/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//*****************************************************************************
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor                : Xilinx
// \   \   \/     Version               : 1.1
//  \   \         Application           : QDRIIP
//  /   /         Filename              : qdriip_v1_4_19_datapath.v
// /___/   /\     Date Last Modified    : $Date: 2015/05/11 $
// \   \  /  \    Date Created          : Thu Oct 24 2013
//  \___\/\___\
//
//Device            : Ultrascale 
//Design            : QDRII+ SRAM
//Purpose           :
//             Contains data muxing between UI and calibration logic
//Reference         :
//Revision History  :
//*****************************************************************************

`timescale 1ps/1ps

module qdriip_v1_4_19_datapath #(

    parameter integer ABITS         = 20
   ,parameter integer DBITS         = 36
   ,parameter integer DBYTES        = 4
   ,parameter integer BURST_LEN     = 4
   ,parameter CAL_MODE 		    = "FAST"
   ,parameter integer TCQ	    = 100
   ,parameter MEM_LATENCY 	    = "2.5"
   ,parameter NO_OF_DEVICES         = 2
   ,parameter SIM_MODE              = "FULL"
   ,parameter RD_LATENCY_SKIP       = ((MEM_LATENCY == "2") && (SIM_MODE != "BFM"))? 10:((SIM_MODE == "BFM")? 13 : 11)
)(
   // Reset and clocks
    input                           div_clk
   ,input                           div_clk_rst
   
   // Inputs from calibration logic
   ,input [3:0]                     cal_doff_n
   ,input [(NO_OF_DEVICES*4)-1:0]   cal_k     
   ,input [3:0]                     cal_wps_n
   ,input [ABITS*4-1:0]             cal_addr
   ,input [DBYTES*4*9-1:0]          cal_dout
   ,input [DBYTES*4-1:0]            cal_bws_n
   ,input [3:0]                     cal_rps_n
   ,input [2*DBITS-1:0]             rd_data_slip 
   ,input [2*DBITS-1:0]             wr_data_slip 
   ,input [2*(DBITS/9)-1:0]         wr_bws_slip 
   ,input [2:0]                     addr_slip
   ,input [4:0]                     rd_valid_cnt
   ,input [2*DBITS-1:0]             fabric_slip 
   ,input                           rd_valid_stg
   ,input                           cal_done

   // Inputs from UI channel 0 and 1
   ,input                           app_wr_cmd0
   ,input [ABITS-1:0]               app_wr_addr0
   ,input [DBITS*BURST_LEN-1:0]     app_wr_data0
   ,input [(DBITS/9)*BURST_LEN-1:0] app_wr_bw_n0
   ,input                           app_rd_cmd0
   ,input [ABITS-1:0]               app_rd_addr0
   ,output [DBITS*BURST_LEN-1:0]    app_rd_data0
   ,output                          app_rd_valid0
   ,input                           app_wr_cmd1
   ,input [ABITS-1:0]               app_wr_addr1
   ,input [DBITS*2-1:0]             app_wr_data1
   ,input [(DBITS/9)*2-1:0]         app_wr_bw_n1
   ,input                           app_rd_cmd1
   ,input [ABITS-1:0]               app_rd_addr1
   ,output [DBITS*2-1:0]            app_rd_data1
   ,output                          app_rd_valid1

   // Interface with PHY
   ,input  [(DBITS*4)-1:0]          map_rd_data
   ,output reg [3:0]		    map_wr_cmd
   ,output reg [3:0]		    map_rd_cmd
   ,output reg [ABITS*4-1:0]        map_addr
   ,output reg [DBITS*4-1:0]        map_wr_data
   ,output reg [DBYTES*4-1:0]       map_bw_n
   ,output [(NO_OF_DEVICES*4)-1:0]  map_k
   ,output [(NO_OF_DEVICES*4)-1:0]  map_k_n  
   ,output [3:0]                    map_doff 
   ,output [(DBITS*4)-1:0]          rd_data_with_slip
);

// Wire declarations
reg  [(DBITS*4)-1:0]  rd_data ;
reg  [(DBITS*4)-1:0]  wr_data_sel ;
reg  [(DBITS*4)-1:0]  wr_data_r ;
reg  [(DBITS*4)-1:0]  wr_data_2r ;
reg  [7:0]            shift_wr_data[DBITS-1:0] ;
reg  [(DBYTES*4)-1:0] wr_bws_n_sel;
reg  [(DBYTES*4)-1:0] wr_bws_n_r;
reg  [(DBYTES*4)-1:0] wr_bws_n_2r;
reg  [7:0]            shift_wr_bws_n[DBYTES-1:0];
reg  [ABITS-1:0]      rd_addr_r ;
reg  [ABITS*4-1:0]    addr_mux ;
reg  [ABITS*4-1:0]    addr_mux_r;
reg  [ABITS*4-1:0]    addr_mux_r1;
reg  [11:0]           shift_addr_mux[ABITS-1:0] ;
reg  [3:0]            wr_cmd ;
reg  [3:0]            rd_cmd ;
reg  [4:0] 	      rd_valid_cnt_r;
reg  [35:0] 	      rd_valid_shift0;
reg  [35:0] 	      rd_valid_shift1;
reg  [DBITS-1:0]      bit_valid_stg_r;
reg  [1:0]            fab_slip_cnt ;
reg  [3:0]            wr_cmd_r ;
reg  [3:0]            rd_cmd_r ;
reg  [3:0]            wr_cmd_r1;
reg  [3:0]            rd_cmd_r1;
reg  [11:0]           shift_wr_cmd ;
reg  [11:0]           shift_rd_cmd ;
integer unsigned      idx; 
reg [3:0]             addr_slip_calc;
reg [2:0]             data_slip_calc[DBITS-1:0];
reg [2:0]             bw_slip_calc[DBYTES-1:0];
(* keep = "TUE" *) reg div_clk_rst_r1;

//***************** Start of the RTL ***********************//

  always @(posedge div_clk)
    div_clk_rst_r1 <= div_clk_rst;

//Splitting the read data bus into 4 parts at the output of ISERDES
always@(posedge div_clk) begin
  for(idx= 0 ; idx < DBITS ; idx = idx + 1) begin
    {rd_data[idx+DBITS*3],rd_data[idx+DBITS*2],
               rd_data[idx+DBITS],rd_data[idx]} <= #TCQ map_rd_data[idx*4+:4] ;
  end
end 

genvar i;
generate
//******** Macro for BL4 specific RTL ********//
  if(BURST_LEN == 4) begin: BL4_LOGIC
    //Muxing the inputs from cal module and UI
    for(i=0; i < ABITS ; i = i + 1) begin
      always @(posedge div_clk) begin
        addr_mux[i*4+:4] <= #TCQ (cal_done == 1) ? {app_wr_addr0[i],app_wr_addr0[i],
                                                    app_rd_addr0[i],app_rd_addr0[i]} 
                                                 : cal_addr[i*4+:4] ;
      end
    end
    always @(posedge div_clk) begin
      wr_cmd <= #TCQ (cal_done == 1) ? {~app_wr_cmd0,~app_wr_cmd0,2'h3}
                                     : {cal_wps_n[1:0],2'h3} ;
      rd_cmd <= #TCQ (cal_done == 1) ? {2'h3,~app_rd_cmd0,~app_rd_cmd0} 
                                     : {2'h3,cal_rps_n[1:0]} ;
    end
	
    //Registering the data to accomodate the 1 cycle write latency in BL4 designs
    always @(posedge div_clk) begin
      wr_data_sel  <= #TCQ (cal_done == 1) ? app_wr_data0 : cal_dout;
      wr_bws_n_sel <= #TCQ (cal_done == 1) ? app_wr_bw_n0 : cal_bws_n;
      wr_data_r  <= #TCQ wr_data_sel;
      wr_bws_n_r <= #TCQ wr_bws_n_sel;
    end

    //Read data is assigned with the bus after read bitslip logic
    //Read valid is assigned with the calibrated latency counter delay
    assign app_rd_data0  = (cal_done == 1) ? rd_data_with_slip : 'b0 ;
    assign app_rd_valid0 = rd_valid_shift0[rd_valid_cnt_r];
    assign app_rd_data1  = 'b0;
    assign app_rd_valid1 = 'b0;

    always @(posedge div_clk) begin
      if (div_clk_rst_r1) begin
        rd_valid_shift0[35:0] <= #TCQ 36'b0;
      end else begin
        rd_valid_shift0[0] <= #TCQ app_rd_cmd0;
        rd_valid_shift0[35:1] <= #TCQ rd_valid_shift0[34:0];
      end
    end

  end //BL4_LOGIC
  
  // ****** Macro for BL2 specific RTL *******//
  if(BURST_LEN == 2) begin: BL2_LOGIC
    //Muxing the inputs from cal module and UI
    for(i=0; i < ABITS ; i = i + 1) begin
      always @(posedge div_clk) begin
        addr_mux[i*4+:4] <= #TCQ (cal_done == 1) ? {app_wr_addr1[i],app_rd_addr1[i],
                                                    app_wr_addr0[i],app_rd_addr0[i]}
                                                 : {cal_addr[3*ABITS+i],cal_addr[2*ABITS+i],
                                                    cal_addr[1*ABITS+i],cal_addr[0*ABITS+i]} ;
      end 
    end
    always @(posedge div_clk) begin
      wr_cmd <= #TCQ (cal_done == 1) ? {~app_wr_cmd1,~app_wr_cmd1,~app_wr_cmd0,~app_wr_cmd0}
                                     : cal_wps_n[3:0] ;
    
      rd_cmd <= #TCQ (cal_done == 1) ? {~app_rd_cmd1,~app_rd_cmd1,~app_rd_cmd0,~app_rd_cmd0}
                                     : cal_rps_n[3:0] ;
    end
	  
    //Simple muxing of write data path based on cal_done
    always @(posedge div_clk) 
    begin
      wr_data_r  <= #TCQ (cal_done == 1) ? {app_wr_data1,app_wr_data0} : cal_dout;
      wr_bws_n_r <= #TCQ (cal_done == 1) ? {app_wr_bw_n1,app_wr_bw_n0} : cal_bws_n;
    end
 
    //Read data is assigned with the bus after read bitslip logic
    //Read valid is assigned with the calibrated latency counter delay
    assign app_rd_data0  = (cal_done == 1) ? rd_data_with_slip[0+:2*DBITS] : 'b0;
    assign app_rd_data1  = (cal_done == 1) ? rd_data_with_slip[2*DBITS+:2*DBITS] : 'b0;
    assign app_rd_valid0 = rd_valid_shift0[rd_valid_cnt_r];
    assign app_rd_valid1 = rd_valid_shift1[rd_valid_cnt_r];
    
    always @(posedge div_clk) begin
      if (div_clk_rst_r1) begin
        rd_valid_shift0[35:0] <= #TCQ 36'b0;
        rd_valid_shift1[35:0] <= #TCQ 36'b0;
      end else begin
        rd_valid_shift0[0]    <= #TCQ app_rd_cmd0;
        rd_valid_shift0[35:1] <= #TCQ rd_valid_shift0[34:0];
        rd_valid_shift1[0]    <= #TCQ app_rd_cmd1;
        rd_valid_shift1[35:1] <= #TCQ rd_valid_shift1[34:0];
      end
    end

  end //BL2_LOGIC
endgenerate

//Registering the address/command and data signals
always @(posedge div_clk) begin
  if (div_clk_rst_r1) begin
    wr_cmd_r <= #TCQ 1'b0;
    rd_cmd_r <= #TCQ 1'b0;
    wr_cmd_r1 <= #TCQ 1'b0;
    rd_cmd_r1 <= #TCQ 1'b0;
    addr_mux_r <= #TCQ 'b0;
    addr_mux_r1 <= #TCQ 'b0;
  end else begin
    wr_cmd_r  <= #TCQ wr_cmd;
    rd_cmd_r  <= #TCQ rd_cmd;
    wr_cmd_r1 <= #TCQ wr_cmd_r;
    rd_cmd_r1 <= #TCQ rd_cmd_r;
    for(idx=0; idx < ABITS ; idx = idx + 1) begin
      addr_mux_r[idx*4+:4]  <= #TCQ addr_mux[idx*4+:4];
      addr_mux_r1[idx*4+:4] <= #TCQ addr_mux_r[idx*4+:4];
    end
  end
end
always @(posedge div_clk) begin
  wr_data_2r  <= #TCQ wr_data_r;
  wr_bws_n_2r <= #TCQ wr_bws_n_r;
end

//Creating the two word shift registers for handling the write bitslip
always @(*) begin
  for(idx=0; idx < ABITS ; idx = idx + 1) begin
    shift_addr_mux[idx] <= #TCQ {addr_mux[idx*4 +:4],addr_mux_r[idx*4 +:4],
                                 addr_mux_r1[idx*4 +:4]};
  end
  shift_wr_cmd <= #TCQ {wr_cmd,wr_cmd_r,wr_cmd_r1};
  shift_rd_cmd <= #TCQ {rd_cmd,rd_cmd_r,rd_cmd_r1};
end
  
always @(posedge div_clk) begin
  for(idx= 0 ; idx < DBITS ; idx = idx + 1) begin
    shift_wr_data[idx] <= #TCQ
                              {{wr_data_r[idx+DBITS*3],wr_data_r[idx+DBITS*2],
                                wr_data_r[idx+DBITS],wr_data_r[idx]},
                               {wr_data_2r[idx+DBITS*3],wr_data_2r[idx+DBITS*2],
                                wr_data_2r[idx+DBITS],wr_data_2r[idx]}};
  end
  for(idx= 0 ; idx < (DBITS/9) ; idx = idx + 1) begin
    shift_wr_bws_n[idx] <= #TCQ 
                          {{wr_bws_n_r[idx+DBYTES*3],wr_bws_n_r[idx+DBYTES*2],
                            wr_bws_n_r[idx+DBYTES],wr_bws_n_r[idx]},
                           {wr_bws_n_2r[idx+DBYTES*3],wr_bws_n_2r[idx+DBYTES*2],
                            wr_bws_n_2r[idx+DBYTES],wr_bws_n_2r[idx]}};
  end
end

//Creating the 4:1 OSERDES inputs for all interface signals
assign map_doff  = cal_doff_n ;
assign map_k     = cal_k ;
assign map_k_n   = ~cal_k ;

always @(posedge div_clk) begin: xiphy_intfc
  if (div_clk_rst_r1) begin
    addr_slip_calc <= #TCQ 'b0;
    for(idx= 0 ; idx < DBITS ; idx = idx + 1) begin
      data_slip_calc[idx] <= #TCQ 'b0;
    end
    for(idx= 0 ; idx < DBYTES ; idx = idx + 1) begin
      bw_slip_calc[idx]   <= #TCQ 'b0;
    end
  end else begin
    for(idx=0 ; idx < ABITS ; idx = idx +1) begin
      map_addr[4*idx+:4] <= #TCQ shift_addr_mux[idx][addr_slip_calc +:4];
    end 
    addr_slip_calc <= #TCQ (8-addr_slip);

    map_rd_cmd <= #TCQ shift_rd_cmd[addr_slip_calc +:4];
    map_wr_cmd <= #TCQ shift_wr_cmd[addr_slip_calc +:4];

    for(idx= 0 ; idx < DBITS ; idx = idx + 1) begin
      data_slip_calc[idx] <= #TCQ (4-wr_data_slip[idx*2+:2]);
      //map_wr_data[idx*4+:4] <= #TCQ shift_wr_data[idx][(4-wr_data_slip[idx*2+:2]) +:4];
      map_wr_data[idx*4+:4] <= #TCQ shift_wr_data[idx][data_slip_calc[idx] +:4];
    end

    for(idx= 0 ; idx < DBYTES ; idx = idx + 1) begin
      bw_slip_calc[idx]   <= #TCQ (4-wr_bws_slip[idx*2+:2]);
      //map_bw_n[idx*4+:4] <= #TCQ shift_wr_bws_n[idx][(4-wr_bws_slip[idx*2+:2]) +:4];
      map_bw_n[idx*4+:4] <= #TCQ shift_wr_bws_n[idx][bw_slip_calc[idx] +:4];
    end
  end
end

always @(posedge div_clk) begin
  rd_valid_cnt_r <= #TCQ (CAL_MODE == "SKIP") ? RD_LATENCY_SKIP
                                              : (rd_valid_cnt+rd_valid_stg-5) ;
end

// Read bitslip calibration instance
genvar bit_i;
generate
  for(bit_i = 0; bit_i < (DBITS); bit_i = bit_i+1) begin : slip_for_bit
    qdriip_v1_4_19_rd_bit_slip #
      (
        .TCQ         (TCQ)
      )
      qdr_rd_bit_slip
      (
        .clk         (div_clk),
        .rst         (div_clk_rst_r1),
        .slip        (rd_data_slip[bit_i*2+:2]),
        .rvalid_stg  (fabric_slip[bit_i*2+:2]),
        .data_in     ({rd_data[bit_i+DBITS*3],rd_data[bit_i+DBITS*2],
                       rd_data[bit_i+DBITS],rd_data[bit_i]}),
        .data_out    ({rd_data_with_slip[bit_i+DBITS*3],
                       rd_data_with_slip[bit_i+DBITS*2],
                       rd_data_with_slip[bit_i+DBITS],
                       rd_data_with_slip[bit_i]})
      );
  end
endgenerate

endmodule


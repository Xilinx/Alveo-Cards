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
//  /   /         Filename              : qdriip_v1_4_19_cal.v
// /___/   /\     Date Last Modified    : $Date: 2015/05/15 $
// \   \  /  \    Date Created          : Thu Oct 24 2013
//  \___\/\___\
//
//Device            : Ultrascale 
//Design            : QDRII+ SRAM
//Purpose           :
//         Instantiates all modules required for the calibration such as 
//         Microblaze, cal_addr_decoder and config_rom. It also has the
//         XSDB debug interface.
//Reference         :
//Revision History  :
//*****************************************************************************

`timescale 1ps/1ps

module qdriip_v1_4_19_cal_fab #
(
    parameter integer ABITS                     = 21
   ,parameter integer DBITS                     = 18
   ,parameter integer BYTES                     = 6
   ,parameter integer DBYTES                    = 4
   ,parameter integer BURST_LEN                 = 4
   ,parameter BISC_ON                           = 1
   ,parameter RDLVL				= "ON"
   ,parameter K_TO_WR_CAL			= "ON"
   ,parameter STEP_SIZE				= 20 
   ,parameter CAL_MODE                          = "FAST"
   ,parameter tCK				= 2500 
   ,parameter MEM_LATENCY			= "2"
   ,parameter PWR_UP_SEQ_TIME_CLK		= 100
   ,parameter TCQ				= 100 
   ,parameter NO_OF_DEVICES                     = 1
   ,parameter CLK_2TO1				= "TRUE"
   ,parameter C_FAMILY                          = "kintexu"
 
   ,parameter C_MEM_TYPE                        = 4
   ,parameter C_PARAM_MAP_VER                   = 16'h0004
   ,parameter C_ERR_MAP_VER                     = 16'h0002
   ,parameter C_CAL_MAP_VER                     = 16'h0003
   ,parameter C_WARN_MAP_VER                    = 16'h0001

   ,parameter CAL_VER_RTL                       = 2
   ,parameter C_MAJOR_VERSION                   = 2015
   ,parameter C_MINOR_VERSION                   = 4
   ,parameter C_CORE_MAJOR_VER                  = 1
   ,parameter C_CORE_MINOR_VER                  = 1
   ,parameter C_NEXT_SLAVE                      = 1'b0
   ,parameter C_CSE_DRV_VER                     = 16'h0002
   ,parameter C_USE_TEST_REG                    = 1
   ,parameter C_PIPE_IFACE                      = 1
   ,parameter C_CORE_INFO1                      = 0
   ,parameter C_CORE_INFO2                      = 0
   ,parameter SIM_MODE                          = "FULL"
)(
   input                          clk
  ,input                          rst

  ,input                         bisc_complete
  ,input                         vtc_complete
  ,input  [DBITS*4-1:0]          mcal_dqin
  ,output                        reg cal_done_r
  ,output                        en_vtc
  ,output [3:0]                  cal_doff_n
  ,output [(NO_OF_DEVICES*4)-1:0] cal_k     
  ,output [3:0]                  cal_wps_n
  ,output [ABITS*4-1:0]          cal_addr
  ,output [DBYTES*4*9-1:0]       cal_dout
  ,output [DBYTES*4-1:0]         cal_bws_n
  ,output [3:0]                  cal_rps_n
  ,output [2*DBITS-1:0]          rd_data_slip 
  ,output [2*DBITS-1:0]          wr_data_slip 
  ,output [2*(DBITS/9)-1:0]      wr_bws_slip 
  ,output [2:0]                  addr_slip
  ,output [4:0]                  rd_valid_cnt
  ,output [2*DBITS-1:0]          fabric_slip
  ,output                        rd_valid_stg
  ,output reg [31:0]             all_nibbles_t_b
  ,output                        clb2phy_rden

  //Interface with MicroBlaze
  ,input [27:0]                   io_address
  ,input                          io_addr_strobe
  ,input                          io_write_strobe
  ,input [31:0]                   io_write_data
  ,output reg [31:0]              io_read_data
  ,output reg                     io_ready

  // Debug ports
  ,input  [36:0]                 sl_iport0
  ,output [16:0]                 sl_oport0
  ,output [299:0]                dbg_bus
 
  ,input [DBYTES*9*4-1:0] traffic_error
  ,output traffic_clr_error
  ,input [3:0] win_start
  ,input traffic_wr_done
  ,output [31:0] win_status
);

//No of taps required to 90 degree displacement. Assuming that each tap resolution is 5ps.
localparam TAPS_90   = (tCK/4)/5 ;
localparam DEBUG     = "ON" ;
localparam DEBUG_REG = (((RDLVL == "ON") ? 32'h00000010 : 32'h00000000) | ((K_TO_WR_CAL == "ON")? 32'h00000080 : 32'h00000000)) ;
localparam CAL_RDLVL       = (RDLVL == "ON") ? 1 : 0 ;
localparam CAL_MODE_LBL    = (CAL_MODE=="FULL") ? 0 : ((CAL_MODE=="SKIP") ? 1 : 2);
localparam CAL_K_TO_WRITE  = (K_TO_WR_CAL == "ON") ? 1 : 0 ;
localparam SAMPLE_CNT      = (CAL_MODE=="FAST") ? 1 : ((CAL_MODE=="FULL") ? 500 : 50);
localparam RDLVL_MIN_EYE   = 35;
localparam MEM_LATENCY_LBL = (MEM_LATENCY == "2.5") ? 1 : 0 ;

// Initialization
wire [99:0]   dbg_bus_lcl;
wire        cal_done ;
wire [3:0]  cal_doff_n_tmp ;
reg         cal_initdone;
wire        initdone;
wire        pwrup_done;
reg         cal_initdone_pwr_up ;
reg [6:0]   count ;
reg [15:0]  count_pwr_up ;
reg         ub_ready ;
wire [31:0] all_nibbles_t_b_int;

//ROM configuration
wire [7:0]  config_rd_addr;     //ROM address 
wire [31:0] config_rd_data;     //ROM data

//Debug RAM
wire        dbg_wr_en;       //Debug Ram wr enable
wire        dbg_rd_en;       //Debug Ram wr enable
wire [31:0] dbg_wr_data;     //Debug Ram write data
wire [11:0] dbg_addr;        //Debug Ram address
wire [8:0]  dbg_rd_data;     //Debug Ram read data


//*************************************************************************//
//*********************** Start of the RTL ********************************//
//*************************************************************************//

// Debug port
assign dbg_bus[0+:100] = dbg_bus_lcl;
assign dbg_bus[100+:DBITS] = mcal_dqin[0*DBITS+:DBITS];
assign dbg_bus[136+:DBITS] = mcal_dqin[1*DBITS+:DBITS];
assign dbg_bus[172+:DBITS] = mcal_dqin[2*DBITS+:DBITS];
assign dbg_bus[208+:DBITS] = mcal_dqin[3*DBITS+:DBITS];
assign dbg_bus[299:244] = 56'b0;

// Asserting cal done based on the cal_mode
always @(posedge clk) begin
 if (rst) begin
   cal_done_r <= #TCQ 0;
 end else begin
   if (CAL_MODE == "SKIP")
     cal_done_r <= #TCQ cal_initdone;
   else
     cal_done_r <= #TCQ cal_done;
  end
end

// calculating all_nibbles_t_b
always @(posedge clk) begin
 if (rst)
   all_nibbles_t_b <= #TCQ 32'b0;
 else if (ub_ready)
   all_nibbles_t_b <= #TCQ all_nibbles_t_b_int;
 else if (bisc_complete)
   all_nibbles_t_b <= #TCQ 32'hFFFFFFFF;
end

// cal_initdone --> simple wait time bofore starting the power up sequence
// cal_initdone_pwr_up --> power up sequence is completed
// Power up sequence for QDRII+ is mentioned below
// 1. Wait till the K clocks are stable (we are de-asserting reset after lock)
// 2. Wit for 20us (cypress) or 2048 clocks with stable clocks
//              (this time duration is for the PLL inside the device to lock)
// 3. Go to the normal operation, that it!!
always@(posedge clk)begin
  if(rst || ~bisc_complete) begin
    cal_initdone        <= #TCQ  1'b0 ;
    cal_initdone_pwr_up <= #TCQ 1'b0 ;
    count        <= 'b0 ;
    count_pwr_up <= 'b0 ;
  end else begin
    if(~cal_initdone) begin
      count        <= #TCQ  count + 1 ;
      cal_initdone <= #TCQ  count[6]   ;
    end
    if(initdone & (~cal_initdone_pwr_up)) begin
      count_pwr_up        <= #TCQ count_pwr_up +1 ;
      cal_initdone_pwr_up <= #TCQ pwrup_done ;
    end 
  end
end

assign initdone   = (CAL_MODE == "SKIP") ? cal_initdone : ub_ready ;
assign cal_doff_n = (CAL_MODE == "SKIP") ? 4'hF : ((ub_ready == 1) ? 4'hF : 'b0) ;
assign pwrup_done = (CAL_MODE == "FAST") ? 1 : (count_pwr_up == PWR_UP_SEQ_TIME_CLK) ;

genvar i;
generate
  for(i=0;i<NO_OF_DEVICES;i=i+1) begin: CAL_K_INST
    assign cal_k[(4*(i+1))-1:(4*i)] = (cal_initdone == 1) ? 4'b0101 : 4'b0000 ;
  end
endgenerate

// Address Decoder
qdriip_v1_4_19_cal_addr_decode #(
    .DBYTES           (DBYTES),
    .DBITS            (DBITS),
    .ABITS            (ABITS),
    .BURST_LEN        (BURST_LEN),
    .CLK_2TO1         (CLK_2TO1),
    .MEM_LATENCY      (MEM_LATENCY),
    .CAL_MODE         (CAL_MODE),
    .SIM_MODE         (SIM_MODE),
    .TCQ              (TCQ)
)caladdrdecode(
    .clk                          (clk),
    .rst                          (rst),

    .io_address                   (io_address),
    .io_addr_strobe               (io_addr_strobe),
    .io_write_strobe              (io_write_strobe),
    .mb_to_addr_dec_data          (io_write_data),
    .addr_dec_to_mb_data          (io_read_data),
    .io_ready                     (io_ready),

    .init_done                    (cal_initdone),
    .cal_initdone_pwr_up          (cal_initdone_pwr_up),
    .vtc_complete                 (vtc_complete),
    .cal_done                     (cal_done),
    .en_vtc                       (en_vtc),
    .mcal_dqin                    (mcal_dqin),
     
    .cal_rps_n_r                  (cal_rps_n),
    .cal_wps_n_r                  (cal_wps_n),
    .cal_doff_r                   (cal_doff_n_tmp),
    .cal_dqout_r                  (cal_dout),
    .cal_bws_n_r                  (cal_bws_n),
    .cal_addr_r                   (cal_addr),
    .clb2phy_rden_r               (clb2phy_rden),
    .ub_ready_r                   (ub_ready),
    .all_nibbles_t_b              (all_nibbles_t_b_int),

    .rd_data_slip_r               (rd_data_slip),
    .wr_data_slip_r               (wr_data_slip),
    .wr_bws_slip_r                (wr_bws_slip),
    .addr_slip_r                  (addr_slip),
    .rd_latency_val_r             (rd_valid_cnt),
    .fabric_slip_r                (fabric_slip),
    .single_stg_fabslip_r         (rd_valid_stg),
    
    .dbg_wr_en_r                  (dbg_wr_en),
    .dbg_wr_data_r                (dbg_wr_data),
    .dbg_addr                     (dbg_addr),
    .dbg_rd_en                    (dbg_rd_en),
    .dbg_rd_data                  (dbg_rd_data),
    
    .config_rd_data               (config_rd_data),
    .config_rd_addr               (config_rd_addr),

    .dbg_bus                      (dbg_bus_lcl),
    .traffic_error                (traffic_error),
    .traffic_clr_error            (traffic_clr_error),
    .win_start                    (win_start),
    .traffic_wr_done              (traffic_wr_done),
    .win_status                   (win_status)
);

//rom configuration
qdriip_v1_4_19_config_rom #
(
 .MEM0    (C_MEM_TYPE),  //MEMORY_TYPE
 .MEM1    (ABITS),
 .MEM2    (1),//(WPSN_BITS),
 .MEM3    (1),//(RPSN_BITS),
 .MEM4    (BYTES),//(BYTES),
 .MEM5    (DBYTES),//(D_BYTES),
 .MEM6    (DBITS),//(DATA_WIDTH),
 .MEM7    (DBITS/NO_OF_DEVICES), //BITS_IN_BYTE
 .MEM8    (tCK),//TCK
 .MEM9    (2),	//NCK_PER_CLK	
 .MEM10	  (CAL_RDLVL),
 .MEM11	  (0),	//CAL_WRITE_CAL
 .MEM12   (CAL_MODE_LBL),
 .MEM13   (0),  
 .MEM14   (0),	//CAL_INIT_RD_CAL    		
 .MEM15   (CAL_K_TO_WRITE),  //CAL_K_TO_WRITE
 .MEM16   (0),	//CAL_AC     			
 .MEM17   (0),	//CAL_BITSLIP_RDVLD		
 .MEM18   (0),	//CAL_PRBS_RDLVL			
 .MEM19   (SAMPLE_CNT),	//DQS_SAMPLE_CNT		
 .MEM20	  (SAMPLE_CNT),	//WRLVL_SAMPLE_CNT	
 .MEM21	  (SAMPLE_CNT), //RDLVL_SAMPLE_CNT
 .MEM22   (RDLVL_MIN_EYE),		
 .MEM23   (5),	//RDLVL_RANGE_CHK		
 .MEM24   ((DEBUG == "ON")? DEBUG_REG : 0),
 .MEM25   (STEP_SIZE),
 .MEM26   (BISC_ON),
 .MEM27   (MEM_LATENCY_LBL),
 .MEM28   (TAPS_90),
 .MEM29   (0),
 .MEM30   (0),
 .MEM31   (BURST_LEN),
 .MEM32   (0)
 )protype_rom
 (
   .clk_i   (clk),
   .rst_i   (rst),
   .rd_addr (config_rd_addr[5:0]),
   .dout_o  (config_rd_data)
 );

//-------------------------------------------------------------------
// XSDB slave 
//-------------------------------------------------------------------
wire s_rst;
wire s_dclk;
wire s_den; 
wire s_dwe;
wire [16:0] s_daddr;
wire [15:0] s_di;
wire [15:0] s_do;
reg s_drdy;

`ifndef XSDB_SLV_DIS
(* DONT_TOUCH = "true" *) mem_v1_4_0_chipscope_xsdb_slave
#(
   .C_XDEVICEFAMILY	(C_FAMILY),
   .C_MAJOR_VERSION	(C_MAJOR_VERSION),  // ise major version
   .C_MINOR_VERSION	(C_MINOR_VERSION),  // ise minor version
   .C_BUILD_REVISION	(),                 // ise service pack
   .C_CORE_TYPE		(16'h0008),      // root coregen type 
   .C_CORE_MAJOR_VER	(C_CORE_MAJOR_VER), // root coregen core major version
   .C_CORE_MINOR_VER	(C_CORE_MINOR_VER), // root corgen core minor version
   .C_XSDB_SLAVE_TYPE	(16'h0084),// XSDB Slave Type
   .C_NEXT_SLAVE	(C_NEXT_SLAVE),     // Next slave Relative reference neighbor which is part of the core.
   .C_CSE_DRV_VER	(C_CSE_DRV_VER),    // CSE Slave driver version
   .C_USE_TEST_REG	(C_USE_TEST_REG),   // Set to 1 to use test reg
   .C_PIPE_IFACE	(C_PIPE_IFACE),     // Set to 1 to add pipe delay to XSDB interface signals
   .C_CORE_INFO1	(C_CORE_INFO1),
   .C_CORE_INFO2	(C_CORE_INFO2) 
) 
U_XSDB_SLAVE 
(
   .s_rst_o    (s_rst),
   .s_dclk_o   (s_dclk),
   .s_den_o    (s_den),
   .s_dwe_o    (s_dwe),
   .s_daddr_o  (s_daddr),
   .s_di_o     (s_di),
   .sl_iport_i (sl_iport0), // ports, need to route up to core wrapper
   .sl_oport_o (sl_oport0), // ports, need to route up to core wrapper
   .s_do_i     ({7'b0,s_do[8:0]}),
   .s_drdy_i   (s_drdy)
);
`else
assign s_rst = 1'b0;
assign s_dclk = 1'b0;
assign s_den = 1'b0;
assign s_dwe = 1'b0;
assign s_daddr = 17'b0;
assign s_di = 16'b0;
assign sl_oport0 = 16'b0;
`endif

//----------------------
//s_rdy generation
//----------------------
//pipeline s_drdy for 2 clocks
reg t1, t2;
wire s_den_1;

always@(posedge s_dclk)
begin
t1 <= s_den;
t2 <= t1;
s_drdy <= t2;
end

//strech s_den pulse for 2 clocks to enable b-side of dpBRAM
assign s_den_1 = t1 | s_den;

//-------------------------------------------------------------------
//Bram for XSDB and uB wr/rd
//-------------------------------------------------------------------
(* DONT_TOUCH = "true" *) qdriip_v1_4_19_xsdb_bram
#(
   // Header
   .START_ADDRESS         (18),
   .PARAM_MAP_VERSION     (C_PARAM_MAP_VER),
   .MEMORY_TYPE           (C_MEM_TYPE),				
   .RANK                  (1),
   .DBYTES                (DBYTES),
   .QDR_BYTE_LEN          (9),
   .ERROR_MAP_VERSION     (C_ERR_MAP_VER),
   .CAL_MAP_VERSION       (C_CAL_MAP_VER),
   .WARN_MAP_VERSION      (C_WARN_MAP_VER),
   // RTL versions
   .CAL_VER_RTL           (CAL_VER_RTL),
   // Config ROM
   .ABITS                 (ABITS),
   .WPSN_BITS             (1),
   .RPSN_BITS             (1),
   .BYTES                 (BYTES),
   .DATA_WIDTH            (DBITS),
   .BITS_PER_BYTE         (DBITS/NO_OF_DEVICES),
   .TCK                   (tCK),
   .NCK_PER_CLK           (2),
   .CAL_RDLVL             (CAL_RDLVL),
   .CAL_FAST              (CAL_MODE_LBL),
   .CAL_K_TO_WRITE        (CAL_K_TO_WRITE),
   .DQS_SAMPLE_CNT        (SAMPLE_CNT/10),
   .RDLVL_MIN_EYE         (RDLVL_MIN_EYE),
   .STEP_SIZE             (STEP_SIZE),
   .BISC_ON               (BISC_ON),
   .MEM_LATENCY           (MEM_LATENCY_LBL),
   .TAPS_90               (TAPS_90),
   .BURST_LEN             (BURST_LEN)
)
QDRIIP_XSDB_BRAM
(
   .addra   (dbg_addr),  //MB writes on side a, using 12 bits from Addr decoder 
   .clka    (clk),         //Side a uses same clock as RIU
   .dina    (dbg_wr_data[8:0]),
   .douta   (dbg_rd_data[8:0]),
   .ena     (dbg_rd_en),
   .wea     (dbg_wr_en),
   .rsta(1'b0), // portA reset. Tied to '0' (not asserted)
   .rstb(1'b0), // portB reset. Tied to '0' (not asserted)
	
   .addrb   (s_daddr[11:0]),   // XSDB reads on side b using sl_iport_i[11:0] for addr input; max 16bits supported
   .clkb    (s_dclk),          //Side b uses the same clock that XSDB master generated
   .dinb    (s_di[8:0]),       //XSDB writes with user's data
   .doutb   (s_do[8:0]),       //Output of Bram to XSDB, using sl_oport_o[8:0]
   .enb     (s_den_1),         //stretched pulse to latch output BRAM data
   .web     (s_dwe)            //xsdb_write's enable for BRAM 
);

endmodule

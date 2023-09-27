/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

`ifdef MODEL_TECH

`define PATH u_mig_qdriip_phy.inst

integer datawidth;
integer ckwidth; 
localparam BYTES = `PATH.BYTES;
reg [13*BYTES-1:0] fifo_sync_mode       = {(13*BYTES){1'b0}};
reg [45*BYTES-1:0] gclk_src             = {(45*BYTES){1'b0}};
reg [2*BYTES-1:0]  tri_output_phase_90  = {(BYTES*2){1'b0}};
reg [2*BYTES-1:0]  serial_mode          = {BYTES{2'b00}};
reg [BYTES-1:0][1:0] en_clk_to_ext_north = {BYTES{2'b00}};
reg [BYTES-1:0][1:0] en_clk_to_ext_south = {BYTES{2'b00}};
reg [13*BYTES-1:0] dci_src              = {(BYTES*13){1'b0}};
reg [2*BYTES-1:0]  idly_vt_track        = {(2*BYTES){1'b0}};
reg [2*BYTES-1:0]  odly_vt_track        = {(2*BYTES){1'b0}};
reg [2*BYTES-1:0]  qdly_vt_track        = {(2*BYTES){1'b0}};
reg [2*BYTES-1:0]  rxgate_extend        = {(2*BYTES){1'b0}};
reg [15*BYTES-1:0] init                 = {(15*BYTES){1'b1}}; 
reg [13*BYTES-1:0] tx_output_phase_90   = {(13*BYTES){1'b0}};
reg [BYTES-1:0][1:0] en_other_pclk;                  
reg [BYTES-1:0][1:0] en_other_nclk;                  
reg [BYTES-1:0][1:0] rx_clk_phase_p;                 
reg [BYTES-1:0][1:0] rx_clk_phase_n;                 
reg [2*BYTES-1:0]  tx_gating	      = {(2*BYTES){1'b0}};                      
reg [2*BYTES-1:0]  rx_gating	      = {(2*BYTES){1'b0}};                      
reg [BYTES-1:0][1:0] en_dyn_odly_mode;               
reg [13*BYTES-1:0] rxtx_bitslice_en;
reg [BYTES-1:0][14:0] rx_data_type;
reg [1:0] refclk_src                          = 2'b00;
integer rx_delay_val     [12:0]                   = '{0,0,0,0,0,0,0,0,0,0,0,0,0};
integer tx_delay_val     [12:0]                   = '{0,0,0,0,0,0,0,0,0,0,0,0,0};
integer tri_delay_val    [1:0]                    = '{0, 0};
integer read_idle_count  [1:0]                = '{31, 31};
integer rounding_factor  [1:0]                = '{16, 16};
reg   [1:0] ctrl_clk                          = 2'b11; 
reg [16:0] tfabric1,tfabric2;//Expected tfabric range
reg [16:0] tddr3_ck_1,tddr3_ck_2;//Expected ddr3_ck range

// local variables
int k_index=0,out_bytes=0,data_bytes,addr_bytes,inc,last_index,first_index=12;
bit low_addr=1;
bit [BYTES-1:0]out_index= {(BYTES){1'b0}};
int inv_index[2]='{0,0},j=0,rx_index=0; 


 /*
	Generate expected values for rx_data type from `PATH.IOBTYPE and `PATH.INV_RXCLK 
 */
 function void exp_rx_data_type();
    for(int i1=0;i1<BYTES *13 ;i1++) begin 
	    	// For Input lane  if CQ placed then clock or data 
        	if((((`PATH.INV_RXCLK >> (i1/13)*2) & 2'h2 )== 2'h2) && (((`PATH.IOBTYPE >> i1*3) & 3'h2) == 3'h2))begin
        		if((i1%13)==0)
        			rx_data_type[i1/13][1:0] = 2'b11;				
			else if((i1%13)==6)				
        			rx_data_type[i1/13][8:7] = 2'b11;				
        		else if((i1%13)>0 && (i1%13)<6)
        			rx_data_type[i1/13][(i1%13)+1] = 1'b1;
        		else if((i1%13)>6 && (i1%13)<13)
        			rx_data_type[i1/13][(i1%13)+2] = 1'b1;
            	end 
        	else if((((`PATH.INV_RXCLK >> (i1/13)*2) & 2'b11) == 2'b00) && (((`PATH.IOBTYPE >> i1*3) & 3'h2) == 3'h2))begin
        		if((i1%13)==0)
        			rx_data_type[i1/13][1:0] = 2'b01;				
			else if((i1%13)==6)				
        			rx_data_type[i1/13][8:7] = 2'b01;				
        		else if((i1%13)>0 && (i1%13)<6)
        			rx_data_type[i1/13][(i1%13)+1] = 1'b1;
        		else if((i1%13)>6 && (i1%13)<13)
        			rx_data_type[i1/13][(i1%13)+2] = 1'b1;
            	end
		// For output if  not used then 0 or else 1
        	else if((((`PATH.IOBTYPE >> i1*3) & 3'h1) == 3'h1)) begin 
			if((i1%13)==0)
        			rx_data_type[i1/13][1:0] = 2'b11;				
			else if((i1%13)==6)				
        			rx_data_type[i1/13][8:7] = 2'b11;				
        		else if((i1%13)>0 && (i1%13)<6)
        			rx_data_type[i1/13][(i1%13)+1] = 1'b1;
        		else if((i1%13)>6 && (i1%13)<13)
        			rx_data_type[i1/13][(i1%13)+2] = 1'b1;
				
        	end		
        	else if(((`PATH.IOBTYPE >> i1*3) & 3'h7) == 3'h0) begin 
			if((i1%13)==0)
        			rx_data_type[i1/13][1:0] = 2'b00;				
			else if((i1%13)==6)				
        			rx_data_type[i1/13][8:7] = 2'b00;				
        		else if((i1%13)>0 && (i1%13)<6)
        			rx_data_type[i1/13][(i1%13)+1] = 1'b0;
        		else if((i1%13)>6 && (i1%13)<13)
        			rx_data_type[i1/13][(i1%13)+2] = 1'b0;
        	end 
		// default case 
        	else begin 
			if((i1%13)==0)
        			rx_data_type[i1/13][1:0] = 2'b00;				
			else if((i1%13)==6)				
        			rx_data_type[i1/13][8:7] = 2'b00;				
        		else if((i1%13)>0 && (i1%13)<6)
        			rx_data_type[i1/13][(i1%13)+1] = 1'b0;
        		else if((i1%13)>6 && (i1%13)<13)
        			rx_data_type[i1/13][(i1%13)+2] = 1'b0;
        	end			
    end
 endfunction
	
 /*
	Generate expected values for cloking parameters from `PATH.IOBTYPE and `PATH.INV_RXCLK
 */
 function void exp_en_clk();
 begin
 	

	 //for read data bytes below parameters are set
	for(int i1=0;i1<BYTES;i1++) begin 
		if((((`PATH.IOBTYPE >> i1*3*13) & 3'h2) == 3'h2)) begin
			en_other_pclk[i1][1:0] = 2'b10; 
			en_other_nclk[i1][1:0] = 2'b01; 
			rx_clk_phase_p[i1][1:0] = 2'b11; 
			rx_clk_phase_n[i1][1:0] = 2'b11; 
			en_dyn_odly_mode[i1][1:0] = 2'b11;
		end
		else begin 
		  en_other_pclk[i1][1:0] = 2'b00; 
		  en_other_nclk[i1][1:0] = 2'b00; 
		  rx_clk_phase_p[i1][1:0] = 2'b00; 
		  rx_clk_phase_n[i1][1:0] = 2'b00;
		  en_dyn_odly_mode[i1][1:0] = 2'b00;
		end			
	end 
	
	// Find RX clock location and set
	for(int i1=0;i1<BYTES;i1++) begin 
		if((((`PATH.INV_RXCLK >> i1*2) & 2'h2) == 2'h2) || (((`PATH.INV_RXCLK >> i1*2) & 2'h1) == 2'h1)) begin
			inv_index[j++] = i1; 
		end 
		if((((`PATH.IOBTYPE >> i1*3*13) & 3'h2) == 3'h2)) begin 
			rx_index = i1;	
		end			
	end 
	
	for(int i1=0;i1<BYTES;i1++) begin 
		if(`PATH.DBITS == 36)begin
			if(i1 == inv_index[0]) begin 
				en_clk_to_ext_south[i1][1:0] = 2'b11 ; 
			end			
			else begin
				en_clk_to_ext_south[i1][1:0] = 2'b00 ; 
			end			
			
			
			if(i1 == inv_index[0] && inv_index[1]==0 ) begin 
				en_clk_to_ext_north[i1][1:0] = 2'b11 ;
			end 
			else begin
				en_clk_to_ext_north[i1][1:0] = 2'b00 ;
			end			
			
			if(inv_index[1] > 0) begin			
				if(i1 == inv_index[1]) 			
					en_clk_to_ext_north[i1][1:0] = 2'b11 ;
				else 
					en_clk_to_ext_north[i1][1:0] = 2'b00 ;
			end 
		end
		else begin 
			if(rx_index == inv_index[0]) begin	 
				en_clk_to_ext_south[rx_index][1:0] = 2'b11 ;			
			end
			else begin
				en_clk_to_ext_north[rx_index-1][1:0] = 2'b11;
			end				
		end			
	end
 end
 endfunction 

 /*
	Generate expected tx_output_phase_90 based on `PATH.IOBTYPE 
 */
 function void  exp_tx_phase_90();
 begin 

    // Find total o/p bytes , addr_bytes and data_bytes	
    for(int i1=0;i1<BYTES*13;i1++) begin 
	if(((`PATH.IOBTYPE >> i1*3) & 3'b001) == 3'b001) begin
		if(out_index[i1/13]!=1)
			out_bytes++; 
		if(first_index == 12) 
			first_index = i1/13;
		out_index[i1/13]=1;
		last_index = i1/13; 
	end 
	data_bytes = (`PATH.DBITS == 18)?2:4;
	addr_bytes = out_bytes - data_bytes;
    end	


    // tx_out_phase 1 for k clock always 
    // k_clock from IOB_TYPE
    for(int i1=0;i1<BYTES*13;i1++) begin 
	if(((`PATH.IOBTYPE >> i1*3) & 3'b101) == 3'b101) begin
		tx_output_phase_90[i1] = 1'b1;	
		if(k_index ==0)
			k_index = i1/13;
	end 
 	
    end	

    if(`PATH.BURST_LEN != 2)
    begin
         if(k_index > first_index+2) 
        		low_addr=0;	
         else	
        		low_addr=1;
             $display("k_index %d out_index %b data_bytes%b addr_bytes%d last_index%d first_index %d low_addr %b",k_index,out_index,data_bytes,addr_bytes,last_index,first_index,low_addr);
        	//  1'b1 for A/C byte lane also
         if(low_addr == 0) 
         begin 
         	for(int i=first_index;i<first_index+addr_bytes;i++)
             begin 
                    for(int j=0;j<13;j++)
                    begin
             		if(((`PATH.IOBTYPE >> (i*13+j)*3) & 3'h7) != 3'h0)
             			tx_output_phase_90[i*13+j]=1;
                    end					
             end
         end
         else
         begin	    
         	for(int i=last_index;i>last_index-addr_bytes;i--)
             begin
                    for(int j=0;j<13;j++)
                    begin
             		if(((`PATH.IOBTYPE >> (i*13+j)*3) & 3'h7) != 3'h0)
             			tx_output_phase_90[i*13+j]=1;

                    end					

             end	
         end
    end
 end
 endfunction 
 
 // Generate rxtx bit slice en based up on unused pin in IOBTYPE
 function void exp_rxtx_en() ; 
    bit entered;
    for(int i1=0;i1<BYTES*13;i1++) begin 
    	if(((`PATH.IOBTYPE >> (i1*3)) & 3'h7) != 3'b000)begin
	      rxtx_bitslice_en[i1] = 1'b1;  
	end 
    	else begin 
	      rxtx_bitslice_en[i1] = 1'b0;
	end	      
 	// For k clock o/p	
	if(((`PATH.IOBTYPE >> i1*3) & 3'b101) == 3'b101) begin 
				if(entered == 1'b0)	
				    entered = 1'b1;
			  else
				begin				
	          rxtx_bitslice_en[i1] = 1'b0;  
						entered = 1'b0;
				end		
	end			
    end		
 endfunction
 
  task tfabric_tddr3_ck_cal;
   begin
   time t1,t2,t3,t4,t5,t6;
      @(negedge c0_qdriip_rst_clk);
      fork
      begin
      @(posedge c0_qdriip_clk);
         t1 = $time;
         repeat(100)@(posedge c0_qdriip_clk);
         t2 = $time;
         t3 = (t2 - t1)/100;
         tfabric1 = t3 - t3/100;
         tfabric2 = t3 + t3/100;
      end
      begin
         @(posedge c0_qdriip_k_p[0]);
          t4 = $time;
          repeat(100)@(posedge c0_qdriip_k_p[0]);
          t5 = $time;
          t6 = (t5 -t4)/100 ;
          tddr3_ck_1 = t6 - t6/100;
          tddr3_ck_2 = t6 + t6/100;
      end
      join
   end
 endtask

 
 initial 
 begin
  
  exp_rx_data_type(); 
  exp_en_clk();
  exp_rxtx_en();
  exp_tx_phase_90();
  tfabric_tddr3_ck_cal();
  
  XIP_PLLCLK_SRC:assert (`PATH.PLLCLK_SRC === 1'b0) 
      else $display("INCORRECT PARAMETER: PLLCLK_SRC \
         Expected value is 'd%0d Generated value is 'd%0d",0,`PATH.PLLCLK_SRC);


  XIP_BYTES:assert (BYTES >= `PATH.DBYTES + 2) 
      else $display("INCORRECT PARAMETER: BYTES \
         Expected value is 'd%0d Generated value is 'd%0d",`PATH.DBYTES + 2,BYTES);

  XIP_INIT:assert (`PATH.INIT === init) 
      else $display("INCORRECT PARAMETER: INIT \
         Expected value is 'd%0d Generated value is 'd%0d",init,`PATH.INIT);


  XIP_CTRL_CLK:assert (`PATH.CTRL_CLK === ctrl_clk) 
      else $display("INCORRECT PARAMETER: CTRL_CLK  \
         Expected value is 'd%0d Generated value is 'd%0d",ctrl_clk,`PATH.CTRL_CLK);

  XIP_DATA_WIDTH:assert (`PATH.DATA_WIDTH === 4) 
      else $display("INCORRECT PARAMETER: DATA_WIDTH \
         Expected value is 'd%0d Generated value is 'd%0d",4,`PATH.DATA_WIDTH);

  XIP_DIV_MODE:assert (`PATH.DIV_MODE === 2'b11) 
      else $display("INCORRECT PARAMETER: DIV_MODE \
         Expected value is 'd%0d Generated value is 'd%0d",2'b11,`PATH.DIV_MODE);

  XIP_TX_OUTPUT_PHASE_90:assert (`PATH.TX_OUTPUT_PHASE_90 === tx_output_phase_90)
      else $display("INCORRECT PARAMETER: TX_OUTPUT_PHASE_90  \
         Expected value is 'b%0b Generated value is 'b%0b",tx_output_phase_90,`PATH.TX_OUTPUT_PHASE_90);

 // XIP_RX_DATA_TYPE:assert (`PATH.RX_DATA_TYPE === rx_data_type)
 //     else $display("INCORRECT PARAMETER: RX_DATA_TYPE  \
 //        Expected value is 'b%0b Generated value is 'b%0b",rx_data_type,`PATH.RX_DATA_TYPE);

 // XIP_EN_OTHER_PCLK:assert (`PATH.EN_OTHER_PCLK === en_other_pclk) 
 //     else $display("INCORRECT PARAMETER: EN_OTHER_PCLK  \
 //        Expected value is 'b%0b Generated value is 'b%0b",en_other_pclk,`PATH.EN_OTHER_PCLK);

 // XIP_EN_OTHER_NCLK:assert (`PATH.EN_OTHER_NCLK === en_other_nclk)
 //     else $display("INCORRECT PARAMETER: EN_OTHER_NCLK  \
 //        Expected value is 'b%0b Generated value is 'b%0b",en_other_nclk,`PATH.EN_OTHER_NCLK);

  XIP_RX_CLK_PHASE_P:assert (`PATH.RX_CLK_PHASE_P === rx_clk_phase_p )
      else $display("INCORRECT PARAMETER: RX_CLK_PHASE_P  \
         Expected value is 'b%0b Generated value is 'b%0b",rx_clk_phase_p,`PATH.RX_CLK_PHASE_P);

  XIP_RX_CLK_PHASE_N:assert (`PATH.RX_CLK_PHASE_N === rx_clk_phase_n)
      else $display("INCORRECT PARAMETER: RX_CLK_PHASE_N  \
         Expected value is 'b%0b Generated value is 'b%0b",rx_clk_phase_n,`PATH.RX_CLK_PHASE_N);
  
  XIP_RXTX_BITSLICE_EN:assert (`PATH.RXTX_BITSLICE_EN === rxtx_bitslice_en )
      else $display("INCORRECT PARAMETER: RXTX_BITSLICE_EN  \
         Expected value is 'b%0b Generated value is 'b%0b",rxtx_bitslice_en,`PATH.RXTX_BITSLICE_EN);

  XIP_TX_GATING:assert (`PATH.TX_GATING === tx_gating) 
      else $display("INCORRECT PARAMETER: TX_GATING  \
         Expected value is 'b%0b Generated value is 'b%0b",tx_gating,`PATH.TX_GATING);

  XIP_RX_GATING:assert (`PATH.RX_GATING === rx_gating) 
      else $display("INCORRECT PARAMETER: RX_GATING  \
         Expected value is 'b%0b Generated value is 'b%0b",rx_gating,`PATH.RX_GATING);

  XIP_EN_DYN_ODLY_MODE:assert (`PATH.EN_DYN_ODLY_MODE === en_dyn_odly_mode )
      else $display("INCORRECT PARAMETER: EN_DYN_ODLY_MODE  \
         Expected value is 'b%0b Generated value is 'b%0b",en_dyn_odly_mode,`PATH.EN_DYN_ODLY_MODE);

  XIP_REFCLK_SRC:assert (`PATH.REFCLK_SRC === refclk_src ) 
      else $display("INCORRECT PARAMETER: REFCLK_SRC \
         Expected value is 'd%0d Generated value is 'd%0d",refclk_src,`PATH.REFCLK_SRC);

  XIP_TBYTE_CTL:assert (`PATH.TBYTE_CTL == "TBYTE_IN") 
      else $display("INCORRECT PARAMETER: TBYTE_CTL \
         Expected value is %0s Generated value is %0s","TBYTE_IN",`PATH.TBYTE_CTL);

  XIP_DELAY_TYPE:assert (`PATH.DELAY_TYPE === "FIXED") 
      else $display("INCORRECT PARAMETER: DELAY_TYPE  \
         Expected value is %0s Generated value is %0s","FIXED",`PATH.DELAY_TYPE);
  
  XIP_DELAY_FORMAT:assert (`PATH.DELAY_FORMAT == "TIME") 
      else $display("INCORRECT PARAMETER: DELAY_FORMAT \
         Expected value is %0s Generated value is %0s","TIME",`PATH.DELAY_FORMAT);

  XIP_UPDATE_MODE:assert (`PATH.UPDATE_MODE == "ASYNC") 
      else $display("INCORRECT PARAMETER: UPDATE_MODE \
         Expected value is %0s Generated value is %0s","ASYNC",`PATH.UPDATE_MODE);

  XIP_FIFO_SYNC_MODE:assert (`PATH.FIFO_SYNC_MODE === fifo_sync_mode) 
      else $display("INCORRECT PARAMETER: FIFO_SYNC_MODE \
         Expected value is 'd%0d Generated value is 'd%0d",fifo_sync_mode,`PATH.FIFO_SYNC_MODE);

  XIP_GCLK_SRC:assert (`PATH.GCLK_SRC === gclk_src) 
      else $display("INCORRECT PARAMETER: GCLK_SRC  \
         Expected value is 'd%0d Generated value is 'd%0d",gclk_src,`PATH.GCLK_SRC);

  XIP_TRI_OUTPUT_PHASE_90:assert (`PATH.TRI_OUTPUT_PHASE_90 === tri_output_phase_90 ) 
      else $display("INCORRECT PARAMETER: TRI_OUTPUT_PHASE_90 \
         Expected value is 'd%0d Generated value is 'd%0d",tri_output_phase_90,`PATH.TRI_OUTPUT_PHASE_90);

  XIP_SERIAL_MODE:assert (`PATH.SERIAL_MODE === serial_mode ) 
      else $display("INCORRECT PARAMETER: SERIAL_MODE \
         Expected value is 'd%0d Generated value is 'd%0d",serial_mode,`PATH.SERIAL_MODE);

  XIP_EN_CLK_TO_EXT_NORTH:assert (`PATH.EN_CLK_TO_EXT_NORTH === en_clk_to_ext_north)
      else $display("INCORRECT PARAMETER: EN_CLK_TO_EXT_NORTH  \
         Expected value is 'b%0b Generated value is 'b%0b",en_clk_to_ext_north,`PATH.EN_CLK_TO_EXT_NORTH);

  XIP_EN_CLK_TO_EXT_SOUTH:assert (`PATH.EN_CLK_TO_EXT_SOUTH === en_clk_to_ext_south)
      else $display("INCORRECT PARAMETER: EN_CLK_TO_EXT_SOUTH  \
         Expected value is 'b%0b Generated value is 'b%0b",en_clk_to_ext_south,`PATH.EN_CLK_TO_EXT_SOUTH);

  XIP_RX_DELAY_VAL:assert (`PATH.RX_DELAY_VAL === rx_delay_val ) 
      else $display("INCORRECT PARAMETER: RX_DELAY_VAL  \
          Expected value is %0p Generated value is %0p",rx_delay_val,`PATH.RX_DELAY_VAL);

  XIP_TX_DELAY_VAL:assert (`PATH.TX_DELAY_VAL === tx_delay_val) 
      else $display("INCORRECT PARAMETER: TX_DELAY_VAL  \
          Expected value is %0p Generated value is %0p",tx_delay_val,`PATH.TX_DELAY_VAL);

  XIP_TRI_DELAY_VAL:assert (`PATH.TRI_DELAY_VAL === tri_delay_val) 
      else $display("INCORRECT PARAMETER: TRI_DELAY_VAL  \
          Expected value is %0p Generated value is %0p",tri_delay_val,`PATH.TRI_DELAY_VAL);

  XIP_READ_IDLE_COUNT:assert (`PATH.READ_IDLE_COUNT === read_idle_count ) 
      else $display("INCORRECT PARAMETER: READ_IDLE_COUNT  \
          Expected value is %0p Generated value is %0p",read_idle_count,`PATH.READ_IDLE_COUNT);

  XIP_ROUNDING_FACTOR:assert (`PATH.ROUNDING_FACTOR === rounding_factor) 
      else $display("INCORRECT PARAMETER: ROUNDING_FACTOR \
          Expected value is %0p Generated value is %0p",rounding_factor,`PATH.ROUNDING_FACTOR);

  XIP_REFCLK_FREQ:assert (`PATH.REFCLK_FREQ == 300.0) 
      else $display("INCORRECT PARAMETER: REFCLK_FREQ  \
          Expected value is 'd%0d Generated value is %0f",300,`PATH.REFCLK_FREQ);

  XIP_DCI_SRC:assert (`PATH.DCI_SRC === dci_src) 
      else $display("INCORRECT PARAMETER: DCI_SRC  \
          Expected value is 'd%0d Generated value is 'd%0d",dci_src,`PATH.DCI_SRC);

  XIP_IDLY_VT_TRACK:assert (`PATH.IDLY_VT_TRACK === idly_vt_track ) 
      else $display("INCORRECT PARAMETER: IDLY_VT_TRACK \
          Expected value is 'd%0d Generated value is 'd%0d",idly_vt_track,`PATH.IDLY_VT_TRACK);

  XIP_ODLY_VT_TRACK:assert (`PATH.ODLY_VT_TRACK === odly_vt_track) 
      else $display("INCORRECT PARAMETER: ODLY_VT_TRACK  \
          Expected value is 'd%0d Generated value is 'd%0d",odly_vt_track,`PATH.ODLY_VT_TRACK);

  XIP_QDLY_VT_TRACK:assert (`PATH.QDLY_VT_TRACK === qdly_vt_track) 
      else $display("INCORRECT PARAMETER: QDLY_VT_TRACK  \
          Expected value is 'd%0d Generated value is 'd%0d",qdly_vt_track,`PATH.QDLY_VT_TRACK);

  XIP_RXGATE_EXTEND:assert (`PATH.RXGATE_EXTEND === rxgate_extend) 
      else $display("INCORRECT PARAMETER: RXGATE_EXTEND  \
          Expected value is 'd%0d Generated value is 'd%0d",rxgate_extend,`PATH.RXGATE_EXTEND); 
  
  A_ui_clk_Check:assert (tfabric1 <= `PATH.tCK*`PATH.nCK_PER_CLK <= tfabric2)  
      else $display("INCORRECT PARAMETER: Fabric clock period is not \
		equal to tCK*nCK_PER_CLK \
		        valid range is from 'd%0d to 'd%0d, Generated value is \
				'd%0d",tfabric1,tfabric2,`PATH.tCK*`PATH.nCK_PER_CLK); 
  
   A_ddr3_cK_Check:assert (tddr3_ck_1  <= `PATH.tCK <= tddr3_ck_2)  
      else $display("INCORRECT PARAMETER: ddr3_ck_p period is not equal to tCK \
	         valid range is from 'd%0d to 'd%0d, Generated value is \
			'd%0d",tddr3_ck_1,tddr3_ck_2,`PATH.tCK); 
      
 end      



task addr_width_cal;
   output integer addr_width;//Expected axi_addr_width
   input integer data_width;
   input integer burst_length;
   input integer num_devices;
   input integer mem_latency;
   if(mem_latency=="2.5")
     if((data_width==18) &&(burst_length==2)) addr_width=21;
     else if ((data_width==36) &&(burst_length==4) && (num_devices==1)) addr_width=19;
     else addr_width=20;
   else
     if((data_width==18) &&(burst_length==2)) addr_width=22;
     else if ((data_width==36) &&(burst_length==4) && (num_devices==1)) addr_width=20;
     else addr_width=21;
endtask

//assign the concatenated values to a <parameter>_local registers, because the concatenated values cannot be used directly in vcs for comparison. So, compare <parameter>_local(expected_value) with parameter(actual) and trigger the assertion on mismatch
integer RX_DELAY_VAL_local [12:0] = '{0,0,0,0,0,0,0,0,0,0,0,0,0}; 
integer TX_DELAY_VAL_local [12:0] = '{0,0,0,0,0,0,0,0,0,0,0,0,0};
integer TRI_DELAY_VAL_local [1:0] = '{0, 0};
integer READ_IDLE_COUNT_local [1:0] = '{31, 31};
integer ROUNDING_FACTOR_local [1:0] = '{16, 16};

initial begin
integer addr_width;
addr_width_cal(addr_width,DATA_WIDTH,BURST_LEN,NUM_DEVICES,MEM_LATENCY);
//1.
A_MEM_TYPE:assert (MEM_TYPE == "QDRIIP")
      else $display("INCORRECT_PARAMETER: MEM_TYPE  \
         Expected MEM_TYPE is %s Generated MEM_TYPE %s ","QDRIIP",MEM_TYPE);
//2.
A_DATA_WIDTH:assert ((DATA_WIDTH == 18)||(DATA_WIDTH == 36))
      else $display("INCORRECT_PARAMETER:  DATA_WIDTH \
         Expected DATA_WIDTH is %s Generated DATA_WIDTH %s ","18 or 36",DATA_WIDTH);
//3.
A_ADDR_WIDTH:assert (ADDR_WIDTH == addr_width)
      else $display("INCORRECT_PARAMETER:  ADDR_WIDTH \
         Expected ADDR_WIDTH is %d Generated ADDR_WIDTH %d ",addr_width,ADDR_WIDTH);
//4.
A_NUM_DEVICES:assert ((NUM_DEVICES == 1)||((NUM_DEVICES == 2) &&(DATA_WIDTH == 36) && (BURST_LEN == 4)))
      else $display("INCORRECT_PARAMETER: NUM_DEVICES  \
         Expected NUM_DEVICES is %s Generated NUM_DEVICES %s ","1 or 2",NUM_DEVICES);
//5.
A_BURST_LEN:assert ((BURST_LEN == 2)||(BURST_LEN == 4))
      else $display("INCORRECT_PARAMETER: BURST_LEN  \
         Expected BURST_LEN is %s Generated BURST_LEN %s ","2 or 4",BURST_LEN);
//6.
//A_UI_EXTRA_CLOCKS:assert (UI_EXTRA_CLOCKS == "TRUE")
//      else $display("INCORRECT_PARAMETER: UI_EXTRA_CLOCKS  \
//         Expected UI_EXTRA_CLOCKS is %s Generated UI_EXTRA_CLOCKS %s ","TRUE",UI_EXTRA_CLOCKS);
//7.
A_DBYTES:assert (DBYTES == DATA_WIDTH/9)
      else $display("INCORRECT_PARAMETER: DBYTES  \
         Expected DBYTES is %s Generated DBYTES %s ",DATA_WIDTH/9,DBYTES);
//8.
A_SYSCLK_TYPE:assert ((`PATH.SYSCLK_TYPE == "DIFFERENTIAL") || (`PATH.SYSCLK_TYPE == "NO_BUFFER"))
      else $display("INCORRECT_PARAMETER: SYSCLK_TYPE  \
         Expected SYSCLK_TYPE is %s Generated SYSCLK_TYPE %s ","DIFFERENTIAL or NO_BUFFER",SYSCLK_TYPE);
//9.
//if(SYSCLK_TYPE == "DIFFERENTIAL")
//A_DIFF_TERM_SYSCLK:assert ((DIFF_TERM_SYSCLK == "TRUE"))
//      else $display("INCORRECT_PARAMETER: DIFF_TERM_SYSCLK  \
//         Expected DIFF_TERM_SYSCLK is %s Generated DIFF_TERM_SYSCLK %s ","TRUE",DIFF_TERM_SYSCLK);
//10.from phy top
/*** commenting the below assertion as per CR#977147
A_PHY_C_FAMILY:assert ((C_FAMILY == "kintexu")||(C_FAMILY == "virtexu") || (C_FAMILY == "kintexuplus") || (C_FAMILY == "virtexuplus") ||  (C_FAMILY == "zynquplus"))
      else $display("INCORRECT_PARAMETER: C_FAMILY  \
         Expected C_FAMILY is %s Generated C_FAMILY %s ","kintexu or virtexu or kintexplus or virtexplus or zynquplus",C_FAMILY);
*****/      
//11. 
A_PHY_tCK:assert ((`PATH.tCK >= 1580)&& (`PATH.tCK <= 3333))
      else $display("INCORRECT_PARAMETER: tCK  \
         Expected tCK is %s Generated tCK %s ","1580 to 3333",`PATH.tCK);
//12.
A_PHY_nCK_PER_CLK:assert (`PATH.nCK_PER_CLK == 2)
      else $display("INCORRECT_PARAMETER: nCK_PER_CLK  \
         Expected nCK_PER_CLK is %s Generated nCK_PER_CLK %s ",2,`PATH.nCK_PER_CLK);
//13.
A_MEM_LATENCY:assert ((MEM_LATENCY == "2.5")||(MEM_LATENCY == "2")) 
      else $display("INCORRECT_PARAMETER:  MEM_LATENCY \
         Expected MEM_LATENCY is %s Generated MEM_LATENCY %s ","2 or 2.5",MEM_LATENCY);
//14.
A_PHY_CLK_2TO1:assert ((CLK_2TO1 == "TRUE")||(CLK_2TO1 == "FALSE"))
      else $display("INCORRECT_PARAMETER: CLK_2TO1  \
         Expected CLK_2TO1 is %s Generated CLK_2TO1 %s ","TRUE or FALSE",CLK_2TO1);
//15.
A_PHY_PLL_WIDTH:assert (`PATH.PLL_WIDTH <=3)
      else $display("INCORRECT_PARAMETER: PLL_WIDTH  \
         Expected PLL_WIDTH is %s Generated PLL_WIDTH %s ","<=3",`PATH.PLL_WIDTH);
//16.
A_TCQ:assert (TCQ == 100)
      else $display("INCORRECT_PARAMETER: TCQ  \
         Expected TCQ is %d Generated TCQ %d ",100,TCQ);

//17.
A_PHY_NO_OF_DEVICES:assert (`PATH.NO_OF_DEVICES == NUM_DEVICES)
      else $display("INCORRECT_PARAMETER: NO_OF_DEVICES  \
         Expected NO_OF_DEVICES is %s Generated NO_OF_DEVICES %s ",NUM_DEVICES,`PATH.NO_OF_DEVICES);
//18.
A_PHY_ABITS:assert (`PATH.ABITS == ADDR_WIDTH)
      else $display("INCORRECT_PARAMETER: ABITS  \
         Expected ABITS is %s Generated ABITS %s ",ADDR_WIDTH,`PATH.ABITS);
//19.
A_PHY_DBITS:assert (`PATH.DBITS == DATA_WIDTH)
      else $display("INCORRECT_PARAMETER: DBITS  \
         Expected DBITS is %s Generated DBITS %s ",DATA_WIDTH,`PATH.DBITS);
//20.
A_PHY_BYTES:assert (BYTES <=12)
      else $display("INCORRECT_PARAMETER: BYTES  \
         Expected BYTES is %s Generated BYTES %s ","<=12",BYTES);
//21.
A_PHY_DBYTES:assert (`PATH.DBYTES == DATA_WIDTH/9)
      else $display("INCORRECT_PARAMETER: DBYTES  \
         Expected DBYTES is %s Generated DBYTES %s ",DATA_WIDTH/9,`PATH.DBYTES);
//22.
A_PHY_BURST_LEN:assert (`PATH.BURST_LEN == BURST_LEN)
      else $display("INCORRECT_PARAMETER: BURST_LEN  \
         Expected BURST_LEN is %s Generated BURST_LEN %s ","2 or 4",`PATH.BURST_LEN);
//23.
A_PHY_CLK_WIDTH:assert (`PATH.CLK_WIDTH == `PATH.NO_OF_DEVICES)
      else $display("INCORRECT_PARAMETER: CLK_WIDTH  \
         Expected CLK_WIDTH is %s Generated CLK_WIDTH %s ",`PATH.NO_OF_DEVICES,`PATH.CLK_WIDTH);
//24.
A_PHY_TBYTE_CTL:assert (`PATH.TBYTE_CTL == "TBYTE_IN")
      else $display("INCORRECT_PARAMETER: TBYTE_CTL  \
         Expected TBYTE_CTL is %s Generated TBYTE_CTL %s ","TBYTE_IN",`PATH.TBYTE_CTL);
//25.
A_PHY_DELAY_TYPE:assert (`PATH.DELAY_TYPE == "FIXED")
      else $display("INCORRECT_PARAMETER: DELAY_TYPE  \
         Expected DELAY_TYPE is %s Generated DELAY_TYPE %s ","FIXED",`PATH.DELAY_TYPE);
//26.
A_PHY_DELAY_FORMAT:assert (`PATH.DELAY_FORMAT == "TIME")
      else $display("INCORRECT_PARAMETER: DELAY_FORMAT  \
         Expected DELAY_FORMAT is %s Generated DELAY_FORMAT %s ","TIME",`PATH.DELAY_FORMAT);
//27.
A_PHY_UPDATE_MODE:assert (`PATH.UPDATE_MODE == "ASYNC")
      else $display("INCORRECT_PARAMETER: UPDATE_MODE  \
         Expected UPDATE_MODE is %s Generated UPDATE_MODE %s ","ASYNC",`PATH.UPDATE_MODE);
//28.
A_PHY_PLLCLK_SRC:assert (`PATH.PLLCLK_SRC == 0)
      else $display("INCORRECT_PARAMETER: PLLCLK_SRC  \
         Expected PLLCLK_SRC is %s Generated PLLCLK_SRC %s ","0",`PATH.PLLCLK_SRC);
//29.
A_PHY_FIFO_SYNC_MODE:assert (`PATH.FIFO_SYNC_MODE == 0)
      else $display("INCORRECT_PARAMETER: FIFO_SYNC_MODE  \
         Expected FIFO_SYNC_MODE is %s Generated FIFO_SYNC_MODE %s ","0",`PATH.FIFO_SYNC_MODE);
//30.
A_PHY_DIV_MODE:assert (`PATH.DIV_MODE == 2'b11)
      else $display("INCORRECT_PARAMETER: DIV_MODE  \
         Expected DIV_MODE is %s Generated DIV_MODE %s ","2'b11",`PATH.DIV_MODE);
//31.
A_PHY_REFCLK_SRC:assert (`PATH.REFCLK_SRC == 2'b00)
      else $display("INCORRECT_PARAMETER: REFCLK_SRC  \
         Expected REFCLK_SRC is %s Generated REFCLK_SRC %s ","2'b00",`PATH.REFCLK_SRC);
//32.
A_PHY_CTRL_CLK:assert (`PATH.CTRL_CLK == 2'b11)
      else $display("INCORRECT_PARAMETER: CTRL_CLK  \
         Expected CTRL_CLK is %s Generated CTRL_CLK %s ","2'b11",`PATH.CTRL_CLK);
//33.
A_PHY_RX_DELAY_VAL:assert (`PATH.RX_DELAY_VAL == RX_DELAY_VAL_local)
      else $display("INCORRECT_PARAMETER: RX_DELAY_VAL  \
         Expected RX_DELAY_VAL is %s Generated RX_DELAY_VAL %p ","'{0,0,0,0,0,0,0,0,0,0,0,0,0}",`PATH.RX_DELAY_VAL);
//34.
A_PHY_TX_DELAY_VAL:assert (`PATH.TX_DELAY_VAL == TX_DELAY_VAL_local)
      else $display("INCORRECT_PARAMETER: TX_DELAY_VAL  \
         Expected TX_DELAY_VAL is %s Generated TX_DELAY_VAL %p ","'{0,0,0,0,0,0,0,0,0,0,0,0,0}",`PATH.TX_DELAY_VAL);
//35.
A_PHY_TRI_DELAY_VAL:assert (`PATH.TRI_DELAY_VAL == TRI_DELAY_VAL_local)
      else $display("INCORRECT_PARAMETER: TRI_DELAY_VAL  \
         Expected TRI_DELAY_VAL is %s Generated TRI_DELAY_VAL %p ","'{0, 0}",`PATH.TRI_DELAY_VAL);
//36.
A_PHY_READ_IDLE_COUNT:assert (`PATH.READ_IDLE_COUNT == READ_IDLE_COUNT_local)
      else $display("INCORRECT_PARAMETER: READ_IDLE_COUNT  \
         Expected READ_IDLE_COUNT is %s Generated READ_IDLE_COUNT %p ","'{31, 31}",`PATH.READ_IDLE_COUNT);
//37.
A_PHY_ROUNDING_FACTOR:assert (`PATH.ROUNDING_FACTOR == ROUNDING_FACTOR_local)
      else $display("INCORRECT_PARAMETER: ROUNDING_FACTOR  \
         Expected ROUNDING_FACTOR is %s Generated ROUNDING_FACTOR %p ","'{16, 16}",`PATH.ROUNDING_FACTOR);
//38.
A_PHY_DATA_WIDTH:assert (`PATH.DATA_WIDTH == 4)
      else $display("INCORRECT_PARAMETER: DATA_WIDTH  \
         Expected DATA_WIDTH is %s Generated DATA_WIDTH %s ","4",`PATH.DATA_WIDTH);
//39.
A_PHY_REFCLK_FREQ:assert (`PATH.REFCLK_FREQ == 300.0)
      else $display("INCORRECT_PARAMETER: REFCLK_FREQ  \
         Expected REFCLK_FREQ is %0d Generated REFCLK_FREQ %0d ","300",`PATH.REFCLK_FREQ);
//40.
A_PHY_DCI_SRC:assert (`PATH.DCI_SRC == {BYTES*13{1'b0}})
      else $display("INCORRECT_PARAMETER: DCI_SRC  \
         Expected DCI_SRC is %s Generated DCI_SRC %s ","0",`PATH.DCI_SRC);
//41.
A_PHY_RXGATE_EXTEND:assert (`PATH.RXGATE_EXTEND == {2*BYTES{1'b0}})
      else $display("INCORRECT_PARAMETER: RXGATE_EXTEND  \
         Expected RXGATE_EXTEND is %s Generated RXGATE_EXTEND %s ","{2*BYTES{1'b0}}",`PATH.RXGATE_EXTEND);
//42.
A_PHY_BANK_TYPE:assert ((`PATH.BANK_TYPE == "HP_IO")||(`PATH.BANK_TYPE == "HR_IO") ||(`PATH.BANK_TYPE == "DEFAULT"))
      else $display("INCORRECT_PARAMETER: BANK_TYPE  \
         Expected BANK_TYPE is %s Generated BANK_TYPE %s ","HP_IO or HR_IO",`PATH.BANK_TYPE);

$display("QDR2P assertions executed in simulation");

end


`endif



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
//  /   /         Filename              : qdriip_v1_4_19_debug_microblaze.v
// /___/   /\     Date Last Modified    : 2016/11/30
// \   \  /  \    Date Created          : Thu Nov 24 2013
//  \___\/\___\
//
//Device            : Ultrascale 
//Design            : QDRII+ SRAM
//Purpose           :
//                   Module to analyze the debug data that microblaze writes 
//                   into debug memory
//Reference         :
//Revision History  :
//*****************************************************************************

`timescale 1ps / 1ps

module qdriip_v1_4_19_debug_microblaze #
  (
   parameter TCQ = 100
  )
  (
   input        clk,
   input        rst,
   input        IO_Addr_Strobe,
   input [31:0] IO_Address,
   input        IO_Write_Strobe,
   input [31:0] IO_Write_Data,
   input [37:0] cal_r0_status,
   input [37:0] cal_r1_status,
   input [37:0] cal_r2_status,
   input [37:0] cal_r3_status,
   input        cal_error,
   input        cal_warning
   );
   
   localparam CAL_DEBUG   = 32'hC200_0400; //0x00800100
   localparam DEBUG_RAM   = 32'hC240_0000; //0x00900000
   localparam CAL_STATUS0 = 32'hC200_1004; //0x00800401
   localparam CAL_STATUS1 = 32'hC200_1008; //0x00800402
   localparam CAL_STATUS2 = 32'hC200_1010; //0x00800404
   localparam CAL_STATUS3 = 32'hC200_1020; //0x00800408
   localparam CAL_STATUS4 = 32'hC200_1040; //0x00800410
   localparam CAL_STATUS5 = 32'hC200_1080; //0x00800420
   localparam CAL_STATUS6 = 32'hC200_1100; //0x00800440
   localparam CAL_STATUS7 = 32'hC200_1200; //0x00800480
   localparam CAL_DONE    = 32'hC200_0800; //0x00800200
   
   localparam DBG_CONFIG         = 0;
   localparam DBG_INIT           = 1;
   localparam DBG_DQS_GATE       = 2;
   localparam DBG_WRLVL          = 3;
   localparam DBG_RDLVL          = 4;
   localparam DBG_WRITE_DQS      = 5;
   localparam DBG_WRITE_CAL      = 6;
   localparam DBG_READ_VREF      = 7;
   localparam DBG_WRITE_VREF     = 8;
   localparam DBG_WRITE_READ     = 9;
   localparam DBG_DQS_TRACK      = 10;
   localparam DBG_SANITY_CHECK   = 11;
   
   localparam INIT_CAL_RDY       = 0;
   localparam INIT_PHY_RDY       = 1;
   localparam INIT_PWR_UP_DONE   = 2;
   
   localparam DQS_GATE_FINE      = 0;
   localparam DQS_GATE_COARSE    = 1;
   localparam DQS_GATE_OFFSET    = 2;
   localparam DQS_GATE_GT_STAT   = 3;
   localparam DQS_GATE_RD_LAT    = 4;
   localparam DQS_GATE_RD_LAT_DLY= 5;
   localparam DQS_GATE_PAT_MATCH = 6;
   localparam DQS_GATE_PATTERN   = 7;
   localparam DQS_GATE_ERR_CHK   = 8;
   localparam DQS_GATE_FINE_L    = 9;
   localparam DQS_GATE_FINE_R    = 10;
   
   localparam WRLVL_COARSE        = 0;
   localparam WRLVL_SAMPLE        = 1;
   localparam WRLVL_ODELAY_OFFSET = 2;
   localparam WRLVL_COARSE_LEFT   = 3;
   localparam WRLVL_COARSE_RIGHT  = 4;
   localparam WRLVL_FINE          = 5;
   localparam WRLVL_FINE_LEFT     = 6;
   localparam WRLVL_FINE_RIGHT    = 7;
   localparam WRLVL_FINE_CENTER   = 8;
   localparam WRLVL_STEP_SIZE     = 9;
   localparam WRLVL_WARN          = 10;
   localparam WRLVL_ERR           = 11;

   localparam WL_ERR_STABLE_ZERO      = 0;
   localparam WL_ERR_STABLE_ONE       = 1;
   localparam WL_ERR_NO_LEFT_FINE     = 2;

   localparam WL_WARN_OFFSET_ZERO       = 0;
   localparam WL_WARN_STEP_SIZE_ZERO    = 1;
   localparam WL_WARN_NO_RIGHT_FINE     = 2;
   localparam WL_WARN_ODELAY_SATURATED  = 3;

   localparam RDLVL_BIT_VECTOR      = 0;
   localparam RDLVL_QTR             = 1;
   localparam RDLVL_IDELAY          = 2;
   localparam RDLVL_SAMPLES         = 3;
   localparam RDLVL_ERR_CHK         = 4;
   localparam RDLVL_LEFT            = 5;
   localparam RDLVL_RIGHT           = 6;
   localparam RDLVL_CENTER          = 7;
   localparam RDLVL_DESKEW_EDGE_ERR = 8;
   localparam RDLVL_CENTER_EDGE_ERR = 9;
   localparam RDLVL_NO_VALID_DATA   = 10;
   
   localparam WRCAL_LATENCY         = 0;
   localparam WRCAL_COARSE          = 1;
   localparam WRCAL_ERR             = 2;
   
   localparam TRACKING_SAMPLES      = 0;
   localparam TRACKING_GT_STATUS    = 1;
   localparam TRACKING_FINE         = 2;
   localparam TRACKING_COARSE       = 3;
   localparam TRACKING_CNT          = 4;

  //Simple Module to snoop the bus and display when it sees some kind of debug message
  reg         dbg_message_seen;
  reg         dbg_message_write;
  reg [3:0]   status_message_seen;
  reg [37:0]  status_reg;
  
  wire [3:0]  task_id;
  wire [3:0]  code;
  wire [11:0] payload;
  wire [1:0]  rank;
  wire [5:0]  nibble;
  wire [3:0]  bit_num;
  
  
  wire [31:0] IO_Address_shift;
  // Read the debug file and store in memory for display 
  // Hardcoded path till resolved by verification team
  reg  [255:0]  mem[0:63];
  int mem_ptr;
  int fd;

`ifdef SIM
  initial
  begin
    fd = $fopen({`SW_MEMFILE,"/debug.mem"}, "r");
    for (mem_ptr = 0; mem_ptr < 227; mem_ptr = mem_ptr + 1)  // max size is 64*32/9 = 227 for a 64 deep 32 bit memory
    begin
      $fscanf(fd, "%s", mem[mem_ptr]);
    end
  end // initial begin
`endif

  always @ (posedge clk) begin
    if (rst)
	  dbg_message_write  <= #TCQ 1'b0;
	else if (IO_Addr_Strobe && IO_Address[31:16] == DEBUG_RAM[31:16] && IO_Write_Strobe)
	  dbg_message_write  <= #TCQ 1'b1;
	else
	  dbg_message_write  <= #TCQ 1'b0;
  end

  always @ (posedge clk) begin
    if (rst)
	  dbg_message_seen <= #TCQ 1'b0;
	else if (IO_Addr_Strobe && IO_Address == CAL_DEBUG)
	  dbg_message_seen <= #TCQ 1'b1;
	else
	  dbg_message_seen <= #TCQ 1'b0;
  end
  
  
  //Status Messages
  always @ (posedge clk) begin
    if (rst)
	  status_message_seen <= #TCQ 'b0;
	else if (IO_Addr_Strobe)
	  if (IO_Address == CAL_STATUS0 || IO_Address == CAL_STATUS1)
	    status_message_seen <= #TCQ 4'b0001;
	  else if (IO_Address == CAL_STATUS2 || IO_Address == CAL_STATUS3)
	    status_message_seen <= #TCQ 4'b0010;
	  else if (IO_Address == CAL_STATUS4 || IO_Address == CAL_STATUS5)
	    status_message_seen <= #TCQ 4'b0100;
	  else if (IO_Address == CAL_STATUS6 || IO_Address == CAL_STATUS7)
	    status_message_seen <= #TCQ 4'b1000;
	  else
	    status_message_seen <= #TCQ 'b0;
	else
	  status_message_seen <= #TCQ status_message_seen;
  end
  
  //One clock later since we have to let values propogate (update if more
  //pipeline required
  always @ (posedge clk) begin
    if (rst)
	  status_reg <= #TCQ 'b0;
	else if (status_message_seen[0])
	    status_reg <= #TCQ cal_r0_status;
	else if (status_message_seen[1])
	    status_reg <= #TCQ cal_r1_status;
	else if (status_message_seen[2])
	    status_reg <= #TCQ cal_r2_status;
	else if (status_message_seen[3])
	    status_reg <= #TCQ cal_r3_status;
	else
	  status_reg <= #TCQ status_reg;
  end
 
  assign IO_Address_shift = IO_Address >> 2;
  
  assign task_id = IO_Write_Data[31:28];
  assign code    = IO_Write_Data[27:24];
  assign payload = IO_Write_Data[23:12];
  assign rank    = IO_Write_Data[11:10];
  assign nibble  = IO_Write_Data[9:4];
  assign bit_num = IO_Write_Data[3:0];
  wire [7:0] dbg_mem_addr   =  IO_Address_shift[13:6];
  wire [5:0] dbg_mem_off    =  IO_Address_shift[5:0];
  wire [5:0] dbg_mem_remain =  (dbg_mem_off > 32) ? (dbg_mem_off -  32) : 0;
  reg  [8:0] partial_dbg_data;
  reg  [8:0] dbg_data;
  //synthesis translate_off
  //New debug function.
  always @ (posedge clk)
  begin
    if (dbg_message_write)
    begin
      // less than 9-bits of data, store the first half of data
      if(dbg_mem_remain > 0)
      begin	
        partial_dbg_data = IO_Write_Data << (dbg_mem_remain);
      end
      else
      begin
        // combine rest of the data bits with the partial stored data
        if(partial_dbg_data > 0)
        begin
          dbg_data = ((partial_dbg_data | (IO_Write_Data >> (32-dbg_mem_off))) & 9'h 1FF);
          partial_dbg_data = 0;
        end
        else 
        // complete data 
        begin
          dbg_data = (IO_Write_Data >> (32-dbg_mem_off) & 9'h 1FF);
          partial_dbg_data = 0;
        end
        $display ("AADBG_uB:----- %s = %d -----",mem[(((dbg_mem_addr * 32) + (dbg_mem_off-9))/9)], dbg_data);
      end
    end
  end // end new debug function

  always @ (posedge clk) begin
    if (dbg_message_seen) begin
	  case (task_id)
	    DBG_CONFIG : begin
		  $display ("DBG_uB: --------------- Task: DBG_CONFIG -------------------");
		  $display ("DBG_uB: code = %d, payload = %d", code, payload);
		end
		DBG_INIT : begin
		  $display ("DBG_uB: --------------- Task: DBG_INIT ---------------------");
		  case (code)
	        INIT_CAL_RDY :
		      $display ("DBG_uB: Calibration Ready");
		    INIT_PHY_RDY :
		      $display ("DBG_uB: All nibbles of XIPhy Ready");
		    INIT_PWR_UP_DONE :
		      $display ("DBG_uB: Power Up values Saved");
	        default:
		      $display ("DBG_uB: code = %d, payload = %d", code, payload);
          endcase
		end
		DBG_DQS_GATE : begin
		  $display ("DBG_uB: --------------- Task: DBG_DQS_GATE -----------------");
		  case (code)
	        DQS_GATE_FINE :
		      $display ("DBG_uB: fine = %d", payload);
		    DQS_GATE_COARSE :
		      $display ("DBG_uB:             coarse = %d", payload);
		    DQS_GATE_OFFSET :
		      $display ("DBG_uB: fine offset = %d", payload);
		    DQS_GATE_GT_STAT :
		      $display ("DBG_uB:                                GT_STATUS = %d", payload);
		    DQS_GATE_RD_LAT :
		      $display ("DBG_uB: Read latency = %d", payload);
			DQS_GATE_RD_LAT_DLY :
		      $display ("DBG_uB: Read latency Delay = %d", payload);
		    DQS_GATE_PAT_MATCH :
		      $display ("DBG_uB: Pattern Match = %d", payload);
			DQS_GATE_PATTERN :
		      $display ("DBG_uB: Pattern = %b", payload);
			DQS_GATE_ERR_CHK :
			  $display ("DBG_uB: Err chk reg = %b", payload);
			DQS_GATE_FINE_L :
			  $display ("DBG_uB: fine edge (left) = %d", payload);
			DQS_GATE_FINE_R :
			  $display ("DBG_uB: fine edge (right) = %d", payload);
	        default:
		      $display ("DBG_uB: code = %d, payload = %d", code, payload);
          endcase
		end
		DBG_WRLVL : begin
	//	  $display ("DBG_uB: --------------- Task: DBG_WRLVL --------------------");
		  case (code)
	      WRLVL_COARSE :
		      $display ("DBG_uB: WRLVL Coarse = %d", payload);
		    WRLVL_SAMPLE :
		      $display ("DBG_uB: WRLVL Sample = %h", payload);
        WRLVL_ODELAY_OFFSET :
          $display ("DBG_uB: WRLVL Coarse search ODELAY offset = %d", payload);
		    WRLVL_COARSE_LEFT :
          $display ("DBG_uB: WRLVL Coarse left (stable zero) value = %d", payload);
		    WRLVL_COARSE_RIGHT :
          $display ("DBG_uB: WRLVL Coarse right (stable one) value = %d", payload);
	      WRLVL_FINE :
		      $display ("DBG_uB: WRLVL Fine = %d", payload);
		    WRLVL_FINE_LEFT :
          $display ("DBG_uB: WRLVL Fine left (stable zero / noise edge) = %d", payload);
        WRLVL_FINE_RIGHT :
          $display ("DBG_uB: WRLVL Fine right (noise / stable one edge) = %d", payload);
		    WRLVL_FINE_CENTER :
          $display ("DBG_uB: WRLVL Fine noise center = %d", payload);
		    WRLVL_STEP_SIZE :
          $display ("DBG_uB: WRLVL Fine search step size = %d", payload);
        WRLVL_WARN:
          case(payload)
            WL_WARN_OFFSET_ZERO:      $display("DBG_uB: WRLVL Warn: ODELAY offset is zero");
            WL_WARN_STEP_SIZE_ZERO:   $display("DBG_uB: WRLVL Warn: Fine search step size is zero. Setting to 1 (minimum)");
            WL_WARN_NO_RIGHT_FINE:    $display("DBG_uB: WRLVL Warn: Couldn't find right side of noise region. Centering in region scanned");
            WL_WARN_ODELAY_SATURATED: $display("DBG_uB: WRLVL Warn: ODELAY taps saturated. Cannot fully preserve deskew component of DQ/DM bit");
            default:                  $display("DBG_uB: WRLVL Warn: code = $d, payload = %d", code, payload);
          endcase
		    WRLVL_ERR :
          case(payload)
            WL_ERR_STABLE_ZERO:   $display("DBG_uB: WRLVL Err: Couldn't find a stable zero during coarse search");
            WL_ERR_STABLE_ONE:    $display("DBG_uB: WRLVL Err: Couldn't find a stable one during coarse search");
            WL_ERR_NO_LEFT_FINE:  $display("DBG_uB: WRLVL Err: Couldn't find left edge of noise region");            
            default:              $display("DBG_uB: WRLVL Err: code = $d, payload = %d", code, payload);
          endcase
        default:
		      $display ("DBG_uB: code = %d, payload = %d", code, payload);
          endcase
		end
		DBG_RDLVL : begin
		  $display ("DBG_uB: --------------- Task: DBG_RDLVL --------------------");
		  case (code)
	        RDLVL_BIT_VECTOR :
			  $display ("DBG_uB: Bits in nibble for byte = %b", payload);
			RDLVL_QTR :
		      $display ("DBG_uB: QTR DELAY = %d", payload);
		    RDLVL_IDELAY :
		      $display ("DBG_uB:             IDELAY = %d", payload);
		    RDLVL_SAMPLES :
		      $display ("DBG_uB: Samples left before err = %d", payload);
		    RDLVL_ERR_CHK :
		      $display ("DBG_uB:                           RAW err Reg = %b", payload);
			RDLVL_LEFT : begin
			  if (payload[9]==0)
			    $display ("DBG_uB: QTR LEFT Edge (P)= %d", payload[8:0]);
			  else
			    $display ("DBG_uB: QTR LEFT Edge (N)= %d", payload[8:0]);
			end
			RDLVL_RIGHT : begin
			  if (payload[9]==0)
			    $display ("DBG_uB: QTR RIGHT Edge (P)= %d", payload[8:0]);
			  else
			    $display ("DBG_uB: QTR RIGHT Edge (N)= %d", payload[8:0]);
			end
			RDLVL_CENTER : begin
			  if (payload[9]==0)
			    $display ("DBG_uB: QTR CENTER setting (P)= %d", payload[8:0]);
			  else
			    $display ("DBG_uB: QTR CENTER setting (N)= %d", payload[8:0]);
			end
		    RDLVL_DESKEW_EDGE_ERR :
		      $display ("DBG_uB: Deskew Edge not found = %d", payload);
			RDLVL_CENTER_EDGE_ERR : begin
			  if (payload[9]==0)
		        $display ("DBG_uB: Centering Edge not found (P)= %d", payload[8:0]);
			  else
			    $display ("DBG_uB: Centering Edge not found (N)= %d", payload[8:0]);
			end
		    RDLVL_NO_VALID_DATA :
		      $display ("DBG_uB: No valid data = %d", payload);
	        default:
		      $display ("DBG_uB: code = %d, payload = %d", code, payload);
          endcase
		end
		DBG_WRITE_DQS : begin
		  $display ("DBG_uB: --------------- Task: DBG_DQS_CENTER ----------------");
		  $display ("DBG_uB: --------------- Stage: %H Value: %H ----------------", IO_Write_Data[27:20], IO_Write_Data[19:0]);
		end
		DBG_WRITE_CAL : begin
		  $display ("DBG_uB: --------------- Task: DBG_WRITE_CAL ----------------");
		  case (code)
	        WRCAL_LATENCY :
			  $display ("DBG_uB: Write Cal Latency = %d", payload);
			WRCAL_COARSE :
		      $display ("DBG_uB: Write Cal Coarse Setting = %d", payload);
		    WRCAL_ERR :
		      $display ("DBG_uB: Write Cal ERR, max latency attempted = %d", payload);
	        default:
		      $display ("DBG_uB: code = %d, payload = %d", code, payload);
          endcase
		end
		DBG_READ_VREF : begin
		  $display ("DBG_uB: --------------- Task: DBG_READ_VREF ----------------");
		  $display ("DBG_uB: code = %d, payload = %d", code, payload);
		end
		DBG_WRITE_VREF : begin
		  $display ("DBG_uB: --------------- Task: DBG_WRITE_VREF -----------------");
	        end
		DBG_WRITE_READ : begin
		  $display ("DBG_uB: --------------- Task: DBG_WRITE_READ = %H ----------------",IO_Write_Data);
		end
		DBG_DQS_TRACK : begin
		  $display ("DBG_uB: --------------- Task: DBG_DQS_TRACKING ----------------");
		  case (code)
	        TRACKING_SAMPLES : begin
			  $display ("DBG_uB: Samples Per Check = %d", payload);
			end
			TRACKING_GT_STATUS : begin
		      $display ("DBG_uB: GT_STATUS count = %d", payload);
			end
		    TRACKING_FINE : begin
		      $display ("DBG_uB: fine = %d", payload);
			end
			TRACKING_COARSE : begin
		      $display ("DBG_uB:             coarse = %d", payload);
			end
			TRACKING_CNT : begin
		      $display ("DBG_uB: Counter = %d", payload);
			end
	        default:
		      $display ("DBG_uB: code = %d, payload = %d", code, payload);
          endcase
		end
		DBG_SANITY_CHECK : begin
		  $display ("DBG_uB: --------------- Task: DBG_SANITY_CHECK ----------------");
		  $display ("DBG_uB: Sanity Check Failure (nibble=%d)", payload);
		end
		default: begin
		  $display ("DBG_uB: --------------- Task: %d -------------------", task_id);
		  $display ("DBG_uB: code = %d, payload = %d", code, payload);
		end
	  endcase
	
	  // $display ("DBG_uB: %d  %d  %d -- %t", rank, nibble, bit_num, $time);
	end
  end
  
  always @(posedge status_reg[0])
    if (!rst) begin
	  $display ("DBG_uB: ============== Status: %h ============", status_reg);
      $display ("DBG_uB: All nibbles ready %t", $time);
	  $display ("DBG_uB: ============================================");
	end
  
  always @(posedge status_reg[2])
    if (!rst) begin
	  $display ("DBG_uB: ============== Status: %h ============", status_reg);
      $display ("DBG_uB: Initialization Done %t", $time);
	  $display ("DBG_uB: ============================================");
	end
	  
  always @(posedge status_reg[3])
    if (!rst) begin
	  $display ("DBG_uB: ============== Status: %h ============", status_reg);
      $display ("DBG_uB: DQS Gate/Bias Start %t", $time);
	  $display ("DBG_uB: ============================================");
	end
	  
  always @(posedge status_reg[4])
    if (!rst) begin
	  $display ("DBG_uB: ============== Status: %h ============", status_reg);
      $display ("DBG_uB: DQS Gate/Bias Done %t", $time);
	  $display ("DBG_uB: ============================================");
	end
	  
  always @(posedge status_reg[5])
    if (!rst) begin
	  $display ("DBG_uB: ============== Status: %h ============", status_reg);
      $display ("DBG_uB: DQS Gate/Bias Check Start %t", $time);
	  $display ("DBG_uB: ============================================");
	end
	  
  always @(posedge status_reg[6])
    if (!rst) begin
	  $display ("DBG_uB: ============== Status: %h ============", status_reg);
      $display ("DBG_uB: DQS Gate/Bias Check Done %t", $time);
	  $display ("DBG_uB: ============================================");
	end
	  
  always @(posedge status_reg[7])
    if (!rst) begin
	  $display ("DBG_uB: ============== Status: %h ============", status_reg);
      $display ("DBG_uB: WRLVL Start %t", $time);
	  $display ("DBG_uB: ============================================");
	end
  
  always @(posedge status_reg[8])
    if (!rst) begin
	  $display ("DBG_uB: ============== Status: %h ============", status_reg);
      $display ("DBG_uB: WRLVL Done %t", $time);
	  $display ("DBG_uB: ============================================");
	end
  
  always @(posedge status_reg[9])
    if (!rst) begin
	  $display ("DBG_uB: ============== Status: %h ============", status_reg);
      $display ("DBG_uB: RDLVL Start %t", $time);
	  $display ("DBG_uB: ============================================");
	end
	  
  always @(posedge status_reg[10])
    if (!rst) begin
	  $display ("DBG_uB: ============== Status: %h ============", status_reg);
      $display ("DBG_uB: RDLVL Done %t", $time);
	  $display ("DBG_uB: ============================================");
	end
	  
  always @(posedge status_reg[11])
    if (!rst) begin
	  $display ("DBG_uB: ============== Status: %h ============", status_reg);
      $display ("DBG_uB: RDLVL Check Done %t", $time);
	  $display ("DBG_uB: ============================================");
	end
  
  always @(posedge status_reg[12])
    if (!rst) begin
	  $display ("DBG_uB: ============== Status: %h ============", status_reg);
      $display ("DBG_uB: DQS Centering Start %t", $time);
	  $display ("DBG_uB: ============================================");
	end
  
  always @(posedge status_reg[13])
    if (!rst) begin
	  $display ("DBG_uB: ============== Status: %h ============", status_reg);
      $display ("DBG_uB: DQS Centering Done %t", $time);
	  $display ("DBG_uB: ============================================");
	end
  
  always @(posedge status_reg[14])
    if (!rst) begin
	  $display ("DBG_uB: ============== Status: %h ============", status_reg);
      $display ("DBG_uB: Write Calibration Start %t", $time);
	  $display ("DBG_uB: ============================================");
	end
	  
  always @(posedge status_reg[15])
    if (!rst) begin
	  $display ("DBG_uB: ============== Status: %h ============", status_reg);
      $display ("DBG_uB: Write Calibration Done %t", $time);	
	  $display ("DBG_uB: ============================================");
	end  
  
  always @(posedge status_reg[16])
    if (!rst) begin
	  $display ("DBG_uB: ============== Status: %h ============", status_reg);
      $display ("DBG_uB: Write/Read Sanity Check Start %t", $time);
	  $display ("DBG_uB: ============================================");
	end	 
  
  always @(posedge status_reg[17])
    if (!rst) begin
	  $display ("DBG_uB: ============== Status: %h ============", status_reg);
      $display ("DBG_uB: Write/Read Sanity Check Done %t", $time);
	  $display ("DBG_uB: ============================================");
	end
	  
  always @(posedge status_reg[21])
    if (!rst) begin
	  $display ("DBG_uB: ============== Status: %h ============", status_reg);
      $display ("DBG_uB: Read VREF training Done %t", $time);
	  $display ("DBG_uB: ============================================");
	end
  
  always @(posedge status_reg[27])
    if (!rst) begin
	  $display ("DBG_uB: ============== Status: %h ============", status_reg);
      $display ("DBG_uB: Write VREF training Done %t", $time);
	  $display ("DBG_uB: ============================================");
	end
	  
  always @(posedge status_reg[28])
    if (!rst) begin
	  $display ("DBG_uB: ============== Status: %h ============", status_reg);
      $display ("DBG_uB: Write DM training Start %t", $time);
	  $display ("DBG_uB: ============================================");
	end
	  
  always @(posedge status_reg[29])
    if (!rst) begin
	  $display ("DBG_uB: ============== Status: %h ============", status_reg);
      $display ("DBG_uB: Write DM training Done %t", $time);
	  $display ("DBG_uB: ============================================");
	end
	  
  always @(posedge status_reg[30])
    if (!rst) begin
	  $display ("DBG_uB: ============== Status: %h ============", status_reg);
      $display ("DBG_uB: Write/Read Sanity Check Start %t", $time);
	  $display ("DBG_uB: ============================================");
	end	  
  
  always @(posedge status_reg[31])
    if (!rst && status_reg[0]) begin
	  $display ("DBG_uB: ============== Status: %h ============", status_reg);
      $display ("DBG_uB: Write/Read Sanity Check Done %t", $time);
	  $display ("DBG_uB: ============================================");
	end
	
  always @(posedge status_reg[35])
    if (!rst && status_reg[0]) begin
	  $display ("DBG_uB: ============== Status: %h ============", status_reg);
      $display ("DBG_uB: DQS Tracking Started %t", $time);
	  $display ("DBG_uB: ============================================");
	end

  always @(posedge status_reg[37])
    if (!rst && status_reg[0]) begin
	  $display ("DBG_uB: ============== Status: %h ============", status_reg);
      $display ("DBG_uB: Write/Read Sanity Check Start (rank: %d) %t", (status_message_seen>>1), $time);
	  $display ("DBG_uB: ============================================");
	end
	
  /*always @(posedge status_reg[36])
    if (!rst && status_reg[0]) begin
	  $display ("DBG_uB: ============== Status: %h ============", status_reg);
      $display ("DBG_uB: Write/Read Sanity Check Done (rank: %d) %t", (status_message_seen>>1), $time);
	  $display ("DBG_uB: ============================================");
	end*/
  
  //end of Status Messages
  
  always @(posedge cal_error)
    if (!rst) begin
	  $display ("DBG_uB: ============================================");
      $display ("DBG_uB: CAL_FAILED %t", $time);
	  $display ("DBG_uB: ============================================");
	end
	
  always @(posedge cal_warning)
    if (!rst) begin
	  $display ("DBG_uB: ============================================");
      $display ("DBG_uB: WARNING %t", $time);
	  $display ("DBG_uB: ============================================");
	end
	
  always @ (posedge clk) begin
	if (IO_Addr_Strobe && IO_Address == CAL_DONE) begin
	  if (IO_Write_Data[0] == 1) begin
	    $display ("DBG_uB: ============================================");
	    $display ("DBG_uB: CAL_DONE                  %t", $time);
	    $display ("DBG_uB: ============================================");
	  //end else if (IO_Write_Data[0] == 1) begin
	  //  $display ("DBG_uB: en_vtc asserted                  %t", $time);
	  end
	end
  end
  
  //synthesis translate_on

endmodule

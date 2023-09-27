/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//******************************************************************************
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor             : Xilinx
// \   \   \/     Version            : 1.1
//  \   \         Application        : QDRIIP
//  /   /         Filename           : qdriip_v1_4_19_xsdb_bram.sv
// /___/   /\     Date Last Modified : 2016/11/30
// \   \  /  \    Date Created       : Tue Jul 29 2014
//  \___\/\___\
//
// Device           : UltraScale
// Design Name      : QDRII+ SDRAM
// Purpose          :
//             Dual port BRAM instantiation for storing the debug information.
//             One port is accessible through MicroBlaze and the other through 
//             the XSDB interface.
// Reference        :
// Revision History :
//*****************************************************************************

`timescale 1ns / 1ps

(* bram_map="yes" *)
module qdriip_v1_4_19_xsdb_bram #(

   // Header
    parameter  START_ADDRESS             = 18
   ,parameter  PARAM_MAP_VERSION         = 2
   ,parameter  MEMORY_TYPE               = 6
   ,parameter  RANK                      = 1
   ,parameter  DBYTES                    = 2
   ,parameter  DNIBBLES                  = 2*DBYTES
   ,parameter  QDR_BYTE_LEN              = 9
   ,parameter  ERROR_MAP_VERSION         = 2
   ,parameter  CAL_MAP_VERSION           = 2
   ,parameter  WARN_MAP_VERSION          = 2

   // Code versions
   ,parameter  CAL_VER_RTL               = 1
   ,parameter  CAL_VER_C                 = 1
   
   // Configuration ROM
    // MEMORY_TYPE - Header
   ,parameter  ABITS                     = 19
   ,parameter  WPSN_BITS                 = 1
   ,parameter  RPSN_BITS                 = 1
   ,parameter  BYTES                     = 6
    // DBYTES - Header
   ,parameter  DATA_WIDTH                = 18
   ,parameter  BITS_PER_BYTE             = 18
   ,parameter  TCK                       = 511
   ,parameter  NCK_PER_CLK               = 2
   ,parameter  CAL_RDLVL                 = 1
   ,parameter  CAL_WRITE_CAL             = 1
   ,parameter  CAL_FAST                  = 1
   ,parameter  CAL_INIT_WRCAL            = 1
   ,parameter  CAL_INIT_RD_CAL           = 1
   ,parameter  CAL_K_TO_WRITE            = 1
   ,parameter  CAL_AC                    = 1
   ,parameter  CAL_BITSLIP_RDVLD         = 1
   ,parameter  CAL_RDLVL_CMPX            = 0
   ,parameter  DQS_SAMPLE_CNT            = 500
   ,parameter  WRLVL_SAMPLE_CNT          = DQS_SAMPLE_CNT 
   ,parameter  RDLVL_SAMPLE_CNT          = DQS_SAMPLE_CNT 
   ,parameter  RDLVL_MIN_EYE             = DQS_SAMPLE_CNT 
   ,parameter  RDLVL_RANGE_CHK           = 1 
   ,parameter  DBG_MESSAGES              = 1 
   ,parameter  STEP_SIZE                 = 1
   ,parameter  BISC_ON                   = 1
   ,parameter  MEM_LATENCY               = 1
   ,parameter  TAPS_90                   = 511
   ,parameter  CAL_K_TO_BWS_CNTR         = 1
   ,parameter  CAL_K_TO_BWS_BITSLIP      = 1
   ,parameter  BURST_LEN                 = 2
)
(
    clka
   ,clkb
   ,ena
   ,enb
   ,addra
   ,addrb
   ,dina
   ,dinb
   ,douta
   ,doutb
   ,wea
   ,web
   ,rsta
   ,rstb
);

//-----------------------------------------
//Signal Declarations--Input Ports
//-----------------------------------------
  input clka;
  input clkb;
  input ena;
  input enb;
  input [11:0]addra;
  input [11:0]addrb;
  input [8:0]dina;
  input [8:0]dinb;
  input [0:0]wea;
  input [0:0]web;
  input [0:0] rsta;
  input [0:0] rstb;
  
  output [8:0]douta;
  output [8:0]doutb;

//-----------------------------------------
//Signal Declarations--Output Ports
//-----------------------------------------
//output	[71:0] 	RES		;
//output [8:0] RES;
//reg ADDR_WIDTH_init = $realtobits(ADDR_WIDTH);
// BRAM_TDP_MACRO: True Dual Port RAM
// 7 Series
// Xilinx HDL Libraries Guide, version 13.4
//////////////////////////////////////////////////////////////////////////
// DATA_WIDTH_A/B | BRAM_SIZE | RAM Depth | ADDRA/B Width | WEA/B Width //
// ===============|===========|===========|===============|=============//
// 19-36 | "36Kb" | 1024 | 10-bit | 4-bit //
// 10-18 | "36Kb" | 2048 | 11-bit | 2-bit //
// 10-18 | "18Kb" | 1024 | 10-bit | 2-bit //
// 5-9 | "36Kb" | 4096 | 12-bit | 1-bit //
// 5-9 | "18Kb" | 2048 | 11-bit | 1-bit //
// 3-4 | "36Kb" | 8192 | 13-bit | 1-bit //
// 3-4 | "18Kb" | 4096 | 12-bit | 1-bit //
// 2 | "36Kb" | 16384 | 14-bit | 1-bit //
// 2 | "18Kb" | 8192 | 13-bit | 1-bit //
// 1 | "36Kb" | 32768 | 15-bit | 1-bit //
// 1 | "18Kb" | 16384 | 14-bit | 1-bit //
//////////////////////////////////////////////////////////////////////////
BRAM_TDP_MACRO #(
.BRAM_SIZE("36Kb"), // Target BRAM: "18Kb" or "36Kb"
.DEVICE("7SERIES"), // Target device: "VIRTEX5", "VIRTEX6", "SPARTAN6", "7SERIES"
.DOA_REG(0), // Optional port A output register (0 or 1)
.DOB_REG(0), // Optional port B output register (0 or 1)
.INIT_A(9'h0), // Initial values on port A output port
.INIT_B(9'h0), // Initial values on port B output port
.INIT_FILE ("NONE"),
.READ_WIDTH_A (9), // Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
.READ_WIDTH_B (9), // Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
.SIM_COLLISION_CHECK ("ALL"), // Collision check enable "ALL", "WARNING_ONLY",
// "GENERATE_X_ONLY" or "NONE"
.SRVAL_A(9'h0), // Set/Reset value for port A output
.SRVAL_B(9'h0), // Set/Reset value for port B output
.WRITE_MODE_A("WRITE_FIRST"), // "WRITE_FIRST", "READ_FIRST", or "NO_CHANGE"
.WRITE_MODE_B("WRITE_FIRST"), // "WRITE_FIRST", "READ_FIRST", or "NO_CHANGE"
.WRITE_WIDTH_A(9), // Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
.WRITE_WIDTH_B(9), // Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")

// INIT_xx are for the data initialization
.INIT_00({CAL_RDLVL[7:0],NCK_PER_CLK[7:0],8'b0,BITS_PER_BYTE[7:0],DATA_WIDTH[7:0],DBYTES[7:0],BYTES[7:0],RPSN_BITS[7:0],WPSN_BITS[7:0],ABITS[7:0],MEMORY_TYPE[7:0],8'b0,8'b0,4'b0,CAL_VER_RTL[3:0],48'b0,4'b0,WARN_MAP_VERSION[3:0],4'b0,CAL_MAP_VERSION[3:0],4'b0,ERROR_MAP_VERSION[3:0],QDR_BYTE_LEN[7:0],DNIBBLES[7:0],DBYTES[7:0],4'b0,RANK[3:0],4'b0,MEMORY_TYPE[3:0],4'b0,PARAM_MAP_VERSION[3:0],8'b0,8'b0,3'b0,START_ADDRESS[4:0]}),
.INIT_01({120'b0,40'b0,8'b0,8'b0,16'b0,TCK[16:9],TCK[7:0],8'b0,8'b0,BURST_LEN[7:0],CAL_K_TO_BWS_BITSLIP[7:0],CAL_K_TO_BWS_CNTR[7:0],TAPS_90[7:0],MEM_LATENCY[7:0],BISC_ON[7:0],STEP_SIZE[7:0],DBG_MESSAGES[7:0],RDLVL_RANGE_CHK[7:0],RDLVL_MIN_EYE[7:0],RDLVL_SAMPLE_CNT[7:0],WRLVL_SAMPLE_CNT[7:0],DQS_SAMPLE_CNT[7:0],CAL_RDLVL_CMPX[7:0],CAL_BITSLIP_RDVLD[7:0],CAL_AC[7:0],CAL_K_TO_WRITE[7:0],CAL_INIT_RD_CAL[7:0],CAL_INIT_WRCAL[7:0],CAL_FAST[7:0],CAL_WRITE_CAL[7:0]}),

// INITP_xx are for the parity bits
//.INITP_00({204'b0,5'b0,1'b0,1'b0,2'b0,2'b0,2'b0,3'b0,1'b0,TAPS_90[8],MEM_LATENCY[8],DBG_MESSAGES[8],RDLVL_RANGE_CHK[8],RDLVL_MIN_EYE[8],RDLVL_SAMPLE_CNT[8],WRLVL_SAMPLE_CNT[8],DQS_SAMPLE_CNT[8],CAL_RDLVL_CMPX[2],CAL_K_TO_WRITE[2],CAL_FAST[0],TCK[8],1'b0,1'b0,1'b0,RPSN_BITS[1],1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,QDR_BYTE_LEN[8],DNIBBLES[8],DBYTES[8],1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
.INITP_01({7'b0,TCK[17],TCK[8],23'b0})

) BRAM_TDP_MACRO_inst (
.DOA(douta), // Output port-A data, width defined by READ_WIDTH_A parameter
.DOB(doutb), // Output port-B data, width defined by READ_WIDTH_B parameter
.ADDRA(addra), // Input port-A address, width defined by Port A depth
.ADDRB(addrb), // Input port-B address, width defined by Port B depth
.CLKA(clka), // 1-bit input port-A clock
.CLKB(clkb), // 1-bit input port-B clock
.DIA(dina), // Input port-A data, width defined by WRITE_WIDTH_A parameter
.DIB(dinb), // Input port-B data, width defined by WRITE_WIDTH_B parameter
.ENA(ena), // 1-bit input port-A enable
.ENB(enb), // 1-bit input port-B enable
.REGCEA(1'b0), // 1-bit input port-A output register enable
.REGCEB(1'b0), // 1-bit input port-B output register enable
.RSTA(1'b0), // 1-bit input port-A reset
.RSTB(1'b0), // 1-bit input port-B reset
.WEA(wea), // Input port-A write enable, width defined by Port A depth
.WEB(web) // Input port-B write enable, width defined by Port B depth
);
// End of BRAM_TDP_MACRO_inst instantiation


endmodule

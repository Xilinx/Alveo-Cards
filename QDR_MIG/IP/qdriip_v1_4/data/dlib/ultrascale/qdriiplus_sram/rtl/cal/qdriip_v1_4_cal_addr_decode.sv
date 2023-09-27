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
//  /   /         Filename              : qdriip_v1_4_19_cal_addr_decode.v
// /___/   /\     Date Last Modified    : 2016/11/30
// \   \  /  \    Date Created          : Thu Oct 24 2013
//  \___\/\___\
//
//Device            : UltraScale 
//Design            : QDRII+ SRAM
//Purpose           :
//           It is a register interface unit between the microblaze and PHY.
//           Here, PHY includes the hard block XIPHY along with its interfacing
//           soft logic and the calibration logic. It also includes the command
//           and the data processing logic required for the calibration.
//Reference         :
//Revision History  :
//*****************************************************************************

`timescale 1ps/1ps

module qdriip_v1_4_19_cal_addr_decode #
( 
 parameter DBYTES           = 4,  
 parameter DBITS            = 18, 
 parameter ABITS            = 18, 
 parameter RD_LATENCY       = "2",
 parameter MEM_LATENCY      = "2", 
 parameter BURST_LEN        = 4,
 parameter CLK_2TO1         = "TRUE",
 parameter CAL_MODE         = "FAST",
 parameter SIM_MODE         = "FULL",
 parameter TCQ              = 100
)
(
 //Clocks and reset
 input                          clk,
 input                          rst,

 //Interface with MicroBlaze
 input [27:0]                   io_address,      
 input                          io_addr_strobe,
 input                          io_write_strobe,
 input [31:0]                   mb_to_addr_dec_data, 
 output reg [31:0]              addr_dec_to_mb_data,
 output reg                     io_ready,

 //Initialization signals
 input                          init_done,
 input			        cal_initdone_pwr_up,
 input			        vtc_complete,
 output reg                     en_vtc,
 output reg                     cal_done,

 //DQ In/Out signals
 input  [DBYTES*4*9-1:0]        mcal_dqin,
 
 //Calibration signals to Fabric
 output reg [3:0]               cal_rps_n_r,
 output reg [3:0]               cal_wps_n_r,
 output reg [3:0]               cal_doff_r, 
 output reg [DBYTES*4*9-1:0]    cal_dqout_r,
 output reg [DBYTES*4-1:0]      cal_bws_n_r,
 output reg [ABITS*4-1:0]       cal_addr_r,
 output reg 	                clb2phy_rden_r,
 output reg                     ub_ready_r,
 output reg [31:0]              all_nibbles_t_b,

 // read bitslip and read valid signals
 output reg [2*DBITS-1:0]       rd_data_slip_r ,
 output reg [2*DBITS-1:0]       wr_data_slip_r ,
 output reg [2*(DBITS/9)-1:0]   wr_bws_slip_r ,
 output reg [2:0]               addr_slip_r,
 output reg [4:0]               rd_latency_val_r,
 output reg [2*DBITS-1:0]       fabric_slip_r,
 output reg                     single_stg_fabslip_r,

 // Debug rom signals
 output reg                     dbg_wr_en_r,
 output reg [31:0]              dbg_wr_data_r,
 output reg [11:0]              dbg_addr,
 output reg                     dbg_rd_en,
 input  [8:0]                   dbg_rd_data,

 //Configuration Read from rom
 input [31:0]                   config_rd_data,
 output reg [7:0]               config_rd_addr,
 
 output [99:0]                  dbg_bus,
 input [DBYTES*9*4-1:0]         traffic_error,
 output reg                     traffic_clr_error,
 input [3:0]                    win_start,
 input                          traffic_wr_done,
 output reg [31:0]              win_status
);

//Funtion to findout log base2 value 
function integer clogb2 (input integer size);
  begin
    size = size - 1;
    for (clogb2=1; size>1; clogb2=clogb2+1)
      size = size >> 1;
  end
endfunction

//Chekcing how may 32bit registers are needed  
function integer numof32 (input integer size32);
  begin
      for (numof32=0; size32>0; numof32=numof32+1)
      size32 = size32 - 32;
  end
endfunction

//Calculating the part select width that will be used during 
//multi-word writes and reads
localparam MB_DQ_CNT_WIDTH    = clogb2(DBYTES*2);
localparam DNIBBLE_WIDTH      = DBYTES*2 ;
localparam DNIBBLE_CNT_WIDTH  = clogb2(DNIBBLE_WIDTH) ;

//*************************************************************************//
//******************MB Adress Apace****************************************//
//*************************************************************************//
localparam CAL_RDY         = 28'b ????_0000_??10_0000_????_????_???0; //0020000
localparam CAL_CMD_INIT_DN = 28'b ????_0000_??10_0000_????_????_???1; //0020001

localparam CAL_DQOUT_A     = 28'b ????_0000_?10?_0000_0000_000?_????; //0040000
localparam CAL_DQOUT_B     = 28'b ????_0000_?10?_0000_0000_001?_????; //0040020    
localparam CAL_DQPAT_A     = 28'b ????_0000_?10?_0000_0000_010?_????; //0040040
localparam CAL_DQPAT_B     = 28'b ????_0000_?10?_0000_0000_011?_????; //0040060
localparam CAL_PAT_A       = 28'b ????_0000_?10?_0000_0000_100?_????; //0040080
localparam CAL_PAT_B       = 28'b ????_0000_?10?_0000_0000_101?_????; //00400A0
localparam CAL_PAT_C       = 28'b ????_0000_?10?_0000_0000_110?_????; //00400C0
localparam CAL_PAT_D       = 28'b ????_0000_?10?_0000_0000_111?_????; //00400E0
localparam AUTO_CMP_RISE   = 28'b ????_0000_?10?_0000_0001_????_????; //0040100
localparam AUTO_CMP_FALL   = 28'b ????_0000_?10?_0000_0010_????_????; //0040200
localparam AUTO_CMP_BOTH   = 28'b ????_0000_?10?_0000_0011_????_????; //0040300
localparam RD_BIT_SLIP     = 28'b ????_0000_?10?_0000_0100_????_????; //0040400
localparam WR_DATA_SLIP    = 28'b ????_0000_?10?_0000_0101_????_????; //0040500
localparam WR_BWS_SLIP     = 28'b ????_0000_?10?_0000_0110_????_????; //0040600
localparam ADDR_SLIP       = 28'b ????_0000_?10?_0000_0111_????_????; //0040700
localparam PAT_MATCH_AB    = 28'b ????_0000_?10?_0000_1000_????_????; //0040800
localparam SLIP_ON_WRDATA  = 28'b ????_0000_?10?_0000_1001_????_????; //0040900
localparam ALL_NIBBLE_T_B  = 28'b ????_0000_?10?_0000_1010_????_????; //0040A00
localparam CMP_PAT_CD      = 28'b ????_0000_?10?_0000_1011_????_????; //0040B00
localparam CMP_PAT_AB      = 28'b ????_0000_?10?_0000_1100_????_????; //0040C00
localparam PAT_MATCH_CD    = 28'b ????_0000_?10?_0000_1101_????_????; //0040D00
localparam RD_LATENCY_CNT  = 28'b ????_0000_?10?_0000_1110_????_????; //0040E00

localparam CAL_DMOUT_N_A   = 28'b ????_0000_100?_0000_????_??00_????; //0080000 
localparam CAL_DMOUT_N_B   = 28'b ????_0000_100?_0000_????_??01_????; //0080010 
localparam MCAL_DMIN       = 28'b ????_0000_100?_0000_????_??10_????; //0080020

//localparam MCAL_DQIN       = 28'b ????_????_1111_????_0001_??0?_????; //0040100
//localparam MCAL_CMP	       = 28'b ????_????_?1??_????_0001_??1?_????; //0040120

localparam CAL_SEQ           = 28'b ????_0001_????_0000_???1_????_0000; //0100100
localparam CAL_SEQ_CNT       = 28'b ????_0001_????_0000_???1_????_0001; //0100101
localparam CAL_SEQ_A_A_DLY   = 28'b ????_0001_????_0000_???1_????_0010; //0100102
localparam CAL_SEQ_A_B_DLY   = 28'b ????_0001_????_0000_???1_????_0011; //0100103  
localparam CAL_SEQ_B_A_DLY   = 28'b ????_0001_????_0000_???1_????_0100; //0100104
localparam CAL_SEQ_RD_CNT    = 28'b ????_0001_????_0000_???1_????_0101; //0100105
localparam CAL_SEQ_CLR       = 28'b ????_0001_????_0000_???1_????_0110; //0100106
localparam CAL_CMP_CONFIG    = 28'b ????_0001_????_0000_???1_????_0111; //0100107 
localparam CAL_ADDR_CONFIG   = 28'b ????_0001_????_0000_???1_????_1000; //0100108 
localparam CAL_SEQ_CWL       = 28'b ????_0001_????_0000_??10_????_????; //0100200
localparam CAL_TRAFFIC_CNT   = 28'b ????_0001_????_0000_0100_????_??00; //0100400
localparam CAL_MARGIN_START  = 28'b ????_0001_????_0000_0100_????_??01; //0100401
localparam CAL_MARGIN_RESULT = 28'b ????_0001_????_0000_0100_????_??10; //0100402
localparam CAL_MARGIN_STATUS = 28'b ????_0001_????_0000_0100_????_??11; //0100403
localparam CAL_RD_EN         = 28'b ????_0001_????_0000_1000_????_????; //0100800
localparam CAL_TRAFFIC_ERR   = 28'b ????_0001_????_0001_0000_????_????; //0101000

localparam DDR_AC_ADR_A    = 28'b ????_0010_???1_0000_????_?001_????; //0210010
localparam DDR_AC_DOFF_A   = 28'b ????_0010_???1_0000_????_?011_????; //0210030
localparam DDR_AC_RPS_A    = 28'b ????_0010_???1_0000_????_?100_????; //0210040
localparam DDR_AC_WPS_A    = 28'b ????_0010_???1_0000_????_?101_????; //0210050

localparam DDR_AC_ADR_B    = 28'b ????_0100_???1_0000_????_?001_????; //0410010
localparam DDR_AC_RPS_B    = 28'b ????_0100_???1_0000_????_?100_????; //0410040
localparam DDR_AC_WPS_B    = 28'b ????_0100_???1_0000_????_?101_????; //0410050

localparam CONFIG_PARAMS   = 28'b ????_1000_????_0000_?000_????_????; //0800000 
localparam STATUS          = 28'b ????_1000_????_0000_?001_????_???0; //0800100
localparam DEBUG           = 28'b ????_1000_????_0000_?001_????_???1; //0800101
localparam CAL_DONE        = 28'b ????_1000_????_0000_?010_????_????; //0800200
localparam CAL_PQTR_BISC   = 28'b ????_1000_????_0000_?011_????_????; //0800300
localparam CAL_NQTR_BISC   = 28'b ????_1000_????_0000_?100_????_????; //0800400
localparam CLB2PHY_RDEN    = 28'b ????_1000_????_0000_?101_????_????; //0800500

localparam DEBUG_RAM       = 28'b ????_1001_????_0000_????_????_????; //0900000

//this localparam will define the width for the compare register. As we can
//read only 32 bits by MicroBlaze, for 36 bit interface we have to use two 
//registers go provide the compare results per bit wise.
localparam CMP_WIDTH = ((DBITS) > 64) ? 128 : ((DBITS) > 32) ? 64 : 32 ;
localparam ERR_WIDTH = (DBITS == 18) ? 96 : 160 ;

// Delay counter counts abbreviated number of reads for simulation
`ifdef SIMULATION
   localparam DLY_CNTR_WIDTH = 4;
`else
   localparam DLY_CNTR_WIDTH = 16;
`endif

wire [1:0]              slip_init_value ;
reg                     config_rd_val;
reg                     io_addr_strobe_r1;
reg                     io_addr_strobe_r2;

reg  [DBITS-1:0]        dqin_rise_0_r ;
reg  [DBITS-1:0]        dqin_fall_0_r ;
reg  [DBITS-1:0]        dqin_rise_1_r ;
reg  [DBITS-1:0]        dqin_fall_1_r ;
reg  [DBITS-1:0]        dqin_rise_0_r1 ;
reg  [DBITS-1:0]        dqin_fall_0_r1 ;
reg  [DBITS-1:0]        dqin_rise_1_r1 ;
reg  [DBITS-1:0]        dqin_fall_1_r1 ;
reg  [DBITS-1:0]        dqin_rise_0_r2 ;
reg  [DBITS-1:0]        dqin_fall_0_r2 ;
reg  [DBITS-1:0]        dqin_rise_1_r2 ;
reg  [DBITS-1:0]        dqin_fall_1_r2 ;
reg  [DBITS-1:0]        dqin_rise_0_r3 ;
reg  [DBITS-1:0]        dqin_fall_0_r3 ;
reg  [DBITS-1:0]        dqin_rise_1_r3 ;
reg  [DBITS-1:0]        dqin_fall_1_r3 ;

reg  [DBITS-1:0]        err_rise_0_r ;
reg  [DBITS-1:0]        err_fall_0_r ;
reg  [DBITS-1:0]        err_rise_1_r ;
reg  [DBITS-1:0]        err_fall_1_r ;
reg  [DBITS-1:0]        err_rise_0_bwcal_r ;
reg  [DBITS-1:0]        err_fall_0_bwcal_r ;
reg  [DBITS-1:0]        err_rise_1_bwcal_r ;
reg  [DBITS-1:0]        err_fall_1_bwcal_r ;
reg  [DBITS-1:0]        cmp_pat_ab_r ;
reg  [DBITS-1:0]        cmp_pat_cd_r ;
reg  [CMP_WIDTH-1:0]    cmp_pat_ab_reg ;
reg  [CMP_WIDTH-1:0]    cmp_pat_cd_reg ;
reg  [DBITS-1:0]        cmp_pat_ab_rise_r ;
reg  [DBITS-1:0]        cmp_pat_ab_rise0_r ;
reg  [DBITS-1:0]        cmp_pat_cd_rise_r ;
reg  [DBITS-1:0]        cmp_pat_ab_fall_r ;
reg  [DBITS-1:0]        cmp_pat_ab_fall0_r ;
reg  [DBITS-1:0]        cmp_pat_cd_fall_r ;
reg  [DBITS-1:0]        cmp_rise_0_vld_r ;
reg  [DBITS-1:0]        cmp_fall_0_vld_r ;
reg  [DBITS-1:0]        cmp_rise_1_vld_r ;
reg  [DBITS-1:0]        cmp_fall_1_vld_r ;
reg 			ab_pat_compare_r ;
reg  			toggle_compare_r ;
reg  			fix_pat_compare_r ;
reg  			bw_toggle_compare_r ;
reg  			pattern_compare_r;
reg  			addr_cal_compare_r;
reg [DBITS-1:0] 	pat_match_ab_vld_32;
reg [DBITS-1:0] 	pat_match_cd_vld_32;
reg [CMP_WIDTH-1:0] 	pat_match_ab_vld;
reg [CMP_WIDTH-1:0] 	pat_match_cd_vld;
reg [ABITS-1:0]  	rd_addr_cal_ch0_en;     
reg [ABITS-1:0]  	wr_addr_cal_ch0_en;     
reg [ABITS-1:0]  	rd_addr_cal_ch1_en;     
reg [ABITS-1:0]  	wr_addr_cal_ch1_en;     
reg [5:0]               cal_addr_bit_cnt;     
reg [ABITS*4-1:0]       cal_addr_i;
reg [3:0]               cal_wps_n_i;
reg [3:0]               cal_rps_n_i;
reg [3:0]               cal_doff_i;
reg [DBITS -1:0] 	rise0_rise1_error_toggle_r;
reg [DBITS -1:0] 	fall0_fall1_error_toggle_r;
reg [DBITS -1:0] 	rise0_rise1_error_any_pat_r;
reg [DBITS -1:0] 	fall0_fall1_error_any_pat_r;
//reg [DBITS -1:0] 	rise0_rise1_error_bwcal_r;
//reg [DBITS -1:0] 	fall0_fall1_error_bwcal_r;
//reg [CMP_WIDTH-1:0]     rise0_rise1_error_addrcal_r;
reg [DBITS -1:0] 	rise0_rise1_error_slip_r;
reg [DBITS -1:0] 	fall0_fall1_error_slip_r;
reg [CMP_WIDTH -1:0] 	rise0_rise1_error_r;
reg [CMP_WIDTH -1:0] 	fall0_fall1_error_r;
reg [CMP_WIDTH -1:0] 	rise_fall_error_r;
reg [DBITS -1:0]	rd_data_match_r;
reg [DBITS -1:0] 	rd_data_match_r1;
reg [DBITS -1:0]        err_pat_abcd_r ;
reg 			few_bits_not_matched_r;
reg                     cal_seq_r;
                         //0: CMD A only , 1: CMD A on even, CMD B on odd cycles
reg [7:0]               cal_seq_cnt;
                         //sequence counter for cmd generation
reg [4:0]               cal_seq_a_a_dly_r;
                         //CMD A -> A delay
reg [4:0]               cal_seq_a_b_dly_r;
                         //CMD A -> B delay
reg [4:0]               cal_seq_b_a_dly_r;
                         //CMD B -> A delay
reg [15:0]              cal_seq_rd_cnt;
                         //sequence counter for the number of reads
reg [31:0] 	        cal_rd_data_slip_32_r;
reg [31:0] 	        cal_wr_data_slip_32_r;
reg [CMP_WIDTH-1:0] 	cal_rd_data_slip_r; 
reg [CMP_WIDTH-1:0] 	cal_wr_data_slip_r; 
reg [DBYTES-1:0]        cal_wr_bws_slip_r; 
reg [1:0] 	        cal_addr_slip_r; 
//wire   		clr_err_r;
reg   		        clr_err_r;
reg                     slip_on_wrdata_r;
reg                     cnt_clr;
                         //clear seq_cnt and rd_cnt to stop read process
reg                     dq_rd_valid;
                         //indicated the data read out from fifo is valud
reg                     ub_rd_vld_riu_r;
reg                     ub_rd_vld_riu_r1;
reg                     ub_rd_vld_riu_r2;

//Used for combinatorial logic 
reg			config_access ;
reg                     cmd_cnt_reg_sel;
reg                     cal_cnt_rd ;
reg                     cnt_clr_access;
reg                     a_b_rd_sel;
reg [31:0]              intr_cmd_dly_r;
                         //delay between 2 command
reg                     cmd_cnt_dec_r;
                         //When cmd issued, set this for decreasing cal_seq_cnt
reg                     a_b_cmd_sel;
                         //used to select command set between A and B
                         //cmd generation should be always from A set.
reg [4:0]               latency_counter_r;
                         //delay from CMD(RD) to read valid
reg 			rd_cmd_r;
reg 			rd_cmd_r1;
reg 			first_rd_cmd_r;
reg 			few_bits_matched_r;
reg 			few_bits_matched_r1;
wire                    cal_failed;

//index is offset of the data from the base address
//address index is limited by parameter width (ABITS...)
reg [MB_DQ_CNT_WIDTH-1:0]     dq_index;  
reg [15:0]                    cal_dqout_a_r;                    
reg [15:0]                    cal_dqout_b_r;                    
reg [15:0]                    cal_dqpat_a_r;                    
reg [15:0]                    cal_dqpat_b_r;                    
reg [15:0]                    cal_pat_a_r;
reg [15:0]                    cal_pat_b_r;
reg [15:0]                    cal_pat_c_r;
reg [15:0]                    cal_pat_d_r;
//reg [DBYTES*4*9-1:0]          mcal_dq_cmp_r;                            
reg [3:0]                     cal_dmout_a_r;                                                                            
reg [3:0]                     cal_dmout_b_r;                                                                             
reg [ABITS-1:0]               cal_addr_a_r;                      
reg [ABITS-1:0]               cal_addr_b_r;
reg [3:0]                     cal_doff_a_r;
reg [3:0]                     cal_doff_b;
reg [3:0]                     cal_wps_a_r;
reg [3:0]                     cal_wps_b_r;
reg [3:0]                     cal_rps_a_r;
reg [3:0]                     cal_rps_b_r;
reg [8:0]                     cal_pqtr_bisc_9_r ; 
reg [8:0]                     cal_nqtr_bisc_9_r ; 
reg [((DBYTES*2)*9)-1:0]      cal_pqtr_bisc_r ; 
reg [((DBYTES*2)*9)-1:0]      cal_nqtr_bisc_r ; 
reg [DNIBBLE_CNT_WIDTH-1:0]   nibble_cnt ;

//Debug signal
reg                           wrong_addr_access_wr;
reg                           wrong_addr_access_rd;
wire                          wrong_addr_access;
reg [31:0]                    debug_r;
reg [31:0]                    status_r;
reg [DBITS-1:0]               fabric_slip_val;
reg [DBITS-1:0]               fabric_slip_val_r;

integer idx; 
   
//Margin Results (may move these to BRAM eventually)
reg [31:0]              margin_status;
reg [31:0]              margin_status_x0;
reg                     margin_p_active;
reg                     margin_n_active;
reg [8:0]               margin_left;
reg [8:0]               margin_right;
reg [8:0]               margin_start_tap;

//Registers to store the results to view in waveform
//reg [7:0]               margin_nibble_r;
reg [8:0]               margin_left_p;
reg [8:0]               margin_right_p;
reg [8:0]               margin_start_tap_p;
reg [8:0]               margin_left_n;
reg [8:0]               margin_right_n;
reg [8:0]               margin_start_tap_n;

//Delay counter signals
reg                     delay_cntr_rd_valid;
reg [DLY_CNTR_WIDTH-1:0]delay_cntr;
reg [DLY_CNTR_WIDTH-1:0]delay_cntr_r;
reg [DLY_CNTR_WIDTH-1:0]delay_cntr_r1;
reg [DLY_CNTR_WIDTH-1:0]delay_cntr_r2;
wire                    delay_cntr_ce;
wire                    delay_cntr_done;

reg                     traffic_clr_error_r;
reg                     traffic_clr_error_r1;
reg                     traffic_clr_error_r2;
reg [ERR_WIDTH-1:0]     traffic_error_r;
reg [4*4-1:0]           traffic_error_byte_r;
reg [0:0]               win_start_r;
reg [0:0]               win_start_r1;
reg [3:0]               win_start_r2;

//***********************************************************************//
//*********************** Start of the RTL ******************************//
//***********************************************************************//

assign dbg_bus[0+:32] = status_r;
assign dbg_bus[32+:32] = rise0_rise1_error_r[31:0];
assign dbg_bus[64+:32] = fall0_fall1_error_r[31:0];
assign dbg_bus[96] = clr_err_r;
assign dbg_bus[97] = toggle_compare_r;
assign dbg_bus[98] = pattern_compare_r;
assign dbg_bus[99] = fix_pat_compare_r;

//** Few Combinatorial outputs **//
always @(*)
begin
  // Signals that decode required info from the MB address
  config_access    = io_address[23] & (~io_address[20]) & 
                     (~io_address[8]) & (~io_address[9]) & 
                     (~io_address[10]) & (~io_address[11]);
  cmd_cnt_reg_sel  = (~io_address[23]) & io_address[20] & io_address[8] & 
                     (io_address[3:0] == 'h1) & io_write_strobe & io_addr_strobe;
  cal_cnt_rd       = (~io_address[23]) & io_address[20] & io_address[8] & 
                     (io_address[3:0] == 'h5) & io_write_strobe & io_addr_strobe;
  cnt_clr_access   = (~io_address[23]) & io_address[20] & io_address[8] & 
                     (io_address[3:0] =='h6) & io_write_strobe & io_addr_strobe;

  // Address part select to determine the byte or nibble numbers. This is used
  // for width expansion. E.g. 36 bit width values with 32-bit registers.
  config_rd_addr   = io_address[7:0];
  dq_index         = io_address[MB_DQ_CNT_WIDTH-1:0];
  nibble_cnt       = io_address[DNIBBLE_CNT_WIDTH-1:0];
  dbg_rd_en        = io_address[23] & (~io_address[22]) & 
                     (~io_address[21]) & (io_address[20]); //0x900000
  dbg_addr         = io_address[11:0];
end

//cmd selection is depending on cal_seq_r(A only or A/B alternative) and 
//cal_seq_cnt (even is A, odd is B) comparison reg selection is depending
//on cal_seq_r (A only or A/B alternative) and cal_seq_rd_cnt
always @ (*)
begin
  a_b_cmd_sel =  cal_seq_r ? cal_seq_cnt[0]:0;
  a_b_rd_sel =  cal_seq_r ? cal_seq_rd_cnt[0]:0;
end
 
//***************************************************************************
// Margin Checking
//***************************************************************************
always @(posedge clk)
  if (traffic_clr_error_r2 || rst)
    delay_cntr_rd_valid <= #TCQ 1'b0;
  else     
    //delay_cntr_rd_valid <= #TCQ dqin_valid_shift[4];
    delay_cntr_rd_valid <= #TCQ traffic_wr_done;

assign delay_cntr_ce = ~delay_cntr_done & delay_cntr_rd_valid;

always @(posedge clk)
  if (traffic_clr_error_r2 || rst)
    //delay_cntr <= #TCQ {DLY_CNTR_WIDTH{1'b1}};
    delay_cntr <= #TCQ 'h4;
  else if (delay_cntr_ce)
    delay_cntr <= #TCQ delay_cntr - 1;
  else
    delay_cntr <= #TCQ delay_cntr;

assign delay_cntr_done = (delay_cntr == {DLY_CNTR_WIDTH{1'b0}}) ? 1'b1 : 1'b0;

always @(posedge clk)
begin
  traffic_clr_error_r  <= #TCQ cnt_clr;
  traffic_clr_error_r1 <= #TCQ traffic_clr_error_r;
  traffic_clr_error_r2 <= #TCQ traffic_clr_error_r1;
  traffic_clr_error    <= #TCQ traffic_clr_error_r2;
      
  delay_cntr_r         <= #TCQ delay_cntr;
  delay_cntr_r1        <= #TCQ delay_cntr_r;
  delay_cntr_r2        <= #TCQ delay_cntr_r1;

  margin_status_x0     <= #TCQ margin_status;
  win_status           <= #TCQ margin_status_x0;
end

// Once the margin check is completed, win_start deasserts automatically.
// Margin calculation can start again if a rise edge is detected on win_start
always @(posedge clk) begin
  if (rst)
    win_start_r1  <= #TCQ 0;
  else if (margin_status[17]) //Margin_Active
    win_start_r1  <= #TCQ 0;
  else if (win_start[0] & (~win_start_r))
    win_start_r1  <= #TCQ 1;
end

always @(posedge clk) begin
  win_start_r     <= #TCQ win_start[0];
  win_start_r2    <= #TCQ {3'b0,win_start_r1};
end

always @(posedge clk) begin
  if (rst)
    traffic_error_r <= #TCQ {ERR_WIDTH{1'b0}};
  else
    traffic_error_r <= #TCQ traffic_error;
end

//*************************************************************************//
//************************* MicroBlaze Write/Read *************************//
//*************************************************************************//

//****** Writes from MB *******//
always @ (posedge clk)
begin
  if(rst) begin
    ub_ready_r             <= #TCQ 'b0;
    cal_done               <= #TCQ 'b0;
    en_vtc                 <= #TCQ 'b0;
    clr_err_r              <= #TCQ 'b0;
    toggle_compare_r        <= #TCQ 'b1;
    pattern_compare_r      <= #TCQ 'b0;
    fix_pat_compare_r        <= #TCQ 'b0;
    bw_toggle_compare_r        <= #TCQ 'b0;
    ab_pat_compare_r       <= #TCQ 'b0;
    cal_rd_data_slip_32_r  <= #TCQ 'b0;
    cal_wr_data_slip_32_r  <= #TCQ 'b0;
    cal_wr_bws_slip_r      <= #TCQ 'b0;
    cal_addr_slip_r        <= #TCQ 'b0;
    all_nibbles_t_b        <= #TCQ 'b0;
    wrong_addr_access_wr   <= #TCQ 'b0;
    cal_wps_a_r            <= #TCQ {4{1'b1}};
    cal_wps_b_r            <= #TCQ {4{1'b1}};
    cal_rps_a_r            <= #TCQ {4{1'b1}};
    cal_rps_b_r            <= #TCQ {4{1'b1}};
    cal_addr_a_r           <= #TCQ 'b0;
    cal_addr_b_r           <= #TCQ 'b0;
    cal_dqout_a_r          <= #TCQ 'b0; 
    cal_dqout_b_r          <= #TCQ 'b0; 
    cal_dmout_a_r          <= #TCQ 'b0; 
    cal_dmout_b_r          <= #TCQ 'b0; 
    clb2phy_rden_r         <= #TCQ 1'b1;
    cal_doff_a_r           <= #TCQ 'b0 ;
    cal_seq_r              <= #TCQ 'b0;
    status_r               <= #TCQ 'b0 ;
    dbg_wr_en_r            <= #TCQ 1'b0;
    rd_addr_cal_ch0_en     <= #TCQ 'b0;
    wr_addr_cal_ch0_en     <= #TCQ 'b0;
    rd_addr_cal_ch1_en     <= #TCQ 'b0;
    wr_addr_cal_ch1_en     <= #TCQ 'b0;
    cal_addr_bit_cnt       <= #TCQ 6'b0;
    addr_cal_compare_r     <= #TCQ 1'b0;
    pat_match_ab_vld       <= #TCQ 1'b1;
    pat_match_cd_vld       <= #TCQ 1'b1;
    margin_status          <= #TCQ 'b0;
  end else begin
    cal_rd_data_slip_32_r <= #TCQ 'b0;
    cal_wr_data_slip_32_r <= #TCQ 'b0;
    cal_wr_bws_slip_r <= #TCQ 'b0;
    cal_addr_slip_r   <= #TCQ 'b0;
    dbg_wr_en_r <= #TCQ 1'b0;
    clr_err_r   <= #TCQ 1'b0;
    if(io_addr_strobe & io_write_strobe) begin
      casez(io_address[23:0])
        DEBUG_RAM: begin
          dbg_wr_data_r <= #TCQ mb_to_addr_dec_data;
          dbg_wr_en_r   <= #TCQ 1'b1;
        end
        //Debug & status
        DEBUG: begin
          debug_r <= #TCQ mb_to_addr_dec_data;
        end
        STATUS: begin
          status_r <= #TCQ mb_to_addr_dec_data;
        end
        CAL_DONE:begin
          en_vtc   <=  #TCQ mb_to_addr_dec_data[0];
          cal_done <=  #TCQ mb_to_addr_dec_data[1];
        end
        CAL_CMD_INIT_DN: begin
          ub_ready_r <= #TCQ mb_to_addr_dec_data[0];
        end
        //Data slip
        RD_BIT_SLIP:begin
          cal_rd_data_slip_32_r <= #TCQ mb_to_addr_dec_data;
        end
        WR_DATA_SLIP:begin
          cal_wr_data_slip_32_r <= #TCQ mb_to_addr_dec_data;
        end
        WR_BWS_SLIP:begin
          cal_wr_bws_slip_r <= #TCQ mb_to_addr_dec_data[DBYTES-1:0];
        end
        ADDR_SLIP:begin
          cal_addr_slip_r <= #TCQ mb_to_addr_dec_data[1:0];
        end
        PAT_MATCH_AB:begin
          pat_match_ab_vld[dq_index*32+:32] <= #TCQ mb_to_addr_dec_data;
        end
        PAT_MATCH_CD:begin
          pat_match_cd_vld[dq_index*32+:32] <= #TCQ mb_to_addr_dec_data;
        end
        ALL_NIBBLE_T_B:begin
          all_nibbles_t_b <= #TCQ mb_to_addr_dec_data;
        end
        //DQOUT/DMOUT/DQPAT        
        CAL_DQOUT_A: begin      
          cal_dqout_a_r <= #TCQ mb_to_addr_dec_data[15:0]; 
        end
        CAL_DQOUT_B: begin
          cal_dqout_b_r <= #TCQ mb_to_addr_dec_data[15:0]; 
        end
        CAL_DMOUT_N_A: begin
          cal_dmout_a_r <= #TCQ mb_to_addr_dec_data[3:0];
        end
        CAL_DMOUT_N_B: begin
          cal_dmout_b_r <= #TCQ mb_to_addr_dec_data[3:0];
        end
        CAL_PAT_A: begin
          cal_pat_a_r  <= #TCQ mb_to_addr_dec_data[15:0]; 
        end
        CAL_PAT_B: begin
          cal_pat_b_r  <= #TCQ mb_to_addr_dec_data[15:0]; 
        end
        CAL_PAT_C: begin
          cal_pat_c_r  <= #TCQ mb_to_addr_dec_data[15:0]; 
        end
        CAL_PAT_D: begin
          cal_pat_d_r  <= #TCQ mb_to_addr_dec_data[15:0]; 
        end
        CAL_SEQ: begin
          cal_seq_r <= #TCQ mb_to_addr_dec_data[0];
        end  
        //DRAM Address, Control, Command Address map       
        //DDR_AC_DOFF_A: begin
        //  cal_doff_a_r <= #TCQ mb_to_addr_dec_data[3:0];
        //end
        DDR_AC_RPS_A: begin        
          cal_rps_a_r <= #TCQ mb_to_addr_dec_data[3:0];
        end
        DDR_AC_RPS_B: begin      
           cal_rps_b_r <= #TCQ mb_to_addr_dec_data[3:0];      
        end
        DDR_AC_WPS_A: begin
           cal_wps_a_r <= #TCQ mb_to_addr_dec_data[3:0];
        end
        DDR_AC_WPS_B: begin
           cal_wps_b_r <= #TCQ mb_to_addr_dec_data[3:0];
        end
        DDR_AC_ADR_A: begin
          cal_addr_a_r <= #TCQ mb_to_addr_dec_data[ABITS-1:0];
        end
        DDR_AC_ADR_B: begin
          cal_addr_b_r <= #TCQ mb_to_addr_dec_data[ABITS-1:0];
        end
        //BISC values
        CAL_PQTR_BISC: begin
          cal_pqtr_bisc_9_r <= #TCQ mb_to_addr_dec_data[8:0];
        end
        CAL_NQTR_BISC: begin
          cal_nqtr_bisc_9_r <= #TCQ mb_to_addr_dec_data[8:0];
        end
        //Control signals to fabric
        CAL_CMP_CONFIG:begin
          addr_cal_compare_r    <= #TCQ mb_to_addr_dec_data[6] ;
          pattern_compare_r <= #TCQ mb_to_addr_dec_data[5]|mb_to_addr_dec_data[3]|addr_cal_compare_r ;
          //bw_toggle_compare_r  <= #TCQ mb_to_addr_dec_data[4] ;
          //fix_pat_compare_r  <= #TCQ mb_to_addr_dec_data[3] ;
          ab_pat_compare_r <= #TCQ mb_to_addr_dec_data[2] ;
          toggle_compare_r  <= #TCQ mb_to_addr_dec_data[0]|mb_to_addr_dec_data[4];
          clr_err_r        <= #TCQ mb_to_addr_dec_data[1] ;
        end
        CAL_SEQ_A_A_DLY: begin
          cal_seq_a_a_dly_r <= #TCQ mb_to_addr_dec_data[4:0];
        end
        CAL_SEQ_A_B_DLY: begin
          cal_seq_a_b_dly_r <= #TCQ mb_to_addr_dec_data[4:0];
        end
        CAL_SEQ_B_A_DLY: begin
          cal_seq_b_a_dly_r <= #TCQ mb_to_addr_dec_data[4:0];
        end
        CLB2PHY_RDEN:begin
          clb2phy_rden_r <=  #TCQ mb_to_addr_dec_data[0];
        end 
        CAL_ADDR_CONFIG: begin   
          rd_addr_cal_ch0_en[0]   <=  #TCQ mb_to_addr_dec_data[0];
          wr_addr_cal_ch0_en[0]   <=  #TCQ mb_to_addr_dec_data[1];
          rd_addr_cal_ch1_en[0]   <=  #TCQ mb_to_addr_dec_data[2];
          wr_addr_cal_ch1_en[0]   <=  #TCQ mb_to_addr_dec_data[3];
          cal_addr_bit_cnt    <=  #TCQ mb_to_addr_dec_data[9:4];
        end 
        CAL_MARGIN_RESULT: begin
          margin_start_tap    <= #TCQ mb_to_addr_dec_data[8:0];
          margin_right        <= #TCQ mb_to_addr_dec_data[17:9];
          margin_left         <= #TCQ mb_to_addr_dec_data[26:18];
          margin_p_active     <= #TCQ mb_to_addr_dec_data[27];
          margin_n_active     <= #TCQ mb_to_addr_dec_data[28];
        end
        CAL_MARGIN_STATUS: begin
          margin_status <= #TCQ mb_to_addr_dec_data;
        end
        default: begin
          if (~cnt_clr_access & ~cal_cnt_rd & ~cmd_cnt_reg_sel)
          begin
            wrong_addr_access_wr <= #TCQ 1; 
            $display("Micro Blaze is trying to write into an unknown address %H",
                                                               io_address);
          end
        end
      endcase
    end
  end 
end 

//******** Read data to MB *********//
always @ (posedge clk)
begin
  if (rst) begin
    wrong_addr_access_rd <= #TCQ 'b0;
    addr_dec_to_mb_data  <= #TCQ 'b0;
  end 
  else if (io_addr_strobe & ~io_write_strobe) begin
    casez(io_address)
      CAL_RDY: begin
        addr_dec_to_mb_data <= {28'h0, vtc_complete, cal_initdone_pwr_up, init_done};  
      end
      AUTO_CMP_RISE: begin
        addr_dec_to_mb_data <= #TCQ rise0_rise1_error_r[dq_index*32+:32];
      end
      AUTO_CMP_FALL: begin
        addr_dec_to_mb_data <= #TCQ fall0_fall1_error_r[dq_index*32+:32];
      end
      AUTO_CMP_BOTH: begin
        addr_dec_to_mb_data <= #TCQ rise_fall_error_r[dq_index*32+:32];
      end
      CMP_PAT_CD: begin
        addr_dec_to_mb_data <= #TCQ pat_match_cd_vld[dq_index*32+:32];
      end
      CMP_PAT_AB: begin
        addr_dec_to_mb_data <= #TCQ pat_match_ab_vld[dq_index*32+:32];
      end
      CAL_SEQ_CNT: begin
        addr_dec_to_mb_data <= #TCQ cal_seq_cnt;
      end
      CAL_SEQ_RD_CNT: begin
        addr_dec_to_mb_data <= #TCQ  cal_seq_rd_cnt;
      end
      RD_LATENCY_CNT: begin
        addr_dec_to_mb_data <= #TCQ  rd_latency_val_r[4:0];
      end
      SLIP_ON_WRDATA: begin
        addr_dec_to_mb_data <= #TCQ {31'h0,slip_on_wrdata_r};
      end
      CONFIG_PARAMS: begin
        addr_dec_to_mb_data <= #TCQ config_rd_data;
      end
      CAL_PQTR_BISC: begin
        addr_dec_to_mb_data <= #TCQ cal_pqtr_bisc_r[nibble_cnt*9 +:9];
      end
      CAL_NQTR_BISC: begin
        addr_dec_to_mb_data <= #TCQ cal_nqtr_bisc_r[nibble_cnt*9 +:9];
      end
      STATUS: begin
        addr_dec_to_mb_data <= #TCQ status_r;
      end
      CAL_TRAFFIC_CNT: begin
        addr_dec_to_mb_data <= #TCQ {{(32-DLY_CNTR_WIDTH){1'b0}}, delay_cntr_r2};
      end
      CAL_MARGIN_START: begin
        addr_dec_to_mb_data <= #TCQ {28'b0, win_start_r2};
      end
      CAL_TRAFFIC_ERR: begin
        addr_dec_to_mb_data <= #TCQ traffic_error_r[dq_index*32+:32];
      end
      default: begin
        addr_dec_to_mb_data  <= #TCQ 'b0;
        wrong_addr_access_rd <= #TCQ 1;
        $display("Micro Blaze is trying to read from an unknown address %H",io_address);
      end
    endcase
  end
end

always @ (posedge clk) begin
  if (rst) begin
    io_ready <= #TCQ 'b0;
  end else begin
    if (config_access)
      io_ready <= #TCQ  config_rd_val;
    else if (dbg_rd_en)
      io_ready <= #TCQ  io_addr_strobe_r2;
    else
      io_ready <= #TCQ  io_addr_strobe;
  end
end

always @(posedge clk)begin
  config_rd_val     <= #TCQ io_addr_strobe & ~io_write_strobe;
  io_addr_strobe_r1 <= #TCQ io_addr_strobe;
  io_addr_strobe_r2 <= #TCQ io_addr_strobe_r1;
end 
 
//Wrong address access by MB
assign wrong_addr_access = wrong_addr_access_wr | wrong_addr_access_rd ;

// Store the PQTR and NQTR values
always @(posedge clk)
begin
  cal_pqtr_bisc_r[nibble_cnt*9 +:9] <= #TCQ cal_pqtr_bisc_9_r;
  cal_nqtr_bisc_r[nibble_cnt*9 +:9] <= #TCQ cal_nqtr_bisc_9_r;
end

//*************************************************************//
//******************comparision logic for QDR******************//
//*************************************************************//

// Extracting rise and fall data from reads
genvar debug_i;
generate
  for (debug_i = 0; debug_i < DBITS; debug_i = debug_i + 1) begin
    always@(posedge clk) 
    begin
      dqin_rise_0_r[debug_i] <= #TCQ mcal_dqin[debug_i] ;
      dqin_fall_0_r[debug_i] <= #TCQ mcal_dqin[debug_i+DBITS] ;
      dqin_rise_1_r[debug_i] <= #TCQ mcal_dqin[debug_i+DBITS*2] ;
      dqin_fall_1_r[debug_i] <= #TCQ mcal_dqin[debug_i+DBITS*3] ;
    end
  end
endgenerate

// Registering the read data edge wise 
always@(posedge clk) 
begin
  dqin_rise_0_r1 <= #TCQ dqin_rise_0_r ;
  dqin_fall_0_r1 <= #TCQ dqin_fall_0_r ;
  dqin_rise_1_r1 <= #TCQ dqin_rise_1_r ;
  dqin_fall_1_r1 <= #TCQ dqin_fall_1_r ;
  dqin_rise_0_r2 <= #TCQ dqin_rise_0_r1 ;
  dqin_fall_0_r2 <= #TCQ dqin_fall_0_r1 ;
  dqin_rise_1_r2 <= #TCQ dqin_rise_1_r1 ;
  dqin_fall_1_r2 <= #TCQ dqin_fall_1_r1 ;
  dqin_rise_0_r3 <= #TCQ dqin_rise_0_r2 ;
  dqin_fall_0_r3 <= #TCQ dqin_fall_0_r2 ;
  dqin_rise_1_r3 <= #TCQ dqin_rise_1_r2 ;
  dqin_fall_1_r3 <= #TCQ dqin_fall_1_r2 ;
end 

// Comparing the read data between current and previous clock cycles
genvar cmp ;
generate
  for(cmp = 0 ; cmp < DBITS ; cmp = cmp + 1) begin

    // Comparing for read leveling
    always@(posedge clk) 
    begin
      if(dqin_rise_0_r2[cmp] != dqin_rise_0_r[cmp]) 
        err_rise_0_r[cmp] <= #TCQ 1'b1 ;
      else 
        err_rise_0_r[cmp] <= #TCQ 1'b0 ;
     if(dqin_fall_0_r2[cmp] != dqin_fall_0_r[cmp])
        err_fall_0_r[cmp] <= #TCQ 1'b1 ;
      else 
        err_fall_0_r[cmp] <= #TCQ 1'b0 ;
      if(dqin_rise_1_r2[cmp] != dqin_rise_1_r[cmp])
        err_rise_1_r[cmp] <= #TCQ 1'b1 ;
      else 
        err_rise_1_r[cmp] <= #TCQ 1'b0 ;
      if(dqin_fall_1_r2[cmp] != dqin_fall_1_r[cmp]) 
        err_fall_1_r[cmp] <= #TCQ 1'b1 ;
      else 
        err_fall_1_r[cmp] <= #TCQ 1'b0 ;
    end 

    //// Comparing for byte writes calibration
    //always@(posedge clk) 
    //begin
    //  if((dqin_rise_0_r3[cmp] != dqin_rise_0_r1[cmp]) ||
    //     (dqin_rise_0_r2[cmp] != dqin_rise_0_r[cmp]) )
    //    err_rise_0_bwcal_r[cmp] <= #TCQ 1'b1 ;
    //  else 
    //    err_rise_0_bwcal_r[cmp] <= #TCQ 1'b0 ;
    //  if((dqin_fall_0_r3[cmp] != dqin_fall_0_r1[cmp]) ||
    //     (dqin_fall_0_r2[cmp] != dqin_fall_0_r[cmp]) )
    //    err_fall_0_bwcal_r[cmp] <= #TCQ 1'b1 ;
    //  else 
    //    err_fall_0_bwcal_r[cmp] <= #TCQ 1'b0 ;
    //  if((dqin_rise_1_r3[cmp] != dqin_rise_1_r1[cmp]) ||
    //     (dqin_rise_1_r2[cmp] != dqin_rise_1_r[cmp]) )
    //    err_rise_1_bwcal_r[cmp] <= #TCQ 1'b1 ;
    //  else 
    //    err_rise_1_bwcal_r[cmp] <= #TCQ 1'b0 ;
    //  if((dqin_fall_1_r3[cmp] != dqin_fall_1_r1[cmp]) ||
    //     (dqin_fall_1_r2[cmp] != dqin_fall_1_r[cmp]) )
    //    err_fall_1_bwcal_r[cmp] <= #TCQ 1'b1 ;
    //  else 
    //    err_fall_1_bwcal_r[cmp] <= #TCQ 1'b0 ;
    //end 

    //****** Comparison for data patterns ******
    // For latency 2 the correct window will give pattern of either 0011 ,1100
    // or 1111,0000. For latency 2.5 the correct window will give pattern of 
    // either 0111,1000 or 0001,1110.
    // cal_pat_a_r[3:0] will be repeated for the whole datawidth for rise_0.
    // The same applies for others.

    always@(posedge clk)
    begin
      if((((dqin_rise_0_r[cmp] == cal_pat_a_r[cmp%4])    && 
           (dqin_rise_1_r[cmp] == cal_pat_a_r[8+cmp%4])  && 
           (dqin_rise_0_r1[cmp] == cal_pat_b_r[cmp%4])   &&
           (dqin_rise_1_r1[cmp] == cal_pat_b_r[8+cmp%4])  
          ) ||
          ((dqin_rise_0_r[cmp] == cal_pat_b_r[cmp%4])    && 
           (dqin_rise_1_r[cmp] == cal_pat_b_r[8+cmp%4])  && 
           (dqin_rise_0_r1[cmp] == cal_pat_a_r[cmp%4])   &&
           (dqin_rise_1_r1[cmp] == cal_pat_a_r[8+cmp%4])
          ) 
         ) && pat_match_ab_vld[cmp]
        )
        cmp_pat_ab_rise_r[cmp] <= #TCQ 1'b1 ;
      else 
        cmp_pat_ab_rise_r[cmp] <= #TCQ 1'b0 ;

      if((((dqin_fall_0_r[cmp] == cal_pat_a_r[4+cmp%4])  &&
           (dqin_fall_1_r[cmp] == cal_pat_a_r[12+cmp%4]) &&
           (dqin_fall_0_r1[cmp] == cal_pat_b_r[4+cmp%4]) &&
           (dqin_fall_1_r1[cmp] == cal_pat_b_r[12+cmp%4]) 
          ) ||
          ((dqin_fall_0_r[cmp] == cal_pat_b_r[4+cmp%4])  &&
           (dqin_fall_1_r[cmp] == cal_pat_b_r[12+cmp%4]) &&
           (dqin_fall_0_r1[cmp] == cal_pat_a_r[4+cmp%4]) &&
           (dqin_fall_1_r1[cmp] == cal_pat_a_r[12+cmp%4]) 
          )
         ) && pat_match_ab_vld[cmp]
        )
        cmp_pat_ab_fall_r[cmp] <= #TCQ 1'b1 ;
      else 
        cmp_pat_ab_fall_r[cmp] <= #TCQ 1'b0 ;

      cmp_pat_ab_r[cmp] <= #TCQ cmp_pat_ab_rise_r[cmp] && cmp_pat_ab_fall_r[cmp];
    end

    always@(posedge clk)
    begin
      if((((dqin_rise_0_r[cmp] == cal_pat_c_r[cmp%4])    && 
           (dqin_rise_1_r[cmp] == cal_pat_c_r[8+cmp%4])  && 
           (dqin_rise_0_r1[cmp] == cal_pat_d_r[cmp%4])   &&
           (dqin_rise_1_r1[cmp] == cal_pat_d_r[8+cmp%4])
          ) ||
          ((dqin_rise_0_r[cmp] == cal_pat_d_r[cmp%4])    && 
           (dqin_rise_1_r[cmp] == cal_pat_d_r[8+cmp%4])  && 
           (dqin_rise_0_r1[cmp] == cal_pat_c_r[cmp%4])   &&
           (dqin_rise_1_r1[cmp] == cal_pat_c_r[8+cmp%4])
          )
         ) && pat_match_cd_vld[cmp]
        )
        cmp_pat_cd_rise_r[cmp] <= #TCQ 1'b1 ;
      else 
        cmp_pat_cd_rise_r[cmp] <= #TCQ 1'b0;

      if((((dqin_fall_0_r[cmp] == cal_pat_c_r[4+cmp%4])  &&
           (dqin_fall_1_r[cmp] == cal_pat_c_r[12+cmp%4]) &&
           (dqin_fall_0_r1[cmp] == cal_pat_d_r[4+cmp%4]) &&
           (dqin_fall_1_r1[cmp] == cal_pat_d_r[12+cmp%4]) 
          ) ||
          ((dqin_fall_0_r[cmp] == cal_pat_d_r[4+cmp%4])  &&
           (dqin_fall_1_r[cmp] == cal_pat_d_r[12+cmp%4]) &&
           (dqin_fall_0_r1[cmp] == cal_pat_c_r[4+cmp%4]) &&
           (dqin_fall_1_r1[cmp] == cal_pat_c_r[12+cmp%4]) 
          )
         ) && pat_match_cd_vld[cmp]
        )
        cmp_pat_cd_fall_r[cmp] <= #TCQ 1'b1 ;
      else 
        cmp_pat_cd_fall_r[cmp] <= #TCQ 1'b0;

      cmp_pat_cd_r[cmp] <= #TCQ cmp_pat_cd_rise_r[cmp] && cmp_pat_cd_fall_r[cmp];
    end

    always@(posedge clk)
    begin
      if((dqin_rise_0_r2[cmp] == cal_pat_b_r[cmp%4]) && 
         (dqin_rise_0_r[cmp]  == cal_pat_b_r[cmp%4]) )
        cmp_rise_0_vld_r[cmp] <= #TCQ 1'b1 ;
      else 
        cmp_rise_0_vld_r[cmp] <= #TCQ 1'b0 ;
     if((dqin_fall_0_r2[cmp] == cal_pat_b_r[4+cmp%4]) &&
        (dqin_fall_0_r[cmp]  == cal_pat_b_r[4+cmp%4]) )
        cmp_fall_0_vld_r[cmp] <= #TCQ 1'b1 ;
      else 
        cmp_fall_0_vld_r[cmp] <= #TCQ 1'b0 ;
      if((dqin_rise_1_r2[cmp] == cal_pat_b_r[8+cmp%4]) &&
         (dqin_rise_1_r[cmp]  == cal_pat_b_r[8+cmp%4]) )
        cmp_rise_1_vld_r[cmp] <= #TCQ 1'b1 ;
      else 
        cmp_rise_1_vld_r[cmp] <= #TCQ 1'b0 ;
      if((dqin_fall_1_r2[cmp] == cal_pat_b_r[12+cmp%4]) &&
         (dqin_fall_1_r[cmp]  == cal_pat_b_r[12+cmp%4]) )
        cmp_fall_1_vld_r[cmp] <= #TCQ 1'b1 ;
      else 
        cmp_fall_1_vld_r[cmp] <= #TCQ 1'b0 ;
    end
    //always@(posedge clk)
    //begin
    //  if(((dqin_rise_0_r[cmp] == cal_pat_a_r[cmp%4])    && 
    //      (dqin_rise_0_r1[cmp] == cal_pat_b_r[cmp%4])   
    //     ) ||
    //     ((dqin_rise_0_r[cmp] == cal_pat_b_r[cmp%4])    && 
    //      (dqin_rise_0_r1[cmp] == cal_pat_a_r[cmp%4])   
    //     )
    //    )
    //    cmp_pat_ab_rise0_r[cmp] <= #TCQ 1'b1 ;
    //  else 
    //    cmp_pat_ab_rise0_r[cmp] <= #TCQ 1'b0 ;
    //end
    //always@(posedge clk)
    //begin
    //  if(((dqin_fall_0_r[cmp] == cal_pat_a_r[4+cmp%4])    && 
    //      (dqin_fall_0_r1[cmp] == cal_pat_b_r[4+cmp%4])   
    //     ) ||
    //     ((dqin_fall_0_r[cmp] == cal_pat_b_r[4+cmp%4])    && 
    //      (dqin_fall_0_r1[cmp] == cal_pat_a_r[4+cmp%4])   
    //     )
    //    )
    //    cmp_pat_ab_fall0_r[cmp] <= #TCQ 1'b1 ;
    //  else 
    //    cmp_pat_ab_fall0_r[cmp] <= #TCQ 1'b0 ;
    //end
  end
endgenerate

reg clr_err_r1 ;

// keep the error sticky until it is read from MB and cleared
// for timing split the error into different registers   
always@(posedge clk)
begin
  clr_err_r1 <= #TCQ clr_err_r ;

  if (rst) begin
    rise0_rise1_error_slip_r  <= #TCQ 'b0;
    fall0_fall1_error_slip_r  <= #TCQ 'b0;
    rise0_rise1_error_toggle_r <= #TCQ 'b0;
    fall0_fall1_error_toggle_r <= #TCQ 'b0;
    rise0_rise1_error_any_pat_r <= #TCQ 'b0;
    fall0_fall1_error_any_pat_r <= #TCQ 'b0;
    //rise0_rise1_error_bwcal_r <= #TCQ 'b0;
    //fall0_fall1_error_bwcal_r <= #TCQ 'b0;
    err_pat_abcd_r            <= #TCQ 'b0;
    //rise0_rise1_error_addrcal_r <= #TCQ 'b0;
  end 
  else if(clr_err_r|clr_err_r1) begin
    rise0_rise1_error_slip_r  <= #TCQ ~cmp_pat_ab_r;
    rise0_rise1_error_toggle_r <= #TCQ err_rise_1_r | err_rise_0_r;
    fall0_fall1_error_toggle_r <= #TCQ err_fall_1_r | err_fall_0_r;
    rise0_rise1_error_any_pat_r <= #TCQ ~cmp_pat_ab_rise_r & ~cmp_pat_cd_rise_r;
    fall0_fall1_error_any_pat_r <= #TCQ ~cmp_pat_ab_fall_r & ~cmp_pat_cd_fall_r;
    //rise0_rise1_error_bwcal_r <= #TCQ err_rise_1_bwcal_r | err_rise_0_bwcal_r;
    //fall0_fall1_error_bwcal_r <= #TCQ err_fall_1_bwcal_r | err_fall_0_bwcal_r;
    err_pat_abcd_r[DBITS-1:0] <= #TCQ ~cmp_pat_ab_r & ~cmp_pat_cd_r ;
    //rise0_rise1_error_addrcal_r <= #TCQ {CMP_WIDTH{!(&(cmp_pat_ab_rise0_r & cmp_pat_ab_fall0_r))}};
  end 
  else begin
    rise0_rise1_error_slip_r  <= #TCQ ~cmp_pat_ab_r |
                                      rise0_rise1_error_slip_r;
    rise0_rise1_error_toggle_r <= #TCQ err_rise_1_r | err_rise_0_r | 
                                      rise0_rise1_error_toggle_r;
    fall0_fall1_error_toggle_r <= #TCQ err_fall_1_r | err_fall_0_r | 
                                      fall0_fall1_error_toggle_r;
    rise0_rise1_error_any_pat_r <= #TCQ (~cmp_pat_ab_rise_r & ~cmp_pat_cd_rise_r) |
                                            rise0_rise1_error_any_pat_r;
    fall0_fall1_error_any_pat_r <= #TCQ (~cmp_pat_ab_fall_r & ~cmp_pat_cd_fall_r) |
                                            fall0_fall1_error_any_pat_r;
    //rise0_rise1_error_bwcal_r <= #TCQ err_rise_1_bwcal_r | err_rise_0_bwcal_r | 
    //                                  rise0_rise1_error_bwcal_r;
    //fall0_fall1_error_bwcal_r <= #TCQ err_fall_1_bwcal_r | err_fall_0_bwcal_r | 
    //                                  fall0_fall1_error_bwcal_r;
    err_pat_abcd_r[DBITS-1:0] <= #TCQ (~cmp_pat_ab_r & ~cmp_pat_cd_r) |
                                      err_pat_abcd_r[DBITS-1:0] ;
    //rise0_rise1_error_addrcal_r <= #TCQ {CMP_WIDTH{!(&(cmp_pat_ab_rise0_r & cmp_pat_ab_fall0_r))}} | rise0_rise1_error_addrcal_r;
  end
 
  // Assigning the error register based on the current calibration stage
  if (rst) begin
    rise0_rise1_error_r <= #TCQ 'b0;
    fall0_fall1_error_r <= #TCQ 'b0;
  end 
  else if(toggle_compare_r) begin
    rise0_rise1_error_r <= #TCQ rise0_rise1_error_toggle_r;
    fall0_fall1_error_r <= #TCQ fall0_fall1_error_toggle_r;
  end 
  //else if(bw_toggle_compare_r) begin
  //  rise0_rise1_error_r <= #TCQ rise0_rise1_error_bwcal_r;
  //  fall0_fall1_error_r <= #TCQ fall0_fall1_error_bwcal_r;
  //end
  else if (ab_pat_compare_r) begin 
    rise0_rise1_error_r <= #TCQ rd_data_match_r1;
    fall0_fall1_error_r <= #TCQ 'b0;
  end
  //else if (fix_pat_compare_r|addr_cal_compare_r) begin 
  //  //rise0_rise1_error_r <= #TCQ err_pat_abcd_r;
  //  rise0_rise1_error_r <= #TCQ rise0_rise1_error_any_pat_r | fall0_fall1_error_any_pat_r;
  //  fall0_fall1_error_r <= #TCQ 'b0;
  //end
  //else if (addr_cal_compare_r) begin 
  //  rise0_rise1_error_r <= #TCQ rise0_rise1_error_addrcal_r;
  //  fall0_fall1_error_r <= #TCQ 'b0;
  //end
  else if (pattern_compare_r) begin 
    rise0_rise1_error_r <= #TCQ rise0_rise1_error_any_pat_r;
    fall0_fall1_error_r <= #TCQ fall0_fall1_error_any_pat_r;
  end
  else begin 
    rise0_rise1_error_r <= #TCQ rise0_rise1_error_slip_r;
    fall0_fall1_error_r <= #TCQ fall0_fall1_error_slip_r;
  end
end

always @(posedge clk) begin
  if (pattern_compare_r)
    rise_fall_error_r <= err_pat_abcd_r;
  else  
    rise_fall_error_r <= rise0_rise1_error_r | fall0_fall1_error_r;
end

//**************************************
//****** Read enable generation ******//
//*************************************

// Matching for read data validity
// Stops matching when at least one bit is valid on all edges
always@(posedge clk) begin
  if (rst || toggle_compare_r)
    rd_data_match_r <= #TCQ 'b0;
  else if (~|rd_data_match_r && ab_pat_compare_r && rd_cmd_r)
      rd_data_match_r <= #TCQ (cmp_fall_1_vld_r & cmp_fall_0_vld_r &
                              cmp_rise_1_vld_r & cmp_rise_0_vld_r);
end
always @(posedge clk)
  rd_data_match_r1 <= #TCQ rd_data_match_r;

// Determining whether some of the bits are matched
always @(posedge clk) begin
  if(rst || toggle_compare_r)
    few_bits_matched_r <= #TCQ 1'b0;
  else if (|rd_data_match_r && ab_pat_compare_r)
    few_bits_matched_r <= #TCQ 1'b1;
end

always @(posedge clk) begin
  few_bits_matched_r1    <= #TCQ few_bits_matched_r;
  fabric_slip_val_r      <= #TCQ fabric_slip_val;
  few_bits_not_matched_r <= #TCQ ~(&rd_data_match_r1); 
end

// Determining the bits that require fabric bit slip and adding extra
// stage of flops to the early bits due to INFIFO latency differences.
// rd_data_match_r1 has the information on the bits that matched.
always @(posedge clk) begin
  if(rst || toggle_compare_r)
    fabric_slip_val <= #TCQ 'b0;
  else if (few_bits_not_matched_r && few_bits_matched_r1)
    fabric_slip_val <= #TCQ rd_data_match_r1;
end

// Check whether we need to add one more cycle to read latency
always @(posedge clk) begin
  if(rst)
    single_stg_fabslip_r <= #TCQ 'b0;
  else 
    single_stg_fabslip_r <= #TCQ |fabric_slip_val;
end

genvar bit_i;
generate
  for(bit_i = 0; bit_i < DBITS; bit_i = bit_i+1) begin : slip_for_bit
    always @(posedge clk) begin
      if (rst)
        fabric_slip_r[bit_i*2+:2] <= #TCQ 2'b0;
      else if (~fabric_slip_val_r[bit_i] && fabric_slip_val[bit_i])
        fabric_slip_r[bit_i*2+:2] <= #TCQ fabric_slip_r[bit_i*2+:2]+1;
    end
  end
endgenerate

// Determining the first read
always @(posedge clk) begin
  rd_cmd_r       <= #TCQ |({4{cal_addr_r[ABITS-1:1]}});
  rd_cmd_r1      <= #TCQ rd_cmd_r;
  first_rd_cmd_r <= #TCQ rd_cmd_r & ~rd_cmd_r1;
end

// latency_counter_r will be reset when the first read is issued and
// incremented thereon
always @(posedge clk) begin
  if(rst) begin
    latency_counter_r <= #TCQ 'b1;
  end else if (~few_bits_matched_r) begin 
    if (first_rd_cmd_r)
      latency_counter_r <= #TCQ 'b1;
    else
      latency_counter_r <= #TCQ latency_counter_r + 1;
  end
end

always @(posedge clk)
  rd_latency_val_r <= #TCQ latency_counter_r;

//***************************************
//********** Bitslip logic ************//
//***************************************
// Initial slip value for the read data bus. For read latency of 2.5,
// the entire read bus must be added 1 bit slip
assign slip_init_value = (CAL_MODE == "SKIP")
                        ? ((MEM_LATENCY == "2.5") ? ((SIM_MODE=="BFM") ? 2'b10
                                                                       : 2'b01)
			                          : ((SIM_MODE=="BFM") ? 2'b11
                                                                       : 2'b10))
                        : ((MEM_LATENCY == "2.5") ?  2'b01 : 2'b00); 

//Expand the width of the register for 36-bit design
always @ (posedge clk) begin
  if (rst) begin
    cal_rd_data_slip_r <= #TCQ 'b0;
    cal_wr_data_slip_r <= #TCQ 'b0;
  end else begin
    cal_rd_data_slip_r[dq_index*32 +:32] <= #TCQ cal_rd_data_slip_32_r;
    cal_wr_data_slip_r[dq_index*32 +:32] <= #TCQ cal_wr_data_slip_32_r;
  end
end

//Calculating the bit slip values for write, read and address buses based on
//the info provided by MB
integer slip_i;
generate
  always @(posedge clk) begin
    for(slip_i = 0; slip_i < DBITS ; slip_i = slip_i + 1) begin: gen_rd_slip
      if(rst)
        rd_data_slip_r[slip_i*2 +:2] <= #TCQ slip_init_value;
      else 
        rd_data_slip_r[slip_i*2 +:2] <= #TCQ rd_data_slip_r[slip_i*2 +:2] + 
                                             cal_rd_data_slip_r[slip_i];
    end
  end
  always @(posedge clk) begin
    for(slip_i = 0; slip_i < DBITS ; slip_i = slip_i + 1) begin: gen_wr_slip
      if(rst)
        wr_data_slip_r[slip_i*2 +:2] <= #TCQ 2'd0 ;
      else 
        wr_data_slip_r[slip_i*2 +:2] <= #TCQ wr_data_slip_r[slip_i*2 +:2] + 
                                             cal_wr_data_slip_r[slip_i];
    end
  end
  always @(posedge clk) begin
    for(slip_i = 0; slip_i < DBYTES ; slip_i = slip_i + 1) begin: gen_bws_slip
      if(rst)
        wr_bws_slip_r[slip_i*2 +:2] <= #TCQ 2'd0 ;
      else 
        wr_bws_slip_r[slip_i*2 +:2] <= #TCQ wr_bws_slip_r[slip_i*2 +:2] + 
                                            cal_wr_bws_slip_r[slip_i];
    end
  end
endgenerate     

always @(posedge clk) begin
  if(rst) begin
     if (CAL_MODE == "SKIP" && BURST_LEN == 2) 
        addr_slip_r <= #TCQ 3'b100;
     else
        addr_slip_r <= #TCQ 3'b011 ;
  end else begin
    addr_slip_r <= #TCQ addr_slip_r + cal_addr_slip_r[1:0];
  end
end

//Conveys whether bit slip has been added on write path. This will be used 
//during byte writes calibration
always @(posedge clk) begin
  if(rst)
    slip_on_wrdata_r <= #TCQ 0 ;
  else if (cal_wr_data_slip_r > 0)
    slip_on_wrdata_r <= #TCQ 1 ;
end

//***************************************
//*************CMD Processor ************
//*************************************** 

// Signals involving command generation such as cmd counter, inter cmd delay
always @ (posedge clk)
begin
  if (rst) begin
    cmd_cnt_dec_r  <= #TCQ 'b0;
    intr_cmd_dly_r <= #TCQ 'b0;
  end else begin

    //cmd_cnt_dec_r is set when delay between 2 cmds is same as delay set by MB
    if(cal_seq_cnt != 'b0) begin
      //Generate commands only from A-channel
      if(~cal_seq_r) begin
        cmd_cnt_dec_r  <= #TCQ (cal_seq_a_a_dly_r == 0 ) ? 
                               ((cal_seq_cnt >1) ? 1 :0 ) : 
                               ((intr_cmd_dly_r == cal_seq_a_a_dly_r) ? 1 : 0) ;
        intr_cmd_dly_r <= #TCQ (intr_cmd_dly_r == cal_seq_a_a_dly_r) ?
                               0 : intr_cmd_dly_r + 'b1;
      end
      //Generate commands alternately from A & B channels
      else begin
        //Generate commands from B-channel when a_b_cmd_sel is 1
        if (a_b_cmd_sel) begin
          cmd_cnt_dec_r  <= #TCQ  (cal_seq_a_b_dly_r == 0 ) ? 
                                  ((cal_seq_cnt > 1) ? 1 :0 ) : 
                                  ((intr_cmd_dly_r == cal_seq_a_b_dly_r) ? 1:0);
          intr_cmd_dly_r <= #TCQ (intr_cmd_dly_r == cal_seq_a_b_dly_r) ? 
                                 0 : intr_cmd_dly_r + 'b1;
        end
        //Generate commands from A-channel when a_b_cmd_sel is 0
        else begin
          cmd_cnt_dec_r  <= #TCQ  (cal_seq_b_a_dly_r == 0 ) ? 
                                  ((cal_seq_cnt > 1) ? 1 :0 ) : 
                                  (intr_cmd_dly_r == cal_seq_b_a_dly_r);
          intr_cmd_dly_r <= #TCQ (intr_cmd_dly_r == cal_seq_b_a_dly_r) ?
                                 0 : intr_cmd_dly_r + 'b1;
        end
      end
    end else begin
      cmd_cnt_dec_r <= 'b0;
      intr_cmd_dly_r <= 'b0;
    end
  end  
end  

//cal_seq_cnt decreases whenever cmd is issued
//clear cal_seq_cnt when cnt_clr is issued
always @ (posedge clk)
begin    
  if(cmd_cnt_reg_sel) begin
    cal_seq_cnt <= #TCQ mb_to_addr_dec_data[7:0];
    cnt_clr     <= #TCQ 'b0;
  end else if (cnt_clr_access) begin
    cnt_clr <= #TCQ mb_to_addr_dec_data[0];
  end else if (cnt_clr) begin
    cal_seq_cnt <= #TCQ 'b0;
  end else if (cal_seq_cnt == 250) begin
    cal_seq_cnt <= #TCQ 255;
  end else begin
    cal_seq_cnt <= #TCQ cmd_cnt_dec_r ? cal_seq_cnt - 'b1 : cal_seq_cnt;
  end
end

//rd_cnt decreases whenenver read is issued
//clear rd_cnt when cnt_clr is issued
always @ (posedge clk)
begin    
  if (cal_cnt_rd)begin
    cal_seq_rd_cnt <= #TCQ mb_to_addr_dec_data[15:0];
  end else if (cnt_clr) begin
    cal_seq_rd_cnt <= #TCQ 'b0;        
  end else begin
    cal_seq_rd_cnt <= #TCQ (cal_seq_rd_cnt > 0) ? (cal_seq_rd_cnt-1) :
                                                   cal_seq_rd_cnt ;
  end
end

//Command selection between A and B channels
//cmd_cnt_dec_r is used when inter command deley is more than zero
generate
   always@(posedge clk)
   begin
      if(BURST_LEN == 4)
      begin: BL4_cmd_addr_gen
         if((cal_seq_cnt != 0) & cmd_cnt_dec_r) begin
           cal_wps_n_r <= #TCQ  a_b_cmd_sel ? cal_wps_b_r : cal_wps_a_r;
           cal_rps_n_r <= #TCQ  a_b_cmd_sel ? cal_rps_b_r : cal_rps_a_r;
         end else begin
           cal_wps_n_r <= #TCQ  {4{1'b1}} ;
           cal_rps_n_r <= #TCQ  {4{1'b1}} ;
         end
         cal_doff_r  <= #TCQ cal_doff_a_r;
         for(idx = 0 ; idx < ABITS ; idx = idx + 1) begin
           if (a_b_cmd_sel)
             cal_addr_r[idx*4 +:4] <= #TCQ {4{cal_addr_b_r[idx]}};
           else
             cal_addr_r[idx*4 +:4] <= #TCQ {4{cal_addr_a_r[idx]}};
         end
      end // BL4_cmd_addr_gen_end
      else
      begin: BL2_cmd_addr_gen
         if((cal_seq_cnt != 0) & cmd_cnt_dec_r) begin
           cal_wps_n_i <= #TCQ  a_b_cmd_sel ? cal_wps_b_r : cal_wps_a_r;
           cal_rps_n_i <= #TCQ  a_b_cmd_sel ? cal_rps_b_r : cal_rps_a_r;
         end else begin
           cal_wps_n_i <= #TCQ  {4{1'b1}} ;
           cal_rps_n_i <= #TCQ  {4{1'b1}} ;
         end
         cal_doff_i  <= #TCQ cal_doff_a_r;

         cal_wps_n_r <= cal_wps_n_i;
         cal_rps_n_r <= cal_rps_n_i;
         cal_doff_r  <= cal_doff_i;    

         for(idx = 0 ; idx < ABITS ; idx = idx + 1) begin
            if (a_b_cmd_sel)
            begin
               cal_addr_i[idx]         <= #TCQ cal_addr_b_r[idx];
               cal_addr_i[idx+ABITS]   <= #TCQ cal_addr_b_r[idx];
               cal_addr_i[idx+2*ABITS] <= #TCQ cal_addr_b_r[idx];
               cal_addr_i[idx+3*ABITS] <= #TCQ cal_addr_b_r[idx];
            end
            else
            begin
               cal_addr_i[idx]         <= #TCQ cal_addr_a_r[idx];
               cal_addr_i[idx+ABITS]   <= #TCQ cal_addr_a_r[idx];
               cal_addr_i[idx+2*ABITS] <= #TCQ cal_addr_a_r[idx];
               cal_addr_i[idx+3*ABITS] <= #TCQ cal_addr_a_r[idx];
            end
         end
         if(addr_cal_compare_r == 1'b0)
         begin
            cal_addr_r[1*ABITS-1 : 0*ABITS] <= #TCQ cal_addr_i[1*ABITS-1:0*ABITS] ;
            cal_addr_r[2*ABITS-1 : 1*ABITS] <= #TCQ cal_addr_i[2*ABITS-1:1*ABITS] ;
            cal_addr_r[3*ABITS-1 : 2*ABITS] <= #TCQ cal_addr_i[3*ABITS-1:2*ABITS] + 1;
            cal_addr_r[4*ABITS-1 : 3*ABITS] <= #TCQ cal_addr_i[4*ABITS-1:3*ABITS] + 1;
         end
         else
         begin
            cal_addr_r[1*ABITS-1 : 0*ABITS] <= #TCQ cal_addr_i[1*ABITS-1:0*ABITS] | rd_addr_cal_ch0_en << cal_addr_bit_cnt;
            cal_addr_r[2*ABITS-1 : 1*ABITS] <= #TCQ cal_addr_i[2*ABITS-1:1*ABITS] | wr_addr_cal_ch0_en << cal_addr_bit_cnt;
            cal_addr_r[3*ABITS-1 : 2*ABITS] <= #TCQ cal_addr_i[3*ABITS-1:2*ABITS] | rd_addr_cal_ch1_en << cal_addr_bit_cnt;
            cal_addr_r[4*ABITS-1 : 3*ABITS] <= #TCQ cal_addr_i[4*ABITS-1:3*ABITS] | wr_addr_cal_ch1_en << cal_addr_bit_cnt;
         end
      end //BL2_cmd_addr_gen end
   end
endgenerate

//Data selection between A & B channels
generate 
  always @ (posedge clk) 
  begin
    if(~a_b_cmd_sel) begin 
      cal_dqout_r[0*(DBITS) +:(DBITS)] <= {(DBYTES+1)*2{cal_dqout_a_r[3 :0 ]}} ;
      cal_dqout_r[1*(DBITS) +:(DBITS)] <= {(DBYTES+1)*2{cal_dqout_a_r[7 :4 ]}} ;
      cal_dqout_r[2*(DBITS) +:(DBITS)] <= {(DBYTES+1)*2{cal_dqout_a_r[11:8 ]}} ;
      cal_dqout_r[3*(DBITS) +:(DBITS)] <= {(DBYTES+1)*2{cal_dqout_a_r[15:12]}} ;
      cal_bws_n_r[0*DBYTES +:DBYTES]   <= {DBYTES{cal_dmout_a_r[0]}} ;
      cal_bws_n_r[1*DBYTES +:DBYTES]   <= {DBYTES{cal_dmout_a_r[1]}} ;
      cal_bws_n_r[2*DBYTES +:DBYTES]   <= {DBYTES{cal_dmout_a_r[2]}} ;
      cal_bws_n_r[3*DBYTES +:DBYTES]   <= {DBYTES{cal_dmout_a_r[3]}} ;
    end
    else begin
      cal_dqout_r[0*(DBITS) +:(DBITS)] <= {(DBYTES+1)*2{cal_dqout_b_r[3 :0 ]}} ;
      cal_dqout_r[1*(DBITS) +:(DBITS)] <= {(DBYTES+1)*2{cal_dqout_b_r[7 :4 ]}} ;
      cal_dqout_r[2*(DBITS) +:(DBITS)] <= {(DBYTES+1)*2{cal_dqout_b_r[11:8 ]}} ;
      cal_dqout_r[3*(DBITS) +:(DBITS)] <= {(DBYTES+1)*2{cal_dqout_b_r[15:12]}} ;
      cal_bws_n_r[0*DBYTES +:DBYTES]   <= {DBYTES{cal_dmout_b_r[0]}} ;
      cal_bws_n_r[1*DBYTES +:DBYTES]   <= {DBYTES{cal_dmout_b_r[1]}} ;
      cal_bws_n_r[2*DBYTES +:DBYTES]   <= {DBYTES{cal_dmout_b_r[2]}} ;
      cal_bws_n_r[3*DBYTES +:DBYTES]   <= {DBYTES{cal_dmout_b_r[3]}} ;
    end
  end
endgenerate

/////////////////////////////////////////////////////
// Display messages to convey the calibration status
/////////////////////////////////////////////////////

// Calibration PASSES
always@(posedge status_r[0]) begin
  $display("===============================");
  $display(" Read leveling stage complete");
  $display("===============================");
end
 
always@(posedge status_r[1]) begin
  $display("=====================================");
  $display(" Read leveling sanity stage complete");
  $display("=====================================");
end
 
always@(posedge status_r[2]) begin
  $display("====================================");
  $display(" Address calibration stage complete");
  $display("====================================");
end
 
always@(posedge status_r[3]) begin
  $display("===========================================");
  $display(" Address calibration sanity stage complete");
  $display("===========================================");
end
 
always@(posedge status_r[4]) begin
  $display("=====================================");
  $display(" Write data centering stage complete");
  $display("=====================================");
end
 
always@(posedge status_r[5]) begin
  $display("==================================");
  $display(" Write data sanity stage complete");
  $display("==================================");
end
 
always@(posedge status_r[6]) begin
  $display("====================================");
  $display(" Write data bit slip stage complete");
  $display("====================================");
end
 
always@(posedge status_r[7]) begin
  $display("====================================");
  $display(" Read data bit slip stage complete");
  $display("====================================");
end
 
always@(posedge status_r[8]) begin
  $display("======================================");
  $display(" Byte writes centering stage complete");
  $display("======================================");
end
 
always@(posedge status_r[9]) begin
  $display("===================================");
  $display(" Byte writes sanity stage complete");
  $display("===================================");
end
 
always@(posedge status_r[10]) begin
  $display("=====================================");
  $display(" Byte writes bit slip stage complete");
  $display("=====================================");
end
 
always@(posedge status_r[11]) begin
  $display("=============================");
  $display(" Read valid stage complete");
  $display("=============================");
end

always@(posedge status_r[12]) begin
  $display("==================================");
  $display(" Read valid sanity stage complete");
  $display("==================================");
end


// Calibration FAILs
assign cal_failed = (|status_r[31:16]);

always @(posedge cal_failed)
begin
  $display("=================================================");

  if (status_r[16])
    $display(" Calibration Failed at Read leveling stage");
  else if (status_r[17])
    $display(" Calibration Failed at Read leveling sanity stage");
  else if (status_r[18])
    $display(" Calibration Failed at Address calibration stage");
  else if (status_r[19])
    $display(" Calibration Failed at Address calibration sanity stage");
  else if (status_r[20])
    $display(" Calibration Failed at Write data centering stage");
  else if (status_r[21])
    $display(" Calibration Failed at Write data sanity stage");
  else if (status_r[22])
    $display(" Calibration Failed at Write data bit slip stage");
  else if (status_r[23])
    $display(" Calibration Failed at Read data bit slip stage");
  else if (status_r[24])
    $display(" Calibration Failed at Byte writes centering stage");
  else if (status_r[25])
    $display(" Calibration Failed at Byte writes sanity stage");
  else if (status_r[26])
    $display(" Calibration Failed at Byte writes bit slip stage");
  else if (status_r[27])
    $display(" Calibration Failed at Read valid stage");
  else
    $display(" Calibration Failed at Read valid sanity stage");

  $display("=================================================");
  $finish();
end

endmodule


/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//------------------------------------------------------------------------------


//------{
`timescale 1fs/1fs
`default_nettype none
(* DowngradeIPIdentifiedWarnings="yes" *)
module gtfwizard_mac_top # (
  parameter [0:0] AEN_QPLL0_FBDIV = 1'b1,
  parameter [0:0] AEN_QPLL1_FBDIV = 1'b1,
  parameter [0:0] AEN_SDM0TOGGLE = 1'b0,
  parameter [0:0] AEN_SDM1TOGGLE = 1'b0,
  parameter [0:0] A_SDM0TOGGLE = 1'b0,
  parameter [8:0] A_SDM1DATA_HIGH = 9'b000000000,
  parameter [15:0] A_SDM1DATA_LOW = 16'b0000000000000000,
  parameter [0:0] A_SDM1TOGGLE = 1'b0,
  parameter [15:0] BIAS_CFG0 = 16'h0000,
  parameter [15:0] BIAS_CFG1 = 16'h0000,
  parameter [15:0] BIAS_CFG2 = 16'h0000,
  parameter [15:0] BIAS_CFG3 = 16'h0000,
  parameter [15:0] BIAS_CFG4 = 16'h0000,
  parameter [15:0] BIAS_CFG_RSVD = 16'h0000,
  parameter [15:0] COMMON_CFG0 = 16'h0000,
  parameter [15:0] COMMON_CFG1 = 16'h0000,
  parameter [15:0] POR_CFG = 16'h0000,
  parameter [15:0] PPF0_CFG = 16'h0F00,
  parameter [15:0] PPF1_CFG = 16'h0F00,
  parameter QPLL0CLKOUT_RATE = "FULL",
  parameter [15:0] QPLL0_CFG0 = 16'h391C,
  parameter [15:0] QPLL0_CFG1 = 16'h0000,
  parameter [15:0] QPLL0_CFG1_G3 = 16'h0020,
  parameter [15:0] QPLL0_CFG2 = 16'h0F80,
  parameter [15:0] QPLL0_CFG2_G3 = 16'h0F80,
  parameter [15:0] QPLL0_CFG3 = 16'h0120,
  parameter [15:0] QPLL0_CFG4 = 16'h0002,
  parameter [9:0] QPLL0_CP = 10'b0000011111,
  parameter [9:0] QPLL0_CP_G3 = 10'b0000011111,
  parameter integer QPLL0_FBDIV = 66,
  parameter integer QPLL0_FBDIV_G3 = 80,
  parameter [15:0] QPLL0_INIT_CFG0 = 16'h0000,
  parameter [7:0] QPLL0_INIT_CFG1 = 8'h00,
  parameter [15:0] QPLL0_LOCK_CFG = 16'h01E8,
  parameter [15:0] QPLL0_LOCK_CFG_G3 = 16'h21E8,
  parameter [9:0] QPLL0_LPF = 10'b1011111111,
  parameter [9:0] QPLL0_LPF_G3 = 10'b1111111111,
  parameter [0:0] QPLL0_PCI_EN = 1'b0,
  parameter [0:0] QPLL0_RATE_SW_USE_DRP = 1'b0,
  parameter integer QPLL0_REFCLK_DIV = 1,
  parameter [15:0] QPLL0_SDM_CFG0 = 16'h0040,
  parameter [15:0] QPLL0_SDM_CFG1 = 16'h0000,
  parameter [15:0] QPLL0_SDM_CFG2 = 16'h0000,
  parameter QPLL1CLKOUT_RATE = "FULL",
  parameter [15:0] QPLL1_CFG0 = 16'h691C,
  parameter [15:0] QPLL1_CFG1 = 16'h0020,
  parameter [15:0] QPLL1_CFG1_G3 = 16'h0020,
  parameter [15:0] QPLL1_CFG2 = 16'h0F80,
  parameter [15:0] QPLL1_CFG2_G3 = 16'h0F80,
  parameter [15:0] QPLL1_CFG3 = 16'h0120,
  parameter [15:0] QPLL1_CFG4 = 16'h0002,
  parameter [9:0] QPLL1_CP = 10'b0000011111,
  parameter [9:0] QPLL1_CP_G3 = 10'b0000011111,
  parameter integer QPLL1_FBDIV = 66,
  parameter integer QPLL1_FBDIV_G3 = 80,
  parameter [15:0] QPLL1_INIT_CFG0 = 16'h0000,
  parameter [7:0] QPLL1_INIT_CFG1 = 8'h00,
  parameter [15:0] QPLL1_LOCK_CFG = 16'h01E8,
  parameter [15:0] QPLL1_LOCK_CFG_G3 = 16'h21E8,
  parameter [9:0] QPLL1_LPF = 10'b1011111111,
  parameter [9:0] QPLL1_LPF_G3 = 10'b1111111111,
  parameter [0:0] QPLL1_PCI_EN = 1'b0,
  parameter [0:0] QPLL1_RATE_SW_USE_DRP = 1'b0,
  parameter integer QPLL1_REFCLK_DIV = 1,
  parameter [15:0] QPLL1_SDM_CFG0 = 16'h0000,
  parameter [15:0] QPLL1_SDM_CFG1 = 16'h0000,
  parameter [15:0] QPLL1_SDM_CFG2 = 16'h0000,
  parameter [15:0] RSVD_ATTR0 = 16'h0000,
  parameter [15:0] RSVD_ATTR1 = 16'h0000,
  parameter [15:0] RSVD_ATTR2 = 16'h0000,
  parameter [15:0] RSVD_ATTR3 = 16'h0000,
  parameter [1:0] RXRECCLKOUT0_SEL = 2'b00,
  parameter [1:0] RXRECCLKOUT1_SEL = 2'b00,
  parameter [0:0] SARC_ENB = 1'b0,
  parameter [0:0] SARC_SEL = 1'b0,
  parameter [15:0] SDM0INITSEED0_0 = 16'b0000000000000000,
  parameter [8:0] SDM0INITSEED0_1 = 9'b000000000,
  parameter [15:0] SDM1INITSEED0_0 = 16'b0000000000000000,
  parameter [8:0] SDM1INITSEED0_1 = 9'b000000000,
  parameter [0:0] ACJTAG_DEBUG_MODE = 1'b0,
  parameter [0:0] ACJTAG_MODE = 1'b0,
  parameter [0:0] ACJTAG_RESET = 1'b0,
  parameter [15:0] ADAPT_CFG0 = 16'h9200,
  parameter [15:0] ADAPT_CFG1 = 16'h801C,
  parameter [15:0] ADAPT_CFG2 = 16'h0000,
  parameter [0:0] A_RXOSCALRESET = 1'b0,
  parameter [0:0] A_RXPROGDIVRESET = 1'b0,
  parameter [0:0] A_RXTERMINATION = 1'b1,
  parameter [4:0] A_TXDIFFCTRL = 5'b01100,
  parameter [0:0] A_TXPROGDIVRESET = 1'b0,
  parameter CBCC_DATA_SOURCE_SEL = "DECODED",
  parameter [0:0] CDR_SWAP_MODE_EN = 1'b0,
  parameter [0:0] CFOK_PWRSVE_EN = 1'b1,
  parameter [15:0] CH_HSPMUX = 16'h2424,
  parameter [15:0] CKCAL1_CFG_0 = 16'b1100000011000000,
  parameter [15:0] CKCAL1_CFG_1 = 16'b0101000011000000,
  parameter [15:0] CKCAL1_CFG_2 = 16'b0000000000000000,
  parameter [15:0] CKCAL1_CFG_3 = 16'b0000000000000000,
  parameter [15:0] CKCAL2_CFG_0 = 16'b1100000011000000,
  parameter [15:0] CKCAL2_CFG_1 = 16'b1000000011000000,
  parameter [15:0] CKCAL2_CFG_2 = 16'b0000000000000000,
  parameter [15:0] CKCAL2_CFG_3 = 16'b0000000000000000,
  parameter [15:0] CKCAL2_CFG_4 = 16'b0000000000000000,
  parameter [15:0] CPLL_CFG0 = 16'h01FA,
  parameter [15:0] CPLL_CFG1 = 16'h24A9,
  parameter [15:0] CPLL_CFG2 = 16'h6807,
  parameter [15:0] CPLL_CFG3 = 16'h0000,
  parameter integer CPLL_FBDIV = 4,
  parameter integer CPLL_FBDIV_45 = 4,
  parameter [15:0] CPLL_INIT_CFG0 = 16'h001E,
  parameter [15:0] CPLL_LOCK_CFG = 16'h01E8,
  parameter integer CPLL_REFCLK_DIV = 1,
  parameter [2:0] CTLE3_OCAP_EXT_CTRL = 3'b000,
  parameter [0:0] CTLE3_OCAP_EXT_EN = 1'b0,
  parameter [1:0] DDI_CTRL = 2'b00,
  parameter integer DDI_REALIGN_WAIT = 15,
  parameter [0:0] DELAY_ELEC = 1'b0,
  parameter [9:0] DMONITOR_CFG0 = 10'h000,
  parameter [7:0] DMONITOR_CFG1 = 8'h00,
  parameter [0:0] ES_CLK_PHASE_SEL = 1'b0,
  parameter [5:0] ES_CONTROL = 6'b000000,
  parameter ES_ERRDET_EN = "FALSE",
  parameter ES_EYE_SCAN_EN = "FALSE",
  parameter [11:0] ES_HORZ_OFFSET = 12'h800,
  parameter [4:0] ES_PRESCALE = 5'b00000,
  parameter [15:0] ES_QUALIFIER0 = 16'h0000,
  parameter [15:0] ES_QUALIFIER1 = 16'h0000,
  parameter [15:0] ES_QUALIFIER2 = 16'h0000,
  parameter [15:0] ES_QUALIFIER3 = 16'h0000,
  parameter [15:0] ES_QUALIFIER4 = 16'h0000,
  parameter [15:0] ES_QUALIFIER5 = 16'h0000,
  parameter [15:0] ES_QUALIFIER6 = 16'h0000,
  parameter [15:0] ES_QUALIFIER7 = 16'h0000,
  parameter [15:0] ES_QUALIFIER8 = 16'h0000,
  parameter [15:0] ES_QUALIFIER9 = 16'h0000,
  parameter [15:0] ES_QUAL_MASK0 = 16'h0000,
  parameter [15:0] ES_QUAL_MASK1 = 16'h0000,
  parameter [15:0] ES_QUAL_MASK2 = 16'h0000,
  parameter [15:0] ES_QUAL_MASK3 = 16'h0000,
  parameter [15:0] ES_QUAL_MASK4 = 16'h0000,
  parameter [15:0] ES_QUAL_MASK5 = 16'h0000,
  parameter [15:0] ES_QUAL_MASK6 = 16'h0000,
  parameter [15:0] ES_QUAL_MASK7 = 16'h0000,
  parameter [15:0] ES_QUAL_MASK8 = 16'h0000,
  parameter [15:0] ES_QUAL_MASK9 = 16'h0000,
  parameter [15:0] ES_SDATA_MASK0 = 16'h0000,
  parameter [15:0] ES_SDATA_MASK1 = 16'h0000,
  parameter [15:0] ES_SDATA_MASK2 = 16'h0000,
  parameter [15:0] ES_SDATA_MASK3 = 16'h0000,
  parameter [15:0] ES_SDATA_MASK4 = 16'h0000,
  parameter [15:0] ES_SDATA_MASK5 = 16'h0000,
  parameter [15:0] ES_SDATA_MASK6 = 16'h0000,
  parameter [15:0] ES_SDATA_MASK7 = 16'h0000,
  parameter [15:0] ES_SDATA_MASK8 = 16'h0000,
  parameter [15:0] ES_SDATA_MASK9 = 16'h0000,
  parameter integer EYESCAN_VP_RANGE = 0,
  parameter [0:0] EYE_SCAN_SWAP_EN = 1'b0,
  parameter [3:0] FTS_DESKEW_SEQ_ENABLE = 4'b1111,
  parameter [3:0] FTS_LANE_DESKEW_CFG = 4'b1111,
  parameter FTS_LANE_DESKEW_EN = "FALSE",
  parameter [4:0] GEARBOX_MODE = 5'b00000,
  parameter [0:0] ISCAN_CK_PH_SEL2 = 1'b0,
  parameter [0:0] LOCAL_MASTER = 1'b0,
  parameter integer LPBK_BIAS_CTRL = 4,
  parameter [0:0] LPBK_EN_RCAL_B = 1'b0,
  parameter [3:0] LPBK_EXT_RCAL = 4'b0000,
  parameter integer LPBK_IND_CTRL0 = 5,
  parameter integer LPBK_IND_CTRL1 = 5,
  parameter integer LPBK_IND_CTRL2 = 5,
  parameter integer LPBK_RG_CTRL = 2,
  parameter [15:0] MAC_CFG0 = 16'h0000,
  parameter [15:0] MAC_CFG1 = 16'h0000,
  parameter [15:0] MAC_CFG10 = 16'h00BB,
  parameter [15:0] MAC_CFG11 = 16'h0040,
  parameter [15:0] MAC_CFG12 = 16'h2580,
  parameter [15:0] MAC_CFG13 = 16'h0001,
  parameter [15:0] MAC_CFG14 = 16'h0000,
  parameter [15:0] MAC_CFG15 = 16'h0000,
  parameter [15:0] MAC_CFG2 = 16'h0000,
  parameter [15:0] MAC_CFG3 = 16'h0000,
  parameter [15:0] MAC_CFG4 = 16'h0000,
  parameter [15:0] MAC_CFG5 = 16'h0000,
  parameter [15:0] MAC_CFG6 = 16'h0000,
  parameter [15:0] MAC_CFG7 = 16'h0000,
  parameter [15:0] MAC_CFG8 = 16'h0000,
  parameter [15:0] MAC_CFG9 = 16'h0C03,
  parameter [15:0] PCS_RSVD0 = 16'h0000,
  parameter [11:0] PD_TRANS_TIME_FROM_P2 = 12'h03C,
  parameter [7:0] PD_TRANS_TIME_NONE_P2 = 8'h19,
  parameter [7:0] PD_TRANS_TIME_TO_P2 = 8'h64,
  parameter integer PREIQ_FREQ_BST = 0,
  parameter [15:0] RAW_MAC_CFG = 16'h0000,
  parameter [0:0] RCLK_SIPO_DLY_ENB = 1'b0,
  parameter [0:0] RCLK_SIPO_INV_EN = 1'b0,
  parameter [15:0] RCO_NEW_MAC_CFG0 = 16'h0000,
  parameter [15:0] RCO_NEW_MAC_CFG1 = 16'h0000,
  parameter [15:0] RCO_NEW_MAC_CFG2 = 16'h0000,
  parameter [15:0] RCO_NEW_MAC_CFG3 = 16'h0000,
  parameter [15:0] RCO_NEW_RAW_CFG0 = 16'h0000,
  parameter [15:0] RCO_NEW_RAW_CFG1 = 16'h2020,
  parameter [15:0] RCO_NEW_RAW_CFG2 = 16'h0000,
  parameter [15:0] RCO_NEW_RAW_CFG3 = 16'h0000,
  parameter [2:0] RTX_BUF_CML_CTRL = 3'b010,
  parameter [1:0] RTX_BUF_TERM_CTRL = 2'b00,
  parameter [4:0] RXBUFRESET_TIME = 5'b00001,
  parameter RXBUF_EN = "TRUE",
  parameter [4:0] RXCDRFREQRESET_TIME = 5'b10000,
  parameter [4:0] RXCDRPHRESET_TIME = 5'b00001,
  parameter [15:0] RXCDR_CFG0 = 16'h0003,
  parameter [15:0] RXCDR_CFG1 = 16'h0000,
  parameter [15:0] RXCDR_CFG2 = 16'h0164,
  parameter [15:0] RXCDR_CFG3 = 16'h0024,
  parameter [15:0] RXCDR_CFG4 = 16'h5CF6,
  parameter [15:0] RXCDR_CFG5 = 16'hB46B,
  parameter [0:0] RXCDR_FR_RESET_ON_EIDLE = 1'b0,
  parameter [0:0] RXCDR_HOLD_DURING_EIDLE = 1'b0,
  parameter [15:0] RXCDR_LOCK_CFG0 = 16'h0040,
  parameter [15:0] RXCDR_LOCK_CFG1 = 16'h8000,
  parameter [15:0] RXCDR_LOCK_CFG2 = 16'h0000,
  parameter [15:0] RXCDR_LOCK_CFG3 = 16'h0000,
  parameter [15:0] RXCDR_LOCK_CFG4 = 16'h0000,
  parameter [0:0] RXCDR_PH_RESET_ON_EIDLE = 1'b0,
  parameter [15:0] RXCFOK_CFG0 = 16'h0000,
  parameter [15:0] RXCFOK_CFG1 = 16'h0002,
  parameter [15:0] RXCFOK_CFG2 = 16'h002D,
  parameter [15:0] RXCKCAL1_IQ_LOOP_RST_CFG = 16'h0000,
  parameter [15:0] RXCKCAL1_I_LOOP_RST_CFG = 16'h0000,
  parameter [15:0] RXCKCAL1_Q_LOOP_RST_CFG = 16'h0000,
  parameter [15:0] RXCKCAL2_DX_LOOP_RST_CFG = 16'h0000,
  parameter [15:0] RXCKCAL2_D_LOOP_RST_CFG = 16'h0000,
  parameter [15:0] RXCKCAL2_S_LOOP_RST_CFG = 16'h0000,
  parameter [15:0] RXCKCAL2_X_LOOP_RST_CFG = 16'h0000,
  parameter [6:0] RXDFELPMRESET_TIME = 7'b0001111,
  parameter [15:0] RXDFELPM_KL_CFG0 = 16'h0000,
  parameter [15:0] RXDFELPM_KL_CFG1 = 16'h0022,
  parameter [15:0] RXDFELPM_KL_CFG2 = 16'h0100,
  parameter [15:0] RXDFE_CFG0 = 16'h4000,
  parameter [15:0] RXDFE_CFG1 = 16'h0000,
  parameter [15:0] RXDFE_GC_CFG0 = 16'h0000,
  parameter [15:0] RXDFE_GC_CFG1 = 16'h0000,
  parameter [15:0] RXDFE_GC_CFG2 = 16'h0000,
  parameter [15:0] RXDFE_H2_CFG0 = 16'h0000,
  parameter [15:0] RXDFE_H2_CFG1 = 16'h0002,
  parameter [15:0] RXDFE_H3_CFG0 = 16'h0000,
  parameter [15:0] RXDFE_H3_CFG1 = 16'h0002,
  parameter [15:0] RXDFE_H4_CFG0 = 16'h0000,
  parameter [15:0] RXDFE_H4_CFG1 = 16'h0003,
  parameter [15:0] RXDFE_H5_CFG0 = 16'h0000,
  parameter [15:0] RXDFE_H5_CFG1 = 16'h0002,
  parameter [15:0] RXDFE_H6_CFG0 = 16'h0000,
  parameter [15:0] RXDFE_H6_CFG1 = 16'h0002,
  parameter [15:0] RXDFE_H7_CFG0 = 16'h0000,
  parameter [15:0] RXDFE_H7_CFG1 = 16'h0002,
  parameter [15:0] RXDFE_H8_CFG0 = 16'h0000,
  parameter [15:0] RXDFE_H8_CFG1 = 16'h0002,
  parameter [15:0] RXDFE_H9_CFG0 = 16'h0000,
  parameter [15:0] RXDFE_H9_CFG1 = 16'h0002,
  parameter [15:0] RXDFE_HA_CFG0 = 16'h0000,
  parameter [15:0] RXDFE_HA_CFG1 = 16'h0002,
  parameter [15:0] RXDFE_HB_CFG0 = 16'h0000,
  parameter [15:0] RXDFE_HB_CFG1 = 16'h0002,
  parameter [15:0] RXDFE_HC_CFG0 = 16'h0000,
  parameter [15:0] RXDFE_HC_CFG1 = 16'h0002,
  parameter [15:0] RXDFE_HD_CFG0 = 16'h0000,
  parameter [15:0] RXDFE_HD_CFG1 = 16'h0002,
  parameter [15:0] RXDFE_HE_CFG0 = 16'h0000,
  parameter [15:0] RXDFE_HE_CFG1 = 16'h0002,
  parameter [15:0] RXDFE_HF_CFG0 = 16'h0000,
  parameter [15:0] RXDFE_HF_CFG1 = 16'h0002,
  parameter [15:0] RXDFE_KH_CFG0 = 16'h0000,
  parameter [15:0] RXDFE_KH_CFG1 = 16'h0000,
  parameter [15:0] RXDFE_KH_CFG2 = 16'h0000,
  parameter [15:0] RXDFE_KH_CFG3 = 16'h2000,
  parameter [15:0] RXDFE_OS_CFG0 = 16'h0000,
  parameter [15:0] RXDFE_OS_CFG1 = 16'h0000,
  parameter [15:0] RXDFE_UT_CFG0 = 16'h0000,
  parameter [15:0] RXDFE_UT_CFG1 = 16'h0002,
  parameter [15:0] RXDFE_UT_CFG2 = 16'h0000,
  parameter [15:0] RXDFE_VP_CFG0 = 16'h0000,
  parameter [15:0] RXDFE_VP_CFG1 = 16'h0022,
  parameter [15:0] RXDLY_CFG = 16'h0010,
  parameter [15:0] RXDLY_LCFG = 16'h0030,
  parameter [15:0] RXDLY_RAW_CFG = 16'h0010,
  parameter [15:0] RXDLY_RAW_LCFG = 16'h0000,
  parameter RXELECIDLE_CFG = "SIGCFG_4",
  parameter integer RXGBOX_FIFO_INIT_RD_ADDR = 4,
  parameter RXGEARBOX_EN = "FALSE",
  parameter [4:0] RXISCANRESET_TIME = 5'b00001,
  parameter [15:0] RXLPM_CFG = 16'h0000,
  parameter [15:0] RXLPM_GC_CFG = 16'h1000,
  parameter [15:0] RXLPM_KH_CFG0 = 16'h0000,
  parameter [15:0] RXLPM_KH_CFG1 = 16'h0002,
  parameter [15:0] RXLPM_OS_CFG0 = 16'h0000,
  parameter [15:0] RXLPM_OS_CFG1 = 16'h0000,
  parameter [4:0] RXOSCALRESET_TIME = 5'b00011,
  parameter integer RXOUT_DIV = 4,
  parameter [4:0] RXPCSRESET_TIME = 5'b00001,
  parameter [15:0] RXPHBEACON_CFG = 16'h0000,
  parameter [15:0] RXPHBEACON_RAW_CFG = 16'h0000,
  parameter [15:0] RXPHDLY_CFG = 16'h2020,
  parameter [15:0] RXPHSAMP_CFG = 16'h2100,
  parameter [15:0] RXPHSAMP_RAW_CFG = 16'h2100,
  parameter [15:0] RXPHSLIP_CFG = 16'h9933,
  parameter [15:0] RXPHSLIP_RAW_CFG = 16'h9933,
  parameter [4:0] RXPH_MONITOR_SEL = 5'b00000,
  parameter [15:0] RXPI_CFG0 = 16'h0102,
  parameter [15:0] RXPI_CFG1 = 16'b0000000001010100,
  parameter RXPMACLK_SEL = "DATA",
  parameter [4:0] RXPMARESET_TIME = 5'b00001,
  parameter [0:0] RXPRBS_ERR_LOOPBACK = 1'b0,
  parameter integer RXPRBS_LINKACQ_CNT = 15,
  parameter [0:0] RXREFCLKDIV2_SEL = 1'b0,
  parameter integer RXSLIDE_AUTO_WAIT = 7,
  parameter RXSLIDE_MODE = "OFF",
  parameter [0:0] RXSYNC_MULTILANE = 1'b0,
  parameter [0:0] RXSYNC_OVRD = 1'b0,
  parameter [0:0] RXSYNC_SKIP_DA = 1'b0,
  parameter [0:0] RX_AFE_CM_EN = 1'b0,
  parameter [15:0] RX_BIAS_CFG0 = 16'h12B0,
  parameter [0:0] RX_CAPFF_SARC_ENB = 1'b0,
  parameter integer RX_CLK25_DIV = 8,
  parameter [0:0] RX_CLKMUX_EN = 1'b1,
  parameter [4:0] RX_CLK_SLIP_OVRD = 5'b00000,
  parameter [3:0] RX_CM_BUF_CFG = 4'b1010,
  parameter [0:0] RX_CM_BUF_PD = 1'b0,
  parameter integer RX_CM_SEL = 2,
  parameter integer RX_CM_TRIM = 12,
  parameter [0:0] RX_CTLE_PWR_SAVING = 1'b0,
  parameter [3:0] RX_CTLE_RES_CTRL = 4'b0000,
  parameter integer RX_DATA_WIDTH = 20,
  parameter [5:0] RX_DDI_SEL = 6'b000000,
  parameter [2:0] RX_DEGEN_CTRL = 3'b100,
  parameter integer RX_DFELPM_CFG0 = 10,
  parameter [0:0] RX_DFELPM_CFG1 = 1'b1,
  parameter [0:0] RX_DFELPM_KLKH_AGC_STUP_EN = 1'b1,
  parameter integer RX_DFE_AGC_CFG1 = 4,
  parameter integer RX_DFE_KL_LPM_KH_CFG0 = 1,
  parameter integer RX_DFE_KL_LPM_KH_CFG1 = 2,
  parameter [1:0] RX_DFE_KL_LPM_KL_CFG0 = 2'b01,
  parameter integer RX_DFE_KL_LPM_KL_CFG1 = 4,
  parameter [0:0] RX_DFE_LPM_HOLD_DURING_EIDLE = 1'b0,
  parameter RX_DISPERR_SEQ_MATCH = "TRUE",
  parameter [4:0] RX_DIVRESET_TIME = 5'b00001,
  parameter [0:0] RX_EN_CTLE_RCAL_B = 1'b0,
  parameter integer RX_EN_SUM_RCAL_B = 0,
  parameter [6:0] RX_EYESCAN_VS_CODE = 7'b0000000,
  parameter [0:0] RX_EYESCAN_VS_NEG_DIR = 1'b0,
  parameter [1:0] RX_EYESCAN_VS_RANGE = 2'b10,
  parameter [0:0] RX_EYESCAN_VS_UT_SIGN = 1'b0,
  parameter [0:0] RX_I2V_FILTER_EN = 1'b1,
  parameter integer RX_INT_DATAWIDTH = 1,
  parameter [0:0] RX_PMA_POWER_SAVE = 1'b0,
  parameter [15:0] RX_PMA_RSV0 = 16'h002F,
  parameter real RX_PROGDIV_CFG = 0.0,
  parameter [15:0] RX_PROGDIV_RATE = 16'h0001,
  parameter [3:0] RX_RESLOAD_CTRL = 4'b0000,
  parameter [0:0] RX_RESLOAD_OVRD = 1'b0,
  parameter [2:0] RX_SAMPLE_PERIOD = 3'b101,
  parameter integer RX_SIG_VALID_DLY = 11,
  parameter integer RX_SUM_DEGEN_AVTT_OVERITE = 0,
  parameter [0:0] RX_SUM_DFETAPREP_EN = 1'b0,
  parameter [3:0] RX_SUM_IREF_TUNE = 4'b0000,
  parameter integer RX_SUM_PWR_SAVING = 0,
  parameter [3:0] RX_SUM_RES_CTRL = 4'b0000,
  parameter [3:0] RX_SUM_VCMTUNE = 4'b0011,
  parameter [0:0] RX_SUM_VCM_BIAS_TUNE_EN = 1'b1,
  parameter [0:0] RX_SUM_VCM_OVWR = 1'b0,
  parameter [2:0] RX_SUM_VREF_TUNE = 3'b100,
  parameter [1:0] RX_TUNE_AFE_OS = 2'b00,
  parameter [2:0] RX_VREG_CTRL = 3'b010,
  parameter [0:0] RX_VREG_PDB = 1'b1,
  parameter [1:0] RX_WIDEMODE_CDR = 2'b01,
  parameter [1:0] RX_WIDEMODE_CDR_GEN3 = 2'b01,
  parameter [1:0] RX_WIDEMODE_CDR_GEN4 = 2'b01,
  parameter RX_XCLK_SEL = "RXDES",
  parameter [0:0] RX_XMODE_SEL = 1'b0,
  parameter [0:0] SAMPLE_CLK_PHASE = 1'b0,
  parameter SATA_CPLL_CFG = "VCO_3000MHZ",
  parameter SIM_MODE = "FAST",
  parameter SIM_RESET_SPEEDUP = "TRUE",
  parameter SIM_TX_EIDLE_DRIVE_LEVEL = "Z",
  parameter [0:0] SRSTMODE = 1'b0,
  parameter [1:0] TAPDLY_SET_TX = 2'h0,
  parameter [15:0] TCO_NEW_CFG0 = 16'h0000,
  parameter [15:0] TCO_NEW_CFG1 = 16'h0000,
  parameter [15:0] TCO_NEW_CFG2 = 16'h0000,
  parameter [15:0] TCO_NEW_CFG3 = 16'h0000,
  parameter [15:0] TCO_RSVD1 = 16'h0000,
  parameter [15:0] TCO_RSVD2 = 16'h0000,
  parameter [14:0] TERM_RCAL_CFG = 15'b100001000010000,
  parameter [2:0] TERM_RCAL_OVRD = 3'b000,
  parameter [7:0] TRANS_TIME_RATE = 8'h0E,
  parameter [7:0] TST_RSV0 = 8'h00,
  parameter [7:0] TST_RSV1 = 8'h00,
  parameter TXBUF_EN = "TRUE",
  parameter [15:0] TXDLY_CFG = 16'h0010,
  parameter [15:0] TXDLY_LCFG = 16'h0030,
  parameter integer TXDRV_FREQBAND = 0,
  parameter [15:0] TXFE_CFG0 = 16'h0000,
  parameter [15:0] TXFE_CFG1 = 16'h0000,
  parameter [15:0] TXFE_CFG2 = 16'h0000,
  parameter [15:0] TXFE_CFG3 = 16'h0000,
  parameter TXFIFO_ADDR_CFG = "LOW",
  parameter integer TXGBOX_FIFO_INIT_RD_ADDR = 4,
  parameter integer TXOUT_DIV = 4,
  parameter [4:0] TXPCSRESET_TIME = 5'b00001,
  parameter [15:0] TXPHDLY_CFG0 = 16'h6020,
  parameter [15:0] TXPHDLY_CFG1 = 16'h0002,
  parameter [15:0] TXPH_CFG = 16'h0103,
  parameter [15:0] TXPH_CFG2 = 16'h0000,
  parameter [4:0] TXPH_MONITOR_SEL = 5'b00000,
  parameter [15:0] TXPI_CFG0 = 16'h0100,
  parameter [15:0] TXPI_CFG1 = 16'h0000,
  parameter [0:0] TXPI_GRAY_SEL = 1'b0,
  parameter [0:0] TXPI_INVSTROBE_SEL = 1'b0,
  parameter [0:0] TXPI_PPM = 1'b0,
  parameter [7:0] TXPI_PPM_CFG = 8'b00000000,
  parameter [2:0] TXPI_SYNFREQ_PPM = 3'b000,
  parameter [4:0] TXPMARESET_TIME = 5'b00001,
  parameter [0:0] TXREFCLKDIV2_SEL = 1'b0,
  parameter integer TXSWBST_BST = 1,
  parameter integer TXSWBST_EN = 0,
  parameter integer TXSWBST_MAG = 6,
  parameter [0:0] TXSYNC_MULTILANE = 1'b0,
  parameter [0:0] TXSYNC_OVRD = 1'b0,
  parameter [0:0] TXSYNC_SKIP_DA = 1'b0,
  parameter integer TX_CLK25_DIV = 8,
  parameter [0:0] TX_CLKMUX_EN = 1'b1,
  parameter integer TX_DATA_WIDTH = 20,
  parameter [15:0] TX_DCC_LOOP_RST_CFG = 16'h0000,
  parameter [4:0] TX_DIVRESET_TIME = 5'b00001,
  parameter [2:0] TX_EIDLE_ASSERT_DELAY = 3'b110,
  parameter [2:0] TX_EIDLE_DEASSERT_DELAY = 3'b100,
  parameter [0:0] TX_FABINT_USRCLK_FLOP = 1'b0,
  parameter [0:0] TX_FIFO_BYP_EN = 1'b0,
  parameter [0:0] TX_IDLE_DATA_ZERO = 1'b0,
  parameter integer TX_INT_DATAWIDTH = 0,
  parameter TX_LOOPBACK_DRIVE_HIZ = "FALSE",
  parameter [0:0] TX_MAINCURSOR_SEL = 1'b0,
  parameter [15:0] TX_PHICAL_CFG0 = 16'h0000,
  parameter [15:0] TX_PHICAL_CFG1 = 16'h003F,
  parameter integer TX_PI_BIASSET = 0,
  parameter [0:0] TX_PMADATA_OPT = 1'b0,
  parameter [0:0] TX_PMA_POWER_SAVE = 1'b0,
  parameter [15:0] TX_PMA_RSV0 = 16'h0000,
  parameter [15:0] TX_PMA_RSV1 = 16'h0000,
  parameter TX_PROGCLK_SEL = "POSTPI",
  parameter real TX_PROGDIV_CFG = 0.0,
  parameter [15:0] TX_PROGDIV_RATE = 16'h0001,
  parameter [2:0] TX_SAMPLE_PERIOD = 3'b101,
  parameter [1:0] TX_SW_MEAS = 2'b00,
  parameter [2:0] TX_VREG_CTRL = 3'b000,
  parameter [0:0] TX_VREG_PDB = 1'b0,
  parameter [1:0] TX_VREG_VREFSEL = 2'b00,
  parameter TX_XCLK_SEL = "TXOUT",
  parameter [0:0] USE_PCS_CLK_PHASE_SEL = 1'b0,
  parameter [0:0] USE_RAW_ELEC = 1'b0,
  parameter [0:0] Y_ALL_MODE = 1'b0,
  parameter  integer     NUM_CHANNEL = 1

)(
  input  wire gtwiz_reset_clk_freerun_in,
  input  wire gtwiz_reset_all_in,
  input  wire gtwiz_reset_tx_pll_and_datapath_in,
  input  wire gtwiz_reset_tx_datapath_in,
  input  wire gtwiz_reset_rx_pll_and_datapath_in,
  input  wire gtwiz_reset_rx_datapath_in,
  output wire gtwiz_reset_rx_cdr_stable_out,
  output wire gtwiz_reset_tx_done_out,
  output wire gtwiz_reset_rx_done_out,
  output wire gtwiz_pllreset_rx_out,
  output wire gtwiz_pllreset_tx_out,
  input  wire plllock_tx_in,
  input  wire plllock_rx_in,
  input  wire   gtf_ch_cdrstepdir,
  input  wire   gtf_ch_cdrstepsq,
  input  wire   gtf_ch_cdrstepsx,
  input  wire   gtf_ch_cfgreset,
  input  wire   gtf_ch_clkrsvd0,
  input  wire   gtf_ch_clkrsvd1,
  input  wire   gtf_ch_cpllfreqlock,
  input  wire   gtf_ch_cplllockdetclk,
  input  wire   gtf_ch_cplllocken,
  input  wire   gtf_ch_cpllpd,
  input  wire   gtf_ch_cpllreset,
  input  wire   gtf_ch_ctltxresendpause,


  input  wire   gtf_ch_dmonfiforeset,
  input  wire   gtf_ch_dmonitorclk,
  input  wire   gtf_ch_drpclk,
  input  wire   gtf_ch_drprst,
  input  wire   gtf_ch_eyescanreset,
  input  wire   gtf_ch_eyescantrigger,
  input  wire   gtf_ch_freqos,
  input  wire   gtf_ch_gtfrxn,
  input  wire   gtf_ch_gtfrxp,
  input  wire   gtf_ch_gtgrefclk,
  input  wire   gtf_ch_gtnorthrefclk0,
  input  wire   gtf_ch_gtnorthrefclk1,
  input  wire   gtf_ch_gtrefclk0,
  input  wire   gtf_ch_gtrefclk1,
  input  wire   gtf_ch_gtrxresetsel,
  input  wire   gtf_ch_gtsouthrefclk0,
  input  wire   gtf_ch_gtsouthrefclk1,
  input  wire   gtf_ch_gttxresetsel,
  input  wire   gtf_ch_incpctrl,
  input  wire   gtf_ch_qpll0clk,
  input  wire   gtf_ch_qpll0freqlock,
  input  wire   gtf_ch_qpll0refclk,
  input  wire   gtf_ch_qpll1clk,
  input  wire   gtf_ch_qpll1freqlock,
  input  wire   gtf_ch_qpll1refclk,
  input  wire   gtf_ch_resetovrd,
  input  wire   gtf_ch_rxafecfoken,
  input  wire   gtf_ch_rxcdrfreqreset,
  input  wire   gtf_ch_rxcdrhold,
  input  wire   gtf_ch_rxcdrovrden,
  input  wire   gtf_ch_rxcdrreset,
  input  wire   gtf_ch_rxckcalreset,
  input  wire   gtf_ch_rxdfeagchold,
  input  wire   gtf_ch_rxdfeagcovrden,
  input  wire   gtf_ch_rxdfecfokfen,
  input  wire   gtf_ch_rxdfecfokfpulse,
  input  wire   gtf_ch_rxdfecfokhold,
  input  wire   gtf_ch_rxdfecfokovren,
  input  wire   gtf_ch_rxdfekhhold,
  input  wire   gtf_ch_rxdfekhovrden,
  input  wire   gtf_ch_rxdfelfhold,
  input  wire   gtf_ch_rxdfelfovrden,
  input  wire   gtf_ch_rxdfelpmreset,
  input  wire   gtf_ch_rxdfetap10hold,
  input  wire   gtf_ch_rxdfetap10ovrden,
  input  wire   gtf_ch_rxdfetap11hold,
  input  wire   gtf_ch_rxdfetap11ovrden,
  input  wire   gtf_ch_rxdfetap12hold,
  input  wire   gtf_ch_rxdfetap12ovrden,
  input  wire   gtf_ch_rxdfetap13hold,
  input  wire   gtf_ch_rxdfetap13ovrden,
  input  wire   gtf_ch_rxdfetap14hold,
  input  wire   gtf_ch_rxdfetap14ovrden,
  input  wire   gtf_ch_rxdfetap15hold,
  input  wire   gtf_ch_rxdfetap15ovrden,
  input  wire   gtf_ch_rxdfetap2hold,
  input  wire   gtf_ch_rxdfetap2ovrden,
  input  wire   gtf_ch_rxdfetap3hold,
  input  wire   gtf_ch_rxdfetap3ovrden,
  input  wire   gtf_ch_rxdfetap4hold,
  input  wire   gtf_ch_rxdfetap4ovrden,
  input  wire   gtf_ch_rxdfetap5hold,
  input  wire   gtf_ch_rxdfetap5ovrden,
  input  wire   gtf_ch_rxdfetap6hold,
  input  wire   gtf_ch_rxdfetap6ovrden,
  input  wire   gtf_ch_rxdfetap7hold,
  input  wire   gtf_ch_rxdfetap7ovrden,
  input  wire   gtf_ch_rxdfetap8hold,
  input  wire   gtf_ch_rxdfetap8ovrden,
  input  wire   gtf_ch_rxdfetap9hold,
  input  wire   gtf_ch_rxdfetap9ovrden,
  input  wire   gtf_ch_rxdfeuthold,
  input  wire   gtf_ch_rxdfeutovrden,
  input  wire   gtf_ch_rxdfevphold,
  input  wire   gtf_ch_rxdfevpovrden,
  input  wire   gtf_ch_rxdfexyden,
  input  wire   gtf_ch_rxlpmen,
  input  wire   gtf_ch_rxlpmgchold,
  input  wire   gtf_ch_rxlpmgcovrden,
  input  wire   gtf_ch_rxlpmhfhold,
  input  wire   gtf_ch_rxlpmhfovrden,
  input  wire   gtf_ch_rxlpmlfhold,
  input  wire   gtf_ch_rxlpmlfklovrden,
  input  wire   gtf_ch_rxlpmoshold,
  input  wire   gtf_ch_rxlpmosovrden,
  input  wire   gtf_ch_rxoscalreset,
  input  wire   gtf_ch_rxoshold,
  input  wire   gtf_ch_rxosovrden,
  input  wire   gtf_ch_rxpcsreset,
  input  wire   gtf_ch_rxslippma,
  input  wire   gtf_ch_rxpmareset,
  input  wire   gtf_ch_rxpolarity,
  input  wire   gtf_ch_rxprbscntreset,
  input  wire   gtf_ch_rxslipoutclk,
  input  wire   gtf_ch_rxtermination,
  input  wire   gtf_ch_rxuserrdy,
  input  wire   gtf_ch_txaxisterr,
  input  wire   gtf_ch_txaxistpoison,
  input  wire   gtf_ch_txaxistvalid,
  input  wire   gtf_ch_txdccforcestart,
  input  wire   gtf_ch_txdccreset,
  input  wire   gtf_ch_txelecidle,
  input  wire   gtf_ch_txgbseqsync,
  input  wire   gtf_ch_txmuxdcdexhold,
  input  wire   gtf_ch_txmuxdcdorwren,
  input  wire   gtf_ch_txpcsreset,
 
  input  wire   gtf_ch_txpippmen,
  input  wire   gtf_ch_txpippmovrden,
  input  wire   gtf_ch_txpippmpd,
  input  wire   gtf_ch_txpippmsel,
  input  wire   gtf_ch_txpisopd,
  input  wire   gtf_ch_txpmareset,
  input  wire   gtf_ch_txpolarity,
  input  wire   gtf_ch_txprbsforceerr,
  input  wire   gtf_ch_txuserrdy,

  input wire [15:0]  gtf_ch_gtrsvd,
  input wire [15:0]  gtf_ch_pcsrsvdin,
  input wire [19:0]  gtf_ch_tstin,
  input wire [1:0]   gtf_ch_rxelecidlemode,
  input wire [1:0]   gtf_ch_rxmonitorsel,
  input wire [1:0]   gtf_ch_rxpd,
  input wire [1:0]   gtf_ch_rxpllclksel,
  input wire [1:0]   gtf_ch_rxsysclksel,
  input wire [1:0]   gtf_ch_txaxistsof,
  input wire [1:0]   gtf_ch_txpd,
  input wire [1:0]   gtf_ch_txpllclksel,
  input wire [1:0]   gtf_ch_txsysclksel,
  input wire [2:0]   gtf_ch_cpllrefclksel,
  input wire [2:0]   gtf_ch_rxoutclksel,
  input wire [2:0]   gtf_ch_txoutclksel,
  input wire [39:0]  gtf_ch_txrawdata,
  input wire [3:0]   gtf_ch_rxdfecfokfcnum,
  input wire [3:0]   gtf_ch_rxprbssel,
  input wire [3:0]   gtf_ch_txprbssel,
  input wire [4:0]   gtf_ch_txaxistterm,
  input wire [4:0]   gtf_ch_txdiffctrl,
  input wire [4:0]   gtf_ch_txpippmstepsize,
  input wire [4:0]   gtf_ch_txpostcursor,
  input wire [4:0]   gtf_ch_txprecursor,
  input wire [63:0]  gtf_ch_txaxistdata,
  input wire [6:0]   gtf_ch_rxckcalstart,
  input wire [6:0]   gtf_ch_txmaincursor,
  input wire [7:0]   gtf_ch_txaxistlast,
  input wire [7:0]   gtf_ch_txaxistpre,
  input wire [8:0]   gtf_ch_ctlrxpauseack,
  input wire [8:0]   gtf_ch_ctltxpausereq,

  output wire   gtf_ch_cpllfbclklost,
  output wire   gtf_ch_cplllock,
  output wire   gtf_ch_cpllrefclklost,
  output wire   gtf_ch_dmonitoroutclk,

  output wire   gtf_ch_eyescandataerror,
  output wire   gtf_ch_gtftxn,
  output wire   gtf_ch_gtftxp,
  output wire   gtf_ch_gtpowergood,
  output wire   gtf_ch_gtrefclkmonitor,
  output wire   gtf_ch_resetexception,
  output wire   gtf_ch_rxaxisterr,
  output wire   gtf_ch_rxaxistvalid,
  output wire   gtf_ch_rxbitslip,
  output wire   gtf_ch_rxcdrlock,
  output wire   gtf_ch_rxcdrphdone,
  output wire   gtf_ch_rxckcaldone,
  output wire   gtf_ch_rxelecidle,
  output wire   gtf_ch_rxgbseqstart,
  output wire   gtf_ch_rxosintdone,
  output wire   gtf_ch_rxosintstarted,
  output wire   gtf_ch_rxosintstrobedone,
  output wire   gtf_ch_rxosintstrobestarted,
  output wire   gtf_ch_rxoutclk,
  output wire   gtf_ch_rxoutclkfabric,
  output wire   gtf_ch_rxoutclkpcs,
  output wire   gtf_ch_rxphalignerr,
  output wire   gtf_ch_rxpmaresetdone,
  output wire   gtf_ch_rxprbserr,
  output wire   gtf_ch_rxprbslocked,
  output wire   gtf_ch_rxprgdivresetdone,
  output wire   gtf_ch_rxptpsop,
  output wire   gtf_ch_rxptpsoppos,
  output wire   gtf_ch_rxrecclkout,
  output wire   gtf_ch_rxresetdone,
  output wire   gtf_ch_rxslipdone,
  output wire   gtf_ch_rxslipoutclkrdy,
  output wire   gtf_ch_rxslippmardy,
  output wire   gtf_ch_rxsyncdone,

  output wire   gtf_ch_statrxblocklock,

  output wire   gtf_ch_statrxfcserr,


  input  wire [31:0] s_axi_awaddr   ,
  output wire [2:0]  s_axi_awprot   ,
  input  wire        s_axi_awvalid  ,
  output wire        s_axi_awready  ,
  input  wire [31:0] s_axi_wdata    ,
  output wire [3:0]  s_axi_wstrb    ,
  input  wire        s_axi_wvalid   ,
  output wire        s_axi_wready   ,
  output wire [1:0]  s_axi_bresp    ,
  output wire        s_axi_bvalid   ,
  input  wire        s_axi_bready   ,
  input  wire [31:0] s_axi_araddr   ,
  output wire [2:0]  s_axi_arprot   ,
  input  wire        s_axi_arvalid  ,
  output wire        s_axi_arready  ,
  output wire [31:0] s_axi_rdata    ,
  output wire [1:0]  s_axi_rresp    ,
  output wire        s_axi_rvalid   ,
  input  wire        s_axi_rready   ,
  output wire        ctl_tx_send_idle           ,
  output wire        ctl_gt_reset_all           ,
  output wire [79:0] tx_ptp_tstamp_out          ,
  output wire [79:0] rx_ptp_tstamp_out          ,
  output wire        rx_ptp_tstamp_valid_out    ,
  output wire        tx_ptp_tstamp_valid_out    ,


  output wire   gtf_ch_statrxlocalfault,

  output wire   gtf_ch_statrxinternallocalfault,


  output wire   gtf_ch_statrxreceivedlocalfault,
  output wire   gtf_ch_statrxremotefault,

  output wire   gtf_ch_statrxtestpatternmismatch,


  output wire   gtf_ch_statrxvalidctrlcode,



  output wire   gtf_ch_stattxfcserr,





  output wire   gtf_ch_txaxistready,
  output wire   gtf_ch_txdccdone,
  output wire   gtf_ch_txgbseqstart,
  output wire   gtf_ch_txoutclk,
  output wire   gtf_ch_txoutclkfabric,
  output wire   gtf_ch_txoutclkpcs,
  output wire   gtf_ch_txsyncdone,
  output wire   gtf_ch_txpmaresetdone,
  output wire   gtf_ch_txprgdivresetdone,
  output wire   gtf_ch_txptpsop,
  output wire   gtf_ch_txptpsoppos,
  output wire   gtf_ch_txresetdone,
  output wire   gtf_ch_txunfout,
  output wire   gtf_ch_txaxistcanstart,
  output wire   gtf_ch_rxinvalidstart,

  output wire [15:0] gtf_ch_pcsrsvdout,
  output wire [15:0] gtf_ch_pinrsrvdas,
  output wire [1:0]  gtf_ch_rxaxistsof,
  output wire [39:0] gtf_ch_rxrawdata,


  output wire [4:0]  gtf_ch_rxaxistterm,
  output wire [63:0] gtf_ch_rxaxistdata,
  output wire [7:0]  gtf_ch_rxaxistlast,
  output wire [7:0]  gtf_ch_rxaxistpre,
  output wire [7:0]  gtf_ch_rxmonitorout,



  output wire [8:0]  gtf_ch_stattxpausevalid,
  output wire       gtf_ch_gttxreset_out,

  output wire     gtwiz_buffbypass_tx_done_out,
  output wire     gtwiz_buffbypass_rx_done_out,
  output wire     gtf_txusrclk2_out,
  output wire     gtf_rxusrclk2_out
);

  wire gtrxreset_int;
  wire txprogdivreset_int;
  wire rxprogdivreset_int;
  wire rxuserrdy_int;
  wire txuserrdy_int;
  wire rxuserrdy_int_1;
  wire txuserrdy_int_1;
  wire i_gtf_ch_gtpowergood;
  wire i_gtf_ch_gttxreset_in;
  wire i_gtf_ch_gttxreset_out;
  wire i_gtf_ch_txpmareset;
  wire i_gtf_ch_txpisopd;

  assign rxuserrdy_int = rxuserrdy_int_1 | gtf_ch_rxuserrdy;
  assign txuserrdy_int = txuserrdy_int_1 | gtf_ch_txuserrdy;
  assign gtf_ch_txaxistcanstart = gtf_ch_pcsrsvdout[2]; 
  assign gtf_ch_rxinvalidstart  = gtf_ch_pcsrsvdout[7]; 
  wire gtwiz_reset_userclk_tx_active_in = gtf_ch_txpmaresetdone;
  wire gtwiz_reset_userclk_rx_active_in = gtf_ch_rxpmaresetdone;
  wire rxcdrlock_in = gtf_ch_rxcdrlock;
  wire txresetdone_in = gtf_ch_txresetdone;
  wire rxresetdone_in = gtf_ch_rxresetdone;
  wire gtf_ch_txusrclk;
  wire gtf_ch_txusrclk2 = gtf_ch_txusrclk;
  wire gtf_ch_rxusrclk;
  wire gtf_ch_rxusrclk2 = gtf_ch_rxusrclk;
  wire txusrclk2_in = gtf_ch_txusrclk2;
  wire rxusrclk2_in = gtf_ch_rxusrclk2;
  assign gtf_txusrclk2_out = gtf_ch_txusrclk2;
  assign gtf_rxusrclk2_out = gtf_ch_rxusrclk2;


  wire          gtf_ch_drp_reconfig_rdy;
  wire          gtf_ch_drp_reconfig_done;


  wire   gtf_ch_txphdlyreset;
  wire   gtf_ch_txphalign;
  wire   gtf_ch_txphalignen;
  wire   gtf_ch_txphdlypd;
  wire   gtf_ch_txphinit;
  wire   gtf_ch_txphovrden;
  wire   gtf_ch_txdlysreset;
  wire   gtf_ch_txdlybypass;
  wire   gtf_ch_txdlyen;
  wire   gtf_ch_txdlyovrden;
  wire   gtf_ch_txphdlytstclk;
  wire   gtf_ch_txdlyhold;
  wire   gtf_ch_txdlyupdown;
  wire   gtf_ch_txsyncmode;
  wire   gtf_ch_txsyncallin;
  wire   gtf_ch_txsyncin;
  
  wire   gtf_ch_txdlysresetdone;
  wire   gtf_ch_txphaligndone;
  wire   gtf_ch_txphinitdone;
  wire   gtf_ch_txsyncout;


  wire [2:0] ctl_local_loopback;
  wire ctl_tx_send_lfi_axi;
  wire ctl_tx_send_rfi_axi;
  wire ctl_tx_send_idle_axi;

  wire ctl_tx_data_rate    ; 
  wire ctl_rx_data_rate_i  ; 
  wire gtf_ch_statrxhiber  ;
  wire gtf_ch_statrxstatus ;
  wire gtf_ch_statrxbadpreamble;
  wire gtf_ch_statrxbadsfd;
  wire gtf_ch_statrxgotsignalos;
  wire gtf_ch_statrxframingerr;
  wire gtf_ch_statrxtruncated; 
  reg  gtf_ch_statrxtruncated_r; 


  wire gtf_ch_statrxbadcode;
  reg  gtf_ch_statrxbadcode_r;
  wire      stat_rx_framing_err;
  reg       stat_rx_framing_err_r;
  reg       stat_rx_total_packets_r;
  wire      stat_rx_total_packets;
  reg       stat_rx_total_good_packets_r;
  wire      stat_rx_total_good_packets;
  reg  [3:0]   stat_rx_total_bytes_r;
  wire [3:0]   stat_rx_total_bytes;
  reg  [13:0]  stat_rx_total_good_bytes_r;
  wire [13:0]  stat_rx_total_good_bytes;
  reg       stat_rx_packet_small_r;
  wire      stat_rx_packet_small;
  reg       stat_rx_jabber_r;
  wire      stat_rx_jabber;
  reg       stat_rx_packet_large_r;
  wire      stat_rx_packet_large;
  reg       stat_rx_oversize_r;
  wire      stat_rx_oversize;
  reg       stat_rx_undersize_r;
  wire      stat_rx_undersize;
  reg       stat_rx_toolong_r;
  wire      stat_rx_toolong;
  reg       stat_rx_fragment_r;
  wire      stat_rx_fragment;
  reg       stat_rx_packet_64_bytes_r;
  wire      stat_rx_packet_64_bytes;
  reg       stat_rx_packet_65_127_bytes_r;
  reg       stat_rx_packet_128_255_bytes_r;
  reg       stat_rx_packet_256_511_bytes_r;
  reg       stat_rx_packet_512_1023_bytes_r;
  reg       stat_rx_packet_1024_1518_bytes_r;
  reg       stat_rx_packet_1519_1522_bytes_r;
  reg       stat_rx_packet_1523_1548_bytes_r;
  reg       stat_rx_packet_1549_2047_bytes_r;
  reg       stat_rx_packet_2048_4095_bytes_r;
  reg       stat_rx_packet_4096_8191_bytes_r;
  reg       stat_rx_packet_8192_9215_bytes_r;
  wire      stat_rx_packet_65_127_bytes;
  wire      stat_rx_packet_128_255_bytes;
  wire      stat_rx_packet_256_511_bytes;
  wire      stat_rx_packet_512_1023_bytes;
  wire      stat_rx_packet_1024_1518_bytes;
  wire      stat_rx_packet_1519_1522_bytes;
  wire      stat_rx_packet_1523_1548_bytes;
  wire      stat_rx_packet_1549_2047_bytes;
  wire      stat_rx_packet_2048_4095_bytes;
  wire      stat_rx_packet_4096_8191_bytes;
  wire      stat_rx_packet_8192_9215_bytes;
  reg  [13:0]  stat_rx_total_err_bytes_r;
  wire [13:0]  stat_rx_total_err_bytes;
  reg       stat_rx_bad_fcs_r;
  wire      stat_rx_bad_fcs;
  reg       stat_rx_packet_bad_fcs_r;
  wire      stat_rx_packet_bad_fcs;

  wire      gtf_ch_statrxstompedfcs;
  reg       gtf_ch_statrxstompedfcs_r;
  reg       stat_rx_unicast_r;
  wire      stat_rx_unicast;
  reg       stat_rx_multicast_r;
  wire      stat_rx_multicast;
  reg       stat_rx_broadcast_r;
  wire      stat_rx_broadcast;
  reg       stat_rx_vlan_r;
  wire      stat_rx_vlan;
  reg       stat_rx_pause_r;
  wire      stat_rx_pause;
  reg       stat_rx_user_pause_r;
  wire      stat_rx_user_pause;
  reg       stat_rx_inrangeerr_r;
  wire      stat_rx_inrangeerr;
  reg       stat_tx_total_packets_r;
  wire      stat_tx_total_packets;
  reg  [3:0]   stat_tx_total_bytes_r;
  wire [3:0]   stat_tx_total_bytes;
  reg       stat_tx_total_good_packets_r;
  wire      stat_tx_total_good_packets;
  reg  [13:0]  stat_tx_total_good_bytes_r;
  wire [13:0]  stat_tx_total_good_bytes;
  reg       stat_tx_packet_64_bytes_r;
  wire      stat_tx_packet_64_bytes;
  reg       stat_tx_packet_65_127_bytes_r;
  wire      stat_tx_packet_65_127_bytes;
  reg       stat_tx_packet_128_255_bytes_r;
  wire      stat_tx_packet_128_255_bytes;
  reg       stat_tx_packet_256_511_bytes_r;
  reg       stat_tx_packet_512_1023_bytes_r;
  reg       stat_tx_packet_1024_1518_bytes_r;
  reg       stat_tx_packet_1519_1522_bytes_r;
  reg       stat_tx_packet_1523_1548_bytes_r;
  reg       stat_tx_packet_1549_2047_bytes_r;
  reg       stat_tx_packet_2048_4095_bytes_r;
  reg       stat_tx_packet_4096_8191_bytes_r;
  reg       stat_tx_packet_8192_9215_bytes_r;
  wire      stat_tx_packet_256_511_bytes;
  wire      stat_tx_packet_512_1023_bytes;
  wire      stat_tx_packet_1024_1518_bytes;
  wire      stat_tx_packet_1519_1522_bytes;
  wire      stat_tx_packet_1523_1548_bytes;
  wire      stat_tx_packet_1549_2047_bytes;
  wire      stat_tx_packet_2048_4095_bytes;
  wire      stat_tx_packet_4096_8191_bytes;
  wire      stat_tx_packet_8192_9215_bytes;
  reg       stat_tx_packet_large_r;
  wire      stat_tx_packet_large;
  reg       stat_tx_packet_small_r;
  wire      stat_tx_packet_small;
  reg  [13:0]  stat_tx_total_err_bytes_r;
  wire [13:0]  stat_tx_total_err_bytes;
  reg       stat_tx_unicast_r;
  wire      stat_tx_unicast;
  reg       stat_tx_bad_fcs_r;
  reg       stat_tx_broadcast_r;
  reg       stat_tx_multicast_r;
  reg       stat_tx_vlan_r;
  wire      stat_tx_bad_fcs;
  wire      stat_tx_broadcast;
  wire      stat_tx_multicast;
  wire      stat_tx_vlan;
  reg       stat_tx_frame_error_r;
  wire      stat_tx_frame_error;
  wire [8:0]   stat_rx_pause_valid;
  wire [15:0]  stat_rx_pause_quanta0;
  wire [15:0]  stat_rx_pause_quanta1;
  wire [15:0]  stat_rx_pause_quanta2;
  wire [15:0]  stat_rx_pause_quanta3;
  wire [15:0]  stat_rx_pause_quanta4;
  wire [15:0]  stat_rx_pause_quanta5;
  wire [15:0]  stat_rx_pause_quanta6;
  wire [15:0]  stat_rx_pause_quanta7;
  wire [15:0]  stat_rx_pause_quanta8;
  wire [8:0]   stat_rx_pause_req;


  reg  [3:0]  gtf_ch_statrxbytes_r;
  wire [3:0]  gtf_ch_statrxbytes;
  reg         gtf_ch_statrxpkt_r;
  wire        gtf_ch_statrxpkt;
  reg         gtf_ch_statrxpkterr_r;
  wire        gtf_ch_statrxpkterr;
  reg         gtf_ch_statrxbadfcs_r;
  wire        gtf_ch_statrxbadfcs;
  reg         gtf_ch_statrxunicast_r;
  wire        gtf_ch_statrxunicast;
  reg         gtf_ch_statrxbroadcast_r;
  wire        gtf_ch_statrxbroadcast;
  reg         gtf_ch_statrxmulticast_r;
  wire        gtf_ch_statrxmulticast;
  reg         gtf_ch_statrxvlan_r;
  wire        gtf_ch_statrxvlan;
  reg         gtf_ch_statrxinrangeerr_r;
  wire        gtf_ch_statrxinrangeerr;
  wire [8:0]  gtf_ch_statrxpausequanta;
  wire [8:0]  gtf_ch_statrxpausereq;
  wire [8:0]  gtf_ch_statrxpausevalid;
  wire [3:0]  gtf_ch_stattxbytes;
  wire        gtf_ch_stattxpkt;
  wire        gtf_ch_stattxpkterr;
  wire        gtf_ch_stattxbadfcs;
  wire        gtf_ch_stattxunicast;
  wire        gtf_ch_stattxbroadcast;
  wire        gtf_ch_stattxmulticast;
  wire        gtf_ch_stattxvlan;

  wire          ctl_tx_ignore_fcs;
  wire          ctl_tx_fcs_ins_enable;
  wire          ctl_rx_ignore_fcs;
  wire [7:0]    ctl_rx_min_packet_len;
  wire [15:0]   ctl_rx_max_packet_len;



  wire          drp_align_drpen;
  wire          drp_align_drpwe;
  wire [9:0]    drp_align_drpaddr;
  wire [15:0]   drp_align_drpdi;
  wire          drp_align_drprdy;
  wire [15:0]   drp_align_drpdo;
  wire          drp_bridge_drpen;
  wire          drp_bridge_drpwe;
  wire [9:0]    drp_bridge_drpaddr;
  wire [15:0]   drp_bridge_drpdo;
  wire          drp_bridge_drprdy;
  wire [15:0]   drp_bridge_drpdi;


  wire          gtwiz_buffbypass_rx_reset;

  wire [31:0]  m0_axi_awaddr;
  wire [2:0]   m0_axi_awprot;
  wire         m0_axi_awvalid;
  wire         m0_axi_awready;
  wire [31:0]  m0_axi_wdata;
  wire [3:0]   m0_axi_wstrb;
  wire         m0_axi_wvalid;
  wire         m0_axi_wready;
  wire [1:0]   m0_axi_bresp;
  wire         m0_axi_bvalid;
  wire         m0_axi_bready;
  wire [31:0]  m0_axi_araddr;
  wire [2:0]   m0_axi_arprot;
  wire         m0_axi_arvalid;
  wire         m0_axi_arready;
  wire [31:0]  m0_axi_rdata;
  wire [1:0]   m0_axi_rresp;
  wire         m0_axi_rvalid;
  wire         m0_axi_rready;

  wire [31:0]  m1_axi_awaddr;
  wire [2:0]   m1_axi_awprot;
  wire      m1_axi_awvalid;
  wire      m1_axi_awready;
  wire [31:0]  m1_axi_wdata;
  wire [3:0]   m1_axi_wstrb;
  wire      m1_axi_wvalid;
  wire      m1_axi_wready;
  wire [1:0]   m1_axi_bresp;
  wire      m1_axi_bvalid;
  wire      m1_axi_bready;
  wire [31:0]  m1_axi_araddr;
  wire [2:0]   m1_axi_arprot;
  wire      m1_axi_arvalid;
  wire      m1_axi_arready;
  wire [31:0]  m1_axi_rdata;
  wire [1:0]   m1_axi_rresp;
  wire      m1_axi_rvalid;
  wire      m1_axi_rready;



  wire   [15:0] i_gtf_ch_dmonitorout;
  wire   gtf_ch_rxphdlyreset;
  wire   gtf_ch_rxphalign;
  wire   gtf_ch_rxphalignen;
  wire   gtf_ch_rxphdlypd;
  wire   gtf_ch_rxdlysreset;
  wire   gtf_ch_rxdlybypass;
  wire   gtf_ch_rxdlyen;
  wire   gtf_ch_rxdlyovrden;
  wire   gtf_ch_rxsyncmode;
  wire   gtf_ch_rxsyncallin;
  wire   gtf_ch_rxsyncin;
  wire   gtf_ch_rxphaligndone;
  wire   gtf_ch_rxsyncout;
  wire   gtf_ch_rxdlysresetdone;
  wire   gtf_ch_am_switch;
  wire   gtf_ch_rxphovrden;
  
  wire          gtf_ch_drpen;
  wire          gtf_ch_drpwe;
  wire [9:0]    gtf_ch_drpaddr;
  wire [15:0]   gtf_ch_drpdi;
  wire          gtf_ch_drprdy;
  wire [15:0]   gtf_ch_drpdo;
  
  wire   rx_clk;
  wire   tx_clk;
  wire   rx_resetn;
  wire   tx_resetn;
  wire   aclk;
  wire   aresetn;

  assign aclk       =   gtwiz_reset_clk_freerun_in;
  assign aresetn    =   ~gtwiz_reset_all_in;
  assign tx_clk     =   gtf_txusrclk2_out;
  assign rx_clk     =   gtf_rxusrclk2_out;
  assign tx_resetn  =   gtf_ch_txresetdone;
  assign rx_resetn  =   gtf_ch_rxresetdone;

      BUFG_GT u_txusrclk_inst (
        .CE      (1'b1),
        .CEMASK  (1'b0),
        .CLR     (1'b0),
        .CLRMASK (1'b0),
        .DIV     (3'd0),
        .I       (gtf_ch_txoutclk),
        .O       (gtf_ch_txusrclk)
      );

      BUFG_GT u_rxusrclk_inst (
        .CE      (1'b1),
        .CEMASK  (1'b0),
        .CLR     (1'b0),
        .CLRMASK (1'b0),
        .DIV     (3'd0),
        .I       (gtf_ch_rxoutclk),
        .O       (gtf_ch_rxusrclk)
      );

        gtfwizard_mac_delay_powergood #(
          .C_USER_GTPOWERGOOD_DELAY_EN (1)
        ) delay_powergood_inst (
          .GT_TXOUTCLKPCS       (gtf_ch_txoutclkpcs),

          .GT_GTPOWERGOOD       (i_gtf_ch_gtpowergood),
          .USER_GTPOWERGOOD     (gtf_ch_gtpowergood),

          .GT_GTTXRESET         (gtf_ch_gttxreset_out),
          .USER_GTTXRESET       (i_gtf_ch_gttxreset_out),
          .GT_TXPMARESET        (i_gtf_ch_txpmareset),
          .USER_TXPMARESET      (gtf_ch_txpmareset),
          .GT_TXPISOPD          (i_gtf_ch_txpisopd),
          .USER_TXPISOPD        (gtf_ch_txpisopd)
        );

  //assign gtf_ch_ctltxsendidle          =  ctl_tx_send_idle_axi;
  //assign gtf_ch_ctltxsendlfi           =  ctl_tx_send_lfi_axi;
  //assign gtf_ch_ctltxsendrfi           =  ctl_tx_send_rfi_axi;
  //assign gtf_ch_loopback               =  ctl_local_loopback;
  assign stat_rx_framing_err           =  gtf_ch_statrxframingerr;

  gtfwizard_mac_gtfmac_wrapper_axi_if_soft_top i_axi_if_soft_top (

    .ctl_local_loopback (ctl_local_loopback),
    .ctl_gt_reset_all (ctl_gt_reset_all),
    .ctl_gt_tx_reset (),
    .ctl_gt_rx_reset (),
    .ctl_tx_send_lfi (ctl_tx_send_lfi_axi),
    .ctl_tx_send_rfi (ctl_tx_send_rfi_axi),
    .ctl_tx_send_idle (ctl_tx_send_idle_axi),
    .ctl_tx_data_rate (ctl_tx_data_rate),
    .ctl_rx_data_rate                   (1'b0/*ctl_rx_data_rate[i]*/),          // input   wire
    .gtf_ch_rxptpsop            (gtf_ch_rxptpsop   ),
    .gtf_ch_rxptpsoppos         (gtf_ch_rxptpsoppos),
    .gtf_ch_rxgbseqstart        (gtf_ch_rxgbseqstart),
    .gtf_ch_txptpsop            (gtf_ch_txptpsop   ),
    .gtf_ch_txptpsoppos         (gtf_ch_txptpsoppos),
    .gtf_ch_txgbseqstart        (gtf_ch_txgbseqstart),
    .tx_ptp_tstamp_out          (tx_ptp_tstamp_out),
    .tx_ptp_tstamp_valid_out    (tx_ptp_tstamp_valid_out),
    .rx_ptp_tstamp_out          (rx_ptp_tstamp_out),
    .rx_ptp_tstamp_valid_out    (rx_ptp_tstamp_valid_out),

    .stat_rx_hi_ber (gtf_ch_statrxhiber),
    .stat_rx_status (gtf_ch_statrxstatus),
    .stat_rx_clk_align (1'b0),  
    .stat_rx_bit_slip (1'b0), 
    .stat_rx_pkt_err (gtf_ch_statrxpkterr),
    .stat_rx_bad_preamble (gtf_ch_statrxbadpreamble),
    .stat_rx_bad_sfd (gtf_ch_statrxbadsfd),
    .stat_rx_got_signal_os (gtf_ch_statrxgotsignalos),
    .stat_rx_local_fault (gtf_ch_statrxlocalfault),
    .stat_rx_remote_fault (gtf_ch_statrxremotefault),
    .stat_rx_internal_local_fault (gtf_ch_statrxinternallocalfault),
    .stat_rx_received_local_fault (gtf_ch_statrxreceivedlocalfault),

    .stat_rx_framing_err (stat_rx_framing_err_r),
    .stat_rx_bad_code (gtf_ch_statrxbadcode_r),
    .stat_rx_total_packets (stat_rx_total_packets_r),
    .stat_rx_total_good_packets (stat_rx_total_good_packets_r),
    .stat_rx_total_bytes (stat_rx_total_bytes_r),
    .stat_rx_total_good_bytes (stat_rx_total_good_bytes_r),
    .stat_rx_packet_small (stat_rx_packet_small_r),
    .stat_rx_jabber (stat_rx_jabber_r),
    .stat_rx_packet_large (stat_rx_packet_large_r),
    .stat_rx_oversize (stat_rx_oversize_r),
    .stat_rx_undersize (stat_rx_undersize_r),
    .stat_rx_toolong (stat_rx_toolong_r),
    .stat_rx_fragment (stat_rx_fragment_r),
    .stat_rx_packet_64_bytes (stat_rx_packet_64_bytes_r),
    .stat_rx_packet_65_127_bytes (stat_rx_packet_65_127_bytes_r),
    .stat_rx_packet_128_255_bytes (stat_rx_packet_128_255_bytes_r),
    .stat_rx_packet_256_511_bytes (stat_rx_packet_256_511_bytes_r),
    .stat_rx_packet_512_1023_bytes (stat_rx_packet_512_1023_bytes_r),
    .stat_rx_packet_1024_1518_bytes (stat_rx_packet_1024_1518_bytes_r),
    .stat_rx_packet_1519_1522_bytes (stat_rx_packet_1519_1522_bytes_r),
    .stat_rx_packet_1523_1548_bytes (stat_rx_packet_1523_1548_bytes_r),
    .stat_rx_total_err_bytes (stat_rx_total_err_bytes_r),
    .stat_rx_bad_fcs (stat_rx_bad_fcs_r),
    .stat_rx_packet_bad_fcs (stat_rx_packet_bad_fcs_r),
    .stat_rx_stomped_fcs (gtf_ch_statrxstompedfcs_r),
    .stat_rx_packet_1549_2047_bytes (stat_rx_packet_1549_2047_bytes_r),
    .stat_rx_packet_2048_4095_bytes (stat_rx_packet_2048_4095_bytes_r),
    .stat_rx_packet_4096_8191_bytes (stat_rx_packet_4096_8191_bytes_r),
    .stat_rx_packet_8192_9215_bytes (stat_rx_packet_8192_9215_bytes_r),
    .stat_rx_unicast (stat_rx_unicast_r),
    .stat_rx_multicast (stat_rx_multicast_r),
    .stat_rx_broadcast (stat_rx_broadcast_r),
    .stat_rx_vlan (stat_rx_vlan_r),
    .stat_rx_pause (stat_rx_pause_r),
    .stat_rx_user_pause (stat_rx_user_pause_r),
    .stat_rx_inrangeerr (stat_rx_inrangeerr_r),
    .stat_rx_truncated (gtf_ch_statrxtruncated_r),
    .stat_tx_total_packets (stat_tx_total_packets_r),
    .stat_tx_total_bytes (stat_tx_total_bytes_r),
    .stat_tx_total_good_packets (stat_tx_total_good_packets_r),
    .stat_tx_total_good_bytes (stat_tx_total_good_bytes_r),
    .stat_tx_packet_64_bytes (stat_tx_packet_64_bytes_r),
    .stat_tx_packet_65_127_bytes (stat_tx_packet_65_127_bytes_r),
    .stat_tx_packet_128_255_bytes (stat_tx_packet_128_255_bytes_r),
    .stat_tx_packet_256_511_bytes (stat_tx_packet_256_511_bytes_r),
    .stat_tx_packet_512_1023_bytes (stat_tx_packet_512_1023_bytes_r),
    .stat_tx_packet_1024_1518_bytes (stat_tx_packet_1024_1518_bytes_r),
    .stat_tx_packet_1519_1522_bytes (stat_tx_packet_1519_1522_bytes_r),
    .stat_tx_packet_1523_1548_bytes (stat_tx_packet_1523_1548_bytes_r),
    .stat_tx_packet_large (stat_tx_packet_large_r),
    .stat_tx_packet_small (stat_tx_packet_small_r),
    .stat_tx_total_err_bytes (stat_tx_total_err_bytes_r),
    .stat_tx_packet_1549_2047_bytes (stat_tx_packet_1549_2047_bytes_r),
    .stat_tx_packet_2048_4095_bytes (stat_tx_packet_2048_4095_bytes_r),
    .stat_tx_packet_4096_8191_bytes (stat_tx_packet_4096_8191_bytes_r),
    .stat_tx_packet_8192_9215_bytes (stat_tx_packet_8192_9215_bytes_r),
    .stat_tx_unicast (stat_tx_unicast_r),
    .stat_tx_multicast (stat_tx_multicast_r),
    .stat_tx_broadcast (stat_tx_broadcast_r),
    .stat_tx_vlan (stat_tx_vlan_r),
    .stat_tx_bad_fcs (stat_tx_bad_fcs_r),
    .stat_tx_frame_error (stat_tx_frame_error_r),

    .rx_clk ( rx_clk ),
    .tx_clk ( tx_clk ),
    .rx_resetn ( rx_resetn ),
    .tx_resetn ( tx_resetn ),

    .rx_resetn_out(  ),
    .tx_resetn_out( ),

    .s_axi_aclk (aclk),
    .s_axi_aresetn (aresetn),
    .s_axi_awaddr (m1_axi_awaddr),
    .s_axi_awvalid (m1_axi_awvalid),
    .s_axi_awready (m1_axi_awready),
    .s_axi_wdata (m1_axi_wdata),
    .s_axi_wstrb (m1_axi_wstrb),
    .s_axi_wvalid (m1_axi_wvalid),
    .s_axi_wready (m1_axi_wready),
    .s_axi_bresp (m1_axi_bresp),
    .s_axi_bvalid (m1_axi_bvalid),
    .s_axi_bready (m1_axi_bready),
    .s_axi_araddr (m1_axi_araddr),
    .s_axi_arvalid (m1_axi_arvalid),
    .s_axi_arready (m1_axi_arready),
    .s_axi_rdata (m1_axi_rdata),
    .s_axi_rresp (m1_axi_rresp),
    .s_axi_rvalid (m1_axi_rvalid),
    .s_axi_rready (m1_axi_rready),
    .pm_tick (1'b0)     
  );

  always @ (posedge rx_clk or negedge rx_resetn) begin
   
    if (!rx_resetn) begin

        gtf_ch_statrxbytes_r       <= 'd0;
        gtf_ch_statrxpkt_r         <= 'd0;
        gtf_ch_statrxpkterr_r      <= 'd0;
        gtf_ch_statrxtruncated_r   <= 'd0;
        gtf_ch_statrxbadfcs_r      <= 'd0;
        gtf_ch_statrxstompedfcs_r  <= 'd0;
        gtf_ch_statrxunicast_r     <= 'd0;
        gtf_ch_statrxmulticast_r   <= 'd0;
        gtf_ch_statrxbroadcast_r   <= 'd0;
        gtf_ch_statrxvlan_r        <= 'd0;
        gtf_ch_statrxinrangeerr_r  <= 'd0;
        gtf_ch_statrxbadcode_r     <= 'd0;
        stat_rx_framing_err_r      <= 'd0;

        stat_rx_unicast_r                   <= 'd0;
        stat_rx_multicast_r                 <= 'd0;
        stat_rx_broadcast_r                 <= 'd0;
        stat_rx_vlan_r                      <= 'd0;
        stat_rx_inrangeerr_r                <= 'd0;
        stat_rx_bad_fcs_r                   <= 'd0;

        stat_rx_total_bytes_r               <= 'd0;
        stat_rx_total_err_bytes_r           <= 'd0;
        stat_rx_total_good_bytes_r          <= 'd0;
        stat_rx_total_packets_r             <= 'd0;
        stat_rx_total_good_packets_r        <= 'd0;
        stat_rx_packet_64_bytes_r           <= 'd0;
        stat_rx_packet_65_127_bytes_r       <= 'd0;
        stat_rx_packet_128_255_bytes_r      <= 'd0;
        stat_rx_packet_256_511_bytes_r      <= 'd0;
        stat_rx_packet_512_1023_bytes_r     <= 'd0;
        stat_rx_packet_1024_1518_bytes_r    <= 'd0;
        stat_rx_packet_1519_1522_bytes_r    <= 'd0;
        stat_rx_packet_1523_1548_bytes_r    <= 'd0;
        stat_rx_packet_1549_2047_bytes_r    <= 'd0;
        stat_rx_packet_2048_4095_bytes_r    <= 'd0;
        stat_rx_packet_4096_8191_bytes_r    <= 'd0;
        stat_rx_packet_8192_9215_bytes_r    <= 'd0;
        stat_rx_oversize_r                  <= 'd0;
        stat_rx_undersize_r                 <= 'd0;
        stat_rx_toolong_r                   <= 'd0;
        stat_rx_packet_small_r              <= 'd0;
        stat_rx_packet_large_r              <= 'd0;
        stat_rx_user_pause_r                <= 'd0;
        stat_rx_pause_r                     <= 'd0;
        stat_rx_jabber_r                    <= 'd0;
        stat_rx_fragment_r                  <= 'd0;
        stat_rx_packet_bad_fcs_r            <= 'd0;

    end
    else begin

        gtf_ch_statrxbytes_r       <= gtf_ch_statrxbytes;
        gtf_ch_statrxpkt_r         <= gtf_ch_statrxpkt;
        gtf_ch_statrxpkterr_r      <= gtf_ch_statrxpkterr;
        gtf_ch_statrxtruncated_r   <= gtf_ch_statrxtruncated;
        gtf_ch_statrxbadfcs_r      <= gtf_ch_statrxbadfcs;
        gtf_ch_statrxstompedfcs_r  <= gtf_ch_statrxstompedfcs;
        gtf_ch_statrxunicast_r     <= gtf_ch_statrxunicast;
        gtf_ch_statrxmulticast_r   <= gtf_ch_statrxmulticast;
        gtf_ch_statrxbroadcast_r   <= gtf_ch_statrxbroadcast;
        gtf_ch_statrxvlan_r        <= gtf_ch_statrxvlan;
        gtf_ch_statrxinrangeerr_r  <= gtf_ch_statrxinrangeerr;
        gtf_ch_statrxbadcode_r     <= gtf_ch_statrxbadcode;

        stat_rx_unicast_r                   <= stat_rx_unicast;
        stat_rx_multicast_r                 <= stat_rx_multicast;
        stat_rx_broadcast_r                 <= stat_rx_broadcast;
        stat_rx_vlan_r                      <= stat_rx_vlan;
        stat_rx_inrangeerr_r                <= stat_rx_inrangeerr;
        stat_rx_bad_fcs_r                   <= stat_rx_bad_fcs;
        stat_rx_framing_err_r               <= stat_rx_framing_err;

        stat_rx_total_bytes_r               <= stat_rx_total_bytes;
        stat_rx_total_err_bytes_r           <= stat_rx_total_err_bytes;
        stat_rx_total_good_bytes_r          <= stat_rx_total_good_bytes;
        stat_rx_total_packets_r             <= stat_rx_total_packets;
        stat_rx_total_good_packets_r        <= stat_rx_total_good_packets;
        stat_rx_packet_64_bytes_r           <= stat_rx_packet_64_bytes;
        stat_rx_packet_65_127_bytes_r       <= stat_rx_packet_65_127_bytes;
        stat_rx_packet_128_255_bytes_r      <= stat_rx_packet_128_255_bytes;
        stat_rx_packet_256_511_bytes_r      <= stat_rx_packet_256_511_bytes;
        stat_rx_packet_512_1023_bytes_r     <= stat_rx_packet_512_1023_bytes;
        stat_rx_packet_1024_1518_bytes_r    <= stat_rx_packet_1024_1518_bytes;
        stat_rx_packet_1519_1522_bytes_r    <= stat_rx_packet_1519_1522_bytes;
        stat_rx_packet_1523_1548_bytes_r    <= stat_rx_packet_1523_1548_bytes;
        stat_rx_packet_1549_2047_bytes_r    <= stat_rx_packet_1549_2047_bytes;
        stat_rx_packet_2048_4095_bytes_r    <= stat_rx_packet_2048_4095_bytes;
        stat_rx_packet_4096_8191_bytes_r    <= stat_rx_packet_4096_8191_bytes;
        stat_rx_packet_8192_9215_bytes_r    <= stat_rx_packet_8192_9215_bytes;
        stat_rx_oversize_r                  <= stat_rx_oversize;
        stat_rx_undersize_r                 <= stat_rx_undersize;
        stat_rx_toolong_r                   <= stat_rx_toolong;
        stat_rx_packet_small_r              <= stat_rx_packet_small;
        stat_rx_packet_large_r              <= stat_rx_packet_large;
        stat_rx_user_pause_r                <= stat_rx_user_pause;
        stat_rx_pause_r                     <= stat_rx_pause;
        stat_rx_jabber_r                    <= stat_rx_jabber;
        stat_rx_fragment_r                  <= stat_rx_fragment;
        stat_rx_packet_bad_fcs_r            <= stat_rx_packet_bad_fcs;

    end

  end

  always @ (posedge tx_clk or negedge tx_resetn) begin

    if (!tx_resetn) begin

        stat_tx_bad_fcs_r                   <= 'd0;
        stat_tx_broadcast_r                 <= 'd0;
        stat_tx_multicast_r                 <= 'd0;
        stat_tx_unicast_r                   <= 'd0;
        stat_tx_vlan_r                      <= 'd0;

        stat_tx_total_bytes_r               <= 'd0;
        stat_tx_total_err_bytes_r           <= 'd0;
        stat_tx_total_good_bytes_r          <= 'd0;
        stat_tx_total_packets_r             <= 'd0;
        stat_tx_total_good_packets_r        <= 'd0;
        stat_tx_packet_64_bytes_r           <= 'd0;
        stat_tx_packet_65_127_bytes_r       <= 'd0;
        stat_tx_packet_128_255_bytes_r      <= 'd0;
        stat_tx_packet_256_511_bytes_r      <= 'd0;
        stat_tx_packet_512_1023_bytes_r     <= 'd0;
        stat_tx_packet_1024_1518_bytes_r    <= 'd0;
        stat_tx_packet_1519_1522_bytes_r    <= 'd0;
        stat_tx_packet_1523_1548_bytes_r    <= 'd0;
        stat_tx_packet_1549_2047_bytes_r    <= 'd0;
        stat_tx_packet_2048_4095_bytes_r    <= 'd0;
        stat_tx_packet_4096_8191_bytes_r    <= 'd0;
        stat_tx_packet_8192_9215_bytes_r    <= 'd0;
        stat_tx_packet_small_r              <= 'd0;
        stat_tx_packet_large_r              <= 'd0;
        stat_tx_frame_error_r               <= 'd0;

    end
    else begin

        stat_tx_bad_fcs_r                   <= stat_tx_bad_fcs;
        stat_tx_broadcast_r                 <= stat_tx_broadcast;
        stat_tx_multicast_r                 <= stat_tx_multicast;
        stat_tx_unicast_r                   <= stat_tx_unicast;
        stat_tx_vlan_r                      <= stat_tx_vlan;

        stat_tx_total_bytes_r               <= stat_tx_total_bytes;
        stat_tx_total_err_bytes_r           <= stat_tx_total_err_bytes;
        stat_tx_total_good_bytes_r          <= stat_tx_total_good_bytes;
        stat_tx_total_packets_r             <= stat_tx_total_packets;
        stat_tx_total_good_packets_r        <= stat_tx_total_good_packets;
        stat_tx_packet_64_bytes_r           <= stat_tx_packet_64_bytes;
        stat_tx_packet_65_127_bytes_r       <= stat_tx_packet_65_127_bytes;
        stat_tx_packet_128_255_bytes_r      <= stat_tx_packet_128_255_bytes;
        stat_tx_packet_256_511_bytes_r      <= stat_tx_packet_256_511_bytes;
        stat_tx_packet_512_1023_bytes_r     <= stat_tx_packet_512_1023_bytes;
        stat_tx_packet_1024_1518_bytes_r    <= stat_tx_packet_1024_1518_bytes;
        stat_tx_packet_1519_1522_bytes_r    <= stat_tx_packet_1519_1522_bytes;
        stat_tx_packet_1523_1548_bytes_r    <= stat_tx_packet_1523_1548_bytes;
        stat_tx_packet_1549_2047_bytes_r    <= stat_tx_packet_1549_2047_bytes;
        stat_tx_packet_2048_4095_bytes_r    <= stat_tx_packet_2048_4095_bytes;
        stat_tx_packet_4096_8191_bytes_r    <= stat_tx_packet_4096_8191_bytes;
        stat_tx_packet_8192_9215_bytes_r    <= stat_tx_packet_8192_9215_bytes;
        stat_tx_packet_small_r              <= stat_tx_packet_small;
        stat_tx_packet_large_r              <= stat_tx_packet_large;
        stat_tx_frame_error_r               <= stat_tx_frame_error;

    end

  end
   

  gtfwizard_mac_gtfmac_wrapper_stats_gasket i_wrapper_stats_gasket (
    .tx_axis_tpoison  (gtf_ch_txaxistpoison),
    .tx_axis_tready   (gtf_ch_txaxistready ),
    .tx_axis_tlast    (gtf_ch_txaxistlast  ),
    .tx_axis_tterm    (gtf_ch_txaxistterm  ),

  // connect these ctrl to output from axi_custom_crossbar_gtfmac for GTF
  // since the mac_cfg ports will be gone
    .ctl_rx_data_rate                   (1'b0/*ctl_rx_data_rate[i]*/),          // input   wire
    .ctl_rx_ignore_fcs (ctl_rx_ignore_fcs),
    .ctl_rx_min_packet_len (ctl_rx_min_packet_len),
    .ctl_rx_max_packet_len (ctl_rx_max_packet_len),
    .ctl_tx_data_rate (ctl_tx_data_rate),
    .ctl_tx_fcs_ins_enable (ctl_tx_fcs_ins_enable),
    .ctl_tx_ignore_fcs (ctl_tx_ignore_fcs),
    .ctl_tx_packet_framing_enable (1'b0),   // deprecated, always 0

    .stat_rx_total_packets (stat_rx_total_packets),
    .stat_rx_total_good_packets (stat_rx_total_good_packets),
    .stat_rx_total_bytes (stat_rx_total_bytes),
    .stat_rx_total_good_bytes (stat_rx_total_good_bytes),
    .stat_rx_packet_small (stat_rx_packet_small),
    .stat_rx_jabber (stat_rx_jabber),
    .stat_rx_packet_large (stat_rx_packet_large),
    .stat_rx_oversize (stat_rx_oversize),
    .stat_rx_undersize (stat_rx_undersize),
    .stat_rx_toolong (stat_rx_toolong),
    .stat_rx_fragment (stat_rx_fragment),
    .stat_rx_packet_64_bytes (stat_rx_packet_64_bytes),
    .stat_rx_packet_65_127_bytes (stat_rx_packet_65_127_bytes),
    .stat_rx_packet_128_255_bytes (stat_rx_packet_128_255_bytes),
    .stat_rx_packet_256_511_bytes (stat_rx_packet_256_511_bytes),
    .stat_rx_packet_512_1023_bytes (stat_rx_packet_512_1023_bytes),
    .stat_rx_packet_1024_1518_bytes (stat_rx_packet_1024_1518_bytes),
    .stat_rx_packet_1519_1522_bytes (stat_rx_packet_1519_1522_bytes),
    .stat_rx_packet_1523_1548_bytes (stat_rx_packet_1523_1548_bytes),
    .stat_rx_total_err_bytes (stat_rx_total_err_bytes),
    .stat_rx_bad_fcs (stat_rx_bad_fcs),
    .stat_rx_packet_bad_fcs (stat_rx_packet_bad_fcs),
    .stat_rx_packet_1549_2047_bytes (stat_rx_packet_1549_2047_bytes),
    .stat_rx_packet_2048_4095_bytes (stat_rx_packet_2048_4095_bytes),
    .stat_rx_packet_4096_8191_bytes (stat_rx_packet_4096_8191_bytes),
    .stat_rx_packet_8192_9215_bytes (stat_rx_packet_8192_9215_bytes),
    .stat_rx_unicast (stat_rx_unicast),
    .stat_rx_multicast (stat_rx_multicast),
    .stat_rx_broadcast (stat_rx_broadcast),
    .stat_rx_vlan (stat_rx_vlan),
    .stat_rx_pause (stat_rx_pause),
    .stat_rx_user_pause (stat_rx_user_pause),
    .stat_rx_inrangeerr (stat_rx_inrangeerr),
    .stat_rx_pause_valid (stat_rx_pause_valid),
    .stat_rx_pause_quanta0 (stat_rx_pause_quanta0),
    .stat_rx_pause_quanta1 (stat_rx_pause_quanta1),
    .stat_rx_pause_quanta2 (stat_rx_pause_quanta2),
    .stat_rx_pause_quanta3 (stat_rx_pause_quanta3),
    .stat_rx_pause_quanta4 (stat_rx_pause_quanta4),
    .stat_rx_pause_quanta5 (stat_rx_pause_quanta5),
    .stat_rx_pause_quanta6 (stat_rx_pause_quanta6),
    .stat_rx_pause_quanta7 (stat_rx_pause_quanta7),
    .stat_rx_pause_quanta8 (stat_rx_pause_quanta8),
    .stat_rx_pause_req (stat_rx_pause_req),
    .stat_tx_total_packets (stat_tx_total_packets),
    .stat_tx_total_bytes (stat_tx_total_bytes),
    .stat_tx_total_good_packets (stat_tx_total_good_packets),
    .stat_tx_total_good_bytes (stat_tx_total_good_bytes),
    .stat_tx_packet_64_bytes (stat_tx_packet_64_bytes),
    .stat_tx_packet_65_127_bytes (stat_tx_packet_65_127_bytes),
    .stat_tx_packet_128_255_bytes (stat_tx_packet_128_255_bytes),
    .stat_tx_packet_256_511_bytes (stat_tx_packet_256_511_bytes),
    .stat_tx_packet_512_1023_bytes (stat_tx_packet_512_1023_bytes),
    .stat_tx_packet_1024_1518_bytes (stat_tx_packet_1024_1518_bytes),
    .stat_tx_packet_1519_1522_bytes (stat_tx_packet_1519_1522_bytes),
    .stat_tx_packet_1523_1548_bytes (stat_tx_packet_1523_1548_bytes),
    .stat_tx_packet_large (stat_tx_packet_large),
    .stat_tx_packet_small (stat_tx_packet_small),
    .stat_tx_total_err_bytes (stat_tx_total_err_bytes),
    .stat_tx_packet_1549_2047_bytes (stat_tx_packet_1549_2047_bytes),
    .stat_tx_packet_2048_4095_bytes (stat_tx_packet_2048_4095_bytes),
    .stat_tx_packet_4096_8191_bytes (stat_tx_packet_4096_8191_bytes),
    .stat_tx_packet_8192_9215_bytes (stat_tx_packet_8192_9215_bytes),
    .stat_tx_unicast (stat_tx_unicast),
    .stat_tx_multicast (stat_tx_multicast),
    .stat_tx_broadcast (stat_tx_broadcast),
    .stat_tx_vlan (stat_tx_vlan),
    .stat_tx_bad_fcs (stat_tx_bad_fcs),
    .stat_tx_frame_error (stat_tx_frame_error),

    .gtfmac_stat_rx_bytes       (gtf_ch_statrxbytes_r),
    .gtfmac_stat_rx_pkt         (gtf_ch_statrxpkt_r),
    .gtfmac_stat_rx_pkt_err     (gtf_ch_statrxpkterr_r),
    .gtfmac_stat_rx_truncated   (gtf_ch_statrxtruncated_r),
    .gtfmac_stat_rx_bad_fcs     (gtf_ch_statrxbadfcs_r),
    .gtfmac_stat_rx_stomped_fcs (gtf_ch_statrxstompedfcs_r),
    .gtfmac_stat_rx_unicast     (gtf_ch_statrxunicast_r),
    .gtfmac_stat_rx_broadcast   (gtf_ch_statrxbroadcast_r),
    .gtfmac_stat_rx_multicast   (gtf_ch_statrxmulticast_r),
    .gtfmac_stat_rx_vlan        (gtf_ch_statrxvlan_r),
    .gtfmac_stat_rx_inrangeerr  (gtf_ch_statrxinrangeerr_r),

    .gtfmac_rx_pause_quanta     (gtf_ch_statrxpausequanta),
    .gtfmac_rx_pause_req        (gtf_ch_statrxpausereq),
    .gtfmac_rx_pause_valid      (gtf_ch_statrxpausevalid[0]) ,

    .gtfmac_stat_tx_bytes       (gtf_ch_stattxbytes),
    .gtfmac_stat_tx_pkt         (gtf_ch_stattxpkt),
    .gtfmac_stat_tx_pkt_err     (gtf_ch_stattxpkterr),
    .gtfmac_stat_tx_bad_fcs     (gtf_ch_stattxbadfcs),
    .gtfmac_stat_tx_unicast     (gtf_ch_stattxunicast),
    .gtfmac_stat_tx_broadcast   (gtf_ch_stattxbroadcast),
    .gtfmac_stat_tx_multicast   (gtf_ch_stattxmulticast),
    .gtfmac_stat_tx_vlan        (gtf_ch_stattxvlan),
                                
    .rx_clk                     (rx_clk),
    .tx_clk                     (tx_clk),
    .rx_reset                   (rx_resetn),
    .tx_reset                   (tx_resetn)
  );

assign gtwiz_buffbypass_rx_reset = ~gtf_ch_rxresetdone;

gtfwizard_mac_gtfmac_wrapper_drp_bridge #(
    .DRP_COUNT(1),
    .DRP_ADDR_WIDTH(10),
    .DRP_DATA_WIDTH(16)
    ) u_gtfmac_wrapper_drp_bridge (
    .s_axi_aclk (aclk),
    .s_axi_aresetn (aresetn),
    .s_axi_awaddr (m0_axi_awaddr),
    .s_axi_awvalid (m0_axi_awvalid),
    .s_axi_awready (m0_axi_awready),
    .s_axi_wdata (m0_axi_wdata),
    .s_axi_wstrb (m0_axi_wstrb),
    .s_axi_wvalid (m0_axi_wvalid),
    .s_axi_wready (m0_axi_wready),
    .s_axi_bresp (m0_axi_bresp),
    .s_axi_bvalid (m0_axi_bvalid),
    .s_axi_bready (m0_axi_bready),
    .s_axi_araddr (m0_axi_araddr),
    .s_axi_arvalid (m0_axi_arvalid),
    .s_axi_arready (m0_axi_arready),
    .s_axi_rdata (m0_axi_rdata),
    .s_axi_rresp (m0_axi_rresp),
    .s_axi_rvalid (m0_axi_rvalid),
    .s_axi_rready (m0_axi_rready),
  
    /*.drp_en({gtf_cm_drpen,drp_bridge_drpen}),
    .drp_we({gtf_cm_drpwe,drp_bridge_drpwe}),
    .drp_addr({gtf_cm_drpaddr[9:0],drp_bridge_drpaddr[9:0]}),
    .drp_di({gtf_cm_drpdi,drp_bridge_drpdi}),
    .drp_do({gtf_cm_drpdo,drp_bridge_drpdo}),
    .drp_rdy({gtf_cm_drprdy,drp_bridge_drprdy})*/
    .drp_en(drp_bridge_drpen),
    .drp_we(drp_bridge_drpwe),
    .drp_addr(drp_bridge_drpaddr),
    .drp_di(drp_bridge_drpdi),
    .drp_do(drp_bridge_drpdo),
    .drp_rdy(drp_bridge_drprdy)

);

// This mux selects whether we are driving the DRP with the alignment logic or the bridge
assign  gtf_ch_drpen                   =  gtf_ch_drp_reconfig_rdy ? drp_align_drpen   : drp_bridge_drpen;
assign  gtf_ch_drpwe                   =  gtf_ch_drp_reconfig_rdy ? drp_align_drpwe   : drp_bridge_drpwe;
assign  gtf_ch_drpaddr                 =  gtf_ch_drp_reconfig_rdy ? drp_align_drpaddr : drp_bridge_drpaddr;
assign  gtf_ch_drpdi                   =  gtf_ch_drp_reconfig_rdy ? drp_align_drpdi   : drp_bridge_drpdi;

assign  drp_bridge_drpdo               =  gtf_ch_drp_reconfig_rdy ? 16'd0 : gtf_ch_drpdo;
assign  drp_bridge_drprdy              =  gtf_ch_drp_reconfig_rdy ? 1'b0  : gtf_ch_drprdy;
assign  drp_align_drprdy               =  gtf_ch_drp_reconfig_rdy ? gtf_ch_drprdy : 1'b0;
assign  drp_align_drpdo                =  gtf_ch_drp_reconfig_rdy ? gtf_ch_drpdo : 16'd0;


gtfwizard_mac_gtfmac_wrapper_axi_custom_crossbar i_custom_crossbar_gtfmac (
    .S0_s_axi_aclk (aclk),
    .S0_s_axi_aresetn (aresetn),

    .S0_s_axi_awvalid (s_axi_awvalid),
    .S0_s_axi_awready (s_axi_awready),
    .S0_s_axi_wdata (s_axi_wdata),
    .S0_s_axi_wstrb (s_axi_wstrb),
    .S0_s_axi_wvalid (s_axi_wvalid),
    .S0_s_axi_wready (s_axi_wready),
    .S0_s_axi_bresp (s_axi_bresp),
    .S0_s_axi_bvalid (s_axi_bvalid),
    .S0_s_axi_bready (s_axi_bready),
    .S0_s_axi_arvalid (s_axi_arvalid),
    .S0_s_axi_arready (s_axi_arready),
    .S0_s_axi_rdata (s_axi_rdata),
    .S0_s_axi_rresp (s_axi_rresp),
    .S0_s_axi_rvalid (s_axi_rvalid),
    .S0_s_axi_rready (s_axi_rready),
    .S0_s_axi_awaddr (s_axi_awaddr & 32'h0000FFFF),
    .S0_s_axi_araddr (s_axi_araddr & 32'h0000FFFF),

    .M0_m_axi_awaddr (m0_axi_awaddr),
    .M0_m_axi_awvalid (m0_axi_awvalid),
    .M0_m_axi_awready (m0_axi_awready),
    .M0_m_axi_wdata (m0_axi_wdata),
    .M0_m_axi_wstrb (m0_axi_wstrb),
    .M0_m_axi_wvalid (m0_axi_wvalid),
    .M0_m_axi_wready (m0_axi_wready),
    .M0_m_axi_bresp (m0_axi_bresp),
    .M0_m_axi_bvalid (m0_axi_bvalid),
    .M0_m_axi_bready (m0_axi_bready),
    .M0_m_axi_araddr (m0_axi_araddr),
    .M0_m_axi_arvalid (m0_axi_arvalid),
    .M0_m_axi_arready (m0_axi_arready),
    .M0_m_axi_rdata (m0_axi_rdata),
    .M0_m_axi_rresp (m0_axi_rresp),
    .M0_m_axi_rvalid (m0_axi_rvalid),
    .M0_m_axi_rready (m0_axi_rready),

    .M1_m_axi_awaddr (m1_axi_awaddr),
    .M1_m_axi_awvalid (m1_axi_awvalid),
    .M1_m_axi_awready (m1_axi_awready),
    .M1_m_axi_wdata (m1_axi_wdata),
    .M1_m_axi_wstrb (m1_axi_wstrb),
    .M1_m_axi_wvalid (m1_axi_wvalid),
    .M1_m_axi_wready (m1_axi_wready),
    .M1_m_axi_bresp (m1_axi_bresp),
    .M1_m_axi_bvalid (m1_axi_bvalid),
    .M1_m_axi_bready (m1_axi_bready),
    .M1_m_axi_araddr (m1_axi_araddr),
    .M1_m_axi_arvalid (m1_axi_arvalid),
    .M1_m_axi_arready (m1_axi_arready),
    .M1_m_axi_rdata (m1_axi_rdata),
    .M1_m_axi_rresp (m1_axi_rresp),
    .M1_m_axi_rvalid (m1_axi_rvalid),
    .M1_m_axi_rready (m1_axi_rready),

    .ctl_tx_data_rate (ctl_tx_data_rate),
    .ctl_tx_ignore_fcs (ctl_tx_ignore_fcs),
    .ctl_tx_fcs_ins_enable (ctl_tx_fcs_ins_enable),
    .ctl_rx_data_rate (ctl_rx_data_rate_i),
    .ctl_rx_ignore_fcs (ctl_rx_ignore_fcs),
    .ctl_rx_min_packet_len (ctl_rx_min_packet_len),
    .ctl_rx_max_packet_len (ctl_rx_max_packet_len)
  );


gtfwizard_mac_gtf_channel # (
.ACJTAG_DEBUG_MODE              (ACJTAG_DEBUG_MODE              ),
.ACJTAG_MODE                    (ACJTAG_MODE                    ),
.ACJTAG_RESET                   (ACJTAG_RESET                   ),
.ADAPT_CFG0                     (ADAPT_CFG0                     ),
.ADAPT_CFG1                     (ADAPT_CFG1                     ),
.ADAPT_CFG2                     (ADAPT_CFG2                     ),
.A_RXOSCALRESET                 (A_RXOSCALRESET                 ),
.A_RXPROGDIVRESET               (A_RXPROGDIVRESET               ),
.A_RXTERMINATION                (A_RXTERMINATION                ),
.A_TXDIFFCTRL                   (A_TXDIFFCTRL                   ),
.A_TXPROGDIVRESET               (A_TXPROGDIVRESET               ),
.CBCC_DATA_SOURCE_SEL           (CBCC_DATA_SOURCE_SEL           ),
.CDR_SWAP_MODE_EN               (CDR_SWAP_MODE_EN               ),
.CFOK_PWRSVE_EN                 (CFOK_PWRSVE_EN                 ),
.CH_HSPMUX                      (CH_HSPMUX                      ),
.CKCAL1_CFG_0                   (CKCAL1_CFG_0                   ),
.CKCAL1_CFG_1                   (CKCAL1_CFG_1                   ),
.CKCAL1_CFG_2                   (CKCAL1_CFG_2                   ),
.CKCAL1_CFG_3                   (CKCAL1_CFG_3                   ),
.CKCAL2_CFG_0                   (CKCAL2_CFG_0                   ),
.CKCAL2_CFG_1                   (CKCAL2_CFG_1                   ),
.CKCAL2_CFG_2                   (CKCAL2_CFG_2                   ),
.CKCAL2_CFG_3                   (CKCAL2_CFG_3                   ),
.CKCAL2_CFG_4                   (CKCAL2_CFG_4                   ),
.CPLL_CFG0                      (CPLL_CFG0                      ),
.CPLL_CFG1                      (CPLL_CFG1                      ),
.CPLL_CFG2                      (CPLL_CFG2                      ),
.CPLL_CFG3                      (CPLL_CFG3                      ),
.CPLL_FBDIV                     (CPLL_FBDIV                     ),
.CPLL_FBDIV_45                  (CPLL_FBDIV_45                  ),
.CPLL_INIT_CFG0                 (CPLL_INIT_CFG0                 ),
.CPLL_LOCK_CFG                  (CPLL_LOCK_CFG                  ),
.CPLL_REFCLK_DIV                (CPLL_REFCLK_DIV                ),
.CTLE3_OCAP_EXT_CTRL            (CTLE3_OCAP_EXT_CTRL            ),
.CTLE3_OCAP_EXT_EN              (CTLE3_OCAP_EXT_EN              ),
.DDI_CTRL                       (DDI_CTRL                       ),
.DDI_REALIGN_WAIT               (DDI_REALIGN_WAIT               ),
.DELAY_ELEC                     (DELAY_ELEC                     ),
.DMONITOR_CFG0                  (DMONITOR_CFG0                  ),
.DMONITOR_CFG1                  (DMONITOR_CFG1                  ),
.ES_CLK_PHASE_SEL               (ES_CLK_PHASE_SEL               ),
.ES_CONTROL                     (ES_CONTROL                     ),
.ES_ERRDET_EN                   (ES_ERRDET_EN                   ),
.ES_EYE_SCAN_EN                 (ES_EYE_SCAN_EN                 ),
.ES_HORZ_OFFSET                 (ES_HORZ_OFFSET                 ),
.ES_PRESCALE                    (ES_PRESCALE                    ),
.ES_QUALIFIER0                  (ES_QUALIFIER0                  ),
.ES_QUALIFIER1                  (ES_QUALIFIER1                  ),
.ES_QUALIFIER2                  (ES_QUALIFIER2                  ),
.ES_QUALIFIER3                  (ES_QUALIFIER3                  ),
.ES_QUALIFIER4                  (ES_QUALIFIER4                  ),
.ES_QUALIFIER5                  (ES_QUALIFIER5                  ),
.ES_QUALIFIER6                  (ES_QUALIFIER6                  ),
.ES_QUALIFIER7                  (ES_QUALIFIER7                  ),
.ES_QUALIFIER8                  (ES_QUALIFIER8                  ),
.ES_QUALIFIER9                  (ES_QUALIFIER9                  ),
.ES_QUAL_MASK0                  (ES_QUAL_MASK0                  ),
.ES_QUAL_MASK1                  (ES_QUAL_MASK1                  ),
.ES_QUAL_MASK2                  (ES_QUAL_MASK2                  ),
.ES_QUAL_MASK3                  (ES_QUAL_MASK3                  ),
.ES_QUAL_MASK4                  (ES_QUAL_MASK4                  ),
.ES_QUAL_MASK5                  (ES_QUAL_MASK5                  ),
.ES_QUAL_MASK6                  (ES_QUAL_MASK6                  ),
.ES_QUAL_MASK7                  (ES_QUAL_MASK7                  ),
.ES_QUAL_MASK8                  (ES_QUAL_MASK8                  ),
.ES_QUAL_MASK9                  (ES_QUAL_MASK9                  ),
.ES_SDATA_MASK0                 (ES_SDATA_MASK0                 ),
.ES_SDATA_MASK1                 (ES_SDATA_MASK1                 ),
.ES_SDATA_MASK2                 (ES_SDATA_MASK2                 ),
.ES_SDATA_MASK3                 (ES_SDATA_MASK3                 ),
.ES_SDATA_MASK4                 (ES_SDATA_MASK4                 ),
.ES_SDATA_MASK5                 (ES_SDATA_MASK5                 ),
.ES_SDATA_MASK6                 (ES_SDATA_MASK6                 ),
.ES_SDATA_MASK7                 (ES_SDATA_MASK7                 ),
.ES_SDATA_MASK8                 (ES_SDATA_MASK8                 ),
.ES_SDATA_MASK9                 (ES_SDATA_MASK9                 ),
.EYESCAN_VP_RANGE               (EYESCAN_VP_RANGE               ),
.EYE_SCAN_SWAP_EN               (EYE_SCAN_SWAP_EN               ),
.FTS_DESKEW_SEQ_ENABLE          (FTS_DESKEW_SEQ_ENABLE          ),
.FTS_LANE_DESKEW_CFG            (FTS_LANE_DESKEW_CFG            ),
.FTS_LANE_DESKEW_EN             (FTS_LANE_DESKEW_EN             ),
.GEARBOX_MODE                   (GEARBOX_MODE                   ),
.ISCAN_CK_PH_SEL2               (ISCAN_CK_PH_SEL2               ),
.LOCAL_MASTER                   (LOCAL_MASTER                   ),
.LPBK_BIAS_CTRL                 (LPBK_BIAS_CTRL                 ),
.LPBK_EN_RCAL_B                 (LPBK_EN_RCAL_B                 ),
.LPBK_EXT_RCAL                  (LPBK_EXT_RCAL                  ),
.LPBK_IND_CTRL0                 (LPBK_IND_CTRL0                 ),
.LPBK_IND_CTRL1                 (LPBK_IND_CTRL1                 ),
.LPBK_IND_CTRL2                 (LPBK_IND_CTRL2                 ),
.LPBK_RG_CTRL                   (LPBK_RG_CTRL                   ),
.MAC_CFG0                       (MAC_CFG0                       ),
.MAC_CFG1                       (MAC_CFG1                       ),
.MAC_CFG10                      (MAC_CFG10                      ),
.MAC_CFG11                      (MAC_CFG11                      ),
.MAC_CFG12                      (MAC_CFG12                      ),
.MAC_CFG13                      (MAC_CFG13                      ),
.MAC_CFG14                      (MAC_CFG14                      ),
.MAC_CFG15                      (MAC_CFG15                      ),
.MAC_CFG2                       (MAC_CFG2                       ),
.MAC_CFG3                       (MAC_CFG3                       ),
.MAC_CFG4                       (MAC_CFG4                       ),
.MAC_CFG5                       (MAC_CFG5                       ),
.MAC_CFG6                       (MAC_CFG6                       ),
.MAC_CFG7                       (MAC_CFG7                       ),
.MAC_CFG8                       (MAC_CFG8                       ),
.MAC_CFG9                       (MAC_CFG9                       ),
.PCS_RSVD0                      (PCS_RSVD0                      ),
.PD_TRANS_TIME_FROM_P2          (PD_TRANS_TIME_FROM_P2          ),
.PD_TRANS_TIME_NONE_P2          (PD_TRANS_TIME_NONE_P2          ),
.PD_TRANS_TIME_TO_P2            (PD_TRANS_TIME_TO_P2            ),
.PREIQ_FREQ_BST                 (PREIQ_FREQ_BST                 ),
.RAW_MAC_CFG                    (RAW_MAC_CFG                    ),
.RCLK_SIPO_DLY_ENB              (RCLK_SIPO_DLY_ENB              ),
.RCLK_SIPO_INV_EN               (RCLK_SIPO_INV_EN               ),
.RCO_NEW_MAC_CFG0               (RCO_NEW_MAC_CFG0               ),
.RCO_NEW_MAC_CFG1               (RCO_NEW_MAC_CFG1               ),
.RCO_NEW_MAC_CFG2               (RCO_NEW_MAC_CFG2               ),
.RCO_NEW_MAC_CFG3               (RCO_NEW_MAC_CFG3               ),
.RCO_NEW_RAW_CFG0               (RCO_NEW_RAW_CFG0               ),
.RCO_NEW_RAW_CFG1               (RCO_NEW_RAW_CFG1               ),
.RCO_NEW_RAW_CFG2               (RCO_NEW_RAW_CFG2               ),
.RCO_NEW_RAW_CFG3               (RCO_NEW_RAW_CFG3               ),
.RTX_BUF_CML_CTRL               (RTX_BUF_CML_CTRL               ),
.RTX_BUF_TERM_CTRL              (RTX_BUF_TERM_CTRL              ),
.RXBUFRESET_TIME                (RXBUFRESET_TIME                ),
.RXBUF_EN                       (RXBUF_EN                       ),
.RXCDRFREQRESET_TIME            (RXCDRFREQRESET_TIME            ),
.RXCDRPHRESET_TIME              (RXCDRPHRESET_TIME              ),
.RXCDR_CFG0                     (RXCDR_CFG0                     ),
.RXCDR_CFG1                     (RXCDR_CFG1                     ),
.RXCDR_CFG2                     (RXCDR_CFG2                     ),
.RXCDR_CFG3                     (RXCDR_CFG3                     ),
.RXCDR_CFG4                     (RXCDR_CFG4                     ),
.RXCDR_CFG5                     (RXCDR_CFG5                     ),
.RXCDR_FR_RESET_ON_EIDLE        (RXCDR_FR_RESET_ON_EIDLE        ),
.RXCDR_HOLD_DURING_EIDLE        (RXCDR_HOLD_DURING_EIDLE        ),
.RXCDR_LOCK_CFG0                (RXCDR_LOCK_CFG0                ),
.RXCDR_LOCK_CFG1                (RXCDR_LOCK_CFG1                ),
.RXCDR_LOCK_CFG2                (RXCDR_LOCK_CFG2                ),
.RXCDR_LOCK_CFG3                (RXCDR_LOCK_CFG3                ),
.RXCDR_LOCK_CFG4                (RXCDR_LOCK_CFG4                ),
.RXCDR_PH_RESET_ON_EIDLE        (RXCDR_PH_RESET_ON_EIDLE        ),
.RXCFOK_CFG0                    (RXCFOK_CFG0                    ),
.RXCFOK_CFG1                    (RXCFOK_CFG1                    ),
.RXCFOK_CFG2                    (RXCFOK_CFG2                    ),
.RXCKCAL1_IQ_LOOP_RST_CFG       (RXCKCAL1_IQ_LOOP_RST_CFG       ),
.RXCKCAL1_I_LOOP_RST_CFG        (RXCKCAL1_I_LOOP_RST_CFG        ),
.RXCKCAL1_Q_LOOP_RST_CFG        (RXCKCAL1_Q_LOOP_RST_CFG        ),
.RXCKCAL2_DX_LOOP_RST_CFG       (RXCKCAL2_DX_LOOP_RST_CFG       ),
.RXCKCAL2_D_LOOP_RST_CFG        (RXCKCAL2_D_LOOP_RST_CFG        ),
.RXCKCAL2_S_LOOP_RST_CFG        (RXCKCAL2_S_LOOP_RST_CFG        ),
.RXCKCAL2_X_LOOP_RST_CFG        (RXCKCAL2_X_LOOP_RST_CFG        ),
.RXDFELPMRESET_TIME             (RXDFELPMRESET_TIME             ),
.RXDFELPM_KL_CFG0               (RXDFELPM_KL_CFG0               ),
.RXDFELPM_KL_CFG1               (RXDFELPM_KL_CFG1               ),
.RXDFELPM_KL_CFG2               (RXDFELPM_KL_CFG2               ),
.RXDFE_CFG0                     (RXDFE_CFG0                     ),
.RXDFE_CFG1                     (RXDFE_CFG1                     ),
.RXDFE_GC_CFG0                  (RXDFE_GC_CFG0                  ),
.RXDFE_GC_CFG1                  (RXDFE_GC_CFG1                  ),
.RXDFE_GC_CFG2                  (RXDFE_GC_CFG2                  ),
.RXDFE_H2_CFG0                  (RXDFE_H2_CFG0                  ),
.RXDFE_H2_CFG1                  (RXDFE_H2_CFG1                  ),
.RXDFE_H3_CFG0                  (RXDFE_H3_CFG0                  ),
.RXDFE_H3_CFG1                  (RXDFE_H3_CFG1                  ),
.RXDFE_H4_CFG0                  (RXDFE_H4_CFG0                  ),
.RXDFE_H4_CFG1                  (RXDFE_H4_CFG1                  ),
.RXDFE_H5_CFG0                  (RXDFE_H5_CFG0                  ),
.RXDFE_H5_CFG1                  (RXDFE_H5_CFG1                  ),
.RXDFE_H6_CFG0                  (RXDFE_H6_CFG0                  ),
.RXDFE_H6_CFG1                  (RXDFE_H6_CFG1                  ),
.RXDFE_H7_CFG0                  (RXDFE_H7_CFG0                  ),
.RXDFE_H7_CFG1                  (RXDFE_H7_CFG1                  ),
.RXDFE_H8_CFG0                  (RXDFE_H8_CFG0                  ),
.RXDFE_H8_CFG1                  (RXDFE_H8_CFG1                  ),
.RXDFE_H9_CFG0                  (RXDFE_H9_CFG0                  ),
.RXDFE_H9_CFG1                  (RXDFE_H9_CFG1                  ),
.RXDFE_HA_CFG0                  (RXDFE_HA_CFG0                  ),
.RXDFE_HA_CFG1                  (RXDFE_HA_CFG1                  ),
.RXDFE_HB_CFG0                  (RXDFE_HB_CFG0                  ),
.RXDFE_HB_CFG1                  (RXDFE_HB_CFG1                  ),
.RXDFE_HC_CFG0                  (RXDFE_HC_CFG0                  ),
.RXDFE_HC_CFG1                  (RXDFE_HC_CFG1                  ),
.RXDFE_HD_CFG0                  (RXDFE_HD_CFG0                  ),
.RXDFE_HD_CFG1                  (RXDFE_HD_CFG1                  ),
.RXDFE_HE_CFG0                  (RXDFE_HE_CFG0                  ),
.RXDFE_HE_CFG1                  (RXDFE_HE_CFG1                  ),
.RXDFE_HF_CFG0                  (RXDFE_HF_CFG0                  ),
.RXDFE_HF_CFG1                  (RXDFE_HF_CFG1                  ),
.RXDFE_KH_CFG0                  (RXDFE_KH_CFG0                  ),
.RXDFE_KH_CFG1                  (RXDFE_KH_CFG1                  ),
.RXDFE_KH_CFG2                  (RXDFE_KH_CFG2                  ),
.RXDFE_KH_CFG3                  (RXDFE_KH_CFG3                  ),
.RXDFE_OS_CFG0                  (RXDFE_OS_CFG0                  ),
.RXDFE_OS_CFG1                  (RXDFE_OS_CFG1                  ),
.RXDFE_UT_CFG0                  (RXDFE_UT_CFG0                  ),
.RXDFE_UT_CFG1                  (RXDFE_UT_CFG1                  ),
.RXDFE_UT_CFG2                  (RXDFE_UT_CFG2                  ),
.RXDFE_VP_CFG0                  (RXDFE_VP_CFG0                  ),
.RXDFE_VP_CFG1                  (RXDFE_VP_CFG1                  ),
.RXDLY_CFG                      (RXDLY_CFG                      ),
.RXDLY_LCFG                     (RXDLY_LCFG                     ),
.RXDLY_RAW_CFG                  (RXDLY_RAW_CFG                  ),
.RXDLY_RAW_LCFG                 (RXDLY_RAW_LCFG                 ),
.RXELECIDLE_CFG                 (RXELECIDLE_CFG                 ),
.RXGBOX_FIFO_INIT_RD_ADDR       (RXGBOX_FIFO_INIT_RD_ADDR       ),
.RXGEARBOX_EN                   (RXGEARBOX_EN                   ),
.RXISCANRESET_TIME              (RXISCANRESET_TIME              ),
.RXLPM_CFG                      (RXLPM_CFG                      ),
.RXLPM_GC_CFG                   (RXLPM_GC_CFG                   ),
.RXLPM_KH_CFG0                  (RXLPM_KH_CFG0                  ),
.RXLPM_KH_CFG1                  (RXLPM_KH_CFG1                  ),
.RXLPM_OS_CFG0                  (RXLPM_OS_CFG0                  ),
.RXLPM_OS_CFG1                  (RXLPM_OS_CFG1                  ),
.RXOSCALRESET_TIME              (RXOSCALRESET_TIME              ),
.RXOUT_DIV                      (RXOUT_DIV                      ),
.RXPCSRESET_TIME                (RXPCSRESET_TIME                ),
.RXPHBEACON_CFG                 (RXPHBEACON_CFG                 ),
.RXPHBEACON_RAW_CFG             (RXPHBEACON_RAW_CFG             ),
.RXPHDLY_CFG                    (RXPHDLY_CFG                    ),
.RXPHSAMP_CFG                   (RXPHSAMP_CFG                   ),
.RXPHSAMP_RAW_CFG               (RXPHSAMP_RAW_CFG               ),
.RXPHSLIP_CFG                   (RXPHSLIP_CFG                   ),
.RXPHSLIP_RAW_CFG               (RXPHSLIP_RAW_CFG               ),
.RXPH_MONITOR_SEL               (RXPH_MONITOR_SEL               ),
.RXPI_CFG0                      (RXPI_CFG0                      ),
.RXPI_CFG1                      (RXPI_CFG1                      ),
.RXPMACLK_SEL                   (RXPMACLK_SEL                   ),
.RXPMARESET_TIME                (RXPMARESET_TIME                ),
.RXPRBS_ERR_LOOPBACK            (RXPRBS_ERR_LOOPBACK            ),
.RXPRBS_LINKACQ_CNT             (RXPRBS_LINKACQ_CNT             ),
.RXREFCLKDIV2_SEL               (RXREFCLKDIV2_SEL               ),
.RXSLIDE_AUTO_WAIT              (RXSLIDE_AUTO_WAIT              ),
.RXSLIDE_MODE                   (RXSLIDE_MODE                   ),
.RXSYNC_MULTILANE               (RXSYNC_MULTILANE               ),
.RXSYNC_OVRD                    (RXSYNC_OVRD                    ),
.RXSYNC_SKIP_DA                 (RXSYNC_SKIP_DA                 ),
.RX_AFE_CM_EN                   (RX_AFE_CM_EN                   ),
.RX_BIAS_CFG0                   (RX_BIAS_CFG0                   ),
.RX_CAPFF_SARC_ENB              (RX_CAPFF_SARC_ENB              ),
.RX_CLK25_DIV                   (RX_CLK25_DIV                   ),
.RX_CLKMUX_EN                   (RX_CLKMUX_EN                   ),
.RX_CLK_SLIP_OVRD               (RX_CLK_SLIP_OVRD               ),
.RX_CM_BUF_CFG                  (RX_CM_BUF_CFG                  ),
.RX_CM_BUF_PD                   (RX_CM_BUF_PD                   ),
.RX_CM_SEL                      (RX_CM_SEL                      ),
.RX_CM_TRIM                     (RX_CM_TRIM                     ),
.RX_CTLE_PWR_SAVING             (RX_CTLE_PWR_SAVING             ),
.RX_CTLE_RES_CTRL               (RX_CTLE_RES_CTRL               ),
.RX_DATA_WIDTH                  (RX_DATA_WIDTH                  ),
.RX_DDI_SEL                     (RX_DDI_SEL                     ),
.RX_DEGEN_CTRL                  (RX_DEGEN_CTRL                  ),
.RX_DFELPM_CFG0                 (RX_DFELPM_CFG0                 ),
.RX_DFELPM_CFG1                 (RX_DFELPM_CFG1                 ),
.RX_DFELPM_KLKH_AGC_STUP_EN     (RX_DFELPM_KLKH_AGC_STUP_EN     ),
.RX_DFE_AGC_CFG1                (RX_DFE_AGC_CFG1                ),
.RX_DFE_KL_LPM_KH_CFG0          (RX_DFE_KL_LPM_KH_CFG0          ),
.RX_DFE_KL_LPM_KH_CFG1          (RX_DFE_KL_LPM_KH_CFG1          ),
.RX_DFE_KL_LPM_KL_CFG0          (RX_DFE_KL_LPM_KL_CFG0          ),
.RX_DFE_KL_LPM_KL_CFG1          (RX_DFE_KL_LPM_KL_CFG1          ),
.RX_DFE_LPM_HOLD_DURING_EIDLE   (RX_DFE_LPM_HOLD_DURING_EIDLE   ),
.RX_DISPERR_SEQ_MATCH           (RX_DISPERR_SEQ_MATCH           ),
.RX_DIVRESET_TIME               (RX_DIVRESET_TIME               ),
.RX_EN_CTLE_RCAL_B              (RX_EN_CTLE_RCAL_B              ),
.RX_EN_SUM_RCAL_B               (RX_EN_SUM_RCAL_B               ),
.RX_EYESCAN_VS_CODE             (RX_EYESCAN_VS_CODE             ),
.RX_EYESCAN_VS_NEG_DIR          (RX_EYESCAN_VS_NEG_DIR          ),
.RX_EYESCAN_VS_RANGE            (RX_EYESCAN_VS_RANGE            ),
.RX_EYESCAN_VS_UT_SIGN          (RX_EYESCAN_VS_UT_SIGN          ),
.RX_I2V_FILTER_EN               (RX_I2V_FILTER_EN               ),
.RX_INT_DATAWIDTH               (RX_INT_DATAWIDTH               ),
.RX_PMA_POWER_SAVE              (RX_PMA_POWER_SAVE              ),
.RX_PMA_RSV0                    (RX_PMA_RSV0                    ),
.RX_PROGDIV_CFG                 (RX_PROGDIV_CFG                 ),
.RX_PROGDIV_RATE                (RX_PROGDIV_RATE                ),
.RX_RESLOAD_CTRL                (RX_RESLOAD_CTRL                ),
.RX_RESLOAD_OVRD                (RX_RESLOAD_OVRD                ),
.RX_SAMPLE_PERIOD               (RX_SAMPLE_PERIOD               ),
.RX_SIG_VALID_DLY               (RX_SIG_VALID_DLY               ),
.RX_SUM_DEGEN_AVTT_OVERITE      (RX_SUM_DEGEN_AVTT_OVERITE      ),
.RX_SUM_DFETAPREP_EN            (RX_SUM_DFETAPREP_EN            ),
.RX_SUM_IREF_TUNE               (RX_SUM_IREF_TUNE               ),
.RX_SUM_PWR_SAVING              (RX_SUM_PWR_SAVING              ),
.RX_SUM_RES_CTRL                (RX_SUM_RES_CTRL                ),
.RX_SUM_VCMTUNE                 (RX_SUM_VCMTUNE                 ),
.RX_SUM_VCM_BIAS_TUNE_EN        (RX_SUM_VCM_BIAS_TUNE_EN        ),
.RX_SUM_VCM_OVWR                (RX_SUM_VCM_OVWR                ),
.RX_SUM_VREF_TUNE               (RX_SUM_VREF_TUNE               ),
.RX_TUNE_AFE_OS                 (RX_TUNE_AFE_OS                 ),
.RX_VREG_CTRL                   (RX_VREG_CTRL                   ),
.RX_VREG_PDB                    (RX_VREG_PDB                    ),
.RX_WIDEMODE_CDR                (RX_WIDEMODE_CDR                ),
.RX_WIDEMODE_CDR_GEN3           (RX_WIDEMODE_CDR_GEN3           ),
.RX_WIDEMODE_CDR_GEN4           (RX_WIDEMODE_CDR_GEN4           ),
.RX_XCLK_SEL                    (RX_XCLK_SEL                    ),
.RX_XMODE_SEL                   (RX_XMODE_SEL                   ),
.SAMPLE_CLK_PHASE               (SAMPLE_CLK_PHASE               ),
.SATA_CPLL_CFG                  (SATA_CPLL_CFG                  ),
.SIM_MODE                       (SIM_MODE                       ),
.SIM_RESET_SPEEDUP              (SIM_RESET_SPEEDUP              ),
.SIM_TX_EIDLE_DRIVE_LEVEL       (SIM_TX_EIDLE_DRIVE_LEVEL       ),
.SRSTMODE                       (SRSTMODE                       ),
.TAPDLY_SET_TX                  (TAPDLY_SET_TX                  ),
.TCO_NEW_CFG0                   (TCO_NEW_CFG0                   ),
.TCO_NEW_CFG1                   (TCO_NEW_CFG1                   ),
.TCO_NEW_CFG2                   (TCO_NEW_CFG2                   ),
.TCO_NEW_CFG3                   (TCO_NEW_CFG3                   ),
.TCO_RSVD1                      (TCO_RSVD1                      ),
.TCO_RSVD2                      (TCO_RSVD2                      ),
.TERM_RCAL_CFG                  (TERM_RCAL_CFG                  ),
.TERM_RCAL_OVRD                 (TERM_RCAL_OVRD                 ),
.TRANS_TIME_RATE                (TRANS_TIME_RATE                ),
.TST_RSV0                       (TST_RSV0                       ),
.TST_RSV1                       (TST_RSV1                       ),
.TXBUF_EN                       (TXBUF_EN                       ),
.TXDLY_CFG                      (TXDLY_CFG                      ),
.TXDLY_LCFG                     (TXDLY_LCFG                     ),
.TXDRV_FREQBAND                 (TXDRV_FREQBAND                 ),
.TXFE_CFG0                      (TXFE_CFG0                      ),
.TXFE_CFG1                      (TXFE_CFG1                      ),
.TXFE_CFG2                      (TXFE_CFG2                      ),
.TXFE_CFG3                      (TXFE_CFG3                      ),
.TXFIFO_ADDR_CFG                (TXFIFO_ADDR_CFG                ),
.TXGBOX_FIFO_INIT_RD_ADDR       (TXGBOX_FIFO_INIT_RD_ADDR       ),
.TXOUT_DIV                      (TXOUT_DIV                      ),
.TXPCSRESET_TIME                (TXPCSRESET_TIME                ),
.TXPHDLY_CFG0                   (TXPHDLY_CFG0                   ),
.TXPHDLY_CFG1                   (TXPHDLY_CFG1                   ),
.TXPH_CFG                       (TXPH_CFG                       ),
.TXPH_CFG2                      (TXPH_CFG2                      ),
.TXPH_MONITOR_SEL               (TXPH_MONITOR_SEL               ),
.TXPI_CFG0                      (TXPI_CFG0                      ),
.TXPI_CFG1                      (TXPI_CFG1                      ),
.TXPI_GRAY_SEL                  (TXPI_GRAY_SEL                  ),
.TXPI_INVSTROBE_SEL             (TXPI_INVSTROBE_SEL             ),
.TXPI_PPM                       (TXPI_PPM                       ),
.TXPI_PPM_CFG                   (TXPI_PPM_CFG                   ),
.TXPI_SYNFREQ_PPM               (TXPI_SYNFREQ_PPM               ),
.TXPMARESET_TIME                (TXPMARESET_TIME                ),
.TXREFCLKDIV2_SEL               (TXREFCLKDIV2_SEL               ),
.TXSWBST_BST                    (TXSWBST_BST                    ),
.TXSWBST_EN                     (TXSWBST_EN                     ),
.TXSWBST_MAG                    (TXSWBST_MAG                    ),
.TXSYNC_MULTILANE               (TXSYNC_MULTILANE               ),
.TXSYNC_OVRD                    (TXSYNC_OVRD                    ),
.TXSYNC_SKIP_DA                 (TXSYNC_SKIP_DA                 ),
.TX_CLK25_DIV                   (TX_CLK25_DIV                   ),
.TX_CLKMUX_EN                   (TX_CLKMUX_EN                   ),
.TX_DATA_WIDTH                  (TX_DATA_WIDTH                  ),
.TX_DCC_LOOP_RST_CFG            (TX_DCC_LOOP_RST_CFG            ),
.TX_DIVRESET_TIME               (TX_DIVRESET_TIME               ),
.TX_EIDLE_ASSERT_DELAY          (TX_EIDLE_ASSERT_DELAY          ),
.TX_EIDLE_DEASSERT_DELAY        (TX_EIDLE_DEASSERT_DELAY        ),
.TX_FABINT_USRCLK_FLOP          (TX_FABINT_USRCLK_FLOP          ),
.TX_FIFO_BYP_EN                 (TX_FIFO_BYP_EN                 ),
.TX_IDLE_DATA_ZERO              (TX_IDLE_DATA_ZERO              ),
.TX_INT_DATAWIDTH               (TX_INT_DATAWIDTH               ),
.TX_LOOPBACK_DRIVE_HIZ          (TX_LOOPBACK_DRIVE_HIZ          ),
.TX_MAINCURSOR_SEL              (TX_MAINCURSOR_SEL              ),
.TX_PHICAL_CFG0                 (TX_PHICAL_CFG0                 ),
.TX_PHICAL_CFG1                 (TX_PHICAL_CFG1                 ),
.TX_PI_BIASSET                  (TX_PI_BIASSET                  ),
.TX_PMADATA_OPT                 (TX_PMADATA_OPT                 ),
.TX_PMA_POWER_SAVE              (TX_PMA_POWER_SAVE              ),
.TX_PMA_RSV0                    (TX_PMA_RSV0                    ),
.TX_PMA_RSV1                    (TX_PMA_RSV1                    ),
.TX_PROGCLK_SEL                 (TX_PROGCLK_SEL                 ),
.TX_PROGDIV_CFG                 (TX_PROGDIV_CFG                 ),
.TX_PROGDIV_RATE                (TX_PROGDIV_RATE                ),
.TX_SAMPLE_PERIOD               (TX_SAMPLE_PERIOD               ),
.TX_SW_MEAS                     (TX_SW_MEAS                     ),
.TX_VREG_CTRL                   (TX_VREG_CTRL                   ),
.TX_VREG_PDB                    (TX_VREG_PDB                    ),
.TX_VREG_VREFSEL                (TX_VREG_VREFSEL                ),
.TX_XCLK_SEL                    (TX_XCLK_SEL                    ),
.USE_PCS_CLK_PHASE_SEL          (USE_PCS_CLK_PHASE_SEL          ),
.USE_RAW_ELEC                   (USE_RAW_ELEC                   ),
.Y_ALL_MODE                     (Y_ALL_MODE                     )
) gtf_channel_inst (
.gtf_ch_cdrstepdir                   (gtf_ch_cdrstepdir                   ),
.gtf_ch_cdrstepsq                    (gtf_ch_cdrstepsq                    ),
.gtf_ch_cdrstepsx                    (gtf_ch_cdrstepsx                    ),
.gtf_ch_cfgreset                     (gtf_ch_cfgreset                     ),
.gtf_ch_clkrsvd0                     (gtf_ch_clkrsvd0                     ),
.gtf_ch_clkrsvd1                     (gtf_ch_clkrsvd1                     ),
.gtf_ch_cpllfreqlock                 (gtf_ch_cpllfreqlock                 ),
.gtf_ch_cplllockdetclk               (gtf_ch_cplllockdetclk               ),
.gtf_ch_cplllocken                   (gtf_ch_cplllocken                   ),
.gtf_ch_cpllpd                       (gtf_ch_cpllpd                       ),
.gtf_ch_cpllreset                    (gtf_ch_cpllreset                    ),
.gtf_ch_ctltxresendpause             (gtf_ch_ctltxresendpause             ),

.gtf_ch_ctltxsendlfi                 (ctl_tx_send_lfi_axi                 ),
.gtf_ch_ctltxsendrfi                 (ctl_tx_send_rfi_axi                 ),
.gtf_ch_ctltxsendidle                (ctl_tx_send_idle_axi                ),

.gtf_ch_dmonfiforeset                (gtf_ch_dmonfiforeset                ),
.gtf_ch_dmonitorclk                  (gtf_ch_dmonitorclk                  ),
.gtf_ch_drpclk                       (gtf_ch_drpclk                       ),
.gtf_ch_drpen                        (gtf_ch_drpen                        ),
.gtf_ch_drprst                       (gtf_ch_drprst                       ),
.gtf_ch_drpwe                        (gtf_ch_drpwe                        ),
.gtf_ch_eyescanreset                 (gtf_ch_eyescanreset                 ),
.gtf_ch_eyescantrigger               (gtf_ch_eyescantrigger               ),
.gtf_ch_freqos                       (gtf_ch_freqos                       ),
.gtf_ch_gtfrxn                       (gtf_ch_gtfrxn                       ),
.gtf_ch_gtfrxp                       (gtf_ch_gtfrxp                       ),
.gtf_ch_gtgrefclk                    (gtf_ch_gtgrefclk                    ),
.gtf_ch_gtnorthrefclk0               (gtf_ch_gtnorthrefclk0               ),
.gtf_ch_gtnorthrefclk1               (gtf_ch_gtnorthrefclk1               ),
.gtf_ch_gtrefclk0                    (gtf_ch_gtrefclk0                    ),
.gtf_ch_gtrefclk1                    (gtf_ch_gtrefclk1                    ),
.gtf_ch_gtrxreset                    (gtrxreset_int                       ),
.gtf_ch_gtrxresetsel                 (gtf_ch_gtrxresetsel                 ),
.gtf_ch_gtsouthrefclk0               (gtf_ch_gtsouthrefclk0               ),
.gtf_ch_gtsouthrefclk1               (gtf_ch_gtsouthrefclk1               ),
.gtf_ch_gttxreset                    (gtf_ch_gttxreset_out                ),
.gtf_ch_gttxresetsel                 (gtf_ch_gttxresetsel                 ),
.gtf_ch_incpctrl                     (gtf_ch_incpctrl                     ),
.gtf_ch_qpll0clk                     (gtf_ch_qpll0clk                     ),
.gtf_ch_qpll0freqlock                (gtf_ch_qpll0freqlock                ),
.gtf_ch_qpll0refclk                  (gtf_ch_qpll0refclk                  ),
.gtf_ch_qpll1clk                     (gtf_ch_qpll1clk                     ),
.gtf_ch_qpll1freqlock                (gtf_ch_qpll1freqlock                ),
.gtf_ch_qpll1refclk                  (gtf_ch_qpll1refclk                  ),
.gtf_ch_resetovrd                    (gtf_ch_resetovrd                    ),
.gtf_ch_rxafecfoken                  (gtf_ch_rxafecfoken                  ),
.gtf_ch_rxcdrfreqreset               (gtf_ch_rxcdrfreqreset               ),
.gtf_ch_rxcdrhold                    (gtf_ch_rxcdrhold                    ),
.gtf_ch_rxcdrovrden                  (gtf_ch_rxcdrovrden                  ),
.gtf_ch_rxcdrreset                   (gtf_ch_rxcdrreset                   ),
.gtf_ch_rxckcalreset                 (gtf_ch_rxckcalreset                 ),
.gtf_ch_rxdfeagchold                 (gtf_ch_rxdfeagchold                 ),
.gtf_ch_rxdfeagcovrden               (gtf_ch_rxdfeagcovrden               ),
.gtf_ch_rxdfecfokfen                 (gtf_ch_rxdfecfokfen                 ),
.gtf_ch_rxdfecfokfpulse              (gtf_ch_rxdfecfokfpulse              ),
.gtf_ch_rxdfecfokhold                (gtf_ch_rxdfecfokhold                ),
.gtf_ch_rxdfecfokovren               (gtf_ch_rxdfecfokovren               ),
.gtf_ch_rxdfekhhold                  (gtf_ch_rxdfekhhold                  ),
.gtf_ch_rxdfekhovrden                (gtf_ch_rxdfekhovrden                ),
.gtf_ch_rxdfelfhold                  (gtf_ch_rxdfelfhold                  ),
.gtf_ch_rxdfelfovrden                (gtf_ch_rxdfelfovrden                ),
.gtf_ch_rxdfelpmreset                (gtf_ch_rxdfelpmreset                ),
.gtf_ch_rxdfetap10hold               (gtf_ch_rxdfetap10hold               ),
.gtf_ch_rxdfetap10ovrden             (gtf_ch_rxdfetap10ovrden             ),
.gtf_ch_rxdfetap11hold               (gtf_ch_rxdfetap11hold               ),
.gtf_ch_rxdfetap11ovrden             (gtf_ch_rxdfetap11ovrden             ),
.gtf_ch_rxdfetap12hold               (gtf_ch_rxdfetap12hold               ),
.gtf_ch_rxdfetap12ovrden             (gtf_ch_rxdfetap12ovrden             ),
.gtf_ch_rxdfetap13hold               (gtf_ch_rxdfetap13hold               ),
.gtf_ch_rxdfetap13ovrden             (gtf_ch_rxdfetap13ovrden             ),
.gtf_ch_rxdfetap14hold               (gtf_ch_rxdfetap14hold               ),
.gtf_ch_rxdfetap14ovrden             (gtf_ch_rxdfetap14ovrden             ),
.gtf_ch_rxdfetap15hold               (gtf_ch_rxdfetap15hold               ),
.gtf_ch_rxdfetap15ovrden             (gtf_ch_rxdfetap15ovrden             ),
.gtf_ch_rxdfetap2hold                (gtf_ch_rxdfetap2hold                ),
.gtf_ch_rxdfetap2ovrden              (gtf_ch_rxdfetap2ovrden              ),
.gtf_ch_rxdfetap3hold                (gtf_ch_rxdfetap3hold                ),
.gtf_ch_rxdfetap3ovrden              (gtf_ch_rxdfetap3ovrden              ),
.gtf_ch_rxdfetap4hold                (gtf_ch_rxdfetap4hold                ),
.gtf_ch_rxdfetap4ovrden              (gtf_ch_rxdfetap4ovrden              ),
.gtf_ch_rxdfetap5hold                (gtf_ch_rxdfetap5hold                ),
.gtf_ch_rxdfetap5ovrden              (gtf_ch_rxdfetap5ovrden              ),
.gtf_ch_rxdfetap6hold                (gtf_ch_rxdfetap6hold                ),
.gtf_ch_rxdfetap6ovrden              (gtf_ch_rxdfetap6ovrden              ),
.gtf_ch_rxdfetap7hold                (gtf_ch_rxdfetap7hold                ),
.gtf_ch_rxdfetap7ovrden              (gtf_ch_rxdfetap7ovrden              ),
.gtf_ch_rxdfetap8hold                (gtf_ch_rxdfetap8hold                ),
.gtf_ch_rxdfetap8ovrden              (gtf_ch_rxdfetap8ovrden              ),
.gtf_ch_rxdfetap9hold                (gtf_ch_rxdfetap9hold                ),
.gtf_ch_rxdfetap9ovrden              (gtf_ch_rxdfetap9ovrden              ),
.gtf_ch_rxdfeuthold                  (gtf_ch_rxdfeuthold                  ),
.gtf_ch_rxdfeutovrden                (gtf_ch_rxdfeutovrden                ),
.gtf_ch_rxdfevphold                  (gtf_ch_rxdfevphold                  ),
.gtf_ch_rxdfevpovrden                (gtf_ch_rxdfevpovrden                ),
.gtf_ch_rxdfexyden                   (gtf_ch_rxdfexyden                   ),
.gtf_ch_rxdlybypass                  (gtf_ch_rxdlybypass                  ),
.gtf_ch_rxdlyen                      (gtf_ch_rxdlyen                      ),
.gtf_ch_rxdlyovrden                  (gtf_ch_rxdlyovrden                  ),
.gtf_ch_rxdlysreset                  (gtf_ch_rxdlysreset                  ),
.gtf_ch_rxlpmen                      (gtf_ch_rxlpmen                      ),
.gtf_ch_rxlpmgchold                  (gtf_ch_rxlpmgchold                  ),
.gtf_ch_rxlpmgcovrden                (gtf_ch_rxlpmgcovrden                ),
.gtf_ch_rxlpmhfhold                  (gtf_ch_rxlpmhfhold                  ),
.gtf_ch_rxlpmhfovrden                (gtf_ch_rxlpmhfovrden                ),
.gtf_ch_rxlpmlfhold                  (gtf_ch_rxlpmlfhold                  ),
.gtf_ch_rxlpmlfklovrden              (gtf_ch_rxlpmlfklovrden              ),
.gtf_ch_rxlpmoshold                  (gtf_ch_rxlpmoshold                  ),
.gtf_ch_rxlpmosovrden                (gtf_ch_rxlpmosovrden                ),
.gtf_ch_rxoscalreset                 (gtf_ch_rxoscalreset                 ),
.gtf_ch_rxoshold                     (gtf_ch_rxoshold                     ),
.gtf_ch_rxosovrden                   (gtf_ch_rxosovrden                   ),
.gtf_ch_rxpcsreset                   (gtf_ch_rxpcsreset                   ),
.gtf_ch_rxphalign                    (gtf_ch_rxphalign                    ),
.gtf_ch_rxphalignen                  (gtf_ch_rxphalignen                  ),
.gtf_ch_rxphdlypd                    (gtf_ch_rxphdlypd                    ),
.gtf_ch_rxphdlyreset                 (gtf_ch_rxphdlyreset                 ),
.gtf_ch_rxpmareset                   (gtf_ch_rxpmareset                   ),
.gtf_ch_rxpolarity                   (gtf_ch_rxpolarity                   ),
.gtf_ch_rxprbscntreset               (gtf_ch_rxprbscntreset               ),
.gtf_ch_rxprogdivreset               (rxprogdivreset_int),//gtf_ch_rxprogdivreset               ),
.gtf_ch_rxslipoutclk                 (gtf_ch_rxslipoutclk                 ),
.gtf_ch_rxslippma                    (gtf_ch_rxslippma                    ),
.gtf_ch_rxsyncallin                  (gtf_ch_rxsyncallin                  ),
.gtf_ch_rxsyncin                     (gtf_ch_rxsyncin                     ),
.gtf_ch_rxsyncmode                   (gtf_ch_rxsyncmode                   ),
.gtf_ch_rxtermination                (gtf_ch_rxtermination                ),
.gtf_ch_rxuserrdy                    (rxuserrdy_int                       ),                     
.gtf_ch_rxusrclk                     (gtf_ch_rxusrclk                     ),
.gtf_ch_rxusrclk2                    (gtf_ch_rxusrclk2                    ),
.gtf_ch_txaxisterr                   (gtf_ch_txaxisterr                   ),
.gtf_ch_txaxistpoison                (gtf_ch_txaxistpoison                ),
.gtf_ch_txaxistvalid                 (gtf_ch_txaxistvalid                 ),
.gtf_ch_txdccforcestart              (gtf_ch_txdccforcestart              ),
.gtf_ch_txdccreset                   (gtf_ch_txdccreset                   ),
.gtf_ch_txdlybypass                  (gtf_ch_txdlybypass                  ),
.gtf_ch_txdlyen                      (gtf_ch_txdlyen                      ),
.gtf_ch_txdlyhold                    (gtf_ch_txdlyhold                    ),
.gtf_ch_txdlyovrden                  (gtf_ch_txdlyovrden                  ),
.gtf_ch_txdlysreset                  (gtf_ch_txdlysreset                  ),
.gtf_ch_txdlyupdown                  (gtf_ch_txdlyupdown                  ),
.gtf_ch_txelecidle                   (gtf_ch_txelecidle                   ),
.gtf_ch_txgbseqsync                  (gtf_ch_txgbseqsync                  ),
.gtf_ch_txmuxdcdexhold               (gtf_ch_txmuxdcdexhold               ),
.gtf_ch_txmuxdcdorwren               (gtf_ch_txmuxdcdorwren               ),
.gtf_ch_txpcsreset                   (gtf_ch_txpcsreset                   ),
.gtf_ch_txphalign                    (gtf_ch_txphalign                    ),
.gtf_ch_txphalignen                  (gtf_ch_txphalignen                  ),
.gtf_ch_txphdlypd                    (gtf_ch_txphdlypd                    ),
.gtf_ch_txphdlyreset                 (gtf_ch_txphdlyreset                 ),
.gtf_ch_txphdlytstclk                (gtf_ch_txphdlytstclk                ),
.gtf_ch_txphinit                     (gtf_ch_txphinit                     ),
.gtf_ch_txphovrden                   (gtf_ch_txphovrden                   ),
.gtf_ch_txpippmen                    (gtf_ch_txpippmen                    ),
.gtf_ch_txpippmovrden                (gtf_ch_txpippmovrden                ),
.gtf_ch_txpippmpd                    (gtf_ch_txpippmpd                    ),
.gtf_ch_txpippmsel                   (gtf_ch_txpippmsel                   ),
.gtf_ch_txpisopd                     (i_gtf_ch_txpisopd                   ),
.gtf_ch_txpmareset                   (i_gtf_ch_txpmareset                 ),
.gtf_ch_txpolarity                   (gtf_ch_txpolarity                   ),
.gtf_ch_txprbsforceerr               (gtf_ch_txprbsforceerr               ),
.gtf_ch_txprogdivreset               (txprogdivreset_int                  ),
.gtf_ch_txsyncallin                  (gtf_ch_txsyncallin                  ),
.gtf_ch_txsyncin                     (gtf_ch_txsyncin                     ),
.gtf_ch_txsyncmode                   (gtf_ch_txsyncmode                   ),
.gtf_ch_txuserrdy                    (txuserrdy_int                       ),
.gtf_ch_txusrclk                     (gtf_ch_txusrclk                     ),
.gtf_ch_txusrclk2                    (gtf_ch_txusrclk2                    ),
.gtf_ch_drpdi                        (gtf_ch_drpdi                        ),
.gtf_ch_gtrsvd                       (gtf_ch_gtrsvd                       ),
.gtf_ch_pcsrsvdin                    (gtf_ch_pcsrsvdin                    ),
.gtf_ch_tstin                        (gtf_ch_tstin                        ),
.gtf_ch_rxelecidlemode               (gtf_ch_rxelecidlemode               ),
.gtf_ch_rxmonitorsel                 (gtf_ch_rxmonitorsel                 ),
.gtf_ch_rxpd                         (gtf_ch_rxpd                         ),
.gtf_ch_rxpllclksel                  (gtf_ch_rxpllclksel                  ),
.gtf_ch_rxsysclksel                  (gtf_ch_rxsysclksel                  ),
.gtf_ch_txaxistsof                   (gtf_ch_txaxistsof                   ),
.gtf_ch_txpd                         (gtf_ch_txpd                         ),
.gtf_ch_txpllclksel                  (gtf_ch_txpllclksel                  ),
.gtf_ch_txsysclksel                  (gtf_ch_txsysclksel                  ),
.gtf_ch_cpllrefclksel                (gtf_ch_cpllrefclksel                ),
.gtf_ch_loopback                     (ctl_local_loopback                  ),
.gtf_ch_rxoutclksel                  (gtf_ch_rxoutclksel                  ),
.gtf_ch_txoutclksel                  (gtf_ch_txoutclksel                  ),
.gtf_ch_txrawdata                    (gtf_ch_txrawdata                    ),
.gtf_ch_rxdfecfokfcnum               (gtf_ch_rxdfecfokfcnum               ),
.gtf_ch_rxprbssel                    (gtf_ch_rxprbssel                    ),
.gtf_ch_txprbssel                    (gtf_ch_txprbssel                    ),
.gtf_ch_txaxistterm                  (gtf_ch_txaxistterm                  ),
.gtf_ch_txdiffctrl                   (gtf_ch_txdiffctrl                   ),
.gtf_ch_txpippmstepsize              (gtf_ch_txpippmstepsize              ),
.gtf_ch_txpostcursor                 (gtf_ch_txpostcursor                 ),
.gtf_ch_txprecursor                  (gtf_ch_txprecursor                  ),
.gtf_ch_txaxistdata                  (gtf_ch_txaxistdata                  ),
.gtf_ch_rxckcalstart                 (gtf_ch_rxckcalstart                 ),
.gtf_ch_txmaincursor                 (gtf_ch_txmaincursor                 ),
.gtf_ch_txaxistlast                  (gtf_ch_txaxistlast                  ),
.gtf_ch_txaxistpre                   (gtf_ch_txaxistpre                   ),
.gtf_ch_ctlrxpauseack                (gtf_ch_ctlrxpauseack                ),
.gtf_ch_ctltxpausereq                (gtf_ch_ctltxpausereq                ),
.gtf_ch_drpaddr                      (gtf_ch_drpaddr                      ),
.gtf_ch_cpllfbclklost                (gtf_ch_cpllfbclklost                ),
.gtf_ch_cplllock                     (gtf_ch_cplllock                     ),
.gtf_ch_cpllrefclklost               (gtf_ch_cpllrefclklost               ),
.gtf_ch_dmonitoroutclk               (gtf_ch_dmonitoroutclk               ),
.gtf_ch_drprdy                       (gtf_ch_drprdy                       ),
.gtf_ch_eyescandataerror             (gtf_ch_eyescandataerror             ),
.gtf_ch_gtftxn                       (gtf_ch_gtftxn                       ),
.gtf_ch_gtftxp                       (gtf_ch_gtftxp                       ),
.gtf_ch_gtpowergood                  (i_gtf_ch_gtpowergood                ),
.gtf_ch_gtrefclkmonitor              (gtf_ch_gtrefclkmonitor              ),
.gtf_ch_resetexception               (gtf_ch_resetexception               ),
.gtf_ch_rxaxisterr                   (gtf_ch_rxaxisterr                   ),
.gtf_ch_rxaxistvalid                 (gtf_ch_rxaxistvalid                 ),
.gtf_ch_rxbitslip                    (gtf_ch_rxbitslip                    ),
.gtf_ch_rxcdrlock                    (gtf_ch_rxcdrlock                    ),
.gtf_ch_rxcdrphdone                  (gtf_ch_rxcdrphdone                  ),
.gtf_ch_rxckcaldone                  (gtf_ch_rxckcaldone                  ),
.gtf_ch_rxdlysresetdone              (gtf_ch_rxdlysresetdone              ),
.gtf_ch_rxelecidle                   (gtf_ch_rxelecidle                   ),
.gtf_ch_rxgbseqstart                 (gtf_ch_rxgbseqstart                 ),
.gtf_ch_rxosintdone                  (gtf_ch_rxosintdone                  ),
.gtf_ch_rxosintstarted               (gtf_ch_rxosintstarted               ),
.gtf_ch_rxosintstrobedone            (gtf_ch_rxosintstrobedone            ),
.gtf_ch_rxosintstrobestarted         (gtf_ch_rxosintstrobestarted         ),
.gtf_ch_rxoutclk                     (gtf_ch_rxoutclk                     ),
.gtf_ch_rxoutclkfabric               (gtf_ch_rxoutclkfabric               ),
.gtf_ch_rxoutclkpcs                  (gtf_ch_rxoutclkpcs                  ),
.gtf_ch_rxphaligndone                (gtf_ch_rxphaligndone                ),
.gtf_ch_rxphalignerr                 (gtf_ch_rxphalignerr                 ),
.gtf_ch_rxpmaresetdone               (gtf_ch_rxpmaresetdone               ),
.gtf_ch_rxprbserr                    (gtf_ch_rxprbserr                    ),
.gtf_ch_rxprbslocked                 (gtf_ch_rxprbslocked                 ),
.gtf_ch_rxprgdivresetdone            (gtf_ch_rxprgdivresetdone            ),
.gtf_ch_rxptpsop                     (gtf_ch_rxptpsop                     ),
.gtf_ch_rxptpsoppos                  (gtf_ch_rxptpsoppos                  ),
.gtf_ch_rxrecclkout                  (gtf_ch_rxrecclkout                  ),
.gtf_ch_rxresetdone                  (gtf_ch_rxresetdone                  ),
.gtf_ch_rxslipdone                   (gtf_ch_rxslipdone                   ),
.gtf_ch_rxslipoutclkrdy              (gtf_ch_rxslipoutclkrdy              ),
.gtf_ch_rxslippmardy                 (gtf_ch_rxslippmardy                 ),
.gtf_ch_rxsyncdone                   (gtf_ch_rxsyncdone                   ),
.gtf_ch_rxsyncout                    (gtf_ch_rxsyncout                    ),
.gtf_ch_statrxbadcode                (gtf_ch_statrxbadcode                ),
.gtf_ch_statrxbadfcs                 (gtf_ch_statrxbadfcs                 ),
.gtf_ch_statrxbadpreamble            (gtf_ch_statrxbadpreamble            ),
.gtf_ch_statrxbadsfd                 (gtf_ch_statrxbadsfd                 ),
.gtf_ch_statrxblocklock              (gtf_ch_statrxblocklock              ),
.gtf_ch_statrxbroadcast              (gtf_ch_statrxbroadcast              ),
.gtf_ch_statrxfcserr                 (gtf_ch_statrxfcserr                 ),
.gtf_ch_statrxframingerr             (gtf_ch_statrxframingerr             ),
.gtf_ch_statrxgotsignalos            (gtf_ch_statrxgotsignalos            ),
.gtf_ch_statrxhiber                  (gtf_ch_statrxhiber                  ),
.gtf_ch_statrxinrangeerr             (gtf_ch_statrxinrangeerr             ),
.gtf_ch_statrxinternallocalfault     (gtf_ch_statrxinternallocalfault     ),
.gtf_ch_statrxlocalfault             (gtf_ch_statrxlocalfault             ),
.gtf_ch_statrxmulticast              (gtf_ch_statrxmulticast              ),
.gtf_ch_statrxpkt                    (gtf_ch_statrxpkt                    ),
.gtf_ch_statrxpkterr                 (gtf_ch_statrxpkterr                 ),
.gtf_ch_statrxreceivedlocalfault     (gtf_ch_statrxreceivedlocalfault     ),
.gtf_ch_statrxremotefault            (gtf_ch_statrxremotefault            ),
.gtf_ch_statrxstatus                 (gtf_ch_statrxstatus                 ),
.gtf_ch_statrxstompedfcs             (gtf_ch_statrxstompedfcs             ),
.gtf_ch_statrxtestpatternmismatch    (gtf_ch_statrxtestpatternmismatch    ),
.gtf_ch_statrxtruncated              (gtf_ch_statrxtruncated              ),
.gtf_ch_statrxunicast                (gtf_ch_statrxunicast                ),
.gtf_ch_statrxvalidctrlcode          (gtf_ch_statrxvalidctrlcode          ),
.gtf_ch_statrxvlan                   (gtf_ch_statrxvlan                   ),
.gtf_ch_stattxbadfcs                 (gtf_ch_stattxbadfcs                 ),
.gtf_ch_stattxbroadcast              (gtf_ch_stattxbroadcast              ),
.gtf_ch_stattxfcserr                 (gtf_ch_stattxfcserr                 ),
.gtf_ch_stattxmulticast              (gtf_ch_stattxmulticast              ),
.gtf_ch_stattxpkt                    (gtf_ch_stattxpkt                    ),
.gtf_ch_stattxpkterr                 (gtf_ch_stattxpkterr                 ),
.gtf_ch_stattxunicast                (gtf_ch_stattxunicast                ),
.gtf_ch_stattxvlan                   (gtf_ch_stattxvlan                   ),
.gtf_ch_txaxistready                 (gtf_ch_txaxistready                 ),
.gtf_ch_txdccdone                    (gtf_ch_txdccdone                    ),
.gtf_ch_txdlysresetdone              (gtf_ch_txdlysresetdone              ),
.gtf_ch_txgbseqstart                 (gtf_ch_txgbseqstart                 ),
.gtf_ch_txoutclk                     (gtf_ch_txoutclk                     ),
.gtf_ch_txoutclkfabric               (gtf_ch_txoutclkfabric               ),
.gtf_ch_txoutclkpcs                  (gtf_ch_txoutclkpcs                  ),
.gtf_ch_txphaligndone                (gtf_ch_txphaligndone                ),
.gtf_ch_txphinitdone                 (gtf_ch_txphinitdone                 ),
.gtf_ch_txpmaresetdone               (gtf_ch_txpmaresetdone               ),
.gtf_ch_txprgdivresetdone            (gtf_ch_txprgdivresetdone            ),
.gtf_ch_txptpsop                     (gtf_ch_txptpsop                     ),
.gtf_ch_txptpsoppos                  (gtf_ch_txptpsoppos                  ),
.gtf_ch_txresetdone                  (gtf_ch_txresetdone                  ),
.gtf_ch_txsyncdone                   (gtf_ch_txsyncdone                   ),
.gtf_ch_txsyncout                    (gtf_ch_txsyncout                    ),
.gtf_ch_txunfout                     (gtf_ch_txunfout                     ),
.gtf_ch_dmonitorout                   (i_gtf_ch_dmonitorout                   ),
.gtf_ch_drpdo                        (gtf_ch_drpdo                        ),
.gtf_ch_pcsrsvdout                   (gtf_ch_pcsrsvdout                   ),
.gtf_ch_pinrsrvdas                   (gtf_ch_pinrsrvdas                   ),
.gtf_ch_rxaxistsof                   (gtf_ch_rxaxistsof                   ),
.gtf_ch_rxrawdata                    (gtf_ch_rxrawdata                    ),
.gtf_ch_statrxbytes                  (gtf_ch_statrxbytes                  ),
.gtf_ch_stattxbytes                  (gtf_ch_stattxbytes                  ),
.gtf_ch_rxaxistterm                  (gtf_ch_rxaxistterm                  ),
.gtf_ch_rxaxistdata                  (gtf_ch_rxaxistdata                  ),
.gtf_ch_rxaxistlast                  (gtf_ch_rxaxistlast                  ),
.gtf_ch_rxaxistpre                   (gtf_ch_rxaxistpre                   ),
.gtf_ch_rxmonitorout                 (gtf_ch_rxmonitorout                 ),
.gtf_ch_statrxpausequanta            (gtf_ch_statrxpausequanta            ),
.gtf_ch_statrxpausereq               (gtf_ch_statrxpausereq               ),
.gtf_ch_statrxpausevalid             (gtf_ch_statrxpausevalid             ),
.gtf_ch_stattxpausevalid             (gtf_ch_stattxpausevalid             )
);

gtfwizard_mac_reset  u_reset_inst(
  .gtpowergood_in                            (gtf_ch_gtpowergood),
  .gtwiz_reset_all_in                        (gtwiz_reset_all_in),
  .gtwiz_reset_clk_freerun_in                (gtwiz_reset_clk_freerun_in                ),
  .gtwiz_reset_rx_datapath_in                (gtwiz_reset_rx_datapath_in                ),
  .gtwiz_reset_rx_pll_and_datapath_in        (gtwiz_reset_rx_pll_and_datapath_in        ),
  .gtwiz_reset_tx_datapath_in                (gtwiz_reset_tx_datapath_in                ),
  .gtwiz_reset_tx_pll_and_datapath_in        (gtwiz_reset_tx_pll_and_datapath_in        ),
  .gtwiz_reset_userclk_rx_active_in          (gtwiz_reset_userclk_rx_active_in          ),
  .gtwiz_reset_userclk_tx_active_in          (gtwiz_reset_userclk_tx_active_in          ),
  .plllock_rx_in                             (plllock_rx_in),
  .plllock_tx_in                             (plllock_tx_in),
  .rx_enabled_tie_in                         (1'b1),
  .rxcdrlock_in                              (rxcdrlock_in                              ),
  .rxresetdone_in                            (rxresetdone_in),
  .rxusrclk2_in                              (gtf_ch_rxusrclk2),
  .shared_pll_tie_in                         (1'b1),
  .tx_enabled_tie_in                         (1'b1),
  .txresetdone_in                            (txresetdone_in),
  .txusrclk2_in                              (gtf_ch_txusrclk2),
  .gtrxreset_out                             (gtrxreset_int),
  .gttxreset_out                             (i_gtf_ch_gttxreset_out),
  .pllreset_rx_out                           (gtwiz_pllreset_rx_out),
  .pllreset_tx_out                           (gtwiz_pllreset_tx_out),
  .rxprogdivreset_out                        (rxprogdivreset_int),
  .rxuserrdy_out                             (rxuserrdy_int_1),
  .txuserrdy_out                             (txuserrdy_int_1),
  .gtwiz_reset_rx_cdr_stable_out             (gtwiz_reset_rx_cdr_stable_out             ),
  .gtwiz_reset_rx_done_out                   (gtwiz_reset_rx_done_out),
  .gtwiz_reset_tx_done_out                   (gtwiz_reset_tx_done_out),
  .txprogdivreset_out                        (txprogdivreset_int)
);

  gtfwizard_mac_gtwiz_buffbypass_tx #(
    .P_TOTAL_NUMBER_OF_CHANNELS (1),
    .P_MASTER_CHANNEL_POINTER   (0)
  ) gtwiz_buffbypass_tx_inst (
    .gtwiz_buffbypass_tx_clk_in        (gtf_ch_drpclk),
    .gtwiz_buffbypass_tx_reset_in      (~gtf_ch_txpmaresetdone),
    .gtwiz_buffbypass_tx_start_user_in (1'b0),
    .gtwiz_buffbypass_tx_resetdone_in  (gtf_ch_txresetdone),
    .gtwiz_buffbypass_tx_phdlypd_in    (gtf_ch_gttxreset_out),
    .gtwiz_buffbypass_tx_done_out      (gtwiz_buffbypass_tx_done_out),
    .gtwiz_buffbypass_tx_error_out     (),
    .txphaligndone_in                  (gtf_ch_txphaligndone),
    .txphinitdone_in                   (gtf_ch_txphinitdone),
    .txdlysresetdone_in                (gtf_ch_txdlysresetdone),
    .txsyncout_in                      (gtf_ch_txsyncout),
    .txsyncdone_in                     (gtf_ch_txsyncdone),
    .txphdlyreset_out                  (gtf_ch_txphdlyreset),
    .txphalign_out                     (gtf_ch_txphalign),
    .txphalignen_out                   (gtf_ch_txphalignen),
    .txphdlypd_out                     (gtf_ch_txphdlypd),
    .txphinit_out                      (gtf_ch_txphinit),
    .txphovrden_out                    (gtf_ch_txphovrden),
    .txdlysreset_out                   (gtf_ch_txdlysreset),
    .txdlybypass_out                   (gtf_ch_txdlybypass),
    .txdlyen_out                       (gtf_ch_txdlyen),
    .txdlyovrden_out                   (gtf_ch_txdlyovrden),
    .txphdlytstclk_out                 (gtf_ch_txphdlytstclk),
    .txdlyhold_out                     (gtf_ch_txdlyhold),
    .txdlyupdown_out                   (gtf_ch_txdlyupdown),
    .txsyncmode_out                    (gtf_ch_txsyncmode),
    .txsyncallin_out                   (gtf_ch_txsyncallin),
    .txsyncin_out                      (gtf_ch_txsyncin)
  );


/// drp allign switch take to core
  
  gtfwizard_mac_gtf_ch_drp_align_switch gtf_ch_drp_align_switch_inst (
    .freerun_clk_in               (gtf_ch_drpclk),
    .gtwiz_buffbypass_rx_reset_in (~gtf_ch_rxresetdone),
    .am_switch_in                 (gtf_ch_am_switch), 
    .drp_reconfig_rdy_in          (gtf_ch_drp_reconfig_rdy), 
    .drp_reconfig_done_out        (gtf_ch_drp_reconfig_done), 
    .drprdy_in                    (drp_align_drprdy            ),
    .drpen_out                    (drp_align_drpen             ),
    .drpwe_out                    (drp_align_drpwe              ), 
    .drpaddr_out                  (drp_align_drpaddr      ),
    .drpdo_in                     (drp_align_drpdo       ),
    .drpdi_out                    (drp_align_drpdi       )
    
  );

  gtfwizard_mac_gtwiz_buffbypass_rx #(
    .P_TOTAL_NUMBER_OF_CHANNELS (1),
    .P_MASTER_CHANNEL_POINTER   (0)
  ) gtwiz_buffbypass_rx_inst (
    .gtwiz_buffbypass_rx_clk_in        (gtf_ch_drpclk),
    .gtwiz_buffbypass_rx_reset_in      (~gtf_ch_rxpmaresetdone),
    .gtwiz_buffbypass_rx_start_user_in (1'b0),
    .gtwiz_buffbypass_rx_resetdone_in  (gtf_ch_rxresetdone),
    .gtwiz_buffbypass_rx_phdlypd_in    (gtf_ch_gttxreset_out),
    .dmon_bad_align_in                 (i_gtf_ch_dmonitorout[3]), //1 indicates bad MM align which is desirable for WA
    .drp_reconfig_done_in              (gtf_ch_drp_reconfig_done),   
    .workaround_bypass_in              (1'b0),
    .force_bad_align_in                (1'b0),
    .drp_reconfig_rdy_out              (gtf_ch_drp_reconfig_rdy),   
    .drp_switch_am_out                 (gtf_ch_am_switch),  
    .sm_buffbypass_rx_mm_out           (),		
    .gtwiz_buffbypass_rx_done_out      (gtwiz_buffbypass_rx_done_out),
    .gtwiz_buffbypass_rx_error_out     (),
    .rxphaligndone_in                  (gtf_ch_rxphaligndone),
    .rxdlysresetdone_in                (gtf_ch_rxdlysresetdone),
    .rxsyncout_in                      (gtf_ch_rxsyncout),
    .rxsyncdone_in                     (gtf_ch_rxsyncdone),
    .rxphdlyreset_out                  (gtf_ch_rxphdlyreset),
    .rxphalign_out                     (gtf_ch_rxphalign),
    .rxphovrden_out                    (gtf_ch_rxphovrden), // not assigned to any signal/ In ex also the same
    .rxphalignen_out                   (gtf_ch_rxphalignen),
    .rxphdlypd_out                     (gtf_ch_rxphdlypd),
    .rxdlysreset_out                   (gtf_ch_rxdlysreset),
    .rxdlybypass_out                   (gtf_ch_rxdlybypass),
    .rxdlyen_out                       (gtf_ch_rxdlyen),
    .rxdlyovrden_out                   (gtf_ch_rxdlyovrden),
    .rxsyncmode_out                    (gtf_ch_rxsyncmode),
    .rxsyncallin_out                   (gtf_ch_rxsyncallin),
    .rxsyncin_out                      (gtf_ch_rxsyncin)
  );



endmodule
`default_nettype wire
//------}

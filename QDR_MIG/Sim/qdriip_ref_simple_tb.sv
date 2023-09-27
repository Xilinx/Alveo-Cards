/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/


//------------------------------------------------------------------------------
// 
//  Instantiates: Top-level design (Simple QDRII+ Reference Design)
//                G82582DT20E Memory Model

`timescale 1ps/1ps;

module qdriip_ref_simple_tb;

  //============//
  // Parameters //
  //============//

  parameter NUM_WRITES = 10;

  //=====================//
  // Signal Declarations //
  //=====================//

  // Clock/Reset
  logic CLK10_LVDS_300_P;
  logic CLK10_LVDS_300_N;

  // QDRII+ Data Interface
  wire qdriip_cq_p;
  wire qdriip_cq_n;
  wire qdriip_k_p;
  wire qdriip_k_n;
  wire qdriip_w_n;
  wire qdriip_r_n;
  wire qdriip_doff_n;
  wire [1:0] qdriip_bw_n;
  wire [21:0] qdriip_sa;
  wire [17:0] qdriip_d;
  wire [17:0] qdriip_q;

  //=====//
  // DUT //
  //=====//

  qdriip_ref_simple_top #(
    .NUM_WRITES(NUM_WRITES)
  ) DUT (
    .CLK10_LVDS_300_P(CLK10_LVDS_300_P),
    .CLK10_LVDS_300_N(CLK10_LVDS_300_N),

    // QDRII+ Memory Interface
    .QDR0_CQP(qdriip_cq_p),
    .QDR0_CQN(qdriip_cq_n),
    .QDR0_KP(qdriip_k_p),
    .QDR0_KN(qdriip_k_n),
    .QDR0_WN(qdriip_w_n),
    .QDR0_RN(qdriip_r_n),
    .QDR0_DOFFN(qdriip_doff_n),
    .QDR0_BWN(qdriip_bw_n),
    .QDR0_A(qdriip_sa),
    .QDR0_D(qdriip_d),
    .QDR0_Q(qdriip_q)
  );

  // G82582DT20E SRAM Model
  G82582DT20E qdriip_sram_model (
    .SA(qdriip_sa), 		   // input [21:0] address
    .K(qdriip_k_p),		     // input clock
    .nK(qdriip_k_n),		   // input clock
    .nBW(qdriip_bw_n),		 // input [1:0] bank 1 write enable
    .nR(qdriip_r_n), 		   // input read enable
    .nW(qdriip_w_n), 		   // input write enable
    .nDoff(qdriip_doff_n), // input write enable
    .CQ(qdriip_cq_p), 		 // output write enable
    .nCQ(qdriip_cq_n), 		 // output write enable
    .QVLD(), 		           // output write enable
    .D(qdriip_d),		       // input [17:0] data in
    .Q(qdriip_q),		       // output[17:0] data out
    .TMS(1'b1),	           // input Scan Test Mode Select
    .TDI(1'b1),		         // input Scan Test Data In
    .TDO(),		             // output Scan Test Data Out
    .TCK(1'b0)		         // input Scan Test Clock
  );

  //=======//
  // Clock //
  //=======//

  initial begin
    CLK10_LVDS_300_P = 0;
    forever begin
      #(3334/2);
      CLK10_LVDS_300_P = !CLK10_LVDS_300_P;
    end
  end

  assign CLK10_LVDS_300_N = !CLK10_LVDS_300_P;

  //=======//
  // Tasks //
  //=======//

  task reset();
    DUT.sys_rst <= 0;
    #20;
    DUT.sys_rst <= 1;
    #(3334*100);
    DUT.sys_rst <= 0;
  endtask

  //==========//
  // Run Test //
  //==========//

  initial begin
    reset();
    wait(DUT.done);
    #3334;
    $display("Simulation finished");
    $finish;
  end
  
endmodule
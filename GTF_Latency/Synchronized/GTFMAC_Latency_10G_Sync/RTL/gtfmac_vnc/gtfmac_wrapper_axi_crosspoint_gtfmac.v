/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/


module gtfmac_wrapper_axi_crosspoint_gtfmac (
  input  wire S0_s_axi_aclk,
  input  wire S0_s_axi_aresetn,
  input  wire [31:0] S0_s_axi_awaddr,
  input  wire S0_s_axi_awvalid,
  output wire S0_s_axi_awready,
  input  wire [31:0] S0_s_axi_wdata,
  input  wire [3:0] S0_s_axi_wstrb,
  input  wire S0_s_axi_wvalid,
  output wire S0_s_axi_wready,
  output wire [1:0] S0_s_axi_bresp,
  output wire S0_s_axi_bvalid,
  input  wire S0_s_axi_bready,
  input  wire [31:0] S0_s_axi_araddr,
  input  wire S0_s_axi_arvalid,
  output wire S0_s_axi_arready,
  output wire [31:0] S0_s_axi_rdata,
  output wire [1:0] S0_s_axi_rresp,
  output wire S0_s_axi_rvalid,
  input  wire S0_s_axi_rready,

  output wire [31:0] M0_m_axi_awaddr,
  output wire M0_m_axi_awvalid,
  input  wire M0_m_axi_awready,
  output wire [31:0] M0_m_axi_wdata,
  output wire [3:0] M0_m_axi_wstrb,
  output wire M0_m_axi_wvalid,
  input  wire M0_m_axi_wready,
  input  wire [1:0] M0_m_axi_bresp,
  input  wire M0_m_axi_bvalid,
  output wire M0_m_axi_bready,
  output wire [31:0] M0_m_axi_araddr,
  output wire M0_m_axi_arvalid,
  input  wire M0_m_axi_arready,
  input  wire [31:0] M0_m_axi_rdata,
  input  wire [1:0] M0_m_axi_rresp,
  input  wire M0_m_axi_rvalid,
  output wire M0_m_axi_rready,

  output wire [31:0] M1_m_axi_awaddr,
  output wire M1_m_axi_awvalid,
  input  wire M1_m_axi_awready,
  output wire [31:0] M1_m_axi_wdata,
  output wire [3:0] M1_m_axi_wstrb,
  output wire M1_m_axi_wvalid,
  input  wire M1_m_axi_wready,
  input  wire [1:0] M1_m_axi_bresp,
  input  wire M1_m_axi_bvalid,
  output wire M1_m_axi_bready,
  output wire [31:0] M1_m_axi_araddr,
  output wire M1_m_axi_arvalid,
  input  wire M1_m_axi_arready,
  input  wire [31:0] M1_m_axi_rdata,
  input  wire [1:0] M1_m_axi_rresp,
  input  wire M1_m_axi_rvalid,
  output wire M1_m_axi_rready
);

AXI_CROSSBAR_GTFMAC i_AXI_CROSSBAR_GTFMAC (
    .aclk (S0_s_axi_aclk),
    .aresetn (S0_s_axi_aresetn),

    .s_axi_awprot                 ( 3'b000 ),             // input wire [2 : 0] s_axi_awprot
    .s_axi_arprot                 ( 3'b000 ),             // input wire [2 : 0] s_axi_arprot

    .s_axi_awaddr (S0_s_axi_awaddr),
    .s_axi_awvalid (S0_s_axi_awvalid),
    .s_axi_awready (S0_s_axi_awready),
    .s_axi_wdata (S0_s_axi_wdata),
    .s_axi_wstrb (S0_s_axi_wstrb),
    .s_axi_wvalid (S0_s_axi_wvalid),
    .s_axi_wready (S0_s_axi_wready),
    .s_axi_bresp (S0_s_axi_bresp),
    .s_axi_bvalid (S0_s_axi_bvalid),
    .s_axi_bready (S0_s_axi_bready),
    .s_axi_araddr (S0_s_axi_araddr),
    .s_axi_arvalid (S0_s_axi_arvalid),
    .s_axi_arready (S0_s_axi_arready),
    .s_axi_rdata (S0_s_axi_rdata),
    .s_axi_rresp (S0_s_axi_rresp),
    .s_axi_rvalid (S0_s_axi_rvalid),
    .s_axi_rready (S0_s_axi_rready),

    .m_axi_awaddr                 ( { M1_m_axi_awaddr, M0_m_axi_awaddr } ),
    .m_axi_awvalid                ( { M1_m_axi_awvalid, M0_m_axi_awvalid } ),
    .m_axi_awready                ( { M1_m_axi_awready, M0_m_axi_awready } ),
    .m_axi_wdata                  ( { M1_m_axi_wdata, M0_m_axi_wdata } ),
    .m_axi_wstrb                  ( { M1_m_axi_wstrb, M0_m_axi_wstrb } ),
    .m_axi_wvalid                 ( { M1_m_axi_wvalid, M0_m_axi_wvalid } ),
    .m_axi_wready                 ( { M1_m_axi_wready, M0_m_axi_wready } ),
    .m_axi_bresp                  ( { M1_m_axi_bresp, M0_m_axi_bresp } ),
    .m_axi_bvalid                 ( { M1_m_axi_bvalid, M0_m_axi_bvalid } ),
    .m_axi_bready                 ( { M1_m_axi_bready, M0_m_axi_bready } ),
    .m_axi_araddr                 ( { M1_m_axi_araddr, M0_m_axi_araddr } ),
    .m_axi_arvalid                ( { M1_m_axi_arvalid, M0_m_axi_arvalid } ),
    .m_axi_arready                ( { M1_m_axi_arready, M0_m_axi_arready } ),
    .m_axi_rdata                  ( { M1_m_axi_rdata, M0_m_axi_rdata } ),
    .m_axi_rresp                  ( { M1_m_axi_rresp, M0_m_axi_rresp } ),
    .m_axi_rvalid                 ( { M1_m_axi_rvalid, M0_m_axi_rvalid } ),
    .m_axi_rready                 ( { M1_m_axi_rready, M0_m_axi_rready } ),

    .m_axi_awprot                 (   ),             // output wire [5 : 0] m_axi_awprot                  ( unused protection bits )
    .m_axi_arprot                 (   )              // output wire [5 : 0] m_axi_arprot
  ) ;

endmodule

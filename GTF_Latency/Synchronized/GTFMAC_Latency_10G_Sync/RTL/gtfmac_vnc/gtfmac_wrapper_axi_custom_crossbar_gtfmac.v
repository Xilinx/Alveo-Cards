/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/


module gtfmac_wrapper_axi_custom_crossbar_gtfmac (
  input  wire S0_s_axi_aclk,
  input  wire S0_s_axi_aresetn,
  input  wire [31:0] S0_s_axi_awaddr,
  input  wire S0_s_axi_awvalid,
  output wire  S0_s_axi_awready,
  input  wire [31:0] S0_s_axi_wdata,
  input  wire [3:0] S0_s_axi_wstrb,
  input  wire S0_s_axi_wvalid,
  output wire  S0_s_axi_wready,
  output wire  [1:0] S0_s_axi_bresp,
  output wire  S0_s_axi_bvalid,
  input  wire S0_s_axi_bready,
  input  wire [31:0] S0_s_axi_araddr,
  input  wire S0_s_axi_arvalid,
  output wire  S0_s_axi_arready,
  output wire  [31:0] S0_s_axi_rdata,
  output wire  [1:0] S0_s_axi_rresp,
  output wire  S0_s_axi_rvalid,
  input  wire S0_s_axi_rready,

  output wire  [31:0] M0_m_axi_awaddr,
  output wire  M0_m_axi_awvalid,
  input  wire M0_m_axi_awready,
  output wire  [31:0] M0_m_axi_wdata,
  output wire  [3:0] M0_m_axi_wstrb,
  output wire  M0_m_axi_wvalid,
  input  wire M0_m_axi_wready,
  input  wire [1:0] M0_m_axi_bresp,
  input  wire M0_m_axi_bvalid,
  output wire  M0_m_axi_bready,
  output wire  [31:0] M0_m_axi_araddr,
  output wire  M0_m_axi_arvalid,
  input  wire M0_m_axi_arready,
  input  wire [31:0] M0_m_axi_rdata,
  input  wire [1:0] M0_m_axi_rresp,
  input  wire M0_m_axi_rvalid,
  output wire  M0_m_axi_rready,

  output wire  [31:0] M1_m_axi_awaddr,
  output wire  M1_m_axi_awvalid,
  input  wire M1_m_axi_awready,
  output wire  [31:0] M1_m_axi_wdata,
  output wire  [3:0] M1_m_axi_wstrb,
  output wire  M1_m_axi_wvalid,
  input  wire M1_m_axi_wready,
  input  wire [1:0] M1_m_axi_bresp,
  input  wire M1_m_axi_bvalid,
  output wire  M1_m_axi_bready,
  output wire  [31:0] M1_m_axi_araddr,
  output wire  M1_m_axi_arvalid,
  input  wire M1_m_axi_arready,
  input  wire [31:0] M1_m_axi_rdata,
  input  wire [1:0] M1_m_axi_rresp,
  input  wire M1_m_axi_rvalid,
  output wire  M1_m_axi_rready,

  output reg  ctl_tx_data_rate,
  output reg  ctl_tx_ignore_fcs,
  output reg  ctl_tx_fcs_ins_enable,
  output reg  ctl_rx_data_rate,
  output reg  ctl_rx_ignore_fcs,
  output reg  [7:0] ctl_rx_min_packet_len,
  output reg  [15:0] ctl_rx_max_packet_len
);

  localparam MAC_CFG8_ADDR = 12'h000;
  localparam MAC_CFG9_ADDR = 12'h004;
  localparam MAC_CFG10_ADDR = 12'h008;
  localparam MAC_CFG11_ADDR = 12'h00C;
  localparam MAC_CFG12_ADDR = 12'h010;

  reg  [31:0] axi_awaddr;
  reg  axi_awvalid;
  reg  [31:0] axi_araddr;
  reg  axi_arvalid;
  reg  axi_wvalid;
  reg  [15:0] axi_wdata;
  wire [31:0] M0_m_axi_araddr_pre;
  wire [31:0] M0_m_axi_awaddr_pre;

  always @( posedge S0_s_axi_aclk or negedge S0_s_axi_aresetn )
    begin
      if ( S0_s_axi_aresetn != 1'b1 ) begin
        axi_awaddr  <= 32'd0;
        axi_awvalid <= 1'b0;
        axi_araddr  <= 32'd0;
        axi_arvalid <= 1'b0;
        axi_wvalid  <= 1'b0;
        axi_wdata   <= 16'd0;

        ctl_rx_data_rate <= 1'b0;
        ctl_tx_data_rate <= 1'b0;
        ctl_tx_fcs_ins_enable <= 1'b1;
        ctl_tx_ignore_fcs <= 1'b0;
        ctl_rx_ignore_fcs <= 1'b0;
        ctl_rx_min_packet_len <= 8'd64;
        ctl_rx_max_packet_len <= 16'd9600;
      end else begin
        axi_awaddr  <= S0_s_axi_awaddr;
        axi_awvalid <= S0_s_axi_awvalid;
        axi_araddr  <= S0_s_axi_araddr;
        axi_arvalid <= S0_s_axi_arvalid;
        axi_wvalid  <= S0_s_axi_wvalid;
        axi_wdata   <= S0_s_axi_wdata[15:0];

        if (axi_awvalid && axi_wvalid && S0_s_axi_awready && S0_s_axi_wready) begin
          case (axi_awaddr[11:0])
            MAC_CFG8_ADDR : begin
                              ctl_rx_data_rate <= axi_wdata[0];
                              ctl_tx_data_rate <= axi_wdata[1];
                             end
            MAC_CFG9_ADDR : begin
                              ctl_tx_fcs_ins_enable <= axi_wdata[1];
                              ctl_tx_ignore_fcs <= axi_wdata[2];
                            end
            MAC_CFG10_ADDR: begin
                              ctl_rx_ignore_fcs <= axi_wdata[2];
                            end
            MAC_CFG11_ADDR: begin
                              ctl_rx_min_packet_len <= axi_wdata[7:0];
                            end
            MAC_CFG12_ADDR: begin
                              ctl_rx_max_packet_len <= axi_wdata[15:0];
                            end
          endcase
        end
      end
    end

  gtfmac_wrapper_axi_crosspoint_gtfmac i_crosspoint_gtfmac (
    .S0_s_axi_aclk (S0_s_axi_aclk),
    .S0_s_axi_aresetn (S0_s_axi_aresetn),
    .S0_s_axi_awaddr (S0_s_axi_awaddr),
    .S0_s_axi_awvalid (S0_s_axi_awvalid),
    .S0_s_axi_awready (S0_s_axi_awready),
    .S0_s_axi_wdata (S0_s_axi_wdata),
    .S0_s_axi_wstrb (S0_s_axi_wstrb),
    .S0_s_axi_wvalid (S0_s_axi_wvalid),
    .S0_s_axi_wready (S0_s_axi_wready),
    .S0_s_axi_bresp (S0_s_axi_bresp),
    .S0_s_axi_bvalid (S0_s_axi_bvalid),
    .S0_s_axi_bready (S0_s_axi_bready),
    .S0_s_axi_araddr (S0_s_axi_araddr),
    .S0_s_axi_arvalid (S0_s_axi_arvalid),
    .S0_s_axi_arready (S0_s_axi_arready),
    .S0_s_axi_rdata (S0_s_axi_rdata),
    .S0_s_axi_rresp (S0_s_axi_rresp),
    .S0_s_axi_rvalid (S0_s_axi_rvalid),
    .S0_s_axi_rready (S0_s_axi_rready),

    .M0_m_axi_awvalid (M0_m_axi_awvalid),
    .M0_m_axi_awready (M0_m_axi_awready),
    .M0_m_axi_wdata (M0_m_axi_wdata),
    .M0_m_axi_wstrb (M0_m_axi_wstrb),
    .M0_m_axi_wvalid (M0_m_axi_wvalid),
    .M0_m_axi_wready (M0_m_axi_wready),
    .M0_m_axi_bresp (M0_m_axi_bresp),
    .M0_m_axi_bvalid (M0_m_axi_bvalid),
    .M0_m_axi_bready (M0_m_axi_bready),
    .M0_m_axi_arvalid (M0_m_axi_arvalid),
    .M0_m_axi_arready (M0_m_axi_arready),
    .M0_m_axi_rdata (M0_m_axi_rdata),
    .M0_m_axi_rresp (M0_m_axi_rresp),
    .M0_m_axi_rvalid (M0_m_axi_rvalid),
    .M0_m_axi_rready (M0_m_axi_rready),
    .M0_m_axi_awaddr (M0_m_axi_awaddr_pre),
    .M0_m_axi_araddr (M0_m_axi_araddr_pre),

    .M1_m_axi_awaddr (M1_m_axi_awaddr),
    .M1_m_axi_awvalid (M1_m_axi_awvalid),
    .M1_m_axi_awready (M1_m_axi_awready),
    .M1_m_axi_wdata (M1_m_axi_wdata),
    .M1_m_axi_wstrb (M1_m_axi_wstrb),
    .M1_m_axi_wvalid (M1_m_axi_wvalid),
    .M1_m_axi_wready (M1_m_axi_wready),
    .M1_m_axi_bresp (M1_m_axi_bresp),
    .M1_m_axi_bvalid (M1_m_axi_bvalid),
    .M1_m_axi_bready (M1_m_axi_bready),
    .M1_m_axi_araddr (M1_m_axi_araddr),
    .M1_m_axi_arvalid (M1_m_axi_arvalid),
    .M1_m_axi_arready (M1_m_axi_arready),
    .M1_m_axi_rdata (M1_m_axi_rdata),
    .M1_m_axi_rresp (M1_m_axi_rresp),
    .M1_m_axi_rvalid (M1_m_axi_rvalid),
    .M1_m_axi_rready (M1_m_axi_rready)
  );

  assign M0_m_axi_awaddr = M0_m_axi_awaddr_pre + (12'h130*4);
  assign M0_m_axi_araddr = M0_m_axi_araddr_pre + (12'h130*4);

endmodule

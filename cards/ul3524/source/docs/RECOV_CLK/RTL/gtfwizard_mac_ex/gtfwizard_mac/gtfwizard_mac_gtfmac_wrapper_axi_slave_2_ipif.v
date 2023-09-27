/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//------------------------------------------------------------------------------


`timescale 1ps/1ps
`default_nettype none
module gtfwizard_mac_gtfmac_wrapper_axi_slave_2_ipif #(
  parameter C_S_AXI_ADDR_WIDTH = 32,   // Width of M_AXI address bus
  parameter C_S_AXI_DATA_WIDTH = 32    // Width of M_AXI data bus
)
(
  ////////////////////////////////////////////////////////////////////////////
  // System Signals

  ////////////////////////////////////////////////////////////////////////////
  // AXI clock signal
  input wire s_axi_aclk,
  ////////////////////////////////////////////////////////////////////////////
  // AXI active low reset signal
  input wire s_axi_aresetn,

  ////////////////////////////////////////////////////////////////////////////
  // Slave Interface Write Address channel Ports

  ////////////////////////////////////////////////////////////////////////////
  // Master Interface Write Address Channel ports
  // Write address (issued by master, acceped by Slave)
  input  wire [C_S_AXI_ADDR_WIDTH - 1:0] s_axi_awaddr,
  ////////////////////////////////////////////////////////////////////////////
  // Write address valid. This signal indicates that the master signaling
  // valid write address and control information.
  input  wire                          s_axi_awvalid,
  ////////////////////////////////////////////////////////////////////////////
  // Write address ready. This signal indicates that the slave is ready
  // to accept an address and associated control signals.
  output wire                          s_axi_awready,

  ////////////////////////////////////////////////////////////////////////////
  // Slave Interface Write Data channel Ports
  // Write data (issued by master, acceped by Slave)
  input  wire [C_S_AXI_DATA_WIDTH-1:0] s_axi_wdata,
  ////////////////////////////////////////////////////////////////////////////
  // Write strobes. This signal indicates which byte lanes hold
  // valid data. There is one write strobe bit for each eight
  // bits of the write data bus.
  input  wire [C_S_AXI_DATA_WIDTH/8-1:0] s_axi_wstrb,
  ////////////////////////////////////////////////////////////////////////////
  //Write valid. This signal indicates that valid write
  // data and strobes are available.
  input  wire                          s_axi_wvalid,
  ////////////////////////////////////////////////////////////////////////////
  // Write ready. This signal indicates that the slave
  // can accept the write data.
  output wire                          s_axi_wready,

  ////////////////////////////////////////////////////////////////////////////
  // Slave Interface Write Response channel Ports

  ////////////////////////////////////////////////////////////////////////////
  // Write response. This signal indicates the status
  // of the write transaction.
  output wire [1:0]                    s_axi_bresp,
  ////////////////////////////////////////////////////////////////////////////
  // Write response valid. This signal indicates that the channel
  // is signaling a valid write response.
  output wire                          s_axi_bvalid,
  ////////////////////////////////////////////////////////////////////////////
  // Response ready. This signal indicates that the master
  // can accept a write response.
  input  wire                          s_axi_bready,

  ////////////////////////////////////////////////////////////////////////////
  // Slave Interface Read Address channel Ports
  // Read address (issued by master, acceped by Slave)
  input  wire [C_S_AXI_ADDR_WIDTH - 1:0] s_axi_araddr,
  ////////////////////////////////////////////////////////////////////////////
  // Read address valid. This signal indicates that the channel
  // is signaling valid read address and control information.
  input  wire                          s_axi_arvalid,
  ////////////////////////////////////////////////////////////////////////////
  // Read address ready. This signal indicates that the slave is
  // ready to accept an address and associated control signals.
  output wire                          s_axi_arready,

  ////////////////////////////////////////////////////////////////////////////
  // Slave Interface Read Data channel Ports
  // Read data (issued by slave)
  output wire [C_S_AXI_DATA_WIDTH-1:0] s_axi_rdata,
  ////////////////////////////////////////////////////////////////////////////
  // Read response. This signal indicates the status of the
  // read transfer.
  output wire [1:0]                    s_axi_rresp,
  ////////////////////////////////////////////////////////////////////////////
  // Read valid. This signal indicates that the channel is
  // signaling the required read data.
  output wire                          s_axi_rvalid,
  ////////////////////////////////////////////////////////////////////////////
  // Read ready. This signal indicates that the master can
  // accept the read data and response information.
  input  wire                          s_axi_rready,

  output wire                            Bus2IP_Clk,
  output wire                            Bus2IP_Resetn,
  output wire [C_S_AXI_ADDR_WIDTH-1:0]   Bus2IP_Addr,
  output wire                            Bus2IP_RNW,
  output wire                            Bus2IP_CS,
  output wire                            Bus2IP_RdCE,    // Not used
  output wire                            Bus2IP_WrCE,    // Not used
  output wire [C_S_AXI_DATA_WIDTH-1:0]   Bus2IP_Data,
  output wire [C_S_AXI_DATA_WIDTH/8-1:0] Bus2IP_BE,
  input  wire [C_S_AXI_DATA_WIDTH-1:0]   IP2Bus_Data,
  input  wire                            IP2Bus_WrAck,
  input  wire                            IP2Bus_RdAck,
  input  wire                            IP2Bus_WrError,
  input  wire                            IP2Bus_RdError
);

////////////////////////////////////////////////////////////////////////////
// local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
// ADDR_LSB is used for addressing 32/64 bit registers/memories
// ADDR_LSB = 2 for 32 bits (n downto 2)
// ADDR_LSB = 3 for 64 bits (n downto 3)

////////////////////////////////////////////////////////////////////////////
// function called clogb2 that returns an integer which has the
// value of the ceiling of the log base 2.
function integer clogb2 (input integer bd);
integer bit_depth;
begin
  bit_depth = bd;
  for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
    bit_depth = bit_depth >> 1;
  end
endfunction

localparam integer ADDR_LSB = clogb2(C_S_AXI_DATA_WIDTH/8)-1;
localparam integer ADDR_MSB = C_S_AXI_ADDR_WIDTH;

////////////////////////////////////////////////////////////////////////////
// AXI4 Lite internal signals

////////////////////////////////////////////////////////////////////////////
// read response
reg [1 :0]                   axi_rresp;
////////////////////////////////////////////////////////////////////////////
// write response
reg [1 :0]                   axi_bresp;
////////////////////////////////////////////////////////////////////////////
// write address acceptance
reg                          axi_awready;
////////////////////////////////////////////////////////////////////////////
// write data acceptance
reg                          axi_wready;
////////////////////////////////////////////////////////////////////////////
// write response valid
reg                          axi_bvalid;
////////////////////////////////////////////////////////////////////////////
// read data valid
reg                          axi_rvalid;
////////////////////////////////////////////////////////////////////////////
// write response reset
reg                          axi_bresp_reset;
////////////////////////////////////////////////////////////////////////////
// read response reset
reg                          axi_rresp_reset;
////////////////////////////////////////////////////////////////////////////
// write address
reg [ADDR_MSB-1:0] axi_awaddr;
////////////////////////////////////////////////////////////////////////////
// write data
reg [C_S_AXI_DATA_WIDTH-1:0] axi_wdata;
////////////////////////////////////////////////////////////////////////////
// write strobe
reg [C_S_AXI_DATA_WIDTH/8-1:0] axi_wstrb_reg;
reg [C_S_AXI_DATA_WIDTH/8-1:0] axi_wstrb;
////////////////////////////////////////////////////////////////////////////
// read address valid
reg [ADDR_MSB-1:0] axi_araddr;
////////////////////////////////////////////////////////////////////////////
// read data
reg [C_S_AXI_DATA_WIDTH-1:0] axi_rdata;
////////////////////////////////////////////////////////////////////////////
// read address acceptance
reg                          axi_arready;

////////////////////////////////////////////////////////////////////////////
// Example-specific design signals


////////////////////////////////////////////////////////////////////////////
// Signals for user logic chip select generation

////////////////////////////////////////////////////////////////////////////
// Signals for user logic register space example
// Four slave register

////////////////////////////////////////////////////////////////////////////
// Slave register read enable
reg                             slv_reg_rden;
////////////////////////////////////////////////////////////////////////////
// Slave register write enable
reg                             slv_reg_wren;
////////////////////////////////////////////////////////////////////////////

integer                         byte_index;

////////////////////////////////////////////////////////////////////////////
//I/O Connections assignments

////////////////////////////////////////////////////////////////////////////
//Write Address Ready (AWREADY)
assign s_axi_awready = axi_awready;

////////////////////////////////////////////////////////////////////////////
//Write Data Ready(WREADY)
assign s_axi_wready  = axi_wready;

////////////////////////////////////////////////////////////////////////////
//Write Response (BResp)and response valid (BVALID)
assign s_axi_bresp  = axi_bresp;
assign s_axi_bvalid = axi_bvalid;

////////////////////////////////////////////////////////////////////////////
//Read Address Ready(AREADY)
assign s_axi_arready = axi_arready;

////////////////////////////////////////////////////////////////////////////
//Read and Read Data (RDATA), Read Valid (RVALID) and Response (RRESP)
assign s_axi_rdata  = axi_rdata;
assign s_axi_rvalid = axi_rvalid;
assign s_axi_rresp  = axi_rresp;


////////////////////////////////////////////////////////////////////////////
// Implement axi_awready generation
//
//  axi_awready is asserted for one s_axi_aclk clock cycle when both
//  s_axi_awvalid and s_axi_wvalid are asserted. axi_awready is
//  de-asserted when reset is low.

  always @( posedge s_axi_aclk )
  begin
    if ( s_axi_aresetn == 1'b0 )
      begin
        axi_awready <= 1'b0;
      end
    else
      begin
        if (~axi_awready && s_axi_awvalid && s_axi_wvalid && ~slv_reg_wren)
          begin
            ////////////////////////////////////////////////////////////////////////////
            // slave is ready to accept write address when
            // there is a valid write address and write data
            // on the write address and data bus. This design
            // expects no outstanding transactions.
            axi_awready <= 1'b1;
          end
        else
          begin
            axi_awready <= 1'b0;
          end
      end
  end

////////////////////////////////////////////////////////////////////////////
// Implement axi_awaddr latching
//
//  This process is used to latch the address when both
//  s_axi_awvalid and s_axi_wvalid are valid.

  always @( posedge s_axi_aclk )
  begin
    if ( s_axi_aresetn == 1'b0 )
      begin
        axi_awaddr <= 0;
      end
    else
      begin
        if (~axi_awready && s_axi_awvalid && s_axi_wvalid)
          begin
            ////////////////////////////////////////////////////////////////////////////
            // address latching
            axi_awaddr <= s_axi_awaddr;
          end
      end
  end

// -------------------------------------------------------------------------
////////////////////////////////////////////////////////////////////////////
// Implement axi_wdata latching
//
//  This process is used to latch the address when both
//  S_AXI_WVALID and S_AXI_WREADY are valid.

  always @( posedge s_axi_aclk )
  begin
    if ( s_axi_aresetn == 1'b0 )
      begin
        axi_wdata <= 0;
      end
    else
      begin
        if (~axi_wready && s_axi_wvalid)
          begin
            ////////////////////////////////////////////////////////////////////////////
            // data latching
            axi_wdata <= s_axi_wdata;
          end
      end
  end

////////////////////////////////////////////////////////////////////////////
// Registering axi_wstrb

  always @( posedge s_axi_aclk )
  begin
    if ( s_axi_aresetn == 1'b0 )
      begin
        axi_wstrb_reg <= 0;
        axi_wstrb     <= 0;
      end
    else
      begin
        axi_wstrb_reg <= s_axi_wstrb;
        axi_wstrb     <= axi_wstrb_reg;
      end
  end
// -------------------------------------------------------------------------

////////////////////////////////////////////////////////////////////////////
// Implement axi_wready generation
//
//  axi_wready is asserted for one s_axi_aclk clock cycle when both
//  s_axi_awvalid and s_axi_wvalid are asserted. axi_wready is
//  de-asserted when reset is low.

  always @( posedge s_axi_aclk )
  begin
    if ( s_axi_aresetn == 1'b0 )
      begin
        axi_wready <= 1'b0;
      end
    else
      begin
        if (~axi_wready && s_axi_wvalid && s_axi_awvalid && ~slv_reg_wren)
          begin
            ////////////////////////////////////////////////////////////////////////////
            // slave is ready to accept write data when
            // there is a valid write address and write data
            // on the write address and data bus. This design
            // expects no outstanding transactions.
            axi_wready <= 1'b1;
          end
        else
          begin
            axi_wready <= 1'b0;
          end
      end
  end

// Slave register write enable is asserted when valid address and data are available
// and the slave is ready to accept the write address and write data.
  always @ (posedge s_axi_aclk )
  begin
    if ( s_axi_aresetn == 1'b0)
      slv_reg_wren <= 0;
    else if (axi_wready && s_axi_wvalid && axi_awready && s_axi_awvalid)
      slv_reg_wren <= 1;
    else if (IP2Bus_WrAck || IP2Bus_WrError)
      slv_reg_wren <= 0;
  end

////////////////////////////////////////////////////////////////////////////
// Implement write response logic generation
//
//  The write response and response valid signals are asserted by the slave
//  when axi_wready, s_axi_wvalid, axi_wready and s_axi_wvalid are asserted.
//  This marks the acceptance of address and indicates the status of
//  write transaction.

  always @( posedge s_axi_aclk )
  begin
    if ( s_axi_aresetn == 1'b0 )
      begin
        axi_bvalid  <= 0;
        axi_bresp   <= 2'b0;
        axi_bresp_reset <= 1'b1;
      end
    else
      begin
        // if (axi_awready && s_axi_awvalid && ~axi_bvalid && axi_wready && s_axi_wvalid)
        // ------------------------
        // write response is set to 2'b10 when there is a write error/failure
        if (slv_reg_wren && IP2Bus_WrError)
          begin
            axi_bvalid <= 1'b1;
            axi_bresp  <= 2'b11; // write side 'SLVERR' respose
          end
        // ------------------------
        else if (slv_reg_wren && IP2Bus_WrAck)
          begin
            // indicates a valid write response is available
            axi_bvalid <= 1'b1;
            axi_bresp  <= 2'b0; // 'OKAY' response
          end
        else if (s_axi_bready && axi_bvalid)
          begin
            //check if bready is asserted while bvalid is high)
            //(there is a possibility that bready is always asserted high)
            axi_bvalid <= 1'b0;
            // hold rresp for 1 more cycle
            axi_bresp_reset <= 1'b1;
          end
        else if (axi_bresp_reset)
          begin
            // revert rresp
            axi_bresp_reset <= 1'b0;
            axi_bresp  <= 2'b0; // 'OKAY' response
          end
      end
  end


////////////////////////////////////////////////////////////////////////////
// Implement axi_arready generation
//
//  axi_arready is asserted for one s_axi_aclk clock cycle when
//  s_axi_arvalid is asserted. axi_awready is
//  de-asserted when reset (active low) is asserted.
//  The read address is also latched when s_axi_arvalid is
//  asserted. axi_araddr is reset to zero on reset assertion.

  always @( posedge s_axi_aclk )
  begin
    if ( s_axi_aresetn == 1'b0 )
      begin
        axi_arready <= 1'b0;
        axi_araddr  <= {ADDR_MSB{1'b0}};
      end
    else
      begin
        if (~axi_arready && s_axi_arvalid && ~axi_rvalid && ~slv_reg_rden)
          begin
            // indicates that the slave has acceped the valid read address
            axi_arready <= 1'b1;
            axi_araddr  <= s_axi_araddr;
          end
        else
          begin
            axi_arready <= 1'b0;
          end
      end
  end

////////////////////////////////////////////////////////////////////////////
// Implement memory mapped register select and read logic generation
//
//  axi_rvalid is asserted for one s_axi_aclk clock cycle when both
//  a read is outstand (slv_reg_rden) and the IPIF Read is acknolwedged 
//  (IP2Bus_RdAck). It is deasserted on reset (active low). 
//  axi_rresp and axi_rdata are cleared to zero on reset (active low).

  always @( posedge s_axi_aclk )
  begin
    if ( s_axi_aresetn == 1'b0 )
      begin
        axi_rvalid <= 1'b0;
        axi_rresp  <= 2'b0;
        axi_rresp_reset  <= 1'b0;
      end
    else
      begin
        // if (axi_arready && s_axi_arvalid && ~axi_rvalid && IP2Bus_RdAck)
        // ------------------------
        //read response is set to 2'b11 when there is a read error/failure
        if (slv_reg_rden && IP2Bus_RdError)
          begin
            axi_rvalid <= 1'b1;
            axi_rresp  <= 2'b11; // read side 'SLVERR' respose
          end
        // ------------------------
        else if (slv_reg_rden && IP2Bus_RdAck)
          begin
            // Valid read data is available at the read data bus
            axi_rvalid <= 1'b1;
            axi_rresp  <= 2'b0; // 'OKAY' response
          end
        else if (axi_rvalid && s_axi_rready)
          begin
            // Read data is accepted by the master
            axi_rvalid <= 1'b0;
            // hold rresp for 1 more cycle
            axi_rresp_reset <= 1'b1;
          end
        else if (axi_rresp_reset & !IP2Bus_RdError)
          begin
            // revert rresp
            axi_rresp_reset <= 1'b0;
            axi_rresp  <= 2'b0; // 'OKAY' response
          end
      end
  end


////////////////////////////////////////////////////////////////////////////
// Slave register read enable is asserted when valid address is available
// and the slave is ready to accept the read address.
  always @ (posedge s_axi_aclk )
  begin
    if ( s_axi_aresetn == 1'b0)
      slv_reg_rden <= 0;
    else if (axi_arready && s_axi_arvalid && ~axi_rvalid)
      slv_reg_rden <= 1;
    else if (IP2Bus_RdAck || IP2Bus_RdError)
      slv_reg_rden <= 0;
  end

  always @( posedge s_axi_aclk )
  begin
    if ( s_axi_aresetn == 1'b0 )
      begin
        axi_rdata  <= 0;
      end
    else
      begin
        ////////////////////////////////////////////////////////////////////////////
        // When there is a valid read response from the IPIF 
        // output the read dada
        if (slv_reg_rden && IP2Bus_RdAck)
          begin
            axi_rdata <= IP2Bus_Data;     // register read data
          end
      end
  end

  assign Bus2IP_Clk    = s_axi_aclk;
  assign Bus2IP_Resetn = s_axi_aresetn;
  assign Bus2IP_Addr   = slv_reg_wren ? axi_awaddr : axi_araddr ;
  assign Bus2IP_RNW    = slv_reg_rden;
  assign Bus2IP_CS     = slv_reg_rden | slv_reg_wren;
  assign Bus2IP_RdCE   = 1'b0;
  assign Bus2IP_WrCE   = 1'b0;
  //assign Bus2IP_Data   = s_axi_wdata;
  assign Bus2IP_Data   = slv_reg_wren ? axi_wdata : 32'd0;
  //assign Bus2IP_BE     = slv_reg_wren ? s_axi_wstrb : {C_S_AXI_DATA_WIDTH{1'b1}};
  assign Bus2IP_BE     = slv_reg_wren ? axi_wstrb : {C_S_AXI_DATA_WIDTH{1'b1}};

endmodule
`default_nettype wire

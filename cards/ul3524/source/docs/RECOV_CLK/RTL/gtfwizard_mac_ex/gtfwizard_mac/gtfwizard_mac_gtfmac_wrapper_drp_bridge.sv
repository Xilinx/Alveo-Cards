/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//------------------------------------------------------------------------------


`timescale 1ps/1ps
`default_nettype none
module gtfwizard_mac_gtfmac_wrapper_drp_bridge #(
    parameter DRP_COUNT         = 4,
              DRP_ADDR_WIDTH    = 9,
              DRP_DATA_WIDTH    = 16
    ) (
  input  wire s_axi_aclk,
  input  wire s_axi_aresetn,
  input  wire [31:0] s_axi_awaddr,
  input  wire s_axi_awvalid,
  output reg  s_axi_awready,
  input  wire [31:0] s_axi_wdata,
  input  wire [3:0] s_axi_wstrb,
  input  wire s_axi_wvalid,
  output reg  s_axi_wready,
  output reg  [1:0] s_axi_bresp,
  output reg  s_axi_bvalid,
  input  wire s_axi_bready,
  input  wire [31:0] s_axi_araddr,
  input  wire s_axi_arvalid,
  output reg  s_axi_arready,
  output reg  [31:0] s_axi_rdata,
  output reg  [1:0] s_axi_rresp,
  output reg  s_axi_rvalid,
  input  wire s_axi_rready,

  output   reg   [DRP_COUNT-1:0]                          drp_en,
  output   wire  [DRP_COUNT-1:0]                          drp_we,
  output   wire  [DRP_COUNT-1:0] [DRP_ADDR_WIDTH-1: 0]    drp_addr,
  output   wire  [DRP_COUNT-1:0] [DRP_DATA_WIDTH-1: 0]    drp_di,
  input    wire  [DRP_COUNT-1:0] [DRP_DATA_WIDTH-1: 0]    drp_do,
  input    wire  [DRP_COUNT-1:0]                          drp_rdy

);

localparam NUM_DATA_BYTES       =       int'( ( DRP_DATA_WIDTH + 7 ) / 8 ) ;

reg                            i_drp_we;
reg   [DRP_ADDR_WIDTH-1: 0]    i_drp_addr;
reg   [DRP_DATA_WIDTH-1: 0]    i_drp_di;

assign  drp_we   = {DRP_COUNT{i_drp_we}},
        drp_addr = {DRP_COUNT{i_drp_addr}},
        drp_di   = {DRP_COUNT{i_drp_di}};

localparam  SEL_ADDR_SIZE = (DRP_COUNT==1) ? 1 : $clog2( DRP_COUNT );

localparam [1:0] OKAY   = 2'b00,
                 EXOKAY = 2'b01,
                 SLVERR = 2'b10,
                 DECERR = 2'b11;

reg [SEL_ADDR_SIZE-1:0] write_select, read_select;
reg read_flag_addr, write_flag_addr, write_flag_data;                      // flags to note the address and data phase, which can occur simultaneously
reg [3:0]  write_strobe;
reg read_flag, write_flag;
reg [9:0] bus_timer;
reg bus_reset;
reg [DRP_ADDR_WIDTH-1: 0]  ra_buff, wa_buff;

always @( posedge s_axi_aclk or negedge s_axi_aresetn )
    begin
      if ( s_axi_aresetn != 1'b1 ) begin
        s_axi_awready     <=  1'b1;            // Assert the ready signals
        s_axi_wready      <=  1'b1;
        s_axi_arready     <=  1'b1;

        s_axi_bresp       <=  OKAY;
        s_axi_bvalid      <=  0;
        s_axi_rdata       <=  32'h0;
        s_axi_rresp       <=  OKAY;
        s_axi_rvalid      <=  0;

        read_flag_addr    <=  0;
        write_flag_addr   <=  0;
        write_flag_data   <=  0;

        drp_en            <=  {DRP_COUNT{1'b0}};
        i_drp_we          <=  1'b0;
        i_drp_di          <=  {DRP_DATA_WIDTH{1'b0}} ;

        ra_buff           <=  {DRP_ADDR_WIDTH{1'b0}};
        wa_buff           <=  {DRP_ADDR_WIDTH{1'b0}};
        i_drp_addr        <=  {DRP_ADDR_WIDTH{1'b0}};
        write_select      <=  {SEL_ADDR_SIZE{1'b0}};
        read_select       <=  {SEL_ADDR_SIZE{1'b0}};

        read_flag         <=  1'b0;
        write_flag        <=  1'b0;
        write_strobe      <=  0 ;
        bus_timer         <=  0;
        bus_reset         <=  1'b0;
      end
      else begin
        drp_en            <= {DRP_COUNT{1'b0}};
        i_drp_we          <=  1'b0;

        bus_timer         <= (write_flag || read_flag) ? bus_timer+1 : 0;               // The bus timer times the period of the drp access
        bus_reset         <= &bus_timer;                                                // If there is never a drp_rdy signal, then assert the bus reset

        if(s_axi_bvalid && s_axi_bready) begin s_axi_bvalid <= 1'b0; s_axi_bresp <= OKAY;  end       // write termination and removal of valid
        if(s_axi_rvalid && s_axi_rready) begin s_axi_rvalid <= 1'b0; s_axi_rresp <= OKAY;  end       // read termination and removal of valid

        if (s_axi_awready && s_axi_awvalid) begin                            // capture write cycle address phase
          s_axi_awready        <=  1'b0;                                     // Remove the address ready signal
          wa_buff              <=  s_axi_awaddr[2+:DRP_ADDR_WIDTH];          // Save the write address
          write_select         <=  (DRP_COUNT==1) ? 0 : s_axi_awaddr[(DRP_ADDR_WIDTH+2)+:SEL_ADDR_SIZE];
          write_flag_addr      <=  1'b1;
        end

        if (s_axi_wready && s_axi_wvalid) begin                // capture write cycle data phase
          s_axi_wready               <= 1'b0;
          i_drp_di                   <= s_axi_wdata[0+:DRP_DATA_WIDTH];
          write_strobe               <= s_axi_wstrb;
          write_flag_data            <= 1'b1;
        end

        if (s_axi_arready && s_axi_arvalid) begin                       // capture read cycle address phase
          s_axi_arready             <=  1'b0;                           // Clear the read address ready indicator
          ra_buff                   <=  s_axi_araddr[2+:DRP_ADDR_WIDTH];
          read_select               <=  (DRP_COUNT==1) ? 0 : s_axi_araddr[(DRP_ADDR_WIDTH+2)+:SEL_ADDR_SIZE];
          read_flag_addr            <=  1'b1;
        end

        if(write_flag_addr && write_flag_data && !write_flag)begin      // If both address and data phases have occurred, then write the data
          i_drp_addr                 <=  wa_buff;                       // Transfer the write address into the DRP slave
          i_drp_we                   <=  1'b1;
          drp_en[write_select]       <=  1'b1;
          write_flag_addr            <=  1'b0;                          // Clear the address and data phase indicators
          write_flag_data            <=  1'b0;
          write_flag                 <=  1'b1;                           // Set the write-cycle-in-progress flag
          s_axi_awready              <=  1'b1;                           // Re-enable the write address and write data ready indicators
          s_axi_wready               <=  1'b1;
          s_axi_bvalid               <=  1'b0;                          // Ensure that the valid signal is not asserted. (it shouldn't be...this is just a catch-all)
        end
        else if(read_flag_addr && !read_flag && !write_flag)begin    // If the read cycle address phase has occurred, then initiate the read
          drp_en[read_select]       <=  1'b1;
          i_drp_addr                <=  ra_buff;                // Transfer the read address into the DRP slave
          read_flag_addr            <=  1'b0;                   // Clear the read cycle address phase indicator
          read_flag                 <=  1'b1;                   // Set the read-cycle-in-progress flag
          s_axi_arready             <=  1'b1;                   // Re-enable the read cycle address phase
          s_axi_rvalid              <=  1'b0;                   // Ensure that the valid signal is not asserted. (it shouldn't be...this is just a catch-all)
        end

        if (read_flag && !s_axi_rvalid && drp_rdy[read_select]) begin     // On a read cycle, when drp_rdy is asserted, then capture the data
           s_axi_rvalid      <= 1'b1;                                      // and set the completion status
           s_axi_rresp       <= OKAY;
           read_flag         <= 1'b0;
           s_axi_rdata       <= 32'h0;
           s_axi_rdata       <=  drp_do[read_select];
        end

        if (write_flag && !s_axi_bvalid && drp_rdy[write_select]) begin          // On a write cycle, when drp_rdy is asserted, then terminate the cycle
           s_axi_bvalid      <= 1'b1;
           s_axi_bresp       <= (~&write_strobe[0+:NUM_DATA_BYTES]) ? SLVERR : OKAY;                    // The DRP access in not bytewise...All strobes must be active
           write_flag        <= 1'b0;
        end

        if(bus_reset)begin      // if a bus timeout occurs then mark the cycle as complete and set slave error
          if( write_flag )begin
            s_axi_bvalid      <= 1'b1;
            s_axi_bresp       <= SLVERR ;
            write_flag        <= 1'b0;
          end
          if (read_flag ) begin
            s_axi_rvalid      <= 1'b1;
            s_axi_rresp       <= SLVERR;
            read_flag         <= 1'b0;
          end
        end
      end
    end

endmodule
`default_nettype wire

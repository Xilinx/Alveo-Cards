/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//-----------------------------------------------------------------------------
//
// Description: axi_qdriip_bridge
//
// Verilog-standard:  Verilog 2001
//
//--------------------------------------------------------------------------
`timescale 1ps/1ps
`default_nettype none

(* DowngradeIPIdentifiedWarnings="yes" *) 
module axi_qdriip_bridge_v1_0_0_rd_controller #
  (
   parameter integer C_S_AXI_ID_WIDTH                   = 1, 
                       // Width of all ID signals on SI side of converter.
                       // Range: 1 - 32.
   parameter integer C_S_AXI_ADDR_WIDTH                = 23, 
   parameter integer C_S_AXI_DATA_WIDTH                = 64,
   parameter integer C_QDRIIP_ADDR_WIDTH               = 22,
   parameter integer C_QDRIIP_DATA_WIDTH               = 72
   )
  (
  (* KEEP = "TRUE" *) input  wire          s_axi_aclk,
  (* KEEP = "TRUE" *) input  wire          s_axi_aresetn,
  input  wire [C_S_AXI_ID_WIDTH-1:0]       s_axi_arid,
  input  wire [C_S_AXI_ADDR_WIDTH-1:0]     s_axi_araddr,
  input  wire [8-1:0] s_axi_arlen,
  input  wire                              s_axi_arvalid,
  output wire                              s_axi_arready,
  // Slave Interface Read Data Ports
  output wire [C_S_AXI_ID_WIDTH-1:0]       s_axi_rid,
  output wire [C_S_AXI_DATA_WIDTH-1:0]     s_axi_rdata,
  output wire [2-1:0]                      s_axi_rresp,
  output wire                              s_axi_rlast,
  output wire                              s_axi_rvalid,
  input  wire                              s_axi_rready,

  output wire                              qdriip_app_rd_cmd,
  output wire [C_QDRIIP_ADDR_WIDTH-1 : 0]  qdriip_app_rd_addr,
  input  wire [C_QDRIIP_DATA_WIDTH-1 : 0]  qdriip_app_rd_data,
  input  wire                              qdriip_app_rd_valid,
  output wire                              rd_error
  );
  
wire [C_S_AXI_ADDR_WIDTH-1:0]     araddr;
reg  [7:0]                        cmd_beat_counter = 8'h00;
reg                               rx_fifo_push = 1'b0;
wire                              rx_fifo_full;
wire                              rx_fifo_empty;
reg                               arready = 1'b0;
reg                               app_rd_cmd = 1'b0;
reg  [C_QDRIIP_ADDR_WIDTH-1 : 0]  app_rd_addr;
reg  [C_S_AXI_DATA_WIDTH-1 : 0]   rdata;


localparam  AXI_RESP_OKAY     = 2'b00;
localparam  AXI_RESP_EXOKAY   = 2'b01;
localparam  AXI_RESP_SLVERR   = 2'b10;
localparam  AXI_RESP_DECERR   = 2'b11;

////////////////////////////////////////////////////////////////////////////////

enum {RD_CMD_IDLE, RD_CMD_PROCESS_RD} currState;
always @(posedge s_axi_aclk) begin
  if (!s_axi_aresetn) begin
    currState <= RD_CMD_IDLE;
    arready <= 1'b0;
    app_rd_cmd <= 1'b0;
    rx_fifo_push <= 1'b0;
    cmd_beat_counter <= 8'h00;
  end else begin
    arready <= 1'b0;
    rx_fifo_push <= 1'b0;
    app_rd_cmd <= 1'b0;
    ////////////////////////////////////////////////////////////////////////////////
    //State machine to control the app interface
    case (currState)
      RD_CMD_IDLE: begin
        ////////////////////////////////////////////////////////////////////////////////
        //When valid is presented start the transfers.
        // Do not process any more transactions if the RX_FIFO is full.
        if (s_axi_arvalid && !rx_fifo_full) begin
          currState <= RD_CMD_PROCESS_RD;
          arready <= 1'b1;
          cmd_beat_counter <= s_axi_arlen;
          app_rd_addr <= s_axi_araddr >> 3;
          rx_fifo_push <= 1'b1;
          app_rd_cmd <= 1'b1;
        end
      end
      RD_CMD_PROCESS_RD: begin
        if (cmd_beat_counter == 8'h00) begin
          currState <= RD_CMD_IDLE;
          app_rd_cmd <= 1'b0;
        end else begin
          currState <= RD_CMD_PROCESS_RD;
          app_rd_cmd <= 1'b1;
        end
        cmd_beat_counter <= cmd_beat_counter - 1'b1;
        app_rd_addr <= app_rd_addr + 1;
      end
    endcase
  end
end


enum {RD_IDLE, RD_ACITVE} RdState;

////////////////////////////////////////////////////////////////////////////////
//Need to store the ARID and ARLEN to generate the RID and RLAST back into AXI
//Concatinate the conto
reg  [7:0]                        rx_beat_counter = 8'h00;
wire [C_S_AXI_ID_WIDTH-1:0]       rx_fifo_arid;
wire [8-1:0]                      rx_fifo_arlen;

////////////////////////////////////////////////////////////////////////////////
// NOTE: There may need to be a check on this for available entries in the fifo
wire                              rx_fifo_pop = (RdState == RD_IDLE) && !rx_fifo_empty;

wire                              rx_fifo_overflow;
wire                              rx_fifo_underflow;
reg                               rx_fifo_error = 1'b0;

axi_qdriip_bridge_v1_0_0_xpm_fifo_wrapper #(
  .C_ACLK_RELATIONSHIP    ( 1 ), // 0: Async, 1: Sync, 2+, 2-: Related ratio
  .C_FIFO_MEMORY_TYPE     ( 0 ), 
  .C_FIFO_SIZE            ( 5 ), // Fifo depth, 2+
  .C_FIFO_WIDTH           ( C_S_AXI_ID_WIDTH + 8 ), // Bit width of FIFO, 1+
  .C_READ_MODE            ( 1 ), // 0: No FWFT, 1: FWFT, 2: Low Latency Sync with reg output.
  .C_FIFO_READ_LATENCY    ( 0 ), // Read latency passed to xpm primitive, Distributed Memory can be 0 or great Block Memory must be 1 or greater
  .C_SIM_ASSERT_CHK       ( 1 ) // Not implemented!
) FIFO (
  // Write clock domain
  .wr_clk         ( s_axi_aclk ),
  .wr_rst         ( !s_axi_aresetn ),
  .wr_en          ( rx_fifo_push ),
  .din            ( {s_axi_arid, s_axi_arlen} ),
  .full           ( rx_fifo_full ),
  .afull          ( ),
  .prog_full      ( ),
  .overflow       ( rx_fifo_overflow ),

  // Read clock domain
  .rd_clk         ( s_axi_aclk ),
  .rd_rst         ( !s_axi_aresetn ),
  .rd_en          ( rx_fifo_pop ),
  .dout           ( {rx_fifo_arid, rx_fifo_arlen}),
  .empty          ( rx_fifo_empty ),
  .underflow      ( rx_fifo_underflow )
);

////////////////////////////////////////////////////////////////////////////////
//With every valid read beat decrement the rx_beat_counter
//
// This is could become a problem if there is backpressure from the MASTER (RREADY is not asserted)
// Use of axis_subset_converter will indicate a failure, but does not recover.....
// This would then lock up the AXI interface.
reg [C_QDRIIP_DATA_WIDTH-1:0] app_rd_data_q;
reg                           app_rd_valid_q = 1'b0;
reg [C_S_AXI_ID_WIDTH-1:0]    active_arid = {C_S_AXI_ID_WIDTH{1'b1}};

always @(posedge s_axi_aclk) begin
  if (!s_axi_aresetn) begin
    RdState <= RD_IDLE;
    rx_beat_counter <= 8'h00;
    rx_fifo_error <= 1'b0;
    app_rd_valid_q <= 1'b0;
    app_rd_data_q <= {C_QDRIIP_DATA_WIDTH{1'b0}};
    active_arid <= {C_S_AXI_ID_WIDTH{1'b1}};
  end else begin
    app_rd_valid_q <= qdriip_app_rd_valid;
    if (qdriip_app_rd_valid) begin
      app_rd_data_q <= qdriip_app_rd_data;
    end
    case(RdState)
      RD_IDLE: begin
        RdState <= RD_IDLE;
        if (rx_fifo_pop) begin
          RdState <= RD_ACITVE;
          rx_beat_counter <= rx_fifo_arlen;
          active_arid <= rx_fifo_arid;
        end
      end
      RD_ACITVE: begin
        RdState <= RD_ACITVE;
        if (app_rd_valid_q) begin
          if (rx_beat_counter == 8'h00) begin
            RdState <= RD_IDLE;
          end else begin
            rx_beat_counter <= rx_beat_counter - 1'b1;
          end
        end
      end
    endcase
    rx_fifo_error <= rx_fifo_error || (rx_fifo_overflow || rx_fifo_underflow) || (s_axi_rvalid && !s_axi_rready);
  end
end

////////////////////////////////////////////////////////////////////////////////
//Unpack the parity bit
always_comb begin 
  for (int i = 0; i < C_QDRIIP_DATA_WIDTH/9; i++) begin : gen_r_stride
    rdata[i*8+:8] = app_rd_data_q[i*9+:8];
  end
end

////////////////////////////////////////////////////////////////////////////////
// Drive outputs
assign s_axi_arready = arready;
assign qdriip_app_rd_cmd = app_rd_cmd;
assign qdriip_app_rd_addr = app_rd_addr;
assign s_axi_rdata = rdata;
assign s_axi_rlast = (rx_beat_counter == 8'h00);
assign s_axi_rid   = active_arid;
assign rd_error    = rx_fifo_error;
assign s_axi_rresp = (rd_error) ? AXI_RESP_SLVERR : AXI_RESP_OKAY;
assign s_axi_rvalid = app_rd_valid_q;
endmodule : axi_qdriip_bridge_v1_0_0_rd_controller
`default_nettype wire


/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//-----------------------------------------------------------------------------
//
// Description: axi_qdriip_bridge
//
// Verilog-standard:  Verilog 2001
//
//--------------------------------------------------------------------------
`timescale 1ps/1ps
`default_nettype none

(* DowngradeIPIdentifiedWarnings="yes" *) 
module axi_qdriip_bridge_v1_0_0_wr_controller #
  (
   parameter integer C_S_AXI_ID_WIDTH                  = 1, 
                       // Width of all ID signals on SI side of converter.
                       // Range: 1 - 32.
   parameter integer C_S_AXI_ADDR_WIDTH                = 23, 
   parameter integer C_S_AXI_DATA_WIDTH                = 64,
   parameter integer C_QDRIIP_ADDR_WIDTH               = 22,
   parameter integer C_QDRIIP_DATA_WIDTH               = 72
   )
  (
  (* KEEP = "TRUE" *) input  wire          s_axi_aclk,
  (* KEEP = "TRUE" *) input  wire          s_axi_aresetn,
  input  wire [C_S_AXI_ID_WIDTH-1:0]       s_axi_awid,
  input  wire [C_S_AXI_ADDR_WIDTH-1:0]     s_axi_awaddr,
  input  wire [8-1:0] s_axi_awlen,
  input  wire                              s_axi_awvalid,
  output wire                              s_axi_awready,
  // Slave Interface Read Data Ports
  output wire [C_S_AXI_ID_WIDTH-1:0]       s_axi_bid,
  output wire [2-1:0]                      s_axi_bresp,
  output wire                              s_axi_bvalid,
  input  wire                              s_axi_bready,

  input  wire [C_S_AXI_DATA_WIDTH-1:0]     s_axi_wdata,
  input  wire [C_S_AXI_DATA_WIDTH/8-1:0]   s_axi_wstrb,
  input  wire                              s_axi_wvalid,
  input  wire                              s_axi_wlast,
  output wire                              s_axi_wready,

  output wire                                   qdriip_app_wr_cmd,
  output wire [C_QDRIIP_ADDR_WIDTH-1 : 0]       qdriip_app_wr_addr,
  output wire [C_QDRIIP_DATA_WIDTH-1 : 0]       qdriip_app_wr_data,
  output wire [C_QDRIIP_DATA_WIDTH/9 - 1 : 0]   qdriip_app_wr_bw_n,
  output wire                                   wr_error
);
  
wire [C_S_AXI_ADDR_WIDTH-1:0]     awaddr;
reg  [7:0]                        cmd_beat_counter = 8'h00;
reg                               resp_fifo_push = 1'b0;
wire                              resp_fifo_full;
wire                              resp_fifo_empty;
reg                               awready = 1'b0;
reg                               wready = 1'b0;
reg                               bvalid = 1'b0;
reg  [C_QDRIIP_ADDR_WIDTH-1 : 0]  app_wr_addr;
reg  [C_S_AXI_DATA_WIDTH-1 : 0]   wdata;
reg  [C_QDRIIP_DATA_WIDTH-1 : 0]  app_wr_data;

localparam  AXI_RESP_OKAY     = 2'b00;
localparam  AXI_RESP_EXOKAY   = 2'b01;
localparam  AXI_RESP_SLVERR   = 2'b10;
localparam  AXI_RESP_DECERR   = 2'b11;

////////////////////////////////////////////////////////////////////////////////
enum {WR_CMD_IDLE, WR_CMD_PROCESS, WR_CMD_DONE} currState;
always @(posedge s_axi_aclk) begin
  if (!s_axi_aresetn) begin
    currState <= WR_CMD_IDLE;
    awready <= 1'b0;
    wready <= 1'b0;
    resp_fifo_push <= 1'b0;
    cmd_beat_counter <= 8'h00;
  end else begin
    awready <= 1'b0;
    resp_fifo_push <= 1'b0;
    ////////////////////////////////////////////////////////////////////////////////
    //State machine to control the app interface
    case (currState)
      WR_CMD_IDLE: begin
        ////////////////////////////////////////////////////////////////////////////////
        //When valid is presented start the transfers.
        // Do not process any more transactions if the resp_fifo is full.
        if (s_axi_awvalid && s_axi_wvalid && !resp_fifo_full) begin
          cmd_beat_counter <= s_axi_awlen;
          app_wr_addr <= s_axi_awaddr >> 3;
          currState <= WR_CMD_PROCESS;
          wready <= 1'b1;
        end else begin
          wready <= 1'b0;          
        end
      end
      WR_CMD_PROCESS: begin
        wready <= 1'b1;
        if (s_axi_wvalid) begin
          cmd_beat_counter <= cmd_beat_counter - 1'b1;
          app_wr_addr <= app_wr_addr + 1;
            ////////////////////////////////////////////////////////////////////////////////
          //When the number of beats is 0 stop.        
          if (s_axi_wlast) begin
            currState <= WR_CMD_DONE;          
            awready <= 1'b1;
            resp_fifo_push <= 1'b1;
            wready <= 1'b0;
          end else begin
            currState <= WR_CMD_PROCESS;
          end
        end else begin
          currState <= WR_CMD_PROCESS;
        end
      end
      WR_CMD_DONE: begin
        currState <= WR_CMD_IDLE;
        wready <= 1'b0;
      end
    endcase
  end
end

////////////////////////////////////////////////////////////////////////////////
//Need to store the ARID and ARLEN to generate the RID and RLAST back into AXI
//Concatinate the conto
wire [C_S_AXI_ID_WIDTH-1:0]       resp_fifo_awid;

////////////////////////////////////////////////////////////////////////////////
// NOTE: There may need to be a check on this for available entries in the fifo
wire                              resp_fifo_pop = s_axi_bready && s_axi_bvalid && !resp_fifo_empty;

wire                              resp_fifo_overflow;
wire                              resp_fifo_underflow;
reg                               resp_fifo_error = 1'b0;

axi_qdriip_bridge_v1_0_0_xpm_fifo_wrapper #(
  .C_ACLK_RELATIONSHIP    ( 1 ), // 0: Async, 1: Sync, 2+, 2-: Related ratio
  .C_FIFO_MEMORY_TYPE     ( 0 ), 
  .C_FIFO_SIZE            ( 5 ), // Fifo depth, 2+
  .C_FIFO_WIDTH           ( C_S_AXI_ID_WIDTH ), // Bit width of FIFO, 1+
  .C_READ_MODE            ( 1 ), // 0: No FWFT, 1: FWFT, 2: Low Latency Sync with reg output.
  .C_FIFO_READ_LATENCY    ( 0 ), // Read latency passed to xpm primitive, Distributed Memory can be 0 or great Block Memory must be 1 or greater
  .C_SIM_ASSERT_CHK       ( 1 ) // Not implemented!
) FIFO (
  // Write clock domain
  .wr_clk         ( s_axi_aclk ),
  .wr_rst         ( !s_axi_aresetn ),
  .wr_en          ( resp_fifo_push ),
  .din            ( s_axi_awid ),
  .full           ( resp_fifo_full ),
  .afull          ( ),
  .prog_full      ( ),
  .overflow       ( resp_fifo_overflow ),

  // Read clock domain
  .rd_clk         ( s_axi_aclk ),
  .rd_rst         ( !s_axi_aresetn ),
  .rd_en          ( s_axi_bvalid && s_axi_bready ),
  .dout           ( resp_fifo_awid ),
  .empty          ( resp_fifo_empty ),
  .underflow      ( resp_fifo_underflow )
);

////////////////////////////////////////////////////////////////////////////////
// Response state machine
//
// It is possible that there is back pressure on the bready signal from the master and
// to allow some flexibility, a FIFO is added to capture the ID's of the WRITES.
// Due to ordering rules the BVALID cannot be asserted until after the AW and WLast acceptance.
// This means that though the BID can be driven the BVALID needs to wait.
// In this case we know that the command state machine will push the ID after the AWREADY has 
// been asserted thus accepting the AW channel.

enum {RESP_IDLE, RESP_HANDSHAKE} respState;
reg [C_S_AXI_ID_WIDTH-1:0]       active_awid = {C_S_AXI_ID_WIDTH{1'b1}};

always @(posedge s_axi_aclk) begin
  if (!s_axi_aresetn) begin
    respState <= RESP_IDLE;
    bvalid <= 1'b0;
    resp_fifo_error <= 1'b0;
    active_awid <= {C_S_AXI_ID_WIDTH{1'b1}};
  end else begin
    bvalid <= 1'b0;
    case (respState)
      RESP_IDLE: begin
        if (!resp_fifo_empty) begin
          bvalid <= 1'b1;
          respState <= RESP_HANDSHAKE;
          active_awid <= resp_fifo_awid;
        end
      end
      RESP_HANDSHAKE: begin
        bvalid <= 1'b1;
        if (s_axi_bvalid && s_axi_bready) begin
          respState <= RESP_IDLE;
          bvalid <= 1'b0;
        end
      end
    endcase
    resp_fifo_error <= resp_fifo_error || (resp_fifo_overflow || resp_fifo_underflow);
  end
end

////////////////////////////////////////////////////////////////////////////////
//Unpack the parity bit
always_comb begin 
  for (int i = 0; i < C_QDRIIP_DATA_WIDTH/9; i++) begin : gen_stride
    app_wr_data[i*9+:9] = {^(s_axi_wdata[i*8+:8]),s_axi_wdata[i*8+:8]};
  end
end

////////////////////////////////////////////////////////////////////////////////
// Drive outputs
assign s_axi_awready      = awready;
assign s_axi_wready       = wready;
assign qdriip_app_wr_cmd  = (s_axi_wready && s_axi_wvalid);
assign qdriip_app_wr_addr = app_wr_addr;
assign s_axi_bid          = active_awid;
assign s_axi_bvalid       = bvalid;
assign s_axi_bresp        = AXI_RESP_OKAY;
assign wr_error           = resp_fifo_error;
assign qdriip_app_wr_bw_n = ~s_axi_wstrb;
assign qdriip_app_wr_data = app_wr_data;
endmodule : axi_qdriip_bridge_v1_0_0_wr_controller
`default_nettype wire


/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//-----------------------------------------------------------------------------

`default_nettype none

module axi_qdriip_bridge_v1_0_0_xpm_fifo_wrapper #(
  parameter integer C_ACLK_RELATIONSHIP    = 1, // 0: Async, 1: Sync, 2+, 2-: Related ratio
  parameter integer C_FIFO_MEMORY_TYPE     = 1, // 0: Distributed; 1: BRAM

  parameter integer C_FIFO_SIZE            = 5, // Fifo depth, 2+
  parameter integer C_FIFO_WIDTH           = 1, // Bit width of FIFO, 1+
  parameter integer C_PROG_FULL_THRESH     = 2**C_FIFO_SIZE-1, // Full assert threshold value

  parameter integer C_READ_MODE            = 0, // 0: No FWFT, 1: FWFT, 2: Low Latency Sync with reg output.
  parameter integer C_FIFO_READ_LATENCY    = 0, // Read latency passed to xpm primitive, Distributed Memory can be 0 or great Block Memory must be 1 or greater
  parameter         C_DOUT_RESET_VALUE     = "0",
  parameter integer C_CDC_DEST_SYNC_FF     = 3, // Number of synchronization stages: 2+ 
  parameter integer C_FULL_RESET_VALUE     = 1, // 0: FULL is de-asserted when under reset, 1: FULL/prog_full is asserted during reset.
  parameter integer C_FLAG_PROTECTION      = 1, // 0: No Protection, 1: write overflow and read underflow 2: write overflow 3: read underflow
  parameter integer C_SIM_ASSERT_CHK       = 1  // Not implemented!
)
(
  // Write clock domain
  input  wire                    wr_clk,
  input  wire                    wr_rst,
  input  wire                    wr_en,
  input  wire [C_FIFO_WIDTH-1:0] din,
  output logic                   full,
  output logic                   afull,
  output logic                   prog_full,
  output logic                   overflow,

  // Read clock domain
  input  wire                    rd_clk,
  input  wire                    rd_rst,
  input  wire                    rd_en,
  output logic [C_FIFO_WIDTH-1:0]dout,
  output logic                   empty,
  output logic                   underflow
);

timeunit      1ps;
timeprecision 1ps;

// Workaround until CR 974119 resolved:
localparam integer XPM_CLK_SYNC = 0; 
localparam integer XPM_CLK_ASYNC = 1;
localparam integer XPM_FIFO_DISTRIBUTED = 1; 
localparam integer XPM_FIFO_BLOCK = 2; 
localparam integer XPM_FIFO_ULTRA = 3; 
localparam integer XPM_FIFO_BUILTIN = 4;

// Shelved until CR 974119 resolved:
// typedef enum { XPM_CLK_SYNC = 0, XPM_CLK_ASYNC = 1} e_xpm_clocking_mode;
// typedef enum { XPM_FIFO_DISTRIBUTED = 1, XPM_FIFO_BLOCK = 2, XPM_FIFO_ULTRA = 3, XPM_FIFO_BUILTIN = 4} e_xpm_fifo_memory_type;

// typedef enum { XPM_FIFO_READ_MODE_STD = 0, XPM_FIFO_READ_MODE_FWFT = 1 } e_xpm_fifo_read_mode;

localparam         LP_ECC_MODE          =  "no_ecc";
localparam         LP_FIFO_MEMORY_TYPE  =  (C_FIFO_MEMORY_TYPE == 0) ? "distributed" : "block";
localparam integer LP_FIFO_DEPTH        =  2**C_FIFO_SIZE;
localparam integer LP_PROG_EMPTY_THRESH =  5;
localparam integer LP_PROG_FULL_MIN     =  3+(C_READ_MODE*2)+C_CDC_DEST_SYNC_FF;
localparam integer LP_PROG_FULL_MAX     =  (LP_FIFO_DEPTH-3)-(C_READ_MODE*2);
localparam integer LP_PROG_FULL_THRESH  =  (C_PROG_FULL_THRESH > LP_PROG_FULL_MAX) ? LP_PROG_FULL_MAX :
                                             (C_PROG_FULL_THRESH < LP_PROG_FULL_MIN) ? LP_PROG_FULL_MIN : C_PROG_FULL_THRESH ;
localparam         LP_READ_MODE         =  (C_READ_MODE == 1) ? "fwft" : "std";
localparam integer LP_RELATED_CLOCKS    = (C_ACLK_RELATIONSHIP == 0 || C_ACLK_RELATIONSHIP == 1) ? 0 : 1;
// |   Setting USE_ADV_FEATURES[0] to 1 enables overflow flag;     Default value of this bit is 1                        |
// |   Setting USE_ADV_FEATURES[1]  to 1 enables prog_full flag;    Default value of this bit is 1                       |
// |   Setting USE_ADV_FEATURES[2]  to 1 enables wr_data_count;     Default value of this bit is 1                       |
// |   Setting USE_ADV_FEATURES[3]  to 1 enables almost_full flag;  Default value of this bit is 0                       |
// |   Setting USE_ADV_FEATURES[4]  to 1 enables wr_ack flag;       Default value of this bit is 0                       |
// |   Setting USE_ADV_FEATURES[8]  to 1 enables underflow flag;    Default value of this bit is 1                       |
// |   Setting USE_ADV_FEATURES[9]  to 1 enables prog_empty flag;   Default value of this bit is 1                       |
// |   Setting USE_ADV_FEATURES[10] to 1 enables rd_data_count;     Default value of this bit is 1                       |
// |   Setting USE_ADV_FEATURES[11] to 1 enables almost_empty flag; Default value of this bit is 0                       |
// |   Setting USE_ADV_FEATURES[12] to 1 enables data_valid flag;   Default value of this bit is 0                       |
localparam         LP_USE_ADV_FEATURES  = "030B";


localparam integer LP_COMMON_CLOCK                = (C_ACLK_RELATIONSHIP == 1) ? 1 : 0;


localparam integer LP_REMOVE_WR_RD_PROT_LOGIC = C_FLAG_PROTECTION ? 0 : 1;

localparam integer LP_WAKEUP_TIME                 = 0;
localparam integer LP_VERSION                     = 0;

logic                  sleep = 1'b0;
wire                   prog_full_i;
wire                   afull_i;
wire                   full_i;
wire [C_FIFO_SIZE-1:0] wr_data_count;
wire                   wr_rst_busy;

wire                   prog_empty;
wire [C_FIFO_SIZE-1:0] rd_data_count;
wire                   rd_rst_busy;

logic                  injectsbiterr = 1'b0;
logic                  injectdbiterr = 1'b0;
wire                   sbiterr;
wire                   dbiterr;

assign prog_full = C_PROG_FULL_THRESH < LP_PROG_FULL_MIN  || (C_FULL_RESET_VALUE == 0 && wr_rst_busy) ? 1'b1 : prog_full_i;
assign afull = C_FULL_RESET_VALUE == 0 && wr_rst_busy ? 1'b1 : afull_i; 
assign full = C_FULL_RESET_VALUE == 0 && wr_rst_busy ? 1'b1 : full_i; 


  // Based on 2018.3 template
  xpm_fifo_sync #(
    .DOUT_RESET_VALUE    ( C_DOUT_RESET_VALUE   ) , // Not sized.
    .ECC_MODE            ( LP_ECC_MODE          ) ,
    .FIFO_MEMORY_TYPE    ( LP_FIFO_MEMORY_TYPE  ) ,
    .FIFO_READ_LATENCY   ( C_FIFO_READ_LATENCY  ) ,
    .FIFO_WRITE_DEPTH    ( LP_FIFO_DEPTH        ) ,
    .FULL_RESET_VALUE    ( C_FULL_RESET_VALUE   ) ,
    .PROG_EMPTY_THRESH   ( LP_PROG_EMPTY_THRESH ) , // not used
    .PROG_FULL_THRESH    ( LP_PROG_FULL_THRESH  ) ,
    .RD_DATA_COUNT_WIDTH ( C_FIFO_SIZE          ) ,
    .READ_DATA_WIDTH     ( C_FIFO_WIDTH         ) ,
    .READ_MODE           ( LP_READ_MODE         ) ,
    .USE_ADV_FEATURES    ( LP_USE_ADV_FEATURES  ) ,
    .WAKEUP_TIME         ( LP_WAKEUP_TIME       ) ,
    .WRITE_DATA_WIDTH    ( C_FIFO_WIDTH         ) ,
    .WR_DATA_COUNT_WIDTH ( C_FIFO_SIZE          ) 
  ) inst_xpm_fifo_sync (
    // .Portname   ( wirename      ) , // Direction , Size                , Domain , Sense       , Handlingifunused
    .wr_clk        ( wr_clk        ) , // Input     , 1                   , NA     , Risingedge  , Required
    .rst           ( wr_rst        ) , // Input     , 1                   , wr_clk , Active-high , Required
    .wr_rst_busy   ( wr_rst_busy   ) , // Output    , 1                   , wr_clk , Active-high , Required
    .wr_en         ( wr_en         ) , // Input     , 1                   , wr_clk , Active-high , Required
    .din           ( din           ) , // Input     , WRITE_DATA_WIDTH    , wr_clk , NA          , Required
    .full          ( full_i        ) , // Output    , 1                   , wr_clk , Active-high , Required
    .almost_full   ( afull_i       ) , // Output    , 1                   , wr_clk , Active-high , DoNotCare
    .prog_full     ( prog_full_i   ) , // Output    , 1                   , wr_clk , Active-high , DoNotCare
    .overflow      ( overflow      ) , // Output    , 1                   , wr_clk , Active-high , DoNotCare
    .wr_ack        (               ) , // Output    , 1                   , wr_clk , Active-high , DoNotCare
    .wr_data_count ( wr_data_count ) , // Output    , WR_DATA_COUNT_WIDTH , wr_clk , NA          , DoNotCare
    .injectsbiterr ( injectsbiterr ) , // Input     , 1                   , wr_clk , Active-high , Tieto1'b0
    .injectdbiterr ( injectdbiterr ) , // Input     , 1                   , wr_clk , Active-high , Tieto1'b0

    .rd_rst_busy   ( rd_rst_busy   ) , // Output    , 1                   , wr_clk , Active-high , Required
    .data_valid    (               ) , // Output    , 1                   , wr_clk , Active-high , DoNotCare
    .dout          ( dout          ) , // Output    , READ_DATA_WIDTH     , wr_clk , NA          , Required
    .empty         ( empty         ) , // Output    , 1                   , wr_clk , Active-high , Required
    .almost_empty  (               ) , // Output    , 1                   , wr_clk , Active-high , DoNotCare
    .prog_empty    ( prog_empty    ) , // Output    , 1                   , wr_clk , Active-high , DoNotCare
    .rd_data_count ( rd_data_count ) , // Output    , RD_DATA_COUNT_WIDTH , wr_clk , NA          , DoNotCare
    .rd_en         ( rd_en         ) , // Input     , 1                   , wr_clk , Active-high , Required
    .underflow     ( underflow     ) , // Output    , 1                   , wr_clk , Active-high , DoNotCare
    .sbiterr       ( sbiterr       ) , // Output    , 1                   , wr_clk , Active-high , DoNotCare
    .dbiterr       ( dbiterr       ) , // Output    , 1                   , wr_clk , Active-high , DoNotCare
    .sleep         ( sleep         )   // Input     , 1                   , N:A    , Active-high , Tieto1'b0
  );

endmodule : axi_qdriip_bridge_v1_0_0_xpm_fifo_wrapper

`default_nettype wire


/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//-----------------------------------------------------------------------------
//
// Description: axi_qdriip_bridge
//
// Verilog-standard:  Verilog 2001
//
//--------------------------------------------------------------------------
`timescale 1ps/1ps
`default_nettype none

(* DowngradeIPIdentifiedWarnings="yes" *) 
module axi_qdriip_bridge_v1_0_0_top #
  (
   parameter         C_FAMILY                          = "virtex7", 
                       // FPGA Family.
   parameter integer C_S_AXI_ID_WIDTH                  = 1, 
                       // Width of all ID signals on SI side of converter.
                       // Range: 1 - 32.
   //parameter integer C_S_AXI_ADDR_WIDTH                = 23, 
   parameter integer C_S_AXI_ADDR_WIDTH                = 32, 
   parameter integer C_S_AXI_DATA_WIDTH                = 64,
   parameter integer C_QDRIIP_ADDR_WIDTH               = 22,
   parameter integer C_QDRIIP_DATA_WIDTH               = 72
   )
  (
   // Global Signals
   (* KEEP = "TRUE" *) input  wire        s_axi_aclk,
   (* KEEP = "TRUE" *) input  wire        s_axi_aresetn,

   // Slave Interface Write Address Ports
   input  wire [C_S_AXI_ID_WIDTH-1:0]       s_axi_awid,
   input  wire [C_S_AXI_ADDR_WIDTH-1:0]     s_axi_awaddr,
   input  wire [8-1:0] s_axi_awlen,
   input  wire                              s_axi_awvalid,
   output wire                              s_axi_awready,
   // Slave Interface Write Data Ports
   input  wire [C_S_AXI_DATA_WIDTH-1:0]     s_axi_wdata,
   input  wire [C_S_AXI_DATA_WIDTH/8-1:0]   s_axi_wstrb,
   input  wire                              s_axi_wlast,
   input  wire                              s_axi_wvalid,
   output wire                              s_axi_wready,
   // Slave Interface Write Response Ports
   output wire [C_S_AXI_ID_WIDTH-1:0]       s_axi_bid,
   output wire [2-1:0]                      s_axi_bresp,
   output wire                              s_axi_bvalid,
   input  wire                              s_axi_bready,
   // Slave Interface Read Address Ports
   input  wire [C_S_AXI_ID_WIDTH-1:0]       s_axi_arid,
   input  wire [C_S_AXI_ADDR_WIDTH-1:0]     s_axi_araddr,
   input  wire [8-1:0] s_axi_arlen,
   input  wire                              s_axi_arvalid,
   output wire                              s_axi_arready,
   // Slave Interface Read Data Ports
   output wire [C_S_AXI_ID_WIDTH-1:0]       s_axi_rid,
   output wire [C_S_AXI_DATA_WIDTH-1:0]     s_axi_rdata,
   output wire [2-1:0]                      s_axi_rresp,
   output wire                              s_axi_rlast,
   output wire                              s_axi_rvalid,
   input  wire                              s_axi_rready,

  /////////////////////////////////////////////////////////////////////////////
  //APP interface to QDRIIP
//  input  wire                               init_calib_complete,
  output wire                               qdriip_app_wr_cmd,
  output wire [C_QDRIIP_ADDR_WIDTH - 1 : 0]                     qdriip_app_wr_addr,
  output wire [C_QDRIIP_DATA_WIDTH - 1: 0]                      qdriip_app_wr_data,
  output wire [C_QDRIIP_DATA_WIDTH/9 - 1 : 0]                   qdriip_app_wr_bw_n,
  output wire                                                   qdriip_app_rd_cmd,
  output wire [C_QDRIIP_ADDR_WIDTH - 1 : 0]                     qdriip_app_rd_addr,
  input  wire [C_QDRIIP_DATA_WIDTH - 1 : 0]                     qdriip_app_rd_data,
  input  wire                                                   qdriip_app_rd_valid,
  output wire                                                   wr_error,
  output wire                                                   rd_error
);

  wire aclk = s_axi_aclk;
  wire aresetn = s_axi_aresetn;

  wire [C_S_AXI_ADDR_WIDTH-1:0]       awaddr_i     ;
  wire [8-1:0]                      awlen_i     ;
  wire                              awvalid_i     ;
  wire                              awready_i     ;
  wire [C_S_AXI_DATA_WIDTH-1:0]         wdata_i     ;
  wire [C_S_AXI_DATA_WIDTH/8-1:0]       wstrb_i     ;
  wire                              wlast_i     ;
  wire                              wvalid_i     ;
  wire                              wready_i     ;
  wire [2-1:0]                      bresp_i     ;
  wire                              bvalid_i     ;
  wire                              bready_i     ;
  wire [C_S_AXI_ADDR_WIDTH-1:0]       araddr_i     ;
  wire [8-1:0]                      arlen_i     ;
  wire [4-1:0]                      arqos_i     ;
  wire                              arvalid_i     ;
  wire                              arready_i     ;
  wire [C_S_AXI_DATA_WIDTH-1:0]         rdata_i     ;
  wire [2-1:0]                      rresp_i     ;
  wire                              rlast_i     ;
  wire                              rvalid_i     ;
  wire                              rready_i    ;
  wire [C_S_AXI_ID_WIDTH-1:0]         awid_i     ;
  wire [C_S_AXI_ID_WIDTH-1:0]         bid_i     ;
  wire [C_S_AXI_ID_WIDTH-1:0]         arid_i     ;
  wire [C_S_AXI_ID_WIDTH-1:0]         rid_i     ;

  /////////////////////////////////////////////////////////////////////////////
  // Functions
  /////////////////////////////////////////////////////////////////////////////
  

//axi_data_fifo_v2_1_26_axi_data_fifo #(
axi_data_fifo_v2_1_27_axi_data_fifo #(
  .C_FAMILY(C_FAMILY),
  .C_AXI_PROTOCOL(0),
  .C_AXI_ID_WIDTH(C_S_AXI_ID_WIDTH),
  .C_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH),
  .C_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
  .C_AXI_SUPPORTS_USER_SIGNALS(0),
  .C_AXI_AWUSER_WIDTH(1),
  .C_AXI_ARUSER_WIDTH(1),
  .C_AXI_WUSER_WIDTH(1),
  .C_AXI_RUSER_WIDTH(1),
  .C_AXI_BUSER_WIDTH(1),
  .C_AXI_WRITE_FIFO_DEPTH(0),
  .C_AXI_WRITE_FIFO_TYPE("lut"),
  .C_AXI_WRITE_FIFO_DELAY(0),
  .C_AXI_READ_FIFO_DEPTH(512),
  .C_AXI_READ_FIFO_TYPE("bram"),
  .C_AXI_READ_FIFO_DELAY(1)
)
SI_FIFO
(
    .aresetn                    ( aresetn       ) ,
    .aclk                       ( aclk          ) ,
    .s_axi_awid                 ( s_axi_awid    ) ,
    .s_axi_awaddr               ( s_axi_awaddr  ) ,
    .s_axi_awlen                ( s_axi_awlen   ) ,
    .s_axi_awsize               ( 3'h0 ) , //CONST
    .s_axi_awburst              ( 2'h0 ) , //CONST
    .s_axi_awlock               ( 1'h0 ) , //CONST
    .s_axi_awcache              ( 4'h0 ) , //CONST
    .s_axi_awprot               ( 3'h0 ) , //CONST
    .s_axi_awregion             ( 4'h0 ) , //CONST
    .s_axi_awqos                ( 4'h0 ) , //CONST
    .s_axi_awvalid              ( s_axi_awvalid ) ,
    .s_axi_awready              ( s_axi_awready ) ,
    .s_axi_wdata                ( s_axi_wdata   ) ,
    .s_axi_wstrb                ( s_axi_wstrb   ) ,
    .s_axi_wlast                ( s_axi_wlast   ) ,
    .s_axi_wvalid               ( s_axi_wvalid  ) ,
    .s_axi_wready               ( s_axi_wready  ) ,
    .s_axi_wid                  ( {C_S_AXI_ID_WIDTH{1'b0}}     ) ,
    .s_axi_bid                  ( s_axi_bid     ) ,
    .s_axi_bresp                ( s_axi_bresp   ) ,
    .s_axi_bvalid               ( s_axi_bvalid  ) ,
    .s_axi_bready               ( s_axi_bready  ) ,
    .s_axi_arid                 ( s_axi_arid    ) ,
    .s_axi_araddr               ( s_axi_araddr  ) ,
    .s_axi_arlen                ( s_axi_arlen   ) ,
    .s_axi_arsize               ( 3'h0 ) , //CONST
    .s_axi_arburst              ( 2'h0 ) , //CONST
    .s_axi_arlock               ( 1'h0 ) , //CONST
    .s_axi_arcache              ( 4'h0 ) , //CONST
    .s_axi_arprot               ( 3'h0 ) , //CONST
    .s_axi_arregion             ( 4'h0 ) , //CONST
    .s_axi_arqos                ( 4'h0 ) , //CONST
    .s_axi_arvalid              ( s_axi_arvalid ) ,
    .s_axi_arready              ( s_axi_arready ) ,
    .s_axi_rid                  ( s_axi_rid     ) ,
    .s_axi_rdata                ( s_axi_rdata   ) ,
    .s_axi_rresp                ( s_axi_rresp   ) ,
    .s_axi_rlast                ( s_axi_rlast   ) ,
    .s_axi_rvalid               ( s_axi_rvalid  ) ,
    .s_axi_rready               ( s_axi_rready  ) ,
    .s_axi_awuser               ( 1'h0 ) , //CONST
    .s_axi_wuser                ( 1'h0 ) , //CONST
    .s_axi_buser                (  ) , //CONST
    .s_axi_aruser               ( 1'h0 ) , //CONST
    .s_axi_ruser                (  ) , //CONST
    .m_axi_awuser               (  ) , //CONST
    .m_axi_wuser                (  ) , //CONST
    .m_axi_buser                ( 1'h0 ) , //CONST
    .m_axi_aruser               (  ) , //CONST
    .m_axi_ruser                ( 1'h0 ) , //CONST

    .m_axi_awaddr               ( awaddr_i      ) ,
    .m_axi_awlen                ( awlen_i       ) ,
    .m_axi_awid                 ( awid_i        ) ,
    .m_axi_awsize               ( ) ,
    .m_axi_awburst              ( ) ,
    .m_axi_awlock               ( ) ,
    .m_axi_awcache              ( ) ,
    .m_axi_awprot               ( ) ,
    .m_axi_awregion             ( ) ,
    .m_axi_awqos                ( ) ,
    .m_axi_awvalid              ( awvalid_i     ) ,
    .m_axi_awready              ( awready_i     ) ,
    .m_axi_wdata                ( wdata_i       ) ,
    .m_axi_wstrb                ( wstrb_i       ) ,
    .m_axi_wlast                ( wlast_i       ) ,
    .m_axi_wvalid               ( wvalid_i      ) ,
    .m_axi_wid                  (               ) ,
    .m_axi_wready               ( wready_i      ) ,
    .m_axi_bresp                ( bresp_i       ) ,
    .m_axi_bvalid               ( bvalid_i      ) ,
    .m_axi_bready               ( bready_i      ) ,
    .m_axi_bid                  ( bid_i         ) ,
    .m_axi_araddr               ( araddr_i      ) ,
    .m_axi_arlen                ( arlen_i       ) ,
    .m_axi_arid                 ( arid_i        ) ,
    .m_axi_arsize               ( ) ,
    .m_axi_arburst              ( ) ,
    .m_axi_arlock               ( ) ,
    .m_axi_arcache              ( ) ,
    .m_axi_arprot               ( ) ,
    .m_axi_arregion             ( ) ,
    .m_axi_arqos                ( ) ,
    .m_axi_arvalid              ( arvalid_i     ) ,
    .m_axi_arready              ( arready_i     ) ,
    .m_axi_rid                  ( rid_i         ) ,
    .m_axi_rdata                ( rdata_i       ) ,
    .m_axi_rresp                ( rresp_i       ) ,
    .m_axi_rlast                ( rlast_i       ) ,
    .m_axi_rvalid               ( rvalid_i      ) ,
    .m_axi_rready               ( rready_i      ) 
    );



axi_qdriip_bridge_v1_0_0_rd_controller #(
   .C_S_AXI_ID_WIDTH     ( C_S_AXI_ID_WIDTH   ),
   .C_S_AXI_ADDR_WIDTH   ( C_S_AXI_ADDR_WIDTH ), 
   .C_S_AXI_DATA_WIDTH   ( C_S_AXI_DATA_WIDTH ),
   .C_QDRIIP_ADDR_WIDTH  ( C_QDRIIP_ADDR_WIDTH),
   .C_QDRIIP_DATA_WIDTH  ( C_QDRIIP_DATA_WIDTH)
   ) RD (
  .s_axi_aclk           ( s_axi_aclk    ),
  .s_axi_aresetn        ( s_axi_aresetn ),
  .s_axi_arid           ( arid_i        ),
  .s_axi_araddr         ( araddr_i      ),
  .s_axi_arlen          ( arlen_i       ),
  .s_axi_arvalid        ( arvalid_i     ),
  .s_axi_arready        ( arready_i     ),
  .s_axi_rid            ( rid_i         ),
  .s_axi_rdata          ( rdata_i       ),
  .s_axi_rresp          ( rresp_i       ),
  .s_axi_rlast          ( rlast_i       ),
  .s_axi_rvalid         ( rvalid_i      ),
  .s_axi_rready         ( rready_i      ),
  .qdriip_app_rd_cmd    ( qdriip_app_rd_cmd   ),
  .qdriip_app_rd_addr   ( qdriip_app_rd_addr  ),
  .qdriip_app_rd_data   ( qdriip_app_rd_data  ),
  .qdriip_app_rd_valid  ( qdriip_app_rd_valid ),
  .rd_error             ( rd_error )
);

axi_qdriip_bridge_v1_0_0_wr_controller #(
   .C_S_AXI_ID_WIDTH     ( C_S_AXI_ID_WIDTH   ),
   .C_S_AXI_ADDR_WIDTH   ( C_S_AXI_ADDR_WIDTH ), 
   .C_S_AXI_DATA_WIDTH   ( C_S_AXI_DATA_WIDTH ),
   .C_QDRIIP_ADDR_WIDTH  ( C_QDRIIP_ADDR_WIDTH),
   .C_QDRIIP_DATA_WIDTH  ( C_QDRIIP_DATA_WIDTH)
   ) WR (
  .s_axi_aclk           ( s_axi_aclk    ),
  .s_axi_aresetn        ( s_axi_aresetn ),
  .s_axi_awid           ( awid_i        ),
  .s_axi_awaddr         ( awaddr_i      ),
  .s_axi_awlen          ( awlen_i       ),
  .s_axi_awvalid        ( awvalid_i     ),
  .s_axi_awready        ( awready_i     ),
  .s_axi_bid            ( bid_i         ),
  .s_axi_bresp          ( bresp_i       ),
  .s_axi_bvalid         ( bvalid_i      ),
  .s_axi_bready         ( bready_i      ),
  .s_axi_wdata          ( wdata_i       ),
  .s_axi_wstrb          ( wstrb_i       ),
  .s_axi_wlast          ( wlast_i       ),
  .s_axi_wvalid         ( wvalid_i      ),
  .s_axi_wready         ( wready_i      ),
  .qdriip_app_wr_cmd    ( qdriip_app_wr_cmd   ),
  .qdriip_app_wr_addr   ( qdriip_app_wr_addr  ),
  .qdriip_app_wr_data   ( qdriip_app_wr_data  ),
  .qdriip_app_wr_bw_n   ( qdriip_app_wr_bw_n  ),
  .wr_error             ( wr_error )
  );


endmodule
`default_nettype wire




/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//------------------------------------------------------------------------------
//
//  Description: A simple non-bursting AXI master
//
//               Once 'start' signal is asserted high, it sends a number of AXI
//               writes then sends the same number of AXI reads to the same
//               addresses
//
//               The return data is validated by checking against
//               the same set of data that was written on the memory
//
//               'done' is asserted when the writes and reads are finished.
//
//------------------------------------------------------------------------------

module simple_axi_master #(
  parameter AXI_ADDR_WIDTH = 32,
  parameter AXI_DATA_WIDTH = 64,
  parameter NUM_WRITES = 100,
  localparam ERROR_CNT_SIZE = $clog2(NUM_WRITES)
)(
  // Clock/Reset
  input  logic                      clk,
  input  logic                      rst_n,

  // Control/Status Signals
  input  logic                      start,
  output logic                      done,
  output logic [ERROR_CNT_SIZE-1:0] error_counter,

  // AXI Address Write Channel
  output logic [AXI_ADDR_WIDTH-1:0] m_axi_awaddr,
  output logic [7:0]                m_axi_awlen,
  output logic                      m_axi_awvalid,
  input  logic                      m_axi_awready,

  // AXI Write Data Channel
  output logic                      m_axi_wlast,
  output logic [AXI_DATA_WIDTH-1:0] m_axi_wdata,
  output logic [7:0]                m_axi_wstrb,
  output logic                      m_axi_wvalid,
  input  logic                      m_axi_wready,

  // AXI Write Response Channel
  input  logic [1:0]                m_axi_bresp,
  input  logic                      m_axi_bvalid,
  output logic                      m_axi_bready,

  // AXI Address Read Channel
  output logic [AXI_ADDR_WIDTH-1:0] m_axi_araddr,
  output logic [7:0]                m_axi_arlen,
  output logic                      m_axi_arvalid,
  input  logic                      m_axi_arready,

  // AXI Read Data Channel
  input  logic [AXI_DATA_WIDTH-1:0] m_axi_rdata,
  input  logic [1:0]                m_axi_rresp,
  input  logic                      m_axi_rvalid,
  input  logic                      m_axi_rlast,
  output logic                      m_axi_rready
);
  //============//
  // Parameters //
  //============//

  localparam COUNTER_SIZE = $clog2(NUM_WRITES);
  localparam QDRIIP_DATA_WIDTH = 18;
  localparam QDRIIP_BURST_LENGTH = 4;
  localparam AXI_ADDR_CONST = (AXI_DATA_WIDTH / 8);

  //====================//
  // Signal Declaration //
  //====================//

  typedef enum logic [1:0] {IDLE, WRITE, READ, DONE} state_t;

  state_t curr_state, next_state; // State registers

  logic start_r0; // Start signal register

  logic [COUNTER_SIZE:0] write_counter;
  logic [COUNTER_SIZE:0] read_counter;

  //===========//
  // AXI Write //
  //===========//

  // AXI AW & W channel handshake logic
  // Note: The bus will hang if there is no write response from the slave
  always_ff @(posedge clk) begin : axi_write
    if (!rst_n) begin
      m_axi_awvalid <= 0;
      m_axi_wvalid <= 0;
    end else begin
      if (curr_state == IDLE && next_state == WRITE) begin
        m_axi_awvalid <= 1;
        m_axi_wvalid <= 1;
      end else if (curr_state == WRITE) begin
        if (m_axi_awready && m_axi_awvalid) begin
          m_axi_awvalid <= 0;
        end else if (m_axi_wready && m_axi_wvalid) begin
          m_axi_wvalid <= 0;
        end else if (m_axi_bvalid && m_axi_bready) begin
          m_axi_awvalid <= 1;
          m_axi_wvalid <= 1;
        end
      end else begin
        m_axi_awvalid <= 0;
        m_axi_wvalid <= 0;
      end
    end
  end

  // AXI write address and data Logic
  always_ff @(posedge clk) begin
    if (!rst_n) begin
      m_axi_awaddr <= 0;
      m_axi_wdata <= 0;
    end else begin
      if (m_axi_awvalid && m_axi_awready) begin
        m_axi_awaddr <= m_axi_awaddr + AXI_ADDR_CONST;
      end

      if (m_axi_wvalid && m_axi_wready) begin
        m_axi_wdata <= m_axi_wdata + ~AXI_ADDR_CONST;
      end
    end
  end

  // Write counter increment logic
  always_ff @(posedge clk) begin
    if (!rst_n) begin
      write_counter <= 0;
    end else if (m_axi_wvalid && m_axi_wready) begin
      write_counter <= write_counter + 1;

      assert (write_counter <= NUM_WRITES)
        else $error("write_counter overflow");
    end
  end

  //==========//
  // AXI Read //
  //==========//

  // AXI read signaling
  always_ff @(posedge clk) begin
    if (!rst_n) begin
      m_axi_arvalid <= 0;
    end else begin
      if (curr_state == WRITE && next_state == READ) begin
        m_axi_arvalid <= 1; // Assert for the beginning of READ state
      end else if (curr_state == READ) begin
        if (m_axi_arvalid && m_axi_arready) begin
          m_axi_arvalid <= 0; // Deassert after handshake
        end else if (m_axi_rvalid && m_axi_rready && 
                     read_counter < NUM_WRITES-1) begin
          m_axi_arvalid <= 1; // Reassert after read data is received
        end
      end
    end
  end

  // Increments the read counter and the read address when the
  // master recevies a read data back
  always_ff @(posedge clk) begin
    if (!rst_n) begin
      read_counter <= 0;
      m_axi_araddr <= 0;
    end else if (curr_state == READ && m_axi_rvalid && m_axi_rready) begin
      read_counter <= read_counter + 1;

      assert (read_counter <= NUM_WRITES)
        else $error("read_counter overflow!");
      
      m_axi_araddr <= m_axi_araddr + AXI_ADDR_CONST;
    end
  end

  logic [AXI_DATA_WIDTH-1:0] expected_data;

  // Expected data generation and check
  always_ff @(posedge clk) begin
    if (!rst_n) begin
      expected_data <= 0;
      error_counter <= 0;
    end else begin
      if (m_axi_rvalid && m_axi_rready) begin
        expected_data <= expected_data + ~AXI_ADDR_CONST;
        
        if (expected_data != m_axi_rdata) begin
          error_counter <= error_counter + 1;
        end
                
        assert (expected_data == m_axi_rdata) $display("Read data correct");
          else $error("Read data incorrect");

      end
    end
  end

  // Registers the incoming start signal
  always_ff @(posedge clk) begin
    if (!rst_n) begin
      start_r0 <= 0;
    end else begin
      start_r0 <= start;
    end
  end

  // Signals done
  always_ff @(posedge clk) begin
    if (!rst_n) begin
      done <= 0;
    end else if (curr_state == DONE) begin
      done <= 1;
    end else begin
      done <= 0;
    end
  end

  // State transition register
  always_ff @(posedge clk) begin
    if (!rst_n) begin
      curr_state <= IDLE;
    end else begin
      curr_state <= next_state;
    end
  end

  // State transision logic
  always_comb begin
    case (curr_state)
      IDLE : begin
        if (start_r0) begin
          next_state = WRITE;
        end else begin
          next_state = IDLE;
        end
      end 
      WRITE : begin
        if (write_counter == NUM_WRITES) begin
          next_state = READ;
        end else begin
          next_state = WRITE;
        end
      end
      READ : begin
        if (read_counter == NUM_WRITES) begin
          next_state = DONE;
        end else begin
          next_state = READ;
        end
      end
      DONE : begin
        next_state = DONE;
      end
      default : next_state = IDLE;
    endcase
  end

  // Constant AXI signals
  always_comb begin
    m_axi_awlen = 0; // Burst length: 1
    m_axi_wlast = 1;
    m_axi_wstrb = '1;
    m_axi_rready = 1;
    m_axi_arlen = 0; // Burst length: 1
    m_axi_bready = 1;
  end

endmodule : simple_axi_master
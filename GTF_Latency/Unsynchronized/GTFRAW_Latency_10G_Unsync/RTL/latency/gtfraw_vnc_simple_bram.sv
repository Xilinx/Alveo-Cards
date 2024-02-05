/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//------------------------------------------------------------------------------

module gtfraw_vnc_simple_bram # (
    parameter  RAM_WIDTH   = 74,
    parameter  RAM_DEPTH   = 512,
    parameter  ADDR_WIDTH  = 9
) (

    input   wire                    in_clk,
    input   wire                    out_clk,

    input   wire                    ena,
    input   wire                    wea,
    input   wire [ADDR_WIDTH-1:0]   wr_addr,
    input   wire [RAM_WIDTH-1:0]    dina,

    input   wire                    enb,
    input   wire [ADDR_WIDTH-1:0]   rd_addr,
    output  reg  [RAM_WIDTH-1:0]    doutb

);

    (* ram_style = "block" *) reg  [RAM_WIDTH-1:0] ram [RAM_DEPTH-1:0];

    // Infer BRAM - simple dual port
    always @ (posedge in_clk) begin

        if (ena) begin
            if (wea) begin
                ram[wr_addr] <= dina;
            end
        end

    end

    always @ (posedge out_clk) begin

        if (enb) begin
            doutb   <= ram[rd_addr];
        end

    end

endmodule

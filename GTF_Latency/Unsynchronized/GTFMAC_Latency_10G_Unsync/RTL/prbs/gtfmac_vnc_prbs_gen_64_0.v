/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//------------------------------------------------------------------------------

module gtfmac_vnc_prbs_gen_64_0 (
  input  wire        rst      ,
  input  wire        clk      ,
  input  wire        en       ,
  output wire [63:0] prbs_out
);

wire        wea   = 'h0;
wire [15:0] dina  = 'h0;
reg  [9:0]  addra_0 ;
reg  [9:0]  addra_1 ;
reg  [9:0]  addra_2 ;
reg  [9:0]  addra_3 ;
wire [63:0] douta ;

//initial addra = 'h0;
always@(posedge clk)
    if (rst)                 addra_0 <= 'h0;
    else if (en) 
    begin
        if (addra_0 == 'h7f) addra_0 <= 'h0;
        else                 addra_0 <= addra_0 + 1;
    end
always@(posedge clk)
    if (rst)                 addra_1 <= 'h0;
    else if (en) 
    begin
        if (addra_1 == 'h7f) addra_1 <= 'h0;
        else                 addra_1 <= addra_1 + 1;
    end
always@(posedge clk)
    if (rst)                 addra_2 <= 'h0;
    else if (en) 
    begin
        if (addra_2 == 'h7f) addra_2 <= 'h0;
        else                 addra_2 <= addra_2 + 1;
    end
always@(posedge clk)
    if (rst)                 addra_3 <= 'h0;
    else if (en) 
    begin
        if (addra_3 == 'h7f) addra_3 <= 'h0;
        else                 addra_3 <= addra_3 + 1;
    end

wire [9:0] addr_0_nxt = (en ? addra_0 + 1 : addra_0) + 'h000;
wire [9:0] addr_1_nxt = (en ? addra_1 + 1 : addra_1) + 'h080;
wire [9:0] addr_2_nxt = (en ? addra_2 + 1 : addra_2) + 'h100;
wire [9:0] addr_3_nxt = (en ? addra_3 + 1 : addra_3) + 'h180;


blk_mem_gen_prbs blk_mem_gen_0 (
    .clka  ( clk          ),
    .ena   ( 'h1          ),
    .wea   ( 'h0          ),
    .dina  ( 'h0          ),
    .addra ( addr_0_nxt   ),
    .douta ( douta[15:0]  )
);

blk_mem_gen_prbs blk_mem_gen_1 (
    .clka  ( clk          ),
    .ena   ( 'h1          ),
    .wea   ( 'h0          ),
    .dina  ( 'h0          ),
    .addra ( addr_1_nxt   ),
    .douta ( douta[31:16] )
);

blk_mem_gen_prbs blk_mem_gen_2 (
    .clka  ( clk          ),
    .ena   ( 'h1          ),
    .wea   ( 'h0          ),
    .dina  ( 'h0          ),
    .addra ( addr_2_nxt   ),
    .douta ( douta[47:32] )
);

blk_mem_gen_prbs blk_mem_gen_3 (
    .clka  ( clk          ),
    .ena   ( 'h1          ),
    .wea   ( 'h0          ),
    .dina  ( 'h0          ),
    .addra ( addr_3_nxt   ),
    .douta ( douta[63:48] )
);

reg [63:0] douta_0;
always@(posedge clk)
    if (rst)     
        douta_0 <= 'h0;
    else if (en) 
        douta_0 <= douta; 


assign prbs_out = douta_0;

endmodule


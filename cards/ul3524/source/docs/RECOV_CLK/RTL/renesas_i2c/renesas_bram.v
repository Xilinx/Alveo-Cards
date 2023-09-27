/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

/*
create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name blk_mem_gen_0
set_property -dict [list \
  CONFIG.Interface_Type {Native} \
  CONFIG.Enable_A {Always_Enabled} \
  CONFIG.Enable_B {Always_Enabled} \
  CONFIG.Memory_Type {True_Dual_Port_RAM} \
  CONFIG.Write_Width_A {32} \
  CONFIG.Write_Depth_A {16384} \
  CONFIG.Write_Width_B {8} \
] [get_ips blk_mem_gen_0]


create_ip -name axi_bram_ctrl -vendor xilinx.com -library ip -version 4.1 -module_name axi_bram_ctrl_0
set_property -dict [list \
  CONFIG.MEM_DEPTH {16384} \
  CONFIG.PROTOCOL {AXI4LITE} \
  CONFIG.SINGLE_PORT_BRAM {1} \
] [get_ips axi_bram_ctrl_0]
*/

 
module renesas_bram (
    // System Interface
    input  wire        sys_if_clk    ,   
    input  wire        sys_if_rstn   ,
    input  wire        sys_if_wen    ,    
    input  wire [31:0] sys_if_addr   ,   
    input  wire [31:0] sys_if_wdata  ,  
    output wire [31:0] sys_if_rdata  , 

    input  wire        i2c_clkb      ,
    input  wire        i2c_web       ,
    input  wire [15:0] i2c_addrb     ,
    input  wire [15:0] i2c_dinb      ,
    output wire [15:0] i2c_doutb     
);

// True Dual Port RAM
// Port A - 32 bit data, 16384 deep, 14 bit addr
// Port A -  8 bit data, 16384x4 deep, 16 bit addr
reg [3:0] crap = 0;
always@(posedge i2c_clkb)
    crap <= crap + 1;
    
blk_mem_gen_0 blk_mem_gen_0 (
    .clka   ( sys_if_clk        ),
    .wea    ( sys_if_wen        ),
    .addra  ( sys_if_addr[15:2] ),
    .dina   ( sys_if_wdata      ),
    .douta  ( sys_if_rdata      ),

    .clkb   ( i2c_clkb          ),
    .web    ( i2c_web           ),
    .addrb  ( {i2c_addrb, 1'b0}         ),
    .dinb   ( i2c_dinb          ),
    .doutb  ( i2c_doutb         )
);


endmodule



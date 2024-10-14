/*
Copyright (C) 2024, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: X11
*/

initial
begin
    @(posedge jtag_axil_aresetn);
    repeat (300) @(posedge jtag_axil_aclk);

    #11ms;
    $display("#");
    $display("# Test Completed");
    $display("#");    
    $finish();
end


reg [7:0] gpio_pwr_r;
always@(posedge refclk_300)
begin
    if ( !refclk_300_rst ) begin
        if ( gpio_pwr_r != gpio_pwr ) begin
            $display("[INFO] QSPF Power Enable Setting Changed... %0t", $time);
            $display("[INFO]     Port 0 = %0d", gpio_pwr[1]);
            $display("[INFO]     Port 1 = %0d", gpio_pwr[3]);
            $display("[INFO]     Port 2 = %0d", gpio_pwr[5]);
            $display("[INFO]     Port 3 = %0d", gpio_pwr[7]);
            $display("");
        end    
    end
    gpio_pwr_r <= gpio_pwr;
end

reg [7:0] gpio_sw0_r;
always@(posedge refclk_300)
begin
    if ( !refclk_300_rst ) begin
        if ( gpio_sw0_r != gpio_sw0 ) begin
            $display("[INFO] QSFP I2C Mux 0 Selection Changed... %0t", $time);
            if      ( gpio_sw0 == 'h1)  $display("[INFO]     Port 0 Side Band Selected");
            else if ( gpio_sw0 == 'h2)  $display("[INFO]     Port 0 Module I2C Selected");
            else if ( gpio_sw0 == 'h4)  $display("[INFO]     Port 1 Side Band Selected");
            else if ( gpio_sw0 == 'h8)  $display("[INFO]     Port 1 Module I2C Selected");
            else                        $display("[INFO]     Port 0 and 1 Deselected");
            $display("");
        end    
    end
    gpio_sw0_r <= gpio_sw0;
end

//reg [7:0] gpio_sw1_r;
//always@(posedge refclk_300)
//begin
//    if ( !refclk_300_rst ) begin
//        if ( gpio_sw1_r != gpio_sw1 ) begin
//            $display("[INFO] QSFP I2C Mux 1 Selection Changed... %0t", $time);
//            if      ( gpio_sw1 == 'h1)  $display("[INFO]     Port 2 Side Band Selected");
//            else if ( gpio_sw1 == 'h2)  $display("[INFO]     Port 2 Module I2C Selected");
//            else if ( gpio_sw1 == 'h4)  $display("[INFO]     Port 3 Side Band Selected");
//            else if ( gpio_sw1 == 'h8)  $display("[INFO]     Port 3 Module I2C Selected");
//            else                        $display("[INFO]     Port 2 and 3 Deselected");
//            $display("");
//        end    
//    end
//    gpio_sw1_r <= gpio_sw1;
//end


reg [7:0] gpio_qsfp_0_r;
always@(posedge refclk_300)
begin
    if ( !refclk_300_rst ) begin
        if ( gpio_qsfp_0_r != gpio_qsfp_0 ) begin
            $display("[INFO] QSFP 0 Sideband Value Changed... %0t", $time);
            $display("[INFO]     LPMODE   = %0d", gpio_qsfp_0[0]);
            $display("[INFO]     INTL     = %0d (Input)", gpio_qsfp_0[1]);
            $display("[INFO]     MODPRSTL = %0d (Input)", gpio_qsfp_0[2]);
            $display("[INFO]     MODSELL  = %0d", gpio_qsfp_0[3]);
            $display("[INFO]     RESETL   = %0d", gpio_qsfp_0[4]);
            $display("");
        end    
    end
    gpio_qsfp_0_r <= gpio_qsfp_0;
end

reg [7:0] gpio_qsfp_1_r;
always@(posedge refclk_300)
begin
    if ( !refclk_300_rst ) begin
        if ( gpio_qsfp_1_r != gpio_qsfp_1 ) begin
            $display("[INFO] QSFP 1 Sideband Value Changed... %0t", $time);
            $display("[INFO]     LPMODE   = %0d", gpio_qsfp_1[0]);
            $display("[INFO]     INTL     = %0d (Input)", gpio_qsfp_1[1]);
            $display("[INFO]     MODPRSTL = %0d (Input)", gpio_qsfp_1[2]);
            $display("[INFO]     MODSELL  = %0d", gpio_qsfp_1[3]);
            $display("[INFO]     RESETL   = %0d", gpio_qsfp_1[4]);
            $display("");
        end    
    end
    gpio_qsfp_1_r <= gpio_qsfp_1;
end

//reg [7:0] gpio_qsfp_2_r;
//always@(posedge refclk_300)
//begin
//    if ( !refclk_300_rst ) begin
//        if ( gpio_qsfp_2_r != gpio_qsfp_2 ) begin
//            $display("[INFO] QSFP 2 Sideband Value Changed... %0t", $time);
//            $display("[INFO]     LPMODE   = %0d", gpio_qsfp_2[0]);
//            $display("[INFO]     INTL     = %0d (Input)", gpio_qsfp_2[1]);
//            $display("[INFO]     MODPRSTL = %0d (Input)", gpio_qsfp_2[2]);
//            $display("[INFO]     MODSELL  = %0d", gpio_qsfp_2[3]);
//            $display("[INFO]     RESETL   = %0d", gpio_qsfp_2[4]);
//            $display("");
//        end    
//    end
//    gpio_qsfp_2_r <= gpio_qsfp_2;
//end
//
//reg [7:0] gpio_qsfp_3_r;
//always@(posedge refclk_300)
//begin
//    if ( !refclk_300_rst ) begin
//        if ( gpio_qsfp_3_r != gpio_qsfp_3 ) begin
//            $display("[INFO] QSFP 3 Sideband Value Changed... %0t", $time);
//            $display("[INFO]     LPMODE   = %0d", gpio_qsfp_3[0]);
//            $display("[INFO]     INTL     = %0d (Input)", gpio_qsfp_3[1]);
//            $display("[INFO]     MODPRSTL = %0d (Input)", gpio_qsfp_3[2]);
//            $display("[INFO]     MODSELL  = %0d", gpio_qsfp_3[3]);
//            $display("[INFO]     RESETL   = %0d", gpio_qsfp_3[4]);
//            $display("");
//        end    
//    end
//    gpio_qsfp_3_r <= gpio_qsfp_3;
//end


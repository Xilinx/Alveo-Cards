/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//
// Renesas I2C Peripherals.
//

RC38612A002GN2 #(
    .DEVICE_ID ( 'hB0 )
) RC38612A002GN2_0 (
    .enable  ( 1'b1        ),
    .sda_io  ( CLKGEN_SDA  ),
    .scl_io  ( CLKGEN_SCL  )
);

RC38612A002GN2 #(
    .DEVICE_ID ( 'hB2 )
) RC38612A002GN2_1 (
    .enable  ( 1'b1        ),
    .sda_io  ( CLKGEN_SDA  ),
    .scl_io  ( CLKGEN_SCL  )
);


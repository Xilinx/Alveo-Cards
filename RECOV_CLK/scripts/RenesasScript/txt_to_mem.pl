#! /tools/xgs/bin/perl
#/usr/bin/perl

#
# Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: MIT
#

# Example scripts file clips....
#  Size: 0x4, Offset: FC, Data: 0x00C01020
#  Size: 0x4, Offset: FC, Data: 0x00811020
#  Size: 0x4, Offset: FC, Data: 0x00C11020
#  Size: 0xA, Offset: 60, Data: 0x00000000000000000000

#  i2cset -f -y 15 0x5b 0xfc 0x00 0xc3 0x10 0x20 i
#  i2cset -f -y 15 0x5b 0xb0 0x10 0x27 0x00 0x02 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x0a 0x01 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 i

use Switch;

undef $ifile;
undef $ofile;
undef $devid;

for($ii=0;$ii<=$#ARGV;$ii++)
{
    if    ( $ARGV[$ii] =~ /^\-i$/)  { $ifile =  $ARGV[$ii+1]; $ii++; }
    elsif ( $ARGV[$ii] =~ /^\-o$/)  { $ofile =  $ARGV[$ii+1]; $ii++; }
    elsif ( $ARGV[$ii] =~ /^\-id$/) { $devid =  $ARGV[$ii+1]; $ii++; }
    else   { printf("\nERROR: Unknown parameter : %s\n\n", $ARGV[$ii]); exit; }
}

if ( ! defined($ifile) ) { printf("\nERROR: Input file must be identified\n\n"); exit; }
if ( ! defined($ofile) ) { printf("\nERROR: Output file must be identified\n\n"); exit; }
if ( ! defined($devid) ) { printf("\nERROR: I2C Device ID must be identified\n\n"); exit; }

if ( !(-e "$ifile") )  {
    printf("\n");
    printf("ERROR: Input file not found:\n");
    printf("    %s\n", $ifile);
    printf("\n");
    exit;
}

if ( -e "$ofile" )  {
    printf("\n");
    printf("ERROR: Output file already exist.  Please delete and retry:\n");
    printf("    %s\n", $ofile);
    printf("\n");
    #exit;
}

# ---------------------------------------------------------------------

# These are the two output files :
#    1. the one from the command line,
#    2. a humanized log for better debug

#$ofile  = "debug.coe";
$ofile0 = $ofile.".coe";
$ofile1 = $ofile.'.log';
$ofile2 = $ofile.'.reg';
$ofile3 = $ofile.'.tcl';

if( -e "$ofile0") { unlink "$ofile0"; }
if( -e "$ofile1") { unlink "$ofile1"; }
if( -e "$ofile2") { unlink "$ofile2"; }
if( -e "$ofile3") { unlink "$ofile3"; }

$devid = hex($devid);

# ---------------------------------------------------------------------

$nn = 0;

$tcl_nn = 0;

open SOUT0, ">$ofile0";
open SOUT1, ">$ofile1";
open SOUT2, ">$ofile2";
open SOUT3, ">$ofile3";

printf SOUT0 ("memory_initialization_radix=16\;\n");
printf SOUT0 ("memory_initialization_vector=\n");

# Initial line sets the Device ID.
printf SOUT0 ("%02x%02x,\n", 0x01, $devid);
printf SOUT3 ("hwchk_axil_write 0x%08x 0x%08x 0x0000%02x%02x\n", 0x30000, $tcl_nn, 0x01, $devid);
printf SOUT1 ("instru\[%03d\]  = { DEV_ID_OP     , 2'h%02x }\;\n", $nn, $devid);
$tcl_nn = $tcl_nn + 4;
$nn++;

# ---------------------------------------------------------------------

# Load the input text file...
@PARAM = qx(cat $ifile);

foreach $temp (@PARAM)
{
    # Prep read line...
    chomp $temp;
    $temp =~ s/,//g;
    $temp =~ s/0x//g;
    @TOK = split /\s/, $temp;


    # Change to a common format....
    undef @TOK1;
    if ($TOK[0] =~ /^Size/) 
    {
        #  Size: 4 Offset: FC Data: 00C01020
        push @TOK1, $TOK[3];
        $temp = $TOK[5];
        for($ii=0;$ii<length($temp); $ii=$ii+2)
        {
            push @TOK1, substr($temp,$ii,2);
        }
    }
    elsif ($TOK[0] =~ /^i2cset/) 
    {
        #  i2cset -f -y 15 0x5b 0xfc 0x00 0xc3 0x10 0x20 i
        for($ii=5;$ii<$#TOK;$ii++)
        {
            push @TOK1, $TOK[$ii];
        }
    }
    else
    {
        next;
    }

    # Print instructions for Size and Addr...
    $size = $#TOK1;
    $addr = hex($TOK1[0]);
    
    printf SOUT0 ("%02x%02x,\n", 0x02, $size);
    printf SOUT3 ("hwchk_axil_write 0x%08x 0x%08x 0x0000%02x%02x\n", 0x30000, $tcl_nn, 0x02, $size);
    printf SOUT1 ("instru\[%03d\]  = { SIZE_OP       , 2'h%02x }\;\n", $nn, $size);
    $tcl_nn = $tcl_nn + 4;
    $nn++;
    printf SOUT0 ("%02x%02x,\n", 0x04, $addr);
    printf SOUT3 ("hwchk_axil_write 0x%08x 0x%08x 0x0000%02x%02x\n", 0x30000, $tcl_nn, 0x04, $addr);
    printf SOUT1 ("instru\[%03d\]  = { ADDR_OP       , 2'h%02x }\;\n", $nn, $addr);
    $tcl_nn = $tcl_nn + 4;
    $nn++;

    # Display new page select....
    if ($addr == 0xFC)
    {
        # New Page Select 
        $pagesel = hex($TOK1[2]) << 8;        
        printf SOUT2 ("[%02x] Set Page Addr... 0x%04x \n", $addr, $pagesel);
        #set pagesel to 0 for now...
        $pagesel = 0;
    }
    if ($addr == 0xFD)
    {
        # New Page Select 
        $pagesel = hex($TOK1[1]) << 8;        
        printf SOUT2 ("[%02x] Set Page Addr... 0x%04x \n", $addr, $pagesel);
        #set pagesel to 0 for now...
        $pagesel = 0;
    }
    else
    {
        # Normal Register Address
        $str1 = &modlookup($pagesel + $addr);
        printf SOUT2 ("[%04x] %s\n", $pagesel + $addr, $str1);
    }

    # Loop though Data string, one byte at a time, except for final byte...
    for($ii=1;$ii<$#TOK1;$ii=$ii+1)
    {
        $temp = hex($TOK1[$ii]);
        printf SOUT0 ("%02x%02x,\n", 0x08, $temp);
        printf SOUT3 ("hwchk_axil_write 0x%08x 0x%08x 0x0000%02x%02x\n", 0x30000, $tcl_nn, 0x08, $temp);
        printf SOUT1 ("instru\[%03d\]  = { WDATA_OP      , 2'h%02x }\;\n", $nn, $temp);
        $tcl_nn = $tcl_nn + 4;
        $nn++;
        
        #if ($addr == 0xFC) { next; } # Already printed out the status 
        $str1 = &reglookup($pagesel + $addr);
        printf SOUT2 ("     [%04x]  0x%02x  %s\n", $pagesel + $addr, $temp, $str1);
        $addr++;
    }

    $temp = hex($TOK1[$ii]);
    printf SOUT0 ("%02x%02x,\n", 0x10, $temp);
    printf SOUT3 ("hwchk_axil_write 0x%08x 0x%08x 0x0000%02x%02x\n", 0x30000, $tcl_nn, 0x10, $temp);
    printf SOUT1 ("instru\[%03d\]  = { WDATA_LAST_OP , 2'h%02x }\;\n", $nn, $temp);
    $tcl_nn = $tcl_nn + 4;
    $nn++;

    $str1 = &reglookup($pagesel + $addr);
    printf SOUT2 ("     [%04x]  0x%02x  %s\n", $pagesel + $addr, $temp, $str1);
    $addr++;

    if ($pagesel == 0) 
    {
        $pagesel = hex($TOK1[2]) << 8;
        #$pagesel = hex($TOK1[1]) << 8;
    }
}

# Add a "Finished" tag for the state machine....
printf SOUT0 ("%02x%02x\;", 0x80, 0xFF);
printf SOUT3 ("hwchk_axil_write 0x%08x 0x%08x 0x0000%02x%02x\n", 0x30000, $tcl_nn, 0x80, 0xFF);
printf SOUT1 ("instru\[%03d\]  = { FINISHED_OP   , 8'h%02x }\;\n", $nn, 0xFF);
$tcl_nn = $tcl_nn + 4;
$nn++;

close SOUT0;


# ==========================================================================

sub modlookup {
    my $addr = $_[0];
    switch ($addr) {
        case 0xC014 { return "Module: GENERAL_STATUS Chip hardware status registers." }
        case 0xC03C { return "Module: STATUS Live status of alarms and events." }
        case 0xC160 { return "Module: GPIO_USER_CONTROL GPIO user control." }
        case 0xC164 { return "Module: STICKY_STATUS_CLEAR Sticky status clear." }
        case 0xC16C { return "Module: GPIO_TOD_NOTIFICATION_CLEAR"}
        case 0xC170 { return "RESERVED This module must not be modified from the read value"}
        case 0xC180 { return "RESERVED This module must not be modified from the read value"}
        case 0xC188 { return "Module: ALERT_CFG Notification configuration."}
        case 0xC194 { return "Module: SYS_DPLL_XO System DPLL XO configuration."}
        case 0xC19C { return "Module: SYS_APLL System APLL configuration."}
        case 0xC1B0 { return "Module: INPUT_0 Input 0 configuration." }
        case 0xC1C0 { return "INPUT_1 Input 1 configuration." }
        case 0xC1D0 { return "INPUT_2 Input 2 configuration." }
        case 0xC200 { return "INPUT_3 Input 3 configuration." }
        case 0xC210 { return "INPUT_4 Input 4 configuration." }
        case 0xC220 { return "INPUT_5 Input 5 configuration." }
        case 0xC230 { return "INPUT_6 Input 6 configuration." }
        case 0xC240 { return "INPUT_7 Input 7 configuration." }
        case 0xC250 { return "INPUT_8 Input 8 configuration." }
        case 0xC260 { return "INPUT_9 Input 9 configuration." }
        case 0xC280 { return "INPUT_10 Input 10 configuration." }
        case 0xC290 { return "INPUT_11 Input 11 configuration." }
        case 0xC2A0 { return "INPUT_12 Input 12 configuration." }
        case 0xC2B0 { return "INPUT_13 Input 13 configuration." }
        case 0xC2C0 { return "INPUT_14 Input 14 configuration." }
        case 0xC2D0 { return "INPUT_15 Input 15 configuration." }
        case 0xC2E0 { return "Module: REF_MON_0 Reference monitor 0." }
        case 0xC2EC { return "REF_MON_1 Reference monitor 1." }
        case 0xC300 { return "REF_MON_2 Reference monitor 2." }
        case 0xC30C { return "REF_MON_3 Reference monitor 3." }
        case 0xC318 { return "REF_MON_4 Reference monitor 4." }
        case 0xC324 { return "REF_MON_5 Reference monitor 5." }
        case 0xC330 { return "REF_MON_6 Reference monitor 6." }
        case 0xC33C { return "REF_MON_7 Reference monitor 7." }
        case 0xC348 { return "REF_MON_8 Reference monitor 8." }
        case 0xC354 { return "REF_MON_9 Reference monitor 9." }
        case 0xC360 { return "REF_MON_10 Reference monitor 10." }
        case 0xC36C { return "REF_MON_11 Reference monitor 11." }
        case 0xC380 { return "REF_MON_12 Reference monitor 12." }
        case 0xC38C { return "REF_MON_13 Reference monitor 13." }
        case 0xC398 { return "REF_MON_14 Reference monitor 14." }
        case 0xC3A4 { return "REF_MON_15 Reference monitor 15." }
        case 0xC3B0 { return "Module: DPLL_0 DPLL 0 configuration registers." }
        case 0xC400 { return "DPLL_1 DPLL 1 registers." }
        case 0xC43C { return "DPLL_2 DPLL 2 registers." }
        case 0xC480 { return "DPLL_3 DPLL 3 registers." }
        case 0xC4BC { return "DPLL_4 DPLL 4 registers." }
        case 0xC500 { return "DPLL_5 DPLL 5 registers." }
        case 0xC53C { return "DPLL_6 DPLL 6 registers." }
        case 0xC580 { return "DPLL_7 DPLL 7 registers." }
        case 0xC5BC { return "Module: SYS_DPLL System DPLL registers."}
        case 0xC600 { return "Module: DPLL_CTRL_0 DPLL 0 control registers."}
        case 0xC63C { return "DPLL_CTRL_1 DPLL 1 control registers."}
        case 0xC680 { return "DPLL_CTRL_2 DPLL 2 control registers."}
        case 0xC6BC { return "DPLL_CTRL_3 DPLL 3 control registers."}
        case 0xC700 { return "DPLL_CTRL_4 DPLL 4 control registers."}
        case 0xC73C { return "DPLL_CTRL_5 DPLL 5 control registers."}
        case 0xC780 { return "DPLL_CTRL_6 DPLL 6 control registers."}
        case 0xC7BC { return "DPLL_CTRL_7 DPLL 7 control registers."}
        case 0xC800 { return "Module: SYS_DPLL_CTRL System DPLL control registers." }
        case 0xC818 { return "Module: DPLL_PHASE_0 DPLL 0 write phase." }
        case 0xC81C { return "DPLL_PHASE_1 DPLL 1 write phase." }
        case 0xC820 { return "DPLL_PHASE_2 DPLL 2 write phase." }
        case 0xC824 { return "DPLL_PHASE_3 DPLL 3 write phase." }
        case 0xC828 { return "DPLL_PHASE_4 DPLL 4 write phase." }
        case 0xC82C { return "DPLL_PHASE_5 DPLL 5 write phase." }
        case 0xC830 { return "DPLL_PHASE_6 DPLL 6 write phase." }
        case 0xC834 { return "DPLL_PHASE_7 DPLL 7 write phase." }
        case 0xC838 { return "Module: DPLL_FREQ_0 DPLL 0 write frequency."}
        case 0xC840 { return "DPLL_FREQ_1 DPLL 1 write frequency."}
        case 0xC848 { return "DPLL_FREQ_2 DPLL 2 write frequency."}
        case 0xC850 { return "DPLL_FREQ_3 DPLL 3 write frequency."}
        case 0xC858 { return "DPLL_FREQ_4 DPLL 4 write frequency."}
        case 0xC860 { return "DPLL_FREQ_5 DPLL 5 write frequency."}
        case 0xC868 { return "DPLL_FREQ_6 DPLL 6 write frequency."}
        case 0xC870 { return "DPLL_FREQ_7 DPLL 7 write frequency."}
        case 0xC880 { return "Module: DPLL_PHASE_PULL_IN_0 DPLL 0 phase pull-in control." }
        case 0xC888 { return "DPLL_PHASE_PULL_IN_1 DPLL 1 phase pull-in control." }
        case 0xC890 { return "DPLL_PHASE_PULL_IN_2 DPLL 2 phase pull-in control." }
        case 0xC898 { return "DPLL_PHASE_PULL_IN_3 DPLL 3 phase pull-in control." }
        case 0xC8A0 { return "DPLL_PHASE_PULL_IN_4 DPLL 4 phase pull-in control." }
        case 0xC8A8 { return "DPLL_PHASE_PULL_IN_5 DPLL 5 phase pull-in control." }
        case 0xC8B0 { return "DPLL_PHASE_PULL_IN_6 DPLL 6 phase pull-in control." }
        case 0xC8B8 { return "DPLL_PHASE_PULL_IN_7 DPLL 7 phase pull-in control." }
        case 0xC8C0 { return "Module: GPIO_CFG GPIO global configuration."}
        case 0xC8C2 { return "Module: GPIO_0 GPIO 0 registers." }
        case 0xC8D4 { return "GPIO_1 GPIO 1 registers." }
        case 0xC8E6 { return "GPIO_2 GPIO 2 registers." }
        case 0xC900 { return "GPIO_3 GPIO 3 registers." }
        case 0xC912 { return "GPIO_4 GPIO 4 registers." }
        case 0xC924 { return "GPIO_5 GPIO 5 registers." }
        case 0xC936 { return "GPIO_6 GPIO 6 registers." }
        case 0xC948 { return "GPIO_7 GPIO 7 registers." }
        case 0xC95A { return "GPIO_8 GPIO 8 registers." }
        case 0xC980 { return "GPIO_9 GPIO 9 registers." }
        case 0xC992 { return "GPIO_10 GPIO 10 registers." }
        case 0xC9A4 { return "GPIO_11 GPIO 11 registers." }
        case 0xC9B6 { return "GPIO_12 GPIO 12 registers." }
        case 0xC9C8 { return "GPIO_13 GPIO 13 registers." }
        case 0xC9DA { return "GPIO_14 GPIO 14 registers." }
        case 0xCA00 { return "GPIO_15 GPIO 15 registers." }
        case 0xCA12 { return "Module: OUT_DIV_MUX Output divider multiplexers." }
        case 0xCA20 { return "Module: OUTPUT_0 Output 0 registers." }
        case 0xCA30 { return "OUTPUT_1 Output 1 register."}
        case 0xCA40 { return "OUTPUT_2 Output 2 register."}
        case 0xCA50 { return "OUTPUT_3 Output 3 register."}
        case 0xCA60 { return "OUTPUT_4 Output 4 register."}
        case 0xCA80 { return "OUTPUT_5 Output 5 register."}
        case 0xCA90 { return "OUTPUT_6 Output 6 register."}
        case 0xCAA0 { return "OUTPUT_7 Output 7 register."}
        case 0xCAB0 { return "OUTPUT_8 Output 8 register."}
        case 0xCAC0 { return "OUTPUT_9 Output 9 register."}
        case 0xCAD0 { return "OUTPUT_10 Output 10 register."}
        case 0xCAE0 { return "OUTPUT_11 Output 11 register."}
        case 0xCAF0 { return "Module: SERIAL Serial Interfaces registers."}
        case 0xCB00 { return "Module: PWM_ENCODER_0 PWM 0 encoder registers." }
        case 0xCB08 { return "PWM_ENCODER_1 PWM 1 encoder registers." }
        case 0xCB10 { return "PWM_ENCODER_2 PWM 2 encoder registers." }
        case 0xCB18 { return "PWM_ENCODER_3 PWM 3 encoder registers." }
        case 0xCB20 { return "PWM_ENCODER_4 PWM 4 encoder registers." }
        case 0xCB28 { return "PWM_ENCODER_5 PWM 5 encoder registers." }
        case 0xCB30 { return "PWM_ENCODER_6 PWM 6 encoder registers." }
        case 0xCB38 { return "PWM_ENCODER_7 PWM 7 encoder registers." }
        case 0xCB40 { return "Module: PWM_DECODER_0 PWM 0 decoder registers." }
        case 0xCB4A { return "PWM_DECODER_1 PWM 1 decoder registers." }
        case 0xCB54 { return "PWM_DECODER_2 PWM 2 decoder registers." }
        case 0xCB5E { return "PWM_DECODER_3 PWM 3 decoder registers." }
        case 0xCB68 { return "PWM_DECODER_4 PWM 4 decoder registers." }
        case 0xCB80 { return "PWM_DECODER_5 PWM 5 decoder registers." }
        case 0xCB8A { return "PWM_DECODER_6 PWM 6 decoder registers." }
        case 0xCB94 { return "PWM_DECODER_7 PWM 7 decoder registers." }
        case 0xCB9E { return "PWM_DECODER_8 PWM 8 decoder registers." }
        case 0xCBA8 { return "PWM_DECODER_9 PWM 9 decoder registers." }
        case 0xCBB2 { return "PWM_DECODER_10 PWM 10 decoder registers." }
        case 0xCBBC { return "PWM_DECODER_11 PWM 11 decoder registers." }
        case 0xCBC6 { return "PWM_DECODER_12 PWM 12 decoder registers." }
        case 0xCBD0 { return "PWM_DECODER_13 PWM 13 decoder registers." }
        case 0xCBDA { return "PWM_DECODER_14 PWM 14 decoder registers." }
        case 0xCBE4 { return "PWM_DECODER_15 PWM 15 decoder registers." }
        case 0xCBF0 { return "Module: PWM_USER_DATA PWM user data registers." }
        case 0xCC00 { return "Module: TOD_0 TOD 0 registers." }
        case 0xCC02 { return "TOD_1 TOD 1 registers." }
        case 0xCC04 { return "TOD_2 TOD 2 registers." }
        case 0xCC06 { return "TOD_3 TOD 3 registers." }
        case 0xCC10 { return "Module: TOD_WRITE_0 Write TOD 0 registers." }
        case 0xCC20 { return "TOD_WRITE_1 Write TOD 1 registers." }
        case 0xCC30 { return "TOD_WRITE_2 Write TOD 2 registers." }
        case 0xCC40 { return "TOD_WRITE_3 Write TOD 3 registers." }
        case 0xCC50 { return "Module: TOD_READ_PRIMARY_0 Read TOD 0 primary registers." }
        case 0xCC60 { return "TOD_READ_PRIMARY_1 Read TOD 1 primary registers." }
        case 0xCC80 { return "TOD_READ_PRIMARY_2 Read TOD 2 primary registers." }
        case 0xCC90 { return "TOD_READ_PRIMARY_3 Read TOD 3 primary registers." }
        case 0xCCA0 { return "Module: TOD_READ_SECONDARY_0 Read TOD 0 secondary registers." }
        case 0xCCB0 { return "TOD_READ_SECONDARY_1 Read TOD 1 secondary registers." }
        case 0xCCC0 { return "TOD_READ_SECONDARY_2 Read TOD 2 secondary registers." }
        case 0xCCD0 { return "TOD_READ_SECONDARY_3 Read TOD 3 secondary registers." }
        case 0xCCE0 { return "Module: OUTPUT_TDC_CFG Output TDC global configuration."}
        case 0xCD00 { return "Module: OUTPUT_TDC_0 Output TDC 0." }
        case 0xCD08 { return "OUTPUT_TDC_1 Output TDC 1." }
        case 0xCD10 { return "OUTPUT_TDC_2 Output TDC 2." }
        case 0xCD18 { return "OUTPUT_TDC_3 Output TDC 3." }
        case 0xCD20 { return "Module: INPUT_TDC Input TDC"}
        case 0xCD28 { return "Module: SYSREF SYSREF"}
        case 0xCF3C { return "RESERVED This module must not be modified from the read value"}
        case 0xCF4C { return "Module: SCRATCH User multipurpose registers." }
        case 0xCF5C { return "RESERVED This module must not be modified from the read value"}
        case 0xCF64 { return "Module: EEPROM EEPROM." }
        case 0xCF70 { return "Module: OTP OTP." }
        case 0xCF80 { return "Module: BYTE OTP registers."}
        else        { return "unknown - may be an extension" }
    }
}

sub reglookup {
    my $addr = $_[0];

    switch ($addr) {
        case 0x00FC { return "PAGE_ADDR\[7:0\]" }
        case 0x00FD { return "PAGE_ADDR\[15:8\]" }
        case 0x00FE { return "PAGE_ADDR\[23:16\]" }
        case 0x00FF { return "PAGE_ADDR\[31:24\]" }
        case 0xc3b0 + 0x000  {return "DPLL_0.DPLL_DCO_INC_DEC_SIZE Configure frequency step size for GPIO increment/decrement mode.  " }
        case 0xc3b0 + 0x002  {return "DPLL_0.DPLL_CTRL_0 Reference switching configuration and forced lock reference selection." }
        case 0xc3b0 + 0x003  {return "DPLL_0.DPLL_CTRL_1 Configure other hitless switch features and DPLL feedback as a reference." }
        case 0xc3b0 + 0x004  {return "DPLL_0.DPLL_CTRL_2 External feedback and frame/sync pulse configuration." }
        case 0xc3b0 + 0x005  {return "DPLL_0.DPLL_CTRL_3 Configure DPLL loop filter update rate and maximum number of fast lock" }
        case 0xc3b0 + 0x006  {return "DPLL_0.DPLL_FILTER_STATUS_UPDATE_CF" }
        case 0xc3b0 + 0x007  {return "DPLL_0.DPLL_HO_ADVCD_HISTORY Advanced holdover history configuration." }
        case 0xc3b0 + 0x008  {return "DPLL_0.DPLL_HO_ADVCD_BW DPLL advanced holdover bandwidth configuration." }
        case 0xc3b0 + 0x00A  {return "DPLL_0.DPLL_HO_CFG Holdover configuration." }
        case 0xc3b0 + 0x00B  {return "DPLL_0.DPLL_LOCK_0 Phase lock threshold." }
        case 0xc3b0 + 0x00C  {return "DPLL_0.DPLL_LOCK_1 Phase lock monitor duration." }
        case 0xc3b0 + 0x00D  {return "DPLL_0.DPLL_LOCK_2 Frequency lock threshold." }
        case 0xc3b0 + 0x00E  {return "DPLL_0.DPLL_LOCK_3 Frequency lock monitor duration." }
        case 0xc3b0 + 0x00F  {return "DPLL_0.DPLL_REF_PRIORITY_0 Select input for highest (0) priority." }
        case 0xc3b0 + 0x010  {return "DPLL_0.DPLL_REF_PRIORITY_1 Select input for priority 1." }
        case 0xc3b0 + 0x011  {return "DPLL_0.DPLL_REF_PRIORITY_2 Select input for priority 2." }
        case 0xc3b0 + 0x012  {return "DPLL_0.DPLL_REF_PRIORITY_3 Select input for priority 3." }
        case 0xc3b0 + 0x013  {return "DPLL_0.DPLL_REF_PRIORITY_4 Select input for priority 4." }
        case 0xc3b0 + 0x014  {return "DPLL_0.DPLL_REF_PRIORITY_5 Select input for priority 5." }
        case 0xc3b0 + 0x015  {return "DPLL_0.DPLL_REF_PRIORITY_6 Select input for priority 6." }
        case 0xc3b0 + 0x016  {return "DPLL_0.DPLL_REF_PRIORITY_7 Select input for priority 7." }
        case 0xc3b0 + 0x017  {return "DPLL_0.DPLL_REF_PRIORITY_8 Select input for priority 8." }
        case 0xc3b0 + 0x018  {return "DPLL_0.DPLL_REF_PRIORITY_9 Select input for priority 9." }
        case 0xc3b0 + 0x019  {return "DPLL_0.DPLL_REF_PRIORITY_10 Select input for priority 10." }
        case 0xc3b0 + 0x01A  {return "DPLL_0.DPLL_REF_PRIORITY_11 Select input for priority 11." }
        case 0xc3b0 + 0x01B  {return "DPLL_0.DPLL_REF_PRIORITY_12 Select input for priority 12." }
        case 0xc3b0 + 0x01C  {return "DPLL_0.DPLL_REF_PRIORITY_13 Select input for priority 13." }
        case 0xc3b0 + 0x01D  {return "DPLL_0.DPLL_REF_PRIORITY_14 Select input for priority 14." }
        case 0xc3b0 + 0x01E  {return "DPLL_0.DPLL_REF_PRIORITY_15 Select input for priority 15." }
        case 0xc3b0 + 0x01F  {return "DPLL_0.DPLL_REF_PRIORITY_16 Select input for priority 16." }
        case 0xc3b0 + 0x020  {return "DPLL_0.DPLL_REF_PRIORITY_17 Select input for priority 17." }
        case 0xc3b0 + 0x021  {return "DPLL_0.DPLL_REF_PRIORITY_18 Select input for priority 18." }
        case 0xc3b0 + 0x022  {return "DPLL_0.DPLL_TRANS_CTRL Phase transient configuration." }
        case 0xc3b0 + 0x023  {return "DPLL_0.DPLL_FASTLOCK_CFG_0 Fast lock configuration." }
        case 0xc3b0 + 0x024  {return "DPLL_0.DPLL_FASTLOCK_CFG_1 Fast lock configuration." }
        case 0xc3b0 + 0x025  {return "DPLL_0.DPLL_MAX_FREQ_OFFSET DPLL maximum frequency offset limit." }
        case 0xc3b0 + 0x026  {return "DPLL_0.DPLL_FASTLOCK_PSL Fast lock phase slope limit." }
        case 0xc3b0 + 0x028  {return "DPLL_0.DPLL_FASTLOCK_FSL Fast lock frequency slope limit." }
        case 0xc3b0 + 0x02A  {return "DPLL_0.DPLL_FASTLOCK_BW Fast lock loop filter bandwidth." }
        case 0xc3b0 + 0x02C  {return "DPLL_0.DPLL_WRITE_FREQ_TIMER Write frequency timer." }
        case 0xc3b0 + 0x02E  {return "DPLL_0.DPLL_WRITE_PHASE_TIMER Write phase timer." }
        case 0xc3b0 + 0x030  {return "DPLL_0.DPLL_PRED_CFG Predefined configuration selection." }
        case 0xc3b0 + 0x031  {return "DPLL_0.DPLL_TOD_SYNC_CFG DPLL ToD synchronization configuration." }
        case 0xc3b0 + 0x032  {return "DPLL_0.DPLL_COMBO_SLAVE_CFG_0 Combo mode slave primary source configuration." }
        case 0xc3b0 + 0x033  {return "DPLL_0.DPLL_COMBO_SLAVE_CFG_1 Combo mode slave secondary source configuration." }
        case 0xc3b0 + 0x034  {return "DPLL_0.DPLL_SLAVE_REF_CFG Slave mode configuration." }
        case 0xc3b0 + 0x035  {return "DPLL_0.DPLL_REF_MODE Reference selection configuration and XO DPLL monitor enable." }
        case 0xc3b0 + 0x036  {return "DPLL_0.DPLL_PHASE_MEASUREMENT_CFG Phase measurement mode configuration." }
        case 0xc3b0 + 0x037  {return "DPLL_0.DPLL_FASTLOCK_FREQ_SNAP_WIN" }
        case 0xc3b0 + 0x038  {return "DPLL_0.DPLL_FASTLOCK_PHASE_PULL_IN_" }
        case 0xc3b0 + 0x039  {return "DPLL_0.DPLL_FASTLOCK_PHASE_SNAP_WI" }
        case 0xc3b0 + 0x03A  {return "DPLL_0.DPLL_SINGLE_PULSE_SYNC_CFG Single pulse synchronization configuration." }
        case 0xc3b0 + 0x03B  {return "DPLL_0.DPLL_MODE DPLL operating modes." }

        case 0xc000 + 0x000 { return "RESERVED" }
        case 0xc000 + 0x001 { return "RESERVED" }
        case 0xc000 + 0x002 { return "RESERVED" }
        case 0xc000 + 0x003 { return "RESERVED" }
        case 0xc000 + 0x004 { return "RESERVED" }
        case 0xc000 + 0x005 { return "RESERVED" }
        case 0xc000 + 0x006 { return "RESERVED" }
        case 0xc000 + 0x007 { return "RESERVED" }
        case 0xc000 + 0x008 { return "RESERVED" }
        case 0xc000 + 0x009 { return "RESERVED" }
        case 0xc000 + 0x00A { return "RESERVED" }
        case 0xc000 + 0x00B { return "RESERVED" }
        case 0xc000 + 0x00C { return "RESERVED" }
        case 0xc000 + 0x00D { return "RESERVED" }
        case 0xc000 + 0x00E { return "RESERVED" }
        case 0xc000 + 0x00F { return "RESERVED" }
        case 0xc000 + 0x010 { return "RESERVED" }
        case 0xc000 + 0x011 { return "RESERVED" }
        case 0xc000 + 0x012 { return "RESERVED" }
        case 0xc000 + 0x013 { return "RESET_CTRL.SM_RESET Reset state machine." }

        case 0xc014 + 0x000 { return "RESERVED " }
        case 0xc014 + 0x001 { return "RESERVED " }
        case 0xc014 + 0x002 { return "RESERVED " }
        case 0xc014 + 0x003 { return "RESERVED " }
        case 0xc014 + 0x004 { return "GENERAL_STATUS.OTP_STATUS Current status of OTP." }
        case 0xc014 + 0x008 { return "GENERAL_STATUS.EEPROM_STATUS Current status of EEPROM." }
        case 0xc014 + 0x00A { return "GENERAL_STATUS.HW_REV_ID Hardware Revision Identification code" }
        case 0xc014 + 0x00B { return "RESERVED " }
        case 0xc014 + 0x00C { return "RESERVED " }
        case 0xc014 + 0x00D { return "RESERVED " }
        case 0xc014 + 0x00E { return "RESERVED " }
        case 0xc014 + 0x00F { return "RESERVED " }
        case 0xc014 + 0x010 { return "GENERAL_STATUS.MAJ_REL Major release number." }
        case 0xc014 + 0x011 { return "GENERAL_STATUS.MIN_REL Minor release number." }
        case 0xc014 + 0x012 { return "GENERAL_STATUS.HOTFIX_REL Hotfix release number." }
        case 0xc014 + 0x014 { return "RESERVED " }
        case 0xc014 + 0x015 { return "RESERVED " }
        case 0xc014 + 0x016 { return "RESERVED " }
        case 0xc014 + 0x017 { return "RESERVED " }
        case 0xc014 + 0x018 { return "GENERAL_STATUS.DASH_CODE Dash Code value." }
        case 0xc014 + 0x01A { return "RESERVED " }
        case 0xc014 + 0x01B { return "RESERVED " }
        case 0xc014 + 0x01C { return "GENERAL_STATUS.JTAG_DEVICE_ID JTAG device identity." }
        case 0xc014 + 0x01E { return "GENERAL_STATUS.PRODUCT_ID Product identity." }
        case 0xc014 + 0x020 { return "RESERVED " }
        case 0xc014 + 0x021 { return "RESERVED " }
        case 0xc014 + 0x022 { return "GENERAL_STATUS.OTP_SCSR_CONFIG_SELECT Selected soft CSR configuration loaded from OTP." }
        case 0xc014 + 0x023 { return "GENERAL_STATUS.OTP_CONFIG_STATUS OTP soft CSR configuration status." }
        case 0xc014 + 0x024 { return "GENERAL_STATUS.OTP_CSR_CONFIG_STATUS OTP hard CSR configuration status." }
        case 0xc014 + 0x025 { return "RESERVED " }
        case 0xc014 + 0x026 { return "GENERAL_STATUS.EEPROM_CONFIG_STATUS EEPROM soft CSR configuration status" }

        case 0xc03c + 0x0000 { return "STATUS.I2CM_STATUS I2C master status." }
        case 0xc03c + 0x0001 { return "RESERVED " }
        case 0xc03c + 0x0002 { return "STATUS.SER0_STATUS Status of serial interface 0 (main serial port)." }
        case 0xc03c + 0x0003 { return "STATUS.SER0_SPI_STATUS Status of serial interface 0 (main serial port) SPI." }
        case 0xc03c + 0x0004 { return "STATUS.SER0_I2C_STATUS Status of serial interface 0 (main serial port) I2C." }
        case 0xc03c + 0x0005 { return "STATUS.SER1_STATUS Status of serial interface 1 (auxiliary serial port)." }
        case 0xc03c + 0x0006 { return "STATUS.SER1_SPI_STATUS Status of serial interface 1 (auxiliary serial port) SPI." }
        case 0xc03c + 0x0007 { return "STATUS.SER1_I2C_STATUS Status of serial interface 1 (auxiliary serial port) I2C." }
        case 0xc03c + 0x0008 { return "STATUS.IN0_MON_STATUS Input 0 reference monitor status." }
        case 0xc03c + 0x0009 { return "STATUS.IN1_MON_STATUS Input 1 reference monitor status." }
        case 0xc03c + 0x000A { return "STATUS.IN2_MON_STATUS Input 2 reference monitor status." }
        case 0xc03c + 0x000B { return "STATUS.IN3_MON_STATUS Input 3 reference monitor status." }
        case 0xc03c + 0x000C { return "STATUS.IN4_MON_STATUS Input 4 reference monitor status." }
        case 0xc03c + 0x000D { return "STATUS.IN5_MON_STATUS Input 5 reference monitor status." }
        case 0xc03c + 0x000E { return "STATUS.IN6_MON_STATUS Input 6 reference monitor status." }
        case 0xc03c + 0x000F { return "STATUS.IN7_MON_STATUS Input 7 reference monitor status." }
        case 0xc03c + 0x0010 { return "STATUS.IN8_MON_STATUS Input 8 reference monitor status." }
        case 0xc03c + 0x0011 { return "STATUS.IN9_MON_STATUS Input 9 reference monitor status." }
        case 0xc03c + 0x0012 { return "STATUS.IN10_MON_STATUS Input 10 reference monitor status." }
        case 0xc03c + 0x0013 { return "STATUS.IN11_MON_STATUS Input 11 reference monitor status." }
        case 0xc03c + 0x0014 { return "STATUS.IN12_MON_STATUS Input 12 reference monitor status." }
        case 0xc03c + 0x0015 { return "STATUS.IN13_MON_STATUS Input 13 reference monitor status." }
        case 0xc03c + 0x0016 { return "STATUS.IN14_MON_STATUS Input 14 reference monitor status." }
        case 0xc03c + 0x0017 { return "STATUS.IN15_MON_STATUS Input 15 reference monitor status." }
        case 0xc03c + 0x0018 { return "STATUS.DPLL0_STATUS DPLL 0 status." }
        case 0xc03c + 0x0019 { return "STATUS.DPLL1_STATUS DPLL 1 status." }
        case 0xc03c + 0x001A { return "STATUS.DPLL2_STATUS DPLL 2 status." }
        case 0xc03c + 0x001B { return "STATUS.DPLL3_STATUS DPLL 3 status." }
        case 0xc03c + 0x001C { return "STATUS.DPLL4_STATUS DPLL 4 status." }
        case 0xc03c + 0x001D { return "STATUS.DPLL5_STATUS DPLL 5 status." }
        case 0xc03c + 0x001E { return "STATUS.DPLL6_STATUS DPLL 6 status." }
        case 0xc03c + 0x001F { return "STATUS.DPLL7_STATUS DPLL 7 status." }
        case 0xc03c + 0x0020 { return "STATUS.DPLL_SYS_STATUS System DPLL status." }
        case 0xc03c + 0x0021 { return "STATUS.SYS_APLL_STATUS System APLL status." }
        case 0xc03c + 0x0022 { return "STATUS.DPLL0_REF_STAT DPLL 0 input reference status." }
        case 0xc03c + 0x0023 { return "STATUS.DPLL1_REF_STAT DPLL 1 input reference status." }
        case 0xc03c + 0x0024 { return "STATUS.DPLL2_REF_STAT DPLL 2 input reference status." }
        case 0xc03c + 0x0025 { return "STATUS.DPLL3_REF_STAT DPLL 3 input reference status." }
        case 0xc03c + 0x0026 { return "STATUS.DPLL4_REF_STAT DPLL 4 input reference status." }
        case 0xc03c + 0x0027 { return "STATUS.DPLL5_REF_STAT DPLL 5 input reference status." }
        case 0xc03c + 0x0028 { return "STATUS.DPLL6_REF_STAT DPLL 6 input reference status." }
        case 0xc03c + 0x0029 { return "STATUS.DPLL7_REF_STAT DPLL 7 input reference status." }
        case 0xc03c + 0x002A { return "STATUS.DPLL_SYS_REF_STAT System DPLL input reference status." }
        case 0xc03c + 0x0044 { return "STATUS.DPLL0_FILTER_STATUS DPLL 0 loop filter status." }
        case 0xc03c + 0x004C { return "STATUS.DPLL1_FILTER_STATUS DPLL 1 loop filter status." }
        case 0xc03c + 0x0054 { return "STATUS.DPLL2_FILTER_STATUS DPLL 2 loop filter status." }
        case 0xc03c + 0x005C { return "STATUS.DPLL3_FILTER_STATUS DPLL 3 loop filter status." }
        case 0xc03c + 0x0064 { return "STATUS.DPLL4_FILTER_STATUS DPLL 4 loop filter status." }
        case 0xc03c + 0x006C { return "STATUS.DPLL5_FILTER_STATUS DPLL 5 loop filter status." }
        case 0xc03c + 0x0074 { return "STATUS.DPLL6_FILTER_STATUS DPLL 6 loop filter status." }
        case 0xc03c + 0x007C { return "STATUS.DPLL7_FILTER_STATUS DPLL 7 loop filter status." }
        case 0xc03c + 0x0084 { return "STATUS.DPLL_SYS_FILTER_STATUS System DPLL loop filter status." }
        case 0xc03c + 0x008A { return "STATUS.USER_GPIO0_TO_7_STATUS User controlled GPIO level." }
        case 0xc03c + 0x008B { return "STATUS.USER_GPIO8_TO_15_STATUS User controlled GPIO level." }
        case 0xc03c + 0x008C { return "STATUS.IN0_MON_FREQ_STATUS Input 0 reference monitor frequency status and unit." }
        case 0xc03c + 0x008E { return "STATUS.IN1_MON_FREQ_STATUS Input 1 reference monitor frequency status and unit." }
        case 0xc03c + 0x0090 { return "STATUS.IN2_MON_FREQ_STATUS Input 2 reference monitor frequency status and unit." }
        case 0xc03c + 0x0092 { return "STATUS.IN3_MON_FREQ_STATUS Input 3 reference monitor frequency status and unit." }
        case 0xc03c + 0x0094 { return "STATUS.IN4_MON_FREQ_STATUS Input 4 reference monitor frequency status and unit." }
        case 0xc03c + 0x0096 { return "STATUS.IN5_MON_FREQ_STATUS Input 5 reference monitor frequency status and unit." }
        case 0xc03c + 0x0098 { return "STATUS.IN6_MON_FREQ_STATUS Input 6 reference monitor frequency status and unit." }
        case 0xc03c + 0x009A { return "STATUS.IN7_MON_FREQ_STATUS Input 7 reference monitor frequency status and unit." }
        case 0xc03c + 0x009C { return "STATUS.IN8_MON_FREQ_STATUS Input 8 reference monitor frequency status and unit." }
        case 0xc03c + 0x009E { return "STATUS.IN9_MON_FREQ_STATUS Input 9 reference monitor frequency status and unit." }
        case 0xc03c + 0x00A0 { return "STATUS.IN10_MON_FREQ_STATUS Input 10 reference monitor frequency status and unit." }
        case 0xc03c + 0x00A2 { return "STATUS.IN11_MON_FREQ_STATUS Input 11 reference monitor frequency status and unit." }
        case 0xc03c + 0x00A4 { return "STATUS.IN12_MON_FREQ_STATUS Input 12 reference monitor frequency status and unit." }
        case 0xc03c + 0x00A6 { return "STATUS.IN13_MON_FREQ_STATUS Input 13 reference monitor frequency status and unit." }
        case 0xc03c + 0x00A8 { return "STATUS.IN14_MON_FREQ_STATUS Input 14 reference monitor frequency status and unit." }
        case 0xc03c + 0x00AA { return "STATUS.IN15_MON_FREQ_STATUS Input 15 reference monitor frequency status and unit." }
        case 0xc03c + 0x00AC { return "STATUS.OUTPUT_TDC_CFG_STATUS Output TDC global status." }
        case 0xc03c + 0x00AD { return "STATUS.OUTPUT_TDC0_STATUS Output TDC 0 status." }
        case 0xc03c + 0x00AE { return "STATUS.OUTPUT_TDC1_STATUS Output TDC 1 status." }
        case 0xc03c + 0x00AF { return "STATUS.OUTPUT_TDC2_STATUS Output TDC 2 status." }
        case 0xc03c + 0x00B0 { return "STATUS.OUTPUT_TDC3_STATUS Output TDC 3 status." }
        case 0xc03c + 0x00B4 { return "STATUS.OUTPUT_TDC0_MEASUREMENT Output TDC 0 measurement status." }
        case 0xc03c + 0x00BA { return "RESERVED " }
        case 0xc03c + 0x00BB { return "RESERVED " }
        case 0xc03c + 0x00C4 { return "STATUS.OUTPUT_TDC1_MEASUREMENT Output TDC 1 measurement status." }
        case 0xc03c + 0x00CA { return "RESERVED " }
        case 0xc03c + 0x00CB { return "RESERVED " }
        case 0xc03c + 0x00CC { return "STATUS.OUTPUT_TDC2_MEASUREMENT Output TDC 2 measurement status." }
        case 0xc03c + 0x00D2 { return "RESERVED " }
        case 0xc03c + 0x00D3 { return "RESERVED " }
        case 0xc03c + 0x00D4 { return "STATUS.OUTPUT_TDC3_MEASUREMENT Output TDC 3 measurement status." }
        case 0xc03c + 0x00DA { return "RESERVED " }
        case 0xc03c + 0x00DB { return "RESERVED " }
        case 0xc03c + 0x00DC { return "STATUS.DPLL0_PHASE_STATUS Phase offset at output of decimator." }
        case 0xc03c + 0x00E1 { return "RESERVED " }
        case 0xc03c + 0x00E2 { return "RESERVED " }
        case 0xc03c + 0x00E3 { return "RESERVED " }
        case 0xc03c + 0x00E4 { return "STATUS.DPLL1_PHASE_STATUS Phase offset at output of decimator." }
        case 0xc03c + 0x00E9 { return "RESERVED " }
        case 0xc03c + 0x00EA { return "RESERVED " }
        case 0xc03c + 0x00EC { return "STATUS.DPLL2_PHASE_STATUS Phase offset at output of decimator." }
        case 0xc03c + 0x00F1 { return "RESERVED " }
        case 0xc03c + 0x00F2 { return "RESERVED " }
        case 0xc03c + 0x00F3 { return "RESERVED " }
        case 0xc03c + 0x00F4 { return "STATUS.DPLL3_PHASE_STATUS Phase offset at output of decimator." }
        case 0xc03c + 0x00F9 { return "RESERVED " }
        case 0xc03c + 0x00FA { return "RESERVED " }
        case 0xc03c + 0x00FB { return "RESERVED " }
        case 0xc03c + 0x00FC { return "STATUS.DPLL4_PHASE_STATUS Phase offset at output of decimator." }
        case 0xc03c + 0x0101 { return "RESERVED " }
        case 0xc03c + 0x0102 { return "RESERVED " }
        case 0xc03c + 0x0103 { return "RESERVED " }
        case 0xc03c + 0x0104 { return "STATUS.DPLL5_PHASE_STATUS Phase offset at output of decimator." }
        case 0xc03c + 0x0109 { return "RESERVED " }
        case 0xc03c + 0x010A { return "RESERVED " }
        case 0xc03c + 0x010B { return "RESERVED " }
        case 0xc03c + 0x010C { return "STATUS.DPLL6_PHASE_STATUS Phase offset at output of decimator." }
        case 0xc03c + 0x0111 { return "RESERVED " }
        case 0xc03c + 0x0112 { return "RESERVED " }
        case 0xc03c + 0x0113 { return "RESERVED " }
        case 0xc03c + 0x0114 { return "STATUS.DPLL7_PHASE_STATUS Phase offset at output of decimator." }
        case 0xc03c + 0x0119 { return "RESERVED " }
        case 0xc03c + 0x011A { return "RESERVED " }
        case 0xc03c + 0x011B { return "RESERVED " }
        case 0xc03c + 0x011C { return "STATUS.DPLL0_PHASE_PULL_IN_STATUS DPLL0 phase pull-in status" }
        case 0xc03c + 0x011D { return "STATUS.DPLL1_PHASE_PULL_IN_STATUS DPLL1 phase pull-in status" }
        case 0xc03c + 0x011E { return "STATUS.DPLL2_PHASE_PULL_IN_STATUS DPLL2 phase pull-in status" }
        case 0xc03c + 0x011F { return "STATUS.DPLL3_PHASE_PULL_IN_STATUS DPLL3 phase pull-in status" }
        case 0xc03c + 0x0120 { return "STATUS.DPLL4_PHASE_PULL_IN_STATUS DPLL4 phase pull-in status" }
        case 0xc03c + 0x0121 { return "STATUS.DPLL5_PHASE_PULL_IN_STATUS DPLL5 phase pull-in status" }
        case 0xc03c + 0x0122 { return "STATUS.DPLL6_PHASE_PULL_IN_STATUS DPLL6 phase pull-in status" }
        case 0xc03c + 0x0123 { return "STATUS.DPLL7_PHASE_PULL_IN_STATUS DPLL7 phase pull-in status" }

        case 0xc160 + 0x000 { return "RESERVED " }
        case 0xc160 + 0x001 { return "RESERVED " }
        case 0xc160 + 0x002 { return "GPIO_USER_CONTROL.GPIO0_TO_7_OUT GPIO output control." }
        case 0xc160 + 0x003 { return "GPIO_USER_CONTROL.GPIO8_TO_15_OUT GPIO output control." }

        case 0xc164 + 0x000 { return "STICKY_STATUS_CLEAR.IN0_TO_7_MON_STICKY_STATUS_CLEAR" }
        case 0xc164 + 0x001 { return "STICKY_STATUS_CLEAR.IN8_TO_15_MON_STICKY_STATUS_CLEAR" }
        case 0xc164 + 0x002 { return "STICKY_STATUS_CLEAR.DPLL_STICKY_STATUS_CLEAR" }
        case 0xc164 + 0x003 { return "STICKY_STATUS_CLEAR.DPLL_SYS_STICKY_STATUS_CLEAR" }
        case 0xc164 + 0x004 { return "STICKY_STATUS_CLEAR.SYS_APLL_STICKY_STATUS_CLEAR" }
        case 0xc164 + 0x005 { return "STICKY_STATUS_CLEAR.ALL_STICKY_STATUS_CLEAR" }

        case 0xc16c + 0x000 { return "GPIO_TOD_NOTIFICATION_CLEAR.GPIO0_TO_7_CLEAR" }
        case 0xc16c + 0x001 { return "GPIO_TOD_NOTIFICATION_CLEAR.GPIO8_TO_15_CLEAR" }

        case 0xC188 + 0x000 { return "RESERVED " }
        case 0xC188 + 0x001 { return "ALERT_CFG.IN1_0_MON_ALERT_MASK GPIO alert enable masks for reference monitors 0 and 1." }
        case 0xC188 + 0x002 { return "ALERT_CFG.IN3_2_MON_ALERT_MASK GPIO alert enable masks for reference monitors 2 and 3." }
        case 0xC188 + 0x003 { return "ALERT_CFG.IN5_4_MON_ALERT_MASK GPIO alert enable masks for reference monitors 4 and 5." }
        case 0xC188 + 0x004 { return "ALERT_CFG.IN7_6_MON_ALERT_MASK GPIO alert enable masks for reference monitors 6 and 7." }
        case 0xC188 + 0x005 { return "ALERT_CFG.IN9_8_MON_ALERT_MASK GPIO alert enable masks for reference monitors 8 and 9." }
        case 0xC188 + 0x006 { return "ALERT_CFG.IN11_10_MON_ALERT_MASK GPIO alert enable masks for reference monitors 10 and 11." }
        case 0xC188 + 0x007 { return "ALERT_CFG.IN13_12_MON_ALERT_MASK GPIO alert enable masks for reference monitors 12 and 13." }
        case 0xC188 + 0x008 { return "ALERT_CFG.IN15_14_MON_ALERT_MASK GPIO alert enable masks for reference monitors 14 and 15." }
        case 0xC188 + 0x009 { return "ALERT_CFG.DPLL3_2_1_0_ALERT_MASK GPIO alert enable masks for DPLL 0,1, 2 and 3." }
        case 0xC188 + 0x00A { return "ALERT_CFG.DPLL7_6_5_4_ALERT_MASK GPIO alert enable masks for DPLLs 4, 5, 6 and 7." }
        case 0xC188 + 0x00B { return "ALERT_CFG.SYS_ALERT_MASK GPIO alert enable masks for system DPLL and system APLL" }

        case 0xc194 + 0x000 { return "SYS_DPLL_XO.XO_FREQ XO_DPLL frequency in Hz" }

        case 0xc19c + 0x000 { return "SYS_APLL.SYS_APLL_CP_SS_CURRENT_1 System APLL charge pump current register." }
        case 0xc19c + 0x001 { return "SYS_APLL.SYS_APLL_CP_SS_CURRENT_2 System APLL charge pump current register." }
        case 0xc19c + 0x002 { return "SYS_APLL.SYS_APLL_CFG_1 System APLL configuration register 1." }
        case 0xc19c + 0x003 { return "SYS_APLL.SYS_APLL_CFG_2 System APLL configuration register 2." }
        case 0xc19c + 0x004 { return "SYS_APLL.SYS_APLL_VREG_CTRL VREG control register." }
        case 0xc19c + 0x005 { return "SYS_APLL.SYS_APLL_CP_CTRL_0 System APLL charge pump control register." }
        case 0xc19c + 0x006 { return "SYS_APLL.SYS_APLL_CP_CTRL_1 System APLL charge pump control register." }
        case 0xc19c + 0x007 { return "SYS_APLL.SYS_APLL_CP_CTRL_2 System APLL charge pump control register." }
        case 0xc19c + 0x008 { return "SYS_APLL.SYS_APLL_XTAL_FREQ System APLL crystal frequency in Hz." }
        case 0xc19c + 0x010 { return "RESERVED " }
        case 0xc19c + 0x011 { return "RESERVED " }
        case 0xc19c + 0x012 { return "SYS_APLL.SYS_APLL_CTRL System APLL control register." }

        case 0xc1b0 + 0x000 { return "INPUT_0.IN_FREQ Input frequency in Hz." }
        case 0xc1b0 + 0x008 { return "INPUT_0.IN_DIV Input divider value." }
        case 0xc1b0 + 0x00A { return "INPUT_0.IN_PHASE Input phase offset configuration." }
        case 0xc1b0 + 0x00C { return "INPUT_0.IN_SYNC Frame pulse and sync pulse configuration." }
        case 0xc1b0 + 0x00D { return "RESERVED " }
        case 0xc1b0 + 0x00E { return "INPUT_0.IN_MODE_0 Input configuration 0" }
        case 0xc1b0 + 0x00F { return "INPUT_0.IN_MODE_1 Input configuration 1" }

        case 0xc1c0 + 0x000 { return "INPUT_1.IN_FREQ Input frequency in Hz." }
        case 0xc1c0 + 0x008 { return "INPUT_1.IN_DIV Input divider value." }
        case 0xc1c0 + 0x00A { return "INPUT_1.IN_PHASE Input phase offset configuration." }
        case 0xc1c0 + 0x00C { return "INPUT_1.IN_SYNC Frame pulse and sync pulse configuration." }
        case 0xc1c0 + 0x00D { return "RESERVED " }
        case 0xc1c0 + 0x00E { return "INPUT_1.IN_MODE_0 Input configuration 0" }
        case 0xc1c0 + 0x00F { return "INPUT_1.IN_MODE_1 Input configuration 1" }

        case 0xc1d0 + 0x000 { return "INPUT_2.IN_FREQ Input frequency in Hz." }
        case 0xc1d0 + 0x008 { return "INPUT_2.IN_DIV Input divider value." }
        case 0xc1d0 + 0x00A { return "INPUT_2.IN_PHASE Input phase offset configuration." }
        case 0xc1d0 + 0x00C { return "INPUT_2.IN_SYNC Frame pulse and sync pulse configuration." }
        case 0xc1d0 + 0x00D { return "RESERVED " }
        case 0xc1d0 + 0x00E { return "INPUT_2.IN_MODE_0 Input configuration 0" }
        case 0xc1d0 + 0x00F { return "INPUT_2.IN_MODE_1 Input configuration 1" }

        case 0xc200 + 0x000 { return "INPUT_3.IN_FREQ Input frequency in Hz." }
        case 0xc200 + 0x008 { return "INPUT_3.IN_DIV Input divider value." }
        case 0xc200 + 0x00A { return "INPUT_3.IN_PHASE Input phase offset configuration." }
        case 0xc200 + 0x00C { return "INPUT_3.IN_SYNC Frame pulse and sync pulse configuration." }
        case 0xc200 + 0x00D { return "RESERVED " }
        case 0xc200 + 0x00E { return "INPUT_3.IN_MODE_0 Input configuration 0" }
        case 0xc200 + 0x00F { return "INPUT_3.IN_MODE_1 Input configuration 1" }

        case 0xc210 + 0x000 { return "INPUT_4.IN_FREQ Input frequency in Hz." }
        case 0xc210 + 0x008 { return "INPUT_4.IN_DIV Input divider value." }
        case 0xc210 + 0x00A { return "INPUT_4.IN_PHASE Input phase offset configuration." }
        case 0xc210 + 0x00C { return "INPUT_4.IN_SYNC Frame pulse and sync pulse configuration." }
        case 0xc210 + 0x00D { return "RESERVED " }
        case 0xc210 + 0x00E { return "INPUT_4.IN_MODE_0 Input configuration 0" }
        case 0xc210 + 0x00F { return "INPUT_4.IN_MODE_1 Input configuration 1" }

        case 0xc220 + 0x000 { return "INPUT_5.IN_FREQ Input frequency in Hz." }
        case 0xc220 + 0x008 { return "INPUT_5.IN_DIV Input divider value." }
        case 0xc220 + 0x00A { return "INPUT_5.IN_PHASE Input phase offset configuration." }
        case 0xc220 + 0x00C { return "INPUT_5.IN_SYNC Frame pulse and sync pulse configuration." }
        case 0xc220 + 0x00D { return "RESERVED " }
        case 0xc220 + 0x00E { return "INPUT_5.IN_MODE_0 Input configuration 0" }
        case 0xc220 + 0x00F { return "INPUT_5.IN_MODE_1 Input configuration 1" }

        case 0xc230 + 0x000 { return "INPUT_6.IN_FREQ Input frequency in Hz." }
        case 0xc230 + 0x008 { return "INPUT_6.IN_DIV Input divider value." }
        case 0xc230 + 0x00A { return "INPUT_6.IN_PHASE Input phase offset configuration." }
        case 0xc230 + 0x00C { return "INPUT_6.IN_SYNC Frame pulse and sync pulse configuration." }
        case 0xc230 + 0x00D { return "RESERVED " }
        case 0xc230 + 0x00E { return "INPUT_6.IN_MODE_0 Input configuration 0" }
        case 0xc230 + 0x00F { return "INPUT_6.IN_MODE_1 Input configuration 1" }

        case 0xc240 + 0x000 { return "INPUT_7.IN_FREQ Input frequency in Hz." }
        case 0xc240 + 0x008 { return "INPUT_7.IN_DIV Input divider value." }
        case 0xc240 + 0x00A { return "INPUT_7.IN_PHASE Input phase offset configuration." }
        case 0xc240 + 0x00C { return "INPUT_7.IN_SYNC Frame pulse and sync pulse configuration." }
        case 0xc240 + 0x00D { return "RESERVED " }
        case 0xc240 + 0x00E { return "INPUT_7.IN_MODE_0 Input configuration 0" }
        case 0xc240 + 0x00F { return "INPUT_7.IN_MODE_1 Input configuration 1" }

        case 0xc250 + 0x000 { return "INPUT_8.IN_FREQ Input frequency in Hz." }
        case 0xc250 + 0x008 { return "INPUT_8.IN_DIV Input divider value." }
        case 0xc250 + 0x00A { return "INPUT_8.IN_PHASE Input phase offset configuration." }
        case 0xc250 + 0x00C { return "INPUT_8.IN_SYNC Frame pulse and sync pulse configuration." }
        case 0xc250 + 0x00D { return "RESERVED " }
        case 0xc250 + 0x00E { return "INPUT_8.IN_MODE_0 Input configuration 0" }
        case 0xc250 + 0x00F { return "INPUT_8.IN_MODE_1 Input configuration 1" }

        case 0xc260 + 0x000 { return "INPUT_9.IN_FREQ Input frequency in Hz." }
        case 0xc260 + 0x008 { return "INPUT_9.IN_DIV Input divider value." }
        case 0xc260 + 0x00A { return "INPUT_9.IN_PHASE Input phase offset configuration." }
        case 0xc260 + 0x00C { return "INPUT_9.IN_SYNC Frame pulse and sync pulse configuration." }
        case 0xc260 + 0x00D { return "RESERVED " }
        case 0xc260 + 0x00E { return "INPUT_9.IN_MODE_0 Input configuration 0" }
        case 0xc260 + 0x00F { return "INPUT_9.IN_MODE_1 Input configuration 1" }

        case 0xc280 + 0x000 { return "INPUT_10.IN_FREQ Input frequency in Hz." }
        case 0xc280 + 0x008 { return "INPUT_10.IN_DIV Input divider value." }
        case 0xc280 + 0x00A { return "INPUT_10.IN_PHASE Input phase offset configuration." }
        case 0xc280 + 0x00C { return "INPUT_10.IN_SYNC Frame pulse and sync pulse configuration." }
        case 0xc280 + 0x00D { return "RESERVED " }
        case 0xc280 + 0x00E { return "INPUT_10.IN_MODE_0 Input configuration 0" }
        case 0xc280 + 0x00F { return "INPUT_10.IN_MODE_1 Input configuration 1" }

        case 0xc290 + 0x000 { return "INPUT_11.IN_FREQ Input frequency in Hz." }
        case 0xc290 + 0x008 { return "INPUT_11.IN_DIV Input divider value." }
        case 0xc290 + 0x00A { return "INPUT_11.IN_PHASE Input phase offset configuration." }
        case 0xc290 + 0x00C { return "INPUT_11.IN_SYNC Frame pulse and sync pulse configuration." }
        case 0xc290 + 0x00D { return "RESERVED " }
        case 0xc290 + 0x00E { return "INPUT_11.IN_MODE_0 Input configuration 0" }
        case 0xc290 + 0x00F { return "INPUT_11.IN_MODE_1 Input configuration 1" }

        case 0xc2a0 + 0x000 { return "INPUT_12.IN_FREQ Input frequency in Hz." }
        case 0xc2a0 + 0x008 { return "INPUT_12.IN_DIV Input divider value." }
        case 0xc2a0 + 0x00A { return "INPUT_12.IN_PHASE Input phase offset configuration." }
        case 0xc2a0 + 0x00C { return "INPUT_12.IN_SYNC Frame pulse and sync pulse configuration." }
        case 0xc2a0 + 0x00D { return "RESERVED " }
        case 0xc2a0 + 0x00E { return "INPUT_12.IN_MODE_0 Input configuration 0" }
        case 0xc2a0 + 0x00F { return "INPUT_12.IN_MODE_1 Input configuration 1" }

        case 0xc2b0 + 0x000 { return "INPUT_13.IN_FREQ Input frequency in Hz." }
        case 0xc2b0 + 0x008 { return "INPUT_13.IN_DIV Input divider value." }
        case 0xc2b0 + 0x00A { return "INPUT_13.IN_PHASE Input phase offset configuration." }
        case 0xc2b0 + 0x00C { return "INPUT_13.IN_SYNC Frame pulse and sync pulse configuration." }
        case 0xc2b0 + 0x00D { return "RESERVED " }
        case 0xc2b0 + 0x00E { return "INPUT_13.IN_MODE_0 Input configuration 0" }
        case 0xc2b0 + 0x00F { return "INPUT_13.IN_MODE_1 Input configuration 1" }

        case 0xc2c0 + 0x000 { return "INPUT_14.IN_FREQ Input frequency in Hz." }
        case 0xc2c0 + 0x008 { return "INPUT_14.IN_DIV Input divider value." }
        case 0xc2c0 + 0x00A { return "INPUT_14.IN_PHASE Input phase offset configuration." }
        case 0xc2c0 + 0x00C { return "INPUT_14.IN_SYNC Frame pulse and sync pulse configuration." }
        case 0xc2c0 + 0x00D { return "RESERVED " }
        case 0xc2c0 + 0x00E { return "INPUT_14.IN_MODE_0 Input configuration 0" }
        case 0xc2c0 + 0x00F { return "INPUT_14.IN_MODE_1 Input configuration 1" }

        case 0xc2d0 + 0x000 { return "INPUT_15.IN_FREQ Input frequency in Hz." }
        case 0xc2d0 + 0x008 { return "INPUT_15.IN_DIV Input divider value." }
        case 0xc2d0 + 0x00A { return "INPUT_15.IN_PHASE Input phase offset configuration." }
        case 0xc2d0 + 0x00C { return "INPUT_15.IN_SYNC Frame pulse and sync pulse configuration." }
        case 0xc2d0 + 0x00D { return "RESERVED " }
        case 0xc2d0 + 0x00E { return "INPUT_15.IN_MODE_0 Input configuration 0" }
        case 0xc2d0 + 0x00F { return "INPUT_15.IN_MODE_1 Input configuration 1" }

        case 0xc2e0 + 0x000 { return "REF_MON_0.IN_MON_FREQ_CFG Reference monitor frequency configuration." }
        case 0xc2e0 + 0x001 { return "REF_MON_0.IN_MON_FREQ_VLD_INTV Frequency validation short interval." }
        case 0xc2e0 + 0x002 { return "REF_MON_0.IN_MON_TRANS_THRESHOLD Reference clock phase transient threshold." }
        case 0xc2e0 + 0x004 { return "REF_MON_0.IN_MON_TRANS_PERIOD Reference clock phase transient detection period." }
        case 0xc2e0 + 0x006 { return "REF_MON_0.IN_MON_ACT_CFG Activity limit, qualification and disqualification timers." }
        case 0xc2e0 + 0x008 { return "REF_MON_0.IN_MON_LOS_TOLERANCE Loss of signal tolerance configuration." }
        case 0xc2e0 + 0x00A { return "REF_MON_0.IN_MON_LOS_CFG Loss of signal configuration." }
        case 0xc2e0 + 0x00B { return "REF_MON_0.IN_MON_CFG Reference monitor configuration" }

        case 0xc2ec + 0x000 { return "REF_MON_1.IN_MON_FREQ_CFG Reference monitor frequency configuration." }
        case 0xc2ec + 0x001 { return "REF_MON_1.IN_MON_FREQ_VLD_INTV Frequency validation short interval." }
        case 0xc2ec + 0x002 { return "REF_MON_1.IN_MON_TRANS_THRESHOLD Reference clock phase transient threshold." }
        case 0xc2ec + 0x004 { return "REF_MON_1.IN_MON_TRANS_PERIOD Reference clock phase transient detection period." }
        case 0xc2ec + 0x006 { return "REF_MON_1.IN_MON_ACT_CFG Activity limit, qualification and disqualification timers." }
        case 0xc2ec + 0x008 { return "REF_MON_1.IN_MON_LOS_TOLERANCE Loss of signal tolerance configuration." }
        case 0xc2ec + 0x00A { return "REF_MON_1.IN_MON_LOS_CFG Loss of signal configuration." }
        case 0xc2ec + 0x00B { return "REF_MON_1.IN_MON_CFG Reference monitor configuration" }

        case 0xc300 + 0x000 { return "REF_MON_2.IN_MON_FREQ_CFG Reference monitor frequency configuration." }
        case 0xc300 + 0x001 { return "REF_MON_2.IN_MON_FREQ_VLD_INTV Frequency validation short interval." }
        case 0xc300 + 0x002 { return "REF_MON_2.IN_MON_TRANS_THRESHOLD Reference clock phase transient threshold." }
        case 0xc300 + 0x004 { return "REF_MON_2.IN_MON_TRANS_PERIOD Reference clock phase transient detection period." }
        case 0xc300 + 0x006 { return "REF_MON_2.IN_MON_ACT_CFG Activity limit, qualification and disqualification timers." }
        case 0xc300 + 0x008 { return "REF_MON_2.IN_MON_LOS_TOLERANCE Loss of signal tolerance configuration." }
        case 0xc300 + 0x00A { return "REF_MON_2.IN_MON_LOS_CFG Loss of signal configuration." }
        case 0xc300 + 0x00B { return "REF_MON_2.IN_MON_CFG Reference monitor configuration" }

        case 0xc30c + 0x000 { return "REF_MON_3.IN_MON_FREQ_CFG Reference monitor frequency configuration." }
        case 0xc30c + 0x001 { return "REF_MON_3.IN_MON_FREQ_VLD_INTV Frequency validation short interval." }
        case 0xc30c + 0x002 { return "REF_MON_3.IN_MON_TRANS_THRESHOLD Reference clock phase transient threshold." }
        case 0xc30c + 0x004 { return "REF_MON_3.IN_MON_TRANS_PERIOD Reference clock phase transient detection period." }
        case 0xc30c + 0x006 { return "REF_MON_3.IN_MON_ACT_CFG Activity limit, qualification and disqualification timers." }
        case 0xc30c + 0x008 { return "REF_MON_3.IN_MON_LOS_TOLERANCE Loss of signal tolerance configuration." }
        case 0xc30c + 0x00A { return "REF_MON_3.IN_MON_LOS_CFG Loss of signal configuration." }
        case 0xc30c + 0x00B { return "REF_MON_3.IN_MON_CFG Reference monitor configuration" }

        case 0xc318 + 0x000 { return "REF_MON_4.IN_MON_FREQ_CFG Reference monitor frequency configuration." }
        case 0xc318 + 0x001 { return "REF_MON_4.IN_MON_FREQ_VLD_INTV Frequency validation short interval." }
        case 0xc318 + 0x002 { return "REF_MON_4.IN_MON_TRANS_THRESHOLD Reference clock phase transient threshold." }
        case 0xc318 + 0x004 { return "REF_MON_4.IN_MON_TRANS_PERIOD Reference clock phase transient detection period." }
        case 0xc318 + 0x006 { return "REF_MON_4.IN_MON_ACT_CFG Activity limit, qualification and disqualification timers." }
        case 0xc318 + 0x008 { return "REF_MON_4.IN_MON_LOS_TOLERANCE Loss of signal tolerance configuration." }
        case 0xc318 + 0x00A { return "REF_MON_4.IN_MON_LOS_CFG Loss of signal configuration." }
        case 0xc318 + 0x00B { return "REF_MON_4.IN_MON_CFG Reference monitor configuration" }

        case 0xc324 + 0x000 { return "REF_MON_5.IN_MON_FREQ_CFG Reference monitor frequency configuration." }
        case 0xc324 + 0x001 { return "REF_MON_5.IN_MON_FREQ_VLD_INTV Frequency validation short interval." }
        case 0xc324 + 0x002 { return "REF_MON_5.IN_MON_TRANS_THRESHOLD Reference clock phase transient threshold." }
        case 0xc324 + 0x004 { return "REF_MON_5.IN_MON_TRANS_PERIOD Reference clock phase transient detection period." }
        case 0xc324 + 0x006 { return "REF_MON_5.IN_MON_ACT_CFG Activity limit, qualification and disqualification timers." }
        case 0xc324 + 0x008 { return "REF_MON_5.IN_MON_LOS_TOLERANCE Loss of signal tolerance configuration." }
        case 0xc324 + 0x00A { return "REF_MON_5.IN_MON_LOS_CFG Loss of signal configuration." }
        case 0xc324 + 0x00B { return "REF_MON_5.IN_MON_CFG Reference monitor configuration" }

        case 0xc330 + 0x000 { return "REF_MON_6.IN_MON_FREQ_CFG Reference monitor frequency configuration." }
        case 0xc330 + 0x001 { return "REF_MON_6.IN_MON_FREQ_VLD_INTV Frequency validation short interval." }
        case 0xc330 + 0x002 { return "REF_MON_6.IN_MON_TRANS_THRESHOLD Reference clock phase transient threshold." }
        case 0xc330 + 0x004 { return "REF_MON_6.IN_MON_TRANS_PERIOD Reference clock phase transient detection period." }
        case 0xc330 + 0x006 { return "REF_MON_6.IN_MON_ACT_CFG Activity limit, qualification and disqualification timers." }
        case 0xc330 + 0x008 { return "REF_MON_6.IN_MON_LOS_TOLERANCE Loss of signal tolerance configuration." }
        case 0xc330 + 0x00A { return "REF_MON_6.IN_MON_LOS_CFG Loss of signal configuration." }
        case 0xc330 + 0x00B { return "REF_MON_6.IN_MON_CFG Reference monitor configuration" }

        case 0xc33c + 0x000 { return "REF_MON_7.IN_MON_FREQ_CFG Reference monitor frequency configuration." }
        case 0xc33c + 0x001 { return "REF_MON_7.IN_MON_FREQ_VLD_INTV Frequency validation short interval." }
        case 0xc33c + 0x002 { return "REF_MON_7.IN_MON_TRANS_THRESHOLD Reference clock phase transient threshold." }
        case 0xc33c + 0x004 { return "REF_MON_7.IN_MON_TRANS_PERIOD Reference clock phase transient detection period." }
        case 0xc33c + 0x006 { return "REF_MON_7.IN_MON_ACT_CFG Activity limit, qualification and disqualification timers." }
        case 0xc33c + 0x008 { return "REF_MON_7.IN_MON_LOS_TOLERANCE Loss of signal tolerance configuration." }
        case 0xc33c + 0x00A { return "REF_MON_7.IN_MON_LOS_CFG Loss of signal configuration." }
        case 0xc33c + 0x00B { return "REF_MON_7.IN_MON_CFG Reference monitor configuration" }

        case 0xc348 + 0x000 { return "REF_MON_8.IN_MON_FREQ_CFG Reference monitor frequency configuration." }
        case 0xc348 + 0x001 { return "REF_MON_8.IN_MON_FREQ_VLD_INTV Frequency validation short interval." }
        case 0xc348 + 0x002 { return "REF_MON_8.IN_MON_TRANS_THRESHOLD Reference clock phase transient threshold." }
        case 0xc348 + 0x004 { return "REF_MON_8.IN_MON_TRANS_PERIOD Reference clock phase transient detection period." }
        case 0xc348 + 0x006 { return "REF_MON_8.IN_MON_ACT_CFG Activity limit, qualification and disqualification timers." }
        case 0xc348 + 0x008 { return "REF_MON_8.IN_MON_LOS_TOLERANCE Loss of signal tolerance configuration." }
        case 0xc348 + 0x00A { return "REF_MON_8.IN_MON_LOS_CFG Loss of signal configuration." }
        case 0xc348 + 0x00B { return "REF_MON_8.IN_MON_CFG Reference monitor configuration" }

        case 0xc354 + 0x000 { return "REF_MON_9.IN_MON_FREQ_CFG Reference monitor frequency configuration." }
        case 0xc354 + 0x001 { return "REF_MON_9.IN_MON_FREQ_VLD_INTV Frequency validation short interval." }
        case 0xc354 + 0x002 { return "REF_MON_9.IN_MON_TRANS_THRESHOLD Reference clock phase transient threshold." }
        case 0xc354 + 0x004 { return "REF_MON_9.IN_MON_TRANS_PERIOD Reference clock phase transient detection period." }
        case 0xc354 + 0x006 { return "REF_MON_9.IN_MON_ACT_CFG Activity limit, qualification and disqualification timers." }
        case 0xc354 + 0x008 { return "REF_MON_9.IN_MON_LOS_TOLERANCE Loss of signal tolerance configuration." }
        case 0xc354 + 0x00A { return "REF_MON_9.IN_MON_LOS_CFG Loss of signal configuration." }
        case 0xc354 + 0x00B { return "REF_MON_9.IN_MON_CFG Reference monitor configuration" }

        case 0xc360 + 0x000 { return "REF_MON_10.IN_MON_FREQ_CFG Reference monitor frequency configuration." }
        case 0xc360 + 0x001 { return "REF_MON_10.IN_MON_FREQ_VLD_INTV Frequency validation short interval." }
        case 0xc360 + 0x002 { return "REF_MON_10.IN_MON_TRANS_THRESHOLD Reference clock phase transient threshold." }
        case 0xc360 + 0x004 { return "REF_MON_10.IN_MON_TRANS_PERIOD Reference clock phase transient detection period." }
        case 0xc360 + 0x006 { return "REF_MON_10.IN_MON_ACT_CFG Activity limit, qualification and disqualification timers." }
        case 0xc360 + 0x008 { return "REF_MON_10.IN_MON_LOS_TOLERANCE Loss of signal tolerance configuration." }
        case 0xc360 + 0x00A { return "REF_MON_10.IN_MON_LOS_CFG Loss of signal configuration." }
        case 0xc360 + 0x00B { return "REF_MON_10.IN_MON_CFG Reference monitor configuration" }

        case 0xc36c + 0x000 { return "REF_MON_11.IN_MON_FREQ_CFG Reference monitor frequency configuration." }
        case 0xc36c + 0x001 { return "REF_MON_11.IN_MON_FREQ_VLD_INTV Frequency validation short interval." }
        case 0xc36c + 0x002 { return "REF_MON_11.IN_MON_TRANS_THRESHOLD Reference clock phase transient threshold." }
        case 0xc36c + 0x004 { return "REF_MON_11.IN_MON_TRANS_PERIOD Reference clock phase transient detection period." }
        case 0xc36c + 0x006 { return "REF_MON_11.IN_MON_ACT_CFG Activity limit, qualification and disqualification timers." }
        case 0xc36c + 0x008 { return "REF_MON_11.IN_MON_LOS_TOLERANCE Loss of signal tolerance configuration." }
        case 0xc36c + 0x00A { return "REF_MON_11.IN_MON_LOS_CFG Loss of signal configuration." }
        case 0xc36c + 0x00B { return "REF_MON_11.IN_MON_CFG Reference monitor configuration" }

        case 0xc380 + 0x000 { return "REF_MON_12.IN_MON_FREQ_CFG Reference monitor frequency configuration." }
        case 0xc380 + 0x001 { return "REF_MON_12.IN_MON_FREQ_VLD_INTV Frequency validation short interval." }
        case 0xc380 + 0x002 { return "REF_MON_12.IN_MON_TRANS_THRESHOLD Reference clock phase transient threshold." }
        case 0xc380 + 0x004 { return "REF_MON_12.IN_MON_TRANS_PERIOD Reference clock phase transient detection period." }
        case 0xc380 + 0x006 { return "REF_MON_12.IN_MON_ACT_CFG Activity limit, qualification and disqualification timers." }
        case 0xc380 + 0x008 { return "REF_MON_12.IN_MON_LOS_TOLERANCE Loss of signal tolerance configuration." }
        case 0xc380 + 0x00A { return "REF_MON_12.IN_MON_LOS_CFG Loss of signal configuration." }
        case 0xc380 + 0x00B { return "REF_MON_12.IN_MON_CFG Reference monitor configuration" }

        case 0xc38c + 0x000 { return "REF_MON_13.IN_MON_FREQ_CFG Reference monitor frequency configuration." }
        case 0xc38c + 0x001 { return "REF_MON_13.IN_MON_FREQ_VLD_INTV Frequency validation short interval." }
        case 0xc38c + 0x002 { return "REF_MON_13.IN_MON_TRANS_THRESHOLD Reference clock phase transient threshold." }
        case 0xc38c + 0x004 { return "REF_MON_13.IN_MON_TRANS_PERIOD Reference clock phase transient detection period." }
        case 0xc38c + 0x006 { return "REF_MON_13.IN_MON_ACT_CFG Activity limit, qualification and disqualification timers." }
        case 0xc38c + 0x008 { return "REF_MON_13.IN_MON_LOS_TOLERANCE Loss of signal tolerance configuration." }
        case 0xc38c + 0x00A { return "REF_MON_13.IN_MON_LOS_CFG Loss of signal configuration." }
        case 0xc38c + 0x00B { return "REF_MON_13.IN_MON_CFG Reference monitor configuration" }

        case 0xc398 + 0x000 { return "REF_MON_14.IN_MON_FREQ_CFG Reference monitor frequency configuration." }
        case 0xc398 + 0x001 { return "REF_MON_14.IN_MON_FREQ_VLD_INTV Frequency validation short interval." }
        case 0xc398 + 0x002 { return "REF_MON_14.IN_MON_TRANS_THRESHOLD Reference clock phase transient threshold." }
        case 0xc398 + 0x004 { return "REF_MON_14.IN_MON_TRANS_PERIOD Reference clock phase transient detection period." }
        case 0xc398 + 0x006 { return "REF_MON_14.IN_MON_ACT_CFG Activity limit, qualification and disqualification timers." }
        case 0xc398 + 0x008 { return "REF_MON_14.IN_MON_LOS_TOLERANCE Loss of signal tolerance configuration." }
        case 0xc398 + 0x00A { return "REF_MON_14.IN_MON_LOS_CFG Loss of signal configuration." }
        case 0xc398 + 0x00B { return "REF_MON_14.IN_MON_CFG Reference monitor configuration" }

        case 0xc3a4 + 0x000 { return "REF_MON_15.IN_MON_FREQ_CFG Reference monitor frequency configuration." }
        case 0xc3a4 + 0x001 { return "REF_MON_15.IN_MON_FREQ_VLD_INTV Frequency validation short interval." }
        case 0xc3a4 + 0x002 { return "REF_MON_15.IN_MON_TRANS_THRESHOLD Reference clock phase transient threshold." }
        case 0xc3a4 + 0x004 { return "REF_MON_15.IN_MON_TRANS_PERIOD Reference clock phase transient detection period." }
        case 0xc3a4 + 0x006 { return "REF_MON_15.IN_MON_ACT_CFG Activity limit, qualification and disqualification timers." }
        case 0xc3a4 + 0x008 { return "REF_MON_15.IN_MON_LOS_TOLERANCE Loss of signal tolerance configuration." }
        case 0xc3a4 + 0x00A { return "REF_MON_15.IN_MON_LOS_CFG Loss of signal configuration." }
        case 0xc3a4 + 0x00B { return "REF_MON_15.IN_MON_CFG Reference monitor configuration" }

        case 0xc3b0 + 0x000 { return "DPLL_0.DPLL_DCO_INC_DEC_SIZE Configure frequency step size for GPIO increment/decrement mode." }
        case 0xc3b0 + 0x002 { return "DPLL_0.DPLL_CTRL_0 Reference switching configuration and forced lock reference selection." }
        case 0xc3b0 + 0x003 { return "DPLL_0.DPLL_CTRL_1 Configure other hitless switch features and DPLL feedback as a reference." }
        case 0xc3b0 + 0x004 { return "DPLL_0.DPLL_CTRL_2 External feedback and frame/sync pulse configuration." }
        case 0xc3b0 + 0x005 { return "DPLL_0.DPLL_CTRL_3 Configure DPLL loop filter update rate and maximum number of fast lock retry" }
        case 0xc3b0 + 0x006 { return "DPLL_0.DPLL_FILTER_STATUS_UPDATE_CFG DPLL loop filter status update configuration." }
        case 0xc3b0 + 0x007 { return "DPLL_0.DPLL_HO_ADVCD_HISTORY Advanced holdover history configuration." }
        case 0xc3b0 + 0x008 { return "DPLL_0.DPLL_HO_ADVCD_BW DPLL advanced holdover bandwidth configuration." }
        case 0xc3b0 + 0x00A { return "DPLL_0.DPLL_HO_CFG Holdover configuration." }
        case 0xc3b0 + 0x00B { return "DPLL_0.DPLL_LOCK_0 Phase lock threshold." }
        case 0xc3b0 + 0x00C { return "DPLL_0.DPLL_LOCK_1 Phase lock monitor duration." }
        case 0xc3b0 + 0x00D { return "DPLL_0.DPLL_LOCK_2 Frequency lock threshold." }
        case 0xc3b0 + 0x00E { return "DPLL_0.DPLL_LOCK_3 Frequency lock monitor duration." }
        case 0xc3b0 + 0x00F { return "DPLL_0.DPLL_REF_PRIORITY_0 Select input for highest (0) priority." }
        case 0xc3b0 + 0x010 { return "DPLL_0.DPLL_REF_PRIORITY_1 Select input for priority 1." }
        case 0xc3b0 + 0x011 { return "DPLL_0.DPLL_REF_PRIORITY_2 Select input for priority 2." }
        case 0xc3b0 + 0x012 { return "DPLL_0.DPLL_REF_PRIORITY_3 Select input for priority 3." }
        case 0xc3b0 + 0x013 { return "DPLL_0.DPLL_REF_PRIORITY_4 Select input for priority 4." }
        case 0xc3b0 + 0x014 { return "DPLL_0.DPLL_REF_PRIORITY_5 Select input for priority 5." }
        case 0xc3b0 + 0x015 { return "DPLL_0.DPLL_REF_PRIORITY_6 Select input for priority 6." }
        case 0xc3b0 + 0x016 { return "DPLL_0.DPLL_REF_PRIORITY_7 Select input for priority 7." }
        case 0xc3b0 + 0x017 { return "DPLL_0.DPLL_REF_PRIORITY_8 Select input for priority 8." }
        case 0xc3b0 + 0x018 { return "DPLL_0.DPLL_REF_PRIORITY_9 Select input for priority 9." }
        case 0xc3b0 + 0x019 { return "DPLL_0.DPLL_REF_PRIORITY_10 Select input for priority 10." }
        case 0xc3b0 + 0x01A { return "DPLL_0.DPLL_REF_PRIORITY_11 Select input for priority 11." }
        case 0xc3b0 + 0x01B { return "DPLL_0.DPLL_REF_PRIORITY_12 Select input for priority 12." }
        case 0xc3b0 + 0x01C { return "DPLL_0.DPLL_REF_PRIORITY_13 Select input for priority 13." }
        case 0xc3b0 + 0x01D { return "DPLL_0.DPLL_REF_PRIORITY_14 Select input for priority 14." }
        case 0xc3b0 + 0x01E { return "DPLL_0.DPLL_REF_PRIORITY_15 Select input for priority 15." }
        case 0xc3b0 + 0x01F { return "DPLL_0.DPLL_REF_PRIORITY_16 Select input for priority 16." }
        case 0xc3b0 + 0x020 { return "DPLL_0.DPLL_REF_PRIORITY_17 Select input for priority 17." }
        case 0xc3b0 + 0x021 { return "DPLL_0.DPLL_REF_PRIORITY_18 Select input for priority 18." }
        case 0xc3b0 + 0x022 { return "DPLL_0.DPLL_TRANS_CTRL Phase transient configuration." }
        case 0xc3b0 + 0x023 { return "DPLL_0.DPLL_FASTLOCK_CFG_0 Fast lock configuration." }
        case 0xc3b0 + 0x024 { return "DPLL_0.DPLL_FASTLOCK_CFG_1 Fast lock configuration." }
        case 0xc3b0 + 0x025 { return "DPLL_0.DPLL_MAX_FREQ_OFFSET DPLL maximum frequency offset limit." }
        case 0xc3b0 + 0x026 { return "DPLL_0.DPLL_FASTLOCK_PSL Fast lock phase slope limit." }
        case 0xc3b0 + 0x028 { return "DPLL_0.DPLL_FASTLOCK_FSL Fast lock frequency slope limit." }
        case 0xc3b0 + 0x02A { return "DPLL_0.DPLL_FASTLOCK_BW Fast lock loop filter bandwidth." }
        case 0xc3b0 + 0x02C { return "DPLL_0.DPLL_WRITE_FREQ_TIMER Write frequency timer." }
        case 0xc3b0 + 0x02E { return "DPLL_0.DPLL_WRITE_PHASE_TIMER Write phase timer." }
        case 0xc3b0 + 0x030 { return "DPLL_0.DPLL_PRED_CFG Predefined configuration selection." }
        case 0xc3b0 + 0x031 { return "DPLL_0.DPLL_TOD_SYNC_CFG DPLL ToD synchronization configuration." }
        case 0xc3b0 + 0x032 { return "DPLL_0.DPLL_COMBO_SLAVE_CFG_0 Combo mode slave primary source configuration." }
        case 0xc3b0 + 0x033 { return "DPLL_0.DPLL_COMBO_SLAVE_CFG_1 Combo mode slave secondary source configuration." }
        case 0xc3b0 + 0x034 { return "DPLL_0.DPLL_SLAVE_REF_CFG Slave mode configuration." }
        case 0xc3b0 + 0x035 { return "DPLL_0.DPLL_REF_MODE Reference selection configuration and XO DPLL monitor enable." }
        case 0xc3b0 + 0x036 { return "DPLL_0.DPLL_PHASE_MEASUREMENT_CFG Phase measurement mode configuration." }
        case 0xc3b0 + 0x037 { return "DPLL_0.DPLL_FASTLOCK_FREQ_SNAP_WINDOW Fastlock frequency snap window." }
        case 0xc3b0 + 0x038 { return "DPLL_0.DPLL_FASTLOCK_PHASE_PULL_IN_AND_FAST_ACQ_WINDOW Fastlock phase pull-in and fast-acquisition window." }
        case 0xc3b0 + 0x039 { return "DPLL_0.DPLL_FASTLOCK_PHASE_SNAP_WINDOW Fastlock phase snap window." }
        case 0xc3b0 + 0x03A { return "DPLL_0.DPLL_SINGLE_PULSE_SYNC_CFG Single pulse synchronization configuration." }
        case 0xc3b0 + 0x03B { return "DPLL_0.DPLL_MODE DPLL operating modes." }

        case 0xc400 + 0x000 { return "DPLL_1.DPLL_DCO_INC_DEC_SIZE Configure frequency step size for GPIO increment/decrement mode." }
        case 0xc400 + 0x002 { return "DPLL_1.DPLL_CTRL_0 Reference switching configuration and forced lock reference selection." }
        case 0xc400 + 0x003 { return "DPLL_1.DPLL_CTRL_1 Configure other hitless switch features and DPLL feedback as a reference." }
        case 0xc400 + 0x004 { return "DPLL_1.DPLL_CTRL_2 External feedback and frame/sync pulse configuration." }
        case 0xc400 + 0x005 { return "DPLL_1.DPLL_CTRL_3 Configure DPLL loop filter update rate and maximum number of fast lock retry" }
        case 0xc400 + 0x006 { return "DPLL_1.DPLL_FILTER_STATUS_UPDATE_CFG DPLL loop filter status update configuration." }
        case 0xc400 + 0x007 { return "DPLL_1.DPLL_HO_ADVCD_HISTORY Advanced holdover history configuration." }
        case 0xc400 + 0x008 { return "DPLL_1.DPLL_HO_ADVCD_BW DPLL advanced holdover bandwidth configuration." }
        case 0xc400 + 0x00A { return "DPLL_1.DPLL_HO_CFG Holdover configuration." }
        case 0xc400 + 0x00B { return "DPLL_1.DPLL_LOCK_0 Phase lock threshold." }
        case 0xc400 + 0x00C { return "DPLL_1.DPLL_LOCK_1 Phase lock monitor duration." }
        case 0xc400 + 0x00D { return "DPLL_1.DPLL_LOCK_2 Frequency lock threshold." }
        case 0xc400 + 0x00E { return "DPLL_1.DPLL_LOCK_3 Frequency lock monitor duration." }
        case 0xc400 + 0x00F { return "DPLL_1.DPLL_REF_PRIORITY_0 Select input for highest (0) priority." }
        case 0xc400 + 0x010 { return "DPLL_1.DPLL_REF_PRIORITY_1 Select input for priority 1." }
        case 0xc400 + 0x011 { return "DPLL_1.DPLL_REF_PRIORITY_2 Select input for priority 2." }
        case 0xc400 + 0x012 { return "DPLL_1.DPLL_REF_PRIORITY_3 Select input for priority 3." }
        case 0xc400 + 0x013 { return "DPLL_1.DPLL_REF_PRIORITY_4 Select input for priority 4." }
        case 0xc400 + 0x014 { return "DPLL_1.DPLL_REF_PRIORITY_5 Select input for priority 5." }
        case 0xc400 + 0x015 { return "DPLL_1.DPLL_REF_PRIORITY_6 Select input for priority 6." }
        case 0xc400 + 0x016 { return "DPLL_1.DPLL_REF_PRIORITY_7 Select input for priority 7." }
        case 0xc400 + 0x017 { return "DPLL_1.DPLL_REF_PRIORITY_8 Select input for priority 8." }
        case 0xc400 + 0x018 { return "DPLL_1.DPLL_REF_PRIORITY_9 Select input for priority 9." }
        case 0xc400 + 0x019 { return "DPLL_1.DPLL_REF_PRIORITY_10 Select input for priority 10." }
        case 0xc400 + 0x01A { return "DPLL_1.DPLL_REF_PRIORITY_11 Select input for priority 11." }
        case 0xc400 + 0x01B { return "DPLL_1.DPLL_REF_PRIORITY_12 Select input for priority 12." }
        case 0xc400 + 0x01C { return "DPLL_1.DPLL_REF_PRIORITY_13 Select input for priority 13." }
        case 0xc400 + 0x01D { return "DPLL_1.DPLL_REF_PRIORITY_14 Select input for priority 14." }
        case 0xc400 + 0x01E { return "DPLL_1.DPLL_REF_PRIORITY_15 Select input for priority 15." }
        case 0xc400 + 0x01F { return "DPLL_1.DPLL_REF_PRIORITY_16 Select input for priority 16." }
        case 0xc400 + 0x020 { return "DPLL_1.DPLL_REF_PRIORITY_17 Select input for priority 17." }
        case 0xc400 + 0x021 { return "DPLL_1.DPLL_REF_PRIORITY_18 Select input for priority 18." }
        case 0xc400 + 0x022 { return "DPLL_1.DPLL_TRANS_CTRL Phase transient configuration." }
        case 0xc400 + 0x023 { return "DPLL_1.DPLL_FASTLOCK_CFG_0 Fast lock configuration." }
        case 0xc400 + 0x024 { return "DPLL_1.DPLL_FASTLOCK_CFG_1 Fast lock configuration." }
        case 0xc400 + 0x025 { return "DPLL_1.DPLL_MAX_FREQ_OFFSET DPLL maximum frequency offset limit." }
        case 0xc400 + 0x026 { return "DPLL_1.DPLL_FASTLOCK_PSL Fast lock phase slope limit." }
        case 0xc400 + 0x028 { return "DPLL_1.DPLL_FASTLOCK_FSL Fast lock frequency slope limit." }
        case 0xc400 + 0x02A { return "DPLL_1.DPLL_FASTLOCK_BW Fast lock loop filter bandwidth." }
        case 0xc400 + 0x02C { return "DPLL_1.DPLL_WRITE_FREQ_TIMER Write frequency timer." }
        case 0xc400 + 0x02E { return "DPLL_1.DPLL_WRITE_PHASE_TIMER Write phase timer." }
        case 0xc400 + 0x030 { return "DPLL_1.DPLL_PRED_CFG Predefined configuration selection." }
        case 0xc400 + 0x031 { return "DPLL_1.DPLL_TOD_SYNC_CFG DPLL ToD synchronization configuration." }
        case 0xc400 + 0x032 { return "DPLL_1.DPLL_COMBO_SLAVE_CFG_0 Combo mode slave primary source configuration." }
        case 0xc400 + 0x033 { return "DPLL_1.DPLL_COMBO_SLAVE_CFG_1 Combo mode slave secondary source configuration." }
        case 0xc400 + 0x034 { return "DPLL_1.DPLL_SLAVE_REF_CFG Slave mode configuration." }
        case 0xc400 + 0x035 { return "DPLL_1.DPLL_REF_MODE Reference selection configuration and XO DPLL monitor enable." }
        case 0xc400 + 0x036 { return "DPLL_1.DPLL_PHASE_MEASUREMENT_CFG Phase measurement mode configuration." }
        case 0xc400 + 0x037 { return "DPLL_1.DPLL_FASTLOCK_FREQ_SNAP_WINDOW Fastlock frequency snap window." }
        case 0xc400 + 0x038 { return "DPLL_1.DPLL_FASTLOCK_PHASE_PULL_IN_AND_FAST_ACQ_WINDOW Fastlock phase pull-in and fast-acquisition window." }
        case 0xc400 + 0x039 { return "DPLL_1.DPLL_FASTLOCK_PHASE_SNAP_WINDOW Fastlock phase snap window." }
        case 0xc400 + 0x03A { return "DPLL_1.DPLL_SINGLE_PULSE_SYNC_CFG Single pulse synchronization configuration." }
        case 0xc400 + 0x03B { return "DPLL_1.DPLL_MODE DPLL operating modes." }

        case 0xc43c + 0x000 { return "DPLL_2.DPLL_DCO_INC_DEC_SIZE Configure frequency step size for GPIO increment/decrement mode." }
        case 0xc43c + 0x002 { return "DPLL_2.DPLL_CTRL_0 Reference switching configuration and forced lock reference selection." }
        case 0xc43c + 0x003 { return "DPLL_2.DPLL_CTRL_1 Configure other hitless switch features and DPLL feedback as a reference." }
        case 0xc43c + 0x004 { return "DPLL_2.DPLL_CTRL_2 External feedback and frame/sync pulse configuration." }
        case 0xc43c + 0x005 { return "DPLL_2.DPLL_CTRL_3 Configure DPLL loop filter update rate and maximum number of fast lock retry" }
        case 0xc43c + 0x006 { return "DPLL_2.DPLL_FILTER_STATUS_UPDATE_CFG DPLL loop filter status update configuration." }
        case 0xc43c + 0x007 { return "DPLL_2.DPLL_HO_ADVCD_HISTORY Advanced holdover history configuration." }
        case 0xc43c + 0x008 { return "DPLL_2.DPLL_HO_ADVCD_BW DPLL advanced holdover bandwidth configuration." }
        case 0xc43c + 0x00A { return "DPLL_2.DPLL_HO_CFG Holdover configuration." }
        case 0xc43c + 0x00B { return "DPLL_2.DPLL_LOCK_0 Phase lock threshold." }
        case 0xc43c + 0x00C { return "DPLL_2.DPLL_LOCK_1 Phase lock monitor duration." }
        case 0xc43c + 0x00D { return "DPLL_2.DPLL_LOCK_2 Frequency lock threshold." }
        case 0xc43c + 0x00E { return "DPLL_2.DPLL_LOCK_3 Frequency lock monitor duration." }
        case 0xc43c + 0x00F { return "DPLL_2.DPLL_REF_PRIORITY_0 Select input for highest (0) priority." }
        case 0xc43c + 0x010 { return "DPLL_2.DPLL_REF_PRIORITY_1 Select input for priority 1." }
        case 0xc43c + 0x011 { return "DPLL_2.DPLL_REF_PRIORITY_2 Select input for priority 2." }
        case 0xc43c + 0x012 { return "DPLL_2.DPLL_REF_PRIORITY_3 Select input for priority 3." }
        case 0xc43c + 0x013 { return "DPLL_2.DPLL_REF_PRIORITY_4 Select input for priority 4." }
        case 0xc43c + 0x014 { return "DPLL_2.DPLL_REF_PRIORITY_5 Select input for priority 5." }
        case 0xc43c + 0x015 { return "DPLL_2.DPLL_REF_PRIORITY_6 Select input for priority 6." }
        case 0xc43c + 0x016 { return "DPLL_2.DPLL_REF_PRIORITY_7 Select input for priority 7." }
        case 0xc43c + 0x017 { return "DPLL_2.DPLL_REF_PRIORITY_8 Select input for priority 8." }
        case 0xc43c + 0x018 { return "DPLL_2.DPLL_REF_PRIORITY_9 Select input for priority 9." }
        case 0xc43c + 0x019 { return "DPLL_2.DPLL_REF_PRIORITY_10 Select input for priority 10." }
        case 0xc43c + 0x01A { return "DPLL_2.DPLL_REF_PRIORITY_11 Select input for priority 11." }
        case 0xc43c + 0x01B { return "DPLL_2.DPLL_REF_PRIORITY_12 Select input for priority 12." }
        case 0xc43c + 0x01C { return "DPLL_2.DPLL_REF_PRIORITY_13 Select input for priority 13." }
        case 0xc43c + 0x01D { return "DPLL_2.DPLL_REF_PRIORITY_14 Select input for priority 14." }
        case 0xc43c + 0x01E { return "DPLL_2.DPLL_REF_PRIORITY_15 Select input for priority 15." }
        case 0xc43c + 0x01F { return "DPLL_2.DPLL_REF_PRIORITY_16 Select input for priority 16." }
        case 0xc43c + 0x020 { return "DPLL_2.DPLL_REF_PRIORITY_17 Select input for priority 17." }
        case 0xc43c + 0x021 { return "DPLL_2.DPLL_REF_PRIORITY_18 Select input for priority 18." }
        case 0xc43c + 0x022 { return "DPLL_2.DPLL_TRANS_CTRL Phase transient configuration." }
        case 0xc43c + 0x023 { return "DPLL_2.DPLL_FASTLOCK_CFG_0 Fast lock configuration." }
        case 0xc43c + 0x024 { return "DPLL_2.DPLL_FASTLOCK_CFG_1 Fast lock configuration." }
        case 0xc43c + 0x025 { return "DPLL_2.DPLL_MAX_FREQ_OFFSET DPLL maximum frequency offset limit." }
        case 0xc43c + 0x026 { return "DPLL_2.DPLL_FASTLOCK_PSL Fast lock phase slope limit." }
        case 0xc43c + 0x028 { return "DPLL_2.DPLL_FASTLOCK_FSL Fast lock frequency slope limit." }
        case 0xc43c + 0x02A { return "DPLL_2.DPLL_FASTLOCK_BW Fast lock loop filter bandwidth." }
        case 0xc43c + 0x02C { return "DPLL_2.DPLL_WRITE_FREQ_TIMER Write frequency timer." }
        case 0xc43c + 0x02E { return "DPLL_2.DPLL_WRITE_PHASE_TIMER Write phase timer." }
        case 0xc43c + 0x030 { return "DPLL_2.DPLL_PRED_CFG Predefined configuration selection." }
        case 0xc43c + 0x031 { return "DPLL_2.DPLL_TOD_SYNC_CFG DPLL ToD synchronization configuration." }
        case 0xc43c + 0x032 { return "DPLL_2.DPLL_COMBO_SLAVE_CFG_0 Combo mode slave primary source configuration." }
        case 0xc43c + 0x033 { return "DPLL_2.DPLL_COMBO_SLAVE_CFG_1 Combo mode slave secondary source configuration." }
        case 0xc43c + 0x034 { return "DPLL_2.DPLL_SLAVE_REF_CFG Slave mode configuration." }
        case 0xc43c + 0x035 { return "DPLL_2.DPLL_REF_MODE Reference selection configuration and XO DPLL monitor enable." }
        case 0xc43c + 0x036 { return "DPLL_2.DPLL_PHASE_MEASUREMENT_CFG Phase measurement mode configuration." }
        case 0xc43c + 0x037 { return "DPLL_2.DPLL_FASTLOCK_FREQ_SNAP_WINDOW Fastlock frequency snap window." }
        case 0xc43c + 0x038 { return "DPLL_2.DPLL_FASTLOCK_PHASE_PULL_IN_AND_FAST_ACQ_WINDOW Fastlock phase pull-in and fast-acquisition window." }
        case 0xc43c + 0x039 { return "DPLL_2.DPLL_FASTLOCK_PHASE_SNAP_WINDOW Fastlock phase snap window." }
        case 0xc43c + 0x03A { return "DPLL_2.DPLL_SINGLE_PULSE_SYNC_CFG Single pulse synchronization configuration." }
        case 0xc43c + 0x03B { return "DPLL_2.DPLL_MODE DPLL operating modes." }

        case 0xc480 + 0x000 { return "DPLL_3.DPLL_DCO_INC_DEC_SIZE Configure frequency step size for GPIO increment/decrement mode." }
        case 0xc480 + 0x002 { return "DPLL_3.DPLL_CTRL_0 Reference switching configuration and forced lock reference selection." }
        case 0xc480 + 0x003 { return "DPLL_3.DPLL_CTRL_1 Configure other hitless switch features and DPLL feedback as a reference." }
        case 0xc480 + 0x004 { return "DPLL_3.DPLL_CTRL_2 External feedback and frame/sync pulse configuration." }
        case 0xc480 + 0x005 { return "DPLL_3.DPLL_CTRL_3 Configure DPLL loop filter update rate and maximum number of fast lock retry" }
        case 0xc480 + 0x006 { return "DPLL_3.DPLL_FILTER_STATUS_UPDATE_CFG DPLL loop filter status update configuration." }
        case 0xc480 + 0x007 { return "DPLL_3.DPLL_HO_ADVCD_HISTORY Advanced holdover history configuration." }
        case 0xc480 + 0x008 { return "DPLL_3.DPLL_HO_ADVCD_BW DPLL advanced holdover bandwidth configuration." }
        case 0xc480 + 0x00A { return "DPLL_3.DPLL_HO_CFG Holdover configuration." }
        case 0xc480 + 0x00B { return "DPLL_3.DPLL_LOCK_0 Phase lock threshold." }
        case 0xc480 + 0x00C { return "DPLL_3.DPLL_LOCK_1 Phase lock monitor duration." }
        case 0xc480 + 0x00D { return "DPLL_3.DPLL_LOCK_2 Frequency lock threshold." }
        case 0xc480 + 0x00E { return "DPLL_3.DPLL_LOCK_3 Frequency lock monitor duration." }
        case 0xc480 + 0x00F { return "DPLL_3.DPLL_REF_PRIORITY_0 Select input for highest (0) priority." }
        case 0xc480 + 0x010 { return "DPLL_3.DPLL_REF_PRIORITY_1 Select input for priority 1." }
        case 0xc480 + 0x011 { return "DPLL_3.DPLL_REF_PRIORITY_2 Select input for priority 2." }
        case 0xc480 + 0x012 { return "DPLL_3.DPLL_REF_PRIORITY_3 Select input for priority 3." }
        case 0xc480 + 0x013 { return "DPLL_3.DPLL_REF_PRIORITY_4 Select input for priority 4." }
        case 0xc480 + 0x014 { return "DPLL_3.DPLL_REF_PRIORITY_5 Select input for priority 5." }
        case 0xc480 + 0x015 { return "DPLL_3.DPLL_REF_PRIORITY_6 Select input for priority 6." }
        case 0xc480 + 0x016 { return "DPLL_3.DPLL_REF_PRIORITY_7 Select input for priority 7." }
        case 0xc480 + 0x017 { return "DPLL_3.DPLL_REF_PRIORITY_8 Select input for priority 8." }
        case 0xc480 + 0x018 { return "DPLL_3.DPLL_REF_PRIORITY_9 Select input for priority 9." }
        case 0xc480 + 0x019 { return "DPLL_3.DPLL_REF_PRIORITY_10 Select input for priority 10." }
        case 0xc480 + 0x01A { return "DPLL_3.DPLL_REF_PRIORITY_11 Select input for priority 11." }
        case 0xc480 + 0x01B { return "DPLL_3.DPLL_REF_PRIORITY_12 Select input for priority 12." }
        case 0xc480 + 0x01C { return "DPLL_3.DPLL_REF_PRIORITY_13 Select input for priority 13." }
        case 0xc480 + 0x01D { return "DPLL_3.DPLL_REF_PRIORITY_14 Select input for priority 14." }
        case 0xc480 + 0x01E { return "DPLL_3.DPLL_REF_PRIORITY_15 Select input for priority 15." }
        case 0xc480 + 0x01F { return "DPLL_3.DPLL_REF_PRIORITY_16 Select input for priority 16." }
        case 0xc480 + 0x020 { return "DPLL_3.DPLL_REF_PRIORITY_17 Select input for priority 17." }
        case 0xc480 + 0x021 { return "DPLL_3.DPLL_REF_PRIORITY_18 Select input for priority 18." }
        case 0xc480 + 0x022 { return "DPLL_3.DPLL_TRANS_CTRL Phase transient configuration." }
        case 0xc480 + 0x023 { return "DPLL_3.DPLL_FASTLOCK_CFG_0 Fast lock configuration." }
        case 0xc480 + 0x024 { return "DPLL_3.DPLL_FASTLOCK_CFG_1 Fast lock configuration." }
        case 0xc480 + 0x025 { return "DPLL_3.DPLL_MAX_FREQ_OFFSET DPLL maximum frequency offset limit." }
        case 0xc480 + 0x026 { return "DPLL_3.DPLL_FASTLOCK_PSL Fast lock phase slope limit." }
        case 0xc480 + 0x028 { return "DPLL_3.DPLL_FASTLOCK_FSL Fast lock frequency slope limit." }
        case 0xc480 + 0x02A { return "DPLL_3.DPLL_FASTLOCK_BW Fast lock loop filter bandwidth." }
        case 0xc480 + 0x02C { return "DPLL_3.DPLL_WRITE_FREQ_TIMER Write frequency timer." }
        case 0xc480 + 0x02E { return "DPLL_3.DPLL_WRITE_PHASE_TIMER Write phase timer." }
        case 0xc480 + 0x030 { return "DPLL_3.DPLL_PRED_CFG Predefined configuration selection." }
        case 0xc480 + 0x031 { return "DPLL_3.DPLL_TOD_SYNC_CFG DPLL ToD synchronization configuration." }
        case 0xc480 + 0x032 { return "DPLL_3.DPLL_COMBO_SLAVE_CFG_0 Combo mode slave primary source configuration." }
        case 0xc480 + 0x033 { return "DPLL_3.DPLL_COMBO_SLAVE_CFG_1 Combo mode slave secondary source configuration." }
        case 0xc480 + 0x034 { return "DPLL_3.DPLL_SLAVE_REF_CFG Slave mode configuration." }
        case 0xc480 + 0x035 { return "DPLL_3.DPLL_REF_MODE Reference selection configuration and XO DPLL monitor enable." }
        case 0xc480 + 0x036 { return "DPLL_3.DPLL_PHASE_MEASUREMENT_CFG Phase measurement mode configuration." }
        case 0xc480 + 0x037 { return "DPLL_3.DPLL_FASTLOCK_FREQ_SNAP_WINDOW Fastlock frequency snap window." }
        case 0xc480 + 0x038 { return "DPLL_3.DPLL_FASTLOCK_PHASE_PULL_IN_AND_FAST_ACQ_WINDOW Fastlock phase pull-in and fast-acquisition window." }
        case 0xc480 + 0x039 { return "DPLL_3.DPLL_FASTLOCK_PHASE_SNAP_WINDOW Fastlock phase snap window." }
        case 0xc480 + 0x03A { return "DPLL_3.DPLL_SINGLE_PULSE_SYNC_CFG Single pulse synchronization configuration." }
        case 0xc480 + 0x03B { return "DPLL_3.DPLL_MODE DPLL operating modes." }

        case 0xc4bc + 0x000 { return "DPLL_4.DPLL_DCO_INC_DEC_SIZE Configure frequency step size for GPIO increment/decrement mode." }
        case 0xc4bc + 0x002 { return "DPLL_4.DPLL_CTRL_0 Reference switching configuration and forced lock reference selection." }
        case 0xc4bc + 0x003 { return "DPLL_4.DPLL_CTRL_1 Configure other hitless switch features and DPLL feedback as a reference." }
        case 0xc4bc + 0x004 { return "DPLL_4.DPLL_CTRL_2 External feedback and frame/sync pulse configuration." }
        case 0xc4bc + 0x005 { return "DPLL_4.DPLL_CTRL_3 Configure DPLL loop filter update rate and maximum number of fast lock retry" }
        case 0xc4bc + 0x006 { return "DPLL_4.DPLL_FILTER_STATUS_UPDATE_CFG DPLL loop filter status update configuration." }
        case 0xc4bc + 0x007 { return "DPLL_4.DPLL_HO_ADVCD_HISTORY Advanced holdover history configuration." }
        case 0xc4bc + 0x008 { return "DPLL_4.DPLL_HO_ADVCD_BW DPLL advanced holdover bandwidth configuration." }
        case 0xc4bc + 0x00A { return "DPLL_4.DPLL_HO_CFG Holdover configuration." }
        case 0xc4bc + 0x00B { return "DPLL_4.DPLL_LOCK_0 Phase lock threshold." }
        case 0xc4bc + 0x00C { return "DPLL_4.DPLL_LOCK_1 Phase lock monitor duration." }
        case 0xc4bc + 0x00D { return "DPLL_4.DPLL_LOCK_2 Frequency lock threshold." }
        case 0xc4bc + 0x00E { return "DPLL_4.DPLL_LOCK_3 Frequency lock monitor duration." }
        case 0xc4bc + 0x00F { return "DPLL_4.DPLL_REF_PRIORITY_0 Select input for highest (0) priority." }
        case 0xc4bc + 0x010 { return "DPLL_4.DPLL_REF_PRIORITY_1 Select input for priority 1." }
        case 0xc4bc + 0x011 { return "DPLL_4.DPLL_REF_PRIORITY_2 Select input for priority 2." }
        case 0xc4bc + 0x012 { return "DPLL_4.DPLL_REF_PRIORITY_3 Select input for priority 3." }
        case 0xc4bc + 0x013 { return "DPLL_4.DPLL_REF_PRIORITY_4 Select input for priority 4." }
        case 0xc4bc + 0x014 { return "DPLL_4.DPLL_REF_PRIORITY_5 Select input for priority 5." }
        case 0xc4bc + 0x015 { return "DPLL_4.DPLL_REF_PRIORITY_6 Select input for priority 6." }
        case 0xc4bc + 0x016 { return "DPLL_4.DPLL_REF_PRIORITY_7 Select input for priority 7." }
        case 0xc4bc + 0x017 { return "DPLL_4.DPLL_REF_PRIORITY_8 Select input for priority 8." }
        case 0xc4bc + 0x018 { return "DPLL_4.DPLL_REF_PRIORITY_9 Select input for priority 9." }
        case 0xc4bc + 0x019 { return "DPLL_4.DPLL_REF_PRIORITY_10 Select input for priority 10." }
        case 0xc4bc + 0x01A { return "DPLL_4.DPLL_REF_PRIORITY_11 Select input for priority 11." }
        case 0xc4bc + 0x01B { return "DPLL_4.DPLL_REF_PRIORITY_12 Select input for priority 12." }
        case 0xc4bc + 0x01C { return "DPLL_4.DPLL_REF_PRIORITY_13 Select input for priority 13." }
        case 0xc4bc + 0x01D { return "DPLL_4.DPLL_REF_PRIORITY_14 Select input for priority 14." }
        case 0xc4bc + 0x01E { return "DPLL_4.DPLL_REF_PRIORITY_15 Select input for priority 15." }
        case 0xc4bc + 0x01F { return "DPLL_4.DPLL_REF_PRIORITY_16 Select input for priority 16." }
        case 0xc4bc + 0x020 { return "DPLL_4.DPLL_REF_PRIORITY_17 Select input for priority 17." }
        case 0xc4bc + 0x021 { return "DPLL_4.DPLL_REF_PRIORITY_18 Select input for priority 18." }
        case 0xc4bc + 0x022 { return "DPLL_4.DPLL_TRANS_CTRL Phase transient configuration." }
        case 0xc4bc + 0x023 { return "DPLL_4.DPLL_FASTLOCK_CFG_0 Fast lock configuration." }
        case 0xc4bc + 0x024 { return "DPLL_4.DPLL_FASTLOCK_CFG_1 Fast lock configuration." }
        case 0xc4bc + 0x025 { return "DPLL_4.DPLL_MAX_FREQ_OFFSET DPLL maximum frequency offset limit." }
        case 0xc4bc + 0x026 { return "DPLL_4.DPLL_FASTLOCK_PSL Fast lock phase slope limit." }
        case 0xc4bc + 0x028 { return "DPLL_4.DPLL_FASTLOCK_FSL Fast lock frequency slope limit." }
        case 0xc4bc + 0x02A { return "DPLL_4.DPLL_FASTLOCK_BW Fast lock loop filter bandwidth." }
        case 0xc4bc + 0x02C { return "DPLL_4.DPLL_WRITE_FREQ_TIMER Write frequency timer." }
        case 0xc4bc + 0x02E { return "DPLL_4.DPLL_WRITE_PHASE_TIMER Write phase timer." }
        case 0xc4bc + 0x030 { return "DPLL_4.DPLL_PRED_CFG Predefined configuration selection." }
        case 0xc4bc + 0x031 { return "DPLL_4.DPLL_TOD_SYNC_CFG DPLL ToD synchronization configuration." }
        case 0xc4bc + 0x032 { return "DPLL_4.DPLL_COMBO_SLAVE_CFG_0 Combo mode slave primary source configuration." }
        case 0xc4bc + 0x033 { return "DPLL_4.DPLL_COMBO_SLAVE_CFG_1 Combo mode slave secondary source configuration." }
        case 0xc4bc + 0x034 { return "DPLL_4.DPLL_SLAVE_REF_CFG Slave mode configuration." }
        case 0xc4bc + 0x035 { return "DPLL_4.DPLL_REF_MODE Reference selection configuration and XO DPLL monitor enable." }
        case 0xc4bc + 0x036 { return "DPLL_4.DPLL_PHASE_MEASUREMENT_CFG Phase measurement mode configuration." }
        case 0xc4bc + 0x037 { return "DPLL_4.DPLL_FASTLOCK_FREQ_SNAP_WINDOW Fastlock frequency snap window." }
        case 0xc4bc + 0x038 { return "DPLL_4.DPLL_FASTLOCK_PHASE_PULL_IN_AND_FAST_ACQ_WINDOW Fastlock phase pull-in and fast-acquisition window." }
        case 0xc4bc + 0x039 { return "DPLL_4.DPLL_FASTLOCK_PHASE_SNAP_WINDOW Fastlock phase snap window." }
        case 0xc4bc + 0x03A { return "DPLL_4.DPLL_SINGLE_PULSE_SYNC_CFG Single pulse synchronization configuration." }
        case 0xc4bc + 0x03B { return "DPLL_4.DPLL_MODE DPLL operating modes." }

        case 0xc500 + 0x000 { return "DPLL_5.DPLL_DCO_INC_DEC_SIZE Configure frequency step size for GPIO increment/decrement mode." }
        case 0xc500 + 0x002 { return "DPLL_5.DPLL_CTRL_0 Reference switching configuration and forced lock reference selection." }
        case 0xc500 + 0x003 { return "DPLL_5.DPLL_CTRL_1 Configure other hitless switch features and DPLL feedback as a reference." }
        case 0xc500 + 0x004 { return "DPLL_5.DPLL_CTRL_2 External feedback and frame/sync pulse configuration." }
        case 0xc500 + 0x005 { return "DPLL_5.DPLL_CTRL_3 Configure DPLL loop filter update rate and maximum number of fast lock retry" }
        case 0xc500 + 0x006 { return "DPLL_5.DPLL_FILTER_STATUS_UPDATE_CFG DPLL loop filter status update configuration." }
        case 0xc500 + 0x007 { return "DPLL_5.DPLL_HO_ADVCD_HISTORY Advanced holdover history configuration." }
        case 0xc500 + 0x008 { return "DPLL_5.DPLL_HO_ADVCD_BW DPLL advanced holdover bandwidth configuration." }
        case 0xc500 + 0x00A { return "DPLL_5.DPLL_HO_CFG Holdover configuration." }
        case 0xc500 + 0x00B { return "DPLL_5.DPLL_LOCK_0 Phase lock threshold." }
        case 0xc500 + 0x00C { return "DPLL_5.DPLL_LOCK_1 Phase lock monitor duration." }
        case 0xc500 + 0x00D { return "DPLL_5.DPLL_LOCK_2 Frequency lock threshold." }
        case 0xc500 + 0x00E { return "DPLL_5.DPLL_LOCK_3 Frequency lock monitor duration." }
        case 0xc500 + 0x00F { return "DPLL_5.DPLL_REF_PRIORITY_0 Select input for highest (0) priority." }
        case 0xc500 + 0x010 { return "DPLL_5.DPLL_REF_PRIORITY_1 Select input for priority 1." }
        case 0xc500 + 0x011 { return "DPLL_5.DPLL_REF_PRIORITY_2 Select input for priority 2." }
        case 0xc500 + 0x012 { return "DPLL_5.DPLL_REF_PRIORITY_3 Select input for priority 3." }
        case 0xc500 + 0x013 { return "DPLL_5.DPLL_REF_PRIORITY_4 Select input for priority 4." }
        case 0xc500 + 0x014 { return "DPLL_5.DPLL_REF_PRIORITY_5 Select input for priority 5." }
        case 0xc500 + 0x015 { return "DPLL_5.DPLL_REF_PRIORITY_6 Select input for priority 6." }
        case 0xc500 + 0x016 { return "DPLL_5.DPLL_REF_PRIORITY_7 Select input for priority 7." }
        case 0xc500 + 0x017 { return "DPLL_5.DPLL_REF_PRIORITY_8 Select input for priority 8." }
        case 0xc500 + 0x018 { return "DPLL_5.DPLL_REF_PRIORITY_9 Select input for priority 9." }
        case 0xc500 + 0x019 { return "DPLL_5.DPLL_REF_PRIORITY_10 Select input for priority 10." }
        case 0xc500 + 0x01A { return "DPLL_5.DPLL_REF_PRIORITY_11 Select input for priority 11." }
        case 0xc500 + 0x01B { return "DPLL_5.DPLL_REF_PRIORITY_12 Select input for priority 12." }
        case 0xc500 + 0x01C { return "DPLL_5.DPLL_REF_PRIORITY_13 Select input for priority 13." }
        case 0xc500 + 0x01D { return "DPLL_5.DPLL_REF_PRIORITY_14 Select input for priority 14." }
        case 0xc500 + 0x01E { return "DPLL_5.DPLL_REF_PRIORITY_15 Select input for priority 15." }
        case 0xc500 + 0x01F { return "DPLL_5.DPLL_REF_PRIORITY_16 Select input for priority 16." }
        case 0xc500 + 0x020 { return "DPLL_5.DPLL_REF_PRIORITY_17 Select input for priority 17." }
        case 0xc500 + 0x021 { return "DPLL_5.DPLL_REF_PRIORITY_18 Select input for priority 18." }
        case 0xc500 + 0x022 { return "DPLL_5.DPLL_TRANS_CTRL Phase transient configuration." }
        case 0xc500 + 0x023 { return "DPLL_5.DPLL_FASTLOCK_CFG_0 Fast lock configuration." }
        case 0xc500 + 0x024 { return "DPLL_5.DPLL_FASTLOCK_CFG_1 Fast lock configuration." }
        case 0xc500 + 0x025 { return "DPLL_5.DPLL_MAX_FREQ_OFFSET DPLL maximum frequency offset limit." }
        case 0xc500 + 0x026 { return "DPLL_5.DPLL_FASTLOCK_PSL Fast lock phase slope limit." }
        case 0xc500 + 0x028 { return "DPLL_5.DPLL_FASTLOCK_FSL Fast lock frequency slope limit." }
        case 0xc500 + 0x02A { return "DPLL_5.DPLL_FASTLOCK_BW Fast lock loop filter bandwidth." }
        case 0xc500 + 0x02C { return "DPLL_5.DPLL_WRITE_FREQ_TIMER Write frequency timer." }
        case 0xc500 + 0x02E { return "DPLL_5.DPLL_WRITE_PHASE_TIMER Write phase timer." }
        case 0xc500 + 0x030 { return "DPLL_5.DPLL_PRED_CFG Predefined configuration selection." }
        case 0xc500 + 0x031 { return "DPLL_5.DPLL_TOD_SYNC_CFG DPLL ToD synchronization configuration." }
        case 0xc500 + 0x032 { return "DPLL_5.DPLL_COMBO_SLAVE_CFG_0 Combo mode slave primary source configuration." }
        case 0xc500 + 0x033 { return "DPLL_5.DPLL_COMBO_SLAVE_CFG_1 Combo mode slave secondary source configuration." }
        case 0xc500 + 0x034 { return "DPLL_5.DPLL_SLAVE_REF_CFG Slave mode configuration." }
        case 0xc500 + 0x035 { return "DPLL_5.DPLL_REF_MODE Reference selection configuration and XO DPLL monitor enable." }
        case 0xc500 + 0x036 { return "DPLL_5.DPLL_PHASE_MEASUREMENT_CFG Phase measurement mode configuration." }
        case 0xc500 + 0x037 { return "DPLL_5.DPLL_FASTLOCK_FREQ_SNAP_WINDOW Fastlock frequency snap window." }
        case 0xc500 + 0x038 { return "DPLL_5.DPLL_FASTLOCK_PHASE_PULL_IN_AND_FAST_ACQ_WINDOW Fastlock phase pull-in and fast-acquisition window." }
        case 0xc500 + 0x039 { return "DPLL_5.DPLL_FASTLOCK_PHASE_SNAP_WINDOW Fastlock phase snap window." }
        case 0xc500 + 0x03A { return "DPLL_5.DPLL_SINGLE_PULSE_SYNC_CFG Single pulse synchronization configuration." }
        case 0xc500 + 0x03B { return "DPLL_5.DPLL_MODE DPLL operating modes." }

        case 0xc53c + 0x000 { return "DPLL_6.DPLL_DCO_INC_DEC_SIZE Configure frequency step size for GPIO increment/decrement mode." }
        case 0xc53c + 0x002 { return "DPLL_6.DPLL_CTRL_0 Reference switching configuration and forced lock reference selection." }
        case 0xc53c + 0x003 { return "DPLL_6.DPLL_CTRL_1 Configure other hitless switch features and DPLL feedback as a reference." }
        case 0xc53c + 0x004 { return "DPLL_6.DPLL_CTRL_2 External feedback and frame/sync pulse configuration." }
        case 0xc53c + 0x005 { return "DPLL_6.DPLL_CTRL_3 Configure DPLL loop filter update rate and maximum number of fast lock retry" }
        case 0xc53c + 0x006 { return "DPLL_6.DPLL_FILTER_STATUS_UPDATE_CFG DPLL loop filter status update configuration." }
        case 0xc53c + 0x007 { return "DPLL_6.DPLL_HO_ADVCD_HISTORY Advanced holdover history configuration." }
        case 0xc53c + 0x008 { return "DPLL_6.DPLL_HO_ADVCD_BW DPLL advanced holdover bandwidth configuration." }
        case 0xc53c + 0x00A { return "DPLL_6.DPLL_HO_CFG Holdover configuration." }
        case 0xc53c + 0x00B { return "DPLL_6.DPLL_LOCK_0 Phase lock threshold." }
        case 0xc53c + 0x00C { return "DPLL_6.DPLL_LOCK_1 Phase lock monitor duration." }
        case 0xc53c + 0x00D { return "DPLL_6.DPLL_LOCK_2 Frequency lock threshold." }
        case 0xc53c + 0x00E { return "DPLL_6.DPLL_LOCK_3 Frequency lock monitor duration." }
        case 0xc53c + 0x00F { return "DPLL_6.DPLL_REF_PRIORITY_0 Select input for highest (0) priority." }
        case 0xc53c + 0x010 { return "DPLL_6.DPLL_REF_PRIORITY_1 Select input for priority 1." }
        case 0xc53c + 0x011 { return "DPLL_6.DPLL_REF_PRIORITY_2 Select input for priority 2." }
        case 0xc53c + 0x012 { return "DPLL_6.DPLL_REF_PRIORITY_3 Select input for priority 3." }
        case 0xc53c + 0x013 { return "DPLL_6.DPLL_REF_PRIORITY_4 Select input for priority 4." }
        case 0xc53c + 0x014 { return "DPLL_6.DPLL_REF_PRIORITY_5 Select input for priority 5." }
        case 0xc53c + 0x015 { return "DPLL_6.DPLL_REF_PRIORITY_6 Select input for priority 6." }
        case 0xc53c + 0x016 { return "DPLL_6.DPLL_REF_PRIORITY_7 Select input for priority 7." }
        case 0xc53c + 0x017 { return "DPLL_6.DPLL_REF_PRIORITY_8 Select input for priority 8." }
        case 0xc53c + 0x018 { return "DPLL_6.DPLL_REF_PRIORITY_9 Select input for priority 9." }
        case 0xc53c + 0x019 { return "DPLL_6.DPLL_REF_PRIORITY_10 Select input for priority 10." }
        case 0xc53c + 0x01A { return "DPLL_6.DPLL_REF_PRIORITY_11 Select input for priority 11." }
        case 0xc53c + 0x01B { return "DPLL_6.DPLL_REF_PRIORITY_12 Select input for priority 12." }
        case 0xc53c + 0x01C { return "DPLL_6.DPLL_REF_PRIORITY_13 Select input for priority 13." }
        case 0xc53c + 0x01D { return "DPLL_6.DPLL_REF_PRIORITY_14 Select input for priority 14." }
        case 0xc53c + 0x01E { return "DPLL_6.DPLL_REF_PRIORITY_15 Select input for priority 15." }
        case 0xc53c + 0x01F { return "DPLL_6.DPLL_REF_PRIORITY_16 Select input for priority 16." }
        case 0xc53c + 0x020 { return "DPLL_6.DPLL_REF_PRIORITY_17 Select input for priority 17." }
        case 0xc53c + 0x021 { return "DPLL_6.DPLL_REF_PRIORITY_18 Select input for priority 18." }
        case 0xc53c + 0x022 { return "DPLL_6.DPLL_TRANS_CTRL Phase transient configuration." }
        case 0xc53c + 0x023 { return "DPLL_6.DPLL_FASTLOCK_CFG_0 Fast lock configuration." }
        case 0xc53c + 0x024 { return "DPLL_6.DPLL_FASTLOCK_CFG_1 Fast lock configuration." }
        case 0xc53c + 0x025 { return "DPLL_6.DPLL_MAX_FREQ_OFFSET DPLL maximum frequency offset limit." }
        case 0xc53c + 0x026 { return "DPLL_6.DPLL_FASTLOCK_PSL Fast lock phase slope limit." }
        case 0xc53c + 0x028 { return "DPLL_6.DPLL_FASTLOCK_FSL Fast lock frequency slope limit." }
        case 0xc53c + 0x02A { return "DPLL_6.DPLL_FASTLOCK_BW Fast lock loop filter bandwidth." }
        case 0xc53c + 0x02C { return "DPLL_6.DPLL_WRITE_FREQ_TIMER Write frequency timer." }
        case 0xc53c + 0x02E { return "DPLL_6.DPLL_WRITE_PHASE_TIMER Write phase timer." }
        case 0xc53c + 0x030 { return "DPLL_6.DPLL_PRED_CFG Predefined configuration selection." }
        case 0xc53c + 0x031 { return "DPLL_6.DPLL_TOD_SYNC_CFG DPLL ToD synchronization configuration." }
        case 0xc53c + 0x032 { return "DPLL_6.DPLL_COMBO_SLAVE_CFG_0 Combo mode slave primary source configuration." }
        case 0xc53c + 0x033 { return "DPLL_6.DPLL_COMBO_SLAVE_CFG_1 Combo mode slave secondary source configuration." }
        case 0xc53c + 0x034 { return "DPLL_6.DPLL_SLAVE_REF_CFG Slave mode configuration." }
        case 0xc53c + 0x035 { return "DPLL_6.DPLL_REF_MODE Reference selection configuration and XO DPLL monitor enable." }
        case 0xc53c + 0x036 { return "DPLL_6.DPLL_PHASE_MEASUREMENT_CFG Phase measurement mode configuration." }
        case 0xc53c + 0x037 { return "DPLL_6.DPLL_FASTLOCK_FREQ_SNAP_WINDOW Fastlock frequency snap window." }
        case 0xc53c + 0x038 { return "DPLL_6.DPLL_FASTLOCK_PHASE_PULL_IN_AND_FAST_ACQ_WINDOW Fastlock phase pull-in and fast-acquisition window." }
        case 0xc53c + 0x039 { return "DPLL_6.DPLL_FASTLOCK_PHASE_SNAP_WINDOW Fastlock phase snap window." }
        case 0xc53c + 0x03A { return "DPLL_6.DPLL_SINGLE_PULSE_SYNC_CFG Single pulse synchronization configuration." }
        case 0xc53c + 0x03B { return "DPLL_6.DPLL_MODE DPLL operating modes." }

        case 0xc580 + 0x000 { return "DPLL_7.DPLL_DCO_INC_DEC_SIZE Configure frequency step size for GPIO increment/decrement mode." }
        case 0xc580 + 0x002 { return "DPLL_7.DPLL_CTRL_0 Reference switching configuration and forced lock reference selection." }
        case 0xc580 + 0x003 { return "DPLL_7.DPLL_CTRL_1 Configure other hitless switch features and DPLL feedback as a reference." }
        case 0xc580 + 0x004 { return "DPLL_7.DPLL_CTRL_2 External feedback and frame/sync pulse configuration." }
        case 0xc580 + 0x005 { return "DPLL_7.DPLL_CTRL_3 Configure DPLL loop filter update rate and maximum number of fast lock retry" }
        case 0xc580 + 0x006 { return "DPLL_7.DPLL_FILTER_STATUS_UPDATE_CFG DPLL loop filter status update configuration." }
        case 0xc580 + 0x007 { return "DPLL_7.DPLL_HO_ADVCD_HISTORY Advanced holdover history configuration." }
        case 0xc580 + 0x008 { return "DPLL_7.DPLL_HO_ADVCD_BW DPLL advanced holdover bandwidth configuration." }
        case 0xc580 + 0x00A { return "DPLL_7.DPLL_HO_CFG Holdover configuration." }
        case 0xc580 + 0x00B { return "DPLL_7.DPLL_LOCK_0 Phase lock threshold." }
        case 0xc580 + 0x00C { return "DPLL_7.DPLL_LOCK_1 Phase lock monitor duration." }
        case 0xc580 + 0x00D { return "DPLL_7.DPLL_LOCK_2 Frequency lock threshold." }
        case 0xc580 + 0x00E { return "DPLL_7.DPLL_LOCK_3 Frequency lock monitor duration." }
        case 0xc580 + 0x00F { return "DPLL_7.DPLL_REF_PRIORITY_0 Select input for highest (0) priority." }
        case 0xc580 + 0x010 { return "DPLL_7.DPLL_REF_PRIORITY_1 Select input for priority 1." }
        case 0xc580 + 0x011 { return "DPLL_7.DPLL_REF_PRIORITY_2 Select input for priority 2." }
        case 0xc580 + 0x012 { return "DPLL_7.DPLL_REF_PRIORITY_3 Select input for priority 3." }
        case 0xc580 + 0x013 { return "DPLL_7.DPLL_REF_PRIORITY_4 Select input for priority 4." }
        case 0xc580 + 0x014 { return "DPLL_7.DPLL_REF_PRIORITY_5 Select input for priority 5." }
        case 0xc580 + 0x015 { return "DPLL_7.DPLL_REF_PRIORITY_6 Select input for priority 6." }
        case 0xc580 + 0x016 { return "DPLL_7.DPLL_REF_PRIORITY_7 Select input for priority 7." }
        case 0xc580 + 0x017 { return "DPLL_7.DPLL_REF_PRIORITY_8 Select input for priority 8." }
        case 0xc580 + 0x018 { return "DPLL_7.DPLL_REF_PRIORITY_9 Select input for priority 9." }
        case 0xc580 + 0x019 { return "DPLL_7.DPLL_REF_PRIORITY_10 Select input for priority 10." }
        case 0xc580 + 0x01A { return "DPLL_7.DPLL_REF_PRIORITY_11 Select input for priority 11." }
        case 0xc580 + 0x01B { return "DPLL_7.DPLL_REF_PRIORITY_12 Select input for priority 12." }
        case 0xc580 + 0x01C { return "DPLL_7.DPLL_REF_PRIORITY_13 Select input for priority 13." }
        case 0xc580 + 0x01D { return "DPLL_7.DPLL_REF_PRIORITY_14 Select input for priority 14." }
        case 0xc580 + 0x01E { return "DPLL_7.DPLL_REF_PRIORITY_15 Select input for priority 15." }
        case 0xc580 + 0x01F { return "DPLL_7.DPLL_REF_PRIORITY_16 Select input for priority 16." }
        case 0xc580 + 0x020 { return "DPLL_7.DPLL_REF_PRIORITY_17 Select input for priority 17." }
        case 0xc580 + 0x021 { return "DPLL_7.DPLL_REF_PRIORITY_18 Select input for priority 18." }
        case 0xc580 + 0x022 { return "DPLL_7.DPLL_TRANS_CTRL Phase transient configuration." }
        case 0xc580 + 0x023 { return "DPLL_7.DPLL_FASTLOCK_CFG_0 Fast lock configuration." }
        case 0xc580 + 0x024 { return "DPLL_7.DPLL_FASTLOCK_CFG_1 Fast lock configuration." }
        case 0xc580 + 0x025 { return "DPLL_7.DPLL_MAX_FREQ_OFFSET DPLL maximum frequency offset limit." }
        case 0xc580 + 0x026 { return "DPLL_7.DPLL_FASTLOCK_PSL Fast lock phase slope limit." }
        case 0xc580 + 0x028 { return "DPLL_7.DPLL_FASTLOCK_FSL Fast lock frequency slope limit." }
        case 0xc580 + 0x02A { return "DPLL_7.DPLL_FASTLOCK_BW Fast lock loop filter bandwidth." }
        case 0xc580 + 0x02C { return "DPLL_7.DPLL_WRITE_FREQ_TIMER Write frequency timer." }
        case 0xc580 + 0x02E { return "DPLL_7.DPLL_WRITE_PHASE_TIMER Write phase timer." }
        case 0xc580 + 0x030 { return "DPLL_7.DPLL_PRED_CFG Predefined configuration selection." }
        case 0xc580 + 0x031 { return "DPLL_7.DPLL_TOD_SYNC_CFG DPLL ToD synchronization configuration." }
        case 0xc580 + 0x032 { return "DPLL_7.DPLL_COMBO_SLAVE_CFG_0 Combo mode slave primary source configuration." }
        case 0xc580 + 0x033 { return "DPLL_7.DPLL_COMBO_SLAVE_CFG_1 Combo mode slave secondary source configuration." }
        case 0xc580 + 0x034 { return "DPLL_7.DPLL_SLAVE_REF_CFG Slave mode configuration." }
        case 0xc580 + 0x035 { return "DPLL_7.DPLL_REF_MODE Reference selection configuration and XO DPLL monitor enable." }
        case 0xc580 + 0x036 { return "DPLL_7.DPLL_PHASE_MEASUREMENT_CFG Phase measurement mode configuration." }
        case 0xc580 + 0x037 { return "DPLL_7.DPLL_FASTLOCK_FREQ_SNAP_WINDOW Fastlock frequency snap window." }
        case 0xc580 + 0x038 { return "DPLL_7.DPLL_FASTLOCK_PHASE_PULL_IN_AND_FAST_ACQ_WINDOW Fastlock phase pull-in and fast-acquisition window." }
        case 0xc580 + 0x039 { return "DPLL_7.DPLL_FASTLOCK_PHASE_SNAP_WINDOW Fastlock phase snap window." }
        case 0xc580 + 0x03A { return "DPLL_7.DPLL_SINGLE_PULSE_SYNC_CFG Single pulse synchronization configuration." }
        case 0xc580 + 0x03B { return "DPLL_7.DPLL_MODE DPLL operating modes." }


        case 0xc5bc + 0x000 { return "SYS_DPLL.SYS_DPLL_CTRL_0 Reference switching configuration and forced lock reference selection." }
        case 0xc5bc + 0x001 { return "SYS_DPLL.SYS_DPLL_CTRL_3 System DPLL loop filter update rate configuration." }
        case 0xc5bc + 0x002 { return "SYS_DPLL.SYS_DPLL_FILTER_STATUS_UPDATE_CFG System DPLL loop filter status update configuration." }
        case 0xc5bc + 0x003 { return "SYS_DPLL.SYS_DPLL_LOCK_0 Phase lock threshold." }
        case 0xc5bc + 0x004 { return "SYS_DPLL.SYS_DPLL_LOCK_1 Phase lock monitor duration." }
        case 0xc5bc + 0x005 { return "SYS_DPLL.SYS_DPLL_LOCK_2 Frequency lock threshold." }
        case 0xc5bc + 0x006 { return "SYS_DPLL.SYS_DPLL_LOCK_3 Frequency lock monitor duration." }
        case 0xc5bc + 0x007 { return "SYS_DPLL.SYS_DPLL_REF_PRIORITY_0 Select input for highest (0) priority." }
        case 0xc5bc + 0x008 { return "SYS_DPLL.SYS_DPLL_REF_PRIORITY_1 Select input for priority 1." }
        case 0xc5bc + 0x009 { return "SYS_DPLL.SYS_DPLL_REF_PRIORITY_2 Select input for priority 2." }
        case 0xc5bc + 0x00A { return "SYS_DPLL.SYS_DPLL_REF_PRIORITY_3 Select input for priority 3." }
        case 0xc5bc + 0x00B { return "SYS_DPLL.SYS_DPLL_REF_PRIORITY_4 Select input for priority 4." }
        case 0xc5bc + 0x00C { return "SYS_DPLL.SYS_DPLL_REF_PRIORITY_5 Select input for priority 5." }
        case 0xc5bc + 0x00D { return "SYS_DPLL.SYS_DPLL_REF_PRIORITY_6 Select input for priority 6." }
        case 0xc5bc + 0x00E { return "SYS_DPLL.SYS_DPLL_REF_PRIORITY_7 Select input for priority 7." }
        case 0xc5bc + 0x00F { return "SYS_DPLL.SYS_DPLL_REF_PRIORITY_8 Select input for priority 8." }
        case 0xc5bc + 0x010 { return "SYS_DPLL.SYS_DPLL_REF_PRIORITY_9 Select input for priority 9." }
        case 0xc5bc + 0x011 { return "SYS_DPLL.SYS_DPLL_REF_PRIORITY_10 Select input for priority 10." }
        case 0xc5bc + 0x012 { return "SYS_DPLL.SYS_DPLL_REF_PRIORITY_11 Select input for priority 11." }
        case 0xc5bc + 0x013 { return "SYS_DPLL.SYS_DPLL_REF_PRIORITY_12 Select input for priority 12." }
        case 0xc5bc + 0x014 { return "SYS_DPLL.SYS_DPLL_REF_PRIORITY_13 Select input for priority 13." }
        case 0xc5bc + 0x015 { return "SYS_DPLL.SYS_DPLL_REF_PRIORITY_14 Select input for priority 14." }
        case 0xc5bc + 0x016 { return "SYS_DPLL.SYS_DPLL_REF_PRIORITY_15 Select input for priority 15." }
        case 0xc5bc + 0x017 { return "SYS_DPLL.SYS_DPLL_REF_PRIORITY_16 Select input for priority 16." }
        case 0xc5bc + 0x018 { return "SYS_DPLL.SYS_DPLL_REF_PRIORITY_17 Select input for priority 17." }
        case 0xc5bc + 0x019 { return "SYS_DPLL.SYS_DPLL_REF_PRIORITY_18 Select input for priority 18." }
        case 0xc5bc + 0x01A { return "RESERVED " }
        case 0xc5bc + 0x01B { return "SYS_DPLL.SYS_DPLL_REF_MODE Reference selection configuration and XO DPLL monitor enable." }
        case 0xc5bc + 0x01C { return "RESERVED " }
        case 0xc5bc + 0x01D { return "RESERVED " }
        case 0xc5bc + 0x01E { return "SYS_DPLL.SYS_DPLL_MODE System DPLL state machine transition mode." }

        case 0xc600 + 0x000 { return "DPLL_CTRL_0.DPLL_HS_TIE_RESET Reset hitless switching time interval error." }
        case 0xc600 + 0x001 { return "DPLL_CTRL_0.DPLL_MANU_REF_CFG Manual reference mode configuration." }
        case 0xc600 + 0x002 { return "DPLL_CTRL_0.DPLL_DAMPING DPLL loop filter damping factor." }
        case 0xc600 + 0x003 { return "DPLL_CTRL_0.DPLL_DECIMATOR_BW_MULT DPLL loop filter decimator bandwidth multiplier." }
        case 0xc600 + 0x004 { return "DPLL_CTRL_0.DPLL_BW DPLL loop filter bandwidth." }
        case 0xc600 + 0x006 { return "DPLL_CTRL_0.DPLL_PSL DPLL loop filter phase slope limit." }
        case 0xc600 + 0x008 { return "DPLL_CTRL_0.DPLL_PRED0_DAMPING Predefined configuration 0 loop filter damping factor." }
        case 0xc600 + 0x009 { return "DPLL_CTRL_0.DPLL_PRED0_DECIMATOR_BW_MULT Predefined configuration 0 loop filter decimator bandwidth multiplier." }
        case 0xc600 + 0x00A { return "DPLL_CTRL_0.DPLL_PRED0_BW Predefined configuration 0 loop filter bandwidth." }
        case 0xc600 + 0x00C { return "DPLL_CTRL_0.DPLL_PRED0_PSL Predefined configuration 0 loop filter phase slope limit." }
        case 0xc600 + 0x00E { return "DPLL_CTRL_0.DPLL_PRED1_DAMPING Predefined configuration 1 loop filter damping factor." }
        case 0xc600 + 0x00F { return "DPLL_CTRL_0.DPLL_PRED1_DECIMATOR_BW_MULT Predefined configuration 1 loop filter decimator bandwidth multiplier." }
        case 0xc600 + 0x010 { return "DPLL_CTRL_0.DPLL_PRED1_BW Predefined configuration 1 loop filter bandwidth." }
        case 0xc600 + 0x012 { return "DPLL_CTRL_0.DPLL_PRED1_PSL Predefined configuration 1 loop filter phase slope limit." }
        case 0xc600 + 0x014 { return "DPLL_CTRL_0.DPLL_PHASE_OFFSET_CFG DPLL phase offset configuration." }
        case 0xc600 + 0x019 { return "DPLL_CTRL_0.DPLL_HO_HISTORY_RESET Reset advanced holdover history." }
        case 0xc600 + 0x01A { return "DPLL_CTRL_0.DPLL_FINE_PHASE_ADV_CFG DPLL fine phase advance adjustment configuration." }
        case 0xc600 + 0x01C { return "DPLL_CTRL_0.DPLL_FOD_FREQ Fractional Output Divider (FOD) frequency in Hz." }
        case 0xc600 + 0x024 { return "DPLL_CTRL_0.DPLL_MASTER_DIV Master divider value." }
        case 0xc600 + 0x028 { return "DPLL_CTRL_0.DPLL_COMBO_SW_VALUE_CNFG DCO value to be added to the combo bus in SW combo mode." }
        case 0xc600 + 0x030 { return "DPLL_CTRL_0.DPLL_MANUAL_HOLDOVER_VALUE DCO value to be used in manual holdover mode." }
        case 0xc600 + 0x036 { return "DPLL_CTRL_0.DPLL_DCD_FILTER_CNFG DPLL DCD filter configuration." }
        case 0xc600 + 0x038 { return "DPLL_CTRL_0.DPLL_COMBO_MASTER_BW DPLL combo filter bandwidth." }
        case 0xc600 + 0x03A { return "DPLL_CTRL_0.DPLL_COMBO_MASTER_CFG DPLL combo master configuration." }
        case 0xc600 + 0x03B { return "DPLL_CTRL_0.DPLL_FRAME_PULSE_SYNC Frame pulse sync trigger" }

        case 0xc63c + 0x000 { return "DPLL_CTRL_1.DPLL_HS_TIE_RESET Reset hitless switching time interval error." }
        case 0xc63c + 0x001 { return "DPLL_CTRL_1.DPLL_MANU_REF_CFG Manual reference mode configuration." }
        case 0xc63c + 0x002 { return "DPLL_CTRL_1.DPLL_DAMPING DPLL loop filter damping factor." }
        case 0xc63c + 0x003 { return "DPLL_CTRL_1.DPLL_DECIMATOR_BW_MULT DPLL loop filter decimator bandwidth multiplier." }
        case 0xc63c + 0x004 { return "DPLL_CTRL_1.DPLL_BW DPLL loop filter bandwidth." }
        case 0xc63c + 0x006 { return "DPLL_CTRL_1.DPLL_PSL DPLL loop filter phase slope limit." }
        case 0xc63c + 0x008 { return "DPLL_CTRL_1.DPLL_PRED0_DAMPING Predefined configuration 0 loop filter damping factor." }
        case 0xc63c + 0x009 { return "DPLL_CTRL_1.DPLL_PRED0_DECIMATOR_BW_MULT Predefined configuration 0 loop filter decimator bandwidth multiplier." }
        case 0xc63c + 0x00A { return "DPLL_CTRL_1.DPLL_PRED0_BW Predefined configuration 0 loop filter bandwidth." }
        case 0xc63c + 0x00C { return "DPLL_CTRL_1.DPLL_PRED0_PSL Predefined configuration 0 loop filter phase slope limit." }
        case 0xc63c + 0x00E { return "DPLL_CTRL_1.DPLL_PRED1_DAMPING Predefined configuration 1 loop filter damping factor." }
        case 0xc63c + 0x00F { return "DPLL_CTRL_1.DPLL_PRED1_DECIMATOR_BW_MULT Predefined configuration 1 loop filter decimator bandwidth multiplier." }
        case 0xc63c + 0x010 { return "DPLL_CTRL_1.DPLL_PRED1_BW Predefined configuration 1 loop filter bandwidth." }
        case 0xc63c + 0x012 { return "DPLL_CTRL_1.DPLL_PRED1_PSL Predefined configuration 1 loop filter phase slope limit." }
        case 0xc63c + 0x014 { return "DPLL_CTRL_1.DPLL_PHASE_OFFSET_CFG DPLL phase offset configuration." }
        case 0xc63c + 0x019 { return "DPLL_CTRL_1.DPLL_HO_HISTORY_RESET Reset advanced holdover history." }
        case 0xc63c + 0x01A { return "DPLL_CTRL_1.DPLL_FINE_PHASE_ADV_CFG DPLL fine phase advance adjustment configuration." }
        case 0xc63c + 0x01C { return "DPLL_CTRL_1.DPLL_FOD_FREQ Fractional Output Divider (FOD) frequency in Hz." }
        case 0xc63c + 0x024 { return "DPLL_CTRL_1.DPLL_MASTER_DIV Master divider value." }
        case 0xc63c + 0x028 { return "DPLL_CTRL_1.DPLL_COMBO_SW_VALUE_CNFG DCO value to be added to the combo bus in SW combo mode." }
        case 0xc63c + 0x030 { return "DPLL_CTRL_1.DPLL_MANUAL_HOLDOVER_VALUE DCO value to be used in manual holdover mode." }
        case 0xc63c + 0x036 { return "DPLL_CTRL_1.DPLL_DCD_FILTER_CNFG DPLL DCD filter configuration." }
        case 0xc63c + 0x038 { return "DPLL_CTRL_1.DPLL_COMBO_MASTER_BW DPLL combo filter bandwidth." }
        case 0xc63c + 0x03A { return "DPLL_CTRL_1.DPLL_COMBO_MASTER_CFG DPLL combo master configuration." }
        case 0xc63c + 0x03B { return "DPLL_CTRL_1.DPLL_FRAME_PULSE_SYNC Frame pulse sync trigger" }

        case 0xc680 + 0x000 { return "DPLL_CTRL_2.DPLL_HS_TIE_RESET Reset hitless switching time interval error." }
        case 0xc680 + 0x001 { return "DPLL_CTRL_2.DPLL_MANU_REF_CFG Manual reference mode configuration." }
        case 0xc680 + 0x002 { return "DPLL_CTRL_2.DPLL_DAMPING DPLL loop filter damping factor." }
        case 0xc680 + 0x003 { return "DPLL_CTRL_2.DPLL_DECIMATOR_BW_MULT DPLL loop filter decimator bandwidth multiplier." }
        case 0xc680 + 0x004 { return "DPLL_CTRL_2.DPLL_BW DPLL loop filter bandwidth." }
        case 0xc680 + 0x006 { return "DPLL_CTRL_2.DPLL_PSL DPLL loop filter phase slope limit." }
        case 0xc680 + 0x008 { return "DPLL_CTRL_2.DPLL_PRED0_DAMPING Predefined configuration 0 loop filter damping factor." }
        case 0xc680 + 0x009 { return "DPLL_CTRL_2.DPLL_PRED0_DECIMATOR_BW_MULT Predefined configuration 0 loop filter decimator bandwidth multiplier." }
        case 0xc680 + 0x00A { return "DPLL_CTRL_2.DPLL_PRED0_BW Predefined configuration 0 loop filter bandwidth." }
        case 0xc680 + 0x00C { return "DPLL_CTRL_2.DPLL_PRED0_PSL Predefined configuration 0 loop filter phase slope limit." }
        case 0xc680 + 0x00E { return "DPLL_CTRL_2.DPLL_PRED1_DAMPING Predefined configuration 1 loop filter damping factor." }
        case 0xc680 + 0x00F { return "DPLL_CTRL_2.DPLL_PRED1_DECIMATOR_BW_MULT Predefined configuration 1 loop filter decimator bandwidth multiplier." }
        case 0xc680 + 0x010 { return "DPLL_CTRL_2.DPLL_PRED1_BW Predefined configuration 1 loop filter bandwidth." }
        case 0xc680 + 0x012 { return "DPLL_CTRL_2.DPLL_PRED1_PSL Predefined configuration 1 loop filter phase slope limit." }
        case 0xc680 + 0x014 { return "DPLL_CTRL_2.DPLL_PHASE_OFFSET_CFG DPLL phase offset configuration." }
        case 0xc680 + 0x019 { return "DPLL_CTRL_2.DPLL_HO_HISTORY_RESET Reset advanced holdover history." }
        case 0xc680 + 0x01A { return "DPLL_CTRL_2.DPLL_FINE_PHASE_ADV_CFG DPLL fine phase advance adjustment configuration." }
        case 0xc680 + 0x01C { return "DPLL_CTRL_2.DPLL_FOD_FREQ Fractional Output Divider (FOD) frequency in Hz." }
        case 0xc680 + 0x024 { return "DPLL_CTRL_2.DPLL_MASTER_DIV Master divider value." }
        case 0xc680 + 0x028 { return "DPLL_CTRL_2.DPLL_COMBO_SW_VALUE_CNFG DCO value to be added to the combo bus in SW combo mode." }
        case 0xc680 + 0x030 { return "DPLL_CTRL_2.DPLL_MANUAL_HOLDOVER_VALUE DCO value to be used in manual holdover mode." }
        case 0xc680 + 0x036 { return "DPLL_CTRL_2.DPLL_DCD_FILTER_CNFG DPLL DCD filter configuration." }
        case 0xc680 + 0x038 { return "DPLL_CTRL_2.DPLL_COMBO_MASTER_BW DPLL combo filter bandwidth." }
        case 0xc680 + 0x03A { return "DPLL_CTRL_2.DPLL_COMBO_MASTER_CFG DPLL combo master configuration." }
        case 0xc680 + 0x03B { return "DPLL_CTRL_2.DPLL_FRAME_PULSE_SYNC Frame pulse sync trigger" }

        case 0xc6bc + 0x000 { return "DPLL_CTRL_3.DPLL_HS_TIE_RESET Reset hitless switching time interval error." }
        case 0xc6bc + 0x001 { return "DPLL_CTRL_3.DPLL_MANU_REF_CFG Manual reference mode configuration." }
        case 0xc6bc + 0x002 { return "DPLL_CTRL_3.DPLL_DAMPING DPLL loop filter damping factor." }
        case 0xc6bc + 0x003 { return "DPLL_CTRL_3.DPLL_DECIMATOR_BW_MULT DPLL loop filter decimator bandwidth multiplier." }
        case 0xc6bc + 0x004 { return "DPLL_CTRL_3.DPLL_BW DPLL loop filter bandwidth." }
        case 0xc6bc + 0x006 { return "DPLL_CTRL_3.DPLL_PSL DPLL loop filter phase slope limit." }
        case 0xc6bc + 0x008 { return "DPLL_CTRL_3.DPLL_PRED0_DAMPING Predefined configuration 0 loop filter damping factor." }
        case 0xc6bc + 0x009 { return "DPLL_CTRL_3.DPLL_PRED0_DECIMATOR_BW_MULT Predefined configuration 0 loop filter decimator bandwidth multiplier." }
        case 0xc6bc + 0x00A { return "DPLL_CTRL_3.DPLL_PRED0_BW Predefined configuration 0 loop filter bandwidth." }
        case 0xc6bc + 0x00C { return "DPLL_CTRL_3.DPLL_PRED0_PSL Predefined configuration 0 loop filter phase slope limit." }
        case 0xc6bc + 0x00E { return "DPLL_CTRL_3.DPLL_PRED1_DAMPING Predefined configuration 1 loop filter damping factor." }
        case 0xc6bc + 0x00F { return "DPLL_CTRL_3.DPLL_PRED1_DECIMATOR_BW_MULT Predefined configuration 1 loop filter decimator bandwidth multiplier." }
        case 0xc6bc + 0x010 { return "DPLL_CTRL_3.DPLL_PRED1_BW Predefined configuration 1 loop filter bandwidth." }
        case 0xc6bc + 0x012 { return "DPLL_CTRL_3.DPLL_PRED1_PSL Predefined configuration 1 loop filter phase slope limit." }
        case 0xc6bc + 0x014 { return "DPLL_CTRL_3.DPLL_PHASE_OFFSET_CFG DPLL phase offset configuration." }
        case 0xc6bc + 0x019 { return "DPLL_CTRL_3.DPLL_HO_HISTORY_RESET Reset advanced holdover history." }
        case 0xc6bc + 0x01A { return "DPLL_CTRL_3.DPLL_FINE_PHASE_ADV_CFG DPLL fine phase advance adjustment configuration." }
        case 0xc6bc + 0x01C { return "DPLL_CTRL_3.DPLL_FOD_FREQ Fractional Output Divider (FOD) frequency in Hz." }
        case 0xc6bc + 0x024 { return "DPLL_CTRL_3.DPLL_MASTER_DIV Master divider value." }
        case 0xc6bc + 0x028 { return "DPLL_CTRL_3.DPLL_COMBO_SW_VALUE_CNFG DCO value to be added to the combo bus in SW combo mode." }
        case 0xc6bc + 0x030 { return "DPLL_CTRL_3.DPLL_MANUAL_HOLDOVER_VALUE DCO value to be used in manual holdover mode." }
        case 0xc6bc + 0x036 { return "DPLL_CTRL_3.DPLL_DCD_FILTER_CNFG DPLL DCD filter configuration." }
        case 0xc6bc + 0x038 { return "DPLL_CTRL_3.DPLL_COMBO_MASTER_BW DPLL combo filter bandwidth." }
        case 0xc6bc + 0x03A { return "DPLL_CTRL_3.DPLL_COMBO_MASTER_CFG DPLL combo master configuration." }
        case 0xc6bc + 0x03B { return "DPLL_CTRL_3.DPLL_FRAME_PULSE_SYNC Frame pulse sync trigger" }

        case 0xc700 + 0x000 { return "DPLL_CTRL_4.DPLL_HS_TIE_RESET Reset hitless switching time interval error." }
        case 0xc700 + 0x001 { return "DPLL_CTRL_4.DPLL_MANU_REF_CFG Manual reference mode configuration." }
        case 0xc700 + 0x002 { return "DPLL_CTRL_4.DPLL_DAMPING DPLL loop filter damping factor." }
        case 0xc700 + 0x003 { return "DPLL_CTRL_4.DPLL_DECIMATOR_BW_MULT DPLL loop filter decimator bandwidth multiplier." }
        case 0xc700 + 0x004 { return "DPLL_CTRL_4.DPLL_BW DPLL loop filter bandwidth." }
        case 0xc700 + 0x006 { return "DPLL_CTRL_4.DPLL_PSL DPLL loop filter phase slope limit." }
        case 0xc700 + 0x008 { return "DPLL_CTRL_4.DPLL_PRED0_DAMPING Predefined configuration 0 loop filter damping factor." }
        case 0xc700 + 0x009 { return "DPLL_CTRL_4.DPLL_PRED0_DECIMATOR_BW_MULT Predefined configuration 0 loop filter decimator bandwidth multiplier." }
        case 0xc700 + 0x00A { return "DPLL_CTRL_4.DPLL_PRED0_BW Predefined configuration 0 loop filter bandwidth." }
        case 0xc700 + 0x00C { return "DPLL_CTRL_4.DPLL_PRED0_PSL Predefined configuration 0 loop filter phase slope limit." }
        case 0xc700 + 0x00E { return "DPLL_CTRL_4.DPLL_PRED1_DAMPING Predefined configuration 1 loop filter damping factor." }
        case 0xc700 + 0x00F { return "DPLL_CTRL_4.DPLL_PRED1_DECIMATOR_BW_MULT Predefined configuration 1 loop filter decimator bandwidth multiplier." }
        case 0xc700 + 0x010 { return "DPLL_CTRL_4.DPLL_PRED1_BW Predefined configuration 1 loop filter bandwidth." }
        case 0xc700 + 0x012 { return "DPLL_CTRL_4.DPLL_PRED1_PSL Predefined configuration 1 loop filter phase slope limit." }
        case 0xc700 + 0x014 { return "DPLL_CTRL_4.DPLL_PHASE_OFFSET_CFG DPLL phase offset configuration." }
        case 0xc700 + 0x019 { return "DPLL_CTRL_4.DPLL_HO_HISTORY_RESET Reset advanced holdover history." }
        case 0xc700 + 0x01A { return "DPLL_CTRL_4.DPLL_FINE_PHASE_ADV_CFG DPLL fine phase advance adjustment configuration." }
        case 0xc700 + 0x01C { return "DPLL_CTRL_4.DPLL_FOD_FREQ Fractional Output Divider (FOD) frequency in Hz." }
        case 0xc700 + 0x024 { return "DPLL_CTRL_4.DPLL_MASTER_DIV Master divider value." }
        case 0xc700 + 0x028 { return "DPLL_CTRL_4.DPLL_COMBO_SW_VALUE_CNFG DCO value to be added to the combo bus in SW combo mode." }
        case 0xc700 + 0x030 { return "DPLL_CTRL_4.DPLL_MANUAL_HOLDOVER_VALUE DCO value to be used in manual holdover mode." }
        case 0xc700 + 0x036 { return "DPLL_CTRL_4.DPLL_DCD_FILTER_CNFG DPLL DCD filter configuration." }
        case 0xc700 + 0x038 { return "DPLL_CTRL_4.DPLL_COMBO_MASTER_BW DPLL combo filter bandwidth." }
        case 0xc700 + 0x03A { return "DPLL_CTRL_4.DPLL_COMBO_MASTER_CFG DPLL combo master configuration." }
        case 0xc700 + 0x03B { return "DPLL_CTRL_4.DPLL_FRAME_PULSE_SYNC Frame pulse sync trigger" }

        case 0xc73c + 0x000 { return "DPLL_CTRL_5.DPLL_HS_TIE_RESET Reset hitless switching time interval error." }
        case 0xc73c + 0x001 { return "DPLL_CTRL_5.DPLL_MANU_REF_CFG Manual reference mode configuration." }
        case 0xc73c + 0x002 { return "DPLL_CTRL_5.DPLL_DAMPING DPLL loop filter damping factor." }
        case 0xc73c + 0x003 { return "DPLL_CTRL_5.DPLL_DECIMATOR_BW_MULT DPLL loop filter decimator bandwidth multiplier." }
        case 0xc73c + 0x004 { return "DPLL_CTRL_5.DPLL_BW DPLL loop filter bandwidth." }
        case 0xc73c + 0x006 { return "DPLL_CTRL_5.DPLL_PSL DPLL loop filter phase slope limit." }
        case 0xc73c + 0x008 { return "DPLL_CTRL_5.DPLL_PRED0_DAMPING Predefined configuration 0 loop filter damping factor." }
        case 0xc73c + 0x009 { return "DPLL_CTRL_5.DPLL_PRED0_DECIMATOR_BW_MULT Predefined configuration 0 loop filter decimator bandwidth multiplier." }
        case 0xc73c + 0x00A { return "DPLL_CTRL_5.DPLL_PRED0_BW Predefined configuration 0 loop filter bandwidth." }
        case 0xc73c + 0x00C { return "DPLL_CTRL_5.DPLL_PRED0_PSL Predefined configuration 0 loop filter phase slope limit." }
        case 0xc73c + 0x00E { return "DPLL_CTRL_5.DPLL_PRED1_DAMPING Predefined configuration 1 loop filter damping factor." }
        case 0xc73c + 0x00F { return "DPLL_CTRL_5.DPLL_PRED1_DECIMATOR_BW_MULT Predefined configuration 1 loop filter decimator bandwidth multiplier." }
        case 0xc73c + 0x010 { return "DPLL_CTRL_5.DPLL_PRED1_BW Predefined configuration 1 loop filter bandwidth." }
        case 0xc73c + 0x012 { return "DPLL_CTRL_5.DPLL_PRED1_PSL Predefined configuration 1 loop filter phase slope limit." }
        case 0xc73c + 0x014 { return "DPLL_CTRL_5.DPLL_PHASE_OFFSET_CFG DPLL phase offset configuration." }
        case 0xc73c + 0x019 { return "DPLL_CTRL_5.DPLL_HO_HISTORY_RESET Reset advanced holdover history." }
        case 0xc73c + 0x01A { return "DPLL_CTRL_5.DPLL_FINE_PHASE_ADV_CFG DPLL fine phase advance adjustment configuration." }
        case 0xc73c + 0x01C { return "DPLL_CTRL_5.DPLL_FOD_FREQ Fractional Output Divider (FOD) frequency in Hz." }
        case 0xc73c + 0x024 { return "DPLL_CTRL_5.DPLL_MASTER_DIV Master divider value." }
        case 0xc73c + 0x028 { return "DPLL_CTRL_5.DPLL_COMBO_SW_VALUE_CNFG DCO value to be added to the combo bus in SW combo mode." }
        case 0xc73c + 0x030 { return "DPLL_CTRL_5.DPLL_MANUAL_HOLDOVER_VALUE DCO value to be used in manual holdover mode." }
        case 0xc73c + 0x036 { return "DPLL_CTRL_5.DPLL_DCD_FILTER_CNFG DPLL DCD filter configuration." }
        case 0xc73c + 0x038 { return "DPLL_CTRL_5.DPLL_COMBO_MASTER_BW DPLL combo filter bandwidth." }
        case 0xc73c + 0x03A { return "DPLL_CTRL_5.DPLL_COMBO_MASTER_CFG DPLL combo master configuration." }
        case 0xc73c + 0x03B { return "DPLL_CTRL_5.DPLL_FRAME_PULSE_SYNC Frame pulse sync trigger" }

        case 0xc780 + 0x000 { return "DPLL_CTRL_6.DPLL_HS_TIE_RESET Reset hitless switching time interval error." }
        case 0xc780 + 0x001 { return "DPLL_CTRL_6.DPLL_MANU_REF_CFG Manual reference mode configuration." }
        case 0xc780 + 0x002 { return "DPLL_CTRL_6.DPLL_DAMPING DPLL loop filter damping factor." }
        case 0xc780 + 0x003 { return "DPLL_CTRL_6.DPLL_DECIMATOR_BW_MULT DPLL loop filter decimator bandwidth multiplier." }
        case 0xc780 + 0x004 { return "DPLL_CTRL_6.DPLL_BW DPLL loop filter bandwidth." }
        case 0xc780 + 0x006 { return "DPLL_CTRL_6.DPLL_PSL DPLL loop filter phase slope limit." }
        case 0xc780 + 0x008 { return "DPLL_CTRL_6.DPLL_PRED0_DAMPING Predefined configuration 0 loop filter damping factor." }
        case 0xc780 + 0x009 { return "DPLL_CTRL_6.DPLL_PRED0_DECIMATOR_BW_MULT Predefined configuration 0 loop filter decimator bandwidth multiplier." }
        case 0xc780 + 0x00A { return "DPLL_CTRL_6.DPLL_PRED0_BW Predefined configuration 0 loop filter bandwidth." }
        case 0xc780 + 0x00C { return "DPLL_CTRL_6.DPLL_PRED0_PSL Predefined configuration 0 loop filter phase slope limit." }
        case 0xc780 + 0x00E { return "DPLL_CTRL_6.DPLL_PRED1_DAMPING Predefined configuration 1 loop filter damping factor." }
        case 0xc780 + 0x00F { return "DPLL_CTRL_6.DPLL_PRED1_DECIMATOR_BW_MULT Predefined configuration 1 loop filter decimator bandwidth multiplier." }
        case 0xc780 + 0x010 { return "DPLL_CTRL_6.DPLL_PRED1_BW Predefined configuration 1 loop filter bandwidth." }
        case 0xc780 + 0x012 { return "DPLL_CTRL_6.DPLL_PRED1_PSL Predefined configuration 1 loop filter phase slope limit." }
        case 0xc780 + 0x014 { return "DPLL_CTRL_6.DPLL_PHASE_OFFSET_CFG DPLL phase offset configuration." }
        case 0xc780 + 0x019 { return "DPLL_CTRL_6.DPLL_HO_HISTORY_RESET Reset advanced holdover history." }
        case 0xc780 + 0x01A { return "DPLL_CTRL_6.DPLL_FINE_PHASE_ADV_CFG DPLL fine phase advance adjustment configuration." }
        case 0xc780 + 0x01C { return "DPLL_CTRL_6.DPLL_FOD_FREQ Fractional Output Divider (FOD) frequency in Hz." }
        case 0xc780 + 0x024 { return "DPLL_CTRL_6.DPLL_MASTER_DIV Master divider value." }
        case 0xc780 + 0x028 { return "DPLL_CTRL_6.DPLL_COMBO_SW_VALUE_CNFG DCO value to be added to the combo bus in SW combo mode." }
        case 0xc780 + 0x030 { return "DPLL_CTRL_6.DPLL_MANUAL_HOLDOVER_VALUE DCO value to be used in manual holdover mode." }
        case 0xc780 + 0x036 { return "DPLL_CTRL_6.DPLL_DCD_FILTER_CNFG DPLL DCD filter configuration." }
        case 0xc780 + 0x038 { return "DPLL_CTRL_6.DPLL_COMBO_MASTER_BW DPLL combo filter bandwidth." }
        case 0xc780 + 0x03A { return "DPLL_CTRL_6.DPLL_COMBO_MASTER_CFG DPLL combo master configuration." }
        case 0xc780 + 0x03B { return "DPLL_CTRL_6.DPLL_FRAME_PULSE_SYNC Frame pulse sync trigger" }

        case 0xc7bc + 0x000 { return "DPLL_CTRL_7.DPLL_HS_TIE_RESET Reset hitless switching time interval error." }
        case 0xc7bc + 0x001 { return "DPLL_CTRL_7.DPLL_MANU_REF_CFG Manual reference mode configuration." }
        case 0xc7bc + 0x002 { return "DPLL_CTRL_7.DPLL_DAMPING DPLL loop filter damping factor." }
        case 0xc7bc + 0x003 { return "DPLL_CTRL_7.DPLL_DECIMATOR_BW_MULT DPLL loop filter decimator bandwidth multiplier." }
        case 0xc7bc + 0x004 { return "DPLL_CTRL_7.DPLL_BW DPLL loop filter bandwidth." }
        case 0xc7bc + 0x006 { return "DPLL_CTRL_7.DPLL_PSL DPLL loop filter phase slope limit." }
        case 0xc7bc + 0x008 { return "DPLL_CTRL_7.DPLL_PRED0_DAMPING Predefined configuration 0 loop filter damping factor." }
        case 0xc7bc + 0x009 { return "DPLL_CTRL_7.DPLL_PRED0_DECIMATOR_BW_MULT Predefined configuration 0 loop filter decimator bandwidth multiplier." }
        case 0xc7bc + 0x00A { return "DPLL_CTRL_7.DPLL_PRED0_BW Predefined configuration 0 loop filter bandwidth." }
        case 0xc7bc + 0x00C { return "DPLL_CTRL_7.DPLL_PRED0_PSL Predefined configuration 0 loop filter phase slope limit." }
        case 0xc7bc + 0x00E { return "DPLL_CTRL_7.DPLL_PRED1_DAMPING Predefined configuration 1 loop filter damping factor." }
        case 0xc7bc + 0x00F { return "DPLL_CTRL_7.DPLL_PRED1_DECIMATOR_BW_MULT Predefined configuration 1 loop filter decimator bandwidth multiplier." }
        case 0xc7bc + 0x010 { return "DPLL_CTRL_7.DPLL_PRED1_BW Predefined configuration 1 loop filter bandwidth." }
        case 0xc7bc + 0x012 { return "DPLL_CTRL_7.DPLL_PRED1_PSL Predefined configuration 1 loop filter phase slope limit." }
        case 0xc7bc + 0x014 { return "DPLL_CTRL_7.DPLL_PHASE_OFFSET_CFG DPLL phase offset configuration." }
        case 0xc7bc + 0x019 { return "DPLL_CTRL_7.DPLL_HO_HISTORY_RESET Reset advanced holdover history." }
        case 0xc7bc + 0x01A { return "DPLL_CTRL_7.DPLL_FINE_PHASE_ADV_CFG DPLL fine phase advance adjustment configuration." }
        case 0xc7bc + 0x01C { return "DPLL_CTRL_7.DPLL_FOD_FREQ Fractional Output Divider (FOD) frequency in Hz." }
        case 0xc7bc + 0x024 { return "DPLL_CTRL_7.DPLL_MASTER_DIV Master divider value." }
        case 0xc7bc + 0x028 { return "DPLL_CTRL_7.DPLL_COMBO_SW_VALUE_CNFG DCO value to be added to the combo bus in SW combo mode." }
        case 0xc7bc + 0x030 { return "DPLL_CTRL_7.DPLL_MANUAL_HOLDOVER_VALUE DCO value to be used in manual holdover mode." }
        case 0xc7bc + 0x036 { return "DPLL_CTRL_7.DPLL_DCD_FILTER_CNFG DPLL DCD filter configuration." }
        case 0xc7bc + 0x038 { return "DPLL_CTRL_7.DPLL_COMBO_MASTER_BW DPLL combo filter bandwidth." }
        case 0xc7bc + 0x03A { return "DPLL_CTRL_7.DPLL_COMBO_MASTER_CFG DPLL combo master configuration." }
        case 0xc7bc + 0x03B { return "DPLL_CTRL_7.DPLL_FRAME_PULSE_SYNC Frame pulse sync trigger" }


        case 0xC800 + 0x000 { return "SYS_DPLL_CTRL.SYS_DPLL_MANU_REF_CFG Manual reference mode configuration." }
        case 0xC800 + 0x001 { return "SYS_DPLL_CTRL.SYS_DPLL_DAMPING System DPLL loop filter damping factor." }
        case 0xC800 + 0x002 { return "SYS_DPLL_CTRL.SYS_DPLL_DECIMATOR_BW_MULT System DPLL loop filter decimator bandwidth multiplier." }
        case 0xC800 + 0x004 { return "SYS_DPLL_CTRL.SYS_DPLL_BW System DPLL loop filter bandwidth." }
        case 0xC800 + 0x006 { return "SYS_DPLL_CTRL.SYS_DPLL_PSL System DPLL loop filter phase slope limit." }
        case 0xC800 + 0x008 { return "SYS_DPLL_CTRL.SYS_DPLL_PRED0_DAMPING Predefined configuration 0 loop filter damping factor." }
        case 0xC800 + 0x009 { return "SYS_DPLL_CTRL.SYS_DPLL_PRED0_DECIMATOR_BW_MULT Predefined configuration 0 loop filter decimator bandwidth multiplier." }
        case 0xC800 + 0x00A { return "SYS_DPLL_CTRL.SYS_DPLL_PRED0_BW Predefined configuration 0 loop filter bandwidth." }
        case 0xC800 + 0x00C { return "SYS_DPLL_CTRL.SYS_DPLL_PRED0_PSL Predefined configuration 0 loop filter phase slope limit." }
        case 0xC800 + 0x00E { return "SYS_DPLL_CTRL.SYS_DPLL_PRED1_DAMPING Predefined configuration 1 loop filter damping factor." }
        case 0xC800 + 0x00F { return "SYS_DPLL_CTRL.SYS_DPLL_PRED1_DECIMATOR_BW_MULT Predefined configuration 1 loop filter decimator bandwidth multiplier." }
        case 0xC800 + 0x010 { return "SYS_DPLL_CTRL.SYS_DPLL_PRED1_BW Predefined configuration 1 loop filter bandwidth." }
        case 0xC800 + 0x012 { return "SYS_DPLL_CTRL.SYS_DPLL_PRED1_PSL Predefined configuration 1 loop filter phase slope limit." }
        case 0xC800 + 0x014 { return "SYS_DPLL_CTRL.SYS_DPLL_COMBO_MASTER_BW System DPLL combo filter bandwidth." }
        case 0xC800 + 0x016 { return "SYS_DPLL_CTRL.SYS_DPLL_COMBO_MASTER_CFG DPLL combo master configuration" }

        case 0xc818 + 0x000 { return "DPLL_PHASE_0.DPLL_WRITE_PH Set phase offset in write phase mode" }
        case 0xc81c + 0x000 { return "DPLL_PHASE_1.DPLL_WRITE_PH Set phase offset in write phase mode" }
        case 0xc820 + 0x000 { return "DPLL_PHASE_2.DPLL_WRITE_PH Set phase offset in write phase mode" }
        case 0xc824 + 0x000 { return "DPLL_PHASE_3.DPLL_WRITE_PH Set phase offset in write phase mode" }
        case 0xc828 + 0x000 { return "DPLL_PHASE_4.DPLL_WRITE_PH Set phase offset in write phase mode" }
        case 0xc82c + 0x000 { return "DPLL_PHASE_5.DPLL_WRITE_PH Set phase offset in write phase mode" }
        case 0xc830 + 0x000 { return "DPLL_PHASE_6.DPLL_WRITE_PH Set phase offset in write phase mode" }
        case 0xc834 + 0x000 { return "DPLL_PHASE_7.DPLL_WRITE_PH Set phase offset in write phase mode" }

        case 0xc838 + 0x000 { return "DPLL_FREQ_0.DPLL_WR_FREQ Set DPLL frequency offset in write frequency mode." }
        case 0xc840 + 0x000 { return "DPLL_FREQ_1.DPLL_WR_FREQ Set DPLL frequency offset in write frequency mode." }
        case 0xc848 + 0x000 { return "DPLL_FREQ_2.DPLL_WR_FREQ Set DPLL frequency offset in write frequency mode." }
        case 0xc850 + 0x000 { return "DPLL_FREQ_3.DPLL_WR_FREQ Set DPLL frequency offset in write frequency mode." }
        case 0xc858 + 0x000 { return "DPLL_FREQ_4.DPLL_WR_FREQ Set DPLL frequency offset in write frequency mode." }
        case 0xc860 + 0x000 { return "DPLL_FREQ_5.DPLL_WR_FREQ Set DPLL frequency offset in write frequency mode." }
        case 0xc868 + 0x000 { return "DPLL_FREQ_6.DPLL_WR_FREQ Set DPLL frequency offset in write frequency mode." }
        case 0xc870 + 0x000 { return "DPLL_FREQ_7.DPLL_WR_FREQ Set DPLL frequency offset in write frequency mode." }

        case 0xc880 + 0x000 { return "DPLL_PHASE_PULL_IN_0.DPLL_PHASE_PULL_IN_OFFSET Phase pull-in offset." }
        case 0xc880 + 0x004 { return "DPLL_PHASE_PULL_IN_0.DPLL_PHASE_PULL_IN_SLOPE_LIMIT Phase pull-in slope limit." }
        case 0xc880 + 0x007 { return "DPLL_PHASE_PULL_IN_0.DPLL_PHASE_PUL L_IN_CTRLPhase pull-in configuration." }

        case 0xc888 + 0x000 { return "DPLL_PHASE_PULL_IN_1.DPLL_PHASE_PULL_IN_OFFSET Phase pull-in offset." }
        case 0xc888 + 0x004 { return "DPLL_PHASE_PULL_IN_1.DPLL_PHASE_PULL_IN_SLOPE_LIMIT Phase pull-in slope limit." }
        case 0xc888 + 0x007 { return "DPLL_PHASE_PULL_IN_1.DPLL_PHASE_PUL L_IN_CTRLPhase pull-in configuration." }

        case 0xc890 + 0x000 { return "DPLL_PHASE_PULL_IN_2.DPLL_PHASE_PULL_IN_OFFSET Phase pull-in offset." }
        case 0xc890 + 0x004 { return "DPLL_PHASE_PULL_IN_2.DPLL_PHASE_PULL_IN_SLOPE_LIMIT Phase pull-in slope limit." }
        case 0xc890 + 0x007 { return "DPLL_PHASE_PULL_IN_2.DPLL_PHASE_PUL L_IN_CTRLPhase pull-in configuration." }

        case 0xc898 + 0x000 { return "DPLL_PHASE_PULL_IN_3.DPLL_PHASE_PULL_IN_OFFSET Phase pull-in offset." }
        case 0xc898 + 0x004 { return "DPLL_PHASE_PULL_IN_3.DPLL_PHASE_PULL_IN_SLOPE_LIMIT Phase pull-in slope limit." }
        case 0xc898 + 0x007 { return "DPLL_PHASE_PULL_IN_3.DPLL_PHASE_PUL L_IN_CTRLPhase pull-in configuration." }

        case 0xc8a0 + 0x000 { return "DPLL_PHASE_PULL_IN_4.DPLL_PHASE_PULL_IN_OFFSET Phase pull-in offset." }
        case 0xc8a0 + 0x004 { return "DPLL_PHASE_PULL_IN_4.DPLL_PHASE_PULL_IN_SLOPE_LIMIT Phase pull-in slope limit." }
        case 0xc8a0 + 0x007 { return "DPLL_PHASE_PULL_IN_4.DPLL_PHASE_PUL L_IN_CTRLPhase pull-in configuration." }

        case 0xc8a8 + 0x000 { return "DPLL_PHASE_PULL_IN_5.DPLL_PHASE_PULL_IN_OFFSET Phase pull-in offset." }
        case 0xc8a8 + 0x004 { return "DPLL_PHASE_PULL_IN_5.DPLL_PHASE_PULL_IN_SLOPE_LIMIT Phase pull-in slope limit." }
        case 0xc8a8 + 0x007 { return "DPLL_PHASE_PULL_IN_5.DPLL_PHASE_PUL L_IN_CTRLPhase pull-in configuration." }

        case 0xc8b0 + 0x000 { return "DPLL_PHASE_PULL_IN_6.DPLL_PHASE_PULL_IN_OFFSET Phase pull-in offset." }
        case 0xc8b0 + 0x004 { return "DPLL_PHASE_PULL_IN_6.DPLL_PHASE_PULL_IN_SLOPE_LIMIT Phase pull-in slope limit." }
        case 0xc8b0 + 0x007 { return "DPLL_PHASE_PULL_IN_6.DPLL_PHASE_PUL L_IN_CTRLPhase pull-in configuration." }

        case 0xc8b8 + 0x000 { return "DPLL_PHASE_PULL_IN_7.DPLL_PHASE_PULL_IN_OFFSET Phase pull-in offset." }
        case 0xc8b8 + 0x004 { return "DPLL_PHASE_PULL_IN_7.DPLL_PHASE_PULL_IN_SLOPE_LIMIT Phase pull-in slope limit." }
        case 0xc8b8 + 0x007 { return "DPLL_PHASE_PULL_IN_7.DPLL_PHASE_PUL L_IN_CTRLPhase pull-in configuration." }

        case 0xc8c0 + 0x000 { return "GPIO_CFG.GPIO_CFG_GBL Global GPIO parameters." }

        case 0xc8c2 + 0x000 { return "GPIO_0.GPIO_DCO_INC_DEC Increment/decrement DCO FFO configuration." }
        case 0xc8c2 + 0x001 { return "GPIO_0.GPIO_OUT_CTRL_0 GPIO controlled output squelch for outputs 0-7." }
        case 0xc8c2 + 0x002 { return "GPIO_0.GPIO_OUT_CTRL_1 GPIO controlled output squelch for outputs 8-11." }
        case 0xc8c2 + 0x003 { return "GPIO_0.GPIO_TOD_TRIG GPIO controlled TOD trigger input." }
        case 0xc8c2 + 0x004 { return "GPIO_0.GPIO_DPLL_INDICATOR GPIO indicator for DPLL lock and holdover states." }
        case 0xc8c2 + 0x005 { return "GPIO_0.GPIO_LOS_INDICATOR GPIO loss of signal (LOS) indicator." }
        case 0xc8c2 + 0x006 { return "GPIO_0.GPIO_REF_INPUT_DSQ_0 GPIO controlled input disqualification for inputs 0-7." }
        case 0xc8c2 + 0x007 { return "GPIO_0.GPIO_REF_INPUT_DSQ_1 GPIO controlled input disqualification for inputs 8-15." }
        case 0xc8c2 + 0x008 { return "GPIO_0.GPIO_REF_INPUT_DSQ_2 GPIO controlled input disqualification for DPLLs." }
        case 0xc8c2 + 0x009 { return "GPIO_0.GPIO_REF_INPUT_DSQ_3 GPIO controlled input disqualification for system DPLL and disqualification level." }
        case 0xc8c2 + 0x00A { return "GPIO_0.GPIO_MAN_CLK_SEL_0 Configure inputs for GPIO manual clock selection." }
        case 0xc8c2 + 0x00B { return "GPIO_0.GPIO_MAN_CLK_SEL_1 Select DPLLs for GPIO manual clock selection." }
        case 0xc8c2 + 0x00C { return "GPIO_0.GPIO_MAN_CLK_SEL_2 Select system DPLL for GPIO manual clock selection." }
        case 0xc8c2 + 0x00D { return "GPIO_0.GPIO_SLAVE GPIO controlled device slave configuration." }
        case 0xc8c2 + 0x00E { return "GPIO_0.GPIO_ALERT_OUT_CFG GPIO alert notification." }
        case 0xc8c2 + 0x00F { return "GPIO_0.GPIO_TOD_NOTIFICATION_CFG GPIO configuration for DPLL TOD read notification." }
        case 0xc8c2 + 0x010 { return "RESERVED " }
        case 0xc8c2 + 0x011 { return "GPIO_0.GPIO_CTRL GPIO control." }

        case 0xc8d4 + 0x000 { return "GPIO_1.GPIO_DCO_INC_DEC Increment/decrement DCO FFO configuration." }
        case 0xc8d4 + 0x001 { return "GPIO_1.GPIO_OUT_CTRL_0 GPIO controlled output squelch for outputs 0-7." }
        case 0xc8d4 + 0x002 { return "GPIO_1.GPIO_OUT_CTRL_1 GPIO controlled output squelch for outputs 8-11." }
        case 0xc8d4 + 0x003 { return "GPIO_1.GPIO_TOD_TRIG GPIO controlled TOD trigger input." }
        case 0xc8d4 + 0x004 { return "GPIO_1.GPIO_DPLL_INDICATOR GPIO indicator for DPLL lock and holdover states." }
        case 0xc8d4 + 0x005 { return "GPIO_1.GPIO_LOS_INDICATOR GPIO loss of signal (LOS) indicator." }
        case 0xc8d4 + 0x006 { return "GPIO_1.GPIO_REF_INPUT_DSQ_0 GPIO controlled input disqualification for inputs 0-7." }
        case 0xc8d4 + 0x007 { return "GPIO_1.GPIO_REF_INPUT_DSQ_1 GPIO controlled input disqualification for inputs 8-15." }
        case 0xc8d4 + 0x008 { return "GPIO_1.GPIO_REF_INPUT_DSQ_2 GPIO controlled input disqualification for DPLLs." }
        case 0xc8d4 + 0x009 { return "GPIO_1.GPIO_REF_INPUT_DSQ_3 GPIO controlled input disqualification for system DPLL and disqualification level." }
        case 0xc8d4 + 0x00A { return "GPIO_1.GPIO_MAN_CLK_SEL_0 Configure inputs for GPIO manual clock selection." }
        case 0xc8d4 + 0x00B { return "GPIO_1.GPIO_MAN_CLK_SEL_1 Select DPLLs for GPIO manual clock selection." }
        case 0xc8d4 + 0x00C { return "GPIO_1.GPIO_MAN_CLK_SEL_2 Select system DPLL for GPIO manual clock selection." }
        case 0xc8d4 + 0x00D { return "GPIO_1.GPIO_SLAVE GPIO controlled device slave configuration." }
        case 0xc8d4 + 0x00E { return "GPIO_1.GPIO_ALERT_OUT_CFG GPIO alert notification." }
        case 0xc8d4 + 0x00F { return "GPIO_1.GPIO_TOD_NOTIFICATION_CFG GPIO configuration for DPLL TOD read notification." }
        case 0xc8d4 + 0x010 { return "RESERVED " }
        case 0xc8d4 + 0x011 { return "GPIO_1.GPIO_CTRL GPIO control." }

        case 0xc8e6 + 0x000 { return "GPIO_2.GPIO_DCO_INC_DEC Increment/decrement DCO FFO configuration." }
        case 0xc8e6 + 0x001 { return "GPIO_2.GPIO_OUT_CTRL_0 GPIO controlled output squelch for outputs 0-7." }
        case 0xc8e6 + 0x002 { return "GPIO_2.GPIO_OUT_CTRL_1 GPIO controlled output squelch for outputs 8-11." }
        case 0xc8e6 + 0x003 { return "GPIO_2.GPIO_TOD_TRIG GPIO controlled TOD trigger input." }
        case 0xc8e6 + 0x004 { return "GPIO_2.GPIO_DPLL_INDICATOR GPIO indicator for DPLL lock and holdover states." }
        case 0xc8e6 + 0x005 { return "GPIO_2.GPIO_LOS_INDICATOR GPIO loss of signal (LOS) indicator." }
        case 0xc8e6 + 0x006 { return "GPIO_2.GPIO_REF_INPUT_DSQ_0 GPIO controlled input disqualification for inputs 0-7." }
        case 0xc8e6 + 0x007 { return "GPIO_2.GPIO_REF_INPUT_DSQ_1 GPIO controlled input disqualification for inputs 8-15." }
        case 0xc8e6 + 0x008 { return "GPIO_2.GPIO_REF_INPUT_DSQ_2 GPIO controlled input disqualification for DPLLs." }
        case 0xc8e6 + 0x009 { return "GPIO_2.GPIO_REF_INPUT_DSQ_3 GPIO controlled input disqualification for system DPLL and disqualification level." }
        case 0xc8e6 + 0x00A { return "GPIO_2.GPIO_MAN_CLK_SEL_0 Configure inputs for GPIO manual clock selection." }
        case 0xc8e6 + 0x00B { return "GPIO_2.GPIO_MAN_CLK_SEL_1 Select DPLLs for GPIO manual clock selection." }
        case 0xc8e6 + 0x00C { return "GPIO_2.GPIO_MAN_CLK_SEL_2 Select system DPLL for GPIO manual clock selection." }
        case 0xc8e6 + 0x00D { return "GPIO_2.GPIO_SLAVE GPIO controlled device slave configuration." }
        case 0xc8e6 + 0x00E { return "GPIO_2.GPIO_ALERT_OUT_CFG GPIO alert notification." }
        case 0xc8e6 + 0x00F { return "GPIO_2.GPIO_TOD_NOTIFICATION_CFG GPIO configuration for DPLL TOD read notification." }
        case 0xc8e6 + 0x010 { return "RESERVED " }
        case 0xc8e6 + 0x011 { return "GPIO_2.GPIO_CTRL GPIO control." }

        case 0xc900 + 0x000 { return "GPIO_3.GPIO_DCO_INC_DEC Increment/decrement DCO FFO configuration." }
        case 0xc900 + 0x001 { return "GPIO_3.GPIO_OUT_CTRL_0 GPIO controlled output squelch for outputs 0-7." }
        case 0xc900 + 0x002 { return "GPIO_3.GPIO_OUT_CTRL_1 GPIO controlled output squelch for outputs 8-11." }
        case 0xc900 + 0x003 { return "GPIO_3.GPIO_TOD_TRIG GPIO controlled TOD trigger input." }
        case 0xc900 + 0x004 { return "GPIO_3.GPIO_DPLL_INDICATOR GPIO indicator for DPLL lock and holdover states." }
        case 0xc900 + 0x005 { return "GPIO_3.GPIO_LOS_INDICATOR GPIO loss of signal (LOS) indicator." }
        case 0xc900 + 0x006 { return "GPIO_3.GPIO_REF_INPUT_DSQ_0 GPIO controlled input disqualification for inputs 0-7." }
        case 0xc900 + 0x007 { return "GPIO_3.GPIO_REF_INPUT_DSQ_1 GPIO controlled input disqualification for inputs 8-15." }
        case 0xc900 + 0x008 { return "GPIO_3.GPIO_REF_INPUT_DSQ_2 GPIO controlled input disqualification for DPLLs." }
        case 0xc900 + 0x009 { return "GPIO_3.GPIO_REF_INPUT_DSQ_3 GPIO controlled input disqualification for system DPLL and disqualification level." }
        case 0xc900 + 0x00A { return "GPIO_3.GPIO_MAN_CLK_SEL_0 Configure inputs for GPIO manual clock selection." }
        case 0xc900 + 0x00B { return "GPIO_3.GPIO_MAN_CLK_SEL_1 Select DPLLs for GPIO manual clock selection." }
        case 0xc900 + 0x00C { return "GPIO_3.GPIO_MAN_CLK_SEL_2 Select system DPLL for GPIO manual clock selection." }
        case 0xc900 + 0x00D { return "GPIO_3.GPIO_SLAVE GPIO controlled device slave configuration." }
        case 0xc900 + 0x00E { return "GPIO_3.GPIO_ALERT_OUT_CFG GPIO alert notification." }
        case 0xc900 + 0x00F { return "GPIO_3.GPIO_TOD_NOTIFICATION_CFG GPIO configuration for DPLL TOD read notification." }
        case 0xc900 + 0x010 { return "RESERVED " }
        case 0xc900 + 0x011 { return "GPIO_3.GPIO_CTRL GPIO control." }

        case 0xc912 + 0x000 { return "GPIO_4.GPIO_DCO_INC_DEC Increment/decrement DCO FFO configuration." }
        case 0xc912 + 0x001 { return "GPIO_4.GPIO_OUT_CTRL_0 GPIO controlled output squelch for outputs 0-7." }
        case 0xc912 + 0x002 { return "GPIO_4.GPIO_OUT_CTRL_1 GPIO controlled output squelch for outputs 8-11." }
        case 0xc912 + 0x003 { return "GPIO_4.GPIO_TOD_TRIG GPIO controlled TOD trigger input." }
        case 0xc912 + 0x004 { return "GPIO_4.GPIO_DPLL_INDICATOR GPIO indicator for DPLL lock and holdover states." }
        case 0xc912 + 0x005 { return "GPIO_4.GPIO_LOS_INDICATOR GPIO loss of signal (LOS) indicator." }
        case 0xc912 + 0x006 { return "GPIO_4.GPIO_REF_INPUT_DSQ_0 GPIO controlled input disqualification for inputs 0-7." }
        case 0xc912 + 0x007 { return "GPIO_4.GPIO_REF_INPUT_DSQ_1 GPIO controlled input disqualification for inputs 8-15." }
        case 0xc912 + 0x008 { return "GPIO_4.GPIO_REF_INPUT_DSQ_2 GPIO controlled input disqualification for DPLLs." }
        case 0xc912 + 0x009 { return "GPIO_4.GPIO_REF_INPUT_DSQ_3 GPIO controlled input disqualification for system DPLL and disqualification level." }
        case 0xc912 + 0x00A { return "GPIO_4.GPIO_MAN_CLK_SEL_0 Configure inputs for GPIO manual clock selection." }
        case 0xc912 + 0x00B { return "GPIO_4.GPIO_MAN_CLK_SEL_1 Select DPLLs for GPIO manual clock selection." }
        case 0xc912 + 0x00C { return "GPIO_4.GPIO_MAN_CLK_SEL_2 Select system DPLL for GPIO manual clock selection." }
        case 0xc912 + 0x00D { return "GPIO_4.GPIO_SLAVE GPIO controlled device slave configuration." }
        case 0xc912 + 0x00E { return "GPIO_4.GPIO_ALERT_OUT_CFG GPIO alert notification." }
        case 0xc912 + 0x00F { return "GPIO_4.GPIO_TOD_NOTIFICATION_CFG GPIO configuration for DPLL TOD read notification." }
        case 0xc912 + 0x010 { return "RESERVED " }
        case 0xc912 + 0x011 { return "GPIO_4.GPIO_CTRL GPIO control." }

        case 0xc924 + 0x000 { return "GPIO_5.GPIO_DCO_INC_DEC Increment/decrement DCO FFO configuration." }
        case 0xc924 + 0x001 { return "GPIO_5.GPIO_OUT_CTRL_0 GPIO controlled output squelch for outputs 0-7." }
        case 0xc924 + 0x002 { return "GPIO_5.GPIO_OUT_CTRL_1 GPIO controlled output squelch for outputs 8-11." }
        case 0xc924 + 0x003 { return "GPIO_5.GPIO_TOD_TRIG GPIO controlled TOD trigger input." }
        case 0xc924 + 0x004 { return "GPIO_5.GPIO_DPLL_INDICATOR GPIO indicator for DPLL lock and holdover states." }
        case 0xc924 + 0x005 { return "GPIO_5.GPIO_LOS_INDICATOR GPIO loss of signal (LOS) indicator." }
        case 0xc924 + 0x006 { return "GPIO_5.GPIO_REF_INPUT_DSQ_0 GPIO controlled input disqualification for inputs 0-7." }
        case 0xc924 + 0x007 { return "GPIO_5.GPIO_REF_INPUT_DSQ_1 GPIO controlled input disqualification for inputs 8-15." }
        case 0xc924 + 0x008 { return "GPIO_5.GPIO_REF_INPUT_DSQ_2 GPIO controlled input disqualification for DPLLs." }
        case 0xc924 + 0x009 { return "GPIO_5.GPIO_REF_INPUT_DSQ_3 GPIO controlled input disqualification for system DPLL and disqualification level." }
        case 0xc924 + 0x00A { return "GPIO_5.GPIO_MAN_CLK_SEL_0 Configure inputs for GPIO manual clock selection." }
        case 0xc924 + 0x00B { return "GPIO_5.GPIO_MAN_CLK_SEL_1 Select DPLLs for GPIO manual clock selection." }
        case 0xc924 + 0x00C { return "GPIO_5.GPIO_MAN_CLK_SEL_2 Select system DPLL for GPIO manual clock selection." }
        case 0xc924 + 0x00D { return "GPIO_5.GPIO_SLAVE GPIO controlled device slave configuration." }
        case 0xc924 + 0x00E { return "GPIO_5.GPIO_ALERT_OUT_CFG GPIO alert notification." }
        case 0xc924 + 0x00F { return "GPIO_5.GPIO_TOD_NOTIFICATION_CFG GPIO configuration for DPLL TOD read notification." }
        case 0xc924 + 0x010 { return "RESERVED " }
        case 0xc924 + 0x011 { return "GPIO_5.GPIO_CTRL GPIO control." }

        case 0xc936 + 0x000 { return "GPIO_6.GPIO_DCO_INC_DEC Increment/decrement DCO FFO configuration." }
        case 0xc936 + 0x001 { return "GPIO_6.GPIO_OUT_CTRL_0 GPIO controlled output squelch for outputs 0-7." }
        case 0xc936 + 0x002 { return "GPIO_6.GPIO_OUT_CTRL_1 GPIO controlled output squelch for outputs 8-11." }
        case 0xc936 + 0x003 { return "GPIO_6.GPIO_TOD_TRIG GPIO controlled TOD trigger input." }
        case 0xc936 + 0x004 { return "GPIO_6.GPIO_DPLL_INDICATOR GPIO indicator for DPLL lock and holdover states." }
        case 0xc936 + 0x005 { return "GPIO_6.GPIO_LOS_INDICATOR GPIO loss of signal (LOS) indicator." }
        case 0xc936 + 0x006 { return "GPIO_6.GPIO_REF_INPUT_DSQ_0 GPIO controlled input disqualification for inputs 0-7." }
        case 0xc936 + 0x007 { return "GPIO_6.GPIO_REF_INPUT_DSQ_1 GPIO controlled input disqualification for inputs 8-15." }
        case 0xc936 + 0x008 { return "GPIO_6.GPIO_REF_INPUT_DSQ_2 GPIO controlled input disqualification for DPLLs." }
        case 0xc936 + 0x009 { return "GPIO_6.GPIO_REF_INPUT_DSQ_3 GPIO controlled input disqualification for system DPLL and disqualification level." }
        case 0xc936 + 0x00A { return "GPIO_6.GPIO_MAN_CLK_SEL_0 Configure inputs for GPIO manual clock selection." }
        case 0xc936 + 0x00B { return "GPIO_6.GPIO_MAN_CLK_SEL_1 Select DPLLs for GPIO manual clock selection." }
        case 0xc936 + 0x00C { return "GPIO_6.GPIO_MAN_CLK_SEL_2 Select system DPLL for GPIO manual clock selection." }
        case 0xc936 + 0x00D { return "GPIO_6.GPIO_SLAVE GPIO controlled device slave configuration." }
        case 0xc936 + 0x00E { return "GPIO_6.GPIO_ALERT_OUT_CFG GPIO alert notification." }
        case 0xc936 + 0x00F { return "GPIO_6.GPIO_TOD_NOTIFICATION_CFG GPIO configuration for DPLL TOD read notification." }
        case 0xc936 + 0x010 { return "RESERVED " }
        case 0xc936 + 0x011 { return "GPIO_6.GPIO_CTRL GPIO control." }

        case 0xc948 + 0x000 { return "GPIO_7.GPIO_DCO_INC_DEC Increment/decrement DCO FFO configuration." }
        case 0xc948 + 0x001 { return "GPIO_7.GPIO_OUT_CTRL_0 GPIO controlled output squelch for outputs 0-7." }
        case 0xc948 + 0x002 { return "GPIO_7.GPIO_OUT_CTRL_1 GPIO controlled output squelch for outputs 8-11." }
        case 0xc948 + 0x003 { return "GPIO_7.GPIO_TOD_TRIG GPIO controlled TOD trigger input." }
        case 0xc948 + 0x004 { return "GPIO_7.GPIO_DPLL_INDICATOR GPIO indicator for DPLL lock and holdover states." }
        case 0xc948 + 0x005 { return "GPIO_7.GPIO_LOS_INDICATOR GPIO loss of signal (LOS) indicator." }
        case 0xc948 + 0x006 { return "GPIO_7.GPIO_REF_INPUT_DSQ_0 GPIO controlled input disqualification for inputs 0-7." }
        case 0xc948 + 0x007 { return "GPIO_7.GPIO_REF_INPUT_DSQ_1 GPIO controlled input disqualification for inputs 8-15." }
        case 0xc948 + 0x008 { return "GPIO_7.GPIO_REF_INPUT_DSQ_2 GPIO controlled input disqualification for DPLLs." }
        case 0xc948 + 0x009 { return "GPIO_7.GPIO_REF_INPUT_DSQ_3 GPIO controlled input disqualification for system DPLL and disqualification level." }
        case 0xc948 + 0x00A { return "GPIO_7.GPIO_MAN_CLK_SEL_0 Configure inputs for GPIO manual clock selection." }
        case 0xc948 + 0x00B { return "GPIO_7.GPIO_MAN_CLK_SEL_1 Select DPLLs for GPIO manual clock selection." }
        case 0xc948 + 0x00C { return "GPIO_7.GPIO_MAN_CLK_SEL_2 Select system DPLL for GPIO manual clock selection." }
        case 0xc948 + 0x00D { return "GPIO_7.GPIO_SLAVE GPIO controlled device slave configuration." }
        case 0xc948 + 0x00E { return "GPIO_7.GPIO_ALERT_OUT_CFG GPIO alert notification." }
        case 0xc948 + 0x00F { return "GPIO_7.GPIO_TOD_NOTIFICATION_CFG GPIO configuration for DPLL TOD read notification." }
        case 0xc948 + 0x010 { return "RESERVED " }
        case 0xc948 + 0x011 { return "GPIO_7.GPIO_CTRL GPIO control." }

        case 0xc95a + 0x000 { return "GPIO_8.GPIO_DCO_INC_DEC Increment/decrement DCO FFO configuration." }
        case 0xc95a + 0x001 { return "GPIO_8.GPIO_OUT_CTRL_0 GPIO controlled output squelch for outputs 0-7." }
        case 0xc95a + 0x002 { return "GPIO_8.GPIO_OUT_CTRL_1 GPIO controlled output squelch for outputs 8-11." }
        case 0xc95a + 0x003 { return "GPIO_8.GPIO_TOD_TRIG GPIO controlled TOD trigger input." }
        case 0xc95a + 0x004 { return "GPIO_8.GPIO_DPLL_INDICATOR GPIO indicator for DPLL lock and holdover states." }
        case 0xc95a + 0x005 { return "GPIO_8.GPIO_LOS_INDICATOR GPIO loss of signal (LOS) indicator." }
        case 0xc95a + 0x006 { return "GPIO_8.GPIO_REF_INPUT_DSQ_0 GPIO controlled input disqualification for inputs 0-7." }
        case 0xc95a + 0x007 { return "GPIO_8.GPIO_REF_INPUT_DSQ_1 GPIO controlled input disqualification for inputs 8-15." }
        case 0xc95a + 0x008 { return "GPIO_8.GPIO_REF_INPUT_DSQ_2 GPIO controlled input disqualification for DPLLs." }
        case 0xc95a + 0x009 { return "GPIO_8.GPIO_REF_INPUT_DSQ_3 GPIO controlled input disqualification for system DPLL and disqualification level." }
        case 0xc95a + 0x00A { return "GPIO_8.GPIO_MAN_CLK_SEL_0 Configure inputs for GPIO manual clock selection." }
        case 0xc95a + 0x00B { return "GPIO_8.GPIO_MAN_CLK_SEL_1 Select DPLLs for GPIO manual clock selection." }
        case 0xc95a + 0x00C { return "GPIO_8.GPIO_MAN_CLK_SEL_2 Select system DPLL for GPIO manual clock selection." }
        case 0xc95a + 0x00D { return "GPIO_8.GPIO_SLAVE GPIO controlled device slave configuration." }
        case 0xc95a + 0x00E { return "GPIO_8.GPIO_ALERT_OUT_CFG GPIO alert notification." }
        case 0xc95a + 0x00F { return "GPIO_8.GPIO_TOD_NOTIFICATION_CFG GPIO configuration for DPLL TOD read notification." }
        case 0xc95a + 0x010 { return "RESERVED " }
        case 0xc95a + 0x011 { return "GPIO_8.GPIO_CTRL GPIO control." }

        case 0xc980 + 0x000 { return "GPIO_9.GPIO_DCO_INC_DEC Increment/decrement DCO FFO configuration." }
        case 0xc980 + 0x001 { return "GPIO_9.GPIO_OUT_CTRL_0 GPIO controlled output squelch for outputs 0-7." }
        case 0xc980 + 0x002 { return "GPIO_9.GPIO_OUT_CTRL_1 GPIO controlled output squelch for outputs 8-11." }
        case 0xc980 + 0x003 { return "GPIO_9.GPIO_TOD_TRIG GPIO controlled TOD trigger input." }
        case 0xc980 + 0x004 { return "GPIO_9.GPIO_DPLL_INDICATOR GPIO indicator for DPLL lock and holdover states." }
        case 0xc980 + 0x005 { return "GPIO_9.GPIO_LOS_INDICATOR GPIO loss of signal (LOS) indicator." }
        case 0xc980 + 0x006 { return "GPIO_9.GPIO_REF_INPUT_DSQ_0 GPIO controlled input disqualification for inputs 0-7." }
        case 0xc980 + 0x007 { return "GPIO_9.GPIO_REF_INPUT_DSQ_1 GPIO controlled input disqualification for inputs 8-15." }
        case 0xc980 + 0x008 { return "GPIO_9.GPIO_REF_INPUT_DSQ_2 GPIO controlled input disqualification for DPLLs." }
        case 0xc980 + 0x009 { return "GPIO_9.GPIO_REF_INPUT_DSQ_3 GPIO controlled input disqualification for system DPLL and disqualification level." }
        case 0xc980 + 0x00A { return "GPIO_9.GPIO_MAN_CLK_SEL_0 Configure inputs for GPIO manual clock selection." }
        case 0xc980 + 0x00B { return "GPIO_9.GPIO_MAN_CLK_SEL_1 Select DPLLs for GPIO manual clock selection." }
        case 0xc980 + 0x00C { return "GPIO_9.GPIO_MAN_CLK_SEL_2 Select system DPLL for GPIO manual clock selection." }
        case 0xc980 + 0x00D { return "GPIO_9.GPIO_SLAVE GPIO controlled device slave configuration." }
        case 0xc980 + 0x00E { return "GPIO_9.GPIO_ALERT_OUT_CFG GPIO alert notification." }
        case 0xc980 + 0x00F { return "GPIO_9.GPIO_TOD_NOTIFICATION_CFG GPIO configuration for DPLL TOD read notification." }
        case 0xc980 + 0x010 { return "RESERVED " }
        case 0xc980 + 0x011 { return "GPIO_9.GPIO_CTRL GPIO control." }

        case 0xc992 + 0x000 { return "GPIO_10.GPIO_DCO_INC_DEC Increment/decrement DCO FFO configuration." }
        case 0xc992 + 0x001 { return "GPIO_10.GPIO_OUT_CTRL_0 GPIO controlled output squelch for outputs 0-7." }
        case 0xc992 + 0x002 { return "GPIO_10.GPIO_OUT_CTRL_1 GPIO controlled output squelch for outputs 8-11." }
        case 0xc992 + 0x003 { return "GPIO_10.GPIO_TOD_TRIG GPIO controlled TOD trigger input." }
        case 0xc992 + 0x004 { return "GPIO_10.GPIO_DPLL_INDICATOR GPIO indicator for DPLL lock and holdover states." }
        case 0xc992 + 0x005 { return "GPIO_10.GPIO_LOS_INDICATOR GPIO loss of signal (LOS) indicator." }
        case 0xc992 + 0x006 { return "GPIO_10.GPIO_REF_INPUT_DSQ_0 GPIO controlled input disqualification for inputs 0-7." }
        case 0xc992 + 0x007 { return "GPIO_10.GPIO_REF_INPUT_DSQ_1 GPIO controlled input disqualification for inputs 8-15." }
        case 0xc992 + 0x008 { return "GPIO_10.GPIO_REF_INPUT_DSQ_2 GPIO controlled input disqualification for DPLLs." }
        case 0xc992 + 0x009 { return "GPIO_10.GPIO_REF_INPUT_DSQ_3 GPIO controlled input disqualification for system DPLL and disqualification level." }
        case 0xc992 + 0x00A { return "GPIO_10.GPIO_MAN_CLK_SEL_0 Configure inputs for GPIO manual clock selection." }
        case 0xc992 + 0x00B { return "GPIO_10.GPIO_MAN_CLK_SEL_1 Select DPLLs for GPIO manual clock selection." }
        case 0xc992 + 0x00C { return "GPIO_10.GPIO_MAN_CLK_SEL_2 Select system DPLL for GPIO manual clock selection." }
        case 0xc992 + 0x00D { return "GPIO_10.GPIO_SLAVE GPIO controlled device slave configuration." }
        case 0xc992 + 0x00E { return "GPIO_10.GPIO_ALERT_OUT_CFG GPIO alert notification." }
        case 0xc992 + 0x00F { return "GPIO_10.GPIO_TOD_NOTIFICATION_CFG GPIO configuration for DPLL TOD read notification." }
        case 0xc992 + 0x010 { return "RESERVED " }
        case 0xc992 + 0x011 { return "GPIO_10.GPIO_CTRL GPIO control." }

        case 0xc9a4 + 0x000 { return "GPIO_11.GPIO_DCO_INC_DEC Increment/decrement DCO FFO configuration." }
        case 0xc9a4 + 0x001 { return "GPIO_11.GPIO_OUT_CTRL_0 GPIO controlled output squelch for outputs 0-7." }
        case 0xc9a4 + 0x002 { return "GPIO_11.GPIO_OUT_CTRL_1 GPIO controlled output squelch for outputs 8-11." }
        case 0xc9a4 + 0x003 { return "GPIO_11.GPIO_TOD_TRIG GPIO controlled TOD trigger input." }
        case 0xc9a4 + 0x004 { return "GPIO_11.GPIO_DPLL_INDICATOR GPIO indicator for DPLL lock and holdover states." }
        case 0xc9a4 + 0x005 { return "GPIO_11.GPIO_LOS_INDICATOR GPIO loss of signal (LOS) indicator." }
        case 0xc9a4 + 0x006 { return "GPIO_11.GPIO_REF_INPUT_DSQ_0 GPIO controlled input disqualification for inputs 0-7." }
        case 0xc9a4 + 0x007 { return "GPIO_11.GPIO_REF_INPUT_DSQ_1 GPIO controlled input disqualification for inputs 8-15." }
        case 0xc9a4 + 0x008 { return "GPIO_11.GPIO_REF_INPUT_DSQ_2 GPIO controlled input disqualification for DPLLs." }
        case 0xc9a4 + 0x009 { return "GPIO_11.GPIO_REF_INPUT_DSQ_3 GPIO controlled input disqualification for system DPLL and disqualification level." }
        case 0xc9a4 + 0x00A { return "GPIO_11.GPIO_MAN_CLK_SEL_0 Configure inputs for GPIO manual clock selection." }
        case 0xc9a4 + 0x00B { return "GPIO_11.GPIO_MAN_CLK_SEL_1 Select DPLLs for GPIO manual clock selection." }
        case 0xc9a4 + 0x00C { return "GPIO_11.GPIO_MAN_CLK_SEL_2 Select system DPLL for GPIO manual clock selection." }
        case 0xc9a4 + 0x00D { return "GPIO_11.GPIO_SLAVE GPIO controlled device slave configuration." }
        case 0xc9a4 + 0x00E { return "GPIO_11.GPIO_ALERT_OUT_CFG GPIO alert notification." }
        case 0xc9a4 + 0x00F { return "GPIO_11.GPIO_TOD_NOTIFICATION_CFG GPIO configuration for DPLL TOD read notification." }
        case 0xc9a4 + 0x010 { return "RESERVED " }
        case 0xc9a4 + 0x011 { return "GPIO_11.GPIO_CTRL GPIO control." }

        case 0xc9b6 + 0x000 { return "GPIO_12.GPIO_DCO_INC_DEC Increment/decrement DCO FFO configuration." }
        case 0xc9b6 + 0x001 { return "GPIO_12.GPIO_OUT_CTRL_0 GPIO controlled output squelch for outputs 0-7." }
        case 0xc9b6 + 0x002 { return "GPIO_12.GPIO_OUT_CTRL_1 GPIO controlled output squelch for outputs 8-11." }
        case 0xc9b6 + 0x003 { return "GPIO_12.GPIO_TOD_TRIG GPIO controlled TOD trigger input." }
        case 0xc9b6 + 0x004 { return "GPIO_12.GPIO_DPLL_INDICATOR GPIO indicator for DPLL lock and holdover states." }
        case 0xc9b6 + 0x005 { return "GPIO_12.GPIO_LOS_INDICATOR GPIO loss of signal (LOS) indicator." }
        case 0xc9b6 + 0x006 { return "GPIO_12.GPIO_REF_INPUT_DSQ_0 GPIO controlled input disqualification for inputs 0-7." }
        case 0xc9b6 + 0x007 { return "GPIO_12.GPIO_REF_INPUT_DSQ_1 GPIO controlled input disqualification for inputs 8-15." }
        case 0xc9b6 + 0x008 { return "GPIO_12.GPIO_REF_INPUT_DSQ_2 GPIO controlled input disqualification for DPLLs." }
        case 0xc9b6 + 0x009 { return "GPIO_12.GPIO_REF_INPUT_DSQ_3 GPIO controlled input disqualification for system DPLL and disqualification level." }
        case 0xc9b6 + 0x00A { return "GPIO_12.GPIO_MAN_CLK_SEL_0 Configure inputs for GPIO manual clock selection." }
        case 0xc9b6 + 0x00B { return "GPIO_12.GPIO_MAN_CLK_SEL_1 Select DPLLs for GPIO manual clock selection." }
        case 0xc9b6 + 0x00C { return "GPIO_12.GPIO_MAN_CLK_SEL_2 Select system DPLL for GPIO manual clock selection." }
        case 0xc9b6 + 0x00D { return "GPIO_12.GPIO_SLAVE GPIO controlled device slave configuration." }
        case 0xc9b6 + 0x00E { return "GPIO_12.GPIO_ALERT_OUT_CFG GPIO alert notification." }
        case 0xc9b6 + 0x00F { return "GPIO_12.GPIO_TOD_NOTIFICATION_CFG GPIO configuration for DPLL TOD read notification." }
        case 0xc9b6 + 0x010 { return "RESERVED " }
        case 0xc9b6 + 0x011 { return "GPIO_12.GPIO_CTRL GPIO control." }

        case 0xc9c8 + 0x000 { return "GPIO_13.GPIO_DCO_INC_DEC Increment/decrement DCO FFO configuration." }
        case 0xc9c8 + 0x001 { return "GPIO_13.GPIO_OUT_CTRL_0 GPIO controlled output squelch for outputs 0-7." }
        case 0xc9c8 + 0x002 { return "GPIO_13.GPIO_OUT_CTRL_1 GPIO controlled output squelch for outputs 8-11." }
        case 0xc9c8 + 0x003 { return "GPIO_13.GPIO_TOD_TRIG GPIO controlled TOD trigger input." }
        case 0xc9c8 + 0x004 { return "GPIO_13.GPIO_DPLL_INDICATOR GPIO indicator for DPLL lock and holdover states." }
        case 0xc9c8 + 0x005 { return "GPIO_13.GPIO_LOS_INDICATOR GPIO loss of signal (LOS) indicator." }
        case 0xc9c8 + 0x006 { return "GPIO_13.GPIO_REF_INPUT_DSQ_0 GPIO controlled input disqualification for inputs 0-7." }
        case 0xc9c8 + 0x007 { return "GPIO_13.GPIO_REF_INPUT_DSQ_1 GPIO controlled input disqualification for inputs 8-15." }
        case 0xc9c8 + 0x008 { return "GPIO_13.GPIO_REF_INPUT_DSQ_2 GPIO controlled input disqualification for DPLLs." }
        case 0xc9c8 + 0x009 { return "GPIO_13.GPIO_REF_INPUT_DSQ_3 GPIO controlled input disqualification for system DPLL and disqualification level." }
        case 0xc9c8 + 0x00A { return "GPIO_13.GPIO_MAN_CLK_SEL_0 Configure inputs for GPIO manual clock selection." }
        case 0xc9c8 + 0x00B { return "GPIO_13.GPIO_MAN_CLK_SEL_1 Select DPLLs for GPIO manual clock selection." }
        case 0xc9c8 + 0x00C { return "GPIO_13.GPIO_MAN_CLK_SEL_2 Select system DPLL for GPIO manual clock selection." }
        case 0xc9c8 + 0x00D { return "GPIO_13.GPIO_SLAVE GPIO controlled device slave configuration." }
        case 0xc9c8 + 0x00E { return "GPIO_13.GPIO_ALERT_OUT_CFG GPIO alert notification." }
        case 0xc9c8 + 0x00F { return "GPIO_13.GPIO_TOD_NOTIFICATION_CFG GPIO configuration for DPLL TOD read notification." }
        case 0xc9c8 + 0x010 { return "RESERVED " }
        case 0xc9c8 + 0x011 { return "GPIO_13.GPIO_CTRL GPIO control." }

        case 0xc9da + 0x000 { return "GPIO_14.GPIO_DCO_INC_DEC Increment/decrement DCO FFO configuration." }
        case 0xc9da + 0x001 { return "GPIO_14.GPIO_OUT_CTRL_0 GPIO controlled output squelch for outputs 0-7." }
        case 0xc9da + 0x002 { return "GPIO_14.GPIO_OUT_CTRL_1 GPIO controlled output squelch for outputs 8-11." }
        case 0xc9da + 0x003 { return "GPIO_14.GPIO_TOD_TRIG GPIO controlled TOD trigger input." }
        case 0xc9da + 0x004 { return "GPIO_14.GPIO_DPLL_INDICATOR GPIO indicator for DPLL lock and holdover states." }
        case 0xc9da + 0x005 { return "GPIO_14.GPIO_LOS_INDICATOR GPIO loss of signal (LOS) indicator." }
        case 0xc9da + 0x006 { return "GPIO_14.GPIO_REF_INPUT_DSQ_0 GPIO controlled input disqualification for inputs 0-7." }
        case 0xc9da + 0x007 { return "GPIO_14.GPIO_REF_INPUT_DSQ_1 GPIO controlled input disqualification for inputs 8-15." }
        case 0xc9da + 0x008 { return "GPIO_14.GPIO_REF_INPUT_DSQ_2 GPIO controlled input disqualification for DPLLs." }
        case 0xc9da + 0x009 { return "GPIO_14.GPIO_REF_INPUT_DSQ_3 GPIO controlled input disqualification for system DPLL and disqualification level." }
        case 0xc9da + 0x00A { return "GPIO_14.GPIO_MAN_CLK_SEL_0 Configure inputs for GPIO manual clock selection." }
        case 0xc9da + 0x00B { return "GPIO_14.GPIO_MAN_CLK_SEL_1 Select DPLLs for GPIO manual clock selection." }
        case 0xc9da + 0x00C { return "GPIO_14.GPIO_MAN_CLK_SEL_2 Select system DPLL for GPIO manual clock selection." }
        case 0xc9da + 0x00D { return "GPIO_14.GPIO_SLAVE GPIO controlled device slave configuration." }
        case 0xc9da + 0x00E { return "GPIO_14.GPIO_ALERT_OUT_CFG GPIO alert notification." }
        case 0xc9da + 0x00F { return "GPIO_14.GPIO_TOD_NOTIFICATION_CFG GPIO configuration for DPLL TOD read notification." }
        case 0xc9da + 0x010 { return "RESERVED " }
        case 0xc9da + 0x011 { return "GPIO_14.GPIO_CTRL GPIO control." }

        case 0xca00 + 0x000 { return "GPIO_15.GPIO_DCO_INC_DEC Increment/decrement DCO FFO configuration." }
        case 0xca00 + 0x001 { return "GPIO_15.GPIO_OUT_CTRL_0 GPIO controlled output squelch for outputs 0-7." }
        case 0xca00 + 0x002 { return "GPIO_15.GPIO_OUT_CTRL_1 GPIO controlled output squelch for outputs 8-11." }
        case 0xca00 + 0x003 { return "GPIO_15.GPIO_TOD_TRIG GPIO controlled TOD trigger input." }
        case 0xca00 + 0x004 { return "GPIO_15.GPIO_DPLL_INDICATOR GPIO indicator for DPLL lock and holdover states." }
        case 0xca00 + 0x005 { return "GPIO_15.GPIO_LOS_INDICATOR GPIO loss of signal (LOS) indicator." }
        case 0xca00 + 0x006 { return "GPIO_15.GPIO_REF_INPUT_DSQ_0 GPIO controlled input disqualification for inputs 0-7." }
        case 0xca00 + 0x007 { return "GPIO_15.GPIO_REF_INPUT_DSQ_1 GPIO controlled input disqualification for inputs 8-15." }
        case 0xca00 + 0x008 { return "GPIO_15.GPIO_REF_INPUT_DSQ_2 GPIO controlled input disqualification for DPLLs." }
        case 0xca00 + 0x009 { return "GPIO_15.GPIO_REF_INPUT_DSQ_3 GPIO controlled input disqualification for system DPLL and disqualification level." }
        case 0xca00 + 0x00A { return "GPIO_15.GPIO_MAN_CLK_SEL_0 Configure inputs for GPIO manual clock selection." }
        case 0xca00 + 0x00B { return "GPIO_15.GPIO_MAN_CLK_SEL_1 Select DPLLs for GPIO manual clock selection." }
        case 0xca00 + 0x00C { return "GPIO_15.GPIO_MAN_CLK_SEL_2 Select system DPLL for GPIO manual clock selection." }
        case 0xca00 + 0x00D { return "GPIO_15.GPIO_SLAVE GPIO controlled device slave configuration." }
        case 0xca00 + 0x00E { return "GPIO_15.GPIO_ALERT_OUT_CFG GPIO alert notification." }
        case 0xca00 + 0x00F { return "GPIO_15.GPIO_TOD_NOTIFICATION_CFG GPIO configuration for DPLL TOD read notification." }
        case 0xca00 + 0x010 { return "RESERVED " }
        case 0xca00 + 0x011 { return "GPIO_15.GPIO_CTRL GPIO control." }

        case 0xca12 + 0x000 { return "OUT_DIV_MUX.OUT_DIV0_MUX " }
        case 0xca12 + 0x001 { return "OUT_DIV_MUX.OUT_DIV1_MUX " }
        case 0xca12 + 0x002 { return "OUT_DIV_MUX.OUT_DIV2_MUX " }
        case 0xca12 + 0x003 { return "OUT_DIV_MUX.OUT_DIV3_MUX " }
        case 0xca12 + 0x004 { return "OUT_DIV_MUX.OUT_DIV4_MUX " }
        case 0xca12 + 0x005 { return "OUT_DIV_MUX.OUT_DIV5_MUX " }
        case 0xca12 + 0x006 { return "OUT_DIV_MUX.OUT_DIV6_MUX " }
        case 0xca12 + 0x007 { return "OUT_DIV_MUX.OUT_DIV7_MUX " }
        case 0xca12 + 0x008 { return "OUT_DIV_MUX.OUT_DIV8_MUX " }
        case 0xca12 + 0x009 { return "OUT_DIV_MUX.OUT_DIV9_MUX " }
        case 0xca12 + 0x00A { return "OUT_DIV_MUX.OUT_DIV10_MUX" }
        case 0xca12 + 0x00B { return "OUT_DIV_MUX.OUT_DIV11_MUX" }

        case 0xca20 + 0x000 { return "OUTPUT_0.OUT_DIV Output divider value." }
        case 0xca20 + 0x004 { return "OUTPUT_0.OUT_DUTY_CYCLE_HIGH Output duty cycle." }
        case 0xca20 + 0x008 { return "OUTPUT_0.OUT_CTRL_0 Output electrical characteristics." }
        case 0xca20 + 0x009 { return "OUTPUT_0.OUT_CTRL_1 Output electrical characteristics." }
        case 0xca20 + 0x00C { return "OUTPUT_0.OUT_PHASE_ADJ Output phase adjustment." }

        case 0xca30 + 0x000 { return "OUTPUT_1.OUT_DIV Output divider value." }
        case 0xca30 + 0x004 { return "OUTPUT_1.OUT_DUTY_CYCLE_HIGH Output duty cycle." }
        case 0xca30 + 0x008 { return "OUTPUT_1.OUT_CTRL_0 Output electrical characteristics." }
        case 0xca30 + 0x009 { return "OUTPUT_1.OUT_CTRL_1 Output electrical characteristics." }
        case 0xca30 + 0x00C { return "OUTPUT_1.OUT_PHASE_ADJ Output phase adjustment." }

        case 0xca40 + 0x000 { return "OUTPUT_2.OUT_DIV Output divider value." }
        case 0xca40 + 0x004 { return "OUTPUT_2.OUT_DUTY_CYCLE_HIGH Output duty cycle." }
        case 0xca40 + 0x008 { return "OUTPUT_2.OUT_CTRL_0 Output electrical characteristics." }
        case 0xca40 + 0x009 { return "OUTPUT_2.OUT_CTRL_1 Output electrical characteristics." }
        case 0xca40 + 0x00C { return "OUTPUT_2.OUT_PHASE_ADJ Output phase adjustment." }

        case 0xca50 + 0x000 { return "OUTPUT_3.OUT_DIV Output divider value." }
        case 0xca50 + 0x004 { return "OUTPUT_3.OUT_DUTY_CYCLE_HIGH Output duty cycle." }
        case 0xca50 + 0x008 { return "OUTPUT_3.OUT_CTRL_0 Output electrical characteristics." }
        case 0xca50 + 0x009 { return "OUTPUT_3.OUT_CTRL_1 Output electrical characteristics." }
        case 0xca50 + 0x00C { return "OUTPUT_3.OUT_PHASE_ADJ Output phase adjustment." }

        case 0xca60 + 0x000 { return "OUTPUT_4.OUT_DIV Output divider value." }
        case 0xca60 + 0x004 { return "OUTPUT_4.OUT_DUTY_CYCLE_HIGH Output duty cycle." }
        case 0xca60 + 0x008 { return "OUTPUT_4.OUT_CTRL_0 Output electrical characteristics." }
        case 0xca60 + 0x009 { return "OUTPUT_4.OUT_CTRL_1 Output electrical characteristics." }
        case 0xca60 + 0x00C { return "OUTPUT_4.OUT_PHASE_ADJ Output phase adjustment." }

        case 0xca80 + 0x000 { return "OUTPUT_5.OUT_DIV Output divider value." }
        case 0xca80 + 0x004 { return "OUTPUT_5.OUT_DUTY_CYCLE_HIGH Output duty cycle." }
        case 0xca80 + 0x008 { return "OUTPUT_5.OUT_CTRL_0 Output electrical characteristics." }
        case 0xca80 + 0x009 { return "OUTPUT_5.OUT_CTRL_1 Output electrical characteristics." }
        case 0xca80 + 0x00C { return "OUTPUT_5.OUT_PHASE_ADJ Output phase adjustment." }

        case 0xca90 + 0x000 { return "OUTPUT_6.OUT_DIV Output divider value." }
        case 0xca90 + 0x004 { return "OUTPUT_6.OUT_DUTY_CYCLE_HIGH Output duty cycle." }
        case 0xca90 + 0x008 { return "OUTPUT_6.OUT_CTRL_0 Output electrical characteristics." }
        case 0xca90 + 0x009 { return "OUTPUT_6.OUT_CTRL_1 Output electrical characteristics." }
        case 0xca90 + 0x00C { return "OUTPUT_6.OUT_PHASE_ADJ Output phase adjustment." }

        case 0xcaa0 + 0x000 { return "OUTPUT_7.OUT_DIV Output divider value." }
        case 0xcaa0 + 0x004 { return "OUTPUT_7.OUT_DUTY_CYCLE_HIGH Output duty cycle." }
        case 0xcaa0 + 0x008 { return "OUTPUT_7.OUT_CTRL_0 Output electrical characteristics." }
        case 0xcaa0 + 0x009 { return "OUTPUT_7.OUT_CTRL_1 Output electrical characteristics." }
        case 0xcaa0 + 0x00C { return "OUTPUT_7.OUT_PHASE_ADJ Output phase adjustment." }

        case 0xcaB0 + 0x000 { return "OUTPUT_8.OUT_DIV Output divider value." }
        case 0xcaB0 + 0x004 { return "OUTPUT_8.OUT_DUTY_CYCLE_HIGH Output duty cycle." }
        case 0xcaB0 + 0x008 { return "OUTPUT_8.OUT_CTRL_0 Output electrical characteristics." }
        case 0xcaB0 + 0x009 { return "OUTPUT_8.OUT_CTRL_1 Output electrical characteristics." }
        case 0xcaB0 + 0x00C { return "OUTPUT_8.OUT_PHASE_ADJ Output phase adjustment." }

        case 0xcac0 + 0x000 { return "OUTPUT_9.OUT_DIV Output divider value." }
        case 0xcac0 + 0x004 { return "OUTPUT_9.OUT_DUTY_CYCLE_HIGH Output duty cycle." }
        case 0xcac0 + 0x008 { return "OUTPUT_9.OUT_CTRL_0 Output electrical characteristics." }
        case 0xcac0 + 0x009 { return "OUTPUT_9.OUT_CTRL_1 Output electrical characteristics." }
        case 0xcac0 + 0x00C { return "OUTPUT_9.OUT_PHASE_ADJ Output phase adjustment." }

        case 0xcad0 + 0x000 { return "OUTPUT_10.OUT_DIV Output divider value." }
        case 0xcad0 + 0x004 { return "OUTPUT_10.OUT_DUTY_CYCLE_HIGH Output duty cycle." }
        case 0xcad0 + 0x008 { return "OUTPUT_10.OUT_CTRL_0 Output electrical characteristics." }
        case 0xcad0 + 0x009 { return "OUTPUT_10.OUT_CTRL_1 Output electrical characteristics." }
        case 0xcad0 + 0x00C { return "OUTPUT_10.OUT_PHASE_ADJ Output phase adjustment." }

        case 0xcae0 + 0x000 { return "OUTPUT_11.OUT_DIV Output divider value." }
        case 0xcae0 + 0x004 { return "OUTPUT_11.OUT_DUTY_CYCLE_HIGH Output duty cycle." }
        case 0xcae0 + 0x008 { return "OUTPUT_11.OUT_CTRL_0 Output electrical characteristics." }
        case 0xcae0 + 0x009 { return "OUTPUT_11.OUT_CTRL_1 Output electrical characteristics." }
        case 0xcae0 + 0x00C { return "OUTPUT_11.OUT_PHASE_ADJ Output phase adjustment." }

        case 0xcaf0 + 0x000 { return "SERIAL.I2CM I2C Master configuration." }
        case 0xcaf0 + 0x001 { return "RESERVED " }
        case 0xcaf0 + 0x002 { return "SERIAL.SER0 Slave serial interface 0 (main serial port) configuration." }
        case 0xcaf0 + 0x003 { return "SERIAL.SER0_SPI SPI configuration for serial interface 0 (main serial port)." }
        case 0xcaf0 + 0x004 { return "SERIAL.SER0_I2C I2C configuration for serial interface 0 (main serial port)." }
        case 0xcaf0 + 0x005 { return "SERIAL.SER1 Slave serial interface 1 (auxiliary serial port) configuration." }
        case 0xcaf0 + 0x006 { return "SERIAL.SER1_SPI SPI configuration for serial interface 1 (auxiliary serial port)." }
        case 0xcaf0 + 0x007 { return "SERIAL.SER1_I2C I2C configuration for serial interface 1 (auxiliary serial port)." }
        case 0xcaf0 + 0x008 { return "RESERVED " }
        case 0xcaf0 + 0x009 { return "RESERVED " }
        case 0xcaf0 + 0x00A { return "RESERVED " }
        case 0xcaf0 + 0x00B { return "SERIAL.SER_APPLY_CONFIG Trigger serial configuration changes." }

        case 0xcb00 + 0x000 { return "PWM_ENCODER_0.PWM_ENCODER_ID PWM encoder identifier." }
        case 0xcb00 + 0x001 { return "PWM_ENCODER_0.PWM_ENCODER_CNFG PWM encoder configuration." }
        case 0xcb00 + 0x002 { return "PWM_ENCODER_0.PWM_ENCODER_SIGNATURE_0" }
        case 0xcb00 + 0x003 { return "PWM_ENCODER_0.PWM_ENCODER_SIGNATURE_1" }
        case 0xcb00 + 0x004 { return "PWM_ENCODER_0.PWM_ENCODER_SYNC_PAYLOAD_CNFG" }
        case 0xcb00 + 0x005 { return "PWM_ENCODER_0.PWM_ENCODER_SYNC_PAYLOAD_SQUELCH_CNFG" }
        case 0xcb00 + 0x006 { return "RESERVED " }
        case 0xcb00 + 0x007 { return "PWM_ENCODER_0.PWM_ENCODER_CMD PWM encoder command." }

        case 0xcb08 + 0x000 { return "PWM_ENCODER_1.PWM_ENCODER_ID PWM encoder identifier." }
        case 0xcb08 + 0x001 { return "PWM_ENCODER_1.PWM_ENCODER_CNFG PWM encoder configuration." }
        case 0xcb08 + 0x002 { return "PWM_ENCODER_1.PWM_ENCODER_SIGNATURE_0" }
        case 0xcb08 + 0x003 { return "PWM_ENCODER_1.PWM_ENCODER_SIGNATURE_1" }
        case 0xcb08 + 0x004 { return "PWM_ENCODER_1.PWM_ENCODER_SYNC_PAYLOAD_CNFG" }
        case 0xcb08 + 0x005 { return "PWM_ENCODER_1.PWM_ENCODER_SYNC_PAYLOAD_SQUELCH_CNFG" }
        case 0xcb08 + 0x006 { return "RESERVED " }
        case 0xcb08 + 0x007 { return "PWM_ENCODER_1.PWM_ENCODER_CMD PWM encoder command." }

        case 0xcb10 + 0x000 { return "PWM_ENCODER_2.PWM_ENCODER_ID PWM encoder identifier." }
        case 0xcb10 + 0x001 { return "PWM_ENCODER_2.PWM_ENCODER_CNFG PWM encoder configuration." }
        case 0xcb10 + 0x002 { return "PWM_ENCODER_2.PWM_ENCODER_SIGNATURE_0" }
        case 0xcb10 + 0x003 { return "PWM_ENCODER_2.PWM_ENCODER_SIGNATURE_1" }
        case 0xcb10 + 0x004 { return "PWM_ENCODER_2.PWM_ENCODER_SYNC_PAYLOAD_CNFG" }
        case 0xcb10 + 0x005 { return "PWM_ENCODER_2.PWM_ENCODER_SYNC_PAYLOAD_SQUELCH_CNFG" }
        case 0xcb10 + 0x006 { return "RESERVED " }
        case 0xcb10 + 0x007 { return "PWM_ENCODER_2.PWM_ENCODER_CMD PWM encoder command." }

        case 0xcb18 + 0x000 { return "PWM_ENCODER_3.PWM_ENCODER_ID PWM encoder identifier." }
        case 0xcb18 + 0x001 { return "PWM_ENCODER_3.PWM_ENCODER_CNFG PWM encoder configuration." }
        case 0xcb18 + 0x002 { return "PWM_ENCODER_3.PWM_ENCODER_SIGNATURE_0" }
        case 0xcb18 + 0x003 { return "PWM_ENCODER_3.PWM_ENCODER_SIGNATURE_1" }
        case 0xcb18 + 0x004 { return "PWM_ENCODER_3.PWM_ENCODER_SYNC_PAYLOAD_CNFG" }
        case 0xcb18 + 0x005 { return "PWM_ENCODER_3.PWM_ENCODER_SYNC_PAYLOAD_SQUELCH_CNFG" }
        case 0xcb18 + 0x006 { return "RESERVED " }
        case 0xcb18 + 0x007 { return "PWM_ENCODER_3.PWM_ENCODER_CMD PWM encoder command." }

        case 0xcb20 + 0x000 { return "PWM_ENCODER_4.PWM_ENCODER_ID PWM encoder identifier." }
        case 0xcb20 + 0x001 { return "PWM_ENCODER_4.PWM_ENCODER_CNFG PWM encoder configuration." }
        case 0xcb20 + 0x002 { return "PWM_ENCODER_4.PWM_ENCODER_SIGNATURE_0" }
        case 0xcb20 + 0x003 { return "PWM_ENCODER_4.PWM_ENCODER_SIGNATURE_1" }
        case 0xcb20 + 0x004 { return "PWM_ENCODER_4.PWM_ENCODER_SYNC_PAYLOAD_CNFG" }
        case 0xcb20 + 0x005 { return "PWM_ENCODER_4.PWM_ENCODER_SYNC_PAYLOAD_SQUELCH_CNFG" }
        case 0xcb20 + 0x006 { return "RESERVED " }
        case 0xcb20 + 0x007 { return "PWM_ENCODER_4.PWM_ENCODER_CMD PWM encoder command." }

        case 0xcb28 + 0x000 { return "PWM_ENCODER_5.PWM_ENCODER_ID PWM encoder identifier." }
        case 0xcb28 + 0x001 { return "PWM_ENCODER_5.PWM_ENCODER_CNFG PWM encoder configuration." }
        case 0xcb28 + 0x002 { return "PWM_ENCODER_5.PWM_ENCODER_SIGNATURE_0" }
        case 0xcb28 + 0x003 { return "PWM_ENCODER_5.PWM_ENCODER_SIGNATURE_1" }
        case 0xcb28 + 0x004 { return "PWM_ENCODER_5.PWM_ENCODER_SYNC_PAYLOAD_CNFG" }
        case 0xcb28 + 0x005 { return "PWM_ENCODER_5.PWM_ENCODER_SYNC_PAYLOAD_SQUELCH_CNFG" }
        case 0xcb28 + 0x006 { return "RESERVED " }
        case 0xcb28 + 0x007 { return "PWM_ENCODER_5.PWM_ENCODER_CMD PWM encoder command." }

        case 0xcb30 + 0x000 { return "PWM_ENCODER_6.PWM_ENCODER_ID PWM encoder identifier." }
        case 0xcb30 + 0x001 { return "PWM_ENCODER_6.PWM_ENCODER_CNFG PWM encoder configuration." }
        case 0xcb30 + 0x002 { return "PWM_ENCODER_6.PWM_ENCODER_SIGNATURE_0" }
        case 0xcb30 + 0x003 { return "PWM_ENCODER_6.PWM_ENCODER_SIGNATURE_1" }
        case 0xcb30 + 0x004 { return "PWM_ENCODER_6.PWM_ENCODER_SYNC_PAYLOAD_CNFG" }
        case 0xcb30 + 0x005 { return "PWM_ENCODER_6.PWM_ENCODER_SYNC_PAYLOAD_SQUELCH_CNFG" }
        case 0xcb30 + 0x006 { return "RESERVED " }
        case 0xcb30 + 0x007 { return "PWM_ENCODER_6.PWM_ENCODER_CMD PWM encoder command." }

        case 0xcb38 + 0x000 { return "PWM_ENCODER_7.PWM_ENCODER_ID PWM encoder identifier." }
        case 0xcb38 + 0x001 { return "PWM_ENCODER_7.PWM_ENCODER_CNFG PWM encoder configuration." }
        case 0xcb38 + 0x002 { return "PWM_ENCODER_7.PWM_ENCODER_SIGNATURE_0" }
        case 0xcb38 + 0x003 { return "PWM_ENCODER_7.PWM_ENCODER_SIGNATURE_1" }
        case 0xcb38 + 0x004 { return "PWM_ENCODER_7.PWM_ENCODER_SYNC_PAYLOAD_CNFG" }
        case 0xcb38 + 0x005 { return "PWM_ENCODER_7.PWM_ENCODER_SYNC_PAYLOAD_SQUELCH_CNFG" }
        case 0xcb38 + 0x006 { return "RESERVED " }
        case 0xcb38 + 0x007 { return "PWM_ENCODER_7.PWM_ENCODER_CMD PWM encoder command." }

        case 0xcb40 + 0x000 { return "PWM_DECODER_0.PWM_DECODER_CNFG PWM_PPS configuration." }
        case 0xcb40 + 0x002 { return "PWM_DECODER_0.PWM_DECODER_ID PWM decoder identifier." }
        case 0xcb40 + 0x003 { return "PWM_DECODER_0.PWM_DECODER_SIGNATURE_0" }
        case 0xcb40 + 0x004 { return "PWM_DECODER_0.PWM_DECODER_SIGNATURE_1" }
        case 0xcb40 + 0x005 { return "PWM_DECODER_0.PWM_DECODER_SYNC_PAYLOAD_CNFG_0" }
        case 0xcb40 + 0x006 { return "PWM_DECODER_0.PWM_DECODER_SYNC_PAYLOAD_CNFG_1" }
        case 0xcb40 + 0x007 { return "PWM_DECODER_0.PWM_DECODER_SYNC_PAYLOAD_CNFG_2" }
        case 0xcb40 + 0x008 { return "PWM_DECODER_0.PWM_DECODER_SYNC_PAYLOAD_CNFG_3" }
        case 0xcb40 + 0x009 { return "PWM_DECODER_0.PWM_DECODER_CMD PWM decoder command." }

        case 0xcb4a + 0x000 { return "PWM_DECODER_1.PWM_DECODER_CNFG PWM_PPS configuration." }
        case 0xcb4a + 0x002 { return "PWM_DECODER_1.PWM_DECODER_ID PWM decoder identifier." }
        case 0xcb4a + 0x003 { return "PWM_DECODER_1.PWM_DECODER_SIGNATURE_0" }
        case 0xcb4a + 0x004 { return "PWM_DECODER_1.PWM_DECODER_SIGNATURE_1" }
        case 0xcb4a + 0x005 { return "PWM_DECODER_1.PWM_DECODER_SYNC_PAYLOAD_CNFG_0" }
        case 0xcb4a + 0x006 { return "PWM_DECODER_1.PWM_DECODER_SYNC_PAYLOAD_CNFG_1" }
        case 0xcb4a + 0x007 { return "PWM_DECODER_1.PWM_DECODER_SYNC_PAYLOAD_CNFG_2" }
        case 0xcb4a + 0x008 { return "PWM_DECODER_1.PWM_DECODER_SYNC_PAYLOAD_CNFG_3" }
        case 0xcb4a + 0x009 { return "PWM_DECODER_1.PWM_DECODER_CMD PWM decoder command." }

        case 0xcb54 + 0x000 { return "PWM_DECODER_2.PWM_DECODER_CNFG PWM_PPS configuration." }
        case 0xcb54 + 0x002 { return "PWM_DECODER_2.PWM_DECODER_ID PWM decoder identifier." }
        case 0xcb54 + 0x003 { return "PWM_DECODER_2.PWM_DECODER_SIGNATURE_0" }
        case 0xcb54 + 0x004 { return "PWM_DECODER_2.PWM_DECODER_SIGNATURE_1" }
        case 0xcb54 + 0x005 { return "PWM_DECODER_2.PWM_DECODER_SYNC_PAYLOAD_CNFG_0" }
        case 0xcb54 + 0x006 { return "PWM_DECODER_2.PWM_DECODER_SYNC_PAYLOAD_CNFG_1" }
        case 0xcb54 + 0x007 { return "PWM_DECODER_2.PWM_DECODER_SYNC_PAYLOAD_CNFG_2" }
        case 0xcb54 + 0x008 { return "PWM_DECODER_2.PWM_DECODER_SYNC_PAYLOAD_CNFG_3" }
        case 0xcb54 + 0x009 { return "PWM_DECODER_2.PWM_DECODER_CMD PWM decoder command." }

        case 0xcb5e + 0x000 { return "PWM_DECODER_3.PWM_DECODER_CNFG PWM_PPS configuration." }
        case 0xcb5e + 0x002 { return "PWM_DECODER_3.PWM_DECODER_ID PWM decoder identifier." }
        case 0xcb5e + 0x003 { return "PWM_DECODER_3.PWM_DECODER_SIGNATURE_0" }
        case 0xcb5e + 0x004 { return "PWM_DECODER_3.PWM_DECODER_SIGNATURE_1" }
        case 0xcb5e + 0x005 { return "PWM_DECODER_3.PWM_DECODER_SYNC_PAYLOAD_CNFG_0" }
        case 0xcb5e + 0x006 { return "PWM_DECODER_3.PWM_DECODER_SYNC_PAYLOAD_CNFG_1" }
        case 0xcb5e + 0x007 { return "PWM_DECODER_3.PWM_DECODER_SYNC_PAYLOAD_CNFG_2" }
        case 0xcb5e + 0x008 { return "PWM_DECODER_3.PWM_DECODER_SYNC_PAYLOAD_CNFG_3" }
        case 0xcb5e + 0x009 { return "PWM_DECODER_3.PWM_DECODER_CMD PWM decoder command." }

        case 0xcb68 + 0x000 { return "PWM_DECODER_4.PWM_DECODER_CNFG PWM_PPS configuration." }
        case 0xcb68 + 0x002 { return "PWM_DECODER_4.PWM_DECODER_ID PWM decoder identifier." }
        case 0xcb68 + 0x003 { return "PWM_DECODER_4.PWM_DECODER_SIGNATURE_0" }
        case 0xcb68 + 0x004 { return "PWM_DECODER_4.PWM_DECODER_SIGNATURE_1" }
        case 0xcb68 + 0x005 { return "PWM_DECODER_4.PWM_DECODER_SYNC_PAYLOAD_CNFG_0" }
        case 0xcb68 + 0x006 { return "PWM_DECODER_4.PWM_DECODER_SYNC_PAYLOAD_CNFG_1" }
        case 0xcb68 + 0x007 { return "PWM_DECODER_4.PWM_DECODER_SYNC_PAYLOAD_CNFG_2" }
        case 0xcb68 + 0x008 { return "PWM_DECODER_4.PWM_DECODER_SYNC_PAYLOAD_CNFG_3" }
        case 0xcb68 + 0x009 { return "PWM_DECODER_4.PWM_DECODER_CMD PWM decoder command." }

        case 0xcb80 + 0x000 { return "PWM_DECODER_5.PWM_DECODER_CNFG PWM_PPS configuration." }
        case 0xcb80 + 0x002 { return "PWM_DECODER_5.PWM_DECODER_ID PWM decoder identifier." }
        case 0xcb80 + 0x003 { return "PWM_DECODER_5.PWM_DECODER_SIGNATURE_0" }
        case 0xcb80 + 0x004 { return "PWM_DECODER_5.PWM_DECODER_SIGNATURE_1" }
        case 0xcb80 + 0x005 { return "PWM_DECODER_5.PWM_DECODER_SYNC_PAYLOAD_CNFG_0" }
        case 0xcb80 + 0x006 { return "PWM_DECODER_5.PWM_DECODER_SYNC_PAYLOAD_CNFG_1" }
        case 0xcb80 + 0x007 { return "PWM_DECODER_5.PWM_DECODER_SYNC_PAYLOAD_CNFG_2" }
        case 0xcb80 + 0x008 { return "PWM_DECODER_5.PWM_DECODER_SYNC_PAYLOAD_CNFG_3" }
        case 0xcb80 + 0x009 { return "PWM_DECODER_5.PWM_DECODER_CMD PWM decoder command." }

        case 0xcb8a + 0x000 { return "PWM_DECODER_6.PWM_DECODER_CNFG PWM_PPS configuration." }
        case 0xcb8a + 0x002 { return "PWM_DECODER_6.PWM_DECODER_ID PWM decoder identifier." }
        case 0xcb8a + 0x003 { return "PWM_DECODER_6.PWM_DECODER_SIGNATURE_0" }
        case 0xcb8a + 0x004 { return "PWM_DECODER_6.PWM_DECODER_SIGNATURE_1" }
        case 0xcb8a + 0x005 { return "PWM_DECODER_6.PWM_DECODER_SYNC_PAYLOAD_CNFG_0" }
        case 0xcb8a + 0x006 { return "PWM_DECODER_6.PWM_DECODER_SYNC_PAYLOAD_CNFG_1" }
        case 0xcb8a + 0x007 { return "PWM_DECODER_6.PWM_DECODER_SYNC_PAYLOAD_CNFG_2" }
        case 0xcb8a + 0x008 { return "PWM_DECODER_6.PWM_DECODER_SYNC_PAYLOAD_CNFG_3" }
        case 0xcb8a + 0x009 { return "PWM_DECODER_6.PWM_DECODER_CMD PWM decoder command." }

        case 0xcb94 + 0x000 { return "PWM_DECODER_7.PWM_DECODER_CNFG PWM_PPS configuration." }
        case 0xcb94 + 0x002 { return "PWM_DECODER_7.PWM_DECODER_ID PWM decoder identifier." }
        case 0xcb94 + 0x003 { return "PWM_DECODER_7.PWM_DECODER_SIGNATURE_0" }
        case 0xcb94 + 0x004 { return "PWM_DECODER_7.PWM_DECODER_SIGNATURE_1" }
        case 0xcb94 + 0x005 { return "PWM_DECODER_7.PWM_DECODER_SYNC_PAYLOAD_CNFG_0" }
        case 0xcb94 + 0x006 { return "PWM_DECODER_7.PWM_DECODER_SYNC_PAYLOAD_CNFG_1" }
        case 0xcb94 + 0x007 { return "PWM_DECODER_7.PWM_DECODER_SYNC_PAYLOAD_CNFG_2" }
        case 0xcb94 + 0x008 { return "PWM_DECODER_7.PWM_DECODER_SYNC_PAYLOAD_CNFG_3" }
        case 0xcb94 + 0x009 { return "PWM_DECODER_7.PWM_DECODER_CMD PWM decoder command." }

        case 0xcb9e + 0x000 { return "PWM_DECODER_8.PWM_DECODER_CNFG PWM_PPS configuration." }
        case 0xcb9e + 0x002 { return "PWM_DECODER_8.PWM_DECODER_ID PWM decoder identifier." }
        case 0xcb9e + 0x003 { return "PWM_DECODER_8.PWM_DECODER_SIGNATURE_0" }
        case 0xcb9e + 0x004 { return "PWM_DECODER_8.PWM_DECODER_SIGNATURE_1" }
        case 0xcb9e + 0x005 { return "PWM_DECODER_8.PWM_DECODER_SYNC_PAYLOAD_CNFG_0" }
        case 0xcb9e + 0x006 { return "PWM_DECODER_8.PWM_DECODER_SYNC_PAYLOAD_CNFG_1" }
        case 0xcb9e + 0x007 { return "PWM_DECODER_8.PWM_DECODER_SYNC_PAYLOAD_CNFG_2" }
        case 0xcb9e + 0x008 { return "PWM_DECODER_8.PWM_DECODER_SYNC_PAYLOAD_CNFG_3" }
        case 0xcb9e + 0x009 { return "PWM_DECODER_8.PWM_DECODER_CMD PWM decoder command." }

        case 0xcba8 + 0x000 { return "PWM_DECODER_9.PWM_DECODER_CNFG PWM_PPS configuration." }
        case 0xcba8 + 0x002 { return "PWM_DECODER_9.PWM_DECODER_ID PWM decoder identifier." }
        case 0xcba8 + 0x003 { return "PWM_DECODER_9.PWM_DECODER_SIGNATURE_0" }
        case 0xcba8 + 0x004 { return "PWM_DECODER_9.PWM_DECODER_SIGNATURE_1" }
        case 0xcba8 + 0x005 { return "PWM_DECODER_9.PWM_DECODER_SYNC_PAYLOAD_CNFG_0" }
        case 0xcba8 + 0x006 { return "PWM_DECODER_9.PWM_DECODER_SYNC_PAYLOAD_CNFG_1" }
        case 0xcba8 + 0x007 { return "PWM_DECODER_9.PWM_DECODER_SYNC_PAYLOAD_CNFG_2" }
        case 0xcba8 + 0x008 { return "PWM_DECODER_9.PWM_DECODER_SYNC_PAYLOAD_CNFG_3" }
        case 0xcba8 + 0x009 { return "PWM_DECODER_9.PWM_DECODER_CMD PWM decoder command." }

        case 0xcbb2 + 0x000 { return "PWM_DECODER_10.PWM_DECODER_CNFG PWM_PPS configuration." }
        case 0xcbb2 + 0x002 { return "PWM_DECODER_10.PWM_DECODER_ID PWM decoder identifier." }
        case 0xcbb2 + 0x003 { return "PWM_DECODER_10.PWM_DECODER_SIGNATURE_0" }
        case 0xcbb2 + 0x004 { return "PWM_DECODER_10.PWM_DECODER_SIGNATURE_1" }
        case 0xcbb2 + 0x005 { return "PWM_DECODER_10.PWM_DECODER_SYNC_PAYLOAD_CNFG_0" }
        case 0xcbb2 + 0x006 { return "PWM_DECODER_10.PWM_DECODER_SYNC_PAYLOAD_CNFG_1" }
        case 0xcbb2 + 0x007 { return "PWM_DECODER_10.PWM_DECODER_SYNC_PAYLOAD_CNFG_2" }
        case 0xcbb2 + 0x008 { return "PWM_DECODER_10.PWM_DECODER_SYNC_PAYLOAD_CNFG_3" }
        case 0xcbb2 + 0x009 { return "PWM_DECODER_10.PWM_DECODER_CMD PWM decoder command." }

        case 0xcbbc + 0x000 { return "PWM_DECODER_11.PWM_DECODER_CNFG PWM_PPS configuration." }
        case 0xcbbc + 0x002 { return "PWM_DECODER_11.PWM_DECODER_ID PWM decoder identifier." }
        case 0xcbbc + 0x003 { return "PWM_DECODER_11.PWM_DECODER_SIGNATURE_0" }
        case 0xcbbc + 0x004 { return "PWM_DECODER_11.PWM_DECODER_SIGNATURE_1" }
        case 0xcbbc + 0x005 { return "PWM_DECODER_11.PWM_DECODER_SYNC_PAYLOAD_CNFG_0" }
        case 0xcbbc + 0x006 { return "PWM_DECODER_11.PWM_DECODER_SYNC_PAYLOAD_CNFG_1" }
        case 0xcbbc + 0x007 { return "PWM_DECODER_11.PWM_DECODER_SYNC_PAYLOAD_CNFG_2" }
        case 0xcbbc + 0x008 { return "PWM_DECODER_11.PWM_DECODER_SYNC_PAYLOAD_CNFG_3" }
        case 0xcbbc + 0x009 { return "PWM_DECODER_11.PWM_DECODER_CMD PWM decoder command." }

        case 0xcbc6 + 0x000 { return "PWM_DECODER_12.PWM_DECODER_CNFG PWM_PPS configuration." }
        case 0xcbc6 + 0x002 { return "PWM_DECODER_12.PWM_DECODER_ID PWM decoder identifier." }
        case 0xcbc6 + 0x003 { return "PWM_DECODER_12.PWM_DECODER_SIGNATURE_0" }
        case 0xcbc6 + 0x004 { return "PWM_DECODER_12.PWM_DECODER_SIGNATURE_1" }
        case 0xcbc6 + 0x005 { return "PWM_DECODER_12.PWM_DECODER_SYNC_PAYLOAD_CNFG_0" }
        case 0xcbc6 + 0x006 { return "PWM_DECODER_12.PWM_DECODER_SYNC_PAYLOAD_CNFG_1" }
        case 0xcbc6 + 0x007 { return "PWM_DECODER_12.PWM_DECODER_SYNC_PAYLOAD_CNFG_2" }
        case 0xcbc6 + 0x008 { return "PWM_DECODER_12.PWM_DECODER_SYNC_PAYLOAD_CNFG_3" }
        case 0xcbc6 + 0x009 { return "PWM_DECODER_12.PWM_DECODER_CMD PWM decoder command." }

        case 0xcbd0 + 0x000 { return "PWM_DECODER_13.PWM_DECODER_CNFG PWM_PPS configuration." }
        case 0xcbd0 + 0x002 { return "PWM_DECODER_13.PWM_DECODER_ID PWM decoder identifier." }
        case 0xcbd0 + 0x003 { return "PWM_DECODER_13.PWM_DECODER_SIGNATURE_0" }
        case 0xcbd0 + 0x004 { return "PWM_DECODER_13.PWM_DECODER_SIGNATURE_1" }
        case 0xcbd0 + 0x005 { return "PWM_DECODER_13.PWM_DECODER_SYNC_PAYLOAD_CNFG_0" }
        case 0xcbd0 + 0x006 { return "PWM_DECODER_13.PWM_DECODER_SYNC_PAYLOAD_CNFG_1" }
        case 0xcbd0 + 0x007 { return "PWM_DECODER_13.PWM_DECODER_SYNC_PAYLOAD_CNFG_2" }
        case 0xcbd0 + 0x008 { return "PWM_DECODER_13.PWM_DECODER_SYNC_PAYLOAD_CNFG_3" }
        case 0xcbd0 + 0x009 { return "PWM_DECODER_13.PWM_DECODER_CMD PWM decoder command." }

        case 0xcbda + 0x000 { return "PWM_DECODER_14.PWM_DECODER_CNFG PWM_PPS configuration." }
        case 0xcbda + 0x002 { return "PWM_DECODER_14.PWM_DECODER_ID PWM decoder identifier." }
        case 0xcbda + 0x003 { return "PWM_DECODER_14.PWM_DECODER_SIGNATURE_0" }
        case 0xcbda + 0x004 { return "PWM_DECODER_14.PWM_DECODER_SIGNATURE_1" }
        case 0xcbda + 0x005 { return "PWM_DECODER_14.PWM_DECODER_SYNC_PAYLOAD_CNFG_0" }
        case 0xcbda + 0x006 { return "PWM_DECODER_14.PWM_DECODER_SYNC_PAYLOAD_CNFG_1" }
        case 0xcbda + 0x007 { return "PWM_DECODER_14.PWM_DECODER_SYNC_PAYLOAD_CNFG_2" }
        case 0xcbda + 0x008 { return "PWM_DECODER_14.PWM_DECODER_SYNC_PAYLOAD_CNFG_3" }
        case 0xcbda + 0x009 { return "PWM_DECODER_14.PWM_DECODER_CMD PWM decoder command." }

        case 0xcbe4 + 0x000 { return "PWM_DECODER_15.PWM_DECODER_CNFG PWM_PPS configuration." }
        case 0xcbe4 + 0x002 { return "PWM_DECODER_15.PWM_DECODER_ID PWM decoder identifier." }
        case 0xcbe4 + 0x003 { return "PWM_DECODER_15.PWM_DECODER_SIGNATURE_0" }
        case 0xcbe4 + 0x004 { return "PWM_DECODER_15.PWM_DECODER_SIGNATURE_1" }
        case 0xcbe4 + 0x005 { return "PWM_DECODER_15.PWM_DECODER_SYNC_PAYLOAD_CNFG_0" }
        case 0xcbe4 + 0x006 { return "PWM_DECODER_15.PWM_DECODER_SYNC_PAYLOAD_CNFG_1" }
        case 0xcbe4 + 0x007 { return "PWM_DECODER_15.PWM_DECODER_SYNC_PAYLOAD_CNFG_2" }
        case 0xcbe4 + 0x008 { return "PWM_DECODER_15.PWM_DECODER_SYNC_PAYLOAD_CNFG_3" }
        case 0xcbe4 + 0x009 { return "PWM_DECODER_15.PWM_DECODER_CMD PWM decoder command." }

        case 0xcbf0 + 0x000 { return "PWM_USER_DATA.PWM_SRC_ENCODER_ID Source PWM encoder." }
        case 0xcbf0 + 0x001 { return "PWM_USER_DATA.PWM_DST_DECODER_ID Destination PWM decoder." }
        case 0xcbf0 + 0x002 { return "PWM_USER_DATA.PWM_USER_DATA_SIZE The PWM user data length in bytes." }
        case 0xcbf0 + 0x003 { return "RESERVED " }
        case 0xcbf0 + 0x004 { return "RESERVED " }
        case 0xcbf0 + 0x005 { return "RESERVED " }
        case 0xcbf0 + 0x006 { return "RESERVED " }
        case 0xcbf0 + 0x007 { return "PWM_USER_DATA.PWM_USER_DATA_CMD_STS PWM user data command and status register." }

        case 0xcc00 + 0x000 { return "RESERVED " }
        case 0xcc00 + 0x001 { return "TOD_0.TOD_CFG TOD configuration register." }
        case 0xcc02 + 0x000 { return "RESERVED " }
        case 0xcc02 + 0x001 { return "TOD_1.TOD_CFG TOD configuration register." }
        case 0xcc04 + 0x000 { return "RESERVED " }
        case 0xcc04 + 0x001 { return "TOD_2.TOD_CFG TOD configuration register." }
        case 0xcc06 + 0x000 { return "RESERVED " }
        case 0xcc06 + 0x001 { return "TOD_3.TOD_CFG TOD configuration register." }

        case 0xcc10 + 0x000 { return "TOD_WRITE_0.TOD_WRITE TOD write registers." }
        case 0xcc10 + 0x00B { return "RESERVED " }
        case 0xcc10 + 0x00C { return "TOD_WRITE_0.TOD_WRITE_COUNTER Indicates when TOD write is completed." }
        case 0xcc10 + 0x00D { return "TOD_WRITE_0.TOD_WRITE_SELECT_CFG_0 TOD write trigger configuration." }
        case 0xcc10 + 0x00E { return "RESERVED " }
        case 0xcc10 + 0x00F { return "TOD_WRITE_0.TOD_WRITE_CMD TOD write trigger selection." }

        case 0xcc20 + 0x000 { return "TOD_WRITE_1.TOD_WRITE TOD write registers." }
        case 0xcc20 + 0x00B { return "RESERVED " }
        case 0xcc20 + 0x00C { return "TOD_WRITE_1.TOD_WRITE_COUNTER Indicates when TOD write is completed." }
        case 0xcc20 + 0x00D { return "TOD_WRITE_1.TOD_WRITE_SELECT_CFG_0 TOD write trigger configuration." }
        case 0xcc20 + 0x00E { return "RESERVED " }
        case 0xcc20 + 0x00F { return "TOD_WRITE_1.TOD_WRITE_CMD TOD write trigger selection." }

        case 0xcc30 + 0x000 { return "TOD_WRITE_2.TOD_WRITE TOD write registers." }
        case 0xcc30 + 0x00B { return "RESERVED " }
        case 0xcc30 + 0x00C { return "TOD_WRITE_2.TOD_WRITE_COUNTER Indicates when TOD write is completed." }
        case 0xcc30 + 0x00D { return "TOD_WRITE_2.TOD_WRITE_SELECT_CFG_0 TOD write trigger configuration." }
        case 0xcc30 + 0x00E { return "RESERVED " }
        case 0xcc30 + 0x00F { return "TOD_WRITE_2.TOD_WRITE_CMD TOD write trigger selection." }

        case 0xcc40 + 0x000 { return "TOD_WRITE_3.TOD_WRITE TOD write registers." }
        case 0xcc40 + 0x00B { return "RESERVED " }
        case 0xcc40 + 0x00C { return "TOD_WRITE_3.TOD_WRITE_COUNTER Indicates when TOD write is completed." }
        case 0xcc40 + 0x00D { return "TOD_WRITE_3.TOD_WRITE_SELECT_CFG_0 TOD write trigger configuration." }
        case 0xcc40 + 0x00E { return "RESERVED " }
        case 0xcc40 + 0x00F { return "TOD_WRITE_3.TOD_WRITE_CMD TOD write trigger selection." }

        case 0xcc50 + 0x000 { return "TOD_READ_PRIMARY_0.TOD_READ_PRIMARY" }
        case 0xcc50 + 0x00B { return "TOD_READ_PRIMARY_0.TOD_READ_PRIMARY_COUNTER" }
        case 0xcc50 + 0x00C { return "TOD_READ_PRIMARY_0.TOD_READ_PRIMARY_SEL_CFG_0" }
        case 0xcc50 + 0x00D { return "TOD_READ_PRIMARY_0.TOD_READ_PRIMARY_SEL_CFG_1" }
        case 0xcc50 + 0x00E { return "RESERVED " }
        case 0xcc50 + 0x00F { return "TOD_READ_PRIMARY_0.TOD_READ_PRIMARY_CMD" }

        case 0xcc60 + 0x000 { return "TOD_READ_PRIMARY_1.TOD_READ_PRIMARY" }
        case 0xcc60 + 0x00B { return "TOD_READ_PRIMARY_1.TOD_READ_PRIMARY_COUNTER" }
        case 0xcc60 + 0x00C { return "TOD_READ_PRIMARY_1.TOD_READ_PRIMARY_SEL_CFG_0" }
        case 0xcc60 + 0x00D { return "TOD_READ_PRIMARY_1.TOD_READ_PRIMARY_SEL_CFG_1" }
        case 0xcc60 + 0x00E { return "RESERVED " }
        case 0xcc60 + 0x00F { return "TOD_READ_PRIMARY_1.TOD_READ_PRIMARY_CMD" }

        case 0xcc80 + 0x000 { return "TOD_READ_PRIMARY_2.TOD_READ_PRIMARY" }
        case 0xcc80 + 0x00B { return "TOD_READ_PRIMARY_2.TOD_READ_PRIMARY_COUNTER" }
        case 0xcc80 + 0x00C { return "TOD_READ_PRIMARY_2.TOD_READ_PRIMARY_SEL_CFG_0" }
        case 0xcc80 + 0x00D { return "TOD_READ_PRIMARY_2.TOD_READ_PRIMARY_SEL_CFG_1" }
        case 0xcc80 + 0x00E { return "RESERVED " }
        case 0xcc80 + 0x00F { return "TOD_READ_PRIMARY_2.TOD_READ_PRIMARY_CMD" }

        case 0xcc80 + 0x000 { return "TOD_READ_PRIMARY_3.TOD_READ_PRIMARY" }
        case 0xcc80 + 0x00B { return "TOD_READ_PRIMARY_3.TOD_READ_PRIMARY_COUNTER" }
        case 0xcc80 + 0x00C { return "TOD_READ_PRIMARY_3.TOD_READ_PRIMARY_SEL_CFG_0" }
        case 0xcc80 + 0x00D { return "TOD_READ_PRIMARY_3.TOD_READ_PRIMARY_SEL_CFG_1" }
        case 0xcc80 + 0x00E { return "RESERVED " }
        case 0xcc80 + 0x00F { return "TOD_READ_PRIMARY_3.TOD_READ_PRIMARY_CMD" }

        case 0xcca0 + 0x000 { return "TOD_READ_SECONDARY_0.TOD_READ_SECONDARY" }
        case 0xcca0 + 0x00B { return "TOD_READ_SECONDARY_0.TOD_READ_SECONDARY_COUNTER" }
        case 0xcca0 + 0x00C { return "TOD_READ_SECONDARY_0.TOD_READ_SECONDARY_SEL_CFG_0" }
        case 0xcca0 + 0x00D { return "TOD_READ_SECONDARY_0.TOD_READ_SECONDARY_SEL_CFG_1" }
        case 0xcca0 + 0x00E { return "RESERVED " }
        case 0xcca0 + 0x00F { return "TOD_READ_SECONDARY_0.TOD_READ_SECONDARY_CMD" }

        case 0xccb0 + 0x000 { return "TOD_READ_SECONDARY_1.TOD_READ_SECONDARY" }
        case 0xccb0 + 0x00B { return "TOD_READ_SECONDARY_1.TOD_READ_SECONDARY_COUNTER" }
        case 0xccb0 + 0x00C { return "TOD_READ_SECONDARY_1.TOD_READ_SECONDARY_SEL_CFG_0" }
        case 0xccb0 + 0x00D { return "TOD_READ_SECONDARY_1.TOD_READ_SECONDARY_SEL_CFG_1" }
        case 0xccb0 + 0x00E { return "RESERVED " }
        case 0xccb0 + 0x00F { return "TOD_READ_SECONDARY_1.TOD_READ_SECONDARY_CMD" }

        case 0xccc0 + 0x000 { return "TOD_READ_SECONDARY_2.TOD_READ_SECONDARY" }
        case 0xccc0 + 0x00B { return "TOD_READ_SECONDARY_2.TOD_READ_SECONDARY_COUNTER" }
        case 0xccc0 + 0x00C { return "TOD_READ_SECONDARY_2.TOD_READ_SECONDARY_SEL_CFG_0" }
        case 0xccc0 + 0x00D { return "TOD_READ_SECONDARY_2.TOD_READ_SECONDARY_SEL_CFG_1" }
        case 0xccc0 + 0x00E { return "RESERVED " }
        case 0xccc0 + 0x00F { return "TOD_READ_SECONDARY_2.TOD_READ_SECONDARY_CMD" }

        case 0xccd0 + 0x000 { return "TOD_READ_SECONDARY_3.TOD_READ_SECONDARY" }
        case 0xccd0 + 0x00B { return "TOD_READ_SECONDARY_3.TOD_READ_SECONDARY_COUNTER" }
        case 0xccd0 + 0x00C { return "TOD_READ_SECONDARY_3.TOD_READ_SECONDARY_SEL_CFG_0" }
        case 0xccd0 + 0x00D { return "TOD_READ_SECONDARY_3.TOD_READ_SECONDARY_SEL_CFG_1" }
        case 0xccd0 + 0x00E { return "RESERVED " }
        case 0xccd0 + 0x00F { return "TOD_READ_SECONDARY_3.TOD_READ_SECONDARY_CMD" }

        case 0xcce0 + 0x000 { return "OUTPUT_TDC_CFG.OUTPUT_TDC_CFG_GBL_0" }
        case 0xcce0 + 0x002 { return "OUTPUT_TDC_CFG.OUTPUT_TDC_CFG_GBL_1" }
        case 0xcce0 + 0x004 { return "RESERVED " }
        case 0xcce0 + 0x005 { return "RESERVED " }
        case 0xcce0 + 0x006 { return "RESERVED " }
        case 0xcce0 + 0x007 { return "OUTPUT_TDC_CFG.OUTPUT_TDC_CFG_GBL_2" }

        case 0xcd00 + 0x000 { return "OUTPUT_TDC_0.OUTPUT_TDC_CTRL_0 Output TDC control register." }
        case 0xcd00 + 0x002 { return "OUTPUT_TDC_0.OUTPUT_TDC_CTRL_1 Output TDC control register." }
        case 0xcd00 + 0x004 { return "OUTPUT_TDC_0.OUTPUT_TDC_CTRL_2 Output TDC control register." }
        case 0xcd00 + 0x005 { return "OUTPUT_TDC_0.OUTPUT_TDC_CTRL_3 Output TDC control register." }
        case 0xcd00 + 0x006 { return "RESERVED " }
        case 0xcd00 + 0x007 { return "OUTPUT_TDC_0.OUTPUT_TDC_CTRL_4 Output TDC control register." }

        case 0xcd08 + 0x000 { return "OUTPUT_TDC_1.OUTPUT_TDC_CTRL_0 Output TDC control register." }
        case 0xcd08 + 0x002 { return "OUTPUT_TDC_1.OUTPUT_TDC_CTRL_1 Output TDC control register." }
        case 0xcd08 + 0x004 { return "OUTPUT_TDC_1.OUTPUT_TDC_CTRL_2 Output TDC control register." }
        case 0xcd08 + 0x005 { return "OUTPUT_TDC_1.OUTPUT_TDC_CTRL_3 Output TDC control register." }
        case 0xcd08 + 0x006 { return "RESERVED " }
        case 0xcd08 + 0x007 { return "OUTPUT_TDC_1.OUTPUT_TDC_CTRL_4 Output TDC control register." }

        case 0xcd10 + 0x000 { return "OUTPUT_TDC_2.OUTPUT_TDC_CTRL_0 Output TDC control register." }
        case 0xcd10 + 0x002 { return "OUTPUT_TDC_2.OUTPUT_TDC_CTRL_1 Output TDC control register." }
        case 0xcd10 + 0x004 { return "OUTPUT_TDC_2.OUTPUT_TDC_CTRL_2 Output TDC control register." }
        case 0xcd10 + 0x005 { return "OUTPUT_TDC_2.OUTPUT_TDC_CTRL_3 Output TDC control register." }
        case 0xcd10 + 0x006 { return "RESERVED " }
        case 0xcd10 + 0x007 { return "OUTPUT_TDC_2.OUTPUT_TDC_CTRL_4 Output TDC control register." }

        case 0xcd18 + 0x000 { return "OUTPUT_TDC_3.OUTPUT_TDC_CTRL_0 Output TDC control register." }
        case 0xcd18 + 0x002 { return "OUTPUT_TDC_3.OUTPUT_TDC_CTRL_1 Output TDC control register." }
        case 0xcd18 + 0x004 { return "OUTPUT_TDC_3.OUTPUT_TDC_CTRL_2 Output TDC control register." }
        case 0xcd18 + 0x005 { return "OUTPUT_TDC_3.OUTPUT_TDC_CTRL_3 Output TDC control register." }
        case 0xcd18 + 0x006 { return "RESERVED " }
        case 0xcd18 + 0x007 { return "OUTPUT_TDC_3.OUTPUT_TDC_CTRL_4 Output TDC control register." }

        case 0xcd20 + 0x000 { return "INPUT_TDC.INPUT_TDC_SDM_FRAC Input TDC feedback divider fractional value." }
        case 0xcd20 + 0x002 { return "INPUT_TDC.INPUT_TDC_SDM_MOD Input TDC feedback divider modulus value." }
        case 0xcd20 + 0x004 { return "INPUT_TDC.INPUT_TDC_FBD_CTRL Input TDC feedback divider control." }
        case 0xcd20 + 0x005 { return "RESERVED " }
        case 0xcd20 + 0x006 { return "RESERVED " }
        case 0xcd20 + 0x007 { return "INPUT_TDC.INPUT_TDC_CTRL Input TDC contro" }

        case 0xcd28 + 0x000 { return "SYSREF.SYSREF_OUTPUTS SYSREF outputs." }
        case 0xcd28 + 0x002 { return "SYSREF.SYSREF_PULSES SYSREF pulses" }

        case 0xcf4c + 0x000 { return "SCRATCH.SCRATCH0 Multipurpose register" }
        case 0xcf4c + 0x004 { return "SCRATCH.SCRATCH1 Multipurpose register" }
        case 0xcf4c + 0x008 { return "SCRATCH.SCRATCH2 Multipurpose register" }
        case 0xcf4c + 0x00C { return "SCRATCH.SCRATCH3 Multipurpose register" }

        case 0xcf64 + 0x000 { return "EEPROM.EEPROM_I2C_ADDR EEPROM I2C address." }
        case 0xcf64 + 0x001 { return "EEPROM.EEPROM_SIZE EEPROM data transfer size." }
        case 0xcf64 + 0x002 { return "EEPROM.EEPROM_OFFSET EEPROM offset." }
        case 0xcf64 + 0x004 { return "RESERVED " }
        case 0xcf64 + 0x005 { return "RESERVED " }
        case 0xcf64 + 0x006 { return "EEPROM.EEPROM_CMD EEPROM command." }

        case 0xcf70 + 0x000 { return "OTP.OTP_CMD OTP command." }
        case 0xcf70 + 0x004 { return "OTP.OTP_CM_CTR Device counter." }
        case 0xcf70 + 0x006 { return "OTP.OTP_HOST_CTR Update counter." }

        case 0xcf80 + 0x000 { return "BYTE.OTP_EEPROM_PWM_BUFF_0" }
        case 0xcf80 + 0x001 { return "BYTE.OTP_EEPROM_PWM_BUFF_1" }
        case 0xcf80 + 0x002 { return "BYTE.OTP_EEPROM_PWM_BUFF_2" }
        case 0xcf80 + 0x003 { return "BYTE.OTP_EEPROM_PWM_BUFF_3" }
        case 0xcf80 + 0x004 { return "BYTE.OTP_EEPROM_PWM_BUFF_4" }
        case 0xcf80 + 0x005 { return "BYTE.OTP_EEPROM_PWM_BUFF_5" }
        case 0xcf80 + 0x006 { return "BYTE.OTP_EEPROM_PWM_BUFF_6" }
        case 0xcf80 + 0x007 { return "BYTE.OTP_EEPROM_PWM_BUFF_7" }
        case 0xcf80 + 0x008 { return "BYTE.OTP_EEPROM_PWM_BUFF_8" }
        case 0xcf80 + 0x009 { return "BYTE.OTP_EEPROM_PWM_BUFF_9" }
        case 0xcf80 + 0x00A { return "BYTE.OTP_EEPROM_PWM_BUFF_10" }
        case 0xcf80 + 0x00B { return "BYTE.OTP_EEPROM_PWM_BUFF_11" }
        case 0xcf80 + 0x00C { return "BYTE.OTP_EEPROM_PWM_BUFF_12" }
        case 0xcf80 + 0x00D { return "BYTE.OTP_EEPROM_PWM_BUFF_13" }
        case 0xcf80 + 0x00E { return "BYTE.OTP_EEPROM_PWM_BUFF_14" }
        case 0xcf80 + 0x00F { return "BYTE.OTP_EEPROM_PWM_BUFF_15" }
        case 0xcf80 + 0x010 { return "BYTE.OTP_EEPROM_PWM_BUFF_16" }
        case 0xcf80 + 0x011 { return "BYTE.OTP_EEPROM_PWM_BUFF_17" }
        case 0xcf80 + 0x012 { return "BYTE.OTP_EEPROM_PWM_BUFF_18" }
        case 0xcf80 + 0x013 { return "BYTE.OTP_EEPROM_PWM_BUFF_19" }
        case 0xcf80 + 0x014 { return "BYTE.OTP_EEPROM_PWM_BUFF_20" }
        case 0xcf80 + 0x015 { return "BYTE.OTP_EEPROM_PWM_BUFF_21" }
        case 0xcf80 + 0x016 { return "BYTE.OTP_EEPROM_PWM_BUFF_22" }
        case 0xcf80 + 0x017 { return "BYTE.OTP_EEPROM_PWM_BUFF_23" }
        case 0xcf80 + 0x018 { return "BYTE.OTP_EEPROM_PWM_BUFF_24" }
        case 0xcf80 + 0x019 { return "BYTE.OTP_EEPROM_PWM_BUFF_25" }
        case 0xcf80 + 0x01A { return "BYTE.OTP_EEPROM_PWM_BUFF_26" }
        case 0xcf80 + 0x01B { return "BYTE.OTP_EEPROM_PWM_BUFF_27" }
        case 0xcf80 + 0x01C { return "BYTE.OTP_EEPROM_PWM_BUFF_28" }
        case 0xcf80 + 0x01D { return "BYTE.OTP_EEPROM_PWM_BUFF_29" }
        case 0xcf80 + 0x01E { return "BYTE.OTP_EEPROM_PWM_BUFF_30" }
        case 0xcf80 + 0x01F { return "BYTE.OTP_EEPROM_PWM_BUFF_31" }
        case 0xcf80 + 0x020 { return "BYTE.OTP_EEPROM_PWM_BUFF_32" }
        case 0xcf80 + 0x021 { return "BYTE.OTP_EEPROM_PWM_BUFF_33" }
        case 0xcf80 + 0x022 { return "BYTE.OTP_EEPROM_PWM_BUFF_34" }
        case 0xcf80 + 0x023 { return "BYTE.OTP_EEPROM_PWM_BUFF_35" }
        case 0xcf80 + 0x024 { return "BYTE.OTP_EEPROM_PWM_BUFF_36" }
        case 0xcf80 + 0x025 { return "BYTE.OTP_EEPROM_PWM_BUFF_37" }
        case 0xcf80 + 0x026 { return "BYTE.OTP_EEPROM_PWM_BUFF_38" }
        case 0xcf80 + 0x027 { return "BYTE.OTP_EEPROM_PWM_BUFF_39" }
        case 0xcf80 + 0x028 { return "BYTE.OTP_EEPROM_PWM_BUFF_40" }
        case 0xcf80 + 0x029 { return "BYTE.OTP_EEPROM_PWM_BUFF_41" }
        case 0xcf80 + 0x02A { return "BYTE.OTP_EEPROM_PWM_BUFF_42" }
        case 0xcf80 + 0x02B { return "BYTE.OTP_EEPROM_PWM_BUFF_43" }
        case 0xcf80 + 0x02C { return "BYTE.OTP_EEPROM_PWM_BUFF_44" }
        case 0xcf80 + 0x02D { return "BYTE.OTP_EEPROM_PWM_BUFF_45" }
        case 0xcf80 + 0x02E { return "BYTE.OTP_EEPROM_PWM_BUFF_46" }
        case 0xcf80 + 0x02F { return "BYTE.OTP_EEPROM_PWM_BUFF_47" }
        case 0xcf80 + 0x030 { return "BYTE.OTP_EEPROM_PWM_BUFF_48" }
        case 0xcf80 + 0x031 { return "BYTE.OTP_EEPROM_PWM_BUFF_49" }
        case 0xcf80 + 0x032 { return "BYTE.OTP_EEPROM_PWM_BUFF_50" }
        case 0xcf80 + 0x033 { return "BYTE.OTP_EEPROM_PWM_BUFF_51" }
        case 0xcf80 + 0x034 { return "BYTE.OTP_EEPROM_PWM_BUFF_52" }
        case 0xcf80 + 0x035 { return "BYTE.OTP_EEPROM_PWM_BUFF_53" }
        case 0xcf80 + 0x036 { return "BYTE.OTP_EEPROM_PWM_BUFF_54" }
        case 0xcf80 + 0x037 { return "BYTE.OTP_EEPROM_PWM_BUFF_55" }
        case 0xcf80 + 0x038 { return "BYTE.OTP_EEPROM_PWM_BUFF_56" }
        case 0xcf80 + 0x039 { return "BYTE.OTP_EEPROM_PWM_BUFF_57" }
        case 0xcf80 + 0x03A { return "BYTE.OTP_EEPROM_PWM_BUFF_58" }
        case 0xcf80 + 0x03B { return "BYTE.OTP_EEPROM_PWM_BUFF_59" }
        case 0xcf80 + 0x03C { return "BYTE.OTP_EEPROM_PWM_BUFF_60" }
        case 0xcf80 + 0x03D { return "BYTE.OTP_EEPROM_PWM_BUFF_61" }
        case 0xcf80 + 0x03E { return "BYTE.OTP_EEPROM_PWM_BUFF_62" }
        case 0xcf80 + 0x03F { return "BYTE.OTP_EEPROM_PWM_BUFF_63" }
        case 0xcf80 + 0x040 { return "BYTE.OTP_EEPROM_PWM_BUFF_64" }
        case 0xcf80 + 0x041 { return "BYTE.OTP_EEPROM_PWM_BUFF_65" }
        case 0xcf80 + 0x042 { return "BYTE.OTP_EEPROM_PWM_BUFF_66" }
        case 0xcf80 + 0x043 { return "BYTE.OTP_EEPROM_PWM_BUFF_67" }
        case 0xcf80 + 0x044 { return "BYTE.OTP_EEPROM_PWM_BUFF_68" }
        case 0xcf80 + 0x045 { return "BYTE.OTP_EEPROM_PWM_BUFF_69" }
        case 0xcf80 + 0x046 { return "BYTE.OTP_EEPROM_PWM_BUFF_70" }
        case 0xcf80 + 0x047 { return "BYTE.OTP_EEPROM_PWM_BUFF_71" }
        case 0xcf80 + 0x048 { return "BYTE.OTP_EEPROM_PWM_BUFF_72" }
        case 0xcf80 + 0x049 { return "BYTE.OTP_EEPROM_PWM_BUFF_73" }
        case 0xcf80 + 0x04A { return "BYTE.OTP_EEPROM_PWM_BUFF_74" }
        case 0xcf80 + 0x04B { return "BYTE.OTP_EEPROM_PWM_BUFF_75" }
        case 0xcf80 + 0x04C { return "BYTE.OTP_EEPROM_PWM_BUFF_76" }
        case 0xcf80 + 0x04D { return "BYTE.OTP_EEPROM_PWM_BUFF_77" }
        case 0xcf80 + 0x04E { return "BYTE.OTP_EEPROM_PWM_BUFF_78" }
        case 0xcf80 + 0x04F { return "BYTE.OTP_EEPROM_PWM_BUFF_79" }
        case 0xcf80 + 0x050 { return "BYTE.OTP_EEPROM_PWM_BUFF_80" }
        case 0xcf80 + 0x051 { return "BYTE.OTP_EEPROM_PWM_BUFF_81" }
        case 0xcf80 + 0x052 { return "BYTE.OTP_EEPROM_PWM_BUFF_82" }
        case 0xcf80 + 0x053 { return "BYTE.OTP_EEPROM_PWM_BUFF_83" }
        case 0xcf80 + 0x054 { return "BYTE.OTP_EEPROM_PWM_BUFF_84" }
        case 0xcf80 + 0x055 { return "BYTE.OTP_EEPROM_PWM_BUFF_85" }
        case 0xcf80 + 0x056 { return "BYTE.OTP_EEPROM_PWM_BUFF_86" }
        case 0xcf80 + 0x057 { return "BYTE.OTP_EEPROM_PWM_BUFF_87" }
        case 0xcf80 + 0x058 { return "BYTE.OTP_EEPROM_PWM_BUFF_88" }
        case 0xcf80 + 0x059 { return "BYTE.OTP_EEPROM_PWM_BUFF_89" }
        case 0xcf80 + 0x05A { return "BYTE.OTP_EEPROM_PWM_BUFF_90" }
        case 0xcf80 + 0x05B { return "BYTE.OTP_EEPROM_PWM_BUFF_91" }
        case 0xcf80 + 0x05C { return "BYTE.OTP_EEPROM_PWM_BUFF_92" }
        case 0xcf80 + 0x05D { return "BYTE.OTP_EEPROM_PWM_BUFF_93" }
        case 0xcf80 + 0x05E { return "BYTE.OTP_EEPROM_PWM_BUFF_94" }
        case 0xcf80 + 0x05F { return "BYTE.OTP_EEPROM_PWM_BUFF_95" }
        case 0xcf80 + 0x060 { return "BYTE.OTP_EEPROM_PWM_BUFF_96" }
        case 0xcf80 + 0x061 { return "BYTE.OTP_EEPROM_PWM_BUFF_97" }
        case 0xcf80 + 0x062 { return "BYTE.OTP_EEPROM_PWM_BUFF_98" }
        case 0xcf80 + 0x063 { return "BYTE.OTP_EEPROM_PWM_BUFF_99" }
        case 0xcf80 + 0x064 { return "BYTE.OTP_EEPROM_PWM_BUFF_100" }
        case 0xcf80 + 0x065 { return "BYTE.OTP_EEPROM_PWM_BUFF_101" }
        case 0xcf80 + 0x066 { return "BYTE.OTP_EEPROM_PWM_BUFF_102" }
        case 0xcf80 + 0x067 { return "BYTE.OTP_EEPROM_PWM_BUFF_103" }
        case 0xcf80 + 0x068 { return "BYTE.OTP_EEPROM_PWM_BUFF_104" }
        case 0xcf80 + 0x069 { return "BYTE.OTP_EEPROM_PWM_BUFF_105" }
        case 0xcf80 + 0x06A { return "BYTE.OTP_EEPROM_PWM_BUFF_106" }
        case 0xcf80 + 0x06B { return "BYTE.OTP_EEPROM_PWM_BUFF_107" }
        case 0xcf80 + 0x06C { return "BYTE.OTP_EEPROM_PWM_BUFF_108" }
        case 0xcf80 + 0x06D { return "BYTE.OTP_EEPROM_PWM_BUFF_109" }
        case 0xcf80 + 0x06E { return "BYTE.OTP_EEPROM_PWM_BUFF_110" }
        case 0xcf80 + 0x06F { return "BYTE.OTP_EEPROM_PWM_BUFF_111" }
        case 0xcf80 + 0x070 { return "BYTE.OTP_EEPROM_PWM_BUFF_112" }
        case 0xcf80 + 0x071 { return "BYTE.OTP_EEPROM_PWM_BUFF_113" }
        case 0xcf80 + 0x072 { return "BYTE.OTP_EEPROM_PWM_BUFF_114" }
        case 0xcf80 + 0x073 { return "BYTE.OTP_EEPROM_PWM_BUFF_115" }
        case 0xcf80 + 0x074 { return "BYTE.OTP_EEPROM_PWM_BUFF_116" }
        case 0xcf80 + 0x075 { return "BYTE.OTP_EEPROM_PWM_BUFF_117" }
        case 0xcf80 + 0x076 { return "BYTE.OTP_EEPROM_PWM_BUFF_118" }
        case 0xcf80 + 0x077 { return "BYTE.OTP_EEPROM_PWM_BUFF_119" }
        case 0xcf80 + 0x078 { return "BYTE.OTP_EEPROM_PWM_BUFF_120" }
        case 0xcf80 + 0x079 { return "BYTE.OTP_EEPROM_PWM_BUFF_121" }
        case 0xcf80 + 0x07A { return "BYTE.OTP_EEPROM_PWM_BUFF_122" }
        case 0xcf80 + 0x07B { return "BYTE.OTP_EEPROM_PWM_BUFF_123" }
        case 0xcf80 + 0x07C { return "BYTE.OTP_EEPROM_PWM_BUFF_124" }
        case 0xcf80 + 0x07D { return "BYTE.OTP_EEPROM_PWM_BUFF_125" }
        case 0xcf80 + 0x07E { return "BYTE.OTP_EEPROM_PWM_BUFF_126" }
        case 0xcf80 + 0x07F { return "BYTE.OTP_EEPROM_PWM_BUFF_127" }

        else        { return "unknown or not defined" }
    }
}

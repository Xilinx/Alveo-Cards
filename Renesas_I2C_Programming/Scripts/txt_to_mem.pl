#! /usr/bin/perl

#
# 
# Copyright (C) 2024, Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: X11
# 
#

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
    exit; 
}

# ---------------------------------------------------------------------

# These are the two output files :
#    1. the one from the command line, 
#    2. a humanized log for better debug

$ofile0 = $ofile;
$ofile1 = $ofile.'.log';
if( -e "$ofile1") { unlink "$ofile1"; }

$devid = hex($devid);

# ---------------------------------------------------------------------

# Load the input text file...
@PARAM = qx(cat $ifile);

$nn = 0;

open SOUT0, ">$ofile0";
open SOUT1, ">$ofile1";

printf SOUT0 ("memory_initialization_radix=16\;\n");
printf SOUT0 ("memory_initialization_vector=\n");

# Initial line sets the Device ID.
printf SOUT0 ("%02x%02x,\n", 0x01, $devid);
printf SOUT1 ("instru\[%03d\]  = { DEV_ID_OP     , 8'h%02x }\;\n", $nn, $devid);
$nn++;

# Each valid line has the following format...
#   Size: 0x4, Offset: FC, Data: 0x00C01020
foreach $temp (@PARAM)
{
    # Prep read line...
    chomp $temp;
    $temp =~ s/,//g;    
    @TOK = split /\s/, $temp;

    #
    #  Script files with the following format...
    #       i2cset -f -y 15 0x5b 0xfc 0x00 0xc3 0x10 0x20 i
    #
    if ( $TOK[0] =~ /i2cset/ ) 
    {
        # Extrace size,offset and data from valid lines....
        $size = $#TOK - 6;
        $addr = hex($TOK[5]);
        
        # Print instructions for Size and Addr...
        printf SOUT0 ("%02x%02x,\n", 0x02, $size);
        printf SOUT1 ("instru\[%03d\]  = { SIZE_OP       , 8'h%02x }\;\n", $nn, $size);
        $nn++;
        printf SOUT0 ("%02x%02x,\n", 0x04, $addr);
        printf SOUT1 ("instru\[%03d\]  = { ADDR_OP       , 8'h%02x }\;\n", $nn, $addr);
        $nn++;
        
        # Loop though Data string, one byte at a time, except for final byte...
        $len1 = length($data);
        for($ii=0;$ii<$size-1;$ii=$ii+1)
        {
            $temp = hex($TOK[6 + $ii]);
            printf SOUT0 ("%02x%02x,\n", 0x08, $temp);
            printf SOUT1 ("instru\[%03d\]  = { WDATA_OP      , 8'h%02x }\;\n", $nn, $temp);
            $nn++;
        }
        # Last Data byte gets a different identifier...
        $temp = hex($TOK[6 + $ii]);
        printf SOUT0 ("%02x%02x,\n", 0x10, $temp);
        printf SOUT1 ("instru\[%03d\]  = { WDATA_LAST_OP , 8'h%02x }\;\n", $nn, $temp);
        $nn++;
    }
    
    #
    #  Script files with the following format...
    #       Size: 0x4, Offset: FC, Data: 0x00C01020
    #
    if ( $TOK[0] =~ /Size/ ) 
    {
        # Extrace size,offset and data from valid lines....
        $size = hex($TOK[1]);
        $addr = hex('0x'.$TOK[3]);
        $data = $TOK[5];
        
        # Print instructions for Size and Addr...
        printf SOUT0 ("%02x%02x,\n", 0x02, $size);
        printf SOUT1 ("instru\[%03d\]  = { SIZE_OP       , 8'h%02x }\;\n", $nn, $size);
        $nn++;
        printf SOUT0 ("%02x%02x,\n", 0x04, $addr);
        printf SOUT1 ("instru\[%03d\]  = { ADDR_OP       , 8'h%02x }\;\n", $nn, $addr);
        $nn++;
        
        # Loop though Data string, one byte at a time, except for final byte...
        $len1 = length($data);
        $size = $size * 2;
        for($ii=0;$ii<$size-2;$ii=$ii+2)
        {
            $temp = substr($data,$len1-$ii-2,2);
            printf SOUT0 ("%02x%s,\n", 0x08, $temp);
            printf SOUT1 ("instru\[%03d\]  = { WDATA_OP      , 8'h%s }\;\n", $nn, $temp);
            $nn++;
        }
        # Last Data byte gets a different identifier...
        $temp = substr($data,$len1-$ii-2,2);
        printf SOUT0 ("%02x%s,\n", 0x10, $temp);
        printf SOUT1 ("instru\[%03d\]  = { WDATA_LAST_OP , 8'h%s }\;\n", $nn, $temp);
        $nn++;
    }
}

# Add a "Finished" tag for the state machine....
printf SOUT0 ("%02x%02x\;\n", 0x80, 0xFF);
printf SOUT1 ("instru\[%03d\]  = { FINISHED_OP   , 8'h%02x }\;\n", $nn, 0xFF);
$nn++;

close SOUT0;

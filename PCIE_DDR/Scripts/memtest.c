/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

//------------------------------------------------------------------------------

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <stdint.h>
#include <unistd.h>
#include <string.h>
#include <dirent.h>

// -------------------------------------------------------------------
// Global Variables...
char  device0[32]     = "0000:01:00.0";
void* region0_address = (void*)0xc0000000;
void* region1_address = (void*)0x80000000;

size_t region0_size = 128 * 1024; // 128K
size_t region1_size = 1 * 1024 * 1024 * 1024; // 1G

uint32_t* memory0;
uint32_t* memory1;

void* region0_memory;
void* region1_memory;

// -------------------------------------------------------------------

int initialize_memory ( char * device0 ) {

    printf("Initializing Memory Pointers...\n");

    char str0[256];
    
    sprintf(str0, "/sys/bus/pci/devices/%s/resource0", device0);
    int region0 = open(str0, O_RDWR | O_SYNC);

    sprintf(str0, "/sys/bus/pci/devices/%s/resource1", device0);
    int region1 = open(str0, O_RDWR | O_SYNC);
    
    region0_memory = mmap(region0_address,
                          region0_size,
                          PROT_READ | PROT_WRITE,
                          MAP_SHARED,
                          region0,
                          0);
    
    
    region1_memory = mmap(region1_address,
                          region1_size,
                          PROT_READ | PROT_WRITE,
                          MAP_SHARED,
                          region1,
                          0);
       
    close(region0);
    close(region1);
        
    memory0 = (uint32_t*)region0_memory;
    memory1 = (uint32_t*)region1_memory;

    return 0;
}


uint32_t write_reg( uint32_t region, uint32_t addr, uint32_t wdata) {
    // Addr is byte address, memory0 is 4 byte address 
    if (region == 0) { memory0[addr >> 2] = wdata; }
    if (region == 1) { memory1[addr >> 2] = wdata; }
    return 0;
}

uint32_t read_reg( uint32_t region, uint32_t addr) {
    // Addr is byte address, memory0 is 4 byte address 
    uint32_t temp;
    if (region == 0) { temp = memory0[addr >> 2]; }
    if (region == 1) { temp = memory1[addr >> 2]; }
    return temp;
}


uint32_t prbs32;
uint32_t gen_prbs32( uint32_t value ) {    
    uint32_t prbs32_t;
    if ( value == 0x0) {
        prbs32_t = ( (prbs32>>31) ^ (prbs32>>21) ^ (prbs32>>1) ^  (prbs32>>0) ) & 0x1; 
        prbs32   = (( prbs32 << 1) | prbs32_t) & 0xFFFFFFFF;
    }
    else
    {
        prbs32 = value;
    }
    return prbs32;
}

// -------------------------------------------------------------------

uint32_t cycles;
int process_cmdline (int argc, char *argv[]) {
  
    //device0[0] = 0x0;
    //strcpy(device0,"0000:01:00.0");

    cycles = 10;
    
    int ii;
    for(ii=1;ii<argc;ii++)
    {
        if (argv[ii][0] == '-' )
        {
            switch (argv[ii][1])  {
                default:
                        printf("Unknown option -%c\n\n", argv[ii][1]);
                        break;
                case 'd':
                        ++ii;
                        strcpy(device0, argv[ii]);
                        break;
                case 'c':
                        ++ii;
                        cycles = atoi(argv[ii]);
                        break;
            }
        }
    } 
    
    if ( device0[0] == 0x0) 
    {
        printf("ERROR - device ID missing from command line\n");
    }
    
    return 0;
}


// -------------------------------------------------------------------

uint32_t init_ddr( void ) {
    printf("Enabling DDR power and DDR IP...\n");
    write_reg(0, 0x04, 0x02 ); // i2c reset
    write_reg(0, 0x04, 0x03 ); // i2c enable
    write_reg(0, 0x04, 0x01 ); // ddr + i2c enable
    sleep(1.00);
    return 0;
}


uint32_t memtest( uint32_t cycles ) {    
    printf("Starting memtest\n");
    
    uint32_t ii;
    uint32_t temp_u32_0;
    uint32_t temp_u32_1;
    
    printf("   running %d cycles\n", cycles);
    gen_prbs32( 0x16872941 );
    for(ii=0;ii<cycles;ii++)
    {
        temp_u32_0 = gen_prbs32( 0 );
        write_reg( 1, ii*4, temp_u32_0 );
    }
    
    gen_prbs32( 0x16872941 );
    for(ii=0;ii<cycles;ii++)
    {
        temp_u32_0 = read_reg( 1, ii*4 );
        temp_u32_1 = gen_prbs32( 0 );
        if ( temp_u32_0 != temp_u32_1 )
        {
            printf("[READ] ERROR :: 0x%08x = 0x%8x - 0x%08x\n", ii, temp_u32_0, temp_u32_1);
        }
    }
    printf("...memtest complete\n");
    return 0;
}

// -------------------------------------------------------------------

int main (int argc, char *argv[]) {
    uint32_t temp_u32_0;

    process_cmdline( argc, argv );
    
    initialize_memory( device0 );

    printf("Checking DDR power...\n");
    temp_u32_0 = read_reg(0, 0x10); 
    //printf("0x10 0x%08x\n", temp_u32_0);
    if ( (temp_u32_0 & 0x100) == 0x0) 
    {
        init_ddr();
        sleep(1.00);
    }
    
    memtest( cycles );

    return 0;    
}

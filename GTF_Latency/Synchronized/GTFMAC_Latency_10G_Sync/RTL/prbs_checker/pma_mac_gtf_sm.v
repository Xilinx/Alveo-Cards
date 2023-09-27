/*
Copyright (c) 2023, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

`timescale 1ns / 1ps

`define AUTO_MODE_RAW
//`define ADD_FCS     //enables FCS insertion by core

`ifdef AUTO_MODE_RAW
`define AUTO_MODE
`endif

`define init        			5'd0
`define start       			5'd1
`define run_drp     			5'd2
`define wait_drpdone     		5'd3
`define check_drpdone     		5'd4
`define start_phdly   			5'd5
`define check_txdlysrstdone  	5'd6
`define set_txphinit  			5'd7
`define check_txphinit  		5'd8
`define set_txphalign  			5'd9
`define check_txphalign_pulse   5'd10
`define start_txdlyalign   		5'd11
`define check_txphalign_done  	5'd12
`define check_txsync_done  		5'd13

`define check_rxdlysrstdone  	5'd14
`define set_rxphinit  			5'd15
`define check_rxphinit  		5'd16
`define set_rxphalign  			5'd17
`define check_rxphalign_pulse   5'd18
`define start_rxdlyalign   		5'd19
`define check_rxphalign_done  	5'd20
`define check_rxsync_done  		5'd21
`define start_preable			5'd22
`define start_data				5'd23
`define run_compare				5'd24
`define start_tlast				5'd25
`define dummy_wait_last_packet	5'd26
`define check_compare			5'd27
`define done					5'd28
`define fail_data				5'd29

module pma_mac_gtf_sm (
	CLK				    ,	 
	RST				    , 
	START			    , 
	START_MM		    , 
	BIST_COUNT		    , 
	TXDLYSRESET		    , 
	TXDLYSRESETDONE	    , 
	TXPHINIT		    ,
	TXPHINITDONE	    ,
	TXPHALIGNEN		    ,
	TXPHALIGN		    ,
	TXPHALIGNDONE	    ,
	TXSYNCDONE	        ,
	TXDLYEN			    ,
	RXDLYSRESET		    , 
	RXDLYSRESETDONE	    , 
	RXPHINIT		    ,
	RXPHINITDONE    	,
	RXPHALIGNEN		    ,
	RXPHALIGN		    ,
	RXPHALIGNDONE	    ,
	RXSYNCDONE		    ,
	RXPHALIGNERR	    ,
	RXDLYEN			    ,
	GT_RESET		    , 
	BIST_CNT_EN		    , 
	BIST_CNT_RST	    , 
	PREAMBLE_EN		    ,
	BERT_EN			    ,
	TLAST_EN		    ,
	BERT_SYNC		    , 
	ERROR_COUNT_EN	    , 
	BERT_PASS		    ,
	BERT_DET_OUT	    ,     
	STATRXPKT           ,
	STATRXPKTERR        ,
	STATRXSTATUS        ,
	STATRXBADFCS        ,
	STATRXFCSERR        ,
	STATTXPKT           ,
	STATTXPKTERR        ,
	STATTXBADFCS        ,
	STATTXFCSERR        ,
	DONE			    ,
	STATE			    ,
	DATA_ERROR		    ,
	packet_count        ,
	STATRXPKTERR_STICKY ,
    STATRXSTATUS_STICKY ,
    STATTXPKTERR_STICKY ,
    STATTXBADFCS_STICKY ,
    STATTXFCSERR_STICKY ,
    STATRXBADFCS_STICKY ,
    STATRXFCSERR_STICKY ,
    wa_complete_flg
);

parameter COUNT_SIZE 	= 11;
parameter PREABLE_BYTE 	= 3;
parameter NUM_OF_PACKETS = 5;

input 	CLK; 
input 	RST;
input 	START;


input  TXPHALIGNDONE;
input  TXSYNCDONE;
input  TXPHINITDONE;
input  TXDLYSRESETDONE ;
input  RXPHALIGNDONE;
input  RXSYNCDONE;
input  RXPHALIGNERR;
input  RXPHINITDONE;
input  RXDLYSRESETDONE ;

input BERT_PASS; 
input BERT_DET_OUT;
input STATRXPKT;
input STATRXPKTERR;
input STATRXSTATUS;
input STATRXBADFCS;
input STATRXFCSERR;
input STATTXPKT;
input STATTXPKTERR;
input STATTXBADFCS;
input STATTXFCSERR;

input  [COUNT_SIZE:0] BIST_COUNT;

output GT_RESET;
output BIST_CNT_EN;
output BIST_CNT_RST;
output PREAMBLE_EN; 
output BERT_EN; 
output TLAST_EN; 
output BERT_SYNC;
output ERROR_COUNT_EN;


output TXPHALIGN;
output TXPHALIGNEN;
output TXPHINIT;
output TXDLYEN;
output TXDLYSRESET;
output RXPHALIGN;
output RXPHALIGNEN;
output RXPHINIT;
output RXDLYEN;
output RXDLYSRESET;
output DONE;

output DATA_ERROR;
output START_MM;

output [4:0] STATE;
output [7:0] packet_count;
//EG flesh out statuses
output STATRXPKTERR_STICKY;
output STATRXSTATUS_STICKY;
output STATTXPKTERR_STICKY;
output STATTXBADFCS_STICKY;
output STATTXFCSERR_STICKY;
output STATRXBADFCS_STICKY;
output STATRXFCSERR_STICKY;
input  wa_complete_flg;


wire STATRXPKTERR_STICKY;
wire STATRXSTATUS_STICKY;
wire STATTXPKTERR_STICKY;
wire STATTXBADFCS_STICKY;
wire STATTXFCSERR_STICKY;
wire STATRXBADFCS_STICKY;
wire STATRXFCSERR_STICKY;
// Registers
reg  [4:0] state;
reg [4:0] STATE;
reg  GT_RESET; 
reg  START_MM;
reg  BIST_CNT_EN;
reg  BIST_CNT_RST;
reg  PREAMBLE_EN; 
reg  BERT_EN; 
reg  TLAST_EN; 
reg  BERT_SYNC;
reg  ERROR_COUNT_EN;
reg  DONE; 
reg  DATA_ERROR;
reg  TXDLYSRESET;
reg  TXDLYEN; 
reg  TXPHALIGN;
reg  TXPHALIGNEN;
reg  TXPHINIT;
wire TXDLYSRESETDONE; 
wire TXPHALIGNDONE; 
wire TXSYNCDONE; 
wire TXPHINITDONE; 
reg  RXDLYSRESET;
reg  RXDLYEN; 
reg  RXPHALIGN;
reg  RXPHALIGNEN;
reg  RXPHINIT;
wire RXDLYSRESETDONE; 
wire RXPHALIGNDONE; 
wire RXSYNCDONE; 
wire RXPHALIGNERR; 
wire RXPHINITDONE; 

reg [7:0] packet_count;

FDCE txdlysresetdone_sticky (.D(1'b1), .Q(TXDLYSRESETDONE_STICKY), .CE(TXDLYSRESETDONE), .CLR(RST), .C(CLK)); 
FDCE rxdlysresetdone_sticky (.D(1'b1), .Q(RXDLYSRESETDONE_STICKY), .CE(RXDLYSRESETDONE), .CLR(RST), .C(CLK)); 

FDCE statrxstatus_sticky (.D(1'b1), .Q(STATRXSTATUS_STICKY), .CE(STATRXSTATUS), .CLR(RST), .C(CLK)); 
FDCE statrxpkterr_sticky (.D(1'b1), .Q(STATRXPKTERR_STICKY), .CE(STATRXPKTERR), .CLR(RST), .C(CLK)); 
FDCE stattxpkterr_sticky (.D(1'b1), .Q(STATTXPKTERR_STICKY), .CE(STATTXPKTERR), .CLR(RST), .C(CLK)); 

`ifdef ADD_FCS
FDCE statrxbadfcs_sticky (.D(1'b1), .Q(STATRXBADFCS_STICKY), .CE(STATRXBADFCS), .CLR(RST), .C(CLK)); 
FDCE statrxfcserr_sticky (.D(1'b1), .Q(STATRXFCSERR_STICKY), .CE(STATRXFCSERR), .CLR(RST), .C(CLK)); 
FDCE stattxbadfcs_sticky (.D(1'b1), .Q(STATTXBADFCS_STICKY), .CE(STATTXBADFCS), .CLR(RST), .C(CLK)); 
FDCE stattxfcserr_sticky (.D(1'b1), .Q(STATTXFCSERR_STICKY), .CE(STATTXFCSERR), .CLR(RST), .C(CLK)); 
`else
assign STATRXBADFCS_STICKY = 1'b0;
assign STATRXFCSERR_STICKY = 1'b0;
assign STATTXBADFCS_STICKY = 1'b0;
assign STATTXFCSERR_STICKY = 1'b0;
`endif



// initialize all registers
initial 
  begin
    //state             = `check_rxphalign_done;
    state             = `init;
    GT_RESET          = 1'b0;
    BIST_CNT_RST      = 1'b0;
    BIST_CNT_EN       = 1'b0;
    PREAMBLE_EN       = 1'b0;
    BERT_EN           = 1'b0;
    TLAST_EN          = 1'b0;
    BERT_SYNC         = 1'b0;
    ERROR_COUNT_EN    = 1'b0;
    DONE              = 1'b0;
    DATA_ERROR        = 1'b1;
    START_MM          = 1'b0;
    TXDLYEN           = 1'b0;
	`ifdef AUTO_MODE
	TXPHALIGNEN		  = 1'b0;
	RXPHALIGNEN		  = 1'b0;
	`else
	TXPHALIGNEN		  = 1'b1;
	RXPHALIGNEN		  = 1'b1;
	`endif
    TXPHALIGN         = 1'b0;
    TXPHINIT          = 1'b0;
    TXDLYSRESET       = 1'b0;
    RXPHALIGN         = 1'b0;
    RXPHINIT          = 1'b0;
    RXDLYSRESET       = 1'b0;
  end


// bist state machine
always @(posedge CLK) 
begin
  if(RST == 1'b1) 
  begin
    //state             = `check_rxphalign_done;
    state             = `init;
    GT_RESET 			<= 1'b1;
    BIST_CNT_RST 		<= 1'b1;
    BIST_CNT_EN 		<= 1'b0;
    PREAMBLE_EN 		<= 1'b0;
    BERT_EN 			<= 1'b0;
    TLAST_EN 			<= 1'b0;
    BERT_SYNC 			<= 1'b0;
    ERROR_COUNT_EN 		<= 1'b0;
    DONE 				<= 1'b0;
    DATA_ERROR 			<= 1'b1;
    START_MM      		<= 1'b0;
	TXPHALIGNEN			<= 1'b0;
	RXPHALIGNEN			<= 1'b0;
    TXDLYEN           	<= 1'b0;
    TXPHALIGN         	<= 1'b0;
    TXPHINIT          	<= 1'b0;
    TXDLYSRESET       	<= 1'b0;
    RXDLYEN           	<= 1'b0;
    RXPHALIGN         	<= 1'b0;
    RXPHINIT          	<= 1'b0;
    RXDLYSRESET       	<= 1'b0;
    STATE               <= `init;
    packet_count        <= 8'b0;
  end 
  else 
  begin
  STATE <= state;
    case (state[4:0])
      `init : begin
		// Wait for start
		state 			<= START ? `start : `init;
		GT_RESET 		<= 1'b0;
		BIST_CNT_RST	<= 1'b0;
		BIST_CNT_EN 	<= 1'b0;
		PREAMBLE_EN 	<= 1'b0;
		BERT_EN 		<= 1'b0;
		TLAST_EN 		<= 1'b0;
		BERT_SYNC 		<= 1'b0;
		DONE 			<= 1'b0;
		DATA_ERROR 		<= 1'b1;
		START_MM      	<= 1'b0;
		TXPHALIGNEN		<= 1'b0;
		RXPHALIGNEN		<= 1'b0;
		TXDLYEN         <= 1'b0;
		TXPHALIGN       <= 1'b0;
    	TXPHINIT       	<= 1'b0;
    	TXDLYSRESET    	<= 1'b0;
		RXDLYEN         <= 1'b0;
		RXPHALIGN       <= 1'b0;
		RXPHINIT        <= 1'b0;
		RXDLYSRESET     <= 1'b0;
		packet_count    <= 8'b0;
	    end

	    `start : begin
	     // Wait for start
		//drp fsm run is not required as direct attibute setting is applied for manual mode;
		state 			<= START ? `start : `start_phdly;
		GT_RESET 		<= GT_RESET ;
		BIST_CNT_RST 	<= BIST_CNT_RST ;
		BIST_CNT_EN 	<= BIST_CNT_EN ;
		PREAMBLE_EN 	<= PREAMBLE_EN ;
		BERT_EN 		<= BERT_EN ;
		TLAST_EN 		<= TLAST_EN;
		BERT_SYNC 		<= BERT_SYNC;
		ERROR_COUNT_EN 	<= ERROR_COUNT_EN;
		DONE 			<= DONE;
		DATA_ERROR 		<= DATA_ERROR;
		START_MM      	<= START_MM;
		TXDLYEN        	<= TXDLYEN;
		TXPHALIGN      	<= TXPHALIGN;
		`ifdef AUTO_MODE
		TXPHALIGNEN		<= 1'b0;
		RXPHALIGNEN		<= 1'b0;
		`else
		TXPHALIGNEN		<= 1'b1;
		RXPHALIGNEN		<= 1'b1;
		`endif
		TXPHINIT       	<= TXPHINIT;
		TXDLYSRESET    	<= TXDLYSRESET;
		RXDLYEN        	<= RXDLYEN;
		RXPHALIGN      	<= RXPHALIGN;
		RXPHINIT       	<= RXPHINIT;
		RXDLYSRESET    	<= RXDLYSRESET;
	    end

	    
		// expect phaligndone = 0 
 	   `start_phdly : 
	    begin
		state           <= TXPHALIGNDONE & RXPHALIGNDONE ? `start_txdlyalign: `check_txdlysrstdone;
		GT_RESET 		<= GT_RESET;
		BIST_CNT_RST 	<= 1'b1;
		BIST_CNT_EN 	<= BIST_CNT_EN;
		PREAMBLE_EN 	<= PREAMBLE_EN ;
		BERT_EN 		<= BERT_EN;
		TLAST_EN 		<= TLAST_EN;
		BERT_SYNC 		<= BERT_SYNC;
		ERROR_COUNT_EN 	<= ERROR_COUNT_EN;
		DONE 			<= DONE;
		DATA_ERROR 		<= DATA_ERROR;
		START_MM      	<= START_MM;
		TXDLYEN        	<= TXDLYEN;
		TXPHALIGN      	<= TXPHALIGN;
		TXPHALIGNEN		<= TXPHALIGNEN;
		TXPHINIT       	<= TXPHINIT;
		TXDLYSRESET    	<= TXDLYSRESET;
		RXDLYEN        	<= RXDLYEN;
		RXPHALIGN      	<= RXPHALIGN;
		RXPHALIGNEN		<= RXPHALIGNEN;
		RXPHINIT       	<= RXPHINIT;
		RXDLYSRESET    	<= RXDLYSRESET;
	    end
		
	    `check_txdlysrstdone :
	    begin
		`ifdef AUTO_MODE
		state   		<= TXDLYSRESETDONE_STICKY ? `set_txphalign : `check_txdlysrstdone;
		`else
		state   		<= TXDLYSRESETDONE_STICKY ? `set_txphinit : `check_txdlysrstdone;
		`endif
		
		GT_RESET 		<= GT_RESET;
		BIST_CNT_RST 	<= 1'b0;
		BIST_CNT_EN 	<= 1'b1;
		PREAMBLE_EN 	<= PREAMBLE_EN ;
		BERT_EN 		<= BERT_EN;
		TLAST_EN 		<= TLAST_EN;
		BERT_SYNC 		<= BERT_SYNC;
		ERROR_COUNT_EN 	<= ERROR_COUNT_EN;
		DONE 			<= DONE;
		DATA_ERROR 		<= DATA_ERROR;
		START_MM      	<= START_MM;
		TXDLYEN        	<= TXDLYEN;
		TXPHALIGN      	<= TXPHALIGN;
		TXPHALIGNEN		<= TXPHALIGNEN;
		TXPHINIT       	<= TXPHINIT;
		TXDLYSRESET    	<= 1'b1;
		RXDLYEN        	<= RXDLYEN;
		RXPHALIGN      	<= RXPHALIGN;
		RXPHALIGNEN		<= RXPHALIGNEN;
		RXPHINIT       	<= RXPHINIT;
		RXDLYSRESET    	<= RXDLYSRESET;
		end

`ifndef AUTO_MODE		
	   `set_txphinit :
	    begin
		state   		<= TXPHINITDONE ?  `set_txphalign : `check_txphinit;
		GT_RESET 		<= GT_RESET;
		BIST_CNT_RST 	<= 1'b0;
		BIST_CNT_EN 	<= 1'b1;
		PREAMBLE_EN 	<= PREAMBLE_EN ;
		BERT_EN 		<= BERT_EN;
		TLAST_EN 		<= TLAST_EN;
		BERT_SYNC 		<= BERT_SYNC;
		ERROR_COUNT_EN 	<= ERROR_COUNT_EN;
		DONE 			<= DONE;
		DATA_ERROR 		<= DATA_ERROR;
		START_MM      	<= START_MM;
		TXDLYEN        	<= TXDLYEN;
		TXPHALIGN      	<= TXPHALIGN;
		TXPHINIT       	<= 1'b1;
		TXDLYSRESET    	<= 1'b0;
		end 

	    `check_txphinit : 
	    begin
		state           <= TXPHINITDONE ? `set_txphalign : `check_txphinit;
		GT_RESET 		<= GT_RESET;
		BIST_CNT_RST 	<= 1'b1;
		BIST_CNT_EN 	<= 1'b0;
		PREAMBLE_EN 	<= PREAMBLE_EN ;
		BERT_EN 		<= BERT_EN;
		TLAST_EN 		<= TLAST_EN;
		BERT_SYNC 		<= BERT_SYNC;
		ERROR_COUNT_EN 	<= ERROR_COUNT_EN;
		DONE 			<= DONE;
		DATA_ERROR 		<= DATA_ERROR;
		START_MM      	<= START_MM;
		TXDLYEN        	<= TXDLYEN;
		TXPHALIGN      	<= TXPHALIGN;
		TXPHINIT       	<= 1'b1;
		TXDLYSRESET    	<= 1'b0;
	    end
`endif		
	    `set_txphalign :
	    begin
		state   		<= TXPHALIGNDONE ? `check_txphalign_pulse : `set_txphalign;
		GT_RESET 		<= GT_RESET;
		BIST_CNT_RST 	<= 1'b0;
		BIST_CNT_EN 	<= 1'b1;
		PREAMBLE_EN 	<= PREAMBLE_EN ;
		BERT_EN 		<= BERT_EN;
		TLAST_EN 		<= TLAST_EN;
		BERT_SYNC 		<= BERT_SYNC;
		ERROR_COUNT_EN 	<= ERROR_COUNT_EN;
		DONE 			<= DONE;
		DATA_ERROR 		<= DATA_ERROR;
		START_MM      	<= START_MM;
		TXDLYEN        	<= TXDLYEN;
		`ifndef AUTO_MODE
		TXPHALIGN 		<= 1'b1;
		`endif
		TXPHINIT       	<= 1'b0;
		TXDLYSRESET     <= 1'b0;
		
		RXDLYEN        	<= RXDLYEN;
		RXPHALIGN      	<= RXPHALIGN;
		RXPHALIGNEN		<= RXPHALIGNEN;
		RXPHINIT       	<= RXPHINIT;
		RXDLYSRESET    	<= RXDLYSRESET;
		end 

	    `check_txphalign_pulse : 
	    begin
		state           <= TXPHALIGNDONE ? `start_txdlyalign : `check_txphalign_pulse;
		GT_RESET 		<= GT_RESET;
		BIST_CNT_RST 	<= 1'b1;
		BIST_CNT_EN 	<= 1'b0;
		PREAMBLE_EN 	<= PREAMBLE_EN ;
		BERT_EN 		<= BERT_EN;
		TLAST_EN 		<= TLAST_EN;
		BERT_SYNC 		<= BERT_SYNC;
		ERROR_COUNT_EN 	<= ERROR_COUNT_EN;
		DONE 			<= DONE;
		DATA_ERROR 		<= DATA_ERROR;
		START_MM      	<= START_MM;
		TXDLYEN        	<= TXDLYEN;
		`ifndef AUTO_MODE
		TXPHALIGN 		<= 1'b1;
		`endif
		TXPHINIT       	<= 1'b0;
		TXDLYSRESET     <= 1'b0;
		RXDLYEN        	<= RXDLYEN;
		RXPHALIGN      	<= RXPHALIGN;
		RXPHALIGNEN		<= RXPHALIGNEN;
		RXPHINIT       	<= RXPHINIT;
		RXDLYSRESET    	<= RXDLYSRESET;
	    end
		
		`start_txdlyalign : 
	    begin
		state           <= TXPHALIGNDONE ? `check_txphalign_done: `start_txdlyalign;
		GT_RESET 		<= GT_RESET;
		BIST_CNT_RST 	<= 1'b1;
		BIST_CNT_EN 	<= 1'b0;
		PREAMBLE_EN 	<= PREAMBLE_EN ;
		BERT_EN 		<= BERT_EN;
		TLAST_EN 		<= TLAST_EN;
		BERT_SYNC 		<= BERT_SYNC;
		ERROR_COUNT_EN 	<= ERROR_COUNT_EN;
		DONE 			<= DONE;
		DATA_ERROR 		<= DATA_ERROR;
		START_MM      	<= START_MM;
		`ifndef AUTO_MODE
			TXDLYEN         <= 1'b1;
			TXPHALIGN       <= 1'b0;
		`endif
		TXPHINIT       	<= 1'b0;
		TXDLYSRESET     <= 1'b0;
		RXDLYEN        	<= RXDLYEN;
		RXPHALIGN      	<= RXPHALIGN;
		RXPHALIGNEN		<= RXPHALIGNEN;
		RXPHINIT       	<= RXPHINIT;
		RXDLYSRESET    	<= RXDLYSRESET;
	    end

	    `check_txphalign_done : 
	    begin
		state           <= TXPHALIGNDONE ? `check_txsync_done: `check_txphalign_done;
		GT_RESET 		<= GT_RESET;
		BIST_CNT_RST    <= 1'b1;
		BIST_CNT_EN     <= 1'b0;
		PREAMBLE_EN 	<= PREAMBLE_EN ;
		BERT_EN 		<= BERT_EN;
		TLAST_EN 		<= TLAST_EN;
		BERT_SYNC 		<= BERT_SYNC;
		ERROR_COUNT_EN 	<= ERROR_COUNT_EN;
		DONE 			<= DONE;
		DATA_ERROR 		<= DATA_ERROR;
		START_MM      	<= START_MM;
		TXDLYEN         <= TXDLYEN;
		TXPHALIGN       <= 1'b0;
		TXPHINIT      	<= 1'b0;
		TXDLYSRESET     <= 1'b0;
		RXDLYEN        	<= RXDLYEN;
		RXPHALIGN      	<= RXPHALIGN;
		RXPHALIGNEN		<= RXPHALIGNEN;
		RXPHINIT       	<= RXPHINIT;
		RXDLYSRESET    	<= RXDLYSRESET;
	    end

		`check_txsync_done : 
	    begin
		state           <= TXSYNCDONE ? `check_rxdlysrstdone: `check_txphalign_done;
		GT_RESET 		<= GT_RESET;
		BIST_CNT_RST    <= 1'b1;
		BIST_CNT_EN     <= 1'b0;
		PREAMBLE_EN 	<= PREAMBLE_EN ;
		BERT_EN 		<= BERT_EN;
		TLAST_EN 		<= TLAST_EN;
		BERT_SYNC 		<= BERT_SYNC;
		ERROR_COUNT_EN 	<= ERROR_COUNT_EN;
		DONE 			<= DONE;
		DATA_ERROR 		<= DATA_ERROR;
		START_MM      	<= START_MM;
		TXDLYEN         <= TXDLYEN;
		TXPHALIGN       <= 1'b0;
		TXPHINIT      	<= 1'b0;
		TXDLYSRESET     <= 1'b0;
		RXDLYEN        	<= RXDLYEN;
		RXPHALIGN      	<= RXPHALIGN;
		RXPHALIGNEN		<= RXPHALIGNEN;
		RXPHINIT       	<= RXPHINIT;
		RXDLYSRESET    	<= RXDLYSRESET;
	    end
		
		`check_rxdlysrstdone :
	    begin
		// `ifdef AUTO_MODE
		state   		<= RXDLYSRESETDONE_STICKY ? `set_rxphalign : `check_rxdlysrstdone;
		// `else
		// state   		<= RXDLYSRESETDONE_STICKY ? `set_rxphinit : `check_rxdlysrstdone;
		// `endif
		
		GT_RESET 		<= GT_RESET;
		BIST_CNT_RST 	<= 1'b0;
		BIST_CNT_EN 	<= 1'b1;
		PREAMBLE_EN 	<= PREAMBLE_EN ;
		BERT_EN 		<= BERT_EN;
		TLAST_EN 		<= TLAST_EN;
		BERT_SYNC 		<= BERT_SYNC;
		ERROR_COUNT_EN 	<= ERROR_COUNT_EN;
		DONE 			<= DONE;
		DATA_ERROR 		<= DATA_ERROR;
		START_MM      	<= START_MM;
		RXDLYEN        	<= RXDLYEN;
		RXPHALIGN      	<= RXPHALIGN;
		RXPHALIGNEN		<= RXPHALIGNEN;
		RXPHINIT       	<= RXPHINIT;
		RXDLYSRESET    	<= 1'b1;
		TXDLYEN        	<= TXDLYEN;
		TXPHALIGN      	<= TXPHALIGN;
		TXPHALIGNEN		<= TXPHALIGNEN;
		TXPHINIT       	<= TXPHINIT;
		TXDLYSRESET    	<= TXDLYSRESET;
		end
		`set_rxphalign :
	    begin
		state   		<= RXPHALIGNDONE ? `check_rxphalign_pulse: `set_rxphalign;
		GT_RESET 		<= GT_RESET;
		BIST_CNT_RST 	<= 1'b0;
		BIST_CNT_EN 	<= 1'b1;
		PREAMBLE_EN 	<= PREAMBLE_EN ;
		BERT_EN 		<= BERT_EN;
		TLAST_EN 		<= TLAST_EN;
		BERT_SYNC 		<= BERT_SYNC;
		ERROR_COUNT_EN 	<= ERROR_COUNT_EN;
		DONE 			<= DONE;
		DATA_ERROR 		<= DATA_ERROR;
		START_MM      	<= START_MM;
		RXDLYEN        	<= RXDLYEN;
		`ifndef AUTO_MODE
		RXPHALIGN 		<= 1'b1;
		`endif
		RXPHINIT       	<= 1'b0;
		RXDLYSRESET     <= 1'b0;
		
		TXDLYEN        	<= TXDLYEN;
		TXPHALIGN      	<= TXPHALIGN;
		TXPHALIGNEN		<= TXPHALIGNEN;
		TXPHINIT       	<= TXPHINIT;
		TXDLYSRESET    	<= TXDLYSRESET;
		end 

	    `check_rxphalign_pulse : 
	    begin
		state           <= RXPHALIGNDONE ? `start_rxdlyalign : `check_rxphalign_pulse;
		GT_RESET 		<= GT_RESET;
		BIST_CNT_RST 	<= 1'b1;
		BIST_CNT_EN 	<= 1'b0;
		PREAMBLE_EN 	<= PREAMBLE_EN ;
		BERT_EN 		<= BERT_EN;
		TLAST_EN 		<= TLAST_EN;
		BERT_SYNC 		<= BERT_SYNC;
		ERROR_COUNT_EN 	<= ERROR_COUNT_EN;
		DONE 			<= DONE;
		DATA_ERROR 		<= DATA_ERROR;
		START_MM      	<= START_MM;
		RXDLYEN        	<= RXDLYEN;
		`ifndef AUTO_MODE
		RXPHALIGN 		<= 1'b1;
		`endif
		RXPHINIT       	<= 1'b0;
		RXDLYSRESET     <= 1'b0;
		TXDLYEN        	<= TXDLYEN;
		TXPHALIGN      	<= TXPHALIGN;
		TXPHALIGNEN		<= TXPHALIGNEN;
		TXPHINIT       	<= TXPHINIT;
		TXDLYSRESET    	<= TXDLYSRESET;
	    end
		
		`start_rxdlyalign : 
	    begin
		state           <= RXPHALIGNDONE ? `check_rxphalign_done : `start_rxdlyalign;
		GT_RESET 		<= GT_RESET;
		BIST_CNT_RST 	<= 1'b1;
		BIST_CNT_EN 	<= 1'b0;
		PREAMBLE_EN 	<= PREAMBLE_EN ;
		BERT_EN 		<= BERT_EN;
		TLAST_EN 		<= TLAST_EN;
		BERT_SYNC 		<= BERT_SYNC;
		ERROR_COUNT_EN 	<= ERROR_COUNT_EN;
		DONE 			<= DONE;
		DATA_ERROR 		<= DATA_ERROR;
		START_MM      	<= START_MM;
		`ifndef AUTO_MODE
			RXDLYEN         <= 1'b1;
			RXPHALIGN       <= 1'b0;
		`endif
		RXPHINIT       	<= 1'b0;
		RXDLYSRESET     <= 1'b0;
		TXDLYEN        	<= TXDLYEN;
		TXPHALIGN      	<= TXPHALIGN;
		TXPHALIGNEN		<= TXPHALIGNEN;
		TXPHINIT       	<= TXPHINIT;
		TXDLYSRESET    	<= TXDLYSRESET;
	    end

	    `check_rxphalign_done : 
	    begin
		state           <= RXPHALIGNDONE ? `check_rxsync_done: `check_rxphalign_done;
		GT_RESET 		<= GT_RESET;
		BIST_CNT_RST    <= 1'b1;
		BIST_CNT_EN     <= 1'b0;
		PREAMBLE_EN 	<= PREAMBLE_EN ;
		BERT_EN 		<= BERT_EN;
		TLAST_EN 		<= TLAST_EN;
		BERT_SYNC 		<= BERT_SYNC;
		ERROR_COUNT_EN 	<= ERROR_COUNT_EN;
		DONE 			<= DONE;
		DATA_ERROR 		<= DATA_ERROR;
		START_MM      	<= START_MM;
		RXDLYEN         <= RXDLYEN;
		RXPHALIGN       <= 1'b0;
		RXPHINIT      	<= 1'b0;
		RXDLYSRESET     <= 1'b0;
		TXDLYEN        	<= TXDLYEN;
		TXPHALIGN      	<= TXPHALIGN;
		TXPHALIGNEN		<= TXPHALIGNEN;
		TXPHINIT       	<= TXPHINIT;
		TXDLYSRESET    	<= TXDLYSRESET;
	    end
		
		`check_rxsync_done : 
	    begin
		//state           <= (RXSYNCDONE & !RXPHALIGNERR & wa_complete_flg)? `start_preable: `check_rxphalign_done;
		state           <= (RXSYNCDONE & !RXPHALIGNERR & STATRXSTATUS & wa_complete_flg)? `start_preable: `check_rxphalign_done;
		//state           <= (RXSYNCDONE & !RXPHALIGNERR & STATRXSTATUS)? `start_preable: `check_rxphalign_done;
		//state           <= (RXSYNCDONE & !RXPHALIGNERR )? `start_preable: `check_rxphalign_done;
		GT_RESET 		<= GT_RESET;
		BIST_CNT_RST    <= 1'b1;
		BIST_CNT_EN     <= 1'b0;
		PREAMBLE_EN 	<= PREAMBLE_EN ;
		BERT_EN 		<= BERT_EN;
		TLAST_EN 		<= TLAST_EN;
		BERT_SYNC 		<= BERT_SYNC;
		ERROR_COUNT_EN 	<= ERROR_COUNT_EN;
		DONE 			<= DONE;
		DATA_ERROR 		<= DATA_ERROR;
		START_MM      	<= START_MM;
		RXDLYEN         <= RXDLYEN;
		RXPHALIGN       <= 1'b0;
		RXPHINIT      	<= 1'b0;
		RXDLYSRESET     <= 1'b0;
		TXDLYEN        	<= TXDLYEN;
		TXPHALIGN      	<= TXPHALIGN;
		TXPHALIGNEN		<= TXPHALIGNEN;
		TXPHINIT       	<= TXPHINIT;
		TXDLYSRESET    	<= TXDLYSRESET;
	    end	
		`start_preable : 
	    begin
		// start preable
		state 			<= (BIST_COUNT == (PREABLE_BYTE-1)) ? `start_data : `start_preable;
		GT_RESET 		<= GT_RESET;
		BIST_CNT_RST 	<= 1'b0;
		BIST_CNT_EN 	<= 1'b1;
		PREAMBLE_EN 	<= 1'b1 ;
		BERT_EN 		<= 1'b1;
		TLAST_EN 		<= TLAST_EN;
		BERT_SYNC 		<= BERT_SYNC;
		ERROR_COUNT_EN 	<= ERROR_COUNT_EN;
		DONE 			<= DONE;
		DATA_ERROR 		<= DATA_ERROR;
		START_MM      	<= START_MM;
		TXDLYEN        	<= TXDLYEN;
		TXPHALIGN      	<= TXPHALIGN;
		TXPHALIGNEN		<= TXPHALIGNEN;
		TXPHINIT       	<= TXPHINIT;
		TXDLYSRESET    	<= TXDLYSRESET;
		RXDLYEN        	<= RXDLYEN;
		RXPHALIGN      	<= RXPHALIGN;
		RXPHALIGNEN		<= RXPHALIGNEN;
		RXPHINIT       	<= RXPHINIT;
		RXDLYSRESET    	<= RXDLYSRESET;
	    end
		
	    `start_data : 
	    begin
		// start lfsr data and hold here till rxdata 
		state 			<= (BIST_COUNT == 12'd400) ? `run_compare : `start_data;
		GT_RESET 		<= GT_RESET;
		BIST_CNT_RST 	<= 1'b0;
		BIST_CNT_EN 	<= 1'b1;
		PREAMBLE_EN 	<= 1'b0 ;
		BERT_EN 		<= 1'b1;
		TLAST_EN 		<= TLAST_EN;
		BERT_SYNC 		<= BERT_SYNC;
		ERROR_COUNT_EN 	<= ERROR_COUNT_EN;
		DONE 			<= DONE;
		DATA_ERROR 		<= DATA_ERROR;
		START_MM      	<= START_MM;
		TXDLYEN        	<= TXDLYEN;
		TXPHALIGN      	<= TXPHALIGN;
		TXPHALIGNEN		<= TXPHALIGNEN;
		TXPHINIT       	<= TXPHINIT;
		TXDLYSRESET    	<= TXDLYSRESET;
		RXDLYEN        	<= RXDLYEN;
		RXPHALIGN      	<= RXPHALIGN;
		RXPHALIGNEN		<= RXPHALIGNEN;
		RXPHINIT       	<= RXPHINIT;
		RXDLYSRESET    	<= RXDLYSRESET;
	    end

	    `run_compare : 
	    begin
		// enable expect data and comparator - run data till done
		// state 		<= (BIST_COUNT == 12'd3000) ? `start_tlast : `run_compare;
		
//		if (BIST_COUNT >= 12'd500) begin
		if (BIST_COUNT >= 12'd3000) begin
			state 		<= `start_tlast;
			BIST_CNT_RST 	<= 1'b1;
			BIST_CNT_EN 	<= 1'b0;
		end else begin
			state 		<= `run_compare;
			BIST_CNT_RST 	<= 1'b0;
			BIST_CNT_EN 	<= 1'b1;
		
		end
		GT_RESET 		<= GT_RESET;
		// BIST_CNT_RST 	<= 1'b0;
		// BIST_CNT_EN 	<= 1'b1;
		PREAMBLE_EN 	<= 1'b0;
		BERT_EN 		<= 1'b1;
		TLAST_EN 		<= TLAST_EN;
		BERT_SYNC 		<= (BIST_COUNT > 450 );
		ERROR_COUNT_EN 	<= (BIST_COUNT > 600 );
		DONE 			<= 1'b0;
		DATA_ERROR 		<= DATA_ERROR;
		START_MM        <= 1'b0;
		TXDLYEN        	<= TXDLYEN;
		TXPHALIGN      	<= TXPHALIGN;
		TXPHALIGNEN		<= TXPHALIGNEN;
		TXPHINIT       	<= TXPHINIT;
		TXDLYSRESET    	<= TXDLYSRESET;
		RXDLYEN        	<= RXDLYEN;
		RXPHALIGN      	<= RXPHALIGN;
		RXPHALIGNEN		<= RXPHALIGNEN;
		RXPHINIT       	<= RXPHINIT;
		RXDLYSRESET    	<= RXDLYSRESET;
	    end
		
		`start_tlast : 
	    begin
		state 			<= `dummy_wait_last_packet;
		GT_RESET 		<= GT_RESET;
		BIST_CNT_RST 	<= 1'b0;
		BIST_CNT_EN 	<= 1'b1;
		PREAMBLE_EN 	<= 1'b0;
		BERT_EN 		<= 1'b1;
		TLAST_EN 		<= 1'b1;
		BERT_SYNC 		<= BERT_SYNC;
		ERROR_COUNT_EN 	<= 1'b0;
		DONE 			<= 1'b0;
		DATA_ERROR 		<= DATA_ERROR;
		START_MM        <= 1'b0;
		TXDLYEN        	<= TXDLYEN;
		TXPHALIGN      	<= TXPHALIGN;
		TXPHALIGNEN		<= TXPHALIGNEN;
		TXPHINIT       	<= TXPHINIT;
		TXDLYSRESET    	<= TXDLYSRESET;
		RXDLYEN        	<= RXDLYEN;
		RXPHALIGN      	<= RXPHALIGN;
		RXPHALIGNEN		<= RXPHALIGNEN;
		RXPHINIT       	<= RXPHINIT;
		RXDLYSRESET    	<= RXDLYSRESET;
	    end
		
		`dummy_wait_last_packet : 
	    begin
		state 			<= (BIST_COUNT >= 300) ? `check_compare : `dummy_wait_last_packet;
		GT_RESET 		<= GT_RESET;
		BIST_CNT_RST 	<= 1'b0;
		BIST_CNT_EN 	<= 1'b1;
		PREAMBLE_EN 	<= 1'b0;
		
		`ifdef ADD_FCS
		BERT_EN 		<= (BIST_COUNT >= 'h1) ? 1'b0 : 1'b1;
		`else
		BERT_EN 		<= (BIST_COUNT >= 'h3) ? 1'b0 : 1'b1;
		`endif
		
		TLAST_EN 		<= 1'b0;
		BERT_SYNC 		<= BERT_SYNC;
		ERROR_COUNT_EN 	<= 1'b0;
		DONE 			<= 1'b0;
		DATA_ERROR 		<= DATA_ERROR;
		START_MM        <= 1'b0;
		TXDLYEN        	<= TXDLYEN;
		TXPHALIGN      	<= TXPHALIGN;
		TXPHALIGNEN		<= TXPHALIGNEN;
		TXPHINIT       	<= TXPHINIT;
		TXDLYSRESET    	<= TXDLYSRESET;
		RXDLYEN        	<= RXDLYEN;
		RXPHALIGN      	<= RXPHALIGN;
		RXPHALIGNEN		<= RXPHALIGNEN;
		RXPHINIT       	<= RXPHINIT;
		RXDLYSRESET    	<= RXDLYSRESET;
	    end
		
	    `check_compare : 
	    begin
		// enable expect data and comparator - run data till done
		state 			<= (BERT_PASS && BERT_DET_OUT && !STATRXPKTERR_STICKY && STATRXSTATUS_STICKY && !STATTXPKTERR_STICKY && !STATTXBADFCS_STICKY && !STATTXFCSERR_STICKY && !STATRXBADFCS_STICKY && !STATRXFCSERR_STICKY) ? `done : `fail_data;
		GT_RESET 		<= GT_RESET;
		BIST_CNT_RST 	<= 1'b0;
		BIST_CNT_EN 	<= 1'b1;
		PREAMBLE_EN 	<= 1'b0;
		BERT_EN 		<= 1'b0;
		TLAST_EN 		<= 1'b0;
		BERT_SYNC 		<= BERT_SYNC;
		ERROR_COUNT_EN 	<= 1'b0;
		DONE 			<= 1'b0;
		DATA_ERROR      <= DATA_ERROR;
		START_MM        <= 1'b0;
		TXDLYEN        	<= TXDLYEN;
		TXPHALIGN      	<= TXPHALIGN;
		TXPHALIGNEN		<= TXPHALIGNEN;
		TXPHINIT       	<= TXPHINIT;
		TXDLYSRESET    	<= TXDLYSRESET;
		RXDLYEN        	<= RXDLYEN;
		RXPHALIGN      	<= RXPHALIGN;
		RXPHALIGNEN		<= RXPHALIGNEN;
		RXPHINIT       	<= RXPHINIT;
		RXDLYSRESET    	<= RXDLYSRESET;
		packet_count    <= packet_count + 1;
		$display("Packet count is :%d, state: %d", packet_count, state);
	    end

	    `done : 
	    begin
		// done assert reset and head to init
		state           <= (packet_count >= NUM_OF_PACKETS)? `done : `start_preable;
		//state           <= `done;
		GT_RESET 		<= GT_RESET;
		BIST_CNT_RST 	<= 1'b1;
		BIST_CNT_EN 	<= 1'b0;
		PREAMBLE_EN 	<= 1'b0;
		BERT_EN 		<= 1'b0;
		TLAST_EN 		<= 1'b0;
		BERT_SYNC 		<= 1'b0;
		ERROR_COUNT_EN 	<= 1'b0;
		DONE 			<= 1'b1;
		DATA_ERROR 		<= 1'b0;
		START_MM        <= 1'b0;
		TXDLYEN        	<= TXDLYEN;
		TXPHALIGN      	<= TXPHALIGN;
		TXPHALIGNEN		<= TXPHALIGNEN;
		TXPHINIT       	<= TXPHINIT;
		TXDLYSRESET    	<= TXDLYSRESET;
		RXDLYEN        	<= RXDLYEN;
		RXPHALIGN      	<= RXPHALIGN;
		RXPHALIGNEN		<= RXPHALIGNEN;
		RXPHINIT       	<= RXPHINIT;
		RXDLYSRESET    	<= RXDLYSRESET;
		$display("Test PASSED");		   
	    end
	   `fail_data: 
	    begin
		// alignment failed
		state           <= (packet_count >= NUM_OF_PACKETS)? `fail_data : `start_preable;
		//state           <= `fail_data;
		GT_RESET 		<= 1'b0;
		BIST_CNT_RST 	<= 1'b1;
		BIST_CNT_EN 	<= 1'b0;
		PREAMBLE_EN 	<= 1'b0;
		BERT_EN 		<= 1'b0;
		TLAST_EN 		<= 1'b0;
		BERT_SYNC 		<= 1'b0;
		ERROR_COUNT_EN 	<= 1'b0;
		DONE 			<= 1'b1;
		DATA_ERROR 		<= 1'b1;
		START_MM        <= 1'b0;
		TXDLYEN        	<= TXDLYEN;
		TXPHALIGN      	<= TXPHALIGN;
		TXPHALIGNEN		<= TXPHALIGNEN;
		TXPHINIT       	<= TXPHINIT;
		TXDLYSRESET    	<= TXDLYSRESET;
		RXDLYEN        	<= RXDLYEN;
		RXPHALIGN      	<= RXPHALIGN;
		RXPHALIGNEN		<= RXPHALIGNEN;
		RXPHINIT       	<= RXPHINIT;
		RXDLYSRESET    	<= RXDLYSRESET;
		$display("Test FAILED; BERT_PASS:%d BERT_DET_OUT:%d STATRXPKTERR_STICKY:%d STATRXSTATUS_STICKY:%d STATTXPKTERR_STICKY:%d STATTXBADFCS_STICKY:%d STATTXFCSERR_STICKY:%d STATRXBADFCS_STICKY:%d STATRXFCSERR_STICKY:%d", BERT_PASS, BERT_DET_OUT, STATRXPKTERR_STICKY, STATRXSTATUS_STICKY, STATTXPKTERR_STICKY, STATTXBADFCS_STICKY, STATTXFCSERR_STICKY, STATRXBADFCS_STICKY, STATRXFCSERR_STICKY);
		end 
	    
	    default : 
	    begin
		// done assert reset and head to init
		state           <= `init;
		GT_RESET 		<= GT_RESET;
		BIST_CNT_RST 	<= 1'b0;
		BIST_CNT_EN 	<= 1'b0;
		PREAMBLE_EN 	<= 1'b0;
		BERT_EN 		<= 1'b0;
		TLAST_EN 		<= 1'b0;
		BERT_SYNC 		<= 1'b0;
		ERROR_COUNT_EN 	<= 1'b0;
		DONE 			<= 1'b0;
		DATA_ERROR 		<= 1'b1;
		START_MM        <= 1'b0;
		TXDLYEN         <= 1'b0;
		TXPHALIGN       <= 1'b0;
		TXPHINIT       	<= 1'b0;
		TXDLYSRESET     <= 1'b0;
	    end

    endcase
  end
end
endmodule
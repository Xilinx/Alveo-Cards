//	Copyright ? 2013.	GSI Technology
//	apps@gsitechnology.com
//  v 1.00  04/29/13    Jeff Daugherty  1) Created 
//


`timescale 1ps / 1ps

module G82582DT20E#(
		    parameter SPEED = 550,
                              A_bits = 14
)
  (SA, D, Q,  nBW, K, nK, nR, nW, CQ, nCQ, QVLD, TMS, TDI, TDO, TCK, nDoff);
   input [21:0] 	      SA; 		// address
   input 		      K;		// clock
   input 		      nK;		// clock
   input [1:0] 		      nBW;		// bank 1 write enable
   input 		      nR; 		// read enable
   input 		      nW; 		// write enable
   input 		      nDoff; 		// write enable
   output 		      CQ; 		// write enable
   output 		      nCQ; 		// write enable
   output 		      QVLD; 		// write enable
   input [17:0] 	      D;		// data in
   output[17:0] 	      Q;		// data out
   input 		      TMS;		// Scan Test Mode Select
   input 		      TDI;		// Scan Test Data In
   output 		      TDO;		// Scan Test Data Out
   input 		      TCK;		// Scan Test Clock

//---------------------------------------------------------------
// 	Scan Registers 
//---------------------------------------------------------------
   wire [3:0]	tBW;
   assign 	tBW = {1'b1, 1'b1, nBW};
   	
   parameter 	tCHQV     =  450;
   parameter 	tCHQX     = -450;
   parameter 	tCHQV_off =  2750;
   parameter 	tCHQX_off =  0;
   parameter 	tCQHQV    =  SPEED==400 ?  200 :  150;
   // parameter 	tCQHQV    =  0;
   parameter 	tCQHQX    =  SPEED==400 ? -200 : -150;
   // parameter 	tCQHQX    =  0;
   parameter    mem_size  =  A_bits > 1 ? A_bits : 24;
   parameter    mem_style =  A_bits > 1 ? "REDUCED" : "NORMAL";
   
   initial begin
      if (SPEED==550 | SPEED==500| SPEED==450 | SPEED==400 ) begin
	 //do nothing
      end
      else begin
	 $display ("INVALID SPEED option, allowable SPEEDs options are 550, 500, 450, 400. SPEED = %d", SPEED);
	 $stop;
      end
   end
   core_b4_plus #( .A_size(22),
		   .A_bits(A_bits),
		   .DQ_width(18),
		   .RL(25),
		   .ECC(0),
		   .HighZ(18'bZZZZZZZZZZZZZZZZZZ),
		   .bank_size(2**mem_size),
		   .mem_style(mem_style),
		   .mem_size(mem_size),
		   .tCHQV(tCHQV),
    		   .tCHQX(tCHQX),
    		   .tCQHQV(tCQHQV),
    		   .tCQHQX(tCQHQX),
    		   .tCHQV_off(tCHQV_off),
    		   .tCHQX_off(tCHQX_off))
     core_b4_plus( .A     (SA),
		   .D     (D),
		   .Q     (Q),
		   .tBW   (tBW),
		   .K     (K),
		   .nK    (nK),
		   .nR    (nR),
		   .nW    (nW),
		   .nDoff (nDoff),
		   .CQ    (CQ),
		   .nCQ   (nCQ),
		   .QVLD  (QVLD),
		   .TCK   (TCK));

endmodule

// ? 2003.       GSI TECHNOLOGY
//                                              Jeff Daugherty
//                                              apps@gsitechnology.com
//      FileName: core_B4_PLUS.vhd
//
//Version: 1.3
//
//Revision History:
//
//  02/03/2010   1.1   1) Updated core to be a stand alone module
//  06/04/2010   1.2   1) Fixed clock routines to coorectly sense K high and nK rising edge
//  01/13/2012   1.3   1) corrected incorrect reference to Qi[0], should be just Qi
//  10/18/2016   1.4   1) Added Read Latency of 3 cyles to model
//
`timescale 1ps / 1ps
module core_b4_plus #(
   parameter   A_size    = 21,
	       A_bits    = 21,
	       DQ_width  = 9,
	       RL        = 20,
	       ECC       = 0,
	       HighZ     = 36'bZ,
	       bank_size = 2,
	       mem_style = "NORMAL ",
	       mem_size  = 2,
               tCHQV     = 450,
   	       tCHQX     = -450,
    	       tCQHQV    = 400,
    	       tCQHQX    = -400,
            //  tCQHQV    = 0,
    	      //  tCQHQX    = 0,
    	       tCHQV_off = 2000,
    	       tCHQX_off = 0.0,
    	       tS	 = 500,
    	       tH	 = 500
		      )
  (
   input [A_size-1:0] A,         // Address
   input 	      K,	 // Clock
   input 	      nK,	 // Clock
   input [3:0] 	      tBW,	 // Write enable
   input 	      nR,	 // Read enable
   input 	      nW,	 // Write enable
   input 	      nDoff,	 // DLL Enable
   output 	      CQ,	 // Echo Clock
   output 	      nCQ,	 // Echo Clock
   output 	      QVLD,	 // QVLD
   input [DQ_width-1:0] D,	 // data in
   output[DQ_width-1:0] Q,	 // data out
   input 		TCK	 // Scan Test Clock
   );

   wire 		DLL;

   reg [3:0] 		bw_i[0:9];
   reg [DQ_width-1:0] 	memory_core[0:bank_size], Qi, Qi_o, Di[0:9];
   reg [A_size+1:0] 	address_core[0:bank_size], wA_D[0:9], rA_D[0:9];
   reg [mem_size:0] 	address_used=1'b0, addr_t, address_index;
   reg [9:0] 		read_pos;

   reg 			W, we[0:3], bw_err[0:3];
   reg 			R, re=0, re1, Q_switch;
   reg 			K_i, CQ_i=1'b0, nCQ_i=1'b1;
   reg [2:0]            counter_init_cq = 3'b0;
   reg [4*8:0] 		Read_Command;
   reg [5*8:0] 		Write_Command;
   real 		K_Time=1.0, K_Time0, K_Time1, nK_Time=1.0, nK_Time0, nK_Time1, CHQV=0.1, CHQX=0.1;
   real 		CHCQon=1.0, CHCQoff=1.0;
   integer 		JTAG_Flag=0, TCK_Count, delay, latency, i;
   integer 		K_count=0, nK_count=0;

   //assign bw_i[0] = ~tBW;
   //assign Di[0]   = D;
   assign 		DLL     = nDoff;
   assign 		CQ      = CQ_i;
   assign 		nCQ     = nCQ_i;
   assign 		QVLD    = DLL==1 ? re : 1'b0;
 //assign 		Q       = Q_switch==1 ? Qi_o : HighZ;
   assign 		Q       =               Qi_o;

   // purpose: Main Flow
   // inputs : 
   // outputs: 
   always @ (posedge(K))
     begin : K_Flow
	CQ_Clock(1);
	CHQV <= DLL==1 ? tCHQV : tCHQV_off;
	CHQX <= DLL==1 ? tCHQX : tCHQX_off;
	CHCQon  <= 2*K_Time + (CHQV - tCQHQV);
	CHCQoff <= 2*nK_Time + (CHQX - tCQHQX);
	K_i_Clock(1);
     end

   always @ (posedge(nK))
     begin : nK_Flow
	CQ_Clock(0);
	K_i_Clock(0);
     end

   always @ (posedge K_i) begin
      if (counter_init_cq == 3'b101)
   	counter_init_cq <= counter_init_cq;
      else
   	counter_init_cq <= counter_init_cq + 3'b001;
   end

   always @ (K_i)
     begin : K_i_Flow
	Shift;
	bw_i[0] <= ~tBW;
	Di[0]   <= D;
	if (K_i) begin
	   State;
	   Write_Array("RISE");
	end
	else Write_Array("FALL");
        Read_Array;
     end

   always @ (posedge(CQ_i) , posedge(nCQ_i))
     begin : Q_setting
	Q_set;
     end

   // purpose: Generate K_i signals
   // inputs : K, nK
   // outputs: K_i
   task K_i_Clock;
      input UP_D;
      begin
	 if (UP_D)  K_i <= 1'b1;
	 if (~UP_D) K_i <= 1'b0;
      end
   endtask // K_i_clock

   // purpose: Determine if TCK is running
   // inputs : TCK
   // outputs: JTAG_Flag
   always @ (posedge(TCK))
     begin : TCK_Flow
	if (TCK_Count>=2)JTAG_Flag <= 1;
	if (TCK_Count<2) TCK_Count = TCK_Count + 1;
     end

   // purpose: Find time since last K clock edge
   // inputs : K
   // outputs: K_time
   always @ (posedge(K))
     begin : K_state_time
	if (nK_count < 4) begin
	   K_Time1 <= K_Time0;
	   K_Time0 <= $realtime;
	   K_Time <= K_Time0 - K_Time1;
	end
	else begin
	   K_Time <= 1.0;
	   K_count <= K_count + 1;
	end
     end
   
   // purpose: Find time since last nK clock edge
   // inputs : nK
   // outputs: nK_time
   always @ (posedge(nK))
     begin : nK_state_time
	if (nK_count < 4) begin
	   nK_Time1 <= nK_Time0;
	   nK_Time0 <= $realtime;
	   nK_Time <= nK_Time0 - nK_Time1;
	end
	else begin
	   nK_Time <= 1.0;
	   nK_count <= nK_count + 1;
	end
     end
   
   function address_match;
     // check if the requested write address has been accessed when
     // using reduced memeory array.
      input [A_size+1:0] temp_addr;
      begin : check
	 address_match = 0;
	 for (address_index=0; address_index<address_used; address_index=address_index+1) begin
	    if (address_core[address_index] == temp_addr) begin
	       address_match = 1;
	       disable check;
	    end
	 end
      end
   endfunction // addr_check
   
   // purpose: shift address arrays
   // inputs : wA_D, rA_D, read_pos
   // outputs: wA_D, rA_D, read_pos
   task Shift;
      begin  // shift
	 for (i=9 ; i>=1 ; i=i-1) begin
            wA_D[i]     <= wA_D[i-1];
            rA_D[i]     <= rA_D[i-1];
            read_pos[i] <= read_pos[i-1];
	    Di[i]       <= Di[i-1];
	    bw_i[i]     <= bw_i[i-1];
	 end
      end
   endtask // shift


   // purpose: Generate CQ signals
   // inputs : JTAG_Flag, K, nK, tCHCQ
   // outputs: CQ_i, nCQ_i
   task CQ_Clock;
      input UP_D;
      begin
	 if (JTAG_Flag==0 & (counter_init_cq > 3'b100)) begin
	    if (UP_D) begin
	       CQ_i  <= #CHCQon 1'b1;
	       nCQ_i <= #CHCQon 1'b0;
	    end
	    if (~UP_D) begin
	       nCQ_i <= #CHCQon 1'b1;
	       CQ_i  <= #CHCQon 1'b0;
	    end
	 end
	 else begin
            CQ_i  <= 1'bZ;
            nCQ_i <= 1'bZ;
	 end
      end
   endtask // CQ_clock

   // purpose: Determine Read / Write / NOOP State
   // inputs : W, nW, R, nR, lA_B
   // outputs: Read_Command, Write_Command, Read_Pos, wA_D, rA_D, we
   task State;
      begin
	 if(nR==0 && R==0) begin
            Read_Command <= "READ";
            read_pos[0]  <= 1'b1;
            rA_D[3]      <= {A , 2'b00};
            rA_D[2]      <= {A , 2'b01};
            rA_D[1]      <= {A , 2'b10};
            rA_D[0]      <= {A , 2'b11};
	 end
	 else begin
            Read_Command <= "NOOP";
            if (R==0) begin
               read_pos[0] <= 1'b0;
	    end
	 end
	 if (nW==0 && W==0) begin
            we[0]         <= 1'b1;
            Write_Command <= "Write";
            wA_D[3]       <= {A , 2'b00};
            wA_D[2]       <= {A , 2'b01};
            wA_D[1]       <= {A , 2'b10};
            wA_D[0]       <= {A , 2'b11};
	 end
	 else begin
            if (W==0) begin
               we[0] <= 1'b0;
            end
            Write_Command <= "NO-OP";
	 end
	 if (nW==0 && W==1) begin
            W <= 1'b0;
	 end
	 else begin
            W <= ~nW;
	 end
	 if (nR==0 && R==1) begin
            R <= 1'b0;
	 end
	 else begin
            R <= ~nR;
	 end
      end
   endtask // State

   // purpose: Set Q_switch, re, Qi_o
   // inputs : delay, read_pos, Qi
   // outputs: Q_switch, Qi_o, re
   task Q_set;
      begin
	 if (read_pos[delay - 1]==1) re <= #tCQHQV 1'b1;
	 if (read_pos[delay - 1]==0) re <= #tCQHQV 1'b0;
	 if (read_pos[delay]==1) begin
            Q_switch <= #(tCQHQV) 1'b1;
            Q_switch <= #(K_Time/2+tCQHQX) 1'b0;
	 end
	 if (read_pos[delay]==0) begin
            Q_switch <= #(K_Time/2+tCQHQX) 1'b0;
	 end
	 Qi_o <= Qi;
      end
   endtask // Q_set

   // purpose: set Qi
   // inputs : read_pos
   // outputs: Qi
   task Read_Array;
      begin
	 if (address_match(rA_D[latency]) & mem_style == "REDUCED")	begin
	    Qi = {memory_core[address_index]};
	 end
	 else if (mem_style == "NORMAL") begin
	    Qi = {memory_core[rA_D[latency]]};
	 end
	 else begin
	    Qi = {DQ_width{1'bX}};
	 end
	 if (DLL==1) begin
	    if (RL==20) begin
               latency=6;
	       delay=4;
	    end
	    else if(RL==25) begin
               latency=7;
	       delay=5;
	    end
	    else if(RL==30) begin
               latency=8;
	       delay=6;
	    end
	 end
	 else begin
              latency=4;
	      delay=2;
	 end
      end
   endtask // Read_Array

   // purpose: Write data to Array
   // inputs : we, bw_i, W
   // outputs: we1
   task Write_Array;
      input [4*8:0] FLAG;
      begin
	 we[3] <= we[2];
	 we[2] <= we[1];
	 we[1] <= we[0];
	 if (we[3]==1)  begin
	    if (mem_style == "REDUCED") begin
	       if (address_match(wA_D[6])) begin
		  address_core[address_index] = wA_D[6];
		  addr_t                      = address_index;
	       end
	       else begin
		  if (address_used == 1<<A_bits) begin
		     $display ("At time %t A Memory overflow occurred.\n",$time);
		     $display ("Increase the size of A_bits to increase memory size\n");
		     $stop;
		  end
		  address_core[address_used] <= wA_D[6];
		  addr_t                      = address_used;
		  address_used               <= address_used + 1;
	       end
	    end // if (mem_style == "REDUCED")
	    else begin
	       addr_t = wA_D[6];
	    end // else: !if(mem_style == "REDUCED")
	    if (DQ_width== 8) begin
               if (bw_i[1][0]==1) memory_core[addr_t][3:0]  <= Di[1][3:0];
               if (bw_i[1][1]==1) memory_core[addr_t][7:4]  <= Di[1][7:4];
	    end
	    if (DQ_width== 9) begin
               if (bw_i[1][0]==1) memory_core[addr_t][8:0]  <= Di[1][8:0];
	    end
	    if (DQ_width==36 || DQ_width== 18) begin
               if (bw_i[1][0]==1) memory_core[addr_t][8:0]  <= Di[1][8:0];
               if (bw_i[1][1]==1) memory_core[addr_t][17:9] <= Di[1][17:9];
	    end
            if (DQ_width==36) begin
               if (bw_i[1][2]==1) memory_core[addr_t][26:18] <= Di[1][26:18];
               if (bw_i[1][3]==1) memory_core[addr_t][35:27] <= Di[1][35:27];
            end
	 end // if (we1==1)
      end
   endtask // Write_Array
endmodule

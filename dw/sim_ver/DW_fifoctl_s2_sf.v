////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 1997 - 2018 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Rajeev Huralikoppi       11/10/97
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: 178cc06a
// DesignWare_release: O-2018.06-DWBB_201806.3
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT:  Synchronous, dual clock FIFO Controller with Static Flags
//           static programmable almost empty and almost full flags
//
//           This FIFO controller designed to interface to synchronous
//           true dual port RAMs.
//
//           NOTE that Clock Domain Crossing (CDC) random missampling is
//           enabled when the Verilog macro, DW_MODEL_MISSAMPLES, is defined.
//
//		Parameters:	Valid Values
//		==========	============
//		depth		[ 4 to 16777216 ]
//		push_ae_lvl	[ 1 to depth-1 ]
//		push_af_lvl	[ 1 to depth-1 ]
//		pop_ae_lvl	[ 1 to depth-1 ]
//		pop_af_lvl	[ 1 to depth-1 ]
//		err_mode	[ 0 = sticky error flag,
//				  1 = dynamic error flag ]
//		push_sync	[ 1 = single synchronized,
//				  2 = double synchronized,
//				  3 = triple synchronized ]
//		pop_sync	[ 1 = single synchronized,
//				  2 = double synchronized,
//				  3 = triple synchronized ]
//		rst_mode	[ 0 = Asynchronous reset
//				  1 = Synchronous reset ]
//		tst_mode	[ 0 = test input not connected
//				  1 = lock-up latches inserted for scan test ]
//		
//		Input Ports:	Size	Description
//		===========	====	===========
//		clk_push	1 bit	Push I/F Input Clock
//		clk_pop		1 bit	Pop I/F Input Clock
//		rst_n		1 bit	Active Low Reset
//		push_req_n	1 bit	Active Low Push Request
//		pop_req_n	1 bit	Active Low Pop Request
//
//		Output Ports	Size	Description
//		============	====	===========
//		we_n		1 bit	Active low Write Enable (to RAM)
//		push_empty	1 bit	Push I/F Empty Flag
//		push_ae		1 bit	Push I/F Almost Empty Flag
//		push_hf		1 bit	Push I/F Half Full Flag
//		push_af		1 bit	Push I/F Almost Full Flag
//		push_full	1 bit	Push I/F Full Flag
//		push_error	1 bit	Push I/F Error Flag
//		pop_empty	1 bit	Pop I/F Empty Flag
//		pop_ae		1 bit	Pop I/F Almost Empty Flag
//		pop_hf		1 bit	Pop I/F Half Full Flag
//		pop_af		1 bit	Pop I/F Almost Full Flag
//		pop_full	1 bit	Pop I/F Full Flag
//		pop_error	1 bit	Pop I/F Error Flag
//		wr_addr		N bits	Write Address (to RAM)
//		rd_addr		N bits	Read Address (to RAM)
//		push_word_count M bits  Words in FIFO (push IF perception)
//		pop_word_count  M bits  Words in FIFO (push IF perception)
//              test            1 bit   Test Input (controls lock-up latches)
//
//		  Note:	the value of N for wr_addr and rd_addr is
//			determined from the parameter, depth.  The
//			value of N is equal to:
//				ceil( log2( depth ) )
//		
//		  Note:	the value of M for push_word_count and pop_word_count
//			is determined from the parameter, depth.  The
//			value of M is equal to:
//				ceil( log2( depth+1 ) )
//
//
//
// MODIFIED:  11/11/1999 RPH      Rewrote for STAR 92843 fix
//
//             11/29/01     RJK   Fixed size mismatch related to
//                                STAR 129582 (but fixed with 131712)
//
//             12/3/2002    RJK   Added word count outputs
//
//             3/1/2016     RJK   Updated for compatibility with VCS NLP
//
//             10/9/2017    RJK   Rewritten to allow missampling behavior
//                                to be modeled.  If the Verilog macro,
//                                DW_MODEL_MISSAMPLES is defined, then the
//                                missampling will be modeled for STAR
//                                9001026675.
//
//-----------------------------------------------------------------------------

module DW_fifoctl_s2_sf (
			clk_push, clk_pop,
			rst_n,
			push_req_n, pop_req_n, we_n,
                        push_empty, push_ae, push_hf, push_af, push_full, push_error,
			pop_empty, pop_ae, pop_hf, pop_af, pop_full, pop_error,
			wr_addr, rd_addr, push_word_count, pop_word_count, test);

parameter integer depth = 8;
parameter integer push_ae_lvl = 2;
parameter integer push_af_lvl = 2;
parameter integer pop_ae_lvl = 2;
parameter integer pop_af_lvl = 2;
parameter integer err_mode = 0;
parameter integer push_sync = 2;
parameter integer pop_sync = 2;
parameter integer rst_mode = 0;
parameter integer tst_mode = 0;
   
localparam O1O10Il0 = ((depth>65536)?((depth>1048576)?((depth>4194304)?((depth>8388608)?24:23):((depth>2097152)?22:21)):((depth>262144)?((depth>524288)?20:19):((depth>131072)?18:17))):((depth>256)?((depth>4096)?((depth>16384)?((depth>32768)?16:15):((depth>8192)?14:13)):((depth>1024)?((depth>2048)?12:11):((depth>512)?10:9))):((depth>16)?((depth>64)?((depth>128)?8:7):((depth>32)?6:5)):((depth>4)?((depth>8)?4:3):((depth>2)?2:1)))));
localparam O1O00l1O = (depth<16777216)?((depth+1>65536)?((depth+1>1048576)?((depth+1>4194304)?((depth+1>8388608)?24:23):((depth+1>2097152)?22:21)):((depth+1>262144)?((depth+1>524288)?20:19):((depth+1>131072)?18:17))):((depth+1>256)?((depth+1>4096)?((depth+1>16384)?((depth+1>32768)?16:15):((depth+1>8192)?14:13)):((depth+1>1024)?((depth+1>2048)?12:11):((depth+1>512)?10:9))):((depth+1>16)?((depth+1>64)?((depth+1>128)?8:7):((depth+1>32)?6:5)):((depth+1>4)?((depth+1>8)?4:3):((depth+1>2)?2:1))))):25;

   input                       clk_push, clk_pop;
   input                       rst_n;
   input                       push_req_n, pop_req_n;
   output 		       we_n, push_empty, push_ae, push_hf, 
			       push_af, push_full;
   output 		       push_error, pop_empty, pop_ae, pop_hf, pop_af, 
			       pop_full, pop_error;
   output [O1O10Il0-1 : 0]  wr_addr, rd_addr;
   output [O1O00l1O-1 : 0] push_word_count, pop_word_count;
   input                       test;

// synopsys translate_off

// Missampling errors modeled with random insertion of 0 to 1 clock cycle
// only when the Verilog macro, DW_MODEL_MISSAMPLES, is defined
localparam O0OI0OIO = 1;

localparam O01O1I1I  = (O1O10Il0 != O1O00l1O) ? (depth * 2) :
                                                         (depth+2-(depth % 2));
localparam O0O10I10 = (O1O10Il0 != O1O00l1O) ? 0 : ((1 << O1O10Il0) - O01O1I1I)/2;
localparam [O1O00l1O-1:0] O011l0OI = O0O10I10 ^ (O0O10I10 >> 1);
localparam ll00lIOO = 0;

localparam [O1O00l1O-1:0] II0I1O00 = {O1O00l1O{1'b0}};
localparam [O1O00l1O-1:0] I0OIl110 = push_ae_lvl;
localparam [O1O00l1O-1:0] OOOOO1OO = pop_ae_lvl;
localparam [O1O00l1O-1:0] OO0IlOO1 = (depth+1)/2;
localparam [O1O00l1O-1:0] OIOO0101 = depth-push_af_lvl;
localparam [O1O00l1O-1:0] Oll01lIO = depth-pop_af_lvl;
localparam [O1O00l1O-1:0] Il110011 = depth;

// In case local hard coded O0OI0OIO is modified, limit its value to missmapling
// methods valid for Gray code missampling
localparam l11OOIOl = (O0OI0OIO == 3)? 1 :
                          ( (O0OI0OIO == 2)? 4 : O0OI0OIO );

   reg 			       pop_ae, pop_hf, pop_af, pop_full;
   reg [O1O00l1O-1 : 0]     push_word_count, pop_word_count;
   reg 			       I11O00O0, O0O00I00, I000I1I0, 
			       OI1l1011;	 
   reg 			       O100O1O1, l00IOO11;
   
   reg 			       push_af, push_hf, push_ae, push_empty;

   reg  [O1O00l1O-1:0]      lO1lO00I, l1l0IOO0;
   reg  [O1O00l1O-1:0]      ll001l0O, O001OI1O;
   reg  [O1O00l1O-1:0]      O00l1I1I, lOl0OOOO;
   reg  [O1O00l1O-1:0]      I1lOO011, OOl0I1O1;
   reg  [O1O00l1O-1:0]      O1lOO0IO, l100l1O0;
   reg  [O1O00l1O-1:0]      I0001O1I, O1II0Il1;
   wire [O1O00l1O-1:0]      O1l1O1OO, OI0lOllO;
   reg  [O1O00l1O-1:0]      OII0OO00, OO1I11O1;
   wire [O1O00l1O-1:0]      O0OO1l11, IOOO0010;
   wire [O1O00l1O-1:0]      lI0OO1Il, lOO0101I;

   
   
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
	    
  
    if ( (push_ae_lvl < 1) || (push_ae_lvl > depth-1 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter push_ae_lvl (legal range: 1 to depth-1 )",
	push_ae_lvl );
    end
  
    if ( (push_af_lvl < 1) || (push_af_lvl > depth-1 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter push_af_lvl (legal range: 1 to depth-1 )",
	push_af_lvl );
    end
  
    if ( (pop_ae_lvl < 1) || (pop_ae_lvl > depth-1 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter pop_ae_lvl (legal range: 1 to depth-1 )",
	pop_ae_lvl );
    end
  
    if ( (pop_af_lvl < 1) || (pop_af_lvl > depth-1 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter pop_af_lvl (legal range: 1 to depth-1 )",
	pop_af_lvl );
    end
  
    if ( (push_sync < 1) || (push_sync > 3 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter push_sync (legal range: 1 to 3 )",
	push_sync );
    end
  
    if ( (pop_sync < 1) || (pop_sync > 3 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter pop_sync (legal range: 1 to 3 )",
	pop_sync );
    end
  
    if ( (err_mode < 0) || (err_mode > 1 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter err_mode (legal range: 0 to 1 )",
	err_mode );
    end
  
    if ( (rst_mode < 0) || (rst_mode > 1 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter rst_mode (legal range: 0 to 1 )",
	rst_mode );
    end
  
    if ( (tst_mode < 0) || (tst_mode > 1 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter tst_mode (legal range: 0 to 1 )",
	tst_mode );
    end
  
    if ( (depth < 4) || (depth > 16777216 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter depth (legal range: 4 to 16777216 )",
	depth );
    end

   
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 




  initial begin
    if ((push_sync > 0)&&(push_sync < 8))
      $display("Information: *** Instance %m is the DW_fifoctl_s2_sf Clock Domain Crossing Module ***");
  end



  function [O1O00l1O-1:0] OOIllIOI;
    input  [O1O00l1O-1:0] O1I001lO;  // input
    reg    [O1O00l1O-1:0] lOlIIO1O;
    integer                  l0I01O01;
    begin
      lOlIIO1O = {O1O00l1O{1'b0}};
      for (l0I01O01=O1O00l1O-1 ; l0I01O01 >= 0 ; l0I01O01=l0I01O01-1) begin
	if (l0I01O01 < O1O00l1O-1)
	  lOlIIO1O[l0I01O01] = O1I001lO[l0I01O01] ^ lOlIIO1O[l0I01O01+1];
	else
	  lOlIIO1O[l0I01O01] = O1I001lO[l0I01O01];
      end // for
      OOIllIOI = lOlIIO1O;
    end
  endfunction



    always @ (*) begin : DW_lO0IllOI
      if (push_req_n == 1'b0) begin
	lOl0OOOO = (lO1lO00I == depth)? O00l1I1I : 
			   (O00l1I1I + 1) %  O01O1I1I ;
      end else begin
	lOl0OOOO = O00l1I1I;
      end
    end // mk_next_wr_addr_int

    always @ (*) begin : DW_O001lO0O
      if ((lOl0OOOO < lI0OO1Il) ) begin
	l1l0IOO0 = O01O1I1I - (lI0OO1Il - lOl0OOOO );
      end else begin
	l1l0IOO0 = (lOl0OOOO - lI0OO1Il);
      end
    end // mk_next_wd_count
   
    always @ (*) begin : DW_lI1OOO1O
      if ((err_mode == 0) && (I000I1I0 == 1'b1)) begin
	O100O1O1 = 1'b1;
      end else begin
	if ((push_req_n == 1'b0) && (lO1lO00I == depth)) begin
	  O100O1O1 = 1'b1;
	end else begin
	  O100O1O1 = 1'b0;
	end
      end
    end // mk_push_next_error


generate
  if (rst_mode == 0) begin : DW_IllO1ll0
    DWsc_sync #(O1O00l1O, push_sync, ll00lIOO, l11OOIOl) U_RA_SYNC(
       .clk_d(clk_push),
       .rst_d_n(rst_n),
       .init_d_n(1'b1),
       .data_s(OO1I11O1 ^ O011l0OI),
       .test(1'b0),
       .data_d(IOOO0010) );

    always @ (posedge clk_push or negedge rst_n) begin : DW_OII10IOI
      if (rst_n == 1'b0) begin
	O00l1I1I <= {O1O00l1O{1'b0}};
	lO1lO00I <= {O1O00l1O{1'b0}};
	I000I1I0 <= 1'b0;
      end else begin
	O00l1I1I <= lOl0OOOO;
	lO1lO00I <= l1l0IOO0;
	I000I1I0 <= O100O1O1;
      end

    end // block: DW_OII10IOI
  end else begin : DW_I0O10II1
    DWsc_sync #(O1O00l1O, push_sync, ll00lIOO, l11OOIOl) U_RA_SYNC(
       .clk_d(clk_push),
       .rst_d_n(1'b1),
       .init_d_n(rst_n),
       .data_s(OO1I11O1 ^ O011l0OI),
       .test(1'b0),
       .data_d(IOOO0010) );

    always @ (posedge clk_push) begin : DW_O1O10O10
      if (rst_n == 1'b0) begin
	O00l1I1I <= {O1O00l1O{1'b0}};
	lO1lO00I <= {O1O00l1O{1'b0}};
	I000I1I0 <= 1'b0;
      end else begin
	O00l1I1I <= lOl0OOOO;
	lO1lO00I <= l1l0IOO0;
	I000I1I0 <= O100O1O1;
      end
    end // block: DW_O1O10O10
  end
endgenerate

  assign  lOO0101I = OOIllIOI(O0OO1l11 ^ O011l0OI) - O0O10I10;

  assign  O1l1O1OO = O00l1I1I + O0O10I10;

  always @ (*) begin : DW_I0I01l01
    O1lOO0IO = O1l1O1OO ^ (O1l1O1OO >> 1);
  end
   
  always @ (*) begin : DW_IOOI0l1I
    push_empty      = (lO1lO00I == II0I1O00)?   1'b1 : 1'b0;
    push_ae         = (lO1lO00I <= I0OIl110)?     1'b1 : 1'b0;
    push_hf         = (lO1lO00I < OO0IlOO1)?       1'b0 : 1'b1;
    push_af         = (lO1lO00I < OIOO0101)?      1'b0 : 1'b1;
    O0O00I00   = (lO1lO00I != Il110011)?    1'b0 : 1'b1;
    push_word_count = lO1lO00I[O1O00l1O-1:0];
  end // block: mk_push_flags


generate
  if (tst_mode == 0) begin : DW_Ol100lI1
    always @ (*) begin : DW_OO100IOI
      OII0OO00 = O1lOO0IO;
    end // mk_wr_addr_g_cc

    always @ (*) begin : DW_O1II0I10
      OO1I11O1 = I0001O1I;
    end // mk_rd_addr_g_cc

  end else begin : DW_lO0O0O11
    always @ (*) begin : DW_OI001OI0
      if (clk_push == 1'b0)
	l100l1O0 = O1lOO0IO;
    end // mk_wr_addr_gray_ltch

    always @ (*) begin : DW_OO100IOI
      if (test == 1'b0) begin
	OII0OO00 = O1lOO0IO;
      end else begin
	OII0OO00 = l100l1O0;
      end
    end // mk_wr_addr_g_cc

    always @ (*) begin : DW_l111101O
      if (clk_pop == 1'b0)
	O1II0Il1 = I0001O1I;
    end // mk_rd_addr_gray_ltch

    always @ (*) begin : DW_O1II0I10
      if (test == 1'b0) begin
	OO1I11O1 = I0001O1I;
      end else begin
	OO1I11O1 = O1II0Il1;
      end
    end // mk_rd_addr_g_cc
  end
endgenerate


    always @ (*) begin : DW_O0l001II
      if (pop_req_n == 1'b0) begin
	OOl0I1O1 = (ll001l0O != II0I1O00)? (I1lOO011 + 1) % O01O1I1I :
				 I1lOO011;
      end else begin
        OOl0I1O1 = I1lOO011;
      end
    end // mk_next_rd_addr_int

    always @ (*) begin : DW_O1OO01ll
      if (OOl0I1O1 > lOO0101I)  begin
	O001OI1O = O01O1I1I - (OOl0I1O1 - lOO0101I);
      end else begin
	O001OI1O = lOO0101I - OOl0I1O1 ;
      end
    end // mk_next_rd_count   

    always @ (*) begin : DW_l1OlI0l1
      if ((err_mode == 0) && (OI1l1011 == 1'b1)) begin
	l00IOO11 = 1'b1;
      end else begin
	if ((pop_req_n == 1'b0) && (ll001l0O == II0I1O00)) begin
	  l00IOO11 = 1'b1;
	end else begin
	  l00IOO11 = 1'b0;
	end
      end
    end // mk_pop_next_error


generate
  if (rst_mode == 0) begin : DW_l111O100
    DWsc_sync #(O1O00l1O, pop_sync, ll00lIOO, l11OOIOl) U_WA_SYNC(
       .clk_d(clk_pop),
       .rst_d_n(rst_n),
       .init_d_n(1'b1),
       .data_s(OII0OO00 ^ O011l0OI),
       .test(1'b0),
       .data_d(O0OO1l11) );

    always @ (posedge clk_pop or negedge rst_n) begin : DW_IOO11lOI
      if (rst_n == 1'b0) begin
        I1lOO011 <= {O1O00l1O{1'b0}};
        ll001l0O <= {O1O00l1O{1'b0}};
        OI1l1011 <= 1'b0;
      end else begin
	I1lOO011 <= OOl0I1O1;
	ll001l0O <= O001OI1O;
	OI1l1011 <= l00IOO11;
      end
    end // block: DW_IOO11lOI
  end else begin : DW_Ol0l1000
    DWsc_sync #(O1O00l1O, pop_sync, ll00lIOO, l11OOIOl) U_WA_SYNC(
       .clk_d(clk_pop),
       .rst_d_n(1'b1),
       .init_d_n(rst_n),
       .data_s(OII0OO00 ^ O011l0OI),
       .test(1'b0),
       .data_d(O0OO1l11) );

    always @ (posedge clk_pop) begin : DW_OO0lO0OO
      if (rst_n == 1'b0) begin
	I1lOO011 <= {O1O00l1O{1'b0}};
	ll001l0O <= {O1O00l1O{1'b0}};
	OI1l1011 <= 1'b0;
      end else begin
	I1lOO011 <= OOl0I1O1;
	ll001l0O <= O001OI1O;
	OI1l1011 <= l00IOO11;
      end
    end // block: DW_OO0lO0OO
  end
endgenerate

  assign lI0OO1Il = OOIllIOI(IOOO0010 ^ O011l0OI) - O0O10I10;

  assign OI0lOllO = I1lOO011 + O0O10I10;

  always @ (*) begin : DW_l11O1OOI
    I0001O1I = OI0lOllO ^ (OI0lOllO >> 1);
  end


  always @ (*) begin : DW_OI0O1Oll
    I11O00O0  = (ll001l0O == II0I1O00)?   1'b1 : 1'b0;
    pop_ae         = (ll001l0O <= OOOOO1OO)?     1'b1 : 1'b0;
    pop_hf         = (ll001l0O < OO0IlOO1)?       1'b0 : 1'b1;
    pop_af         = (ll001l0O < Oll01lIO)?      1'b0 : 1'b1;
    pop_full       = (ll001l0O != Il110011)?    1'b0 : 1'b1;
    pop_word_count = ll001l0O[O1O00l1O-1:0];
  end // block: mk_pop_flags

  assign wr_addr    = O00l1I1I[O1O10Il0-1:0];
  assign rd_addr    = I1lOO011[O1O10Il0-1:0];
  assign push_full  = O0O00I00;
  assign pop_empty  = I11O00O0;
  assign push_error = I000I1I0;
  assign pop_error  = OI1l1011;
  assign we_n       = O0O00I00 | push_req_n;
   

// synopsys translate_on

endmodule

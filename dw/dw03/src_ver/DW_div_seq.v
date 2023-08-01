////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 2002 - 2018 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Aamir Farooqui                February 20, 2002
//
// VERSION:   Verilog Simulation Model for DW_div_seq
//
// DesignWare_version: 6b3579fa
// DesignWare_release: O-2018.06-DWBB_201806.3
//
////////////////////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------------
//ABSTRACT:  Sequential Divider 
//  Uses modeling functions from DW_Foundation.
//
//MODIFIED:
// 2/26/16 LMSU Updated to use blocking and non-blocking assigments in
//              the correct way
// 8/06/15 RJK Update to support VCS-NLP
// 2/06/15 RJK  Updated input change monitor for input_mode=0 configurations to better
//             inform designers of severity of protocol violations (STAR 9000851903)
// 5/20/14 RJK  Extended corruption of output until next start for configurations
//             with input_mode = 0 (STAR 9000741261)
// 9/25/12 RJK  Corrected data corruption detection to catch input changes
//             during the first cycle of calculation (related to STAR 9000506285)
// 1/4/12 RJK Change behavior when inputs change during calculation with
//          input_mode = 0 to corrupt output (STAR 9000506285)
// 3/19/08 KYUNG fixed the reset error of the sim model (STAR 9000233070)
// 5/02/08 KYUNG fixed the divide_by_0 error (STAR 9000241241)
// 1/08/09 KYUNG fixed the divide_by_0 error (STAR 9000286268)
// 8/01/17 AFT fixes to sequential behavior to make the simulation model
//             match the synthesis model. 
// 01/17/18 AFT Star 9001296230 
//              Fixed error in NLP VCS, related to upadtes to next_complete
//              inside always blocks that define registers. NLP forces the
//              code to be synthesizable, forcing the code of this simulation
//              model to be changed.
//------------------------------------------------------------------------------

module DW_div_seq ( clk, rst_n, hold, start, a,  b, complete, divide_by_0, quotient, remainder);


// parameters 

  parameter  integer a_width     = 3; 
  parameter  integer b_width     = 3;
  parameter  integer tc_mode     = 0;
  parameter  integer num_cyc     = 3;
  parameter  integer rst_mode    = 0;
  parameter  integer input_mode  = 1;
  parameter  integer output_mode = 1;
  parameter  integer early_start = 0;
 
//-----------------------------------------------------------------------------

// ports 
  input clk, rst_n;
  input hold, start;
  input [a_width-1:0] a;
  input [b_width-1:0] b;

  output complete;
  output [a_width-1 : 0] quotient;
  output [b_width-1 : 0] remainder;
  output divide_by_0;

//-----------------------------------------------------------------------------
// synopsys translate_off

localparam signed [31:0] CYC_CONT = (input_mode==1 & output_mode==1 & early_start==0)? 3 :
                                    (input_mode==early_start & output_mode==0)? 1 : 2;

//------------------------------------------------------------------------------
  // include modeling functions
`include "DW_div_function.inc"
 

//-------------------Integers-----------------------
  integer count;
  integer next_count;
 

//-----------------------------------------------------------------------------
// wire and registers 

  wire [a_width-1:0] a;
  wire [b_width-1:0] b;
  wire [b_width-1:0] in2_c;
  wire [a_width-1:0] quotient;
  wire [a_width-1:0] temp_quotient;
  wire [b_width-1:0] remainder;
  wire [b_width-1:0] temp_remainder;
  wire clk, rst_n;
  wire hold, start;
  wire divide_by_0;
  wire complete;
  wire temp_div_0;
  wire start_n;
  wire start_rst;
  wire int_complete;
  wire hold_n;

  reg [a_width-1:0] next_in1;
  reg [b_width-1:0] next_in2;
  reg [a_width-1:0] in1;
  reg [b_width-1:0] in2;
  reg [b_width-1:0] ext_remainder;
  reg [b_width-1:0] next_remainder;
  reg [a_width-1:0] ext_quotient;
  reg [a_width-1:0] next_quotient;
  reg run_set;
  reg ext_div_0;
  reg next_div_0;
  reg start_r;
  reg ext_complete;
  reg next_complete;
  reg temp_div_0_ff;

  wire [b_width-1:0] b_mux;
  reg [b_width-1:0] b_reg;
  reg pr_state;
  reg rst_n_clk;
  reg nxt_complete;
  wire reset_st;
  wire nx_state;

//-----------------------------------------------------------------------------
  
  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
    
    if (a_width < 3) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter a_width (lower bound: 3)",
	a_width );
    end
    
    if ( (b_width < 3) || (b_width > a_width) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter b_width (legal range: 3 to a_width)",
	b_width );
    end
    
    if ( (num_cyc < 3) || (num_cyc > a_width) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter num_cyc (legal range: 3 to a_width)",
	num_cyc );
    end
    
    if ( (tc_mode < 0) || (tc_mode > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter tc_mode (legal range: 0 to 1)",
	tc_mode );
    end
    
    if ( (rst_mode < 0) || (rst_mode > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter rst_mode (legal range: 0 to 1)",
	rst_mode );
    end
    
    if ( (input_mode < 0) || (input_mode > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter input_mode (legal range: 0 to 1)",
	input_mode );
    end
    
    if ( (output_mode < 0) || (output_mode > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter output_mode (legal range: 0 to 1)",
	output_mode );
    end
    
    if ( (early_start < 0) || (early_start > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter early_start (legal range: 0 to 1)",
	early_start );
    end
    
    if ( (input_mode===0 && early_start===1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m : Invalid parameter combination: when input_mode=0, early_start=1 is not possible" );
    end

  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 


//------------------------------------------------------------------------------

  assign start_n      = ~start;
  assign complete     = ext_complete & (~start_r);
  assign in2_c        =  input_mode == 0 ? in2 : ( int_complete == 1 ? in2 : {b_width{1'b1}});
  assign temp_quotient  = (tc_mode)? DWF_div_tc(in1, in2_c) : DWF_div_uns(in1, in2_c);
  assign temp_remainder = (tc_mode)? DWF_rem_tc(in1, in2_c) : DWF_rem_uns(in1, in2_c);
  assign int_complete = (! start && run_set) || start_rst;
  assign start_rst    = ! start && start_r;
  assign reset_st = nx_state;

  assign temp_div_0 = (b_mux == 0) ? 1'b1 : 1'b0;

  assign b_mux = ((input_mode == 1) && (start == 1'b0)) ? b_reg : b;

  always @(posedge clk) begin : a1000_PROC
    if (start == 1) begin
      b_reg <= b;
    end 
  end

// Begin combinational next state assignments
  always @ (start or hold or count or a or b or in1 or in2 or
            temp_div_0 or temp_quotient or temp_remainder or
            ext_div_0 or ext_quotient or ext_remainder or ext_complete) begin
    if (start === 1'b1) begin                       // Start operation
      next_in1       = a;
      next_in2       = b;
      next_count     = 0;
      nxt_complete   = 1'b0;
      next_div_0     = temp_div_0;
      next_quotient  = {a_width{1'bX}};
      next_remainder = {b_width{1'bX}};
    end else if (start === 1'b0) begin              // Normal operation
      if (hold === 1'b0) begin
        if (count >= (num_cyc+CYC_CONT-4)) begin
          next_in1       = in1;
          next_in2       = in2;
          next_count     = count; 
          nxt_complete   = 1'b1;
          if (run_set == 1) begin
            next_div_0     = temp_div_0;
            next_quotient  = temp_quotient;
            next_remainder = temp_remainder;
          end else begin
            next_div_0     = 0;
            next_quotient  = 0;
            next_remainder = 0;
          end
        end else if (count === -1) begin
          next_in1       = {a_width{1'bX}};
          next_in2       = {b_width{1'bX}};
          next_count     = -1; 
          nxt_complete   = 1'bX;
          next_div_0     = 1'bX;
          next_quotient  = {a_width{1'bX}};
          next_remainder = {b_width{1'bX}};
        end else begin
          next_in1       = in1;
          next_in2       = in2;
          next_count     = count+1; 
          nxt_complete   = 1'b0;
          next_div_0     = temp_div_0;
          next_quotient  = {a_width{1'bX}};
          next_remainder = {b_width{1'bX}};
        end
      end else if (hold === 1'b1) begin             // Hold operation
        next_in1       = in1;
        next_in2       = in2;
        next_count     = count; 
        nxt_complete   = ext_complete;
        next_div_0     = ext_div_0;
        next_quotient  = ext_quotient;
        next_remainder = ext_remainder;
      end else begin                                // hold = X
        next_in1       = {a_width{1'bX}};
        next_in2       = {b_width{1'bX}};
        next_count     = -1;
        nxt_complete   = 1'bX;
        next_div_0     = 1'bX;
        next_quotient  = {a_width{1'bX}};
        next_remainder = {b_width{1'bX}};
      end
    end else begin                                  // start = X 
      next_in1       = {a_width{1'bX}};
      next_in2       = {b_width{1'bX}};
      next_count     = -1;
      nxt_complete   = 1'bX;
      next_div_0     = 1'bX;
      next_quotient  = {a_width{1'bX}};
      next_remainder = {b_width{1'bX}};
    end
  end
// end combinational next state assignments
  
generate
  if (rst_mode == 0) begin : GEN_RM_EQ_0

    assign nx_state = ~rst_n | (~start_r & pr_state);

  // Begin sequential assignments   
    always @ ( posedge clk or negedge rst_n ) begin : ar_register_PROC
      if (rst_n === 1'b0) begin
        count           <= 0;
        if(input_mode == 1) begin
          in1           <= 0;
          in2           <= 0;
        end else if (input_mode == 0) begin
          in1           <= a;
          in2           <= b;
        end 
        ext_complete    <= 0;
        ext_div_0       <= 0;
        start_r         <= 0;
        run_set         <= 0;
        pr_state        <= 1;
        ext_quotient    <= 0;
        ext_remainder   <= 0;
        temp_div_0_ff   <= 0;
        rst_n_clk       <= 1'b0;
      end else if (rst_n === 1'b1) begin
        count           <= next_count;
        in1             <= next_in1;
        in2             <= next_in2;
        ext_complete    <= nxt_complete & start_n;
        ext_div_0       <= next_div_0;
        ext_quotient    <= next_quotient;
        ext_remainder   <= next_remainder;
        start_r         <= start;
        pr_state        <= nx_state;
        run_set         <= 1;
        if (start == 1'b1)
          temp_div_0_ff   <= temp_div_0;
        rst_n_clk       <= rst_n;
      end else begin                                // If nothing is activated then put 'X'
        count           <= -1;
        in1             <= {a_width{1'bX}};
        in2             <= {b_width{1'bX}};
        ext_complete    <= 1'bX;
        ext_div_0       <= 1'bX;
        ext_quotient    <= {a_width{1'bX}};
        ext_remainder   <= {b_width{1'bX}};
        temp_div_0_ff   <= 1'bX;
        rst_n_clk       <= 1'bX;
      end 
    end                                             // ar_register_PROC

  end else begin : GEN_RM_NE_0

    assign nx_state = ~rst_n_clk | (~start_r & pr_state);

  // Begin sequential assignments   
    always @ ( posedge clk ) begin : sr_register_PROC
      if (rst_n === 1'b0) begin
        count           <= 0;
        if(input_mode == 1) begin
          in1           <= 0;
          in2           <= 0;
        end else if (input_mode == 0) begin
          in1           <= a;
          in2           <= b;
        end 
        ext_complete    <= 0;
        ext_div_0       <= 0;
        start_r         <= 0;
        run_set         <= 0;
        pr_state        <= 1;
        ext_quotient    <= 0;
        ext_remainder   <= 0;
        temp_div_0_ff   <= 0;
        rst_n_clk       <= 1'b0;
      end else if (rst_n === 1'b1) begin
        count           <= next_count;
        in1             <= next_in1;
        in2             <= next_in2;
        ext_complete    <= nxt_complete & start_n;
        ext_div_0       <= next_div_0;
        ext_quotient    <= next_quotient;
        ext_remainder   <= next_remainder;
        start_r         <= start;
        pr_state        <= nx_state;
        run_set         <= 1;
        if (start == 1'b1)
          temp_div_0_ff   <= temp_div_0;
        rst_n_clk       <= rst_n;
      end else begin                                // If nothing is activated then put 'X'
        count           <= -1;
        in1             <= {a_width{1'bX}};
        in2             <= {b_width{1'bX}};
        ext_complete    <= 1'bX;
        ext_div_0       <= 1'bX;
        ext_quotient    <= {a_width{1'bX}};
        ext_remainder   <= {b_width{1'bX}};
        temp_div_0_ff   <= 1'bX;
        rst_n_clk       <= 1'bX;
      end 
   end // sr_register_PROC

  end
endgenerate

  always @ (posedge clk) begin: nxt_complete_sync_PROC
    next_complete <= nxt_complete;
  end // complete_reg_PROC

  wire corrupt_data;

generate
  if (input_mode == 0) begin : GEN_IM_EQ_0

    localparam [0:0] NO_OUT_REG = (output_mode == 0)? 1'b1 : 1'b0;
    reg [a_width-1:0] ina_hist;
    reg [b_width-1:0] inb_hist;
    wire next_corrupt_data;
    reg  corrupt_data_int;
    wire data_input_activity;
    reg  init_complete;
    wire next_alert1;
    integer change_count;

    assign next_alert1 = next_corrupt_data & rst_n & init_complete &
                                    ~start & ~complete;

    if (rst_mode == 0) begin : GEN_A_RM_EQ_0
      always @ (posedge clk or negedge rst_n) begin : ar_hist_regs_PROC
	if (rst_n === 1'b0) begin
	    ina_hist        <= a;
	    inb_hist        <= b;
	    change_count    <= 0;

	  init_complete   <= 1'b0;
	  corrupt_data_int <= 1'b0;
	end else begin
	  if ( rst_n === 1'b1) begin
	    if ((hold != 1'b1) || (start == 1'b1)) begin
	      ina_hist        <= a;
	      inb_hist        <= b;
	      change_count    <= (start == 1'b1)? 0 :
	                         (next_alert1 == 1'b1)? change_count + 1 : change_count;
	    end

	    init_complete   <= init_complete | start;
	    corrupt_data_int<= next_corrupt_data | (corrupt_data_int & ~start);
	  end else begin
	    ina_hist        <= {a_width{1'bx}};
	    inb_hist        <= {b_width{1'bx}};
	    change_count    <= -1;
	    init_complete   <= 1'bx;
	    corrupt_data_int <= 1'bX;
	  end
	end
      end
    end else begin : GEN_A_RM_NE_0
      always @ (posedge clk) begin : sr_hist_regs_PROC
	if (rst_n === 1'b0) begin
	    ina_hist        <= a;
	    inb_hist        <= b;
	    change_count    <= 0;
	  init_complete   <= 1'b0;
	  corrupt_data_int <= 1'b0;
	end else begin
	  if ( rst_n === 1'b1) begin
	    if ((hold != 1'b1) || (start == 1'b1)) begin
	      ina_hist        <= a;
	      inb_hist        <= b;
	      change_count    <= (start == 1'b1)? 0 :
	                         (next_alert1 == 1'b1)? change_count + 1 : change_count;
	    end

	    init_complete   <= init_complete | start;
	    corrupt_data_int<= next_corrupt_data | (corrupt_data_int & ~start);
	  end else begin
	    ina_hist        <= {a_width{1'bx}};
	    inb_hist        <= {b_width{1'bx}};
	    init_complete    <= 1'bx;
	    corrupt_data_int <= 1'bX;
	    change_count     <= -1;
	  end
	end
      end
    end // GEN_A_RM_NE_0

    assign data_input_activity =  (((a !== ina_hist)?1'b1:1'b0) |
				 ((b !== inb_hist)?1'b1:1'b0)) & rst_n;

    assign next_corrupt_data = (NO_OUT_REG | ~complete) &
                              (data_input_activity & ~start &
					~hold & init_complete);

`ifdef UPF_POWER_AWARE
  `protected
)9\ALdD@9g#4;?8g1cA<aM5Z-=GFNf>Y=_U2f2CDR-JH3_Y9&dWT4)PcCWJ<C+/I
YE2BEcG9PU3&[(N]=?&@-3#cUFI[02NF2g1G_/.LC2+C?;bdVKa^34U>-2_EFIM&
44=2.:7##]/e3[P0\0N1VVd^#)\g/5RP/(4aS)dd>)8ES;.a,)>V#O<RcQa\IX^<
Hd<E3#>-fg4>(R3_G^&A9FIX:Lb-&VYK]bT2(6)0+eQ?FKcH7CgU:agQO:f/1(@D
R&EH\7#0cIB3b:X)f_H]]S4NF.3EQ<S0^H=EI,QQ-A7FJSN&AZS4R1Z+H#)QA]Zg
2QB_N5,>BL/_e)Mf=WS4V,;D2ZK)96GO9N_1;>7S&L\eZ.JMa+-S+f8_6X4E/<2\
>DG.<:gLB.4Y>O>L;L<a+Fg#bGb_W(N=DJ+=&c0aZSPZOfPMC?)H?L4Y^CJ^GR0a
daX^@)PgI/R[&9,^\/V(0;Fc/]G(&SHK2(dV8bFXZb4]J6))D^-RC[K/@N[>ZZAD
AGELFd@P8NDTP27,A,K-=+HZ&CL<IR7S361T,L+dDg_\7/1K9N^AM@2EMO5M:A&Y
Y8P]:0fH9K/3V3NBPPA26S73H2e=TKLV8<X-6^Z&PfFUB7dG;7d=34^UD:1M,4IV
I-8<6G+(9V.IOCBR<U=M(&WCAGgC-d8C26Tg_/+\CT/3&^CFS8&N?=f:NI:-&7<;
XV?IZfW:HI;)3V+g+O#>FR\?O2fFK:[?:1_SO8\bVZ<?[+T)aa01d,=394b6#Q]b
E?[DI9dM5\/J(=Gg3-7+SGC,:^e13XZ7fHQ=HI5DCUPDEET9[_]gE?3ed\4>J5Zd
/LA.4)d7?d)WP5g@JE)R9+-TH540\F^RP5>-4<gWG?412g.3]O]<8TYNFT>S(.U]
aZG5d[4G6<A;HX?H5HMEGKB\?]2<]I4/F&&1./MdN)?U;O0</K,KR,RDKH5]F&-Z
)cK@AV>Q)<BE&&@OT,R;ceMa>?>^#e&/C?YA@NG-^C1W+(2W5L\1_^g3W,f#_Vdc
LJ55aEd7HRXg8?d2Q&?H\Ag+@\V:.fa6V-M@G2Dg&\/>+1<7MQ;>6>/W3EWeUf->
-[+@SC__RVER#8UNB,Tc]JU,YFF&)+Tdg1O(AgG3T;6F<8J8e31O7N=I1<JB]Z_/
ge9)8/f5f:A+C<dYU7;NDCYLP&898<6FKaULgB3;L49>B5-)]X[:\513^dP^E]:]
1S.->86::32ZEJEF;DW,I9aLC9BJ,+YCC,IOX^2C&\6+UP<d7fc&L#O06.Z8gZ+Q
W.Y2fe;);Y)1Z#3KTLe6CCd8@J8^cD]QO1R>-91A#WFg@UT?VZNX88^W@C@2#;D^
Za1fK_>dQ:g0fb#,f-[Fag<QdQ5He:SQ1<3]:ASd0f2>L\F^I>EP.&ONB6b.ZHdc
9AS_N&C-3&Pg@gKL28(L#H/0WQE\H5,/f3<C1YGB/U&U(6^(^?A]A@1,@5N#3VB8
2>Y):62+#]#6NZ6+V5H-5(e<I=36VV<#bcVd>BR84M]>D#^?f,dBRJ7U5UH+6e_9
Y8P(Gd@P>EAbI(RP#],&XSST)YE1K]\,,4A1V\>I/fe(1H@/,C9L.92/QO@a4[]K
BP33D^RFJWN&d)fed4;#DAYH7I9PeX//FU)1g7G>&E(]Cf?XZ,N)bS-K,A9C7\(]
YMJ<d5\EHa^13GHDUUXZ9]/I659PD/__cNaKZ6(V.e5OXWGYV2.)JSS1(<=FN;38
HV<+e<Rg7MceV]D]d]\<3SHNEJ<;@VLJ^DP<cdcMRe#GX_^LK)ae&Hf[6bH..POf
?g3EJ-0#E^O(a>T4DB[PXOKK4XH#SgDIWQMGYQJ0IRML:A3Y)a:0D,G^>\JCJGB6
c.VQK4aO)S0AIdgPPL2b;TcAA;YD1QF,Ge>);S=+?ZZeE8:aPQ7a@dfV?KNH2YaS
bF6>b4DO..gc/Gg1gMg(,OddaI=eNfYM0SDX+gFReffD&Aa7M5Y33@d4X3I]\@.a
+U=^YCgENGL1JaTM9Rc;G3D>C2_P2>RROadZO7_<QSCCgV^?3,R_1c0J;Z8IFEO]
ZB]8a@:K^OVE1LJbMB3UI/44BX6=2eTeZO<];K3Q77_IdSU/T^=HA[_WN>ADfZ]X
c<McX9U\N^AG/[YgF17P7T/bN_DacLI16-<]TSXT>UL>XG(S:[.EP5+RJ)M[?g1V
83KZ\XRJb3E:(4bE),>T0NI@Z-0:XA7\HN823&L5[:KdaP6.1UY<)38OUYEKLW/V
;V^XD1=Z(C,bAX_G=PA_A5f16C4?)>QX[=Q8:M5FLfJYEd,>7_.fb://&A].c5Za
::]M]]&d<JC.KfDV#,0>Y,BL:QTBB2\Y_NE0]LMW]VaW0>GDP1;O_>I>V;@\6]E\U$
`endprotected

`else
    always @ (posedge clk) begin : corrupt_alert_PROC
      integer updated_count;

      updated_count = change_count;

      if (next_alert1 == 1'b1) begin
        $display("## Warning from %m: DW_div_seq operand input change near %0d will cause corrupted results if operation is allowed to complete.", $time);
	updated_count = updated_count + 1;
      end

      if (((rst_n & init_complete & ~start & ~complete & next_complete) == 1'b1) &&
          (updated_count > 0)) begin
	$display(" ");
	$display("############################################################");
	$display("############################################################");
	$display("##");
	$display("## Error!! : from %m");
	$display("##");
	$display("##    This instance of DW_div_seq has encountered %0d change(s)", updated_count);
	$display("##    on operand input(s) after starting the calculation.");
	$display("##    The instance is configured with no input register.");
	$display("##    So, the result of the operation was corrupted.  This");
	$display("##    message is generated at the point of completion of");
	$display("##    the operation (at time %0d), separate warning(s) were", $time );
	$display("##    generated earlier during calculation.");
	$display("##");
	$display("############################################################");
	$display("############################################################");
	$display(" ");
      end
    end
`endif

    assign corrupt_data = corrupt_data_int;

  if (output_mode == 0) begin : GEN_OM_EQ_0
    reg  alert2_issued;
    wire next_alert2;

    assign next_alert2 = next_corrupt_data & rst_n & init_complete &
                                     ~start & complete & ~alert2_issued;

`ifdef UPF_POWER_AWARE
  `protected
\@3YabQ3\9e+35CFJQHP5OXdX4=6;#.]V[[@&/_FYOO6T1ZTTa<D/)6cND_C#+E3
FZ05fR^VeV5YLU?Q&ZbL.^A4/+8<)6;H0Q23J=ef.[OAU03LQU2,XHB[_ZR;M^7K
9dOBS5>N]21<.F6V197?^]DZD,-<0_+5?N\FUgW(PB.=&[K);N;DB^MD-<S-5([I
YdFO)d33^I\3TZG?U(V1\<]_3.&8TF0Z&,XB#WE,gC-1UU)><EV,\MSE&Z)S2_EZ
2gU+LFMYL;L&KT20-4[6SQSOc_c)U<9/WZW/=^O6PVGK.=)PAbBf<g<M-NU;A/&?
L=V^^NC<dR)(ge6fBMVC\.42(.@=P^e3EN]3/>Rcf:Z@I]bBJ4EM:aXe-]PN@CPI
9&ggYX5HL[X-3RH2(4O_AX-QERd)QBDR;2.<)8<bH.&e.XJaacg50BL(a4OOAC-S
3?4gNg=90T[E\&XEc=N]f;O^=KE]LN+55.@<Me<+:_[-8eIQdMf7c9/Q(S4G[gOX
170.&E[:,F3E.$
`endprotected

`else
    always @ (posedge clk) begin : corrupt_alert2_PROC
      if (next_alert2 == 1'b1) begin
        $display( "## Warning from %m: DW_div_seq operand input change near %0d causes output to no longer retain result of previous operation.", $time);
      end
    end
`endif

    if (rst_mode == 0) begin : GEN_AI_REG_AR
      always @ (posedge clk or negedge rst_n) begin : ar_alrt2_reg_PROC
        if (rst_n == 1'b0) alert2_issued <= 1'b0;

	  else alert2_issued <= ~start & (alert2_issued | next_alert2);
      end
    end else begin : GEN_AI_REG_SR
      always @ (posedge clk) begin : sr_alrt2_reg_PROC
        if (rst_n == 1'b0) alert2_issued <= 1'b0;

	  else alert2_issued <= ~start & (alert2_issued | next_alert2);
      end
    end

  end  // GEN_OM_EQ_0

  // GEN_IM_EQ_0
  end else begin : GEN_IM_NE_0
    assign corrupt_data = 1'b0;
  end // GEN_IM_NE_0
endgenerate
    

  assign quotient     = (reset_st == 1) ? {a_width{1'b0}} :
                        ((((input_mode==0)&&(output_mode==0))||(early_start==1)) & start == 1'b1) ? {a_width{1'bX}} :
                        (corrupt_data !== 1'b0)? {a_width{1'bX}} : ext_quotient;
  assign remainder    = (reset_st == 1) ? {b_width{1'b0}} :
                        ((((input_mode==0)&&(output_mode==0))||(early_start==1)) & start == 1'b1) ? {b_width{1'bX}} :
                        (corrupt_data !== 1'b0)? {b_width{1'bX}} : ext_remainder;
  assign divide_by_0  = (reset_st == 1) ? 1'b0 :
                        (input_mode == 1 && output_mode == 0 && early_start == 0) ? ext_div_0 :
                        (output_mode == 1 && early_start == 0) ? temp_div_0_ff :
                        temp_div_0_ff;

 
  always @ (clk) begin : P_monitor_clk 
    if ( (clk !== 1'b0) && (clk !== 1'b1) && ($time > 0) )
      $display( "WARNING: %m :\n  at time = %t, detected unknown value, %b, on clk input.",
                $time, clk );
    end // P_monitor_clk 
// synopsys translate_on

endmodule

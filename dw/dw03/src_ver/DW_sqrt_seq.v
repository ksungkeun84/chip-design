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
// AUTHOR:    Aamir Farooqui                February 12, 2002
//
// VERSION:   Verilog Simulation Model for DW_sqrt_seq
//
// DesignWare_version: b67072bd
// DesignWare_release: O-2018.06-DWBB_201806.3
//
////////////////////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------------
//
//ABSTRACT:  Sequential Square Root 
// Uses modeling functions from DW_Foundation.
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
//             during the first cycle of calculation (related to STAR 9000506330)
// 1/5/12 RJK Change behavior when input changes during calculation with
//          input_mode = 0 to corrupt output (STAR 9000506330)
//
//------------------------------------------------------------------------------

module DW_sqrt_seq ( clk, rst_n, hold, start, a, complete, root);


// parameters 

  parameter  integer width       = 6; 
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
  input [width-1:0] a;

  output complete;
  output [(width+1)/2-1:0] root;

//-----------------------------------------------------------------------------
// synopsys translate_off

//------------------------------------------------------------------------------
localparam signed [31:0] CYC_CONT = (input_mode==1 & output_mode==1 & early_start==0)? 3 :
                                    (input_mode==early_start & output_mode==0)? 1 : 2;

//------------------------------------------------------------------------------
  // include modeling functions
`include "DW_sqrt_function.inc"
 
//-------------------Integers-----------------------
  integer count;
  integer next_count;
 

//-----------------------------------------------------------------------------
// wire and registers 

  wire clk, rst_n;
  wire hold, start;
  wire [width-1:0] a;
  wire complete;
  wire [(width+1)/2-1:0] root;

  wire [(width+1)/2-1:0] temp_root;
  reg [(width+1)/2-1:0] ext_root;
  reg [(width+1)/2-1:0] next_root;
 
  reg [width-1:0]   in1;
  reg [width-1:0]   next_in1;

  wire start_n;
  wire hold_n;
  reg ext_complete;
  reg next_complete;
 


//-----------------------------------------------------------------------------
  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
    
    if (width < 6) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter width (lower bound: 6)",
	width );
    end
    
    if ( (num_cyc < 3) || (num_cyc > (width+1)/2) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter num_cyc (legal range: 3 to (width+1)/2)",
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
  assign complete     = ext_complete & start_n;
  assign temp_root    = (tc_mode)? DWF_sqrt_tc (in1): DWF_sqrt_uns (in1); 

// Begin combinational next state assignments
  always @ (start or hold or a or count or in1 or temp_root or ext_root or ext_complete) begin : a1000_PROC
    if (start === 1'b1) begin                   // Start operation
      next_in1      = a;
      next_count    = 0;
      next_complete = 1'b0;
      next_root     = {(width+1)/2{1'bX}};
    end else if (start === 1'b0) begin          // Normal operation
      if (hold===1'b0) begin
        if (count >= (num_cyc+CYC_CONT-4)) begin
          next_in1      = in1;
          next_count    = count; 
          next_complete = 1'b1;
          next_root     = temp_root;
        end else if (count === -1) begin
          next_in1      = {width{1'bX}};
          next_count    = -1; 
          next_complete = 1'bX;
          next_root     = {(width+1)/2{1'bX}};
        end else begin
          next_in1      = in1;
          next_count    = count+1; 
          next_complete = 1'b0;
          next_root     = {(width+1)/2{1'bX}} ;
        end
      end else if (hold === 1'b1) begin         // Hold operation
        next_in1      = in1;
        next_count    = count; 
        next_complete = ext_complete;
        next_root     = ext_root;
      end else begin                            // hold == X
        next_in1      = {width{1'bX}};
        next_count    = -1;
        next_complete = 1'bX;
        next_root     = {(width+1)/2{1'bX}};
      end
    end else begin                              // start == X
      next_in1      = {width{1'bX}};
      next_count    = -1;
      next_complete = 1'bX;
      next_root     = {(width+1)/2{1'bX}};
    end
  end
// end combinational next state assignments

generate
  if (rst_mode == 0) begin : GEN_RM_EQ_0

  // Begin sequential assignments   
    always @ ( posedge clk or negedge rst_n ) begin: ar_register_PROC
      if (rst_n === 1'b0) begin                 // initialize everything asyn reset
        count        <= 0;
        in1          <= 0;
        ext_root     <= 0;
        ext_complete <= 0;
      end else if (rst_n === 1'b1) begin        // rst_n == 1
        count        <= next_count;
        in1          <= next_in1;
        ext_root     <= next_root;
        ext_complete <= next_complete & start_n;
      end else begin                            // rst_n == X
        count        <= -1;
        in1          <= {width{1'bX}};
        ext_root     <= {(width+1)/2{1'bX}};
        ext_complete <= 1'bX;
      end 
   end // ar_register_PROC

  end else begin : GEN_RM_NE_0

  // Begin sequential assignments   
    always @ ( posedge clk ) begin: sr_register_PROC 
      if (rst_n === 1'b0) begin                 // initialize everything syn reset
        count        <= 0;
        in1          <= 0;
        ext_root     <= 0;
        ext_complete <= 0;
      end else if (rst_n === 1'b1) begin        // rst_n == 1
        count        <= next_count;
        in1          <= next_in1;
        ext_root     <= next_root;
        ext_complete <= next_complete & start_n;
      end else begin                            // rst_n == X
        count        <= -1;
        in1          <= {width{1'bX}};
        ext_root     <= {(width+1)/2{1'bX}};
        ext_complete <= 1'bX;
      end 
    end // sr_register_PROC

  end
endgenerate

  wire corrupt_data;

generate
  if (input_mode == 0) begin : GEN_IM_EQ_0

    localparam [0:0] NO_OUT_REG = (output_mode == 0)? 1'b1 : 1'b0;
    reg [width-1:0] ina_hist;
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
	    change_count    <= 0;

	  init_complete   <= 1'b0;
	  corrupt_data_int <= 1'b0;
	end else begin
	  if ( rst_n === 1'b1) begin
	    if ((hold != 1'b1) || (start == 1'b1)) begin
	      ina_hist        <= a;
	      change_count    <= (start == 1'b1)? 0 :
	                         (next_alert1 == 1'b1)? change_count + 1 : change_count;
	    end

	    init_complete   <= init_complete | start;
	    corrupt_data_int<= next_corrupt_data | (corrupt_data_int & ~start);
	  end else begin
	    ina_hist        <= {width{1'bx}};
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
	    change_count    <= 0;
	  init_complete   <= 1'b0;
	  corrupt_data_int <= 1'b0;
	end else begin
	  if ( rst_n === 1'b1) begin
	    if ((hold != 1'b1) || (start == 1'b1)) begin
	      ina_hist        <= a;
	      change_count    <= (start == 1'b1)? 0 :
	                         (next_alert1 == 1'b1)? change_count + 1 : change_count;
	    end

	    init_complete   <= init_complete | start;
	    corrupt_data_int<= next_corrupt_data | (corrupt_data_int & ~start);
	  end else begin
	    ina_hist        <= {width{1'bx}};
	    init_complete    <= 1'bx;
	    corrupt_data_int <= 1'bX;
	    change_count     <= -1;
	  end
	end
      end
    end // GEN_A_RM_NE_0

    assign data_input_activity =  ((a !== ina_hist)?1'b1:1'b0) & rst_n;

    assign next_corrupt_data = (NO_OUT_REG | ~complete) &
                              (data_input_activity & ~start &
					~hold & init_complete);

`ifdef UPF_POWER_AWARE
  `protected
)9\ALdD@9g#4;?8g1cA<aM5Z-=GFNf>Y=_U2f2CDR-JH3_Y9&dWT4)PcCWJ<C+/I
]E^+-E2Y\+-VX)+bJaJ;Y/,7T+)4T0[;6PZSI#6We#:cLT.RFX4eEdARM@@2Y40B
Q_MVfbB6BJ_:DHZ1V0B2d?eBcM7^;4I91&]3GIg(W^@Tb3g_J-,283^?TFY:&[95
.bCV..33=.K9C2^ffGA:-.PJ4Y=a/g.?0A-Z8#_1,>Vg<fCF+0XWM4#ZU]789UL8
d6,SF0GN:@?ROcJa&)?#SZ>dca,&)d^EZMYZYB<HCU/YU6>Nd61-e5ID=(K6U6<g
F\P=<5>H&U1Tb_0LUAe7MWIQ4a>a\5O@7#<fE0I-:ZT^VY7IbVX&;<d:H>#fUOaH
3[WS8L6Z+Bg2gL]X8OD)d:D.L(HF1>OBBG/WPg[)E-Tb=T#&_aP7Ne4^2TEWHWF-
T6/;4;0[fT3dS.:5DOH_F4>83VP+O=5JW37-AWca?D3@94Te2WG/(0=cVD3(O<c:
[WZ/9Z;:#^Q/WWC?ZffU3HP?P=TBINZaP0c40RPK\43N+BG?c=HQ4:#fXNdf)g?5
Q.RaN2W2dOR7JJMfOE9??=ef<+b@W<5a^PXB[->8VPP;,=8?cdAJS-/g09Yf\DT\
&NH]_,@NV\ICYKYV@\;c2O/(<UT]OJ@S+OFKJG^-HGCH;1Md;.,)cNTA\a[5[]&Q
0QM=+Ie6YY3UN^d)4U^KO6(=4VgLEYE;X0LHW8Gc53G55=YLRK3E8PUUY]>9&SUY
I2KLD1S&<@@1N5]4P^K)OL9&-Kdc@@e.V[=;8HPV9?QZ_1)FJK;DA)-FVCbSLUJ=
7YK<c81.8=\S@;H1<I>EeW7-aGZ>&B<><>Cf0?O<^#dccE?&TK8JT;d@+-:]<bD)
P;]5:Kc\I\8JQ(0Y3</?=cbg&Z<?g;]NX@#gH<2V##0&2JP;3#B8?_W@CJfVZM?9
Ve]Cc01cg.BN;Df[OH^&94KZB<=S>G>M,L3Z,<Xf_XcT1&<AK3&Y#LKJY&_1\G//
/d>VBFc=2&KdKbMWXR<f653-f-f.=SB0R<Z/9BCS8f:gA[Pdb]J#8(.Ybb2JTNR7
@.(.0[-bRROPXQ]V-<,eX1g==B37]=?[A1Fa1QAab1^5N:XT/H1f^D:3;K6>#DDg
dfPOcg-EC-^d/1G.K_\:a<KgI90f-Nc+@/S)f:+:<d)cPH6PES-7?f/NLBCF<F/:
Q]]SCWc?4C0bIPgGO/0;XVS0PdG08Lb3Z0FJ=.&1<[R>aD=dT(N)OX/WP:V2O0P^
8:R+?55N96Z]5\>@+]A0IJPW<);1E3&+9.G0B,OaO0ZRf9<9B^=^6]:1TV=7;8/Z
<N4[\,<6V\8Y>/:](ZGH,a_.fBUJ(+Yf8eN4M1^e:S#WOXNCR:A[V0]6=/ET4W?Z
bZ8U#eZEQ.-V/#/D;J6)+PQcN[(DNZP>81c96--404S]IXd)b5=JJaPc.#VQI7V[
-]Z-/^T-2LDf4<SDWS..^-EZ[7MgJGa\;I@+<X=MZD,@OF[N?.g;:O.g[7cdZVVP
7?]E\.K6DI@>_]8(A_3\U/S837c><EXP79<ZE;HYJSf@6KCVF8=4BK_FH;Nb/=8@
a029#eN0d10NVW2=KL3NXe&&L+7gKYb9^R,T?FT^JI\fIWdXE^LC0Oge/)EaUI(;
c1\UJ56D+2Y]cAN;DUc[KcYL8XY>(/ZAPV;Xce?T#1FE9FS8K5PDV-DN-bI]C(CC
(JG=^K<N;YfR-GD;&9f#]N0RRG>RK85@6F/)d>>.MX;LffF>,Pf@8S-P+AIeRWYe
FX6@7K)b,LVf>_<gIXR<TYU.Pc<@T:3@ceO-^0JNWYMER<M]YJaL4T@=UL:<Eg9G
P6:QbNT/ce;&4^>P4^.1&Q5Hf&ZJQ5C&74:(M>Y8/CIR[E:YSHP0,NKCC]?5-/U2
-T<<TaR_\/IM0/]81IQ(7g/N&g&d]/>J76=(fZFL6H)=6)7T-E-\V.4#&b@\]3?T
eXLbdA9RDP^2_CX:dK]W&1IB<OdY/#8ZY/N2W_V38a#6[KQ6+5OBZfR>>G;_?,MZ
ES41XC8eXCY<US3La#RFN&J:OV#-(6XSY@UQ_&/+R(B(,4?0Ka.\4F5JG0C^R.<O
Ye,-#,N^44gVF+.I=\g+d^cg^TBI(:5:eQ9NdPRPdV>@gWReHCdX&Q&;54S;CDM?
NJD^)G@0&M0E,d(;^M\@W[C\MfW2PTZE-b54.X+7e9QIZC1e]\Qdg_)^O:c1K4MR
P8R:8ZQ7\7fb:@aVRC\F+>)&(^.==)YWSYI.2V38)bUKBHAI+fTXf>FgV:0O#;77
4DR=:1/fP][3)^fLBg..;\KgC5@XLJ#@M)#S\\RX&VI,[6a18f5+J=;+8:GMLZb8W$
`endprotected

`else
    always @ (posedge clk) begin : corrupt_alert_PROC
      integer updated_count;

      updated_count = change_count;

      if (next_alert1 == 1'b1) begin
        $display("## Warning from %m: DW_sqrt_seq operand input change near %0d will cause corrupted results if operation is allowed to complete.", $time);
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
	$display("##    This instance of DW_sqrt_seq has encountered %0d change(s)", updated_count);
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
NKO]T::McT&6H][Sbg+B9Jc=TPXADc1S,@U+RS/_cFaFGCRSJa4d,/A)bZ#MM/]X
aKDEXV<J<=;GGQ9dC++L-3:+e::U4N<57bBK-5L5EA_.f@Uc]=>[:OQP3Q1.SKX@
7\_X-195]SP^g4=fRM.J<B[AR>9BZcEK0^VHU.AgAA0)#FDdY1]IA\>gI,2BR,DB
4\I&304@9C(fLW+=34gB(?234[]]/L/WL=D(<7J)P0^=BC=)_1ARYEe4VEXL:X:/
L(.<=FI-<+e9FC8V)KdL?4SdbSYI_X;3)=c_+S-Mb&5;MA7ZCO0^R-S)6Ubd:O(S
\+Yd33J1J8\86aL1NQ5(_WQYEER3N@gOXV&6_J)PQF3@-7;6N&a5=eN9,;Ga=RIf
SA;;Ce#&G5+7BUb@<T4>c5LWR0DG<Y<\HF&Y<+MEZA<\F^EX_A2EIY,fD+K@M1:M
gKC/JV(>+807/$
`endprotected

`else
    always @ (posedge clk) begin : corrupt_alert2_PROC
      if (next_alert2 == 1'b1) begin
        $display( "## Warning from %m: DW_sqrt_seq operand input change near %0d causes output to no longer retain result of previous operation.", $time);
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

  assign root         = ((((input_mode==0)&&(output_mode==0))||(early_start==1)) & start == 1'b1) ?
			     {(width+1)/2{1'bX}} :
                             (corrupt_data === 1'b0)? ext_root : {(width+1)/2{1'bX}} ;

 
  always @ (clk) begin : P_monitor_clk 
    if ( (clk !== 1'b0) && (clk !== 1'b1) && ($time > 0) )
      $display( "WARNING: %m :\n  at time = %t, detected unknown value, %b, on clk input.",
                $time, clk );
    end // P_monitor_clk 
// synopsys translate_on

endmodule





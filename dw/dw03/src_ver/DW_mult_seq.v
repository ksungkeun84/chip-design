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
// VERSION:   Verilog Simulation Model for DW_mult_seq
//
// DesignWare_version: e90338e1
// DesignWare_release: O-2018.06-DWBB_201806.3
//
////////////////////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------------
//
//ABSTRACT:  Sequential Multiplier 
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
//             during the first cycle of calculation (related to STAR 9000505348)
// 1/5/12 RJK Change behavior when inputs change during calculation with
//          input_mode = 0 to corrupt output (STAR 9000505348)
//
//------------------------------------------------------------------------------

module DW_mult_seq ( clk, rst_n, hold, start, a,  b, complete, product);


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
  output [a_width+b_width-1:0] product;

//-----------------------------------------------------------------------------
// synopsys translate_off

localparam signed [31:0] CYC_CONT = (input_mode==1 & output_mode==1 & early_start==0)? 3 :
                                    (input_mode==early_start & output_mode==0)? 1 : 2;

//-------------------Integers-----------------------
  integer count;
  integer next_count;
 

//-----------------------------------------------------------------------------
// wire and registers 

  wire clk, rst_n;
  wire hold, start;
  wire [a_width-1:0] a;
  wire [b_width-1:0] b;
  wire complete;
  wire [a_width+b_width-1:0] product;

  wire [a_width+b_width-1:0] temp_product;
  reg [a_width+b_width-1:0] ext_product;
  reg [a_width+b_width-1:0] next_product;
  wire [a_width+b_width-2:0] long_temp1,long_temp2;
  reg [a_width-1:0]   in1;
  reg [b_width-1:0]   in2;
  reg [a_width-1:0]   next_in1;
  reg [b_width-1:0]   next_in2;
 
  wire [a_width-1:0]   temp_a;
  wire [b_width-1:0]   temp_b;

  wire start_n;
  wire hold_n;
  reg ext_complete;
  reg next_complete;
 


//-----------------------------------------------------------------------------
  
  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
    
    if (b_width < 3) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter b_width (lower bound: 3)",
	b_width );
    end
    
    if ( (a_width < 3) || (a_width > b_width) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter a_width (legal range: 3 to b_width)",
	a_width );
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
  assign complete     = ext_complete & start_n;

  assign temp_a       = (in1[a_width-1])? (~in1 + 1'b1) : in1;
  assign temp_b       = (in2[b_width-1])? (~in2 + 1'b1) : in2;
  assign long_temp1   = temp_a*temp_b;
  assign long_temp2   = ~(long_temp1 - 1'b1);
  assign temp_product = (tc_mode)? (((in1[a_width-1] ^ in2[b_width-1]) && (|long_temp1))?
                                {1'b1,long_temp2} : {1'b0,long_temp1}) : in1*in2;

// Begin combinational next state assignments
  always @ (start or hold or a or b or count or in1 or in2 or
            temp_product or ext_product or ext_complete) begin
    if (start === 1'b1) begin                     // Start operation
      next_in1      = a;
      next_in2      = b;
      next_count    = 0;
      next_complete = 1'b0;
      next_product  = {a_width+b_width{1'bX}};
    end else if (start === 1'b0) begin            // Normal operation
      if (hold === 1'b0) begin
        if (count >= (num_cyc+CYC_CONT-4)) begin
          next_in1      = in1;
          next_in2      = in2;
          next_count    = count; 
          next_complete = 1'b1;
          next_product  = temp_product;
        end else if (count === -1) begin
          next_in1      = {a_width{1'bX}};
          next_in2      = {b_width{1'bX}};
          next_count    = -1; 
          next_complete = 1'bX;
          next_product  = {a_width+b_width{1'bX}};
        end else begin
          next_in1      = in1;
          next_in2      = in2;
          next_count    = count+1; 
          next_complete = 1'b0;
          next_product  = {a_width+b_width{1'bX}};
        end
      end else if (hold === 1'b1) begin           // Hold operation
        next_in1      = in1;
        next_in2      = in2;
        next_count    = count; 
        next_complete = ext_complete;
        next_product  = ext_product;
      end else begin                              // hold == x
        next_in1      = {a_width{1'bX}};
        next_in2      = {b_width{1'bX}};
        next_count    = -1;
        next_complete = 1'bX;
        next_product  = {a_width+b_width{1'bX}};
      end
    end else begin                                // start == x
      next_in1      = {a_width{1'bX}};
      next_in2      = {b_width{1'bX}};
      next_count    = -1;
      next_complete = 1'bX;
      next_product  = {a_width+b_width{1'bX}};
    end
  end
// end combinational next state assignments

generate
  if (rst_mode == 0) begin : GEN_RM_EQ_0

  // Begin sequential assignments
    always @ ( posedge clk or negedge rst_n ) begin: ar_register_PROC
      if (rst_n === 1'b0) begin                   // initialize everything asyn reset
        count        <= 0;
        in1          <= 0;
        in2          <= 0;
        ext_product  <= 0;
        ext_complete <= 0;
      end else if (rst_n === 1'b1) begin          // rst_n == 1
        count        <= next_count;
        in1          <= next_in1;
        in2          <= next_in2;
        ext_product  <= next_product;
        ext_complete <= next_complete & start_n;
      end else begin                              // rst_n == X
        in1          <= {a_width{1'bX}};
        in2          <= {b_width{1'bX}};
        count        <= -1;
        ext_product  <= {a_width+b_width{1'bX}};
        ext_complete <= 1'bX;
      end 
   end // ar_register_PROC

  end else  begin : GEN_RM_NE_0

  // Begin sequential assignments
    always @ ( posedge clk ) begin: sr_register_PROC 
      if (rst_n === 1'b0) begin                   // initialize everything asyn reset
        count        <= 0;
        in1          <= 0;
        in2          <= 0;
        ext_product  <= 0;
        ext_complete <= 0;
      end else if (rst_n === 1'b1) begin          // rst_n == 1
        count        <= next_count;
        in1          <= next_in1;
        in2          <= next_in2;
        ext_product  <= next_product;
        ext_complete <= next_complete & start_n;
      end else begin                              // rst_n == X
        in1          <= {a_width{1'bX}};
        in2          <= {b_width{1'bX}};
        count        <= -1;
        ext_product  <= {a_width+b_width{1'bX}};
        ext_complete <= 1'bX;
      end 
   end // ar_register_PROC

  end
endgenerate

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
M\Q.Bg0KgYgA9/],-)KYg&FM0eZY2;X=c,Y6Hg^4b6&@B34N/I0+U2530&Eb@G31
^W0T=d0VB2e,3::G=,dfeRRUWQQ\7(.,1DWTc/0IAUKF.YM+Q.AJ:I(KdV)H4I=>
Q-F),595ZM2OOY>CgD7G@MD7<f6>I7?2Ie?^.9Jag8Ze)8e7DGcK+A0Ag)T>0Y1V
+-T_)29K8B[.&c978\XAGYT4XAUK[cWIgKf<U<7M<JQf6W8M0ME&a+ZfMZ(c>QL9
^,<@9,J+CZ0Z^F8\QPgZ#QW55&+[V2-Q,E>C]X8MNCM_R@F1e#&BDUCSJ)V##=,P
N:I>R5BOKRZW(BLV2,8[H&7AT9B_>GHIZS.Y)SH7)AT#Q[P5(6ZI@.F7AUD,S,C>
BBDBf_8=>#Q+HPM;H[X7/24:R^;G6bOFfUDN41^WRM(I0=V6)#&CbK+Tf/a(@F5[
8#.YV+?d9/F?G>@1&QT>UI.Y@D4d/F?A_C#+RAL;J/X\6=SZ?.)_-SX833g>OS>Q
bWC1(6]CY?S:Sfb?G?SRLRLBa4.YTeV2S/WUMgc@YBOe_M]a<9_+(J\1:H0N/()6
@\IaJ)MF_PdBF9I.V_D#Z8(DK-_?<3UI808?+S:22V\MQ]\77UH5cJI46OLb:d#@
aQ/6S2/.;:aNS5a0^ZUAV.B;Z<A9=.;(ZCKaL/[gb/KUTga-3P)P((X./(J_DC#Q
QR_+e@D=BL<^79J)c(,P?eWIgRZ&L.+R1]^=_)^C&(+/3(V5GU,8fQfS7Oc(/3f9
e;6UaTO6_(#^@.:_cF<2;8J>3\a1EZUIb5=+)B;K6^-(EQO\>85D2#IGB35dFV\d
.1C0GUg:W]OYbbSO5^5N)/XZJHD(&G&3-E2aW8P<H9IOD:_aX1S@f6gS>WJO@:FP
8X0\f?AUOM<E0B?NNXcZQC]fCEWSS\>V5(C^Cf4KNL\Y^f&]5FaB.RGY4dc[NG3f
B>HJF^bbWA@H3QW5R7HXWVN?H]XN2IPCd0BXeG57Q_0L+.QSf/+0JNCBgB)?Pg/2
6,Ic2b574#N<SJge>GcXH(e88OGNJ[S5O??B02^#-#K&G=]1e3HRGCF<+9eee(<F
Pf;:XY<Og6dP>)DS7WQ0USVGBQ(MB2E2=U6H[5>2.e[+78a8;;bQgAG.)R2X5eTE
<\eI+EY?)^7C+(?Bb@M-5<cP^H/ADU-g-/+=V60ObeDIQFBY;bdB#C[L>=\R/_,A
[IY5K83dS7.(5@+fNS)A8_3/d@XV8:X6.1_):dg>0(+X<6,SgKC&)SBC<3DJPg<g
VbQ58TZ;HS312DE^=bCL,2:]aZbDKNe_aM(5#O+[5OY,f8I]PVZQZ:2I@3:dK5I0
=UCP#GG>;>?_-6PTTSA#g6^ZX@_9c<+,&gJGc\>f=SVG2UICY7OA=PGH^MTDQS5M
KZ[^/^a43UHMSX;<31_=-a?f<Z,3LMOXVCP;F.O:,;)=)BScIJ/#<f)?62R3+KK2
c7Zg^HXHU/\R\..Hd-QJ2H]9X@;_=g-&I4.,S-(2BZ26\e:M\^-NO8aZTb9J=)]g
X2f:<A:97.8JY=4,+-K7?<YZNJ2Eb1\U(6GT8D]&G(1M5\_9E+Y#I>6D:1?-36XD
_#U.@a-3;)W6-F?H(4T5(B^>YGK4eeB^>/BL8K[BIbd(CLFU]NUHNfgVcHe6Sc5U
f\XQ2FD=c]T77<LBB,YN2P(g7#T\WXU(PV7I?F0[cENG\0:QB=gdM&e/FAbbQ+Z#
L?UUD-6fY^gZV],GW_X-X?Q,J]+[,VaL:7OA2UN76UWA5gcgFG.+YN+baVU08S6<
R.OU-1<@Ma#Bb9Ge0=H&\OWO,&f(JP>;I<d+IG3:/[Vf.\D@8?8]NSFBPgS@>aVH
9cY\MLJ.O0<GE(I\S>AD(3L;:e51DI>5=[(8GZGL[.bfHP\2?8<K@M\FY&G@_bJ)
)75SQ2C2=NY7f&,RdM.:Pdbe\cL]I)IH:>YC1=8a,&B\<@L<CB-0AWZ#>[,?>>5=
e&(@LW?RL926IBXI(.#BILadbB]RC7Wb#]@\YbA3DBc0[@7\dZecWeS1c2T+QS>0
f2#;)]N;TV.[dTB^f6K^+N4T=1\XR3S2G5E8aG[^[QUZP[YX9d\f>#<Q+>:D7L7.
&W-].U9KO)55+Ad3GX5A]R0Z-G+OVE8W31485>:<P7ZY5E1fJ,dPCgX.[Af^>@GO
g-QYb:(/@5X^]Q]-(IXN:W>QZ#[KD^;/R:\H27g/b)_4f4F/[<ZGZ8g=M\5\>B^:
75W/(WS<IT;YB:;5@^^7.4UTTWD2-T9QPZY]5M[&V0NE=P+&a68#D9A;U6N<=9]?W$
`endprotected

`else
    always @ (posedge clk) begin : corrupt_alert_PROC
      integer updated_count;

      updated_count = change_count;

      if (next_alert1 == 1'b1) begin
        $display("## Warning from %m: DW_mult_seq operand input change near %0d will cause corrupted results if operation is allowed to complete.", $time);
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
	$display("##    This instance of DW_mult_seq has encountered %0d change(s)", updated_count);
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
-\LdbeSb(1Hc08CH^MegE4TP_7_+K_&.N&+(7R,&R0=VZCfGY+f_R\g^6?(&X3K>
Rd<3V3>;)E7S1GP1#2H3T18BE6B&YB/Sgf#<.#eGNZA,/IRBYL:E9fN-1F]<YHIg
MUM9)X@Q_40dBQYHMfeO=-H]Ua7\:[4cg#ZHRaX18bL-XaZ3E/9JMH:(LaSXHNNX
&&a2ZQD6SISOJC8_E[RAg7cZNXIUAC-^F]99;Jb:EJ:WYM=GZ)D0&8aS]aP-9TQG
J:_5Q&/#\-d^.+LF0F&BMd9&CGR?ZPU<Q;/6T4]YgNHd4]A.^<W-Tc+#^]Q[,FRT
fSdaP469NA0G>.96C=_deU(PBK)PZHE3N0N]U1J,5>b,3LAcIAfXQ-6e/aA,;]-A
@+fA>4)5f(?;[9PXI]U^1@ER(:^a9YR2HWOZcW0W?gBg++83SXGKVIU=[796\0=b
OUH8&O(S.VV;/$
`endprotected

`else
    always @ (posedge clk) begin : corrupt_alert2_PROC
      if (next_alert2 == 1'b1) begin
        $display( "## Warning from %m: DW_mult_seq operand input change near %0d causes output to no longer retain result of previous operation.", $time);
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

  assign product      = ((((input_mode==0)&&(output_mode==0)) || (early_start == 1)) && start == 1'b1) ?
			  {a_width+b_width{1'bX}} :
                          (corrupt_data === 1'b0)? ext_product : {a_width+b_width{1'bX}};


 
  always @ (clk) begin : P_monitor_clk 
    if ( (clk !== 1'b0) && (clk !== 1'b1) && ($time > 0) )
      $display( "WARNING: %m :\n  at time = %t, detected unknown value, %b, on clk input.",
                $time, clk );
    end // P_monitor_clk 
// synopsys translate_on

endmodule





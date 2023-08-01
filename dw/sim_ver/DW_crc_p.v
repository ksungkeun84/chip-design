////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 2000 - 2018 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Jay Zhu, March 25, 2000
//
// VERSION:   Verilog Simulation Model
//
// DesignWare_version: 49162b93
// DesignWare_release: O-2018.06-DWBB_201806.3
//
////////////////////////////////////////////////////////////////////////////////
//-------------------------------------------------------------------------------
//
// ABSTRACT : Generic parallel CRC Generator/Checker 
//
// MODIFIED :
//
//      LMSU    07/09/2015      Changed for compatibility with VCS Native Low Power
//
//	RJK	04/12/2011 	Recoded parts to clean for lint - STAR 9000444285
//
//-------------------------------------------------------------------------------

module	DW_crc_p(
		data_in,
		crc_in,
		crc_ok,
		crc_out
		);

parameter    integer data_width = 16;
parameter    integer poly_size  = 16;
parameter    integer crc_cfg    = 7;
parameter    integer bit_order  = 3;
parameter    integer poly_coef0 = 4129;
parameter    integer poly_coef1 = 0;
parameter    integer poly_coef2 = 0;
parameter    integer poly_coef3 = 0;

input [data_width-1:0]	data_in;
input [poly_size-1:0]	crc_in;
output			crc_ok;
output [poly_size-1:0]	crc_out;


// synopsys translate_off

`define	DW_max_data_crc_l (data_width>poly_size?data_width:poly_size)


wire [poly_size-1:0]		crc_in_inv;
wire [poly_size-1:0]		crc_reg;
wire [poly_size-1:0]		crc_out_inv;
wire [poly_size-1:0]		crc_chk_crc_in;

`ifdef UPF_POWER_AWARE
  `protected
U3K2)dJ+JAF>gBS\3V1AN4KZWTVH58#0_+Y]gF@JF((EJgH.?2f(4)>ccL,+&f8N
]_A6I+Q-B4G7#U09[XY>29);@2-[UD/K9/TV5ZI-ODZ&X;VR^L?S<A.I)P;Ad1f7
)b#WD_^G\08HM#BBAEBU>0+FK1D^c;1Ae]?b8<(aY_Q9a3O401\6K#]>#ZZHfH#0
E>DfdTIfNZ4;Ke?=W7W].Q,(:9<AAb>g?MD&AL3W[RFM2)+6U4KQRCe^-\U.)<gY
O1Q-Pf+^F)3,\7LXA7d7&:)X5@=K8NO^a-2:P1OW[SBX]Z0@9;RL?@bXdd0^6K:H
OIE]]Je3I7YeIaUOgN@W(2(7-bJRHBDg[HIddMPU_Q;Z#+Xb-Ef/)LH?27^G\205
/2MVQ,7DYB4C.S]]([HffeU#_[f_-F]470<(1\:/e[<O;WB7(1\RHUeDa1YLJ5>Z
=(J3d1P?(0_+d4_MSd3&3C56EK=0>E@9V&Q71@[<dD4a/[C=.IGQ9>Q#>O.;]SR-
5D<EO<SH@)](N/(F61ZMY9_U[.\aPVW<V?I4d][5H<f9[>0NG4a^cBJJ@Y#e.,GW
=M=95P5Y.Y5:g^EKXJ\Q\aL7=?:H<H1c^2[\1]?X94NK#=DR\WI\U2?:T_.a36VK
G(/Vd7I&6+)&_#<4G<,7BLL^+DJ,,.GP9dS,AM1EG9O6>=6+(4X@=-#LWN<P;dOG
H>c\HWM_CKeFR;HD=V?5ZOd<,4bZPJ5HVQ7G@[G@CCcUF)@DI:BX6Q-BCJ5?&BAQ
?gd-IZ++G_R0?Y+fS-[R?/2S_Dc#RS><Zf6Q#3fHBI7XT[+(cdZ]+[QLE;.c:M\Q
1:?)5#g#;eFOAT-UeZK;G<P_;QHZLGC-HAH\F8L1B,JdRX2/E#1#b#=5[;YbX_WB
II(>\5d_0CfR-^;=)a+O,^>AfB:fAFZ]EZ?Q<[d[f^-/?JbHeZPEUY]MFa;DOGP,
-=Sfd2>MgSC;T)(/)ccO25TRAF(:8a[\XB1c);W()FDFD)B/71dE(bBI)=F.PNYN
KD^=_IaI?4EZZD@2bV-HBKS96:&AG4_48:&2BRNWM002>@K0^@0.N9WGW5Q(STDM
S2PP_c&8M6D2\U<^1E1EC/N.7.Z8919?B?@/[(c,QJEM7?#U@(:+M47Z-)V0(+@Q
^W0)1@U)1MM/OM5=@-Jd-B?FNN#XgWE34WLb=VV[^1P.RA:PKfJRS:-5_=XJ07#/
D\A7bU0_5XMOg\c)46@/RFN4K,ZPQ(gF<ZYLO\FIG(V#^\J.P>?e^NQ+U&[c3bGY
][F@HE_=,Z+MP<YY\?FW7JBe,H?-T][4aaaB)&F;3WU_GX\5^d0Vdf6KD9;]QL-g
,Ygf..QSSGC1F@LRc7[11f^2=Hc3X@Z0T))a_7:_]/S+eL<^O,5L<=Qa)cY,4:4T
11_P[&dTDCeZd)FT-0[,C1BC^O.Q@cK0&(eQLHRfae?C@6JgPedd\8)d)f0^:&S@
M,BAW9LNM36&2KPA8gS8._&0Z,:/>R60eB_4#PLFZCQ/?H/=ZGR-d6W1\@20We/#
VPJ1;A1EPHCK<(V+_2V(&VN<AP#-]:dgcC](1P/1cebRH?D&_/bQFT.#_HQQFI,/
bCSgC;O5GZ?TdK8aVRBBDcP4).M)>81KeEfB)a&YYYf5ebNVd>B+F&.#O$
`endprotected

`else
reg [poly_size-1:0]             crc_inv_alt;
reg [poly_size-1:0]             crc_polynomial;
`endif

function [`DW_max_data_crc_l-1:0]	bit_ordering;
    input [`DW_max_data_crc_l-1:0]	input_data;
    input [31:0]		v_width;

    begin : function_bit_ordering

	integer			width;
	integer			byte_idx;
	integer			bit_idx;

	width = v_width;

	case (bit_order) 
	    0 :
	  	bit_ordering = input_data;
	    1 :
		for(bit_idx=0; bit_idx<width; bit_idx=bit_idx+1)
		  bit_ordering[bit_idx] = input_data[width-bit_idx-1];
	    2 :
	  	for(byte_idx=0; byte_idx<width/8; byte_idx=byte_idx+1)
		  for(bit_idx=0;
		      bit_idx<8;
		      bit_idx=bit_idx+1)
	            bit_ordering[bit_idx+byte_idx*8]
		      = input_data[bit_idx+(width/8-byte_idx-1)*8];
	    3 :
		for(byte_idx=0; byte_idx<width/8; byte_idx=byte_idx+1)
		  for(bit_idx=0; bit_idx<8; bit_idx=bit_idx+1)
		    bit_ordering[byte_idx*8+bit_idx]
		          = input_data[(byte_idx+1)*8-1-bit_idx];
	    default : 
		begin 
		    $display("ERROR: %m : Internal Error.  Please report to Synopsys representative."); 
		    $finish; 
		end
	endcase

    end
endfunction // bit_ordering

function [poly_size-1 : 0] bit_order_crc;

    input [poly_size-1 : 0] crc_in;

    begin : function_bit_order_crc

        reg [`DW_max_data_crc_l-1 : 0] input_value;
        reg [`DW_max_data_crc_l-1 : 0] return_value;
	integer i;

	input_value = {`DW_max_data_crc_l{1'b0}};

	for (i=0 ; i < poly_size ; i=i+1)
	  input_value[i] = crc_in[i];

	return_value = bit_ordering(input_value,poly_size);

	bit_order_crc = return_value[poly_size-1 : 0];
    end
endfunction // bit_order_crc


function [data_width-1 : 0] bit_order_data;

    input [data_width-1 : 0] data_in;

    begin : function_bit_order_data

        reg [`DW_max_data_crc_l-1 : 0] input_value;
        reg [`DW_max_data_crc_l-1 : 0] return_value;
	integer i;

	input_value = {`DW_max_data_crc_l{1'b0}};

	for (i=0 ; i < data_width ; i=i+1)
	  input_value[i] = data_in[i];

	return_value = bit_ordering(input_value,data_width);

	bit_order_data = return_value[data_width-1 : 0];
    end
endfunction // bit_order_data


function [poly_size-1:0]	calculate_crc_w_in;

    input [poly_size-1:0]		crc_in;
    input [`DW_max_data_crc_l-1:0]	input_data;
    input [31:0]			width0;

    begin : function_calculate_crc_w_in

	integer			width;
	reg			feedback_bit;
	reg [poly_size-1:0]	feedback_vector;
	integer			bit_idx;

	width = width0;
	calculate_crc_w_in = crc_in;
	for(bit_idx=width-1; bit_idx>=0; bit_idx=bit_idx-1) begin
	    feedback_bit = calculate_crc_w_in[poly_size-1]
				^ input_data[bit_idx];
	    feedback_vector = {poly_size{feedback_bit}};

	    calculate_crc_w_in = {calculate_crc_w_in[poly_size-2:0],1'b0}
	  		^ (crc_polynomial & feedback_vector);
	end

    end
endfunction // calculate_crc_w_in


function [poly_size-1:0]	calculate_crc;
    input [data_width-1:0]	input_data;

    begin : function_calculate_crc

	reg [`DW_max_data_crc_l-1:0]	input_value;
	reg [poly_size-1:0]		crc_tmp;
	integer i;

	input_value = {`DW_max_data_crc_l{1'b0}};

	for (i=0 ; i < data_width ; i=i+1)
	  input_value[i] = input_data[i];

	crc_tmp = {poly_size{(crc_cfg % 2)?1'b1:1'b0}};
	calculate_crc = calculate_crc_w_in(crc_tmp, input_value,
			data_width);
    end
endfunction // calculate_crc_crc


function [poly_size-1:0]	calculate_crc_crc;
    input [poly_size-1:0]	input_crc;
    input [poly_size-1:0]	input_data;

    begin : function_calculate_crc_crc

	reg [`DW_max_data_crc_l-1:0]	input_value;
	reg [poly_size-1:0]		crc_tmp;
	integer i;

	input_value = {`DW_max_data_crc_l{1'b0}};

	for (i=0 ; i < poly_size ; i=i+1)
	  input_value[i] = input_data[i];

	calculate_crc_crc = calculate_crc_w_in(input_crc, input_value,
			poly_size);
    end
endfunction // calculate_crc_crc


    
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    

	
    if ( (data_width < 1) || (data_width > 512) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter data_width (legal range: 1 to 512)",
	data_width );
    end
	
    if ( (poly_size < 2) || (poly_size > 64) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter poly_size (legal range: 2 to 64)",
	poly_size );
    end
	
    if ( (crc_cfg < 0) || (crc_cfg > 7) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter crc_cfg (legal range: 0 to 7)",
	crc_cfg );
    end
	
    if ( (bit_order < 0) || (bit_order > 3) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter bit_order (legal range: 0 to 3)",
	bit_order );
    end
	
    if ( (poly_coef0 < 1) || (poly_coef0 > 65535) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter poly_coef0 (legal range: 1 to 65535)",
	poly_coef0 );
    end
	
    if ( (poly_coef1 < 0) || (poly_coef1 > 65535) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter poly_coef1 (legal range: 0 to 65535)",
	poly_coef1 );
    end
	
    if ( (poly_coef2 < 0) || (poly_coef2 > 65535) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter poly_coef2 (legal range: 0 to 65535)",
	poly_coef2 );
    end
	
    if ( (poly_coef3 < 0) || (poly_coef3 > 65535) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter poly_coef3 (legal range: 0 to 65535)",
	poly_coef3 );
    end

	if(poly_coef0 %2 == 0) begin
	    param_err_flg = 1;
	    $display(
	      "ERROR: %m : Invalid even poly_coef0 (poly_coef0=%d).",
	      poly_coef0);
	end

	if(bit_order > 1 && (data_width % 8 > 0)) begin
	    param_err_flg = 1;
	    $display(
	      "ERROR: %m : Invalid configuration (bit_order=%d, data_width=%d).",
	      bit_order, data_width);
	end

	if(bit_order > 1 && (poly_size % 8 > 0)) begin
	    param_err_flg = 1;
	    $display(
	      "ERROR: %m : Invalid configuration (bit_order=%d, poly_size=%d).",
	      bit_order, poly_size);
	end

    
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 



`ifndef UPF_POWER_AWARE
    initial begin : initialize_vars

	reg [63:0]	crc_polynomial64;
	reg [15:0]	coef0;
	reg [15:0]	coef1;
	reg [15:0]	coef2;
	reg [15:0]	coef3;
	integer		bit_idx;

	coef0 = poly_coef0;
	coef1 = poly_coef1;
	coef2 = poly_coef2;
	coef3 = poly_coef3;

	crc_polynomial64 = {coef3, coef2, coef1, coef0};
	crc_polynomial = crc_polynomial64[poly_size-1:0];

	case(crc_cfg/2)
	    0 : crc_inv_alt = {poly_size{1'b0}};
	    1 : for(bit_idx=0; bit_idx<poly_size; bit_idx=bit_idx+1)
		crc_inv_alt[bit_idx] = (bit_idx % 2)? 1'b0 : 1'b1;
	    2 : for(bit_idx=0; bit_idx<poly_size; bit_idx=bit_idx+1)
		crc_inv_alt[bit_idx] = (bit_idx % 2)? 1'b1 : 1'b0;
	    3 : crc_inv_alt = {poly_size{1'b1}};
	    default : 
		begin 
		    $display("ERROR: %m : Internal Error.  Please report to Synopsys representative."); 
		    $finish; 
		end
	endcase

    end // initialize_vars


`endif
    assign	crc_in_inv = bit_order_crc(crc_in) ^ crc_inv_alt;

    assign	crc_reg = calculate_crc(bit_order_data(data_in));

    assign	crc_out_inv = crc_reg ^ crc_inv_alt;
    assign	crc_out = bit_order_crc(crc_out_inv);
    assign	crc_chk_crc_in = calculate_crc_crc(crc_reg, crc_in_inv);
    assign	crc_ok = ! (| crc_chk_crc_in);


`undef	DW_max_data_crc_l

// synopsys translate_on

endmodule

////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 2009 - 2018 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Doug Lee       2/6/09
//
// VERSION:   Verilog Simulation Model
//
// DesignWare_version: 6b3a03a9
// DesignWare_release: O-2018.06-DWBB_201806.3
//
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//
// ABSTRACT: Low Power Pipelined Modified Hamming Code Error Correction/Detection Simulation Model 
//
//           This module supports data widths up to 8178 using
//           14 check bits
//
//
//  Parameters:     Valid Values    Description
//  ==========      ============    =============
//  data_width       8 to 8178      default: 8
//                                  Width of 'datain' and 'dataout'
//
//  chk_width         5 to 14       default: 5
//                                  Width of 'chkin', 'chkout', and 'syndout'
//
//   rw_mode           0 or 1       default: 1
//                                  Read or write mode
//                                    0 => read mode
//                                    1 => write mode
//
//   op_iso_mode      0 to 4        default: 0
//                                  Type of operand isolation
//                                    If 'in_reg' is '1', this parameter is ignored...effectively set to '1'.
//                                    0 => Follow intent defined by Power Compiler user setting
//                                    1 => no operand isolation
//                                    2 => 'and' gate isolaton
//                                    3 => 'or' gate isolation
//                                    4 => preferred isolation style: 'and' gate
//
//   id_width        1 to 1024      default: 1
//                                  Launch identifier width
//
//   in_reg           0 to 1        default: 0
//                                  Input register control
//                                    0 => no input register
//                                    1 => include input register
//
//   stages          1 to 1022      default: 4
//                                  Number of logic stages in the pipeline
//
//   out_reg          0 to 1        default: 0
//                                  Output register control
//                                    0 => no output register
//                                    1 => include output register
//
//   no_pm            0 to 1        default: 1
//                                  Pipeline management usage
//                                    0 => Use pipeline management
//                                    1 => Do not use pipeline management - launch input
//                                          becomes global register enable to block
//
//   rst_mode         0 to 1        default: 0
//                                  Control asynchronous or synchronous reset 
//                                  behavior of rst_n
//                                    0 => asynchronous reset
//                                    1 => synchronous reset 
//
//
//  Ports        Size    Direction    Description
//  =====        ====    =========    ===========
//  clk          1 bit     Input      Clock Input
//  rst_n        1 bit     Input      Reset Input, Active Low
//
//  datain       M bits    Input      Input data bus
//  chkin        N bits    Input      Input check bits bus
//
//  err_detect   1 bit     Output     Any error flag (active high)
//  err_multiple 1 bit     Output     Multiple bit error flag (active high)
//  dataout      M bits    Output     Output data bus
//  chkout       N bits    Output     Output check bits bus
//  syndout      N bits    Output     Output error syndrome bus
//
//  launch       1 bit     Input      Active High Control input to launch data into pipe
//  launch_id    Q bits    Input      ID tag for operation being launched
//  pipe_full    1 bit     Output     Status Flag indicating no slot for a new launch
//  pipe_ovf     1 bit     Output     Status Flag indicating pipe overflow
//
//  accept_n     1 bit     Input      Flow Control Input, Active Low
//  arrive       1 bit     Output     Product available output 
//  arrive_id    Q bits    Output     ID tag for product that has arrived
//  push_out_n   1 bit     Output     Active Low Output used with FIFO
//  pipe_census  R bits    Output     Output bus indicating the number
//                                   of pipeline register levels currently occupied
//
//     Note: M is the value of "data_width" parameter
//     Note: N is the value of "chk_width" parameter
//     Note: Q is the value of "id_width" parameter
//     Note: R is equal to the larger of '1' or ceil(log2(in_reg+stages+out_reg))
//
//
//-----------------------------------------------------------------------------
// Modified:
//     LMSU 02/17/15  Updated to eliminate derived internal clock and reset signals
//     RJK  10/07/15  Updated for compatibility with VCS NLP feature
//     RJK  07/14/17  Updated UPF specific code (STAR 9001217597)
//
////////////////////////////////////////////////////////////////////////////////
module DW_lp_piped_ecc(
        clk,            // Clock input
        rst_n,          // Reset

        datain,         // Input data bus
        chkin,          // Input check bits bus (for read or scrub)

        err_detect,     // Any error flag (active high)
        err_multiple,   // Multiple bit error flag (active high)
        dataout,        // Output data bus
        chkout,         // Output check bits bus
        syndout,        // Output error syndrome bus

        launch,         // Launch data into pipe input
        launch_id,      // ID tag of data launched input
        pipe_full,      // Pipe slots full output (used for flow control)
        pipe_ovf,       // Pipe overflow output

        accept_n,       // Take product input (flow control)
        arrive,         // Data arrival output
        arrive_id,      // ID tag of arrival product output
        push_out_n,     // Active low output used when FIFO follows
        pipe_census     // Pipe stages occupied count output
        );

parameter integer data_width = 8;  // RANGE 1 to 8178
parameter integer chk_width = 5;   // RANGE 5 to 14
parameter integer rw_mode = 1;     // RANGE 0 to 1
parameter integer op_iso_mode = 0; // RANGE 0 to 4
parameter integer id_width = 1;    // RANGE 1 to 1024
parameter integer in_reg = 0;      // RANGE 0 to 1
parameter integer stages = 4;      // RANGE 1 to 1022
parameter integer out_reg = 0;     // RANGE 0 to 1
parameter integer no_pm = 1;       // RANGE 0 to 1
parameter integer rst_mode = 0;    // RANGE 0 to 1




input                          clk;         // Clock Input
input                          rst_n;       // Reset
input  [data_width-1:0]        datain;        // Data input
input  [chk_width-1:0]         chkin;         // Check bits input

output                         err_detect;    // Error detect output
output                         err_multiple;  // Multiple errors detected output
output [data_width-1:0]        dataout;       // Data output
output [chk_width-1:0]         chkout;        // Check bits output
output [chk_width-1:0]         syndout;       // Syndrome output

input                          launch;      // Launch data into pipe
input  [id_width-1:0]          launch_id;   // ID tag of data launched
output                         pipe_full;   // Pipe slots full (used for flow control)
output                         pipe_ovf;    // Pipe overflow

input                          accept_n;    // Take product (flow control)
output                         arrive;      // Product arrival
output [id_width-1:0]          arrive_id;   // ID tag of arrival product
output                         push_out_n;  // Active low output used when FIFO follows

output [(((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>256)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4096)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16384)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32768)?16:15):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8192)?14:13)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>1024)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2048)?12:11):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>512)?10:9))):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>64)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>128)?8:7):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32)?6:5)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8)?4:3):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2)?2:1)))))-1:0]       pipe_census; // Pipe Stages Occupied Output

// synopsys translate_off

wire  [data_width-1:0]           O00IlO0I;
wire  [chk_width-1:0]            IOOI1O00;
wire                             O0lI0O1O;
wire  [id_width-1:0]             O10O0O10;
wire                             I1O0O1O1;

wire  [data_width-1:0]           O1110110;
wire  [chk_width-1:0]            OOOl1101;
wire  [data_width-1:0]           O1II11O1;
wire  [data_width-1:0]           OII1OOl0;
wire  [chk_width-1:0]            O01I11IO;
wire  [chk_width-1:0]            I01OO00O;

wire  [data_width-1:0]           O001IOl1;
wire  [chk_width-1:0]            I101OO10;
wire  [data_width-1:0]           I01ll0OO;
wire  [chk_width-1:0]            Ol0I0lO1;

wire  [data_width-1:0]           I10IO1Ol;
wire  [chk_width-1:0]            OI1l0l00;
wire  [chk_width-1:0]            O010010O;
wire                             lO00l00I;
wire                             I0O11O11;

wire  [data_width-1:0]           O0llOO1O;
wire  [chk_width-1:0]            IO1lO0l0;
wire  [chk_width-1:0]            II000OOO;
wire                             I10O110O;
wire                             IO100O1I;

wire  [(((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)-1:0]     O00l0I1O;
wire                             OOOOlIO1;
reg   [(((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)-1:0]     O10l0O0O;

wire                             O010lO10;
wire                             OOO1O1OO;
wire                             I1O001OO;
wire  [id_width-1:0]             IOO11O11;
wire                             OO1lIIO1;
wire  [(((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)-1:0]     O00101I1;
wire  [(((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>256)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4096)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16384)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32768)?16:15):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8192)?14:13)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>1024)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2048)?12:11):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>512)?10:9))):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>64)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>128)?8:7):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32)?6:5)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8)?4:3):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2)?2:1)))))-1:0]          O1O1IlO0;

wire                             l1I101lO;
wire                             OO1IOO00;
reg                              I10l1lO0;
wire                             O0O1011l;
wire  [id_width-1:0]             l0OOl11l;
wire                             I0IOIl1O;
wire  [(((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)-1:0]     IIO10010;
wire  [(((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>256)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4096)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16384)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32768)?16:15):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8192)?14:13)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>1024)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2048)?12:11):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>512)?10:9))):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>64)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>128)?8:7):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32)?6:5)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8)?4:3):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2)?2:1)))))-1:0]          OOO0Ol0O;

wire  [id_width-1:0]             OlI0OIOI;


  assign O00IlO0I     = (datain | (datain ^ datain));
  assign IOOI1O00      = (chkin | (chkin ^ chkin));
  assign O0lI0O1O     = (launch | (launch ^ launch));
  assign O10O0O10  = (launch_id | (launch_id ^ launch_id));
  assign I1O0O1O1   = (accept_n | (accept_n ^ accept_n));



`ifdef UPF_POWER_AWARE
`protected
T/Ref+&<=ZQ<:@>2&AXOIT_/FE[-/-\GdcSH#g_dbfR<P-)XVg893)Y_D\1P5C]F
ee47G.S((Hg,;<b&K^)WIQRE_3O#;2,dXZe5T<Mf388Z]\.^c,Gf^\O00I\:@a5L
=Xg\94de3[)2T4IKV?TOAB7L=Z0aN)OL(PILE6#9ZK,\e+?ZGYRPIE07B96@,TFg
LY630=L_@:ZKHUU]47@Y[>bZI2^F]WHEOWe.eMa.2KFV?WGR&f&F8&Q05E6V?,^=
)94@GE_<:T9:6G;AMC)\e7b<e2Q85DH6]DSCY(SddT2,CJ/_FP<_\6\Y3_8?PJ\.
?M@OTd?gW0F]+XfY_-##P_2eRc,/gYVJ@>7E^f+EG2Q)DP2\C&;Ac+20SaJ+U9Dg
#-,_/,^-AgQBY59UZJQ)JA3<BLT/Ub.->9\.Q^UYGe6.f5[PMWM5Y#5R:B_/1S6T
dO6J4EYSU.[EfI#MHXM,P_-7#KX<(>f9P2Ua@_,Q^3N@LRSf5[BJHAb>3&>J:>X=
:gGJ[2>\(IX=FHE62dOD6e)gR>1cE:,-7aG[Ue:A\V>IYE/.c<g^^@L>EKd5T5J?
F1MPE?_P0]BfIEa>6#I?3?[1M+D^[8cRUY8S9a7J#?/E23CQX#CH=Kd\d</_Z3,K
U8@W2-CEUV3@Z6+DdT.[9S\cIBTS==efG:2.dd3ND^A):,Yc?9,cO(2N?_C2AN_9
(GXRN+)0_#SbdLg/f0YIGffUO1P6NV62d/OV#)Z7US7<J;G./6Q,N&OXKJX[^6L0
Bc>f&4He_82>N8;/W\.]7]<5Z@,5CA>U1PO_H\93RQd,TfRHMSIcAZ5+0)]0L-D)
R62HY>4<1^K>91,.PaGO8V2&K)@(3[T8OBJT77I5)#CH-07J8B^42\ec1]7=WeJU
K6<PS<9FY[P#)@,>T:@@.b]T9K#,MHWBaaP5U;40[))^C+T[54][H(a_58LA<P_.
HL2Oa#0_[=C;EM>,X,0E^cIJXeW0IR3N1Ba5bc-+_QFS.d:^:B5_;I(\3,7,ANML
)B?1A/<ce\EQY(?/REZY)Ig5L(\RgJSR,N[G1JR+37^1G&R-Q/V=]IPgdOLC.N=8
RILe6g;Ng;Mdb+]cc74)Ag8Be4_b&5.^\IS?1-0U\aD<5>2(eb9U0]-6f6=^>aDD
.T\bN>D\JQ^<gX4]U>f5^1aKA@7?YWW\4AU17U8#//aF2dI2XQRB#W+H>EV9T]HJ
5KDc0GUKMbMR;Ff5_>/=7:OP\JI9[PSF4GQ,S\L^[N\V_b6XE;=9U8@?ZWQ8Q/O6
P@6CJ/F5H-SK3_P9aWe)_1QA3H2a_QA5gSQPPEfN)?=b=URS)BN@J7F@Ac[TU/<H
@@af:\C[I9^YPD)1a5KD18,\A0#2L8<CS44P&SRRb^G=.2aMSM/2=O#WE^?E4Mg?
@&(V8BNGIS[TFba2+3V^HWDH9eNYa9?[1+?.0FV=U,Qg2K;^T871TGBPfF/W+B1L
,02?4)2\/V33^W(c)H1XfO@^J2&eJaY1Eg7ECS4?@<8:PD0aT:E#:9?PSVN5FPNO
&Z+0#Je@Aaa#D?1^-4L4EVHL88#@N&cFG1(OV?#?FM0WGN(>g)S+BgW)/<M)JU\g
JKJ@XRUHJ3JXXX,OQ[QYK&+UUFIXL/DI8,2@8>V,dEg@OL\4]3K5YLd?+XaIG4@Z
\PS>e_PVeR+@W]AS_B-_a3:4[^[S^Obc6cgF?J#-:6#QIFYF+^8KN\Ug[.A0gP=V
)Fb_9-E\/E.J^<e=a0UEAca@;_^.&07a/=((^95FN[K+?,:_D]7LJHX)Y9(:+VeP
UZ<[1J,D/@R05S<feUB8UagP?&26((Z6\51&H(QAL#g3TG#P+DbHKKXP/1B;YS&@
.0)TCHD:+I?>;TP5P[5H@DUT9-^9\#VDY/HJR3P<Mc[?AJ_^7:NYFG=@(V>T-X,g
[BK_B@2Q5.@c,QR0Hfe0?60Y.BcWbaH<4GZcc^gR.9O6#QDQS6Z\V<HJFAcPTb2^
c2><4cT,9)7gL>c:4_,0)CZR)9:=L]#?I/534<a-)1U1:^Z?6.GcZ6@-OA_ffRe:
Z+7KD_9;0>/(;4D-[;AI/b4V=+]g+McLbd+/._+(>AgQ3-H.5dUX[[SHf_.M)HC1
C36Hc0F\6E[_[7Y=gKAI98#8XgZBX7:=Ld1EFF)8W]XJ3PX8Z)aP6,<Z3Pb/-gDI
]2aPLXB]--;cI.598R9(>];?04SFe9P6>028=)@V4CDSE[=JW&X2bb4cP;BWNF]X
WScKVCf>D,^7,2<eG<I6WQ\eN-[7GA78S]gXW,,\J[G4b]e-B9TQfC1PI<WU&>>3
AY7TbRd[F#a-V<]-Yc#ATe.20L/VO6FD9Y0-8+Ra?NY.4X9AFI+cMC?eU#_R>R?=
SUJTQa^E_WaaYEKR9AYBMH8aJ)Z,857CCF7#(IDcO4Ta?)(J(PXF5?44W^L)(GK1
B.K6a-#FF2@L_(.]O[[Le)?#@_D<eL2E<bHc-gdCS6,K]@?GU,7NUXCLURN^-HQ1
&3da_g7I+;\.,3AZ7[1[?I8^(_If488>c1^J9]O43L@gReLKIYF,FcIWdK8ga\L7
1NZK<a1J65&#Eff:eGWT,57^C6FU;CJ6/YbK_O)X]e-^]IK,8L>gEBU>a&eP#RfV
Ye)SU#?d[9RLa(R@gOA?@M[&LIT6&RD9P6bNKP_8_8#C(>.NY(L02HQ)>4B?JQ\I
cFL?g9F-?G40VL1+Y3I&V3LC.+)aZ022dg.<]A+5\PQ#Q=@TRK+#SPRT3DDGaZZ,
LHe)0YZBO2_cPAKGZ[c@)C4,UB:47G,7U(J+4,(W;D>;;TE+?T&a<-f77S9IBK-=
]1?-3=YY7Yb5UWV.K]^CeD;8F+0,G.-[NPUca#R@XAd4U+HU<&dI;Z9-Z>VH,ZDD
afE#f+7^KS116)3PJfY#WD3Z]D,#T^gKD7bL2STP4gJH\+KbZVA.JaBM\2/<5(=T
f\a\D9L=4F3;:SSA?2,^.W;PQ:aP2HJ-,bP1_Ma5=#,dK6IR-DR@,0&]W]HCLbL[
]U9(6^QXZ?KI2><4<6f;O6DIF#VfME\9-PIDGEK=MJa89>C&YXdRJN(W=,CLT^1X
:W=W^5bA9#B?79[f(Z_URGRcP_;J;PXRb-.41_^,B0^6I1E>-V?7W.cB4O=KW[JS
N6+<_IX-M#I_7YO+CQ7/E>=@K-cB&aVO:JE8=_RgVY7WQGLM\cH0OCQRMQT+8f86
TYS2F[F(HEUTUQfXMdEOc_Ba]3FbPPTD9aGI.C.]783Q1@,LIgeM<LVH59]DOG#.
)V\)Nde1I0Ua<#XUG=(RKQf4A<&N]4@Q4+<Q]WW+YGZ-#Hd&(P\,BH,WbgMaI)8R
,E/31>-:F72NM_J44B/4E@b0a:NBGLMAOQ/.?T@CdFY(^;fddPIDfV_(aS91(cKX
HI11C1e5V5(Bb99:@:E/EFTJFdU50,6>eW[XG+F\C,YAMgDZ<(g9IM&g&M4<;-6Y
+S&C@IM=7E6I1V5UGfKRZWO8@URD7e1Pf7\2a=A0A-8IY?H+1TV<Z6>5Z<2UMGY-
#H(JN8\>KWW=-XW4ZZ7:a,</<TH2?cK/ZXQBL&WS1)-d#,==)X\_BU:>e)[aR#LW
6XgAU</[L@2DH0cSP4Ge]/+PXU-+YZ=@W_NV9R0L>(=e>A)CH^L8G^1TU.:6JLJ+
ePCUe/YJ5fQaHM9B;WL@M3]gVK.P0CXX.MWA-(-1(\Tb&VN?#Y7_)>LX[O22D.V+
<[4F#_#_:bXX8Pb\6#41I\OeXP0],4<2[T-BNQc9X\LYU,??,[3Z(H/:F8=e862D
Bg-SMgW+I6:J<bbfC/P92<\dN9^>=0@BeS^?6GcZIfW9E:91DRAgHHb>?gdU;E^U
ULFY]]dKXJSJgQ3SgPa=U_-GBW<2WcF;A.]7J]I>38a(\fY&=>Md=Z5FcX7Aff/e
1=AfAWT:672T]S&/H@OY^Q]=:N=^G0(VJXNB@W?+0aeY/9X@GdY#M@g?@AbIV?Mf
VE:QGF-2],W14E@g->eLF-T3H;cA439B5fC00AB.\GI<c4:95H(a<M/1G=>4-:7:
-L/7V/OC3=/[P=7Cf90fA^[&.P&Z:Qg@0e=_O..IC].,9>/BM[1=>g[eXPNAa&-?
N8#[X<0bZMSbg;\.G49)[7HYW6-;@gV>#)(+NA[L19);ID.C7dR,AgX\J61X6a8f
gL.#1cb4_D3L@YXX<H(5PAcA_.]IQFI[a-gO,7F7/LXfKQ7:A>GLdP9\Q3cPE9GW
gKfd@<UF9FUD^47;U>SdZ/[.M[]5V]DR/EU?K7L4f39,&&K6)#9fKN^#^K[J9L=3
-C],ZHIPF023UfF._U8>:?QbZ[LMM_fI]N[@0EGOK[:EXQC-S\5=IdaWL?AN]N&#
Od_11Q@eOaUgI#C0F#XcPPIBBeZVV8V7IJbH)\,3J1__P0/X:<S^L.J9Eb:9Y0&D
2U(]-I^Z/R:#C>,V=HZ<H(D31NGKfcOA3RVBUdB\d4FWPe-OVWXC=JF)SKd&JJ0,
(bN4T71FCDY0-0eCVKK\.:cQZTVOTRR6JH8JAOF(UOUJXO(H=\-1QZ1)K-^TGD<\
]E\1FaZ38O9),G3G0DC;@UC>(1eB&28@CXKQP)-FeN0/&Z=[H/:(71CGFR<O#+[L
De2>Za=P(>Y;V7Y7Y\KPWXP+MOW-9,A\35,V.HRB-0g@eCKScbS,C?<#W^+WNVYa
.C4VaS>R_SQBLO.1f@>O\W^c?UD1=5RBfMK>#?V/?5I_Z;TBNX3?7Y)Sd\g76?;5
MX/SFg=B=a2\)Ac^MOMR4K/T(4V6de22SC^]Y5Ga2WU]NLbQ\.@J7gI=A;E-]@EIR$
`endprotected

`else

 integer OI11IO001, I1011Ol00;
 integer O1O00I001, IlOO01011, IIl1lll10;
 integer lO0IlIOl1, O1I1IO0IO, l1O0O110I, O0l1O10l0;
 integer OIOOl1I00, O0Olll0O0, l1IO10001;
 integer II010O0O1,  lI1O010l1, IOI001111;
 integer O0O1O11OO, O001O1Ol1, OO0O101O0, OlOOIO10I;
 integer lOlIIl001, I11000011, lOO0lO1O0, II1Il0l1l, l11O1O1II;
 integer Ill11O01O [0:(1<<chk_width)-1];
 integer O1111l11O [0:(1<<(chk_width-1))-1];
 reg  [chk_width-1:0] II0O00OIl;
 reg  [data_width-1:0]   IIO0O111I;
  reg [data_width-1:0] O00ll11OO [0:chk_width-1];
`endif

 wire [chk_width-1:0] O000001OO;
 reg  [data_width-1:0] IOO11O1I0;
 reg  [chk_width-1:0] OI1l0OOOI;
 reg  O1OO110OI, OO11O110l;

  function [30:0] OI100OI00;
  
    input [30:0] O01I10010;
    input [30:0] I1011Ol00;
    
    if (O01I10010) begin
      if (I1011Ol00 < 1) OI100OI00 = 1;
      else if (I1011Ol00 > 5) OI100OI00 = 1;
      else OI100OI00 = 0;
    end else begin
      if (I1011Ol00 < 1) OI100OI00 = 5;
      else if (I1011Ol00 < 3) OI100OI00 = 1;
      else OI100OI00 = 0;
    end
  endfunction


  function [30:0] OI10l11ll;
  
    input [30:0] l1Il10O1l;
    
    integer O0O1O1101, lO1lOOlI0;
    begin
      
      lO1lOOlI0 = l1Il10O1l;
      O0O1O1101 = 0;
      
      while (lO1lOOlI0 != 0) begin
        if (lO1lOOlI0 & 1)
          O0O1O1101 = O0O1O1101 + 1;
      
        lO1lOOlI0 = lO1lOOlI0 >> 1;
      end
      
      OI10l11ll = O0O1O1101;
    end
  endfunction
  

`ifndef UPF_POWER_AWARE
  initial begin
    
    OI11IO001 = 1;
    O001O1Ol1 = 5;
    lOlIIl001 = OI11IO001 << chk_width;
    l1O0O110I = 2;
    lOO0lO1O0 = lOlIIl001 >> O001O1Ol1;
    O0Olll0O0 = l1O0O110I << 4;

    for (OO0O101O0=0 ; OO0O101O0 < lOlIIl001 ; OO0O101O0=OO0O101O0+1) begin
      Ill11O01O[OO0O101O0]=-1;
    end

    II1Il0l1l = lOO0lO1O0 * l1O0O110I;
    lO0IlIOl1 = 0;
    I11000011 = O001O1Ol1 + Ill11O01O[0];
    OIOOl1I00 = O0Olll0O0 + Ill11O01O[1];

    for (IOI001111=0 ; (IOI001111 < II1Il0l1l) && (lO0IlIOl1 < data_width) ; IOI001111=IOI001111+1) begin
      O1O00I001 = IOI001111 / l1O0O110I;

      if ((IOI001111 < 4) || ((IOI001111 > 8) && (IOI001111 >= (II1Il0l1l-(l1O0O110I*l1O0O110I)))))
        O1O00I001 = O1O00I001 ^ 1;

      if (^IOI001111 ^ 1)
        O1O00I001 = lOO0lO1O0-OI11IO001-O1O00I001;

      if (lOO0lO1O0 == OI11IO001)
        O1O00I001 = 0;

      O1I1IO0IO = 0;
      O0O1O11OO = O1O00I001 << O001O1Ol1;

      if (IOI001111 < lOO0lO1O0) begin
        II010O0O1 = 0;
        if (lOO0lO1O0 > OI11IO001)
          II010O0O1 = IOI001111 % 2;

          O0l1O10l0 = OI100OI00(II010O0O1,0);

        for (OO0O101O0=O0O1O11OO ; (OO0O101O0 < (O0O1O11OO+O0Olll0O0)) && (lO0IlIOl1 < data_width) ; OO0O101O0=OO0O101O0+1) begin
          lI1O010l1 = OI10l11ll(OO0O101O0);
          if (lI1O010l1 % 2) begin
            if (O0l1O10l0 <= 0) begin
              if (lI1O010l1 > 1) begin
                Ill11O01O[OO0O101O0] = ((O1I1IO0IO < 2) && (II010O0O1 == 0))?
            			    lO0IlIOl1 ^ 1 : lO0IlIOl1;
                O1111l11O[ ((O1I1IO0IO < 2) && (II010O0O1 == 0))? lO0IlIOl1 ^ 1 : lO0IlIOl1 ] =
            			    OO0O101O0;
                lO0IlIOl1 = lO0IlIOl1 + 1;
              end

              O1I1IO0IO = O1I1IO0IO + 1;

              if (O1I1IO0IO < 8) begin
                O0l1O10l0 = OI100OI00(II010O0O1,O1I1IO0IO);

              end else begin
                OO0O101O0 = O0O1O11OO+O0Olll0O0;
              end
            end else begin

              O0l1O10l0 = O0l1O10l0 - 1;
            end
          end
        end

      end else begin
        for (OO0O101O0=O0O1O11OO+OIOOl1I00 ; (OO0O101O0 >= O0O1O11OO) && (lO0IlIOl1 < data_width) ; OO0O101O0=OO0O101O0-1) begin
          lI1O010l1 = OI10l11ll(OO0O101O0);

          if (lI1O010l1 %2) begin
            if ((lI1O010l1>1) && (Ill11O01O[OO0O101O0] < 0)) begin
              Ill11O01O[OO0O101O0] = lO0IlIOl1;
              O1111l11O[lO0IlIOl1] = OO0O101O0;
              lO0IlIOl1 = lO0IlIOl1 + 1;
            end
          end
        end
      end
    end

    l1IO10001 = OI11IO001 - 1;

    for (OO0O101O0=0 ; OO0O101O0<chk_width ; OO0O101O0=OO0O101O0+1) begin
      IIO0O111I = {data_width{1'b0}};
      for (lO0IlIOl1=0 ; lO0IlIOl1 < data_width ; lO0IlIOl1=lO0IlIOl1+1) begin
        if (O1111l11O[lO0IlIOl1] & (1 << OO0O101O0)) begin
          IIO0O111I[lO0IlIOl1] = 1'b1;
        end
      end
      O00ll11OO[OO0O101O0] = IIO0O111I;
    end

    l11O1O1II = l1IO10001 - 1;

    for (OO0O101O0=0 ; OO0O101O0<chk_width ; OO0O101O0=OO0O101O0+1) begin
      Ill11O01O[OI11IO001<<OO0O101O0] = data_width+OO0O101O0;
    end

    OlOOIO10I = l1IO10001;
  end
`endif
  
  
  always @ (O1110110) begin : DW_IO010IO10
    
    for (I1011Ol00=0 ; I1011Ol00 < chk_width ; I1011Ol00=I1011Ol00+1) begin
      II0O00OIl[I1011Ol00] = ^(O1110110 & O00ll11OO[I1011Ol00]) ^
				((I1011Ol00<2)||(I1011Ol00>3))? 1'b0 : 1'b1;
    end
  end // DW_IO010IO10
  
  assign O000001OO = II0O00OIl ^ OOOl1101;

  always @ (O000001OO) begin : DW_I10l100O1
    if (rw_mode[0] != 1'b1) begin
      if ((^(O000001OO ^ O000001OO) !== 1'b0)) begin
        OI1l0OOOI = {chk_width{1'bx}};
        IOO11O1I0 = {data_width{1'bx}};
        O1OO110OI = 1'bx;
        OO11O110l = 1'bx;
      end else begin
        OI1l0OOOI = {chk_width{1'b0}};
        IOO11O1I0 = {data_width{1'b0}};
        if (O000001OO === {chk_width{1'b0}}) begin
          O1OO110OI = 1'b0;
          OO11O110l = 1'b0;
        end else if (Ill11O01O[O000001OO+OlOOIO10I] == l11O1O1II) begin
          O1OO110OI = 1'b1;
          OO11O110l = 1'b1;
        end else begin
          O1OO110OI = 1'b1;
          OO11O110l = 1'b0;
          if (Ill11O01O[O000001OO+OlOOIO10I] < data_width)
            IOO11O1I0[Ill11O01O[O000001OO+OlOOIO10I]] = 1'b1;
          else
            OI1l0OOOI[Ill11O01O[O000001OO+OlOOIO10I]-data_width] = 1'b1;
        end
      end
    end
  end // DW_I10l100O1

  assign O1110110 = (rw_mode == 1) ? O1II11O1 : OII1OOl0;
  assign OOOl1101  = (rw_mode == 1) ? O01I11IO  : I01OO00O;

  assign O001IOl1 = O1110110;
  assign I101OO10  = II0O00OIl;
reg   [(data_width+chk_width)-1 : 0]     O0110101;
reg   [(data_width+chk_width)-1 : 0]     OI0000O0 [0 : ((stages-1+out_reg < 1)? 0 : (stages+out_reg-2))];




generate
  if (rst_mode==0) begin
    always @ (posedge clk or negedge rst_n) begin : PROC_pl_in_registers_wr_mode
      integer lO01IO0O;

      if (rst_n === 1'b0) begin
        O0110101 <= {(data_width+chk_width){1'b0}};
      end else if (rst_n === 1'b1) begin
        if (OOOOlIO1 === 1'b1)
          O0110101<= {O00IlO0I, IOOI1O00};
        else if (OOOOlIO1 !== 1'b0)
          O0110101 <= ((O0110101 ^ {O00IlO0I, IOOI1O00}) & {(data_width+chk_width){1'bx}}) ^ O0110101;
      end else begin
        O0110101 <= {(data_width+chk_width){1'bx}};
      end
    end
  end else begin
    always @ (posedge clk) begin : PROC_pl_in_registers_wr_mode
      integer lO01IO0O;

      if (rst_n === 1'b0) begin
        O0110101 <= {(data_width+chk_width){1'b0}};
      end else if (rst_n === 1'b1) begin
        if (OOOOlIO1 === 1'b1)
          O0110101<= {O00IlO0I, IOOI1O00};
        else if (OOOOlIO1 !== 1'b0)
          O0110101 <= ((O0110101 ^ {O00IlO0I, IOOI1O00}) & {(data_width+chk_width){1'bx}}) ^ O0110101;
      end else begin
        O0110101 <= {(data_width+chk_width){1'bx}};
      end
    end
  end
endgenerate


  assign {O1II11O1, O01I11IO} = (in_reg == 0)? {O00IlO0I, IOOI1O00} : O0110101;




generate
  if (rst_mode==0) begin
    always @ (posedge clk or negedge rst_n) begin : PROC_pl_registers_wr_mode
      integer lO01IO0O;

      if (rst_n === 1'b0) begin
        for (lO01IO0O=0 ; lO01IO0O <= ((stages-1+out_reg < 1)? 0 : (stages+out_reg-2)) ; lO01IO0O=lO01IO0O+1) begin
          OI0000O0[lO01IO0O] <= {(data_width+chk_width){1'b0}};
        end
      end else if (rst_n === 1'b1) begin
        for (lO01IO0O=0 ; lO01IO0O <= ((stages-1+out_reg < 1)? 0 : (stages+out_reg-2)) ; lO01IO0O=lO01IO0O+1) begin
          if (O10l0O0O[lO01IO0O] === 1'b1)
            OI0000O0[lO01IO0O] <= (lO01IO0O == 0)? {O001IOl1, I101OO10} : OI0000O0[lO01IO0O-1];
          else if (O10l0O0O[lO01IO0O] !== 1'b0)
            OI0000O0[lO01IO0O] <= ((OI0000O0[lO01IO0O] ^ ((lO01IO0O == 0)? {O001IOl1, I101OO10} : OI0000O0[lO01IO0O-1]))
          		      & {(data_width+chk_width){1'bx}}) ^ OI0000O0[lO01IO0O];
        end
      end else begin
        for (lO01IO0O=0 ; lO01IO0O <= ((stages-1+out_reg < 1)? 0 : (stages+out_reg-2)) ; lO01IO0O=lO01IO0O+1) begin
          OI0000O0[lO01IO0O] <= {(data_width+chk_width){1'bx}};
        end
      end
    end
  end else begin
    always @ (posedge clk) begin : PROC_pl_registers_wr_mode
      integer lO01IO0O;

      if (rst_n === 1'b0) begin
        for (lO01IO0O=0 ; lO01IO0O <= ((stages-1+out_reg < 1)? 0 : (stages+out_reg-2)) ; lO01IO0O=lO01IO0O+1) begin
          OI0000O0[lO01IO0O] <= {(data_width+chk_width){1'b0}};
        end
      end else if (rst_n === 1'b1) begin
        for (lO01IO0O=0 ; lO01IO0O <= ((stages-1+out_reg < 1)? 0 : (stages+out_reg-2)) ; lO01IO0O=lO01IO0O+1) begin
          if (O10l0O0O[lO01IO0O] === 1'b1)
            OI0000O0[lO01IO0O] <= (lO01IO0O == 0)? {O001IOl1, I101OO10} : OI0000O0[lO01IO0O-1];
          else if (O10l0O0O[lO01IO0O] !== 1'b0)
            OI0000O0[lO01IO0O] <= ((OI0000O0[lO01IO0O] ^ ((lO01IO0O == 0)? {O001IOl1, I101OO10} : OI0000O0[lO01IO0O-1]))
          		      & {(data_width+chk_width){1'bx}}) ^ OI0000O0[lO01IO0O];
        end
      end else begin
        for (lO01IO0O=0 ; lO01IO0O <= ((stages-1+out_reg < 1)? 0 : (stages+out_reg-2)) ; lO01IO0O=lO01IO0O+1) begin
          OI0000O0[lO01IO0O] <= {(data_width+chk_width){1'bx}};
        end
      end
    end
  end
endgenerate

  assign {I01ll0OO, Ol0I0lO1} = (stages+out_reg == 1)? {O001IOl1, I101OO10} : OI0000O0[((stages-1+out_reg < 1)? 0 : (stages+out_reg-2))];


  assign I10IO1Ol      = O1110110 ^ IOO11O1I0;
  assign OI1l0l00       = OOOl1101 ^ OI1l0OOOI;
  assign O010010O      = O000001OO;
  assign lO00l00I   = O1OO110OI;
  assign I0O11O11 = OO11O110l;
reg   [(data_width+chk_width)-1 : 0]     l1l0O01I;
reg   [(data_width+(chk_width*2)+2)-1 : 0]     OIOOl10l [0 : ((stages-1+out_reg < 1)? 0 : (stages+out_reg-2))];




generate
  if (rst_mode==0) begin
    always @ (posedge clk or negedge rst_n) begin : PROC_pl_in_registers_rd_mode
      integer lO01IO0O;

      if (rst_n === 1'b0) begin
        l1l0O01I <= {(data_width+chk_width){1'b0}};
      end else if (rst_n === 1'b1) begin
        if (OOOOlIO1 === 1'b1)
          l1l0O01I<= {O00IlO0I, IOOI1O00};
        else if (OOOOlIO1 !== 1'b0)
          l1l0O01I <= ((l1l0O01I ^ {O00IlO0I, IOOI1O00}) & {(data_width+chk_width){1'bx}}) ^ l1l0O01I;
      end else begin
        l1l0O01I <= {(data_width+chk_width){1'bx}};
      end
    end
  end else begin
    always @ (posedge clk) begin : PROC_pl_in_registers_rd_mode
      integer lO01IO0O;

      if (rst_n === 1'b0) begin
        l1l0O01I <= {(data_width+chk_width){1'b0}};
      end else if (rst_n === 1'b1) begin
        if (OOOOlIO1 === 1'b1)
          l1l0O01I<= {O00IlO0I, IOOI1O00};
        else if (OOOOlIO1 !== 1'b0)
          l1l0O01I <= ((l1l0O01I ^ {O00IlO0I, IOOI1O00}) & {(data_width+chk_width){1'bx}}) ^ l1l0O01I;
      end else begin
        l1l0O01I <= {(data_width+chk_width){1'bx}};
      end
    end
  end
endgenerate


  assign {OII1OOl0, I01OO00O} = (in_reg == 0)? {O00IlO0I, IOOI1O00} : l1l0O01I;




generate
  if (rst_mode==0) begin
    always @ (posedge clk or negedge rst_n) begin : PROC_pl_registers_rd_mode
      integer lO01IO0O;

      if (rst_n === 1'b0) begin
        for (lO01IO0O=0 ; lO01IO0O <= ((stages-1+out_reg < 1)? 0 : (stages+out_reg-2)) ; lO01IO0O=lO01IO0O+1) begin
          OIOOl10l[lO01IO0O] <= {(data_width+(chk_width*2)+2){1'b0}};
        end
      end else if (rst_n === 1'b1) begin
        for (lO01IO0O=0 ; lO01IO0O <= ((stages-1+out_reg < 1)? 0 : (stages+out_reg-2)) ; lO01IO0O=lO01IO0O+1) begin
          if (O10l0O0O[lO01IO0O] === 1'b1)
            OIOOl10l[lO01IO0O] <= (lO01IO0O == 0)? {I10IO1Ol, OI1l0l00, O010010O, lO00l00I, I0O11O11} : OIOOl10l[lO01IO0O-1];
          else if (O10l0O0O[lO01IO0O] !== 1'b0)
            OIOOl10l[lO01IO0O] <= ((OIOOl10l[lO01IO0O] ^ ((lO01IO0O == 0)? {I10IO1Ol, OI1l0l00, O010010O, lO00l00I, I0O11O11} : OIOOl10l[lO01IO0O-1]))
          		      & {(data_width+(chk_width*2)+2){1'bx}}) ^ OIOOl10l[lO01IO0O];
        end
      end else begin
        for (lO01IO0O=0 ; lO01IO0O <= ((stages-1+out_reg < 1)? 0 : (stages+out_reg-2)) ; lO01IO0O=lO01IO0O+1) begin
          OIOOl10l[lO01IO0O] <= {(data_width+(chk_width*2)+2){1'bx}};
        end
      end
    end
  end else begin
    always @ (posedge clk) begin : PROC_pl_registers_rd_mode
      integer lO01IO0O;

      if (rst_n === 1'b0) begin
        for (lO01IO0O=0 ; lO01IO0O <= ((stages-1+out_reg < 1)? 0 : (stages+out_reg-2)) ; lO01IO0O=lO01IO0O+1) begin
          OIOOl10l[lO01IO0O] <= {(data_width+(chk_width*2)+2){1'b0}};
        end
      end else if (rst_n === 1'b1) begin
        for (lO01IO0O=0 ; lO01IO0O <= ((stages-1+out_reg < 1)? 0 : (stages+out_reg-2)) ; lO01IO0O=lO01IO0O+1) begin
          if (O10l0O0O[lO01IO0O] === 1'b1)
            OIOOl10l[lO01IO0O] <= (lO01IO0O == 0)? {I10IO1Ol, OI1l0l00, O010010O, lO00l00I, I0O11O11} : OIOOl10l[lO01IO0O-1];
          else if (O10l0O0O[lO01IO0O] !== 1'b0)
            OIOOl10l[lO01IO0O] <= ((OIOOl10l[lO01IO0O] ^ ((lO01IO0O == 0)? {I10IO1Ol, OI1l0l00, O010010O, lO00l00I, I0O11O11} : OIOOl10l[lO01IO0O-1]))
          		      & {(data_width+(chk_width*2)+2){1'bx}}) ^ OIOOl10l[lO01IO0O];
        end
      end else begin
        for (lO01IO0O=0 ; lO01IO0O <= ((stages-1+out_reg < 1)? 0 : (stages+out_reg-2)) ; lO01IO0O=lO01IO0O+1) begin
          OIOOl10l[lO01IO0O] <= {(data_width+(chk_width*2)+2){1'bx}};
        end
      end
    end
  end
endgenerate

  assign {O0llOO1O, IO1lO0l0, II000OOO, I10O110O, IO100O1I} = (stages+out_reg == 1)? {I10IO1Ol, OI1l0l00, O010010O, lO00l00I, I0O11O11} : OIOOl10l[((stages-1+out_reg < 1)? 0 : (stages+out_reg-2))];



reg   [id_width-1 : 0]     lO00O01l [0 : ((in_reg+stages-1+out_reg < 1)? 0 : (in_reg+stages+out_reg-2))];





generate
  if (rst_mode==0) begin
    always @ (posedge clk or negedge rst_n) begin : PROC_pl_registers_id
      integer lO01IO0O;

      if (rst_n === 1'b0) begin
        for (lO01IO0O=0 ; lO01IO0O <= ((in_reg+stages-1+out_reg < 1)? 0 : (in_reg+stages+out_reg-2)) ; lO01IO0O=lO01IO0O+1) begin
          lO00O01l[lO01IO0O] <= {id_width{1'b0}};
        end
      end else if (rst_n === 1'b1) begin
        for (lO01IO0O=0 ; lO01IO0O <= ((in_reg+stages-1+out_reg < 1)? 0 : (in_reg+stages+out_reg-2)) ; lO01IO0O=lO01IO0O+1) begin
          if (O00l0I1O[lO01IO0O] === 1'b1)
            lO00O01l[lO01IO0O] <= (lO01IO0O == 0)? O10O0O10 : lO00O01l[lO01IO0O-1];
          else if (O00l0I1O[lO01IO0O] !== 1'b0)
            lO00O01l[lO01IO0O] <= ((lO00O01l[lO01IO0O] ^ ((lO01IO0O == 0)? O10O0O10 : lO00O01l[lO01IO0O-1]))
          		      & {id_width{1'bx}}) ^ lO00O01l[lO01IO0O];
        end
      end else begin
        for (lO01IO0O=0 ; lO01IO0O <= ((in_reg+stages-1+out_reg < 1)? 0 : (in_reg+stages+out_reg-2)) ; lO01IO0O=lO01IO0O+1) begin
          lO00O01l[lO01IO0O] <= {id_width{1'bx}};
        end
      end
    end
  end else begin
    always @ (posedge clk) begin : PROC_pl_registers_id
      integer lO01IO0O;

      if (rst_n === 1'b0) begin
        for (lO01IO0O=0 ; lO01IO0O <= ((in_reg+stages-1+out_reg < 1)? 0 : (in_reg+stages+out_reg-2)) ; lO01IO0O=lO01IO0O+1) begin
          lO00O01l[lO01IO0O] <= {id_width{1'b0}};
        end
      end else if (rst_n === 1'b1) begin
        for (lO01IO0O=0 ; lO01IO0O <= ((in_reg+stages-1+out_reg < 1)? 0 : (in_reg+stages+out_reg-2)) ; lO01IO0O=lO01IO0O+1) begin
          if (O00l0I1O[lO01IO0O] === 1'b1)
            lO00O01l[lO01IO0O] <= (lO01IO0O == 0)? O10O0O10 : lO00O01l[lO01IO0O-1];
          else if (O00l0I1O[lO01IO0O] !== 1'b0)
            lO00O01l[lO01IO0O] <= ((lO00O01l[lO01IO0O] ^ ((lO01IO0O == 0)? O10O0O10 : lO00O01l[lO01IO0O-1]))
          		      & {id_width{1'bx}}) ^ lO00O01l[lO01IO0O];
        end
      end else begin
        for (lO01IO0O=0 ; lO01IO0O <= ((in_reg+stages-1+out_reg < 1)? 0 : (in_reg+stages+out_reg-2)) ; lO01IO0O=lO01IO0O+1) begin
          lO00O01l[lO01IO0O] <= {id_width{1'bx}};
        end
      end
    end
  end
endgenerate

  assign OlI0OIOI = (in_reg+stages+out_reg == 1)? O10O0O10 : lO00O01l[((in_reg+stages-1+out_reg < 1)? 0 : (in_reg+stages+out_reg-2))];




generate
  if (rst_mode==0) begin : DW_II0lOI0l
    DW_lp_pipe_mgr #((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1), id_width) U_PIPE_MGR (
                     .clk(clk),
                     .rst_n(rst_n),
                     .init_n(1'b1),
                     .launch(O0lI0O1O),
                     .launch_id(O10O0O10),
                     .accept_n(I1O0O1O1),
                     .arrive(I1O001OO),
                     .arrive_id(IOO11O11),
                     .pipe_en_bus(O00101I1),
                     .pipe_full(O010lO10),
                     .pipe_ovf(OOO1O1OO),
                     .push_out_n(OO1lIIO1),
                     .pipe_census(O1O1IlO0)
                     );
  end else begin : DW_I01OI0I1
    DW_lp_pipe_mgr #((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1), id_width) U_PIPE_MGR (
                     .clk(clk),
                     .rst_n(1'b1),
                     .init_n(rst_n),
                     .launch(O0lI0O1O),
                     .launch_id(O10O0O10),
                     .accept_n(I1O0O1O1),
                     .arrive(I1O001OO),
                     .arrive_id(IOO11O11),
                     .pipe_en_bus(O00101I1),
                     .pipe_full(O010lO10),
                     .pipe_ovf(OOO1O1OO),
                     .push_out_n(OO1lIIO1),
                     .pipe_census(O1O1IlO0)
                     );
  end
endgenerate

assign O0O1011l         = O0lI0O1O;
assign l0OOl11l      = O10O0O10;
assign IIO10010    = {(((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1){1'b0}};
assign l1I101lO      = I1O0O1O1;
assign OO1IOO00  = l1I101lO && O0O1011l;
assign I0IOIl1O     = ~(~I1O0O1O1 && O0lI0O1O);
assign OOO0Ol0O    = {(((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>256)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4096)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16384)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32768)?16:15):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8192)?14:13)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>1024)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2048)?12:11):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>512)?10:9))):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>64)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>128)?8:7):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32)?6:5)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8)?4:3):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2)?2:1))))){1'b0}};


assign arrive           = no_pm ? 1'b0 : ((in_reg+stages+out_reg) > 1) ? I1O001OO : O0O1011l;
assign arrive_id        = ((in_reg+stages+out_reg) > 1) ? (no_pm ? OlI0OIOI          : IOO11O11  ) : l0OOl11l;
assign O00l0I1O  = ((in_reg+stages+out_reg) > 1) ? (no_pm ? {(((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1){launch}} : O00101I1) : IIO10010;
assign pipe_full        = no_pm ? 1'b0 : ((in_reg+stages+out_reg) > 1) ? O010lO10 : l1I101lO;
assign pipe_ovf         = no_pm ? 1'b0 : ((in_reg+stages+out_reg) > 1) ? OOO1O1OO : I10l1lO0;
assign push_out_n       = no_pm ? 1'b0 : ((in_reg+stages+out_reg) > 1) ? OO1lIIO1 : I0IOIl1O;
assign pipe_census      = no_pm ? {(((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>256)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4096)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16384)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32768)?16:15):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8192)?14:13)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>1024)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2048)?12:11):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>512)?10:9))):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>16)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>64)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>128)?8:7):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>32)?6:5)):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>4)?((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>8)?4:3):((((((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1)+1)>2)?2:1))))){1'b0}} : ((in_reg+stages+out_reg) > 1) ? O1O1IlO0 : OOO0Ol0O;

assign OOOOlIO1 = O00l0I1O[0];

  always @(O00l0I1O) begin : out_en_bus_in_reg1_PROC
    integer lO01IO0O;

    if  (in_reg == 1) begin
      O10l0O0O[0] = 1'b0;
      for (lO01IO0O=1; lO01IO0O<(((in_reg+(stages-1)+out_reg) >= 1) ? (in_reg+(stages-1)+out_reg) : 1); lO01IO0O=lO01IO0O+1) begin
        O10l0O0O[lO01IO0O-1] = O00l0I1O[lO01IO0O];
      end
    end else begin
      O10l0O0O = O00l0I1O;
    end
  end


generate
  if (rst_mode==0) begin : DW_O11011I1
    always @ (posedge clk or negedge rst_n) begin : posedge_registers_PROC
      if (rst_n === 1'b0) begin
        I10l1lO0     <= 1'b0;
      end else if (rst_n === 1'b1) begin
        I10l1lO0     <= OO1IOO00;
      end else begin
        I10l1lO0     <= 1'bx;
      end
    end
  end else begin : DW_I0O1O01I
    always @ (posedge clk) begin : posedge_registers_PROC
      if (rst_n === 1'b0) begin
        I10l1lO0     <= 1'b0;
      end else if (rst_n === 1'b1) begin
        I10l1lO0     <= OO1IOO00;
      end else begin
        I10l1lO0     <= 1'bx;
      end
    end
  end
endgenerate


  assign dataout      = ((in_reg==0) && (stages==1) && (out_reg==0) && (no_pm == 0) && (launch==1'b0)) ? 
                          {data_width{1'bx}} : 
                          (rw_mode==0) ? O0llOO1O: I01ll0OO;

  assign chkout       = ((in_reg==0) && (stages==1) && (out_reg==0) && (no_pm == 0) && (launch==1'b0)) ? 
                          {chk_width{1'bx}} : 
                          (rw_mode==0) ? IO1lO0l0: Ol0I0lO1;

  assign syndout      = ((in_reg==0) && (stages==1) && (out_reg==0) && (no_pm == 0) && (launch==1'b0)) ? 
                          {chk_width{1'bx}} : 
                          (rw_mode==0) ? II000OOO: {chk_width{1'b0}};

  assign err_detect   = ((in_reg==0) && (stages==1) && (out_reg==0) && (no_pm == 0) && (launch==1'b0)) ? 
                          1'bx : 
                          (rw_mode==0) ? I10O110O: 1'b0;

  assign err_multiple = ((in_reg==0) && (stages==1) && (out_reg==0) && (no_pm == 0) && (launch==1'b0)) ? 
                          1'bx : 
                          (rw_mode==0) ? IO100O1I: 1'b0;

  //-------------------------------------------------------------------------
  // Parameter legality check
  //-------------------------------------------------------------------------
  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
  
    if ( (data_width < 8) || (data_width > 8178) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter data_width (legal range: 8 to 8178)",
	data_width );
    end
  
    if ( (chk_width < 5) || (chk_width > 14) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter chk_width (legal range: 5 to 14)",
	chk_width );
    end
  
    if ( (rw_mode < 0) || (rw_mode > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter rw_mode (legal range: 0 to 1)",
	rw_mode );
    end
  
    if ( (op_iso_mode < 0) || (op_iso_mode > 4) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter op_iso_mode (legal range: 0 to 4)",
	op_iso_mode );
    end
  
    if ( (id_width < 1) || (id_width > 1024) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter id_width (legal range: 1 to 1024)",
	id_width );
    end
  
    if ( (stages < 1) || (stages > 1022) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter stages (legal range: 1 to 1022)",
	stages );
    end
  
    if ( (in_reg < 0) || (in_reg > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter in_reg (legal range: 0 to 1)",
	in_reg );
    end
  
    if ( (out_reg < 0) || (out_reg > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter out_reg (legal range: 0 to 1)",
	out_reg );
    end
  
    if ( (no_pm < 0) || (no_pm > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter no_pm (legal range: 0 to 1)",
	no_pm );
    end
  
    if ( (rst_mode < 0) || (rst_mode > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter rst_mode (legal range: 0 to 1)",
	rst_mode );
    end
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 


  
  always @ (clk) begin : monitor_clk 
    if ( (clk !== 1'b0) && (clk !== 1'b1) && ($time > 0) )
      $display( "WARNING: %m :\n  at time = %t, detected unknown value, %b, on clk input.",
                $time, clk );
    end // monitor_clk 

// synopsys translate_on
endmodule

////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 2000  - 2018 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Rick Kelly        07/28/2000
//
// VERSION:   Verilog Simulation Model for DW02_tree
//
// DesignWare_version: 7a05aa12
// DesignWare_release: O-2018.06-DWBB_201806.3
//
////////////////////////////////////////////////////////////////////////////////

//-----------------------------------------------------------------------------------
//
// ABSTRACT:  Wallace Tree Summer with Carry Save output
//
// MODIFIED:
//            Aamir Farooqui 7/11/02
//            Corrected parameter checking, simplied sim model, and X_processing
//
//            Alex Tenca  6/20/2011
//            Introduced a new parameter (verif_en) that allows the use of random 
//            CS output values, instead of the fixed CS representation used in 
//            the original model. By "fixed" we mean: the CS output is always the
//            the same for the same input values. By using a randomization process,
//            the CS output for a given input value will change with time. The CS
//            output takes one of the possible CS representations that correspond
//            to the binary output of the DW02_tree. For example: for binary (0110)
//            sometimes the output is (0101,0001), sometimes (0110,0000), sometimes
//            (1100,1010), etc. These are all valid CS representations of 6.
//            Options for the CS output behavior are (based on verif_en parameter):
//              0 - old behavior (fixed CS representation)
//              1 - fully random CS output
//
//------------------------------------------------------------------------------
//

module DW02_tree( INPUT, OUT0, OUT1 );

// parameters
parameter integer num_inputs = 8;
parameter integer input_width = 8;
parameter integer verif_en = 1;


//-----------------------------------------------------------------------------
// ports
input [num_inputs*input_width-1 : 0]	INPUT;
output [input_width-1:0]		OUT0, OUT1;

//-----------------------------------------------------------------------------
// synopsys translate_off
reg    [input_width-1:0]		OII0OOOI, O001l0I0;
wire   [input_width-1:0]                out0_rnd_cs_full, out1_rnd_cs_full;
wire   [input_width-1:0]                out_fixed_cs,out_rnd_cs_full;

//-----------------------------------------------------------------------------
  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
    
    if (num_inputs < 1) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter num_inputs (lower bound: 1)",
	num_inputs );
    end
    
    if (input_width < 1) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter input_width (lower bound: 1)",
	input_width );
    end
    
    if ( (verif_en < 0) || (verif_en > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter verif_en (legal range: 0 to 1)",
	verif_en );
    end
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 


initial begin : verif_en_warning
  if (verif_en < 1)
    $display("The simulation coverage of CS values is not the best when verif_en=%d !\nThe recommended value is 1.",verif_en);
end // verif_en_warning

//-----------------------------------------------------------------------------


`protected
f4U::0(5#KUTK?&[UYC5P+T][GNb:H_Aa&^W&6fIS)CPb^&K1GBN5).=6Q^X]\bD
8-A=(eINaR,A7;FQ-D5g(A:TEg>W(,B.R#f,<]\TQTR</04KBC3/+M)OMUBSF#MK
\f1C9N&V<VaGO7,F0IHT)adNE&L)N.R(K041B2-Y9I_0M?AV.cH9F#b6HZ&LR#a3
-d]H+##cOB?1Se3^,:SFZK,7fM]XHY8f;109c)U@Lf<&9>VgFVacgY31#&a;.<H/
>9\PON;ZD<2Y#Z]2AW;f3_#f@#]VSN0T;UQKUO;dU,4E#(BJ2,C:1e=6MR1<X@2V
#>8EEHCe8#+5ZgATBgfg&/F70Y6PYAPVYI9gZR[_FAM^)9^a3fWV:&5,B4ND;(A,
9#?,?4Gf<(I5.6F4XE41?X:OPLeR:_-Bc=6(\I1F^Ca=We6YcP7DCR)WF0-9D#fA
gU>]Y_7QV_+,5??:+>IPU@_)Q\#=:Pd>S9U@>1FBUOQ)&g8G>5U#QQ\bN6LLWG(W
&X[d[dD0+9/Jeg34PB^);G\c4NP40)-?DW>@6(e_6R1cUM]3d=LNf+R6G54gf[G2
QLJ_RFWJ&AOW&])G@;<T2NE63?OEYKUQKR=TRf1-AcBQ<7.I^=Vc;SARe>:9I)BS
=96KH6&d@,gN/Q42?@XdDCNVP[<[\-QF/D.J-8Z5NIAQB7J;4;g>(eBIb1KBd)d/
@QAc0YD-I+f@KDVQFWILAJ9dYEe\+:7T7[J.@5H8/.Q77W+>GZ<2HQ19KD]CRB=I
a##IU)aRR9-WQ.@TIgc)^M6@4XI/,(J5AJ0R?;O=AZ1eCNECX&2JCO2&_64eg0:=
VM_+61D2W_UW,/JV\2OY[b;#/T-9;#^/79ZD-g(OWB&>P@UG=J[Ngb7/b57.S_YS
1V5ANaXDK#H,JUQ8Ne@1^?V-^68.I6,#9S+48&5DL90.\.D(1K=#<Q#g/9^1]2a6
J>5bY3XPW[4-e;Q<FN/K/N[1V7JMPUMQ]I.69]IME5)D8]P&ITGA=N2Y@7cKC0Wd
#VKT--W:/gOagV?C#;T#4>LXe7f(L0aCVE?89BGX;UcHRDfeF<aE^eL_\dPYOVJ[
\Hb8PEQ)U.:5QYWgc]C\+#7PO_U0bNP,c6baaPX8-X.ZV4]PK]LW^eCHC2eYa-58
V#E6-Z[VWbNZA^RN<>@8IE,R)8Q(d0eE\Vbb2,KWY2(BB3X_eb,CY#V5<QT42[f<
e^FQJMZOS>f58fW7+:N=&@13;JIQ8I4[;&JgQE,XeVPaJGc+R^T;I7N_eg69I7G[
Rd\IFc&UEH4T99&X2_3-_\:9LX?G6#&1U5dPY?MA3IE2).6cP]3)5XH:WdJ.P9>b
R=Q+\@5XNTM9]+)PL-H71V3\&5)_RFP)WUBKb1M)fSE:D8Oa-5IVAe9C8^Ha/V(H
aBceW12a>3]++B(+f/QO@WcO2-88cgJ#Y_F_0-JKeK696U?OePCT-:e:4JE:G+BF
7Bg6QcI/RWcZSK<R<OOQEX?KY&(S[8fc_Y\)0K3\71<]>O#9MHSLNZ:+SG^3IfUW
B:_):P9:^M6Zf\\:NJ=N1E=M0W,=NP5JLVc\MN2.He8E<]d_<RFPX,(@^;/TW7L/
@SL#)81fdE3W)?C\8BM.FU])YR1#&9[b],+E#S?+Jc1I[IXYP/,eLTDdD4Udf&@L
YY+.[L-fN71LX4VM@a]9DRf&,6^YZP_^-J(Y-cI:Gc3L)]:B,19Z<N56d+TY.[T_
V0Jf]5[3#2LG#3&U/J;gTHWL>R^I1d1(Jc?X6Z#HK)TNP]L:9_2@BgQ+WP(Jad=+
5(cba^b4J-,bXO8OVC+CYP]NdSKYVZH<9(bMVg:2;K4O@4LdRBVB;RZ=0UAScCQC
0fY=ROR<[<]e&-DSKW&2:-;;KGGaD8,O(TVK-:_WV0U&]P:;K#(NM<L^;_K6[SEX
FbgV[84e6c&JfQB]cZU;HMB8MOM#M<-=V6C84F<aVCYLX@c9Z4-;a<]C#)#.</@M
P<H^^I02.T8,e^G5Jg\+_9YRR6+HfA.d_FR6HT[]?<dgE41O=fZ<VfOK6]YL\](6
eCT,(=EV;(b1O1RC[NY(P\<5d:TZT=OGYJb6e^KSU12e_L]N>XSG#)8L#<EOe,A=
c/Y=OSb&IV-+TBYXEJOcDFI0P70X_H_]C/eTT>M?dHfIXRK:TbSUB#c6Ee\I-,KT
M2H_N_=f9EPRBO.e08Mga:67NTDZU]PG5:R]>NTcM7>T8C^W07:-ED[P@.0(7dIR
PW/LH3@d(0\,;\I.#(GQ?M,da15;3,a;CG)R+BRg+@5XUQgI59@DK6@]+^I,=VVO
H&NeD_NO3F85+a6\^T_)1D>##f)L<A4;3B+5QDJY_=@8/O]Gg?<fT?[B7IXQC54M
].&ccWbR8bOb\c(9ZgfH3PaH;#[U]#,,8)8CP4+g:;K\F=4SdUIO770.JR[ffZAP
F;FJ9,?V4C(1=W:gW/#L@+6Db?Q+[e9RF;9W/MC5]KKc<^B6J.f-Wdd=20AOQE;c
^?/1Z#.(Z,G_d@Y_SHdQMJ)&MO_7)>(G;LO@3:f3=@DU^3MS+]-[M<P53?Y4/La/
NfHE]<XA5<EO0NbQcS#<dgDOFSV_11VS)Y1HS=.)&\:GTg=5Q]R8?->,0XZ9cgXX
^3eJ.BGZ@SW71d_P</a4ZH=7]#<C(FF^?TR/NBLBM<gW\;LN31;_d-_b#]c:7H0.
-&W,NBTgHc+2K^H-R;]f,cB73RE,;-]---UCR2Z4X/82.:bMIf1^.L]3AV0GTNc&
&_(KD<PM=fTg)0WY_=6#Z]^-0<N,[6.;;5\ZG,API=_X:10-/ed&WTaR]f?Ag[1\
9X@:](.dfU4[[5_b7d^I\U2O+S([&3))KDe@g&>55Y9EP+AI/GZMX[<VAXB1N.<Z
.03?0CUIRg[TF74517FYO)^(e+784e\d\-+0La71@B],,Q/SJ6[+D?1V;,TU+E4a
CDQ1+LXOSKJ<4V^>YZ#OE5,@//T&Y-7U@d.0?&8QGMZeT250Z/fSbJ&W9PMSXD&&
X<[4QTD-+<cc7#K1]Ad#Y>.LO_bDG(?<C.M0>V+&5FA2^:F;=U.SaI[16N&bNXJB
)ZP&a]JRS,gF13,DXG/KgF>-+>BA//C6V3Tcf,g:49^E[MZ+A__O@78LFb?9M?R2
-f#[,O]aMe+<[9NGE6-)acJ2\_02NA;7g9W]\E.F^e;\RI:GL6M.<:SE9GVX.0Sg
O+,]9.KLLGG4b-?\+80dPW3cSZZT]1a);S#>;QE:=4OTNG-\&+_6YP0=S2Q-9dcT
R;@V#25LaZJ<E7\0_#YS,#I@>?N1<f@ZN+3dT2M[Y)TE/.VE\?[IMIJfTZ5=4&O=
V[O7C2T95c0]cKKZfSISD7R-0/;=1TR3<B68[=;cMGL/,@G>Vg>-YZTK#bSf[6E:
fC-[IE@M,A09VgKYbgI,8-[+??UI6A1[IU&9_/a8D2F/3,2FeN4GQ(dUKI[GbGFC
><KI#S,[eHS,YZf?#dKc#F2Q?ZE_<d-2P6_M=ZUX1?OQfN:e]<T4J61fP-^>T13Q
U))>V#R(NJdg6B+dIaSV_#A(EW?<D;6X/D_f>^;F/dH/g#Ne4MJd[>JL:Yg8.&Z8
A3eVHTC=(V9E36\=;G?,[3::4/deVU]K6_Yg>2A+U-<R)9FD7G<PBS,IN;Qa3SNU
GD?E>IF62QY/JH/83bJ[B1__f_X<>4FW9aC;aV]7A;dWCUZeeBgcV:Y=/b&(QCW,
ZBLb&+\S1ZTf.J->c7N@&TUD/;KW^,5@IHAebJ#,OVaKH>2[):U?2.eMLW2OWRg2
=2-I68=1YPMP940:=.U.IBW]]&-]J;1C;7(:C3BD154ZG>?9VACNNNP(83=M^Sd5
XOM,CZ?;8K::-9+[.8cBQUZ.?f1Nf-?2d&;f4DY,R8FQMW:-SISL//7^CfX1dc;,
BeG6-CRb7]P)NW6>c/c0Gg[-]T,F<SI.O,679aH;>/^&3gcM2R^A=Pa:BCFG0J7a
(e/e-Q7+Z7_3.D)738=H4ORE&8[=f1T5]W;/NEX(E9&AYRYW7ZWO6E>Z<d7+865<
AIeV50_cR=JJF__V/XGVfM0U7_^G3e\7)ad92b-):Q2[N?5&(&=P)P@RCM\1TIP1
^XAY8?I]MI4+6-ee@3I07Z4U&3X7GM2N>g:f:bMX#_TeNda@Kd[MaVbL@1a;_PQg
2-/S2c[OY@RZ,QJEO=UN[3ZMMYIe\URUON7aPJ3M@3#U\BHDb??S?+IZ(LW=YV[G
=5&aXC@27a=8R5:&fCfdM84Yd1Y3C..#CH6G,DX#)0]0+2Y,)]AB<-#DI2,EV9Dc
M>>-d:.X<^YXbD^.f9ARF)^=JcQ#J7)Q;&@aM0L>A2ScPEbK&Z@=e53B7WU[(7F#
;QPa^I,106F-9^H7:CVO5SF9F\XL(4PMH-D<JLN22HSMG(^1d/3^Vd(-\EZ-/Q@7
FNWGPWaT6FKF#WQJIT-\CQ)A586<90gWC<5/D5Z>4>Z?\Y1AQC0(7>8JZ8PYW)@(
He\(/=TRTfZ>JZYYU4)7_S]LV/K9b><A@(Y=cVTX=,/Y@MN0R:2\M]EGH:R-4GdY
dSDeD>fJT-RMRDCS3Q2@/b]L8$
`endprotected


// synopsys translate_on

endmodule

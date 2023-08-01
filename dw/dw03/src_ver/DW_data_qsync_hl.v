////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 2006 - 2018 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    "Bruce Dean May 25 2006"     
//
// VERSION:   "Simulation verilog"
//
// DesignWare_version: 71b06b2f
// DesignWare_release: O-2018.06-DWBB_201806.3
//
////////////////////////////////////////////////////////////////////////////////
//
//
//  ABSTRACT:  
//
//             Parameters:     Valid Values
//             ==========      ============
//             width           1 to 1024      8
//             clk_ratio       2 to 1024      2
//             reg_data_s      0 to 1         1
//             reg_data_d      0 to 1         1
//             tst_mode        0 to 2         0
//
//
//             Input Ports:    Size    Description
//             ===========     ====    ===========
//             clk_s            1        Source clock
//             rst_s_n          1        Source domain asynch. reset (active low)
//             init_s_n         1        Source domain synch. reset (active low)
//             send_s           1        Source domain send request input
//             data_s           width    Source domain send data input
//             clk_d            1        Destination clock
//             rst_d_n          1        Destination domain asynch. reset (active low)
//             init_d_n         1        Destination domain synch. reset (active low)
//             test             1        Scan test mode select input
//
//
//             Output Ports    Size    Description
//             ============    ====    ===========
//             data_d          width    Destination domain data output
//             data_avail_d    1        Destination domain data update output
//
//
//
//
//
//  MODIFIED:
//
//  10/01/15 RJK  Updated for compatible with VCS NLP flow
//

`ifdef UPF_POWER_AWARE
`protected
U3K2)dJ+JAF>gBS\3V1AN4KZWTVH58#0_+Y]gF@JF((EJgH.?2f(4)>ccL,+&f8N
bQ;e@<LN(^O^L/BD_L.2Z^CFQGIR43g-CP^+LI<LJXDH2abEDf<E(=f#:>.?fOYD
DUA=KKdMJUd+CDU5.>fSQGb(E&@Nf_\4+/2CFB<TLIUSD;ETTa=RDgFOAL8;\ACg
2X6HgS?XP8a49FYd+d(TZ8)V1[>.aZ@0C:P33b2Q3ga.0;3_]Q6f]^RA+SbeXdfX
JNX\3Q=1#N71;8,dA/TDJ.=@A5/JT_-,;]?-HA;<Be#:M_D6bD]YJW?I:^.6=XHe
5FaMPX@ENaE2a-SA1D4AN4DY-YV0RO-Ha=a,4/]#Z?J,P(bfIK>,,Cd>.=.dJ^:>
^QDC?U<1d?GB8;)W_V90Q_]W^S(05F6-,8C.Y+]24FJZ\W@7T3#Sb>JM@:?=#\55
:Db9O/@[H/bS8SRPXcDHGQRJX4M(C//\R(9/PI8Gf>SYO]9g+=Ld<IB159V9]L1g
#I;b(;>X;,gLX24b\AN2:>I:Q7=WbY5.@aVOe\_@>]8fL7D?aISbV\IcRN^HE=^.
^(ZLL3H>-+5LLK=LQIO&U8GZf@7E-)VWHB@CbKNAB,bae-D3[CS?A5eIY\2SccR;
XUKb9&F:N/FFV^>T>XJ<LE>[NM?/?d2B#69.I&+167)bIb?VKIOC+9MZ#0-B4GA=
VZ44Y;D..d2(Q-N:dD+DdWNTQ(<P?=2Z(D)C<,>E9E5b&eJDSc>YdN)R9T,5^7@A
5B=(6[R@8E_U.OMA2K8UIV(d1e[?CH=M-]3E6BS#-H,_=3G>CYb0XUW6+/6<bVRP
db<:]](KCCX6//:PV=<S&cI-aJRKFC^9G/DE=[G.)XKV+1)@ZaLO9B^cKL5fH2eW
M>AVQ7N6<e@03I6B&4<96O8c\;cCM.72_V:MdJWg#gLVX1#39Hd3,S#4->7\g77@
,U(5a2L^5N8ROU(ZWPF:];ZU;,M8-;[HIOO/d568A=X&8)G\Y>4gW-c1B2E5J9ZR
?UNZ/BSQ=SF=#K]e^SEAg=S8TWCWF@M7a_^aWHY,JJ\MH71S0V@.EMRP9_G?4<QI
TOLK>Y;=L4^57\&]#+BGd0FaZU_N7TdW)6a6BdC]?R>>;14S^gLZQ<6?JcgJ?7;V
8O3fg6Y26-CJ8_9M@)XPHEV6+HY@L<OC++QD^9bN^VUNBT&H/U^4&e=:LbB1QZP=
d8@=dUcMDfIDbYR2BSbfD_O8<3=M/;[E6W8:^.IeB,D1;P7L:BgUSV@dec2KdV?Z
2T&R6NB)A2IF/OBL/;6KcIfD([GS((a\&&)d56N@\9Nde2c&:18;feH?268AON2=
L4A(FIG5W),dTU)]V6[[OBf<Y^+:8cF@[bHBG]=8T?EIPDL75RF?D4;DGC=]O/@J
g[Qb9/0R1_RAZGK_NSSC&;\.PE&<^Yf9SO2I,:E.AY1PcF6L7A[03>Ob4LL2b\DY
gF?W<AD..gX^Y\G/f?YBS#9M0PQGG14@Wb143:bKdeO2YV/03R,]^J^4AH?RI^Q;
Y1Z.@>6907?>>U)F16<SL04c+EH.#NS&d/\/a#2LLAE@?72AQRL)F?O[R,1NO\U\
]^d-:.77QV<)/@PM7SA\:A5;3Ga=U?\Vd^F(>,ZDa^.Ueb0K8A=f]]P0KN9A6P?E
D+.69?,Z5=/N1f<,[R?M6:G<0A0W7=G3L<Ag4G/BBX2<Y>E73eU\\HM\P#Q0(RV^
QB?>-CWC]D9XX5E?1)_;VD<9G;F[M6GX?2J+=FC@NU>-;fT>GdFbW/D-\:,51V?6
S/W869QW(,A50)N[HR/)G45N5=L@-:4<D?,51?3><.)L+5:JE0[RAgJ6(5ON>R)K
0,+;DH3+E<ZT,/(b\#Z/G)bWL]Agb_Vd^H#0:gd>L4L49>9[1:O;S=N^)AY5XS+A
(Q4<@^SQeL+YJ_5C\8NNES^<O(/PNgXL9D/#^J6A9.OV17CC3(ga6HN/C,]TQ^[4
AHFg;^6._-GILIL+@6RGX>]?9-?8WBG=FQZa(\=?;I@QW?Z;C?Wae<,8D<N+QH#I
TfHYW=KgODO^R4_6F:]QaLFSMC2T5J1(-JI+e@e89[A3-JOY=N<A5A@f8&cAMQZc
#4]OaTKdM0.G?(65^?QWZC@L_f3EEe;1Dg3I#8LU8GCLJR3OH9TRZNI2-K,/T8.W
]1I3?0O=I-gKD/N?e3.A=HaD.0P:ICfb;(LVX557fY<4PZV(H2,[MgLQZ:,f?gKZ
U;SVf2EZJ<.[\#I#7RV@9b&+P=Y0146AJ_78Y)&G(,[/UX])#ANc+,dCS-Z]I<g2
.f,_=T7D^/_0QM<6,SG\LUe_b<2a\^-\eDYN;0>-[X<)UF>)T-=OY9g#^84c&[<C
0>&Nc>CK)H2B^)a>R8K(H9?>W^0A6/@KWdf)eVcOJPQ8Z?;60K4>0gD2E\9J9).I
/]][DMK<?JGZcL/.I.MW\ZC(dgNdOdSRVURf.K#5U^R_W9M3P3X^0_Y@eQ<MH2BZ
_=f[O;-\Ae1eNJ7C2d^5M<3_P&N40BJc8QP/RKfGHXMIeH2Y;<=&9&83@DaS<(3#
?g<?]f?La#MDc-6]LH[3.^Z\cBG,QL>9+^7@5=d<GC=&#IBAgBYU1e4(66Gg]dO\
(2Xae5EX/b(:,3^N=G8eGb5_M>&,Of.-W-H8)cMUQTH:[b][U:72A#:G1FA)52GY
IRg_[X_(,9aZ:a0e@Z98)cdX+17Uf?8:=7B[#8NI]MG04a=DK7/5#Q\R9?J;Ra-[
@6AXPbNeS&c-_aF:egcR,e9+g1@R:5TV5D+?.VSJR2^[=7(Ab.a=BK\E?c38YLGM
<3SH5..gMUY6F/T6XH6)Y@_0>/[T]HFFdfRd:PMK8GFM=[A(\B^PLV3aV:MEMQ)e
,RHRb<,73TU;_D;B(M-NM6cR9X)US]=bM0S]KY7?W<T?eg=&G8550/++\I<Rd:GV
>FFK\NXQ;^MKZIbc@896O(dKE:90USP,XE[L[7CWZW?@64[4-#6E8F8d:A4/?g9d
PXSe[QOe:/>X]Za:JbN@_NUCU&PE&WJR>IF-K<Sgd@dUH&cGT;S(J;aOQUYYG^(]
0;/W[E:KYG:9]?@S/D\#TL38A@?1J:a/G1NTcA&^L4D\45D<:2@X^1S?#_VAIB-E
]LK#&CTLN;^ZYc#ND,)P8M@BPS-4A3C1bV)\>)G-V+Jd79+1#FAN&]=2^Dfb:[>6
-:^OHZM@FOY;<B5>.),;L.L0O6GEeBX(O+@;70@C&,SG@=G];PD-6:e@>T(/d[Ee
G0DRA:N@C@R=?M^&?F2Hf[F)6M6eVI(/#PO9<]:=OdTR/6Me[D1([,:]84a(IPO#
<A/:O(EE=F-BB9G9D:Q3O4+E#6S6=H,d)VL43Ief=X1HeR9_KYeT0OG/X:<Q]g61
(2)VW[-GdX1^=7D+d3RI0eJ0BA4)OM6a@\_?&^#7H<:Z[9X2)b8gdNXeWFE,P4;R
D6;V_d(_c&[,<#<&=^TI+8UadV@8YHFU+3D4egMOdP[a7V712.fEb\LA-e+09];V
36UD+=O</&0^<F[b^RZA3]JRUS><:_G6g6/X(5S5((TV\TGL&RM-\gZ^YYM.JSPP
>:90W#[:<NS9d-[J=0;/&(MIG7=W_B;;<E5<?\O:(V3eGAO:U)/>TUcY(,0F6=Y;
TNS_NYH7eN_-MN0bWId+8BHf^W,?A3d5N]@)WZ@#PK.7aLL#57SW\Ag.OX-]E7bY
,gWK-,8CHVD=XBHR?0Y6NFOO1[2D](#ZEJJ]N_1+<TCEaZK2]F+D<@_8eUEbK_:.
(]+b/.=_gd5G0G0E,FZUB7TAc+T_?\BK:3?f<PW6V4f:a?I4,IbAW0&<M4##FG:9
Fc2IE(Je<3<S>c\:YJc=9VTY7]XAAW;FM#9ZHOP-3-:V_YB9B[PfADM#A_O?4.,:
B?:5A2O2cdR)BETNc[50P6,;3^@fM(O(dK<?Tf<N]N7Z7;DS8Da>5:)NYO9YXA#\
6KDg=,TLC9.CV^7(&IEdL0?5)JIdR<^.WKdRM&1L1SWAgaK)TX7>^L>f0J4d7N&@
-6I15S_Z7^D>A3FEDYB/FF9788:9>0^Qa7d=J+VX7?J<4(eJ90V,2PIYXa6WP41:
F8L:WHT:.:9O^(5XR8<[XVYS6:#NbLMF_<,a]&(-:J5_7a^#<e_&Ue;..P<NdLB;
MOM-,BG9#&(b9L?4P<SQM6\KP?bdg)5_-,5D/>/S#&^WQZUC5=DZ.\F&OGS.+PN@
O+SZ2V.P>#W[T<Yf.HXLW90+A@MIeUF=3\OXRYF0X(F:FIB>FPg[X>H3VH:F;+FD
0,8/O@CJ50a[X8>d;J]2/>V;3WcK\b;Q\4^^f&Cf6NeGAGVBK_C.R@D.@W(KU3?6
AHd)XGO-O(S1Xc#D4Z:AbOA\/@E[I4ATUP#5_WE>Z:9XbMW8[f90^K^7PWXSb&eT
)[#[ISD\C]-FeK6OY5WMUQZZ/^)+;H?VPH]b\C/4g68\fFPOW2e)^>&&IXIOag(Z
<\I)XP&YT_TEVP9H?D1bEP,-gQI(8O\6TO>M#34]Z3/E=<1;dB/X:+JDN)-8927Q
K#H7<V_;V-:QWFTDD(L_XTO-daP1fe;5f.f#W4O.YYKA9@Ra9O4.6fDC7F\P0b=/
.IK&#GI3WZ_A]fU01H46UBH9H7_eHJD_3CX2_OY:],[3XY[U]JRDJaba?Ud:b#=J
eZg@:TL@N&-\0UDSd6Gce4LJHIG:RVO4T.+C4.4P6J&,X.0DdcLES(2P7LT,G-.K
b5PZ;R6)?Xa7PgY1AY++0?.EG[IU]6Y#9Ff_MGMFJ/20QZ(;J^T-#Q,SZD>@-H??
W9HZ3Nb#C(4F2)2Nb\5H^eQG4##+7eF)2<IP14K?[CFUU4<K5IJ,1T]@B/,DJ^M#
T05:N2I<=7HcD<LD:/BICI+F9e865cKcaD^(b@P3<7EP2GLI/SU#C>#7S;(UBN.\
IH,0[3.ZL&,>gUO6OE)5[J(TACW3Tb7CN0fMP/#,54)^TF@-F?9QaG^]-\dP>OB+
Ec_fVedR6@TE5)7ZB/4WaCOX-5I6S&.EIX7b3G+e52K1FAY9IZ=G?,,4TDEF]:CV
-/\?E\KZ6a<LX;IIHC++,HY=#I/,XUd[0^4f[^P8?D[YT91fA.G).?@-U@EI#Le>
++A=c>WScJ&FNI;fF&F_8<IeZHZ8N]@KH,ES2\g^?=4E^8#c00RH8I^96TGTI(Z-
\eA4\ZESRR_#\^?+JDY^GO;<Jc)0A+QbVXe;aE(?E.0dL;=>@0\#Q^5f^Q79GaM@
QXGX)g(P15@Y]:a#>4?7^MA#WU)2DFEfQSGeHg.&6UM#?dEg_(U^J_=gT[gL663)
X<GYUX5.e7aTaf\9H17=,b/FdT&4[#C_?UULP2\FGKTHcU5V<M6+JG_T(9.>1S\R
W9[C><]SD<C<VJN.=+A@RUH<N_H-.=PAPa.R(1[ELa1HMDE1UEd@b-C6_L;[]O^Q
.^2YIR650T9TeYD\/c(XOP.f.(gWI>J=^=Rd&,FE/4@=GY>OU<E+0J(\(]aKM^H_
[EU1Y]##E@A@<7G1S2bSKbEC\_&IQ_daeV\;1@(MFIAB_==TWMZ\9YU1[@-6,EMe
:L-^,W;?X^=0fPFG:/d)0Z9&UKc8<3Ic(a9A-B=3\=&bI,^08ROLERIYU7/Kd3/6
N:fK/;Ad2>4_ZD48P;+&fWI[GfS9)JG;fVV]0<f/4W;,-R>O-Yg3S.69F-VP]@0a
7MM050E<02A\97BC:PQ&,fJ^\a[3Z:2>#c)dO2e=NU;AGBK.3S1]3_NC7^;\aNH[
g;g=,>],JH)AL<&H5R8)6[_51&S:d,8f9F&HbeL4(_gJYa/(35,>S>J>?>6]8=/-
>/IL#WDBMf.U?R-<(42Ff[.2Q(SH)f_4L[2QQKVXc)Y=<KfAPbS>F5=VD/@?-VM&
E+bGfHd[:Q,Hg:F5b]31@6AQQ9V7K\-PWQC/(J0P)@BJA=7>R60d#f,>9[[dV8XC
1&BN9BX1.M_#2LNJV)=\b8@\d;UPbB0EPA(4[Q,fLXc9Y_YM.dK_PVf@&#^-LU9N
2_]GV6.B7+8d5?:_?cK#2?[7&>4>8ROGO>M.F7M:IBK.H5]O9-T.g]Z]M8^A;4Te
BaY=\[QND+X#Q1#3;,WR^4@PD\>/K]@9c_P,MS&[=WNQaUeZc?=&6[Qf=a8L6;L7
&H8,=O+A==D0V.00#K1c,#C+N@XMJ5E)7(ET2-dS4dc?]__B(c+08S6MF4a=M+#P
_0DC-?2?4M#K96M<G&IAS3;9eDd<TFO+E&/0]9>.3E74HVDa;Q#7,7EcQ4+,e]TQ
b2FL_3:LbI1YX9N1_3)7A^Y>ZF8QA8bd\L]GP0IR42P2c?)-U\>c,^79?<PKQ/ZP
ARJN[<DO4,XXW8ZSL0X^6Ag;)[Ed+eOL,@c+bfaQA4e5XeGf+OAg,BXeCLS+BDSa
[(/5>_SIK47Y;?+I1P8F31NXSG^5&[d<U<.GODO0,aMd8L@01aCdXd/J(4++L:IQ
,IB-dSfb<baeO_<ceUcL;Z_JJPUKfD&YOLFb6JR]F?HfIH-gC[@\Z(S\C]/AO9U1
H,9,U#WcTAV79TMUXJF_QT>97:=4^][MJU-YX:H>+DeXe6/0<1=f0,G/cS]14&5>
A.=cV@;O459D5/83d[@YKaR5C(+OTH]a=7_Jb[14R\6@g;]Hb&8=#NA\+72&#bgR
d:Ocg/;MH)cX[UKH^dfJ(U@P3G-4VOXQAc[WYCGRaY7.EXV<OJ[fUX)2?TSPI@E\
W5^O:b5bXBN6L,6DQB;>P66;I&?8]&W[#&1LF(O^=f3-MGTB[ReZd_<DOCGEU8,J
71.VO(T-a7e/MIR,PR\./d<7UA8Q^MU5V1.1@_TP8-H3P3SK>d+8MbEfKYRV9FHU
8Y<FV^[28^FJ]X7IAMGZL-JEga5If1S1^/\S.Af:2>Eg:OJa9LUTFJ#5#7<8.MH>
,+2RF160X;1=3[O^#]WG?P1FHE)A=Z;:44EEM/502J+e(g]]\.)gE^aS)>3IQYM:
F:X-[??6.)=>EKeeA)<#LGcKeGM+RDX]6?CR,3)XAX#eJ=<XN6D#.TId5gDec.L)
:dVc:U>dbHAUaXTS\c;(GJBY8I+<f[b)TSC.DO7(b1:-J[J4-UGS9XLY]HY:b?1=
Ugaf)Y]Z-SZLd-O]P<)TV_Ncd,a@-N:^eK\e(5aHM@X+3>BQB)&6_<<3O88acWA<
\2eWT.-G&D0LZG.U:9I7b<>,7:1Q>[4BD9GY7OUTI3BaD4E?F7>OLaPH03P]4d)K
60:/#/bafFOPOb>&\DS00,GeXNf;;f;Ddea_YG#H>.\JAQJ[6YQG<EeQ(1J1._e[
aI\cL2:9L^5R?WEP)7Db8S91[KIFBJCDKgIKC?R1XL.-QTD)_Z,0;N[NVYO,HIA0
TRTY8+ZFJI1O_bX@_@b4:]=6a&>AN6@e\T1\K)#]6fCYcbR(?0@5]LATLJM4W1#F
<C)R4-f]DOQC:P>MHTF3L>d4cCG]P+f8Cb1Jd_T=)b#XZB+9TMGOY&N&IGV:\,S?
UOP<eF>HV[KDP1f<W@C:JKRU5VY:#Q-;De13DHdE&06PeeA?V=+Z9#N;YUS2aP4L
Oa)VTME+,7E#g^-77T)#e@WCGLB04W(OCXS8OP?H10c8-]e;66/Q<GPf9WR3K+-G
M.;_gYS790-4[H6VdA0O#B#[.?LbZ^Hd#cEaEZSV1:T=<F4eLKBS7/DNLJ@,@4A4
]?U:&><BZ]4P^Y6e^(?La+GMbO8b596\J-6UbQ>+VcN1#T=+0=KI4P<fcVY;aTfB
C)WN<O/.QdE,0=c-=dTIDG0(U1_-8a\5EQfD30VP+=2P1FJ6cKT(;aJV-g\Q<HL:
CRCX2K<NFaB?GYGD[@]Zc1FCO-53F8&QEGCK@a2E=(_VOV@\_L[,d2L>^\]/1X5[
&EU>10aTQJFR)WDA5T>@WI;2=EI@.#=I2f)Vb9#D6IfJ=TPQW]KM@^IH\XB_Tf9b
bMPJ9T]-(7Z)b^Gb8e)ROMAJX:,KGb,ge:[MZECK@V5gJegFf[4M>D?[cW0IV:\Z
DO+e>#=cOTXJ5WR_7bX84T03d.TK2@Z3SY)&08=5DVS=51:bE5M3(bgX#62IG(@&
2<+(TQY9H+6DL0PHJQ1=B+XS.,I[Ye6Z5Z?@0[W5E=X9T(:\M,,9aF1)2HK5YO&,
^^1B=FJAgRK9M<&V:0QATR2#>AOY2,W_XCGK\^].a.1PN\4:PP]0[\&0.^PK6,.J
RF=/SR_f<+.:.Z+.W0(<LL5H)]WVdCBbW[O4)+D]ZCfMH-#(I;>:#@bO)GTXL<[8
6C[HcT:/a:A.bf#G&Z\Y+-C2BS^EC(P-IU(=dH)O&Z,U]WE<7gA>bE1B)]LM<bZ=
FI>J<8>17NWKOb-aM3YE3>0QX=73c4c>EU#>P2Bd7.#VaV0F<\\?OEM.K@X\,+9P
C?5]<=@8)<#N6ACeV;51_VCTIWS;\,S=90=.d0D@eV/deN9\73>.@8&=()36K/8I
[-.Y):R7UCgc=?G/Y3UD.(]CHH70U26.G22V^=\&H7a(EK+a[K:<AIBDI[b<6J)2
#N#^1SZM8T?R&\>&DANBgN9c>XVBI?=-RXg\@)>8RVKV>OTc1BcEV/>@H/&)=7>:
X6R>MJAYO56#KcU0.I0(58HPKBg&SV_41:&]40&R?E@1E0;=@,UHe&4f85=EYCBW
?LEN6U:SAV6F]B[FBUI[WM>HHE&H\\/AX4\]X+<X=Z@.G>(Q(2](Ye_K06LB&6Q3
O0&R4S[VP+TX(@S[b/EQ?D&-a-2)GM9FbPZPBT(YESEMfHR\9B&/Z<#TOGH?gaMR
d(OgFG\]=@:C(E?1WTJZ.\EeS\gJ3E\cK>_d97O&O.\.9#K=gD?#c;.B5H&NO4^[
=]Q<CA-J(#eL631Z>8;dT@OE3TS]?GR#dH3RD>IV8f.UE<)0]WN49@cIXV8)K5ZU
Y@-]LRKMHM>&8FLYa__N;_95NTQa8=]K[[dEf(6]FGM(\AN0:44cC5B=S/H.Z[,b
PZV9A[1;<^TL0;.])J\<?N1)?^?g8P1):H)U8aL]P<0(]3=4Nbc>faY6=1dDY7eK
50B+AY-F^HVeeUK&CQU&-IPY@1)e(+cXeB+2@#dc#2e5eAe,>+XO@BH^;92KVJIT
E[^><Vd@X)CU5QaKa]\0>3Cb6.S-Y2GT=6J7eZbG\C1V4,35]?>;5EbN/@]/8Q5O
@U7XRH?MfC,H_7D8=2-Rd&P=b5?5^_#ZOR(<G@f3Z)M[[^;WScS2]7JeB8.?e8N3
\53b##X0.ReJTHOGAaIV()ADSeaB8TSP#N&A1bb.0f;-FS6ESeb]>5=De\F+>^-#
L6LUW(=D)].DQ.=)^G=HbaHFJZCQFBfMR-1YG4V_&#B\EKa[7I//U@AaH?^ZP#OG
6E5fQIQ9=:Z4Vafa4/YH+:@;7QfS-P&](e(II5VHRJa-A1C)TfWC5-fG[)&?O:S]
f1HEVEG.I+gaS+64^S@->SSE8D?O&DV;,FPI>C]-?Z/85@<[:e[aNUa0?#L\[GLK
@6DEgK7NaKD:N1C6SRWV.-3gK545^+U]10S6/F34/<K&_ES@#PQ+JaB,0aLX1)6G
RGL53Kc]dgg1J>f2^)GL?U9fg8#_M6.#cgX=aUKN4,2,QCA#TcAKL8FBcRSb[Y@5
:EJGV5aM>N:OP&Ib]fS>BbdQL)N#D[?CbKf:9OB&FgSK@&IELS]^g>ZW3A5RE&Wg
eJD<E@G3:[XK(SP(_HJ/MZaD(\[&=GWWOW-5PPZ4a(YNaR7/JB9T#ZC3KVYNWZ-f
\Y-9],]6V#0U28f^:a-dMYS<](@c7d#H#8J5:IS0]]:O-ZB4_T&3?DRXVO\,b&.=
Q?A=?,]S=Z0GY67\>3d-B_PP6H3(<EMCcI-gbggWWXH_2g<eRH0VU./#QMH1_^<Q
E1G(2DJDKaPD:JN9@M-ALK<Kg<88A_/CLf+T2T1Ga1),C/3ANYCeD\DJgcf(Ab6g
7TQJ#gS6897.O-@WDS_5SC_Z:RKM,47\:T;5;+dAEXCQ?N2^Y9Z[f/N9MUg<<<c5
WB)67;#g7g10NPMOFS&W9^=[\B<V/5M4aN#=5B+Q77H1L4&:^TG4ZgTF:^B.W(=W
,Z3e1DDaZE2WZQ\d_MXIGL[/\aYWeU_^8dK+YW@U6BH^QM&U/bP;NYGID]\MBDO(
4Y6KDC9?c13X=S]_>\fb3EdQ\N&NP2D(\#[L,\3g/[CC-+(G6NY@BINObEZ+D-9E
H532O_+L79/&,HI]GQ[0JEb7Q&1bdV;N_c/W6a@_aD2F(=C/88][GQ-9+RXM2O^.
SUF)[OPD#X=]B=4TF)JO-01fHBT(LDBE_7G+KE^W5DH-a?6X#T?#@A24L;Ab@7a;
>88,[WS450MM2XdbB_gb(^U>;bUPRRS/W5>EN(<Qe;P/5AeUK@N\CYWUN+6cEgX:
Fe6>?8J566g07BOB@W;_]#VPC<]+,5e3aJ6+dbDI/+c_K>OaTS=gH,^,=E4O@/H/
S7f,:eDCR4^]GU>?N\T>.0[WIV:;8VgP>XJ.ffY9?+@c5IW9)HOYe_Tc4Y,aT169
b-=QHc/LR,&afb^&A8:/[c38H==Y<A/2>\+B4@)(YU2RB_M\@X,8.N8=[.8J>&LV
HXA+CEKdBVcFX+DCAPEQ(+&@4RE(B):SBWH/_Bb[^0MWO\Ua54cMG[<DF6_&AE[g
Obf/?/)3ggAa=<XD2+GbY;3?XWT-dSb8_&a\<d)M@(DaU>DWO->3E#69XV0]Y-9C
ZC3^S-N#J50dEV<@AAQUPJg7ReXaC@X8EVGP>MHO0.(JJAf4)2?UXa-LLbOLXgC<
Se)C9-WS1dHQI/L+N2]?dOZT@_:UAKXKcbW_Z8<U_5f4.I=?PcDH\I&1#&US()<5
&Ka&Mf=)ZJ)Rg+1&X4C?F&A.P]7>JKb7.b6;N5OL;US/EXLG8NNF2AWW,OOG?C5H
YC75+>Ug;bG.T?K:A7SD#&#aOF[d+,2=\0UO>b)N6L?]FPN^V^WJ/-G>XAYZSeUH
J<.1e27[7@Eg)YSJ9+YIIH(_?c)U1U:KU3TLX2LWXaE<8@O#f)K1[\<;?f8gRWHe
>JN73--6d-\fZ/efV;88LKU\2;Z^)6VEbB1eb^3UD>/<H$
`endprotected

`else

module DW_data_qsync_hl(
	clk_s,
	rst_s_n,
	init_s_n,
	send_s,
	data_s,
	clk_d,
	rst_d_n,
	init_d_n,
	data_avail_d,
	data_d,
	test
	);

  parameter integer width = 8;
  parameter integer clk_ratio = 2;
  parameter integer tst_mode = 0;

  input  clk_s;
  input  rst_s_n;
  input  init_s_n;
  input  send_s;
  input  [width-1:0] data_s;

  input  clk_d;
  input  rst_d_n;
  input  init_d_n;
  output data_avail_d ;
  output [width-1:0] data_d;

  input  test;
// synopsys translate_off
integer reset ;//        [4 : 0];// :="00001";
integer idle ;//         [4 : 0];// :="00010";
integer update_a ;//     [4 : 0];// :="00100";
integer update_b ;//     [4 : 0];// :="01000";
integer update_hold;//   [4 : 0];// :="10000";

reg    [width-1 : 0]  data_s_reg ; 
wire   [width-1 : 0]  data_s_mux ; 
reg    [4 : 0]  send_state ; 
reg    [4 : 0]  next_state ; 
reg     tmg_ref_data   ;
reg     tmg_ref_reg    ;
wire    tmg_ref_mux    ;
reg     tmg_ref_neg    ;
reg     tmg_ref_pos    ;
reg     tmg_ref_xi     ;
wire    tmg_ref_xo     ;
wire    tmg_ref_fb     ;
wire    tmg_ref_cc;
wire    tmg_ref_ccm;
reg     tmg_ref_l;
reg     data_s_l;
wire    data_avl_out   ;
reg     data_avail_r   ;
reg     data_avail_s   ;
wire    data_s_snd_en  ;
wire    data_s_reg_en  ;
reg    [width-1 : 0]  data_s_snd;
reg     send_s_en      ;
wire    data_m_sel     ;
wire    tmg_ref_fben   ;
reg     data_a_reg;
 
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
  
    if ( (width < 1) || (width > 1024) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter width (legal range: 1 to 1024)",
	width );
    end
  
    if ( (clk_ratio < 2) || (clk_ratio > 1024) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter clk_ratio (legal range: 2 to 1024)",
	clk_ratio );
    end
  
    if ( (tst_mode < 0) || (tst_mode > 2) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter tst_mode (legal range: 0 to 2)",
	tst_mode );
    end

    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 

  initial begin
    reset       <= 5'b00000;
    idle        <= 5'b00001;
    update_a    <= 5'b00010;
    update_b    <= 5'b00100;
    update_hold <= 5'b01000;
  end
  always @ ( clk_s or rst_s_n) begin : SRC_DM_SEQ_PROC
    if  (rst_s_n === 0) begin  
      data_s_reg   <= 0;
      data_s_snd   <= 0;
      send_state   <= 0;
      data_avail_r <= 0;
      tmg_ref_xi   <= 0;
      tmg_ref_reg  <= 0;
      tmg_ref_pos  <= 0;
      tmg_ref_neg  <= 0;
      data_a_reg   <= 0;
    end else if  (rst_s_n === 1) begin   
      if(clk_s === 1)  begin
        if ( init_s_n === 0) begin  
          data_s_reg   <= 0;
          data_s_snd   <= 0;
          send_state   <= 0;
          data_avail_r <= 0;
          tmg_ref_xi   <= 0;
          tmg_ref_reg  <= 0;
          tmg_ref_pos  <= 0;
          tmg_ref_neg  <= 0;
          data_a_reg   <= 0;
        end else if ( init_s_n === 1)   begin 
	  if(data_s_reg_en === 1)
            data_s_reg   <= data_s;
          if(data_s_snd_en === 1)
            data_s_snd   <= data_s_mux;
          send_state   <= next_state;
	  data_avail_r <= data_avl_out;
          tmg_ref_xi   <= tmg_ref_xo;
          tmg_ref_reg  <= tmg_ref_mux;
          tmg_ref_pos  <= tmg_ref_ccm;
          data_a_reg   <= data_avl_out;
        end else begin
          send_state   <= {width{1'bx}};
          data_s_reg   <= {width{1'bx}};
          data_s_snd   <= {width{1'bx}};
          data_avail_r <= 1'bx;
          tmg_ref_xi   <= 1'bx;
          tmg_ref_reg  <= 1'bx;
          tmg_ref_pos  <= 1'bx;
          tmg_ref_neg  <= 1'bx;
          data_a_reg   <= 1'bx;
	end
      end else if(clk_s === 0)  begin
        if ( init_s_n === 0)  
          tmg_ref_neg  <= 0;
        else if ( init_s_n === 1)   
          tmg_ref_neg  <= tmg_ref_ccm;
        else
          tmg_ref_neg  <= 1'bx;
      end else begin
        send_state   <= {width{1'bx}};
        data_s_reg   <= {width{1'bx}};
        data_s_snd   <= {width{1'bx}};
	data_avail_r <= 1'bx;
        tmg_ref_xi   <= 1'bx;
        tmg_ref_reg  <= 1'bx;
        tmg_ref_pos  <= 1'bx;
        tmg_ref_neg  <= 1'bx;
        data_a_reg   <= 1'bx;
      end
    end else begin
      send_state   <= {width{1'bx}};
      data_s_reg   <= {width{1'bx}};
      data_s_snd   <= {width{1'bx}};
      data_avail_r <= 1'bx;
      tmg_ref_xi   <= 1'bx;
      tmg_ref_reg  <= 1'bx;
      tmg_ref_pos  <= 1'bx;
      tmg_ref_neg  <= 1'bx;
      data_a_reg   <= 1'bx;
    end 
  end  

  always @ ( clk_d or rst_d_n) begin : DST_DM_POS_SEQ_PROC
    if (rst_d_n === 0 ) 
      tmg_ref_data <= 0;
    else if (rst_d_n === 1 ) begin  
      if(clk_d === 0)  begin
	tmg_ref_data <= tmg_ref_data;
      end else if(clk_d === 1) 
        if (init_d_n === 0 ) 
          tmg_ref_data <= 0;
        else if (init_d_n === 1 )
	  if(data_avail_r)  
            tmg_ref_data <= !  tmg_ref_data ;
	  else
	    tmg_ref_data <= tmg_ref_data;
	else
          tmg_ref_data <= 1'bx;
      else
        tmg_ref_data <= 1'bx;
    end else
      tmg_ref_data <= 1'bx;
  end
  
// latch is intentionally infered
// leda S_4C_R off
// leda DFT_021 off
  always @ (clk_s or tmg_ref_cc) begin : frwd_hold_latch_PROC
    if (clk_s == 1'b1) 
      tmg_ref_l <= tmg_ref_cc;
  end // frwd_hold_latch_PROC;
// leda DFT_021 on
// leda S_4C_R on

   always @ (send_state or send_s or tmg_ref_fb or clk_s ) begin : SRC_DM_COMB_PROC
    case (send_state) 
      reset : 
	next_state =  idle;
      idle : 
        if (send_s === 1) 
	  next_state =  update_a;
        else
	  next_state =  idle;
      update_a : 
        if(send_s === 1) 
	  next_state =  update_b;
        else
	  next_state =  update_hold;
      update_b : 
        if(tmg_ref_fb === 1 & send_s === 0) 
	  next_state =  update_hold;
        else
	  next_state =  update_b;
      update_hold : 
        if(send_s === 1 & tmg_ref_fb === 0) 
	  next_state =  update_b;
        else if(send_s === 1 & tmg_ref_fb === 1) 
	  next_state =  update_hold;
        else if(send_s === 0 & tmg_ref_fb ===1) 
	  next_state =  idle;
        else
	  next_state =  update_hold;
      default : next_state = reset;
    endcase
  end 
  assign data_avl_out   = next_state[1] | next_state[2] | next_state[3];
  assign tmg_ref_xo     = tmg_ref_reg ^  tmg_ref_mux;
  assign tmg_ref_fb     = tmg_ref_xo;//not (tmg_ref_xi | tmg_ref_xo) when clk_ratio = 3 else tmg_ref_xo;
  assign tmg_ref_mux    = clk_ratio === 2 ? tmg_ref_neg  : tmg_ref_pos ;
  assign tmg_ref_fben   = next_state[1] | next_state[2] | next_state[3];
  assign data_s_mux     = (data_m_sel === 1) ? data_s : data_s_reg;
  assign data_m_sel     = (send_state[0]  | (send_state[3] & data_s_snd_en)) ;
  assign data_s_reg_en  = (send_state[2] | (send_state[3] & !  tmg_ref_fb)) & send_s;
  assign data_s_snd_en  = (send_state[0] & send_s) | (send_state[2] & tmg_ref_fb) |
                          (send_state[3] & tmg_ref_fb & send_s);
  assign data_d         = data_s_snd;
  assign data_avail_d   = data_a_reg;
  assign tmg_ref_cc     = tmg_ref_data;
  assign tmg_ref_ccm    = ((clk_ratio > 2) & (test == 1'b1)) ?  tmg_ref_l: tmg_ref_cc;
  // synopsys translate_on
endmodule
`endif

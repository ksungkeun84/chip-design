////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 1998  - 2018 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Rick Kelly               November 3, 1998
//
// VERSION:   Verilog Simulation Model for DW02_multp
//
// DesignWare_version: 28366885
// DesignWare_release: O-2018.06-DWBB_201806.3
//
////////////////////////////////////////////////////////////////////////////////

//-----------------------------------------------------------------------------
//
// ABSTRACT:  Multiplier, partial products
//
//    **** >>>>  NOTE:	This model is architecturally different
//			from the 'wall' implementation of DW02_multp
//			but will generate exactly the same result
//			once the two partial product outputs are
//			added together
//
// MODIFIED:
//
//              Aamir Farooqui 7/11/02
//              Corrected parameter simplied sim model, checking, and X_processing 
//              Alex Tenca  6/3/2011
//              Introduced a new parameter (verif_en) that allows the use of random 
//              CS output values, instead of the fixed CS representation used in 
//              the original model. By "fixed" we mean: the CS output is always the
//              the same for the same input values. By using a randomization process, 
//              the CS output for a given input value will change with time. The CS
//              output takes one of the possible CS representations that correspond 
//              to the product of the input values. For example: 3*2=6 may generate
//              sometimes the output (0101,0001), sometimes (0110,0000), sometimes
//              (1100,1010), etc. These are all valid CS representations of 6.
//              Options for the CS output behavior are (based on verif_en parameter):
//              0 - old behavior (fixed CS representation)
//              1 - partially random CS output. MSB of out0 is always '0'
//                  This behavior is similar to the old behavior, in the sense that
//                  the MSB of the old behavior has a constant bit. It differs from
//                  the old behavior because the other bits are random. The patterns
//                  are such that allow simple sign extension.
//              2 - partially random CS output. MSB of either out0 or out1 always
//                  have a '0'. The patterns allow simple sign extension.
//              3 - fully random CS output
//              Alex Tenca  12/08/2016
//              Tones down the warning message for the verif_en parameter
//              by recommending other values only when verif_en is 0 or 1
//------------------------------------------------------------------------------


module DW02_multp( a, b, tc, out0, out1 );


// parameters
parameter integer a_width = 8;
parameter integer b_width = 8;
parameter integer out_width = 18;
parameter integer verif_en = 2;

// ports
input [a_width-1 : 0]	a;
input [b_width-1 : 0]	b;
input			tc;
output [out_width-1:0]	out0, out1;


//-----------------------------------------------------------------------------

  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
    
    if (a_width < 1) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter a_width (lower bound: 1)",
	a_width );
    end
    
    if (b_width < 1) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter b_width (lower bound: 1)",
	b_width );
    end
    
    if (out_width < (a_width+b_width+2)) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter out_width (lower bound: (a_width+b_width+2))",
	out_width );
    end
    
    if ( (verif_en < 0) || (verif_en > 3) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter verif_en (legal range: 0 to 3)",
	verif_en );
    end
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 



initial begin : verif_en_warning
  if (verif_en < 2) begin
    $display( "" );
    $display("Warning: from DW02_multp at %m");
    $display("    The simulation coverage of Carry-Save values is not the best when verif_en=%d !\nThe recommended value is 2 or 3.",verif_en);
    $display( "" );
  end
end // verif_en_warning   


//-----------------------------------------------------------------------------
// synopsys translate_off

`protected
f4U::0(5#KUTK?&[UYC5P+T][GNb:H_Aa&^W&6fIS)CPb^&K1GBN5).=6Q^X]\bD
_5(WQL_6=E(9LgYM5<6+3NbgKgXDaPN)<aZX<+cY4e,3aU+3W>20&LWP5f8R>/4N
A:F2+0bCZ)])@FY)VH)=CI;ReF\<a+I>BX5=>K>I2a.3<7NBX-G6_a13TC@DA)T)
,DLA;B[O>4]TY5XC3#S17,7QW#8Y65+;(EC9I@#141aadQ:Y(I?E<;HWJE<K(@7\
+gcL/3PNIN;V8+NY:SQW7Q3#9a3T=Y;IJ@f)><S:+L@OH@d)K:.0bcc#g;0,FVU?
;S^eA;F;&QYL>G0bPC&,:3dN?0\QHRHI]V_:2#K3g7ee-KZbO].X<76?K/76C<-:
#Z1\F2EQ-(QEV\VbK1]>VEe-KIL17:77]cKeX@ZI>MIOB3)ZI8KNe8KK/b-9C@=1
UE3(SZ-]:QYYEGg#d>g;T3;DE?\e#WaT--YX4a,N)Vd^AKe#85)@SJ5/5/(H[P;;
S)0MY+>FG;3LZWXcQWJ?L0e^<2XU[(0S]Y8Q91Cb<U.9GC4PO9a7[BE1,C;L\Z09
0IaUI+We;^\_5XM?eL7VC8#4/>I=\?O_&P_28fA0P7>FPD8G&J6=MYZLbE6:\2]+
Q]77Y0)CZ[C@<fKBgQb;7F9HN0/9eD92AKeI91O^0M;NWP2KUSXFJc,;=/=X56TO
fb4E0]WFYQ@ZIZc+RSeU&);MK+cG53P6DeJ@.ag#B&b^^d,P8:b4J2/)cSaRa<NN
Ncf#E##.EfZUT5O#7<K=Wd_U\@-V:^BBO=4(GgHc@e<C1/[d7@ET1Y[.WI=S=0/<
LM+[gXU8fS\^A>,2#\=T^c2-T;8c>M_,f^R0:ORXP8;fAa69SCb9DKSEQU_6GSdM
]?J9+7G5/(LA.:FC/c<&4V@AAL2aB,KadDgB\JVR/.I?MfKZW^JcF[PD75LF?^fM
cB39:RNC:&AKD,Zg)0#(TZd;gATY_EA7<\-KGKMIYJ4gO:+WO5)6.eOS8/>a>c0N
(gXQZ,4.[56;+\?9W-,Z8E]f&Y9WTZ-Y4IPXNFLU(\X:+V+a/9HA;28bXFI@A?HY
D4XD7ZF0#\.RWI&@M._&;7M?K_5YEE0c@W_SO.HS=D^U4^1_9=9[-V1BL2;^//\_
@COcYE5Q&2#2A:OO^DXLGTN]2&497;AS7Y-)fYJ3+fe7_c&(Z#6?:\XCMd^/VefE
__N3K0Pd?4YL^H0@\d9_<cU;_B:QXf:J#-IP<TWJ7.37<ZVUZ<N(dEJ;bTT8HNE9
+bR;_0b^@2>dD_9UES.Z;4Nc-6_P]0RJ6XI0M4_O,CIc:>,>)8Z;JJ4de289V<BI
PC[[N\5=K8BIb>c]b5I?b9886+K:CPW3-[[UWTZ/\;&+;MdB7Fg<7<_I1>2&^Fc.
U92+a9LM3-VIdYT/?2>T(A,O:#c>:-;\XRKT0gOf>GU0Efd0&\[4XUgSKB2],@E8
40-/4W3P5KTEO#(c-@M[)affb@V.G=[EYP(0Z[.e:dJ9<8L:?dbT3KMaUA84^G_?
AS6<RDZ0OON/d),WR0BNGS&SH-@d_E1,093=.c39;a5\@5(PHggSF412H<@GgF^^
Ga)dY-?=_-B6/L<(>_23?J/QRG(;>-dMY[IKOKDY..AV;A9Z42NCK3:QDU?G/T<#
:C9<UP5\8S]O-\T9X@SP9J<FXYQT/7L</5)8S3NED?d&#X1N+8@7#Rc3DBadb+?A
)Fd>>AHfFR?\^YfUfg[V\.g:eXa5&Beb4@D9,V=c1HPKa=W5<^0-Vg_G^@UYgW8a
5J\M[/64[&@2XT10339J;4A#F)X0B(.d&b8N6T>=,904g]L73GG\L@JRfV:L9E1P
I?-NHN/QVO;^aPDD-7&B?7Yg5C&L60[-Mg(#Ga<F+FMAObaeF02N=L;).Z(8FWH.
K_d:NMK[W=DB&ZXUbGg4CM8/@g</HLS_4#TgXecNG#d\>d1PdM,ODI+=fZgRE4Z+
BHa5=Zd\^<Z8?aH6eX[B8B^<c.M@4)26-VWfC&fIFRL-TX\RP-P&YTH-2;c1Xa<6
3.aF+fgL;+&Wc0#6Q>SI<0R(\AW7MU4)ID7T#VO\ZF2cg->9EMI4;e1gWc0W0KE1
4NJPE+?)0JOd.M7NaB9L@9bL?(682.B0VgKKUTL/5S_0YI2bdC\\#LG[GD#Y/TQ[
.1[M?:-B^cX/>?d>NN10,4eB-cJ]=<#U^+;M34_7-5+QR,<\#TW(SDC@-(bRbLM,
EfI9P]F6M&X.5g2?=Y@MB?E\:P5K5#DJ8A4g=)^ffW2e,LW0X\ad^aR>NB)bFRO)
/\]MI@6N?YVWaWaG-6PCZ2]e.Y57(K?9#CENB+/?N],A2+3-^>DL+X+SL057C<c:
V0a)<?&Tc_A@J^cU#YWC5I<1+_)(ea^JHX_S^TC721.KT_?XG_\P_2\>H\BG)R2K
YS8U9Z_fORMcb10L/4DD\cC3Z-\<9e,2HO(WLH2Y=C5CfGXIQ;LFcR+>?++V1-1D
gE4/XL6U;#+CTd+eIf7^ID^)7\14<305YTSP7>[Sc3+\-;9N()9bE8O:gL]cO\JE
H0-gb+MG>9_,VfSHL;&_^1.D;Te5Z)T<2_33,ZS_59)MP>1(@Z)Z(J.GMcZ-;>-K
U^,DCAa9(BOM;P9;S?0KMN^9)e2+MA:W[:B+=H/fdc[;P;KM-:R6(De(_9.KMC&<
T/C0_#^F>L94<V<PM^W=(WM/-QFWF,\a.VK74f_fa_cJF>ATA#-4U2OO.4#,NF5^
7F(K^;a_988>\#K:9QBRRP,e\KJ5U6I9A>U@]RbL?MDQA.ST];2R-_#c-N7f:J-D
DK#eSW:g_/_WC>Lg<S@aLZ?[DZXVYXb_K1E\aeP\68Q_2]+c2PUg[9JddUU&.NBY
+O&,5Q)aYEPXY:F3DC&+^VM]L6UcSS.7g4_7:YT[^L1JN8-A)YX1Q=8K[?AR(=+U
A)gKJfaR4U-Z0/N3?a42:+K[V63=f?1KR(J3a9><A.7+KLEH_f,;TZD>I-fN&\C+
M537DJFVAVX-,D<1D)0LH67Q/I^A_#??f@]g\UZ>HP&Qg7,T8HY(61BaCTL.BK@;
L-BP];f].M?H/dIZH75d1UP^d4PfSf2^Y3+=/&X6IJ;fLa,<L\;b.eMJ8S\PTL.)
d[E8e)DZ+e>-A5ZM-Pe:b]9/Y_Jf=\=S,2&\2bAL#dGU?^<&eGeWO)0c)3>?RdI+
TT,@20f_7(e39EGP6N&)^1KSXM,;Z3001<12bNM:^A\aC,GO>Q/\RAIe;;6Ae<IP
1039cR:[LI6#67SMgGIIY/8_^@].24^TRLU\/9dfOfNX(0=B];G51Y3>#Z>SRU#8
5N@N);H^bA86&IVD3=NT9VgM9>?R?=+C0E:HN5:U,>_PZ?,<@16Y<Hga?7-#O,DW
gNX]FdLM^KS>(2(D7I,J[Tc_:.?+M+2S.3XH/_GW5U2X[H>.ZQ\]#N:a+Hb_Q/P3
g<83e.[067L6L^FK,g0NMV5M<Y+R(4QSHVc:cP^EJ:(,cLc=,./[_7ZbU,8XT3GD
WH.6A2(.J\/b<C3RDRbf\RPM.E7Z_\b4CARPL-P&Fba4HA^;IGR5S=CD(/B-Z[Q^
b>&@WQd^8.@W@PKe#,83F;>@@8A/GCRU&Gede.4OSQBASCYUc=BYX\d^4S(J1W+.
X:\E&7]7(X.\fN_QIY&/e=T.,K=2?;bcgP+@ZE];G>176V+e[K)YT^;OTPP\ZcG(
/KMFV[XD>=a4/=Z(B-)0<K7.5BfBKA2\/g8-L.M]c</2Ma].1LZ,8PFc8(V4]U3=
fd+-EG;cH_4E,N-HX\2Z<dRHAI3ZJ5O0c,0bdSA.M[2LL[:V&4aab?GWDPg?D+7=
TJ0@G/JC25f&/I9[C0K2@dGP6/4J2V7@:]052[F;b@KWZ89EE(D:AWY,+AaAeFQ0
,8_5&711+(aNWTR&OR<AJH5KE@78NXZ&B@L^LXNR>.L\5#.bNf@dGIMO2VYdRKE/
<R:KD/>YC286^[_9c<##?V,g:2SK,8W2OVC_.T29TK4L9E5A2.7-d1]ZKaQGbMXQ
Z#X)<.HL?:/Z86]L_L6-M5]&B4K^&a>]RL&CeD[CLKQ2M).L\T4M13;\H_8[Xd,?
/(9Q:S3506@T)A+P6?#5B+519[5/B&CPMLg.0GJ7B[2;?@@^KH/4<O,EHTND:NY<
,KeeQ;_7UTPXT(XPE.9MW#LQK>U\2&_N03ReX>VcLYf9OA[:2Q;<GVBUNbB?<F41
2K+eVGB7>Fg]1.\a[/4[O&N5#[gE2/__NWJ9-c_@6e&f4;-99bfP1@-?MQO+)aP/
=_f8I-O#JUEOQbWa6ZE>Q9P36=A,\WRA>K]BL?VFd,7O<I^2;4UW:]]..-40b[Z=
FJ0K@6,dcDH,;.a\9KYFFTf0;fDZ=OR])+eKD?9c,@QN3E=>?/E3E7VLd2<=+[eM
28);:>_G4BRYf:5BX^@RWFV.Sf4DOE^W8HfNP4CA36M0H=YN]@6._PGXdYga=6@>
9(ID+..S_Q7?/egL,bME5/7e1N9XC8]32F4_<#deRM7)L/\c\3L)>c)C4?>=#Q9S
C(Sa<H]/YNE>EO1Ea8C(:G?<4EX2MCH#;0(&NX9HBcP^B[GYEa9<A\MU:(Z@7.:&
Bc8)>Pd::.L/H6-a<GS-b6A?9Dg[0AW4+NSe1DCVSM.VQVd94\PR;LP]>eNeDEM/
dc;RA+5L>PZWP,)[]U8JAB?_]C=GTJONCNY.=@2b:7BI5>.&U46Q>0=YU.)@8QaG
9-7#1HB.1KZZ)7P50.g\35[NI\#FEa\3WXbWgg;Z8S?_Z?.7@:c/EI4Ra.IU-[ED
PMB</K4A5D;>DK?YVcO7_cXB]DfQ;OW4)&e>._HYQ5>W3#a\[3+WX(0b^#OS)I6:
-?\0LMPHc[f3bN@C,4\)/4fYN4>4Z&P:U-P^U>O#U(c.U2gZ_b@5RT^?dMO?N7DD
X5d#[M>J,\fYO6b+f>N]-d2+YN-eKFf1,8X<08d#V>5PNS6GcOD2gLS6I/feRcVH
1Y;Q,\0Q6Y3M]2#MZ1(826bSU8Z+g>/0,&c7EO03#6T:4GLIc,ZREd)eT6?SNX/6
c&2V.\)Z,a0&R@<Q[((LL^4B7b\Oc.J:_M.;)96)<fR=9O_PdYgSQOcN.eRO,,>R
7(Q_UdX>.8>F:>H>HURU@^e(7AYGa=T1&&Q#^?^9?C;-P_Z;e6I/6e5DgCJ=EGSN
91a4C:(fUeK=Y2.C[?LGM1EY<U2+Dd52M#B0L.03W2Q103B84H#,>E)R#QcGK\;7
&]L[].7_-2a,TcNcLH^@98b[d<#bOSVA:=.R>G4+<:C-=+e]3<&W67@T4C?QDIf#
O5I_cQNTSS22B0_?6/5GCd&?D8U(aW(I\/(,9+7ML8L2b3=,eU44WCeF#:[]V:Kb
YD9R>TFRM/Q_Ee?L>MHW]J@@3M#&MG9.,8c^TJ#AW4fcUS?,:LGL;391X.b2\+_V
f7(IHS5N0\_CGYVC,b=fQG+6d)LI\2_>RXM/M>WS]L-25aUJLFSaFJH@:Z4_H[6^
]1Y#QQ2cAcfbNCOZIE3^D_.7C152ST+PZZGW@Lg0dGU_bWfeeUNQERcFYD:1T9S?
UG&#MK34#7&,W&a##Jg[9\P)Y\+AM)F3g7-TG?.K,(>e]ecP3g-.]_P-9J-6E[AJ
-0,c1=,gS/,c88T65?c5+])ANP9Q&Z-&?T@ID=[:@Z^)Wf2R?d79d<(CI)-T.fVg
5b#)N48FXKfce(I?(<B#>\_gR@<LPD^V)_WIM?K;&@B;>X1B8FJD02:BXbCLCAJ9
#e-=FgX4,[^/<e7JC@_.A0K:Y1&Za;=(\<N7b-6H>[@X&:R5aT<7&UZf)c5fYQT\
0C0e5SWO>[1STR\DW\LJ_R3]X20@4\aC:@XU_T5I4)10H-WBSV0cC0D3OW6?XQbK
W_:@:HYMJJ)feLgDTGCLQbMV^G^>#8-a,>Y57J,9=WAKF]Z?D0>?N0;#P6>+V+gF
/+L7aUOgYY_Ad0/X3R/7/1SJMH^(/]@b4C98[@+JS^aM<\-8PGGG4X>UYJ+^3#B:
(DL447,F6_Ta@g;?/52Z3,9c+0OU+Y2CGFNbcc)P+(;ZXA=THQFaQ,F;?1+Z\OXV
_JN#[C7YYF:<^1Z67J(Y>Q0\<XcWXM6A12+LB::caJWbXBK6P6/aN5ed/QWY_b^Y
gN:T_&46)_#[NNVgBc#C+G<I.QU2T@9LHc,+0G4f39B[_)Bee#75^]aJaGH#9Z>V
_Db))gF[@g;^JA)S)2I+]9A\(:T[6eG9AU6MXT.f=+7=Xc)J1H9XgRea4_3I1#SK
0E[#[<f=ebYDZ4\AOP8aKG8BDd)Q+JB;76VXSX+&a3L)6S+9(IQ<]8W<&GA\Y1@+
,QEd#7V=87g4@cJ_OD5PUMWEAX,;WGIH-60Ec\YD-L#P7LRQW5_7eIRS\V1e-#0:
?C+<I#.)-(IORXV;3I]QE?]2TYHMd@-^RP1eCN2>#\B[:2[XNRDdTJ2T)WeN(8V9
2BZd#C>@Y3BC;5:YVUK\LHb<Id>N?dY@5OC+eP8)5^;)[>@RI&L.@I4-VO]R>b(]
3EDQ1Kc#;0;S3;/]b<ea-K.M5:QGD/OcaQ#9/MHb[,T;EO1@F<1JS.cgA44CL_C5
Za16/dBB?g.K5FQM5>WBDPG,;C?H;0>]Z=9YIEEH,E3AdQ-[E@,QE+^5c_1,7&>:
,=WSG14fbXL+PEGH_J7Xa??bMJ9.TdF^4Y0-e2gS^1OdN>-bUG/98/S2Q&A_GD9N
^2b8N?#b5T3EIXf[YbC;JeX4X\B7F;I3aAP6E/4S_8VE:3cGRN4;8.Zf5g)5<[,N
2:S0Ed&7+1FOeA=4cQ&S(1b)4&NYS_.V3M?K^I@7I<3J_(IAQa1REE7T=G1?:EVG
@6N>A1<J[/9ZW-BeW;R9bNbPWJ>>(VDTX,#c(@K7g@88c3<V]?ZF^C?.PY@Nc[01
[2\.<g7O9Hc^E=:bEB-Z@]IWL)T2@UQ@JBN/,J=WH0<&OD3;6&f^MS4-Xc+a:04J
aEN+A@=Y>R+TXeY6[I#a)V,AF+]b8AS-@C[G9\2+M3TI]DeV^J.a&J=760UA^1O1
H9Z1d2VZ&5U-98#SE@I24PY:72G+6R\P[N@-TLHUQ8O[cQB8H8,6\gTLU13efYf&
X7KG,U#PK1)5:0SF:+JSA___aMG4WE6-,-?3X-RSN4;T31<+&EAR7&.OXK]^O6)L
g,X:;1[/db[F\BCX;[XfD.N4L;[=RV>eeG1#R@Ua]W.)PB+L5A,KY0SgD@3:^F,T
+C&Bab>U0fB<dDNVgI5H1S#5cYfcW_bBF:&(bC7ZK=:a).fg2MPeSKK/B-E?27.I
S?[aSaMa-S##3T0a4BL#Fd8dZ0eW/GS>:c]bR18Q6RRD?]@7QTeOcYN?dZP_F9RX
?7QeJ(efOH(3<RXAeg<AB>];<42C2M?d(9Q2-Md&4/f+ITYOZ_N0gN7E3#fT-PON
=,-+8U[D+?fgfCQ(-_+d7c5(MX?RB[FE_9(3).AWTAI>NA3?IOUe1ZGS_1-aG5C:
-XUVA=C.NaNb(K=&-.3_O4f(J/4#f<Kf3QREeV<G.C#JA#?fM,2We=XG42W98L.1
,@G&[eP628=TNQV1U-,@Rf;abL1RgE]@7LM,X#93SaZUZ&VC3VG.WN;cWE.-g/_8
600P[E10AI?A/3C)gL0JUf1#-U]Rc)7eTWBS_2bVN5DHQc[]16T8X_9^VMB;=A9B
HWC3U[00)Y\).g@(?^YZTHI<:ZaZK,6);&CQf-MN;\(=[NM@Z^L6g.ML6.?.3YAI
69J;EWKQG#J/)J_&Q@<9NP59WZ)J42Gf\;[aMeYE:SffXF>\CH&[AI3B(8dbEG6<
I=+cONN5/aFU-YS[L8(,85I.IRL7<MBZ-_PNT>\TG;gaV<3G(3@H^cT>S(cQ)?KA
I/d\0PW/R4;V;IHU]5<?fL\6;_WT=</>>LIZ]FS]&(.R;@+ZN&,g9<:fX#UDZ)7:
bS?O0Z#^0<-_O#<L<LG,PB-=\+S\fU5f(E<F4,<->VC-@VI^_Y_<<;3:.@@KAUgV
Ye,/^WMGg&B:NLLK=R-E3V/4/bJaad@fS4#0af/Td9b8_fWS\<5.QLAL#HgAXFCR
+3Z5C\-V+L/=H(G/N6MI8\U+WIDf[f;<+S5\_KP7K.(^=d3cSFSeIE[Hc1>2:L6E
#X<.NG,2&U1f4+YZE6b93WPMR,4Jfe1[aWU9g@=[[AE[&D=E:;MHDHOC\S-+BK]]
GK[[7@b)_GJV6D#GaG1Z&.a_@H#BR2^Z8/W,e+WKd]M\1?CXDCI@Y05c8&:N(D2<
>^D_?I7,]ZHDDbf?63)F@A<N+==aC(]Oab3\Q>+8S&1Q(TQFKBV(_N1b6J?CI]FV
>\.JT9;,]/8c]ee57#\YM(EHCe&g;.#Q1DD4Kg:^Ta/=EX<T965L6/K7<e[Igd0e
A61aEI[YRgV-LKHWJ#<(N[T=A8LeUA4#(gWe5WQU70N>3[VaY:/fE1Ca.>Z;(Y29
+C<BZ@Y8XGg[<OH&+FWRW23TD9#gb?<7H?Jca\F13YaQX:R;52]EK4-GXNOf/\(#
S8ce@FS>P^aKTX<C>a:C@DP>&KEW4UXI^]@CXRZ#-g?N]X12DR2cZBbGRVEDD=)@
:;XefL_A=WZd?0<RTLREP4P>1$
`endprotected


// synopsys translate_on

endmodule

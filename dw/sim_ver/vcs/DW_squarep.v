////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 1999 - 2018 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Rick Kelly        5/17/99
//
// VERSION:   Verilog Simulation Architecture
//
// DesignWare_version: 1afd18ef
// DesignWare_release: O-2018.06-DWBB_201806.3
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT:  Integer Squarer, parital products
//
//    **** >>>>  NOTE:	This model is architecturally different
//			from the 'wall' implementation of DW_squarep
//			but will generate exactly the same result
//			once the two partial product outputs are
//			added together
//
// MODIFIED:
//              RPH         10/16/2002
//              Added parameter Chceking and added DC directives
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
//                  are such that allow simple sign extension when tc=1
//              2 - partially random CS output. MSB of either out0 or out1 always
//                  have a '0'. The patterns allow simple sign extension when tc=1.
//              3 - fully random CS output
//              Alex Tenca  12/08/2016
//              Tones down the warning message for the verif_en parameter
//              by recommending other values only when verif_en is 0 or 1
//------------------------------------------------------------------------------
//
module DW_squarep(a, tc, out0, out1);

   parameter integer width = 8;
   parameter integer verif_en = 2;

   input [width-1 : 0] a;
   input 	       tc;
   output [2*width-1 : 0] out0, out1;
  // synopsys translate_off
   

   wire  signed [width : 0] a_signed;
   wire  signed [(2*width)-1:0] square;
   wire  signed [(2*width)+1:0] square_ext;
   wire  [(2*width)-1:0]   out0_rnd_cs_l1, out1_rnd_cs_l1;
   wire  [(2*width)-1:0]   out0_rnd_cs_l2, out1_rnd_cs_l2;
   wire  [(2*width)-1:0]   out0_rnd_cs_full, out1_rnd_cs_full;
   wire  [(2*width)-1:0]   out_fixed_cs,out_rnd_cs_l1,out_rnd_cs_l2,out_rnd_cs_full;
   wire                    special_msb_pattern;


  //-------------------------------------------------------------------------
  // Parameter legality check
  //-------------------------------------------------------------------------

   
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
     
    if (width < 1) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter width (lower bound: 1)",
	width );
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
     if (verif_en < 2)
       $display("The simulation coverage of CS values is not the best when verif_en=%d !\nThe recommended value is 2 or 3.",verif_en);
   end // verif_en_warning

  //-----------------------------------------------------------------------------

`protected
f4U::0(5#KUTK?&[UYC5P+T][GNb:H_Aa&^W&6fIS)CPb^&K1GBN5).=6Q^X]\bD
cMS+I4V+YN5KNC&afQ&=g]QJLASQ/8aM_1WC(+AU:&PMOX?C-T1fEL-+Q+)JDa/#
(PI^EP0+=g4Q=0a>C<S^&OcQS96ECX>_]-R;FU#=\39.MTTE5G&?V<GF0?S-cH(L
.g_RI4B?:YY=S_NVM#1g&#g>HCX9HAW=H9>73<KUKFQS\=SQb0=^bL[Y@Q)]BZJU
26a/aaL:cDIacY.&06f<HS#eTLMDCb75X\#B7YXQM^19U\b\9SH<CfM^U4Z8FTc#
7M_FW&R8?4ARV.Y]5O05a^_)N.YM(LbHUE;/H?@M?B]?BX?1>MaD,\FRTP7R[A/K
;>HcT0gYZX]B@::0CI_P@=3aXAVRV53;T,9F;I50\L-IObM9Re.f-OE8@7P5dbKW
?BLIa&+&F2<N5JV;V0g0Z:SS7bB5N-B+<-97:Y/V925KU01[MaJ-0Y8#.U6fK?:]
cD)[BcL\cLN<EQY9.)VV9Ef>cL15@BQ#J<RO@4MG?30@7,C]X.28;Gg+.Z6W8Bd3
C?ICJ.8UL5_ES#Y1)UDJDA^YP^Z0F-(g</b-(KO#-6IBS[faQ:FXM_Z>4DL7+4Eb
BHS8,Wf<SX#QO?>/34g6LQ1NHR/c0a)<L?bH0\K:[c4;cUYA):g\T[gS^KRg[.0I
K<3:(+#=OEYA8/9.QCL0;9\QB^gPa=af=:f/Q4Q3;IVQ_c0/^77.IA5D59g[ANFF
3;BN3b(Z<?\BNJdTZA)9F;]Z+#1d+RYR2Z+-1O_gLLM]\(ZY_JeS:/7PDa;T+\;(
eKH<[KLgDMSFE>gMD\B3:>aL;c_1LZb6+4O1^eWY+B7;0IdU#aRZbJZ5=0d5&-[;
LKbbV/D-O4^L9M4:+T)IcSD>99XcO66L.N::J94@SZ[&+21QIN(ab.N36QP@5QC2
f6.K1;0..bE0@_e1)U?\RAFb1#A9;(W,\06fRF\FEH6;c<TL&gf@T+KZGOPQP=K;
DX&\_f(FReWAI/)M9UFK@QaEQKR=O2+?&CgSJM&GT9(N[S;L.d8a=F7CCVKa1/dU
;M-0V<a[5,M)Z0S-)BY9WIK@ZI7E8NU(6V_S^&?LCcJ:@#0C?&gLB3BJ3VYPed?;
UT)&FOOfG^UB_CEFPg/gNL40,R&a00;#dYF3IV8:FW4+B&+(08;-.VF#=8<W@aXe
BXB;d9C<_aZAL,^;RO4=74G;_QU;IHF]fI@2-#GX.4e?1bJGLeYR.0-Fe,bY>g,]
aX=WD5]D<UMUK)P4e7D<)Q+N1H;g=Q>II0S;XK-fZ20GO<@X<JW9\TZ-[cR_eT@3
6;dL>?8@#>-7.9\VZD[I<JA//YN-43A36f(g,bTe/LGV3RUfT\=TB.VP3=F]DLfJ
K.&I>D<=AQ9\CJ[]d)Z#5H,P[.g7_4N160+VK/1Z;6Z5>X7DGXH^(.g04b5C##Pd
FG^(?NY[\.[c&<<VS_>H.((L?^-+-W\fAHL/G6b#07(#,9,<@LT-dV\V3T3&b3G#
A_7T1cXD(Rd&00#)b@-,d6@dAMF9#30V\+gg2B+]J&K0W@g5X=M]X30eJ4[<87>g
HF&+_7<#:JBR#(Tf9P:HZ;cF[KfN?<O@d^=6;AIV/9eZaI8&b/08W[G\G\IBJQ2S
(TH/)6c2b=:(P]<G=MZ7dUW=YNM[c\T>Z88-IV\Ic)IS>g3\9fS,Z\IeWgEU<S[G
+GH/ELKC^f_McMd_>O&aJ15#5GWH8U[BR;^;]db?KbOf<BRP:,,=NN6>/5J;.H(B
\G\Ye=[7I+M&6&9EB=-6:MO/28bPQYSK/7W;cMcI22[dcd?e[,00:5KE8B>EJdTd
7\L;80>GP#YG6T=/.,D?D;YQYFgN))R)?e<30DcBR^L&^9J@5R3I4J?NQ1RbFE/5
+bW8D]H_L?&#PN^#.L[8(6d.9agY&Rd2+GM6\2IBGOS?O;=:E]:GH]g].8<97GHe
AE<P8C3:)OeIg.Z]3M?A]cN,g-aCL>BCb_W[FEGVMAc<U<KJCG3QdMEMK>>+Y47G
,F\@[XZd^dJN\HD_R]Z&[PBQ1KD<S0^R&,YX-35JaEBQ_E#]6@8fLc9Q1O(g1g<W
\(<5HM#bgKUFW/BO9W,0L\D\+g6\J,ZYZJc9.^761gXAMLY=V,XR[#LJ4N9]P#.H
Y.g??DTC7ZH==R6?ACRd##B#?d?5IOIU72LX=J\D8XZJNf(-^<::fK\-G0K<M]LW
2RW3JW\7P<R4f.BAcQ7b/C6()2&LY,Gc_L>C^J;L./I6CL9M2KU2S;=b<E4B=)5f
Z>1:06e#/NG,B&?Bf#?b+(d0WAH:8;D5D33]84+&>Yc(3ES4g)Pa(<8?9g.b^/5T
^&6&KA+gaP2ATRFQ_\0OZTVW#C;E+QJTC0TIa1?1Ad;D;Q[A+YbcBAcBFPK,W:WN
12S=2Qa\dO^_S)[L=9PBZ)a8Vg+B&O#9Y2#[bcIB5^FQL8WCI[JOS>O1K/J&WW&0
M7g(AEcEI.XS6C1.c&_&JYR/I_@O89M\>@TBb9&_VU30Q-gb,U9QKOJT<UGG2,6K
U#KH(b#HENRDcZDILO+-\Pa[SY2d3^1>)<;]6=_M5-geMKJ_-_4b5[.dBOF6KgYe
X#_XR=8_^P2;bf.C<;e_LTQg<+YCdV)87J2KLNW_KTQe1g5Zd.V?TOWQ:\<0b[PT
S1[H+S[CeHfIOc[->GaKW3>J1T1gdeJ&<AR>dM/ZIURHg.57G0#8ALe4gb3T_A^e
R-A:LZ-eW/3T]SX)4E,eGHfJ3QM5K[&g>G&SKMDDgD_)KQ>OK5,-54daQ;/-RaOV
9&[Q1<0O?CZD)Q:O5[S/OOG)NYHf;D+fdQ@JN4C1B+KYf1.U]Yc@1)X^M^aG:V3E
^b@-H-RX6_56feBU6S;d^KH@g^HPJ(II]VT5eKN?a=dQ_g:>/ZFDCIM(X,VFOU;T
__KfW]89AM/E6M^7PMIRaE-)0NF)a-PdZ^P[+cM:/RYIJV>C7(C9CX^-]_[-[KIO
4:G>LcTPNg5E-OX+YB1Q7TVJXa=G)N0X.OBPGU,O_AD^e6VU5LE]D3FG9S[Ag#T9
Kb_&DP_#d0aC/&CZCd@[4N#-bM+NJ7,eT)TWf0&./+5RN.c?FaZQ6=0W_9N;VV)B
?S#^a3EL[)82,VN5ReJCNGQR#M@SL6_6AP+AL1[L.[DCZ9EYbEgBfKNeS=D\X0b<
b#W7WdT73;M2NDX@c89GBTT<&E)S@?X=R0VF&#Z\(T&I;JV==aK56FfeWWUD[L]G
-<LXaT1)U#N@R]bU(V@g?W,3;.E3).LN+CIPQ5>I_NZCAG._C,XLEeO0,?/7.IYY
N>1?Dc6Ze30d#gE>UPEY,fTeYe?@L)-(JLfQL_=5fL(aA#V3F:_0]f]MZaNgQ)&T
FJL#HNcU(@?C+1RM@UIVHR:L52<@:1e-9SZW7./@]5HHC,Z9c^?+QL7#GE]fB9DM
Y0(5,C^10X,QH?R2J^Ue21T<8B(MB5K,L^U2dN6T:ZI&-OB,[c3:C,eG29#B(9S/
6fW+1@I\#Nc1bM6,=<)-S0ZYd#@46O/&_40b_.VcT>g:H7G_+VSJ^+4SRL,?c6\J
GS(GPa.[&>Yf4K?bFfR@CC?9T1G3f8O7C_GUNYE8N=&HdG1.7BIX5\eaa6-fXN--
SLIN4XH<e@NT8a]:@\BIA;-92Gf6?a[0DHH&RN@-OAd@9L)C0G)d9Te-@\^?;+SF
BfB@LJbNb9>054&4_I2;#.[2ZYQ[BXJ0:MaC_.OX\SDPEf<X9HLJI1].ffCcGJ0_
QW[a-AS[2U5<;@J2ZG8E-Ug77M:#4=QLOdY4>JDYLD;QRB-C5DSCY.UX16CD<WBN
Z/-\1\L1IGf./W]9@?T&(2,A9faCOeAaFU.\N8&;=]0e\)FU+<>fP;32d2P:X/g8
MQPZbJ44e,XJ]@ZOC7U?ZFf^K(PP[RL\CBOWFdMJ;#-@H/0+CH)3W\JB:9MT(?<g
YE53@6P)F5S]C=JKWR66bZ=1e]?9-g>8^5C[&8;[U0@K@N8)K[I)@-#\IcdYC.K6
BY#&OXce8>X3W+LG@e;<Qc_d21AQb69.OFgf=8I67g9>G>[C(^@e-f):-F\BS660
V@DR0U7QELWI.LLd5TK^d3b>_\@:;-cG4dF[0_)[F00gZ<9WA-^@_WLJ5WU#0a,S
2W0f\GK_gA_/3^1)TTBS4>@U-^/fF5;Gb/3?MY<f9N9@:(<@:HJQU6EBXK;<VW]T
&JZd#8QBB^MYQ+\aMET,I\)eYF\^4_5/BUZfGTI^bG+TKYO?6g-PF(U+TaZPc[EX
,J_T6)AMT<O&QZ/7:,PXbI#_W[P-cWK2ASYI&C]4&I,d>3g26C(9IB>O)FB3QCWH
K->D&2eRYZF4b=3\17?RdR5VPK?@=#e^c81(XD35W5<R<;AfB4^@YSg9+_32/.Ae
[KFQ.BQ_CQ#\ceC&Z_ND>aK&PX[G49b>-1\SX6VbFQVQ\AZ)d;)=\eS6JT:U[0X/
V^ZDJ##EKFNU#4R07KI(_FAQWQ3^_:KO,G:3;G/[NL;Ga=8(c+L=9Y;4I1L-@ebC
U7b,9M35fKN#If4g1C,;e^XTOW]@)L?bP,TOYD>6X,F11/1a3[[0gZ-&VQ,:^&Re
[;4CQI)UUCFGZGH=@WLF.WMG#g30aS4M6(JU@?H(R;=76R5E27?(aU6+)B>Q_.,V
=N3XEW.&R]E33GOUV:E.6S&-0^(1G5A#N=:L_FI1975&QXg.-\>]UJH+d^6]7<\+
N_D/2LUG@UNCNOUdO3DC<N0FY^G9XT#RD>U09797,3UP>+JD_I@:=0=J@ge-L[?S
]feC@2A;#a?=B&N/]E-.OJ8Z96R[/Y,ZId6?UFW>J:8,>Yb<8c0^>;_fYBUf?82Y
I6HPFEQMFX+M=R5615E&7L^55g.0?9^\/07:X9O]SK@YQ/^TA:#MD\U=)LK^3ee4
=MS0Z)VC]\\ISCUd\bC=LSH2W0EUH5C#c+31Ud8O4cAOGgOYRC#IQ\^)>LLPX<BP
<Z5eK;:MZMXS45a:/7B#<5\H1T6)7J@D6dCOY29@X3K02PYIWF<WM12cc>P^X201
++QKFGG=.C3e<4H0M9N?P2G?@QF2V781Hd/A.KXVfVM9(FD8X?J>/NA]00=3ROf^
AA^?KV1^8XAa\2)2&N9^IA\]e4RN@fCA2E,=:&T7D&D7:WC0NSaJa?CFIDfa-XC[
USWLg+&8]>SfH_E\,Yb6YL+E?J1P@9P0P_E^YTb^Nfg,eWW78[KDNWVW(ND&&\B.
P=\VDK(e_8642=[EBKNU&J,+?.G^/5a3>eU]U[Q8ULWFgV:@ZPKZ8Wa^OX27c+/6
GP+1Zb9;NDA):BXYM1&g5.e;]C32E]gI1P\2Bb=^JV-<1a1NT-?(cV#C_5W6:2ZR
^a#f51Pc+A.A/d17Af@0SK\.,(NT&G#5(6dT<F&C.<@ZR=,E72P>.K?Mb=N#f-&3
JPCXX2/<S9QB<NX>^\5g(1PD/216XF+f(1a@9DP;ZHd&(EF9Q4K5:=b&C)/&G5[#
A:056e=NGfeOgUF>BY;cD_7aNHPc+HCMN\+5OBZO/C72BVG_0b\(cN&::VHd0gbP
\^B5eYGe#>M;&@(b)a.(50Ta>QE,@5DESXad1,,0J+VCMPM8fHU]e2BPG4-cbeN+
AT1(1JbeJ5/bT.A[F1^_8H>])B6,dT\YS)=4C;Y)1;1f@(Z6H+&V(Je3PJG1=_]5
AK9AHaP[Q0-.VC5M2<+1#FI0M^Kfce;:-f-TZZD,:QELg>^TcS<K?e#Q&5TVBfN1
1NRe]5Og#H>Fc[M09gRbE6MHT\c1/be27WeU3OfLS]<@9OUD;WM4PK.SY&RVPaU2
&Y1=VIb8a]bH\)9LTG2R)K3LVKTF?DTb1dOWF@D6_+C5-&N<&1Q5,^+3g9ULPY[S
We(Q9L)1TJRb/O+VgeU8STSYNNF_>9V^C7K8FR=6F[#EAWE3-.E7QRY;7/J0>[UL
X)6O7F[JF3dP,Rb@]59+GB9gSKHDfO2N)dcRZAe5YW[g@;Ac@6[Je7d3BS=9.W6;
\LeYA4fEJgg0:&T1deY;=J;,dL\[e>ID?I5gRRfXJ9\Yc.,E7U&Re_,1P/>Z89@0
+Q3,LDMTI[):H749+Ad^5KUAIDN3;E6Q;ZNTB_Y1:#XQMSK4I8EJV_>MdMEP,TG\
,&(>1V&O^UaW0bHX[.#(Lf.[+b[I#T+(@),Y9T0MPWG\g-)R?GcJ,&Jf&0I#)5E1
4e5P/O8<Jed#,dFN1OC]R3:M4>1I_VNB;6\XQZU2aQPb3ZPceGG/50VRW71S+IH^
BV;eX[EGB:Zc;G;.(>^L6E14:>D2Yf?BfNg/;Y]&4;>+##@J:BL26A>>&)<U&0J(
NMb_7(BEV).I0N31F3d,>#_f[BMGf1;9A-X<4,5V-D4J[=1aW+)UEKd,_W7YP94e
fUKaKMQ\J(_:H0<]X4CBC@RAZE@;EO,O/_GOX3J?\&EZE/XTX/1,QISWPg^J<&.3
G4>P1J&7DI),c1DQO3L^Y6e[SVDe]6cVK[JJ.:#(JP:U^;5]7;A=W4^.Y,FfaU7,
gX,O)_Og&UU+=a^X])@bLH+_DOQ>:@<SHdY3a\(G_&#49&a>09ff:@Y\3[](<&2_
JOTS^c5g(fB)IL(O1H)e<[Sa/H,fP+CX1NYLPc+^IW/?UY:gb5V&,0(3?4(3NM4)
3ZfBD=5-=)<=3bK_O^Aeg\;Z.D=IBFKa11APE9-e#XP898L+46bc[AVNG+/P(Z\^
U.@KJ5-JU#NVPK(U045ZS92K<]>+RL)&0=SYcT6&DFI(B[@K([3g95A<-VVFSI;N
+4?D9:N@3H>Yf_,ccf\BRJDF;bC75#^ULSEIRON&.&g=Q?ZXM=COY?OL<NTKU[@.
:2[XXBU7bY=5UK[,697e=T]KU<d?3G:D5&&^[b5VSTMN]UV?.R]MV?c]^eM7_^VE
([3PZaD<<D/;N9PC7cEO@;?7bDL(:RG=<d\M2_BA3F8f4^]f6Q><@^9Rd&HU<[][
a3UIbB.(/TA7WN/UX0R]N^>?0a:0E&dea=J0L^]eTMBB8?ASPOOQfL8c]eggPDNB
+6,R46)bK.DG,EAG67=V52-g@)L;)<94^.71UE9IZI?b?+a?W>N&AY])XM#c8&c8
dE2>Z/+&NgaO1]-5Q5Y:0OV\f9//MgfGZYC9JYKT>9)-A]3(AbVEHX;[cPcaVbYJ
IJJB/d2PNG5VX(HXFR@..1>;#H>B)-T()G9dGNdB<Q:8OTMJPdI\;A.@Z=&Z.K9C
N6aCPK>R7^\OSSQ-/Z^JQ5>-ATXOGYJ,V8-IM=4\a&Y<Q)-65agE=<550Y6Q<+NZ
#D:=8K6#4Hf,>45N3UN=1,EfM]PNSPPBI_RP;XE=:(FH=_.:.Y[F?2BTB+c9BZ2Y
I5L(^R-<YU]S:+MeR/RZW<Pf)QR<88_g;FZ674Wdda@,K@46(VGa(V;+O\]:KNG+
[b#QK7E1+bD>Ne^2U7KbUb\D2:->?G^[?RWb/(WF=eVD<^R.RF0_e?PME4X=>SEf
7^)#O)Y1J,I223+J4LdZ?I\3>WW6Z1_JbbT)<c<QMGfVI])Z91G?18)gAJL)&T5,
(RfZ^e=&OT\G<.#b>USf.YDR_I&-X0U<[S&[]aG6#aF<B9A/@dPKVKZLe9Y1AP&X
6_g(K2]W?Ud7;9Gd.13SeS?3-B_QJ-W:,>AUXOG#H+bLX]@R/Kd8CN-(I]M_8S48
G_L6I9?If\[deD_9L^c5[@f&@#?SV?7eV+017gE.Eb/1Z.G8I.H-C]Y#Eg[#[Y>b
X5-\=GHb]^.dN<^Ra/&Wbca#8>6Bc&G4CEJH4F1UDb4Ad29Z-XHMg535_<DD?eYA
C0V4#D1,^9V;.40P&d<=fcPIJ23K1HZ9G2H0O)_38&I<RMO^7IXfT\?..X;E3OV/
[QV)5UgK0)Vb6SZ-.4W7?>^QU?^W.@?E=M+>T4D.I8?KEKB1c@,e.C(RACdDQI=;
Q5;RefT9dQ4=VHW91@X)AC\LOXcB@#?#W^_26V1)0ULBe8G67\8B2U0fa58U\G&D
OC-K6deK73A<I7B5\]]g<U&<dc5gYecQPA:Ec-[cZ>[gc_[,0:LAA[K/b(7#DD9M
UNeD0ZUB[&D(:68R^43IUCPI2TXVOe>Z5=>JYSL,FbUC1^,Yg&2=2)SE\RE&0-X@
HcV8VF=K)d=JA0?-2DUJ?T;4-EEb0QR_P\2:aT__WMFFZJ)7Y(9??G]DeTY?I(a7
1&ND<D.0+2SCFO#S1g=FDcW[1JOP.8]I:AMB49Cd7N9R9HMfW1;KPCPK>)3P15LN
@B-D7FE(;J(OG5-)ScX3eDLXR9aASV]RB.A_6K8S>DcfUEMEH079/.5#(]Z<Zg[_
a,SF^a5-BSa=QO2Ne8gU^/-</O&W5)aMd+a8WZAP3S-IO.d#,a(AYQR75R(AeA<a
=WT1R]E4Z6XQG5-=d8?4Dg;K<6G]&RA9GYLB11D&:X:M<]07KCW:E/C;&L_Ta76M
?442;Z?ObfJ\\d<0O]Q_T=9UK1cJU_Xf6M4d[;_IB&D3Q<CC@,:(_--)A0_.2]M?Q$
`endprotected


   // synopsys translate_on

endmodule


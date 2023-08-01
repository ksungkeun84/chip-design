////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 2001 - 2018 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Rick Kelly    Aug. 7, 2001
//
// VERSION:   Verilog Simulation Model for DW_ecc
//
// DesignWare_version: c7646384
// DesignWare_release: O-2018.06-DWBB_201806.3
//
////////////////////////////////////////////////////////////////////////////////
//
// ABSTRACT: Error Detection & Correction
//
//      Parameters:
//           width       - data size (4 <= "width" <= 8178)
//           chkbits     - number of checkbits (5 <= "chkbits" <= 14)
//           synd_sel    - controls checkbit correction vs syndrome
//                           emission selection when gen input is not
//                           active (0 => correct check bits
//                           1 => pass syndrome to chkout)
//
//      Ports:
//           gen         - generate versus check mode control input
//                           (1 => generate check bits from datain
//                           0 => check validity of check bits on chkin
//                           with respect to data on datain and indicate
//                           the presence of errors on err_detect & err_multpl)
//           correct_n   - control signal indicating whether or not to correct
//           datain      - input data
//           chkin       - input check bits
//           err_detect  - flag indicating occurance of error
//           err_multpl  - flag indicating multibit (i.e. uncorrectable) error
//           dataout     - output data
//           chkout      - output check bits
//
//-----------------------------------------------------------------------------
// MODIFIED:
//
//  10/7/15 RJK  Updated for compatibility with VCS NLP feature
//  12/21/16 RJK Relaxed lower bound on width (STAR 9001134170)
//  7/14/17 RJK  Updated UPF specific code (STAR 9001217597)
//
//-----------------------------------------------------------------------------

module DW_ecc(gen, correct_n, datain, chkin,
		err_detect, err_multpl, dataout, chkout);

parameter integer width = 32;
parameter integer chkbits = 7;
parameter integer synd_sel = 0;

input gen;	// checkbit generation control input (active high)
input correct_n;// correct error control input (active low)
input [width-1:0] datain;   // data input bus (generating, checking & correcting)
input [chkbits-1:0] chkin;  // checkbit input bus (checking & correcting)

output err_detect;	// error detection output flag (active high)
output err_multpl;	// multiple bit error detection output (active high)
output [width-1:0] dataout;	// data output bus (generating, checking & correcting)
output [chkbits-1:0] chkout;	// checkbit output bus (generating & scrubbing)

// synopsys translate_off
`ifdef UPF_POWER_AWARE
`protected
U3K2)dJ+JAF>gBS\3V1AN4KZWTVH58#0_+Y]gF@JF((EJgH.?2f(4)>ccL,+&f8N
[TgGFVf3);B9QOW?SQ^RO?0ET,HNUZ6/cRO@UcP[MK-@3-68EG>46[><aK?994CQ
L7,#ZU[0+(5Z]M3dS0_>7;dN??eO(A2RDaV9G7bKbXD(NWFH#G)FW6#_cOUQWVYQ
Z,E)<Fgg^gP&#Y_=A\&d0>6&;Gg7)BCAJeReL@2Paa:6:&9T8P;E??7B2JXQA6+O
f].A.Lg6X?e4MNCI_E]=Z;b91UB)FMC]0)4J.MSL3_ICUHWC8M;bH.GQ2R-QO&L,
;B8I4WC:,^&7?I0]T-68Og11USgOed^[&2[TK48SgV/8&Hff3W=.N+I;Xd;6L?0/
Fff-]SV&0LVWZU@QU<:?d@Q&A>BPe\6/b@6_cIEI5AR.,NEL81Y:>4Y[/;ca/R=P
gU?fVbV&Y5I9a@b=UN;Ke^,>YLMHSS@NO8S+BDGe:@\^6d(IK99FER0/e\UJZ#1]
Q6(NW:X)L-f3fD/[e,c.;]HZNKE_?0./3&VJ5VcIB\U0..6fRE6U@V#3#Y/JG7U4
gg#E0NP5]E:IC-+5Y>>G39(>+(@TU,C(<NeLBNYS@AaU7R_2\9XQ22?S.[aO]UR[
RVc=/]bO?D^JgJM9C3LFQ=Q@Q-+^&EfL@_dV[UEd0ZCFP_Z.2,fYX#Y>)1c30+QK
/+c=-CR<\CV\T\C1[<XBQE7P9WGOE4ISAfD-PeRP>c()TDB#9L1B22UQ(>/5.=2d
(R[\2,AV>1@J1FfBM<Y_EbJeSRRI6W@-9)YP_[3^b6EI;cYb\66,F?<9O-d&^]J:
G@,D#(AdDCb&[&f^LM<Ue)D:DMd)R0Mf-77EC4Q:PX4\8:8M3JQfABdTdJ9R7ZGP
A>/&(FO]T^OZA9J)_5<Qd4aU+F0XdOX0A5-L5f7#[W_&=F.,9bTW\69QX3N7DX2^
:Z^\BHLf@Q;/&)_\W^>,LFV)#H-CbS3\\TUS22U^+eG??34XB]H9)<aF8fPZROCa
MQLB.R+Y=4.OY]I2&&V2V<7.WKAd@QdK(+E+7D9e:>Z8[G/,J5V]\1J3Q#(I&ZZ=
5\_H6NR:]67B:WB,)Q;)@?J6;bH)P>>BYW-#E:EOg9Y<\-@G#7.V9KH/X:0YaaW\
H#g-#,Ab7OH.&cg7OaX2][8_B?A,G8g>)Ne#QFS<7D/])?;VNKZQ5dCd\@-A8:=-
1/Zb_caQfgJ+aN)&/Mc\3FfXVC8A;4CcD?MbHG^;Q9cV4L\Ia4CYKLW,7SRL?V-N
_dc_;6eEOgP@&]VU:&#Y/7+Iga(^YAR,LO7&]F>O\bVYIR-6UK^X;TMMYR^Q8+B,
JP>4IX_XSg1@WdK43<X207XYQN\1.Cd(E2H1SI#3XI3K2aW-+Z>b[7]3-?I>YB/=
2RW>>b3B]^=8IV_KN/DcN[=/aE,XccIBD;_N:IN)FGQ1.S+&P/K6[[=#)bDF-4XB
:.V[OU(eUC_,6_]6IXIZ6^CM6?>I.PAd_:\eNN:LEbF>D1aZ&+SK.ca/W+eP5P(g
V971-)@H-RbV_PB6ZTZD6U/;WIC687eC?J0N9e0Q)faGFEI=ZLQ;:Ac:PJNV\D+4
(X2;ZHPFUD>\L5g-1;#1/NHOgL(Z??\]SHK&I-@6)Z\Y.(;(+S7c@8RME:J6(QMc
N(4PG_KMK/2TK<3<4:1@)c8)@@L^;V4VH/SGNHPD/T3=D-42VX/4.F@&ZOR?a6CS
\T:.d>P>O>45U3cQ17P9R<T[f>fR=?4[;F:Nb;E_#MA586,MGAfAPQ?+0Wg./4\b
\90E:VXIS6Ig/JI[W###H_?>2=FYSU7(>\MR;05I)-BBa3,Z)M-CMf^Ge<+)12T/
(XV>WXS6]]2/0OdYMQ2;7f#40XU)f<[7V.11Z:4+(8L>bgE9R<)^D5#SdKcO2121
IQ709(2\FJKA,;HbHRR/=fEBZ31De^HQ3Qa9GTU0d2_,+#g^L9Z;+6X5.6IQM;U@
;6QGe6[4(_De7L5G+L1[OORCYY^_,<+\e=CEVd0I7[aNR&@488_a\/beM)8C=.[\
04POHeSPVI/cV[:&M1>:A@(SIH49A:b:>BIdbdb<YHfWRc#><Q@[/],_R]O19Z=X
N;MXEWM91g@QJFbBb7.5gO-64>(LREVRWZ=D/4[<DOc>G3<)FB@B_K/FO9a\#AS7
A+e=bXWAO;XaLQ_+eQW(R9(eP09fOFecFEP?b7@LP)S,<9A&1:O_4(IHcNQ<[N(c
I+]K=2BEW^I<<@^D\8G@?)-P/]\LI:5Y[4Q919NUbOCfb?IUS6DU,<HOe,I?6W+3
Kg\;=_=<]_dK<_Wa]^9@<W.0UM9?K6QWHF^<93VR3BTVdecEU<-JMX#\NDVI3[8T
(X/Y3XZ;Ia1,@&U@E2.(a0]Z3;Fc)L5=XG)U):_RM>F9BUEL?a,Db@W/#90OYb<R
H,M?gES:HPe[?[@?H_0QFdE\/;L:+\[YN:)0L>_#Z.]TJ2[CbM3HO3eE2#A3ZG=-
PWG+1DMN73B,=Ve.I/\G.5)[BZW0eP#=U2)eT1?<JLa>2>3\,&PM^61^[J&3\V_g
2MBHAMaRf@[,Nb((XfPVH.T]D=ZW2^G4)1HLgdK?G:Z-bb^1Ta&R#.O01^6AfU.M
1aI74P4_+aR_N^gH&\92/3+/H>:3.I<;.>3J-e3aF:Yc\;f5T&UEMW]NF+&J:C#G
#LNc((BMb.\dTT1O4&MgI]C0)B)=FOIIV?d288]^36L4OG-d4I3R/[D=@)[;b3Y_
&8^Ye-2YJ;>5\+KA==I-II@Q34S4MPZbTB=152\@8LdIg?L++//;E49WQ98bHN8A
9CcFEZgfNc(I;7=-.d5GI7C>I];5-[8>YdgBObdH,H7-FD5-+]bgLU12dWS3.4^.
Le#R(-0(;:LgHP?H=AGb@Y50&S]:><#MG<P<CD,81M/;YC&d4=&<W:;17N3b/VO1
fbXIOZb/QPR&VaO]b^<&R9R#T@<GVEc70>EU-0LMJ6:O^9g#KJFUaeMI)ee26I\;
U]</2A8R1/VGA,KYg3B4<QV-#66JZ;BaJXG880N8F8V[G_G;cY[4E:(A]+G(Rg;S
?S:/#,V&B4=;I0U(@T&<Cg3CaS&1cX\LT9PHQVM_E/&/9,e;R)04Pb)T@U;&A)c,
,(47E(U[7(KA(NJCQ)bF(Bb-TH4K:DFC1CJW))^1IMIQMY&D8LJBVdAHfBSGGYcD
Z;aT@;]?gMJD\=gU@8L#(B?P4Z16K])&S=_2XTCd-J;1Z)E)<(B</2Q<gbcc:c1H
9CKYKHB,]d-a-17[81T\7Z(G]G>;UbU6cL<Ed?@\e8:<BKc4_9FCD]Kd-gc#LV2&
\\AH#HREL2H?)55]A?QP+gA0#95a,6^LP8MZR5.1I\64H>#4bU3@WC(d16#M6c5c
(MA]2fU,^@WGERC;SfN.2fa>T,V&ZOZ7c:4-4ba.9g2+M((\<B;@H]\(RMcYNY@A
/VTGK]VLOcD_Z5dT=XAEL\J@=XcW>E6/V-DCQK]9D86:[2aTY3-B]C22&GT1(0Z4
BK0:eMQHAdG,?1F9.TKRff+.0U2e.?#?H:(6)^cO9LK/K_D;[bY+GZP^>fO-f),a
J,=[AQ-F=?\HFQ+=bb9L9-:KQ;^BM2gWGZ5#gLZ?7@U6_\)(Fe]4=D2\C1;dd>\X
gTL&/BU]ENM67aA.fQP51R#5PY#LRf8\6=\GGJ[Y,K#Xd.&FXIN@</Z:S6Ld-D#B
JOH(<(5&_8=@CeZJJ>ff)V26?LQcVd2A6?#,:-Xg(+9S3C9:^21eVQ6_76ce^.d,
.Ga=9+C><a\-27X:/U2>f8752VK,@D+K@TZd(VLD5A88I:Qb(P:FY3W,(_5AW/?(
G)+UZ&cTI7f)WP_UQ5,(#d^=/1YBgPbZUE1fE2N;O7?.KI@:fUM3^DKD/AG_4#8Y
W#GV\>B/.YgC=/+YQ;T[4CMMW\;+ZMGfH@8A:@\WZB,a,Me/,WIZSc7&N6)Zf+a[
(QcEC\G.,_RZWb[.B3\MacG(8c^X?LG<:7NXf[)SXLI)(Z#Fa/:AUHF8_33dHY<&
b,QQM8=XS8eU#K(@KK\+&b0J_<8V38a05Z4M3NL3VQBg,Y)SX@17Kca]:g.)LC:A
\(LE9e[/7d.<g5U-(@&,OVS;,USFNR>P,3,?&ZAe6YBCK^U^;Mf-^.P60\B=W/P:
b6><2KCcD#SBS&5cA,+?)BQ.Rf.86YMC<]H3#.=.?U]:BeJGe5=Q>Xc_eM93_Haa
>(R+(IIO[EbG[/-+.#M\]ZQ0-WCeUB.7B#4JRc]@A<I4[(dTPCSF+6Qd@TTX]>4\
c.1?4CS&8C&EY^7g]&D7.)Xf\cIBb;4)e#c[-6Q+fO.)Ne_FA#^b-A=-AF24_?W0
UQXbB,9GMYdd51\?&^>(YEP,)=X4-\fJHD91\BQ:VA^>g-[b\JUER.Y.b&/^@=,7
GdH3aLAVZA^6>Z[C_)O50a^=B>5C57=G__P^I3e5O#D3&FLET=\UDW8WHKM6N+7Y
;cf&8(Z7N]4D1/cDZ8LLEX@L:XAJH;ERVc7];Z.HM,)c[J7bSB)F;QFaZA;>Z;P6
FNe1T_dS:J4@#WP-#\=<)_6EI>;9/\2_25CTA&K6X527#0CI^F.I.D7#C/#;Q27T
BB6TN)OMM#98>S[=9M,#<QDXA?)^J3.UaJ7ga]E7K8S2IV-W23;#201D[:HB^+T7T$
`endprotected

`else

 integer OI11IO001, I1011Ol00;
 integer O1O00I001, IlOO01011, IIl1lll10;
 integer lO0IlIOl1, O1I1IO0IO, l1O0O110I, O0l1O10l0;
 integer OIOOl1I00, O0Olll0O0, l1IO10001;
 integer II010O0O1,  lI1O010l1, IOI001111;
 integer O0O1O11OO, O001O1Ol1, OO0O101O0, OlOOIO10I;
 integer lOlIIl001, I11000011, lOO0lO1O0, II1Il0l1l, l11O1O1II;
 integer Ill11O01O [0:(1<<chkbits)-1];
 integer O1111l11O [0:(1<<(chkbits-1))-1];
 reg  [chkbits-1:0] II0O00OIl;
 reg  [width-1:0]   IIO0O111I;
  reg [width-1:0] O00ll11OO [0:chkbits-1];
`endif

 wire [chkbits-1:0] O000001OO;
 reg  [width-1:0] IOO11O1I0;
 reg  [chkbits-1:0] OI1l0OOOI;
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
    lOlIIl001 = OI11IO001 << chkbits;
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

    for (IOI001111=0 ; (IOI001111 < II1Il0l1l) && (lO0IlIOl1 < width) ; IOI001111=IOI001111+1) begin
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

        for (OO0O101O0=O0O1O11OO ; (OO0O101O0 < (O0O1O11OO+O0Olll0O0)) && (lO0IlIOl1 < width) ; OO0O101O0=OO0O101O0+1) begin
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
        for (OO0O101O0=O0O1O11OO+OIOOl1I00 ; (OO0O101O0 >= O0O1O11OO) && (lO0IlIOl1 < width) ; OO0O101O0=OO0O101O0-1) begin
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

    for (OO0O101O0=0 ; OO0O101O0<chkbits ; OO0O101O0=OO0O101O0+1) begin
      IIO0O111I = {width{1'b0}};
      for (lO0IlIOl1=0 ; lO0IlIOl1 < width ; lO0IlIOl1=lO0IlIOl1+1) begin
        if (O1111l11O[lO0IlIOl1] & (1 << OO0O101O0)) begin
          IIO0O111I[lO0IlIOl1] = 1'b1;
        end
      end
      O00ll11OO[OO0O101O0] = IIO0O111I;
    end

    l11O1O1II = l1IO10001 - 1;

    for (OO0O101O0=0 ; OO0O101O0<chkbits ; OO0O101O0=OO0O101O0+1) begin
      Ill11O01O[OI11IO001<<OO0O101O0] = width+OO0O101O0;
    end

    OlOOIO10I = l1IO10001;
  end
`endif
  
  
  always @ (datain) begin : DW_IO010IO10
    
    for (I1011Ol00=0 ; I1011Ol00 < chkbits ; I1011Ol00=I1011Ol00+1) begin
      II0O00OIl[I1011Ol00] = ^(datain & O00ll11OO[I1011Ol00]) ^
				((I1011Ol00<2)||(I1011Ol00>3))? 1'b0 : 1'b1;
    end
  end // DW_IO010IO10
  
  assign O000001OO = II0O00OIl ^ chkin;

  always @ (O000001OO or gen) begin : DW_I10l100O1
    if (gen != 1'b1) begin
      if ((^(O000001OO ^ O000001OO) !== 1'b0)) begin
        OI1l0OOOI = {chkbits{1'bx}};
        IOO11O1I0 = {width{1'bx}};
        O1OO110OI = 1'bx;
        OO11O110l = 1'bx;
      end else begin
        OI1l0OOOI = {chkbits{1'b0}};
        IOO11O1I0 = {width{1'b0}};
        if (O000001OO === {chkbits{1'b0}}) begin
          O1OO110OI = 1'b0;
          OO11O110l = 1'b0;
        end else if (Ill11O01O[O000001OO+OlOOIO10I] == l11O1O1II) begin
          O1OO110OI = 1'b1;
          OO11O110l = 1'b1;
        end else begin
          O1OO110OI = 1'b1;
          OO11O110l = 1'b0;
          if (Ill11O01O[O000001OO+OlOOIO10I] < width)
            IOO11O1I0[Ill11O01O[O000001OO+OlOOIO10I]] = 1'b1;
          else
            OI1l0OOOI[Ill11O01O[O000001OO+OlOOIO10I]-width] = 1'b1;
        end
      end
    end
  end // DW_I10l100O1

  assign err_detect = (gen === 1'b1)? 1'b0 : ((gen === 1'b0)? O1OO110OI : 1'bx);
  assign err_multpl = (gen === 1'b1)? 1'b0 : ((gen === 1'b0)? OO11O110l : 1'bx);

  assign chkout = (gen === 1'b1)? II0O00OIl :
  		  ((gen ===1'b0) && (synd_sel == 1))? O000001OO :
		  ((gen === 1'b0) && (correct_n === 1'b1))? (chkin | (chkin ^ chkin)) :
		  ((gen === 1'b0) && (correct_n === 1'b0))? chkin ^ OI1l0OOOI :
		  {chkbits{1'bx}};

  assign dataout = ((gen === 1'b1) || (correct_n === 1'b1))? (datain | (datain ^ datain)) :
  		  ((gen ===1'b0) && (correct_n === 1'b0))? datain ^ IOO11O1I0 :
		  {width{1'bx}};
  
  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
    
    if ( (width < 4) || (width > 8178) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter width (legal range: 4 to 8178)",
	width );
    end
    
    if ( (chkbits < 5) || (chkbits > 14) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter chkbits (legal range: 5 to 14)",
	chkbits );
    end
    
    if ( (synd_sel < 0) || (synd_sel > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter synd_sel (legal range: 0 to 1)",
	synd_sel );
    end
    
    if ( width > ((1<<(chkbits-1))-chkbits) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m : Invalid parameter combination (chkbits value too low for specified width)" );
    end
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 

  
// synopsys translate_on
endmodule

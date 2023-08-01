////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 1994 - 2018 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Igor Kurilov       07/09/94 02:08am
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: f4092d46
// DesignWare_release: O-2018.06-DWBB_201806.3
//
////////////////////////////////////////////////////////////////////////////////
//-------------------------------------------------------------------------
//
// ABSTRACT:  LFSR Up/Down Counter
//           Programmable wordlength (width in integer range 1 to 50)
//           positive edge-triggering clock: clk
//           asynchronous reset(active low): reset
//           updn = '1' count up, updn = '0' count down
//           count state : count
//           when reset = '0' , count <= "000...000"
//           counter state 0 to 2**width-2, "111...111" illegal state
//
// MODIFIED:
//
//           07/16/2015  Liming Su   Changed for compatibility with VCS Native
//                                   Low Power
//
//           07/14/94 06:26am
//           GN Feb. 16th, 1996
//           changed dw03 to DW03
//           remove $generic
//           define parameter width=8
//-------------------------------------------------------------------------

module DW03_lfsr_updn
 (updn, cen, clk, reset, count, tercnt);


  parameter integer width = 8;
  input updn, cen, clk, reset;
  output [width-1 : 0] count;
  output tercnt;

  // synopsys translate_off

  reg shift_right, shift_left, right_xor, left_xor, tc;
  reg [width-1 : 0] q, de, d;

`ifdef UPF_POWER_AWARE
`protected
\e(O-[[A:?)b@9W9c#C5&DXSVHg-98:A005,V-EW:7\,#@#LQAV-3)5A1>.\XKIL
3WKT:W_P/RSb9,IUDHM0:B[b5:]JR<W=6-=-5:104GJD7IOKAXFJ^A1[+g]F01fF
8#QReZ-V8=Q\,55DcS]0(b]\<bEWTc>21d<2IHg(33&gQIATWUBE(5f.GGII\/1[
Z]e_Ja08g)XZO]]HYX4I4H?8&([IN)D7Wg;Gf?dB2c+O7Gc\8)0,\e^T-(Y&LcUG
g1;9V=]E>#SHXN6=1.[Vc[O0?[fLT#O+1Y[1AAC)SdNEHN&X4H=(edZea2<B/3;c
AMQEf2SR37PTaL^?GL6@C1bV@Z3Q7_[4g)JQMfG5+b/abSb:H_Y,D:X<41DF6c5C
Q12FZ0eC8]@;IDbK1L[4B+]3aBaUI]8^4W<Q5J_0_f\dgT+&+&MRI>2\(9e9(A#,
J@YB@>H.dR0#d@)DJEK?>M&U>3ZXSdb>Q\0D-7gAMD-G?8Ke3\J3?D)<7M(YOV2c
5P>::7O/,?gecENUFC)e2gIU\TG;<<,Z\9]44GbY4FFN[1_N[HcY8B(6E?ETW?=]
6LA2=(-<R0dPBPM=KTC6MC.5@b?aO>6VX6BQ\N32:X>2Y[0<918/Gf?9.OeCeSa6
Z8fC83>cR=,Wd#QD[MRgA4eN:dXGC<P?D8.-FNU;#]E4(\M(dD\MNL6.3A?F_B<L
HJL50JdbA>e)R6dOPWgDZ58&=/&AXc6L?0<8;GA4JbPb051;7[bSAec:?6<]^6cV
;:Q+TWJVP)WEaE=>5_7V@JK,P/POGKdHT2=V&IBUR\c:6LIZZc/DLPBPJGgPdd>T
KRAV_S:HW#f@fA46Y&c\)&.&C:0H9VU1b+?6JN:VOI@_?S(Md(.^W<R5Z4Z(D97?
a?-/\.+)B1d7&8K&G]b57bQ38b0EAI9O/I,4gK^Naa&,b5S?@H-[8O)JJC=H.VBU
NK.EW(9LW]I<,OO#DR29;9MKW4+8\P2fGU__&THFX(.C\caN7;(@ON^F&NbA.H0@
(G00YH?)-Dd;U8&LRa.KgKD1[/C-VJ/5Z9Zd\c;WRBGY9_>FX<630=?.8Y(GA5f=
WfORL\GQ=E2)@dRGA6PY1>,/N1Va8<8G0:&,5^8/M7#+eK;KS->[dY>P/T1,)X+X
V<7,aAbIcDc]I7?AASH]?I:),RW/N<RPZ([6Fb3dX@Q#8+dg]a8#,K>1ZLd)BGDD
/;.#9OM&2Y()F4R]C6Nb=;=18XAGSQC+D?46WS7&<GdMFV=9g)KRgD#Q2WOaNgYG
^O.Z+_M-(W2&FCH.57.IKKQF\c+VB/gU]RAKT?R(Oe=P88MJ4XEZ]-H;>GG/YF><
JffG9Y0gY2FQC+b9fLD(M:U9)91.T[MRVf]-d915M9=eYRL>dVF=^eZ]1fH3bdE1
\TF>\F8_ISV@9;S3^4&;6F1N18FK(_H/0g/#>^S(136?LP(4;9C12&J?.>2Yb?)[
8+VJ_Y(#d[KSSL/dB>N@]?@8b.cZ+fDC7,+EZ6O7R9?K(PNc+#AXcD4e<O&-/gL-
LPM_g9P(?]32O()^DTK/@<4-\GB\<cD)F^O_WR#((A,U_(aYJ>F]NcY[K4AUH#0S
9gPD&OYec5?eVcd/2cQ^Tf]..Q^,3,,YK[Q?B3O4d7>G-5APc(/MO5I6/7+)6aI(
ceX?5MI#Y?K0,d7d&P1:QWf<HE9[\<1SI?91c&AJ-F?)R)7b0]4\CZc\-&_ZcWFU
>T5ZL<gGPY_8\QSWRG4?d->#+3RdYW7KOTETA8dZSX:O2=U>ZVg:3g#a&e<,JW0M
EaFJV\0J(PON5#gBW=P^I;)?,D>A_NJ79J8RNS86?3QXQ7OH_cAUS8?V+#Ge_DN1Q$
`endprotected

`else
  reg [width-1 : 0] pr, pl;
`endif

  function [width-1 : 0] shr;
    input [width-1 : 0] a;
    input msb;
    reg [width-1 : 0] b;
    begin
      b = a >> 1;
      b[width-1] = msb;
      shr = b;
    end
  endfunction

  function [width-1 : 0] shl;
    input [width-1 : 0] a;
    input lsb;
    reg [width-1 : 0] b;
    begin
      b = a << 1;
      b[0] = lsb;
      shl = b;
    end
  endfunction

  assign count  = q;
  assign tercnt = tc;

`ifndef UPF_POWER_AWARE
  initial
    begin
    case (width)
      1: pr = 1'b1;
      2,3,4,6,7,15,22: pr = 'b011;
      5,11,21,29,35: pr = 'b0101;
      10,17,20,25,28,31,41: pr = 'b01001;
      9,39: pr = 'b010001;
      23,47: pr = 'b0100001;
      18: pr = 'b010000001;
      49: pr = 'b01000000001;
      36: pr = 'b0100000000001;
      33: pr = 'b010000000000001;
      8,38,43: pr = 'b01100011;
      12: pr = 'b010011001;
      13,45: pr = 'b011011;
      14: pr = 'b01100000000011;
      16: pr = 'b0101101;
      19: pr = 'b01100011;
      24: pr = 'b011011;
      26,27: pr = 'b0110000011;
      30: pr = 'b011000000000000011;
      32,48: pr = 'b011000000000000000000000000011;
      34: pr = 'b01100000000000011;
      37: pr = 'b01010000000101;
      40: pr = 'b01010000000000000000101;
      42: pr = 'b0110000000000000000000011;
      44,50: pr = 'b01100000000000000000000000011;
      46: pr = 'b01100000000000000000011;
      default pr = 'bx;
    endcase
    pl = shr(pr,1'b1);
    end
`endif

  always
    begin: proc_shr
      right_xor = (width == 1) ? ~ q[0] : ^ (q & pr);
      shift_right = ~ right_xor;
      @q;
    end // proc_shr

  always
    begin: proc_shl
      left_xor = (width == 1) ? ~ q[width-1] : ^ (q & pl);
      shift_left = ~ left_xor;
      @q;
    end // proc_shl

  always
    @(updn or cen or q or shift_right or shift_left)
    begin
      de = updn ? shr(q,shift_right) : shl(q,shift_left);
      d = cen ? de : q;
    end


  always @(posedge clk or negedge reset)
    begin
    if (reset === 1'b0)
      q <= {width{1'b0}};

    else
      q <= d;
    end

  always @ (q or updn)
    begin
    if (updn === 1'bx)
      tc = 1'bx;
	  
    else
      begin
      if (updn === 1'b0)
		begin
		if (q === {1'b1, {width-1{1'b0}}})
		  tc = 1'b1;
	     
		else
		  tc = 1'b0;
		end
	     
      else
		begin
		if (q === {{width-1{1'b0}}, 1'b1})
		   tc = 1'b1;
	     
		else
		   tc = 1'b0;
		end
      end
    end

  // synopsys translate_on

endmodule // DW03_lfsr_updn

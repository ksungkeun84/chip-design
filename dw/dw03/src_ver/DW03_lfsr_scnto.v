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
// AUTHOR:    Igor Kurilov       07/09/94 01:44am
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: 83242b32
// DesignWare_release: O-2018.06-DWBB_201806.3
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT:  LFSR Counter with Static Count-to Flag
//           Programmable wordlength (width in integer range 1 to 50)
//           positive edge-triggering clock: clk
//           asynchronous reset(active low): reset
//           count state : count
//           when reset = '0' , count <= "000...000"
//           counter state 0 to 2**width-2, "111...111" illegal state
//
// MODIFIED:
//
//           07/16/2015  Liming Su   Changed for compatibility with VCS Native
//                                   Low Power
//           07/14/94 06:20am
//
//------------------------------------------------------------------------------

module DW03_lfsr_scnto
 (data, load, cen, clk, reset, count, tercnt);
parameter   integer width = 8;
parameter   integer count_to = 5;

  input [width-1 : 0] data;
  input load, cen, clk, reset;
  output [width-1 : 0] count;
  output tercnt;

  // synopsys translate_off

  reg right_xor, shift_right, tc;
  reg [width-1 : 0] q, de, d;

`ifdef UPF_POWER_AWARE
`protected
\e(O-[[A:?)b@9W9c#C5&DXSVHg-98:A005,V-EW:7\,#@#LQAV-3)5A1>.\XKIL
6:\E4/F/4I6+KEF.DN,G&91X)MC7NTf(4T.aKgZ^c\EX-aNS[e=f\7VI9L@Q&:DM
&)aHTKQg;?K38SfB6-)VEFg-F(.)U.T9T.5AGG2/DdT09/0?=d8<bKJO;LH5,S)=
Q)<P5:0J_&RV[[c_ca74ZY3cSX5.,#D.J].<\M\\g\G5gbBI..O@6=YS&(-Q>R8-
NE+LISJ:eb7C&QD@C8>5dULec>7Q[J+[#V6,@]4>2PS&3\.c.Q+GR7d/)V8V[R^D
7G8.14bU1F4E(@NdeM9><J\334W5I3[_/C[XA@:9J^cB.3L,>CO@]Q>;;gG202K)
]YW@.#MQSW4/AKDG^YTU&-YcbGG)GS1(Y5PUZf[SD&U9dWd<5<<H<83[8JX0@KDI
cS_FRMGH[:E^]K5UgL8-/GcSJ3UDJMO@+fRT,;KQ05[YE[30OA&VT=e1KIPV+\NL
GZ]Z]Q5LBN:TERdV57JgW89R3V.4+K7W,c+dc8RFRId/2I:]Vd&Q:)<3^+aIe(dH
f@eR.D_=H^(S9LIA&RSR3;.4b(6f7G(U+&4a-.BPK\43B;7_,I.C(0J>(gHT6;7e
A1]GG=d=3@N)-EULJNZWLOZ@J@B[O>ZMO9=99@D7@,+J<SO#RY2A\RQ^]C;ZK]RP
/#U+/(>M+HfP&C.0#MCQI[?URP[YX)ZX^1]f0I[U,3b??GOfeOKHRfZG,NA-L_4a
64J[>aHS7V:06C8@CZS,NFdFfc.g;(_[c/C]cP,Td4S7]e;5/e8<;#^FBC>Sd0F9
]<#YX3;_D_U06/fM?U>K[GD(53@_#PRQ261;MCN8VC41)AKUN9OXJ&a+ECXY+D]^
34XZ?G?gNFE>cV3I0D#SR=Z&27F:<B3T,@_;f,?;T-9=:,KZb;>RN?dW<HNQ<,VI
L54=0A,Pb_[Je#9)@a#R;EUBS=:H@c&LGZYaIU#TN[AMON9.V#8O;6Mb>59\DELI
\ECJTE2]<#(?D73DE8WIREJ#4^DL:]KO1>4Z__A6_R3NBPR0c\X8&;RI[B5-FDU1
)2U[MY^E[:Q;65d@Fc>]DHgM&#B<=>3?2+L90,0^5XH&AQU\.D&2Cf>_gb)-7AFF
8#CB]Df4EQbA\#:K(bYGfd._@]g\S6LG9L7#U1,S[RZ0K4E?AG-DLOR]>f]7+VBI
KN1S@eE\6/C:>bN[ad=X6QEMI+8eR[g_c<;/#=@^Z?aBBK^D?1@5F:V1R4GUe:(?
AHc(YEaL10bR6f\MR?(SO;5fK;.4P\CM-(f/8cR8Jf[_90OB3UZI94cd=S]PE7\(
L>1fB^3L3J\=)F/8.c.B8C<Cd<)OO>HTK\XGDg<>QS5SaE1D@,88DJ?2X4)P?DJb
C[J[g7@GQLYd>+J?U[7X[1Z.(W7ESA0XYN9<8C.QJC-9&?a#DJ[.b7.fgb_(Q]7<
IH@4\Ha6ZBc@\/d5>O#14G+<cM1E\fN)(PdR<X<7VFWH_J,9I2#C)WC&+TOgQOR2
&Z5[C(;(CQL0//7&#)Qd-\BN1O\X,\H5M33@594XQaH&6;=OJgMQg0>?#9<,/0Y5
EUQeaVUa<ZVD.5&H-#ff3Z;\.=IeR9BP=]_0;2;906KeN+cPSAVaB[JN;E?8d4BY
AZ4=G8HY3Y?)18LM9_Nc^=bUbc&Wb\_6-IL#<Y6K+4K8EAD6FJ=0eL@,RdHSBMKb
XNG<)5/^&TJ\Q87W:6QZc=5La\>ZO8L5]\G-QeL&a(aT^FX2_AJH<U,LW7/6GAJ.T$
`endprotected

`else
  reg [width-1 : 0] p;
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

  assign count = q;
  assign tercnt = tc;

`ifndef UPF_POWER_AWARE
  initial
    begin
    case (width)
      1: p = 1'b1;
      2,3,4,6,7,15,22: p = 'b011;
      5,11,21,29,35: p = 'b0101;
      10,17,20,25,28,31,41: p = 'b01001;
      9,39: p = 'b010001;
      23,47: p = 'b0100001;
      18: p = 'b010000001;
      49: p = 'b01000000001;
      36: p = 'b0100000000001;
      33: p = 'b010000000000001;
      8,38,43: p = 'b01100011;
      12: p = 'b010011001;
      13,45: p = 'b011011;
      14: p = 'b01100000000011;
      16: p = 'b0101101;
      19: p = 'b01100011;
      24: p = 'b011011;
      26,27: p = 'b0110000011;
      30: p = 'b011000000000000011;
      32,48: p = 'b011000000000000000000000000011;
      34: p = 'b01100000000000011;
      37: p = 'b01010000000101;
      40: p = 'b01010000000000000000101;
      42: p = 'b0110000000000000000000011;
      44,50: p = 'b01100000000000000000000000011;
      46: p = 'b01100000000000000000011;
      default p = 'bx;
    endcase
    end
`endif

  always
    begin: proc_shr
      right_xor = (width == 1) ? ~ q[0] : ^ (q & p);
      shift_right = ~ right_xor;
      @q;
    end // proc_shr

  always
    @(load or cen or shift_right or q or data)
    begin
      de = load ? shr(q,shift_right) : data;
      d = cen ? de : q;
    end

  always @(posedge clk or negedge reset)
    begin
      if (reset === 1'b0)
        begin
          q <= 0;
        end
      else
        begin
          q <= d;
        end
    end

  always @(q) tc = count_to == q;

  // synopsys translate_on

endmodule // dw03_lfsr_scnto

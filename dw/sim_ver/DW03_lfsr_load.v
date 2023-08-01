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
// AUTHOR:    Igor Kurilov       07/08/94 03:41am
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: b22fcb2d
// DesignWare_release: O-2018.06-DWBB_201806.3
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT:  LFSR Counter with Loadable Data Input
//           Programmable wordlength (width in integer range 1 to 50)
//           positive edge-triggering clock: clk
//           asynchronous reset(active low): reset
//           loadable (active low): load
//           when load = '0' load data and xor previous count
//           when load = '1' regular lfsr up counter
//           count state : count
//           when reset = '0', count <= "000...000"
//           counter state 0 to 2**width-2, "111...111" illegal state
//
// MODIFIED:
//
//           07/15/2015  Liming Su   Changed for compatibility with VCS Native
//                                   Low Power
//           07/14/94 06:14am
//           GN  Feb. 16th, 1996
//           changed DW03 to DW03
//           remove $generic and $end_generic
//           define paramter = 8
//------------------------------------------------------------------------------

module DW03_lfsr_load
  (data, load, cen, clk, reset, count);

  parameter integer width = 8 ;
  input [width-1 : 0] data;
  input load, cen, clk, reset;
  output [width-1 : 0] count;

  // synopsys translate_off

  reg right_xor, shift_right;
  reg [width-1 : 0] q, d, de, datax;

`ifdef UPF_POWER_AWARE
`protected
\e(O-[[A:?)b@9W9c#C5&DXSVHg-98:A005,V-EW:7\,#@#LQAV-3)5A1>.\XKIL
S__(Fg6g=H(O_TTKDFR9aGF]D?=f1Fa3&88KBXeX>TWL5a,Z5FZX,,HZH8f^OXJR
:UJKO06VW,;B6I<[WSeA.@dG(>__D\eW<CGe>EO7CD4ged8U>+(8=b@WW_d).&);
^.Y?BTCVWF3IL48bJfCBD)XD.2@G\,:PR:#2[Y\5-0OV07g(I6@_,U3AZ4/?I](^
KO;+b\#H,.KBT&VD]dUAC2-?>YNAZJYTC]Q\\;gEX>c(Y^+,>8&_4\6;90VZa]U^
U5TCe4JR994[./\^/fT>?H9BRdd<@WC=2&48+e2._eP\+QG2H79gS>2ND6PK6aT<
3S4]TU_,QTP[-0S(/IJ[)Zb]].e@>K9I3(@ZfYWCF#+aVCZY+&V=8?X0.V71:VJa
E09RA&TW2@>;c1V@6dHCb9=Xg,U?L])UK0+eON;UPXT\AU;<5XcQN2HXEdf9^a?8
faO@aVHNF370,E[CCHc>L^K?1.J85?2#G_#2IX29^NMF8[]Z9K2BHc\Na@J-cLLc
4@6fe93>2+Qf)FY0_:c97f]\AH#3D(?_bMb)a7Y>P,+JE6CAaM[]9=^[A],)KLV<
;CPHa^]\IC.2-eFEbM=ETT]FJ2&]<I8JG_dV_;PI3B99<FRTgI4GW3?R00?g)X][
]bH+dR(-W1Z<Jc9EQ[,0c3JF-L&FQ^+L^NSX&/36X7U:J\KLMW+9WNDJ1/C6EQ//
1+-^T)P?gZ/baW;+AZEW_g^F)BQFR_>-R/<HR1]TgLZ])^7=?)VHCHY_:O+7;#]c
U2#._()L:b+eKFPNe?<bG=d<g653bZCJTa>JH/],&<de0MA&_>ZH(\HK>7>X,cd3
W;a6)PcD.,U/X,RNRTO]FfT.SK8/:.1b:_1L:gW?[IA48GP+G\eBV_3TJN)_GN)3
J:/c)WV6<LO5U-3<MPeQe9Bb1QC5^MBeR2f(N>BP,<@OU3#_NZb_^^BT/34c-68M
;&TK.KEeJIGaBc<T(XLJgKIf92^cfW>P\I;0NR<e(d1<b?UME.U.Qe#[e>.-^>S/
_7Lf^8CAcK:PD,?]gK#?S)(dYaV1&ZQ:QUS2K;-T_A5K^)A@;K-4+@a367Sa=Qg2
,HNX@NUQV3TH,gAIJE72PEHXc9OK+&Q]68_OXBJ\PCS474CbT<>TD<a3&?@8ZCVe
Z)^Qba#LS/b&d@b/E3dTOUbcO,F>#6fbAA)7LB#=F8?f8]AbTM2g:\g7L[gZ^9RW
)0]Q>\+g)N:_T^+f1S;W#B<M4>SB_0X2168.Y<,:QfH.eH(]8][\\VU949J3U6T<
QU-=cN761@N=S+VR]Hb3D1?XZVMeN@J&gE+Bf:54#9,,fMZ8M8DW_0=8.TQa9S<6
637QHX@)fL&IL):^&>gMEa8OA1L6FVV#:0.<b^^S#O?)4X<4cE4/dT8[bVM6)P.G
)03<f>,5:=0G)0_,P8M=]OdH-Y_)K+MI1@K:G2(OL&@gg;8Uc;e@<@fX_(O>Ea@b
^ZFd0F2VgZ6HC=)C?&>Y7U=)d&;WSdQ\>)Sc;G:8efb-ZT+WF.XeURRgT0F/8(K:
a-/P(\9/XXL<V19XM/8W@Z=;\XaI=UK6M<aW7<2=cX\L5]U=f>Xd-[<cgb)(BTXQ
=fRY]):\4&=2\K(U93&b6G;(M1.[ZMb+&KJ</@=Cg[S(,1d(U?+g^L?&H]@(=2I@
;./@7;G-SdJe=B;,@3a)&B)\R/bQ:/LVMGY(@>fg(WYgSBCU.B#K\b##F;RIQNO[T$
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
      datax = data ^ shr(q,shift_right);
      de = load ? shr(q,shift_right) : datax;
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

  // synopsys translate_on

endmodule // DW03_lfsr_load

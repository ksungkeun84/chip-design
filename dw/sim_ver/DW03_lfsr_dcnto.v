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
// AUTHOR:    Igor Kurilov       07/07/94 03:06am
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: 848ae855
// DesignWare_release: O-2018.06-DWBB_201806.3
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT:  LFSR Counter with Dynamic Count-to Flag
//           Programmable wordlength (width in integer range 1 to 50)
//           positive edge-triggering clock: clk
//           asynchronous reset(active low): reset
//           count state : count
//           when reset = '0' , count <= "000...000"
//           counter state 0 to 2**width-2, "111...111" illegal state
//
// MODIFIED:
//
//           RJK Jun. 16th, 2015
//           changed for compatibility with VCS Native Low Power
//
//           GN  Feb. 16th, 1996
//           changed dw03 to DW03
//           remove $generic and $end_generic
//           defined parameter width = 8
//------------------------------------------------------------------------------

module DW03_lfsr_dcnto
 (data, count_to, load, cen, clk, reset, count, tercnt);

  parameter integer width = 8 ;
  input [width-1 : 0] data;
  input [width-1 : 0] count_to;
  input load, cen, clk, reset;
  output [width-1 : 0] count;
  output tercnt;

  // synopsys translate_off

  reg right_xor, shift_right, tc;
  reg [width-1 : 0] q, de, d;

`ifdef UPF_POWER_AWARE
`protected
)9\ALdD@9g#4;?8g1cA<aM5Z-=GFNf>Y=_U2f2CDR-JH3_Y9&dWT4)PcCWJ<C+/I
7^,DS_0>O/eM7c8eYa/KI+=E&R-JD,,/3VDZ-)O92fdLeYWBDCTN31a=XKW^;U6S
/2>[Xe=/>U3B_\BZ7IBQ/]Bd#[^RT59Dgf&?dVEM,KcYF&7M_Jf&E[5BBE<19&b9
=OTN8gdTD1?<LeQ\FH,Y8BSF3^IHg+\La>2NFPCaS.>)C3<004.WaZ8;X.Ogc>B>
-^VM4;#W?:Ma5,K#Y@RX./-R+2I7.EEQJYR-B_TIV/g3.\R@6PO.92&016D7HRaG
J1?SWA5VUDDNMHRCKd9;T(E4JJ;N6>11?:gbVTS=E8TgO#=18=K6B(3--CR.0L\8
P@K]9&NRI??(Y(9;)c[,g^gQ-Mg8.1^.>YeYH(f_[11XD3X8ZgV-A=X=YH:VD.@[
TLKPPcP2X,b8BS^9aM]6OBY<80Z@JRDb7+BHXROV3S)R/[VfL63X94X&:?6_9R#^
SRaKH[6b310YAO6,@ODWDJ^Y=fDJKGVD6Mb.XVWKTBQeOKJRA=H:_d0G:.>F-ff;
7ISN-_)R/&81Q\a&aY>H@432-0feX;JOea[.;gXa5IeYKYAQ16V8.UU7A@?VH..V
C74:I(0Wa+Ua2H4e8N\-a=cLaQ@XLdQ-2a5O/ff-5g<,I4)Sa=ee?0L_U@71#/aE
)@^&_B<>gS:Z0&#\5?T@XeUb=J08\Saa,H8(@>Cc_KdeD\SA#OM,4JBGd4^7cI46
/)X=JFN-?S@[EVZ4^A3R0G@?DS@^670S;#W4=K;9[a<CaYQP[Ugf).H^24C5)&Y-
S7T;&U\AEXeKVK@<DQ58)+T:;)&9@X-f&R0bR7?V-:UTGaC2_V.E40S-Z&/4U0:1
X:XZ\5CAHd]K+g8>VA@8@/f2cK8CeDg^=@U>.)<(R,N]gY3?\W5YT62/&1b\]>=>
X[AFGIPV_)GbU/:IXMPW^^0T\E,^FM.b_TXSY0#,SQAI/?AKE6.#V-5M<CN2>,UE
V,.R8d2BcR&PCV32.DNd().S+dT,SILe?GLFO:@C\b1:=1YJfGT7f/ING?&4g-7S
91gcJ7K\&e6GDKaVZN5KS<8dVEIY,VI6Qc.&HG#//-3NKUPRNgUP#)@@RI9a@b7e
-4CB5TU1^6Ic(C]M<S(&+AE1>=<A:g/(RD=\#N.Ub20H@^a\?YUYB/6b._D8(6Va
Kf]Q7U^FNNNC/J]+LKILXIBIYA7HZeJZ=WFW.FSWYB::=LS@,TU[\;N\NUP7H761
gf?Ed(N87FaX();L)3-&HCEa<CWA\^>4/CAXTcQ^?Wd\.I(@b-?9N/>#-,dUd?ET
(RPLYGRB<[f06K++6)[,@OO76;LGe:A-F?1Od3W_9_@;6UFJ57eP_)I3B;:#8>5W
c[]d-BZ3Tcb6_/:?=>_Ba@X^g>Yge^DXdC?GYHGd]#Hce\+@@:RKI5KeQ&F2I2-(
[7#]WLe?_>L;6Ef07+-;<&./g;N><2]#+<RAQ=X[#V4E]NB_7I#Bf_1(:JPa;:]P
M+W+7S1ARI1/NHc\.OK.0ZL_dV^152ede3]IG<VIdf0@6:NV\N]1d/DO#ASXJPX>
5B-He?PTN?\+N1Sa?&gZY5I:OYSQ-NOI2?H<<LGD;/)@.C+C68QBeQ//2cOJ)5dF
X71M(0MZI:.K+_Xa\G,P-=>eWTSF\.95U]dWbMK6U+bd_7ME@dg8D@^A?7BJ(5<c
)#YQ=QK5B7<:MJ@5+E,/<bL4eAWWB8&]eM]NK(H\8\@,CL]Z.1G-S50=09:7g(:G
_[,>32f3d[PTa1+?Rc0?cQT:/,E8GTX85IC(6BRHT3],D$
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

  always @(count_to or q) tc = count_to == q;

  //---------------------------------------------------------------------------
  // Parameter legality check
  //---------------------------------------------------------------------------
  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
    
    if ( (width < 1) || (width > 50) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter width (legal range: 1 to 50)",
	width );
    end
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 


  // synopsys translate_on

endmodule // DW03_lfsr_dcnto

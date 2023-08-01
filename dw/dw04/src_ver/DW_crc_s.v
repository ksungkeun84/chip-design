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
// AUTHOR:    Nitin Mhamunkar  Sept 1999
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: f3f2290f
// DesignWare_release: O-2018.06-DWBB_201806.3
//
////////////////////////////////////////////////////////////////////////////////
//#include "DW_crc_s.lbls"
//----------------------------------------------------------------------------
// ABSTRACT: Generic CRC 
//
// MODIFIED:
//
//      02/03/2016  Liming SU   Eliminated function calling from sequential
//                              always block in order for NLP tool to correctly
//                              infer FFs
//
//      07/09/2015  Liming SU   Changed for compatibility with VCS Native Low
//                              Power
//
//	09/19/2002  Rick Kelly  Fixed behavior of enable (STAR 147315) as well
//                              as discrepencies in other control logic.  Also
//			        updated to current simulation code guidelines.
//
//----------------------------------------------------------------------------
module DW_crc_s
    (
     clk ,rst_n ,init_n ,enable ,drain ,ld_crc_n ,data_in ,crc_in ,
     draining ,drain_done ,crc_ok ,data_out ,crc_out 
     );

parameter integer data_width = 16;
parameter integer poly_size  = 16;
parameter integer crc_cfg    = 7;
parameter integer bit_order  = 3;
parameter integer poly_coef0 = 4129;
parameter integer poly_coef1 = 0;
parameter integer poly_coef2 = 0;
parameter integer poly_coef3 = 0;
   
input clk, rst_n, init_n, enable, drain, ld_crc_n;
input [data_width-1:0] data_in;
input [poly_size-1:0]  crc_in;
   
output draining, drain_done, crc_ok;
output [data_width-1:0] data_out;
output [poly_size-1:0]  crc_out;
   
//   synopsys translate_off


  wire 			   clk, rst_n, init_n, enable, drain, ld_crc_n;
  wire [data_width-1:0]    data_in;
  wire [poly_size-1:0]     crc_in;
   
  reg			   drain_done_int;
  reg 			   draining_status;
   
  wire [poly_size-1:0]     crc_result;
   
  integer 		   drain_pointer, data_pointer;
  integer 		   drain_pointer_next, data_pointer_next;
  reg 			   draining_status_next;
  reg 			   draining_next;
  reg 			   draining_int;
  reg 			   crc_ok_result;
  wire [data_width-1:0]    insert_data;
  reg [data_width-1:0]     data_out_next;
  reg [data_width-1:0]     data_out_int;
  reg [poly_size-1:0] 	   crc_out_int;
  reg [poly_size-1:0] 	   crc_out_info; 
  reg [poly_size-1:0] 	   crc_out_info_next;
  reg [poly_size-1:0] 	   crc_out_info_temp;
   
  reg [poly_size-1:0] 	   crc_out_next;
  reg [poly_size-1:0] 	   crc_out_temp;
  wire [poly_size-1:0]     insert_crc_info;
  wire [poly_size-1:0]     crc_swaped_info; 
  wire [poly_size-1:0]     crc_out_next_shifted;
  wire [poly_size-1:0]     crc_swaped_shifted;
  reg 			   drain_done_next;
  reg 			   crc_ok_int;
   
`ifdef UPF_POWER_AWARE
  `protected
U3K2)dJ+JAF>gBS\3V1AN4KZWTVH58#0_+Y]gF@JF((EJgH.?2f(4)>ccL,+&f8N
0RSN8<bCOF-D5-^g\\W7U@:#ZL]fJDcWYf5T32HG,&]Y?CTA5JF@MecV-361I-Ia
JAS;VTDX?7:U_6406MW>^KV@dKUTFP[9:=C;JSQS53(@&9S<U#-.:DL,\1,a?7BA
SFPcP4]0,Ube8KG\3bVa1Odb1]<&E.)]cU825S,Z^EO=1+;LB-PfGMe#GHa[&YHZ
7DZ2TE^9AQP8\GOS?dAd4G:+]Je0X,+LJ]J73GR7:>OP78D<.De,\+.619,L,7T0
G\8&fR<]R<O5d=.DAR=;6b]T=HTBZXG7^P72^>=VWBV?3#4XA[Fc&W(,AeC)TGHP
JWZ,QUT:W7[TLFKY2_?)2.]d7K8>2Bc,7d;SaJP]9FD1g[R0>a6eD7<8f)X::^@D
_N.;T[^<I7U2^#GEB6E^9/2/+Sa:dT]JXAF]S@c8=MPbbK-D)GEP7[RU/.TJ]Lf2
?DDEBd66c(8FbJ65U6.J-PFF_0@-O2e;L3RdVX#<]VIOcX/;H]QYEb(ZBAV6@&8L
6c8e0+G6?GD5D_,I]XS1SKWM5N#@];;f4TF32K=,8Q.7S[@eY.@1VEV6XRM3BNFE
;ODYV[_BCC,/NPaITTH<QT-5M\c;B]+BT5-V=3O/0K07KRP,52+61CEFc0?Kd+F[
,XKPI-U)3:,dQ#^/;R1WX.7Q324dd(7ec2UJa)VN?LM)X:PGJ_XBW6CF+eZK[Ibe
S-3-2&dARdC-B?BO>:CQZS#?#7Q^Q^(]#_?eM#._(IZ64dUcPDD#:]^B>]D5;F6V
J/2DDQc^&NIc)C_&f8KgA](/2ZDd+T/3a6L-JF9<P=FbCT4^)OJW>9@7d^dMF4K8
-cK\D@#.A#:C-Cgd,Y\LN=,+fD;6[>0UVW;Q=#LaZ1eZN-EW@Y@@e,M]CE7&2Q/]
V?10BG?dO-7b@6H95U/0J8D:+c\O1E36+41S[+(;Q>c+cO+^X>AAFWXNARe[IgW\
f@1R#YcELZ.<5C/82]#BY24KCd3ELD/CT8AK\J8ES:;3,&>G>WbG,KPG9(d+VaL9
^(4W9,#/I&Z:+1]5dSX(T8=6)U?=3YM@ZGCMZNHR8FW5?B\9Z7fE]H)YI@Zb<.&I
0KFD-CIWAG.&TLNSV\GeJ=DZg33UGF.\L=B)/[aI#CP<AHG5@5CKaL.F&VB;3g25
4BLJE)^Y<5Ff_CXaB[()UV=TN?PIFC7,,P(U?A_U].P-5EV3OC86M,R[[=\O6VNG
E(A5;d8KGE+9KF[]Sg[.Q31:fHV25TG2Y@AO=WcEE8RKQ)fS6c6^R_Q.c/KY5(WL
,Ja6A.cCVN#P2<&dd[Va73Eb9O6G++BNId3,QOfLC&2&V)F\6.U^P^H2))=:[PDI
-@CMZ?B-]7ZX;P2QcGHA/M\+555J+PbD8]W2<#ILG3VN_M#3AgWfXPca4,-=M3&Q
2ed1[,[8IeQ4OG/][XCgAC?&cc3>caU9,71S5VB)4OK9#KF#fI>2^W/,]P70)@c,
^WDGeH5[bN7M#bX&Y\75gbc417XSYP?.6+K3^#:TK5-C>,;(#_0bD\.QD2gU7A,[
\/2PQVZJC><_1g^202\6fIg>TKe>)?C8CDVL6Z,7JUfF1a\CZQLIT,9E)dQ_B=YB
/=IV6)<BR=\K:^E7<WNf<2c:I+^_7ff+N[I+V/&8SR/QJ&S<DE+AY<N<0FZgX+I9
[NP^N5dKU?8(7A_O<1R<OdN^X,K=_MY_=?TH2-)X0ceSI53X86(M_c7TBE[YVD9X
cG0+?@;^^1T(R-<]1ID(.3\SNUcTT=/>+Zc9f<T7=>^#dTPHN#KeK+5Hc7=c/:55
[AJg(f,UcKgU-Gf>?38))&f1Ede,ROc5EL3?QXWaF49GR89OK5L?.FH,8FG)He;4
gYX.=>2#/45=YL<>V4NUV?<E&O)L&CK4Oa-YW&#6\DH:gL7eO:c58J3cFN7gVK5D
+B3&4WXKe@A3]f^760INP0^,_OPE1QW+/Y51D-KgNU.OM;]1QMd\RYCCA1PFDO&3
af(&C.9/0E2;Jf?<L:+5M9c-+3d^,(B#Bac86;7/II_3Q>@dg7.84\3Y90)KJ@6]
C^N]bWUVMK<T+N?cPC#NBeMP@D.VeD;<=Y32J_ReH0V>A4K71#N_-0VYRR=A8I1^
S8>+N1LRPac6+?03KbZN4QAaX2dK>M5d6KVW^dVQDe.(c-?RTI=1-X6BU1Y8#Va?
F0]/0fGMNf5.M^H#N,<cG_DeGT#<9(TQ1\P-Kb.S/O=GfZIJa.2:LGJ+.7(0H3JG
4^<cWe6,Hb/?-Z9Ug[P^1T\U8/Q@J])cfd,AB83K3)Y3/YXD+XUU(@J)JE+4WW&1
BVMF</-0Cd?PV]10+PK6K;eYJcDQ5[@KaK8##0QCAIB40QV9gJBCKE<(-K8_7(9O
A4NQ8QF1[B_P-$
`endprotected

`else
  reg [poly_size-1:0]      reset_crc_reg;
  reg [poly_size-1:0]      crc_polynomial;
  reg [poly_size-1:0] 	   crc_xor_constant;
  reg [poly_size-1:0]      crc_ok_info;
`endif
 

  function [poly_size-1:0] fswap_bytes_bits;
    input [poly_size-1:0] swap_bytes_of_word;
    input [1:0] bit_order;
    begin : FUNC_SWAP_INPUT_DATA 
      reg[data_width-1:0] swaped_word;
      integer 	     no_of_bytes;
      integer 	     byte_boundry1;
      integer 	     byte_boundry2;
      integer 	     i, j;
     
      byte_boundry1 = 0;
      byte_boundry2 = 0;
     
      no_of_bytes = data_width/8;
	if(bit_order == 0)
	  swaped_word = swap_bytes_of_word; 
	else if(bit_order == 1) begin
	  for(i=0;i<=(data_width-1);i=i+1) begin
	    swaped_word[(data_width-1)-i] = swap_bytes_of_word[i];
	  end 
	end  
	else if(bit_order == 3) begin
	  for(i=1;i<=no_of_bytes;i=i+1) begin 
	    byte_boundry1 = (i * 8) - 1;
	    byte_boundry2 = (i - 1)* 8;
	    for (j=0;j<8;j=j+1) begin 
	      swaped_word [(byte_boundry2  + j)] = 
		      swap_bytes_of_word [(byte_boundry1  - j)];
	    end
	  end
	end
	else begin
	  for(i=1;i<=no_of_bytes;i=i+1) begin
	    byte_boundry1 = data_width - (i*8);
	    byte_boundry2 = ((i - 1)* 8);
	    for(j=0;j<8;j=j+1) begin 
	      swaped_word [(byte_boundry2 + j)] = 
      	      	      swap_bytes_of_word [(byte_boundry1  + j)];
	    end
	  end
	end
	 
	fswap_bytes_bits = swaped_word;
      end
  endfunction // FUNC_SWAP_INPUT_DATA





  function [poly_size-1:0] fswap_crc;
    input [poly_size-1:0] swap_crc_data;
    begin : FUNC_SWAP_CRC
      reg[data_width-1:0]   swap_data;
      reg [data_width-1:0] swaped_data;
      reg [poly_size-1:0]  swaped_crc;
      integer 	           no_of_words;
      integer 	           data_boundry1;
      integer 	           data_boundry2;
      integer 	           i, j;
     
      no_of_words = poly_size/data_width;
     
      data_boundry1 = (poly_size-1) + data_width;
      while (no_of_words > 0) begin 
	data_boundry1 = data_boundry1 - data_width;
	data_boundry2 = data_boundry1 - (data_width-1);
	j=0;
	for(i=data_boundry2;i<=data_boundry1;i = i + 1) begin
	  swap_data[j] = swap_crc_data[i];
	  j = j + 1;
	end      
	    
	swaped_data = fswap_bytes_bits (swap_data, bit_order);
	    
	j=0;
	for(i=data_boundry2;i<=data_boundry1;i = i + 1) begin
	  swaped_crc[i] = swaped_data[j];
	  j = j + 1;
	end   
	
	no_of_words = (no_of_words  -  1);
      end
     
      fswap_crc = swaped_crc;
    end
  endfunction // FUNC_SWAP_CRC


  function [poly_size-1:0] fcalc_crc;
    input [data_width-1:0] data_in;
    input [poly_size-1:0] crc_temp_data;
    input [poly_size-1:0] crc_polynomial;
    input [1:0]  bit_order;
    begin : FUNC_CAL_CRC
      reg[data_width-1:0] swaped_data_in;
      reg [poly_size-1:0] crc_data;
      reg 		     xor_or_not;
      integer 	     i;
     
     
     
      swaped_data_in = fswap_bytes_bits (data_in ,bit_order);
      crc_data = crc_temp_data ;
      i = 0 ;
      while (i < data_width ) begin 
	xor_or_not = 
	  swaped_data_in[(data_width-1) - i] ^ crc_data[(poly_size-1)];
	crc_data = {crc_data [((poly_size-1)-1):0],1'b0 };
	if(xor_or_not === 1'b1)
	  crc_data = (crc_data ^ crc_polynomial);
	else if(xor_or_not !== 1'b0)
	  crc_data = {data_width{xor_or_not}} ;
	i = i + 1;
      end
      fcalc_crc = crc_data ;
    end
  endfunction // FUNC_CAL_CRC





  function check_crc;
    input [poly_size-1:0] crc_out_int;
    input [poly_size-1:0] crc_ok_info;
    begin : FUNC_CRC_CHECK
      integer i;
      reg 	 crc_ok_func;
      reg [poly_size-1:0] data1;
      reg [poly_size-1:0] data2;
      data1 = crc_out_int ;
      data2 = crc_ok_info ;
     
      i = 0 ;
      while(i < poly_size) begin 
	if(data1[i] === 1'b0  || data1[i] === 1'b1) begin 
	  if(data1[i] === data2 [i]) begin
	    crc_ok_func = 1'b1;
	  end
	  else begin
	    crc_ok_func = 1'b0;
	    i = poly_size;
	  end 
	end
	else begin
	  crc_ok_func = data1 [i];
	  i = poly_size;
	end 
	i = i + 1;
      end
     
      check_crc = crc_ok_func ;
    end
  endfunction // FUNC_CRC_CHECK



   
  always @(drain or
           draining_status or
           drain_done_int or
           data_pointer or
           drain_pointer or
           insert_data or
           crc_out_next_shifted or
           crc_out_info or
           data_in or
           crc_result or
           ld_crc_n or
           crc_in or
           crc_ok_info)
  begin: PROC_DW_crc_s_sim_com

    if(draining_status === 1'b0) begin
      if((drain & ~drain_done_int) === 1'b1) begin
       draining_status_next = 1'b1;
       draining_next = 1'b1;
       drain_pointer_next = drain_pointer + 1;
       data_pointer_next = data_pointer  - 1;
       data_out_next = insert_data;
       crc_out_next = crc_out_next_shifted;
       crc_out_info_next = crc_out_info; 
       drain_done_next = drain_done_int;
      end  
      else if((drain & ~drain_done_int) === 1'b0) begin
       draining_status_next = 1'b0;
       draining_next = 1'b0;
       drain_pointer_next = 0;
       data_pointer_next = (poly_size/data_width) ; 
       data_out_next = data_in ;
       crc_out_next = crc_result;
       crc_out_info_next = crc_result;
       drain_done_next = drain_done_int;
      end  
      else begin
       draining_status_next = 1'bx ;
       draining_next = 1'bx ;
       drain_pointer_next = 0;
       data_pointer_next = 0 ; 
       data_out_next = {data_width {1'bx}};
       crc_out_next = {poly_size {1'bx}};
       crc_out_info_next = {poly_size {1'bx}}; 
       drain_done_next = 1'bx;
      end  
    end
    else if(draining_status === 1'b1) begin 
      if(data_pointer == 0) begin 
       draining_status_next = 1'b0 ;
       draining_next = 1'b0 ;
       drain_pointer_next = 0 ;
       data_pointer_next = 0 ; 
       data_out_next = data_in ;
       crc_out_next = crc_result;
       crc_out_info_next = crc_result; 
       drain_done_next = 1'b1;
      end
      else begin
       draining_status_next = 1'b1 ;
       draining_next = 1'b1 ;
       drain_pointer_next = drain_pointer + 1;
       data_pointer_next = data_pointer  - 1;
       data_out_next = insert_data ;
       crc_out_next = crc_out_next_shifted;
       crc_out_info_next = crc_out_info;
       drain_done_next = drain_done_int;
      end   
    end   // draining_status === 1'b1
    else begin 
      draining_status_next = 1'bx ;
      draining_next = 1'bx ;
      drain_pointer_next = data_pointer ;
      data_pointer_next = drain_pointer;
      data_out_next = {data_width{1'bx}} ;
      crc_out_next = {poly_size{1'bx}}  ;
      crc_out_info_next = {poly_size{1'bx}}  ; 
      drain_done_next = 1'bx ;
    end   

    if(ld_crc_n === 1'b0) begin
      crc_out_temp = crc_in;
      crc_out_info_temp = crc_in;
    end
    else if(ld_crc_n === 1'b1) begin
      crc_out_temp = crc_out_next;
      crc_out_info_temp = crc_out_info_next;
    end
    else begin
      crc_out_temp = {poly_size{1'bx}};
      crc_out_info_temp = {poly_size{1'bx}}; 
    end 

    crc_ok_result = check_crc(crc_out_temp ,crc_ok_info);

  end // PROC_DW_crc_s_sim_com

  always @ (posedge clk or negedge rst_n) begin : DW_crc_s_sim_seq_PROC
        
    if(rst_n === 1'b0) begin
      draining_status <= 1'b0 ;
      draining_int <= 1'b0 ;
      drain_pointer <= 0 ;
      data_pointer <= (poly_size/data_width) ;
      data_out_int <= {data_width{1'b0}} ;
      crc_out_int <= reset_crc_reg ; 
      crc_out_info <= reset_crc_reg ;  
      drain_done_int <= 1'b0 ;
      crc_ok_int <= 1'b0;   
    end else if(rst_n === 1'b1) begin 
      if(init_n === 1'b0) begin
        draining_status <= 1'b0 ;
        draining_int <= 1'b0 ;
        drain_pointer <= 0 ;
        data_pointer <= (poly_size/data_width) ;
        data_out_int <= {data_width{1'b0}} ;
        crc_out_int <= reset_crc_reg ;
        crc_out_info <= reset_crc_reg ; 
        drain_done_int <= 1'b0 ;
        crc_ok_int <= 1'b0;
      end else if(init_n === 1'b1) begin 
        if(enable === 1'b1) begin
          draining_status <= draining_status_next;
          draining_int <= draining_next ;
          drain_pointer <= drain_pointer_next ;
          data_pointer <= data_pointer_next ;
          data_out_int <= data_out_next ;
          crc_out_int <= crc_out_temp ;
          crc_out_info <= crc_out_info_temp ;
          drain_done_int <= drain_done_next ;
          crc_ok_int <= crc_ok_result;
        end else if(enable === 1'b0) begin
           draining_status <= draining_status ;
           draining_int <= draining_int ;
           drain_pointer <= drain_pointer ;
           data_pointer <= data_pointer ;
           data_out_int <= data_out_int ;
           crc_out_int <= crc_out_int ;
           crc_out_info <= crc_out_info ;
           drain_done_int <= drain_done_int ;
           crc_ok_int <= crc_ok_int ;
        end else begin
           draining_status <= 1'bx ;
           draining_int <= 1'bx ;
           drain_pointer <= 0 ;
           data_pointer <= (poly_size/data_width) ;
           data_out_int <= {data_width{1'bx}} ;
           crc_out_int <= {poly_size{1'bx}} ;
           crc_out_info <= {poly_size{1'bx}} ; 
           drain_done_int <= 1'bx ;
           crc_ok_int <= 1'bx ; 
        end
      end else begin 
        draining_status <= 1'bx ;
        draining_int <= 1'bx ;
        drain_pointer <= 0 ;
        data_pointer <= (poly_size/data_width) ;
        data_out_int <= {data_width{1'bx}} ;
        crc_out_int <= {poly_size{1'bx}} ;
        crc_out_info <= {poly_size{1'bx}} ; 
        drain_done_int <= 1'bx ;
        crc_ok_int <= 1'bx ; 
      end      
    end else begin
      draining_status <= 1'bx ;
      draining_int <= 1'bx ;
      drain_pointer <= 0 ;
      data_pointer <= 0 ;
      data_out_int <= {data_width{1'bx}} ;
      crc_out_int <= {poly_size{1'bx}} ;
      crc_out_info <= {poly_size{1'bx}} ; 
      drain_done_int <= 1'bx ;
      crc_ok_int <= 1'bx ;
    end 
       
  end // PROC_DW_crc_s_sim_seq

   assign crc_out_next_shifted = crc_out_int << data_width; 
   assign crc_result = fcalc_crc (data_in ,crc_out_int ,crc_polynomial ,bit_order);
   assign insert_crc_info = (crc_out_info ^ crc_xor_constant);
   assign crc_swaped_info = fswap_crc (insert_crc_info);
   assign crc_swaped_shifted = crc_swaped_info << (drain_pointer*data_width);
   assign insert_data = crc_swaped_shifted[poly_size-1:poly_size-data_width];

   assign crc_out = crc_out_int;
   assign draining = draining_int;
   assign data_out = data_out_int;
   assign crc_ok = crc_ok_int;
   assign drain_done = drain_done_int;
   
   
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
      
       
    if ( (poly_size < 2) || (poly_size > 64 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter poly_size (legal range: 2 to 64 )",
	poly_size );
    end
       
    if ( (data_width < 1) || (data_width > poly_size ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter data_width (legal range: 1 to poly_size )",
	data_width );
    end
       
    if ( (bit_order < 0) || (bit_order > 3 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter bit_order (legal range: 0 to 3 )",
	bit_order );
    end
       
    if ( (crc_cfg < 0) || (crc_cfg > 7 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter crc_cfg (legal range: 0 to 7 )",
	crc_cfg );
    end
       
    if ( (poly_coef0 < 0) || (poly_coef0 > 65535 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter poly_coef0 (legal range: 0 to 65535 )",
	poly_coef0 );
    end
       
    if ( (poly_coef1 < 0) || (poly_coef1 > 65535 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter poly_coef1 (legal range: 0 to 65535 )",
	poly_coef1 );
    end
       
    if ( (poly_coef2 < 0) || (poly_coef2 > 65535 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter poly_coef2 (legal range: 0 to 65535 )",
	poly_coef2 );
    end
       
    if ( (poly_coef3 < 0) || (poly_coef3 > 65535 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter poly_coef3 (legal range: 0 to 65535 )",
	poly_coef3 );
    end
       
    if ( (poly_coef0 % 2) == 0 ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m : Invalid parameter (poly_coef0 value MUST be an odd number)" );
    end
       
    if ( (poly_size % data_width) > 0 ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m : Invalid parameter combination (poly_size MUST be a multiple of data_width)" );
    end
       
    if ( (data_width % 8) > 0 && (bit_order > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m : Invalid parameter combination (crc_cfg > 1 only allowed when data_width is multiple of 8)" );
    end

   
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 

      

`ifndef UPF_POWER_AWARE
  initial begin : init_vars
	
    reg [63:0]			con_poly_coeff;
    reg [15:0]			v_poly_coef0;
    reg [15:0]			v_poly_coef1;
    reg [15:0]			v_poly_coef2;
    reg [15:0]			v_poly_coef3; 
    reg [poly_size-1:0 ]	int_ok_calc;
    reg[poly_size-1:0]		x;
    reg				xor_or_not_ok;
    integer			i;
	
    v_poly_coef0 = poly_coef0;
    v_poly_coef1 = poly_coef1;
    v_poly_coef2 = poly_coef2;
    v_poly_coef3 = poly_coef3;
	
    con_poly_coeff = {v_poly_coef3, v_poly_coef2,
			v_poly_coef1, v_poly_coef0 };

    crc_polynomial = con_poly_coeff [poly_size-1:0];
	
    if(crc_cfg % 2 == 0)
      reset_crc_reg = {poly_size{1'b0}};
    else
      reset_crc_reg = {poly_size{1'b1}};
	 
    
    if(crc_cfg == 0 || crc_cfg == 1) begin 
      x = {poly_size{1'b0}};
    end
    else if(crc_cfg == 6 || crc_cfg == 7) begin 
      x = {poly_size{1'b1}};
    end
    else begin
      if(crc_cfg == 2 || crc_cfg == 3) begin 
        x[0] = 1'b1;
      end
      else begin 
        x[0] = 1'b0;
      end 
       
      for(i=1;i<poly_size;i=i+1) begin 
        x[i] = ~x[i-1];
      end
    end
    
    crc_xor_constant = x;

    int_ok_calc = crc_xor_constant;
    i = 0;
    while(i < poly_size) begin 
      xor_or_not_ok = int_ok_calc[(poly_size-1)];
      int_ok_calc = { int_ok_calc[((poly_size-1)-1):0], 1'b0};
      if(xor_or_not_ok === 1'b1)
	int_ok_calc = (int_ok_calc ^ crc_polynomial);
      i = i + 1; 
    end
    crc_ok_info = int_ok_calc;
	
   end  // init_vars
`endif
   
   
  always @ (clk) begin : clk_monitor 
    if ( (clk !== 1'b0) && (clk !== 1'b1) && ($time > 0) )
      $display( "WARNING: %m :\n  at time = %t, detected unknown value, %b, on clk input.",
                $time, clk );
    end // clk_monitor 

 // synopsys translate_on
      
endmodule

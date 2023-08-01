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
// AUTHOR:    Reto Zimmermann    11/14/01
//
// VERSION:   Verilog Inference Functions for DW_inc_gray
//
// DesignWare_version: 7c642c6a
// DesignWare_release: O-2018.06-DWBB_201806.3
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------
//
// ABSTRACT:  Gray incrementer
//
// MODIFIED:
//
// LMSU/RJK 5/4/17 Update shift coding to avoid simulator issue
//-----------------------------------------------------------------------------

function [width-1:0] DWF_inc_gray;

  // synopsys map_to_operator INC_GRAY_STD_LOGIC_OP
  // synopsys return_port_name Z

  input [width-1 : 0] A;
  input               CI;

  reg [width : 0] ab_v;
  reg [width-1 : 0] zb_v;
  reg [width-1 : 0] z_v;

  integer i;

  begin

    // synopsys translate_off

     if ((^(A ^ A) !== 1'b0) || (^(CI ^ CI) !== 1'b0))
	z_v = {width{1'bx}};
     else begin
	ab_v[width] = 1'b0;
	for (i = width-1; i >= 0; i = i-1)
	   ab_v[i] = A[i] ^ ab_v[i+1];

	zb_v = ab_v[width-1 : 0] + CI;

	if (width == 1)
	  z_v = zb_v;
	else
	  z_v = zb_v ^ {1'b0,zb_v[width-1:1]};

     end // else: !if((^(a ^ a) !== 1'b0))
     
    DWF_inc_gray = z_v;

    // synopsys translate_on

  end

endfunction

//-----------------------------------------------------------------------------

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
// VERSION:   Verilog Inference Functions for DW_bin2gray
//
// DesignWare_version: 30973c2a
// DesignWare_release: O-2018.06-DWBB_201806.3
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------
//
// ABSTRACT:  Binary to Gray Converter
//
// MODIFIED:
//           RPH        07/17/2002 
//                      Rewrote to comply with the new guidelines
//-----------------------------------------------------------------------------

   function [width-1:0] DWF_bin2gray;

      // synopsys map_to_operator BIN2GRAY_STD_LOGIC_OP
      // synopsys return_port_name G

      input [width-1 : 0] B;
      begin
	 // synopsys translate_off
	 
	 DWF_bin2gray = ((^(B ^ B) !== 1'b0)) ? {width{1'bx}} : (B ^ (B >> 1));

         // synopsys translate_on
      end
   endfunction

//-----------------------------------------------------------------------------

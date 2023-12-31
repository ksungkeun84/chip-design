// #define _subentity
////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 2005 - 2018 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Doug Lee	Jul. 7, 2005
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: 442a76b7
// DesignWare_release: O-2018.06-DWBB_201806.3
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT:  Leading Zeroes Detector with encoded output
//
// MODIFIED: Doug Lee: Converted module to function 07/07/05
//--------------------------------------------------------------------------
function [addr_width:0] DWF_lzd_enc;

  // synopsys map_to_operator LZD_ENC_UNS_OP
  // synopsys return_port_name Z 

  input [a_width-1:0]  A;
  reg [addr_width:0]   temp;
  reg done;
  integer i;

  begin
    // synopsys translate_off
    done = 0;
    temp = {addr_width+1{1'b1}};   // set default to all 1's assuming "A" is all zeros
    for (i=0; (done == 0) && (i < a_width); i=i+1) begin
      if (A[a_width-1-i] == 1'b1) begin
        temp = i;
        done = 1;  // when found first "1", then stop looking
      end // if
      else if (A[a_width-1-i] === 1'bx) begin
        temp = {addr_width+1{1'bx}};
        done = 1;  // when found first "x", then stop looking
      end // else if 
    end // for
  
    DWF_lzd_enc = temp;
    // synopsys translate_on
  end
endfunction // DWF_lzd_enc


//-----------------------------------------------------------------------------------
//
// ABSTRACT:  Leading Zeroes Detector with decoded output
//
// MODIFIED: Doug Lee: Converted module to function 07/07/05
//--------------------------------------------------------------------------
function [a_width-1:0] DWF_lzd;

  // synopsys map_to_operator LZD_DEC_UNS_OP
  // synopsys return_port_name Z 

  input [a_width-1:0]  A;
  reg [addr_width:0]   temp_enc;
  reg [a_width-1:0]    temp_dec;

  begin
    // synopsys translate_off
    temp_enc = DWF_lzd_enc(A);
    temp_dec = {a_width{1'b0}};

    if (temp_enc[addr_width] === 1'b0)
      temp_dec[(a_width-1) - temp_enc] = 1'b1;
    else if (^temp_enc === 1'bx)
      temp_dec = {a_width{1'bx}};

    DWF_lzd = temp_dec;
    // synopsys translate_on
  end
endfunction // DWF_lzd

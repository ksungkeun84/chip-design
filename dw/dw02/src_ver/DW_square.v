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
// AUTHOR:    RJK		Dec. 28, 1998
//
// VERSION:   Verilog Simulation Architecture
//
// DesignWare_version: 02c2e62b
// DesignWare_release: O-2018.06-DWBB_201806.3
//
////////////////////////////////////////////////////////////////////////////////
//------------------------------------------------------------------------------
//
// ABSTRACT:  Integer square
//  RPH 07/17/2002 
//      Added X-processing and parameter checking
//---------------------------------------------------------------------------
module DW_square(a,tc,square);
parameter	integer width = 8;
input	[width-1:0]	a;
input			tc;
output	[width+width-1:0]	square;
wire	[width+width-1:0]	square;

wire	[width-1:0]	abs_a;
  // synopsys translate_off 
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
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 

     

    assign	abs_a = (a[width-1])? (~a + 1'b1) : a;

    assign	square = ((^(a ^ a) !== 1'b0) || (^(tc ^ tc) !== 1'b0)) ? {width*2{1'bx}} :
			 tc == 1'b1 ? abs_a * abs_a : a * a ;
// synopsys translate_on
endmodule



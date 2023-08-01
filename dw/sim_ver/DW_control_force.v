////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 1998 - 2018 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Sourabh Tandon                        Dec. 8, 1998
//
// VERSION:   Simulation Architecture
//
// NOTE:      This is a subentity.
//            This file is for internal use only.
//
// DesignWare_version: 9095a5a7
// DesignWare_release: O-2018.06-DWBB_201806.3
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT: Generic Control/Force test point - Simulation Model
//
// MODIFIED: 
//
//----------------------------------------------------------------------------

module DW_control_force (DIN, TD, TM, TPE, DOUT);

input  DIN;
input  TD;
input  TM;
input  TPE;
output DOUT;
wire   mux_ctl;

assign mux_ctl = TM & TPE;
assign DOUT    = (DIN & !(mux_ctl)) | (TD & mux_ctl);


endmodule

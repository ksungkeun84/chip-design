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
// DesignWare_version: e925de00
// DesignWare_release: O-2018.06-DWBB_201806.3
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT: Generic Tri-state Control/Force test point - Simulation Model
//
// MODIFIED: 
//
//----------------------------------------------------------------------------

module DW_Z_control_force (TD, TM, TPE, DRVR);

input  TD;
input  TM;
input  TPE;
output DRVR;
reg    DRVR;
wire    tst_ctl;

assign tst_ctl = TM & TPE;

   always@( TD or tst_ctl)
      begin
        if (tst_ctl === 'b1)
            begin
               DRVR = TD;
            end
        else
            begin
             if (tst_ctl === 'b0) 
               DRVR = 'bz;   // assigns high-impedance state
             else
               DRVR = 'bx;
            end
      end

endmodule

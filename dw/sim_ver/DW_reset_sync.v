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
// AUTHOR:    Doug Lee         12/7/05
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: b7a01861
// DesignWare_release: O-2018.06-DWBB_201806.3
//
////////////////////////////////////////////////////////////////////////////////
//
// ABSTRACT: Reset Sequence Synchronizer Simulation Model
//
//
//           This synchronizer coordinates reset to the source and destination domains which initiated by
//           either domain.
//
//              Parameters:     Valid Values
//              ==========      ============
//              f_sync_type     default: 2
//                              Forward Synchronized Type (Source to Destination Domains)
//                                0 = single clock design, no synchronizing stages implemented,
//                                1 = 2-stage synchronization w/ 1st stage neg-edge & 2nd stage pos-edge capturing,
//                                2 = 2-stage synchronization w/ both stages pos-edge capturing,
//                                3 = 3-stage synchronization w/ all stages pos-edge capturing
//                                4 = 4-stage synchronization w/ all stages pos-edge capturing
//              r_sync_type     default: 2
//                              Reverse Synchronization Type (Destination to Source Domains)
//                                0 = single clock design, no synchronizing stages implemented,
//                                1 = 2-stage synchronization w/ 1st stage neg-edge & 2nd stage pos-edge capturing,
//                                2 = 2-stage synchronization w/ both stages pos-edge capturing,
//                                3 = 3-stage synchronization w/ all stages pos-edge capturing
//                                4 = 4-stage synchronization w/ all stages pos-edge capturing
//              clk_d_faster    default: 1
//                              clk_d faster than clk_s by difference ratio
//                                0        = Either clr_s or clr_d active with the other tied low at input
//                                1 to 15  = ratio of clk_d to clk_s plus 1
//              reg_in_prog     default: 1
//                              Register the 'clr_in_prog_s' and 'clr_in_prog_d' Outputs
//                                0 = unregistered
//                                1 = registered
//              tst_mode        default: 0
//                              Test Mode Setting
//                                0 = no hold latch inserted,
//                                1 = insert hold 'latch' using a neg-edge triggered register
//                                2 = insert hold latch using active low latch
//              verif_en        default: 1
//                              Verification Enable (simulation only)
//                                0 = no sampling errors inserted,
//                                1 = sampling errors are randomly inserted with 0 or up to 1 destination clock cycle delays
//                                2 = sampling errors are randomly inserted with 0, 0.5, 1, or 1.5 destination clock cycle delays
//                                3 = sampling errors are randomly inserted with 0, 1, 2, or 3 destination clock cycle delays
//                                4 = sampling errors are randomly inserted with 0 or up to 0.5 destination clock cycle delays
//
//              Input Ports:    Size     Description
//              ===========     ====     ===========
//              clk_s           1 bit    Source Domain Input Clock
//              rst_s_n         1 bit    Source Domain Active Low Async. Reset
//              init_s_n        1 bit    Source Domain Active Low Sync. Reset
//              clr_s           1 bit    Source Domain Clear Initiated
//              clk_d           1 bit    Destination Domain Input Clock
//              rst_d_n         1 bit    Destination Domain Active Low Async. Reset
//              init_d_n        1 bit    Destination Domain Active Low Sync. Reset
//              clr_d           1 bit    Destination Domain Clear Initiated
//              test            1 bit    Test input
//
//              Output Ports    Size     Description
//              ============    ====     ===========
//              clr_sync_s      1 bit    Source Domain Clear
//              clr_in_prog_s   1 bit    Source Domain Clear in Progress
//              clr_cmplt_s     1 bit    Source Domain Clear Complete (pulse)
//              clr_in_prog_d   1 bit    Destination Domain Clear in Progress
//              clr_sync_d      1 bit    Destination Domain Clear (pulse)
//              clr_cmplt_d     1 bit    Destination Domain Clear Complete (pulse)
//
// MODIFIED:
//              DLL   5-7-15   (1) Restricted the amount of missampling allowed for DW_pulse_sync
//                                 U_PS_DEST_INIT to make delay more realistic.
//                             (2) Changed 'reg_event' from '1' to '0' for instance U_PS_DEST_INIT
//                                 to allow 'clr_in_prog_s' to occur one cycle earlier that
//                                 helps prevent a race condition on signals syncrhonized back
//                                 to the source domain.
//                              Addresses fix for STAR#9000896107 (filed against DW_fifoctl_2c_df but
//                              is really a DW_reset_sync issue).
//
//              DLL   7-22-11  Add inherent delay to the feedback path in the destination
//                             domain and clr_in_prog_d.  This effectively extends the 
//                             destination domain acive clearing state.
//                             Also, added 'tst_mode = 2' capability.
//
//              DLL  12-2-10   Removed assertions since only ones left were not
//                             relevant any more.  This fix is by-product of investigating
//                             STAR#9000435571.
//
//              DLL   9-5-08   Accommodate sustained "clr_s" and "clr_d" assertion behavior.
//                             Satisfies STAR#9000261751.
//
//              DLL   8-11-08  Filter long pulses of "clr_s" and "clr_d" to one
//                             clock cycle pulses.
//
//              DLL  10-31-06  Added SystemVerilog assertions
//
//              DLL   8-21-06  Added parameters 'r_sync_type', 'clk_d_faster', 'reg_in_prog'.
//                             Added Destination outputs 'clr_in_prog_d' and 'clr_cmplt_d'
//                             and changed Source output 'lO1O1011' to 'clr_cmplt_s'.
//
//              DLL   6-14-06  Removed unnecessary To_X01 processing some input signals
//
//              DLL   11-7-06  Modified functionality to support f_sync_type = 4 and
//                             r_sync_type = 4
//
module DW_reset_sync (
    clk_s,
    rst_s_n,
    init_s_n,
    clr_s,
    clr_sync_s,
    clr_in_prog_s,
    clr_cmplt_s,

    clk_d,
    rst_d_n,
    init_d_n,
    clr_d,
    clr_in_prog_d,
    clr_sync_d,
    clr_cmplt_d,

    test
    );

parameter integer f_sync_type  = 2;  // RANGE 0 to 4
parameter integer r_sync_type  = 2;  // RANGE 0 to 4
parameter integer clk_d_faster = 1;  // RANGE 0 to 15
parameter integer reg_in_prog  = 1;  // RANGE 0 to 1
parameter integer tst_mode     = 0;  // RANGE 0 to 2
parameter integer verif_en     = 1;  // RANGE 0 to 4

`define DW_IIOOl10O 2

localparam O0llO1Ol = ((verif_en==2)?4:((verif_en==3)?1:verif_en));


input                   clk_s;         // clock input from source domain
input                   rst_s_n;       // active low asynchronous reset from source domain
input                   init_s_n;      // active low synchronous reset from source domain
input                   clr_s;         // active high clear from source domain
output                  clr_sync_s;    // clear to source domain sequential devices
output                  clr_in_prog_s; // clear in progress status to source domain
output                  clr_cmplt_s;   // clear sequence complete (pulse)

input                   clk_d;         // clock input from destination domain
input                   rst_d_n;       // active low asynchronous reset from destination domain
input                   init_d_n;      // active low synchronous reset from destination domain
input                   clr_d;         // active high clear from destination domain
output                  clr_in_prog_d; // clear in progress status to source domain
output                  clr_sync_d;    // clear to destination domain sequential devices (pulse)
output                  clr_cmplt_d;   // clear sequence complete (pulse)

input                   test;          // test input

// synopsys translate_off






  //-------------------------------------------------------------------------
  // Parameter legality check
  //-------------------------------------------------------------------------
  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
  
    if ( ((f_sync_type & 7) < 0) || ((f_sync_type & 7) > 4) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter (f_sync_type & 7) (legal range: 0 to 4)",
	(f_sync_type & 7) );
    end
  
    if ( ((r_sync_type & 7) < 0) || ((r_sync_type & 7) > 4) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter (r_sync_type & 7) (legal range: 0 to 4)",
	(r_sync_type & 7) );
    end
  
    if ( (reg_in_prog < 0) || (reg_in_prog > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter reg_in_prog (legal range: 0 to 1)",
	reg_in_prog );
    end
  
    if ( (tst_mode < 0) || (tst_mode > 2) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter tst_mode (legal range: 0 to 2)",
	tst_mode );
    end
  
    if ( (verif_en < 0) || (verif_en > 4) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter verif_en (legal range: 0 to 4)",
	verif_en );
    end
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 


  wire                      lOl0I0l1;
  wire                      Il0110O1;
  wire                      O010111l;

  integer                   I01O0111;
  integer                   l1010110;

  reg                       O1111O0O;
  wire                      OOlIO1OO;
  reg                       lll0OO11;
  wire                      I0I0O1l1;
  wire                      lO1O1011;

  reg                       l011lO0l;
  wire                      l00O0lO1;
  wire                      l11Ol01I;
  wire                      OI01IO11;
  wire                      l0Ol100I;
  reg                       l10Ol00O;

  wire                      IOIOOIlO;
  wire                      OOI1001O;

  reg                       O100OIlI;
  wire                      l0IlI00O;
  reg                       IIOOI0Ol;
  reg                       Il1O110I;
  reg                       O1OOO1O0;
  wire                      O0OIl111;

  integer                   OOOOIlO1;
  integer                   OI1IO11l;

  reg                       OlOOO000;
  wire                      IllIlOl0;
  wire                      I0OO1l01;
  wire                      lI1IO1O0;
  reg                       OO001I10;

  wire                      O0III10l;
  reg                       IO00llI0;

  wire                      OOlOO11O;
  reg                       OIO10I11;

  integer  O0IOO0OO;



assign IllIlOl0   = (reg_in_prog == 0) ? ((IOIOOIlO && !OlOOO000) ||
                                                (((OI1IO11l == 1) && (OOOOIlO1 == 0)) && IOIOOIlO)) :
//                                               (!clr_in_prog_d && IOIOOIlO);
                                               (OI1IO11l == 1) && (OOOOIlO1 == 0);
assign I0OO1l01 = (OI1IO11l == 0) && (OOOOIlO1 == 1);
assign lI1IO1O0  = (IllIlOl0 && !I0OO1l01) ? 1'b1 :
                            (I0OO1l01) ? 1'b0 : OO001I10;



  initial begin
    if ((f_sync_type > 0)&&(f_sync_type < 8))
      $display("Information: *** Instance %m is the DW_reset_sync Clock Domain Crossing Module ***");
  end


DW_pulse_sync #(1, (f_sync_type + 8), tst_mode, verif_en, 1) U_PS_SRC_INIT (
            .clk_s(clk_s),
            .rst_s_n(rst_s_n),
            .init_s_n(init_s_n),
            .event_s(clr_s),
            .clk_d(clk_d),
            .rst_d_n(rst_d_n),
            .init_d_n(init_d_n),
            .test(test),
            .event_d(lOl0I0l1)
            );


  
generate
  if (((f_sync_type&7)>1)&&(tst_mode==2)) begin : GEN_LATCH_frwd_hold_latch_PROC
    reg [1-1:0] OIO10I11;
    always @ (clk_s or clr_s) begin : LATCH_frwd_hold_latch_PROC_PROC

      if (clk_s == 1'b0)

	OIO10I11 = clr_s;


    end // LATCH_frwd_hold_latch_PROC_PROC


    assign OOlOO11O = (test==1'b1)? OIO10I11 : clr_s;

  end else begin : GEN_DIRECT_frwd_hold_latch_PROC
    assign OOlOO11O = clr_s;
  end
endgenerate

  DW_sync #(1, f_sync_type+8, tst_mode, verif_en) U_SYNC_CLR_S(
	.clk_d(clk_d),
	.rst_d_n(rst_d_n),
	.init_d_n(init_d_n),
	.data_s(OOlOO11O),
	.test(test),
	.data_d(Il0110O1) );

assign O010111l = lOl0I0l1 || Il0110O1;



DW_pulse_sync #(0, (r_sync_type + 8), tst_mode, O0llO1Ol, 0) U_PS_DEST_INIT (
            .clk_s(clk_d),
            .rst_s_n(rst_d_n),
            .init_s_n(init_d_n),
            .event_s(OOI1001O),
            .clk_d(clk_s),
            .rst_d_n(rst_s_n),
            .init_d_n(init_s_n),
            .test(test),
            .event_d(OI01IO11)
            );

DW_pulse_sync #(0, (f_sync_type + 8), tst_mode, verif_en, 0) U_PS_FB_DEST (
            .clk_s(clk_s),
            .rst_s_n(rst_s_n),
            .init_s_n(init_s_n),
            .event_s(l10Ol00O),
            .clk_d(clk_d),
            .rst_d_n(rst_d_n),
            .init_d_n(init_d_n),
            .test(test),
            .event_d(l11Ol01I)
            );

assign O0III10l  = (l11Ol01I && IOIOOIlO) ? 1'b1 :
                          (!l11Ol01I && !IOIOOIlO && IO00llI0) ? 1'b0 :
                            IO00llI0; 
assign l00O0lO1 = (l11Ol01I && !IOIOOIlO && !IO00llI0) || 
                        (!l11Ol01I && !IOIOOIlO && IO00llI0);

DW_pulse_sync #(0, (r_sync_type + 8), tst_mode, verif_en, 0) U_PS_ACK (
            .clk_s(clk_d),
            .rst_s_n(rst_d_n),
            .init_s_n(init_d_n),
            .event_s(l011lO0l),
            .clk_d(clk_s),
            .rst_d_n(rst_s_n),
            .init_d_n(init_s_n),
            .test(test),
            .event_d(lO1O1011)
            );

  always @(OI01IO11 or lO1O1011 or I01O0111) begin : a1000_PROC
    if (OI01IO11 && ~lO1O1011) begin
      if (I01O0111 === `DW_IIOOl10O)
        l1010110 = I01O0111;
      else
        l1010110 = I01O0111 + 1;
    end else if (~OI01IO11 && lO1O1011) begin
      if (I01O0111 === 0)
        l1010110 = I01O0111;
      else
        l1010110 = I01O0111 - 1;
    end else begin
      l1010110 = I01O0111;
    end
  end

  assign OOlIO1OO = (l1010110 > 0); 

  assign I0I0O1l1   = lO1O1011 && ((I01O0111 === 1) && (l1010110 === 0));

  assign IOIOOIlO              = O010111l || clr_d;
  assign OOI1001O       = IOIOOIlO && !OO001I10;

  assign l0IlI00O = (OI1IO11l > 0);

  assign l0Ol100I    = l00O0lO1 & ~OOI1001O;


  always @(OOI1001O or l011lO0l or OOOOIlO1) begin : a1001_PROC
    if (OOI1001O && ~l011lO0l) begin
      if (OOOOIlO1 === `DW_IIOOl10O)
        OI1IO11l = OOOOIlO1;
      else
        OI1IO11l = OOOOIlO1 + 1;
    end else if (~OOI1001O && l011lO0l) begin
      if (OOOOIlO1 === 0)
        OI1IO11l = OOOOIlO1;
      else
        OI1IO11l = OOOOIlO1 - 1;
    end else begin
      OI1IO11l = OOOOIlO1;
    end
  end

  assign O0OIl111   = ~O100OIlI && IIOOI0Ol;


  always @(posedge clk_s or negedge rst_s_n) begin : a1002_PROC
    if (rst_s_n === 1'b0) begin
      I01O0111          <= 0;
      l10Ol00O  <= 1'b0;
      O1111O0O  <= 1'b0;
      lll0OO11    <= 1'b0;
    end else if (rst_s_n === 1'b1) begin
      if (init_s_n === 1'b0) begin
        I01O0111          <= 0;
        l10Ol00O  <= 1'b0;
        O1111O0O  <= 1'b0;
        lll0OO11    <= 1'b0;
      end else if (init_s_n === 1'b1) begin
        I01O0111          <= l1010110;
        l10Ol00O  <= OI01IO11;
        O1111O0O  <= OOlIO1OO;
        lll0OO11    <= I0I0O1l1;
      end else begin
        I01O0111          <= -1;
        l10Ol00O  <= 1'bX;
        O1111O0O  <= 1'bX;
        lll0OO11    <= 1'bX;
      end
    end else begin
      I01O0111          <= -1;
      l10Ol00O  <= 1'bX;
      O1111O0O  <= 1'bX;
      lll0OO11    <= 1'bX; 
    end
  end

  always @(posedge clk_d or negedge rst_d_n) begin : a1003_PROC
    if (rst_d_n === 1'b0) begin
      OlOOO000      <= 1'b0;
      OO001I10           <= 1'b0;
      OOOOIlO1            <= 0;
      O100OIlI    <= 1'b0;
      IIOOI0Ol <= 1'b0;
      l011lO0l            <= 1'b0;
      Il1O110I       <= 1'b0;
      O1OOO1O0      <= 1'b0;
      IO00llI0             <= 1'b0;
    end else if (rst_d_n === 1'b1) begin
      if (init_d_n === 1'b0) begin
        OlOOO000      <= 1'b0;
        OO001I10           <= 1'b0;
        OOOOIlO1            <= 0;
        O100OIlI    <= 1'b0;
        IIOOI0Ol <= 1'b0;
        l011lO0l            <= 1'b0;
        Il1O110I       <= 1'b0;
        O1OOO1O0      <= 1'b0;
        IO00llI0             <= 1'b0;
      end else if (init_d_n === 1'b1) begin
        OlOOO000      <= IOIOOIlO;
        OO001I10           <= lI1IO1O0;
        OOOOIlO1            <= OI1IO11l;
        O100OIlI    <= l0IlI00O;
        IIOOI0Ol <= O100OIlI;
        l011lO0l            <= l00O0lO1;
        Il1O110I       <= l0Ol100I;
        O1OOO1O0      <= O0OIl111;
        IO00llI0             <= O0III10l;
      end else begin
        OlOOO000      <= 1'bX;
        OO001I10           <= 1'bX;
        OOOOIlO1            <= -1;
        O100OIlI    <= 1'bX;
        IIOOI0Ol <= 1'bX;
        l011lO0l            <= 1'bX;
        Il1O110I       <= 1'bX;
        O1OOO1O0      <= 1'bX;
        IO00llI0             <= 1'bX;
      end
    end else begin
      OlOOO000      <= 1'bX;
      OO001I10           <= 1'bX;
      OOOOIlO1            <= -1;
      O100OIlI    <= 1'bX;
      IIOOI0Ol <= 1'bX;
      l011lO0l            <= 1'bX;
      Il1O110I       <= 1'bX;
      O1OOO1O0      <= 1'bX; 
      IO00llI0             <= 1'bX;
    end
  end

  assign clr_sync_s      = OI01IO11;
  assign clr_cmplt_s     = lll0OO11;
  assign clr_in_prog_s   = (reg_in_prog == 0) ? OOlIO1OO : O1111O0O;
  assign clr_in_prog_d   = (reg_in_prog == 0) ? O100OIlI : IIOOI0Ol;
  assign clr_sync_d      = Il1O110I;
  assign clr_cmplt_d     = O1OOO1O0;


  
  always @ (clk_s) begin : monitor_clk_s 
    if ( (clk_s !== 1'b0) && (clk_s !== 1'b1) && ($time > 0) )
      $display( "WARNING: %m :\n  at time = %t, detected unknown value, %b, on clk_s input.",
                $time, clk_s );
    end // monitor_clk_s 
  
  always @ (clk_d) begin : monitor_clk_d 
    if ( (clk_d !== 1'b0) && (clk_d !== 1'b1) && ($time > 0) )
      $display( "WARNING: %m :\n  at time = %t, detected unknown value, %b, on clk_d input.",
                $time, clk_d );
    end // monitor_clk_d 


// synopsys translate_on
`undef DW_IIOOl10O
endmodule
/* vcs gen_ip dbg_ip off */
 /* */

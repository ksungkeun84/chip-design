////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 2006 - 2018 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Kyung-Nam Han, Sep. 25, 2006
//
// VERSION:   Verilog Simulation Model for DW_fp_div_seq
//
// DesignWare_version: f59c9a8c
// DesignWare_release: O-2018.06-DWBB_201806.3
//
////////////////////////////////////////////////////////////////////////////////

//-----------------------------------------------------------------------------
//
// ABSTRACT: Floating-Point Sequencial Divider
//
//              DW_fp_div_seq calculates the floating-point division
//              while supporting six rounding modes, including four IEEE
//              standard rounding modes.
//
//              parameters      valid values (defined in the DW manual)
//              ==========      ============
//              sig_width       significand size,  2 to 253 bits
//              exp_width       exponent size,     3 to 31 bits
//              ieee_compliance support the IEEE Compliance
//                              0 - IEEE 754 compatible without denormal support
//                                  (NaN becomes Infinity, Denormal becomes Zero)
//                              1 - IEEE 754 standard compatible
//                                  (NaN and denormal numbers are supported)
//              num_cyc         Number of cycles required for the FP sequential
//                              division operation including input and output
//                              register. Actual number of clock cycle is
//                              num_cyc - (1 - input_mode) - (1 - output_mode)
//                               - early_start + internal_reg
//              rst_mode        Synchronous / Asynchronous reset
//                              0 - Asynchronous reset
//                              1 - Synchronous reset
//              input_mode      Input register setup
//                              0 - No input register
//                              1 - Input registers are implemented
//              output_mode     Output register setup
//                              0 - No output register
//                              1 - Output registers are implemented
//              early_start     Computation start (only when input_mode = 1)
//                              0 - start computation in the 2nd cycle
//                              1 - start computation in the 1st cycle (forwarding)
//                              early_start should be 0 when input_mode = 0
//              internal_reg    Insert a register between an integer sequential divider
//                              and a normalization unit
//                              0 - No internal register
//                              1 - Internal register is implemented
//
//              Input ports     Size & Description
//              ===========     ==================
//              a               (sig_width + exp_width + 1)-bits
//                              Floating-point Number Input
//              b               (sig_width + exp_width + 1)-bits
//                              Floating-point Number Input
//              rnd             3 bits
//                              Rounding Mode Input
//              clk             Clock
//              rst_n           Reset. (active low)
//              start           Start operation
//                              A new operation is started by setting start=1
//                              for 1 clock cycle
//              z               (sig_width + exp_width + 1)-bits
//                              Floating-point Number Output
//              status          8 bits
//                              Status Flags Output
//              complete        Operation completed
//
// Modified:
//   6/05/07 KYUNG (0703-SP3)
//           The legal range of num_cyc parameter widened.
//   3/25/08 KYUNG (0712-SP3)
//           Fixed the reset error (STAR 9000234177)
//   1/29/10 KYUNG (D-2010.03)
//           1. Removed synchronous DFF when rst_mode = 0 (STAR 9000367314)
//           2. Fixed complete signal error at the reset  (STAR 9000371212)
//           3. Fixed divide_by_zero flag error           (STAR 9000371212)
//   2/27/12 RJK (F-2011.09-SP4)
//           Added missing message when input changes during calculation
//           while input_mode=0 (STAR 9000523798)
//   9/22/14 KYUNG (J-2014.09-SP1)
//           Modified for the support of VCS NLP feature
//   9/22/15 RJK (K-2015.06-SP3) Further update for NLP compatibility
//   2/26/16 LMSU
//           Updated to use blocking and non-blocking assigments in
//           the correct way
//   10/2/17 AFT (M-2016.12-SP5-2)
//           Fixed the behavior of the complete output signal to match
//           the synthesis model and the VHDL simulation model. 
//           (STAR 9001121224)
//           Also fixed the issue with the impact of rnd input on the
//           components output 'z'. (STAR 9001251699)
//  07/10/18 AFT - Star 9001366623
//           Signal int_complete_advanced had its declaration changed from
//           'reg' to 'wire'.
//
//-----------------------------------------------------------------------------

module DW_fp_div_seq (a, b, rnd, clk, rst_n, start, z, status, complete);

  parameter integer sig_width = 23;      // RANGE 2 TO 253
  parameter integer exp_width = 8;       // RANGE 3 TO 31
  parameter integer ieee_compliance = 0; // RANGE 0 TO 1
  parameter integer num_cyc = 4;         // RANGE 4 TO (2 * sig_width + 3)
  parameter integer rst_mode = 0;        // RANGE 0 TO 1
  parameter integer input_mode = 1;      // RANGE 0 TO 1
  parameter integer output_mode = 1;     // RANGE 0 TO 1
  parameter integer early_start = 0;     // RANGE 0 TO 1
  parameter integer internal_reg = 1;    // RANGE 0 TO 1


  localparam TOTAL_WIDTH = (sig_width + exp_width + 1);

//-----------------------------------------------------------------------------

  input [(exp_width + sig_width):0] a;
  input [(exp_width + sig_width):0] b;
  input [2:0] rnd;
  input clk;
  input rst_n;
  input start;

  output [(exp_width + sig_width):0] z;
  output [8    -1:0] status;
  output complete;

// synopsys translate_off

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
    
    if ( (sig_width < 2) || (sig_width > 253) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter sig_width (legal range: 2 to 253)",
	sig_width );
    end
    
    if ( (exp_width < 3) || (exp_width > 31) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter exp_width (legal range: 3 to 31)",
	exp_width );
    end
    
    if ( (ieee_compliance < 0) || (ieee_compliance > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter ieee_compliance (legal range: 0 to 1)",
	ieee_compliance );
    end
    
    if ( (num_cyc < 4) || (num_cyc > 2*sig_width+3) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter num_cyc (legal range: 4 to 2*sig_width+3)",
	num_cyc );
    end
    
    if ( (rst_mode < 0) || (rst_mode > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter rst_mode (legal range: 0 to 1)",
	rst_mode );
    end
    
    if ( (input_mode < 0) || (input_mode > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter input_mode (legal range: 0 to 1)",
	input_mode );
    end
    
    if ( (output_mode < 0) || (output_mode > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter output_mode (legal range: 0 to 1)",
	output_mode );
    end
    
    if ( (early_start < 0) || (early_start > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter early_start (legal range: 0 to 1)",
	early_start );
    end
    
    if ( (internal_reg < 0) || (internal_reg > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter internal_reg (legal range: 0 to 1)",
	internal_reg );
    end
    
    if ( (input_mode===0 && early_start===1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m : Invalid parameter combination: when input_mode=0, early_start=1 is not possible" );
    end
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 


//-----------------------------------------------------------------------------

  localparam CYC_CONT = num_cyc - 3;
  integer count;
  integer next_count;
  integer cnt_glitch;

  reg  [(exp_width + sig_width):0] ina;
  reg  [(exp_width + sig_width):0] inb;
  reg  [(exp_width + sig_width):0] next_ina;
  reg  [(exp_width + sig_width):0] next_inb;
  reg  [(exp_width + sig_width):0] next_int_z;
  reg  [(exp_width + sig_width):0] int_z;
  reg  [(exp_width + sig_width):0] int_z_d1;
  reg  [(exp_width + sig_width):0] int_z_d2;
  reg  [7:0] next_int_status;
  reg  [7:0] int_status;
  reg  [7:0] int_status_d1;
  reg  [7:0] int_status_d2;
  reg  [2:0] rnd_reg;
  reg  new_input_pre;
  reg  new_input_reg_d1;
  reg  new_input_reg_d2;
  reg  next_int_complete;
  reg  next_complete;
  reg  int_complete;
  wire int_complete_advanced; 

  reg  int_complete_d1;
  reg  int_complete_d2;
  reg  count_reseted;
  reg  next_count_reseted;

  wire [(exp_width + sig_width):0] ina_div;
  wire [(exp_width + sig_width):0] inb_div;
  wire [(exp_width + sig_width):0] z;
  wire [(exp_width + sig_width):0] temp_z;
  wire [7:0] status;
  wire [7:0] temp_status;
  wire [2:0] rnd_div;
  wire clk, rst_n;
  wire complete;
  wire start_in;

  reg  start_clk;
  wire rst_n_rst;
  reg  reset_st;
  wire corrupt_data;
  reg  [(exp_width + sig_width):0] a_reg;
  reg  [(exp_width + sig_width):0] b_reg;

  localparam [1:0] output_cont = output_mode + internal_reg;

  assign corrupt_data = (output_cont == 2) ? new_input_reg_d2:
                        (output_cont == 1) ? new_input_reg_d1:
                        new_input_pre;

  assign z = (reset_st) ? 0 :
             (corrupt_data !== 1'b0)? {TOTAL_WIDTH{1'bx}} :
             (output_cont == 2) ? int_z_d2 :
             (output_cont == 1) ? int_z_d1 :
             next_int_z;

  assign status = (reset_st) ? 0 :
                  (corrupt_data !== 1'b0)? {8{1'bx}} :
                  (output_cont == 2) ? int_status_d2 :
                  (output_cont == 1) ? int_status_d1 :
                  next_int_status;

  assign complete = (rst_n == 1'b0 && rst_mode == 0) ? 1'b0:
              (output_cont == 2) ? int_complete_d2:
              (output_cont == 1) ? int_complete_d1:
              int_complete_advanced;

  assign ina_div = (input_mode == 1) ? ina : a;
  assign inb_div = (input_mode == 1) ? inb : b;
  assign rnd_div = (input_mode==1) ? rnd_reg : rnd;

  DW_fp_div #(sig_width, exp_width, ieee_compliance) U1 (
                      .a(ina_div),
                      .b(inb_div),
                      .rnd(rnd_div),
                      .z(temp_z),
                      .status(temp_status)
  );

  generate
  if (rst_mode == 0) begin : GEN_RM_EQ_0_CORRUPT_DATA
  always @(posedge clk or negedge rst_n) begin : a1000_PROC
    if (rst_n == 1'b0) begin
      new_input_reg_d1 <= 1'b0;
      new_input_reg_d2 <=1'b0;
    end else begin
      new_input_reg_d1 <= new_input_pre;
      new_input_reg_d2 <= new_input_reg_d1;
    end
  end
  end else begin : GEN_RM_NEQ_0_CORRUPT_DATA
  always @(posedge clk) begin : a1001_PROC
    if (rst_n == 1'b0) begin
      new_input_reg_d1 <= 1'b0;
      new_input_reg_d2 <=1'b0;
    end else begin
      new_input_reg_d1 <= new_input_pre;
      new_input_reg_d2 <= new_input_reg_d1;
    end
  end 
  end
  endgenerate

  always @(ina_div or inb_div) begin : a1002_PROC
    new_input_pre = (start_in == 1'b0) & (input_mode == 0) & (reset_st == 1'b0);
  end

  generate 
  if (rst_mode == 0) begin : GEN_DATA_DETCT_RM0
  always @(posedge clk or negedge rst_n) begin: DATA_CHANGE_DETECTION_PROC
    if (rst_n == 1'b0) begin
      new_input_pre <= 1'b0;
    end else begin
      if (input_mode == 0 && reset_st == 1'b0 && start_in == 1'b0 && (a_reg != a || b_reg != b)) begin
        new_input_pre <= 1'b1;
      end else begin
        if (start_in == 1'b1) begin
          new_input_pre <= 1'b0;
        end 
      end
    end
  end
  end
  else begin : GEN_DATA_DETCT_RM1
  always @(posedge clk) begin: DATA_CHANGE_DETECTION_PROC
    if (rst_n == 1'b0) begin
      new_input_pre <= 1'b0;
    end else begin
      if (input_mode == 0 && reset_st == 1'b0 && start_in == 1'b0 && (a_reg != a || b_reg != b)) begin
        new_input_pre <= 1'b1;
      end else begin
        if (start_in == 1'b1) begin
          new_input_pre <= 1'b0;
        end 
      end
    end
  end
  end
  endgenerate

  assign start_in = (input_mode & ~early_start) ? start_clk : start;

  always @(start or a or b or ina or inb or count_reseted or next_count) begin : next_comb_PROC
    if (start===1'b1) begin
      next_ina           = a;
      next_inb           = b;
    end
    else if (start===1'b0) begin
      if (next_count >= CYC_CONT) begin
        next_ina           = ina;
        next_inb           = inb;
      end else if (next_count === -1) begin
        next_ina           = {TOTAL_WIDTH{1'bX}};
        next_inb           = {TOTAL_WIDTH{1'bX}};
      end else begin
        next_ina           = ina;
        next_inb           = inb;
      end 
    end
  end

  always @(rst_n or start_in or a or b or ina or inb or count_reseted or next_count or
           temp_z or temp_status or output_cont or count or reset_st) begin : next_state_comb_PROC
    if (start_in===1'b1) begin
      next_count_reseted = 1'b1;
      next_complete      = 1'b0;
      next_int_complete  = 1'b0;
      next_int_z         = {TOTAL_WIDTH{1'bx}};
      next_int_status    = {8{1'bx}};
    end
    else if (start_in===1'b0) begin
      next_count_reseted = 1'b0;
      if (count >= CYC_CONT) begin
        next_int_z         = temp_z & {((exp_width + sig_width) + 1){~(start_in | reset_st)}};
        next_int_status    = temp_status & {8{~(start_in | reset_st)}};
      end
      if (next_count >= CYC_CONT) begin
        next_int_complete  = rst_n;
        next_complete      = 1'b1;
      end else if (next_count === -1) begin
        next_int_complete  = 1'bX;
        next_int_z         = {TOTAL_WIDTH{1'bX}};
        next_int_status    = {8{1'bX}};
        next_complete      = 1'bX;
      end else begin
        next_int_complete  = 0;
        next_int_z         = {TOTAL_WIDTH{1'bX}};
        next_int_status    = {8{1'bX}};
      end 
    end

  end

  always @(start_in or count_reseted or count) begin : a1003_PROC
    if (start_in===1'b1)
      next_count = 0;
    else if(start_in===1'b0) begin
      if (count >= CYC_CONT)
        next_count = count;
      else if (count === -1)
        next_count = -1;
      else
        next_count = count + 1;
    end
  end
 
  assign int_complete_advanced = (internal_reg == 1 || input_mode == 1 || output_mode == 1)?int_complete & (~start_in):int_complete;

  generate
  if (rst_mode == 0) begin : GEN_RM_EQ_0_D
    always @ (posedge clk or negedge rst_n) begin: register_PROC
      if (rst_n === 1'b0) begin
        int_z           <= 0;
        int_status      <= 0;
        int_complete    <= 0;
        count_reseted   <= 0;
        count           <= 0;
        ina             <= 0;
        inb             <= 0;
        int_z_d1        <= 0;
        int_z_d2        <= 0;
        int_status_d1   <= 0;
        int_status_d2   <= 0;
        int_complete_d1 <= 0;
        int_complete_d2 <= 0;
        start_clk       <= 0;
        a_reg           <= 0;
        b_reg           <= 0;
        rnd_reg         <= 3'b000;
      end else if (rst_n === 1'b1) begin
        int_z           <= next_int_z;
        int_status      <= next_int_status;
        int_complete    <= next_int_complete;
        count_reseted   <= next_count_reseted;
        count           <= next_count;
        ina             <= next_ina;
        inb             <= next_inb;
        int_z_d1        <= next_int_z;
        int_z_d2        <= int_z_d1;
        int_status_d1   <= next_int_status;
        int_status_d2   <= int_status_d1;
        int_complete_d1 <= int_complete_advanced;
        int_complete_d2 <= int_complete_d1;
        start_clk       <= start;
        a_reg           <= a;
        b_reg           <= b;
        rnd_reg         <= (start == 1'b1)?rnd:rnd_reg;
      end else begin
        int_z           <= {(exp_width + sig_width){1'bx}};
        int_status      <= {7{1'bx}};
        int_complete    <= 1'bx;
        count_reseted   <= 1'bx;
        count           <= -1;
        ina             <= {TOTAL_WIDTH{1'bx}};
        inb             <= {TOTAL_WIDTH{1'bx}};
        int_z_d1        <= {(exp_width + sig_width){1'bx}};
        int_z_d2        <= {(exp_width + sig_width){1'bx}};
        int_status_d1   <= {8{1'bx}};
        int_status_d2   <= {8{1'bx}};
        int_complete_d1 <= 1'bx;
        int_complete_d2 <= 1'bx;
        start_clk       <= 1'bx;
        a_reg           <= {TOTAL_WIDTH{1'bx}};
        b_reg           <= {TOTAL_WIDTH{1'bx}};
        rnd_reg         <= 3'bxxx;
      end
    end
    always @(posedge clk or negedge rst_n) begin: RST_FSM_PROC
      if (rst_n == 1'b0) begin
        reset_st <= 1'b1;
      end else begin
        if (start == 1'b1) reset_st <= 1'b0;
      end 
    end
  end
  else begin : GEN_RM_NE_0_D
    always @ ( posedge clk) begin: register_PROC
      if (rst_n === 1'b0) begin
        int_z           <= 0;
        int_status      <= 0;
        int_complete    <= 0;
        count_reseted   <= 0;
        count           <= 0;
        ina             <= 0;
        inb             <= 0;
        int_z_d1        <= 0;
        int_z_d2        <= 0;
        int_status_d1   <= 0;
        int_status_d2   <= 0;
        int_complete_d1 <= 0;
        int_complete_d2 <= 0;
        start_clk       <= 0;
        a_reg           <= 0;
        b_reg           <= 0;
        rnd_reg         <= 3'b000;
      end else if (rst_n === 1'b1) begin
        int_z           <= next_int_z;
        int_status      <= next_int_status;
        int_complete    <= next_int_complete;
        count_reseted   <= next_count_reseted;
        count           <= next_count;
        ina             <= next_ina;
        inb             <= next_inb;
        int_z_d1        <= next_int_z;
        int_z_d2        <= int_z_d1;
        int_status_d1   <= next_int_status;
        int_status_d2   <= int_status_d1;
        int_complete_d1 <= int_complete_advanced;
        int_complete_d2 <= int_complete_d1;
        start_clk       <= start;
        a_reg           <= a;
        b_reg           <= b;
        rnd_reg         <= (start==1'b1)?rnd:rnd_reg;
      end else begin
        int_z           <= {(exp_width + sig_width){1'bx}};
        int_status      <= {8{1'bx}};
        int_complete    <= 1'bx;
        count_reseted   <= 1'bx;
        count           <= -1;
        ina             <= {TOTAL_WIDTH{1'bx}};
        inb             <= {TOTAL_WIDTH{1'bx}};
        int_z_d1        <= {(exp_width + sig_width){1'bx}};
        int_z_d2        <= {(exp_width + sig_width){1'bx}};
        int_status_d1   <= {8{1'bx}};
        int_status_d2   <= {8{1'bx}};
        int_complete_d1 <= 1'bx;
        int_complete_d2 <= 1'bx;
        start_clk       <= 1'bx;
        a_reg           <= {TOTAL_WIDTH{1'bx}};
        b_reg           <= {TOTAL_WIDTH{1'bx}};
        rnd_reg         <= 3'bxxx;
      end
    end
    always @(posedge clk) begin: RST_FSM_PROC
      if (rst_n == 1'b0) begin
        reset_st <= 1'b1;
      end else begin
        if (start == 1'b1) reset_st <= 1'b0;
      end 
    end
  end
  endgenerate

  
  always @ (clk) begin : P_monitor_clk 
    if ( (clk !== 1'b0) && (clk !== 1'b1) && ($time > 0) )
      $display( "WARNING: %m :\n  at time = %t, detected unknown value, %b, on clk input.",
                $time, clk );
    end // P_monitor_clk 

`ifdef UPF_POWER_AWARE
  `protected
\e(O-[[A:?)b@9W9c#C5&DXSVHg-98:A005,V-EW:7\,#@#LQAV-3)5A1>.\XKIL
>(6fAbRd=2Z?1Vdc&ANaINXFR/TBfXRF(@@S?(<6bcfV[fPT]71(XaU;QM\[[QNf
W=74,fge<=a1F-K:cFA4;9WS0dTMVMOHRN/FA3R0fX3EgDF^H@E9a:#_7^[:9Y4E
<(F2VKYPIb5Wc;\UPPCJ(X[#_R0R&@Q3=-43;K2O,WL^>cAW94WOf4TK?+,_&;fB
b]U[Q<YSHd^KN,S2+I.<dCCVfP:I2PaJ>XRGA,?g>369?IDV[?C86)WeW^>RSW_Z
dc1)8/U.B9>-If2g=HfG2dY[+5cdM8C2^.bPb0PM?#JSQDAI>)-U]7=,aL;)PFDM
,P):-F?J#92f\<HRU52P5]+GX>35[e/14E4H+eC(Of&SD(\+.d&X+&4g-A#6=9^#
+?XP&eZc7<6_L?54)BCg]aAT22CgAfD?ZGV<\Se3-V(cgCeMeZ./N1YQT:CQF9JG
0GcaA,B_9M>\6c[8X,I;M)b.F_D?0A0,a5YU4[=NId7O^;>H()YE3BdH)5D^S50:
?(g^02Q941;>//Qa]QWd9.Fb(Cee.UJ&7;_3H28V^//Y;0(#2TVb0\:<MQ0V/A6#
<GgT5ND3c>-J_0SXVJQ0#F6A]?MQ^SLJQ1_0O=fHNG)BJN[Sfe<@F#0>JK]G#.TU
_g@,MI-P-(1)-3Q7CIeI0;U-c/#TbcOWZEA04@W,\/dZA+3V76XA+eZ&^]LbWdKg
:,Z_[N@)Cc5:L)UX=UUZ?5bDH^d]5La@I8LZ[<_Zd48+32?T8dFQc=Mae0SG\FdD
H&FS#&\2>.bU;cWO(L7J0Q4ed5(JMS+=J0Zb:+_KfGO;dG>VE0f9E;f@eDYX6<4K
>XM;^WA<V(67+E=[XVULR@R8@>@\^SY.acL0R&WVJ/_I.V&S[/=N:Y[ZEP]aQ#V]
NO^CUCAPEc-H+gVJg5eF-K(6#XW[K27b]1I,LQEMW?:SS-_7)e9c1eHe/S?H)ZT+
+0[HV6BDH825-QXGf^0.&[H4)G.7]0dI:<F)#8)dLK@9+=>3KEaX,5.=:Ecd1:N(
V<6fEf?WW3UTN1?M]90FWPF<5E+N1U[Q.GMBL^TH0-?efcNND5->5a>e?TTR;G??
Y4AJeQM6:5O@&)_Xb?64@O5,<7PPDOb,T4#X2HBJL)/]E0<?=]HGc7N+,&J:7gP@
^aRC)8PVdX#aO;K-_YeDNd.9f&N4>R.VP,<[d9c>-\?EX]_0#;DYK7aMYJZ_4QTO
7DF/^S6b/]aC^XK&,c5-+KaD-=L?f7cOgY?[TY,_4&WL:?CeX8+bVK3C-XM?=-7-
5Z_.8UX4L1;Ob):a6:/<gLX.ZPZ^Ga1ZN9Y#RUL#:.DQOa7I2Z)aQ0)H3g^27dWA
@]X1MSN^\SP[<93>2,N6(_5[E^IAJ@Z]_^.LbW,??GVU@1&4-bS9e3U7[)4W:^21
(c:#KcY<?VD?]@B(I:;MVaJgf37WAb>?J[<-,7beW.K[LH_EEZ5WC/20UQ,/;3-2
g6d,d]^,g88eH=c)dE@:[1<..[335VVfP?]#:>IJNQTU->PZP8CSM3Wc]GMaD7MY
cBF1fM.W[4@G,)4Hf8-YMcJ;UEYMHUG[JJ-#G0I)fO9K6(W3U&aYbf+B0DPX-ARa
WH8ScB2g8CF1319MT:H;eR_XR&d92^N0Q+1,bYI[#<\#I#+6HK.bM?;G_dLdR@3E
3gga_\K)2B?DW;AH1/FNWL>YaEUfdR.KT7K.@,1/</QSBHDDNA+O:)N@>+.G:G2c
(X.fA.L@5LedEc<1S@]gK-Zea)-/\IN<9L=QD6VQGT)CL/R=.M9A&8Hb[3PYJ.>H
.Le#;E+=(g3K6e3Je.=TU/2#LL717K94[^8fU#+5)NeP[UKVD);f@6[L4d>:T3JP
#&NWe^N=[:e;9^ES=(/6[+>bA@HV1^DLWZNQ+WJ>P)8FHcPN_C,Qe4F(FHIMN]-d
2gCFI.f7BB6eLS(7[EBH\4W0NZ-Q=YQS>0_/,3OF0d_0T302Ae]HZ0ID4a)g.R\U
G9X2C-#0/5^-0]?NgeGR_Y1Q#^I>QZ_NXI7W]^2+Ra=TED9UPP=a.^7Ta<<J#)d?
T=9:<:/SgG<Z10LBU<SU@4c6bTPYRD(Oa?&WVZ9-@]TDcK/_C(TRG)Z22d?Y\fb]W$
`endprotected

`else
    always @ (posedge clk) begin : corrupt_alert_PROC

      if (new_input_pre == 1'b1) begin
        $display("## Warning from %m: DW_fp_div_seq operand input change near %0d will cause corrupted results if operation is allowed to complete.", $time);
      end

      if (corrupt_data == 1'b1 && complete == 1'b1) begin
	$display(" ");
	$display("############################################################");
	$display("############################################################");
	$display("##");
	$display("## Error!! : from %m");
	$display("##");
	$display("##    This instance of DW_fp_div_seq has encountered changes");
	$display("##    on operand input(s) after starting the calculation.");
	$display("##    The instance is configured with no input register.");
	$display("##    So, the result of the operation was corrupted.  This");
	$display("##    message is generated at the point of completion of");
	$display("##    the operation (at time %0d), separate warning(s) were", $time );
	$display("##    generated earlier during calculation.");
	$display("##");
	$display("############################################################");
	$display("############################################################");
	$display(" ");
      end
    end
`endif


// synopsys translate_on

endmodule

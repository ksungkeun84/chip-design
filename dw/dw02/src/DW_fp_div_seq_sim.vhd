
--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2006 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Kyung-Nam Han, Sep. 25, 2006
--
-- VERSION:   VHDL Simulation Model for DW_fp_div_seq
--
-- DesignWare_version: ee706bdb
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-- ABSTRACT: Floating-Point Sequencial Divider
--
--              DW_fp_div_seq calculates the floating-point division
--              while supporting six rounding modes, including four IEEE
--              standard rounding modes.
--
--              parameters      valid values (defined in the DW manual)
--              ==========      ============
--              sig_width       significand size,  2 to 253 bits
--              exp_width       exponent size,     3 to 31 bits
--              ieee_compliance support the IEEE Compliance 
--                              0 - IEEE 754 compatible without denormal support
--                                  (NaN becomes Infinity, Denormal becomes Zero)
--                              1 - IEEE 754 compatible with denormal support
--                                  (NaN and denormal numbers are supported)
--              num_cyc         Number of cycles required for the FP sequential
--                              division operation including input and output 
--                              register. Actual number of clock cycle is 
--                              num_cyc - (1 - input_mode) - (1 - output_mode)
--                               - early_start + internal_reg
--              rst_mode        Synchronous / Asynchronous reset 
--                              0 - Asynchronous reset
--                              1 - Synchronous reset
--              input_mode      Input register setup
--                              0 - No input register
--                              1 - Input registers are implemented
--              output_mode     Output register setup
--                              0 - No output register
--                              1 - Output registers are implemented
--              early_start     Computation start (only when input_mode = 1)
--                              0 - start computation in the 2nd cycle
--                              1 - start computation in the 1st cycle (forwarding)
--                              early_start should be 0 when input_mode = 0
--              internal_reg    Insert a register between an integer sequential divider
--                              and a normalization unit
--                              0 - No internal register
--                              1 - Internal register is implemented
--
--              Input ports     Size & Description
--              ===========     ==================
--              a               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Input
--              b               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Input
--              rnd             3 bits
--                              Rounding Mode Input
--              clk             Clock
--              rst_n           Reset. (active low)
--              start           Start operation
--                              A new operation is started by setting start=1
--                              for 1 clock cycle
--              z               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Output
--              status          8 bits
--                              Status Flags Output
--              complete        Operation completed
--
-- Modified : 6/05/07 (0703-SP3)
--            The legal range of num_cyc parameter widened
--
--            1/29/10 (D-2010.03)
--            1. Removed synchronous DFF when rst_mode = 0 (STAR 9000367314)
--            2. Fixed complete signal error at the reset (STAR 9000371212)
--            3. Fixed divide_by_zero flag error          (STAR 9000371212)
--
--	      2/27/12 RJK
--	      Added missing message when input changes during calculation
--	       while using input_mode=0 (STAR 9000523798)
--
--            10/2/17 AFT (M-2016.12-SP5-2)
--            Fixed the behavior of complete output to match with with 
--            synthesis model and Verilog simulation model. (STAR 9001121224)
--            Also fixed the issue with the impact of rnd input on the
--            components output 'z'. (STAR 9001251699)
--
--           2/06/15 RJK
--           Updated input change monitor for input_mode=0 configurations to better
--           inform designers of severity of protocol violations (STAR 9000851903)
--           5/20/14 RJK
--           Extended corruption of output until next start for configurations
--           with input_mode = 0 (STAR 9000741261)
--           9/25/12 RJK
--           Corrected data corruption detection to catch input changes
--            during the first cycle of calculation (related to STAR 9000523798)
-------------------------------------------------------------------------------

library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DW_Foundation.all;
use DWARE.DW_Foundation_comp_arith.all;

architecture sim of DW_fp_div_seq is
	
-- pragma translate_off




  constant zero : integer := 0;

  signal count       : integer;
  signal CYC_CONT    : integer;
  signal output_cont    : integer;
  
  signal temp_z  : std_logic_vector((exp_width + sig_width) downto 0) ;

  signal temp_status : std_logic_vector(7 downto 0) ;

  signal ina         : std_logic_vector((exp_width + sig_width) downto 0);
  signal inb         : std_logic_vector((exp_width + sig_width) downto 0);
  signal ina_div     : std_logic_vector((exp_width + sig_width) downto 0);
  signal inb_div     : std_logic_vector((exp_width + sig_width) downto 0);
  signal a_reg       : std_logic_vector((exp_width + sig_width) downto 0);
  signal b_reg       : std_logic_vector((exp_width + sig_width) downto 0);

  signal a_rst_n      : std_logic;
  signal new_input : std_logic;
  signal new_input_pre : std_logic;
  signal new_input_reg_d1 : std_logic;
  signal new_input_reg_d2 : std_logic;

  signal rnd_reg       : std_logic_vector(2 downto 0);
  signal rnd_div       : std_logic_vector(2 downto 0);

  signal next_complete : std_logic;
  signal int_complete  : std_logic;
  signal int_complete_advanced : std_logic;
  signal int_complete_d1  : std_logic;
  signal int_complete_d2  : std_logic;
  signal int_z  : std_logic_vector((exp_width + sig_width) downto 0) ;
  signal int_z_d1  : std_logic_vector((exp_width + sig_width) downto 0) ;
  signal int_z_d2  : std_logic_vector((exp_width + sig_width) downto 0) ;
  signal int_status : std_logic_vector(7 downto 0) ;
  signal int_status_d1 : std_logic_vector(7 downto 0) ;
  signal int_status_d2 : std_logic_vector(7 downto 0) ;
  signal count_reseted  : std_logic;
  signal start_in: std_logic;

  type state is (state_0, state_1);
  signal start_clk    : std_logic;
  signal rst_n_rst    : std_logic;
  signal reset_st     : std_logic;
  signal reset_st_n_z : std_logic_vector(sig_width + exp_width downto 0);
  signal reset_st_n_status : std_logic_vector(7 downto 0);

  signal cnt_glitch  : integer;
  signal next_count : integer;
  signal next_count_reseted : std_logic;
  signal next_int_status : std_logic_vector(7 downto 0) ;
  signal next_ina    : std_logic_vector((exp_width + sig_width) downto 0);
  signal next_inb    : std_logic_vector((exp_width + sig_width) downto 0);
  signal next_int_complete : std_logic;
  signal next_int_z  : std_logic_vector((exp_width + sig_width) downto 0);
  signal ext_complete : std_logic;
  signal corrupt_data : std_logic;
-- pragma translate_on

begin


-- pragma translate_off
  
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
    
    if ( (sig_width < 3) OR (sig_width > 253) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter sig_width (legal range: 3 to 253)"
        severity warning;
    end if;
    
    if ( (exp_width < 3) OR (exp_width > 31) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter exp_width (legal range: 3 to 31)"
        severity warning;
    end if;
    
    if ( (ieee_compliance < 0) OR (ieee_compliance > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter ieee_compliance (legal range: 0 to 1)"
        severity warning;
    end if;
    
    if ( (num_cyc < 4) OR (num_cyc > 2*sig_width+3) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter num_cyc (legal range: 4 to 2*sig_width+3)"
        severity warning;
    end if;
    
    if ( (rst_mode < 0) OR (rst_mode > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter rst_mode (legal range: 0 to 1)"
        severity warning;
    end if;
    
    if ( (input_mode < 0) OR (input_mode > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter input_mode (legal range: 0 to 1)"
        severity warning;
    end if;
    
    if ( (output_mode < 0) OR (output_mode > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter output_mode (legal range: 0 to 1)"
        severity warning;
    end if;
    
    if ( (early_start < 0) OR (early_start > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter early_start (legal range: 0 to 1)"
        severity warning;
    end if;
    
    if ( (input_mode=0 and early_start=1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid parameter combination: when input_mode=0, early_start=1 is not possible"
        severity warning;
    end if;
  
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;


  corrupt_data <= new_input_reg_d2 when (output_cont = 2) else
                  new_input_reg_d1 when (output_cont = 1) else
                  new_input_pre;
  a_rst_n  <= rst_n WHEN (rst_mode = 0) else '1';
  output_cont <= output_mode + internal_reg;
  
  reset_st_n_z <= (others => not reset_st);
  reset_st_n_status <= (others => not reset_st);
  z <=        (others => '0') when (reset_st = '1') else
              (others => 'X') when (corrupt_data /= '0') else
              int_z_d2 when (output_cont = 2) else
              int_z_d1 when (output_cont = 1) else
              next_int_z;
  status <=   (others => '0') when (reset_st = '1') else
              (others => 'X') when (corrupt_data /= '0') else
              int_status_d2 when (output_cont = 2) else
              int_status_d1    when (output_cont = 1) else
              next_int_status;
  ext_complete <= '0' when (a_rst_n = '0') else
              int_complete_d2 when (output_cont = 2) else
              int_complete_d1 when (output_cont = 1) else
              int_complete_advanced;
  complete <= ext_complete;

  ina_div <= ina when (input_mode = 1) else a;
  inb_div <= inb when (input_mode = 1) else b;
  rnd_div <= rnd_reg when (input_mode = 1) else rnd;
  CYC_CONT <= num_cyc - 3;
 
  -- Instance of DW_fp_div
  U1 : DW_fp_div
      generic map (
              sig_width => sig_width,
              exp_width => exp_width,
              ieee_compliance => ieee_compliance
              )
      port map (
              a => ina_div,
              b => inb_div,
              rnd => rnd_div,
              z => temp_z,
              status => temp_status
              );
   
  process (clk, rst_n) begin
    if (rst_n = '0' and rst_mode = 0) then
      new_input_reg_d1 <= '0';
      new_input_reg_d2 <= '0';
    else  
      if (rising_edge(clk)) then
        if (rst_n = '0') then
          new_input_reg_d1 <= '0';
          new_input_reg_d2 <= '0';
        else
          new_input_reg_d1 <= new_input_pre;
          new_input_reg_d2 <= new_input_reg_d1;
        end if;
      end if;
    end if;
  end process;

  DATA_CORRUP_PROC: process (clk, rst_n, ina_div, inb_div) begin
    if (rst_n = '0' and rst_mode = 0) then
      new_input_pre <= '0';
    elsif (clk'event and clk = '1') then
      if (rst_n = '0') then
        new_input_pre <= '0';
      else 
        if (start_in = '0' and input_mode = 0 and reset_st = '0' and (a_reg /= a or b_reg /= b)) then
          new_input_pre <= '1';
        else
          if (start_in = '1') then
            new_input_pre <= '0';
          end if;
        end if;
      end if; 
    else 
      if ((ina_div'event or inb_div'event) and (start_in = '0') and (input_mode = 0) and (reset_st = '0')) then
        new_input_pre <= '1';
      end if;
    end if;
  end process;

  start_in <= start_clk when (input_mode = 1 and early_start = 0) else start;
     
  process (a, b, start, count_reseted, ina, inb, next_count) begin
    if ((start = '1')) then 
      next_ina           <= a;
      next_inb           <= b;
    elsif (start = '0') then
      if (next_count >= CYC_CONT) then
        next_ina           <= ina;
        next_inb           <= inb;
      elsif (next_count = -1) then
        next_ina           <= (others => 'X');
        next_inb           <= (others => 'X');
      else 
        next_ina           <= ina;
        next_inb           <= inb;
      end if;
    end if;
  end process; 

  process (a, b, start_in, count_reseted, a_rst_n, temp_z, temp_status, ina, inb, new_input, next_count, count, reset_st) begin
    if ((start_in = '1') and (count_reseted = '0')) then 
      next_count_reseted <= '1';
      next_complete      <= '0';
      next_int_complete  <= '0';
      next_int_z         <= (others => 'X');
      next_int_status    <= (others => 'X');
    elsif ((start_in = '0') or (start_in = '1' and count_reseted = '1')) then
      next_count_reseted <= '0';
      if (count >= CYC_CONT) then
        if (not (start_in = '1' or reset_st = '1')) then
          next_int_z      <= temp_z;
          next_int_status <= temp_status;
        else
          next_int_z      <= (others => '0');
          next_int_status <= (others => '0');
        end if;
      end if;
      if (next_count >= CYC_CONT) then
        next_int_complete  <= a_rst_n;
        next_complete      <= '1';
      elsif (next_count = -1) then
        next_int_complete  <= 'X';
        next_int_z         <= (others => 'X');
        next_int_status    <= (others => 'X');
        next_complete      <= 'X';
      else 
        next_int_complete  <= '0';
        next_int_z         <= (others => 'X');
        next_int_status    <= (others => 'X');
      end if;
    end if;
  end process; 

  process (start_in, count_reseted, count) begin
    if (start_in = '1') then
      next_count <= 0;
    elsif (start_in = '0') then
      if (count >= CYC_CONT) then
        next_count <= count;
      elsif (count = -1) then
        next_count <= -1;
      else
        next_count <= count + 1;
      end if;
    end if;
  end process;

  int_complete_advanced <= (int_complete and (not start_in)) when (internal_reg = 1 or input_mode = 1 or output_mode = 1) else int_complete;

  div_seq_PROC: process (clk, rst_n) begin
      if (rst_n = '0' and rst_mode = 0) then
        int_z           <= (others => '0');
        int_status      <= (others => '0');
        int_complete    <= '0';
        count_reseted   <= '0';
        count           <= 0;
        ina             <= (others => '0');
        inb             <= (others => '0');
        int_z_d1        <= (others => '0');
        int_z_d2        <= (others => '0');
        int_status_d1   <= (others => '0');
        int_status_d2   <= (others => '0');
        int_complete_d1 <= '0';
        int_complete_d2 <= '0';
        start_clk       <= '0';
        a_reg           <= (others => '0');
        b_reg           <= (others => '0');
        rnd_reg         <= (others => '0');
      elsif (clk'event and clk = '1') then
          if (rst_n = '0') then
            int_z           <= (others => '0');
            int_status      <= (others => '0');
            int_complete    <= '0';
            count_reseted   <= '0';
            count           <= 0;
            ina             <= (others => '0');
            inb             <= (others => '0');
            int_z_d1        <= (others => '0');
            int_z_d2        <= (others => '0');
            int_status_d1   <= (others => '0');
            int_status_d2   <= (others => '0');
            int_complete_d1 <= '0';
            int_complete_d2 <= '0';
            start_clk       <= '0';
            a_reg           <= (others => '0');
            b_reg           <= (others => '0');
            rnd_reg         <= (others => '0');
          elsif (rst_n = '1') then
            int_z           <= next_int_z;
            int_status      <= next_int_status;
            int_complete    <= next_int_complete;
            count_reseted   <= next_count_reseted;
            count           <= next_count;
            ina             <= next_ina;
            inb             <= next_inb;
            int_z_d1      <= next_int_z;
            int_z_d2        <= int_z_d1;
            int_status_d1 <= next_int_status;
            int_status_d2   <= int_status_d1;
            int_complete_d1 <= int_complete_advanced;
            int_complete_d2 <= int_complete_d1;
            start_clk       <= start;
            a_reg           <= a;
            b_reg           <= b;
            if (start = '1') then
              rnd_reg         <= rnd;
            end if;
          else
            int_z           <= (others => 'X');
            int_status      <= (others => 'X');
            int_complete    <= 'X';
            count_reseted   <= 'X';
            count           <= -1;
            ina             <= (others => 'X');
            inb             <= (others => 'X');
            int_z_d1        <= (others => 'X');
            int_z_d2        <= (others => 'X');
            int_status_d1   <= (others => 'X');
            int_status_d2   <= (others => 'X');
            int_complete_d1 <= 'X';
            int_complete_d2 <= 'X';
            start_clk       <= 'X';
            a_reg           <= (others => 'X');
            b_reg           <= (others => 'X');
            rnd_reg         <= (others => 'X');
          end if;
      end if;
  end process div_seq_PROC;

  RST_SM_PROC: process (clk, rst_n) begin
     if (rst_n = '0' and rst_mode = 0) then
       reset_st <= '1';
     else
       if (rising_edge(clk)) then
         if (rst_n = '0') then
           reset_st <= '1';
         else
           if (start = '1') then
             reset_st <= '0';
           end if;
         end if;
       end if;
     end if;
  end process RST_SM_PROC;

  PROC_corrupt_alert : process ( clk )
    begin
      if (rising_edge(clk)) then

	assert (not (new_input_pre = '1')) report
	   "## Warning: operand input change at this point will cause corrupted results if operation is allowed to complete or has already completed." & lf severity warning;

	assert (not (corrupt_data = '1' and ext_complete = '1')) report ""
	    & lf & " "
	    & lf & "############################################################"
	    & lf & "############################################################"
	    & lf & "##"
	    & lf & "## Error!! :"
	    & lf & "##"
	    & lf & "##      This instance of DW_fp_div_seq has encountered a change"
	    & lf & "##      on operand input(s) after starting the calculation."
	    & lf & "##      The instance is configured with no input register."
	    & lf & "##      So, the result of the operation is corrupted.  This"
	    & lf & "##      message is generated at the point of completion of"
	    & lf & "##      the operation, separate warning(s) were generated"
	    & lf & "##      earlier during calculation (other than corruption"
	    & lf & "##      detected now that occured in the previous cycle)."
	    & lf & "##"
	    & lf & "############################################################"
	    & lf & "############################################################"
	    & lf severity warning;
      end if;
    end process;


 
  P_monitor_clk  : process (clk) begin

    assert NOT (Is_X( clk ) AND (now > 0 ns)) 
      report "WARNING: Detected unknown value on the clock input port clk."
      severity warning;

  end process P_monitor_clk ;

-- pragma translate_on

end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

library dw02;

configuration DW_fp_div_seq_cfg_sim of DW_fp_div_seq is
 for sim
  for U1 : DW_fp_div use configuration dw02.DW_fp_div_cfg_sim; end for;
 end for; -- sim
end DW_fp_div_seq_cfg_sim;
-- pragma translate_on

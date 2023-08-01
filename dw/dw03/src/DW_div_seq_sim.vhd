--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2002 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Aamir Farooqui		February 20, 2002
--
-- VERSION:   VHDL Simulation Model for DW_div_seq
--
-- DesignWare_version: 014130cc
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Sequential Divider
--            - Uses modeling functions from DW_Foundation.
--
-- MODIFIED:
--
--  11/04/15  RJK  Change pkg use from individual DW02 pkg to unified DWARE pkg
--
-- 2/06/15 RJK  Updated input change monitor for input_mode=0 configurations to better
--             inform designers of severity of protocol violations (STAR 9000851903)
-- 5/20/14 RJK  Extended corruption of output until next start for configurations
--             with input_mode = 0 (STAR 9000741261)
-- 9/25/12 RJK  Corrected data corruption detection to catch input changes
--             during the first cycle of calculation (related to STAR 9000506285)
-- 1/9/12  RJK Changed behavior when inputs change during calculation with
--            input_mode = 0 to corrupt output (STAR 9000506285)
-- 3/12/07 JBD fixed divide by zero for sign mode tc_mode ==1
-- 2/19/08 KYUNG fixed the sim model of divide by zero when tc_mode = 0, rst_mode = 1 and input_mode = 1
-- 3/17/08 KYUNG fixed the reset error of the sim model (STAR 9000233070)
-- 5/02/08 KYUNG fixed the divide_by_0 error (STAR 9000241241)
-- 1/08/09 KYUNG fixed the divide_by_0 error (STAR 9000286268)
-- 8/01/17 AFT major change in the code structure to match the flow
--             in the Verilog simulation model. Also, multiple fixes
--             to sequential behavior to make the simulation model
--             match the synthesis model. 
------------------------------------------------------------------------------

library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use DWARE.DW_Foundation_arith.all;

architecture sim of DW_div_seq is
	

-- pragma translate_off

  function cycle_cont(l, m , n : natural) return natural is
   begin
     if  ((l=1) and (m=1) and (n=0))then
       return (3);
     elsif  ((l=0) and (m=0) and (n=0))then
       return (1);
     elsif  ((l=1) and (m=0) and (n=1))then
       return (1);
     else
       return (2);
     end if;
  end cycle_cont;

  constant CYC_CONT : integer := cycle_cont(input_mode, output_mode, early_start);

  signal ext_quotient     : std_logic_vector(a_width-1 downto 0) ;
  signal temp_quotient    : std_logic_vector(a_width-1 downto 0) ;
  signal sign_quotient    : std_logic_vector(a_width-1 downto 0) ;
  signal unsign_quotient  : std_logic_vector(a_width-1 downto 0) ;
  signal ext_remainder    : std_logic_vector(b_width-1 downto 0) ;
  signal temp_remainder   : std_logic_vector(b_width-1 downto 0) ;
  signal sign_remainder   : std_logic_vector(b_width-1 downto 0) ;
  signal unsign_remainder : std_logic_vector(b_width-1 downto 0) ;
  signal b_mux            : std_logic_vector(b_width-1 downto 0) ; 
  signal b_reg            : std_logic_vector(b_width-1 downto 0) ;
  signal in1              : std_logic_vector(a_width-1 downto 0);
  signal in2              : std_logic_vector(b_width-1 downto 0);
  signal in2_c            : std_logic_vector(b_width-1 downto 0);
  signal ext_div_0        : std_logic;
  signal temp_div_0       : std_logic;
  signal temp_div_0_ff    : std_logic;
  signal a_rst_n          : std_logic;
  signal start_n          : std_logic;
  signal start_r          : std_logic;
  signal start_rst        : std_logic;
  signal run_set          : std_logic;
  signal ext_complete     : std_logic;
  signal int_complete     : std_logic;
  signal count            : integer;

  signal pr_state     : std_logic;
  signal nx_state     : std_logic;
  signal rst_n_rst    : std_logic;
  signal rst_n_clk    : std_logic;
  signal reset_st     : std_logic;
  signal next_complete : std_logic;
  
  signal next_quotient    : std_logic_vector(a_width-1 downto 0);
  signal next_remainder   : std_logic_vector(b_width-1 downto 0) ;
  signal next_count       : integer;
  signal nxt_complete     : std_logic;
  signal next_div_0       : std_logic;
  signal next_in1         : std_logic_vector(a_width-1 downto 0);
  signal next_in2         : std_logic_vector(b_width-1 downto 0);

  signal corrupt_data        : std_logic;
-- pragma translate_on

begin

-- pragma translate_off
  
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
    
    if (a_width < 3) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter a_width (lower bound: 3)"
        severity warning;
    end if;
    
    if ( (b_width < 3) OR (b_width > a_width) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter b_width (legal range: 3 to a_width)"
        severity warning;
    end if;
    
    if ( (num_cyc < 3) OR (num_cyc > a_width) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter num_cyc (legal range: 3 to a_width)"
        severity warning;
    end if;
    
    if ( (tc_mode < 0) OR (tc_mode > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter tc_mode (legal range: 0 to 1)"
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

  start_n      <= not start;
  a_rst_n      <= rst_n WHEN (rst_mode = 0) else '1';
  complete     <= ext_complete and (not start_r);
  in2_c        <= in2 when input_mode = 0 
                  else (others => '1') when (int_complete /= '1') 
                  else in2;
  unsign_quotient  <= std_logic_vector(DWF_div (unsigned(in1), unsigned(in2_c)));
  sign_quotient    <= std_logic_vector(DWF_div (signed(in1), signed(in2_c)));
  temp_quotient    <= sign_quotient when (tc_mode = 1) 
                      else unsign_quotient;
  unsign_remainder <= std_logic_vector(DWF_rem (unsigned(in1), unsigned(in2_c)));
  sign_remainder   <= std_logic_vector(DWF_rem (signed(in1), signed(in2_c)));
  temp_remainder   <= sign_remainder when (tc_mode = 1) 
                      else unsign_remainder;
  int_complete <= (not start and run_set) or start_rst;
  start_rst    <= not start and start_r;
  nx_state <= (not rst_n or (not start_r and pr_state)) when (rst_mode = 0) 
              else
              (not rst_n_clk or (not start_r and pr_state));
  reset_st <= nx_state;

  temp_div_0       <= '1' when (unsigned(b_mux) = 0) 
                      else '0';
   
  b_mux <= b_reg when ((input_mode = 1) and (start = '0')) else b;
 
  B_PROC: process ( clk ) begin
      -------------------------------------------------*/
    if (rising_edge(clk) and start = '1') then
      b_reg <= b;
    end if;
  end process B_PROC;

  next_state_PROC : process (start, hold, count, a, b, in1, in2, 
                        temp_quotient, temp_remainder, ext_quotient, 
                        ext_complete, temp_div_0, ext_div_0, 
                        ext_remainder)
    begin

    if(start = '1') then
      next_in1       <= a;
      next_in2       <= b;
      next_count     <= 0;
      nxt_complete   <= '0';
      next_div_0     <= temp_div_0;
      next_quotient  <= (others => 'X'); 
      next_remainder <= (others => 'X'); 

    elsif(start = '0') then
      if (hold = '0') then

        if (count >= (num_cyc+CYC_CONT-4)) then
          next_in1       <= in1;
          next_in2       <= in2;
          next_count     <= count;
          nxt_complete   <= '1';
 
          if (run_set = '1') then
            next_div_0     <= temp_div_0;
            next_quotient  <= temp_quotient;
            next_remainder <= temp_remainder;
          else
            next_div_0     <= '0';
            next_quotient  <= (others => '0');
            next_remainder <= (others => '0');
          end if;

        elsif (count = -1) then
          next_in1       <= (others => 'X');
          next_in2       <= (others => 'X');
          next_count     <= -1;
          nxt_complete   <= 'X';
          next_div_0     <= 'X';
          next_quotient  <= (others => 'X');
          next_remainder <= (others => 'X');

        else
          next_in1       <= in1;
          next_in2       <= in2;
          next_count     <= count+1;
          nxt_complete   <= '0';
          next_div_0     <= temp_div_0;
          next_quotient  <= (others => 'X');
          next_remainder <= (others => 'X'); 
        end if;

      elsif (hold = '1') then
        next_in1        <= in1;
        next_in2        <= in2;
        next_count      <= count;
        nxt_complete    <= ext_complete;
        next_div_0      <= ext_div_0;
        next_quotient   <= ext_quotient;
        next_remainder  <= ext_remainder;

      else
        next_in1        <= (others => 'X');
        next_in2        <= (others => 'X');
        next_count      <= -1;
        nxt_complete    <= 'X';
        next_div_0      <= 'X';
        next_quotient   <= (others => 'X');
        next_remainder  <= (others => 'X');
      end if;

    else
      next_in1      <= (others => 'X');
      next_in2      <= (others => 'X');
      next_count    <= -1;
      nxt_complete  <= 'X';
      next_div_0    <= 'X';
      next_quotient <= (others => 'X');
      next_remainder<= (others => 'X');
    end if;
  end process next_state_PROC;

  div_seq_PROC: process ( clk, a_rst_n )
    begin
    if (a_rst_n = '0') then

      count        <= 0;
      if(input_mode = 1) then
        in1 <= (others => '0');
        in2 <= (others => '0');
      elsif (input_mode = 0) then
        in1 <= a;
        in2 <= b;
      end if;
      ext_complete <= '0';
      ext_div_0    <= '0';
      start_r      <= '0';
      run_set      <= '0';
      pr_state     <= '1';
      ext_quotient <= (others => '0');
      ext_remainder<= (others => '0');
      temp_div_0_ff<= '0';
      rst_n_clk <= '0';
    elsif (a_rst_n = '1') then

      if (clk'event and clk = '1') then

        if (rst_n = '0') then    
          count        <= 0;
	  if(input_mode = 1) then
            in1 <= (others => '0');
            in2 <= (others => '0');
	  elsif (input_mode = 0) then
            in1 <= a;
            in2 <= b;
	  end if;
          ext_complete <= '0';
          ext_div_0    <= '0'; 
          start_r      <= '0';
          run_set      <= '0';
          pr_state     <= '1';
          ext_quotient <= (others => '0');
          ext_remainder<= (others => '0');
          temp_div_0_ff   <= '0';
          rst_n_clk <= '0';
        elsif (rst_n = '1') then
          count        <= next_count;
          in1          <= next_in1;
          in2          <= next_in2;
          ext_complete <= nxt_complete and start_n;
          ext_div_0    <= next_div_0;
          ext_quotient <= next_quotient;
          ext_remainder<= next_remainder;
          start_r      <= start;
          pr_state     <= nx_state;
          run_set      <= '1';
          if (start = '1') then
            temp_div_0_ff<= temp_div_0;
          end if;
          rst_n_clk    <= rst_n;
        else
          count        <= -1;
          in1          <= (others => 'X');
          in2          <= (others => 'X');
          ext_complete <= 'X';
          ext_div_0    <= 'X';
          ext_quotient <= (others => 'X');
          ext_remainder<= (others => 'X');
          temp_div_0_ff<= 'X'; 
          rst_n_clk    <= 'X';
        end if;
      end if;

    else
      count        <= -1;
      in1          <= (others => 'X');
      in2          <= (others => 'X');
      ext_complete <= 'X';
      ext_div_0    <= 'X';
      ext_quotient <= (others => 'X');
      ext_remainder<= (others => 'X');
      temp_div_0_ff<= 'X';
      rst_n_clk    <= 'X';
    end if;
    next_complete <= nxt_complete;

  end process div_seq_PROC;


  rst_n_rst <= rst_n_clk when (rst_mode = 1) 
               else rst_n;

  quotient     <= (others => '0') when (reset_st = '1') else
                  (others => 'X') when ((((input_mode = 0) and (output_mode = 0)) or (early_start = 1)) and start = '1') else
                  ext_quotient when (corrupt_data = '0') else (others => 'X');
  remainder    <= (others => '0') when (reset_st = '1') else
                  (others => 'X') when ((((input_mode = 0) and (output_mode = 0)) or (early_start = 1)) and start = '1') else
                  ext_remainder when (corrupt_data = '0') else (others => 'X');
  divide_by_0  <= '0' when (reset_st = '1') else
                  ext_div_0 when (input_mode = 1 and output_mode = 0 and early_start = 0) else
                  temp_div_0_ff when (output_mode = 1 and early_start = 0) else
                  temp_div_0_ff;


GEN_IM0 : if (input_mode = 0) generate
IM0_BLK: block
 signal ina_hist    : std_logic_vector(a_width-1 downto 0);
 signal inb_hist    : std_logic_vector(b_width-1 downto 0);
 signal corrupt_data_int : std_logic;
 signal next_corrupt_data : std_logic;
 signal data_input_activity : std_logic;
 signal init_complete : std_logic;
 signal next_alert1 : std_logic;
 signal change_count : INTEGER;

begin

  next_alert1 <= next_corrupt_data AND rst_n AND init_complete AND (NOT start) AND (NOT ext_complete);

 GEN_IM0_RM_EQ_0: if (rst_mode = 0) generate
   PROCC_hist_regs_rm0 : process ( clk, rst_n ) begin
     if (rst_n = '0') then
       ina_hist        <= a;
       inb_hist        <= b;
       change_count     <=  0 ;
       init_complete    <= '0';
       corrupt_data_int <= '0';
     elsif ( rst_n = '1') then
       if (rising_edge(clk)) then
	  if ((hold /= '1') OR (start = '1')) then
	    ina_hist        <= a;
	    inb_hist        <= b;
	    if (start = '1') then
	      change_count  <= 0;
	    elsif (next_alert1 = '1') then
	      change_count  <= change_count + 1;
	    end if;
	  end if;

	   init_complete    <= init_complete OR start;
	   corrupt_data_int <= next_corrupt_data OR (corrupt_data_int AND (NOT start));

       end if;
     else
       ina_hist        <= (others => 'X');
       inb_hist        <= (others => 'X');
       change_count     <= -1 ;
       init_complete    <= 'X';
       corrupt_data_int <= 'X';
     end if;
   end process;
  end generate GEN_IM0_RM_EQ_0;

 GEN_IM0_RM_NE_0 : if (rst_mode /= 0) generate
   PROCC_hist_regs_rm1 : process ( clk ) begin
     if (rising_edge(clk)) then
       if (rst_n = '0') then
	 ina_hist        <= a;
	 inb_hist        <= b;
	 change_count     <=  0 ;
	 init_complete    <= '0';
	 corrupt_data_int <= '0';
       elsif ( rst_n = '1') then
	  if ((hold /= '1') OR (start = '1')) then
	    ina_hist        <= a;
	    inb_hist        <= b;
	    if (start = '1') then
	      change_count  <= 0;
	    elsif (next_alert1 = '1') then
	      change_count  <= change_count + 1;
	    end if;
	  end if;

	   init_complete    <= init_complete OR start;
	   corrupt_data_int <= next_corrupt_data OR (corrupt_data AND (NOT start));

       else
         ina_hist        <= (others => 'X');
         inb_hist        <= (others => 'X');
         change_count     <= -1 ;
         init_complete    <= 'X';
         corrupt_data_int <= 'X';
       end if;
     end if;
   end process;
  end generate GEN_IM0_RM_NE_0;


  data_input_activity <= rst_n WHEN ((a /= ina_hist) OR
				 (b /= inb_hist)) ELSE '0';

  next_corrupt_data <= '0' WHEN ((input_mode /= 0) OR
                                 ((output_mode /= 0) AND (ext_complete = '1'))) ELSE
			    (data_input_activity AND (NOT start) AND
			    (NOT hold) AND init_complete);

 PROC_corrupt_alert : process ( clk )
   variable updated_count : integer;
   begin
      if (rising_edge(clk)) then

	updated_count := change_count;

	if (next_alert1 = '1') then
	  assert (rst_n /= '1') report
	   "## Warning: operand input change at this point will cause corrupted results if operation is allowed to complete." & lf severity warning;
	  updated_count := updated_count + 1;
	end if;

	if ((rst_n AND init_complete AND (NOT start) AND (NOT ext_complete) AND next_complete)
	            = '1') then
	  assert (updated_count < 1) report ""
	    & lf & " "
	    & lf & "############################################################"
	    & lf & "############################################################"
	    & lf & "##"
	    & lf & "## Error!! :"
	    & lf & "##"
	    & lf & "##      This instance of DW_div_seq has encountered a change"
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
      end if;
  end process;

  corrupt_data <= corrupt_data_int;

  GEN_OM_EQ_0: if (output_mode = 0) generate
   OM0_BLK: block
    signal alert2_issued : std_logic;
    signal next_alert2   : std_logic;
   begin

    next_alert2 <= next_corrupt_data AND rst_n AND init_complete AND
				     (NOT start) AND ext_complete AND (NOT alert2_issued);

    PROC_corrupt_alert2: process(clk) begin

      if (rising_edge(clk)) then

	assert (next_alert2 = '0') report
	 "## Warning: operand input change causes output to no longer retain result of previous operation." & lf severity warning;
	 
      end if;
    end process PROC_corrupt_alert2;

    GEN_AI_REG_AR: if (rst_mode = 0) generate
      PROC_AI_REG_AR: process(clk, rst_n) begin
        if (rst_n = '0') then
	  alert2_issued <= '0';
	else
	  if rising_edge(clk) then
	    alert2_issued <= (NOT start) AND (alert2_issued OR next_alert2);
	  end if;
	end if;
      end process PROC_AI_REG_AR;
    end generate GEN_AI_REG_AR;

    GEN_AI_REG_SR: if (rst_mode /= 0) generate
      PROC_AI_REG_SR: process(clk) begin
	if rising_edge(clk) then
	  if (rst_n = '0') then
	    alert2_issued <= '0';
	  else
	    alert2_issued <= (NOT start) AND (alert2_issued OR next_alert2);
	  end if;
	end if;
      end process PROC_AI_REG_SR;
    end generate GEN_AI_REG_SR;

   end block OM0_BLK;
  end generate GEN_OM_EQ_0;

end block IM0_BLK;
end generate GEN_IM0;


GEN_IM1 : if (input_mode /= 0) generate
  corrupt_data <= '0';
end generate GEN_IM1;


 
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

configuration DW_div_seq_cfg_sim of DW_div_seq is
 for sim
 end for; -- sim
end DW_div_seq_cfg_sim;
-- pragma translate_on

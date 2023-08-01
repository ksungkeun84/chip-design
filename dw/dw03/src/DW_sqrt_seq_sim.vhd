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
-- AUTHOR:    Aamir Farooqui		February 13, 2002
--
-- VERSION:   VHDL Simulation Model for DW_sqrt_seq
--
-- DesignWare_version: c3dff542
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Sequential Square Root 
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
--             during the first cycle of calculation (related to STAR 9000506330)
--
------------------------------------------------------------------------------

library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use DWARE.DW_Foundation_arith.all;


architecture sim of DW_sqrt_seq is
	

-- pragma translate_off

-- Function
-- find the actual number of cycles required based on
-- input_mode, output_mode and early_start
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


-------------------CONSTANTS-----------------------
   constant CYC_CONT : integer := cycle_cont(input_mode, output_mode, early_start);


  signal ext_root      : std_logic_vector(((width+1)/2)-1 downto 0) ;
  signal next_root     : std_logic_vector(((width+1)/2)-1 downto 0) ;
  signal temp_root     : std_logic_vector(((width+1)/2)-1 downto 0) ;
  signal in1           : std_logic_vector(width-1 downto 0);
  signal next_in1      : std_logic_vector(width-1 downto 0);
 
  signal a_rst_n      : std_logic;
  signal start_n      : std_logic;
  signal ext_complete : std_logic;
  signal next_complete: std_logic;
 
  signal count       : integer;
  signal next_count  : integer;

  signal corrupt_data        : std_logic;

-- pragma translate_on

begin

-- pragma translate_off

  
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
    
    if (width < 6) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter width (lower bound: 6)"
        severity warning;
    end if;
    
    if ( (num_cyc < 3) OR (num_cyc > (width+1)/2) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter num_cyc (legal range: 3 to (width+1)/2)"
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
------------------------------------------------------------------------------
  
  start_n  <= not start; 
  a_rst_n  <= rst_n WHEN (rst_mode = 0) else '1';
  complete <= ext_complete and (not start);
  root     <= (others => 'X') when ((((input_mode = 0) and (output_mode = 0)) or (early_start = 1)) and start = '1') else
              (others => 'X') when (corrupt_data /= '0') else ext_root;
  temp_root<= std_logic_vector(DWF_sqrt (signed(in1))) when (tc_mode = 1) else std_logic_vector(DWF_sqrt (unsigned(in1))); 



  sqrt_seq_PROC: process ( clk, a_rst_n  )
  begin


-- First cycle computation
    if(start = '1') then
      next_count   <= 0;
      next_in1     <= a;
      next_root    <= (others => 'X');

-- Rest of the computation
    elsif(start = '0') then
      if (hold = '0') then
        if (count >= (num_cyc+CYC_CONT-4)) then
          next_in1      <= in1;
          next_count    <= count;
          next_complete <= '1';
          next_root     <= temp_root;
        elsif (count = -1) then
          next_in1      <= (others => 'X');
          next_count    <= -1;
          next_complete <= 'X';
          next_root  <= (others => 'X');
        else
          next_in1      <= in1;
          next_count    <= count+1;
          next_complete <= '0'; 
          next_root     <= (others => 'X');
        end if;
-- Hold the computation
      elsif (hold = '1') then
        next_in1        <= in1;
        next_count      <= count;
        next_complete   <= ext_complete;
        next_root       <= ext_root;
      else
        next_in1        <= (others => 'X');
        next_count      <= -1;
        next_complete   <= 'X';
        next_root       <= (others => 'X');
      end if;
    else
      next_in1      <= (others => 'X');
      next_count    <= -1;
      next_complete <= 'X';
      next_root     <= (others => 'X');
    end if;



 
    if (a_rst_n = '0') then
-- initialize everything
      count        <= 0;
      in1          <= (others => '0');
      ext_root     <= (others => '0');
      ext_complete <= '0';
    elsif (a_rst_n = '1') then
      if (clk'event and clk = '1') then
        if (rst_n = '0') then    
          count        <= 0;
          in1          <= (others => '0');
          ext_root     <= (others => '0');
          ext_complete <= '0';

-- Normal operation
        elsif (rst_n = '1') then
          count        <= next_count;
          in1          <= next_in1;
          ext_root     <= next_root;
          ext_complete <= next_complete and start_n;
        else
          count        <= -1;
          in1          <= (others => 'X');
          ext_root     <= (others => 'X');
          ext_complete <= 'X';
        end if;
      end if;
    else
      count        <= -1;
      in1          <= (others => 'X');
      ext_root     <= (others => 'X');
      ext_complete <= 'X';
    end if;
  end process sqrt_seq_PROC;


GEN_IM0 : if (input_mode = 0) generate
IM0_BLK: block
 signal ina_hist    : std_logic_vector(width-1 downto 0);
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
       change_count     <=  0 ;
       init_complete    <= '0';
       corrupt_data_int <= '0';
     elsif ( rst_n = '1') then
       if (rising_edge(clk)) then
	  if ((hold /= '1') OR (start = '1')) then
	    ina_hist        <= a;
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
	 change_count     <=  0 ;
	 init_complete    <= '0';
	 corrupt_data_int <= '0';
       elsif ( rst_n = '1') then
	  if ((hold /= '1') OR (start = '1')) then
	    ina_hist        <= a;
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
         change_count     <= -1 ;
         init_complete    <= 'X';
         corrupt_data_int <= 'X';
       end if;
     end if;
   end process;
  end generate GEN_IM0_RM_NE_0;


  data_input_activity <= rst_n WHEN (a /= ina_hist) ELSE '0';

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
	    & lf & "##      This instance of DW_sqrt_seq has encountered a change"
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

configuration DW_sqrt_seq_cfg_sim of DW_sqrt_seq is
 for sim
 end for; -- sim
end DW_sqrt_seq_cfg_sim;
-- pragma translate_on

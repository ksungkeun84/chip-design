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
-- AUTHOR:    Doug Lee    Feb 23, 2006
--
-- VERSION:   VHDL Simulation Model
--
-- DesignWare_version: 9372d2d0
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
--
-- ABSTRACT: Pipelined Multiply and Accumulate Simulation Model
--
--           This receives to operands that get multiplied and
--           accumulated.  The operation is configurable to be
--           pipelined.  Also, includes pipeline management.
--
--
--              Parameters      Valid Values   Description
--              ==========      ============   ===========
--              a_width           1 to 1024    default: 8
--                                             Width of 'a' input
--
--              b_width           1 to 1024    default: 8
--                                             Width of 'a' input
--
--              acc_width         2 to 2048    default: 16
--                                             Width of 'a' input
--                                               Must be >= (a_width + b_width)
--
--              tc                  0 or 1     default: 0
--                                             Twos complement control
--                                               0 => unsigned
--                                               1 => signed
--
--              pipe_reg            0 to 7     default: 0
--                                             Pipeline register stages
--                                               0 => no pipeline register stages inserted
--                                               1 => pipeline stage0 inserted
--                                               2 => pipeline stage1 inserted
--                                               3 => pipeline stages 0 and 1 inserted
--                                               4 => pipeline stage2 pipeline inserted
--                                               5 => pipeline stages 0 and 2 pipeline inserted
--                                               6 => pipeline stages 1 and 2 inserted
--                                               7 => pipeline stages 0, 1, and 2 inserted
--
--              id_width          1 to 1024    default: 1
--                                             Width of 'launch_id' and 'arrive_id' ports
--
--              no_pm               0 or 1     default: 0
--                                             Pipeline management included control
--                                               0 => DW_pipe_mgr connected to pipeline
--                                               1 => DW_pipe_mgr bypassed
--
--              op_iso_mode         0 to 4     default: 0
--                                             Type of operand isolation
--                                               0 => Follow intent defined by Power Compiler user setting
--                                               1 => no operand isolation
--                                               2 => 'and' gate operand isolaton
--                                               3 => 'or' gate operand isolation
--                                               4 => preferred isolation style: 'and' gate
--
--
--              Input Ports:    Size           Description
--              ===========     ====           ===========
--              clk             1 bit          Input Clock
--              rst_n           1 bit          Active Low Async. Reset
--              init_n          1 bit          Active Low Sync. Reset
--              clr_acc_n       1 bit          Actvie Low Clear accumulate results
--              a               a_width bits   Multiplier
--              b               b_width bits   Multiplicand
--              launch          1 bit          Start a multiply and accumulate with a and b
--              launch_id       id_width bits  Identifier associated with 'launch' assertion
--              accept_n        1 bit          Downstream logic ready to use 'acc' result (active low)
--
--              Output Ports    Size           Description
--              ============    ====           ===========
--              acc             acc_width bits Multiply and accumulate result
--              arrive          1 bit          Valid multiply and accumulate result
--              arrive_id       id_width bits  launch_id from originating launch that produced acc result
--              pipe_full       1 bit          Upstream notification that pipeline is full
--              pipe_ovf        1 bit          Status Flag indicating pipe overflow
--              push_out_n      1 bit          Active Low Output used with FIFO (optional)
--              pipe_census     3 bits         Output bus indicating the number of pipe stages currently occupied
--
--
-- MODIFIED:
--           02/06/08  DLL Enhanced abstract and added 'op_iso_mode' parameter.
--
--           11/21/06  DLL Change library reference in configuration block
--
--------------------------------------------------------------------------
 
library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_misc.all;
use DWARE.DWpackages.all;
use DWARE.DW_foundation_comp_arith.all;

architecture sim of DW_piped_mac is
	

  function calc_stages( pipe_reg : in INTEGER ) return INTEGER is
    begin
        if(pipe_reg = 0) then
          return (1);
        elsif (pipe_reg = 7) then
          return (4);
        elsif ((pipe_reg = 1) OR (pipe_reg = 2) OR (pipe_reg = 4)) then
          return(2);
        else
          return(3);
        end if;
  end calc_stages;

  constant stages               : INTEGER := calc_stages( pipe_reg );
  constant pipe_reg_vec         : std_logic_vector(2 downto 0)  := CONV_STD_LOGIC_VECTOR(pipe_reg, 3);
  constant tc_vec               : std_logic_vector(31 downto 0) := CONV_STD_LOGIC_VECTOR(tc, 32);

  signal pipe_en_bus            : std_logic_vector(stages-1 downto 0);
  signal pipe_en_bus_pm         : std_logic_vector(stages-1 downto 0);

  signal launch_pm              : std_logic;
  signal launch_id_pm           : std_logic_vector(id_width-1 downto 0);
  signal pipe_full_pm           : std_logic;
  signal pipe_ovf_pm            : std_logic;

  signal accept_n_pm            : std_logic;
  signal arrive_pm              : std_logic;
  signal arrive_id_pm           : std_logic_vector(id_width-1 downto 0);
  signal push_out_n_pm          : std_logic;

  signal pipe_census_pm         : std_logic_vector(2 downto 0);
  signal pipe_census_int        : std_logic_vector(2 downto 0);

  signal en0                    : std_logic;
  signal en1                    : std_logic;
  signal en2                    : std_logic;
  signal en_acc                 : std_logic;

  signal a_reg_s0               : std_logic_vector(a_width-1 downto 0);
  signal next_a_reg_s0          : std_logic_vector(a_width-1 downto 0);
  signal a_s0_selected          : std_logic_vector(a_width-1 downto 0);
  signal a_reg_s1               : std_logic_vector(a_width-1 downto 0);
  signal next_a_reg_s1          : std_logic_vector(a_width-1 downto 0);
  signal a_s1_selected          : std_logic_vector(a_width-1 downto 0);

  signal b_reg_s0               : std_logic_vector(b_width-1 downto 0);
  signal next_b_reg_s0          : std_logic_vector(b_width-1 downto 0);
  signal b_s0_selected          : std_logic_vector(b_width-1 downto 0);
  signal b_reg_s1               : std_logic_vector(b_width-1 downto 0);
  signal next_b_reg_s1          : std_logic_vector(b_width-1 downto 0);
  signal b_s1_selected          : std_logic_vector(b_width-1 downto 0);

  signal clr_acc_n_reg_s0       : std_logic;
  signal next_clr_acc_n_reg_s0  : std_logic;
  signal clr_acc_n_s0_selected  : std_logic;
  signal clr_acc_n_reg_s1       : std_logic;
  signal next_clr_acc_n_reg_s1  : std_logic;
  signal clr_acc_n_s1_selected  : std_logic;

  signal sum                    : std_logic_vector(acc_width-1 downto 0);
  signal acc_reg_gated          : std_logic_vector(acc_width-1 downto 0);

  signal acc_reg                : std_logic_vector(acc_width-1 downto 0);
  signal next_acc_reg           : std_logic_vector(acc_width-1 downto 0);
  signal acc_reg_s2             : std_logic_vector(acc_width-1 downto 0);
  signal next_acc_reg_s2        : std_logic_vector(acc_width-1 downto 0);

  signal tc_vec_bit0            : std_logic;

  type FifoArrayType is array (0 to stages-1) of
         std_logic_vector(id_width-1 downto 0);

  signal idsr_mem         : FifoArrayType;

  signal dtsr             : std_logic_vector(stages-1 downto 0);
  signal next_dtsr        : std_logic_vector(stages-1 downto 0);

  signal sel_en           : std_logic_vector(stages-1 downto 0);
  signal pipe_en_bus_int  : std_logic_vector(stages-1 downto 0);
  signal pipe_full_int    : std_logic;
  signal pipe_ovf_int     : std_logic;
  signal accept           : std_logic;

  begin
  -- pragma translate_off
    
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
     
    if (a_width < 1) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter a_width (lower bound: 1)"
        severity warning;
    end if;
     
    if (b_width < 1) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter b_width (lower bound: 1)"
        severity warning;
    end if;
     
    if (acc_width < 2) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter acc_width (lower bound: 2)"
        severity warning;
    end if;
     
    if ( (tc < 0) OR (tc > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter tc (legal range: 0 to 1)"
        severity warning;
    end if;
     
    if ( (pipe_reg < 0) OR (pipe_reg > 7) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter pipe_reg (legal range: 0 to 7)"
        severity warning;
    end if;
     
    if ( (id_width < 1) OR (id_width > 1024) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter id_width (legal range: 1 to 1024)"
        severity warning;
    end if;
     
    if ( (no_pm < 0) OR (no_pm > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter no_pm (legal range: 0 to 1)"
        severity warning;
    end if;
     
    if ( (op_iso_mode < 0) OR (op_iso_mode > 4) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter op_iso_mode (legal range: 0 to 4)"
        severity warning;
    end if;
    
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;

    accept <= NOT(accept_n_pm); 

    sel_PROC: process (sel_en, dtsr, accept)
      variable i  : INTEGER;
      begin
	for i in stages-1 downto 0 loop
          if (i = stages-1) then
            sel_en(i) <= accept OR NOT(dtsr(i));
          else
            sel_en(i) <= sel_en(i+1) OR NOT(dtsr(i));
          end if; 
	end loop;
    end process;  -- sel_PROC


    dtsr_PROC: process (sel_en, dtsr, launch_pm)
      variable i  : INTEGER;
      begin
        for i in 0 to stages-1 loop
          if(i = 0) then
            if (sel_en(0) = '1') then
              next_dtsr(0) <= launch_pm;
            else
              next_dtsr(0) <= dtsr(0);
            end if;
          else
            if (sel_en(i) = '1') then
              next_dtsr(i) <= dtsr(i-1);
            else
              next_dtsr(i) <= dtsr(i);
            end if;
          end if;
        end loop;
    end process; -- dtsr_PROC

    pipe_en_PROC: process (sel_en, next_dtsr)
      variable i  : INTEGER;
      begin
        for i in 0 to stages-1 loop
          pipe_en_bus_int(i) <= sel_en(i) AND next_dtsr(i);
        end loop;
    end process;  -- pipe_en_PROC

    census_PROC: process (dtsr)
      variable cnt : INTEGER;
      variable i   : INTEGER;
      begin
	cnt := 0;
        for i in 0 to stages-1 loop
	  if (dtsr(i) = '1') then
            cnt := cnt + 1;
	  end if;
        end loop;
        
        pipe_census_pm <= CONV_STD_LOGIC_VECTOR(cnt, 3);
    end process;  -- census_PROC


    sim_clk_1: process (clk, rst_n)
      variable i  : INTEGER;
      begin

        if (rst_n = '0') then
          dtsr     <= (others => '0');
          pipe_ovf_int <= '0';
	  for i in 0 to (stages-1) loop
            idsr_mem(i) <= (others => '0');
	  end loop;
        elsif (rst_n = '1') then
	  if (rising_edge(clk)) then
	    if (init_n = '0') then
              dtsr     <= (others => '0');
              pipe_ovf_int <= '0';
	      for i in 0 to (stages-1) loop
                idsr_mem(i) <= (others => '0');
	      end loop;
	    elsif (init_n = '1') then
              dtsr     <= next_dtsr;
              pipe_ovf_int <= NOT(sel_en(0)) AND launch_pm;
	      for i in 0 to (stages-1) loop
                if (i = 0) then
                  if ((sel_en(0) = '1') AND (launch_pm = '1')) then
                    idsr_mem(0) <= launch_id_pm;
                  end if;
                else
                  if ((sel_en(i) = '1') AND (next_dtsr(i) = '1')) then
                    idsr_mem(i) <= idsr_mem(i-1);
                  end if;
                end if;
	      end loop;
            else
              dtsr     <= (others => 'X');
              pipe_ovf_int <= 'X';
	      for i in 0 to (stages-1) loop
                idsr_mem(i) <= (others => 'X');
	      end loop;
	    end if;
          else
            dtsr     <= dtsr;
            pipe_ovf_int <= pipe_ovf_int;
	    for i in 0 to (stages-1) loop
              idsr_mem(i) <= idsr_mem(i);
	    end loop;
	  end if;
	else
          dtsr     <= (others => 'X');
          pipe_ovf_int <= 'X';
	  for i in 0 to (stages-1) loop
            idsr_mem(i) <= (others => 'X');
	  end loop;
	end if;

    end process;

    pipe_en_bus_pm   <= pipe_en_bus_int;
    pipe_ovf_pm      <= pipe_ovf_int;
    pipe_full_pm     <= AND_REDUCE(dtsr) AND NOT(accept);
    arrive_pm        <= dtsr(stages-1);
    arrive_id_pm     <= idsr_mem(stages-1);
    push_out_n_pm    <= NOT(accept AND dtsr(stages-1));


-- Stitch around pipe manager inputs/outputs if parameter "no_pm" is 1
    launch_pm       <= '1' when no_pm = 1 else launch;
    launch_id_pm    <= (others => '0') when no_pm = 1 else launch_id;
    pipe_full       <= '0' when no_pm = 1 else pipe_full_pm;
    pipe_ovf        <= '0' when no_pm = 1 else pipe_ovf_pm;
    pipe_en_bus     <= (others => '1') when  no_pm = 1 else pipe_en_bus_pm;

    accept_n_pm     <= '0' when  no_pm = 1 else accept_n;
    arrive          <= '1' when  no_pm = 1 else arrive_pm;
    arrive_id       <= (others => '0') when  no_pm = 1 else arrive_id_pm;
    push_out_n      <= '0' when  no_pm = 1 else push_out_n_pm;
    pipe_census_int <= (others => '0') when  no_pm = 1 else pipe_census_pm;


    en_PROC: process (pipe_en_bus)
      variable   i : INTEGER;
      begin
        case pipe_reg is
          when 0 => en_acc <= pipe_en_bus(0);
          when 1 => for i in 0 to stages-1 loop
                      if (i = 0) then
                        en0 <= pipe_en_bus(i);
                      else
                        en_acc <= pipe_en_bus(i);
                      end if;
                    end loop;
          when 2 => for i in 0 to stages-1 loop
                      if (i = 0) then
                        en1 <= pipe_en_bus(i);
                      else
                        en_acc <= pipe_en_bus(i);
                      end if;
                    end loop;
          when 3 => for i in 0 to stages-1 loop
                      if (i = 0) then
                        en0 <= pipe_en_bus(i);
                      elsif (i = 1) then
                        en1 <= pipe_en_bus(i);
                      else
                        en_acc <= pipe_en_bus(i);
                      end if;
                    end loop;
          when 4 => for i in 0 to stages-1 loop
                      if (i = 0) then
                        en_acc <= pipe_en_bus(i);
                      else
                        en2 <= pipe_en_bus(i);
                      end if;
                    end loop;
          when 5 => for i in 0 to stages-1 loop
                      if (i = 0) then
                        en0 <= pipe_en_bus(i);
                      elsif (i = 1) then
                        en_acc <= pipe_en_bus(i);
                      else
                        en2 <= pipe_en_bus(i);
                      end if;
                    end loop;
          when 6 => for i in 0 to stages-1 loop
                      if (i = 0) then
                        en1 <= pipe_en_bus(i);
                      elsif (i = 1) then
                        en_acc <= pipe_en_bus(i);
                      else
                        en2 <= pipe_en_bus(i);
                      end if;
                    end loop;
          when others => for i in 0 to stages-1 loop
                      if (i = 0) then
                        en0 <= pipe_en_bus(i);
                      elsif (i = 1) then
                        en1 <= pipe_en_bus(i);
                      elsif (i = 2) then
                        en_acc <= pipe_en_bus(i);
                      else
                        en2 <= pipe_en_bus(i);
                      end if;
                    end loop;
        end case; 
    end process;  -- en_PROC

    next_a_reg_s0 <= a when en0 = '1' else a_reg_s0;
    next_b_reg_s0 <= b when en0 = '1' else b_reg_s0;
    a_s0_selected <= a when pipe_reg_vec(0) = '0' else a_reg_s0;
    b_s0_selected <= b when pipe_reg_vec(0) = '0' else b_reg_s0;

    next_clr_acc_n_reg_s0 <= clr_acc_n when en0 = '1' else clr_acc_n_reg_s0;
    clr_acc_n_s0_selected <= clr_acc_n when pipe_reg_vec(0) = '0' else clr_acc_n_reg_s0;

    next_a_reg_s1 <= a_s0_selected when en1 = '1' else a_reg_s1;
    next_b_reg_s1 <= b_s0_selected when en1 = '1' else b_reg_s1;
    a_s1_selected <= a_s0_selected when pipe_reg_vec(1) = '0' else a_reg_s1;
    b_s1_selected <= b_s0_selected when pipe_reg_vec(1) = '0' else b_reg_s1;

    next_clr_acc_n_reg_s1 <= clr_acc_n_s0_selected when en1 = '1' else clr_acc_n_reg_s1;
    clr_acc_n_s1_selected <= clr_acc_n_s0_selected when pipe_reg_vec(1) = '0' else clr_acc_n_reg_s1;

    acc_gate_PROC: process (acc_reg, clr_acc_n_s1_selected)
      variable   i:  INTEGER;
      begin
        for i in 0 to acc_width-1 loop
          acc_reg_gated(i) <= clr_acc_n_s1_selected AND acc_reg(i);
        end loop;
    end process acc_gate_PROC;

    tc_vec_bit0 <= tc_vec(0);
  process (a_s1_selected,b_s1_selected,acc_reg_gated,tc_vec_bit0)
    variable SUM_tc, PROD_tc: SIGNED(acc_width-1 downto 0);    
    variable SUM_un, PROD_un: UNSIGNED(acc_width-1 downto 0);   
    variable PROD1_tc: SIGNED(a_width+b_width-1 downto 0);    
    variable PROD1_un: UNSIGNED(a_width+b_width-1 downto 0);       
    variable A_tc: SIGNED(a_width-1 downto 0);
    variable B_tc: SIGNED(b_width-1 downto 0);    
    variable A_un: UNSIGNED(a_width-1 downto 0);
    variable B_un: UNSIGNED(b_width-1 downto 0);        
  begin 
    if (Is_X(a_s1_selected) or Is_X(b_s1_selected) or Is_X(acc_reg_gated) or Is_X(tc_vec_bit0)) then 
      sum <= (others => 'X');
    elsif tc_vec_bit0 = '0' then
      A_un := UNSIGNED(a_s1_selected);
      B_un := UNSIGNED(b_s1_selected);      
      PROD1_un := A_un * B_un;
      if acc_width < a_width+b_width then
        PROD_un := PROD1_un(acc_width-1 downto 0);
      else
        PROD_un := (others => '0'); 
        PROD_un(a_width+b_width-1 downto 0) := PROD1_un;      
      end if;
      SUM_un := PROD_un + UNSIGNED(acc_reg_gated);            
      sum <= std_logic_vector(SUM_un);
    else
      A_tc := SIGNED(a_s1_selected);
      B_tc := SIGNED(b_s1_selected);          
      PROD1_tc := A_tc * B_tc;
      if acc_width >= a_width+b_width then
        PROD_tc(a_width+b_width-1 downto 0) := PROD1_tc;
        if (acc_width > a_width+b_width) then
          for i in acc_width-1 downto a_width+b_width loop
            PROD_tc(i) := PROD_tc(a_width+b_width-1);
          end loop;
        end if;
      else
        PROD_tc := PROD1_tc(acc_width-1 downto 0);      
      end if;
      
      SUM_tc := PROD_tc + SIGNED(acc_reg_gated);
      sum <= std_logic_vector(SUM_tc);
    end if;
  end process;

    next_acc_reg    <= sum when en_acc = '1' else acc_reg;
    next_acc_reg_s2 <= acc_reg when en2 = '1' else acc_reg_s2;

    sim_clk_2: process (clk, rst_n)

      begin

        if (rst_n = '0') then
          a_reg_s0          <= (others => '0');
          a_reg_s1          <= (others => '0');
          b_reg_s0          <= (others => '0');
          b_reg_s1          <= (others => '0');
          clr_acc_n_reg_s0  <= '0';
          clr_acc_n_reg_s1  <= '0';
          acc_reg           <= (others => '0');
          acc_reg_s2        <= (others => '0');
        elsif (rst_n = '1') then
	  if (rising_edge(clk)) then
	    if (init_n = '0') then
              a_reg_s0          <= (others => '0');
              a_reg_s1          <= (others => '0');
              b_reg_s0          <= (others => '0');
              b_reg_s1          <= (others => '0');
              clr_acc_n_reg_s0  <= '0';
              clr_acc_n_reg_s1  <= '0';
              acc_reg           <= (others => '0');
              acc_reg_s2        <= (others => '0');
	    elsif (init_n = '1') then
              a_reg_s0          <= next_a_reg_s0;
              a_reg_s1          <= next_a_reg_s1;
              b_reg_s0          <= next_b_reg_s0;
              b_reg_s1          <= next_b_reg_s1;
              clr_acc_n_reg_s0  <= next_clr_acc_n_reg_s0;
              clr_acc_n_reg_s1  <= next_clr_acc_n_reg_s1;
              acc_reg           <= next_acc_reg;
              acc_reg_s2        <= next_acc_reg_s2;
            else
              a_reg_s0          <= (others => 'X');
              a_reg_s1          <= (others => 'X');
              b_reg_s0          <= (others => 'X');
              b_reg_s1          <= (others => 'X');
              clr_acc_n_reg_s0  <= 'X';
              clr_acc_n_reg_s1  <= 'X';
              acc_reg           <= (others => 'X');
              acc_reg_s2        <= (others => 'X');
	    end if;
          else
            a_reg_s0          <= a_reg_s0;
            a_reg_s1          <= a_reg_s1;
            b_reg_s0          <= b_reg_s0;
            b_reg_s1          <= b_reg_s1;
            clr_acc_n_reg_s0  <= clr_acc_n_reg_s0;
            clr_acc_n_reg_s1  <= clr_acc_n_reg_s1;
            acc_reg           <= acc_reg;
            acc_reg_s2        <= acc_reg_s2;
	  end if;
	else
          a_reg_s0          <= (others => 'X');
          a_reg_s1          <= (others => 'X');
          b_reg_s0          <= (others => 'X');
          b_reg_s1          <= (others => 'X');
          clr_acc_n_reg_s0  <= 'X';
          clr_acc_n_reg_s1  <= 'X';
          acc_reg           <= (others => 'X');
          acc_reg_s2        <= (others => 'X');
	end if;

    end process;

    acc          <= acc_reg when pipe_reg_vec(2) = '0' else acc_reg_s2;
    pipe_census  <= pipe_census_int;

    
  monitor_clk  : process (clk) begin

    assert NOT (Is_X( clk ) AND (now > 0 ns)) 
      report "WARNING: Detected unknown value on the clock input port clk."
      severity warning;

  end process monitor_clk ;

  -- pragma translate_on 
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_piped_mac_cfg_sim of DW_piped_mac is
 for sim
 end for; -- sim
end DW_piped_mac_cfg_sim;
-- pragma translate_on

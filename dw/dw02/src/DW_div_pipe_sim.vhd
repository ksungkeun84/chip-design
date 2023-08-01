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
-- AUTHOR:    Rajeev Huralikoppi      April 2, 2002
--
-- VERSION:   VHDL Simulation Architecture
--
-- DesignWare_version: 803ec614
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Pipelined Divider Simulation model
--
--      Parameters      Valid Values    Description
--      ==========      =========       ===========
--      a_width         >= 1            default: none 
--                                      Word length of a
--      
--      b_width         >= 1            default: none
--                                      Word length of b
--      
--      tc_mode         0 or 1          default: 0
--                                      Two's complement control:
--                                        0 => inputs/outputs unsigned
--                                        1 => inputs/outputs two's complement
--
--      rem_mode        0 or 1          default: 1
--                                      Remainder output control:
--                                        0 => remainder output is VHDL modulus
--                                        1 => remainder output is remainder
--  
--      num_stages      >= 2            default: 2
--                                      Number of pipelined stages
--
--      stall_mode      0 or 1          default: 1
--                                      Stall mode
--                                        0 => non-stallable
--                                        1 => stallable
--
--      rst_mode        0 to 2          default: 1
--                                      Reset mode
--                                        0 => no reset
--                                        1 => asynchronous reset
--                                        2 => synchronous reset
--
--      op_iso_mode     0 to 4         default: 0
--                                     Type of operand isolation
--                                       If 'stall_mode' is '0', this parameter is ignored and no isolation is applied
--                                       0 => Follow intent defined by Power Compiler user setting
--                                       1 => no operand isolation
--                                       2 => 'and' gate operand isolaton
--                                       3 => 'or' gate operand isolation
--                                       4 => preferred isolation style: 'or'
--
--
--      Input Ports     Size            Description
--      ===========     ====            ============
--      clk             1               Clock
--      rst_n           1               Reset, active low
--      en              1               Register enable, active high
--      a               a_width         Divisor
--      b               b_width         Dividend
--
--      Output Ports    Size            Description
--      ============    ====            ============
--      quotient        a_width         quotient (a/b)
--      remainder       b_width         remainder
--      divide_by_0     1               divide by zero flag
--
--
-- MODIFIED :
--  11/04/15  RJK  Change pkg use from individual DW02 pkg to unified DWARE pkg
--
--            RJK  05/28/13   Updated documentation in comments to properly
--                            describe the "en" input (STAR 9000627580)
--            DLL  01/28/08   Added detail to abstract and added "op_iso_mode"
--                            parameter and related code.
--            DLL  11/10/05   Changed legality checking value of 'num_stages'
--                            parameter
--
--
-- 
---------------------------------------------------------------------------------
library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use DWARE.DW_Foundation_comp.all;
 
architecture sim of DW_div_pipe is
	
  
  type a_reg_type is array (0 to num_stages-1) of
    std_logic_vector(a_width-1 downto 0);
  type b_reg_type is array (0 to num_stages-1) of
    std_logic_vector(b_width-1 downto 0);

  signal a_reg  : a_reg_type;
  signal b_reg  : b_reg_type;
  
begin
-- pragma translate_off
  
  -- pipeline registers
  pipe_reg_PROC: process (clk, rst_n)
    variable a_var  : a_reg_type;
    variable b_var  : b_reg_type;  
  begin
    a_var(0)  := a;
    b_var(0)  := b;
    -- asynchronous reset
    if  (rst_n = '0') then
      if(rst_mode = 1) then
        for l in  num_stages-1 downto 1 loop
          a_var(l)  := (others => '0');
          b_var(l)  := (others => '0');
        end loop;
      elsif (rst_mode = 2) then
        if (clk'event and clk = '1') then
         -- synchronous reset
          for l in  num_stages-1 downto 1 loop
            a_var(l)  := (others => '0');
            b_var(l)  := (others => '0');
          end loop;
        end if;
      end if;
    elsif  (rst_n = '1') or (rst_mode = 0) then
      if (clk'event and clk = '1') then
        if (stall_mode /= 0) and (en = '0') then
          -- pipeline disbled
          for l in  num_stages-1 downto 1 loop
            a_var(l)  := a_var(l);
            b_var(l)  := b_var(l);
          end loop;      
      -- pipeline enabled
        elsif (stall_mode = 0) or (en = '1') then
          for l in num_stages-1 downto 1 loop
            a_var(l)  := a_var(l-1);
            b_var(l)  := b_var(l-1);
          end loop;
        else
          -- X-processing on en
          for l in  num_stages-1 downto 1 loop
            a_var(l)  := (others => 'X');
            b_var(l)  := (others => 'X');
          end loop;          
        end if;
      end if;
    else
      -- X-processing
      if(rst_mode = 1) then
        for l in  num_stages-1 downto 1 loop
          a_var(l)  := (others => 'X');
          b_var(l)  := (others => 'X');
        end loop;
      elsif (rst_mode = 2) then
        if (clk'event and clk = '1') then
         -- synchronous reset
          for l in  num_stages-1 downto 1 loop
            a_var(l)  := (others => 'X');
            b_var(l)  := (others => 'X');
          end loop;
        end if;
      end if;
    end if;
    for l in 0 to num_stages-1 loop
      a_reg(l)  <= a_var(l);
      b_reg(l)  <= b_var(l);
    end loop;
  end process pipe_reg_PROC;

  -- divider
  U_DIV : DW_div
    generic map (
      a_width  => a_width,
      b_width  => b_width,
      tc_mode  => tc_mode,
      rem_mode => rem_mode)
    port map (
      a           => a_reg(num_stages-1),
      b           => b_reg(num_stages-1),
      quotient    => quotient,
      remainder   => remainder,
      divide_by_0 => divide_by_0);
 -----------------------------------------------------------------------------
  -- Parameter legality check and initializations
  -----------------------------------------------------------------------------
  
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
    
    if ( (tc_mode < 0) OR (tc_mode > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter tc_mode (legal range: 0 to 1)"
        severity warning;
    end if;
    
    if ( (rem_mode < 0) OR (rem_mode > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter rem_mode (legal range: 0 to 1)"
        severity warning;
    end if;            
    
    if (num_stages < 2) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter num_stages (lower bound: 2)"
        severity warning;
    end if;   
    
    if ( (stall_mode < 0) OR (stall_mode > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter stall_mode (legal range: 0 to 1)"
        severity warning;
    end if;   
    
    if ( (rst_mode < 0) OR (rst_mode > 2) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter rst_mode (legal range: 0 to 2)"
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
 
  -----------------------------------------------------------------------------
  -- Report unknown clock inputs
  -----------------------------------------------------------------------------
  
  clk_monitor  : process (clk) begin

    assert NOT (Is_X( clk ) AND (now > 0 ns)) 
      report "WARNING: Detected unknown value on the clock input port clk."
      severity warning;

  end process clk_monitor ;
 -- pragma translate_on  
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

library dw02;

configuration DW_div_pipe_cfg_sim of DW_div_pipe is
 for sim
  for U_DIV : DW_div use configuration dw02.DW_div_cfg_sim; end for;
 end for; -- sim
end DW_div_pipe_cfg_sim;
-- pragma translate_on

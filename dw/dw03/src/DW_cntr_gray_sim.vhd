--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2001 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Reto Zimmermann    11/14/01
--
-- VERSION:   VHDL Simulation Model for DW_cntr_gray
--
-- DesignWare_version: 2d0fe3e2
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Gray counter
--
-- MODIFIED:
--
-------------------------------------------------------------------------------

library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DW_Foundation_arith.all;


architecture sim of DW_cntr_gray is
	

  signal count_int  : std_logic_vector(width-1 downto 0);

begin

  -- pragma translate_off

  -----------------------------------------------------------------------------
  -- Behavioral model
  -----------------------------------------------------------------------------

  register_PROC: process (clk, rst_n)

    variable count_next : std_logic_vector(width-1 downto 0);

  begin

    
    if (load_n = '0') then
      count_next := To_X01(data);
    elsif (load_n = '1') then
      count_next := DWF_inc_gray (count_int, cen);
    else
      count_next := (others => 'X');
    end if;
   
    
    if (rst_n = '0') then
      count_int <= (others => '0');
    elsif (rst_n = '1') then
      if (clk'event and clk = '1') then
        if (init_n = '0') then
          count_int <= (others => '0');
        elsif (init_n = '1') then
          count_int <= count_next;
        else
          count_int <= (others => 'X');
        end if;
      end if;
    else
      count_int <= (others => 'X');
    end if;

  end process register_PROC;


  count <= count_int;

  
  -----------------------------------------------------------------------------
  -- Parameter legality check
  -----------------------------------------------------------------------------

  
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
    
    if (width < 1) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter width (lower bound: 1)"
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

  
  monitor_clk_PROC : process (clk) begin

    assert NOT (Is_X( clk ) AND (now > 0 ns)) 
      report "WARNING: Detected unknown value on the clock input port clk."
      severity warning;

  end process monitor_clk_PROC;

  -- pragma translate_on

end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_cntr_gray_cfg_sim of DW_cntr_gray is
 for sim
 end for; -- sim
end DW_cntr_gray_cfg_sim;
-- pragma translate_on

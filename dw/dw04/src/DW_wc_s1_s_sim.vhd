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
-- AUTHOR:    RPH             Aug 2002
--
-- VERSION:   VHDL Simulation Model
--
-- DesignWare_version: d2838e52
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Boundary Scan Cell Type WC_S1_S
--
--           
--  Input Parameters:   value   Description
--  =========== 	====    ===========
--  rst_mode            0 to 3  0 - FFs have no set or reset
--                              1 - FFs with reset
--                              2 - FFs with set
--                              3 - FFs with both set and reset
--                         
--  Input Ports:   	Size    Description
--  =========== 	====    ===========
--  shift_clk           1 bit   shift clock
    
--  shift_en            1 bit   shift enable
--  capture_en          1 bit   Capture enable
--  safe_control        1 bit   Safe control
    
--  safe_value          1 bit   Safe value  
--  cfi                 1 bit    
--  cti                 1 bit    
--  
--  Output Ports    	Size    Description
--  ============	====    ===========
--  cfo                 1 bit    
--  cfo_n        	1 bit    
--  cto             	1 bit    
--              
--
--
-- MODIFIED: 
--		3/28/2003  RJK	Updated variable names related to functional
--				change in synthetic model for STAR 165306
--
--	RJK	6/23/2011
--		Added toggle_state input as requested by DFT team
--
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

architecture sim of DW_wc_s1_s is
	
  signal temp_cto : std_logic;
  signal temp_cti : std_logic;

begin
  -- pragma translate_off
  temp_cti <= To_X01(cti) when shift_en = '1' else
                 temp_cto XOR toggle_state when shift_en = '0' else
                 'X';
  cfo <= temp_cto when safe_control = '0' else
         To_X01(safe_value) when safe_control = '1' else
         'X';
  cfo_n <= not temp_cto when safe_control = '0' else
         not safe_value when safe_control = '1' else
         'X';
  cto <= temp_cto;
  
  SHIFT_PROC: process (shift_clk)
  begin  -- process SHIFT_PROC
   if ((rst_mode = 1 or rst_mode = 3) and rst_n = '0') then
     temp_cto <= '0';
   elsif ((rst_mode = 2 or rst_mode = 3) and set_n = '0') then
     temp_cto <= '1';
   elsif shift_clk'event and shift_clk'last_value = '0' and shift_clk = '1' then
     -- rising clock edge
     if (capture_en = '0') then
       temp_cto <= To_X01(cfi);
     elsif (capture_en = '1') then
       temp_cto <= temp_cti;
     else
       temp_cto <= 'X';
     end if;
   end if;
  end process SHIFT_PROC;
  
  -----------------------------------------------------------------------------
  -- Parameter legality check
  -----------------------------------------------------------------------------
  
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
    
    if ( (rst_mode < 0) OR (rst_mode > 3) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter rst_mode (legal range: 0 to 3)"
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
  
  clk_monitor  : process (shift_clk) begin

    assert NOT (Is_X( shift_clk ) AND (now > 0 ns)) 
      report "WARNING: Detected unknown value on the clock input port shift_clk."
      severity warning;

  end process clk_monitor ;   
-- pragma translate_on
end sim;  
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_wc_s1_s_cfg_sim of DW_wc_s1_s is
 for sim
 end for; -- sim
end DW_wc_s1_s_cfg_sim;
-- pragma translate_on

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
-- DesignWare_version: dfda1905
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Boundary Scan Cell Type BC_8
--
--           
--
--              
--  Input Ports:   	Size    Description
--  =========== 	====    ===========
--  capture_clk     	1 bit   Clocks data into the capture stage
--  update_clk      	1 bit   Clocks data into the update stage 
--  capture_en      	1 bit   Enable for data clocked into the capture 
--  update_en       	1 bit   Enable for data clocked into the update stage 
--  shift_dr           	1 bit   Enables the boundary scan chain to shift data
--			        one stage toward its serial output (tdo) 
--  mode		1 bit  	Determines whether data_out is controlled by the
--				boundary scan cell or by the data_in signal
--				
--  si	 		1 bit  	Serial path from the previous boundary scan cell
--  pin_input 		1 bit 	IC input data
--  data_in		1 bit 	Input data
--
--  
--  Output Ports    	Size    Description
--  ============	====    ===========
--  ic_input        	1 bit   System input logic
--  data_out        	1 bit   Output data
--  so              	1 bit   Serial path to the next boundary scan cell
--              
--
--
-- MODIFIED: 
--
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

architecture sim of DW_bc_8 is
	
  signal capture_out : std_logic;
  signal update_out  : std_logic;
  signal capture_val : std_logic;

begin
  -- pragma translate_off
  capture_val <= To_X01(pin_input) when shift_dr = '0' else
                 To_X01(si) when shift_dr = '1' else
                 'X';
  data_out <= To_X01(output_data) when mode = '0' else
              update_out when mode = '1' else
              'X';
  
  ic_input <= pin_input;
  so       <= capture_out;
  
  CAPTURE_PROC: process (capture_clk)
  begin  -- process CAPTURE_PROC
   if capture_clk'event and capture_clk'last_value = '0' and capture_clk = '1' then
     -- rising clock edge
     if (capture_en = '1') then
       capture_out <= capture_out;
     elsif (capture_en = '0') then
       capture_out <= capture_val;
     else
       capture_out <= 'X';
     end if;
   end if;
  end process CAPTURE_PROC;

  UPDATE_PROC: process (update_clk)
  begin  -- process UPDATE_PROC
    if update_clk'event and update_clk'last_value = '0' and update_clk = '1' then
      -- rising clock edge
      if (update_en = '1') then
        update_out <= capture_out;
      elsif (update_en = '0') then
        update_out <= update_out;
      else
        update_out <= 'X';
      end if;
    end if;
  end process UPDATE_PROC;
  
  -----------------------------------------------------------------------------
  -- Parameter legality check
  -----------------------------------------------------------------------------
  
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
    --no parameters to check
  
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;

  -----------------------------------------------------------------------------
  -- Report unknown clock inputs
  -----------------------------------------------------------------------------
  
  clk_monitor1  : process (capture_clk) begin

    assert NOT (Is_X( capture_clk ) AND (now > 0 ns)) 
      report "WARNING: Detected unknown value on the clock input port capture_clk."
      severity warning;

  end process clk_monitor1 ;
  
  clk_monitor2  : process (update_clk) begin

    assert NOT (Is_X( update_clk ) AND (now > 0 ns)) 
      report "WARNING: Detected unknown value on the clock input port update_clk."
      severity warning;

  end process clk_monitor2 ;    
-- pragma translate_on
end sim;  
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_bc_8_cfg_sim of DW_bc_8 is
 for sim
 end for; -- sim
end DW_bc_8_cfg_sim;
-- pragma translate_on

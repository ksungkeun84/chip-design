--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 1992 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    KB			March 25, 1994
--
-- VERSION:   Synthetic Architecture
--
-- DesignWare_version: 70f0c2c4
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Register with Synchronous Enable and Reset
--
---------------------------------------------------------------------------------
-- 
--      WSFDB revision control info 
--              @(#)DW03_reg_s_pl.vhd	1.2
--
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
entity DW03_reg_s_pl is
	generic(width: POSITIVE := 8;
		reset_value: INTEGER := 0);
	port (	d	: in	std_logic_vector(width-1 downto 0);
		clk	: in	std_logic;
		reset_N	: in	std_logic;
		enable	: in	std_logic;
		q	: out	std_logic_vector(width-1 downto 0) );
   -- Design Analyzer Symbol 
   -- pragma dc_tcl_script_begin
   -- set_attribute [current_design] "canonical_name" "DW03_reg_s_pl" -type "string" -quiet
   -- set_attribute "d" "canonical_pin_number" "0" -type "integer" -bus -quiet
   -- set_attribute "clk" "canonical_pin_number" "1" -type "integer" -bus -quiet
   -- set_attribute "reset_N" "canonical_pin_number" "2" -type "integer" -bus -quiet
   -- set_attribute "enable" "canonical_pin_number" "3" -type "integer" -bus -quiet
   -- set_attribute "q" "canonical_pin_number" "4" -type "integer" -bus -quiet
   -- pragma dc_tcl_script_end
	
end DW03_reg_s_pl;

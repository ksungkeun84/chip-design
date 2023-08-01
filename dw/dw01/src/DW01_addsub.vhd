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
-- AUTHOR:    PS			Nov. 8, 1992
--
-- VERSION:   VHDL Entity File
--
-- DesignWare_version: 4bbd9a56
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Adder-Subtractor
--           ADD_SUB= '1' : SUM <= A - B - CI
--           ADD_SUB= '0' : SUM <= A + B + CI
--           Carry-in and Carry-out is active high with both addition 
--           and subtraction.
-- MODIFIED: 
--
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
entity DW01_addsub is
   generic(width: NATURAL);
   port(A,B : in std_logic_vector(width-1 downto 0);
        CI : in std_logic;
        ADD_SUB : std_logic;
        SUM : out std_logic_vector(width-1 downto 0);
        CO : out std_logic);
-- Design Analyzer Symbol 
-- pragma dc_tcl_script_begin
-- set_attribute [current_design] "canonical_name" "DW01_addsub" -type "string" -quiet
-- set_attribute "A" "canonical_pin_number" "0" -type "integer" -bus -quiet
-- set_attribute "B" "canonical_pin_number" "1" -type "integer" -bus -quiet
-- set_attribute "CI" "canonical_pin_number" "2" -type "integer" -bus -quiet
-- set_attribute "ADD_SUB" "canonical_pin_number" "3" -type "integer" -bus -quiet
-- set_attribute "SUM" "canonical_pin_number" "4" -type "integer" -bus -quiet
-- set_attribute "CO" "canonical_pin_number" "5" -type "integer" -bus -quiet
-- pragma dc_tcl_script_end
	
end DW01_addsub;

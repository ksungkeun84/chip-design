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
-- AUTHOR:    PS
--
-- VERSION:   Entity
--
-- DesignWare_version: 423adaf3
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  2-Function Comparator
--
-- MODIFIED: 
--
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
entity DW01_cmp2 is
   generic (width : NATURAL);
   port(A,B : in std_logic_vector(width-1 downto 0) ;
        LEQ : in std_logic ; -- 1 => LEQ/GT 0=> LT/GEQ
	TC : in std_logic;  -- 1 => 2's complement numbers
        LT_LE : out std_logic ;
        GE_GT : out std_logic) ;
-- Design Analyzer Symbol 
-- pragma dc_tcl_script_begin
-- set_attribute [current_design] "canonical_name" "DW01_cmp2" -type "string" -quiet
-- set_attribute "A" "canonical_pin_number" "0" -type "integer" -bus -quiet
-- set_attribute "B" "canonical_pin_number" "1" -type "integer" -bus -quiet
-- set_attribute "LEQ" "canonical_pin_number" "2" -type "integer" -bus -quiet
-- set_attribute "TC" "canonical_pin_number" "3" -type "integer" -bus -quiet
-- set_attribute "LT_LE" "canonical_pin_number" "4" -type "integer" -bus -quiet
-- set_attribute "GE_GT" "canonical_pin_number" "5" -type "integer" -bus -quiet
-- pragma dc_tcl_script_end
	
end DW01_cmp2;

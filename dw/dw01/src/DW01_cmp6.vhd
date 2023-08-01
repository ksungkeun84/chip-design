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
-- DesignWare_version: 467eed51
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  6-Function Comparator
--
-- MODIFIED: 
--
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
entity DW01_cmp6 is
   generic (width : NATURAL);
   port(A,B: in std_logic_vector(width-1 downto 0) ;
        TC : in std_logic ;
        LT : out std_logic ;
        GT : out std_logic ;
        EQ : out std_logic ;
        LE : out std_logic ;
        GE : out std_logic ;
        NE : out std_logic) ;
-- Design Analyzer Symbol 
-- pragma dc_tcl_script_begin
-- set_attribute [current_design] "canonical_name" "DW01_cmp6" -type "string" -quiet
-- set_attribute "A" "canonical_pin_number" "0" -type "integer" -bus -quiet
-- set_attribute "B" "canonical_pin_number" "1" -type "integer" -bus -quiet
-- set_attribute "TC" "canonical_pin_number" "2" -type "integer" -bus -quiet
-- set_attribute "LT" "canonical_pin_number" "3" -type "integer" -bus -quiet
-- set_attribute "GT" "canonical_pin_number" "4" -type "integer" -bus -quiet
-- set_attribute "EQ" "canonical_pin_number" "5" -type "integer" -bus -quiet
-- set_attribute "LE" "canonical_pin_number" "6" -type "integer" -bus -quiet
-- set_attribute "GE" "canonical_pin_number" "7" -type "integer" -bus -quiet
-- set_attribute "NE" "canonical_pin_number" "8" -type "integer" -bus -quiet
-- pragma dc_tcl_script_end
 
	
end DW01_cmp6;

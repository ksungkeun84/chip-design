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
-- AUTHOR:    Taewhan Kim (BC)
--
-- VERSION:   Entity
--
-- DesignWare_version: ad03163b
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Carry Save Adder
--            for the HDL subprogram csa.
--  
--  
-- MODIFIED:  
-- 
--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
entity DW01_csa is
  generic (
    width : INTEGER
  );
  port (
    a     : in std_logic_vector(width-1 downto 0);
    b     : in std_logic_vector(width-1 downto 0);
    c     : in std_logic_vector(width-1 downto 0);
    ci    : in std_logic;
    carry : out std_logic_vector(width-1 downto 0);
    sum   : out std_logic_vector(width-1 downto 0);
    co    : out std_logic
  );
-- Design Analyzer Symbol
-- pragma dc_tcl_script_begin
-- set_attribute [current_design] "canonical_name" "DW01_csa" -type "string" -quiet
-- set_attribute "a" "canonical_pin_number" "0" -type "integer" -bus -quiet
-- set_attribute "b" "canonical_pin_number" "1" -type "integer" -bus -quiet
-- set_attribute "c" "canonical_pin_number" "2" -type "integer" -bus -quiet
-- set_attribute "ci" "canonical_pin_number" "3" -type "integer" -bus -quiet
-- set_attribute "carry" "canonical_pin_number" "4" -type "integer" -bus -quiet
-- set_attribute "sum" "canonical_pin_number" "5" -type "integer" -bus -quiet
-- set_attribute "co" "canonical_pin_number" "6" -type "integer" -bus -quiet
-- pragma dc_tcl_script_end
	
end DW01_csa;

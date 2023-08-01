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
-- AUTHOR:    PS			Oct. 3, 1992
--
-- VERSION:   VHDL Entity File
--
-- DesignWare_version: c47a91c2
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Multiplier
--           A_width-Bits * B_width-Bits => A_width+B_width Bits
--           Operands A and B can be either both signed (two's complement) or 
--	     both unsigned numbers. TC determines the coding of the input operands.
--           ie. TC = '1' => signed multiplication
--	         TC = '0' => unsigned multiplication
--
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
entity DW02_mult is
   generic( A_width: NATURAL;		-- multiplier wordlength
            B_width: NATURAL);		-- multiplicand wordlength
   port(A : in std_logic_vector(A_width-1 downto 0);  
        B : in std_logic_vector(B_width-1 downto 0);
        TC : in std_logic;		-- signed -> '1', unsigned -> '0'
        PRODUCT : out std_logic_vector(A_width+B_width-1 downto 0));
   -- Design Analyzer Symbol 
   -- pragma dc_tcl_script_begin
   -- set_attribute [current_design] "canonical_name" "DW02_mult" -type "string" -quiet
   -- set_attribute "A" "canonical_pin_number" "0" -type "integer" -bus -quiet
   -- set_attribute "B" "canonical_pin_number" "1" -type "integer" -bus -quiet
   -- set_attribute "TC" "canonical_pin_number" "2" -type "integer" -bus -quiet
   -- set_attribute "PRODUCT" "canonical_pin_number" "3" -type "integer" -bus -quiet
   -- pragma dc_tcl_script_end
	
end DW02_mult;

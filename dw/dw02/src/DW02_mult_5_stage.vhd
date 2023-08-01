--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 1995 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Reiner Genevriere    Aug. 10, 1995
--
-- VERSION:   VHDL Entity File
--
-- DesignWare_version: 3d4f0f29
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Five-Stage Pipelined Multiplier
--
-- MODIFIED : GN  Jan. 25, 1996
--            Move component from DW03 to DW02
--	10/15/1998	Jay Zhu	STAR 59348
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
entity DW02_mult_5_stage is
   generic( A_width: POSITIVE;		-- multiplier wordlength
            B_width: POSITIVE);		-- multiplicand wordlength
   port(A : in std_logic_vector(A_width-1 downto 0);  
        B : in std_logic_vector(B_width-1 downto 0);
        TC : in std_logic;		-- signed -> '1', unsigned -> '0'
        CLK : in std_logic;           -- clock for the stage registers.
        PRODUCT : out std_logic_vector(A_width+B_width-1 downto 0));
   -- Design Analyzer Symbol 
   -- pragma dc_tcl_script_begin
   -- set_attribute [current_design] "canonical_name" "DW02_mult_5_stage" -type "string" -quiet
   -- set_attribute "A" "canonical_pin_number" "0" -type "integer" -bus -quiet
   -- set_attribute "B" "canonical_pin_number" "1" -type "integer" -bus -quiet
   -- set_attribute "TC" "canonical_pin_number" "2" -type "integer" -bus -quiet
   -- set_attribute "CLK" "canonical_pin_number" "3" -type "integer" -bus -quiet
   -- set_attribute "PRODUCT" "canonical_pin_number" "4" -type "integer" -bus -quiet
   -- set_optimize_registers "true" 
   -- pragma dc_tcl_script_end
	
end DW02_mult_5_stage;

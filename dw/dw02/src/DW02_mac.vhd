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
-- AUTHOR:    PS			Oct. 3, 1991
--
-- VERSION:   VHDL Entity File
--
-- DesignWare_version: 4cd2d4f1
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Multiplier-Accumulator
--           (A_width Bits * B_width Bits) + (A_width+B_width Bits)
--             => A_width+B_width Bits  
--           signed or unsigned operands       
--           ie. TC = '1' => signed 
--	         TC = '0' => unsigned 
-- MODIFYED:
--	10/15/1998	Jay Zhu	STAR 59348 & remove signed/unsigned
--			mixed functions which are never implemented
--
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
entity DW02_mac is
   generic( A_width: NATURAL ;                  -- multiplier wordlength
            B_width: NATURAL);                  -- multiplicand wordlength
   port(A : in std_logic_vector(A_width-1 downto 0);  
        B : in std_logic_vector(B_width-1 downto 0);
        C : in std_logic_vector(A_width+B_width-1 downto 0);
        TC : in std_logic;          
        MAC : out std_logic_vector(A_width+B_width-1 downto 0));
-- pragma dc_tcl_script_begin
-- set_attribute [current_design] "canonical_name" "DW02_mac" -type "string" -quiet
-- pragma dc_tcl_script_end
	
end DW02_mac;

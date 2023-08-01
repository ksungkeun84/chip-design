--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 1994 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    PS			Dec. 2, 1994
--
-- VERSION:   VHDL Entity File
--
-- DesignWare_version: fc56b380
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Generalized Sum of Products
--           signed or unsigned operands       
--           ie. TC = '1' => signed 
--	         TC = '0' => unsigned 
--
--------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
entity DW02_prod_sum is
   generic( A_width: NATURAL;             -- multiplier wordlength
            B_width: NATURAL;             -- multiplicand wordlength
	    num_inputs: POSITIVE;          
            SUM_width: NATURAL);          -- multiplicand wordlength 
   port(A : in std_logic_vector(num_inputs*A_width-1 downto 0);  
        B : in std_logic_vector(num_inputs*B_width-1 downto 0);
        TC : in std_logic;          
        SUM : out std_logic_vector(SUM_width-1 downto 0));
-- pragma dc_tcl_script_begin
-- set_attribute [current_design] "canonical_name" "DW02_prod_sum" -type "string" -quiet
-- pragma dc_tcl_script_end
	
end DW02_prod_sum;

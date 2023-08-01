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
-- AUTHOR:    PS			Jan. 21, 1992
--
-- VERSION:   VHDL Entity File
--
-- DesignWare_version: 44edce5b
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Vector Adder
--           number of inputs = 'num_inputs'
--           wordlenght of inputs and output = 'input_width'
--
--           Sum a number of input words together to form the outpus SUM
--           Since a variable number of input ports is not supported the 
--           2-D array of inputs (num_inputs X input_width) is flattened into
--           a single 1-D array of length num_inputs*input_width bits.
--
-- MODIFIED:
--
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
entity DW02_sum is
  generic(num_inputs : NATURAL;      -- number of inputs
          input_width : NATURAL);     -- wordlength of inputs
  port(INPUT : in std_logic_vector(num_inputs*input_width-1 downto 0);  
       SUM : out std_logic_vector(input_width-1 downto 0));
-- pragma dc_tcl_script_begin
-- set_attribute [current_design] "canonical_name" "DW02_sum" -type "string" -quiet
-- pragma dc_tcl_script_end
	
end DW02_sum;

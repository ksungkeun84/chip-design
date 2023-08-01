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
-- AUTHOR:    PS                 Jan. 21, 1992
--
-- VERSION:   VHDL Entity File
--
-- DesignWare_version: 5134936d
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Wallace Tree Compressor
--           number of inputs = 'num_inputs'
--           wordlenght of inputs and output = 'input_width'
--
--           Compress a set of data into two terms. 
--           Since a variable number of input ports is not supported the 
--           2-D array of inputs (num_inputs X input_width) is flattened into
--           a single 1-D array of length num_inputs*input_width bits.
--           Note: there is no final carry-ripple adder in this architecture.
--
-- MODIFIED:
--            Alex Tenca  6/20/2011
--            Introduced a new parameter (verif_en) that allows the use of random 
--            CS output values, instead of the fixed CS representation used in 
--            the original model. By "fixed" we mean: the CS output is always the
--            the same for the same input values. By using a randomization process,
--            the CS output for a given input value will change with time. The CS
--            output takes one of the possible CS representations that correspond
--            to the binary output of the DW02_tree. For example: for binary (0110)
--            sometimes the output is (0101,0001), sometimes (0110,0000), sometimes
--            (1100,1010), etc. These are all valid CS representations of 6.
--            Options for the CS output behavior are (based on verif_en parameter):
--              0 - old behavior (fixed CS representation)
--              1 - fully random CS output
--
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
entity DW02_tree is
  generic(num_inputs : POSITIVE;      -- number of inputs
          input_width : POSITIVE;     -- wordlength of inputs
 	  verif_en : INTEGER := 1);   -- control of random CS output
  port(INPUT : in std_logic_vector(num_inputs*input_width-1 downto 0);  
       OUT0, OUT1: out std_logic_vector(input_width-1 downto 0));
end DW02_tree;

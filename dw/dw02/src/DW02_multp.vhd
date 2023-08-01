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
-- AUTHOR:    Paul Scheidt       Jan. 31, 1994
--
-- VERSION:   VHDL Entity File
--
-- DesignWare_version: 0e17ef87
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Multiplier, partial products
--           a_width-Bits * b_width-Bits => out_width Bits
--           Operands a and b can be either both signed (two's complement) or
--           both unsigned numbers. The tc input determines the coding of the
--           input operands.
--           ie. tc = '1' => signed multiplication
--               tc = '0' => unsigned multiplication
--    
--           Note:
--           The two outputs, out0 and out1, must be fed to a final adder
--           module in order to complete the multiplication.  
--
-- MODIFICATION:
--
--		RJK - 6/2/97
--		entity changed to include all bits of out1 and out2 from
--		DW02_tree in order to include sign extension before
--		summing (so as to postpone carry-propogate addition for
--		sums of products and other merged operations)
--              Alex Tenca  6/3/2011
--              Introduced a new parameter (verif_en) that allows the use of random 
--              CS output values, instead of the fixed CS representation used in 
--              the original model. By "fixed" we mean: the CS output is always the
--              the same for the same input values. By using a randomization process, 
--              the CS output for a given input value will change with time. The CS
--              output takes one of the possible CS representations that correspond 
--              to the product of the input values. For example: 3*2=6 may generate
--              sometimes the output (0101,0001), sometimes (0110,0000), sometimes
--              (1100,1010), etc. These are all valid CS representations of 6.
--              Options for the CS output behavior are (based on verif_en parameter):
--              0 - old behavior (fixed CS representation)
--              1 - partially random CS output. MSB of out0 is always '0'
--                  This behavior is similar to the old behavior, in the sense that
--                  the MSB of the old behavior has a constant bit. It differs from
--                  the old behavior because the other bits are random
--              2 - partially random CS output. MSB of either out0 or out1 always
--                  have a '0'
--              3 - fully random CS output
--              Alex Tenca 12/20/2016
--              Changed default value of verif_en to 2
--
--
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
--slLIB dw02
--slIMP wall DesignWare-Foundation DW02_booth/str DW02_tree/wallace
entity DW02_multp is
   generic( a_width: NATURAL;           -- multiplier word size
            b_width: NATURAL;           -- multiplicand word size
	    out_width: NATURAL;         -- partial prod word size
            verif_en: INTEGER := 2);    -- random CS representation control
   port(a : in std_logic_vector(a_width-1 downto 0);  
        b : in std_logic_vector(b_width-1 downto 0);
        tc : in std_logic;              -- signed -> '1', unsigned -> '0'
        out0 : out std_logic_vector(out_width-1 downto 0);
        out1 : out std_logic_vector(out_width-1 downto 0));
end DW02_multp;

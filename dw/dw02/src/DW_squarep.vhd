--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 1998 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Rick Kelly       Dec. 9, 1998
--
-- VERSION:   Synthetic Architecture
--
-- DesignWare_version: 59fb46bc
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT: : Integer Square with two partial product outputs
--             The output of this component is in Carry-save form. The
--             square input value is obtained in binary by adding the 
--             two outputs.
--
-- MODIFICATION:
--              06/23/2011 - Alex Tenca
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
--slIMP wall DesignWare-Foundation

entity DW_squarep is
   generic( width: NATURAL;             -- multiplier size
            verif_en: INTEGER := 2);    -- random CS representation control

   port(a : in std_logic_vector(width-1 downto 0);  
        tc : in std_logic;          -- signed -> '1', unsigned -> '0'
        out0 : out std_logic_vector((2*width)-1 downto 0);
        out1 : out std_logic_vector((2*width)-1 downto 0));

end DW_squarep;


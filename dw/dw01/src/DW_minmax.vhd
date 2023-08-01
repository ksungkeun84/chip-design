--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 1999 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Reto Zimmermann              July 26, 1999
--
-- VERSION:   Entity
--
-- DesignWare_version: 7527ba93
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT: Minimum/maximum value detector/selector
--           - This component determines and selects the minimum or maximum
--             value out of NUM_INPUTS inputs.  The inputs must be merged into
--             one single input vector A.
--           - TC determines whether the inputs are unsigned ('0') of signed
--             ('1').
--           - Min_Max determines whether the minimum ('0') or the maximum
--             ('1') is determined.
--           - Value outputs the minimum/maximum value.
--           - Index tells which input it the minimum/maximum.
--           
-- MODIFIED: 03/01/00  Reto Zimmermann
--           Fixed STAR 99910
--
-------------------------------------------------------------------------------

library IEEE, DWARE;
use IEEE.std_logic_1164.all;
--use IEEE.std_logic_arith.all;
use DWARE.DW_Foundation_arith.all;


entity DW_minmax is

  generic (
    width      : natural;               -- word width of inputs and output
    num_inputs : natural := 2);         -- number of inputs

  port (
    a       : in  std_logic_vector(num_inputs*width-1 downto 0);  -- operands
    tc      : in  std_logic;          -- '0' : unsigned, '1' : signed
    min_max : in  std_logic;          -- '0' : minimum, '1' : maximum
    value   : out std_logic_vector(width-1 downto 0);  -- output value
    index   : out std_logic_vector(bit_width(num_inputs)-1 downto 0));
                                        -- index of operand that is min/max

end DW_minmax;



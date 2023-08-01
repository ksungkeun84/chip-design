--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2013 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Reto Zimmermann         Sep 25, 2013
--
-- VERSION:   Entity
--
-- DesignWare_version: 94fcd61e
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Combinational Divider with Saturation
--            - Divides two operands a and b to yield a saturated quotient
--              and divide_by_0 flag.
--            - Parameter tc_mode switches between unsigned and signed division
--            
--   Parameter  Legal Range       Default  Description
--   ---------  -----------       -------  -----------
--   a_width    >= 2              none     word length of a
--   b_width    >= 2              none     word length of b
--   q_width    >= 2, <= a_width  none     word length of quotient
--   tc_mode    0 or 1            0        two's complement control:
--                                           0 : inputs/outputs unsigned
--                                           1 : inputs/outputs two's complement
--
--   Inputs       Size     Description
--   ------       ----     -----------
--   a            a_width  dividend
--   b            b_width  divisor
--
--   Outputs      Size
--   -------      ----
--   quotient     q_width  quotient
--   divide_by_0  1        indicates if b equals 0
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;


entity DW_div_sat is

  generic (
    a_width  : positive;                    -- word width of dividend
    b_width  : positive;                    -- word width of divisor
    q_width  : positive;                    -- word width of quotient
    tc_mode  : integer  := 0);  -- '0' : unsigned, '1' : 2's compl.

  port (
    a           : in  std_logic_vector(a_width-1 downto 0);  -- dividend
    b           : in  std_logic_vector(b_width-1 downto 0);  -- divisor
    quotient    : out std_logic_vector(q_width-1 downto 0);  -- quotient
    divide_by_0 : out std_logic);     -- divide-by-0 flag

end DW_div_sat;

-------------------------------------------------------------------------------

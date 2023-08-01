--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2000 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Reto Zimmermann         March 21, 2000
--
-- VERSION:   Entity
--
-- DesignWare_version: 84e9e8c4
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Combinational Divider
--            - Divides two operands a and b to yield a quotient, remainder,
--              and divide_by_0 flag.
--            - Parameter tc_mode switches between unsigned and signed division
--            - Parameter rem_mode switches between remainder and modulus at
--              remainder output.
--            
--   Parameter  Legal Range    Default  Description
--   ---------  -----------    -------  -----------
--   a_width    >= 1           none     word length of a
--   b_width    >= 1           none     word length of b
--   tc_mode    0 or 1         0        two's complement control:
--                                        0 : inputs/outputs unsigned
--                                        1 : inputs/outputs two's complement
--   rem_mode   0 or 1         1        remainder output control:
--                                        0 : remainder output is VHDL modulus
--                                        1 : remainder output is remainder
--
--   Inputs       Size     Description
--   ------       ----     -----------
--   a            a_width  dividend
--   b            b_width  divisor
--
--   Outputs      Size
--   -------      ----
--   quotient     a_width  quotient
--   remainder    b_width  remainder/modulus
--   divide_by_0  1        indicates if b equals 0
--   
-- MODIFIED:  Reto Zimmermann, July 25, 2005
--            - IEEE compliance (special case: "minimum negative number / -1")
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;


entity DW_div is

  generic (
    a_width  : positive;                    -- word width of dividend, quotient
    b_width  : positive;                    -- word width of divisor, remainder
    tc_mode  : integer  := 0;   -- '0' : unsigned, '1' : 2's compl.
    rem_mode : integer  := 1);  -- '0' : modulus, '1' : remainder

  port (
    a           : in  std_logic_vector(a_width-1 downto 0);  -- dividend
    b           : in  std_logic_vector(b_width-1 downto 0);  -- divisor
    quotient    : out std_logic_vector(a_width-1 downto 0);  -- quotient
    remainder   : out std_logic_vector(b_width-1 downto 0);  -- remainder
    divide_by_0 : out std_logic);     -- divide-by-0 flag

end DW_div;

-------------------------------------------------------------------------------

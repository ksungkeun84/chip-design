--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2009 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Kyung-Nam Han  Nov. 30, 2009
--
-- VERSION:   VHDL Entity for DW_lp_multifunc
--
-- DesignWare_version: 18196faf
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--
-- ABSTRACT: Fixed-point Multi-function Unit
--
--              DW_lp_multifunc calculates transcendental functions 
--              with polynomial approximation method. Functions that are 
--              implemented include reciprocal, square root, inverse 
--              square root, trigonometric functions, logarithm and 
--              exponential function. All can be implemented in one unit,
--              but user can choose some of them or just one function for
--              the implementation. 
--
--              parameters      valid values (defined in the DW manual)
--              ==========      ============
--              op_width        operand width,  3 to 24 bits
--              func_select     Select functions to be implemented
--                              16-bit binary parameter
--                              func_select[0]: reciprocal, 1/x
--                              func_select[1]: square root, sqrt(x)
--                              func_select[2]: inv. square root, 1/sqrt(x)
--                              func_select[3]: sine function, sin(pi*x)
--                              func_select[4]: cosine function, cos(pi*x)
--                              func_select[5]: base-2 log function, log2(x)
--                              func_select[6]: base-2 power function, 2^x
--                              func_select[7:15]: reserved
--
--              Input ports     Size & Description
--              ===========     ==================
--              a               (op_width + 1) bits
--                              Fixed-point Number Input
--              func            16-bit Function selection port
--                              Output function is determined by FUNC
--
--              Output ports    Size & Description
--              ===========     ==================
--              z               (op_width + 2) bits
--                              Fixed-point number output
--              status          1 bit
--
-------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

entity DW_lp_multifunc is

  generic(
    op_width        : POSITIVE   := 24;
    func_select     : POSITIVE  := 127
  );

  port(
    a        : in std_logic_vector(op_width downto 0);
    func     : in std_logic_vector(15 downto 0);
    z        : out std_logic_vector(op_width + 1 downto 0);
    status   : out std_logic
  );

end DW_lp_multifunc;



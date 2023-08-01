--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2006 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Alexandre Tenca, Dec. 5, 2006
--
-- VERSION:   VHDL Entity for DW_fp_invsqrt
--
-- DesignWare_version: 6d10fcc2
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--
-- ABSTRACT: Floating-Point Inverse Square Root
--
--              DW_fp_invsqrt calculates the floating-point reciprocal of 
--              a square root. It supports six rounding modes, including 
--              four IEEE standard rounding modes.
--
--              parameters      valid values
--              ==========      ============
--              sig_width       significand f,  2 to 253 bits
--              exp_width       exponent e,     3 to 31 bits
--              ieee_compliance 0 or 1 
--                              support the IEEE Compliance 
--                              including NaN and denormal.
--                              0 - MC (module compiler) compatible
--                              1 - IEEE 754 standard compatible
--
--              Input ports     Size & Description
--              ===========     ==================
--              a               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Input
--              rnd             3 bits
--                              Rounding Mode Input
--              z               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Output
--              status          8 bits
--                              Status Flags Output
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity DW_fp_invsqrt is

  generic(
    sig_width   : POSITIVE  := 23;
    exp_width   : POSITIVE   := 8;
    ieee_compliance: INTEGER     := 0
  );

  port(
    a        : in std_logic_vector(sig_width + exp_width downto 0);
    rnd      : in std_logic_vector(2 downto 0);
    z        : out std_logic_vector(sig_width + exp_width downto 0);
    status   : out std_logic_vector(7 downto 0)
  );

end DW_fp_invsqrt;


--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2008 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Alex Tenca and Kyung-Nam Han  March 14, 2008
--
-- VERSION:   VHDL Entity for DW_ifp_mult
--
-- DesignWare_version: 4f013a4d
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--
-- ABSTRACT: Floating-Point Multiplier - Internal Format
--
--              DW_ifp_mult calculates the floating-point multiplication
--              while receiving and generating FP values in internal
--              FP format (no normalization).
--
--              parameters      valid values (defined in the DW manual)
--              ==========      ============
--              sig_widthi      significand size of the input,  2 to 253 bits
--              exp_widthi      exponent size of the input,     3 to 31 bits
--              sig_widtho      significand size of the output, 2 to 253 bits
--              exp_widtho      exponent size of the output,    3 to 31 bits
--
--              Input ports     Size & Description
--              ===========     ==================
--              a               (sig_widthi + exp_widthi + 7)-bits
--                              Internal Floating-point Number Input
--              b               (sig_widthi + exp_widthi + 7)-bits
--                              Internal Floating-point Number Input
--
--              Output ports    Size & Description
--              ===========     ==================
--              z               (sig_widtho + exp_widtho + 7)-bits
--                              Internal Floating-point Number Output
--
--  MODIFICATIONS
--              
-------------------------------------------------------------------------------

library IEEE, DWARE;
use IEEE.std_logic_1164.all;

entity DW_ifp_mult is

  generic(
    sig_widthi   : POSITIVE  := 23;
    exp_widthi   : POSITIVE   := 8;
    sig_widtho   : POSITIVE  := 23;
    exp_widtho   : POSITIVE   := 8
  );

  port(
    a        : in std_logic_vector(sig_widthi + exp_widthi + 7 -1 downto 0);
    b        : in std_logic_vector(sig_widthi + exp_widthi + 7 -1 downto 0);
    z        : out std_logic_vector(sig_widtho + exp_widtho + 7 -1 downto 0)
  );

end DW_ifp_mult;


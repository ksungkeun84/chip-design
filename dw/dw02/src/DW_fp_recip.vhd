
--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2007 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Kyung-Nam Han, Jul. 16, 2007
--
-- VERSION:   VHDL Entity for DW_fp_recip
--
-- DesignWare_version: 1475e80d
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-- ABSTRACT: Floating-Point Reciprocal
--
--              DW_fp_recip calculates the floating-point reciprocal
--              with 1 ulp error.
--
--              parameters      valid values (defined in the DW manual)
--              ==========      ============
--              sig_width       significand size,  2 to 60 bits
--              exp_width       exponent size,     3 to 31 bits
--              ieee_compliance support the IEEE Compliance 
--                              0 - IEEE 754 compatible without denormal support
--                                  (NaN becomes Infinity, Denormal becomes Zero)
--                              1 - IEEE 754 compatible with denormal support
--                                  (NaN and denormal numbers are supported)
--              faithful_round  parameter for the faithful_rounding that
--                              admits 1 ulp error
--                              0 - default value. it keeps all rounding modes
--                              1 - z has 1 ulp error. RND input does not affect 
--                                  the output
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

entity DW_fp_recip is

  generic(
    sig_width      : POSITIVE  := 23;
    exp_width      : POSITIVE  := 8;
    ieee_compliance: INTEGER    := 0;
    faithful_round : INTEGER    := 0
  );

  port(
    a        : in std_logic_vector(sig_width + exp_width downto 0);
    rnd      : in std_logic_vector(2 downto 0);
    z        : out std_logic_vector(sig_width + exp_width downto 0);
    status   : out std_logic_vector(7 downto 0)
  );

end DW_fp_recip;



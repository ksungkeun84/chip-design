
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
-- AUTHOR:    Kyung-Nam Han, Mar. 22, 2006
--
-- VERSION:   VHDL Entity for DW_fp_div
--
-- DesignWare_version: a2c5eb80
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--
-- ABSTRACT: Floating-Point Divider
--
--              DW_fp_div calculates the floating-point division
--              while supporting six rounding modes, including four IEEE
--              standard rounding modes.
--
--              parameters      valid values (defined in the DW manual)
--              ==========      ============
--              sig_width       significand size,  2 to 253 bits
--              exp_width       exponent size,     3 to 31 bits
--              ieee_compliance support the IEEE Compliance 
--                              0 - IEEE 754 compatible without denormal support
--                                  (NaN becomes Infinity, Denormal becomes Zero)
--                              1 - IEEE 754 compatible with denormal support
--                                  (NaN and denormal numbers are supported)
--              faithful_round  select the faithful_rounding that admits 1 ulp error
--                              0 - default value. it keeps all rounding modes
--                              1 - z has 1 ulp error. RND input does not affect
--                                  the output
--
--              Input ports     Size & Description
--              ===========     ==================
--              a               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Input
--              b               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Input
--              rnd             3 bits
--                              Rounding Mode Input
--
--              Output ports    Size & Description
--              ============    ==================
--              z               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Output
--              status          8 bits
--                              Status Flags Output
--
--     Jan.  2. 2008 Kyung-Nam Han from 0712-SP1
--       New parameter, faithful_round, is introduced
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity DW_fp_div is

  generic(
    sig_width   : POSITIVE  := 23;
    exp_width   : POSITIVE   := 8;
    ieee_compliance: INTEGER   := 0;
    faithful_round : INTEGER   := 0
  );

  port(
    a        : in std_logic_vector(sig_width + exp_width downto 0);
    b        : in std_logic_vector(sig_width + exp_width downto 0);
    rnd      : in std_logic_vector(2 downto 0);
    z        : out std_logic_vector(sig_width + exp_width downto 0);
    status   : out std_logic_vector(7 downto 0)
  );

end DW_fp_div;



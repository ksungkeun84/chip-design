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
-- AUTHOR:    Kyung-Nam Han  Sep. 25, 2007
--
-- VERSION:   VHDL Entity for DW_fp_sincos
--
-- DesignWare_version: 90fe45ec
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--
-- ABSTRACT: Floating-Point Sine/Cosine Unit
--
--              DW_fp_sincos calculates the floating-point sine/cosine 
--              function. 
--
--              parameters      valid values (defined in the DW manual)
--              ==========      ============
--              sig_width       significand,  2 to 33 bits
--              exp_width       exponent,     3 to 31 bits
--              ieee_compliance support the IEEE Compliance 
--                              including NaN and denormal expressions.
--                              0 - MC (module compiler) compatible
--                              1 - IEEE 754 standard compatible
--              pi_multiple     angle is multipled by pi
--                              0 - sin(x) or cos(x)
--                              1 - sin(pi * x) or cos(pi * x)
--              arch            implementation select
--                              0 - area optimized (default)
--                              1 - speed optimized
--              err_range       error range of the result compared to the
--                              true result. It is effective only when arch = 0
--                              and 1, and ignored when arch = 2
--                              1 - 1 ulp error (default)
--                              2 - 2 ulp error
--
--              Input ports     Size & Description
--              ===========     ==================
--              a               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Input
--              sin_cos         1 bit
--                              Operator Selector
--                              0 - sine, 1 - cosine
--              z               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Output
--              status          8 bits
--                              Status Flags Output
--
-- MODIFIED: Kyung-Nam Han 07/23/08
--           Added two new parameters, arch and err_range
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity DW_fp_sincos is

  generic(
    sig_width      : POSITIVE  := 23;
    exp_width      : POSITIVE   := 8;
    ieee_compliance: INTEGER     := 0;
    pi_multiple    : INTEGER     := 1;
    arch           : INTEGER     := 0;
    err_range      : INTEGER     := 1;
    
    -- for the internal use
    rcp_margin_bit : INTEGER    := 5;
    round_nearest_pi : INTEGER   := 1
  );

  port(
    a        : in std_logic_vector(sig_width + exp_width downto 0);
    sin_cos  : in std_logic;
    z        : out std_logic_vector(sig_width + exp_width downto 0);
    status   : out std_logic_vector(7 downto 0)
  );

end DW_fp_sincos;



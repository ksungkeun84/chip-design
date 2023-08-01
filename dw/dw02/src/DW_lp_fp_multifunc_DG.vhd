--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2010 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Kyung-Nam Han  Oct. 22, 2010
--
-- VERSION:   VHDL Entity for DW_lp_fp_multifunc_DG
--
-- DesignWare_version: a0d6b08d
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--
-- ABSTRACT: Floating-point Multi-function Unit with Datapath Gating
--
--             DW_lp_fp_multifunc_DG calculates floating-point transcendental
--             functions with polynomial approximation methods.
--             Functions that are implemented include reciprocal, 
--             square root, inverse square root, trigonometric functions, 
--             logarithm and exponential function. All can be implemented 
--             in one unit, but user can choose some of them or just one 
--             function for the implementation.  The DG_ctrl input controls 
--             Datapath Gating.
--
--             parameters      valid values (defined in the DW manual)
--             ==========      ============
--             sig_width       significand size,  2 to 23 bits
--             exp_width       exponent size,     3 to 8 bits
--             ieee_compliance support the IEEE Compliance 
--                             0 - IEEE 754 compatible without denormal support
--                                 (NaN becomes Infinity, Denormal becomes Zero)
--                             1 - IEEE 754 compatible with denormal support
--                                 (NaN and denormal numbers are supported)
--             func_select     Select functions to be implemented
--                             16-bit binary parameter
--                             func_select[0]: reciprocal, 1/x
--                             func_select[1]: square root, sqrt(x)
--                             func_select[2]: inv. square root, 1/sqrt(x)
--                             func_select[3]: sine function, sin(pi*x)
--                             func_select[4]: cosine function, cos(pi*x)
--                             func_select[5]: base-2 log function, log2(x)
--                             func_select[6]: base-2 power function, 2^x
--                             func_select[7:15]: reserved
--             faithful_round  This parameter is only for FP reciprocal with
--                             func_select[0] = 1. It is for the compatibility 
--                             with faithful_round parameter of DW_fp_recip.
--                             0 - it keeps all rounding modes. 
--                             1 - Default value. 
--                                 z has 1 ulp error. RND input does not affect 
--                                 the output
--             pi_multiple     This parameter is only for FP sine and FP cosine
--                             with func_select[3] = 1 or func_select[4] = 1.
--                             angle of sine/cosine is multipled by pi
--                             0 - sin(x) or cos(x)
--                             1 - Default value.
--                                 sin(pi * x) or cos(pi * x)
--
--             Input ports     Size & Description
--             ===========     ==================
--             a               (sig_width + exp_width + 1) bits
--                             Floating-point Number Input
--             func            16-bit Function selection port
--                             Output function is determined by FUNC
--             rnd             Rounding mode.  It is only valid for 
--                             FP reciprocal with func_select[0] = 1 and 
--                             faithful_round = 0. Otherwise, rnd input is
--                             ignored. 
--             DG_ctrl         Datapath gating contro input
--                             1 bit (default is 1)
--
--             Output ports    Size & Description
--             ===========     ==================
--             z               (sig_width + exp_width + 1) bits
--                             Floating-point number output
--             status          8 bit
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity DW_lp_fp_multifunc_DG is

  generic(
    sig_width       : INTEGER   := 23;
    exp_width       : INTEGER    := 8;
    ieee_compliance : INTEGER    := 0;
    func_select     : INTEGER  := 127;
    faithful_round  : INTEGER    := 1;
    pi_multiple     : INTEGER    := 1
  );

  port(
    a        : in std_logic_vector(sig_width + exp_width downto 0);
    func     : in std_logic_vector(15 downto 0);
    rnd      : in std_logic_vector(2 downto 0);
    DG_ctrl  : in std_logic;
    z        : out std_logic_vector(sig_width + exp_width downto 0);
    status   : out std_logic_vector(7 downto 0)
  );

end DW_lp_fp_multifunc_DG;



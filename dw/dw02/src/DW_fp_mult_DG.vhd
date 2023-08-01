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
-- AUTHOR:    Alexandre Tenca October 12, 2009
--
-- VERSION:   VHDL Entity for DW_fp_mult_DG
--
-- DesignWare_version: 84393040
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
--
-- ABSTRACT: Floating-Point Multiplier with Datapath Gating
--
--              DW_fp_mult_DG calculates the floating-point multiplication
--              while supporting six rounding modes, including four IEEE
--              standard rounding modes. This version supports Datapath gating.
--              When the input DG_ctrl=0, the component has a fixed zero output,
--              and when DG_ctrl=1, the component behaves the same way as 
--              DW_fp_mult
--
--              parameters      valid values (defined in the DW manual)
--              ==========      ============
--              sig_width       significand size,  2 to 253 bits
--              exp_width       exponent size,     3 to 31 bits
--              ieee_compliance support the IEEE Compliance 
--                              including NaN and denormal expressions.
--                              0 - MC (module compiler) compatible
--                              1 - IEEE 754 standard compatible
--
--              Input ports     Size & Description
--              ===========     ==================
--              a               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Input
--              b               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Input
--              rnd             3 bits
--                              Rounding Mode Input
--              DG_ctrl         Datapath gating control
--                              1 bit  (default is value 1)
--              z               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Output
--              status          8 bits
--                              Status Flags Output
--
-------------------------------------------------------------------------------
-- Modified:   AFT 2009 - generated DG component from original component
--             created in 2006.
--
--
-------------------------------------------------------------------------------
--

library IEEE, DWARE;
use IEEE.std_logic_1164.all;

entity DW_fp_mult_DG is

  generic(
    sig_width   : POSITIVE  := 23;
    exp_width   : POSITIVE   := 8;
    ieee_compliance: INTEGER     := 0
  );

  port(
    a        : in std_logic_vector(sig_width + exp_width downto 0);
    b        : in std_logic_vector(sig_width + exp_width downto 0);
    rnd      : in std_logic_vector(2 downto 0);
    DG_ctrl  : in std_logic;
    z        : out std_logic_vector(sig_width + exp_width downto 0);
    status   : out std_logic_vector(7 downto 0)
  );

end DW_fp_mult_DG;


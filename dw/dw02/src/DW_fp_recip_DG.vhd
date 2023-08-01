
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
-- AUTHOR:    Alex Tenca and Kyung-Nam Han, May 2010
--
-- VERSION:   VHDL Entity for DW_fp_recip_DG
--
-- DesignWare_version: ff677044
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-- ABSTRACT: Floating-Point Reciprocal with Datapath Gating
--
--              DW_fp_recip_DG calculates the floating-point reciprocal
--              while supporting six rounding modes, including four IEEE
--              standard rounding modes.
--              When the DG_ctrl pin has a value 0 the component is disabled
--              to save power. 
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
--              faithful_round  admits 1 ulp error with less resources
--                              0 - support IEEE compatible rounding modes
--                              1 - result has 1 ulp error
--
--              Input ports     Size & Description
--              ===========     ==================
--              a               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Input
--              rnd             3 bits
--                              Rounding Mode Input
--              DG_ctrl         1 bit
--                              Datapath gating control (0 - disabled)
--              z               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Output
--              status          8 bits
--                              Status Flags Output
--
-- Modified:
--   06/13/09 Kyung-Nam Han (C-0906-SP1)
--     Removed Synplicity error with addr signal
--     Removed some LINT warnings at VCS and DC
--   05/2010 Alex Tenca - included basic datapath gating in the component
--           implementation. The original component was designed by Kyung-Nam
--           Han 
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity DW_fp_recip_DG is

  generic(
    sig_width      : POSITIVE  := 23;
    exp_width      : POSITIVE  := 8;
    ieee_compliance: INTEGER    := 0;
    faithful_round : INTEGER    := 0
  );

  port(
    a        : in std_logic_vector(sig_width + exp_width downto 0);
    rnd      : in std_logic_vector(2 downto 0);
    DG_ctrl  : in std_logic;     -- Datapath gating control pin
    z        : out std_logic_vector(sig_width + exp_width downto 0);
    status   : out std_logic_vector(7 downto 0)
  );

end DW_fp_recip_DG;



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
-- AUTHOR:    Alexandre Tenca   June 2008
--
-- VERSION:   VHDL Entity File for FP Natural Logarithm
--
-- DesignWare_version: e21b35ec
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--
-- ABSTRACT: Floating-point Natural Logarithm
--           Computes the natural logarithm of a FP number
--
--              parameters      valid values (defined in the DW manual)
--              ==========      ============
--              sig_width       significand size,  2 to 60 bits
--              exp_width       exponent size,     3 to 31 bits
--              ieee_compliance 0 or 1
--              extra_prec      0 to 60-sig_width bits
--              arch            implementation select
--                              0 - area optimized
--                              1 - speed optimized
--
--              Input ports     Size & Description
--              ===========     ==================
--              a               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Input
--
--              Output ports    Size & Description
--              ===========     ==================
--              z               (sig_width + exp_width + 1) bits
--                              Floating-point Number that represents ln(a)
--              status          byte
--                              Status information about FP operation
--
-- MODIFIED:
--           07/2015 - AFT - Star 9000927308
--              Modified the upper bound on the sig_width
--              parameter to avoid incorrect instance of DW_ln. This was found
--              after the problem listed in the Star document was fixed.
--
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity DW_fp_ln is
   generic(sig_width : POSITIVE := 10;
	   exp_width : POSITIVE  := 5;
           ieee_compliance : INTEGER  := 0;
           extra_prec : INTEGER  := 0;
           arch : INTEGER     := 0);
   port(a : in std_logic_vector(sig_width+exp_width downto 0);  -- FP input number
        z : out std_logic_vector(sig_width+exp_width downto 0); -- FP ln(a)
        status : out std_logic_vector(7 downto 0));
end DW_fp_ln;
 


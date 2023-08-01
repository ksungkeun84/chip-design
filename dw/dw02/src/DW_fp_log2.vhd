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
-- AUTHOR:    Alexandre Tenca   August 2007
--
-- VERSION:   VHDL Entity File for FP Base-2 Logarithm
--
-- DesignWare_version: bbb40cb9
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--
-- ABSTRACT: Floating-point Base-2 Logarithm
--           Computes the base-2 logarithm of a FP number
--
--              parameters      valid values (defined in the DW manual)
--              ==========      ============
--              sig_width       significand size,  2 to 60 bits
--              exp_width       exponent size,     3 to 31 bits
--              ieee_compliance 0 or 1
--              extra_prec      0 to 60-sig_width (default 0)
--              arch            implementation select
--                              0 - area optimized
--                              1 - speed optimized
--                              2 - 2007.12 implementation (default)
--
--              Input ports     Size & Description
--              ===========     ==================
--              a               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Input
--
--              Output ports    Size & Description
--              ===========     ==================
--              z               (sig_width + exp_width + 1) bits
--                              Floating-point Number that represents log2(a)
--              status          byte
--                              Status information about FP operation
--
-- MODIFIED:
--            10/10/2007 - AFT 
--               Included a new parameter to increase the internal precision.
--            09/2008 - AFT - included another parameter (arch) 
--            07/2015 - AFT - Star 9000926897
--               Reduced upper bound on the sig_width parameter
--
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity DW_fp_log2 is
   generic(sig_width : POSITIVE := 10;
	   exp_width : POSITIVE  := 5;
           ieee_compliance : INTEGER  := 0;
           extra_prec : INTEGER  := 0;
           arch : INTEGER     := 2);
   port(a : in std_logic_vector(sig_width+exp_width downto 0);  -- FP input number
        z : out std_logic_vector(sig_width+exp_width downto 0); -- FP log2(a)
        status : out std_logic_vector(7 downto 0));
end DW_fp_log2;
 


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
-- AUTHOR:    Alexandre Tenca   May 2008
--
-- VERSION:   VHDL Entity File for FP Exponential
--
-- DesignWare_version: 7de22af6
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--
-- ABSTRACT: Floating-point Exponential
--           Computes the exponential of a Floating-point number
--
--              parameters      valid values (defined in the DW manual)
--              ==========      ============
--              sig_width       significand size,  2 to 60 bits
--              exp_width       exponent size,     3 to 31 bits
--              ieee_compliance 0 or 1 (default 0)
--              arch            implementation select
--                              0 - area optimized
--                              1 - speed optimized
--                              2 - uses 2007.12 sub-components (default)
--
--              Input ports     Size & Description
--              ===========     ==================
--              a               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Input
--
--              Output ports    Size & Description
--              ===========     ==================
--              z               (sig_width + exp_width + 1) bits
--                              Floating-point Number that represents exp(a)
--              status          byte
--                              Status information about FP operation
--
-- MODIFIED:
--          August 2008 - AFT - included new parameter (arch)
--          07/2015 - AFT - Star 9000927859
--              Updated the upper bound of sig_width to 57 to avoid incorrect
--              instantiation of DW_exp2 (for value 58, 59 and 60).
--
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity DW_fp_exp is
   generic(sig_width : POSITIVE := 10;
	   exp_width : POSITIVE  := 5;
           ieee_compliance : INTEGER  := 0;
           arch : INTEGER     := 2);
   port(a : in std_logic_vector(sig_width+exp_width downto 0);  -- FP input number
        z : out std_logic_vector(sig_width+exp_width downto 0); -- FP exp(a)
        status : out std_logic_vector(7 downto 0));
end DW_fp_exp;
 


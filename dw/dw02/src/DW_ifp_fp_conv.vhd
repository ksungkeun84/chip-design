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
-- AUTHOR:    Alexandre Tenca   December 2007
--
-- VERSION:   VHDL Entity File for IFP to FP converter
--
-- DesignWare_version: c6663d45
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--
-- ABSTRACT: Floating-point internal format to IEEE format converter
--              parameters      valid values (defined in the DW manual)
--              ==========      ============
--              sig_widthi      significand size,  2 to 253 bits
--              exp_widthi      exponent size,     3 to 31 bits
--              sig_width       significand size,  2 to 253 bits
--              exp_width       exponent size,     3 to 31 bits
--              use_denormal    0 or 1  (default 0)
--
--              Input ports     Size & Description
--              ===========     ==================
--              a               (sig_widthi + exp_widthi + 7)-bits
--                              Internal Floating-point Number Input
--              rnd             3 bits
--                              Rounding mode
--
--              Output ports    Size & Description
--              ===========     ==================
--              z               (sig_width + exp_width + 1) bits
--                              IEEE Floating-point Number
--              status          8 bits
--                              Status information about FP number
--
-- MODIFIED: 
--
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity DW_ifp_fp_conv is
   generic(sig_widthi : POSITIVE := 25;
	   exp_widthi : POSITIVE   := 8;
           sig_width  : POSITIVE  := 23;
	   exp_width  : POSITIVE   := 8;
           use_denormal : INTEGER  := 0);
   port(a : in std_logic_vector(sig_widthi+exp_widthi+7-1 downto 0); -- IFP number
        rnd : in std_logic_vector(2 downto 0);                     -- rounding mode
        z : out std_logic_vector(sig_width+exp_width downto 0);    -- IEEE FP number
        status : out std_logic_vector(7 downto 0));
end DW_ifp_fp_conv;
 


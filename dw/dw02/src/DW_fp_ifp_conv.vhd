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
-- VERSION:   VHDL Entity File for FP to IFP converter
--
-- DesignWare_version: 0c13e517
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--
-- ABSTRACT: Floating-point format to internal format converter
--              parameters      valid values (defined in the DW manual)
--              ==========      ============
--              sig_widthi      significand size,  2 to 253 bits
--              exp_widthi      exponent size,     3 to 31 bits
--              sig_widtho      significand size,  sig_widthi+2 to 253 bits
--              exp_widtho      exponent size,     exp_widthi to 31 bits
--              use_denormal    0 or 1  (default 0)
--              use_1scmpl      0 or 1  (default 0)
--
--              Input ports     Size & Description
--              ===========     ==================
--              a               (sig_widthi + exp_widthi + 1)-bits
--                              Floating-point Number Input
--
--              Output ports    Size & Description
--              ===========     ==================
--              z               (sig_widtho + exp_widtho + 7) bits
--                              Internal Floating-point Number
--
-- MODIFIED: 
--
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity DW_fp_ifp_conv is
   generic(sig_widthi : POSITIVE := 23;
	   exp_widthi : POSITIVE   := 8;
           sig_widtho : POSITIVE  := 25;
	   exp_widtho : POSITIVE   := 8;
           use_denormal : INTEGER  := 0;
           use_1scmpl : INTEGER  := 0);
   port(a : in std_logic_vector(sig_widthi+exp_widthi downto 0);   -- FP number
        z : out std_logic_vector(sig_widtho+exp_widtho+7-1 downto 0) -- Internal FP number
        );
end DW_fp_ifp_conv;
 


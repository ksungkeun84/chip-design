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
-- VERSION:   VHDL Entity File for FP Adder/Subtractor -- Internal FP format
--
-- DesignWare_version: b0b79a06
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--
-- ABSTRACT: Floating-point two-operand Adder/Subtractor in Internal FP format
--           Computes the addition/subtraction of two FP numbers in internal
--           (proprietary) FP format. 
--           The format of the FP numbers is defined by the number of bits 
--           in the significand (sig_width) and the number of bits in the 
--           exponent (exp_width). The internal format uses status (7 bits),
--           exponent, and significand fields. The significand is expressed 
--           in two's complement. 
--           The total number of bits in the FP number is sig_width+exp_width+7
--           The output follows the same format.
--           Subtraction is forced when op=1
--           Althought rounding is not done, the sign of zeros requires this
--           information.
--              parameters      valid values (defined in the DW manual)
--              ==========      ============
--              sig_widthi      significand size of the input,  2 to 253 bits
--              exp_widthi      exponent size of the input,     3 to 31 bits
--              sig_widtho      significand size of the output, 2 to 253 bits
--              exp_widtho      exponent size of the output,    3 to 31 bits
--              use_denormal    0 to 1 (default 0)
--              use_1scmpl      0 or 1  (default 0)
--
--              Input ports     Size & Description
--              ===========     ==================
--              a               (sig_widthi + exp_widthi + 7)-bits
--                              Floating-point Number Input
--              b               (sig_widthi + exp_widthi + 7)-bits
--                              Floating-point Number Input
--              op              1 bit
--                              add/sub control: 0 for add - 1 for sub
--              rnd             3 bits
--                              Rounding mode
--
--              Output ports    Size & Description
--              ===========     ==================
--              z               (sig_widtho + exp_widtho + 7) bits
--                              Floating-point Number result
--
-- MODIFIED: 
--
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;


entity DW_ifp_addsub is
   generic(sig_widthi : POSITIVE := 23;
	   exp_widthi : POSITIVE   := 8;
           sig_widtho : POSITIVE  := 23;
	   exp_widtho : POSITIVE   := 8;
           use_denormal : INTEGER  := 0;
           use_1scmpl : INTEGER  := 0
           );
   port(a : in std_logic_vector(sig_widthi+exp_widthi+7-1 downto 0);   -- 1st FP number
        b : in std_logic_vector(sig_widthi+exp_widthi+7-1 downto 0);   -- 2nd FP number
        op : in std_logic;       -- add/sub control: 0 for add - 1 for sub
        rnd : in std_logic_vector(2 downto 0);  -- rounding mode
        z : out std_logic_vector(sig_widtho+exp_widtho+7-1 downto 0)   -- FP result
        );
end DW_ifp_addsub;
 


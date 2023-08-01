--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2006 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Alexandre Tenca   February 2006
--
-- VERSION:   VHDL Entity File for 4-operand FP Sum
--
-- DesignWare_version: df2e3a4f
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--
-- ABSTRACT: Four-operand Floating-point Adder (SUM4)
--           Computes the addition of four FP numbers. The format of the FP
--           numbers is defined by the number of bits in the significand 
--           (sig_width) and the number of bits in the exponent (exp_width).
--           The total number of bits in each FP number is sig_width+exp_width+1.
--           The sign bit takes the place of the MS bit in the significand,
--           which is always 1 (unless the number is a denormal; a condition 
--           that can be detected testing the exponent value).
--           The outputs are a FP number and status flags with information about
--           special number representations and exceptions. 
--              parameters      valid values (defined in the DW manual)
--              ==========      ============
--              sig_width       significand f,  2 to 253 bits
--              exp_width       exponent e,     3 to 31 bits
--              ieee_compliance 0 or 1 (default 0)
--              arch_type       0 or 1 (default 0)
--
--              Input ports     Size & Description
--              ===========     ==================
--              a               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Input
--              b               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Input
--              c               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Input
--              d               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Input
--              rnd             3 bits
--                              rounding mode
--
--              Output ports    Size & Description
--              ===========     ==================
--              z               (sig_width + exp_width + 1) bits
--                              Floating-point Number -> a+b+c
--              status          byte
--                              info about FP result
--
-- MODIFIED:
--          AFT 03/08: included a new parameter (arch_type) to control
--                     the use of alternative architecture with IFP blocks
--         12/11/2008: expanded the use of IFP components to accept 
--                     ieee_compliance=1
--
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity DW_fp_sum4 is
   generic(sig_width : POSITIVE := 23;
	   exp_width : POSITIVE  := 8;
           ieee_compliance : INTEGER  := 0;
           arch_type : INTEGER  := 0);
   port(a : in std_logic_vector(sig_width+exp_width downto 0);   -- 1st FP number
        b : in std_logic_vector(sig_width+exp_width downto 0);   -- 2nd FP number
        c : in std_logic_vector(sig_width+exp_width downto 0);   -- 3rd FP number
        d : in std_logic_vector(sig_width+exp_width downto 0);   -- 4th FP number
	rnd : in std_logic_vector(2 downto 0);              -- rounding
        z : out std_logic_vector(sig_width+exp_width downto 0);  -- FP result
        status : out std_logic_vector(7 downto 0));
end DW_fp_sum4;
 


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
-- AUTHOR:    Alexandre Tenca   October 2006
--
-- VERSION:   VHDL Entity File for FP 4-Term Dot-product
--
-- DesignWare_version: ba3ddecd
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--
-- ABSTRACT: Floating-point Fourt-term Dot-product
--           Computes the sum of products of FP numbers. For this component,
--           four products are considered. Given the FP inputs a, b, c, d, e
--           f, g and h, it computes the FP output z = a*b + c*d + e*f + g*h. 
--           The format of the FP numbers is defined by the number of bits 
--           in the significand (sig_width) and the number of bits in the 
--           exponent (exp_width).
--           The total number of bits in the FP number is sig_width+exp_width+1
--           since the sign bit takes the place of the MS bits in the significand
--           which is always 1 (unless the number is a denormal; a condition 
--           that can be detected testing the exponent value).
--           The output is a FP number and status flags with information about
--           special number representations and exceptions. Rounding mode may 
--           also be defined by an input port.
--              parameters      valid values (defined in the DW manual)
--              ==========      ============
--              sig_width       significand,  2 to 253 bits
--              exp_width       exponent,     3 to 31 bits
--              ieee_compliance 0 or 1 (default 0)
--              arch_type       0 or 1 (default 0)
--
--              Input ports     Size & Description
--              ===========     ==================
--              a               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Input
--              b               (sig_width + exp_width) + 1-bits
--                              Floating-point Number Input
--              c               (sig_width + exp_width) + 1-bits
--                              Floating-point Number Input
--              d               (sig_width + exp_width) + 1-bits
--                              Floating-point Number Input
--              e               (sig_width + exp_width) + 1-bits
--                              Floating-point Number Input
--              f               (sig_width + exp_width) + 1-bits
--                              Floating-point Number Input
--              g               (sig_width + exp_width) + 1-bits
--                              Floating-point Number Input
--              h               (sig_width + exp_width) + 1-bits
--                              Floating-point Number Input
--              rnd             3 bits
--                              rounding mode
--
--              Output ports    Size & Description
--              ===========     ==================
--              z               (sig_width + exp_width + 1) bits
--                              Floating-point Number result that corresponds
--                              to a*b+c*d+e*f+g*h
--              status          byte
--                              info about FP results
--
-- MODIFIED:
--           04/2008 - AFT - included parameter arch_type to control the use
--                     of internal floating-point format blocks
--           01/2009 - AFT - expanded the range of parameters to accept
--                     ieee_compliance=1 when arch_type=1
--
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity DW_fp_dp4 is
   generic(sig_width :       POSITIVE := 23;
	   exp_width :       POSITIVE := 8;
           ieee_compliance : INTEGER  := 0;
           arch_type :       INTEGER  := 0);
   port(a : in std_logic_vector(sig_width+exp_width downto 0);   -- 1st FP number
        b : in std_logic_vector(sig_width+exp_width downto 0);   -- 2nd FP number
        c : in std_logic_vector(sig_width+exp_width downto 0);   -- 3rd FP number
        d : in std_logic_vector(sig_width+exp_width downto 0);   -- 4th FP number
        e : in std_logic_vector(sig_width+exp_width downto 0);   -- 5th FP number
        f : in std_logic_vector(sig_width+exp_width downto 0);   -- 6th FP number
        g : in std_logic_vector(sig_width+exp_width downto 0);   -- 7th FP number
        h : in std_logic_vector(sig_width+exp_width downto 0);   -- 8th FP number
	rnd : in std_logic_vector(2 downto 0);   -- rounding
        z : out std_logic_vector(sig_width+exp_width downto 0);  -- FP result
        status : out std_logic_vector(7 downto 0));
end DW_fp_dp4;
 


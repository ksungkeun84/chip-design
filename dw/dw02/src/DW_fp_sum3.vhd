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
-- VERSION:   VHDL Entity File for 3-operand FP sum
--
-- DesignWare_version: 273c5cda
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--
-- ABSTRACT: Three-operand Floating-point Adder (SUM3)
--           Computes the addition of three FP numbers. The format of the FP
--           numbers is defined by the number of bits in the significand 
--           (sig_width) and the number of bits in the exponent (exp_width).
--           The outputs are a FP number and status flags with information 
--           about special number representations and exceptions. 
--
--              parameters      valid values (defined in the DW manual)
--              ==========      ============
--              sig_width       significand size,  2 to 253 bits
--              exp_width       exponent size,     3 to 31 bits
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
--
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity DW_fp_sum3 is
   generic(sig_width : POSITIVE := 23;
           exp_width : POSITIVE   := 8;
           ieee_compliance : INTEGER  := 0;
           arch_type : INTEGER  := 0);
   port(a : in std_logic_vector(sig_width+exp_width downto 0);   -- 1st FP number
        b : in std_logic_vector(sig_width+exp_width downto 0);   -- 2nd FP number
        c : in std_logic_vector(sig_width+exp_width downto 0);   -- 3rd FP number
        rnd : in std_logic_vector(2 downto 0);                   -- rounding
        z : out std_logic_vector(sig_width+exp_width downto 0);  -- FP result
        status : out std_logic_vector(7 downto 0));
end DW_fp_sum3;
 


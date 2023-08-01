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
-- AUTHOR:    Alexandre Tenca   April 2006
--
-- VERSION:   VHDL Entity File for FP Comparator
--
-- DesignWare_version: 20e9a7fc
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--
-- ABSTRACT: Floating-point Comparator
--           Compares two FP numbers and generates outputs that indicate when 
--           A>B, A<B and A=B. The component also provides outputs for MAX and 
--           MIN values, with corresponding status flags.
--
--              parameters      valid values (defined in the DW manual)
--              ==========      ============
--              sig_width       significand size,  2 to 253 bits
--              exp_width       exponent size,     3 to 31 bits
--              ieee_compliance 0 or 1
--
--              Input ports     Size & Description
--              ===========     ==================
--              a               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Input
--              b               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Input
--              zctr            1 bit
--                              defines the min/max operation of z0 and z1
--
--              Output ports    Size & Description
--              ===========     ==================
--              aeqb            1 bit
--                              has value 1 when a=b
--              altb            1 bit
--                              has value 1 when a<b
--              agtb            1 bit
--                              has value 1 when a>b
--              unordered       1 bit
--                              one of the inputs is NaN
--              z0              (sig_width + exp_width + 1) bits
--                              Floating-point Number that has max(a,b) when
--                              zctr=1, and min(a,b) otherwise
--              z1              (sig_width + exp_width + 1) bits
--                              Floating-point Number that has max(a,b) when
--                              zctr=0, and min(a,b) otherwise
--              status0         byte
--                              info about FP value in z0
--              status1         byte
--                              info about FP value in z1
--
-- MODIFIED:
--
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity DW_fp_cmp is
   generic(sig_width : POSITIVE := 23;
	   exp_width : POSITIVE := 8;
           ieee_compliance : INTEGER := 0);
   port(a : in std_logic_vector(sig_width+exp_width downto 0);  -- 1st FP number
        b : in std_logic_vector(sig_width+exp_width downto 0);  -- 2nd FP number
        zctr : in std_logic;                                    -- output control
        aeqb : out std_logic;                                   -- output a=b
        altb : out std_logic;                                   -- output a<b
        agtb : out std_logic;                                   -- output a>b
        unordered : out std_logic;                              -- output when NaN input
        z0 : out std_logic_vector(sig_width+exp_width downto 0);-- FP max/min result
        z1 : out std_logic_vector(sig_width+exp_width downto 0);-- FP max/min result
        status0 : out std_logic_vector(7 downto 0);
        status1 : out std_logic_vector(7 downto 0));
end DW_fp_cmp;
 


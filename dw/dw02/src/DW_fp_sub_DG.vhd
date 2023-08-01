--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2009 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Alexandre Tenca   September 2009
--
-- VERSION:   VHDL Entity File for FP Subtractor with Datapath gating
--
-- DesignWare_version: f537830a
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
-- ABSTRACT: Floating-point two-operand Subtractor with Datapath Gating
--           Computes the subtraction of two FP numbers.
--           For information about FP subtraction, please, look at the description
--           of DW_fp_sub. This component has an extra control port that disables
--           the components functionality in order to save power. The control port
--           is DG_ctrl. Whe DG_ctrl is set to 0, the component will not operate,
--           reducing dynamic power (datapath gating). When DG_ctrl is set to 1,
--           the component works as DW_fp_sub.
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
--              rnd             3 bits
--                              rounding mode
--              DG_ctrl          1 bit
--                              controls the use of datapath gating
--
--              Output ports    Size & Description
--              ===========     ==================
--              z               (sig_width + exp_width + 1) bits
--                              Floating-point Number result
--              status          byte
--                              info about FP results
--
--
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity DW_fp_sub_DG is
   generic(sig_width : POSITIVE := 23;
	   exp_width : POSITIVE := 8;
           ieee_compliance : INTEGER := 0);
   port(a : in std_logic_vector(sig_width+exp_width downto 0);   -- 1st FP number
        b : in std_logic_vector(sig_width+exp_width downto 0);   -- 2nd FP number
	rnd : in std_logic_vector(2 downto 0);   -- rounding
        DG_ctrl : in std_logic;                   -- datapath gating control
        z : out std_logic_vector(sig_width+exp_width downto 0);  -- FP result
        status : out std_logic_vector(7 downto 0));
end DW_fp_sub_DG;
 


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
-- AUTHOR:    Alexandre Tenca   August 2009
--
-- VERSION:   VHDL Entity File for FP Adder/Subtractor with Datapath gating
--
-- DesignWare_version: 622f4627
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--
-- ABSTRACT: Floating-point two-operand Adder/Subtractor with Datapath gating
--           This component is in fact an extension of the floating point adder
--           that allows isolation of signals when the DG_ctrl input is set to 0.
--           When the DG_ctrl is set to 1, the component works the same way as the
--           DW_fp_addsub previously released. When DG_ctrl = 0 the output is a 
--           zero with appropriate status bits. The use of this option will  
--           reduce dynamic power consumption when the input is not processed. 
--           For more description about the FP addsub, please, refer to the 
--           documentation and files of DW_fp_addsub.
--              parameters      valid values (defined in the DW manual)
--              ==========      ============
--              sig_width       significand size,  2 to 253 bits
--              exp_width       exponent size,     3 to 31 bits
--              ieee_compliance 0 or 1  (default 0)
--
--              Input ports     Size & Description
--              ===========     ==================
--              a               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Input
--              b               (sig_width + exp_width) + 1-bits
--                              Floating-point Number Input
--              rnd             3 bits
--                              rounding mode
--              op              1 bit
--                              add/sub control: 0 for add - 1 for sub
--              DG_ctrl         1 bit
--                              datapath gating control: 0 - isolate inputs
-- 
--              Output ports    Size & Description
--              ===========     ==================
--              z               (sig_width + exp_width + 1) bits
--                              Floating-point Number result
--              status          byte
--                              info about FP results
--
-- MODIFIED: 
--
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity DW_fp_addsub_DG is
   generic(sig_width : POSITIVE := 23;
	   exp_width : POSITIVE   := 8;
           ieee_compliance : INTEGER  := 0);
   port(a : in std_logic_vector(sig_width+exp_width downto 0);   -- 1st FP number
        b : in std_logic_vector(sig_width+exp_width downto 0);   -- 2nd FP number
	rnd : in std_logic_vector(2 downto 0);   -- rounding
        op : in std_logic;       -- add/sub control: 0 for add - 1 for sub
        DG_ctrl : in std_logic;   -- datapath gating control: 0 = isolate inputs
        z : out std_logic_vector(sig_width+exp_width downto 0);  -- FP result
        status : out std_logic_vector(7 downto 0));
end DW_fp_addsub_DG;
 


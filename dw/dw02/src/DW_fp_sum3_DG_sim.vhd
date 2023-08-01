--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2010 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Alexandre F. Tenca  January 2010
--
-- VERSION:   VHDL Simulation Model - FP SUM3 with DG
--
-- DesignWare_version: 84ee9c96
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--
-- ABSTRACT: Three-operand Floating-point Adder (SUM3) with Datapath gating
--           Computes the addition of three FP numbers. The format of the FP
--           numbers is defined by the number of bits in the significand 
--           (sig_width) and the number of bits in the exponent (exp_width).
--           The outputs are a FP number and status flags with information 
--           about special number representations and exceptions. 
--           A DG_ctrl port controls if the component has its inputs isolated
--           of not. When this input is '1' the component behaves as the 
--           DW_fp_sum3.
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
--              DG_ctrl         1 bit
--                              Datapath gating control (1 - normal operation)
--
--              Output ports    Size & Description
--              ===========     ==================
--              z               (sig_width + exp_width + 1) bits
--                              Floating-point Number -> a+b+c
--              status          byte
--                              info about FP result
--
-- MODIFIED:
---------------------------------------------------------------------------------

library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use DWARE.DW_Foundation_comp_arith.all;

architecture sim of DW_fp_sum3_DG is
	
-- pragma translate_off


signal z_int : std_logic_vector(exp_width+sig_width downto 0);
signal status_int : std_logic_vector(7 downto 0);

-- pragma translate_on
begin
-- pragma translate_off
  
    
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
    
    if ( (sig_width < 2) OR (sig_width > 253) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter sig_width (legal range: 2 to 253)"
        severity warning;
    end if;
    
    if ( (exp_width < 3) OR (exp_width > 31) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter exp_width (legal range: 3 to 31)"
        severity warning;
    end if;
    
    if ( (ieee_compliance < 0) OR (ieee_compliance > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter ieee_compliance (legal range: 0 to 1)"
        severity warning;
    end if;
    
    if ( (arch_type < 0) OR (arch_type > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter arch_type (legal range: 0 to 1)"
        severity warning;
    end if;
    
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;  

  -- instantiate the DW_fp_sum3 component for simulation
  -- with DG_ctrl input controlling the output
  U1 : DW_fp_sum3 generic map (sig_width => sig_width,
                               exp_width => exp_width,
                               ieee_compliance => ieee_compliance,
                               arch_type => arch_type)
               port map (a => a,             -- 1st FP number
                         b => b,             -- 2nd FP number
                         c => c,             -- 3rd FP number
                         rnd => rnd,         -- rounding mode
                         z => z_int,         -- FP result
                         status => status_int
                         );

  z <= z_int when (DG_ctrl = '1') else (others => 'X');
  status <= status_int when (DG_ctrl = '1') else (others => 'X');

-- pragma translate_on

end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

library dw02;

configuration DW_fp_sum3_DG_cfg_sim of DW_fp_sum3_DG is
 for sim
  for U1 : DW_fp_sum3 use configuration dw02.DW_fp_sum3_cfg_sim; end for;
 end for; -- sim
end DW_fp_sum3_DG_cfg_sim;
-- pragma translate_on

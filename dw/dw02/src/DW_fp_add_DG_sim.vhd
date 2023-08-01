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
-- AUTHOR:    Alexandre F. Tenca
--
-- VERSION:   VHDL Simulation Model - FP Add with Datapath Gating
--
-- DesignWare_version: 93100b57
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--
-- ABSTRACT: Floating-point two-operand Adder with Datapath Gating
--           Computes the addition of two FP numbers. 
--           For information about FP addition, please, look at the description
--           of DW_fp_add. This component has an extra control port that disables
--           the components functionality in order to save power. The control port
--           is DG_ctrl. Whe DG_ctrl is set to 0, the component will not operate,
--           reducing dynamic power (datapath gating). When DG_ctrl is set to 1, 
--           the component works as DW_fp_add.
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
--              DG_ctrl         1 bit
--                              controls the use of datapath gating
--
--              Output ports    Size & Description
--              ===========     ==================
--              z               (sig_width + exp_width + 1) bits
--                              Floating-point Number result
--              status          byte
--                              info about FP results
--
---------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
--
-- MODIFIED:
--
---------------------------------------------------------------------------------

library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DW_Foundation_comp_arith.all;

architecture sim of DW_fp_add_DG is
	
-- pragma translate_off

signal zero : std_logic := '0';

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
    
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;  

-- instantiate the DW_fp_addsub component for simulation
-- with op input connected to '0'
U1 : DW_fp_addsub_DG generic map (sig_width => sig_width,
	                          exp_width => exp_width,
	                          ieee_compliance => ieee_compliance)
               port map (a => a,             -- 1st FP number
                         b => b,             -- 2nd FP number
	                 rnd => rnd,         -- rounding mode
                         op => zero,         -- add/sub control: 0 for add
                         DG_ctrl => DG_ctrl, -- datapath gating control
                         z => z,             -- FP result
                         status => status
                         );

-- pragma translate_on  

end sim ;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

library dw02;

configuration DW_fp_add_DG_cfg_sim of DW_fp_add_DG is
 for sim
for U1 : DW_fp_addsub_DG use configuration dw02.DW_fp_addsub_DG_cfg_sim; end for;
 end for; -- sim
end DW_fp_add_DG_cfg_sim;
-- pragma translate_on

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
-- AUTHOR:    Alex Tenca and Kyung-Nam Han  May 2010
--
-- VERSION:   VHDL Simulation model for DW_fp_recip_DG
--
-- DesignWare_version: 96347f0a
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--
-- ABSTRACT: Floating-Point Reciprocal with Datapath Gating
--
--              DW_fp_recip_DG calculates the floating-point reciprocal
--              while supporting six rounding modes, including four IEEE
--              standard rounding modes.
--              When the DG_ctrl pin has a value 0 the component is disabled
--              to save power. 
--
--              parameters      valid values (defined in the DW manual)
--              ==========      ============
--              sig_width       significand size,  2 to 60 bits
--              exp_width       exponent size,     3 to 31 bits
--              ieee_compliance support the IEEE Compliance 
--                              0 - IEEE 754 compatible without denormal support
--                                  (NaN becomes Infinity, Denormal becomes Zero)
--                              1 - IEEE 754 compatible with denormal support
--                                  (NaN and denormal numbers are supported)
--              faithful_round  admits 1 ulp error with less resources
--                              0 - support IEEE compatible rounding modes
--                              1 - result has 1 ulp error
--
--              Input ports     Size & Description
--              ===========     ==================
--              a               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Input
--              rnd             3 bits
--                              Rounding Mode Input
--              DG_ctrl         1 bit
--                              Datapath gating control (0 - disabled)
--              z               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Output
--              status          8 bits
--                              Status Flags Output
--
-- Modified:
--   06/13/09 Kyung-Nam Han (C-0906-SP1)
--     Removed Synplicity error with addr signal
--     Removed some LINT warnings at VCS and DC
--   05/2010 Alex Tenca - included basic datapath gating in the component
--           implementation. The original component was designed by Kyung-Nam
--           Han 
-------------------------------------------------------------------------------


library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DW_Foundation_comp.all;


architecture sim of DW_fp_recip_DG is
	

-- pragma translate_off


signal l0OO0l01 : std_logic_vector(exp_width+sig_width downto 0);
signal llO0llI0 : std_logic_vector(7 downto 0);

-- pragma translate_on
 
begin

-- pragma translate_off
  
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
     
    if ( (sig_width < 2) OR (sig_width > 60) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter sig_width (legal range: 2 to 60)"
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
     
    if ( (faithful_round < 0) OR (faithful_round > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter faithful_round (legal range: 0 to 1)"
        severity warning;
    end if;
  
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;

    -- Instance of DW_fp_recip
    U1 : DW_fp_recip
        generic map (
                sig_width => sig_width,
                exp_width => exp_width,
                ieee_compliance => ieee_compliance,
                faithful_round => faithful_round
                )
        port map (
                a => a,
                rnd => rnd,
                z => l0OO0l01,
                status => llO0llI0
                );

  z <= l0OO0l01 when (DG_ctrl = '1') else (others => 'X');
  status <= llO0llI0 when (DG_ctrl = '1') else (others => 'X');

-- pragma translate_on

end sim;


--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

library dw02;

configuration DW_fp_recip_DG_cfg_sim of DW_fp_recip_DG is
 for sim
    for U1 : DW_fp_recip use configuration dw02.DW_fp_recip_cfg_sim; end for;
 end for; -- sim
end DW_fp_recip_DG_cfg_sim;
-- pragma translate_on

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
-- AUTHOR:    Alex Tenca, January 2010
--
-- VERSION:   VHDL Simulation Model for DW_fp_div with Datapath Gating
--
-- DesignWare_version: 5e27cf5a
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-- ABSTRACT: Floating-Point Divider wih Datapath Gating
--
--              DW_fp_div_DG calculates the floating-point division
--              while supporting six rounding modes, including four IEEE
--              standard rounding modes.
--              The DG_ctrl pin controls the isolation of signals. When this pin
--              has a '1' the component behaves exactly as the DW_fp_div.
--
--              parameters      valid values (defined in the DW manual)
--              ==========      ============
--              sig_width       significand size,  2 to 253 bits
--              exp_width       exponent size,     3 to 31 bits
--              ieee_compliance support the IEEE Compliance 
--                              0 - IEEE 754 compatible without denormal support
--                                  (NaN becomes Infinity, Denormal becomes Zero)
--                              1 - IEEE 754 compatible with denormal support
--                                  (NaN and denormal numbers are supported)
--              faithful_round  select the faithful_rounding that admits 1 ulp error
--                              0 - default value. it keeps all rounding modes
--                              1 - z has 1 ulp error. RND input does not affect
--                                  the output
--
--              Input ports     Size & Description
--              ===========     ==================
--              a               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Input
--              b               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Input
--              rnd             3 bits
--                              Rounding Mode Input
--              DG_ctrl         1 bit
--                              Datapath gating control (1 - normal operation)
--
--              Output ports    Size & Description
--              ============    ==================
--              z               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Output
--              status          8 bits
--                              Status Flags Output
--
-- MODIFIED: 
--
-------------------------------------------------------------------------------

library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use DWARE.DW_Foundation_comp_arith.all;

architecture sim of DW_fp_div_DG is
	
-- pragma translate_off


signal ll0IO101 : std_logic_vector(exp_width+sig_width downto 0);
signal Il0l00OO : std_logic_vector(7 downto 0);

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

  -- Instance of DW_fp_div
  U1 : DW_fp_div
       generic map ( sig_width => sig_width, 
                      exp_width => exp_width, 
                      ieee_compliance => ieee_compliance, 
                      faithful_round => faithful_round )
        port map ( a => a, 
                   b => b, 
                   rnd => rnd, 
                   z => ll0IO101, 
                   status => Il0l00OO );

  z <= ll0IO101 when (DG_ctrl = '1') else (others => 'X');
  status <= Il0l00OO when (DG_ctrl = '1') else (others => 'X');

  -- pragma translate_on

end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

library dw02;

configuration DW_fp_div_DG_cfg_sim of DW_fp_div_DG is
 for sim
  for U1 : DW_fp_div use configuration dw02.DW_fp_div_cfg_sim; end for;
 end for; -- sim
end DW_fp_div_DG_cfg_sim;
-- pragma translate_on

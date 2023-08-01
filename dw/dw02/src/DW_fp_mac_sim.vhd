
--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2007 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Kyung-Nam Han, Mar. 9, 2007
--
-- VERSION:   VHDL Simulation Model for DW_fp_mac
--
-- DesignWare_version: 224d9f09
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--
-- ABSTRACT: Floating-Point MAC (Multiply and Add, a * b + c)
--
--              DW_fp_mac calculates the floating-point multiplication and
--              addition (ab + c),
--              while supporting six rounding modes, including four IEEE
--              standard rounding modes.
--
--              parameters      valid values (defined in the DW manual)
--              ==========      ============
--              sig_width       significand size,  2 to 253 bits
--              exp_width       exponent size,     3 to 31 bits
--              ieee_compliance support the IEEE Compliance 
--                              including NaN and denormal expressions.
--                              0 - IEEE 754 compatible without denormal support
--                                  (NaN becomes Infinity, Denormal becomes Zero)
--                              1 - IEEE 754 standard compatible
--                                  (NaN and denormal numbers are supported)
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
--                              Rounding Mode Input
--              z               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Output
--              status          8 bits
--                              Status Flags Output
--
-------------------------------------------------------------------------------

library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DW_Foundation.all;
use DWARE.DW_Foundation_comp_arith.all;

architecture sim of DW_fp_mac is

  -- pragma translate_off



  signal one : std_logic_vector(exp_width + sig_width downto 0);
  signal one_sig : std_logic_vector(sig_width - 1 downto 0);
  signal one_exp : std_logic_vector(exp_width - 1 downto 0);
  signal ones_temp : std_logic_vector(exp_width - 2 downto 0);

  -- pragma translate_on

  ----------------------------------------------------------------------
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

  ones_temp <= (others => '1');
  one_exp <= '0' & ones_temp;
  one_sig <= (others => '0');
  one <= '0' & one_exp & one_sig;

  -- DW_fp_dp2(a, b, c, 1) = ab + c
  U1 : DW_fp_dp2
    generic map (
            sig_width => sig_width,
            exp_width => exp_width,
            ieee_compliance => ieee_compliance
            )
    port map (
            a => a,
            b => b,
            c => c,
            d => one,
            rnd => rnd,
            z => z,
            status => status
            );

  -- pragma translate_on

end sim;

  -- pragma translate_off
library dw02;
configuration DW_fp_mac_cfg_sim of DW_fp_mac is
 for sim
  for U1 : DW_fp_dp2 use configuration dw02.DW_fp_dp2_cfg_sim; end for;
 end for; -- sim
end DW_fp_mac_cfg_sim;
  -- pragma translate_on


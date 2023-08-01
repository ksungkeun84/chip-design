--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2005 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Alexandre F. Tenca
--
-- VERSION:   VHDL Simulation Model - FP Add
--
-- DesignWare_version: 65d9828e
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------

----------------------------------------------------------------------------------
--
-- ABSTRACT: Floating-point two-operand Adder
--           Computes the addition of two FP numbers. 
--           The format of the FP numbers is defined by the number of bits 
--           in the significand (sig_width) and the number of bits in the 
--           exponent (exp_width). 
--           The total number of bits in the FP number is sig_width+exp_width
--           since the sign bit takes the place of the MS bits in the significand
--           which is always 1 (unless the number is a denormal; a condition 
--           that can be detected testing the exponent value).
--           The output is a FP number and status flags with information about
--           special number representations and exceptions. 
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
--              rnd        3 bits
--                              rounding mode
--
--              Output ports    Size & Description
--              ===========     ==================
--              z               (sig_width + exp_width + 1) bits
--                              Floating-point Number result
--              status_flags    byte
--                              info about FP results
--
--
-- MODIFIED:
--
---------------------------------------------------------------------------------

library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DW_Foundation_comp_arith.all;

architecture sim of DW_fp_add is
	
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
U1 : DW_fp_addsub generic map (sig_width => sig_width,
	                       exp_width => exp_width,
	                       ieee_compliance => ieee_compliance)
               port map (a => a,   -- 1st FP number
                         b => b,   -- 2nd FP number
	                 rnd => rnd,  -- rounding mode
                         op => zero,  -- add/sub control: 0 for add - 1 for sub
                         z => z,    -- FP result
                         status => status
                         );

-- pragma translate_on  

end sim ;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

library dw02;

configuration DW_fp_add_cfg_sim of DW_fp_add is
 for sim
for U1 : DW_fp_addsub use configuration dw02.DW_fp_addsub_cfg_sim; end for;
 end for; -- sim
end DW_fp_add_cfg_sim;
-- pragma translate_on


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
-- AUTHOR:    Kyung-Nam Han   Nov. 07, 2006
--
-- VERSION:   VHDL Simulation Model for DW_sqrt_rem
--
-- DesignWare_version: 05bb49bf
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--
-- ABSTRACT:  Combinational Square Root with a Remainder Output
-- 
--              DW_sqrt_rem shares the same code with DW_sqrt, which is 
--              first created by Reto in 2000.
--              DW_sqrt_rem is an "internal" component for DW_fp_sqrt
--              It has an additional output port for the partial remainder
--
--              parameters      valid values (defined in the DW manual)
--              ==========      ============
--              width           Word length of a   (width >= 2)
--              tc_mode         Two's complementation
--                              0 - unsigned
--                              1 - signed
--
--              Input ports     Size & Description
--              ===========     ==================
--              a               (width)-bits
--                              Radicand
--              root            int([width+1]/2)-bits
--                              Square root
--              remainder       (int([width+1]/2) + 1)-bits
--                              Remainder
--
-------------------------------------------------------------------------------
--
-- MODIFIED:
--
--  11/04/15  RJK  Change pkg use from individual DW02 pkg to unified DWARE pkg
--
-------------------------------------------------------------------------------

library IEEE, DWARE;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use DWARE.DW_Foundation_arith.all;


architecture sim of DW_sqrt_rem is
	

begin

  -- pragma translate_off
  
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
    
    if (width < 2) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter width (lower bound: 2)"
        severity warning;
    end if;
    
    if ( (tc_mode < 0) OR (tc_mode > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter tc_mode (legal range: 0 to 1)"
        severity warning;
    end if;
  
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;


  sqrt: process (a)

  variable tc_aint: integer;
  variable tc_a   : std_logic_vector(width - 1 downto 0);
  variable vecone : std_logic_vector(width - 1 downto 0);
  variable temp_root : std_logic_vector((width+1)/2-1 downto 0);
  variable temp_rem  : std_logic_vector(width - 1 downto 0);

  begin

    vecone := (others => '0');
    vecone(0) := '1';

    if (tc_mode = 1 and a(width - 1) = '1') then
      tc_a := (not a) + vecone;
    else 
      tc_a := a;
    end if;

    if tc_mode = 0 then
      temp_root := std_logic_vector(DWF_sqrt (unsigned(a)));

    else
      temp_root := std_logic_vector(DWF_sqrt (signed(a)));
    end if;

    temp_rem := tc_a - (temp_root * temp_root);

    root <= temp_root;
    remainder <= temp_rem((width + 1) / 2 downto 0);

  end process sqrt;

  -- pragma translate_on

end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_sqrt_rem_cfg_sim of DW_sqrt_rem is
 for sim
 end for; -- sim
end DW_sqrt_rem_cfg_sim;
-- pragma translate_on

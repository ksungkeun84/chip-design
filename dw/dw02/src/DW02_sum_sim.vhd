--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 1994 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Jay Zhu/RPH	Dec. 21, 1994
--
-- VERSION:   VHDL Simulation Model
--
-- DesignWare_version: 9d47f290
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
 
------------------------------------------------------------------------------
--
-- ABSTRACT:  Vector Adder
--
-- HISTORY: Jay Zhu 08/25/98	STAR 56715 work-around
--				(The final fixing should be done
--				by DWS.  After the formal fixing,
--				this work around should be backed off).
--
------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

architecture sim of DW02_sum is
	
 
begin

-- pragma translate_off
    
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
      
    if (num_inputs < 1) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter num_inputs (lower bound: 1)"
        severity warning;
    end if;
      
    if (input_width < 1) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter input_width (lower bound: 1)"
        severity warning;
    end if;
    
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;
      
  sum_PROC : process (INPUT)
  variable tmp_sum : UNSIGNED (input_width-1 downto 0);
  begin
     tmp_sum := UNSIGNED(INPUT(input_width-1 downto 0));
     if  (Is_X(INPUT)) then
       tmp_sum := (others => 'X');
     else
       for i in 1 to num_inputs-1 loop
         tmp_sum := tmp_sum 
                    + UNSIGNED(INPUT((i+1)*input_width-1 downto i*input_width));
       end loop;         
     end if;

     SUM <= std_logic_vector(tmp_sum);
     
  end process sum_PROC;
-- pragma translate_on
end sim;
------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW02_sum_cfg_sim of DW02_sum is
 for sim
 end for; -- sim
end DW02_sum_cfg_sim;
-- pragma translate_on

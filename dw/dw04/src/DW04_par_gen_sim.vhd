--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 1997 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    RJK                        June 16th, 1997
--
-- VERSION:   Architecture - Sim Model
--
-- DesignWare_version: 62b12cb1
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Parity Generator and Checker
--           parameterizable bus size (width > 0), parameteric "odd/even"
--           parameter width, parameter par_type
--           port datain     - input data (width bits wide)
--           port parity     - output parity bit.
--
-- MODIFIED:
--
--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
architecture sim of DW04_par_gen is
	
  constant widthM1    : integer := datain'high;
  begin
-- pragma translate_off
     process (datain)
	variable result : std_logic;
        begin
	result := '0';
	for i in datain'range loop
	    result := result XOR datain(i);
	end loop;
	if (par_type = 0) then
	    parity <= NOT result;
	
	else
	    parity <= result;
	end if;
     end process;
-- pragma translate_on
  end sim;  
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW04_par_gen_cfg_sim of DW04_par_gen is
 for sim
 end for; -- sim
end DW04_par_gen_cfg_sim;
-- pragma translate_on

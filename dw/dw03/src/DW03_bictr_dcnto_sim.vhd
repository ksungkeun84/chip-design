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
-- AUTHOR:    RJK          Aug. 8, 1997
--
-- VERSION:   Simulation architecture 'sim'
--
-- DesignWare_version: 3e579de3
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Up/Down Binary Counter w. Dynamic Flag
--           programmable wordlength (width > 0)
--           programmable count_to (0 < count_to <to 2**width-1)
--
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
architecture sim of DW03_bictr_dcnto is
	
  signal next_state, cur_state : UNSIGNED(width-1 downto 0);
begin
-- pragma translate_off
-- curent state process
  process (reset, next_state,clk)
    begin
      if (reset = '0') then
         cur_state <= (others => '0');
      elsif (clk'event and clk = '1') then
         cur_state <= next_state;
      end if;
  end process;
  count <= std_logic_vector(cur_state);
-- the next state process
  process(cur_state, data, load, up_dn, cen)
    begin
    if (load = '0') OR (load = 'L') then
       next_state <= UNSIGNED(data);
    else
       if (load = '1') OR (load = 'H') then
	  if (cen = '1') OR (cen = 'H') then
	     if (up_dn = '1') OR (up_dn = 'H') then
		next_state <= (cur_state + 1);
	     else
		if (up_dn = '0') OR (up_dn = 'L') then
		    next_state <= (cur_state - 1);
		else
		    next_state <= (others => 'X');
		end if;
	     end if;
	  else
	     if (cen = '0') OR (cen = 'L') then
		next_state <= cur_state;
	     else
		next_state <= (others => 'X');
	     end if;
	  end if;
       else
	  next_state <= (others => 'X');
       end if;
    end if;
   end process;
-- generate terminal count
     compare_proc: process(count_to,cur_state)
       begin
        if (count_to = std_logic_vector(cur_state)) then
           tercnt <= '1';
        else
           tercnt <= '0';
        end if;
      end process;
-- pragma translate_on
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW03_bictr_dcnto_cfg_sim of DW03_bictr_dcnto is
 for sim
 end for; -- sim
end DW03_bictr_dcnto_cfg_sim;
-- pragma translate_on

--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 1992 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    GN          April 12, 1993
--
-- VERSION:   Simulation architecture 'sim'
--
-- DesignWare_version: 3e06b617
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Up/Down Binary Counter w. Static  Flag
--           programmable wordlength (width > 0)
--           programmable count_to (0 < count_to <to 2**width-1)
--
-- MODIFIED: 
--          
--         
---------------------------------------------------------------------------------
library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use DWARE.DW_Foundation_arith.all;
architecture sim of DW03_bictr_scnto is
	
  signal cur_int, next_int : integer := 0;
  signal next_state, cur_state : std_logic_vector(width-1 downto 0);
  signal cnto,en_state, next_count : std_logic_vector(width-1 downto 0);
  signal tc : std_logic;
      function equal (A,B : std_logic_vector) return BOOLEAN is
        begin
-- pragma translate_off
            for i in A'range loop
               if A(i) /= B(i) then
                   return FALSE;
               end if;
            end loop;
            return TRUE;
-- pragma translate_on
       end;
begin
 count <= cur_state;
-- curent state process
  process (reset, next_state,clk)
    begin
      if (reset = '0') then
         cur_state <= (others => '0');
      elsif (clk'event and clk = '1') then
         cur_state <= next_state;
      end if;
  end process;
-- the next state process
  process(cur_state, next_int, data, load, up_dn, cen, cur_int, next_count, en_state)
     begin
     next_count  <= std_logic_vector(conv_unsigned(next_int,width));
     cur_int <= DW_CONV_INTEGER(unsigned(cur_state));
-- When load = '0', data input load to counter
-- when load = '1', counter increase/decrease
-- depending up/down signal and enable count signal
    if (load = '0') then
       next_state <= data;
    else
       next_state <= en_state;
    end if;
-- when (updn = '1') then
   if (up_dn = '1') then
     if (cur_int = 2**width-1) then
        next_int <= 0;
     else
        next_int <= cur_int + 1;
     end if;
  elsif (up_dn = '0') then
     if (cur_int = 0) then
       next_int <= (2**width - 1);
     else
       next_int <= cur_int - 1;
     end if;
  end if;
-- when cen = '1' then counter star count up/down
-- when cen = '0' counter  unchange value
   if (cen = '1') then
     en_state <= next_count;
   else
     en_state <= cur_state;
   end if;
end process;
-- generate terminal count
    cnto <= std_logic_vector(CONV_UNSIGNED(count_to,width));
     compare_proc: process(cnto,cur_state,tc)
       begin
        if equal(cnto,cur_state) then
           tc <= '1';
        else
           tc <= '0';
        end if;
      end process;
      tercnt <= tc;
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW03_bictr_scnto_cfg_sim of DW03_bictr_scnto is
 for sim
 end for; -- sim
end DW03_bictr_scnto_cfg_sim;
-- pragma translate_on

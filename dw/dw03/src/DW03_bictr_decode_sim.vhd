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
-- AUTHOR:    GN	       Jan. 24, 1994	
--
-- VERSION:   Simulation architecture 'sim' 
--
-- DesignWare_version: ca311b46
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Up/Down Binary Counter w. Output Decode
--
-- MODIFIED: 
--          
---------------------------------------------------------------------------------
library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use DWARE.DW_Foundation_arith.all;
architecture sim of DW03_bictr_decode is
	
  signal cur_int, next_int : integer := 0;
  signal next_state, cur_state : std_logic_vector(width-1 downto 0);
  signal en_state, next_count : std_logic_vector(width-1 downto 0);
  signal tcup, tcdn : std_logic;
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
-- generate terminal count
   if (up_dn = '1') then
      if (cur_int = 2**width-1) then
         tcup <= '1';
         tcdn <= '0';
       else
         tcup <= '0';
         tcdn <= '0';
       end if;
   elsif (up_dn = '0') then
      if (cur_int = 0) then
         tcdn <= '1';
         tcup <= '0';
      else
         tcdn <= '0';
         tcup <= '0';
      end if;
   end if;
  end process;
   tercnt <= tcup or tcdn;
-- decoder process
process(cur_state)
    constant dec_width: POSITIVE := 2**width;
    variable and_acc: std_logic;
    variable and_out: std_logic_vector(dec_width-1 downto 0);
    type and_array is array(dec_width-1 downto 0) of std_logic_vector(width-1 downto 0);
    variable and_in : and_array;
  begin
    for j in 1 to width loop
      for k in 0 to dec_width-1 loop
        if (k mod 2**j) < 2**(j-1) then
          and_in(k)(j-1) := not cur_state(j-1);
        else
          and_in(k)(j-1) := cur_state(j-1);
        end if;
      end loop;
    end loop;
    for i in 0 to dec_width-1 loop
      and_acc := '1';
      for j in 0 to width-1 loop
        and_acc := and_acc and and_in(i)(j);
      end loop;
     and_out(i) := and_acc;
    end loop;
    for i in 0 to dec_width-1 loop
      count_dec(i) <= and_out(i);
    end loop;
  end process;
-- pragma translate_on
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW03_bictr_decode_cfg_sim of DW03_bictr_decode is
 for sim
 end for; -- sim
end DW03_bictr_decode_cfg_sim;
-- pragma translate_on

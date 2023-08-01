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
-- AUTHOR:    RJK		May 29, 1997
--
-- VERSION:   Simulation Model
--
-- DesignWare_version: 349cb14e
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Up/Down Counter
--           parameterizable wordlength (width > 0)
--	     clk	- positive edge-triggering clock
--           reset	- asynchronous reset (active low)
--           data	- data load input
--	     cen	- counter enable
--	     count	- counter state	
--
-- MODIFIED: Rong       Sep. 21,1999
--           Modified X-handling
--          
---------------------------------------------------------------------------------
library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use DWARE.DWpackages.all;
architecture sim of DW03_updn_ctr is
	
  constant term_value_low  : unsigned(width-1 downto 0) := (others => '0');
  constant term_value_high : unsigned(width-1 downto 0) := (others => '1');
  signal cur_state : unsigned(width-1 downto 0);
begin
-- pragma translate_off

  count <= dw_conv_std_logic_vector(cur_state, width);
-- count logic process
  process (clk,reset)
    variable next_state : UNSIGNED(width-1 downto 0);
    variable reset_int : std_logic;       
    variable load_int : std_logic;
    variable cen_int : std_logic;
    variable up_dn_int : std_logic;
  begin
    reset_int := TO_UX01(reset);
    load_int := TO_UX01(load);
    cen_int := TO_UX01(cen);
    up_dn_int := TO_UX01(up_dn);
    
 
    if reset_int = '1' then
      if rising_edge(clk) then
        if (load_int = '0')  then
          next_state := UNSIGNED(data);
	
        elsif  (load_int = '1')  then
          if  (cen_int = '0')  then
            next_state := cur_state;
	    
          elsif  (up_dn_int = '0') and (cen_int = '1') then
            next_state := cur_state - '1';
	    
          elsif  (up_dn_int = '1') and (cen_int = '1') then
            next_state := cur_state + '1';
	    
          else
            next_state := (others => 'X');
          end if;
	
        else
          next_state := (others => 'X');
        end if;
      end if;
    else
      next_state := (others => reset_int); 
      cur_state <= (others => reset_int);
    end if;
    cur_state <= next_state;
  end process;

-- the tercnt logic process
  process(cur_state, up_dn)
    variable up_dn_int : std_logic;
  begin
    up_dn_int := TO_UX01(up_dn);

    if cur_state = term_value_low then
      if up_dn_int = '0'  then
        tercnt <= '1';
      elsif up_dn_int = '1' then
        tercnt <= '0';
      else
        tercnt <= 'X';
      end if;
   
       
    elsif cur_state = term_value_high then
      if up_dn_int = '0' then
        tercnt <= '0';
      elsif up_dn_int = '1' then
        tercnt <= '1';
      else
        tercnt <= 'X';
    end if;
	
    elsif ( any_unknown( cur_state ) = 1 ) then
        tercnt <= 'X';
    else
        tercnt <= '0';
    end if;
  end process;
-- pragma translate_on
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW03_updn_ctr_cfg_sim of DW03_updn_ctr is
 for sim
 end for; -- sim
end DW03_updn_ctr_cfg_sim;
-- pragma translate_on

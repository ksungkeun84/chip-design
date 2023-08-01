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
-- AUTHOR:    KB			March 26, 1994
--
-- VERSION:   Synthetic Architecture
--
-- DesignWare_version: 3acc23bb
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Register with Synchronous Enable and Reset
--
---------------------------------------------------------------------------------
-- 
--      WSFDB revision control info 
--              @(#)DW03_reg_s_pl_sim.vhd	1.2
--      
--	MODIFIDED       Rong 	            Aug. 1999
--                      Add parameter checking and x-handling
---------------------------------------------------------------------------------
library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use DWARE.DW_Foundation_arith.all;
architecture sim of DW03_reg_s_pl is
	
constant reset_value_vector	: std_logic_vector(width downto 0)
	 := dw_conv_std_logic_vector(reset_value,width+1);
begin
-- pragma translate_off
-- Parameter validation process
par_validate: process
variable error : std_logic := '0';
begin
   if width <= 31  then
     if reset_value>(2**(width-1)-1+2**(width-1)) or reset_value<0 or width<1 then
        error := '1';
     end if;
   elsif reset_value /= 0  then
        error := '1';
   end if;
 
assert error ='0'
report "Error: reset_value parameter of DW03_reg_s_pl is out of legal range."
severity FAILURE;
wait;
end process par_validate;

q_reg: process (clk)
variable d_int: std_logic_vector (width-1 downto 0);
variable reset_N_int: std_logic := '1';
variable enable_int: std_logic := '0';
  begin
  d_int := TO_UX01(d);
  reset_N_int := TO_UX01(reset_N);
  enable_int := TO_UX01(enable);
 
  if rising_edge(clk) then
      if reset_N_int = '0' then
         q <= reset_value_vector(width-1 downto 0);
      elsif reset_N_int = '1' then
         if  enable_int ='1' then
             q <= d_int;
         elsif enable_int /= '0' then
             q <= (others => enable);
         end if;
      else q <= ( others => reset_N_int );
      end if;
   end if;

end process q_reg;
-- pragma translate_on
end sim;  ---- end of DW03_reg_s_pl simulation model ----
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW03_reg_s_pl_cfg_sim of DW03_reg_s_pl is
 for sim
 end for; -- sim
end DW03_reg_s_pl_cfg_sim;
-- pragma translate_on

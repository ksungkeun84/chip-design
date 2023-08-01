--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 1996 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    KARKI                        Nov.15th,1996
--
-- VERSION:   Architecture - Sim Model
--
-- DesignWare_version: 569a05ae
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Shadow and Multibit Register
--           parameterizable width, and number of registers 1 or 2
--           datain     - input data to system register.
--           sys_clk    - clock that samples the system register, positive edge triggered
--	     shad_clk   - signal that clocks the output of the system register into
--			  the shadow register,	positive edge triggered
--	     reset      - Asynchronous reset signal that clears the system and shadow
--			  registers
--	     SI		- Serial scan input clocked by clocked by shad_clk when SE
--			  is high
--	     SE		- Serial scan enable signal,active high.Enables scan only on the
--			  shadow register
--	     sys_out    - Output of the system register
--	     shad_out   - Parallel output of the shadow register that lags the system
--			  register by one cycle
-- 	     SO		- Serial scan output from the shadow register. When SE is low,
-- 			  represents the state of the MSB of the shadow register.
--			  When SE is high, each successive bit is shifted up one &
--			  SI is clocked into the LSB
--  
-- MODIFIED  Rong 	  Sep. 1999
--		          Add parameter checking and x-handling
--
--------------------------------------------------------------------------------
library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;

architecture sim of DW04_shad_reg is
	
signal sys_out_int : std_logic_vector(width -1 downto 0); 
begin
-- pragma translate_off
 
PAR_CHECK: process 
variable error: std_logic := '0';
begin
	if (bld_shad_reg > 1 or bld_shad_reg < 0 or width < 1 or width > 512) then
        error := '1';
        end if;
assert error = '0'
report " Error: parameter width or bld_shad_reg of DW04_shad_reg is out of legal range." 
severity FAILURE;
wait;
end process PAR_CHECK;

        
DIRECT_SHADE_OUT : process ( sys_clk, shad_clk, reset )
variable reset_int,SE_int,SO_int : std_logic;
variable datain_int,shad_out_int : std_logic_vector(width -1 downto 0);
begin
datain_int := TO_UX01(datain);
reset_int := TO_UX01(reset);
SE_int := TO_UX01(SE);
 
 
        if reset_int = '1' then
 
           if rising_edge(sys_clk) then
                sys_out_int <= datain_int;
                sys_out <= datain_int;
           end if;
           if rising_edge(shad_clk) and bld_shad_reg =1 then
                 if (SE_int = '0') then
                    shad_out_int := sys_out_int;
                 elsif (SE_int = '1') then
                    shad_out_int := shad_out_int(width-2 downto 0) & TO_UX01(SI);
                 else
                    shad_out_int := (others => SE_int);
                 end if;
 
                 SO_int := shad_out_int(width-1);
                 shad_out <= shad_out_int;
                 SO <= SO_int;
            end if;
 
          else
 
                if bld_shad_reg = 1  then
                shad_out_int := (others => reset_int);
                SO_int := shad_out_int(width-1);
                end if;

                sys_out_int <= (others => reset_int);
                sys_out <= (others => reset_int);
                shad_out <= shad_out_int;
                SO <= SO_int ;
 
          end if;
 

end process DIRECT_SHADE_OUT;

-- pragma translate_on
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW04_shad_reg_cfg_sim of DW04_shad_reg is
 for sim
 end for; -- sim
end DW04_shad_reg_cfg_sim;
-- pragma translate_on

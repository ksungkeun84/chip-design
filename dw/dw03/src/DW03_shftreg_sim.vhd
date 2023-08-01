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
-- AUTHOR:    Scott MacKay			May, 20, 1993
--
-- VERSION:   Simulation Architecture of  DW03_shftreg (sim)
--
-- DesignWare_version: f59e7e38
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Shift Register
--           length wordlength
--           shift enable active low
--           parallel load enable active low
-- MODIFIED: Rong  	Aug 17,1999 
--           Add X and U handling 
--         
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_arith.all;
architecture sim of DW03_shftreg is
	
begin
-- pragma translate_off
	CNT: process (LOAD_N, SHIFT_N, S_IN, P_IN,CLK)

        variable load_n_int, shift_n_int, s_in_int: std_logic;
        variable p_in_int : std_logic_vector(length-1 downto 0);
        variable q: std_logic_vector (length-1 downto 0) ;
        variable d_int: std_logic_vector (length-1 downto 0) ;
 
        begin

        p_in_int := TO_UX01(P_IN);
        load_n_int := TO_UX01(LOAD_N);
        shift_n_int := TO_UX01(SHIFT_N);
        s_in_int := TO_UX01(S_IN);
 
        if rising_edge(CLK) then
           if load_n_int = '0' then
              d_int := p_in_int;
           elsif load_n_int = '1' then
              if shift_n_int = '0' then
                 d_int := q(length-2 downto 0) & s_in_int;
              elsif shift_n_int = '1' then
                 d_int := q;
              else
                 d_int := (others => shift_n_int);
              end if;
           else
              d_int := (others => load_n_int);
           end if;
        q := d_int;
        P_OUT <= q;
        end if;

        end process CNT;
	
-- pragma translate_on
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW03_shftreg_cfg_sim of DW03_shftreg is
 for sim
 end for; -- sim
end DW03_shftreg_cfg_sim;
-- pragma translate_on

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
-- AUTHOR:    SS		Nov. 11, 1996
--
-- VERSION:   VHDL Simulation Model
--
-- DesignWare_version: 3e0c2b69
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------
--
-- ABSTRACT: Simulation Architecture of DW_decode_en 
--
-- MODIFIED:
--      02/05/2008 - AFT - Simplified the simulation model to publish
--                   the component.
--
---------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
architecture sim of DW_decode_en is
	

constant dec_width: NATURAL := 2**width;
signal one_vec : std_logic_vector (dec_width-1 downto 0);

begin
-- pragma translate_off

one_vec <= conv_std_logic_vector (1, dec_width);
b <= (others => 'X') when (Is_X(a) or Is_X(en)) else
     (SHL(one_vec, std_logic_vector(a))) when (en = '1') else
     (others => '0');     
    
-- pragma translate_on
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_decode_en_cfg_sim of DW_decode_en is
 for sim
 end for; -- sim
end DW_decode_en_cfg_sim;
-- pragma translate_on

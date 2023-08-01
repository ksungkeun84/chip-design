--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 1998 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Sourabh Tandon/Dhiraj Goswami         Dec. 8, 1998
--
-- VERSION:   VHDL Simulation Model
--
-- NOTE:      This is a subentity.
--            This file is for internal use only.
--
-- DesignWare_version: f8b9fbc8
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT: Generic Tri-state Control/Force test point - Simulation Model
--
-- MODIFIED: 
--
------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
 
architecture sim of DW_Z_control_force is
	
signal tst_ctl : std_logic;
begin
-- pragma translate_off
    tst_ctl <= TM and TPE;
    infer : process (TD, tst_ctl) begin
             if (tst_ctl = '1') then
               DRVR <= TD;
             elsif (tst_ctl = '0') then
               DRVR <= 'Z';   -- assigns high-impedance state
             else
               DRVR <= 'X';
             end if;
            end process;
-- pragma translate_on
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_Z_control_force_cfg_sim of DW_Z_control_force is
 for sim
 end for; -- sim
end DW_Z_control_force_cfg_sim;
-- pragma translate_on

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
-- DesignWare_version: 32b25912
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT: Generic observ/data generator test point - Simulation model
--
-- MODIFIED:
--
------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
 
architecture sim of DW_observ_dgen is
	
begin
-- pragma translate_off
    infer : process (CLK) begin
             if (CLK'event and CLK = '1') then
               TDGO <= OBIN;
             end if;
            end process infer;
-- pragma translate_on
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_observ_dgen_cfg_sim of DW_observ_dgen is
 for sim
 end for; -- sim
end DW_observ_dgen_cfg_sim;
-- pragma translate_on

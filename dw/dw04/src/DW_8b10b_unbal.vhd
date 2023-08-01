--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 1999 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Rick Kelly and Jay Zhu  Aug 27, 1999
--
-- VERSION:   Entity
--
-- DesignWare_version: da1232e0
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT: 8b10b unbalanced character predictor
--	Parameters:
--		k28_5_only : Special character subset control
--			parameter (0 for all special characters
--			encoded, 1 for only K28.5 decoded [when
--			k_char=HIGH K28.5 is encoded regardless
--			of the value of the input data])
--	Inputs:
--		k_char : Special character control
--		data_in : Input data to be encoded that balance
--			predition is based on
--	Outputs:
--		unbal  : Output indicating whether the input
--			data byte will flip the running disparity
--			bit of the encoder (unbalance = HIGH) or
--			keep it in the same state (unbalanced = LOW)
------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity DW_8b10b_unbal is
    
    generic(
	    k28_5_only : INTEGER  := 0
	   );
    port(
	    k_char : in std_logic;			-- Special Character control input
	    data_in : in std_logic_vector(7 downto 0);	-- Input data bus (eight bits)
	    unbal   : out std_logic			-- Predicted unbalance status output
	 );
end DW_8b10b_unbal;

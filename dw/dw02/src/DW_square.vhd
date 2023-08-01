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
-- AUTHOR:    Rick Kelly       Dec. 9, 1998
--
-- VERSION:   VHDL Entity File
--
-- DesignWare_version: f63bd089
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Integer square
--
-- MODIFICATION:
--
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
entity DW_square is
   generic( width: NATURAL);          -- multiplier size
   port(a : in std_logic_vector(width-1 downto 0);  
        tc : in std_logic;          -- signed -> '1', unsigned -> '0'
        square : out std_logic_vector((2*width)-1 downto 0));
end DW_square;

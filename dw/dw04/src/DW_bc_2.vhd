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
-- AUTHOR:    Suzanne Skracic                 Jun. 29, 1996
--
-- VERSION:   VHDL Entity File
--
-- DesignWare_version: d3465276
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Boundary Scan Cell Type BC_2
--           This design implements a BC_2 type boundary-scan cell.
--           All the 1149.1 instructions are supported by this cell.
--
-- MODIFIED:
--
-----------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity DW_bc_2 is
    port ( capture_clk : in std_logic; -- =tck for sync, =clock_dr for async
	   update_clk  : in std_logic; -- =tck for sync, =update_dr for async
	   capture_en  : in std_logic; -- =clock_dr for sync, =0 for async
	   update_en   : in std_logic; -- =update_dr for sync, =1 for async
	   shift_dr    : in std_logic; -- =shift_dr from TAP
	   mode        : in std_logic; 
	   si          : in std_logic; -- serial data path input
	   data_in     : in std_logic; 
	   data_out    : out std_logic;  
	   so          : out std_logic); -- serial data path output
end DW_bc_2;

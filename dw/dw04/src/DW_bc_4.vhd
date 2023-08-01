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
-- DesignWare_version: f6e0a61a
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Boundary Scan Cell Type BC_4
--           This design implements a BC_4 type boundary-scan cell.
--           All the 1149.1 instructions are supported by this cell.
--
-- MODIFIED:
--
-----------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity DW_bc_4 is
    port ( capture_clk : in std_logic; -- =tck for sync, =clock_dr for async
	   capture_en  : in std_logic; -- =clock_dr for sync, =0 for async
	   shift_dr    : in std_logic; -- =shift_dr from TAP
	   si          : in std_logic; -- serial data path input
	   data_in     : in std_logic; 
	   so          : out std_logic; -- serial data path output
           data_out    : out std_logic); 
end DW_bc_4;

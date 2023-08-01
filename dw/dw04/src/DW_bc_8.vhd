--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2002 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Rajeev P Huralikoppi   Aug 21, 2002
--
-- VERSION:   VHDL Entity File
--
-- DesignWare_version: 93e3b6d0
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Boundary Scan Cell Type BC_8
--           This design implements a BC_8 type boundary-scan cell.
--            
-- MODIFIED:
--
-----------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity DW_bc_8 is
  port (
    capture_clk : in  std_logic;      -- =tck for sync, =clock_dr for async
    update_clk  : in  std_logic;      -- =tck for sync, =update_dr for async
    
    capture_en  : in  std_logic;      -- =clock_dr for sync, =0 for async
    update_en   : in  std_logic;      -- =update_dr for sync, =1 for async
    shift_dr    : in  std_logic;      -- =shift_dr from TAP
    mode        : in  std_logic;
    si          : in  std_logic;      -- serial data path input
    pin_input   : in  std_logic;      -- connected to IC input pin
    output_data : in  std_logic;      -- connected to IC data output logic

    ic_input    : out std_logic;      -- connected to IC input logic 
    data_out    : out std_logic;
    so          : out std_logic);     -- serial data path output
end DW_bc_8;

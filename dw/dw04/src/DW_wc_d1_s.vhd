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
-- AUTHOR:    Rajeev Huralikoppi      Oct 2002
--
-- VERSION:   VHDL Entity File
--
-- DesignWare_version: 5ca84218
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT: Wrapper Core Cell Type WC_D1_S
--           This design implements a WC_D1_S type Wrapper Core  cell.
--           
--
-- MODIFIED:
--      RPH     11/26/2002
--              Added rst_mode parameter  
-----------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity DW_wc_d1_s is 
  generic (
    rst_mode : natural := 0);           -- reset mode 0, 1,2 or 3
  port (
    shift_clk    : in  std_logic;     -- shift clock
    
    rst_n        : in  std_logic;     -- active low reset 
    set_n        : in  std_logic;     -- active low set
    
    shift_en     : in  std_logic;     -- shift enable
    capture_en   : in  std_logic;     -- Capture enable; active low
    safe_control : in  std_logic;     -- Capture enable
    safe_value   : in  std_logic;     -- Safe_value input    
    cfi          : in  std_logic;     -- serial data path input
    cti          : in  std_logic;     -- serial data path input
    
    cfo          : out std_logic;
    cto          : out std_logic;     -- serial data path output

    toggle_state : in  std_logic);
end DW_wc_d1_s;

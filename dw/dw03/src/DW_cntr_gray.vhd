--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2001 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Reto Zimmermann    11/14/01
--
-- VERSION:   VHDL Entity File for DW_cntr_gray
--
-- DesignWare_version: 24e81eab
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Gray counter
--
--   Parameter  Legal Range    Default  Description
--   ---------  -----------    -------  -----------
--   width      >= 1           none     word length of count
--
--   Inputs       Size         Description
--   ------       ----         -----------
--   clk          1            clock
--   rst_n        1            asynchronous reset, active low
--   init_n       1            synchronous reset, active low
--   load_n       1            load enable, active low
--   data         width        load data input
--   cen          1            count enable (0 : keep value, 1 : count)
--
--   Outputs      Size         Description
--   -------      ----         -----------
--   count        width        counter output
--
-- MODIFIED:
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;


entity DW_cntr_gray is

  generic (
    width : positive);                  -- word width

  port (
    clk    : in  std_logic;           -- clock
    rst_n  : in  std_logic;           -- asynchronous reset, active low
    init_n : in  std_logic;           -- synchronous reset, active low
    load_n : in  std_logic;           -- load enable, active low
    data   : in  std_logic_vector(width-1 downto 0);   -- load data input
    cen    : in  std_logic;           -- count enable
    count  : out std_logic_vector(width-1 downto 0));  -- counter output

end DW_cntr_gray;

-------------------------------------------------------------------------------

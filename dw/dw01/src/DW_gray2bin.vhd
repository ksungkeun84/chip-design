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
-- VERSION:   VHDL Entity File for DW_gray2bin
--
-- DesignWare_version: 7fb289e1
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Gray to Binary Converter
--
--   Parameter  Legal Range    Default  Description
--   ---------  -----------    -------  -----------
--   width      >= 1           none     word length of input/output
--
--   Inputs       Size         Description
--   ------       ----         -----------
--   g            width        Gray input
--
--   Outputs      Size         Description
--   -------      ----         -----------
--   b            width        Binary output
--
-- MODIFIED:
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;


entity DW_gray2bin is

  generic (
    width : natural);                   -- word width

  port (
    g : in  std_logic_vector(width-1 downto 0);   -- Gray input
    b : out std_logic_vector(width-1 downto 0));  -- Binary output

end DW_gray2bin;

-------------------------------------------------------------------------------

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
-- VERSION:   VHDL Entity File for DW_bin2gray
--
-- DesignWare_version: 4477b1ec
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Binary to Gray Converter
--
--   Parameter  Legal Range    Default  Description
--   ---------  -----------    -------  -----------
--   width      >= 1           none     word length of input/output
--
--   Inputs       Size         Description
--   -------      ----         -----------
--   b            width        Binary input
--
--   Outputs      Size         Description
--   ------       ----         -----------
--   g            width        Gray output
--
-- MODIFIED:
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;


entity DW_bin2gray is

  generic (
    width : natural);                   -- word width

  port (
    b : in  std_logic_vector(width-1 downto 0);   -- binary input
    g : out std_logic_vector(width-1 downto 0));  -- Gray output

end DW_bin2gray;

-------------------------------------------------------------------------------

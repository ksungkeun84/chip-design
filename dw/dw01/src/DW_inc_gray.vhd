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
-- VERSION:   VHDL Entity File for DW_inc_gray
--
-- DesignWare_version: 26ddc3e9
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT: Gray incrementer
--
--   Parameter  Legal Range    Default  Description
--   ---------  -----------    -------  -----------
--   width      >= 1           none     word length of input/output
--
--   Inputs       Size         Description
--   -------      ----         -----------
--   a            width        Gray input
--   ci           1            carry input
--
--   Outputs      Size         Description
--   ------       ----         -----------
--   Z            width        incremented Gray output
--
-- MODIFIED:
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;


entity DW_inc_gray is

  generic (
    width : natural);                   -- word width

  port (
    a  : in  std_logic_vector(width-1 downto 0);   -- Gray input
    ci : in  std_logic;                            -- carry input
    z  : out std_logic_vector(width-1 downto 0));  -- Gray output

end DW_inc_gray;

-------------------------------------------------------------------------------

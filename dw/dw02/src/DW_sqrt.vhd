--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2000 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Reto Zimmermann         May 2, 2000
--
-- VERSION:   Entity
--
-- DesignWare_version: 594b8608
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Combinational Square Root
--            - Calculates the square root of the absolute value of a.
--            
--   Parameter  Legal Range    Default  Description
--   ---------  -----------    -------  -----------
--   width      >= 2           none     word length of a
--   tc_mode    0 or 1         0        two's complement control:
--                                        0 : input/output unsigned
--                                        1 : input two's complement
--                                            output unsigned
--
--   Inputs       Size         Description
--   ------       ----         -----------
--   a            width        radicand
--
--   Outputs      Size         Description
--   -------      ----         -----------
--   root         (width+1)/2  square root
--   
-- MODIFIED:
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;


entity DW_sqrt is

  generic (
    width   : positive;                    -- radicand word width
    tc_mode : integer  := 0);  -- '0' : unsigned, '1' : 2's compl.

  port (
    a    : in  std_logic_vector(width-1 downto 0);         -- radicand
    root : out std_logic_vector((width+1)/2-1 downto 0));  -- square root

end DW_sqrt;

-------------------------------------------------------------------------------

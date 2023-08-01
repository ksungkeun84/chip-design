
--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2006 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Kyung-Nam Han   Nov. 07, 2006
--
-- VERSION:   VHDL Entity for DW_sqrt_rem
--
-- DesignWare_version: 5ca44a4b
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--
-- ABSTRACT:  Combinational Square Root with a Remainder Output
-- 
--              DW_sqrt_rem shares the same code with DW_sqrt, which is 
--              first created by Reto in 2000.
--              DW_sqrt_rem is an "internal" component for DW_fp_sqrt
--              It has an additional output port for the partial remainder
--
--              parameters      valid values (defined in the DW manual)
--              ==========      ============
--              width           Word length of a   (width >= 2)
--              tc_mode         Two's complementation
--                              0 - unsigned
--                              1 - signed
--
--              Input ports     Size & Description
--              ===========     ==================
--              a               (width)-bits
--                              Radicand
--              root            int([width+1]/2)-bits
--                              Square root
--              remainder       int([width+1]/2 + 1)-bits
--                              Remainder
--
-------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;


entity DW_sqrt_rem is

  generic (
    width   : positive;                    -- radicand word width
    tc_mode : integer  := 0);  -- '0' : unsigned, '1' : 2's compl.

  port (
    a        : in  std_logic_vector(width-1 downto 0);         -- radicand
    root     : out std_logic_vector((width+1)/2-1 downto 0);   -- square root
    remainder: out std_logic_vector((width+1)/2 downto 0));   -- square root

end DW_sqrt_rem;

-------------------------------------------------------------------------------



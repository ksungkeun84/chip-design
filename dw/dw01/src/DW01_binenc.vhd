--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 1994 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    PS			Dec. 12, 1994
--
-- VERSION:   Entity
--
-- DesignWare_version: 934c42cc
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Binary Encoder
--
-- MODIFIED: 
--	10/14/1998	Jay Zhu	STAR 59348
--      05/10/2000      Rick Kelly   STAR 103007
--
------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
entity DW01_binenc is
   generic (A_width, ADDR_width: POSITIVE);
 
   port    ( A    : in std_logic_vector(A_width-1 downto 0);
             ADDR : out std_logic_vector(ADDR_width-1 downto 0));
end DW01_binenc;

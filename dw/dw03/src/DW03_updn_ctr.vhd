--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 1992 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    PS			Feb. 10, 1993
--
-- VERSION:   Entity
--
-- DesignWare_version: 491e60a0
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Up/Down Counter
--           parameterizable wordlength (width > 0)
--	     clk	- positive edge-triggering clock
--           reset	- asynchronous reset (active low)
--           data	- data load input
--	     cen	- counter enable
--	     count	- counter state	
--
-- MODIFIED: 
--          
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
entity DW03_updn_ctr is
  generic(width : POSITIVE);
  port(data     : in std_logic_vector(width-1 downto 0);
       up_dn, load, cen, clk, reset : in std_logic;
       count    : out std_logic_vector(width-1 downto 0);
       tercnt   : out std_logic); 
end DW03_updn_ctr;

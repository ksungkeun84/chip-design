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
-- AUTHOR:    GN                 April. 05, 1993
--
-- VERSION:   entity 
--
-- DesignWare_version: 93d6f472
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  LFSR Counter with Dynamic Count-to Flag
--           Programmable wordlength (width in integer range 1 to 50)
--           positive edge-triggering clock: clk
--           asynchronous reset(active low): reset
--           updn = '1' count up, updn = '0' count down
--           count state : count
--           when reset = '0' , count <= "000...000"
--           counter state 0 to 2**width-2, "111...111" illegal state
--
-- MODIFIED:
--
--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
entity DW03_lfsr_dcnto is
  generic(width : integer);
  port (data : in std_logic_vector(width-1 downto 0);
        count_to : in std_logic_vector(width-1 downto 0);
        load, cen, clk, reset : in std_logic;
        count   : out std_logic_vector(width-1 downto 0);
        tercnt : out std_logic);
end DW03_lfsr_dcnto;

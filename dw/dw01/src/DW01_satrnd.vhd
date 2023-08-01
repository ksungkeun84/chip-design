--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 1998 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    PS			Aug. 8, 1994
--
-- VERSION:   Entity
--
-- DesignWare_version: dae97bc7
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Arithmetic Saturation and Rounding Logic
--
--           signed: tc = '1'
--           unsigned: tc = '0'
--
--           eg. width=9, msb_out=5, lsb_out=2
--           input:    8 7 6 5 4 3 2 1 0
--           extract         5 4 3 2
--           output          3 2 1 0
--
-- MODIFIED: 
--		Jay Zhu	08/25/98	SLDB legality check
------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
entity DW01_satrnd is
  generic(width : POSITIVE := 16;
          msb_out: NATURAL := 15;
	  lsb_out: NATURAL := 0);
  port(din : std_logic_vector(width-1 downto 0);
       tc : std_logic;
       sat : std_logic;              
       rnd : std_logic;
       ov : out std_logic;                     
       dout : out std_logic_vector(msb_out-lsb_out downto 0));
end DW01_satrnd;

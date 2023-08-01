--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 1996 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    SS			Nov. 11, 1996
--
-- VERSION:   VHDL Entity File
--
-- NOTE:      This is a subentity.
--            This file is for internal use only.
--
-- DesignWare_version: e73e3c96
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT: Decoder 
--           The n-bit address A decodes to 2**n lines.
--	     The selected bit in port B is active high.
--	     Active high enable en.
--
--	     If en <= '1' then
--           eg. n=3
--           A(2:0)	   B(7:0)
--           000 	-> 00000001
--           001 	-> 00000010
--           010 	-> 00000100
--           011 	-> 00001000
--           100 	-> 00010000
--           101 	-> 00100000
--           110 	-> 01000000
--           111 	-> 10000000
--	     If en <= '0' then
--	     XXX	-> 00000000
--
--
-- MODIFIED:
--
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
entity DW_decode_en is
  generic(width : NATURAL);
  port(en : in std_logic;
       a: in std_logic_vector(width-1 downto 0);
       b: out std_logic_vector(2**width-1 downto 0));
end DW_decode_en;



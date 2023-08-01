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
-- AUTHOR:    PS			Dec. 31, 1991
--
-- VERSION:   VHDL Entity File
--
-- DesignWare_version: 838721d3
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Decrementer
--           The n-bit address A decodes to 2**n lines.
--	     The selected bit in port B is active high.
--
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
--
--
-- MODIFIED:
--	10/14/1998	Jay Zhu	STAR 59348
--
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
entity DW01_decode is
  generic(width : NATURAL);
  port(A: in std_logic_vector(width-1 downto 0);
       B: out std_logic_vector(2**width-1 downto 0));
end DW01_decode;

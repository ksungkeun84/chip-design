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
-- AUTHOR:    Rick Kelly and Sourabh Tandon     August 24, 1998
--
-- VERSION:   VHDL Entity File
--
-- DesignWare_version: 8f329432
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Duplex Comparator
--
--	Parameters		Valid Values
--	==========		============
--	width			>= 4
--	p1_width		2 to (width-2)
--
--	Input Ports	Size	Description
--	===========	====	===========
--	a		width	Input data
--	b		width	Input data
--	tc		1 bit	Two's complement select (active high)
--	dplx		1 bit	Duplex mode select (active high)
--
--	Output Ports	Size	Description
--	===========	====	===========
--	lt1		1 bit	Part1: a less than b output
--	eq1		1 bit	Part1: a equal to b output
--	gt1		1 bit	Part1: a greater than b output
--	lt2		1 bit	Full or Part2: a less than b output
--	eq2		1 bit	Full or Part2: a equal to b output
--	gt2		1 bit	Full or Part2: a greater than b output
--
-- MODIFIED:
--
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
entity DW_cmp_dx is
	generic(
		width :		NATURAL;
		p1_width :	NATURAL
		);
	port(
		a : 		in std_logic_vector(width-1 downto 0);
		b : 		in std_logic_vector(width-1 downto 0);
        	tc :		in std_logic;
        	dplx :		in std_logic;
        	lt1 :		out std_logic;
        	eq1 :		out std_logic;
        	gt1 :		out std_logic;
        	lt2 :		out std_logic;
        	eq2 :		out std_logic;
        	gt2 :		out std_logic
		);
end DW_cmp_dx;

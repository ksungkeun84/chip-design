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
-- AUTHOR:    Rick Kelly and Jay Zhu     Feburary 4, 1998
--
-- VERSION:   VHDL Entity File
--
-- DesignWare_version: 959dac98
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Duplex Adder-Subtractor
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
--	ci1		1 bit	Full or part1 carry input
--	ci2		1 bit	Part2 carry input
--	addsub		1 bit	Add/subtract select input
--	tc		1 bit	Two's complement select (active high)
--	sat		1 bit	Saturation mode select (active high)
--	avg		1 bit	Average mode select (active high)
--	dplx		1 bit	Duplex mode select (active high)
--
--	Output Ports	Size	Description
--	===========	====	===========
--	sum		width	Output data
--	co1		1 bit	Part1 carry output
--	co2		1 bit	Full or part2 carry output
--
-- MODIFIED:
--
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
entity DW_addsub_dx is
	generic(
		width :		NATURAL;
		p1_width :	NATURAL
		);
	port(
		a : 		in std_logic_vector(width-1 downto 0);
		b : 		in std_logic_vector(width-1 downto 0);
        	ci1 :		in std_logic;
        	ci2 :		in std_logic;
        	addsub :	in std_logic;
        	tc :		in std_logic;
        	sat :		in std_logic;
        	avg :		in std_logic;
        	dplx :		in std_logic;
        	sum :		out std_logic_vector(width-1 downto 0);
        	co1 :		out std_logic;
        	co2 :		out std_logic
		);
end DW_addsub_dx;

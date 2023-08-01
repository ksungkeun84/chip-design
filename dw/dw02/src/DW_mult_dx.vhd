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
-- AUTHOR:    Jay Zhu     October 20, 1998
--
-- VERSION:   VHDL Entity File
--
-- DesignWare_version: ebb23ca3
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Duplex Multiplier
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
--	product		2*width	Output data
--
-- MODIFIED:
--
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
entity DW_mult_dx is
	generic(
		width :		NATURAL;
		p1_width :	NATURAL
		);
	port(
		a : 		in std_logic_vector(width-1 downto 0);
		b : 		in std_logic_vector(width-1 downto 0);
        	tc :		in std_logic;
        	dplx :		in std_logic;
        	product :	out std_logic_vector(2*width-1 downto 0)
		);
end DW_mult_dx;

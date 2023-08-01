--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 1999 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Rick Kelly		Apr. 5, 1999
--
-- VERSION:   Entity
--
-- DesignWare_version: d1656f3b
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT: Generic CRC Generator/Checker
--
--	Parameters	Valid Values
--	==========	============
--	data_width	 1 to poly_size
--	poly_size	 2 to 64
--	crc_cfg		 0 to 7
--			[ 0 => Initial CRC of all zeros & non inverted insertion,
--			  1 => Initial CRC of all ones & non inverted insertion,
--			  2 => Initial CRC of all zeros & XOR ..010101 insertion,
--			  3 => Initial CRC of all ones & XOR ..010101 insertion,
--			  4 => Initial CRC of all zeros & XOR ..101010 insertion,
--			  5 => Initial CRC of all ones & XOR ..101010 insertion,
--			  6 => Initial CRC of all zeros & inverted insertion,
--			  7 => Initial CRC of all ones & inverted insertion ]
--	bit_order	 0 to 3
--			[ 0 => msb caluclated first down to lsb calculated last
--			  1 => lsb caluclated first up to msb calculated last
--			  2 => msb of low order byte calculated first to lsb of
--				high order byte calculated last
--			  3 => lsb of high order byte calculated first to msb of
--				low order byte calculated last ]
--	poly_coef0	 0 to 65535 (lowest 16 polynomial coefficient digits)
--	poly_coef1	 0 to 65535 (lower middle 16 polynomial coefficient digits)
--	poly_coef2	 0 to 65535 (upper middle 16 polynomial coefficient digits)
--	poly_coef3	 0 to 65535 (highest 16 polynomial coefficient digits)
--
--	Input Ports	Size	Description
--	===========	====	===========
--	clk		1 bit	Clock input
--	rst_n		1 bit	Asynchronous Reset (active low)
--	init_n		1 bit	Initialization input (active low)
--	enable		1 bit	Enable input (active high)
--	drain		1 bit	Drain start input (active high)
--	ld_crc_n	1 bit	CRC load control (active low)
--	data_in	     data_width	Data input stream
--	crc_in 	      poly_size	CRC value to load
--
--	Output Ports	Size	Description
--	===========	====	===========
--	draining	1 bit	Drain active status output
--	drain_done	1 bit   Drain completion status output
--	crc_ok		1 bit	CRC status output
--	data_out     data_width Output data stream (with inserted CRC)
--	crc_out       poly_size CRC Register
--
--	Example polynomial coefficients:
--	======= ========== ============
--
--	CRC-32  	poly_size => 32, poly_coef0 => 7607, poly_coef1 => 1217 (04c11db7h)
--	CRC-16		poly_size => 16, poly_coef0 => 32773 (8005h)
--	CCITT-CRC16	poly_size => 16, poly_coef0 => 4129 (1021h)
--	ATM Header CRC	poly_size => 8,  poly_coef0 => 7, (07h) crc_cfg => 2
--
-- MODIFIED:
--
--	RJK  10/4/2002  Changed type of generics from INTEGER to NATURAL so that
--			HDLC will interpret them as unsigned (STAR 153480)
--
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity DW_crc_s is

    generic (
	    data_width : NATURAL  := 16;
	    poly_size  : NATURAL  := 16;
	    crc_cfg    : NATURAL   := 7;
	    bit_order  : NATURAL   := 3;
	    poly_coef0 : NATURAL  := 4129;
	    poly_coef1 : NATURAL  := 0;
	    poly_coef2 : NATURAL  := 0;
	    poly_coef3 : NATURAL  := 0
	    );

    port    (
	    clk : in std_logic;
	    rst_n : in std_logic;
	    init_n : in std_logic;
	    enable : in std_logic;
	    drain : in std_logic;
	    ld_crc_n : in std_logic;
	    data_in : in std_logic_vector(data_width-1 downto 0);
	    crc_in : in std_logic_vector(poly_size-1 downto 0);

	    draining : out std_logic;
	    drain_done : out std_logic;
	    crc_ok : out std_logic;
	    data_out : out std_logic_vector(data_width-1 downto 0);
	    crc_out : out std_logic_vector(poly_size-1 downto 0)
	    );

end DW_crc_s;


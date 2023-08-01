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
-- AUTHOR:    Rick Kelly and Jay Zhu	January 12, 2000
--
-- VERSION:   Entity
--
-- DesignWare_version: 177158e4
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT: Generic parallel CRC Generator/Checker
--
--	Parameters	Valid Values
--	==========	============
--	data_width	 1 to 512
--	poly_size	 2 to 64
--	crc_cfg		 0 to 7
--			[0 => Initial CRC of all zeros & non inverted insertion,
--			 1 => Initial CRC of all ones & non inverted insertion,
--			 2 => Initial CRC of all zeros & XOR ..010101 insertion,
--			 3 => Initial CRC of all ones & XOR ..010101 insertion,
--			 4 => Initial CRC of all zeros & XOR ..101010 insertion,
--			 5 => Initial CRC of all ones & XOR ..101010 insertion,
--			 6 => Initial CRC of all zeros & inverted insertion,
--			 7 => Initial CRC of all ones & inverted insertion ]
--	bit_order	 0 to 3
--			[ 0 => msb calculated first down to lsb calculated last
--			  1 => lsb calculated first up to msb calculated last
--			  2 => msb of low order byte calculated first to lsb of
--				high order byte calculated last
--			  3 => lsb of high order byte calculated first to msb of
--				low order byte calculated last ]
--	poly_coef0	 1 to 65535 (lowest 16 polynomial coefficient digits)
--	poly_coef1	 0 to 65535 (lower middle 16 polynomial coef. digits)
--	poly_coef2	 0 to 65535 (upper middle 16 polynomial coef. digits)
--	poly_coef3	 0 to 65535 (highest 16 polynomial coefficient digits)
--
--	Input Ports	Size	Description
--	===========	====	===========
--	data_in       data_width Input data used for both generating
--				and checking for valid CRC
--	crc_in 	      poly_size	CRC value for CRC validation
--
--	Output Ports	Size	Description
--	===========	====	===========
--	crc_ok		1 bit	CRC validation flag
--	crc_out       poly_size CRC Generation output
--
--	Example polynomial coefficients:
--	======= ========== ============
--
--	CRC-32  	poly_size => 32, poly_coef0 => 7607, poly_coef1 => 1217
--			      (04c11db7h implies coef0 = 1db7h & coef1 = 04c1h)
--	CRC-16		poly_size => 16, poly_coef0 => 32773 (8005h)
--	CCITT-CRC16	poly_size => 16, poly_coef0 => 4129 (1021h)
--	USB Token Pkt 	poly_size => 5,  poly_coef0 => 5, (05h)
--	ATM Header CRC	poly_size => 8,  poly_coef0 => 7, (07h)
--
-- MODIFIED:
--
--	RJK  10/4/2002  Changed type of generics from INTEGER to NATURAL so that
--			HDLC will interpret them as unsigned (STAR 153480)
--
--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity DW_crc_p is

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
	    data_in : in std_logic_vector(data_width-1 downto 0);
	    crc_in : in std_logic_vector(poly_size-1 downto 0);

	    crc_ok : out std_logic;
	    crc_out : out std_logic_vector(poly_size-1 downto 0)
	    );

end DW_crc_p;

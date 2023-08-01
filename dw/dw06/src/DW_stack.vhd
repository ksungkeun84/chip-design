--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 1997 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Jay Zhu 		10/21/97
--
-- VERSION:   Entity
--
-- DesignWare_version: 239ebb85
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Stack
--
--           This stack  designed to interface to synchronous
--           true dual port RAMs.
--
--		Parameters:	Valid Values
--		==========	============
--		width		[ 1 to 256 ]
--		depth		[ 2 to 256 ]
--		err_mode	[ 0 = dynamic error flag,
--				  1 = sticky error flag ]
--		rst_mode	[ 0 = asynchronous reset control & memory,
--				  1 = synchronous reset control & memory,
--				  2 = asynchronous reset control only,
--				  3 = synchronous reset control only ]
--		
--		Input Ports:	Size	Description
--		===========	====	===========
--		clk		1 bit	Input Clock
--		rst_n		1 bit	Active Low Reset
--		push_req_n	1 bit	Active Low Push Request
--		pop_req_n	1 bit	Active Low Pop Request
--		data_in		W bits	Push Data input
--
--		Output Ports	Size	Description
--		============	====	===========
--		empty		1 bit	Empty Flag
--		full		1 bit	Full Flag
--		error		1 bit	Error Flag
--		data_out	W bits	Pop Data output
--
--
-- MODIFIED: 
--
---------------------------------------------------------------------------------
--
 
library IEEE;
use IEEE.std_logic_1164.all;
entity DW_stack is
	
	generic (
		    width : INTEGER  ;
		    depth : INTEGER  ;
		    err_mode : INTEGER  := 0;
		    rst_mode : INTEGER  := 0
		);
	
	port    (
		    clk : in std_logic;
		    rst_n : in std_logic;
		    push_req_n : in std_logic;
		    pop_req_n : in std_logic;
		    data_in : in std_logic_vector( width-1 downto 0 );
		    empty : out std_logic;
		    full : out std_logic;
		    error : out std_logic;
		    data_out : out std_logic_vector( width-1 downto 0 )
		);
end DW_stack;

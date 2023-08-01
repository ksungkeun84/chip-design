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
-- AUTHOR:    Rick Kelly		9/19/97
--
-- VERSION:   Entity
--
-- DesignWare_version: f6316db5
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Stack Controller
--
--           This Stack controller designed to interface to synchronous
--           true dual port RAMs.
--
--		Parameters:	Valid Values
--		==========	============
--		depth		[ 2 to 16777216 ]
--		err_mode	[ 0 = sticky error flag,
--				  1 = dynamic error flag ]
--		rst_mode	[ 0 = asynchronous reset,
--				  1 = synchronous reset ]
--		
--		Input Ports:	Size	Description
--		===========	====	===========
--		clk		1 bit	Input Clock
--		rst_n		1 bit	Active Low Reset
--		push_req_n	1 bit	Active Low Push Request
--		pop_req_n	1 bit	Active Low Pop Request
--
--		Output Ports	Size	Description
--		============	====	===========
--		we_n		1 bit	Active low Write Enable (to RAM)
--		empty		1 bit	Empty Flag
--		full		1 bit	Full Flag
--		error		1 bit	Error Flag
--		wr_addr		N bits	Write Address (to RAM)
--		rd_addr		N bits	Read Address (to RAM)
--
--		  Note:	the value of N for wr_addr and rd_addr is
--			determined from the parameter, depth.  The
--			value of N is equal to:
--				ceil( log2( depth ) )
--		
--
--
-- MODIFIED: 
--
---------------------------------------------------------------------------------
--
 
library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
entity DW_stackctl is
	
	generic (
		    depth : INTEGER  ;
		    err_mode : INTEGER  := 0;
		    rst_mode : INTEGER  := 0
		);
	
	port    (
		    clk : in std_logic;
		    rst_n : in std_logic;
		    push_req_n : in std_logic;
		    pop_req_n : in std_logic;
		    we_n : out std_logic;
		    empty : out std_logic;
		    full : out std_logic;
		    error : out std_logic;
		    wr_addr : out std_logic_vector( bit_width(depth)-1 downto 0 );
		    rd_addr : out std_logic_vector( bit_width(depth)-1 downto 0 )
		);
end DW_stackctl;

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
-- AUTHOR:    Rick Kelly		11/14/96
--
-- VERSION:   Entity
--
-- DesignWare_version: 8364e362
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Synchronous, dual clcok  with Static Flags
--           static programmable almost empty and almost full flags
--
--           This FIFO controller designed to interface to synchronous
--           true dual port RAMs.
--
--		Parameters:	Valid Values
--		==========	============
--		depth		[ 4 to 16777216 ]
--		push_ae_lvl	[ 1 to depth-1 ]
--		push_af_lvl	[ 1 to depth-1 ]
--		pop_ae_lvl	[ 1 to depth-1 ]
--		pop_af_lvl	[ 1 to depth-1 ]
--		err_mode	[ 0 = sticky error flag,
--				  1 = dynamic error flag ]
--		push_sync	[ 1 = single synchronized,
--				  2 = double synchronized,
--				  3 = triple synchronized ]
--		pop_sync	[ 1 = single synchronized,
--				  2 = double synchronized,
--				  3 = triple synchronized ]
--		rst_mode	[ 0 = asynchronous reset,
--				  1 = synchronous reset ]
--		tst_mode	[ 0 = test input not connected
--				  1 = test input controls lockup latches ]
--		
--		Input Ports:	Size	Description
--		===========	====	===========
--		clk_push	1 bit	Push I/F Input Clock
--		clk_pop		1 bit	Pop I/F Input Clock
--		rst_push_n	1 bit	Active Low Async Reset for push Domain
--		rst_pop_n	1 bit	Active Low Async Reset for pop Domain
--		init_push_n	1 bit	Active Low Sync Init. for push Domain
--		init_pop_n	1 bit	Active Low Sync Init. for pop Domain
--		push_req_n	1 bit	Active Low Push Request
--		pop_req_n	1 bit	Active Low Pop Request
--
--		Output Ports	Size	Description
--		============	====	===========
--		we_n		1 bit	Active low Write Enable (to RAM)
--		push_empty	1 bit	Push I/F Empty Flag
--		push_ae		1 bit	Push I/F Almost Empty Flag
--		push_hf		1 bit	Push I/F Half Full Flag
--		push_af		1 bit	Push I/F Almost Full Flag
--		push_full	1 bit	Push I/F Full Flag
--		push_error	1 bit	Push I/F Error Flag
--		pop_empty	1 bit	Pop I/F Empty Flag
--		pop_ae		1 bit	Pop I/F Almost Empty Flag
--		pop_hf		1 bit	Pop I/F Half Full Flag
--		pop_af		1 bit	Pop I/F Almost Full Flag
--		pop_full	1 bit	Pop I/F Full Flag
--		pop_error	1 bit	Pop I/F Error Flag
--		wr_addr		N bits	Write Address (to RAM)
--		rd_addr		N bits	Read Address (to RAM)
--		push_word_count M bits  Words in FIFO (push IF perception)
--		pop_word_count  M bits  Words in FIFO (push IF perception)
--		test            1 bit   Test input control (active high for
--
--		  Note:	the value of N for wr_addr and rd_addr is
--			determined from the parameter, depth.  The
--			value of N is equal to:
--				ceil( log2( depth ) )
--		
--		  Note:	the value of M for push_word_count and pop_word_count
--			is determined from the parameter, depth.  The
--			value of M is equal to:
--				ceil( log2( depth+1 ) )
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
entity DW_fifoctl_s2dr_sf is
	
	generic (
		    depth : INTEGER  := 8;
		    push_ae_lvl : INTEGER  := 2;
		    push_af_lvl : INTEGER  := 2;
		    pop_ae_lvl : INTEGER  := 2;
		    pop_af_lvl : INTEGER  := 2;
		    err_mode : INTEGER  := 0;
		    push_sync : INTEGER  := 2;
		    pop_sync : INTEGER  := 2;
		    tst_mode : INTEGER  := 0
		);
	
	port    (
		    clk_push : in std_logic;
		    clk_pop : in std_logic;
		    rst_push_n : in std_logic;
		    rst_pop_n : in std_logic;
		    init_push_n : in std_logic;
		    init_pop_n : in std_logic;
		    push_req_n : in std_logic;
		    pop_req_n : in std_logic;
		    we_n : out std_logic;
		    push_empty : out std_logic;
		    push_ae : out std_logic;
		    push_hf : out std_logic;
		    push_af : out std_logic;
		    push_full : out std_logic;
		    push_error : out std_logic;
		    pop_empty : out std_logic;
		    pop_ae : out std_logic;
		    pop_hf : out std_logic;
		    pop_af : out std_logic;
		    pop_full : out std_logic;
		    pop_error : out std_logic;
		    wr_addr : out std_logic_vector( bit_width(depth)-1 downto 0 );
		    rd_addr : out std_logic_vector( bit_width(depth)-1 downto 0 );
		    push_word_count : out std_logic_vector( bit_width(depth+1)-1 downto 0 );
		    pop_word_count : out std_logic_vector( bit_width(depth+1)-1 downto 0 );
		    test : in std_logic
		);
end DW_fifoctl_s2dr_sf;

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
-- DesignWare_version: c47deef9
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Synchronous, dual clcok with Static Flags
--           programmable almost empty and almost full flags
--
--		Parameters:	Valid Values
--		==========	============
--		width		[ 1 to 256 ]
--		depth		[ 4 to 256 ]
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
--		rst_mode	[ 0 = asynchronous reset RAM & ctlr,
--				  1 = synchronous reset RAM & ctlr,
--				  2 = asynchronous reset ctlr only,
--				  3 = synchronous reset ctlr only ]
--		
--		Input Ports:	Size	Description
--		===========	====	===========
--		clk_push	1 bit	Push I/F Input Clock
--		clk_pop		1 bit	Pop I/F Input Clock
--		rst_n		1 bit	Active Low Reset
--		push_req_n	1 bit	Active Low Push Request
--		pop_req_n	1 bit	Active Low Pop Request
--		data_in		width	Push Data input
--
--		Output Ports	Size	Description
--		============	====	===========
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
--		data_out	width	Pop Data output
--
--
--
-- MODIFIED: 
--
---------------------------------------------------------------------------------
--
 
library IEEE,DWARE;
use IEEE.std_logic_1164.all;
entity DW_fifo_s2_sf is
	
	generic (
		    width : INTEGER  := 8;
		    depth : INTEGER  := 8;
		    push_ae_lvl : INTEGER  := 2;
		    push_af_lvl : INTEGER  := 2;
		    pop_ae_lvl : INTEGER  := 2;
		    pop_af_lvl : INTEGER  := 2;
		    err_mode : INTEGER  := 0;
		    push_sync : INTEGER  := 2;
		    pop_sync : INTEGER  := 2;
		    rst_mode : INTEGER  := 0
		);
	
	port    (
		    clk_push : in std_logic;
		    clk_pop : in std_logic;
		    rst_n : in std_logic;
		    push_req_n : in std_logic;
		    pop_req_n : in std_logic;
		    data_in : in std_logic_vector(width-1 downto 0);
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
		    data_out : out std_logic_vector( width-1 downto 0 )
		);
end DW_fifo_s2_sf;

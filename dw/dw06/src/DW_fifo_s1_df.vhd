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
-- DesignWare_version: 9bde8786
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Synchronous with Dynamic Flags
--           dynamic programmable almost empty and almost full flags
--
--           This FIFO  designed to interface to synchronous
--           true dual port RAMs.
--
--		Parameters:	Valid Values
--		==========	============
--		width		[ 1 to 2048 ]
--		depth		[ 2 to 1024 ]
--              err_mode        [ 0 = sticky error flag w/ ptr check,
--                                1 = sticky error flag (no ptr chk),
--                                2 = dynamic error flag ]
--		rst_mode	[ 0 = asynchronous reset control & memory,
--				  1 = synchronous reset control & memory,
--				  2 = asynchronous reset control only,
--				  3 = synchronous reset control only ]
--		
--		Input Ports:	Size	Description
--		===========	====	===========
--		clk		1 bit	Input Clock
--		rst_n  		1 bit	Active Low Reset
--		push_req_n	1 bit	Active Low Push Request
--		pop_req_n	1 bit	Active Low Pop Request
--		diag_n		1 bit	Active Low diagnostic input
--              ae_level        N bits  Almost Empty level
--              af_thresh       N bits  Almost Full threshold
--              data_in         W bits  Push Data input
--
--		Output Ports	Size	Description
--		============	====	===========
--		empty		1 bit	Empty Flag
--		almost_empty	1 bit	Almost Empty Flag
--		half_full	1 bit	Half Full Flag
--		almost_full	1 bit	Almost Full Flag
--		full		1 bit	Full Flag
--		error		1 bit	Error Flag
--		data_out	W bits	Pop Data output
--
--		  Note:	the value of N for wr_addr and rd_addr is
--			determined from the parameter, depth.  The
--			value of N is equal to:
--				ceil( log2( depth ) )
--		
--
--
-- MODIFIED: 
--		RJK	03/16/11
--		Increased width and depth limits to 2048 & 1024 respectively.
--		STAR 9000371459
--
---------------------------------------------------------------------------------
--
 
library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
entity DW_fifo_s1_df is
	
	generic (
		    width : INTEGER  := 8;
		    depth : INTEGER  := 4;
		    err_mode : INTEGER  := 0;
		    rst_mode : INTEGER  := 0
		);
	
	port    (
		    clk : in std_logic;
		    rst_n : in std_logic;
		    push_req_n : in std_logic;
		    pop_req_n : in std_logic;
		    diag_n : in std_logic;
		    ae_level : in std_logic_vector( bit_width(depth)-1 downto 0 );
		    af_thresh : in std_logic_vector( bit_width(depth)-1 downto 0 );
		    data_in : in std_logic_vector( width-1 downto 0 );
		    empty : out std_logic;
		    almost_empty : out std_logic;
		    half_full : out std_logic;
		    almost_full : out std_logic;
		    full : out std_logic;
		    error : out std_logic;
		    data_out : out std_logic_vector( width-1 downto 0 )
		);
end DW_fifo_s1_df;

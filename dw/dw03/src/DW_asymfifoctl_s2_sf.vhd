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
-- AUTHOR:    J. Jay Zhu		07/15/98
--
-- VERSION:   Entity
--
-- DesignWare_version: c53a36b8
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Asymmetric Synchronous, dual clcok with Static Flags
--           (FIFO) with static programmable almost empty and almost
--           full flags.
--
--           This FIFO controller designed to interface to synchronous
--           true dual port RAMs.
--
--		Parameters:	Valid Values
--		==========	============
--		data_in_width	[1 to 4096]
--		data_out_width	[1 to 4096]
--                  Note: data_in_width and data_out_width must be
--                        in integer multiple relationship: either
--                              data_in_width = K * data_out_width
--                        or    data_out_width = K * data_in_width
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
--		byte_order	[ 0 = the first byte is in MSBs
--				  1 = the first byte is in LSBs ]
--		
--		Input Ports:	Size	Description
--		===========	====	===========
--		clk_push	1 bit	Push I/F Input Clock
--		clk_pop		1 bit	Pop I/F Input Clock
--		rst_n		1 bit	Active Low Reset
--		push_req_n	1 bit	Active Low Push Request
--              flush_n         1 bit   Flush the partial word into
--                                      the full word memory.  For
--                                      data_in_width<data_out_width
--                                      only
--		pop_req_n	1 bit	Active Low Pop Request
--              data_in         L bits  FIFO data to push
--              rd_data         M bits  RAM data input to asymmetric
--                                      FIFO controller
--
--		Output Ports	Size	Description
--		============	====	===========
--		we_n		1 bit	Active low Write Enable (to RAM)
--		push_empty	1 bit	Push I/F Empty Flag
--		push_ae		1 bit	Push I/F Almost Empty Flag
--		push_hf		1 bit	Push I/F Half Full Flag
--		push_af		1 bit	Push I/F Almost Full Flag
--		push_full	1 bit	Push I/F Full Flag
--		ram_full	1 bit	Push I/F ram Full Flag
--              part_wd         1 bit   Partial word read flag.  For
--                                      data_in_width<data_out_width
--                                      only
--		push_error	1 bit	Push I/F Error Flag
--		pop_empty	1 bit	Pop I/F Empty Flag
--		pop_ae		1 bit	Pop I/F Almost Empty Flag
--		pop_hf		1 bit	Pop I/F Half Full Flag
--		pop_af		1 bit	Pop I/F Almost Full Flag
--		pop_full	1 bit	Pop I/F Full Flag
--		pop_error	1 bit	Pop I/F Error Flag
--              wr_data         M bits  FIFO controller output data
--                                      to RAM
--		wr_addr		N bits	Write Address (to RAM)
--		rd_addr		N bits	Read Address (to RAM)
--              data_out        O bits  FIFO data to pop
--
--                Note: the value of L is parameter data_in_width
--                Note: the value of M is
--                         maximum(data_in_width, data_out_width)
--		  Note:	the value of N for wr_addr and rd_addr is
--			determined from the parameter, depth.  The
--			value of N is equal to:
--				ceil( log2( depth ) )
--		  Note: the value of O is parameter data_out_width
--		
--
--
-- MODIFIED:
--
------------------------------------------------------------------------
--
library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DW_Foundation_arith.all;
entity DW_asymfifoctl_s2_sf is
	
	generic (
		    data_in_width  : INTEGER  ;
		    data_out_width : INTEGER  ;
		    depth : INTEGER  := 8;
		    push_ae_lvl : INTEGER  := 2;
		    push_af_lvl : INTEGER  := 2;
		    pop_ae_lvl : INTEGER  := 2;
		    pop_af_lvl : INTEGER  := 2;
		    err_mode : INTEGER  := 0;
		    push_sync : INTEGER  := 2;
		    pop_sync : INTEGER  := 2;
		    rst_mode : INTEGER  := 1;
		    byte_order : INTEGER  := 0
		);
	
	port    (
		    clk_push : in std_logic;
		    clk_pop : in std_logic;
		    rst_n : in std_logic;
		    push_req_n : in std_logic;
		    flush_n : in std_logic;
		    pop_req_n : in std_logic;
		    data_in : in std_logic_vector(data_in_width-1 downto 0);
		    rd_data : in std_logic_vector(maximum(data_in_width,
		    			data_out_width)-1 downto 0);
		    we_n : out std_logic;
		    push_empty : out std_logic;
		    push_ae : out std_logic;
		    push_hf : out std_logic;
		    push_af : out std_logic;
		    push_full : out std_logic;
		    ram_full : out std_logic;
		    part_wd : out std_logic;
		    push_error : out std_logic;
		    pop_empty : out std_logic;
		    pop_ae : out std_logic;
		    pop_hf : out std_logic;
		    pop_af : out std_logic;
		    pop_full : out std_logic;
		    pop_error : out std_logic;
		    wr_data : out std_logic_vector(maximum(data_in_width,
		    			data_out_width)-1 downto 0);
		    wr_addr : out std_logic_vector( bit_width(depth)-1 downto 0 );
		    rd_addr : out std_logic_vector( bit_width(depth)-1 downto 0 );
		    data_out : out std_logic_vector(data_out_width-1
		    			downto 0)
		);
end DW_asymfifoctl_s2_sf;

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
-- AUTHOR:    Jay Zhu		October 30, 1997
--
-- VERSION:   Entity
--
-- DesignWare_version: 0afd6d03
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Asymmetric, Synchronous with Static Flags 
--           (FIFO) with static programmable almost empty and almost
--           full flags.
--
--           This FIFO controller designed to interface to synchronous
--           true dual port RAMs.
--
--		Parameters:	Valid Values
--		==========	============
--		data_in_width	[ 1 to 256]
--		data_out_width	[ 1 to 256]
--                  Note: data_in_width and data_out_width must be
--                        in integer multiple relationship: either
--                              data_in_width = K * data_out_width
--                        or    data_out_width = K * data_in_width
--		depth		[ 2 to 16777216 ]
--		ae_level	[ 1 to depth-1 ]
--		af_level	[ 1 to depth-1 ]
--		err_mode	[ 0 = dynamic error flag,
--				  1 = sticky error flag ]
--		rst_mode	[ 0 = asynchronous reset,
--				  1 = synchronous reset ]
--		byte_order	[ 0 = the first byte is in MSBs
--				  1 = the first byte is in LSBs ]
--		
--		Input Ports:	Size	Description
--		===========	====	===========
--		clk		1 bit	Input Clock
--		rst_n		1 bit	Active Low Reset
--		push_req_n	1 bit	Active Low Push Request
--              flush_n         1 bit   Flush the partial word into
--                                      the full word memory.  For
--                                      data_in_width<data_out_width
--                                      only
--		pop_req_n	1 bit	Active Low Pop Request
--		diag_n		1 bit	Active Low diagnostic input
--              data_in         L bits  FIFO data to push
--              rd_data         M bits  RAM data input to asymmetric
--                                      FIFO controller
--
--		Output Ports	Size	Description
--		============	====	===========
--		we_n		1 bit	Active low Write Enable (to RAM)
--		empty		1 bit	Empty Flag
--		almost_empty	1 bit	Almost Empty Flag
--		half_full	1 bit	Half Full Flag
--		almost_full	1 bit	Almost Full Flag
--		full		1 bit	Full Flag
--		ram_full	1 bit	Full Flag for RAM
--		error		1 bit	Error Flag
--              part_wd         1 bit   Partial word read flag.  For
--                                      data_in_width<data_out_width
--                                      only
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
-- MODIFIED:
--
---------------------------------------------------------------------------------
--
library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
entity DW_asymfifoctl_s1_sf is
	
	generic (
		    data_in_width  : INTEGER  ;
		    data_out_width : INTEGER  ;
		    depth      : INTEGER  ;
		    ae_level   : INTEGER  ;
		    af_level   : INTEGER  ;
		    err_mode   : INTEGER  := 1;
		    rst_mode   : INTEGER  := 1;
		    byte_order : INTEGER  := 0
		);
	
	port    (
		    clk : in std_logic;
		    rst_n : in std_logic;
		    push_req_n : in std_logic;
		    flush_n : in std_logic;
		    pop_req_n : in std_logic;
		    diag_n : in std_logic;
		    data_in : in std_logic_vector(data_in_width-1 downto 0);
		    rd_data : in std_logic_vector(maximum(data_in_width,
		    			data_out_width)-1 downto 0);
		    we_n : out std_logic;
		    empty : out std_logic;
		    almost_empty : out std_logic;
		    half_full : out std_logic;
		    almost_full : out std_logic;
		    full : out std_logic;
		    ram_full : out std_logic;
		    error : out std_logic;
		    part_wd : out std_logic;
		    wr_data : out std_logic_vector(maximum(data_in_width,
		    			data_out_width)-1 downto 0);
		    wr_addr : out std_logic_vector( bit_width(depth)-1 downto 0 );
		    rd_addr : out std_logic_vector( bit_width(depth)-1 downto 0 );
		    data_out : out std_logic_vector(data_out_width-1
		    			downto 0)
		);
end DW_asymfifoctl_s1_sf;

--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2006 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Doug Lee 	04/25/06
--
-- VERSION:   Entity
--
-- DesignWare_version: a20be3cb
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT: Input registers used for asymmetric fifos when the
--           input data width is less than and an integer multiple
--           of the output data width.
--
--              Parameters:     Valid Values
--              ==========      ============
--              in_width        [ 1 to 256]
--              out_width       [ 1 to 256]
--                  Note: in_width must be less than
--                        out_width and an integer multiple:
--                        that is, out_width = K * in_width
--              err_mode        [ 0 = sticky error flag,
--                                1 = dynamic error flag ]
--              byte_order      [ 0 = the first byte (or subword) is in MSBs
--                                1 = the first byte  (or subword)is in LSBs ]
--              flush_value     [ 0 = fill empty bits of partial word with 0's upon flush
--                                1 = fill empty bits of partial word with 1's upon flush ]
--
--              Input Ports     Size    Description
--              ===========     ====    ===========
--              clk_push        1 bit   Push I/F Input Clock
--              rst_push_n      1 bit   Async. Push Reset (active low)
--              init_push_n     1 bit   Sync. Push Reset (active low)
--              push_req_n      1 bit   Push Request (active low)
--              data_in         M bits  Data subword being pushed
--              flush_n         1 bit   Flush the partial word into
--                                      the full word memory (active low)
--              fifo_full       1 bit   Full indicator of RAM/FIFO
--
--              Output Ports    Size    Description
--              ============    ====    ===========
--              push_wd_n       1 bit   Full word ready for transfer (active low)
--              data_out        N bits  Data word into RAM or FIFO
--              inbuf_full      1 bit   Inbuf registers all contain active data_in subwords
--              part_wd         1 bit   Partial word pushed flag
--              push_error      1 bit   Overrun of RAM or FIFO (includes inbuf registers)
--
--                Note: M is the value of the parameter in_width
--                      N is the value of the parameter out_width
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
entity DW_asymdata_inbuf is
	
	generic (
		    in_width    : INTEGER  := 8;
		    out_width   : INTEGER  := 16;
		    err_mode    : INTEGER  := 0;
		    byte_order  : INTEGER  := 0;
		    flush_value : INTEGER  := 0
		);
	
	port    (
		    clk_push     : in std_logic;
		    rst_push_n   : in std_logic;
		    init_push_n  : in std_logic;
		    push_req_n   : in std_logic;
		    data_in      : in std_logic_vector(in_width-1 downto 0);
		    flush_n      : in std_logic;
		    fifo_full    : in std_logic;

		    push_wd_n    : out std_logic;
		    data_out     : out std_logic_vector(out_width-1 downto 0);
		    inbuf_full   : out std_logic;
		    part_wd      : out std_logic;
		    push_error   : out std_logic
		);
end DW_asymdata_inbuf;

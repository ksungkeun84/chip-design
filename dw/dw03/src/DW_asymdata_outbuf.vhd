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
-- AUTHOR:    Doug Lee   May 25, 2006
--
-- VERSION:   Entity
--
-- DesignWare_version: 9175a537
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT: Asymmetric Data Transfer Output Buffer Entity
--           Output multiplexer used for asymmetric data transfers when the
--           input data width is greater than and an integer multiple
--           of the output data width.
--
--              Parameters:     Valid Values
--              ==========      ============
--              in_width        [ 1 to 256]
--              out_width       [ 1 to 256]
--                  Note: in_width must be greater than
--                        out_width and an integer multiple:
--                        that is, in_width = K * out_width
--              err_mode        [ 0 = sticky error flag,
--                                1 = dynamic error flag ]
--              byte_order      [ 0 = the first byte (or subword) is in MSBs
--                                1 = the first byte (or subword) is in LSBs ]
--
--              Input Ports     Size    Description
--              ===========     ====    ===========
--              clk_pop         1 bit   Pop I/F Input Clock
--              rst_pop_n       1 bit   Async. Pop Reset (active low)
--              init_pop_n      1 bit   Sync. Pop Reset (active low)
--              pop_req_n       1 bit   Active Low Pop Request
--              data_in         M bits  Data full word being popped
--              fifo_empty      1 bit   Empty indicator from fifoctl that RAM/FIFO is empty
--
--              Output Ports    Size    Description
--              ============    ====    ===========
--              pop_wd_n        1 bit   Full word read (active low)
--              data_out        N bits  Data subword into RAM or FIFO
--              part_wd         1 bit   Partial word poped flag
--              pop_error       1 bit   Underrun of RAM or FIFO
--
--                Note: M is the value of the parameter in_width
--                      N is the value of the parameter out_width
--
--
--
-- MODIFIED: 
--
--    DLL    10/06/11   Changed in_width and out_width default values.
--
---------------------------------------------------------------------------------
--
 
library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
entity DW_asymdata_outbuf is
	
	generic (
		    in_width    : INTEGER  := 16;
		    out_width   : INTEGER  := 8;
		    err_mode    : INTEGER  := 0;
		    byte_order  : INTEGER  := 0
		);
	
	port    (
		    clk_pop      : in std_logic;
		    rst_pop_n    : in std_logic;
		    init_pop_n   : in std_logic;
		    pop_req_n    : in std_logic;
		    data_in      : in std_logic_vector(in_width-1 downto 0);
		    fifo_empty   : in std_logic;

		    pop_wd_n     : out std_logic;
		    data_out     : out std_logic_vector(out_width-1 downto 0);
		    part_wd      : out std_logic;
		    pop_error    : out std_logic
		);
end DW_asymdata_outbuf;

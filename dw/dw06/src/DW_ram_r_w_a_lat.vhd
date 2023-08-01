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
-- AUTHOR:    SS                 Feb. 25 1997
--
-- VERSION:   entity
--
-- DesignWare_version: 5ae90281
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Dual-Port RAM (Latch-Based)
--             (latch memory array)
--
--              Parameters:     Valid Values
--              ===========     ============
--              data_width      [ 1 to 256 ]
--              depth           [ 2 to 256 ]
--              rst_mode        [ 0 = asynchronous reset,
--                                1 = no reset ]
--
--              Input Ports:    Description
--              ============    ===========
--              rst_n           Reset (active low)
--              cs_n            Chip Select (active low)
--              wr_n            Write Enable (active low)
--              rd_addr         Read address Bus [ceil( log2(depth) )]
--              wr_addr         Write address Bus [ceil( log2(depth) )]
--              data_in         Input data [data_width-1:0]
--
--              Output Ports:   Description
--              =============   ===========
--              data_out        Output data [data_width-1:0]
--
--      NOTE: This RAM is intended to be used as a scratchpad memory only.
--              For best results keep "depth" and "data_width" less than 65
--              (ie. less than 64 words in RAM) and the overall number of
--              bits less than 256.
--
--
-- MODIFIED:
------------------------------------------------------------------------------
library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
entity DW_ram_r_w_a_lat is
  generic(data_width : INTEGER;
          depth      : INTEGER ;
	  rst_mode   : INTEGER  := 1);
  port(rst_n	: in std_logic;
       cs_n     : in std_logic;
       wr_n     : in std_logic;
       rd_addr	: in std_logic_vector(bit_width(depth)-1 downto 0);
       wr_addr	: in std_logic_vector(bit_width(depth)-1 downto 0);
       data_in	: in std_logic_vector(data_width-1 downto 0);
       data_out	: out std_logic_vector(data_width-1 downto 0));
end DW_ram_r_w_a_lat;

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
-- AUTHOR:    SS			Mar. 4, 1997
--
-- VERSION:   Entity
--
-- DesignWare_version: d86ff562
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Synch Write, Asynch Read RAM (Latch-Based)
--            (latch based memory array)
--
--              Parameters:     Valid Values
--              ===========     ============
--              data_width      [ 1 to 256 ]
--              depth           [ 2 to 256 ]
--
--              Input Ports:    Description
--              ============    ===========
--              clk             Clock Signal
--              cs_n            Chip Select (active low)
--              wr_n            Write Enable (active low)
--              rd_addr         Read Address Bus [ceil( log2(depth) )]
--              wr_addr         Write Address Bus [ceil( log2(depth) )]
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
---------------------------------------------------------------------------------
library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
entity DW_ram_r_w_s_lat is
  generic(data_width : INTEGER;
          depth      : INTEGER ); 
  port(clk	: in std_logic;
       cs_n     : in std_logic;
       wr_n     : in std_logic;
       rd_addr  : in std_logic_vector(bit_width(depth)-1 downto 0);
       wr_addr  : in std_logic_vector(bit_width(depth)-1 downto 0);
       data_in  : in std_logic_vector(data_width-1 downto 0);
       data_out : out std_logic_vector(data_width-1 downto 0));
end DW_ram_r_w_s_lat;

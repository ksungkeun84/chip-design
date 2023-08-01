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
-- AUTHOR:    SS                 Feb. 11 1997
--
-- VERSION:   entity
--
-- DesignWare_version: 6a524a01
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Three-Port RAM (Flip-Flop Based)
--            (flip flop memory array)
--            legal range: {2 <= depth <= 256 }
--            legal range: { 1 <= data_width <= 256}
--            Input data: data_in[data_width-1:0]
--            Output data from rd1_addr: data_rd1_out[data_width-1:0]
--            Output data from rd2_addr: data_rd2_out[data_width-1:0]
--            Read1 Address: rd1_addr[addr_width-1:0]
--            Read2 Address: rd2_addr[addr_width-1:0]
--            Write Address: wr_addr[addr_width-1:0]
--            write enable (active low): wr_n
--            chip select (active low): cs_n
--            reset (active low): rst_n
--            Testing signals : test_mode and test_clk 
--            NOTE: This RAM is intended to be used as a scratchpad memory only.
--                  For best results keep "depth" and "data_width" less than 65 
--                  (ie. less than 64 words in RAM) and the overall number of
--                  bits less than 256.
--
--
--
--
-- MODIFIED:
---------------------------------------------------------------------------------
library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
entity DW_ram_2r_w_a_dff is
  generic(data_width : INTEGER;
          depth      : INTEGER ;
          rst_mode : INTEGER  := 1);
  port(rst_n	    : in std_logic;
       cs_n	    : in std_logic;
       wr_n         : in std_logic;
       test_mode    : in std_logic;
       test_clk     : in std_logic;
       rd1_addr	    : in std_logic_vector(bit_width(depth)-1 downto 0);
       rd2_addr	    : in std_logic_vector(bit_width(depth)-1 downto 0);
       wr_addr	    : in std_logic_vector(bit_width(depth)-1 downto 0);
       data_in	    : in std_logic_vector(data_width-1 downto 0);
       data_rd1_out : out std_logic_vector(data_width-1 downto 0);
       data_rd2_out : out std_logic_vector(data_width-1 downto 0));
end DW_ram_2r_w_a_dff;

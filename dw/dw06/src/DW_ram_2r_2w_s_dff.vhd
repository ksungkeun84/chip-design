--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2014 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Rick Kelly			July 1, 2014
--
-- VERSION:   Entity
--
-- DesignWare_version: 9a294c8b
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Four port (2 read, 2 write) synchronous write, asynchronous read
--            RAM constructed with D-FFs.
--
---------------------------------------------------------------------------------
library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
entity DW_ram_2r_2w_s_dff is
  generic(width : INTEGER;
          addr_width : INTEGER ; 
          rst_mode : INTEGER  := 0); 
  port(clk	: in std_logic;
       rst_n    : in std_logic;

       en_w1_n  : in std_logic;
       addr_w1  : in std_logic_vector(addr_width-1 downto 0);
       data_w1  : in std_logic_vector(width-1 downto 0);

       en_w2_n  : in std_logic;
       addr_w2  : in std_logic_vector(addr_width-1 downto 0);
       data_w2  : in std_logic_vector(width-1 downto 0);

       en_r1_n  : in std_logic;
       addr_r1  : in std_logic_vector(addr_width-1 downto 0);
       data_r1  : out std_logic_vector(width-1 downto 0);

       en_r2_n  : in std_logic;
       addr_r2  : in std_logic_vector(addr_width-1 downto 0);
       data_r2  : out std_logic_vector(width-1 downto 0));
end DW_ram_2r_2w_s_dff;

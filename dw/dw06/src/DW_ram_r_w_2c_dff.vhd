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
-- AUTHOR:    Doug Lee        9/6/06
--
-- VERSION:   Entity
--
-- DesignWare_version: dd2e0b8a
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Synchronous Two-Clock RAM (one clock for the write port and
--            one clock for the read port)
--
--            Parameters:     Valid Values
--            ==========      ============
--             width          [ 1 to 1024 ]
--             depth          [ 2 to 1024 ]
--             addr_width     ceil(log2(depth)) [ 1 to 10 ]
--             mem_mode       [ 0 to 7 ]
--             rst_mode       [ 0 => resets clear RAM array
--                              1 => reset do not clear RAM ]
--
--            Write Port Interface
--            ====================
--            Ports           Size      Description
--            =====           ====      ===========
--            clk_w            1        Write Port clock
--            rst_w_n          1        Active Low Asynchronous Reset (write clock domain)
--            init_w_n         1        Active Low Synchronous  Reset (write clock domain)
--            en_w_n           1        Active Low Write Enable input
--            addr_w       addr_width   write address input
--            data_w         width      write data input
--
--            Read Port Interface
--            ====================
--            Ports           Size      Description
--            =====           ====      ===========
--            clk_r            1        Read Port clock 
--            rst_r_n          1        Active Low Asynchronous Reset (read clock domain)
--            init_r_n         1        Active Low Synchronous  Reset (read clock domain)
--            en_r_n           1        Active Low Read Enable input
--            addr_r       addr_width   read address input
--            data_r_a         1        read data arrival output
--            data_r         width      read data output
--
--
-- MODIFIED: 
--   10/12/09   DLL  Changed lower bound of 'depth' from 4 to 2.
--
---------------------------------------------------------------------------------
--
 
library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
entity DW_ram_r_w_2c_dff is
	
	generic (
		    width        : POSITIVE  := 8;
		    depth        : POSITIVE  := 8;
                    addr_width   : NATURAL   := 3;
                    mem_mode     : NATURAL    := 5;
		    rst_mode     : NATURAL    := 1
		);
	
	port    (
                    clk_w           : in std_logic;
                    rst_w_n         : in std_logic;
                    init_w_n        : in std_logic;
                    en_w_n          : in std_logic;
                    addr_w          : in std_logic_vector( bit_width(depth)-1 downto 0);
                    data_w          : in std_logic_vector(width-1 downto 0);

                    clk_r           : in std_logic;
                    rst_r_n         : in std_logic;
                    init_r_n        : in std_logic;
                    en_r_n          : in std_logic;
                    addr_r          : in std_logic_vector( bit_width(depth)-1 downto 0);
                    data_r_a        : out std_logic;
		    data_r          : out std_logic_vector(width-1 downto 0)
		);
end DW_ram_r_w_2c_dff;

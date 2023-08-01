--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2007 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Doug Lee   4/30/07
--
-- VERSION:   Entity
--
-- DesignWare_version: b50f286a
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT: Entity for Low Power Single-clock FIFO Controller with Caching and Dynamic Flags
--
--           This FIFO controller is designed to interface to synchronous
--           dual port synchronous RAMs.  It contains word caching (pop
--           interface) and status flags that are dynamically configured.
--
--
--      Parameters     Valid Values   Description
--      ==========     ============   ===========
--      width           1 to 4096     default: 8
--                                    Width of data to/from RAM
--
--      depth         4 to 268435456  default: 8
--                                    Depth of the FIFO (includes RAM, cache, and write re-timing stage)
--
--      mem_mode         0 to 7       default: 3
--                                    Defines where and how many re-timing stages:
--                                      0 => no pre or post retiming
--                                      1 => RAM data out (post) re-timing
--                                      2 => RAM read address (pre) re-timing
--                                      3 => RAM data out  and read address re-timing
--                                      4 => RAM write interface (pre) re-timing
--                                      5 => RAM write interface and RAM data out re-timing
--                                      6 => RAM write interface and read address re-timing
--                                      7 => RAM write interface, read address, and read address re-timing
--
--      arch_type        0 to 4       default: 1
--                                    Datapath architecture configuration
--                                      0 => no input re-timing, no pre-fetch cache
--                                      1 => no input re-timing, pre-fetch pipeline cache
--                                      2 => input re-timing, pre-fetch pipeline cache
--                                      3 => no input re-timing, pre-fetch register file cache
--                                      4 => input re-timing, pre-fetch register file cache
--
--      af_from_top      0 or 1       default: 1
--                                    Almost full level input (af_level) usage
--                                      0 => the af_level input value represents the minimum
--                                           number of valid FIFO entries at which the almost_full
--                                           output starts being asserted
--                                      1 => the af_level input value represents the maximum number
--                                           of unfilled FIFO entries at which the almost_full
--                                           output starts being asserted
--
--      ram_re_ext       0 or 1       default: 0
--                                    Determines the charateristic of the ram_re_d_n signal to RAM
--                                      0 => Single-cycle pulse of ram_re_d_n at the read event to RAM
--                                      1 => Extend assertion of ram_re_d_n while read event active in RAM
--
--      err_mode         0 or 1       default: 0
--                                    Error Reporting Behavior
--                                      0 => sticky error flag
--                                      1 => dynamic error flag
--
--
--		
--      Inputs           Size       Description
--      ======           ====       ===========
--      clk                1        Clock
--      rst_n              1        Asynchronous reset (active low)
--      init_n             1        Synchronous reset (active low)
--      ae_level           N        Almost empty threshold setting (for the almost_empty output)
--      af_level           N        Almost full threshold setting (for the almost_full output)
--      level_change       1        Almost empty and/or almost full level is being changed (active high pulse)
--      push_n             1        Push request (active low)
--      data_in            M        Data input
--      pop_n              1        Pop request (active low)
--      rd_data	           M        Data read from RAM
--
--
--      Outputs          Size       Description
--      =======          ====       ===========
--      ram_we_n           1        Write enable to RAM (active low)
--      wr_addr            P        Write address to RAM (registered)
--      wr_data            M        Data written to RAM
--      ram_re_n           1        Read enable to RAM (active low)
--      rd_addr            P        Read address to RAM (registered)
--      data_out           M        Data output
--      word_cnt           N        FIFO word count
--      empty              1        FIFO empty flag
--      almost_empty       1        Almost empty flag (determined by ae_level input)
--      half_full          1        Half full flag
--      almost_full        1        Almost full flag (determined by af_level input)
--      full               1        Full flag
--      error              1        Error flag (overrun or underrun)
--
--
--           Note: M is equal to the "width" parameter
--
--           Note: N is based on "depth":
--                   N = ceil(log2(depth+1))
--
--           Note: P is ceil(log2(ram_depth)) (see Note immediately below about "ram_depth")
--
--           Note: "ram_depth" is not a parameter but is based on parameter
--                 "depth", "mem_mode", and "arch_type":
--      
--                  If arch_type is '0', then:
--                       ram_depth = depth.
--                  If arch_type is '1' or '3', then:
--                       ram_depth = depth-1 when mem_mode = 0
--                       ram_depth = depth-2 when mem_mode = 1, 2, 4, or 6
--                       ram_depth = depth-3 when mem_mode = 3, 5, or 7
--                  If arch_type is '2' or '4', then:
--                       ram_depth = depth-2 when mem_mode = 0
--                       ram_depth = depth-3 when mem_mode = 1, 2, 4, or 6
--                       ram_depth = depth-4 when mem_mode = 3, 5, or 7
--
--
-- MODIFIED: 
--
--
--
library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
-- #define _depth_offset  minimum(arch_type*3, (2+(mem_mode mod 2)+(mem_mode/2)-(mem_mode/4)-(mem_mode/6)-(arch_type mod 2)))
entity DW_lp_fifoctl_1c_df is
	generic (
                    width        : POSITIVE  := 8;
                    depth        : POSITIVE  := 8;
                    mem_mode     : NATURAL    := 3;
                    arch_type    : NATURAL    := 1;
                    af_from_top  : NATURAL    := 1;
                    ram_re_ext   : NATURAL    := 0;
                    err_mode     : NATURAL    := 0
		);
	
	port    (
                    clk          : in std_logic;
                    rst_n        : in std_logic;
                    init_n       : in std_logic;
                    ae_level     : in std_logic_vector(bit_width(depth+1)-1 downto 0);
                    af_level     : in std_logic_vector(bit_width(depth+1)-1 downto 0);
                    level_change : in std_logic;
                    push_n       : in std_logic;
                    data_in      : in std_logic_vector(width-1 downto 0);
                    pop_n        : in std_logic;
                    rd_data      : in std_logic_vector(width-1 downto 0);

                    ram_we_n     : out std_logic;
                    wr_addr      : out std_logic_vector(bit_width(depth-minimum(arch_type*3, (2+(mem_mode mod 2)+(mem_mode/2)-(mem_mode/4)-(mem_mode/6)-(arch_type mod 2))))-1 downto 0);
                    wr_data      : out std_logic_vector(width-1 downto 0);
                    ram_re_n     : out std_logic;
                    rd_addr      : out std_logic_vector(bit_width(depth-minimum(arch_type*3, (2+(mem_mode mod 2)+(mem_mode/2)-(mem_mode/4)-(mem_mode/6)-(arch_type mod 2))))-1 downto 0);
                    data_out     : out std_logic_vector(width-1 downto 0);
                    word_cnt     : out std_logic_vector(bit_width(depth+1)-1 downto 0);
                    empty        : out std_logic;
                    almost_empty : out std_logic;
                    half_full    : out std_logic;
                    almost_full  : out std_logic;
                    full         : out std_logic;
                    error        : out std_logic
		);
end DW_lp_fifoctl_1c_df;

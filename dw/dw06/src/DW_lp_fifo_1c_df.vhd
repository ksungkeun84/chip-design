--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2009 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Doug Lee   9/20/09
--
-- VERSION:   Entity
--
-- DesignWare_version: 6e0d54a5
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT: Entity for Single-clock FIFO with Dynamic Flags
--
--
--           This FIFO incorporates a single-clock FIFO controller with
--           caching and dynamic flags along with a synchronous
--           dual port synchronous RAM.
--
--
--      Parameters     Valid Values   Description
--      ==========     ============   ===========
--      width           1 to 1024     default: 8
--                                    Width of data to/from FIFO
--
--      depth           4 to 1024     default: 8
--                                    Depth of the FIFO (includes RAM, cache, and write re-timing stage)
--
--      mem_mode         0 to 7       default: 3
--                                    Defines where and how many re-timing stages used in RAM:
--                                      0 => no pre or post retiming
--                                      1 => RAM data out (post) re-timing
--                                      2 => RAM read address (pre) re-timing
--                                      3 => RAM data out and read address re-timing
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
--                                    Determines the charateristic of the ram_re_n signal to RAM
--                                      0 => Single-cycle pulse of ram_re_n at the read event to RAM
--                                      1 => Extend assertion of ram_re_n while read event active in RAM
--
--      err_mode         0 or 1       default: 0
--                                    Error Reporting Behavior
--                                      0 => sticky error flag
--                                      1 => dynamic error flag
--
--      rst_mode         0 to 3       default: 0
--                                    System Reset Mode which defines the affect of ‘rst_n’ :
--                                      0 => asynchronous reset including clearing the RAM
--                                      1 => asynchronous reset not including clearing the RAM
--                                      2 => synchronous reset including clearing the RAM
--                                      3 => synchronous reset not including clearing the RAM
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
--
--
--      Outputs          Size       Description
--      =======          ====       ===========
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
--           Note: N is equal to ceil(log2(depth+1))
--
--
-- MODIFIED: 
--
--
--
library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
entity DW_lp_fifo_1c_df is
	generic (
                    width        : POSITIVE  := 8;
                    depth        : POSITIVE  := 8;
                    mem_mode     : NATURAL    := 3;
                    arch_type    : NATURAL    := 1;
                    af_from_top  : NATURAL    := 1;
                    ram_re_ext   : NATURAL    := 0;
                    err_mode     : NATURAL    := 0;
                    rst_mode     : NATURAL    := 0
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
                    data_out     : out std_logic_vector(width-1 downto 0);
                    word_cnt     : out std_logic_vector(bit_width(depth+1)-1 downto 0);
                    empty        : out std_logic;
                    almost_empty : out std_logic;
                    half_full    : out std_logic;
                    almost_full  : out std_logic;
                    full         : out std_logic;
                    error        : out std_logic
		);
end DW_lp_fifo_1c_df;

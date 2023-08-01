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
-- AUTHOR:    Doug Lee        10/24/09
--
-- VERSION:   Entity
--
-- DesignWare_version: f5030ec8
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
--
-- ABSTRACT: Dual clock domain interface assymetric FIFO controller Entity
--
--           Used for assymetric FIFOs with synchronous pipelined RAMs and
--           external caching.  Status flags are dynamically
--           configured.
--
--
--      Parameters     Valid Values   Description
--      ==========     ============   ===========
--      data_s_width    1 to 1024     default: 16
--                                    Width of data_s
--
--      data_d_width    1 to 1024     default: 8
--                                    Width of data_d
--
--      ram_depth       4 to 1024     default: 8
--                                    Depth of the RAM in the FIFO (does not include cache depth)
--
--      mem_mode         0 to 7       default: 3
--                                    Defines where and how many re-timing stages:
--                                      0 => no RAM pre or post retiming
--                                      1 => RAM data out (post) re-timing
--                                      2 => RAM read address (pre) re-timing
--                                      3 => RAM read address (pre) and data out (post) re-timing
--                                      4 => RAM write interface (pre) re-timing
--                                      5 => RAM write interface (pre) and data out (post) re-timing
--                                      6 => RAM write interface (pre) and read address (pre) re-timing
--                                      7 => RAM write interface (pre), read address re-timing (pre), and data out (post) re-timing
--
--      arch_type        0 or 1       default: 0
--                                    Pre-fetch cache architecture type
--                                      0 => Pipeline style
--                                      1 => Register File style
--
--      f_sync_type      1 to 4       default: 2
--                                    Mode of forward synchronization (source to destination)
--                                      1 => 2-stage synchronization w/ 1st stage neg-edge & 2nd stage pos-edge capturing,
--                                      2 => 2-stage synchronization w/ both stages pos-edge capturing,
--                                      3 => 3-stage synchronization w/ all stages pos-edge capturing
--                                      4 => 4-stage synchronization w/ all stages pos-edge capturing
--
--      r_sync_type      1 to 4       default: 2
--                                    Mode of reverse synchronization (destination to source)
--                                      1 => 2-stage synchronization w/ 1st stage neg-edge & 2nd stage pos-edge capturing,
--                                      2 => 2-stage synchronization w/ both stages pos-edge capturing,
--                                      3 => 3-stage synchronization w/ all stages pos-edge capturing
--                                      4 => 4-stage synchronization w/ all stages pos-edge capturing
--
--      byte_order       1 to 0       default: 0
--                                      0 => the first byte (or subword) is in MSBs
--                                      1 => the first byte  (or subword)is in LSBs
--
--      flush_value      1 to 0        default: 0 
--                                      0 => fill empty bits of partial word with 0's upon flush
--                                      1 => fill empty bits of partial word with 1's upon flush
--
--      clk_ratio       -7 to 7       default: 1
--                                    Rounded quotient between clk_s and clk_d
--                                      1 to 7   => when clk_d rate faster than clk_s rate: round(clk_d rate / clk_s rate)
--                                         0     => supports all clock ratios
--                                      -7 to -1 => when clk_d rate slower than clk_s rate: 0 - round(clk_s rate / clk_d rate)
--
--      ram_re_ext       0 or 1       default: 1
--                                    Determines the charateristic of the ram_re_d_n signal to RAM
--                                      0 => Single-cycle pulse of ram_re_d_n at the read event to RAM
--                                      1 => Extend assertion of ram_re_d_n while read event active in RAM
--
--      err_mode         0 or 1       default: 0
--                                    Error Reporting Behavior
--                                      0 => sticky error flag
--                                      1 => dynamic error flag
--
--      tst_mode         0 or 1       default: 0
--                                    Latch insertion for testing purposes
--                                      0 => no hold latch inserted,
--                                      1 => insert hold 'latch' using a neg-edge triggered register
--                                      2 => insert hold latch using active low latch
--
--        verif_en     0, 1, or 4     Synchronization missampling control (Simulation verification)
--                                    Default value = 1
--                                    0 => no sampling errors modeled,
--                                    1 => when using the SIM_MS architecture, randomly insert 0 to 1 cycle delay
--                                    4 => when using the SIM_MS architecture, randomly insert 0 to 0.5 cycle delay
--
--      Inputs           Size       Description
--      ======           ====       ===========
--      clk_s            1 bit      Source Domain Clock
--      rst_s_n          1 bit      Source Domain Asynchronous Reset (active low)
--      init_s_n         1 bit      Source Domain Synchronous Reset (active low)
--      clr_s            1 bit      Source Domain Clear to initiate orchestrated reset (active high pulse)
--      ae_level_s       N bits     Source Domain RAM almost empty threshold setting
--      af_level_s       N bits     Source Domain RAM almost full threshold setting
--      push_s_n         1 bit      Source Domain push request (active low)
--      flush_s_n        1 bit      Source Domain Flush the partial word into the full word memory (active low)
--      data_s           L bits     Source Domain data
--
--      clk_d            1 bit      Destination Domain Clock
--      rst_d_n          1 bit      Destination Domain Asynchronous Reset (active low)
--      init_d_n         1 bit      Destination Domain Synchronous Reset (active low)
--      clr_d            1 bit      Destination Domain Clear to initiate orchestrated reset (active high pulse)
--      ae_level_d       Q bits     Destination Domain FIFO almost empty threshold setting
--      af_level_d       Q bits     Destination Domain FIFO almost full threshold setting
--      pop_d_n          1 bit      Destination Domain pop request (active low)
--      rd_data_d        M bits     Destination Domain read data from RAM
--
--      test             1 bit      Test input
--
--      Outputs          Size       Description
--      =======          ====       ===========
--      clr_sync_s       1 bit      Source Domain synchronized clear (active high pulse)
--      clr_in_prog_s    1 bit      Source Domain orchestrate clearing in progress
--      clr_cmplt_s      1 bit      Source Domain orchestrated clearing complete (active high pulse)
--      wr_en_s_n        1 bit      Source Domain write enable to RAM (active low)
--      wr_addr_s        P bits     Source Domain write address to RAM
--      wr_data_s        M bits     Source Domain write data to RAM
--      inbuf_part_wd_s  1 bit      Source Domain partial word in input buffer flag (meaningful when data_s_width < data_d_width)
--      inbuf_full_s     1 bit      Source domain input buffer full flag (meaningful when data_s_width < data_d_width)
--      fifo_word_cnt_s  Q bits     Source Domain FIFO word count (includes cache)
--      word_cnt_s       N bits     Source Domain RAM only word count
--      fifo_empty_s     1 bit      Source Domain FIFO Empty Flag
--      empty_s          1 bit      Source Domain RAM Empty Flag
--      almost_empty_s   1 bit      Source Domain RAM Almost Empty Flag
--      half_full_s      1 bit      Source Domain RAM Half Full Flag
--      almost_full_s    1 bit      Source Domain RAM Almost Full Flag
--      ram_full_s       1 bit      Source Domain RAM Full Flag
--      push_error_s     1 bit      Source Domain Push Error Flag
--
--      clr_sync_d       1 bit      Destination Domain synchronized clear (active high pulse)
--      clr_in_prog_d    1 bit      Destination Domain orchestrate clearing in progress
--      clr_cmplt_d      1 bit      Destination Domain orchestrated clearing complete (active high pulse)
--      ram_re_d_n       1 bit      Destination Domain Read Enable to RAM (active-low)
--      rd_addr_d        P bits     Destination Domain read address to RAM
--      data_d           R bits     Destination Domain data out
--      outbuf_part_wd_d 1 bit      Destination Domain outbuf partial word popped flag (meaningful when data_s_width > data_d_width)
--      word_cnt_d       Q bits     Destination Domain FIFO word count (includes cache)
--      ram_word_cnt_d   N bits     Destination Domain RAM only word count
--      empty_d          1 bit      Destination Domain Empty Flag
--      almost_empty_d   1 bit      Destination Domain Almost Empty Flag
--      half_full_d      1 bit      Destination Domain Half Full Flag
--      almost_full_d    1 bit      Destination Domain Almost Full Flag
--      full_d           1 bit      Destination Domain Full Flag
--      pop_error_d      1 bit      Destination Domain Pop Error Flag
--
--           Note: L is equal to the data_s_width parameter
--           Note: M is equal to larger of data_s_width and data_d_width
--           Note: R is equal to the data_d_width parameter
--
--           Note: N is based on ram_depth:
--                   N = ceil(log2(ram_depth+1))
--
--           Note: P is ceil(log2(ram_depth))
--
--           Note: Q is based on the mem_mode parameter:
--                   Q = ceil(log2((ram_depth+1)+1)) when mem_mode = 0 or 4
--                   Q = ceil(log2((ram_depth+1)+2)) when mem_mode = 1, 2, 5, or 6
--                   Q = ceil(log2((ram_depth+1)+3)) when mem_mode = 3 or 7
--
--
--
-- MODIFIED: 
--
--
---------------------------------------------------------------------------------
--
library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
entity DW_asymfifoctl_2c_df is
	
	generic (
		    data_s_width     : POSITIVE  := 16;
		    data_d_width     : POSITIVE  := 8;
		    ram_depth        : POSITIVE  := 8;
                    mem_mode         : NATURAL    := 5;
                    arch_type        : NATURAL    := 0;
                    f_sync_type      : NATURAL  := 2;
                    r_sync_type      : NATURAL  := 2;
                    byte_order       : NATURAL    := 0;
                    flush_value      : NATURAL    := 0;
                    clk_ratio        : INTEGER  := 1; --  range -7 to 7 := 1;  -- NOTE: '0' is illegal
                    ram_re_ext       : NATURAL    := 1;
                    err_mode         : NATURAL    := 0;
                    tst_mode         : NATURAL    := 0;
                    verif_en         : NATURAL  := 1  -- only values legal are 0, 1, 4
		);
	
	port    (
                    clk_s             : in std_logic;
                    rst_s_n           : in std_logic;
                    init_s_n          : in std_logic;
                    clr_s             : in std_logic;
                    ae_level_s        : in std_logic_vector(bit_width(ram_depth+1)-1 downto 0);
                    af_level_s        : in std_logic_vector(bit_width(ram_depth+1)-1 downto 0);
                    push_s_n          : in std_logic;
                    flush_s_n         : in std_logic;
                    data_s            : in std_logic_vector(data_s_width-1 downto 0);
                    clr_sync_s        : out std_logic;
                    clr_in_prog_s     : out std_logic;
                    clr_cmplt_s       : out std_logic;
                    wr_en_s_n         : out std_logic;
                    wr_addr_s         : out std_logic_vector(bit_width(ram_depth)-1 downto 0);
                    wr_data_s         : out std_logic_vector(maximum(data_s_width, data_d_width)-1 downto 0);
                    inbuf_part_wd_s   : out std_logic;
                    inbuf_full_s      : out std_logic;
                    fifo_word_cnt_s   : out std_logic_vector(bit_width((ram_depth+1+(mem_mode mod 2)+((mem_mode/2) mod 2))+1)-1 downto 0);
                    word_cnt_s        : out std_logic_vector(bit_width(ram_depth+1)-1 downto 0);
                    fifo_empty_s      : out std_logic;
                    empty_s           : out std_logic;
                    almost_empty_s    : out std_logic;
                    half_full_s       : out std_logic;
                    almost_full_s     : out std_logic;
                    ram_full_s        : out std_logic;
                    push_error_s      : out std_logic;

                    clk_d             : in std_logic;
                    rst_d_n           : in std_logic;
                    init_d_n          : in std_logic;
                    clr_d             : in std_logic;
                    ae_level_d        : in std_logic_vector(bit_width((ram_depth+1+(mem_mode mod 2)+((mem_mode/2) mod 2))+1)-1 downto 0);
                    af_level_d        : in std_logic_vector(bit_width((ram_depth+1+(mem_mode mod 2)+((mem_mode/2) mod 2))+1)-1 downto 0);
                    pop_d_n           : in std_logic;
		    rd_data_d         : in std_logic_vector(maximum(data_s_width, data_d_width)-1 downto 0);
                    clr_sync_d        : out std_logic;
                    clr_in_prog_d     : out std_logic;
                    clr_cmplt_d       : out std_logic;
                    ram_re_d_n        : out std_logic;
                    rd_addr_d         : out std_logic_vector(bit_width(ram_depth)-1 downto 0);
		    data_d            : out std_logic_vector(data_d_width-1 downto 0);
                    outbuf_part_wd_d  : out std_logic;
                    word_cnt_d        : out std_logic_vector(bit_width((ram_depth+1+(mem_mode mod 2)+((mem_mode/2) mod 2))+1)-1 downto 0);
                    ram_word_cnt_d    : out std_logic_vector(bit_width(ram_depth+1)-1 downto 0);
                    empty_d           : out std_logic;
                    almost_empty_d    : out std_logic;
                    half_full_d       : out std_logic;
                    almost_full_d     : out std_logic;
                    full_d            : out std_logic;
                    pop_error_d       : out std_logic;

		    test : in std_logic
		);
end DW_asymfifoctl_2c_df;

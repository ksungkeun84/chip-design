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
-- AUTHOR:    Doug Lee    Oct 28, 2009
--
-- VERSION:   VHDL Simulation Model
--
-- DesignWare_version: 6480b103
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
--
-- ABSTRACT: Dual clock domain interface assymetric FIFO controller VHDL Simulation Model
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
--  2/8/2017  RJK  Updated to allow clk_ratio=0 to be valid to support
--                 arbitrary clock relationships (STAR 9001152809)
--
--
---------------------------------------------------------------------------------
--
library IEEE,DWARE;
use STD.textio.all;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use DWARE.DWpackages.all;
use DWARE.DW_Foundation_comp_arith.all;

architecture sim of DW_asymfifoctl_2c_df is
	
-- pragma translate_off

constant F_SYNC_TYPE_ADD8     : INTEGER := (f_sync_type + 8);

constant F_SYNC_TYPE_INT      : INTEGER := (f_sync_type mod 8);

constant R_SYNC_TYPE_ADD8     : INTEGER := (r_sync_type + 8);

constant R_SYNC_TYPE_INT      : INTEGER := (r_sync_type mod 8);

constant EFF_DEPTH            : INTEGER := ram_depth+1+(mem_mode mod 2)+((mem_mode/2) mod 2);
constant ADDR_WIDTH           : INTEGER := bit_width(ram_depth);
constant CNT_WIDTH            : INTEGER := bit_width(ram_depth+1);
constant FIFO_CNT_WIDTH       : INTEGER := bit_width(EFF_DEPTH+1);
constant RAM_WIDTH            : INTEGER := maximum(data_s_width, data_d_width);


-- Source Domain signals
signal init_s_n_INBUF            : std_logic;
signal clr_in_prog_s_int         : std_logic;
signal Ol1l1l1l          : std_logic;
signal ll10lO1l             : std_logic;
signal OOI0O00I             : std_logic_vector(RAM_WIDTH-1 downto 0);
signal O1lII1O0            : std_logic;
signal O1l01l1O             : std_logic;
signal OlO1010l          : std_logic;
signal Il1OO1OO            : std_logic;
signal I1Ol0IO0           : std_logic;

-- Destination Domain internal signals
signal init_d_n_OUTBUF           : std_logic;
signal I11O1O11         : std_logic;
signal O0010l00            : std_logic_vector(RAM_WIDTH-1 downto 0);
signal I1ll1Ol0           : std_logic;
signal l0I1010O           : std_logic;
signal O10ll11O             : std_logic_vector(data_d_width-1 downto 0);
signal OIl1O0O1           : std_logic;
signal lOOI1l1O            : std_logic;
signal I10O1001          : std_logic;
signal O1O1OI1l               : std_logic;

-- pragma translate_on


begin
-- pragma translate_off

   
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
   
    if ( (data_s_width < 1) OR (data_s_width > 1024 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter data_s_width (legal range: 1 to 1024 )"
        severity warning;
    end if;
   
    if ( (data_d_width < 1) OR (data_d_width > 1024 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter data_d_width (legal range: 1 to 1024 )"
        severity warning;
    end if;
   
    if ( (ram_depth < 4) OR (ram_depth > 1024 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter ram_depth (legal range: 4 to 1024 )"
        severity warning;
    end if;
   
    if ( (mem_mode < 0) OR (mem_mode > 7 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter mem_mode (legal range: 0 to 7 )"
        severity warning;
    end if;
   
    if ( (arch_type < 0) OR (arch_type > 1 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter arch_type (legal range: 0 to 1 )"
        severity warning;
    end if;
   
    if ( (F_SYNC_TYPE_INT < 1) OR (F_SYNC_TYPE_INT > 4 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter F_SYNC_TYPE_INT (legal range: 1 to 4 )"
        severity warning;
    end if;
   
    if ( (R_SYNC_TYPE_INT < 1) OR (R_SYNC_TYPE_INT > 4 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter R_SYNC_TYPE_INT (legal range: 1 to 4 )"
        severity warning;
    end if;
   
    if ( (byte_order < 0) OR (byte_order > 1 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter byte_order (legal range: 0 to 1 )"
        severity warning;
    end if;
   
    if ( (flush_value < 0) OR (flush_value > 1 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter flush_value (legal range: 0 to 1 )"
        severity warning;
    end if;
   
    if ( (clk_ratio < -7) OR (clk_ratio > 7 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter clk_ratio (legal range: -7 to 7 )"
        severity warning;
    end if;
   
    if ( (ram_re_ext < 0) OR (ram_re_ext > 1 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter ram_re_ext (legal range: 0 to 1 )"
        severity warning;
    end if;
   
    if ( (err_mode < 0) OR (err_mode > 1 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter err_mode (legal range: 0 to 1 )"
        severity warning;
    end if;
   
    if ( (tst_mode < 0) OR (tst_mode > 2 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter tst_mode (legal range: 0 to 2 )"
        severity warning;
    end if;
   
    if ( (verif_en < 0) OR (verif_en > 4 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter verif_en (legal range: 0 to 4 )"
        severity warning;
    end if;
   
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;

  G_SRC_INBUF : if ( data_s_width < data_d_width ) generate
    U_INBUF : DW_asymdata_inbuf
      generic map (
        in_width => data_s_width,
        out_width => RAM_WIDTH,
        err_mode => err_mode,
        byte_order => byte_order,
        flush_value => flush_value )
      port map (
        clk_push => clk_s,
        rst_push_n => rst_s_n,
        init_push_n => init_s_n_INBUF,
        push_req_n => push_s_n,
        data_in => data_s,
        flush_n => flush_s_n,
        fifo_full => Il1OO1OO,
        push_wd_n => ll10lO1l,
        data_out => OOI0O00I,
        inbuf_full => O1lII1O0,
        part_wd => O1l01l1O,
        push_error => OlO1010l );
  
    init_s_n_INBUF  <= (init_s_n AND NOT(clr_in_prog_s_int));

    Ol1l1l1l  <= ll10lO1l;
    wr_data_s         <= OOI0O00I;
  
    inbuf_part_wd_s   <= O1l01l1O;
    inbuf_full_s      <= O1lII1O0;
    push_error_s      <= OlO1010l;
  end generate G_SRC_INBUF;

  G_SRC_NO_INBUF : if ( data_s_width >= data_d_width ) generate
    init_s_n_INBUF  <= '1';

    Ol1l1l1l  <= push_s_n;
    wr_data_s         <= data_s;
  
    inbuf_part_wd_s   <= '0';
    inbuf_full_s      <= '1';
    push_error_s      <= I1Ol0IO0;
  end generate G_SRC_NO_INBUF;

  ram_full_s        <= Il1OO1OO;


  U_FIFOCTL : DW_fifoctl_2c_df
    generic map (
      width => RAM_WIDTH,
      ram_depth => ram_depth,
      mem_mode => mem_mode,
      f_sync_type => F_SYNC_TYPE_ADD8,
      r_sync_type => R_SYNC_TYPE_ADD8,
      clk_ratio => clk_ratio,
      ram_re_ext => ram_re_ext,
      err_mode => err_mode,
      tst_mode => tst_mode,
      verif_en => verif_en,
      clr_dual_domain => 0,
      arch_type => arch_type )
    port map (
      clk_s => clk_s,
      rst_s_n => rst_s_n,
      init_s_n => init_s_n,
      clr_s => clr_s,
      ae_level_s => ae_level_s,
      af_level_s => af_level_s,
      push_s_n => Ol1l1l1l,
      clr_sync_s => clr_sync_s,
      clr_in_prog_s => clr_in_prog_s_int,
      clr_cmplt_s => clr_cmplt_s,
      wr_en_s_n => wr_en_s_n,
      wr_addr_s => wr_addr_s,
      fifo_word_cnt_s => fifo_word_cnt_s,
      word_cnt_s => word_cnt_s,
      fifo_empty_s => fifo_empty_s,
      empty_s => empty_s,
      almost_empty_s => almost_empty_s,
      half_full_s => half_full_s,
      almost_full_s => almost_full_s,
      full_s => Il1OO1OO,
      error_s => I1Ol0IO0,
      clk_d => clk_d,
      rst_d_n => rst_d_n,
      init_d_n => init_d_n,
      clr_d => clr_d,
      ae_level_d => ae_level_d,
      af_level_d => af_level_d,
      pop_d_n => OIl1O0O1,
      rd_data_d => rd_data_d,
      clr_sync_d => clr_sync_d,
      clr_in_prog_d => I11O1O11,
      clr_cmplt_d => clr_cmplt_d,
      ram_re_d_n => ram_re_d_n,
      rd_addr_d => rd_addr_d,
      data_d => O0010l00,
      word_cnt_d => word_cnt_d,
      ram_word_cnt_d => ram_word_cnt_d,
      empty_d => O1O1OI1l,
      almost_empty_d => almost_empty_d,
      half_full_d => half_full_d,
      almost_full_d => almost_full_d,
      full_d => full_d,
      error_d => I1ll1Ol0,
      test => test );

  empty_d           <= O1O1OI1l;

  G_DEST_OUTBUF : if ( data_s_width > data_d_width ) generate
    U_OUTBUF : DW_asymdata_outbuf
      generic map (
        in_width => RAM_WIDTH,
        out_width => data_d_width,
        err_mode => err_mode,
        byte_order => byte_order )
      port map (
        clk_pop => clk_d,
        rst_pop_n => rst_d_n,
        init_pop_n => init_d_n_OUTBUF,
        pop_req_n => pop_d_n,
        data_in => O0010l00,
        fifo_empty => O1O1OI1l,
        pop_wd_n => l0I1010O,
        data_out => O10ll11O,
        part_wd => lOOI1l1O,
        pop_error => I10O1001 );
  
    init_d_n_OUTBUF <= (init_d_n AND NOT(I11O1O11));

    OIl1O0O1   <= l0I1010O;
    data_d            <= O10ll11O;
  
    pop_error_d       <= I10O1001;
    outbuf_part_wd_d  <= lOOI1l1O;
  end generate G_DEST_OUTBUF;


  G_DEST_NO_OUTBUF : if ( data_s_width <= data_d_width ) generate
    init_d_n_OUTBUF <= '1';

    OIl1O0O1   <= pop_d_n;
    data_d            <= O0010l00;
  
    pop_error_d       <= I1ll1Ol0;
    outbuf_part_wd_d  <= '0';
  end generate G_DEST_NO_OUTBUF;


  clr_in_prog_s <= clr_in_prog_s_int;
  clr_in_prog_d <= I11O1O11;

  
  clk_s_monitor  : process (clk_s) begin

    assert NOT (Is_X( clk_s ) AND (now > 0 ns)) 
      report "WARNING: Detected unknown value on the clock input port clk_s."
      severity warning;

  end process clk_s_monitor ;
  
  clk_d_monitor  : process (clk_d) begin

    assert NOT (Is_X( clk_d ) AND (now > 0 ns)) 
      report "WARNING: Detected unknown value on the clock input port clk_d."
      severity warning;

  end process clk_d_monitor ;


    -- Message printed to standard output identifyng method of use when f_sync_type is greater than 0 and less than 8
    method_msg : process
      variable buf : line;
      constant preamble_str : STRING := "Information: *** Instance ";
      constant method_str : STRING := " is the DW_fifoctl_2c_df Clock Domain Crossing Module ***";

    begin
      if ((f_sync_type > 0) AND (f_sync_type < 8)) then
        write(buf, preamble_str);
        write(buf, sim'Instance_name);
        write(buf, method_str);
        writeline(output, buf);
      end if;

      wait;

    end process method_msg;

-- pragma translate_on
end sim;

-- pragma translate_off
library dw03;
configuration DW_asymfifoctl_2c_df_cfg_sim_ms of DW_asymfifoctl_2c_df is
 for sim
  for G_SRC_INBUF
    for U_INBUF: DW_asymdata_inbuf use configuration dw03.DW_asymdata_inbuf_cfg_sim; end for;
  end for; -- G_SRC_INBUF
  for U_FIFOCTL: DW_fifoctl_2c_df use configuration dw03.DW_fifoctl_2c_df_cfg_sim_ms; end for;
  for G_DEST_OUTBUF
    for U_OUTBUF: DW_asymdata_outbuf use configuration dw03.DW_asymdata_outbuf_cfg_sim; end for;
  end for; -- G_DEST_OUTBUF;
 end for; -- sim
end DW_asymfifoctl_2c_df_cfg_sim_ms;

library dw03;
configuration DW_asymfifoctl_2c_df_cfg_sim of DW_asymfifoctl_2c_df is
 for sim
  for G_SRC_INBUF
    for U_INBUF: DW_asymdata_inbuf use configuration dw03.DW_asymdata_inbuf_cfg_sim; end for;
  end for; -- G_SRC_INBUF
  for U_FIFOCTL: DW_fifoctl_2c_df use configuration dw03.DW_fifoctl_2c_df_cfg_sim; end for;
  for G_DEST_OUTBUF
    for U_OUTBUF: DW_asymdata_outbuf use configuration dw03.DW_asymdata_outbuf_cfg_sim; end for;
  end for; -- G_DEST_OUTBUF;
 end for; -- sim
end DW_asymfifoctl_2c_df_cfg_sim;
-- pragma translate_on


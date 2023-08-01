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
-- AUTHOR:    Doug Lee    Nov 3, 2006
--
-- VERSION:   VHDL Simulation Model
--
-- DesignWare_version: 24b6f2f0
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
--
--
-- ABSTRACT: Dual clock domain interface FIFO Simulation Model
--
--           Incorporates synchronous pipelined RAM and FIFO controller
--           with caching.  Status flags are dynamically configured.
--
--
--      Parameters     Valid Values   Description
--      ==========     ============   ===========
--      width           1 to 1024     default: 8
--                                    Width of data to/from RAM
--
--      ram_depth       4 to 1024     default: 8
--                                    Depth of the RAM in the FIFO (does not include cache depth)
--
--      mem_mode         0 to 7       default: 5
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
--      clk_ratio       -7 to 7       default: 1
--                                    Rounded quotient between clk_s and clk_d
--                                      1 to 7   => when clk_d rate faster than clk_s rate: round(clk_d rate / clk_s rate)
--                                         0     => supports all clock ratios
--                                     -7 to -1  => when clk_d rate slower than clk_s rate: 0 - round(clk_s rate / clk_d rate)
--                                      NOTE: 0 is illegal
--
--      rst_mode         0 or 1       default: 0
--                                    Control Reset of RAM contents
--                                      0 => include resets to clear RAM
--                                      1 => do not include reset to clear RAM
--
--      err_mode         0 or 1       default: 0
--                                    Error Reporting Behavior
--                                      0 => sticky error flag
--                                      1 => dynamic error flag
--
--      tst_mode         0 to 2       default: 0
--                                    Latch insertion for testing purposes
--                                      0 => no hold latch inserted,
--                                      1 => insert hold 'latch' using a neg-edge triggered register
--                                      2 => insert hold latch using active low latch
--
--      verif_en         0 to 4       default: 1
--                                    Verification mode
--                                      0 => no sampling errors inserted,
--                                      1 => sampling errors are randomly inserted with 0 or up to 1 destination clock cycle delays
--                                      2 => sampling errors are randomly inserted with 0, 0.5, 1, or 1.5 destination clock cycle delays
--                                      3 => sampling errors are randomly inserted with 0, 1, 2, or 3 destination clock cycle delays
--                                      4 => sampling errors are randomly inserted with 0 or up to 0.5 destination clock cycle delays
--
--      clr_dual_domain    1          default: 1
--                                    Activity of clr_s and/or clr_d
--                                      0 => either clr_s or clr_d can be activated, but the other must be tied 'low'
--                                      1 => both clr_s and clr_d can be activated
--
--      arch_type        0 or 1       default: 0
--                                    Pre-fetch cache architecture type
--                                      0 => Pipeline style
--                                      1 => Register File style
--
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
--      data_s           M bits     Source Domain push data
--
--      clk_d            1 bit      Destination Domain Clock
--      rst_d_n          1 bit      Destination Domain Asynchronous Reset (active low)
--      init_d_n         1 bit      Destination Domain Synchronous Reset (active low)
--      clr_d            1 bit      Destination Domain Clear to initiate orchestrated reset (active high pulse)
--      ae_level_d       Q bits     Destination Domain FIFO almost empty threshold setting
--      af_level_d       Q bits     Destination Domain FIFO almost full threshold setting
--      pop_d_n          1 bit      Destination Domain pop request (active low)
--
--      test             1 bit      Test input
--
--      Outputs          Size       Description
--      =======          ====       ===========
--      clr_sync_s       1 bit      Source Domain synchronized clear (active high pulse)
--      clr_in_prog_s    1 bit      Source Domain orchestrate clearing in progress
--      clr_cmplt_s      1 bit      Source Domain orchestrated clearing complete (active high pulse)
--      fifo_word_cnt_s  Q bits     Source Domain FIFO word count (includes cache)
--      word_cnt_s       N bits     Source Domain RAM only word count
--      fifo_empty_s     1 bit      Source Domain FIFO Empty Flag
--      empty_s          1 bit      Source Domain RAM Empty Flag
--      almost_empty_s   1 bit      Source Domain RAM Almost Empty Flag
--      half_full_s      1 bit      Source Domain RAM Half Full Flag
--      almost_full_s    1 bit      Source Domain RAM Almost Full Flag
--      full_s           1 bit      Source Domain RAM Full Flag
--      error_s          1 bit      Source Domain Error Flag
--
--      clr_sync_d       1 bit      Destination Domain synchronized clear (active high pulse)
--      clr_in_prog_d    1 bit      Destination Domain orchestrate clearing in progress
--      clr_cmplt_d      1 bit      Destination Domain orchestrated clearing complete (active high pulse)
--      data_d           M bits     Destination Domain data out
--      word_cnt_d       Q bits     Destination Domain FIFO word count (includes cache)
--      empty_d          1 bit      Destination Domain Empty Flag
--      almost_empty_d   1 bit      Destination Domain Almost Empty Flag
--      half_full_d      1 bit      Destination Domain Half Full Flag
--      almost_full_d    1 bit      Destination Domain Almost Full Flag
--      full_d           1 bit      Destination Domain Full Flag
--      error_d          1 bit      Destination Domain Error Flag
--
--           Note: M is equal to the width parameter
--
--           Note: N is based on ram_depth:
--                   N = ceil(log2(ram_depth+1))
--
--           Note: Q is based on the mem_mode parameter:
--                   Q = ceil(log2((ram_depth+1)+1)) when mem_mode = 0 or 4
--                   Q = ceil(log2((ram_depth+1)+2)) when mem_mode = 1, 2, 5, or 6
--                   Q = ceil(log2((ram_depth+1)+3)) when mem_mode = 3 or 7
--
--
--
-- MODIFIED: 
--      2/8/2017  RJK  Updated to allow clk_ratio=0 to be valid to support
--                     arbitrary clock relationships (STAR 9001152809)
--
--      8/05/11  DLL   Added upper range of tst_mode to 2.
--
--     11/20/08  DLL   Added 'arch_type' parameter checking.
--
---------------------------------------------------------------------------------
--
library IEEE,DWARE;
use STD.textio.all;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use DWARE.DWpackages.all;
use DWARE.DW_foundation_comp_arith.all;

architecture sim of DW_fifo_2c_df is
	
-- pragma translate_off
function calc_adj_ram_depth( ram_depth, cnt_width : in INTEGER ) return INTEGER is
begin
 if ( ram_depth = (2**(cnt_width-1)) ) then
   return( ram_depth );
 else
   return( (ram_depth + 2) - (ram_depth mod 2) );
 end if;
end calc_adj_ram_depth;

constant F_SYNC_TYPE_ADD8     : INTEGER := (f_sync_type + 8);

constant F_SYNC_TYPE_INT      : INTEGER := (f_sync_type mod 8);

constant R_SYNC_TYPE_ADD8     : INTEGER := (r_sync_type + 8);

constant R_SYNC_TYPE_INT      : INTEGER := (r_sync_type mod 8);

constant addr_width           : INTEGER := bit_width(ram_depth);
constant cnt_width            : INTEGER := bit_width(ram_depth+1);
constant adj_ram_depth        : INTEGER := calc_adj_ram_depth(ram_depth, cnt_width);


-- Source Domain Interconnects
signal wr_en_s_n         : std_logic;
signal wr_addr_s         : std_logic_vector(addr_width-1 downto 0);

-- Source Domain internal signals
signal clr_in_prog_s_int : std_logic;
signal init_s_n_merge    : std_logic;
signal data_s_int        : std_logic_vector(width-1 downto 0);

-- Destination Domain Interconnects
signal rd_data_d         : std_logic_vector(width-1 downto 0);
signal ram_re_d_n        : std_logic;
signal rd_addr_d         : std_logic_vector(addr_width-1 downto 0);

-- Destination Domain internal signals
signal clr_in_prog_d_int : std_logic;
signal init_d_n_merge    : std_logic;


signal ram_word_cnt_d_nc : std_logic_vector(cnt_width-1 downto 0);
signal data_r_a_nc       : std_logic;

-- pragma translate_on

begin
-- pragma translate_off

   
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
   
    if ( (width < 1) OR (width > 1024) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter width (legal range: 1 to 1024)"
        severity warning;
    end if;
   
    if ( (ram_depth < 4) OR (ram_depth > 1024) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter ram_depth (legal range: 4 to 1024)"
        severity warning;
    end if;
   
    if ( (mem_mode < 0) OR (mem_mode > 7 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter mem_mode (legal range: 0 to 7 )"
        severity warning;
    end if;
   
    if ( (F_SYNC_TYPE_INT < 1) OR (F_SYNC_TYPE_INT > 4) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter F_SYNC_TYPE_INT (legal range: 1 to 4)"
        severity warning;
    end if;
   
    if ( (R_SYNC_TYPE_INT < 1) OR (R_SYNC_TYPE_INT > 4) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter R_SYNC_TYPE_INT (legal range: 1 to 4)"
        severity warning;
    end if;
   
    if ( (clk_ratio < -7) OR (clk_ratio > 7) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter clk_ratio (legal range: -7 to 7)"
        severity warning;
    end if;
   
    if ( (rst_mode < 0) OR (rst_mode > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter rst_mode (legal range: 0 to 1)"
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
   
    if ( (clr_dual_domain < 0) OR (clr_dual_domain > 1 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter clr_dual_domain (legal range: 0 to 1 )"
        severity warning;
    end if;
   
    if ( (arch_type < 0) OR (arch_type > 1 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter arch_type (legal range: 0 to 1 )"
        severity warning;
    end if;
   
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;


   U_FIFOCTL : DW_fifoctl_2c_df
     generic map ( 
       width           => width, 
       ram_depth       => ram_depth,
       mem_mode        => mem_mode, 
       f_sync_type     => F_SYNC_TYPE_ADD8,
       r_sync_type     => R_SYNC_TYPE_ADD8, 
       clk_ratio       => clk_ratio,
       ram_re_ext      => 0, 
       err_mode        => err_mode,
       tst_mode        => tst_mode, 
       verif_en        => verif_en,
       clr_dual_domain => clr_dual_domain)
     port map ( 
       clk_s           => clk_s, 
       rst_s_n         => rst_s_n, 
       init_s_n        => init_s_n,
       clr_s           => clr_s, 
       ae_level_s      => ae_level_s, 
       af_level_s      => af_level_s,
       push_s_n        => push_s_n, 
       clr_sync_s      => clr_sync_s, 
       clr_in_prog_s   => clr_in_prog_s_int,
       clr_cmplt_s     => clr_cmplt_s, 
       wr_en_s_n       => wr_en_s_n, 
       wr_addr_s       => wr_addr_s,
       fifo_word_cnt_s => fifo_word_cnt_s, 
       word_cnt_s      => word_cnt_s,
       fifo_empty_s    => fifo_empty_s, 
       empty_s         => empty_s, 
       almost_empty_s  => almost_empty_s,
       half_full_s     => half_full_s, 
       almost_full_s   => almost_full_s,
       full_s          => full_s, 
       error_s         => error_s,
       clk_d           => clk_d, 
       rst_d_n         => rst_d_n, 
       init_d_n        => init_d_n,
       clr_d           => clr_d, 
       ae_level_d      => ae_level_d, 
       af_level_d      => af_level_d,
       pop_d_n         => pop_d_n, 
       rd_data_d       => rd_data_d, 
       clr_sync_d      => clr_sync_d,
       clr_in_prog_d   => clr_in_prog_d_int, 
       clr_cmplt_d     => clr_cmplt_d,
       ram_re_d_n      => ram_re_d_n, 
       rd_addr_d       => rd_addr_d, 
       data_d          => data_d,
       word_cnt_d      => word_cnt_d, 
       ram_word_cnt_d  => ram_word_cnt_d_nc,
       empty_d         => empty_d, 
       almost_empty_d  => almost_empty_d,
       half_full_d     => half_full_d, 
       almost_full_d   => almost_full_d,
       full_d          => full_d, 
       error_d         => error_d, 
       test            => test);

  init_s_n_merge <= (init_s_n AND NOT(clr_in_prog_s_int));
  data_s_int     <= (To_X01(data_s));
  init_d_n_merge <= (init_d_n AND NOT(clr_in_prog_d_int));

  U_RAM: DW_ram_r_w_2c_dff
    generic map (
      width      => width,
      depth      => adj_ram_depth,
      addr_width => addr_width,
      mem_mode   => mem_mode,
      rst_mode   => rst_mode)
    port map (
      clk_w      => clk_s,
      rst_w_n    => rst_s_n,
      init_w_n   => init_s_n_merge,
      en_w_n     => wr_en_s_n,
      addr_w     => wr_addr_s,
      data_w     => data_s_int,
      clk_r      => clk_d,
      rst_r_n    => rst_d_n,
      init_r_n   => init_d_n_merge,
      en_r_n     => ram_re_d_n,
      addr_r     => rd_addr_d,
      data_r_a   => data_r_a_nc,
      data_r     => rd_data_d);

  clr_in_prog_s   <= clr_in_prog_s_int;

  clr_in_prog_d   <= clr_in_prog_d_int;


  
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
      constant method_str : STRING := " is the DW_fifo_2c_df Clock Domain Crossing Module ***";

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
library dw03, dw06;
configuration DW_fifo_2c_df_cfg_sim_ms of DW_fifo_2c_df is
 for sim
  for U_FIFOCTL: DW_fifoctl_2c_df use configuration dw03.DW_fifoctl_2c_df_cfg_sim_ms; end for;
  for U_RAM: DW_ram_r_w_2c_dff use configuration dw06.DW_ram_r_w_2c_dff_cfg_sim; end for;
 end for; -- sim
end DW_fifo_2c_df_cfg_sim_ms;

library dw03, dw06;
configuration DW_fifo_2c_df_cfg_sim of DW_fifo_2c_df is
 for sim
  for U_FIFOCTL: DW_fifoctl_2c_df use configuration dw03.DW_fifoctl_2c_df_cfg_sim; end for;
  for U_RAM: DW_ram_r_w_2c_dff use configuration dw06.DW_ram_r_w_2c_dff_cfg_sim; end for;
 end for; -- sim
end DW_fifo_2c_df_cfg_sim;
-- pragma translate_on


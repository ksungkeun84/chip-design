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
-- AUTHOR:    Doug Lee    Sept 19, 2006
--
-- VERSION:   VHDL Simulation Model
--
-- DesignWare_version: 170833e9
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
--
--
-- ABSTRACT: Dual clock domain interface FIFO controller Simulation Model
--
--           Used for FIFOs with synchronous pipelined RAMs. Contains
--           external caching in destination domain.  Status flags are 
--           dynamically configured.
--
--
--      Parameters     Valid Values   Description
--      ==========     ============   ===========
--      width           1 to 1024     default: 8
--                                    Width of data to/from RAM
--
--      ram_depth     4 to 16777216   default: 8
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
--                                     -7 to -1 => when clk_d rate slower than clk_s rate: 0 - round(clk_s rate / clk_d rate)
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
--      ram_re_d_n       1 bit      Destination Domain Read Enable to RAM (active-low)
--      rd_addr_d        P bits     Destination Domain read address to RAM
--      data_d           M bits     Destination Domain data out
--      word_cnt_d       Q bits     Destination Domain FIFO word count (includes cache)
--      ram_word_cnt_d   N bits     Destination Domain RAM only word count
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
--          RJK  2/8/2017
--          Updated to allow clk_ratio=0 to be valid to support
--          arbitrary clock relationships (STAR 9001152809)
--
--          DLL - 8/02/11
--          Removed 'init_s_n_merge' into DW_sync...only use 'init_s_n'.  Also added
--          tst_mode=2 capability.
--
--          DLL - 11/15/10
--          Fixed default values for some parameters to match across all
--          source code.
--          This fix addresses STAR#9000429754.
--
--          DLL - 3/17/10
--          Fixed the de-assertion conditions for 'almost_empty_d' and
--          assertion condtions for 'half_full_d', 'almost_full_d', and
--          'full_d'.  This allows blind popping in with data underruns.
--          This fix addresses STAR#9000380664.
--
--          DLL - 3/16/10
--          Apply 'clr_in_prog_d' for synchronous resets to registers
--          instead of 'clr_sync_d' and 'clr_in_prog_s' used instead
--          of 'clr_sync_s'.
--          This fix addresses STAR#9000381235.
--
--          DLL - 11/4/09
--          Changed so that now the cache count includes RAM read in
--          progress state.  A gray-coded vector is used as a result.
--          This fix addresses STAR#9000353986.
--
--          DLL - 10/25/08
--          Added 'arch_type' parameter.
--
--          DLL - 1/23/07
--          Changed default value of ram_re_ext to 0.
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

architecture sim of DW_fifoctl_2c_df is
	
-- pragma translate_off

function calc_modulus( ram_depth, cnt_width : in INTEGER ) return INTEGER is
begin
 if ( (2**(cnt_width-1)) = ram_depth ) then
   return( ram_depth * 2 );
 else
   return( ram_depth + 2 - (ram_depth mod 2) );
 end if;
end calc_modulus;

function calc_adj_ptr_max( ram_depth, cnt_width : in INTEGER ) return INTEGER is
begin
 if ( (2**(cnt_width-1)) = ram_depth ) then
   return( ram_depth * 2 );
 else
   return( ram_depth + 2 - (ram_depth mod 2) );
 end if;
end calc_adj_ptr_max;

function calc_inuse_cnt_width( width : in INTEGER ) return INTEGER is
begin
 if ( width = 1 ) then
   return( 1 );
 else
   return( 2 );
 end if;
end calc_inuse_cnt_width;

function calc_is_ram_2totheN( ram_depth : in INTEGER ) return INTEGER is
variable i       : INTEGER := 0;
variable vect    : std_logic_vector(31 downto 0);
variable cnt     : INTEGER := 0;
begin
  vect := CONV_STD_LOGIC_VECTOR(ram_depth, 32);
  for i in 0 to 31 loop
    if (vect(i) = '1') then
      cnt := cnt + 1;
    end if;
  end loop;
  if ( cnt = 1 ) then
    return ( 1 );
  else
    return ( 0 );
  end if;
end calc_is_ram_2totheN; 

function calc_push_gray_sync_delay( mem_mode, f_sync_type, clk_ratio : in INTEGER ) return INTEGER is
begin
  if ( (clk_ratio > 0) AND (mem_mode > 3) ) then
    if ( (mem_mode = 4) OR (mem_mode = 5) ) then
      if ( (f_sync_type + 1) <= clk_ratio ) then
        return ( 1 );
      else
        return ( 0 );
      end if;
    else
      if ( (f_sync_type + 2) <= clk_ratio ) then
        return ( 1 );
      else
        return ( 0 );
      end if;
    end if;
  else
    if ( (clk_ratio = 0) AND (mem_mode > 3) ) then
      return ( 1 );
    else
      return ( 0 );
    end if;
  end if;
end calc_push_gray_sync_delay;

function calc_pop_gray_sync_delay( ram_depth_2N, mem_mode, r_sync_type, clk_ratio : in INTEGER ) return INTEGER is
begin
  if ( (ram_depth_2N = 1) AND (clk_ratio < 0) AND (((mem_mode/2) mod 2) = 1) ) then
    if ( mem_mode < 4 ) then
      if ( (0 - (r_sync_type + 1)) >= clk_ratio ) then
        return ( 1 );
      else
        return ( 0 );
      end if;
    else
      if ( (0 - (r_sync_type + 2)) >= clk_ratio ) then
        return ( 1 );
      else
        return ( 0 );
      end if;
    end if;
  else
    if ( (ram_depth_2N = 1) AND (clk_ratio = 0) AND (((mem_mode/2) mod 2) = 1) ) then
      return ( 1 );
    else
      return ( 0 );
    end if;
  end if;
end calc_pop_gray_sync_delay;

function calc_clk_d_faster( clr_dual_domain, clk_ratio : in INTEGER ) return INTEGER is
begin
 if ( clr_dual_domain = 1 ) then
   if ( clk_ratio > 0 ) then
     return( clk_ratio + 1);
   else
     return ( 1 );
   end if;
 else
   return( 0 );
 end if;
end calc_clk_d_faster;

function calc_gray_verif_en( given_verif_en : in INTEGER ) return INTEGER is
begin
  if (given_verif_en = 2) then
    return ( 4 );
  elsif (given_verif_en = 3) then
    return ( 1 );
  else
    return( given_verif_en );
  end if;
end calc_gray_verif_en;

function my_bin2gray (B : std_logic_vector) return std_logic_vector is
  variable b_v : std_logic_vector(B'length downto 0);
  variable g_v : std_logic_vector(B'length-1 downto 0);
begin
  b_v := '0' & B;
  g_v := B xor b_v(B'length downto 1);
  return g_v;
end my_bin2gray;

function my_gray2bin (G : std_logic_vector) return std_logic_vector is
  variable g_v : std_logic_vector(G'length-1 downto 0);
  variable b_v : std_logic_vector(G'length downto 0);
begin
  g_v := G;
  b_v(G'length) := '0';
  for i in G'length-1 downto 0 loop
    b_v(i) := g_v(i) xor b_v(i+1);
  end loop;
  return b_v(G'length-1 downto 0);
end my_gray2bin;


constant gray_verif_en : INTEGER := calc_gray_verif_en( verif_en );

constant F_SYNC_TYPE_ADD8     : INTEGER := (f_sync_type + 8);

constant F_SYNC_TYPE_INT      : INTEGER := (f_sync_type mod 8);

constant R_SYNC_TYPE_ADD8     : INTEGER := (r_sync_type + 8);

constant R_SYNC_TYPE_INT      : INTEGER := (r_sync_type mod 8);

constant eff_depth            : INTEGER := ram_depth+1+(mem_mode mod 2)+((mem_mode/2) mod 2);
constant addr_width           : INTEGER := bit_width(ram_depth);
constant cnt_width            : INTEGER := bit_width(ram_depth+1);
constant fifo_cnt_width       : INTEGER := bit_width(eff_depth+1);
constant modulus              : INTEGER := calc_modulus(ram_depth, cnt_width);
constant leftover_cnt         : INTEGER := (2**cnt_width) - modulus;
constant adj_ptr_max          : INTEGER := calc_adj_ptr_max(ram_depth, cnt_width);
constant offset               : INTEGER := leftover_cnt / 2;
constant inuse_width          : INTEGER := 1+((mem_mode/2) mod 2)+(mem_mode mod 2);
constant inuse_cnt_width      : INTEGER := calc_inuse_cnt_width(inuse_width);
constant ram_depth_2N         : INTEGER := calc_is_ram_2totheN(ram_depth);
constant push_gray_sync_delay : INTEGER := calc_push_gray_sync_delay(mem_mode, F_SYNC_TYPE_INT, clk_ratio);
constant pop_gray_sync_delay  : INTEGER := calc_pop_gray_sync_delay(ram_depth_2N, mem_mode, R_SYNC_TYPE_INT, clk_ratio);
constant clk_d_faster_int     : INTEGER := calc_clk_d_faster(clr_dual_domain, clk_ratio);
constant zeroes               : std_logic_vector(fifo_cnt_width-1 downto 0) := (others => '0');

constant mem_mode_vector      : std_logic_vector(31 downto 0) := std_logic_vector(CONV_UNSIGNED(mem_mode, 32));

type CacheData is array (0 to inuse_width-1) of
         std_logic_vector(width-1 downto 0);

signal   cache_one_deep       : std_logic;


-- Source Domain Interconnects
signal wr_en_s_int               : std_logic;                               -- Source Domain enable to gray code synchronizer
signal wr_ptr_s                  : std_logic_vector(cnt_width-1 downto 0);  -- Source Domain next write pointer (relative to RAM) - unregisterd
signal rd_ptr_s                  : std_logic_vector(cnt_width-1 downto 0);  -- Source Domain synchronized read pointer (relative to RAM)
signal wr_addr_s_FWD_GRAY        : std_logic_vector(cnt_width-1 downto 0);  -- Source Domain synchronized write address (relative to RAM)

signal cache_census_gray_s       : std_logic_vector(inuse_cnt_width-1 downto 0);  -- Source Domain synchronized external cache count (gray-coded vector)
signal cache_census_s            : std_logic_vector(inuse_cnt_width-1 downto 0);  -- Source Domain synchronized external cache count (binary-value vector)
signal cache_census_gray_d_cc    : std_logic_vector(inuse_cnt_width-1 downto 0);  -- Source Domain for DW_sync front-end
signal cache_census_gray_d_l     : std_logic_vector(inuse_cnt_width-1 downto 0);  -- Source Domain for DW_sync front-end
signal cache_census_gray_d       : std_logic_vector(inuse_cnt_width-1 downto 0);  -- Source Domain for DW_sync front-end
signal inuse_d             : std_logic_vector(2 downto 0);  -- Source Domain for DW_sync front-end
signal next_inuse_d        : std_logic_vector(2 downto 0);  -- Source Domain for DW_sync front-end

-- Source Domain internal signals
signal init_s_n_FWD_GRAY_SYNC    : std_logic;
signal init_d_n_FWD_GRAY_SYNC    : std_logic;
signal clr_sync_s_int            : std_logic;
signal clr_in_prog_s_int         : std_logic;
signal clr_in_prog_s_int_d1      : std_logic;
signal clr_cmplt_s_int           : std_logic;
signal empty_s_int               : std_logic;
signal next_empty_s_int          : std_logic;
signal almost_empty_s_int        : std_logic;
signal next_almost_empty_s_int   : std_logic;
signal half_full_s_int           : std_logic;
signal next_half_full_s_int      : std_logic;
signal almost_full_s_int         : std_logic;
signal next_almost_full_s_int    : std_logic;
signal full_s_int                : std_logic;
signal next_full_s_int           : std_logic;
signal next_error_s_int          : std_logic;
signal error_s_int               : std_logic;

signal fifo_word_cnt_s_int       : integer := 0;
signal next_fifo_word_cnt_s_int  : integer := 0;
signal word_cnt_s_int            : integer := 0;
signal next_word_cnt_s_int       : integer := 0;




-- Destination Domain Interconnects
signal ram_re_d_int              : std_logic;                               -- Destination Domain enable to gray code synchronizer
signal rd_ptr_d                  : std_logic_vector(cnt_width-1 downto 0);  -- Destination Domain synchronized read pointer (relative to RAM)
signal rd_addr_d_REV_GRAY        : std_logic_vector(cnt_width-1 downto 0);  -- Destination Domain synchronized read address (relative to RAM)
signal wr_ptr_d                  : std_logic_vector(cnt_width-1 downto 0);  -- Destination Domain next write pointer (relative to RAM) - unregisterd

-- Destination Domain internal signals
signal init_s_n_REV_GRAY_SYNC    : std_logic;
signal init_d_n_REV_GRAY_SYNC    : std_logic;
signal clr_in_prog_d_int         : std_logic;
signal clr_in_prog_d_int_d1      : std_logic;
signal clr_sync_d_int            : std_logic;
signal clr_cmplt_d_int           : std_logic;
signal empty_d_int               : std_logic;
signal almost_empty_d_int        : std_logic;
signal next_almost_empty_d_int   : std_logic;
signal half_full_d_int           : std_logic;
signal next_half_full_d_int      : std_logic;
signal almost_full_d_int         : std_logic;
signal next_almost_full_d_int    : std_logic;
signal full_d_int                : std_logic;
signal next_full_d_int           : std_logic;
signal next_error_d_int          : std_logic;
signal error_d_int               : std_logic;
signal ram_empty_d               : std_logic;
signal cache_full                : std_logic;

signal word_cnt_d_int            : integer := 0;
signal next_word_cnt_d_int       : integer := 0;
signal ram_word_cnt_d_int        : integer := 0;
signal next_ram_word_cnt_d_int   : integer := 0;
signal total_census_d            : integer := 0;
signal total_census_vec_d        : std_logic_vector(inuse_cnt_width-1 downto 0);
signal next_inuse_d_census       : integer := 0;
signal next_cache_full_d         : std_logic;

signal rd_pend_sr_d              : std_logic_vector(1 downto 0);
signal next_rd_pend_sr_d         : std_logic_vector(1 downto 0);

signal ld_cache                  : std_logic;
 
signal cache_data_d              : CacheData;
signal next_cache_data_d         : CacheData;

signal ram_empty_d_d1            : std_logic;
signal ram_empty_d_d1_int        : std_logic;
signal ram_empty_d_pipe          : std_logic;
signal rd_data_d_int             : std_logic_vector(width-1 downto 0);



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
   
    if ( (ram_depth < 4) OR (ram_depth > 16777216) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter ram_depth (legal range: 4 to 16777216)"
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
   
    if ( (ram_re_ext < 0) OR (ram_re_ext > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter ram_re_ext (legal range: 0 to 1)"
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

  U_RST: DW_reset_sync
    generic map (
      f_sync_type   => F_SYNC_TYPE_ADD8,
      r_sync_type   => R_SYNC_TYPE_ADD8,
      clk_d_faster  => clk_d_faster_int,
      reg_in_prog   => 0,
      tst_mode      => tst_mode,
      verif_en      => verif_en)
    port map (
      clk_s         => clk_s,
      rst_s_n       => rst_s_n,
      init_s_n      => init_s_n,
      clr_s         => clr_s,
      clr_sync_s    => clr_sync_s_int,
      clr_in_prog_s => clr_in_prog_s_int,
      clr_cmplt_s   => clr_cmplt_s_int,
      clk_d         => clk_d,
      rst_d_n       => rst_d_n,
      init_d_n      => init_d_n,
      clr_d         => clr_d,
      clr_in_prog_d => clr_in_prog_d_int,
      clr_sync_d    => clr_sync_d_int,
      clr_cmplt_d   => clr_cmplt_d_int,
      test          => test);

  init_s_n_FWD_GRAY_SYNC <= (init_s_n AND NOT(clr_in_prog_s_int));
  init_d_n_FWD_GRAY_SYNC <= (init_d_n AND NOT(clr_in_prog_d_int));

  U_FWD_GRAY: DW_gray_sync
    generic map (
      width              => cnt_width,
      offset             => offset,
      reg_count_d        => 0,
      f_sync_type        => F_SYNC_TYPE_ADD8,
      tst_mode           => tst_mode,
      verif_en           => gray_verif_en,
      pipe_delay         => push_gray_sync_delay,
      reg_count_s        => 0,
      reg_offset_count_s => 1) 
    port map (
      clk_s              => clk_s,
      rst_s_n            => rst_s_n,
      init_s_n           => init_s_n_FWD_GRAY_SYNC,
      en_s               => wr_en_s_int,
      count_s            => wr_ptr_s,
      offset_count_s     => wr_addr_s_FWD_GRAY,
      clk_d              => clk_d,
      rst_d_n            => rst_d_n,
      init_d_n           => init_d_n_FWD_GRAY_SYNC,
      count_d            => wr_ptr_d,
      test               => test);


  init_s_n_REV_GRAY_SYNC <= (init_s_n AND NOT(clr_in_prog_s_int));
  init_d_n_REV_GRAY_SYNC <= (init_d_n AND NOT(clr_in_prog_d_int));

  U_REV_GRAY: DW_gray_sync
    generic map (
      width              => cnt_width,
      offset             => offset,
      reg_count_d        => 0,
      f_sync_type        => R_SYNC_TYPE_ADD8,
      tst_mode           => tst_mode,
      verif_en           => gray_verif_en,
      pipe_delay         => pop_gray_sync_delay,
      reg_count_s        => 0,
      reg_offset_count_s => 1) 
    port map (
      clk_s              => clk_d,
      rst_s_n            => rst_d_n,
      init_s_n           => init_d_n_REV_GRAY_SYNC,
      en_s               => ram_re_d_int,
      count_s            => rd_ptr_d,
      offset_count_s     => rd_addr_d_REV_GRAY,
      clk_d              => clk_s,
      rst_d_n            => rst_s_n,
      init_d_n           => init_s_n_REV_GRAY_SYNC,
      count_d            => rd_ptr_s,
      test               => test);


  
  rvs_hold_latch_PROC : process(clk_d, cache_census_gray_d) begin
    if (clk_d = '0') then
      cache_census_gray_d_l <= cache_census_gray_d;
    end if;
  end process rvs_hold_latch_PROC;

  cache_census_gray_d_cc <= cache_census_gray_d_l when (((r_sync_type mod 8) > 1) AND (tst_mode = 2) AND (test = '1')) else cache_census_gray_d;

  U_REV_SYNC : DW_sync
    generic map (
	width => inuse_cnt_width,
	f_sync_type => r_sync_type+8,
	tst_mode => tst_mode,
	verif_en => verif_en )
    port map (
	clk_d => clk_s,
	rst_d_n => rst_s_n,
	init_d_n => init_s_n,
	data_s => cache_census_gray_d_cc,
	test => test,
	data_d => cache_census_gray_s );



  wr_en_s_int     <= NOT(full_s_int) AND NOT(push_s_n);
  wr_en_s_n       <= NOT(wr_en_s_int);


  mk_next_word_cnt_s_int : process (wr_ptr_s, rd_ptr_s, word_cnt_s_int)
    variable wr_ptr_integ  : INTEGER;
    variable rd_ptr_integ  : INTEGER;
  begin  -- process mk_next_word_cnt_s_int
    wr_ptr_integ  := CONV_INTEGER(UNSIGNED(wr_ptr_s));
    rd_ptr_integ  := CONV_INTEGER(UNSIGNED(rd_ptr_s));
    if (word_cnt_s_int < 0) then
      next_word_cnt_s_int <= word_cnt_s_int;
    else
      if (wr_ptr_integ >= rd_ptr_integ) then
        next_word_cnt_s_int <=  wr_ptr_integ - rd_ptr_integ;
      elsif (wr_ptr_integ < rd_ptr_integ) then
        next_word_cnt_s_int <= adj_ptr_max - (rd_ptr_integ - wr_ptr_integ);
      else
        next_word_cnt_s_int <= -1;
      end if;
    end if;
  end process mk_next_word_cnt_s_int;

  mk_next_error_s : process (push_s_n, full_s_int, error_s_int)
    variable error_seen  : std_logic;
  begin  -- process mk_next_error_s
    if ((push_s_n = '0') AND (full_s_int = '1')) then
      error_seen := '1';
    else
      error_seen := '0';
    end if;
    if (err_mode < 1) then
      next_error_s_int <= error_seen OR error_s_int;
    else
      next_error_s_int <= error_seen;
    end if;
  end process mk_next_error_s;

  mk_source_flags : process (next_word_cnt_s_int, ae_level_s, af_level_s, clr_in_prog_s_int)
    variable next_word_cnt_s_int_slv : std_logic_vector(cnt_width-1 downto 0);
  begin  -- process mk_source_flags
    next_word_cnt_s_int_slv := std_logic_vector(CONV_UNSIGNED(next_word_cnt_s_int,cnt_width));
    if (next_word_cnt_s_int < 0) then
      next_empty_s_int        <= 'X';
      next_almost_empty_s_int <= 'X';
      next_half_full_s_int    <= 'X';
      next_almost_full_s_int  <= 'X';
      next_full_s_int         <= 'X';
    else
      if ((next_word_cnt_s_int_slv = 0) OR (clr_in_prog_s_int = '1')) then next_empty_s_int <= '1'; 
      else next_empty_s_int        <= '0'; end if;
      if ((next_word_cnt_s_int_slv <= ae_level_s) OR (clr_in_prog_s_int = '1')) then next_almost_empty_s_int <= '1'; 
      else next_almost_empty_s_int <= '0'; end if;
      if ((next_word_cnt_s_int_slv < (ram_depth+1)/2) OR (clr_in_prog_s_int = '1')) then next_half_full_s_int <= '0'; 
      else next_half_full_s_int    <= '1'; end if;
      if ((next_word_cnt_s_int_slv < ram_depth-af_level_s) OR (clr_in_prog_s_int = '1')) then next_almost_full_s_int  <= '0'; 
      else next_almost_full_s_int  <= '1'; end if;
      if ((next_word_cnt_s_int_slv /= ram_depth) OR (clr_in_prog_s_int = '1')) then next_full_s_int <= '0'; 
      else next_full_s_int         <= '1'; end if;
    end if;
  end process mk_source_flags;

  G2B_1: if (inuse_cnt_width = 1) generate
    cache_census_s <= cache_census_gray_s;
  end generate G2B_1;
  G2B_2: if (inuse_cnt_width = 2) generate
    cache_census_s <= my_gray2bin(cache_census_gray_s);
  end generate G2B_2;
  
  next_fifo_word_cnt_s_int <= next_word_cnt_s_int + CONV_INTEGER(UNSIGNED(cache_census_s));

  clk_s_general_regs : process (clk_s)
  begin
    if (clk_s'event and clk_s = '1') then
      clr_in_prog_s_int_d1  <= clr_in_prog_s_int;
    end if;
  end process clk_s_general_regs;
  
  clk_s_registers : process (clk_s, rst_s_n)
  begin
  
    if (rst_s_n = '0' ) then
        fifo_word_cnt_s_int   <= 0;
        word_cnt_s_int        <= 0;
        error_s_int           <= '0';
        empty_s_int           <= '0';
        almost_empty_s_int    <= '0';
        half_full_s_int       <= '0';
        almost_full_s_int     <= '0';
        full_s_int            <= '0';
    elsif (rst_s_n = '1') then
      if (clk_s'event and clk_s = '1') then
        if ((init_s_n = '0') OR (clr_in_prog_s_int = '1')) then
          fifo_word_cnt_s_int   <= 0;
          word_cnt_s_int        <= 0;
          error_s_int           <= '0' ;
          empty_s_int           <= '0';
          almost_empty_s_int    <= '0';
          half_full_s_int       <= '0';
          almost_full_s_int     <= '0';
          full_s_int            <= '0';
        elsif (init_s_n = '1') then
          fifo_word_cnt_s_int   <= next_fifo_word_cnt_s_int;
          word_cnt_s_int        <= next_word_cnt_s_int;
          error_s_int           <= next_error_s_int ;
          empty_s_int           <= NOT(next_empty_s_int);
          almost_empty_s_int    <= NOT(next_almost_empty_s_int);
          half_full_s_int       <= next_half_full_s_int;
          almost_full_s_int     <= next_almost_full_s_int;
          full_s_int            <= next_full_s_int;
        else
          fifo_word_cnt_s_int   <= -1;
          word_cnt_s_int        <= -1;
          error_s_int           <= 'X' ;
        end if;
      end if;
    else
      fifo_word_cnt_s_int   <= -1;
      word_cnt_s_int        <= -1;
      error_s_int           <= 'X' ;
    end if;
  end process clk_s_registers;


  clr_sync_s      <= clr_sync_s_int;
  clr_in_prog_s   <= clr_in_prog_s_int;
  clr_cmplt_s     <= clr_cmplt_s_int;
  word_cnt_s      <= (others => 'X') when (word_cnt_s_int < 0) else std_logic_vector(CONV_UNSIGNED(word_cnt_s_int, cnt_width));
  fifo_word_cnt_s <= (others => 'X') when (fifo_word_cnt_s_int < 0) else std_logic_vector(CONV_UNSIGNED(fifo_word_cnt_s_int, fifo_cnt_width));
  wr_addr_s       <= wr_addr_s_FWD_GRAY(addr_width-1 downto 0);
  fifo_empty_s    <= '1' when ((std_logic_vector(CONV_UNSIGNED(fifo_word_cnt_s_int, fifo_cnt_width)) = zeroes) OR (clr_in_prog_s_int_d1 = '1')) else '0';
  empty_s         <= NOT(empty_s_int);
  almost_empty_s  <= NOT(almost_empty_s_int);
  half_full_s     <= half_full_s_int;
  almost_full_s   <= almost_full_s_int;
  full_s          <= full_s_int;
  error_s         <= error_s_int;
  



  mk_next_ram_word_cnt_d_int : process (wr_ptr_d, rd_ptr_d, ram_word_cnt_d_int)
    variable wr_ptr_integ  : INTEGER;
    variable rd_ptr_integ  : INTEGER;
  begin  -- process mk_next_ram_word_cnt_d_int
    wr_ptr_integ  := CONV_INTEGER(UNSIGNED(wr_ptr_d));
    rd_ptr_integ  := CONV_INTEGER(UNSIGNED(rd_ptr_d));
    if (ram_word_cnt_d_int < 0) then
      next_ram_word_cnt_d_int <= ram_word_cnt_d_int;
    else
      if (wr_ptr_integ >= rd_ptr_integ) then
        next_ram_word_cnt_d_int <=  wr_ptr_integ - rd_ptr_integ;
      elsif (wr_ptr_integ < rd_ptr_integ) then
        next_ram_word_cnt_d_int <= adj_ptr_max - (rd_ptr_integ - wr_ptr_integ);
      else
        next_ram_word_cnt_d_int <= -1;
      end if;
    end if;
  end process mk_next_ram_word_cnt_d_int;
  
  mk_total_census_d: process (inuse_d, rd_pend_sr_d)
    variable i1        : integer;
    variable i2        : integer;
    variable temp_cnt1 : integer;
    variable temp_cnt2 : integer;
  begin
    temp_cnt1 := 0;
    temp_cnt2 := 0;
    for i1 in 0 to inuse_width-1 loop
      if (inuse_d(i1) = '1') then
        temp_cnt1 := temp_cnt1 + 1;
      end if;
    end loop;
    for i2 in 0 to 1 loop
      if (rd_pend_sr_d(i2) = '1') then
        temp_cnt2 := temp_cnt2 + 1;
      end if;
    end loop;
    total_census_d <= temp_cnt1 + temp_cnt2;
  end process mk_total_census_d;

  mk_next_inuse_d_census: process (next_inuse_d)
    variable i1        : integer;
    variable temp_cnt1 : integer;
  begin
    temp_cnt1 := 0;
    for i1 in 0 to inuse_width-1 loop
      if (next_inuse_d(i1) = '1') then
        temp_cnt1 := temp_cnt1 + 1;
      end if;
    end loop;
    next_inuse_d_census <= temp_cnt1;
  end process mk_next_inuse_d_census;

  next_cache_full_d <= '1' when (next_inuse_d_census = inuse_width) else '0';

  total_census_vec_d  <= std_logic_vector(CONV_UNSIGNED(total_census_d,inuse_cnt_width));
B2G_1: if (inuse_cnt_width = 1) generate
  cache_census_gray_d <= total_census_vec_d;
end generate B2G_1;
B2G_2: if (inuse_cnt_width = 2) generate
  cache_census_gray_d <= my_bin2gray(total_census_vec_d);
end generate B2G_2;
  
  ram_empty_d    <= '1' when ((ram_word_cnt_d_int = 0) OR (clr_in_prog_d_int_d1 = '1')) else '0';
  cache_full     <= '1' when (total_census_d = inuse_width) else '0';
  ram_re_d_int   <= NOT(ram_empty_d) AND (NOT(pop_d_n) OR NOT(cache_full));
  
  mk_rd_pending_logic: process (ram_re_d_int, rd_pend_sr_d)
  begin
    if (((mem_mode=0) OR (mem_mode=4))) then
      next_rd_pend_sr_d  <= (others => '0');
      ld_cache           <= ram_re_d_int;
    elsif (((mem_mode=3) OR (mem_mode=7))) then
      next_rd_pend_sr_d  <= rd_pend_sr_d(0) & ram_re_d_int; 
      ld_cache           <= rd_pend_sr_d(1);
    else
      next_rd_pend_sr_d  <= '0' & ram_re_d_int;
      ld_cache           <= rd_pend_sr_d(0);
    end if;
  end process mk_rd_pending_logic;


  mk_next_inuse_d : process (pop_d_n, ld_cache, inuse_d)
  begin
    if (((mem_mode=0) OR (mem_mode=4))) then
      if ((pop_d_n = '0') OR (ld_cache = '1')) then
        next_inuse_d(0) <= ld_cache;
      else
        next_inuse_d(0) <= inuse_d(0);
      end if;
      next_inuse_d(1) <= inuse_d(1);
      next_inuse_d(2) <= inuse_d(2);
    else
      if (((ld_cache = '1') AND (inuse_d(0) = '0')) OR 
          ((pop_d_n = '0') AND (ld_cache = '0') AND (inuse_d(1) = '0') AND (inuse_d(2) = '0'))) then
        next_inuse_d(0) <= ld_cache;
      else
        next_inuse_d(0) <= inuse_d(0);
      end if;
      if (((pop_d_n = '1') AND (ld_cache= '1')  AND (inuse_d(0)= '1') AND (inuse_d(2) = '0')) OR
           ((pop_d_n = '0') AND (ld_cache = '0') AND (inuse_d(2) = '0'))) then
        next_inuse_d(1) <= ld_cache;
      else
        next_inuse_d(1) <= inuse_d(1);
      end if;
      if (((mem_mode=3) OR (mem_mode=7))) then
        if (((pop_d_n = '0') AND (ld_cache = '0')) OR
            ((pop_d_n = '1') AND (ld_cache = '1') AND (inuse_d(0) = '1') AND (inuse_d(1) = '1'))) then
          next_inuse_d(2) <= ld_cache;
        else
          next_inuse_d(2) <= inuse_d(2);
        end if;
      else
        next_inuse_d(2) <= inuse_d(2);
      end if;
    end if;
  end process mk_next_inuse_d;

  ram_empty_d_pipe <= ram_empty_d_d1_int when (((mem_mode mod 2) = 0) AND (((mem_mode/2) mod 2) = 1)) else ram_empty_d;
  rd_data_d_int    <= (others => '0') when (((mem_mode mod 2) = 0) AND (ram_empty_d_pipe = '1')) else (To_X01(rd_data_d));

  mk_next_cache_data_d : process (pop_d_n, ld_cache, inuse_d, rd_data_d_int, cache_data_d)
    variable  i : INTEGER := 0;
  begin
    for i in 0 to inuse_width-1 loop
      if (((mem_mode=0) OR (mem_mode=4))) then
        if (((ld_cache = '1') AND (inuse_d(0) = '0')) OR 
            ((pop_d_n = '0') AND (ld_cache = '1') AND (inuse_d(0) = '1'))) then
          next_cache_data_d(i)  <= rd_data_d_int;
        else
          next_cache_data_d(i)  <= cache_data_d(i);
        end if;
      elsif (((mem_mode=1) OR (mem_mode=2) OR (mem_mode=5) OR (mem_mode=6))) then
        if (i = 0) then
          if (((ld_cache = '1') AND (inuse_d(0) = '0')) OR 
              ((pop_d_n = '0') AND ((ld_cache = '1') AND (inuse_d(1) = '0')))) then
            next_cache_data_d(i)  <= rd_data_d_int;
          else
            if ((pop_d_n = '0') AND (inuse_d(1) = '1')) then
              next_cache_data_d(i)  <= cache_data_d(i+1);
            else
              next_cache_data_d(i)  <= cache_data_d(i);
            end if;
          end if;
        else  -- i=1
          if (((pop_d_n = '1') AND (ld_cache = '1') AND (inuse_d(0) = '1') AND (inuse_d(1) = '0')) OR 
              ((pop_d_n = '0') AND (ld_cache = '1') AND (inuse_d(1) = '1'))) then
            next_cache_data_d(i)  <= rd_data_d_int;
          else
            next_cache_data_d(i)  <= cache_data_d(i);
          end if;
        end if;
      else
        if (i = 0) then
          if (((ld_cache = '1') AND (inuse_d(0) = '0')) OR 
              ((pop_d_n = '0') AND (ld_cache = '1') AND (inuse_d(1) = '0'))) then
            next_cache_data_d(i)  <= rd_data_d_int;
          else 
            if ((pop_d_n = '0') AND (inuse_d(1) = '1')) then
              next_cache_data_d(i)  <= cache_data_d(i+1);
            else
              next_cache_data_d(i)  <= cache_data_d(i);
            end if;
          end if;  -- for next_cache_data_d(0)
        elsif (i = 1) then
          if ((((pop_d_n = '1') AND (ld_cache = '1') AND (inuse_d(0) = '1') AND (inuse_d(1) = '0')) OR 
              ((pop_d_n = '0') AND (ld_cache = '1') AND (inuse_d(1) = '1') AND (inuse_d(2) = '0')))) then
            next_cache_data_d(i)  <= rd_data_d_int;
          else 
            if ((pop_d_n = '0') AND (inuse_d(2) = '1')) then
              next_cache_data_d(i)  <= cache_data_d(i+1);
            else
              next_cache_data_d(i)  <= cache_data_d(i);
            end if;
          end if;  -- for next_cache_data_d(1)
        else  -- i=2
          if (((pop_d_n = '1') AND (ld_cache = '1') AND (inuse_d(1) = '1') AND (inuse_d(2) = '0')) OR
              ((pop_d_n = '0') AND (ld_cache = '1') AND (inuse_d(2) = '1'))) then -- for next_cache_data_d(2
            next_cache_data_d(i)  <= rd_data_d_int;
          else  --for next_cache_data_d(2)
            next_cache_data_d(i)  <= cache_data_d(i);
          end if;
        end if;
      end if;
    end loop;
  end process mk_next_cache_data_d;


  mk_next_word_cnt_d : process (next_ram_word_cnt_d_int, next_inuse_d, next_rd_pend_sr_d)
    variable i1         : INTEGER;
    variable i2         : INTEGER;
    variable temp_cnt1  : INTEGER;
    variable temp_cnt2  : INTEGER;
  begin
    temp_cnt1 := 0;
    temp_cnt2 := 0;
    if (next_ram_word_cnt_d_int < 0 ) then
      next_word_cnt_d_int <= -1;
    else
      for i1 in 0 to inuse_width-1 loop
        if (next_inuse_d(i1) = '1') then
          temp_cnt1 := temp_cnt1 + 1;
        end if;
      end loop;
      for i2 in 0 to 1 loop
        if (next_rd_pend_sr_d(i2) = '1') then
          temp_cnt2 := temp_cnt2 + 1;
        end if;
      end loop;
      next_word_cnt_d_int <= next_ram_word_cnt_d_int + temp_cnt1 + temp_cnt2; 
    end if;
  end process mk_next_word_cnt_d;

  mk_next_error_d : process (pop_d_n, empty_d_int, error_d_int)
    variable error_seen  : std_logic;
  begin  -- process mk_next_error_d
    if ((pop_d_n = '0') AND (empty_d_int = '1')) then
      error_seen := '1';
    else
      error_seen := '0';
    end if;
    if (err_mode < 1) then
      next_error_d_int <= error_seen OR error_d_int;
    else
      next_error_d_int <= error_seen;
    end if;
  end process mk_next_error_d;


  empty_d_int  <= NOT(inuse_d(0)) OR clr_in_prog_d_int_d1;
  
  mk_destination_flags : process (next_word_cnt_d_int, ae_level_d, af_level_d, clr_in_prog_d_int,
                                  almost_empty_d_int, half_full_d_int, almost_full_d_int,
                                  full_d_int, next_inuse_d_census, next_cache_full_d)
    variable next_word_cnt_d_int_slv     : std_logic_vector(fifo_cnt_width-1 downto 0);
  begin  -- process mk_destination_flags
    next_word_cnt_d_int_slv := std_logic_vector(CONV_UNSIGNED(next_word_cnt_d_int,fifo_cnt_width));
    if (next_word_cnt_d_int < 0) then
      next_almost_empty_d_int <= 'X';
      next_half_full_d_int    <= 'X';
      next_almost_full_d_int  <= 'X';
      next_full_d_int         <= 'X';
    else
      if (almost_empty_d_int = '0') then
        if (((next_word_cnt_d_int_slv <= ae_level_d) OR ((next_cache_full_d = '0') AND (next_inuse_d_census <= ae_level_d))) OR 
             (clr_in_prog_d_int = '1')) then next_almost_empty_d_int <= '1'; 
        else next_almost_empty_d_int <= '0'; end if;
      else
        if ((next_word_cnt_d_int_slv <= ae_level_d) OR (clr_in_prog_d_int = '1')) then next_almost_empty_d_int <= '1'; 
        else next_almost_empty_d_int <= '0'; end if;
      end if;
      if (half_full_d_int = '0') then
        if ((((next_word_cnt_d_int_slv < (eff_depth+1)/2)) OR (next_cache_full_d = '0')) OR (clr_in_prog_d_int = '1')) then
          next_half_full_d_int <= '0'; 
        else next_half_full_d_int    <= '1'; end if;
      else
        if ((next_word_cnt_d_int_slv < (eff_depth+1)/2) OR (clr_in_prog_d_int = '1')) then next_half_full_d_int <= '0'; 
        else next_half_full_d_int    <= '1'; end if;
      end if;
      if (almost_full_d_int = '0') then
        if ((((next_word_cnt_d_int_slv < eff_depth-af_level_d)) OR 
              ((next_cache_full_d = '0') AND (next_inuse_d_census < eff_depth-af_level_d))) OR 
            (clr_in_prog_d_int = '1')) then next_almost_full_d_int <= '0'; 
        else next_almost_full_d_int  <= '1'; end if;
      else
        if ((next_word_cnt_d_int_slv < eff_depth-af_level_d) OR (clr_in_prog_d_int = '1')) then next_almost_full_d_int <= '0'; 
        else next_almost_full_d_int  <= '1'; end if;
      end if;
      if (full_d_int = '0') then
        if (((next_word_cnt_d_int_slv /= eff_depth) OR (next_cache_full_d = '0')) OR (clr_in_prog_d_int = '1')) then next_full_d_int <= '0'; 
        else next_full_d_int         <= '1'; end if;
      else
        if ((next_word_cnt_d_int_slv /= eff_depth) OR (clr_in_prog_d_int = '1')) then next_full_d_int <= '0'; 
        else next_full_d_int         <= '1'; end if;
      end if;
    end if;
  end process mk_destination_flags;
  
  word_cnt_d <= (others => 'X') when (word_cnt_d_int < 0) else std_logic_vector(CONV_UNSIGNED(word_cnt_d_int,fifo_cnt_width));
  
  clk_d_general_regs : process (clk_d)
  begin
    if (clk_d'event and clk_d = '1') then
      clr_in_prog_d_int_d1  <= clr_in_prog_d_int;
    end if;
  end process clk_d_general_regs;
  
  clk_d_registers : process (clk_d, rst_d_n)
    variable  i : INTEGER;
  begin
  
    if (rst_d_n = '0' ) then
        inuse_d               <= (others => '0');
        rd_pend_sr_d          <= (others => '0');
        word_cnt_d_int        <= 0;
        ram_word_cnt_d_int    <= 0;
        error_d_int           <= '0';
        almost_empty_d_int    <= '0';
        half_full_d_int       <= '0';
        almost_full_d_int     <= '0';
        full_d_int            <= '0';
	ram_empty_d_d1        <= '0';
        for i in 0 to inuse_width-1 loop
          cache_data_d(i)       <= (others => '0');
        end loop;
    elsif (rst_d_n = '1') then
      if (clk_d'event and clk_d = '1') then
        if ((init_d_n = '0') OR (clr_in_prog_d_int = '1')) then
          inuse_d               <= (others => '0');
          rd_pend_sr_d          <= (others => '0');
          word_cnt_d_int        <= 0;
          ram_word_cnt_d_int    <= 0;
          error_d_int           <= '0';
          almost_empty_d_int    <= '0';
          half_full_d_int       <= '0';
          almost_full_d_int     <= '0';
          full_d_int            <= '0';
	  ram_empty_d_d1        <= '0';
          for i in 0 to inuse_width-1 loop
            cache_data_d(i)       <= (others => '0');
          end loop;
        elsif (init_d_n = '1') then
          inuse_d               <= next_inuse_d;
          rd_pend_sr_d          <= next_rd_pend_sr_d;
          word_cnt_d_int        <= next_word_cnt_d_int;
          ram_word_cnt_d_int    <= next_ram_word_cnt_d_int;
          error_d_int           <= next_error_d_int;
          almost_empty_d_int    <= NOT(next_almost_empty_d_int);
          half_full_d_int       <= next_half_full_d_int;
          almost_full_d_int     <= next_almost_full_d_int;
          full_d_int            <= next_full_d_int;
	  ram_empty_d_d1        <= NOT(ram_empty_d);
          for i in 0 to inuse_width-1 loop
            cache_data_d(i)       <= next_cache_data_d(i);
          end loop;
        else
          inuse_d               <= (others => 'X');
          rd_pend_sr_d          <= (others => 'X');
          word_cnt_d_int        <= -1;
          ram_word_cnt_d_int    <= -1;
          error_d_int           <= 'X';
          almost_empty_d_int    <= 'X';
          half_full_d_int       <= 'X';
          almost_full_d_int     <= 'X';
          full_d_int            <= 'X';
	  ram_empty_d_d1        <= 'X';
          for i in 0 to inuse_width-1 loop
            cache_data_d(i)       <= (others => 'X');
          end loop;
        end if;
      end if;
    else
      inuse_d               <= (others => 'X');
      rd_pend_sr_d          <= (others => 'X');
      word_cnt_d_int        <= -1;
      ram_word_cnt_d_int    <= -1;
      error_d_int           <= 'X';
      almost_empty_d_int    <= 'X';
      half_full_d_int       <= 'X';
      almost_full_d_int     <= 'X';
      full_d_int            <= 'X';
      ram_empty_d_d1        <= 'X';
      for i in 0 to inuse_width-1 loop
        cache_data_d(i)       <= (others => 'X');
      end loop;
    end if;
  end process clk_d_registers;
  
  ram_empty_d_d1_int <= NOT(ram_empty_d_d1);

  clr_in_prog_d   <= clr_in_prog_d_int;
  clr_sync_d      <= clr_sync_d_int;
  clr_cmplt_d     <= clr_cmplt_d_int;
  rd_addr_d       <= rd_addr_d_REV_GRAY(addr_width-1 downto 0);
  data_d          <= cache_data_d(0);
  ram_word_cnt_d  <= std_logic_vector(CONV_UNSIGNED(ram_word_cnt_d_int, cnt_width));
  empty_d         <= empty_d_int;
  almost_empty_d  <= NOT(almost_empty_d_int);
  half_full_d     <= half_full_d_int;
  almost_full_d   <= almost_full_d_int;
  full_d          <= full_d_int;
  error_d         <= error_d_int;

  mk_ram_re_d_n : process (ram_re_d_int, rd_pend_sr_d)
  begin
    if (((mem_mode=0) OR (mem_mode=4)) OR (ram_re_ext = 0)) then ram_re_d_n <= NOT(ram_re_d_int);
    elsif (((mem_mode=1) OR (mem_mode=2) OR (mem_mode=5) OR (mem_mode=6))) then ram_re_d_n <= NOT(ram_re_d_int) AND NOT(rd_pend_sr_d(0));
    else ram_re_d_n <= NOT(ram_re_d_int) AND NOT(rd_pend_sr_d(0)) AND NOT(rd_pend_sr_d(1));
    end if;
  end process mk_ram_re_d_n;
  
  
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
configuration DW_fifoctl_2c_df_cfg_sim_ms of DW_fifoctl_2c_df is
 for sim
  for U_RST: DW_reset_sync use configuration dw03.DW_reset_sync_cfg_sim_ms; end for;
  for U_FWD_GRAY: DW_gray_sync use configuration dw03.DW_gray_sync_cfg_sim_ms; end for;
  for U_REV_GRAY: DW_gray_sync use configuration dw03.DW_gray_sync_cfg_sim_ms; end for;
--  for U_SYNC: DW_sync use configuration dw03.DW_sync_cfg_sim_ms; end for;
 end for; -- sim
end DW_fifoctl_2c_df_cfg_sim_ms;

library dw03;
configuration DW_fifoctl_2c_df_cfg_sim of DW_fifoctl_2c_df is
 for sim
  for U_RST: DW_reset_sync use configuration dw03.DW_reset_sync_cfg_sim; end for;
  for U_FWD_GRAY: DW_gray_sync use configuration dw03.DW_gray_sync_cfg_sim; end for;
  for U_REV_GRAY: DW_gray_sync use configuration dw03.DW_gray_sync_cfg_sim; end for;
--  for U_SYNC: DW_sync use configuration dw03.DW_sync_cfg_sim; end for;
 end for; -- sim
end DW_fifoctl_2c_df_cfg_sim;
-- pragma translate_on

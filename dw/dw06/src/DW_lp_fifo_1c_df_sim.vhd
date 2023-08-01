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
-- AUTHOR:    Doug Lee    Sep 25, 2009
--
-- VERSION:   VHDL Simulation Model
--
-- DesignWare_version: 955ae501
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT: VHDL Simulation Model for Single-clock FIFO with Dynamic Flags
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
---------------------------------------------------------------------------------
--
library IEEE,DWARE;
use STD.textio.all;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_misc.all;
use DWARE.DWpackages.all;
use DWARE.DW_foundation_comp_arith.all;

architecture sim of DW_lp_fifo_1c_df is
	
-- pragma translate_off

function calc_ram_depth( depth, mem_mode, arch_type : in INTEGER ) return INTEGER is
begin
 if ( arch_type = 0 ) then
   return( depth );
 elsif ( (arch_type = 1) OR (arch_type = 3) ) then
   if ( mem_mode = 0 ) then
     return ( depth - 1 );
   elsif ( (mem_mode = 3) OR (mem_mode = 5) OR (mem_mode = 7) ) then
     return ( depth - 3 );
   else
     return ( depth - 2 );
   end if;
 else
   if ( mem_mode = 0 ) then
     return ( depth - 2 );
   elsif ( (mem_mode = 3) OR (mem_mode = 5) OR (mem_mode = 7) ) then
     return ( depth - 4 );
   else
     return ( depth - 3 );
   end if;
 end if;
end calc_ram_depth;


constant lO0l0110         : INTEGER := 1+(mem_mode mod 2)+(mem_mode/2)-(mem_mode/4)-(mem_mode/6);
constant IIOlIO10           : INTEGER := calc_ram_depth(depth, mem_mode, arch_type);
constant l10Ol0I1      : INTEGER := bit_width(IIOlIO10);
constant lI0l111O           : INTEGER := bit_width(depth+1);
constant O100I1O1        : INTEGER := (rst_mode mod 2);
constant I11OI1Il       : INTEGER := (rst_mode / 2);


signal OOO1O0OI        : std_logic;
signal IOl01l1O       : std_logic;
signal OO0I1l00          : std_logic;
signal OOIO101I           : std_logic_vector(l10Ol0I1-1 downto 0);
signal OOl0O110           : std_logic_vector(width-1 downto 0);
signal Ol00Ol11           : std_logic_vector(width-1 downto 0);
signal ll0O10OI          : std_logic;
signal IOOOll11           : std_logic_vector(l10Ol0I1-1 downto 0);
signal II1O1O01           : std_logic;

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
  
    if ( (depth < 4) OR (depth > 1024) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter depth (legal range: 4 to 1024)"
        severity warning;
    end if;
  
    if ( (mem_mode < 0) OR (mem_mode > 7 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter mem_mode (legal range: 0 to 7 )"
        severity warning;
    end if;
  
    if ( (arch_type < 0) OR (arch_type > 4 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter arch_type (legal range: 0 to 4 )"
        severity warning;
    end if;
  
    if ( (af_from_top < 0) OR (af_from_top > 1 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter af_from_top (legal range: 0 to 1 )"
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
  
    if ( (rst_mode < 0) OR (rst_mode > 3 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter rst_mode (legal range: 0 to 3 )"
        severity warning;
    end if;
  
    if ( (arch_type=0 and mem_mode/=0) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid parameter combination: when arch_type is 0, mem_mode must be 0"
        severity warning;
    end if;
  
    if ( (arch_type>=3 and mem_mode=0) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid parameter combination: when arch_type is 3 or 4, mem_mode must be > 0"
        severity warning;
    end if;
  
    if ( (IIOlIO10<2) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid parameter combination of arch_type and mem_mode settings causes depth of RAM to be < 2"
        severity warning;
    end if;
  
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;


  OOO1O0OI  <= '1' when (I11OI1Il = 1) else rst_n;
  IOl01l1O <= (init_n AND rst_n) when (I11OI1Il = 1) else init_n;

  U_FIFOCTL : DW_lp_fifoctl_1c_df
    generic map (
      width => width,
      depth => depth,
      mem_mode => mem_mode,
      arch_type => arch_type,
      af_from_top => af_from_top,
      ram_re_ext => ram_re_ext,
      err_mode => err_mode)
    port map (
      clk => clk,
      rst_n => OOO1O0OI,
      init_n => IOl01l1O,
      ae_level => ae_level,
      af_level => af_level,
      level_change => level_change,
      push_n => push_n,
      data_in => data_in,
      pop_n => pop_n,
      rd_data => Ol00Ol11,
      ram_we_n => OO0I1l00,
      wr_addr => OOIO101I,
      wr_data => OOl0O110,
      ram_re_n => ll0O10OI,
      rd_addr => IOOOll11,
      data_out => data_out,
      word_cnt => word_cnt,
      empty => empty,
      almost_empty => almost_empty,
      half_full => half_full,
      almost_full => almost_full,
      full => full,
      error => error);


  U_RAM: DW_ram_r_w_2c_dff
    generic map (
      width      => width,
      depth      => IIOlIO10,
      addr_width => l10Ol0I1,
      mem_mode   => mem_mode,
      rst_mode   => O100I1O1)
    port map (
      clk_w      => clk,
      rst_w_n    => OOO1O0OI,
      init_w_n   => IOl01l1O,
      en_w_n     => OO0I1l00,
      addr_w     => OOIO101I,
      data_w     => OOl0O110,
      clk_r      => clk,
      rst_r_n    => OOO1O0OI,
      init_r_n   => IOl01l1O,
      en_r_n     => ll0O10OI,
      addr_r     => IOOOll11,
      data_r_a   => II1O1O01,
      data_r     => Ol00Ol11);



  
  clk_monitor  : process (clk) begin

    assert NOT (Is_X( clk ) AND (now > 0 ns)) 
      report "WARNING: Detected unknown value on the clock input port clk."
      severity warning;

  end process clk_monitor ;

-- pragma translate_on
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

library dw03, dw06;

configuration DW_lp_fifo_1c_df_cfg_sim of DW_lp_fifo_1c_df is
 for sim
  for U_FIFOCTL : DW_lp_fifoctl_1c_df use configuration dw03.DW_lp_fifoctl_1c_df_cfg_sim; end for;
  for U_RAM: DW_ram_r_w_2c_dff use configuration dw06.DW_ram_r_w_2c_dff_cfg_sim; end for;
 end for; -- sim
end DW_lp_fifo_1c_df_cfg_sim;
-- pragma translate_on

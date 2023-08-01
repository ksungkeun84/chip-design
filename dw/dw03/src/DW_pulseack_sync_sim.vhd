--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2005 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Bruce Dean                 July 9, 2005
--
-- VERSION:   VHDL simulation model for  DW_pulseack_sync
--
-- DesignWare_version: ec3b262f
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--
--           pulseack synchronizer 
--
-------------------------------------------------------------------------------
--      Parameters      Valid Values    Description
--      ==========      ============    ===========
--      reg_event         0 to 1        register output
--      reg_ack           0 to 1        register ack output
--      ack_delay         0 to 1        ack timing control
--      f_sync_type       0 to 4        number and type of flops s->d
--      r_sync_type       0 to 4        number and type of flops d-> s
--      tst_mode          0 to 2        test mode flop/latch insertion
--      verif_en          0 to 4        Missampling method control
--      pulse_mode        0 to 3        input trigger method
--
-------------------------------------------------------------------------------
library IEEE,DWARE;
use STD.textio.all;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_misc.all;
use DWARE.DW_foundation_comp_arith.all;
architecture sim of DW_pulseack_sync is
	
  signal tgl_d_evnt_x   : std_logic;
  signal event_d_w      : std_logic;
  signal busy_s_w       : std_logic;
  signal ack_s_w        : std_logic;
  signal data_d         : std_logic;
  signal dstdom_ack     : std_logic;
  signal busy_s_int     : std_logic;
  signal busy_state     : std_logic;
  signal nxt_busy_state : std_logic;
  signal tgl_dst_ack_r  : std_logic;
  signal tgl_dst_ack_x  : std_logic;
  signal tgl_d_sel_q    : std_logic;
  signal tgl_s_en_q     : std_logic;
  signal event_s_cap    : std_logic;
  signal tgl_d_evnt_q0  : std_logic_vector(0 downto 0);
  signal tgl_d_evnt_q1  : std_logic_vector(0 downto 0);
  signal tgl_d_evnt_l   : std_logic_vector(0 downto 0);
  signal tgl_d_evnt_d   : std_logic_vector(0 downto 0);
  signal tgl_d_evnt_cc  : std_logic_vector(0 downto 0);
  signal tgl_dst_ack_d  : std_logic_vector(0 downto 0);
  signal tgl_dst_ack_q  : std_logic_vector(0 downto 0);
  signal tgl_s_evnt_d   : std_logic_vector(0 downto 0);
  signal tgl_s_evnt_q   : std_logic_vector(0 downto 0);
  signal tgl_s_evnt_cc  : std_logic_vector(0 downto 0);
  signal tgl_s_event_l  : std_logic_vector(0 downto 0);
  signal event_d_ack    : std_logic_vector(0 downto 0);
  constant F_SYNC_TYPE_ADD8 : INTEGER := (f_sync_type + 8);

  constant F_SYNC_TYPE_INT : INTEGER := (f_sync_type mod 8);
  constant R_SYNC_TYPE_INT : INTEGER := (r_sync_type mod 8);
   -- component declarations
begin
-- pragma translate_off  
  
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
  
    if ( (reg_event < 0) OR (reg_event > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter reg_event (legal range: 0 to 1)"
        severity warning;
    end if;
  
    if ( (reg_ack < 0) OR (reg_ack > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter reg_ack (legal range: 0 to 1)"
        severity warning;
    end if;
  
    if ( (ack_delay < 0) OR (ack_delay > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter ack_delay (legal range: 0 to 1)"
        severity warning;
    end if;
  
    if ( (f_sync_type mod 8 < 0) OR (f_sync_type mod 8 > 4) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter f_sync_type mod 8 (legal range: 0 to 4)"
        severity warning;
    end if;
  
    if ( (r_sync_type mod 8 < 0) OR (r_sync_type mod 8 > 4) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter r_sync_type mod 8 (legal range: 0 to 4)"
        severity warning;
    end if;
  
    if ( (tst_mode < 0) OR (tst_mode > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter tst_mode (legal range: 0 to 1)"
        severity warning;
    end if;
  
    if ( (verif_en < 0) OR (verif_en > 4) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter verif_en (legal range: 0 to 4)"
        severity warning;
    end if;
  
    if ( (pulse_mode < 0) OR (pulse_mode > 3) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter pulse_mode (legal range: 0 to 3)"
        severity warning;
    end if;
  
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;

  process (clk_s, rst_s_n) begin
    if  (rst_s_n = '0')  then
      tgl_s_evnt_q(0)  <= '0';
      busy_state       <= '0';
      tgl_dst_ack_q(0) <= '0';
      event_s_cap      <= '0';
    elsif  (rst_s_n = '1')  then
      if ( clk_s = '1' and clk_s'event )  then
        if ( init_s_n = '0')  then
          tgl_s_evnt_q(0)  <= '0';
          busy_state       <= '0';
          tgl_dst_ack_q(0) <= '0';
          event_s_cap      <= '0';
        elsif ( init_s_n = '1')  then
          tgl_s_evnt_q(0) <= tgl_s_evnt_d(0);
          event_s_cap     <= event_s;
          busy_state      <= nxt_busy_state;
          tgl_dst_ack_q   <= tgl_dst_ack_d;
	  tgl_dst_ack_r   <= tgl_dst_ack_x;
        else
          tgl_s_evnt_q(0)  <= 'X';
          busy_state       <= 'X';
          tgl_dst_ack_q(0) <= 'X';
          event_s_cap      <= 'X';
        end if;
      end if;
    else
      tgl_s_evnt_q(0)  <= 'X';
      busy_state       <= 'X';
      tgl_dst_ack_q(0) <= 'X';
      event_s_cap      <= 'X';
    end if;
  end process;
  
  process (clk_d, rst_d_n) begin
    if (rst_d_n = '0' ) then
      tgl_d_sel_q   <= '0';
      tgl_d_evnt_q1 <= "0";
    elsif (rst_d_n = '1' ) then
      if (clk_d'event and clk_d = '1' ) then
        if (init_d_n = '0' ) then
          tgl_d_sel_q   <= '0';
          tgl_d_evnt_q1 <= "0";
        elsif (init_d_n = '1' ) then
          tgl_d_sel_q      <= tgl_d_evnt_d(0);
          tgl_d_evnt_q1(0) <= tgl_d_evnt_x;
        else
          tgl_d_sel_q   <= 'X';
          tgl_d_evnt_q1 <= "X";
        end if;
      end if;
    else
      tgl_d_sel_q   <= 'X';
      tgl_d_evnt_q1 <= "X";
    end if;
  end process;
  

  frwd_hold_latch_PROC : process(clk_s, tgl_s_evnt_q) begin
    if (clk_s = '0') then
      tgl_s_event_l <= tgl_s_evnt_q;
    end if;
  end process frwd_hold_latch_PROC;

  tgl_s_evnt_cc <= tgl_s_event_l when (((f_sync_type mod 8) > 1) AND (tst_mode = 2) AND (test = '1')) else tgl_s_evnt_q;

  U_DW_SYNC_F : DW_sync
    generic map (
	width => 1,
	f_sync_type => f_sync_type+8,
	tst_mode => tst_mode,
	verif_en => verif_en )
    port map (
	clk_d => clk_d,
	rst_d_n => rst_d_n,
	init_d_n => init_d_n,
	data_s => tgl_s_evnt_cc,
	test => test,
	data_d => tgl_d_evnt_d );

  rvs_hold_latch_PROC : process(clk_d, tgl_d_evnt_q0) begin
    if (clk_d = '0') then
      tgl_d_evnt_l <= tgl_d_evnt_q0;
    end if;
  end process rvs_hold_latch_PROC;

  tgl_d_evnt_cc <= tgl_d_evnt_l when (((r_sync_type mod 8) > 1) AND (tst_mode = 2) AND (test = '1')) else tgl_d_evnt_q0;

  U_DW_SYNC_R : DW_sync
    generic map (
	width => 1,
	f_sync_type => r_sync_type+8,
	tst_mode => tst_mode,
	verif_en => verif_en )
    port map (
	clk_d => clk_s,
	rst_d_n => rst_s_n,
	init_d_n => init_s_n,
	data_s => tgl_d_evnt_cc,
	test => test,
	data_d => tgl_dst_ack_d );		
  
  tgl_s_evnt_d(0) <= tgl_s_evnt_q(0)  xor (event_s and not busy_state)
    when (pulse_mode = 0 ) else tgl_s_evnt_q(0) xor (event_s and (not busy_state) and (not event_s_cap))
    when (pulse_mode = 1 ) else tgl_s_evnt_q(0) xor (event_s_cap and (not busy_state) and (not event_s))
    when (pulse_mode = 2 ) else tgl_s_evnt_q(0) xor ((event_s xor event_s_cap) and not busy_state)
    when (pulse_mode = 3 ) ; 
  tgl_d_evnt_x     <= tgl_d_evnt_d(0)  xor tgl_d_sel_q; 
  tgl_dst_ack_x    <= ((tgl_dst_ack_q(0) xor tgl_dst_ack_d(0)));
  nxt_busy_state   <= tgl_dst_ack_d(0) xor tgl_s_evnt_d(0);
  event_d_w        <= tgl_d_evnt_q1(0) when (reg_event = 1) else tgl_d_evnt_x;
  ack_s_w          <= tgl_dst_ack_r    when (reg_ack = 1)   else tgl_dst_ack_x;
  tgl_d_evnt_q0(0) <= tgl_d_sel_q when ack_delay = 1 else tgl_d_evnt_d(0);
  busy_s           <= busy_state;
  ack_s            <= ack_s_w;
  event_d          <= event_d_w;
  
  monitor_clk_s  : process (clk_s) begin

    assert NOT (Is_X( clk_s ) AND (now > 0 ns)) 
      report "WARNING: Detected unknown value on the clock input port clk_s."
      severity warning;

  end process monitor_clk_s ;  
  
  monitor_clk_d  : process (clk_d) begin

    assert NOT (Is_X( clk_d ) AND (now > 0 ns)) 
      report "WARNING: Detected unknown value on the clock input port clk_d."
      severity warning;

  end process monitor_clk_d ;


    -- Message printed to standard output identifyng method of use when f_sync_type is greater than 0 and less than 8
    method_msg : process
      variable buf : line;
      constant preamble_str : STRING := "Information: *** Instance ";
      constant method_str : STRING := " is the DW_pulseack_sync Clock Domain Crossing Module ***";

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
configuration DW_pulseack_sync_cfg_sim of DW_pulseack_sync is
 for sim
    for U_DW_SYNC_F : DW_sync use configuration dw03.DW_sync_cfg_sim; end for;
    for U_DW_SYNC_R : DW_sync use configuration dw03.DW_sync_cfg_sim; end for;
 end for; -- sim
end DW_pulseack_sync_cfg_sim;

library dw03;
configuration DW_pulseack_sync_cfg_sim_ms of DW_pulseack_sync is
 for sim
    for U_DW_SYNC_F : DW_sync use configuration dw03.DW_sync_cfg_sim_ms; end for;
    for U_DW_SYNC_R : DW_sync use configuration dw03.DW_sync_cfg_sim_ms; end for;
 end for; -- sim
end DW_pulseack_sync_cfg_sim_ms;
-- pragma translate_on

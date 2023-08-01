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
-- AUTHOR:    Bruce Dean                 July 9, 2004
--
-- VERSION:   VHDL simulation model for  DW_pulse_sync
--
-- DesignWare_version: abfe66e0
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
--
--
-------------------------------------------------------------------------------
--      Parameters      Valid Values    Description
--      ==========      ============    ===========
--      reg_event         0/1           register outputs
--      f_sync_type       0-4           number and type of flops
--      tst_mode          0-2           test mode flop/latch insertion
--      verif_en          0-4           num/type of sampling errors for sim
--      pulse_mode        0-3           single clock cycle pulse in produces
--
--
-- MODIFIED: 
--              DLL   9-21-11  Added tst_mode=2 checking (not a functional change)
--
-------------------------------------------------------------------------------
library IEEE, DWARE;
use STD.textio.all;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_misc.all;
use DWARE.DWpackages.all;
use DWARE.DW_foundation_comp_arith.all;

architecture sim of DW_pulse_sync is
	
  signal event_d_out : std_logic_vector(1 downto 0);
  signal event_d_upd : std_logic;
  signal data_d      : std_logic;
  signal dstdom_d       : std_logic_vector(0 downto 0);
  signal tgl_event_s    : std_logic_vector(0 downto 0);
  signal event_s_reg    : std_logic_vector(0 downto 0);
  signal event_s_in     : std_logic_vector(0 downto 0);
  signal tgl_event_l    : std_logic_vector(0 downto 0);
  signal tgl_event_cc   : std_logic_vector(0 downto 0);
  constant F_SYNC_TYPE_ADD8 : INTEGER := (f_sync_type + 8);
  constant F_SYNC_TYPE_INT : INTEGER := (f_sync_type mod 8);

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
  
    if ( (F_SYNC_TYPE_INT < 0) OR (F_SYNC_TYPE_INT > 4) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter F_SYNC_TYPE_INT (legal range: 0 to 4)"
        severity warning;
    end if;
  
    if ( (tst_mode < 0) OR (tst_mode > 2) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter tst_mode (legal range: 0 to 2)"
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

event_s_in(0) <= event_s xor tgl_event_s(0) when (pulse_mode = 0) else 
                 ((event_s and not event_s_reg(0)) xor tgl_event_s(0)) when pulse_mode = 1 else
		 ((not event_s and event_s_reg(0)) xor tgl_event_s(0)) when pulse_mode = 2 else
		 (event_s xor event_s_reg(0)) xor tgl_event_s(0) when pulse_mode =3;

  process (clk_s, rst_s_n) begin
    if  (rst_s_n = '0')  then
      tgl_event_s(0) <= '0';
      event_s_reg(0) <= '0';
    elsif  (rst_s_n = '1')  then
      if ( clk_s = '1' and clk_s'event )  then
        if ( init_s_n = '0')  then
          tgl_event_s(0) <= '0';
          event_s_reg(0) <= '0';
        elsif ( init_s_n = '1')  then
          tgl_event_s(0) <= event_s_in(0);
          event_s_reg(0) <= event_s;
        else
          tgl_event_s(0) <= 'X';
          event_s_reg(0) <= 'X';
        end if;
      end if;
    else
      tgl_event_s(0) <= 'X';
      event_s_reg(0) <= 'X';   
    end if;
  end process;

  data_d           <= dstdom_d(0);


  frwd_hold_latch_PROC : process(clk_s, tgl_event_s) begin
    if (clk_s = '0') then
      tgl_event_l <= tgl_event_s;
    end if;
  end process frwd_hold_latch_PROC;

  tgl_event_cc <= tgl_event_l when (((f_sync_type mod 8) > 1) AND (tst_mode = 2) AND (test = '1')) else tgl_event_s;

  U_SYNC : DW_sync
    generic map (
	width => 1,
	f_sync_type => f_sync_type+8,
	tst_mode => tst_mode,
	verif_en => verif_en )
    port map (
	clk_d => clk_d,
	rst_d_n => rst_d_n,
	init_d_n => init_d_n,
	data_s => tgl_event_cc,
	test => test,
	data_d => dstdom_d );

  process (clk_d, rst_d_n) begin
    if (rst_d_n = '0' ) then
      event_d_out <= "00";
    elsif (rst_d_n = '1' ) then
      if (clk_d'event and clk_d = '1' ) then
        if (init_d_n = '0' ) then
          event_d_out <= "00";
        elsif (init_d_n = '1' ) then
          event_d_out <= event_d_upd & data_d;
        else
          event_d_out <= "XX";
        end if;
      end if;
    else
      event_d_out <= "XX";
    end if;
  end process;
  
  event_d     <= event_d_out(1) when (reg_event = 1) else event_d_upd;
  event_d_upd <= not event_d_out(0) when (data_d = '1') else event_d_out(0);

 
  monitor_clk_d  : process (clk_d) begin

    assert NOT (Is_X( clk_d ) AND (now > 0 ns)) 
      report "WARNING: Detected unknown value on the clock input port clk_d."
      severity warning;

  end process monitor_clk_d ;
 
  monitor_clk_s  : process (clk_s) begin

    assert NOT (Is_X( clk_s ) AND (now > 0 ns)) 
      report "WARNING: Detected unknown value on the clock input port clk_s."
      severity warning;

  end process monitor_clk_s ;


    -- Message printed to standard output identifyng method of use when f_sync_type is greater than 0 and less than 8
    method_msg : process
      variable buf : line;
      constant preamble_str : STRING := "Information: *** Instance ";
      constant method_str : STRING := " is the DW_pulse_sync Clock Domain Crossing Module ***";

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
configuration DW_pulse_sync_cfg_sim_ms of DW_pulse_sync is
 for sim
  for U_SYNC: DW_sync use configuration dw03.DW_sync_cfg_sim_ms; end for;
 end for; -- sim
end DW_pulse_sync_cfg_sim_ms;

library dw03;
configuration DW_pulse_sync_cfg_sim of DW_pulse_sync is
 for sim
    for U_SYNC : DW_sync use configuration dw03.DW_sync_cfg_sim; end for;
 end for; -- sim
end DW_pulse_sync_cfg_sim;
-- pragma translate_on

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
-- AUTHOR:    Doug Lee    May 16, 2005
--
-- VERSION:   VHDL Simulation Model
--
-- DesignWare_version: ff69e824
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT: Data Bus Synchronizer without acknowledge Simulation Model
--
--
--           This synchronizer passes data values from the source domain to the destination domain.
--           Full feedback hand-shake is NOT used. So there is no busy or done status on in the source domain.
--
--              Parameters:     Valid Values
--              ==========      ============
--              width           [ default : 8
--                                1 to 1024 : width of data_s and data_d ports ]
--              f_sync_type     [ default : 2
--                                0 = single clock design, no synchronizing stages implemented,
--                                1 = 2-stage synchronization w/ 1st stage neg-edge & 2nd stage pos-edge capturing,
--                                2 = 2-stage synchronization w/ both stages pos-edge capturing,
--                                3 = 3-stage synchronization w/ all stages pos-edge capturing,
--                                4 = 4-stage synchronization w/ all stages pos-edge capturing ]
--              tst_mode        [ default : 0
--                                0 = no hold latch inserted,
--                                1 = insert hold 'latch' using a neg-edge triggered register ]
--              verif_en        [ default : 1
--                                0 = no sampling errors inserted,
--                                1 = sampling errors are randomly inserted with 0 or up to 1 destination clock cycle delays
--                                2 = sampling errors are randomly inserted with 0, 0.5, 1 or 1.5 destination clock cycle delays
--                                3 = sampling errors are randomly inserted with 0, 1, 2, or 3 destination clock cycle delays
--                                4 = sampling errors are randomly inserted with 0 or up to 0.5 destination clock cycle delays ]
--              send_mode       [ default : 0 (send_s detection control)
--                                0 = every clock cycle of send_s asserted invokes
--                                    a data transfer to destination domain
--                                1 = rising edge transition of send_s invokes
--                                    a data transfer to destination domain
--                                2 = falling edge transition of send_s invokes
--                                    a data transfer to destination domain
--                                3 = every toggle transition of send_s invokes
--                                    a data transfer to destination domain ]
--
--
--              Input Ports:    Size     Description
--              ===========     ====     ===========
--              clk_s           1 bit    Source Domain Input Clock
--              rst_s_n         1 bit    Source Domain Active Low Async. Reset
--              init_s_n        1 bit    Source Domain Active Low Sync. Reset
--              send_s          1 bit    Source Domain Active High Send Request
--              data_s          N bits   Source Domain Data Input
--              clk_d           1 bit    Destination Domain Input Clock
--              rst_d_n         1 bit    Destination Domain Active Low Async. Reset
--              init_d_n        1 bit    Destination Domain Active Low Sync. Reset
--              test            1 bit    Test input
--
--              Output Ports    Size     Description
--              ============    ====     ===========
--              data_avail_d    1 bit    Destination Domain Data Available Output
--              data_d          N bits   Destination Domain Data Output
--
--                Note: (1) The value of N is equal to the 'width' parameter value
--
--
--
-- MODIFIED:
--
--              DLL  6/8/06   Added send_mode parameter and functionality
--
--              DLL  6/12/06  Cleaned up excessive use of 'To_X01' on input signals
--
--              DLL  11/15/06 Added 4-stage synchronization capability
--
--              DLL  11/21/06 Changed library reference in configuration block
--
--------------------------------------------------------------------------
 
library IEEE, DWARE;
use STD.textio.all;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_misc.all;
use DWARE.DWpackages.all;
use DWARE.DW_foundation_comp_arith.all;

architecture sim of DW_data_sync_na is
	
  signal send_s_int_reg : std_logic;
  signal send_s_sel     : std_logic;

  signal data_s_hold       : std_logic_vector(width-1 downto 0);
  signal data_s_hold_d1    : std_logic_vector(width-1 downto 0);

  signal DW_pulse_sync_event_d    : std_logic;

  constant F_SYNC_TYPE_ADD8 : INTEGER := (f_sync_type + 8);

  constant F_SYNC_TYPE_INT : INTEGER := (f_sync_type mod 8);


  begin
  -- pragma translate_off
    
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
     
    if (width < 1) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter width (lower bound: 1)"
        severity warning;
    end if;
     
    if ( (F_SYNC_TYPE_INT < 0) OR (F_SYNC_TYPE_INT > 4) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter F_SYNC_TYPE_INT (legal range: 0 to 4)"
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
     
    if ( (send_mode < 0) OR (send_mode > 3) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter send_mode (legal range: 0 to 3)"
        severity warning;
    end if;
    
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;


  U1: DW_pulse_sync
    generic map (
      reg_event   => 0,
      f_sync_type => F_SYNC_TYPE_ADD8, 
      tst_mode    => tst_mode,
      verif_en    => verif_en,
      pulse_mode  => send_mode)
    port map (
      clk_s       => clk_s,
      rst_s_n     => rst_s_n,  
      init_s_n    => init_s_n,  
      event_s     => send_s,
      clk_d       => clk_d,
      rst_d_n     => rst_d_n,  
      init_d_n    => init_d_n,  
      test        => test,  
      event_d     => DW_pulse_sync_event_d);  

    send_s_sel  <= (To_X01(send_s)) when (send_mode = 0) else
		     (send_s AND NOT(send_s_int_reg)) when (send_mode = 1) else
		       (NOT(send_s) AND send_s_int_reg) when (send_mode = 2) else
		 	 (send_s XOR send_s_int_reg);


    data_sync_na_sim_clk_s: process (clk_s, rst_s_n)

      variable data_s_hold_int          : std_logic_vector(width-1 downto 0);
      variable next_data_s_hold_int     : std_logic_vector(width-1 downto 0);

      begin

        if (send_s_sel = '1') then
	  next_data_s_hold_int := (To_X01(data_s));
	elsif (send_s_sel = '0') then
	  next_data_s_hold_int := data_s_hold_int;
        else
	  next_data_s_hold_int := (others => 'X');
	end if;

        -- Positive edge ffs
        if (rst_s_n = '0') then
	  send_s_int_reg         <= '0';
          data_s_hold_int        := (others => '0');
        elsif (rst_s_n = '1') then
	  if (rising_edge(clk_s)) then
	    if (init_s_n = '0') then
	      send_s_int_reg         <= '0';
              data_s_hold_int        := (others => '0');
	    elsif (init_s_n = '1') then
	      send_s_int_reg         <= (To_X01(send_s));
              data_s_hold_int        := next_data_s_hold_int;
            else
	      send_s_int_reg         <= 'X';
              data_s_hold_int        := (others => 'X');
	    end if;
          else
	    send_s_int_reg         <= send_s_int_reg;
            data_s_hold_int        := data_s_hold_int;
	  end if;
	else
	  send_s_int_reg         <= 'X';
          data_s_hold_int        := (others => 'X');
	end if;

	-- Generate data_s_hold
	data_s_hold  <= data_s_hold_int;

    end process;

    data_sync_na_sim_clk_d: process (clk_d, rst_d_n)
      variable data_d_int          : std_logic_vector(width-1 downto 0);
      variable next_data_d_int     : std_logic_vector(width-1 downto 0);
      variable data_avail_d_int    : std_logic;
      variable data_s_hold_d1_int  : std_logic_vector(width-1 downto 0);

      begin

	if (DW_pulse_sync_event_d = '1') then
	  next_data_d_int := data_s_hold;
	else
	  next_data_d_int := data_d_int;
	end if;

        -- Positive edge ffs
        if (rst_d_n = '0') then
          data_d_int          := (others => '0');
          data_avail_d_int    := '0';
	  data_s_hold_d1_int  := (others => '0');
        elsif (rst_d_n = '1') then
	  if (rising_edge(clk_d)) then
	    if (init_d_n = '0') then
              data_d_int          := (others => '0');
              data_avail_d_int    := '0';
	      data_s_hold_d1_int  := (others => '0');
	    elsif (init_d_n = '1') then
              data_d_int          := next_data_d_int;
              data_avail_d_int    := DW_pulse_sync_event_d;
	      data_s_hold_d1_int  := data_s_hold;
            else
              data_d_int          := (others => 'X');
              data_avail_d_int    := 'X';
	      data_s_hold_d1_int  := (others => 'X');
	    end if;
          else
            data_d_int          := data_d_int;
            data_avail_d_int    := data_avail_d_int;
	    data_s_hold_d1_int  := data_s_hold_d1_int;
	  end if;
	else
          data_d_int          := (others => 'X');
          data_avail_d_int    := 'X';
	  data_s_hold_d1_int  := (others => 'X');
	end if;


	-- Assign to signals
	data_d         <= data_d_int;
	data_avail_d   <= data_avail_d_int;
	data_s_hold_d1 <= data_s_hold_d1_int;

    end process;

    
  monitor_clk_d  : process (clk_d) begin

    assert NOT (Is_X( clk_d ) AND (now > 0 ns)) 
      report "WARNING: Detected unknown value on the clock input port clk_d."
      severity warning;

  end process monitor_clk_d ;


    -- Message printed to standard output identifyng data_d register input setup time violation
    setup_time_violation_msg : process (data_s_hold, data_s_hold_d1, DW_pulse_sync_event_d, rst_s_n, init_s_n, rst_d_n, init_d_n)
    begin
      assert ((f_sync_type = 0) OR (data_s_hold = data_s_hold_d1) OR (DW_pulse_sync_event_d = '0') OR
	      (init_s_n = '0') OR (rst_s_n = '0') OR (init_d_n = '0') OR (rst_d_n = '0'))
	report "#### 'data_d' output register setup-time violation.  Captured data_s changes within one clk_d cycle before rising-edge. ####"
	severity WARNING;

    end process setup_time_violation_msg;


    -- Message printed to standard output identifyng method of use when f_sync_type is greater than 0 and less than 8
    method_msg : process
      variable buf : line;
      constant preamble_str : STRING := "Information: *** Instance ";
      constant method_str : STRING := " is the DW_data_sync_na Clock Domain Crossing Module ***";

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
configuration DW_data_sync_na_cfg_sim_ms of DW_data_sync_na is
 for sim
  for U1: DW_pulse_sync use configuration dw03.DW_pulse_sync_cfg_sim_ms; end for;
 end for; -- sim
end DW_data_sync_na_cfg_sim_ms;

library dw03;
configuration DW_data_sync_na_cfg_sim of DW_data_sync_na is
 for sim
  for U1: DW_pulse_sync use configuration dw03.DW_pulse_sync_cfg_sim; end for;
 end for; -- sim
end DW_data_sync_na_cfg_sim;
-- pragma translate_on

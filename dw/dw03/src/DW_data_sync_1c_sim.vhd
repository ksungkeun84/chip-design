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
-- DesignWare_version: 1de1d964
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT: Single Clock Data Bus Synchronizer Simulation Model
--
--           This synchronizes incoming data into the destination domain
--           with a configurable number of sampling stages and consecutive
--           samples of stable data values.  This model contains two configurations;
--           one for 'missampling' functionality and one without 'missampling'.
--           
--           The 'missampling' functionality configuration is bound to the
--           'sim_ms' architecture of the DW_sync component.
--
--              Parameters:     Valid Values
--              ==========      ============
--              width           [ 1 to 1024 ]
--              f_sync_type     [ 0 = single clock design, no synchronizing stages implemented,
--                                1 = 2-stage synchronization w/ 1st stage neg-edge & 2nd stage pos-edge capturing,
--                                2 = 2-stage synchronization w/ both stages pos-edge capturing,
--                                3 = 3-stage synchronization w/ all stages pos-edge capturing,
--                                4 = 4-stage synchronization w/ all stages pos-edge capturing ]
--              filt_size       [ 1 to 8 : width of filt_d input port ]
--              tst_mode        [ 0 = no hold latch inserted,
--                                1 = insert hold 'latch' using a neg-edge triggered register ]
--              verif_en        [ 0 = no sampling errors inserted,
--                                1 = sampling errors are randomly inserted with 0 or up to 1 destination clock cycle delays
--                                2 = sampling errors are randomly inserted with 0, 0.5, 1 or 1.5 destination clock cycle delays
--                                3 = sampling errors are randomly inserted with 0, 1, 2, or 3 destination clock cycle delays
--                                4 = sampling errors are randomly inserted with 0 or up to 0.5 destination clock cycle delays ]
--
--              Input Ports:    Size     Description
--              ===========     ====     ===========
--              clk_d           1 bit    Destination Domain Input Clock
--              rst_d_n         1 bit    Destination Domain Active Low Async. Reset
--              init_d_n        1 bit    Destination Domain Active Low Sync. Reset
--              data_s          N bits   Source Domain Data Input
--              filt_d          M bits   Destination Domain filter defining the number of clk_d cycles required to declare stable data
--              test            N bits   Test input
--
--              Output Ports    Size     Description
--              ============    ====     ===========
--              data_avail_d    1 bit    Destination Domain Data Available Output
--              data_d          N bits   Destination Domain Data Output
--              max_skew_d      M+1 bits Destination Domain maximum skew detected between bits for any data_s bus transition
--
--                Note: (1) The value of M is equal to the 'filt_size' parameter value
--                      (2) The value of N is equal to the 'width' parameter value
--
--
-- MODIFIED:
--              DLL  6/14/06  Cleaned up excessive use of 'To_X01' on input signals
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

architecture sim of DW_data_sync_1c is
	
  signal data_avail_d_int  : std_logic;
  signal data_d_int        : std_logic_vector(width-1 downto 0);
  signal max_skew_d_in     : std_logic_vector(filt_size downto 0);

  signal DW_sync_data_d    : std_logic_vector(width-1 downto 0);

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
     
    if ( (filt_size < 1) OR (filt_size > 8) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter filt_size (legal range: 1 to 8)"
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
    
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;

  U1: DW_sync
    generic map (
      width       => width,
      f_sync_type => F_SYNC_TYPE_ADD8, 
      tst_mode    => tst_mode,
      verif_en    => verif_en)
    port map (
      clk_d       => clk_d,
      rst_d_n     => rst_d_n,  
      init_d_n    => init_d_n,  
      data_s      => data_s,
      test        => test,  
      data_d      => DW_sync_data_d);  

    data_sync_1c_sim_mdl: process (clk_d, rst_d_n)
      variable data_d_int             : std_logic_vector(width-1 downto 0);
      variable data_avail_d_int       : std_logic;
      variable max_skew_d_int         : std_logic_vector(filt_size downto 0);
      variable next_data_d_int        : std_logic_vector(width-1 downto 0);
      variable next_data_avail_d_int  : std_logic;
      variable next_max_skew_d_int    : std_logic_vector(filt_size downto 0);


      variable next_counting_state    : std_logic;
      variable counting_state         : std_logic;
      variable diff                   : std_logic;
      variable sync_data_d_last       : std_logic_vector(width-1 downto 0);
      variable next_data_counter      : std_logic_vector(filt_size-1 downto 0);
      variable data_counter           : std_logic_vector(filt_size-1 downto 0);
      variable next_skew_counter      : std_logic_vector(filt_size downto 0);
      variable skew_counter           : std_logic_vector(filt_size downto 0);
      variable greater_skew           : std_logic;

      constant bit_x_value            : std_logic := 'X';
    
      begin

        if (DW_sync_data_d /= sync_data_d_last) then
	  diff := '1';
        else
	  diff := '0';
	end if;
                      
        if (diff = '1') then
	  next_counting_state := '1';
        elsif ( ((diff = '0') and (counting_state = '1') and (data_counter = filt_d)) or
		((counting_state = '1') and (UNSIGNED(filt_d) = 0)) or
		(data_counter > filt_d) ) then
          next_counting_state := '0';
        else
	  next_counting_state := counting_state;
	end if;

	if ( (data_counter > filt_d) or ((counting_state = '1') and (data_counter = filt_d) and (diff = '0')) ) then
          next_data_counter := (others => '0');
	elsif (diff = '1') then
	  next_data_counter(0) := '1';
	  next_data_counter(filt_size-1 downto 1) := (others => '0');
        elsif (counting_state = '1') then
	  next_data_counter := UNSIGNED(data_counter) + 1;
        else
	  next_data_counter := (others => '0');
	end if;

	if ( ((counting_state = '0') and (diff = '0')) or
	     (next_counting_state = '0') or (data_counter > filt_d) ) then
	  next_skew_counter := (others => '0');
        else
	  next_skew_counter := UNSIGNED(skew_counter) + 1;
	end if;

        if (skew_counter > max_skew_d_int) then
	  greater_skew := '1';
	else
	  greater_skew := '0';
	end if;

	if (F_SYNC_TYPE_INT = 0) then
	  next_max_skew_d_int := (others => '0');
        elsif ((counting_state = '1') and (diff = '1') and (greater_skew = '1')) then
	  next_max_skew_d_int := skew_counter;
	else
	  next_max_skew_d_int := max_skew_d_int;
	end if;

	if (XOR_REDUCE(filt_d) = 'X') then
	  next_data_d_int := (others => 'X');
	elsif ( (UNSIGNED(filt_d) = 0) or ((counting_state = '1') and (diff = '0') and (data_counter = filt_d)) ) then
	  next_data_d_int := DW_sync_data_d;
	else
	  next_data_d_int := data_d_int;
	end if;

        if (XOR_REDUCE(filt_d) = 'X') then
	  next_data_avail_d_int := 'X';
	elsif (UNSIGNED(filt_d) = 0) then
	  next_data_avail_d_int := diff;
	elsif ( (counting_state = '1') and (diff = '0') and (data_counter = filt_d) ) then
	  next_data_avail_d_int := '1';
        else
	  next_data_avail_d_int := '0';
	end if;
                      
        -- Positive edge ffs
        if (rst_d_n = '0') then
	  sync_data_d_last  := (others => '0');
	  counting_state    := '0';
          data_d_int        := (others => '0');
          data_avail_d_int  := '0';
          max_skew_d_int    := (others => '0');
          data_counter      := (others => '0');
          skew_counter      := (others => '0');
        elsif (rst_d_n = '1') then
	  if (rising_edge(clk_d)) then
	    if (init_d_n = '0') then
	      sync_data_d_last  := (others => '0');
	      counting_state    := '0';
              data_d_int        := (others => '0');
              data_avail_d_int  := '0';
              max_skew_d_int    := (others => '0');
              data_counter      := (others => '0');
              skew_counter      := (others => '0');
	    elsif (init_d_n = '1') then
	      sync_data_d_last  := DW_sync_data_d;
	      counting_state    := next_counting_state;
              data_d_int        := next_data_d_int;
              data_avail_d_int  := next_data_avail_d_int;
              max_skew_d_int    := next_max_skew_d_int;
              data_counter      := next_data_counter;
              skew_counter      := next_skew_counter;
            else
	      sync_data_d_last  := (others => 'X');
	      counting_state    := 'X';
              data_d_int        := (others => 'X');
              data_avail_d_int  := 'X';
              max_skew_d_int    := (others => 'X');
              data_counter      := (others => 'X');
              skew_counter      := (others => 'X');
	    end if;
          else
	    sync_data_d_last  := sync_data_d_last;
	    counting_state    := counting_state;
            data_d_int        := data_d_int;
            data_avail_d_int  := data_avail_d_int;
            max_skew_d_int    := max_skew_d_int;
            data_counter      := data_counter;
            skew_counter      := skew_counter;
	  end if;
	else
	  sync_data_d_last  := (others => 'X');
	  counting_state    := 'X';
          data_d_int        := (others => 'X');
          data_avail_d_int  := 'X';
          max_skew_d_int    := (others => 'X');
          data_counter      := (others => 'X');
          skew_counter      := (others => 'X');
	end if;


	-- Generate different versions of data_d
	data_d        <= data_d_int;
	data_avail_d  <= data_avail_d_int;
        max_skew_d    <= max_skew_d_int;

    end process;

    
  monitor_clk_d  : process (clk_d) begin

    assert NOT (Is_X( clk_d ) AND (now > 0 ns)) 
      report "WARNING: Detected unknown value on the clock input port clk_d."
      severity warning;

  end process monitor_clk_d ;


    -- Message printed to standard output identifyng method of use when f_sync_type is greater than 0 and less than 8
    method_msg : process
      variable buf : line;
      constant preamble_str : STRING := "Information: *** Instance ";
      constant method_str : STRING := " is the DW_data_sync_1c Clock Domain Crossing Module ***";

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
configuration DW_data_sync_1c_cfg_sim_ms of DW_data_sync_1c is
 for sim
  for U1: DW_sync use configuration dw03.DW_sync_cfg_sim_ms; end for;
 end for; -- sim
end DW_data_sync_1c_cfg_sim_ms;

library dw03;
configuration DW_data_sync_1c_cfg_sim of DW_data_sync_1c is
 for sim
  for U1: DW_sync use configuration dw03.DW_sync_cfg_sim; end for;
 end for; -- sim
end DW_data_sync_1c_cfg_sim;
-- pragma translate_on

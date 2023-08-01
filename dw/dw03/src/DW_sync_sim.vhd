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
-- AUTHOR:    Doug Lee    Mar. 17, 2005
--
-- VERSION:   VHDL Simulation Model
--
-- DesignWare_version: 29e4ef49
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT: Fundamental Synchronizer Simulation Model
--
--           This synchronizes incoming data into the destination domain
--           with a configurable number of sampling stages.
--
--              Parameters:     Valid Values
--              ==========      ============
--              width           [ 1 to 1024 ]
--              f_sync_type     [ 0 = single clock design, no synchronizing stages implemented,
--                                1 = 2-stage synchronization w/ 1st stage neg-edge & 2nd stage pos-edge capturing,
--                                2 = 2-stage synchronization w/ both stages pos-edge capturing,
--                                3 = 3-stage synchronization w/ all stages pos-edge capturing
--                                4 = 4-stage synchronization w/ all stages pos-edge capturing ]
--              tst_mode        [ 0 = no hold latch inserted,
--                                1 = insert hold 'latch' using a neg-edge triggered register
--                                2 = reserved (functions same as tst_mode=0 ]
--              verif_en        [ 0 = no sampling errors modeled
--                                1 = sampling errors are randomly inserted with 0 or up to 1 destination clock cycle delays
--                                2 = sampling errors are randomly inserted with 0, 0.5, 1, or 1.5 destination clock cycle delays
--                                3 = sampling errors are randomly inserted with 0, 1, 2, or 3 destination clock cycle delays
--                                4 = sampling errors are randomly inserted with 0 or up to 0.5 destination clock cycle delays ]
--
--              Input Ports:    Size    Description
--              ===========     ====    ===========
--              clk_d           1 bit   Destination Domain Input Clock
--              rst_d_n         1 bit   Destination Domain Active Low Async. Reset
--              init_d_n        1 bit   Destination Domain Active Low Sync. Reset
--              data_s          N bits  Source Domain Data Input
--              test            1 bit   Test input
--
--              Output Ports    Size    Description
--              ============    ====    ===========
--              data_d          N bits  Destination Domain Data Output
--
--                Note: the value of N is equal to the 'width' parameter value
--
--
-- MODIFIED:
--              DLL   8-8-11   Added tst_mode=2 (not a functional change)
--
--              DLL   6-12-06  Removed unnecessary To_X01 processing of many input signals
--
--              DLL   11-7-06  Modified functionality to support f_sync_type = 4
--
--------------------------------------------------------------------------
 
library IEEE, DWARE;
use STD.textio.all;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;

architecture sim of DW_sync is
	
-- pragma translate_off
  signal test_hold_int : std_logic_vector(width-1 downto 0);
  signal data2_out_int : std_logic_vector(width-1 downto 0);
  signal data3_out_int : std_logic_vector(width-1 downto 0);
  signal data4_out_int : std_logic_vector(width-1 downto 0);

  constant F_SYNC_TYPE_INT : INTEGER := (f_sync_type mod 8);
-- pragma translate_on

  begin
  -- pragma translate_off

  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
  
    if (width < 1 ) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter width (lower bound: 1 )"
        severity warning;
    end if;
  
    if ( (F_SYNC_TYPE_INT < 0) OR (F_SYNC_TYPE_INT > 4) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter F_SYNC_TYPE_INT (legal range: 0 to 4)"
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


    sync_sim_mdl: process (clk_d, rst_d_n)
      variable ndata1_int         : std_logic_vector(width-1 downto 0);
      variable data1_int          : std_logic_vector(width-1 downto 0);
      variable data2_int          : std_logic_vector(width-1 downto 0);
      variable data3_int          : std_logic_vector(width-1 downto 0);
      variable data4_int          : std_logic_vector(width-1 downto 0);
      variable test_ndata1_int    : std_logic_vector(width-1 downto 0);
      variable next_data1_int     : std_logic_vector(width-1 downto 0);
      variable next_data2_int     : std_logic_vector(width-1 downto 0);
      variable next_data3_int     : std_logic_vector(width-1 downto 0);
      variable next_data4_int     : std_logic_vector(width-1 downto 0);
    
      begin
        -- Setup "next" stages
        if (test = '0') then
	  next_data1_int := (To_X01(data_s));
        elsif (test = '1') then
          if (tst_mode = 1) then
	    next_data1_int := test_ndata1_int;
          else
	    next_data1_int := (To_X01(data_s));
          end if;
        else
	  next_data1_int := (others => 'X');
	end if;

        if (F_SYNC_TYPE_INT = 1) then
	  next_data2_int := ndata1_int;
        elsif  ((F_SYNC_TYPE_INT = 2) or (F_SYNC_TYPE_INT = 3) or (F_SYNC_TYPE_INT = 4)) then
	  next_data2_int := data1_int;
	else
	  next_data2_int := (others => '0');
	end if;
                      
	next_data3_int := data2_int;
	next_data4_int := data3_int;
                      
        -- Positive edge ffs
        if (rst_d_n = '0') then
           data1_int     := (others => '0');
           data2_int     := (others => '0');
           data3_int     := (others => '0');
           data4_int     := (others => '0');
        elsif (rst_d_n = '1') then
	  if (rising_edge(clk_d)) then
	    if (init_d_n = '0') then
              data1_int     := (others => '0');
              data2_int     := (others => '0');
              data3_int     := (others => '0');
              data4_int     := (others => '0');
	    elsif (init_d_n = '1') then
              data1_int     := next_data1_int;
              data2_int     := next_data2_int;
              data3_int     := next_data3_int;
              data4_int     := next_data4_int;
            else
              data1_int     := (others => 'X');
              data2_int     := (others => 'X');
              data3_int     := (others => 'X');
              data4_int     := (others => 'X');
	    end if;
          else
            data1_int     := data1_int;
            data2_int     := data2_int;
            data3_int     := data3_int;
            data4_int     := data4_int;
	  end if;
	else
           data1_int     := (others => 'X');
           data2_int     := (others => 'X');
           data3_int     := (others => 'X');
           data4_int     := (others => 'X');
	end if;

        -- Negative edge ffs
        if (rst_d_n = '0') then
           ndata1_int       := (others => '0');
           test_ndata1_int  := (others => '0');
        elsif (rst_d_n = '1') then
	  if (falling_edge(clk_d)) then
	    if (init_d_n = '0') then
	      ndata1_int       := (others => '0');
              test_ndata1_int  := (others => '0');
            elsif (init_d_n = '1') then
              ndata1_int       := (To_X01(data_s));
              test_ndata1_int  := (To_X01(data_s));
            else 
              ndata1_int       := (others => 'X');
              test_ndata1_int  := (others => 'X');
            end if;
          end if;
        else
           ndata1_int       := (others => 'X');
           test_ndata1_int  := (others => 'X');
        end if;

	-- Generate different versions of data_d
	test_hold_int <= test_ndata1_int;
	data2_out_int <= data2_int;
	data3_out_int <= data3_int;
	data4_out_int <= data4_int;

    end process;

    mux_out : process (test, data_s, test_hold_int, data2_out_int, data3_out_int, data4_out_int)
      begin
        -- Determine data_d 
	if (F_SYNC_TYPE_INT = 0) then
	  if ((tst_mode = 1) and (test = '1')) then
	    data_d <= test_hold_int;
	  else
	    data_d <= (To_X01(data_s));
	  end if;
	elsif ((F_SYNC_TYPE_INT = 1) or (F_SYNC_TYPE_INT = 2)) then
	  data_d <= data2_out_int;
	elsif (F_SYNC_TYPE_INT = 3) then
	  data_d <= data3_out_int;
        else
	  data_d <= data4_out_int;
	end if;
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
      constant method_str : STRING := " is the DW_sync Clock Domain Crossing Module ***";

    begin
      if ((f_sync_type > 0) AND (f_sync_type < 8)) then
        write(buf, preamble_str);
        write(buf, sim'Instance_name);
        write(buf, method_str);
        writeline(output, buf);
      end if;

      wait;

    end process method_msg;


    -- Message printed to standard output identifyng parameter settings when f_sync_type is not 0
    cfg_msg : process
      variable buf : line;
      constant preamble_str : STRING := "Information: *** Instance ";
      constant configured_str : STRING := " is configured as followed: ";
      constant width_str : STRING := "width is: ";
      constant f_sync_type_str : STRING := ", f_sync_type is: ";
      constant tst_mode_str : STRING := ", tst_mode is: ";
      constant postamble_str :  STRING := " ***";

    begin
      if (F_SYNC_TYPE_INT > 0) then
        write(buf, preamble_str);
        write(buf, sim'Instance_name);
        write(buf, configured_str);
        write(buf, width_str);
        write(buf, width);
        write(buf, f_sync_type_str);
        write(buf, F_SYNC_TYPE_INT);
        write(buf, tst_mode_str);
        write(buf, tst_mode);
	write(buf, postamble_str);
        writeline(output, buf);
      end if;
 
      wait;

    end process cfg_msg;

  -- pragma translate_on 
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_sync_cfg_sim of DW_sync is
 for sim
 end for; -- sim
end DW_sync_cfg_sim;
-- pragma translate_on

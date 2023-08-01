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
-- AUTHOR:    Doug Lee    Apr. 14, 2005
--
-- VERSION:   VHDL Simulation Model
--
-- DesignWare_version: cb5ebe86
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
--              verif_en        [ 0 = no sampling errors inserted,
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
--              data_d        N bits  Destination Domain Data Output
--
--                Note: the value of N is equal to the 'width' parameter value
--
--
-- MODIFIED:
--              RJK   5-13-16  Updated to eliminate undesired pragma
--              DLL   8-8-11   Added tst_mode=2 (not a functional change)
--              DLL   6-12-06  Removed unnecessary To_X01 processing of many input signals
--
--              DLL   11-13-06 Modified functionality to support f_sync_type = 4
--
--------------------------------------------------------------------------
 
library IEEE, DWARE;
use STD.textio.all;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use DWARE.DWpackages.all;

architecture sim_ms of DW_sync is
	
-- pragma translate_off
  signal test_hold_int : std_logic_vector(width-1 downto 0);
  signal data2_out_int : std_logic_vector(width-1 downto 0);
  signal data3_out_int : std_logic_vector(width-1 downto 0);
  signal data4_out_int : std_logic_vector(width-1 downto 0);

  signal hclk_odd	: std_logic;
  signal data_s_int_ms  : std_logic_vector(width-1 downto 0);
  signal data_s_delta_t: std_logic_vector(width-1 downto 0) := (others => '0');
  signal last_data_dyn  : std_logic_vector(width-1 downto 0);
  signal last_data_s    : std_logic_vector(width-1 downto 0);
  signal last_data_s_q  : std_logic_vector(width-1 downto 0);
  signal last_data_s_qq : std_logic_vector(width-1 downto 0);
  signal data_select    : std_logic_vector(width-1 downto 0);
  signal data_select_2  : std_logic_vector(width-1 downto 0);
  signal data_s_sel_0   : std_logic_vector(width-1 downto 0);
  signal data_s_sel_1   : std_logic_vector(width-1 downto 0);
  signal data_s_sel_2   : std_logic_vector(width-1 downto 0);

  constant F_SYNC_TYPE_INT : INTEGER := (f_sync_type mod 8);

  signal init_pass_flag  : std_logic;
  constant init_seed     : integer := 0335;

    -- Returns a random 32-bit integer based on the "seed" input
    function random (seed: integer) return integer is
        variable  tmp    : integer;
        variable  result : integer;

        constant  rand_max : integer := 2147483399;
        constant  r0       : integer := 40692;
        constant  r1       : integer := 52774;
        constant  r2       : integer := 3791;

      begin
	tmp := seed / r1;
	result := r0 * (seed - tmp * r1) - tmp * r2;
	if (result < 0) then
          result := result + rand_max;
        end if;
	
	return (result);

    end function random;


    -- Returns a random "in_width"-bit vector and a newly generated seed
    -- Note: the new_seed can be used by external processes to maintain a stream of seeds into 
    --       the function "random" that is fairly unique through a single path starting from init_seed.
    procedure wide_random (in_width, seed : IN integer;
	   		   vector : OUT std_logic_vector; new_seed : OUT integer) is
        variable  temp_seed   : integer;

      begin
	temp_seed := random(seed);
	if (in_width < 32) then
	  vector := CONV_STD_LOGIC_VECTOR( temp_seed, in_width );
        else
	  vector(31 downto 0) := CONV_STD_LOGIC_VECTOR( temp_seed, 32 ); 
	  if (in_width > 32) then
	    for i in 1 to (in_width/32) loop
	      temp_seed := random(temp_seed);
	      vector(minimum(in_width-1, i*32+31) downto i*32) := CONV_STD_LOGIC_VECTOR( temp_seed, (minimum(in_width-1, i*32+31) - i*32 +1) );
	    end loop;
	  end if;
	end if;

	new_seed := temp_seed;

    end wide_random;
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
      variable ndata1_int      : std_logic_vector(width-1 downto 0);
      variable data1_int       : std_logic_vector(width-1 downto 0);
      variable data2_int       : std_logic_vector(width-1 downto 0);
      variable data3_int       : std_logic_vector(width-1 downto 0);
      variable data4_int       : std_logic_vector(width-1 downto 0);
      variable test_ndata1_int : std_logic_vector(width-1 downto 0);
      variable next_data1_int  : std_logic_vector(width-1 downto 0);
      variable next_data2_int  : std_logic_vector(width-1 downto 0);
      variable next_data3_int  : std_logic_vector(width-1 downto 0);
      variable next_data4_int  : std_logic_vector(width-1 downto 0);
    
      begin
        -- Setup "next" stages
        if (test = '0') then
	  next_data1_int := data_s_int_ms;
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
              ndata1_int       := data_s_int_ms;
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

    hclk_odd <= clk_d when ((verif_en mod 2)=1) else not clk_d;

    missample_delta_delay : process(data_s)
      begin
      data_s_delta_t <= (To_X01(data_s));
    end process missample_delta_delay;

    missample_catch_last_data : process(hclk_odd, data_s)
      begin
      if (rising_edge(hclk_odd) OR data_s'event) then
	last_data_dyn <= data_s_delta_t;
      end if;
    end process missample_catch_last_data;

    missample_hist_even : process (clk_d, rst_d_n)
      begin
        if (rst_d_n = '0') then
           last_data_s_q   <= (others => '0');
        else
	  if (rising_edge(clk_d)) then
	    if (init_d_n = '0') then
              last_data_s_q   <= (others => '0');
	    else
              last_data_s_q   <= last_data_s;
	    end if;
          else
            last_data_s_q   <= last_data_s_q;
	  end if;
	end if;
    end process missample_hist_even;

    missample_hist_odd : process (hclk_odd, rst_d_n)
      begin
        if (rst_d_n = '0') then
           last_data_s     <= (others => '0');
           last_data_s_qq  <= (others => '0');
        else
	  if (rising_edge(hclk_odd)) then
	    if (init_d_n = '0') then
              last_data_s     <= (others => '0');
              last_data_s_qq  <= (others => '0');
	    else
              last_data_s     <= (To_X01(data_s));
              last_data_s_qq  <= last_data_s_q;
	    end if;
          else
            last_data_s     <= last_data_s;
            last_data_s_qq  <= last_data_s_qq;
	  end if;
	end if;
    end process missample_hist_odd;

    set_initial_pass_flag : process (clk_d, rst_d_n, data_s, last_data_s)
      begin
        if (rst_d_n = '0') then
	  init_pass_flag <= '1';
        else
	  if (rising_edge(clk_d)) then
	    if (init_d_n = '0') then
	      init_pass_flag <= '1';
	    end if;
          else
            if ((To_X01(data_s)) /= last_data_s) then
		init_pass_flag <= '0';
	    end if;
          end if;
        end if;
    end process;

    mk_next_data_select : process (data_s, last_data_s)
      variable   rand_seed   : integer;
      variable   data_select_var     : std_logic_vector(width-1 downto 0);
      variable   data_select_2_var   : std_logic_vector(width-1 downto 0);
      begin
        if ((To_X01(data_s)) /= last_data_s) then
	  if (init_pass_flag = '1') then
            rand_seed := init_seed;
	  end if;
          wide_random(in_width=>width, seed=>rand_seed, vector=>data_select_var, new_seed=>rand_seed);
    	  data_select <= data_select_var;
    
          if ((verif_en = 2) OR (verif_en = 3)) then
            wide_random(in_width=>width, seed=>rand_seed, vector=>data_select_2_var, new_seed=>rand_seed);
    	    data_select_2 <= data_select_2_var;
          else
            data_select_2 <= (others => '0');
          end if;
        end if;
    end process;

    -- data_s_sel_0 selects between data_s_int and last_data_s_q based on data_select (on a bit by bit basis
    -- via vector ((a & NOT(sel)) | (b & sel)) expression) except when verif_en prameter is < 1 (i.e. 0)
    -- when only data_s is selected
    --
    data_s_sel_0 <=  data_s when (verif_en < 1) else ((data_s AND NOT(data_select)) OR (last_data_dyn AND data_select));
  
    -- data_s_sel_1 selects between last_data_s_qq and last_data_s_qqq based on data_select only when
    -- verif_en = 2.  Otherwise (when verif_en < 2) a value of all zeros is selected (this is
    -- not necessary for functionality since data_s_sel_1 will never be selected to the vector,
    -- when verif_en is less than 2 because data_select_2 will be forced to
    -- be all zeros - but this is done to reduce the number of needless simulation events)
    --
    data_s_sel_1 <= (others => '0') when (verif_en < 2) else ((last_data_s_q AND NOT(data_select)) OR (last_data_s_qq AND data_select));
  
    -- data_s_int_ms is simply a bit-by-bit mux selection between bits of data_s_sel_0 and
    -- data_s_sel_1, based on the selection control vector, data_select_2.
    --
    data_s_int_ms <= (data_s_sel_0 AND NOT(data_select_2)) OR (data_s_sel_1 AND data_select_2);


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

    -- Message printed to standard output identifyng missampling is enabled and the verif_en value
    missampling_msg : process
      variable buf_ms : line;
      constant preamble_str : STRING := "Information: ";
      constant middle_str   : STRING := ": *** Running with DW_MODEL_MISSAMPLES defined, verif_en is: ";
      constant postamble_str :  STRING := " ***";

      begin
        write(buf_ms, preamble_str);
	write(buf_ms, sim_ms'Instance_name);
	write(buf_ms, middle_str);
        write(buf_ms, verif_en);
        write(buf_ms, postamble_str);
        writeline(output, buf_ms);

        wait;

    end process missampling_msg;



    -- Message printed to standard output identifyng method of use when f_sync_type is greater than 0 and less than 8
    method_msg : process
      variable buf : line;
      constant preamble_str : STRING := "Information: *** Instance ";
      constant method_str : STRING := " is the DW_sync Clock Domain Crossing Module ***";

    begin
      if ((f_sync_type > 0) AND (f_sync_type < 8)) then
        write(buf, preamble_str);
        write(buf, sim_ms'Instance_name);
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
        write(buf, sim_ms'Instance_name);
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


    
  monitor_clk_d  : process (clk_d) begin

    assert NOT (Is_X( clk_d ) AND (now > 0 ns)) 
      report "WARNING: Detected unknown value on the clock input port clk_d."
      severity warning;

  end process monitor_clk_d ;
  -- pragma translate_on 
end sim_ms;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_sync_cfg_sim_ms of DW_sync is
 for sim_ms
 end for; -- sim_ms
end DW_sync_cfg_sim_ms;
-- pragma translate_on

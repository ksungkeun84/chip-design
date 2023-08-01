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
-- AUTHOR:    Doug Lee    Jan 3, 2006
--
-- VERSION:   VHDL Simulation Model
--
-- DesignWare_version: 1128c551
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
--
-- ABSTRACT: Data Stream Synchronizer Simulation Model
--
--           This synchronizes an incoming data stream from a source domain
--           to a destination domain with a minimum amount of latency.
--
--       Parameters:     Valid Values    Description
--       ==========      ============    ===========
--       width            1 to 1024      default: 8
--                                       Width of data_s and data_d ports
--
--       depth            2 to 256       default: 4
--                                       Depth of FIFO
--
--       prefill_lvl     0 to depth-1    default: 0
--                                       number of FIFO locations filled before
--                                       transferring to destination domain ]
--
--       f_sync_type       0 to 4        default: 2
--                                       Forward Synchronization Type (Source to Destination Domains)
--                                         0 => no synchronization, single clock design
--                                         1 => 2-stage synchronization w/ 1st stage neg-edge & 2nd stage pos-edge capturing
--                                         2 => 2-stage synchronization w/ both stages pos-edge capturing
--                                         3 => 3-stage synchronization w/ all stages pos-edge capturing
--                                         4 => 4-stage synchronization w/ all stages pos-edge capturing
--
--       reg_stat          0 or 1        default: 1
--                                       Register internally calculated status
--                                         0 => don't register internally calculated status
--                                         1 => register internally calculated status
--
--       tst_mode          0 or 2        default: 0
--                                       Insert neg-edge hold latch at front-end of synchronizers during "test"
--                                         0 => no hold latch inserted,
--                                         1 => insert hold 'latch' using a neg-edge triggered register
--                                         2 => insert hold latch using an active low latch
--
--        verif_en         0 to 4        default: 1
--                                       Verification mode
--                                         0 => no sampling errors inserted,
--                                         1 => sampling errors are randomly inserted with 0 or up to 1 destination clock cycle delays
--                                         2 => sampling errors are randomly inserted with 0, 0.5, 1, or 1.5 destination clock cycle delays
--                                         3 => sampling errors are randomly inserted with 0, 1, 2, or 3 destination clock cycle delays
--                                         4 => sampling errors are randomly inserted with 0 or up to 0.5 destination clock cycle delays
--
--       r_sync_type       0 to 4        default: 2
--                                       Reverse Synchronization Type (Destination to Source Domains)
--                                         0 => no synchronization, single clock design
--                                         1 => 2-stage synchronization w/ 1st stage neg-edge & 2nd stage pos-edge capturing
--                                         2 => 2-stage synchronization w/ both stages pos-edge capturing
--                                         3 => 3-stage synchronization w/ all stages pos-edge capturing
--                                         4 => 4-stage synchronization w/ all stages pos-edge capturing
--
--       clk_d_faster      0 to 15       default: 1
--                                       clk_d faster than clk_s by difference ratio
--                                         0        => Either clr_s or clr_d active with the other tied low at input
--                                         1 to 15  => ratio of clk_d to clk_s frequencies plus 1
--
--       reg_in_prog       0 or 1        default: 1
--                                       Register the 'clr_in_prog_s' and 'clr_in_prog_d' Outputs
--                                         0 => unregistered
--                                         1 => registered
--
--       Input Ports:    Size     Description
--       ===========     ====     ===========
--       clk_s           1 bit    Source Domain Input Clock
--       rst_s_n         1 bit    Source Domain Active Low Async. Reset
--       init_s_n        1 bit    Source Domain Active Low Sync. Reset
--       clr_s           1 bit    Source Domain Internal Logic Clear (reset)
--       send_s          1 bit    Source Domain Active High Send Request
--       data_s          N bits   Source Domain Data
--
--       clk_d           1 bit    Destination Domain Input Clock
--       rst_d_n         1 bit    Destination Domain Active Low Async. Reset
--       init_d_n        1 bit    Destination Domain Active Low Sync. Reset
--       clr_d           1 bit    Destination Domain Internal Logic Clear (reset)
--       prefill_d       1 bit    Destination Domain Prefill Control
--
--       test            1 bit    Test input
--
--       Output Ports    Size     Description
--       ============    ====     ===========
--       clr_sync_d      1 bit    Source Domain Clear
--       clr_in_prog_s   1 bit    Source Domain Clear in Progress
--       clr_cmplt_s     1 bit    Soruce Domain Clear Complete (pulse)
--
--       clr_in_prog_d   1 bit    Destination Domain Clear in Progress
--       clr_sync_d      1 bit    Destination Domain Clear (pulse)
--       clr_cmplt_d     1 bit    Destination Domain Clear Complete (pulse)
--       data_avail_d    1 bit    Destination Domain Data Available
--       data_d          N bits   Destination Domain Data
--       prefilling_d    1 bit    Destination Domain Prefillng Status
--
--           Note: The value of N is equal to the 'width' parameter value
--
--
-- MODIFIED:
--
--  07/25/11 DLL  Removed or-ing of 'clr_in_prog_d' with 'init_d_n' that
--                wires to DW_sync 'init_d_n' input port.
--                Added checking and comments for tst_mode = 2.
--
--  10/20/06 DLL  Updated with new version of DW_reset_sync
--
--  11/15/06 DLL  Added 4-stage synchronization capability
--
--  11/21/06 DLL  Changed library reference in configuration block
--
--------------------------------------------------------------------------
 
library IEEE, DWARE;
use STD.textio.all;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_misc.all;
use DWARE.DWpackages.all;
use DWARE.DW_foundation_comp_arith.all;

architecture sim of DW_stream_sync is
	

  function calc_sync_verif_en( verif_en : in INTEGER ) return INTEGER is
    begin
        if(verif_en = 2) then
          return (4);
        elsif (verif_en = 3) then
          return (1);
        else
          return(verif_en);
        end if;
  end calc_sync_verif_en; -- local verif_en for DW_sync instance

  constant sync_verif_en  : INTEGER := calc_sync_verif_en(verif_en);

  type FifoArrayType is array (0 to depth-1) of
         std_logic_vector(width-1 downto 0);

  signal data_mem               : FifoArrayType;
  signal next_data_mem          : std_logic_vector(width-1 downto 0);

  signal data_avail_d_int       : std_logic;
  signal next_data_avail_d_int  : std_logic;
  signal data_d_int             : std_logic_vector(width-1 downto 0);
  signal next_data_d_int        : std_logic_vector(width-1 downto 0);
  signal prefilling_d_int       : std_logic;
  signal next_prefilling_d_int  : std_logic;

  signal clr_sync_s_int         : std_logic;
  signal clr_in_prog_s_int      : std_logic;
  signal clr_cmplt_s_int        : std_logic;
  signal clr_in_prog_d_int      : std_logic;
  signal clr_sync_d_int         : std_logic;
  signal clr_cmplt_d_int        : std_logic;

  signal dw_sync_event_vec      : std_logic_vector(depth-1 downto 0);
  signal event_vec_selected     : std_logic_vector(depth-1 downto 0);
  signal event_vec_l            : std_logic_vector(depth-1 downto 0);
  signal event_vec_s            : std_logic_vector(depth-1 downto 0);
  signal next_event_vec_s       : std_logic_vector(depth-1 downto 0);

  signal wr_ptr_s               : std_logic_vector(bit_width(depth)-1 downto 0);
  signal next_wr_ptr_s          : std_logic_vector(bit_width(depth)-1 downto 0);
  signal rd_ptr_d               : std_logic_vector(bit_width(depth)-1 downto 0);
  signal next_rd_ptr_d          : std_logic_vector(bit_width(depth)-1 downto 0);

  signal detect_lvl             : std_logic;
  signal next_detect_lvl        : std_logic;

  signal valid_cnt              : std_logic_vector(bit_width(depth)-1 downto 0);
  signal next_valid_cnt         : std_logic_vector(bit_width(depth)-1 downto 0);


  constant F_SYNC_TYPE_ADD8 : INTEGER := (f_sync_type + 8);
  constant F_SYNC_TYPE_INT : INTEGER := (f_sync_type mod 8);
  constant R_SYNC_TYPE_ADD8 : INTEGER := (r_sync_type + 8);
  constant R_SYNC_TYPE_INT : INTEGER := (r_sync_type mod 8);

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
     
    if ( (depth < 2) OR (depth > 256) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter depth (legal range: 2 to 256)"
        severity warning;
    end if;
     
    if ( (prefill_lvl < 0) OR (prefill_lvl > 255) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter prefill_lvl (legal range: 0 to 255)"
        severity warning;
    end if;
     
    if ( (F_SYNC_TYPE_INT < 0) OR (F_SYNC_TYPE_INT > 4) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter F_SYNC_TYPE_INT (legal range: 0 to 4)"
        severity warning;
    end if;
     
    if ( (reg_stat < 0) OR (reg_stat > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter reg_stat (legal range: 0 to 1)"
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
     
    if ( (R_SYNC_TYPE_INT < 0) OR (R_SYNC_TYPE_INT > 4) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter R_SYNC_TYPE_INT (legal range: 0 to 4)"
        severity warning;
    end if;
     
    if ( (clk_d_faster < 0) OR (clk_d_faster > 15) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter clk_d_faster (legal range: 0 to 15)"
        severity warning;
    end if;
     
    if ( (reg_in_prog < 0) OR (reg_in_prog > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter reg_in_prog (legal range: 0 to 1)"
        severity warning;
    end if;
    
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;

  U_RST: DW_reset_sync
    generic map (
      f_sync_type  => F_SYNC_TYPE_ADD8,
      r_sync_type  => R_SYNC_TYPE_ADD8,
      clk_d_faster => clk_d_faster,
      reg_in_prog  => reg_in_prog,
      tst_mode     => tst_mode,
      verif_en     => verif_en)
    port map (
      clk_s         => clk_s,
      rst_s_n       => rst_s_n,  
      init_s_n      => init_s_n,  
      clr_s         => To_X01(clr_s),
      clk_d         => clk_d,
      rst_d_n       => rst_d_n,  
      init_d_n      => init_d_n,  
      clr_d         => To_X01(clr_d),
      test          => test,  
      clr_sync_s    => clr_sync_s_int,
      clr_in_prog_s => clr_in_prog_s_int,
      clr_cmplt_s   => clr_cmplt_s_int, 
      clr_in_prog_d => clr_in_prog_d_int,
      clr_sync_d    => clr_sync_d_int,
      clr_cmplt_d   => clr_cmplt_d_int);


    src_PROC: process (send_s, data_s, event_vec_s, wr_ptr_s, data_mem)
      begin
        if (send_s = '1') then
          next_event_vec_s(0) <= NOT(event_vec_s(depth-1));
          next_event_vec_s(depth-1 downto 1) <= event_vec_s(depth-2 downto 0);
  	  next_data_mem <= data_s;
          if ((CONV_INTEGER(UNSIGNED(wr_ptr_s))) = (depth-1)) then
            next_wr_ptr_s <= (others => '0');
          else
            next_wr_ptr_s <= CONV_STD_LOGIC_VECTOR((CONV_INTEGER(UNSIGNED(wr_ptr_s)) + 1), bit_width(depth));
          end if;
        elsif (send_s = '0') then
          next_event_vec_s  <= event_vec_s;
          next_wr_ptr_s <= wr_ptr_s;
  	  next_data_mem <= data_mem(CONV_INTEGER(UNSIGNED(wr_ptr_s)));
        else
          next_event_vec_s <= (others => 'X');
          next_data_mem <= (others => 'X');
          next_wr_ptr_s <= (others => 'X');
        end if;
    end process;  -- data_mem_PROC


    sim_clk_s: process (clk_s, rst_s_n)

      variable i  : INTEGER;

      begin
        if (rst_s_n = '0') then
          event_vec_s  <= (others => '0');
          wr_ptr_s <= (others => '0');
	  for i in 0 to (depth-1) loop
            data_mem(i) <= (others => '0');
	  end loop;
        elsif (rst_s_n = '1') then
	  if (rising_edge(clk_s)) then
	    if ((init_s_n = '0') OR (clr_in_prog_s_int = '1')) then
              event_vec_s  <= (others => '0');
              wr_ptr_s <= (others => '0');
	      for i in 0 to (depth-1) loop
                data_mem(i) <= (others => '0');
	      end loop;
	    elsif (init_s_n = '1') then
              event_vec_s  <= next_event_vec_s;
              wr_ptr_s <= next_wr_ptr_s;
              data_mem(CONV_INTEGER(UNSIGNED(wr_ptr_s))) <= next_data_mem;
            else
              event_vec_s  <= (others => 'X');
              wr_ptr_s <= (others => 'X');
              data_mem(CONV_INTEGER(UNSIGNED(wr_ptr_s))) <= (others => 'X');
	    end if;
          else
            event_vec_s  <= event_vec_s;
            wr_ptr_s <= wr_ptr_s;
            data_mem(CONV_INTEGER(UNSIGNED(wr_ptr_s))) <= data_mem(CONV_INTEGER(UNSIGNED(wr_ptr_s)));
	  end if;
	else
          event_vec_s  <= (others => 'X');
          wr_ptr_s <= (others => 'X');
          data_mem(CONV_INTEGER(UNSIGNED(wr_ptr_s))) <= (others => 'X');
	end if;

        if (Is_X(wr_ptr_s)) then
	  for i in 0 to (depth-1) loop
            data_mem(i) <= (others => 'X');
	  end loop;
        end if;

    end process;


  hold_latch_PROC : process(clk_s, event_vec_s) begin
    if (clk_s = '0') then
      event_vec_l <= event_vec_s;
    end if;
  end process hold_latch_PROC;

  event_vec_selected <= event_vec_l when (((f_sync_type mod 8) > 1) AND (tst_mode = 2) AND (test = '1')) else event_vec_s;

  U_SYNC : DW_sync
    generic map (
	width => depth,
	f_sync_type => f_sync_type+8,
	tst_mode => tst_mode,
	verif_en => sync_verif_en )
    port map (
	clk_d => clk_d,
	rst_d_n => rst_d_n,
	init_d_n => init_d_n,
	data_s => event_vec_selected,
	test => test,
	data_d => dw_sync_event_vec );

    
    valid_cnt_PROC: process (dw_sync_event_vec, rd_ptr_d, detect_lvl)
      variable idx             : INTEGER;
      variable tmp_valid_cnt   : std_logic_vector(bit_width(depth)-1 downto 0);

      begin
        tmp_valid_cnt := (others => '0');
        for idx in 0 to (depth-1) loop
          if (CONV_INTEGER(UNSIGNED(rd_ptr_d)) > idx) then 
            if (dw_sync_event_vec(idx) = NOT(detect_lvl)) then
              tmp_valid_cnt := CONV_STD_LOGIC_VECTOR((CONV_INTEGER(UNSIGNED(tmp_valid_cnt))+1), bit_width(depth));
            else
              tmp_valid_cnt := tmp_valid_cnt;
            end if;
          else
            if (dw_sync_event_vec(idx) = detect_lvl) then
              tmp_valid_cnt := CONV_STD_LOGIC_VECTOR((CONV_INTEGER(UNSIGNED(tmp_valid_cnt))+1), bit_width(depth));
            else
              tmp_valid_cnt := tmp_valid_cnt;
            end if;
          end if;
          if (dw_sync_event_vec(idx) = 'X') then
            tmp_valid_cnt := (others => 'X');
          end if;

        end loop;
      
	next_valid_cnt <= tmp_valid_cnt;

    end process;


    prefilling_PROC: process (prefill_d, prefilling_d_int, valid_cnt, next_valid_cnt)
    
      begin
        if ((prefill_d = 'X') OR (prefilling_d_int = 'X')) then
          next_prefilling_d_int <= 'X';
        elsif (prefill_lvl = 0) then
          next_prefilling_d_int <= '0';
        else
          if (reg_stat = 1) then
            if ((prefill_d = '1') AND (prefill_lvl > CONV_INTEGER(UNSIGNED(valid_cnt)))) then
              next_prefilling_d_int <= '1';
            elsif (prefill_lvl <= CONV_INTEGER(UNSIGNED(valid_cnt))) then
              next_prefilling_d_int <= '0';
            else
              next_prefilling_d_int <= prefilling_d_int;
            end if;
          else
            if ((prefill_d = '1') AND (prefill_lvl > CONV_INTEGER(UNSIGNED(next_valid_cnt)))) then
              next_prefilling_d_int <= '1';
            elsif (prefill_lvl <= CONV_INTEGER(UNSIGNED(next_valid_cnt))) then
              next_prefilling_d_int <= '0';
            else
              next_prefilling_d_int <= prefilling_d_int;
            end if;
          end if;
        end if;
    end process;


    read_ptr_PROC: process (next_data_avail_d_int, rd_ptr_d)

      begin
        if (next_data_avail_d_int = 'X') then
          next_rd_ptr_d <= (others => 'X');
        elsif (next_data_avail_d_int = '1') then
          if (CONV_INTEGER(UNSIGNED(rd_ptr_d)) = (depth-1)) then
            next_rd_ptr_d <= (others => '0');
          else
            next_rd_ptr_d <= CONV_STD_LOGIC_VECTOR((CONV_INTEGER(UNSIGNED(rd_ptr_d))+1), bit_width(depth));
          end if;
        else
          next_rd_ptr_d <= rd_ptr_d;
        end if;
    end process;

    next_detect_lvl <= NOT(detect_lvl) when ((next_data_avail_d_int = '1') AND
                                             (OR_REDUCE(next_rd_ptr_d) = '0'))
                                       else detect_lvl;

    data_avail_PROC: process (next_prefilling_d_int, detect_lvl, dw_sync_event_vec, rd_ptr_d)
      begin
        if ((dw_sync_event_vec(CONV_INTEGER(UNSIGNED(rd_ptr_d))) = 'X') OR (next_prefilling_d_int = 'X')) then
          next_data_avail_d_int <= 'X';
	elsif ((next_prefilling_d_int = '0') AND
	        (detect_lvl = dw_sync_event_vec(CONV_INTEGER(UNSIGNED(rd_ptr_d))))) then
          next_data_avail_d_int <= '1';
        else
          next_data_avail_d_int <= '0';
	end if;
    end process;

    data_d_PROC: process (next_data_avail_d_int, rd_ptr_d, data_d_int, data_mem)
      begin
        if (next_data_avail_d_int = 'X') then
          next_data_d_int  <= (others => 'X');
        elsif (next_data_avail_d_int = '1') then
          next_data_d_int  <= data_mem(CONV_INTEGER(UNSIGNED(rd_ptr_d)));
        else
          next_data_d_int  <= data_d_int;
        end if;
    end process;


    sim_clk_d: process (clk_d, rst_d_n)

      begin

        if (rst_d_n = '0') then
          rd_ptr_d          <= (others => '0');
          valid_cnt         <= (others => '0');
          detect_lvl        <= '1';
          data_avail_d_int  <= '0';
          data_d_int        <= (others => '0');
          prefilling_d_int  <= '0';
        elsif (rst_d_n = '1') then
	  if (rising_edge(clk_d)) then
	    if ((init_d_n = '0') OR (clr_in_prog_d_int = '1')) then
              rd_ptr_d          <= (others => '0');
              valid_cnt         <= (others => '0');
              detect_lvl        <= '1';
              data_avail_d_int  <= '0';
              data_d_int        <= (others => '0');
              prefilling_d_int  <= '0'; 
	    elsif (init_d_n = '1') then
              rd_ptr_d          <= next_rd_ptr_d;
              valid_cnt         <= next_valid_cnt;
              detect_lvl        <= next_detect_lvl;
              data_avail_d_int  <= next_data_avail_d_int;
              data_d_int        <= next_data_d_int;
              prefilling_d_int  <= next_prefilling_d_int;
            else
              rd_ptr_d          <= (others => 'X');
              valid_cnt         <= (others => 'X');
              detect_lvl        <= 'X';
              data_avail_d_int  <= 'X';
              data_d_int        <= (others => 'X');
              prefilling_d_int  <= 'X';
	    end if;
          else
            rd_ptr_d          <= rd_ptr_d;
            valid_cnt         <= valid_cnt;
            detect_lvl        <= detect_lvl;
            data_avail_d_int  <= data_avail_d_int;
            data_d_int        <= data_d_int;
            prefilling_d_int  <= prefilling_d_int;
	  end if;
	else
          rd_ptr_d          <= (others => 'X');
          valid_cnt         <= (others => 'X');
          detect_lvl        <= 'X';
          data_avail_d_int  <= 'X';
          data_d_int        <= (others => 'X');
          prefilling_d_int  <= 'X';
	end if;

    end process;

    clr_sync_s    <= clr_sync_s_int;
    clr_in_prog_s <= clr_in_prog_s_int;
    clr_cmplt_s   <= clr_cmplt_s_int;
    clr_in_prog_d <= clr_in_prog_d_int;
    clr_sync_d    <= clr_sync_d_int;
    clr_cmplt_d   <= clr_cmplt_d_int;
    data_avail_d  <= data_avail_d_int;
    data_d        <= data_d_int;
    prefilling_d  <= prefilling_d_int;

    
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
      constant method_str : STRING := " is the DW_stream_sync Clock Domain Crossing Module ***";

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
configuration DW_stream_sync_cfg_sim_ms of DW_stream_sync is
 for sim
  for U_RST: DW_reset_sync use configuration dw03.DW_reset_sync_cfg_sim_ms; end for;
  for U_SYNC: DW_sync use configuration dw03.DW_sync_cfg_sim_ms; end for;
 end for; -- sim
end DW_stream_sync_cfg_sim_ms;

library dw03;
configuration DW_stream_sync_cfg_sim of DW_stream_sync is
 for sim
  for U_RST: DW_reset_sync use configuration dw03.DW_reset_sync_cfg_sim; end for;
  for U_SYNC: DW_sync use configuration dw03.DW_sync_cfg_sim; end for;
 end for; -- sim
end DW_stream_sync_cfg_sim;
-- pragma translate_on

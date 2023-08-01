--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2004 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Doug Lee   Aug. 23, 2005
--
-- VERSION:   VHDL simulation model for DW_gray_sync
--
-- DesignWare_version: 55a0ba6a
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT: Gray Coded Synchronizer Simulation Model
--
--           This converts binary counter values to gray-coded values in the source domain
--           which then gets synchronized in the destination domain.  Once in the destination
--           domain, the gray-coded values are decoded back to binary values and presented
--           to the output port 'count_d'.  In the source domain, two versions of binary
--           counter values, count_s and offset_count_s, are output to give reference to
--           current state of the counters in, relative and absolute terms, respectively.
--
--              Parameters:     Valid Values
--              ==========      ============
--              width           [ 1 to 1024: width of count_s, offset_count_s and count_d ports
--                                default: 8 ]
--              offset          [ 0 to (2**(width-1) - 1): offset for non integer power of 2
--                                default: 0 ]
--              reg_count_d     [ 0 or 1: registering of count_d output
--                                default: 1
--                                0 = count_d output is unregistered
--                                1 = count_d output is registered ]
--              f_sync_type     [ 0 to 4: mode of synchronization
--                                default: 2
--                                0 = single clock design, no synchronizing stages implemented,
--                                1 = 2-stage synchronization w/ 1st stage neg-edge & 2nd stage pos-edge capturing,
--                                2 = 2-stage synchronization w/ both stages pos-edge capturing,
--                                3 = 3-stage synchronization w/ all stages pos-edge capturing
--                                4 = 4-stage synchronization w/ all stages pos-edge capturing ]
--              tst_mode        [ 0 to 2: latch insertion for testing purposes
--                                default: 0
--                                0 = no hold latch inserted,
--                                1 = insert hold 'latch' using a neg-edge triggered register
--                                2 = insert hold 'latch' using active low latch ]
--              verif_en        [ 0, 1, or 4: verification mode
--                                default: 1
--                                0 = no sampling errors inserted,
--                                1 = sampling errors are randomly inserted with 0 or up to 1 destination clock cycle delays
--                                4 = sampling errors are randomly inserted with 0 or up to 0.5 destination clock cycle delays ]
--              pipe_delay      [ 0 to 2: pipeline bin2gray result
--                                default: 0
--                                0 = only re-timing register of bin2gray result to destination domain
--                                1 = one additional pipeline stage of bin2gray result to destination domain
--                                2 = two additional pipeline stages of bin2gray result to destination domain ]
--              reg_count_s     [ 0 or 1: registering of count_s output
--                                default: 1
--                                0 = count_s output is unregistered
--                                1 = count_s output is registered ]
--              reg_offset_count_s  [ 0 or 1: registering of offset_count_s output
--                                    default: 1
--                                    0 = offset_count_s output is unregistered
--                                    1 = offset_count_s output is registered ]
--
--              Input Ports:    Size     Description
--              ===========     ====     ===========
--              clk_s           1 bit    Source Domain Input Clock
--              rst_s_n         1 bit    Source Domain Active Low Async. Reset
--              init_s_n        1 bit    Source Domain Active Low Sync. Reset
--              en_s            1 bit    Source Domain enable that advances binary counter
--              clk_d           1 bit    Destination Domain Input Clock
--              rst_d_n         1 bit    Destination Domain Active Low Async. Reset
--              init_d_n        1 bit    Destination Domain Active Low Sync. Reset
--              test            1 bit    Test input
--
--              Output Ports    Size     Description
--              ============    ====     ===========
--              count_s         M bit    Source Domain binary counter value
--              offset_count_s  M bits   Source Domain binary counter offset value
--              count_d         M bits   Destination Domain binary counter value
--
--                Note: (1) The value of M is equal to the 'width' parameter value
--
--
-- MODIFIED:
--            8/01/11 DLL    Tied 'init_d_n' input to instance DW_sync to '1' to
--                           disable any type of synchronous reset to it and added
--                           tst_mode=2 capability.
--
--            2/28/08 DLL    Changed behavior of next_count_s_int and next_offset_count_s_int
--                           during init_s_n assertion.  
--                           Addresses STAR#9000450996.
--
--            11/21/06 DLL   Changed library reference in configuration block
--
--            11/7/06  DLL   Modified functionality to support f_sync_type = 4
--
--            8/1/06   DLL   Added parameter 'reg_offset_count_s' which allows for registered
--                           or unregistered 'offset_count_s'.
--
--            7/21/06  DLL   Added parameter 'reg_count_s' which allows for registered
--                           or unregistered 'count_s'.
--
--            7/10/06  DLL   Added parameter 'pipe_delay' that allows up to 2 additional
--                           register delays of the binary to gray code result from
--                           the source to destination domain.
--
--            6/14/06  DLL  Removed unnecessary To_X01 processing of many input signals
--
-------------------------------------------------------------------------------
library IEEE, DWARE;
use STD.textio.all;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_misc.all;
use DWARE.DW_Foundation_arith.all;
use DWARE.DW_foundation_comp_arith.all;

architecture sim of DW_gray_sync is
	
  signal bin2gray_cc        : std_logic_vector(width-1 downto 0);
  signal bin2gray_l         : std_logic_vector(width-1 downto 0);
  signal bin2gray_s         : std_logic_vector(width-1 downto 0);
  signal bin2gray_s_d1      : std_logic_vector(width-1 downto 0);
  signal bin2gray_s_d2      : std_logic_vector(width-1 downto 0);
  signal bin2gray_s_pipe    : std_logic_vector(width-1 downto 0);
  signal DW_sync_bin2gray_d : std_logic_vector(width-1 downto 0);

  signal next_count_s_int        : std_logic_vector(width-1 downto 0);
  signal next_offset_count_s_int : std_logic_vector(width-1 downto 0);
  signal next_bin2gray_s         : std_logic_vector(width-1 downto 0);
  signal count_s_int             : std_logic_vector(width-1 downto 0);
  signal count_s_int_xor         : std_logic_vector(width-1 downto 0);
  signal offset_count_s_int      : std_logic_vector(width-1 downto 0);
  signal next_count_d_int   : std_logic_vector(width-1 downto 0);
  signal count_d_int        : std_logic_vector(width-1 downto 0);

  constant F_SYNC_TYPE_ADD8 : INTEGER := (f_sync_type + 8);
  constant F_SYNC_TYPE_INT : INTEGER := (f_sync_type mod 8);

  constant OFFSET_MAX : INTEGER := ((2**(width-1))-1);
  constant FORCED_VALUE : std_logic_vector(width-1 downto 0) := CONV_STD_LOGIC_VECTOR(offset, width);
  constant FORCED_VALUE_BIN2GRAY : std_logic_vector(width-1 downto 0) := DWF_bin2gray(FORCED_VALUE);
  constant COUNT_S_MAX : std_logic_vector(width-1 downto 0) := CONV_STD_LOGIC_VECTOR(((2**width)-1-offset),width);

   -- component declarations


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
  
    if ( (offset < 0) OR (offset > OFFSET_MAX) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter offset (legal range: 0 to OFFSET_MAX)"
        severity warning;
    end if;
  
    if ( (reg_count_d < 0) OR (reg_count_d > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter reg_count_d (legal range: 0 to 1)"
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
  
    if ( ((verif_en = 2)or(verif_en = 3)) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Illegal value for verif_en. For DW_gray_sync, values 2 and 3 are not allowed."
        severity warning;
    end if;
  
    if ( (pipe_delay < 0) OR (pipe_delay > 2) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter pipe_delay (legal range: 0 to 2)"
        severity warning;
    end if;
  
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;


  next_count_values: process (init_s_n, en_s, count_s_int_xor, offset_count_s_int, next_count_s_int)

    begin
      if (init_s_n = '0') then
        next_count_s_int        <= FORCED_VALUE;
        next_offset_count_s_int <= (others => '0');
      else
        if (en_s = '1') then
          if (count_s_int_xor = COUNT_S_MAX) then
            next_count_s_int        <= FORCED_VALUE;
            next_offset_count_s_int <= (others => '0');
          else
  	  if (count_s_int_xor(0) = 'X') then
              next_count_s_int        <= (others => 'X');
              next_offset_count_s_int <= (others => 'X');
            else
              next_count_s_int        <= CONV_STD_LOGIC_VECTOR((CONV_INTEGER(UNSIGNED(count_s_int_xor)) + 1), width);
              next_offset_count_s_int <= CONV_STD_LOGIC_VECTOR((CONV_INTEGER(UNSIGNED(offset_count_s_int)) + 1), width);
  	  end if;
          end if;
        elsif (en_s = '0') then
          next_count_s_int        <= count_s_int_xor;
          next_offset_count_s_int <= offset_count_s_int;
        else
          next_count_s_int        <= (others => 'X');
          next_offset_count_s_int <= (others => 'X');
        end if;
      end if;

  end process;

  next_bin2gray_s  <= DWF_bin2gray(next_count_s_int);

  bin2gray_s_pipe  <= bin2gray_s_d2 when (pipe_delay = 2) else
			bin2gray_s_d1 when (pipe_delay = 1) else bin2gray_s;


  hold_latch_PROC : process(clk_s, bin2gray_s_pipe) begin
    if (clk_s = '0') then
      bin2gray_l <= bin2gray_s_pipe;
    end if;
  end process hold_latch_PROC;

  bin2gray_cc <= bin2gray_l when (((f_sync_type mod 8) > 1) AND (tst_mode = 2) AND (test = '1')) else bin2gray_s_pipe;

  U_SYNC : DW_sync
    generic map (
	width => width,
	f_sync_type => f_sync_type+8,
	tst_mode => tst_mode,
	verif_en => verif_en )
    port map (
	clk_d => clk_d,
	rst_d_n => rst_d_n,
	init_d_n => '1',
	data_s => bin2gray_cc,
	test => test,
	data_d => DW_sync_bin2gray_d );

  gray_sync_sim_s: process (clk_s, rst_s_n)

    begin
      if (rst_s_n = '0') then
        count_s_int         <= (others => '0');
        offset_count_s_int  <= (others => '0');
        bin2gray_s          <= (others => '0');
        bin2gray_s_d1       <= (others => '0');
        bin2gray_s_d2       <= (others => '0');
      elsif (rst_s_n = '1') then
        if (rising_edge(clk_s)) then
          if (init_s_n = '0') then
            count_s_int         <= (others => '0');
            offset_count_s_int  <= (others => '0');
            bin2gray_s          <= (others => '0');
            bin2gray_s_d1       <= (others => '0');
            bin2gray_s_d2       <= (others => '0');
          elsif (init_s_n = '1') then
            count_s_int         <= next_count_s_int XOR FORCED_VALUE;
            offset_count_s_int  <= next_offset_count_s_int;
            bin2gray_s          <= next_bin2gray_s XOR FORCED_VALUE_BIN2GRAY;
            bin2gray_s_d1       <= bin2gray_s;
            bin2gray_s_d2       <= bin2gray_s_d1;
          else
            count_s_int         <= (others => 'X');
            offset_count_s_int  <= (others => 'X');
            bin2gray_s          <= (others => 'X');
            bin2gray_s_d1       <= (others => 'X');
            bin2gray_s_d2       <= (others => 'X');
          end if;
        else
          count_s_int         <= count_s_int;
          offset_count_s_int  <= offset_count_s_int;
          bin2gray_s          <= bin2gray_s;
          bin2gray_s_d1       <= bin2gray_s_d1;
          bin2gray_s_d2       <= bin2gray_s_d2;
        end if;
      else
        count_s_int         <= (others => 'X');
        offset_count_s_int  <= (others => 'X');
        bin2gray_s          <= (others => 'X');
        bin2gray_s_d1       <= (others => 'X');
        bin2gray_s_d2       <= (others => 'X');
      end if;

  end process;

  next_count_d_int <= DWF_gray2bin(DW_sync_bin2gray_d);

  gray_sync_sim_d: process (clk_d, rst_d_n)

    begin

       if (rst_d_n = '0') then
          count_d_int       <= (others => '0');
        elsif (rst_d_n = '1') then
          if (rising_edge(clk_d)) then
            if (init_d_n = '0') then
              count_d_int       <= (others => '0');
            elsif (init_d_n = '1') then
              count_d_int       <= next_count_d_int;
            else
              count_d_int       <= (others => 'X');
            end if;
          else
            count_d_int       <= count_d_int;
          end if;
        else
          count_d_int       <= (others => 'X');
        end if;

  end process;

  -- intermediate signal
  count_s_int_xor <= count_s_int XOR FORCED_VALUE;

  -- Source domain outputs
  count_s        <= count_s_int_xor when (reg_count_s = 1) else next_count_s_int;
  offset_count_s <= offset_count_s_int when (reg_offset_count_s = 1) else next_offset_count_s_int;

  -- Generate different versions of count_d
  count_d       <= (count_d_int XOR FORCED_VALUE) when (reg_count_d = 1) else (next_count_d_int XOR FORCED_VALUE);



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
      constant method_str : STRING := " is the DW_gray_sync Clock Domain Crossing Module ***";

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
configuration DW_gray_sync_cfg_sim_ms of DW_gray_sync is
 for sim
  for U_SYNC: DW_sync use configuration dw03.DW_sync_cfg_sim_ms; end for;
 end for; -- sim
end DW_gray_sync_cfg_sim_ms;

library dw03;
configuration DW_gray_sync_cfg_sim of DW_gray_sync is
 for sim
    for U_SYNC : DW_sync use configuration dw03.DW_sync_cfg_sim; end for;
 end for; -- sim
end DW_gray_sync_cfg_sim;
-- pragma translate_on

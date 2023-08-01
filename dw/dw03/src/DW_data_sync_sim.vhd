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
-- VERSION:   VHDL simulation model for  DW_data_sync
--
-- DesignWare_version: 6e79b363
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:   Data Synchronizer
--              Synchronizes data across clock boundaries
--
-- KNOWN BUGS: None
--
-- CHANGE LOG:
--  01/09/06   File created.  bd
--  02/03/06   added send mode param
--  06/16/06   added To_X01 processing to 'data_s' along with enhancing X-handling
--  11/07/06   incremented f_sync parameter for 4 flop synchronization
--  11/21/06   Changed library reference in configuration block
--  01/08/10   Fixed STAR#9000366699 regarding improper behavior
--             of 'error_s' for both 'pend_mode' values (0, 1).
--
-----------------------------------------------------------------------------
library IEEE, DWARE;
use STD.textio.all;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_misc.all;
use DWARE.DWpackages.all;
use DWARE.DW_foundation_comp_arith.all;
architecture sim of DW_data_sync is
	
signal O01Ol01O      : std_logic;
signal O000OO1I      : std_logic;
signal OlOOl0l1    : std_logic;

signal IOO1O01O  : std_logic;
signal O00Il110    : std_logic;
signal O1l010OO    : std_logic;
signal OlOlI110   : std_logic;
signal lOI1I00l   : std_logic;
signal lO110OlI : std_logic;
signal Ill01O1l   : std_logic;
signal l1ll0II1   : std_logic;
signal OOl101lO  : std_logic;
signal OO1101OO  : std_logic;
signal data_s_kod  : std_logic;

signal IOlIO1I1     : std_logic;
signal O1OIOOOI     : std_logic;
signal O1I1l10l      : std_logic;
signal O1111O11  : std_logic;

signal I11I0l0I      : std_logic;
signal O1l10OO0  : std_logic;

signal O01OOI01  : std_logic;
signal OOlIO1I0 : std_logic;
signal I1llOIOO  : std_logic;
signal IO0I1111  : std_logic;

signal I10l0I01  : std_logic;
signal I1l0O10O  : std_logic;

signal I1O1011O  : std_logic_vector (width-1 downto 0);
signal I01OO00O  : std_logic_vector (width-1 downto 0);
signal OO0100O1  : std_logic_vector (width-1 downto 0);
signal O1O01I1I  : std_logic_vector (width-1 downto 0);
--------------------------------------------------------------------------------
-- Component declaration derived from dw/dw03/src/DW_pulseack_sync.vhdpp
--------------------------------------------------------------------------------
  component DW_pulseack_sync
  generic (
    reg_event   :     NATURAL range 0 to 1 := 1;
    reg_ack     :     NATURAL range 0 to 1 := 1;
    ack_delay   :     NATURAL range 0 to 1 := 1;
    f_sync_type :     NATURAL              := 2; 
    r_sync_type :     NATURAL              := 2; 
    tst_mode    :     NATURAL range 0 to 1 := 0; 
    verif_en    :     NATURAL range 0 to 4 := 1;
    pulse_mode  :     NATURAL range 0 to 3 := 0 
    ); 
  port (

    clk_s    : in std_logic;  -- clock  for source domain
    rst_s_n  : in std_logic;  -- active low async. reset in clk_s domain
    init_s_n : in std_logic;  -- active low sync. reset in clk_s domain
    event_s  : in std_logic;  -- event pulseack  (active high event)
    ack_s    : out std_logic;   -- source domain event acknowledge output
    busy_s   : out std_logic;   -- source domain busy status output

    clk_d    : in  std_logic;  -- clock  for destination domain
    rst_d_n  : in  std_logic;  -- active low async. reset in clk_d domain
    init_d_n : in  std_logic;  -- active low sync. reset in clk_d domain
    event_d  : out std_logic;  -- event pulseack output (active high event)

    test     : in  std_logic  -- test mode
   );
  end component;

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
  
    if ( (pend_mode < 0) OR (pend_mode > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter pend_mode (legal range: 0 to 1)"
        severity warning;
    end if;
  
    if ( (ack_delay < 0) OR (ack_delay > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter ack_delay (legal range: 0 to 1)"
        severity warning;
    end if;
  
    if ( (f_sync_type < 0) OR (f_sync_type > 4) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter f_sync_type (legal range: 0 to 4)"
        severity warning;
    end if;
  
    if ( (r_sync_type < 0) OR (r_sync_type > 4) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter r_sync_type (legal range: 0 to 4)"
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

 
-- Instance of DW_pulseack_sync
    U_DW_PA_SYNC : DW_pulseack_sync
      generic map (
        reg_event   =>  0,
        reg_ack     =>  0,
        ack_delay   =>  ack_delay,
        f_sync_type =>  f_sync_type,
        r_sync_type =>  r_sync_type,
        tst_mode    =>  tst_mode,
        verif_en    =>  verif_en,
        pulse_mode  =>  0
        )
      port map (
        clk_s    =>  clk_s,
        rst_s_n  =>  rst_s_n,
        init_s_n =>  init_s_n,
        event_s  =>  O1OIOOOI,
        clk_d    =>  clk_d,
        rst_d_n  =>  rst_d_n,
        init_d_n =>  init_d_n,
        test     =>  test,
        busy_s   =>  IOO1O01O,
        ack_s    =>  lOI1I00l,
        event_d  =>  lO110OlI
	);
--OO0100O1 <= data_s when OOlIO1I0 = 0 else O1O01I1I;

  process (clk_s, rst_s_n) begin
    if  (rst_s_n = '0')  then
      I1O1011O <= (others => '0');
      O1O01I1I <= (others => '0');
      OlOOl0l1   <= '0';
      O00Il110   <= '0';
      O1l010OO   <= '0';
      O1I1l10l     <= '0';
      I11I0l0I     <= '0';
    elsif (rst_s_n = '1') then
      if ( clk_s = '1' and clk_s'event )  then
        if ( init_s_n = '0')  then
          I1O1011O <= (others => '0');
          O1O01I1I <= (others => '0');
          OlOOl0l1   <= '0';
          O00Il110   <= '0';
          O1l010OO   <= '0';
          O1I1l10l     <= '0';
          I11I0l0I     <= '0';
        elsif ( init_s_n = '1')  then
          if(OOl101lO = '1') then
            I1O1011O <= OO0100O1;
          elsif (OOl101lO = '0') then
            I1O1011O <= I1O1011O;
          else
	    I1O1011O <= (others => 'X');
	  end if;
          if (OO1101OO = '1') then
            O1O01I1I <= (To_X01(data_s));
          elsif (OO1101OO = '0') then
            O1O01I1I <= O1O01I1I;
          else
	    O1O01I1I <= (others => 'X');
	  end if;
	  OlOOl0l1   <= send_s;
          O00Il110   <= I1llOIOO;
          O1l010OO   <= IO0I1111;
          O1I1l10l     <= O1111O11;
          I11I0l0I     <= O1l10OO0;
        else
          I1O1011O <= (others => 'X');
          O1O01I1I <= (others => 'X');
          OlOOl0l1   <= 'X';
          O00Il110   <= 'X';
          O1l010OO   <= 'X';
          O1I1l10l     <= 'X';
          I11I0l0I     <= 'X';
        end if;
      end if;
    else
      I1O1011O <= (others => 'X');
      O1O01I1I <= (others => 'X');
      OlOOl0l1   <= 'X';
      O00Il110   <= 'X';
      O1l010OO   <= 'X';
      O1I1l10l     <= 'X';
      I11I0l0I     <= 'X';
    end if;
  end process;

  process (clk_d, rst_d_n) begin
    if (rst_d_n = '0' ) then
       I01OO00O     <= (others => '0');
       I10l0I01 <= '0';
    elsif (rst_d_n = '1' ) then
      if (clk_d'event and clk_d = '1' ) then
        if (init_d_n = '0' ) then
          I01OO00O     <= (others => '0');
          I10l0I01 <= '0';
        elsif (init_d_n = '1' ) then
          if(I1l0O10O = '1') then
            I01OO00O   <= I1O1011O;
          elsif (I1l0O10O = '0') then
            I01OO00O   <= I01OO00O;
          else
            I01OO00O   <= (others => 'X');
  	  end if;
          I10l0I01 <= I1l0O10O;
        else
          I01OO00O     <= (others => 'X');
          I10l0I01 <= 'X';
        end if;
      end if;
    else
       I01OO00O     <= (others => 'X');
       I10l0I01 <= 'X';
    end if;
  end process;
  
  G1 : if(pend_mode = 1) generate 
    IO0I1111   <= ((O1I1l10l and O1l10OO0) and not lOI1I00l);
    I1llOIOO   <= (IOlIO1I1 or O1OIOOOI) or (not lOI1I00l and O00Il110)
                     or (lOI1I00l and I11I0l0I);
    O1111O11   <= (O1OIOOOI and not IOO1O01O) 
                     or (O1I1l10l and not lOI1I00l) 
                     or (lOI1I00l and I11I0l0I) 
		     or (I11I0l0I and not O1I1l10l);
    O1l10OO0   <= (IOlIO1I1 and not I11I0l0I and O1I1l10l) 
                     or (I11I0l0I and not lOI1I00l and O1I1l10l)--;
                     or (IOlIO1I1 and lOI1I00l and O1I1l10l); 
    OOl101lO   <= (IOlIO1I1 and not O1I1l10l and not O00Il110) 
                     or (lOI1I00l and I11I0l0I)
		     or (not O1I1l10l and I11I0l0I and not lOI1I00l);
    OO1101OO   <=  I1llOIOO and IOlIO1I1;
    data_s_kod   <=  (IOlIO1I1 and O1I1l10l and not I11I0l0I) 
                     or (not O1l10OO0 and lOI1I00l and IOlIO1I1)
		     or (IOlIO1I1 and lOI1I00l);
    OO0100O1   <= O1O01I1I when (I11I0l0I = '1') else (To_X01(data_s));
    O1OIOOOI      <= (IOlIO1I1 and not O1I1l10l) 
                     or (O1I1l10l and not IOO1O01O); 
  end generate;

  G2 : if(pend_mode = 0) generate
    O1111O11   <= (O1OIOOOI and not IOO1O01O)
                     or (O1I1l10l and not lOI1I00l);
    I1llOIOO   <= IOlIO1I1 or O1111O11;
    IO0I1111   <= IOlIO1I1 or O1111O11;
    OOlIO1I0  <= '0';
    OOl101lO   <= IOlIO1I1 and not IOO1O01O;
    OO0100O1   <= (To_X01(data_s));
    O1OIOOOI      <= IOlIO1I1;
  end generate;

  G3 : if(send_mode = 0) generate
    IOlIO1I1    <= send_s ;
  end generate; 
  G4 : if(send_mode = 1) generate
    IOlIO1I1    <= (send_s and not OlOOl0l1);-- xor send_tgl;
  end generate; 
  G5 : if(send_mode = 2) generate
    IOlIO1I1    <= (not send_s and OlOOl0l1);-- xor send_tgl;
  end generate; 
  G6 : if(send_mode = 3) generate
    IOlIO1I1    <= (send_s xor OlOOl0l1) ;--xor send_tgl;
  end generate; 

  O01OOI01   <= lOI1I00l;
  I1l0O10O   <= lO110OlI;

--outputs
  data_avail_d <= I10l0I01;
  data_d       <= I01OO00O;
  done_s       <= O01OOI01;
  empty_s      <= O00Il110;--s_nxt;--O00Il110;
  full_s       <= O1l010OO;--s_nxt;--O00Il110;
  
  
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
configuration DW_data_sync_cfg_sim of DW_data_sync is
 for sim
    for U_DW_PA_SYNC : DW_pulseack_sync use configuration dw03.DW_pulseack_sync_cfg_sim; end for;
 end for; -- sim
end DW_data_sync_cfg_sim;

library dw03;
configuration DW_data_sync_cfg_sim_ms of DW_data_sync is
 for sim
    for U_DW_PA_SYNC : DW_pulseack_sync use configuration dw03.DW_pulseack_sync_cfg_sim_ms; end for;
 end for; -- sim
end DW_data_sync_cfg_sim_ms;
-- pragma translate_on

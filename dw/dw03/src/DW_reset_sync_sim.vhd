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
-- AUTHOR:    Doug Lee    Dec 9, 2005
--
-- VERSION:   VHDL Simulation Model
--
-- DesignWare_version: 85b60afb
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
--
-- ABSTRACT: Reset Sequence Synchronizer
--
--           This synchronizer orchestrates a synchronous reset sequence between the source
--           and destination domains.
--
--              Parameters:     Valid Values
--              ==========      ============
--              f_sync_type     default: 2
--                              Forward Synchronized Type (Source to Destination Domains)
--                                0 = single clock design, no synchronizing stages implemented,
--                                1 = 2-stage synchronization w/ 1st stage neg-edge & 2nd stage pos-edge capturing,
--                                2 = 2-stage synchronization w/ both stages pos-edge capturing,
--                                3 = 3-stage synchronization w/ all stages pos-edge capturing
--                                4 = 4-stage synchronization w/ all stages pos-edge capturing
--              r_sync_type     default: 2
--                              Reverse Synchronization Type (Destination to Source Domains)
--                                0 = single clock design, no synchronizing stages implemented,
--                                1 = 2-stage synchronization w/ 1st stage neg-edge & 2nd stage pos-edge capturing,
--                                2 = 2-stage synchronization w/ both stages pos-edge capturing,
--                                3 = 3-stage synchronization w/ all stages pos-edge capturing
--                                4 = 4-stage synchronization w/ all stages pos-edge capturing
--              clk_d_faster    default: 1
--                              clk_d faster than clk_s by difference ratio
--                                0        = Either clr_s or clr_d active with the other tied low at input
--                                1 to 15  = ratio of clk_d to clk_s plus 1
--              reg_in_prog     default: 1
--                              Register the 'clr_in_prog_s' and 'clr_in_prog_d' Outputs
--                                0 = unregistered
--                                1 = registered
--              tst_mode        default: 0
--                              Test Mode Setting
--                                0 = no hold latch inserted,
--                                1 = insert hold 'latch' using a neg-edge triggered register
--                                2 = insert hold latch using active low latch
--              verif_en        default: 1
--                              Verification Enable (simulation only)
--                                0 = no sampling errors inserted,
--                                1 = sampling errors are randomly inserted with 0 or 1 destination clock cycle delays
--                                2 = sampling errors are randomly inserted with 0, 0.5, 1, or 1.5 destination clock cycle delays
--                                3 = sampling errors are randomly inserted with 0, 1, 2, or 3 destination clock cycle delays
--                                4 = sampling errors are randomly inserted with 0 or up to 0.5 destination clock cycle delays
--
--
-- MODIFIED:
--              DLL   5-7-15   (1) Restricted the amount of missampling allowed for DW_pulse_sync
--                                 U_PS_DEST to make delay more realistic.
--                             (2) Changed 'reg_event' from '1' to '0' for instance U_PS_DEST
--                                 to allow 'clr_in_prog_s' to occur one cycle earlier that
--                                 helps prevent a race condition on signals syncrhonized back
--                                 to the source domain.
--                              Addresses fix for STAR#9000896107 (filed against DW_fifoctl_2c_df but
--                              is really a DW_reset_sync issue).
--
--              DLL   7-22-11  Add inherent delay to the feedback path in the destination
--                             domain and clr_in_prog_d.  This effectively extends the 
--                             destination domain acive clearing state.
--                             Also added 'tst_mode = 2' capability.
--
--              DLL   9-5-08   Accommodate sustained "clr_s" and "clr_d" assertion behavior.
--                             Satisfies STAR#9000261751.
--
--              DLL   8-11-08  Filter long pulses of "clr_s" and "clr_d" to one
--                             clock cycle pulses.
--
--              DLL   6/14/06  Removed unnecessary To_X01 processing some input signals
--
--              DLL   8/21/06  Added parameters 'r_sync_type', 'clk_d_faster', 'reg_in_prog'.
--                             Added Destination outputs 'clr_in_prog_d' and 'clr_cmplt_d'
--                             and changed Source output 'clr_ack_s' to 'clr_cmplt_s'.
--
--              DLL   11/7/06  Modified functionality to support f_sync_type = 4 and
--                             r_sync_type = 4
--
--              DLL   11/21/06 Changed library reference in configuration block
--
--------------------------------------------------------------------------
 
library IEEE, DWARE;
use STD.textio.all;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_misc.all;
use DWARE.DWpackages.all;
use DWARE.DW_foundation_comp_arith.all;

architecture sim of DW_reset_sync is
	
-- pragma translate_off

  function calc_restricted_verif_en( given_verif_en : in INTEGER ) return INTEGER is
  begin
    if (given_verif_en = 2) then
      return ( 4 );
    elsif (given_verif_en = 3) then
      return ( 1 );
    else
      return( given_verif_en );
    end if;
  end calc_restricted_verif_en;

  signal O1O01I01                : std_logic_vector(0 downto 0);
  signal lOl0I0l1              : std_logic;
  signal l0OIlIO1             : std_logic_vector(0 downto 0);
  signal Il0110O1                 : std_logic;
  signal O010111l          : std_logic;
  signal OI01IO11           : std_logic;
  signal l10Ol00O        : std_logic;
  signal lO1O1011                : std_logic;

  signal I01O0111                : INTEGER := 0; 
  signal l1010110           : INTEGER := 0;
  signal O1111O0O        : std_logic;
  signal OOlIO1OO   : std_logic;
  signal lll0OO11          : std_logic;
  signal I0I0O1l1     : std_logic;

  signal l0Ol100I      : std_logic;
  signal Il1O110I           : std_logic;
  signal OOOOIlO1                : INTEGER := 0; 
  signal OI1IO11l           : INTEGER := 0;

  signal l11Ol01I          : std_logic;
  signal l00O0lO1           : std_logic;
  signal l011lO0l                : std_logic;
  signal O100OIlI        : std_logic;
  signal l0IlI00O   : std_logic;
  signal IIOOI0Ol     : std_logic;
  signal O1OOO1O0          : std_logic;
  signal O0OIl111     : std_logic;

  signal IOIOOIlO             : std_logic;
  signal OOI1001O      : std_logic;

  signal OO1OOO11                 : std_logic;
  signal O1OIOIIl          : std_logic;
  signal OI010O0I               : std_logic;
  signal OOI0OOlO             : std_logic;

  signal OlOOO000          : std_logic;
  signal IllIlOl0           : std_logic;
  signal I0OO1l01         : std_logic;
  signal lI1IO1O0          : std_logic;
  signal OO001I10               : std_logic;

  signal O0III10l            : std_logic;
  signal IO00llI0                 : std_logic;
  signal clr_s_int_cc             : std_logic_vector(0 downto 0);
  signal clr_s_int_l              : std_logic_vector(0 downto 0);

  constant O11OlI00 : INTEGER := (f_sync_type + 8);

  constant IOIOO0Il : INTEGER := (f_sync_type mod 8);

  constant O11OlO00 : INTEGER := (r_sync_type + 8);

  constant OO0IO0I1 : INTEGER := (r_sync_type mod 8);

  constant RESTRICTED_VERIF_EN : INTEGER := calc_restricted_verif_en( verif_en );

-- pragma translate_on

  begin
  -- pragma translate_off
    
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
     
    if ( (IOIOO0Il < 0) OR (IOIOO0Il > 4) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter IOIOO0Il (legal range: 0 to 4)"
        severity warning;
    end if;
     
    if ( (OO0IO0I1 < 0) OR (OO0IO0I1 > 4) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter OO0IO0I1 (legal range: 0 to 4)"
        severity warning;
    end if;
     
    if ( (reg_in_prog < 0) OR (reg_in_prog > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter reg_in_prog (legal range: 0 to 1)"
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
    
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;

    OOIl011l : process (clr_s, OO1OOO11, O1111O0O, l1010110, I01O0111, OI010O0I, OOI0OOlO)
      variable OO011Il0     : std_logic;
      variable O1l100l0   : std_logic;
      begin
        if (clk_d_faster /= 0) then
          if (((clr_s = '1') AND (OO1OOO11 = '0')) OR ((O1111O0O = '0') AND (clr_s = '1')) OR 
                              (((l1010110 = 1) AND (I01O0111 = 0)) AND (clr_s = '1'))) then
            OO011Il0 := '1';
          else
            OO011Il0 := '0';
          end if;
        else
          OO011Il0 := NOT(O1111O0O) AND clr_s;
        end if;

        if ((l1010110 = 0) AND (I01O0111 = 1)) then
          O1l100l0 := '1';
        else
          O1l100l0 := '0';
        end if; 

        if ((OO011Il0 = '1') AND
            (((clk_d_faster /= 0) AND ((OOI0OOlO = '1') OR (O1l100l0 = '0'))) OR 
             ((clk_d_faster = 0) AND (O1l100l0 = '0'))) )then
          O1OIOIIl <= '1';
        else
          if (O1l100l0 = '1') then
            O1OIOIIl <= '0';
          else
            O1OIOIIl <= OI010O0I;
          end if;
        end if;
    end process OOIl011l;

    OOI0OOlO     <= clr_s AND NOT(OI010O0I);


  O1O01I01(0) <= clr_s;


  frwd_hold_latch_PROC : process(clk_s, O1O01I01) begin
    if (clk_s = '0') then
      clr_s_int_l <= O1O01I01;
    end if;
  end process frwd_hold_latch_PROC;

  clr_s_int_cc <= clr_s_int_l when (((f_sync_type mod 8) > 1) AND (tst_mode = 2) AND (test = '1')) else O1O01I01;

  U_SYNC_SRC : DW_sync
    generic map (
	width => 1,
	f_sync_type => f_sync_type+8,
	tst_mode => tst_mode,
	verif_en => verif_en )
    port map (
	clk_d => clk_d,
	rst_d_n => rst_d_n,
	init_d_n => init_d_n,
	data_s => clr_s_int_cc,
	test => test,
	data_d => l0OIlIO1 );

  Il0110O1 <= l0OIlIO1(0);

  U_PS_SRC: DW_pulse_sync
    generic map (
      reg_event   => 1,
      f_sync_type => O11OlI00, 
      tst_mode    => tst_mode,
      verif_en    => verif_en,
      pulse_mode  => 1)
    port map (
      clk_s       => clk_s,
      rst_s_n     => rst_s_n,  
      init_s_n    => init_s_n,  
      event_s     => clr_s,
      clk_d       => clk_d,
      rst_d_n     => rst_d_n,  
      init_d_n    => init_d_n,  
      test        => test,  
      event_d     => lOl0I0l1);  

  O010111l <= lOl0I0l1 OR Il0110O1;

  U_PS_DEST: DW_pulse_sync
    generic map (
      reg_event   => 0,
      f_sync_type => O11OlO00, 
      tst_mode    => tst_mode,
      verif_en    => RESTRICTED_VERIF_EN,
      pulse_mode  => 0)
    port map (
      clk_s       => clk_d,
      rst_s_n     => rst_d_n,  
      init_s_n    => init_d_n,  
      event_s     => OOI1001O,
      clk_d       => clk_s,
      rst_d_n     => rst_s_n,  
      init_d_n    => init_s_n,  
      test        => test,  
      event_d     => OI01IO11);  

  U_PS_FB_TO_DEST: DW_pulse_sync
    generic map (
      reg_event   => 0,
      f_sync_type => O11OlI00, 
      tst_mode    => tst_mode,
      verif_en    => verif_en,
      pulse_mode  => 0)
    port map (
      clk_s       => clk_s,
      rst_s_n     => rst_s_n,  
      init_s_n    => init_s_n,  
      event_s     => l10Ol00O,
      clk_d       => clk_d,
      rst_d_n     => rst_d_n,  
      init_d_n    => init_d_n,  
      test        => test,  
      event_d     => l11Ol01I);  

  OO00Ol11 : process (l11Ol01I, IOIOOIlO, IO00llI0)
    begin
      if (l11Ol01I = '1' AND IOIOOIlO = '1') then
        O0III10l <= '1';
      elsif (l11Ol01I = '0' AND IOIOOIlO = '0' AND IO00llI0 = '1') then
        O0III10l <= '0';
      else
        O0III10l <= IO00llI0;
      end if;
    end process OO00Ol11;

  l00O0lO1 <= (l11Ol01I AND NOT(IOIOOIlO) AND NOT(IO00llI0)) OR
                        (NOT(l11Ol01I) AND NOT(IOIOOIlO) AND IO00llI0);

  U_PS_ACK: DW_pulse_sync
    generic map (
      reg_event   => 0,
      f_sync_type => O11OlO00, 
      tst_mode    => tst_mode,
      verif_en    => verif_en,
      pulse_mode  => 0)
    port map (
      clk_s       => clk_d,
      rst_s_n     => rst_d_n,  
      init_s_n    => init_d_n,  
      event_s     => l011lO0l,
      clk_d       => clk_s,
      rst_d_n     => rst_s_n,  
      init_d_n    => init_s_n,  
      test        => test,  
      event_d     => lO1O1011);  


    O0O1O1l0: process (OI01IO11, lO1O1011, I01O0111)
      begin
        if ((OI01IO11 = 'X') OR (lO1O1011 = 'X')) then
	  l1010110 <= -1;
        elsif ((OI01IO11 = '1') AND (lO1O1011 = '0')) then
	  if (I01O0111 = 2) then
	    l1010110 <= I01O0111;
	  else
	    l1010110 <= I01O0111 + 1;
          end if;
	elsif ((OI01IO11 = '0') AND (lO1O1011 = '1')) then
	  if (I01O0111 = 0) then
	    l1010110 <= I01O0111;
	  else
	    l1010110 <= I01O0111 - 1;
          end if;
        else
	  l1010110 <= I01O0111;
	end if;
    end process O0O1O1l0;

    O10OOIOO: process (l1010110)
      begin
        if (l1010110 > 0) then
          OOlIO1OO <= '1';
        elsif (l1010110 = 0) then
          OOlIO1OO <= '0';
        else
          OOlIO1OO <= 'X';
        end if;
    end process O10OOIOO;

    I0I0O1l1 <= '1' when (lO1O1011 = '1') AND (l1010110 = 0) AND (I01O0111 = 1) else '0';


    II0lO1O1: process (clk_s, rst_s_n)
      begin
        if (rst_s_n = '0') then
          OO1OOO11             <= '0';
          OI010O0I           <= '0';
          I01O0111            <= 0;
          l10Ol00O    <= '0';
	  O1111O0O    <= '0';
	  lll0OO11      <= '0';
        elsif (rst_s_n = '1') then
	  if (rising_edge(clk_s)) then
	    if (init_s_n = '0') then
              OO1OOO11             <= '0';
              OI010O0I           <= '0';
              I01O0111            <= 0;
              l10Ol00O    <= '0';
	      O1111O0O    <= '0';
	      lll0OO11      <= '0';
	    elsif (init_s_n = '1') then
              OO1OOO11             <= clr_s;
              OI010O0I           <= O1OIOIIl;
              I01O0111            <= l1010110;
              l10Ol00O    <= OI01IO11;
	      O1111O0O    <= OOlIO1OO;
	      lll0OO11      <= I0I0O1l1;
            else
              OO1OOO11             <= 'X';
              OI010O0I           <= 'X';
              I01O0111            <= -1;
              l10Ol00O    <= 'X';
	      O1111O0O    <= 'X';
	      lll0OO11      <= 'X';
	    end if;
          else
            OO1OOO11             <= OO1OOO11;
            OI010O0I           <= OI010O0I;
            I01O0111            <= I01O0111;
	    O1111O0O    <= O1111O0O;
  	    lll0OO11      <= lll0OO11;
	  end if;
	else
          OO1OOO11             <= 'X';
          OI010O0I           <= 'X';
          I01O0111            <= -1;
	  O1111O0O    <= 'X';
	  lll0OO11      <= 'X';
	end if;

    end process;

    -- Assign to signals
    clr_sync_s     <= OI01IO11;
    clr_in_prog_s  <= OOlIO1OO when (reg_in_prog = 0) else O1111O0O;
    clr_cmplt_s    <= lll0OO11;


    lIOIOl1O : process (clr_d, OlOOO000, O100OIlI, OI1IO11l, OOOOIlO1, OO001I10)
      variable IllIlOl0     : std_logic;
      variable I0OO1l01   : std_logic;
      begin
        if (reg_in_prog = 0) then
          if (((clr_d = '1') AND (OlOOO000 = '0')) OR (((OI1IO11l = 1) AND (OOOOIlO1 = 0)) AND (IOIOOIlO = '1'))) then
            IllIlOl0 := '1';
          else
            IllIlOl0 := '0';
          end if;
        else
          if ((OI1IO11l = 1) AND (OOOOIlO1 = 0)) then
            IllIlOl0 := '1';
          else
            IllIlOl0 := '0';
          end if;
        end if;

        if ((OI1IO11l = 0) AND (OOOOIlO1 = 1)) then
         I0OO1l01 := '1';
        else
         I0OO1l01 := '0';
        end if;

        if ((IllIlOl0 = '1') AND (I0OO1l01 = '0')) then
          lI1IO1O0 <= '1';
        else
          if (I0OO1l01 = '1') then
            lI1IO1O0 <= '0';
          else
            lI1IO1O0 <= OO001I10;
          end if;
        end if;
    end process lIOIOl1O;


    IOIOOIlO             <= O010111l OR clr_d;     
    OOI1001O      <= IOIOOIlO AND NOT(OO001I10);
    clr_sync_d               <= Il1O110I;

    OlO11OO0: process (OOI1001O, l011lO0l, OOOOIlO1)
      begin
        if ((OOI1001O = 'X') OR (l011lO0l = 'X')) then
          OI1IO11l <= -1;
        elsif ((OOI1001O = '1') AND (l011lO0l = '0')) then
	  if (OOOOIlO1 = 2) then
	    OI1IO11l <= OOOOIlO1;
	  else
	    OI1IO11l <= OOOOIlO1 + 1;
          end if;
	elsif ((OOI1001O = '0') AND (l011lO0l = '1')) then
	  if (OOOOIlO1 = 0) then
	    OI1IO11l <= OOOOIlO1;
	  else
	    OI1IO11l <= OOOOIlO1 - 1;
          end if;
        else
	  OI1IO11l <= OOOOIlO1;
	end if;
    end process OlO11OO0;

    O1lO000O: process (OI1IO11l)
      begin
        if (OI1IO11l > 0) then
	  l0IlI00O <= '1';
        elsif (OI1IO11l = 0) then
	  l0IlI00O <= '0';
        else
	  l0IlI00O <= 'X';
        end if;
    end process O1lO000O;

    O0OIl111 <= NOT(O100OIlI) AND IIOOI0Ol;


    l1O1O100: process (clk_d, rst_d_n)
      begin
        if (rst_d_n = '0') then
          OlOOO000      <= '0';
          OO001I10           <= '0';
          IO00llI0             <= '0';
          OOOOIlO1            <= 0;
          l011lO0l            <= '0';
	  Il1O110I       <= '0';
          O100OIlI    <= '0';
          IIOOI0Ol <= '0';
          O1OOO1O0      <= '0';
        elsif (rst_d_n = '1') then
	  if (rising_edge(clk_d)) then
	    if (init_d_n = '0') then
              OlOOO000      <= '0';
              OO001I10           <= '0';
              IO00llI0             <= '0';
              OOOOIlO1            <= 0;
              l011lO0l            <= '0';
	      Il1O110I       <= '0';
              O100OIlI    <= '0';
              IIOOI0Ol <= '0';
              O1OOO1O0      <= '0';
	    elsif (init_d_n = '1') then
              OlOOO000      <= IOIOOIlO;
              OO001I10           <= lI1IO1O0;
              IO00llI0             <= O0III10l;
              OOOOIlO1            <= OI1IO11l;
              l011lO0l            <= l00O0lO1;
	      Il1O110I       <= l00O0lO1 AND NOT(OOI1001O);
              O100OIlI    <= l0IlI00O;
              IIOOI0Ol <= O100OIlI;
              O1OOO1O0      <= O0OIl111;
            else
              OlOOO000      <= 'X';
              OO001I10           <= 'X';
              IO00llI0             <= 'X';
              OOOOIlO1            <= -1;
              l011lO0l            <= 'X';
	      Il1O110I       <= 'X';
              O100OIlI    <= 'X';
              IIOOI0Ol <= 'X';
              O1OOO1O0      <= 'X';
	    end if;
          else
            OlOOO000      <= OlOOO000;
            OO001I10           <= OO001I10;
            IO00llI0             <= IO00llI0;
            OOOOIlO1            <= OOOOIlO1;
            l011lO0l            <= l011lO0l;
	    Il1O110I       <= Il1O110I;
            O100OIlI    <= O100OIlI;
            IIOOI0Ol <= IIOOI0Ol;
            O1OOO1O0      <= O1OOO1O0;
	  end if;
	else
          OlOOO000      <= 'X';
          OO001I10           <= 'X';
          IO00llI0             <= 'X';
          OOOOIlO1            <= -1;
          l011lO0l            <= 'X';
	  Il1O110I       <= 'X';
          O100OIlI    <= 'X';
          IIOOI0Ol <= 'X';
          O1OOO1O0      <= 'X';
	end if;

    end process;

    clr_sync_d     <= Il1O110I;
    clr_in_prog_d  <= O100OIlI when (reg_in_prog = 0) else  IIOOI0Ol;
    clr_cmplt_d    <= O1OOO1O0;


    
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
      constant method_str : STRING := " is the DW_reset_sync Clock Domain Crossing Module ***";

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
configuration DW_reset_sync_cfg_sim_ms of DW_reset_sync is
 for sim
  for U_PS_SRC: DW_pulse_sync use configuration dw03.DW_pulse_sync_cfg_sim_ms; end for;
  for U_PS_DEST: DW_pulse_sync use configuration dw03.DW_pulse_sync_cfg_sim_ms; end for;
  for U_PS_FB_TO_DEST: DW_pulse_sync use configuration dw03.DW_pulse_sync_cfg_sim_ms; end for;
  for U_PS_ACK: DW_pulse_sync use configuration dw03.DW_pulse_sync_cfg_sim_ms; end for;
 end for; -- sim
end DW_reset_sync_cfg_sim_ms;

library dw03;
configuration DW_reset_sync_cfg_sim of DW_reset_sync is
 for sim
  for U_PS_SRC: DW_pulse_sync use configuration dw03.DW_pulse_sync_cfg_sim; end for;
  for U_PS_DEST: DW_pulse_sync use configuration dw03.DW_pulse_sync_cfg_sim; end for;
  for U_PS_FB_TO_DEST: DW_pulse_sync use configuration dw03.DW_pulse_sync_cfg_sim; end for;
  for U_PS_ACK: DW_pulse_sync use configuration dw03.DW_pulse_sync_cfg_sim; end for;
 end for; -- sim
end DW_reset_sync_cfg_sim;
-- pragma translate_on

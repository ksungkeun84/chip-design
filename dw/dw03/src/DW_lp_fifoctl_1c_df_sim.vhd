--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2007 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Doug Lee    June 14, 2007
--
-- VERSION:   VHDL Simulation Model
--
-- DesignWare_version: 3a684759
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT: Simulation model for Low Power Single-clock FIFO Controller with Caching and Dynamic Flags
--
--           This FIFO controller is designed to interface to synchronous
--           dual port synchronous RAMs.  It contains word caching (pop
--           interface) and status flags that are dynamically configured.
--
--
--      Parameters     Valid Values   Description
--      ==========     ============   ===========
--      width           1 to 4096     default: 8
--                                    Width of data to/from RAM
--
--      depth         4 to 268435456  default: 8
--                                    Depth of the FIFO (includes RAM, cache, and write re-timing stage)
--
--      mem_mode         0 to 7       default: 3
--                                    Defines where and how many re-timing stages used in RAM:
--                                      0 => no pre or post retiming
--                                      1 => RAM data out (post) re-timing
--                                      2 => RAM read address (pre) re-timing
--                                      3 => RAM data out and read address re-timing
--                                      4 => RAM write interface (pre) re-timing
--                                      5 => RAM write interface and RAM data out re-timing
--                                      6 => RAM write interface and read address re-timing
--                                      7 => RAM write interface, read address, and read address re-timing
--
--      arch_type        0 to 4       default: 1
--                                    Datapath architecture configuration
--                                      0 => no input re-timing, no pre-fetch cache
--                                      1 => no input re-timing, pre-fetch pipeline cache
--                                      2 => input re-timing, pre-fetch pipeline cache
--                                      3 => no input re-timing, pre-fetch register file cache
--                                      4 => input re-timing, pre-fetch register file cache
--
--      af_from_top      0 or 1       default: 1
--                                    Almost full level input (af_level) usage
--                                      0 => the af_level input value represents the minimum
--                                           number of valid FIFO entries at which the almost_full
--                                           output starts being asserted
--                                      1 => the af_level input value represents the maximum number
--                                           of unfilled FIFO entries at which the almost_full
--                                           output starts being asserted
--
--      ram_re_ext       0 or 1       default: 0
--                                    Determines the charateristic of the ram_re_n signal to RAM
--                                      0 => Single-cycle pulse of ram_re_n at the read event to RAM
--                                      1 => Extend assertion of ram_re_n while read event active in RAM
--
--      err_mode         0 or 1       default: 0
--                                    Error Reporting Behavior
--                                      0 => sticky error flag
--                                      1 => dynamic error flag
--
--
--
--      Inputs           Size       Description
--      ======           ====       ===========
--      clk                1        Clock
--      rst_n              1        Asynchronous reset (active low)
--      init_n             1        Synchronous reset (active low)
--      ae_level           N        Almost empty threshold setting (for the almost_empty output)
--      af_level           N        Almost full threshold setting (for the almost_full output)
--      level_change       1        Almost empty and/or almost full level is being changed (active high pulse)
--      push_n             1        Push request (active low)
--      data_in            M        Data input
--      pop_n              1        Pop request (active low)
--      rd_data            M        Data read from RAM
--
--
--      Outputs          Size       Description
--      =======          ====       ===========
--      ram_we_n           1        Write enable to RAM (active low)
--      wr_addr            P        Write address to RAM (registered)
--      wr_data            M        Data written to RAM
--      ram_re_n           1        Read enable to RAM (active low)
--      rd_addr            P        Read address to RAM (registered)
--      data_out           M        Data output
--      word_cnt           N        FIFO word count
--      empty              1        FIFO empty flag
--      almost_empty       1        Almost empty flag (determined by ae_level input)
--      half_full          1        Half full flag
--      almost_full        1        Almost full flag (determined by af_level input)
--      full               1        Full flag
--      error              1        Error flag (overrun or underrun)
--
--
--           Note: M is equal to the "width" parameter
--
--           Note: N is based on "depth":
--                   N = ceil(log2(depth+1))
--
--           Note: P is ceil(log2(ram_depth)) (see Note immediately below about "ram_depth")
--
--           Note: "ram_depth" is not a parameter but is based on parameter
--                 "depth", "mem_mode", and "arch_type":
--
--                  If arch_type is '0', then:
--                       ram_depth = depth.
--                  If arch_type is '1' or '3', then:
--                       ram_depth = depth-1 when mem_mode = 0
--                       ram_depth = depth-2 when mem_mode = 1, 2, 4, or 6
--                       ram_depth = depth-3 when mem_mode = 3, 5, or 7
--                  If arch_type is '2' or '4', then:
--                       ram_depth = depth-2 when mem_mode = 0
--                       ram_depth = depth-3 when mem_mode = 1, 2, 4, or 6
--                       ram_depth = depth-4 when mem_mode = 3, 5, or 7
--
--
-- MODIFIED: 
--          DLL - 2/3/11
--          Added parameter legality checking for illegal value combinations
--          of arch_type and mem_mode.
--          This fix addresses STAR#9000446050.
--
---------------------------------------------------------------------------------
--
library IEEE,DWARE;
use STD.textio.all;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_misc.all;
use DWARE.DWpackages.all;
use DWARE.DW_foundation_comp_arith.all;

architecture sim of DW_lp_fifoctl_1c_df is
	
-- pragma translate_off

function IO011OO1( depth, mem_mode, arch_type : in INTEGER ) return INTEGER is
begin
 if ( arch_type = 0 ) then
   return( depth );
 elsif ( (arch_type = 1) OR (arch_type = 3) ) then
   if ( mem_mode = 0 ) then
     return ( depth - 1 );
   elsif ( (mem_mode = 3) OR (mem_mode = 5) OR (mem_mode = 7) ) then
     return ( depth - 3 );
   else
     return ( depth - 2 );
   end if;
 else
   if ( mem_mode = 0 ) then
     return ( depth - 2 );
   elsif ( (mem_mode = 3) OR (mem_mode = 5) OR (mem_mode = 7) ) then
     return ( depth - 4 );
   else
     return ( depth - 3 );
   end if;
 end if;
end IO011OO1;

function IOl0OIII( O0lOI0O1 : in INTEGER ) return INTEGER is
variable l0IO00O0       : INTEGER := 0;
variable vect    : std_logic_vector(31 downto 0);
variable cnt     : INTEGER := 0;
begin
  vect := CONV_STD_LOGIC_VECTOR(O0lOI0O1, 32);
  for l0IO00O0 in 0 to 31 loop
    if (vect(l0IO00O0) = '1') then
      cnt := cnt + 1;
    end if;
  end loop;
  if ( cnt = 1 ) then
    return ( 1 );
  else
    return ( 0 );
  end if;
end IOl0OIII; 


constant O0lOI0O1           : INTEGER := IO011OO1(depth, mem_mode, arch_type);
constant O0O1O00I        : INTEGER := O0lOI0O1 - 1;
constant lOOOI110      : INTEGER := bit_width(O0lOI0O1);
constant OOOl01O1       : INTEGER := bit_width(O0lOI0O1+1);
constant DW_O0I10OIO       : INTEGER := bit_width(depth);
constant l110l0l1           : INTEGER := bit_width(depth+1);
constant Il10Il1O         : INTEGER := 1+(mem_mode mod 2)+(mem_mode/2)-(mem_mode/4)-(mem_mode/6);
constant IOlIOlO0              : INTEGER := IOl0OIII(O0lOI0O1);
constant OIl10010              : std_logic_vector(lOOOI110-1 downto 0) := (others => '0');
constant O11O1111     : std_logic_vector(31 downto 0) := std_logic_vector(CONV_UNSIGNED(mem_mode, 32));


type O101O1OO is array (0 to 2) of
         std_logic_vector(width-1 downto 0);

type O1I011OI is array (0 to 2) of
         std_logic_vector(DW_O0I10OIO-1 downto 0);


signal OO1l1lI1            : std_logic; 
signal I1l10lOl                  : std_logic;


signal O1IO0II1           : std_logic_vector(width-1 downto 0);
signal Il11Ol10   : std_logic_vector(width-1 downto 0);
signal O10110OI        : std_logic_vector(width-1 downto 0);
signal IO10O1Ol           : std_logic_vector(width-1 downto 0);
signal OI01O00O        : std_logic_vector(width-1 downto 0);

signal OOlOllOO           : std_logic_vector(lOOOI110-1 downto 0);
signal O0IO01lI     : integer := 0;
signal IlO10lI1          : integer := 0;
signal l100O001                : std_logic_vector(DW_O0I10OIO-1 downto 0);
signal OIOIOOOl        : std_logic_vector(DW_O0I10OIO-1 downto 0);
signal II1111OI             : std_logic_vector(DW_O0I10OIO-1 downto 0);
signal l1001lIO         : std_logic_vector(DW_O0I10OIO-1 downto 0);
signal I0ll01O0            : std_logic_vector(DW_O0I10OIO-1 downto 0);
signal I10O0IOl     : std_logic_vector(DW_O0I10OIO-1 downto 0);
signal O1l0O011        : O1I011OI;
signal I0OO0IIl             : O1I011OI;

signal l1O0O01O                   : std_logic;
signal I0IIO0I1           : std_logic;
signal IOOI11O0           : std_logic;

signal O0OOII0O          : std_logic;
signal Ol11lOOO          : std_logic;
signal O10I1O1l       : std_logic;
signal Ol1I0I11     : integer := 0;
signal lI1I0Ol0          : integer := 0;
signal OOOOOl0O       : integer := 0;
signal I01ll0O1                : std_logic_vector(lOOOI110 downto 0);
signal O0O1O1l1           : std_logic_vector(lOOOI110-1 downto 0);
signal I11O10O0           : std_logic_vector(lOOOI110-1 downto 0);
signal l0O1O10O        : std_logic_vector(lOOOI110-1 downto 0);
signal IOOl0IlI          : std_logic;
signal O1l00OOI     : integer := 0;
signal O01I100l          : integer := 0;
signal IO0IO1O0                : std_logic_vector(lOOOI110 downto 0);
signal I00I0I1O           : std_logic_vector(lOOOI110-1 downto 0);

signal ll0OOI00    : integer := 0;
signal OlOlI111         : integer := 0;

signal OlII10O1       : std_logic;
signal OI111l11   : integer := 0;
signal l01IOOl0        : integer := 0;

signal I0O101Ol          : std_logic;
signal l1O01100    : std_logic;
signal lll000Il : std_logic;
signal O01l10lI      : std_logic;
signal IOO00OlO : std_logic;
signal O010I0Ol             : std_logic;
signal lO1OO1Ol      : std_logic_vector(width-1 downto 0);
signal OI1lO1I0       : std_logic_vector(DW_O0I10OIO-1 downto 0);

signal l1OOI000          : std_logic;

signal OO0O11OO        : std_logic;
signal I10I10O1             : std_logic;
signal OO0Ol11I          : std_logic;
signal OOIO10O1               : std_logic;
signal I11O0O00            : std_logic;
signal I1O0OO11          : std_logic;
signal IlOO00OI               : std_logic_vector(1 downto 0);
signal l0OlOI0O          : std_logic_vector(1 downto 0);

signal O01III00            : std_logic_vector(2 downto 0);
signal OI10O0l0                 : std_logic_vector(2 downto 0);
signal O00I000I           : std_logic_vector(width-1 downto 0);
signal l0OOO01I            : O101O1OO;
signal O01lI10I       : O101O1OO;

signal l0OOOl0O             : std_logic;
signal l0llI101          : std_logic;
signal lI1I1O0O         : std_logic;
signal OOO111OI    : std_logic;
signal OO11IOO0         : std_logic;

signal lOO0O011             : std_logic;
signal O010OO0O          : std_logic;
signal OO10O101      : std_logic;
signal Ol00IO01 : std_logic;
signal IlOIlIO0         : std_logic;
signal OlO1O11O       : std_logic;
signal O1OI0O11  : std_logic;
signal l1O10OOO              : std_logic;

signal O00II10O            : std_logic;
signal l0I1I1OO             : std_logic;
signal lI1lI110        : std_logic;

signal OOl00001        : std_logic;
signal OI1l111O       : std_logic;
signal I011lOOO       : std_logic;

signal lII10OI1    : std_logic;
signal OOl11l0I    : std_logic;
signal OIOOOlOO       : std_logic_vector(1 downto 0);
signal OI0O011O      : std_logic;
signal O1lI001O      : std_logic;

signal OOl111O1     : std_logic;
signal O11lOO10     : std_logic;
signal llO00O1l     : std_logic;
signal OOOOlO11        : std_logic_vector(2 downto 0);
signal II00I10I       : std_logic;
signal l1l0OllO       : std_logic;

signal ll011101     : std_logic;
signal l00I0IO0     : std_logic;
signal O100000O        : std_logic_vector(1 downto 0);
signal ll000l0I       : std_logic;
signal OI010l01       : std_logic;

signal l01l010I     : std_logic;
signal O0lI00I1     : std_logic;
signal l0O0l0O1     : std_logic;
signal lOO1lO01        : std_logic_vector(2 downto 0);
signal Il0OI111       : std_logic;
signal OOO0O00O       : std_logic;

signal II0111O0     : std_logic;
signal OO11I0OO     : std_logic;
signal O1O0lIOI        : std_logic_vector(1 downto 0);
signal I010I0Ol       : std_logic;
signal I10O1l10       : std_logic;

signal lO0111Ol     : std_logic;
signal O0011Ill     : std_logic;
signal O01I1I0I     : std_logic;
signal O0000O1I        : std_logic_vector(2 downto 0);
signal O1I0I0l1       : std_logic;
signal O000OO1l       : std_logic;

signal I1OOO0OO          : std_logic_vector(DW_O0I10OIO-1 downto 0);
signal O111001l         : std_logic;


constant lI10l0IO : INTEGER := 1;
-- #include "$SRCROOT/dware/dw/dw06/src/DW_ram_r_w_2c_dff_sim_vhd.h"
  type lO1O00I0 is array (0 to O0lOI0O1-1) of
			  std_logic_vector(DW_O0I10OIO-1 downto 0);

  constant IO0III1O : std_logic_vector(DW_O0I10OIO-1 downto 0) := (others => '0');
  constant OOI0OOIO   : std_logic_vector(DW_O0I10OIO-1 downto 0) := (others => 'X');

  signal   I1O0101l	: lO1O00I0;

  constant O1IlOlI1 : lO1O00I0 := (others => IO0III1O);
  constant lOI00Ol1   : lO1O00I0 := (others => OOI0OOIO);

  signal   OI0Il000	: std_logic;
  signal   OOOIO0OO	: std_logic_vector(lOOOI110-1 downto 0);
  signal   I1OlOOIO	: std_logic_vector(DW_O0I10OIO-1 downto 0);

  signal   l10IlI11	: std_logic;
  signal   I011l101	: std_logic_vector(lOOOI110-1 downto 0);

  signal   OOl1llOO	: std_logic;
  signal   Il0100O0	: std_logic_vector(lOOOI110-1 downto 0);
  signal   O1lOO10O	: std_logic_vector(DW_O0I10OIO-1 downto 0);
  signal   O00OOI01	: std_logic;
  signal   Ol001110	: std_logic_vector(lOOOI110-1 downto 0);
  signal   lOI0IO1O	: std_logic_vector(DW_O0I10OIO-1 downto 0);

  signal   I1O0110l	: std_logic;
  signal   lO1I0OlI	: std_logic_vector(DW_O0I10OIO-1 downto 0);
-- pragma translate_on
 
begin
-- pragma translate_off

  lOI0IO1O <= (others => 'X') WHEN (Is_X(O00OOI01) or Is_X(Ol001110)) else
		  (others => '0') WHEN (CONV_INTEGER(UNSIGNED(Ol001110)) >= O0lOI0O1) else
		    I1O0101l((CONV_INTEGER(UNSIGNED(Ol001110))));
  
  
  OI01I01l : process( clk, rst_n ) begin
    
    if (rst_n = '0') AND (lI10l0IO = 0) then
      I1O0101l <= O1IlOlI1;
    elsif (rst_n = '1') OR (lI10l0IO = 1) then
      if rising_edge(clk) then
	if (init_n = '0') AND (lI10l0IO = 0) then
	  I1O0101l <= O1IlOlI1;
	elsif (init_n = '1') OR (lI10l0IO = 1) then
	  if (OOl1llOO = '1') then
	    if Is_X(Il0100O0) then
	      I1O0101l <= lOI00Ol1;
	    else
	      if (CONV_INTEGER(UNSIGNED(Il0100O0)) < O0lOI0O1) then
		I1O0101l( CONV_INTEGER(UNSIGNED(Il0100O0)) ) <=
			    To_X01( O1lOO10O );
	      end if;
	    end if;
	  elsif (OOl1llOO /= '0') then
	    if (Is_X(Il0100O0)) then
	      I1O0101l <= lOI00Ol1;
	    else
	      I1O0101l( CONV_INTEGER(UNSIGNED(Il0100O0)) ) <= (others => 'X');
	    end if;
	  end if;
	else
	  I1O0101l <= lOI00Ol1;
	end if;
      end if;
    else
      I1O0101l <= lOI00Ol1;
    end if;

  end process OI01I01l;

  G1A : if (mem_mode > 3) generate
    retime_w_inputs_PROC : process (clk, rst_n) begin
      if (rst_n = '0') then
	OI0Il000   <= '0';
	OOOIO0OO <= (others => '0');
        I1OlOOIO <= IO0III1O;
      elsif (rst_n = '1') then
        if rising_edge(clk) then
	  if (init_n = '0') then
	    OI0Il000   <= '0';
	    OOOIO0OO <= (others => '0');
	    I1OlOOIO <= IO0III1O;
	  elsif (init_n = '1') then
	    OI0Il000 <= NOT O0OOII0O;
	    if (O0OOII0O = '0') then
	      OOOIO0OO <= O0O1O1l1;
	      I1OlOOIO <= I10O0IOl;
	    elsif (O0OOII0O /= '1') then
	      OOOIO0OO <= (others => 'X');
	      I1OlOOIO <= OOI0OOIO;
	    end if;
	  else
	    OI0Il000   <= 'X';
	    OOOIO0OO <= (others => 'X');
	    I1OlOOIO <= OOI0OOIO;
	  end if;
	end if;
      else
	OI0Il000   <= 'X';
	OOOIO0OO <= (others => 'X');
	I1OlOOIO <= OOI0OOIO;
      end if;
    end process retime_w_inputs_PROC;

    Il0100O0 <= OOOIO0OO;
    OOl1llOO <= OI0Il000;
    O1lOO10O <= I1OlOOIO;
  end generate G1A;
  

  G1B : if (mem_mode <= 3) generate
    Il0100O0 <= O0O1O1l1;
    OOl1llOO <= NOT O0OOII0O;
    O1lOO10O <= I10O0IOl;
  end generate G1B;
  
  
  G2A : if ((mem_mode mod 4) > 1) generate
    retime_r_inputs_PROC : process (clk, rst_n) begin
      if (rst_n = '0') then
	l10IlI11   <= '0';
	I011l101 <= (others => '0');
      elsif (rst_n = '1') then
        if rising_edge(clk) then
	  if (init_n = '0') then
	    l10IlI11   <= '0';
	    I011l101 <= (others => '0');
	  elsif (init_n = '1') then
	    l10IlI11 <= NOT I1O0OO11;
	    if (I1O0OO11 = '0') then
	      I011l101 <= OOlOllOO;
	    elsif (I1O0OO11 /= '1') then
	      I011l101 <= (others => 'X');
	    end if;
	  else
	    l10IlI11   <= 'X';
	    I011l101 <= (others => 'X');
	  end if;
	end if;
      else
	l10IlI11   <= 'X';
	I011l101 <= (others => 'X');
      end if;
    end process retime_r_inputs_PROC;

    O00OOI01 <= l10IlI11;
    Ol001110 <= I011l101;
  end generate G2A;


  G2B : if ((mem_mode mod 4) <= 1) generate
    O00OOI01 <= NOT I1O0OO11;
    Ol001110 <= OOlOllOO;
  end generate G2B;
  
  
  G3A : if ((mem_mode mod 2) = 1) generate
    retime_r_outputs_PROC : process (clk, rst_n) begin
      if (rst_n = '0') then
	I1O0110l <= '0';
	lO1I0OlI <= (others => '0');
      elsif (rst_n = '1') then
        if rising_edge(clk) then
	  if (init_n = '0') then
	    I1O0110l   <= '0';
	    lO1I0OlI <= (others => '0');
	  elsif (init_n = '1') then
	    I1O0110l <= O00OOI01;
	    if (O00OOI01 = '1') then
	      lO1I0OlI <= lOI0IO1O;
	    elsif (O00OOI01 /= '0') then
	      lO1I0OlI <= (others => 'X');
	    end if;
	  else
	    I1O0110l  <= 'X';
	    lO1I0OlI <= (others => 'X');
	  end if;
	end if;
      else
	I1O0110l  <= 'X';
	lO1I0OlI <= (others => 'X');
      end if;
    end process retime_r_outputs_PROC;

    I1OOO0OO <= lO1I0OlI;
    O111001l <= I1O0110l;
  end generate G3A;


  G3B : if ((mem_mode mod 2) = 0) generate
    I1OOO0OO <= lOI0IO1O;
    O111001l <= O00OOI01;
  end generate G3B;





  OO1l1lI1     <= NOT(push_n) AND (NOT(l1O10OOO) OR (l1O10OOO AND NOT(pop_n)));
  l1O0O01O            <= NOT(pop_n) AND NOT(lOO0O011);

  OO01OOOO : process (data_in)
  begin
    for bit_idx in 0 to width-1 loop
      O1IO0II1(bit_idx) <= To_X01(data_in(bit_idx)); -- convert any X's
    end loop;
  end process OO01OOOO;

  Il11Ol10  <= O1IO0II1 when (OO1l1lI1 = '1') else O10110OI;
  OIOIOOOl       <= l100O001 when (OO1l1lI1 = '1') else II1111OI;

  I0O100lO : process (IlO10lI1, OO1l1lI1)
  begin
    if (OO1l1lI1 = '1') then
      if (IlO10lI1 = depth-1) then
        O0IO01lI <= 0;
      else
        O0IO01lI <= IlO10lI1+1;
      end if;
    else
      O0IO01lI <= IlO10lI1;
    end if;
  end process I0O100lO;
  l100O001            <= std_logic_vector(CONV_UNSIGNED(IlO10lI1, DW_O0I10OIO));

  O0l0I000 : process (l01IOOl0, pop_n)
  begin
    if ((l01IOOl0 = 0) OR ((l01IOOl0 = 1) AND (pop_n = '0'))) then  
      I0O101Ol <= '1';
    else
      I0O101Ol <= '0';
    end if;
  end process O0l0I000;
  lll000Il  <= I0O101Ol AND OO1l1lI1;
  O01l10lI         <= I10I10O1 AND NOT(l1O01100);
  O010I0Ol                <= OO1l1lI1 when (lll000Il = '1') else 
                                (O01l10lI AND (NOT(l1O10OOO) OR (l1O10OOO AND NOT(pop_n))));
  lO1OO1Ol         <= O1IO0II1 when (lll000Il = '1') else O10110OI;
  OI1lO1I0          <= l100O001 when (lll000Il = '1') else II1111OI;

  IIO1O10O : process (l1O10OOO, pop_n, I10I10O1, OO1l1lI1)
  begin
    if ((arch_type mod 2) = 0) then
      if ((l1O10OOO = '1') AND (pop_n = '1')) then
        OO0O11OO <= I10I10O1;
      else
        OO0O11OO <= OO1l1lI1;
      end if;
    else
      OO0O11OO <= '0';
    end if;
  end process IIO1O10O;
  IOO00OlO    <= OO0O11OO AND NOT(lll000Il);


  OI1l110O : process (push_n, O010I0Ol, l1O10OOO, pop_n)
  begin
    if ((l1O10OOO = '0') OR (pop_n = '0')) then
      if ((arch_type mod 2) = 1) then
        I1l10lOl <= NOT(push_n);
      else
       I1l10lOl <= O010I0Ol;
      end if;
    else
      I1l10lOl <= '0';
    end if;
  end process OI1l110O;

  Ol11lOOO <= NOT(I0IIO0I1);
  OI0O11IO : process (push_n, pop_n, l1O10OOO, O10I1O1l, Ol11lOOO)
  begin
    if (arch_type = 0) then
      O0OOII0O <= push_n OR (l1O10OOO AND pop_n);
    else
      if ((mem_mode = 2) OR (mem_mode = 3)) then
        O0OOII0O <= O10I1O1l;
      else
        O0OOII0O <= Ol11lOOO;
      end if;
    end if;
  end process OI0O11IO;

  IO10O1Ol     <= O1IO0II1 when ((arch_type = 0) OR ((arch_type mod 2) = 1)) else lO1OO1Ol;
  I0ll01O0      <= l100O001 when ((arch_type = 0) OR ((arch_type mod 2) = 1)) else OI1lO1I0;
  OO0Ol11I    <= NOT(O0OOII0O) when (mem_mode >= 4) else '0';

  I10O0IOl <= l1001lIO when ((mem_mode=2) OR (mem_mode=3)) else I0ll01O0;


  OIIO1IO1 : process (rd_data)
  begin
    for bit_idx in 0 to width-1 loop
      O00I000I(bit_idx) <= To_X01(rd_data(bit_idx)); -- convert any X's
    end loop;
  end process OIIO1IO1;

  IO1010I0 : process (O01I100l, lI1I0Ol0)
  begin
    if ((O01I100l >= 0) AND (lI1I0Ol0 >= 0)) then
      if (O01I100l = lI1I0Ol0) then
        lI1I1O0O <= '1';
      else
        lI1I1O0O <= '0';
      end if;
    else
      lI1I1O0O <= 'X';
    end if;
  end process IO1010I0;

  OOO111OI  <= '1' when (O01I100l = OOOOOl0O) else '0';
  OO11IOO0       <= lI1I1O0O OR OOO111OI;

  l1I0Olll : process (OO11IOO0, OOO111OI, lI1I1O0O)
  begin
    if (mem_mode = 4) then
      l0OOOl0O <= OO11IOO0;
    elsif (mem_mode >= 5) then
      l0OOOl0O <= OOO111OI;
    else
      l0OOOl0O <= lI1I1O0O;
    end if;
  end process l1I0Olll;

  O0OI11Il : process (I0IIO0I1, I11O0O00, OlOlI111)
  begin
    if ((I0IIO0I1 = '1')  AND (I11O0O00 = '0')) then
      ll0OOI00 <= OlOlI111 + 1;
    elsif ((I0IIO0I1 = '0') AND (I11O0O00 = '1')) then
      ll0OOI00 <= OlOlI111 - 1;
    else
      ll0OOI00 <= OlOlI111;
    end if;
  end process O0OI11Il;

  OlII10O1 <= (push_n AND NOT(pop_n) AND NOT(lOO0O011)) OR (pop_n AND NOT(push_n) AND NOT(l1O10OOO)) OR
                     (NOT(push_n) AND NOT(pop_n) AND lOO0O011);
  l0OO11II : process (OlII10O1, l01IOOl0, IOO00OlO, 
                                    ll0OOI00, O01III00, l0OlOI0O)
    variable I0000000         : INTEGER;
    variable OOO11Il1         : INTEGER;
    variable Ol1OOOO1  : INTEGER;
    variable I0O10Oll  : INTEGER;
    variable I001I101  : INTEGER;
  begin
    Ol1OOOO1 := 0;
    I0O10Oll := 0;
    I001I101 := 0;
    if (OlII10O1 = '1') then
      if (ll0OOI00 < 0 ) then
        OI111l11 <= -1;
      elsif (arch_type = 0) then
        OI111l11 <= ll0OOI00;
      else
        for I0000000 in 0 to Il10Il1O-1 loop
          if (O01III00(I0000000) = '1') then
            Ol1OOOO1 := Ol1OOOO1 + 1;
          end if;
        end loop;
        for OOO11Il1 in 0 to 1 loop
          if (l0OlOI0O(OOO11Il1) = '1') then
            I0O10Oll := I0O10Oll + 1;
          end if;
        end loop;
        if (IOO00OlO = '1') then
          I001I101 := 1;
        end if;
        OI111l11 <= ll0OOI00 + Ol1OOOO1 + I0O10Oll + I001I101; 
      end if;
    elsif (OlII10O1 = '0') then
      OI111l11 <= l01IOOl0;
    else
      OI111l11 <= -1;
    end if;
  end process l0OO11II;


    OOl00001 <= NOT(l0OOOl0O) OR
                        I1l10lOl OR
                        (NOT(l1O0O01O) AND OI10O0l0(0));

    OI1l111O <= (I1l10lOl AND NOT(l0OOOl0O)) OR
                        (I1l10lOl AND NOT(l1O0O01O) AND OI10O0l0(0));

    I011lOOO <= l1O0O01O AND NOT(l0OOOl0O);


    lII10OI1 <= (I1l10lOl AND l0OOOl0O AND IlOO00OI(0)) OR
                        (I1l10lOl AND l0OOOl0O AND OI10O0l0(1)) OR
                        (NOT(l1O0O01O) AND IlOO00OI(0)) OR
                        (NOT(l1O0O01O) AND OI10O0l0(1)) OR
                        (I1l10lOl AND NOT(l1O0O01O) AND OI10O0l0(0));

    OOl11l0I <= I1l10lOl OR
                        IlOO00OI(0) OR
                        OI10O0l0(1) OR
                        (NOT(l1O0O01O) AND OI10O0l0(0));

    OI0O011O <= (I1l10lOl AND NOT(l0OOOl0O)) OR
                        (I1l10lOl AND NOT(l1O0O01O) AND IlOO00OI(0)) OR
                        (I1l10lOl AND NOT(l1O0O01O) AND OI10O0l0(1));

    O1lI001O <= l1O0O01O AND NOT(l0OOOl0O);
    OIOOOlOO  <= lII10OI1 & OOl11l0I;


    OOl111O1 <= (I1l10lOl AND l1O0O01O AND l0OOOl0O AND IlOO00OI(1)) OR
                        (NOT(l1O0O01O) AND OI10O0l0(2)) OR
                        (NOT(l1O0O01O) AND IlOO00OI(0) AND OI10O0l0(1)) OR
                        (I1l10lOl AND l0OOOl0O AND OI10O0l0(2)) OR
                        (I1l10lOl AND NOT(l1O0O01O) AND NOT(IlOO00OI(1)) AND IlOO00OI(0)) OR
                        (I1l10lOl AND l0OOOl0O AND IlOO00OI(0) AND OI10O0l0(1)) OR
                        (I1l10lOl AND NOT(l1O0O01O) AND NOT(IlOO00OI(1)) AND OI10O0l0(1));

    O11lOO10 <= OI10O0l0(2) OR
                        (IlOO00OI(0) AND OI10O0l0(1)) OR
                        (I1l10lOl AND NOT(IlOO00OI(1)) AND IlOO00OI(0)) OR
                        (I1l10lOl AND NOT(l1O0O01O) AND OI10O0l0(0)) OR
                        (NOT(l1O0O01O) AND IlOO00OI(0)) OR
                        (I1l10lOl AND NOT(IlOO00OI(1)) AND OI10O0l0(1)) OR
                        (NOT(l1O0O01O) AND OI10O0l0(1));

    llO00O1l <= IlOO00OI(0) OR
                        I1l10lOl OR
                        OI10O0l0(1) OR
                        (NOT(l1O0O01O) AND OI10O0l0(0));

    II00I10I <= (I1l10lOl AND NOT(l1O0O01O) AND OI10O0l0(2)) OR
                        (I1l10lOl AND NOT(l0OOOl0O)) OR
                        (I1l10lOl AND NOT(l1O0O01O) AND IlOO00OI(1)) OR
                        (I1l10lOl AND NOT(l1O0O01O) AND IlOO00OI(0) AND OI10O0l0(1));

    l1l0OllO <= l1O0O01O AND NOT(l0OOOl0O);
    OOOOlO11  <= OOl111O1 & O11lOO10 & llO00O1l;


    ll011101 <= (I1l10lOl AND NOT(OOIO10O1) AND NOT(l0OOOl0O)) OR
                        (I1l10lOl AND NOT(l1O0O01O) AND OI10O0l0(0)) OR
                        (I1l10lOl AND NOT(OOIO10O1) AND OI10O0l0(1)) OR
                        (NOT(l1O0O01O) AND NOT(l0OOOl0O)) OR
                        (NOT(l0OOOl0O) AND OI10O0l0(1)) OR
                        (NOT(l1O0O01O) AND OI10O0l0(1));

    l00I0IO0 <= (I1l10lOl AND NOT(OOIO10O1)) OR
                        (NOT(l1O0O01O) AND OI10O0l0(0)) OR
                        NOT(l0OOOl0O) OR
                        OI10O0l0(1);

    ll000l0I <= (I1l10lOl AND OOIO10O1 AND OI10O0l0(0)) OR
                        (I1l10lOl AND NOT(l1O0O01O) AND NOT(l0OOOl0O)) OR
                        (I1l10lOl AND NOT(l1O0O01O) AND OI10O0l0(1)) OR
                        (I1l10lOl AND NOT(l0OOOl0O) AND OI10O0l0(1));

    OI010l01 <= (NOT(l0OOOl0O) AND NOT(OI10O0l0(1))) OR
                        (l1O0O01O AND NOT(l0OOOl0O));
    O100000O  <= ll011101 & l00I0IO0;


    l01l010I <= (NOT(l1O0O01O) AND OI10O0l0(2) AND NOT(OI10O0l0(1))) OR
                        (I1l10lOl AND l1O0O01O AND NOT(OOIO10O1) AND NOT(l0OOOl0O) AND NOT(OI10O0l0(1))) OR
                        (I1l10lOl AND NOT(OOIO10O1) AND l0OOOl0O AND OI10O0l0(2)) OR
                        (NOT(l1O0O01O) AND NOT(IlOO00OI(0)) AND OI10O0l0(2)) OR
                        (I1l10lOl AND l1O0O01O AND NOT(OOIO10O1) AND NOT(l0OOOl0O) AND NOT(IlOO00OI(0)) AND NOT(OI10O0l0(2))) OR
                        (NOT(l1O0O01O) AND IlOO00OI(0) AND NOT(OI10O0l0(2)) AND OI10O0l0(1)) OR
                        (I1l10lOl AND NOT(l1O0O01O) AND l0OOOl0O AND IlOO00OI(0)) OR
                        (I1l10lOl AND NOT(OOIO10O1) AND l0OOOl0O AND IlOO00OI(0) AND OI10O0l0(1)) OR
                        (I1l10lOl AND NOT(l1O0O01O) AND l0OOOl0O AND OI10O0l0(1));

    O0lI00I1 <= (OI10O0l0(2) AND NOT(OI10O0l0(1))) OR
                        (NOT(l1O0O01O) AND NOT(OI10O0l0(2)) AND OI10O0l0(1)) OR
                        (NOT(l1O0O01O) AND IlOO00OI(0) AND NOT(OI10O0l0(1))) OR
                        (I1l10lOl AND NOT(l1O0O01O) AND NOT(OI10O0l0(2)) AND OI10O0l0(0)) OR
                        (NOT(IlOO00OI(0)) AND OI10O0l0(2)) OR
                        (I1l10lOl AND l0OOOl0O AND IlOO00OI(0)) OR
                        (IlOO00OI(0) AND NOT(OI10O0l0(2)) AND OI10O0l0(1)) OR
                        (I1l10lOl AND l0OOOl0O AND OI10O0l0(1));

    l0O0l0O1 <=(I1l10lOl AND NOT(OI10O0l0(1))) OR
                        (NOT(IlOO00OI(0)) AND OI10O0l0(1)) OR
                        (NOT(OI10O0l0(2)) AND OI10O0l0(1)) OR
                        (IlOO00OI(0) AND NOT(OI10O0l0(1))) OR
                        (NOT(l1O0O01O) AND NOT(OI10O0l0(2)) AND OI10O0l0(0));

    Il0OI111 <= (I1l10lOl AND OOIO10O1 AND NOT(IlOO00OI(0))) OR
                        (I1l10lOl AND NOT(l1O0O01O) AND IlOO00OI(0) AND NOT(OI10O0l0(2)) AND OI10O0l0(1)) OR
                        (I1l10lOl AND NOT(l1O0O01O) AND NOT(l0OOOl0O) AND NOT(OI10O0l0(2))) OR
                        (I1l10lOl AND OOIO10O1 AND NOT(OI10O0l0(2))) OR
                        (I1l10lOl AND NOT(l1O0O01O) AND l0OOOl0O AND OI10O0l0(2)) OR
                        (I1l10lOl AND NOT(l0OOOl0O) AND NOT(IlOO00OI(0)) AND OI10O0l0(2)) OR
                        (I1l10lOl AND NOT(l0OOOl0O) AND IlOO00OI(0) AND NOT(OI10O0l0(2)) AND OI10O0l0(1));

    OOO0O00O <= (NOT(l0OOOl0O) AND NOT(OI10O0l0(1))) OR
                        (l1O0O01O AND NOT(l0OOOl0O) AND NOT(IlOO00OI(0))) OR
                        (NOT(l0OOOl0O) AND NOT(IlOO00OI(0)) AND NOT(OI10O0l0(2))) OR
                        (l1O0O01O AND NOT(l0OOOl0O) AND NOT(OI10O0l0(2)));

    lOO1lO01  <= l01l010I & O0lI00I1 & l0O0l0O1;


    II0111O0 <= (I1l10lOl AND NOT(OOIO10O1) AND l0OOOl0O AND IlOO00OI(0)) OR
                        (I1l10lOl AND NOT(OOIO10O1) AND l0OOOl0O AND OI10O0l0(1)) OR
                        (NOT(l1O0O01O) AND IlOO00OI(0)) OR
                        (NOT(l1O0O01O) AND OI10O0l0(1)) OR
                        (I1l10lOl AND NOT(l1O0O01O) AND OI10O0l0(0));

    OO11I0OO <= I1l10lOl OR
                        IlOO00OI(0) OR
                        OI10O0l0(1) OR
                        (NOT(l1O0O01O) AND OI10O0l0(0));

    I010I0Ol <= (I1l10lOl AND NOT(l0OOOl0O)) OR
                        (I1l10lOl AND NOT(l1O0O01O) AND IlOO00OI(0)) OR
                        (I1l10lOl AND OOIO10O1) OR
                        (I1l10lOl AND NOT(l1O0O01O) AND OI10O0l0(1));

    I10O1l10 <= (l1O0O01O AND NOT(l0OOOl0O)) OR
                        (l1O0O01O AND OOIO10O1);
    O1O0lIOI  <= II0111O0 & OO11I0OO;
    lO0111Ol <= (I1l10lOl AND l1O0O01O AND NOT(OOIO10O1) AND l0OOOl0O AND IlOO00OI(1)) OR
                        (I1l10lOl AND NOT(OOIO10O1) AND l0OOOl0O AND OI10O0l0(2)) OR
                        (NOT(l1O0O01O) AND OI10O0l0(2)) OR
                        (NOT(l1O0O01O) AND IlOO00OI(0) AND OI10O0l0(1)) OR
                        (I1l10lOl AND NOT(l1O0O01O) AND NOT(OOIO10O1) AND l0OOOl0O AND NOT(IlOO00OI(1)) AND IlOO00OI(0)) OR
                        (I1l10lOl AND NOT(OOIO10O1) AND l0OOOl0O AND IlOO00OI(0) AND OI10O0l0(1)) OR
                        (I1l10lOl AND NOT(l1O0O01O) AND NOT(OOIO10O1) AND NOT(IlOO00OI(1)) AND OI10O0l0(1));

    O0011Ill <= (I1l10lOl AND NOT(l1O0O01O) AND NOT(OOIO10O1) AND NOT(IlOO00OI(0)) AND OI10O0l0(0)) OR
                        (NOT(l1O0O01O) AND IlOO00OI(1)) OR
                        OI10O0l0(2) OR
                        (I1l10lOl AND NOT(OOIO10O1) AND l0OOOl0O AND NOT(IlOO00OI(1)) AND IlOO00OI(0)) OR
                        (IlOO00OI(0) AND OI10O0l0(1)) OR
                        (NOT(l1O0O01O) AND NOT(OOIO10O1) AND l0OOOl0O AND IlOO00OI(0)) OR
                        (I1l10lOl AND NOT(OOIO10O1) AND NOT(IlOO00OI(1)) AND OI10O0l0(1)) OR
                        (NOT(l1O0O01O) AND NOT(OOIO10O1) AND OI10O0l0(1));

    O01I1I0I <= (NOT(l1O0O01O) AND NOT(OOIO10O1) AND NOT(IlOO00OI(0)) AND OI10O0l0(0)) OR
                        (I1l10lOl AND NOT(OOIO10O1) AND NOT(IlOO00OI(0))) OR
                        IlOO00OI(1) OR
                        OI10O0l0(2) OR
                        (IlOO00OI(0) AND OI10O0l0(1)) OR
                        (NOT(OOIO10O1) AND l0OOOl0O AND IlOO00OI(0)) OR
                        (NOT(OOIO10O1) AND OI10O0l0(1));

    O1I0I0l1 <= (I1l10lOl AND NOT(l1O0O01O) AND OI10O0l0(2)) OR
                        (I1l10lOl AND NOT(l0OOOl0O) AND IlOO00OI(1)) OR
                        (I1l10lOl AND OOIO10O1 AND IlOO00OI(1)) OR
                        (I1l10lOl AND NOT(l0OOOl0O) AND OI10O0l0(1)) OR
                        (I1l10lOl AND OOIO10O1 AND OI10O0l0(2)) OR
                        (I1l10lOl AND NOT(l1O0O01O) AND IlOO00OI(1)) OR
                        (I1l10lOl AND OOIO10O1 AND IlOO00OI(0) AND OI10O0l0(1)) OR
                        (I1l10lOl AND NOT(l1O0O01O) AND IlOO00OI(0) AND OI10O0l0(1));

    O000OO1l <= (l1O0O01O AND NOT(l0OOOl0O) AND IlOO00OI(1)) OR
                        (l1O0O01O AND OOIO10O1 AND IlOO00OI(1)) OR
                        (l1O0O01O AND NOT(l0OOOl0O) AND OI10O0l0(1)) OR
                        (l1O0O01O AND OOIO10O1 AND OI10O0l0(2)) OR
                        (l1O0O01O AND OOIO10O1 AND IlOO00OI(0) AND OI10O0l0(1));
    O0000O1I  <= lO0111Ol & O0011Ill & O01I1I0I;


  I0O00l0l : process (OO1l1lI1, OI1l111O, OI0O011O, II00I10I, 
                              ll000l0I, Il0OI111, I010I0Ol, O1I0I0l1)
  begin
    if (arch_type = 0) then
      I0IIO0I1 <= OO1l1lI1;
    elsif (mem_mode = 0) then
      I0IIO0I1 <= OI1l111O;
    elsif ((mem_mode = 1) OR (mem_mode = 2)) then
      I0IIO0I1 <= OI0O011O;
    elsif (mem_mode = 3) then
      I0IIO0I1 <= II00I10I;
    elsif (mem_mode = 4) then
      I0IIO0I1 <= ll000l0I;
    elsif (mem_mode = 5) then
      I0IIO0I1 <= Il0OI111;
    elsif (mem_mode = 6) then
      I0IIO0I1 <= I010I0Ol;
    else
      I0IIO0I1 <= O1I0I0l1;
    end if;
  end process I0O00l0l;


  O0l110Il : process (I0IIO0I1, lI1I0Ol0)
    variable wr_ptr_slv  : std_logic_vector(lOOOI110 downto 0);
  begin
    wr_ptr_slv := std_logic_vector(CONV_UNSIGNED(lI1I0Ol0, lOOOI110+1));
    if (I0IIO0I1 = '1') then
      if (wr_ptr_slv(lOOOI110-1 downto 0) = std_logic_vector(CONV_UNSIGNED(O0O1O00I, lOOOI110))) then
        Ol1I0I11 <= CONV_INTEGER(UNSIGNED(NOT(wr_ptr_slv(lOOOI110)) & OIl10010));
      else
        Ol1I0I11 <= lI1I0Ol0 + 1;
      end if ;
    elsif (I0IIO0I1 = '0') then
      Ol1I0I11 <= lI1I0Ol0;
    else
      Ol1I0I11 <= -1;
    end if;
  end process O0l110Il;

  I01ll0O1        <= (others => 'X') when (lI1I0Ol0 = -1) else std_logic_vector(CONV_UNSIGNED(lI1I0Ol0, lOOOI110+1));
  I11O10O0   <= I01ll0O1(lOOOI110-1 downto 0);
  O0O1O1l1   <= l0O1O10O when ((mem_mode = 2) OR (mem_mode = 3)) else I11O10O0;

  O1l110OO : process (I011lOOO, O1lI001O, l1l0OllO, OI010l01, OOO0O00O, I10O1l10, O000OO1l)
  begin
    if (mem_mode = 0) then
      IOOI11O0 <= I011lOOO;
    elsif ((mem_mode = 1) OR (mem_mode = 2)) then
      IOOI11O0 <= O1lI001O;
    elsif (mem_mode = 3) then
      IOOI11O0 <= l1l0OllO;
    elsif (mem_mode = 4) then
      IOOI11O0 <= OI010l01;
    elsif (mem_mode = 5) then
      IOOI11O0 <= OOO0O00O;
    elsif (mem_mode = 6) then
      IOOI11O0 <= I10O1l10;
    else
      IOOI11O0 <= O000OO1l;
    end if;
  end process O1l110OO;

  OOOO0l01 : process (IOOI11O0, O01I100l)
    variable OO1O0I11  : std_logic_vector(lOOOI110 downto 0);
  begin
    OO1O0I11 := std_logic_vector(CONV_UNSIGNED(O01I100l, lOOOI110+1));
    if (IOOI11O0 = '1') then
      if (OO1O0I11(lOOOI110-1 downto 0) = std_logic_vector(CONV_UNSIGNED(O0O1O00I, lOOOI110))) then
        O1l00OOI <= CONV_INTEGER(UNSIGNED(NOT(OO1O0I11(lOOOI110)) & OIl10010));
      else
        O1l00OOI <= O01I100l + 1;
      end if ;
    elsif (IOOI11O0 = '0') then
      O1l00OOI <= O01I100l;
    else
      O1l00OOI <= -1;
    end if;
  end process OOOO0l01;

  IO0IO1O0      <= (others => 'X') when (O01I100l = -1) else std_logic_vector(CONV_UNSIGNED(O01I100l, lOOOI110+1));
  I00I0I1O <= IO0IO1O0(lOOOI110-1 downto 0);
  OOlOllOO <= I00I0I1O;

  I11O0O00    <= IOOI11O0;
  I1O0OO11  <= NOT(I11O0O00); 
  l0OlOI0O(1) <= I11O0O00 when ((mem_mode=3) OR (mem_mode=7)) else '0';
  O0I10lI0 : process (IlOO00OI, I11O0O00)
  begin
    if (((mem_mode=3) OR (mem_mode=7))) then
      l0OlOI0O(0) <= IlOO00OI(1);
    elsif (((mem_mode=1) OR (mem_mode=2) OR (mem_mode=5) OR (mem_mode=6))) then
      l0OlOI0O(0) <= I11O0O00;
    else
      l0OlOI0O(0) <= '0';
    end if;
  end process O0I10lI0;

  lIl0Il0I : process (OOl00001, OIOOOlOO, OOOOlO11,
                           O100000O, lOO1lO01, O1O0lIOI, O0000O1I)
  begin
    if (mem_mode = 0) then
      O01III00 <= b"00" & OOl00001;
    elsif ((mem_mode = 1) OR (mem_mode = 2)) then
      O01III00 <= '0' & OIOOOlOO;
    elsif (mem_mode = 3) then
      O01III00 <= OOOOlO11;
    elsif (mem_mode = 4) then
      O01III00 <= '0' & O100000O;
    elsif (mem_mode = 5) then
      O01III00 <= lOO1lO01;
    elsif (mem_mode = 6) then
      O01III00 <= '0' & O1O0lIOI;
    elsif (mem_mode = 7) then
      O01III00 <= O0000O1I;
    else
       O01III00 <= b"000";
    end if;
  end process lIl0Il0I;

  I001II11 : process (I11O0O00, IlOO00OI)
  begin
    if ((mem_mode=0) OR (ram_re_ext = 0)) then
      IOOl0IlI <= NOT(I11O0O00);
    elsif (((mem_mode=1) OR (mem_mode=2) OR (mem_mode=4) OR (mem_mode=6))) then
      IOOl0IlI <= NOT(I11O0O00) AND NOT(IlOO00OI(0));
    else
      IOOl0IlI <= NOT(I11O0O00) AND NOT(IlOO00OI(0)) AND NOT(IlOO00OI(1)); 
    end if;
  end process I001II11;

  l1OOI000 <= I10I10O1 when ((arch_type mod 2) = 0) else '1';

  O1lOOlO0 : process (O01III00, lOO0O011, l0OOOl0O, O1IO0II1, OO1l1lI1, pop_n, OI10O0l0,
                           I0ll01O0, IO10O1Ol, O00I000I, O111001l, I1OOO0OO, l1OOI000)
    variable l0IO00O0                  : INTEGER;
    variable IlO10lI1       : INTEGER;
    variable lIO00I01   : INTEGER;
    variable OlO01l1l   : INTEGER;
    variable lO101100   : INTEGER;
    variable IO00O1I1       : std_logic_vector(DW_O0I10OIO-1 downto 0);
    variable l11O1OO1 : INTEGER;
  begin
    IlO10lI1            := CONV_INTEGER(UNSIGNED(I0ll01O0));
    lIO00I01        := CONV_INTEGER(UNSIGNED(I0OO0IIl(2)));
    OlO01l1l        := CONV_INTEGER(UNSIGNED(I0OO0IIl(1)));
    lO101100        := CONV_INTEGER(UNSIGNED(I0OO0IIl(0)));

    IO00O1I1         := I1OOO0OO;
    l11O1OO1   := CONV_INTEGER(UNSIGNED(IO00O1I1));

    if (O01III00(0) = '1') then
      O01lI10I(0) <= l0OOO01I(0);
      O1l0O011(0)  <= I0OO0IIl(0);
      if ((OO1l1lI1 = '1') AND (lOO0O011 = '1')) then
        O01lI10I(0) <= O1IO0II1;
        O1l0O011(0)  <= I0ll01O0;
      elsif (pop_n = '0') then
        if (lO101100 = depth-1) then
          if ((OlO01l1l = 0) AND (OI10O0l0(1) = '1')) then
            O01lI10I(0) <= l0OOO01I(1);
            O1l0O011(0)  <= I0OO0IIl(1);
          elsif ((IO00O1I1 = 0) AND (O111001l = '1')) then
            O01lI10I(0) <= O00I000I;
            O1l0O011(0)  <= IO00O1I1;
--          elsif ((IlO10lI1 = 0) AND (l1OOI000 = '1')) then
          elsif (IlO10lI1 = 0) then
            O01lI10I(0) <= IO10O1Ol;
            O1l0O011(0)  <= I0ll01O0;
          end if;
        else
          if (((lO101100+1) = OlO01l1l) AND (OI10O0l0(1) = '1')) then
            O01lI10I(0) <= l0OOO01I(1);
            O1l0O011(0)  <= I0OO0IIl(1);
          elsif (((lO101100+1) = l11O1OO1) AND (O111001l = '1')) then
            O01lI10I(0) <= O00I000I;
            O1l0O011(0)  <= IO00O1I1;
--          elsif (((lO101100+1) = IlO10lI1) AND (l1OOI000 = '1')) then
          elsif ((lO101100+1) = IlO10lI1) then
            O01lI10I(0) <= IO10O1Ol;
            O1l0O011(0)  <= I0ll01O0;
          end if;
        end if;
      end if;
    elsif (O01III00(0) = '0') then
      O01lI10I(0) <= l0OOO01I(0);
      O1l0O011(0)  <= I0OO0IIl(0);
    else
      O01lI10I(0) <= (others => 'X');
      O1l0O011(0)  <= (others => 'X');
    end if;
    if (O01III00(1) = '1') then
      O01lI10I(1) <= l0OOO01I(1);
      O1l0O011(1)  <= I0OO0IIl(1);
      if (pop_n = '0') then
        if (lO101100 = depth-1) then
          if ((lIO00I01 = 1) AND (OI10O0l0(2) = '1')) then
            O01lI10I(1) <= l0OOO01I(2);
            O1l0O011(1)  <= I0OO0IIl(2);
          elsif ((IO00O1I1 = 1) AND (O111001l = '1')) then
            O01lI10I(1) <= O00I000I;
            O1l0O011(1)  <= IO00O1I1;
          elsif ((IlO10lI1 = 1) AND (l1OOI000 = '1')) then
            O01lI10I(1) <= IO10O1Ol;
            O1l0O011(1)  <= I0ll01O0;
          end if;
        elsif (lO101100 = depth-2) then
          if ((lIO00I01 = 0) AND (OI10O0l0(2) = '1')) then
            O01lI10I(1) <= l0OOO01I(2);
            O1l0O011(1)  <= I0OO0IIl(2);
          elsif ((IO00O1I1 = 0) AND (O111001l = '1')) then
            O01lI10I(1) <= O00I000I;
            O1l0O011(1)  <= IO00O1I1;
          elsif ((IlO10lI1 = 0) AND (l1OOI000 = '1')) then
            O01lI10I(1) <= IO10O1Ol;
            O1l0O011(1)  <= I0ll01O0;
          end if;
        else
          if (((lO101100+2) = lIO00I01) AND (OI10O0l0(2) = '1')) then
            O01lI10I(1) <= l0OOO01I(2);
            O1l0O011(1)  <= I0OO0IIl(2);
          elsif (((lO101100+2) = l11O1OO1) AND (O111001l = '1')) then
            O01lI10I(1) <= O00I000I;
            O1l0O011(1)  <= IO00O1I1;
          elsif (((lO101100+2) = IlO10lI1) AND (l1OOI000 = '1')) then
            O01lI10I(1) <= IO10O1Ol;
            O1l0O011(1)  <= I0ll01O0;
          end if;
        end if;
      else
        if (lO101100 = depth-1) then
          if ((lIO00I01 = 0) AND (OI10O0l0(2) = '1')) then
            O01lI10I(1) <= l0OOO01I(2);
            O1l0O011(1)  <= I0OO0IIl(2);
          elsif ((IO00O1I1 = 0) AND (O111001l = '1')) then
            O01lI10I(1) <= O00I000I;
            O1l0O011(1)  <= IO00O1I1;
          elsif ((IlO10lI1 = 0) AND (l1OOI000 = '1')) then
            O01lI10I(1) <= IO10O1Ol;
            O1l0O011(1)  <= I0ll01O0;
          end if;
        else
          if (((lO101100+1) = lIO00I01) AND (OI10O0l0(2) = '1')) then
            O01lI10I(1) <= l0OOO01I(2);
            O1l0O011(1)  <= I0OO0IIl(2);
          elsif (((lO101100+1) = l11O1OO1) AND (O111001l = '1')) then
            O01lI10I(1) <= O00I000I;
            O1l0O011(1)  <= IO00O1I1;
          elsif (((lO101100+1) = IlO10lI1) AND (l1OOI000 = '1')) then
            O01lI10I(1) <= IO10O1Ol;
            O1l0O011(1)  <= I0ll01O0;
          end if;
        end if;
      end if;
    elsif (O01III00(1) = '0') then
      O01lI10I(1) <= l0OOO01I(1);
      O1l0O011(1)  <= I0OO0IIl(1);
    else
      O01lI10I(1) <= (others => 'X');
      O1l0O011(1)  <= (others => 'X');
    end if;
    if (O01III00(2) = '1') then
      O01lI10I(2) <= l0OOO01I(2);
      O1l0O011(2)  <= I0OO0IIl(2);
      if (pop_n = '0') then
        if (lO101100 = depth-1) then
          if ((IO00O1I1 = 2) AND (O111001l = '1')) then
            O01lI10I(2) <= O00I000I;
            O1l0O011(2)  <= IO00O1I1;
          elsif ((IlO10lI1 = 2) AND (l1OOI000 = '1')) then
            O01lI10I(2) <= IO10O1Ol;
            O1l0O011(2)  <= I0ll01O0;
          end if;
        elsif (lO101100 = depth-2) then
          if ((IO00O1I1 = 1) AND (O111001l = '1')) then
            O01lI10I(2) <= O00I000I;
            O1l0O011(2)  <= IO00O1I1;
          elsif ((IlO10lI1 = 1) AND (l1OOI000 = '1')) then
            O01lI10I(2) <= IO10O1Ol;
            O1l0O011(2)  <= I0ll01O0;
          end if;
        elsif (lO101100 = depth-3) then
          if ((IO00O1I1 = 0) AND (O111001l = '1')) then
            O01lI10I(2) <= O00I000I;
            O1l0O011(2)  <= IO00O1I1;
          elsif ((IlO10lI1 = 0) AND (l1OOI000 = '1')) then
            O01lI10I(2) <= IO10O1Ol;
            O1l0O011(2)  <= I0ll01O0;
          end if;
        else
          if (((lO101100+3) = l11O1OO1) AND (O111001l = '1')) then
            O01lI10I(2) <= O00I000I;
            O1l0O011(2)  <= IO00O1I1;
          elsif (((lO101100+3) = IlO10lI1) AND (l1OOI000 = '1')) then
            O01lI10I(2) <= IO10O1Ol;
            O1l0O011(2)  <= I0ll01O0;
          end if;
        end if;
      else
        if (lO101100 = depth-1) then
          if ((IO00O1I1 = 1) AND (O111001l = '1')) then
            O01lI10I(2) <= O00I000I;
            O1l0O011(2)  <= IO00O1I1;
          elsif ((IlO10lI1 = 1) AND (l1OOI000 = '1')) then
            O01lI10I(2) <= IO10O1Ol;
            O1l0O011(2)  <= I0ll01O0;
          end if;
        elsif (lO101100 = depth-2) then
          if ((IO00O1I1 = 0) AND (O111001l = '1')) then
            O01lI10I(2) <= O00I000I;
            O1l0O011(2)  <= IO00O1I1;
          elsif ((IlO10lI1 = 0) AND (l1OOI000 = '1')) then
            O01lI10I(2) <= IO10O1Ol;
            O1l0O011(2)  <= I0ll01O0;
          end if;
        else
          if (((lO101100+2) = l11O1OO1) AND (O111001l = '1')) then
            O01lI10I(2) <= O00I000I;
            O1l0O011(2)  <= IO00O1I1;
          elsif (((lO101100+2) = IlO10lI1) AND (l1OOI000 = '1')) then
            O01lI10I(2) <= IO10O1Ol;
            O1l0O011(2)  <= I0ll01O0;
          end if;
        end if;
      end if;
    elsif (O01III00(2) = '0') then
      O01lI10I(2) <= l0OOO01I(2);
      O1l0O011(2)  <= I0OO0IIl(2);
    else
      O01lI10I(2) <= (others => 'X');
      O1l0O011(2)  <= (others => 'X');
    end if;
  end process O1lOOlO0;


  IO0011O1 : process (push_n, l1O10OOO, pop_n, lOO0O011)
  begin
    if (((push_n = '0') AND (l1O10OOO = '1') AND (pop_n = '1')) OR
        ((pop_n = '0') AND (lOO0O011 = '1'))) then
      O00II10O <= '1';
    elsif (((push_n = '1') OR (l1O10OOO = '0') OR (pop_n = '0')) AND
        ((pop_n = '1') OR (lOO0O011 = '0'))) then
      O00II10O <= '0';
    else 
      O00II10O <= 'X';
    end if;
  end process IO0011O1;
  lI1lI110 <= (O00II10O OR l0I1I1OO) when (err_mode < 1) else O00II10O;

  OO1lOl0I : process (l01IOOl0)
  begin
    if (l01IOOl0 = 0) then
      lOO0O011 <= '1';
    elsif (l01IOOl0 > 0) then
      lOO0O011 <= '0';
    else
      lOO0O011 <= 'X';
    end if;
    if (l01IOOl0 >= (depth+1)/2) then
      IlOIlIO0 <= '1';
    elsif ((l01IOOl0 < (depth+1)/2) AND (l01IOOl0 >= 0)) then
      IlOIlIO0 <= '0';
    else
      IlOIlIO0 <= 'X';
    end if;
    if (l01IOOl0 = depth) then
      l1O10OOO <= '1';
    elsif ((l01IOOl0 < depth) AND (l01IOOl0 >= 0)) then
      l1O10OOO <= '0';
    else
      l1O10OOO <= 'X';
    end if;
  end process OO1lOl0I;

  O010OO0O       <= ((push_n XOR pop_n) AND 
                          ((NOT(pop_n) AND NOT(lOO0O011)) OR (NOT(push_n) AND NOT(l1O10OOO)))) OR
                        (NOT(push_n) AND NOT(pop_n) AND lOO0O011);
  
  OO0O0Il1 : process (OI111l11, ae_level, af_level, O010OO0O, level_change,
                            OO10O101, OlO1O11O)
    variable l0OO1O0O : INTEGER;
    variable l0Il0O1I : INTEGER;
  begin  -- process mkource_flags
    if ((XOR_REDUCE(ae_level) = '0') OR (XOR_REDUCE(ae_level) = '1')) then
      l0OO1O0O := CONV_INTEGER(UNSIGNED(ae_level));
    else
      l0OO1O0O := -1;
    end if;
    if ((XOR_REDUCE(af_level) = '0') OR (XOR_REDUCE(af_level) = '1')) then
      l0Il0O1I := CONV_INTEGER(UNSIGNED(af_level));
    else
      l0Il0O1I := -1;
    end if;

    if ((O010OO0O = '1') OR (level_change = '1')) then
      if (OI111l11 < 0) then
        Ol00IO01 <= 'X';
        O1OI0O11  <= 'X';
      else
        if (l0OO1O0O /= -1) then
          if (OI111l11 <= l0OO1O0O) then
            Ol00IO01 <= '1'; 
          elsif (OI111l11 > l0OO1O0O) then
            Ol00IO01 <= '0'; 
          end if;
        else
          Ol00IO01 <= 'X';
        end if;
        if (l0Il0O1I /= -1) then
          if (af_from_top = 0) then
            if (OI111l11 < l0Il0O1I) then
              O1OI0O11 <= '0'; 
            elsif (OI111l11 >= l0Il0O1I) then
              O1OI0O11 <= '1'; 
            end if;
          else
            if (OI111l11 < depth-l0Il0O1I) then
              O1OI0O11 <= '0'; 
            elsif (OI111l11 >= depth-l0Il0O1I) then
              O1OI0O11 <= '1'; 
            end if;
          end if;
        else
          O1OI0O11 <= 'X';
        end if;
      end if;
    elsif ((O010OO0O = '0') AND (level_change = '0')) then
      Ol00IO01 <= OO10O101;
      O1OI0O11  <= OlO1O11O;
    else
      Ol00IO01 <= 'X';
      O1OI0O11  <= 'X';
    end if;
  end process OO0O0Il1;
  
  Il11Ol1I : process (clk, rst_n)
    variable  l0IO00O0 : INTEGER;
    variable  O0000OO0 : INTEGER;
  begin
  
    if (rst_n = '0' ) then
        l1O01100  <= '0';
        I10I10O1           <= '0';
        OI10O0l0               <= (others => '0');
        IlOO00OI             <= (others => '0');
        OlOlI111       <= 0;
	l0llI101        <= '0';
        l01IOOl0      <= 0;
        l0I1I1OO           <= '0';
        OO10O101    <= '1';
        OlO1O11O     <= '0';
        O10110OI      <= (others => '0');
        OI01O00O      <= (others => '0');
        O10I1O1l     <= '1';
        OOIO10O1             <= '0';
        l0O1O10O      <= (others => '0');
        lI1I0Ol0        <= 0;
        OOOOOl0O     <= 0;
        O01I100l        <= 0;
        II1111OI           <= (others => '0');
        IlO10lI1        <= 0;
        l1001lIO       <= (others => '0');
        for l0IO00O0 in 0 to Il10Il1O-1 loop
          l0OOO01I(l0IO00O0)       <= (others => '0');
        end loop;
        for O0000OO0 in 0 to Il10Il1O-1 loop
          I0OO0IIl(O0000OO0)       <= (others => '0');
        end loop;
    elsif (rst_n = '1') then
      if (clk'event and clk = '1') then
        if (init_n = '0') then
          l1O01100  <= '0';
          I10I10O1           <= '0';
          OI10O0l0               <= (others => '0');
          IlOO00OI             <= (others => '0');
          OlOlI111       <= 0;
	  l0llI101        <= '0';
          l01IOOl0      <= 0;
          l0I1I1OO           <= '0';
          OO10O101    <= '1';
          OlO1O11O     <= '0';
          O10110OI      <= (others => '0');
          OI01O00O      <= (others => '0');
          O10I1O1l     <= '1';
          OOIO10O1             <= '0';
          l0O1O10O      <= (others => '0');
          lI1I0Ol0        <= 0;
          OOOOOl0O     <= 0;
          O01I100l        <= 0;
          II1111OI           <= (others => '0');
          IlO10lI1        <= 0;
          l1001lIO       <= (others => '0');
          for l0IO00O0 in 0 to Il10Il1O-1 loop
            l0OOO01I(l0IO00O0)       <= (others => '0');
          end loop;
          for O0000OO0 in 0 to Il10Il1O-1 loop
            I0OO0IIl(O0000OO0)       <= (others => '0');
          end loop;
        elsif (init_n = '1') then
          l1O01100  <= lll000Il;
          I10I10O1           <= OO0O11OO;
          OI10O0l0               <= O01III00;
          IlOO00OI             <= l0OlOI0O;
          OlOlI111       <= ll0OOI00;
	  l0llI101        <= l0OOOl0O;
          l01IOOl0      <= OI111l11;
          l0I1I1OO           <= lI1lI110 ;
          OO10O101    <= Ol00IO01;
          OlO1O11O     <= O1OI0O11;
          O10110OI      <= Il11Ol10;
          OI01O00O      <= IO10O1Ol;
          O10I1O1l     <= Ol11lOOO;
          OOIO10O1             <= OO0Ol11I;
          l0O1O10O      <= I11O10O0;
          lI1I0Ol0        <= Ol1I0I11;
          OOOOOl0O     <= lI1I0Ol0;
          O01I100l        <= O1l00OOI;
          II1111OI           <= OIOIOOOl;
          IlO10lI1        <= O0IO01lI;
          l1001lIO       <= I0ll01O0;
          for l0IO00O0 in 0 to Il10Il1O-1 loop
            l0OOO01I(l0IO00O0)       <= O01lI10I(l0IO00O0);
          end loop;
          for O0000OO0 in 0 to Il10Il1O-1 loop
            I0OO0IIl(O0000OO0)       <= O1l0O011(O0000OO0);
          end loop;
        else
          l1O01100  <= 'X';
          I10I10O1           <= 'X';
          OI10O0l0               <= (others => 'X');
          IlOO00OI             <= (others => 'X');
          OlOlI111       <= -1;
	  l0llI101        <= 'X';
          l01IOOl0      <= -1;
          l0I1I1OO           <= 'X';
          OO10O101    <= 'X';
          OlO1O11O     <= 'X';
          O10110OI      <= (others => 'X');
          OI01O00O      <= (others => 'X');
          O10I1O1l     <= 'X';
          OOIO10O1             <= 'X';
          l0O1O10O      <= (others => 'X');
          lI1I0Ol0        <= -1;
          OOOOOl0O     <= -1;
          O01I100l        <= -1;
          II1111OI           <= (others => 'X');
          IlO10lI1        <= -1;
          l1001lIO       <= (others => 'X');
          for l0IO00O0 in 0 to Il10Il1O-1 loop
            l0OOO01I(l0IO00O0)       <= (others => 'X');
          end loop;
          for O0000OO0 in 0 to Il10Il1O-1 loop
            I0OO0IIl(O0000OO0)       <= (others => 'X');
          end loop;
        end if;
      end if;
    else
      l1O01100  <= 'X';
      I10I10O1           <= 'X';
      OI10O0l0               <= (others => 'X');
      IlOO00OI             <= (others => 'X');
      OlOlI111       <= -1;
      l0llI101        <= 'X';
      l01IOOl0      <= -1;
      l0I1I1OO           <= 'X';
      OO10O101    <= 'X';
      OlO1O11O     <= 'X';
      O10110OI          <= (others => 'X');
      OI01O00O      <= (others => 'X');
      O10I1O1l     <= 'X';
      OOIO10O1             <= 'X';
      l0O1O10O      <= (others => 'X');
      lI1I0Ol0        <= -1;
      OOOOOl0O     <= -1;
      O01I100l        <= -1;
      II1111OI           <= (others => 'X');
      IlO10lI1        <= -1;
      l1001lIO       <= (others => 'X');
      for l0IO00O0 in 0 to Il10Il1O-1 loop
        l0OOO01I(l0IO00O0)       <= (others => 'X');
      end loop;
      for O0000OO0 in 0 to Il10Il1O-1 loop
        I0OO0IIl(O0000OO0)       <= (others => 'X');
      end loop;
    end if;
  end process Il11Ol1I;

  word_cnt      <= (others => 'X') when (l01IOOl0 < 0) else std_logic_vector(CONV_UNSIGNED(l01IOOl0, l110l0l1));
  

  data_out      <= O00I000I when (arch_type = 0) else l0OOO01I(0);
  word_cnt      <= (others => 'X') when (l01IOOl0 < 0) else std_logic_vector(CONV_UNSIGNED(l01IOOl0, l110l0l1));
  empty         <= lOO0O011;
  almost_empty  <= OO10O101;
  half_full     <= IlOIlIO0;
  almost_full   <= OlO1O11O;
  full          <= l1O10OOO;
  error         <= l0I1I1OO;

  ram_we_n      <= O0OOII0O;
  wr_addr       <= O0O1O1l1;
  ram_re_n      <= IOOl0IlI;
  rd_addr       <= I00I0I1O;
  OlO0l100 : process (O0OOII0O, OI01O00O, IO10O1Ol)
  begin
    if ((O0OOII0O = '1') OR (O0OOII0O = 'X')) then
      wr_data <= (others => 'X');
    elsif ((mem_mode = 2) OR (mem_mode = 3)) then
      wr_data <= OI01O00O;
    else
      wr_data <= IO10O1Ol;
    end if;
  end process OlO0l100;

  
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
  
    if ( (width < 1) OR (width > 4096) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter width (legal range: 1 to 4096)"
        severity warning;
    end if;
  
    if ( (depth < 4) OR (depth > 268435456) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter depth (legal range: 4 to 268435456)"
        severity warning;
    end if;
  
    if ( (mem_mode < 0) OR (mem_mode > 7 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter mem_mode (legal range: 0 to 7 )"
        severity warning;
    end if;
  
    if ( (arch_type < 0) OR (arch_type > 4 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter arch_type (legal range: 0 to 4 )"
        severity warning;
    end if;
  
    if ( (af_from_top < 0) OR (af_from_top > 1 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter af_from_top (legal range: 0 to 1 )"
        severity warning;
    end if;
  
    if ( (ram_re_ext < 0) OR (ram_re_ext > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter ram_re_ext (legal range: 0 to 1)"
        severity warning;
    end if;
  
    if ( (err_mode < 0) OR (err_mode > 1 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter err_mode (legal range: 0 to 1 )"
        severity warning;
    end if;
  
    if ( (arch_type=0 and mem_mode/=0) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid parameter combination: when input_mode=0, mem_mode must be 0"
        severity warning;
    end if;
  
    if ( (arch_type>=3 and mem_mode=0) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid parameter combination: when mem_mode=0, arch_type can only be 0, 1, or 2"
        severity warning;
    end if;
  
    if ( (O0lOI0O1<2) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid parameter combination of arch_type and mem_mode settings causes depth of RAM to be < 2"
        severity warning;
    end if;
  
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;

  
  clk_monitor  : process (clk) begin

    assert NOT (Is_X( clk ) AND (now > 0 ns)) 
      report "WARNING: Detected unknown value on the clock input port clk."
      severity warning;

  end process clk_monitor ;

-- pragma translate_on
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_lp_fifoctl_1c_df_cfg_sim of DW_lp_fifoctl_1c_df is
 for sim
 end for; -- sim
end DW_lp_fifoctl_1c_df_cfg_sim;
-- pragma translate_on

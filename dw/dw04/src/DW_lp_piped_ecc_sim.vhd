--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2009 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Doug Lee    Feb. 14, 2009
--
-- VERSION:   VHDL Simulation Model
--
-- DesignWare_version: 4f70d264
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT: Low Power Pipelined Modified Hamming Code Error Correction/Detection Synthetic Model
--  
--           This module supports data widths up to 8178 using
--           14 check bits
--
--   
--  Parameters:     Valid Values    Description
--  ==========      ============    =============
--  data_width       8 to 8178      default: 8
--                                  Width of 'datain' and 'dataout'
--
--  chk_width         5 to 14       default: 5
--                                  Width of 'chkin', 'chkout', and 'syndout'
--
--   rw_mode           0 or 1       default: 1
--                                  Read or write mode
--                                    0 => read mode
--                                    1 => write mode
--
--   op_iso_mode      0 to 4        default: 0
--                                  Type of operand isolation
--                                    If 'in_reg' is '1', this parameter is ignored...effectively set to '1'.
--                                    0 => Follow intent defined by Power Compiler user setting
--                                    1 => no operand isolation
--                                    2 => 'and' gate isolaton
--                                    3 => 'or' gate isolation
--                                    4 => preferred isolation style: 'and' gate
--
--   id_width        1 to 1024      default: 1
--                                  Launch identifier width
--
--   in_reg           0 to 1        default: 0
--                                  Input register control
--                                    0 => no input register
--                                    1 => include input register
--
--   stages          1 to 1022      default: 4
--                                  Number of logic stages in the pipeline
--
--   out_reg          0 to 1        default: 0
--                                  Output register control
--                                    0 => no output register
--                                    1 => include output register
--
--   no_pm            0 to 1        default: 1
--                                  Pipeline management usage
--                                    0 => Use pipeline management
--                                    1 => Do not use pipeline management - launch input
--                                          becomes global register enable to block
--
--   rst_mode         0 to 1        default: 0
--                                  Control asynchronous or synchronous reset
--                                  behavior of rst_n
--                                    0 => asynchronous reset
--                                    1 => synchronous reset 
--
--   
--  Ports        Size    Direction    Description
--  =====        ====    =========    ===========
--  clk          1 bit     Input      Clock Input
--  rst_n        1 bit     Input      Reset Input, Active Low
--
--  datain       M bits    Input      Input data bus
--  chkin        N bits    Input      Input check bits bus
--
--  err_detect   1 bit     Output     Any error flag (active high)
--  err_multiple 1 bit     Output     Multiple bit error flag (active high)
--  dataout      M bits    Output     Output data bus
--  chkout       N bits    Output     Output check bits bus
--  syndout      N bits    Output     Output error syndrome bus
--
--  launch       1 bit     Input      Active High Control input to launch data into pipe
--  launch_id    Q bits    Input      ID tag for operation being launched
--  pipe_full    1 bit     Output     Status Flag indicating no slot for a new launch
--  pipe_ovf     1 bit     Output     Status Flag indicating pipe overflow
--
--  accept_n     1 bit     Input      Flow Control Input, Active Low
--  arrive       1 bit     Output     Product available output
--  arrive_id    Q bits    Output     ID tag for product that has arrived
--  push_out_n   1 bit     Output     Active Low Output used with FIFO
--  pipe_census  R bits    Output     Output bus indicating the number
--                                   of pipeline register levels currently occupied
--
--     Note: M is the value of "data_width" parameter
--     Note: N is the value of "chk_width" parameter
--     Note: Q is the value of "id_width" parameter
--     Note: R is equal to the larger of '1' or ceil(log2(in_reg+stages+out_reg))
--
--
--  Modified:
--
--------------------------------------------------------------------------
 
library IEEE, DWARE;
use STD.textio.all;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_misc.all;
use DWARE.DWpackages.all;
use DWARE.DW_foundation_comp_arith.all;

architecture sim of DW_lp_piped_ecc is
	
-- pragma translate_off


  function OOl001O1( in_reg, stages, out_reg : in INTEGER ) return INTEGER is
    begin
        if((in_reg+(stages-1)+out_reg) >= 1) then
          return (in_reg+(stages-1)+out_reg);
        else
          return(1);
        end if;
  end OOl001O1; -- pipe_mgr stages

  constant l10I10O1  : INTEGER := OOl001O1(in_reg, stages, out_reg);

  signal O1110110          : std_logic_vector(data_width-1 downto 0);
  signal OOOl1101           : std_logic_vector(chk_width-1 downto 0);
  signal O1II11O1  : std_logic_vector(data_width-1 downto 0);
  signal O01I11IO   : std_logic_vector(chk_width-1 downto 0);
  signal OII1OOl0  : std_logic_vector(data_width-1 downto 0);
  signal I01OO00O   : std_logic_vector(chk_width-1 downto 0);

  signal O001IOl1       : std_logic_vector(data_width-1 downto 0);
  signal I101OO10        : std_logic_vector(chk_width-1 downto 0);
  signal I01ll0OO      : std_logic_vector(data_width-1 downto 0);
  signal Ol0I0lO1       : std_logic_vector(chk_width-1 downto 0);

  signal I10IO1Ol       : std_logic_vector(data_width-1 downto 0);
  signal OI1l0l00        : std_logic_vector(chk_width-1 downto 0);
  signal O010010O       : std_logic_vector(chk_width-1 downto 0);
  signal lO00l00I    : std_logic;
  signal I0O11O11  : std_logic;

  signal O0llOO1O      : std_logic_vector(data_width-1 downto 0);
  signal IO1lO0l0       : std_logic_vector(chk_width-1 downto 0);
  signal II000OOO      : std_logic_vector(chk_width-1 downto 0);
  signal I10O110O   : std_logic;
  signal IO100O1I : std_logic;

  signal dataout_Xs       : std_logic_vector(data_width-1 downto 0);
  signal chkout_Xs        : std_logic_vector(chk_width-1 downto 0);
  signal syndout_Xs       : std_logic_vector(chk_width-1 downto 0);


  signal O00IlO0I         : std_logic_vector(data_width-1 downto 0);
  signal IOOI1O00          : std_logic_vector(chk_width-1 downto 0);
  signal O0lI0O1O         : std_logic;
  signal O10O0O10      : std_logic_vector(id_width-1 downto 0);
  signal I1O0O1O1       : std_logic;

  signal O010lO10       : std_logic;
  signal OOO1O1OO        : std_logic;
  signal I1O001OO          : std_logic;
  signal IOO11O11       : std_logic_vector(id_width-1 downto 0);
  signal OO1lIIO1      : std_logic;
  signal O00101I1     : std_logic_vector(l10I10O1-1 downto 0);
  signal O1O1IlO0     : std_logic_vector(bit_width(l10I10O1+1)-1 downto 0);

  signal OlI0OIOI    : std_logic_vector(id_width-1 downto 0);

  signal l1I101lO      : std_logic;
  signal OO1IOO00  : std_logic;
  signal I10l1lO0       : std_logic;
  signal O0O1011l         : std_logic;
  signal l0OOl11l      : std_logic_vector(id_width-1 downto 0);
  signal I0IOIl1O     : std_logic;
  signal IIO10010    : std_logic_vector(l10I10O1-1 downto 0);
  signal OOO0Ol0O    : std_logic_vector(bit_width(l10I10O1+1)-1 downto 0);

  signal OI0111OO      : std_logic;
  signal O01l001l       : std_logic;
  signal O0OO0OOl         : std_logic;
  signal OO111O10      : std_logic_vector(id_width-1 downto 0);
  signal l1OOI1O1     : std_logic;
  signal O00l0I1O    : std_logic_vector(l10I10O1-1 downto 0);
  signal OO000101    : std_logic_vector(bit_width(l10I10O1+1)-1 downto 0);

  signal OOOOlIO1  : std_logic;
  signal O10l0O0O : std_logic_vector(l10I10O1-1 downto 0);

  constant pl_id_reg_en_msb  : integer := maximum(0, in_reg+stages+out_reg-2);
  constant O11l1111     : integer := maximum(0, stages+out_reg-2);
  constant word_of_Xs_in_reg : std_logic_vector(data_width+chk_width-1 downto 0) := (others => 'X');
  constant word_of_Xs_wr_mode         : std_logic_vector((data_width+chk_width)-1 downto 0) := (others => 'X');
  constant word_of_Xs_rd_mode         : std_logic_vector((data_width+(chk_width*2)+2)-1 downto 0) := (others => 'X');
  constant word_of_Xs_id              : std_logic_vector(id_width-1 downto 0) := (others => 'X');
  signal merged_pl_reg_in_out_wr_mode : std_logic_vector(data_width+chk_width-1 downto 0);
  signal merged_pl_reg_in_out_rd_mode : std_logic_vector(data_width+chk_width-1 downto 0);
  signal merged_pl_reg_out_wr_mode    : std_logic_vector((data_width+chk_width)-1 downto 0);
  signal merged_pl_reg_out_rd_mode    : std_logic_vector((data_width+(chk_width*2)+2)-1 downto 0);

  signal clk_int            : std_logic;
  signal rst_n_a            : std_logic;
  signal rst_n_s            : std_logic;
  signal O0110101 : std_logic_vector(data_width+chk_width-1 downto 0);
  signal l1l0O01I : std_logic_vector(data_width+chk_width-1 downto 0);

  type pipe_id_T is array (0 to pl_id_reg_en_msb) of std_logic_vector(id_width-1 downto 0);
  type pipe_wr_mode_T is array (0 to O11l1111) of std_logic_vector((data_width+chk_width)-1 downto 0);
  type pipe_rd_mode_T is array (0 to O11l1111) of std_logic_vector((data_width+(chk_width*2)+2)-1 downto 0);
  signal OI0000O0    : pipe_wr_mode_T;
  signal OIOOl10l    : pipe_rd_mode_T;
  signal lO00O01l         : pipe_id_T;


   

type IO1Il001I is array (0 to (2**chk_width)-1) of INTEGER;
SIGNAL O11lIl10l : IO1Il001I;

subtype l00O0Il10 is std_logic_vector(data_width-1 downto 0);
type OO0O11I00 is array (0 to chk_width-1) of l00O0Il10;
CONSTANT O1Il0l0O1 : std_logic_vector(chk_width-1 downto 0)
				:= (others => '0');
SIGNAL l0O000lO0 : OO0O11I00;
SIGNAL IO0l0O111 : std_logic_vector(chk_width-1 downto 0);
SIGNAL O1Il0O1O0 : std_logic_vector(chk_width-1 downto 0);
SIGNAL lOI0l1lOO : std_logic_vector(data_width-1 downto 0);
SIGNAL OOOI110O0  : std_logic_vector(chk_width-1 downto 0);
SIGNAL lIO0OlOlO : std_logic;
SIGNAL O00O0OO01 : std_logic;
SIGNAL IOl01OOlI : INTEGER;


  function l0IOO110I(OOOO1OIO1: INTEGER) return INTEGER is
    variable l0I0O1llO: INTEGER;
  begin
    if (OOOO1OIO1 mod 2) = 0 then
      l0I0O1llO := OOOO1OIO1 + 1;
    else
      l0I0O1llO := OOOO1OIO1 - 1;
    end if;
    return l0I0O1llO;
  end l0IOO110I;


  function l0O0O1lI0(OOOO1OIO1: INTEGER) return INTEGER is
    variable l0I0O1llO: INTEGER;
    variable II1000l0l: INTEGER;
  begin
    l0I0O1llO := 0;
    II1000l0l := OOOO1OIO1;
    while (II1000l0l /= 0) loop
      if (II1000l0l mod 2) = 1 then
	l0I0O1llO := l0IOO110I(l0I0O1llO);
      end if;
      II1000l0l := II1000l0l / 2;
    end loop;
    return l0I0O1llO;
  end l0O0O1lI0;


  function IIIlIIO01(OOOO1OIO1: std_logic_vector; OO0101O01: INTEGER) return INTEGER is
    variable l0I0O1llO: INTEGER;
  begin
    l0I0O1llO := 0;
    for Ol01lIIO0 in OO0101O01-1 downto 0 loop
      l0I0O1llO := l0I0O1llO * 2;
      if (OOOO1OIO1(Ol01lIIO0) = '1') then
	l0I0O1llO := l0I0O1llO + 1;
      end if;
    end loop;
    return l0I0O1llO;
  end IIIlIIO01;


  function III110100( I00O00lI1, Ol01lIIO0 : in INTEGER ) return INTEGER is
    variable lOO01llO0 : INTEGER;
  begin
    if (I00O00lI1 > 0) then
      if (Ol01lIIO0 < 1) OR (Ol01lIIO0 > 5) then lOO01llO0 := 1;
      else lOO01llO0 := 0;
      end if;
    else
      if (Ol01lIIO0 < 1) then lOO01llO0 := 5;
      else
	if (Ol01lIIO0 < 3) then lOO01llO0 := 1;
	else lOO01llO0 := 0;
	end if;
      end if;
    end if;
    return lOO01llO0;
  end III110100;


  function O01OI111I( l1100110O : in INTEGER ) return INTEGER is
    variable II1000l0l : INTEGER;
    variable OIOO0I0lI : INTEGER;
  begin
    II1000l0l := l1100110O;
    OIOO0I0lI := 0;

    while (II1000l0l /= 0) loop
      if (II1000l0l mod 2 = 1) then
	OIOO0I0lI := OIOO0I0lI + 1;
      end if;

      II1000l0l := II1000l0l / 2;
    end loop;

    return OIOO0I0lI;
  end O01OI111I;


-- pragma translate_on

begin

-- pragma translate_off

  O1l01lO0I : process
    variable OOOlO0111 : INTEGER;
    variable Ol01lIIO0 : INTEGER;
    variable l101OO11I : INTEGER;
    variable OIl0OOIO0 : INTEGER;
    variable I00I0OOO0 : INTEGER;
    variable IOOlO1O00 : INTEGER;
    variable IOO0O11Il : INTEGER;
    variable I1OOIO10O : INTEGER;
    variable O1l10l1l0 : INTEGER;
    variable llO01l0l0 : INTEGER;
    variable O00101l00 : INTEGER;
    variable III1I0O00 : INTEGER;
    variable IIO1Il0ll : INTEGER;
    variable lO1IOO000 : INTEGER;
    variable I1O1l100l : INTEGER;
    variable O1IO0I01l : INTEGER;
    variable lOI1O1lOO : INTEGER;
    variable O0IO010O1 : INTEGER;
    variable llI1OI000 : INTEGER;
    variable O1l1lO0OO : INTEGER;
    variable l0110lO01 : INTEGER;
    variable O00100101 : INTEGER;
    variable OOlO0O0lO : INTEGER;
    variable l1Ol11100 : std_logic_vector(data_width-1 downto 0);
    type OI1II11lO is array (0 to (2**(chk_width-1))-1) of INTEGER;
    variable I0OOI1lO0 : OI1II11lO;
    variable llOO0l1lO : IO1Il001I := (others => -1);
  begin
    
    lOI1O1lOO := 3;
    I1OOIO10O := 2;
    llI1OI000 := I1OOIO10O ** chk_width;
    lOI1O1lOO := lOI1O1lOO + I1OOIO10O;
    OOOlO0111 := 1;
    l0110lO01 := llI1OI000 / (I1OOIO10O ** lOI1O1lOO);
    O00101l00 := 2 ** (I1OOIO10O+OOOlO0111+I1OOIO10O);

    O00100101 := l0110lO01 * I1OOIO10O;
    IOOlO1O00 := 0;
    O1l1lO0OO := lOI1O1lOO + llOO0l1lO(0);
    llO01l0l0 := O00101l00 + llOO0l1lO(1);
    I1O1l100l := 0;

    while (IOOlO1O00 < data_width) AND (I1O1l100l < O00100101) loop
      l101OO11I := I1O1l100l / I1OOIO10O;

      if ((I1O1l100l < 4) OR ((I1O1l100l > 8) AND (I1O1l100l >= (O00100101-4)))) then
	l101OO11I := l0IOO110I(l101OO11I);
      end if;

      if (l0O0O1lI0(I1O1l100l) = 0) then
	l101OO11I := l0110lO01-OOOlO0111-l101OO11I;
      end if;

      if (l0110lO01 = OOOlO0111) then
	l101OO11I := 0;
      end if;

      IOO0O11Il := 0;
      O1IO0I01l := l101OO11I * (I1OOIO10O ** lOI1O1lOO);

      if (I1O1l100l < l0110lO01) then
	IIO1Il0ll := 0;
	if (l0110lO01 > OOOlO0111) then
	  IIO1Il0ll := I1O1l100l mod 2;
	end if;

	O1l10l1l0 := III110100(IIO1Il0ll,0);

	O0IO010O1 := O1IO0I01l;
	while (O0IO010O1 < (O1IO0I01l+O00101l00)) AND (IOOlO1O00 < data_width) loop
	  lO1IOO000 := O01OI111I(O0IO010O1);
	  if (lO1IOO000 mod 2 = 1) then
	    if (O1l10l1l0 <= 0) then
	      if (lO1IOO000 > 1) then
		if (IOO0O11Il < 2) AND (IIO1Il0ll = 0) then
		  llOO0l1lO(O0IO010O1) := l0IOO110I(IOOlO1O00);
		  I0OOI1lO0(l0IOO110I(IOOlO1O00)) := O0IO010O1;
		else
		  llOO0l1lO(O0IO010O1) := IOOlO1O00;
		  I0OOI1lO0(IOOlO1O00) := O0IO010O1;
		end if;
		IOOlO1O00 := IOOlO1O00+1;
	      end if;

	      IOO0O11Il := IOO0O11Il + 1;

	      if (IOO0O11Il < 8) then
		O1l10l1l0 := III110100(IIO1Il0ll,IOO0O11Il);
	      else
		O0IO010O1 := O1IO0I01l+O00101l00;
	      end if;
	    else
	      
	      O1l10l1l0 := O1l10l1l0 - 1;
	    end if;
	  end if;
	  O0IO010O1 := O0IO010O1 + 1;
	end loop;

      else

        O0IO010O1 := O1IO0I01l+llO01l0l0;
        while (O0IO010O1 <= (O1IO0I01l+llO01l0l0) AND (O0IO010O1 >= O1IO0I01l) AND (IOOlO1O00 < data_width)) loop
	  lO1IOO000 := O01OI111I(O0IO010O1);

	  if (lO1IOO000 mod 2) = 1 then
	    if (lO1IOO000 > 1) AND (llOO0l1lO(O0IO010O1) < 0) then
	      llOO0l1lO(O0IO010O1) := IOOlO1O00;
	      I0OOI1lO0(IOOlO1O00) := O0IO010O1;
	      IOOlO1O00 := IOOlO1O00 + 1;
	    end if;
	  end if;
          O0IO010O1 := O0IO010O1 - 1;
	end loop;
      end if;

      I1O1l100l := I1O1l100l + 1;
    end loop;

    III1I0O00 := OOOlO0111 - 1;

    for O0IO010O1 in 0 to chk_width-1 loop
      OOlO0O0lO := 2 ** O0IO010O1;
      l1Ol11100 := (others => '0');
      for IOOlO1O00 in 0 to data_width-1 loop
	if ((I0OOI1lO0(IOOlO1O00)/OOlO0O0lO) mod 2) /= 0 then
	  l1Ol11100(IOOlO1O00) := '1';
	end if;
      end loop; -- IOOlO1O00
      l0O000lO0(O0IO010O1) <= l1Ol11100;
    end loop; -- O0IO010O1

    IOl01OOlI <= III1I0O00 - 1;

    for O0IO010O1 in 0 to chk_width-1 loop
      llOO0l1lO(I1OOIO10O**O0IO010O1) := data_width+O0IO010O1;
    end loop; -- O0IO010O1

    O11lIl10l <= llOO0l1lO;

    wait;
  end process O1l01lO0I;


  I1ll11lO0 : process(O1110110)
   variable lO00000Il : std_logic;
   variable O110O1Il0 : std_logic_vector(data_width-1 downto 0); begin
    if (Is_X(O1110110)) then
      IO0l0O111 <= (others => 'X');
    else
      for lO01IO0O in 0 to chk_width-1 loop
        lO00000Il := '0';
        O110O1Il0 := l0O000lO0(lO01IO0O) AND O1110110;
        for j in 0 to data_width-1 loop
	  if O110O1Il0(j)='1' then
	    lO00000Il := NOT lO00000Il;
	  end if;
        end loop;

        if (lO01IO0O=2) or (lO01IO0O=3) then
          IO0l0O111(lO01IO0O) <= NOT lO00000Il;
        else
          IO0l0O111(lO01IO0O) <= lO00000Il;
        end if;
      end loop;
    end if;
  end process I1ll11lO0;


  O1Il0O1O0 <= IO0l0O111 XOR OOOl1101;

  OO01IlO1O : process(O1Il0O1O0)
    variable IO11O1IIO : INTEGER;
  begin
    if (rw_mode = 0) then 
      if (Is_X(O1Il0O1O0)) then
	OOOI110O0 <= (others => 'X');
	lOI0l1lOO <= (others => 'X');
	lIO0OlOlO <= 'X';
	O00O0OO01 <= 'X';
      else
	OOOI110O0 <= (others => '0');
	lOI0l1lOO <= (others => '0');
	if (O1Il0O1O0 = O1Il0l0O1) then
	  lIO0OlOlO <= '0';
	  O00O0OO01 <= '0';
	else
	  IO11O1IIO := O11lIl10l(IIIlIIO01(O1Il0O1O0,chk_width));
	  if (IO11O1IIO = IOl01OOlI) then
	    lIO0OlOlO <= '1';
	    O00O0OO01 <= '1';
	  else
	    lIO0OlOlO <= '1';
	    O00O0OO01 <= '0';
	    if (IO11O1IIO < data_width) then
	      lOI0l1lOO(IO11O1IIO) <= '1';
	    else
	      OOOI110O0(IO11O1IIO-data_width) <= '1';
	    end if;
	  end if;
	end if;
      end if;
    elsif (rw_mode /= 1) then
      OOOI110O0 <= (others => 'X');
      lOI0l1lOO <= (others => 'X');
      lIO0OlOlO <= 'X';
      O00O0OO01 <= 'X';
    end if;
  end process OO01IlO1O;


    clk_int <= To_X01(clk);
    rst_n_a <= rst_n WHEN (rst_mode = 0) ELSE '1';
    rst_n_s <= To_X01(rst_n);
    O00IlO0I <= To_X01(datain);
    IOOI1O00 <= To_X01(chkin);
    O0lI0O1O <= To_X01(launch);
    O10O0O10 <= To_X01(launch_id);
    I1O0O1O1 <= To_X01(accept_n);

  O1110110 <= O1II11O1 when (rw_mode = 1) else OII1OOl0;
  OOOl1101  <= O01I11IO  when (rw_mode = 1) else I01OO00O;

    I10IO1Ol      <= O1110110 XOR lOI0l1lOO;
    OI1l0l00       <= OOOl1101 XOR OOOI110O0;
    O010010O      <= O1Il0O1O0;
    lO00l00I   <= lIO0OlOlO;
    I0O11O11 <= O00O0OO01;

  merged_pl_reg_in_out_rd_mode <= (O00IlO0I & IOOI1O00) when (in_reg = 0) else l1l0O01I;



  merged_pl_reg_out_rd_mode <= (I10IO1Ol & OI1l0l00 & O010010O & lO00l00I & I0O11O11) when ((stages+out_reg) = 1) else OIOOl10l(O11l1111);


    O001IOl1 <= O1110110;
    I101OO10  <= IO0l0O111;

  merged_pl_reg_in_out_wr_mode <= (O00IlO0I & IOOI1O00) when (in_reg = 0) else O0110101;



  merged_pl_reg_out_wr_mode <= (O001IOl1 & I101OO10) when ((stages+out_reg) = 1) else OI0000O0(O11l1111);



 O1II11O1 <= merged_pl_reg_in_out_wr_mode(data_width+chk_width-1 downto chk_width);
 O01I11IO  <= merged_pl_reg_in_out_wr_mode(chk_width-1 downto 0);

 I01ll0OO <= merged_pl_reg_out_wr_mode(data_width+chk_width-1 downto chk_width);
 Ol0I0lO1  <= merged_pl_reg_out_wr_mode(chk_width-1 downto 0);

 OII1OOl0 <= merged_pl_reg_in_out_rd_mode(data_width+chk_width-1 downto chk_width);
 I01OO00O  <= merged_pl_reg_in_out_rd_mode(chk_width-1 downto 0);

 O0llOO1O      <=  merged_pl_reg_out_rd_mode((data_width+(chk_width*2))+1 downto (chk_width*2)+2);
 IO1lO0l0       <=  merged_pl_reg_out_rd_mode((chk_width*2)+1 downto chk_width+2);
 II000OOO      <=  merged_pl_reg_out_rd_mode(chk_width+1 downto 2);
 I10O110O   <= merged_pl_reg_out_rd_mode(1);
 IO100O1I <= merged_pl_reg_out_rd_mode(0);





  OlI0OIOI <= O10O0O10 when ((in_reg+stages+out_reg) = 1) else lO00O01l(pl_id_reg_en_msb);




    U1 : DW_lp_pipe_mgr
        generic map (
          stages => l10I10O1,
          id_width => id_width )
        port map (
          clk => clk_int,
          rst_n => rst_n_a,
          init_n => rst_n_s,
          launch => O0lI0O1O,
          launch_id => O10O0O10,
          accept_n => I1O0O1O1,
          arrive => I1O001OO,
          arrive_id => IOO11O11,
          pipe_en_bus => O00101I1,
          pipe_full => O010lO10,
          pipe_ovf => OOO1O1OO,
          push_out_n => OO1lIIO1,
          pipe_census => O1O1IlO0 );


    O0O1011l         <= O0lI0O1O;
    l0OOl11l      <= O10O0O10;
    IIO10010    <= (others => '0');
    l1I101lO      <= I1O0O1O1;
    OO1IOO00  <= l1I101lO AND O0O1011l;
    I0IOIl1O     <= NOT(NOT(I1O0O1O1) AND O0lI0O1O);
    OOO0Ol0O    <= (others => '0');
      
    pipe_ctrl_out_int1: process (I1O001OO, O010lO10, OOO1O1OO, OO1lIIO1, O1O1IlO0,
                                 O0O1011l, l1I101lO, I10l1lO0, I0IOIl1O, OOO0Ol0O)
      begin
        if (no_pm=1) then
           O0OO0OOl       <= '0';
           OI0111OO    <= '0';
           O01l001l     <= '0';
           l1OOI1O1   <= '0';
           OO000101  <= (others => '0'); 
        else
           if ((in_reg+stages+out_reg) > 1) then
             O0OO0OOl       <= I1O001OO;
             OI0111OO    <= O010lO10;
             O01l001l     <= OOO1O1OO;
             l1OOI1O1   <= OO1lIIO1;
             OO000101  <= O1O1IlO0;
           else
             O0OO0OOl       <= O0O1011l;
             OI0111OO    <= l1I101lO;
             O01l001l     <= I10l1lO0;
             l1OOI1O1   <= I0IOIl1O;
             OO000101  <= OOO0Ol0O;
           end if;
        end if;
    end process pipe_ctrl_out_int1;

    pipe_ctrl_out_int2: process (launch, OlI0OIOI, IOO11O11, O00101I1, l0OOl11l, IIO10010)
      begin
        if ((in_reg+stages+out_reg) > 1) then
          if (no_pm=1) then
            OO111O10    <= OlI0OIOI;
            O00l0I1O  <= (others => launch);
          else
            OO111O10    <= IOO11O11;
            O00l0I1O  <= O00101I1;
          end if;
        else
          OO111O10    <= l0OOl11l;
          O00l0I1O  <= IIO10010;
        end if;
    end process pipe_ctrl_out_int2;


    OOOOlIO1 <= O00l0I1O(0);

    pipe_out_en_bus_PROC: process (O00l0I1O)
      begin
        if (in_reg = 1) then
          O10l0O0O(0) <= '0';
          for lO01IO0O in 1 to l10I10O1-1 loop
            O10l0O0O(lO01IO0O-1) <= O00l0I1O(lO01IO0O);
          end loop;
        else
          O10l0O0O <= O00l0I1O;
        end if;
    end process pipe_out_en_bus_PROC;


    sim_clk: process (clk_int, rst_n_a)
      variable lO01IO0O  : INTEGER;
      begin

        if (rst_n_a = '0') then
          I10l1lO0 <= '0';
        elsif (rst_n_a = '1') then
	  if (rising_edge(clk_int)) then
            if (rst_n_s = '0') then
              I10l1lO0 <= '0';
            elsif (rst_n_s = '1') then
              I10l1lO0 <= OO1IOO00;
            else
              I10l1lO0 <= 'X';
            end if;
          end if;
        else
          I10l1lO0 <= 'X';
	end if;

    end process;

    dataout_Xs    <= (others => 'X');
    chkout_Xs     <= (others => 'X');
    syndout_Xs    <= (others => 'X');

    outputs_proc: process (launch, O0llOO1O, I01ll0OO,
                           IO1lO0l0, Ol0I0lO1, II000OOO,
                           I10O110O, IO100O1I)
      begin
        if ((in_reg=0) AND (stages=1) AND (out_reg=0) AND (no_pm=0) AND (launch='0')) then
          dataout       <= (others => 'X');
          chkout        <= (others => 'X');
          syndout       <= (others => 'X');
          err_detect    <= 'X';
          err_multiple  <= 'X';
        else
          if (rw_mode=0) then
            dataout       <= O0llOO1O;
            chkout        <= IO1lO0l0;
            syndout       <= II000OOO;
            err_detect    <= I10O110O;
            err_multiple  <= IO100O1I;
          else
            dataout       <= I01ll0OO;
            chkout        <= Ol0I0lO1;
            syndout       <= (others => '0');
            err_detect    <= '0';
            err_multiple  <= '0';
          end if;
        end if;
    end process;
    

    pipe_ovf      <= O01l001l;
    pipe_full     <= OI0111OO;
    arrive        <= O0OO0OOl;
    arrive_id     <= OO111O10;
    push_out_n    <= l1OOI1O1;
    pipe_census   <= OO000101;


    
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
    
    if ( (data_width < 8) OR (data_width > 8178) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter data_width (legal range: 8 to 8178)"
        severity warning;
    end if;
    
    if ( (chk_width < 5) OR (chk_width > 14) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter chk_width (legal range: 5 to 14)"
        severity warning;
    end if;
    
    if ( (rw_mode < 0) OR (rw_mode > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter rw_mode (legal range: 0 to 1)"
        severity warning;
    end if;
    
    if ( (op_iso_mode < 0) OR (op_iso_mode > 4) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter op_iso_mode (legal range: 0 to 4)"
        severity warning;
    end if;
    
    if ( (id_width < 1) OR (id_width > 1024) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter id_width (legal range: 1 to 1024)"
        severity warning;
    end if;
    
    if ( (stages < 1) OR (stages > 1022) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter stages (legal range: 1 to 1022)"
        severity warning;
    end if;
    
    if ( (in_reg < 0) OR (in_reg > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter in_reg (legal range: 0 to 1)"
        severity warning;
    end if;
    
    if ( (out_reg < 0) OR (out_reg > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter out_reg (legal range: 0 to 1)"
        severity warning;
    end if;
    
    if ( (no_pm < 0) OR (no_pm > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter no_pm (legal range: 0 to 1)"
        severity warning;
    end if;
    
    if ( (rst_mode < 0) OR (rst_mode > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter rst_mode (legal range: 0 to 1)"
        severity warning;
    end if;
    
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;

    
  monitor_clk  : process (clk) begin

    assert NOT (Is_X( clk ) AND (now > 0 ns)) 
      report "WARNING: Detected unknown value on the clock input port clk."
      severity warning;

  end process monitor_clk ;

-- pragma translate_on 
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

library dw03;

configuration DW_lp_piped_ecc_cfg_sim of DW_lp_piped_ecc is
 for sim
    for U1 : DW_lp_pipe_mgr use configuration dw03.DW_lp_pipe_mgr_cfg_sim; end for;
 end for; -- sim
end DW_lp_piped_ecc_cfg_sim;
-- pragma translate_on

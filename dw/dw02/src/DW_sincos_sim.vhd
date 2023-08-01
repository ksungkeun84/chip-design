--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2008 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Kyung-Nam Han  Jul. 7, 2008
--
-- VERSION:   VHDL Simulation Model of DW_sincos
--
-- DesignWare_version: 0968a0fe
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------


--
-- ABSTRACT: Fixed-Point Sine/Cosine Unit
--
--              DW_sincos calculates the fixed-point sine/cosine 
--              function. 
--
--              parameters      valid values (defined in the DW manual)
--              ==========      ============
--              A_width         input,      2 to 34 bits
--              WAVE_width      output,     2 to 34 bits
--              arch            implementation select
--                              0 - area optimized (default)
--                              1 - speed optimized
--              err_range       error range of the result compared to the
--                              true result
--                              1 - 1 ulp error (default)
--                              2 - 2 ulp error
--
--              Input ports     Size & Description
--              ===========     ==================
--              A               A_width bits
--                              Fixed-point Number Input
--              SIN_COS         1 bit
--                              Operator Selector
--                              0 - sine, 1 - cosine
--              WAVE            WAVE_width bits
--                              Fixed-point Number Output
--
-- MIDIFIED:
--   09/08/08 Kyung-Nam Han
--            Improved QoR when A_width > WAVE_width
--   06/16/10 Kyung-Nam Han (STAR 9000400672)
--            DW_sincos has 2 ulp erros when A_width<=9, err_range=1. 
--            Fixed from D-2010.03-SP3.
--   03/02/15 Kyung-Nam Han (STAR 9000862271, 9000855825)
--            Fixed 1 ulp error and out-range-error when
--            9 <= A_width <= 15 and 14 <= WAVE_width <= 16. 
------------------------------------------------------------------------------

library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_misc.all;
use ieee.numeric_std.all;
use DWARE.DW_Foundation_arith.all;

architecture sim of DW_sincos is
	

  -- pragma translate_off

  constant IOI1O1O1: integer := 0;

  constant lO00001O: integer := 1;

  function O001IIOI (l1OIO110, IO11O0O0, IO11l10I: integer) return integer is
  begin
    if (IO11O0O0 >= l1OIO110 + 1) then
      return (IO11O0O0 - 1);
    elsif ((l1OIO110 = IO11O0O0) or (IO11l10I= 1)) then
      return (l1OIO110);
    else 
      return (IO11O0O0 + 1);
    end if;
  end O001IIOI;

  function O10lOOll (l1OIO110, IO11O0O0, IO11l10I: integer) return integer is
  begin
    if (IO11O0O0 >= l1OIO110 + 1) then
      return (IO11O0O0);
    elsif ((l1OIO110 = IO11O0O0) or (IO11l10I= 1)) then
      return (l1OIO110 + 1);
    else
      return (IO11O0O0);
    end if;
  end O10lOOll;

  function Ill0lO10 (l1OIO110, IO11O0O0, IO11l10I: integer) return integer is
  begin
    if (IO11O0O0 >= l1OIO110 + 1) then
      return (IO11l10I);
    else
      return (1);
    end if;
  end Ill0lO10;

  function O11I00ll (O111OOOI, l1OIO110: boolean) return boolean is
  begin
    if (O111OOOI = true) then
      return (true);
    else
      return (l1OIO110);
    end if;
  end O11I00ll;

  function l1OI0101 (O10IOOOl: boolean) return integer is
  begin
    if (O10IOOOl = true) then
      return (1);
    else
      return (err_range);
    end if;
  end l1OI0101;

  constant O0Ol1101: boolean := (A_width >= 9) and (A_width <= 15) and (WAVE_width >= 14) and (WAVE_width <= 15) and (lO00001O = 1);
  constant O11l1lO1: boolean := (A_width >= 9) and (A_width <= 15) and (WAVE_width = 16) and (lO00001O = 1);
  constant I00II0OO: boolean := O0Ol1101 or O11l1lO1;
  constant O10001I1: integer := l1OI0101(O0Ol1101);

  constant O000l11O: integer := O001IIOI(A_width, WAVE_width, O10001I1);
  constant I0lOOI1I: integer := O10lOOll(A_width, WAVE_width, O10001I1);
  constant ll0Ill00: integer := Ill0lO10(A_width, WAVE_width, O10001I1);

  constant l100Oll1: boolean := (O000l11O >= 10) and (O000l11O <= 14);
  constant I101I1lO: boolean := O11I00ll(O0Ol1101, l100Oll1);


  function O0OlO0II (IO11010I, OIO0O110: integer) return integer is
  begin
    if ((IO11010I >= 11 and IO11010I <= 24) or ((IO11010I = 25) and (OIO0O110 = 2))) then
      return (6);
    else
      return (7);
    end if;
  end O0OlO0II;

  function I00Ol1O1 (O000l11O, I01O10OI, OO1OI1Ol: integer) return integer is
  begin
    if (O000l11O <= 9) then
      return (1);
    else
      return (I01O10OI - (1 + OO1OI1Ol));
    end if;
  end I00Ol1O1;

  function O1O0l111 (O000l11O, OO1OI1Ol: integer) return integer is
  begin
    if (O000l11O <= 9) then
      return (1);
    else
      return (O000l11O - 2 - OO1OI1Ol);
    end if;
  end O1O0l111;

  function OI0I11O1 (O000l11O, l10IO101: integer) return integer is
  begin
    if ((O000l11O <= 9) or I101I1lO) then
      return (1);
    else
      return (l10IO101 + 2);
    end if;
  end OI0I11O1;

  function llI1OI0l (O000l11O, ll0OlOOl: integer) return integer is
  begin
    if ((O000l11O <= 9) or I101I1lO) then
      return (1);
    else
      return (ll0OlOOl + 2);
    end if;
  end llI1OI0l;

  function lI1O111O (O000l11O, l10IO101: integer) return integer is
  begin
    if ((O000l11O <= 9) or I101I1lO) then
      return (1);
    else
      return (l10IO101 + 3);
    end if;
  end lI1O111O;

  constant IOO0O0OI: integer := O0OlO0II(I0lOOI1I, ll0Ill00);
  constant O1O11O0l: integer := ((I0lOOI1I - 2) + (2 - ll0Ill00) + 2);
  constant OOl1OI11: integer := I00Ol1O1(O000l11O, O1O11O0l, IOO0O0OI);
  constant IIO1O1O1: integer := O1O11O0l - 2 * (1 + IOO0O0OI);
  constant I10l0lIO: integer := O1O11O0l - 3 * (1 + IOO0O0OI);
  constant I01000Ol: integer := OI0I11O1(O000l11O, IIO1O1O1);
  constant lOlO10O0: integer := llI1OI0l(O000l11O, I01000Ol);
  constant O001l00I: integer := 2 * lOlO10O0;
  constant l001O0ll: integer := lI1O111O(O000l11O, IIO1O1O1);
  constant I001O1OI: integer := OOl1OI11 + 1;
  constant OIO00lOO: integer := OOl1OI11 + 2;
  constant I000O101: integer := O1O0l111(O000l11O, IOO0O0OI);
  constant l0l1O000: integer := I000O101 + (2 - ll0Ill00);
  constant l011OlIO: integer := I001O1OI + l0l1O000;

  function I1IO1lOO (lO10l1O1: integer) return integer is
  begin
    if (lO10l1O1 = 6) then
      return (13);
    else
      return (14);
    end if;
  end I1IO1lOO;

  function II1I1OO0 (IOO0O0OI: integer) return integer is
  begin
    if (IOO0O0OI = 6) then
      return (19);
    else
      return (21);
    end if;
  end II1I1OO0;

  function l1O0OI01 (lO10l1O1: integer) return integer is
  begin
    if (lO10l1O1 = 6) then
      return (26);
    else
      return (29);
    end if;
  end l1O0OI01;

  function OI10OIO1 (lO10l1O1: integer) return integer is
  begin
    if (lO10l1O1 = 6) then
      return (19 - I001O1OI);
    else
      return (0);
    end if;
  end OI10OIO1;

  function OOOII0l0 (O000l11O, IIO1O1O1: integer) return integer is
  begin
    if ((O000l11O <= 9) or I101I1lO) then
      return (1);
    else
      return (IIO1O1O1 + 2);
    end if;
  end OOOII0l0;

  function IOO1OOlO (O000l11O, IIO1O1O1: integer) return integer is
  begin
    if ((O000l11O <= 9) or I101I1lO) then
      return (1);
    else
      return (IIO1O1O1 + 2);
    end if;
  end IOO1OOlO;

  function OI0lOOOI (O000l11O, I10l0lIO: integer) return integer is
  begin
    if (O000l11O >= 26) then
      return (I10l0lIO + 2);
    else
      return (1);
    end if;
  end OI0lOOOI;

  function lO1l0l11 (O000l11O, IIO1O1O1: integer) return integer is
  begin
    if ((O000l11O <= 9) or I101I1lO) then
      return (1);
    else
      return (IIO1O1O1 + 2);
    end if;
  end lO1l0l11;

  function O1IIOO00 (O000l11O, I0lOOI1I, IOO0O0OI, ll0Ill00: integer) return integer is
  begin
    if (O000l11O <= 9) then
      return (1);
    else
      return (I0lOOI1I - IOO0O0OI + (3 - ll0Ill00));
    end if;
  end O1IIOO00;

  function l0l0l00O (O000l11O, lOIIOlOl: integer) return integer is
  begin
    if (O000l11O <= 9) then
      return (29 - lOIIOlOl);
    else
      return (0);
    end if;
  end l0l0l00O;

  constant OOOO11lO: integer := I1IO1lOO(IOO0O0OI);
  constant OO0OOO0l: integer := II1I1OO0(IOO0O0OI);
  constant OI10IIO1: integer := l1O0OI01(IOO0O0OI);
  constant OO01OOOO: integer := OOOII0l0(O000l11O, IIO1O1O1);
  constant I0I0l110: integer := IOO1OOlO(O000l11O, IIO1O1O1);
  constant OIlO01OI: integer := OI0lOOOI(O000l11O, I10l0lIO);
  constant O00I0011: integer := lO1l0l11(O000l11O, IIO1O1O1);
  constant O001OO10: integer := O1IIOO00(O000l11O, I0lOOI1I, IOO0O0OI, ll0Ill00);
  constant I000lO0I: integer := I0I0l110 + OO01OOOO;
  constant Il10O1O0: integer := I001O1OI + l0l1O000;
  constant O1lOIIOI: integer := OI10OIO1(IOO0O0OI);
  constant lO10001O: integer := I01000Ol + I0I0l110;
  constant lOIIOlOl: integer := I0lOOI1I - 2;
  constant l0l1O1Ol: integer := l0l0l00O(O000l11O, lOIIOlOl);

  function IO0IO0O0 (O000l11O, IOO0O0OI: integer) return integer is
  begin
    if (O000l11O <= 9) then
      return (O000l11O - 2);
    else
      return (IOO0O0OI);
    end if;
  end IO0IO0O0;

  function OO1OO001 (O000l11O, O001ll11: integer) return integer is
  begin
    if I101I1lO then
      return (0);
    else
      return (O001ll11);
    end if;
  end OO1OO001;

  function O1IOI0OI (IOO0O0OI: integer) return integer is
  begin
    if (IOO0O0OI = 6) then
      return (26 - 1);
    else
      return (0);
    end if;
  end O1IOI0OI;

  function OOO0O01O (IOO0O0OI, O1O11O0l: integer) return integer is
  begin
    if (IOO0O0OI = 6) then
      return (26 - O1O11O0l);
    else
      return (0);
    end if;
  end OOO0O01O;

  function OOIlOO00 (IOO0O0OI: integer) return integer is
  begin
    if (IOO0O0OI = 6) then
      return (13 - 1);
    else
      return (0);
    end if;
  end OOIlOO00;

  function l0OI100I (IOO0O0OI, I0I0l110: integer) return integer is
  begin
    if (IOO0O0OI = 6) then
      return (13 - I0I0l110);
    else
      return (0);
    end if;
  end l0OI100I;

  function l01O10l0 (I0I0l110: integer) return integer is
  begin
    if (O000l11O >= 26) then
      return (0);
    else
      return (14 - I0I0l110);
    end if;
  end l01O10l0;

  function lOO01IO1 (I001O1OI: integer) return integer is
  begin
    if (O000l11O >= 26) then
      return (0);
    else
      return (21 - I001O1OI);
    end if;
  end lOO01IO1;

  function Ol00I1OO (O1O11O0l: integer) return integer is
  begin
    if (O000l11O >= 26) then
      return (0);
    else
      return (29 - O1O11O0l);
    end if;
  end Ol00I1OO;

  function O1111O0l (O000l11O, I01000Ol, lOlO10O0: integer) return integer is
  begin
     return (I01000Ol + lOlO10O0);
  end O1111O0l;

  function II11110l (O000l11O, I10l0lIO: integer) return integer is
  begin
    if (O000l11O >= 26) then
      return (I10l0lIO + 2);
    else
      return (1);
    end if;
  end II11110l;

  function O0OOOl1I (O000l11O, I10l0lIO: integer) return integer is
  begin
    if (O000l11O >= 26) then
      return (I10l0lIO + 3);
    else
      return (1);
    end if;
  end O0OOOl1I;

  function Ol0I1OI0 (O000l11O, I10l0lIO: integer) return integer is
  begin
    if (O000l11O >= 26) then
      return (I10l0lIO + 3);
    else
      return (1);
    end if;
  end Ol0I1OI0;

  function l010I101 (O000l11O, I10l0lIO: integer) return integer is
  begin
    if (O000l11O >= 26) then
      return (I10l0lIO + 2);
    else
      return (1);
    end if;
  end l010I101;

  constant II0O01O1: integer := IO0IO0O0(O000l11O, IOO0O0OI);
  constant OIO1101l: integer := OO1OO001(O000l11O, arch);
  constant OIlI0001: integer := O1IOI0OI(IOO0O0OI);
  constant OI0OOl0I: integer := OOO0O01O(IOO0O0OI, O1O11O0l);
  constant OIOlOl00: integer := OOIlOO00(IOO0O0OI);
  constant lO010111: integer := l0OI100I(IOO0O0OI, I0I0l110);
  constant I0lIOl0O: integer := l01O10l0(I0I0l110);
  constant l0OOI0I1: integer := lOO01IO1(I001O1OI);
  constant l1l10lI0: integer := Ol00I1OO(O1O11O0l);
  constant OO1OI111: integer := O1111O0l(O000l11O, I01000Ol, lOlO10O0);
  constant l111l0II: integer := II11110l(O000l11O, I10l0lIO);
  constant O0lOI1l1: integer := O0OOOl1I(O000l11O, I10l0lIO);
  constant l0O110I0: integer := O0lOI1l1 + l111l0II;
  constant I0O00OI0: integer := Ol0I1OI0(O000l11O, I10l0lIO);
  constant II110O10: integer := l010I101(O000l11O, I10l0lIO);
  constant O1O1OIO0: integer := O0lOI1l1 + II110O10;

  function O01OlI0l (O000l11O, IOO0O0OI: integer) return integer is
  begin
    if (O000l11O <= 9) then
      return 0;
    else
      return (O000l11O - 3 - IOO0O0OI);
    end if;
  end O01OlI0l;

  function OI1100OO (O000l11O: integer) return integer is
  begin
    if (O000l11O = 2) then
      return (0);
    else
      return (O000l11O - 3);
    end if;
  end OI1100OO;

  function OI1Ol100 (O000l11O, IOO0O0OI: integer) return integer is
  begin
    if (O000l11O <= 9) then
      return (0);
    else
      return (O000l11O - 2 - IOO0O0OI);
    end if;
  end OI1Ol100;

  function lO100010 (O000l11O, II0O01O1: integer) return integer is
  begin
    if O000l11O < 9 then
      return (7 - II0O01O1);
    else
      return (1);
    end if;
  end lO100010;

  constant O0l1O1l0: integer := OI1100OO(O000l11O);
  constant OOll1OO0: integer := OI1Ol100(O000l11O, IOO0O0OI);
  constant O01I1l01: integer := O01OlI0l(O000l11O, IOO0O0OI);
  constant l1lIO0O1: integer := lO100010(O000l11O, II0O01O1);

  function lOII1101 (A_width, I0lOOI1I: integer) return integer is
  begin
    if (I0lOOI1I > A_width + 1) then
      return (I0lOOI1I - A_width - 1);
    else
      return (1);
    end if;
  end lOII1101;

  constant O0l1Ol0O: integer := lOII1101(A_width, I0lOOI1I);

  function IOOIOI00 (l1OIO110, IO11O0O0, O001OO1O: integer) return integer is
  begin
    if (IO11O0O0 >= l1OIO110 + 1) then
      return (0);
    else 
      return (l1OIO110 - O001OO1O);
    end if;
  end IOOIOI00;

  constant Ol001II0: integer := IOOIOI00(A_width, I0lOOI1I, O000l11O);

  constant l0OO11l1: integer := 19 - 9;
  constant Ol1OlOO1: integer := O1O11O0l;
  constant O0Ol0ll1: integer := l0OO11l1 + l0l1O000;
  constant O001Il0I: integer := Ol1OlOO1 + 1;
  signal Il0Olll0: std_logic_vector(l0OO11l1 - 1 downto 0);
  signal l11011lI: std_logic_vector(Ol1OlOO1 - 1 downto 0);
  signal lI10lIO1: std_logic_vector(O001OO10 - 1 downto 0);
  signal OOOOIO0I: std_logic_vector(O0Ol0ll1 - 1 downto 0);
  signal lOOl0O1l: std_logic_vector(O001Il0I - 1 downto 0);

  signal I11O10O1: std_logic_vector(O000l11O - 1 downto 0);
  signal O11O100O: std_logic_vector(I0lOOI1I - 1 downto 0);
  signal OO1100OI: std_logic_vector(I0lOOI1I - 1 downto 0);
  signal l1OIl011: std_logic_vector(I0lOOI1I - 1 downto 0);
  signal O1010OI0: std_logic_vector(I0lOOI1I - 1 downto 0);
  signal O100OO1l: std_logic_vector(O000l11O downto 0);
  signal l01Ol010: std_logic_vector(O000l11O downto 0);
  signal IO0O011O: std_logic_vector(O0l1O1l0 - OOll1OO0 downto 0);
  signal I0100000: std_logic_vector(6 downto 0);
  signal O1011OOO: std_logic_vector(O01I1l01 downto 0);
  signal OlO01lOO: std_logic_vector(l0l1O000 - 1 downto 0);
  signal l1IOl0O0: std_logic_vector(l0l1O000 - 1 downto 0);
  signal OI00I100: std_logic_vector(lOlO10O0 - 1 downto 0);
  signal lOl00Il0: std_logic_vector(O001l00I - 1 downto 0);
  signal O10OOI11: std_logic_vector(I01000Ol - 1 downto 0);
  signal O1O0lOIO: std_logic_vector(OO1OI111 - 1 downto 0);
  signal O11O1001: std_logic_vector(l111l0II - 1 downto 0);
  signal l1OlO0O0: std_logic_vector(I0I0l110 - 1 downto 0);
  signal O0O011O1: std_logic_vector(O0lOI1l1 - 1 downto 0);
  signal O10O10O1: std_logic_vector(lO10001O - 1 downto 0);
  signal I1000l11: std_logic_vector(l0O110I0 - 1 downto 0);
  signal OI00O010: std_logic_vector(l001O0ll - 1 downto 0);
  signal OllO1OOO: std_logic_vector(I0O00OI0 - 1 downto 0);
  signal O00O01OO: std_logic_vector(l011OlIO - 1 downto 0);
  signal l1l0O1ll: std_logic_vector(OIO00lOO - 1 downto 0);
  signal O1OI0lI0: std_logic_vector(O1O11O0l downto 0);
  signal O0l0O001: std_logic_vector(O1O11O0l downto 0);
  signal I100II10: std_logic_vector(O1O1OIO0 - 1 downto 0);
  signal I1llOOlO: std_logic_vector(I000lO0I - 1 downto 0);
  signal OOI00OO0: std_logic_vector(OIlO01OI - 1 downto 0);
  signal ll0100O0: std_logic_vector(O00I0011 - 1 downto 0);
  signal lO01000I: std_logic_vector(Il10O1O0 - 1 downto 0);
  signal O00011O0: std_logic_vector(O001OO10 - 1 downto 0);
  signal O0lIOO00: std_logic_vector(I0I0l110 - 1 downto 0);
  signal lO11O100: std_logic_vector(I001O1OI - 1 downto 0);
  signal O10001lO: std_logic_vector(lOIIOlOl - 1 downto 0);
  signal I1OOOIO0: std_logic_vector(I0lOOI1I - 1 downto 0);
  signal OllIOOOl: std_logic_vector(I0lOOI1I - 1 downto 0);
  signal O1101O1O: std_logic_vector(I0lOOI1I - 1 downto 0);
  signal l111OII0: std_logic_vector(I0lOOI1I - 3 downto 0);
  signal OOOOOOO1: std_logic;
  signal O0OOOI1l: std_logic;
  signal lIlO0l1O: std_logic;
  signal II1OOOI1: std_logic;
  signal O01OI010: std_logic;
  signal l10l0Il1: std_logic;
  signal O11llOOl: std_logic;
  signal l001OOll: std_logic_vector(I0lOOI1I - 1 downto 0);
  signal I10OII11: std_logic_vector(I0lOOI1I - 1 downto 0);
  signal O10101lO: std_logic_vector(I0lOOI1I - 1 downto 0);
  signal I10l0OIO: std_logic_vector(I0lOOI1I - 1 downto 0);
  signal lO0O1I0l: std_logic_vector(I001O1OI - 1 downto 0);
  signal O11I00II: std_logic_vector(O1O11O0l - 1 downto 0);
  signal OI110IIO: std_logic_vector(I001O1OI - 1 downto 0);
  signal O0000OlI: std_logic_vector(O1O11O0l downto 0);
  signal O1I000O1: std_logic_vector(O1O11O0l downto 0);
  signal I1OI1110: std_logic_vector(14 - 1 downto 0);
  signal OOOl0110: std_logic_vector(21 - 1 downto 0);
  signal O0II010O: std_logic_vector(29 - 1 downto 0);
  signal l111OlOl: std_logic_vector(13 - 1 downto 0);
  signal IlI0O01I: std_logic_vector(19 - 1 downto 0);
  signal OOO011lO: std_logic_vector(26 - 1 downto 0);
  signal l0011l0O: std_logic_vector(15 - 1 downto 0);
  signal l1101IO0: std_logic_vector(22  - 1 downto 0);
  signal O1O1O1l1: std_logic_vector(29 - 1 downto 0);
  signal OOOI0lO1: std_logic_vector(37 - 1 downto 0);
  signal OI0I1O1O: std_logic_vector(19 - 1 downto 0);
  signal ll0IO001: std_logic_vector(26 - 1 downto 0);
  signal OII1OIl1: std_logic_vector(O000l11O - 2 downto 0);
  signal l1OO1III: std_logic_vector((O1O11O0l - OIO00lOO) - 1 downto 0);
  signal O1Il1001: std_logic_vector((O1O11O0l - l001O0ll) - 1 downto 0);
  signal ll1lO0O1: std_logic_vector((O1O11O0l - I0O00OI0) - 1 downto 0);
  signal O1ll1II1: std_logic_vector((I001O1OI - O00I0011) - 1 downto 0);
  signal l0l0lIOO: std_logic_vector((O1O11O0l - O001OO10) - 1 downto 0);
  signal Ol101IO0: std_logic_vector(I0lOOI1I - 1 downto 0);
  signal II10O0O0: std_logic_vector((I0lOOI1I - (O1O11O0l + ll0Ill00 - 3) - 1) downto 0);
  signal OlO111OO: std_logic_vector(I0lOOI1I - 2 downto 0);
  signal O100OO00: std_logic_vector(I0lOOI1I - 3 downto 0);
  signal IOOOO001: std_logic_vector(I0lOOI1I - 1 downto 0);
  signal O0OOOl1O: std_logic_vector((I0lOOI1I - (O1O11O0l + ll0Ill00 - 3) - 1) downto 0);
  signal O11OIOll: std_logic_vector(I0lOOI1I - 2 downto 0);
  signal l0l11Ol1: std_logic_vector(l1lIO0O1 - 1 downto 0);
  signal OIOII100: std_logic_vector(I0lOOI1I - 3 downto 0);
  signal OI100IO0: std_logic_vector(O0l1Ol0O - 1 downto 0);
  signal O1OlO010: std_logic_vector(I0lOOI1I - 1 downto 0);
  signal Ol0O1O0O: std_logic;
  signal IIl10O00: std_logic_vector(O000l11O - 3 downto 0);
  signal O0Ol0I1O: std_logic;
  signal l0O01001: std_logic_vector(l0OO11l1 - 1 downto 0);
  signal I0I10IlO: std_logic_vector(O1O11O0l downto 0);

-- pragma translate_on

begin

-- pragma translate_off

  
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
    
    if ( (A_width < 2) OR (A_width > 34) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter A_width (legal range: 2 to 34)"
        severity warning;
    end if;
    
    if ( (I0lOOI1I < 2) OR (I0lOOI1I > 35) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter I0lOOI1I (legal range: 2 to 35)"
        severity warning;
    end if;
    
    if ( (arch < 0) OR (arch > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter arch (legal range: 0 to 1)"
        severity warning;
    end if;
    
    if ( (err_range < 1) OR (err_range > 2) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter err_range (legal range: 1 to 2)"
        severity warning;
    end if;
  
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;

  OII1OIl1 <= (others => '0'); 
  l1OO1III <= (others => '0');
  O1Il1001 <= (others => '0');
  ll1lO0O1 <= (others => '0');
  O1ll1II1 <= (others => '0');
  l0l0lIOO <= (others => '0');
  OlO111OO <= (others => '0');
  II10O0O0 <= (others => '0');
  O100OO00 <= (others => '0');
  O11OIOll <= (others => '0');
  O0OOOl1O <= (others => '0');
  l0l11Ol1 <= (others => '0');
  OIOII100 <= (others => '0');
  OI100IO0 <= (others => '0');
  I11O10O1 <= A & OI100IO0 when (I0lOOI1I > A_width + 1) else
           A(A_width - 1 downto Ol001II0);


  OOOOOOO1 <= '0' when ((SIN_COS = '0' and 
                       ((I11O10O1(O000l11O - 1 downto O000l11O - 2) = "00") or 
                        (I11O10O1(O000l11O - 1 downto O000l11O - 2) = "10"))) or
                      (SIN_COS = '1' and 
                       ((I11O10O1(O000l11O - 1 downto O000l11O - 2) = "01") or 
                        (I11O10O1(O000l11O - 1 downto O000l11O - 2) = "11")))) else 
            '1';
  O0OOOI1l  <= '0' when ((SIN_COS = '0' and 
                       ((I11O10O1(O000l11O - 1 downto O000l11O - 2) = "00") or 
                        (I11O10O1(O000l11O - 1 downto O000l11O - 2) = "01"))) or
                      (SIN_COS = '1' and 
                       ((I11O10O1(O000l11O - 1 downto O000l11O - 2) = "00") or 
                        (I11O10O1(O000l11O - 1 downto O000l11O - 2) = "11")))) else 
            '1';

  IIl10O00 <= (others => '0');

  O0Ol0I1O <= '1' when ((SIN_COS = '0' and
                         I11O10O1(O000l11O - 2) = '1' and
                         I11O10O1(O000l11O - 3 downto 0) = IIl10O00) or
                         (SIN_COS = '1' and
                         I11O10O1(O000l11O -2 downto 0) = '0' & IIl10O00)) else
               '0';

  l01Ol010 <= ("11" & not I11O10O1(O000l11O - 2 downto 0)) + 1 when (O000l11O <= 9) else
           ("01" & OII1OIl1) - ("00" & I11O10O1(O000l11O - 2 downto 0));
  O100OO1l <= l01Ol010 when OOOOOOO1 = '1' else 
          ("00" & I11O10O1(O000l11O - 2 downto 0));
  l10l0Il1 <= '1' when (O100OO1l(O000l11O - 1 downto O000l11O - 2) = "01") else
                       '0';
  O11llOOl <= '1' when (O100OO1l(O000l11O - 1 downto O000l11O - 2) = "10") else
                      '0';
  O01OI010 <= O11llOOl when SIN_COS = '1' else
           l10l0Il1;

  IO0O011O <= O100OO1l(O0l1O1l0 downto OOll1OO0);

  O1011OOO <= O100OO1l(O01I1l01 downto 0);
  OlO01lOO <= (O1011OOO & '0') when ll0Ill00 = 1 else O1011OOO;

  I0100000 <= l0l11Ol1 when O000l11O = 2 else
                 IO0O011O & l0l11Ol1 when (O000l11O >= 3 and O000l11O <= 8) else
                 '0' & IO0O011O when (IOO0O0OI = 6 and O000l11O > 9) else
                 IO0O011O;
  l1IOl0O0 <= OlO01lOO;

  OI00I100 <= l1IOl0O0(l0l1O000 - 1 downto l0l1O000 - lOlO10O0);
  lOl00Il0 <= OI00I100 * OI00I100;
  O10OOI11 <= lOl00Il0(O001l00I - 1 downto O001l00I - I01000Ol);

  O1O0lOIO <= O10OOI11 * OI00I100;
  O11O1001 <= O1O0lOIO(OO1OI111 - 1 downto OO1OI111 - l111l0II);

  O0O011O1 <= l0011l0O(15 - 1 downto 15 - O0lOI1l1) when (O000l11O >= 26) else
        (others => '0');
  I1000l11 <= O0O011O1 * O11O1001;
  OllO1OOO <= I1000l11(l0O110I0 - 1 downto l0O110I0 - I0O00OI0) when (O000l11O >= 26) else
               (others => '0');

  l1OlO0O0 <= (others => '0') when (I101I1lO or (O000l11O <= 9)) else
        l1101IO0(22  - 1 downto 22  - I0I0l110) when (O000l11O >= 26) else
        l111OlOl(OIOlOl00 downto lO010111) when IOO0O0OI = 6 else 
        I1OI1110(14 - 1 downto I0lIOl0O);
  O10O10O1 <= l1OlO0O0 * O10OOI11;
  OI00O010 <= O10O10O1(lO10001O - 1 downto lO10001O - l001O0ll);
          
  
  DW_I00I10OO: if (O0Ol1101 = true) generate
  begin
    Il0Olll0 <= OI0I1O1O(19 - 1 downto 9);
  end generate DW_I00I10OO;

  DW_O1l0O101: if (O0Ol1101 = false) generate
  begin
    lO0O1I0l <= (others => '0') when (O000l11O <= 9) else
          O1O1O1l1(29 - 1 downto 29 - I001O1OI) when (O000l11O >= 26) else
          IlI0O01I(19 - 1 downto O1lOIIOI) when IOO0O0OI = 6 else 
          OOOl0110(21 - 1 downto l0OOI0I1);
  end generate DW_O1l0O101;

  O00O01OO <= lO0O1I0l * l1IOl0O0;
  l1l0O1ll <= O00O01OO(l011OlIO - 1 downto l011OlIO - OIO00lOO);

  DW_ll1IlI0O: if (O0Ol1101 = true) generate
  begin
    l11011lI <= ll0IO001(26 - 1 downto 26 - O1O11O0l);
  end generate DW_ll1IlI0O;

  DW_l1OO0110: if (O0Ol1101 = false) generate
  begin
    O11I00II <= OOOI0lO1(37 - 1 downto 37 - O1O11O0l) when (O000l11O >= 26) else
          OOO011lO(OIlI0001 downto OI0OOl0I) when (IOO0O0OI = 6) else 
          O0II010O(29 - 1 downto l1l10lI0);
  end generate DW_l1OO0110;

  O0l0O001 <= ('0' & O11I00II) + ('0' & l1OO1III & l1l0O1ll) - ('0' & O1Il1001 & OI00O010) - ('0' & ll1lO0O1 & OllO1OOO);

  lIlO0l1O <= O0l0O001(2) when ll0Ill00 = 1 else '0';

  IOOOO001 <= (O0OOOl1O & O0l0O001(O1O11O0l downto 4 - ll0Ill00)) + (O11OIOll & lIlO0l1O);
  l001OOll <= IOOOO001;

  GEN_z1_1: if IOI1O1O1 = 1 generate
  begin
    I10OII11(0) <= '0' when (l001OOll(I0lOOI1I - 2) = '1') else
                    l001OOll(0);
    I10OII11(I0lOOI1I - 1 downto 1) <= l001OOll(I0lOOI1I - 1 downto 1);
  end generate GEN_z1_1;

  GEN_z1_0: if IOI1O1O1 = 0 generate
  begin
    I10OII11 <= l001OOll;
  end generate GEN_z1_0;

  O1010OI0 <= not(I10OII11) + 1 when (O0OOOI1l = '1') else
        I10OII11;

  I100II10 <= O0O011O1 * l1IOl0O0(l0l1O000 - 1 downto l0l1O000 - II110O10); 
  OOI00OO0 <= I100II10(O1O1OIO0 - 1 downto O1O1OIO0 - OIlO01OI);
  O0lIOO00 <= OOI00OO0 + l1OlO0O0 when (O000l11O >= 26) else
         l1OlO0O0;

  DW_lOlOOIl0: if (O0Ol1101 = true) generate
  begin
    l0O01001 <= Il0Olll0;
    I0I10IlO <= '0' & l11011lI;
  end generate DW_lOlOOIl0;

  I1llOOlO <= O0lIOO00 * l1IOl0O0(l0l1O000 - 1 downto l0l1O000 - OO01OOOO);
  ll0100O0 <= I1llOOlO(I000lO0I - 1 downto I000lO0I - O00I0011);
  lO11O100 <= lO0O1I0l - (O1ll1II1 & ll0100O0);

  DW_IO1IO01O: if (O0Ol1101 = true) generate
  begin
    OOOOIO0I <= l0O01001 * l1IOl0O0;
    lI10lIO1 <= OOOOIO0I(O0Ol0ll1 - 1 downto O0Ol0ll1 - O001OO10);
    lOOl0O1l <= lI10lIO1 + I0I10IlO;
    O1OI0lI0 <= lOOl0O1l(O1O11O0l downto 0);
  end generate DW_IO1IO01O;

  DW_OOll1OI1: if (O0Ol1101 = false) generate
  begin
    lO01000I <= lO11O100 * l1IOl0O0;
    O00011O0 <= lO01000I(Il10O1O0 - 1 downto Il10O1O0 - O001OO10);
    O1OI0lI0 <= ('0' & l0l0lIOO & O00011O0) + ('0' & O11I00II);
  end generate DW_OOll1OI1;

  DW_l0II10I1: if (O0Ol1101 = true) generate
  begin
    II1OOOI1 <= '0';
  end generate DW_l0II10I1;

  DW_OOII010I: if (O0Ol1101 = false) generate
  begin
    II1OOOI1 <= O1OI0lI0(2) when ll0Ill00 = 1 else '0';
  end generate DW_OOII010I;

  Ol101IO0 <= (II10O0O0 & O1OI0lI0(O1O11O0l downto 4 - ll0Ill00)) + (O11OIOll & II1OOOI1);
  O10101lO <= Ol101IO0;

  GEN_z0_1: if IOI1O1O1 = 1 generate
  begin
    I10l0OIO(0) <= '0' when (O10101lO(I0lOOI1I - 2) = '1') else
                    O10101lO(0);
    I10l0OIO(I0lOOI1I - 1 downto 1) <= O10101lO(I0lOOI1I - 1 downto 1);
  end generate GEN_z0_1;

  GEN_z0_0: if IOI1O1O1 = 0 generate
  begin
    I10l0OIO <= O10101lO;
  end generate GEN_z0_0;

  l1OIl011 <= not(I10l0OIO) + 1 when (O0OOOI1l = '1') else
        I10l0OIO;

  O10001lO <= O0II010O(29 - 1 downto l0l1O1Ol) when O000l11O <= 9 else
                 (others => '0');
  I1OOOIO0 <= ("00" & O10001lO) when O000l11O <= 9 else
                  (others => '0');

  l111OII0 <= (others => '0');
  O1101O1O <= O0OOOI1l & '1' & l111OII0;
  OllIOOOl <= O1101O1O                when O0Ol0I1O = '1' else
             ((not I1OOOIO0) + '1') when O0OOOI1l = '1'     else
             I1OOOIO0;
  O11O100O <= l1OIl011 when OIO1101l = 0 else O1010OI0;
  Ol0O1O0O <= O01OI010 and O0OOOI1l;
  OO1100OI <= Ol0O1O0O & (O100OO1l(O000l11O - 1) or O01OI010) & OIOII100;
  O1OlO010 <= O11O100O or OO1100OI when (O000l11O >= 10 and O000l11O <= 34) else
          OllIOOOl;
  WAVE <= O1OlO010(I0lOOI1I - 1 downto I0lOOI1I - WAVE_width) when (I0lOOI1I > WAVE_width) else
          O1OlO010;

  OIO01100: process (I0100000) begin

    case I0100000 is
      when "0000000" =>
        ll0IO001 <= "00000000000001001000000000";
        OI0I1O1O <= "1100100011110000000";
      when "0000001" =>
        ll0IO001 <= "00000110010011001000000000";
        OI0I1O1O <= "1100100011110000000";
      when "0000010" =>
        ll0IO001 <= "00001100100101000000000000";
        OI0I1O1O <= "1100100010110000000";
      when "0000011" =>
        ll0IO001 <= "00010010110110011000000000";
        OI0I1O1O <= "1100100001010000000";
      when "0000100" =>
        ll0IO001 <= "00011001000111000000000000";
        OI0I1O1O <= "1100011111010000000";
      when "0000101" =>
        ll0IO001 <= "00011111010110110000000000";
        OI0I1O1O <= "1100011100100000000";
      when "0000110" =>
        ll0IO001 <= "00100101100101001000000000";
        OI0I1O1O <= "1100011010000000000";
      when "0000111" =>
        ll0IO001 <= "00101011110010001000000000";
        OI0I1O1O <= "1100010110110000000";
      when "0001000" =>
        ll0IO001 <= "00110001111101100000000000";
        OI0I1O1O <= "1100010011000000000";
      when "0001001" =>
        ll0IO001 <= "00111000000110111000000000";
        OI0I1O1O <= "1100001110100000000";
      when "0001010" =>
        ll0IO001 <= "00111110001110010000000000";
        OI0I1O1O <= "1100001001100000000";
      when "0001011" =>
        ll0IO001 <= "01000100010010111000000000";
        OI0I1O1O <= "1100000101000000000";
      when "0001100" =>
        ll0IO001 <= "01001010010101011000000000";
        OI0I1O1O <= "1011111110110000000";
      when "0001101" =>
        ll0IO001 <= "01010000010100110000000000";
        OI0I1O1O <= "1011111000000000000";
      when "0001110" =>
        ll0IO001 <= "01010110010001000000000000";
        OI0I1O1O <= "1011110001100000000";
      when "0001111" =>
        ll0IO001 <= "01011100001001110000000000";
        OI0I1O1O <= "1011101011000000000";
      when "0010000" =>
        ll0IO001 <= "01100001111110111000000000";
        OI0I1O1O <= "1011100100000000000";
      when "0010001" =>
        ll0IO001 <= "01100111110000110000000000";
        OI0I1O1O <= "1011011011000000000";
      when "0010010" =>
        ll0IO001 <= "01101101011110010000000000";
        OI0I1O1O <= "1011010011010000000";
      when "0010011" =>
        ll0IO001 <= "01110011000111111000000000";
        OI0I1O1O <= "1011001001100000000";
      when "0010100" =>
        ll0IO001 <= "01111000101100101000000000";
        OI0I1O1O <= "1011000000110000000";
      when "0010101" =>
        ll0IO001 <= "01111110001101000000000000";
        OI0I1O1O <= "1010110111000000000";
      when "0010110" =>
        ll0IO001 <= "10000011101000100000000000";
        OI0I1O1O <= "1010101100010000000";
      when "0010111" =>
        ll0IO001 <= "10001000111110110000000000";
        OI0I1O1O <= "1010100010010000000";
      when "0011000" =>
        ll0IO001 <= "10001110001111111000000000";
        OI0I1O1O <= "1010010111010000000";
      when "0011001" =>
        ll0IO001 <= "10010011011011011000000000";
        OI0I1O1O <= "1010001100000000000";
      when "0011010" =>
        ll0IO001 <= "10011000100001000000000000";
        OI0I1O1O <= "1010000000000000000";
      when "0011011" =>
        ll0IO001 <= "10011101100001100000000000";
        OI0I1O1O <= "1001110011100000000";
      when "0011100" =>
        ll0IO001 <= "10100010011011100000000000";
        OI0I1O1O <= "1001100111000000000";
      when "0011101" =>
        ll0IO001 <= "10100111001111001000000000";
        OI0I1O1O <= "1001011010010000000";
      when "0011110" =>
        ll0IO001 <= "10101011111100011000000000";
        OI0I1O1O <= "1001001101000000000";
      when "0011111" =>
        ll0IO001 <= "10110000100011000000000000";
        OI0I1O1O <= "1000111111010000000";
      when "0100000" =>
        ll0IO001 <= "10110101000010110000000000";
        OI0I1O1O <= "1000110010000000000";
      when "0100001" =>
        ll0IO001 <= "10111001011011100000000000";
        OI0I1O1O <= "1000100011110000000";
      when "0100010" =>
        ll0IO001 <= "10111101101101001000000000";
        OI0I1O1O <= "1000010101110000000";
      when "0100011" =>
        ll0IO001 <= "11000001110111100000000000";
        OI0I1O1O <= "1000000110100000000";
      when "0100100" =>
        ll0IO001 <= "11000101111010111000000000";
        OI0I1O1O <= "0111110101110000000";
      when "0100101" =>
        ll0IO001 <= "11001001110101111000000000";
        OI0I1O1O <= "0111100111000000000";
      when "0100110" =>
        ll0IO001 <= "11001101101001011000000000";
        OI0I1O1O <= "0111010111000000000";
      when "0100111" =>
        ll0IO001 <= "11010001010100101000000000";
        OI0I1O1O <= "0111000111100000000";
      when "0101000" =>
        ll0IO001 <= "11010100111000011000000000";
        OI0I1O1O <= "0110110110100000000";
      when "0101001" =>
        ll0IO001 <= "11011000010011110000000000";
        OI0I1O1O <= "0110100101100000000";
      when "0101010" =>
        ll0IO001 <= "11011011100110110000000000";
        OI0I1O1O <= "0110010100110000000";
      when "0101011" =>
        ll0IO001 <= "11011110110001001000000000";
        OI0I1O1O <= "0110000011110000000";
      when "0101100" =>
        ll0IO001 <= "11100001110011000000000000";
        OI0I1O1O <= "0101110010100000000";
      when "0101101" =>
        ll0IO001 <= "11100100101100001000000000";
        OI0I1O1O <= "0101100001010000000";
      when "0101110" =>
        ll0IO001 <= "11100111011100100000000000";
        OI0I1O1O <= "0101001111100000000";
      when "0101111" =>
        ll0IO001 <= "11101010000011110000000000";
        OI0I1O1O <= "0100111101110000000";
      when "0110000" =>
        ll0IO001 <= "11101100100010011000000000";
        OI0I1O1O <= "0100101010110000000";
      when "0110001" =>
        ll0IO001 <= "11101110110111110000000000";
        OI0I1O1O <= "0100011000100000000";
      when "0110010" =>
        ll0IO001 <= "11110001000011111000000000";
        OI0I1O1O <= "0100000110000000000";
      when "0110011" =>
        ll0IO001 <= "11110011000111000000000000";
        OI0I1O1O <= "0011110010100000000";
      when "0110100" =>
        ll0IO001 <= "11110101000000000000000000";
        OI0I1O1O <= "0011100000110000000";
      when "0110101" =>
        ll0IO001 <= "11110110101111111000000000";
        OI0I1O1O <= "0011001101110000000";
      when "0110110" =>
        ll0IO001 <= "11111000010110101000000000";
        OI0I1O1O <= "0010111010000000000";
      when "0110111" =>
        ll0IO001 <= "11111001110011100000000000";
        OI0I1O1O <= "0010100111010000000";
      when "0111000" =>
        ll0IO001 <= "11111011000110101000000000";
        OI0I1O1O <= "0010010011110000000";
      when "0111001" =>
        ll0IO001 <= "11111100010000000000000000";
        OI0I1O1O <= "0010000000000000000";
      when "0111010" =>
        ll0IO001 <= "11111101010000011000000000";
        OI0I1O1O <= "0001101100000000000";
      when "0111011" =>
        ll0IO001 <= "11111110000110010000000000";
        OI0I1O1O <= "0001011001100000000";
      when "0111100" =>
        ll0IO001 <= "11111110110010111000000000";
        OI0I1O1O <= "0001000100110000000";
      when "0111101" =>
        ll0IO001 <= "11111111010101001000000000";
        OI0I1O1O <= "0000110010000000000";
      when "0111110" =>
        ll0IO001 <= "11111111101101111000000000";
        OI0I1O1O <= "0000011101110000000";
      when "0111111" =>
        ll0IO001 <= "11111111111101000000000000";
        OI0I1O1O <= "0000001010000000000";
      when others =>
        OI0I1O1O <= (others => 'X');
        ll0IO001 <= (others => 'X');
    end case;

    case I0100000 is
      when "0000000" =>
        l111OlOl <= "0000000111110";
        IlI0O01I <= "1100100100010010110";
        OOO011lO <= "00000000000000000000000101";
      when "0000001" =>
        l111OlOl <= "0000010111001";
        IlI0O01I <= "1100100100000011010";
        OOO011lO <= "00000110010010000101010000";
      when "0000010" =>
        l111OlOl <= "0000100110101";
        IlI0O01I <= "1100100011010100110";
        OOO011lO <= "00001100100011111011000110";
      when "0000011" =>
        l111OlOl <= "0000110110001";
        IlI0O01I <= "1100100010000111010";
        OOO011lO <= "00010010110101010001111101";
      when "0000100" =>
        l111OlOl <= "0001000101100";
        IlI0O01I <= "1100100000011010111";
        OOO011lO <= "00011001000101111010010101";
      when "0000101" =>
        l111OlOl <= "0001010101000";
        IlI0O01I <= "1100011110001111101";
        OOO011lO <= "00011111010101100100110100";
      when "0000110" =>
        l111OlOl <= "0001100100010";
        IlI0O01I <= "1100011011100101100";
        OOO011lO <= "00100101100100000001111110";
      when "0000111" =>
        l111OlOl <= "0001110011100";
        IlI0O01I <= "1100011000011100111";
        OOO011lO <= "00101011110001000010011101";
      when "0001000" =>
        l111OlOl <= "0010000010110";
        IlI0O01I <= "1100010100110101101";
        OOO011lO <= "00110001111100010110111100";
      when "0001001" =>
        l111OlOl <= "0010010001111";
        IlI0O01I <= "1100010000110000000";
        OOO011lO <= "00111000000101110000001110";
      when "0001010" =>
        l111OlOl <= "0010100000111";
        IlI0O01I <= "1100001100001100000";
        OOO011lO <= "00111110001100111111000110";
      when "0001011" =>
        l111OlOl <= "0010101111111";
        IlI0O01I <= "1100000111001010001";
        OOO011lO <= "01000100010001110100100001";
      when "0001100" =>
        l111OlOl <= "0010111110110";
        IlI0O01I <= "1100000001101010010";
        OOO011lO <= "01001010010100000001011101";
      when "0001101" =>
        l111OlOl <= "0011001101011";
        IlI0O01I <= "1011111011101100101";
        OOO011lO <= "01010000010011010111000100";
      when "0001110" =>
        l111OlOl <= "0011011100000";
        IlI0O01I <= "1011110101010001101";
        OOO011lO <= "01010110001111100110100010";
      when "0001111" =>
        l111OlOl <= "0011101010100";
        IlI0O01I <= "1011101110011001100";
        OOO011lO <= "01011100001000100001001110";
      when "0010000" =>
        l111OlOl <= "0011111000110";
        IlI0O01I <= "1011100111000100011";
        OOO011lO <= "01100001111101111000100101";
      when "0010001" =>
        l111OlOl <= "0100000111000";
        IlI0O01I <= "1011011111010010101";
        OOO011lO <= "01100111101111011110001111";
      when "0010010" =>
        l111OlOl <= "0100010101000";
        IlI0O01I <= "1011010111000100100";
        OOO011lO <= "01101101011101000011111011";
      when "0010011" =>
        l111OlOl <= "0100100010111";
        IlI0O01I <= "1011001110011010011";
        OOO011lO <= "01110011000110011011100100";
      when "0010100" =>
        l111OlOl <= "0100110000100";
        IlI0O01I <= "1011000101010100101";
        OOO011lO <= "01111000101011010111001110";
      when "0010101" =>
        l111OlOl <= "0100111110000";
        IlI0O01I <= "1010111011110011100";
        OOO011lO <= "01111110001011101001001001";
      when "0010110" =>
        l111OlOl <= "0101001011010";
        IlI0O01I <= "1010110001110111010";
        OOO011lO <= "10000011100111000011101110";
      when "0010111" =>
        l111OlOl <= "0101011000011";
        IlI0O01I <= "1010100111100000100";
        OOO011lO <= "10001000111101011001100110";
      when "0011000" =>
        l111OlOl <= "0101100101010";
        IlI0O01I <= "1010011100101111101";
        OOO011lO <= "10001110001110011101100010";
      when "0011001" =>
        l111OlOl <= "0101110010000";
        IlI0O01I <= "1010010001100100111";
        OOO011lO <= "10010011011010000010100101";
      when "0011010" =>
        l111OlOl <= "0101111110011";
        IlI0O01I <= "1010000110000000111";
        OOO011lO <= "10011000011111111011111011";
      when "0011011" =>
        l111OlOl <= "0110001010101";
        IlI0O01I <= "1001111010000011111";
        OOO011lO <= "10011101011111111101000001";
      when "0011100" =>
        l111OlOl <= "0110010110101";
        IlI0O01I <= "1001101101101110100";
        OOO011lO <= "10100010011001111001100000";
      when "0011101" =>
        l111OlOl <= "0110100010011";
        IlI0O01I <= "1001100001000001001";
        OOO011lO <= "10100111001101100101010011";
      when "0011110" =>
        l111OlOl <= "0110101101111";
        IlI0O01I <= "1001010011111100010";
        OOO011lO <= "10101011111010110100100010";
      when "0011111" =>
        l111OlOl <= "0110111001001";
        IlI0O01I <= "1001000110100000011";
        OOO011lO <= "10110000100001011011100110";
      when "0100000" =>
        l111OlOl <= "0111000100000";
        IlI0O01I <= "1000111000101110001";
        OOO011lO <= "10110101000001001111001001";
      when "0100001" =>
        l111OlOl <= "0111001110110";
        IlI0O01I <= "1000101010100101111";
        OOO011lO <= "10111001011010000100000011";
      when "0100010" =>
        l111OlOl <= "0111011001001";
        IlI0O01I <= "1000011100001000010";
        OOO011lO <= "10111101101011101111100000";
      when "0100011" =>
        l111OlOl <= "0111100011010";
        IlI0O01I <= "1000001101010101111";
        OOO011lO <= "11000001110110000110111110";
      when "0100100" =>
        l111OlOl <= "0111101101001";
        IlI0O01I <= "0111111110001111001";
        OOO011lO <= "11000101111001000000001010";
      when "0100101" =>
        l111OlOl <= "0111110110101";
        IlI0O01I <= "0111101110110100111";
        OOO011lO <= "11001001110100010001000110";
      when "0100110" =>
        l111OlOl <= "0111111111111";
        IlI0O01I <= "0111011111000111011";
        OOO011lO <= "11001101100111110000000101";
      when "0100111" =>
        l111OlOl <= "1000001000110";
        IlI0O01I <= "0111001111000111100";
        OOO011lO <= "11010001010011010011110001";
      when "0101000" =>
        l111OlOl <= "1000010001011";
        IlI0O01I <= "0110111110110101110";
        OOO011lO <= "11010100110110110011000010";
      when "0101001" =>
        l111OlOl <= "1000011001110";
        IlI0O01I <= "0110101110010010110";
        OOO011lO <= "11011000010010000101001000";
      when "0101010" =>
        l111OlOl <= "1000100001101";
        IlI0O01I <= "0110011101011111010";
        OOO011lO <= "11011011100101000001100110";
      when "0101011" =>
        l111OlOl <= "1000101001010";
        IlI0O01I <= "0110001100011011110";
        OOO011lO <= "11011110101111100000010011";
      when "0101100" =>
        l111OlOl <= "1000110000101";
        IlI0O01I <= "0101111011001001000";
        OOO011lO <= "11100001110001011001011011";
      when "0101101" =>
        l111OlOl <= "1000110111101";
        IlI0O01I <= "0101101001100111100";
        OOO011lO <= "11100100101010100101100001";
      when "0101110" =>
        l111OlOl <= "1000111110010";
        IlI0O01I <= "0101010111111000010";
        OOO011lO <= "11100111011010111101011100";
      when "0101111" =>
        l111OlOl <= "1001000100100";
        IlI0O01I <= "0101000101111011101";
        OOO011lO <= "11101010000010011010011000";
      when "0110000" =>
        l111OlOl <= "1001001010011";
        IlI0O01I <= "0100110011110010100";
        OOO011lO <= "11101100100000110101110111";
      when "0110001" =>
        l111OlOl <= "1001010000000";
        IlI0O01I <= "0100100001011101011";
        OOO011lO <= "11101110110110001001110101";
      when "0110010" =>
        l111OlOl <= "1001010101010";
        IlI0O01I <= "0100001110111101010";
        OOO011lO <= "11110001000010010000011110";
      when "0110011" =>
        l111OlOl <= "1001011010001";
        IlI0O01I <= "0011111100010010101";
        OOO011lO <= "11110011000101000100011011";
      when "0110100" =>
        l111OlOl <= "1001011110101";
        IlI0O01I <= "0011101001011110010";
        OOO011lO <= "11110100111110100000101001";
      when "0110101" =>
        l111OlOl <= "1001100010110";
        IlI0O01I <= "0011010110100000111";
        OOO011lO <= "11110110101110100000011011";
      when "0110110" =>
        l111OlOl <= "1001100110100";
        IlI0O01I <= "0011000011011011010";
        OOO011lO <= "11111000010100111111011110";
      when "0110111" =>
        l111OlOl <= "1001101001111";
        IlI0O01I <= "0010110000001110001";
        OOO011lO <= "11111001110001111001110100";
      when "0111000" =>
        l111OlOl <= "1001101100111";
        IlI0O01I <= "0010011100111010001";
        OOO011lO <= "11111011000101001011111001";
      when "0111001" =>
        l111OlOl <= "1001101111101";
        IlI0O01I <= "0010001001100000001";
        OOO011lO <= "11111100001110110010011110";
      when "0111010" =>
        l111OlOl <= "1001110001111";
        IlI0O01I <= "0001110110000000111";
        OOO011lO <= "11111101001110101010101111";
      when "0111011" =>
        l111OlOl <= "1001110011110";
        IlI0O01I <= "0001100010011101000";
        OOO011lO <= "11111110000100110010001101";
      when "0111100" =>
        l111OlOl <= "1001110101010";
        IlI0O01I <= "0001001110110101011";
        OOO011lO <= "11111110110001000110110100";
      when "0111101" =>
        l111OlOl <= "1001110110011";
        IlI0O01I <= "0000111011001010101";
        OOO011lO <= "11111111010011100110110101";
      when "0111110" =>
        l111OlOl <= "1001110111001";
        IlI0O01I <= "0000100111011101101";
        OOO011lO <= "11111111101100010000111100";
      when "0111111" =>
        l111OlOl <= "1001110111100";
        IlI0O01I <= "0000010011101111001";
        OOO011lO <= "11111111111011000100001011";
      when others =>
        l111OlOl <= (others => 'X');
        IlI0O01I <= (others => 'X');
        OOO011lO <= (others => 'X');
    end case;

    case I0100000 is
      when "0000000" =>
        I1OI1110 <= "00000000111110";
        OOOl0110 <= "110010010001000010010";
        O0II010O <= "00000000000000000000000000101";
      when "0000001" =>
        I1OI1110 <= "00000010111010";
        OOOl0110 <= "110010010000110010110";
        O0II010O <= "00000011001001000011101000010";
      when "0000010" =>
        I1OI1110 <= "00000100110110";
        OOOl0110 <= "110010010000000100010";
        O0II010O <= "00000110010010000101010101010";
      when "0000011" =>
        I1OI1110 <= "00000110110001";
        OOOl0110 <= "110010001110110110110";
        O0II010O <= "00001001011011000011001010010";
      when "0000100" =>
        I1OI1110 <= "00001000101101";
        OOOl0110 <= "110010001101001010010";
        O0II010O <= "00001100100011111011001011001";
      when "0000101" =>
        I1OI1110 <= "00001010101001";
        OOOl0110 <= "110010001010111110110";
        O0II010O <= "00001111101100101011011100010";
      when "0000110" =>
        I1OI1110 <= "00001100100101";
        OOOl0110 <= "110010001000010100011";
        O0II010O <= "00010010110101010010000001101";
      when "0000111" =>
        I1OI1110 <= "00001110100000";
        OOOl0110 <= "110010000101001011000";
        O0II010O <= "00010101111101101100111111100";
      when "0001000" =>
        I1OI1110 <= "00010000011100";
        OOOl0110 <= "110010000001100010111";
        O0II010O <= "00011001000101111010011010010";
      when "0001001" =>
        I1OI1110 <= "00010010010111";
        OOOl0110 <= "110001111101011011110";
        O0II010O <= "00011100001101111000010110011";
      when "0001010" =>
        I1OI1110 <= "00010100010010";
        OOOl0110 <= "110001111000110101111";
        O0II010O <= "00011111010101100100111000101";
      when "0001011" =>
        I1OI1110 <= "00010110001101";
        OOOl0110 <= "110001110011110001010";
        O0II010O <= "00100010011100111110000101110";
      when "0001100" =>
        I1OI1110 <= "00011000001000";
        OOOl0110 <= "110001101110001101110";
        O0II010O <= "00100101100100000010000010110";
      when "0001101" =>
        I1OI1110 <= "00011010000010";
        OOOl0110 <= "110001101000001011110";
        O0II010O <= "00101000101010101110110100111";
      when "0001110" =>
        I1OI1110 <= "00011011111100";
        OOOl0110 <= "110001100001101011001";
        O0II010O <= "00101011110001000010100001100";
      when "0001111" =>
        I1OI1110 <= "00011101110110";
        OOOl0110 <= "110001011010101011111";
        O0II010O <= "00101110110110111011001110010";
      when "0010000" =>
        I1OI1110 <= "00011111110000";
        OOOl0110 <= "110001010011001110001";
        O0II010O <= "00110001111100010111000001010";
      when "0010001" =>
        I1OI1110 <= "00100001101001";
        OOOl0110 <= "110001001011010010000";
        O0II010O <= "00110101000001010100000000100";
      when "0010010" =>
        I1OI1110 <= "00100011100010";
        OOOl0110 <= "110001000010110111100";
        O0II010O <= "00111000000101110000010010101";
      when "0010011" =>
        I1OI1110 <= "00100101011011";
        OOOl0110 <= "110000111001111110111";
        O0II010O <= "00111011001001101001111110100";
      when "0010100" =>
        I1OI1110 <= "00100111010011";
        OOOl0110 <= "110000110000101000000";
        O0II010O <= "00111110001100111111001011001";
      when "0010101" =>
        I1OI1110 <= "00101001001011";
        OOOl0110 <= "110000100110110011000";
        O0II010O <= "01000001001111101110000000010";
      when "0010110" =>
        I1OI1110 <= "00101011000011";
        OOOl0110 <= "110000011100100000001";
        O0II010O <= "01000100010001110100100101100";
      when "0010111" =>
        I1OI1110 <= "00101100111010";
        OOOl0110 <= "110000010001101111010";
        O0II010O <= "01000111010011010001000011010";
      when "0011000" =>
        I1OI1110 <= "00101110110001";
        OOOl0110 <= "110000000110100000110";
        O0II010O <= "01001010010100000001100010010";
      when "0011001" =>
        I1OI1110 <= "00110000100111";
        OOOl0110 <= "101111111010110100011";
        O0II010O <= "01001101010100000100001011100";
      when "0011010" =>
        I1OI1110 <= "00110010011101";
        OOOl0110 <= "101111101110101010101";
        O0II010O <= "01010000010011010111001000101";
      when "0011011" =>
        I1OI1110 <= "00110100010010";
        OOOl0110 <= "101111100010000011011";
        O0II010O <= "01010011010001111000100011100";
      when "0011100" =>
        I1OI1110 <= "00110110000111";
        OOOl0110 <= "101111010100111110110";
        O0II010O <= "01010110001111100110100110101";
      when "0011101" =>
        I1OI1110 <= "00110111111011";
        OOOl0110 <= "101111000111011101000";
        O0II010O <= "01011001001100011111011101001";
      when "0011110" =>
        I1OI1110 <= "00111001101111";
        OOOl0110 <= "101110111001011110001";
        O0II010O <= "01011100001000100001010010011";
      when "0011111" =>
        I1OI1110 <= "00111011100010";
        OOOl0110 <= "101110101011000010011";
        O0II010O <= "01011111000011101010010010011";
      when "0100000" =>
        I1OI1110 <= "00111101010100";
        OOOl0110 <= "101110011100001001110";
        O0II010O <= "01100001111101111000101001110";
      when "0100001" =>
        I1OI1110 <= "00111111000110";
        OOOl0110 <= "101110001100110100101";
        O0II010O <= "01100100110111001010100101101";
      when "0100010" =>
        I1OI1110 <= "01000000111000";
        OOOl0110 <= "101101111101000010111";
        O0II010O <= "01100111101111011110010011101";
      when "0100011" =>
        I1OI1110 <= "01000010101000";
        OOOl0110 <= "101101101100110100111";
        O0II010O <= "01101010100110110010000010001";
      when "0100100" =>
        I1OI1110 <= "01000100011001";
        OOOl0110 <= "101101011100001010101";
        O0II010O <= "01101101011101000100000000000";
      when "0100101" =>
        I1OI1110 <= "01000110001000";
        OOOl0110 <= "101101001011000100010";
        O0II010O <= "01110000010010010010011100111";
      when "0100110" =>
        I1OI1110 <= "01000111110111";
        OOOl0110 <= "101100111001100010001";
        O0II010O <= "01110011000110011011101000111";
      when "0100111" =>
        I1OI1110 <= "01001001100101";
        OOOl0110 <= "101100100111100100011";
        O0II010O <= "01110101111001011101110101001";
      when "0101000" =>
        I1OI1110 <= "01001011010010";
        OOOl0110 <= "101100010101001011000";
        O0II010O <= "01111000101011010111010010111";
      when "0101001" =>
        I1OI1110 <= "01001100111111";
        OOOl0110 <= "101100000010010110010";
        O0II010O <= "01111011011100000110010100100";
      when "0101010" =>
        I1OI1110 <= "01001110101011";
        OOOl0110 <= "101011101111000110011";
        O0II010O <= "01111110001011101001001101001";
      when "0101011" =>
        I1OI1110 <= "01010000010110";
        OOOl0110 <= "101011011011011011101";
        O0II010O <= "10000000111001111110010000010";
      when "0101100" =>
        I1OI1110 <= "01010010000000";
        OOOl0110 <= "101011000111010110000";
        O0II010O <= "10000011100111000011110010100";
      when "0101101" =>
        I1OI1110 <= "01010011101010";
        OOOl0110 <= "101010110010110101110";
        O0II010O <= "10000110010010111000001001000";
      when "0101110" =>
        I1OI1110 <= "01010101010011";
        OOOl0110 <= "101010011101111011001";
        O0II010O <= "10001000111101011001101001111";
      when "0101111" =>
        I1OI1110 <= "01010110111011";
        OOOl0110 <= "101010001000100110010";
        O0II010O <= "10001011100110100110101011111";
      when "0110000" =>
        I1OI1110 <= "01011000100010";
        OOOl0110 <= "101001110010110111100";
        O0II010O <= "10001110001110011101100110101";
      when "0110001" =>
        I1OI1110 <= "01011010001000";
        OOOl0110 <= "101001011100101110111";
        O0II010O <= "10010000110100111100110010100";
      when "0110010" =>
        I1OI1110 <= "01011011101101";
        OOOl0110 <= "101001000110001100110";
        O0II010O <= "10010011011010000010101001000";
      when "0110011" =>
        I1OI1110 <= "01011101010010";
        OOOl0110 <= "101000101111010001010";
        O0II010O <= "10010101111101101101100100001";
      when "0110100" =>
        I1OI1110 <= "01011110110110";
        OOOl0110 <= "101000010111111100101";
        O0II010O <= "10011000011111111011111111000";
      when "0110101" =>
        I1OI1110 <= "01100000011000";
        OOOl0110 <= "101000000000001111000";
        O0II010O <= "10011011000000101100010101100";
      when "0110110" =>
        I1OI1110 <= "01100001111010";
        OOOl0110 <= "100111101000001000111";
        O0II010O <= "10011101011111111101000100101";
      when "0110111" =>
        I1OI1110 <= "01100011011011";
        OOOl0110 <= "100111001111101010001";
        O0II010O <= "10011111111101101100101001111";
      when "0111000" =>
        I1OI1110 <= "01100100111011";
        OOOl0110 <= "100110110110110011010";
        O0II010O <= "10100010011001111001100100001";
      when "0111001" =>
        I1OI1110 <= "01100110011010";
        OOOl0110 <= "100110011101100100100";
        O0II010O <= "10100100110100100010010010111";
      when "0111010" =>
        I1OI1110 <= "01100111111000";
        OOOl0110 <= "100110000011111101111";
        O0II010O <= "10100111001101100101010110111";
      when "0111011" =>
        I1OI1110 <= "01101001010101";
        OOOl0110 <= "100101101001111111111";
        O0II010O <= "10101001100101000001010001110";
      when "0111100" =>
        I1OI1110 <= "01101010110000";
        OOOl0110 <= "100101001111101010101";
        O0II010O <= "10101011111010110100100110000";
      when "0111101" =>
        I1OI1110 <= "01101100001011";
        OOOl0110 <= "100100110100111110011";
        O0II010O <= "10101110001110111101110111010";
      when "0111110" =>
        I1OI1110 <= "01101101100101";
        OOOl0110 <= "100100011001111011011";
        O0II010O <= "10110000100001011011101010001";
      when "0111111" =>
        I1OI1110 <= "01101110111110";
        OOOl0110 <= "100011111110100010000";
        O0II010O <= "10110010110010001100100100010";
      when "1000000" =>
        I1OI1110 <= "01110000010110";
        OOOl0110 <= "100011100010110010011";
        O0II010O <= "10110101000001001111001100010";
      when "1000001" =>
        I1OI1110 <= "01110001101100";
        OOOl0110 <= "100011000110101100111";
        O0II010O <= "10110111001110100010001010001";
      when "1000010" =>
        I1OI1110 <= "01110011000010";
        OOOl0110 <= "100010101010010001101";
        O0II010O <= "10111001011010000100000110100";
      when "1000011" =>
        I1OI1110 <= "01110100010110";
        OOOl0110 <= "100010001101100001001";
        O0II010O <= "10111011100011110011101011011";
      when "1000100" =>
        I1OI1110 <= "01110101101001";
        OOOl0110 <= "100001110000011011011";
        O0II010O <= "10111101101011101111100011110";
      when "1000101" =>
        I1OI1110 <= "01110110111100";
        OOOl0110 <= "100001010011000000111";
        O0II010O <= "10111111110001110110011011111";
      when "1000110" =>
        I1OI1110 <= "01111000001101";
        OOOl0110 <= "100000110101010001111";
        O0II010O <= "11000001110110000111000001000";
      when "1000111" =>
        I1OI1110 <= "01111001011100";
        OOOl0110 <= "100000010111001110101";
        O0II010O <= "11000011111000100000000001100";
      when "1001000" =>
        I1OI1110 <= "01111010101011";
        OOOl0110 <= "011111111000110111011";
        O0II010O <= "11000101111001000000001100111";
      when "1001001" =>
        I1OI1110 <= "01111011111001";
        OOOl0110 <= "011111011010001100100";
        O0II010O <= "11000111110111100110010100000";
      when "1001010" =>
        I1OI1110 <= "01111101000101";
        OOOl0110 <= "011110111011001110001";
        O0II010O <= "11001001110100010001001000110";
      when "1001011" =>
        I1OI1110 <= "01111110010000";
        OOOl0110 <= "011110011011111100110";
        O0II010O <= "11001011101110111111011110001";
      when "1001100" =>
        I1OI1110 <= "01111111011010";
        OOOl0110 <= "011101111100011000101";
        O0II010O <= "11001101100111110000001000100";
      when "1001101" =>
        I1OI1110 <= "10000000100011";
        OOOl0110 <= "011101011100100010000";
        O0II010O <= "11001111011110100001111101100";
      when "1001110" =>
        I1OI1110 <= "10000001101010";
        OOOl0110 <= "011100111100011001010";
        O0II010O <= "11010001010011010011110011101";
      when "1001111" =>
        I1OI1110 <= "10000010110000";
        OOOl0110 <= "011100011011111110101";
        O0II010O <= "11010011000110000100100011000";
      when "1010000" =>
        I1OI1110 <= "10000011110101";
        OOOl0110 <= "011011111011010010100";
        O0II010O <= "11010100110110110011000100110";
      when "1010001" =>
        I1OI1110 <= "10000100111001";
        OOOl0110 <= "011011011010010101001";
        O0II010O <= "11010110100101011110010011011";
      when "1010010" =>
        I1OI1110 <= "10000101111011";
        OOOl0110 <= "011010111001000110110";
        O0II010O <= "11011000010010000101001010101";
      when "1010011" =>
        I1OI1110 <= "10000110111100";
        OOOl0110 <= "011010010111100111111";
        O0II010O <= "11011001111100100110100111100";
      when "1010100" =>
        I1OI1110 <= "10000111111100";
        OOOl0110 <= "011001110101111000110";
        O0II010O <= "11011011100101000001101000010";
      when "1010101" =>
        I1OI1110 <= "10001000111010";
        OOOl0110 <= "011001010011111001101";
        O0II010O <= "11011101001011010101001100100";
      when "1010110" =>
        I1OI1110 <= "10001001110111";
        OOOl0110 <= "011000110001101010111";
        O0II010O <= "11011110101111100000010101001";
      when "1010111" =>
        I1OI1110 <= "10001010110011";
        OOOl0110 <= "011000001111001100111";
        O0II010O <= "11100000010001100010000100011";
      when "1011000" =>
        I1OI1110 <= "10001011101110";
        OOOl0110 <= "010111101100100000000";
        O0II010O <= "11100001110001011001011101111";
      when "1011001" =>
        I1OI1110 <= "10001100100111";
        OOOl0110 <= "010111001001100100011";
        O0II010O <= "11100011001111000101100110010";
      when "1011010" =>
        I1OI1110 <= "10001101011111";
        OOOl0110 <= "010110100110011010100";
        O0II010O <= "11100100101010100101100011110";
      when "1011011" =>
        I1OI1110 <= "10001110010101";
        OOOl0110 <= "010110000011000010110";
        O0II010O <= "11100110000011111000011110001";
      when "1011100" =>
        I1OI1110 <= "10001111001010";
        OOOl0110 <= "010101011111011101011";
        O0II010O <= "11100111011010111101011110010";
      when "1011101" =>
        I1OI1110 <= "10001111111110";
        OOOl0110 <= "010100111011101010110";
        O0II010O <= "11101000101111110011101110010";
      when "1011110" =>
        I1OI1110 <= "10010000110000";
        OOOl0110 <= "010100010111101011010";
        O0II010O <= "11101010000010011010011001111";
      when "1011111" =>
        I1OI1110 <= "10010001100001";
        OOOl0110 <= "010011110011011111001";
        O0II010O <= "11101011010010110000101110001";
      when "1100000" =>
        I1OI1110 <= "10010010010000";
        OOOl0110 <= "010011001111000110110";
        O0II010O <= "11101100100000110101111001101";
      when "1100001" =>
        I1OI1110 <= "10010010111110";
        OOOl0110 <= "010010101010100010100";
        O0II010O <= "11101101101100101001001100000";
      when "1100010" =>
        I1OI1110 <= "10010011101011";
        OOOl0110 <= "010010000101110010111";
        O0II010O <= "11101110110110001001110110100";
      when "1100011" =>
        I1OI1110 <= "10010100010110";
        OOOl0110 <= "010001100000111000000";
        O0II010O <= "11101111111101010111001100000";
      when "1100100" =>
        I1OI1110 <= "10010101000000";
        OOOl0110 <= "010000111011110010010";
        O0II010O <= "11110001000010010000100000011";
      when "1100101" =>
        I1OI1110 <= "10010101101000";
        OOOl0110 <= "010000010110100010001";
        O0II010O <= "11110010000100110101001001001";
      when "1100110" =>
        I1OI1110 <= "10010110001111";
        OOOl0110 <= "001111110001001000000";
        O0II010O <= "11110011000101000100011101010";
      when "1100111" =>
        I1OI1110 <= "10010110110101";
        OOOl0110 <= "001111001011100100000";
        O0II010O <= "11110100000010111101110101001";
      when "1101000" =>
        I1OI1110 <= "10010111011001";
        OOOl0110 <= "001110100101110110110";
        O0II010O <= "11110100111110100000101010101";
      when "1101001" =>
        I1OI1110 <= "10010111111011";
        OOOl0110 <= "001110000000000000011";
        O0II010O <= "11110101110111101100011000111";
      when "1101010" =>
        I1OI1110 <= "10011000011100";
        OOOl0110 <= "001101011010000001100";
        O0II010O <= "11110110101110100000011100110";
      when "1101011" =>
        I1OI1110 <= "10011000111100";
        OOOl0110 <= "001100110011111010010";
        O0II010O <= "11110111100010111100010100010";
      when "1101100" =>
        I1OI1110 <= "10011001011010";
        OOOl0110 <= "001100001101101011010";
        O0II010O <= "11111000010100111111011111010";
      when "1101101" =>
        I1OI1110 <= "10011001110111";
        OOOl0110 <= "001011100111010100100";
        O0II010O <= "11111001000100101001011110110";
      when "1101110" =>
        I1OI1110 <= "10011010010010";
        OOOl0110 <= "001011000000110110110";
        O0II010O <= "11111001110001111001110101011";
      when "1101111" =>
        I1OI1110 <= "10011010101011";
        OOOl0110 <= "001010011010010010001";
        O0II010O <= "11111010011100110000000111001";
      when "1110000" =>
        I1OI1110 <= "10011011000100";
        OOOl0110 <= "001001110011100111001";
        O0II010O <= "11111011000101001011111001110";
      when "1110001" =>
        I1OI1110 <= "10011011011010";
        OOOl0110 <= "001001001100110110001";
        O0II010O <= "11111011101011001100110100010";
      when "1110010" =>
        I1OI1110 <= "10011011110000";
        OOOl0110 <= "001000100101111111011";
        O0II010O <= "11111100001110110010011111001";
      when "1110011" =>
        I1OI1110 <= "10011100000011";
        OOOl0110 <= "000111111111000011010";
        O0II010O <= "11111100101111111100100100011";
      when "1110100" =>
        I1OI1110 <= "10011100010101";
        OOOl0110 <= "000111011000000010010";
        O0II010O <= "11111101001110101010101111110";
      when "1110101" =>
        I1OI1110 <= "10011100100110";
        OOOl0110 <= "000110110000111100110";
        O0II010O <= "11111101101010111100101110000";
      when "1110110" =>
        I1OI1110 <= "10011100110101";
        OOOl0110 <= "000110001001110011001";
        O0II010O <= "11111110000100110010001110000";
      when "1110111" =>
        I1OI1110 <= "10011101000011";
        OOOl0110 <= "000101100010100101101";
        O0II010O <= "11111110011100001010111111100";
      when "1111000" =>
        I1OI1110 <= "10011101001111";
        OOOl0110 <= "000100111011010100110";
        O0II010O <= "11111110110001000110110100011";
      when "1111001" =>
        I1OI1110 <= "10011101011010";
        OOOl0110 <= "000100010100000000110";
        O0II010O <= "11111111000011100101011111100";
      when "1111010" =>
        I1OI1110 <= "10011101100011";
        OOOl0110 <= "000011101100101010001";
        O0II010O <= "11111111010011100110110101100";
      when "1111011" =>
        I1OI1110 <= "10011101101011";
        OOOl0110 <= "000011000101010001010";
        O0II010O <= "11111111100001001010101100101";
      when "1111100" =>
        I1OI1110 <= "10011101110001";
        OOOl0110 <= "000010011101110110100";
        O0II010O <= "11111111101100010000111100011";
      when "1111101" =>
        I1OI1110 <= "10011101110101";
        OOOl0110 <= "000001110110011010001";
        O0II010O <= "11111111110100111001011101111";
      when "1111110" =>
        I1OI1110 <= "10011101111000";
        OOOl0110 <= "000001001110111100110";
        O0II010O <= "11111111111011000100001100000";
      when "1111111" =>
        I1OI1110 <= "10011101111010";
        OOOl0110 <= "000000100111011110100";
        O0II010O <= "11111111111110110001000010110";
      when others =>
        I1OI1110 <= (others => 'X');
        OOOl0110 <= (others => 'X');
        O0II010O <= (others => 'X');
    end case;

    case I0100000 is
      when "0000000" =>
        l0011l0O <= "101001010101110";
        l1101IO0 <= "0000000000000000000000";
        O1O1O1l1 <= "11001001000011111101101010100";
        OOOI0lO1 <= "0000000000000000000000000000000000000";
      when "0000001" =>
        l0011l0O <= "101001010101011";
        l1101IO0 <= "0000000111110000000110";
        O1O1O1l1 <= "11001001000010111111101001110";
        OOOI0lO1 <= "0000001100100100001110100011111110011";
      when "0000010" =>
        l0011l0O <= "101001010100100";
        l1101IO0 <= "0000001111100000000111";
        O1O1O1l1 <= "11001001000000000101101000001";
        OOOI0lO1 <= "0000011001001000010101010111110111101";
      when "0000011" =>
        l0011l0O <= "101001010011011";
        l1101IO0 <= "0000010111001111111111";
        O1O1O1l1 <= "11001000111011001111100111011";
        OOOI0lO1 <= "0000100101101100001100101011101011001";
      when "0000100" =>
        l0011l0O <= "101001010001110";
        l1101IO0 <= "0000011110111111101000";
        O1O1O1l1 <= "11001000110100011101101010011";
        OOOI0lO1 <= "0000110010001111101100101111100010000";
      when "0000101" =>
        l0011l0O <= "101001001111110";
        l1101IO0 <= "0000100110101110111111";
        O1O1O1l1 <= "11001000101011101111110101101";
        OOOI0lO1 <= "0000111110110010101101110011110011111";
      when "0000110" =>
        l0011l0O <= "101001001101011";
        l1101IO0 <= "0000101110011101111101";
        O1O1O1l1 <= "11001000100001000110001110001";
        OOOI0lO1 <= "0001001011010101001000001001001011001";
      when "0000111" =>
        l0011l0O <= "101001001010101";
        l1101IO0 <= "0000110110001100011111";
        O1O1O1l1 <= "11001000010100100000111010110";
        OOOI0lO1 <= "0001010111110110110100000000101010011";
      when "0001000" =>
        l0011l0O <= "101001000111011";
        l1101IO0 <= "0000111101111010011111";
        O1O1O1l1 <= "11001000000110000000000011001";
        OOOI0lO1 <= "0001100100010111101001101011110000101";
      when "0001001" =>
        l0011l0O <= "101001000011111";
        l1101IO0 <= "0001000101100111111001";
        O1O1O1l1 <= "11000111110101100011110000001";
        OOOI0lO1 <= "0001110000110111100001011100011110011";
      when "0001010" =>
        l0011l0O <= "101000111111111";
        l1101IO0 <= "0001001101010100101001";
        O1O1O1l1 <= "11000111100011001100001100001";
        OOOI0lO1 <= "0001111101010110010011100101011010101";
      when "0001011" =>
        l0011l0O <= "101000111011100";
        l1101IO0 <= "0001010101000000101000";
        O1O1O1l1 <= "11000111001110111001100010010";
        OOOI0lO1 <= "0010001001110011111000011001110110110";
      when "0001100" =>
        l0011l0O <= "101000110110110";
        l1101IO0 <= "0001011100101011110011";
        O1O1O1l1 <= "11000110111000101011111111000";
        OOOI0lO1 <= "0010010110010000001000001101110100011";
      when "0001101" =>
        l0011l0O <= "101000110001101";
        l1101IO0 <= "0001100100010110000101";
        O1O1O1l1 <= "11000110100000100011110000010";
        OOOI0lO1 <= "0010100010101010111011010110001001010";
      when "0001110" =>
        l0011l0O <= "101000101100000";
        l1101IO0 <= "0001101011111111011001";
        O1O1O1l1 <= "11000110000110100001000100110";
        OOOI0lO1 <= "0010101111000100001010001000100100010";
      when "0001111" =>
        l0011l0O <= "101000100110001";
        l1101IO0 <= "0001110011100111101010";
        O1O1O1l1 <= "11000101101010100100001100101";
        OOOI0lO1 <= "0010111011011011101100111011110010011";
      when "0010000" =>
        l0011l0O <= "101000011111110";
        l1101IO0 <= "0001111011001110110101";
        O1O1O1l1 <= "11000101001100101101011001000";
        OOOI0lO1 <= "0011000111110001011100000111100011010";
      when "0010001" =>
        l0011l0O <= "101000011001000";
        l1101IO0 <= "0010000010110100110011";
        O1O1O1l1 <= "11000100101100111100111100100";
        OOOI0lO1 <= "0011010100000101010000000100101101011";
      when "0010010" =>
        l0011l0O <= "101000010001111";
        l1101IO0 <= "0010001010011001100000";
        O1O1O1l1 <= "11000100001011010011001010100";
        OOOI0lO1 <= "0011100000010111000001001101010011111";
      when "0010011" =>
        l0011l0O <= "101000001010011";
        l1101IO0 <= "0010010001111100111000";
        O1O1O1l1 <= "11000011100111110000011000000";
        OOOI0lO1 <= "0011101100100110100111111100101010001";
      when "0010100" =>
        l0011l0O <= "101000000010100";
        l1101IO0 <= "0010011001011110110110";
        O1O1O1l1 <= "11000011000010010100111010101";
        OOOI0lO1 <= "0011111000110011111100101111011001000";
      when "0010101" =>
        l0011l0O <= "100111111010010";
        l1101IO0 <= "0010100000111111010101";
        O1O1O1l1 <= "11000010011011000001001001110";
        OOOI0lO1 <= "0100000100111110111000000011100011011";
      when "0010110" =>
        l0011l0O <= "100111110001101";
        l1101IO0 <= "0010101000011110010001";
        O1O1O1l1 <= "11000001110001110101011101011";
        OOOI0lO1 <= "0100010001000111010010011000101011000";
      when "0010111" =>
        l0011l0O <= "100111101000100";
        l1101IO0 <= "0010101111111011100101";
        O1O1O1l1 <= "11000001000110110010001111001";
        OOOI0lO1 <= "0100011101001101000100001111110100110";
      when "0011000" =>
        l0011l0O <= "100111011111001";
        l1101IO0 <= "0010110111010111001101";
        O1O1O1l1 <= "11000000011001110111111001011";
        OOOI0lO1 <= "0100101001010000000110001011101101010";
      when "0011001" =>
        l0011l0O <= "100111010101010";
        l1101IO0 <= "0010111110110001000011";
        O1O1O1l1 <= "10111111101011000110110111111";
        OOOI0lO1 <= "0100110101010000010000110000101110000";
      when "0011010" =>
        l0011l0O <= "100111001011001";
        l1101IO0 <= "0011000110001001000100";
        O1O1O1l1 <= "10111110111010011111100111101";
        OOOI0lO1 <= "0101000001001101011100100101000001011";
      when "0011011" =>
        l0011l0O <= "100111000000100";
        l1101IO0 <= "0011001101011111001010";
        O1O1O1l1 <= "10111110001000000010100110011";
        OOOI0lO1 <= "0101001101000111100010010000100111100";
      when "0011100" =>
        l0011l0O <= "100110110101101";
        l1101IO0 <= "0011010100110011010010";
        O1O1O1l1 <= "10111101010011110000010011011";
        OOOI0lO1 <= "0101011000111110011010011101011010101";
      when "0011101" =>
        l0011l0O <= "100110101010010";
        l1101IO0 <= "0011011100000101010111";
        O1O1O1l1 <= "10111100011101101001001111000";
        OOOI0lO1 <= "0101100100110001111101110111010011111";
      when "0011110" =>
        l0011l0O <= "100110011110101";
        l1101IO0 <= "0011100011010101010011";
        O1O1O1l1 <= "10111011100101101101111010011";
        OOOI0lO1 <= "0101110000100010000101001100001111100";
      when "0011111" =>
        l0011l0O <= "100110010010101";
        l1101IO0 <= "0011101010100011000100";
        O1O1O1l1 <= "10111010101011111110111000001";
        OOOI0lO1 <= "0101111100001110101001001100010001110";
      when "0100000" =>
        l0011l0O <= "100110000110001";
        l1101IO0 <= "0011110001101110100100";
        O1O1O1l1 <= "10111001110000011100101011110";
        OOOI0lO1 <= "0110000111110111100010101001101010110";
      when "0100001" =>
        l0011l0O <= "100101111001011";
        l1101IO0 <= "0011111000110111101111";
        O1O1O1l1 <= "10111000110011000111111010010";
        OOOI0lO1 <= "0110010011011100101010011000111011101";
      when "0100010" =>
        l0011l0O <= "100101101100010";
        l1101IO0 <= "0011111111111110100000";
        O1O1O1l1 <= "10110111110100000001001001001";
        OOOI0lO1 <= "0110011110111101111001010000111010100";
      when "0100011" =>
        l0011l0O <= "100101011110101";
        l1101IO0 <= "0100000111000010110011";
        O1O1O1l1 <= "10110110110011001000111111101";
        OOOI0lO1 <= "0110101010011011001000001010110110110";
      when "0100100" =>
        l0011l0O <= "100101010000110";
        l1101IO0 <= "0100001110000100100100";
        O1O1O1l1 <= "10110101110000100000000101100";
        OOOI0lO1 <= "0110110101110100010000000010011110000";
      when "0100101" =>
        l0011l0O <= "100101000010100";
        l1101IO0 <= "0100010101000011101111";
        O1O1O1l1 <= "10110100101100000111000011111";
        OOOI0lO1 <= "0111000001001001001001110110000000000";
      when "0100110" =>
        l0011l0O <= "100100110100000";
        l1101IO0 <= "0100011100000000001110";
        O1O1O1l1 <= "10110011100101111110100101001";
        OOOI0lO1 <= "0111001100011001101110100110010011000";
      when "0100111" =>
        l0011l0O <= "100100100101000";
        l1101IO0 <= "0100100010111001111111";
        O1O1O1l1 <= "10110010011110000111010100011";
        OOOI0lO1 <= "0111010111100101110111010110111000010";
      when "0101000" =>
        l0011l0O <= "100100010101101";
        l1101IO0 <= "0100101001110000111100";
        O1O1O1l1 <= "10110001010100100001111110000";
        OOOI0lO1 <= "0111100010101101011101001110000000010";
      when "0101001" =>
        l0011l0O <= "100100000110000";
        l1101IO0 <= "0100110000100101000001";
        O1O1O1l1 <= "10110000001001001111001111010";
        OOOI0lO1 <= "0111101101110000011001010100101110111";
      when "0101010" =>
        l0011l0O <= "100011110110000";
        l1101IO0 <= "0100110111010110001010";
        O1O1O1l1 <= "10101110111100001111110110111";
        OOOI0lO1 <= "0111111000101110100100110110111111011";
      when "0101011" =>
        l0011l0O <= "100011100101101";
        l1101IO0 <= "0100111110000100010100";
        O1O1O1l1 <= "10101101101101100100100100000";
        OOOI0lO1 <= "1000000011100111111001000011101001011";
      when "0101100" =>
        l0011l0O <= "100011010101000";
        l1101IO0 <= "0101000100101111011001";
        O1O1O1l1 <= "10101100011101001110000111100";
        OOOI0lO1 <= "1000001110011100001111001100100100010";
      when "0101101" =>
        l0011l0O <= "100011000100000";
        l1101IO0 <= "0101001011010111010110";
        O1O1O1l1 <= "10101011001011001101010010101";
        OOOI0lO1 <= "1000011001001011100000100110101011101";
      when "0101110" =>
        l0011l0O <= "100010110010101";
        l1101IO0 <= "0101010001111100000110";
        O1O1O1l1 <= "10101001110111100010111000001";
        OOOI0lO1 <= "1000100011110101100110101010000011010";
      when "0101111" =>
        l0011l0O <= "100010100000111";
        l1101IO0 <= "0101011000011101100110";
        O1O1O1l1 <= "10101000100010001111101011110";
        OOOI0lO1 <= "1000101110011010011010110001111011110";
      when "0110000" =>
        l0011l0O <= "100010001110111";
        l1101IO0 <= "0101011110111011110001";
        O1O1O1l1 <= "10100111001011010100100001110";
        OOOI0lO1 <= "1000111000111001110110011100110101101";
      when "0110001" =>
        l0011l0O <= "100001111100100";
        l1101IO0 <= "0101100101010110100101";
        O1O1O1l1 <= "10100101110010110010010000001";
        OOOI0lO1 <= "1001000011010011110011001100100110011";
      when "0110010" =>
        l0011l0O <= "100001101001110";
        l1101IO0 <= "0101101011101101111011";
        O1O1O1l1 <= "10100100011000101001101101010";
        OOOI0lO1 <= "1001001101101000001010100110011011100";
      when "0110011" =>
        l0011l0O <= "100001010110110";
        l1101IO0 <= "0101110010000001110001";
        O1O1O1l1 <= "10100010111100111011110000110";
        OOOI0lO1 <= "1001010111110110110110010010111111010";
      when "0110100" =>
        l0011l0O <= "100001000011011";
        l1101IO0 <= "0101111000010010000011";
        O1O1O1l1 <= "10100001011111101001010011010";
        OOOI0lO1 <= "1001100001111111101111111110011100000";
      when "0110101" =>
        l0011l0O <= "100000101111110";
        l1101IO0 <= "0101111110011110101101";
        O1O1O1l1 <= "10100000000000110011001110011";
        OOOI0lO1 <= "1001101100000010110001011000100000101";
      when "0110110" =>
        l0011l0O <= "100000011011110";
        l1101IO0 <= "0110000100100111101011";
        O1O1O1l1 <= "10011110100000011010011100100";
        OOOI0lO1 <= "1001110101111111110100010100100011111";
      when "0110111" =>
        l0011l0O <= "100000000111100";
        l1101IO0 <= "0110001010101100111001";
        O1O1O1l1 <= "10011100111110011111111001001";
        OOOI0lO1 <= "1001111111110110110010101001101000100";
      when "0111000" =>
        l0011l0O <= "011111110010111";
        l1101IO0 <= "0110010000101110010100";
        O1O1O1l1 <= "10011011011011000100100000100";
        OOOI0lO1 <= "1010001001100111100110010010100001000";
      when "0111001" =>
        l0011l0O <= "011111011110000";
        l1101IO0 <= "0110010110101011111000";
        O1O1O1l1 <= "10011001110110001001010000010";
        OOOI0lO1 <= "1010010011010010001001001101110011010";
      when "0111010" =>
        l0011l0O <= "011111001000110";
        l1101IO0 <= "0110011100100101100001";
        O1O1O1l1 <= "10011000001111101111000110100";
        OOOI0lO1 <= "1010011100110110010101011101111100011";
      when "0111011" =>
        l0011l0O <= "011110110011010";
        l1101IO0 <= "0110100010011011001011";
        O1O1O1l1 <= "10010110100111110111000010010";
        OOOI0lO1 <= "1010100110010100000101001001010100010";
      when "0111100" =>
        l0011l0O <= "011110011101100";
        l1101IO0 <= "0110101000001100110011";
        O1O1O1l1 <= "10010100111110100010000011111";
        OOOI0lO1 <= "1010101111101011010010011010010001100";
      when "0111101" =>
        l0011l0O <= "011110000111011";
        l1101IO0 <= "0110101101111010010101";
        O1O1O1l1 <= "10010011010011110001001100001";
        OOOI0lO1 <= "1010111000111011110111011111001100100";
      when "0111110" =>
        l0011l0O <= "011101110001000";
        l1101IO0 <= "0110110011100011101111";
        O1O1O1l1 <= "10010001100111100101011101000";
        OOOI0lO1 <= "1011000010000101101110101010100011100";
      when "0111111" =>
        l0011l0O <= "011101011010010";
        l1101IO0 <= "0110111001001000111011";
        O1O1O1l1 <= "10001111111001111111111001000";
        OOOI0lO1 <= "1011001011001000110010010010111101111";
      when "1000000" =>
        l0011l0O <= "011101000011011";
        l1101IO0 <= "0110111110101001111000";
        O1O1O1l1 <= "10001110001011000001100100000";
        OOOI0lO1 <= "1011010100000100111100110011001111110";
      when "1000001" =>
        l0011l0O <= "011100101100001";
        l1101IO0 <= "0111000100000110100001";
        O1O1O1l1 <= "10001100011010101011100010011";
        OOOI0lO1 <= "1011011100111010001000101010011101001";
      when "1000010" =>
        l0011l0O <= "011100010100101";
        l1101IO0 <= "0111001001011110110011";
        O1O1O1l1 <= "10001010101000111110111001010";
        OOOI0lO1 <= "1011100101101000010000011011111101111";
      when "1000011" =>
        l0011l0O <= "011011111100110";
        l1101IO0 <= "0111001110110010101011";
        O1O1O1l1 <= "10001000110101111100101111000";
        OOOI0lO1 <= "1011101110001111001110101111100000010";
      when "1000100" =>
        l0011l0O <= "011011100100110";
        l1101IO0 <= "0111010100000010000101";
        O1O1O1l1 <= "10000111000001100110001010011";
        OOOI0lO1 <= "1011110110101110111110010001001101001";
      when "1000101" =>
        l0011l0O <= "011011001100011";
        l1101IO0 <= "0111011001001100111111";
        O1O1O1l1 <= "10000101001011111100010011011";
        OOOI0lO1 <= "1011111111000111011001110001101010110";
      when "1000110" =>
        l0011l0O <= "011010110011111";
        l1101IO0 <= "0111011110010011010101";
        O1O1O1l1 <= "10000011010101000000010010011";
        OOOI0lO1 <= "1100000111011000011100000101111111110";
      when "1000111" =>
        l0011l0O <= "011010011011000";
        l1101IO0 <= "0111100011010101000011";
        O1O1O1l1 <= "10000001011100110011010000110";
        OOOI0lO1 <= "1100001111100010000000000111110111001";
      when "1001000" =>
        l0011l0O <= "011010000001111";
        l1101IO0 <= "0111101000010010001000";
        O1O1O1l1 <= "01111111100011010110011000111";
        OOOI0lO1 <= "1100010111100100000000110101100010100";
      when "1001001" =>
        l0011l0O <= "011001101000100";
        l1101IO0 <= "0111101101001010100000";
        O1O1O1l1 <= "01111101101000101010110101011";
        OOOI0lO1 <= "1100011111011110011001010001111101110";
      when "1001010" =>
        l0011l0O <= "011001001110111";
        l1101IO0 <= "0111110001111110000111";
        O1O1O1l1 <= "01111011101100110001110010000";
        OOOI0lO1 <= "1100100111010001000100100100110010001";
      when "1001011" =>
        l0011l0O <= "011000110101001";
        l1101IO0 <= "0111110110101100111011";
        O1O1O1l1 <= "01111001101111101100011011010";
        OOOI0lO1 <= "1100101110111011111101111010011000111";
      when "1001100" =>
        l0011l0O <= "011000011011000";
        l1101IO0 <= "0111111011010110111001";
        O1O1O1l1 <= "01110111110001011011111110011";
        OOOI0lO1 <= "1100110110011111000000100011111110010";
      when "1001101" =>
        l0011l0O <= "011000000000110";
        l1101IO0 <= "0111111111111011111110";
        O1O1O1l1 <= "01110101110010000001101001000";
        OOOI0lO1 <= "1100111101111010000111110111100101000";
      when "1001110" =>
        l0011l0O <= "010111100110001";
        l1101IO0 <= "1000000100011100000111";
        O1O1O1l1 <= "01110011110001011110101001111";
        OOOI0lO1 <= "1101000101001101001111010000001000101";
      when "1001111" =>
        l0011l0O <= "010111001011011";
        l1101IO0 <= "1000001000110111010010";
        O1O1O1l1 <= "01110001101111110100010000011";
        OOOI0lO1 <= "1101001100011000010010001101100000010";
      when "1010000" =>
        l0011l0O <= "010110110000011";
        l1101IO0 <= "1000001101001101011011";
        O1O1O1l1 <= "01101111101101000011101100010";
        OOOI0lO1 <= "1101010011011011001100010100100001101";
      when "1010001" =>
        l0011l0O <= "010110010101001";
        l1101IO0 <= "1000010001011110100001";
        O1O1O1l1 <= "01101101101001001110001110011";
        OOOI0lO1 <= "1101011010010101111001001111000100000";
      when "1010010" =>
        l0011l0O <= "010101111001110";
        l1101IO0 <= "1000010101101010100000";
        O1O1O1l1 <= "01101011100100010101000111111";
        OOOI0lO1 <= "1101100001001000010100101100000010100";
      when "1010011" =>
        l0011l0O <= "010101011110001";
        l1101IO0 <= "1000011001110001010101";
        O1O1O1l1 <= "01101001011110011001101010111";
        OOOI0lO1 <= "1101100111110010011010011111011110100";
      when "1010100" =>
        l0011l0O <= "010101000010010";
        l1101IO0 <= "1000011101110010111111";
        O1O1O1l1 <= "01100111010111011101001001111";
        OOOI0lO1 <= "1101101110010100000110100010100011000";
      when "1010101" =>
        l0011l0O <= "010100100110001";
        l1101IO0 <= "1000100001101111011011";
        O1O1O1l1 <= "01100101001111100000111000010";
        OOOI0lO1 <= "1101110100101101010100110011100110100";
      when "1010110" =>
        l0011l0O <= "010100001001111";
        l1101IO0 <= "1000100101100110100110";
        O1O1O1l1 <= "01100011000110100110001001111";
        OOOI0lO1 <= "1101111010111110000001010110001101110";
      when "1010111" =>
        l0011l0O <= "010011101101100";
        l1101IO0 <= "1000101001011000011110";
        O1O1O1l1 <= "01100000111100101110010011000";
        OOOI0lO1 <= "1110000001000110001000010011001110001";
      when "1011000" =>
        l0011l0O <= "010011010000111";
        l1101IO0 <= "1000101101000101000001";
        O1O1O1l1 <= "01011110110001111010101000110";
        OOOI0lO1 <= "1110000111000101100101111000101111111";
      when "1011001" =>
        l0011l0O <= "010010110100000";
        l1101IO0 <= "1000110000101100001100";
        O1O1O1l1 <= "01011100100110001100100000111";
        OOOI0lO1 <= "1110001100111100010110011010010000111";
      when "1011010" =>
        l0011l0O <= "010010010111000";
        l1101IO0 <= "1000110100001101111101";
        O1O1O1l1 <= "01011010011001100101010001100";
        OOOI0lO1 <= "1110010010101010010110010000100110011";
      when "1011011" =>
        l0011l0O <= "010001111001111";
        l1101IO0 <= "1000110111101010010010";
        O1O1O1l1 <= "01011000001100000110010001010";
        OOOI0lO1 <= "1110011000001111100001111001111111100";
      when "1011100" =>
        l0011l0O <= "010001011100100";
        l1101IO0 <= "1000111011000001001001";
        O1O1O1l1 <= "01010101111101110000110111100";
        OOOI0lO1 <= "1110011101101011110101111010000111011";
      when "1011101" =>
        l0011l0O <= "010000111111000";
        l1101IO0 <= "1000111110010010100000";
        O1O1O1l1 <= "01010011101110100110011100000";
        OOOI0lO1 <= "1110100010111111001110111010000111101";
      when "1011110" =>
        l0011l0O <= "010000100001010";
        l1101IO0 <= "1001000001011110010101";
        O1O1O1l1 <= "01010001011110101000010111001";
        OOOI0lO1 <= "1110101000001001101001101000101001100";
      when "1011111" =>
        l0011l0O <= "010000000011100";
        l1101IO0 <= "1001000100100100100101";
        O1O1O1l1 <= "01001111001101111000000001101";
        OOOI0lO1 <= "1110101101001011000010111001111001000";
      when "1100000" =>
        l0011l0O <= "001111100101100";
        l1101IO0 <= "1001000111100101001111";
        O1O1O1l1 <= "01001100111100010110110100111";
        OOOI0lO1 <= "1110110010000011010111100111100110001";
      when "1100001" =>
        l0011l0O <= "001111000111010";
        l1101IO0 <= "1001001010100000010010";
        O1O1O1l1 <= "01001010101010000110001010100";
        OOOI0lO1 <= "1110110110110010100100110001000110111";
      when "1100010" =>
        l0011l0O <= "001110101001000";
        l1101IO0 <= "1001001101010101101010";
        O1O1O1l1 <= "01001000010111000111011100111";
        OOOI0lO1 <= "1110111011011000100111011011011001011";
      when "1100011" =>
        l0011l0O <= "001110001010101";
        l1101IO0 <= "1001010000000101010111";
        O1O1O1l1 <= "01000110000011011100000110100";
        OOOI0lO1 <= "1110111111110101011100110001000101100";
      when "1100100" =>
        l0011l0O <= "001101101100000";
        l1101IO0 <= "1001010010101111010111";
        O1O1O1l1 <= "01000011101111000101100010100";
        OOOI0lO1 <= "1111000100001001000010000010011110101";
      when "1100101" =>
        l0011l0O <= "001101001101010";
        l1101IO0 <= "1001010101010011101000";
        O1O1O1l1 <= "01000001011010000101001100100";
        OOOI0lO1 <= "1111001000010011010100100101100101010";
      when "1100110" =>
        l0011l0O <= "001100101110100";
        l1101IO0 <= "1001010111110010001000";
        O1O1O1l1 <= "00111111000100011100100000011";
        OOOI0lO1 <= "1111001100010100010001110110001000111";
      when "1100111" =>
        l0011l0O <= "001100001111100";
        l1101IO0 <= "1001011010001010110111";
        O1O1O1l1 <= "00111100101110001100111010011";
        OOOI0lO1 <= "1111010000001011110111010101101001011";
      when "1101000" =>
        l0011l0O <= "001011110000100";
        l1101IO0 <= "1001011100011101110010";
        O1O1O1l1 <= "00111010010111010111110111010";
        OOOI0lO1 <= "1111010011111010000010101011011000101";
      when "1101001" =>
        l0011l0O <= "001011010001010";
        l1101IO0 <= "1001011110101010111000";
        O1O1O1l1 <= "00110111111111111110110011111";
        OOOI0lO1 <= "1111010111011110110001100100011011110";
      when "1101010" =>
        l0011l0O <= "001010110010000";
        l1101IO0 <= "1001100000110010001000";
        O1O1O1l1 <= "00110101101000000011001101111";
        OOOI0lO1 <= "1111011010111010000001110011101100111";
      when "1101011" =>
        l0011l0O <= "001010010010101";
        l1101IO0 <= "1001100010110011100000";
        O1O1O1l1 <= "00110011001111100110100010110";
        OOOI0lO1 <= "1111011110001011110001010001111100011";
      when "1101100" =>
        l0011l0O <= "001001110011001";
        l1101IO0 <= "1001100100101111000000";
        O1O1O1l1 <= "00110000110110101010010000101";
        OOOI0lO1 <= "1111100001010011111101111101110010001";
      when "1101101" =>
        l0011l0O <= "001001010011100";
        l1101IO0 <= "1001100110100100100101";
        O1O1O1l1 <= "00101110011101001111110101111";
        OOOI0lO1 <= "1111100100010010100101111011101110101";
      when "1101110" =>
        l0011l0O <= "001000110011110";
        l1101IO0 <= "1001101000010100010000";
        O1O1O1l1 <= "00101100000011011000110001001";
        OOOI0lO1 <= "1111100111000111100111010110001100011";
      when "1101111" =>
        l0011l0O <= "001000010100000";
        l1101IO0 <= "1001101001111101111110";
        O1O1O1l1 <= "00101001101001000110100001010";
        OOOI0lO1 <= "1111101001110011000000011101100001010";
      when "1110000" =>
        l0011l0O <= "000111110100001";
        l1101IO0 <= "1001101011100001101111";
        O1O1O1l1 <= "00100111001110011010100101011";
        OOOI0lO1 <= "1111101100010100101111100111111110110";
      when "1110001" =>
        l0011l0O <= "000111010100010";
        l1101IO0 <= "1001101100111111100011";
        O1O1O1l1 <= "00100100110011010110011101000";
        OOOI0lO1 <= "1111101110101100110011010001110100000";
      when "1110010" =>
        l0011l0O <= "000110110100010";
        l1101IO0 <= "1001101110010111010111";
        O1O1O1l1 <= "00100010010111111011100111110";
        OOOI0lO1 <= "1111110000111011001001111101001110000";
      when "1110011" =>
        l0011l0O <= "000110010100010";
        l1101IO0 <= "1001101111101001001011";
        O1O1O1l1 <= "00011111111100001011100101100";
        OOOI0lO1 <= "1111110010111111110010010010011001000";
      when "1110100" =>
        l0011l0O <= "000101110100001";
        l1101IO0 <= "1001110000110100111110";
        O1O1O1l1 <= "00011101100000000111110110010";
        OOOI0lO1 <= "1111110100111010101010111111100000111";
      when "1110101" =>
        l0011l0O <= "000101010011111";
        l1101IO0 <= "1001110001111010110000";
        O1O1O1l1 <= "00011011000011110001111010011";
        OOOI0lO1 <= "1111110110101011110010111000110010100";
      when "1110110" =>
        l0011l0O <= "000100110011110";
        l1101IO0 <= "1001110010111010100000";
        O1O1O1l1 <= "00011000100111001011010010010";
        OOOI0lO1 <= "1111111000010011001000111000011100000";
      when "1110111" =>
        l0011l0O <= "000100010011011";
        l1101IO0 <= "1001110011110100001101";
        O1O1O1l1 <= "00010110001010010101011110100";
        OOOI0lO1 <= "1111111001110000101011111110101101100";
      when "1111000" =>
        l0011l0O <= "000011110011001";
        l1101IO0 <= "1001110100100111110111";
        O1O1O1l1 <= "00010011101101010001111111111";
        OOOI0lO1 <= "1111111011000100011011010001111010000";
      when "1111001" =>
        l0011l0O <= "000011010010110";
        l1101IO0 <= "1001110101010101011101";
        O1O1O1l1 <= "00010001010000000010010111010";
        OOOI0lO1 <= "1111111100001110010101111110010111100";
      when "1111010" =>
        l0011l0O <= "000010110010011";
        l1101IO0 <= "1001110101111100111111";
        O1O1O1l1 <= "00001110110010101000000101100";
        OOOI0lO1 <= "1111111101001110011011010110100000000";
      when "1111011" =>
        l0011l0O <= "000010010010000";
        l1101IO0 <= "1001110110011110011101";
        O1O1O1l1 <= "00001100010101000100101100000";
        OOOI0lO1 <= "1111111110000100101010110010110001101";
      when "1111100" =>
        l0011l0O <= "000001110001100";
        l1101IO0 <= "1001110110111001110101";
        O1O1O1l1 <= "00001001110111011001101011101";
        OOOI0lO1 <= "1111111110110001000011110001101111000";
      when "1111101" =>
        l0011l0O <= "000001010001001";
        l1101IO0 <= "1001110111001111001000";
        O1O1O1l1 <= "00000111011001101000100101111";
        OOOI0lO1 <= "1111111111010011100101110111111111101";
      when "1111110" =>
        l0011l0O <= "000000110000101";
        l1101IO0 <= "1001110111011110010110";
        O1O1O1l1 <= "00000100111011110010111011111";
        OOOI0lO1 <= "1111111111101100010000110000010000011";
      when "1111111" =>
        l0011l0O <= "000000010000001";
        l1101IO0 <= "1001110111100111011111";
        O1O1O1l1 <= "00000010011101111010001111001";
        OOOI0lO1 <= "1111111111111011000100001011010011010";
      when others =>
        l0011l0O <= (others => 'X');
        l1101IO0 <= (others => 'X');
        O1O1O1l1 <= (others => 'X');
        OOOI0lO1 <= (others => 'X');
    end case;

  end process OIO01100;

-- pragma translate_on

end sim;

--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_sincos_cfg_sim of DW_sincos is
 for sim
 end for; -- sim
end DW_sincos_cfg_sim;
-- pragma translate_on

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
-- AUTHOR:    Kyung-Nam Han  Jul. 16, 2007
--
-- VERSION:   VHDL Simulation model for DW_fp_recip
--
-- DesignWare_version: cbb9ba54
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--
-- ABSTRACT: Floating-Point Reciprocal
--
--              DW_fp_recip calculates the floating-point reciprocal
--              with 1 ulp error.
--
--              parameters      valid values (defined in the DW manual)
--              ==========      ============
--              sig_width       significand size,  2 to 253 bits
--              exp_width       exponent size,     3 to 31 bits
--              ieee_compliance support the IEEE Compliance 
--                              0 - IEEE 754 compatible without denormal support
--                                  (NaN becomes Infinity, Denormal becomes Zero)
--                              1 - IEEE 754 compatible with denormal support
--                                  (NaN and denormal numbers are supported)
--              faithful_round  parameter for the faithful_rounding that
--                              has 1 ulp error
--                              0 - default value. it keeps all rounding modes
--                              1 - z has 1 ulp error. RND input does not affect 
--                                  the output
--
--              Input ports     Size & Description
--              ===========     ==================
--              a               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Input
--              rnd             3 bits
--                              Rounding Mode Input
--
--              Output ports    Size & Description
--              ===========     ==================
--              z               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Output
--              status          8 bits
--                              Status Flags Output
--
-- Modified:
--   Jan. 6. 2008 Kyung-Nam Han from 0712-SP1
--     Fixed the array index mismatch error when sig_width = 52
--   May 14, 2009 Kyung-Nam Han
--     Fixed Mentor's Modelsim fatal error with sig_width = 23
--   Jun. 3. 2010 Kyung-Nam Han (from D-2010.03-SP3)
--     1) With sig_width=8, it had larger than 1 ulp error. Fixed.
--     2) With faithful_round=1, 1/denormal was not 'Inf'
--        when the true result is at the infinite region. Fixed
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_misc.all;
use ieee.numeric_std.all;
library DWARE;
use DWARE.DW_Foundation_comp.all;


architecture sim of DW_fp_recip is
	

  -- pragma translate_off



  constant DW_Ill0lOl1          : integer  := 4;
  constant DW_O110O00O            : integer  := 0;
  constant DW_IOI010lO        : integer  := 1;
  constant DW_OOO101O1   : integer  := 2;
  constant DW_IIlI101I    : integer  := 3;

  constant DW_l01OI1IO             : integer := (2 * sig_width + 2);
  constant DW_O0OI011O               : integer := (sig_width + 2);
  constant ext                : integer := (sig_width + 2);

  function lIOO101l(a: in integer) return integer is
    begin
      if (a < 25) then
        return 0;
      else
        return (a - 25);
      end if;
    end function;

  function IOOI0II1(a: in integer) return integer is
    begin
      if (a >= 8) then
        return 0;
      else
        return (8 - a);
      end if;
    end function;

  function IOO1010l (a: in integer) return integer is
    begin
      if (a >= 9) then
        return (a - 9);
      else
        return 0;
      end if;
    end function;

  function I1lO1I1I (a: in integer) return integer is
    begin
      if (a >= 11) then
        return (a - 10);
      else
        return 0;
      end if;
    end function;

  constant O00l1O10          : integer := I1lO1I1I(sig_width);
  constant l101001I        : integer := IOO1010l(sig_width);
  constant OIl0I0IO  : integer := IOOI0II1(sig_width);
  constant DW_OOO111l0      : integer := lIOO101l(sig_width);
  constant OO10OI11      : integer := (sig_width - 24);
  constant DW_OO00OII1 : integer := (2 * sig_width - 47);
  constant DW_OI11IOIO : integer := (2 * sig_width - 21);
  constant DW_OO1I11OI      : integer := (sig_width - 11);
  constant DW_OOOI0O01         : integer := (7 - sig_width);

  ----------------------------------------------------------------------
  function Il1lIO0I (a : in std_logic_vector; b : in std_logic_vector) return std_logic_vector is

    variable result : std_logic_vector(a'range);
    variable ref : std_logic_vector(b'length downto 0) := (others => '0');
    variable count : integer := a'length - 1;

    begin

      if (b = 0) then
        result := (others => '1');

      elsif (a < b) then
        result := (others => '0');

      else 
        while (count >= 0) loop
          ref := ref(ref'length - 2 downto 0) & a(count);

          if (ref >= b) then
            ref := ref - b;
            result(count) := '1';
          else
            result(count) := '0';
          end if;

          count := count - 1;

        end loop;
      end if;

    return result;

  end function;
  ----------------------------------------------------------------------
  function llO001O1 (a : in std_logic_vector; b : in std_logic_vector) return std_logic_vector is

    variable result : std_logic_vector(a'range);
    variable ref : std_logic_vector(b'length downto 0) := (others => '0');
    variable count : integer := a'length - 1;
    variable return_vec : std_logic_vector(a'length - 1 downto 0);
    variable zero_vec : std_logic_vector(a'length - b'length - 1 downto 0) := (others => '0');

    begin

      if (b = 0) then
        ref := (others => '1');

      elsif (a < b) then
        ref := (others => '0');

      else 
        while (count >= 0) loop
          ref := ref(ref'length - 2 downto 0) & a(count);

          if (ref >= b) then
            ref := ref - b;
            result(count) := '1';
          else
            result(count) := '0';
          end if;

          count := count - 1;

        end loop;
      end if;

      return_vec := zero_vec & ref(b'length - 1 downto 0);

    return return_vec;

  end function;
  ----------------------------------------------------------------------
  function IIOO1I10 (a : in std_logic_vector; sh : in integer) return std_logic_vector is

    variable b : std_logic_vector(a'range) := a;
    variable count : integer := sh;

    begin

      while (count > 0) loop
        b := '0' & b(b'length-1 downto 1);
        count := count - 1;
      end loop;

    return b;

  end function;

  ----------------------------------------------------------------------
  function O000OOO0 (a : in std_logic_vector; sh : in integer) return std_logic_vector is

    variable b : std_logic_vector(a'range) := a;
    variable count : integer := sh;

    begin

      while (count > 0) loop
        b := b(b'length-2 downto 0) & '0';
        count := count - 1;
      end loop;

    return b;

  end function;

  ----------------------------------------------------------------------
  function OO11l0O1 (
    rnd    : in std_logic_vector(2 downto 0);
    Sign   : in std_logic;
    L      : in std_logic;
    R      : in std_logic;
    OIllO0O1    : in std_logic )
    return std_logic_vector is

    variable OO11l0O1 : std_logic_vector(DW_Ill0lOl1 - 1 downto 0);
  
    begin
  
    OO11l0O1(DW_O110O00O) := '0';
    OO11l0O1(DW_IOI010lO) := R OR OIllO0O1;
    OO11l0O1(DW_OOO101O1) := '0';
    OO11l0O1(DW_IIlI101I) := '0';
  
    case rnd is
  
    when "000" =>
      OO11l0O1(DW_O110O00O) := R AND (L OR OIllO0O1);
      OO11l0O1(DW_OOO101O1) := '1';
      OO11l0O1(DW_IIlI101I) := '0';
  
    when "001" =>
      OO11l0O1(DW_O110O00O) := '0';
      OO11l0O1(DW_OOO101O1) := '0';
      OO11l0O1(DW_IIlI101I) := '0';
  
    when "010" =>
      OO11l0O1(DW_O110O00O) := not (Sign) AND (R OR OIllO0O1);
      OO11l0O1(DW_OOO101O1) := not (Sign);
      OO11l0O1(DW_IIlI101I) := not (Sign);
  
    when "011" =>
      OO11l0O1(DW_O110O00O) := Sign AND (R OR OIllO0O1);
      OO11l0O1(DW_OOO101O1) := Sign;
      OO11l0O1(DW_IIlI101I) := Sign;
  
    when "100" =>
      OO11l0O1(DW_O110O00O) := R;
      OO11l0O1(DW_OOO101O1) := '1';
      OO11l0O1(DW_IIlI101I) := '0';
  
    when "101" =>
      OO11l0O1(DW_O110O00O) := R OR OIllO0O1;
      OO11l0O1(DW_OOO101O1) := '1';
      OO11l0O1(DW_IIlI101I) := '1';
  
    when others =>
      OO11l0O1(DW_O110O00O) := 'X';
      OO11l0O1(DW_OOO101O1) := 'X';
      OO11l0O1(DW_IIlI101I) := 'X';
  
    end case;
  
    return(OO11l0O1);

  end function;

  -- pragma translate_on
  ----------------------------------------------------------------------

  signal lI0OO0O1    : std_logic_vector(exp_width - 2 downto 0);
  signal lI1O1111   : std_logic_vector(sig_width - 1 downto 0);
  signal l0I1l1O1      : std_logic_vector(sig_width + exp_width downto 0);
  signal O00OI111     : std_logic_vector(sig_width + exp_width downto 0);
  signal O1010O0O: std_logic_vector(7 downto 0);

begin

  -- pragma translate_off

  
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
     
    if ( (sig_width < 2) OR (sig_width > 60) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter sig_width (legal range: 2 to 60)"
        severity warning;
    end if;
     
    if ( (exp_width < 3) OR (exp_width > 31) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter exp_width (legal range: 3 to 31)"
        severity warning;
    end if;
     
    if ( (ieee_compliance < 0) OR (ieee_compliance > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter ieee_compliance (legal range: 0 to 1)"
        severity warning;
    end if;
     
    if ( (faithful_round < 0) OR (faithful_round > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter faithful_round (legal range: 0 to 1)"
        severity warning;
    end if;
  
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;

  lI0OO0O1 <= (others => '1');
  lI1O1111 <= (others => '0');
  l0I1l1O1 <= "00" & lI0OO0O1 & lI1O1111;

  -- Instance of DW_fp_sqrt
  U1 : DW_fp_div
      generic map (
              sig_width => sig_width,
              exp_width => exp_width,
              ieee_compliance => ieee_compliance
              )
      port map (
              a => l0I1l1O1,
              b => a,
              rnd => rnd,
              z => O00OI111,
              status => O1010O0O
              );

  l001OOOI: process (a, O00OI111, O1010O0O)

  variable lOO011OI : std_logic_vector((exp_width + sig_width) downto 0);
  variable OlO000O1 : std_logic_vector(exp_width - 1 downto 0);
  variable IOOI01IO : std_logic_vector(exp_width - 1 downto 0);
  variable lOOllO11 : std_logic_vector(sig_width - 1 downto 0);
  variable OI0Ill10 : std_logic_vector(sig_width - 1 downto 0);
  variable I0l110I0 : std_logic_vector(exp_width + 1 downto 0);
  variable OOl100OI : std_logic_vector(exp_width + 1 downto 0);
  variable lOO00lI0 : std_logic_vector(exp_width + 1 downto 0);
  variable OO111l0O : std_logic_vector(exp_width + 1 downto 0);
  variable l0l0IOlO : std_logic_vector(exp_width + 1 downto 0);
  variable O0I11O0l : std_logic_vector(exp_width + 1 downto 0);
  variable O01I1IO1 : std_logic_vector(exp_width + 1 downto 0);
  variable O00IO10O : std_logic_vector(sig_width downto 0);
  variable l011011l : std_logic_vector(sig_width downto 0);
  variable lO10010I : std_logic_vector(sig_width downto 0);
  variable l01101I0 : std_logic_vector(sig_width downto 0);
  variable OO01l0I0 : std_logic_vector(sig_width downto 0);
  variable O1IlO100 : std_logic_vector(sig_width downto 0);
  variable I11l0100 : std_logic_vector(sig_width downto 0);
  variable lI0l111l : std_logic_vector(sig_width downto 0);
  variable Ill1lII0 : std_logic_vector(sig_width downto 0);
  variable OI0llO10 : std_logic_vector(1 downto 0);
  variable l0100O0l : std_logic_vector(DW_Ill0lOl1 - 1 downto 0);
  variable l1O10II1 : std_logic_vector(8     - 1 downto 0);
  variable O00IIl0l : std_logic_vector(exp_width - 1 downto 0);
  variable OlIO0O11 : std_logic_vector(sig_width - 1 downto 0);
  variable IO001O1l : std_logic_vector(sig_width - 1 downto 0);
  variable IO10l110 : std_logic_vector(sig_width - 2 downto 0);
  variable OOO0l10l : std_logic_vector((exp_width + sig_width) downto 0);
  variable OIOlO100 : std_logic_vector((exp_width + sig_width) downto 0);
  variable lOIIOI0O : std_logic_vector(ext - 1 downto 0);
  variable OO01OI01 : std_logic_vector(sig_width + ext downto 0);
  variable OI1I0001 : std_logic_vector(sig_width + ext downto 0);
  variable I1I0l10O : std_logic_vector(exp_width - 1 downto 0);
  variable O1I11010 : std_logic_vector(exp_width - 1 downto 0);
  variable lOO00O01 : std_logic_vector(exp_width + 1 downto 0);
  variable IOl1OO01 : std_logic_vector(sig_width downto 0);
  variable OO00I1O1 : std_logic_vector(2 * sig_width + 1 downto 0);
  variable OIIIOl01 : std_logic_vector(sig_width downto 0);
  variable O1OI1lI0 : std_logic_vector(2 downto 0);
  variable OIllO0O1 : std_logic;
  variable O100OOI0 : std_logic;
  variable IO0OlO1O : BOOLEAN;
  variable O0l10lOO : BOOLEAN;
  variable IOOO0OOO : BOOLEAN;
  variable OO0I1OIl : BOOLEAN;
  variable I00101O1 : BOOLEAN;
  variable I00I01O1 : BOOLEAN;
  variable lOIIOI1l : BOOLEAN;
  variable l00lOI1I : BOOLEAN;
  variable O00001Ol : BOOLEAN;
  variable OOOO1O00 : INTEGER;
  variable l1101OO1 : INTEGER;
  variable OIl0O110 : INTEGER;
  variable l1IOlO01 : INTEGER;
  variable l0OOO11l : INTEGER;
  variable lI1l011I : std_logic_vector(exp_width + sig_width downto 0);
  variable IlO001II : std_logic_vector(sig_width - 1 downto 0);
  variable I0O0O0IO : std_logic_vector(exp_width - 1 downto 0);
  variable O0l1000O : std_logic_vector(exp_width - 2 downto 0);
  variable l0OO0101 : std_logic_vector(8 downto 0);
  variable O000O0Il : std_logic_vector(8 downto 0);
  variable IOOO0Ol0 : std_logic_vector(sig_width + 3 downto 0);
  variable Ol1O10O0 : std_logic_vector(sig_width + 3 downto 0);
  variable l101lO0O : std_logic_vector(sig_width + 3 downto 0);
  variable l0O1Ol0O : std_logic_vector(sig_width + 9 downto 0);
  variable lO1l1OO0 : std_logic_vector(sig_width + 1 downto 0);
  variable OI0OIlO1 : std_logic_vector(sig_width + 18 downto 0);
  variable IlOI0OOI : std_logic_vector(DW_OI11IOIO downto 0);
  variable II1ll01l : std_logic_vector(DW_OO1I11OI downto 0);
  variable I11O1I01 : std_logic_vector(DW_OI11IOIO downto 0);
  variable Oll0O1lO : std_logic_vector(OO10OI11 downto 0);
  variable l1O0IlOI : std_logic_vector(DW_OO00OII1 downto 0);
  variable O100lO10 : std_logic_vector(DW_OO00OII1 downto 0);
  variable l110lO1l : std_logic_vector(DW_OOO111l0 downto 0);
  variable I1I10101 : std_logic_vector(8 - sig_width downto 0);
  variable OO1IO0OO : std_logic_vector(sig_width + 9 downto 0);
  variable I001ll10 : std_logic_vector(9 downto 0);
  variable O1I0I0I1 : std_logic_vector(19 downto 0);
  variable I111I1O0 : std_logic_vector(10 downto 0);
  variable IIOO1OOO : std_logic_vector(19 downto 0);
  variable O00O101I : std_logic_vector(8 downto 0);
  variable O001OII0 : std_logic_vector(sig_width + 3 downto 0);
  variable OOOO00O1 : std_logic_vector(sig_width + 3 downto 0);
  variable OO1l11IO : std_logic_vector(sig_width + 3 downto 0);
  variable O0Ol1Il1 : std_logic_vector(sig_width downto 0);
  variable lIO001IO : std_logic_vector(sig_width downto 0);
  variable O1I110II : std_logic_vector(sig_width downto 0);
  variable O0O0OlOl : std_logic_vector(sig_width downto 0);
  variable OIO01O00 : std_logic_vector(7 - sig_width downto 0);
  variable I11OOO0O : std_logic_vector(8 - sig_width downto 0);

  begin

  O0l1000O := (others => '1');
  I0O0O0IO := '0' & O0l1000O;
  IlO001II := (others => '0');
  lI1l011I := '0' & I0O0O0IO & IlO001II;
  O1OI1lI0 := B"001";
  O100OOI0 := a((exp_width + sig_width)) xor lI1l011I((exp_width + sig_width));
  OlO000O1 := lI1l011I(((exp_width + sig_width) - 1) downto sig_width);
  IOOI01IO := a(((exp_width + sig_width) - 1) downto sig_width);
  lOOllO11 := lI1l011I((sig_width - 1) downto 0);
  OI0Ill10 := a((sig_width - 1) downto 0);
  l1O10II1 := (others => '0');
  I1I0l10O := (others => '0');
  O1I11010 := (others => '0');
  O00IIl0l := (others => '1');
  OlIO0O11 := (others => '0');
  IO10l110 := (others => '0');
  IO001O1l := (others => '1');
  lOIIOI0O := (others => '0');
  IOl1OO01 := (others => '0');
  l01101I0 := (others => '0');
  I1I10101 := (others => '0');
  OO1IO0OO := (others => '0');
  OO1IO0OO(sig_width + 9) := '1';
  l1IOlO01 := 0;
  l0OOO11l := 0;

  if (ieee_compliance = 1) then
    O0l10lOO := (OlO000O1 = ((((2 ** (exp_width-1)) - 1) * 2) + 1)) and (lOOllO11 = 0);
    IOOO0OOO := (IOOI01IO = ((((2 ** (exp_width-1)) - 1) * 2) + 1)) and (OI0Ill10 = 0);
    OO0I1OIl := (OlO000O1 = ((((2 ** (exp_width-1)) - 1) * 2) + 1)) and (lOOllO11 /= 0);
    I00101O1 := (IOOI01IO = ((((2 ** (exp_width-1)) - 1) * 2) + 1)) and (OI0Ill10 /= 0);
    I00I01O1 := (OlO000O1 = 0) and (lOOllO11 = 0);
    lOIIOI1l := (IOOI01IO = 0) and (OI0Ill10 = 0);
    l00lOI1I := (OlO000O1 = 0) and (lOOllO11 /= 0);
    O00001Ol := (IOOI01IO = 0) and (OI0Ill10 /= 0);
    OOO0l10l := O100OOI0 & O00IIl0l & OlIO0O11;
    OIOlO100 := '0' & O00IIl0l & IO10l110 & '1';
  else
    O0l10lOO := (OlO000O1 = ((((2 ** (exp_width-1)) - 1) * 2) + 1));
    IOOO0OOO := (IOOI01IO = ((((2 ** (exp_width-1)) - 1) * 2) + 1));
    OO0I1OIl := false;
    I00101O1 := false;
    I00I01O1 := (OlO000O1 = 0);
    lOIIOI1l := (IOOI01IO = 0);
    l00lOI1I := false;
    O00001Ol := false;
    OOO0l10l := O100OOI0 & O00IIl0l & OlIO0O11;
    OIOlO100 := '0' & O00IIl0l & OlIO0O11;
  end if;

  if (lOIIOI1l) then
    l1O10II1(7) := '1';
  else
    l1O10II1(7) := '0';
  end if;

  if (OO0I1OIl or I00101O1 or (O0l10lOO and IOOO0OOO) or (I00I01O1 and lOIIOI1l)) then
    lOO011OI := OIOlO100;
    l1O10II1(2) := '1';

  elsif (O0l10lOO or lOIIOI1l) then
    lOO011OI := OOO0l10l;
    l1O10II1(1) := '1';

  elsif (I00I01O1 or IOOO0OOO) then
    l1O10II1(0) := '1';
    lOO011OI := (others => '0');
    lOO011OI((exp_width + sig_width)) := O100OOI0;

  else

    if (ieee_compliance = 1) then

      if (l00lOI1I) then
        l1IOlO01 := 1;
        O00IO10O := '0' & lI1l011I((sig_width - 1) downto 0);

        while (O00IO10O(sig_width) /= '1') loop
          O00IO10O := O000OOO0(O00IO10O, 1);
          I1I0l10O := I1I0l10O + 1;
        end loop;
      else
        l1IOlO01 := 0;
        O00IO10O := '1' & lI1l011I((sig_width - 1) downto 0);
      end if;

      if (O00001Ol) then
        l0OOO11l := 1;
        l011011l := '0' & a((sig_width - 1) downto 0);

        while (l011011l(sig_width) /= '1') loop
          l011011l := O000OOO0(l011011l, 1);
          O1I11010 := O1I11010 + 1;
        end loop;
      else
        l0OOO11l := 0;
        l011011l := '1' & a((sig_width - 1) downto 0);
      end if;

    else
      O00IO10O := '1' & lI1l011I((sig_width - 1) downto 0);
      l011011l := '1' & a((sig_width - 1) downto 0);
    end if;

    if (l011011l(sig_width - 1 downto 0) = 0) then
      IO0OlO1O := TRUE;
    else
      IO0OlO1O := FALSE;
    end if;

    if (ieee_compliance = 1) then
      lO10010I := l011011l;
    else
      lO10010I := '1' & OI0Ill10(sig_width - 1 downto 0);
    end if;

    if (sig_width >= 9) then
      l0OO0101 := lO10010I(sig_width - 1 downto l101001I);
    else
      l0OO0101 := lO10010I(sig_width - 1 downto 0) & I1I10101;
    end if;

    I001ll10 := '1' & l0OO0101(8 downto 0);
    I111I1O0 := ('0' & I001ll10) + 1;
    O1I0I0I1 := (others => '0');
    O1I0I0I1(19) := '1';
    IIOO1OOO := Il1lIO0I(O1I0I0I1, I111I1O0);
    O000O0Il := IIOO1OOO(9 downto 1);
    l0O1Ol0O := lO10010I * O000O0Il;
    lO1l1OO0 := not l0O1Ol0O(sig_width + 1 downto 0);
    OI0OIlO1 := O000O0Il * (OO1IO0OO + lO1l1OO0);
    IOOO0Ol0 := OI0OIlO1(sig_width  + 17 downto 14);

    if (sig_width >= 11) then
      IlOI0OOI := lO1l1OO0(sig_width + 1 downto 12) * lO1l1OO0(sig_width + 1 downto 12);
      II1ll01l := IlOI0OOI(2 * sig_width - 21 downto O00l1O10);
      I11O1I01 := IOOO0Ol0(sig_width + 3 downto 14) * II1ll01l;
      Ol1O10O0 := IOOO0Ol0 + I11O1I01(2 * sig_width - 21 downto O00l1O10);
    else
      IlOI0OOI := (others => '0');
      II1ll01l := (others => '0');
      I11O1I01 := (others => '0');
      Ol1O10O0 := (others => '0');
    end if;
    
    if (sig_width >= 25) then
      Oll0O1lO := II1ll01l(sig_width - 11 downto 13);
      O100lO10 := Ol1O10O0(sig_width + 3 downto 27) * l1O0IlOI(2 * sig_width - 47 downto sig_width - 23);
      l110lO1l := O100lO10(2 * sig_width - 47 downto sig_width - 22);
      l1O0IlOI := Oll0O1lO * Oll0O1lO;
      l101lO0O := Ol1O10O0 + l110lO1l;
    else
      Oll0O1lO := (others => '0');
      O100lO10 := (others => '0');
      l110lO1l := (others => '0');
      l1O0IlOI := (others => '0');
      l101lO0O := (others => '0');
    end if;


    if (sig_width <= 8) then
      OIO01O00 := (others => '0');
      I11OOO0O := '1' & OIO01O00;
    else 
      OIO01O00 := (others => '0');
      I11OOO0O := (others => '0');
    end if;

    if (sig_width = 8) then
      O00O101I := O000O0Il + 1;
    elsif (sig_width < 8) then
      O00O101I := O000O0Il + I11OOO0O;
    else 
      O00O101I := (others => '0');
    end if;
  
    O001OII0 := IOOO0Ol0 + "1000";
    OOOO00O1 := Ol1O10O0 + "1000";
    OO1l11IO := l101lO0O + "1000";

    if (sig_width >= 8) then
      O0Ol1Il1(8 downto 0) := O00O101I(8 downto 0);
    elsif (O000O0Il(7 - sig_width) = '1') then
      O0Ol1Il1 := O00O101I(8 downto OIl0I0IO);
    else 
      O0Ol1Il1 := O000O0Il(8 downto OIl0I0IO);
    end if;

    if (IOOO0Ol0(2) = '1') then
      lIO001IO := O001OII0(sig_width + 3 downto 3);
    else
      lIO001IO := IOOO0Ol0(sig_width + 3 downto 3);
    end if;

    if (Ol1O10O0(2) = '1') then
      O1I110II := OOOO00O1(sig_width + 3 downto 3);
    else
      O1I110II := Ol1O10O0(sig_width + 3 downto 3);
    end if;

    if (l101lO0O(2) = '1') then
      O0O0OlOl := OO1l11IO(sig_width + 3 downto 3);
    else
      O0O0OlOl := l101lO0O(sig_width + 3 downto 3);
    end if;

    if (IO0OlO1O) then
      lI0l111l := (others => '0');
    elsif (sig_width <= 8) then
      lI0l111l := O0Ol1Il1;
    elsif (sig_width <= 14) then
      lI0l111l := lIO001IO;
    elsif (sig_width <= 30) then
      lI0l111l := O1I110II;
    else
      lI0l111l := O0O0OlOl;
    end if;

    Ill1lII0 := (others => '0');
    Ill1lII0(0) := '1';

    I0l110I0 := ((B"00" & OlO000O1) - (B"00" & I1I0l10O) + l1IOlO01) - ((B"00" & IOOI01IO) - (B"00" & O1I11010) + l0OOO11l) + ((2 ** (exp_width-1)) - 1);
    OOl100OI := ((B"00" & IOOI01IO) + (B"00" & I1I0l10O) + l0OOO11l) - ((B"00" & OlO000O1) + (B"00" & O1I11010) + ((2 ** (exp_width-1)) - 1) + l1IOlO01);
    if (IO0OlO1O) then
      lOO00lI0 := I0l110I0;
      OO111l0O := OOl100OI;
    else
      lOO00lI0 := I0l110I0 - 1;
      OO111l0O := OOl100OI + 1;
    end if;

    O1IlO100 := lI0l111l;
    OI0llO10 := (others => '0');
    O0I11O0l := lOO00lI0;
    O01I1IO1 := OO111l0O;
    OIllO0O1 := '1';
  
    if (ieee_compliance = 1) then
      if ((O0I11O0l <= 0) or (O0I11O0l(exp_width + 1) = '1')) then
        lOO00O01 := O01I1IO1 + 1;

        OO00I1O1 := IIOO1I10(O1IlO100 & IOl1OO01, conv_integer(lOO00O01));
        O1IlO100 := OO00I1O1(2 * sig_width + 1 downto sig_width + 1);
        OIIIOl01 := OO00I1O1(sig_width downto 0);

        if (lOO00O01 > sig_width + 1) then
          OIllO0O1 := '1';
        end if;

        OI0llO10(1) := O1IlO100(0);
        OI0llO10(0) := OIIIOl01(sig_width);
  
        if (OIIIOl01(sig_width - 1 downto 0) /= 0) then
          OIllO0O1 := '1';
        end if;
      end if;
    end if;

    l0100O0l := OO11l0O1(O1OI1lI0, O100OOI0, OI0llO10(1), OI0llO10(0), OIllO0O1);

    if (l0100O0l(DW_O110O00O) = '1') then
      I11l0100 := O1IlO100 + 1;
    else
      I11l0100 := O1IlO100;
    end if;

    if ((O0I11O0l >= ((((2 ** (exp_width-1)) - 1) * 2) + 1)) and (O0I11O0l(exp_width + 1) = '0')) then
      l1O10II1(4) := '1';
      l1O10II1(5) := '1';
  
      if ((l0100O0l(DW_OOO101O1) = '1') or (faithful_round = 1)) then
        OO01l0I0 := OOO0l10l(sig_width downto 0);
        l0l0IOlO := conv_std_logic_vector(((((2 ** (exp_width-1)) - 1) * 2) + 1), l0l0IOlO'length);
        l1O10II1(1) := '1';
      else
        OO01l0I0 := (others => '1');
        l0l0IOlO := conv_std_logic_vector(((((2 ** (exp_width-1)) - 1) * 2) + 1) - 1, l0l0IOlO'length);
      end if;

    elsif ((O0I11O0l <= 0) or (O0I11O0l(exp_width + 1) = '1')) then
      l1O10II1(3) := '1';

      if (ieee_compliance = 0) then
        l1O10II1(5) := '1';
      
        if (l0100O0l(DW_IIlI101I) = '1') then
          OO01l0I0 := (others => '0');
          l0l0IOlO := conv_std_logic_vector(0 + 1, l0l0IOlO'length);
        else
          OO01l0I0 := (others => '0');
          l0l0IOlO := conv_std_logic_vector(0, l0l0IOlO'length);
          l1O10II1(0) := '1';
        end if;
      else
        OO01l0I0 := I11l0100;
        l0l0IOlO := conv_std_logic_vector(conv_integer(I11l0100(sig_width)), l0l0IOlO'length);

      end if;
    else 
      OO01l0I0 := I11l0100;
      l0l0IOlO := O0I11O0l;
    end if;

    if (ieee_compliance = 1 and (O0I11O0l = 0) and (O1IlO100 = 0)) then
      OO01l0I0(sig_width - 1) := '1';
    end if;

    if ((OO01l0I0(sig_width - 1 downto 0) = 0) and (l0l0IOlO(exp_width - 1 downto 0) = 0)) then
      l1O10II1(0) := '1';
    end if;

    if (IO0OlO1O = FALSE) then
      l1O10II1(5) := l1O10II1(5) or l0100O0l(DW_IOI010lO);
    end if;

    lOO011OI := O100OOI0 & l0l0IOlO(exp_width - 1 downto 0) & OO01l0I0(sig_width - 1 downto 0);

  end if;


  if (Is_X(a) or Is_X(rnd)) then
  
    status <= (others => 'X');
    z <= (others => 'X');
  
  else

    if (faithful_round = 1) then
      status <= l1O10II1;
      z <= lOO011OI;
    else
      status <= O1010O0O;
      z <= O00OI111;
    end if;

  end if;


  end process l001OOOI;

  -- pragma translate_on

end sim;


--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

library dw02;

configuration DW_fp_recip_cfg_sim of DW_fp_recip is
 for sim
  for U1 : DW_fp_div use configuration dw02.DW_fp_div_cfg_sim; end for;
 end for; -- sim
end DW_fp_recip_cfg_sim;
-- pragma translate_on

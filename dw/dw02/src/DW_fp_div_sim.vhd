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
-- AUTHOR:    Kyung-Nam Han  Mar. 22, 2006
--
-- VERSION:   VHDL Simulation model for DW_fp_div
--
-- DesignWare_version: 5e4ef900
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--
-- ABSTRACT: Floating-Point Divider
--
--              DW_fp_div calculates the floating-point division
--              while supporting six rounding modes, including four IEEE
--              standard rounding modes.
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
--              faithful_round  select the faithful_rounding that admits 1 ulp error
--                              0 - default value. it keeps all rounding modes
--                              1 - z has 1 ulp error. RND input does not affect
--                                  the output
--
--              Input ports     Size & Description
--              ===========     ==================
--              a               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Input
--              b               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Input
--              rnd             3 bits
--                              Rounding Mode Input
--
--              Output ports    Size & Description
--              ============    ==================
--              z               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Output
--              status          8 bits
--                              Status Flags Output
--
-- MODIFIED: 
--   5/7/2007 (0703-SP2):
--     Fixed the rounding error of denormal numbers when ieee_compliance = 1
--   10/18/2007 (0712):
--     Fixed the 'divide by zero' flag when 0/0 
--   1/2/2008 (0712-SP1):
--     New parameter, faithful_round, is introduced
--   6/4/2010 (2010.03-SP3):
--     Removed VCS error [IRIPS] when sig_width = 2 and 3.
--   1/30/2017 (2016.12-SP3): STAR 9001167381
--     Fix of output z between zero and minnorm
--   6/15/2017 (2016.12-SP5): Fix of STAR 9001189734 and 9001210054
--   5/01/2018 (2018.06): Modification for the full parameter coverage
--                        at each implementation.
-----------------------------------------------------------------------------


library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_misc.all;
use ieee.numeric_std.all;
use DWARE.DWpackages.all;

architecture sim of DW_fp_div is
	

  -- pragma translate_off



  constant OIIlOlO1 : boolean := ((faithful_round = 1) and (sig_width >= 11) and (sig_width <= 57));

  constant rnd_width          : integer  := 4;
  constant rnd_inc            : integer  := 0;
  constant rnd_inexact        : integer  := 1;
  constant rnd_hugeinfinity   : integer  := 2;
  constant rnd_tinyminnorm    : integer  := 3;

  constant qwidth             : integer := (2 * sig_width + 2);
  constant qmsb               : integer := (sig_width + 2);
  constant ext                : integer := (sig_width + 2);
  ----------------------------------------------------------------------
  function lOO11O0l (a : in std_logic_vector; b : in std_logic_vector) return std_logic_vector is

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
  function O11110OI (a : in std_logic_vector; b : in std_logic_vector) return std_logic_vector is

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
  function O11Il110 (a : in std_logic_vector; sh : in integer) return std_logic_vector is

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
  function lOOOII1l (
    rnd    : in std_logic_vector(2 downto 0);
    Sign   : in std_logic;
    L      : in std_logic;
    R      : in std_logic;
    I101O11O    : in std_logic )
    return std_logic_vector is

    variable lOOOII1l : std_logic_vector(rnd_width - 1 downto 0);
  
    begin
  
    lOOOII1l(rnd_inc) := '0';
    lOOOII1l(rnd_inexact) := R OR I101O11O;
    lOOOII1l(rnd_hugeinfinity) := '0';
    lOOOII1l(rnd_tinyminnorm) := '0';
  
    case rnd is
  
    when "000" =>
      lOOOII1l(rnd_inc) := R AND (L OR I101O11O);
      lOOOII1l(rnd_hugeinfinity) := '1';
      lOOOII1l(rnd_tinyminnorm) := '0';
  
    when "001" =>
      lOOOII1l(rnd_inc) := '0';
      lOOOII1l(rnd_hugeinfinity) := '0';
      lOOOII1l(rnd_tinyminnorm) := '0';
  
    when "010" =>
      lOOOII1l(rnd_inc) := not (Sign) AND (R OR I101O11O);
      lOOOII1l(rnd_hugeinfinity) := not (Sign);
      lOOOII1l(rnd_tinyminnorm) := not (Sign);
  
    when "011" =>
      lOOOII1l(rnd_inc) := Sign AND (R OR I101O11O);
      lOOOII1l(rnd_hugeinfinity) := Sign;
      lOOOII1l(rnd_tinyminnorm) := Sign;
  
    when "100" =>
      lOOOII1l(rnd_inc) := R;
      lOOOII1l(rnd_hugeinfinity) := '1';
      lOOOII1l(rnd_tinyminnorm) := '0';
  
    when "101" =>
      lOOOII1l(rnd_inc) := R OR I101O11O;
      lOOOII1l(rnd_hugeinfinity) := '1';
      lOOOII1l(rnd_tinyminnorm) := '1';
  
    when others =>
      lOOOII1l(rnd_inc) := 'X';
      lOOOII1l(rnd_hugeinfinity) := 'X';
      lOOOII1l(rnd_tinyminnorm) := 'X';
  
    end case;
  
    return(lOOOII1l);

  end function;

  -- pragma translate_on

  ----------------------------------------------------------------------

begin

  -- pragma translate_off

  
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
     
    if ( (sig_width < 2) OR (sig_width > 253) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter sig_width (legal range: 2 to 253)"
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


  II0l1001: process (a, b, rnd)

  variable l1l1O100 : std_logic_vector((exp_width + sig_width) downto 0);
  variable lO101111 : std_logic_vector(exp_width - 1 downto 0);
  variable lI00O00I : std_logic_vector(exp_width - 1 downto 0);
  variable O00O1Ol1 : std_logic_vector(sig_width - 1 downto 0);
  variable II01O1O0 : std_logic_vector(sig_width - 1 downto 0);
  variable IOO1O01O : std_logic_vector((exp_width + bit_width(sig_width) + 2) - 1 downto 0);
  variable O10101O1 : std_logic_vector((exp_width + bit_width(sig_width) + 2) - 1 downto 0);
  variable I1O1O11O : std_logic_vector((exp_width + bit_width(sig_width) + 2) - 1 downto 0);
  variable lO1O0OI1 : std_logic_vector((exp_width + bit_width(sig_width) + 2) - 1 downto 0);
  variable IO10IOO1 : std_logic_vector(exp_width + 1 downto 0);
  variable I11OOO10 : std_logic_vector((exp_width + bit_width(sig_width) + 2) - exp_width - 1 downto 0);
  variable l10OO10O : std_logic_vector((exp_width + bit_width(sig_width) + 2) - 1 downto 0);
  variable OlOO00lO : std_logic_vector((exp_width + bit_width(sig_width) + 2) - 1 downto 0);
  variable OOIl0010 : std_logic_vector(sig_width downto 0);
  variable IOOl0lII : std_logic_vector(sig_width downto 0);
  variable OI1IOllI : std_logic_vector(sig_width downto 0);
  variable l11Illl0 : std_logic_vector(sig_width downto 0);
  variable lO001Ol0 : std_logic_vector(sig_width downto 0);
  variable normfrac_pre : std_logic_vector(2 * sig_width + 1 downto 0);
  variable I0OI1lO0 : std_logic_vector(sig_width downto 0);
  variable O10110O1 : std_logic_vector(qwidth downto 0);
  variable O011IOO0 : std_logic_vector(sig_width downto 0);
  variable I11IO1I1 : std_logic_vector(1 downto 0);
  variable OO000O0O : std_logic_vector(rnd_width - 1 downto 0);
  variable O00OO1I0 : std_logic_vector(8     - 1 downto 0);
  variable OOl0111O : std_logic_vector(exp_width - 1 downto 0);
  variable I1O0I10O : std_logic_vector(sig_width - 1 downto 0);
  variable OlOI1111 : std_logic_vector(sig_width - 1 downto 0);
  variable I10Il000 : std_logic_vector(sig_width - 2 downto 0);
  variable IIl1O10O : std_logic_vector((exp_width + sig_width) downto 0);
  variable I00lIO1l : std_logic_vector((exp_width + sig_width) downto 0);
  variable l1011lII : std_logic_vector(ext - 1 downto 0);
  variable I0Il1OII : std_logic_vector(sig_width + ext downto 0);
  variable O11O0O01 : std_logic_vector(sig_width + ext downto 0);
  variable ll1110OO : std_logic_vector(sig_width + ext downto 0);
  variable OIOO1O0O : std_logic_vector(sig_width + ext downto 0);
  variable OIIO0OOl : std_logic_vector(exp_width + 1 downto 0);
  variable l0III011 : std_logic_vector(exp_width + 1 downto 0);
  variable OO0lIO1O : std_logic_vector((exp_width + bit_width(sig_width) + 2) - 1 downto 0);
  variable l0lO100O : std_logic_vector(sig_width downto 0);
  variable l00IlOl1 : std_logic_vector(2 * sig_width + 1 downto 0);
  variable IOIlII10 : std_logic_vector(sig_width downto 0);
  variable I101O11O : std_logic;
  variable lO011100 : std_logic;
  variable lOI111I1 : BOOLEAN;
  variable O100O11l : BOOLEAN;
  variable l10OO1I0 : BOOLEAN;
  variable l1O1Ol0O : BOOLEAN;
  variable I000lO00 : BOOLEAN;
  variable l1OllI0I : BOOLEAN;
  variable lO00I10I : BOOLEAN;
  variable IIIl11O1 : BOOLEAN;
  variable l000I1O0 : BOOLEAN;
  variable l11I1010 : INTEGER;
  variable O0OI0OO0 : INTEGER;
  variable O00Ol011 : INTEGER;
  variable O1001010 : INTEGER;
  variable O10O1OO0 : INTEGER;
  variable Ol01O010 : std_logic;
  variable lO1I110I : std_logic;
  variable II0IIO1O : std_logic_vector(sig_width downto 0);
  variable I0I0Il0O : std_logic_vector(sig_width downto 0);
  variable OO00O010 : std_logic_vector(8 - sig_width downto 0);
  variable l110l11I : std_logic_vector(8 downto 0);
  variable IOOlIOOO : std_logic_vector(9 downto 0);
  variable I1l100OI : std_logic_vector(10 downto 0);
  variable l0l1O011 : std_logic_vector(19 downto 0);
  variable IO00O1O1 : std_logic_vector(8 downto 0);
  variable OlOO1OO1 : std_logic_vector(19 downto 0);
  variable OOI10OIO : std_logic_vector(sig_width + 9 downto 0);
  variable l0IO1lOO : std_logic;
  variable OO0OO1I0 : std_logic_vector(8 downto 0);
  variable O00OI010 : std_logic_vector(sig_width + 9 downto 0);
  variable IOIlOO00 : std_logic_vector(sig_width + 1 downto 0);
  variable O0O0IIII : std_logic_vector(2 * sig_width - 7 downto 0);
  variable II11llO0 : std_logic_vector(sig_width + 3 downto 0);
  variable l0101100 : std_logic_vector(sig_width + 3 downto 0);
  variable l0I1OOll : std_logic_vector(sig_width + 3 downto 0);
  variable OIlI10I1 : std_logic;
  variable Ol1O10O0 : std_logic_vector(sig_width + 3 downto 0);
  variable O1l11OIO : std_logic_vector(2 * sig_width - 21 downto 0);
  variable Il101Il1 : std_logic_vector(sig_width - 11 downto 0);
  variable IOll10OO : std_logic_vector(2 * sig_width - 21 downto 0);
  variable O0l0O011 : std_logic_vector(sig_width + 3 downto 0);
  variable OOO01OO1 : std_logic;
  variable O0O1011O : std_logic_vector(sig_width + 3 downto 0);
  variable llOO0II1 : std_logic_vector(sig_width - 24 downto 0);
  variable O010I0IO : std_logic_vector(2 * sig_width - 47 downto 0);
  variable OOOl110I : std_logic_vector(2 * sig_width - 47 downto 0);
  variable O00O00O1 : std_logic_vector(sig_width - 25 downto 0);
  variable lI100I0I : std_logic_vector(sig_width + 3 downto 0);
  variable I10l01Il : std_logic;
  variable O1O0011O : std_logic_vector(sig_width + 3 downto 0);
  variable O1O1O01l : std_logic_vector(8 downto 0);
  variable l10IIOlO : std_logic_vector(sig_width - 1 downto 0);
  variable I100O001 : std_logic_vector(7 - sig_width downto 0);
  variable lO1O0IlO : std_logic_vector(8 downto 0);
  variable l0I1OI0l : std_logic_vector(sig_width + 3 downto 0);
  variable IIOI0lOO : std_logic_vector(sig_width + 3 downto 0);
  variable O11OOOOl : std_logic_vector(sig_width + 3 downto 0);
  variable I1O0OO1I : std_logic_vector(sig_width - 1 downto 0);
  variable O1O11O1I : std_logic_vector(sig_width + 3 downto 0);
  variable OO1110O0 : std_logic_vector(sig_width downto 0);
  variable I01II0I0 : std_logic_vector(sig_width downto 0);
  variable IOIOI010 : std_logic_vector(sig_width downto 0);
  variable IOO101lO : std_logic_vector(sig_width downto 0);
  variable OlIlOOIO : std_logic_vector(sig_width downto 0);
  variable Ol011lO0 : std_logic;
  variable I010IlI0 : std_logic;
  variable lO0IO11l : std_logic;
  variable OOO111OO : std_logic;
  variable I0I0OO01 : std_logic_vector(13 downto 0);
  variable IO11OO01 : std_logic_vector(sig_width downto 0);
  variable O101OOOO : std_logic_vector((2 * ((sig_width - 3) + 2)) - 1 downto 0);
  variable O010OOO1 : std_logic_vector((sig_width + 4 + 2) - 1 downto 0);
  variable O1I10I10 : std_logic_vector((sig_width + 4 + 2) - 1 downto 0);
  variable l101O0Ol : std_logic_vector((sig_width + 4 + 2) - 1 downto 0);
  variable lI101011 : std_logic_vector(6 downto 0);
  variable OIO10l10 : std_logic_vector(2 * sig_width + 1 downto 0);
  variable I10OIO10 : std_logic_vector(2 * sig_width + 1 downto 0);
  variable OIOlIO00 : integer;


  begin

  lO011100 := a((exp_width + sig_width)) xor b((exp_width + sig_width));
  lO101111 := a(((exp_width + sig_width) - 1) downto sig_width);
  lI00O00I := b(((exp_width + sig_width) - 1) downto sig_width);
  O00O1Ol1 := a((sig_width - 1) downto 0);
  II01O1O0 := b((sig_width - 1) downto 0);
  O00OO1I0 := (others => '0');
  OIIO0OOl := (others => '0');
  l0III011 := (others => '0');
  OOl0111O := (others => '1');
  I1O0I10O := (others => '0');
  I10Il000 := (others => '0');
  OlOI1111 := (others => '1');
  l1011lII := (others => '0');
  l0lO100O := (others => '0');
  OI1IOllI := (others => '0');
  OO00O010 := (others => '0');
  l10IIOlO := (others => '0');
  I100O001 := (others => '0');
  I1O0OO1I := (others => '0');
  O1O11O1I := I1O0OO1I & "1000";
  I0I0OO01 := (others => '0');
  O1001010 := 0;
  O10O1OO0 := 0;
  IO11OO01 := (others => '1');
  I11OOO10 := (others => '0');

  if (sig_width <= 8) then
    lO1O0IlO := l10IIOlO & '1' & I100O001;
  else 
    lO1O0IlO := (others => '0');
  end if;



  if (ieee_compliance = 1) then
    lOI111I1 := (lO101111 = ((((2 ** (exp_width-1)) - 1) * 2) + 1)) and (O00O1Ol1 = 0);
    O100O11l := (lI00O00I = ((((2 ** (exp_width-1)) - 1) * 2) + 1)) and (II01O1O0 = 0);
    l10OO1I0 := (lO101111 = ((((2 ** (exp_width-1)) - 1) * 2) + 1)) and (O00O1Ol1 /= 0);
    l1O1Ol0O := (lI00O00I = ((((2 ** (exp_width-1)) - 1) * 2) + 1)) and (II01O1O0 /= 0);
    I000lO00 := (lO101111 = 0) and (O00O1Ol1 = 0);
    l1OllI0I := (lI00O00I = 0) and (II01O1O0 = 0);
    lO00I10I := (lO101111 = 0) and (O00O1Ol1 /= 0);
    IIIl11O1 := (lI00O00I = 0) and (II01O1O0 /= 0);

    IIl1O10O := lO011100 & OOl0111O & I1O0I10O;
    I00lIO1l := '0' & OOl0111O & I10Il000 & '1';
  else
    lOI111I1 := (lO101111 = ((((2 ** (exp_width-1)) - 1) * 2) + 1));
    O100O11l := (lI00O00I = ((((2 ** (exp_width-1)) - 1) * 2) + 1));
    l10OO1I0 := false;
    l1O1Ol0O := false;
    I000lO00 := (lO101111 = 0);
    l1OllI0I := (lI00O00I = 0);
    lO00I10I := false;
    IIIl11O1 := false;

    IIl1O10O := lO011100 & OOl0111O & I1O0I10O;
    I00lIO1l := '0' & OOl0111O & I1O0I10O;
  end if;

  if (ieee_compliance = 1) then
    if (l1OllI0I and not(I000lO00 or l10OO1I0 or lOI111I1) ) then
      O00OO1I0(7) := '1';
    else
      O00OO1I0(7) := '0';
    end if;
  else
    if (l1OllI0I and not(I000lO00 or l10OO1I0) ) then
      O00OO1I0(7) := '1';
    else
      O00OO1I0(7) := '0';
    end if;
  end if;

  if (l10OO1I0 or l1O1Ol0O or (lOI111I1 and O100O11l) or (I000lO00 and l1OllI0I)) then
    l1l1O100 := I00lIO1l;
    O00OO1I0(2) := '1';

  elsif (lOI111I1 or l1OllI0I) then
    l1l1O100 := IIl1O10O;
    O00OO1I0(1) := '1';

  elsif (I000lO00 or O100O11l) then
    O00OO1I0(0) := '1';
    l1l1O100 := (others => '0');
    l1l1O100((exp_width + sig_width)) := lO011100;

  else

    if (ieee_compliance = 1) then

      if (lO00I10I) then
        O1001010 := 1;
        OOIl0010 := '0' & a((sig_width - 1) downto 0);

        while (OOIl0010(sig_width) /= '1') loop
          OOIl0010 := O11Il110(OOIl0010, 1);
          OIIO0OOl := OIIO0OOl + 1;
        end loop;
      else
        O1001010 := 0;
        OOIl0010 := '1' & a((sig_width - 1) downto 0);
      end if;

      if (IIIl11O1) then
        O10O1OO0 := 1;
        IOOl0lII := '0' & b((sig_width - 1) downto 0);

        while (IOOl0lII(sig_width) /= '1') loop
          IOOl0lII := O11Il110(IOOl0lII, 1);
          l0III011 := l0III011 + 1;
        end loop;
      else
        O10O1OO0 := 0;
        IOOl0lII := '1' & b((sig_width - 1) downto 0);
      end if;

    else
      OOIl0010 := '1' & a((sig_width - 1) downto 0);
      IOOl0lII := '1' & b((sig_width - 1) downto 0);
    end if;

    if (OOIl0010 = IOOl0lII) then
      Ol01O010 := '1';
    else
      Ol01O010 := '0';
    end if;

    if (IOOl0lII(sig_width - 1 downto 0) = 0) then
      lO1I110I := '1';
    else
      lO1I110I := '0';
    end if;

    II0IIO1O := OOIl0010;

    if (ieee_compliance = 1) then
      I0I0Il0O := IOOl0lII;
    else
      I0I0Il0O := '1' & II01O1O0;
    end if;

    if (sig_width >= 9) then
      l110l11I := I0I0Il0O(sig_width - 1 downto sig_width - 9);
    else
      l110l11I := I0I0Il0O(sig_width - 1 downto 0) & OO00O010;
    end if;

    IOOlIOOO := '1' & l110l11I(8 downto 0);
    I1l100OI := ('0' & IOOlIOOO) + 1;
    OlOO1OO1 := (others => '0');
    OlOO1OO1(19) := '1';
    l0l1O011 := lOO11O0l(OlOO1OO1, I1l100OI);
    IO00O1O1 := l0l1O011(9 downto 1);
    OOI10OIO := IO00O1O1 * II0IIO1O;
    l0IO1lOO := OOI10OIO(sig_width + 9);

    if (l0IO1lOO = '1') then
      OO0OO1I0 := OOI10OIO(sig_width + 9 downto sig_width + 1);
    else
      OO0OO1I0 := OOI10OIO(sig_width + 8 downto sig_width);
    end if;

    O00OI010 := I0I0Il0O * IO00O1O1;
    IOIlOO00 := not O00OI010(sig_width + 1 downto 0);

    lI101011 := (others => '0');
    O101OOOO := OOI10OIO((sig_width + 10) - 1 downto (sig_width + 10) - (sig_width - 3) - 2) *
               IOIlOO00((sig_width + 2) - 1 downto (sig_width + 2) - (sig_width - 3) - 2);
    O010OOO1 := lI101011 & O101OOOO((2 * ((sig_width - 3) + 2)) - 1 downto (2 * ((sig_width - 3) + 2)) - (sig_width + 4 + 2) + 7);
    O1I10I10 := OOI10OIO((sig_width + 10) - 1 downto (sig_width + 10) - (sig_width + 4 + 2));
    l101O0Ol := O1I10I10 + O010OOO1;

    if (sig_width <= 8) then
      O0O0IIII := (others => '0');
    else
      O0O0IIII := OOI10OIO(sig_width + 9 downto 13) * IOIlOO00(sig_width + 1 downto 5);
    end if;

    if (sig_width > 8) then
      l0101100 := "0000000" & O0O0IIII(2 * sig_width - 7 downto sig_width - 3);
    else
      l0101100 := (others=>'0');
    end if;

    II11llO0 := OOI10OIO(sig_width + 9 downto 6);

    l0I1OOll := II11llO0 + l0101100;
    OIlI10I1 := l0I1OOll(sig_width + 3);

    if ((sig_width >= 14)) then
      Ol1O10O0 := l101O0Ol((sig_width + 4 + 2) - 1 downto (sig_width + 4 + 2) - (sig_width + 4));
    else
      if (OIlI10I1 = '1') then
        Ol1O10O0 := l0I1OOll;
      else
        Ol1O10O0 := l0I1OOll(sig_width + 2 downto 0) & '0';
      end if;
    end if;

    if (sig_width >= 11) then
      O1l11OIO := IOIlOO00(sig_width + 1 downto 12) * IOIlOO00(sig_width + 1 downto 12);
      Il101Il1 := O1l11OIO(2 * sig_width - 21 downto sig_width - 10);
      IOll10OO := Ol1O10O0(sig_width + 3 downto 14) * Il101Il1;
      O0l0O011 := Ol1O10O0 + (I0I0OO01 & IOll10OO(2 * sig_width - 21 downto sig_width - 10));
      OOO01OO1 := O0l0O011(sig_width + 3);
    else
      O1l11OIO := (others => '0');
      Il101Il1 := (others => '0');
      IOll10OO := (others => '0');
      O0l0O011 := (others => '0');
      OOO01OO1 := '0';
    end if;

    if (sig_width <= 28) then
      if (OOO01OO1 = '1') then
        O0O1011O := O0l0O011;
      else
        O0O1011O := O0l0O011(sig_width + 2 downto 0) & '0';
      end if;
    else
      O0O1011O := O0l0O011;
    end if;

    if (sig_width >= 25) then
      llOO0II1 := Il101Il1(sig_width - 11 downto 13);
      O010I0IO := llOO0II1 * llOO0II1;
      OOOl110I := O0O1011O(sig_width + 3 downto 27) * O010I0IO(2 * sig_width - 47 downto sig_width - 23);
      O00O00O1 := OOOl110I(2 * sig_width - 47 downto sig_width - 22);
      lI100I0I := O0O1011O + (B"0000000000000000000000000000" & O00O00O1);
    else
      llOO0II1 := (others => '0');
      O010I0IO := (others => '0');
      OOOl110I := (others => '0');
      O00O00O1 := (others => '0');
      lI100I0I := (others => '0');
    end if;
    
    I10l01Il := lI100I0I(sig_width + 3);

    if (I10l01Il = '1') then
      O1O0011O := lI100I0I;
    else
      O1O0011O := lI100I0I(sig_width + 2 downto 0) & '0';
    end if;

    if (sig_width = 8) then
      O1O1O01l := OO0OO1I0 + 1;
    elsif (sig_width < 8) then
      O1O1O01l := OO0OO1I0 + lO1O0IlO;
    else
      O1O1O01l := (others => '0');
    end if;

    l0I1OI0l := Ol1O10O0 + O1O11O1I;
    IIOI0lOO := O0O1011O + O1O11O1I;
    O11OOOOl := O1O0011O + O1O11O1I;

    if (sig_width > 8) then
      OO1110O0 := (others => '0');
    elsif (sig_width = 8) then
      OO1110O0 := OO0OO1I0(8 downto 8 - sig_width);
    elsif (OO0OO1I0(7 - sig_width) = '1') then
      OO1110O0 := O1O1O01l(8 downto 8 - sig_width);
    else
      OO1110O0 := OO0OO1I0(8 downto 8 - sig_width);
    end if;

    if (Ol1O10O0(2) = '1') then
      I01II0I0 := l0I1OI0l(sig_width + 3 downto 3);
    else
      I01II0I0 := Ol1O10O0(sig_width + 3 downto 3);
    end if;

    if (O0O1011O(2) = '1') then
      IOIOI010 := IIOI0lOO(sig_width + 3 downto 3);
    else
      IOIOI010 := O0O1011O(sig_width + 3 downto 3);
    end if;

    if (O1O0011O(2) = '1') then
      IOO101lO := O11OOOOl(sig_width + 3 downto 3);
    else
      IOO101lO := O1O0011O(sig_width + 3 downto 3);
    end if;

    if (sig_width <= 8) then
      OlIlOOIO := OO1110O0;
      I010IlI0 := l0IO1lOO;
    elsif (sig_width <= 13) then
      OlIlOOIO := I01II0I0;
      I010IlI0 := OIlI10I1;
    elsif (sig_width <= 28) then
      OlIlOOIO := IOIOI010;
      I010IlI0 := OOO01OO1;
    else
      OlIlOOIO := IOO101lO;
      I010IlI0 := I10l01Il;
    end if;

    if (OIIlOlO1) then
      if (OlIlOOIO = 0) then
        Ol011lO0 := '1';
      else
        Ol011lO0 := '0';
      end if;
    else
      Ol011lO0 := '0';
    end if;

    if (II01O1O0 /= 0) then
      lO0IO11l := not Ol01O010;
    else
      lO0IO11l := '0';
    end if;


    I0Il1OII := OOIl0010 & l1011lII;
    O11O0O01 := l1011lII & IOOl0lII;

    if (IOOl0lII /= OI1IOllI) then
      ll1110OO := lOO11O0l(I0Il1OII, O11O0O01);
      OIOO1O0O := O11110OI(I0Il1OII, O11O0O01);

      O10110O1 := ll1110OO;

      if (OIIlOlO1) then
        O011IOO0 := (others => lO0IO11l);
      else
        O011IOO0 := OIOO1O0O(sig_width downto 0);
      end if;
    end if;

    IOO1O01O := ((I11OOO10 & lO101111) - OIIO0OOl + O1001010) - ((I11OOO10 & lI00O00I) - l0III011 + O10O1OO0) + ((2 ** (exp_width-1)) - 1);
    I1O1O11O := ((I11OOO10 & lI00O00I) + OIIO0OOl + O10O1OO0) - ((I11OOO10 & lO101111) + l0III011 + ((2 ** (exp_width-1)) - 1) + O1001010);
    O10101O1 := IOO1O01O - 1;
    lO1O0OI1 := I1O1O11O + 1;

    if (OIIlOlO1) then
      if ((lO1I110I = '1') and (ieee_compliance = 0)) then
        lO001Ol0 := II0IIO1O;
      else
        lO001Ol0 := OlIlOOIO;
      end if;
    elsif (O10110O1(qmsb) = '1') then
      lO001Ol0 := O10110O1(qmsb downto 2);
    else
      lO001Ol0 := O10110O1(qmsb - 1 downto 1);
    end if;

    if (O10110O1(qmsb) = '1') then
      I11IO1I1 := O10110O1(2 downto 1);
      l10OO10O := IOO1O01O;
      OlOO00lO := I1O1O11O;
    else
      I11IO1I1 := O10110O1(1 downto 0);
      l10OO10O := O10101O1;
      OlOO00lO := lO1O0OI1;
    end if;

    if (l10OO10O <= 0 or l10OO10O((exp_width + bit_width(sig_width) + 2) - 1) = '1') then
      OOO111OO := '1';
    else
      OOO111OO := '0';
    end if;

    if (OIIlOlO1) then
      if ((lO1I110I = '1' or Ol01O010 = '1') and OOO111OO = '0') then
        I101O11O := '0';
      else 
        I101O11O := '1';
      end if;
    else
      if (O011IOO0 = 0) then
        I101O11O := '0';
      else
        I101O11O := '1';
      end if;
    end if;
  
    normfrac_pre := lO001Ol0 & l0lO100O;

    if (ieee_compliance = 1) then
      if ((l10OO10O <= 0) or (l10OO10O((exp_width + bit_width(sig_width) + 2) - 1) = '1')) then
        if (OIIlOlO1) then
          OO0lIO1O := OlOO00lO + 1 + Ol01O010;
        else
          OO0lIO1O := OlOO00lO + 1;
        end if;

        OIO10l10 := lO001Ol0 & l0lO100O;
        OIOlIO00 := conv_integer(OO0lIO1O);

        I10OIO10 := OIO10l10;
        while (OIOlIO00 > 0) loop
          I10OIO10 := '0' & I10OIO10(I10OIO10'length-1 downto 1);
          OIOlIO00 := OIOlIO00 - 1;
        end loop;
        l00IlOl1 := I10OIO10;

        lO001Ol0 := l00IlOl1(2 * sig_width + 1 downto sig_width + 1);
        IOIlII10 := l00IlOl1(sig_width downto 0);

        if (OO0lIO1O > (sig_width + 1)) then
          I101O11O := '1';
        end if;

        I11IO1I1(1) := lO001Ol0(0);
        I11IO1I1(0) := IOIlII10(sig_width);
  
        if (IOIlII10(sig_width - 1 downto 0) /= 0) then
          I101O11O := '1';
        end if;
      end if;
    end if;

    OO000O0O := lOOOII1l(rnd, lO011100, I11IO1I1(1), I11IO1I1(0), I101O11O);

    if (OIIlOlO1) then
      I0OI1lO0 := lO001Ol0;
    elsif (OO000O0O(rnd_inc) = '1') then
      I0OI1lO0 := lO001Ol0 + 1;
    else
      I0OI1lO0 := lO001Ol0;
    end if;

    if (OIIlOlO1) then
      l000I1O0 := OOIl0010 < IOOl0lII;
    else
      l000I1O0 := FALSE;
    end if;

    if ((l10OO10O >= ((((2 ** (exp_width-1)) - 1) * 2) + 1)) and (l10OO10O((exp_width + bit_width(sig_width) + 2) - 1) = '0')) then
      O00OO1I0(4) := '1';
      O00OO1I0(5) := '1';
  
      if (OO000O0O(rnd_hugeinfinity) = '1') then
        l11Illl0 := IIl1O10O(sig_width downto 0);
        IO10IOO1 := conv_std_logic_vector(((((2 ** (exp_width-1)) - 1) * 2) + 1), IO10IOO1'length);
        O00OO1I0(1) := '1';
      else
        l11Illl0 := (others => '1');
        IO10IOO1 := conv_std_logic_vector(((((2 ** (exp_width-1)) - 1) * 2) + 1) - 1, IO10IOO1'length);
      end if;

    elsif ((l10OO10O <= 0) or (l10OO10O((exp_width + bit_width(sig_width) + 2) - 1) = '1')) then
      O00OO1I0(3) := '1';

      if (ieee_compliance = 0) then
        O00OO1I0(5) := '1';
      
        if ((l000I1O0 = FALSE) and ((l10OO10O = conv_std_logic_vector(0, l10OO10O'length)) and (lO001Ol0 = IO11OO01)) and 
            ((rnd = B"000") or (rnd = B"101") or (rnd = B"110") or ((rnd = B"010") and (lO011100 = '0')) or ((rnd = B"011") and (lO011100 = '1')))) then
          l11Illl0 := (others => '0');
          IO10IOO1 := conv_std_logic_vector(1, IO10IOO1'length);
        else
          if (OO000O0O(rnd_tinyminnorm) = '1') then
            l11Illl0 := (others => '0');
            IO10IOO1 := conv_std_logic_vector(0 + 1, IO10IOO1'length);
          else
            l11Illl0 := (others => '0');
            IO10IOO1 := conv_std_logic_vector(0, IO10IOO1'length);
            O00OO1I0(0) := '1';
          end if;
        end if;
      else
        l11Illl0 := I0OI1lO0;
        IO10IOO1 := conv_std_logic_vector(conv_integer(I0OI1lO0(sig_width)), IO10IOO1'length);
      end if;
    else 
     if ((OIIlOlO1) and (Ol01O010 = '1')) then
       l11Illl0 := (others => '0');
     else
       l11Illl0 := I0OI1lO0;
     end if;

      IO10IOO1 := l10OO10O(exp_width + 1 downto 0);
    end if;

    if ((l11Illl0(sig_width - 1 downto 0) = 0) and (IO10IOO1(exp_width - 1 downto 0) = 0)) then
      O00OO1I0(0) := '1';
    end if;

    O00OO1I0(5) := O00OO1I0(5) or OO000O0O(rnd_inexact);

    l1l1O100 := lO011100 & IO10IOO1(exp_width - 1 downto 0) & l11Illl0(sig_width - 1 downto 0);

  end if;


  if (Is_X(a) or Is_X(b) or Is_X(rnd)) then
  
    status <= (others => 'X');
    z <= (others => 'X');
  
  else

    status <= O00OO1I0;
    z <= l1l1O100;

  end if;


  end process II0l1001;

  -- pragma translate_on

end sim;

--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_fp_div_cfg_sim of DW_fp_div is
 for sim
 end for; -- sim
end DW_fp_div_cfg_sim;
-- pragma translate_on

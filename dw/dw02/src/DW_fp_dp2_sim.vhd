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
-- AUTHOR:    Alexandre F. Tenca, September 2006
--
-- VERSION:   VHDL Simulation Model - DW_fp_dp2
--
-- DesignWare_version: 1488d326
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--
-- ABSTRACT: Floating-point two-term Dot-product
--           Computes the sum of products of FP numbers. For this component,
--           two products are considered. Given the FP inputs a, b, c, and d,
--           it computes the FP output z = a*b + c*d. 
--           The format of the FP numbers is defined by the number of bits 
--           in the significand (sig_width) and the number of bits in the 
--           exponent (exp_width).
--           The total number of bits in the FP number is sig_width+exp_width+1
--           since the sign bit takes the place of MS bits in the significand
--           which is always 1 (unless the number is a denormal; a condition 
--           that can be detected testing the exponent value).
--           The output is a FP number and status flags with information about
--           special number representations and exceptions. Rounding mode may 
--           also be defined by an input port.
--              parameters      valid values (defined in the DW manual)
--              ==========      ============
--              sig_width       significand size,  2 to 253 bits
--              exp_width       exponent size,     3 to 31 bits
--              ieee_compliance 0 or 1 (default 0)
--              arch_type       0 or 1 (default 0)
--
--              Input ports     Size & Description
--              ===========     ==================
--              a               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Input
--              b               (sig_width + exp_width) + 1-bits
--                              Floating-point Number Input
--              c               (sig_width + exp_width) + 1-bits
--                              Floating-point Number Input
--              d               (sig_width + exp_width) + 1-bits
--                              Floating-point Number Input
--              rnd             3 bits
--                              rounding mode
--
--              Output ports    Size & Description
--              ===========     ==================
--              z               (sig_width + exp_width + 1) bits
--                              Floating-point Number result that corresponds
--                              to a*b+c*d
--              status          byte
--                              info about FP results
--
-- MODIFIED:
--         10/4/06 - includes rounding for denormal values
--         05/1/07 - Fix the manipulation of sign of zero
--         03/2008 - AFT - included parameter arch_type to control the use
--                   of internal floating-point format blocks.
--
--         01/2009 - AFT - fix the cases when tiny=1 and MinNorm=1 for some
--                   combination of the inputs and rounding modes.
--
--         12/2008 - Fixed tiny bit for the case of sub-norm before rounding
--         12/2008 - Allowed the use of denormals when arch_type = 1.
--         09/2012 - AFT - Bug was causing 1 ulp error for some configurations,
--                   such as (51,3,0,0), (51,3,1,0), (52,11,0,0), etc. The last
--                   one is a double-precision FP format. The problem is caused
--                   by the use of the power operator, which has a limitation
--                   on the value of the exponent (it cannot be larger than 31)
--                   For this reason, rounding is not properly done. The fix 
--                   consists in using the concatenation operator with 
--                   appropriate bit vectors.
--         04/2013 - AFT - Fixed status bit mismatches for huge and tiny.
--         02/2018 - AFT - Star 9001298582 - in some cases, Huge status bit 
--                   is not being set when the output is forced to +/-MaxNorm
--                   during an exception handling of internal overflow.
-- 
---------------------------------------------------------------------------------

library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_misc.all;
use DWARE.DW_Foundation_comp_arith.all;

architecture sim of DW_fp_dp2 is
	

-- pragma translate_off


-- OO0Ol01O function used in several FP components
function OO0Ol01O (IlIO100I: std_logic_vector(2 downto 0);
                   ll000OIO: std_logic;
                   OI0l1I0O: std_logic;
                   I11O1O10: std_logic;
                   Ol101l00: std_logic) return std_logic_vector is
--*******************************
--  I1OOII00 has 4 bits:
--  I1OOII00[0]
--  I1OOII00[1]
--  I1OOII00[2]
--  I1OOII00[3]
--*******************************

--*******************************
--  Rounding increment equations
--  |
--    MODE | Equation   | Description
--    -----------------------------
--    even | I11O1O10&(OI0l1I0O|Ol101l00)  | IEEE round to nearest (even)
--    zero | 0          | IEEE round to zero
--    +inf | S'&(I11O1O10|Ol101l00) | IEEE round to positive infinity
--    -inf | S&(I11O1O10|Ol101l00)  | IEEE round to negative infinity
--     up  | I11O1O10          | round to nearest (up)
--    away | (I11O1O10|Ol101l00)    | round away from zero
-- *******************************
variable OO0Ol01O : std_logic_vector (4-1 downto 0);
begin
  OO0Ol01O(0) := '0';
  OO0Ol01O(1) := I11O1O10 or Ol101l00;
  OO0Ol01O(2) := '0';
  OO0Ol01O(3) := '0';
  case IlIO100I is
    when "000" =>
      -- round to nearest (even) 
      OO0Ol01O(0) := I11O1O10 and (OI0l1I0O or Ol101l00);
      OO0Ol01O(2) := '1';
      OO0Ol01O(3) := '0';
    when "001" =>
      -- round to zero 
      OO0Ol01O(0) := '0';
      OO0Ol01O(2) := '0';
      OO0Ol01O(3) := '0';
    when "010" =>
      -- round to positive infinity 
      OO0Ol01O(0) := not ll000OIO and (I11O1O10 or Ol101l00);
      OO0Ol01O(2) := not ll000OIO;
      OO0Ol01O(3) := not ll000OIO;
    when "011" =>
      -- round to negative infinity 
      OO0Ol01O(0) := ll000OIO and (I11O1O10 or Ol101l00);
      OO0Ol01O(2) := ll000OIO;
      OO0Ol01O(3) := ll000OIO;
    when "100" =>
      -- round to nearest (up)
      OO0Ol01O(0) := I11O1O10;
      OO0Ol01O(2) := '1';
      OO0Ol01O(3) := '0';
    when "101" =>
      -- round away form 0  
      OO0Ol01O(0) := I11O1O10 or Ol101l00;
      OO0Ol01O(2) := '1';
      OO0Ol01O(3) := '1';
    when others =>
      OO0Ol01O(0) := 'X';
      OO0Ol01O(2) := 'X';
      OO0Ol01O(3) := 'X';
  end case;
  return (OO0Ol01O);
end function;                                    -- I1OOII00 function


signal status_int1, O00ll1lO : std_logic_vector(8    -1 downto 0);
signal z_temp1, O1Il1000 : std_logic_vector((exp_width + sig_width) downto 0);

-- Other signals used for simulation of the architecture when arch_type = 1

signal I0O0OIO1 : std_logic_vector(sig_width+2+exp_width+6 downto 0); -- inputs
signal OIlI1OOI : std_logic_vector(sig_width+2+exp_width+6 downto 0);
signal lIO1I1lO : std_logic_vector(sig_width+2+exp_width+6 downto 0);
signal l1O10O11 : std_logic_vector(sig_width+2+exp_width+6 downto 0); 
signal l1I0O0OO : std_logic_vector((sig_width+2+6)+exp_width+1+6 downto 0); 
signal IO0OOOIO : std_logic_vector((sig_width+2+6)+exp_width+1+6 downto 0); 
signal I1Ol10O0 : std_logic_vector((sig_width+2+6)+1+exp_width+1+1+6 downto 0); -- a*b

-- pragma translate_on
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
    
    if ( (arch_type < 0) OR (arch_type > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter arch_type (legal range: 0 to 1)"
        severity warning;
    end if;
    
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;

-----------------------------------------------------------------------
-- Simulation model of the FP DP2 for the case arch_type = 1
-----------------------------------------------------------------------

-- Instances of DW_fp_ifp_conv  -- format converters
  U1: DW_fp_ifp_conv generic map (sig_widthi => sig_width, 
                                  exp_widthi => exp_width, 
                                  sig_widtho => sig_width+2,
                                  exp_widtho => exp_width,
                                  use_denormal => ieee_compliance,
                                  use_1scmpl => 0)
          port map ( a => a, z => I0O0OIO1 );
  U2: DW_fp_ifp_conv generic map (sig_widthi => sig_width, 
                                  exp_widthi => exp_width, 
                                  sig_widtho => sig_width+2,
                                  exp_widtho => exp_width,
                                  use_denormal => ieee_compliance,
                                  use_1scmpl => 0)
          port map ( a => b, z => OIlI1OOI );
  U3: DW_fp_ifp_conv generic map (sig_widthi => sig_width, 
                                  exp_widthi => exp_width, 
                                  sig_widtho => sig_width+2,
                                  exp_widtho => exp_width,
                                  use_denormal => ieee_compliance,
                                  use_1scmpl => 0)
          port map ( a => c, z => lIO1I1lO );
  U4: DW_fp_ifp_conv generic map (sig_widthi => sig_width, 
                                  exp_widthi => exp_width, 
                                  sig_widtho => sig_width+2,
                                  exp_widtho => exp_width,
                                  use_denormal => ieee_compliance,
                                  use_1scmpl => 0)
          port map ( a => d, z => l1O10O11 );
-- Instances of DW_ifp_mult
  U5: DW_ifp_mult generic map (  sig_widthi => sig_width+2,
                                 exp_widthi => exp_width,
                                 sig_widtho => (sig_width+2+6),
                                 exp_widtho => exp_width+1)
          port map ( a => I0O0OIO1, b => OIlI1OOI, z => l1I0O0OO);
  U6: DW_ifp_mult generic map (  sig_widthi => sig_width+2,
                                 exp_widthi => exp_width,
                                 sig_widtho => (sig_width+2+6),
                                 exp_widtho => exp_width+1)
          port map ( a => lIO1I1lO, b => l1O10O11, z => IO0OOOIO);
-- Instance of DW_ifp_addsub
  U7: DW_ifp_addsub generic map (sig_widthi => (sig_width+2+6),
                                 exp_widthi => exp_width+1,
                                 sig_widtho => (sig_width+2+6)+1,
                                 exp_widtho => exp_width+1+1,
                                 use_denormal => ieee_compliance,
                                 use_1scmpl => 0)
          port map ( a => l1I0O0OO, b => IO0OOOIO, rnd => rnd, op => '0', z => I1Ol10O0);
-- Instance of DW_ifp_fp_conv  -- format converter
  U8: DW_ifp_fp_conv generic map (sig_widthi => (sig_width+2+6)+1,
                                  exp_widthi => exp_width+1+1,
                                  sig_width  => sig_width,
                                  exp_width  => exp_width,
                                  use_denormal => ieee_compliance)
          port map ( a => I1Ol10O0, rnd => rnd, z => z_temp1, status => status_int1 );


-----------------------------------------------------------------------
-- purpose: main process for the behavioral description of the FP DP2
-- when arch_type = 0
-----------------------------------------------------------------------
-- type   : combinational
-- inputs : a, b, c, d, rnd
-- outputs: O00ll1lO and O1Il1000
MAIN_PROCESS: process (a, b, c, d, rnd)

variable lOOO0IO1 : std_logic_vector(8    -1 downto 0);
variable OOOlO11O : std_logic_vector((exp_width + sig_width) downto 0);
variable I010l1OO, I0IOlI0I, l10OO111, IO1lI10l : std_logic;
variable O101O0IO,llOOO1OO,OII10I11,O0ll10O0 :  std_logic_vector(exp_width-1 downto 0); -- Exponents.
variable I1OOO001,l000OOOl,ll01l00O,lll00O1O : std_logic_vector(sig_width-1 downto 0);  -- fraction bits
variable l11O000O,I1111l1l,l0l0O01l,O1111I11 : std_logic_vector(sig_width downto 0);    -- mantissa bits
variable lO100lO1,O0100000,OOlI1O01,IO001011 : std_logic;  -- sign bits
variable OlO11100,lOIO1l0l,O0I1OlI0,I0I0O1Ol : std_logic;  
variable l0l011O1,I1011O01,O01llI11,IO100O11 : std_logic;  
variable O110Ol1O, ll01Ol11 : std_logic_vector(2*sig_width+1 downto 0); -- internal products
variable O1OIO01l, ll1lIIl1 : std_logic_vector((2*sig_width+2+2) downto 0);
variable lOIO11O0, Ol1OOI0O :  std_logic_vector(exp_width downto 0);
variable OO111IOO, llOl1O11 :  std_logic;
variable IOI1OIlO : std_logic_vector(exp_width-1 downto 0);
variable I0I1O100 : std_logic_vector(exp_width-1 downto 0);
variable O0l1101I : std_logic_vector(sig_width-1 downto 0);
variable I01O11OO : std_logic_vector(sig_width downto 0);
variable OI11lOIl : std_logic_vector(exp_width-1 downto 0);
-- The biggest possible exponent for addition/subtraction
variable I1lOOO10 : std_logic_vector(exp_width+1 downto 0);
variable Ol0O1l10,lI111l0O,l101011O :  std_logic_vector(exp_width downto 0);
variable IOl11I1I,O0I0l01l :  std_logic_vector((2*sig_width+2+2) downto 0); -- Mantissa vectors
variable l1OllIl0,IIII1OOO :  std_logic;
variable l1OO0O0I :  std_logic_vector((2*sig_width+2+2) downto 0); 
variable O00011OI :  std_logic_vector((2*sig_width+2+2) downto 0); -- internal adder output
variable IO1Ol100 :  std_logic_vector((2*sig_width+2+2) downto 0); -- Mantissa vector - internal
variable I01l010O : std_logic_vector((2*sig_width+2+2) downto 0);
 -- Contains values returned by OO0Ol01O function.
variable I1OOII00 : std_logic_vector(4-1 downto 0);
-- special FP values
variable O111OlO1 : std_logic_vector((exp_width + sig_width + 1)-1 downto 0);  -- Not-a-number
variable OlIO1OI0 : std_logic_vector((exp_width + sig_width + 1)-1 downto 0); -- plus infinity
variable O1OI0O1I : std_logic_vector((exp_width + sig_width + 1)-1 downto 0);  -- negative infinity
variable II1O1l1I, lO100IlO : std_logic;
variable O100II10, O1lIO10O : std_logic;
-- indication of denormals for Large or Small value
--variable Denormal_Large : std_logic;
--variable Denormal_Small : std_logic;
variable l0l101O0, II10IIO0, IO1lIO11, l00OO001 : std_logic;
variable Ol100OO0 : std_logic_vector((2*sig_width+2+2) downto (2*sig_width+2-sig_width-2+2));
variable possible_tiny : std_logic;

begin  -- process MAIN_PROCESS

  Ol100OO0 := (others => '0');
  O0l1101I := (others => '0');
  IOI1OIlO := (others => '0');
  I01O11OO := (others => '0');
  I01l010O := (others => '0');

  -- setup some of special variables...
  OI11lOIl := conv_std_logic_vector(((((2 ** (exp_width-1)) - 1) * 2) + 1), OI11lOIl'length);
  I0I1O100 := IOI1OIlO + 1;
  O111OlO1 := '0' & OI11lOIl & O0l1101I;
  -- mantissa of NaN  is 1 when ieee_compliance = 1
  if (ieee_compliance = 1) then 
    O111OlO1(0) := '1';  
  end if;
  OlIO1OI0 := '0' & OI11lOIl & O0l1101I;
  O1OI0O1I := '1' & OI11lOIl & O0l1101I;
  lOOO0IO1 := (others => '0');

  -- extract exponent and significand from inputs
  O101O0IO := a(((exp_width + sig_width) - 1) downto sig_width);
  llOOO1OO := b(((exp_width + sig_width) - 1) downto sig_width);
  OII10I11 := c(((exp_width + sig_width) - 1) downto sig_width);
  O0ll10O0 := d(((exp_width + sig_width) - 1) downto sig_width);
  I1OOO001 := a((sig_width - 1) downto 0);
  l000OOOl := b((sig_width - 1) downto 0);
  ll01l00O := c((sig_width - 1) downto 0);
  lll00O1O := d((sig_width - 1) downto 0);
  lO100lO1 := a((exp_width + sig_width));
  O0100000 := b((exp_width + sig_width));
  OOlI1O01 := c((exp_width + sig_width));
  IO001011 := d((exp_width + sig_width));
  I0IOlI0I := (lO100lO1 xor O0100000) xor (OOlI1O01 xor IO001011);
    
  -- build mantissas
  -- Detect the denormal input case
  if ((O101O0IO = IOI1OIlO) and (I1OOO001 /= O0l1101I) and (ieee_compliance = 1)) then
    -- Mantissa of denormal value
    l11O000O := '0' & I1OOO001;
    l0l101O0 := '1';
    O101O0IO(0) := '1';                -- set exponent of denormal to minimum
  else
    -- Mantissa for normal number
    if (O101O0IO = IOI1OIlO) then
      l11O000O := I01O11OO;
    else
      l11O000O := '1' & I1OOO001;
    end if;
    l0l101O0 := '0';      
  end if;
  if ((llOOO1OO = IOI1OIlO) and (l000OOOl /= O0l1101I) and (ieee_compliance = 1)) then
    -- Mantissa of denormal value
    I1111l1l := '0' & l000OOOl;
    II10IIO0 := '1';
    llOOO1OO(0) := '1';
  else
    -- Mantissa for normal number
    if (llOOO1OO = IOI1OIlO) then
      I1111l1l := I01O11OO;
    else
      I1111l1l := '1' & l000OOOl;
    end if;
    II10IIO0 := '0';      
  end if;
  if ((OII10I11 = IOI1OIlO) and (ll01l00O /= O0l1101I) and (ieee_compliance = 1)) then
    -- Mantissa of denormal value
    l0l0O01l := '0' & ll01l00O;
    IO1lIO11 := '1';
    OII10I11(0) := '1';
  else
    -- Mantissa for normal number
    if (OII10I11 = IOI1OIlO) then
      l0l0O01l := I01O11OO;
    else
      l0l0O01l := '1' & ll01l00O;
    end if;
    IO1lIO11 := '0';      
  end if;
  if ((O0ll10O0 = IOI1OIlO) and (lll00O1O /= O0l1101I) and (ieee_compliance = 1)) then
    -- Mantissa of denormal value
    O1111I11 := '0' & lll00O1O;
    l00OO001 := '1';
    O0ll10O0(0) := '1';
  else
    -- Mantissa for normal number
    if (O0ll10O0 = IOI1OIlO) then
      O1111I11 := I01O11OO;
    else
      O1111I11 := '1' & lll00O1O;
    end if;
    l00OO001 := '0';      
  end if;
  if ((O101O0IO = IOI1OIlO) and ((I1OOO001 = O0l1101I) or (ieee_compliance = 0))) then
    OlO11100 := '1';
  else
    OlO11100 := '0';
  end if;
  if ((llOOO1OO = IOI1OIlO) and ((l000OOOl = O0l1101I) or (ieee_compliance = 0))) then
    lOIO1l0l := '1';
  else
    lOIO1l0l := '0';
  end if;
  if ((OII10I11 = IOI1OIlO) and ((ll01l00O = O0l1101I) or (ieee_compliance = 0))) then
    O0I1OlI0 := '1';
  else
    O0I1OlI0 := '0';
  end if;
  if ((O0ll10O0 = IOI1OIlO) and ((lll00O1O = O0l1101I) or (ieee_compliance = 0))) then
    I0I0O1Ol := '1';
  else
    I0I0O1Ol := '0';
  end if;
  if ((O101O0IO = OI11lOIl) and ((I1OOO001 = O0l1101I) or (ieee_compliance = 0))) then
    l0l011O1 := '1';
  else
    l0l011O1 := '0';
  end if;
  if ((llOOO1OO = OI11lOIl) and ((l000OOOl = O0l1101I) or (ieee_compliance = 0))) then
    I1011O01 := '1';
  else
    I1011O01 := '0';
  end if;
  if ((OII10I11 = OI11lOIl) and ((ll01l00O = O0l1101I) or (ieee_compliance = 0))) then
    O01llI11 := '1';
  else
    O01llI11 := '0';
  end if;
  if ((O0ll10O0 = OI11lOIl) and ((lll00O1O = O0l1101I) or (ieee_compliance = 0))) then
    IO100O11 := '1';
  else
    IO100O11 := '0';
  end if;

  -- calculate the internal exponents
  if (O101O0IO = 0 or llOOO1OO = 0) then
    lOIO11O0 := (others => '0');
  else
    lOIO11O0 := ("0"&O101O0IO) + ("0"&llOOO1OO);
  end if;
  if (OII10I11 = 0 or O0ll10O0 = 0) then
    Ol1OOI0O := (others => '0');
  else
    Ol1OOI0O := ("0"&OII10I11) + ("0"&O0ll10O0);
  end if;

  -- zero products
  O100II10 := OlO11100 or lOIO1l0l;
  O1lIO10O := O0I1OlI0 or I0I0O1Ol;

  -- Identify and treat special input values
  -- NaN inputs
  -- Rule 1.
  if ((O101O0IO = OI11lOIl) and (I1OOO001 /= O0l1101I) and (ieee_compliance = 1)) then
    -- one of the inputs is a NAN       --> the output must be an NAN
    OOOlO11O := O111OlO1;
    lOOO0IO1(2) := '1';
  elsif ((llOOO1OO = OI11lOIl) and (l000OOOl /= O0l1101I) and (ieee_compliance = 1)) then
    OOOlO11O := O111OlO1;
    lOOO0IO1(2) := '1';
  elsif ((OII10I11 = OI11lOIl) and (ll01l00O /= O0l1101I) and (ieee_compliance = 1)) then
    OOOlO11O := O111OlO1;
    lOOO0IO1(2) := '1';
  elsif ((O0ll10O0 = OI11lOIl) and (lll00O1O /= O0l1101I) and (ieee_compliance = 1)) then
    OOOlO11O := O111OlO1;
    lOOO0IO1(2) := '1';
  --
  -- Infinity Inputs
  -- Rule 2.1
  elsif ((l0l011O1 = '1' and lOIO1l0l = '1') or
         (I1011O01 = '1' and OlO11100 = '1') or
         (O01llI11 = '1' and I0I0O1Ol = '1') or
         (IO100O11 = '1' and O0I1OlI0 = '1') ) then
    OOOlO11O := O111OlO1;
    lOOO0IO1(2) := '1';
      if (ieee_compliance = 0) then
        lOOO0IO1(1) := '1';
      end if;

  -- 
  --  Zero inputs
  elsif (O100II10 = '1' and O1lIO10O = '1') then
    OO111IOO := (lO100lO1 xor O0100000);
    llOl1O11 := (OOlI1O01 xor IO001011);
    OOOlO11O := (others => '0');
    if (OO111IOO = llOl1O11) then
      OOOlO11O((exp_width + sig_width)) := OO111IOO;
    elsif (rnd = "011") then
      OOOlO11O((exp_width + sig_width)) := '1';
    else
      OOOlO11O((exp_width + sig_width)) := '0';
    end if;
    lOOO0IO1(0) := '1';

  --
  -- Normal Inputs
  --
  else                                          
    -- generate the product terms
    O110Ol1O := (l11O000O * I1111l1l);
    ll01Ol11 := (l0l0O01l * O1111I11);
    O1OIO01l := '0'&O110Ol1O&"00";
    ll1lIIl1 := '0'&ll01Ol11&"00";

    -- sign of the internal product
    OO111IOO := (lO100lO1 xor O0100000);
    llOl1O11 := (OOlI1O01 xor IO001011);
    
    II1O1l1I := '0';
    lO100IlO := '0';
    if ((l0l011O1 = '1') or (I1011O01 = '1')) then
      II1O1l1I := '1';
    end if;
    if ((O01llI11 = '1') or (IO100O11 = '1')) then
      lO100IlO := '1';
    end if;
    if (II1O1l1I = '1' or lO100IlO = '1')  then
      lOOO0IO1(1) := '1';
      lOOO0IO1(4) := not (l0l011O1 or I1011O01 or O01llI11 or IO100O11);
      lOOO0IO1(5) := not (l0l011O1 or I1011O01 or O01llI11 or IO100O11);
      OOOlO11O := OlIO1OI0;
      if (II1O1l1I = '1') then
        OOOlO11O((exp_width + sig_width)) := OO111IOO;
      else
        OOOlO11O((exp_width + sig_width)) := llOl1O11;
      end if;
      -- Watch out for Inf-Inf !
      if ( (II1O1l1I = '1') and (lO100IlO = '1') and (I0IOlI0I = '1') ) then
        lOOO0IO1(2) := '1';
        lOOO0IO1(4) := '0';
        lOOO0IO1(5) := '0';
        OOOlO11O := O111OlO1;                  -- NaN
        if (ieee_compliance = 1) then
          lOOO0IO1(1) := '0';
        end if;
      end if;
    else
      while ( (O1OIO01l((2*sig_width+2+2)-1) = '0') and (lOIO11O0 /= 0) ) loop
        lOIO11O0 := lOIO11O0 - 1;
        O1OIO01l := O1OIO01l(O1OIO01l'length-2 downto 0) & '0';
      end loop;
      while ( (ll1lIIl1((2*sig_width+2+2)-1) = '0') and (Ol1OOI0O /= 0) ) loop
        Ol1OOI0O := Ol1OOI0O - 1;
        ll1lIIl1 := ll1lIIl1(O1OIO01l'length-2 downto 0) & '0';
      end loop;

      -- compute the signal that defines the large and small FP value
      I010l1OO := '0';
      if ((lOIO11O0&O1OIO01l) < (Ol1OOI0O&ll1lIIl1)) then
        I010l1OO := '1';
      end if;
      if (I010l1OO = '1') then
        Ol0O1l10 := Ol1OOI0O;
        IOl11I1I := ll1lIIl1;
        l1OllIl0 := llOl1O11;
        lI111l0O := lOIO11O0;
        O0I0l01l := O1OIO01l;
        IIII1OOO := OO111IOO;
      else
        Ol0O1l10 := lOIO11O0;
        IOl11I1I := O1OIO01l;
        l1OllIl0 := OO111IOO;
        lI111l0O := Ol1OOI0O;
        O0I0l01l := ll1lIIl1;
        IIII1OOO := llOl1O11;
     end if;

      -- Shift right by l101011O the Small number: O0I0l01l.
      l10OO111 := '0';
      l101011O := Ol0O1l10 - lI111l0O;
      l1OO0O0I := O0I0l01l;
      while ( (l1OO0O0I /= I01l010O) and (l101011O /= IOI1OIlO) ) loop
        l10OO111 := l1OO0O0I(0) or l10OO111;
        l1OO0O0I := '0' & l1OO0O0I(l1OO0O0I'length-1 downto 1);
        l101011O := l101011O - 1;
      end loop;
      l1OO0O0I(0) := l1OO0O0I(0) or l10OO111;
  
      -- Compute internal addition result: a +/- b
      if (I0IOlI0I = '0') then
        O00011OI := IOl11I1I + l1OO0O0I;
      else
        O00011OI := IOl11I1I - l1OO0O0I;
      end if;
      
      IO1Ol100 := O00011OI;

      -- Processing after addition
      I1lOOO10 := '0' & Ol0O1l10;

      --
      -- Normal case after the computation.
      --
        -- Normalize the Mantissa for computation overflow case.
        IO1lI10l := '0';
        if (IO1Ol100((2*sig_width+2+2)) = '1') then
          I1lOOO10 := I1lOOO10 + 1;
          IO1lI10l := IO1Ol100(0);
          IO1Ol100 := '0' & IO1Ol100(IO1Ol100'length-1 downto 1);
          IO1Ol100(0) := IO1Ol100(0) or IO1lI10l;
        end if;
        if (IO1Ol100((2*sig_width+2+2)-1) = '1') then
          I1lOOO10 := I1lOOO10 + 1;
          IO1lI10l := IO1Ol100(0);
          IO1Ol100 := '0' & IO1Ol100(IO1Ol100'length-1 downto 1);
          IO1Ol100(0) := IO1Ol100(0) or IO1lI10l;
        end if;

        -- Normalize the Mantissa for leading zero case.
        while ( (IO1Ol100((2*sig_width+2+2)-2) = '0') and (I1lOOO10 > ((2 ** (exp_width-1)) - 1)) ) loop
          I1lOOO10 := I1lOOO10 - 1;
          IO1Ol100 := IO1Ol100(IO1Ol100'length-2 downto 0) & '0';
        end loop;

        while ( IO1Ol100 /= I01l010O and (I1lOOO10 <= ((2 ** (exp_width-1)) - 1)) ) loop
          I1lOOO10 := I1lOOO10 + 1;
          IO1lI10l := IO1Ol100(0) or IO1lI10l;
          IO1Ol100 := '0' & IO1Ol100(IO1Ol100'length-1 downto 1);
        end loop;

        -- Round IO1Ol100 according to the rounding mode (rnd).
          I1OOII00 := OO0Ol01O(rnd, l1OllIl0, IO1Ol100((2*sig_width+2-sig_width-2+2)), IO1Ol100(((2*sig_width+2-sig_width-2+2) - 1)),
                      (or_reduce(IO1Ol100(((2*sig_width+2-sig_width-2+2) - 1)-1 downto 0)) or l10OO111 or IO1lI10l));

          if (I1OOII00(0) = '1') then
            IO1Ol100 := IO1Ol100 + ('1' & conv_std_logic_vector(0,(2*sig_width+2-sig_width-2+2)));
            lOOO0IO1(5) := '0';
          end if;   

          -- Normalize the Mantissa for overflow case after rounding.
          if ( (IO1Ol100((2*sig_width+2+2)-1) = '1') ) then
            I1lOOO10 := I1lOOO10 + 1;
            IO1Ol100 := '0' & IO1Ol100(IO1Ol100'length-1 downto 1);
          end if;
        
        -- test if the output of the rounding unit is still not normalized
        if ((IO1Ol100((2*sig_width+2+2) downto (2*sig_width+2+2)-2) = "000") or (I1lOOO10 <= ((2 ** (exp_width-1)) - 1))) then
          -- result is tiny or zero
          if (ieee_compliance = 1) then
            OOOlO11O := l1OllIl0 & IOI1OIlO & IO1Ol100((2*sig_width+2+2)-3 downto (2*sig_width+2-sig_width-2+2));
            lOOO0IO1(5) := I1OOII00(1);
            lOOO0IO1(3) := I1OOII00(1) or 
                                           or_reduce(IO1Ol100((2*sig_width+2+2) downto (2*sig_width+2-sig_width-2+2)));
            if (IO1Ol100((2*sig_width+2+2)-3 downto (2*sig_width+2-sig_width-2+2)) = O0l1101I) then
              lOOO0IO1(0) := '1';
              if (I1OOII00(1) = '0') then
                -- result is an exact zero
                if (rnd = "011") then
                  OOOlO11O((exp_width + sig_width)) := '1';         
                else
                  OOOlO11O((exp_width + sig_width)) := '0';
                end if;
              end if;
            end if;
          else
            -- when denormals are not used  -> the output becomes zero or minnorm
            lOOO0IO1(5) := I1OOII00(1) or 
                                           or_reduce(IO1Ol100((2*sig_width+2+2) downto (2*sig_width+2-sig_width-2+2)));
            if (((rnd = "011" and l1OllIl0 = '1') or
                 (rnd = "010" and l1OllIl0 = '0') or
                 rnd = "101") and (IO1Ol100((2*sig_width+2+2) downto (2*sig_width+2-sig_width-2+2)) /= Ol100OO0)) then
              -- Minnorm
              OOOlO11O := l1OllIl0 & I0I1O100 & O0l1101I;
              lOOO0IO1(0) := '0';
              lOOO0IO1(3) := '0';
            else
              -- zero
              lOOO0IO1(3) := I1OOII00(1) or 
                                          or_reduce(IO1Ol100((2*sig_width+2+2) downto (2*sig_width+2-sig_width-2+2)));
              lOOO0IO1(0) := '1';
              lOOO0IO1(3) := lOOO0IO1(5);
              if (lOOO0IO1(5) = '1') then
                OOOlO11O := l1OllIl0 & IOI1OIlO & O0l1101I;
              else
                OOOlO11O := (others => '0');
                if (rnd = "011") then
                  OOOlO11O((exp_width + sig_width)) := '1';         
                else
                  OOOlO11O((exp_width + sig_width)) := '0';
                end if;
              end if;
            end if;
          end if;
        else
          --
          -- Huge
          --
          if (I1lOOO10 >= conv_std_logic_vector(((((2 ** (exp_width-1)) - 1) * 2) + 1)+((2 ** (exp_width-1)) - 1),I1lOOO10'length)) then
            lOOO0IO1(5) := '1';
            if (I1OOII00(2) = '1') then
              -- Infinity
              IO1Ol100((2*sig_width+2+2)-3 downto (2*sig_width+2-sig_width-2+2)) := (others => '0');
              I1lOOO10 := conv_std_logic_vector(((((2 ** (exp_width-1)) - 1) * 2) + 1),I1lOOO10'length);
              lOOO0IO1(1) := '1';
              lOOO0IO1(4) := '1';
            else
              -- MaxNorm
              I1lOOO10 := conv_std_logic_vector(((((2 ** (exp_width-1)) - 1) * 2) + 1),I1lOOO10'length) - 1;
              IO1Ol100((2*sig_width+2+2)-3 downto (2*sig_width+2-sig_width-2+2)) := (others => '1');
             lOOO0IO1(4) := '1';
            end if;
          else
              I1lOOO10 := I1lOOO10 - ((2 ** (exp_width-1)) - 1);
          end if;
          --
          -- Normal
          --
          lOOO0IO1(5) := lOOO0IO1(5) or 
                                         I1OOII00(1);
          -- Reconstruct the floating point format.
          OOOlO11O := l1OllIl0 & I1lOOO10(exp_width-1 downto 0) & IO1Ol100((2*sig_width+2+2)-3 downto (2*sig_width+2-sig_width-2+2));
  
        end if;  -- (IO1Ol100((2*sig_width+2+2) downto (2*sig_width+2+2)-2) = "000")
      end if;
  end if;  -- NaN input 

  O00ll1lO <= lOOO0IO1;
  O1Il1000 <= OOOlO11O;

end process MAIN_PROCESS;

--
-- purpose: process the output values
-- type   : combinational
-- inputs : a,b,c,rnd,z_temp1,O1Il1000,status_int1,O00ll1lO
-- outputs: status and OOOlO11O
SELECT_OUTPUT: process (a, b, c, d, rnd, z_temp1, O1Il1000, status_int1, 
                        O00ll1lO)
begin
  if (Is_X(a) or Is_X(b) or Is_X(c) or Is_X(d) or Is_X(rnd)) then
    status <= (others => 'X');
    z <= (others => 'X');
  else
    if (arch_type = 1) then
      status <= status_int1;
      z <= z_temp1;
    else
      status <= O00ll1lO;
      z <= O1Il1000;
    end if;
  end if;
end process SELECT_OUTPUT;

-- pragma translate_on  

end sim ;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

library dw02;

configuration DW_fp_dp2_cfg_sim of DW_fp_dp2 is
 for sim
  for U1: DW_fp_ifp_conv use configuration dw02.DW_fp_ifp_conv_cfg_sim; end for;
  for U2: DW_fp_ifp_conv use configuration dw02.DW_fp_ifp_conv_cfg_sim; end for;
  for U3: DW_fp_ifp_conv use configuration dw02.DW_fp_ifp_conv_cfg_sim; end for;
  for U4: DW_fp_ifp_conv use configuration dw02.DW_fp_ifp_conv_cfg_sim; end for;
  for U5: DW_ifp_mult use configuration dw02.DW_ifp_mult_cfg_sim; end for;
  for U6: DW_ifp_mult use configuration dw02.DW_ifp_mult_cfg_sim; end for;
  for U7: DW_ifp_addsub use configuration dw02.DW_ifp_addsub_cfg_sim; end for;
  for U8: DW_ifp_fp_conv use configuration dw02.DW_ifp_fp_conv_cfg_sim; end for;
 end for; -- sim
end DW_fp_dp2_cfg_sim;
-- pragma translate_on

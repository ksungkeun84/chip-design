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
-- AUTHOR:    Alexandre F. Tenca, October 2006
--
-- VERSION:   VHDL Simulation Model - DW_fp_dp3
--
-- DesignWare_version: d2975190
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--
-- ABSTRACT: Floating-point Three-term Dot-product
--           Computes the sum of products of FP numbers. For this component,
--           three products are considered. Given the FP inputs a, b, c, d, e
--           and f, it computes the FP output z = a*b + c*d + e*f. 
--           The format of the FP numbers is defined by the number of bits 
--           in the significand (sig_width) and the number of bits in the 
--           exponent (exp_width).
--           The total number of bits in the FP number is sig_width+exp_width+1
--           since the sign bit takes the place of the MS bits in the significand
--           which is always 1 (unless the number is a denormal; a condition 
--           that can be detected testing the exponent value).
--           The output is a FP number and status flags with information about
--           special number representations and exceptions. Rounding mode may 
--           also be defined by an input port.
--              parameters      valid values (defined in the DW manual)
--              ==========      ============
--              sig_width       significand f,  2 to 253 bits
--              exp_width       exponent e,     3 to 31 bits
--              ieee_compliance 0 or 1  (default 0)
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
--              e               (sig_width + exp_width) + 1-bits
--                              Floating-point Number Input
--              f               (sig_width + exp_width) + 1-bits
--                              Floating-point Number Input
--              rnd             3 bits
--                              rounding mode
--
--              Output ports    Size & Description
--              ===========     ==================
--              z               (sig_width + exp_width + 1) bits
--                              Floating-point Number result that corresponds
--                              to a*b+c*d+e*f
--              status          byte
--                              info about FP results
--
-- MODIFIED:
--           11/2007 - AFT Included test of STK bit to cancel the STK bit of the
--                     smallest product when both STK bits are true.
--           11/09/07 - AFT - Includes modifications to deal with the sign of zeros
--                    according to specification regarding the addition.(A-SP1)
--           04/21/08 - AFT : fixed some cases when the infinity status bit 
--                    should be set with invalid bit (ieee_compliance = 0)
--           04/2008 - AFT - included parameter arch_type to control the use
--                     of internal floating-point format blocks.
--           1/2009 - AFT - extended the coverage of arch_type to include the
--                    case when ieee_compliance = 1
--           4/2012 - AFT - sign of zero when all the products are zero is not 
--                    properly set when ieee_compliance=0 and rnd=3
--                    Rounding operation is not performed properly when 
--                                2*_f+5 >= 32
--                    Problem was caused by using 2**x to position the 1 to be 
--                    added. This operation is limited to a value less than 32
--                    bits. The code was replaced to a more robust solution.
--           02/2017 - AFT - fixed rounding error problems found when fixing
--                    star 9001123397. The simulation model needed more 
--                    internal precision.
-- 
---------------------------------------------------------------------------------

library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_misc.all;
use DWARE.DW_Foundation_comp_arith.all;

architecture sim of DW_fp_dp3 is
	

-- pragma translate_off


-- OI101IO0 function used in several FP components
function OI101IO0 (l1OII0l0: std_logic_vector(2 downto 0);
                   Oll0O0O0: std_logic;
                   O1I1OOOl: std_logic;
                   O0000l0O: std_logic;
                   OIO1I10O: std_logic) return std_logic_vector is
--*******************************
--  IO1OIO0O has 4 bits:
--  IO1OIO0O[0]
--  IO1OIO0O[1]
--  IO1OIO0O[2]
--  IO1OIO0O[3]
--*******************************

--*******************************
--  Rounding increment equations
--  |
--    MODE | Equation   | Description
--    -----------------------------
--    even | O0000l0O&(O1I1OOOl|OIO1I10O)  | IEEE round to nearest (even)
--    zero | 0          | IEEE round to zero
--    +inf | S'&(O0000l0O|OIO1I10O) | IEEE round to positive infinity
--    -inf | S&(O0000l0O|OIO1I10O)  | IEEE round to negative infinity
--     up  | O0000l0O          | round to nearest (up)
--    away | (O0000l0O|OIO1I10O)    | round away from zero
-- *******************************
variable OI101IO0 : std_logic_vector (4-1 downto 0);
begin
  OI101IO0(0) := '0';
  OI101IO0(1) := O0000l0O or OIO1I10O;
  OI101IO0(2) := '0';
  OI101IO0(3) := '0';
  case l1OII0l0 is
    when "000" =>
      -- round to nearest (even) 
      OI101IO0(0) := O0000l0O and (O1I1OOOl or OIO1I10O);
      OI101IO0(2) := '1';
      OI101IO0(3) := '0';
    when "001" =>
      -- round to zero 
      OI101IO0(0) := '0';
      OI101IO0(2) := '0';
      OI101IO0(3) := '0';
    when "010" =>
      -- round to positive infinity 
      OI101IO0(0) := not Oll0O0O0 and (O0000l0O or OIO1I10O);
      OI101IO0(2) := not Oll0O0O0;
      OI101IO0(3) := not Oll0O0O0;
    when "011" =>
      -- round to negative infinity 
      OI101IO0(0) := Oll0O0O0 and (O0000l0O or OIO1I10O);
      OI101IO0(2) := Oll0O0O0;
      OI101IO0(3) := Oll0O0O0;
    when "100" =>
      -- round to nearest (up)
      OI101IO0(0) := O0000l0O;
      OI101IO0(2) := '1';
      OI101IO0(3) := '0';
    when "101" =>
      -- round away form 0  
      OI101IO0(0) := O0000l0O or OIO1I10O;
      OI101IO0(2) := '1';
      OI101IO0(3) := '1';
    when others =>
      OI101IO0(0) := 'X';
      OI101IO0(2) := 'X';
      OI101IO0(3) := 'X';
  end case;
  return (OI101IO0);
end function;                                    -- IO1OIO0O function


signal OlIII0lO, O0l0OO10 : std_logic_vector(8    -1 downto 0);
signal lO100001, O1l11O01 : std_logic_vector((exp_width + sig_width) downto 0);

-- Other signals used for simulation of the architecture when arch_type = 1

signal llI00I11 : std_logic_vector(sig_width+2+exp_width+6 downto 0); -- inputs
signal O0O0O01O : std_logic_vector(sig_width+2+exp_width+6 downto 0);
signal lO0lII11 : std_logic_vector(sig_width+2+exp_width+6 downto 0);
signal O01OO010 : std_logic_vector(sig_width+2+exp_width+6 downto 0); 
signal l0l01101 : std_logic_vector(sig_width+2+exp_width+6 downto 0); 
signal O100l11O : std_logic_vector(sig_width+2+exp_width+6 downto 0); 
signal II00010O : std_logic_vector(2*(sig_width+2+1)+exp_width+1+6 downto 0);-- a*b 
signal O1OO1Il0 : std_logic_vector(2*(sig_width+2+1)+exp_width+1+6 downto 0);-- c*d 
signal O11OO010 : std_logic_vector(2*(sig_width+2+1)+1+exp_width+1+1+6 downto 0);-- e*f 
signal O0OI0011 : std_logic_vector(2*(sig_width+2+1)+1+exp_width+1+1+6 downto 0);--p1+p2 
signal OO1IO1ll : std_logic_vector(2*(sig_width+2+1)+1+1+exp_width+1+1+1+6 downto 0);--p1+p2+p3

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
          port map ( a => a, z => llI00I11 );
  U2: DW_fp_ifp_conv generic map (sig_widthi => sig_width, 
                                  exp_widthi => exp_width, 
                                  sig_widtho => sig_width+2,
                                  exp_widtho => exp_width,
                                  use_denormal => ieee_compliance,
                                  use_1scmpl => 0)
          port map ( a => b, z => O0O0O01O );
  U3: DW_fp_ifp_conv generic map (sig_widthi => sig_width, 
                                  exp_widthi => exp_width, 
                                  sig_widtho => sig_width+2,
                                  exp_widtho => exp_width,
                                  use_denormal => ieee_compliance,
                                  use_1scmpl => 0)
          port map ( a => c, z => lO0lII11 );
  U4: DW_fp_ifp_conv generic map (sig_widthi => sig_width, 
                                  exp_widthi => exp_width, 
                                  sig_widtho => sig_width+2,
                                  exp_widtho => exp_width,
                                  use_denormal => ieee_compliance,
                                  use_1scmpl => 0)
          port map ( a => d, z => O01OO010 );
  U5: DW_fp_ifp_conv generic map (sig_widthi => sig_width, 
                                  exp_widthi => exp_width, 
                                  sig_widtho => sig_width+2,
                                  exp_widtho => exp_width,
                                  use_denormal => ieee_compliance,
                                  use_1scmpl => 0)
          port map ( a => e, z => l0l01101 );
  U6: DW_fp_ifp_conv generic map (sig_widthi => sig_width, 
                                  exp_widthi => exp_width, 
                                  sig_widtho => sig_width+2,
                                  exp_widtho => exp_width,
                                  use_denormal => ieee_compliance,
                                  use_1scmpl => 0)
          port map ( a => f, z => O100l11O );
-- Instances of DW_ifp_mult
  U7: DW_ifp_mult generic map (  sig_widthi => sig_width+2,
                                 exp_widthi => exp_width,
                                 sig_widtho => 2*(sig_width+2+1),
                                 exp_widtho => exp_width+1)
          port map ( a => llI00I11, b => O0O0O01O, z => II00010O);
  U8: DW_ifp_mult generic map (  sig_widthi => sig_width+2,
                                 exp_widthi => exp_width,
                                 sig_widtho => 2*(sig_width+2+1),
                                 exp_widtho => exp_width+1)
          port map ( a => lO0lII11, b => O01OO010, z => O1OO1Il0);
  U9: DW_ifp_mult generic map (  sig_widthi => sig_width+2,
                                 exp_widthi => exp_width,
                                 sig_widtho => 2*(sig_width+2+1)+1,
                                 exp_widtho => exp_width+1+1)
          port map ( a => l0l01101, b => O100l11O, z => O11OO010);
-- Instance of DW_ifp_addsub
  U10: DW_ifp_addsub generic map (sig_widthi => 2*(sig_width+2+1),
                                 exp_widthi => exp_width+1,
                                 sig_widtho => 2*(sig_width+2+1)+1,
                                 exp_widtho => exp_width+1+1,
                                 use_denormal => ieee_compliance,
                                 use_1scmpl => 0)
          port map ( a => II00010O, b => O1OO1Il0, rnd => rnd, op => '0', z => O0OI0011);
  U11: DW_ifp_addsub generic map (sig_widthi => 2*(sig_width+2+1)+1,
                                 exp_widthi => exp_width+1+1,
                                 sig_widtho => 2*(sig_width+2+1)+1+1,
                                 exp_widtho => exp_width+1+1+1,
                                 use_denormal => ieee_compliance,
                                 use_1scmpl => 0)
          port map ( a => O0OI0011, b => O11OO010, rnd => rnd, op => '0', z => OO1IO1ll);
-- Instance of DW_ifp_fp_conv  -- format converter
  U12: DW_ifp_fp_conv generic map (sig_widthi => 2*(sig_width+2+1)+1+1,
                                  exp_widthi => exp_width+1+1+1,
                                  sig_width  => sig_width,
                                  exp_width  => exp_width,
                                  use_denormal => ieee_compliance)
          port map ( a => OO1IO1ll, rnd => rnd, z => lO100001, status => OlIII0lO );


-----------------------------------------------------------------------
-- purpose: main process for the behavioral description of the FP DP2
-- when arch_type = 0
-----------------------------------------------------------------------
-- type   : combinational
-- inputs : a, b, c, d, e, f, rnd
-- outputs: O0l0OO10 and O1l11O01
MAIN_PROCESS: process (a, b, c, d, e, f, rnd)

variable OIOO0Il0 : std_logic_vector(8    -1 downto 0);
variable O1I1O1II : std_logic_vector((exp_width + sig_width) downto 0);
variable O10O0O01,I0000OlI,OIO1I10O,I1I010Ol,I10O1l00,O100O1O1,O111II00,I110l0O1 : std_logic;
 -- Exponents.
variable l11O10O1,l0IO00OO,OIl11l11,lO0IIIl1,OO1I01Il,l110001O: std_logic_vector(exp_width-1 downto 0);
 -- fractional bits
variable O111lO00,OOO110l0,OOl0lO0I,OllI0I00,OO1lI100,IO00IO1O : std_logic_vector(sig_width-1 downto 0);
-- mantissa bits
variable I10I1101,O01O0O01,I011IIO1,Ol1I1I10,IO1I0II1,IOOIOOO1 : std_logic_vector(sig_width downto 0);    
-- sign bits
variable I1lOI000,l01O0I00,IOO10O10,O11l0101,Ill0lIII,I01l0ll0 : std_logic; 
variable lII1l0O0,I01I1O10,Ol0OIl01,OOl0I01I,l1l101l1,I011O1O1 : std_logic;  
variable O000O1lI,I00OO11l,IOO0O00I,I1I00O1I,O0OO1O11,OI011II1 : std_logic;  
variable O1l100O0,Ol01000O,Ol11lO0O,OO011O10,OlO0OIO0,OOl0OI0l : std_logic;  
-- internal products
variable O01l0IIl,OII01I10,l11I110l : std_logic_vector(2*sig_width+1 downto 0); 
variable OIl1IIl0 : std_logic_vector((2*(sig_width+1)+1+(2*sig_width+5)) downto 0);
variable ll1IIOll : std_logic_vector((2*(sig_width+1)+1+(2*sig_width+5)) downto 0);
variable l101O0I1 : std_logic_vector((2*(sig_width+1)+1+(2*sig_width+5)) downto 0);
variable IO01OOO1, O1O0llI1, ll0Il11O :  std_logic;
variable OO0l1OOO,lI11OO01,l0I0lIOl : std_logic_vector(exp_width downto 0);
-- Special field values
variable l00O001O : std_logic_vector(exp_width-1 downto 0) := (others => '0');
variable O00ll0l1 : std_logic_vector(exp_width-1 downto 0) := (others => '0');
variable ll01O0II : std_logic_vector(sig_width-1 downto 0) := (others => '0');
variable OI0l001O : std_logic_vector(sig_width downto 0) := (others => '0');
variable I1OOOO01 : std_logic_vector(exp_width-1 downto 0);
variable lIl01O00 : std_logic_vector((2*(sig_width+1)+1+(2*sig_width+5)) downto ((2*(sig_width+1)+1+(2*sig_width+5))-3-sig_width));
-- The biggest possible exponent for addition/subtraction
variable Ol1O00ll : std_logic_vector(exp_width+1 downto 0);
variable ll0OO0lO,O1OOII1O :  std_logic_vector(exp_width downto 0);
-- Mantissa vectors and signs after multiplication and sorting
variable O0I10110,l00OO00O,I1O1l111 :  std_logic_vector((2*(sig_width+1)+1+(2*sig_width+5)) downto 0); 
variable OO0OlO0l :  std_logic_vector((2*(sig_width+1)+1+(2*sig_width+5)) downto 0); 
variable I1lI1IOO,OIOO1OI0,O0O000ll :  std_logic;
variable OO11IlIl :  std_logic;
variable lO10lI00,OOIO0000,l1Ol01I0 :  std_logic_vector(exp_width downto 0);
variable IOIOOlOO :  std_logic_vector(exp_width downto 0);
variable O00O00lO : std_logic_vector((2*(sig_width+1)+1+(2*sig_width+5)) downto 0); 
variable l01OIO1I : std_logic_vector((2*(sig_width+1)+1+(2*sig_width+5)) downto 0);
-- internal adder output 
variable I10000OO : std_logic;
variable lI011O0I,l0O01OII :  std_logic_vector((2*(sig_width+1)+1+(2*sig_width+5))+1 downto 0); 
variable l11101IO :  std_logic_vector((2*(sig_width+1)+1+(2*sig_width+5))+1 downto 0); 
variable O1IO111I : std_logic;
-- Mantissa vector - internal
variable l1110O1O :  std_logic_vector((2*(sig_width+1)+1+(2*sig_width+5)) downto 0); 
variable OlO11O00 : std_logic_vector((2*(sig_width+1)+1+(2*sig_width+5)) downto 0) := (others => '0');
 -- Values returned by OI101IO0 function (rounding).
variable IO1OIO0O : std_logic_vector(4-1 downto 0);
-- Special FP values
variable OO1O1lO1 : std_logic_vector((exp_width + sig_width + 1)-1 downto 0);  -- Not-a-number
variable IO001OOO : std_logic_vector((exp_width + sig_width + 1)-1 downto 0); -- plus infinity
variable O0I110O0 : std_logic_vector((exp_width + sig_width + 1)-1 downto 0);  -- negative infinity
variable O001lI00,I1I01OI1,OOO0O000 : std_logic;
variable I0l1I11l,O0O00I1I,OOO0OI11 : std_logic;
variable OOI1OI11,lIO0OlI1,l01O1OI0 : std_logic;
-- indication of denormals for Large or Small value
--variable Denormal_Large : std_logic;
--variable Denormal_Small : std_logic;
variable IO1OI101, O1I00111, I01O00O0, IOOI00O1 : std_logic;
variable l1O10O11, OO00OOl1 : std_logic;
variable IO0Il1I0 : std_logic;

begin  -- process MAIN_PROCESS

  lIl01O00 := (others => '0');
  -- setup some of special variables...
  I1OOOO01 := conv_std_logic_vector(((((2 ** (exp_width-1)) - 1) * 2) + 1), I1OOOO01'length);
  O00ll0l1 := l00O001O + 1;
  OO1O1lO1 := '0' & I1OOOO01 & ll01O0II;
  -- mantissa of NaN  is 1 when ieee_compliance = 1
  if (ieee_compliance = 1) then 
    OO1O1lO1(0) := '1';  
  end if;
  IO001OOO := '0' & I1OOOO01 & ll01O0II;
  O0I110O0 := '1' & I1OOOO01 & ll01O0II;
  OIOO0Il0 := (others => '0');

  -- extract exponent and significand from inputs
  l11O10O1 := a(((exp_width + sig_width) - 1) downto sig_width);
  l0IO00OO := b(((exp_width + sig_width) - 1) downto sig_width);
  OIl11l11 := c(((exp_width + sig_width) - 1) downto sig_width);
  lO0IIIl1 := d(((exp_width + sig_width) - 1) downto sig_width);
  OO1I01Il := e(((exp_width + sig_width) - 1) downto sig_width);
  l110001O := f(((exp_width + sig_width) - 1) downto sig_width);
  O111lO00 := a((sig_width - 1) downto 0);
  OOO110l0 := b((sig_width - 1) downto 0);
  OOl0lO0I := c((sig_width - 1) downto 0);
  OllI0I00 := d((sig_width - 1) downto 0);
  OO1lI100 := e((sig_width - 1) downto 0);
  IO00IO1O := f((sig_width - 1) downto 0);
  I1lOI000 := a((exp_width + sig_width));
  l01O0I00 := b((exp_width + sig_width));
  IOO10O10 := c((exp_width + sig_width));
  O11l0101 := d((exp_width + sig_width));
  Ill0lIII := e((exp_width + sig_width));
  I01l0ll0 := f((exp_width + sig_width));
    
  if ((l11O10O1 = l00O001O) and ((O111lO00 = ll01O0II) or (ieee_compliance = 0))) then
    lII1l0O0 := '1';
    O111lO00 := ll01O0II;
  else
    lII1l0O0 := '0';
  end if;
  if ((l0IO00OO = l00O001O) and ((OOO110l0 = ll01O0II) or (ieee_compliance = 0))) then
    I01I1O10 := '1';
    OOO110l0 := ll01O0II;
  else
    I01I1O10 := '0';
  end if;
  if ((OIl11l11 = l00O001O) and ((OOl0lO0I = ll01O0II) or (ieee_compliance = 0))) then
    Ol0OIl01 := '1';
    OOl0lO0I := ll01O0II;
  else
    Ol0OIl01 := '0';
  end if;
  if ((lO0IIIl1 = l00O001O) and ((OllI0I00 = ll01O0II) or (ieee_compliance = 0))) then
    OOl0I01I := '1';
    OllI0I00 := ll01O0II;
  else
    OOl0I01I := '0';
  end if;
  if ((OO1I01Il = l00O001O) and ((OO1lI100 = ll01O0II) or (ieee_compliance = 0))) then
    l1l101l1 := '1';
    OO1lI100 := ll01O0II;
  else
    l1l101l1 := '0';
  end if;
  if ((l110001O = l00O001O) and ((IO00IO1O = ll01O0II) or (ieee_compliance = 0))) then
    I011O1O1 := '1';
    IO00IO1O := ll01O0II;
  else
    I011O1O1 := '0';
  end if;

  -- detect infinity inputs
  if ((l11O10O1 = I1OOOO01) and ((O111lO00 = ll01O0II) or (ieee_compliance = 0))) then
    O000O1lI := '1';
    O111lO00 := ll01O0II;
  else 
    O000O1lI := '0';
  end if;
  if ((l0IO00OO = I1OOOO01) and ((OOO110l0 = ll01O0II) or (ieee_compliance = 0))) then
    I00OO11l := '1';
    OOO110l0 := ll01O0II;
  else 
    I00OO11l := '0';
  end if;
  if ((OIl11l11 = I1OOOO01) and ((OOl0lO0I = ll01O0II) or (ieee_compliance = 0))) then
    IOO0O00I := '1';
    OOl0lO0I := ll01O0II;
  else 
    IOO0O00I := '0';
  end if;
  if ((lO0IIIl1 = I1OOOO01) and ((OllI0I00 = ll01O0II) or (ieee_compliance = 0))) then
    I1I00O1I := '1';
    OllI0I00 := ll01O0II;
  else 
    I1I00O1I := '0';
  end if;
  if ((OO1I01Il = I1OOOO01) and ((OO1lI100 = ll01O0II) or (ieee_compliance = 0))) then
    O0OO1O11 := '1';
    OO1lI100 := ll01O0II;
  else 
    O0OO1O11 := '0';
  end if;
  if ((l110001O = I1OOOO01) and ((IO00IO1O = ll01O0II) or (ieee_compliance = 0))) then
    OI011II1 := '1';
    IO00IO1O := ll01O0II;
  else 
    OI011II1 := '0';
  end if;

  -- detect the nan inputs
  if ((l11O10O1 = I1OOOO01) and (O111lO00 /= ll01O0II) and (ieee_compliance = 1)) then
    O1l100O0 := '1';
  else
    O1l100O0 := '0';
  end if;
  if ((l0IO00OO = I1OOOO01) and (OOO110l0 /= ll01O0II) and (ieee_compliance = 1)) then
    Ol01000O := '1';
  else
    Ol01000O := '0';
  end if;
  if ((OIl11l11 = I1OOOO01) and (OOl0lO0I /= ll01O0II) and (ieee_compliance = 1)) then
    Ol11lO0O := '1';
  else
    Ol11lO0O := '0';
  end if;
  if ((lO0IIIl1 = I1OOOO01) and (OllI0I00 /= ll01O0II) and (ieee_compliance = 1)) then
    OO011O10 := '1';
  else
    OO011O10 := '0';
  end if;
  if ((OO1I01Il = I1OOOO01) and (OO1lI100 /= ll01O0II) and (ieee_compliance = 1)) then
    OlO0OIO0 := '1';
  else
    OlO0OIO0 := '0';
  end if;
  if ((l110001O = I1OOOO01) and (IO00IO1O /= ll01O0II) and (ieee_compliance = 1)) then
    OOl0OI0l := '1';
  else
    OOl0OI0l := '0';
  end if;
  
  -- build mantissas
  -- Detect the denormal input case
  if ((l11O10O1 = l00O001O) and (O111lO00 /= ll01O0II) and (ieee_compliance = 1)) then
    -- Mantissa of denormal value
    I10I1101 := '0' & O111lO00;
    IO1OI101 := '1';
    l11O10O1(0) := '1';                -- set exponent of denormal to minimum
  else
    -- Mantissa for normal number
    if (l11O10O1 = l00O001O) then
      I10I1101 := OI0l001O;
    else
      I10I1101 := '1' & O111lO00;
    end if;
    IO1OI101 := '0';      
  end if;
  if ((l0IO00OO = l00O001O) and (OOO110l0 /= ll01O0II) and (ieee_compliance = 1)) then
    -- Mantissa of denormal value
    O01O0O01 := '0' & OOO110l0;
    O1I00111 := '1';
    l0IO00OO(0) := '1';
  else
    -- Mantissa for normal number
    if (l0IO00OO = l00O001O) then
      O01O0O01 := OI0l001O;
    else
      O01O0O01 := '1' & OOO110l0;
    end if;
    O1I00111 := '0';      
  end if;
  if ((OIl11l11 = l00O001O) and (OOl0lO0I /= ll01O0II) and (ieee_compliance = 1)) then
    -- Mantissa of denormal value
    I011IIO1 := '0' & OOl0lO0I;
    I01O00O0 := '1';
    OIl11l11(0) := '1';
  else
    -- Mantissa for normal number
    if (OIl11l11 = l00O001O) then
      I011IIO1 := OI0l001O;
    else
      I011IIO1 := '1' & OOl0lO0I;
    end if;
    I01O00O0 := '0';      
  end if;
  if ((lO0IIIl1 = l00O001O) and (OllI0I00 /= ll01O0II) and (ieee_compliance = 1)) then
    -- Mantissa of denormal value
    Ol1I1I10 := '0' & OllI0I00;
    IOOI00O1 := '1';
    lO0IIIl1(0) := '1';
  else
    -- Mantissa for normal number
    if (lO0IIIl1 = l00O001O) then
      Ol1I1I10 := OI0l001O;
    else
      Ol1I1I10 := '1' & OllI0I00;
    end if;
    IOOI00O1 := '0';      
  end if;
  if ((OO1I01Il = l00O001O) and (OO1lI100 /= ll01O0II) and (ieee_compliance = 1)) then
    -- Mantissa of denormal value
    IO1I0II1 := '0' & OO1lI100;
    l1O10O11 := '1';
    OO1I01Il(0) := '1';
  else
    -- Mantissa for normal number
    if (OO1I01Il = l00O001O) then
      IO1I0II1 := OI0l001O;
    else
      IO1I0II1 := '1' & OO1lI100;
    end if;
    l1O10O11 := '0';      
  end if;
  if ((l110001O = l00O001O) and (IO00IO1O /= ll01O0II) and (ieee_compliance = 1)) then
    -- Mantissa of denormal value
    IOOIOOO1 := '0' & IO00IO1O;
    OO00OOl1 := '1';
    l110001O(0) := '1';
  else
    -- Mantissa for normal number
    if (l110001O = l00O001O) then
      IOOIOOO1 := OI0l001O;
    else
      IOOIOOO1 := '1' & IO00IO1O;
    end if;
    OO00OOl1 := '0';      
  end if;
  if (l11O10O1 = 0 or l0IO00OO = 0) then
    OO0l1OOO := (others => '0');
  else
    OO0l1OOO := ("0"&l11O10O1) + ("0"&l0IO00OO);
  end if;
  if (OIl11l11 = 0 or lO0IIIl1 = 0) then
    lI11OO01 := (others => '0');
  else
    lI11OO01 := ("0"&OIl11l11) + ("0"&lO0IIIl1);
  end if;
  if (OO1I01Il = 0 or l110001O = 0) then
    l0I0lIOl := (others => '0');
  else
    l0I0lIOl := ("0"&OO1I01Il) + ("0"&l110001O);
  end if;
  
  OOI1OI11 := (lII1l0O0 or I01I1O10);
  lIO0OlI1 := (Ol0OIl01 or OOl0I01I);
  l01O1OI0 := (l1l101l1 or I011O1O1);

  -- Rule 1.
  if (O1l100O0 = '1' or Ol01000O = '1' or Ol11lO0O = '1' or OO011O10 = '1' or OlO0OIO0 = '1'
      or OlO0OIO0 = '1' or OOl0OI0l = '1') then
    -- one of the inputs is a NAN       --> the output must be an NAN
    O1I1O1II := OO1O1lO1;
    OIOO0Il0(2) := '1';

  elsif (((O000O1lI = '1' and I01I1O10 = '1') or (I00OO11l = '1' and lII1l0O0 = '1') or
          (IOO0O00I = '1' and OOl0I01I = '1') or (I1I00O1I = '1' and Ol0OIl01 = '1') or
          (O0OO1O11 = '1' and I011O1O1 = '1') or (OI011II1 = '1' and l1l101l1 = '1')) ) then
    O1I1O1II := OO1O1lO1;
    OIOO0Il0(2) := '1';
    if (ieee_compliance = 0) then
      OIOO0Il0(1) := '1';
    end if;


  -- Zero inputs 
  elsif (OOI1OI11 = '1' and lIO0OlI1 = '1' and 
         l01O1OI0 = '1') then
    IO01OOO1 := (I1lOI000 xor l01O0I00);
    O1O0llI1 := (IOO10O10 xor O11l0101);
    ll0Il11O := (Ill0lIII xor I01l0ll0);
    O1I1O1II := (others => '0');
    if (IO01OOO1 = O1O0llI1 and O1O0llI1 = ll0Il11O and ieee_compliance = 1) then
      O1I1O1II((exp_width + sig_width)) := IO01OOO1;
    elsif (rnd = "011") then
      O1I1O1II((exp_width + sig_width)) := '1';
    else
      O1I1O1II((exp_width + sig_width)) := '0';
    end if;
    OIOO0Il0(0) := '1';

  --
  -- Normal Inputs
  --
  else                                          
    -- generate the product terms
    O01l0IIl := (I10I1101 * O01O0O01);
    OII01I10 := (I011IIO1 * Ol1I1I10);
    l11I110l := (IO1I0II1 * IOOIOOO1);
    OIl1IIl0 := "00"&O01l0IIl&conv_std_logic_vector(0, (2*sig_width+5));
    ll1IIOll := "00"&OII01I10&conv_std_logic_vector(0, (2*sig_width+5));
    l101O0I1 := "00"&l11I110l&conv_std_logic_vector(0, (2*sig_width+5));

    IO01OOO1 := (I1lOI000 xor l01O0I00);
    O1O0llI1 := (IOO10O10 xor O11l0101);
    ll0Il11O := (Ill0lIII xor I01l0ll0);

    -- the following variables are used to keep track of invalid operations
    I0l1I11l := ((O000O1lI and I01I1O10) or (I00OO11l and lII1l0O0));
    O0O00I1I := ((IOO0O00I and OOl0I01I) or (I1I00O1I and Ol0OIl01));
    OOO0OI11 := ((O0OO1O11 and I011O1O1) or (OI011II1 and l1l101l1));
    IO0Il1I0 := I0l1I11l or O0O00I1I or OOO0OI11;
    OOI1OI11 := (lII1l0O0 or I01I1O10) and  not I0l1I11l;
    lIO0OlI1 := (Ol0OIl01 or OOl0I01I) and  not O0O00I1I;
    l01O1OI0 := (l1l101l1 or I011O1O1) and  not OOO0OI11;
    

    if (IO0Il1I0 = '1' or
        (OOI1OI11='1' and lIO0OlI1='1' and l01O1OI0='1')) then
      if (IO0Il1I0 = '1') then
        OIOO0Il0(2) := '1';
        if (ieee_compliance = 0) then
          OIOO0Il0(1) := '1';
        end if;
        O1I1O1II := OO1O1lO1;                  -- NaN
      else
                                          -- Zero (exact)
        OIOO0Il0(0) := '1';
        O1I1O1II := (others => '0');
      end if;
    else
      while ( (OIl1IIl0((2*(sig_width+1)+1+(2*sig_width+5))-2) = '0') and (OO0l1OOO /= 0) ) loop
        OO0l1OOO := OO0l1OOO - 1;
        OIl1IIl0 := OIl1IIl0(OIl1IIl0'length-2 downto 0) & '0';
      end loop;
      while ( (ll1IIOll((2*(sig_width+1)+1+(2*sig_width+5))-2) = '0') and (lI11OO01 /= 0) ) loop
        lI11OO01 := lI11OO01 - 1;
        ll1IIOll := ll1IIOll(ll1IIOll'length-2 downto 0) & '0';
      end loop;
      while ( (l101O0I1((2*(sig_width+1)+1+(2*sig_width+5))-2) = '0') and (l0I0lIOl /= 0) ) loop
        l0I0lIOl := l0I0lIOl - 1;
        l101O0I1 := l101O0I1(l101O0I1'length-2 downto 0) & '0';
      end loop;

      O001lI00 := '0';
      I1I01OI1 := '0';
      OOO0O000 := '0';
      if ( (O000O1lI = '1') or (I00OO11l = '1') ) then
        O001lI00 := '1';
      end if;
      if ( (IOO0O00I = '1') or (I1I00O1I = '1') ) then
        I1I01OI1 := '1';
      end if;
      if ( (O0OO1O11 = '1') or (OI011II1 = '1') ) then
        OOO0O000 := '1';
      end if;
      if (O001lI00 = '1' or I1I01OI1 = '1' or OOO0O000 = '1')  then
        OIOO0Il0(1) := '1';
        OIOO0Il0(4) := not (O000O1lI or I00OO11l or IOO0O00I or
                                         I1I00O1I or O0OO1O11 or OI011II1);
        OIOO0Il0(5) := not (O000O1lI or I00OO11l or IOO0O00I or
                                         I1I00O1I or O0OO1O11 or OI011II1);
        O1I1O1II := IO001OOO;
        O1I1O1II((exp_width + sig_width)) := (O001lI00 and IO01OOO1) or
                            (I1I01OI1 and O1O0llI1) or
                            (OOO0O000 and ll0Il11O);
        -- Watch out for Inf-Inf !
        if ( (O001lI00 = '1'  and I1I01OI1 = '1' and IO01OOO1 /= O1O0llI1) or
             (O001lI00 = '1'  and OOO0O000 = '1' and IO01OOO1 /= ll0Il11O) or
             (I1I01OI1 = '1'  and OOO0O000 = '1' and O1O0llI1 /= ll0Il11O))
          then
          OIOO0Il0(2) := '1';
          OIOO0Il0(1) := '0';
          if (ieee_compliance = 0) then
            OIOO0Il0(1) := '1';
          end if;
          OIOO0Il0(4) := '0';
          OIOO0Il0(5) := '0';
          O1I1O1II := OO1O1lO1;                  -- NaN
        end if;

      else
          if ((IO01OOO1&OO0l1OOO&OIl1IIl0) = 
              ((not O1O0llI1)&lI11OO01&ll1IIOll)) then
            OO0l1OOO := (others => '0');
            OIl1IIl0 := (others => '0');
            lI11OO01 := (others => '0');
            ll1IIOll := (others => '0');
          end if;
          if ((IO01OOO1&OO0l1OOO&OIl1IIl0) = 
              ((not ll0Il11O)&l0I0lIOl&l101O0I1)) then
            OO0l1OOO := (others => '0');
            OIl1IIl0 := (others => '0');
            l0I0lIOl := (others => '0');
            l101O0I1 := (others => '0');
          end if;
          if ((O1O0llI1&lI11OO01&ll1IIOll) = 
              ((not ll0Il11O)&l0I0lIOl&l101O0I1)) then
            lI11OO01 := (others => '0');
            ll1IIOll := (others => '0');
            l0I0lIOl := (others => '0');
            l101O0I1 := (others => '0');
          end if;

        O10O0O01 := '0';
        if ((lI11OO01&ll1IIOll) < (l0I0lIOl&l101O0I1)) then
          O10O0O01 := '1';
        end if;
        if (O10O0O01 = '1') then
          IOIOOlOO := l0I0lIOl;
          OO0OlO0l := l101O0I1;
          OO11IlIl := ll0Il11O;
          l1Ol01I0 := lI11OO01;
          I1O1l111 := ll1IIOll;
          O0O000ll := O1O0llI1;
        else
          IOIOOlOO := lI11OO01;
          OO0OlO0l := ll1IIOll;
          OO11IlIl := O1O0llI1;
          l1Ol01I0 := l0I0lIOl;
          I1O1l111 := l101O0I1;
          O0O000ll := ll0Il11O;
        end if;
        I0000OlI := '0';
        if ((OO0l1OOO&OIl1IIl0) < (IOIOOlOO&OO0OlO0l)) then
          I0000OlI := '1';
        end if;
        if (I0000OlI = '1') then
          lO10lI00 := IOIOOlOO;
          O0I10110 := OO0OlO0l;
          I1lI1IOO := OO11IlIl;
          OOIO0000 := OO0l1OOO;
          l00OO00O := OIl1IIl0;
          OIOO1OI0 := IO01OOO1;
        else
          lO10lI00 := OO0l1OOO;
          O0I10110 := OIl1IIl0;
          I1lI1IOO := IO01OOO1;
          OOIO0000 := IOIOOlOO;
          l00OO00O := OO0OlO0l;
          OIOO1OI0 := OO11IlIl;
       end if;
 
        I1I010Ol := '0';
        ll0OO0lO := lO10lI00 - OOIO0000;
        O00O00lO := l00OO00O;
        while ( (O00O00lO /= OlO11O00) and (ll0OO0lO /= l00O001O) ) loop
          I1I010Ol := O00O00lO(0) or I1I010Ol;
          O00O00lO := '0' & O00O00lO(O00O00lO'length-1 
                                                     downto 1);
          ll0OO0lO := ll0OO0lO - 1;
        end loop;
        O00O00lO(0) := O00O00lO(0) or I1I010Ol;
        I1I010Ol := O00O00lO(0);
        I10O1l00 := '0';
        O1OOII1O := lO10lI00 - l1Ol01I0;
        l01OIO1I := I1O1l111;
        while ( (l01OIO1I /= OlO11O00) and (O1OOII1O /= l00O001O) ) loop
          I10O1l00 := l01OIO1I(0) or I10O1l00;
          l01OIO1I := '0' & l01OIO1I(l01OIO1I'length-1 
                                                     downto 1);
          O1OOII1O := O1OOII1O - 1;
        end loop;
        l01OIO1I(0) := l01OIO1I(0) or I10O1l00;
        I10O1l00 := l01OIO1I(0);
      
          if (I1I010Ol = '1'  and I10O1l00 = '1') then
            if ((OOIO0000 & l00OO00O) < (l1Ol01I0 & I1O1l111)) then
              O00O00lO(0) := '0';
            else
              l01OIO1I(0) := '0';
            end if;
          end if;

        if (I1lI1IOO /= OIOO1OI0) then
          lI011O0I := not ('0'&O00O00lO) + 1;
        else
          lI011O0I := ('0'&O00O00lO);
        end if;
        if (I1lI1IOO /= O0O000ll) then
          l0O01OII := not ('0'&l01OIO1I) + 1;
        else
          l0O01OII := ('0'&l01OIO1I);
        end if;
        l11101IO := ('0'&O0I10110) + lI011O0I + l0O01OII;

        I10000OO := l11101IO((2*(sig_width+1)+1+(2*sig_width+5))+1);      
        if (I10000OO = '1') then
          l1110O1O := not l11101IO((2*(sig_width+1)+1+(2*sig_width+5)) downto 0) + 1;
        else
          l1110O1O := l11101IO((2*(sig_width+1)+1+(2*sig_width+5)) downto 0);
        end if;
        if (l11101IO /= 0) then
          O1IO111I := I10000OO xor I1lI1IOO;
        else
          O1IO111I := '0';
        end if;
 
        Ol1O00ll := '0' & lO10lI00;

        -- Normalize the Mantissa for computation overflow case.
        O100O1O1 := '0';
        if (l1110O1O((2*(sig_width+1)+1+(2*sig_width+5))) = '1') then
          Ol1O00ll := Ol1O00ll + 1;
          O100O1O1 := l1110O1O(0);
          l1110O1O := '0' & l1110O1O(l1110O1O'length-1 downto 1);
          l1110O1O(0) := l1110O1O(0) or O100O1O1;
        end if;
        if (l1110O1O((2*(sig_width+1)+1+(2*sig_width+5))-1) = '1') then
          Ol1O00ll := Ol1O00ll + 1;
          O100O1O1 := l1110O1O(0);
          l1110O1O := '0' & l1110O1O(l1110O1O'length-1 downto 1);
          l1110O1O(0) := l1110O1O(0) or O100O1O1;
       end if;
        if (l1110O1O((2*(sig_width+1)+1+(2*sig_width+5))-2) = '1') then
          Ol1O00ll := Ol1O00ll + 1;
          O100O1O1 := l1110O1O(0);
          l1110O1O := '0' & l1110O1O(l1110O1O'length-1 downto 1);
          l1110O1O(0) := l1110O1O(0) or O100O1O1;
        end if; 
        while ( (l1110O1O((2*(sig_width+1)+1+(2*sig_width+5))-3) = '0') and (Ol1O00ll > (((2 ** (exp_width-1)) - 1)+1)) ) loop
          Ol1O00ll := Ol1O00ll - 1;
          l1110O1O := l1110O1O(l1110O1O'length-2 downto 0) & '0';
        end loop;

        while ( l1110O1O /= OlO11O00 and (Ol1O00ll <= ((2 ** (exp_width-1)) - 1)) ) loop
          Ol1O00ll := Ol1O00ll + 1;
          O100O1O1 := l1110O1O(0) or O100O1O1;
          l1110O1O := '0' & l1110O1O(l1110O1O'length-1 downto 1);
        end loop;

        O111II00 := l1110O1O(((2*(sig_width+1)+1+(2*sig_width+5))-3-sig_width));
        I110l0O1 := l1110O1O((((2*(sig_width+1)+1+(2*sig_width+5))-3-sig_width) - 1));
        OIO1I10O := or_reduce(l1110O1O((((2*(sig_width+1)+1+(2*sig_width+5))-3-sig_width) - 1)-1 downto 0)) or I1I010Ol or I10O1l00 or O100O1O1;
        IO1OIO0O := OI101IO0(rnd, O1IO111I, O111II00, I110l0O1, OIO1I10O);
 
        if (IO1OIO0O(0) = '1') then
          l1110O1O := l1110O1O + ('1' & conv_std_logic_vector(0,((2*(sig_width+1)+1+(2*sig_width+5))-3-sig_width)));
        end if;   

        if ( (l1110O1O((2*(sig_width+1)+1+(2*sig_width+5))-2) = '1') ) then
          Ol1O00ll := Ol1O00ll + 1;
          l1110O1O := '0' & l1110O1O(l1110O1O'length-1 downto 1);
        end if;
        
        if ((l1110O1O((2*(sig_width+1)+1+(2*sig_width+5)) downto (2*(sig_width+1)+1+(2*sig_width+5))-3) = "0000") or (Ol1O00ll<=((2 ** (exp_width-1)) - 1))) then
          -- result is tiny
          if (ieee_compliance = 1) then
            O1I1O1II := O1IO111I & l00O001O & l1110O1O(((2*(sig_width+1)+1+(2*sig_width+5))-4) downto ((2*(sig_width+1)+1+(2*sig_width+5))-3-sig_width));
            OIOO0Il0(5) := IO1OIO0O(1);
            OIOO0Il0(3) := IO1OIO0O(1) or 
                                           or_reduce(l1110O1O((2*(sig_width+1)+1+(2*sig_width+5)) downto ((2*(sig_width+1)+1+(2*sig_width+5))-3-sig_width)));
            if (l1110O1O(((2*(sig_width+1)+1+(2*sig_width+5))-4) downto ((2*(sig_width+1)+1+(2*sig_width+5))-3-sig_width)) = ll01O0II) then
              OIOO0Il0(0) := '1'; 
              if (IO1OIO0O(1) = '0') then
                -- result is an exact zero
                if (rnd = "011") then
                  O1I1O1II((exp_width + sig_width)) := '1';
                else
                  O1I1O1II((exp_width + sig_width)) := '0';
                end if;
              end if;
            end if;
          else
            -- when denormals are not used  -> the output becomes zero or minnorm
            OIOO0Il0(5) := IO1OIO0O(1) or 
                                           or_reduce(l1110O1O((2*(sig_width+1)+1+(2*sig_width+5)) downto ((2*(sig_width+1)+1+(2*sig_width+5))-3-sig_width)));
            OIOO0Il0(3) := IO1OIO0O(1) or 
                                           or_reduce(l1110O1O((2*(sig_width+1)+1+(2*sig_width+5)) downto ((2*(sig_width+1)+1+(2*sig_width+5))-3-sig_width)));
            if (((rnd = "011" and O1IO111I = '1') or
                 (rnd = "010" and O1IO111I = '0') or
                 rnd = "101") and (l1110O1O((2*(sig_width+1)+1+(2*sig_width+5)) downto ((2*(sig_width+1)+1+(2*sig_width+5))-3-sig_width)) /= lIl01O00)) then
              -- Minnorm
              O1I1O1II := O1IO111I & O00ll0l1 & ll01O0II;
              OIOO0Il0(0) := '0';
            else
              -- zero
              OIOO0Il0(0) := '1';
              if (OIOO0Il0(5) = '1') then
                O1I1O1II := O1IO111I & l00O001O & ll01O0II;
              else
                O1I1O1II := (others => '0');
                if (rnd = "011") then
                  O1I1O1II := '1' & l00O001O & ll01O0II;
                else
                  O1I1O1II := '0' & l00O001O & ll01O0II;
                end if;
              end if;
            end if;
          end if;
        else
          --
          -- Huge
          --
          if (Ol1O00ll >= conv_std_logic_vector(((((2 ** (exp_width-1)) - 1) * 2) + 1)+((2 ** (exp_width-1)) - 1),Ol1O00ll'length)) then
            OIOO0Il0(4) := '1';
            OIOO0Il0(5) := '1';
            if (IO1OIO0O(2) = '1') then
              -- Infinity
              l1110O1O((2*(sig_width+1)+1+(2*sig_width+5))-3 downto ((2*(sig_width+1)+1+(2*sig_width+5))-3-sig_width)) := (others => '0');
              Ol1O00ll := conv_std_logic_vector(((((2 ** (exp_width-1)) - 1) * 2) + 1),Ol1O00ll'length);
              OIOO0Il0(1) := '1';
            else
              -- MaxNorm
              Ol1O00ll := conv_std_logic_vector(((((2 ** (exp_width-1)) - 1) * 2) + 1),Ol1O00ll'length) - 1;
              l1110O1O(((2*(sig_width+1)+1+(2*sig_width+5))-4) downto ((2*(sig_width+1)+1+(2*sig_width+5))-3-sig_width)) := (others => '1');
            end if;
          else
              Ol1O00ll := Ol1O00ll - ((2 ** (exp_width-1)) - 1);
          end if;
          --
          -- Normal
          --
          OIOO0Il0(5) := OIOO0Il0(5) or IO1OIO0O(1);
          -- Reconstruct the floating point format.
          O1I1O1II := O1IO111I & Ol1O00ll(exp_width-1 downto 0) & l1110O1O(((2*(sig_width+1)+1+(2*sig_width+5))-4) downto ((2*(sig_width+1)+1+(2*sig_width+5))-3-sig_width));
  
        end if;  -- (l1110O1O((2*(sig_width+1)+1+(2*sig_width+5)) downto (2*(sig_width+1)+1+(2*sig_width+5))-2) = "000")
      end if;
    end if;
  end if;  -- NaN input 

  O0l0OO10 <= OIOO0Il0;
  O1l11O01 <= O1I1O1II;

end process MAIN_PROCESS;

--
-- purpose: process the output values
-- type   : combinational
SELECT_OUTPUT: process (a, b, c, d, e, f, rnd, lO100001, O1l11O01, OlIII0lO, 
                        O0l0OO10)
begin
  if (Is_X(a) or Is_X(b) or Is_X(c) or Is_X(d) or Is_X(e) or Is_X(f) or Is_X(rnd)) then
    status <= (others => 'X');
    z <= (others => 'X');
  else
     if (arch_type = 1) then
       status <= OlIII0lO;
       z <= lO100001;
     else
       status <= O0l0OO10;
       z <= O1l11O01;
     end if;
  end if;
end process SELECT_OUTPUT;  

-- pragma translate_on  

end sim ;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

library dw02;

configuration DW_fp_dp3_cfg_sim of DW_fp_dp3 is
 for sim
  for U1: DW_fp_ifp_conv use configuration dw02.DW_fp_ifp_conv_cfg_sim; end for;
  for U2: DW_fp_ifp_conv use configuration dw02.DW_fp_ifp_conv_cfg_sim; end for;
  for U3: DW_fp_ifp_conv use configuration dw02.DW_fp_ifp_conv_cfg_sim; end for;
  for U4: DW_fp_ifp_conv use configuration dw02.DW_fp_ifp_conv_cfg_sim; end for;
  for U5: DW_fp_ifp_conv use configuration dw02.DW_fp_ifp_conv_cfg_sim; end for;
  for U6: DW_fp_ifp_conv use configuration dw02.DW_fp_ifp_conv_cfg_sim; end for;
  for U7: DW_ifp_mult use configuration dw02.DW_ifp_mult_cfg_sim; end for;
  for U8: DW_ifp_mult use configuration dw02.DW_ifp_mult_cfg_sim; end for;
  for U9: DW_ifp_mult use configuration dw02.DW_ifp_mult_cfg_sim; end for;
  for U10: DW_ifp_addsub use configuration dw02.DW_ifp_addsub_cfg_sim; end for;
  for U11: DW_ifp_addsub use configuration dw02.DW_ifp_addsub_cfg_sim; end for;
  for U12: DW_ifp_fp_conv use configuration dw02.DW_ifp_fp_conv_cfg_sim; end for;
 end for; -- sim
end DW_fp_dp3_cfg_sim;
-- pragma translate_on

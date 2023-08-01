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
-- VERSION:   VHDL Simulation Model - DW_fp_dp4
--
-- DesignWare_version: 50f377e2
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--
-- ABSTRACT: Floating-point Four-term Dot-product
--           Computes the sum of products of FP numbers. For this component,
--           four products are considered. Given the FP inputs a, b, c, d, e
--           f, g and h, it computes the FP output z = a*b + c*d + e*f + g*h. 
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
--              sig_width       significand,  2 to 253 bits
--              exp_width       exponent,     3 to 31 bits
--              ieee_compliance 0 or 1 (default 1)
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
--              g               (sig_width + exp_width) + 1-bits
--                              Floating-point Number Input
--              h               (sig_width + exp_width) + 1-bits
--                              Floating-point Number Input
--              rnd             3 bits
--                              rounding mode
--
--              Output ports    Size & Description
--              ===========     ==================
--              z               (sig_width + exp_width + 1) bits
--                              Floating-point Number result that corresponds
--                              to a*b+c*d+e*f+g*h
--              status          byte
--                              info about FP results
--
-- MODIFIED:
--           11/12/07 - AFT - Includes modifications to deal with the sign of zeros
--                   according to specification regarding the addition of zeros 
--                   (A-SP1)
--           11/12/07 - AFT - fixed other problems related to the cancellation of
--                    of products and internal detection of infinities
--           04/2008 - AFT - included parameter arch_type to control the use
--                   of internal floating-point format blocks.
--           01/2009 - AFT - expanded the use of parameters to accept 
--                     ieee_compliance=1 when arch_type=1
--           07/2009 - AFT - fixed the STK bit cancellation procedure to follow 
--                     the same rules defined for the sum4 component (see comments
--                     in the code)
--           09/2010 - AFT - fix corner cases when only 1 bit of the signficant is
--                     kept during alignment.
--           10/2011 - AFT - fixed the cancellation of STK bits when there are 
--                     partially shifted out of range products. 
--           04/2012 - AFT - fixed problem described in star 9000532273 
--                     Sticky bit is being shifted during normalization, and 
--                     causing rounding error. 
--           07/2012 - AFT - slightly changed the description of the rules used
--                     to cancel stk bits when POR or COR products happen. No change
--                     in functionality.
--
---------------------------------------------------------------------------------
library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_misc.all;
use DWARE.DW_Foundation_comp_arith.all;

architecture sim of DW_fp_dp4 is
	

-- pragma translate_off


-- Ol1l110O function used in several FP components
function Ol1l110O (ll1IOIlO: std_logic_vector(2 downto 0);
                   I000OO0O: std_logic;
                   IO1IO0l1: std_logic;
                   OO100IO0: std_logic;
                   O0l10OOI: std_logic) return std_logic_vector is
--*******************************
--  l1000O1I has 4 bits:
--  l1000O1I[0]
--  l1000O1I[1]
--  l1000O1I[2]
--  l1000O1I[3]
--*******************************

--*******************************
--  Rounding increment equations
--  |
--    MODE | Equation   | Description
--    -----------------------------
--    even | OO100IO0&(IO1IO0l1|O0l10OOI)  | IEEE round to nearest (even)
--    zero | 0          | IEEE round to zero
--    +inf | S'&(OO100IO0|O0l10OOI) | IEEE round to positive infinity
--    -inf | S&(OO100IO0|O0l10OOI)  | IEEE round to negative infinity
--     up  | OO100IO0          | round to nearest (up)
--    away | (OO100IO0|O0l10OOI)    | round away from zero
-- *******************************
variable Ol1l110O : std_logic_vector (4-1 downto 0);
begin
  Ol1l110O(0) := '0';
  Ol1l110O(1) := OO100IO0 or O0l10OOI;
  Ol1l110O(2) := '0';
  Ol1l110O(3) := '0';
  case ll1IOIlO is
    when "000" =>
      -- round to nearest (even) 
      Ol1l110O(0) := OO100IO0 and (IO1IO0l1 or O0l10OOI);
      Ol1l110O(2) := '1';
      Ol1l110O(3) := '0';
    when "001" =>
      -- round to zero 
      Ol1l110O(0) := '0';
      Ol1l110O(2) := '0';
      Ol1l110O(3) := '0';
    when "010" =>
      -- round to positive infinity 
      Ol1l110O(0) := not I000OO0O and (OO100IO0 or O0l10OOI);
      Ol1l110O(2) := not I000OO0O;
      Ol1l110O(3) := not I000OO0O;
    when "011" =>
      -- round to negative infinity 
      Ol1l110O(0) := I000OO0O and (OO100IO0 or O0l10OOI);
      Ol1l110O(2) := I000OO0O;
      Ol1l110O(3) := I000OO0O;
    when "100" =>
      -- round to nearest (up)
      Ol1l110O(0) := OO100IO0;
      Ol1l110O(2) := '1';
      Ol1l110O(3) := '0';
    when "101" =>
      -- round away form 0  
      Ol1l110O(0) := OO100IO0 or O0l10OOI;
      Ol1l110O(2) := '1';
      Ol1l110O(3) := '1';
    when others =>
      Ol1l110O(0) := 'X';
      Ol1l110O(2) := 'X';
      Ol1l110O(3) := 'X';
  end case;
  return (Ol1l110O);
end function;                                    -- l1000O1I function


signal status_int1, O10O0I1O : std_logic_vector(8    -1 downto 0);
signal z_temp1, OO0IOOll : std_logic_vector((exp_width + sig_width) downto 0);

-- Other signals used for simulation of the architecture when arch_type = 1

signal OI0IOI00 : std_logic_vector(sig_width+2+exp_width+6 downto 0); -- inputs
signal OOO1IlI0 : std_logic_vector(sig_width+2+exp_width+6 downto 0);
signal l10OOO00 : std_logic_vector(sig_width+2+exp_width+6 downto 0);
signal I0OOII0O : std_logic_vector(sig_width+2+exp_width+6 downto 0); 
signal ll11O1l0 : std_logic_vector(sig_width+2+exp_width+6 downto 0); 
signal Ol01Ol0I : std_logic_vector(sig_width+2+exp_width+6 downto 0); 
signal IO0OI0ll : std_logic_vector(sig_width+2+exp_width+6 downto 0); 
signal O101OI11 : std_logic_vector(sig_width+2+exp_width+6 downto 0); 
signal O10Ol000 : std_logic_vector(2*(sig_width+2+1)+exp_width+1+6 downto 0);-- a*b 
signal l100OO1I : std_logic_vector(2*(sig_width+2+1)+exp_width+1+6 downto 0);-- c*d 
signal l1Ol001l : std_logic_vector(2*(sig_width+2+1)+exp_width+1+6 downto 0);-- e*f 
signal IO0111Ol : std_logic_vector(2*(sig_width+2+1)+exp_width+1+6 downto 0);-- g*h 
signal llOI0000 : std_logic_vector(2*(sig_width+2+1)+1+exp_width+1+1+6 downto 0);--p1+p2 
signal OIOOl1O1 : std_logic_vector(2*(sig_width+2+1)+1+exp_width+1+1+6 downto 0);--p3+p4
signal O11OlO0I : std_logic_vector(2*(sig_width+2+1)+1+1+exp_width+1+1+1+6 downto 0);--padd1+padd2

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
          port map ( a => a, z => OI0IOI00 );
  U2: DW_fp_ifp_conv generic map (sig_widthi => sig_width, 
                                  exp_widthi => exp_width, 
                                  sig_widtho => sig_width+2,
                                  exp_widtho => exp_width,
                                  use_denormal => ieee_compliance,
                                  use_1scmpl => 0)
          port map ( a => b, z => OOO1IlI0 );
  U3: DW_fp_ifp_conv generic map (sig_widthi => sig_width, 
                                  exp_widthi => exp_width, 
                                  sig_widtho => sig_width+2,
                                  exp_widtho => exp_width,
                                  use_denormal => ieee_compliance,
                                  use_1scmpl => 0)
          port map ( a => c, z => l10OOO00 );
  U4: DW_fp_ifp_conv generic map (sig_widthi => sig_width, 
                                  exp_widthi => exp_width, 
                                  sig_widtho => sig_width+2,
                                  exp_widtho => exp_width,
                                  use_denormal => ieee_compliance,
                                  use_1scmpl => 0)
          port map ( a => d, z => I0OOII0O );
  U5: DW_fp_ifp_conv generic map (sig_widthi => sig_width, 
                                  exp_widthi => exp_width, 
                                  sig_widtho => sig_width+2,
                                  exp_widtho => exp_width,
                                  use_denormal => ieee_compliance,
                                  use_1scmpl => 0)
          port map ( a => e, z => ll11O1l0 );
  U6: DW_fp_ifp_conv generic map (sig_widthi => sig_width, 
                                  exp_widthi => exp_width, 
                                  sig_widtho => sig_width+2,
                                  exp_widtho => exp_width,
                                  use_denormal => ieee_compliance,
                                  use_1scmpl => 0)
          port map ( a => f, z => Ol01Ol0I );
  U7: DW_fp_ifp_conv generic map (sig_widthi => sig_width, 
                                  exp_widthi => exp_width, 
                                  sig_widtho => sig_width+2,
                                  exp_widtho => exp_width,
                                  use_denormal => ieee_compliance,
                                  use_1scmpl => 0)
          port map ( a => g, z => IO0OI0ll );
  U8: DW_fp_ifp_conv generic map (sig_widthi => sig_width, 
                                  exp_widthi => exp_width, 
                                  sig_widtho => sig_width+2,
                                  exp_widtho => exp_width,
                                  use_denormal => ieee_compliance,
                                  use_1scmpl => 0)
          port map ( a => h, z => O101OI11 );
-- Instances of DW_ifp_mult
  U9: DW_ifp_mult generic map (  sig_widthi => sig_width+2,
                                 exp_widthi => exp_width,
                                 sig_widtho => 2*(sig_width+2+1),
                                 exp_widtho => exp_width+1)
          port map ( a => OI0IOI00, b => OOO1IlI0, z => O10Ol000);
  U10: DW_ifp_mult generic map (  sig_widthi => sig_width+2,
                                 exp_widthi => exp_width,
                                 sig_widtho => 2*(sig_width+2+1),
                                 exp_widtho => exp_width+1)
          port map ( a => l10OOO00, b => I0OOII0O, z => l100OO1I);
  U11: DW_ifp_mult generic map (  sig_widthi => sig_width+2,
                                 exp_widthi => exp_width,
                                 sig_widtho => 2*(sig_width+2+1),
                                 exp_widtho => exp_width+1)
          port map ( a => ll11O1l0, b => Ol01Ol0I, z => l1Ol001l);
  U12: DW_ifp_mult generic map (  sig_widthi => sig_width+2,
                                 exp_widthi => exp_width,
                                 sig_widtho => 2*(sig_width+2+1),
                                 exp_widtho => exp_width+1)
          port map ( a => IO0OI0ll, b => O101OI11, z => IO0111Ol);
-- Instance of DW_ifp_addsub
  U13: DW_ifp_addsub generic map (sig_widthi => 2*(sig_width+2+1),
                                 exp_widthi => exp_width+1,
                                 sig_widtho => 2*(sig_width+2+1)+1,
                                 exp_widtho => exp_width+1+1,
                                 use_denormal => ieee_compliance,
                                 use_1scmpl => 0)
          port map ( a => O10Ol000, b => l100OO1I, rnd => rnd, op => '0', z => llOI0000);
  U14: DW_ifp_addsub generic map (sig_widthi => 2*(sig_width+2+1),
                                 exp_widthi => exp_width+1,
                                 sig_widtho => 2*(sig_width+2+1)+1,
                                 exp_widtho => exp_width+1+1,
                                 use_denormal => ieee_compliance,
                                 use_1scmpl => 0)
          port map ( a => l1Ol001l, b => IO0111Ol, rnd => rnd, op => '0', z => OIOOl1O1);
  U15: DW_ifp_addsub generic map (sig_widthi => 2*(sig_width+2+1)+1,
                                 exp_widthi => exp_width+1+1,
                                 sig_widtho => 2*(sig_width+2+1)+1+1,
                                 exp_widtho => exp_width+1+1+1,
                                 use_denormal => ieee_compliance,
                                 use_1scmpl => 0)
          port map ( a => llOI0000, b => OIOOl1O1, rnd => rnd, op => '0', z => O11OlO0I);
-- Instance of DW_ifp_fp_conv  -- format converter
  U16: DW_ifp_fp_conv generic map (sig_widthi => 2*(sig_width+2+1)+1+1,
                                  exp_widthi => exp_width+1+1+1,
                                  sig_width  => sig_width,
                                  exp_width  => exp_width,
                                  use_denormal => ieee_compliance)
          port map ( a => O11OlO0I, rnd => rnd, z => z_temp1, status => status_int1 );


-----------------------------------------------------------------------
-- purpose: main process for the behavioral description of the FP DP2
-- when arch_type = 0
-----------------------------------------------------------------------
-- purpose: main process for the behavioral description of the FP DP2
-- type   : combinational
-- inputs : a, b, c, d, e, f, g, h, rnd
-- outputs: l0Ol0OOI and OIl1001l
MAIN_PROCESS: process (a, b, c, d, e, f, g, h, rnd)

variable l0Ol0OOI : std_logic_vector(8    -1 downto 0);
variable OIl1001l : std_logic_vector((exp_width + sig_width) downto 0);
variable lO0OOOIl,l1O100I0,OIO0I111,O01l0OI0,O0l10OOI,OIlOO101,l01010ll,OO1llIO1,IOIO101I,Il110l11,Il001001 : std_logic;
 -- Exponents.
variable OII0OO00,I0IO1I0I,II11O1l1,O111O1l0,O0I11lO1,I0OllO01,lI10O00l,lOOO1O10: std_logic_vector(exp_width-1 downto 0);
 -- fractional bits
variable I0OOOO0I,O11l1Il0,l1010OI1,Olll0I0I,l110IO01,l0011Ol0,O1I01l1O,OOIllOOl: std_logic_vector(sig_width-1 downto 0);
-- mantissa bits
variable OlI00101,O0O01OO1,IlOl0O1O,I00001l0,l00l0l10,l0l10l0l,l010l000,OO1O01OI: std_logic_vector(sig_width downto 0);    
-- sign bits
variable I0O1O10l,lIO0OIO1,O0I1O0OO,I0101O0I,lI0O1O11,lOllOlI1,O0O10OIl,O1101IlO: std_logic; 
variable O01l0I11,OOO1IO01,OOl000IO,O0I0l100,lOIOI11I,OOl0lll1,lll1O1I1,OlO101Ol: std_logic;  
variable II10OOO1,l0l0IIOI,l000O1O1,O111l1ll,I0OIO0II,I00O0l01,l1I11O1O,O00O10O0: std_logic;  
variable IIOO00Ol,IOlI1111,lI01111O,llIO1OO1,O0IOIOOO,l0O0001O,OI0OOO0I,O1I10IO1: std_logic;  
-- internal products
variable l0OOO1l1,I1OlI0Ol,OlOIOIO0,l10IIIO0: std_logic_vector(2*sig_width+1 downto 0); 
variable I1llOI11 : std_logic_vector(((6*sig_width+5+3)-2) downto 0);
variable I011O0l1 : std_logic_vector(((6*sig_width+5+3)-2) downto 0);
variable O0IOlI0O : std_logic_vector(((6*sig_width+5+3)-2) downto 0);
variable OIOl00O1 : std_logic_vector(((6*sig_width+5+3)-2) downto 0);
variable I11010I0, O11O0IO1, llII1II1, l0OIOl1I :  std_logic;
variable O11O101I,O0Ol1l1l,II10l0O0,O00I1lOO : std_logic_vector(exp_width+1 downto 0);
-- Special field values
variable I10O1110 : std_logic_vector(exp_width-1 downto 0) := (others => '0');
variable lOII1O0l : std_logic_vector(exp_width-1 downto 0) := (others => '0');
variable I1OOO1OI : std_logic_vector(sig_width-1 downto 0) := (others => '0');
variable I0I101OI : std_logic_vector(sig_width downto 0) := (others => '0');
variable lO11O011 : std_logic_vector(exp_width-1 downto 0);
variable I10ll1O0 : std_logic_vector(((6*sig_width+5+3)-2) downto (((6*sig_width+5+3)-2)-3-sig_width));
-- The biggest possible exponent for addition/subtraction
variable I0I0110O : std_logic_vector(exp_width+1 downto 0);
variable O0I0lO1O,OOI1O00O,O1OlO001 :  std_logic_vector(exp_width+1 downto 0);
-- Mantissa vectors and signs after multiplication and sorting
variable llOIOl1I,lO0ll1O1,O11lO00O :  std_logic_vector(((6*sig_width+5+3)-2) downto 0); 
variable OO1101OO,l0010OO1 :  std_logic_vector(((6*sig_width+5+3)-2) downto 0); 
variable I01O1OI1,OO011IO0,II01l1O1 :  std_logic_vector(((6*sig_width+5+3)-2) downto 0); 
variable OI01lO00,l10O100O,O1l100OO :  std_logic;
variable OII1I001,II101lI0 :  std_logic;
variable l10OlIl0,O11l0O0O,OOIIOO0O :  std_logic;
variable O1O0lOOO,O011O1I0,OlI1O0O0 :  std_logic_vector(exp_width+1 downto 0);
variable O0111O11,O1O00OII :  std_logic_vector(exp_width+1 downto 0);
variable OI0Ol0OO,OI1000I0,Il10l0OO:  std_logic_vector(exp_width+1 downto 0);
variable I1O11lIO : std_logic_vector(((6*sig_width+5+3)-2) downto 0); 
variable l0O111OO : std_logic_vector(((6*sig_width+5+3)-2) downto 0);
variable O1l0O100 : std_logic_vector(((6*sig_width+5+3)-2) downto 0);
-- internal adder output 
variable IO1110IO : std_logic;
variable O111111l,OO10Il01:  std_logic_vector(((6*sig_width+5+3)-2)+1 downto 0); 
variable l0IOIO11,IOOO1I01:  std_logic_vector(((6*sig_width+5+3)-2)+1 downto 0); 
variable II1lO1lO :  std_logic_vector(((6*sig_width+5+3)-2)+1 downto 0); 
variable I10OIO1I : std_logic;
-- Mantissa vector - internal
variable OIOOl1OI :  std_logic_vector(((6*sig_width+5+3)-2) downto 0); 
variable O10I0l10 : std_logic_vector(((6*sig_width+5+3)-2) downto 0) := (others => '0');
 -- Values returned by Ol1l110O function (rounding).
variable l1000O1I : std_logic_vector(4-1 downto 0);
-- Special FP values
variable IIOO1OI0 : std_logic_vector((exp_width + sig_width + 1)-1 downto 0);  -- Not-a-number
variable OI11lO10 : std_logic_vector((exp_width + sig_width + 1)-1 downto 0); -- plus infinity
variable OI0110lO : std_logic_vector((exp_width + sig_width + 1)-1 downto 0);  -- negative infinity
variable Ol10000O,IOI00O10,OOIO0lO0,I1000OO1 : std_logic;
variable l1OOO0O1,lO01101O,IO0OO10I,OO00O1OO: std_logic;
variable O1l10l01,l1O100O0,OO1II1I1,O0Ol01I1 : std_logic;
-- indication of denormals for Large or Small value
--variable Denormal_Large : std_logic;
--variable Denormal_Small : std_logic;
variable OIO11IOO, I1O0lOII, O00OOl01, O01II1lI : std_logic;
variable O00I0Ol1, O1l000I0, OO0O1111, lOO000II : std_logic;
variable IO1O0000 : std_logic;
variable I00l100l : std_logic;
variable DW_OO10OOO1 : integer;
variable l0IlO0O1, OlOl1OO0: std_logic; 
variable O11IOO1I, OlOII011: std_logic; 

begin  -- process MAIN_PROCESS

  DW_OO10OOO1 := 0;

  I10ll1O0 := (others => '0');
  O10I0l10 := (others => '0');
  -- setup some of special variables...
  lO11O011 := conv_std_logic_vector(((((2 ** (exp_width-1)) - 1) * 2) + 1), lO11O011'length);
  lOII1O0l := I10O1110 + 1;
  IIOO1OI0 := '0' & lO11O011 & I1OOO1OI;
  -- mantissa of NaN  is 1 when ieee_compliance = 1
  if (ieee_compliance = 1) then 
    IIOO1OI0(0) := '1';  
  end if;
  OI11lO10 := '0' & lO11O011 & I1OOO1OI;
  OI0110lO := '1' & lO11O011 & I1OOO1OI;
  l0Ol0OOI := (others => '0');

  -- extract exponent and significand from inputs
  OII0OO00 := a(((exp_width + sig_width) - 1) downto sig_width);
  I0IO1I0I := b(((exp_width + sig_width) - 1) downto sig_width);
  II11O1l1 := c(((exp_width + sig_width) - 1) downto sig_width);
  O111O1l0 := d(((exp_width + sig_width) - 1) downto sig_width);
  O0I11lO1 := e(((exp_width + sig_width) - 1) downto sig_width);
  I0OllO01 := f(((exp_width + sig_width) - 1) downto sig_width);
  lI10O00l := g(((exp_width + sig_width) - 1) downto sig_width);
  lOOO1O10 := h(((exp_width + sig_width) - 1) downto sig_width);
  I0OOOO0I := a((sig_width - 1) downto 0);
  O11l1Il0 := b((sig_width - 1) downto 0);
  l1010OI1 := c((sig_width - 1) downto 0);
  Olll0I0I := d((sig_width - 1) downto 0);
  l110IO01 := e((sig_width - 1) downto 0);
  l0011Ol0 := f((sig_width - 1) downto 0);
  O1I01l1O := g((sig_width - 1) downto 0);
  OOIllOOl := h((sig_width - 1) downto 0);
  I0O1O10l := a((exp_width + sig_width));
  lIO0OIO1 := b((exp_width + sig_width));
  O0I1O0OO := c((exp_width + sig_width));
  I0101O0I := d((exp_width + sig_width));
  lI0O1O11 := e((exp_width + sig_width));
  lOllOlI1 := f((exp_width + sig_width));
  O0O10OIl := g((exp_width + sig_width));
  O1101IlO := h((exp_width + sig_width));
    
  if ((OII0OO00 = I10O1110) and ((I0OOOO0I = I1OOO1OI) or (ieee_compliance = 0))) then
    O01l0I11 := '1';
    I0OOOO0I := I1OOO1OI;
  else
    O01l0I11 := '0';
  end if;
  if ((I0IO1I0I = I10O1110) and ((O11l1Il0 = I1OOO1OI) or (ieee_compliance = 0))) then
    OOO1IO01 := '1';
    O11l1Il0 := I1OOO1OI;
  else
    OOO1IO01 := '0';
  end if;
  if ((II11O1l1 = I10O1110) and ((l1010OI1 = I1OOO1OI) or (ieee_compliance = 0))) then
    OOl000IO := '1';
    l1010OI1 := I1OOO1OI;
  else
    OOl000IO := '0';
  end if;
  if ((O111O1l0 = I10O1110) and ((Olll0I0I = I1OOO1OI) or (ieee_compliance = 0))) then
    O0I0l100 := '1';
    Olll0I0I := I1OOO1OI;
  else
    O0I0l100 := '0';
  end if;
  if ((O0I11lO1 = I10O1110) and ((l110IO01 = I1OOO1OI) or (ieee_compliance = 0))) then
    lOIOI11I := '1';
    l110IO01 := I1OOO1OI;
  else
    lOIOI11I := '0';
  end if;
  if ((I0OllO01 = I10O1110) and ((l0011Ol0 = I1OOO1OI) or (ieee_compliance = 0))) then
    OOl0lll1 := '1';
    l0011Ol0 := I1OOO1OI;
  else
    OOl0lll1 := '0';
  end if;
  if ((lI10O00l = I10O1110) and ((O1I01l1O = I1OOO1OI) or (ieee_compliance = 0))) then
    lll1O1I1 := '1';
    O1I01l1O := I1OOO1OI;
  else
    lll1O1I1 := '0';
  end if;
  if ((lOOO1O10 = I10O1110) and ((OOIllOOl = I1OOO1OI) or (ieee_compliance = 0))) then
    OlO101Ol := '1';
    OOIllOOl := I1OOO1OI;
  else
    OlO101Ol := '0';
  end if;

  -- detect infinity inputs
  if ((OII0OO00 = lO11O011) and ((I0OOOO0I = I1OOO1OI) or (ieee_compliance = 0))) then
    II10OOO1 := '1';
    I0OOOO0I := I1OOO1OI;
  else 
    II10OOO1 := '0';
  end if;
  if ((I0IO1I0I = lO11O011) and ((O11l1Il0 = I1OOO1OI) or (ieee_compliance = 0))) then
    l0l0IIOI := '1';
    O11l1Il0 := I1OOO1OI;
  else 
    l0l0IIOI := '0';
  end if;
  if ((II11O1l1 = lO11O011) and ((l1010OI1 = I1OOO1OI) or (ieee_compliance = 0))) then
    l000O1O1 := '1';
    l1010OI1 := I1OOO1OI;
  else 
    l000O1O1 := '0';
  end if;
  if ((O111O1l0 = lO11O011) and ((Olll0I0I = I1OOO1OI) or (ieee_compliance = 0))) then
    O111l1ll := '1';
    Olll0I0I := I1OOO1OI;
  else 
    O111l1ll := '0';
  end if;
  if ((O0I11lO1 = lO11O011) and ((l110IO01 = I1OOO1OI) or (ieee_compliance = 0))) then
    I0OIO0II := '1';
    l110IO01 := I1OOO1OI;
  else 
    I0OIO0II := '0';
  end if;
  if ((I0OllO01 = lO11O011) and ((l0011Ol0 = I1OOO1OI) or (ieee_compliance = 0))) then
    I00O0l01 := '1';
    l0011Ol0 := I1OOO1OI;
  else 
    I00O0l01 := '0';
  end if;
  if ((lI10O00l = lO11O011) and ((O1I01l1O = I1OOO1OI) or (ieee_compliance = 0))) then
    l1I11O1O := '1';
    O1I01l1O := I1OOO1OI;
  else 
    l1I11O1O := '0';
  end if;
  if ((lOOO1O10 = lO11O011) and ((OOIllOOl = I1OOO1OI) or (ieee_compliance = 0))) then
    O00O10O0 := '1';
    OOIllOOl := I1OOO1OI;
  else 
    O00O10O0 := '0';
  end if;

  -- detect the nan inputs
  if ((OII0OO00 = lO11O011) and (I0OOOO0I /= I1OOO1OI) and (ieee_compliance = 1)) then
    IIOO00Ol := '1';
  else
    IIOO00Ol := '0';
  end if;
  if ((I0IO1I0I = lO11O011) and (O11l1Il0 /= I1OOO1OI) and (ieee_compliance = 1)) then
    IOlI1111 := '1';
  else
    IOlI1111 := '0';
  end if;
  if ((II11O1l1 = lO11O011) and (l1010OI1 /= I1OOO1OI) and (ieee_compliance = 1)) then
    lI01111O := '1';
  else
    lI01111O := '0';
  end if;
  if ((O111O1l0 = lO11O011) and (Olll0I0I /= I1OOO1OI) and (ieee_compliance = 1)) then
    llIO1OO1 := '1';
  else
    llIO1OO1 := '0';
  end if;
  if ((O0I11lO1 = lO11O011) and (l110IO01 /= I1OOO1OI) and (ieee_compliance = 1)) then
    O0IOIOOO := '1';
  else
    O0IOIOOO := '0';
  end if;
  if ((I0OllO01 = lO11O011) and (l0011Ol0 /= I1OOO1OI) and (ieee_compliance = 1)) then
    l0O0001O := '1';
  else
    l0O0001O := '0';
  end if;
  if ((lI10O00l = lO11O011) and (O1I01l1O /= I1OOO1OI) and (ieee_compliance = 1)) then
    OI0OOO0I := '1';
  else
    OI0OOO0I := '0';
  end if;
  if ((lOOO1O10 = lO11O011) and (OOIllOOl /= I1OOO1OI) and (ieee_compliance = 1)) then
    O1I10IO1 := '1';
  else
    O1I10IO1 := '0';
  end if;
  
  -- build mantissas
  -- Detect the denormal input case
  if ((OII0OO00 = I10O1110) and (I0OOOO0I /= I1OOO1OI) and (ieee_compliance = 1)) then
    -- Mantissa of denormal value
    OlI00101 := '0' & I0OOOO0I;
    OIO11IOO := '1';
    OII0OO00(0) := '1';                -- set exponent of denormal to minimum
  else
    -- Mantissa for normal number
    if (OII0OO00 = I10O1110) then
      OlI00101 := I0I101OI;
    else
      OlI00101 := '1' & I0OOOO0I;
    end if;
    OIO11IOO := '0';      
  end if;
  if ((I0IO1I0I = I10O1110) and (O11l1Il0 /= I1OOO1OI) and (ieee_compliance = 1)) then
    -- Mantissa of denormal value
    O0O01OO1 := '0' & O11l1Il0;
    I1O0lOII := '1';
    I0IO1I0I(0) := '1';
  else
    -- Mantissa for normal number
    if (I0IO1I0I = I10O1110) then
      O0O01OO1 := I0I101OI;
    else
      O0O01OO1 := '1' & O11l1Il0;
    end if;
    I1O0lOII := '0';      
  end if;
  if ((II11O1l1 = I10O1110) and (l1010OI1 /= I1OOO1OI) and (ieee_compliance = 1)) then
    -- Mantissa of denormal value
    IlOl0O1O := '0' & l1010OI1;
    O00OOl01 := '1';
    II11O1l1(0) := '1';
  else
    -- Mantissa for normal number
    if (II11O1l1 = I10O1110) then
      IlOl0O1O := I0I101OI;
    else
      IlOl0O1O := '1' & l1010OI1;
    end if;
    O00OOl01 := '0';      
  end if;
  if ((O111O1l0 = I10O1110) and (Olll0I0I /= I1OOO1OI) and (ieee_compliance = 1)) then
    -- Mantissa of denormal value
    I00001l0 := '0' & Olll0I0I;
    O01II1lI := '1';
    O111O1l0(0) := '1';
  else
    -- Mantissa for normal number
    if (O111O1l0 = I10O1110) then
      I00001l0 := I0I101OI;
    else
      I00001l0 := '1' & Olll0I0I;
    end if;
    O01II1lI := '0';      
  end if;
  if ((O0I11lO1 = I10O1110) and (l110IO01 /= I1OOO1OI) and (ieee_compliance = 1)) then
    -- Mantissa of denormal value
    l00l0l10 := '0' & l110IO01;
    O00I0Ol1 := '1';
    O0I11lO1(0) := '1';
  else
    -- Mantissa for normal number
    if (O0I11lO1 = I10O1110) then
      l00l0l10 := I0I101OI;
    else
      l00l0l10 := '1' & l110IO01;
    end if;
    O00I0Ol1 := '0';      
  end if;
  if ((I0OllO01 = I10O1110) and (l0011Ol0 /= I1OOO1OI) and (ieee_compliance = 1)) then
    -- Mantissa of denormal value
    l0l10l0l := '0' & l0011Ol0;
    O1l000I0 := '1';
    I0OllO01(0) := '1';
  else
    -- Mantissa for normal number
    if (I0OllO01 = I10O1110) then
      l0l10l0l := I0I101OI;
    else
      l0l10l0l := '1' & l0011Ol0;
    end if;
    O1l000I0 := '0';      
  end if;
  if ((lI10O00l = I10O1110) and (O1I01l1O /= I1OOO1OI) and (ieee_compliance = 1)) then
    -- Mantissa of denormal value
    l010l000 := '0' & O1I01l1O;
    OO0O1111 := '1';
    lI10O00l(0) := '1';
  else
    -- Mantissa for normal number
    if (lI10O00l = I10O1110) then
      l010l000 := I0I101OI;
    else
      l010l000 := '1' & O1I01l1O;
    end if;
    OO0O1111 := '0';      
  end if;
  if ((lOOO1O10 = I10O1110) and (OOIllOOl /= I1OOO1OI) and (ieee_compliance = 1)) then
    -- Mantissa of denormal value
    OO1O01OI := '0' & OOIllOOl;
    lOO000II := '1';
    lOOO1O10(0) := '1';
  else
    -- Mantissa for normal number
    if (lOOO1O10 = I10O1110) then
      OO1O01OI := I0I101OI;
    else
      OO1O01OI := '1' & OOIllOOl;
    end if;
    lOO000II := '0';      
  end if;
  -- calculate the internal exponents
  -- For multiplication, the exponents are computed as the sum of the
  -- operand exponents
  if (OII0OO00 = 0 or I0IO1I0I = 0) then
    O11O101I := (others => '0');
  else
    O11O101I := ("00"&OII0OO00) + ("00"&I0IO1I0I);
  end if;
  if (II11O1l1 = 0 or O111O1l0 = 0) then
    O0Ol1l1l := (others => '0');
  else
    O0Ol1l1l := ("00"&II11O1l1) + ("00"&O111O1l0);
  end if;
  if (O0I11lO1 = 0 or I0OllO01 = 0) then
    II10l0O0 := (others => '0');
  else
    II10l0O0 := ("00"&O0I11lO1) + ("00"&I0OllO01);
  end if;
  if (lI10O00l = 0 or lOOO1O10 = 0) then
    O00I1lOO := (others => '0');
  else
    O00I1lOO := ("00"&lI10O00l) + ("00"&lOOO1O10);
  end if;

  O1l10l01 := (O01l0I11 or OOO1IO01);
  l1O100O0 := (OOl000IO or O0I0l100);
  OO1II1I1 := (lOIOI11I or OOl0lll1);
  O0Ol01I1 := (lll1O1I1 or OlO101Ol);
    
  -- Identify and treat special input values

  -- Rule 1.
  if (IIOO00Ol = '1' or IOlI1111 = '1' or lI01111O = '1' or llIO1OO1 = '1' or O0IOIOOO = '1'
      or l0O0001O = '1' or OI0OOO0I = '1'or O1I10IO1 = '1') then
    -- one of the inputs is a NAN       --> the output must be an NAN
    OIl1001l := IIOO1OI0;
    l0Ol0OOI(2) := '1';
    if (ieee_compliance = 0) then
      l0Ol0OOI(1) := '1';
    else
      l0Ol0OOI(1) := '0';
    end if;

  --
  -- Infinity Inputs
  -- Rule 2.1
  --  any combination of infinity and zero in the inputs of a product term.
  elsif ((II10OOO1 = '1' and OOO1IO01 = '1') or (l0l0IIOI = '1' and O01l0I11 = '1') or
         (l000O1O1 = '1' and O0I0l100 = '1') or (O111l1ll = '1' and OOl000IO = '1') or
         (I0OIO0II = '1' and OOl0lll1 = '1') or (I00O0l01 = '1' and lOIOI11I = '1') or
         (l1I11O1O = '1' and OlO101Ol = '1') or (O00O10O0 = '1' and lll1O1I1 = '1')) then
    OIl1001l := IIOO1OI0;
    l0Ol0OOI(2) := '1';
    if (ieee_compliance = 0) then
      l0Ol0OOI(1) := '1';
    else
      l0Ol0OOI(1) := '0';
    end if;

  -- Leave the decision about 2.2 and 3 for after the multiplication is done

  -- Zero inputs 
  elsif (O1l10l01 = '1' and l1O100O0 = '1' and 
         OO1II1I1 = '1' and O0Ol01I1 = '1' and (ieee_compliance = 1)) then
    I11010I0 := (I0O1O10l xor lIO0OIO1);
    O11O0IO1 := (O0I1O0OO xor I0101O0I);
    llII1II1 := (lI0O1O11 xor lOllOlI1);
    l0OIOl1I := (O0O10OIl xor O1101IlO);
    OIl1001l := (others => '0');
    if (I11010I0 = O11O0IO1 and O11O0IO1 = llII1II1 and llII1II1 = l0OIOl1I) then
      OIl1001l((exp_width + sig_width)) := I11010I0;
    elsif (rnd = "011") then
      OIl1001l((exp_width + sig_width)) := '1';
    else
      OIl1001l((exp_width + sig_width)) := '0';
    end if;
    l0Ol0OOI(0) := '1';

  --
  -- Normal Inputs
  --
  else                                          
    -- generate the product terms
    l0OOO1l1 := (OlI00101 * O0O01OO1);
    I1OlI0Ol := (IlOl0O1O * I00001l0);
    OlOIOIO0 := (l00l0l10 * l0l10l0l);
    l10IIIO0 := (l010l000 * OO1O01OI);
    I1llOI11 := "00"&l0OOO1l1&conv_std_logic_vector(0, ((6*sig_width+5+3)-2*sig_width-5));
    I011O0l1 := "00"&I1OlI0Ol&conv_std_logic_vector(0, ((6*sig_width+5+3)-2*sig_width-5));
    O0IOlI0O := "00"&OlOIOIO0&conv_std_logic_vector(0, ((6*sig_width+5+3)-2*sig_width-5));
    OIOl00O1 := "00"&l10IIIO0&conv_std_logic_vector(0, ((6*sig_width+5+3)-2*sig_width-5));

    I11010I0 := (I0O1O10l xor lIO0OIO1);
    O11O0IO1 := (O0I1O0OO xor I0101O0I);
    llII1II1 := (lI0O1O11 xor lOllOlI1);
    l0OIOl1I := (O0O10OIl xor O1101IlO);

    -- the following variables are used to keep track of invalid operations
    if (ieee_compliance = 1) then
      l1OOO0O1 := ((II10OOO1 and OOO1IO01) or (l0l0IIOI and O01l0I11)); 
      lO01101O := ((l000O1O1 and O0I0l100) or (O111l1ll and OOl000IO));
      IO0OO10I := ((I0OIO0II and OOl0lll1) or (I00O0l01 and lOIOI11I));
      OO00O1OO := ((l1I11O1O and OlO101Ol) or (O00O10O0 and lll1O1I1));
    else
      l1OOO0O1 := '0';
      lO01101O := '0';
      IO0OO10I := '0';
      OO00O1OO := '0';
    end if;
    IO1O0000 := l1OOO0O1 or lO01101O or IO0OO10I or OO00O1OO;

    if (IO1O0000 = '1') then
        l0Ol0OOI(2) := '1';
        OIl1001l := IIOO1OI0;                  -- NaN
        if (ieee_compliance = 0) then
          l0Ol0OOI(1) := '1';
        else
          l0Ol0OOI(1) := '0';
        end if;
    else
      -- Detect the case of infinity in a product
      -- Normalize the intermediate mantissas of partial prods
      while ( (I1llOI11(((6*sig_width+5+3)-2)-2) = '0') and (O11O101I /= 0) ) loop
        O11O101I := O11O101I - 1;
        I1llOI11 := I1llOI11(I1llOI11'length-2 downto 0) & '0';
      end loop;
      while ( (I011O0l1(((6*sig_width+5+3)-2)-2) = '0') and (O0Ol1l1l /= 0) ) loop
        O0Ol1l1l := O0Ol1l1l - 1;
        I011O0l1 := I011O0l1(I011O0l1'length-2 downto 0) & '0';
      end loop;
      while ( (O0IOlI0O(((6*sig_width+5+3)-2)-2) = '0') and (II10l0O0 /= 0) ) loop
        II10l0O0 := II10l0O0 - 1;
        O0IOlI0O := O0IOlI0O(O0IOlI0O'length-2 downto 0) & '0';
      end loop;
      while ( (OIOl00O1(((6*sig_width+5+3)-2)-2) = '0') and (O00I1lOO /= 0) ) loop
        O00I1lOO := O00I1lOO - 1;
        OIOl00O1 := OIOl00O1(OIOl00O1'length-2 downto 0) & '0';
      end loop;

      Ol10000O := '0';
      IOI00O10 := '0';
      OOIO0lO0 := '0';
      I1000OO1 := '0';
      if ((II10OOO1 = '1') or (l0l0IIOI = '1')) then
        Ol10000O := '1';
      end if;
      if ((l000O1O1 = '1') or (O111l1ll = '1')) then
        IOI00O10 := '1';
      end if;
      if ((I0OIO0II = '1') or (I00O0l01 = '1')) then
        OOIO0lO0 := '1';
      end if;
      if ((l1I11O1O = '1') or (O00O10O0 = '1')) then
        I1000OO1 := '1';
      end if;
      I00l100l := II10OOO1 or l0l0IIOI or l000O1O1 or O111l1ll or
                        I0OIO0II or I00O0l01 or l1I11O1O or O00O10O0;
      if (Ol10000O='1' or IOI00O10='1' or OOIO0lO0='1' or I1000OO1='1')  then
        l0Ol0OOI(1) := '1';
        l0Ol0OOI(4) := not (I00l100l);
        l0Ol0OOI(5) := l0Ol0OOI(4);
        OIl1001l := OI11lO10;
        OIl1001l((exp_width + sig_width)) := (Ol10000O and I11010I0) or
                            (IOI00O10 and O11O0IO1) or
                            (OOIO0lO0 and llII1II1) or
                            (I1000OO1 and l0OIOl1I);
        -- Watch out for Inf-Inf !
        if ( (Ol10000O='1' and IOI00O10='1' and I11010I0/=O11O0IO1) or 
             (Ol10000O='1' and OOIO0lO0='1' and I11010I0/=llII1II1) or 
             (Ol10000O='1' and I1000OO1='1' and I11010I0/=l0OIOl1I) or 
             (IOI00O10='1' and OOIO0lO0='1' and O11O0IO1/=llII1II1) or 
             (IOI00O10='1' and I1000OO1='1' and O11O0IO1/=l0OIOl1I) or 
             (OOIO0lO0='1' and I1000OO1='1' and llII1II1/=l0OIOl1I) ) then
          l0Ol0OOI(2) := '1';
          l0Ol0OOI(4) := '0';
          l0Ol0OOI(5) := '0';
          OIl1001l := IIOO1OI0;                  -- NaN
          if (ieee_compliance = 0) then
            l0Ol0OOI(1) := '1';
          else
            l0Ol0OOI(1) := '0';
          end if;
        end if;

      else
        -- continue with addition of products
          if ((I11010I0&O11O101I&I1llOI11) = 
              ((not O11O0IO1)&O0Ol1l1l&I011O0l1)) then
            O11O101I := (others => '0');
            I1llOI11 := (others => '0');
            O0Ol1l1l := (others => '0');
            I011O0l1 := (others => '0');
          end if;
          if ((I11010I0&O11O101I&I1llOI11) = 
              ((not llII1II1)&II10l0O0&O0IOlI0O)) then
            O11O101I := (others => '0');
            I1llOI11 := (others => '0');
            II10l0O0 := (others => '0');
            O0IOlI0O := (others => '0');
          end if;
          if ((I11010I0&O11O101I&I1llOI11) = 
              ((not l0OIOl1I)&O00I1lOO&OIOl00O1)) then
            O11O101I := (others => '0');
            I1llOI11 := (others => '0');
            O00I1lOO := (others => '0');
            OIOl00O1 := (others => '0');
          end if;
          if ((O11O0IO1&O0Ol1l1l&I011O0l1) = 
              ((not llII1II1)&II10l0O0&O0IOlI0O)) then
            O0Ol1l1l := (others => '0');
            I011O0l1 := (others => '0');
            II10l0O0 := (others => '0');
            O0IOlI0O := (others => '0');
          end if;
          if ((O11O0IO1&O0Ol1l1l&I011O0l1) = 
              ((not l0OIOl1I)&O00I1lOO&OIOl00O1)) then
            O0Ol1l1l := (others => '0');
            I011O0l1 := (others => '0');
            O00I1lOO := (others => '0');
            OIOl00O1 := (others => '0');
          end if;
          if ((llII1II1&II10l0O0&O0IOlI0O) = 
              ((not l0OIOl1I)&O00I1lOO&OIOl00O1)) then
            II10l0O0 := (others => '0');
            O0IOlI0O := (others => '0');
            O00I1lOO := (others => '0');
            OIOl00O1 := (others => '0');
          end if;

        -- compute the signal that defines the large and small FP values
        lO0OOOIl := '0';
        if ((O11O101I&I1llOI11) < (O0Ol1l1l&I011O0l1)) then
          lO0OOOIl := '1';
        end if;
        if (lO0OOOIl = '1') then
          O011O1I0 := O0Ol1l1l;
          lO0ll1O1 := I011O0l1;
          l10O100O := O11O0IO1;
          OI1000I0 := O11O101I;
          OO011IO0 := I1llOI11;
          O11l0O0O := I11010I0;
        else
          O011O1I0 := O11O101I;
          lO0ll1O1 := I1llOI11;
          l10O100O := I11010I0;
          OI1000I0 := O0Ol1l1l;
          OO011IO0 := I011O0l1;
          O11l0O0O := O11O0IO1;
        end if;
        l1O100I0 := '0';
        if ((II10l0O0&O0IOlI0O) < (O00I1lOO&OIOl00O1)) then
          l1O100I0 := '1';
        end if;
        if (l1O100I0 = '1') then
          OlI1O0O0 := O00I1lOO;
          O11lO00O := OIOl00O1;
          O1l100OO := l0OIOl1I;
          Il10l0OO := II10l0O0;
          II01l1O1 := O0IOlI0O;
          OOIIOO0O := llII1II1;
        else
          OlI1O0O0 := II10l0O0;
          O11lO00O := O0IOlI0O;
          O1l100OO := llII1II1;
          Il10l0OO := O00I1lOO;
          II01l1O1 := OIOl00O1;
          OOIIOO0O := l0OIOl1I;
        end if;
        OIO0I111 := '0';
        if ((O011O1I0&lO0ll1O1) < (OlI1O0O0&O11lO00O)) then
          OIO0I111 := '1';
        end if;
        if (OIO0I111 = '1') then
          O1O0lOOO := OlI1O0O0;
          llOIOl1I := O11lO00O;
          OI01lO00 := O1l100OO;
          O0111O11 := O011O1I0;
          OO1101OO := lO0ll1O1;
          OII1I001 := l10O100O;
        else
          O1O0lOOO := O011O1I0;
          llOIOl1I := lO0ll1O1;
          OI01lO00 := l10O100O;
          O0111O11 := OlI1O0O0;
          OO1101OO := O11lO00O;
          OII1I001 := O1l100OO;
        end if;
        O01l0OI0 := '0';
        if ((OI1000I0&OO011IO0) < (Il10l0OO&II01l1O1)) then
          O01l0OI0 := '1';
        end if;
        if (O01l0OI0 = '1') then
          O1O00OII := Il10l0OO;
          l0010OO1 := II01l1O1;
          II101lI0 := OOIIOO0O;
          OI0Ol0OO := OI1000I0;
          I01O1OI1 := OO011IO0;
          l10OlIl0 := O11l0O0O;
        else
          O1O00OII := OI1000I0;
          l0010OO1 := OO011IO0;
          II101lI0 := O11l0O0O;
          OI0Ol0OO := Il10l0OO;
          I01O1OI1 := II01l1O1;
          l10OlIl0 := OOIIOO0O;
        end if;

        -- Shift right by O0I0lO1O/2/3 the middle and min products.
        -- Alignment phase
        I1O11lIO := OO1101OO;
        if (DW_OO10OOO1 > 0) then
          OIlOO101 := or_reduce(OO1101OO(DW_OO10OOO1 downto 0));
          I1O11lIO(DW_OO10OOO1 downto 0) := (others => '0');
        else
          OIlOO101 := '0';
        end if;
        O0I0lO1O := O1O0lOOO - O0111O11;
        while ( (I1O11lIO(I1O11lIO'length-1 downto DW_OO10OOO1+1) /= O10I0l10(I1O11lIO'length-1 downto DW_OO10OOO1+1)) and (O0I0lO1O /= I10O1110) ) loop
          I1O11lIO(I1O11lIO'length-1 downto DW_OO10OOO1) := 
                          '0'&I1O11lIO(I1O11lIO'length-1 
                                                     downto DW_OO10OOO1+1);
          OIlOO101 := I1O11lIO(DW_OO10OOO1) or OIlOO101;
          O0I0lO1O := O0I0lO1O - 1;
        end loop;
        O11IOO1I := not or_reduce(I1O11lIO(I1O11lIO'length-1 downto DW_OO10OOO1+1));
        l0IlO0O1 := or_reduce(I1O11lIO(I1O11lIO'length-1 downto DW_OO10OOO1+1)) and OIlOO101;
        I1O11lIO(DW_OO10OOO1) := OIlOO101;
        l0O111OO := l0010OO1;
        if (DW_OO10OOO1 > 0) then
          l01010ll := or_reduce(l0010OO1(DW_OO10OOO1 downto 0));
          l0O111OO(DW_OO10OOO1 downto 0) := (others => '0');
        else
          l01010ll := '0';
        end if;
        OOI1O00O := O1O0lOOO - O1O00OII;
        while ( (l0O111OO(l0O111OO'length-1 downto DW_OO10OOO1+1) /= O10I0l10(l0O111OO'length-1 downto DW_OO10OOO1+1)) and (OOI1O00O /= I10O1110) ) loop
          l0O111OO(l0O111OO'length-1 downto DW_OO10OOO1) := 
                         '0'&l0O111OO(l0O111OO'length-1 
                                                     downto DW_OO10OOO1+1);
          l01010ll := l0O111OO(DW_OO10OOO1) or l01010ll;
          OOI1O00O := OOI1O00O - 1;
        end loop;
        OlOII011 := not or_reduce(l0O111OO(l0O111OO'length-1 downto DW_OO10OOO1+1));
        OlOl1OO0 := or_reduce(l0O111OO(l0O111OO'length-1 downto DW_OO10OOO1+1)) and l01010ll;
        l0O111OO(DW_OO10OOO1) := l01010ll;
        O1l0O100 := I01O1OI1;
        if (DW_OO10OOO1 > 0) then
          OO1llIO1 := or_reduce(I01O1OI1(DW_OO10OOO1 downto 0));
          O1l0O100(DW_OO10OOO1 downto 0) := (others => '0');
        else
          OO1llIO1 := '0';
        end if;
        O1OlO001 := O1O0lOOO - OI0Ol0OO;
        while ( (O1l0O100(O1l0O100'length-1 downto DW_OO10OOO1+1) /= O10I0l10(O1l0O100'length-1 downto DW_OO10OOO1+1)) and (O1OlO001 /= I10O1110) ) loop
          O1l0O100(O1l0O100'length-1 downto DW_OO10OOO1) := 
                               '0' & O1l0O100(O1l0O100'length-1 
                                                     downto DW_OO10OOO1+1);
          OO1llIO1 := O1l0O100(DW_OO10OOO1) or OO1llIO1;
          O1OlO001 := O1OlO001 - 1;
        end loop;
        O1l0O100(DW_OO10OOO1) := OO1llIO1;

        if (l0IlO0O1 = '1' or OlOl1OO0 = '1') then 
          O1l0O100(DW_OO10OOO1) := '0';
          -- AFT - 10/2011
	  -- when both middle products are partially shifted off range
          -- we want to keep the stk bit of the largest one
          if (l0IlO0O1 = '1' and OlOl1OO0 = '1') then 
            if ((O0111O11&OO1101OO) < (O1O00OII&l0010OO1)) then
              I1O11lIO(DW_OO10OOO1) := '0';
            else
              l0O111OO(DW_OO10OOO1) := '0';
            end if;
          end if;
        else
          if ((OIlOO101 = '1' and O11IOO1I = '1') or 
              (l01010ll = '1' and OlOII011 = '1')) then 
            O1l0O100(DW_OO10OOO1) := '0';
            if ((OIlOO101 = '1' and O11IOO1I = '1') and 
                (l01010ll = '1' and OlOII011 = '1')) then 
              if ((O0111O11&OO1101OO) < (O1O00OII&l0010OO1)) then
                I1O11lIO(DW_OO10OOO1) := '0';
              else
                l0O111OO(DW_OO10OOO1) := '0';
              end if;
            end if;
          end if;
        end if;
          
        -- Compute internal addition result
        O111111l := ('0'&llOIOl1I);
        if (OI01lO00 /= OII1I001) then
          OO10Il01 := not ('0'&I1O11lIO) + 1;
        else
          OO10Il01 := ('0'&I1O11lIO);
        end if;
        if (OI01lO00 /= II101lI0) then
          l0IOIO11 := not ('0'&l0O111OO) + 1;
        else
          l0IOIO11 := ('0'&l0O111OO);
        end if;
        if (OI01lO00 /= l10OlIl0) then
          IOOO1I01 := not ('0'&O1l0O100) + 1;
        else
          IOOO1I01 := ('0'&O1l0O100);
        end if;
        II1lO1lO := O111111l+OO10Il01+l0IOIO11+IOOO1I01;

        -- Processing after addition
        IO1110IO := II1lO1lO(((6*sig_width+5+3)-2)+1);      
        if (IO1110IO = '1') then
          OIOOl1OI := not II1lO1lO(((6*sig_width+5+3)-2) downto 0) + 1;
        else
          OIOOl1OI := II1lO1lO(((6*sig_width+5+3)-2) downto 0);
        end if;
        OIOOl1OI(0) := '0'; -- eliminates the stick bit from OIOOl1OI
        if (II1lO1lO /= 0) then
          I10OIO1I := IO1110IO xor OI01lO00;
        else
          I10OIO1I := '0';
        end if;
 
        if (or_reduce(OIOOl1OI(((6*sig_width+5+3)-2) downto sig_width+5)) = '0' and OO1llIO1 = '1') then
            OIOOl1OI := I01O1OI1;
            if (OIOOl1OI = O10I0l10) then I10OIO1I := '0';
                               else I10OIO1I := l10OlIl0;
            end if;
            I0I0110O := OI0Ol0OO;
            OO1llIO1 := '0';
        else
          I0I0110O := O1O0lOOO;
        end if;

        -- Normalize the Mantissa for computation overflow case.
        IOIO101I := '0';
        if (OIOOl1OI(((6*sig_width+5+3)-2)) = '1') then
          I0I0110O := I0I0110O + 1;
          IOIO101I := OIOOl1OI(DW_OO10OOO1);
          OIOOl1OI := '0' & OIOOl1OI(OIOOl1OI'length-1 downto 1);
          OIOOl1OI(0) := OIOOl1OI(DW_OO10OOO1) or IOIO101I;
        end if;
        if (OIOOl1OI(((6*sig_width+5+3)-2)-1) = '1') then
          I0I0110O := I0I0110O + 1;
          IOIO101I := OIOOl1OI(DW_OO10OOO1);
          OIOOl1OI := '0' & OIOOl1OI(OIOOl1OI'length-1 downto 1);
          OIOOl1OI(0) := OIOOl1OI(DW_OO10OOO1) or IOIO101I;
       end if;
        if (OIOOl1OI(((6*sig_width+5+3)-2)-2) = '1') then
          I0I0110O := I0I0110O + 1;
          IOIO101I := OIOOl1OI(DW_OO10OOO1);
          OIOOl1OI := '0' & OIOOl1OI(OIOOl1OI'length-1 downto 1);
          OIOOl1OI(0) := OIOOl1OI(DW_OO10OOO1) or IOIO101I;
        end if; 

        -- Normalize the Mantissa for leading zero case.
        while ( (OIOOl1OI(((6*sig_width+5+3)-2)-3) = '0') and (I0I0110O > ((2 ** (exp_width-1)) - 1)) ) loop
          I0I0110O := I0I0110O - 1;
          OIOOl1OI := OIOOl1OI(OIOOl1OI'length-2 downto 0) & '0';
        end loop;
 
        while ( OIOOl1OI /= O10I0l10 and (I0I0110O <= ((2 ** (exp_width-1)) - 1)) and
                (ieee_compliance = 1)) loop
          I0I0110O := I0I0110O + 1;
          IOIO101I := OIOOl1OI(DW_OO10OOO1) or IOIO101I;
          OIOOl1OI := '0' & OIOOl1OI(OIOOl1OI'length-1 downto 1);
        end loop;

        -- Round OIOOl1OI according to the rounding mode (rnd).
        Il110l11 := OIOOl1OI((((6*sig_width+5+3)-2)-3-sig_width));
        Il001001 := OIOOl1OI(((((6*sig_width+5+3)-2)-3-sig_width) - 1));
        O0l10OOI := or_reduce(OIOOl1OI(((((6*sig_width+5+3)-2)-3-sig_width) - 1)-1 downto 0)) or OIlOO101 or l01010ll or OO1llIO1 or IOIO101I;
        l1000O1I := Ol1l110O(rnd, I10OIO1I, Il110l11, Il001001, O0l10OOI);
        if (l1000O1I(0) = '1') then
          OIOOl1OI := OIOOl1OI + ('1' & conv_std_logic_vector(0,(((6*sig_width+5+3)-2)-3-sig_width)));
        end if;   

        -- Normalize the Mantissa for overflow case after rounding.
        if ( (OIOOl1OI(((6*sig_width+5+3)-2)-2) = '1') ) then
          I0I0110O := I0I0110O + 1;
          OIOOl1OI := '0' & OIOOl1OI(OIOOl1OI'length-1 downto 1);
        end if;
        
        -- test if the output of the rounding unit is still not normalized
        if ((OIOOl1OI(((6*sig_width+5+3)-2) downto ((6*sig_width+5+3)-2)-3) = "0000") or (I0I0110O<=((2 ** (exp_width-1)) - 1))) then
          -- result is tiny
          if (ieee_compliance = 1) then
            OIl1001l := I10OIO1I & I10O1110 & OIOOl1OI((((6*sig_width+5+3)-2)-4) downto (((6*sig_width+5+3)-2)-3-sig_width));
            l0Ol0OOI(5) := l1000O1I(1);
            l0Ol0OOI(3) := l1000O1I(1) or 
                                           or_reduce(OIOOl1OI(((6*sig_width+5+3)-2) downto (((6*sig_width+5+3)-2)-3-sig_width)));
            if (OIOOl1OI((((6*sig_width+5+3)-2)-4) downto (((6*sig_width+5+3)-2)-3-sig_width)) = I1OOO1OI) then
              l0Ol0OOI(0) := '1'; 
              if (l1000O1I(1) = '0') then
                -- result is an exact zero
                if (rnd = "011") then
                  OIl1001l((exp_width + sig_width)) := '1';
                else
                  OIl1001l((exp_width + sig_width)) := '0';
                end if;
              end if;
            end if;
          else
            -- when denormals are not used  -> the output becomes zero or minnorm
            l0Ol0OOI(5) := l1000O1I(1) or 
                                           or_reduce(OIOOl1OI(((6*sig_width+5+3)-2) downto (((6*sig_width+5+3)-2)-3-sig_width)));
            l0Ol0OOI(3) := l1000O1I(1) or 
                                           or_reduce(OIOOl1OI(((6*sig_width+5+3)-2) downto (((6*sig_width+5+3)-2)-3-sig_width))); 
            if (((rnd = "011" and I10OIO1I = '1') or
                 (rnd = "010" and I10OIO1I = '0') or
                 rnd = "101") and (OIOOl1OI(((6*sig_width+5+3)-2) downto (((6*sig_width+5+3)-2)-3-sig_width)) /= I10ll1O0)) then
              -- minnorm
              OIl1001l := I10OIO1I & lOII1O0l & I1OOO1OI;
              l0Ol0OOI(0) := '0';
            else   -- zero
              l0Ol0OOI(0) := '1';
              if (l0Ol0OOI(5) = '1') then
                OIl1001l := I10OIO1I & I10O1110 & I1OOO1OI;
              else
                OIl1001l := (others => '0');
                if (rnd = "011") then
                  OIl1001l := '1' & I10O1110 & I1OOO1OI;
                else
                  OIl1001l := '0' & I10O1110 & I1OOO1OI;
                end if;
              end if;
            end if;
          end if;
        else
          --
          -- Huge
          --
          if (I0I0110O >= conv_std_logic_vector(((((2 ** (exp_width-1)) - 1) * 2) + 1)+((2 ** (exp_width-1)) - 1),I0I0110O'length)) then
            l0Ol0OOI(4) := '1';
            l0Ol0OOI(5) := '1';
            if (l1000O1I(2) = '1') then
              -- Infinity
              OIOOl1OI(((6*sig_width+5+3)-2)-3 downto (((6*sig_width+5+3)-2)-3-sig_width)) := (others => '0');
              I0I0110O := conv_std_logic_vector(((((2 ** (exp_width-1)) - 1) * 2) + 1),I0I0110O'length);
              l0Ol0OOI(1) := '1';
            else
              -- MaxNorm
              I0I0110O := conv_std_logic_vector(((((2 ** (exp_width-1)) - 1) * 2) + 1),I0I0110O'length) - 1;
              OIOOl1OI((((6*sig_width+5+3)-2)-4) downto (((6*sig_width+5+3)-2)-3-sig_width)) := (others => '1');
            end if;
          else
              I0I0110O := I0I0110O - ((2 ** (exp_width-1)) - 1);
          end if;
          --
          -- Normal
          --
          l0Ol0OOI(5) := l0Ol0OOI(5) or l1000O1I(1);
          -- Reconstruct the floating point format.
          OIl1001l := I10OIO1I & I0I0110O(exp_width-1 downto 0) & OIOOl1OI((((6*sig_width+5+3)-2)-4) downto (((6*sig_width+5+3)-2)-3-sig_width));
  
        end if;  -- (OIOOl1OI(((6*sig_width+5+3)-2) downto ((6*sig_width+5+3)-2)-2) = "000")
      end if;
    end if;
  end if;  -- NaN input 

  O10O0I1O <= l0Ol0OOI;
  OO0IOOll <= OIl1001l;

end process MAIN_PROCESS;

--
-- purpose: process the output values
-- type   : combinational
SELECT_OUTPUT: process (a, b, c, d, e, f, g, h, rnd, z_temp1, OO0IOOll, 
                        status_int1, O10O0I1O)
begin
  if (Is_X(a) or Is_X(b) or Is_X(c) or Is_X(d) or Is_X(e) or 
      Is_X(f) or Is_X(g) or Is_X(h) or Is_X(rnd)) then
    status <= (others => 'X');
    z <= (others => 'X');
  else
     if (arch_type = 1) then
       status <= status_int1;
       z <= z_temp1;
     else
       status <= O10O0I1O;
       z <= OO0IOOll;
     end if;
  end if;
end process SELECT_OUTPUT;  

-- pragma translate_on  

end sim ;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

library dw02;

configuration DW_fp_dp4_cfg_sim of DW_fp_dp4 is
 for sim
  for U1: DW_fp_ifp_conv use configuration dw02.DW_fp_ifp_conv_cfg_sim; end for;
  for U2: DW_fp_ifp_conv use configuration dw02.DW_fp_ifp_conv_cfg_sim; end for;
  for U3: DW_fp_ifp_conv use configuration dw02.DW_fp_ifp_conv_cfg_sim; end for;
  for U4: DW_fp_ifp_conv use configuration dw02.DW_fp_ifp_conv_cfg_sim; end for;
  for U5: DW_fp_ifp_conv use configuration dw02.DW_fp_ifp_conv_cfg_sim; end for;
  for U6: DW_fp_ifp_conv use configuration dw02.DW_fp_ifp_conv_cfg_sim; end for;
  for U7: DW_fp_ifp_conv use configuration dw02.DW_fp_ifp_conv_cfg_sim; end for;
  for U8: DW_fp_ifp_conv use configuration dw02.DW_fp_ifp_conv_cfg_sim; end for;
  for U9: DW_ifp_mult use configuration dw02.DW_ifp_mult_cfg_sim; end for;
  for U10: DW_ifp_mult use configuration dw02.DW_ifp_mult_cfg_sim; end for;
  for U11: DW_ifp_mult use configuration dw02.DW_ifp_mult_cfg_sim; end for;
  for U12: DW_ifp_mult use configuration dw02.DW_ifp_mult_cfg_sim; end for;
  for U13: DW_ifp_addsub use configuration dw02.DW_ifp_addsub_cfg_sim; end for;
  for U14: DW_ifp_addsub use configuration dw02.DW_ifp_addsub_cfg_sim; end for;
  for U15: DW_ifp_addsub use configuration dw02.DW_ifp_addsub_cfg_sim; end for;
  for U16: DW_ifp_fp_conv use configuration dw02.DW_ifp_fp_conv_cfg_sim; end for;
 end for; -- sim
end DW_fp_dp4_cfg_sim;
-- pragma translate_on

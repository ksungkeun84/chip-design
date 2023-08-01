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
-- AUTHOR:    Alexandre F. Tenca, August 2006
--
-- VERSION:   VHDL Simulation Model - FP SUM4
--
-- DesignWare_version: cddd28ae
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--
-- ABSTRACT: Four-operand Floating-point Adder (SUM4)
--           Computes the addition of four FP numbers. The format of the FP
--           numbers is defined by the number of bits in the significand 
--           (sig_width) and the number of bits in the exponent (exp_width).
--           The total number of bits in each FP number is sig_width+exp_width+1.
--           The sign bit takes the place of the MS bit in the significand,
--           which is always 1 (unless the number is a denormal; a condition 
--           that can be detected testing the exponent value).
--           The outputs are a FP number and status flags with information about
--           special number representations and exceptions. 
--              parameters      valid values (defined in the DW manual)
--              ==========      ============
--              sig_width       significand f,  2 to 253 bits
--              exp_width       exponent e,     3 to 31 bits
--              ieee_compliance 0 or 1 (default 0)
--              arch_type       0 or 1 (default 0)
--
--              Input ports     Size & Description
--              ===========     ==================
--              a               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Input
--              b               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Input
--              c               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Input
--              d               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Input
--              rnd             3 bits
--                              rounding mode
--
--              Output ports    Size & Description
--              ===========     ==================
--              z               (sig_width + exp_width + 1) bits
--                              Floating-point Number -> a+b+c
--              status          byte
--                              info about FP result
--
-- MODIFIED:
--
---------------------------------------------------------------------------------

library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_misc.all;
use DWARE.DW_Foundation_arith.all;
use DWARE.DW_Foundation_comp_arith.all;

architecture sim of DW_fp_sum4 is
	
-- pragma translate_off


-- ll1lO01I function used in several FP components
function ll1lO01I (I0OO1101: std_logic_vector(2 downto 0);
                   Sign: std_logic;
                   I0OOOOOO: std_logic;
                   l111I0I1: std_logic;
                   O101lII0: std_logic) return std_logic_vector is
--*******************************
--  lOOOII0I has 4 bits:
--  lOOOII0I[0]
--  lOOOII0I[1]
--  lOOOII0I[2]
--  lOOOII0I[3]
--*******************************

--*******************************
--  Rounding increment equations
--  |
--    MODE | Equation   | Description
--    -----------------------------
--    even | l111I0I1&(I0OOOOOO|O101lII0)  | IEEE round to nearest (even)
--    zero | 0          | IEEE round to zero
--    +inf | S'&(l111I0I1|O101lII0) | IEEE round to positive infinity
--    -inf | S&(l111I0I1|O101lII0)  | IEEE round to negative infinity
--     up  | l111I0I1          | round to nearest (up)
--    away | (l111I0I1|O101lII0)    | round away from zero
-- *******************************
variable ll1lO01I : std_logic_vector (4-1 downto 0);
begin
  ll1lO01I(0) := '0';
  ll1lO01I(1) := l111I0I1 or O101lII0;
  ll1lO01I(2) := '0';
  ll1lO01I(3) := '0';
  case I0OO1101 is
    when "000" =>
      -- round to nearest (even) 
      ll1lO01I(0) := l111I0I1 and (I0OOOOOO or O101lII0);
      ll1lO01I(2) := '1';
      ll1lO01I(3) := '0';
    when "001" =>
      -- round to zero 
      ll1lO01I(0) := '0';
      ll1lO01I(2) := '0';
      ll1lO01I(3) := '0';
    when "010" =>
      -- round to positive infinity 
      ll1lO01I(0) := not Sign and (l111I0I1 or O101lII0);
      ll1lO01I(2) := not Sign;
      ll1lO01I(3) := not Sign;
    when "011" =>
      -- round to negative infinity 
      ll1lO01I(0) := Sign and (l111I0I1 or O101lII0);
      ll1lO01I(2) := Sign;
      ll1lO01I(3) := Sign;
    when "100" =>
      -- round to nearest (up)
      ll1lO01I(0) := l111I0I1;
      ll1lO01I(2) := '1';
      ll1lO01I(3) := '0';
    when "101" =>
      -- round away form 0  
      ll1lO01I(0) := l111I0I1 or O101lII0;
      ll1lO01I(2) := '1';
      ll1lO01I(3) := '1';
    when others =>
      ll1lO01I(0) := 'X';
      ll1lO01I(2) := 'X';
      ll1lO01I(3) := 'X';
  end case;
  return (ll1lO01I);
end function;                                    -- lOOOII0I function

-- Auxiliary function
function my_sll (a : in std_logic_vector; sh : in integer) return std_logic_vector is
variable b : std_logic_vector(a'range) := a;
variable count : integer := sh;
begin
  while (count > 0) loop
    b := b(b'length-2 downto 0) & '0';
    count := count - 1;
  end loop;
  return b;
end function;

-- extension of 2 operands, 3 extra MS bits and 2 bits of gap

signal status_int1, l0O01OIO : std_logic_vector(8    -1 downto 0);
signal z_temp1, IO10OIlO : std_logic_vector((exp_width + sig_width) downto 0);

-- Other signals used for simulation of the architecture when ieee_compliance=2

signal l0OOO110 : std_logic_vector(sig_width+2+exp_width+6 downto 0);
signal l1IIO0O1 : std_logic_vector(sig_width+2+exp_width+6 downto 0);
signal O1O10l10 : std_logic_vector(sig_width+2+exp_width+6 downto 0);
signal OO101IOO : std_logic_vector(sig_width+2+exp_width+6 downto 0);
signal O1I0OlO0 : std_logic_vector(sig_width+2+3+exp_width+1+6 downto 0); -- result of a+b = e
signal I0OOIllO : std_logic_vector(sig_width+2+3+exp_width+1+6 downto 0); -- result of c+d = f
signal Oll0110I : std_logic_vector(sig_width+2+3+sig_width+exp_width+1+1+6 downto 0); -- result of e+f

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
-- Simulation model for the case arch_type = 1
-----------------------------------------------------------------------

-- Instances of DW_fp_ifp_conv  -- format converters
  U1: DW_fp_ifp_conv generic map (sig_widthi => sig_width, 
                                  exp_widthi => exp_width, 
                                  sig_widtho => sig_width+2,
                                  exp_widtho => exp_width,
                                  use_denormal => ieee_compliance,
                                  use_1scmpl => 0)
          port map ( a => a, z => l0OOO110 );
  U2: DW_fp_ifp_conv generic map (sig_widthi => sig_width, 
                                  exp_widthi => exp_width, 
                                  sig_widtho => sig_width+2,
                                  exp_widtho => exp_width,
                                  use_denormal => ieee_compliance,
                                  use_1scmpl => 0)
          port map ( a => b, z => l1IIO0O1 );
  U3: DW_fp_ifp_conv generic map (sig_widthi => sig_width, 
                                  exp_widthi => exp_width, 
                                  sig_widtho => sig_width+2,
                                  exp_widtho => exp_width,
                                  use_denormal => ieee_compliance,
                                  use_1scmpl => 0)
          port map ( a => c, z => O1O10l10 );
  U4: DW_fp_ifp_conv generic map (sig_widthi => sig_width, 
                                  exp_widthi => exp_width, 
                                  sig_widtho => sig_width+2,
                                  exp_widtho => exp_width,
                                  use_denormal => ieee_compliance,
                                  use_1scmpl => 0)
          port map ( a => d, z => OO101IOO );
-- Instances of DW_ifp_addsub
  U5: DW_ifp_addsub generic map (sig_widthi => sig_width+2,
                                 exp_widthi => exp_width,
                                 sig_widtho => sig_width+2+3,
                                 exp_widtho => exp_width+1,
                                 use_denormal => ieee_compliance,
                                 use_1scmpl => 0)
          port map ( a => l0OOO110, b => l1IIO0O1, rnd => rnd, op => '0', z => O1I0OlO0);
  U6: DW_ifp_addsub generic map (sig_widthi => sig_width+2,
                                 exp_widthi => exp_width,
                                 sig_widtho => sig_width+2+3,
                                 exp_widtho => exp_width+1,
                                 use_denormal => ieee_compliance,
                                 use_1scmpl => 0)
          port map ( a => O1O10l10, b => OO101IOO, rnd => rnd, op => '0', z => I0OOIllO);
  U7: DW_ifp_addsub generic map (sig_widthi => sig_width+2+3,
                                 exp_widthi => exp_width+1,
                                 sig_widtho => sig_width+2+3+sig_width,
                                 exp_widtho => exp_width+1+1,
                                 use_denormal => ieee_compliance,
                                 use_1scmpl => 0)
          port map ( a => O1I0OlO0, b => I0OOIllO, rnd => rnd, op => '0', z => Oll0110I);
-- Instance of DW_ifp_fp_conv  -- format converter
  U8: DW_ifp_fp_conv generic map (sig_widthi => sig_width+2+3+sig_width,
                                  exp_widthi => exp_width+1+1,
                                  sig_width  => sig_width,
                                  exp_width  => exp_width,
                                  use_denormal => ieee_compliance)
          port map ( a => Oll0110I, rnd => rnd, z => z_temp1, status => status_int1 );

-----------------------------------------------------------------------
-- Simulation model for the case arch_type = 0
-----------------------------------------------------------------------

-- purpose: main process for the behavioral description of the FP sum3
-- when ieee_compliance = 0 or 1
-- type   : combinational
-- inputs : a, b, c, d, rnd
-- outputs: l0O01OIO and IO10OIlO
MAIN_PROCESS: process (a, b, c, d, rnd)
variable OOI0101l : std_logic_vector(8    -1 downto 0);
variable l00O1I0O : std_logic_vector((exp_width + sig_width) downto 0);
variable O01l1O11, I010O1Il, I01IO10l, OOOl1lI0 : std_logic;
variable l00OlIOI,l1OlOO0l,lO001000, IO0lOOlO :  std_logic_vector(exp_width-1 downto 0); -- Exponents.
variable IOO10001,OOO000lI,O10O1I1O, l100OOIl :  std_logic_vector(sig_width-1 downto 0); -- fraction bits
variable O11llO11,O0Ol1O1l     :  std_logic_vector(sig_width downto 0);   -- The Mantissa numbers
variable O110011O,lIl1ll0I     :  std_logic_vector(sig_width downto 0);
variable Ol1O0O11,ll0O0OI1:  std_logic_vector((2*(sig_width+1)+5+1)  -1-3 downto 0);
variable I1OO01OI,OO011l1I:  std_logic_vector((2*(sig_width+1)+5+1)  -1-3 downto 0);
variable I0O1IOO1,O1OI1I1O,l110O0O1,O01I0O1l:  std_logic;                       -- sign bits
variable lI11O1Ol,l110OOll,lOOOIl1O,O1OlOlOO: std_logic;
variable I1lOOOOl,O0IOOOO0,OO1l11OI,l101lO0l: std_logic;
variable lOIOl1l1: std_logic;
variable Ol0O010O, l0I0O110, OI0100IO, lOOO10I1: std_logic;

-- special FP representations
variable O0100O01 : std_logic_vector(exp_width-1 downto 0) := (others => '0');
variable I01O0I0O : std_logic_vector(exp_width-1 downto 0) := (others => '0');
variable OI00I00l : std_logic_vector(sig_width-1 downto 0) := (others => '0');
variable I01111IO : std_logic_vector(exp_width-1 downto 0);
variable l1l1IOI0 : std_logic_vector((exp_width + sig_width + 1)-1 downto 0);  -- Not-a-number

-- The biggest possible exponent for addition/subtraction
variable OO1I100l : std_logic_vector(exp_width-1 downto 0);
variable II011O01, O1OI100O, I0O10l11, O0OIOl10 : std_logic_vector(exp_width-1 downto 0);
variable Ol1OO1l0 : std_logic_vector(exp_width+1 downto 0);
variable O00l1lI1, l1l10lOO :  std_logic_vector((((2*(sig_width+1)+5+1)  -1)-1)   downto 0); -- Mantissa of output
variable lOl01lOO : std_logic_vector((((2*(sig_width+1)+5+1)  -1)-1)   downto 0) := (others => '0'); 
variable I111101l : std_logic_vector(sig_width downto 0) := (others => '0');
variable I1OO000l : std_logic_vector(sig_width+2+1 downto 0) := (others => '0');
variable lO10l0Ol : std_logic_vector(O11llO11'length+2-1 downto 0) := (others => '0');
variable O0OOO0O1 : std_logic_vector((((2*(sig_width+1)+5+1)  -1)-1)   downto (sig_width+2+1)) := (others => '0');
variable lOl1OOI1 : std_logic_vector(Ol1O0O11'length-1 downto 0) := (others => '0');
variable l00lOOlO : std_logic_vector(I1OO01OI'length-1 downto 0) := (others => '0');
variable OO011Ol0 : std_logic_vector(OO011l1I'length-1 downto 0) := (others => '0');
variable I1OOOl0O : std_logic_vector(OO011l1I'length-1 downto 1) := (others => '0');

 -- Contains values returned by ll1lO01I function.
variable lOOOII0I : std_logic_vector(4-1 downto 0);
variable I1O101O0 : std_logic_vector(O00l1lI1'length-1 downto 0);

-- indication of special cases for the inputs
variable OO10IO0O, O0O01OO0, OIOl0O1O, I010Il1O : std_logic;
variable O0O0OO1O, O00010IO, OlOlOI0O, OO111110 : std_logic;
variable llOlO1l1, lOOIOlOl, OOOOl1OI, O0I1l11I : std_logic;
variable OO00100I, Ol0l01IO, llO1IOl0, l1O110II : std_logic;

-- internal variables
variable l00O1IO0, lOl1lIOO :  std_logic_vector(((2*(sig_width+1)+5+1)  -1) downto 0); 
variable OlIll11O, OO000000 :  std_logic_vector(((2*(sig_width+1)+5+1)  -1) downto 0); 
variable O1ll0100 :  std_logic_vector(((2*(sig_width+1)+5+1)  -1) downto 0); 
variable I1IlO10O : std_logic;
variable O0lIl1Ol :  std_logic_vector(((2*(sig_width+1)+5+1)  -1)-1 downto 0); 
variable O1I110OO, I0lI1010 :  std_logic_vector(((2*(sig_width+1)+5+1)  -1) downto 0); 
variable IOl0lOO0, O011IOl0 :  std_logic_vector(((2*(sig_width+1)+5+1)  -1) downto 0); 
variable O11lI101 : std_logic;
variable O00I1OlI : std_logic_vector(exp_width-1 downto 0);
variable l01000Ol : std_logic_vector((exp_width + sig_width + 1)-1 downto 0);
variable O00I10O0 : std_logic_vector((exp_width + sig_width + 1)-1 downto 0);

begin  -- process MAIN_PROCESS
  I01111IO := conv_std_logic_vector(((((2 ** (exp_width-1)) - 1) * 2) + 1), I01111IO'length);
  I01O0I0O := O0100O01 + 1;
  l1l1IOI0 := '0' & I01111IO & OI00I00l;
  if (ieee_compliance = 1) then
    l1l1IOI0(0) := '1';  -- mantissa is 1 when number is NAN and ieee_compliance=1
  else
    l1l1IOI0(0) := '0';
  end if;
  OOI0101l := (others => '0');
  I1O101O0 := (others => '0');
  I1O101O0(0) := '1';
  lOl1OOI1 := (others => '0');
  l00lOOlO := (others => '0');
  OO011Ol0 := (others => '0');
  lOl01lOO := (others => '0');
  I111101l := (others => '0');
  I1OO000l := (others => '0');
  lO10l0Ol := (others => '0');
  O0OOO0O1 := (others => '0');
  I1OOOl0O := (others => '0');
  lI11O1Ol := '0';
  l110OOll := '0';
  lOOOIl1O := '0';
  O1OlOlOO := '0';
  l01000Ol((exp_width + sig_width)) := '0';
  l01000Ol(((exp_width + sig_width) - 1) downto sig_width) := conv_std_logic_vector(((((2 ** (exp_width-1)) - 1) * 2) + 1),exp_width);
  l01000Ol((sig_width - 1) downto 0) := (others => '0');
  O00I10O0((exp_width + sig_width)) := '1';
  O00I10O0(((exp_width + sig_width) - 1) downto sig_width) := conv_std_logic_vector(((((2 ** (exp_width-1)) - 1) * 2) + 1),exp_width);
  O00I10O0((sig_width - 1) downto 0) := (others => '0');

  l00OlIOI := a(((exp_width + sig_width) - 1) downto sig_width);
  l1OlOO0l := b(((exp_width + sig_width) - 1) downto sig_width);
  lO001000 := c(((exp_width + sig_width) - 1) downto sig_width);
  IO0lOOlO := d(((exp_width + sig_width) - 1) downto sig_width);
  IOO10001 := a((sig_width - 1) downto 0);
  OOO000lI := b((sig_width - 1) downto 0);
  O10O1I1O := c((sig_width - 1) downto 0);
  l100OOIl := d((sig_width - 1) downto 0);
  I0O1IOO1 := a((exp_width + sig_width));
  O1OI1I1O := b((exp_width + sig_width));
  l110O0O1 := c((exp_width + sig_width)); 
  O01I0O1l := d((exp_width + sig_width)); 

  -- infinities
  if ((l00OlIOI = I01111IO) and ((IOO10001 = OI00I00l) or (ieee_compliance = 0))) then 
     O0O0OO1O := '1';
  else
     O0O0OO1O := '0';
  end if;
  if ((l1OlOO0l = I01111IO) and ((OOO000lI = OI00I00l) or (ieee_compliance = 0))) then 
     O00010IO := '1';
  else
     O00010IO := '0';
  end if;
  if ((lO001000 = I01111IO) and ((O10O1I1O = OI00I00l) or (ieee_compliance = 0))) then 
     OlOlOI0O := '1';
  else
     OlOlOI0O := '0';
  end if;
  if ((IO0lOOlO = I01111IO) and ((l100OOIl = OI00I00l) or (ieee_compliance = 0))) then 
     OO111110 := '1';
  else
     OO111110 := '0';
  end if;
  -- nan
  if ((l00OlIOI = I01111IO) and (IOO10001 /= OI00I00l) and (ieee_compliance = 1)) then 
     llOlO1l1 := '1';
  else
     llOlO1l1 := '0';
  end if;
  if ((l1OlOO0l = I01111IO) and (OOO000lI /= OI00I00l) and (ieee_compliance = 1)) then 
     lOOIOlOl := '1';
  else
     lOOIOlOl := '0';
  end if;
  if ((lO001000 = I01111IO) and (O10O1I1O /= OI00I00l) and (ieee_compliance = 1)) then 
     OOOOl1OI := '1';
  else
     OOOOl1OI := '0';
  end if;
  if ((IO0lOOlO = I01111IO) and (l100OOIl /= OI00I00l) and (ieee_compliance = 1)) then 
     O0I1l11I := '1';
  else
     O0I1l11I := '0';
  end if;
  -- zeros
  if ((l00OlIOI = O0100O01) and ((IOO10001 = OI00I00l) or (ieee_compliance = 0))) then
     OO00100I := '1';
     IOO10001 := (others => '0');
  else
     OO00100I := '0';
  end if;
  if ((l1OlOO0l = O0100O01) and ((OOO000lI = OI00I00l) or (ieee_compliance = 0))) then
     Ol0l01IO := '1';
     OOO000lI := (others => '0');
  else
     Ol0l01IO := '0';
  end if;
  if ((lO001000 = O0100O01) and ((O10O1I1O = OI00I00l) or (ieee_compliance = 0))) then
     llO1IOl0 := '1';
     O10O1I1O := (others => '0');
  else
     llO1IOl0 := '0';
  end if;
  if ((IO0lOOlO = O0100O01) and ((l100OOIl = OI00I00l) or (ieee_compliance = 0))) then
     l1O110II := '1';
     l100OOIl := (others => '0');
  else
     l1O110II := '0';
  end if;
  -- denormals
  if ((l00OlIOI = O0100O01) and (IOO10001 /= OI00I00l) and (ieee_compliance = 1)) then
    OO10IO0O := '1';
    l00OlIOI := I01O0I0O;
  else
     OO10IO0O := '0';
  end if;
  if ((l1OlOO0l = O0100O01) and (OOO000lI /= OI00I00l) and (ieee_compliance = 1)) then
    O0O01OO0 := '1';
    l1OlOO0l := I01O0I0O;
  else
     O0O01OO0 := '0';
  end if;
  if ((lO001000 = O0100O01) and (O10O1I1O /= OI00I00l) and (ieee_compliance = 1)) then
    OIOl0O1O := '1';
    lO001000 := I01O0I0O;
  else
    OIOl0O1O := '0';
  end if;
  if ((IO0lOOlO = O0100O01) and (l100OOIl /= OI00I00l) and (ieee_compliance = 1)) then
    I010Il1O := '1';
    IO0lOOlO := I01O0I0O;
  else
    I010Il1O := '0';
  end if;

  if ((llOlO1l1 = '1') or (lOOIOlOl = '1') or (OOOOl1OI = '1') or (O0I1l11I = '1')) then
    l00O1I0O := l1l1IOI0;
    OOI0101l(2) := '1';
  elsif  (O0O0OO1O = '1') then
    if (((O00010IO = '1') and (I0O1IOO1 /= O1OI1I1O)) or ((OlOlOI0O = '1') and (I0O1IOO1 /= l110O0O1))
         or ((OO111110 = '1') and (I0O1IOO1 /= O01I0O1l))) then
      OOI0101l(2) := '1';
      l00O1I0O := l1l1IOI0;
       if (ieee_compliance = 1) then
        OOI0101l(1) := '0';
      else
        OOI0101l(1) := '1';
      end if;
   else 
      OOI0101l(1) := '1';
      if (I0O1IOO1 = '1') then
        l00O1I0O := O00I10O0;
      else
        l00O1I0O := l01000Ol;
      end if;
    end if;
  elsif (O00010IO = '1') then
    if (((O0O0OO1O = '1') and (I0O1IOO1 /= O1OI1I1O)) or ((OlOlOI0O = '1') and (O1OI1I1O /= l110O0O1)) 
         or ((OO111110 = '1') and (O1OI1I1O /= O01I0O1l))) then
      l00O1I0O := l1l1IOI0;
      OOI0101l(2) := '1';
       if (ieee_compliance = 1) then
        OOI0101l(1) := '0';
      else
        OOI0101l(1) := '1';
      end if;
   else
      OOI0101l(1) := '1';
      if (O1OI1I1O = '1') then
        l00O1I0O := O00I10O0;
      else
        l00O1I0O := l01000Ol;
      end if;
    end if;
  elsif (OlOlOI0O = '1') then
    if (((O0O0OO1O = '1') and (I0O1IOO1 /= l110O0O1)) or ((O00010IO = '1') and (O1OI1I1O /= l110O0O1))
        or ((OO111110 = '1') and (O01I0O1l /= l110O0O1))) then
      l00O1I0O := l1l1IOI0;
      OOI0101l(2) := '1';
      if (ieee_compliance = 1) then
        OOI0101l(1) := '0';
      else
        OOI0101l(1) := '1';
      end if;
    else
      OOI0101l(1) := '1';
      if (l110O0O1 = '1') then
        l00O1I0O := O00I10O0;
      else
        l00O1I0O := l01000Ol;
      end if;
    end if;
  elsif (OO111110 = '1') then
    if (((O0O0OO1O = '1') and (I0O1IOO1 /= O01I0O1l)) or ((O00010IO = '1') and (O1OI1I1O /= O01I0O1l))
        or ((OlOlOI0O = '1') and (O01I0O1l /= l110O0O1))) then
      l00O1I0O := l1l1IOI0;
      OOI0101l(2) := '1';
      if (ieee_compliance = 1) then
        OOI0101l(1) := '0';
      else
        OOI0101l(1) := '1';
      end if;
    else
      OOI0101l(1) := '1';
      if (O01I0O1l = '1') then
        l00O1I0O := O00I10O0;
      else
        l00O1I0O := l01000Ol;
      end if;
    end if;
  
  elsif ((OO00100I = '1') and (Ol0l01IO = '1') and (llO1IOl0 = '1') and (l1O110II = '1')) then
      l00O1I0O := (others => '0');
      OOI0101l(0) := '1';
      if (ieee_compliance = 0) then
        if (rnd = "011") then
          l00O1I0O((exp_width + sig_width)) := '1';
        else
          l00O1I0O((exp_width + sig_width)) := '0';
        end if;
      else
        if ((I0O1IOO1 = O1OI1I1O) and (O1OI1I1O = l110O0O1) and (l110O0O1 = O01I0O1l)) then
          l00O1I0O((exp_width + sig_width)) := I0O1IOO1;
        else
          if (rnd = "011") then
            l00O1I0O((exp_width + sig_width)) := '1';
          else
            l00O1I0O((exp_width + sig_width)) := '0';
          end if;
        end if;
      end if;
    
  else                                          
    if (OO10IO0O = '1' or OO00100I = '1') then
       if (ieee_compliance = 1) then
          O11llO11 := "0" & IOO10001;
       else
          O11llO11 := I111101l;
       end if;
    else
       O11llO11 := "1" & IOO10001;
    end if;
    if (O0O01OO0 = '1' or Ol0l01IO = '1') then
       if (ieee_compliance = 1) then
          O0Ol1O1l := "0" & OOO000lI;
       else
          O0Ol1O1l := I111101l;
       end if;
    else
       O0Ol1O1l := "1" & OOO000lI;
    end if;
    if (OIOl0O1O = '1' or llO1IOl0 = '1') then
       if (ieee_compliance = 1) then
          O110011O := "0" & O10O1I1O;
       else
          O110011O := I111101l;
       end if;
    else
       O110011O := "1" & O10O1I1O;
    end if;
    if (I010Il1O = '1' or l1O110II = '1') then
       if (ieee_compliance = 1) then
          lIl1ll0I := "0" & l100OOIl;
       else
          lIl1ll0I := I111101l;
       end if;
    else
       lIl1ll0I := "1" & l100OOIl;
    end if;
    if ((l00OlIOI = l1OlOO0l) and (O11llO11 = O0Ol1O1l) and (I0O1IOO1 /= O1OI1I1O)) then
      l00OlIOI := O0100O01;
      O11llO11 := I111101l;
      l1OlOO0l := O0100O01;
      O0Ol1O1l := I111101l;
    end if;
    if ((l00OlIOI = lO001000) and (O11llO11 = O110011O) and (I0O1IOO1 /= l110O0O1)) then
      l00OlIOI := O0100O01;
      O11llO11 := I111101l;
      lO001000 := O0100O01;
      O110011O := I111101l;
    end if;
    if ((l00OlIOI = IO0lOOlO) and (O11llO11 = lIl1ll0I) and (I0O1IOO1 /= O01I0O1l)) then
      l00OlIOI := O0100O01;
      O11llO11 := I111101l;
      IO0lOOlO := O0100O01;
      lIl1ll0I := I111101l;
    end if;
    if ((l1OlOO0l = lO001000) and (O0Ol1O1l = O110011O) and (O1OI1I1O /= l110O0O1)) then
      l1OlOO0l := O0100O01;
      O0Ol1O1l := I111101l;
      lO001000 := O0100O01;
      O110011O := I111101l;
    end if;
    if ((l1OlOO0l = IO0lOOlO) and (O0Ol1O1l = lIl1ll0I) and (O1OI1I1O /= O01I0O1l)) then
      l1OlOO0l := O0100O01;
      O0Ol1O1l := I111101l;
      IO0lOOlO := O0100O01;
      lIl1ll0I := I111101l;
    end if;
    if ((lO001000 = IO0lOOlO) and (O110011O = lIl1ll0I) and (l110O0O1 /= O01I0O1l)) then
      lO001000 := O0100O01;
      O110011O := I111101l;
      IO0lOOlO := O0100O01;
      lIl1ll0I := I111101l;
    end if;
 
    if ((l00OlIOI > l1OlOO0l) and (l00OlIOI > lO001000) and (l00OlIOI > IO0lOOlO)) then
      OO1I100l := l00OlIOI;
    elsif ((l1OlOO0l >= l00OlIOI) and (l1OlOO0l > lO001000) and (l1OlOO0l > IO0lOOlO)) then
      OO1I100l := l1OlOO0l;
    elsif ((lO001000 >= l00OlIOI) and (lO001000 >= l1OlOO0l) and (lO001000 > IO0lOOlO)) then
      OO1I100l := lO001000;
    else
      OO1I100l := IO0lOOlO;
    end if;
    II011O01 := OO1I100l - l00OlIOI;
    O1OI100O := OO1I100l - l1OlOO0l;
    I0O10l11 := OO1I100l - lO001000;
    O0OIOl10 := OO1I100l - IO0lOOlO;

    O01l1O11 := '0';
    Ol1O0O11 := O11llO11 & I1OO000l;
    O00I1OlI := II011O01;
    while ( (Ol1O0O11 /= lOl1OOI1) and (O00I1OlI /= O0100O01) )  loop
      O01l1O11 := Ol1O0O11(0) or O01l1O11;
      Ol1O0O11 := '0' & Ol1O0O11(Ol1O0O11'length-1 downto 1);
      O00I1OlI := O00I1OlI - 1;
    end loop;
    O01l1O11 := Ol1O0O11(0) or O01l1O11;

    I010O1Il := '0';
    ll0O0OI1 := O0Ol1O1l & I1OO000l;
    O00I1OlI := O1OI100O;
    while ( (ll0O0OI1 /= lOl1OOI1) and (O00I1OlI /= O0100O01) )  loop
      I010O1Il := ll0O0OI1(0) or I010O1Il;
      ll0O0OI1 := '0' & ll0O0OI1(ll0O0OI1'length-1 downto 1);
      O00I1OlI := O00I1OlI - 1;
    end loop;
    I010O1Il := ll0O0OI1(0) or I010O1Il;

    I01IO10l := '0';
    I1OO01OI := O110011O & I1OO000l;
    O00I1OlI := I0O10l11;
    while ( (I1OO01OI /= l00lOOlO) and (O00I1OlI /= O0100O01) )  loop
      I01IO10l := I1OO01OI(0) or I01IO10l;
      I1OO01OI := '0' & I1OO01OI(I1OO01OI'length-1 downto 1);
      O00I1OlI := O00I1OlI - 1;
    end loop;
    I01IO10l := I1OO01OI(0) or I01IO10l;

    OOOl1lI0 := '0';
    OO011l1I := lIl1ll0I & I1OO000l;
    O00I1OlI := O0OIOl10;
    while ( (OO011l1I /= OO011Ol0) and (O00I1OlI /= O0100O01) )  loop
      OOOl1lI0 := OO011l1I(0) or OOOl1lI0;
      OO011l1I := '0' & OO011l1I(OO011l1I'length-1 downto 1);
      O00I1OlI := O00I1OlI - 1;
    end loop;
    OOOl1lI0 := OO011l1I(0) or OOOl1lI0;

    lOIOl1l1 := '0';
    lI11O1Ol := '0';
    l110OOll := '0';
    lOOOIl1O := '0';
    O1OlOlOO := '0';

    Ol0O010O := '0';
    l0I0O110 := '0';
    OI0100IO := '0';
    lOOO10I1 := '0';
    if (Ol1O0O11(Ol1O0O11'length-1 downto 1) = I1OOOl0O) then
      Ol0O010O := '1';
    end if;
    if (ll0O0OI1(ll0O0OI1'length-1 downto 1) = I1OOOl0O) then
      l0I0O110 := '1';
    end if;
    if (I1OO01OI(I1OO01OI'length-1 downto 1) = I1OOOl0O) then
      OI0100IO := '1';
    end if;
    if (OO011l1I(OO011l1I'length-1 downto 1) = I1OOOl0O) then
      lOOO10I1 := '1';
    end if;

    if ((O01l1O11 = '1') and (Ol0O010O = '1') and 
        (I010O1Il = '1') and (l0I0O110 = '1') and 
        (I01IO10l = '1') and (OI0100IO = '1')) then
      lOIOl1l1 := '1';
      if (((l00OlIOI & O11llO11) > (l1OlOO0l & O0Ol1O1l)) and ((l00OlIOI & O11llO11) > (lO001000 & O110011O))) then
        l110OOll := '1';
        lOOOIl1O := '1';
        O1OlOlOO := '1';
      else
        if (((lO001000 & O110011O) > (l00OlIOI & O11llO11)) and ((lO001000 & O110011O) > (l1OlOO0l & O0Ol1O1l))) then
          lI11O1Ol := '1';
          l110OOll := '1';
          O1OlOlOO := '1';
        else
          if (((l1OlOO0l & O0Ol1O1l) > (l00OlIOI & O11llO11)) and ((l1OlOO0l & O0Ol1O1l) > (lO001000 & O110011O))) then
            lI11O1Ol := '1';
            lOOOIl1O := '1';
            O1OlOlOO := '1';
          end if;
        end if;
      end if;
    end if;
    if ((O01l1O11 = '1') and (Ol0O010O = '1') and 
        (I010O1Il = '1') and (l0I0O110 = '1') and 
        (OOOl1lI0 = '1') and (lOOO10I1 = '1')) then
      lOIOl1l1 := '1';
      if (((l00OlIOI & O11llO11) > (l1OlOO0l & O0Ol1O1l)) and ((l00OlIOI & O11llO11) > (IO0lOOlO & lIl1ll0I))) then
        l110OOll := '1';
        lOOOIl1O := '1';
        O1OlOlOO := '1';
      else
        if (((l1OlOO0l & O0Ol1O1l) > (l00OlIOI & O11llO11)) and ((l1OlOO0l & O0Ol1O1l) > (IO0lOOlO & lIl1ll0I))) then
          lI11O1Ol := '1';
          lOOOIl1O := '1';
          O1OlOlOO := '1';
        else
          if (((IO0lOOlO & lIl1ll0I) > (l00OlIOI & O11llO11)) and ((IO0lOOlO & lIl1ll0I) > (l1OlOO0l & O0Ol1O1l))) then
            lI11O1Ol := '1';
            l110OOll := '1';
            lOOOIl1O := '1';
          end if;
        end if;
      end if;
    end if;
    if ((O01l1O11 = '1') and (Ol0O010O = '1') and 
        (I01IO10l = '1') and (OI0100IO = '1') and 
        (OOOl1lI0 = '1') and (lOOO10I1 = '1')) then
      lOIOl1l1 := '1';
      if (((l00OlIOI & O11llO11) > (lO001000 & O110011O)) and ((l00OlIOI & O11llO11) > (IO0lOOlO & lIl1ll0I))) then
        l110OOll := '1';
        lOOOIl1O := '1';
        O1OlOlOO := '1';
      else
        if (((lO001000 & O110011O) > (l00OlIOI & O11llO11)) and ((lO001000 & O110011O) > (IO0lOOlO & lIl1ll0I))) then
          lI11O1Ol := '1';
          l110OOll := '1';
          O1OlOlOO := '1';
        else
          if (((IO0lOOlO & lIl1ll0I) > (l00OlIOI & O11llO11)) and ((IO0lOOlO & lIl1ll0I) > (lO001000 & O110011O))) then
            lI11O1Ol := '1';
            l110OOll := '1';
            lOOOIl1O := '1';
          end if;
        end if;
      end if;
    end if;
    if ((I010O1Il = '1') and (l0I0O110 = '1') and 
        (I01IO10l = '1') and (OI0100IO = '1') and 
        (OOOl1lI0 = '1') and (lOOO10I1 = '1')) then
      lOIOl1l1 := '1';
      if (((l1OlOO0l & O0Ol1O1l) > (lO001000 & O110011O)) and ((l1OlOO0l & O0Ol1O1l) > (IO0lOOlO & lIl1ll0I))) then
        lI11O1Ol := '1';
        lOOOIl1O := '1';
        O1OlOlOO := '1';
      else
        if (((lO001000 & O110011O) > (l1OlOO0l & O0Ol1O1l)) and ((lO001000 & O110011O) > (IO0lOOlO & lIl1ll0I))) then
          lI11O1Ol := '1';
          l110OOll := '1';
          O1OlOlOO := '1';
        else
          if (((IO0lOOlO & lIl1ll0I) > (l1OlOO0l & O0Ol1O1l)) and ((IO0lOOlO & lIl1ll0I) > (lO001000 & O110011O))) then
            lI11O1Ol := '1';
            l110OOll := '1';
            lOOOIl1O := '1';
          end if;
        end if;
      end if;
    end if;
    if (lOIOl1l1 = '0') then
      if ((O01l1O11 = '1') and (Ol0O010O = '1') and 
          (((I010O1Il = '1') and (l0I0O110 = '1') and 
            ((l00OlIOI & O11llO11) < (l1OlOO0l & O0Ol1O1l))) or
           ((I01IO10l = '1') and (OI0100IO = '1') and 
            ((l00OlIOI & O11llO11) < (lO001000 & O110011O))) or
           ((OOOl1lI0 = '1') and (lOOO10I1 = '1' and 
            ((l00OlIOI & O11llO11) < (IO0lOOlO & lIl1ll0I)))) )  ) then
        lI11O1Ol := '1';
      else
        lI11O1Ol := '0';
      end if;
      if ((I010O1Il = '1') and (l0I0O110 = '1') and 
          (((O01l1O11 = '1') and (Ol0O010O = '1') and 
            ((l1OlOO0l & O0Ol1O1l) < (l00OlIOI & O11llO11))) or
           ((I01IO10l = '1') and (OI0100IO = '1') and 
            ((l1OlOO0l & O0Ol1O1l) < (lO001000 & O110011O))) or
          ((OOOl1lI0 = '1') and (lOOO10I1 = '1' and 
            ((l1OlOO0l & O0Ol1O1l) < (IO0lOOlO & lIl1ll0I)))) )  ) then
        l110OOll := '1';
      else
        l110OOll := '0';
      end if;
      if ((I01IO10l = '1') and (OI0100IO = '1') and 
          (((O01l1O11 = '1') and (Ol0O010O = '1') and 
            ((lO001000 & O110011O) < (l00OlIOI & O11llO11))) or
           ((I010O1Il = '1') and (l0I0O110 = '1') and 
            ((lO001000 & O110011O) < (l1OlOO0l & O0Ol1O1l))) or
           ((OOOl1lI0 = '1') and (lOOO10I1 = '1' and 
            ((lO001000 & O110011O) < (IO0lOOlO & lIl1ll0I)))) )  ) then
        lOOOIl1O := '1';
      else
        lOOOIl1O := '0';
      end if;
      if ((OOOl1lI0 = '1') and (lOOO10I1 = '1' and 
          (((O01l1O11 = '1') and (Ol0O010O = '1') and 
            ((IO0lOOlO & lIl1ll0I) < (l00OlIOI & O11llO11))) or
           ((I010O1Il = '1') and (l0I0O110 = '1') and 
            ((IO0lOOlO & lIl1ll0I) < (l1OlOO0l & O0Ol1O1l))) or
           ((I01IO10l = '1') and (OI0100IO = '1') and 
            ((IO0lOOlO & lIl1ll0I) < (lO001000 & O110011O)))) )  ) then
        O1OlOlOO := '1';
      else
        O1OlOlOO := '0';
      end if;
    end if;

    I1lOOOOl := (not lI11O1Ol) and O01l1O11;
    O0IOOOO0 := (not l110OOll) and I010O1Il;
    OO1l11OI := (not lOOOIl1O) and I01IO10l;
    l101lO0l := (not O1OlOlOO) and OOOl1lI0;

    O1I110OO := "000" & Ol1O0O11(Ol1O0O11'length-1 downto 1) & I1lOOOOl;
    I0lI1010 := "000" & ll0O0OI1(ll0O0OI1'length-1 downto 1) & O0IOOOO0;
    IOl0lOO0 := "000" & I1OO01OI(I1OO01OI'length-1 downto 1) & OO1l11OI;
    O011IOl0 := "000" & OO011l1I(OO011l1I'length-1 downto 1) & l101lO0l;

    if (I0O1IOO1 = '1') then
      l00O1IO0 := (not O1I110OO) + 1;
    else 
      l00O1IO0 := O1I110OO;
    end if;
    if (O1OI1I1O = '1') then
      lOl1lIOO := (not I0lI1010) + 1;
    else 
      lOl1lIOO := I0lI1010;
    end if;
    if (l110O0O1 = '1') then
      OlIll11O := (not IOl0lOO0) + 1;
    else 
      OlIll11O := IOl0lOO0;
    end if;
    if (O01I0O1l = '1') then
      OO000000 := (not O011IOl0) + 1;
    else 
      OO000000 := O011IOl0;
    end if;

    O1ll0100 := l00O1IO0 + lOl1lIOO + OlIll11O + OO000000;
    
    I1IlO10O := O1ll0100(((2*(sig_width+1)+5+1)  -1));
    if (I1IlO10O = '1') then
      O0lIl1Ol := (not O1ll0100(((2*(sig_width+1)+5+1)  -1)-1 downto 0))+1;
    else
      O0lIl1Ol := O1ll0100(((2*(sig_width+1)+5+1)  -1)-1 downto 0);
    end if;

    O00l1lI1 := O0lIl1Ol;
    l1l10lOO := O0lIl1Ol;
    
    Ol1OO1l0 := "00" & OO1I100l;

    if ((O00l1lI1((((2*(sig_width+1)+5+1)  -1)-1)   downto (sig_width+2+1)-2) = O0OOO0O1) and
        (O01l1O11 = '1' or I010O1Il = '1' or I01IO10l = '1' or OOOl1lI0 = '1')) then
      if (O01l1O11 = '1') then
        l00O1I0O := a; 
        OOI0101l(0) := OO00100I;
        OOI0101l(5) := '0';
        OOI0101l(3) := '0';
        OOI0101l(4) := '0';
        OOI0101l(1) := O0O0OO1O;
        OOI0101l(2) := llOlO1l1;
      end if;
      if (I010O1Il = '1') then
        l00O1I0O := b; 
        OOI0101l(0) := Ol0l01IO;
        OOI0101l(5) := '0';
        OOI0101l(3) := '0';
        OOI0101l(4) := '0';
        OOI0101l(1) := O00010IO;
        OOI0101l(2) := lOOIOlOl;
      end if;
      if (I01IO10l = '1') then
        l00O1I0O := c; 
        OOI0101l(0) := llO1IOl0;
        OOI0101l(5) := '0';
        OOI0101l(3) := '0';
        OOI0101l(4) := '0';
        OOI0101l(1) := OlOlOI0O;
        OOI0101l(2) := OOOOl1OI;
      end if;
      if (OOOl1lI0 = '1') then
        l00O1I0O := d; 
        OOI0101l(0) := l1O110II;
        OOI0101l(5) := '0';
        OOI0101l(3) := '0';
        OOI0101l(4) := '0';
        OOI0101l(1) := OO111110;
        OOI0101l(2) := O0I1l11I;
      end if;

    else
    O11lI101 := '0';
    if (O00l1lI1((((2*(sig_width+1)+5+1)  -1)-1)  ) = '1') then
      Ol1OO1l0 := Ol1OO1l0 + 1;
      O11lI101 := O00l1lI1(0) or O11lI101;
      O00l1lI1 := '0' & O00l1lI1(O00l1lI1'length-1 downto 1);
    end if;
    if (O00l1lI1((((2*(sig_width+1)+5+1)  -1)-1)  -1) = '1') then
      Ol1OO1l0 := Ol1OO1l0 + 1;
      O11lI101 := O00l1lI1(0) or O11lI101;
      O00l1lI1 := '0' & O00l1lI1(O00l1lI1'length-1 downto 1);
    end if;
    while ( (O00l1lI1((((2*(sig_width+1)+5+1)  -1)-1)  -2) = '0') and (Ol1OO1l0 > I01O0I0O) ) loop
      Ol1OO1l0 := Ol1OO1l0 - 1;
      O00l1lI1 := O00l1lI1(O00l1lI1'length-2 downto 0) & '0';
    end loop;

    lOOOII0I := ll1lO01I(rnd, I1IlO10O, O00l1lI1((sig_width+3+1)), O00l1lI1((sig_width+2+1)),(or_reduce(O00l1lI1((sig_width+2+1)-1 downto 0)&O01l1O11&I010O1Il&I01IO10l&OOOl1lI0&O11lI101)));
    
    if (lOOOII0I(0) = '1') then
      O00l1lI1 := O00l1lI1 + my_sll(I1O101O0,(sig_width+3+1));
    end if;   

    if ( (O00l1lI1((((2*(sig_width+1)+5+1)  -1)-1)  -1) = '1') ) then
      Ol1OO1l0 := Ol1OO1l0 + 1;
      O00l1lI1 := '0' & O00l1lI1((((2*(sig_width+1)+5+1)  -1)-1)   downto 1);
    end if;

    if (O00l1lI1 = lOl01lOO) then
      OOI0101l(0) := '1';
      l00O1I0O := (others => '0');
      if (rnd = "011") then
        l00O1I0O((exp_width + sig_width)) := '1';
      else
        l00O1I0O((exp_width + sig_width)) := '0';
      end if;

    else
      if (O00l1lI1((((2*(sig_width+1)+5+1)  -1)-1)   downto (((2*(sig_width+1)+5+1)  -1)-1)  -2) = "000") then
        if (ieee_compliance = 1) then
          l00O1I0O := I1IlO10O & O0100O01 & O00l1lI1((((2*(sig_width+1)+5+1)  -1)-1)  -3 downto (sig_width+3+1));
          OOI0101l(3) := '1';
          OOI0101l(5) := lOOOII0I(1);
          if (O00l1lI1((((2*(sig_width+1)+5+1)  -1)-1)  -3 downto (sig_width+3+1)) = lO10l0Ol) then
            OOI0101l(0) := '1'; 
          end if;
        else
          OOI0101l(3) := '1';
          OOI0101l(5) := '1';
          if ((rnd = "011" and I1IlO10O = '1') or
              (rnd = "010" and I1IlO10O = '0') or
              rnd = "101") then
            l00O1I0O := I1IlO10O & I01O0I0O & OI00I00l;
            OOI0101l(0) := '0';
          else
            l00O1I0O := I1IlO10O & O0100O01 & OI00I00l;
            OOI0101l(0) := '1';
          end if;
        end if;  -- ieee_compliance = 1

      else
        if (Ol1OO1l0 >= conv_std_logic_vector(((((2 ** (exp_width-1)) - 1) * 2) + 1),Ol1OO1l0'length)) then
          -- huge
          OOI0101l(5) := '1';          
          OOI0101l(4) := '1';
          if (lOOOII0I(2) = '1') then
            -- Infinity
            O00l1lI1 := (others => '0');
            Ol1OO1l0 := conv_std_logic_vector(((((2 ** (exp_width-1)) - 1) * 2) + 1),Ol1OO1l0'length);
            OOI0101l(1) := '1';
          else
            -- MaxNorm
            Ol1OO1l0 := conv_std_logic_vector(((((2 ** (exp_width-1)) - 1) * 2) + 1),Ol1OO1l0'length) - 1;
            O00l1lI1 := (others => '1');
          end if;
        elsif (Ol1OO1l0 <= conv_std_logic_vector(0,Ol1OO1l0'length)) then
          Ol1OO1l0 := conv_std_logic_vector(0,Ol1OO1l0'length) + 1;
        else
          OOI0101l(5) := lOOOII0I(1);
        end if;

        -- Reconstruct the floating point format.
        l00O1I0O := I1IlO10O & Ol1OO1l0(exp_width-1 downto 0) & O00l1lI1((((2*(sig_width+1)+5+1)  -1)-1)  -3 downto (sig_width+3+1));

      end if;  -- (O00l1lI1(....) = "000")
      
    end if; --  if (O00l1lI1 = lOl01lOO) 

    end if; -- if ((OOOl1lI0 = ...) 


  end if;  -- if NaN input 

  l0O01OIO <= OOI0101l;
  IO10OIlO <=  l00O1I0O;
  
end process MAIN_PROCESS;

--
-- purpose: process the output values
-- type   : combinational
-- inputs : a,b,c,d,rnd,z_temp1,IO10OIlO,status_int1,l0O01OIO
-- outputs: status and l00O1I0O
SELECT_OUTPUT: process (a, b, c, d, rnd, z_temp1, IO10OIlO, status_int1, l0O01OIO)
begin
  if (Is_X(a) or Is_X(b) or Is_X(c) or Is_X(d) or Is_X(rnd)) then
    status <= (others => 'X');
    z <= (others => 'X');
  else
    if (arch_type = 1) then
      status <= status_int1;
      z <= z_temp1;
    else
      status <= l0O01OIO;
      z <= IO10OIlO;
    end if;
  end if;
end process SELECT_OUTPUT;

-- pragma translate_on  

end sim ;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

library dw02;

configuration DW_fp_sum4_cfg_sim of DW_fp_sum4 is
 for sim
  for U1: DW_fp_ifp_conv use configuration dw02.DW_fp_ifp_conv_cfg_sim; end for;
  for U2: DW_fp_ifp_conv use configuration dw02.DW_fp_ifp_conv_cfg_sim; end for;
  for U3: DW_fp_ifp_conv use configuration dw02.DW_fp_ifp_conv_cfg_sim; end for;
  for U4: DW_fp_ifp_conv use configuration dw02.DW_fp_ifp_conv_cfg_sim; end for;
  for U5: DW_ifp_addsub use configuration dw02.DW_ifp_addsub_cfg_sim; end for;
  for U6: DW_ifp_addsub use configuration dw02.DW_ifp_addsub_cfg_sim; end for;
  for U7: DW_ifp_addsub use configuration dw02.DW_ifp_addsub_cfg_sim; end for;
  for U8: DW_ifp_fp_conv use configuration dw02.DW_ifp_fp_conv_cfg_sim; end for;
 end for; -- sim
end DW_fp_sum4_cfg_sim;
-- pragma translate_on

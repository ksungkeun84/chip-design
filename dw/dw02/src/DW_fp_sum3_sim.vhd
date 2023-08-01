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
-- VERSION:   VHDL Simulation Model - FP SUM3
--
-- DesignWare_version: fd7ee03d
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--
-- ABSTRACT: Three-operand Floating-point Adder (SUM3)
--           Computes the addition of three FP numbers. The format of the FP
--           numbers is defined by the number of bits in the significand 
--           (sig_width) and the number of bits in the exponent (exp_width).
--           The outputs are a FP number and status flags with information 
--           about special number representations and exceptions. 
--
--           special number representations and exceptions. 
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
--              b               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Input
--              c               (sig_width + exp_width + 1)-bits
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
-- 
-- MODIFIED:
---------------------------------------------------------------------------------

library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_misc.all;
use IEEE.std_logic_arith.all;
use DWARE.DW_Foundation_arith.all;
use DWARE.DW_Foundation_comp_arith.all;

architecture sim of DW_fp_sum3 is
	
-- pragma translate_off


-- O1111O11 function used in several FP components
function O1111O11 (Il1O1O1O: std_logic_vector(2 downto 0);
                   l0OOO100: std_logic;
                   O0I1IIIl: std_logic;
                   I1O001O0: std_logic;
                   O001I111: std_logic) return std_logic_vector is
--*******************************
--  IlO1I01O has 4 bits:
--  IlO1I01O[0]
--  IlO1I01O[1]
--  IlO1I01O[2]
--  IlO1I01O[3]
--*******************************

--*******************************
--  Rounding increment equations
--  |
--    MODE | Equation   | Description
--    -----------------------------
--    even | I1O001O0&(O0I1IIIl|O001I111)  | IEEE round to nearest (even)
--    zero | 0          | IEEE round to zero
--    +inf | S'&(I1O001O0|O001I111) | IEEE round to positive infinity
--    -inf | S&(I1O001O0|O001I111)  | IEEE round to negative infinity
--     up  | I1O001O0          | round to nearest (up)
--    away | (I1O001O0|O001I111)    | round away from zero
-- *******************************
variable O1111O11 : std_logic_vector (4-1 downto 0);
begin
  O1111O11(0) := '0';
  O1111O11(1) := I1O001O0 or O001I111;
  O1111O11(2) := '0';
  O1111O11(3) := '0';
  case Il1O1O1O is
    when "000" =>
      -- round to nearest (even) 
      O1111O11(0) := I1O001O0 and (O0I1IIIl or O001I111);
      O1111O11(2) := '1';
      O1111O11(3) := '0';
    when "001" =>
      -- round to zero 
      O1111O11(0) := '0';
      O1111O11(2) := '0';
      O1111O11(3) := '0';
    when "010" =>
      -- round to positive infinity 
      O1111O11(0) := not l0OOO100 and (I1O001O0 or O001I111);
      O1111O11(2) := not l0OOO100;
      O1111O11(3) := not l0OOO100;
    when "011" =>
      -- round to negative infinity 
      O1111O11(0) := l0OOO100 and (I1O001O0 or O001I111);
      O1111O11(2) := l0OOO100;
      O1111O11(3) := l0OOO100;
    when "100" =>
      -- round to nearest (up)
      O1111O11(0) := I1O001O0;
      O1111O11(2) := '1';
      O1111O11(3) := '0';
    when "101" =>
      -- round away form 0  
      O1111O11(0) := I1O001O0 or O001I111;
      O1111O11(2) := '1';
      O1111O11(3) := '1';
    when others =>
      O1111O11(0) := 'X';
      O1111O11(2) := 'X';
      O1111O11(3) := 'X';
  end case;
  return (O1111O11);
end function;                                    -- IlO1I01O function

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



signal lll0I1II, I0IO0O0O : std_logic_vector(8    -1 downto 0);
signal z_temp1, l10O0O1I : std_logic_vector((exp_width + sig_width) downto 0);

-- Other signals used for simulation of the architecture when arch_type = 1

signal l010O0ll : std_logic_vector(sig_width+2+exp_width+6 downto 0);
signal Ol0010O0 : std_logic_vector(sig_width+2+exp_width+6 downto 0);
signal O1OI0l10 : std_logic_vector(sig_width+2+3+exp_width+1+6 downto 0);
signal l11OOlI1 : std_logic_vector(sig_width+2+3+exp_width+1+6 downto 0); -- result of a+b = d
signal lO111I0I : std_logic_vector(sig_width+2+3+sig_width+exp_width+1+1+6 downto 0); -- result of d+c

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
          port map ( a => a, z => l010O0ll );
  U2: DW_fp_ifp_conv generic map (sig_widthi => sig_width, 
                                  exp_widthi => exp_width, 
                                  sig_widtho => sig_width+2,
                                  exp_widtho => exp_width,
                                  use_denormal => ieee_compliance,
                                  use_1scmpl => 0)
          port map ( a => b, z => Ol0010O0 );
  U3: DW_fp_ifp_conv generic map (sig_widthi => sig_width, 
                                  exp_widthi => exp_width, 
                                  sig_widtho => sig_width+2+3,
                                  exp_widtho => exp_width+1,
                                  use_denormal => ieee_compliance,
                                  use_1scmpl => 0)
          port map ( a => c, z => O1OI0l10 );
-- Instances of DW_ifp_addsub
  U4: DW_ifp_addsub generic map (sig_widthi => sig_width+2,
                                 exp_widthi => exp_width,
                                 sig_widtho => sig_width+2+3,
                                 exp_widtho => exp_width+1,
                                 use_denormal => ieee_compliance,
                                 use_1scmpl => 0)
          port map ( a => l010O0ll, b => Ol0010O0, rnd => rnd, op => '0', z => l11OOlI1);
  U5: DW_ifp_addsub generic map (sig_widthi => sig_width+2+3,
                                 exp_widthi => exp_width+1,
                                 sig_widtho => sig_width+2+3+sig_width,
                                 exp_widtho => exp_width+1+1,
                                 use_denormal => ieee_compliance,
                                 use_1scmpl => 0)
          port map ( a => l11OOlI1, b => O1OI0l10, rnd => rnd, op => '0', z => lO111I0I);
-- Instance of DW_ifp_fp_conv  -- format converter
  U6: DW_ifp_fp_conv generic map (sig_widthi => sig_width+2+3+sig_width,
                                  exp_widthi => exp_width+1+1,
                                  sig_width  => sig_width,
                                  exp_width  => exp_width,
                                  use_denormal => ieee_compliance)
          port map ( a => lO111I0I, rnd => rnd, z => z_temp1, status => lll0I1II );

-----------------------------------------------------------------------
-- purpose: main process for the behavioral description of the FP sum3
-- when arch_type = 0
-----------------------------------------------------------------------
-- type   : combinational
-- inputs : a, b, c, rnd
-- outputs: I0IO0O0O and l10O0O1I
MAIN_PROCESS: process (a, b, c, rnd)
variable ll110l1I : std_logic_vector(8    -1 downto 0);
variable lIOO1001 : std_logic_vector((exp_width + sig_width) downto 0);
variable I0Il0O1I, OO101OOO, O0I0O01O : std_logic;
variable Ol1Oll0I,O10111O0,OO0000OO :  std_logic_vector(exp_width-1 downto 0); -- Exponents.
variable OI011O11,OO0O001O,OOlI01lO :  std_logic_vector(sig_width-1 downto 0); -- fraction bits
variable lOO0I110,OO1OO1l0,l1O1I0OO :  std_logic_vector(sig_width downto 0);   -- The Mantissa numbers
variable OlOIO0l0, l111OO11, OlO1OOOI :  std_logic_vector(((2*(sig_width+1)+2+4)-1)-3 downto 0);
variable IIl00Ol1,OO01O0I1,OOO0O111 :  std_logic;                       -- sign bits
variable O111OlI1, O00llO1O, lOO0I0lO: std_logic;
 
-- special FP representations
variable lOI10110 : std_logic_vector(exp_width-1 downto 0) := (others => '0');
variable l1I10lIO : std_logic_vector(exp_width-1 downto 0) := (others => '0');
variable Ill0I1l1 : std_logic_vector(sig_width-1 downto 0) := (others => '0');
variable lOOI0lOl : std_logic_vector(exp_width-1 downto 0);
variable IOOll1IO : std_logic_vector((exp_width + sig_width + 1)-1 downto 0);  -- Not-a-number

-- The biggest possible exponent for addition/subtraction
variable Ol1I00ll : std_logic_vector(exp_width-1 downto 0);
variable I0OIOlO0, l0l1lOO0, OI100lII : std_logic_vector(exp_width-1 downto 0);
variable OO11I001 : std_logic_vector(exp_width+1 downto 0);
variable OI1lIl0O, O10IOI0O :  std_logic_vector((((2*(sig_width+1)+2+4)-1)-1)   downto 0); -- Mantissa of output
variable l10100l1 : std_logic_vector((((2*(sig_width+1)+2+4)-1)-1)   downto 0) := (others => '0');
variable O100O1I0 : std_logic_vector(sig_width downto 0) := (others => '0');
variable I11IIO1O : std_logic_vector(sig_width-1 downto 0) := (others => '0');
variable O0000lOl : std_logic_vector(sig_width+3 downto 0) := (others => '0');
variable I010lOO0 : std_logic_vector(OlOIO0l0'length-1 downto 0);

 -- Contains values returned by O1111O11 function.
variable IlO1I01O : std_logic_vector(4-1 downto 0);
variable OIOO111O : std_logic_vector(OI1lIl0O'length-1 downto 0);

-- indication of special cases for the inputs
variable lO0l111O, IO11011l, IOIOIllO : std_logic;
variable l0lI0000, l1O0O1OO, O1l111O0 : std_logic;
variable lIO0lIOl, Oll11OIO, I1IOO1OO : std_logic;
variable lOOll11l, IO00OO1I, l0I11010 : std_logic;

-- internal variables
variable O000OO0O, O0011101, OI10O11O :  std_logic_vector(((2*(sig_width+1)+2+4)-1) downto 0); 
variable OOIO01O1 :  std_logic_vector(((2*(sig_width+1)+2+4)-1) downto 0); 
variable O00IOO01 : std_logic;
variable l001011I :  std_logic_vector(((2*(sig_width+1)+2+4)-1)-1 downto 0); 
variable O1011Ol0, OOO1O1O1, lOIO1OO1 :  std_logic_vector(((2*(sig_width+1)+2+4)-1) downto 0); 
variable O001I111 : std_logic;
variable O1IOI01O : std_logic_vector(exp_width-1 downto 0);
variable lO010O10 : std_logic_vector((exp_width + sig_width + 1)-1 downto 0);
variable I00O01lO : std_logic_vector((exp_width + sig_width + 1)-1 downto 0);

begin  -- process MAIN_PROCESS

  lOOI0lOl := conv_std_logic_vector(((((2 ** (exp_width-1)) - 1) * 2) + 1), lOOI0lOl'length);
  l1I10lIO := lOI10110 + 1;
  IOOll1IO := '0' & lOOI0lOl & Ill0I1l1;
  if (ieee_compliance = 1) then
    IOOll1IO(0) := '1';  -- mantissa is 1 when number is NAN and ieee_compliance = 1
  else
    IOOll1IO(0) := '0';
  end if;
  ll110l1I := (others => '0');
  OIOO111O := (others => '0');
  OIOO111O(0) := '1';
  I010lOO0 := (others => '0');
  l10100l1 := (others => '0');
  O100O1I0 := (others => '0');
  I11IIO1O := (others => '0');
  O0000lOl := (others => '0');
  O111OlI1 := '0';
  O00llO1O := '0';
  lOO0I0lO := '0';

  Ol1Oll0I := a(((exp_width + sig_width) - 1) downto sig_width);
  O10111O0 := b(((exp_width + sig_width) - 1) downto sig_width);
  OO0000OO := c(((exp_width + sig_width) - 1) downto sig_width);
  OI011O11 := a((sig_width - 1) downto 0);
  OO0O001O := b((sig_width - 1) downto 0);
  OOlI01lO := c((sig_width - 1) downto 0);
  IIl00Ol1 := a((exp_width + sig_width));
  OO01O0I1 := b((exp_width + sig_width));
  OOO0O111 := c((exp_width + sig_width)); 
  lO010O10((exp_width + sig_width)) := '0';
  lO010O10(((exp_width + sig_width) - 1) downto sig_width) := conv_std_logic_vector(((((2 ** (exp_width-1)) - 1) * 2) + 1),exp_width);
  lO010O10((sig_width - 1) downto 0) := (others => '0');
  I00O01lO((exp_width + sig_width)) := '1';
  I00O01lO(((exp_width + sig_width) - 1) downto sig_width) := conv_std_logic_vector(((((2 ** (exp_width-1)) - 1) * 2) + 1),exp_width);
  I00O01lO((sig_width - 1) downto 0) := (others => '0');

  if ((Ol1Oll0I = lOOI0lOl) and ((OI011O11 = Ill0I1l1) or (ieee_compliance = 0))) then 
     l0lI0000 := '1';
  else
     l0lI0000 := '0';
  end if;
  if ((O10111O0 = lOOI0lOl) and ((OO0O001O = Ill0I1l1) or (ieee_compliance = 0))) then 
     l1O0O1OO := '1';
  else
     l1O0O1OO := '0';
  end if;
  if ((OO0000OO = lOOI0lOl) and ((OOlI01lO = Ill0I1l1) or (ieee_compliance = 0))) then 
     O1l111O0 := '1';
  else
     O1l111O0 := '0';
  end if;
  if ((Ol1Oll0I = lOOI0lOl) and (OI011O11 /= Ill0I1l1) and (ieee_compliance = 1)) then 
     lIO0lIOl := '1';
  else
     lIO0lIOl := '0';
  end if;
  if ((O10111O0 = lOOI0lOl) and (OO0O001O /= Ill0I1l1) and (ieee_compliance = 1)) then 
     Oll11OIO := '1';
  else
     Oll11OIO := '0';
  end if;
  if ((OO0000OO = lOOI0lOl) and (OOlI01lO /= Ill0I1l1) and (ieee_compliance = 1)) then 
     I1IOO1OO := '1';
  else
     I1IOO1OO := '0';
  end if;
  if ((Ol1Oll0I = lOI10110) and ((OI011O11 = Ill0I1l1) or (ieee_compliance = 0))) then
     lOOll11l := '1';
     OI011O11 := (others => '0');
  else
     lOOll11l := '0';
  end if;
  if ((O10111O0 = lOI10110) and ((OO0O001O = Ill0I1l1) or (ieee_compliance = 0))) then
     IO00OO1I := '1';
     OO0O001O := (others => '0');
  else
     IO00OO1I := '0';
  end if;
  if ((OO0000OO = lOI10110) and ((OOlI01lO = Ill0I1l1) or (ieee_compliance = 0))) then
     l0I11010 := '1';
     OOlI01lO := (others => '0');
  else
     l0I11010 := '0';
  end if;
  if ((Ol1Oll0I = lOI10110) and (OI011O11 /= Ill0I1l1) and (ieee_compliance = 1)) then
    lO0l111O := '1';
    Ol1Oll0I := l1I10lIO;
  else
     lO0l111O := '0';
  end if;
  if ((O10111O0 = lOI10110) and (OO0O001O /= Ill0I1l1) and (ieee_compliance = 1)) then
    IO11011l := '1';
    O10111O0 := l1I10lIO;
  else
     IO11011l := '0';
  end if;
  if ((OO0000OO = lOI10110) and (OOlI01lO /= Ill0I1l1) and (ieee_compliance = 1)) then
    IOIOIllO := '1';
    OO0000OO := l1I10lIO;
  else
    IOIOIllO := '0';
  end if;


  if ((lIO0lIOl = '1') or (Oll11OIO = '1') or (I1IOO1OO = '1')) then
    lIOO1001 := IOOll1IO;
    ll110l1I(2) := '1';

  elsif  (l0lI0000 = '1') then
    if (((l1O0O1OO = '1') and (IIl00Ol1 /= OO01O0I1)) or ((O1l111O0 = '1') and (IIl00Ol1 /= OOO0O111))) then
      ll110l1I(2) := '1';
      lIOO1001 := IOOll1IO;
      if (ieee_compliance = 1) then
        ll110l1I(1) := '0';
      else
        ll110l1I(1) := '1';
      end if;
    else 
      ll110l1I(1) := '1';
      if (IIl00Ol1 = '1') then
        lIOO1001 := I00O01lO;
      else
        lIOO1001 := lO010O10;
      end if;
    end if;
  elsif (l1O0O1OO = '1') then
    if (((l0lI0000 = '1') and (IIl00Ol1 /= OO01O0I1)) or ((O1l111O0 = '1') and (OO01O0I1 /= OOO0O111))) then
      lIOO1001 := IOOll1IO;
      ll110l1I(2) := '1';
      if (ieee_compliance = 1) then
        ll110l1I(1) := '0';
      else
        ll110l1I(1) := '1';
      end if;
    else
      ll110l1I(1) := '1';
      if (OO01O0I1 = '1') then
        lIOO1001 := I00O01lO;
      else
        lIOO1001 := lO010O10;
      end if;
    end if;
  elsif (O1l111O0 = '1') then
    if (((l0lI0000 = '1') and (IIl00Ol1 /= OOO0O111)) or ((l1O0O1OO = '1') and (OO01O0I1 /= OOO0O111))) then
      lIOO1001 := IOOll1IO;
      ll110l1I(2) := '1';
       if (ieee_compliance = 1) then
        ll110l1I(1) := '0';
      else
        ll110l1I(1) := '1';
      end if;
   else
      ll110l1I(1) := '1';
      if (OOO0O111 = '1') then
        lIOO1001 := I00O01lO;
      else
        lIOO1001 := lO010O10;
      end if;
    end if;
  
  elsif ((lOOll11l = '1') and (IO00OO1I = '1') and (l0I11010 = '1')) then
      lIOO1001 := (others => '0');
      ll110l1I(0) := '1';
      if (ieee_compliance = 0) then
        if (rnd = "011") then
          lIOO1001((exp_width + sig_width)) := '1';
        else
          lIOO1001((exp_width + sig_width)) := '0';
        end if;
      else
        if ((IIl00Ol1 = OO01O0I1) and (OO01O0I1 = OOO0O111)) then
          lIOO1001((exp_width + sig_width)) := IIl00Ol1;
        else
          if (rnd = "011") then
            lIOO1001((exp_width + sig_width)) := '1';
          else
            lIOO1001((exp_width + sig_width)) := '0';
          end if;
        end if;
      end if;

  elsif ((a(((exp_width + sig_width) - 1) downto 0) = b(((exp_width + sig_width) - 1) downto 0)) and (IIl00Ol1 /= OO01O0I1)) then
    lIOO1001 := c;
    ll110l1I(0) := l0I11010;
    ll110l1I(3) := IOIOIllO;
    if (l0I11010 = '1') then
        if (rnd = "011") then
          lIOO1001((exp_width + sig_width)) := '1';
        else
          lIOO1001((exp_width + sig_width)) := '0';
        end if;
    end if;

  elsif ((b(((exp_width + sig_width) - 1) downto 0) = c(((exp_width + sig_width) - 1) downto 0)) and (OO01O0I1 /= OOO0O111)) then
    lIOO1001 := a;
    ll110l1I(0) := lOOll11l;
    ll110l1I(3) := lO0l111O;
    if (lOOll11l = '1') then
        if (rnd = "011") then
          lIOO1001((exp_width + sig_width)) := '1';
        else
          lIOO1001((exp_width + sig_width)) := '0';
        end if;
    end if;

  elsif ((a(((exp_width + sig_width) - 1) downto 0) = c(((exp_width + sig_width) - 1) downto 0)) and (IIl00Ol1 /= OOO0O111)) then
    lIOO1001 := b;
    ll110l1I(0) := IO00OO1I;
    ll110l1I(3) := IO11011l;
    if (IO00OO1I = '1') then
        if (rnd = "011") then
          lIOO1001((exp_width + sig_width)) := '1';
        else
          lIOO1001((exp_width + sig_width)) := '0';
        end if;
    end if;

  else                                          
    if (lO0l111O = '1' or lOOll11l = '1') then
       if (ieee_compliance = 1) then
          lOO0I110 := "0" & OI011O11;
       else
          lOO0I110 := O100O1I0;
       end if;
    else
       lOO0I110 := "1" & OI011O11;
    end if;
    if (IO11011l = '1' or IO00OO1I = '1') then
       if (ieee_compliance = 1) then
          OO1OO1l0 := "0" & OO0O001O;
       else
          OO1OO1l0 := O100O1I0;
       end if;
    else
       OO1OO1l0 := "1" & OO0O001O;
    end if;
    if (IOIOIllO = '1' or l0I11010 = '1') then
       if (ieee_compliance = 1) then
          l1O1I0OO := "0" & OOlI01lO;
       else
          l1O1I0OO := O100O1I0;
       end if;
    else
       l1O1I0OO := "1" & OOlI01lO;
    end if;
  
    if ((Ol1Oll0I > O10111O0) and (Ol1Oll0I > OO0000OO)) then
      Ol1I00ll := Ol1Oll0I;
    elsif ((O10111O0 >= Ol1Oll0I) and (O10111O0 > OO0000OO)) then
      Ol1I00ll := O10111O0;
    else
      Ol1I00ll := OO0000OO;
    end if;
    I0OIOlO0 := Ol1I00ll - Ol1Oll0I;
    l0l1lOO0 := Ol1I00ll - O10111O0;
    OI100lII := Ol1I00ll - OO0000OO;

    I0Il0O1I := '0';
    OlOIO0l0 := lOO0I110 & O0000lOl;
    O1IOI01O := I0OIOlO0;
    while ( (OlOIO0l0 /= I010lOO0) and (O1IOI01O /= lOI10110) )  loop
      I0Il0O1I := OlOIO0l0(0) or I0Il0O1I;
      OlOIO0l0 := '0' & OlOIO0l0(OlOIO0l0'length-1 downto 1);
      O1IOI01O := O1IOI01O - 1;
    end loop;
    I0Il0O1I := OlOIO0l0(0) or I0Il0O1I;
    OlOIO0l0(0) := '0';

    OO101OOO := '0';
    l111OO11 := OO1OO1l0 & O0000lOl;
    O1IOI01O := l0l1lOO0;
    while ( (l111OO11 /= I010lOO0) and (O1IOI01O /= lOI10110) )  loop
      OO101OOO := l111OO11(0) or OO101OOO;
      l111OO11 := '0' & l111OO11(l111OO11'length-1 downto 1);
      O1IOI01O := O1IOI01O - 1;
    end loop;
    OO101OOO := l111OO11(0) or OO101OOO;
    l111OO11(0) := '0';

    O0I0O01O := '0';
    OlO1OOOI := l1O1I0OO & O0000lOl;
    O1IOI01O := OI100lII;
    while ( (OlO1OOOI /= I010lOO0) and (O1IOI01O /= lOI10110) )  loop
      O0I0O01O := OlO1OOOI(0) or O0I0O01O;
      OlO1OOOI := '0' & OlO1OOOI(OlO1OOOI'length-1 downto 1);
      O1IOI01O := O1IOI01O - 1;
    end loop;
    O0I0O01O := OlO1OOOI(0) or O0I0O01O; 
    OlO1OOOI(0) := '0';

    if ((I0Il0O1I = '1') and (OO101OOO = '1')) then
      if ((Ol1Oll0I & lOO0I110) < (O10111O0 & OO1OO1l0)) then
        O111OlI1 := '1';
      else
        O111OlI1 := '0';
      end if;
      O00llO1O := not O111OlI1;
      lOO0I0lO := '0';
    end if;
    if ((OO101OOO = '1') and (O0I0O01O = '1')) then
      if ((O10111O0 & OO1OO1l0) < (OO0000OO & l1O1I0OO)) then
        O00llO1O := '1';
      else
        O00llO1O := '0';
      end if;
      lOO0I0lO := not O00llO1O;
      O111OlI1 := '0';
    end if;
    if ((I0Il0O1I = '1') and (O0I0O01O = '1')) then
      if ((Ol1Oll0I & lOO0I110) < (OO0000OO & l1O1I0OO)) then
        O111OlI1 := '1';
      else
        O111OlI1 := '0';
      end if;
      lOO0I0lO := not O111OlI1;
      O00llO1O := '0';
    end if;

    O1011Ol0 := "000" & OlOIO0l0(OlOIO0l0'length-1 downto 1) & ((not O111OlI1 and I0Il0O1I) or OlOIO0l0(0));
    OOO1O1O1 := "000" & l111OO11(l111OO11'length-1 downto 1) & ((not O00llO1O and OO101OOO) or l111OO11(0));
    lOIO1OO1 := "000" & OlO1OOOI(OlO1OOOI'length-1 downto 1) & ((not lOO0I0lO and O0I0O01O) or OlO1OOOI(0));

    if (IIl00Ol1 = '1') then
      O000OO0O := (not O1011Ol0) + 1;
    else 
      O000OO0O := O1011Ol0;
    end if;
    if (OO01O0I1 = '1') then
      O0011101 := (not OOO1O1O1) + 1;
    else 
      O0011101 := OOO1O1O1;
    end if;
    if (OOO0O111 = '1') then
      OI10O11O := (not lOIO1OO1) + 1;
    else 
      OI10O11O := lOIO1OO1;
    end if;

    OOIO01O1 := O000OO0O + O0011101 + OI10O11O;
    
    O00IOO01 := OOIO01O1(((2*(sig_width+1)+2+4)-1));
    if (O00IOO01 = '1') then
      l001011I := (not OOIO01O1(((2*(sig_width+1)+2+4)-1)-1 downto 0))+1;
    else
      l001011I := OOIO01O1(((2*(sig_width+1)+2+4)-1)-1 downto 0);
    end if;

    OI1lIl0O := l001011I;
    O10IOI0O := l001011I;
    
    OO11I001 := "00" & Ol1I00ll;

    O001I111 := '0';
    if (OI1lIl0O((((2*(sig_width+1)+2+4)-1)-1)  ) = '1') then
      OO11I001 := OO11I001 + 1;
      O001I111 := OI1lIl0O(0);
      OI1lIl0O := '0' & OI1lIl0O(OI1lIl0O'length-1 downto 1);
    end if;
    if (OI1lIl0O((((2*(sig_width+1)+2+4)-1)-1)  -1) = '1') then
      OO11I001 := OO11I001 + 1;
      O001I111 := OI1lIl0O(0) or O001I111;
      OI1lIl0O := '0' & OI1lIl0O(OI1lIl0O'length-1 downto 1);
    end if;
    while ( (OI1lIl0O((((2*(sig_width+1)+2+4)-1)-1)  -2) = '0') and (OO11I001 > l1I10lIO) ) loop
      OO11I001 := OO11I001 - 1;
      OI1lIl0O := OI1lIl0O(OI1lIl0O'length-2 downto 0) & '0';
    end loop;

    IlO1I01O := O1111O11(rnd, O00IOO01, OI1lIl0O(((((2*(sig_width+1)+2+4)-1)-1)  -2-sig_width)), OI1lIl0O((((((2*(sig_width+1)+2+4)-1)-1)  -2-sig_width)-1) ),
               (or_reduce(OI1lIl0O((((((2*(sig_width+1)+2+4)-1)-1)  -2-sig_width)-1) -1 downto 0)&I0Il0O1I&OO101OOO&O0I0O01O&O001I111)));

    if (IlO1I01O(0) = '1') then
      OI1lIl0O := OI1lIl0O + my_sll(OIOO111O,((((2*(sig_width+1)+2+4)-1)-1)  -2-sig_width));
    end if;   

    if ( (OI1lIl0O((((2*(sig_width+1)+2+4)-1)-1)  -1) = '1') ) then
      OO11I001 := OO11I001 + 1;
      OI1lIl0O := '0' & OI1lIl0O((((2*(sig_width+1)+2+4)-1)-1)   downto 1);
    end if;

    if (OI1lIl0O = l10100l1) then
      ll110l1I(0) := '1';
      lIOO1001 := (others => '0');
      if (rnd = "011") then
        lIOO1001((exp_width + sig_width)) := '1';
      else
        lIOO1001((exp_width + sig_width)) := '0';
      end if;
 
    else
      if (OI1lIl0O((((2*(sig_width+1)+2+4)-1)-1)   downto (((2*(sig_width+1)+2+4)-1)-1)  -2) = "000") then
         if (ieee_compliance = 1) then
           lIOO1001 := O00IOO01 & lOI10110 & OI1lIl0O((((2*(sig_width+1)+2+4)-1)-1)  -3 downto ((((2*(sig_width+1)+2+4)-1)-1)  -2-sig_width));
           ll110l1I(3) := '1';
           ll110l1I(5) := IlO1I01O(1);
           if (OI1lIl0O((((2*(sig_width+1)+2+4)-1)-1)  -3 downto ((((2*(sig_width+1)+2+4)-1)-1)  -2-sig_width)) = I11IIO1O) then
             ll110l1I(0) := '1'; 
           end if;
         else
           ll110l1I(3) := '1';
           ll110l1I(5) := '1';
           if ((rnd = "011" and O00IOO01 = '1') or
               (rnd = "010" and O00IOO01 = '0') or
               rnd = "101") then
             lIOO1001 := O00IOO01 & l1I10lIO & Ill0I1l1;
             ll110l1I(0) := '0';
           else
             lIOO1001 := O00IOO01 & lOI10110 & Ill0I1l1;
             ll110l1I(0) := '1';
           end if;
         end if;

      else
        if (OO11I001 >= conv_std_logic_vector(((((2 ** (exp_width-1)) - 1) * 2) + 1),OO11I001'length)) then
          ll110l1I(5) := '1';
          ll110l1I(4) := '1';
          if (IlO1I01O(2) = '1') then
            OI1lIl0O := (others => '0');
            OO11I001 := conv_std_logic_vector(((((2 ** (exp_width-1)) - 1) * 2) + 1),OO11I001'length);
            ll110l1I(1) := '1';
          else
            OO11I001 := conv_std_logic_vector(((((2 ** (exp_width-1)) - 1) * 2) + 1),OO11I001'length) - 1;
            OI1lIl0O := (others => '1');
          end if;
        else
          if (OO11I001 <= conv_std_logic_vector(0,OO11I001'length)) then
            OO11I001 := conv_std_logic_vector(0,OO11I001'length) + 1;
          end if;
        end if;

          ll110l1I(5) :=  ll110l1I(5) or
                                          IlO1I01O(1);
          lIOO1001 := O00IOO01 & OO11I001(exp_width-1 downto 0) & OI1lIl0O((((2*(sig_width+1)+2+4)-1)-1)  -3 downto ((((2*(sig_width+1)+2+4)-1)-1)  -2-sig_width));

      end if;
      
    end if;

  end if;

  I0IO0O0O <= ll110l1I;
  l10O0O1I <= lIOO1001;

end process MAIN_PROCESS;

--
-- purpose: process the output values
-- type   : combinational
-- inputs : a,b,c,rnd,z_temp1,l10O0O1I,lll0I1II,I0IO0O0O
-- outputs: status and lIOO1001
SELECT_OUTPUT: process (a, b, c, rnd, z_temp1, l10O0O1I, lll0I1II, I0IO0O0O)
begin
  if (Is_X(a) or Is_X(b) or Is_X(c) or Is_X(rnd)) then
    status <= (others => 'X');
    z <= (others => 'X');
  else
    if (arch_type = 1) then
      status <= lll0I1II;
      z <= z_temp1;
    else
      status <= I0IO0O0O;
      z <= l10O0O1I;
    end if;
  end if;
end process SELECT_OUTPUT;

-- pragma translate_on  

end sim ;

--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

library dw02;

configuration DW_fp_sum3_cfg_sim of DW_fp_sum3 is
 for sim
  for U1: DW_fp_ifp_conv use configuration dw02.DW_fp_ifp_conv_cfg_sim; end for;
  for U2: DW_fp_ifp_conv use configuration dw02.DW_fp_ifp_conv_cfg_sim; end for;
  for U3: DW_fp_ifp_conv use configuration dw02.DW_fp_ifp_conv_cfg_sim; end for;
  for U4: DW_ifp_addsub use configuration dw02.DW_ifp_addsub_cfg_sim; end for;
  for U5: DW_ifp_addsub use configuration dw02.DW_ifp_addsub_cfg_sim; end for;
  for U6: DW_ifp_fp_conv use configuration dw02.DW_ifp_fp_conv_cfg_sim; end for;
 end for; -- sim
end DW_fp_sum3_cfg_sim;
-- pragma translate_on

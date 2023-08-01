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
-- AUTHOR:    Alexandre F. Tenca - September 2007
--
-- VERSION:   VHDL Simulation Model - FP Base-2 Exponential
--
-- DesignWare_version: 2e0d533e
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--
-- ABSTRACT: Floating-point Base-2 Exponential
--           Computes the base-2 exponential of a Floating-point number
--
--              parameters      valid values (defined in the DW manual)
--              ==========      ============
--              sig_width       significand size,  2 to 60 bits
--              exp_width       exponent size,     3 to 31 bits
--              ieee_compliance 0 or 1
--              arch            implementation select
--                              0 - area optimized
--                              1 - speed optimized
--                              2 - 2007.12 implementation (default)
--
--              Input ports     Size & Description
--              ===========     ==================
--              a               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Input
--
--              Output ports    Size & Description
--              ===========     ==================
--              z               (sig_width + exp_width + 1) bits
--                              Floating-point Number that represents exp2(a)
--              status          byte
--                              Status information about FP operation
--
-- MODIFIED:
--          05/2008 - AFT - Fixed the inexact status bit.
--                    Fixed the tiny bit when ieee_compliance = 1. This bit
--                    must be set to 1 whenever the output is a denormal.
--          August 2008 - AFT - included new parameter (arch) and fixed some
--                   issues with accuracy and status information.
--          07/2015 - AFT - Star 9000927455
--                   Fix incorrect results when the exponent field size is 
--                   too small. The size of some variables had to be increased
--                   to avoid overflow during calculations for these 
--                   special configurations. Since this is the simulation 
--                   model, the increase in the variable size was done 
--                   independently of the ieee_compliance value. Also reduced
--                   the upper bound of sig_width to 58 to avoid incorrect
--                   configuration of DW_exp2.
--
---------------------------------------------------------------------------------

library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_misc.all;
use DWARE.DW_Foundation_arith.all;
use DWARE.DW_Foundation_comp_arith.all;

architecture sim of DW_fp_exp2 is
	
-- pragma translate_off

-- definitions used in the code

  signal OI1lOOII, OO01I101 : std_logic_vector ((exp_width + sig_width + 1)-1 downto 0);
  signal O01Ol0OO, OO11O101 : std_logic_vector (8    -1 downto 0);
  signal IOIOO00l : std_logic_vector (sig_width+1 downto 0);
  signal I0l1l1O0 : std_logic_vector(sig_width+1 downto 0);
  signal O1I1OOI0 : std_logic_vector (sig_width+1 downto 0);
  signal Ol0lIO10 : signed (exp_width+sig_width downto 0);
  signal I11l1110 : signed (exp_width+1 downto 0);
  signal O11ll11O : std_logic;
  signal l0010011, Ol1I0O1O, I00O0l0I, lO0O0OOl : std_logic;
  signal IOOIl0OI : std_logic;

-- pragma translate_on
begin
-- pragma translate_off
  
    
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
    
    if ( (sig_width < 2) OR (sig_width > 58) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter sig_width (legal range: 2 to 58)"
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
    
    if ( (arch < 0) OR (arch > 2) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter arch (legal range: 0 to 2)"
        severity warning;
    end if;
    
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;  

  Pre_process: process (a)
  variable l0lllII1 : std_logic;
  variable OIO10O00 : unsigned (exp_width downto 0);
  variable IO001001 : signed (exp_width+sig_width downto 0);
  variable l0Ol0000 : std_logic_vector (sig_width downto 0);
  variable I0OO1lOl : std_logic_vector (sig_width-1 downto 0);
  variable OIl100OI : std_logic_vector (sig_width-1 downto 0);
  variable l110Il0O : unsigned (exp_width downto 0);
  variable OO01OIO0 : std_logic_vector ((exp_width + sig_width + 1)-1 downto 0);
  variable Ol0l11lI: std_logic_vector (8    -1 downto 0);
  variable O0100111, O1ll0OO1, O1O1OOl1, Il1OIl01 : std_logic;
  variable O0OO001l : std_logic_vector((exp_width + sig_width + 1)-1 downto 0);
  variable IIOOl011 : std_logic_vector((exp_width + sig_width + 1)-1 downto 0);
  variable I1O11101 : std_logic_vector((exp_width + sig_width + 1)-1 downto 0);
  variable l1l0101I : std_logic_vector((exp_width + sig_width + 1)-1 downto 0);
  variable lOIl1IOO : std_logic_vector (sig_width+1 downto 0);
  variable O1010O00 : std_logic_vector(exp_width-2 downto 0);  
  variable O1l111I0 : std_logic_vector(exp_width-1 downto 0);
  begin

  O1l111I0 := conv_std_logic_vector(((((2 ** (exp_width-1)) - 1) * 2) + 1), O1l111I0'length);
  OIl100OI := (others => '0');
  l110Il0O := (others => '0');
  O1010O00 := conv_std_logic_vector(((2 ** (exp_width-1)) - 1), exp_width-1);
  OIO10O00 := unsigned('0'& a(((exp_width + sig_width) - 1) downto sig_width));
  IO001001 := conv_signed(OIO10O00,exp_width+sig_width+1);
  I0OO1lOl := a((sig_width - 1) downto 0);
  O0100111 := '0';
  O0OO001l := '0' & O1l111I0 & OIl100OI;
  if (ieee_compliance = 1) then
      O0OO001l(0) := '1';
  end if;
  IIOOl011 := '1' &  O1l111I0 & OIl100OI;
  I1O11101 := '0' &  O1l111I0 & OIl100OI;
  l1l0101I := '0' & '0' & O1010O00 & OIl100OI;
    
  if (ieee_compliance = 1 and OIO10O00 = l110Il0O) then
    if (I0OO1lOl = OIl100OI) then
        O0100111 := '1';
        O1ll0OO1 := '0';
      else
        O0100111 := '0';
        O1ll0OO1 := '1';
        IO001001(0) := '1';
    end if;
    l0Ol0000 := '0' & I0OO1lOl;
  elsif (ieee_compliance = 0 and OIO10O00 = l110Il0O) then
    l0Ol0000 := '0' & OIl100OI;
    O0100111 := '1';
    O1ll0OO1 := '0';
  else
    l0Ol0000 := '1' & I0OO1lOl;
    O0100111 := '0';
    O1ll0OO1 := '0';
  end if;
    
  if ((OIO10O00(exp_width-1 downto 0) = ((((2 ** (exp_width-1)) - 1) * 2) + 1)) and
       ((ieee_compliance = 0) or (I0OO1lOl = OIl100OI))) then
        O1O1OOl1 := '1';
      else
        O1O1OOl1 := '0';
  end if;

  if ((OIO10O00(exp_width-1 downto 0) = ((((2 ** (exp_width-1)) - 1) * 2) + 1)) and
       (ieee_compliance = 1) and (I0OO1lOl /= OIl100OI)) then
        Il1OIl01 := '1';
      else
        Il1OIl01 := '0';
  end if;

  l0lllII1 := a((exp_width + sig_width));
    
  Ol0l11lI := (others => '0');
  OO01OIO0 := (others => '0');
  lOIl1IOO := (others => '1');
    
  if (Il1OIl01 = '1') then
    OO01OIO0 := O0OO001l;
    Ol0l11lI(2) := '1';

  elsif ((O1O1OOl1 = '1') and (l0lllII1 = '0')) then  
    OO01OIO0 := I1O11101;
    Ol0l11lI(1) := '1';

  elsif ((O1O1OOl1 = '1') and (l0lllII1 = '1')) then  
    OO01OIO0 := (others => '0');
    Ol0l11lI(0) := '1';

  elsif (O0100111 = '1') then    
    OO01OIO0 := l1l0101I;

  elsif (O1ll0OO1 = '1') then	
    lOIl1IOO := l0Ol0000 & '0';
    while lOIl1IOO(lOIl1IOO'left) = '0' loop
      lOIl1IOO := lOIl1IOO(lOIl1IOO'length-2 downto 0) & '0';
      IO001001 := IO001001 - 1;
    end loop;
    OO01OIO0 := (others => '0');

  else
     lOIl1IOO := l0Ol0000 & '0';
     OO01OIO0 := (others => '0');
  end if;

  OI1lOOII <= OO01OIO0;
  O01Ol0OO <= Ol0l11lI;
  IOIOO00l <= lOIl1IOO;
  Ol0lIO10 <= IO001001 - conv_signed(unsigned(O1010O00),exp_width+sig_width+1);
  O11ll11O <= l0lllII1;
  l0010011 <= O0100111;
  Ol1I0O1O <= O1ll0OO1;
  I00O0l0I <= O1O1OOl1;
  lO0O0OOl <= Il1OIl01;
  end process Pre_process;
---------------------------------------------------------------

  Main_process: process (IOIOO00l,Ol0lIO10,O11ll11O)
  variable I1l11l1l : signed (exp_width+sig_width downto 0);
  variable O1IIIO11 : std_logic_vector(sig_width+exp_width+3 downto 0);
  variable l1l0OOOl : signed(exp_width+1 downto 0);
  variable OOO1000I : std_logic_vector(sig_width+1 downto 0);
  variable l1IO0l1I : std_logic;
  variable O11O0I0O : std_logic_vector(exp_width+1 downto 0);
  variable O0O010l0 : std_logic_vector(sig_width+1 downto 0);
  variable l101IO1O : integer;
  variable I1IlO1II : std_logic;
  begin
    I1l11l1l := Ol0lIO10;
    O11O0I0O := (others => '0');
    O1IIIO11 := O11O0I0O & IOIOO00l;
    I1IlO1II := '0';
    if (conv_integer(I1l11l1l) < -1) then
      while (conv_integer(I1l11l1l) < -1) loop
        I1IlO1II := I1IlO1II or O1IIIO11(0);
        O1IIIO11 := '0' & O1IIIO11(O1IIIO11'left downto 1);
        I1l11l1l := I1l11l1l + 1;
      end loop;
    else
      if (conv_integer(I1l11l1l) > -1) then
        l101IO1O := 0;
        while (conv_integer(I1l11l1l) > -1 and l101IO1O < (I1l11l1l'length+1) and
               O1IIIO11(O1IIIO11'left) = '0') loop
          O1IIIO11 := O1IIIO11(O1IIIO11'left-1 downto 0) & '0';
          I1l11l1l := I1l11l1l - 1;
          l101IO1O := l101IO1O + 1;
        end loop;
      end if;
    end if;
    IOOIl0OI <= I1IlO1II;
                    
      l1l0OOOl := signed(O1IIIO11(O1IIIO11'left downto O1IIIO11'left-exp_width-1));
      OOO1000I := O1IIIO11(sig_width+1 downto 0);
      if (conv_integer(OOO1000I) = 0) then
        l1IO0l1I := '1';
      else
        l1IO0l1I := '0';
      end if;
                    
      if (O11ll11O = '1') then
        if (l1IO0l1I = '1') then
          I11l1110 <= -(l1l0OOOl);
        else
          I11l1110 <= -(l1l0OOOl+1);
        end if;
      else
        I11l1110 <= l1l0OOOl;
      end if;

    if (O11ll11O = '1' and l1IO0l1I = '0') then
      O0O010l0 := unsigned(not OOO1000I) + 1;
    else
      O0O010l0 := OOO1000I;
    end if;
    I0l1l1O0 <= O0O010l0;
  end process Main_process;

--------------------------------------------------------------
    
  U1 : DW_exp2 generic map (op_width => sig_width+2,
                            arch => arch,
                            err_range => 1)
       port map (a => I0l1l1O0,
                 z => O1I1OOI0);

--------------------------------------------------------------

  Post_process: process (I0l1l1O0, O1I1OOI0, Ol0lIO10, I11l1110, O11ll11O, IOOIl0OI)
    variable I0OIl11O : signed (exp_width+1 downto 0);
    variable I01O1O11: std_logic_vector(sig_width downto 0);
    variable l110Il0O : std_logic_vector (exp_width-1 downto 0);
    variable O01I1lOl : std_logic_vector (8    -1 downto 0);
    variable IIl01O01 : std_logic_vector ((exp_width + sig_width + 1)-1 downto 0);
    variable lOOI1OOO : boolean;
    variable l0O0IOOO : boolean;
    variable IIO0O111 : signed (exp_width+1 downto 0);
    variable Ill00OO0 : signed (exp_width+sig_width downto 0);
    variable I1O11101 : std_logic_vector((exp_width + sig_width + 1)-1 downto 0);
    variable O1l111I0 : std_logic_vector(exp_width-1 downto 0);
    variable OIl100OI : std_logic_vector (sig_width-1 downto 0);
    variable IllO110I : signed (exp_width downto 0);
    variable l1OI1IOl : std_logic;
  begin
    O1l111I0 := conv_std_logic_vector(((((2 ** (exp_width-1)) - 1) * 2) + 1), O1l111I0'length);
    l110Il0O := (others => '0');
    OIl100OI := (others => '0');
    I1O11101 := '0' &  O1l111I0 & OIl100OI;
    IIl01O01 := (others => '0');
    O01I1lOl := (others => '0');
    O01I1lOl(5) := or_reduce(I0l1l1O0) or IOOIl0OI;
    I0OIl11O := I11l1110;
    I01O1O11 := O1I1OOI0(O1I1OOI0'left downto 1) + 
                   O1I1OOI0(0);
                    
    if (and_reduce(O1I1OOI0) = '1') then
      I0OIl11O := I0OIl11O + 1;
      I01O1O11(I01O1O11'left) := '1';
    end if;
    
      IllO110I := conv_signed(((2 ** (exp_width-1)) - 1), IllO110I'length);
      IIO0O111 := conv_signed(I0OIl11O,IIO0O111'length) +
                         conv_signed(IllO110I,IIO0O111'length);

    lOOI1OOO := false;
    l0O0IOOO := false;
      Ill00OO0 := Ol0lIO10 - conv_signed(exp_width,Ol0lIO10'length) + 1;
      if (conv_integer(Ill00OO0) > 0 and conv_integer(Ol0lIO10) > 0 and
          O11ll11O = '0') then
        lOOI1OOO := true;
      else
       if ((conv_integer(IIO0O111) >= (2**exp_width-1)) and
           (O11ll11O = '0')) then
           lOOI1OOO := true;
       end if;
      end if;
                                                     
      if (conv_integer(Ill00OO0) > 0 and conv_integer(Ol0lIO10) > 0 and
          O11ll11O = '1') then
           l0O0IOOO := true;
      end if;
      if (IIO0O111 <= 0) then
        if (ieee_compliance = 1) then
            l0O0IOOO := false;
            l1OI1IOl := '0';
            while (IIO0O111 <= 0) loop
              IIO0O111 := IIO0O111 + 1;
              l1OI1IOl := I01O1O11(0);
              I01O1O11 := '0' & I01O1O11(I01O1O11'length-1 downto 1);
            end loop;
            I01O1O11 := I01O1O11 + l1OI1IOl;
        else
          l0O0IOOO := true;
        end if;
      end if;
         
    if (lOOI1OOO) then
      IIl01O01 := I1O11101;
      O01I1lOl(1) := '1';
      O01I1lOl(4) := '1';
      O01I1lOl(5) := '1';
    elsif (l0O0IOOO) then
      IIl01O01 := (others => '0');
      O01I1lOl(0) := '1';
      if (ieee_compliance = 0) then
        O01I1lOl(3) := '1';
      else
        O01I1lOl(3) := '0';
      end if;
      O01I1lOl(5) := '1';
    else
        if (I01O1O11(I01O1O11'left) = '0') then
            IIl01O01 := '0' & conv_std_logic_vector(0,exp_width) &
                           I01O1O11(sig_width-1 downto 0);
            if (conv_integer(I01O1O11(sig_width-1 downto 0)) = 0) then
              O01I1lOl(0) := '1';
              O01I1lOl(5) := '1';
            else
              O01I1lOl(3) := '1';
            end if;
        else
            IIl01O01 := '0' & conv_std_logic_vector(IIO0O111(exp_width-1 downto 0),exp_width) &
                           I01O1O11(sig_width-1 downto 0);
        end if;
    end if;
                    
    OO01I101 <= IIl01O01;
    OO11O101 <= O01I1lOl;
  end process Post_process;

  z <= (others => 'X') when Is_X(a) else
       OI1lOOII when (conv_integer(O01Ol0OO) /= 0 or conv_integer(OI1lOOII) /= 0) else OO01I101;
  status <= (others => 'X') when Is_X(a) else
            O01Ol0OO when (conv_integer(O01Ol0OO) /= 0 or conv_integer(OI1lOOII) /= 0) else OO11O101;
    
-- pragma translate_on  
end sim ;

--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

library dw02;

configuration DW_fp_exp2_cfg_sim of DW_fp_exp2 is
 for sim
  for U1 : DW_exp2 use configuration dw02.DW_exp2_cfg_sim; end for;
 end for; -- sim
end DW_fp_exp2_cfg_sim;
-- pragma translate_on

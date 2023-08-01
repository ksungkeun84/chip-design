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
-- AUTHOR:    Alexandre F. Tenca - May 2008
--
-- VERSION:   VHDL Simulation Model - FP Exponential
--
-- DesignWare_version: 718355ae
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--
-- ABSTRACT: Floating-point Exponential
--           Computes the exponential of a Floating-point number
--
--              parameters      valid values (defined in the DW manual)
--              ==========      ============
--              sig_width       significand size,  2 to 60 bits
--              exp_width       exponent size,     3 to 31 bits
--              ieee_compliance 0 or 1
--              arch            implementation select
--                              0 - area optimized
--                              1 - speed optimized
--                              2 - uses 2007.12 sub-components (default)
--
--              Input ports     Size & Description
--              ===========     ==================
--              a               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Input
--
--              Output ports    Size & Description
--              ===========     ==================
--              z               (sig_width + exp_width + 1) bits
--                              Floating-point Number that represents exp(a)
--              status          byte
--                              Status information about FP operation
--
-- MODIFIED:
--          August 2008 - AFT - included new parameter (arch) and fixed other
--              issues related to accuracy.
--          June 2015 - AFT - added more bits to the vectors used to compute
--              the result's exponent value
--          07/2015 - AFT - Star 9000927859
--              To match the functionality of simulation and synthesis model
--              it was necessary to re-write this model and avoid using
--              floating-point operations. This model was based on the model
--              created for DW_fp_exp2. The difference is the input scaling
--              needed for the exp() function.
--          11/2015 - AFT - Star 9000972181
--              Increased the size of the internal constant log2(e) to handle
--              the situation when sig_width+exp_width+1 > 62. This is the case
--              for double-precision FP.
--          07/2017 - AFT - Regression error fix - LHS didn't match RHS in 
--              equation at line 274. Reported in Star 9001204304
--
---------------------------------------------------------------------------------

library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_misc.all;
use DWARE.DW_Foundation_comp_arith.all;
use DWARE.DWpackages.all;

architecture sim of DW_fp_exp is
	
-- pragma translate_off

-- definitions used in the code

  signal OOOl1I0O, I0I11OOl : std_logic_vector ((exp_width + sig_width + 1)-1 downto 0);
  signal OOll0O1I, OlO0Ol01 : std_logic_vector (8    -1 downto 0);
  signal O0O00I11 : std_logic_vector (sig_width+(exp_width+1)+1 downto 0);
  signal l1111010 : std_logic_vector(sig_width+2 downto 0);
  signal II1O0IO0 : std_logic_vector (sig_width+2 downto 0);
  signal OOOII01O : signed (exp_width+sig_width downto 0);
  signal IlOOI10l : signed (exp_width+(bit_width(sig_width))+1 downto 0);
  signal O1O0OI10 : std_logic;
  signal O0100lO0, IO010101, l1lOO01I, IlO011I0 : std_logic;
  signal l00O111O : std_logic;
  constant O1lIlll1 : std_logic_vector (91 downto 0) := "10111000101010100011101100101001010111000001011111110000101110111011111010000111111111101101";
  signal I00OIIl1 : std_logic_vector (sig_width+(exp_width+1) downto 0);

-- pragma translate_on
begin
-- pragma translate_off
  
    
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
    
    if ( (sig_width < 2) OR (sig_width > 57) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter sig_width (legal range: 2 to 57)"
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

  I00OIIl1 <= O1lIlll1(O1lIlll1'left downto O1lIlll1'left-sig_width-(exp_width+1));

  Pre_process: process (a, I00OIIl1)
  variable lO10O10O : std_logic;
  variable I0IlI100 : unsigned (exp_width downto 0);
  variable O0Ol1OI1 : signed (exp_width+sig_width downto 0);
  variable lO0l10O1 : std_logic_vector (sig_width downto 0);
  variable I110O0OO : std_logic_vector (sig_width+(exp_width+1) downto 0);
  variable Ill01110 : std_logic_vector (2*(sig_width+(exp_width+1)+1)-1 downto 0);
  constant M_long_left : integer := Ill01110'left;
  variable lO1100I0 : std_logic_vector (sig_width-1 downto 0);
  variable OO11II01 : std_logic_vector (sig_width-1 downto 0);
  variable ll0OlO01 : unsigned (exp_width downto 0);
  variable Ol110110 : std_logic_vector ((exp_width + sig_width + 1)-1 downto 0);
  variable l11OOO0l: std_logic_vector (8    -1 downto 0);
  variable O1ll1001, Ol0O11I1, O1I110lO, O01lO1O1 : std_logic;
  variable OOO0IOOO : std_logic_vector((exp_width + sig_width + 1)-1 downto 0);
  variable I00l1lOl : std_logic_vector((exp_width + sig_width + 1)-1 downto 0);
  variable O00OIO10 : std_logic_vector((exp_width + sig_width + 1)-1 downto 0);
  variable OlO1OIO0 : std_logic_vector((exp_width + sig_width + 1)-1 downto 0);
  variable O010Il00 : std_logic_vector (sig_width+(exp_width+1)+1 downto 0);
  variable O011O1OO : std_logic_vector(exp_width-2 downto 0);  
  variable O111Ol10 : std_logic_vector(exp_width-1 downto 0);
  begin

  O111Ol10 := conv_std_logic_vector(((((2 ** (exp_width-1)) - 1) * 2) + 1), O111Ol10'length);
  OO11II01 := (others => '0');
  ll0OlO01 := (others => '0');
  O011O1OO := conv_std_logic_vector(((2 ** (exp_width-1)) - 1), exp_width-1);
  I0IlI100 := unsigned('0'& a(((exp_width + sig_width) - 1) downto sig_width));
  O0Ol1OI1 := conv_signed(I0IlI100,exp_width+sig_width+1);
  lO1100I0 := a((sig_width - 1) downto 0);
  O1ll1001 := '0';
  OOO0IOOO := '0' & O111Ol10 & OO11II01;
  if (ieee_compliance = 1) then
      OOO0IOOO(0) := '1';
  end if;
  I00l1lOl := '1' &  O111Ol10 & OO11II01;
  O00OIO10 := '0' &  O111Ol10 & OO11II01;
  OlO1OIO0 := '0' & '0' & O011O1OO & OO11II01;
    
  if (ieee_compliance = 1 and I0IlI100 = ll0OlO01) then
    if (lO1100I0 = OO11II01) then
        O1ll1001 := '1';
        Ol0O11I1 := '0';
      else
        O1ll1001 := '0';
        Ol0O11I1 := '1';
        O0Ol1OI1(0) := '1';
    end if;
    lO0l10O1 := '0' & lO1100I0;
  elsif (ieee_compliance = 0 and I0IlI100 = ll0OlO01) then
    lO0l10O1 := '0' & OO11II01;
    O1ll1001 := '1';
    Ol0O11I1 := '0';
  else
    lO0l10O1 := '1' & lO1100I0;
    O1ll1001 := '0';
    Ol0O11I1 := '0';
  end if;
    
  if ((I0IlI100(exp_width-1 downto 0) = ((((2 ** (exp_width-1)) - 1) * 2) + 1)) and
       ((ieee_compliance = 0) or (lO1100I0 = OO11II01))) then
        O1I110lO := '1';
      else
        O1I110lO := '0';
  end if;

  if ((I0IlI100(exp_width-1 downto 0) = ((((2 ** (exp_width-1)) - 1) * 2) + 1)) and
       (ieee_compliance = 1) and (lO1100I0 /= OO11II01)) then
        O01lO1O1 := '1';
      else
        O01lO1O1 := '0';
  end if;

  lO10O10O := a((exp_width + sig_width));
    
  l11OOO0l := (others => '0');
  Ol110110 := (others => '0');
  O010Il00 := (others => '1');
  I110O0OO := (others => '0');
  Ill01110 := (others => '0');
    
  if (O01lO1O1 = '1') then
    Ol110110 := OOO0IOOO;
    l11OOO0l(2) := '1';

  elsif ((O1I110lO = '1') and (lO10O10O = '0')) then  
    Ol110110 := O00OIO10;
    l11OOO0l(1) := '1';

  elsif ((O1I110lO = '1') and (lO10O10O = '1')) then  
    Ol110110 := (others => '0');
    l11OOO0l(0) := '1';

  elsif (O1ll1001 = '1') then    
    Ol110110 := OlO1OIO0;

  else
    I110O0OO := (lO0l10O1 & conv_std_logic_vector(0,(exp_width+1)));
    Ill01110 := I110O0OO * I00OIIl1;
    O010Il00 := Ill01110(M_long_left downto sig_width+(exp_width+1));
    Ol110110 := (others => '0');
  end if;

  OOOl1I0O <= Ol110110;
  OOll0O1I <= l11OOO0l;
  O0O00I11 <= O010Il00;
  OOOII01O <= O0Ol1OI1 - conv_signed(unsigned(O011O1OO),exp_width+sig_width+1);
  O1O0OI10 <= lO10O10O;
  O0100lO0 <= O1ll1001;
  IO010101 <= Ol0O11I1;
  l1lOO01I <= O1I110lO;
  IlO011I0 <= O01lO1O1;
  end process Pre_process;
---------------------------------------------------------------

  Main_process: process (O0O00I11,OOOII01O,O1O0OI10,O0100lO0,l1lOO01I,IlO011I0)
  variable O1O0O000 : signed (exp_width+sig_width downto 0);
  variable OOlOl01O : std_logic_vector(sig_width+(exp_width+1)+exp_width+(bit_width(sig_width)) downto 0);
  variable I01I101l : signed(exp_width+(bit_width(sig_width)) downto 0);
  variable O0110O11 : std_logic_vector(sig_width+2 downto 0);
  variable I01O001O : std_logic;
  variable lIIOIOOl : std_logic_vector(exp_width+(bit_width(sig_width))-2 downto 0);
  variable Ol0O0lI0 : std_logic_vector(sig_width+2 downto 0);
  variable O11ll1I0 : integer;
  variable O00I11Ol : std_logic;
  begin
    O1O0O000 := OOOII01O;
    lIIOIOOl := (others => '0');
    OOlOl01O := lIIOIOOl & O0O00I11;
    O00I11Ol := not(O0100lO0 or l1lOO01I or IlO011I0);
    if (conv_integer(O1O0O000) < 0) then
      while (conv_integer(O1O0O000) < 0) loop
        O00I11Ol := O00I11Ol or OOlOl01O(0);
        OOlOl01O := '0' & OOlOl01O(OOlOl01O'left downto 1);
        O1O0O000 := O1O0O000 + 1;
      end loop;
    else
      if (conv_integer(O1O0O000) > 0 and OOlOl01O(OOlOl01O'left) = '0') then
        O11ll1I0 := 0;
        while (conv_integer(O1O0O000) > 0 and O11ll1I0 < (O1O0O000'length+1) and
               OOlOl01O(OOlOl01O'left) = '0') loop
          OOlOl01O := OOlOl01O(OOlOl01O'left-1 downto 0) & '0';
          O1O0O000 := O1O0O000 - 1;
          O11ll1I0 := O11ll1I0 + 1;
        end loop;
      end if;
    end if;
    l00O111O <= O00I11Ol;
                    
      I01I101l := signed(OOlOl01O(OOlOl01O'left downto sig_width+(exp_width+1)));
      O0110O11 := OOlOl01O(sig_width+(exp_width+1)-1 downto (exp_width+1)-3);
      if (conv_integer(O0110O11) = 0) then
        I01O001O := '1';
      else
        I01O001O := '0';
      end if;
                    
      if (O1O0OI10 = '1') then
        if (I01O001O = '1') then
          IlOOI10l <= conv_signed(-(I01I101l),IlOOI10l'length);
        else
          IlOOI10l <= conv_signed(-(I01I101l+1),IlOOI10l'length);
        end if;
      else
        IlOOI10l <= conv_signed(I01I101l,IlOOI10l'length);
      end if;

    if (O1O0OI10 = '1' and I01O001O = '0') then
      if (O00I11Ol = '0') then
        Ol0O0lI0 := unsigned(not O0110O11) + 1;
      else
        Ol0O0lI0 := unsigned(not O0110O11) + 0;
      end if;
    else
      Ol0O0lI0 := O0110O11;
    end if;
    l1111010 <= Ol0O0lI0;
  end process Main_process;

--------------------------------------------------------------
    
  U1 : DW_exp2 generic map (op_width => sig_width+3,
                            arch => arch,
                            err_range => 1)
       port map (a => l1111010,
                 z => II1O0IO0);

--------------------------------------------------------------

  Post_process: process (l1111010, II1O0IO0, OOOII01O, IlOOI10l, O1O0OI10, l00O111O)
    variable O00l1OO1 : std_logic_vector (sig_width+3 downto 0);
    variable OO1OOl0O : signed (exp_width+(bit_width(sig_width))+1 downto 0);
    variable IllO0llO: std_logic_vector(sig_width+1 downto 0);
    variable ll0OlO01 : std_logic_vector (exp_width-1 downto 0);
    variable OIIl10l1 : std_logic_vector (8    -1 downto 0);
    variable lIOO11O1 : std_logic_vector ((exp_width + sig_width + 1)-1 downto 0);
    variable O0I10OI0 : boolean;
    variable O0010II1 : boolean;
    variable OO010OlI : signed (exp_width+(bit_width(sig_width))+1 downto 0);
    variable O1I0OI00 : signed (exp_width+sig_width downto 0);
    variable O00OIO10 : std_logic_vector((exp_width + sig_width + 1)-1 downto 0);
    variable O111Ol10 : std_logic_vector(exp_width-1 downto 0);
    variable OO11II01 : std_logic_vector (sig_width-1 downto 0);
    variable l1IlO1O0 : signed (exp_width downto 0);
    variable OIO10OO0 : std_logic;
  begin
    O111Ol10 := conv_std_logic_vector(((((2 ** (exp_width-1)) - 1) * 2) + 1), O111Ol10'length);
    ll0OlO01 := (others => '0');
    OO11II01 := (others => '0');
    O00OIO10 := '0' &  O111Ol10 & OO11II01;
    lIOO11O1 := (others => '0');
    OIIl10l1 := (others => '0');
    OIIl10l1(5) := or_reduce(l1111010) or l00O111O;
    OO1OOl0O := IlOOI10l;
    O00l1OO1 := ('0' & II1O0IO0) + II1O0IO0(0);
                    
    if (and_reduce(II1O0IO0) = '1') then
      OO1OOl0O := OO1OOl0O + 1;
      IllO0llO := (others => '0');
      IllO0llO(IllO0llO'left-1) := '1';
    end if;
    
      l1IlO1O0 := conv_signed(((2 ** (exp_width-1)) - 1), l1IlO1O0'length);
      OO010OlI := conv_signed(OO1OOl0O,OO010OlI'length) +
                         conv_signed(l1IlO1O0,OO010OlI'length);

    O0I10OI0 := false;
    O0010II1 := false;
      O1I0OI00 := OOOII01O - conv_signed(exp_width,OOOII01O'length) + 1;
      if (conv_integer(O1I0OI00) > 0 and conv_integer(OOOII01O) > 0 and
          O1O0OI10 = '0') then
        O0I10OI0 := true;
      else
          if ((OO010OlI >= ((((2 ** (exp_width-1)) - 1) * 2) + 1)) and
              (O1O0OI10 = '0')) then
            O0I10OI0 := true;
       end if;
      end if;
                                                     
      if (conv_integer(O1I0OI00) > 0 and conv_integer(OOOII01O) > 0 and
          O1O0OI10 = '1') then
          O0010II1 := true;
      end if;
      if (OO010OlI <= 0) then
        if (ieee_compliance = 1) then
            O0010II1 := false;
            while (OO010OlI <= 0) loop
              OO010OlI := OO010OlI + 1;
              O00l1OO1 := '0' & O00l1OO1(O00l1OO1'left downto 1);
            end loop;
        else
          O0010II1 := true;
        end if;
      end if;
    OIO10OO0 := O00l1OO1(1);
    IllO0llO := O00l1OO1(O00l1OO1'left downto 2) + OIO10OO0;
    if (and_reduce(O00l1OO1(sig_width+2 downto 2)) = '1' and OIO10OO0 = '1') then
      OO010OlI := OO010OlI + 1;
      if ((OO010OlI >= ((((2 ** (exp_width-1)) - 1) * 2) + 1)) and (O1O0OI10 = '0')) then
          O0I10OI0 := true;
      end if;
      IllO0llO := (others => '0');
      IllO0llO(IllO0llO'left) := '1';
    end if;
          
    if (O0I10OI0) then
      lIOO11O1 := O00OIO10;
      OIIl10l1(1) := '1';
      OIIl10l1(4) := '1';
      OIIl10l1(5) := '1';
    elsif (O0010II1) then
      lIOO11O1 := (others => '0');
      OIIl10l1(0) := '1';
      if (ieee_compliance = 0) then
        OIIl10l1(3) := '1';
      else
        OIIl10l1(3) := '0';
      end if;
      OIIl10l1(5) := '1';
    else
        if (IllO0llO(IllO0llO'left downto IllO0llO'left-1) = "00") then
            lIOO11O1 := '0' & conv_std_logic_vector(0,exp_width) &
                           IllO0llO(sig_width-1 downto 0);
            if (conv_integer(IllO0llO(sig_width-1 downto 0)) = 0) then
              OIIl10l1(0) := '1';
              OIIl10l1(5) := '1';
            else
              OIIl10l1(3) := '1';
            end if;
        else
            lIOO11O1 := '0' & conv_std_logic_vector(OO010OlI(exp_width-1 downto 0),exp_width) &
                           IllO0llO(sig_width-1 downto 0);
        end if;
    end if;
                    
    I0I11OOl <= lIOO11O1;
    OlO0Ol01 <= OIIl10l1;
  end process Post_process;

  z <= (others => 'X') when Is_X(a) else
       OOOl1I0O when (conv_integer(OOll0O1I) /= 0 or conv_integer(OOOl1I0O) /= 0) else I0I11OOl;
  status <= (others => 'X') when Is_X(a) else
            OOll0O1I when (conv_integer(OOll0O1I) /= 0 or conv_integer(OOOl1I0O) /= 0) else OlO0Ol01;
    
-- pragma translate_on  
end sim ;

--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

library dw02;

configuration DW_fp_exp_cfg_sim of DW_fp_exp is
 for sim
  for U1 : DW_exp2 use configuration dw02.DW_exp2_cfg_sim; end for;
 end for; -- sim
end DW_fp_exp_cfg_sim;
-- pragma translate_on

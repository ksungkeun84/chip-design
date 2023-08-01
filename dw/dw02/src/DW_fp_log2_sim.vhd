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
-- AUTHOR:    Alexandre F. Tenca - August 2007
--
-- VERSION:   VHDL Simulation Model - FP Base-2 Logarithm
--
-- DesignWare_version: a6995016
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--
-- ABSTRACT: Floating-point Base-2 Logarithm
--           Computes the base-2 logarithm of a FP number
--
--              parameters      valid values (defined in the DW manual)
--              ==========      ============
--              sig_width       significand size,  2 to 60 bits
--              exp_width       exponent size,     3 to 31 bits
--              ieee_compliance 0 or 1
--              extra_prec      0 to 60-sig_width (default 0)
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
--                              Floating-point Number that represents log2(a)
--              status          byte
--                              Status information about FP operation
--
-- MODIFIED:
--            10/10/2007 - AFT 
--               Included a new parameter to increase the internal precision.
--            09/2008 - AFT - included another parameter (arch) 
--            08/12/2010 - Alex Tenca, Kyung-Nam Han (STAR 9000409445)
--               Fixed bugs with sig_width=23 and exp_width=4
--            07/07/2015 - AFT - Star 9000926897
--               Fixed errors when parameter set is one with
--               extreme values, such as (59,3,0,0,0). Some of the conv_integer
--               function calls had their argument out of range.
--            12/2015 - AFT - Star 9000984209
--               fixed case when input is -0 to be log2(-0)=-inf 
--            10/03/2015 - STAR 9001082385
--               status[7] = 1 when log(+0) and log(-0)
--
---------------------------------------------------------------------------------

library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_misc.all;
use DWARE.DW_Foundation_arith.all;
use DWARE.DW_Foundation_comp_arith.all;

architecture sim of DW_fp_log2 is
	
-- pragma translate_off

-- definitions used in the code

-- signals
  signal l0I1l1I0, l11OOl11 : std_logic_vector ((exp_width + sig_width + 1)-1 downto 0);
  signal OOlIIl1O, I1lO1I0O : std_logic_vector (8    -1 downto 0);
  constant DW_lO11100O : integer := sig_width+extra_prec+1;
  constant DW_lI1lIOOO : integer := DW_lO11100O+exp_width+5;
  signal ll0OIO0O : std_logic_vector (DW_lO11100O-1 downto 0);
  signal lIIOl00O : std_logic_vector (DW_lO11100O-1 downto 0);
  signal I1I1O1O1 : signed (DW_lI1lIOOO - 1 downto 0);
  signal O01OI110 : std_logic_vector(8    -1 downto 0) := (others => '0');
  signal O1lI1O00, OlOOOO0O, OO1lOl00, OO1l1OO0 : std_logic;
-- pragma translate_on
begin
-- pragma translate_off
  
    
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
    
    if ( (sig_width < 2) OR (sig_width > 59) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter sig_width (legal range: 2 to 59)"
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
    
    if ( (extra_prec < 0) OR (extra_prec > 59-sig_width) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter extra_prec (legal range: 0 to 59-sig_width)"
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
  variable O1O00011 : std_logic;
  variable OO1OI100 : unsigned (DW_lI1lIOOO - 1 downto 0);
  variable O1OI1I0I : signed (DW_lI1lIOOO - 1 downto 0);
  variable lIIOO1O0 : std_logic_vector (sig_width downto 0);
  variable O1O0IO0I : std_logic_vector (sig_width-1 downto 0);
  variable Ol11Il00 : std_logic_vector (sig_width-1 downto 0);
  variable OlO01101 : unsigned (exp_width downto 0);
  variable O0l00010 : std_logic_vector ((exp_width + sig_width + 1)-1 downto 0);
  variable OlO0O1OO: std_logic_vector (8    -1 downto 0);
  variable l010OO01, O1101lll, II0l1011, IOOII00I : std_logic;
  variable Ol0I1l00 : std_logic_vector(exp_width-1 downto 0);
  variable l0O111Ol : std_logic_vector((exp_width + sig_width + 1)-1 downto 0);  -- Not-a-number
  variable O1101l11 : std_logic_vector((exp_width + sig_width + 1)-1 downto 0);  -- minus infinity
  variable OOl0l110 : std_logic_vector((exp_width + sig_width + 1)-1 downto 0);  -- plus infinity
  variable IO01l1lO : std_logic_vector (sig_width downto 0);
  variable O100110O : unsigned (DW_lO11100O-1 downto 0);
  
  begin                                 -- process MAIN

  Ol0I1l00 := conv_std_logic_vector(((((2 ** (exp_width-1)) - 1) * 2) + 1), Ol0I1l00'length);
  Ol11Il00 := (others => '0');
  OlO01101 := (others => '0');
  OO1OI100 := conv_unsigned(unsigned(B"00" & a(((exp_width + sig_width) - 1) downto sig_width)),OO1OI100'length);
  O1OI1I0I := conv_signed(OO1OI100,O1OI1I0I'length);
  O1O0IO0I := a((sig_width - 1) downto 0);
  l010OO01 := '0';
  l0O111Ol := '0' & Ol0I1l00 & Ol11Il00;
  if (ieee_compliance = 1) then
      l0O111Ol(0) := '1';  -- mantissa is 1 when number is NAN and not MC code
  end if;
  O1101l11 := '1' &  Ol0I1l00 & Ol11Il00;
  OOl0l110 := '0' &  Ol0I1l00 & Ol11Il00;
  
  if (ieee_compliance = 1 and OO1OI100 = OlO01101) then
    if (O1O0IO0I = Ol11Il00) then
        l010OO01 := '1';
        O1101lll := '0';
      else
        l010OO01 := '0';
        O1101lll := '1';
        O1OI1I0I(0) := '1';                  -- make the value the minimum Ol0lOO0l
    end if;
    lIIOO1O0 := '0' & a((sig_width - 1) downto 0);
  elsif (ieee_compliance = 0 and OO1OI100 = OlO01101) then
    lIIOO1O0 := '0' & Ol11Il00;
    l010OO01 := '1';
    O1101lll := '0';
  else
    lIIOO1O0 := '1' & a((sig_width - 1) downto 0);
    l010OO01 := '0';
    O1101lll := '0';
  end if;
    
  if ((OO1OI100(exp_width-1 downto 0) = ((((2 ** (exp_width-1)) - 1) * 2) + 1)) and
       ((ieee_compliance = 0) or (O1O0IO0I = Ol11Il00))) then
        II0l1011 := '1';
      else
        II0l1011 := '0';
  end if;

  if ((OO1OI100(exp_width-1 downto 0) = ((((2 ** (exp_width-1)) - 1) * 2) + 1)) and
       (ieee_compliance = 1) and (O1O0IO0I /= Ol11Il00)) then
        IOOII00I := '1';
      else
        IOOII00I := '0';
  end if;

  O1O00011 := a((exp_width + sig_width));                  -- minus zero is also
                                        -- considered negative
    
  OlO0O1OO := (others => '0');
  O0l00010 := (others => '0');
  IO01l1lO := (others => '1');
    
  --
  -- NaN or negative input
  --
  if ((IOOII00I = '1') or                        -- a is NaN or
      ((O1O00011 = '1') and (l010OO01 = '0'))) then  -- negative and non-zero
    -- output is NaN or infinity, depending on ieee_compliance
    -- but status bit is marked as invalid operation
    O0l00010 := l0O111Ol;
    OlO0O1OO(2) := '1';

  --
  -- Positive Infinity Input
  --
  elsif (II0l1011 = '1') then  
    O0l00010 := OOl0l110;
    OlO0O1OO(1) := '1';

  --
  -- Zero Input
  --
  elsif (l010OO01 = '1') then    
    O0l00010 := O1101l11;
    OlO0O1OO(1) := '1';
    OlO0O1OO(7) := '1';

  --
  -- Denormal Inputs
  --
  elsif (O1101lll = '1') then	
    IO01l1lO := lIIOO1O0;
    -- normalize it
    while IO01l1lO(IO01l1lO'left) = '0' loop
      IO01l1lO := IO01l1lO(IO01l1lO'length-2 downto 0) & '0';
      O1OI1I0I := O1OI1I0I - 1;
    end loop;
    O0l00010 := (others => '0');

  --
  -- +1 Input
  --
  elsif (O1OI1I0I = conv_signed(((2 ** (exp_width-1)) - 1),O1OI1I0I'length) and  O1O0IO0I = conv_std_logic_vector(0,O1O0IO0I'length)
         and O1O00011 = '0') then
    OlO0O1OO(0) := '1';
    O0l00010 := (others => '0');

  --
  -- Normal (normalized) input
  --
  else
     IO01l1lO := lIIOO1O0;
     O0l00010 := (others => '0');
  end if;

  l0I1l1I0 <= O0l00010;
  OOlIIl1O <= OlO0O1OO;
  O100110O := conv_unsigned(unsigned(IO01l1lO),DW_lO11100O);
  ll0OIO0O <= std_logic_vector(SHL(O100110O,conv_unsigned(DW_lO11100O-(sig_width+1),16)));
  I1I1O1O1 <= O1OI1I0I - ((2 ** (exp_width-1)) - 1);
  O1lI1O00 <= l010OO01;
  OlOOOO0O <= O1101lll;
  OO1lOl00 <= II0l1011;
  OO1l1OO0 <= IOOII00I;
  end process Pre_process;

  U1 : DW_log2 generic map (op_width => DW_lO11100O, arch => arch)
       port map (a => ll0OIO0O,
                 z => lIIOl00O);

  -- Once the fixed-point log2 is computed, normalize the output and
  -- adjust Ol0lOO0l.
  Post_process: process (lIIOl00O, I1I1O1O1)
    variable Ol0lOO0l : signed (DW_lI1lIOOO - 1 downto 0);
    variable O0OOl011 : std_logic_vector (DW_lO11100O-1 downto 0);
    variable Ol11Il00 : std_logic_vector (sig_width-1 downto 0);
    variable OlO01101 : std_logic_vector (exp_width-1 downto 0);
    variable OOO1lO0l, lOOOI1O0 : signed (DW_lI1lIOOO-1 downto 0);
    variable I0l0l101 : signed (DW_lI1lIOOO-1 downto 0);
    variable I1Ol0OlI : signed (DW_lI1lIOOO-1 downto 0);
    variable O0OlI011 : std_logic_vector (DW_lI1lIOOO-1 downto 0);
    variable Ol0001IO : std_logic_vector(DW_lI1lIOOO-1 downto 0);
    variable OIll0O01 : std_logic_vector(DW_lO11100O downto 0);
    variable lO0111Ol : std_logic_vector(sig_width+1 downto 0);
    variable O1011010 : unsigned (DW_lI1lIOOO-1 downto 0);
    variable l011IOI1 : signed (DW_lI1lIOOO-1 downto 0);
    variable l100OO01  : std_logic_vector (8    -1 downto 0);
    variable Ol1OI0O1 : std_logic;
    variable Ol0I1l00 : std_logic_vector(exp_width-1 downto 0);
    variable O1101l11 : std_logic_vector((exp_width + sig_width + 1)-1 downto 0);  -- minus infinity
   begin  -- process
    Ol0I1l00 := conv_std_logic_vector(((((2 ** (exp_width-1)) - 1) * 2) + 1), Ol0I1l00'length);
    Ol11Il00 := (others => '0');
    O1101l11 := '1' &  Ol0I1l00 & Ol11Il00;
    OlO01101 := (others => '0');
    Ol0lOO0l := conv_signed(((2 ** (exp_width-1)) - 1),Ol0lOO0l'length);
    l011IOI1 := conv_signed(I1I1O1O1,l011IOI1'length);
    OOO1lO0l := SHL(l011IOI1,conv_unsigned(DW_lO11100O,16));
    O1011010 := conv_unsigned(unsigned(lIIOl00O),O1011010'length);
    lOOOI1O0 := conv_signed(O1011010,lOOOI1O0'length);
    I0l0l101 := OOO1lO0l + lOOOI1O0;
    if (I1I1O1O1(I1I1O1O1'left) = '1') then
        Ol1OI0O1 := '1';
        I1Ol0OlI := -I0l0l101;
      else
        Ol1OI0O1 := '0';
        I1Ol0OlI := I0l0l101;
    end if;
    O0OlI011 := std_logic_vector(I1Ol0OlI);
    -- normalize/denormalize the output
    Ol0001IO := O0OlI011;
    -- shift right when the number is too large
    while ((or_reduce(Ol0001IO(Ol0001IO'left downto DW_lO11100O+1))='1') and (or_reduce(Ol0001IO) = '1')) loop
      Ol0001IO := '0' & Ol0001IO(Ol0001IO'length-1 downto 1);
      Ol0lOO0l := Ol0lOO0l + 1;
    end loop;
    OIll0O01 := Ol0001IO(DW_lO11100O downto 0);
    -- shift to the left if the value is too small
    while (OIll0O01(DW_lO11100O)='0' and (or_reduce(OIll0O01) = '1') and
           conv_integer(Ol0lOO0l) > 1) loop
      OIll0O01 := OIll0O01(OIll0O01'length-2 downto 0) & '0';
      Ol0lOO0l := Ol0lOO0l - 1; 
    end loop;
   
     -- perform rounding
    lO0111Ol := unsigned('0'&OIll0O01(DW_lO11100O downto extra_prec+1))+OIll0O01(extra_prec);
    if (lO0111Ol(lO0111Ol'left)='1') then
      -- post-rounding normalization
      lO0111Ol := '0' & lO0111Ol(lO0111Ol'length-1 downto 1);
      Ol0lOO0l := Ol0lOO0l + 1;
    end if;
    -- decide on the output value
    if (lO0111Ol(sig_width) = '0') then
      -- it is a denormalized output
      if (ieee_compliance = 1) then
        l11OOl11 <= Ol1OI0O1 &   OlO01101 & lO0111Ol(sig_width-1 downto 0);
        l100OO01(3) := '1';
      else
        l11OOl11 <= (others => '0');
        l100OO01(3) := '1';
        l100OO01(0) := '1';
      end if;
    else
      -- it is a normalized number
      -- check for underflow condition
      if (or_reduce(conv_std_logic_vector(Ol0lOO0l(exp_width+5 downto exp_width),6)) = '1') then
        l100OO01(4) := '1';
        l100OO01(5) := '1';
        l100OO01(1) := '1';
        l11OOl11 <= O1101l11;
      else
        l100OO01 := (others => '0');
        l11OOl11 <= Ol1OI0O1 & conv_std_logic_vector(Ol0lOO0l(exp_width-1 downto 0),exp_width) &
                   lO0111Ol(sig_width-1 downto 0);
      end if;
    end if;
    I1lO1I0O <= l100OO01;
  end process Post_process;

  z <= (others => 'X') when Is_X(a) else
       l0I1l1I0 when (OOlIIl1O /= O01OI110) else l11OOl11;
  status <= (others => 'X') when Is_X(a) else
            OOlIIl1O when (OOlIIl1O /= O01OI110) else I1lO1I0O;
    
-- pragma translate_on  
end sim ;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

library dw02;

configuration DW_fp_log2_cfg_sim of DW_fp_log2 is
 for sim
  for U1 : DW_log2 use configuration dw02.DW_log2_cfg_sim; end for;
 end for; -- sim
end DW_fp_log2_cfg_sim;
-- pragma translate_on

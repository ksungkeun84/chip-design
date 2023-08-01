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
-- AUTHOR:    Alexandre F. Tenca - June 2008
--
-- VERSION:   VHDL Simulation Model - FP Natural Logarithm
--
-- DesignWare_version: 37f0237f
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--
-- ABSTRACT: Floating-point Natural Logarithm
--           Computes the natural logarithm of a FP number
--
--              parameters      valid values (defined in the DW manual)
--              ==========      ============
--              sig_width       significand size,  2 to 60 bits
--              exp_width       exponent size,     3 to 31 bits
--              ieee_compliance 0 or 1
--              extra_prec      0 to 60-sig_width bits
--              arch            implementation select
--                              0 - area optimized
--                              1 - speed optimized
--
--              Input ports     Size & Description
--              ===========     ==================
--              a               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Input
--
--              Output ports    Size & Description
--              ===========     ==================
--              z               (sig_width + exp_width + 1) bits
--                              Floating-point Number that represents ln(a)
--              status          byte
--                              Status information about FP operation
--
-- MODIFIED:
--           07/2015 - AFT - Star 9000927308
--                Fixed boundary errors when: (1) the exponent
--                is too small, and when the significand size if too large and
--                (2) The parameter set (59,3,0,0,0) causes the DW_ln to be
--                instanted with parameter values out of range. 
--
--           11/2015 - AFT - Star 9000854445
--                the ln(-0) should be the same as ln(+0)=-inf
--
--           11/2016 - Star 9001116007
--                Fixed the status[7] flag for ln(+0) and ln(-0)
--
--           4/10/2018 - RJK -  STAR 9001308455
--                 Updated upper bounds check on the extra_prec parameter
--
---------------------------------------------------------------------------------
library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_misc.all;
use DWARE.DW_Foundation_arith.all;
use DWARE.DW_Foundation_comp_arith.all;

architecture sim of DW_fp_ln is
	
-- pragma translate_off

-- definitions used in the code

-- signals
  signal OOO10100, IO10000O : std_logic_vector ((exp_width + sig_width + 1)-1 downto 0);
  signal lOO0O0l0, OOO11lOO : std_logic_vector (8    -1 downto 0);
  constant DW_l1111OlI : integer := sig_width+extra_prec+1;
  constant DW_O1I0O100 : integer := DW_l1111OlI+exp_width+5;
  signal O1IOl1I1 : std_logic_vector (DW_l1111OlI-1 downto 0);
  signal OI0O0lO0 : std_logic_vector (DW_l1111OlI-1 downto 0);
  signal O0O01lI1 : signed (DW_O1I0O100-1 downto 0);
  signal O101l000 : std_logic_vector(8    -1 downto 0) := (others => '0');
  constant l1000Il0 : std_logic_vector (92 downto 0) := "010110001011100100001011111110111110100011100111101111001101010111100100111100011101100111001";
  signal O10O001O : std_logic_vector (DW_l1111OlI-1 downto 0);
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
    
    if ( (arch < 0) OR (arch > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter arch (legal range: 0 to 1)"
        severity warning;
    end if;
    
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;  

  O10O001O <= l1000Il0(l1000Il0'left-1 downto l1000Il0'left-O10O001O'length) + l1000Il0(l1000Il0'left-O10O001O'length-1);

  Pre_process: process (a)
  variable lOI10I11 : std_logic;
  variable lIO1IOO1 : unsigned (DW_O1I0O100-1 downto 0);
  variable OIO0I1Ol : signed (DW_O1I0O100-1 downto 0);
  variable OO10lI1l : std_logic_vector (sig_width downto 0);
  variable l1I111Il : std_logic_vector (sig_width-1 downto 0);
  variable OIlOllO0 : std_logic_vector (sig_width-1 downto 0);
  variable lO0lI00I : unsigned (exp_width downto 0);
  variable lI00O010 : std_logic_vector ((exp_width + sig_width + 1)-1 downto 0);
  variable O010OO00: std_logic_vector (8    -1 downto 0);
  variable II1l110I, lOO00I0l, I100llOO, I010Il1O : std_logic;
  variable l01O1OIO : std_logic_vector(exp_width-1 downto 0);
  variable O1001111 : std_logic_vector((exp_width + sig_width + 1)-1 downto 0);
  variable OI11lI10 : std_logic_vector((exp_width + sig_width + 1)-1 downto 0);
  variable l100101I : std_logic_vector((exp_width + sig_width + 1)-1 downto 0);
  variable O101OI0O : std_logic_vector (sig_width downto 0);
  variable lOO10O10 : unsigned (DW_l1111OlI-1 downto 0);
  
  begin

    l01O1OIO := conv_std_logic_vector(((((2 ** (exp_width-1)) - 1) * 2) + 1), l01O1OIO'length);
    OIlOllO0 := (others => '0');
    lO0lI00I := (others => '0');
    lIO1IOO1 := conv_unsigned(unsigned('0'& a(((exp_width + sig_width) - 1) downto sig_width)),lIO1IOO1'length);
    OIO0I1Ol := conv_signed(lIO1IOO1,OIO0I1Ol'length);
    l1I111Il := a((sig_width - 1) downto 0);
    II1l110I := '0';
    O1001111 := '0' & l01O1OIO & OIlOllO0;
    if (ieee_compliance = 1) then
      O1001111(0) := '1'; 

    end if;
    OI11lI10 := '1' &  l01O1OIO & OIlOllO0;
    l100101I := '0' &  l01O1OIO & OIlOllO0;
    
    if (ieee_compliance = 1 and lIO1IOO1 = lO0lI00I) then
      if (l1I111Il = OIlOllO0) then
          II1l110I := '1';
          lOO00I0l := '0';
      else
          II1l110I := '0';
          lOO00I0l := '1';
          OIO0I1Ol(0) := '1';
      end if;
      OO10lI1l := '0' & a((sig_width - 1) downto 0);
    elsif (ieee_compliance = 0 and lIO1IOO1 = lO0lI00I) then
      OO10lI1l := '0' & OIlOllO0;
      II1l110I := '1';
      lOO00I0l := '0';
    else
      OO10lI1l := '1' & a((sig_width - 1) downto 0);
      II1l110I := '0';
      lOO00I0l := '0';
    end if;
      
    if ((lIO1IOO1(exp_width-1 downto 0) = ((((2 ** (exp_width-1)) - 1) * 2) + 1)) and
        ((ieee_compliance = 0) or (l1I111Il = OIlOllO0))) then
      I100llOO := '1';
    else
      I100llOO := '0';
    end if;
    
    if ((lIO1IOO1(exp_width-1 downto 0) = ((((2 ** (exp_width-1)) - 1) * 2) + 1)) and
        (ieee_compliance = 1) and (l1I111Il /= OIlOllO0)) then
      I010Il1O := '1';
    else
      I010Il1O := '0';
    end if;
  
    lOI10I11 := a((exp_width + sig_width));
      
    O010OO00 := (others => '0');
    lI00O010 := (others => '0');
    O101OI0O := (others => '1');
      
    if ((I010Il1O = '1') or  ((lOI10I11 = '1') and (II1l110I = '0'))) then  
      lI00O010 := O1001111;
      O010OO00(2) := '1';
    
    elsif (I100llOO = '1') then  
      lI00O010 := l100101I;
      O010OO00(1) := '1';
  
    elsif (II1l110I = '1') then    
      lI00O010 := OI11lI10;
      O010OO00(1) := '1';
      O010OO00(7) := '1';
  
    elsif (lOO00I0l = '1') then	
      O101OI0O := OO10lI1l;
      while O101OI0O(O101OI0O'left) = '0' loop
        O101OI0O := O101OI0O(O101OI0O'length-2 downto 0) & '0';
        OIO0I1Ol := OIO0I1Ol - 1;
      end loop;
      lI00O010 := (others => '0');
  
    elsif (OIO0I1Ol = conv_signed(((2 ** (exp_width-1)) - 1),OIO0I1Ol'length) and
           l1I111Il = conv_std_logic_vector(0,l1I111Il'length) and
           lOI10I11 = '0') then
      O010OO00(0) := '1';
      lI00O010 := (others => '0');
  
    else
       O101OI0O := OO10lI1l;
       lI00O010 := (others => '0');
    end if;
    
    OOO10100 <= lI00O010;
    lOO0O0l0 <= O010OO00;
    lOO10O10 := conv_unsigned(unsigned(O101OI0O),DW_l1111OlI);
    O1IOl1I1 <= std_logic_vector(SHL(lOO10O10,conv_unsigned(DW_l1111OlI-(sig_width+1),8)));
    O0O01lI1 <= OIO0I1Ol - ((2 ** (exp_width-1)) - 1);
  end process Pre_process;

  U1 : DW_ln generic map (op_width => DW_l1111OlI, arch => arch)
       port map (a => O1IOl1I1,
                 z => OI0O0lO0);

  Post_process: process (OI0O0lO0, O0O01lI1, O10O001O)
  variable O1OO1OO1 : signed (DW_O1I0O100 - 1 downto 0);
  variable OIlOllO0 : std_logic_vector (sig_width-1 downto 0);
  variable lO0lI00I : std_logic_vector (exp_width-1 downto 0);
  variable lI01I1ll, OOI111O0 : signed (DW_O1I0O100-1 downto 0);
  variable Ol0Il1O0 : signed (DW_O1I0O100-1 downto 0);
  variable OOIOOlO1 : signed (DW_O1I0O100-1 downto 0);
  variable OOO0O1O1 : std_logic_vector (DW_O1I0O100-1 downto 0);
  variable O101OI0I : std_logic_vector(DW_O1I0O100-1 downto 0);
  variable Il1O0IOO : std_logic_vector(DW_l1111OlI downto 0);
  variable O10IO0I0 : std_logic_vector(sig_width+1 downto 0);
  variable l010Ol0I : unsigned (DW_O1I0O100-1 downto 0);
  variable I10IO001 : signed (O0O01lI1'length+O10O001O'length downto 0);
  variable OI1l00OO : signed (DW_O1I0O100-1 downto 0);
  variable OO1O1OO0  : std_logic_vector (8    -1 downto 0);
  variable lO1O00Ol : std_logic;
  variable l01O1OIO : std_logic_vector(exp_width-1 downto 0);
  variable OI11lI10 : std_logic_vector((exp_width + sig_width + 1)-1 downto 0);
  begin
    OIlOllO0 := (others => '0');
    lO0lI00I := (others => '0');
    l01O1OIO := conv_std_logic_vector(((((2 ** (exp_width-1)) - 1) * 2) + 1), l01O1OIO'length);
    OI11lI10 := '1' &  l01O1OIO & OIlOllO0;
    O1OO1OO1 := conv_signed(((2 ** (exp_width-1)) - 1),O1OO1OO1'length);
    I10IO001 := O0O01lI1 * unsigned(O10O001O);
    OI1l00OO := I10IO001(OI1l00OO'left downto 0);
    lI01I1ll := OI1l00OO;
    l010Ol0I := conv_unsigned(unsigned(OI0O0lO0),l010Ol0I'length);
    OOI111O0 := conv_signed(l010Ol0I,OOI111O0'length);
    Ol0Il1O0 := lI01I1ll + OOI111O0;
    if (Ol0Il1O0(Ol0Il1O0'left) = '1') then
      OOIOOlO1 := -Ol0Il1O0;
      lO1O00Ol := '1';
    else
      lO1O00Ol := '0';
      OOIOOlO1 := Ol0Il1O0;
    end if;
    OOO0O1O1 := std_logic_vector(OOIOOlO1);
    O101OI0I := OOO0O1O1;
    while ((or_reduce(O101OI0I(O101OI0I'left downto DW_l1111OlI+1))='1') and (or_reduce(O101OI0I) = '1')) loop
      O101OI0I := '0' & O101OI0I(O101OI0I'length-1 downto 1);
      O1OO1OO1 := O1OO1OO1 + 1;
    end loop;
    Il1O0IOO := O101OI0I(DW_l1111OlI downto 0);
    while (Il1O0IOO(DW_l1111OlI)='0' and or_reduce(Il1O0IOO) = '1' and
           conv_integer(O1OO1OO1) > 1) loop
      Il1O0IOO := Il1O0IOO(Il1O0IOO'length-2 downto 0) & '0';
      O1OO1OO1 := O1OO1OO1 - 1; 
    end loop;
   
    O10IO0I0 := unsigned('0'&Il1O0IOO(DW_l1111OlI downto extra_prec+1))+Il1O0IOO(extra_prec);
    if (O10IO0I0(O10IO0I0'left)='1') then
      O10IO0I0 := '0' & O10IO0I0(O10IO0I0'length-1 downto 1);
      O1OO1OO1 := O1OO1OO1 + 1;
    end if;
    if (O10IO0I0(sig_width) = '0') then
      if (ieee_compliance = 1) then
        IO10000O <= lO1O00Ol &   lO0lI00I & O10IO0I0(sig_width-1 downto 0);
        OO1O1OO0(3) := '1';
      else
        IO10000O <= (others => '0');
        OO1O1OO0(3) := '1';
        OO1O1OO0(0) := '1';
      end if;
    else
      if (or_reduce(conv_std_logic_vector(O1OO1OO1(exp_width+5 downto exp_width),6)) = '1') then
        OO1O1OO0(4) := '1';
        OO1O1OO0(5) := '1';
        OO1O1OO0(1) := '1';
        IO10000O <= OI11lI10;
      else
        OO1O1OO0 := (others => '0');
        IO10000O <= lO1O00Ol & conv_std_logic_vector(O1OO1OO1,exp_width) &
                   O10IO0I0(sig_width-1 downto 0);
      end if;
    end if;
    OO1O1OO0(5) := not OO1O1OO0(1) and
                                    not OO1O1OO0(2) and
                                    not (OO1O1OO0(0) and
                                         not OO1O1OO0(3));
    OOO11lOO <= OO1O1OO0;
  end process Post_process;

  z <= (others => 'X') when Is_X(a) else
       OOO10100 when (lOO0O0l0 /= O101l000) else IO10000O;
  status <= (others => 'X') when Is_X(a) else
            lOO0O0l0 when (lOO0O0l0 /= O101l000) else OOO11lOO;
    
-- pragma translate_on  
end sim ;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

library dw02;

configuration DW_fp_ln_cfg_sim of DW_fp_ln is
 for sim
  for U1 : DW_ln use configuration dw02.DW_ln_cfg_sim; end for;
 end for; -- sim
end DW_fp_ln_cfg_sim;
-- pragma translate_on

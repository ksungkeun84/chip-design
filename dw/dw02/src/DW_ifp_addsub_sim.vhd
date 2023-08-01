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
-- AUTHOR:    Alexandre F. Tenca (December 2007)
--
-- VERSION:   VHDL Simulation Model - FP Add/sub - internal format
--
-- DesignWare_version: 4af2d099
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--
-- ABSTRACT: Floating-point two-operand Adder/Subtractor in Internal FP format
--           Computes the addition/subtraction of two FP numbers in internal
--           (proprietary) FP format. 
--           The format of the FP numbers is defined by the number of bits 
--           in the significand (sig_width) and the number of bits in the 
--           exponent (exp_width). The internal format uses status (7 bits),
--           exponent, and significand fields. The significand is expressed 
--           in two's complement. 
--           The total number of bits in the FP number is sig_width+exp_width+7
--           The output follows the same format.
--           Subtraction is forced when op=1
--           Althought rounding is not done, the sign of zeros requires this
--           information.
--              parameters      valid values (defined in the DW manual)
--              ==========      ============
--              sig_widthi      significand size of the input,  2 to 253 bits
--              exp_widthi      exponent size of the input,     3 to 31 bits
--              sig_widtho      significand size of the output, 2 to 253 bits
--              exp_widtho      exponent size of the output,    3 to 31 bits
--              use_denormal    0 or 1  (default 0)
--              use_1scmpl      0 or 1  (default 0)
--
--              Input ports     Size & Description
--              ===========     ==================
--              a               (sig_widthi + exp_widthi + 7)-bits
--                              Floating-point Number Input
--              b               (sig_widthi + exp_widthi + 7)-bits
--                              Floating-point Number Input
--              op              1 bit
--                              add/sub control: 0 for add - 1 for sub
--              rnd             3 bits
--                              Rounding mode
--
--              Output ports    Size & Description
--              ===========     ==================
--              z               (sig_widtho + exp_widtho + 7) bits
--                              Floating-point Number result
--
-- MODIFIED: 
--
--------------------------------------------------------------------------------

library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_misc.all;
use DWARE.DW_Foundation_arith.all;

architecture sim of DW_ifp_addsub is
	
-- pragma translate_off


-- pragma translate_on
begin
-- pragma translate_off
  
    
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
    
    if ( (sig_widthi < 2) OR (sig_widthi > 253) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter sig_widthi (legal range: 2 to 253)"
        severity warning;
    end if;
    
    if ( (exp_widthi < 3) OR (exp_widthi > 31) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter exp_widthi (legal range: 3 to 31)"
        severity warning;
    end if;
    
    if ( (sig_widtho < sig_widthi) OR (sig_widtho > 253) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter sig_widtho (legal range: sig_widthi to 253)"
        severity warning;
    end if;
    
    if ( (exp_widtho < exp_widthi) OR (exp_widtho > 31) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter exp_widtho (legal range: exp_widthi to 31)"
        severity warning;
    end if;
    
    if ( (use_denormal < 0) OR (use_denormal > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter use_denormal (legal range: 0 to 1)"
        severity warning;
    end if;
    
    if ( (use_1scmpl < 0) OR (use_1scmpl > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter use_1scmpl (legal range: 0 to 1)"
        severity warning;
    end if;
    
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;

-- purpose: main process for the behavioral description of the FP add/sub
-- type   : combinational
-- inputs : a, b, op
-- outputs: O00IlII1
MAIN_PROCESS: process (a, b, op, rnd)
variable l1Oll11l : std_logic_vector(7-1 downto 0);
variable I1OI11O1 : std_logic_vector(7-1 downto 0);
variable O1l1O1Ol : std_logic_vector(7-1 downto 0);
variable O00IlII1 : std_logic_vector(exp_widtho+sig_widtho+7-1 downto 0);
variable I0O0llII, l00I1l00, IIl0110I, O0O11OlO, I11IOOO0, O000I1ll, I000101O, OOOOlOlO : std_logic;
variable Ol11OO1I, OOOlO00l, lO0O1111: std_logic;
variable II1IO1IO,l0I00110 :  unsigned(exp_widtho-1 downto 0); -- Exponents.
variable O1OOOI0O,I11l0011,llO01I1I :  unsigned(exp_widtho-1 downto 0);
-- The biggest possible exponent for addition/subtraction
variable O0lO100I : unsigned(exp_widtho-1 downto 0);
variable OlO0OO10,I01O0l00 :  signed(sig_widtho downto 0); -- The Mantissa numbers.
variable lO1ll111 : signed(sig_widtho+1 downto 0);
variable O01Ol0O1 : signed(sig_widtho+1 downto 0);
variable OIIll00O : signed(2 downto 0);
variable lOOO01OO : signed(2 downto 0);
variable O000OOO0 : signed(sig_widtho+1 downto 0);
variable OOOO1011 :  signed(sig_widtho downto 0); -- The Mantissa numbers.
variable lI0OlO11 :  signed(sig_widtho downto 0); -- The Mantissa numbers.
variable zero_M : signed(OOOO1011'left downto 0) := (others => '0');
variable zero_E : signed(O1OOOI0O'left downto 0) := (others => '0');
variable OO1O000O : signed(sig_widtho downto 0);  
variable I0lOO1IO : signed(sig_widtho downto 0);  
variable O0Ol1110 : signed(sig_widtho downto 0);  
variable Ol1OO100, Il00OOl1: std_logic;
variable counter : integer;
variable lO11IO10 : std_logic;
variable l0O1I1OO : std_logic;
variable lO1OOIOO : std_logic;
variable I1lOO001 : std_logic;
variable O01O0Ol0 : std_logic;
variable O0O1lOI0,l0O0OO00 : std_logic_vector(2 downto 0);
variable O1110111 : std_logic_vector(sig_widtho-sig_widthi downto 0);
variable lO11lO10 : std_logic_vector(sig_widtho-sig_widthi downto 0);
variable III111lO, OI1lI1O0 : std_logic;
variable Ol1OOOO0, O0l101O1: std_logic;

begin  -- process MAIN_PROCESS
  Ol1OOOO0 := '0';
  O0l101O1 := '0';
  I1OI11O1 := a(sig_widthi+exp_widthi+7-1 downto sig_widthi+exp_widthi);
  O1l1O1Ol := b(sig_widthi+exp_widthi+7-1 downto sig_widthi+exp_widthi);
  I0O0llII := I1OI11O1(2);
  l00I1l00 := I1OI11O1(1);
  O0O11OlO := I1OI11O1(3     );
  I11IOOO0 := O1l1O1Ol(2);
  O000I1ll := O1l1O1Ol(1);
  OOOOlOlO := O1l1O1Ol(3     );
  lO11IO10 := I1OI11O1(4);
  l0O1I1OO := O1l1O1Ol(4);
  III111lO := (I1OI11O1(6     ) and a(0)) or
              (lO11IO10 and a(sig_widthi-1));
  OI1lI1O0 := (O1l1O1Ol(6     ) and b(0)) or
              (l0O1I1OO and b(sig_widthi-1));
  O1110111 := (others => III111lO);
  lO11lO10 := (others => OI1lI1O0);
                   
  if (exp_widthi < exp_widtho) then
    -- patch LS bits with zeros
    II1IO1IO := unsigned(conv_std_logic_vector(0,exp_widtho-exp_widthi) & a(sig_widthi+exp_widthi-1 downto sig_widthi));
    l0I00110 := unsigned(conv_std_logic_vector(0,exp_widtho-exp_widthi) & b(sig_widthi+exp_widthi-1 downto sig_widthi));
  else
    II1IO1IO := unsigned(a(sig_widthi+exp_widthi-1 downto sig_widthi));               -- same value
    l0I00110 := unsigned(b(sig_widthi+exp_widthi-1 downto sig_widthi));
  end if;
  if (sig_widthi < sig_widtho) then
    OO1O000O := signed(a(sig_widthi-1) & a(sig_widthi-1 downto 0) &
                  O1110111(sig_widtho-sig_widthi downto 1));
    I0lOO1IO := signed(b(sig_widthi-1) & b(sig_widthi-1 downto 0) &
                  lO11lO10(sig_widtho-sig_widthi downto 1));
  else
    OO1O000O := signed(a(sig_widthi-1) & a(sig_widthi-1 downto 0));
    I0lOO1IO := signed(b(sig_widthi-1) & b(sig_widthi-1 downto 0));
  end if;
  IIl0110I := I1OI11O1(0) or (not l00I1l00 and not I0O0llII and not or_reduce(std_logic_vector(OO1O000O)));
  I000101O := O1l1O1Ol(0) or (not O000I1ll and not I11IOOO0 and not or_reduce(std_logic_vector(I0lOO1IO)));
  if (IIl0110I = '1') then
    II1IO1IO := (others => '0');
  end if;
  if (I000101O = '1') then
    l0I00110 := (others => '0');
  end if;

  l1Oll11l := (others => '0');

  -- correct sign of second input when subtraction is used
  if (op = '1') then 
    -- invert the sign of input b
    if (use_1scmpl = 0) then
      O0Ol1110 := -I0lOO1IO;
    else  
      O0Ol1110 := -I0lOO1IO-1;
      lO1OOIOO := not l0O1I1OO;
    end if;
  else
    O0Ol1110 := I0lOO1IO;    
    lO1OOIOO := l0O1I1OO;
  end if;

  Ol1OO100 := OO1O000O(OO1O000O'left);
  Il00OOl1 := O0Ol1110(O0Ol1110'left);
  
  OOOlO00l := Ol1OO100 xor Il00OOl1;

  -- compute the signal that defines the large and small FP value
  Ol11OO1I := '0';
  if (II1IO1IO < l0I00110) then
    Ol11OO1I := '1';
    O1OOOI0O := l0I00110;
    I11l0011 := II1IO1IO;
    OlO0OO10 := O0Ol1110;
    I01O0l00 := OO1O000O;
    if (use_1scmpl = 1) then
      I1lOO001 := lO1OOIOO;
      O01O0Ol0 := lO11IO10;
    else
      I1lOO001 := '0';
      O01O0Ol0 := '0';
    end if;
  else
    Ol11OO1I := '0';
    O1OOOI0O := II1IO1IO;
    I11l0011 := l0I00110;
    OlO0OO10 := OO1O000O;
    I01O0l00 := O0Ol1110;
    if (use_1scmpl = 1) then
      I1lOO001 := lO11IO10;
      O01O0Ol0 := lO1OOIOO;
    else
      I1lOO001 := '0';
      O01O0Ol0 := '0';
    end if;
  end if;

  if ((IIl0110I = '1' and Ol11OO1I = '1') or (I000101O = '1' and not Ol11OO1I = '1')) then
    I01O0l00 := (others => '0');
  end if;

  -- Output conditions based on input status
  -- NaN input
  if (I0O0llII = '1' or I11IOOO0 = '1') then
    -- one of the inputs is a NAN       --> the output must be an NAN
    l1Oll11l(2) := '1';
  end if;
  -- Infinity Input
  if (l00I1l00 = '1' or O000I1ll = '1') then 
    l1Oll11l(1) := '1';
    l1Oll11l(5     ) := '0';
    if (l00I1l00 = '1') then
      l1Oll11l(5     ) := I1OI11O1(5     );
    end if;
    if (O000I1ll = '1') then
      l1Oll11l(5     ) := O1l1O1Ol(5     ) xor op;
    end if;
    -- Watch out for Inf-Inf !
    if (l00I1l00 = '1' and O000I1ll = '1' and 
	(I1OI11O1(5     ) /= (O1l1O1Ol(5     ) xor op))) then
      l1Oll11l(2) := '1';
      l1Oll11l(1) := '0';
      l1Oll11l(5     ) := '0';
    end if;
  end if;
  -- Zero Input 
  if (IIl0110I = '1' and I000101O = '1') then -- Zero inputs 
    l1Oll11l(0) := '1';
    Ol1OOOO0 := I1OI11O1(5     );
    O0l101O1 := O1l1O1Ol(5     ) xor op;
    if (Ol1OOOO0 /= O0l101O1) then
      if (rnd = "011") then
        l1Oll11l(5     ) := '1';        
      else
        l1Oll11l(5     ) := '0';
      end if;
    else
      l1Oll11l(5     ) := Ol1OOOO0;
    end if;
  end if;
  --
  -- Normal Inputs
  --
    if (IIl0110I = '1') then
      if (Ol11OO1I = '1') then I01O0l00 := (others => '0');
                      else OlO0OO10 := (others => '0');
      end if;
    end if;
    if (I000101O = '1') then
      if (Ol11OO1I = '1') then OlO0OO10 := (others => '0');
                      else I01O0l00 := (others => '0');
      end if;
    end if;

    -- Shift right by llO01I1I the Small number: I01O0l00.
    lO0O1111 := '0';
    llO01I1I := O1OOOI0O - I11l0011;
    counter := 0;
    while ( (llO01I1I /= zero_E) and 
            (or_reduce(std_logic_vector(I01O0l00)) /= '0') and 
            (counter < 256)) loop
      lO0O1111 := (I01O0l00(0) xor O01O0Ol0) or lO0O1111;
      I01O0l00 := I01O0l00(I01O0l00'left) & I01O0l00(I01O0l00'length-1 downto 1);
      llO01I1I := llO01I1I - 1;
      counter := counter + 1;
    end loop;

      l1Oll11l(6     ) := ((OOOlO00l or (Ol1OO100 and Il00OOl1)) and lO0O1111) or 
                                   (I000101O and I1OI11O1(6     )) or
                                   (IIl0110I and O1l1O1Ol(6     ));
     
    -- Compute OOOO1011 result
    lO1ll111 := signed(OlO0OO10 & '0');
    O01Ol0O1 := signed(I01O0l00 & lO0O1111);
    O0O1lOI0 := '0' & (I1lOO001) & '0';
    l0O0OO00 := '0' & (O01O0Ol0) & '0';
    OIIll00O := signed(O0O1lOI0);
    lOOO01OO := signed(l0O0OO00);
    O000OOO0 := lO1ll111 + O01Ol0O1 + OIIll00O + lOOO01OO;
    OOOO1011 := O000OOO0(O000OOO0'left downto 1);
    O0lO100I := O1OOOI0O;

    lI0OlO11 := OOOO1011;
    O0lO100I := O0lO100I + 1;
    l1Oll11l(3     ) := (lO0O1111 or O0O11OlO or OOOOlOlO or lI0OlO11(0)) and not (l00I1l00 or O000I1ll or I0O0llII or I11IOOO0);
    if (O0lO100I < O1OOOI0O) then
        -- overflow
        l1Oll11l(1) := '1';
    end if;
    -- Exact zero output from non-zero inputs
    -- the sign must follow the rounding mode
    if ((or_reduce(std_logic_vector(OOOO1011)) = '0') and 
        IIl0110I = '0' and I000101O = '0' and
        l1Oll11l(2 downto 1) = "00") then
	if (rnd = "011") then -- round to minus infinity
          l1Oll11l(5     ) := '1';
        else
          l1Oll11l(5     ) := '0';
        end if;
    end if;
    -- Reconstruct the floating point format.
    O00IlII1 := l1Oll11l & conv_std_logic_vector(O0lO100I,O0lO100I'length) &
              conv_std_logic_vector(lI0OlO11(lI0OlO11'left downto 1),lI0OlO11'length-1);
  if (Is_X(a) or Is_X(b) or Is_X(op)) then
    z <= (others => 'X');
  else
    z <= O00IlII1;
  end if;
  
end process MAIN_PROCESS;

-- pragma translate_on  

end sim ;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_ifp_addsub_cfg_sim of DW_ifp_addsub is
 for sim
 end for; -- sim
end DW_ifp_addsub_cfg_sim;
-- pragma translate_on

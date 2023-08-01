
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
-- AUTHOR:    Alex Tenca and Kyung-Nam Han   March 14, 2008
--
-- VERSION:   VHDL Simulation Model for DW_ifp_mult
--
-- DesignWare_version: 7053e9a2
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--
-- ABSTRACT: Floating-Point Multiplier - Internal format
--
--              DW_ifp_mult calculates the floating-point multiplication
--              while receiving and generating FP values in internal
--              FP format (no normalization).
--
--              parameters      valid values (defined in the DW manual)
--              ==========      ============
--              sig_widthi      significand size of the input,  2 to 253 bits
--              exp_widthi      exponent size of the input,     3 to 31 bits
--              sig_widtho      significand size of the output, 2 to 253 bits
--              exp_widtho      exponent size of the output,    3 to 31 bits
--
--              Input ports     Size & Description
--              ===========     ==================
--              a               (sig_widthi + exp_widthi + 7)-bits
--                              Internal Floating-point Number Input
--              b               (sig_widthi + exp_widthi + 7)-bits
--                              Internal Floating-point Number Input
--
--              Output ports    Size & Description
--              ===========     ==================
--              z               (sig_widtho + exp_widtho + 7)-bits
--                              Internal Floating-point Number Output
-- MODIFIED:
--          
-------------------------------------------------------------------------------
library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_misc.all;
use DWARE.DW_Foundation_arith.all;

architecture sim of DW_ifp_mult is
	

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
  
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;


  MAIN_PROCESS: process (a, b)

  variable I0111lO1 : std_logic_vector(7-1 downto 0);
  variable OIO10OO0 : std_logic_vector(7-1 downto 0);
  variable IlO1l1O1 : std_logic_vector(7-1 downto 0);
  variable OIl11lO1 : std_logic_vector(exp_widtho+sig_widtho+7-1 downto 0);
  variable l1O10II0, l11lllOl, lO1I0I0O, IOIOOll0, l1IOO110, O10IIO1l, OI11O1Il, OO1lII11 : std_logic;
  variable I00O1O00: std_logic;
  variable llI101OI,OI10O10l :  unsigned(exp_widtho-1 downto 0); -- Exponents.
  variable lOOOIOl1 :  unsigned(exp_widtho downto 0);       -- Output exponent
  variable I00IOO0l :  signed(sig_widtho*2-1 downto 0); -- The Mantissa numbers.
  variable OIOll01I : signed(sig_widtho-1 downto 0);  
  variable OOlO11O0 : signed(sig_widtho-1 downto 0);  
  variable l01O1I0l, l10I111O, l110l0lI: std_logic;
  variable I1O11O01 : std_logic;
  variable OO1001Ol : std_logic;
  variable O1000OO0 : std_logic_vector(sig_widtho-sig_widthi downto 0);
  variable O1IOI0ll : std_logic_vector(sig_widtho-sig_widthi downto 0);
  variable O011OOOl, l1O0OOll : std_logic;
  variable Ill0I10O: integer;
  variable O1OI0IOl: std_logic_vector(exp_widtho downto 0);
  variable I1OOII00: std_logic_vector(exp_widtho downto 0);

  begin

  OIO10OO0 := a(sig_widthi+exp_widthi+7-1 downto sig_widthi+exp_widthi);
  IlO1l1O1 := b(sig_widthi+exp_widthi+7-1 downto sig_widthi+exp_widthi);
  l1O10II0 := OIO10OO0(2);
  l11lllOl := OIO10OO0(1);
  IOIOOll0 := OIO10OO0(3     );
  l1IOO110 := IlO1l1O1(2);
  O10IIO1l := IlO1l1O1(1);
  OO1lII11 := IlO1l1O1(3     );
  I1O11O01 := OIO10OO0(4);
  OO1001Ol := IlO1l1O1(4);
  O011OOOl := (OIO10OO0(6     ) and a(0)) or
              (I1O11O01 and a(sig_widthi-1));
  l1O0OOll := (IlO1l1O1(6     ) and b(0)) or
              (OO1001Ol and b(sig_widthi-1));
  O1000OO0 := (others => O011OOOl);
  O1IOI0ll := (others => l1O0OOll);
                   
  if (exp_widthi < exp_widtho) then
    -- patch LS bits with zeros
    llI101OI := unsigned(conv_std_logic_vector(0,exp_widtho-exp_widthi) &
                    a(sig_widthi+exp_widthi-1 downto sig_widthi));
    OI10O10l := unsigned(conv_std_logic_vector(0,exp_widtho-exp_widthi) &
                    b(sig_widthi+exp_widthi-1 downto sig_widthi));
  else
    llI101OI := unsigned(a(sig_widthi+exp_widthi-1 downto sig_widthi));               -- same value
    OI10O10l := unsigned(b(sig_widthi+exp_widthi-1 downto sig_widthi));
  end if;
  if (sig_widthi < sig_widtho) then
    OIOll01I := signed(a(sig_widthi-1 downto 0) &
                  O1000OO0((sig_widtho-sig_widthi) downto 1));
    OOlO11O0 := signed(b(sig_widthi-1 downto 0) &
                  O1IOI0ll((sig_widtho-sig_widthi) downto 1));
  else
    OIOll01I := signed(a(sig_widthi-1 downto 0));
    OOlO11O0 := signed(b(sig_widthi-1 downto 0));
  end if;
  lO1I0I0O := OIO10OO0(0) or
           (not l11lllOl and not or_reduce(std_logic_vector(OIOll01I)));
  OI11O1Il := IlO1l1O1(0) or
           (not O10IIO1l and not or_reduce(std_logic_vector(OOlO11O0)));
  if (lO1I0I0O = '1') then
    llI101OI := (others => '0');
  end if;
  if (OI11O1Il = '1') then
    OI10O10l := (others => '0');
  end if;

  I0111lO1 := (others => '0');

  l01O1I0l := OIOll01I(OIOll01I'left);
  l01O1I0l := ((lO1I0I0O or l11lllOl) and OIO10OO0(5     )) or
            ((not (lO1I0I0O or l11lllOl)) and l01O1I0l);
  l10I111O := OOlO11O0(OOlO11O0'left);
  l10I111O := ((OI11O1Il or O10IIO1l) and IlO1l1O1(5     )) or
            ((not (OI11O1Il or O10IIO1l)) and l10I111O);
  l110l0lI := l01O1I0l xor l10I111O;

  -- Output conditions based on input status
  -- NaN input
  if (l1O10II0 = '1' or l1IOO110 = '1') then
    -- one of the inputs is a NAN       --> the output must be an NAN
    I0111lO1(2) := '1';
  end if;
  -- Infinity Input
  if (l11lllOl = '1' or O10IIO1l = '1') then 
    if (lO1I0I0O = '1' or OI11O1Il = '1') then
      -- problem --> the output must be NaN
      I0111lO1(2) := '1';
    else
      I0111lO1(1) := '1';
      I0111lO1(5     ) := l110l0lI;
    end if;
  end if;
  -- Zero Input 
  if ((lO1I0I0O = '1' or OI11O1Il = '1') and
      (conv_integer(I0111lO1) = 0)) then -- Zero output 
    I0111lO1(0) := '1';
    I0111lO1(5     ) := l110l0lI;
    OIOll01I := (others => '0');
    llI101OI := (others => '0');
    OOlO11O0 := (others => '0');
    OI10O10l := (others => '0');
  end if;

  -- Ill0I10O calculation
  Ill0I10O := 2 ** (exp_widthi-1)-1;
  O1OI0IOl := conv_std_logic_vector(Ill0I10O, O1OI0IOl'length);
  I1OOII00 := not O1OI0IOl;

  I00IOO0l := (OIOll01I * OOlO11O0);  
  -- Compute result exponent
  lOOOIOl1 := ('0' & llI101OI) + ('0' & OI10O10l) + unsigned(I1OOII00 + 3);
  if (lOOOIOl1(lOOOIOl1'left) = '1' and conv_integer(I0111lO1) = 0) then
    -- overflow or underflow condition
    -- it is underflow when the input exponents are too small
    if (llI101OI(llI101OI'left) = '1') then
      lOOOIOl1 := (others => '1');
    else
      I00IOO0l := (others => '0');
      I0111lO1(3     ) := '1';
      I0111lO1(5     ) := l110l0lI;
    end if;
  end if;
  -- calculates the sticky bit
  I00O1O00 := or_reduce(std_logic_vector(I00IOO0l(I00IOO0l'left-sig_widtho downto 0))) or IOIOOll0 or OO1lII11;
  I0111lO1(3     ) := I0111lO1(3     ) or I00O1O00;
  if (I0111lO1(2) = '0' and
      (I0111lO1(0) = '1' or
       I0111lO1(1) = '1')) then
    I0111lO1(5     ) := l110l0lI;
  end if;
  -- Reconstruct the floating point format.
  OIl11lO1 := I0111lO1 & conv_std_logic_vector(lOOOIOl1,lOOOIOl1'length-1) &
            conv_std_logic_vector(I00IOO0l(I00IOO0l'left downto
                                           I00IOO0l'left-sig_widtho+1),
                                           sig_widtho);
  
  ---------------------------------------------------------
      -- Output Format
  ---------------------------------------------------------

  if (Is_X(a) or Is_X(b)) then
    z <= (others => 'X');
  else
    z <= OIl11lO1;
  end if;


  end process MAIN_PROCESS;

  -- pragma translate_on

end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_ifp_mult_cfg_sim of DW_ifp_mult is
 for sim
 end for; -- sim
end DW_ifp_mult_cfg_sim;
-- pragma translate_on

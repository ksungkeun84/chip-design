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
-- AUTHOR:    Alexandre F. Tenca - April 2006
--
-- VERSION:   VHDL Simulation Model - FP Comparator
--
-- DesignWare_version: 48f72e04
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--
-- ABSTRACT: Floating-point Comparator
--           Compares two FP numbers and generates outputs that indicate when 
--           A>B, A<B and A=B. The component also provides outputs for MAX and 
--           MIN values, with corresponding status flags.
--
--              parameters      valid values (defined in the DW manual)
--              ==========      ============
--              sig_width       significand size,  2 to 253 bits
--              exp_width       exponent size,     3 to 31 bits
--              ieee_compliance 0 or 1
--
--              Input ports     Size & Description
--              ===========     ==================
--              a               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Input
--              b               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Input
--              zctr            1 bit
--                              defines the min/max operation of z0 and z1
--
--              Output ports    Size & Description
--              ===========     ==================
--              aeqb            1 bit
--                              has value 1 when a=b
--              altb            1 bit
--                              has value 1 when a<b
--              agtb            1 bit
--                              has value 1 when a>b
--              unordered       1 bit
--                              one of the inputs is NaN
--              z0              (sig_width + exp_width + 1) bits
--                              Floating-point Number that has max(a,b) when
--                              zctr=1, and min(a,b) otherwise
--              z1              (sig_width + exp_width + 1) bits
--                              Floating-point Number that has max(a,b) when
--                              zctr=0, and min(a,b) otherwise
--              status0         byte
--                              info about FP value in z0
--              status1         byte
--                              info about FP value in z1
--
-- MODIFIED: 
--
--    4/18 - the ieee_compliance parameter is also controlling the use of nans
--           When 0, the component behaves as the MC component (no denormals
--           and no NaNs).
--
---------------------------------------------------------------------------------

library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_misc.all;
use DWARE.DW_Foundation_arith.all;

architecture sim of DW_fp_cmp is
	
-- pragma translate_off

-- component declarations

-- definitions used in the code

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
    
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;  

  MAIN: process (a, b, zctr)
  variable sign : std_logic;
  variable Ea,Eb : std_logic_vector (exp_width-1 downto 0);
  variable Ma,Mb : std_logic_vector (sig_width downto 0);
  variable Fa,Fb : std_logic_vector (sig_width-1 downto 0);
  variable chk : std_logic;
  variable zero_f : std_logic_vector (sig_width-1 downto 0);
  variable zero_e : std_logic_vector (exp_width-1 downto 0);
  variable infExp_vec : std_logic_vector(exp_width-1 downto 0);
  variable z0_int,z1_int : std_logic_vector ((exp_width + sig_width) downto 0);
  variable status0_int,status1_int: std_logic_vector (8    -1 downto 0);
  variable agtb_int,aeqb_int,altb_int, unordered_int : std_logic;
  variable zer_a, zer_b : std_logic;
  
  begin                                 -- process MAIN

  InfExp_vec := conv_std_logic_vector(((((2 ** (exp_width-1)) - 1) * 2) + 1), InfExp_vec'length);
  zero_f := (others => '0');
  zero_e := (others => '0');
  Ea := a(((exp_width + sig_width) - 1) downto sig_width);
  Eb := b(((exp_width + sig_width) - 1) downto sig_width);
  Fa := a((sig_width - 1) downto 0);
  Fb := b((sig_width - 1) downto 0);
  zer_a := '0';
  zer_b := '0';
  
  if (ieee_compliance = 1 and Ea = zero_e) then
    if (Fa = zero_f) then
        zer_a := '1';
      else
        zer_a := '0';
    end if;
    Ma := '0' & a((sig_width - 1) downto 0);
  elsif (ieee_compliance = 0 and Ea = zero_e) then
    Ma := '0' & zero_f;
    zer_a := '1';
  else
    Ma := '1' & a((sig_width - 1) downto 0);
  end if;
    
  if (ieee_compliance = 1 and Eb = zero_e) then
    if (Fb = zero_f) then
        zer_b := '1';
      else
        zer_b := '0';
    end if;
    Mb := '0' & b((sig_width - 1) downto 0);
  elsif (ieee_compliance = 0 and Eb = zero_e) then
    Mb := '0' & zero_f;
    zer_b := '1';
  else
    Mb := '1' & b((sig_width - 1) downto 0);
  end if;

  sign := (a((exp_width + sig_width)) and not zer_a) xor (b((exp_width + sig_width)) and not zer_b);
    
  status0_int := (others => '0');
  status1_int := (others => '0');
  z0_int := (others => '0');
  z1_int := (others => '0');
  agtb_int := '0';
  aeqb_int := '0';
  altb_int := '0';
  unordered_int := '0';

  --
  -- NaN input
  --
  if (((Ea = ((((2 ** (exp_width-1)) - 1) * 2) + 1) and Fa /= zero_f) or	-- a or b are NaN.
       (Eb = ((((2 ** (exp_width-1)) - 1) * 2) + 1) and Fb /= zero_f)) and (ieee_compliance = 1)) then
    -- nothing to do
    -- z0 and z1 get the values of a and b
      unordered_int := '1';
  --
  -- Infinity Input
  --
  elsif (Ea = ((((2 ** (exp_width-1)) - 1) * 2) + 1) and Eb = ((((2 ** (exp_width-1)) - 1) * 2) + 1)) then    -- a and b are Infinity.
    if (sign = '0') then
      aeqb_int := '1';
    elsif (a((exp_width + sig_width)) = '0') then
      agtb_int := '1';
    else 
      altb_int := '1';
    end if;
  elsif (Ea = ((((2 ** (exp_width-1)) - 1) * 2) + 1)) then			-- Only a is Infinity.
    if (a((exp_width + sig_width)) = '0') then agtb_int := '1';
    else altb_int := '1';
    end if;
  elsif (Eb = ((((2 ** (exp_width-1)) - 1) * 2) + 1)) then			-- Only b is Infinity.
    if (b((exp_width + sig_width)) = '0') then altb_int := '1';
    else agtb_int := '1';
    end if;
  --
  -- Zero Input
  --
  elsif (zer_a = '1' and zer_b = '1') then      -- a and b are Zero.
    aeqb_int := '1';	-- +0 == -0
  elsif (zer_a = '1') then                    	-- Only a is Zero.
    if (b((exp_width + sig_width)) = '0') then altb_int := '1';
    else agtb_int := '1';
    end if;
  elsif (zer_b = '1') then            		-- Only b is Zero.
    if (a((exp_width + sig_width)) = '0') then agtb_int := '1';
    else altb_int := '1';
    end if;
  --
  -- Normal/Denormal Inputs
  --
  elsif (sign = '1') then		-- a and b have different sign bit.
    if (a((exp_width + sig_width)) = '0') then agtb_int := '1';
    else altb_int := '1';
    end if;
  elsif (Ea /= Eb) then		-- a and b have the same sign, but different exponents
    if ( ((not a((exp_width + sig_width)))='1' and Ea>Eb) or ((a((exp_width + sig_width))='1') and Ea<Eb)) then agtb_int := '1';
    else altb_int := '1';
    end if;
  else 
    if ( ((not a((exp_width + sig_width)))='1' and Fa>Fb) or ((a((exp_width + sig_width))='1') and Fa<Fb)) then 
       agtb_int := '1';   -- a and b have the same exponent and sign but different fractions
    elsif (Fa = Fb) then
       aeqb_int := '1';
    else
       altb_int := '1';
    end if;
  end if;
    
  -- Check if agtb_int, aeqb_int, altb_int and unordered are mutually exclusive.
  chk := agtb_int or aeqb_int or altb_int or unordered_int;
  assert (chk = '1') report "ERROR: agtb, aeqb, altb, and unordered are NOT mutually exclusive." severity error;

  -- assign a or b to zx outputs according to zctr flag.
  if ( (agtb_int and zctr)='1' or (altb_int and not zctr)='1' or (aeqb_int and not zctr)='1'  or unordered_int='1') then
    z0_int := a;
    z1_int := b;
    status0_int(7) := '1';
    if (ieee_compliance = 1) then
      if (Ea = ((((2 ** (exp_width-1)) - 1) * 2) + 1) and Fa = zero_f) then status0_int(1) := '1'; end if;
      if (Ea = ((((2 ** (exp_width-1)) - 1) * 2) + 1) and Fa /= zero_f) then status0_int(2) := '1'; end if;
      if (Eb = ((((2 ** (exp_width-1)) - 1) * 2) + 1) and Fb = zero_f) then status1_int(1) := '1'; end if;
      if (Eb = ((((2 ** (exp_width-1)) - 1) * 2) + 1) and Fb /= zero_f) then status1_int(2) := '1'; end if;
    else
      if (Ea = ((((2 ** (exp_width-1)) - 1) * 2) + 1)) then status0_int(1) := '1'; end if;
      if (Eb = ((((2 ** (exp_width-1)) - 1) * 2) + 1)) then status1_int(1) := '1'; end if;
    end if;
    status0_int(0) := zer_a;
    status1_int(0) := zer_b;
  else
    z0_int := b;
    z1_int := a;
    if (ieee_compliance = 1) then
      if (Eb = ((((2 ** (exp_width-1)) - 1) * 2) + 1) and Fb = zero_f) then status0_int(1) := '1'; end if;
      if (Eb = ((((2 ** (exp_width-1)) - 1) * 2) + 1) and Fb /= zero_f) then status1_int(2) := '1'; end if;
      if (Ea = ((((2 ** (exp_width-1)) - 1) * 2) + 1) and Fa = zero_f) then status1_int(1) := '1'; end if;
      if (Ea = ((((2 ** (exp_width-1)) - 1) * 2) + 1) and Fa /= zero_f) then status0_int(2) := '1'; end if;
    else
      if (Eb = ((((2 ** (exp_width-1)) - 1) * 2) + 1)) then status0_int(1) := '1'; end if;
      if (Ea = ((((2 ** (exp_width-1)) - 1) * 2) + 1)) then status1_int(1) := '1'; end if;
    end if;
    status0_int(0) := zer_b;
    status1_int(0) := zer_a;
    status1_int(7) := '1';
  end if;


  if (Is_X(a) or Is_X(b)) then
    aeqb <= 'X';
    altb <= 'X';
    agtb <= 'X';
    unordered <= 'X';
    z0 <= (others => 'X');
    z1 <= (others => 'X');
    status0 <= (others => 'X');
    status1 <= (others => 'X');
  else
    aeqb <= aeqb_int;
    altb <= altb_int;
    agtb <= agtb_int;
    unordered <= unordered_int;
    z0 <= z0_int;
    z1 <= z1_int;
    status0 <= status0_int;
    status1 <= status1_int;
  end if;

  end process MAIN;

-- pragma translate_on  
end sim ;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_fp_cmp_cfg_sim of DW_fp_cmp is
 for sim
 end for; -- sim
end DW_fp_cmp_cfg_sim;
-- pragma translate_on

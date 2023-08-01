
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
-- AUTHOR:    Kyung-Nam Han   Nov. 6, 2006
--
-- VERSION:   VHDL Simulation Model for DW_fp_sqrt
--
-- DesignWare_version: f463b7e9
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--
-- ABSTRACT: Floating-Point Square Root
--
--              DW_fp_sqrt calculates the floating-point square root
--              while supporting six rounding modes, including four IEEE
--              standard rounding modes.
--
--              parameters      valid values (defined in the DW manual)
--              ==========      ============
--              sig_width       significand size,  2 to 253 bits
--              exp_width       exponent size,     3 to 31 bits
--              ieee_compliance support the IEEE Compliance 
--                              including NaN and denormal expressions.
--                              0 - IEEE 754 compatible without denormal support
--                                  (NaN becomes Infinity, Denormal becomes Zero)
--                              1 - IEEE 754 compatible with denormal support
--                                  (NaN and denormal numbers are supported)
--
--              Input ports     Size & Description
--              ===========     ==================
--              a               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Input
--              rnd             3 bits
--                              Rounding Mode Input
--              z               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Output
--              status          8 bits
--                              Status Flags Output
--
-- MODIFIED: 4/25/07, Kyung-Nam Han (z0703-SP2)
--           Corrected DW_fp_sqrt(-0) = -0
--           7/19/10, Kyung-Nam Han (STAR 9000404523, D-2010.03-SP4)
--           Removed bugs with (23,4,1)-configuration
--
-------------------------------------------------------------------------------
library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use DWARE.DW_Foundation_arith.all;

architecture sim of DW_fp_sqrt is
	

  -- pragma translate_off


  constant RND_Width          : integer  := 4;
  constant RND_Inc            : integer  := 0;
  constant RND_Inexact        : integer  := 1;
  constant RND_HugeInfinity   : integer  := 2;
  constant RND_TinyminNorm    : integer  := 3;
  constant R_Width : integer := (sig_width + 2);

  ----------------------------------------------------------------------
  function my_srl (a : in std_logic_vector; sh : in integer) return std_logic_vector is

    variable b : std_logic_vector(a'range) := a;
    variable count : integer := sh;

    begin

      while (count > 0) loop
        --b := '0' & b(b'length-1 downto 1);
        b := b(b'length-1) & b(b'length-1 downto 1);
        count := count - 1;
      end loop;

    return b;

  end function;

  ----------------------------------------------------------------------
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

  ----------------------------------------------------------------------
  function rnd_eval (
    rnd    : in std_logic_vector(2 downto 0);
    Sign   : in std_logic;
    L      : in std_logic;
    R      : in std_logic;
    stk    : in std_logic )
    return std_logic_vector is

    variable rnd_eval : std_logic_vector(rnd_Width - 1 downto 0);
  
    begin
  
    rnd_eval(rnd_Inc) := '0';
    rnd_eval(rnd_Inexact) := R OR stk;
    rnd_eval(rnd_HugeInfinity) := '0';
    rnd_eval(rnd_TinyminNorm) := '0';
  
    case rnd is
  
    when "000" =>
      rnd_eval(rnd_Inc) := R AND (L OR stk);
      rnd_eval(rnd_HugeInfinity) := '1';
      rnd_eval(rnd_TinyminNorm) := '0';
  
    when "001" =>
      rnd_eval(rnd_Inc) := '0';
      rnd_eval(rnd_HugeInfinity) := '0';
      rnd_eval(rnd_TinyminNorm) := '0';
  
    when "010" =>
      rnd_eval(rnd_Inc) := not (Sign) AND (R OR stk);
      rnd_eval(rnd_HugeInfinity) := not (Sign);
      rnd_eval(rnd_TinyminNorm) := not (Sign);
  
    when "011" =>
      rnd_eval(rnd_Inc) := Sign AND (R OR stk);
      rnd_eval(rnd_HugeInfinity) := Sign;
      rnd_eval(rnd_TinyminNorm) := Sign;
  
    when "100" =>
      rnd_eval(rnd_Inc) := R;
      rnd_eval(rnd_HugeInfinity) := '1';
      rnd_eval(rnd_TinyminNorm) := '0';
  
    when "101" =>
      rnd_eval(rnd_Inc) := R OR stk;
      rnd_eval(rnd_HugeInfinity) := '1';
      rnd_eval(rnd_TinyminNorm) := '1';
  
    when others =>
      rnd_eval(rnd_Inc) := 'X';
      rnd_eval(rnd_HugeInfinity) := 'X';
      rnd_eval(rnd_TinyminNorm) := 'X';
  
    end case;
  
    return(rnd_eval);

  end function;

  -- pragma translate_on

  ----------------------------------------------------------------------
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


  MAIN_PROCESS: process (a, rnd)

  variable SIGN: std_logic;
  variable EA: std_logic_vector(exp_width - 1 downto 0);
  variable SIGA: std_logic_vector(sig_width - 1 downto 0);
  variable status_reg: std_logic_vector(8     - 1 downto 0);
  variable z_reg: std_logic_vector((exp_width + sig_width) downto 0);
  variable MAX_EXP_A: BOOLEAN;
  variable InfSig_A: BOOLEAN;
  variable Zero_A: BOOLEAN;
  variable Denorm_A: BOOLEAN;
  variable NaN_Sig: std_logic_vector(sig_width - 1 downto 0);
  variable Inf_Sig: std_logic_vector(sig_width - 1 downto 0);
  variable NaN_Reg: std_logic_vector((exp_width + sig_width) downto 0);
  variable Inf_Reg: std_logic_vector((exp_width + sig_width) downto 0);
  variable exp_max: std_logic_vector(exp_width - 1 downto 0);
  variable MA: std_logic_vector(sig_width downto 0);
  variable TMP_MA: std_logic_vector(sig_width downto 0);
  variable LZ_INA: std_logic_vector(exp_width + 1 downto 0);
  variable EZ: std_logic_vector(exp_width + 1 downto 0);
  variable EM: std_logic_vector(exp_width + 1 downto 0);
  variable Denorm_A_bit: std_logic;
  variable MZ: std_logic_vector(sig_width + 1 downto 0);
  variable REMAINDER: std_logic_vector(R_Width downto 0);
  variable Sticky: std_logic;
  variable Round_Bit: std_logic;
  variable Mantissa: std_logic_vector(R_Width - 1 downto 1);
  variable Mantissa2: std_logic_vector(R_Width - 2 downto 0);
  variable rnd_val: std_logic_vector(RND_Width - 1 downto 0);
  variable Movf: std_logic;
  variable temp_mantissa: std_logic_vector(R_Width downto 1);
  variable Sqrt_in: std_logic_vector(2 * sig_width + 3 downto 0);
  variable sqrt_zeros: std_logic_vector(sig_width + 1 downto 0);
  variable temp_remainder: std_logic_vector(2 * sig_width + 3 downto 0);
  variable Guard_Bit: std_logic;
  variable zero_exp: std_logic_vector(exp_width + 1 downto 0);
  variable NegInput: BOOLEAN;
  variable SignNeg: BOOLEAN;
  variable zero_expsig: std_logic_vector(exp_width + sig_width - 1 downto 0);
  variable EZ_shift: integer;
 
  begin

  SIGN := '0';
  EA := a(((exp_width + sig_width) - 1) downto sig_width);
  SIGA := a((sig_width - 1) downto 0);
  status_reg := (others => '0');
  MAX_EXP_A := (EA = ((((2 ** (exp_width-1)) - 1) * 2) + 1));
  InfSig_A := (SIGA = 0);
  exp_max := (others => '1');
  LZ_INA := (others => '0');
  sqrt_zeros := (others => '0');
  zero_exp := (others => '0');
  zero_expsig := (others => '0');
    
  -- Zero and Denormal
  if (ieee_compliance = 1) then
    Zero_A := (EA = 0) and (SIGA = 0);
    Denorm_A := (EA = 0) and (SIGA /= 0);

    NaN_Sig := (others => '0');
    NaN_Sig(0) := '1';
    Inf_Sig := (others => '0');
    NaN_Reg := '0' & exp_max & NaN_Sig;
    Inf_Reg := '0' & exp_max & Inf_Sig;

    if (Denorm_A) then
      MA := '0' & a((sig_width - 1) downto 0);
    else
      MA := '1' & a((sig_width - 1) downto 0);
    end if;

  else
    Zero_A := (EA = 0);
    Denorm_A := FALSE;

    MA := '1' & a((sig_width - 1) downto 0);
    NaN_Sig := (others => '0');
    Inf_Sig := (others => '0');
    NaN_Reg := '0' & exp_max & NaN_Sig;
    Inf_Reg := '0' & exp_max & Inf_Sig;
  end if;

  if (a((exp_width + sig_width)) = '0') then
    SignNeg := FALSE;
  else
    SignNeg := TRUE;
  end if;


  NegInput := (not Zero_A) and SignNeg;
  if ((ieee_compliance = 1 and MAX_EXP_A and not (InfSig_A)) or NegInput) then
    status_reg(2) := '1';
    z_reg := NaN_Reg;

  elsif (MAX_EXP_A) then

    if (ieee_compliance = 0) then
      status_reg(1) := '1';
    end if;

    if (Zero_A) then
      status_reg(2) := '1';
      z_reg := NaN_Reg;
    else
      status_reg(1) := '1';
      z_reg := Inf_Reg;
    end if;

  elsif (Zero_A) then
    
    status_reg(0) := '1';
    z_reg := a((exp_width + sig_width)) & zero_expsig;

  -- Normal & Denormal Operation
  else

    TMP_MA := MA;
    if (Denorm_A) then
      while (MA(sig_width) /= '1') loop
        MA := my_sll(MA, 1);
        LZ_INA := LZ_INA + 1;
      end loop;

      Denorm_A_bit := '1';

    else
      Denorm_A_bit := '0';
    end if;

    -- Exponent Calculation
    EM := EA - LZ_INA + Denorm_A_bit - ((2 ** (exp_width-1)) - 1);
    EZ := my_srl(EM, 1);

    -- Adjust Exponent Bias
    EZ := EZ + ((2 ** (exp_width-1)) - 1);


    -- Square Root Operation
    if (EM(0) = '0') then
      Sqrt_in := '0' & MA & sqrt_zeros;
    else
      Sqrt_in := MA & sqrt_zeros & '0';
    end if;
    MZ := std_logic_vector(DWF_sqrt(unsigned(Sqrt_in)));

    temp_remainder := Sqrt_in - MZ * MZ;
    REMAINDER := temp_remainder(sig_width + 2 downto 0);


    -- Sticky Calculation
    if (REMAINDER = 0) then
      Sticky := '0';
    else
      Sticky := '1';
    end if;


    if (ieee_compliance = 1 and (EZ = zero_exp or EZ(exp_width + 1) = '1')) then
      Sticky := Sticky or MZ(0);
      MZ := '0' & MZ(sig_width + 1 downto 1);
    end if;

    Mantissa := MZ(R_Width - 1 downto 1);
    Round_Bit := MZ(0);
    Guard_Bit := MZ(1);

    -- Rounding Operation
    rnd_val := rnd_eval(rnd, '0', Guard_Bit, Round_Bit, Sticky);

    -- Round Addition
    if (rnd_val(RND_Inc) = '1') then
      temp_mantissa := "0" & Mantissa + 1;
    else
      temp_mantissa := "0" & Mantissa;
    end if;

    Movf := temp_mantissa(R_Width);

    -- Normalize the Mantissa for overflow case after rounding
    if (Movf = '1') then
      EZ := EZ + 1;
      temp_mantissa := my_srl(temp_mantissa, 1);
    end if;

    Mantissa := temp_mantissa(R_Width - 1 downto 1);

    -- 
    -- Tiny
    --
    if (EZ = 0) then
      status_reg(3) := '1';
  
      if (Mantissa(R_Width - 2 downto 1) = 0 and
          EZ(exp_width - 1 downto 0) = 0) then
        status_reg(0) := '1';
      end if;

    end if;

    status_reg(5) := rnd_val(RND_Inexact);

    Mantissa2 := Mantissa(R_Width - 1 downto 1);

    if (ieee_compliance = 1 and EZ(exp_width + 1) = '1') then
      EZ_shift := conv_integer((not EZ) + 1);

      Mantissa2 := my_srl(Mantissa2, EZ_shift);

      EZ := (others => '0');
    end if;

    -- Reconstruct the FP number
    z_reg := "0" & EZ(exp_width - 1 downto 0) & Mantissa2(R_Width - 3 downto 0);

  end if;


  ---------------------------------------------------------
      -- Output Format
  ---------------------------------------------------------

  if (Is_X(a) or Is_X(rnd)) then
  
    status <= (others => 'X');
    z <= (others => 'X');
  
  else

    status <= status_reg;
    z <= z_reg;

  end if;

  end process MAIN_PROCESS;

  -- pragma translate_on

end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_fp_sqrt_cfg_sim of DW_fp_sqrt is
 for sim
 end for; -- sim
end DW_fp_sqrt_cfg_sim;
-- pragma translate_on

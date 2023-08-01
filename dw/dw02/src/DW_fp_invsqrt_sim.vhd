
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
-- AUTHOR:    Alexandre Tenca and Kyung-Nam Han Dec. 5, 2006
--
-- VERSION:   VHDL Simulation Model for DW_fp_invsqrt
--
-- DesignWare_version: 0c90f4c1
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--
-- ABSTRACT: Floating-Point Inverse Square Root
--
--              DW_fp_invsqrt calculates the floating-point reciprocal of 
--              a square root. It supports six rounding modes, including 
--              four IEEE standard rounding modes.
--
--              parameters      valid values
--              ==========      ============
--              sig_width       significand f,  2 to 253 bits
--              exp_width       exponent e,     3 to 31 bits
--              ieee_compliance 0 or 1 
--                              support the IEEE Compliance 
--                              including NaN and denormal.
--                              0 - MC (module compiler) compatible
--                              1 - IEEE 754 standard compatible
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
-- MODIFIED:
--
--   05/05/10 Kyung-Nam Han (STAR 9000391410, D-2010.03-SP2)
--            Fixed that 1/sqrt(-0) = -Inf, and set divide_by_zero flag. 
--   07/08/10 Kyung-Nam Han (STAR 9000404527, D-2010.03-SP4)
--            Fixed an error of (23, 4, 1)-configuration.
--            When input is a very small denormal, output does not show Inf.
-------------------------------------------------------------------------------

library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_misc.all;
use DWARE.DW_Foundation_comp.all;

architecture sim of DW_fp_invsqrt is
	

  -- pragma translate_off



-- RND_eval function used in several FP components
function RND_eval (RND: std_logic_vector(2 downto 0);
                   Sign: std_logic;
                   L: std_logic;
                   R: std_logic;
                   STK: std_logic) return std_logic_vector is
--*******************************
--  RND_val has 4 bits:
--  RND_val[0]
--  RND_val[1]
--  RND_val[2]
--  RND_val[3]
--*******************************

--*******************************
--  Rounding increment equations
--  |
--    MODE | Equation   | Description
--    -----------------------------
--    even | R&(L|STK)  | IEEE round to nearest (even)
--    zero | 0          | IEEE round to zero
--    +inf | S'&(R|STK) | IEEE round to positive infinity
--    -inf | S&(R|STK)  | IEEE round to negative infinity
--     up  | R          | round to nearest (up)
--    away | (R|STK)    | round away from zero
-- *******************************
variable RND_eval : std_logic_vector (4-1 downto 0);
begin
  RND_eval(0) := '0';
  RND_eval(1) := R or STK;
  RND_eval(2) := '0';
  RND_eval(3) := '0';
  case RND is
    when "000" =>
      -- round to nearest (even) 
      RND_eval(0) := R and (L or STK);
      RND_eval(2) := '1';
      RND_eval(3) := '0';
    when "001" =>
      -- round to zero 
      RND_eval(0) := '0';
      RND_eval(2) := '0';
      RND_eval(3) := '0';
    when "010" =>
      -- round to positive infinity 
      RND_eval(0) := not Sign and (R or STK);
      RND_eval(2) := not Sign;
      RND_eval(3) := not Sign;
    when "011" =>
      -- round to negative infinity 
      RND_eval(0) := Sign and (R or STK);
      RND_eval(2) := Sign;
      RND_eval(3) := Sign;
    when "100" =>
      -- round to nearest (up)
      RND_eval(0) := R;
      RND_eval(2) := '1';
      RND_eval(3) := '0';
    when "101" =>
      -- round away form 0  
      RND_eval(0) := R or STK;
      RND_eval(2) := '1';
      RND_eval(3) := '1';
    when others =>
      RND_eval(0) := 'X';
      RND_eval(2) := 'X';
      RND_eval(3) := 'X';
  end case;
  return (RND_eval);
end function;                                    -- RND_val function

 ----------------------------------------------------------------------
  function local_srl (a : in std_logic_vector; sh : in integer) return std_logic_vector 
is

    variable b : std_logic_vector(a'range) := a;
    variable count : integer := sh;

    begin

      while (count > 0) loop
        b := '0' & b(b'length-1 downto 1);
        count := count - 1;
      end loop;

    return b;

  end function;

  ----------------------------------------------------------------------
  function local_sll (a : in std_logic_vector; sh : in integer) return std_logic_vector 
is

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

  constant R_Width : integer := (sig_width + 2);

  signal Sticky: std_logic;
  signal InvSQRT_inp : std_logic_vector(R_Width-1 downto 0);
  signal InvSQRT_out : std_logic_vector(R_width-1 downto 0);

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


  MAIN_PROCESS: process (a, rnd, Sticky, InvSQRT_out)

  variable SIGNA: std_logic;
  variable SIGN: std_logic;
  variable EA: std_logic_vector(exp_width - 1 downto 0);
  variable actual_EA: std_logic_vector(exp_width - 1 downto 0);
  variable SIGA: std_logic_vector(sig_width - 1 downto 0);
  variable MAX_EXP_A: BOOLEAN;
  variable ZerSig_A: BOOLEAN;
  variable Zero_A: BOOLEAN;
  variable Denorm_A: BOOLEAN;
  variable NaN_A: BOOLEAN;
  variable Inf_A: BOOLEAN;
  variable NaN_Sig: std_logic_vector(sig_width - 1 downto 0);
  variable Inf_Sig: std_logic_vector(sig_width - 1 downto 0);
  variable Zero_Sig: std_logic_vector(sig_width - 1 downto 0);
  variable NaN_Reg: std_logic_vector((exp_width + sig_width) downto 0);
  variable Inf_Reg: std_logic_vector((exp_width + sig_width) downto 0);
  variable exp_max: std_logic_vector(exp_width - 1 downto 0);
  variable MA: std_logic_vector(sig_width downto 0);
  variable TMP_MA: std_logic_vector(sig_width downto 0);
  variable extended_MA: std_logic_vector(R_width-1 downto 0);
  variable LZ_INA: std_logic_vector(exp_width + 1 downto 0);
  variable z_reg: std_logic_vector((exp_width + sig_width) downto 0);
  variable status_reg: std_logic_vector(8     - 1 downto 0);
  variable EZ: std_logic_vector(exp_width + 1 downto 0);
  variable EM: std_logic_vector(exp_width + 1 downto 0);
  variable EZ_MAX: std_logic_vector(exp_width + 1 downto 0);
  variable EZ_MAX_pre: std_logic_vector(exp_width - 1 downto 0);
  variable Denorm_A_bit: std_logic;
  variable Round_Bit: std_logic;
  variable LS_Bit: std_logic;
  variable STK_Bit : std_logic;
  variable Mantissa: std_logic_vector(R_Width - 1 downto 1);
  variable temp_mantissa: std_logic_vector(R_Width downto 1);
  variable rnd_val: std_logic_vector(4 - 1 downto 0);
  variable EZ_Zero: BOOLEAN;
  variable Movf: std_logic;
  variable quarter_input : std_logic; 
  
  begin

  SIGNA := a((exp_width + sig_width));
  EA := a(((exp_width + sig_width) - 1) downto sig_width);
  SIGA := a((sig_width - 1) downto 0);
  status_reg := (others => '0');
  MAX_EXP_A := (EA = ((((2 ** (exp_width-1)) - 1) * 2) + 1));
  ZerSig_A := (SIGA = 0);
  exp_max := (others => '1');
  Zero_Sig := (others => '0');
  LZ_INA := (others => '0');
  quarter_input := '0';
  EZ_MAX_pre := (others => '1');
  EZ_MAX := "00" & EZ_MAX_pre;
  
  if (ieee_compliance = 1) then
    Zero_A := (EA = 0) and (ZerSig_A);
    Denorm_A := (EA = 0) and (not ZerSig_A);
    NaN_A := (EA = ((((2 ** (exp_width-1)) - 1) * 2) + 1)) and (not ZerSig_A);
    Inf_A := (EA = ((((2 ** (exp_width-1)) - 1) * 2) + 1)) and (ZerSig_A);

    NaN_Sig := (others => '0');
    NaN_Sig(0) := '1';
    Inf_Sig := Zero_Sig;
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
    NaN_A := FALSE;
    Inf_A := (EA = ((((2 ** (exp_width-1)) - 1) * 2) + 1));

    MA := '1' & a((sig_width - 1) downto 0);
    NaN_Sig := (others => '0');
    Inf_Sig := Zero_Sig;
    NaN_Reg := '0' & exp_max & NaN_Sig;
    Inf_Reg := '0' & exp_max & Inf_Sig;
  
  end if;

  if (Zero_A) then
    SIGN := SIGNA;
  else
    SIGN := '0';
  end if;

  if (NaN_A or ((SIGNA = '1') and (not Zero_A))) then
    status_reg(2) := '1';
    z_reg := NaN_Reg;

  elsif (Zero_A) then
    status_reg(7) := '1';
    status_reg(1) := '1';
    z_reg := SIGN & Inf_Reg((exp_width + sig_width) - 1 downto 0);

  elsif (Inf_A) then
    status_reg(0) := '1';
    z_reg := (others => '0');

  else

    TMP_MA := MA;
    actual_EA := EA - ((2 ** (exp_width-1)) - 1);
    if (Denorm_A) then
      while (MA(sig_width-1) /= '1') loop
        MA := local_sll(MA, 1);
        LZ_INA := LZ_INA + 1;
      end loop;
      Denorm_A_bit := '1';
      if ((LZ_INA(0) xor actual_EA(0)) = '1') then
        MA := local_sll(MA,1);
        LZ_INA := LZ_INA + 1;
      end if;
      extended_MA := MA & '0';
    else
      LZ_INA := (others => '1');
      if (actual_EA(0) = '1') then
        extended_MA := MA & '0';
      else
        extended_MA := '0' & MA;
      end if;
      Denorm_A_bit := '0';
    end if;
    if ((or_reduce(extended_MA(R_width-3 downto 0)) = '0') and 
        (extended_MA(R_width-1) = '0')) then
      quarter_input := '1';
    end if;

    EM := not (EA - LZ_INA - quarter_input + Denorm_A_bit - ((2 ** (exp_width-1)) - 1)) + 1;
    EZ := local_srl(EM, 1);

    InvSQRT_inp <= extended_MA;

    if (quarter_input = '1') then
      Mantissa := (others => '0');
      Mantissa(R_width-1) := '1';
      Round_Bit := '0';
      LS_Bit := '0';
      STK_Bit := '0';
    else
      Mantissa := InvSQRT_out(R_Width-1 downto 1);
      Round_Bit := InvSQRT_out(0);
      LS_Bit := InvSQRT_out(1);
      STK_Bit := Sticky;
    end if;

    rnd_val := RND_eval(rnd, '0', LS_Bit, Round_Bit, STK_Bit);

    if (rnd_val(0) = '1') then
      temp_mantissa := "0" & Mantissa + 1;
    else
      temp_mantissa := "0" & Mantissa;
    end if;

    Movf := temp_mantissa(R_Width);

    if (Movf = '1') then
      EZ := EZ + 1;
      temp_mantissa := local_srl(temp_mantissa, 1);
    end if;

    Mantissa := temp_mantissa(R_Width - 1 downto 1);

    if (ieee_compliance = 1 and (EZ + ((2 ** (exp_width-1)) - 1) <= 0) and Mantissa(R_Width - 1) = '1') then
    EZ := EZ + 1;
    end if;

    EZ_Zero := (EZ = ((2 ** (exp_width-1)) - 1));

    EZ := EZ + ((2 ** (exp_width-1)) - 1);

    if (EZ = 0) then
      status_reg(3) := '1';
  
      if (Mantissa(R_Width - 2 downto 1) = 0 and
          EZ(exp_width - 1 downto 0) = 0) then
        status_reg(0) := '1';
      end if;

    end if;

    status_reg(5) := rnd_val(1);

    if ((EZ >= EZ_MAX) and EZ(exp_width + 1) = '0') then
      status_reg(1) := '1';
      status_reg(5) := '0';
      EZ := EZ_MAX;
      Mantissa := (others => '0');
    end if;

    z_reg := SIGN & EZ(exp_width - 1 downto 0) & Mantissa(R_Width - 2 downto 1);

  end if;



  if (Is_X(a) or Is_X(rnd)) then
  
    status <= (others => 'X');
    z <= (others => 'X');
  
  else

    status <= status_reg;
    z <= z_reg;
      
  end if;

  end process MAIN_PROCESS;

  U1 : DW_inv_sqrt generic map ( a_width => R_Width )
  port map ( a => InvSQRT_inp, b => InvSQRT_out, t => Sticky );


  -- pragma translate_on

end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

library dw02;

configuration DW_fp_invsqrt_cfg_sim of DW_fp_invsqrt is
 for sim
  for U1 : DW_inv_sqrt use configuration dw02.DW_inv_sqrt_cfg_sim; end for;
 end for; -- sim
end DW_fp_invsqrt_cfg_sim;
-- pragma translate_on


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
-- AUTHOR:    Kyung-Nam Han   Jan. 18, 2005
--
-- VERSION:   VHDL Simulation Model for DW_fp_i2flt
--
-- DesignWare_version: 7e8efbe0
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------

--------------------------------------------------------------------
--
-- ABSTRACT:  Integer Number Format to Floating-Point Number Format Converter
--
--              This converts an integer number to a floating-point number.
--
--              parameters      valid values (defined in the DW manual)
--              ==========      ============
--              sig_width       significand size,  2 to 253 bits
--              exp_width       exponent size,     3 to 31 bits
--              isize           integer size,      3 to 512 bits
--              isign           signed/unsigned integer flag
--                              0 - unsigned, 1 - signed integer (2's complement)
--
--              Input ports     Size & Description
--              ===========     ==================
--              a               (isize)-bits
--                              Integer Input
--              rnd             3 bits
--                              Rounding Mode Input
--              status          8 bits
--                              Status Flags Output
--              z               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Output
-- 
-- MODIFIED:
--
--	8/1/2012    RJK - Tightened isize restriction as per STAR 9000557637
--------------------------------------------------------------------

library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_misc.all;

architecture sim of DW_fp_i2flt is
	

  -- pragma translate_off


  constant rnd_Width          : integer  := 4;
  constant rnd_Inc            : integer  := 0;
  constant rnd_Inexact        : integer  := 1;
  constant rnd_HugeInfinity   : integer  := 2;
  constant rnd_TinyminNorm    : integer  := 3;

  constant Mwidth   : integer  := sig_width + 4;
  constant Movf     : integer  := Mwidth - 1;
  constant ML       : integer  := 2;
  constant MR       : integer  := 1;
  constant MS       : integer  := 0;

  ----------------------------------------------------------------------
  function my_srl (a : in std_logic_vector; sh : in integer) return std_logic_vector is

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
     
    if ( (isize < 3+isign) or (isize > 512) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Parameter isize must be at least 3+isign and no greater than 512"
        severity warning;
    end if; 
     
    if ( (isign < 0) OR (isign > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter isign (legal range: 0 to 1)"
        severity warning;
    end if;
  
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;


  MAIN_PROCESS: process (a, rnd)

  variable ai   : std_logic_vector(isize - 1 downto 0);
  variable aif  : std_logic_vector(Movf - 1 downto 0);
  variable status_reg : std_logic_vector(8     - 1 downto 0);
  variable z_reg : std_logic_vector((exp_width + sig_width) downto 0);
  variable LZ   : std_logic_vector(isize - 1 downto 0);
  variable num   : std_logic_vector(isize - 1 downto 0);
  variable Mf   : std_logic_vector(Mwidth - 1 downto 0);
  variable EXP   : std_logic_vector(exp_width downto 0);
  variable STK : std_logic;
  variable rnd_val : std_logic_vector(rnd_Width - 1 downto 0);

  variable zero_vec   : std_logic_vector(isize - 1 downto 0);
  variable one_vec : std_logic_vector(Mwidth - 1 downto 0);

  variable zero_f : std_logic_vector(Movf - isize - 1 downto 0);


  begin

  ai := a;
  zero_f := (others => '0');
  status_reg := (others => '0');
  LZ := (others => '0');
  Mf := (others => '0');
  EXP := (others => '0');
  STK := '0';
  zero_vec := (others => '0');

  one_vec := (others => '0');
  one_vec(0) := '1';


  -------------------------------------------
  -- Zero Detection of Input
  -------------------------------------------
  if (or_reduce(ai) = '0') then
    status_reg(0) := '1';
    z_reg := (others => '0');

  -------------------------------------------
  -- Non-zero Integer Calculation
  -------------------------------------------
  else

    if (isign = 1) then -- signed number setting

      if (ai(isize -1) = '1') then
        ai := not ai + 1;
        z_reg((exp_width + sig_width)) := '1';
      else 
        z_reg((exp_width + sig_width)) := '0';
      end if;

    else -- unsigned number setting
      z_reg((exp_width + sig_width)) := '0';

    end if;

    --------------------------------------------------------------------------
    -- Convert the unsigned magnitude representation to floating-point format
    -- Left shift to normalize Ai
    --------------------------------------------------------------------------

    while (ai(isize - 1) = '0') loop
      ai := my_sll(ai, 1);
      LZ := LZ + 1;
    end loop;

    ----------------------------------
    -- Calculate the Biased Exponent
    ----------------------------------
    if (isize - 1 - conv_integer(LZ) + ((2 ** (exp_width-1)) - 1) >= ((((2 ** (exp_width-1)) - 1) * 2) + 1)) then
      EXP := conv_std_logic_vector(((((2 ** (exp_width-1)) - 1) * 2) + 1), EXP'length);
    else
      EXP := conv_std_logic_vector(isize - 1 - conv_integer(LZ) + ((2 ** (exp_width-1)) - 1), EXP'length);
    end if;

    ----------------------------------
    -- Converts integer to fraction
    ----------------------------------
    if (isize <= sig_width + 2) then
      -- If the Mantissa fraction (f+2) is big enough to hold ai,
      -- Left adjustment at Movf-1: Movf-1-(isize-1) = Movf-isize >= i

      aif := zero_f & ai;
      Mf(Movf - 1 downto 0) := my_sll(aif, Movf - isize);

    else
      -- If the Mantissa fraction (f+2) in NOT big enough to hold ai,
      -- calculate the STK.

      Mf(Movf - 1 downto MR) := ai(isize - 1 downto isize - sig_width - 2);
      STK := '0';
      num := conv_std_logic_vector(isize - sig_width - 3, num'length);
    
      while (num /= 0) loop
        STK := STK OR ai(conv_integer(num));
        num := num - 1;
      end loop;

      STK := STK OR ai(conv_integer(num));
      Mf(MS) := STK;

    end if;


    ------------------------------------------------------
    -- Round the Mantissa according to the rounding modes
    ------------------------------------------------------
    rnd_val := rnd_eval(RND, z_reg((exp_width + sig_width)), Mf(ML), Mf(MR), Mf(MS));

    if (rnd_val(rnd_Inc) = '1') then
      Mf := Mf + my_sll(one_vec, ML);
    end if;

    status_reg(5) := rnd_val(rnd_Inexact);

    -----------------------------------------------------------
    -- Normalize the Mantissa for overflow case after rounding
    -----------------------------------------------------------
    if (Mf(Movf) = '1') then

      EXP := EXP + 1;
      Mf := my_srl(Mf, 1);

    end if;
    
    ----------------------------------------
    -- Note: "Tiny" situation doesn't exist
    ----------------------------------------
    if (EXP >= ((((2 ** (exp_width-1)) - 1) * 2) + 1)) then

      status_reg(4) := '1';
      status_reg(5) := '1';

      if (rnd_val(rnd_HugeInfinity) = '1') then

        EXP := conv_std_logic_vector(((((2 ** (exp_width-1)) - 1) * 2) + 1), EXP'length);
        --Mf(Movf - 2 downto ML) := (others => '1');
        Mf(Movf - 2 downto ML) := (others => '0');
        status_reg(1) := '1';

      else

        -- MaxNorm
        EXP := conv_std_logic_vector(((((2 ** (exp_width-1)) - 1) * 2) + 1) - 1, EXP'length);
        Mf(Movf -2 downto ML) := (others => '1');

      end if;

    end if;

    z_reg := z_reg((exp_width + sig_width)) & EXP((exp_width - 1) downto 0) & Mf(Movf - 2 downto ML);

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

configuration DW_fp_i2flt_cfg_sim of DW_fp_i2flt is
 for sim
 end for; -- sim
end DW_fp_i2flt_cfg_sim;
-- pragma translate_on

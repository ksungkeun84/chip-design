
--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2005 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Kyung-Nam Han   Oct. 31, 2005
--
-- VERSION:   VHDL Simulation Model for DW_fp_flt2i
--
-- DesignWare_version: 9528b86b
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------

--
-- ABSTRACT:  Floating-point Number Format to Integer Number Format Converter
--
--              This converts a floating-point number to a signed integer number.
--              Conversion to a unsigned integer number is not supported.
--
--              parameters      valid values (defined in the DW manual)
--              ==========      ============
--              sig_width       significand size,  2 to 253 bits
--              exp_width       exponent sizee,    3 to 31 bits
--              isize           integer size,      3 to 512 bits
--              ieee_compliance support the IEEE Compliance 
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
--              z               (isize)-bits
--                              Converted Integer Output
--              status          8 bits
--                              Status Flags Output
--
-- Modified:
--   Sep.09.2009 Kyung-Nam Han (C-2009.03-SP3)
--     Added ieee_compliance parameter
--------------------------------------------------------------------

library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_misc.all;
use DWARE.DW_Foundation_arith.all;
use IEEE.numeric_std.all;

architecture sim of DW_fp_flt2i is
	

  -- pragma translate_off

  constant isign  : integer := 0;	-- 0: sign, 1: unsigned	
  constant int_isign  : integer   := 0;
  constant Mwidth   : integer  := 2 * isize + 2;
  constant Movf   : integer  := Mwidth - 1;
  constant MM   : integer   := Movf - 1;
  constant ML   : integer  := Movf - isize;
  constant MR   : integer  := ML - 1;
  constant MS   : integer   := ML - 2;
  constant Mx   : integer  := 0;


  ----------------------------------------------------------------------
  function convert_unsigned (ARG : std_logic_vector) return UNSIGNED is

    variable z: UNSIGNED (arg'range);
  
    begin
  
    for i in ARG'range loop
      z(i) := ARG(i);
    end loop;
  
    return (z);
  
  end; --  function convert_signed;


  ----------------------------------------------------------------------
  -- purpose: convert unsigned to _raw_std_logic_vector_
  function convert_std_logic_vector (ARG : UNSIGNED) 
      return std_logic_vector is

    variable z: std_logic_vector(arg'range);
  
    begin
  
    for i in ARG'range loop
      z(i) := ARG(i);
    end loop;  -- i
  
    return (z);

  end; --  function convert_std_logic_vector;

  constant rnd_Width   : integer  := 4;
  constant rnd_Inc   : integer  := 0;
  constant rnd_Inexact   : integer  := 1;
  constant rnd_HugeInfinity   : integer  := 2;
  constant rnd_TinyminNorm   : integer  := 3;


  ----------------------------------------------------------------------
  function rnd_eval (
    rnd   : in std_logic_vector(2 downto 0);
    Sign   : in std_logic;
    L   : in std_logic;
    R   : in std_logic;
    stk   : in std_logic)
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
     
    if ( (isize < 3) OR (isize > 512) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter isize (legal range: 3 to 512)"
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

  variable af        : std_logic_vector((exp_width + sig_width) downto 0);
  variable status_reg: std_logic_vector(8     - 1 downto 0);
  variable mi        : std_logic_vector(Mwidth - 1 downto 0);
  variable stk       : std_logic;
  variable eaf       : std_logic_vector(exp_width - 1 downto 0);
  variable num       : integer;
  variable rnd_val   : std_logic_vector(rnd_Width - 1 downto 0);
  variable z_reg     : std_logic_vector(isize - 1 downto 0);
  variable maxneg    : std_logic_vector(isize - 1 downto 0);
  variable maxpos    : std_logic_vector(isize - 1 downto 0);
  variable zero_vec  : unsigned(mi'length - 1 downto 1);

  variable exp       : std_logic_vector(exp_width - 1 downto 0);
  variable zero_exp  : std_logic_vector(exp'range);

  variable sig          : std_logic_vector((sig_width - 1) downto 0);
  variable zero_sig     : std_logic_vector((sig_width - 1) downto 0);
  variable inf_input    : BOOLEAN;
  variable denorm_input : BOOLEAN;
  variable nan_input    : BOOLEAN;
  variable zero_input   : BOOLEAN;
  

  begin

  af := a;
  status_reg := (others => '0');
  mi := (others => '0');
  exp := (others => '0');
  stk := '0';
  eaf := af(((exp_width + sig_width) - 1) downto sig_width);
  num := 0;
  zero_vec := (others => '0');
  zero_exp := (others => '0');
  sig := af((sig_width - 1) downto 0);
  zero_sig := (others => '0');

  if (ieee_compliance = 1) then

    inf_input := (eaf = ((((2 ** (exp_width-1)) - 1) * 2) + 1)) and (sig = zero_sig);
    nan_input := (eaf = ((((2 ** (exp_width-1)) - 1) * 2) + 1)) and (sig /= zero_sig);
    denorm_input := (eaf = 0 ) and (sig /= zero_sig);
    zero_input := (eaf = 0 ) and (sig = zero_sig);

  else

    inf_input := (eaf = ((((2 ** (exp_width-1)) - 1) * 2) + 1));
    nan_input := FALSE;
    denorm_input := FALSE;
    zero_input := (eaf = 0 );
 
  end if;

  if (inf_input) then

    if (ieee_compliance = 1) then
      status_reg(2) := '1';
    else
      status_reg(6) := '1';
      status_reg(5) := '1';
    end if;

  elsif (nan_input) then

    status_reg(2) := '1';

  elsif (zero_input) then

    status_reg(0) := '1';

  else
    mi(ML) := '1';

    if (sig_width <= isize) then
      mi(MR downto MR - sig_width + 1) := af((sig_width - 1) downto 0);

    else

      mi(MR downto MR - isize + 1) := af((sig_width - 1) downto (sig_width - 1) - isize + 1);
      num := (sig_width - 1) - isize;
      stk := '0';
  
      while (num /= 0) loop
        stk := stk OR af(num);
        num := num - 1;
      end loop;

      stk := stk OR af(num);
      mi(0) := stk;

    end if;

    if (eaf >= ((2 ** (exp_width-1)) - 1)) then
      exp := eaf - ((2 ** (exp_width-1)) - 1);

    while (conv_integer(exp) /= 0) loop

      if (mi(Movf) /= '1') then
        mi := convert_std_logic_vector(
        convert_unsigned(mi) sll 1);
      end if;

      exp := exp - 1;

    end loop;

    else 
      exp := ((2 ** (exp_width-1)) - 1) - eaf;

      while (conv_integer(exp) /= 0) loop

        stk := mi(0);
        mi := convert_std_logic_vector(
        convert_unsigned(mi) srl 1);
        mi(0) := stk OR mi(0);
        exp := exp - 1;

      end loop;

    end if;

    if (mi(Movf) = '1') then

      status_reg(6) := '1';
      status_reg(5) := '1';

    else

      stk := '0';
      num := MS;
  
      while (num /= 0) loop

        stk := stk OR mi(num);
        num := num - 1;

      end loop;

      stk := stk OR mi(num);
      mi(MS) := stk;


      rnd_val := rnd_eval(rnd, af((exp_width + sig_width)), mi(ML), mi(MR), mi(MS));

      if (rnd_val(rnd_Inc) = '1') then

        mi := convert_std_logic_vector(
        convert_unsigned(mi) + ((zero_vec & '1') sll ML));

      end if;

      status_reg(5) := 
      status_reg(5) OR rnd_val(rnd_Inexact);

      if (mi(Movf) = '1') then

        status_reg(6) := '1';
        status_reg(5) := '1';

      elsif (mi(MM downto ML) = 0) then

        status_reg(0) := '1';

        if (denorm_input) then
          status_reg(3) := '1';
        end if;

      end if;

    end if;

  end if;


  if (isign = int_isign) then

    maxneg := (others => '0');
    maxneg(isize - 1) := '1';

    maxpos := (others => '1');
    maxpos(isize - 1) := '0';

    if ((af((exp_width + sig_width)) = '1' AND mi(MM downto ML) > maxneg) OR
      (af((exp_width + sig_width)) = '0' AND mi(MM downto ML) > maxpos)) then

      status_reg(6) := '1';
      status_reg(5) := '1';

    end if;

    if (af((exp_width + sig_width)) = '1') then

      if (status_reg(6) = '1' or
          status_reg(2) = '1') then
        z_reg := not (maxneg) + 1;
      elsif (status_reg(0) = '1') then
        z_reg := (others => '0');
      else 
        z_reg := not (mi(MM downto ML)) + 1;
      end if;

    else

      if (status_reg(6) = '1' or
          status_reg(2) = '1') then
        z_reg := maxpos;
      elsif (status_reg(0) = '1') then
        z_reg := (others => '0');
      else 
        z_reg := mi(MM downto ML);
      end if;

    end if;

  end if;

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

configuration DW_fp_flt2i_cfg_sim of DW_fp_flt2i is
 for sim
 end for; -- sim
end DW_fp_flt2i_cfg_sim;
-- pragma translate_on

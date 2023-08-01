
--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2009 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Kyung-Nam Han   Feb. 22, 2005 (Modified by Alex Tenca October 12, 2009)
--
-- VERSION:   VHDL Simulation Model for DW_fp_mult_DG
--
-- DesignWare_version: 37bc3dd9
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
--
-- ABSTRACT: Floating-Point Multiplier with Datapath Gating
--
--              DW_fp_mult_DG calculates the floating-point multiplication
--              while supporting six rounding modes, including four IEEE
--              standard rounding modes. This version supports Datapath gating.
--              When the input DG_ctrl=0, the component has a fixed zero output,
--              and when DG_ctrl=1, the component behaves the same way as 
--              DW_fp_mult
--
--              parameters      valid values (defined in the DW manual)
--              ==========      ============
--              sig_width       significand size,  2 to 253 bits
--              exp_width       exponent size,     3 to 31 bits
--              ieee_compliance support the IEEE Compliance 
--                              including NaN and denormal expressions.
--                              0 - MC (module compiler) compatible
--                              1 - IEEE 754 standard compatible
--
--              Input ports     Size & Description
--              ===========     ==================
--              a               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Input
--              b               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Input
--              rnd             3 bits
--                              Rounding Mode Input
--              DG_ctrl         Datapath gating control
--                              1 bit  (default is value 1)
--              z               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Output
--              status          8 bits
--                              Status Flags Output
--
-------------------------------------------------------------------------------
-- Modified:   AFT 2009 - generated DG component from original component
--             created in 2006.
--
--
-------------------------------------------------------------------------------
--
library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_misc.all;
use ieee.numeric_std.all;
use DWARE.DWpackages.all;

architecture sim of DW_fp_mult_DG is

  -- pragma translate_off


  constant RND_Width          : integer  := 4;
  constant RND_Inc            : integer  := 0;
  constant RND_Inexact        : integer  := 1;
  constant RND_HugeInfinity   : integer  := 2;
  constant RND_TinyminNorm    : integer  := 3;

  constant Mwidth   : integer  := 2 * sig_width + 3;
  constant Movf     : integer  := Mwidth - 1;
  constant ML       : integer  := Movf - 1 - sig_width;
  constant MR       : integer  := ML - 1;

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

  ----------------------------------------------------------------------
  function ez_shift_msb (a: in integer; b: in integer) return integer is

    -- a: exp_width, b: sig_width
    variable z : integer;

    begin

      if (((a = 3) and (b < 8)) or
          ((a = 4) and (b < 16)) or
          ((a = 5) and (b < 32)) or
          ((a = 6) and (b < 64)) or
          ((a = 7) and (b < 128)) or
          (a >= 8)) then
        z := a + 1;
      else
        if ((b >= 8) and (b < 16)) then
          z := 5;
        elsif ((b >= 16) and (b < 32)) then
          z := 6;
        elsif ((b >= 32) and (b < 64)) then
          z := 7;
        elsif ((b >= 64) and (b < 128)) then
          z := 8;
        elsif ((b >= 128) and (b < 256)) then
          z := 9;
        end if;
      end if;

    return z;

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


  MAIN_PROCESS: process (a, b, rnd, DG_ctrl)

  variable ez_msb : integer := ez_shift_msb(exp_width, sig_width);
  variable ez_ea_diff : integer := ez_msb - (exp_width - 1);
  variable ez_ea_tmp : std_logic_vector(ez_ea_diff - 1 downto 0) := (others => '0');
  variable z_reg  : std_logic_vector((exp_width + sig_width) downto 0);
  variable ea     : std_logic_vector(exp_width - 1 downto 0);
  variable eb     : std_logic_vector(exp_width - 1 downto 0);
  variable ez     : std_logic_vector(ez_msb downto 0);
  variable ez_probe1     : std_logic_vector(ez_msb downto 0);
  variable ez_probe2     : std_logic_vector(ez_msb downto 0);
  variable ez_probe3     : std_logic_vector(ez_msb downto 0);
  variable ez_probe4     : std_logic_vector(ez_msb downto 0);
  variable ez_probe5     : std_logic_vector(ez_msb downto 0);
  variable ez_probe6     : std_logic_vector(ez_msb downto 0);
  variable ezcal  : std_logic_vector(ez_msb downto 0);
  variable ma     : std_logic_vector(sig_width downto 0);
  variable mb     : std_logic_vector(sig_width downto 0);
  variable tmp_ma : std_logic_vector(sig_width downto 0);
  variable tmp_mb : std_logic_vector(sig_width downto 0);
  variable siga   : std_logic_vector(sig_width - 1 downto 0);
  variable sigb   : std_logic_vector(sig_width - 1 downto 0);
  variable mz     : std_logic_vector(Mwidth - 1 downto 0);
  variable stk    : std_logic;
  variable sign   : std_logic;
  variable rnd_val: std_logic_vector(RND_Width - 1 downto 0);
  variable status_reg: std_logic_vector(8     - 1 downto 0);
  variable one_vec: std_logic_vector(Mwidth - 1 downto 0);
  variable nan_reg: std_logic_vector((exp_width + sig_width) downto 0);
  variable inf_reg: std_logic_vector((exp_width + sig_width) downto 0);
  variable lz_ina : std_logic_vector(ez_msb downto 0);
  variable lz_inb : std_logic_vector(ez_msb downto 0);
  variable lz_in  : std_logic_vector(ez_msb downto 0);
  variable maxexp_a : std_logic;
  variable maxexp_b : std_logic;
  variable infsig_a : std_logic;
  variable infsig_b : std_logic;
  variable zero_a   : std_logic;
  variable zero_b   : std_logic;
  variable denorm_a : std_logic;
  variable denorm_b : std_logic;
  variable stk_pre  : std_logic;
  variable ez_zero  : std_logic;
  variable ez_bias_equal  : std_logic;
  variable ez_less_bias   : std_logic;
  variable ez_shift    : std_logic_vector(ez_shift_msb(exp_width, sig_width) downto 0);
  variable stk_ext     : std_logic;
  variable mz_stk      : std_logic_vector(Mwidth + sig_width downto 0);
  variable mz_stk2     : std_logic_vector(Mwidth downto 0);
  variable zero_ext    : std_logic_vector(sig_width downto 0);
  variable zero_bit : std_logic;
  variable nan_sig     : std_logic_vector(sig_width - 1 downto 0);
  variable inf_sig     : std_logic_vector(sig_width - 1 downto 0);
  variable mz_movf1    : std_logic;
  variable check_inexact_denormal  : std_logic;
  variable range_check   : std_logic;
  variable minnorm_case   : std_logic;
  variable ez_shift_int  : integer;
  variable i : integer;


  begin

  sign := a((exp_width + sig_width)) xor B((exp_width + sig_width));
  ea := a(((exp_width + sig_width) - 1) downto sig_width);
  eb := b(((exp_width + sig_width) - 1) downto sig_width);
  siga := a((sig_width - 1) downto 0);
  sigb := b((sig_width - 1) downto 0);
  status_reg := (others => '0');
  lz_ina := (others => '0');
  lz_inb := (others => '0');
  lz_in  := (others => '0');
 


  ez := (others => '0');
  mz := (others => '0');
  one_vec := (others => '0');
  one_vec(0) := '1';
  zero_ext := (others => '0');
  zero_bit := '0';
  stk_ext := '0';

  if (ea = ((((2 ** (exp_width-1)) - 1) * 2) + 1)) then
    maxexp_a := '1';
  else 
    maxexp_a := '0';
  end if;

  if (eb = ((((2 ** (exp_width-1)) - 1) * 2) + 1)) then
    maxexp_b := '1';
  else 
    maxexp_b := '0';
  end if;

  if (siga = 0) then
    infsig_a := '1';
  else 
    infsig_a := '0';
  end if;

  if (sigb = 0) then
    infsig_b := '1';
  else 
    infsig_b := '0';
  end if;

  -- Zero and Denormal
  if (ieee_compliance = 1) then
    if ((ea = 0) and (siga = 0)) then
      zero_a := '1';
    else
      zero_a := '0';
    end if; 

    if ((eb = 0) and (sigb = 0)) then
      zero_b := '1';
    else
      zero_b := '0';
    end if; 

    if ((ea = 0) and (siga /= 0)) then
      denorm_a := '1';
    else
      denorm_a := '0';
    end if; 

    if ((eb = 0) and (sigb /= 0)) then
      denorm_b := '1';
    else
      denorm_b := '0';
    end if; 

    if (denorm_a = '1') then
      ma := '0' & siga;
    else
      ma := '1' & siga;
    end if;

    if (denorm_b = '1') then
      mb := '0' & sigb;
    else
      mb := '1' & sigb;
    end if;

    -- IEEE Standard
    nan_sig := (others => '0');
    nan_sig(0) := '1';
    inf_sig := (others => '0');

    nan_reg := (others => '0');
    nan_reg((exp_width + sig_width)) := '0';
    nan_reg(((exp_width + sig_width) - 1) downto sig_width) := (others => '1');
    nan_reg(0) := '1';
    inf_reg := (others => '0');
    inf_reg((exp_width + sig_width)) := sign;
    inf_reg(((exp_width + sig_width) - 1) downto sig_width) := (others => '1');

  else -- ieee_compliance = 0

    if (ea = 0) then
      zero_a := '1';
    else
      zero_a := '0';
    end if;

    if (eb = 0) then
      zero_b := '1';
    else
      zero_b := '0';
    end if;

    denorm_a := '0';
    denorm_b := '0';
    ma := '1' & siga;
    mb := '1' & sigb;

    nan_sig := (others => '0');
    inf_sig := (others => '0');

    -- from 0703-SP2, NaN has always + sign.
    nan_reg := (others => '0');
    nan_reg(((exp_width + sig_width) - 1) downto sig_width) := (others => '1');
    inf_reg := (others => '0');
    inf_reg((exp_width + sig_width)) := sign;
    inf_reg(((exp_width + sig_width) - 1) downto sig_width) := (others => '1');

  end if;

  -- NaN Input
  if ((ieee_compliance = 1) and (((maxexp_a = '1') and (infsig_a = '0')) or ((maxexp_b = '1') and (infsig_b = '0')))) then

    status_reg(2) := '1';
    z_reg := nan_reg;

  -- Infinity Input
  elsif (maxexp_a = '1' or maxexp_b = '1') then

    if (ieee_compliance = 0) then
      status_reg(1) := '1';
    end if;

    -- '0 * Inf' Case
    if (zero_a = '1' or zero_b = '1') then
      status_reg(2) := '1';
      z_reg := nan_reg;
    else
      status_reg(1) := '1';
      z_reg := inf_reg;
    end if;

  -- Zero Input
  elsif (zero_a = '1' or zero_b = '1') then
      status_reg(0) := '1';
      z_reg := (others => '0');
      z_reg((exp_width + sig_width)) := sign;

  -- Normal & Denormal Inputs
  else
    -- Denormal Check
    if (denorm_a = '1') then
      tmp_ma := ma;
      while (tmp_ma(sig_width) /= '1') loop
        tmp_ma := my_sll(tmp_ma, 1);
        lz_ina := lz_ina + 1;
      end loop;
    end if;

    if (denorm_b = '1') then
      tmp_mb := mb;
      while (tmp_mb(sig_width) /= '1') loop
        tmp_mb := my_sll(tmp_mb, 1);
        lz_inb := lz_inb + 1;
      end loop;
    end if;
   
    lz_in := lz_ina + lz_inb;

    ezcal := (ez_ea_tmp & ea) + (ez_ea_tmp & eb) - ((2 ** (exp_width-1)) - 1);
    ez := (ez_ea_tmp & ea) + (ez_ea_tmp & eb) + denorm_a + denorm_b - lz_in;
    ez_probe1 := ez;
    mz := '0' & (ma * mb);

    if (ieee_compliance = 1) then
      mz := my_sll(mz, conv_integer(lz_in));
    end if;

    -- 1b normalization based on the multiplication result
    mz_movf1 := mz(Movf - 1);

    if (mz(Movf - 1) = '1') then
      ez := ez + 1;
      minnorm_case := '0';
    else
      mz := my_sll(mz, 1); 
      if (ez - ((2 ** (exp_width-1)) - 1) = 0) then
        minnorm_case := '1';
      else
        minnorm_case := '0';
      end if;
    end if;

    ez_probe2 := ez;
 
    -- Denormal Support
    if (ieee_compliance = 1) then

      ez_shift_int := ((2 ** (exp_width-1)) - 1) + conv_integer(lz_in) + 1 - (conv_integer(ea) + conv_integer(eb) + conv_integer(denorm_a) + conv_integer(denorm_b) + conv_integer(mz_movf1));

      ez_shift := conv_std_logic_vector(ez_shift_int, ez_shift'length);
      mz_stk2 := mz & zero_bit;

      if ((ea + eb + denorm_a + denorm_b + mz_movf1) < (((2 ** (exp_width-1)) - 1) + lz_in + 1)) then
        range_check := '1';
      else
        range_check := '0';
      end if;

      if ((ez_shift(ez_shift_msb(exp_width, sig_width)) = '0') and (range_check = '1')) then
        for i in 0 to conv_integer(ez_shift) - 1 loop
          mz_stk2 := my_srl(mz_stk2, 1);
          stk_ext := stk_ext or mz_stk2(0);
        end loop;
      end if;

      mz := mz_stk2(Mwidth downto 1);
    end if;

    if ((mz(MR - 1 downto 0) = 0) and (stk_ext = '0')) then
      stk := '0';
    else
      stk := '1';
    end if;

    rnd_val := rnd_eval(rnd, sign, mz(ML), mz(MR), stk);

    -- Round Addition
    if (rnd_val(RND_Inc) = '1') then
      mz := mz + my_sll(one_vec, ML);
    end if;

    -- Post-Normalization after rounding
    if (mz(Movf) = '1') then
      ez := ez + 1;
      mz := my_srl(mz, 1);
    end if;

    ez_probe3 := ez;

    -- Denormal Support
    if (ieee_compliance = 1 and (ez <= ((2 ** (exp_width-1)) - 1)) and mz(Movf - 1) = '1') then
      ez := ez + 1;
    end if;

    if (ez = ((2 ** (exp_width-1)) - 1)) then
      ez_zero := '1';
    else
      ez_zero := '0';
    end if;

    -- Adjust Exponent Bias
    if ((ez >= ((2 ** (exp_width-1)) - 1)) and (ez(ez_msb) = '0')) then
      ez := ez - ((2 ** (exp_width-1)) - 1);
    else
      ez := (others => '0');
    end if;
    ez_probe4 := ez;

    -- Huge Result Case
    if (ez(ez_msb downto 0) >= ((((2 ** (exp_width-1)) - 1) * 2) + 1)) then
      status_reg(4) := '1';
      status_reg(5) := '1';
      
      if (rnd_val(RND_HugeInfinity) = '1') then
        -- Infinity
        mz(Movf - 2 downto ML) := inf_sig;
        ez := conv_std_logic_vector(((((2 ** (exp_width-1)) - 1) * 2) + 1), ez'length);
        status_reg(1) := '1';
      else
        -- MaxNorm
        ez := conv_std_logic_vector(((((2 ** (exp_width-1)) - 1) * 2) + 1) - 1, ez'length);
        mz(Movf - 2 downto ML) := (others => '1');
      end if;

    -- Tiny Result Case
    elsif (ez(ez_msb downto 0) = 0) then
    
      status_reg(3) := '1';

      if (ieee_compliance = 0) then 
        status_reg(5) := '1';

        if (rnd_val(RND_TinyMinNorm) = '1') then
          -- MinNorm
          mz(Movf - 2 downto ML) := (others => '0');
          ez := conv_std_logic_vector(0 + 1, ez'length);
        else
          -- Zero
          mz(Movf - 2 downto ML) := (others => '0');
          ez := conv_std_logic_vector(0, ez'length);
          status_reg(0) := '1';
        end if;
      end if;
      ez_probe5 := ez;

      if ((mz(Movf - 2 downto ML) = 0) and (ez(exp_width - 1 downto 0) = 0)) then
        status_reg(0) := '1';
       end if;

    end if;

    ez_probe6 := ez;

    if (zero_a = '0' and zero_b = '0' and ez(exp_width - 1 downto 0) = 0 and mz(Movf - 2 downto ML) = 0) then
      check_inexact_denormal := '1';
    else
      check_inexact_denormal := '0';
    end if;
    status_reg(5) := status_reg(5) or rnd_val(RND_Inexact) or check_inexact_denormal;

    -- Floating-point format
    z_reg := sign & ez(exp_width - 1 downto 0) & mz(Movf - 2 downto ML);
      
  end if;

  ---------------------------------------------------------
      -- Output Format
  ---------------------------------------------------------

  if (Is_X(a) or Is_X(b) or Is_X(rnd)) then
  
    status <= (others => 'X');
    z <= (others => 'X');
  
  else

    if (DG_ctrl = '1') then
      status <= status_reg;
      z <= z_reg;
    else
      status <= (others => 'X');
      z <= (others => 'X');
    end if;

  end if;


  end process MAIN_PROCESS;

  -- pragma translate_on

end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_fp_mult_DG_cfg_sim of DW_fp_mult_DG is
 for sim
 end for; -- sim
end DW_fp_mult_DG_cfg_sim;
-- pragma translate_on

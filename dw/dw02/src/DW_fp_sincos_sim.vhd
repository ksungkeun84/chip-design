
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
-- AUTHOR:    Kyung-Nam Han   Sep. 25, 2007
--
-- VERSION:   VHDL Simulation Model for DW_fp_sincos
--
-- DesignWare_version: 102c5098
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--
-- ABSTRACT: Floating-Point Sine/Cosine Unit
--
--              DW_fp_sincos calculates the floating-point sine/cosine 
--              function. 
--
--              parameters      valid values (defined in the DW manual)
--              ==========      ============
--              sig_width       significand,  2 to 33 bits
--              exp_width       exponent,     3 to 31 bits
--              ieee_compliance support the IEEE Compliance 
--                              including NaN and denormal expressions.
--                              0 - MC (module compiler) compatible
--                              1 - IEEE 754 standard compatible
--              pi_multiple     angle is multipled by pi
--                              0 - sin(x) or cos(x)
--                              1 - sin(pi * x) or cos(pi * x)
--              arch            implementation select
--                              0 - area optimized (default)
--                              1 - speed optimized
--              err_range       error range of the result compared to the
--                              true result. It is effective only when arch = 0
--                              and 1, and ignored when arch = 2
--                              1 - 1 ulp error (default)
--                              2 - 2 ulp error
--
--              Input ports     Size & Description
--              ===========     ==================
--              a               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Input
--              sin_cos         1 bit
--                              Operator Selector
--                              0 - sine, 1 - cosine
--              z               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Output
--              status          8 bits
--                              Status Flags Output
--
-- MODIFIED: Kyung-Nam Han 07/23/08
--             Added two new parameters, arch and err_range
--           Kyung-Nam Han 06/16/10 (STAR 9000400674, D-2010.03-SP3)
--             Fixes bugs of DW_fp_sincos when sig_width<=9
--           Kyung-Nam Han 08/10/10 (STAR 9000409629, D-2010.03-SP4)
--             Fixed bugs of (sig_width=23, exp_width=4 and ieee_compliance=1)-
--             parameter
--           Kyung-Nam Han 02/10/14 
--             Made arch=2 obsolete. arch=2 will be available with
--             _restore_old_trig macro.
--           Kyung-Nam Han 07/07/15 (STAR 9000921582, K-2015.06-SP1)
--             Fixed bugs with pi_multiple=0, while guaranteeing up to 
--             2 ulp errors.
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_misc.all;
use ieee.numeric_std.all;
library DWARE;
use DWARE.DW_Foundation_comp.all;

architecture sim of DW_fp_sincos is
	

  -- pragma translate_off



  ----------------------------------------------------------------------
  function my_srl (a : in std_logic_vector; sh : in integer) return std_logic_vector is

    variable b : std_logic_vector(a'range) := a;
    variable count : integer := sh;

    begin

      while (count > 0) loop
        b := '0' & b(b'length-1 downto 1);
        --b := b(b'length-1) & b(b'length-1 downto 1);
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
  function arch_dw_value(arch: in integer) return integer is
  begin
    if (arch = 2) then
      return (1);
    else
      return (arch);
    end if;
  end function;
  ----------------------------------------------------------------------
  constant arch_dw: INTEGER := arch;

  function in_margin_value(pi_multiple: in integer) return integer is
  begin
    if (pi_multiple = 1) then
      return (0);
    else
      return (1);
    end if;
  end function;

  function err_range_new_value(pi_multiple: in integer; err_range: in integer) return integer is
  begin
    if (pi_multiple = 1) then
      return (err_range);
    else
      return (1);
    end if;
  end function;

  constant in_margin: INTEGER := in_margin_value(pi_multiple);
  constant sig_width_new: INTEGER := sig_width + rcp_margin_bit;
  constant ma_rcp_pi_width: INTEGER := 2 * sig_width + rcp_margin_bit + 2;
  constant err_range_new: INTEGER := err_range_new_value(pi_multiple, err_range);

  signal SINCOS_IN: std_logic_vector(sig_width + in_margin downto 0);
  signal SINCOS_OUT: std_logic_vector(sig_width + 1 downto 0);
  signal SINCOS_OUT_OLD: std_logic_vector(sig_width + 1 downto 0);
  signal SINCOS_OUT_NEW: std_logic_vector(sig_width + 1 + in_margin downto 0);

  -- pragma translate_on

begin

  -- pragma translate_off

  
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
    assert false 
      report ""
        & lf & "  *************************************************************"
        & lf & "  *                                                           *"
        & lf & "  *  This DesignWare Library Component will not support       *"
        & lf & "  *  the configuration 'arch=2' in the future releases        *"
        & lf & "  *  of the Synopsys DesignWare Library!                      *"
        & lf & "  *                                                           *"
        & lf & "  *  Please consult the datasheet to determine the value of   *"
        & lf & "  *  the parameters 'arch' and 'err_range' that best suite    *"
        & lf & "  *  your application.                                        *"
        & lf & "  *                                                           *"
        & lf & "  *  support@synopsys.com                                     *"
        & lf & "  *                                                           *"
        & lf & "  *************************************************************"
        & lf
      severity warning;
     
    if ( (sig_width < 2) OR (sig_width > 33) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter sig_width (legal range: 2 to 33)"
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
     
    if ( (pi_multiple < 0) OR (pi_multiple > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter pi_multiple (legal range: 0 to 1)"
        severity warning;
    end if;
     
    if ( (arch < 0) OR (arch > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter arch (legal range: 0 to 1)"
        severity warning;
    end if;
     
    if ( (err_range < 1) OR (err_range > 2) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter err_range (legal range: 1 to 2)"
        severity warning;
    end if;
     
    if ( (rcp_margin_bit < 0) OR (rcp_margin_bit > 32) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter rcp_margin_bit (legal range: 0 to 32)"
        severity warning;
    end if;
     
    if ( (round_nearest_pi < 0) OR (round_nearest_pi > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter round_nearest_pi (legal range: 0 to 1)"
        severity warning;
    end if;
  
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;

  -- Instance of DW_fp_sqrt

  U2 : DW_sincos
      generic map (
              A_width => (sig_width + 1 + in_margin),
              wave_width => (sig_width + 2 + in_margin),
              arch => arch_dw,
              err_range => err_range_new
              )
      port map (
              A => SINCOS_IN,
              SIN_COS => sin_cos,
              WAVE => SINCOS_OUT_NEW
              );

  SINCOS_OUT <= SINCOS_OUT_NEW(sig_width + 1 + in_margin downto in_margin);

  MAIN_PROCESS: process (a, sin_cos, SINCOS_OUT)

  variable SIGN          : std_logic;
  variable SIGNOUT       : std_logic;
  variable Denorm_A_bit  : std_logic;
  variable EA            : std_logic_vector(exp_width - 1 downto 0);
  variable SIGA          : std_logic_vector(sig_width - 1 downto 0);
  variable status_reg    : std_logic_vector(8     - 1 downto 0);
  variable z_reg         : std_logic_vector((exp_width + sig_width) downto 0);
  variable NaN_Sig       : std_logic_vector(sig_width - 1 downto 0);
  variable Inf_Sig       : std_logic_vector(sig_width - 1 downto 0);
  variable NaN_Reg       : std_logic_vector((exp_width + sig_width) downto 0);
  variable Inf_Reg       : std_logic_vector((exp_width + sig_width) downto 0);
  variable exp_max       : std_logic_vector(exp_width - 1 downto 0);
  variable MA            : std_logic_vector(sig_width downto 0);
  variable MA_PI         : std_logic_vector(sig_width + in_margin downto 0);
  variable MA_IN         : std_logic_vector(sig_width + in_margin downto 0);
  variable LZ_INA        : std_logic_vector(exp_width + 1 downto 0);
  variable EZ            : std_logic_vector(exp_width + 1 downto 0);
  variable EZ_all_zero   : std_logic_vector(exp_width + 1 downto 0);
  variable EZ_Bias       : std_logic_vector(exp_width + 1 downto 0);
  variable EM            : std_logic_vector(exp_width + 1 downto 0);
  variable EM_PI         : std_logic_vector(exp_width + 1 downto 0);
  variable EM_Neg        : std_logic_vector(exp_width + 1 downto 0);
  variable zero_exp      : std_logic_vector(exp_width + 1 downto 0);
  variable zero_expsig   : std_logic_vector(exp_width + sig_width - 1 downto 0);
  variable MA_RCP_PI     : std_logic_vector(ma_rcp_pi_width - 1 downto 0);
  variable NORM_IN       : std_logic_vector(sig_width downto 0);
  variable NORM_IN_PRE   : std_logic_vector(sig_width downto 0);
  variable SINCOS_OUT_r  : std_logic_vector(sig_width + 1 downto 0);
  variable recip_pi_value: std_logic_vector(98 downto 0);
  variable recip_pi      : std_logic_vector(sig_width + rcp_margin_bit downto 0);

  variable MAX_EXP_A     : BOOLEAN;
  variable InfSig_A      : BOOLEAN;
  variable Zero_A        : BOOLEAN;
  variable Denorm_A      : BOOLEAN;
  variable NegInput      : BOOLEAN;
  variable SignNeg       : BOOLEAN;
 
  begin

  SIGN := a(sig_width + exp_width);
  EA := a(((exp_width + sig_width) - 1) downto sig_width);
  SIGA := a((sig_width - 1) downto 0);
  status_reg := (others => '0');
  MAX_EXP_A := (EA = ((((2 ** (exp_width-1)) - 1) * 2) + 1));
  InfSig_A := (SIGA = 0);
  exp_max := (others => '1');
  LZ_INA := (others => '0');
  zero_exp := (others => '0');
  zero_expsig := (others => '0');
  EZ_Bias := (others => '1');
  EZ_Bias(exp_width + 1 downto exp_width - 1) := B"000";
  NORM_IN := (others => '0');
  EZ_all_zero := (others => '0');

  recip_pi_value := "101000101111100110000011011011100100111001000100000101010010100111111100001001110101011111010001111";
  recip_pi := recip_pi_value(98 downto 98 - sig_width - rcp_margin_bit);
    
  -- Zero and Denormal
  if (ieee_compliance = 1) then
    Zero_A := (EA = 0) and (SIGA = 0);
    Denorm_A := (EA = 0) and (SIGA /= 0);

    NaN_Sig := (others => '0');
    NaN_Sig(0) := '1';
    Inf_Sig := (others => '0');
    NaN_Reg := '0' & exp_max & NaN_Sig;
    Inf_Reg := SIGN & exp_max & Inf_Sig;

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
    Inf_Reg := SIGN & exp_max & Inf_Sig;
  end if;

  if (MAX_EXP_A) then

    status_reg(2) := '1';
    z_reg := NaN_Reg;

  elsif (Zero_A) then
    
    if (sin_cos = '0') then
      status_reg(0) := '1';
      z_reg := a((exp_width + sig_width)) & zero_expsig;
    else
      z_reg := (others => '0');
      z_reg(sig_width + exp_width - 2 downto sig_width) := (others => '1');
    end if;

  -- Normal & Denormal Operation
  else

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

    -- 1/pi multiplication
    MA_RCP_PI := MA * recip_pi;

    if (MA_RCP_PI(ma_rcp_pi_width - 1) = '1') then
      EM_PI := EM + 1;
    else
      MA_RCP_PI := my_sll(MA_RCP_PI, 1);
      EM_PI := EM;
    end if;

    if (pi_multiple = 0) then
      EM := EM_PI - 2;
    end if;

    EM_Neg := 0 - EM;

    --if (EM(exp_width - 1) = '0') then
    if (EM(exp_width + 1) = '0') then
      MA_RCP_PI := my_sll(MA_RCP_PI, conv_integer(EM));
      MA := my_sll(MA, conv_integer(EM));
    else
      MA_RCP_PI := my_srl(MA_RCP_PI, conv_integer(EM_Neg));
      MA := my_srl(MA, conv_integer(EM_Neg));
    end if;

    if (round_nearest_pi = 1) then
      MA_PI := MA_RCP_PI(ma_rcp_pi_width - 1 downto ma_rcp_pi_width - (sig_width + 1 + in_margin)) + MA_RCP_PI(ma_rcp_pi_width - (sig_width + 1 + in_margin) - 1);
    else
      MA_PI := MA_RCP_PI(ma_rcp_pi_width - 1 downto ma_rcp_pi_width - (sig_width + 1 + in_margin));
    end if;

    if (pi_multiple = 1) then
      MA_IN := MA;
    else
      MA_IN := MA_PI;
    end if;

    SINCOS_IN <= MA_IN;
      
    if (sin_cos = '1') then
      SIGNOUT := SINCOS_OUT(sig_width + 1);
    else
      SIGNOUT := SINCOS_OUT(sig_width + 1) xor SIGN;
    end if;

    if (SINCOS_OUT(sig_width + 1) = '1') then
      NORM_IN := not(SINCOS_OUT(sig_width downto 0)) + 1;
    else
      NORM_IN := SINCOS_OUT(sig_width downto 0);
    end if;

    NORM_IN_PRE := NORM_IN;

    -- Normalization
    EZ := EZ_Bias;

    if (NORM_IN(sig_width downto 1) = 0) then
      EZ := (others => '0');
      status_reg(0) := '1';
      NORM_IN := (others => '0');
    else 
      while (NORM_IN(sig_width) = '0') loop
        EZ := EZ - 1;
        NORM_IN := my_sll(NORM_IN, 1);
      end loop;
    end if;

    if (sig_width > ((2 ** (exp_width-1)) - 1)) then
      if (ieee_compliance = 1) then
        if (EZ(exp_width + 1) = '1' or EZ = EZ_all_zero) then
          EZ := (others => '0');
          NORM_IN := my_sll(NORM_IN_PRE, ((2 ** (exp_width-1)) - 1) - 1);
        end if;
      else -- ieee_compliance == 0
        if (EZ(exp_width + 1) = '1' or EZ = EZ_all_zero) then
          EZ := (others => '0');
          NORM_IN := (others => '0');
        end if;
      end if;
    end if;
      
    -- Tiny
    if (EZ = 0) then
      status_reg(3) := '1';

      if (ieee_compliance = 0) then
        NORM_IN := (others => '0');
        status_reg(0) := '1';
      end if;

    end if;

    status_reg(5) := '1';
  

    -- Reconstruct the FP number
    z_reg := SIGNOUT & EZ(exp_width - 1 downto 0) & NORM_IN(sig_width - 1 downto 0);

  end if;

  ---------------------------------------------------------
      -- Output Format
  ---------------------------------------------------------

  if (Is_X(a) or Is_X(sin_cos)) then
  
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

library dw02;

configuration DW_fp_sincos_cfg_sim of DW_fp_sincos is
 for sim
  for U2 : DW_sincos use configuration dw02.DW_sincos_cfg_sim; end for;
 end for; -- sim
end DW_fp_sincos_cfg_sim;
-- pragma translate_on

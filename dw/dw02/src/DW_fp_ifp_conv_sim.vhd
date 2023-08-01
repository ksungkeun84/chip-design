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
-- AUTHOR:    Alexandre F. Tenca - December 2007
--
-- VERSION:   VHDL Simulation Model - FP to IFP converter
--
-- DesignWare_version: ff5c16a8
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--
-- ABSTRACT: Floating-point format to internal format converter
--              parameters      valid values (defined in the DW manual)
--              ==========      ============
--              sig_widthi      significand size,  2 to 253 bits
--              exp_widthi      exponent size,     3 to 31 bits
--              sig_widtho      significand size,  sig_widthi+1 to 253 bits
--              exp_widtho      exponent size,     exp_widthi to 31 bits
--              use_denormal    0 or 1  (default 0)
--              use_1scmpl      0 or 1  (default 0)
--
--              Input ports     Size & Description
--              ===========     ==================
--              a               (sig_widthi + exp_widthi + 1)-bits
--                              Floating-point Number Input
--
--              Output ports    Size & Description
--              ===========     ==================
--              z               (sig_widtho + exp_widtho + 7) bits
--                              Internal Floating-point Number
--
-- MODIFIED: 
--          11/2008 - include the processing of denormals and NaNs when use_denormal=1
--------------------------------------------------------------------------------
library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_misc.all;
use DWARE.DW_Foundation_arith.all;

architecture sim of DW_fp_ifp_conv is
	
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
    
    if ( (sig_widtho < sig_widthi+2) OR (sig_widtho > 253) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter sig_widtho (legal range: sig_widthi+2 to 253)"
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

  MAIN: process (a)
  variable O01OIO01 : std_logic;
  variable OlOOO0O1 : std_logic_vector (exp_widthi-1 downto 0);
  variable II0l1OO1 : std_logic_vector (sig_widthi downto 0);
  variable O0I1lOlI : std_logic_vector (sig_widthi-1 downto 0);
  variable l0OIl0Ol : std_logic_vector (sig_widthi-1 downto 0);
  variable I0l0OO10 : std_logic_vector (exp_widthi-1 downto 0);
  variable l1IOO011 : std_logic_vector (exp_widthi-1 downto 0);
  variable OlIIOOl1 : std_logic_vector(exp_widthi-1 downto 0);
  variable OO01001O: std_logic_vector (7-1 downto 0);
  variable OI00O001: std_logic_vector (sig_widthi+1 downto 0);
  variable OO10lO1O: std_logic_vector (sig_widtho-1 downto 0);
  variable Il0000O1 : std_logic_vector (sig_widtho+exp_widtho+7-1 downto 0);  
  variable O0OOIO1l : std_logic_vector (exp_widtho-1 downto 0);
  variable I1O01O10 : std_logic_vector (sig_widtho-1 downto 0);
  variable OOI00lIl : std_logic_vector (sig_widtho-1 downto 0);
  begin                                 -- process MAIN

  -- initialize some variables
  OlIIOOl1 := (others => '1');
  l0OIl0Ol := (others => '0');
  I0l0OO10 := (others => '0');
  l1IOO011 := (others => '0');
  l1IOO011(0) := '1';
  OlOOO0O1 := a(sig_widthi+exp_widthi-1 downto sig_widthi);
  O0I1lOlI := a(sig_widthi-1 downto 0);
  O01OIO01 := a(sig_widthi+exp_widthi);
  OO01001O := (others => '0');
  OO01001O(5     ) := O01OIO01;

  -- test the cases of zero and infinity  
  if (use_denormal = 0) then
  if (OlOOO0O1 = I0l0OO10) then
    OO01001O(0) := '1';
    OlOOO0O1 := I0l0OO10;
    II0l1OO1 := (others => '0');
  elsif (OlOOO0O1 = OlIIOOl1) then
    OO01001O(1) := '1';
    OlOOO0O1 := I0l0OO10;
    II0l1OO1 := (others => '0');
  else
    II0l1OO1 := '1' & O0I1lOlI;
  end if;
  -- code introduced to handle denormal and NaNs as inputs.
  else
  if (OlOOO0O1 = I0l0OO10 and O0I1lOlI = 0) then
    OO01001O(0) := '1';
    OlOOO0O1 := I0l0OO10;
    II0l1OO1 := (others => '0');
  elsif (OlOOO0O1 = OlIIOOl1 and O0I1lOlI = 0) then
    OO01001O(1) := '1';
    OlOOO0O1 := I0l0OO10;
    II0l1OO1 := (others => '0');
  elsif (OlOOO0O1 = I0l0OO10 and O0I1lOlI /= 0) then
    OlOOO0O1 := l1IOO011;
    II0l1OO1 := '0' & O0I1lOlI;
  elsif (OlOOO0O1 = OlIIOOl1 and O0I1lOlI /= 0) then
    OO01001O(2) := '1';
    OlOOO0O1 := I0l0OO10;
    II0l1OO1 := (others => '0');
  else
    II0l1OO1 := '1' & O0I1lOlI;
  end if;
  end if;

  -- Convert input mantissa to a signed value
  -- Extend the mantissa 
  OI00O001 := ('0'&II0l1OO1);
  if (sig_widtho > (sig_widthi+2)) then
    OOI00lIl := OI00O001 & conv_std_logic_vector(0,sig_widtho-sig_widthi-2);
  else
    OOI00lIl := OI00O001;
  end if;

  -- Convert input mantissa to one's or 2's complement form
  -- depending on parameter
  if (O01OIO01 = '1' and not (OO01001O(0) = '1' or
                          OO01001O(1) = '1')) then
    if (use_1scmpl = 1) then
      OO10lO1O := not OOI00lIl;
      OO01001O(4     ) := '1';
    else
      OO10lO1O := conv_std_logic_vector(unsigned(not OOI00lIl) + 1,OO10lO1O'length);
      OO01001O(4     ) := '0';
    end if;
  elsif (OO01001O(0) = '1' or
         OO01001O(1) = '1') then
      OO10lO1O := (others => '0');
  else
    OO10lO1O := OOI00lIl;
  end if;
  I1O01O10 := OO10lO1O;

  -- Adjust the exponent
  if (exp_widtho > exp_widthi) then
    O0OOIO1l := conv_std_logic_vector(0,exp_widtho-exp_widthi) & OlOOO0O1;
  else
    O0OOIO1l := OlOOO0O1;
  end if;  

  -- build the output value
  Il0000O1 := OO01001O & O0OOIO1l & std_logic_vector(I1O01O10);
  
  if (Is_X(a)) then
    z <= (others => 'X');
  else
    z <= Il0000O1;
  end if;

  end process MAIN;

-- pragma translate_on  
end sim ;

--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_fp_ifp_conv_cfg_sim of DW_fp_ifp_conv is
 for sim
 end for; -- sim
end DW_fp_ifp_conv_cfg_sim;
-- pragma translate_on

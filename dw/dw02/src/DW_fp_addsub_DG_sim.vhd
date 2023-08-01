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
-- AUTHOR:    Alexandre F. Tenca - August 2009
--
-- VERSION:   VHDL Simulation Model - FP Add/sub with Datapath gating
--
-- DesignWare_version: 86318b68
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--
-- ABSTRACT: Floating-point two-operand Adder/Subtractor with Datapath gating
--           This component is in fact an extension of the floating point adder
--           that allows isolation of signals when the DG_ctrl input is set to 0.
--           When this input is set to 1, the component works the same way as the
--           DW_fp_addsub previously released. The input DG_ctrl = 0 is used to 
--           reduce power consumption when the input is not meaningfull. 
--           For more description about the FP addsub, please, refer to the 
--           documentation and files of DW_fp_addsub.
--              parameters      valid values (defined in the DW manual)
--              ==========      ============
--              sig_width       significand size,  2 to 253 bits
--              exp_width       exponent size,     3 to 31 bits
--              ieee_compliance 0 or 1  (default 0)
--
--              Input ports     Size & Description
--              ===========     ==================
--              a               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Input
--              b               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Input
--              rnd             3 bits
--                              rounding mode
--              op              1 bit
--                              add/sub control: 0 for add - 1 for sub
--              DG_ctrl          1 bit
--                              dapath gating control: 0 - isolate
--
--              Output ports    Size & Description
--              ===========     ==================
--              z               (sig_width + exp_width + 1) bits
--                              Floating-point Number result
--              status          byte
--                              info about FP results
--
--        
-- MODIFIED: 
---------------------------------------------------------------------------------

library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_misc.all;
use DWARE.DW_Foundation_arith.all;

architecture sim of DW_fp_addsub_DG is
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

-- purpose: main process for the behavioral description of the FP add/sub
-- type   : combinational
-- inputs : a, b, rnd, op
-- outputs: status_int and z_temp
MAIN_PROCESS: process (a, b, rnd, op, DG_ctrl)
variable status_int : std_logic_vector(8    -1 downto 0);
variable z_temp : std_logic_vector((exp_width + sig_width) downto 0);
variable Large : std_logic_vector((exp_width + sig_width) downto 0);
variable Small : std_logic_vector((exp_width + sig_width) downto 0);
variable swap, subtract, STK : std_logic;
variable E_a,E_b :  std_logic_vector(exp_width-1 downto 0); -- Exponents.
variable E_Large,E_Small,E_Diff :  std_logic_vector(exp_width-1 downto 0);
variable F_a,F_b :  std_logic_vector(sig_width-1 downto 0);         -- fraction bits
variable F_Large,F_Small :  std_logic_vector(sig_width-1 downto 0); -- of mantissa
variable zero_E : std_logic_vector(exp_width-1 downto 0) := (others => '0');
variable min_E : std_logic_vector(exp_width-1 downto 0) := (others => '0');
variable zero_F : std_logic_vector(sig_width-1 downto 0) := (others => '0');
variable infExp_vec : std_logic_vector(exp_width-1 downto 0);
-- The biggest possible exponent for addition/subtraction
variable E_Comp : std_logic_vector(exp_width+1 downto 0);
variable M_Large,M_Small :  std_logic_vector(((sig_width + 3 + 3        ) - 2) downto 0); -- The Mantissa numbers.
variable M_Z :  std_logic_vector(((sig_width + 3 + 3        ) - 2) downto 0); -- The Mantissa numbers.
variable zero_M : std_logic_vector(((sig_width + 3 + 3        ) - 2) downto 0) := (others => '0');
 -- Contains values returned by RND_eval function.
variable RND_val : std_logic_vector(4-1 downto 0);
-- special FP values
variable NANfp : std_logic_vector((exp_width + sig_width + 1)-1 downto 0);  -- Not-a-number
variable b_int : std_logic_vector((exp_width + sig_width + 1)-1 downto 0);  -- internal value of b
-- indication of denormals for Large or Small value
variable Denormal_Large : std_logic;
variable Denormal_Small : std_logic;
variable small_zero_vec : std_logic_vector((3 - 1) downto 0);
begin  -- process MAIN_PROCESS

  small_zero_vec := (others => '0');
  -- setup some of special variables...
  InfExp_vec := conv_std_logic_vector(((((2 ** (exp_width-1)) - 1) * 2) + 1), InfExp_vec'length);
  min_E := zero_E + 1;
  NANfp := '0' & InfExp_vec & zero_F;
  NANfp(0) := '1';  -- mantissa is 1 when number is NAN
  status_int := (others => '0');
  -- extract exponent and significand from inputs
  E_a := a(((exp_width + sig_width) - 1) downto sig_width);
  E_b := b(((exp_width + sig_width) - 1) downto sig_width);
  F_a := a((sig_width - 1) downto 0);
  F_b := b((sig_width - 1) downto 0);
  -- correct sign of second input when subtraction is used
  b_int := b;
  if (op = '1') then 
    -- invert the sign of input b
    b_int((exp_width + sig_width)) := not b((exp_width + sig_width));    
  end if;
  subtract := a((exp_width + sig_width)) xor b_int((exp_width + sig_width));
  -- compute the signal that defines the large and small FP value
  swap := '0';
  if (a(((exp_width + sig_width) - 1) downto 0) < b_int(((exp_width + sig_width) - 1) downto 0)) then
    swap := '1';
  end if;
  if (swap = '1') then
    Large := b_int;
    Small := a;
    else
    Large := a;
    Small := b_int;
  end if;       
  E_Large := Large(((exp_width + sig_width) - 1) downto sig_width);
  E_Small := Small(((exp_width + sig_width) - 1) downto sig_width);
  F_Large := Large((sig_width - 1) downto 0);
  F_Small := Small((sig_width - 1) downto 0);

  --
  -- NAN input
  --
  if ((E_a = InfExp_vec) and (F_a /= zero_F) and (ieee_compliance = 1)) then
    -- one of the inputs is a NAN       --> the output must be an NAN
    -- CPU behavior (sun, i686)    z_temp := a;
    -- IEEE ref model              z_temp := NANfp;
    z_temp := NANfp;
    status_int(2) := '1';
  elsif ((E_b = InfExp_vec) and (F_b /= zero_F) and (ieee_compliance = 1)) then
    -- one of the inputs is a NAN       --> the output must be an NAN
    -- CPU behavior (sun, i686)    z_temp := b;
    -- IEEE ref model              z_temp := NANfp;
    z_temp := NANfp;
    status_int(2) := '1';
  --
  -- Infinity Input
  --
  elsif ((E_Large = InfExp_vec) and ((F_Large = zero_F) or (ieee_compliance = 0))) then 
    status_int(1) := '1';
    z_temp := Large;
    -- Set the fraction to 0
    z_temp((sig_width - 1) downto 0) := (others => '0');
    -- Watch out for Inf-Inf !
    if ( (E_Small = InfExp_vec) and ((F_Small = zero_F) or (ieee_compliance = 0)) 
         and (subtract = '1') ) then
      status_int(2) := '1';
      if (ieee_compliance = 1) then
        status_int(1) := '0';
        z_temp := NANfp;                  -- NaN
      else
        z_temp((exp_width + sig_width)) := '0';   -- use positive infinity to represent NaN
      end if;
    end if;
  --
  -- Zero Input (or denormal input when ieee_compliance = 0)
  --
  elsif ((E_Small = zero_E) and ((ieee_compliance = 0) or (F_Small = zero_F))) then -- Zero input 
    z_temp := Large;
    -- watch out for 0-0 !
    if ((E_Large = zero_E) and ((ieee_compliance = 0) or (F_Large = zero_F))) then
      status_int(0) := '1';
      z_temp := (others => '0');
      if (subtract='1') then
        if (rnd = "011") then
          z_temp((exp_width + sig_width)) := '1';
        else
          z_temp((exp_width + sig_width)) := '0';
        end if;
      else
        z_temp((exp_width + sig_width)) := a((exp_width + sig_width));  
      end if;
    end if;
  --
  -- Normal Inputs
  --
  else                                          
    -- Detect the denormal input case
    if ((E_large = zero_E) and (F_Large /= zero_F)) then
      -- M_Large contains the Mantissa of denormal value
      M_Large := "00" & F_Large & "000";
      Denormal_Large := '1';
    else
      -- M_Large is the Mantissa for Large number
      M_Large := "01" & F_Large & "000";
      Denormal_Large := '0';      
    end if;
    if ((E_small = zero_E) and (F_Small /= zero_F)) then
      -- M_Small contains the Mantissa of denormal value
      M_Small := "00" & F_Small & "000";
      Denormal_Small := '1';
    else
      -- M_Small is the Mantissa for Small number
      M_Small := "01" & F_Small & "000";
      Denormal_Small := '0';
    end if;

    -- Shift right by E_Diff the Small number: M_Small.
    -- When one of the inputs is a denormal, we need to
    -- compensate because the exponent for a denormal is
    -- actually 1, and not 0.
    STK := '0';
    if ((Denormal_Large xor Denormal_Small) = '1') then
      E_Diff := E_Large - E_Small - 1;
    else
      E_Diff := E_Large - E_Small;
    end if;
    while ( (M_Small /= zero_M) and (E_Diff /= zero_E) ) loop
      STK := M_Small(0) or STK;
      M_Small := '0' & M_Small(M_Small'length-1 downto 1);
      E_Diff := E_Diff - 1;
    end loop;
    M_Small(0) := M_Small(0) or STK;

    -- Compute M_Z result: a +/- b
    if (subtract = '0') then
      M_Z := M_Large + M_Small;
    else
      M_Z := M_Large - M_Small;
    end if;
    -- Post Processing.
    E_Comp := "00" & E_Large;
    --
    -- Exact 0 special case after the computation.
    --
    if (M_Z = zero_M) then
      status_int(0) := '1';
      z_temp := (others => '0');
      -- If rounding mode is -Infinity, the sign bit is 1; otherwise the
      -- sign bit is zero
      if (rnd = "011") then
        z_temp((exp_width + sig_width)) := '1';
      end if;
    --
    -- Normal case after the computation.
    --
    else     -- Normal computation case 
      -- Normalize the Mantissa for computation overflow case.
      if (M_Z(((sig_width + 3 + 3        ) - 2)) = '1') then
        E_Comp := E_Comp + 1;
        STK := M_Z(0);
        M_Z := '0' & M_Z(M_Z'length-1 downto 1);
        M_Z(0) := M_Z(0) or STK;
      end if;
      -- Normalize the Mantissa for leading zero case.
      while ( (M_Z(((sig_width + 3 + 3        ) - 2)-1) = '0') and (E_Comp > min_E) ) loop
        E_Comp := E_Comp - 1;
        M_Z := M_Z(M_Z'length-2 downto 0) & '0';
      end loop;

      -- test if the output of the normalization unit is still not normalized
      -- if this is the case, the number became a denormal value (Tiny)
      if (M_Z(((sig_width + 3 + 3        ) - 2) downto ((sig_width + 3 + 3        ) - 2)-1) = "00") then
        -- result is tiny
        if (ieee_compliance = 1) then
          z_temp := Large((exp_width + sig_width)) & zero_E & M_Z(((sig_width + 3 + 3        ) - 2)-2 downto 3);
          status_int(3) := '0';
          if ((STK = '1') or (M_Z((3 - 1) downto 0) /= small_zero_vec)) then
            status_int(5) := '1';
          end if;
          if (M_Z(((sig_width + 3 + 3        ) - 2)-2 downto 3) = zero_F) then
            status_int(0) := '1'; 
          end if;
        else
          if ((rnd = "011" and Large((exp_width + sig_width)) = '1') or
              (rnd = "010" and Large((exp_width + sig_width)) = '0') or
              rnd = "101") then
            z_temp := Large((exp_width + sig_width)) & min_E & zero_F;
            status_int(0) := '0';
          else
            z_temp := Large((exp_width + sig_width)) & zero_E & zero_F;
            status_int(0) := '1';
          end if;
          status_int(3) := '1';
          status_int(5) := '1';
        end if;
      else
        -- Round M_Z according to the rounding mode (rnd).
        RND_val := RND_eval(rnd, Large((exp_width + sig_width)), M_Z(3), M_Z((3 - 1)),(or_reduce(M_Z(1 downto 0))));

        if (RND_val(0) = '1') then
          M_Z := M_Z + 2**3;
          status_int(5) := '0';
        end if;   

        -- Normalize the Mantissa for overflow case after rounding.
        if ( (M_Z(((sig_width + 3 + 3        ) - 2)) = '1') ) then
          E_Comp := E_Comp + 1;
          M_Z := '0' & M_Z(M_Z'length-1 downto 1);
        end if;
        --
        -- Huge
        --
        if (E_Comp >= conv_std_logic_vector(((((2 ** (exp_width-1)) - 1) * 2) + 1),E_Comp'length)) then
          status_int(4) := '1';
          status_int(5) := '1';
          if (RND_val(2) = '1') then
            -- Infinity
            M_Z(((sig_width + 3 + 3        ) - 2)-2 downto 3) := (others => '0');
            E_Comp := conv_std_logic_vector(((((2 ** (exp_width-1)) - 1) * 2) + 1),E_Comp'length);
            status_int(1) := '1';
          else
            -- MaxNorm
            E_Comp := conv_std_logic_vector(((((2 ** (exp_width-1)) - 1) * 2) + 1),E_Comp'length) - 1;
            M_Z(((sig_width + 3 + 3        ) - 2)-2 downto 3) := (others => '1');
          end if;
        --
        -- Tiny 
        --
        else
          if (E_Comp <= conv_std_logic_vector(0,E_Comp'length)) then
            -- when it comes to this point the value was a denormal that
            -- got to a normal range
            E_Comp := conv_std_logic_vector(0,E_Comp'length) + 1;
          end if;
        end if;
        --
        -- Normal
        --
        status_int(5) := status_int(5) or RND_val(1);
        -- Reconstruct the floating point format.
        z_temp := Large((exp_width + sig_width)) & E_Comp(exp_width-1 downto 0) & M_Z(((sig_width + 3 + 3        ) - 2)-2 downto 3);

      end if;  -- (M_Z(((sig_width + 3 + 3        ) - 2) downto ((sig_width + 3 + 3        ) - 2)-1) = "00")
      
    end if; --  if (M_Z = zero_M) then

  end if;  -- NaN input 

  if (Is_X(a) or Is_X(b) or Is_X(rnd)) then
    status <= (others => 'X');
    z <= (others => 'X');
  else
    if (DG_ctrl = '1') then
      status <= status_int;
      z <= z_temp;
    else 
      status <= (others => 'X');
      z <= (others => 'X');
    end if;
  end if;
  
end process MAIN_PROCESS;

-- pragma translate_on  

end sim ;

--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_fp_addsub_DG_cfg_sim of DW_fp_addsub_DG is
 for sim
 end for; -- sim
end DW_fp_addsub_DG_cfg_sim;
-- pragma translate_on

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
-- VERSION:   VHDL Simulation Model - IFP to FP converter
--
-- DesignWare_version: 46dbf65b
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--
-- ABSTRACT: Floating-point internal format to IEEE format converter
--              parameters      valid values (defined in the DW manual)
--              ==========      ============
--              sig_widthi      significand size,  2 to 253 bits
--              exp_widthi      exponent size,     3 to 31 bits
--              sig_width       significand size,  2 to 253 bits
--              exp_width       exponent size,     3 to 31 bits
--              use_denormal    0 or 1  (default 0)
--
--              Input ports     Size & Description
--              ===========     ==================
--              a               (sig_widthi + exp_widthi + 7)-bits
--                              Internal Floating-point Number Input
--              rnd             3 bits
--                              Rounding mode
--
--              Output ports    Size & Description
--              ===========     ==================
--              z               (sig_width + exp_width + 1) bits
--                              IEEE Floating-point Number
--              status          8 bits
--                              Status information about FP number
--
--           Important, although the IFP has a bit for 1's complement 
--           representation, this converter does not process this bit. 
--
-- MODIFIED: 11/2008 - included the manipulation of denormals and NaNs
--           04/2012 - modified the size of the internal extended mantissa
--                     variable, and fixed the rounding method. Was using
--                     2**x, and this operation is limited to 32 bits.
--                     
--------------------------------------------------------------------------------
library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_misc.all;
use DWARE.DW_Foundation_arith.all;

architecture sim of DW_ifp_fp_conv is
	
-- pragma translate_off



-- O1I1O111 function used in several FP components
function O1I1O111 (lllOI11l: std_logic_vector(2 downto 0);
                   OOIOOI1l: std_logic;
                   IOl0I1O0: std_logic;
                   OO11OI10: std_logic;
                   lO0IO0OO: std_logic) return std_logic_vector is
--*******************************
--  l1O0l10l has 4 bits:
--  l1O0l10l[0]
--  l1O0l10l[1]
--  l1O0l10l[2]
--  l1O0l10l[3]
--*******************************

--*******************************
--  Rounding increment equations
--  |
--    MODE | Equation   | Description
--    -----------------------------
--    even | OO11OI10&(IOl0I1O0|lO0IO0OO)  | IEEE round to nearest (even)
--    zero | 0          | IEEE round to zero
--    +inf | S'&(OO11OI10|lO0IO0OO) | IEEE round to positive infinity
--    -inf | S&(OO11OI10|lO0IO0OO)  | IEEE round to negative infinity
--     up  | OO11OI10          | round to nearest (up)
--    away | (OO11OI10|lO0IO0OO)    | round away from zero
-- *******************************
variable O1I1O111 : std_logic_vector (4-1 downto 0);
begin
  O1I1O111(0) := '0';
  O1I1O111(1) := OO11OI10 or lO0IO0OO;
  O1I1O111(2) := '0';
  O1I1O111(3) := '0';
  case lllOI11l is
    when "000" =>
      -- round to nearest (even) 
      O1I1O111(0) := OO11OI10 and (IOl0I1O0 or lO0IO0OO);
      O1I1O111(2) := '1';
      O1I1O111(3) := '0';
    when "001" =>
      -- round to zero 
      O1I1O111(0) := '0';
      O1I1O111(2) := '0';
      O1I1O111(3) := '0';
    when "010" =>
      -- round to positive infinity 
      O1I1O111(0) := not OOIOOI1l and (OO11OI10 or lO0IO0OO);
      O1I1O111(2) := not OOIOOI1l;
      O1I1O111(3) := not OOIOOI1l;
    when "011" =>
      -- round to negative infinity 
      O1I1O111(0) := OOIOOI1l and (OO11OI10 or lO0IO0OO);
      O1I1O111(2) := OOIOOI1l;
      O1I1O111(3) := OOIOOI1l;
    when "100" =>
      -- round to nearest (up)
      O1I1O111(0) := OO11OI10;
      O1I1O111(2) := '1';
      O1I1O111(3) := '0';
    when "101" =>
      -- round away form 0  
      O1I1O111(0) := OO11OI10 or lO0IO0OO;
      O1I1O111(2) := '1';
      O1I1O111(3) := '1';
    when others =>
      O1I1O111(0) := 'X';
      O1I1O111(2) := 'X';
      O1I1O111(3) := 'X';
  end case;
  return (O1I1O111);
end function;                                    -- l1O0l10l function

-------------------------------------------------------------------------------
-- 
  -- return the maximum value of two arguments
  function max(a, b : INTEGER) return INTEGER is
  begin
    if ( a > b ) then
        return (a);
      else
        return (b);
    end if;
  end max;

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
    
    if ( (sig_width < 2) OR (sig_width > sig_widthi) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter sig_width (legal range: 2 to sig_widthi)"
        severity warning;
    end if;
    
    if ( (exp_width < 3) OR (exp_width > exp_widthi) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter exp_width (legal range: 3 to exp_widthi)"
        severity warning;
    end if;
    
    if ( (use_denormal < 0) OR (use_denormal > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter use_denormal (legal range: 0 to 1)"
        severity warning;
    end if;
    
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;  

MAIN: process (a,rnd)
  constant O01IO00I : integer := sig_widthi+sig_width;
  variable IlOI0OlI : std_logic;
  variable IOl1I00O : std_logic_vector (exp_widthi-1 downto 0);
  variable O0OlO000 : std_logic_vector (exp_widthi+2 downto 0);
  variable I1I11l00 : signed (sig_widthi downto 0);
  variable O0l10lOl : signed (sig_widthi downto 0);
  variable OIO11I0l : std_logic_vector (sig_width-1 downto 0);
  variable Ol0IO000 : std_logic_vector (sig_width-1 downto 0);
  variable llIlOOOI : std_logic_vector (exp_width-1 downto 0);
  variable OOO1I1O0 : std_logic_vector(exp_width-1 downto 0);
  variable lI11O100: std_logic_vector (7-1 downto 0);
  variable OO1IO111: std_logic_vector (7 downto 0);
  variable lI00OO0O : std_logic_vector (sig_width+exp_width downto 0);  
  variable lOIO0l11 : std_logic_vector(sig_widthi downto 0);
  variable O00OO01I : std_logic_vector(O01IO00I downto 0);
  variable lO0IO0OO : std_logic;
  variable l1010I10 : std_logic_vector(exp_width-1 downto 0);
  variable l1O0l10l : std_logic_vector(4-1 downto 0);
  begin                                 -- process MAIN
  -- variable initialization
  OIO11I0l := (others => '0');
  Ol0IO000 := (others => '0');
  Ol0IO000(0) := '1';
  llIlOOOI := (others => '0');
  OOO1I1O0 := (others => '1');
  OO1IO111 := (others => '0');
  l1010I10 := conv_std_logic_vector(1,l1010I10'length);
  lOIO0l11 := (others => '0');
  O00OO01I := (others => '0');
  lI00OO0O := (others => '0');

  -- Pass the status bits to the status output
  OO1IO111 := (others => '0');
  lI11O100 := a(sig_widthi+exp_widthi+7-1 downto sig_widthi+exp_widthi);
  OO1IO111(2 downto 0) := lI11O100(2 downto 0); -- invalid/inf/zero flags
  OO1IO111(5) := lI11O100(3);

  IOl1I00O := a(sig_widthi+exp_widthi-1 downto sig_widthi);
  IlOI0OlI := a(sig_widthi-1);
  I1I11l00 := signed(a(sig_widthi-1 downto 0) & lI11O100(3));
  if (IlOI0OlI = '1') then
    O0l10lOl := -I1I11l00;
  else
    O0l10lOl := I1I11l00;
  end if;
  O0l10lOl(0) := '0';  
    
  if (conv_integer(OO1IO111(2 downto 0)) /= 0) then
    if (OO1IO111(0) = '1' and OO1IO111(2) = '0') then
      if (OO1IO111(5) = '1') then
        -- result is tiny
        if ((rnd = "011" and lI11O100(5     ) = '1') or
            (rnd = "010" and lI11O100(5     ) = '0') or
             rnd = "101") then
          if (use_denormal = 0) then
            lI00OO0O := lI11O100(5     ) & l1010I10 & OIO11I0l;
            OO1IO111(3) := '0';
          else
            lI00OO0O := lI11O100(5     ) & llIlOOOI & Ol0IO000;
            OO1IO111(3) := '1';
          end if;
          OO1IO111(0) := '0';
        else
          lI00OO0O := lI11O100(5     ) & llIlOOOI & OIO11I0l;
          OO1IO111(0) := '1';
          OO1IO111(3) := '1';
        end if;
      else
        lI00OO0O := lI11O100(5     ) & llIlOOOI & OIO11I0l;
      end if;
    end if;
    if (OO1IO111(1) = '1' and OO1IO111(2) = '0') then
      lI00OO0O := lI11O100(5     ) & OOO1I1O0 & OIO11I0l;
      OO1IO111(0) := '0';
      OO1IO111(1) := '1';
    end if;
    if (OO1IO111(2) = '1') then
      OO1IO111 := (others => '0');
      if (use_denormal = 0) then
        lI00OO0O := '0' & OOO1I1O0 & OIO11I0l;
        OO1IO111(1) := '1';
        OO1IO111(2) := '1';
      else
        lI00OO0O := '0' & OOO1I1O0 & Ol0IO000;
        OO1IO111 := (others => '0');
        OO1IO111(2) := '1';
      end if;
    end if;
  else
      lO0IO0OO := OO1IO111(5);
      if (or_reduce(std_logic_vector(O0l10lOl)) = '0') then
        O0OlO000 := (others => '0');
      else
        O0OlO000 := conv_std_logic_vector(unsigned(IOl1I00O),O0OlO000'length);
      end if;
      if (or_reduce(std_logic_vector(O0l10lOl)) = '0' and IlOI0OlI = '0') then
        IlOI0OlI := lI11O100(5     );
      end if;
      lOIO0l11 := std_logic_vector(O0l10lOl);
      if (lOIO0l11(lOIO0l11'left) = '1' or O0OlO000 < l1010I10) then
          lOIO0l11 := '0' & lOIO0l11(lOIO0l11'left downto 1);
          O0OlO000 := O0OlO000 + 1;
      end if;
      while ( (lOIO0l11(lOIO0l11'left downto lOIO0l11'left-1) = "00") and (O0OlO000 > l1010I10) ) loop
        O0OlO000 := O0OlO000 - 1;
        lOIO0l11 := lOIO0l11(lOIO0l11'length-2 downto 0) & '0';
      end loop;

      -- Extend the mantissa if needed.
       if (O00OO01I'left > lOIO0l11'left) then
          O00OO01I := lOIO0l11 &
                     conv_std_logic_vector(0,O00OO01I'left-lOIO0l11'left);
        else
          O00OO01I := std_logic_vector(lOIO0l11);
        end if;
      -- Round lOIO0l11 according to the rounding mode (rnd).
        lO0IO0OO := or_reduce(std_logic_vector(O00OO01I(O00OO01I'left-sig_width-1-1-1 downto 0))) or lO0IO0OO;
        l1O0l10l := O1I1O111(rnd, IlOI0OlI, O00OO01I(O00OO01I'left-sig_width-1), O00OO01I(O00OO01I'left-sig_width-1-1),lO0IO0OO);

        if (l1O0l10l(0) = '1') then
          O00OO01I := O00OO01I + ('1' & conv_std_logic_vector(0,O00OO01I'left-sig_width-1));
        end if;   

      -- Normalize the Mantissa for overflow case after rounding.
        if ( (O00OO01I(O00OO01I'left) = '1') ) then
          O0OlO000 := O0OlO000 + 1;
          O00OO01I := '0' & O00OO01I(O00OO01I'length-1 downto 1);
        end if;

      if (((O0OlO000 < l1010I10) and 
           ((lO0IO0OO = '1') or (or_reduce(std_logic_vector(lOIO0l11)) /= '0'))) or
          ((O0OlO000 = l1010I10) and 
	   (or_reduce(O00OO01I(O00OO01I'left downto O00OO01I'left-1)) = '0') and
           ((lO0IO0OO = '1') or (or_reduce(std_logic_vector(lOIO0l11)) /= '0')))) 
	then
        -- result is tiny
        if ((use_denormal = 1) and
            (conv_integer(O00OO01I(O00OO01I'left-2 downto O00OO01I'left-sig_width-1)) /= 0)) then
          lI00OO0O := IlOI0OlI & llIlOOOI & O00OO01I(O00OO01I'left-2 downto O00OO01I'left-sig_width-1);
          OO1IO111(3) := '1';
          if ((lO0IO0OO = '1') or (conv_integer(O00OO01I(O00OO01I'left-sig_width-1-1 downto 0)) /= 0)) then
            OO1IO111(5) := '1';
          end if;
          if (conv_integer(O00OO01I(O00OO01I'left-2 downto O00OO01I'left-sig_width-1)) = 0) then
            OO1IO111(0) := '1'; 
          end if;
        else
          -- value is zero of minimal non-zero representable FP,
          -- when denormal is not used --> becomes zero or minFP
          -- when denormal is used --> becomes zero or mindenorm
    	  if ((rnd = "011" and IlOI0OlI = '1') or
             (rnd = "010" and IlOI0OlI = '0') or
              rnd = "101") then
            if (use_denormal = 0) then
              lI00OO0O := IlOI0OlI & l1010I10 & OIO11I0l;
              OO1IO111(3) := '0';
            else
              lI00OO0O := IlOI0OlI & llIlOOOI & Ol0IO000;
              OO1IO111(3) := '1';
             end if;
            OO1IO111(0) := '0';
          else
            lI00OO0O := IlOI0OlI & llIlOOOI & OIO11I0l;
            OO1IO111(0) := '1';
            OO1IO111(3) := '1';
          end if;
          OO1IO111(5) := '1';
        end if;
      else
        if (or_reduce(std_logic_vector(lOIO0l11)) = '0') then
          O0OlO000 := (others => '0');
          OO1IO111(0) := '1';
          O00OO01I := (others => '0');
        end if;
        --
        -- Huge
        --
        if (O0OlO000 >= conv_std_logic_vector(((((2 ** (exp_width-1)) - 1) * 2) + 1),O0OlO000'length)) then
          OO1IO111(4) := '1';
          OO1IO111(5) := '1';
          if (l1O0l10l(2) = '1') then
            -- Infinity
            O00OO01I(O00OO01I'left downto O00OO01I'left-sig_width-1) := (others => '0');
            O0OlO000 := conv_std_logic_vector(((((2 ** (exp_width-1)) - 1) * 2) + 1),O0OlO000'length);
            OO1IO111(1) := '1';
          else
            -- MaxNorm
            O0OlO000 := conv_std_logic_vector(((((2 ** (exp_width-1)) - 1) * 2) + 1),O0OlO000'length) - 1;
            O00OO01I(O00OO01I'left downto O00OO01I'left-sig_width-1) := (others => '1');
          end if;
        end if;
        --
        -- Normal
        --
        OO1IO111(5) := OO1IO111(5) or l1O0l10l(1);
        -- Reconstruct the floating point format.
        lI00OO0O := IlOI0OlI & O0OlO000(exp_width-1 downto 0) & std_logic_vector(O00OO01I(O00OO01I'left-2 downto O00OO01I'left-sig_width-1));
      end if;
  end if;

  if (Is_X(a) or Is_X(rnd)) then
    status <= (others => 'X');
    z <= (others => 'X');
  else
    status <= OO1IO111;
    z <= lI00OO0O;
  end if;

end process;

-- pragma translate_on  
end sim ;

--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_ifp_fp_conv_cfg_sim of DW_ifp_fp_conv is
 for sim
 end for; -- sim
end DW_ifp_fp_conv_cfg_sim;
-- pragma translate_on

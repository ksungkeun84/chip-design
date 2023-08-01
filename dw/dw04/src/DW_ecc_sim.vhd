--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2002 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Rick Kelly                        July 1, 2002
--
-- VERSION:   VHDL Simulation Model
--
-- DesignWare_version: ea793223
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT: Error Detection & Correction
--
--    Generics:
--           width       - data size (4 <= "width" <= 8178)
--           chkbits     - number of checkbits (5 <= "chkbits" <= 14)
--           synd_sel    - controls checkbit correction vs syndrome
--                           emission selection when gen input is not
--                           active (0 => correct check bits
--                           1 => pass syndrome to chkout)
--
--    Ports:
--           gen         - generate versus check mode control input
--                           (1 => generate check bits from datain
--                           0 => check validity of check bits on chkin
--                           with respect to data on datain and indicate
--                           the presence of errors on err_detect & err_multpl)
--           correct_n   - control signal indicating whether or not to correct
--           datain      - input data
--           chkin       - input check bits
--           err_detect  - flag indicating occurance of error
--           err_multpl  - flag indicating multibit (i.e. uncorrectable) error
--           dataout     - output data
--           chkout      - output check bits
--
-- MODIFIED:
--
--  RJK 12/21/2016  Relaxed lower bound on width parameter (STAR 9001134170)
--
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
 
architecture sim of DW_ecc is
	

-- pragma translate_off

type IO1Il001I is array (0 to (2**chkbits)-1) of INTEGER;
SIGNAL O11lIl10l : IO1Il001I;

subtype l00O0Il10 is std_logic_vector(width-1 downto 0);
type OO0O11I00 is array (0 to chkbits-1) of l00O0Il10;
CONSTANT O1Il0l0O1 : std_logic_vector(chkbits-1 downto 0)
				:= (others => '0');
SIGNAL l0O000lO0 : OO0O11I00;
SIGNAL IO0l0O111 : std_logic_vector(chkbits-1 downto 0);
SIGNAL O1Il0O1O0 : std_logic_vector(chkbits-1 downto 0);
SIGNAL lOI0l1lOO : std_logic_vector(width-1 downto 0);
SIGNAL OOOI110O0  : std_logic_vector(chkbits-1 downto 0);
SIGNAL lIO0OlOlO : std_logic;
SIGNAL O00O0OO01 : std_logic;
SIGNAL IOl01OOlI : INTEGER;


  function l0IOO110I(OOOO1OIO1: INTEGER) return INTEGER is
    variable l0I0O1llO: INTEGER;
  begin
    if (OOOO1OIO1 mod 2) = 0 then
      l0I0O1llO := OOOO1OIO1 + 1;
    else
      l0I0O1llO := OOOO1OIO1 - 1;
    end if;
    return l0I0O1llO;
  end l0IOO110I;


  function l0O0O1lI0(OOOO1OIO1: INTEGER) return INTEGER is
    variable l0I0O1llO: INTEGER;
    variable II1000l0l: INTEGER;
  begin
    l0I0O1llO := 0;
    II1000l0l := OOOO1OIO1;
    while (II1000l0l /= 0) loop
      if (II1000l0l mod 2) = 1 then
	l0I0O1llO := l0IOO110I(l0I0O1llO);
      end if;
      II1000l0l := II1000l0l / 2;
    end loop;
    return l0I0O1llO;
  end l0O0O1lI0;


  function IIIlIIO01(OOOO1OIO1: std_logic_vector; OO0101O01: INTEGER) return INTEGER is
    variable l0I0O1llO: INTEGER;
  begin
    l0I0O1llO := 0;
    for Ol01lIIO0 in OO0101O01-1 downto 0 loop
      l0I0O1llO := l0I0O1llO * 2;
      if (OOOO1OIO1(Ol01lIIO0) = '1') then
	l0I0O1llO := l0I0O1llO + 1;
      end if;
    end loop;
    return l0I0O1llO;
  end IIIlIIO01;


  function III110100( I00O00lI1, Ol01lIIO0 : in INTEGER ) return INTEGER is
    variable lOO01llO0 : INTEGER;
  begin
    if (I00O00lI1 > 0) then
      if (Ol01lIIO0 < 1) OR (Ol01lIIO0 > 5) then lOO01llO0 := 1;
      else lOO01llO0 := 0;
      end if;
    else
      if (Ol01lIIO0 < 1) then lOO01llO0 := 5;
      else
	if (Ol01lIIO0 < 3) then lOO01llO0 := 1;
	else lOO01llO0 := 0;
	end if;
      end if;
    end if;
    return lOO01llO0;
  end III110100;


  function O01OI111I( l1100110O : in INTEGER ) return INTEGER is
    variable II1000l0l : INTEGER;
    variable OIOO0I0lI : INTEGER;
  begin
    II1000l0l := l1100110O;
    OIOO0I0lI := 0;

    while (II1000l0l /= 0) loop
      if (II1000l0l mod 2 = 1) then
	OIOO0I0lI := OIOO0I0lI + 1;
      end if;

      II1000l0l := II1000l0l / 2;
    end loop;

    return OIOO0I0lI;
  end O01OI111I;


-- pragma translate_on

begin

-- pragma translate_off

  O1l01lO0I : process
    variable OOOlO0111 : INTEGER;
    variable Ol01lIIO0 : INTEGER;
    variable l101OO11I : INTEGER;
    variable OIl0OOIO0 : INTEGER;
    variable I00I0OOO0 : INTEGER;
    variable IOOlO1O00 : INTEGER;
    variable IOO0O11Il : INTEGER;
    variable I1OOIO10O : INTEGER;
    variable O1l10l1l0 : INTEGER;
    variable llO01l0l0 : INTEGER;
    variable O00101l00 : INTEGER;
    variable III1I0O00 : INTEGER;
    variable IIO1Il0ll : INTEGER;
    variable lO1IOO000 : INTEGER;
    variable I1O1l100l : INTEGER;
    variable O1IO0I01l : INTEGER;
    variable lOI1O1lOO : INTEGER;
    variable O0IO010O1 : INTEGER;
    variable llI1OI000 : INTEGER;
    variable O1l1lO0OO : INTEGER;
    variable l0110lO01 : INTEGER;
    variable O00100101 : INTEGER;
    variable OOlO0O0lO : INTEGER;
    variable l1Ol11100 : std_logic_vector(width-1 downto 0);
    type OI1II11lO is array (0 to (2**(chkbits-1))-1) of INTEGER;
    variable I0OOI1lO0 : OI1II11lO;
    variable llOO0l1lO : IO1Il001I := (others => -1);
  begin
    
    lOI1O1lOO := 3;
    I1OOIO10O := 2;
    llI1OI000 := I1OOIO10O ** chkbits;
    lOI1O1lOO := lOI1O1lOO + I1OOIO10O;
    OOOlO0111 := 1;
    l0110lO01 := llI1OI000 / (I1OOIO10O ** lOI1O1lOO);
    O00101l00 := 2 ** (I1OOIO10O+OOOlO0111+I1OOIO10O);

    O00100101 := l0110lO01 * I1OOIO10O;
    IOOlO1O00 := 0;
    O1l1lO0OO := lOI1O1lOO + llOO0l1lO(0);
    llO01l0l0 := O00101l00 + llOO0l1lO(1);
    I1O1l100l := 0;

    while (IOOlO1O00 < width) AND (I1O1l100l < O00100101) loop
      l101OO11I := I1O1l100l / I1OOIO10O;

      if ((I1O1l100l < 4) OR ((I1O1l100l > 8) AND (I1O1l100l >= (O00100101-4)))) then
	l101OO11I := l0IOO110I(l101OO11I);
      end if;

      if (l0O0O1lI0(I1O1l100l) = 0) then
	l101OO11I := l0110lO01-OOOlO0111-l101OO11I;
      end if;

      if (l0110lO01 = OOOlO0111) then
	l101OO11I := 0;
      end if;

      IOO0O11Il := 0;
      O1IO0I01l := l101OO11I * (I1OOIO10O ** lOI1O1lOO);

      if (I1O1l100l < l0110lO01) then
	IIO1Il0ll := 0;
	if (l0110lO01 > OOOlO0111) then
	  IIO1Il0ll := I1O1l100l mod 2;
	end if;

	O1l10l1l0 := III110100(IIO1Il0ll,0);

	O0IO010O1 := O1IO0I01l;
	while (O0IO010O1 < (O1IO0I01l+O00101l00)) AND (IOOlO1O00 < width) loop
	  lO1IOO000 := O01OI111I(O0IO010O1);
	  if (lO1IOO000 mod 2 = 1) then
	    if (O1l10l1l0 <= 0) then
	      if (lO1IOO000 > 1) then
		if (IOO0O11Il < 2) AND (IIO1Il0ll = 0) then
		  llOO0l1lO(O0IO010O1) := l0IOO110I(IOOlO1O00);
		  I0OOI1lO0(l0IOO110I(IOOlO1O00)) := O0IO010O1;
		else
		  llOO0l1lO(O0IO010O1) := IOOlO1O00;
		  I0OOI1lO0(IOOlO1O00) := O0IO010O1;
		end if;
		IOOlO1O00 := IOOlO1O00+1;
	      end if;

	      IOO0O11Il := IOO0O11Il + 1;

	      if (IOO0O11Il < 8) then
		O1l10l1l0 := III110100(IIO1Il0ll,IOO0O11Il);
	      else
		O0IO010O1 := O1IO0I01l+O00101l00;
	      end if;
	    else
	      
	      O1l10l1l0 := O1l10l1l0 - 1;
	    end if;
	  end if;
	  O0IO010O1 := O0IO010O1 + 1;
	end loop;

      else

        O0IO010O1 := O1IO0I01l+llO01l0l0;
        while (O0IO010O1 <= (O1IO0I01l+llO01l0l0) AND (O0IO010O1 >= O1IO0I01l) AND (IOOlO1O00 < width)) loop
	  lO1IOO000 := O01OI111I(O0IO010O1);

	  if (lO1IOO000 mod 2) = 1 then
	    if (lO1IOO000 > 1) AND (llOO0l1lO(O0IO010O1) < 0) then
	      llOO0l1lO(O0IO010O1) := IOOlO1O00;
	      I0OOI1lO0(IOOlO1O00) := O0IO010O1;
	      IOOlO1O00 := IOOlO1O00 + 1;
	    end if;
	  end if;
          O0IO010O1 := O0IO010O1 - 1;
	end loop;
      end if;

      I1O1l100l := I1O1l100l + 1;
    end loop;

    III1I0O00 := OOOlO0111 - 1;

    for O0IO010O1 in 0 to chkbits-1 loop
      OOlO0O0lO := 2 ** O0IO010O1;
      l1Ol11100 := (others => '0');
      for IOOlO1O00 in 0 to width-1 loop
	if ((I0OOI1lO0(IOOlO1O00)/OOlO0O0lO) mod 2) /= 0 then
	  l1Ol11100(IOOlO1O00) := '1';
	end if;
      end loop; -- IOOlO1O00
      l0O000lO0(O0IO010O1) <= l1Ol11100;
    end loop; -- O0IO010O1

    IOl01OOlI <= III1I0O00 - 1;

    for O0IO010O1 in 0 to chkbits-1 loop
      llOO0l1lO(I1OOIO10O**O0IO010O1) := width+O0IO010O1;
    end loop; -- O0IO010O1

    O11lIl10l <= llOO0l1lO;

    wait;
  end process O1l01lO0I;


  I1ll11lO0 : process(datain)
   variable lO00000Il : std_logic;
   variable O110O1Il0 : std_logic_vector(width-1 downto 0); begin
    if (Is_X(datain)) then
      IO0l0O111 <= (others => 'X');
    else
      for i in 0 to chkbits-1 loop
        lO00000Il := '0';
        O110O1Il0 := l0O000lO0(i) AND datain;
        for j in 0 to width-1 loop
	  if O110O1Il0(j)='1' then
	    lO00000Il := NOT lO00000Il;
	  end if;
        end loop;

        if (i=2) or (i=3) then
          IO0l0O111(i) <= NOT lO00000Il;
        else
          IO0l0O111(i) <= lO00000Il;
        end if;
      end loop;
    end if;
  end process I1ll11lO0;


  O1Il0O1O0 <= IO0l0O111 XOR chkin;

  OO01IlO1O : process(O1Il0O1O0, gen)
    variable IO11O1IIO : INTEGER;
  begin
    if (To_X01(gen) = '0') then 
      if (Is_X(O1Il0O1O0)) then
	OOOI110O0 <= (others => 'X');
	lOI0l1lOO <= (others => 'X');
	lIO0OlOlO <= 'X';
	O00O0OO01 <= 'X';
      else
	OOOI110O0 <= (others => '0');
	lOI0l1lOO <= (others => '0');
	if (O1Il0O1O0 = O1Il0l0O1) then
	  lIO0OlOlO <= '0';
	  O00O0OO01 <= '0';
	else
	  IO11O1IIO := O11lIl10l(IIIlIIO01(O1Il0O1O0,chkbits));
	  if (IO11O1IIO = IOl01OOlI) then
	    lIO0OlOlO <= '1';
	    O00O0OO01 <= '1';
	  else
	    lIO0OlOlO <= '1';
	    O00O0OO01 <= '0';
	    if (IO11O1IIO < width) then
	      lOI0l1lOO(IO11O1IIO) <= '1';
	    else
	      OOOI110O0(IO11O1IIO-width) <= '1';
	    end if;
	  end if;
	end if;
      end if;
    elsif (To_X01(gen) /= '1') then
      OOOI110O0 <= (others => 'X');
      lOI0l1lOO <= (others => 'X');
      lIO0OlOlO <= 'X';
      O00O0OO01 <= 'X';
    end if;
  end process OO01IlO1O;

   err_detect <= '0' WHEN (gen = '1') ELSE lIO0OlOlO WHEN (gen = '0') ELSE 'X';
   err_multpl <= '0' WHEN (gen = '1') ELSE O00O0OO01 WHEN (gen = '0') ELSE 'X';

   chkout <= IO0l0O111 WHEN (gen = '1') ELSE
             O1Il0O1O0 WHEN ((gen = '0') AND (synd_sel = 1)) ELSE
	     To_X01(chkin) WHEN ((gen = '0') AND (correct_n = '1')) ELSE
	     chkin XOR OOOI110O0 WHEN ((gen = '0') AND (correct_n = '0')) ELSE
	     (others => 'X');

   dataout <= To_X01(datain) WHEN ((gen = '1') OR (correct_n = '1')) ELSE
              datain XOR lOI0l1lOO WHEN ((gen = '0') AND (correct_n = '0')) ELSE
	      (others => 'X');

  
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
    
    if ( (width < 4) OR (width > 8178) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter width (legal range: 4 to 8178)"
        severity warning;
    end if;
    
    if ( (chkbits < 5) OR (chkbits > 14) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter chkbits (legal range: 5 to 14)"
        severity warning;
    end if;
    
    if ( (synd_sel < 0) OR (synd_sel > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter synd_sel (legal range: 0 to 1)"
        severity warning;
    end if;
    
    if ( width > ((2**(chkbits-1))-chkbits) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid parameter combination (chkbits value too low for specified width)"
        severity warning;
    end if;
  
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check; 

-- pragma translate_on

end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_ecc_cfg_sim of DW_ecc is
 for sim
 end for; -- sim
end DW_ecc_cfg_sim;
-- pragma translate_on

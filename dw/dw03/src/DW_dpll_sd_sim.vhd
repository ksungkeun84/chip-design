--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2000 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Rick Kelly      June 15, 2000
--
-- VERSION:   VHDL Simulation Model for DW_dpll_sd
--
-- DesignWare_version: 1da09cf0
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
library IEEE, DWARE;
use IEEE.std_logic_1164.all;

use IEEE.std_logic_arith.all;
use DWARE.DWpackages.all;

architecture sim of DW_dpll_sd is
	

    constant OOOlIO0l : INTEGER := bit_width(divisor);
    constant O011IOI1  : INTEGER := bit_width(windows);
    
    --
    constant OIl1OI0l : INTEGER := (windows/2)+1;
    constant IIIO11OO : INTEGER := (windows+1)/2;
    
    --
    constant I11I11IO : INTEGER := 0;
    constant lOlll1Ol : INTEGER := (divisor-1)/2;
    constant OlOIOI1I : INTEGER := divisor-1;
    constant llIOOl1O : INTEGER := -99999999;
    
    constant llll0l1O : INTEGER := 2;
    
    signal l1l1000I, OI0OO110, llI1lIOI : std_logic;
    signal O000IIII, Il0IIl0I, IlOlIOlO, IIlIOI1I : std_logic;
    signal Ol1OOlOO, IOl0l1IO : std_logic;
    signal O01Il01I, lO1OIIOI : std_logic;
    signal Il00OI1O, l1l1II1O : std_logic_vector(OIl1OI0l*width-1 downto 0);
    signal O11lOIlI, lI101II1 : std_logic_vector(IIIO11OO*width-1 downto 0);
    signal IO0l1IIl : std_logic_vector(width-1 downto 0);
    signal lIl11101 : std_logic_vector(width-1 downto 0);
    signal O0IOl10I, I0l0000O, IIIlOlOl : std_logic_vector(width-1 downto 0);
    
    signal lO1OOl01 : INTEGER := llIOOl1O;
    signal lI00OOll : INTEGER := llIOOl1O;
    signal II0lOI10 : INTEGER := llIOOl1O;
    signal lII0llI1 : INTEGER := llIOOl1O;
    signal I0IIOIIl, OI01Il1I : INTEGER := 0;
    signal I0IOIO1I : INTEGER := llll0l1O;
    
begin

-- pragma translate_off
    
    clk_out <= OI0OO110;
    bit_ready <= l1l1000I;
    data_out <= IO0l1IIl;
    
    Il0IIl0I <= (NOT squelch) AND (l1l1II1O(0) XOR (lI101II1(0)));
    
    IOl0l1IO <= Ol1OOlOO when (O000IIII = '0') else
				'1' when ((II0lOI10=(lOlll1Ol+1)) OR (II0lOI10=(lOlll1Ol-1))) else
				'0';


    -- 

    process(Il00OI1O, IIIlOlOl) begin
	
	l1l1II1O(OIl1OI0l*width-1 downto (OIl1OI0l-1)*width) <= IIIlOlOl;
	
	for O0O001I1 in 0 to (OIl1OI0l-1)*width-1 loop
	    l1l1II1O(O0O001I1) <= Il00OI1O(O0O001I1+width);
	end loop;
    end process;
    

    -- 

    process(Il00OI1O, O11lOIlI) begin
	
	lI101II1(width-1 downto 0) <= Il00OI1O(width-1 downto 0);
	
	if (IIIO11OO > 1) then
	    for O0O001I1 in 0 to (IIIO11OO-1)*width-1 loop
		lI101II1(O0O001I1+width) <= O11lOIlI(O0O001I1);
	    end loop;
	end if;
    end process;
    
    
    -- 

    O01Il01I <= 'X' WHEN (II0lOI10 < I11I11IO) else
    			    (NOT O000IIII) WHEN (II0lOI10 = OlOIOI1I) else '0';
    
    
    -- 

    llI1lIOI <= '1' WHEN (lII0llI1 > lOlll1Ol) else '0';
    
    
    OI01Il1I <= conv_integer(unsigned(window));
    
    I0IIOIIl <= OI01Il1I WHEN (OI01Il1I < windows) else windows-1;
    
    lIl11101 <= IO0l1IIl WHEN (O01Il01I = '0') else
			    O11lOIlI((1+I0IIOIIl/2)*width-1 downto (I0IIOIIl/2)*width)
				WHEN (I0IIOIIl mod 2 /= 0) else
			    Il00OI1O((1+I0IIOIIl/2)*width-1 downto (I0IIOIIl/2)*width);
    
    
    IIlIOI1I <= IlOlIOlO WHEN (O000IIII = '0') else OI0OO110;
    
    lO1OIIOI <= NOT((OI0OO110 XOR IlOlIOlO) AND Ol1OOlOO);
    
    
    -- 

    IOIOlOlO : process (II0lOI10, O000IIII, lO1OOl01, lO1OIIOI) begin
    
	if (O000IIII = '0') then
		
	    if (II0lOI10 = OlOIOI1I) then
		lII0llI1 <= I11I11IO;
	    else
		lII0llI1 <=  II0lOI10 + 1;
	    
	    end if;
	    
 	else
	    
	    if ((II0lOI10/=(lOlll1Ol+1)) AND (II0lOI10/=(lOlll1Ol-1))) then
		
		if ((gain=1) AND (II0lOI10/=lOlll1Ol)) then
		    if (II0lOI10 > lOlll1Ol) then
			lII0llI1 <= II0lOI10 - ((II0lOI10-lOlll1Ol+1)/I0IOIO1I) + 1;
		    else
			lII0llI1 <= II0lOI10 + ((lOlll1Ol-II0lOI10)/I0IOIO1I) + 1;
		    end if;
		else
		    lII0llI1 <= lOlll1Ol + 1;
		end if;
		
	    else
		
		if (filter > 1) then
		    
		    if ((lO1OOl01=0) AND (lO1OIIOI='1')) then
			lII0llI1 <= lOlll1Ol + 1;
		    else
			lII0llI1 <= II0lOI10 + 1;
		    end if;
		    
		else
		
		    if (filter = 1) then
			lII0llI1 <= lOlll1Ol + 1;
		    else
			lII0llI1 <= II0lOI10 + 1;
		    end if;
		    
		end if;
	    end if;
	end if;

    end process IOIOlOlO;

    
    
    IlllOIII : process (O000IIII, lO1OOl01, II0lOI10, lO1OIIOI) begin

	if (filter>1) then
	
	    if (((II0lOI10=(lOlll1Ol+1))OR(II0lOI10=(lOlll1Ol-1))) AND (O000IIII='1')) then
	
		if ((lO1OIIOI='1') AND (lO1OOl01>0)) then
		    lI00OOll <= lO1OOl01 - 1;
		else
		
		    if ((lO1OIIOI='1') AND (lO1OOl01=0)) then
			lI00OOll <= filter - 1;
		    else
			lI00OOll <= filter - 2;
		    end if;
			
		end if;
	
	    else
	
		if (O000IIII='1') then
		    lI00OOll <= filter-1;
		else
		    lI00OOll <= lO1OOl01;
		end if;
	    
	    end if;
	
	else
	
	    lI00OOll <= 0;
	
	end if;
	
    end process IlllOIII;
    
    
    
    l1lOOOOO : process (clk, rst_n) begin
    
	if (rst_n = '0') then
	
	    O0IOl10I <= (others => '0');
	    I0l0000O <= (others => '0');
	    IIIlOlOl <= (others => '0');
	    O000IIII <= '0';
	    l1l1000I <= '0';
	    IO0l1IIl <= (others => '0');
	    IlOlIOlO <= '0';
	    Ol1OOlOO <= '0';
	    Il00OI1O <= (others => '0');
	    O11lOIlI <= (others => '0');
	    II0lOI10 <= lOlll1Ol;
	    lO1OOl01 <= filter-1;
	    OI0OO110 <= '0';
	
	else
	    
	    if (rst_n = '1') then
		
		if (clk'event AND clk = '1') then
		
		    O0IOl10I <= data_in;
		    I0l0000O <= O0IOl10I;
		    IIIlOlOl <= I0l0000O;

		    if (stall = '0') then
		
			O000IIII <= Il0IIl0I;
			l1l1000I <= O01Il01I;
			IO0l1IIl <= lIl11101;
			IlOlIOlO <= IIlIOI1I;
			Ol1OOlOO <= IOl0l1IO;
			O11lOIlI <= lI101II1;
			Il00OI1O <= l1l1II1O;
			II0lOI10 <= lII0llI1;
			lO1OOl01 <= lI00OOll;
			OI0OO110 <= llI1lIOI;
		
		    else
		
			if (stall = '1') then
		    
			    O000IIII <= O000IIII;
			    l1l1000I <= l1l1000I;
			    IO0l1IIl <= IO0l1IIl;
			    IlOlIOlO <= IlOlIOlO;
			    Ol1OOlOO <= Ol1OOlOO;
			    O11lOIlI <= O11lOIlI;
			    Il00OI1O <= Il00OI1O;
			    II0lOI10 <= II0lOI10;
			    lO1OOl01 <= lO1OOl01;
			    OI0OO110 <= OI0OO110;
		    
			else
		    
			    O000IIII <= 'X';
			    l1l1000I <= 'X';
			    IO0l1IIl <= (others => 'X');
			    IlOlIOlO <= 'X';
			    Ol1OOlOO <= 'X';
			    Il00OI1O <= (others => 'X');
			    O11lOIlI <= (others => 'X');
			    II0lOI10 <= llIOOl1O;
			    lO1OOl01 <= llIOOl1O;
			    OI0OO110 <= 'X';
		    
			end if;
		
		    end if;
		
		end if;
	
	    else
		
		O0IOl10I <= (others => 'X');
		I0l0000O <= (others => 'X');
		IIIlOlOl <= (others => 'X');
		O000IIII <= 'X';
		l1l1000I <= 'X';
		IO0l1IIl <= (others => 'X');
		IlOlIOlO <= 'X';
		Ol1OOlOO <= 'X';
		Il00OI1O <= (others => 'X');
		O11lOIlI <= (others => 'X');
		II0lOI10 <= llIOOl1O;
		lO1OOl01 <= llIOOl1O;
		OI0OO110 <= 'X';
	
	    end if;
	    
	end if;
	
    end process l1lOOOOO;
   
   
    
    
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
	
    if ( (width < 1) OR (width > 16 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter width (legal range: 1 to 16 )"
        severity warning;
    end if;
	
    if ( (divisor < 4) OR (divisor > 256 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter divisor (legal range: 4 to 256 )"
        severity warning;
    end if;
	
    if ( (gain < 1) OR (gain > 2 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter gain (legal range: 1 to 2 )"
        severity warning;
    end if;
	
    if ( (filter < 0) OR (filter > 8 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter filter (legal range: 0 to 8 )"
        severity warning;
    end if;
	
    if ( (windows < 1) OR (windows > (divisor+1)/2 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter windows (legal range: 1 to (divisor+1)/2 )"
        severity warning;
    end if;
    
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;
    
    
    
    
  P_monitor_clk  : process (clk) begin

    assert NOT (Is_X( clk ) AND (now > 0 ns)) 
      report "WARNING: Detected unknown value on the clock input port clk."
      severity warning;

  end process P_monitor_clk ;

    
-- pragma translate_on

end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_dpll_sd_cfg_sim of DW_dpll_sd is
 for sim
 end for; -- sim
end DW_dpll_sd_cfg_sim;
-- pragma translate_on

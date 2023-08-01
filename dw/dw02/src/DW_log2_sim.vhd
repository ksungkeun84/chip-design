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
-- AUTHOR:    Alexandre Tenca   June 2007
--
-- VERSION:   VHDL Simulation model version 2.0
--
-- DesignWare_version: f44d4aa2
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--
-- ABSTRACT: Fixed-point base-2 logarithm (DW_log2)
--           Computes the base-2 logarithm of a fixed point value in the 
--           range [1,2). 
--           The number of fractional bits to be used is controlled by
--           a parameter. 
-- 
--
--              parameters      valid values (defined in the DW manual)
--              ==========      ============
--              op_width        operand size,  >= 2
--                              includes the integer bit
--              arch            implementation select
--                              0 - area optimized 
--                              1 - speed optimized
--                              2 - 2007.12 implementation (default)
--              err_range       error range of the result compared to the
--                              true result. Default is used when arch=2.
--                              1 - 1 ulp max error (default)
--                              2 - 2 ulp max error
--
--              Input ports     Size & Description
--              ===========     ==================
--              a               main input with op_width fractional bits
--
--              Output ports    Size & Description
--              ===========     ==================
--              z               op_width fractional bits. log2(a)
--
-- MODIFIED:
--           August 2008 - Included new parameter to control alternative arch
--                         and err_range
--           May 2018 - AFT - Star 9001341564
--                         Removed declaration of variable that is not used in
--                         the code (addr_fill)
--
---------------------------------------------------------------------------------
                                       
library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use DWARE.DWpackages.all;

architecture sim of DW_log2 is
	
-- pragma translate_off

--#define debug true

signal lll10l10 : std_logic_vector(op_width-1 downto 0);
constant DW_l1I1lO01 : INTEGER := bit_width(op_width*6)+100;

  constant DW_OlOOO000 : INTEGER := 256;
  constant DW_OI1O1I0O : INTEGER := 8;
  constant DW_O010l10I : INTEGER := (47);
  constant O01ll0l0 : integer := (48);
  constant DW_l1010I01 : INTEGER := 4;
  constant DW_I0I00O00 : INTEGER := 4;
  constant DW_O0O0lO11 : INTEGER := 1;
  constant DW_O0OO0O01 : INTEGER :=  (op_width+DW_l1010I01+DW_I0I00O00+DW_O0O0lO11); 
  constant DW_l0l110I1 : INTEGER :=  (op_width+DW_l1010I01+DW_I0I00O00);
  constant DW_O001OOOI : INTEGER :=  (op_width+DW_l1010I01+DW_I0I00O00);
  constant DW_IOOO11OI : INTEGER :=  (op_width+DW_l1010I01+DW_I0I00O00);
  constant DW_l0IOl1OO : INTEGER :=  (op_width+DW_O0OO0O01-1);
  constant DW_O0Ol00I0 : INTEGER :=  (op_width+DW_l0l110I1-1);
  constant DW_OI0O0OO0 : INTEGER :=  (op_width+DW_O001OOOI-1);
  constant DW_O1100l11 : INTEGER :=  (op_width+DW_I0I00O00);
  constant DW_IO1IIIl0 : INTEGER :=  2;
  constant DW_IOl1OOO0 : INTEGER :=  (op_width-1+DW_IO1IIIl0);

  signal O010I0I1 : std_logic_vector (op_width-1 downto 0);
  signal OIO00011 : std_logic_vector (op_width-1 downto 0);

-- pragma translate_on
begin
-- pragma translate_off
  
    
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
    
    if ( (op_width < 2) OR (op_width > 60) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter op_width (legal range: 2 to 60)"
        severity warning;
    end if;
    
    if ( (arch < 0) OR (arch > 2) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter arch (legal range: 0 to 2)"
        severity warning;
    end if;
    
    if ( (err_range < 1) OR (err_range > 2) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter err_range (legal range: 1 to 2)"
        severity warning;
    end if;
    
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;

      
DW_IOO1Il01: process (a)
  variable OlOOO0l1 : unsigned(op_width+DW_l1I1lO01-1 downto 0);
  variable I00010Ol : unsigned(2*(op_width+DW_l1I1lO01)-1 downto 0);
  variable Ol000OO1 : std_logic_vector(op_width-1 downto 0);
  variable OIl1l0O1 : std_logic_vector(DW_l1I1lO01-1 downto 0);
  begin
    OIl1l0O1 := (others => '0');
    OlOOO0l1 := unsigned(a & OIl1l0O1);
    Ol000OO1 := (others => '0');
    for OOIO01I0 in 1 to op_width loop
      I00010Ol := OlOOO0l1 * OlOOO0l1;
      if (I00010Ol(I00010Ol'length-1) = '1') then
        Ol000OO1 := Ol000OO1(Ol000OO1'length-2 downto 0) & '1';
        OlOOO0l1 := I00010Ol(I00010Ol'length-1 downto op_width+DW_l1I1lO01);
      else
        Ol000OO1 := Ol000OO1(Ol000OO1'length-2 downto 0) & '0';
        OlOOO0l1 := I00010Ol(I00010Ol'length-2 downto op_width+DW_l1I1lO01-1);
      end if;
    end loop;
    I00010Ol := OlOOO0l1 * OlOOO0l1;
    if (I00010Ol(I00010Ol'length-1) = '1') then
      lll10l10 <= unsigned(Ol000OO1) + conv_unsigned(1,op_width);
    else
      lll10l10 <= Ol000OO1;
    end if;
  end process DW_IOO1Il01;  

DW_OOII11OI: process (a)
  variable O0lOO0lI : unsigned (O01ll0l0-1 downto 0);
  variable Ol01lOl0 : unsigned (O01ll0l0-1 downto 0);
  variable lO10IO1O : unsigned (O01ll0l0-1 downto 0);
  variable ll0O01OO : unsigned (O01ll0l0-1 downto 0);
  variable IlOl010O : unsigned (O01ll0l0-1 downto 0);
  variable IIOl10O0 : unsigned (O01ll0l0-1 downto 0);
  variable IO0l01l0 : unsigned (O01ll0l0-1 downto 0);
  variable O10011OO : unsigned (O01ll0l0-1 downto 0);
  variable OlIII0l1 : unsigned (O01ll0l0-1 downto 0);
  variable O0OOO1Ol : signed (DW_O0OO0O01-1 downto 0);
  variable IlO0OlO0 : signed (DW_l0l110I1-1 downto 0);
  variable I0lO01lI : signed (DW_O001OOOI-1 downto 0);
  variable Il001l11 : signed (DW_IOOO11OI-1 downto 0);
  variable I11000OO : signed (DW_l0l110I1-1 downto 0);
  variable O1010O10 : signed (DW_O001OOOI-1 downto 0);
  variable O1O11001 : signed (DW_IOOO11OI-1 downto 0);
  variable O0O01OO0 : signed (DW_O001OOOI-1 downto 0);
  variable l10OIO11 : signed (DW_IOOO11OI-1 downto 0);
  variable Ol111l1O  : signed (DW_OI0O0OO0+1 downto 0);
  variable l11OOO01  : signed (DW_O0Ol00I0+1 downto 0);
  variable OI0l0OO0 : signed (DW_l0IOl1OO+1 downto 0);
  variable O1llIl1O  : signed (DW_OI0O0OO0+1 downto 0);
  variable l0IIIO0O  : signed (DW_O0Ol00I0+1 downto 0);
  variable I011Ol10 : signed (DW_l0IOl1OO+1 downto 0);
  variable II0Ol1Il  : signed (DW_OI0O0OO0+1 downto 0);
  variable O0OlOOOl  : signed (DW_O0Ol00I0+1 downto 0);
  variable O10IlO11 : signed (DW_l0IOl1OO+1 downto 0);
  variable I11O100l  : signed (DW_OI0O0OO0 downto 0);
  variable O10ll00I : unsigned (DW_O1100l11-1 downto 0);
  variable IOO0O111 : unsigned (DW_O1100l11-1 downto 0);
  variable O1OI11lI : std_logic_vector (DW_OI1O1I0O-1 downto 0);
  variable lIOI0I0O : unsigned (DW_IOl1OOO0 downto 0);
  variable l0O11O0I : integer;
  variable OlO000O1 : unsigned (op_width-1 downto 0);
  variable Oll01O00 : unsigned (op_width-1+DW_O0O0lO11 downto 0);
begin
  OlO000O1 := (others => '0');
  OlO000O1(OlO000O1'left) := '1';
  Oll01O00 := (others => '0');
  Oll01O00(Oll01O00'left) := '1';
  for OOIO01I0 in 0 to DW_OI1O1I0O-1 loop
    if (op_width-1 <= OOIO01I0) then
      O1OI11lI(DW_OI1O1I0O - 1 - OOIO01I0) := '0';
    else
      O1OI11lI(DW_OI1O1I0O - 1 - OOIO01I0) := a(op_width - 2 - OOIO01I0);
    end if;
  end loop;
  
--                                                                       
--   Table created using MATLAB program Gen_log2_poly_coeff_rom_and_code 
--   Copyright   Synopsys Inc. 2007                                      
    case (O1OI11lI) is
      when "00000000" => 
              O0lOO0lI:= X"03D3229B8ECF";Ol01lOl0:= X"6EC14A028597";lO10IO1O:= X"228EA7DA0DF4";ll0O01OO:= X"6ADCEB87DDAF";
              IlOl010O:= X"7A406E892E54";IIOl10O0:= X"1709C45512A1";IO0l01l0:= X"6EB5CD21EF77";
              O10011OO:= X"0B84E1D5F876";OlIII0l1:= X"747B1F1E859C";
      when "00000001" => 
              O0lOO0lI:= X"03C7C5564D3A";Ol01lOl0:= X"6EE383DEED75";lO10IO1O:= X"226C4BCD6437";ll0O01OO:= X"6AE86AFD6E11";
              IlOl010O:= X"7A4BD6D9D9DF";IIOl10O0:= X"16F2DCE84B05";IO0l01l0:= X"6EC14C49CEDD";
              O10011OO:= X"0B796E208C51";OlIII0l1:= X"74869E462291";
      when "00000010" => 
              O0lOO0lI:= X"03BC9543390F";Ol01lOl0:= X"6F05572DF0E3";lO10IO1O:= X"224A34E0ECEA";ll0O01OO:= X"6AF3DEAE529E";
              IlOl010O:= X"7A571D571DEF";IIOl10O0:= X"16DC22D8EA28";IO0l01l0:= X"6ECCC0095A7D";
              O10011OO:= X"0B6E1119D99E";OlIII0l1:= X"74921205628E";
      when "00000011" => 
              O0lOO0lI:= X"03B191368C58";Ol01lOl0:= X"6F26C66DB448";lO10IO1O:= X"2228615CAEBF";ll0O01OO:= X"6AFF4700A7DA";
              IlOl010O:= X"7A6242862110";IIOl10O0:= X"16C595A0D20C";IO0l01l0:= X"6ED828770D05";
              O10011OO:= X"0B62CA7EBF16";OlIII0l1:= X"749D7A72D2B7";
      when "00000100" => 
              O0lOO0lI:= X"03A6B7ED608E";Ol01lOl0:= X"6F47D46E76C6";lO10IO1O:= X"2206CF2CB64E";ll0O01OO:= X"6B0AA47BC571";
              IlOl010O:= X"7A6D46E99822";IIOl10O0:= X"16AF34BBBCBC";IO0l01l0:= X"6EE385A93A95";
              O10011OO:= X"0B579A0D2357";OlIII0l1:= X"74A8D7A4BD94";
      when "00000101" => 
              O0lOO0lI:= X"039C098837BC";Ol01lOl0:= X"6F687FCBB450";lO10IO1O:= X"21E5807F7F80";ll0O01OO:= X"6B15F6362544";
              IlOl010O:= X"7A782B01B9D1";IIOl10O0:= X"1698FFA76934";IO0l01l0:= X"6EEED7B5F63C";
              O10011OO:= X"0B4C7F83EFD4";OlIII0l1:= X"74B429B12C15";
      when "00000110" => 
              O0lOO0lI:= X"03918444CC16";Ol01lOl0:= X"6F88CCEA7BA6";lO10IO1O:= X"21C4719AF783";ll0O01OO:= X"6B213D483988";
              IlOl010O:= X"7A82EF4C2796";IIOl10O0:= X"1682F5E3DEB7";IO0l01l0:= X"6EFA1EB2EB62";
              O10011OO:= X"0B417AA30BE7";OlIII0l1:= X"74BF70ADE691";
      when "00000111" => 
              O0lOO0lI:= X"03872784ABAC";Ol01lOl0:= X"6FA8BCBD2EFF";lO10IO1O:= X"21A3A241BAF7";ll0O01OO:= X"6B2C799CCDEA";
              IlOl010O:= X"7A8D94445A9D";IIOl10O0:= X"166D16F2A175";IO0l01l0:= X"6F055AB5C1C5";
              O10011OO:= X"0B368B2B5801";OlIII0l1:= X"74CAACB075C5";
      when "00001000" => 
              O0lOO0lI:= X"037CF3789B45";Ol01lOl0:= X"6FC84DB8D9DF";lO10IO1O:= X"218314C6B522";ll0O01OO:= X"6B37AA3CAA8B";
              IlOl010O:= X"7A981A634245";IIOl10O0:= X"165762578D03";IO0l01l0:= X"6F108BD3A9BF";
              O10011OO:= X"0B2BB0DEA8F7";OlIII0l1:= X"74D5DDCE23C4";
      when "00001001" => 
              O0lOO0lI:= X"0372E5B0B8D7";Ol01lOl0:= X"6FE7867B637B";lO10IO1O:= X"2162C30D6C42";ll0O01OO:= X"6B42D117F76F";
              IlOl010O:= X"7AA2821FABE2";IIOl10O0:= X"1641D79811D8";IO0l01l0:= X"6F1BB221BC58";
              O10011OO:= X"0B20EB7FC35F";OlIII0l1:= X"74E1041BFCF6";
      when "00001010" => 
              O0lOO0lI:= X"0368FF256AB0";Ol01lOl0:= X"70066318CBAA";lO10IO1O:= X"2142B1D9A3DE";ll0O01OO:= X"6B4DEC605CF7";
              IlOl010O:= X"7AACCBEE26F6";IIOl10O0:= X"162C763B8002";IO0l01l0:= X"6F26CDB4D14E";
              O10011OO:= X"0B163AD2571D";OlIII0l1:= X"74EC1FAED0F6";
      when "00001011" => 
              O0lOO0lI:= X"035F3E2FDD02";Ol01lOl0:= X"7024E7CFF5F5";lO10IO1O:= X"2122DD76C2D8";ll0O01OO:= X"6B58FD346285";
              IlOl010O:= X"7AB6F84103F1";IIOl10O0:= X"16173DCB1BB9";IO0l01l0:= X"6F31DEA1708D";
              O10011OO:= X"0B0B9E9AFAF6";OlIII0l1:= X"74F7309B3385";
      when "00001100" => 
              O0lOO0lI:= X"0355A215F15D";Ol01lOl0:= X"704316087A41";lO10IO1O:= X"2103451B8956";ll0O01OO:= X"6B6403B1EC6D";
              IlOl010O:= X"7AC107888331";IIOl10O0:= X"16022DD1CD0B";IO0l01l0:= X"6F3CE4FBF85D";
              O10011OO:= X"0B01169F283B";OlIII0l1:= X"750236F57D6E";
      when "00001101" => 
              O0lOO0lI:= X"034C2A921CC6";Ol01lOl0:= X"7060EDC05401";lO10IO1O:= X"20E3E9772C39";ll0O01OO:= X"6B6EFF738EC9";
              IlOl010O:= X"7ACAFA32CC7D";IIOl10O0:= X"15ED45DC421F";IO0l01l0:= X"6F47E0D88815";
              O10011OO:= X"0AF6A2A536A8";OlIII0l1:= X"750D32D1CD61";
      when "00001110" => 
              O0lOO0lI:= X"0342D6BFCBAC";Ol01lOl0:= X"707E70EEF672";lO10IO1O:= X"20C4C923F783";ll0O01OO:= X"6B79F0CE7869";
              IlOl010O:= X"7AD4D0ABF506";IIOl10O0:= X"15D88578F36E";IO0l01l0:= X"6F52D24AFA4E";
              O10011OO:= X"0AEC4274583D";OlIII0l1:= X"7518244408D4";
      when "00001111" => 
              O0lOO0lI:= X"0339A5DB451A";Ol01lOl0:= X"709BA12C0666";lO10IO1O:= X"20A5E31B372D";ll0O01OO:= X"6B84D7F7E6E3";
              IlOl010O:= X"7ADE8B5E2E41";IIOl10O0:= X"15C3EC37D117";IO0l01l0:= X"6F5DB9670D24";
              O10011OO:= X"0AE1F5D49530";OlIII0l1:= X"75230B5FDCDD";
      when "00010000" => 
              O0lOO0lI:= X"033097691FC4";Ol01lOl0:= X"70B87F2F6719";lO10IO1O:= X"2087373F54E8";ll0O01OO:= X"6B8FB4D3810C";
              IlOl010O:= X"7AE82AB1A420";IIOl10O0:= X"15AF79AA99A9";IO0l01l0:= X"6F689640311E";
              O10011OO:= X"0AD7BC8EC813";OlIII0l1:= X"752DE838BEFF";
      when "00010001" => 
              O0lOO0lI:= X"0327AA602800";Ol01lOl0:= X"70D50D7B72C4";lO10IO1O:= X"2068C3871EA8";ll0O01OO:= X"6B9A87F3FD5D";
              IlOl010O:= X"7AF1AF0C94E3";IIOl10O0:= X"159B2D64B7C8";IO0l01l0:= X"6F7368E997DB";
              O10011OO:= X"0ACD966C99E9";OlIII0l1:= X"7538BAE1EE04";
      when "00010010" => 
              O0lOO0lI:= X"031EDF744F66";Ol01lOl0:= X"70F14904C23E";lO10IO1O:= X"204A8BD571C6";ll0O01OO:= X"6BA54FD08E8A";
              IlOl010O:= X"7AFB18D37163";IIOl10O0:= X"158706FB0C4A";IO0l01l0:= X"6F7E31764D9B";
              O10011OO:= X"0AC383387E71";OlIII0l1:= X"7543836E72BD";
      when "00010011" => 
              O0lOO0lI:= X"03163453BE31";Ol01lOl0:= X"710D387885E4";lO10IO1O:= X"202C89A3A747";ll0O01OO:= X"6BB00E977370";
              IlOl010O:= X"7B046868E422";IIOl10O0:= X"15730603ED69";IO0l01l0:= X"6F88EFF936C8";
              O10011OO:= X"0AB982BDB06D";OlIII0l1:= X"754E41F120DC";
      when "00010100" => 
              O0lOO0lI:= X"030DA90BFC90";Ol01lOl0:= X"7128DAED71B4";lO10IO1O:= X"200EBE841BF8";ll0O01OO:= X"6BBAC394E22B";
              IlOl010O:= X"7B0D9E2DBD30";IIOl10O0:= X"155F2A176065";IO0l01l0:= X"6F93A484EDF2";
              O10011OO:= X"0AAF94C82E0E";OlIII0l1:= X"7558F67C97AA";
      when "00010101" => 
              O0lOO0lI:= X"03053DCB263F";Ol01lOl0:= X"71442F0DE301";lO10IO1O:= X"1FF12C83693E";ll0O01OO:= X"6BC56DE696DF";
              IlOl010O:= X"7B16BA8109FF";IIOl10O0:= X"154B72CEF4CA";IO0l01l0:= X"6F9E4F2BD44D";
              O10011OO:= X"0AA5B924B577";OlIII0l1:= X"7563A12342C9";
      when "00010110" => 
              O0lOO0lI:= X"02FCF12D7667";Ol01lOl0:= X"715F38A04784";lO10IO1O:= X"1FD3D02535D2";ll0O01OO:= X"6BD00EA95478";
              IlOl010O:= X"7B1FBDC02026";IIOl10O0:= X"1537DFC5BB44";IO0l01l0:= X"6FA8F000138D";
              O10011OO:= X"0A9BEFA0C133";OlIII0l1:= X"756E41F75B02";
      when "00010111" => 
              O0lOO0lI:= X"02F4C26B236A";Ol01lOl0:= X"7179F97B06A2";lO10IO1O:= X"1FB6A7FCD7CF";ll0O01OO:= X"6BDAA63E39C8";
              IlOl010O:= X"7B28A846E45C";IIOl10O0:= X"15247097B84C";IO0l01l0:= X"6FB38713E806";
              O10011OO:= X"0A92380A84F2";OlIII0l1:= X"7578D90AE6F1";
      when "00011000" => 
              O0lOO0lI:= X"02ECB1E0A87D";Ol01lOl0:= X"71946FBB5044";lO10IO1O:= X"1F99B6AC0E1A";ll0O01OO:= X"6BE5338CBFC8";
              IlOl010O:= X"7B317A6F3B48";IIOl10O0:= X"151124E32941";IO0l01l0:= X"6FBE1478ECE2";
              O10011OO:= X"0A889230EA2A";OlIII0l1:= X"7583666FBBBC";
      when "00011001" => 
              O0lOO0lI:= X"02E4BEDA5E59";Ol01lOl0:= X"71AE9CFA595F";lO10IO1O:= X"1F7CFB081021";ll0O01OO:= X"6BEFB6DD3ABE";
              IlOl010O:= X"7B3A3491B992";IIOl10O0:= X"14FDFC4711C9";IO0l01l0:= X"6FC89840E316";
              O10011OO:= X"0A7EFDE38CE2";OlIII0l1:= X"758DEA377DD3";
      when "00011010" => 
              O0lOO0lI:= X"02DCE8145799";Ol01lOl0:= X"71C884B5F2E8";lO10IO1O:= X"1F6071C9CDE5";ll0O01OO:= X"6BFA314026AF";
              IlOl010O:= X"7B42D705509A";IIOl10O0:= X"14EAF663FDA5";IO0l01l0:= X"6FD3127D4525";
              O10011OO:= X"0A757AF2B88C";OlIII0l1:= X"75986473A194";
      when "00011011" => 
              O0lOO0lI:= X"02D52DB882B5";Ol01lOl0:= X"71E225B9CDFA";lO10IO1O:= X"1F441CD0D884";ll0O01OO:= X"6C04A1E34DF4";
              IlOl010O:= X"7B4B621F4DCD";IIOl10O0:= X"14D812DC0F92";IO0l01l0:= X"6FDD833F3BC3";
              O10011OO:= X"0A6C092F64E6";OlIII0l1:= X"75A2D5356C03";
      when "00011100" => 
              O0lOO0lI:= X"02CD8ECAF5CE";Ol01lOl0:= X"71FB82A207F9";lO10IO1O:= X"1F27F9C53451";ll0O01OO:= X"6C0F0981CBF3";
              IlOl010O:= X"7B53D633AA25";IIOl10O0:= X"14C551525DC9";IO0l01l0:= X"6FE7EA97F563";
              O10011OO:= X"0A62A86B32F7";OlIII0l1:= X"75AD3C8DF36C";
      when "00011101" => 
              O0lOO0lI:= X"02C60B646726";Ol01lOl0:= X"72149A776885";lO10IO1O:= X"1F0C0A426EDB";ll0O01OO:= X"6C19676193BD";
              IlOl010O:= X"7B5C3394C7D8";IIOl10O0:= X"14B2B16B9060";IO0l01l0:= X"6FF248984C26";
              O10011OO:= X"0A5958786A1B";OlIII0l1:= X"75B79A8E2014";
      when "00011110" => 
              O0lOO0lI:= X"02BEA29874C0";Ol01lOl0:= X"722D6FACE3C4";lO10IO1O:= X"1EF04C1666A1";ll0O01OO:= X"6C23BC319229";
              IlOl010O:= X"7B647A93BED8";IIOl10O0:= X"14A032CD42ED";IO0l01l0:= X"6FFC9D511B3D";
              O10011OO:= X"0A501929F516";OlIII0l1:= X"75C1EF46ACD5";
      when "00011111" => 
              O0lOO0lI:= X"02B753EC144F";Ol01lOl0:= X"7246034131DF";lO10IO1O:= X"1ED4BEA83443";ll0O01OO:= X"6C2E080A3EEC";
              IlOl010O:= X"7B6CAB800022";IIOl10O0:= X"148DD51EDEF3";IO0l01l0:= X"7006E8D2C26B";
              O10011OO:= X"0A46EA535F3C";OlIII0l1:= X"75CC3AC827C9";
      when "00100000" => 
              O0lOO0lI:= X"02B01F9C0FA3";Ol01lOl0:= X"725E53C9BDAB";lO10IO1O:= X"1EB96413C58F";ll0O01OO:= X"6C384A005930";
              IlOl010O:= X"7B74C6A7D9CA";IIOl10O0:= X"147B98087FD5";IO0l01l0:= X"70112B2DC251";
              O10011OO:= X"0A3DCBC8D1B2";OlIII0l1:= X"75D67D22F2E0";
      when "00100001" => 
              O0lOO0lI:= X"02A904DA3876";Ol01lOl0:= X"72766361B370";lO10IO1O:= X"1E9E3A7F9458";ll0O01OO:= X"6C4282A3C479";
              IlOl010O:= X"7B7CCC58198A";IIOl10O0:= X"14697B33CEEB";IO0l01l0:= X"701B64723EC2";
              O10011OO:= X"0A34BD5F10AC";OlIII0l1:= X"75E0B6674480";
      when "00100010" => 
              O0lOO0lI:= X"02A2022F1DE1";Ol01lOl0:= X"728E366CF815";lO10IO1O:= X"1E833D72DC9E";ll0O01OO:= X"6C4CB384A99C";
              IlOl010O:= X"7B84BCDC54CF";IIOl10O0:= X"14577E4B6C45";IO0l01l0:= X"702594B05157";
              O10011OO:= X"0A2BBEEB78BF";OlIII0l1:= X"75EAE6A52822";
      when "00100011" => 
              O0lOO0lI:= X"029B184FAF45";Ol01lOl0:= X"72A5C9F2A3D6";lO10IO1O:= X"1E6870C6EBA4";ll0O01OO:= X"6C56DB1049BD";
              IlOl010O:= X"7B8C987ECFC0";IIOl10O0:= X"1445A0FB3132";IO0l01l0:= X"702FBBF7E1B9";
              O10011OO:= X"0A22D043FC4D";OlIII0l1:= X"75F50DEC7EE5";
      when "00100100" => 
              O0lOO0lI:= X"029446E85E8E";Ol01lOl0:= X"72BD1E7AF79D";lO10IO1O:= X"1E4DD4606401";ll0O01OO:= X"6C60F9306AA1";
              IlOl010O:= X"7B945F887364";IIOl10O0:= X"1433E2F05143";IO0l01l0:= X"7039DA589047";
              O10011OO:= X"0A19F13F20F1";OlIII0l1:= X"75FF2C4D0028";
      when "00100101" => 
              O0lOO0lI:= X"028D8D467B09";Ol01lOl0:= X"72D435D8140E";lO10IO1O:= X"1E3366A8728F";ll0O01OO:= X"6C6B0E5FCF8F";
              IlOl010O:= X"7B9C12410D15";IIOl10O0:= X"142243D8D3FA";IO0l01l0:= X"7043EFE2004C";
              O10011OO:= X"0A1121B3FCF7";OlIII0l1:= X"760941D63A14";
      when "00100110" => 
              O0lOO0lI:= X"0286EA9A5D48";Ol01lOl0:= X"72EB12474F34";lO10IO1O:= X"1E19258661BE";ll0O01OO:= X"6C751B4D0A16";
              IlOl010O:= X"7BA3B0EF16F6";IIOl10O0:= X"1410C3641D25";IO0l01l0:= X"704DFCA38808";
              O10011OO:= X"0A08617A34FA";OlIII0l1:= X"76134E97922E";
      when "00100111" => 
              O0lOO0lI:= X"02805ED31F24";Ol01lOl0:= X"7301B379D04C";lO10IO1O:= X"1DFF11CA57B2";ll0O01OO:= X"6C7F1F8AA4C0";
              IlOl010O:= X"7BAB3BD7DA52";IIOl10O0:= X"13FF6142A85E";IO0l01l0:= X"705800AC5562";
              O10011OO:= X"09FFB069F95F";OlIII0l1:= X"761D52A045E9";
      when "00101000" => 
              O0lOO0lI:= X"0279E9D42310";Ol01lOl0:= X"731819490FC2";lO10IO1O:= X"1DE52C17D7C1";ll0O01OO:= X"6C891ABB264F";
              IlOl010O:= X"7BB2B33FAD1E";IIOl10O0:= X"13EE1D258410";IO0l01l0:= X"7061FC0BB8C4";
              O10011OO:= X"09F70E5C0411";OlIII0l1:= X"76274DFF6B30";
      when "00101001" => 
              O0lOO0lI:= X"02738ACAD2E4";Ol01lOl0:= X"732E46094F6C";lO10IO1O:= X"1DCB7231E460";ll0O01OO:= X"6C930D9D7555";
              IlOl010O:= X"7BBA176974CF";IIOl10O0:= X"13DCF6BF7BAD";IO0l01l0:= X"706BEED076D3";
              O10011OO:= X"09EE7B29962D";OlIII0l1:= X"763140C3F0E4";
      when "00101010" => 
              O0lOO0lI:= X"026D41E2A026";Ol01lOl0:= X"7344389EBC5B";lO10IO1O:= X"1DB1E5D56894";ll0O01OO:= X"6C9CF767928F";
              IlOl010O:= X"7BC1689703B9";IIOl10O0:= X"13CBEDC44A08";IO0l01l0:= X"7075D9093C98";
              O10011OO:= X"09E5F6AC75B4";OlIII0l1:= X"763B2AFC9F6C";
      when "00101011" => 
              O0lOO0lI:= X"02670DF6BACF";Ol01lOl0:= X"7359F486DA13";lO10IO1O:= X"1D988362C724";ll0O01OO:= X"6CA6D96469AC";
              IlOl010O:= X"7BC8A70957D1";IIOl10O0:= X"13BB01E80EE3";IO0l01l0:= X"707FBAC4EEAB";
              O10011OO:= X"09DD80BEEB5E";OlIII0l1:= X"76450CB81939";
      when "00101100" => 
              O0lOO0lI:= X"0260EF6621FF";Ol01lOl0:= X"736F77F5D2A5";lO10IO1O:= X"1D7F4D622AC5";ll0O01OO:= X"6CB0B27ADE4A";
              IlOl010O:= X"7BCFD30000EF";IIOl10O0:= X"13AA32E0BE31";IO0l01l0:= X"70899411D117";
              O10011OO:= X"09D5193BC063";OlIII0l1:= X"764EE604DB46";
      when "00101101" => 
              O0lOO0lI:= X"025AE5311D1B";Ol01lOl0:= X"7384C5F1C642";lO10IO1O:= X"1D6640B60630";ll0O01OO:= X"6CBA83C601FE";
              IlOl010O:= X"7BD6ECB9C248";IIOl10O0:= X"13998064AFCA";IO0l01l0:= X"709364FE5C3D";
              O10011OO:= X"09CCBFFE3C66";OlIII0l1:= X"7658B6F13D91";
      when "00101110" => 
              O0lOO0lI:= X"0254F011CFFA";Ol01lOl0:= X"7399DB6D0191";lO10IO1O:= X"1D4D616458AC";ll0O01OO:= X"6CC44B94E270";
              IlOl010O:= X"7BDDF4743B60";IIOl10O0:= X"1388EA2B7307";IO0l01l0:= X"709D2D98BF46";
              O10011OO:= X"09C474E22358";OlIII0l1:= X"76627F8B73A3";
      when "00101111" => 
              O0lOO0lI:= X"024F0E1BACB8";Ol01lOl0:= X"73AEBEBE9F6F";lO10IO1O:= X"1D34A85C424F";ll0O01OO:= X"6CCE0C933ACD";
              IlOl010O:= X"7BE4EA6C0C68";IIOl10O0:= X"13786FED81F7";IO0l01l0:= X"70A6EDEF0B20";
              O10011OO:= X"09BC37C3B364";OlIII0l1:= X"766C3FE18D03";
      when "00110000" => 
              O0lOO0lI:= X"02493FE26BB0";Ol01lOl0:= X"73C36D666D24";lO10IO1O:= X"1D1C18F91C82";ll0O01OO:= X"6CD7C553D6B2";
              IlOl010O:= X"7BEBCEDCBF67";IIOl10O0:= X"136811647FA7";IO0l01l0:= X"70B0A60F0B95";
              O10011OO:= X"09B4087FA2FA";OlIII0l1:= X"7675F80175B6";
      when "00110001" => 
              O0lOO0lI:= X"0243857DEC62";Ol01lOl0:= X"73D7E697E479";lO10IO1O:= X"1D03B498CF92";ll0O01OO:= X"6CE1752FA13B";
              IlOl010O:= X"7BF2A2012B5C";IIOl10O0:= X"1357CE4A5455";IO0l01l0:= X"70BA5606CCE2";
              O10011OO:= X"09ABE6F31ED1";OlIII0l1:= X"767FA7F8F6AA";
      when "00110010" => 
              O0lOO0lI:= X"023DDE37AB03";Ol01lOl0:= X"73EC2C69E9CF";lO10IO1O:= X"1CEB7927A438";ll0O01OO:= X"6CEB1CDD7F90";
              IlOl010O:= X"7BF96412CAA8";IIOl10O0:= X"1347A65AC8BA";IO0l01l0:= X"70C3FDE3A523";
              O10011OO:= X"09A3D2FBC7FC";OlIII0l1:= X"76894FD5B63F";
      when "00110011" => 
              O0lOO0lI:= X"023849BD6C05";Ol01lOl0:= X"74003F917BA4";lO10IO1O:= X"1CD366337803";ll0O01OO:= X"6CF4BC6FB5AA";
              IlOl010O:= X"7C00154A8C7B";IIOl10O0:= X"133799519A7D";IO0l01l0:= X"70CD9DB35778";
              O10011OO:= X"099BCC77B1F7";OlIII0l1:= X"7692EFA538A8";
      when "00110100" => 
              O0lOO0lI:= X"0232C773B9DD";Ol01lOl0:= X"741421CF5E39";lO10IO1O:= X"1CBB7A052D39";ll0O01OO:= X"6CFE547B95EA";
              IlOl010O:= X"7C06B5E03906";IIOl10O0:= X"1327A6EBF77D";IO0l01l0:= X"70D735832FE9";
              O10011OO:= X"0993D34560EB";OlIII0l1:= X"769C8774E068";
      when "00110101" => 
              O0lOO0lI:= X"022D57C7FD33";Ol01lOl0:= X"7427D129D7CB";lO10IO1O:= X"1CA3B76182D4";ll0O01OO:= X"6D07E3C9EB47";
              IlOl010O:= X"7C0D460AC356";IIOl10O0:= X"1317CEE7C169";IO0l01l0:= X"70E0C560722C";
              O10011OO:= X"098BE743C7BA";OlIII0l1:= X"76A61751EEBB";
      when "00110110" => 
              O0lOO0lI:= X"0227F91677C6";Ol01lOl0:= X"743B5326FCB2";lO10IO1O:= X"1C8C17FCC13B";ll0O01OO:= X"6D116CCA0934";
              IlOl010O:= X"7C13C60025EF";IIOl10O0:= X"13081103EA4B";IO0l01l0:= X"70EA4D582032";
              O10011OO:= X"09840852464F";OlIII0l1:= X"76AF9F498406";
      when "00110111" => 
              O0lOO0lI:= X"0222AD18264F";Ol01lOl0:= X"744EA118FC8C";lO10IO1O:= X"1C74A44FB70A";ll0O01OO:= X"6D1AEBF5CFE6";
              IlOl010O:= X"7C1A35F5B04D";IIOl10O0:= X"12F86CFFBFC3";IO0l01l0:= X"70F3CD7765EC";
              O10011OO:= X"097C3650A7D0";OlIII0l1:= X"76B91F68A047";
      when "00111000" => 
              O0lOO0lI:= X"021D71B70DF0";Ol01lOl0:= X"7461C22FD126";lO10IO1O:= X"1C5D54003BE8";ll0O01OO:= X"6D246494A37B";
              IlOl010O:= X"7C20961FAF42";IIOl10O0:= X"12E8E29BC610";IO0l01l0:= X"70FD45CB1310";
              O10011OO:= X"0974711F20F0";OlIII0l1:= X"76C297BC2376";
      when "00111001" => 
              O0lOO0lI:= X"021847829106";Ol01lOl0:= X"7474B3FA7483";lO10IO1O:= X"1C462A637EAB";ll0O01OO:= X"6D2DD5338350";
              IlOl010O:= X"7C26E6B19AB0";IIOl10O0:= X"12D97199505B";IO0l01l0:= X"7106B65FD809";
              O10011OO:= X"096CB89E4E39";OlIII0l1:= X"76CC0850CDF9";
      when "00111010" => 
              O0lOO0lI:= X"02132E435F84";Ol01lOl0:= X"748776DCE810";lO10IO1O:= X"1C2F275E04FA";ll0O01OO:= X"6D373DC3A15E";
              IlOl010O:= X"7C2D27DE41AF";IIOl10O0:= X"12CA19BA1B04";IO0l01l0:= X"71101F4282CB";
              O10011OO:= X"09650CAF3268";OlIII0l1:= X"76D571334105";
      when "00111011" => 
              O0lOO0lI:= X"020E253D215A";Ol01lOl0:= X"749A0D28E117";lO10IO1O:= X"1C184872D51B";ll0O01OO:= X"6D409F30A01E";
              IlOl010O:= X"7C3359D768BB";IIOl10O0:= X"12BADAC141AB";IO0l01l0:= X"7119807F668C";
              O10011OO:= X"095D6D3334CF";OlIII0l1:= X"76DED26FFF02";
      when "00111100" => 
              O0lOO0lI:= X"02092C87CA28";Ol01lOl0:= X"74AC76248DD6";lO10IO1O:= X"1C018EE03861";ll0O01OO:= X"6D49F8DF932B";
              IlOl010O:= X"7C397CCE2D03";IIOl10O0:= X"12ABB4725279";IO0l01l0:= X"7122DA22EB1C";
              O10011OO:= X"0955DA0C1FC2";OlIII0l1:= X"76E82C136BF3";
      when "00111101" => 
              O0lOO0lI:= X"020443F1B8F1";Ol01lOl0:= X"74BEB22611C8";lO10IO1O:= X"1BEAFA968D3B";ll0O01OO:= X"6D534ABDDDCE";
              IlOl010O:= X"7C3F90F30633";IIOl10O0:= X"129CA6914E9E";IO0l01l0:= X"712C2C398BDC";
              O10011OO:= X"094E531C1EFF";OlIII0l1:= X"76F17E29CDCF";
      when "00111110" => 
              O0lOO0lI:= X"01FF6AD3B7FA";Ol01lOl0:= X"74D0C33C17AA";lO10IO1O:= X"1BD489613633";ll0O01OO:= X"6D5C959C9315";
              IlOl010O:= X"7C4596755A0B";IIOl10O0:= X"128DB0E3BD1B";IO0l01l0:= X"713576CF2C00";
              O10011OO:= X"0946D845BE2A";OlIII0l1:= X"76FAC8BF4CF6";
      when "00111111" => 
              O0lOO0lI:= X"01FAA139B7B8";Ol01lOl0:= X"74E2A8DD7C08";lO10IO1O:= X"1BBE3C408AD9";ll0O01OO:= X"6D65D8F9FF73";
              IlOl010O:= X"7C4B8D840826";IIOl10O0:= X"127ED32F56F9";IO0l01l0:= X"713EB9EFE729";
              O10011OO:= X"093F696BE751";OlIII0l1:= X"77040BDFF479";
      when "01000000" => 
              O0lOO0lI:= X"01F5E6EA6FA1";Ol01lOl0:= X"74F46383C85F";lO10IO1O:= X"1BA812F3C1EA";ll0O01OO:= X"6D6F14D8FC26";
              IlOl010O:= X"7C51764D429D";IIOl10O0:= X"12700D3A6DA6";IO0l01l0:= X"7147F5A7D14F";
              O10011OO:= X"09380671E170";OlIII0l1:= X"770D4797B282";
      when "01000001" => 
              O0lOO0lI:= X"01F13BFDE531";Ol01lOl0:= X"7505F2783DEF";lO10IO1O:= X"1B920EB6C13F";ll0O01OO:= X"6D78489D4900";
              IlOl010O:= X"7C5750FE4B22";IIOl10O0:= X"12615ECC984A";IO0l01l0:= X"71512A0288A1";
              O10011OO:= X"0930AF3B4EFD";OlIII0l1:= X"77167BF258B8";
      when "01000010" => 
              O0lOO0lI:= X"01EC9F4D9F29";Ol01lOl0:= X"751759B6250A";lO10IO1O:= X"1B7C2ADE54A9";ll0O01OO:= X"6D817623868E";
              IlOl010O:= X"7C5D1DC3F14D";IIOl10O0:= X"1252C7AD7D8B";IO0l01l0:= X"715A570BF637";
              O10011OO:= X"092963AC2C82";OlIII0l1:= X"771FA8FB9C7F";
      when "01000011" => 
              O0lOO0lI:= X"01E8114D38FA";Ol01lOl0:= X"75289732F479";lO10IO1O:= X"1B666A4C9D75";ll0O01OO:= X"6D8A9C1FEBDA";
              IlOl010O:= X"7C62DCCA241C";IIOl10O0:= X"124447A5EDED";IO0l01l0:= X"71637CCF9BC8";
              O10011OO:= X"092223A8CF30";OlIII0l1:= X"7728CEBF177F";
      when "01000100" => 
              O0lOO0lI:= X"01E39216154D";Ol01lOl0:= X"7539AA35324F";lO10IO1O:= X"1B50CE411549";ll0O01OO:= X"6D93B9F3A949";
              IlOl010O:= X"7C688E3C306C";IIOl10O0:= X"1235DE7F4CC9";IO0l01l0:= X"716C9B58F0E4";
              O10011OO:= X"091AEF15E38C";OlIII0l1:= X"7731ED4847C9";
      when "01000101" => 
              O0lOO0lI:= X"01DF20BB6BC9";Ol01lOl0:= X"754A95E9CD08";lO10IO1O:= X"1B3B5308DB07";ll0O01OO:= X"6D9CD1170197";
              IlOl010O:= X"7C6E3244C2E9";IIOl10O0:= X"12278C039069";IO0l01l0:= X"7175B2B361B9";
              O10011OO:= X"0913C5D86C12";OlIII0l1:= X"773B04A2904E";
      when "01000110" => 
              O0lOO0lI:= X"01DABCFBD566";Ol01lOl0:= X"755B5AF83DFA";lO10IO1O:= X"1B25F81C46E7";ll0O01OO:= X"6DA5E1AE1367";
              IlOl010O:= X"7C73C90DD6A9";IIOl10O0:= X"12194FFD734F";IO0l01l0:= X"717EC2EA2EA3";
              O10011OO:= X"090CA7D5BFE1";OlIII0l1:= X"774414D9392F";
      when "01000111" => 
              O0lOO0lI:= X"01D667587A40";Ol01lOl0:= X"756BF71FA388";lO10IO1O:= X"1B10C0A9EC45";ll0O01OO:= X"6DAEEA485661";
              IlOl010O:= X"7C7952C0CC28";IIOl10O0:= X"120B2A383F17";IO0l01l0:= X"7187CC088C6B";
              O10011OO:= X"090594F38974";OlIII0l1:= X"774D1DF7700C";
      when "01001000" => 
              O0lOO0lI:= X"01D21E90D9CD";Ol01lOl0:= X"757C6EDBBA9F";lO10IO1O:= X"1AFBA744749C";ll0O01OO:= X"6DB7ED1FC2E2";
              IlOl010O:= X"7C7ECF865295";IIOl10O0:= X"11FD1A800B70";IO0l01l0:= X"7190CE197AF5";
              O10011OO:= X"08FE8D17C560";OlIII0l1:= X"775620084855";
      when "01001001" => 
              O0lOO0lI:= X"01CDE3723BB0";Ol01lOl0:= X"758CBEC80644";lO10IO1O:= X"1AE6B090B636";ll0O01OO:= X"6DC0E8231867";
              IlOl010O:= X"7C843F8694B4";IIOl10O0:= X"11EF20A15046";IO0l01l0:= X"7199C9280A26";
              O10011OO:= X"08F79028C10F";OlIII0l1:= X"775F1B16BBA5";
      when "01001010" => 
              O0lOO0lI:= X"01C9B57F2531";Ol01lOl0:= X"759CE87726DA";lO10IO1O:= X"1AD1DAD8282A";ll0O01OO:= X"6DC9DBF74742";
              IlOl010O:= X"7C89A2E9134B";IIOl10O0:= X"11E13C694ABB";IO0l01l0:= X"71A2BD3F1818";
              O10011OO:= X"08F09E0D1988";OlIII0l1:= X"77680F2DAA09";
      when "01001011" => 
              O0lOO0lI:= X"01C5944440EB";Ol01lOl0:= X"75ACED59913A";lO10IO1O:= X"1ABD248ABA04";ll0O01OO:= X"6DD2C932CE5F";
              IlOl010O:= X"7C8EF9D4C1C7";IIOl10O0:= X"11D36DA5B86B";IO0l01l0:= X"71ABAA697C08";
              O10011OO:= X"08E9B6ABBA47";OlIII0l1:= X"7770FC57DA4E";
      when "01001100" => 
              O0lOO0lI:= X"01C17FC800FC";Ol01lOl0:= X"75BCCD0A04BE";lO10IO1O:= X"1AA88E7525E6";ll0O01OO:= X"6DDBAF684F75";
              IlOl010O:= X"7C94446FD45F";IIOl10O0:= X"11C5B4255D4A";IO0l01l0:= X"71B490B1AE62";
              O10011OO:= X"08E2D9EBDBF6";OlIII0l1:= X"7779E29FFA5B";
      when "01001101" => 
              O0lOO0lI:= X"01BD77B39E9E";Ol01lOl0:= X"75CC888EA906";lO10IO1O:= X"1A94178CD0DD";ll0O01OO:= X"6DE48EF5E812";
              IlOl010O:= X"7C9982E02ADA";IIOl10O0:= X"11B80FB6F3BA";IO0l01l0:= X"71BD702277A6";
              O10011OO:= X"08DC07B50366";OlIII0l1:= X"7782C2109F6C";
      when "01001110" => 
              O0lOO0lI:= X"01B97BF124A6";Ol01lOl0:= X"75DC1FF329F5";lO10IO1O:= X"1A7FC00AA200";ll0O01OO:= X"6DED67AE27D1";
              IlOl010O:= X"7C9EB54AEB92";IIOl10O0:= X"11AA802A36A5";IO0l01l0:= X"71C648C642FA";
              O10011OO:= X"08D53FEF003F";OlIII0l1:= X"778B9AB4467D";
      when "01001111" => 
              O0lOO0lI:= X"01B58C6F3440";Ol01lOl0:= X"75EB93317BA5";lO10IO1O:= X"1A6B883F2DBD";ll0O01OO:= X"6DF63958CB86";
              IlOl010O:= X"7CA3DBD4AC27";IIOl10O0:= X"119D054F7CE5";IO0l01l0:= X"71CF1AA75DCB";
              O10011OO:= X"08CE8281EC1F";OlIII0l1:= X"77946C95545F";
      when "01010000" => 
              O0lOO0lI:= X"01B1A890233D";Ol01lOl0:= X"75FAE46D4D5F";lO10IO1O:= X"1A576DA36689";ll0O01OO:= X"6DFF04FBFE5C";
              IlOl010O:= X"7CA8F6A1A445";IIOl10O0:= X"118F9EF7386B";IO0l01l0:= X"71D7E5D04B4C";
              O10011OO:= X"08C7CF562946";OlIII0l1:= X"779D37BE1635";
      when "01010001" => 
              O0lOO0lI:= X"01ADD0E32860";Ol01lOl0:= X"760A112AD51C";lO10IO1O:= X"1A4373C0C931";ll0O01OO:= X"6E07C8F6BD59";
              IlOl010O:= X"7CAE05D545A2";IIOl10O0:= X"11824CF30B08";IO0l01l0:= X"71E0AA4B0DFF";
              O10011OO:= X"08C1265461A3";OlIII0l1:= X"77A5FC38C1A8";
      when "01010010" => 
              O0lOO0lI:= X"01AA047B90A9";Ol01lOl0:= X"76191CCA87C1";lO10IO1O:= X"1A2F966ADCD6";ll0O01OO:= X"6E10870980F9";
              IlOl010O:= X"7CB30992B1D3";IIOl10O0:= X"11750F14957A";IO0l01l0:= X"71E96821EEB5";
              O10011OO:= X"08BA876585C0";OlIII0l1:= X"77AEBA0F7526";
      when "01010011" => 
              O0lOO0lI:= X"01A643E75D53";Ol01lOl0:= X"762804D448FA";lO10IO1O:= X"1A1BD9296103";ll0O01OO:= X"6E193D9220C0";
              IlOl010O:= X"7CB801FC49B9";IIOl10O0:= X"1167E52EA428";IO0l01l0:= X"71F21F5EB541";
              O10011OO:= X"08B3F272CBAC";OlIII0l1:= X"77B7714C383D";
      when "01010100" => 
              O0lOO0lI:= X"01A28DDAE6EF";Ol01lOl0:= X"7636CE2B52E5";lO10IO1O:= X"1A0835C4BA53";ll0O01OO:= X"6E21EF3C485A";
              IlOl010O:= X"7CBCEF34405C";IIOl10O0:= X"115ACF13AEDB";IO0l01l0:= X"71FAD00BA59D";
              O10011OO:= X"08AD6765AE0E";OlIII0l1:= X"77C021F8FBBC";
      when "01010101" => 
              O0lOO0lI:= X"019EE3C55DF9";Ol01lOl0:= X"764572D49042";lO10IO1O:= X"19F4B47286EA";ll0O01OO:= X"6E2A98513E36";
              IlOl010O:= X"7CC1D15BFC1F";IIOl10O0:= X"114DCC978160";IO0l01l0:= X"72037A32658E";
              O10011OO:= X"08A6E627EB07";OlIII0l1:= X"77C8CC1F9A28";
      when "01010110" => 
              O0lOO0lI:= X"019B43DE2CC3";Ol01lOl0:= X"7653F9AE48C9";lO10IO1O:= X"19E14C4EF6B7";ll0O01OO:= X"6E333CAFD727";
              IlOl010O:= X"7CC6A894996B";IIOl10O0:= X"1140DD8DE4C2";IO0l01l0:= X"720C1DDCDEFF";
              O10011OO:= X"08A06EA38345";OlIII0l1:= X"77D16FC9D7DD";
      when "01010111" => 
              O0lOO0lI:= X"0197AF410F27";Ol01lOl0:= X"76625E07055B";lO10IO1O:= X"19CE03DF4E9B";ll0O01OO:= X"6E3BD95DD299";
              IlOl010O:= X"7CCB74FE7713";IIOl10O0:= X"113401CBD782";IO0l01l0:= X"7214BB146ED1";
              O10011OO:= X"089A00C2B915";OlIII0l1:= X"77DA0D01634D";
      when "01011000" => 
              O0lOO0lI:= X"019424B4A94A";Ol01lOl0:= X"7670A48A855E";lO10IO1O:= X"19BAD5216E74";ll0O01OO:= X"6E4470F729D9";
              IlOl010O:= X"7CD036B9DC69";IIOl10O0:= X"11273925D51B";IO0l01l0:= X"721D51E30A74";
              O10011OO:= X"08939C700F50";OlIII0l1:= X"77E2A3CFD562";
      when "01011001" => 
              O0lOO0lI:= X"0190A5270DA5";Ol01lOl0:= X"767EC939A33E";lO10IO1O:= X"19A7C5B42C05";ll0O01OO:= X"6E4D00E43CFC";
              IlOl010O:= X"7CD4EDE644E2";IIOl10O0:= X"111A8371BCA7";IO0l01l0:= X"7225E251F904";
              O10011OO:= X"088D41964896";OlIII0l1:= X"77EB343EB18E";
      when "01011010" => 
              O0lOO0lI:= X"018D2F4473BF";Ol01lOl0:= X"768CD134885A";lO10IO1O:= X"1994CEED265E";ll0O01OO:= X"6E558C113002";
              IlOl010O:= X"7CD99AA2D9EF";IIOl10O0:= X"110DE0858E43";IO0l01l0:= X"722E6C6AAA6A";
              O10011OO:= X"0886F0206638";OlIII0l1:= X"77F3BE576642";
      when "01011011" => 
              O0lOO0lI:= X"0189C46765D3";Ol01lOl0:= X"769AB6BF654C";lO10IO1O:= X"1981F8CC3283";ll0O01OO:= X"6E5E0ECFEF76";
              IlOl010O:= X"7CDE3D0E7655";IIOl10O0:= X"11015037642F";IO0l01l0:= X"7236F036BBFE";
              O10011OO:= X"0880A7F9A770";OlIII0l1:= X"77FC42234CF9";
      when "01011100" => 
              O0lOO0lI:= X"018662EF4EDC";Ol01lOl0:= X"76A8803AF556";lO10IO1O:= X"196F3AEAB5AC";ll0O01OO:= X"6E668CD9340C";
              IlOl010O:= X"7CE2D54743E2";IIOl10O0:= X"10F4D25E809A";IO0l01l0:= X"723F6DBF40C3";
              O10011OO:= X"087A690D8873";OlIII0l1:= X"7804BFABAA94";
      when "01011101" => 
              O0lOO0lI:= X"01830C471FF9";Ol01lOl0:= X"76B627A1A839";lO10IO1O:= X"195C9DB78422";ll0O01OO:= X"6E6F0247482F";
              IlOl010O:= X"7CE7636B1215";IIOl10O0:= X"10E866D26729";IO0l01l0:= X"7247E50D5C28";
              O10011OO:= X"08743347C187";OlIII0l1:= X"780D36F9AF94";
      when "01011110" => 
              O0lOO0lI:= X"017FBE00EC00";Ol01lOl0:= X"76C3B6AA93CA";lO10IO1O:= X"194A142CFB60";ll0O01OO:= X"6E7774F44B8E";
              IlOl010O:= X"7CEBE79754C2";IIOl10O0:= X"10DC0D6AE32C";IO0l01l0:= X"7250562A3D63";
              O10011OO:= X"086E06944642";OlIII0l1:= X"7815A8167842";
      when "01011111" => 
              O0lOO0lI:= X"017C79EEABF0";Ol01lOl0:= X"76D125A76E64";lO10IO1O:= X"1937A902DE27";ll0O01OO:= X"6E7FDFED9439";
              IlOl010O:= X"7CF061E91587";IIOl10O0:= X"10CFC600327A";IO0l01l0:= X"7258C11F0177";
              O10011OO:= X"0867E2DF4495";OlIII0l1:= X"781E130B0D03";
      when "01100000" => 
              O0lOO0lI:= X"01793F4E7293";Ol01lOl0:= X"76DE777A42A8";lO10IO1O:= X"192558836656";ll0O01OO:= X"6E8844D1C4C5";
              IlOl010O:= X"7CF4D27CCE38";IIOl10O0:= X"10C3906B7020";IO0l01l0:= X"726125F468F5";
              O10011OO:= X"0861C815240B";OlIII0l1:= X"782677E06283";
      when "01100001" => 
              O0lOO0lI:= X"01760E6E268F";Ol01lOl0:= X"76EBAAA76124";lO10IO1O:= X"191324F580C1";ll0O01OO:= X"6E90A282AC11";
              IlOl010O:= X"7CF9396EC5DC";IIOl10O0:= X"10B76C859881";IO0l01l0:= X"726984B383DE";
              O10011OO:= X"085BB62284EE";OlIII0l1:= X"782ED69F59F1";
      when "01100010" => 
              O0lOO0lI:= X"0172E5F94465";Ol01lOl0:= X"76F8C479AA37";lO10IO1O:= X"19010743DC82";ll0O01OO:= X"6E98FC314FCB";
              IlOl010O:= X"7CFD96DAAE4B";IIOl10O0:= X"10AB5A289ACB";IO0l01l0:= X"7271DD64F4E1";
              O10011OO:= X"0855ACF43F83";OlIII0l1:= X"78372F50C13D";
      when "01100011" => 
              O0lOO0lI:= X"016FC71DE54C";Ol01lOl0:= X"7705BFD5F27B";lO10IO1O:= X"18EF06B5B0B8";ll0O01OO:= X"6EA14E71F09B";
              IlOl010O:= X"7D01EADC0CDE";IIOl10O0:= X"109F592E3B7E";IO0l01l0:= X"727A3011B565";
              O10011OO:= X"084FAC776339";OlIII0l1:= X"783F81FD5348";
      when "01100100" => 
              O0lOO0lI:= X"016CB0F8B808";Ol01lOl0:= X"7712A036A56C";lO10IO1O:= X"18DD1EB21D5A";ll0O01OO:= X"6EA99B52753A";
              IlOl010O:= X"7D06358DCAC1";IIOl10O0:= X"109369714C33";IO0l01l0:= X"72827CC23D13";
              O10011OO:= X"0849B49935E7";OlIII0l1:= X"7847CEADB819";
      when "01100101" => 
              O0lOO0lI:= X"0169A3E73571";Ol01lOl0:= X"771F63E0528A";lO10IO1O:= X"18CB51D9A8E5";ll0O01OO:= X"6EB1E189CE5A";
              IlOl010O:= X"7D0A770A78E3";IIOl10O0:= X"10878ACCF366";IO0l01l0:= X"728AC37F000C";
              O10011OO:= X"0843C5473306";OlIII0l1:= X"7850156A8522";
      when "01100110" => 
              O0lOO0lI:= X"01669F533BCA";Ol01lOl0:= X"772C0D125420";lO10IO1O:= X"18B99D4135F4";ll0O01OO:= X"6EBA22621CE9";
              IlOl010O:= X"7D0EAF6C863B";IIOl10O0:= X"107BBD1C1709";IO0l01l0:= X"72930450D6EF";
              O10011OO:= X"083DDE6F0AFB";OlIII0l1:= X"7858563C3D5C";
      when "01100111" => 
              O0lOO0lI:= X"0163A362014A";Ol01lOl0:= X"77389AFD5518";lO10IO1O:= X"18A802403B1E";ll0O01OO:= X"6EC25D2AC38C";
              IlOl010O:= X"7D12DECDC323";IIOl10O0:= X"1070003ABB3F";IO0l01l0:= X"729B3F40095D";
              O10011OO:= X"0837FFFEA24C";OlIII0l1:= X"7860912B5197";
      when "01101000" => 
              O0lOO0lI:= X"0160AF8C5BE5";Ol01lOl0:= X"77450FA83F77";lO10IO1O:= X"18967E32D789";ll0O01OO:= X"6ECA930FD943";
              IlOl010O:= X"7D170547B468";IIOl10O0:= X"106454051DD1";IO0l01l0:= X"72A37454EC5E";
              O10011OO:= X"083229E410EE";OlIII0l1:= X"7868C64020A2";
      when "01101001" => 
              O0lOO0lI:= X"015DC4441498";Ol01lOl0:= X"77516901336C";lO10IO1O:= X"188514368E01";ll0O01OO:= X"6ED2C28B49A4";
              IlOl010O:= X"7D1B22F3A07D";IIOl10O0:= X"1058B8579350";IO0l01l0:= X"72ABA397FA95";
              O10011OO:= X"082C5C0DA18E";OlIII0l1:= X"7870F582F778";
      when "01101010" => 
              O0lOO0lI:= X"015AE16A3B78";Ol01lOl0:= X"775DA7576D6B";lO10IO1O:= X"1873C412F05C";ll0O01OO:= X"6EDAEBA5D82F";
              IlOl010O:= X"7D1F37EA25FF";IIOl10O0:= X"104D2D0FB352";IO0l01l0:= X"72B3CD10FFB3";
              O10011OO:= X"08269669D0EC";OlIII0l1:= X"78791EFC1170";
      when "01101011" => 
              O0lOO0lI:= X"01580681D965";Ol01lOl0:= X"7769CC8BEAA5";lO10IO1O:= X"18628B5401F1";ll0O01OO:= X"6EE30F7719D9";
              IlOl010O:= X"7D23444405CA";IIOl10O0:= X"1041B20A209A";IO0l01l0:= X"72BBF0C8A897";
              O10011OO:= X"0820D8E74D0B";OlIII0l1:= X"788142B39887";
      when "01101100" => 
              O0lOO0lI:= X"015533C156A6";Ol01lOl0:= X"7775D786F34A";lO10IO1O:= X"18516BB9B7CE";ll0O01OO:= X"6EEB2D1B2983";
              IlOl010O:= X"7D274819509F";IIOl10O0:= X"10364724DE08";IO0l01l0:= X"72C40EC6DD01";
              O10011OO:= X"081B2374F4A1";OlIII0l1:= X"788960B1A577";
      when "01101101" => 
              O0lOO0lI:= X"015268BCB7C1";Ol01lOl0:= X"7781C9E58574";lO10IO1O:= X"1840632B9C6B";ll0O01OO:= X"6EF3458041E7";
              IlOl010O:= X"7D2B4381CAFE";IIOl10O0:= X"102AEC3E37BA";IO0l01l0:= X"72CC27138346";
              O10011OO:= X"08157601D65E";OlIII0l1:= X"789178FE3FF5";
      when "01101110" => 
              O0lOO0lI:= X"014FA569B34C";Ol01lOl0:= X"778DA3A5A084";lO10IO1O:= X"182F71DD5EE5";ll0O01OO:= X"6EFB587E950A";
              IlOl010O:= X"7D2F36951617";IIOl10O0:= X"101FA1345010";IO0l01l0:= X"72D439B6D242";
              O10011OO:= X"080FD07D3053";OlIII0l1:= X"78998BA15ECE";
      when "01101111" => 
              O0lOO0lI:= X"014CEA42F5EC";Ol01lOl0:= X"77996288CCB9";lO10IO1O:= X"181E9B38CE5F";ll0O01OO:= X"6F0364649675";
              IlOl010O:= X"7D33216A4271";IIOl10O0:= X"101465E65A6D";IO0l01l0:= X"72DC46B86FD4";
              O10011OO:= X"080A32D66F2F";OlIII0l1:= X"78A198A2E83B";
      when "01110000" => 
              O0lOO0lI:= X"014A35E3C5C5";Ol01lOl0:= X"77A50C61273B";lO10IO1O:= X"180DD7147F34";ll0O01OO:= X"6F0B6D0A35DA";
              IlOl010O:= X"7D3704183919";IIOl10O0:= X"10093A33715E";IO0l01l0:= X"72E44E2044EB";
              O10011OO:= X"08049CFD2DC4";OlIII0l1:= X"78A9A00AB1EB";
      when "01110001" => 
              O0lOO0lI:= X"0147897D18A5";Ol01lOl0:= X"77B09BDF6C29";lO10IO1O:= X"17FD2D419958";ll0O01OO:= X"6F136EA1B5C6";
              IlOl010O:= X"7D3ADEB59CE9";IIOl10O0:= X"0FFE1DFAF04C";IO0l01l0:= X"72EC4FF63D18";
              O10011OO:= X"07FF0EE13445";OlIII0l1:= X"78B1A1E08141";
      when "01110010" => 
              O0lOO0lI:= X"0144E3F00C24";Ol01lOl0:= X"77BC15AFEC91";lO10IO1O:= X"17EC97336DD3";ll0O01OO:= X"6F1B6C417BB7";
              IlOl010O:= X"7D3EB1588D43";IIOl10O0:= X"0FF3111D26DD";IO0l01l0:= X"72F44C41C45D";
              O10011OO:= X"07F9887277BF";OlIII0l1:= X"78B99E2C0B7F";
      when "01110011" => 
              O0lOO0lI:= X"0142467987F2";Ol01lOl0:= X"77C7744715C5";lO10IO1O:= X"17DC1D1F9910";ll0O01OO:= X"6F2361E4A56E";
              IlOl010O:= X"7D427C172288";IIOl10O0:= X"0FE81379F448";IO0l01l0:= X"72FC430AC7BC";
              O10011OO:= X"07F409A1197A";OlIII0l1:= X"78C194F4F5EE";
      when "01110100" => 
              O0lOO0lI:= X"013FAFBCFE02";Ol01lOl0:= X"77D2BD63873E";lO10IO1O:= X"17CBB6E40820";ll0O01OO:= X"6F2B5368D257";
              IlOl010O:= X"7D463F07008E";IIOl10O0:= X"0FDD24F205C0";IO0l01l0:= X"73043458CED1";
              O10011OO:= X"07EE925D665B";OlIII0l1:= X"78C98642D613";
      when "01110101" => 
              O0lOO0lI:= X"013D203CB526";Ol01lOl0:= X"77DDEEA3C096";lO10IO1O:= X"17BB68234E78";ll0O01OO:= X"6F333EFD08E0";
              IlOl010O:= X"7D49FA3D7B40";IIOl10O0:= X"0FD245666FAC";IO0l01l0:= X"730C203344F3";
              O10011OO:= X"07E92297D651";OlIII0l1:= X"78D1721D31D5";
      when "01110110" => 
              O0lOO0lI:= X"013A9754D816";Ol01lOl0:= X"77E90AAAE3B5";lO10IO1O:= X"17AB2D3217AB";ll0O01OO:= X"6F3B265B6B56";
              IlOl010O:= X"7D4DADCFA7EB";IIOl10O0:= X"0FC774B87D75";IO0l01l0:= X"731406A19BA8";
              O10011OO:= X"07E3BA410BBD";OlIII0l1:= X"78D9588B7FB1";
      when "01110111" => 
              O0lOO0lI:= X"0138161D31EE";Ol01lOl0:= X"77F40C82E69E";lO10IO1O:= X"179B0D80920C";ll0O01OO:= X"6F4305D45856";
              IlOl010O:= X"7D5159D26CC7";IIOl10O0:= X"0FBCB2C985DA";IO0l01l0:= X"731BE7AB6A49";
              O10011OO:= X"07DE5949D2F7";OlIII0l1:= X"78E1399526C6";
      when "01111000" => 
              O0lOO0lI:= X"01359B5203FF";Ol01lOl0:= X"77FEF98FCC57";lO10IO1O:= X"178B0158BECA";ll0O01OO:= X"6F4AE11BD262";
              IlOl010O:= X"7D54FE5A3498";IIOl10O0:= X"0FB1FF7BCCED";IO0l01l0:= X"7323C357C7CE";
              O10011OO:= X"07D8FFA321A0";OlIII0l1:= X"78E915417F24";
      when "01111001" => 
              O0lOO0lI:= X"013327464289";Ol01lOl0:= X"7809D03CF28A";lO10IO1O:= X"177B0B37835C";ll0O01OO:= X"6F52B6EC7614";
              IlOl010O:= X"7D589B7B549B";IIOl10O0:= X"0FA75AB15BAC";IO0l01l0:= X"732B99AE2355";
              O10011OO:= X"07D3AD3E1634";OlIII0l1:= X"78F0EB97D1DC";
      when "01111010" => 
              O0lOO0lI:= X"0130B8F36917";Ol01lOl0:= X"781494EE49BE";lO10IO1O:= X"176B24CBC1E5";ll0O01OO:= X"6F5A8A54A287";
              IlOl010O:= X"7D5C3149DB55";IIOl10O0:= X"0F9CC44C91C9";IO0l01l0:= X"73336AB5D8F5";
              O10011OO:= X"07CE620BF75C";OlIII0l1:= X"78F8BC9F5943";
      when "01111011" => 
              O0lOO0lI:= X"012E51D08BD1";Ol01lOl0:= X"781F40FF85FD";lO10IO1O:= X"175B580ECDE6";ll0O01OO:= X"6F62565DC5AA";
              IlOl010O:= X"7D5FBFD96386";IIOl10O0:= X"0F923C30AD82";IO0l01l0:= X"733B3675CC72";
              O10011OO:= X"07C91DFE3395";OlIII0l1:= X"7900885F40EF";
      when "01111100" => 
              O0lOO0lI:= X"012BF15A9124";Ol01lOl0:= X"7829D68C3409";lO10IO1O:= X"174BA212AD9D";ll0O01OO:= X"6F6A1C6902FB";
              IlOl010O:= X"7D63473D7A94";IIOl10O0:= X"0F87C2409F1D";IO0l01l0:= X"7342FCF54687";
              O10011OO:= X"07C3E106607D";OlIII0l1:= X"79084EDEA60F";
      when "01111101" => 
              O0lOO0lI:= X"012997B9571D";Ol01lOl0:= X"783454B9296E";lO10IO1O:= X"173C044C40AC";ll0O01OO:= X"6F71DBAD6198";
              IlOl010O:= X"7D66C7895C4A";IIOl10O0:= X"0F7D565FD464";IO0l01l0:= X"734ABE3B5E32";
              O10011OO:= X"07BEAB163A73";OlIII0l1:= X"791010249767";
      when "01111110" => 
              O0lOO0lI:= X"0127435308A9";Ol01lOl0:= X"783EC2893FC8";lO10IO1O:= X"172C74723DF5";ll0O01OO:= X"6F79993968D6";
              IlOl010O:= X"7D6A40CFE76D";IIOl10O0:= X"0F72F8725D66";IO0l01l0:= X"73527A4EDC24";
              O10011OO:= X"07B97C1FA3F3";OlIII0l1:= X"7917CC3815A3";
      when "01111111" => 
              O0lOO0lI:= X"0124F56133D8";Ol01lOl0:= X"78491A5EA9D9";lO10IO1O:= X"171CFB0B1C7F";ll0O01OO:= X"6F8150C417FD";
              IlOl010O:= X"7D6DB323F25D";IIOl10O0:= X"0F68A85BF21C";IO0l01l0:= X"735A3136F4E9";
              O10011OO:= X"07B45414A541";OlIII0l1:= X"791F83201347";
      when "10000000" => 
              O0lOO0lI:= X"0122AE08BEB0";Ol01lOl0:= X"78535B6B8531";lO10IO1O:= X"170D99794E8A";ll0O01OO:= X"6F89018C6AD0";
              IlOl010O:= X"7D711E97F02E";IIOl10O0:= X"0F5E66010340";IO0l01l0:= X"7361E2FA7CF4";
              O10011OO:= X"07AF32E76BBE";OlIII0l1:= X"792734E3750C";
      when "10000001" => 
              O0lOO0lI:= X"01206CA13784";Ol01lOl0:= X"785D887FAC00";lO10IO1O:= X"16FE4BB09857";ll0O01OO:= X"6F90AD898F8D";
              IlOl010O:= X"7D74833E07B1";IIOl10O0:= X"0F5431467866";IO0l01l0:= X"73698FA0188F";
              O10011OO:= X"07AA188A4991";OlIII0l1:= X"792EE18911D9";
      when "10000010" => 
              O0lOO0lI:= X"011E3063ED2E";Ol01lOl0:= X"7867A4FBD2F4";lO10IO1O:= X"16EF0CBEB92D";ll0O01OO:= X"6F98572BF40E";
              IlOl010O:= X"7D77E12861B3";IIOl10O0:= X"0F4A0A10C614";IO0l01l0:= X"7371372EEB89";
              O10011OO:= X"07A504EFB51B";OlIII0l1:= X"79368917B301";
      when "10000011" => 
              O0lOO0lI:= X"011BFAD02768";Ol01lOl0:= X"7871A9F664CD";lO10IO1O:= X"16DFE738874C";ll0O01OO:= X"6F9FF9146EC4";
              IlOl010O:= X"7D7B38689513";IIOl10O0:= X"0F3FF045AD34";IO0l01l0:= X"7378D9AD47AA";
              O10011OO:= X"079FF80A487E";OlIII0l1:= X"793E2B961462";
      when "10000100" => 
              O0lOO0lI:= X"0119CAFBAA7E";Ol01lOl0:= X"787B9B6F949E";lO10IO1O:= X"16D0D53E0371";ll0O01OO:= X"6FA796293BB1";
              IlOl010O:= X"7D7E89105008";IIOl10O0:= X"0F35E3CA3E4E";IO0l01l0:= X"738077222BD0";
              O10011OO:= X"079AF1CCC135";OlIII0l1:= X"7945C90AE47E";
      when "10000101" => 
              O0lOO0lI:= X"0117A0B4C011";Ol01lOl0:= X"78857A27E596";lO10IO1O:= X"16C1D5D116E1";ll0O01OO:= X"6FAF2EDE4F9F";
              IlOl010O:= X"7D81D330CDB4";IIOl10O0:= X"0F2BE4847DA0";IO0l01l0:= X"73880F94060A";
              O10011OO:= X"0795F229FF90";OlIII0l1:= X"794D617CC4AE";
      when "10000110" => 
              O0lOO0lI:= X"01157C511981";Ol01lOl0:= X"788F4476274F";lO10IO1O:= X"16B2EB9F5C3A";ll0O01OO:= X"6FB6C1CAF638";
              IlOl010O:= X"7D8516DB5897";IIOl10O0:= X"0F21F259D907";IO0l01l0:= X"738FA309DE15";
              O10011OO:= X"0790F9150651";OlIII0l1:= X"7954F4F24930";
      when "10000111" => 
              O0lOO0lI:= X"01135D4C7530";Ol01lOl0:= X"7898FC9544E5";lO10IO1O:= X"16A413694BF3";ll0O01OO:= X"6FBE5088901B";
              IlOl010O:= X"7D8854208005";IIOl10O0:= X"0F180D319299";IO0l01l0:= X"739731897DC9";
              O10011OO:= X"078C0680FA25";OlIII0l1:= X"795C8371F96D";
      when "10001000" => 
              O0lOO0lI:= X"011143FA8E92";Ol01lOl0:= X"78A2A0E432E2";lO10IO1O:= X"16954FD221C6";ll0O01OO:= X"6FC5D9B256E9";
              IlOl010O:= X"7D8B8B11320E";IIOl10O0:= X"0F0E34F166D8";IO0l01l0:= X"739EBB19FE71";
              O10011OO:= X"07871A612158";OlIII0l1:= X"79640D024FE5";
      when "10001001" => 
              O0lOO0lI:= X"010F3019E8D8";Ol01lOl0:= X"78AC326E3141";lO10IO1O:= X"16869F6778B3";ll0O01OO:= X"6FCD5DF7F446";
              IlOl010O:= X"7D8EBBBDBE31";IIOl10O0:= X"0F046980938D";IO0l01l0:= X"73A63FC1790B";
              O10011OO:= X"078234A8E33E";OlIII0l1:= X"796B91A9BA8D";
      when "10001010" => 
              O0lOO0lI:= X"010D21630FFF";Ol01lOl0:= X"78B5B25CE84A";lO10IO1O:= X"1678008420C1";ll0O01OO:= X"6FD4DE250404";
              IlOl010O:= X"7D91E63670E7";IIOl10O0:= X"0EFAAAC5FDFC";IO0l01l0:= X"73ADBF866FBD";
              O10011OO:= X"077D554BC7F3";OlIII0l1:= X"7973116E9AB6";
      when "10001011" => 
              O0lOO0lI:= X"010B17F79C9D";Ol01lOl0:= X"78BF1FF6296E";lO10IO1O:= X"1669746A1B77";ll0O01OO:= X"6FDC5988786E";
              IlOl010O:= X"7D950A8B5503";IIOl10O0:= X"0EF0F8A8F41B";IO0l01l0:= X"73B53A6F39B1";
              O10011OO:= X"07787C3D77C9";OlIII0l1:= X"797A8C57455D";
      when "10001100" => 
              O0lOO0lI:= X"010913E0FFEB";Ol01lOl0:= X"78C87AEE464B";lO10IO1O:= X"165AFBB34ACA";ll0O01OO:= X"6FE3CFC65FEE";
              IlOl010O:= X"7D9828CC3BAB";IIOl10O0:= X"0EE753111628";IO0l01l0:= X"73BCB0821369";
              O10011OO:= X"0773A971BAFD";OlIII0l1:= X"7982026A032F";
      when "10001101" => 
              O0lOO0lI:= X"01071520A682";Ol01lOl0:= X"78D1C31E28DC";lO10IO1O:= X"164C96C248D5";ll0O01OO:= X"6FEB409E7528";
              IlOl010O:= X"7D9B4108B427";IIOl10O0:= X"0EDDB9E671CB";IO0l01l0:= X"73C421C50907";
              O10011OO:= X"076EDCDC7942";OlIII0l1:= X"798973AD10B1";
      when "10001110" => 
              O0lOO0lI:= X"01051B967666";Ol01lOl0:= X"78DAF8FB2FD1";lO10IO1O:= X"163E4506B145";ll0O01OO:= X"6FF2AC4E18BF";
              IlOl010O:= X"7D9E53505D53";IIOl10O0:= X"0ED42D1086D0";IO0l01l0:= X"73CB8E3EB901";
              O10011OO:= X"076A1671B958";OlIII0l1:= X"7990E0269E6E";
      when "10001111" => 
              O0lOO0lI:= X"010326BC63AA";Ol01lOl0:= X"78E41ED95CD5";lO10IO1O:= X"16300303731A";ll0O01OO:= X"6FFA1498DDD4";
              IlOl010O:= X"7DA15FB25800";IIOl10O0:= X"0ECAAC780021";IO0l01l0:= X"73D2F5F4FD70";
              O10011OO:= X"07655625A0C7";OlIII0l1:= X"799847DCD0E0";
      when "10010000" => 
              O0lOO0lI:= X"010137281749";Ol01lOl0:= X"78ED31DF07E7";lO10IO1O:= X"1621D54CA1A0";ll0O01OO:= X"70017711D518";
              IlOl010O:= X"7DA4663DAE05";IIOl10O0:= X"0EC1380575C5";IO0l01l0:= X"73DA58EDE21F";
              O10011OO:= X"07609BEC7344";OlIII0l1:= X"799FAAD5C0E9";
      when "10010001" => 
              O0lOO0lI:= X"00FF4C3F38E8";Ol01lOl0:= X"78F634C1E40E";lO10IO1O:= X"1613B7C942D4";ll0O01OO:= X"7008D5CF32BA";
              IlOl010O:= X"7DA7670161D0";IIOl10O0:= X"0EB7CFA13CC1";IO0l01l0:= X"73E1B72FCA7B";
              O10011OO:= X"075BE7BA928F";OlIII0l1:= X"79A709177B98";
      when "10010010" => 
              O0lOO0lI:= X"00FD66229CC8";Ol01lOl0:= X"78FF26CBBCAD";lO10IO1O:= X"1605ABB6FEAD";ll0O01OO:= X"701030204666";
              IlOl010O:= X"7DAA620BF4E0";IIOl10O0:= X"0EAE7334E4E6";IO0l01l0:= X"73E910C04647";
              O10011OO:= X"075739847DE3";OlIII0l1:= X"79AE62A80283";
      when "10010011" => 
              O0lOO0lI:= X"00FB8505A987";Ol01lOl0:= X"790806ECDE1C";lO10IO1O:= X"15F7B2E380F3";ll0O01OO:= X"701785070B72";
              IlOl010O:= X"7DAD576C11F0";IIOl10O0:= X"0EA522A9253C";IO0l01l0:= X"73F065A5B18E";
              O10011OO:= X"0752913ED1C1";OlIII0l1:= X"79B5B78D4BB5";
      when "10010100" => 
              O0lOO0lI:= X"00F9A87E179F";Ol01lOl0:= X"7910D6FE52C5";lO10IO1O:= X"15E9CA884BC8";ll0O01OO:= X"701ED5EC5163";
              IlOl010O:= X"7DB0473002DC";IIOl10O0:= X"0E9BDDE78E64";IO0l01l0:= X"73F7B5E5DFAC";
              O10011OO:= X"074DEEDE476D";OlIII0l1:= X"79BD07CD41F6";
      when "10010101" => 
              O0lOO0lI:= X"00F7D14D851D";Ol01lOl0:= X"7919934CE630";lO10IO1O:= X"15DBF8A13BC3";ll0O01OO:= X"70261F9CA5AF";
              IlOl010O:= X"7DB33165CA1A";IIOl10O0:= X"0E92A4DA3D69";IO0l01l0:= X"73FF01865666";
              O10011OO:= X"07495257B4AA";OlIII0l1:= X"79C4536DC4D8";
      when "10010110" => 
              O0lOO0lI:= X"00F5FE71036A";Ol01lOl0:= X"792240881AB0";lO10IO1O:= X"15CE35E821A0";ll0O01OO:= X"702D65E12911";
              IlOl010O:= X"7DB6161B818C";IIOl10O0:= X"0E89776AB0EE";IO0l01l0:= X"7406488D39FD";
              O10011OO:= X"0744BBA00B59";OlIII0l1:= X"79CB9A74A8D0";
      when "10010111" => 
              O0lOO0lI:= X"00F42F8CE39C";Ol01lOl0:= X"792AE04CB667";lO10IO1O:= X"15C07FE89532";ll0O01OO:= X"7034A9FDFBA0";
              IlOl010O:= X"7DB8F55F02C7";IIOl10O0:= X"0E805582DF50";IO0l01l0:= X"740D8B007160";
              O10011OO:= X"07402AAC5929";OlIII0l1:= X"79D2DCE7B742";
      when "10011000" => 
              O0lOO0lI:= X"00F265ABE72B";Ol01lOl0:= X"79336D876BDA";lO10IO1O:= X"15B2DED45D6A";ll0O01OO:= X"703BE7902448";
              IlOl010O:= X"7DBBCF3DD7B3";IIOl10O0:= X"0E773F0D69D1";IO0l01l0:= X"7414C8E57C5C";
              O10011OO:= X"073B9F71C733";OlIII0l1:= X"79DA1ACCAEC2";
      when "10011001" => 
              O0lOO0lI:= X"00F0A0070B58";Ol01lOl0:= X"793BEBD3B9DA";lO10IO1O:= X"15A54D0D932B";ll0O01OO:= X"704321873686";
              IlOl010O:= X"7DBEA3C57E81";IIOl10O0:= X"0E6E33F4C5F6";IO0l01l0:= X"741C02421DA3";
              O10011OO:= X"073719E599B3";OlIII0l1:= X"79E15429430A";
      when "10011010" => 
              O0lOO0lI:= X"00EEDF16B047";Ol01lOl0:= X"794458D5A15A";lO10IO1O:= X"1597CE79C3F4";ll0O01OO:= X"704A55C4424D";
              IlOl010O:= X"7DC173034302";IIOl10O0:= X"0E653423B9BD";IO0l01l0:= X"7423371BF7D1";
              O10011OO:= X"073299FD2F9F";OlIII0l1:= X"79E889031D37";
      when "10011011" => 
              O0lOO0lI:= X"00ED2213011E";Ol01lOl0:= X"794CB833C44B";lO10IO1O:= X"158A5D5E5C6B";ll0O01OO:= X"7051874BAAC8";
              IlOl010O:= X"7DC43D045EAF";IIOl10O0:= X"0E5C3F84F607";IO0l01l0:= X"742A6778DE58";
              O10011OO:= X"072E1FAE0270";OlIII0l1:= X"79EFB95FDBBD";
      when "10011100" => 
              O0lOO0lI:= X"00EB69CFDBA6";Ol01lOl0:= X"795505D7678D";lO10IO1O:= X"157D006BA726";ll0O01OO:= X"7058B27DA770";
              IlOl010O:= X"7DC701D5B72D";IIOl10O0:= X"0E535603EA5B";IO0l01l0:= X"7431935E2B38";
              O10011OO:= X"0729AAEDA5AF";OlIII0l1:= X"79F6E54512B2";
      when "10011101" => 
              O0lOO0lI:= X"00E9B59B2C8A";Ol01lOl0:= X"795D4501BA94";lO10IO1O:= X"156FB285310E";ll0O01OO:= X"705FDA0C46C3";
              IlOl010O:= X"7DC9C1842492";IIOl10O0:= X"0E4A778BE49D";IO0l01l0:= X"7438BAD17252";
              O10011OO:= X"07253BB1C6C7";OlIII0l1:= X"79FE0CB84BAA";
      when "10011110" => 
              O0lOO0lI:= X"00E8058FBC50";Ol01lOl0:= X"79657518B33D";lO10IO1O:= X"156274C0A5D2";ll0O01OO:= X"7066FD580775";
              IlOl010O:= X"7DCC7C1C546F";IIOl10O0:= X"0E41A4086F25";IO0l01l0:= X"743FDDD835C5";
              O10011OO:= X"0720D1F02C8E";OlIII0l1:= X"7A052FBF061A";
      when "10011111" => 
              O0lOO0lI:= X"00E659DDF92D";Ol01lOl0:= X"796D951781E5";lO10IO1O:= X"155548E37AD9";ll0O01OO:= X"706E1B60D985";
              IlOl010O:= X"7DCF31AAD09F";IIOl10O0:= X"0E38DB653BF1";IO0l01l0:= X"7446FC77F633";
              O10011OO:= X"071C6D9EB725";OlIII0l1:= X"7A0C4E5EB725";
      when "10100000" => 
              O0lOO0lI:= X"00E4B1F3B131";Ol01lOl0:= X"7975A7AD15FF";lO10IO1O:= X"15482AB10F62";ll0O01OO:= X"707536669AF3";
              IlOl010O:= X"7DD1E23BE3DE";IIOl10O0:= X"0E301D8E7F0C";IO0l01l0:= X"744E16B5E906";
              O10011OO:= X"07180EB35F7D";OlIII0l1:= X"7A13689CC9F6";
      when "10100001" => 
              O0lOO0lI:= X"00E30EE36063";Ol01lOl0:= X"797DA784755B";lO10IO1O:= X"153B22F537FB";ll0O01OO:= X"707C4998A5C8";
              IlOl010O:= X"7DD48DDBFE44";IIOl10O0:= X"0E276A6FA8CE";IO0l01l0:= X"74552C9800D7";
              O10011OO:= X"0713B5243728";OlIII0l1:= X"7A1A7E7E9FB0";
      when "10100010" => 
              O0lOO0lI:= X"00E16ED409C7";Ol01lOl0:= X"79859D8E13FE";lO10IO1O:= X"152E233BC0AC";ll0O01OO:= X"70835CC67F58";
              IlOl010O:= X"7DD7349705BD";IIOl10O0:= X"0E1EC1F5A243";IO0l01l0:= X"745C3E231B90";
              O10011OO:= X"070F60E76807";OlIII0l1:= X"7A2190098F91";
      when "10100011" => 
              O0lOO0lI:= X"00DFD31AEB54";Ol01lOl0:= X"798D832D0B3F";lO10IO1O:= X"15213669F93E";ll0O01OO:= X"708A69F9A3B8";
              IlOl010O:= X"7DD9D678E26D";IIOl10O0:= X"0E16240D05E2";IO0l01l0:= X"74634B5C73D9";
              O10011OO:= X"070B11F333F5";OlIII0l1:= X"7A289D42E720";
      when "10100100" => 
              O0lOO0lI:= X"00DE3B453AE2";Ol01lOl0:= X"79955A7BCC4A";lO10IO1O:= X"1514592E2DA1";ll0O01OO:= X"709172F5B14A";
              IlOl010O:= X"7DDC738D67A0";IIOl10O0:= X"0E0D90A26B23";IO0l01l0:= X"746A54496401";
              O10011OO:= X"0706C83DF48D";OlIII0l1:= X"7A2FA62FEA1B";
      when "10100101" => 
              O0lOO0lI:= X"00DCA75EFD1F";Ol01lOl0:= X"799D2327A3B1";lO10IO1O:= X"15078C2D1FD6";ll0O01OO:= X"70987755E129";
              IlOl010O:= X"7DDF0BE0558A";IIOl10O0:= X"0E0507A26135";IO0l01l0:= X"747158EF6A44";
              O10011OO:= X"070283BE1AE2";OlIII0l1:= X"7A36AAD5D2A8";
      when "10100110" => 
              O0lOO0lI:= X"00DB1732BA5E";Ol01lOl0:= X"79A4DE217389";lO10IO1O:= X"14FACDF6DE7B";ll0O01OO:= X"709F77D9A1C6";
              IlOl010O:= X"7DE19F7D14F8";IIOl10O0:= X"0DFC88FA50EC";IO0l01l0:= X"747859536EBA";
              O10011OO:= X"06FE446A2F21";OlIII0l1:= X"7A3DAB39D183";
      when "10100111" => 
              O0lOO0lI:= X"00D98AF02632";Ol01lOl0:= X"79AC8A663FAC";lO10IO1O:= X"14EE205303C1";ll0O01OO:= X"70A6737BFF39";
              IlOl010O:= X"7DE42E6F1893";IIOl10O0:= X"0DF414973E1B";IO0l01l0:= X"747F557AC8B8";
              O10011OO:= X"06FA0A38D06A";OlIII0l1:= X"7A44A7610DDC";
      when "10101000" => 
              O0lOO0lI:= X"00D801E4529D";Ol01lOl0:= X"79B42B58508B";lO10IO1O:= X"14E17DC30732";ll0O01OO:= X"70AD6D3B181F";
              IlOl010O:= X"7DE6B8C19497";IIOl10O0:= X"0DEBAA66B6B2";IO0l01l0:= X"74864D6A79BF";
              O10011OO:= X"06F5D520B474";OlIII0l1:= X"7A4B9F50A5A2";
      when "10101001" => 
              O0lOO0lI:= X"00D67D272541";Ol01lOl0:= X"79BBBB71F0EA";lO10IO1O:= X"14D4EF8934D1";ll0O01OO:= X"70B45FEF7A6C";
              IlOl010O:= X"7DE93E7FA27C";IIOl10O0:= X"0DE34A565E40";IO0l01l0:= X"748D41278CEF";
              O10011OO:= X"06F1A518A759";OlIII0l1:= X"7A52930DAD75";
      when "10101010" => 
              O0lOO0lI:= X"00D4FBFC832C";Ol01lOl0:= X"79C33E43A327";lO10IO1O:= X"14C86FD9EFC1";ll0O01OO:= X"70BB4EC1E2BA";
              IlOl010O:= X"7DEBBFB44143";IIOl10O0:= X"0DDAF453EDDB";IO0l01l0:= X"749430B7171E";
              O10011OO:= X"06ED7A178B43";OlIII0l1:= X"7A59829D30DF";
      when "10101011" => 
              O0lOO0lI:= X"00D37E1C6617";Ol01lOl0:= X"79CAB52112DA";lO10IO1O:= X"14BBFC980E31";ll0O01OO:= X"70C23AD62666";
              IlOl010O:= X"7DEE3C6A54A1";IIOl10O0:= X"0DD2A84D379B";IO0l01l0:= X"749B1C1E33A9";
              O10011OO:= X"06E95414583E";OlIII0l1:= X"7A606E04323C";
      when "10101100" => 
              O0lOO0lI:= X"00D20412E544";Ol01lOl0:= X"79D21D37A8A8";lO10IO1O:= X"14AF9A93E413";ll0O01OO:= X"70C921750833";
              IlOl010O:= X"7DF0B4AC834C";IIOl10O0:= X"0DCA66309859";IO0l01l0:= X"74A20361A530";
              O10011OO:= X"06E533061BDF";OlIII0l1:= X"7A675547AB0B";
      when "10101101" => 
              O0lOO0lI:= X"00D08D99C3FE";Ol01lOl0:= X"79D977D10365";lO10IO1O:= X"14A347C363A8";ll0O01OO:= X"70D003B639ED";
              IlOl010O:= X"7DF328858E3B";IIOl10O0:= X"0DC22DEBD4D2";IO0l01l0:= X"74A8E686C84F";
              O10011OO:= X"06E116E3F913";OlIII0l1:= X"7A6E386C8BCD";
      when "10101110" => 
              O0lOO0lI:= X"00CF1A263EA5";Ol01lOl0:= X"79E0C793BECC";lO10IO1O:= X"1496FFCC6B9A";ll0O01OO:= X"70D6E400192A";
              IlOl010O:= X"7DF597FFB79C";IIOl10O0:= X"0DB9FF6E1B53";IO0l01l0:= X"74AFC591E544";
              O10011OO:= X"06DCFFA527E2";OlIII0l1:= X"7A751777BC35";
      when "10101111" => 
              O0lOO0lI:= X"00CDAA53AF5F";Ol01lOl0:= X"79E8095D51EA";lO10IO1O:= X"148AC80B639A";ll0O01OO:= X"70DDBF4974F8";
              IlOl010O:= X"7DF803257D19";IIOl10O0:= X"0DB1DAA59464";IO0l01l0:= X"74B6A08839CA";
              O10011OO:= X"06D8ED40F51F";OlIII0l1:= X"7A7BF26E1B49";
      when "10110000" => 
              O0lOO0lI:= X"00CC3DDD5911";Ol01lOl0:= X"79EF3E73D124";lO10IO1O:= X"147E9E7635AF";ll0O01OO:= X"70E496AD0AFD";
              IlOl010O:= X"7DFA6A012B5C";IIOl10O0:= X"0DA9BF80CEC0";IO0l01l0:= X"74BD776EC859";
              O10011OO:= X"06D4DFAEC240";OlIII0l1:= X"7A82C9547F4E";
      when "10110001" => 
              O0lOO0lI:= X"00CAD50C2B7C";Ol01lOl0:= X"79F665506675";lO10IO1O:= X"147285BC5242";ll0O01OO:= X"70EB689D4769";
              IlOl010O:= X"7DFCCC9CB726";IIOl10O0:= X"0DA1ADEF44D9";IO0l01l0:= X"74C44A49E60D";
              O10011OO:= X"06D0D6E6051D";OlIII0l1:= X"7A899C2FB5F6";
      when "10110010" => 
              O0lOO0lI:= X"00C96F76FA0A";Ol01lOl0:= X"79FD7FF3FC38";lO10IO1O:= X"14667A94D560";ll0O01OO:= X"70F236E9FFC5";
              IlOl010O:= X"7DFF2B025593";IIOl10O0:= X"0D99A5DF5B20";IO0l01l0:= X"74CB191EEC9B";
              O10011OO:= X"06CCD2DE479B";OlIII0l1:= X"7A906B048489";
      when "10110011" => 
              O0lOO0lI:= X"00C80CEDE0C1";Ol01lOl0:= X"7A048F3FB367";lO10IO1O:= X"145A7B98F654";ll0O01OO:= X"70F90255C2A3";
              IlOl010O:= X"7E01853BCC7E";IIOl10O0:= X"0D91A740B2D3";IO0l01l0:= X"74D1E3F242EF";
              O10011OO:= X"06C8D38F279A";OlIII0l1:= X"7A9735D7A7C8";
      when "10110100" => 
              O0lOO0lI:= X"00C6ADC1A3F6";Ol01lOl0:= X"7A0B9184C8AD";lO10IO1O:= X"144E8BBCB755";ll0O01OO:= X"70FFC92B7049";
              IlOl010O:= X"7E03DB52CBB0";IIOl10O0:= X"0D89B202FDF2";IO0l01l0:= X"74D8AAC85A1D";
              O10011OO:= X"06C4D8F0568A";OlIII0l1:= X"7A9DFCADD440";
      when "10110101" => 
              O0lOO0lI:= X"00C551960481";Ol01lOl0:= X"7A1288878868";lO10IO1O:= X"1442A815EF99";ll0O01OO:= X"71068D099899";
              IlOl010O:= X"7E062D512694";IIOl10O0:= X"0D81C6153A95";IO0l01l0:= X"74DF6DA65542";
              O10011OO:= X"06C0E2F9996E";OlIII0l1:= X"7AA4BF8BB605";
      when "10110110" => 
              O0lOO0lI:= X"00C3F926BF46";Ol01lOl0:= X"7A197071ADED";lO10IO1O:= X"1436D74CD185";ll0O01OO:= X"710D4A1B8D9E";
              IlOl010O:= X"7E087B404FA6";IIOl10O0:= X"0D79E367778A";IO0l01l0:= X"74E62C9087D1";
              O10011OO:= X"06BCF1A2C866";OlIII0l1:= X"7AAB7E75F129";
      when "10110111" => 
              O0lOO0lI:= X"00C2A31CDF59";Ol01lOl0:= X"7A2050119FC0";lO10IO1O:= X"142B0DD2D0E7";ll0O01OO:= X"711406F05637";
              IlOl010O:= X"7E0AC529D9A5";IIOl10O0:= X"0D7209E91C4D";IO0l01l0:= X"74ECE78BEC8C";
              O10011OO:= X"06B904E3CE9D";OlIII0l1:= X"7AB239712188";
      when "10111000" => 
              O0lOO0lI:= X"00C150C89142";Ol01lOl0:= X"7A2720938D94";lO10IO1O:= X"141F5774A291";ll0O01OO:= X"711ABCC06B23";
              IlOl010O:= X"7E0D0B16EE09";IIOl10O0:= X"0D6A398AC0DA";IO0l01l0:= X"74F39E9C9166";
              O10011OO:= X"06B51CB4AA07";OlIII0l1:= X"7AB8F081DAF9";
      when "10111001" => 
              O0lOO0lI:= X"00C0013055DE";Ol01lOl0:= X"7A2DE6EA619F";lO10IO1O:= X"1413ABCA6D52";ll0O01OO:= X"712170527A1D";
              IlOl010O:= X"7E0F4D10ED6A";IIOl10O0:= X"0D62723C084A";IO0l01l0:= X"74FA51C76E64";
              O10011OO:= X"06B1390D6B2B";OlIII0l1:= X"7ABFA3ACA95A";
      when "10111010" => 
              O0lOO0lI:= X"00BEB4D35C17";Ol01lOl0:= X"7A34A072E0E4";lO10IO1O:= X"14080F767340";ll0O01OO:= X"71281EF49AE7";
              IlOl010O:= X"7E118B20DFE9";IIOl10O0:= X"0D5AB3ED8ED7";IO0l01l0:= X"75010110BCFB";
              O10011OO:= X"06AD59E634EA";OlIII0l1:= X"7AC652F610A2";
      when "10111011" => 
              O0lOO0lI:= X"00BD6B2FDE42";Ol01lOl0:= X"7A3B4FBBB02E";lO10IO1O:= X"13FC7E24E6B2";ll0O01OO:= X"712ECB1BEA7E";
              IlOl010O:= X"7E13C54FE71A";IIOl10O0:= X"0D52FE8F6294";IO0l01l0:= X"7507AC7D48BC";
              O10011OO:= X"06A97F373C55";OlIII0l1:= X"7ACCFE628CEC";
      when "10111100" => 
              O0lOO0lI:= X"00BC24DA2BAC";Ol01lOl0:= X"7A41F1B07647";lO10IO1O:= X"13F0FD4222D7";ll0O01OO:= X"7135719E194D";
              IlOl010O:= X"7E15FBA6E7CB";IIOl10O0:= X"0D4B52122D71";IO0l01l0:= X"750E54116E08";
              O10011OO:= X"06A5A8F8C864";OlIII0l1:= X"7AD3A5F692A6";
      when "10111101" => 
              O0lOO0lI:= X"00BAE1083759";Ol01lOl0:= X"7A488A5B4707";lO10IO1O:= X"13E585E2E156";ll0O01OO:= X"713C1672C352";
              IlOl010O:= X"7E182E2EAF87";IIOl10O0:= X"0D43AE66B4EE";IO0l01l0:= X"7514F7D1884A";
              O10011OO:= X"06A1D72331D9";OlIII0l1:= X"7ADA49B68E7A";
      when "10111110" => 
              O0lOO0lI:= X"00B9A013FBFB";Ol01lOl0:= X"7A4F17D770B1";lO10IO1O:= X"13DA1B64F670";ll0O01OO:= X"7142B79FC28C";
              IlOl010O:= X"7E1A5CEFFF45";IIOl10O0:= X"0D3C137DB58B";IO0l01l0:= X"751B97C21193";
              O10011OO:= X"069E09AEE301";OlIII0l1:= X"7AE0E9A6E579";
      when "10111111" => 
              O0lOO0lI:= X"00B86285D1E2";Ol01lOl0:= X"7A55974898AB";lO10IO1O:= X"13CEC2DF2689";ll0O01OO:= X"714952254C29";
              IlOl010O:= X"7E1C87F34FFE";IIOl10O0:= X"0D348148B2E0";IO0l01l0:= X"752233E6ECE7";
              O10011OO:= X"069A40945786";OlIII0l1:= X"7AE785CBF52D";
      when "11000000" => 
              O0lOO0lI:= X"00B7270A3725";Ol01lOl0:= X"7A5C0F91504F";lO10IO1O:= X"13C370601458";ll0O01OO:= X"714FECEF6AE6";
              IlOl010O:= X"7E1EAF416E8F";IIOl10O0:= X"0D2CF7B7D7D3";IO0l01l0:= X"7528CC4540C6";
              O10011OO:= X"06967BCC1C37";OlIII0l1:= X"7AEE1E2A1397";
      when "11000001" => 
              O0lOO0lI:= X"00B5EF1E8467";Ol01lOl0:= X"7A6278CE53FC";lO10IO1O:= X"13B831CC2E07";ll0O01OO:= X"71567FDA9607";
              IlOl010O:= X"7E20D2E2A290";IIOl10O0:= X"0D2576BCEDFC";IO0l01l0:= X"752F60E0DFDC";
              O10011OO:= X"0692BB4ECEDF";OlIII0l1:= X"7AF4B2C58F60";
      when "11000010" => 
              O0lOO0lI:= X"00B4B98AEE60";Ol01lOl0:= X"7A68D95647EB";lO10IO1O:= X"13ACFC1D9D08";ll0O01OO:= X"715D114EBAC8";
              IlOl010O:= X"7E22F2DF4B64";IIOl10O0:= X"0D1DFE4939B8";IO0l01l0:= X"7535F1BE270A";
              O10011OO:= X"068EFF151E12";OlIII0l1:= X"7AFB43A2AFC5";
      when "11000011" => 
              O0lOO0lI:= X"00B386E970BC";Ol01lOl0:= X"7A6F2DED6C22";lO10IO1O:= X"13A1D517D04E";ll0O01OO:= X"71639DE3A060";
              IlOl010O:= X"7E250F3F8F44";IIOl10O0:= X"0D168E4E96A7";IO0l01l0:= X"753C7EE1041B";
              O10011OO:= X"068B4717C8FB";OlIII0l1:= X"7B01D0C5B4C5";
      when "11000100" => 
              O0lOO0lI:= X"00B25730EFEF";Ol01lOl0:= X"7A7576B1B1AD";lO10IO1O:= X"1396BC9EE6DD";ll0O01OO:= X"716A259F42BC";
              IlOl010O:= X"7E27280BC277";IIOl10O0:= X"0D0F26BE0CB5";IO0l01l0:= X"7543084E34FA";
              O10011OO:= X"0687934F9F32";OlIII0l1:= X"7B085A32D71B";
      when "11000101" => 
              O0lOO0lI:= X"00B129A3E9E4";Ol01lOl0:= X"7A7BB780446A";lO10IO1O:= X"138BABF3144D";ll0O01OO:= X"7170AC73B236";
              IlOl010O:= X"7E293D4BDA27";IIOl10O0:= X"0D07C789C29B";IO0l01l0:= X"75498E099042";
              O10011OO:= X"0683E3B5807B";OlIII0l1:= X"7B0EDFEE4880";
      when "11000110" => 
              O0lOO0lI:= X"00AFFEF6C192";Ol01lOl0:= X"7A81EC8CB146";lO10IO1O:= X"1380A9E05836";ll0O01OO:= X"71772E576EF7";
              IlOl010O:= X"7E2B4F07EE4B";IIOl10O0:= X"0D0070A333A9";IO0l01l0:= X"75501017996C";
              O10011OO:= X"068038425CC6";OlIII0l1:= X"7B1561FC3355";
      when "11000111" => 
              O0lOO0lI:= X"00AED68FEEFA";Ol01lOl0:= X"7A8818F89749";lO10IO1O:= X"1375B0ED098F";ll0O01OO:= X"717DAE7F670D";
              IlOl010O:= X"7E2D5D47C9F4";IIOl10O0:= X"0CF921FCBC26";IO0l01l0:= X"75568E7C21B9";
              O10011OO:= X"067C90EF33CF";OlIII0l1:= X"7B1BE060BB1D";
      when "11001000" => 
              O0lOO0lI:= X"00ADB0C73C4C";Ol01lOl0:= X"7A8E3AE19411";lO10IO1O:= X"136AC484F5CC";ll0O01OO:= X"71842ADDEE1B";
              IlOl010O:= X"7E2F68134EAC";IIOl10O0:= X"0CF1DB883974";IO0l01l0:= X"755D093B7FE4";
              O10011OO:= X"0678EDB51507";OlIII0l1:= X"7B225B1FFC5E";
      when "11001001" => 
              O0lOO0lI:= X"00AC8E5FD79F";Ol01lOl0:= X"7A944E21566A";lO10IO1O:= X"135FEC27E89A";ll0O01OO:= X"718A9EF2DDFF";
              IlOl010O:= X"7E316F722966";IIOl10O0:= X"0CEA9D381577";IO0l01l0:= X"75638059A27A";
              O10011OO:= X"06754E8D1F73";OlIII0l1:= X"7B28D23E0CA6";
      when "11001010" => 
              O0lOO0lI:= X"00AB6DD78A0D";Ol01lOl0:= X"7A9A5ABC62EF";lO10IO1O:= X"1355199B46F6";ll0O01OO:= X"7191132D0AB8";
              IlOl010O:= X"7E33736C0A83";IIOl10O0:= X"0CE366FE7FAF";IO0l01l0:= X"7569F3DAC0A4";
              O10011OO:= X"0671B370815E";OlIII0l1:= X"7B2F45BEFACF";
      when "11001011" => 
              O0lOO0lI:= X"00AA5014B760";Ol01lOl0:= X"7AA05BD0D2C3";lO10IO1O:= X"134A55AC5E61";ll0O01OO:= X"719782467B9D";
              IlOl010O:= X"7E3574086C81";IIOl10O0:= X"0CDC38CE3AD4";IO0l01l0:= X"757063C2A239";
              O10011OO:= X"066E1C58785B";OlIII0l1:= X"7B35B5A6CEC2";
      when "11001100" => 
              O0lOO0lI:= X"00A93477DE34";Ol01lOl0:= X"7AA654A9EEA7";lO10IO1O:= X"133F9A86D0A0";ll0O01OO:= X"719DEFB36638";
              IlOl010O:= X"7E37714ECB4F";IIOl10O0:= X"0CD51299D789";IO0l01l0:= X"7576D0154FF3";
              O10011OO:= X"066A893E50FD";OlIII0l1:= X"7B3C21F989B7";
      when "11001101" => 
              O0lOO0lI:= X"00A81BC6E235";Ol01lOl0:= X"7AAC410D7AD1";lO10IO1O:= X"1334EFD87233";ll0O01OO:= X"71A456D19F4E";
              IlOl010O:= X"7E396B4696E8";IIOl10O0:= X"0CCDF453E4A6";IO0l01l0:= X"757D38D6E838";
              O10011OO:= X"0666FA1B66C0";OlIII0l1:= X"7B428ABB2635";
      when "11001110" => 
              O0lOO0lI:= X"00A7050E3697";Ol01lOl0:= X"7AB22610A80C";lO10IO1O:= X"132A4C8DB6B1";ll0O01OO:= X"71AABD0C11EC";
              IlOl010O:= X"7E3B61F723F7";IIOl10O0:= X"0CC6DDEF26C4";IO0l01l0:= X"75839E0B6D4A";
              O10011OO:= X"06636EE923B9";OlIII0l1:= X"7B48EFEF9844";
      when "11001111" => 
              O0lOO0lI:= X"00A5F0F8AD7F";Ol01lOl0:= X"7AB80008EA94";lO10IO1O:= X"131FB7569EF3";ll0O01OO:= X"71B11E55D3FA";
              IlOl010O:= X"7E3D55679FD4";IIOl10O0:= X"0CBFCF5EC4E9";IO0l01l0:= X"7589FFB69C1F";
              O10011OO:= X"065FE7A100A7";OlIII0l1:= X"7B4F519ACD3B";
      when "11010000" => 
              O0lOO0lI:= X"00A4DF3CA0D6";Ol01lOl0:= X"7ABDD076C270";lO10IO1O:= X"13152D909A6F";ll0O01OO:= X"71B77C3CE831";
              IlOl010O:= X"7E3F459F44FF";IIOl10O0:= X"0CB8C8958B49";IO0l01l0:= X"75905DDC9757";
              O10011OO:= X"065C643C84A9";OlIII0l1:= X"7B55AFC0ABF1";
      when "11010001" => 
              O0lOO0lI:= X"00A3CFA47C8A";Ol01lOl0:= X"7AC39870538F";lO10IO1O:= X"130AAD55059D";ll0O01OO:= X"71BDD7E0A108";
              IlOl010O:= X"7E4132A51583";IIOl10O0:= X"0CB1C986E7C6";IO0l01l0:= X"7596B8810273";
              O10011OO:= X"0658E4B54509";OlIII0l1:= X"7B5C0A6514E6";
      when "11010010" => 
              O0lOO0lI:= X"00A2C28FC913";Ol01lOl0:= X"7AC955DF1DC2";lO10IO1O:= X"13003A81AB20";ll0O01OO:= X"71C42EE21A51";
              IlOl010O:= X"7E431C8030B4";IIOl10O0:= X"0CAAD225B3AD";IO0l01l0:= X"759D0FA81B29";
              O10011OO:= X"06556904E52B";OlIII0l1:= X"7B62618BE23B";
      when "11010011" => 
              O0lOO0lI:= X"00A1B78A3475";Ol01lOl0:= X"7ACF0B30B6C7";lO10IO1O:= X"12F5D0BD9009";ll0O01OO:= X"71CA83DD42C9";
              IlOl010O:= X"7E4503374F4B";IIOl10O0:= X"0CA3E26613E3";IO0l01l0:= X"75A363550453";
              O10011OO:= X"0651F1251680";OlIII0l1:= X"7B68B538E778";
      when "11010100" => 
              O0lOO0lI:= X"00A0AF940268";Ol01lOl0:= X"7AD4B2DA4298";lO10IO1O:= X"12EB7A3CB6A2";ll0O01OO:= X"71D0D09331F6";
              IlOl010O:= X"7E46E6D17806";IIOl10O0:= X"0C9CFA3AE7CE";IO0l01l0:= X"75A9B38C1C1C";
              O10011OO:= X"064E7D0F981B";OlIII0l1:= X"7B6F056FF22A";
      when "11010101" => 
              O0lOO0lI:= X"009FA91C85F6";Ol01lOl0:= X"7ADA5563EB0B";lO10IO1O:= X"12E127784BAF";ll0O01OO:= X"71D71E72D05D";
              IlOl010O:= X"7E48C7556CEE";IIOl10O0:= X"0C961997E035";IO0l01l0:= X"75B0005114B5";
              O10011OO:= X"064B0CBE36C3";OlIII0l1:= X"7B755234C98F";
      when "11010110" => 
              O0lOO0lI:= X"009EA54974B5";Ol01lOl0:= X"7ADFEC733E92";lO10IO1O:= X"12D6E4243483";ll0O01OO:= X"71DD6650718E";
              IlOl010O:= X"7E4AA4C9DEE1";IIOl10O0:= X"0C8F4070C481";IO0l01l0:= X"75B649A79DE3";
              O10011OO:= X"0647A02ACCC1";OlIII0l1:= X"7B7B9B8B2EA9";
      when "11010111" => 
              O0lOO0lI:= X"009DA31D3E16";Ol01lOl0:= X"7AE57D704217";lO10IO1O:= X"12CCA664704B";ll0O01OO:= X"71E3AE2E125C";
              IlOl010O:= X"7E4C7F354F6C";IIOl10O0:= X"0C886EB9E226";IO0l01l0:= X"75BC8F92FE6C";
              O10011OO:= X"0644374F41B0";OlIII0l1:= X"7B81E176DC61";
      when "11011000" => 
              O0lOO0lI:= X"009CA344A4DF";Ol01lOl0:= X"7AEB04960F20";lO10IO1O:= X"12C275371444";ll0O01OO:= X"71E9F1BC7F25";
              IlOl010O:= X"7E4E569E91C4";IIOl10O0:= X"0C81A4663259";IO0l01l0:= X"75C2D217C84F";
              O10011OO:= X"0640D2258A6F";OlIII0l1:= X"7B8823FB8787";
      when "11011001" => 
              O0lOO0lI:= X"009BA5B91C74";Ol01lOl0:= X"7AF081FA6058";lO10IO1O:= X"12B85088C9B2";ll0O01OO:= X"71F030FE8E6B";
              IlOl010O:= X"7E502B0C08EF";IIOl10O0:= X"0C7AE16A23CA";IO0l01l0:= X"75C911394836";
              O10011OO:= X"063D70A7A8D6";OlIII0l1:= X"7B8E631CDF07";
      when "11011010" => 
              O0lOO0lI:= X"009AAA9C3927";Ol01lOl0:= X"7AF5F4D4587B";lO10IO1O:= X"12AE39E1FAEB";ll0O01OO:= X"71F66AF91D5F";
              IlOl010O:= X"7E51FC840DD1";IIOl10O0:= X"0C7425BA2494";IO0l01l0:= X"75CF4CFADC77";
              O10011OO:= X"063A12CFABC7";OlIII0l1:= X"7B949EDE8BA2";
      when "11011011" => 
              O0lOO0lI:= X"0099B176F077";Ol01lOl0:= X"7AFB5FABCE5A";lO10IO1O:= X"12A42CA60FA0";ll0O01OO:= X"71FCA27CC654";
              IlOl010O:= X"7E53CB0D1BF7";IIOl10O0:= X"0C6D7149FBF4";IO0l01l0:= X"75D585608FBB";
              O10011OO:= X"0636B897AED9";OlIII0l1:= X"7B9AD7443061";
      when "11011100" => 
              O0lOO0lI:= X"0098BA58A981";Ol01lOl0:= X"7B00C21F5028";lO10IO1O:= X"129A2999B9A1";ll0O01OO:= X"7202D709A997";
              IlOl010O:= X"7E5596AD6469";IIOl10O0:= X"0C66C40E5F97";IO0l01l0:= X"75DBBA6DA129";
              O10011OO:= X"063361F9DA59";OlIII0l1:= X"7BA10C516A56";
      when "11011101" => 
              O0lOO0lI:= X"0097C4D8B39C";Ol01lOl0:= X"7B061E6CBE6D";lO10IO1O:= X"12902C9EE4FA";ll0O01OO:= X"72090B28A3B8";
              IlOl010O:= X"7E575F6B5199";IIOl10O0:= X"0C601DFB09C0";IO0l01l0:= X"75E1EC264B46";
              O10011OO:= X"06300EF06322";OlIII0l1:= X"7BA73E09D0B0";
      when "11011110" => 
              O0lOO0lI:= X"0096D1E2AB21";Ol01lOl0:= X"7B0B6F625A5B";lO10IO1O:= X"12863F753562";ll0O01OO:= X"720F38C419C5";
              IlOl010O:= X"7E59254CD230";IIOl10O0:= X"0C597F055CA7";IO0l01l0:= X"75E81A8D4F1B";
              O10011OO:= X"062CBF758A62";OlIII0l1:= X"7BAD6C70F502";
      when "11011111" => 
              O0lOO0lI:= X"0095E072AEB6";Ol01lOl0:= X"7B10BAA3DA4D";lO10IO1O:= X"127C57A5B8CD";ll0O01OO:= X"721566588CE0";
              IlOl010O:= X"7E5AE85843AF";IIOl10O0:= X"0C52E720F810";IO0l01l0:= X"75EE45A72309";
              O10011OO:= X"062973839D9D";OlIII0l1:= X"7BB3978A6301";
      when "11100000" => 
              O0lOO0lI:= X"0094F1AF62F5";Ol01lOl0:= X"7B15F9AE516D";lO10IO1O:= X"127281721B33";ll0O01OO:= X"721B8C38E369";
              IlOl010O:= X"7E5CA8936743";IIOl10O0:= X"0C4C56439FCF";IO0l01l0:= X"75F46D764E36";
              O10011OO:= X"06262B14F66E";OlIII0l1:= X"7BB9BF59A0D2";
      when "11100001" => 
              O0lOO0lI:= X"0094048CCC9F";Ol01lOl0:= X"7B1B3257E959";lO10IO1O:= X"1268B1FC02B6";ll0O01OO:= X"7221B1279649";
              IlOl010O:= X"7E5E6604649C";IIOl10O0:= X"0C45CC617407";IO0l01l0:= X"75FA91FEF14E";
              O10011OO:= X"0622E623FA7C";OlIII0l1:= X"7BBFE3E22EEC";
      when "11100010" => 
              O0lOO0lI:= X"009319ABA926";Ol01lOl0:= X"7B20610AE62F";lO10IO1O:= X"125EF0102FB0";ll0O01OO:= X"7227D0DB99FD";
              IlOl010O:= X"7E6020B10F57";IIOl10O0:= X"0C3F496FAC7F";IO0l01l0:= X"7600B34437A1";
              O10011OO:= X"061FA4AB1B56";OlIII0l1:= X"7BC605278829";
      when "11100011" => 
              O0lOO0lI:= X"00923046EEE5";Ol01lOl0:= X"7B258A1574F3";lO10IO1O:= X"125533A23948";ll0O01OO:= X"722DF05C3CCC";
              IlOl010O:= X"7E61D89F501A";IIOl10O0:= X"0C38CD630EBA";IO0l01l0:= X"7606D149C867";
              O10011OO:= X"061C66A4D644";OlIII0l1:= X"7BCC232D21F1";
      when "11100100" => 
              O0lOO0lI:= X"00914966D4BA";Ol01lOl0:= X"7B2AA7939403";lO10IO1O:= X"124B87E175E4";ll0O01OO:= X"72340898BC9B";
              IlOl010O:= X"7E638DD5029F";IIOl10O0:= X"0C3258306D5C";IO0l01l0:= X"760CEC134F7B";
              O10011OO:= X"06192C0BB442";OlIII0l1:= X"7BD23DF66C0D";
      when "11100101" => 
              O0lOO0lI:= X"009063608862";Ol01lOl0:= X"7B2FC2F121ED";lO10IO1O:= X"1241DB098C7C";ll0O01OO:= X"723A24BFA08B";
              IlOl010O:= X"7E654057BF50";IIOl10O0:= X"0C2BE9CD771D";IO0l01l0:= X"761303A3B8D9";
              O10011OO:= X"0615F4DA49BD";OlIII0l1:= X"7BD85586D10A";
      when "11100110" => 
              O0lOO0lI:= X"008F8049C666";Ol01lOl0:= X"7B34D048A0BA";lO10IO1O:= X"123843B58A8D";ll0O01OO:= X"72403682CE6E";
              IlOl010O:= X"7E66F02D3CB3";IIOl10O0:= X"0C25822F46EF";IO0l01l0:= X"761917FE8C30";
              O10011OO:= X"0612C10B36A5";OlIII0l1:= X"7BDE69E1B5D2";
      when "11100111" => 
              O0lOO0lI:= X"008E9E98BCE8";Ol01lOl0:= X"7B39D84F9E99";lO10IO1O:= X"122EB170CEEE";ll0O01OO:= X"72464842C6F3";
              IlOl010O:= X"7E689D5B1EBC";IIOl10O0:= X"0C1F214B1C0A";IO0l01l0:= X"761F29273F0C";
              O10011OO:= X"060F9099261C";OlIII0l1:= X"7BE47B0A7A2C";
      when "11101000" => 
              O0lOO0lI:= X"008DBF3D0ABF";Ol01lOl0:= X"7B3ED5A2FDF8";lO10IO1O:= X"12252E8BB04B";ll0O01OO:= X"724C536DF56F";
              IlOl010O:= X"7E6A47E704A5";IIOl10O0:= X"0C18C71625D0";IO0l01l0:= X"762537216647";
              O10011OO:= X"060C637ECE89";OlIII0l1:= X"7BEA8904785A";
      when "11101001" => 
              O0lOO0lI:= X"008CE10BD78A";Ol01lOl0:= X"7B43CEE5E650";lO10IO1O:= X"121BAE6CBB77";ll0O01OO:= X"725260009245";
              IlOl010O:= X"7E6BEFD65904";IIOl10O0:= X"0C1273863ADC";IO0l01l0:= X"762B41F00754";
              O10011OO:= X"060939B6F147";OlIII0l1:= X"7BF093D30590";
      when "11101010" => 
              O0lOO0lI:= X"008C053BA1FF";Ol01lOl0:= X"7B48BD1A31C9";lO10IO1O:= X"12123E7EF7D3";ll0O01OO:= X"72586568DC0D";
              IlOl010O:= X"7E6D952E91BB";IIOl10O0:= X"0C0C2690E64E";IO0l01l0:= X"763149967EE3";
              O10011OO:= X"0606133C5AC7";OlIII0l1:= X"7BF69B797193";
      when "11101011" => 
              O0lOO0lI:= X"008B2A8BA24F";Ol01lOl0:= X"7B4DA767C3B8";lO10IO1O:= X"1208D11E3310";ll0O01OO:= X"725E6C552FAC";
              IlOl010O:= X"7E6F37F51C72";IIOl10O0:= X"0C05E02BB1E7";IO0l01l0:= X"76374E183AD0";
              O10011OO:= X"0602F009E227";OlIII0l1:= X"7BFC9FFB0733";
      when "11101100" => 
              O0lOO0lI:= X"008A51AD6F81";Ol01lOl0:= X"7B5289C8CB95";lO10IO1O:= X"11FF6E0BC172";ll0O01OO:= X"72646FCD0E31";
              IlOl010O:= X"7E70D82F3BF2";IIOl10O0:= X"0BFFA04CABBE";IO0l01l0:= X"763D4F78396C";
              O10011OO:= X"05FFD01A6962";OlIII0l1:= X"7C02A15B0BE8";
      when "11101101" => 
              O0lOO0lI:= X"00897B1251A9";Ol01lOl0:= X"7B5761A2D48D";lO10IO1O:= X"11F61A5CFE48";ll0O01OO:= X"726A6C84E710";
              IlOl010O:= X"7E7275E24C0B";IIOl10O0:= X"0BF966E961D8";IO0l01l0:= X"76434DBA033E";
              O10011OO:= X"05FCB368DD06";OlIII0l1:= X"7C089F9CC02B";
      when "11101110" => 
              O0lOO0lI:= X"0088A5D84684";Ol01lOl0:= X"7B5C3404AF4C";lO10IO1O:= X"11ECCC645C66";ll0O01OO:= X"727068AC1D13";
              IlOl010O:= X"7E7411136BD8";IIOl10O0:= X"0BF333F82C7A";IO0l01l0:= X"764948E06D57";
              O10011OO:= X"05F999F03417";OlIII0l1:= X"7C0E9AC35F6F";
      when "11101111" => 
              O0lOO0lI:= X"0087D26C1E21";Ol01lOl0:= X"7B60FE6F3569";lO10IO1O:= X"11E389000766";ll0O01OO:= X"7276611C1660";
              IlOl010O:= X"7E75A9C7F31F";IIOl10O0:= X"0BED076E69ED";IO0l01l0:= X"764F40EF4CFC";
              O10011OO:= X"05F683AB7011";OlIII0l1:= X"7C1492D22014";
      when "11110000" => 
              O0lOO0lI:= X"008700B15B7B";Ol01lOl0:= X"7B65C17D04EE";lO10IO1O:= X"11DA4F14A37E";ll0O01OO:= X"727C5684980B";
              IlOl010O:= X"7E774004F830";IIOl10O0:= X"0BE6E1425608";IO0l01l0:= X"765535E9B0E4";
              O10011OO:= X"05F370959CBC";OlIII0l1:= X"7C1A87CC3378";
      when "11110001" => 
              O0lOO0lI:= X"008630DE11E5";Ol01lOl0:= X"7B6A7BE8B909";lO10IO1O:= X"11D1212931FC";ll0O01OO:= X"7282473C41C1";
              IlOl010O:= X"7E78D3CF6160";IIOl10O0:= X"0BE0C16AC894";IO0l01l0:= X"765B27D21ED4";
              O10011OO:= X"05F060A9D00A";OlIII0l1:= X"7C2079B4C624";
      when "11110010" => 
              O0lOO0lI:= X"008562B4732B";Ol01lOl0:= X"7B6F2F0F3D3C";lO10IO1O:= X"11C7FCA8E29B";ll0O01OO:= X"728834E721E0";
              IlOl010O:= X"7E7A652C523B";IIOl10O0:= X"0BDAA7DD8DC4";IO0l01l0:= X"766116AC2E8F";
              O10011OO:= X"05ED53E32A07";OlIII0l1:= X"7C26688EFFA9";
      when "11110011" => 
              O0lOO0lI:= X"008495D7483F";Ol01lOl0:= X"7B73DD0839EF";lO10IO1O:= X"11BEDD8D1325";ll0O01OO:= X"728E221D4589";
              IlOl010O:= X"7E7BF420EBBF";IIOl10O0:= X"0BD494905CCB";IO0l01l0:= X"7667027B9BCE";
              O10011OO:= X"05EA4A3CD4C5";OlIII0l1:= X"7C2C545E02C3";
      when "11110100" => 
              O0lOO0lI:= X"0083CAA1D1FC";Ol01lOl0:= X"7B7883B5B91B";lO10IO1O:= X"11B5C801A03A";ll0O01OO:= X"72940C2483E3";
              IlOl010O:= X"7E7D80B1D1C9";IIOl10O0:= X"0BCE877AB6E2";IO0l01l0:= X"766CEB427266";
              O10011OO:= X"05E743B2042D";OlIII0l1:= X"7C323D24ED68";
      when "11110101" => 
              O0lOO0lI:= X"0083017DDA98";Ol01lOl0:= X"7B7D209FE1FE";lO10IO1O:= X"11ACC0EB42D6";ll0O01OO:= X"7299EFC43F39";
              IlOl010O:= X"7E7F0AE3F3C4";IIOl10O0:= X"0BC88092D9F8";IO0l01l0:= X"7672D10406F4";
              O10011OO:= X"05E4403DF605";OlIII0l1:= X"7C3822E6D8A7";
      when "11110110" => 
              O0lOO0lI:= X"008239C86E58";Ol01lOl0:= X"7B81B7788FD1";lO10IO1O:= X"11A3C11F6DB4";ll0O01OO:= X"729FD1A186BC";
              IlOl010O:= X"7E8092BC5FBC";IIOl10O0:= X"0BC27FCE6DE0";IO0l01l0:= X"7678B3C45047";
              O10011OO:= X"05E13FDBF1B7";OlIII0l1:= X"7C3E05A6D8F3";
      when "11110111" => 
              O0lOO0lI:= X"00817362251C";Ol01lOl0:= X"7B8648F113B5";lO10IO1O:= X"119AC74C5643";ll0O01OO:= X"72A5B295B9E1";
              IlOl010O:= X"7E82183FB188";IIOl10O0:= X"0BBC8524BCF4";IO0l01l0:= X"767E9385B980";
              O10011OO:= X"05DE4287484A";OlIII0l1:= X"7C43E567FE02";
      when "11111000" => 
              O0lOO0lI:= X"0080AEE6D2C0";Ol01lOl0:= X"7B8AD168DDD2";lO10IO1O:= X"1191DAA1887D";ll0O01OO:= X"72AB8DE535D5";
              IlOl010O:= X"7E839B728A35";IIOl10O0:= X"0BB6908CE198";IO0l01l0:= X"7684704AE9CA";
              O10011OO:= X"05DB483B5455";OlIII0l1:= X"7C49C22D52C5";
      when "11111001" => 
              O0lOO0lI:= X"007FEB6AFB67";Ol01lOl0:= X"7B8F56468D3F";lO10IO1O:= X"1188F088840E";ll0O01OO:= X"72B16A7E3514";
              IlOl010O:= X"7E851C59C379";IIOl10O0:= X"0BB0A1FCFACB";IO0l01l0:= X"768A4A178DB2";
              O10011OO:= X"05D850F379C2";OlIII0l1:= X"7C4F9BF9DDBB";
      when "11111010" => 
              O0lOO0lI:= X"007F2A17DFAA";Ol01lOl0:= X"7B93D0A13032";lO10IO1O:= X"118016B1989C";ll0O01OO:= X"72B73F59BA41";
              IlOl010O:= X"7E869AF9E675";IIOl10O0:= X"0BAAB96C48E3";IO0l01l0:= X"769020EE42C6";
              O10011OO:= X"05D55CAB25D6";OlIII0l1:= X"7C5572D0A0AF";
      when "11111011" => 
              O0lOO0lI:= X"007E69FB4C94";Ol01lOl0:= X"7B98460A9A8F";lO10IO1O:= X"1177422A6CF6";ll0O01OO:= X"72BD13A6A275";
              IlOl010O:= X"7E8817579D72";IIOl10O0:= X"0BA4D6D16DD6";IO0l01l0:= X"7695F4D25053";
              O10011OO:= X"05D26B5DCF0E";OlIII0l1:= X"7C5B46B498F1";
      when "11111100" => 
              O0lOO0lI:= X"007DAB97F24F";Ol01lOl0:= X"7B9CB37166A2";lO10IO1O:= X"116E7913A4F8";ll0O01OO:= X"72C2E353A432";
              IlOl010O:= X"7E8991776914";IIOl10O0:= X"0B9EFA2394B1";IO0l01l0:= X"769BC5C683E1";
              O10011OO:= X"05CF7D06F51F";OlIII0l1:= X"7C6117A8BF14";
      when "11111101" => 
              O0lOO0lI:= X"007CEE9CCDA7";Ol01lOl0:= X"7BA11AAE86A5";lO10IO1O:= X"1165B7D0CE2B";ll0O01OO:= X"72C8B0BDE2BC";
              IlOl010O:= X"7E8B095DD9D3";IIOl10O0:= X"0B9923598E9E";IO0l01l0:= X"76A193CE1189";
              O10011OO:= X"05CC91A220AB";OlIII0l1:= X"7C66E5B0077B";
      when "11111110" => 
              O0lOO0lI:= X"007C32BC7A8A";Ol01lOl0:= X"7BA57D88AC85";lO10IO1O:= X"115CFAE33098";ll0O01OO:= X"72CE7E33193C";
              IlOl010O:= X"7E8C7F0F3193";IIOl10O0:= X"0B93526B4AA4";IO0l01l0:= X"76A75EEB1E40";
              O10011OO:= X"05C9A92AE359";OlIII0l1:= X"7C6CB0CD61EB";
      when "11111111" => 
              O0lOO0lI:= X"007B78E087DA";Ol01lOl0:= X"7BA9D6823757";lO10IO1O:= X"11544D4A1C8C";ll0O01OO:= X"72D4445EAABB";
              IlOl010O:= X"7E8DF29017A7";IIOl10O0:= X"0B8D874F0923";IO0l01l0:= X"76AD27218901";
              O10011OO:= X"05C6C39CD7A5";OlIII0l1:= X"7C727903B9D5";
      when others => null;
    end case;

  if (O01ll0l0>DW_O010l10I) then
    l0O11O0I := O01ll0l0 - DW_O010l10I;
  else
    l0O11O0I := 0;
  end if;
  if ((O01ll0l0-l0O11O0I-DW_O0OO0O01) < 0) then
    O0OOO1Ol := conv_signed(O0lOO0lI(O01ll0l0-1-l0O11O0I downto 0),O0OOO1Ol'length);
  else
    O0OOO1Ol := signed(O0lOO0lI(O01ll0l0-1-l0O11O0I downto O01ll0l0-l0O11O0I-DW_O0OO0O01));
  end if;
  if ((O01ll0l0-l0O11O0I-DW_l0l110I1) < 0) then
    IlO0OlO0 := conv_signed(Ol01lOl0(O01ll0l0-1-l0O11O0I downto 0),IlO0OlO0'length);
    I11000OO := conv_signed(IlOl010O(O01ll0l0-1-l0O11O0I downto 0),I11000OO'length);
  else
    IlO0OlO0 := signed(Ol01lOl0(O01ll0l0-1-l0O11O0I downto O01ll0l0-l0O11O0I-DW_l0l110I1));
    I11000OO := signed(IlOl010O(O01ll0l0-1-l0O11O0I downto O01ll0l0-l0O11O0I-DW_l0l110I1));
  end if;
  if ((O01ll0l0-l0O11O0I-DW_O001OOOI) < 0) then
    I0lO01lI := conv_signed(lO10IO1O(O01ll0l0-1-l0O11O0I downto 0),I0lO01lI'length);
    O1010O10 := conv_signed(IIOl10O0(O01ll0l0-1-l0O11O0I downto 0),O1010O10'length);
    O0O01OO0 := conv_signed(O10011OO(O01ll0l0-1-l0O11O0I downto 0),O0O01OO0'length);
  else
    I0lO01lI := signed(lO10IO1O(O01ll0l0-1-l0O11O0I downto O01ll0l0-l0O11O0I-DW_O001OOOI));
    O1010O10 := signed(IIOl10O0(O01ll0l0-1-l0O11O0I downto O01ll0l0-l0O11O0I-DW_O001OOOI));
    O0O01OO0 := signed(O10011OO(O01ll0l0-1-l0O11O0I downto O01ll0l0-l0O11O0I-DW_O001OOOI));
  end if;
  if ((O01ll0l0-l0O11O0I-DW_IOOO11OI) < 0)  then
    Il001l11 := conv_signed(ll0O01OO(O01ll0l0-1-l0O11O0I downto 0),Il001l11'length);
    O1O11001 := conv_signed(IO0l01l0(O01ll0l0-1-l0O11O0I downto 0),O1O11001'length);
    l10OIO11 := conv_signed(OlIII0l1(O01ll0l0-1-l0O11O0I downto 0),l10OIO11'length);
  else    
    Il001l11 := signed(ll0O01OO(O01ll0l0-1-l0O11O0I downto O01ll0l0-l0O11O0I-DW_IOOO11OI));
    O1O11001 := signed(IO0l01l0(O01ll0l0-1-l0O11O0I downto O01ll0l0-l0O11O0I-DW_IOOO11OI));
    l10OIO11 := signed(OlIII0l1(O01ll0l0-1-l0O11O0I downto O01ll0l0-l0O11O0I-DW_IOOO11OI));
  end if;

  OI0l0OO0 := SHR((O0OOO1Ol * unsigned(a) + IlO0OlO0 * Oll01O00),conv_unsigned(op_width-1+DW_O0O0lO11,32));  
  l11OOO01 := SHR((signed(OI0l0OO0(DW_l0l110I1-1 downto 0)) *  unsigned(a) + I0lO01lI * OlO000O1),conv_unsigned(op_width-1,32));
  Ol111l1O := signed(l11OOO01(DW_O001OOOI-1 downto 0)) * unsigned(a) + Il001l11 * OlO000O1;
  I011Ol10 := (others => '0');
  l0IIIO0O := SHR((I11000OO *  unsigned(a) + O1010O10 * OlO000O1),conv_unsigned(op_width-1,32));
  O1llIl1O := signed(l0IIIO0O(DW_O001OOOI-1 downto 0)) *  unsigned(a) + O1O11001 * OlO000O1;
  O10IlO11 := (others => '0');
  O0OlOOOl := (others => '0');   
  II0Ol1Il := O0O01OO0 *  unsigned(a) + l10OIO11 * OlO000O1;
  if ((op_width >= 19) and (op_width < 29)) then
    I11O100l := O1llIl1O(I11O100l'left downto 0);
  else
    if ((op_width >= 13) and (op_width < 19)) then
      I11O100l := II0Ol1Il(I11O100l'left downto 0);
    else  
      I11O100l := Ol111l1O(I11O100l'left downto 0);
    end if;
  end if;
  I11O100l := SHL(I11O100l,conv_unsigned(DW_l1010I01,3));

  for OOIO01I0 in 1 to O10ll00I'length loop
    if (OOIO01I0 <= I11O100l'length) then
      O10ll00I(O10ll00I'length-OOIO01I0) := I11O100l(I11O100l'length-OOIO01I0);
    else
      O10ll00I(O10ll00I'length-OOIO01I0) := '0';
    end if;
  end loop;

  IOO0O111 := unsigned(O10ll00I);
  lIOI0I0O:= unsigned(IOO0O111(IOO0O111'length-2 downto IOO0O111'length-1-lIOI0I0O'length))
            + unsigned('1' & conv_unsigned(0,DW_IO1IIIl0-1));
  O010I0I1 <= std_logic_vector(lIOI0I0O(DW_IOl1OOO0 downto DW_IOl1OOO0-op_width+1));
end process;

Log_alg1_new: process (a)
  variable O0lOO0lI : unsigned (O01ll0l0-1 downto 0);
  variable Ol01lOl0 : unsigned (O01ll0l0-1 downto 0);
  variable lO10IO1O : unsigned (O01ll0l0-1 downto 0);
  variable ll0O01OO : unsigned (O01ll0l0-1 downto 0);
  variable IlOl010O : unsigned (O01ll0l0-1 downto 0);
  variable IIOl10O0 : unsigned (O01ll0l0-1 downto 0);
  variable IO0l01l0 : unsigned (O01ll0l0-1 downto 0);
  variable O10011OO : unsigned (O01ll0l0-1 downto 0);
  variable OlIII0l1 : unsigned (O01ll0l0-1 downto 0);
  variable O0OOO1Ol : signed (DW_O0OO0O01-1 downto 0);
  variable IlO0OlO0 : signed (DW_l0l110I1-1 downto 0);
  variable I0lO01lI : signed (DW_O001OOOI-1 downto 0);
  variable Il001l11 : signed (DW_IOOO11OI-1 downto 0);
  variable I11000OO : signed (DW_l0l110I1-1 downto 0);
  variable O1010O10 : signed (DW_O001OOOI-1 downto 0);
  variable O1O11001 : signed (DW_IOOO11OI-1 downto 0);
  variable O0O01OO0 : signed (DW_O001OOOI-1 downto 0);
  variable l10OIO11 : signed (DW_IOOO11OI-1 downto 0);
  variable Ol111l1O  : signed (DW_OI0O0OO0+1 downto 0);
  variable l11OOO01  : signed (DW_O0Ol00I0+1 downto 0);
  variable OI0l0OO0 : signed (DW_l0IOl1OO+1 downto 0);
  variable O1llIl1O  : signed (DW_OI0O0OO0+1 downto 0);
  variable l0IIIO0O  : signed (DW_O0Ol00I0+1 downto 0);
  variable I011Ol10 : signed (DW_l0IOl1OO+1 downto 0);
  variable II0Ol1Il  : signed (DW_OI0O0OO0+1 downto 0);
  variable O0OlOOOl  : signed (DW_O0Ol00I0+1 downto 0);
  variable O10IlO11 : signed (DW_l0IOl1OO+1 downto 0);
  variable I11O100l  : signed (DW_OI0O0OO0 downto 0);
  variable O10ll00I : unsigned (DW_O1100l11-1 downto 0);
  variable IOO0O111 : unsigned (DW_O1100l11-1 downto 0);
  variable O1OI11lI : std_logic_vector (DW_OI1O1I0O-1 downto 0);
  variable IOIlO01O : std_logic_vector (op_width-1 downto 0); 
  variable lIOI0I0O : unsigned (DW_IOl1OOO0 downto 0);
  variable l0O11O0I : integer;
  variable OlO000O1 : unsigned (op_width-1 downto 0);
  variable Oll01O00 : unsigned (op_width-1+DW_O0O0lO11 downto 0);
  variable l0100IOO : unsigned (2*op_width-1 downto 0);
  variable l0Il1llO : unsigned (3*op_width-1 downto 0);
  variable l110I00O : unsigned (2*op_width-1 downto 0);
  variable lOI1O001 : unsigned (op_width+DW_I0I00O00-1 downto 0);
  variable I11IlIII : unsigned (3*op_width-1 downto 0);
  variable I111O10l : unsigned (op_width+DW_I0I00O00-1 downto 0);
  variable O0Ol00II : unsigned (IOIlO01O'left+DW_I0I00O00+1 downto 0);
  variable OOOOOOO1 : std_logic_vector (DW_I0I00O00 downto 0);
begin
  OlO000O1 := (others => '0');
  OlO000O1(OlO000O1'left) := '1';
  Oll01O00 := (others => '0');
  Oll01O00(Oll01O00'left) := '1';
  OOOOOOO1 := (others => '0');
  for OOIO01I0 in 0 to DW_OI1O1I0O-1 loop
    if (op_width-1 <= OOIO01I0) then
      O1OI11lI(DW_OI1O1I0O - 1 - OOIO01I0) := '0';
    else
      O1OI11lI(DW_OI1O1I0O - 1 - OOIO01I0) := a(op_width - 2 - OOIO01I0);
    end if;
  end loop;
  
  IOIlO01O := a;
  IOIlO01O(op_width-1) := '0';
  for OOIO01I0 in 0 to DW_OI1O1I0O-1 loop 
    if (op_width-2 >= OOIO01I0) then
        IOIlO01O(op_width-2-OOIO01I0) := '0';
    end if;
  end loop;

    case (O1OI11lI) is
      when "00000000" => 
              O0lOO0lI:= X"03D32246D962";Ol01lOl0:= X"7A3AB1D5C3D6";lO10IO1O:= X"0B8AA3B1C545";ll0O01OO:= X"00000000000A";
              IlOl010O:= X"7A406E892D6B";IIOl10O0:= X"0B8AA1676F49";IO0l01l0:= X"00000000306C";
              O10011OO:= X"0B84E1D5F876";OlIII0l1:= X"000000F47E12";
      when "00000001" => 
              O0lOO0lI:= X"03C7C5564EBF";Ol01lOl0:= X"7A462B31D80D";lO10IO1O:= X"0B7F248D3A7F";ll0O01OO:= X"000B84E236C7";
              IlOl010O:= X"7A4BD6D9DA68";IIOl10O0:= X"0B7F2249B277";IO0l01l0:= X"000B84E2669A";
              O10011OO:= X"0B796E208C52";OlIII0l1:= X"000B85D4CF6E";
      when "00000010" => 
              O0lOO0lI:= X"03BC95255266";Ol01lOl0:= X"7A5182776249";lO10IO1O:= X"0B73BC395760";ll0O01OO:= X"0016FE50B6F8";
              IlOl010O:= X"7A571D571720";IIOl10O0:= X"0B73B9FC8287";IO0l01l0:= X"0016FE50E63E";
              O10011OO:= X"0B6E1119D99E";OlIII0l1:= X"0016FF416FDF";
      when "00000011" => 
              O0lOO0lI:= X"03B1910813B5";Ol01lOl0:= X"7A5CB82C92B4";lO10IO1O:= X"0B686A72750E";ll0O01OO:= X"00226C622F5C";
              IlOl010O:= X"7A624286226F";IIOl10O0:= X"0B68683C38F3";IO0l01l0:= X"00226C625E16";
              O10011OO:= X"0B62CA7EBF17";OlIII0l1:= X"00226D510E0B";
      when "00000100" => 
              O0lOO0lI:= X"03A6B81AF1D9";Ol01lOl0:= X"7A67CCD56AFE";lO10IO1O:= X"0B5D2EF5F6F3";ll0O01OO:= X"002DCF2D0B8F";
              IlOl010O:= X"7A6D46E99383";IIOl10O0:= X"0B5D2CC639C5";IO0l01l0:= X"002DCF2D39BF";
              O10011OO:= X"0B579A0D2358";OlIII0l1:= X"002DD01A157A";
      when "00000101" => 
              O0lOO0lI:= X"039C0949BB00";Ol01lOl0:= X"7A72C0F3C2C9";lO10IO1O:= X"0B520982459E";ll0O01OO:= X"003926C77513";
              IlOl010O:= X"7A782B01B01C";IIOl10O0:= X"0B520758EE24";IO0l01l0:= X"003926C7A2BD";
              O10011OO:= X"0B4C7F83EFD4";OlIII0l1:= X"003927B2AF99";
      when "00000110" => 
              O0lOO0lI:= X"03918431165C";Ol01lOl0:= X"7A7D9505D889";lO10IO1O:= X"0B46F9D6CA8B";ll0O01OO:= X"004473475456";
              IlOl010O:= X"7A82EF4C2563";IIOl10O0:= X"0B46F7B3BFC1";IO0l01l0:= X"00447347817A";
              O10011OO:= X"0B417AA30BE7";OlIII0l1:= X"00447430C4C0";
      when "00000111" => 
              O0lOO0lI:= X"038727AE02FC";Ol01lOl0:= X"7A884988CBF3";lO10IO1O:= X"0B3BFFB3EA0F";ll0O01OO:= X"004FB4C251AA";
              IlOl010O:= X"7A8D94445261";IIOl10O0:= X"0B3BFD9713AF";IO0l01l0:= X"004FB4C27E4B";
              O10011OO:= X"0B368B2B5802";OlIII0l1:= X"004FB5A9FD2E";
      when "00001000" => 
              O0lOO0lI:= X"037CF325C958";Ol01lOl0:= X"7A92DEF6895D";lO10IO1O:= X"0B311ADAFF9B";ll0O01OO:= X"005AEB4DD645";
              IlOl010O:= X"7A981A633B5E";IIOl10O0:= X"0B3118C445BC";IO0l01l0:= X"005AEB4E0265";
              O10011OO:= X"0B2BB0DEA8F7";OlIII0l1:= X"005AEC33C203";
      when "00001001" => 
              O0lOO0lI:= X"0372E5E88A47";Ol01lOl0:= X"7A9D55C6D175";lO10IO1O:= X"0B264B0E58A9";ll0O01OO:= X"006616FF0D2E";
              IlOl010O:= X"7AA2821FB19B";IIOl10O0:= X"0B2648FDA3AE";IO0l01l0:= X"006616FF38CF";
              O10011OO:= X"0B20EB7FC360";OlIII0l1:= X"006617E33E34";
      when "00001010" => 
              O0lOO0lI:= X"0368FF0E492B";Ol01lOl0:= X"7AA7AE6F9560";lO10IO1O:= X"0B1B90112FF7";ll0O01OO:= X"007137EAE433";
              IlOl010O:= X"7AACCBEE27A1";IIOl10O0:= X"0B1B8E0668F7";IO0l01l0:= X"007137EB0F57";
              O10011OO:= X"0B163AD2571E";OlIII0l1:= X"007138CD5F7C";
      when "00001011" => 
              O0lOO0lI:= X"035F3E002483";Ol01lOl0:= X"7AB1E9640AB1";lO10IO1O:= X"0B10E9A7A99D";ll0O01OO:= X"007C4E260CD1";
              IlOl010O:= X"7AB6F841084E";IIOl10O0:= X"0B10E7A2B9EC";IO0l01l0:= X"007C4E26377A";
              O10011OO:= X"0B0B9E9AFAF6";OlIII0l1:= X"007C4F06D743";
      when "00001100" => 
              O0lOO0lI:= X"0355A1F370CE";Ol01lOl0:= X"7ABC0715A051";lO10IO1O:= X"0B065796CE38";ll0O01OO:= X"008759C4FD1D";
              IlOl010O:= X"7AC107888393";IIOl10O0:= X"0B0655979FB8";IO0l01l0:= X"008759C5274C";
              O10011OO:= X"0B01169F283B";OlIII0l1:= X"00875AA41B8C";
      when "00001101" => 
              O0lOO0lI:= X"034C2A7D24AF";Ol01lOl0:= X"7AC607F31007";lO10IO1O:= X"0AFBD9A4872C";ll0O01OO:= X"00925ADBF0A3";
              IlOl010O:= X"7ACAFA32CCAD";IIOl10O0:= X"0AFBD7AB03DD";IO0l01l0:= X"00925ADC1A5A";
              O10011OO:= X"0AF6A2A536A9";OlIII0l1:= X"00925BB967D0";
      when "00001110" => 
              O0lOO0lI:= X"0342D691BA14";Ol01lOl0:= X"7ACFEC6A1F7B";lO10IO1O:= X"0AF16F97999A";ll0O01OO:= X"009D517EE947";
              IlOl010O:= X"7AD4D0ABFB38";IIOl10O0:= X"0AF16DA3AC41";IO0l01l0:= X"009D517F1288";
              O10011OO:= X"0AEC4274583C";OlIII0l1:= X"009D525ABDE4";
      when "00001111" => 
              O0lOO0lI:= X"0339A5C267A6";Ol01lOl0:= X"7AD9B4E58AEB";lO10IO1O:= X"0AE71937A36B";ll0O01OO:= X"00A83DC1B022";
              IlOl010O:= X"7ADE8B5E2E68";IIOl10O0:= X"0AE717493703";IO0l01l0:= X"00A83DC1D8EE";
              O10011OO:= X"0AE1F5D49531";OlIII0l1:= X"00A83E9BE6CB";
      when "00010000" => 
              O0lOO0lI:= X"0330976768D6";Ol01lOl0:= X"7AE361CE7FE3";lO10IO1O:= X"0ADCD64D1694";ll0O01OO:= X"00B31FB7D650";
              IlOl010O:= X"7AE82AB19EF9";IIOl10O0:= X"0ADCD4641675";IO0l01l0:= X"00B31FB7FEAA";
              O10011OO:= X"0AD7BC8EC814";OlIII0l1:= X"00B320907394";
      when "00010001" => 
              O0lOO0lI:= X"0327AAB3D78A";Ol01lOl0:= X"7AECF38C8141";lO10IO1O:= X"0AD2A6A13550";ll0O01OO:= X"00BDF774B5CC";
              IlOl010O:= X"7AF1AF0C8FD4";IIOl10O0:= X"0AD2A4BD8D5C";IO0l01l0:= X"00BDF774DDB6";
              O10011OO:= X"0ACD966C99EB";OlIII0l1:= X"00BDF84BBE26";
      when "00010010" => 
              O0lOO0lI:= X"031EDF46313D";Ol01lOl0:= X"7AF66A8488C9";lO10IO1O:= X"0AC889FE0EBB";ll0O01OO:= X"00C8C50B7239";
              IlOl010O:= X"7AFB18D37480";IIOl10O0:= X"0AC8881FAAFE";IO0l01l0:= X"00C8C50B99B3";
              O10011OO:= X"0AC383387E72";OlIII0l1:= X"00C8C5E0EA14";
      when "00010011" => 
              O0lOO0lI:= X"03163445E24F";Ol01lOl0:= X"7AFFC71A7DCC";lO10IO1O:= X"0ABE802E7A73";ll0O01OO:= X"00D3888EF9AB";
              IlOl010O:= X"7B046868E568";IIOl10O0:= X"0ABE7E554789";IO0l01l0:= X"00D3888F20B8";
              O10011OO:= X"0AB982BDB06D";OlIII0l1:= X"00D38962E562";
      when "00010100" => 
              O0lOO0lI:= X"030DA9586948";Ol01lOl0:= X"7B0909AFB53F";lO10IO1O:= X"0AB488FE15A8";ll0O01OO:= X"00DE42120574";
              IlOl010O:= X"7B0D9E2DBC31";IIOl10O0:= X"0AB4872A0054";IO0l01l0:= X"00DE42122C15";
              O10011OO:= X"0AAF94C82E10";OlIII0l1:= X"00DE42E46952";
      when "00010101" => 
              O0lOO0lI:= X"03053DD31FD5";Ol01lOl0:= X"7B1232A44618";lO10IO1O:= X"0AAAA4393EFB";ll0O01OO:= X"00E8F1A71AE3";
              IlOl010O:= X"7B16BA81051C";IIOl10O0:= X"0AAAA26A3472";IO0l01l0:= X"00E8F1A74119";
              O10011OO:= X"0AA5B924B577";OlIII0l1:= X"00E8F277FB22";
      when "00010110" => 
              O0lOO0lI:= X"02FCF12A42D0";Ol01lOl0:= X"7B1B42566839";lO10IO1O:= X"0AA0D1AD1342";ll0O01OO:= X"00F397608C04";
              IlOl010O:= X"7B1FBDC0246C";IIOl10O0:= X"0AA0CFE30110";IO0l01l0:= X"00F39760B1D1";
              O10011OO:= X"0A9BEFA0C133";OlIII0l1:= X"00F3982FECD0";
      when "00010111" => 
              O0lOO0lI:= X"02F4C2CC6812";Ol01lOl0:= X"7B243922A787";lO10IO1O:= X"0A9711276A23";ll0O01OO:= X"00FE3350785F";
              IlOl010O:= X"7B28A846DC3E";IIOl10O0:= X"0A970F623E16";IO0l01l0:= X"00FE33509DC4";
              O10011OO:= X"0A92380A84F2";OlIII0l1:= X"00FE341E5DD4";
      when "00011000" => 
              O0lOO0lI:= X"02ECB21409A8";Ol01lOl0:= X"7B2D17641F04";lO10IO1O:= X"0A8D6276D28C";ll0O01OO:= X"0108C588CDAE";
              IlOl010O:= X"7B317A6F37EA";IIOl10O0:= X"0A8D60B67AF3";IO0l01l0:= X"0108C588F2AE";
              O10011OO:= X"0A889230EA2A";OlIII0l1:= X"0108C6553BDA";
      when "00011001" => 
              O0lOO0lI:= X"02E4BED758C6";Ol01lOl0:= X"7B35DD7373CA";lO10IO1O:= X"0A83C56A9009";ll0O01OO:= X"01134E1B4897";
              IlOl010O:= X"7B3A3491B68F";IIOl10O0:= X"0A83C3AEFB2D";IO0l01l0:= X"01134E1B6D32";
              O10011OO:= X"0A7EFDE38CE3";OlIII0l1:= X"01134EE64377";
      when "00011010" => 
              O0lOO0lI:= X"02DCE803DEBD";Ol01lOl0:= X"7B3E8BA9493C";lO10IO1O:= X"0A7A39D29658";ll0O01OO:= X"011DCD197559";
              IlOl010O:= X"7B42D705492D";IIOl10O0:= X"0A7A381BB343";IO0l01l0:= X"011DCD199991";
              O10011OO:= X"0A757AF2B88C";OlIII0l1:= X"011DCDE300DE";
      when "00011011" => 
              O0lOO0lI:= X"02D52DA94F32";Ol01lOl0:= X"7B47225AD009";lO10IO1O:= X"0A70BF7F8801";ll0O01OO:= X"01284294B081";
              IlOl010O:= X"7B4B621F4DAD";IIOl10O0:= X"0A70BDCD4598";IO0l01l0:= X"01284294D457";
              O10011OO:= X"0A6C092F64E5";OlIII0l1:= X"0128435CD08C";
      when "00011100" => 
              O0lOO0lI:= X"02CD8EEE0BE3";Ol01lOl0:= X"7B4FA1DD46B5";lO10IO1O:= X"0A675642B18C";ll0O01OO:= X"0132AE9E2791";
              IlOl010O:= X"7B53D633B12F";IIOl10O0:= X"0A675494FF46";IO0l01l0:= X"0132AE9E4B07";
              O10011OO:= X"0A62A86B32F8";OlIII0l1:= X"0132AF64DFF7";
      when "00011101" => 
              O0lOO0lI:= X"02C60B6EC8B9";Ol01lOl0:= X"7B580A83ABE6";lO10IO1O:= X"0A5DFDEE07B0";ll0O01OO:= X"013D1146D9AF";
              IlOl010O:= X"7B5C3394CC1A";IIOl10O0:= X"0A5DFC44D550";IO0l01l0:= X"013D1146FCC5";
              O10011OO:= X"0A5958786A1C";OlIII0l1:= X"013D120C2E35";
      when "00011110" => 
              O0lOO0lI:= X"02BEA2ADB94A";Ol01lOl0:= X"7B605C9FB6F4";lO10IO1O:= X"0A54B65423EB";ll0O01OO:= X"01476A9F9846";
              IlOl010O:= X"7B647A93B93C";IIOl10O0:= X"0A54B4AF615D";IO0l01l0:= X"01476A9FBAFE";
              O10011OO:= X"0A501929F516";OlIII0l1:= X"01476B638CA5";
      when "00011111" => 
              O0lOO0lI:= X"02B754212711";Ol01lOl0:= X"7B689881D724";lO10IO1O:= X"0A4B7F48419F";ll0O01OO:= X"0151BAB907AC";
              IlOl010O:= X"7B6CAB8002EC";IIOl10O0:= X"0A4B7DA7DF3A";IO0l01l0:= X"0151BAB92A08";
              O10011OO:= X"0A46EA535F3D";OlIII0l1:= X"0151BB7B9F8F";
      when "00100000" => 
              O0lOO0lI:= X"02B01FC41A37";Ol01lOl0:= X"7B70BE782D47";lO10IO1O:= X"0A42589E3BD7";ll0O01OO:= X"015C01A39FC3";
              IlOl010O:= X"7B74C6A7D33F";IIOl10O0:= X"0A42570229E2";IO0l01l0:= X"015C01A3C1C4";
              O10011OO:= X"0A3DCBC8D1B4";OlIII0l1:= X"015C0264DEC9";
      when "00100001" => 
              O0lOO0lI:= X"02A90480ACDF";Ol01lOl0:= X"7B78CED15AD8";lO10IO1O:= X"0A39422A8918";ll0O01OO:= X"01663F6FAC97";
              IlOl010O:= X"7B7CCC5817D0";IIOl10O0:= X"0A394092B896";IO0l01l0:= X"01663F6FCE3E";
              O10011OO:= X"0A34BD5F10AD";OlIII0l1:= X"0166402F9652";
      when "00100010" => 
              O0lOO0lI:= X"02A20240D616";Ol01lOl0:= X"7B80C9D8F8E2";lO10IO1O:= X"0A303BC23A79";ll0O01OO:= X"0170742D4EF6";
              IlOl010O:= X"7B84BCDC531D";IIOl10O0:= X"0A303A2E9C6E";IO0l01l0:= X"0170742D7044";
              O10011OO:= X"0A2BBEEB78BF";OlIII0l1:= X"017074EBE6EA";
      when "00100011" => 
              O0lOO0lI:= X"029B18605780";Ol01lOl0:= X"7B88AFDA464D";lO10IO1O:= X"0A27453AF7AD";ll0O01OO:= X"017A9FEC7D0C";
              IlOl010O:= X"7B8C987ECFCB";IIOl10O0:= X"0A2743AB7D7E";IO0l01l0:= X"017A9FEC9E03";
              O10011OO:= X"0A22D043FC4E";OlIII0l1:= X"017AA0A9C6B1";
      when "00100100" => 
              O0lOO0lI:= X"029446FD5D18";Ol01lOl0:= X"7B90811DF669";lO10IO1O:= X"0A1E5E6AFD85";ll0O01OO:= X"0184C2BD02F6";
              IlOl010O:= X"7B945F887264";IIOl10O0:= X"0A1E5CDF987E";IO0l01l0:= X"0184C2BD2397";
              O10011OO:= X"0A19F13F20F1";OlIII0l1:= X"0184C37901BA";
      when "00100101" => 
              O0lOO0lI:= X"028D8D08469A";Ol01lOl0:= X"7B983DED81A5";lO10IO1O:= X"0A15872919C7";ll0O01OO:= X"018EDCAE8358";
              IlOl010O:= X"7B9C12410CFA";IIOl10O0:= X"0A1585A1BBEB";IO0l01l0:= X"018EDCAEA3A4";
              O10011OO:= X"0A1121B3FCF9";OlIII0l1:= X"018EDD693A9C";
      when "00100110" => 
              O0lOO0lI:= X"0286EA92F242";Ol01lOl0:= X"7B9FE68F3404";lO10IO1O:= X"0A0CBF4CAAAF";ll0O01OO:= X"0198EDD077EC";
              IlOl010O:= X"7BA3B0EF13AD";IIOl10O0:= X"0A0CBDC945E5";IO0l01l0:= X"0198EDD097E4";
              O10011OO:= X"0A08617A34FA";OlIII0l1:= X"0198EE89EB04";
      when "00100111" => 
              O0lOO0lI:= X"02805EEA89E5";Ol01lOl0:= X"7BA77B4982E6";lO10IO1O:= X"0A0406AD9AD3";ll0O01OO:= X"01A2F6323211";
              IlOl010O:= X"7BAB3BD7E2A1";IIOl10O0:= X"0A04052E217C";IO0l01l0:= X"01A2F63251B6";
              O10011OO:= X"09FFB069F95E";OlIII0l1:= X"01A2F6EA6446";
      when "00101000" => 
              O0lOO0lI:= X"0279E9DDF1B8";Ol01lOl0:= X"7BAEFC60DB15";lO10IO1O:= X"09FB5D245FDC";ll0O01OO:= X"01ACF5E2DB54";
              IlOl010O:= X"7BB2B33FADD4";IIOl10O0:= X"09FB5BA8C464";IO0l01l0:= X"01ACF5E2FAA7";
              O10011OO:= X"09F70E5C0412";OlIII0l1:= X"01ACF699CFE5";
      when "00101001" => 
              O0lOO0lI:= X"02738ADA9CA3";Ol01lOl0:= X"7BB66A1921DA";lO10IO1O:= X"09F2C289F781";ll0O01OO:= X"01B6ECF175FF";
              IlOl010O:= X"7BBA1769642F";IIOl10O0:= X"09F2C1122CCA";IO0l01l0:= X"01B6ECF19501";
              O10011OO:= X"09EE7B29962E";OlIII0l1:= X"01B6EDA7301E";
      when "00101010" => 
              O0lOO0lI:= X"026D41B89B0F";Ol01lOl0:= X"7BBDC4B47098";lO10IO1O:= X"09EA36B7E5D4";ll0O01OO:= X"01C0DB6CDD9A";
              IlOl010O:= X"7BC16897091A";IIOl10O0:= X"09EA3543DEAB";IO0l01l0:= X"01C0DB6CFC4D";
              O10011OO:= X"09E5F6AC75B5";OlIII0l1:= X"01C0DC216070";
      when "00101011" => 
              O0lOO0lI:= X"02670DE8AA00";Ol01lOl0:= X"7BC50C7475D8";lO10IO1O:= X"09E1B988325A";ll0O01OO:= X"01CAC163C776";
              IlOl010O:= X"7BC8A70951C1";IIOl10O0:= X"09E1B817E20C";IO0l01l0:= X"01CAC163E5DB";
              O10011OO:= X"09DD80BEEB5D";OlIII0l1:= X"01CAC217161F";
      when "00101100" => 
              O0lOO0lI:= X"0260EF3997B9";Ol01lOl0:= X"7BCC41992E7B";lO10IO1O:= X"09D94AD56680";ll0O01OO:= X"01D49EE4C32B";
              IlOl010O:= X"7BCFD30007B6";IIOl10O0:= X"09D94968C05C";IO0l01l0:= X"01D49EE4E142";
              O10011OO:= X"09D5193BC063";OlIII0l1:= X"01D49F96E0BA";
      when "00101101" => 
              O0lOO0lI:= X"025AE52EB8C2";Ol01lOl0:= X"7BD36462054A";lO10IO1O:= X"09D0EA7A8AEC";ll0O01OO:= X"01DE73FE3B19";
              IlOl010O:= X"7BD6ECB9CBD0";IIOl10O0:= X"09D0E911829C";IO0l01l0:= X"01DE73FE58E4";
              O10011OO:= X"09CCBFFE3C68";OlIII0l1:= X"01DE74AF2A97";
      when "00101110" => 
              O0lOO0lI:= X"0254EFBDA8C2";Ol01lOl0:= X"7BDA750C9EA9";lO10IO1O:= X"09C8985325F3";ll0O01OO:= X"01E840BE74EB";
              IlOl010O:= X"7BDDF47442E1";IIOl10O0:= X"09C896EDAF15";IO0l01l0:= X"01E840BE926B";
              O10011OO:= X"09C474E22358";OlIII0l1:= X"01E8416E3956";
      when "00101111" => 
              O0lOO0lI:= X"024F0E1B0652";Ol01lOl0:= X"7BE173D6E282";lO10IO1O:= X"09C0543B3890";ll0O01OO:= X"01F20533920E";
              IlOl010O:= X"7BE4EA6C0BB8";IIOl10O0:= X"09C052D94759";IO0l01l0:= X"01F20533AF43";
              O10011OO:= X"09BC37C3B365";OlIII0l1:= X"01F205E22E58";
      when "00110000" => 
              O0lOO0lI:= X"02494033D074";Ol01lOl0:= X"7BE860FC7CEC";lO10IO1O:= X"09B81E0F3D99";ll0O01OO:= X"01FBC16B902B";
              IlOl010O:= X"7BEBCEDCCE51";IIOl10O0:= X"09B81CB0C62D";IO0l01l0:= X"01FBC16BAD17";
              O10011OO:= X"09B4087FA2FC";OlIII0l1:= X"01FBC219073F";
      when "00110001" => 
              O0lOO0lI:= X"024385AF1E45";Ol01lOl0:= X"7BEF3CB8A50C";lO10IO1O:= X"09AFF5AC26DC";ll0O01OO:= X"0205757449A5";
              IlOl010O:= X"7BF2A2012A61";IIOl10O0:= X"09AFF4511DA9";IO0l01l0:= X"020575746649";
              O10011OO:= X"09ABE6F31ED3";OlIII0l1:= X"020576209E63";
      when "00110010" => 
              O0lOO0lI:= X"023DDE4AAE93";Ol01lOl0:= X"7BF6074566D4";lO10IO1O:= X"09A7DAEF5B9A";ll0O01OO:= X"020F215B760B";
              IlOl010O:= X"7BF96412D6B3";IIOl10O0:= X"09A7D997B524";IO0l01l0:= X"020F215B9266";
              O10011OO:= X"09A3D2FBC7FC";OlIII0l1:= X"020F2206AB49";
      when "00110011" => 
              O0lOO0lI:= X"023849BA3B59";Ol01lOl0:= X"7BFCC0DBFAA1";lO10IO1O:= X"099FCDB6B665";ll0O01OO:= X"0218C52EAA8A";
              IlOl010O:= X"7C00154A8FA0";IIOl10O0:= X"099FCC62676A";IO0l01l0:= X"0218C52EC69F";
              O10011OO:= X"099BCC77B1F9";OlIII0l1:= X"0218C5D8C316";
      when "00110100" => 
              O0lOO0lI:= X"0232C7A56711";Ol01lOl0:= X"7C0369B4BCD5";lO10IO1O:= X"0997CDE0834E";ll0O01OO:= X"022260FB5A66";
              IlOl010O:= X"7C06B5E02F1A";IIOl10O0:= X"0997CC8F80BD";IO0l01l0:= X"022260FB7635";
              O10011OO:= X"0993D34560EB";OlIII0l1:= X"022261A45903";
      when "00110101" => 
              O0lOO0lI:= X"022D57AB684F";Ol01lOl0:= X"7C0A02073633";lO10IO1O:= X"098FDB4B7E0C";ll0O01OO:= X"022BF4CED765";
              IlOl010O:= X"7C0D460ABAD7";IIOl10O0:= X"098FD9FDBCFF";IO0l01l0:= X"022BF4CEF2F0";
              O10011OO:= X"098BE743C7BA";OlIII0l1:= X"022BF576BECF";
      when "00110110" => 
              O0lOO0lI:= X"0227F981B536";Ol01lOl0:= X"7C108A09E17B";lO10IO1O:= X"0987F5D6D04F";ll0O01OO:= X"023580B65242";
              IlOl010O:= X"7C13C6002706";IIOl10O0:= X"0987F48C4628";IO0l01l0:= X"023580B66D89";
              O10011OO:= X"09840852464F";OlIII0l1:= X"0235815D252A";
      when "00110111" => 
              O0lOO0lI:= X"0222ACFEB67A";Ol01lOl0:= X"7C1701F230B2";lO10IO1O:= X"09801D620FF4";ll0O01OO:= X"023F04BEDB16";
              IlOl010O:= X"7C1A35F5B196";IIOl10O0:= X"09801C1AB21F";IO0l01l0:= X"023F04BEF61A";
              O10011OO:= X"097C3650A7D0";OlIII0l1:= X"023F05649C24";
      when "00111000" => 
              O0lOO0lI:= X"021D719FE20C";Ol01lOl0:= X"7C1D69F54429";lO10IO1O:= X"097851CD3CFE";ll0O01OO:= X"024880F561C5";
              IlOl010O:= X"7C20961FAA9F";IIOl10O0:= X"097850890146";IO0l01l0:= X"024880F57C87";
              O10011OO:= X"0974711F20EF";OlIII0l1:= X"0248819A139A";
      when "00111001" => 
              O0lOO0lI:= X"0218479CFA78";Ol01lOl0:= X"7C23C24630B0";lO10IO1O:= X"097092F8C0B8";ll0O01OO:= X"0251F566B669";
              IlOl010O:= X"7C26E6B19F75";IIOl10O0:= X"097091B79C9A";IO0l01l0:= X"0251F566D0E9";
              O10011OO:= X"096CB89E4E3A";OlIII0l1:= X"0251F60A5B9D";
      when "00111010" => 
              O0lOO0lI:= X"02132E35C981";Ol01lOl0:= X"7C2A0B18E937";lO10IO1O:= X"0968E0C56A92";ll0O01OO:= X"025B621F89B7";
              IlOl010O:= X"7C2D27DE3C25";IIOl10O0:= X"0968DF87542C";IO0l01l0:= X"025B621FA3F7";
              O10011OO:= X"09650CAF3268";OlIII0l1:= X"025B62C224D9";
      when "00111011" => 
              O0lOO0lI:= X"020E253D9F51";Ol01lOl0:= X"7C30449F8503";lO10IO1O:= X"09613B146FF3";ll0O01OO:= X"0264C72C6D69";
              IlOl010O:= X"7C3359D766B6";IIOl10O0:= X"096139D95D6A";IO0l01l0:= X"0264C72C8769";
              O10011OO:= X"095D6D3334D1";OlIII0l1:= X"0264C7CE00FF";
      when "00111100" => 
              O0lOO0lI:= X"02092C7CC1F2";Ol01lOl0:= X"7C366F0B7914";lO10IO1O:= X"0959A1C769E8";ll0O01OO:= X"026E2499D49E";
              IlOl010O:= X"7C397CCE2E46";IIOl10O0:= X"0959A08F5196";IO0l01l0:= X"026E2499EE5F";
              O10011OO:= X"0955DA0C1FC4";OlIII0l1:= X"026E253A6326";
      when "00111101" => 
              O0lOO0lI:= X"020443DE0B97";Ol01lOl0:= X"7C3C8A8D29C6";lO10IO1O:= X"095214C053E1";ll0O01OO:= X"02777A74143F";
              IlOl010O:= X"7C3F90F2F910";IIOl10O0:= X"0952138B2C06";IO0l01l0:= X"02777A742DC2";
              O10011OO:= X"094E531C1EFF";OlIII0l1:= X"02777B13A032";
      when "00111110" => 
              O0lOO0lI:= X"01FF6AEDEE7B";Ol01lOl0:= X"7C429754E606";lO10IO1O:= X"094A93E1899C";ll0O01OO:= X"0280C8C76364";
              IlOl010O:= X"7C45967550B4";IIOl10O0:= X"094A92AF48DA";IO0l01l0:= X"0280C8C77CAA";
              O10011OO:= X"0946D845BE2A";OlIII0l1:= X"0280C965EF2F";
      when "00111111" => 
              O0lOO0lI:= X"01FAA15B86C0";Ol01lOl0:= X"7C4895920123";lO10IO1O:= X"09431F0DC619";ll0O01OO:= X"028A0F9FDBAE";
              IlOl010O:= X"7C4B8D840AD8";IIOl10O0:= X"09431DDE6346";IO0l01l0:= X"028A0F9FF4B7";
              O10011OO:= X"093F696BE752";OlIII0l1:= X"028A103D69B8";
      when "01000000" => 
              O0lOO0lI:= X"01F5E71BDA4F";Ol01lOl0:= X"7C4E85729731";lO10IO1O:= X"093BB6282245";ll0O01OO:= X"02934F0979A7";
              IlOl010O:= X"7C51764D402A";IIOl10O0:= X"093BB4FB9430";IO0l01l0:= X"02934F099274";
              O10011OO:= X"09380671E170";OlIII0l1:= X"02934FA60C51";
      when "01000001" => 
              O0lOO0lI:= X"01F13BD07735";Ol01lOl0:= X"7C5467249FC6";lO10IO1O:= X"0934591412F3";ll0O01OO:= X"029C87101D23";
              IlOl010O:= X"7C5750FE4FEE";IIOl10O0:= X"093457EA50AF";IO0l01l0:= X"029C871035B5";
              O10011OO:= X"0930AF3B4EFF";OlIII0l1:= X"029C87ABB6C3";
      when "01000010" => 
              O0lOO0lI:= X"01EC9F734B27";Ol01lOl0:= X"7C5A3AD4CA4E";lO10IO1O:= X"092D07B56802";ll0O01OO:= X"02A5B7BF8996";
              IlOl010O:= X"7C5D1DC3F3F3";IIOl10O0:= X"092D068E688E";IO0l01l0:= X"02A5B7BFA1EE";
              O10011OO:= X"092963AC2C83";OlIII0l1:= X"02A5B85A2C7D";
      when "01000011" => 
              O0lOO0lI:= X"01E81186CAE0";Ol01lOl0:= X"7C6000AFDC04";lO10IO1O:= X"0925C1F04A51";ll0O01OO:= X"02AEE1236673";
              IlOl010O:= X"7C62DCCA2189";IIOl10O0:= X"0925C0CC050F";IO0l01l0:= X"02AEE1237E91";
              O10011OO:= X"092223A8CF31";OlIII0l1:= X"02AEE1BD14E9";
      when "01000100" => 
              O0lOO0lI:= X"01E3922456C7";Ol01lOl0:= X"7C65B8E0EFC3";lO10IO1O:= X"091E87A93B33";ll0O01OO:= X"02B803473F7E";
              IlOl010O:= X"7C688E3C2E93";IIOl10O0:= X"091E8687A75E";IO0l01l0:= X"02B803475764";
              O10011OO:= X"091AEF15E38E";OlIII0l1:= X"02B803DFFBC7";
      when "01000101" => 
              O0lOO0lI:= X"01DF20A2E2C4";Ol01lOl0:= X"7C6B6393C57B";lO10IO1O:= X"091758C511F8";ll0O01OO:= X"02C11E36852D";
              IlOl010O:= X"7C6E3244C006";IIOl10O0:= X"091757A62751";IO0l01l0:= X"02C11E369CDA";
              O10011OO:= X"0913C5D86C12";OlIII0l1:= X"02C11ECE5181";
      when "01000110" => 
              O0lOO0lI:= X"01DABCF6F771";Ol01lOl0:= X"7C7100F25F21";lO10IO1O:= X"09103528FBC9";ll0O01OO:= X"02CA31FC8CF3";
              IlOl010O:= X"7C73C90DCDA9";IIOl10O0:= X"0910340CB213";IO0l01l0:= X"02CA31FCA468";
              O10011OO:= X"090CA7D5BFE1";OlIII0l1:= X"02CA32936B88";
      when "01000111" => 
              O0lOO0lI:= X"01D66730A86C";Ol01lOl0:= X"7C769125F890";lO10IO1O:= X"09091CBA79DC";ll0O01OO:= X"02D33EA4919E";
              IlOl010O:= X"7C7952C0C715";IIOl10O0:= X"09091BA0C8AB";IO0l01l0:= X"02D33EA4A8DD";
              O10011OO:= X"090594F38974";OlIII0l1:= X"02D33F3A84A0";
      when "01001000" => 
              O0lOO0lI:= X"01D21EC297EA";Ol01lOl0:= X"7C7C14582973";lO10IO1O:= X"09020F5F5FA8";ll0O01OO:= X"02DC4439B3A5";
              IlOl010O:= X"7C7ECF865155";IIOl10O0:= X"09020E483F0F";IO0l01l0:= X"02DC4439CAAE";
              O10011OO:= X"08FE8D17C560";OlIII0l1:= X"02DC44CEBD3A";
      when "01001001" => 
              O0lOO0lI:= X"01CDE3AF3501";Ol01lOl0:= X"7C818AB10898";lO10IO1O:= X"08FB0CFDD281";ll0O01OO:= X"02E542C6F97B";
              IlOl010O:= X"7C843F869559";IIOl10O0:= X"08FB0BE93A79";IO0l01l0:= X"02E542C7104F";
              O10011OO:= X"08F79028C10F";OlIII0l1:= X"02E5435B1BC3";
      when "01001010" => 
              O0lOO0lI:= X"01C9B59A8A8F";Ol01lOl0:= X"7C86F458A82C";lO10IO1O:= X"08F4157C47B1";ll0O01OO:= X"02EE3A574FE3";
              IlOl010O:= X"7C89A2E9160C";IIOl10O0:= X"08F4146A3074";IO0l01l0:= X"02EE3A576681";
              O10011OO:= X"08F09E0D198A";OlIII0l1:= X"02EE3AEA8CF5";
      when "01001011" => 
              O0lOO0lI:= X"01C59439BB66";Ol01lOl0:= X"7C8C51766677";lO10IO1O:= X"08ED28C1838D";ll0O01OO:= X"02F72AF58A39";
              IlOl010O:= X"7C8EF9D4B425";IIOl10O0:= X"08ED27B1E594";IO0l01l0:= X"02F72AF5A0A2";
              O10011OO:= X"08E9B6ABBA48";OlIII0l1:= X"02F72B87E429";
      when "01001100" => 
              O0lOO0lI:= X"01C17FB99A1F";Ol01lOl0:= X"7C91A23040DC";lO10IO1O:= X"08E646B498A9";ll0O01OO:= X"030014AC62C7";
              IlOl010O:= X"7C94446FD21A";IIOl10O0:= X"08E645A76C26";IO0l01l0:= X"030014AC78FD";
              O10011OO:= X"08E2D9EBDBF7";OlIII0l1:= X"0300153DDBA0";
      when "01001101" => 
              O0lOO0lI:= X"01BD77E64B2D";Ol01lOl0:= X"7C96E6AC4480";lO10IO1O:= X"08DF6F3CE5ED";ll0O01OO:= X"0308F7867B0F";
              IlOl010O:= X"7C9982E028D3";IIOl10O0:= X"08DF6E32233A";IO0l01l0:= X"0308F7869113";
              O10011OO:= X"08DC07B50363";OlIII0l1:= X"0308F81714D8";
      when "01001110" => 
              O0lOO0lI:= X"01B97C048AFB";Ol01lOl0:= X"7C9C1F10DE6D";lO10IO1O:= X"08D8A2421545";ll0O01OO:= X"0311D38E5C19";
              IlOl010O:= X"7C9EB54AE934";IIOl10O0:= X"08D8A139B557";IO0l01l0:= X"0311D38E71EA";
              O10011OO:= X"08D53FEF0041";OlIII0l1:= X"0311D41E18D1";
      when "01001111" => 
              O0lOO0lI:= X"01B58C53C706";Ol01lOl0:= X"7CA14B823875";lO10IO1O:= X"08D1DFAC1BE1";ll0O01OO:= X"031AA8CE76BB";
              IlOl010O:= X"7CA3DBD4B2CF";IIOl10O0:= X"08D1DEA6176D";IO0l01l0:= X"031AA8CE8C5B";
              O10011OO:= X"08CE8281EC1F";OlIII0l1:= X"031AA95D585C";
      when "01010000" => 
              O0lOO0lI:= X"01B1A8B3CDA1";Ol01lOl0:= X"7CA66C249814";lO10IO1O:= X"08CB276337E3";ll0O01OO:= X"0323775123E6";
              IlOl010O:= X"7CA8F6A1A47C";IIOl10O0:= X"08CB265F87A1";IO0l01l0:= X"032377513954";
              O10011OO:= X"08C7CF562945";OlIII0l1:= X"032377DF2C62";
      when "01010001" => 
              O0lOO0lI:= X"01ADD0EDBC0C";Ol01lOl0:= X"7CAB811BDFDA";lO10IO1O:= X"08C4794FEF85";ll0O01OO:= X"032C3F20A4EB";
              IlOl010O:= X"7CAE05D54705";IIOl10O0:= X"08C4784E8C5D";IO0l01l0:= X"032C3F20BA28";
              O10011OO:= X"08C1265461A3";OlIII0l1:= X"032C3FADD630";
      when "01010010" => 
              O0lOO0lI:= X"01AA0496D576";Ol01lOl0:= X"7CB08A8BC73A";lO10IO1O:= X"08BDD55B0FF8";ll0O01OO:= X"0335004723C7";
              IlOl010O:= X"7CB30992A907";IIOl10O0:= X"08BDD45BF316";IO0l01l0:= X"0335004738D5";
              O10011OO:= X"08BA876585BF";OlIII0l1:= X"033500D37FBE";
      when "01010011" => 
              O0lOO0lI:= X"01A643CC9B97";Ol01lOl0:= X"7CB5889698F7";lO10IO1O:= X"08B73B6DACEC";ll0O01OO:= X"033DBACEB368";
              IlOl010O:= X"7CB801FC4F12";IIOl10O0:= X"08B73A70CF60";IO0l01l0:= X"033DBACEC845";
              O10011OO:= X"08B3F272CBAE";OlIII0l1:= X"033DBB5A3BF1";
      when "01010100" => 
              O0lOO0lI:= X"01A28E1AB905";Ol01lOl0:= X"7CBA7B5F1777";lO10IO1O:= X"08B0AB711EA3";ll0O01OO:= X"03466EC14FEF";
              IlOl010O:= X"7CBCEF3440D1";IIOl10O0:= X"08B0AA7679CE";IO0l01l0:= X"03466EC1649E";
              O10011OO:= X"08AD6765AE0E";OlIII0l1:= X"03466F4C06E8";
      when "01010101" => 
              O0lOO0lI:= X"019EE37DC3FC";Ol01lOl0:= X"7CBF6306BEE8";lO10IO1O:= X"08AA254F01CC";ll0O01OO:= X"034F1C28DEFB";
              IlOl010O:= X"7CC1D15BFACE";IIOl10O0:= X"08AA24568F0C";IO0l01l0:= X"034F1C28F37B";
              O10011OO:= X"08A6E627EB07";OlIII0l1:= X"034F1CB2C639";
      when "01010110" => 
              O0lOO0lI:= X"019B43E80CBC";Ol01lOl0:= X"7CC43FAEABC4";lO10IO1O:= X"08A3A8F13608";ll0O01OO:= X"0357C30F2FE7";
              IlOl010O:= X"7CC6A8948A63";IIOl10O0:= X"08A3A7FAEEBC";IO0l01l0:= X"0357C30F4439";
              O10011OO:= X"08A06EA38347";OlIII0l1:= X"0357C398493D";
      when "01010111" => 
              O0lOO0lI:= X"0197AF383F07";Ol01lOl0:= X"7CC9117796E1";lO10IO1O:= X"089D3641DD02";ll0O01OO:= X"0360637DFC0F";
              IlOl010O:= X"7CCB74FE75EC";IIOl10O0:= X"089D354DBA9D";IO0l01l0:= X"0360637E1035";
              O10011OO:= X"089A00C2B914";OlIII0l1:= X"036064064948";
      when "01011000" => 
              O0lOO0lI:= X"019424B6C6F5";Ol01lOl0:= X"7CCDD882C783";lO10IO1O:= X"0896CD2B58F7";ll0O01OO:= X"0368FD7EE713";
              IlOl010O:= X"7CD036B9D687";IIOl10O0:= X"0896CC39557A";IO0l01l0:= X"0368FD7EFB0C";
              O10011OO:= X"08939C700F51";OlIII0l1:= X"0368FE0669F6";
      when "01011001" => 
              O0lOO0lI:= X"0190A50738DD";Ol01lOl0:= X"7CD294EEBA89";lO10IO1O:= X"08906D984D71";ll0O01OO:= X"0371911B7F13";
              IlOl010O:= X"7CD4EDE6437D";IIOl10O0:= X"08906CA86251";IO0l01l0:= X"0371911B92E0";
              O10011OO:= X"088D41964895";OlIII0l1:= X"037191A23961";
      when "01011010" => 
              O0lOO0lI:= X"018D2F96EB18";Ol01lOl0:= X"7CD746DB853E";lO10IO1O:= X"088A17739C37";ll0O01OO:= X"037A1E5D3CF5";
              IlOl010O:= X"7CD99AA2E6F7";IIOl10O0:= X"088A1685C350";IO0l01l0:= X"037A1E5D5095";
              O10011OO:= X"0886F0206637";OlIII0l1:= X"037A1EE33069";
      when "01011011" => 
              O0lOO0lI:= X"0189C457A8C1";Ol01lOl0:= X"7CDBEE67F7AD";lO10IO1O:= X"0883CAA865BD";ll0O01OO:= X"0382A54D849C";
              IlOl010O:= X"7CDE3D0E7850";IIOl10O0:= X"0883C9BC98F8";IO0l01l0:= X"0382A54D9811";
              O10011OO:= X"0880A7F9A76F";OlIII0l1:= X"0382A5D2B2EE";
      when "01011100" => 
              O0lOO0lI:= X"0186630620C2";Ol01lOl0:= X"7CE08BB2BEB8";lO10IO1O:= X"087D872207C3";ll0O01OO:= X"038B25F5A52E";
              IlOl010O:= X"7CE2D547487F";IIOl10O0:= X"087D86384128";IO0l01l0:= X"038B25F5B878";
              O10011OO:= X"087A690D8872";OlIII0l1:= X"038B267A1010";
      when "01011101" => 
              O0lOO0lI:= X"01830B91EA10";Ol01lOl0:= X"7CE51ED9C0FD";lO10IO1O:= X"08774CCC1CC0";ll0O01OO:= X"0393A05ED94B";
              IlOl010O:= X"7CE7636B1529";IIOl10O0:= X"08774BE45674";IO0l01l0:= X"0393A05EEC6C";
              O10011OO:= X"08743347C189";OlIII0l1:= X"0393A0E2826A";
      when "01011110" => 
              O0lOO0lI:= X"017FBE109177";Ol01lOl0:= X"7CE9A7FA3C98";lO10IO1O:= X"08711B927AF3";ll0O01OO:= X"039C1492474D";
              IlOl010O:= X"7CEBE79756C2";IIOl10O0:= X"08711AACAEED";IO0l01l0:= X"039C14925A44";
              O10011OO:= X"086E06944643";OlIII0l1:= X"039C15153051";
      when "01011111" => 
              O0lOO0lI:= X"017C79D7B3EF";Ol01lOl0:= X"7CEE2732531D";lO10IO1O:= X"086AF36132C1";ll0O01OO:= X"03A482990181";
              IlOl010O:= X"7CF061E9102A";IIOl10O0:= X"086AF27D5B86";IO0l01l0:= X"03A48299144E";
              O10011OO:= X"0867E2DF4497";OlIII0l1:= X"03A4831B2C0D";
      when "01100000" => 
              O0lOO0lI:= X"01793F376EFD";Ol01lOl0:= X"7CF29C9E03C0";lO10IO1O:= X"0864D4248F74";ll0O01OO:= X"03ACEA7C0660";
              IlOl010O:= X"7CF4D27CCB2C";IIOl10O0:= X"0864D342A741";IO0l01l0:= X"03ACEA7C1904";
              O10011OO:= X"0861C815240B";OlIII0l1:= X"03ACEAFD7412";
      when "01100001" => 
              O0lOO0lI:= X"01760E19E033";Ol01lOl0:= X"7CF70859992A";lO10IO1O:= X"085EBDC9151F";ll0O01OO:= X"03B54C4440CC";
              IlOl010O:= X"7CF9396EC08B";IIOl10O0:= X"085EBCE9162E";IO0l01l0:= X"03B54C445348";
              O10011OO:= X"085BB62284EF";OlIII0l1:= X"03B54CC4F33F";
      when "01100010" => 
              O0lOO0lI:= X"0172E5E050B7";Ol01lOl0:= X"7CFB6A81E77F";lO10IO1O:= X"0858B03B7FBB";ll0O01OO:= X"03BDA7FA8849";
              IlOl010O:= X"7CFD96DAB74A";IIOl10O0:= X"0858AF5D64CB";IO0l01l0:= X"03BDA7FA9A9D";
              O10011OO:= X"0855ACF43F84";OlIII0l1:= X"03BDA87A8112";
      when "01100011" => 
              O0lOO0lI:= X"016FC6FE17BB";Ol01lOl0:= X"7CFFC33187A3";lO10IO1O:= X"0852AB68C3C0";ll0O01OO:= X"03C5FDA7A131";
              IlOl010O:= X"7D01EADC062F";IIOl10O0:= X"0852AA8C8732";IO0l01l0:= X"03C5FDA7B35D";
              O10011OO:= X"084FAC776339";OlIII0l1:= X"03C5FE26E1E0";
      when "01100100" => 
              O0lOO0lI:= X"016CB0FBFD7E";Ol01lOl0:= X"7D041284419D";lO10IO1O:= X"084CAF3E0BA3";ll0O01OO:= X"03CE4D543CED";
              IlOl010O:= X"7D06358DC237";IIOl10O0:= X"084CAE63A823";IO0l01l0:= X"03CE4D544EF2";
              O10011OO:= X"0849B49935E6";OlIII0l1:= X"03CE4DD2C70E";
      when "01100101" => 
              O0lOO0lI:= X"0169A3ADBF2E";Ol01lOl0:= X"7D085894F8D9";lO10IO1O:= X"0846BBA8B823";ll0O01OO:= X"03D69708FA2E";
              IlOl010O:= X"7D0A770A82CA";IIOl10O0:= X"0846BAD02884";IO0l01l0:= X"03D697090C0D";
              O10011OO:= X"0843C5473307";OlIII0l1:= X"03D69786CF49";
      when "01100110" => 
              O0lOO0lI:= X"01669F427E32";Ol01lOl0:= X"7D0C957DA005";lO10IO1O:= X"0840D0965F86";ll0O01OO:= X"03DEDACE651E";
              IlOl010O:= X"7D0EAF6C872B";IIOl10O0:= X"0840CFBF9E75";IO0l01l0:= X"03DEDACE76D7";
              O10011OO:= X"083DDE6F0AFC";OlIII0l1:= X"03DEDB4B86B8";
      when "01100111" => 
              O0lOO0lI:= X"0163A32C7BC1";Ol01lOl0:= X"7D10C958FE63";lO10IO1O:= X"083AEDF4CC09";ll0O01OO:= X"03E718ACF79B";
              IlOl010O:= X"7D12DECDC21F";IIOl10O0:= X"083AED1FD489";IO0l01l0:= X"03E718AD092E";
              O10011OO:= X"0837FFFEA24C";OlIII0l1:= X"03E719296731";
      when "01101000" => 
              O0lOO0lI:= X"0160AF77C5A1";Ol01lOl0:= X"7D14F4408AA0";lO10IO1O:= X"083513B1FC21";ll0O01OO:= X"03EF50AD1963";
              IlOl010O:= X"7D170547BB9B";IIOl10O0:= X"083512DEC931";IO0l01l0:= X"03EF50AD2AD1";
              O10011OO:= X"083229E410ED";OlIII0l1:= X"03EF5128D870";
      when "01101001" => 
              O0lOO0lI:= X"015DC4708490";Ol01lOl0:= X"7D19164CE85D";lO10IO1O:= X"082F41BC219B";ll0O01OO:= X"03F782D7204F";
              IlOl010O:= X"7D1B22F3914E";IIOl10O0:= X"082F40EAAE00";IO0l01l0:= X"03F782D73198";
              O10011OO:= X"082C5C0DA190";OlIII0l1:= X"03F78352304A";
      when "01101010" => 
              O0lOO0lI:= X"015AE1629904";Ol01lOl0:= X"7D1D2F981D84";lO10IO1O:= X"082978019FC4";ll0O01OO:= X"03FFAF335082";
              IlOl010O:= X"7D1F37EA33D1";IIOl10O0:= X"08297731E6B8";IO0l01l0:= X"03FFAF3361A6";
              O10011OO:= X"08269669D0EC";OlIII0l1:= X"03FFAFADB2DE";
      when "01101011" => 
              O0lOO0lI:= X"0158067FEC1A";Ol01lOl0:= X"7D21403A4F3E";lO10IO1O:= X"0823B6710C57";ll0O01OO:= X"0407D5C9DC9B";
              IlOl010O:= X"7D234444105C";IIOl10O0:= X"0823B5A308FA";IO0l01l0:= X"0407D5C9ED9B";
              O10011OO:= X"0820D8E74D0A";OlIII0l1:= X"0407D64392C6";
      when "01101100" => 
              O0lOO0lI:= X"015533A093B0";Ol01lOl0:= X"7D25484BE2FA";lO10IO1O:= X"081DFCF92DC8";ll0O01OO:= X"040FF6A2E5E8";
              IlOl010O:= X"7D2748194EDC";IIOl10O0:= X"081DFC2CDB52";IO0l01l0:= X"040FF6A2F6C5";
              O10011OO:= X"081B2374F4A0";OlIII0l1:= X"040FF71BF14D";
      when "01101101" => 
              O0lOO0lI:= X"015268973A5C";Ol01lOl0:= X"7D2947E4F20F";lO10IO1O:= X"08184B88FAD7";ll0O01OO:= X"041811C67C96";
              IlOl010O:= X"7D2B4381D248";IIOl10O0:= X"08184ABE548E";IO0l01l0:= X"041811C68D4F";
              O10011OO:= X"08157601D65F";OlIII0l1:= X"0418123EDE9A";
      when "01101110" => 
              O0lOO0lI:= X"014FA55EB82D";Ol01lOl0:= X"7D2D3F1D06BA";lO10IO1O:= X"0812A20F9A07";ll0O01OO:= X"0420273C9FDE";
              IlOl010O:= X"7D2F36950D08";IIOl10O0:= X"0812A1469B46";IO0l01l0:= X"0420273CB074";
              O10011OO:= X"080FD07D3052";OlIII0l1:= X"042027B459E4";
      when "01101111" => 
              O0lOO0lI:= X"014CE9F278BF";Ol01lOl0:= X"7D312E0B5324";lO10IO1O:= X"080D007C60E5";ll0O01OO:= X"0428370D3E3A";
              IlOl010O:= X"7D33216A4027";IIOl10O0:= X"080CFFB504EF";IO0l01l0:= X"0428370D4EAE";
              O10011OO:= X"080A32D66F30";OlIII0l1:= X"0428378451A2";
      when "01110000" => 
              O0lOO0lI:= X"014A35E2D8EC";Ol01lOl0:= X"7D3514C76BD4";lO10IO1O:= X"080766BED309";ll0O01OO:= X"043041403591";
              IlOl010O:= X"7D3704183BBA";IIOl10O0:= X"080765F91587";IO0l01l0:= X"0430414045E2";
              O10011OO:= X"08049CFD2DC2";OlIII0l1:= X"043041B6A3B4";
      when "01110001" => 
              O0lOO0lI:= X"014789687078";Ol01lOl0:= X"7D38F3677EF2";lO10IO1O:= X"0801D4C6A24C";ll0O01OO:= X"043845DD5361";
              IlOl010O:= X"7D3ADEB59827";IIOl10O0:= X"0801D4027EAC";IO0l01l0:= X"043845DD6390";
              O10011OO:= X"07FF0EE13444";OlIII0l1:= X"043846531D97";
      when "01110010" => 
              O0lOO0lI:= X"0144E45E9EC5";Ol01lOl0:= X"7D3CCA0204B8";lO10IO1O:= X"07FC4A83AD63";ll0O01OO:= X"044044EC54F4";
              IlOl010O:= X"7D3EB158970A";IIOl10O0:= X"07FC49C11F29";IO0l01l0:= X"044044EC6502";
              O10011OO:= X"07F9887277C1";OlIII0l1:= X"044045617C91";
      when "01110011" => 
              O0lOO0lI:= X"0142467FC01D";Ol01lOl0:= X"7D4098AD6A4D";lO10IO1O:= X"07F6C7E5FF63";ll0O01OO:= X"04483E74E788";
              IlOl010O:= X"7D427C172C42";IIOl10O0:= X"07F6C725024F";IO0l01l0:= X"04483E74F775";
              O10011OO:= X"07F409A1197C";OlIII0l1:= X"04483EE96DDB";
      when "01110100" => 
              O0lOO0lI:= X"013FAFDBB1E9";Ol01lOl0:= X"7D445F7F34C5";lO10IO1O:= X"07F14CDDCF9F";ll0O01OO:= X"0450327EA87B";
              IlOl010O:= X"7D463F0702A5";IIOl10O0:= X"07F14C1E5F58";IO0l01l0:= X"0450327EB847";
              O10011OO:= X"07EE925D665B";OlIII0l1:= X"045032F28ED1";
      when "01110101" => 
              O0lOO0lI:= X"013D20532193";Ol01lOl0:= X"7D481E8CFACF";lO10IO1O:= X"07EBD95B808C";ll0O01OO:= X"04582111257A";
              IlOl010O:= X"7D49FA3D7CD7";IIOl10O0:= X"07EBD89D98D1";IO0l01l0:= X"045821113526";
              O10011OO:= X"07E92297D64F";OlIII0l1:= X"045821846D1A";
      when "01110110" => 
              O0lOO0lI:= X"013A97C76F7D";Ol01lOl0:= X"7D4BD5EBF9A0";lO10IO1O:= X"07E66D4F9F70";ll0O01OO:= X"04600A33DCA8";
              IlOl010O:= X"7D4DADCFAF97";IIOl10O0:= X"07E66C933C0E";IO0l01l0:= X"04600A33EC33";
              O10011OO:= X"07E3BA410BBE";OlIII0l1:= X"04600AA686D8";
      when "01110111" => 
              O0lOO0lI:= X"0138160CF164";Ol01lOl0:= X"7D4F85B15021";lO10IO1O:= X"07E108AAE3A0";ll0O01OO:= X"0467EDEE3CCB";
              IlOl010O:= X"7D5159D26B79";IIOl10O0:= X"07E107F0008B";IO0l01l0:= X"0467EDEE4C37";
              O10011OO:= X"07DE5949D2F8";OlIII0l1:= X"0467EE604ACD";
      when "01111000" => 
              O0lOO0lI:= X"01359B2AFE31";Ol01lOl0:= X"7D532DF17026";lO10IO1O:= X"07DBAB5E2E50";ll0O01OO:= X"046FCC47A576";
              IlOl010O:= X"7D54FE5A363B";IIOl10O0:= X"07DBAAA4C76C";IO0l01l0:= X"046FCC47B4C2";
              O10011OO:= X"07D8FFA321A1";OlIII0l1:= X"046FCCB91888";
      when "01111001" => 
              O0lOO0lI:= X"013326BEEA2E";Ol01lOl0:= X"7D56CEC14545";lO10IO1O:= X"07D6555A895A";ll0O01OO:= X"0477A5476731";
              IlOl010O:= X"7D589B7B595F";IIOl10O0:= X"07D654A29AD9";IO0l01l0:= X"0477A547765E";
              O10011OO:= X"07D3AD3E1632";OlIII0l1:= X"0477A5B8408E";
      when "01111010" => 
              O0lOO0lI:= X"0130B942A83C";Ol01lOl0:= X"7D5A6833F500";lO10IO1O:= X"07D1069127E7";ll0O01OO:= X"047F78F4C3A2";
              IlOl010O:= X"7D5C3149DBD2";IIOl10O0:= X"07D105DAAD81";IO0l01l0:= X"047F78F4D2B1";
              O10011OO:= X"07CE620BF75D";OlIII0l1:= X"047F79650482";
      when "01111011" => 
              O0lOO0lI:= X"012E522251A6";Ol01lOl0:= X"7D5DFA5E35F3";lO10IO1O:= X"07CBBEF36432";ll0O01OO:= X"04874756EDB7";
              IlOl010O:= X"7D5FBFD96690";IIOl10O0:= X"07CBBE3E5A2F";IO0l01l0:= X"04874756FCA8";
              O10011OO:= X"07C91DFE3396";OlIII0l1:= X"048747C6974E";
      when "01111100" => 
              O0lOO0lI:= X"012BF1792BFB";Ol01lOl0:= X"7D6185534D42";lO10IO1O:= X"07C67E72C084";ll0O01OO:= X"048F107509CC";
              IlOl010O:= X"7D63473D7B58";IIOl10O0:= X"07C67DBF2304";IO0l01l0:= X"048F1075189E";
              O10011OO:= X"07C3E106607E";OlIII0l1:= X"048F10E41D4A";
      when "01111101" => 
              O0lOO0lI:= X"0129975AE469";Ol01lOl0:= X"7D650926510E";lO10IO1O:= X"07C14500E611";ll0O01OO:= X"0496D4562DD1";
              IlOl010O:= X"7D66C7895A8F";IIOl10O0:= X"07C1444EB117";IO0l01l0:= X"0496D4563C85";
              O10011OO:= X"07BEAB163A72";OlIII0l1:= X"0496D4C4AC65";
      when "01111110" => 
              O0lOO0lI:= X"0127435932CE";Ol01lOl0:= X"7D6885EAEA02";lO10IO1O:= X"07BC128FA414";ll0O01OO:= X"049E93016175";
              IlOl010O:= X"7D6A40CFF3A7";IIOl10O0:= X"07BC11DED401";IO0l01l0:= X"049E9301700C";
              O10011OO:= X"07B97C1FA3F5";OlIII0l1:= X"049E936F4C49";
      when "01111111" => 
              O0lOO0lI:= X"0124F5929AAC";Ol01lOl0:= X"7D6BFBB39E46";lO10IO1O:= X"07B6E710F029";ll0O01OO:= X"04A64C7D9E47";
              IlOl010O:= X"7D6DB323F9D8";IIOl10O0:= X"07B6E6618146";IO0l01l0:= X"04A64C7DACC1";
              O10011OO:= X"07B45414A541";OlIII0l1:= X"04A64CEAF683";
      when "10000000" => 
              O0lOO0lI:= X"0122ADE71306";Ol01lOl0:= X"7D6F6A931702";lO10IO1O:= X"07B1C276E52A";ll0O01OO:= X"04AE00D1CFE0";
              IlOl010O:= X"7D711E97EDAB";IIOl10O0:= X"07B1C1C8D3D1";IO0l01l0:= X"04AE00D1DE3D";
              O10011OO:= X"07AF32E76BBE";OlIII0l1:= X"04AE013E96A9";
      when "10000001" => 
              O0lOO0lI:= X"01206C66D746";Ol01lOl0:= X"7D72D29B71FA";lO10IO1O:= X"07ACA4B3C312";ll0O01OO:= X"04B5B004D406";
              IlOl010O:= X"7D74833E0E92";IIOl10O0:= X"07ACA4070B84";IO0l01l0:= X"04B5B004E247";
              O10011OO:= X"07AA188A4991";OlIII0l1:= X"04B5B0710A7D";
      when "10000010" => 
              O0lOO0lI:= X"011E30A409EA";Ol01lOl0:= X"7D7633DF6CED";lO10IO1O:= X"07A78DB9EDDD";ll0O01OO:= X"04BD5A1D7AD1";
              IlOl010O:= X"7D77E1285A4C";IIOl10O0:= X"07A78D0E8CC1";IO0l01l0:= X"04BD5A1D88F6";
              O10011OO:= X"07A504EFB51A";OlIII0l1:= X"04BD5A892214";
      when "10000011" => 
              O0lOO0lI:= X"011BFAFEB923";Ol01lOl0:= X"7D798E7019ED";lO10IO1O:= X"07A27D7BEE53";ll0O01OO:= X"04C4FF2286CF";
              IlOl010O:= X"7D7B38689FA0";IIOl10O0:= X"07A27CD1DFDD";IO0l01l0:= X"04C4FF2294D8";
              O10011OO:= X"079FF80A487F";OlIII0l1:= X"04C4FF8D9FFA";
      when "10000100" => 
              O0lOO0lI:= X"0119CAED5EC8";Ol01lOl0:= X"7D7CE25FF84E";lO10IO1O:= X"079D73EC6FE1";ll0O01OO:= X"04CC9F1AAD29";
              IlOl010O:= X"7D7E8910530A";IIOl10O0:= X"079D7343B0E2";IO0l01l0:= X"04CC9F1ABB15";
              O10011OO:= X"079AF1CCC134";OlIII0l1:= X"04CC9F853954";
      when "10000101" => 
              O0lOO0lI:= X"0117A0F25C06";Ol01lOl0:= X"7D802FBF6E70";lO10IO1O:= X"079870FE4203";ll0O01OO:= X"04D43A0C95C3";
              IlOl010O:= X"7D81D330DB4F";IIOl10O0:= X"07987056CEB6";IO0l01l0:= X"04D43A0CA395";
              O10011OO:= X"0795F229FF91";OlIII0l1:= X"04D43A769605";
      when "10000110" => 
              O0lOO0lI:= X"01157C419A12";Ol01lOl0:= X"7D8376A0EDD7";lO10IO1O:= X"079374A455B7";ll0O01OO:= X"04DBCFFEDB66";
              IlOl010O:= X"7D8516DB48C1";IIOl10O0:= X"079373FE2B06";IO0l01l0:= X"04DBCFFEE91C";
              O10011OO:= X"0790F915064F";OlIII0l1:= X"04DBD06850D1";
      when "10000111" => 
              O0lOO0lI:= X"01135D63F7A4";Ol01lOl0:= X"7D86B7146978";lO10IO1O:= X"078E7ED1BF49";ll0O01OO:= X"04E360F80BD9";
              IlOl010O:= X"7D8854208815";IIOl10O0:= X"078E7E2CD99C";IO0l01l0:= X"04E360F81974";
              O10011OO:= X"078C0680FA26";OlIII0l1:= X"04E36160F77D";
      when "10001000" => 
              O0lOO0lI:= X"011143F3E460";Ol01lOl0:= X"7D89F12B3BBC";lO10IO1O:= X"07898F79B3FB";ll0O01OO:= X"04EAECFEA80A";
              IlOl010O:= X"7D8B8B112ED1";IIOl10O0:= X"07898ED61026";IO0l01l0:= X"04EAECFEB58B";
              O10011OO:= X"07871A612156";OlIII0l1:= X"04EAED670AF4";
      when "10001001" => 
              O0lOO0lI:= X"010F2FEDB21C";Ol01lOl0:= X"7D8D24F5D64B";lO10IO1O:= X"0784A68F8ABB";ll0O01OO:= X"04F27419242D";
              IlOl010O:= X"7D8EBBBDBE75";IIOl10O0:= X"0784A5ED2581";IO0l01l0:= X"04F274193194";
              O10011OO:= X"078234A8E341";OlIII0l1:= X"04F27480FF68";
      when "10001010" => 
              O0lOO0lI:= X"010D2158D647";Ol01lOl0:= X"7D905284648B";lO10IO1O:= X"077FC406BB6A";ll0O01OO:= X"04F9F64DE7DD";
              IlOl010O:= X"7D91E6366BFD";IIOl10O0:= X"077FC3659187";IO0l01l0:= X"04F9F64DF52A";
              O10011OO:= X"077D554BC7F3";OlIII0l1:= X"04F9F6B53C72";
      when "10001011" => 
              O0lOO0lI:= X"010B1805DC9E";Ol01lOl0:= X"7D9379E742FA";lO10IO1O:= X"077AE7D2DE30";ll0O01OO:= X"050173A34E3F";
              IlOl010O:= X"7D950A8B49EF";IIOl10O0:= X"077AE732EC80";IO0l01l0:= X"050173A35B71";
              O10011OO:= X"07787C3D77CB";OlIII0l1:= X"0501740A1D31";
      when "10001100" => 
              O0lOO0lI:= X"01091405AC4A";Ol01lOl0:= X"7D969B2E26BC";lO10IO1O:= X"077611E7AB81";ll0O01OO:= X"0508EC1FA61C";
              IlOl010O:= X"7D9828CC2CA4";IIOl10O0:= X"07761148EED2";IO0l01l0:= X"0508EC1FB335";
              O10011OO:= X"0773A971BAFF";OlIII0l1:= X"0508EC85F06F";
      when "10001101" => 
              O0lOO0lI:= X"0107152FA698";Ol01lOl0:= X"7D99B668EEDF";lO10IO1O:= X"07714238FB57";ll0O01OO:= X"05105FC9320A";
              IlOl010O:= X"7D9B4108BBF1";IIOl10O0:= X"0771419B7085";IO0l01l0:= X"05105FC93F0A";
              O10011OO:= X"076EDCDC7942";OlIII0l1:= X"0510602EF8BE";
      when "10001110" => 
              O0lOO0lI:= X"01051B78A8E6";Ol01lOl0:= X"7D9CCBA7222C";lO10IO1O:= X"076C78BAC4FB";ll0O01OO:= X"0517CEA62883";
              IlOl010O:= X"7D9E53505C3A";IIOl10O0:= X"076C781E68FF";IO0l01l0:= X"0517CEA6356A";
              O10011OO:= X"076A1671B95D";OlIII0l1:= X"0517CF0B6C95";
      when "10001111" => 
              O0lOO0lI:= X"010326B511D7";Ol01lOl0:= X"7D9FDAF8465C";lO10IO1O:= X"0767B5611E85";ll0O01OO:= X"051F38BCB40B";
              IlOl010O:= X"7DA15FB258B4";IIOl10O0:= X"0767B4C5EE6C";IO0l01l0:= X"051F38BCC0D9";
              O10011OO:= X"07655625A0C6";OlIII0l1:= X"051F39217676";
      when "10010000" => 
              O0lOO0lI:= X"0101371FDD39";Ol01lOl0:= X"7DA2E46B01AC";lO10IO1O:= X"0762F8203CE4";ll0O01OO:= X"05269E12F348";
              IlOl010O:= X"7DA4663DB596";IIOl10O0:= X"0762F7863590";IO0l01l0:= X"05269E12FFFE";
              O10011OO:= X"07609BEC7345";OlIII0l1:= X"05269E773505";
      when "10010001" => 
              O0lOO0lI:= X"00FF4C1D63D4";Ol01lOl0:= X"7DA5E80F39A8";lO10IO1O:= X"075E40EC7270";ll0O01OO:= X"052DFEAEF927";
              IlOl010O:= X"7DA767015D50";IIOl10O0:= X"075E40539132";IO0l01l0:= X"052DFEAF05C5";
              O10011OO:= X"075BE7BA9290";OlIII0l1:= X"052DFF12BB2B";
      when "10010010" => 
              O0lOO0lI:= X"00FD66316E39";Ol01lOl0:= X"7DA8E5F2BA79";lO10IO1O:= X"07598FBA302D";ll0O01OO:= X"05355A96CCF5";
              IlOl010O:= X"7DAA620C0333";IIOl10O0:= X"07598F2271E4";IO0l01l0:= X"05355A96D97A";
              O10011OO:= X"075739847DE8";OlIII0l1:= X"05355AFA1033";
      when "10010011" => 
              O0lOO0lI:= X"00FB85310008";Ol01lOl0:= X"7DABDE244B0F";lO10IO1O:= X"0754E47E03F3";ll0O01OO:= X"053CB1D06A7E";
              IlOl010O:= X"7DAD576C1596";IIOl10O0:= X"0754E3E765AF";IO0l01l0:= X"053CB1D076EC";
              O10011OO:= X"0752913ED1C5";OlIII0l1:= X"053CB2332FE8";
      when "10010100" => 
              O0lOO0lI:= X"00F9A8C2E0A5";Ol01lOl0:= X"7DAED0B2DA64";lO10IO1O:= X"07503F2C9863";ll0O01OO:= X"05440461C22B";
              IlOl010O:= X"7DB0472FF595";IIOl10O0:= X"07503E97177B";IO0l01l0:= X"05440461CE82";
              O10011OO:= X"074DEEDE476F";OlIII0l1:= X"054404C40AB0";
      when "10010101" => 
              O0lOO0lI:= X"00F7D130D525";Ol01lOl0:= X"7DB1BDABFCA9";lO10IO1O:= X"074B9FBAB574";ll0O01OO:= X"054B5250B91F";
              IlOl010O:= X"7DB33165C5C4";IIOl10O0:= X"074B9F264EE5";IO0l01l0:= X"054B5250C55E";
              O10011OO:= X"07495257B4A9";OlIII0l1:= X"054B52B285AB";
      when "10010110" => 
              O0lOO0lI:= X"00F5FE13AF9C";Ol01lOl0:= X"7DB4A51E6EAC";lO10IO1O:= X"0747061D3EA4";ll0O01OO:= X"05529BA32952";
              IlOl010O:= X"7DB6161B84E0";IIOl10O0:= X"07470589EFD5";IO0l01l0:= X"05529BA3357A";
              O10011OO:= X"0744BBA00B5A";OlIII0l1:= X"05529C047ACE";
      when "10010111" => 
              O0lOO0lI:= X"00F42FBB540C";Ol01lOl0:= X"7DB787175F6A";lO10IO1O:= X"07427249342A";ll0O01OO:= X"0559E05EE1AD";
              IlOl010O:= X"7DB8F55F0718";IIOl10O0:= X"074271B6FA20";IO0l01l0:= X"0559E05EEDBE";
              O10011OO:= X"07402AAC5928";OlIII0l1:= X"0559E0BFB902";
      when "10011000" => 
              O0lOO0lI:= X"00F265A51C22";Ol01lOl0:= X"7DBA63A55E56";lO10IO1O:= X"073DE433B105";ll0O01OO:= X"05612089A628";
              IlOl010O:= X"7DBBCF3DD466";IIOl10O0:= X"073DE3A2895F";IO0l01l0:= X"05612089B223";
              O10011OO:= X"073B9F71C734";OlIII0l1:= X"056120EA043B";
      when "10011001" => 
              O0lOO0lI:= X"00F0A033C215";Ol01lOl0:= X"7DBD3AD52CC3";lO10IO1O:= X"07395BD1EC57";ll0O01OO:= X"05685C292FE4";
              IlOl010O:= X"7DBEA3C58048";IIOl10O0:= X"07395B41D430";IO0l01l0:= X"05685C293BC8";
              O10011OO:= X"073719E599B2";OlIII0l1:= X"05685C891598";
      when "10011010" => 
              O0lOO0lI:= X"00EEDF0B0EDE";Ol01lOl0:= X"7DC00CB4BA9C";lO10IO1O:= X"0734D9193779";ll0O01OO:= X"056F93432D46";
              IlOl010O:= X"7DC173034961";IIOl10O0:= X"0734D88A2C56";IO0l01l0:= X"056F93433914";
              O10011OO:= X"073299FD2F9F";OlIII0l1:= X"056F93A29B7C";
      when "10011011" => 
              O0lOO0lI:= X"00ED2265B2A2";Ol01lOl0:= X"7DC2D950BF24";lO10IO1O:= X"07305BFEFEFA";ll0O01OO:= X"0576C5DD4211";
              IlOl010O:= X"7DC43D046003";IIOl10O0:= X"07305B70FE0D";IO0l01l0:= X"0576C5DD4DC9";
              O10011OO:= X"072E1FAE026E";OlIII0l1:= X"0576C63C39A8";
      when "10011100" => 
              O0lOO0lI:= X"00EB69FA551C";Ol01lOl0:= X"7DC5A0B6B7D4";lO10IO1O:= X"072BE478C926";ll0O01OO:= X"057DF3FD0783";
              IlOl010O:= X"7DC701D5B03C";IIOl10O0:= X"072BE3EBCFFF";IO0l01l0:= X"057DF3FD1326";
              O10011OO:= X"0729AAEDA5AF";OlIII0l1:= X"057DF45B8958";
      when "10011101" => 
              O0lOO0lI:= X"00E9B5BD5AF1";Ol01lOl0:= X"7DC862F382BE";lO10IO1O:= X"0727727C3691";ll0O01OO:= X"05851DA80C6D";
              IlOl010O:= X"7DC9C184239F";IIOl10O0:= X"072771F042A1";IO0l01l0:= X"05851DA817FA";
              O10011OO:= X"07253BB1C6C4";OlIII0l1:= X"05851E061959";
      when "10011110" => 
              O0lOO0lI:= X"00E805ABFD19";Ol01lOl0:= X"7DCB2013D9AE";lO10IO1O:= X"072305FF0162";ll0O01OO:= X"058C42E3D54D";
              IlOl010O:= X"7DCC7C1C52D6";IIOl10O0:= X"07230574103D";IO0l01l0:= X"058C42E3E0C4";
              O10011OO:= X"0720D1F02C8F";OlIII0l1:= X"058C43416E2A";
      when "10011111" => 
              O0lOO0lI:= X"00E659C17D6A";Ol01lOl0:= X"7DCDD82433BD";lO10IO1O:= X"071E9EF6FD3C";ll0O01OO:= X"059363B5DC68";
              IlOl010O:= X"7DCF31AAD1DE";IIOl10O0:= X"071E9E6D0C54";IO0l01l0:= X"059363B5E7CA";
              O10011OO:= X"071C6D9EB725";OlIII0l1:= X"05936413020B";
      when "10100000" => 
              O0lOO0lI:= X"00E4B2206F32";Ol01lOl0:= X"7DD08B30CB59";lO10IO1O:= X"071A3D5A16C2";ll0O01OO:= X"059A802391E3";
              IlOl010O:= X"7DD1E23BF73C";IIOl10O0:= X"071A3CD12386";IO0l01l0:= X"059A80239D30";
              O10011OO:= X"07180EB35F7F";OlIII0l1:= X"059A80804521";
      when "10100001" => 
              O0lOO0lI:= X"00E30E69A488";Ol01lOl0:= X"7DD339466469";lO10IO1O:= X"0715E11E5310";ll0O01OO:= X"05A198325BDD";
              IlOl010O:= X"7DD48DDBFF7E";IIOl10O0:= X"0715E0965B2B";IO0l01l0:= X"05A198326715";
              O10011OO:= X"0713B524372B";OlIII0l1:= X"05A1988E9D88";
      when "10100010" => 
              O0lOO0lI:= X"00E16ED607A8";Ol01lOl0:= X"7DD5E270B74C";lO10IO1O:= X"07118A39D01D";ll0O01OO:= X"05A8ABE79685";
              IlOl010O:= X"7DD73496FB19";IIOl10O0:= X"071189B2D10C";IO0l01l0:= X"05A8ABE7A1A9";
              O10011OO:= X"070F60E76808";OlIII0l1:= X"05A8AC43676D";
      when "10100011" => 
              O0lOO0lI:= X"00DFD30AC788";Ol01lOl0:= X"7DD886BC50FF";lO10IO1O:= X"070D38A2C388";ll0O01OO:= X"05AFBB489434";
              IlOl010O:= X"7DD9D678E26F";IIOl10O0:= X"070D381CBB13";IO0l01l0:= X"05AFBB489F44";
              O10011OO:= X"070B11F333F6";OlIII0l1:= X"05AFBBA3F529";
      when "10100100" => 
              O0lOO0lI:= X"00DE3B52A857";Ol01lOl0:= X"7DDB263471CD";lO10IO1O:= X"0708EC4F7B71";ll0O01OO:= X"05B6C65A9D87";
              IlOl010O:= X"7DDC738D6F58";IIOl10O0:= X"0708EBCA6722";IO0l01l0:= X"05B6C65AA883";
              O10011OO:= X"0706C83DF491";OlIII0l1:= X"05B6C6B58F54";
      when "10100101" => 
              O0lOO0lI:= X"00DCA7558EA0";Ol01lOl0:= X"7DDDC0E557FE";lO10IO1O:= X"0704A5365CED";ll0O01OO:= X"05BDCD22F172";
              IlOl010O:= X"7DDF0BE05C4F";IIOl10O0:= X"0704A4B23A86";IO0l01l0:= X"05BDCD22FC5A";
              O10011OO:= X"070283BE1AE4";OlIII0l1:= X"05BDCD7D74E1";
      when "10100110" => 
              O0lOO0lI:= X"00DB17142B26";Ol01lOl0:= X"7DE056DA7F87";lO10IO1O:= X"0700634DE4B5";ll0O01OO:= X"05C4CFA6C55C";
              IlOl010O:= X"7DE19F7D1A93";IIOl10O0:= X"070062CAB208";IO0l01l0:= X"05C4CFA6D030";
              O10011OO:= X"06FE446A2F23";OlIII0l1:= X"05C4D000DB35";
      when "10100111" => 
              O0lOO0lI:= X"00D98AB92424";Ol01lOl0:= X"7DE2E81F0750";lO10IO1O:= X"06FC268CA6A6";ll0O01OO:= X"05CBCDEB4532";
              IlOl010O:= X"7DE42E6F1C1B";IIOl10O0:= X"06FC260A6150";IO0l01l0:= X"05CBCDEB4FF2";
              O10011OO:= X"06FA0A38D06D";OlIII0l1:= X"05CBCE44EE3D";
      when "10101000" => 
              O0lOO0lI:= X"00D802116F90";Ol01lOl0:= X"7DE574BE7E75";lO10IO1O:= X"06F7EEE94D12";ll0O01OO:= X"05D2C7F59383";
              IlOl010O:= X"7DE6B8C199E7";IIOl10O0:= X"06F7EE67F2DE";IO0l01l0:= X"05D2C7F59E2F";
              O10011OO:= X"06F5D520B478";OlIII0l1:= X"05D2C84ED083";
      when "10101001" => 
              O0lOO0lI:= X"00D67D20F3B8";Ol01lOl0:= X"7DE7FCC3F404";lO10IO1O:= X"06F3BC5A9904";ll0O01OO:= X"05D9BDCAC990";
              IlOl010O:= X"7DE93E7FA50B";IIOl10O0:= X"06F3BBDA27B7";IO0l01l0:= X"05D9BDCAD42A";
              O10011OO:= X"06F1A518A75C";OlIII0l1:= X"05D9BE239B4A";
      when "10101010" => 
              O0lOO0lI:= X"00D4FBCD1097";Ol01lOl0:= X"7DEA803A9528";lO10IO1O:= X"06EF8ED7618E";ll0O01OO:= X"05E0AF6FF76A";
              IlOl010O:= X"7DEBBFB44531";IIOl10O0:= X"06EF8E57D704";IO0l01l0:= X"05E0AF7001F1";
              O10011OO:= X"06ED7A178B4A";OlIII0l1:= X"05E0AFC85E9D";
      when "10101011" => 
              O0lOO0lI:= X"00D37E1CF373";Ol01lOl0:= X"7DECFF2D2CBF";lO10IO1O:= X"06EB665693E7";ll0O01OO:= X"05E79CEA2402";
              IlOl010O:= X"7DEE3C6A4F56";IIOl10O0:= X"06EB65D7EDF4";IO0l01l0:= X"05E79CEA2E76";
              O10011OO:= X"06E954145843";OlIII0l1:= X"05E79D42216E";
      when "10101100" => 
              O0lOO0lI:= X"00D203EDFABE";Ol01lOl0:= X"7DEF79A6A943";lO10IO1O:= X"06E742CF32D7";ll0O01OO:= X"05EE863E4D42";
              IlOl010O:= X"7DF0B4AC8A0C";IIOl10O0:= X"06E742516F58";IO0l01l0:= X"05EE863E57A2";
              O10011OO:= X"06E533061BE2";OlIII0l1:= X"05EE8695E1A4";
      when "10101101" => 
              O0lOO0lI:= X"00D08D2C10F0";Ol01lOl0:= X"7DF1EFB1C48F";lO10IO1O:= X"06E3243856A8";ll0O01OO:= X"05F56B71681F";
              IlOl010O:= X"7DF328858513";IIOl10O0:= X"06E323BB7390";IO0l01l0:= X"05F56B71726D";
              O10011OO:= X"06E116E3F916";OlIII0l1:= X"05F56BC89433";
      when "10101110" => 
              O0lOO0lI:= X"00CF1A01BAEF";Ol01lOl0:= X"7DF46158BE38";lO10IO1O:= X"06DF0A892CF5";ll0O01OO:= X"05FC4C8860B5";
              IlOl010O:= X"7DF597FFB5F2";IIOl10O0:= X"06DF0A0D282B";IO0l01l0:= X"05FC4C886AF0";
              O10011OO:= X"06DCFFA527E1";OlIII0l1:= X"05FC4CDF2535";
      when "10101111" => 
              O0lOO0lI:= X"00CDAA6B2BA8";Ol01lOl0:= X"7DF6CEA5DD1B";lO10IO1O:= X"06DAF5B8F858";ll0O01OO:= X"060329881A54";
              IlOl010O:= X"7DF803258859";IIOl10O0:= X"06DAF53DCF97";IO0l01l0:= X"06032988247E";
              O10011OO:= X"06D8ED40F51F";OlIII0l1:= X"060329DE77F8";
      when "10110000" => 
              O0lOO0lI:= X"00CC3DDE3407";Ol01lOl0:= X"7DF937A465AB";lO10IO1O:= X"06D6E5BF0F78";ll0O01OO:= X"060A02756F9D";
              IlOl010O:= X"7DFA6A012F83";IIOl10O0:= X"06D6E544C113";IO0l01l0:= X"060A027579B5";
              O10011OO:= X"06D4DFAEC243";OlIII0l1:= X"060A02CB671B";
      when "10110001" => 
              O0lOO0lI:= X"00CAD4D47093";Ol01lOl0:= X"7DFB9C5D8C83";lO10IO1O:= X"06D2DA92DE86";ll0O01OO:= X"0610D755328F";
              IlOl010O:= X"7DFCCC9CC887";IIOl10O0:= X"06D2DA196855";IO0l01l0:= X"0610D7553C95";
              O10011OO:= X"06D0D6E6051E";OlIII0l1:= X"0610D7AAC49C";
      when "10110010" => 
              O0lOO0lI:= X"00C96F4886EA";Ol01lOl0:= X"7DFDFCDB652B";lO10IO1O:= X"06CED42BE565";ll0O01OO:= X"0617A82C2CA0";
              IlOl010O:= X"7DFF2B02526A";IIOl10O0:= X"06CED3B3454D";IO0l01l0:= X"0617A82C3694";
              O10011OO:= X"06CCD2DE479E";OlIII0l1:= X"0617A88159F0";
      when "10110011" => 
              O0lOO0lI:= X"00C80CED57BF";Ol01lOl0:= X"7E00592854DE";lO10IO1O:= X"06CAD281B7C7";ll0O01OO:= X"061E74FF1ED0";
              IlOl010O:= X"7E01853BBE0B";IIOl10O0:= X"06CAD209EBDA";IO0l01l0:= X"061E74FF28B2";
              O10011OO:= X"06C8D38F2798";OlIII0l1:= X"061E7553E814";
      when "10110100" => 
              O0lOO0lI:= X"00C6ADADE9B4";Ol01lOl0:= X"7E02B14E4533";lO10IO1O:= X"06C6D58BFD53";ll0O01OO:= X"06253DD2C1BD";
              IlOl010O:= X"7E03DB52C717";IIOl10O0:= X"06C6D51503C8";IO0l01l0:= X"06253DD2CB8E";
              O10011OO:= X"06C4D8F0568F";OlIII0l1:= X"06253E2727A5";
      when "10110101" => 
              O0lOO0lI:= X"00C551C57F36";Ol01lOl0:= X"7E050556738E";lO10IO1O:= X"06C2DD42718C";ll0O01OO:= X"062C02ABC5B6";
              IlOl010O:= X"7E062D511C52";IIOl10O0:= X"06C2DCCC4854";IO0l01l0:= X"062C02ABCF76";
              O10011OO:= X"06C0E2F99970";OlIII0l1:= X"062C02FFC8F0";
      when "10110110" => 
              O0lOO0lI:= X"00C3F8FD83F8";Ol01lOl0:= X"7E07554ACF9A";lO10IO1O:= X"06BEE99CE2DD";ll0O01OO:= X"0632C38ED2D0";
              IlOl010O:= X"7E087B405439";IIOl10O0:= X"06BEE9278813";IO0l01l0:= X"0632C38EDC7F";
              O10011OO:= X"06BCF1A2C867";OlIII0l1:= X"0632C3E27409";
      when "10110111" => 
              O0lOO0lI:= X"00C2A320DD51";Ol01lOl0:= X"7E09A1352547";lO10IO1O:= X"06BAFA9332D1";ll0O01OO:= X"0639808088F6";
              IlOl010O:= X"7E0AC529CF97";IIOl10O0:= X"06BAFA1EA4CE";IO0l01l0:= X"063980809295";
              O10011OO:= X"06B904E3CE9E";OlIII0l1:= X"063980D3C8D9";
      when "10111000" => 
              O0lOO0lI:= X"00C150A70089";Ol01lOl0:= X"7E0BE91DF88D";lO10IO1O:= X"06B7101D566F";ll0O01OO:= X"064039858001";
              IlOl010O:= X"7E0D0B16EE69";IIOl10O0:= X"06B70FA99319";IO0l01l0:= X"06403985898F";
              O10011OO:= X"06B51CB4AA08";OlIII0l1:= X"064039D85F38";
      when "10111001" => 
              O0lOO0lI:= X"00C001430612";Ol01lOl0:= X"7E0E2D0F06C5";lO10IO1O:= X"06B32A3354C3";ll0O01OO:= X"0646EEA247C6";
              IlOl010O:= X"7E0F4D10EE6F";IIOl10O0:= X"06B329C05A3D";IO0l01l0:= X"0646EEA25143";
              O10011OO:= X"06B1390D6B2C";OlIII0l1:= X"0646EEF4C6F8";
      when "10111010" => 
              O0lOO0lI:= X"00BEB4B7FD59";Ol01lOl0:= X"7E106D11D848";lO10IO1O:= X"06AF48CD475F";ll0O01OO:= X"064D9FDB682B";
              IlOl010O:= X"7E118B20EFAE";IIOl10O0:= X"06AF485B13FC";IO0l01l0:= X"064D9FDB7198";
              O10011OO:= X"06AD59E634EC";OlIII0l1:= X"064DA02D87FF";
      when "10111011" => 
              O0lOO0lI:= X"00BD6B1D7944";Ol01lOl0:= X"7E12A92F4D34";lO10IO1O:= X"06AB6BE35A57";ll0O01OO:= X"06544D356139";
              IlOl010O:= X"7E13C54FFC5F";IIOl10O0:= X"06AB6B71EC55";IO0l01l0:= X"06544D356A96";
              O10011OO:= X"06A97F373C54";OlIII0l1:= X"06544D872254";
      when "10111100" => 
              O0lOO0lI:= X"00BC24850DCC";Ol01lOl0:= X"7E14E1703092";lO10IO1O:= X"06A7936DCBD4";ll0O01OO:= X"065AF6B4AB2E";
              IlOl010O:= X"7E15FBA6F185";IIOl10O0:= X"06A792FD2171";IO0l01l0:= X"065AF6B4B47A";
              O10011OO:= X"06A5A8F8C863";OlIII0l1:= X"065AF7060E33";
      when "10111101" => 
              O0lOO0lI:= X"00BAE0FA2AAB";Ol01lOl0:= X"7E1715DD3D6C";lO10IO1O:= X"06A3BF64EBCE";ll0O01OO:= X"06619C5DB68F";
              IlOl010O:= X"7E182E2EAE22";IIOl10O0:= X"06A3BEF5032B";IO0l01l0:= X"06619C5DBFCB";
              O10011OO:= X"06A1D72331D8";OlIII0l1:= X"06619CAEBC20";
      when "10111110" => 
              O0lOO0lI:= X"00B9A04C2B71";Ol01lOl0:= X"7E19467F8383";lO10IO1O:= X"069FEFC11BB0";ll0O01OO:= X"06683E34EC39";
              IlOl010O:= X"7E1A5CEFF7D4";IIOl10O0:= X"069FEF51F30A";IO0l01l0:= X"06683E34F565";
              O10011OO:= X"069E09AEE301";OlIII0l1:= X"06683E8594F7";
      when "10111111" => 
              O0lOO0lI:= X"00B86265EEF3";Ol01lOl0:= X"7E1B735FC54A";lO10IO1O:= X"069C247ACE6E";ll0O01OO:= X"066EDC3EAD74";
              IlOl010O:= X"7E1C87F35CE6";IIOl10O0:= X"069C240C6429";IO0l01l0:= X"066EDC3EB691";
              O10011OO:= X"069A40945786";OlIII0l1:= X"066EDC8EF9FF";
      when "11000000" => 
              O0lOO0lI:= X"00B72771FDB0";Ol01lOl0:= X"7E1D9C863E9F";lO10IO1O:= X"06985D8A887B";ll0O01OO:= X"0675767F5405";
              IlOl010O:= X"7E1EAF4170A4";IIOl10O0:= X"06985D1CDAC7";IO0l01l0:= X"0675767F5D12";
              O10011OO:= X"06967BCC1C39";OlIII0l1:= X"067576CF44F9";
      when "11000001" => 
              O0lOO0lI:= X"00B5EF279AA3";Ol01lOl0:= X"7E1FC1FBDE73";lO10IO1O:= X"06949AE8DEEE";ll0O01OO:= X"067C0CFB323B";
              IlOl010O:= X"7E20D2E298BF";IIOl10O0:= X"06949A7BEC49";IO0l01l0:= X"067C0CFB3B38";
              O10011OO:= X"0692BB4ECEE1";OlIII0l1:= X"067C0D4AC836";
      when "11000010" => 
              O0lOO0lI:= X"00B4B9C7A587";Ol01lOl0:= X"7E21E3C887E4";lO10IO1O:= X"0690DC8E7845";ll0O01OO:= X"06829FB69305";
              IlOl010O:= X"7E22F2DF371F";IIOl10O0:= X"0690DC223EDD";IO0l01l0:= X"06829FB69BF3";
              O10011OO:= X"068EFF151E14";OlIII0l1:= X"0682A005CEA1";
      when "11000011" => 
              O0lOO0lI:= X"00B386F57CAA";Ol01lOl0:= X"7E2401F51E07";lO10IO1O:= X"068D22740B16";ll0O01OO:= X"06892EB5B9FF";
              IlOl010O:= X"7E250F3F906A";IIOl10O0:= X"068D2208896A";IO0l01l0:= X"06892EB5C2DF";
              O10011OO:= X"068B4717C8FC";OlIII0l1:= X"06892F049BD6";
      when "11000100" => 
              O0lOO0lI:= X"00B256ECA260";Ol01lOl0:= X"7E261C8961C8";lO10IO1O:= X"06896C925F01";ll0O01OO:= X"068FB9FCE387";
              IlOl010O:= X"7E27280BC131";IIOl10O0:= X"06896C27936D";IO0l01l0:= X"068FB9FCEC57";
              O10011OO:= X"0687934F9F2F";OlIII0l1:= X"068FBA4B6C31";
      when "11000101" => 
              O0lOO0lI:= X"00B1299793E4";Ol01lOl0:= X"7E28338D81C7";lO10IO1O:= X"0685BAE24BC1";ll0O01OO:= X"0696419044C6";
              IlOl010O:= X"7E293D4BE390";IIOl10O0:= X"0685BA78349B";IO0l01l0:= X"069641904D87";
              O10011OO:= X"0683E3B5807F";OlIII0l1:= X"069641DE74DA";
      when "11000110" => 
              O0lOO0lI:= X"00AFFEEDC2BA";Ol01lOl0:= X"7E2A47098C74";lO10IO1O:= X"06820D5CB927";ll0O01OO:= X"069CC5740BC9";
              IlOl010O:= X"7E2B4F07F349";IIOl10O0:= X"06820CF354D7";IO0l01l0:= X"069CC574147B";
              O10011OO:= X"068038425CCB";OlIII0l1:= X"069CC5C1E3DC";
      when "11000111" => 
              O0lOO0lI:= X"00AED6CBF1F6";Ol01lOl0:= X"7E2C5705A004";lO10IO1O:= X"067E63FA9EF6";ll0O01OO:= X"06A345AC5F8A";
              IlOl010O:= X"7E2D5D47D457";IIOl10O0:= X"067E6391EBFE";IO0l01l0:= X"06A345AC682E";
              O10011OO:= X"067C90EF33D2";OlIII0l1:= X"06A345F9E032";
      when "11001000" => 
              O0lOO0lI:= X"00ADB13795DD";Ol01lOl0:= X"7E2E63898528";lO10IO1O:= X"067ABEB504DB";ll0O01OO:= X"06A9C23D6006";
              IlOl010O:= X"7E2F681352C6";IIOl10O0:= X"067ABE4D01B8";IO0l01l0:= X"06A9C23D689B";
              O10011OO:= X"0678EDB5150A";OlIII0l1:= X"06A9C28A89D4";
      when "11001001" => 
              O0lOO0lI:= X"00AC8E769364";Ol01lOl0:= X"7E306C9C730D";lO10IO1O:= X"06771D850259";ll0O01OO:= X"06B03B2B2645";
              IlOl010O:= X"7E316F722999";IIOl10O0:= X"06771D1DAD48";IO0l01l0:= X"06B03B2B2ECC";
              O10011OO:= X"06754E8D1F70";OlIII0l1:= X"06B03B77F9CC";
      when "11001010" => 
              O0lOO0lI:= X"00AB6DEC79E4";Ol01lOl0:= X"7E3272472018";lO10IO1O:= X"06738063BD9A";ll0O01OO:= X"06B6B079C473";
              IlOl010O:= X"7E33736C03BA";IIOl10O0:= X"06737FFD1557";IO0l01l0:= X"06B6B079CCEB";
              O10011OO:= X"0671B370815B";OlIII0l1:= X"06B6B0C64242";
      when "11001011" => 
              O0lOO0lI:= X"00AA5020A14B";Ol01lOl0:= X"7E3474902EA7";lO10IO1O:= X"066FE74A6D19";ll0O01OO:= X"06BD222D45E5";
              IlOl010O:= X"7E357408644D";IIOl10O0:= X"066FE6E46FF7";IO0l01l0:= X"06BD222D4E50";
              O10011OO:= X"066E1C58785A";OlIII0l1:= X"06BD22796E8C";
      when "11001100" => 
              O0lOO0lI:= X"00A9349D61AF";Ol01lOl0:= X"7E36737FE23F";lO10IO1O:= X"066C52325585";ll0O01OO:= X"06C39049AF33";
              IlOl010O:= X"7E37714ECCCC";IIOl10O0:= X"066C51CD0233";IO0l01l0:= X"06C39049B78F";
              O10011OO:= X"066A893E50FE";OlIII0l1:= X"06C390958340";
      when "11001101" => 
              O0lOO0lI:= X"00A81B9C1BDD";Ol01lOl0:= X"7E386F1D3440";lO10IO1O:= X"0668C114CB2D";ll0O01OO:= X"06C9FAD2FE3D";
              IlOl010O:= X"7E396B469B61";IIOl10O0:= X"0668C0B02021";IO0l01l0:= X"06C9FAD3068B";
              O10011OO:= X"0666FA1B66BD";OlIII0l1:= X"06C9FB1E7E3C";
      when "11001110" => 
              O0lOO0lI:= X"00A705143B3F";Ol01lOl0:= X"7E3A676F8658";lO10IO1O:= X"066533EB30DA";ll0O01OO:= X"06D061CD2A41";
              IlOl010O:= X"7E3B61F72C32";IIOl10O0:= X"066533872C8D";IO0l01l0:= X"06D061CD3281";
              O10011OO:= X"06636EE923B9";OlIII0l1:= X"06D0621856BE";
      when "11001111" => 
              O0lOO0lI:= X"00A5F100C28B";Ol01lOl0:= X"7E3C5C7E20B6";lO10IO1O:= X"0661AAAEF7FD";ll0O01OO:= X"06D6C53C23E6";
              IlOl010O:= X"7E3D5567A458";IIOl10O0:= X"0661AA4B9907";IO0l01l0:= X"06D6C53C2C19";
              O10011OO:= X"065FE7A100AC";OlIII0l1:= X"06D6C586FD6C";
      when "11010000" => 
              O0lOO0lI:= X"00A4DF3BF916";Ol01lOl0:= X"7E3E4E5068D7";lO10IO1O:= X"065E2559A068";ll0O01OO:= X"06DD2523D54D";
              IlOl010O:= X"7E3F459F452D";IIOl10O0:= X"065E24F6E564";IO0l01l0:= X"06DD2523DD73";
              O10011OO:= X"065C643C84A9";OlIII0l1:= X"06DD256E5C64";
      when "11010001" => 
              O0lOO0lI:= X"00A3CFAAAA5B";Ol01lOl0:= X"7E403CED9ED3";lO10IO1O:= X"065AA3E4B84A";ll0O01OO:= X"06E38188221D";
              IlOl010O:= X"7E4132A5195E";IIOl10O0:= X"065AA3829FEE";IO0l01l0:= X"06E381882A35";
              O10011OO:= X"0658E4B54507";OlIII0l1:= X"06E381D2574D";
      when "11010010" => 
              O0lOO0lI:= X"00A2C27CB245";Ol01lOl0:= X"7E42285C70E0";lO10IO1O:= X"06572649DC35";ll0O01OO:= X"06E9DA6CE793";
              IlOl010O:= X"7E431C8025D7";IIOl10O0:= X"065725E8650A";IO0l01l0:= X"06E9DA6CEF9E";
              O10011OO:= X"06556904E531";OlIII0l1:= X"06E9DAB6CB62";
      when "11010011" => 
              O0lOO0lI:= X"00A1B7E51FA0";Ol01lOl0:= X"7E4410A36B16";lO10IO1O:= X"0653AC82B6CC";ll0O01OO:= X"06F02FD5FC8E";
              IlOl010O:= X"7E4503374913";IIOl10O0:= X"0653AC21DF39";IO0l01l0:= X"06F02FD6048C";
              O10011OO:= X"0651F1251681";OlIII0l1:= X"06F0301F8F83";
      when "11010100" => 
              O0lOO0lI:= X"00A0AF41C5B9";Ol01lOl0:= X"7E45F5CA9563";lO10IO1O:= X"06503688FFB5";ll0O01OO:= X"06F681C731A0";
              IlOl010O:= X"7E46E6D1767D";IIOl10O0:= X"06503628C6A4";IO0l01l0:= X"06F681C73991";
              O10011OO:= X"064E7D0F981A";OlIII0l1:= X"06F68210743F";
      when "11010101" => 
              O0lOO0lI:= X"009FA8F8B2D2";Ol01lOl0:= X"7E47D7D7EDC4";lO10IO1O:= X"064CC4567D62";ll0O01OO:= X"06FCD044511A";
              IlOl010O:= X"7E48C75565CD";IIOl10O0:= X"064CC3F6E15D";IO0l01l0:= X"06FCD04458FD";
              O10011OO:= X"064B0CBE36C4";OlIII0l1:= X"06FCD08D43E6";
      when "11010110" => 
              O0lOO0lI:= X"009EA4F290D7";Ol01lOl0:= X"7E49B6D25DB0";lO10IO1O:= X"064955E50345";ll0O01OO:= X"07031B511F18";
              IlOl010O:= X"7E4AA4C9CD64";IIOl10O0:= X"0649558602F4";IO0l01l0:= X"07031B5126EF";
              O10011OO:= X"0647A02ACCC2";OlIII0l1:= X"07031B99C293";
      when "11010111" => 
              O0lOO0lI:= X"009DA3058756";Ol01lOl0:= X"7E4B92C0D232";lO10IO1O:= X"0645EB2E7232";ll0O01OO:= X"070962F15992";
              IlOl010O:= X"7E4C7F355501";IIOl10O0:= X"0645EAD00C5D";IO0l01l0:= X"070962F1615D";
              O10011OO:= X"0644374F41B3";OlIII0l1:= X"07096339AE3E";
      when "11011000" => 
              O0lOO0lI:= X"009CA3712E9D";Ol01lOl0:= X"7E4D6BA96CAE";lO10IO1O:= X"0642842CB8A4";ll0O01OO:= X"070FA728B868";
              IlOl010O:= X"7E4E569E9836";IIOl10O0:= X"064283CEEBD5";IO0l01l0:= X"070FA728C026";
              O10011OO:= X"0640D2258A6D";OlIII0l1:= X"070FA770BEC5";
      when "11011001" => 
              O0lOO0lI:= X"009BA5FCF709";Ol01lOl0:= X"7E4F4192FF25";lO10IO1O:= X"063F20D9D1E3";ll0O01OO:= X"0715E7FAED6E";
              IlOl010O:= X"7E502B0C0605";IIOl10O0:= X"063F207C9CD0";IO0l01l0:= X"0715E7FAF51F";
              O10011OO:= X"063D70A7A8D8";OlIII0l1:= X"0715E842A5F9";
      when "11011010" => 
              O0lOO0lI:= X"009AAA932B22";Ol01lOl0:= X"7E5114843063";lO10IO1O:= X"063BC12FC62F";ll0O01OO:= X"071C256BA479";
              IlOl010O:= X"7E51FC8411C2";IIOl10O0:= X"063BC0D327B5";IO0l01l0:= X"071C256BAC1D";
              O10011OO:= X"063A12CFABC5";OlIII0l1:= X"071C25B30FB1";
      when "11011011" => 
              O0lOO0lI:= X"0099B1306922";Ol01lOl0:= X"7E52E4835855";lO10IO1O:= X"06386528AAD7";ll0O01OO:= X"07225F7E836E";
              IlOl010O:= X"7E53CB0D1F1D";IIOl10O0:= X"063864CCA1BA";IO0l01l0:= X"07225F7E8B06";
              O10011OO:= X"0636B897AEDA";OlIII0l1:= X"07225FC5A1D0";
      when "11011100" => 
              O0lOO0lI:= X"0098BA159090";Ol01lOl0:= X"7E54B19652A1";lO10IO1O:= X"06350CBEA210";ll0O01OO:= X"072896372A4D";
              IlOl010O:= X"7E5596AD7478";IIOl10O0:= X"06350C632CE8";IO0l01l0:= X"0728963731D9";
              O10011OO:= X"063361F9DA5D";OlIII0l1:= X"0728967DFC55";
      when "11011101" => 
              O0lOO0lI:= X"0097C4D46D9B";Ol01lOl0:= X"7E567BC4181A";lO10IO1O:= X"0631B7EBDA15";ll0O01OO:= X"072EC9993340";
              IlOl010O:= X"7E575F6B55C8";IIOl10O0:= X"0631B790F7CE";IO0l01l0:= X"072EC9993AC0";
              O10011OO:= X"06300EF06323";OlIII0l1:= X"072EC9DFB968";
      when "11011110" => 
              O0lOO0lI:= X"0096D1C05D79";Ol01lOl0:= X"7E584312422A";lO10IO1O:= X"062E66AA8E3A";ll0O01OO:= X"0734F9A832A3";
              IlOl010O:= X"7E59254CE57B";IIOl10O0:= X"062E66503D80";IO0l01l0:= X"0734F9A83A17";
              O10011OO:= X"062CBF758A63";OlIII0l1:= X"0734F9EE6D65";
      when "11011111" => 
              O0lOO0lI:= X"0095E0BF6C97";Ol01lOl0:= X"7E5A07871C59";lO10IO1O:= X"062B18F505C9";ll0O01OO:= X"073B2667B715";
              IlOl010O:= X"7E5AE858369B";IIOl10O0:= X"062B189B4566";IO0l01l0:= X"073B2667BE7D";
              O10011OO:= X"062973839D9D";OlIII0l1:= X"073B26ADA6EA";
      when "11100000" => 
              O0lOO0lI:= X"0094F1B1D9C6";Ol01lOl0:= X"7E5BC928D964";lO10IO1O:= X"0627CEC5944D";ll0O01OO:= X"07414FDB4982";
              IlOl010O:= X"7E5CA8936708";IIOl10O0:= X"0627CE6C6308";IO0l01l0:= X"07414FDB50DF";
              O10011OO:= X"06262B14F66F";OlIII0l1:= X"07415020EEE2";
      when "11100001" => 
              O0lOO0lI:= X"009404B1BE45";Ol01lOl0:= X"7E5D87FD54EF";lO10IO1O:= X"062488169973";ll0O01OO:= X"074776066D31";
              IlOl010O:= X"7E5E66045DAE";IIOl10O0:= X"062487BDF623";IO0l01l0:= X"074776067482";
              O10011OO:= X"0622E623FA7F";OlIII0l1:= X"0747764BC892";
      when "11100010" => 
              O0lOO0lI:= X"00931983D7FA";Ol01lOl0:= X"7E5F440ACC54";lO10IO1O:= X"062144E280C6";ll0O01OO:= X"074D98EC9FCD";
              IlOl010O:= X"7E6020B11164";IIOl10O0:= X"0621448A6A47";IO0l01l0:= X"074D98ECA712";
              O10011OO:= X"061FA4AB1B58";OlIII0l1:= X"074D9931B1A4";
      when "11100011" => 
              O0lOO0lI:= X"009230869BD0";Ol01lOl0:= X"7E60FD5684A2";lO10IO1O:= X"061E0523C1F3";ll0O01OO:= X"0753B8915972";
              IlOl010O:= X"7E61D89F5C4E";IIOl10O0:= X"061E04CC36EB";IO0l01l0:= X"0753B89160AB";
              O10011OO:= X"061C66A4D647";OlIII0l1:= X"0753B8D62235";
      when "11100100" => 
              O0lOO0lI:= X"00914915625E";Ol01lOl0:= X"7E62B3E75ACC";lO10IO1O:= X"061AC8D4DFA7";ll0O01OO:= X"0759D4F80CBB";
              IlOl010O:= X"7E638DD500DD";IIOl10O0:= X"061AC87DDF3E";IO0l01l0:= X"0759D4F813E9";
              O10011OO:= X"06192C0BB441";OlIII0l1:= X"0759D53C8CDD";
      when "11100101" => 
              O0lOO0lI:= X"009063C9DA0E";Ol01lOl0:= X"7E6467C20859";lO10IO1O:= X"06178FF06919";ll0O01OO:= X"075FEE2426CB";
              IlOl010O:= X"7E654057BE5C";IIOl10O0:= X"06178F99F200";IO0l01l0:= X"075FEE242DED";
              O10011OO:= X"0615F4DA49BF";OlIII0l1:= X"075FEE685EBF";
      when "11100110" => 
              O0lOO0lI:= X"008F804E808D";Ol01lOl0:= X"7E6618ECCD2F";lO10IO1O:= X"06145A70F839";ll0O01OO:= X"076604190F5A";
              IlOl010O:= X"7E66F02D407C";IIOl10O0:= X"06145A1B0963";IO0l01l0:= X"076604191671";
              O10011OO:= X"0612C10B36A4";OlIII0l1:= X"0766045CFF92";
      when "11100111" => 
              O0lOO0lI:= X"008E9E9E395D";Ol01lOl0:= X"7E67C76D3D23";lO10IO1O:= X"0611285132A6";ll0O01OO:= X"076C16DA28BF";
              IlOl010O:= X"7E689D5B28F8";IIOl10O0:= X"061127FBCAF5";IO0l01l0:= X"076C16DA2FCB";
              O10011OO:= X"060F9099261D";OlIII0l1:= X"076C171DD1AC";
      when "11101000" => 
              O0lOO0lI:= X"008DBEC3670B";Ol01lOl0:= X"7E697348EAA8";lO10IO1O:= X"060DF98BC91C";ll0O01OO:= X"0772266ACFFE";
              IlOl010O:= X"7E6A47E70459";IIOl10O0:= X"060DF936E781";IO0l01l0:= X"0772266AD6FF";
              O10011OO:= X"060C637ECE87";OlIII0l1:= X"077226AE320F";
      when "11101001" => 
              O0lOO0lI:= X"008CE0FAAA86";Ol01lOl0:= X"7E6B1C84E0FA";lO10IO1O:= X"060ACE1B77C8";ll0O01OO:= X"077832CE5CCE";
              IlOl010O:= X"7E6BEFD65D77";IIOl10O0:= X"060ACDC71AEC";IO0l01l0:= X"077832CE63C5";
              O10011OO:= X"060939B6F14A";OlIII0l1:= X"077833117874";
      when "11101010" => 
              O0lOO0lI:= X"008C04B77A3E";Ol01lOl0:= X"7E6CC327822F";lO10IO1O:= X"0607A5FB051C";ll0O01OO:= X"077E3C0821AC";
              IlOl010O:= X"7E6D952E9435";IIOl10O0:= X"0607A5A72C2F";IO0l01l0:= X"077E3C082897";
              O10011OO:= X"0606133C5AC4";OlIII0l1:= X"077E3C4AF753";
      when "11101011" => 
              O0lOO0lI:= X"008B2A746E5D";Ol01lOl0:= X"7E6E67356111";lO10IO1O:= X"060481254354";ll0O01OO:= X"0784421B6BDD";
              IlOl010O:= X"7E6F37F51439";IIOl10O0:= X"060480D1ED14";IO0l01l0:= X"0784421B72BE";
              O10011OO:= X"0602F009E228";OlIII0l1:= X"0784425DFBF4";
      when "11101100" => 
              O0lOO0lI:= X"008A51E54500";Ol01lOl0:= X"7E7008B4650B";lO10IO1O:= X"06015F950EB3";ll0O01OO:= X"078A450B8381";
              IlOl010O:= X"7E70D82F38C8";IIOl10O0:= X"06015F423A2B";IO0l01l0:= X"078A450B8A56";
              O10011OO:= X"05FFD01A6965";OlIII0l1:= X"078A454DCE73";
      when "11101101" => 
              O0lOO0lI:= X"00897B0EA190";Ol01lOl0:= X"7E71A7A9B0F3";lO10IO1O:= X"05FE41454EA1";ll0O01OO:= X"079044DBAB96";
              IlOl010O:= X"7E7275E24416";IIOl10O0:= X"05FE40F2FAC2";IO0l01l0:= X"079044DBB261";
              O10011OO:= X"05FCB368DD05";OlIII0l1:= X"0790451DB1CF";
      when "11101110" => 
              O0lOO0lI:= X"0088A60D0F66";Ol01lOl0:= X"7E73441A6461";lO10IO1O:= X"05FB2630F4F9";ll0O01OO:= X"0796418F2209";
              IlOl010O:= X"7E7411137579";IIOl10O0:= X"05FB25DF20A2";IO0l01l0:= X"0796418F28CA";
              O10011OO:= X"05F999F03417";OlIII0l1:= X"079641D0E3F4";
      when "11101111" => 
              O0lOO0lI:= X"0087D27A785E";Ol01lOl0:= X"7E74DE0C48B9";lO10IO1O:= X"05F80E52FDB9";ll0O01OO:= X"079C3B291FBE";
              IlOl010O:= X"7E75A9C7F441";IIOl10O0:= X"05F80E01A821";IO0l01l0:= X"079C3B292675";
              O10011OO:= X"05F683AB7015";OlIII0l1:= X"079C3B6A9DC5";
      when "11110000" => 
              O0lOO0lI:= X"008700FD7F92";Ol01lOl0:= X"7E76758369D6";lO10IO1O:= X"05F4F9A6700C";ll0O01OO:= X"07A231ACD89B";
              IlOl010O:= X"7E774004EC4D";IIOl10O0:= X"05F4F95597D1";IO0l01l0:= X"07A231ACDF47";
              O10011OO:= X"05F370959CBE";OlIII0l1:= X"07A231EE1326";
      when "11110001" => 
              O0lOO0lI:= X"008630FAE5D0";Ol01lOl0:= X"7E780A85E679";lO10IO1O:= X"05F1E8265C4F";ll0O01OO:= X"07A8251D7B8F";
              IlOl010O:= X"7E78D3CF6036";IIOl10O0:= X"05F1E7D600AB";IO0l01l0:= X"07A8251D8231";
              O10011OO:= X"05F060A9D00A";OlIII0l1:= X"07A8255E7307";
      when "11110010" => 
              O0lOO0lI:= X"008562A04A11";Ol01lOl0:= X"7E799D186E83";lO10IO1O:= X"05EED9CDDDBB";ll0O01OO:= X"07AE157E32A2";
              IlOl010O:= X"7E7A652C5BA6";IIOl10O0:= X"05EED97DFDAF";IO0l01l0:= X"07AE157E393A";
              O10011OO:= X"05ED53E32A09";OlIII0l1:= X"07AE15BEE76E";
      when "11110011" => 
              O0lOO0lI:= X"0084960F943C";Ol01lOl0:= X"7E7B2D3FC3E5";lO10IO1O:= X"05EBCE98197B";ll0O01OO:= X"07B402D222FB";
              IlOl010O:= X"7E7BF420DD23";IIOl10O0:= X"05EBCE48B3E9";IO0l01l0:= X"07B402D22988";
              O10011OO:= X"05EA4A3CD4C5";OlIII0l1:= X"07B403129581";
      when "11110100" => 
              O0lOO0lI:= X"0083CAD1E3FC";Ol01lOl0:= X"7E7CBB0195A0";lO10IO1O:= X"05E8C6803E38";ll0O01OO:= X"07B9ED1C6CEB";
              IlOl010O:= X"7E7D80B1CFFC";IIOl10O0:= X"05E8C631525F";IO0l01l0:= X"07B9ED1C736E";
              O10011OO:= X"05E743B20430";OlIII0l1:= X"07B9ED5C9D90";
      when "11110101" => 
              O0lOO0lI:= X"008301839FB6";Ol01lOl0:= X"7E7E4661C0C1";lO10IO1O:= X"05E5C1818550";ll0O01OO:= X"07BFD4602BF5";
              IlOl010O:= X"7E7F0AE40AB1";IIOl10O0:= X"05E5C13311FB";IO0l01l0:= X"07BFD460326E";
              O10011OO:= X"05E4403DF606";OlIII0l1:= X"07BFD4A01B20";
      when "11110110" => 
              O0lOO0lI:= X"0082399F02CB";Ol01lOl0:= X"7E7FCF65F85A";lO10IO1O:= X"05E2BF9730EB";ll0O01OO:= X"07C5B8A076DE";
              IlOl010O:= X"7E8092BC6373";IIOl10O0:= X"05E2BF493553";IO0l01l0:= X"07C5B8A07D4D";
              O10011OO:= X"05E13FDBF1B7";OlIII0l1:= X"07C5B8E024F1";
      when "11110111" => 
              O0lOO0lI:= X"00817367FA0E";Ol01lOl0:= X"7E8156128790";lO10IO1O:= X"05DFC0BC8D93";ll0O01OO:= X"07CB99E05FAE";
              IlOl010O:= X"7E82183FA74F";IIOl10O0:= X"05DFC06F08A6";IO0l01l0:= X"07CB99E06614";
              O10011OO:= X"05DE4287484E";OlIII0l1:= X"07CB9A1FCD0D";
      when "11111000" => 
              O0lOO0lI:= X"0080AEC80C1B";Ol01lOl0:= X"7E82DA6C577E";lO10IO1O:= X"05DCC4ECF0FC";ll0O01OO:= X"07D17822F3C2";
              IlOl010O:= X"7E839B728799";IIOl10O0:= X"05DCC49FE1CC";IO0l01l0:= X"07D17822FA1E";
              O10011OO:= X"05DB483B5454";OlIII0l1:= X"07D1786220CF";
      when "11111001" => 
              O0lOO0lI:= X"007FEBA95A98";Ol01lOl0:= X"7E845C7840F7";lO10IO1O:= X"05D9CC23BA51";ll0O01OO:= X"07D7536B3BCE";
              IlOl010O:= X"7E851C59BEA3";IIOl10O0:= X"05D9CBD72000";IO0l01l0:= X"07D7536B4220";
              O10011OO:= X"05D850F379BF";OlIII0l1:= X"07D753AA28EB";
      when "11111010" => 
              O0lOO0lI:= X"007F2A046BF4";Ol01lOl0:= X"7E85DC3AE3AE";lO10IO1O:= X"05D6D65C5245";ll0O01OO:= X"07DD2BBC3BEC";
              IlOl010O:= X"7E869AF9E6AF";IIOl10O0:= X"05D6D6102BED";IO0l01l0:= X"07DD2BBC4235";
              O10011OO:= X"05D55CAB25D3";OlIII0l1:= X"07DD2BFAE97A";
      when "11111011" => 
              O0lOO0lI:= X"007E6A191CBE";Ol01lOl0:= X"7E8759B87181";lO10IO1O:= X"05D3E3922AEA";ll0O01OO:= X"07E30118F3A3";
              IlOl010O:= X"7E8817579B27";IIOl10O0:= X"05D3E3467776";IO0l01l0:= X"07E30118F9E2";
              O10011OO:= X"05D26B5DCF14";OlIII0l1:= X"07E301576202";
      when "11111100" => 
              O0lOO0lI:= X"007DAB8453F9";Ol01lOl0:= X"7E88D4F61CC7";lO10IO1O:= X"05D0F3C0BF0B";ll0O01OO:= X"07E8D3845DF1";
              IlOl010O:= X"7E899177677D";IIOl10O0:= X"05D0F3757DB7";IO0l01l0:= X"07E8D3846426";
              O10011OO:= X"05CF7D06F51F";OlIII0l1:= X"07E8D3C28D80";
      when "11111101" => 
              O0lOO0lI:= X"007CEE6D1D54";Ol01lOl0:= X"7E8A4DF82004";lO10IO1O:= X"05CE06E392FD";ll0O01OO:= X"07EEA3017151";
              IlOl010O:= X"7E8B095DC955";IIOl10O0:= X"05CE0698C2E1";IO0l01l0:= X"07EEA301777E";
              O10011OO:= X"05CC91A220AB";OlIII0l1:= X"07EEA33F6270";
      when "11111110" => 
              O0lOO0lI:= X"007C32DFB99E";Ol01lOl0:= X"7E8BC4C2E18F";lO10IO1O:= X"05CB1CF633EA";ll0O01OO:= X"07F46F931FCB";
              IlOl010O:= X"7E8C7F0F35CE";IIOl10O0:= X"05CB1CABD422";IO0l01l0:= X"07F46F9325EE";
              O10011OO:= X"05C9A92AE359";OlIII0l1:= X"07F46FD0D2D6";
      when "11111111" => 
              O0lOO0lI:= X"007B789E3D42";Ol01lOl0:= X"7E8D395B2CC2";lO10IO1O:= X"05C835F437CA";ll0O01OO:= X"07FA393C56F5";
              IlOl010O:= X"7E8DF29018DF";IIOl10O0:= X"05C835AA4792";IO0l01l0:= X"07FA393C5D0F";
              O10011OO:= X"05C6C39CD7AB";OlIII0l1:= X"07FA3979CC4A";
      when others => null;
    end case;

  if (O01ll0l0>DW_O010l10I) then
    l0O11O0I := O01ll0l0 - DW_O010l10I;
  else
    l0O11O0I := 0;
  end if;
  if ((O01ll0l0-l0O11O0I-DW_O0OO0O01) < 0) then
    O0OOO1Ol := conv_signed(O0lOO0lI(O01ll0l0-1-l0O11O0I downto 0),O0OOO1Ol'length);
  else
    O0OOO1Ol := signed(O0lOO0lI(O01ll0l0-1-l0O11O0I downto O01ll0l0-l0O11O0I-DW_O0OO0O01));
  end if;
  if ((O01ll0l0-l0O11O0I-DW_l0l110I1) < 0) then
    IlO0OlO0 := conv_signed(Ol01lOl0(O01ll0l0-1-l0O11O0I downto 0),IlO0OlO0'length);
    I11000OO := conv_signed(IlOl010O(O01ll0l0-1-l0O11O0I downto 0),I11000OO'length);
  else
    IlO0OlO0 := signed(Ol01lOl0(O01ll0l0-1-l0O11O0I downto O01ll0l0-l0O11O0I-DW_l0l110I1));
    I11000OO := signed(IlOl010O(O01ll0l0-1-l0O11O0I downto O01ll0l0-l0O11O0I-DW_l0l110I1));
  end if;
  if ((O01ll0l0-l0O11O0I-DW_O001OOOI) < 0) then
    I0lO01lI := conv_signed(lO10IO1O(O01ll0l0-1-l0O11O0I downto 0),I0lO01lI'length);
    O1010O10 := conv_signed(IIOl10O0(O01ll0l0-1-l0O11O0I downto 0),O1010O10'length);
    O0O01OO0 := conv_signed(O10011OO(O01ll0l0-1-l0O11O0I downto 0),O0O01OO0'length);
  else
    I0lO01lI := signed(lO10IO1O(O01ll0l0-1-l0O11O0I downto O01ll0l0-l0O11O0I-DW_O001OOOI));
    O1010O10 := signed(IIOl10O0(O01ll0l0-1-l0O11O0I downto O01ll0l0-l0O11O0I-DW_O001OOOI));
    O0O01OO0 := signed(O10011OO(O01ll0l0-1-l0O11O0I downto O01ll0l0-l0O11O0I-DW_O001OOOI));
  end if;
  if ((O01ll0l0-l0O11O0I-DW_IOOO11OI) < 0)  then
    Il001l11 := conv_signed(ll0O01OO(O01ll0l0-1-l0O11O0I downto 0),Il001l11'length);
    O1O11001 := conv_signed(IO0l01l0(O01ll0l0-1-l0O11O0I downto 0),O1O11001'length);
    l10OIO11 := conv_signed(OlIII0l1(O01ll0l0-1-l0O11O0I downto 0),l10OIO11'length);
  else    
    Il001l11 := signed(ll0O01OO(O01ll0l0-1-l0O11O0I downto O01ll0l0-l0O11O0I-DW_IOOO11OI));
    O1O11001 := signed(IO0l01l0(O01ll0l0-1-l0O11O0I downto O01ll0l0-l0O11O0I-DW_IOOO11OI));
    l10OIO11 := signed(OlIII0l1(O01ll0l0-1-l0O11O0I downto O01ll0l0-l0O11O0I-DW_IOOO11OI));
  end if;

  if (arch = 0) then
    OI0l0OO0 := SHR((O0OOO1Ol * unsigned(IOIlO01O) + IlO0OlO0 * Oll01O00),conv_unsigned(op_width-1+DW_O0O0lO11,16));  
    l11OOO01 := SHR((signed(OI0l0OO0(DW_l0l110I1-1 downto 0)) *  unsigned(IOIlO01O) + I0lO01lI * OlO000O1),conv_unsigned(op_width-1,16));
    Ol111l1O := signed(l11OOO01(DW_O001OOOI-1 downto 0)) * unsigned(IOIlO01O) + Il001l11 * OlO000O1;
    I011Ol10 := (others => '0');
    l0IIIO0O := SHR((I11000OO *  unsigned(IOIlO01O) + O1010O10 * OlO000O1),conv_unsigned(op_width-1,32));
    O1llIl1O := signed(l0IIIO0O(DW_O001OOOI-1 downto 0)) *  unsigned(IOIlO01O) + O1O11001 * OlO000O1;
    O10IlO11 := (others => '0');
    O0OlOOOl := (others => '0');   
    II0Ol1Il := O0O01OO0 *  unsigned(IOIlO01O) + l10OIO11 * OlO000O1;
  else
    l0100IOO := unsigned(IOIlO01O) * unsigned(IOIlO01O);
    if ((op_width-2) < DW_I0I00O00) then
      lOI1O001 := conv_unsigned(SHL(l0100IOO,conv_unsigned(DW_I0I00O00-op_width+2,16)),lOI1O001'length);
    else
      l110I00O := SHR(l0100IOO,conv_unsigned(op_width-2-DW_I0I00O00,16));
      lOI1O001 := l110I00O(lOI1O001'left downto 0);
    end if;
    l0Il1llO := unsigned(IOIlO01O) * unsigned(IOIlO01O) * unsigned(IOIlO01O);
    if ((2*op_width-3) < DW_I0I00O00) then
      I111O10l :=  SHL(l0Il1llO,conv_unsigned(DW_I0I00O00-2*op_width+3,16));
    else
      I11IlIII := SHR(l0Il1llO,conv_unsigned(2*op_width-3-DW_I0I00O00,16));
      I111O10l := I11IlIII(I111O10l'left downto 0);
    end if;
    O0Ol00II := unsigned(IOIlO01O & OOOOOOO1);
    OI0l0OO0 := conv_signed(SHR(O0OOO1Ol * I111O10l,conv_unsigned(op_width+DW_I0I00O00+DW_O0O0lO11,16)), OI0l0OO0'length);  
    l11OOO01 := conv_signed(SHR(IlO0OlO0 * lOI1O001,conv_unsigned(op_width+DW_I0I00O00,16)),l11OOO01'length);
    Ol111l1O := SHL(conv_signed(OI0l0OO0 + l11OOO01 + SHR(I0lO01lI * O0Ol00II,conv_unsigned(op_width+DW_I0I00O00,16)) + Il001l11,Ol111l1O'length),conv_unsigned(op_width-1,16));
    I011Ol10 := (others => '0');
    l0IIIO0O := conv_signed(SHR(I11000OO * lOI1O001,conv_unsigned(op_width+DW_I0I00O00,16)),l0IIIO0O'length);
    O1llIl1O := SHL(conv_signed(I011Ol10 + l0IIIO0O + SHR(O1010O10 * O0Ol00II,conv_unsigned(op_width+DW_I0I00O00,16)) + O1O11001,O1llIl1O'length),conv_unsigned(op_width-1,16));
    O10IlO11 := (others => '0');
    O0OlOOOl := (others => '0');   
    II0Ol1Il := SHL(conv_signed(O10IlO11 + O0OlOOOl + SHR(O0O01OO0 *  O0Ol00II,conv_unsigned(op_width+DW_I0I00O00,16)) + l10OIO11,II0Ol1Il'length),conv_unsigned(op_width-1,16));
  end if;
  if ((op_width >= 19) and (op_width < 29)) then
    I11O100l := O1llIl1O(I11O100l'left downto 0);
  else
    if ((op_width >= 13) and (op_width < 19)) then
      I11O100l := II0Ol1Il(I11O100l'left downto 0);
    else  
      I11O100l := Ol111l1O(I11O100l'left downto 0);
    end if;
  end if;
  I11O100l := SHL(I11O100l,conv_unsigned(DW_l1010I01,3));

  for OOIO01I0 in 1 to O10ll00I'length loop
    if (OOIO01I0 <= I11O100l'length) then
      O10ll00I(O10ll00I'length-OOIO01I0) := I11O100l(I11O100l'length-OOIO01I0);
    else
      O10ll00I(O10ll00I'length-OOIO01I0) := '0';
    end if;
  end loop;

  IOO0O111 := unsigned(O10ll00I);
  if (err_range = 1) then
    lIOI0I0O:= unsigned(IOO0O111(IOO0O111'length-2 downto IOO0O111'length-1-lIOI0I0O'length))
              + unsigned('1' & conv_unsigned(0,DW_IO1IIIl0-1));
  else
    lIOI0I0O:=  unsigned(IOO0O111(IOO0O111'length-2 downto IOO0O111'length-1-lIOI0I0O'length));
  end if;
  OIO00011 <= std_logic_vector(lIOI0I0O(DW_IOl1OOO0 downto DW_IOl1OOO0-op_width+1));
end process;


  z <=  (others => 'X') when (Is_x(a)) else
        lll10l10 when (op_width < 13 or op_width >= 39) else O010I0I1 when (arch = 2) else OIO00011;

-- pragma translate_on  

end sim ;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_log2_cfg_sim of DW_log2 is
 for sim
 end for; -- sim
end DW_log2_cfg_sim;
-- pragma translate_on

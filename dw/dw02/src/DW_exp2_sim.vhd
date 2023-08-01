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
-- AUTHOR:    Alexandre Tenca   August 2007
--
-- VERSION:   VHDL Simulation model version 2.0
--
-- DesignWare_version: ae64d91a
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--
-- ABSTRACT: Fixed-point exponential base-2 (DW_exp2) - exp2(a) = 2^a
--           Computes the value of 2 to the power a, where a is a fixed point 
--           value in the range [0,1) delivering a result that is always
--           normalized -- range [1,2).
--           The number of fractional bits to be used is controlled by
--           a parameter. 
--
--              parameters      valid values (defined in the DW manual)
--              ==========      ============
--              op_width        operand size,  >= 2 and <= 60
--                              number of fractional bits at the input
--              arch            implementation select
--                              0 - area optimized 
--                              1 - speed optimized
--                              2 - 2007.12 implementation (default)
--              err_range       error range of the result compared to the
--                              true result. Default is use when arch=2.
--                              1 - 1 ulp max error (default)
--                              2 - 2 ulp max error
--
--              Input ports     Size & Description
--              ===========     ==================
--              a               main input with op_width fractional bits
--
--              Output ports    Size & Description
--              ===========     ==================
--              z               op_width bits 
--                              Value of exp2(a) - one integer bit and 
--                              op_width-1 fractional bits
--
--  Note: this simulation model was designed to run configuraiton of up to 
--        op_width=38 bits. In the range 39-60, only the Verilog simulation
--        model using VCS is available.
-- MODIFIED:
--           August 2008 - Included new parameter to control alternative arch
--                         and err_range
--           May 2018    - Star 9001341564
--                         Removed declaration of variable that is not used 
--                         in the code (addr_fill)
--
---------------------------------------------------------------------------------
                                       
library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use DWARE.DWpackages.all;

architecture sim of DW_exp2 is
	
-- pragma translate_off

--#define debug true

  constant table_nrows : INTEGER := 256;
  constant table_addrsize : INTEGER := 8;
  constant coef_max_size : INTEGER := (47);
  constant coef_case_size : integer := (48);
  constant int_bits : INTEGER := 4;
  constant extra_LSBs : INTEGER := 4;
  constant coef3_size : INTEGER :=  (op_width+int_bits+extra_LSBs); 
  constant bits : INTEGER := 0;
  constant coef3_size_new : INTEGER :=  (op_width+int_bits+extra_LSBs+bits); 
  constant coef2_size : INTEGER :=  (op_width+int_bits+extra_LSBs);
  constant coef1_size : INTEGER :=  (op_width+int_bits+extra_LSBs);
  constant coef0_size : INTEGER :=  (op_width+int_bits+extra_LSBs);
  constant prod3_MSB : INTEGER :=  (op_width+coef3_size-1);
  constant prod3_MSB_new : INTEGER :=  (op_width+coef3_size_new-1);
  constant prod2_MSB : INTEGER :=  (op_width+coef2_size-1);
  constant prod1_MSB : INTEGER :=  (op_width+coef1_size-1);
  constant z_int_size : INTEGER :=  (op_width+extra_LSBs);
  constant chain : INTEGER :=  2;
  constant z_round_MSB : INTEGER :=  (op_width-1+chain);

  signal z_poly : std_logic_vector (op_width-1 downto 0);
  signal z_poly_new : std_logic_vector (op_width-1 downto 0);

  constant lookuptable_nrows : integer := 2048;
  constant lookuptable_wordsize : integer := 13;
  constant lookuptable_mwordsize : integer := 16;
  constant lookuptable_addrsize : integer := 11;
  constant lookupint_bits : integer := 2;

  signal z_lookup : std_logic_vector (op_width-1 downto 0);

  constant extra_lbits: integer := 4;
  constant r4table_nrows: integer := 264;
  constant r4table_wordsize: integer := 72;
  constant r4table_addrsize: integer := 9;
  signal z_r4: std_logic_vector(op_width-1 downto 0);

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
    if ( (op_width > 38) ) then
      param_err_flg := 1;
      assert false
        report "WARNING: The DesignWare Library Component, DW_exp2, can only be simulated using its Verilog simulation model with Synopsys VCS and VCS-MX simulators when the parameter, op_width, is set greater than 38.  Stopping simulation."
        severity error;
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


alg0: process (a)
  variable tblu_addr: std_logic_vector (lookuptable_addrsize-1 downto 0);
  variable tblu_rom: std_logic_vector (lookuptable_mwordsize-1 downto 0);
  variable rom_out : std_logic_vector (lookuptable_wordsize-1 downto 0);
  variable z_extended : std_logic_vector (op_width downto 0);
begin
  if (lookuptable_addrsize-op_width > 0) then
     tblu_addr := std_logic_vector(SHL(conv_unsigned(unsigned(a),lookuptable_addrsize),
                                          conv_unsigned(lookuptable_addrsize-op_width,31)));
  else
     tblu_addr := a(tblu_addr'length-1 downto 0);
  end if;
    
    case (tblu_addr) is
      when "00000000000" => tblu_rom:=X"0800";
      when "00000000001" => tblu_rom:=X"0800";
      when "00000000010" => tblu_rom:=X"0800";
      when "00000000011" => tblu_rom:=X"0802";
      when "00000000100" => tblu_rom:=X"0802";
      when "00000000101" => tblu_rom:=X"0802";
      when "00000000110" => tblu_rom:=X"0804";
      when "00000000111" => tblu_rom:=X"0804";
      when "00000001000" => tblu_rom:=X"0804";
      when "00000001001" => tblu_rom:=X"0806";
      when "00000001010" => tblu_rom:=X"0806";
      when "00000001011" => tblu_rom:=X"0806";
      when "00000001100" => tblu_rom:=X"0808";
      when "00000001101" => tblu_rom:=X"0808";
      when "00000001110" => tblu_rom:=X"0808";
      when "00000001111" => tblu_rom:=X"080A";
      when "00000010000" => tblu_rom:=X"080A";
      when "00000010001" => tblu_rom:=X"080A";
      when "00000010010" => tblu_rom:=X"080C";
      when "00000010011" => tblu_rom:=X"080C";
      when "00000010100" => tblu_rom:=X"080C";
      when "00000010101" => tblu_rom:=X"080E";
      when "00000010110" => tblu_rom:=X"080E";
      when "00000010111" => tblu_rom:=X"0810";
      when "00000011000" => tblu_rom:=X"0810";
      when "00000011001" => tblu_rom:=X"0810";
      when "00000011010" => tblu_rom:=X"0812";
      when "00000011011" => tblu_rom:=X"0812";
      when "00000011100" => tblu_rom:=X"0812";
      when "00000011101" => tblu_rom:=X"0814";
      when "00000011110" => tblu_rom:=X"0814";
      when "00000011111" => tblu_rom:=X"0814";
      when "00000100000" => tblu_rom:=X"0816";
      when "00000100001" => tblu_rom:=X"0816";
      when "00000100010" => tblu_rom:=X"0816";
      when "00000100011" => tblu_rom:=X"0818";
      when "00000100100" => tblu_rom:=X"0818";
      when "00000100101" => tblu_rom:=X"0818";
      when "00000100110" => tblu_rom:=X"081A";
      when "00000100111" => tblu_rom:=X"081A";
      when "00000101000" => tblu_rom:=X"081A";
      when "00000101001" => tblu_rom:=X"081C";
      when "00000101010" => tblu_rom:=X"081C";
      when "00000101011" => tblu_rom:=X"081E";
      when "00000101100" => tblu_rom:=X"081E";
      when "00000101101" => tblu_rom:=X"081E";
      when "00000101110" => tblu_rom:=X"0820";
      when "00000101111" => tblu_rom:=X"0820";
      when "00000110000" => tblu_rom:=X"0820";
      when "00000110001" => tblu_rom:=X"0822";
      when "00000110010" => tblu_rom:=X"0822";
      when "00000110011" => tblu_rom:=X"0822";
      when "00000110100" => tblu_rom:=X"0824";
      when "00000110101" => tblu_rom:=X"0824";
      when "00000110110" => tblu_rom:=X"0824";
      when "00000110111" => tblu_rom:=X"0826";
      when "00000111000" => tblu_rom:=X"0826";
      when "00000111001" => tblu_rom:=X"0826";
      when "00000111010" => tblu_rom:=X"0828";
      when "00000111011" => tblu_rom:=X"0828";
      when "00000111100" => tblu_rom:=X"082A";
      when "00000111101" => tblu_rom:=X"082A";
      when "00000111110" => tblu_rom:=X"082A";
      when "00000111111" => tblu_rom:=X"082C";
      when "00001000000" => tblu_rom:=X"082C";
      when "00001000001" => tblu_rom:=X"082C";
      when "00001000010" => tblu_rom:=X"082E";
      when "00001000011" => tblu_rom:=X"082E";
      when "00001000100" => tblu_rom:=X"082E";
      when "00001000101" => tblu_rom:=X"0830";
      when "00001000110" => tblu_rom:=X"0830";
      when "00001000111" => tblu_rom:=X"0830";
      when "00001001000" => tblu_rom:=X"0832";
      when "00001001001" => tblu_rom:=X"0832";
      when "00001001010" => tblu_rom:=X"0832";
      when "00001001011" => tblu_rom:=X"0834";
      when "00001001100" => tblu_rom:=X"0834";
      when "00001001101" => tblu_rom:=X"0836";
      when "00001001110" => tblu_rom:=X"0836";
      when "00001001111" => tblu_rom:=X"0836";
      when "00001010000" => tblu_rom:=X"0838";
      when "00001010001" => tblu_rom:=X"0838";
      when "00001010010" => tblu_rom:=X"0838";
      when "00001010011" => tblu_rom:=X"083A";
      when "00001010100" => tblu_rom:=X"083A";
      when "00001010101" => tblu_rom:=X"083A";
      when "00001010110" => tblu_rom:=X"083C";
      when "00001010111" => tblu_rom:=X"083C";
      when "00001011000" => tblu_rom:=X"083C";
      when "00001011001" => tblu_rom:=X"083E";
      when "00001011010" => tblu_rom:=X"083E";
      when "00001011011" => tblu_rom:=X"0840";
      when "00001011100" => tblu_rom:=X"0840";
      when "00001011101" => tblu_rom:=X"0840";
      when "00001011110" => tblu_rom:=X"0842";
      when "00001011111" => tblu_rom:=X"0842";
      when "00001100000" => tblu_rom:=X"0842";
      when "00001100001" => tblu_rom:=X"0844";
      when "00001100010" => tblu_rom:=X"0844";
      when "00001100011" => tblu_rom:=X"0844";
      when "00001100100" => tblu_rom:=X"0846";
      when "00001100101" => tblu_rom:=X"0846";
      when "00001100110" => tblu_rom:=X"0846";
      when "00001100111" => tblu_rom:=X"0848";
      when "00001101000" => tblu_rom:=X"0848";
      when "00001101001" => tblu_rom:=X"084A";
      when "00001101010" => tblu_rom:=X"084A";
      when "00001101011" => tblu_rom:=X"084A";
      when "00001101100" => tblu_rom:=X"084C";
      when "00001101101" => tblu_rom:=X"084C";
      when "00001101110" => tblu_rom:=X"084C";
      when "00001101111" => tblu_rom:=X"084E";
      when "00001110000" => tblu_rom:=X"084E";
      when "00001110001" => tblu_rom:=X"084E";
      when "00001110010" => tblu_rom:=X"0850";
      when "00001110011" => tblu_rom:=X"0850";
      when "00001110100" => tblu_rom:=X"0852";
      when "00001110101" => tblu_rom:=X"0852";
      when "00001110110" => tblu_rom:=X"0852";
      when "00001110111" => tblu_rom:=X"0854";
      when "00001111000" => tblu_rom:=X"0854";
      when "00001111001" => tblu_rom:=X"0854";
      when "00001111010" => tblu_rom:=X"0856";
      when "00001111011" => tblu_rom:=X"0856";
      when "00001111100" => tblu_rom:=X"0856";
      when "00001111101" => tblu_rom:=X"0858";
      when "00001111110" => tblu_rom:=X"0858";
      when "00001111111" => tblu_rom:=X"0858";
      when "00010000000" => tblu_rom:=X"085A";
      when "00010000001" => tblu_rom:=X"085A";
      when "00010000010" => tblu_rom:=X"085C";
      when "00010000011" => tblu_rom:=X"085C";
      when "00010000100" => tblu_rom:=X"085C";
      when "00010000101" => tblu_rom:=X"085E";
      when "00010000110" => tblu_rom:=X"085E";
      when "00010000111" => tblu_rom:=X"085E";
      when "00010001000" => tblu_rom:=X"0860";
      when "00010001001" => tblu_rom:=X"0860";
      when "00010001010" => tblu_rom:=X"0860";
      when "00010001011" => tblu_rom:=X"0862";
      when "00010001100" => tblu_rom:=X"0862";
      when "00010001101" => tblu_rom:=X"0864";
      when "00010001110" => tblu_rom:=X"0864";
      when "00010001111" => tblu_rom:=X"0864";
      when "00010010000" => tblu_rom:=X"0866";
      when "00010010001" => tblu_rom:=X"0866";
      when "00010010010" => tblu_rom:=X"0866";
      when "00010010011" => tblu_rom:=X"0868";
      when "00010010100" => tblu_rom:=X"0868";
      when "00010010101" => tblu_rom:=X"0868";
      when "00010010110" => tblu_rom:=X"086A";
      when "00010010111" => tblu_rom:=X"086A";
      when "00010011000" => tblu_rom:=X"086C";
      when "00010011001" => tblu_rom:=X"086C";
      when "00010011010" => tblu_rom:=X"086C";
      when "00010011011" => tblu_rom:=X"086E";
      when "00010011100" => tblu_rom:=X"086E";
      when "00010011101" => tblu_rom:=X"086E";
      when "00010011110" => tblu_rom:=X"0870";
      when "00010011111" => tblu_rom:=X"0870";
      when "00010100000" => tblu_rom:=X"0870";
      when "00010100001" => tblu_rom:=X"0872";
      when "00010100010" => tblu_rom:=X"0872";
      when "00010100011" => tblu_rom:=X"0874";
      when "00010100100" => tblu_rom:=X"0874";
      when "00010100101" => tblu_rom:=X"0874";
      when "00010100110" => tblu_rom:=X"0876";
      when "00010100111" => tblu_rom:=X"0876";
      when "00010101000" => tblu_rom:=X"0876";
      when "00010101001" => tblu_rom:=X"0878";
      when "00010101010" => tblu_rom:=X"0878";
      when "00010101011" => tblu_rom:=X"087A";
      when "00010101100" => tblu_rom:=X"087A";
      when "00010101101" => tblu_rom:=X"087A";
      when "00010101110" => tblu_rom:=X"087C";
      when "00010101111" => tblu_rom:=X"087C";
      when "00010110000" => tblu_rom:=X"087C";
      when "00010110001" => tblu_rom:=X"087E";
      when "00010110010" => tblu_rom:=X"087E";
      when "00010110011" => tblu_rom:=X"087E";
      when "00010110100" => tblu_rom:=X"0880";
      when "00010110101" => tblu_rom:=X"0880";
      when "00010110110" => tblu_rom:=X"0882";
      when "00010110111" => tblu_rom:=X"0882";
      when "00010111000" => tblu_rom:=X"0882";
      when "00010111001" => tblu_rom:=X"0884";
      when "00010111010" => tblu_rom:=X"0884";
      when "00010111011" => tblu_rom:=X"0884";
      when "00010111100" => tblu_rom:=X"0886";
      when "00010111101" => tblu_rom:=X"0886";
      when "00010111110" => tblu_rom:=X"0888";
      when "00010111111" => tblu_rom:=X"0888";
      when "00011000000" => tblu_rom:=X"0888";
      when "00011000001" => tblu_rom:=X"088A";
      when "00011000010" => tblu_rom:=X"088A";
      when "00011000011" => tblu_rom:=X"088A";
      when "00011000100" => tblu_rom:=X"088C";
      when "00011000101" => tblu_rom:=X"088C";
      when "00011000110" => tblu_rom:=X"088C";
      when "00011000111" => tblu_rom:=X"088E";
      when "00011001000" => tblu_rom:=X"088E";
      when "00011001001" => tblu_rom:=X"0890";
      when "00011001010" => tblu_rom:=X"0890";
      when "00011001011" => tblu_rom:=X"0890";
      when "00011001100" => tblu_rom:=X"0892";
      when "00011001101" => tblu_rom:=X"0892";
      when "00011001110" => tblu_rom:=X"0892";
      when "00011001111" => tblu_rom:=X"0894";
      when "00011010000" => tblu_rom:=X"0894";
      when "00011010001" => tblu_rom:=X"0896";
      when "00011010010" => tblu_rom:=X"0896";
      when "00011010011" => tblu_rom:=X"0896";
      when "00011010100" => tblu_rom:=X"0898";
      when "00011010101" => tblu_rom:=X"0898";
      when "00011010110" => tblu_rom:=X"0898";
      when "00011010111" => tblu_rom:=X"089A";
      when "00011011000" => tblu_rom:=X"089A";
      when "00011011001" => tblu_rom:=X"089C";
      when "00011011010" => tblu_rom:=X"089C";
      when "00011011011" => tblu_rom:=X"089C";
      when "00011011100" => tblu_rom:=X"089E";
      when "00011011101" => tblu_rom:=X"089E";
      when "00011011110" => tblu_rom:=X"089E";
      when "00011011111" => tblu_rom:=X"08A0";
      when "00011100000" => tblu_rom:=X"08A0";
      when "00011100001" => tblu_rom:=X"08A2";
      when "00011100010" => tblu_rom:=X"08A2";
      when "00011100011" => tblu_rom:=X"08A2";
      when "00011100100" => tblu_rom:=X"08A4";
      when "00011100101" => tblu_rom:=X"08A4";
      when "00011100110" => tblu_rom:=X"08A4";
      when "00011100111" => tblu_rom:=X"08A6";
      when "00011101000" => tblu_rom:=X"08A6";
      when "00011101001" => tblu_rom:=X"08A8";
      when "00011101010" => tblu_rom:=X"08A8";
      when "00011101011" => tblu_rom:=X"08A8";
      when "00011101100" => tblu_rom:=X"08AA";
      when "00011101101" => tblu_rom:=X"08AA";
      when "00011101110" => tblu_rom:=X"08AA";
      when "00011101111" => tblu_rom:=X"08AC";
      when "00011110000" => tblu_rom:=X"08AC";
      when "00011110001" => tblu_rom:=X"08AE";
      when "00011110010" => tblu_rom:=X"08AE";
      when "00011110011" => tblu_rom:=X"08AE";
      when "00011110100" => tblu_rom:=X"08B0";
      when "00011110101" => tblu_rom:=X"08B0";
      when "00011110110" => tblu_rom:=X"08B0";
      when "00011110111" => tblu_rom:=X"08B2";
      when "00011111000" => tblu_rom:=X"08B2";
      when "00011111001" => tblu_rom:=X"08B4";
      when "00011111010" => tblu_rom:=X"08B4";
      when "00011111011" => tblu_rom:=X"08B4";
      when "00011111100" => tblu_rom:=X"08B6";
      when "00011111101" => tblu_rom:=X"08B6";
      when "00011111110" => tblu_rom:=X"08B6";
      when "00011111111" => tblu_rom:=X"08B8";
      when "00100000000" => tblu_rom:=X"08B8";
      when "00100000001" => tblu_rom:=X"08BA";
      when "00100000010" => tblu_rom:=X"08BA";
      when "00100000011" => tblu_rom:=X"08BA";
      when "00100000100" => tblu_rom:=X"08BC";
      when "00100000101" => tblu_rom:=X"08BC";
      when "00100000110" => tblu_rom:=X"08BC";
      when "00100000111" => tblu_rom:=X"08BE";
      when "00100001000" => tblu_rom:=X"08BE";
      when "00100001001" => tblu_rom:=X"08C0";
      when "00100001010" => tblu_rom:=X"08C0";
      when "00100001011" => tblu_rom:=X"08C0";
      when "00100001100" => tblu_rom:=X"08C2";
      when "00100001101" => tblu_rom:=X"08C2";
      when "00100001110" => tblu_rom:=X"08C2";
      when "00100001111" => tblu_rom:=X"08C4";
      when "00100010000" => tblu_rom:=X"08C4";
      when "00100010001" => tblu_rom:=X"08C6";
      when "00100010010" => tblu_rom:=X"08C6";
      when "00100010011" => tblu_rom:=X"08C6";
      when "00100010100" => tblu_rom:=X"08C8";
      when "00100010101" => tblu_rom:=X"08C8";
      when "00100010110" => tblu_rom:=X"08CA";
      when "00100010111" => tblu_rom:=X"08CA";
      when "00100011000" => tblu_rom:=X"08CA";
      when "00100011001" => tblu_rom:=X"08CC";
      when "00100011010" => tblu_rom:=X"08CC";
      when "00100011011" => tblu_rom:=X"08CC";
      when "00100011100" => tblu_rom:=X"08CE";
      when "00100011101" => tblu_rom:=X"08CE";
      when "00100011110" => tblu_rom:=X"08D0";
      when "00100011111" => tblu_rom:=X"08D0";
      when "00100100000" => tblu_rom:=X"08D0";
      when "00100100001" => tblu_rom:=X"08D2";
      when "00100100010" => tblu_rom:=X"08D2";
      when "00100100011" => tblu_rom:=X"08D2";
      when "00100100100" => tblu_rom:=X"08D4";
      when "00100100101" => tblu_rom:=X"08D4";
      when "00100100110" => tblu_rom:=X"08D6";
      when "00100100111" => tblu_rom:=X"08D6";
      when "00100101000" => tblu_rom:=X"08D6";
      when "00100101001" => tblu_rom:=X"08D8";
      when "00100101010" => tblu_rom:=X"08D8";
      when "00100101011" => tblu_rom:=X"08DA";
      when "00100101100" => tblu_rom:=X"08DA";
      when "00100101101" => tblu_rom:=X"08DA";
      when "00100101110" => tblu_rom:=X"08DC";
      when "00100101111" => tblu_rom:=X"08DC";
      when "00100110000" => tblu_rom:=X"08DC";
      when "00100110001" => tblu_rom:=X"08DE";
      when "00100110010" => tblu_rom:=X"08DE";
      when "00100110011" => tblu_rom:=X"08E0";
      when "00100110100" => tblu_rom:=X"08E0";
      when "00100110101" => tblu_rom:=X"08E0";
      when "00100110110" => tblu_rom:=X"08E2";
      when "00100110111" => tblu_rom:=X"08E2";
      when "00100111000" => tblu_rom:=X"08E4";
      when "00100111001" => tblu_rom:=X"08E4";
      when "00100111010" => tblu_rom:=X"08E4";
      when "00100111011" => tblu_rom:=X"08E6";
      when "00100111100" => tblu_rom:=X"08E6";
      when "00100111101" => tblu_rom:=X"08E6";
      when "00100111110" => tblu_rom:=X"08E8";
      when "00100111111" => tblu_rom:=X"08E8";
      when "00101000000" => tblu_rom:=X"08EA";
      when "00101000001" => tblu_rom:=X"08EA";
      when "00101000010" => tblu_rom:=X"08EA";
      when "00101000011" => tblu_rom:=X"08EC";
      when "00101000100" => tblu_rom:=X"08EC";
      when "00101000101" => tblu_rom:=X"08EE";
      when "00101000110" => tblu_rom:=X"08EE";
      when "00101000111" => tblu_rom:=X"08EE";
      when "00101001000" => tblu_rom:=X"08F0";
      when "00101001001" => tblu_rom:=X"08F0";
      when "00101001010" => tblu_rom:=X"08F2";
      when "00101001011" => tblu_rom:=X"08F2";
      when "00101001100" => tblu_rom:=X"08F2";
      when "00101001101" => tblu_rom:=X"08F4";
      when "00101001110" => tblu_rom:=X"08F4";
      when "00101001111" => tblu_rom:=X"08F4";
      when "00101010000" => tblu_rom:=X"08F6";
      when "00101010001" => tblu_rom:=X"08F6";
      when "00101010010" => tblu_rom:=X"08F8";
      when "00101010011" => tblu_rom:=X"08F8";
      when "00101010100" => tblu_rom:=X"08F8";
      when "00101010101" => tblu_rom:=X"08FA";
      when "00101010110" => tblu_rom:=X"08FA";
      when "00101010111" => tblu_rom:=X"08FC";
      when "00101011000" => tblu_rom:=X"08FC";
      when "00101011001" => tblu_rom:=X"08FC";
      when "00101011010" => tblu_rom:=X"08FE";
      when "00101011011" => tblu_rom:=X"08FE";
      when "00101011100" => tblu_rom:=X"08FE";
      when "00101011101" => tblu_rom:=X"0900";
      when "00101011110" => tblu_rom:=X"0900";
      when "00101011111" => tblu_rom:=X"0902";
      when "00101100000" => tblu_rom:=X"0902";
      when "00101100001" => tblu_rom:=X"0902";
      when "00101100010" => tblu_rom:=X"0904";
      when "00101100011" => tblu_rom:=X"0904";
      when "00101100100" => tblu_rom:=X"0906";
      when "00101100101" => tblu_rom:=X"0906";
      when "00101100110" => tblu_rom:=X"0906";
      when "00101100111" => tblu_rom:=X"0908";
      when "00101101000" => tblu_rom:=X"0908";
      when "00101101001" => tblu_rom:=X"090A";
      when "00101101010" => tblu_rom:=X"090A";
      when "00101101011" => tblu_rom:=X"090A";
      when "00101101100" => tblu_rom:=X"090C";
      when "00101101101" => tblu_rom:=X"090C";
      when "00101101110" => tblu_rom:=X"090E";
      when "00101101111" => tblu_rom:=X"090E";
      when "00101110000" => tblu_rom:=X"090E";
      when "00101110001" => tblu_rom:=X"0910";
      when "00101110010" => tblu_rom:=X"0910";
      when "00101110011" => tblu_rom:=X"0912";
      when "00101110100" => tblu_rom:=X"0912";
      when "00101110101" => tblu_rom:=X"0912";
      when "00101110110" => tblu_rom:=X"0914";
      when "00101110111" => tblu_rom:=X"0914";
      when "00101111000" => tblu_rom:=X"0914";
      when "00101111001" => tblu_rom:=X"0916";
      when "00101111010" => tblu_rom:=X"0916";
      when "00101111011" => tblu_rom:=X"0918";
      when "00101111100" => tblu_rom:=X"0918";
      when "00101111101" => tblu_rom:=X"0918";
      when "00101111110" => tblu_rom:=X"091A";
      when "00101111111" => tblu_rom:=X"091A";
      when "00110000000" => tblu_rom:=X"091C";
      when "00110000001" => tblu_rom:=X"091C";
      when "00110000010" => tblu_rom:=X"091C";
      when "00110000011" => tblu_rom:=X"091E";
      when "00110000100" => tblu_rom:=X"091E";
      when "00110000101" => tblu_rom:=X"0920";
      when "00110000110" => tblu_rom:=X"0920";
      when "00110000111" => tblu_rom:=X"0920";
      when "00110001000" => tblu_rom:=X"0922";
      when "00110001001" => tblu_rom:=X"0922";
      when "00110001010" => tblu_rom:=X"0924";
      when "00110001011" => tblu_rom:=X"0924";
      when "00110001100" => tblu_rom:=X"0924";
      when "00110001101" => tblu_rom:=X"0926";
      when "00110001110" => tblu_rom:=X"0926";
      when "00110001111" => tblu_rom:=X"0928";
      when "00110010000" => tblu_rom:=X"0928";
      when "00110010001" => tblu_rom:=X"0928";
      when "00110010010" => tblu_rom:=X"092A";
      when "00110010011" => tblu_rom:=X"092A";
      when "00110010100" => tblu_rom:=X"092C";
      when "00110010101" => tblu_rom:=X"092C";
      when "00110010110" => tblu_rom:=X"092C";
      when "00110010111" => tblu_rom:=X"092E";
      when "00110011000" => tblu_rom:=X"092E";
      when "00110011001" => tblu_rom:=X"0930";
      when "00110011010" => tblu_rom:=X"0930";
      when "00110011011" => tblu_rom:=X"0930";
      when "00110011100" => tblu_rom:=X"0932";
      when "00110011101" => tblu_rom:=X"0932";
      when "00110011110" => tblu_rom:=X"0934";
      when "00110011111" => tblu_rom:=X"0934";
      when "00110100000" => tblu_rom:=X"0934";
      when "00110100001" => tblu_rom:=X"0936";
      when "00110100010" => tblu_rom:=X"0936";
      when "00110100011" => tblu_rom:=X"0938";
      when "00110100100" => tblu_rom:=X"0938";
      when "00110100101" => tblu_rom:=X"0938";
      when "00110100110" => tblu_rom:=X"093A";
      when "00110100111" => tblu_rom:=X"093A";
      when "00110101000" => tblu_rom:=X"093C";
      when "00110101001" => tblu_rom:=X"093C";
      when "00110101010" => tblu_rom:=X"093C";
      when "00110101011" => tblu_rom:=X"093E";
      when "00110101100" => tblu_rom:=X"093E";
      when "00110101101" => tblu_rom:=X"0940";
      when "00110101110" => tblu_rom:=X"0940";
      when "00110101111" => tblu_rom:=X"0940";
      when "00110110000" => tblu_rom:=X"0942";
      when "00110110001" => tblu_rom:=X"0942";
      when "00110110010" => tblu_rom:=X"0944";
      when "00110110011" => tblu_rom:=X"0944";
      when "00110110100" => tblu_rom:=X"0944";
      when "00110110101" => tblu_rom:=X"0946";
      when "00110110110" => tblu_rom:=X"0946";
      when "00110110111" => tblu_rom:=X"0948";
      when "00110111000" => tblu_rom:=X"0948";
      when "00110111001" => tblu_rom:=X"0948";
      when "00110111010" => tblu_rom:=X"094A";
      when "00110111011" => tblu_rom:=X"094A";
      when "00110111100" => tblu_rom:=X"094C";
      when "00110111101" => tblu_rom:=X"094C";
      when "00110111110" => tblu_rom:=X"094C";
      when "00110111111" => tblu_rom:=X"094E";
      when "00111000000" => tblu_rom:=X"094E";
      when "00111000001" => tblu_rom:=X"0950";
      when "00111000010" => tblu_rom:=X"0950";
      when "00111000011" => tblu_rom:=X"0950";
      when "00111000100" => tblu_rom:=X"0952";
      when "00111000101" => tblu_rom:=X"0952";
      when "00111000110" => tblu_rom:=X"0954";
      when "00111000111" => tblu_rom:=X"0954";
      when "00111001000" => tblu_rom:=X"0954";
      when "00111001001" => tblu_rom:=X"0956";
      when "00111001010" => tblu_rom:=X"0956";
      when "00111001011" => tblu_rom:=X"0958";
      when "00111001100" => tblu_rom:=X"0958";
      when "00111001101" => tblu_rom:=X"0958";
      when "00111001110" => tblu_rom:=X"095A";
      when "00111001111" => tblu_rom:=X"095A";
      when "00111010000" => tblu_rom:=X"095C";
      when "00111010001" => tblu_rom:=X"095C";
      when "00111010010" => tblu_rom:=X"095C";
      when "00111010011" => tblu_rom:=X"095E";
      when "00111010100" => tblu_rom:=X"095E";
      when "00111010101" => tblu_rom:=X"0960";
      when "00111010110" => tblu_rom:=X"0960";
      when "00111010111" => tblu_rom:=X"0960";
      when "00111011000" => tblu_rom:=X"0962";
      when "00111011001" => tblu_rom:=X"0962";
      when "00111011010" => tblu_rom:=X"0964";
      when "00111011011" => tblu_rom:=X"0964";
      when "00111011100" => tblu_rom:=X"0966";
      when "00111011101" => tblu_rom:=X"0966";
      when "00111011110" => tblu_rom:=X"0966";
      when "00111011111" => tblu_rom:=X"0968";
      when "00111100000" => tblu_rom:=X"0968";
      when "00111100001" => tblu_rom:=X"096A";
      when "00111100010" => tblu_rom:=X"096A";
      when "00111100011" => tblu_rom:=X"096A";
      when "00111100100" => tblu_rom:=X"096C";
      when "00111100101" => tblu_rom:=X"096C";
      when "00111100110" => tblu_rom:=X"096E";
      when "00111100111" => tblu_rom:=X"096E";
      when "00111101000" => tblu_rom:=X"096E";
      when "00111101001" => tblu_rom:=X"0970";
      when "00111101010" => tblu_rom:=X"0970";
      when "00111101011" => tblu_rom:=X"0972";
      when "00111101100" => tblu_rom:=X"0972";
      when "00111101101" => tblu_rom:=X"0972";
      when "00111101110" => tblu_rom:=X"0974";
      when "00111101111" => tblu_rom:=X"0974";
      when "00111110000" => tblu_rom:=X"0976";
      when "00111110001" => tblu_rom:=X"0976";
      when "00111110010" => tblu_rom:=X"0976";
      when "00111110011" => tblu_rom:=X"0978";
      when "00111110100" => tblu_rom:=X"0978";
      when "00111110101" => tblu_rom:=X"097A";
      when "00111110110" => tblu_rom:=X"097A";
      when "00111110111" => tblu_rom:=X"097C";
      when "00111111000" => tblu_rom:=X"097C";
      when "00111111001" => tblu_rom:=X"097C";
      when "00111111010" => tblu_rom:=X"097E";
      when "00111111011" => tblu_rom:=X"097E";
      when "00111111100" => tblu_rom:=X"0980";
      when "00111111101" => tblu_rom:=X"0980";
      when "00111111110" => tblu_rom:=X"0980";
      when "00111111111" => tblu_rom:=X"0982";
      when "01000000000" => tblu_rom:=X"0982";
      when "01000000001" => tblu_rom:=X"0984";
      when "01000000010" => tblu_rom:=X"0984";
      when "01000000011" => tblu_rom:=X"0984";
      when "01000000100" => tblu_rom:=X"0986";
      when "01000000101" => tblu_rom:=X"0986";
      when "01000000110" => tblu_rom:=X"0988";
      when "01000000111" => tblu_rom:=X"0988";
      when "01000001000" => tblu_rom:=X"098A";
      when "01000001001" => tblu_rom:=X"098A";
      when "01000001010" => tblu_rom:=X"098A";
      when "01000001011" => tblu_rom:=X"098C";
      when "01000001100" => tblu_rom:=X"098C";
      when "01000001101" => tblu_rom:=X"098E";
      when "01000001110" => tblu_rom:=X"098E";
      when "01000001111" => tblu_rom:=X"098E";
      when "01000010000" => tblu_rom:=X"0990";
      when "01000010001" => tblu_rom:=X"0990";
      when "01000010010" => tblu_rom:=X"0992";
      when "01000010011" => tblu_rom:=X"0992";
      when "01000010100" => tblu_rom:=X"0994";
      when "01000010101" => tblu_rom:=X"0994";
      when "01000010110" => tblu_rom:=X"0994";
      when "01000010111" => tblu_rom:=X"0996";
      when "01000011000" => tblu_rom:=X"0996";
      when "01000011001" => tblu_rom:=X"0998";
      when "01000011010" => tblu_rom:=X"0998";
      when "01000011011" => tblu_rom:=X"0998";
      when "01000011100" => tblu_rom:=X"099A";
      when "01000011101" => tblu_rom:=X"099A";
      when "01000011110" => tblu_rom:=X"099C";
      when "01000011111" => tblu_rom:=X"099C";
      when "01000100000" => tblu_rom:=X"099E";
      when "01000100001" => tblu_rom:=X"099E";
      when "01000100010" => tblu_rom:=X"099E";
      when "01000100011" => tblu_rom:=X"09A0";
      when "01000100100" => tblu_rom:=X"09A0";
      when "01000100101" => tblu_rom:=X"09A2";
      when "01000100110" => tblu_rom:=X"09A2";
      when "01000100111" => tblu_rom:=X"09A2";
      when "01000101000" => tblu_rom:=X"09A4";
      when "01000101001" => tblu_rom:=X"09A4";
      when "01000101010" => tblu_rom:=X"09A6";
      when "01000101011" => tblu_rom:=X"09A6";
      when "01000101100" => tblu_rom:=X"09A8";
      when "01000101101" => tblu_rom:=X"09A8";
      when "01000101110" => tblu_rom:=X"09A8";
      when "01000101111" => tblu_rom:=X"09AA";
      when "01000110000" => tblu_rom:=X"09AA";
      when "01000110001" => tblu_rom:=X"09AC";
      when "01000110010" => tblu_rom:=X"09AC";
      when "01000110011" => tblu_rom:=X"09AC";
      when "01000110100" => tblu_rom:=X"09AE";
      when "01000110101" => tblu_rom:=X"09AE";
      when "01000110110" => tblu_rom:=X"09B0";
      when "01000110111" => tblu_rom:=X"09B0";
      when "01000111000" => tblu_rom:=X"09B2";
      when "01000111001" => tblu_rom:=X"09B2";
      when "01000111010" => tblu_rom:=X"09B2";
      when "01000111011" => tblu_rom:=X"09B4";
      when "01000111100" => tblu_rom:=X"09B4";
      when "01000111101" => tblu_rom:=X"09B6";
      when "01000111110" => tblu_rom:=X"09B6";
      when "01000111111" => tblu_rom:=X"09B6";
      when "01001000000" => tblu_rom:=X"09B8";
      when "01001000001" => tblu_rom:=X"09B8";
      when "01001000010" => tblu_rom:=X"09BA";
      when "01001000011" => tblu_rom:=X"09BA";
      when "01001000100" => tblu_rom:=X"09BC";
      when "01001000101" => tblu_rom:=X"09BC";
      when "01001000110" => tblu_rom:=X"09BC";
      when "01001000111" => tblu_rom:=X"09BE";
      when "01001001000" => tblu_rom:=X"09BE";
      when "01001001001" => tblu_rom:=X"09C0";
      when "01001001010" => tblu_rom:=X"09C0";
      when "01001001011" => tblu_rom:=X"09C2";
      when "01001001100" => tblu_rom:=X"09C2";
      when "01001001101" => tblu_rom:=X"09C2";
      when "01001001110" => tblu_rom:=X"09C4";
      when "01001001111" => tblu_rom:=X"09C4";
      when "01001010000" => tblu_rom:=X"09C6";
      when "01001010001" => tblu_rom:=X"09C6";
      when "01001010010" => tblu_rom:=X"09C8";
      when "01001010011" => tblu_rom:=X"09C8";
      when "01001010100" => tblu_rom:=X"09C8";
      when "01001010101" => tblu_rom:=X"09CA";
      when "01001010110" => tblu_rom:=X"09CA";
      when "01001010111" => tblu_rom:=X"09CC";
      when "01001011000" => tblu_rom:=X"09CC";
      when "01001011001" => tblu_rom:=X"09CC";
      when "01001011010" => tblu_rom:=X"09CE";
      when "01001011011" => tblu_rom:=X"09CE";
      when "01001011100" => tblu_rom:=X"09D0";
      when "01001011101" => tblu_rom:=X"09D0";
      when "01001011110" => tblu_rom:=X"09D2";
      when "01001011111" => tblu_rom:=X"09D2";
      when "01001100000" => tblu_rom:=X"09D2";
      when "01001100001" => tblu_rom:=X"09D4";
      when "01001100010" => tblu_rom:=X"09D4";
      when "01001100011" => tblu_rom:=X"09D6";
      when "01001100100" => tblu_rom:=X"09D6";
      when "01001100101" => tblu_rom:=X"09D8";
      when "01001100110" => tblu_rom:=X"09D8";
      when "01001100111" => tblu_rom:=X"09D8";
      when "01001101000" => tblu_rom:=X"09DA";
      when "01001101001" => tblu_rom:=X"09DA";
      when "01001101010" => tblu_rom:=X"09DC";
      when "01001101011" => tblu_rom:=X"09DC";
      when "01001101100" => tblu_rom:=X"09DE";
      when "01001101101" => tblu_rom:=X"09DE";
      when "01001101110" => tblu_rom:=X"09DE";
      when "01001101111" => tblu_rom:=X"09E0";
      when "01001110000" => tblu_rom:=X"09E0";
      when "01001110001" => tblu_rom:=X"09E2";
      when "01001110010" => tblu_rom:=X"09E2";
      when "01001110011" => tblu_rom:=X"09E4";
      when "01001110100" => tblu_rom:=X"09E4";
      when "01001110101" => tblu_rom:=X"09E4";
      when "01001110110" => tblu_rom:=X"09E6";
      when "01001110111" => tblu_rom:=X"09E6";
      when "01001111000" => tblu_rom:=X"09E8";
      when "01001111001" => tblu_rom:=X"09E8";
      when "01001111010" => tblu_rom:=X"09EA";
      when "01001111011" => tblu_rom:=X"09EA";
      when "01001111100" => tblu_rom:=X"09EA";
      when "01001111101" => tblu_rom:=X"09EC";
      when "01001111110" => tblu_rom:=X"09EC";
      when "01001111111" => tblu_rom:=X"09EE";
      when "01010000000" => tblu_rom:=X"09EE";
      when "01010000001" => tblu_rom:=X"09F0";
      when "01010000010" => tblu_rom:=X"09F0";
      when "01010000011" => tblu_rom:=X"09F0";
      when "01010000100" => tblu_rom:=X"09F2";
      when "01010000101" => tblu_rom:=X"09F2";
      when "01010000110" => tblu_rom:=X"09F4";
      when "01010000111" => tblu_rom:=X"09F4";
      when "01010001000" => tblu_rom:=X"09F6";
      when "01010001001" => tblu_rom:=X"09F6";
      when "01010001010" => tblu_rom:=X"09F6";
      when "01010001011" => tblu_rom:=X"09F8";
      when "01010001100" => tblu_rom:=X"09F8";
      when "01010001101" => tblu_rom:=X"09FA";
      when "01010001110" => tblu_rom:=X"09FA";
      when "01010001111" => tblu_rom:=X"09FC";
      when "01010010000" => tblu_rom:=X"09FC";
      when "01010010001" => tblu_rom:=X"09FE";
      when "01010010010" => tblu_rom:=X"09FE";
      when "01010010011" => tblu_rom:=X"09FE";
      when "01010010100" => tblu_rom:=X"0A00";
      when "01010010101" => tblu_rom:=X"0A00";
      when "01010010110" => tblu_rom:=X"0A02";
      when "01010010111" => tblu_rom:=X"0A02";
      when "01010011000" => tblu_rom:=X"0A04";
      when "01010011001" => tblu_rom:=X"0A04";
      when "01010011010" => tblu_rom:=X"0A04";
      when "01010011011" => tblu_rom:=X"0A06";
      when "01010011100" => tblu_rom:=X"0A06";
      when "01010011101" => tblu_rom:=X"0A08";
      when "01010011110" => tblu_rom:=X"0A08";
      when "01010011111" => tblu_rom:=X"0A0A";
      when "01010100000" => tblu_rom:=X"0A0A";
      when "01010100001" => tblu_rom:=X"0A0A";
      when "01010100010" => tblu_rom:=X"0A0C";
      when "01010100011" => tblu_rom:=X"0A0C";
      when "01010100100" => tblu_rom:=X"0A0E";
      when "01010100101" => tblu_rom:=X"0A0E";
      when "01010100110" => tblu_rom:=X"0A10";
      when "01010100111" => tblu_rom:=X"0A10";
      when "01010101000" => tblu_rom:=X"0A10";
      when "01010101001" => tblu_rom:=X"0A12";
      when "01010101010" => tblu_rom:=X"0A12";
      when "01010101011" => tblu_rom:=X"0A14";
      when "01010101100" => tblu_rom:=X"0A14";
      when "01010101101" => tblu_rom:=X"0A16";
      when "01010101110" => tblu_rom:=X"0A16";
      when "01010101111" => tblu_rom:=X"0A18";
      when "01010110000" => tblu_rom:=X"0A18";
      when "01010110001" => tblu_rom:=X"0A18";
      when "01010110010" => tblu_rom:=X"0A1A";
      when "01010110011" => tblu_rom:=X"0A1A";
      when "01010110100" => tblu_rom:=X"0A1C";
      when "01010110101" => tblu_rom:=X"0A1C";
      when "01010110110" => tblu_rom:=X"0A1E";
      when "01010110111" => tblu_rom:=X"0A1E";
      when "01010111000" => tblu_rom:=X"0A1E";
      when "01010111001" => tblu_rom:=X"0A20";
      when "01010111010" => tblu_rom:=X"0A20";
      when "01010111011" => tblu_rom:=X"0A22";
      when "01010111100" => tblu_rom:=X"0A22";
      when "01010111101" => tblu_rom:=X"0A24";
      when "01010111110" => tblu_rom:=X"0A24";
      when "01010111111" => tblu_rom:=X"0A26";
      when "01011000000" => tblu_rom:=X"0A26";
      when "01011000001" => tblu_rom:=X"0A26";
      when "01011000010" => tblu_rom:=X"0A28";
      when "01011000011" => tblu_rom:=X"0A28";
      when "01011000100" => tblu_rom:=X"0A2A";
      when "01011000101" => tblu_rom:=X"0A2A";
      when "01011000110" => tblu_rom:=X"0A2C";
      when "01011000111" => tblu_rom:=X"0A2C";
      when "01011001000" => tblu_rom:=X"0A2E";
      when "01011001001" => tblu_rom:=X"0A2E";
      when "01011001010" => tblu_rom:=X"0A2E";
      when "01011001011" => tblu_rom:=X"0A30";
      when "01011001100" => tblu_rom:=X"0A30";
      when "01011001101" => tblu_rom:=X"0A32";
      when "01011001110" => tblu_rom:=X"0A32";
      when "01011001111" => tblu_rom:=X"0A34";
      when "01011010000" => tblu_rom:=X"0A34";
      when "01011010001" => tblu_rom:=X"0A36";
      when "01011010010" => tblu_rom:=X"0A36";
      when "01011010011" => tblu_rom:=X"0A36";
      when "01011010100" => tblu_rom:=X"0A38";
      when "01011010101" => tblu_rom:=X"0A38";
      when "01011010110" => tblu_rom:=X"0A3A";
      when "01011010111" => tblu_rom:=X"0A3A";
      when "01011011000" => tblu_rom:=X"0A3C";
      when "01011011001" => tblu_rom:=X"0A3C";
      when "01011011010" => tblu_rom:=X"0A3C";
      when "01011011011" => tblu_rom:=X"0A3E";
      when "01011011100" => tblu_rom:=X"0A3E";
      when "01011011101" => tblu_rom:=X"0A40";
      when "01011011110" => tblu_rom:=X"0A40";
      when "01011011111" => tblu_rom:=X"0A42";
      when "01011100000" => tblu_rom:=X"0A42";
      when "01011100001" => tblu_rom:=X"0A44";
      when "01011100010" => tblu_rom:=X"0A44";
      when "01011100011" => tblu_rom:=X"0A44";
      when "01011100100" => tblu_rom:=X"0A46";
      when "01011100101" => tblu_rom:=X"0A46";
      when "01011100110" => tblu_rom:=X"0A48";
      when "01011100111" => tblu_rom:=X"0A48";
      when "01011101000" => tblu_rom:=X"0A4A";
      when "01011101001" => tblu_rom:=X"0A4A";
      when "01011101010" => tblu_rom:=X"0A4C";
      when "01011101011" => tblu_rom:=X"0A4C";
      when "01011101100" => tblu_rom:=X"0A4E";
      when "01011101101" => tblu_rom:=X"0A4E";
      when "01011101110" => tblu_rom:=X"0A4E";
      when "01011101111" => tblu_rom:=X"0A50";
      when "01011110000" => tblu_rom:=X"0A50";
      when "01011110001" => tblu_rom:=X"0A52";
      when "01011110010" => tblu_rom:=X"0A52";
      when "01011110011" => tblu_rom:=X"0A54";
      when "01011110100" => tblu_rom:=X"0A54";
      when "01011110101" => tblu_rom:=X"0A56";
      when "01011110110" => tblu_rom:=X"0A56";
      when "01011110111" => tblu_rom:=X"0A56";
      when "01011111000" => tblu_rom:=X"0A58";
      when "01011111001" => tblu_rom:=X"0A58";
      when "01011111010" => tblu_rom:=X"0A5A";
      when "01011111011" => tblu_rom:=X"0A5A";
      when "01011111100" => tblu_rom:=X"0A5C";
      when "01011111101" => tblu_rom:=X"0A5C";
      when "01011111110" => tblu_rom:=X"0A5E";
      when "01011111111" => tblu_rom:=X"0A5E";
      when "01100000000" => tblu_rom:=X"0A5E";
      when "01100000001" => tblu_rom:=X"0A60";
      when "01100000010" => tblu_rom:=X"0A60";
      when "01100000011" => tblu_rom:=X"0A62";
      when "01100000100" => tblu_rom:=X"0A62";
      when "01100000101" => tblu_rom:=X"0A64";
      when "01100000110" => tblu_rom:=X"0A64";
      when "01100000111" => tblu_rom:=X"0A66";
      when "01100001000" => tblu_rom:=X"0A66";
      when "01100001001" => tblu_rom:=X"0A68";
      when "01100001010" => tblu_rom:=X"0A68";
      when "01100001011" => tblu_rom:=X"0A68";
      when "01100001100" => tblu_rom:=X"0A6A";
      when "01100001101" => tblu_rom:=X"0A6A";
      when "01100001110" => tblu_rom:=X"0A6C";
      when "01100001111" => tblu_rom:=X"0A6C";
      when "01100010000" => tblu_rom:=X"0A6E";
      when "01100010001" => tblu_rom:=X"0A6E";
      when "01100010010" => tblu_rom:=X"0A70";
      when "01100010011" => tblu_rom:=X"0A70";
      when "01100010100" => tblu_rom:=X"0A70";
      when "01100010101" => tblu_rom:=X"0A72";
      when "01100010110" => tblu_rom:=X"0A72";
      when "01100010111" => tblu_rom:=X"0A74";
      when "01100011000" => tblu_rom:=X"0A74";
      when "01100011001" => tblu_rom:=X"0A76";
      when "01100011010" => tblu_rom:=X"0A76";
      when "01100011011" => tblu_rom:=X"0A78";
      when "01100011100" => tblu_rom:=X"0A78";
      when "01100011101" => tblu_rom:=X"0A7A";
      when "01100011110" => tblu_rom:=X"0A7A";
      when "01100011111" => tblu_rom:=X"0A7A";
      when "01100100000" => tblu_rom:=X"0A7C";
      when "01100100001" => tblu_rom:=X"0A7C";
      when "01100100010" => tblu_rom:=X"0A7E";
      when "01100100011" => tblu_rom:=X"0A7E";
      when "01100100100" => tblu_rom:=X"0A80";
      when "01100100101" => tblu_rom:=X"0A80";
      when "01100100110" => tblu_rom:=X"0A82";
      when "01100100111" => tblu_rom:=X"0A82";
      when "01100101000" => tblu_rom:=X"0A84";
      when "01100101001" => tblu_rom:=X"0A84";
      when "01100101010" => tblu_rom:=X"0A84";
      when "01100101011" => tblu_rom:=X"0A86";
      when "01100101100" => tblu_rom:=X"0A86";
      when "01100101101" => tblu_rom:=X"0A88";
      when "01100101110" => tblu_rom:=X"0A88";
      when "01100101111" => tblu_rom:=X"0A8A";
      when "01100110000" => tblu_rom:=X"0A8A";
      when "01100110001" => tblu_rom:=X"0A8C";
      when "01100110010" => tblu_rom:=X"0A8C";
      when "01100110011" => tblu_rom:=X"0A8E";
      when "01100110100" => tblu_rom:=X"0A8E";
      when "01100110101" => tblu_rom:=X"0A8E";
      when "01100110110" => tblu_rom:=X"0A90";
      when "01100110111" => tblu_rom:=X"0A90";
      when "01100111000" => tblu_rom:=X"0A92";
      when "01100111001" => tblu_rom:=X"0A92";
      when "01100111010" => tblu_rom:=X"0A94";
      when "01100111011" => tblu_rom:=X"0A94";
      when "01100111100" => tblu_rom:=X"0A96";
      when "01100111101" => tblu_rom:=X"0A96";
      when "01100111110" => tblu_rom:=X"0A98";
      when "01100111111" => tblu_rom:=X"0A98";
      when "01101000000" => tblu_rom:=X"0A9A";
      when "01101000001" => tblu_rom:=X"0A9A";
      when "01101000010" => tblu_rom:=X"0A9A";
      when "01101000011" => tblu_rom:=X"0A9C";
      when "01101000100" => tblu_rom:=X"0A9C";
      when "01101000101" => tblu_rom:=X"0A9E";
      when "01101000110" => tblu_rom:=X"0A9E";
      when "01101000111" => tblu_rom:=X"0AA0";
      when "01101001000" => tblu_rom:=X"0AA0";
      when "01101001001" => tblu_rom:=X"0AA2";
      when "01101001010" => tblu_rom:=X"0AA2";
      when "01101001011" => tblu_rom:=X"0AA4";
      when "01101001100" => tblu_rom:=X"0AA4";
      when "01101001101" => tblu_rom:=X"0AA6";
      when "01101001110" => tblu_rom:=X"0AA6";
      when "01101001111" => tblu_rom:=X"0AA6";
      when "01101010000" => tblu_rom:=X"0AA8";
      when "01101010001" => tblu_rom:=X"0AA8";
      when "01101010010" => tblu_rom:=X"0AAA";
      when "01101010011" => tblu_rom:=X"0AAA";
      when "01101010100" => tblu_rom:=X"0AAC";
      when "01101010101" => tblu_rom:=X"0AAC";
      when "01101010110" => tblu_rom:=X"0AAE";
      when "01101010111" => tblu_rom:=X"0AAE";
      when "01101011000" => tblu_rom:=X"0AB0";
      when "01101011001" => tblu_rom:=X"0AB0";
      when "01101011010" => tblu_rom:=X"0AB2";
      when "01101011011" => tblu_rom:=X"0AB2";
      when "01101011100" => tblu_rom:=X"0AB2";
      when "01101011101" => tblu_rom:=X"0AB4";
      when "01101011110" => tblu_rom:=X"0AB4";
      when "01101011111" => tblu_rom:=X"0AB6";
      when "01101100000" => tblu_rom:=X"0AB6";
      when "01101100001" => tblu_rom:=X"0AB8";
      when "01101100010" => tblu_rom:=X"0AB8";
      when "01101100011" => tblu_rom:=X"0ABA";
      when "01101100100" => tblu_rom:=X"0ABA";
      when "01101100101" => tblu_rom:=X"0ABC";
      when "01101100110" => tblu_rom:=X"0ABC";
      when "01101100111" => tblu_rom:=X"0ABE";
      when "01101101000" => tblu_rom:=X"0ABE";
      when "01101101001" => tblu_rom:=X"0AC0";
      when "01101101010" => tblu_rom:=X"0AC0";
      when "01101101011" => tblu_rom:=X"0AC0";
      when "01101101100" => tblu_rom:=X"0AC2";
      when "01101101101" => tblu_rom:=X"0AC2";
      when "01101101110" => tblu_rom:=X"0AC4";
      when "01101101111" => tblu_rom:=X"0AC4";
      when "01101110000" => tblu_rom:=X"0AC6";
      when "01101110001" => tblu_rom:=X"0AC6";
      when "01101110010" => tblu_rom:=X"0AC8";
      when "01101110011" => tblu_rom:=X"0AC8";
      when "01101110100" => tblu_rom:=X"0ACA";
      when "01101110101" => tblu_rom:=X"0ACA";
      when "01101110110" => tblu_rom:=X"0ACC";
      when "01101110111" => tblu_rom:=X"0ACC";
      when "01101111000" => tblu_rom:=X"0ACE";
      when "01101111001" => tblu_rom:=X"0ACE";
      when "01101111010" => tblu_rom:=X"0ACE";
      when "01101111011" => tblu_rom:=X"0AD0";
      when "01101111100" => tblu_rom:=X"0AD0";
      when "01101111101" => tblu_rom:=X"0AD2";
      when "01101111110" => tblu_rom:=X"0AD2";
      when "01101111111" => tblu_rom:=X"0AD4";
      when "01110000000" => tblu_rom:=X"0AD4";
      when "01110000001" => tblu_rom:=X"0AD6";
      when "01110000010" => tblu_rom:=X"0AD6";
      when "01110000011" => tblu_rom:=X"0AD8";
      when "01110000100" => tblu_rom:=X"0AD8";
      when "01110000101" => tblu_rom:=X"0ADA";
      when "01110000110" => tblu_rom:=X"0ADA";
      when "01110000111" => tblu_rom:=X"0ADC";
      when "01110001000" => tblu_rom:=X"0ADC";
      when "01110001001" => tblu_rom:=X"0ADC";
      when "01110001010" => tblu_rom:=X"0ADE";
      when "01110001011" => tblu_rom:=X"0ADE";
      when "01110001100" => tblu_rom:=X"0AE0";
      when "01110001101" => tblu_rom:=X"0AE0";
      when "01110001110" => tblu_rom:=X"0AE2";
      when "01110001111" => tblu_rom:=X"0AE2";
      when "01110010000" => tblu_rom:=X"0AE4";
      when "01110010001" => tblu_rom:=X"0AE4";
      when "01110010010" => tblu_rom:=X"0AE6";
      when "01110010011" => tblu_rom:=X"0AE6";
      when "01110010100" => tblu_rom:=X"0AE8";
      when "01110010101" => tblu_rom:=X"0AE8";
      when "01110010110" => tblu_rom:=X"0AEA";
      when "01110010111" => tblu_rom:=X"0AEA";
      when "01110011000" => tblu_rom:=X"0AEC";
      when "01110011001" => tblu_rom:=X"0AEC";
      when "01110011010" => tblu_rom:=X"0AEE";
      when "01110011011" => tblu_rom:=X"0AEE";
      when "01110011100" => tblu_rom:=X"0AEE";
      when "01110011101" => tblu_rom:=X"0AF0";
      when "01110011110" => tblu_rom:=X"0AF0";
      when "01110011111" => tblu_rom:=X"0AF2";
      when "01110100000" => tblu_rom:=X"0AF2";
      when "01110100001" => tblu_rom:=X"0AF4";
      when "01110100010" => tblu_rom:=X"0AF4";
      when "01110100011" => tblu_rom:=X"0AF6";
      when "01110100100" => tblu_rom:=X"0AF6";
      when "01110100101" => tblu_rom:=X"0AF8";
      when "01110100110" => tblu_rom:=X"0AF8";
      when "01110100111" => tblu_rom:=X"0AFA";
      when "01110101000" => tblu_rom:=X"0AFA";
      when "01110101001" => tblu_rom:=X"0AFC";
      when "01110101010" => tblu_rom:=X"0AFC";
      when "01110101011" => tblu_rom:=X"0AFE";
      when "01110101100" => tblu_rom:=X"0AFE";
      when "01110101101" => tblu_rom:=X"0B00";
      when "01110101110" => tblu_rom:=X"0B00";
      when "01110101111" => tblu_rom:=X"0B00";
      when "01110110000" => tblu_rom:=X"0B02";
      when "01110110001" => tblu_rom:=X"0B02";
      when "01110110010" => tblu_rom:=X"0B04";
      when "01110110011" => tblu_rom:=X"0B04";
      when "01110110100" => tblu_rom:=X"0B06";
      when "01110110101" => tblu_rom:=X"0B06";
      when "01110110110" => tblu_rom:=X"0B08";
      when "01110110111" => tblu_rom:=X"0B08";
      when "01110111000" => tblu_rom:=X"0B0A";
      when "01110111001" => tblu_rom:=X"0B0A";
      when "01110111010" => tblu_rom:=X"0B0C";
      when "01110111011" => tblu_rom:=X"0B0C";
      when "01110111100" => tblu_rom:=X"0B0E";
      when "01110111101" => tblu_rom:=X"0B0E";
      when "01110111110" => tblu_rom:=X"0B10";
      when "01110111111" => tblu_rom:=X"0B10";
      when "01111000000" => tblu_rom:=X"0B12";
      when "01111000001" => tblu_rom:=X"0B12";
      when "01111000010" => tblu_rom:=X"0B14";
      when "01111000011" => tblu_rom:=X"0B14";
      when "01111000100" => tblu_rom:=X"0B16";
      when "01111000101" => tblu_rom:=X"0B16";
      when "01111000110" => tblu_rom:=X"0B18";
      when "01111000111" => tblu_rom:=X"0B18";
      when "01111001000" => tblu_rom:=X"0B18";
      when "01111001001" => tblu_rom:=X"0B1A";
      when "01111001010" => tblu_rom:=X"0B1A";
      when "01111001011" => tblu_rom:=X"0B1C";
      when "01111001100" => tblu_rom:=X"0B1C";
      when "01111001101" => tblu_rom:=X"0B1E";
      when "01111001110" => tblu_rom:=X"0B1E";
      when "01111001111" => tblu_rom:=X"0B20";
      when "01111010000" => tblu_rom:=X"0B20";
      when "01111010001" => tblu_rom:=X"0B22";
      when "01111010010" => tblu_rom:=X"0B22";
      when "01111010011" => tblu_rom:=X"0B24";
      when "01111010100" => tblu_rom:=X"0B24";
      when "01111010101" => tblu_rom:=X"0B26";
      when "01111010110" => tblu_rom:=X"0B26";
      when "01111010111" => tblu_rom:=X"0B28";
      when "01111011000" => tblu_rom:=X"0B28";
      when "01111011001" => tblu_rom:=X"0B2A";
      when "01111011010" => tblu_rom:=X"0B2A";
      when "01111011011" => tblu_rom:=X"0B2C";
      when "01111011100" => tblu_rom:=X"0B2C";
      when "01111011101" => tblu_rom:=X"0B2E";
      when "01111011110" => tblu_rom:=X"0B2E";
      when "01111011111" => tblu_rom:=X"0B30";
      when "01111100000" => tblu_rom:=X"0B30";
      when "01111100001" => tblu_rom:=X"0B32";
      when "01111100010" => tblu_rom:=X"0B32";
      when "01111100011" => tblu_rom:=X"0B34";
      when "01111100100" => tblu_rom:=X"0B34";
      when "01111100101" => tblu_rom:=X"0B34";
      when "01111100110" => tblu_rom:=X"0B36";
      when "01111100111" => tblu_rom:=X"0B36";
      when "01111101000" => tblu_rom:=X"0B38";
      when "01111101001" => tblu_rom:=X"0B38";
      when "01111101010" => tblu_rom:=X"0B3A";
      when "01111101011" => tblu_rom:=X"0B3A";
      when "01111101100" => tblu_rom:=X"0B3C";
      when "01111101101" => tblu_rom:=X"0B3C";
      when "01111101110" => tblu_rom:=X"0B3E";
      when "01111101111" => tblu_rom:=X"0B3E";
      when "01111110000" => tblu_rom:=X"0B40";
      when "01111110001" => tblu_rom:=X"0B40";
      when "01111110010" => tblu_rom:=X"0B42";
      when "01111110011" => tblu_rom:=X"0B42";
      when "01111110100" => tblu_rom:=X"0B44";
      when "01111110101" => tblu_rom:=X"0B44";
      when "01111110110" => tblu_rom:=X"0B46";
      when "01111110111" => tblu_rom:=X"0B46";
      when "01111111000" => tblu_rom:=X"0B48";
      when "01111111001" => tblu_rom:=X"0B48";
      when "01111111010" => tblu_rom:=X"0B4A";
      when "01111111011" => tblu_rom:=X"0B4A";
      when "01111111100" => tblu_rom:=X"0B4C";
      when "01111111101" => tblu_rom:=X"0B4C";
      when "01111111110" => tblu_rom:=X"0B4E";
      when "01111111111" => tblu_rom:=X"0B4E";
      when "10000000000" => tblu_rom:=X"0B50";
      when "10000000001" => tblu_rom:=X"0B50";
      when "10000000010" => tblu_rom:=X"0B52";
      when "10000000011" => tblu_rom:=X"0B52";
      when "10000000100" => tblu_rom:=X"0B54";
      when "10000000101" => tblu_rom:=X"0B54";
      when "10000000110" => tblu_rom:=X"0B56";
      when "10000000111" => tblu_rom:=X"0B56";
      when "10000001000" => tblu_rom:=X"0B58";
      when "10000001001" => tblu_rom:=X"0B58";
      when "10000001010" => tblu_rom:=X"0B5A";
      when "10000001011" => tblu_rom:=X"0B5A";
      when "10000001100" => tblu_rom:=X"0B5C";
      when "10000001101" => tblu_rom:=X"0B5C";
      when "10000001110" => tblu_rom:=X"0B5E";
      when "10000001111" => tblu_rom:=X"0B5E";
      when "10000010000" => tblu_rom:=X"0B60";
      when "10000010001" => tblu_rom:=X"0B60";
      when "10000010010" => tblu_rom:=X"0B62";
      when "10000010011" => tblu_rom:=X"0B62";
      when "10000010100" => tblu_rom:=X"0B62";
      when "10000010101" => tblu_rom:=X"0B64";
      when "10000010110" => tblu_rom:=X"0B64";
      when "10000010111" => tblu_rom:=X"0B66";
      when "10000011000" => tblu_rom:=X"0B66";
      when "10000011001" => tblu_rom:=X"0B68";
      when "10000011010" => tblu_rom:=X"0B68";
      when "10000011011" => tblu_rom:=X"0B6A";
      when "10000011100" => tblu_rom:=X"0B6A";
      when "10000011101" => tblu_rom:=X"0B6C";
      when "10000011110" => tblu_rom:=X"0B6C";
      when "10000011111" => tblu_rom:=X"0B6E";
      when "10000100000" => tblu_rom:=X"0B6E";
      when "10000100001" => tblu_rom:=X"0B70";
      when "10000100010" => tblu_rom:=X"0B70";
      when "10000100011" => tblu_rom:=X"0B72";
      when "10000100100" => tblu_rom:=X"0B72";
      when "10000100101" => tblu_rom:=X"0B74";
      when "10000100110" => tblu_rom:=X"0B74";
      when "10000100111" => tblu_rom:=X"0B76";
      when "10000101000" => tblu_rom:=X"0B76";
      when "10000101001" => tblu_rom:=X"0B78";
      when "10000101010" => tblu_rom:=X"0B78";
      when "10000101011" => tblu_rom:=X"0B7A";
      when "10000101100" => tblu_rom:=X"0B7A";
      when "10000101101" => tblu_rom:=X"0B7C";
      when "10000101110" => tblu_rom:=X"0B7C";
      when "10000101111" => tblu_rom:=X"0B7E";
      when "10000110000" => tblu_rom:=X"0B7E";
      when "10000110001" => tblu_rom:=X"0B80";
      when "10000110010" => tblu_rom:=X"0B80";
      when "10000110011" => tblu_rom:=X"0B82";
      when "10000110100" => tblu_rom:=X"0B82";
      when "10000110101" => tblu_rom:=X"0B84";
      when "10000110110" => tblu_rom:=X"0B84";
      when "10000110111" => tblu_rom:=X"0B86";
      when "10000111000" => tblu_rom:=X"0B86";
      when "10000111001" => tblu_rom:=X"0B88";
      when "10000111010" => tblu_rom:=X"0B88";
      when "10000111011" => tblu_rom:=X"0B8A";
      when "10000111100" => tblu_rom:=X"0B8A";
      when "10000111101" => tblu_rom:=X"0B8C";
      when "10000111110" => tblu_rom:=X"0B8C";
      when "10000111111" => tblu_rom:=X"0B8E";
      when "10001000000" => tblu_rom:=X"0B8E";
      when "10001000001" => tblu_rom:=X"0B90";
      when "10001000010" => tblu_rom:=X"0B90";
      when "10001000011" => tblu_rom:=X"0B92";
      when "10001000100" => tblu_rom:=X"0B92";
      when "10001000101" => tblu_rom:=X"0B94";
      when "10001000110" => tblu_rom:=X"0B94";
      when "10001000111" => tblu_rom:=X"0B96";
      when "10001001000" => tblu_rom:=X"0B96";
      when "10001001001" => tblu_rom:=X"0B98";
      when "10001001010" => tblu_rom:=X"0B98";
      when "10001001011" => tblu_rom:=X"0B9A";
      when "10001001100" => tblu_rom:=X"0B9A";
      when "10001001101" => tblu_rom:=X"0B9C";
      when "10001001110" => tblu_rom:=X"0B9C";
      when "10001001111" => tblu_rom:=X"0B9E";
      when "10001010000" => tblu_rom:=X"0B9E";
      when "10001010001" => tblu_rom:=X"0BA0";
      when "10001010010" => tblu_rom:=X"0BA0";
      when "10001010011" => tblu_rom:=X"0BA2";
      when "10001010100" => tblu_rom:=X"0BA2";
      when "10001010101" => tblu_rom:=X"0BA4";
      when "10001010110" => tblu_rom:=X"0BA4";
      when "10001010111" => tblu_rom:=X"0BA6";
      when "10001011000" => tblu_rom:=X"0BA6";
      when "10001011001" => tblu_rom:=X"0BA8";
      when "10001011010" => tblu_rom:=X"0BA8";
      when "10001011011" => tblu_rom:=X"0BAA";
      when "10001011100" => tblu_rom:=X"0BAA";
      when "10001011101" => tblu_rom:=X"0BAC";
      when "10001011110" => tblu_rom:=X"0BAC";
      when "10001011111" => tblu_rom:=X"0BAE";
      when "10001100000" => tblu_rom:=X"0BAE";
      when "10001100001" => tblu_rom:=X"0BB0";
      when "10001100010" => tblu_rom:=X"0BB0";
      when "10001100011" => tblu_rom:=X"0BB2";
      when "10001100100" => tblu_rom:=X"0BB4";
      when "10001100101" => tblu_rom:=X"0BB4";
      when "10001100110" => tblu_rom:=X"0BB6";
      when "10001100111" => tblu_rom:=X"0BB6";
      when "10001101000" => tblu_rom:=X"0BB8";
      when "10001101001" => tblu_rom:=X"0BB8";
      when "10001101010" => tblu_rom:=X"0BBA";
      when "10001101011" => tblu_rom:=X"0BBA";
      when "10001101100" => tblu_rom:=X"0BBC";
      when "10001101101" => tblu_rom:=X"0BBC";
      when "10001101110" => tblu_rom:=X"0BBE";
      when "10001101111" => tblu_rom:=X"0BBE";
      when "10001110000" => tblu_rom:=X"0BC0";
      when "10001110001" => tblu_rom:=X"0BC0";
      when "10001110010" => tblu_rom:=X"0BC2";
      when "10001110011" => tblu_rom:=X"0BC2";
      when "10001110100" => tblu_rom:=X"0BC4";
      when "10001110101" => tblu_rom:=X"0BC4";
      when "10001110110" => tblu_rom:=X"0BC6";
      when "10001110111" => tblu_rom:=X"0BC6";
      when "10001111000" => tblu_rom:=X"0BC8";
      when "10001111001" => tblu_rom:=X"0BC8";
      when "10001111010" => tblu_rom:=X"0BCA";
      when "10001111011" => tblu_rom:=X"0BCA";
      when "10001111100" => tblu_rom:=X"0BCC";
      when "10001111101" => tblu_rom:=X"0BCC";
      when "10001111110" => tblu_rom:=X"0BCE";
      when "10001111111" => tblu_rom:=X"0BCE";
      when "10010000000" => tblu_rom:=X"0BD0";
      when "10010000001" => tblu_rom:=X"0BD0";
      when "10010000010" => tblu_rom:=X"0BD2";
      when "10010000011" => tblu_rom:=X"0BD2";
      when "10010000100" => tblu_rom:=X"0BD4";
      when "10010000101" => tblu_rom:=X"0BD4";
      when "10010000110" => tblu_rom:=X"0BD6";
      when "10010000111" => tblu_rom:=X"0BD6";
      when "10010001000" => tblu_rom:=X"0BD8";
      when "10010001001" => tblu_rom:=X"0BD8";
      when "10010001010" => tblu_rom:=X"0BDA";
      when "10010001011" => tblu_rom:=X"0BDA";
      when "10010001100" => tblu_rom:=X"0BDC";
      when "10010001101" => tblu_rom:=X"0BDC";
      when "10010001110" => tblu_rom:=X"0BDE";
      when "10010001111" => tblu_rom:=X"0BDE";
      when "10010010000" => tblu_rom:=X"0BE0";
      when "10010010001" => tblu_rom:=X"0BE0";
      when "10010010010" => tblu_rom:=X"0BE2";
      when "10010010011" => tblu_rom:=X"0BE4";
      when "10010010100" => tblu_rom:=X"0BE4";
      when "10010010101" => tblu_rom:=X"0BE6";
      when "10010010110" => tblu_rom:=X"0BE6";
      when "10010010111" => tblu_rom:=X"0BE8";
      when "10010011000" => tblu_rom:=X"0BE8";
      when "10010011001" => tblu_rom:=X"0BEA";
      when "10010011010" => tblu_rom:=X"0BEA";
      when "10010011011" => tblu_rom:=X"0BEC";
      when "10010011100" => tblu_rom:=X"0BEC";
      when "10010011101" => tblu_rom:=X"0BEE";
      when "10010011110" => tblu_rom:=X"0BEE";
      when "10010011111" => tblu_rom:=X"0BF0";
      when "10010100000" => tblu_rom:=X"0BF0";
      when "10010100001" => tblu_rom:=X"0BF2";
      when "10010100010" => tblu_rom:=X"0BF2";
      when "10010100011" => tblu_rom:=X"0BF4";
      when "10010100100" => tblu_rom:=X"0BF4";
      when "10010100101" => tblu_rom:=X"0BF6";
      when "10010100110" => tblu_rom:=X"0BF6";
      when "10010100111" => tblu_rom:=X"0BF8";
      when "10010101000" => tblu_rom:=X"0BF8";
      when "10010101001" => tblu_rom:=X"0BFA";
      when "10010101010" => tblu_rom:=X"0BFA";
      when "10010101011" => tblu_rom:=X"0BFC";
      when "10010101100" => tblu_rom:=X"0BFC";
      when "10010101101" => tblu_rom:=X"0BFE";
      when "10010101110" => tblu_rom:=X"0BFE";
      when "10010101111" => tblu_rom:=X"0C00";
      when "10010110000" => tblu_rom:=X"0C02";
      when "10010110001" => tblu_rom:=X"0C02";
      when "10010110010" => tblu_rom:=X"0C04";
      when "10010110011" => tblu_rom:=X"0C04";
      when "10010110100" => tblu_rom:=X"0C06";
      when "10010110101" => tblu_rom:=X"0C06";
      when "10010110110" => tblu_rom:=X"0C08";
      when "10010110111" => tblu_rom:=X"0C08";
      when "10010111000" => tblu_rom:=X"0C0A";
      when "10010111001" => tblu_rom:=X"0C0A";
      when "10010111010" => tblu_rom:=X"0C0C";
      when "10010111011" => tblu_rom:=X"0C0C";
      when "10010111100" => tblu_rom:=X"0C0E";
      when "10010111101" => tblu_rom:=X"0C0E";
      when "10010111110" => tblu_rom:=X"0C10";
      when "10010111111" => tblu_rom:=X"0C10";
      when "10011000000" => tblu_rom:=X"0C12";
      when "10011000001" => tblu_rom:=X"0C12";
      when "10011000010" => tblu_rom:=X"0C14";
      when "10011000011" => tblu_rom:=X"0C14";
      when "10011000100" => tblu_rom:=X"0C16";
      when "10011000101" => tblu_rom:=X"0C18";
      when "10011000110" => tblu_rom:=X"0C18";
      when "10011000111" => tblu_rom:=X"0C1A";
      when "10011001000" => tblu_rom:=X"0C1A";
      when "10011001001" => tblu_rom:=X"0C1C";
      when "10011001010" => tblu_rom:=X"0C1C";
      when "10011001011" => tblu_rom:=X"0C1E";
      when "10011001100" => tblu_rom:=X"0C1E";
      when "10011001101" => tblu_rom:=X"0C20";
      when "10011001110" => tblu_rom:=X"0C20";
      when "10011001111" => tblu_rom:=X"0C22";
      when "10011010000" => tblu_rom:=X"0C22";
      when "10011010001" => tblu_rom:=X"0C24";
      when "10011010010" => tblu_rom:=X"0C24";
      when "10011010011" => tblu_rom:=X"0C26";
      when "10011010100" => tblu_rom:=X"0C26";
      when "10011010101" => tblu_rom:=X"0C28";
      when "10011010110" => tblu_rom:=X"0C28";
      when "10011010111" => tblu_rom:=X"0C2A";
      when "10011011000" => tblu_rom:=X"0C2A";
      when "10011011001" => tblu_rom:=X"0C2C";
      when "10011011010" => tblu_rom:=X"0C2E";
      when "10011011011" => tblu_rom:=X"0C2E";
      when "10011011100" => tblu_rom:=X"0C30";
      when "10011011101" => tblu_rom:=X"0C30";
      when "10011011110" => tblu_rom:=X"0C32";
      when "10011011111" => tblu_rom:=X"0C32";
      when "10011100000" => tblu_rom:=X"0C34";
      when "10011100001" => tblu_rom:=X"0C34";
      when "10011100010" => tblu_rom:=X"0C36";
      when "10011100011" => tblu_rom:=X"0C36";
      when "10011100100" => tblu_rom:=X"0C38";
      when "10011100101" => tblu_rom:=X"0C38";
      when "10011100110" => tblu_rom:=X"0C3A";
      when "10011100111" => tblu_rom:=X"0C3A";
      when "10011101000" => tblu_rom:=X"0C3C";
      when "10011101001" => tblu_rom:=X"0C3C";
      when "10011101010" => tblu_rom:=X"0C3E";
      when "10011101011" => tblu_rom:=X"0C40";
      when "10011101100" => tblu_rom:=X"0C40";
      when "10011101101" => tblu_rom:=X"0C42";
      when "10011101110" => tblu_rom:=X"0C42";
      when "10011101111" => tblu_rom:=X"0C44";
      when "10011110000" => tblu_rom:=X"0C44";
      when "10011110001" => tblu_rom:=X"0C46";
      when "10011110010" => tblu_rom:=X"0C46";
      when "10011110011" => tblu_rom:=X"0C48";
      when "10011110100" => tblu_rom:=X"0C48";
      when "10011110101" => tblu_rom:=X"0C4A";
      when "10011110110" => tblu_rom:=X"0C4A";
      when "10011110111" => tblu_rom:=X"0C4C";
      when "10011111000" => tblu_rom:=X"0C4C";
      when "10011111001" => tblu_rom:=X"0C4E";
      when "10011111010" => tblu_rom:=X"0C50";
      when "10011111011" => tblu_rom:=X"0C50";
      when "10011111100" => tblu_rom:=X"0C52";
      when "10011111101" => tblu_rom:=X"0C52";
      when "10011111110" => tblu_rom:=X"0C54";
      when "10011111111" => tblu_rom:=X"0C54";
      when "10100000000" => tblu_rom:=X"0C56";
      when "10100000001" => tblu_rom:=X"0C56";
      when "10100000010" => tblu_rom:=X"0C58";
      when "10100000011" => tblu_rom:=X"0C58";
      when "10100000100" => tblu_rom:=X"0C5A";
      when "10100000101" => tblu_rom:=X"0C5A";
      when "10100000110" => tblu_rom:=X"0C5C";
      when "10100000111" => tblu_rom:=X"0C5C";
      when "10100001000" => tblu_rom:=X"0C5E";
      when "10100001001" => tblu_rom:=X"0C60";
      when "10100001010" => tblu_rom:=X"0C60";
      when "10100001011" => tblu_rom:=X"0C62";
      when "10100001100" => tblu_rom:=X"0C62";
      when "10100001101" => tblu_rom:=X"0C64";
      when "10100001110" => tblu_rom:=X"0C64";
      when "10100001111" => tblu_rom:=X"0C66";
      when "10100010000" => tblu_rom:=X"0C66";
      when "10100010001" => tblu_rom:=X"0C68";
      when "10100010010" => tblu_rom:=X"0C68";
      when "10100010011" => tblu_rom:=X"0C6A";
      when "10100010100" => tblu_rom:=X"0C6A";
      when "10100010101" => tblu_rom:=X"0C6C";
      when "10100010110" => tblu_rom:=X"0C6E";
      when "10100010111" => tblu_rom:=X"0C6E";
      when "10100011000" => tblu_rom:=X"0C70";
      when "10100011001" => tblu_rom:=X"0C70";
      when "10100011010" => tblu_rom:=X"0C72";
      when "10100011011" => tblu_rom:=X"0C72";
      when "10100011100" => tblu_rom:=X"0C74";
      when "10100011101" => tblu_rom:=X"0C74";
      when "10100011110" => tblu_rom:=X"0C76";
      when "10100011111" => tblu_rom:=X"0C76";
      when "10100100000" => tblu_rom:=X"0C78";
      when "10100100001" => tblu_rom:=X"0C78";
      when "10100100010" => tblu_rom:=X"0C7A";
      when "10100100011" => tblu_rom:=X"0C7C";
      when "10100100100" => tblu_rom:=X"0C7C";
      when "10100100101" => tblu_rom:=X"0C7E";
      when "10100100110" => tblu_rom:=X"0C7E";
      when "10100100111" => tblu_rom:=X"0C80";
      when "10100101000" => tblu_rom:=X"0C80";
      when "10100101001" => tblu_rom:=X"0C82";
      when "10100101010" => tblu_rom:=X"0C82";
      when "10100101011" => tblu_rom:=X"0C84";
      when "10100101100" => tblu_rom:=X"0C84";
      when "10100101101" => tblu_rom:=X"0C86";
      when "10100101110" => tblu_rom:=X"0C88";
      when "10100101111" => tblu_rom:=X"0C88";
      when "10100110000" => tblu_rom:=X"0C8A";
      when "10100110001" => tblu_rom:=X"0C8A";
      when "10100110010" => tblu_rom:=X"0C8C";
      when "10100110011" => tblu_rom:=X"0C8C";
      when "10100110100" => tblu_rom:=X"0C8E";
      when "10100110101" => tblu_rom:=X"0C8E";
      when "10100110110" => tblu_rom:=X"0C90";
      when "10100110111" => tblu_rom:=X"0C90";
      when "10100111000" => tblu_rom:=X"0C92";
      when "10100111001" => tblu_rom:=X"0C92";
      when "10100111010" => tblu_rom:=X"0C94";
      when "10100111011" => tblu_rom:=X"0C96";
      when "10100111100" => tblu_rom:=X"0C96";
      when "10100111101" => tblu_rom:=X"0C98";
      when "10100111110" => tblu_rom:=X"0C98";
      when "10100111111" => tblu_rom:=X"0C9A";
      when "10101000000" => tblu_rom:=X"0C9A";
      when "10101000001" => tblu_rom:=X"0C9C";
      when "10101000010" => tblu_rom:=X"0C9C";
      when "10101000011" => tblu_rom:=X"0C9E";
      when "10101000100" => tblu_rom:=X"0C9E";
      when "10101000101" => tblu_rom:=X"0CA0";
      when "10101000110" => tblu_rom:=X"0CA2";
      when "10101000111" => tblu_rom:=X"0CA2";
      when "10101001000" => tblu_rom:=X"0CA4";
      when "10101001001" => tblu_rom:=X"0CA4";
      when "10101001010" => tblu_rom:=X"0CA6";
      when "10101001011" => tblu_rom:=X"0CA6";
      when "10101001100" => tblu_rom:=X"0CA8";
      when "10101001101" => tblu_rom:=X"0CA8";
      when "10101001110" => tblu_rom:=X"0CAA";
      when "10101001111" => tblu_rom:=X"0CAC";
      when "10101010000" => tblu_rom:=X"0CAC";
      when "10101010001" => tblu_rom:=X"0CAE";
      when "10101010010" => tblu_rom:=X"0CAE";
      when "10101010011" => tblu_rom:=X"0CB0";
      when "10101010100" => tblu_rom:=X"0CB0";
      when "10101010101" => tblu_rom:=X"0CB2";
      when "10101010110" => tblu_rom:=X"0CB2";
      when "10101010111" => tblu_rom:=X"0CB4";
      when "10101011000" => tblu_rom:=X"0CB4";
      when "10101011001" => tblu_rom:=X"0CB6";
      when "10101011010" => tblu_rom:=X"0CB8";
      when "10101011011" => tblu_rom:=X"0CB8";
      when "10101011100" => tblu_rom:=X"0CBA";
      when "10101011101" => tblu_rom:=X"0CBA";
      when "10101011110" => tblu_rom:=X"0CBC";
      when "10101011111" => tblu_rom:=X"0CBC";
      when "10101100000" => tblu_rom:=X"0CBE";
      when "10101100001" => tblu_rom:=X"0CBE";
      when "10101100010" => tblu_rom:=X"0CC0";
      when "10101100011" => tblu_rom:=X"0CC2";
      when "10101100100" => tblu_rom:=X"0CC2";
      when "10101100101" => tblu_rom:=X"0CC4";
      when "10101100110" => tblu_rom:=X"0CC4";
      when "10101100111" => tblu_rom:=X"0CC6";
      when "10101101000" => tblu_rom:=X"0CC6";
      when "10101101001" => tblu_rom:=X"0CC8";
      when "10101101010" => tblu_rom:=X"0CC8";
      when "10101101011" => tblu_rom:=X"0CCA";
      when "10101101100" => tblu_rom:=X"0CCC";
      when "10101101101" => tblu_rom:=X"0CCC";
      when "10101101110" => tblu_rom:=X"0CCE";
      when "10101101111" => tblu_rom:=X"0CCE";
      when "10101110000" => tblu_rom:=X"0CD0";
      when "10101110001" => tblu_rom:=X"0CD0";
      when "10101110010" => tblu_rom:=X"0CD2";
      when "10101110011" => tblu_rom:=X"0CD2";
      when "10101110100" => tblu_rom:=X"0CD4";
      when "10101110101" => tblu_rom:=X"0CD6";
      when "10101110110" => tblu_rom:=X"0CD6";
      when "10101110111" => tblu_rom:=X"0CD8";
      when "10101111000" => tblu_rom:=X"0CD8";
      when "10101111001" => tblu_rom:=X"0CDA";
      when "10101111010" => tblu_rom:=X"0CDA";
      when "10101111011" => tblu_rom:=X"0CDC";
      when "10101111100" => tblu_rom:=X"0CDC";
      when "10101111101" => tblu_rom:=X"0CDE";
      when "10101111110" => tblu_rom:=X"0CE0";
      when "10101111111" => tblu_rom:=X"0CE0";
      when "10110000000" => tblu_rom:=X"0CE2";
      when "10110000001" => tblu_rom:=X"0CE2";
      when "10110000010" => tblu_rom:=X"0CE4";
      when "10110000011" => tblu_rom:=X"0CE4";
      when "10110000100" => tblu_rom:=X"0CE6";
      when "10110000101" => tblu_rom:=X"0CE6";
      when "10110000110" => tblu_rom:=X"0CE8";
      when "10110000111" => tblu_rom:=X"0CEA";
      when "10110001000" => tblu_rom:=X"0CEA";
      when "10110001001" => tblu_rom:=X"0CEC";
      when "10110001010" => tblu_rom:=X"0CEC";
      when "10110001011" => tblu_rom:=X"0CEE";
      when "10110001100" => tblu_rom:=X"0CEE";
      when "10110001101" => tblu_rom:=X"0CF0";
      when "10110001110" => tblu_rom:=X"0CF0";
      when "10110001111" => tblu_rom:=X"0CF2";
      when "10110010000" => tblu_rom:=X"0CF4";
      when "10110010001" => tblu_rom:=X"0CF4";
      when "10110010010" => tblu_rom:=X"0CF6";
      when "10110010011" => tblu_rom:=X"0CF6";
      when "10110010100" => tblu_rom:=X"0CF8";
      when "10110010101" => tblu_rom:=X"0CF8";
      when "10110010110" => tblu_rom:=X"0CFA";
      when "10110010111" => tblu_rom:=X"0CFC";
      when "10110011000" => tblu_rom:=X"0CFC";
      when "10110011001" => tblu_rom:=X"0CFE";
      when "10110011010" => tblu_rom:=X"0CFE";
      when "10110011011" => tblu_rom:=X"0D00";
      when "10110011100" => tblu_rom:=X"0D00";
      when "10110011101" => tblu_rom:=X"0D02";
      when "10110011110" => tblu_rom:=X"0D02";
      when "10110011111" => tblu_rom:=X"0D04";
      when "10110100000" => tblu_rom:=X"0D06";
      when "10110100001" => tblu_rom:=X"0D06";
      when "10110100010" => tblu_rom:=X"0D08";
      when "10110100011" => tblu_rom:=X"0D08";
      when "10110100100" => tblu_rom:=X"0D0A";
      when "10110100101" => tblu_rom:=X"0D0A";
      when "10110100110" => tblu_rom:=X"0D0C";
      when "10110100111" => tblu_rom:=X"0D0E";
      when "10110101000" => tblu_rom:=X"0D0E";
      when "10110101001" => tblu_rom:=X"0D10";
      when "10110101010" => tblu_rom:=X"0D10";
      when "10110101011" => tblu_rom:=X"0D12";
      when "10110101100" => tblu_rom:=X"0D12";
      when "10110101101" => tblu_rom:=X"0D14";
      when "10110101110" => tblu_rom:=X"0D16";
      when "10110101111" => tblu_rom:=X"0D16";
      when "10110110000" => tblu_rom:=X"0D18";
      when "10110110001" => tblu_rom:=X"0D18";
      when "10110110010" => tblu_rom:=X"0D1A";
      when "10110110011" => tblu_rom:=X"0D1A";
      when "10110110100" => tblu_rom:=X"0D1C";
      when "10110110101" => tblu_rom:=X"0D1C";
      when "10110110110" => tblu_rom:=X"0D1E";
      when "10110110111" => tblu_rom:=X"0D20";
      when "10110111000" => tblu_rom:=X"0D20";
      when "10110111001" => tblu_rom:=X"0D22";
      when "10110111010" => tblu_rom:=X"0D22";
      when "10110111011" => tblu_rom:=X"0D24";
      when "10110111100" => tblu_rom:=X"0D24";
      when "10110111101" => tblu_rom:=X"0D26";
      when "10110111110" => tblu_rom:=X"0D28";
      when "10110111111" => tblu_rom:=X"0D28";
      when "10111000000" => tblu_rom:=X"0D2A";
      when "10111000001" => tblu_rom:=X"0D2A";
      when "10111000010" => tblu_rom:=X"0D2C";
      when "10111000011" => tblu_rom:=X"0D2C";
      when "10111000100" => tblu_rom:=X"0D2E";
      when "10111000101" => tblu_rom:=X"0D30";
      when "10111000110" => tblu_rom:=X"0D30";
      when "10111000111" => tblu_rom:=X"0D32";
      when "10111001000" => tblu_rom:=X"0D32";
      when "10111001001" => tblu_rom:=X"0D34";
      when "10111001010" => tblu_rom:=X"0D34";
      when "10111001011" => tblu_rom:=X"0D36";
      when "10111001100" => tblu_rom:=X"0D38";
      when "10111001101" => tblu_rom:=X"0D38";
      when "10111001110" => tblu_rom:=X"0D3A";
      when "10111001111" => tblu_rom:=X"0D3A";
      when "10111010000" => tblu_rom:=X"0D3C";
      when "10111010001" => tblu_rom:=X"0D3C";
      when "10111010010" => tblu_rom:=X"0D3E";
      when "10111010011" => tblu_rom:=X"0D40";
      when "10111010100" => tblu_rom:=X"0D40";
      when "10111010101" => tblu_rom:=X"0D42";
      when "10111010110" => tblu_rom:=X"0D42";
      when "10111010111" => tblu_rom:=X"0D44";
      when "10111011000" => tblu_rom:=X"0D44";
      when "10111011001" => tblu_rom:=X"0D46";
      when "10111011010" => tblu_rom:=X"0D48";
      when "10111011011" => tblu_rom:=X"0D48";
      when "10111011100" => tblu_rom:=X"0D4A";
      when "10111011101" => tblu_rom:=X"0D4A";
      when "10111011110" => tblu_rom:=X"0D4C";
      when "10111011111" => tblu_rom:=X"0D4E";
      when "10111100000" => tblu_rom:=X"0D4E";
      when "10111100001" => tblu_rom:=X"0D50";
      when "10111100010" => tblu_rom:=X"0D50";
      when "10111100011" => tblu_rom:=X"0D52";
      when "10111100100" => tblu_rom:=X"0D52";
      when "10111100101" => tblu_rom:=X"0D54";
      when "10111100110" => tblu_rom:=X"0D56";
      when "10111100111" => tblu_rom:=X"0D56";
      when "10111101000" => tblu_rom:=X"0D58";
      when "10111101001" => tblu_rom:=X"0D58";
      when "10111101010" => tblu_rom:=X"0D5A";
      when "10111101011" => tblu_rom:=X"0D5A";
      when "10111101100" => tblu_rom:=X"0D5C";
      when "10111101101" => tblu_rom:=X"0D5E";
      when "10111101110" => tblu_rom:=X"0D5E";
      when "10111101111" => tblu_rom:=X"0D60";
      when "10111110000" => tblu_rom:=X"0D60";
      when "10111110001" => tblu_rom:=X"0D62";
      when "10111110010" => tblu_rom:=X"0D64";
      when "10111110011" => tblu_rom:=X"0D64";
      when "10111110100" => tblu_rom:=X"0D66";
      when "10111110101" => tblu_rom:=X"0D66";
      when "10111110110" => tblu_rom:=X"0D68";
      when "10111110111" => tblu_rom:=X"0D68";
      when "10111111000" => tblu_rom:=X"0D6A";
      when "10111111001" => tblu_rom:=X"0D6C";
      when "10111111010" => tblu_rom:=X"0D6C";
      when "10111111011" => tblu_rom:=X"0D6E";
      when "10111111100" => tblu_rom:=X"0D6E";
      when "10111111101" => tblu_rom:=X"0D70";
      when "10111111110" => tblu_rom:=X"0D70";
      when "10111111111" => tblu_rom:=X"0D72";
      when "11000000000" => tblu_rom:=X"0D74";
      when "11000000001" => tblu_rom:=X"0D74";
      when "11000000010" => tblu_rom:=X"0D76";
      when "11000000011" => tblu_rom:=X"0D76";
      when "11000000100" => tblu_rom:=X"0D78";
      when "11000000101" => tblu_rom:=X"0D7A";
      when "11000000110" => tblu_rom:=X"0D7A";
      when "11000000111" => tblu_rom:=X"0D7C";
      when "11000001000" => tblu_rom:=X"0D7C";
      when "11000001001" => tblu_rom:=X"0D7E";
      when "11000001010" => tblu_rom:=X"0D7E";
      when "11000001011" => tblu_rom:=X"0D80";
      when "11000001100" => tblu_rom:=X"0D82";
      when "11000001101" => tblu_rom:=X"0D82";
      when "11000001110" => tblu_rom:=X"0D84";
      when "11000001111" => tblu_rom:=X"0D84";
      when "11000010000" => tblu_rom:=X"0D86";
      when "11000010001" => tblu_rom:=X"0D88";
      when "11000010010" => tblu_rom:=X"0D88";
      when "11000010011" => tblu_rom:=X"0D8A";
      when "11000010100" => tblu_rom:=X"0D8A";
      when "11000010101" => tblu_rom:=X"0D8C";
      when "11000010110" => tblu_rom:=X"0D8E";
      when "11000010111" => tblu_rom:=X"0D8E";
      when "11000011000" => tblu_rom:=X"0D90";
      when "11000011001" => tblu_rom:=X"0D90";
      when "11000011010" => tblu_rom:=X"0D92";
      when "11000011011" => tblu_rom:=X"0D92";
      when "11000011100" => tblu_rom:=X"0D94";
      when "11000011101" => tblu_rom:=X"0D96";
      when "11000011110" => tblu_rom:=X"0D96";
      when "11000011111" => tblu_rom:=X"0D98";
      when "11000100000" => tblu_rom:=X"0D98";
      when "11000100001" => tblu_rom:=X"0D9A";
      when "11000100010" => tblu_rom:=X"0D9C";
      when "11000100011" => tblu_rom:=X"0D9C";
      when "11000100100" => tblu_rom:=X"0D9E";
      when "11000100101" => tblu_rom:=X"0D9E";
      when "11000100110" => tblu_rom:=X"0DA0";
      when "11000100111" => tblu_rom:=X"0DA2";
      when "11000101000" => tblu_rom:=X"0DA2";
      when "11000101001" => tblu_rom:=X"0DA4";
      when "11000101010" => tblu_rom:=X"0DA4";
      when "11000101011" => tblu_rom:=X"0DA6";
      when "11000101100" => tblu_rom:=X"0DA6";
      when "11000101101" => tblu_rom:=X"0DA8";
      when "11000101110" => tblu_rom:=X"0DAA";
      when "11000101111" => tblu_rom:=X"0DAA";
      when "11000110000" => tblu_rom:=X"0DAC";
      when "11000110001" => tblu_rom:=X"0DAC";
      when "11000110010" => tblu_rom:=X"0DAE";
      when "11000110011" => tblu_rom:=X"0DB0";
      when "11000110100" => tblu_rom:=X"0DB0";
      when "11000110101" => tblu_rom:=X"0DB2";
      when "11000110110" => tblu_rom:=X"0DB2";
      when "11000110111" => tblu_rom:=X"0DB4";
      when "11000111000" => tblu_rom:=X"0DB6";
      when "11000111001" => tblu_rom:=X"0DB6";
      when "11000111010" => tblu_rom:=X"0DB8";
      when "11000111011" => tblu_rom:=X"0DB8";
      when "11000111100" => tblu_rom:=X"0DBA";
      when "11000111101" => tblu_rom:=X"0DBC";
      when "11000111110" => tblu_rom:=X"0DBC";
      when "11000111111" => tblu_rom:=X"0DBE";
      when "11001000000" => tblu_rom:=X"0DBE";
      when "11001000001" => tblu_rom:=X"0DC0";
      when "11001000010" => tblu_rom:=X"0DC2";
      when "11001000011" => tblu_rom:=X"0DC2";
      when "11001000100" => tblu_rom:=X"0DC4";
      when "11001000101" => tblu_rom:=X"0DC4";
      when "11001000110" => tblu_rom:=X"0DC6";
      when "11001000111" => tblu_rom:=X"0DC8";
      when "11001001000" => tblu_rom:=X"0DC8";
      when "11001001001" => tblu_rom:=X"0DCA";
      when "11001001010" => tblu_rom:=X"0DCA";
      when "11001001011" => tblu_rom:=X"0DCC";
      when "11001001100" => tblu_rom:=X"0DCE";
      when "11001001101" => tblu_rom:=X"0DCE";
      when "11001001110" => tblu_rom:=X"0DD0";
      when "11001001111" => tblu_rom:=X"0DD0";
      when "11001010000" => tblu_rom:=X"0DD2";
      when "11001010001" => tblu_rom:=X"0DD4";
      when "11001010010" => tblu_rom:=X"0DD4";
      when "11001010011" => tblu_rom:=X"0DD6";
      when "11001010100" => tblu_rom:=X"0DD6";
      when "11001010101" => tblu_rom:=X"0DD8";
      when "11001010110" => tblu_rom:=X"0DDA";
      when "11001010111" => tblu_rom:=X"0DDA";
      when "11001011000" => tblu_rom:=X"0DDC";
      when "11001011001" => tblu_rom:=X"0DDC";
      when "11001011010" => tblu_rom:=X"0DDE";
      when "11001011011" => tblu_rom:=X"0DE0";
      when "11001011100" => tblu_rom:=X"0DE0";
      when "11001011101" => tblu_rom:=X"0DE2";
      when "11001011110" => tblu_rom:=X"0DE2";
      when "11001011111" => tblu_rom:=X"0DE4";
      when "11001100000" => tblu_rom:=X"0DE6";
      when "11001100001" => tblu_rom:=X"0DE6";
      when "11001100010" => tblu_rom:=X"0DE8";
      when "11001100011" => tblu_rom:=X"0DE8";
      when "11001100100" => tblu_rom:=X"0DEA";
      when "11001100101" => tblu_rom:=X"0DEC";
      when "11001100110" => tblu_rom:=X"0DEC";
      when "11001100111" => tblu_rom:=X"0DEE";
      when "11001101000" => tblu_rom:=X"0DEE";
      when "11001101001" => tblu_rom:=X"0DF0";
      when "11001101010" => tblu_rom:=X"0DF2";
      when "11001101011" => tblu_rom:=X"0DF2";
      when "11001101100" => tblu_rom:=X"0DF4";
      when "11001101101" => tblu_rom:=X"0DF4";
      when "11001101110" => tblu_rom:=X"0DF6";
      when "11001101111" => tblu_rom:=X"0DF8";
      when "11001110000" => tblu_rom:=X"0DF8";
      when "11001110001" => tblu_rom:=X"0DFA";
      when "11001110010" => tblu_rom:=X"0DFA";
      when "11001110011" => tblu_rom:=X"0DFC";
      when "11001110100" => tblu_rom:=X"0DFE";
      when "11001110101" => tblu_rom:=X"0DFE";
      when "11001110110" => tblu_rom:=X"0E00";
      when "11001110111" => tblu_rom:=X"0E00";
      when "11001111000" => tblu_rom:=X"0E02";
      when "11001111001" => tblu_rom:=X"0E04";
      when "11001111010" => tblu_rom:=X"0E04";
      when "11001111011" => tblu_rom:=X"0E06";
      when "11001111100" => tblu_rom:=X"0E06";
      when "11001111101" => tblu_rom:=X"0E08";
      when "11001111110" => tblu_rom:=X"0E0A";
      when "11001111111" => tblu_rom:=X"0E0A";
      when "11010000000" => tblu_rom:=X"0E0C";
      when "11010000001" => tblu_rom:=X"0E0E";
      when "11010000010" => tblu_rom:=X"0E0E";
      when "11010000011" => tblu_rom:=X"0E10";
      when "11010000100" => tblu_rom:=X"0E10";
      when "11010000101" => tblu_rom:=X"0E12";
      when "11010000110" => tblu_rom:=X"0E14";
      when "11010000111" => tblu_rom:=X"0E14";
      when "11010001000" => tblu_rom:=X"0E16";
      when "11010001001" => tblu_rom:=X"0E16";
      when "11010001010" => tblu_rom:=X"0E18";
      when "11010001011" => tblu_rom:=X"0E1A";
      when "11010001100" => tblu_rom:=X"0E1A";
      when "11010001101" => tblu_rom:=X"0E1C";
      when "11010001110" => tblu_rom:=X"0E1C";
      when "11010001111" => tblu_rom:=X"0E1E";
      when "11010010000" => tblu_rom:=X"0E20";
      when "11010010001" => tblu_rom:=X"0E20";
      when "11010010010" => tblu_rom:=X"0E22";
      when "11010010011" => tblu_rom:=X"0E24";
      when "11010010100" => tblu_rom:=X"0E24";
      when "11010010101" => tblu_rom:=X"0E26";
      when "11010010110" => tblu_rom:=X"0E26";
      when "11010010111" => tblu_rom:=X"0E28";
      when "11010011000" => tblu_rom:=X"0E2A";
      when "11010011001" => tblu_rom:=X"0E2A";
      when "11010011010" => tblu_rom:=X"0E2C";
      when "11010011011" => tblu_rom:=X"0E2C";
      when "11010011100" => tblu_rom:=X"0E2E";
      when "11010011101" => tblu_rom:=X"0E30";
      when "11010011110" => tblu_rom:=X"0E30";
      when "11010011111" => tblu_rom:=X"0E32";
      when "11010100000" => tblu_rom:=X"0E32";
      when "11010100001" => tblu_rom:=X"0E34";
      when "11010100010" => tblu_rom:=X"0E36";
      when "11010100011" => tblu_rom:=X"0E36";
      when "11010100100" => tblu_rom:=X"0E38";
      when "11010100101" => tblu_rom:=X"0E3A";
      when "11010100110" => tblu_rom:=X"0E3A";
      when "11010100111" => tblu_rom:=X"0E3C";
      when "11010101000" => tblu_rom:=X"0E3C";
      when "11010101001" => tblu_rom:=X"0E3E";
      when "11010101010" => tblu_rom:=X"0E40";
      when "11010101011" => tblu_rom:=X"0E40";
      when "11010101100" => tblu_rom:=X"0E42";
      when "11010101101" => tblu_rom:=X"0E44";
      when "11010101110" => tblu_rom:=X"0E44";
      when "11010101111" => tblu_rom:=X"0E46";
      when "11010110000" => tblu_rom:=X"0E46";
      when "11010110001" => tblu_rom:=X"0E48";
      when "11010110010" => tblu_rom:=X"0E4A";
      when "11010110011" => tblu_rom:=X"0E4A";
      when "11010110100" => tblu_rom:=X"0E4C";
      when "11010110101" => tblu_rom:=X"0E4C";
      when "11010110110" => tblu_rom:=X"0E4E";
      when "11010110111" => tblu_rom:=X"0E50";
      when "11010111000" => tblu_rom:=X"0E50";
      when "11010111001" => tblu_rom:=X"0E52";
      when "11010111010" => tblu_rom:=X"0E54";
      when "11010111011" => tblu_rom:=X"0E54";
      when "11010111100" => tblu_rom:=X"0E56";
      when "11010111101" => tblu_rom:=X"0E56";
      when "11010111110" => tblu_rom:=X"0E58";
      when "11010111111" => tblu_rom:=X"0E5A";
      when "11011000000" => tblu_rom:=X"0E5A";
      when "11011000001" => tblu_rom:=X"0E5C";
      when "11011000010" => tblu_rom:=X"0E5E";
      when "11011000011" => tblu_rom:=X"0E5E";
      when "11011000100" => tblu_rom:=X"0E60";
      when "11011000101" => tblu_rom:=X"0E60";
      when "11011000110" => tblu_rom:=X"0E62";
      when "11011000111" => tblu_rom:=X"0E64";
      when "11011001000" => tblu_rom:=X"0E64";
      when "11011001001" => tblu_rom:=X"0E66";
      when "11011001010" => tblu_rom:=X"0E68";
      when "11011001011" => tblu_rom:=X"0E68";
      when "11011001100" => tblu_rom:=X"0E6A";
      when "11011001101" => tblu_rom:=X"0E6A";
      when "11011001110" => tblu_rom:=X"0E6C";
      when "11011001111" => tblu_rom:=X"0E6E";
      when "11011010000" => tblu_rom:=X"0E6E";
      when "11011010001" => tblu_rom:=X"0E70";
      when "11011010010" => tblu_rom:=X"0E72";
      when "11011010011" => tblu_rom:=X"0E72";
      when "11011010100" => tblu_rom:=X"0E74";
      when "11011010101" => tblu_rom:=X"0E74";
      when "11011010110" => tblu_rom:=X"0E76";
      when "11011010111" => tblu_rom:=X"0E78";
      when "11011011000" => tblu_rom:=X"0E78";
      when "11011011001" => tblu_rom:=X"0E7A";
      when "11011011010" => tblu_rom:=X"0E7C";
      when "11011011011" => tblu_rom:=X"0E7C";
      when "11011011100" => tblu_rom:=X"0E7E";
      when "11011011101" => tblu_rom:=X"0E7E";
      when "11011011110" => tblu_rom:=X"0E80";
      when "11011011111" => tblu_rom:=X"0E82";
      when "11011100000" => tblu_rom:=X"0E82";
      when "11011100001" => tblu_rom:=X"0E84";
      when "11011100010" => tblu_rom:=X"0E86";
      when "11011100011" => tblu_rom:=X"0E86";
      when "11011100100" => tblu_rom:=X"0E88";
      when "11011100101" => tblu_rom:=X"0E88";
      when "11011100110" => tblu_rom:=X"0E8A";
      when "11011100111" => tblu_rom:=X"0E8C";
      when "11011101000" => tblu_rom:=X"0E8C";
      when "11011101001" => tblu_rom:=X"0E8E";
      when "11011101010" => tblu_rom:=X"0E90";
      when "11011101011" => tblu_rom:=X"0E90";
      when "11011101100" => tblu_rom:=X"0E92";
      when "11011101101" => tblu_rom:=X"0E92";
      when "11011101110" => tblu_rom:=X"0E94";
      when "11011101111" => tblu_rom:=X"0E96";
      when "11011110000" => tblu_rom:=X"0E96";
      when "11011110001" => tblu_rom:=X"0E98";
      when "11011110010" => tblu_rom:=X"0E9A";
      when "11011110011" => tblu_rom:=X"0E9A";
      when "11011110100" => tblu_rom:=X"0E9C";
      when "11011110101" => tblu_rom:=X"0E9E";
      when "11011110110" => tblu_rom:=X"0E9E";
      when "11011110111" => tblu_rom:=X"0EA0";
      when "11011111000" => tblu_rom:=X"0EA0";
      when "11011111001" => tblu_rom:=X"0EA2";
      when "11011111010" => tblu_rom:=X"0EA4";
      when "11011111011" => tblu_rom:=X"0EA4";
      when "11011111100" => tblu_rom:=X"0EA6";
      when "11011111101" => tblu_rom:=X"0EA8";
      when "11011111110" => tblu_rom:=X"0EA8";
      when "11011111111" => tblu_rom:=X"0EAA";
      when "11100000000" => tblu_rom:=X"0EAC";
      when "11100000001" => tblu_rom:=X"0EAC";
      when "11100000010" => tblu_rom:=X"0EAE";
      when "11100000011" => tblu_rom:=X"0EAE";
      when "11100000100" => tblu_rom:=X"0EB0";
      when "11100000101" => tblu_rom:=X"0EB2";
      when "11100000110" => tblu_rom:=X"0EB2";
      when "11100000111" => tblu_rom:=X"0EB4";
      when "11100001000" => tblu_rom:=X"0EB6";
      when "11100001001" => tblu_rom:=X"0EB6";
      when "11100001010" => tblu_rom:=X"0EB8";
      when "11100001011" => tblu_rom:=X"0EBA";
      when "11100001100" => tblu_rom:=X"0EBA";
      when "11100001101" => tblu_rom:=X"0EBC";
      when "11100001110" => tblu_rom:=X"0EBC";
      when "11100001111" => tblu_rom:=X"0EBE";
      when "11100010000" => tblu_rom:=X"0EC0";
      when "11100010001" => tblu_rom:=X"0EC0";
      when "11100010010" => tblu_rom:=X"0EC2";
      when "11100010011" => tblu_rom:=X"0EC4";
      when "11100010100" => tblu_rom:=X"0EC4";
      when "11100010101" => tblu_rom:=X"0EC6";
      when "11100010110" => tblu_rom:=X"0EC8";
      when "11100010111" => tblu_rom:=X"0EC8";
      when "11100011000" => tblu_rom:=X"0ECA";
      when "11100011001" => tblu_rom:=X"0ECA";
      when "11100011010" => tblu_rom:=X"0ECC";
      when "11100011011" => tblu_rom:=X"0ECE";
      when "11100011100" => tblu_rom:=X"0ECE";
      when "11100011101" => tblu_rom:=X"0ED0";
      when "11100011110" => tblu_rom:=X"0ED2";
      when "11100011111" => tblu_rom:=X"0ED2";
      when "11100100000" => tblu_rom:=X"0ED4";
      when "11100100001" => tblu_rom:=X"0ED6";
      when "11100100010" => tblu_rom:=X"0ED6";
      when "11100100011" => tblu_rom:=X"0ED8";
      when "11100100100" => tblu_rom:=X"0EDA";
      when "11100100101" => tblu_rom:=X"0EDA";
      when "11100100110" => tblu_rom:=X"0EDC";
      when "11100100111" => tblu_rom:=X"0EDC";
      when "11100101000" => tblu_rom:=X"0EDE";
      when "11100101001" => tblu_rom:=X"0EE0";
      when "11100101010" => tblu_rom:=X"0EE0";
      when "11100101011" => tblu_rom:=X"0EE2";
      when "11100101100" => tblu_rom:=X"0EE4";
      when "11100101101" => tblu_rom:=X"0EE4";
      when "11100101110" => tblu_rom:=X"0EE6";
      when "11100101111" => tblu_rom:=X"0EE8";
      when "11100110000" => tblu_rom:=X"0EE8";
      when "11100110001" => tblu_rom:=X"0EEA";
      when "11100110010" => tblu_rom:=X"0EEC";
      when "11100110011" => tblu_rom:=X"0EEC";
      when "11100110100" => tblu_rom:=X"0EEE";
      when "11100110101" => tblu_rom:=X"0EF0";
      when "11100110110" => tblu_rom:=X"0EF0";
      when "11100110111" => tblu_rom:=X"0EF2";
      when "11100111000" => tblu_rom:=X"0EF2";
      when "11100111001" => tblu_rom:=X"0EF4";
      when "11100111010" => tblu_rom:=X"0EF6";
      when "11100111011" => tblu_rom:=X"0EF6";
      when "11100111100" => tblu_rom:=X"0EF8";
      when "11100111101" => tblu_rom:=X"0EFA";
      when "11100111110" => tblu_rom:=X"0EFA";
      when "11100111111" => tblu_rom:=X"0EFC";
      when "11101000000" => tblu_rom:=X"0EFE";
      when "11101000001" => tblu_rom:=X"0EFE";
      when "11101000010" => tblu_rom:=X"0F00";
      when "11101000011" => tblu_rom:=X"0F02";
      when "11101000100" => tblu_rom:=X"0F02";
      when "11101000101" => tblu_rom:=X"0F04";
      when "11101000110" => tblu_rom:=X"0F06";
      when "11101000111" => tblu_rom:=X"0F06";
      when "11101001000" => tblu_rom:=X"0F08";
      when "11101001001" => tblu_rom:=X"0F0A";
      when "11101001010" => tblu_rom:=X"0F0A";
      when "11101001011" => tblu_rom:=X"0F0C";
      when "11101001100" => tblu_rom:=X"0F0C";
      when "11101001101" => tblu_rom:=X"0F0E";
      when "11101001110" => tblu_rom:=X"0F10";
      when "11101001111" => tblu_rom:=X"0F10";
      when "11101010000" => tblu_rom:=X"0F12";
      when "11101010001" => tblu_rom:=X"0F14";
      when "11101010010" => tblu_rom:=X"0F14";
      when "11101010011" => tblu_rom:=X"0F16";
      when "11101010100" => tblu_rom:=X"0F18";
      when "11101010101" => tblu_rom:=X"0F18";
      when "11101010110" => tblu_rom:=X"0F1A";
      when "11101010111" => tblu_rom:=X"0F1C";
      when "11101011000" => tblu_rom:=X"0F1C";
      when "11101011001" => tblu_rom:=X"0F1E";
      when "11101011010" => tblu_rom:=X"0F20";
      when "11101011011" => tblu_rom:=X"0F20";
      when "11101011100" => tblu_rom:=X"0F22";
      when "11101011101" => tblu_rom:=X"0F24";
      when "11101011110" => tblu_rom:=X"0F24";
      when "11101011111" => tblu_rom:=X"0F26";
      when "11101100000" => tblu_rom:=X"0F28";
      when "11101100001" => tblu_rom:=X"0F28";
      when "11101100010" => tblu_rom:=X"0F2A";
      when "11101100011" => tblu_rom:=X"0F2C";
      when "11101100100" => tblu_rom:=X"0F2C";
      when "11101100101" => tblu_rom:=X"0F2E";
      when "11101100110" => tblu_rom:=X"0F2E";
      when "11101100111" => tblu_rom:=X"0F30";
      when "11101101000" => tblu_rom:=X"0F32";
      when "11101101001" => tblu_rom:=X"0F32";
      when "11101101010" => tblu_rom:=X"0F34";
      when "11101101011" => tblu_rom:=X"0F36";
      when "11101101100" => tblu_rom:=X"0F36";
      when "11101101101" => tblu_rom:=X"0F38";
      when "11101101110" => tblu_rom:=X"0F3A";
      when "11101101111" => tblu_rom:=X"0F3A";
      when "11101110000" => tblu_rom:=X"0F3C";
      when "11101110001" => tblu_rom:=X"0F3E";
      when "11101110010" => tblu_rom:=X"0F3E";
      when "11101110011" => tblu_rom:=X"0F40";
      when "11101110100" => tblu_rom:=X"0F42";
      when "11101110101" => tblu_rom:=X"0F42";
      when "11101110110" => tblu_rom:=X"0F44";
      when "11101110111" => tblu_rom:=X"0F46";
      when "11101111000" => tblu_rom:=X"0F46";
      when "11101111001" => tblu_rom:=X"0F48";
      when "11101111010" => tblu_rom:=X"0F4A";
      when "11101111011" => tblu_rom:=X"0F4A";
      when "11101111100" => tblu_rom:=X"0F4C";
      when "11101111101" => tblu_rom:=X"0F4E";
      when "11101111110" => tblu_rom:=X"0F4E";
      when "11101111111" => tblu_rom:=X"0F50";
      when "11110000000" => tblu_rom:=X"0F52";
      when "11110000001" => tblu_rom:=X"0F52";
      when "11110000010" => tblu_rom:=X"0F54";
      when "11110000011" => tblu_rom:=X"0F56";
      when "11110000100" => tblu_rom:=X"0F56";
      when "11110000101" => tblu_rom:=X"0F58";
      when "11110000110" => tblu_rom:=X"0F5A";
      when "11110000111" => tblu_rom:=X"0F5A";
      when "11110001000" => tblu_rom:=X"0F5C";
      when "11110001001" => tblu_rom:=X"0F5E";
      when "11110001010" => tblu_rom:=X"0F5E";
      when "11110001011" => tblu_rom:=X"0F60";
      when "11110001100" => tblu_rom:=X"0F62";
      when "11110001101" => tblu_rom:=X"0F62";
      when "11110001110" => tblu_rom:=X"0F64";
      when "11110001111" => tblu_rom:=X"0F66";
      when "11110010000" => tblu_rom:=X"0F66";
      when "11110010001" => tblu_rom:=X"0F68";
      when "11110010010" => tblu_rom:=X"0F6A";
      when "11110010011" => tblu_rom:=X"0F6A";
      when "11110010100" => tblu_rom:=X"0F6C";
      when "11110010101" => tblu_rom:=X"0F6E";
      when "11110010110" => tblu_rom:=X"0F6E";
      when "11110010111" => tblu_rom:=X"0F70";
      when "11110011000" => tblu_rom:=X"0F72";
      when "11110011001" => tblu_rom:=X"0F72";
      when "11110011010" => tblu_rom:=X"0F74";
      when "11110011011" => tblu_rom:=X"0F76";
      when "11110011100" => tblu_rom:=X"0F76";
      when "11110011101" => tblu_rom:=X"0F78";
      when "11110011110" => tblu_rom:=X"0F7A";
      when "11110011111" => tblu_rom:=X"0F7A";
      when "11110100000" => tblu_rom:=X"0F7C";
      when "11110100001" => tblu_rom:=X"0F7E";
      when "11110100010" => tblu_rom:=X"0F7E";
      when "11110100011" => tblu_rom:=X"0F80";
      when "11110100100" => tblu_rom:=X"0F82";
      when "11110100101" => tblu_rom:=X"0F82";
      when "11110100110" => tblu_rom:=X"0F84";
      when "11110100111" => tblu_rom:=X"0F86";
      when "11110101000" => tblu_rom:=X"0F86";
      when "11110101001" => tblu_rom:=X"0F88";
      when "11110101010" => tblu_rom:=X"0F8A";
      when "11110101011" => tblu_rom:=X"0F8A";
      when "11110101100" => tblu_rom:=X"0F8C";
      when "11110101101" => tblu_rom:=X"0F8E";
      when "11110101110" => tblu_rom:=X"0F8E";
      when "11110101111" => tblu_rom:=X"0F90";
      when "11110110000" => tblu_rom:=X"0F92";
      when "11110110001" => tblu_rom:=X"0F92";
      when "11110110010" => tblu_rom:=X"0F94";
      when "11110110011" => tblu_rom:=X"0F96";
      when "11110110100" => tblu_rom:=X"0F96";
      when "11110110101" => tblu_rom:=X"0F98";
      when "11110110110" => tblu_rom:=X"0F9A";
      when "11110110111" => tblu_rom:=X"0F9C";
      when "11110111000" => tblu_rom:=X"0F9C";
      when "11110111001" => tblu_rom:=X"0F9E";
      when "11110111010" => tblu_rom:=X"0FA0";
      when "11110111011" => tblu_rom:=X"0FA0";
      when "11110111100" => tblu_rom:=X"0FA2";
      when "11110111101" => tblu_rom:=X"0FA4";
      when "11110111110" => tblu_rom:=X"0FA4";
      when "11110111111" => tblu_rom:=X"0FA6";
      when "11111000000" => tblu_rom:=X"0FA8";
      when "11111000001" => tblu_rom:=X"0FA8";
      when "11111000010" => tblu_rom:=X"0FAA";
      when "11111000011" => tblu_rom:=X"0FAC";
      when "11111000100" => tblu_rom:=X"0FAC";
      when "11111000101" => tblu_rom:=X"0FAE";
      when "11111000110" => tblu_rom:=X"0FB0";
      when "11111000111" => tblu_rom:=X"0FB0";
      when "11111001000" => tblu_rom:=X"0FB2";
      when "11111001001" => tblu_rom:=X"0FB4";
      when "11111001010" => tblu_rom:=X"0FB4";
      when "11111001011" => tblu_rom:=X"0FB6";
      when "11111001100" => tblu_rom:=X"0FB8";
      when "11111001101" => tblu_rom:=X"0FB8";
      when "11111001110" => tblu_rom:=X"0FBA";
      when "11111001111" => tblu_rom:=X"0FBC";
      when "11111010000" => tblu_rom:=X"0FBC";
      when "11111010001" => tblu_rom:=X"0FBE";
      when "11111010010" => tblu_rom:=X"0FC0";
      when "11111010011" => tblu_rom:=X"0FC2";
      when "11111010100" => tblu_rom:=X"0FC2";
      when "11111010101" => tblu_rom:=X"0FC4";
      when "11111010110" => tblu_rom:=X"0FC6";
      when "11111010111" => tblu_rom:=X"0FC6";
      when "11111011000" => tblu_rom:=X"0FC8";
      when "11111011001" => tblu_rom:=X"0FCA";
      when "11111011010" => tblu_rom:=X"0FCA";
      when "11111011011" => tblu_rom:=X"0FCC";
      when "11111011100" => tblu_rom:=X"0FCE";
      when "11111011101" => tblu_rom:=X"0FCE";
      when "11111011110" => tblu_rom:=X"0FD0";
      when "11111011111" => tblu_rom:=X"0FD2";
      when "11111100000" => tblu_rom:=X"0FD2";
      when "11111100001" => tblu_rom:=X"0FD4";
      when "11111100010" => tblu_rom:=X"0FD6";
      when "11111100011" => tblu_rom:=X"0FD6";
      when "11111100100" => tblu_rom:=X"0FD8";
      when "11111100101" => tblu_rom:=X"0FDA";
      when "11111100110" => tblu_rom:=X"0FDC";
      when "11111100111" => tblu_rom:=X"0FDC";
      when "11111101000" => tblu_rom:=X"0FDE";
      when "11111101001" => tblu_rom:=X"0FE0";
      when "11111101010" => tblu_rom:=X"0FE0";
      when "11111101011" => tblu_rom:=X"0FE2";
      when "11111101100" => tblu_rom:=X"0FE4";
      when "11111101101" => tblu_rom:=X"0FE4";
      when "11111101110" => tblu_rom:=X"0FE6";
      when "11111101111" => tblu_rom:=X"0FE8";
      when "11111110000" => tblu_rom:=X"0FE8";
      when "11111110001" => tblu_rom:=X"0FEA";
      when "11111110010" => tblu_rom:=X"0FEC";
      when "11111110011" => tblu_rom:=X"0FEE";
      when "11111110100" => tblu_rom:=X"0FEE";
      when "11111110101" => tblu_rom:=X"0FF0";
      when "11111110110" => tblu_rom:=X"0FF2";
      when "11111110111" => tblu_rom:=X"0FF2";
      when "11111111000" => tblu_rom:=X"0FF4";
      when "11111111001" => tblu_rom:=X"0FF6";
      when "11111111010" => tblu_rom:=X"0FF6";
      when "11111111011" => tblu_rom:=X"0FF8";
      when "11111111100" => tblu_rom:=X"0FFA";
      when "11111111101" => tblu_rom:=X"0FFA";
      when "11111111110" => tblu_rom:=X"0FFC";
      when "11111111111" => tblu_rom:=X"0FFE";
      when others => null;
    end case;

  rom_out := tblu_rom (rom_out'length-1 downto 0);
  if (lookuptable_wordsize-1-lookupint_bits+1-op_width >= 0) then
    z_extended := rom_out (lookuptable_wordsize-1-lookupint_bits+1 downto 
                           lookuptable_wordsize-1-lookupint_bits+1-op_width);
  else
    z_extended := (others => '0');
  end if;
  z_lookup <= z_extended(op_width downto 1);
end process;

alg1: process (a)
  variable C3 : unsigned (coef_case_size-1 downto 0);
  variable C2 : unsigned (coef_case_size-1 downto 0);
  variable C1 : unsigned (coef_case_size-1 downto 0);
  variable C0 : unsigned (coef_case_size-1 downto 0);
  variable Q2 : unsigned (coef_case_size-1 downto 0);
  variable Q1 : unsigned (coef_case_size-1 downto 0);
  variable Q0 : unsigned (coef_case_size-1 downto 0);
  variable L1 : unsigned (coef_case_size-1 downto 0);
  variable L0 : unsigned (coef_case_size-1 downto 0);
  variable C3_trunc : signed (coef3_size-1 downto 0);
  variable C2_trunc : signed (coef2_size-1 downto 0);
  variable C1_trunc : signed (coef1_size-1 downto 0);
  variable C0_trunc : signed (coef0_size-1 downto 0);
  variable Q2_trunc : signed (coef2_size-1 downto 0);
  variable Q1_trunc : signed (coef1_size-1 downto 0);
  variable Q0_trunc : signed (coef0_size-1 downto 0);
  variable L1_trunc : signed (coef1_size-1 downto 0);
  variable L0_trunc : signed (coef0_size-1 downto 0);
  variable p1_c  : signed (prod1_MSB+2 downto 0);
  variable p2_c  : signed (prod2_MSB+2 downto 0);
  variable p3_c : signed (prod3_MSB+2 downto 0);
  variable p1_q  : signed (prod1_MSB+2 downto 0);
  variable p2_q  : signed (prod2_MSB+2 downto 0);
  variable p3_q : signed (prod3_MSB+2 downto 0);
  variable p1_l  : signed (prod1_MSB+2 downto 0);
  variable p2_l  : signed (prod2_MSB+2 downto 0);
  variable p3_l : signed (prod3_MSB+2 downto 0);
  variable p1_sel  : signed (prod1_MSB downto 0);
  variable p1_aligned : unsigned (z_int_size-1 downto 0);
  variable z_int : unsigned (z_int_size-1 downto 0);
  variable addr : std_logic_vector (table_addrsize-1 downto 0);
  variable z_round : unsigned (z_round_MSB downto 0);
  variable diff : integer;
  variable pad_vec : unsigned (op_width downto 0);
begin
  pad_vec := (others => '0');
  pad_vec(pad_vec'left) := '1';
  for i in 0 to table_addrsize-1 loop
    if (op_width-1 <= i) then
      addr(table_addrsize - 1 - i) := '0';
    else
      addr(table_addrsize - 1 - i) := a(op_width - 1 - i);
    end if;
  end loop;
  
    case (addr) is
      when "00000000" => 
              C3:= X"0071D3C3E365";C2:= X"01EBFBC65AF1";C1:= X"058B90BFC443";C0:= X"07FFFFFFFFFF";
              Q2:= X"01ECA68408A4";Q1:= X"058B907B9A74";Q0:= X"08000000059F";
              L1:= X"058D7D221E7A";L0:= X"07FFFFAE3BFA";
      when "00000001" => 
              C3:= X"0072229F3C92";C2:= X"01EBFAD94E79";C1:= X"058B90C0BCF4";C0:= X"07FFFFFFFFA5";
              Q2:= X"01EDFC75221D";Q1:= X"058B8DCF9421";Q0:= X"0800000166F8";
              L1:= X"059157C4F389";L0:= X"07FFFBD36BA4";
      when "00000010" => 
              C3:= X"007271C8BD9C";C2:= X"01EBF8FE42E2";C1:= X"058B90C47E75";C0:= X"07FFFFFFFD15";
              Q2:= X"01EF5353A414";Q1:= X"058B8873F5EB";Q0:= X"08000006CE06";
              L1:= X"05953514981F";L0:= X"07FFF4189EBB";
      when "00000011" => 
              C3:= X"0072C1292881";C2:= X"01EBF633E119";C1:= X"058B90CCE8D5";C0:= X"07FFFFFFF494";
              Q2:= X"01F0AB200F50";Q1:= X"058B80650720";Q0:= X"08000012EFF6";
              L1:= X"05991512E78E";L0:= X"07FFE878760D";
      when "00000100" => 
              C3:= X"007310E3BA94";C2:= X"01EBF27731DB";C1:= X"058B90DBE6B3";C0:= X"07FFFFFFE079";
              Q2:= X"01F203DB3721";Q1:= X"058B759F0982";Q0:= X"080000288796";
              L1:= X"059CF7C1BE73";L0:= X"07FFD8ED8CD1";
      when "00000101" => 
              C3:= X"007360C39620";C2:= X"01EBEDC8F5DF";C1:= X"058B90F359C7";C0:= X"07FFFFFFB93D";
              Q2:= X"01F35D85920E";Q1:= X"058B681E3D72";Q0:= X"0800004A5552";
              L1:= X"05A0DD22FAB9";L0:= X"07FFC57278A4";
      when "00000110" => 
              C3:= X"0073B0D83C49";C2:= X"01EBE827691E";C1:= X"058B91152EFB";C0:= X"07FFFFFF7564";
              Q2:= X"01F4B81FCA18";Q1:= X"058B57DEDE40";Q0:= X"0800007B1F49";
              L1:= X"05A4C5387B85";L0:= X"07FFAE01C980";
      when "00000111" => 
              C3:= X"0074010CFDC7";C2:= X"01EBE1930675";C1:= X"058B9143496C";C0:= X"07FFFFFF099B";
              Q2:= X"01F613AAB18B";Q1:= X"058B44DD20FD";Q0:= X"080000BDB152";
              L1:= X"05A8B0042164";L0:= X"07FF929609B7";
      when "00001000" => 
              C3:= X"007451A3EF42";C2:= X"01EBDA0501DF";C1:= X"058B917FC3F6";C0:= X"07FFFFFE681A";
              Q2:= X"01F77026D27F";Q1:= X"058B2F153A18";Q0:= X"08000114DCFC";
              L1:= X"05AC9D87CE17";L0:= X"07FF7329BDF2";
      when "00001001" => 
              C3:= X"0074A250697C";C2:= X"01EBD182CC37";C1:= X"058B91CC6362";C0:= X"07FFFFFD81F7";
              Q2:= X"01F8CD94B4B4";Q1:= X"058B16835B50";Q0:= X"08000183798F";
              L1:= X"05B08DC564B9";L0:= X"07FF4FB76527";
      when "00001010" => 
              C3:= X"0074F35A8CE6";C2:= X"01EBC803A0BE";C1:= X"058B922B6668";C0:= X"07FFFFFC44F6";
              Q2:= X"01FA2BF548E4";Q1:= X"058AFB23AAC2";Q0:= X"0800020C6446";
              L1:= X"05B480BEC9BB";L0:= X"07FF28397895";
      when "00001011" => 
              C3:= X"007544934825";C2:= X"01EBBD8B1070";C1:= X"058B929EA2E9";C0:= X"07FFFFFA9E0F";
              Q2:= X"01FB8B48EBFD";Q1:= X"058ADCF2559F";Q0:= X"080002B27FF9";
              L1:= X"05B87675E2D3";L0:= X"07FEFCAA6BC0";
      when "00001100" => 
              C3:= X"00759600564C";C2:= X"01EBB2176491";C1:= X"058B93281E9F";C0:= X"07FFFFF877B3";
              Q2:= X"01FCEB90807D";Q1:= X"058ABBEB7A7C";Q0:= X"08000378B596";
              L1:= X"05BC6EEC970D";L0:= X"07FECD04AC6D";
      when "00001101" => 
              C3:= X"0075E76CF178";C2:= X"01EBA5AFC47E";C1:= X"058B93C96E48";C0:= X"07FFFFF5BC47";
              Q2:= X"01FE4CCC7876";Q1:= X"058A980B3E0C";Q0:= X"08000461F3B5";
              L1:= X"05C06A24CEC0";L0:= X"07FE9942A297";
      when "00001110" => 
              C3:= X"007639609E4A";C2:= X"01EB983DCF82";C1:= X"058B9485B524";C0:= X"07FFFFF24D3A";
              Q2:= X"01FFAEFDC0EF";Q1:= X"058A714DB4C7";Q0:= X"080005712F26";
              L1:= X"05C46820739F";L0:= X"07FE615EB071";
      when "00001111" => 
              C3:= X"00768B644031";C2:= X"01EB89D3144E";C1:= X"058B955E032C";C0:= X"07FFFFEE1339";
              Q2:= X"02011224D454";Q1:= X"058A47AEFAFF";Q0:= X"080006A96264";
              L1:= X"05C868E170B7";L0:= X"07FE2553325A";
      when "00010000" => 
              C3:= X"0076DDB864C4";C2:= X"01EB7A633592";C1:= X"058B96550E59";C0:= X"07FFFFE8ED22";
              Q2:= X"0202764267EB";Q1:= X"058A1B2B22EF";Q0:= X"0800080D8E0D";
              L1:= X"05CC6C69B253";L0:= X"07FDE51A7EDC";
      when "00010001" => 
              C3:= X"00773020A779";C2:= X"01EB69F873FB";C1:= X"058B976C309F";C0:= X"07FFFFE2BEDD";
              Q2:= X"0203DB571E60";Q1:= X"0589EBBE3D02";Q0:= X"080009A0B8B3";
              L1:= X"05D072BB2628";L0:= X"07FDA0AEE6A7";
      when "00010010" => 
              C3:= X"007782D28C48";C2:= X"01EB588719E8";C1:= X"058B98A6318F";C0:= X"07FFFFDB625E";
              Q2:= X"02054163B908";Q1:= X"0589B9645185";Q0:= X"08000B65EF19";
              L1:= X"05D47BD7BB40";L0:= X"07FD580AB485";
      when "00010011" => 
              C3:= X"0077D5C4FA94";C2:= X"01EB460F5C25";C1:= X"058B9A051BDA";C0:= X"07FFFFD2B36F";
              Q2:= X"0206A868D3F2";Q1:= X"0589841969A3";Q0:= X"08000D6043F0";
              L1:= X"05D887C161EC";L0:= X"07FD0B282D60";
      when "00010100" => 
              C3:= X"00782912091A";C2:= X"01EB32895134";C1:= X"058B9B8BA035";C0:= X"07FFFFC88761";
              Q2:= X"020810671AF5";Q1:= X"05894BD9889D";Q0:= X"08000F92D012";
              L1:= X"05DC967A0BEC";L0:= X"07FCBA019031";
      when "00010101" => 
              C3:= X"00787C8AEB57";C2:= X"01EB1DFE47A4";C1:= X"058B9D3B19FC";C0:= X"07FFFFBCBA3B";
              Q2:= X"0209795F4A9B";Q1:= X"058910A0AABE";Q0:= X"08001200B29F";
              L1:= X"05E0A803AC41";L0:= X"07FC64911601";
      when "00010110" => 
              C3:= X"0078D0367E6A";C2:= X"01EB086BAD8F";C1:= X"058B9F15C73B";C0:= X"07FFFFAF205B";
              Q2:= X"020AE352087B";Q1:= X"0588D26ACBE8";Q0:= X"080014AD10C3";
              L1:= X"05E4BC603764";L0:= X"07FC0AD0F1E1";
      when "00010111" => 
              C3:= X"007923F0825D";C2:= X"01EAF1DA317B";C1:= X"058BA11CED37";C0:= X"07FFFF9F9345";
              Q2:= X"020C4E3FFAA6";Q1:= X"05889133E414";Q0:= X"0800179B15DB";
              L1:= X"05E8D391A316";L0:= X"07FBACBB50E9";
      when "00011000" => 
              C3:= X"0079780A329A";C2:= X"01EADA32E5D8";C1:= X"058BA354A9F8";C0:= X"07FFFF8DD492";
              Q2:= X"020DBA29C81A";Q1:= X"05884CF7E728";Q0:= X"08001ACDF37F";
              L1:= X"05ECED99E674";L0:= X"07FB4A4A5A2B";
      when "00011001" => 
              C3:= X"0079CC4EF3BB";C2:= X"01EAC1829BC5";C1:= X"058BA5BDF0CF";C0:= X"07FFFF79BBB3";
              Q2:= X"020F271032DB";Q1:= X"058805B2BFD5";Q0:= X"08001E48E1D1";
              L1:= X"05F10A7AF9EE";L0:= X"07FAE3782EB5";
      when "00011010" => 
              C3:= X"007A20D7EA90";C2:= X"01EAA7C0DC9B";C1:= X"058BA85BAAA9";C0:= X"07FFFF630E94";
              Q2:= X"021094F3E6DD";Q1:= X"0587BB6058B3";Q0:= X"0800220F1F11";
              L1:= X"05F52A36D781";L0:= X"07FA783EE983";
      when "00011011" => 
              C3:= X"007A758A569F";C2:= X"01EA8CF47BC7";C1:= X"058BAB2F42DF";C0:= X"07FFFF499D74";
              Q2:= X"021203D5928F";Q1:= X"05876DFC97D1";Q0:= X"08002623EFDD";
              L1:= X"05F94CCF7A47";L0:= X"07FA08989F86";
      when "00011100" => 
              C3:= X"007ACA8A557F";C2:= X"01EA7110B5BD";C1:= X"058BAE3C324F";C0:= X"07FFFF2D2413";
              Q2:= X"021373B5DC92";Q1:= X"05871D8360D4";Q0:= X"08002A8A9F1D";
              L1:= X"05FD7246DEF3";L0:= X"07F9947F5F8F";
      when "00011101" => 
              C3:= X"007B2003AFC7";C2:= X"01EA54043CEA";C1:= X"058BB186AEF5";C0:= X"07FFFF0D52DB";
              Q2:= X"0214E49591EC";Q1:= X"0586C9F08AD1";Q0:= X"08002F467E97";
              L1:= X"06019A9F036B";L0:= X"07F91BED3257";
      when "00011110" => 
              C3:= X"007B755C1F7B";C2:= X"01EA3602C83C";C1:= X"058BB50AF1A8";C0:= X"07FFFEEA26E1";
              Q2:= X"0216567533DB";Q1:= X"0586733FF9C3";Q0:= X"0800345AE591";
              L1:= X"0605C5D9E723";L0:= X"07F89EDC1A70";
      when "00011111" => 
              C3:= X"007BCB169FCE";C2:= X"01EA16DDC252";C1:= X"058BB8D081F6";C0:= X"07FFFEC32C10";
              Q2:= X"0217C9559A03";Q1:= X"0586196D79E5";Q0:= X"080039CB32E5";
              L1:= X"0609F3F98ACD";L0:= X"07F81D461444";
      when "00100000" => 
              C3:= X"007C20DA672F";C2:= X"01E9F6B4352C";C1:= X"058BBCD5C403";C0:= X"07FFFE98481F";
              Q2:= X"02193D3776EC";Q1:= X"0585BC74DB63";Q0:= X"08003F9ACB82";
              L1:= X"060E24FFF096";L0:= X"07F79725160E";
      when "00100001" => 
              C3:= X"007C7718FE0D";C2:= X"01E9D55A0690";C1:= X"058BC1226FA7";C0:= X"07FFFE68FBB7";
              Q2:= X"021AB21B5802";Q1:= X"05855C51F3FA";Q0:= X"080045CD1A3F";
              L1:= X"061258EF1C04";L0:= X"07F70C730FD5";
      when "00100010" => 
              C3:= X"007CCD6CAF68";C2:= X"01E9B2F4AEB8";C1:= X"058BC5B3F177";C0:= X"07FFFE353439";
              Q2:= X"021C2802249E";Q1:= X"0584F9007E2B";Q0:= X"08004C659202";
              L1:= X"06168FC91208";L0:= X"07F67D29EB67";
      when "00100011" => 
              C3:= X"007D2402F607";C2:= X"01E98F713611";C1:= X"058BCA8EF167";C0:= X"07FFFDFC8DB5";
              Q2:= X"021D9EEC5A9E";Q1:= X"0584927C4BD9";Q0:= X"08005367AA80";
              L1:= X"061AC98FD8F6";L0:= X"07F5E9438C51";
      when "00100100" => 
              C3:= X"007D7B043395";C2:= X"01E96ABC9269";C1:= X"058BCFB868F7";C0:= X"07FFFDBE9ABF";
              Q2:= X"021F16DAE1DD";Q1:= X"058428C10E2A";Q0:= X"08005AD6E403";
              L1:= X"061F06457891";L0:= X"07F550B9CFD8";
      when "00100101" => 
              C3:= X"007DD2007372";C2:= X"01E945051C13";C1:= X"058BD52BFCB2";C0:= X"07FFFD7B5D48";
              Q2:= X"02208FCE4986";Q1:= X"0583BBCA8A77";Q0:= X"080062B6C3D1";
              L1:= X"062345EBF9FB";L0:= X"07F4B3868CFB";
      when "00100110" => 
              C3:= X"007E297224B1";C2:= X"01E91E146BE8";C1:= X"058BDAF3C58F";C0:= X"07FFFD322400";
              Q2:= X"022209C768CA";Q1:= X"05834B946D4D";Q0:= X"08006B0AD765";
              L1:= X"0627888567CE";L0:= X"07F411A39461";
      when "00100111" => 
              C3:= X"007E81029BEE";C2:= X"01E8F60F18E6";C1:= X"058BE10CAD38";C0:= X"07FFFCE2DE63";
              Q2:= X"022384C6C44B";Q1:= X"0582D81A7769";Q0:= X"080073D6B128";
              L1:= X"062BCE13CDFB";L0:= X"07F36B0AB061";
      when "00101000" => 
              C3:= X"007ED8B479CD";C2:= X"01E8CCF39F23";C1:= X"058BE77908AA";C0:= X"07FFFC8D3820";
              Q2:= X"022500CD4715";Q1:= X"05826158466D";Q0:= X"08007D1DECA3";
              L1:= X"0630169939EA";L0:= X"07F2BFB5A4F2";
      when "00101001" => 
              C3:= X"007F30C814AB";C2:= X"01E8A2A23064";C1:= X"058BEE402070";C0:= X"07FFFC3095D3";
              Q2:= X"02267DDB86CB";Q1:= X"0581E7498DBE";Q0:= X"080086E42A35";
              L1:= X"06346217BA73";L0:= X"07F20F9E2FA7";
      when "00101010" => 
              C3:= X"007F890A5875";C2:= X"01E877318FB2";C1:= X"058BF560A7E5";C0:= X"07FFFBCCCD04";
              Q2:= X"0227FBF23F1A";Q1:= X"058169E9F0E4";Q0:= X"0800912D11F9";
              L1:= X"0638B0915FDF";L0:= X"07F15ABE07AB";
      when "00101011" => 
              C3:= X"007FE1AFD1C4";C2:= X"01E84A860505";C1:= X"058BFCE18BA1";C0:= X"07FFFB613E78";
              Q2:= X"02297B122D35";Q1:= X"0580E9350E6A";Q0:= X"08009BFC5304";
              L1:= X"063D02083BCC";L0:= X"07F0A10EDDBE";
      when "00101100" => 
              C3:= X"00803A3CC8E0";C2:= X"01E81CDD4AB4";C1:= X"058C04BA9A01";C0:= X"07FFFAEE22C6";
              Q2:= X"022AFB3C0ED9";Q1:= X"058065268032";Q0:= X"0800A755A363";
              L1:= X"0641567E615F";L0:= X"07EFE28A5C2A";
      when "00101101" => 
              C3:= X"008093620751";C2:= X"01E7EDDAC15F";C1:= X"058C0CFE1429";C0:= X"07FFFA722D67";
              Q2:= X"022C7C7081DD";Q1:= X"057FDDB9E704";Q0:= X"0800B33CBF1F";
              L1:= X"0645ADF5E52F";L0:= X"07EF1F2A26BC";
      when "00101110" => 
              C3:= X"0080EC7AA8FF";C2:= X"01E7BDD3861C";C1:= X"058C159F6B33";C0:= X"07FFF9EDD77C";
              Q2:= X"022DFEB04BE4";Q1:= X"057F52EAD1A7";Q0:= X"0800BFB56A6D";
              L1:= X"064A0870DD3A";L0:= X"07EE56E7DAC4";
      when "00101111" => 
              C3:= X"00814616B863";C2:= X"01E78C789B3B";C1:= X"058C1EAF2759";C0:= X"07FFF95FDF83";
              Q2:= X"022F81FC4794";Q1:= X"057EC4B4C269";Q0:= X"0800CCC37155";
              L1:= X"064E65F160FA";L0:= X"07ED89BD0F0A";
      when "00110000" => 
              C3:= X"00819FE5C1D4";C2:= X"01E759F3F965";C1:= X"058C28281AD9";C0:= X"07FFF8C84E2C";
              Q2:= X"0231065506CC";Q1:= X"057E331351BE";Q0:= X"0800DA6AA487";
              L1:= X"0652C6798953";L0:= X"07ECB7A353CB";
      when "00110001" => 
              C3:= X"0081F9AA77EA";C2:= X"01E72667F6E7";C1:= X"058C3205F6A2";C0:= X"07FFF82724B3";
              Q2:= X"02328BBB599B";Q1:= X"057D9E01FCF4";Q0:= X"0800E8AEDDE7";
              L1:= X"06572A0B70A2";L0:= X"07EBE09432B4";
      when "00110010" => 
              C3:= X"008253F81B00";C2:= X"01E6F17EA3F0";C1:= X"058C3C5B8D5F";C0:= X"07FFF77AE66B";
              Q2:= X"0234122FF7DE";Q1:= X"057D057C45E8";Q0:= X"0800F793FDAB";
              L1:= X"065B90A932B2";L0:= X"07EB04892ED7";
      when "00110011" => 
              C3:= X"0082AE7B47CC";C2:= X"01E6BB661D61";C1:= X"058C47228394";C0:= X"07FFF6C3ADED";
              Q2:= X"023599B392A3";Q1:= X"057C697DACE1";Q0:= X"0801071DEAEE";
              L1:= X"065FFA54ECDD";L0:= X"07EA237BC4A7";
      when "00110100" => 
              C3:= X"0083091B5E39";C2:= X"01E6842C8D56";C1:= X"058C525A422A";C0:= X"07FFF6013B40";
              Q2:= X"02372246DFBD";Q1:= X"057BCA01AC14";Q0:= X"080117509428";
              L1:= X"06646710BDD8";L0:= X"07E93D6569F6";
      when "00110101" => 
              C3:= X"0083642BF69D";C2:= X"01E64B9D2CE8";C1:= X"058C5E1001C0";C0:= X"07FFF53258FD";
              Q2:= X"0238ABEAAB8D";Q1:= X"057B2703B02B";Q0:= X"0801282FF000";
              L1:= X"0668D6DEC5DC";L0:= X"07E8523F8DEC";
      when "00110110" => 
              C3:= X"0083BF55ECC5";C2:= X"01E611EC55CA";C1:= X"058C6A3B6B82";C0:= X"07FFF45748A6";
              Q2:= X"023A369FBD78";Q1:= X"057A807F22FE";Q0:= X"080139BFFC48";
              L1:= X"066D49C126A6";L0:= X"07E7620398FB";
      when "00110111" => 
              C3:= X"00841AD0329F";C2:= X"01E5D6F64FDD";C1:= X"058C76E65FA8";C0:= X"07FFF36F07C8";
              Q2:= X"023BC266C8AE";Q1:= X"0579D66F725A";Q0:= X"08014C04BD49";
              L1:= X"0671BFBA0363";L0:= X"07E66CAAECE4";
      when "00111000" => 
              C3:= X"0084767AFD46";C2:= X"01E59ACE02E9";C1:= X"058C840F49C7";C0:= X"07FFF2795E95";
              Q2:= X"023D4F4071C8";Q1:= X"057928D00E76";Q0:= X"08015F023DDE";
              L1:= X"067638CB80AE";L0:= X"07E5722EE4AC";
      when "00111001" => 
              C3:= X"0084D26CA18F";C2:= X"01E55D6360CE";C1:= X"058C91BC21BA";C0:= X"07FFF17587AA";
              Q2:= X"023EDD2D9B65";Q1:= X"0578779C47EF";Q0:= X"080172BC9341";
              L1:= X"067AB4F7C4BB";L0:= X"07E47288D491";
      when "00111010" => 
              C3:= X"00852E90A77F";C2:= X"01E51EC2CE9E";C1:= X"058C9FEC94F4";C0:= X"07FFF06331F0";
              Q2:= X"02406C2EEC13";Q1:= X"0577C2CF854F";Q0:= X"08018737D737";
              L1:= X"067F3440F737";L0:= X"07E36DB20A08";
      when "00111011" => 
              C3:= X"00858B05E2C9";C2:= X"01E4DED5AC0B";C1:= X"058CAEA84DBE";C0:= X"07FFEF416E5E";
              Q2:= X"0241FC4545B9";Q1:= X"05770A650DC4";Q0:= X"08019C782E09";
              L1:= X"0683B6A94131";L0:= X"07E263A3CBBE";
      when "00111100" => 
              C3:= X"0085E7B58D74";C2:= X"01E49DAA0544";C1:= X"058CBDEE9E22";C0:= X"07FFEE0FED66";
              Q2:= X"02438D713D3C";Q1:= X"05764E584763";Q0:= X"0801B281BF76";
              L1:= X"06883C32CD58";L0:= X"07E154575983";
      when "00111101" => 
              C3:= X"0086449D93F6";C2:= X"01E45B401425";C1:= X"058CCDC1EEAE";C0:= X"07FFECCE222E";
              Q2:= X"02451FB3B7BC";Q1:= X"05758EA46E8A";Q0:= X"0801C958BF1C";
              L1:= X"068CC4DFC7CC";L0:= X"07E03FC5EC4D";
      when "00111110" => 
              C3:= X"0086A1E75CDF";C2:= X"01E417785B1E";C1:= X"058CDE2C61DC";C0:= X"07FFEB7ADCD4";
              Q2:= X"0246B30D4F69";Q1:= X"0574CB44DE78";Q0:= X"0801E1016400";
              L1:= X"069150B25E41";L0:= X"07DF25E8B630";
      when "00111111" => 
              C3:= X"0086FF49CF08";C2:= X"01E3D2867F5E";C1:= X"058CEF23FF64";C0:= X"07FFEA1689D0";
              Q2:= X"0248477EF15A";Q1:= X"05740434C615";Q0:= X"0801F97FF194";
              L1:= X"0695DFACBFCB";L0:= X"07DE06B8E25D";
      when "01000000" => 
              C3:= X"00875D183BF6";C2:= X"01E38C2B6911";C1:= X"058D00BAE37E";C0:= X"07FFE89F487A";
              Q2:= X"0249DD0942EF";Q1:= X"0573396F7271";Q0:= X"080212D8AEC0";
              L1:= X"069A71D11D27";L0:= X"07DCE22F950F";
      when "01000001" => 
              C3:= X"0087BAFEA4F3";C2:= X"01E344A4A002";C1:= X"058D12E43BE4";C0:= X"07FFE715C4E2";
              Q2:= X"024B73AD078D";Q1:= X"05726AF01DA6";Q0:= X"08022D0FEBDD";
              L1:= X"069F0721A883";L0:= X"07DBB845EB90";
      when "01000010" => 
              C3:= X"00881926C0E2";C2:= X"01E2FBD15D0C";C1:= X"058D25AAD04A";C0:= X"07FFE578B07C";
              Q2:= X"024D0B6B23CF";Q1:= X"057198B1EBFE";Q0:= X"0802482A0340";
              L1:= X"06A39FA0959D";L0:= X"07DA88F4FC2D";
      when "01000011" => 
              C3:= X"008877A84391";C2:= X"01E2B19D85AA";C1:= X"058D3916798B";C0:= X"07FFE3C6F375";
              Q2:= X"024EA44419B9";Q1:= X"0570C2B03015";Q0:= X"0802642B5076";
              L1:= X"06A83B5019AC";L0:= X"07D95435D635";
      when "01000100" => 
              C3:= X"0088D67321B3";C2:= X"01E266138F54";C1:= X"058D4D274100";C0:= X"07FFE2001D97";
              Q2:= X"02503E38FAF9";Q1:= X"056FE8E5ED2E";Q0:= X"080281184098";
              L1:= X"06ACDA326B7A";L0:= X"07D81A0181ED";
      when "01000101" => 
              C3:= X"0089356633E7";C2:= X"01E2194C92EB";C1:= X"058D61D90EE2";C0:= X"07FFE0241EF1";
              Q2:= X"0251D94A5B85";Q1:= X"056F0B4E63BC";Q0:= X"08029EF54002";
              L1:= X"06B17C49C36C";L0:= X"07D6DA510085";
      when "01000110" => 
              C3:= X"0089947CD837";C2:= X"01E1CB4BDCB0";C1:= X"058D772D57E3";C0:= X"07FFDE326CF3";
              Q2:= X"025375790B85";Q1:= X"056E29E4AFEA";Q0:= X"0802BDC6C721";
              L1:= X"06B621985B3F";L0:= X"07D5951D4C28";
      when "01000111" => 
              C3:= X"0089F3EC26AE";C2:= X"01E17BE46599";C1:= X"058D8D330D2A";C0:= X"07FFDC2939A3";
              Q2:= X"025512C5CB24";Q1:= X"056D44A3F1FA";Q0:= X"0802DD915523";
              L1:= X"06BACA206E77";L0:= X"07D44A5F57D4";
      when "01001000" => 
              C3:= X"008A53BD68DE";C2:= X"01E12B0C0AA6";C1:= X"058DA3EFE584";C0:= X"07FFDA078430";
              Q2:= X"0256B1316EE7";Q1:= X"056C5B873A26";Q0:= X"0802FE5972C9";
              L1:= X"06BF75E439F9";L0:= X"07D2FA100F71";
      when "01001001" => 
              C3:= X"008AB3D184FF";C2:= X"01E0D8DAC947";C1:= X"058DBB600298";C0:= X"07FFD7CD2E78";
              Q2:= X"025850BCB9E0";Q1:= X"056B6E899D88";Q0:= X"08032023AF8F";
              L1:= X"06C424E5FC4B";L0:= X"07D1A42857BC";
      when "01001010" => 
              C3:= X"008B14188BD4";C2:= X"01E0855CFDFE";C1:= X"058DD3827BE3";C0:= X"07FFD579D80C";
              Q2:= X"0259F168689A";Q1:= X"056A7DA63098";Q0:= X"080342F4A261";
              L1:= X"06C8D727F57D";L0:= X"07D048A10E41";
      when "01001011" => 
              C3:= X"008B74AAE1F7";C2:= X"01E0307C28D5";C1:= X"058DEC607851";C0:= X"07FFD30C2621";
              Q2:= X"025B93355CB7";Q1:= X"056988D7ED7D";Q0:= X"080366D0ED6E";
              L1:= X"06CD8CAC6731";L0:= X"07CEE7730958";
      when "01001100" => 
              C3:= X"008BD53E1EED";C2:= X"01DFDA791236";C1:= X"058E05E96D37";C0:= X"07FFD08540DE";
              Q2:= X"025D3624424B";Q1:= X"05689019E8FA";Q0:= X"08038BBD3676";
              L1:= X"06D24575949A";L0:= X"07CD8097181D";
      when "01001101" => 
              C3:= X"008C367D3026";C2:= X"01DF82B94EA1";C1:= X"058E204E1DCB";C0:= X"07FFCDDFD17F";
              Q2:= X"025EDA35F6F5";Q1:= X"0567936715F6";Q0:= X"0803B1BE2FB4";
              L1:= X"06D70185C27D";L0:= X"07CC1406026A";
      when "01001110" => 
              C3:= X"008C97D52AF1";C2:= X"01DF29BE998A";C1:= X"058E3B6AA53C";C0:= X"07FFCB1EE6A9";
              Q2:= X"02607F6B3463";Q1:= X"056692BA780A";Q0:= X"0803D8D8906A";
              L1:= X"06DBC0DF3730";L0:= X"07CAA1B888CE";
      when "01001111" => 
              C3:= X"008CF963DAD1";C2:= X"01DECF6D4469";C1:= X"058E5749DEF7";C0:= X"07FFC840EBA0";
              Q2:= X"026225C4C2EC";Q1:= X"05658E0F057F";Q0:= X"080401111961";
              L1:= X"06E083843A95";L0:= X"07C929A7648E";
      when "01010000" => 
              C3:= X"008D5B2D6578";C2:= X"01DE73C03BDD";C1:= X"058E73F0068C";C0:= X"07FFC544EE8C";
              Q2:= X"0263CD439A0F";Q1:= X"0564855F9255";Q0:= X"08042A6C984F";
              L1:= X"06E549771638";L0:= X"07C7ABCB4790";
      when "01010001" => 
              C3:= X"008DBD42FF33";C2:= X"01DE16A5C512";C1:= X"058E916570D0";C0:= X"07FFC22989BF";
              Q2:= X"026575E838CB";Q1:= X"056378A73903";Q0:= X"080454EFD787";
              L1:= X"06EA12BA1534";L0:= X"07C6281CDC60";
      when "01010010" => 
              C3:= X"008E1FB03C7F";C2:= X"01DDB810C2F2";C1:= X"058EAFB13C74";C0:= X"07FFBEED6EB3";
              Q2:= X"02671FB3A4CD";Q1:= X"056267E0BAF6";Q0:= X"0804809FB6EE";
              L1:= X"06EEDF4F8429";L0:= X"07C49E94C62D";
      when "01010011" => 
              C3:= X"008E825B1B39";C2:= X"01DD58187DF3";C1:= X"058ECECECED1";C0:= X"07FFBB908E34";
              Q2:= X"0268CAA69F8D";Q1:= X"05615306FF51";Q0:= X"0804AD811837";
              L1:= X"06F3AF39B16D";L0:= X"07C30F2BA0AF";
      when "01010100" => 
              C3:= X"008EE54FACD1";C2:= X"01DCF6AF887C";C1:= X"058EEEC55F36";C0:= X"07FFB8119163";
              Q2:= X"026A76C201A1";Q1:= X"05603A14D9BA";Q0:= X"0804DB98E7E8";
              L1:= X"06F8827AECD1";L0:= X"07C179DA003A";
      when "01010101" => 
              C3:= X"008F48793478";C2:= X"01DC93E8F3FC";C1:= X"058F0F916EAA";C0:= X"07FFB4704BE4";
              Q2:= X"026C24066B43";Q1:= X"055F1D053E32";Q0:= X"08050AEC14E7";
              L1:= X"06FD591587D9";L0:= X"07BFDE9871A1";
      when "01010110" => 
              C3:= X"008FABD93853";C2:= X"01DC2FC21996";C1:= X"058F313691B1";C0:= X"07FFB0ABC9F7";
              Q2:= X"026DD274C1BE";Q1:= X"055DFBD2EEAF";Q0:= X"08053B7F9E10";
              L1:= X"0702330BD5A0";L0:= X"07BE3D5F7A39";
      when "01010111" => 
              C3:= X"00900F9F3586";C2:= X"01DBCA092021";C1:= X"058F53C8870D";C0:= X"07FFACC13CC5";
              Q2:= X"026F820DFA6E";Q1:= X"055CD6789C9B";Q0:= X"08056D588CF8";
              L1:= X"070710602AD6";L0:= X"07BC962797D4";
      when "01011000" => 
              C3:= X"0090738D35E4";C2:= X"01DB62FBB27E";C1:= X"058F77353212";C0:= X"07FFA8B21B57";
              Q2:= X"027132D2A37B";Q1:= X"055BACF13AC3";Q0:= X"0805A07BE7E2";
              L1:= X"070BF114DDC6";L0:= X"07BAE8E940BB";
      when "01011001" => 
              C3:= X"0090D7FE22DE";C2:= X"01DAFA39A5A6";C1:= X"058F9BA0CF36";C0:= X"07FFA4799CA4";
              Q2:= X"0272E4C3D5E0";Q1:= X"055A7F3757E3";Q0:= X"0805D4EECE16";
              L1:= X"0710D52C466A";L0:= X"07B9359CE39B";
      when "01011010" => 
              C3:= X"00913C5E572D";C2:= X"01DA905C0ECC";C1:= X"058FC0D8CF9B";C0:= X"07FFA01D07F5";
              Q2:= X"027497E21278";Q1:= X"05594D45E74B";Q0:= X"08060AB6554C";
              L1:= X"0715BCA8BE57";L0:= X"07B77C3AE78B";
      when "01011011" => 
              C3:= X"0091A1155587";C2:= X"01DA24F504D1";C1:= X"058FE70674AD";C0:= X"07FF9B96F283";
              Q2:= X"02764C2E68CC";Q1:= X"0558171773D9";Q0:= X"080641D7AD60";
              L1:= X"071AA78CA0C0";L0:= X"07B5BCBBAC00";
      when "01011100" => 
              C3:= X"0092063C5094";C2:= X"01D9B7E71BC9";C1:= X"05900E377829";C0:= X"07FF96E51142";
              Q2:= X"027801A982E0";Q1:= X"0556DCA6CAE8";Q0:= X"08067A580272";
              L1:= X"071F95DA4A7A";L0:= X"07B3F71788CA";
      when "01011101" => 
              C3:= X"00926B9D4CC0";C2:= X"01D9496A6547";C1:= X"0590365AD64A";C0:= X"07FF9208C530";
              Q2:= X"0279B854508D";Q1:= X"05559DEE831D";Q0:= X"0806B43C925C";
              L1:= X"0724879419F7";L0:= X"07B22B46CE0A";
      when "01011110" => 
              C3:= X"0092D119D4A7";C2:= X"01D8D99F702D";C1:= X"05905F6755E6";C0:= X"07FF8D0291EC";
              Q2:= X"027B702F8DEE";Q1:= X"05545AE95398";Q0:= X"0806EF8A9D1A";
              L1:= X"07297CBC6F65";L0:= X"07B05941C423";
      when "01011111" => 
              C3:= X"009336FEF275";C2:= X"01D8682FDA67";C1:= X"0590897F9EB9";C0:= X"07FF87CD930F";
              Q2:= X"027D293C2A17";Q1:= X"05531391C915";Q0:= X"08072C47727B";
              L1:= X"072E7555AC7C";L0:= X"07AE8100ABC7";
      when "01100000" => 
              C3:= X"00939D8C556A";C2:= X"01D7F4D0A013";C1:= X"0590B4C3735E";C0:= X"07FF826512CD";
              Q2:= X"027EE37ACF36";Q1:= X"0551C7E29E78";Q0:= X"08076A7861CF";
              L1:= X"0733716234B3";L0:= X"07ACA27BBDD8";
      when "01100001" => 
              C3:= X"009403C99A01";C2:= X"01D780989371";C1:= X"0590E0CCE5C9";C0:= X"07FF7CD52E18";
              Q2:= X"02809EEC62A7";Q1:= X"055077D65DF1";Q0:= X"0807AA22CB82";
              L1:= X"073870E46D1A";L0:= X"07AABDAB2B77";
      when "01100010" => 
              C3:= X"00946A7826E2";C2:= X"01D70AAC21B5";C1:= X"05910DF17658";C0:= X"07FF77128021";
              Q2:= X"02825B91D5FF";Q1:= X"054F236782C1";Q0:= X"0807EB4C1B15";
              L1:= X"073D73DEBC70";L0:= X"07A8D2871DEC";
      when "01100011" => 
              C3:= X"0094D194B572";C2:= X"01D6930BF9EF";C1:= X"05913C3476F1";C0:= X"07FF711BD8EF";
              Q2:= X"0284196BE2CB";Q1:= X"054DCA90ADCC";Q0:= X"08082DF9BD0C";
              L1:= X"07427A538B1E";L0:= X"07A6E107B6AB";
      when "01100100" => 
              C3:= X"009538E89A20";C2:= X"01D619F56E1C";C1:= X"05916B816BA5";C0:= X"07FF6AF32232";
              Q2:= X"0285D87B5FD5";Q1:= X"054C6D4C64F6";Q0:= X"080872312B35";
              L1:= X"074784454334";L0:= X"07A4E9250F44";
      when "01100101" => 
              C3:= X"0095A0804193";C2:= X"01D59F58A99A";C1:= X"05919BE16F44";C0:= X"07FF64967A3E";
              Q2:= X"028798C1400A";Q1:= X"054B0B9512B8";Q0:= X"0808B7F7ED09";
              L1:= X"074C91B6507C";L0:= X"07A2EAD73960";
      when "01100110" => 
              C3:= X"00960845B320";C2:= X"01D5234E6109";C1:= X"0591CD4DB325";C0:= X"07FF5E061190";
              Q2:= X"02895A3E2972";Q1:= X"0549A5655935";Q0:= X"0808FF538745";
              L1:= X"0751A2A9205F";L0:= X"07A0E6163EBB";
      when "01100111" => 
              C3:= X"0096707401EF";C2:= X"01D4A58E4AF1";C1:= X"0591FFE61EAC";C0:= X"07FF573CEF29";
              Q2:= X"028B1CF30D6C";Q1:= X"05483AB79A33";Q0:= X"08094849939C";
              L1:= X"0756B7202210";L0:= X"079EDADA2113";
      when "01101000" => 
              C3:= X"0096D8D8ACA4";C2:= X"01D42653735C";C1:= X"05923396253C";C0:= X"07FF503D12B9";
              Q2:= X"028CE0E0E116";Q1:= X"0546CB862E7E";Q0:= X"080992DFB612";
              L1:= X"075BCF1DC649";L0:= X"079CC91ADA38";
      when "01101001" => 
              C3:= X"00974181864D";C2:= X"01D3A58BAB22";C1:= X"059268682708";C0:= X"07FF4904582A";
              Q2:= X"028EA608499B";Q1:= X"054557CBAAE4";Q0:= X"0809DF1B8ECD";
              L1:= X"0760EAA47F8F";L0:= X"079AB0D05BED";
      when "01101010" => 
              C3:= X"0097AA94CF5C";C2:= X"01D32305872C";C1:= X"05929E73D463";C0:= X"07FF418EB4C2";
              Q2:= X"02906C6A2D54";Q1:= X"0543DF826A65";Q0:= X"080A2D02D20B";
              L1:= X"076609B6C21B";L0:= X"079891F28FE8";
      when "01101011" => 
              C3:= X"009813BD9F97";C2:= X"01D29F293B03";C1:= X"0592D591040C";C0:= X"07FF39E0F32B";
              Q2:= X"029234078BAA";Q1:= X"054262A4AD96";Q0:= X"080A7C9B4208";
              L1:= X"076B2C5703DB";L0:= X"07966C7957CB";
      when "01101100" => 
              C3:= X"00987D7308FA";C2:= X"01D2195F58F7";C1:= X"05930E025D30";C0:= X"07FF31F0FA12";
              Q2:= X"0293FCE12A26";Q1:= X"0540E12CDFA4";Q0:= X"080ACDEAA0B2";
              L1:= X"07705287BC5D";L0:= X"0794405C8D29";
      when "01101101" => 
              C3:= X"0098E71FDF38";C2:= X"01D192638253";C1:= X"0593477BADB5";C0:= X"07FF29C8BD0E";
              Q2:= X"0295C6F7D8B8";Q1:= X"053F5B155EA1";Q0:= X"080B20F6BB0C";
              L1:= X"07757C4B6503";L0:= X"07920D940165";
      when "01101110" => 
              C3:= X"0099514B2747";C2:= X"01D109879F8D";C1:= X"0593824A427A";C0:= X"07FF215C75F6";
              Q2:= X"0297924C7E98";Q1:= X"053DD0586F96";Q0:= X"080B75C56BF4";
              L1:= X"077AA9A478D1";L0:= X"078FD4177DC3";
      when "01101111" => 
              C3:= X"0099BBA4FD3D";C2:= X"01D07F30D49A";C1:= X"0593BE45EC75";C0:= X"07FF18B1130F";
              Q2:= X"02995EDFE7F6";Q1:= X"053C40F0698E";Q0:= X"080BCC5C92FC";
              L1:= X"077FDA95749D";L0:= X"078D93DEC34B";
      when "01110000" => 
              C3:= X"009A26763BBB";C2:= X"01CFF2FE25FA";C1:= X"0593FB9C2D9A";C0:= X"07FF0FBF2450";
              Q2:= X"029B2CB2F805";Q1:= X"053AACD78AD1";Q0:= X"080C24C21D92";
              L1:= X"07850F20D6CE";L0:= X"078B4CE18AE1";
      when "01110001" => 
              C3:= X"009A916ED4BB";C2:= X"01CF6556AFD3";C1:= X"05943A2345DA";C0:= X"07FF068BE587";
              Q2:= X"029CFBC6BD2F";Q1:= X"05391407E5E9";Q0:= X"080C7EFC0B81";
              L1:= X"078A47491FA8";L0:= X"0788FF178519";
      when "01110010" => 
              C3:= X"009AFCBD2AAF";C2:= X"01CED5FBF015";C1:= X"059479F9C9B5";C0:= X"07FEFD1207BE";
              Q2:= X"029ECC1BBAD8";Q1:= X"0537767C02FC";Q0:= X"080CDB104B3D";
              L1:= X"078F8310D123";L0:= X"0786AA785A47";
      when "01110011" => 
              C3:= X"009B68308D5F";C2:= X"01CE452D64F7";C1:= X"0594BB06A678";C0:= X"07FEF3546AB3";
              Q2:= X"02A09DB3221A";Q1:= X"0535D42DCB26";Q0:= X"080D3904F724";
              L1:= X"0794C27A6EF1";L0:= X"07844EFBAA6E";
      when "01110100" => 
              C3:= X"009BD428EFE8";C2:= X"01CDB267C898";C1:= X"0594FD883C71";C0:= X"07FEE948D408";
              Q2:= X"02A2708DBB8F";Q1:= X"05342D177EC6";Q0:= X"080D98E01EFE";
              L1:= X"079A05887E79";L0:= X"0781EC990D45";
      when "01110101" => 
              C3:= X"009C40447CD6";C2:= X"01CD1E2DECD7";C1:= X"05954146C711";C0:= X"07FEDEF6C6BD";
              Q2:= X"02A444AC421C";Q1:= X"053281336651";Q0:= X"080DFAA7D94F";
              L1:= X"079F4C3D8702";L0:= X"077F83481213";
      when "01110110" => 
              C3:= X"009CACE24B42";C2:= X"01CC87FB8036";C1:= X"059586822D25";C0:= X"07FED4539DDC";
              Q2:= X"02A61A0FBF9A";Q1:= X"0530D07B7D0F";Q0:= X"080E5E6256F4";
              L1:= X"07A4969C1178";L0:= X"077D13003FCA";
      when "01110111" => 
              C3:= X"009D196E54E9";C2:= X"01CBF09C0CBF";C1:= X"0595CCDFAEA0";C0:= X"07FEC96C6E5F";
              Q2:= X"02A7F0B8F61B";Q1:= X"052F1AE9FAC3";Q0:= X"080EC415C3C7";
              L1:= X"07A9E4A6A88B";L0:= X"077A9BB914EF";
      when "01111000" => 
              C3:= X"009D86760559";C2:= X"01CB5749515B";C1:= X"059614BE7C28";C0:= X"07FEBE319AF6";
              Q2:= X"02A9C8A90510";Q1:= X"052D6078BAF3";Q0:= X"080F2BC869F4";
              L1:= X"07AF365FD8B0";L0:= X"07781D6A0790";
      when "01111001" => 
              C3:= X"009DF3EC0837";C2:= X"01CABC12EE34";C1:= X"05965E1B46D6";C0:= X"07FEB2A2A120";
              Q2:= X"02ABA1E08A63";Q1:= X"052BA1220CDE";Q0:= X"080F95808182";
              L1:= X"07B48BCA303E";L0:= X"0775980A8535";
      when "01111010" => 
              C3:= X"009E6186104C";C2:= X"01CA1F607F29";C1:= X"0596A8C879C8";C0:= X"07FEA6C5BF37";
              Q2:= X"02AD7C60954E";Q1:= X"0529DCDFD043";Q0:= X"08100144658B";
              L1:= X"07B9E4E83F21";L0:= X"07730B91F2F8";
      when "01111011" => 
              C3:= X"009ECF81D24F";C2:= X"01C980D85B03";C1:= X"0596F4F41254";C0:= X"07FE9A92B9B6";
              Q2:= X"02AF5829C4ED";Q1:= X"052813AC4A2E";Q0:= X"08106F1A6204";
              L1:= X"07BF41BC9733";L0:= X"077077F7AD57";
      when "01111100" => 
              C3:= X"009F3DB11278";C2:= X"01C8E0BB8211";C1:= X"059742823231";C0:= X"07FE8E0D13C7";
              Q2:= X"02B1353D5089";Q1:= X"0526458128A4";Q0:= X"0810DF08F00A";
              L1:= X"07C4A249CC02";L0:= X"076DDD330847";
      when "01111101" => 
              C3:= X"009FAC2BD407";C2:= X"01C83EE58748";C1:= X"05979187D18D";C0:= X"07FE8130766E";
              Q2:= X"02B3139C09DA";Q1:= X"05247258753E";Q0:= X"081151167BE8";
              L1:= X"07CA069272E6";L0:= X"076B3B3B4F21";
      when "01111110" => 
              C3:= X"00A01AECA88B";C2:= X"01C79B5CD96E";C1:= X"0597E2052111";C0:= X"07FE73FBE328";
              Q2:= X"02B4F346CD34";Q1:= X"05229A2C2A49";Q0:= X"0811C5497E9F";
              L1:= X"07CF6E99231A";L0:= X"07689207C493";
      when "01111111" => 
              C3:= X"00A08A2D0268";C2:= X"01C6F5CA25B6";C1:= X"05983428EF3E";C0:= X"07FE66669E43";
              Q2:= X"02B6D43E7C74";Q1:= X"0520BCF63787";Q0:= X"08123BA87CCE";
              L1:= X"07D4DA607589";L0:= X"0765E18FA2AD";
      when "10000000" => 
              C3:= X"00A0F9A4B2D4";C2:= X"01C64E96630A";C1:= X"059887C2FD80";C0:= X"07FE587791BF";
              Q2:= X"02B8B683EA29";Q1:= X"051EDAB096DA";Q0:= X"0812B43A019A";
              L1:= X"07DA49EB04ED";L0:= X"076329CA1ACE";
      when "10000001" => 
              C3:= X"00A169430677";C2:= X"01C5A5D9E338";C1:= X"0598DCCA1D92";C0:= X"07FE4A2F56B7";
              Q2:= X"02BA9A181104";Q1:= X"051CF35514AA";Q0:= X"08132F04ACB0";
              L1:= X"07DFBD3B6DE2";L0:= X"07606AAE5590";
      when "10000010" => 
              C3:= X"00A1D960D6D5";C2:= X"01C4FB0C6C19";C1:= X"0599338689F1";C0:= X"07FE3B80C0A3";
              Q2:= X"02BC7EFC038A";Q1:= X"051B06DD5F44";Q0:= X"0813AC0F2EB1";
              L1:= X"07E534544EDE";L0:= X"075DA43372CA";
      when "10000011" => 
              C3:= X"00A249A3E82D";C2:= X"01C44EB54E07";C1:= X"05998BB742F0";C0:= X"07FE2C75BD75";
              Q2:= X"02BE65305CC5";Q1:= X"05191543989C";Q0:= X"08142B60242C";
              L1:= X"07EAAF3847F1";L0:= X"075AD65089A2";
      when "10000100" => 
              C3:= X"00A2BA4CEB86";C2:= X"01C3A06FE06C";C1:= X"0599E5931DA6";C0:= X"07FE1D03EEAB";
              Q2:= X"02C04CB655C1";Q1:= X"05171E813C6E";Q0:= X"0814ACFE5D41";
              L1:= X"07F02DE9FB39";L0:= X"075800FCA851";
      when "10000101" => 
              C3:= X"00A32B60A9C7";C2:= X"01C2F031DA02";C1:= X"059A412388D3";C0:= X"07FE0D288B59";
              Q2:= X"02C2358E9415";Q1:= X"05152290580F";Q0:= X"081530F08E16";
              L1:= X"07F5B06C0C7F";L0:= X"0755242ED44A";
      when "10000110" => 
              C3:= X"00A39C7EB946";C2:= X"01C23E9072DC";C1:= X"059A9E1E2F5C";C0:= X"07FDFCEF7016";
              Q2:= X"02C41FBA28E4";Q1:= X"0513216A8484";Q0:= X"0815B73D9226";
              L1:= X"07FB36C12188";L0:= X"07523FDE0A0D";
      when "10000111" => 
              C3:= X"00A40E0D4628";C2:= X"01C18AE9DA19";C1:= X"059AFCDB247C";C0:= X"07FDEC483180";
              Q2:= X"02C60B39EB8E";Q1:= X"05111B09915E";Q0:= X"08163FEC401E";
              L1:= X"0800C0EBE1BA";L0:= X"074F54013D4B";
      when "10001000" => 
              C3:= X"00A47FF86C35";C2:= X"01C0D55B0C0C";C1:= X"059B5D4F172C";C0:= X"07FDDB33A28F";
              Q2:= X"02C7F80EE8DC";Q1:= X"050F0F67103F";Q0:= X"0816CB038876";
              L1:= X"08064EEEF68E";L0:= X"074C608F58A6";
      when "10001001" => 
              C3:= X"00A4F216E3B9";C2:= X"01C01E2412E1";C1:= X"059BBF5B9ACC";C0:= X"07FDC9B60A8B";
              Q2:= X"02C9E639F561";Q1:= X"050CFE7CC89B";Q0:= X"0817588A56E3";
              L1:= X"080BE0CD0B30";L0:= X"0749657F3DD8";
      when "10001010" => 
              C3:= X"00A564766C53";C2:= X"01BF652DB62A";C1:= X"059C23106671";C0:= X"07FDB7CB8B7A";
              Q2:= X"02CBD5BBF499";Q1:= X"050AE8446D0C";Q0:= X"0817E887A603";
              L1:= X"08117688CCAE";L0:= X"074662C7C59A";
      when "10001011" => 
              C3:= X"00A5D75A1650";C2:= X"01BEAA090EBA";C1:= X"059C88AD4367";C0:= X"07FDA5677BA9";
              Q2:= X"02CDC695DC58";Q1:= X"0508CCB796D5";Q0:= X"08187B0280CE";
              L1:= X"08171024E9F7";L0:= X"0743585FBF96";
      when "10001100" => 
              C3:= X"00A64A8A7ECF";C2:= X"01BDED0D944C";C1:= X"059CF006E2EE";C0:= X"07FD9290731D";
              Q2:= X"02CFB8C8AA8D";Q1:= X"0506ABCFD09F";Q0:= X"08191001FFD1";
              L1:= X"081CADA413D9";L0:= X"0740463DF262";
      when "10001101" => 
              C3:= X"00A6BE103DB4";C2:= X"01BD2E2B3C8B";C1:= X"059D5929CEF4";C0:= X"07FD7F42FAB1";
              Q2:= X"02D1AC55268E";Q1:= X"05048586DB46";Q0:= X"0819A78D365E";
              L1:= X"08224F08FCE9";L0:= X"073D2C591B8B";
      when "10001110" => 
              C3:= X"00A731B5EA22";C2:= X"01BC6DB92AEA";C1:= X"059DC3E95AD3";C0:= X"07FD6B862AD5";
              Q2:= X"02D3A13C8B48";Q1:= X"050259D5F2A8";Q0:= X"081A41AB660D";
              L1:= X"0827F45659B8";L0:= X"073A0AA7EF68";
      when "10001111" => 
              C3:= X"00A7A5B009FD";C2:= X"01BBAB5EF5C9";C1:= X"059E3079D699";C0:= X"07FD574F3C3E";
              Q2:= X"02D5977F8C7C";Q1:= X"050028B6E227";Q0:= X"081ADE63B28D";
              L1:= X"082D9D8EE0B6";L0:= X"0736E121192A";
      when "10010000" => 
              C3:= X"00A81A221B5F";C2:= X"01BAE6DE479E";C1:= X"059E9F0264A5";C0:= X"07FD4295963A";
              Q2:= X"02D78F1F1523";Q1:= X"04FDF2233332";Q0:= X"081B7DBD5B52";
              L1:= X"08334AB54A0E";L0:= X"0733AFBB3AE4";
      when "10010001" => 
              C3:= X"00A88EB8EBA0";C2:= X"01BA20C1E4FB";C1:= X"059F0F389A7B";C0:= X"07FD2D65FB32";
              Q2:= X"02D9881C3002";Q1:= X"04FBB6144575";Q0:= X"081C1FBFB561";
              L1:= X"0838FBCC5009";L0:= X"0730766CED4D";
      when "10010010" => 
              C3:= X"00A903AC97AF";C2:= X"01B958A90B6B";C1:= X"059F8156CEC5";C0:= X"07FD17B43887";
              Q2:= X"02DB8277D629";Q1:= X"04F974838694";Q0:= X"081CC4721BB5";
              L1:= X"083EB0D6AEAC";L0:= X"072D352CBFF3";
      when "10010011" => 
              C3:= X"00A978D6D1AA";C2:= X"01B88ED3AC8E";C1:= X"059FF53C2E41";C0:= X"07FD01855559";
              Q2:= X"02DD7E3301EB";Q1:= X"04F72D6A5CB9";Q0:= X"081D6BDBF557";
              L1:= X"084469D723EE";L0:= X"0729EBF1390D";
      when "10010100" => 
              C3:= X"00A9EEA4F8E3";C2:= X"01B7C28264EC";C1:= X"05A06B5B14F5";C0:= X"07FCEAC20CB1";
              Q2:= X"02DF7B4E7D96";Q1:= X"04F4E0C25FF5";Q0:= X"081E1604A4B9";
              L1:= X"084A26D06FA8";L0:= X"07269AB0D586";
      when "10010101" => 
              C3:= X"00AA64B7B05C";C2:= X"01B6F4578A63";C1:= X"05A0E35A30B6";C0:= X"07FCD37A2D72";
              Q2:= X"02E179CB5E00";Q1:= X"04F28E84CCDF";Q0:= X"081EC2F3B084";
              L1:= X"084FE7C553B1";L0:= X"0723416208DE";
      when "10010110" => 
              C3:= X"00AADAF7AE40";C2:= X"01B6247AD1CA";C1:= X"05A15D25B8ED";C0:= X"07FCBBB05F69";
              Q2:= X"02E379AA8E72";Q1:= X"04F036AB0A24";Q0:= X"081F72B09D3C";
              L1:= X"0855ACB8939C";L0:= X"071FDFFB3D4D";
      when "10010111" => 
              C3:= X"00AB51819281";C2:= X"01B552B88CA1";C1:= X"05A1D8DF88C8";C0:= X"07FCA35CC85B";
              Q2:= X"02E57AED0B95";Q1:= X"04EDD92E646B";Q0:= X"0820254300FA";
              L1:= X"085B75ACF522";L0:= X"071C7672D37A";
      when "10011000" => 
              C3:= X"00ABC8656AFD";C2:= X"01B47EF2A168";C1:= X"05A2569D27B3";C0:= X"07FC8A79E2D9";
              Q2:= X"02E77D93D3CC";Q1:= X"04EB7608205E";Q0:= X"0820DAB27E40";
              L1:= X"086142A53FB7";L0:= X"071904BF22B5";
      when "10011001" => 
              C3:= X"00AC3FAB4F1D";C2:= X"01B3A9181C20";C1:= X"05A2D66CF215";C0:= X"07FC71037075";
              Q2:= X"02E9819FCE52";Q1:= X"04E90D31986B";Q0:= X"08219306BB29";
              L1:= X"086713A43CD5";L0:= X"07158AD678C2";
      when "10011010" => 
              C3:= X"00ACB72C1C09";C2:= X"01B2D16D9665";C1:= X"05A35829A371";C0:= X"07FC56FF9108";
              Q2:= X"02EB8711E68C";Q1:= X"04E69EA41C94";Q0:= X"08224E476AE8";
              L1:= X"086CE8ACB7E4";L0:= X"071208AF19E0";
      when "10011011" => 
              C3:= X"00AD2F26AB3A";C2:= X"01B1F77F3FAD";C1:= X"05A3DC1D2535";C0:= X"07FC3C5E08BD";
              Q2:= X"02ED8DEB2650";Q1:= X"04E42A58D2A2";Q0:= X"08230C7C5774";
              L1:= X"0872C1C17E3B";L0:= X"070E7E3F40BE";
      when "10011100" => 
              C3:= X"00ADA7333478";C2:= X"01B11C0822D6";C1:= X"05A461D9EA3A";C0:= X"07FC2133A3A0";
              Q2:= X"02EF962CA277";Q1:= X"04E1B048CC73";Q0:= X"0823CDAD5B33";
              L1:= X"08789EE55F10";L0:= X"070AEB7D1E81";
      when "10011101" => 
              C3:= X"00AE1FBBEB3F";C2:= X"01B03E44C65B";C1:= X"05A4E9DAB039";C0:= X"07FC0566244D";
              Q2:= X"02F19FD70CB1";Q1:= X"04DF306D8F11";Q0:= X"082491E23799";
              L1:= X"087E801B2BBC";L0:= X"0707505EDA90";
      when "10011110" => 
              C3:= X"00AE98C0A7BC";C2:= X"01AF5E31DFA5";C1:= X"05A5742680A8";C0:= X"07FBE8F2800C";
              Q2:= X"02F3AAEBA940";Q1:= X"04DCAABFE6BF";Q0:= X"08255922F0C4";
              L1:= X"08846565B74E";L0:= X"0703ACDA92D1";
      when "10011111" => 
              C3:= X"00AF11B4B045";C2:= X"01AE7CD32060";C1:= X"05A60020718A";C0:= X"07FBCBF7B8AA";
              Q2:= X"02F5B76B5DB9";Q1:= X"04DA1F390D33";Q0:= X"0826237773CC";
              L1:= X"088A4EC7D6FE";L0:= X"070000E65B56";
      when "10100000" => 
              C3:= X"00AF8B4F0B81";C2:= X"01AD98D1E3CE";C1:= X"05A68EA12BA8";C0:= X"07FBAE4790BA";
              Q2:= X"02F7C55718C6";Q1:= X"04D78DD22BD1";Q0:= X"0826F0E7BCEC";
              L1:= X"08903C4461E8";L0:= X"06FC4C783E88";
      when "10100001" => 
              C3:= X"00B0053AA042";C2:= X"01ACB2CA5A67";C1:= X"05A71F4C044F";C0:= X"07FB8FF3B6A2";
              Q2:= X"02F9D4AFC026";Q1:= X"04D4F68471A2";Q0:= X"0827C17BD0D7";
              L1:= X"08962DDE3116";L0:= X"06F88F863D0F";
      when "10100010" => 
              C3:= X"00B07F769D66";C2:= X"01ABCABC2538";C1:= X"05A7B22547A7";C0:= X"07FB70F9D00E";
              Q2:= X"02FBE5767C4A";Q1:= X"04D25948B3D0";Q0:= X"0828953BDAF3";
              L1:= X"089C23981FA1";L0:= X"06F4CA064DBE";
      when "10100011" => 
              C3:= X"00B0F9E62F8B";C2:= X"01AAE0DCCC79";C1:= X"05A8470EB3D1";C0:= X"07FB515EE0D0";
              Q2:= X"02FDF7AC574D";Q1:= X"04CFB617E709";Q0:= X"08296C300765";
              L1:= X"08A21D750A86";L0:= X"06F0FBEE5D9F";
      when "10100100" => 
              C3:= X"00B174BD2395";C2:= X"01A9F4C7781C";C1:= X"05A8DE4C92D0";C0:= X"07FB3112F0D2";
              Q2:= X"03000B52198F";Q1:= X"04CD0CEB4E04";Q0:= X"082A466073E7";
              L1:= X"08A81B77D0E9";L0:= X"06ED25344FC9";
      when "10100101" => 
              C3:= X"00B1EFDBB179";C2:= X"01A906B75513";C1:= X"05A977BD145B";C0:= X"07FB101BBB6F";
              Q2:= X"03022068FBC9";Q1:= X"04CA5DBB9612";Q0:= X"082B23D57866";
              L1:= X"08AE1DA353B3";L0:= X"06E945CDFD8C";
      when "10100110" => 
              C3:= X"00B26B7763B3";C2:= X"01A816425259";C1:= X"05AA13A91BC6";C0:= X"07FAEE680020";
              Q2:= X"030436F1BA21";Q1:= X"04C7A88206C8";Q0:= X"082C049745C2";
              L1:= X"08B423FA75E4";L0:= X"06E55DB1363F";
      when "10100111" => 
              C3:= X"00B2E75CF7CA";C2:= X"01A723C97EC8";C1:= X"05AAB1D658A1";C0:= X"07FACC02B97E";
              Q2:= X"03064EED9417";Q1:= X"04C4ED3737D4";Q0:= X"082CE8AE5060";
              L1:= X"08BA2E801C9F";L0:= X"06E16CD3BF28";
      when "10101000" => 
              C3:= X"00B36364C7C2";C2:= X"01A62F99DE5F";C1:= X"05AB5215D4E5";C0:= X"07FAA8F4C58A";
              Q2:= X"0308685D608E";Q1:= X"04C22BD442BE";Q0:= X"082DD022ED1D";
              L1:= X"08C03D372ED3";L0:= X"06DD732B53B1";
      when "10101001" => 
              C3:= X"00B3DFF01041";C2:= X"01A538F1EA7F";C1:= X"05ABF4EAD898";C0:= X"07FA851FD9FA";
              Q2:= X"030A834247DF";Q1:= X"04BF6451D068";Q0:= X"082EBAFDA065";
              L1:= X"08C65022959A";L0:= X"06D970ADA521";
      when "10101010" => 
              C3:= X"00B45CA2E78B";C2:= X"01A44085A4FC";C1:= X"05AC99E2CE35";C0:= X"07FA609B9A45";
              Q2:= X"030C9F9D2E27";Q1:= X"04BC96A8DD86";Q0:= X"082FA946DDC8";
              L1:= X"08CC67453BF9";L0:= X"06D565505ABE";
      when "10101011" => 
              C3:= X"00B4D9F7BD15";C2:= X"01A3455EC2A9";C1:= X"05AD41A5C57F";C0:= X"07FA3B412DA6";
              Q2:= X"030EBD6F1521";Q1:= X"04B9C2D239D4";Q0:= X"08309B073262";
              L1:= X"08D282A20F20";L0:= X"06D15109119A";
      when "10101100" => 
              C3:= X"00B55769B1BE";C2:= X"01A24884FED8";C1:= X"05ADEB88335D";C0:= X"07FA1535179D";
              Q2:= X"0310DCB919D6";Q1:= X"04B6E8C68A3F";Q0:= X"083190474480";
              L1:= X"08D8A23BFE14";L0:= X"06CD33CD5CC2";
      when "10101101" => 
              C3:= X"00B5D5656A33";C2:= X"01A1491B97E9";C1:= X"05AE98228D5D";C0:= X"07F9EE539CE2";
              Q2:= X"0312FD7C421C";Q1:= X"04B4087E8C67";Q0:= X"0832890FBD1E";
              L1:= X"08DEC615FA00";L0:= X"06C90D92C505";
      when "10101110" => 
              C3:= X"00B653958F49";C2:= X"01A047CD258E";C1:= X"05AF47062112";C0:= X"07F9C6B3FA6A";
              Q2:= X"03151FB9800C";Q1:= X"04B121F31299";Q0:= X"083385694916";
              L1:= X"08E4EE32F62A";L0:= X"06C4DE4EC8F0";
      when "10101111" => 
              C3:= X"00B6D1F351F7";C2:= X"019F44A6F70F";C1:= X"05AFF82D3B2D";C0:= X"07F99E560D50";
              Q2:= X"03174371E23A";Q1:= X"04AE351CC294";Q0:= X"0834855CAF3A";
              L1:= X"08EB1A95E7C7";L0:= X"06C0A5F6DCE3";
      when "10110000" => 
              C3:= X"00B750F8403B";C2:= X"019E3EACEA0C";C1:= X"05B0AC492154";C0:= X"07F9750FA50E";
              Q2:= X"031968A6610F";Q1:= X"04AB41F45A41";Q0:= X"083588F2B919";
              L1:= X"08F14B41C61A";L0:= X"06BC64806AF4";
      when "10110001" => 
              C3:= X"00B7D0169B70";C2:= X"019D370127F8";C1:= X"05B16296CFCD";C0:= X"07F94B0BBE02";
              Q2:= X"031B8F5835F5";Q1:= X"04A8487237B2";Q0:= X"083690345C4B";
              L1:= X"08F780398A8B";L0:= X"06B819E0D2DA";
      when "10110010" => 
              C3:= X"00B84FBA8305";C2:= X"019C2CC17247";C1:= X"05B21BB70D56";C0:= X"07F9202399A3";
              Q2:= X"031DB7881EAA";Q1:= X"04A5488F5DC3";Q0:= X"08379B2A6087";
              L1:= X"08FDB9803079";L0:= X"06B3C60D6A00";
      when "10110011" => 
              C3:= X"00B8CFDEB567";C2:= X"019B1FF550C1";C1:= X"05B2D7A9FF68";C0:= X"07F8F4553E33";
              Q2:= X"031FE1376029";Q1:= X"04A242440DA8";Q0:= X"0838A9DDDBBB";
              L1:= X"0903F718B581";L0:= X"06AF68FB7B4D";
      when "10110100" => 
              C3:= X"00B950220A3B";C2:= X"019A1166CBDA";C1:= X"05B395E69FBC";C0:= X"07F8C7BEEB48";
              Q2:= X"03220C66DC4E";Q1:= X"049F35890C76";Q0:= X"0839BC57C10D";
              L1:= X"090A3906191F";L0:= X"06AB02A04761";
      when "10110101" => 
              C3:= X"00B9D0C0BD8C";C2:= X"01990095C829";C1:= X"05B456CAC15A";C0:= X"07F89A490DD2";
              Q2:= X"03243917ABCE";Q1:= X"049C2256CC5B";Q0:= X"083AD2A12BCC";
              L1:= X"09107F4B5CF3";L0:= X"06A692F10457";
      when "10110110" => 
              C3:= X"00BA51886C75";C2:= X"0197EDEBC908";C1:= X"05B51A0FC2DE";C0:= X"07F86C02A61E";
              Q2:= X"0326674AF998";Q1:= X"049908A59EEF";Q0:= X"083BECC34E3D";
              L1:= X"0916C9EB84CB";L0:= X"06A219E2DDBC";
      when "10110111" => 
              C3:= X"00BAD2F5BFA0";C2:= X"0196D85C58B5";C1:= X"05B5E0795C48";C0:= X"07F83CBB745D";
              Q2:= X"03289701A531";Q1:= X"0495E86E3AA4";Q0:= X"083D0AC74219";
              L1:= X"091D18E9967D";L0:= X"069D976AF49A";
      when "10111000" => 
              C3:= X"00BB548F2594";C2:= X"0195C0E98552";C1:= X"05B6A9540198";C0:= X"07F80C9C5C06";
              Q2:= X"032AC83CF600";Q1:= X"0492C1A8BB4B";Q0:= X"083E2CB663A0";
              L1:= X"09236C4899DC";L0:= X"06990B7E5F7F";
      when "10111001" => 
              C3:= X"00BBD664A863";C2:= X"0194A76FDA46";C1:= X"05B774BCD84A";C0:= X"07F7DB9CC687";
              Q2:= X"032CFAFDB688";Q1:= X"048F944DE98C";Q0:= X"083F5299DC71";
              L1:= X"0929C40B9912";L0:= X"069476122A2E";
      when "10111010" => 
              C3:= X"00BC59085AE1";C2:= X"01938AAF4563";C1:= X"05B843A0ACDA";C0:= X"07F7A9819A40";
              Q2:= X"032F2F44FD25";Q1:= X"048C60561B54";Q0:= X"08407C7B0A9A";
              L1:= X"09302035A029";L0:= X"068FD71B55F0";
      when "10111011" => 
              C3:= X"00BCDBDEAA1B";C2:= X"01926BF74482";C1:= X"05B915116C38";C0:= X"07F776826202";
              Q2:= X"03316513F86C";Q1:= X"048925B97C83";Q0:= X"0841AA63670E";
              L1:= X"093680C9BD70";L0:= X"068B2E8ED942";
      when "10111100" => 
              C3:= X"00BD5EC773AF";C2:= X"01914B8E2172";C1:= X"05B9E8DEE88B";C0:= X"07F742A95472";
              Q2:= X"03339C6BC22E";Q1:= X"0485E4705051";Q0:= X"0842DC5C6DF4";
              L1:= X"093CE5CB0143";L0:= X"06867C619FF4";
      when "10111101" => 
              C3:= X"00BDE2308C7A";C2:= X"019028807182";C1:= X"05BABFC005D5";C0:= X"07F70DC7E911";
              Q2:= X"0335D54D3DE5";Q1:= X"04829C732388";Q0:= X"0844126F8BEB";
              L1:= X"09434F3C7E1F";L0:= X"0681C0888B12";
      when "10111110" => 
              C3:= X"00BE65DFF3E0";C2:= X"018F034C2A43";C1:= X"05BB995CB216";C0:= X"07F6D7F1D498";
              Q2:= X"03380FB981DD";Q1:= X"047F4DBA327F";Q0:= X"08454CA6567A";
              L1:= X"0949BD2148C3";L0:= X"067CFAF870C4";
      when "10111111" => 
              C3:= X"00BEEA1EF508";C2:= X"018DDB4B6581";C1:= X"05BC76352749";C0:= X"07F6A1055779";
              Q2:= X"033A4BB1DA48";Q1:= X"047BF83D6240";Q0:= X"08468B0A8F80";
              L1:= X"09502F7C77D4";L0:= X"06782BA61C8A";
      when "11000000" => 
              C3:= X"00BF6EDE8DC4";C2:= X"018CB09C13C1";C1:= X"05BD5638E31F";C0:= X"07F669045425";
              Q2:= X"033C89371FAF";Q1:= X"04789BF53D9C";Q0:= X"0847CDA5C6D6";
              L1:= X"0956A6512448";L0:= X"067352864EE0";
      when "11000001" => 
              C3:= X"00BFF3CC29AF";C2:= X"018B83F604B7";C1:= X"05BE38E2A590";C0:= X"07F6300E2C67";
              Q2:= X"033EC84A828A";Q1:= X"047538D9C5D4";Q0:= X"08491481CB53";
              L1:= X"095D21A26931";L0:= X"066E6F8DBD66";
      when "11000010" => 
              C3:= X"00C078D4CF43";C2:= X"018A5583EA41";C1:= X"05BF1E1586E3";C0:= X"07F5F6288821";
              Q2:= X"034108ECF92A";Q1:= X"0471CEE34D26";Q0:= X"084A5FA8591F";
              L1:= X"0963A17363C0";L0:= X"066982B112CA";
      when "11000011" => 
              C3:= X"00C0FE69DB49";C2:= X"018924422C98";C1:= X"05C0069AC99B";C0:= X"07F5BB1EA162";
              Q2:= X"03434B1FBFBB";Q1:= X"046E5E09B59C";Q0:= X"084BAF2362A1";
              L1:= X"096A25C7336C";L0:= X"06648BE4EEA9";
      when "11000100" => 
              C3:= X"00C18471ADD2";C2:= X"0187F0680046";C1:= X"05C0F24E0F0D";C0:= X"07F57EF77797";
              Q2:= X"03458EE3CF3D";Q1:= X"046AE645409A";Q0:= X"084D02FCC1F8";
              L1:= X"0970AEA0F9BD";L0:= X"065F8B1DE5AC";
      when "11000101" => 
              C3:= X"00C20AC597B6";C2:= X"0186BA4BE9DC";C1:= X"05C1E0F20746";C0:= X"07F541C0A15D";
              Q2:= X"0347D43A3750";Q1:= X"0467678E0701";Q0:= X"084E5B3E6C6B";
              L1:= X"09773C03DA5B";L0:= X"065A80508176";
      when "11000110" => 
              C3:= X"00C291654CA8";C2:= X"018581ED044A";C1:= X"05C2D28BC0AD";C0:= X"07F50376E506";
              Q2:= X"034A1B24301B";Q1:= X"0463E1DBDCA5";Q0:= X"084FB7F27DCA";
              L1:= X"097DCDF2FB3E";L0:= X"06556B714075";
      when "11000111" => 
              C3:= X"00C31878EF6A";C2:= X"018446EBE899";C1:= X"05C3C769EFA0";C0:= X"07F4C403E327";
              Q2:= X"034C63A2B34B";Q1:= X"04605526EF06";Q0:= X"08511922FB5E";
              L1:= X"098464718474";L0:= X"06504C749605";
      when "11001000" => 
              C3:= X"00C39FBBE594";C2:= X"018309E709E3";C1:= X"05C4BF15C298";C0:= X"07F48384733F";
              Q2:= X"034EADB70D6D";Q1:= X"045CC166E453";Q0:= X"08527EDA2B06";
              L1:= X"098AFF82A05B";L0:= X"064B234EEA3A";
      when "11001001" => 
              C3:= X"00C427C5C22F";C2:= X"0181C9777BE1";C1:= X"05C5BAADADFB";C0:= X"07F441AB9557";
              Q2:= X"0350F961F913";Q1:= X"045926944035";Q0:= X"0853E922082E";
              L1:= X"09919F297B53";L0:= X"0645EFF49A1A";
      when "11001010" => 
              C3:= X"00C4AFE9731D";C2:= X"01808732797A";C1:= X"05C6B8F89EA5";C0:= X"07F3FEC90ECC";
              Q2:= X"035346A4EE82";Q1:= X"045584A656C7";Q0:= X"085558051131";
              L1:= X"09984369441A";L0:= X"0640B259F743";
      when "11001011" => 
              C3:= X"00C53864977F";C2:= X"017F428500A4";C1:= X"05C7BA6EAC11";C0:= X"07F3BABB5EAD";
              Q2:= X"03559580D519";Q1:= X"0451DB9558C0";Q0:= X"0856CB8D7A15";
              L1:= X"099EEC452B8E";L0:= X"063B6A73481A";
      when "11001100" => 
              C3:= X"00C5C109B4AA";C2:= X"017DFBDA2428";C1:= X"05C8BEBF02B5";C0:= X"07F37595F614";
              Q2:= X"0357E5F6EA92";Q1:= X"044E2B58E7FB";Q0:= X"085843C5BB75";
              L1:= X"09A599C064C5";L0:= X"06361834C7AB";
      when "11001101" => 
              C3:= X"00C64A88F365";C2:= X"017CB1894CF0";C1:= X"05C9C741F25D";C0:= X"07F32EFAEFD5";
              Q2:= X"035A380818A8";Q1:= X"044A73E92582";Q0:= X"0859C0B8277C";
              L1:= X"09AC4BDE2515";L0:= X"0630BB92A59D";
      when "11001110" => 
              C3:= X"00C6D3F6E741";C2:= X"017B65C5ACD6";C1:= X"05CAD239987A";C0:= X"07F2E75F1823";
              Q2:= X"035C8BB5AC95";Q1:= X"0446B53D8CAB";Q0:= X"085B426F5EDB";
              L1:= X"09B302A1A418";L0:= X"062B54810624";
      when "11001111" => 
              C3:= X"00C75E1845CB";C2:= X"017A16B2BA5C";C1:= X"05CBE129FE69";C0:= X"07F29E5841FC";
              Q2:= X"035EE100B705";Q1:= X"0442EF4DF2D4";Q0:= X"085CC8F5EAAF";
              L1:= X"09B9BE0E1B8B";L0:= X"0625E2F40212";
      when "11010000" => 
              C3:= X"00C7E89B932C";C2:= X"0178C5124327";C1:= X"05CCF37CC99F";C0:= X"07F2540C5E21";
              Q2:= X"036137EA6457";Q1:= X"043F2211FA01";Q0:= X"085E5456752A";
              L1:= X"09C07E26C777";L0:= X"062066DFA6B0";
      when "11010001" => 
              C3:= X"00C873113972";C2:= X"017771F3EE2C";C1:= X"05CE0858C69C";C0:= X"07F208B46B4F";
              Q2:= X"03639073BB3C";Q1:= X"043B4D817AA8";Q0:= X"085FE49B9ED7";
              L1:= X"09C742EEE620";L0:= X"061AE037F5BD";
      when "11010010" => 
              C3:= X"00C8FE3D73CB";C2:= X"01761B752F2E";C1:= X"05CF214CBEE5";C0:= X"07F1BBE1B01D";
              Q2:= X"0365EA9DD61E";Q1:= X"0437719426E7";Q0:= X"086179D02423";
              L1:= X"09CE0C69B80C";L0:= X"06154EF0E568";
      when "11010011" => 
              C3:= X"00C9899D34D3";C2:= X"0174C2D5C650";C1:= X"05D03D57EAB4";C0:= X"07F16DD7FD9B";
              Q2:= X"03684669E6B9";Q1:= X"04338E4183C1";Q0:= X"086313FEE08B";
              L1:= X"09D4DA9A7FFD";L0:= X"060FB2FE6043";
      when "11010100" => 
              C3:= X"00CA159912A8";C2:= X"0173671071AB";C1:= X"05D15D5713C3";C0:= X"07F11E58456C";
              Q2:= X"036AA3D90D82";Q1:= X"042FA3812B9C";Q0:= X"0864B332B372";
              L1:= X"09DBAD848306";L0:= X"060A0C54452F";
      when "11010101" => 
              C3:= X"00CAA20A269A";C2:= X"01720882078F";C1:= X"05D28103C86E";C0:= X"07F0CD734AAF";
              Q2:= X"036D02EC5FF4";Q1:= X"042BB14AC46A";Q0:= X"086657768401";
              L1:= X"09E2852B087A";L0:= X"06045AE6675D";
      when "11010110" => 
              C3:= X"00CB2EB471A0";C2:= X"0170A7BE98FE";C1:= X"05D3A7E789D1";C0:= X"07F07B47B2FA";
              Q2:= X"036F63A53787";Q1:= X"0427B7957BD8";Q0:= X"086800D57835";
              L1:= X"09E9619159E8";L0:= X"05FE9EA88E4A";
      when "11010111" => 
              C3:= X"00CBBB842047";C2:= X"016F44F756F5";C1:= X"05D4D1DCF562";C0:= X"07F027DDF398";
              Q2:= X"0371C6047915";Q1:= X"0423B6593B4E";Q0:= X"0869AF5A7478";
              L1:= X"09F042BAC328";L0:= X"05F8D78E75AC";
      when "11011000" => 
              C3:= X"00CC48EE4EB9";C2:= X"016DDF02D4BE";C1:= X"05D5FFE31E5A";C0:= X"07EFD2EC3CD8";
              Q2:= X"03742A0B6430";Q1:= X"041FAD8D4DFF";Q0:= X"086B6310ABFC";
              L1:= X"09F728AA926B";L0:= X"05F3058BCD5A";
      when "11011001" => 
              C3:= X"00CCD6DBA845";C2:= X"016C761849A0";C1:= X"05D731D1FBFD";C0:= X"07EF7C7B0AA7";
              Q2:= X"03768FBB33E8";Q1:= X"041B9D28FEF0";Q0:= X"086D1C035F38";
              L1:= X"09FE13641832";L0:= X"05ED2894394A";
      when "11011010" => 
              C3:= X"00CD6512B0B5";C2:= X"016B0AC77D83";C1:= X"05D867350AA2";C0:= X"07EF24A8D466";
              Q2:= X"0378F714B5A8";Q1:= X"041785244D05";Q0:= X"086EDA3D8EE6";
              L1:= X"0A0502EAA71E";L0:= X"05E7409B51B2";
      when "11011011" => 
              C3:= X"00CDF38E0BB7";C2:= X"01699D1CA083";C1:= X"05D9A00687D6";C0:= X"07EECB74FA84";
              Q2:= X"037B60198D64";Q1:= X"04136575C2D0";Q0:= X"08709DCAE72F";
              L1:= X"0A0BF7419447";L0:= X"05E14D94A2B5";
      when "11011100" => 
              C3:= X"00CE827DADC2";C2:= X"01682C9AD75D";C1:= X"05DADCB62107";C0:= X"07EE70BD4D7A";
              Q2:= X"037DCACA8829";Q1:= X"040F3E155284";Q0:= X"087266B687E0";
              L1:= X"0A12F06C3712";L0:= X"05DB4F73AC7A";
      when "11011101" => 
              C3:= X"00CF11F11D02";C2:= X"0166B916AF2A";C1:= X"05DC1D6F7837";C0:= X"07EE14728A4C";
              Q2:= X"038037290423";Q1:= X"040B0EF9EF1C";Q0:= X"0874350C0AED";
              L1:= X"0A19EE6DE93D";L0:= X"05D5462BE31D";
      when "11011110" => 
              C3:= X"00CFA1ABDE18";C2:= X"0165432A6E1C";C1:= X"05DD61B2C631";C0:= X"07EDB6B6F02B";
              Q2:= X"0382A5362343";Q1:= X"0406D81AEB6D";Q0:= X"087608D6EE81";
              L1:= X"0A20F14A06C3";L0:= X"05CF31B0AEBC";
      when "11011111" => 
              C3:= X"00D031B03E92";C2:= X"0163CACEBEBB";C1:= X"05DEA98AEF86";C0:= X"07ED57851049";
              Q2:= X"038514F2D8DD";Q1:= X"0402996FE538";Q0:= X"0877E2229CED";
              L1:= X"0A27F903EDDF";L0:= X"05C911F56B69";
      when "11100000" => 
              C3:= X"00D0C22F3964";C2:= X"01624F817A05";C1:= X"05DFF56E942C";C0:= X"07ECF6B7F7CC";
              Q2:= X"03878660A7A9";Q1:= X"03FE52EF7956";Q0:= X"0879C0FAFD99";
              L1:= X"0A2F059EFF63";L0:= X"05C2E6ED68DC";
      when "11100001" => 
              C3:= X"00D15318119D";C2:= X"0160D16B614F";C1:= X"05E14540364D";C0:= X"07EC9455775A";
              Q2:= X"0389F98074B2";Q1:= X"03FA049150B3";Q0:= X"087BA56B9037";
              L1:= X"0A36171E9E4E";L0:= X"05BCB08BEABC";
      when "11100010" => 
              C3:= X"00D1E45E85CB";C2:= X"015F50AAC071";C1:= X"05E298EA60F5";C0:= X"07EC306155A9";
              Q2:= X"038C6E539575";Q1:= X"03F5AE4C4886";Q0:= X"087D8F803AD2";
              L1:= X"0A3D2D863000";L0:= X"05B66EC4286F";
      when "11100011" => 
              C3:= X"00D2760AF0D5";C2:= X"015DCD26F77A";C1:= X"05E3F0886D68";C0:= X"07EBCAD0DF50";
              Q2:= X"038EE4DB2BF0";Q1:= X"03F150179113";Q0:= X"087F7F44CC72";
              L1:= X"0A4448D91C2B";L0:= X"05B021894D1C";
      when "11100100" => 
              C3:= X"00D308453ADB";C2:= X"015C4672F823";C1:= X"05E54C810C13";C0:= X"07EB6382F27B";
              Q2:= X"03915D1876FC";Q1:= X"03ECE9EA209D";Q0:= X"088174C53B18";
              L1:= X"0A4B691ACD00";L0:= X"05A9C8CE777D";
      when "11100101" => 
              C3:= X"00D39AA0004C";C2:= X"015ABDB123D6";C1:= X"05E6ABD6B9CD";C0:= X"07EAFAC049DB";
              Q2:= X"0393D70C6C46";Q1:= X"03E87BBB68C1";Q0:= X"0883700D5330";
              L1:= X"0A528E4EAEE9";L0:= X"05A36486BA0B";
      when "11100110" => 
              C3:= X"00D42D617FB3";C2:= X"01593223A6FB";C1:= X"05E80F37E16E";C0:= X"07EA90527D9E";
              Q2:= X"039652B87349";Q1:= X"03E405820919";Q0:= X"088571294C3A";
              L1:= X"0A59B87830B9";L0:= X"059CF4A51AD3";
      when "11100111" => 
              C3:= X"00D4C0B7D938";C2:= X"0157A34AFFF9";C1:= X"05E9771D5E34";C0:= X"07EA2412715F";
              Q2:= X"0398D01DCFF8";Q1:= X"03DF8734D890";Q0:= X"0887782552F9";
              L1:= X"0A60E79AC3B0";L0:= X"0596791C9364";
      when "11101000" => 
              C3:= X"00D5548209E2";C2:= X"0156117D3CA1";C1:= X"05EAE33FF9D0";C0:= X"07E9B61296ED";
              Q2:= X"039B4F3D67E5";Q1:= X"03DB00CB51BF";Q0:= X"0889850D57AD";
              L1:= X"0A681BB9DB6A";L0:= X"058FF1E010D7";
      when "11101001" => 
              C3:= X"00D5E864692E";C2:= X"01547DB20F94";C1:= X"05EC52C40BB6";C0:= X"07E94692C90A";
              Q2:= X"039DD018C70F";Q1:= X"03D6723BBAE0";Q0:= X"088B97EDE3BB";
              L1:= X"0A6F54D8EE00";L0:= X"05895EE273A5";
      when "11101010" => 
              C3:= X"00D67CFE5B53";C2:= X"0152E633E23D";C1:= X"05EDC73D7CE5";C0:= X"07E8D515B9B1";
              Q2:= X"03A052B0CB82";Q1:= X"03D1DB7D8EEB";Q0:= X"088DB0D301FE";
              L1:= X"0A7692FB73C1";L0:= X"0582C0168FE0";
      when "11101011" => 
              C3:= X"00D711D9EDF0";C2:= X"01514C430630";C1:= X"05EF3F8DD593";C0:= X"07E861EFB4EB";
              Q2:= X"03A2D706E86C";Q1:= X"03CD3C8731E9";Q0:= X"088FCFC94A15";
              L1:= X"0A7DD624E789";L0:= X"057C156F2CD9";
      when "11101100" => 
              C3:= X"00D7A7479F56";C2:= X"014FAEFF4E6C";C1:= X"05F0BC88AA74";C0:= X"07E7ECDD252A";
              Q2:= X"03A55D1C5276";Q1:= X"03C8954F7233";Q0:= X"0891F4DD312B";
              L1:= X"0A851E58C691";L0:= X"05755EDF0543";
      when "11101101" => 
              C3:= X"00D83CF1B305";C2:= X"014E0F53660A";C1:= X"05F23D5B671F";C0:= X"07E7761BE7F4";
              Q2:= X"03A7E4F203B5";Q1:= X"03C3E5CD83AB";Q0:= X"0894201B0B10";
              L1:= X"0A8C6B9A9091";L0:= X"056E9C58C70C";
      when "11101110" => 
              C3:= X"00D8D2EE5271";C2:= X"014C6D00909D";C1:= X"05F3C244BAE3";C0:= X"07E6FD96243D";
              Q2:= X"03AA6E8978B5";Q1:= X"03BF2DF7A19E";Q0:= X"0896518FAC61";
              L1:= X"0A93BDEDC78C";L0:= X"0567CDCF137E";
      when "11101111" => 
              C3:= X"00D96934294C";C2:= X"014AC81EDAF9";C1:= X"05F54B33A1A8";C0:= X"07E6834E617D";
              Q2:= X"03ACF9E3D4B6";Q1:= X"03BA6DC4A51D";Q0:= X"08988947AEC9";
              L1:= X"0A9B1555F01A";L0:= X"0560F3347EF4";
      when "11110000" => 
              C3:= X"00DA0042037C";C2:= X"01491F483317";C1:= X"05F6D97CABAD";C0:= X"07E606D797AD";
              Q2:= X"03AF87024183";Q1:= X"03B5A52B541B";Q0:= X"089AC74FC29E";
              L1:= X"0AA271D69130";L0:= X"055A0C7B9106";
      when "11110001" => 
              C3:= X"00DA977E5D92";C2:= X"01477428CFA5";C1:= X"05F86B953F94";C0:= X"07E588A9D845";
              Q2:= X"03B215E5F2A2";Q1:= X"03B0D4225B6E";Q0:= X"089D0BB4B1D1";
              L1:= X"0AA9D3733432";L0:= X"05531996C46C";
      when "11110010" => 
              C3:= X"00DB2F6B9115";C2:= X"0145C54DF598";C1:= X"05FA02E05F19";C0:= X"07E50852BCD1";
              Q2:= X"03B4A6902BB2";Q1:= X"03ABFAA0423B";Q0:= X"089F5683661F";
              L1:= X"0AB13A2F6507";L0:= X"054C1A7886DF";
      when "11110011" => 
              C3:= X"00DBC790D101";C2:= X"0144140B7DE7";C1:= X"05FB9E22EBEF";C0:= X"07E48632824E";
              Q2:= X"03B739023A49";Q1:= X"03A7189B7518";Q0:= X"08A1A7C8E421";
              L1:= X"0AB8A60EB1F4";L0:= X"05450F13393C";
      when "11110100" => 
              C3:= X"00DC5FA2D598";C2:= X"01426138475D";C1:= X"05FD3C940665";C0:= X"07E402869D72";
              Q2:= X"03B9CD3D54F8";Q1:= X"03A22E0A848D";Q0:= X"08A3FF922DB8";
              L1:= X"0AC01714ABDC";L0:= X"053DF7592F2F";
      when "11110101" => 
              C3:= X"00DCF9025E3C";C2:= X"0140A8DF5173";C1:= X"05FEE200EFE8";C0:= X"07E37C163FBA";
              Q2:= X"03BC63429508";Q1:= X"039D3AE43213";Q0:= X"08A65DEC3B6C";
              L1:= X"0AC78D44E5F2";L0:= X"0536D33CAF80";
      when "11110110" => 
              C3:= X"00DD92704F96";C2:= X"013EEE900D3C";C1:= X"06008B098083";C0:= X"07E2F3F15A0C";
              Q2:= X"03BEFB1370C6";Q1:= X"03983F1E85D6";Q0:= X"08A8C2E46CA5";
              L1:= X"0ACF08A2F5FD";L0:= X"052FA2AFF3BE";
      when "11110111" => 
              C3:= X"00DE2C218CA5";C2:= X"013D31B1C283";C1:= X"0602384452E9";C0:= X"07E269E54BA8";
              Q2:= X"03C194B1104D";Q1:= X"03933AB015BB";Q0:= X"08AB2E87EB8D";
              L1:= X"0AD689327442";L0:= X"052865A52857";
      when "11111000" => 
              C3:= X"00DEC6601B48";C2:= X"013B716BB364";C1:= X"0603EA888618";C0:= X"07E1DDA9CE11";
              Q2:= X"03C4301CA493";Q1:= X"038E2D8F6000";Q0:= X"08ADA0E3FBB0";
              L1:= X"0ADE0EF6FB84";L0:= X"05211C0E6C7E";
      when "11111001" => 
              C3:= X"00DF6117FF54";C2:= X"0139ADF4DE67";C1:= X"0605A1A76E06";C0:= X"07E14F4AA6ED";
              Q2:= X"03C6CD576649";Q1:= X"038917B2CC7A";Q0:= X"08B01A05F9DC";
              L1:= X"0AE599F428E5";L0:= X"0519C5DDD24D";
      when "11111010" => 
              C3:= X"00DFFC02589E";C2:= X"0137E819D807";C1:= X"06075CDFDA2E";C0:= X"07E0BF036B04";
              Q2:= X"03C96C62C01D";Q1:= X"0383F9105A48";Q0:= X"08B299FB8445";
              L1:= X"0AED2A2D9C37";L0:= X"051263055E63";
      when "11111011" => 
              C3:= X"00E0976CD353";C2:= X"01361EF59314";C1:= X"06091D169185";C0:= X"07E02C86CA3B";
              Q2:= X"03CC0D3FB8AF";Q1:= X"037ED19EC3EE";Q0:= X"08B520D1EC6A";
              L1:= X"0AF4BFA6F7D2";L0:= X"050AF3770808";
      when "11111100" => 
              C3:= X"00E1334D3430";C2:= X"013452A3219E";C1:= X"060AE237A359";C0:= X"07DF97D7F053";
              Q2:= X"03CEAFEFFBCE";Q1:= X"0379A15378A2";Q0:= X"08B7AE9734B8";
              L1:= X"0AFC5A63E05B";L0:= X"05037724B959";
      when "11111101" => 
              C3:= X"00E1CF7A96B1";C2:= X"013283989A7C";C1:= X"060CABD51922";C0:= X"07DF0117AFE6";
              Q2:= X"03D154745642";Q1:= X"037468259669";Q0:= X"08BA43589A98";
              L1:= X"0B03FA67FD3A";L0:= X"04FBEE004ECA";
      when "11111110" => 
              C3:= X"00E26C6DCC08";C2:= X"0130B06CD67C";C1:= X"060E7B5A7394";C0:= X"07DE67CAE932";
              Q2:= X"03D3FACE3F0C";Q1:= X"036F260AE4E9";Q0:= X"08BCDF24127F";
              L1:= X"0B0B9FB6F845";L0:= X"04F457FB9770";
      when "11111111" => 
              C3:= X"00E309A45E18";C2:= X"012EDAA07576";C1:= X"06104F516CD2";C0:= X"07DDCC69BF9D";
              Q2:= X"03D6A2FF2070";Q1:= X"0369DAF93C16";Q0:= X"08BF82079840";
              L1:= X"0B134A547DD9";L0:= X"04ECB50854DE";
      when others => null;
    end case;

  if (coef_case_size>coef_max_size) then
    diff := coef_case_size - coef_max_size;
  else
    diff := 0;
  end if;
  if ((coef_case_size-diff-coef3_size) < 0) then
    C3_trunc := conv_signed(C3(coef_case_size-1-diff downto 0),C3_trunc'length);
  else
    C3_trunc := signed(C3(coef_case_size-1-diff downto coef_case_size-diff-coef3_size));
  end if;
  if ((coef_case_size-diff-coef2_size) < 0) then
    C2_trunc := conv_signed(C2(coef_case_size-1-diff downto 0),C2_trunc'length);
    Q2_trunc := conv_signed(Q2(coef_case_size-1-diff downto 0),Q2_trunc'length);
  else
    C2_trunc := signed(C2(coef_case_size-1-diff downto coef_case_size-diff-coef2_size));
    Q2_trunc := signed(Q2(coef_case_size-1-diff downto coef_case_size-diff-coef2_size));
  end if;
  if ((coef_case_size-diff-coef1_size) < 0) then
    C1_trunc := conv_signed(C1(coef_case_size-1-diff downto 0),C1_trunc'length);
    Q1_trunc := conv_signed(Q1(coef_case_size-1-diff downto 0),Q1_trunc'length);
    L1_trunc := conv_signed(L1(coef_case_size-1-diff downto 0),L1_trunc'length);
  else
    C1_trunc := signed(C1(coef_case_size-1-diff downto coef_case_size-diff-coef1_size));
    Q1_trunc := signed(Q1(coef_case_size-1-diff downto coef_case_size-diff-coef1_size));
    L1_trunc := signed(L1(coef_case_size-1-diff downto coef_case_size-diff-coef1_size));
  end if;
  if ((coef_case_size-diff-coef0_size) < 0)  then
    C0_trunc := conv_signed(C0(coef_case_size-1-diff downto 0),C0_trunc'length);
    Q0_trunc := conv_signed(Q0(coef_case_size-1-diff downto 0),Q0_trunc'length);
    L0_trunc := conv_signed(L0(coef_case_size-1-diff downto 0),L0_trunc'length);
  else    
    C0_trunc := signed(C0(coef_case_size-1-diff downto coef_case_size-diff-coef0_size));
    Q0_trunc := signed(Q0(coef_case_size-1-diff downto coef_case_size-diff-coef0_size));
    L0_trunc := signed(L0(coef_case_size-1-diff downto coef_case_size-diff-coef0_size));
  end if;

  p3_c := SHR((C3_trunc * unsigned(a) + C2_trunc * pad_vec),conv_unsigned(op_width,32));  
  p2_c := SHR((signed(p3_c(coef2_size-1 downto 0)) *  unsigned(a) + C1_trunc * pad_vec),conv_unsigned(op_width,32));
  p1_c := signed(p2_c(coef1_size-1 downto 0)) * unsigned(a) + C0_trunc * pad_vec;
  p3_q := (others => '0');
  p2_q := SHR((Q2_trunc *  unsigned(a) + Q1_trunc * pad_vec),conv_unsigned(op_width,32));
  p1_q := signed(p2_q(coef1_size-1 downto 0)) *  unsigned(a) + Q0_trunc * pad_vec;
  p3_l := (others => '0');
  p2_l := (others => '0');   
  p1_l := L1_trunc *  unsigned(a) + L0_trunc * pad_vec;
  if ((op_width >= 19) and (op_width < 29)) then
    p1_sel := p1_q(p1_sel'left downto 0);
  else
    if (op_width < 19) then
      p1_sel := p1_l(p1_sel'left downto 0);
    else  
      p1_sel := p1_c(p1_sel'left downto 0);
    end if;
  end if;
  p1_sel := SHL(p1_sel,conv_unsigned(int_bits,3));

  for i in 1 to p1_aligned'length loop
    if (i <= p1_sel'length) then
      p1_aligned(p1_aligned'length-i) := p1_sel(p1_sel'length-i);
    else
      p1_aligned(p1_aligned'length-i) := '0';
    end if;
  end loop;

  z_int := unsigned(p1_aligned);
  z_round:= unsigned(z_int(z_int'length-1 downto z_int'length-z_round'length))
            + unsigned('1' & conv_unsigned(0,chain-1));
  z_poly <= '1'&std_logic_vector(z_round(z_round_MSB downto z_round_MSB-op_width+2));
end process;

alg1_new: process (a)
  variable C3 : unsigned (coef_case_size-1 downto 0);
  variable C2 : unsigned (coef_case_size-1 downto 0);
  variable C1 : unsigned (coef_case_size-1 downto 0);
  variable C0 : unsigned (coef_case_size-1 downto 0);
  variable Q2 : unsigned (coef_case_size-1 downto 0);
  variable Q1 : unsigned (coef_case_size-1 downto 0);
  variable Q0 : unsigned (coef_case_size-1 downto 0);
  variable L1 : unsigned (coef_case_size-1 downto 0);
  variable L0 : unsigned (coef_case_size-1 downto 0);
  variable C3_trunc : signed (coef3_size_new-1 downto 0);
  variable C2_trunc : signed (coef2_size-1 downto 0);
  variable C1_trunc : signed (coef1_size-1 downto 0);
  variable C0_trunc : signed (coef0_size-1 downto 0);
  variable Q2_trunc : signed (coef2_size-1 downto 0);
  variable Q1_trunc : signed (coef1_size-1 downto 0);
  variable Q0_trunc : signed (coef0_size-1 downto 0);
  variable L1_trunc : signed (coef1_size-1 downto 0);
  variable L0_trunc : signed (coef0_size-1 downto 0);
  variable p1_c  : signed (prod1_MSB+1 downto 0);
  variable p2_c  : signed (prod2_MSB+1 downto 0);
  variable p3_c : signed (prod3_MSB_new+1 downto 0);
  variable p1_q  : signed (prod1_MSB+1 downto 0);
  variable p2_q  : signed (prod2_MSB+1 downto 0);
  variable p3_q : signed (prod3_MSB_new+1 downto 0);
  variable p1_l  : signed (prod1_MSB+1 downto 0);
  variable p2_l  : signed (prod2_MSB+1 downto 0);
  variable p3_l : signed (prod3_MSB_new+1 downto 0);
  variable p1_sel  : signed (prod1_MSB downto 0);
  variable p1_aligned : unsigned (z_int_size-1 downto 0);
  variable z_int : unsigned (z_int_size-1 downto 0);
  variable addr : std_logic_vector (table_addrsize-1 downto 0);
  variable short_a : std_logic_vector (op_width-1 downto 0); 
  variable z_round : unsigned (z_round_MSB downto 0);
  variable diff : integer;
  variable pad_vec : unsigned (op_width downto 0);
  variable pad_vec2 : unsigned (op_width+bits downto 0);
  variable a_square : unsigned (2*op_width-1 downto 0);
  variable a_cube : unsigned (3*op_width-1 downto 0);
  variable a_square_aligned : unsigned (2*op_width-1 downto 0);
  variable a_square_trunc : unsigned (op_width+extra_LSBs-1 downto 0);
  variable a_cube_aligned : unsigned (3*op_width-1 downto 0);
  variable a_cube_trunc : unsigned (op_width+extra_LSBs-1 downto 0);
  variable short_a_padded : unsigned (short_a'left+extra_LSBs downto 0);
  variable pad_vec3 : std_logic_vector (extra_LSBs-1 downto 0);
begin
  pad_vec := (others => '0');
  pad_vec(pad_vec'left) := '1';
  pad_vec2 := (others => '0');
  pad_vec2(pad_vec2'left) := '1';
  pad_vec3 := (others => '0');
  for i in 0 to table_addrsize-1 loop
    if (op_width-1 <= i) then
      addr(table_addrsize - 1 - i) := '0';
    else
      addr(table_addrsize - 1 - i) := a(op_width - 1 - i);
    end if;
  end loop;
  
  short_a := a;
  for i in 0 to table_addrsize-1 loop 
    if (op_width-1 >= i) then
        short_a(op_width-1-i) := '0';
    end if;
  end loop;

    case (addr) is
      when "00000000" => 
              C3:= X"0071D3892DCC";C2:= X"01EBFBC6AEF9";C1:= X"058B90BFC427";C0:= X"07FFFFFFFFFF";
              Q2:= X"01ECA6840123";Q1:= X"058B907B9A7B";Q0:= X"08000000059F";
              L1:= X"058D7D221E7B";L0:= X"07FFFFAE3BFA";
      when "00000001" => 
              C3:= X"007222939145";C2:= X"01ED51414D3A";C1:= X"058F6A0CD75A";C0:= X"08058D7D2D5E";
              Q2:= X"01EDFC75293E";Q1:= X"058F69C87E5C";Q0:= X"08058D7D3301";
              L1:= X"059157C4F387";L0:= X"08058D2B3098";
      when "00000010" => 
              C3:= X"007271C6B6A5";C2:= X"01EEA7A8F67C";C1:= X"05934605CCE9";C0:= X"080B1ED4FD99";
              Q2:= X"01EF5353A155";Q1:= X"059345C14479";Q0:= X"080B1ED50341";
              L1:= X"05953514981C";L0:= X"080B1E82C7EB";
      when "00000011" => 
              C3:= X"0072C139971A";C2:= X"01EFFEFE46C0";C1:= X"059724AC7F6C";C0:= X"0810B40A1D80";
              Q2:= X"01F0AB20198F";Q1:= X"05972467C772";Q0:= X"0810B40A232C";
              L1:= X"05991512E78D";L0:= X"0810B3B7AEC3";
      when "00000100" => 
              C3:= X"007310E7F25D";C2:= X"01F15741D699";C1:= X"059B0602CAF7";C0:= X"08164D1F3BBF";
              Q2:= X"01F203DB304B";Q1:= X"059B05BDE344";Q0:= X"08164D1F416F";
              L1:= X"059CF7C1BE72";L0:= X"08164CCC93CB";
      when "00000101" => 
              C3:= X"007360B85142";C2:= X"01F2B0747CB5";C1:= X"059EEA0A8CA5";C0:= X"081BEA1708DD";
              Q2:= X"01F35D858E2C";Q1:= X"059EE9C57528";Q0:= X"081BEA170E91";
              L1:= X"05A0DD22FAB4";L0:= X"081BE9C4278A";
      when "00000110" => 
              C3:= X"0073B0D74771";C2:= X"01F40A96963B";C1:= X"05A2D0C5A329";C0:= X"08218AF4373F";
              Q2:= X"01F4B81FD498";Q1:= X"05A2D0805BB1";Q0:= X"08218AF43CF7";
              L1:= X"05A4C5387B84";L0:= X"08218AA11C65";
      when "00000111" => 
              C3:= X"0074011E8C03";C2:= X"01F565A9051D";C1:= X"05A6BA35EE3E";C0:= X"08272FB97B2A";
              Q2:= X"01F613AAB5F9";Q1:= X"05A6B9F076AA";Q0:= X"08272FB980E5";
              L1:= X"05A8B0042160";L0:= X"08272F6626A1";
      when "00001000" => 
              C3:= X"007451A040DB";C2:= X"01F6C1AC5712";C1:= X"05AAA65D4F11";C0:= X"082CD8698AC2";
              Q2:= X"01F77026C952";Q1:= X"05AAA617A74B";Q0:= X"082CD8699081";
              L1:= X"05AC9D87CE14";L0:= X"082CD815FC63";
      when "00001001" => 
              C3:= X"0074A2623EA3";C2:= X"01F81EA128D2";C1:= X"05AE953DA81F";C0:= X"083285071E0F";
              Q2:= X"01F8CD94BD1F";Q1:= X"05AE94F7CFFD";Q0:= X"0832850723D2";
              L1:= X"05B08DC564BB";L0:= X"083284B355B1";
      when "00001010" => 
              C3:= X"0074F358A940";C2:= X"01F97C883ABE";C1:= X"05B286D8DD18";C0:= X"08383594EEFB";
              Q2:= X"01FA2BF54069";Q1:= X"05B28692D47B";Q0:= X"08383594F4C2";
              L1:= X"05B480BEC9BC";L0:= X"08383540EC76";
      when "00001011" => 
              C3:= X"00754485342F";C2:= X"01FADB622626";C1:= X"05B67B30D31F";C0:= X"083DEA15B953";
              Q2:= X"01FB8B48EF42";Q1:= X"05B67AEA99E1";Q0:= X"083DEA15BF1F";
              L1:= X"05B87675E2D3";L0:= X"083DE9C17C7F";
      when "00001100" => 
              C3:= X"007595DD5F2B";C2:= X"01FC3B2FACD4";C1:= X"05BA72477080";C0:= X"0843A28C3ACD";
              Q2:= X"01FCEB9073D8";Q1:= X"05BA72010696";Q0:= X"0843A28C409D";
              L1:= X"05BC6EEC9709";L0:= X"0843A237C381";
      when "00001101" => 
              C3:= X"0075E779565B";C2:= X"01FD9BF14FBF";C1:= X"05BE6C1E9D08";C0:= X"08495EFB3303";
              Q2:= X"01FE4CCC85C4";Q1:= X"05BE6BD80239";Q0:= X"08495EFB38D7";
              L1:= X"05C06A24CEBF";L0:= X"08495EA68117";
      when "00001110" => 
              C3:= X"00763958428B";C2:= X"01FEFDA7BC63";C1:= X"05C268B841B4";C0:= X"084F1F656379";
              Q2:= X"01FFAEFDBD04";Q1:= X"05C2687175E5";Q0:= X"084F1F656951";
              L1:= X"05C4682073A2";L0:= X"084F1F1076C3";
      when "00001111" => 
              C3:= X"00768B623EC7";C2:= X"02006053BD53";C1:= X"05C6681648D8";C0:= X"0854E3CD8F9C";
              Q2:= X"02011224CDF2";Q1:= X"05C667CF4BE8";Q0:= X"0854E3CD9577";
              L1:= X"05C868E170B6";L0:= X"0854E37867F4";
      when "00010000" => 
              C3:= X"0076DDB75F26";C2:= X"0201C3F5CBE0";C1:= X"05CA6A3A9E38";C0:= X"085AAC367CC4";
              Q2:= X"020276426594";Q1:= X"05CA69F36FEF";Q0:= X"085AAC3682A3";
              L1:= X"05CC6C69B254";L0:= X"085AABE11A01";
      when "00010001" => 
              C3:= X"00773031D1EA";C2:= X"0203288EDB2D";C1:= X"05CE6F272EAB";C0:= X"086078A2F235";
              Q2:= X"0203DB571F71";Q1:= X"05CE6EDFCF0B";Q0:= X"086078A2F819";
              L1:= X"05D072BB262A";L0:= X"0860784D542F";
      when "00010010" => 
              C3:= X"007782E67144";C2:= X"02048E1F646E";C1:= X"05D276DDE8AF";C0:= X"08664915B923";
              Q2:= X"02054163BE8A";Q1:= X"05D276965781";Q0:= X"08664915BF0B";
              L1:= X"05D47BD7BB3E";L0:= X"086648BFDFB0";
      when "00010011" => 
              C3:= X"0077D5E24D0D";C2:= X"0205F4A80406";C1:= X"05D68160BBF4";C0:= X"086C1D919CAE";
              Q2:= X"0206A868D85F";Q1:= X"05D68118F914";Q0:= X"086C1D91A29A";
              L1:= X"05D887C161EC";L0:= X"086C1D3B87A5";
      when "00010100" => 
              C3:= X"007829071E15";C2:= X"02075C299BA3";C1:= X"05DA8EB1996E";C0:= X"0871F61969E8";
              Q2:= X"020810672330";Q1:= X"05DA8E69A4C9";Q0:= X"0871F6196FD8";
              L1:= X"05DC967A0BEA";L0:= X"0871F5C3191F";
      when "00010101" => 
              C3:= X"00787C77F2F0";C2:= X"0208C4A49E86";C1:= X"05DE9ED27395";C0:= X"0877D2AFEFD4";
              Q2:= X"0209795F4FC0";Q1:= X"05DE9E8A4CF6";Q0:= X"0877D2AFF5C8";
              L1:= X"05E0A803AC45";L0:= X"0877D2596322";
      when "00010110" => 
              C3:= X"0078D00D87F0";C2:= X"020A2E19F3F7";C1:= X"05E2B1C53E0E";C0:= X"087DB357FF69";
              Q2:= X"020AE3520611";Q1:= X"05E2B17CE563";Q0:= X"087DB3580561";
              L1:= X"05E4BC603769";L0:= X"087DB30136A4";
      when "00010111" => 
              C3:= X"007923F6270B";C2:= X"020B988A01AD";C1:= X"05E6C78BEE11";C0:= X"088398146B91";
              Q2:= X"020C4E3FF600";Q1:= X"05E6C7436321";Q0:= X"08839814718D";
              L1:= X"05E8D391A318";L0:= X"088397BD6690";
      when "00011000" => 
              C3:= X"00797808175F";C2:= X"020D03F5C1A1";C1:= X"05EAE02879EB";C0:= X"088980E8092D";
              Q2:= X"020DBA29CE64";Q1:= X"05EADFDFBCA0";Q0:= X"088980E80F2D";
              L1:= X"05ECED99E671";L0:= X"08898090C7C6";
      when "00011001" => 
              C3:= X"0079CC4CC3DF";C2:= X"020E705DC734";C1:= X"05EEFB9CD976";C0:= X"088F6DD5AF15";
              Q2:= X"020F271039DE";Q1:= X"05EEFB53E9BB";Q0:= X"088F6DD5B519";
              L1:= X"05F10A7AF9F4";L0:= X"088F6D7E311D";
      when "00011010" => 
              C3:= X"007A20DB5288";C2:= X"020FDDC2A1B5";C1:= X"05F319EB05F2";C0:= X"08955EE03618";
              Q2:= X"021094F3EDD9";Q1:= X"05F319A1E390";Q0:= X"08955EE03C21";
              L1:= X"05F52A36D77E";L0:= X"08955E887B67";
      when "00011011" => 
              C3:= X"007A759A3CDA";C2:= X"02114C252F65";C1:= X"05F73B14F9D0";C0:= X"089B540A7902";
              Q2:= X"021203D593B8";Q1:= X"05F73ACBA4B4";Q0:= X"089B540A7F0F";
              L1:= X"05F94CCF7A48";L0:= X"089B53B2816C";
      when "00011100" => 
              C3:= X"007ACA9E6ED2";C2:= X"0212BB85F8F8";C1:= X"05FB5F1CB110";C0:= X"08A14D575496";
              Q2:= X"021373B5E412";Q1:= X"05FB5ED32909";Q0:= X"08A14D575AA8";
              L1:= X"05FD7246DEED";L0:= X"08A14CFF1FF2";
      when "00011101" => 
              C3:= X"007B1FDBA4F4";C2:= X"02142BE5BE7F";C1:= X"05FF860428F6";C0:= X"08A74AC9A798";
              Q2:= X"0214E49588C3";Q1:= X"05FF85BA6DE3";Q0:= X"08A74AC9ADAD";
              L1:= X"06019A9F036C";L0:= X"08A74A7135BB";
      when "00011110" => 
              C3:= X"007B7547C452";C2:= X"02159D4547FA";C1:= X"0603AFCD6029";C0:= X"08AD4C6452C6";
              Q2:= X"021656753539";Q1:= X"0603AF8371EB";Q0:= X"08AD4C6458E0";
              L1:= X"0605C5D9E721";L0:= X"08AD4C0BA386";
      when "00011111" => 
              C3:= X"007BCB03CECF";C2:= X"02170FA51A8B";C1:= X"0607DC7A56C0";C0:= X"08B3522A38E1";
              Q2:= X"0217C9559BAE";Q1:= X"0607DC303532";Q0:= X"08B3522A3EFF";
              L1:= X"0609F3F98ACD";L0:= X"08B351D14C12";
      when "00100000" => 
              C3:= X"007C20EC8F36";C2:= X"021883060DD2";C1:= X"060C0C0D0E28";C0:= X"08B95C1E3EA8";
              Q2:= X"02193D376BC8";Q1:= X"060C0BC2B92A";Q0:= X"08B95C1E44CA";
              L1:= X"060E24FFF094";L0:= X"08B95BC51421";
      when "00100001" => 
              C3:= X"007C77191016";C2:= X"0219F768B392";C1:= X"06103E878949";C0:= X"08BF6A434ADD";
              Q2:= X"021AB21B5EE5";Q1:= X"06103E3D00A5";Q0:= X"08BF6A435104";
              L1:= X"061258EF1C04";L0:= X"08BF69E9E272";
      when "00100010" => 
              C3:= X"007CCD754202";C2:= X"021B6CCDEE20";C1:= X"061473EBCC3F";C0:= X"08C57C9C4646";
              Q2:= X"021C28021D95";Q1:= X"061473A10FEB";Q0:= X"08C57C9C4C71";
              L1:= X"06168FC91208";L0:= X"08C57C429FCD";
      when "00100011" => 
              C3:= X"007D24185B30";C2:= X"021CE3364032";C1:= X"0618AC3BDCCB";C0:= X"08CB932C1BAE";
              Q2:= X"021D9EEC660D";Q1:= X"0618ABF0EC92";Q0:= X"08CB932C21DD";
              L1:= X"061AC98FD8F8";L0:= X"08CB92D236FB";
      when "00100100" => 
              C3:= X"007D7AEA87EB";C2:= X"021E5AA282CA";C1:= X"061CE779C1E5";C0:= X"08D1ADF5B7E5";
              Q2:= X"021F16DAE56F";Q1:= X"061CE72E9DAD";Q0:= X"08D1ADF5BE18";
              L1:= X"061F06457894";L0:= X"08D1AD9B94CD";
      when "00100101" => 
              C3:= X"007DD20A860D";C2:= X"021FD3134316";C1:= X"062125A7840F";C0:= X"08D7CCFC09C4";
              Q2:= X"02208FCE51E7";Q1:= X"0621255C2BAD";Q0:= X"08D7CCFC0FFC";
              L1:= X"062345EBFA01";L0:= X"08D7CCA1A81C";
      when "00100110" => 
              C3:= X"007E295F0A26";C2:= X"02214C895330";C1:= X"062566C72D19";C0:= X"08DDF042022E";
              Q2:= X"022209C76271";Q1:= X"0625667BA06C";Q0:= X"08DDF042086A";
              L1:= X"0627888567CE";L0:= X"08DDEFE761CA";
      when "00100111" => 
              C3:= X"007E80F30C70";C2:= X"0222C7055D22";C1:= X"0629AADAC851";C0:= X"08E417CA940D";
              Q2:= X"022384C6CC19";Q1:= X"0629AA8F072F";Q0:= X"08E417CA9A4E";
              L1:= X"062BCE13CDFB";L0:= X"08E4176FB4C3";
      when "00101000" => 
              C3:= X"007ED8BFB164";C2:= X"02244288222B";C1:= X"062DF1E4625C";C0:= X"08EA4398B45C";
              Q2:= X"022500CD3D7E";Q1:= X"062DF1986CAE";Q0:= X"08EA4398BAA1";
              L1:= X"0630169939ED";L0:= X"08EA433D95FF";
      when "00101001" => 
              C3:= X"007F30C324D8";C2:= X"0225BF125D6A";C1:= X"06323BE6095A";C0:= X"08F073AF5A1F";
              Q2:= X"02267DDB7DD7";Q1:= X"06323B99DEF8";Q0:= X"08F073AF6068";
              L1:= X"06346217BA77";L0:= X"08F07353FC83";
      when "00101010" => 
              C3:= X"007F891A4D15";C2:= X"02273CA48D31";C1:= X"063688E1CCF0";C0:= X"08F6A8117E6C";
              Q2:= X"0227FBF238B9";Q1:= X"063688956DA0";Q0:= X"08F6A81184B9";
              L1:= X"0638B0915FD9";L0:= X"08F6A7B5E165";
      when "00101011" => 
              C3:= X"007FE1969B5E";C2:= X"0228BB3FC5EA";C1:= X"063AD8D9BDEA";C0:= X"08FCE0C21C66";
              Q2:= X"02297B1223F6";Q1:= X"063AD88D29A2";Q0:= X"08FCE0C222B8";
              L1:= X"063D02083BC5";L0:= X"08FCE0663FCA";
      when "00101100" => 
              C3:= X"00803A61C8E2";C2:= X"022A3AE46E2F";C1:= X"063F2BCFEED2";C0:= X"09031DC43146";
              Q2:= X"022AFB3BFCC2";Q1:= X"063F2B832561";Q0:= X"09031DC4379C";
              L1:= X"0641567E615C";L0:= X"09031D6814E6";
      when "00101101" => 
              C3:= X"0080934F9A75";C2:= X"022BBB93838E";C1:= X"064381C67368";C0:= X"09095F1ABC53";
              Q2:= X"022C7C707D6C";Q1:= X"0643817974B1";Q0:= X"09095F1AC2AE";
              L1:= X"0645ADF5E530";L0:= X"09095EBE6005";
      when "00101110" => 
              C3:= X"0080ECA20701";C2:= X"022D3D4D6231";C1:= X"0647DABF611A";C0:= X"090FA4C8BEED";
              Q2:= X"022DFEB05899";Q1:= X"0647DA722CE3";Q0:= X"090FA4C8C54C";
              L1:= X"064A0870DD3A";L0:= X"090FA46C2284";
      when "00101111" => 
              C3:= X"0081461BC662";C2:= X"022EC0131F7D";C1:= X"064C36BCCE78";C0:= X"0915EED13C89";
              Q2:= X"022F81FC4A35";Q1:= X"064C366F64AF";Q0:= X"0915EED142EC";
              L1:= X"064E65F160FA";L0:= X"0915EE745FD8";
      when "00110000" => 
              C3:= X"00819FCA1962";C2:= X"023043E55BC5";C1:= X"065095C0D3C3";C0:= X"091C3D373AB0";
              Q2:= X"023106550BAD";Q1:= X"065095733444";Q0:= X"091C3D374118";
              L1:= X"0652C6798950";L0:= X"091C3CDA1D8B";
      when "00110001" => 
              C3:= X"0081F9BE6BD9";C2:= X"0231C8C4BD3B";C1:= X"0654F7CD8A9B";C0:= X"09228FFDC109";
              Q2:= X"02328BBB5B56";Q1:= X"0654F77FB542";Q0:= X"09228FFDC775";
              L1:= X"06572A0B709D";L0:= X"09228FA06343";
      when "00110010" => 
              C3:= X"008253F66A25";C2:= X"02334EB208BC";C1:= X"06595CE50E1B";C0:= X"0928E727D952";
              Q2:= X"0234122FF197";Q1:= X"06595C9702C1";Q0:= X"0928E727DFC3";
              L1:= X"065B90A932B3";L0:= X"0928E6CA3ABE";
      when "00110011" => 
              C3:= X"0082AE6A68E6";C2:= X"0234D5ADEEEE";C1:= X"065DC5097ADC";C0:= X"092F42B88F66";
              Q2:= X"023599B387FE";Q1:= X"065DC4BB3954";Q0:= X"092F42B895DC";
              L1:= X"065FFA54ECDC";L0:= X"092F425AAFD7";
      when "00110100" => 
              C3:= X"00830933453E";C2:= X"02365DB9141E";C1:= X"0662303CEEDE";C0:= X"0935A2B2F13E";
              Q2:= X"02372246DE42";Q1:= X"06622FEE76F8";Q0:= X"0935A2B2F7B7";
              L1:= X"06646710BDD7";L0:= X"0935A254D086";
      when "00110101" => 
              C3:= X"00836416FFD7";C2:= X"0237E6D49678";C1:= X"06669E81897C";C0:= X"093C071A0EEF";
              Q2:= X"0238ABEAB315";Q1:= X"06669E32DB2D";Q0:= X"093C071A156D";
              L1:= X"0668D6DEC5DF";L0:= X"093C06BBACE2";
      when "00110110" => 
              C3:= X"0083BF4D7B53";C2:= X"02397100C650";C1:= X"066B0FD96BE2";C0:= X"09426FF0FAB1";
              Q2:= X"023A369FBCDB";Q1:= X"066B0F8A86EB";Q0:= X"09426FF10134";
              L1:= X"066D49C126A8";L0:= X"09426F925722";
      when "00110111" => 
              C3:= X"00841ABE295D";C2:= X"023AFC3EA0D3";C1:= X"066F8446B859";C0:= X"0948DD3AC8DD";
              Q2:= X"023BC266C0BF";Q1:= X"066F83F79C9E";Q0:= X"0948DD3ACF64";
              L1:= X"0671BFBA0361";L0:= X"0948DCDBE39E";
      when "00111000" => 
              C3:= X"0084767FC814";C2:= X"023C888EB13A";C1:= X"0673FBCB92E9";C0:= X"094F4EFA8FEF";
              Q2:= X"023D4F407409";Q1:= X"0673FB7C403C";Q0:= X"094F4EFA967A";
              L1:= X"067638CB80AE";L0:= X"094F4E9B68D2";
      when "00111001" => 
              C3:= X"0084D25C6577";C2:= X"023E15F21380";C1:= X"0678766A20CE";C0:= X"0955C5336887";
              Q2:= X"023EDD2D991B";Q1:= X"0678761A9725";Q0:= X"0955C5336F17";
              L1:= X"067AB4F7C4BF";L0:= X"0955C4D3FF5F";
      when "00111010" => 
              C3:= X"00852E91FFEB";C2:= X"023FA4691737";C1:= X"067CF4248927";C0:= X"095C3FE86D6C";
              Q2:= X"02406C2EF380";Q1:= X"067CF3D4C841";Q0:= X"095C3FE87401";
              L1:= X"067F3440F734";L0:= X"095C3F88C20B";
      when "00111011" => 
              C3:= X"00858AF98403";C2:= X"024133F4CCC0";C1:= X"068174FCF427";C0:= X"0962BF1CBB8D";
              Q2:= X"0241FC4541D0";Q1:= X"068174ACFBEE";Q0:= X"0962BF1CC226";
              L1:= X"0683B6A94130";L0:= X"0962BEBCCDC5";
      when "00111100" => 
              C3:= X"0085E7B97A38";C2:= X"0242C495A6A3";C1:= X"0685F8F58BDF";C0:= X"096942D37201";
              Q2:= X"02438D713F93";Q1:= X"0685F8A55C17";Q0:= X"096942D3789F";
              L1:= X"06883C32CD59";L0:= X"0969427341A3";
      when "00111101" => 
              C3:= X"008644A448AB";C2:= X"0244564CB50A";C1:= X"068A80107B8E";C0:= X"096FCB0FB20A";
              Q2:= X"02451FB3AAAA";Q1:= X"068A7FC01425";Q0:= X"096FCB0FB8AC";
              L1:= X"068CC4DFC7CF";L0:= X"096FCAAF3EE9";
      when "00111110" => 
              C3:= X"0086A1CBB0AD";C2:= X"0245E91AA10B";C1:= X"068F0A4FF01B";C0:= X"097657D49F17";
              Q2:= X"0246B30D52F9";Q1:= X"068F09FF50EA";Q0:= X"097657D4A5BE";
              L1:= X"069150B25E3D";L0:= X"09765773E904";
      when "00111111" => 
              C3:= X"0086FF4EB12E";C2:= X"02477CFFF508";C1:= X"069397B61811";C0:= X"097CE9255EC3";
              Q2:= X"0248477EEAB4";Q1:= X"0693976540E2";Q0:= X"097CE925656F";
              L1:= X"0695DFACBFCC";L0:= X"097CE8C46591";
      when "01000000" => 
              C3:= X"00875CF7A91C";C2:= X"024911FDC617";C1:= X"069828452337";C0:= X"09837F0518DB";
              Q2:= X"0249DD093E24";Q1:= X"069827F413EA";Q0:= X"09837F051F8B";
              L1:= X"069A71D11D26";L0:= X"09837EA3DC59";
      when "01000001" => 
              C3:= X"0087BAEF3413";C2:= X"024AA814A838";C1:= X"069CBBFF4302";C0:= X"098A1976F759";
              Q2:= X"024B73AD0788";Q1:= X"069CBBADFB7E";Q0:= X"098A1976FE0E";
              L1:= X"069F0721A884";L0:= X"098A19157759";
      when "01000010" => 
              C3:= X"00881926CABB";C2:= X"024C3F455B30";C1:= X"06A152E6AA7D";C0:= X"0990B87E266B";
              Q2:= X"024D0B6B1675";Q1:= X"06A152952A85";Q0:= X"0990B87E2D25";
              L1:= X"06A39FA0959B";L0:= X"0990B81C62C0";
      when "01000011" => 
              C3:= X"0088779B6AA3";C2:= X"024DD790B8A9";C1:= X"06A5ECFD8E12";C0:= X"09975C1DD474";
              Q2:= X"024EA4441DA5";Q1:= X"06A5ECABD58E";Q0:= X"09975C1DDB33";
              L1:= X"06A83B5019AC";L0:= X"09975BBBCCED";
      when "01000100" => 
              C3:= X"0088D659CE7A";C2:= X"024F70F76BCB";C1:= X"06AA8A4623D3";C0:= X"099E0459320B";
              Q2:= X"02503E38F83B";Q1:= X"06AA89F43288";Q0:= X"099E045938CE";
              L1:= X"06ACDA326B80";L0:= X"099E03F6E679";
      when "01000101" => 
              C3:= X"0089354D70F7";C2:= X"02510B7A60EE";C1:= X"06AF2AC2A332";C0:= X"09A4B13371FC";
              Q2:= X"0251D94A51CE";Q1:= X"06AF2A707917";Q0:= X"09A4B13378C4";
              L1:= X"06B17C49C368";L0:= X"09A4B0D0E231";
      when "01000110" => 
              C3:= X"00899481234B";C2:= X"0252A71A471C";C1:= X"06B3CE75455E";C0:= X"09AB62AFC94F";
              Q2:= X"02537579027B";Q1:= X"06B3CE22E23F";Q0:= X"09AB62AFD01C";
              L1:= X"06B621985B43";L0:= X"09AB624CF51B";
      when "01000111" => 
              C3:= X"0089F40ADFA8";C2:= X"025443D7B773";C1:= X"06B875604505";C0:= X"09B218D16F43";
              Q2:= X"025512C5CBDB";Q1:= X"06B8750DA8AA";Q0:= X"09B218D17614";
              L1:= X"06BACA206E75";L0:= X"09B2186E5677";
      when "01001000" => 
              C3:= X"008A53C2344E";C2:= X"0255E1B3CF69";C1:= X"06BD1F85DE2B";C0:= X"09B8D39B9D54";
              Q2:= X"0256B1317273";Q1:= X"06BD1F330883";Q0:= X"09B8D39BA42A";
              L1:= X"06BF75E439F7";L0:= X"09B8D3383FBF";
      when "01001001" => 
              C3:= X"008AB3CD0AF6";C2:= X"025780AF063D";C1:= X"06C1CCE84EBD";C0:= X"09BF93118F3A";
              Q2:= X"025850BCBA5C";Q1:= X"06C1CC953F8D";Q0:= X"09BF93119614";
              L1:= X"06C424E5FC47";L0:= X"09BF92ADECAD";
      when "01001010" => 
              C3:= X"008B141B34C6";C2:= X"025920CA4D6F";C1:= X"06C67D89D5DC";C0:= X"09C6573682EB";
              Q2:= X"0259F1686EBE";Q1:= X"06C67D368D0B";Q0:= X"09C6573689CB";
              L1:= X"06C8D727F579";L0:= X"09C656D29B37";
      when "01001011" => 
              C3:= X"008B74970873";C2:= X"025AC206789D";C1:= X"06CB316CB475";C0:= X"09CD200DB8A0";
              Q2:= X"025B933556D4";Q1:= X"06CB311931D7";Q0:= X"09CD200DBF84";
              L1:= X"06CD8CAC672E";L0:= X"09CD1FA98B93";
      when "01001100" => 
              C3:= X"008BD56A819A";C2:= X"025C64642432";C1:= X"06CFE8932CEF";C0:= X"09D3ED9A72CF";
              Q2:= X"025D362441E2";Q1:= X"06CFE83F7056";Q0:= X"09D3ED9A79B8";
              L1:= X"06D245759498";L0:= X"09D3ED36003B";
      when "01001101" => 
              C3:= X"008C367520B4";C2:= X"025E07E446C2";C1:= X"06D4A2FF833C";C0:= X"09DABFDFF636";
              Q2:= X"025EDA35F500";Q1:= X"06D4A2AB8C85";Q0:= X"09DABFDFFD23";
              L1:= X"06D70185C279";L0:= X"09DABF7B3DE9";
      when "01001110" => 
              C3:= X"008C97C52823";C2:= X"025FAC878DC1";C1:= X"06D960B3FCF5";C0:= X"09E196E189D4";
              Q2:= X"02607F6B352D";Q1:= X"06D9605FCBF6";Q0:= X"09E196E190C6";
              L1:= X"06DBC0DF372C";L0:= X"09E1967C8B9F";
      when "01001111" => 
              C3:= X"008CF95C574B";C2:= X"0261524EC502";C1:= X"06DE21B2E135";C0:= X"09E872A276F0";
              Q2:= X"026225C4C90C";Q1:= X"06DE215E75CE";Q0:= X"09E872A27DE7";
              L1:= X"06E083843A96";L0:= X"09E8723D32A2";
      when "01010000" => 
              C3:= X"008D5B31CE55";C2:= X"0262F93AC012";C1:= X"06E2E5FE78B6";C0:= X"09EF53260919";
              Q2:= X"0263CD4388E9";Q1:= X"06E2E5A9D2B5";Q0:= X"09EF53261015";
              L1:= X"06E54977163C";L0:= X"09EF52C07E82";
      when "01010001" => 
              C3:= X"008DBD4F2093";C2:= X"0264A14C4AD3";C1:= X"06E7AD990DBB";C0:= X"09F6386F8E28";
              Q2:= X"026575E84227";Q1:= X"06E7AD442CF3";Q0:= X"09F6386F9529";
              L1:= X"06EA12BA1534";L0:= X"09F63809BD16";
      when "01010010" => 
              C3:= X"008E1FB8D145";C2:= X"02664A841996";C1:= X"06EC7884EC31";C0:= X"09FD2282563F";
              Q2:= X"02671FB3AB2F";Q1:= X"06EC782FD080";Q0:= X"09FD22825D45";
              L1:= X"06EEDF4F842D";L0:= X"09FD221C3E82";
      when "01010011" => 
              C3:= X"008E8251B185";C2:= X"0267F4E32D16";C1:= X"06F146C46183";C0:= X"0A041161B3CF";
              Q2:= X"0268CAA6A289";Q1:= X"06F1466F0ACA";Q0:= X"0A041161BADA";
              L1:= X"06F3AF39B169";L0:= X"0A0410FB5535";
      when "01010100" => 
              C3:= X"008EE53CCB33";C2:= X"0269A06A1725";C1:= X"06F61859BCDD";C0:= X"0A0B0510FB96";
              Q2:= X"026A76C1F435";Q1:= X"06F618042ADC";Q0:= X"0A0B051102A6";
              L1:= X"06F8827AECD0";L0:= X"0A0B04AA55EF";
      when "01010101" => 
              C3:= X"008F486ECEE3";C2:= X"026B4D19C2CB";C1:= X"06FAED474ED7";C0:= X"0A11FD9384A2";
              Q2:= X"026C2406659B";Q1:= X"06FAECF18173";Q0:= X"0A11FD938BB7";
              L1:= X"06FD591587DB";L0:= X"0A11FD2C97BC";
      when "01010110" => 
              C3:= X"008FABE52587";C2:= X"026CFAF2F846";C1:= X"06FFC58F69C2";C0:= X"0A18FAECA853";
              Q2:= X"026DD274CAFB";Q1:= X"06FFC53960D2";Q0:= X"0A18FAECAF6D";
              L1:= X"0702330BD59F";L0:= X"0A18FA8573FD";
      when "01010111" => 
              C3:= X"00900F94FB07";C2:= X"026EA9F690B2";C1:= X"0704A1346185";C0:= X"0A1FFD1FC25C";
              Q2:= X"026F820DF1E5";Q1:= X"0704A0DE1CE0";Q0:= X"0A1FFD1FC97A";
              L1:= X"070710602AD1";L0:= X"0A1FFCB84663";
      when "01011000" => 
              C3:= X"00907391439E";C2:= X"02705A25592B";C1:= X"070980388B93";C0:= X"0A27043030C4";
              Q2:= X"027132D2B2C1";Q1:= X"07097FE20B13";Q0:= X"0A27043037E7";
              L1:= X"070BF114DDC4";L0:= X"0A2703C86CF7";
      when "01011001" => 
              C3:= X"0090D7D89E4A";C2:= X"02720B8001B8";C1:= X"070E629E3F38";C0:= X"0A2E102153E8";
              Q2:= X"0272E4C3C8B9";Q1:= X"070E624782A5";Q0:= X"0A2E10215B11";
              L1:= X"0710D52C466D";L0:= X"0A2E0FB94816";
      when "01011010" => 
              C3:= X"00913C5B8F16";C2:= X"0273BE078FC7";C1:= X"07134867D501";C0:= X"0A3520F68E7F";
              Q2:= X"027497E213FF";Q1:= X"07134810DC47";Q0:= X"0A3520F695AD";
              L1:= X"0715BCA8BE5A";L0:= X"0A35208E3A76";
      when "01011011" => 
              C3:= X"0091A14337CF";C2:= X"027571BC753A";C1:= X"07183197A794";C0:= X"0A3C36B34598";
              Q2:= X"02764C2E6350";Q1:= X"07183140725E";Q0:= X"0A3C36B34CCB";
              L1:= X"071AA78CA0C0";L0:= X"0A3C364AA925";
      when "01011100" => 
              C3:= X"009206446552";C2:= X"027726A01AAD";C1:= X"071D1E3012A2";C0:= X"0A43515AE09E";
              Q2:= X"027801A98610";Q1:= X"071D1DD8A0F2";Q0:= X"0A43515AE7D5";
              L1:= X"071F95DA4A79";L0:= X"0A4350F1FB8E";
      when "01011101" => 
              C3:= X"00926B911D85";C2:= X"0278DCB2F523";C1:= X"07220E3373FE";C0:= X"0A4A70F0C957";
              Q2:= X"0279B8544737";Q1:= X"07220DDBC5B1";Q0:= X"0A4A70F0D093";
              L1:= X"0724879419F8";L0:= X"0A4A70879B79";
      when "01011110" => 
              C3:= X"0092D149071A";C2:= X"027A93F59DD5";C1:= X"072701A42B15";C0:= X"0A5195786BE9";
              Q2:= X"027B702F89A9";Q1:= X"0727014C3FDA";Q0:= X"0A519578732A";
              L1:= X"07297CBC6F63";L0:= X"0A51950EF50A";
      when "01011111" => 
              C3:= X"009337317298";C2:= X"027C4C6954C5";C1:= X"072BF88498A1";C0:= X"0A58BEF536DB";
              Q2:= X"027D293C1742";Q1:= X"072BF82C7066";Q0:= X"0A58BEF53E21";
              L1:= X"072E7555AC7D";L0:= X"0A58BE8B76C9";
      when "01100000" => 
              C3:= X"00939D5E0DFB";C2:= X"027E060EB844";C1:= X"0730F2D71F60";C0:= X"0A5FED6A9B14";
              Q2:= X"027EE37AC58B";Q1:= X"0730F27EB9ED";Q0:= X"0A5FED6AA260";
              L1:= X"0733716234B1";L0:= X"0A5FED00919C";
      when "01100001" => 
              C3:= X"009403CEA093";C2:= X"027FC0E6B977";C1:= X"0735F09E2372";C0:= X"0A6720DC0BE0";
              Q2:= X"02809EEC6A81";Q1:= X"0735F04580AF";Q0:= X"0A6720DC1330";
              L1:= X"073870E46D18";L0:= X"0A672071B8CE";
      when "01100010" => 
              C3:= X"00946A8D0FDD";C2:= X"02817CF1FE45";C1:= X"073AF1DC0AED";C0:= X"0A6E594CFEEE";
              Q2:= X"02825B91D648";Q1:= X"073AF1832A97";Q0:= X"0A6E594D0643";
              L1:= X"073D73DEBC6D";L0:= X"0A6E58E2620F";
      when "01100011" => 
              C3:= X"0094D18487F7";C2:= X"02833A3196BC";C1:= X"073FF6933D3A";C0:= X"0A7596C0EC55";
              Q2:= X"0284196BE40F";Q1:= X"073FF63A1F35";Q0:= X"0A7596C0F3B0";
              L1:= X"07427A538B1A";L0:= X"0A7596560577";
      when "01100100" => 
              C3:= X"009538DFC355";C2:= X"0284F8A60B81";C1:= X"0744FEC623B8";C0:= X"0A7CD93B4E95";
              Q2:= X"0285D87B6215";Q1:= X"0744FE6CC7D3";Q0:= X"0A7CD93B55F5";
              L1:= X"074784454335";L0:= X"0A7CD8D01D85";
      when "01100101" => 
              C3:= X"0095A064A466";C2:= X"0286B8509F09";C1:= X"074A0A772924";C0:= X"0A8420BFA298";
              Q2:= X"028798C13211";Q1:= X"074A0A1D8F4B";Q0:= X"0A8420BFA9FD";
              L1:= X"074C91B6507E";L0:= X"0A8420542721";
      when "01100110" => 
              C3:= X"0096084B59C5";C2:= X"02887931B9D7";C1:= X"074F19A8BA52";C0:= X"0A8B6D5167B2";
              Q2:= X"02895A3E2847";Q1:= X"074F194EE23E";Q0:= X"0A8B6D516F1C";
              L1:= X"0751A2A92066";L0:= X"0A8B6CE5A1A1";
      when "01100111" => 
              C3:= X"009670690DB7";C2:= X"028A3B4A75F8";C1:= X"07542C5D456C";C0:= X"0A92BEF41FA7";
              Q2:= X"028B1CF314E2";Q1:= X"07542C032EFB";Q0:= X"0A92BEF42716";
              L1:= X"0756B7202210";L0:= X"0A92BE880EC7";
      when "01101000" => 
              C3:= X"0096D8DBE4C8";C2:= X"028BFE9B8E63";C1:= X"075942973A68";C0:= X"0A9A15AB4EA7";
              Q2:= X"028CE0E0D363";Q1:= X"0759423CE574";Q0:= X"0A9A15AB561B";
              L1:= X"075BCF1DC646";L0:= X"0A9A153EF2C6";
      when "01101001" => 
              C3:= X"00974185A6FA";C2:= X"028DC325FDB5";C1:= X"075E5C590AF0";C0:= X"0AA1717A7B56";
              Q2:= X"028EA60846BA";Q1:= X"075E5BFE7747";Q0:= X"0AA1717A82CF";
              L1:= X"0760EAA47F8F";L0:= X"0AA1710DD43F";
      when "01101010" => 
              C3:= X"0097AA7B7F50";C2:= X"028F88EA84D6";C1:= X"076379A52A61";C0:= X"0AA8D2652EC8";
              Q2:= X"02906C6A3C93";Q1:= X"0763794A57E1";Q0:= X"0AA8D2653647";
              L1:= X"076609B6C21C";L0:= X"0AA8D1F83C47";
      when "01101011" => 
              C3:= X"009813C2BDF3";C2:= X"02914FE9F401";C1:= X"07689A7E0DCC";C0:= X"0AB0386EF488";
              Q2:= X"02923407976C";Q1:= X"07689A22FC41";Q0:= X"0AB0386EFC0B";
              L1:= X"076B2C5703D8";L0:= X"0AB03801B668";
      when "01101100" => 
              C3:= X"00987D4E224F";C2:= X"029318252F8C";C1:= X"076DBEE62BF9";C0:= X"0AB7A39B5A93";
              Q2:= X"0293FCE12F11";Q1:= X"076DBE8ADB30";Q0:= X"0AB7A39B621C";
              L1:= X"07705287BC5D";L0:= X"0AB7A32DD0A1";
      when "01101101" => 
              C3:= X"0098E72B64C6";C2:= X"0294E19D11D6";C1:= X"0772E6DFFD59";C0:= X"0ABF13EDF162";
              Q2:= X"0295C6F7D409";Q1:= X"0772E6846D33";Q0:= X"0ABF13EDF8F0";
              L1:= X"07757C4B6507";L0:= X"0ABF13801B68";
      when "01101110" => 
              C3:= X"0099514C3AEB";C2:= X"0296AC528579";C1:= X"0778126DFC17";C0:= X"0AC6896A4BE3";
              Q2:= X"0297924C78DF";Q1:= X"077812122C5F";Q0:= X"0AC6896A5377";
              L1:= X"077AA9A478DA";L0:= X"0AC688FC29AD";
      when "01101111" => 
              C3:= X"0099BBBB623B";C2:= X"029878464E5F";C1:= X"077D4192A427";C0:= X"0ACE0413FF83";
              Q2:= X"02995EDFE8DA";Q1:= X"077D413694B2";Q0:= X"0ACE0414071C";
              L1:= X"077FDA95749B";L0:= X"0ACE03A590DC";
      when "01110000" => 
              C3:= X"009A2667A385";C2:= X"029A457967E7";C1:= X"07827450731A";C0:= X"0AD583EEA429";
              Q2:= X"029B2CB30B65";Q1:= X"078273F423C3";Q0:= X"0AD583EEABC7";
              L1:= X"07850F20D6CF";L0:= X"0AD5837FE8DC";
      when "01110001" => 
              C3:= X"009A91693E66";C2:= X"029C13EC94BD";C1:= X"0787AAA9E85D";C0:= X"0ADD08FDD43C";
              Q2:= X"029CFBC6B0E9";Q1:= X"0787AA4D58F8";Q0:= X"0ADD08FDDBDF";
              L1:= X"078A47491FA9";L0:= X"0ADD088ECC13";
      when "01110010" => 
              C3:= X"009AFCC29C1D";C2:= X"029DE3A0AB88";C1:= X"078CE4A18501";C0:= X"0AE493452CA2";
              Q2:= X"029ECC1BC79B";Q1:= X"078CE444B55B";Q0:= X"0AE49345344B";
              L1:= X"078F8310D123";L0:= X"0AE492D5D769";
      when "01110011" => 
              C3:= X"009B68317FD3";C2:= X"029FB496DF1D";C1:= X"07922239CBCA";C0:= X"0AEC22C84CC5";
              Q2:= X"02A09DB329F6";Q1:= X"079221DCBBC4";Q0:= X"0AEC22C85473";
              L1:= X"0794C27A6EEC";L0:= X"0AEC2258AA45";
      when "01110100" => 
              C3:= X"009BD42ED542";C2:= X"02A186CF6B29";C1:= X"07976375417B";C0:= X"0AF3B78AD690";
              Q2:= X"02A2708DB0D9";Q1:= X"07976317F0CD";Q0:= X"0AF3B78ADE43";
              L1:= X"079A05887E7E";L0:= X"0AF3B71AE694";
      when "01110101" => 
              C3:= X"009C404D86F8";C2:= X"02A35A4BC44E";C1:= X"079CA8566C3A";C0:= X"0AFB51906E75";
              Q2:= X"02A444AC3F4D";Q1:= X"079CA7F8DAC6";Q0:= X"0AFB5190762D";
              L1:= X"079F4C3D8704";L0:= X"0AFB512030C7";
      when "01110110" => 
              C3:= X"009CACCCD7B0";C2:= X"02A52F0C888D";C1:= X"07A1F0DFD420";C0:= X"0B02F0DCBB6D";
              Q2:= X"02A61A0FBF5E";Q1:= X"07A1F08201B6";Q0:= X"0B02F0DCC32B";
              L1:= X"07A4969C1176";L0:= X"0B02F06C2FD8";
      when "01110111" => 
              C3:= X"009D197EF029";C2:= X"02A70512C53D";C1:= X"07A73D140304";C0:= X"0B0A957366FB";
              Q2:= X"02A7F0B90552";Q1:= X"07A73CB5EF84";Q0:= X"0B0A95736EBE";
              L1:= X"07A9E4A6A88B";L0:= X"0B0A95028D47";
      when "01111000" => 
              C3:= X"009D8680DAC4";C2:= X"02A8DC5F3AE8";C1:= X"07AC8CF58480";C0:= X"0B123F581D2A";
              Q2:= X"02A9C8A8FABC";Q1:= X"07AC8C972FBB";Q0:= X"0B123F5824F3";
              L1:= X"07AF365FD8B7";L0:= X"0B123EE6F523";
      when "01111001" => 
              C3:= X"009DF3DB01AD";C2:= X"02AAB4F2B4E2";C1:= X"07B1E086E5FF";C0:= X"0B19EE8E8C94";
              Q2:= X"02ABA1E08171";Q1:= X"07B1E0284FBB";Q0:= X"0B19EE8E9462";
              L1:= X"07B48BCA303E";L0:= X"0B19EE1D1603";
      when "01111010" => 
              C3:= X"009E618043ED";C2:= X"02AC8ECE38D7";C1:= X"07B737CAB690";C0:= X"0B21A31A6661";
              Q2:= X"02AD7C607590";Q1:= X"07B7376BDEAC";Q0:= X"0B21A31A6E34";
              L1:= X"07B9E4E83F21";L0:= X"0B21A2A8A10E";
      when "01111011" => 
              C3:= X"009ECF635321";C2:= X"02AE69F2B83F";C1:= X"07BC92C3871B";C0:= X"0B295CFF5E47";
              Q2:= X"02AF5829D038";Q1:= X"07BC92646D60";Q0:= X"0B295CFF6620";
              L1:= X"07BF41BC9731";L0:= X"0B295C8D49FD";
      when "01111100" => 
              C3:= X"009F3DAFEE63";C2:= X"02B04660D570";C1:= X"07C1F173EA62";C0:= X"0B311C412A90";
              Q2:= X"02B1353D5D4A";Q1:= X"07C1F1148E9F";Q0:= X"0B311C41326F";
              L1:= X"07C4A249CBFD";L0:= X"0B311BCEC718";
      when "01111101" => 
              C3:= X"009FAC3222F6";C2:= X"02B22419BFF0";C1:= X"07C753DE74CE";C0:= X"0B38E0E38419";
              Q2:= X"02B3139C0A65";Q1:= X"07C7537ED6DC";Q0:= X"0B38E0E38BFD";
              L1:= X"07CA069272E6";L0:= X"0B38E070D13C";
      when "01111110" => 
              C3:= X"00A01B035BEB";C2:= X"02B4031E3F7F";C1:= X"07CCBA05BCA1";C0:= X"0B40AAEA2654";
              Q2:= X"02B4F346C3A0";Q1:= X"07CCB9A5DC52";Q0:= X"0B40AAEA2E3D";
              L1:= X"07CF6E992316";L0:= X"0B40AA7723DA";
      when "01111111" => 
              C3:= X"00A08A275B58";C2:= X"02B5E36F32AB";C1:= X"07D223EC59F0";C0:= X"0B487A58CF4A";
              Q2:= X"02B6D43E6B45";Q1:= X"07D2238C3718";Q0:= X"0B487A58D739";
              L1:= X"07D4DA607583";L0:= X"0B4879E57CFC";
      when "10000000" => 
              C3:= X"00A0F996FDE2";C2:= X"02B7C50D86A8";C1:= X"07D79194E69E";C0:= X"0B504F333F9D";
              Q2:= X"02B8B683E623";Q1:= X"07D791348108";Q0:= X"0B504F334791";
              L1:= X"07DA49EB04EF";L0:= X"0B504EBF9D45";
      when "10000001" => 
              C3:= X"00A16945A5E7";C2:= X"02B9A7FA36DE";C1:= X"07DD0301FE42";C0:= X"0B58297D3A8B";
              Q2:= X"02BA9A181D50";Q1:= X"07DD02A155CD";Q0:= X"0B58297D4285";
              L1:= X"07DFBD3B6DE9";L0:= X"0B58290947F0";
      when "10000010" => 
              C3:= X"00A1D9549DE3";C2:= X"02BB8C35FEE5";C1:= X"07E278363E6F";C0:= X"0B60093A85EC";
              Q2:= X"02BC7EFBFC1D";Q1:= X"07E277D552DF";Q0:= X"0B60093A8DEC";
              L1:= X"07E534544EDC";L0:= X"0B6008C642D7";
      when "10000011" => 
              C3:= X"00A249A8740A";C2:= X"02BD71C1EE3D";C1:= X"07E7F134465B";C0:= X"0B67EE6EEA3A";
              Q2:= X"02BE653067E2";Q1:= X"07E7F0D3178B";Q0:= X"0B67EE6EF23F";
              L1:= X"07EAAF3847F2";L0:= X"0B67EDFA5673";
      when "10000100" => 
              C3:= X"00A2BA4E211F";C2:= X"02BF589ED8A7";C1:= X"07ED6DFEB732";C0:= X"0B6FD91E328C";
              Q2:= X"02C04CB64C2D";Q1:= X"07ED6D9D44EB";Q0:= X"0B6FD91E3A97";
              L1:= X"07F02DE9FB36";L0:= X"0B6FD8A94DDB";
      when "10000101" => 
              C3:= X"00A32B4C9F13";C2:= X"02C140CDA0DB";C1:= X"07F2EE9833E4";C0:= X"0B77C94C2C9D";
              Q2:= X"02C2358E93D3";Q1:= X"07F2EE367DEE";Q0:= X"0B77C94C34AD";
              L1:= X"07F5B06C0C81";L0:= X"0B77C8D6F6C9";
      when "10000110" => 
              C3:= X"00A39C839A5E";C2:= X"02C32A4F6066";C1:= X"07F87303611D";C0:= X"0B7FBEFCA8C9";
              Q2:= X"02C41FBA2949";Q1:= X"07F872A16758";Q0:= X"0B7FBEFCB0DF";
              L1:= X"07FB36C12182";L0:= X"0B7FBE87219B";
      when "10000111" => 
              C3:= X"00A40E0F65F6";C2:= X"02C51524DEB8";C1:= X"07FDFB42E58A";C0:= X"0B87BA337A16";
              Q2:= X"02C60B39FA8A";Q1:= X"07FDFAE0A7C3";Q0:= X"0B87BA338232";
              L1:= X"0800C0EBE1BF";L0:= X"0B87B9BDA155";
      when "10001000" => 
              C3:= X"00A47FF8DD65";C2:= X"02C7014EEE7B";C1:= X"0803875969A3";C0:= X"0B8FBAF4762F";
              Q2:= X"02C7F80EE30D";Q1:= X"080386F6E7AE";Q0:= X"0B8FBAF47E50";
              L1:= X"08064EEEF693";L0:= X"0B8FBA7E4BA1";
      when "10001001" => 
              C3:= X"00A4F2157C47";C2:= X"02C8EECEC7BD";C1:= X"080917499799";C0:= X"0B97C1437567";
              Q2:= X"02C9E639E26C";Q1:= X"080916E6D150";Q0:= X"0B97C1437D8E";
              L1:= X"080BE0CD0B34";L0:= X"0B97C0CCF8D5";
      when "10001010" => 
              C3:= X"00A56496AB5A";C2:= X"02CADDA5037F";C1:= X"080EAB161BA8";C0:= X"0B9FCD2452C0";
              Q2:= X"02CBD5BBE7D9";Q1:= X"080EAAB310CA";Q0:= X"0B9FCD245AEC";
              L1:= X"08117688CCB2";L0:= X"0B9FCCAD83F0";
      when "10001011" => 
              C3:= X"00A5D75A9183";C2:= X"02CCCDD2C740";C1:= X"081442C1A3C0";C0:= X"0BA7DE9AEBE5";
              Q2:= X"02CDC695CD01";Q1:= X"0814425E542C";Q0:= X"0BA7DE9AF417";
              L1:= X"08171024E9FD";L0:= X"0BA7DE23CA9F";
      when "10001100" => 
              C3:= X"00A64A7D8FA2";C2:= X"02CEBF58E092";C1:= X"0819DE4EDFBF";C0:= X"0BAFF5AB2133";
              Q2:= X"02CFB8C89AA8";Q1:= X"0819DDEB4B3C";Q0:= X"0BAFF5AB296B";
              L1:= X"081CADA413D5";L0:= X"0BAFF533AD3D";
      when "10001101" => 
              C3:= X"00A6BDEF4277";C2:= X"02D0B2384D2C";C1:= X"081F7DC0815F";C0:= X"0BB81258D5B6";
              Q2:= X"02D1AC552F07";Q1:= X"081F7D5CA7B7";Q0:= X"0BB81258DDF3";
              L1:= X"08224F08FCE6";L0:= X"0BB811E10ED7";
      when "10001110" => 
              C3:= X"00A731A703B3";C2:= X"02D2A67203ED";C1:= X"082521193C2F";C0:= X"0BC034A7EF2E";
              Q2:= X"02D3A13C826C";Q1:= X"082520B51D35";Q0:= X"0BC034A7F771";
              L1:= X"0827F45659B9";L0:= X"0BC0342FD52C";
      when "10001111" => 
              C3:= X"00A7A5B33C44";C2:= X"02D49C06E7A2";C1:= X"082AC85BC5AE";C0:= X"0BC85C9C560E";
              Q2:= X"02D5977F78E3";Q1:= X"082AC7F76132";Q0:= X"0BC85C9C5E56";
              L1:= X"082D9D8EE0AC";L0:= X"0BC85C23E8B0";
      when "10010000" => 
              C3:= X"00A81A11A202";C2:= X"02D692F7F54C";C1:= X"0830738AD523";C0:= X"0BD08A39F580";
              Q2:= X"02D78F1F11A8";Q1:= X"083073262AFB";Q0:= X"0BD08A39FDCE";
              L1:= X"08334AB54A0F";L0:= X"0BD089C1348C";
      when "10010001" => 
              C3:= X"00A88EBE38FC";C2:= X"02D88B4615F1";C1:= X"083622A923D6";C0:= X"0BD8BD84BB67";
              Q2:= X"02D9881C2FEA";Q1:= X"0836224433D7";Q0:= X"0BD8BD84C3BB";
              L1:= X"0838FBCC5008";L0:= X"0BD8BD0BA6A3";
      when "10010010" => 
              C3:= X"00A903C355D9";C2:= X"02DA84F23BE5";C1:= X"083BD5B96CDE";C0:= X"0BE0F6809860";
              Q2:= X"02DB8277DEDD";Q1:= X"083BD55436CB";Q0:= X"0BE0F680A0BA";
              L1:= X"083EB0D6AEAB";L0:= X"0BE0F6072F91";
      when "10010011" => 
              C3:= X"00A97900898D";C2:= X"02DC7FFD794B";C1:= X"08418CBE6D3E";C0:= X"0BE935317FC3";
              Q2:= X"02DD7E32F9B3";Q1:= X"08418C58F0F2";Q0:= X"0BE935318822";
              L1:= X"084469D723ED";L0:= X"0BE934B7C2AF";
      when "10010100" => 
              C3:= X"00A9EEAE90AA";C2:= X"02DE7C68759B";C1:= X"084747BAE3F3";C0:= X"0BF1799B67A6";
              Q2:= X"02DF7B4E81D0";Q1:= X"084747552129";Q0:= X"0BF1799B700C";
              L1:= X"084A26D06FAB";L0:= X"0BF179215613";
      when "10010101" => 
              C3:= X"00AA649D4DCA";C2:= X"02E07A347BD7";C1:= X"084D06B191A3";C0:= X"0BF9C3C248E1";
              Q2:= X"02E179CB657A";Q1:= X"084D064B8846";Q0:= X"0BF9C3C2514D";
              L1:= X"084FE7C553A9";L0:= X"0BF9C347E295";
      when "10010110" => 
              C3:= X"00AADAE80A25";C2:= X"02E279623828";C1:= X"0852C9A53945";C0:= X"0C0213AA1F0C";
              Q2:= X"02E379AA95F9";Q1:= X"0852C93EE909";Q0:= X"0C0213AA277E";
              L1:= X"0855ACB8939F";L0:= X"0C02132F63CB";
      when "10010111" => 
              C3:= X"00AB51811B55";C2:= X"02E479F2CCEC";C1:= X"085890989F4F";C0:= X"0C0A6956E883";
              Q2:= X"02E57AED11FA";Q1:= X"08589032080E";Q0:= X"0C0A6956F0FA";
              L1:= X"085B75ACF520";L0:= X"0C0A68DBD811";
      when "10011000" => 
              C3:= X"00ABC8696181";C2:= X"02E67BE72F7F";C1:= X"085E5B8E8A59";C0:= X"0C12C4CCA666";
              Q2:= X"02E77D93D4BB";Q1:= X"085E5B27ABDE";Q0:= X"0C12C4CCAEE3";
              L1:= X"086142A53FB3";L0:= X"0C12C451408A";
      when "10011001" => 
              C3:= X"00AC3F943A64";C2:= X"02E87F4066FC";C1:= X"08642A89C2DF";C0:= X"0C1B260F5CA0";
              Q2:= X"02E9819FC5D7";Q1:= X"08642A229D0F";Q0:= X"0C1B260F6523";
              L1:= X"086713A43CD5";L0:= X"0C1B2593A11E";
      when "10011010" => 
              C3:= X"00ACB71EA5D9";C2:= X"02EA83FF3A79";C1:= X"0869FD8D135D";C0:= X"0C238D2311E3";
              Q2:= X"02EB8711E2D3";Q1:= X"0869FD25A601";Q0:= X"0C238D231A6C";
              L1:= X"086CE8ACB7E2";L0:= X"0C238CA7007F";
      when "10011011" => 
              C3:= X"00AD2F03884B";C2:= X"02EC8A24AF4A";C1:= X"086FD49B4833";C0:= X"0C2BFA0BCFAD";
              Q2:= X"02ED8DEB2E9C";Q1:= X"086FD4339307";Q0:= X"0C2BFA0BD83B";
              L1:= X"0872C1C17E36";L0:= X"0C2BF98F682C";
      when "10011100" => 
              C3:= X"00ADA73FB445";C2:= X"02EE91B1BD71";C1:= X"0875AFB72FAA";C0:= X"0C346CCDA249";
              Q2:= X"02EF962C9AF6";Q1:= X"0875AF4F3279";Q0:= X"0C346CCDAADD";
              L1:= X"08789EE55F14";L0:= X"0C346C50E46F";
      when "10011101" => 
              C3:= X"00AE1FCC4C3E";C2:= X"02F09AA76467";C1:= X"087B8EE39A02";C0:= X"0C3CE56C98D1";
              Q2:= X"02F19FD71BBC";Q1:= X"087B8E7B549A";Q0:= X"0C3CE56CA16C";
              L1:= X"087E801B2BB6";L0:= X"0C3CE4EF8463";
      when "10011110" => 
              C3:= X"00AE98AEE613";C2:= X"02F2A506A82D";C1:= X"088172235966";C0:= X"0C4563ECC532";
              Q2:= X"02F3AAEBAF8B";Q1:= X"088171BACB9D";Q0:= X"0C4563ECCDD3";
              L1:= X"08846565B74E";L0:= X"0C45636F59F3";
      when "10011111" => 
              C3:= X"00AF11CE9D37";C2:= X"02F4B0D0A44F";C1:= X"0887597941F5";C0:= X"0C4DE8523C2B";
              Q2:= X"02F5B76B5B3E";Q1:= X"088759106BA2";Q0:= X"0C4DE85244D2";
              L1:= X"088A4EC7D6FF";L0:= X"0C4DE7D479DE";
      when "10100000" => 
              C3:= X"00AF8B55AEC1";C2:= X"02F6BE061104";C1:= X"088D44E829E7";C0:= X"0C5672A11550";
              Q2:= X"02F7C5570F69";Q1:= X"088D447F0AD5";Q0:= X"0C5672A11DFC";
              L1:= X"08903C4461E5";L0:= X"0C567222FBB9";
      when "10100001" => 
              C3:= X"00B0053DE040";C2:= X"02F8CCA7EE6F";C1:= X"08933472E95B";C0:= X"0C5F02DD6B0B";
              Q2:= X"02F9D4AFCAF8";Q1:= X"08933409814A";Q0:= X"0C5F02DD73BE";
              L1:= X"08962DDE3116";L0:= X"0C5F025EF9EE";
      when "10100010" => 
              C3:= X"00B07F57C01C";C2:= X"02FADCB78549";C1:= X"0899281C5A47";C0:= X"0C67990B5AA1";
              Q2:= X"02FBE5768B3B";Q1:= X"089927B2A915";Q0:= X"0C67990B635A";
              L1:= X"089C23981F9E";L0:= X"0C67988C91C2";
      when "10100011" => 
              C3:= X"00B0F9E3ABBF";C2:= X"02FCEE358803";C1:= X"089F1FE758C2";C0:= X"0C70352F0433";
              Q2:= X"02FDF7AC5874";Q1:= X"089F1F7D5E33";Q0:= X"0C70352F0CF1";
              L1:= X"08A21D750A8C";L0:= X"0C7034AFE353";
      when "10100100" => 
              C3:= X"00B174B646C3";C2:= X"02FF01230F1A";C1:= X"08A51BD6C2E5";C0:= X"0C78D74C8ABB";
              Q2:= X"03000B521F0F";Q1:= X"08A51B6C7EC4";Q0:= X"0C78D74C9380";
              L1:= X"08A81B77D0E2";L0:= X"0C78D6CD119E";
      when "10100101" => 
              C3:= X"00B1EFE885A3";C2:= X"0301158110EE";C1:= X"08AB1BED78A5";C0:= X"0C817F681415";
              Q2:= X"03022068E8ED";Q1:= X"08AB1B82EAC4";Q0:= X"0C817F681CE0";
              L1:= X"08AE1DA353AA";L0:= X"0C817EE8427F";
      when "10100110" => 
              C3:= X"00B26B68156D";C2:= X"03032B509ED4";C1:= X"08B1202E5C0B";C0:= X"0C8A2D85C8FF";
              Q2:= X"030436F1BB7F";Q1:= X"08B11FC3842C";Q0:= X"0C8A2D85D1D0";
              L1:= X"08B423FA75E7";L0:= X"0C8A2D059EB1";
      when "10100111" => 
              C3:= X"00B2E7335C2D";C2:= X"03054292BDAA";C1:= X"08B7289C5110";C0:= X"0C92E1A9D517";
              Q2:= X"03064EED8D8A";Q1:= X"08B728312F0F";Q0:= X"0C92E1A9DDEE";
              L1:= X"08BA2E801C9C";L0:= X"0C92E12951D4";
      when "10101000" => 
              C3:= X"00B36364A8F4";C2:= X"03075B484F51";C1:= X"08BD353A3DCD";C0:= X"0C9B9BD866E2";
              Q2:= X"0308685D612B";Q1:= X"08BD34CED173";Q0:= X"0C9B9BD86FBF";
              L1:= X"08C03D372ED6";L0:= X"0C9B9B578A6C";
      when "10101001" => 
              C3:= X"00B3DFE49A3B";C2:= X"030975726BF7";C1:= X"08C3460B0A40";C0:= X"0CA45C15AFCC";
              Q2:= X"030A83424199";Q1:= X"08C3459F535B";Q0:= X"0CA45C15B8AF";
              L1:= X"08C65022959D";L0:= X"0CA45B9479E5";
      when "10101010" => 
              C3:= X"00B45CBB2BA7";C2:= X"030B91121238";C1:= X"08C95B11A084";C0:= X"0CAD2265E428";
              Q2:= X"030C9F9D30E3";Q1:= X"08C95AA59ED0";Q0:= X"0CAD2265ED12";
              L1:= X"08CC67453C04";L0:= X"0CAD21E45492";
      when "10101011" => 
              C3:= X"00B4D9F6A7D8";C2:= X"030DAE282E44";C1:= X"08CF7450ECAC";C0:= X"0CB5EECD3B37";
              Q2:= X"030EBD6F262E";Q1:= X"08CF73E49FFA";Q0:= X"0CB5EECD4427";
              L1:= X"08D282A20F22";L0:= X"0CB5EE4B51B4";
      when "10101100" => 
              C3:= X"00B557724577";C2:= X"030FCCB5FBFA";C1:= X"08D591CBDCB7";C0:= X"0CBEC14FEF26";
              Q2:= X"0310DCB927A4";Q1:= X"08D5915F44EB";Q0:= X"0CBEC14FF81C";
              L1:= X"08D8A23BFE14";L0:= X"0CBEC0CDAB78";
      when "10101101" => 
              C3:= X"00B5D55A7CF4";C2:= X"0311ECBC3DBF";C1:= X"08DBB38560F8";C0:= X"0CC799F23D10";
              Q2:= X"0312FD7C4A38";Q1:= X"08DBB3187DBA";Q0:= X"0CC799F2460D";
              L1:= X"08DEC615FA05";L0:= X"0CC7996F9EF8";
      when "10101110" => 
              C3:= X"00B653820967";C2:= X"03140E3C4033";C1:= X"08E1D9806B69";C0:= X"0CD078B86503";
              Q2:= X"03151FB9888D";Q1:= X"08E1D9133CA1";Q0:= X"0CD078B86E05";
              L1:= X"08E4EE32F628";L0:= X"0CD078356C41";
      when "10101111" => 
              C3:= X"00B6D2286626";C2:= X"03163136A530";C1:= X"08E803BFF073";C0:= X"0CD95DA6A9FE";
              Q2:= X"03174371E527";Q1:= X"08E8035275DA";Q0:= X"0CD95DA6B307";
              L1:= X"08EB1A95E7C0";L0:= X"0CD95D235654";
      when "10110000" => 
              C3:= X"00B750FA9609";C2:= X"031855ACF206";C1:= X"08EE3246E632";C0:= X"0CE248C151F7";
              Q2:= X"031968A66DC6";Q1:= X"08EE31D91FA9";Q0:= X"0CE248C15B06";
              L1:= X"08F14B41C616";L0:= X"0CE2483DA327";
      when "10110001" => 
              C3:= X"00B7D03D5A2D";C2:= X"031A7B9FC97F";C1:= X"08F465184520";C0:= X"0CEB3A0CA5DB";
              Q2:= X"031B8F5824E5";Q1:= X"08F464AA3262";Q0:= X"0CEB3A0CAEF1";
              L1:= X"08F780398A88";L0:= X"0CEB39889BA5";
      when "10110010" => 
              C3:= X"00B84FC885D8";C2:= X"031CA3106B77";C1:= X"08FA9C370788";C0:= X"0CF4318CF191";
              Q2:= X"031DB78816D0";Q1:= X"08FA9BC8A86B";Q0:= X"0CF4318CFAAC";
              L1:= X"08FDB9803081";L0:= X"0CF431088BB4";
      when "10110011" => 
              C3:= X"00B8CFC31F87";C2:= X"031ECBFFB0AD";C1:= X"0900D7A629F4";C0:= X"0CFD2F4683F8";
              Q2:= X"031FE137534A";Q1:= X"0900D7377E2F";Q0:= X"0CFD2F468D1A";
              L1:= X"0903F718B582";L0:= X"0CFD2EC1C237";
      when "10110100" => 
              C3:= X"00B95010660B";C2:= X"0320F66EC516";C1:= X"09071768AAD8";C0:= X"0D06333DAEF2";
              Q2:= X"03220C66E24C";Q1:= X"090716F9B23B";Q0:= X"0D06333DB81A";
              L1:= X"090A3906191D";L0:= X"0D0632B8910B";
      when "10110101" => 
              C3:= X"00B9D0A53002";C2:= X"0323225EC7C2";C1:= X"090D5B818ACE";C0:= X"0D0F3D76C75B";
              Q2:= X"03243917B826";Q1:= X"090D5B124540";Q0:= X"0D0F3D76D08A";
              L1:= X"09107F4B5CF7";L0:= X"0D0F3CF14D10";
      when "10110110" => 
              C3:= X"00BA518FF030";C2:= X"03254FD0B0CF";C1:= X"0913A3F3CC92";C0:= X"0D184DF62516";
              Q2:= X"0326674B0255";Q1:= X"0913A38439CC";Q0:= X"0D184DF62E4B";
              L1:= X"0916C9EB84CE";L0:= X"0D184D704E25";
      when "10110111" => 
              C3:= X"00BAD2E6B018";C2:= X"03277EC55CEC";C1:= X"0919F0C27500";C0:= X"0D2164C02304";
              Q2:= X"03289701BA7B";Q1:= X"0919F05294BE";Q0:= X"0D2164C02C40";
              L1:= X"091D18E99677";L0:= X"0D216439EF2E";
      when "10111000" => 
              C3:= X"00BB549ED70B";C2:= X"0329AF3E016A";C1:= X"092041F08ADD";C0:= X"0D2A81D91F12";
              Q2:= X"032AC83CEA03";Q1:= X"092041805CF6";Q0:= X"0D2A81D92854";
              L1:= X"09236C4899DE";L0:= X"0D2A81528E15";
      when "10111001" => 
              C3:= X"00BBD6970D1B";C2:= X"032BE13BC3DE";C1:= X"092697811726";C0:= X"0D33A5457A2F";
              Q2:= X"032CFAFDA99E";Q1:= X"092697109B65";Q0:= X"0D33A5458377";
              L1:= X"0929C40B990C";L0:= X"0D33A4BE8BCC";
      when "10111010" => 
              C3:= X"00BC59032187";C2:= X"032E14BF7646";C1:= X"092CF1772508";C0:= X"0D3CCF099859";
              Q2:= X"032F2F4501EA";Q1:= X"092CF1065B26";Q0:= X"0D3CCF09A1A7";
              L1:= X"09302035A028";L0:= X"0D3CCE824C4E";
      when "10111011" => 
              C3:= X"00BCDBB55464";C2:= X"033049CA6A72";C1:= X"09334FD5C191";C0:= X"0D45FF29E096";
              Q2:= X"033165140305";Q1:= X"09334F64A96C";Q0:= X"0D45FF29E9EB";
              L1:= X"093680C9BD6F";L0:= X"0D45FEA236A4";
      when "10111100" => 
              C3:= X"00BD5ECA199C";C2:= X"0332805D8AB3";C1:= X"0939B29FFC2B";C0:= X"0D4F35AABCFE";
              Q2:= X"03339C6BB4BD";Q1:= X"0939B22E9591";Q0:= X"0D4F35AAC65A";
              L1:= X"093CE5CB0144";L0:= X"0D4F3522B4E2";
      when "10111101" => 
              C3:= X"00BDE23FAAF3";C2:= X"0334B879D3A2";C1:= X"094019D8E64B";C0:= X"0D5872909AB6";
              Q2:= X"0335D54D3C6E";Q1:= X"0940196730EA";Q0:= X"0D587290A419";
              L1:= X"09434F3C7E29";L0:= X"0D587208342F";
      when "10111110" => 
              C3:= X"00BE6607F793";C2:= X"0336F2208B24";C1:= X"094685839369";C0:= X"0D61B5DFE9F9";
              Q2:= X"03380FB98F4A";Q1:= X"094685118F31";Q0:= X"0D61B5DFF361";
              L1:= X"0949BD2148C0";L0:= X"0D61B55724C5";
      when "10111111" => 
              C3:= X"00BEEA33766E";C2:= X"03392D528FA7";C1:= X"094CF5A31956";C0:= X"0D6AFF9D1E13";
              Q2:= X"033A4BB1DA2C";Q1:= X"094CF530C5F6";Q0:= X"0D6AFF9D2782";
              L1:= X"09502F7C77D2";L0:= X"0D6AFF13F9F1";
      when "11000000" => 
              C3:= X"00BF6EA377C1";C2:= X"033B6A112697";C1:= X"09536A3A8FDC";C0:= X"0D744FCCAD69";
              Q2:= X"033C89371D83";Q1:= X"095369C7ED27";Q0:= X"0D744FCCB6DF";
              L1:= X"0956A6512444";L0:= X"0D744F432A17";
      when "11000001" => 
              C3:= X"00BFF390A5D3";C2:= X"033DA85D23B1";C1:= X"0959E34D10FE";C0:= X"0D7DA6731179";
              Q2:= X"033EC84A7D48";Q1:= X"0959E2DA1EB0";Q0:= X"0D7DA6731AF5";
              L1:= X"095D21A2692B";L0:= X"0D7DA5E92EB4";
      when "11000010" => 
              C3:= X"00C078D53CF9";C2:= X"033FE837BD96";C1:= X"096060DDB8E5";C0:= X"0D870394C6DA";
              Q2:= X"034108ECFB63";Q1:= X"0960606A76CA";Q0:= X"0D870394D05D";
              L1:= X"0963A17363C5";L0:= X"0D87030A8462";
      when "11000011" => 
              C3:= X"00C0FE6DC7DE";C2:= X"034229A20E8B";C1:= X"0966E2EFA5DA";C0:= X"0D9067364D44";
              Q2:= X"03434B1FB47C";Q1:= X"0966E27C13BD";Q0:= X"0D90673656CD";
              L1:= X"096A25C7336F";L0:= X"0D9066ABAAD4";
      when "11000100" => 
              C3:= X"00C18461BF02";C2:= X"03446C9D3283";C1:= X"096D6985F849";C0:= X"0D99D15C278A";
              Q2:= X"03458EE3C5FC";Q1:= X"096D691215F1";Q0:= X"0D99D15C311A";
              L1:= X"0970AEA0F9B8";L0:= X"0D99D0D124E1";
      when "11000101" => 
              C3:= X"00C20ABC15AE";C2:= X"0346B12A1C42";C1:= X"0973F4A3D2ED";C0:= X"0DA3420ADBA4";
              Q2:= X"0347D43A3ECA";Q1:= X"0973F42FA01D";Q0:= X"0DA3420AE53B";
              L1:= X"09773C03DA5C";L0:= X"0DA3417F787F";
      when "11000110" => 
              C3:= X"00C29160CBE0";C2:= X"0348F74A1A44";C1:= X"097A844C5A7E";C0:= X"0DACB946F2AC";
              Q2:= X"034A1B2433C1";Q1:= X"097A83D7D70B";Q0:= X"0DACB946FC49";
              L1:= X"097DCDF2FB41";L0:= X"0DACB8BB2EC7";
      when "11000111" => 
              C3:= X"00C3185E974E";C2:= X"034B3EFE2885";C1:= X"09811882B605";C0:= X"0DB63714F8E2";
              Q2:= X"034C63A2C133";Q1:= X"0981180DE1BB";Q0:= X"0DB637150286";
              L1:= X"09846471847C";L0:= X"0DB63688D3FB";
      when "11001000" => 
              C3:= X"00C39FD5D0A3";C2:= X"034D88474222";C1:= X"0987B14A0EB6";C0:= X"0DBFBB797DAE";
              Q2:= X"034EADB7003A";Q1:= X"0987B0D4E95B";Q0:= X"0DBFBB798759";
              L1:= X"098AFF82A05C";L0:= X"0DBFBAECF782";
      when "11001001" => 
              C3:= X"00C427987D81";C2:= X"034FD326A3C7";C1:= X"098E4EA58FF4";C0:= X"0DC9467913A4";
              Q2:= X"0350F962081C";Q1:= X"098E4E30194D";Q0:= X"0DC946791D55";
              L1:= X"09919F297B53";L0:= X"0DC945EC2BEF";
      when "11001010" => 
              C3:= X"00C4AFC1E4E9";C2:= X"03521F9D4A95";C1:= X"0994F098675F";C0:= X"0DD2D8185082";
              Q2:= X"035346A4F2F1";Q1:= X"0994F0229F23";Q0:= X"0DD2D8185A3A";
              L1:= X"099843694417";L0:= X"0DD2D78B0700";
      when "11001011" => 
              C3:= X"00C5384C6ED2";C2:= X"03546DAC6B7E";C1:= X"099B9725C49F";C0:= X"0DDC705BCD37";
              Q2:= X"03559580E046";Q1:= X"099B96AFAAAA";Q0:= X"0DDC705BD6F5";
              L1:= X"099EEC452B89";L0:= X"0DDC6FCE21A4";
      when "11001100" => 
              C3:= X"00C5C122AB7A";C2:= X"0356BD553347";C1:= X"09A24250D9C7";C0:= X"0DE60F4825E0";
              Q2:= X"0357E5F6E6C2";Q1:= X"09A241DA6DDB";Q0:= X"0DE60F482FA6";
              L1:= X"09A599C064C2";L0:= X"0DE60EBA17F8";
      when "11001101" => 
              C3:= X"00C64A625B16";C2:= X"03590E989194";C1:= X"09A8F21CDB0E";C0:= X"0DEFB4E1F9D0";
              Q2:= X"035A380826F8";Q1:= X"09A8F1A61CF0";Q0:= X"0DEFB4E2039C";
              L1:= X"09AC4BDE2517";L0:= X"0DEFB453894F";
      when "11001110" => 
              C3:= X"00C6D4150C60";C2:= X"035B617798F7";C1:= X"09AFA68CFEEE";C0:= X"0DF9612DEB8E";
              Q2:= X"035C8BB5B665";Q1:= X"09AFA615EE61";Q0:= X"0DF9612DF561";
              L1:= X"09B302A1A417";L0:= X"0DF9609F1830";
      when "11001111" => 
              C3:= X"00C75E03116E";C2:= X"035DB5F3B742";C1:= X"09B65FA47DF6";C0:= X"0E031430A0D9";
              Q2:= X"035EE100C406";Q1:= X"09B65F2D1AC4";Q0:= X"0E031430AAB3";
              L1:= X"09B9BE0E1B89";L0:= X"0E0313A16A58";
      when "11010000" => 
              C3:= X"00C7E88966D2";C2:= X"03600C0D8EF4";C1:= X"09BD1D669333";C0:= X"0E0CCDEEC2A8";
              Q2:= X"036137EA5F63";Q1:= X"09BD1CEEDD15";Q0:= X"0E0CCDEECC89";
              L1:= X"09C07E26C772";L0:= X"0E0CCD5F28C1";
      when "11010001" => 
              C3:= X"00C873209002";C2:= X"036263C6F881";C1:= X"09C3DFD67B8C";C0:= X"0E168E6CFD32";
              Q2:= X"03639073ACE7";Q1:= X"09C3DF5E7270";Q0:= X"0E168E6D0719";
              L1:= X"09C742EEE61B";L0:= X"0E168DDCFF9E";
      when "11010010" => 
              C3:= X"00C8FE539676";C2:= X"0364BD205347";C1:= X"09CAA6F776AF";C0:= X"0E2055AFFFE7";
              Q2:= X"0365EA9DCBFC";Q1:= X"09CAA67F1A3E";Q0:= X"0E2055B009D6";
              L1:= X"09CE0C69B808";L0:= X"0E20551F9E63";
      when "11010011" => 
              C3:= X"00C989C8A9C4";C2:= X"0367181B3A3F";C1:= X"09D172CCC60F";C0:= X"0E2A23BC7D7D";
              Q2:= X"03684669DFA3";Q1:= X"09D172541620";Q0:= X"0E2A23BC8772";
              L1:= X"09D4DA9A8002";L0:= X"0E2A232BB7C2";
      when "11010100" => 
              C3:= X"00CA15AC3D3F";C2:= X"036974B8887A";C1:= X"09D84359ADC1";C0:= X"0E33F8972BE8";
              Q2:= X"036AA3D91870";Q1:= X"09D842E0A9F4";Q0:= X"0E33F89735E4";
              L1:= X"09DBAD84830E";L0:= X"0E33F80601B1";
      when "11010101" => 
              C3:= X"00CAA1F246AF";C2:= X"036BD2F9885E";C1:= X"09DF18A173C7";C0:= X"0E3DD444C464";
              Q2:= X"036D02EC70E6";Q1:= X"09DF18281C0B";Q0:= X"0E3DD444CE67";
              L1:= X"09E2852B087C";L0:= X"0E3DD3B3356B";
      when "11010110" => 
              C3:= X"00CB2E983510";C2:= X"036E32DF49A8";C1:= X"09E5F2A760B1";C0:= X"0E47B6CA0373";
              Q2:= X"036F63A5340D";Q1:= X"09E5F22DB4B2";Q0:= X"0E47B6CA0D7D";
              L1:= X"09E9619159E9";L0:= X"0E47B6380F72";
      when "11010111" => 
              C3:= X"00CBBB90D9A6";C2:= X"0370946B26CB";C1:= X"09ECD16EBF0B";C0:= X"0E51A02BA8E1";
              Q2:= X"0371C6047934";Q1:= X"09ECD0F4BEB3";Q0:= X"0E51A02BB2F3";
              L1:= X"09F042BAC32C";L0:= X"0E519F994F93";
      when "11011000" => 
              C3:= X"00CC490DBB4B";C2:= X"0372F79DD03E";C1:= X"09F3B4FADC26";C0:= X"0E5B906E77C7";
              Q2:= X"03742A0B61D8";Q1:= X"09F3B4808711";Q0:= X"0E5B906E81E0";
              L1:= X"09F728AA926F";L0:= X"0E5B8FDBB8E5";
      when "11011001" => 
              C3:= X"00CCD6E07BBA";C2:= X"03755C78C7DA";C1:= X"09FA9D4F071A";C0:= X"0E658797368A";
              Q2:= X"03768FBB1B3A";Q1:= X"09FA9CD45D11";Q0:= X"0E65879740AA";
              L1:= X"09FE1364182A";L0:= X"0E65870411CD";
      when "11011010" => 
              C3:= X"00CD650B081E";C2:= X"0377C2FD3756";C1:= X"0A018A6E917C";C0:= X"0E6F85AAAEE1";
              Q2:= X"0378F714CB69";Q1:= X"0A0189F3924D";Q0:= X"0E6F85AAB907";
              L1:= X"0A0502EAA717";L0:= X"0E6F85172402";
      when "11011011" => 
              C3:= X"00CDF3A34F88";C2:= X"037A2B2C133E";C1:= X"0A087C5CCF4F";C0:= X"0E798AADADD5";
              Q2:= X"037B60198C04";Q1:= X"0A087BE17ABA";Q0:= X"0E798AADB802";
              L1:= X"0A0BF7419448";L0:= X"0E798A19BC8E";
      when "11011100" => 
              C3:= X"00CE8283913B";C2:= X"037C9506CDE7";C1:= X"0A0F731D16A7";C0:= X"0E8396A503C4";
              Q2:= X"037DCACA946C";Q1:= X"0A0F72A16C86";Q0:= X"0E8396A50DF8";
              L1:= X"0A12F06C371A";L0:= X"0E839610ABCE";
      when "11011101" => 
              C3:= X"00CF11DD350A";C2:= X"037F008E38EC";C1:= X"0A166EB2C030";C0:= X"0E8DA9958464";
              Q2:= X"038037290BC5";Q1:= X"0A166E36C033";Q0:= X"0E8DA9958E9F";
              L1:= X"0A19EE6DE93D";L0:= X"0E8DA900C577";
      when "11011110" => 
              C3:= X"00CFA18125D3";C2:= X"03816DC3D7F9";C1:= X"0A1D6F212696";C0:= X"0E97C38406C4";
              Q2:= X"0382A536180C";Q1:= X"0A1D6EA4D0A0";Q0:= X"0E97C3841107";
              L1:= X"0A20F14A06B6";L0:= X"0E97C2EEE099";
      when "11011111" => 
              C3:= X"00D031B1CBEA";C2:= X"0383DCA858E5";C1:= X"0A24746BA74E";C0:= X"0EA1E4756550";
              Q2:= X"038514F2E8C3";Q1:= X"0A2473EEFAF7";Q0:= X"0EA1E4756F9A";
              L1:= X"0A27F903EDDD";L0:= X"0EA1E3DFD79F";
      when "11100000" => 
              C3:= X"00D0C22B16F5";C2:= X"03864D3D6613";C1:= X"0A2B7E95A192";C0:= X"0EAC0C6E7DD1";
              Q2:= X"038786609EF1";Q1:= X"0A2B7E189EC4";Q0:= X"0EAC0C6E8822";
              L1:= X"0A2F059EFF65";L0:= X"0EAC0BD88853";
      when "11100001" => 
              C3:= X"00D1531C0AA5";C2:= X"0388BF83CE3C";C1:= X"0A328DA27778";C0:= X"0EB63B743172";
              Q2:= X"0389F9807731";Q1:= X"0A328D251DD7";Q0:= X"0EB63B743BCA";
              L1:= X"0A36171E9E4F";L0:= X"0EB63ADDD3DF";
      when "11100010" => 
              C3:= X"00D1E45D0792";C2:= X"038B337D09EF";C1:= X"0A39A1958D09";C0:= X"0EC0718B64C1";
              Q2:= X"038C6E539226";Q1:= X"0A39A117DC6B";Q0:= X"0EC0718B6F20";
              L1:= X"0A3D2D863001";L0:= X"0EC070F49ECF";
      when "11100011" => 
              C3:= X"00D276112D4B";C2:= X"038DA92A0E2B";C1:= X"0A40BA7248E9";C0:= X"0ECAAEB8FFAF";
              Q2:= X"038EE4DB20B2";Q1:= X"0A40B9F44112";Q0:= X"0ECAAEB90A16";
              L1:= X"0A4448D91C31";L0:= X"0ECAAE21D117";
      when "11100100" => 
              C3:= X"00D3080E3E75";C2:= X"0390208C48BD";C1:= X"0A47D83C13EE";C0:= X"0ED4F301ED98";
              Q2:= X"03915D186227";Q1:= X"0A47D7BDB49F";Q0:= X"0ED4F301F806";
              L1:= X"0A4B691ACD02";L0:= X"0ED4F26A5611";
      when "11100101" => 
              C3:= X"00D39AA44827";C2:= X"039299A47815";C1:= X"0A4EFAF6598A";C0:= X"0EDF3E6B1D41";
              Q2:= X"0393D70C6E0F";Q1:= X"0A4EFA77A279";Q0:= X"0EDF3E6B27B5";
              L1:= X"0A528E4EAEE5";L0:= X"0EDF3DD31C82";
      when "11100110" => 
              C3:= X"00D42D8C3878";C2:= X"039514742A75";C1:= X"0A5622A48747";C0:= X"0EE990F980D9";
              Q2:= X"039652B87FDE";Q1:= X"0A5622257839";Q0:= X"0EE990F98B55";
              L1:= X"0A59B87830B9";L0:= X"0EE99061169A";
      when "11100111" => 
              C3:= X"00D4C0C1EFAB";C2:= X"039790FC9E2A";C1:= X"0A5D4F4A0D22";C0:= X"0EF3EAB20E02";
              Q2:= X"0398D01DBB79";Q1:= X"0A5D4ECAA5F7";Q0:= X"0EF3EAB21886";
              L1:= X"0A60E79AC3B1";L0:= X"0EF3EA1939F9";
      when "11101000" => 
              C3:= X"00D55468EA94";C2:= X"039A0F3EDB50";C1:= X"0A6480EA5D96";C0:= X"0EFE4B99BDCD";
              Q2:= X"039B4F3D6F51";Q1:= X"0A64806A9E04";Q0:= X"0EFE4B99C857";
              L1:= X"0A681BB9DB72";L0:= X"0EFE4B007FB0";
      when "11101001" => 
              C3:= X"00D5E87FC0E7";C2:= X"039C8F3C018B";C1:= X"0A6BB788ED89";C0:= X"0F08B3B58CBE";
              Q2:= X"039DD018C1E9";Q1:= X"0A6BB708D53D";Q0:= X"0F08B3B59750";
              L1:= X"0A6F54D8EDFE";L0:= X"0F08B31BE443";
      when "11101010" => 
              C3:= X"00D67CEEB614";C2:= X"039F10F5701D";C1:= X"0A72F3293413";C0:= X"0F13230A7AD0";
              Q2:= X"03A052B0D779";Q1:= X"0A72F2A8C2E6";Q0:= X"0F13230A8569";
              L1:= X"0A7692FB73BC";L0:= X"0F13227067AF";
      when "11101011" => 
              C3:= X"00D711E095BB";C2:= X"03A1946C174E";C1:= X"0A7A33CEAAF9";C0:= X"0F1D999D8B76";
              Q2:= X"03A2D706F057";Q1:= X"0A7A334DE093";Q0:= X"0F1D999D9617";
              L1:= X"0A7DD624E783";L0:= X"0F1D99030D64";
      when "11101100" => 
              C3:= X"00D7A7178D37";C2:= X"03A419A1A101";C1:= X"0A81797CCE08";C0:= X"0F281773C59F";
              Q2:= X"03A55D1C4E0F";Q1:= X"0A8178FBAA42";Q0:= X"0F281773D047";
              L1:= X"0A851E58C690";L0:= X"0F2816D8DC52";
      when "11101101" => 
              C3:= X"00D83CCCFEC7";C2:= X"03A6A096DC16";C1:= X"0A88C4371BDE";C0:= X"0F329C9233B6";
              Q2:= X"03A7E4F20FBD";Q1:= X"0A88C3B59E7C";Q0:= X"0F329C923E65";
              L1:= X"0A8C6B9A908B";L0:= X"0F329BF6DEE3";
      when "11101110" => 
              C3:= X"00D8D2ECDA33";C2:= X"03A9294D1C7D";C1:= X"0A9014011554";C0:= X"0F3D28FDE3A5";
              Q2:= X"03AA6E897F52";Q1:= X"0A90137F3E0E";Q0:= X"0F3D28FDEE5C";
              L1:= X"0A93BDEDC78F";L0:= X"0F3D28622302";
      when "11101111" => 
              C3:= X"00D96972728B";C2:= X"03ABB3C5A960";C1:= X"0A9768DE3DB2";C0:= X"0F47BCBBE6DB";
              Q2:= X"03ACF9E3CA34";Q1:= X"0A97685C0C53";Q0:= X"0F47BCBBF199";
              L1:= X"0A9B1555F01B";L0:= X"0F47BC1FBA1D";
      when "11110000" => 
              C3:= X"00DA003D0EAE";C2:= X"03AE4001DD72";C1:= X"0A9EC2D21AB0";C0:= X"0F5257D15247";
              Q2:= X"03AF8702363B";Q1:= X"0A9EC24F8EF9";Q0:= X"0F5257D15D0D";
              L1:= X"0AA271D69132";L0:= X"0F525734B923";
      when "11110001" => 
              C3:= X"00DA97887AAE";C2:= X"03B0CE029C43";C1:= X"0AA621E03499";C0:= X"0F5CFA433E64";
              Q2:= X"03B215E5EFD0";Q1:= X"0AA6215D4E44";Q0:= X"0F5CFA434931";
              L1:= X"0AA9D3733435";L0:= X"0F5CF9A6388F";
      when "11110010" => 
              C3:= X"00DB2F5B1F40";C2:= X"03B35DC92AA2";C1:= X"0AAD860C160A";C0:= X"0F67A416C733";
              Q2:= X"03B4A6902ECF";Q1:= X"0AAD8588D4D3";Q0:= X"0F67A416D208";
              L1:= X"0AB13A2F6504";L0:= X"0F67A3795461";
      when "11110011" => 
              C3:= X"00DBC77EEDA6";C2:= X"03B5EF56FD70";C1:= X"0AB4EF594C0F";C0:= X"0F7255510C42";
              Q2:= X"03B739023F25";Q1:= X"0AB4EED5AFB5";Q0:= X"0F725551171E";
              L1:= X"0AB8A60EB1F6";L0:= X"0F7254B32C27";
      when "11110100" => 
              C3:= X"00DC6000837B";C2:= X"03B882AD50E6";C1:= X"0ABC5DCB6630";C0:= X"0F7D0DF730AC";
              Q2:= X"03B9CD3D4946";Q1:= X"0ABC5D476E91";Q0:= X"0F7D0DF73B90";
              L1:= X"0AC01714ABD6";L0:= X"0F7D0D58E2FD";
      when "11110101" => 
              C3:= X"00DCF8FAF313";C2:= X"03BB17CD27FB";C1:= X"0AC3D165F695";C0:= X"0F87CE0E5B20";
              Q2:= X"03BC6342A4F3";Q1:= X"0AC3D0E1A34C";Q0:= X"0F87CE0E660B";
              L1:= X"0AC78D44E5F1";L0:= X"0F87CD6F9F90";
      when "11110110" => 
              C3:= X"00DD92493C1A";C2:= X"03BDAEB801EC";C1:= X"0ACB4A2C91A3";C0:= X"0F92959BB5DC";
              Q2:= X"03BEFB137E7E";Q1:= X"0ACB49A7E280";Q0:= X"0F92959BC0CF";
              L1:= X"0ACF08A2F5FF";L0:= X"0F9294FC8C20";
      when "11110111" => 
              C3:= X"00DE2C29CE3B";C2:= X"03C0476ECC2F";C1:= X"0AD2C822CE6E";C0:= X"0F9D64A46EB8";
              Q2:= X"03C194B10D91";Q1:= X"0AD2C79DC334";Q0:= X"0F9D64A479B3";
              L1:= X"0AD689327445";L0:= X"0F9D6404D683";
      when "11111000" => 
              C3:= X"00DEC648C1D9";C2:= X"03C2E1F32C69";C1:= X"0ADA4B4C4662";C0:= X"0FA83B2DB722";
              Q2:= X"03C4301C994D";Q1:= X"0ADA4AC6DEE3";Q0:= X"0FA83B2DC224";
              L1:= X"0ADE0EF6FB7C";L0:= X"0FA83A8DB027";
      when "11111001" => 
              C3:= X"00DF60ECFEA8";C2:= X"03C57E460CA8";C1:= X"0AE1D3AC9591";C0:= X"0FB3193CC421";
              Q2:= X"03C6CD57705F";Q1:= X"0AE1D326D174";Q0:= X"0FB3193CCF2B";
              L1:= X"0AE599F428E5";L0:= X"0FB3189C4E14";
      when "11111010" => 
              C3:= X"00DFFC141D2F";C2:= X"03C81C68A146";C1:= X"0AE961475A89";C0:= X"0FBDFED6CE5E";
              Q2:= X"03C96C62BC4C";Q1:= X"0AE960C13984";Q0:= X"0FBDFED6D96F";
              L1:= X"0AED2A2D9C3F";L0:= X"0FBDFE35E8F1";
      when "11111011" => 
              C3:= X"00E09770D095";C2:= X"03CABC5CA59E";C1:= X"0AF0F4203610";C0:= X"0FC8EC01121D";
              Q2:= X"03CC0D3FD5BF";Q1:= X"0AF0F399B7FA";Q0:= X"0FC8EC011D36";
              L1:= X"0AF4BFA6F7D0";L0:= X"0FC8EB5FBD03";
      when "11111100" => 
              C3:= X"00E133517FE2";C2:= X"03CD5E22F266";C1:= X"0AF88C3ACBD9";C0:= X"0FD3E0C0CF47";
              Q2:= X"03CEAFEFEDF8";Q1:= X"0AF88BB3F06F";Q0:= X"0FD3E0C0DA68";
              L1:= X"0AFC5A63E05E";L0:= X"0FD3E01F0A33";
      when "11111101" => 
              C3:= X"00E1CFA135AC";C2:= X"03D001BCE379";C1:= X"0B00299AC1E8";C0:= X"0FDEDD1B496A";
              Q2:= X"03D1547455C4";Q1:= X"0B00291388E5";Q0:= X"0FDEDD1B5492";
              L1:= X"0B03FA67FD3A";L0:= X"0FDEDC79140D";
      when "11111110" => 
              C3:= X"00E26C593F3F";C2:= X"03D2A72BC35E";C1:= X"0B07CC43C0D6";C0:= X"0FE9E115C7B8";
              Q2:= X"03D3FACE4821";Q1:= X"0B07CBBC29FD";Q0:= X"0FE9E115D2E8";
              L1:= X"0B0B9FB6F845";L0:= X"0FE9E07321C5";
      when "11111111" => 
              C3:= X"00E30992D12E";C2:= X"03D54E70C19A";C1:= X"0B0F743973C0";C0:= X"0FF4ECB59511";
              Q2:= X"03D6A2FF1488";Q1:= X"0B0F73B17EC7";Q0:= X"0FF4ECB5A049";
              L1:= X"0B134A547DD8";L0:= X"0FF4EC127E3A";
      when others => null;
    end case;

  if (coef_case_size>coef_max_size) then
    diff := coef_case_size - coef_max_size;
  else
    diff := 0;
  end if;
  if ((coef_case_size-diff-coef3_size_new) < 0) then
    C3_trunc := conv_signed(C3(coef_case_size-1-diff downto 0),C3_trunc'length);
  else
    C3_trunc := signed(C3(coef_case_size-1-diff downto coef_case_size-diff-coef3_size_new));
  end if;
  if ((coef_case_size-diff-coef2_size) < 0) then
    C2_trunc := conv_signed(C2(coef_case_size-1-diff downto 0),C2_trunc'length);
    Q2_trunc := conv_signed(Q2(coef_case_size-1-diff downto 0),Q2_trunc'length);
  else
    C2_trunc := signed(C2(coef_case_size-1-diff downto coef_case_size-diff-coef2_size));
    Q2_trunc := signed(Q2(coef_case_size-1-diff downto coef_case_size-diff-coef2_size));
  end if;
  if ((coef_case_size-diff-coef1_size) < 0) then
    C1_trunc := conv_signed(C1(coef_case_size-1-diff downto 0),C1_trunc'length);
    Q1_trunc := conv_signed(Q1(coef_case_size-1-diff downto 0),Q1_trunc'length);
    L1_trunc := conv_signed(L1(coef_case_size-1-diff downto 0),L1_trunc'length);
  else
    C1_trunc := signed(C1(coef_case_size-1-diff downto coef_case_size-diff-coef1_size));
    Q1_trunc := signed(Q1(coef_case_size-1-diff downto coef_case_size-diff-coef1_size));
    L1_trunc := signed(L1(coef_case_size-1-diff downto coef_case_size-diff-coef1_size));
  end if;
  if ((coef_case_size-diff-coef0_size) < 0)  then
    C0_trunc := conv_signed(C0(coef_case_size-1-diff downto 0),C0_trunc'length);
    Q0_trunc := conv_signed(Q0(coef_case_size-1-diff downto 0),Q0_trunc'length);
    L0_trunc := conv_signed(L0(coef_case_size-1-diff downto 0),L0_trunc'length);
  else    
    C0_trunc := signed(C0(coef_case_size-1-diff downto coef_case_size-diff-coef0_size));
    Q0_trunc := signed(Q0(coef_case_size-1-diff downto coef_case_size-diff-coef0_size));
    L0_trunc := signed(L0(coef_case_size-1-diff downto coef_case_size-diff-coef0_size));
  end if;

  if (arch = 0) then
    p3_c := conv_signed(SHR((C3_trunc * unsigned(short_a) + C2_trunc * pad_vec2),conv_unsigned(op_width+bits,16)),p3_c'length);  
    p2_c := conv_signed(SHR((signed(p3_c(coef2_size-1 downto 0)) *  unsigned(short_a) + C1_trunc * pad_vec),conv_unsigned(op_width,16)),p2_c'length);
    p1_c := conv_signed((signed(p2_c(coef1_size-1 downto 0)) * unsigned(short_a) + C0_trunc * pad_vec),p1_c'length);
    p3_q := (others => '0');
    p2_q := conv_signed(SHR((Q2_trunc *  unsigned(short_a) + Q1_trunc * pad_vec),conv_unsigned(op_width,32)),p2_q'length);
    p1_q := conv_signed(signed(p2_q(coef1_size-1 downto 0)) *  unsigned(short_a) + Q0_trunc * pad_vec,p1_q'length);
    p3_l := (others => '0');
    p2_l := (others => '0');   
    p1_l := conv_signed(L1_trunc *  unsigned(short_a) + L0_trunc * pad_vec,p1_l'length);
  else
    a_square := unsigned(short_a) * unsigned(short_a);
    if (op_width < extra_LSBs) then
      a_square_trunc := conv_unsigned(SHL(a_square,conv_unsigned(extra_LSBs-op_width,16)),a_square_trunc'length);
    else
      a_square_aligned := SHR(a_square,conv_unsigned(op_width-extra_LSBs,16));
      a_square_trunc := a_square_aligned(a_square_trunc'left downto 0);
    end if;
    a_cube := unsigned(short_a) * unsigned(short_a) * unsigned(short_a);
    if ((2*op_width) < extra_LSBs) then
      a_cube_trunc :=  SHL(a_cube,conv_unsigned(extra_LSBs-2*op_width,16));
    else
      a_cube_aligned := SHR(a_cube,conv_unsigned(2*op_width-extra_LSBs,16));
      a_cube_trunc := a_cube_aligned(a_cube_trunc'left downto 0);
    end if;
    short_a_padded := unsigned(short_a & pad_vec3);
    p3_c := conv_signed(SHR(C3_trunc * a_cube_trunc,conv_unsigned(op_width+extra_LSBs+bits,16)), p3_c'length);  
    p2_c := conv_signed(SHR(C2_trunc * a_square_trunc,conv_unsigned(op_width+extra_LSBs,16)),p2_c'length);
    p1_c := SHL(conv_signed(p3_c + p2_c + SHR(C1_trunc * short_a_padded,conv_unsigned(op_width+extra_LSBs,16)) + C0_trunc,p1_c'length),conv_unsigned(op_width,16));
    p3_q := (others => '0');
    p2_q := conv_signed(SHR(Q2_trunc * a_square_trunc,conv_unsigned(op_width+extra_LSBs,16)),p2_q'length);
    p1_q := SHL(conv_signed(p3_q + p2_q + SHR(Q1_trunc * short_a_padded,conv_unsigned(op_width+extra_LSBs,16)) + Q0_trunc,p1_q'length),conv_unsigned(op_width,16));
    p3_l := (others => '0');
    p2_l := (others => '0');   
    p1_l := SHL(conv_signed(p3_l + p2_l + SHR(L1_trunc *  short_a_padded,conv_unsigned(op_width+extra_LSBs,16)) + L0_trunc,p1_l'length),conv_unsigned(op_width,16));
  end if;
  if ((op_width >= 19) and (op_width < 29)) then
    p1_sel := p1_q(p1_sel'left downto 0);
  else
    if ((op_width >= 12) and (op_width < 19)) then
      p1_sel := p1_l(p1_sel'left downto 0);
    else  
      p1_sel := p1_c(p1_sel'left downto 0);
    end if;
  end if;

  p1_sel := SHL(p1_sel,conv_unsigned(int_bits-1,3));

  for i in 1 to p1_aligned'length loop
    if (i <= p1_sel'length) then
      p1_aligned(p1_aligned'length-i) := p1_sel(p1_sel'length-i);
    else
      p1_aligned(p1_aligned'length-i) := '0';
    end if;
  end loop;

  z_int := unsigned(p1_aligned);
  if (err_range = 1) then
    z_round:= unsigned(z_int(z_int'length-1 downto z_int'length-z_round'length)) + 1;
  else
    z_round:=  unsigned(z_int(z_int'length-1 downto z_int'length-z_round'length));
  end if;
  z_poly_new <= std_logic_vector(z_round(z_round_MSB downto z_round_MSB-op_width+1));
end process;


  


 z <=  (others => 'X') when (Is_x(a)) else
        z_lookup when (op_width <  12) else
        z_poly   when (op_width < 39 and arch = 2) else 
        z_poly_new when (op_width < 39 and arch < 2);
-- pragma translate_on  

end sim ;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_exp2_cfg_sim of DW_exp2 is
 for sim
 end for; -- sim
end DW_exp2_cfg_sim;
-- pragma translate_on

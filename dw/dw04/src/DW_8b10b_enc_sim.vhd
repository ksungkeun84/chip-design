--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 1999 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Jay Zhu  August 18, 1999
--
-- VERSION:   VHDL Simulation Model
--
-- DesignWare_version: 85c5faa1
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT: 8b10b encoder VHDL simulation model
--      Parameters:
--              bytes : Number of bytes to decode.
--              k28_5_only : Special character subset control
--                      parameter (0 for all special characters
--                      decoded, 1 for only K28.5 decoded [when
--                      k_char=HIGH implies K28.5, all other special
--                      characters indicate a code error])
--              en_mode : 0 => enable not connected (backward campat.)
--                        1 => enable=0 stalls decoder
--              init_mode : during initialization the method in which
--                          input init_rd_val is applied to data_in.
--                            0 => init_rd_val input is registered
--                                 before being applied to data in
--                            1 => init_rd_val input is not registered
--              rst_mode :  reset mode
--                            0 => using asynchronous reset FFs
--                            1 => using synchronous reset FFs
--              op_iso_mode : Operand Isolation mode 
--                            '0': Follow intent defined by Power Compiler user setting
--                            '1': no operand isolation
--                            '2': 'and' gate isolation
--                            '3': 'or' gate isolation
--                            '4': preferred isolation style: 'or' gate
--      Inputs:
--              clk :   Clock
--              rst_n : Asynchronous reset, active low
--              init_rd_n : Synchronous initialization, active low
--              init_rd_val : Value of initial running disparity
--              k_char : Special character indicators (one indicator
--                      per decoded byte)
--              data_in : Input data for decoding, normally should be
--                      8b10b encoded data
--      Outputs:
--              rd :    Current running disparity (after decoding data
--                      presented at data_in)
--              data_out : decoded output data
--      Input:
--              enable : Enables register clocking
--
-- MODIFIED:
--      2/11/15 RJK
--      Updated model to eliminate derived reset signal
--
--      DLL 09/14/2004 added enable input pin and 
--      en_mode and init_mode parameters.  Also, general comment
--      enhancements.
--
--      DLL 02/15/2008 added 'op_iso_mode' parameter and checking logic.
--
--      RJK 10/6/08 Added rst_mode parameter to select reset type
--                  (STAR 9000270234)
--
---------------------------------------------------------------

library	IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use DWARE.DWpackages.all;



architecture sim of DW_8b10b_enc is
	

-- pragma translate_off

type abcdei_rd_TBL_T0 is array (0 to 1) of std_logic_vector(6 downto 0);
type abcdei_rd_TBL_T is array (0 to 31) of abcdei_rd_TBL_T0;

constant abcdei_rd_tbl  : abcdei_rd_TBL_T := (
	("1001111",	"0110000"),
	("0111011",	"1000100"),
	("1011011",	"0100100"),
	("1100010",	"1100011"),
	("1101011",	"0010100"),
	("1010010",	"1010011"),
	("0110010",	"0110011"),
	("1110000",	"0001111"),
	("1110011",	"0001100"),
	("1001010",	"1001011"),
	("0101010",	"0101011"),
	("1101000",	"1101001"),
	("0011010",	"0011011"),
	("1011000",	"1011001"),
	("0111000",	"0111001"),
	("0101111",	"1010000"),
	("0110111",	"1001000"),
	("1000110",	"1000111"),
	("0100110",	"0100111"),
	("1100100",	"1100101"),
	("0010110",	"0010111"),
	("1010100",	"1010101"),
	("0110100",	"0110101"),
	("1110101",	"0001010"),
	("1100111",	"0011000"),
	("1001100",	"1001101"),
	("0101100",	"0101101"),
	("1101101",	"0010010"),
	("0011100",	"0011101"),
	("1011101",	"0100010"),
	("0111101",	"1000010"),
	("1010111",	"0101000"));

type fghj_rd_TBL_T0 is array (0 to 1) of std_logic_vector(4 downto 0);
type fghj_rd_TBL_T is array (0 to 7) of fghj_rd_TBL_T0;

constant fghj_rd_tbl  : fghj_rd_TBL_T := (
	("10111",	"01000"),
	("10010",	"10011"),
	("01010",	"01011"),
	("11000",	"00111"),
	("11011",	"00100"),
	("10100",	"10101"),
	("01100",	"01101"),
	("11101",	"00010"));



function conv_std_logic_2_int(input_bit : std_logic)
	return	integer is
	variable rt_int : integer;
begin
	  if(input_bit = '0') then
	    rt_int := 0;
	  else
	    rt_int := 1;
	  end if;
	return rt_int;

end conv_std_logic_2_int;




function encode_8b_to_10b(
		HGFEDCBA :	std_logic_vector(7 downto 0);
		k_char:		std_logic;
		K28_5_only:	integer;
		RD_in:		std_logic
		)
	return std_logic_vector is
	variable HGFEDCBA_RD :	std_logic_vector(8 downto 0);
	variable abcdeifghj : std_logic_vector(9 downto 0);
	variable abcdei_rd : std_logic_vector(6 downto 0);
	variable fghj_rd : std_logic_vector(4 downto 0);
	variable RD_out : std_logic;
begin

	if k_char = '1' then

	  if K28_5_only = 1 then
	    if RD_in = '0' then
	      abcdeifghj := "0011111010";
	      RD_out := '1';
	    else
	      abcdeifghj := "1100000101";
	      RD_out := '0';
	    end if;

	  else
	    HGFEDCBA_RD := HGFEDCBA & RD_in;
	    case HGFEDCBA_RD is
	      when "000111000" =>
	      	abcdeifghj := "0011110100";
	      	RD_out := '0';
	      when "000111001" =>
	      	abcdeifghj := "1100001011";
	      	RD_out := '1';
	      when "001111000" =>
	      	abcdeifghj := "0011111001";
	      	RD_out := '1';
	      when "001111001" =>
	      	abcdeifghj := "1100000110";
	      	RD_out := '0';
	      when "010111000" =>
	      	abcdeifghj := "0011110101";
	      	RD_out := '1';
	      when "010111001" =>
	      	abcdeifghj := "1100001010";
	      	RD_out := '0';
	      when "011111000" =>
	      	abcdeifghj := "0011110011";
	      	RD_out := '1';
	      when "011111001" =>
	      	abcdeifghj := "1100001100";
	      	RD_out := '0';
	      when "100111000" =>
	      	abcdeifghj := "0011110010";
	      	RD_out := '0';
	      when "100111001" =>
	      	abcdeifghj := "1100001101";
	      	RD_out := '1';
	      when "101111000" =>
	      	abcdeifghj := "0011111010";
	      	RD_out := '1';
	      when "101111001" =>
	      	abcdeifghj := "1100000101";
	      	RD_out := '0';
	      when "110111000" =>
	      	abcdeifghj := "0011110110";
	      	RD_out := '1';
	      when "110111001" =>
	      	abcdeifghj := "1100001001";
	      	RD_out := '0';
	      when "111111000" =>
	      	abcdeifghj := "0011111000";
	      	RD_out := '0';
	      when "111111001" =>
	      	abcdeifghj := "1100000111";
	      	RD_out := '1';
	      when "111101110" =>
	      	abcdeifghj := "1110101000";
	      	RD_out := '0';
	      when "111101111" =>
	      	abcdeifghj := "0001010111";
	      	RD_out := '1';
	      when "111110110" =>
	      	abcdeifghj := "1101101000";
	      	RD_out := '0';
	      when "111110111" =>
	      	abcdeifghj := "0010010111";
	      	RD_out := '1';
	      when "111111010" =>
	      	abcdeifghj := "1011101000";
	      	RD_out := '0';
	      when "111111011" =>
	      	abcdeifghj := "0100010111";
	      	RD_out := '1';
	      when "111111100" =>
	      	abcdeifghj := "0111101000";
	      	RD_out := '0';
	      when "111111101" =>
	      	abcdeifghj := "1000010111";
	      	RD_out := '1';
	      when others =>
	        abcdeifghj := (others => 'X');
	        RD_out := 'X';
		assert 1=0 report "Warning: data on DW_8b10_enc's data_in is invalid for k_char=1 and k28_5_only=0." severity WARNING;
	    end case;

	  end if;

	elsif k_char = '0' then

	  if any_unknown(HGFEDCBA & RD_in) = 1 then
	    abcdeifghj := (others => 'X');
	    RD_out := 'X';
	  else
	    abcdei_rd := abcdei_rd_TBL(
		CONV_INTEGER(UNSIGNED(HGFEDCBA(4 downto 0))))
			(conv_std_logic_2_int(RD_in));
	    if HGFEDCBA(7 downto 5) = "111" then
	      if (HGFEDCBA(4 downto 0) = "01011" OR
	          HGFEDCBA(4 downto 0) = "01101" OR
	          HGFEDCBA(4 downto 0) = "01110") AND
		 abcdei_rd(0) = '1' then
	        fghj_rd := "10000";
	      elsif (HGFEDCBA(4 downto 0) = "10001" OR
	             HGFEDCBA(4 downto 0) = "10010" OR
	             HGFEDCBA(4 downto 0) = "10100") AND
		 abcdei_rd(0) = '0' then
	        fghj_rd := "01111";
	      else
	        fghj_rd := fghj_rd_TBL(
		  CONV_INTEGER(UNSIGNED(HGFEDCBA(7 downto 5))))
				(conv_std_logic_2_int(abcdei_rd(0)));
	      end if;
	    else
	      fghj_rd := fghj_rd_TBL(
		CONV_INTEGER(UNSIGNED(HGFEDCBA(7 downto 5))))
				(conv_std_logic_2_int(abcdei_rd(0)));
	    end if;
	      abcdeifghj := abcdei_rd(6 downto 1) & fghj_rd(4 downto 1);
	      RD_out := fghj_rd(0);
	  end if;

	else
	  abcdeifghj := (others => 'X');
	  RD_out := 'X';
	end if;

	return abcdeifghj & RD_out;

end encode_8b_to_10b;



signal	rd_int :	std_logic;

-- pragma translate_on
begin

-- pragma translate_off

GEN_RM_EQ_0_EM_EQ_0 : if (rst_mode = 0) AND (en_mode = 0) generate
  -- Async reset, no enable
  ENCODER_TOP_LEVEL_AR_NE : process(clk, rst_n)
	variable tmp_rd :	std_logic;
	variable tmp_signal :	std_logic_vector(10 downto 0);
	variable data_out_int : std_logic_vector(bytes*10-1 downto 0);
  begin

	if (rst_n = '0') then
	  rd_int <= '0';
	  data_out <= (others=>'0');
	elsif (rst_n = '1') then
	  if(rising_edge(clk)) then
		if((init_rd_n = '0') AND (init_mode = 1)) then
		  tmp_rd  := init_rd_val;
		elsif((init_rd_n = '1') OR (init_mode = 0)) then
		  tmp_rd := rd_int;
		else
		  tmp_rd := 'X';
		end if;

		for byte_idx in bytes downto 1 loop
		  tmp_signal := encode_8b_to_10b(
		    HGFEDCBA => data_in(byte_idx*8-1 downto (byte_idx-1)*8),
		    k_char => k_char(byte_idx-1),
		    K28_5_only => K28_5_only,
		    RD_in => tmp_rd
		    );
		  data_out_int(byte_idx*10-1 downto (byte_idx-1)*10) :=
		    tmp_signal(10 downto 1);
		  tmp_rd := tmp_signal(0);
		end loop;

		data_out <= data_out_int;

		if((init_rd_n = '0') AND (init_mode = 0)) then
		  rd_int <= init_rd_val;
		elsif((init_rd_n = '1') OR (init_mode = 1)) then
		  rd_int <= tmp_rd;
		else
		  rd_int <= 'X';
		end if;

	  end if;

	else
	  data_out <= (others => 'X');
	  rd_int <= 'X';
	end if;

  end process ENCODER_TOP_LEVEL_AR_NE;
end generate;


GEN_RM_EQ_0_EM_NE_0 : if (rst_mode = 0) AND (en_mode /= 0) generate
  -- Async reset, with enable
  ENCODER_TOP_LEVEL_AR_WE : process(clk, rst_n)
	variable tmp_rd :	std_logic;
	variable tmp_signal :	std_logic_vector(10 downto 0);
	variable data_out_int : std_logic_vector(bytes*10-1 downto 0);
  begin

	if (rst_n = '0') then
	  rd_int <= '0';
	  data_out <= (others=>'0');
	elsif (rst_n = '1') then
	  if(rising_edge(clk)) then

	      if (enable = '1') then
		if((init_rd_n = '0') AND (init_mode = 1)) then
		  tmp_rd  := init_rd_val;
		elsif((init_rd_n = '1') OR (init_mode = 0)) then
		  tmp_rd := rd_int;
		else
		  tmp_rd := 'X';
		end if;

		for byte_idx in bytes downto 1 loop
		  tmp_signal := encode_8b_to_10b(
		    HGFEDCBA => data_in(byte_idx*8-1 downto (byte_idx-1)*8),
		    k_char => k_char(byte_idx-1),
		    K28_5_only => K28_5_only,
		    RD_in => tmp_rd
		    );
		  data_out_int(byte_idx*10-1 downto (byte_idx-1)*10) :=
		    tmp_signal(10 downto 1);
		  tmp_rd := tmp_signal(0);
		end loop;

		data_out <= data_out_int;

		if((init_rd_n = '0') AND (init_mode = 0)) then
		  rd_int <= init_rd_val;
		elsif((init_rd_n = '1') OR (init_mode = 1)) then
		  rd_int <= tmp_rd;
		else
		  rd_int <= 'X';
		end if;

	      end if;

	  end if;

	else
	  data_out <= (others => 'X');
	  rd_int <= 'X';
	end if;

  end process ENCODER_TOP_LEVEL_AR_WE;
end generate;


GEN_RM_NE_0_EM_EQ_0 : if (rst_mode /= 0) AND (en_mode = 0) generate
  -- Sync reset, no enable
  ENCODER_TOP_LEVEL_SR_NE : process(clk)
	variable tmp_rd :	std_logic;
	variable tmp_signal :	std_logic_vector(10 downto 0);
	variable data_out_int : std_logic_vector(bytes*10-1 downto 0);
  begin

      if(rising_edge(clk)) then
	if (rst_n = '0') then
	  rd_int <= '0';
	  data_out <= (others=>'0');
	elsif (rst_n = '1') then

	    if((init_rd_n = '0') AND (init_mode = 1)) then
	      tmp_rd  := init_rd_val;
	    elsif((init_rd_n = '1') OR (init_mode = 0)) then
	      tmp_rd := rd_int;
	    else
	      tmp_rd := 'X';
	    end if;

	    for byte_idx in bytes downto 1 loop
	      tmp_signal := encode_8b_to_10b(
		HGFEDCBA => data_in(byte_idx*8-1 downto (byte_idx-1)*8),
		k_char => k_char(byte_idx-1),
		K28_5_only => K28_5_only,
		RD_in => tmp_rd
		);
	      data_out_int(byte_idx*10-1 downto (byte_idx-1)*10) :=
		tmp_signal(10 downto 1);
	      tmp_rd := tmp_signal(0);
	    end loop;

	    data_out <= data_out_int;

	    if((init_rd_n = '0') AND (init_mode = 0)) then
	      rd_int <= init_rd_val;
	    elsif((init_rd_n = '1') OR (init_mode = 1)) then
	      rd_int <= tmp_rd;
	    else
	      rd_int <= 'X';
	    end if;

	else
	  rd_int <= 'X';
	  data_out <= (others=>'X');
	end if;
      end if;

  end process ENCODER_TOP_LEVEL_SR_NE;
end generate;


GEN_RM_NE_0_EM_NE_0 : if (rst_mode /= 0) AND (en_mode /= 0) generate
  -- Sync reset, with enable
  ENCODER_TOP_LEVEL_SR_WE : process(clk)
	variable tmp_rd :	std_logic;
	variable tmp_signal :	std_logic_vector(10 downto 0);
	variable data_out_int : std_logic_vector(bytes*10-1 downto 0);
  begin

      if(rising_edge(clk)) then
	if (rst_n = '0') then
	  rd_int <= '0';
	  data_out <= (others=>'0');
	elsif (rst_n = '1') then

	  if (enable = '1') then
	    if((init_rd_n = '0') AND (init_mode = 1)) then
	      tmp_rd  := init_rd_val;
	    elsif((init_rd_n = '1') OR (init_mode = 0)) then
	      tmp_rd := rd_int;
	    else
	      tmp_rd := 'X';
	    end if;

	    for byte_idx in bytes downto 1 loop
	      tmp_signal := encode_8b_to_10b(
		HGFEDCBA => data_in(byte_idx*8-1 downto (byte_idx-1)*8),
		k_char => k_char(byte_idx-1),
		K28_5_only => K28_5_only,
		RD_in => tmp_rd
		);
	      data_out_int(byte_idx*10-1 downto (byte_idx-1)*10) :=
		tmp_signal(10 downto 1);
	      tmp_rd := tmp_signal(0);
	    end loop;

	    data_out <= data_out_int;

	    if((init_rd_n = '0') AND (init_mode = 0)) then
	      rd_int <= init_rd_val;
	    elsif((init_rd_n = '1') OR (init_mode = 1)) then
	      rd_int <= tmp_rd;
	    else
	      rd_int <= 'X';
	    end if;

	  end if;

	else
	  rd_int <= 'X';
	  data_out <= (others=>'X');
	end if;
      end if;

  end process ENCODER_TOP_LEVEL_SR_WE;
end generate;

	rd <= rd_int;

  
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
  
    if ( (bytes < 1) OR (bytes > 16) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter bytes (legal range: 1 to 16)"
        severity warning;
    end if;
  
    if ( (k28_5_only < 0) OR (k28_5_only > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter k28_5_only (legal range: 0 to 1)"
        severity warning;
    end if;
  
    if ( (en_mode < 0) OR (en_mode > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter en_mode (legal range: 0 to 1)"
        severity warning;
    end if;
  
    if ( (init_mode < 0) OR (init_mode > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter init_mode (legal range: 0 to 1)"
        severity warning;
    end if;
  
    if ( (rst_mode < 0) OR (rst_mode > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter rst_mode (legal range: 0 to 1)"
        severity warning;
    end if;
  
    if ( (op_iso_mode < 0) OR (op_iso_mode > 4) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter op_iso_mode (legal range: 0 to 4)"
        severity warning;
    end if;
  
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;

  
  PROC_check_clk : process (clk) begin

    assert NOT (Is_X( clk ) AND (now > 0 ns)) 
      report "WARNING: Detected unknown value on the clock input port clk."
      severity warning;

  end process PROC_check_clk;


-- pragma translate_on
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_8b10b_enc_cfg_sim of DW_8b10b_enc is
 for sim
 end for; -- sim
end DW_8b10b_enc_cfg_sim;
-- pragma translate_on

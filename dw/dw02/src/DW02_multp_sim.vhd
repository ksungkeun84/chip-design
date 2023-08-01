--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 1998 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Rick Kelly        11/3/98
--
-- VERSION:   VHDL Simulation Model for Multp 
--
-- DesignWare_version: 587a260f
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Multiplier, parital products
--
--    **** >>>>  NOTE:	This model is architecturally different
--			from the 'wall' implementation of DW02_multp
--			but will generate exactly the same result
--			once the two partial product outputs are
--			added together
--
-- MODIFIED: 
--
--              Aamir Farooqui 6/21/02
--              Corrected parameter checking, simplified code and X_processing
------------------------------------------------------------------------------
--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

architecture sim of DW02_multp is
	
-- pragma translate_off
  CONSTANT npp : INTEGER := (a_width/2) + 2;
  CONSTANT xdim : INTEGER := a_width+b_width+1;
  CONSTANT zeros : std_logic_vector(xdim+3 downto 0) := (others => '0');
  CONSTANT ones  : std_logic_vector(xdim+3 downto 0) := (others => '1');
  SIGNAL   tmp_out0, tmp_out1 : std_logic_vector(xdim-1 downto 0);
  SIGNAL   ext_out0, ext_out1 : std_logic_vector(out_width-1 downto 0);
  SIGNAL   a_padded : std_logic_vector(a_width+2 downto 0);
  SIGNAL   b_padded : std_logic_vector(xdim+3 downto 0);
  SIGNAL   a_sign, b_sign : std_logic;

-- pragma translate_on
  begin
-- pragma translate_off

-----------------------------------------------------------------------------

  
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
    
    if (a_width < 1) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter a_width (lower bound: 1)"
        severity warning;
    end if;
    
    if (b_width < 1) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter b_width (lower bound: 1)"
        severity warning;
    end if;
    
    if (out_width < (a_width+b_width+2)) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter out_width (lower bound: (a_width+b_width+2))"
        severity warning;
    end if;
  
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;

-----------------------------------------------------------------------------

  a_sign   <= TC AND A(a_width-1);
  b_sign   <= TC AND B(b_width-1);
  a_padded <= a_sign & a_sign & a & '0';
  b_padded <= (ones(xdim+3 downto b_width) & b) when (b_sign='1') 
              else (zeros(xdim+3 downto b_width) & b);


  mk_pp_array : process( a_padded, b_padded )
    SUBTYPE  pp_type is std_logic_vector(xdim-1 downto 0);
    TYPE     pp_array_type is array (0 to npp-1) of pp_type;
    variable temp_pp_array : pp_array_type;
    variable next_pp_array : pp_array_type;
    variable temp_pp       : std_logic_vector(xdim+3 downto 0);
    variable temp_bitgroup : std_logic_vector(2 downto 0);
    variable tmp_pp_carry  : std_logic_vector(xdim-1 downto 0);
    variable pp_count      : INTEGER;
    begin
      temp_pp_array(0) := zeros(xdim-1 downto 0);
      for bit_pair in 0 to npp-2 loop
        temp_bitgroup := a_padded(bit_pair*2+2 downto bit_pair*2);
        case temp_bitgroup is
          when "000" | "111"  =>
            temp_pp := zeros;
          when "001" | "010"  => 
            temp_pp := b_padded ((xdim+2)-(2*bit_pair) downto 0) & zeros(2*bit_pair downto 0);
          when "011" => 
            temp_pp := (b_padded ((xdim+1)-(2*bit_pair) downto 0) & '0') & zeros(2*bit_pair downto 0);
          when "100" =>
            temp_pp := (UNSIGNED((not(b_padded ((xdim+1)-(2*bit_pair) downto 0) & '0'))) + 1) & zeros(2*bit_pair downto 0);
          when "101" | "110" =>
            temp_pp := (UNSIGNED(not b_padded((xdim+2)-(2*bit_pair) downto 0)) + 1) & zeros(2*bit_pair downto 0);
          when others => temp_pp := (others => '0');
        end case;
	temp_pp_array(bit_pair+1) := temp_pp(xdim downto 1);
      end loop;
    
      pp_count := npp;
      while (pp_count > 2) loop
        for i in 0 to (pp_count/3)-1 loop
          next_pp_array(i*2) := temp_pp_array(i*3) XOR
				temp_pp_array(i*3+1) XOR
				temp_pp_array(i*3+2);
	  tmp_pp_carry := (temp_pp_array(i*3) AND temp_pp_array(i*3+1)) OR
	                  (temp_pp_array(i*3+1) AND temp_pp_array(i*3+2)) OR
			  (temp_pp_array(i*3) AND temp_pp_array(i*3+2));
		
	  next_pp_array(i*2+1) := tmp_pp_carry(xdim-2 downto 0) & '0';
        end loop;
        if (pp_count mod 3) > 0 then
	  for i in 0 to (pp_count mod 3)-1 loop
	    next_pp_array(2 * (pp_count/3) + i) := temp_pp_array(3 * (pp_count/3) + i);
	  end loop;
        end if;
        temp_pp_array := next_pp_array;
        pp_count := pp_count - (pp_count/3);
      end loop;
      tmp_out0 <= temp_pp_array(0);
      if (pp_count = 1) then
        tmp_out1 <= zeros(xdim-1 downto 0);
      else
        tmp_out1 <= temp_pp_array(1);
      end if;
    end process mk_pp_array;

ext_out0(xdim-1 downto 0) <= tmp_out0(xdim-1 downto 0);
ext_out1(xdim-1 downto 0) <= tmp_out1(xdim-1 downto 0);
ext_out0(out_width-1 downto xdim) <= (others => '0');
ext_out1(out_width-1 downto xdim) <= (others => (tmp_out0(xdim-1) OR tmp_out1(xdim-1)));


 out0 <= (others => 'X') when (Is_X(A) or Is_X(B) or Is_X(TC)) else ext_out0;
 out1 <= (others => 'X') when (Is_X(A) or Is_X(B) or Is_X(TC)) else ext_out1;
-- pragma translate_on
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW02_multp_cfg_sim of DW02_multp is
 for sim
 end for; -- sim
end DW02_multp_cfg_sim;
-- pragma translate_on

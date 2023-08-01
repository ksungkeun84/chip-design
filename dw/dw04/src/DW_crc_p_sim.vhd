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
-- AUTHOR:    Jay Zhu, Feb 25, 2000
--
-- VERSION:   VHDL Simulation Model
--
-- DesignWare_version: 1cc60bf2
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT : Generic parallel CRC Generator/Checker 
--
-- MODIFIED :
--
---------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

architecture sim of DW_crc_p is
	

-- pragma translate_off


	  
function	calculate_crc_polynomial(
				coef0 : integer;
				coef1 : integer;
				coef2 : integer;
				coef3 : integer
				)
		return std_logic_vector is

variable	poly_coef_all : UNSIGNED(63 downto 0);
variable	crc_polynomial : std_logic_vector(poly_size-1 downto 0);
begin
	poly_coef_all(15 downto 0)  := CONV_UNSIGNED(coef0, 16);
	poly_coef_all(31 downto 16) := CONV_UNSIGNED(coef1, 16);
	poly_coef_all(47 downto 32) := CONV_UNSIGNED(coef2, 16);
	poly_coef_all(63 downto 48) := CONV_UNSIGNED(coef3, 16);
	crc_polynomial := std_logic_vector(poly_coef_all(poly_size-1 downto 0));
	return crc_polynomial;

end calculate_crc_polynomial;


constant crc_polynomial : std_logic_vector(poly_size-1 downto 0)
			:= calculate_crc_polynomial(poly_coef0,
				poly_coef1, poly_coef2, poly_coef3);


function	bit_ordering(
			input_data : std_logic_vector
			)
		return std_logic_vector is
constant	width : positive := input_data'length;
variable	output_data : std_logic_vector(width-1 downto 0);
begin

	case (bit_order) is
	  when 0 =>
	  	output_data := input_data;
	  when 1 =>
		for bite_idx in 0 to width-1 loop
		  output_data(bite_idx) := input_data(width-bite_idx-1);
		end loop;
	  when 2 =>
	  	for byte_idx in 0 to width/8-1 loop
	          output_data((byte_idx+1)*8-1 downto byte_idx*8)
		        := input_data((width/8-byte_idx)*8-1
				downto (width/8-byte_idx-1)*8);
	        end loop;
	  when 3 =>
		for byte_idx in 0 to width/8-1 loop
		  for bit_idx in 8-1 downto 0 loop
		    output_data(byte_idx*8+bit_idx)
		          := input_data((byte_idx+1)*8-1-bit_idx);
		  end loop;
		end loop;
	  when others => 
	  assert FALSE 
  	    report "Internal Error in DW_crc_p.  Please report to Synopsys representative." 
  	    severity ERROR;
	end case;

	return output_data;

end bit_ordering;
	

function	calculate_crc(
			crc_reg : std_logic_vector(
					poly_size-1 downto 0);
			input_data : std_logic_vector
			)
		return std_logic_vector is

constant	width : positive := input_data'length;
variable	crc_reg_out : std_logic_vector(poly_size-1 downto 0);
variable	feedback_bit : std_logic;
variable	feedback_vector : std_logic_vector(poly_size-1
						downto 0);
begin

	crc_reg_out := crc_reg;
	for bit_idx in width-1 downto 0 loop
	  feedback_bit := crc_reg_out(poly_size-1)
						XOR input_data(bit_idx);
	  feedback_vector := (others => feedback_bit);

	  crc_reg_out(poly_size-1 downto 1)
		:= crc_reg_out(poly_size-2 downto 0);
	  crc_reg_out(0) := '0';

	  crc_reg_out := crc_reg_out
	  		XOR (crc_polynomial AND feedback_vector);
	end loop;

	return crc_reg_out;

end calculate_crc;


function	calculate_crc(
			input_data : std_logic_vector
			)
		return std_logic_vector is
variable	crc_tmp: std_logic_vector(poly_size-1 downto 0);
variable	crc_reg_out : std_logic_vector(poly_size-1 downto 0);
begin

	if ((crc_cfg mod 2) = 1) then
	  crc_tmp := (others => '1');
	else
	  crc_tmp := (others => '0');
	end if;

	crc_reg_out := calculate_crc(crc_tmp, input_data);

	return crc_reg_out;

end calculate_crc;


function	make_crc_inv_alt(
			poly_size : integer
			)
		return std_logic_vector is
variable	crc_inv_alt : std_logic_vector(poly_size-1
					downto 0);
begin
		case(crc_cfg/2) is
		  when 0 => crc_inv_alt := (others => '0');
		  when 1 => for bit_idx in 0 to poly_size-1 loop
			      if (bit_idx mod 2 = 0) then
			        crc_inv_alt(bit_idx) := '1';
			      else
			        crc_inv_alt(bit_idx) := '0';
			      end if;
			    end loop;
		  when 2 => for bit_idx in 0 to poly_size-1 loop
			      if (bit_idx mod 2 = 1) then
			        crc_inv_alt(bit_idx) := '1';
			      else
			        crc_inv_alt(bit_idx) := '0';
			      end if;
			    end loop;
		  when 3 => crc_inv_alt := (others => '1');
		  when others => 
	  assert FALSE 
  	    report "Internal Error in DW_crc_p.  Please report to Synopsys representative." 
  	    severity ERROR;
		end case;

		return crc_inv_alt;

end make_crc_inv_alt;


constant	crc_inv_alt : std_logic_vector(poly_size-1
					downto 0)
			:= make_crc_inv_alt(poly_size);

signal	crc_in_inv : 	std_logic_vector(poly_size-1 downto 0);
signal	crc_in_ordered :std_logic_vector(poly_size-1 downto 0);
signal	crc_reg : 	std_logic_vector(poly_size-1 downto 0);
signal	crc_out_inv : 	std_logic_vector(poly_size-1 downto 0);

-- pragma translate_on

begin
-- pragma translate_off

	crc_in_ordered <= bit_ordering(crc_in);
	crc_in_inv <= crc_in_ordered XOR crc_inv_alt;

	crc_reg <= calculate_crc(bit_ordering(data_in));

	crc_out_inv <= crc_reg XOR crc_inv_alt;
	crc_out <= bit_ordering(crc_out_inv);


    
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    

	
    if ( (poly_coef0 mod 2)=0 ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid parameter (poly_coef0 value MUST be odd)"
        severity warning;
    end if;
	
    if ( (bit_order>1) AND (data_width mod 8 > 0) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid parameter combination (bit_order > 1 only allowed when data_width is multiple of 8)"
        severity warning;
    end if;
	
    if ( (bit_order>1) AND (poly_size mod 8 > 0) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid parameter combination (bit_order > 1 only allowed when poly_size is multiple of 8)"
        severity warning;
    end if;

    
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;

SYNDROME_CHK : process(crc_reg, crc_in_inv)
variable crc_chk_crc_in : std_logic_vector(poly_size-1 downto 0);
variable crc_ok_n : std_logic;
begin

	crc_chk_crc_in := calculate_crc(crc_reg, crc_in_inv);
	crc_ok_n := '0';
	for bit_idx in poly_size-1 downto 0 loop
	  crc_ok_n := crc_ok_n OR crc_chk_crc_in(bit_idx);
	end loop;
	crc_ok <= NOT crc_ok_n;

end process SYNDROME_CHK;

-- pragma translate_on
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_crc_p_cfg_sim of DW_crc_p is
 for sim
 end for; -- sim
end DW_crc_p_cfg_sim;
-- pragma translate_on

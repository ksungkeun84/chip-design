--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 1995 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    KB                 May 20, 1995
--
-- VERSION:   VHDL Simulation Model for DW_iir_sc
--
-- DesignWare_version: 52731e89
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
-- ABSTRACT: VHDL simulation model for IIR filter with static coefficients
--
-- MODIFIED:  
--            Doug Lee    06/02/2008
--              Added extra legality check to not allow
--                "B0_coef != 0" and all other coefficients "0".
--
--            Zhijun (Jerry) Huang      02/17/2004
--            Changed interface names
--            Added parameter legality check
--            Added asynchronous reset signal rst_n
--            Added optional output register controlled by parameter out_reg
--            Added X-processing
--            Fixed logic errors by changing some signals to variables in the 
--            rounding/saturation process
--            Fixed the errors due to integer's 32-bit range limit
--
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_misc.all;
architecture sim of DW_iir_sc is 
	
-- pragma translate_off

function maximum(L, R: INTEGER) return INTEGER is
    begin
        if L > R then
            return L;
        else
            return R;
        end if;
end;
 
constant psum_width	: INTEGER := maximum((feedback_width + max_coef_width + 3),
					     (data_in_width + frac_data_out_width + max_coef_width + 3));

signal  padd_const_signed	: SIGNED(frac_data_out_width+1 downto 0);
constant A1_coef_signed	: SIGNED(max_coef_width-1 downto 0) := CONV_SIGNED(A1_coef,max_coef_width);
constant A2_coef_signed	: SIGNED(max_coef_width-1 downto 0) := CONV_SIGNED(A2_coef,max_coef_width);
constant B0_coef_signed	: SIGNED(max_coef_width-1 downto 0) := CONV_SIGNED(B0_coef,max_coef_width);
constant B1_coef_signed	: SIGNED(max_coef_width-1 downto 0) := CONV_SIGNED(B1_coef,max_coef_width);
constant B2_coef_signed	: SIGNED(max_coef_width-1 downto 0) := CONV_SIGNED(B2_coef,max_coef_width);
signal	gated_in_data	: std_logic_vector(data_in_width-1 downto 0) := (others => '0');
signal	feedback_data	: std_logic_vector(feedback_width-1 downto 0) := (others => '0');
signal	B0_product, B1_product, B2_product
			: SIGNED(data_in_width+max_coef_width-1 downto 0) := (others => '0');
signal	A1_product, A2_product
			: SIGNED(feedback_width+max_coef_width-1 downto 0) := (others => '0');
signal	A2_product_padded, B2_product_padded
			: SIGNED(psum_width-3 downto 0) := (others => '0');
signal	psum2, psum2_saved
			: std_logic_vector(psum_width-3 downto 0) := (others => '0');
signal	psum2_padded, psum1_A1_B1,
	A1_product_padded, B1_product_padded,
	B0_product_padded, psum0
			: SIGNED(psum_width-1 downto 0) := (others => '0');
signal	psum1, psum1_saved
			: std_logic_vector(psum_width-1 downto 0) := (others => '0');
signal  data_out_noreg, data_out_final 
			: std_logic_vector(data_out_width-1 downto 0);
signal  saturation_noreg, saturation_final
			: std_logic;
-- pragma translate_on

begin
-- pragma translate_off

  
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
    
    if (data_in_width < 2) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter data_in_width (lower bound: 2)"
        severity warning;
    end if;
    
    if ( (data_out_width < 2) OR (data_out_width > psum_width-frac_coef_width) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter data_out_width (legal range: 2 to psum_width-frac_coef_width)"
        severity warning;
    end if;
    
    if ( (frac_data_out_width < 0) OR (frac_data_out_width > data_out_width-1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter frac_data_out_width (legal range: 0 to data_out_width-1)"
        severity warning;
    end if;
    
    if (feedback_width < 2) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter feedback_width (lower bound: 2)"
        severity warning;
    end if;
    
    if ( (max_coef_width < 2) OR (max_coef_width > 31) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter max_coef_width (legal range: 2 to 31)"
        severity warning;
    end if;
    
    if ( (frac_coef_width < 0) OR (frac_coef_width > max_coef_width-1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter frac_coef_width (legal range: 0 to max_coef_width-1)"
        severity warning;
    end if;
    
    if ( (saturation_mode < 0) OR (saturation_mode > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter saturation_mode (legal range: 0 to 1)"
        severity warning;
    end if;
    
    if ( (out_reg < 0) OR (out_reg > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter out_reg (legal range: 0 to 1)"
        severity warning;
    end if;
    
    if ( (A1_coef < -2**(max_coef_width-1)) OR (A1_coef > 2**(max_coef_width-1)-1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter A1_coef (legal range: -2**(max_coef_width-1) to 2**(max_coef_width-1)-1)"
        severity warning;
    end if;
    
    if ( (A2_coef < -2**(max_coef_width-1)) OR (A2_coef > 2**(max_coef_width-1)-1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter A2_coef (legal range: -2**(max_coef_width-1) to 2**(max_coef_width-1)-1)"
        severity warning;
    end if;
    
    if ( (B0_coef < -2**(max_coef_width-1)) OR (B0_coef > 2**(max_coef_width-1)-1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter B0_coef (legal range: -2**(max_coef_width-1) to 2**(max_coef_width-1)-1)"
        severity warning;
    end if;
    
    if ( (B1_coef < -2**(max_coef_width-1)) OR (B1_coef > 2**(max_coef_width-1)-1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter B1_coef (legal range: -2**(max_coef_width-1) to 2**(max_coef_width-1)-1)"
        severity warning;
    end if;
    
    if ( (B2_coef < -2**(max_coef_width-1)) OR (B2_coef > 2**(max_coef_width-1)-1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter B2_coef (legal range: -2**(max_coef_width-1) to 2**(max_coef_width-1)-1)"
        severity warning;
    end if;
    
    if ( ((A1_coef=0) AND (A2_coef=0) AND (B1_coef=0) AND (B2_coef=0)) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Illegal to have all coefficients but B0_coef set to 0"
        severity warning;
    end if;
  
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;

  -- padd_const_signed = 2^frac_data_out_width 
  padd_const_signed(frac_data_out_width+1 downto frac_data_out_width) <= "01";
  g0: if (frac_data_out_width > 0) generate
      padd_const_signed(frac_data_out_width-1 downto 0) <= (others => '0');
  end generate g0;
  A1_product <= SIGNED(feedback_data) * A1_coef_signed;
  A2_product <= SIGNED(feedback_data) * A2_coef_signed;
  B0_product <= SIGNED(gated_in_data) * B0_coef_signed;
  B1_product <= SIGNED(gated_in_data) * B1_coef_signed;
  B2_product <= SIGNED(gated_in_data) * B2_coef_signed;
  A2_product_padded <= SIGNED(SXT(std_logic_vector(A2_product), psum_width-2));
  B2_product_padded <= CONV_SIGNED(B2_product * padd_const_signed, psum_width-2);
  psum2 <= A2_product_padded + B2_product_padded;
  A1_product_padded <= SIGNED(SXT(std_logic_vector(A1_product), psum_width));
  B1_product_padded <= CONV_SIGNED(B1_product * padd_const_signed, psum_width);
  psum1_A1_B1 <= A1_product_padded + B1_product_padded;
  psum2_padded <= SIGNED(SXT(psum2_saved,psum_width));
  psum1 <= psum1_A1_B1 + psum2_padded;
  B0_product_padded <= CONV_SIGNED(B0_product * padd_const_signed, psum_width);
  psum0 <= B0_product_padded + SIGNED(psum1_saved);
  
process(init_n, data_in)
begin
    if (init_n = '0') then
	gated_in_data <= (others => '0');
    else
	gated_in_data <= data_in;
    end if;
end process;
  
RND_SAT : process(psum0)
  variable round_limit		: SIGNED(frac_coef_width downto 0);
  variable max_pos_output	: SIGNED(data_out_width-1 downto 0);
  variable max_neg_output	: SIGNED(data_out_width-1 downto 0);
  variable max_pos_feedback	: SIGNED(feedback_width-1 downto 0);
  variable max_neg_feedback	: SIGNED(feedback_width-1 downto 0);
  variable output_inc_data 	: SIGNED(data_out_width-1 downto 0);
  variable feedback_inc_data	: SIGNED(feedback_width-1 downto 0);
  variable output_to_big	: std_logic;
  variable feedback_to_big	: std_logic;
begin
    max_pos_output(data_out_width-1) := '0';
    max_neg_output(data_out_width-1) := '1';
    if (data_out_width > 2) then
	max_pos_output(data_out_width-2 downto 0) := (others => '1');
	max_neg_output(data_out_width-2 downto 1) := (others => '0');
    elsif (data_out_width = 2) then
	max_pos_output(0) := '1';
    end if;
    if (saturation_mode = 0) then
	max_neg_output(0) := '0';
    else
	max_neg_output(0) := '1';
    end if;
    max_pos_feedback(feedback_width-1) := '0';
    max_neg_feedback(feedback_width-1) := '1';
    if (feedback_width > 2) then
	max_pos_feedback(feedback_width-2 downto 0) := (others => '1');
	max_neg_feedback(feedback_width-2 downto 1) := (others => '0');
    elsif (feedback_width = 2) then
	max_pos_feedback(0) := '1';
    end if;
    if (saturation_mode = 0) then
	max_neg_feedback(0) := '0';
    else
	max_neg_feedback(0) := '1';
    end if;

    if (frac_coef_width > 0) then
        -- round_limit = -2^(frac_coef_width-1)
        round_limit(frac_coef_width downto 0) := (others => '0');
        round_limit(frac_coef_width downto frac_coef_width-1) := "11";

    	if (psum0(psum_width-1 downto frac_coef_width-1)
		 >= (max_pos_output & '1')) then
		data_out_noreg <= std_logic_vector(max_pos_output);
		output_to_big := '1';
	elsif (psum0(psum_width-1 downto frac_coef_width) < max_neg_output) then
		data_out_noreg <= std_logic_vector(max_neg_output);
		output_to_big := '1';
	elsif (     (psum0(frac_coef_width-1) = '1')
		    and (   (psum0(psum_width-1) = '0')
			 or (psum0(frac_coef_width-1 downto 0) > round_limit))) then
		output_inc_data := psum0(data_out_width+frac_coef_width-1 downto frac_coef_width) + 1;
		data_out_noreg <= std_logic_vector(output_inc_data);
		output_to_big := '0';
	else	
		data_out_noreg <= std_logic_vector(
			psum0(data_out_width+frac_coef_width-1 downto frac_coef_width));
		output_to_big := '0';
	end if;
	if (psum0(psum_width-1 downto frac_coef_width-1)
		 >= (max_pos_feedback & '1')) then
		feedback_data <= std_logic_vector(max_pos_feedback);
		feedback_to_big := '1';
	elsif (psum0(psum_width-1 downto frac_coef_width) < max_neg_feedback) then
		feedback_data <= std_logic_vector(max_neg_feedback);
		feedback_to_big := '1';
	elsif (     (psum0(frac_coef_width-1) = '1')
		    and (   (psum0(psum_width-1) = '0')
			 or (psum0(frac_coef_width-1 downto 0) > round_limit))) then
		feedback_inc_data := 
			psum0(feedback_width+frac_coef_width-1 downto frac_coef_width) + 1;
		feedback_data <= std_logic_vector(feedback_inc_data);
		feedback_to_big := '0';
	else	
		feedback_data <= std_logic_vector(
			psum0(feedback_width+frac_coef_width-1 downto frac_coef_width));
		feedback_to_big := '0';
	end if;
    else
	if (psum0 > max_pos_output) then
		data_out_noreg <= std_logic_vector(max_pos_output);
		output_to_big := '1';
	elsif (psum0 < max_neg_output) then
		data_out_noreg <= std_logic_vector(max_neg_output);
		output_to_big := '1';
	else	
		data_out_noreg <= std_logic_vector(psum0(data_out_width-1 downto 0));
		output_to_big := '0';
	end if;
	if (psum0 > max_pos_feedback) then
		feedback_data <= std_logic_vector(max_pos_feedback);
		feedback_to_big := '1';
	elsif (psum0 < max_neg_feedback) then
		feedback_data <= std_logic_vector(max_neg_feedback);
		feedback_to_big := '1';
	else	
		feedback_data <= std_logic_vector(psum0(feedback_width-1 downto 0));
		feedback_to_big := '0';
	end if;
    end if;
    saturation_noreg <= output_to_big or feedback_to_big;
end process RND_SAT;


process(clk, rst_n, data_out_noreg, saturation_noreg) 
begin 
    if (out_reg = 0) then
        -- no registers on final outputs

        data_out_final <= data_out_noreg;
        saturation_final <= saturation_noreg;

        if (To_X01(rst_n) = '0') then
	    psum2_saved <= (others => '0'); 
            psum1_saved <= (others => '0'); 
        elsif (To_X01(rst_n) = '1') then
            if rising_edge(clk) then

                if (Is_X(init_n) or Is_X(enable) or 
                    Is_X(data_in) or Is_X(psum1_saved)) then
                    psum2_saved <= (others => 'X'); 
                elsif (init_n = '0') then
                    psum2_saved <= (others => '0'); 
                elsif (enable = '1') then
                    psum2_saved <= psum2;
                else 
                    psum2_saved <= psum2_saved;
                end if;

                if (Is_X(init_n) or Is_X(enable) or 
                    Is_X(data_in) or Is_X(psum2_saved)) then 
                    psum1_saved <= (others => 'X'); 
                elsif (init_n = '0') then
                    psum1_saved <= (others => '0');
                elsif (enable = '1') then
                    psum1_saved <= psum1;
                else
                    psum1_saved <= psum1_saved;
                end if;
                
            end if;
        else -- To_X01(rst_n) = 'X'
	    psum2_saved <= (others => 'X');
            psum1_saved <= (others => 'X');
        end if;
       
    else
        -- final outputs are registered
        
        if (To_X01(rst_n) = '0') then
	    psum2_saved <= (others => '0'); 
            psum1_saved <= (others => '0'); 
            data_out_final <= (others => '0');
            saturation_final <= '0';
        elsif (To_X01(rst_n) = '1') then
            if rising_edge(clk) then

                if (Is_X(init_n) or Is_X(enable) or 
                    Is_X(data_in) or Is_X(psum1_saved)) then
                    psum2_saved <= (others => 'X'); 
                elsif (init_n = '0') then
                    psum2_saved <= (others => '0'); 
                elsif (enable = '1') then
                    psum2_saved <= psum2;
                else
                    psum2_saved <= psum2_saved;
                end if;

                if (Is_X(init_n) or Is_X(enable) or 
                    Is_X(data_in) or Is_X(psum2_saved)) then 
                    psum1_saved <= (others => 'X'); 
                elsif (init_n = '0') then
                    psum1_saved <= (others => '0');
                elsif (enable = '1') then
                    psum1_saved <= psum1;
                else
                    psum1_saved <= psum1_saved;
                end if;

                if (Is_X(init_n) or Is_X(enable) or 
                    Is_X(data_in) or Is_X(psum1_saved)) then
                    data_out_final <= (others => 'X'); 
                    saturation_final <= 'X';
                elsif (init_n = '0') then
                    data_out_final <= (others => '0');
                    saturation_final <= '0';
                elsif (enable = '1') then
                    data_out_final <= data_out_noreg;
                    saturation_final <= saturation_noreg;
                else
                    data_out_final <= data_out_final;
                    saturation_final <= saturation_final;
                end if;
                
            end if;
        else -- To_X01(rst_n) = 'X'
	    psum2_saved <= (others => 'X');
            psum1_saved <= (others => 'X');
            data_out_final <= (others => 'X');
            saturation_final <= 'X';
        end if;

    end if;
    
end process;

data_out <= data_out_final;
saturation <= saturation_final;


  
  clk_monitor_PROC : process (clk) begin

    assert NOT (Is_X( clk ) AND (now > 0 ns)) 
      report "WARNING: Detected unknown value on the clock input port clk."
      severity warning;

  end process clk_monitor_PROC;

-- pragma translate_on
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_iir_sc_cfg_sim of DW_iir_sc is
 for sim
 end for; -- sim
end DW_iir_sc_cfg_sim;
-- pragma translate_on

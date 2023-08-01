--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 1994 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    PS      April 11, 1994
--
-- VERSION:   VHDL Simulation Model for DW_fir
--
-- DesignWare_version: ecf7edb6
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT: High-Speed Digital FIR Filter 
--
-- MODIFIED: Zhijun (Jerry) Huang     07/15/2003
--           changed interface names
--           reset all registers when rst_n is active 
--           added X-processing 
--           added parameter legality check 
--
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
architecture sim of DW_fir is
	
-- pragma translate_off
  type coef_array is array (order-1 downto 0) of std_logic_vector(coef_width-1 downto 0);  
  type acc_array is array (order-1 downto 0) of std_logic_vector(data_out_width-1 downto 0);    
  signal sample_data: std_logic_vector(data_in_width-1 downto 0);
  signal coef_data: coef_array;
  signal sum_acc: acc_array;  
-- pragma translate_on
begin
-- pragma translate_off

  
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
    
    if (data_in_width < 1) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter data_in_width (lower bound: 1)"
        severity warning;
    end if;
    
    if (coef_width < 1) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter coef_width (lower bound: 1)"
        severity warning;
    end if;
    
    if (data_out_width < 1) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter data_out_width (lower bound: 1)"
        severity warning;
    end if;
    
    if ( (order < 2) OR (order > 256) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter order (legal range: 2 to 256)"
        severity warning;
    end if;
  
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;

  process (sample_data, coef_data, sum_acc, clk, rst_n, data_in, coef_in, init_acc_val, coef_shift_en)
  variable data_tc: signed(data_in_width-1 downto 0);  
  variable data_uns: unsigned(data_in_width-1 downto 0);  
  variable coef_tc: signed(coef_width-1 downto 0);    
  variable coef_uns: unsigned(coef_width-1 downto 0);      
  variable sum_tc: signed(data_out_width-1 downto 0);          
  variable sum_uns: unsigned(data_out_width-1 downto 0);
  begin
    if (To_X01(rst_n) = '0') then   
      coef_data <= (others => (others => '0'));
      sum_acc <= (others => (others => '0'));
      sample_data <= (others => '0');
      data_out <= (others => '0');
      coef_out <= (others => '0');
    elsif (To_X01(rst_n) = '1') then
      
      -- propogate the 0th (last) word MAC (no latches on final outputs)
      if (Is_X(tc) or Is_X(sample_data) or Is_X(coef_data(0)) or Is_X(sum_acc(0))) then
        data_out <= (others => 'X');
      elsif (To_X01(tc) = '0') then        -- unsigned case
        data_uns := UNSIGNED(sample_data);
        coef_uns := UNSIGNED(coef_data(0));
        sum_uns := UNSIGNED(sum_acc(0));
        sum_uns := sum_uns + coef_uns * data_uns;
        data_out <= std_logic_vector(sum_uns);
      else  -- (To_X01(tc) = '1')          -- signed case
        data_tc := SIGNED(sample_data);
        coef_tc := SIGNED(coef_data(0));
        sum_tc := SIGNED(sum_acc(0));
        sum_tc := sum_tc + coef_tc * data_tc;
        data_out <= std_logic_vector(sum_tc);
      end if;
      coef_out <= coef_data(0);       -- send out coef
      
      if rising_edge(clk) then            
        -- execute FIR filter
        if (To_X01(tc) = '0') then          -- unsigned case
          data_uns := UNSIGNED(sample_data);
          for i in 1 to order-1 loop  -- for each tap            
            if (Is_X(sample_data) or Is_X(coef_data(i)) or Is_X(sum_acc(i))) then
              sum_acc(i-1) <= (others => 'X');
            else
              coef_uns := UNSIGNED(coef_data(i));
              sum_uns := UNSIGNED(sum_acc(i));
              sum_uns := sum_uns + coef_uns * data_uns;
              sum_acc(i-1) <= std_logic_vector(sum_uns);
            end if;
          end loop;
        elsif (To_X01(tc) = '1') then      -- signed case
          data_tc := SIGNED(sample_data);
          for i in 1 to order-1 loop  -- for each tap
            if (Is_X(sample_data) or Is_X(coef_data(i)) or Is_X(sum_acc(i))) then
              sum_acc(i-1) <= (others => 'X');
            else  
              coef_tc := SIGNED(coef_data(i));
              sum_tc := SIGNED(sum_acc(i));
              sum_tc := sum_tc + coef_tc * data_tc;
              sum_acc(i-1) <= std_logic_vector(sum_tc);
            end if;
          end loop;
        else 
          for i in 1 to order-1 loop
            sum_acc(i-1) <=  (others => 'X'); 
          end loop;
        end if;

        -- load coefficients serially if enabled
        if (To_X01(coef_shift_en) = '0') then
          for i in 0 to order-1 loop
            coef_data(i) <= coef_data(i);
          end loop;
        elsif (To_X01(coef_shift_en) = '1') then
          for i in 0 to order-2 loop
            coef_data(i) <= coef_data(i+1);  
          end loop;
          coef_data(order-1) <= coef_in;
        else
          coef_data <= (others => (others => 'X'));
        end if;                 

        -- latch incoming data
        if(Is_X(data_in)) then
          sample_data <= (others => 'X');
        else  
          sample_data <= data_in;
        end if;
        if(Is_X(init_acc_val)) then
          sum_acc(order-1) <= (others => 'X');
        else  
          sum_acc(order-1) <= init_acc_val;
        end if;
        
      end if; -- end if rising_edge(clk)       
    else -- To_X01(rst_n) = 'X'
      coef_data <= (others => (others => 'X'));
      sum_acc <= (others => (others => 'X'));
      sample_data <= (others => 'X');
      data_out <= (others => 'X');
      coef_out <= (others => 'X');
    end if;
  end process;

  
  clk_monitor_PROC  : process (clk) begin

    assert NOT (Is_X( clk ) AND (now > 0 ns)) 
      report "WARNING: Detected unknown value on the clock input port clk."
      severity warning;

  end process clk_monitor_PROC ;

-- pragma translate_on
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_fir_cfg_sim of DW_fir is
 for sim
 end for; -- sim
end DW_fir_cfg_sim;
-- pragma translate_on

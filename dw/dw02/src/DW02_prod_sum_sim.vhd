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
-- AUTHOR:    PS	    Dec. 21, 1994
--
-- VERSION:   VHDL Simulation Model
--
-- DesignWare_version: a576092f
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
-- ABSTRACT:  Generalized Sum of Products
--           signed or unsigned operands       
--           ie. TC = '1' => signed 
--	         TC = '0' => unsigned 
--
-- MODIFIED:
--	Bob Tong:       12/07/98
--                      STAR 59142
--
--------------------------------------------------------------------------
library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use DWARE.DW_Foundation_arith.all;

architecture sim of DW02_prod_sum is
	
  subtype prod_vector_signed is
    SIGNED(A_width+B_width-1 downto 0);  
  subtype prod_vector_unsigned is
    UNSIGNED(A_width+B_width-1 downto 0);      
  subtype sum_vector_unsigned is
    UNSIGNED(SUM_width-1 downto 0);
  subtype sum_vector_signed is
    SIGNED(SUM_width-1 downto 0); 
begin
-- pragma translate_off
    
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
      
    if (A_width < 1) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter A_width (lower bound: 1)"
        severity warning;
    end if;
      
    if (B_width < 1) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter B_width (lower bound: 1)"
        severity warning;
    end if;
      
    if (num_inputs < 1) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter num_inputs (lower bound: 1)"
        severity warning;
    end if;
      
    if (SUM_width < 1) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter SUM_width (lower bound: 1)"
        severity warning;
    end if;
    
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;  
  
  process (A,B,TC)
    variable PROD_un: prod_vector_unsigned;
    variable PROD_tc: prod_vector_signed;    
    variable SUM_un, XPROD_un: sum_vector_unsigned;
    variable SUM_tc, XPROD_tc: sum_vector_signed;
  begin 
    if(Is_X(A) or Is_X(B) or Is_X(TC)) then
      SUM <= (others => 'X');
    elsif TC = '0' then
      SUM_un := sum_vector_unsigned'(others => '0');
      for i in 0 to num_inputs-1 loop
        PROD_un := UNSIGNED(A((i+1)*A_width-1 downto i*A_width)) *
     	           UNSIGNED(B((i+1)*B_width-1 downto i*B_width)); 
	if SUM_width > A_width+B_width then
	  XPROD_un(A_width+B_width-1 downto 0) := PROD_un;
	  for i in A_width+B_width to SUM_width-1 loop
	    XPROD_un(i) := '0';
	  end loop; 
	  SUM_un := SUM_un + XPROD_un;
	else
	  SUM_un := SUM_un + PROD_un(SUM_width-1 downto 0);
	end if;
      end loop;
      SUM <= std_logic_vector(SUM_un);
    else
      SUM_tc := sum_vector_signed'(others => '0');
      for i in 0 to num_inputs-1 loop
        PROD_tc := SIGNED(A((i+1)*A_width-1 downto i*A_width)) *
                   SIGNED(B((i+1)*B_width-1 downto i*B_width)); 
	if SUM_width > A_width+B_width then
	  XPROD_tc(A_width+B_width-1 downto 0) := PROD_tc;
	  for i in A_width+B_width to SUM_width-1 loop
	    XPROD_tc(i) := PROD_tc(A_width+B_width-1);
	  end loop; 
	  SUM_tc := SUM_tc + XPROD_tc;
	else
	  SUM_tc := SUM_tc + PROD_tc(SUM_width-1 downto 0);
	end if;
      end loop;
      SUM <= std_logic_vector(SUM_tc);
    end if;
  end process;
-- pragma translate_on
end sim;
  
----------------------------------------------------------------

--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW02_prod_sum_cfg_sim of DW02_prod_sum is
 for sim
 end for; -- sim
end DW02_prod_sum_cfg_sim;
-- pragma translate_on

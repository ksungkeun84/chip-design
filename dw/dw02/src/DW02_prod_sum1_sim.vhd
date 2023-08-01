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
-- DesignWare_version: aa6497b7
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
-- ABSTRACT:  Multiplier-Adder
--           signed or unsigned operands       
--           ie. TC = '1' => signed 
--	         TC = '0' => unsigned 
--
--  MODIFIED:
---	Bob Tong:       12/07/98
--                      STAR 59142
--
--      Doug Lee:       03/21/2006
--                      Replaced behavioral code 'process' block
--			with DW02_prod_sum1_sim.h
--
------------------------------------------------------------------------
library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use DWARE.DW_Foundation_arith.all;
architecture sim of DW02_prod_sum1 is
	
  
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
  process (A,B,C,TC)
    variable SUM_tc, PROD_tc: SIGNED(SUM_width-1 downto 0);    
    variable SUM_un, PROD_un: UNSIGNED(SUM_width-1 downto 0);   
    variable PROD1_tc: SIGNED(A_width+B_width-1 downto 0);    
    variable PROD1_un: UNSIGNED(A_width+B_width-1 downto 0);       
    variable A_tc: SIGNED(A_width-1 downto 0);
    variable B_tc: SIGNED(B_width-1 downto 0);    
    variable A_un: UNSIGNED(A_width-1 downto 0);
    variable B_un: UNSIGNED(B_width-1 downto 0);        
  begin 
    if (Is_X(A) or Is_X(B) or Is_X(C) or Is_X(TC)) then 
      SUM <= (others => 'X');
    elsif TC = '0' then
      A_un := UNSIGNED(A);
      B_un := UNSIGNED(B);      
      PROD1_un := A_un * B_un;
      if SUM_width < A_width+B_width then
        PROD_un := PROD1_un(SUM_width-1 downto 0);
      else
        PROD_un := (others => '0'); 
        PROD_un(A_width+B_width-1 downto 0) := PROD1_un;      
      end if;
      SUM_un := PROD_un + UNSIGNED(C);            
      SUM <= std_logic_vector(SUM_un);
    else
      A_tc := SIGNED(A);
      B_tc := SIGNED(B);          
      PROD1_tc := A_tc * B_tc;
      if SUM_width >= A_width+B_width then
        PROD_tc(A_width+B_width-1 downto 0) := PROD1_tc;
        if (SUM_width > A_width+B_width) then
          for i in SUM_width-1 downto A_width+B_width loop
            PROD_tc(i) := PROD_tc(A_width+B_width-1);
          end loop;
        end if;
      else
        PROD_tc := PROD1_tc(SUM_width-1 downto 0);      
      end if;
      
      SUM_tc := PROD_tc + SIGNED(C);
      SUM <= std_logic_vector(SUM_tc);
    end if;
  end process;
-- pragma translate_on
end sim;
----------------------------------------------------------------

--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW02_prod_sum1_cfg_sim of DW02_prod_sum1 is
 for sim
 end for; -- sim
end DW02_prod_sum1_cfg_sim;
-- pragma translate_on

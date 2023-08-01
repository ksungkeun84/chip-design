--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 1992 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Paul Sheit/Rajeev Huralikoppi
--
-- VERSION:   VHDL Simulation Model
--
-- DesignWare_version: e6d453dc
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Carry Save Adder
--
-- MODIFIED:
--  08/28/2002  RPH             Rewrote the model according to the new coding
--                              Guidelines--
--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
 
architecture sim of DW01_csa is
	
  -- pragma translate_off
procedure add_abc(A,B,C: std_logic; S,COUT: out std_logic) is
  variable T : std_logic;
begin
  T := A xor B;
  S := T xor C;
  COUT := (A and B) or (T and C);
end add_abc;
  -- pragma translate_on

begin
-- pragma translate_off
    
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
    
    if (width < 1) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter width (lower bound: 1)"
        severity warning;
    end if;
    
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;
    
    process(a,b,c,ci)
      variable temp_sum   : std_logic_vector(width-1 downto 0) := (others => '0');
      variable temp_carry : std_logic_vector(width-1 downto 0) := (others => '0');
      variable temp_cout  : std_logic                          := '0';
    begin
      if (Is_x(a) or Is_x(b) or Is_x(c) or Is_x(ci)) then
        temp_sum := (others => 'X');
        temp_carry := (others => 'X');
        temp_cout := 'X';
      else
        temp_carry(0) := c(0);
        if width > 1 then
          add_abc(A => a(0), B => b(0), C => ci, 
                  S => temp_sum(0), COUT => temp_carry(1));
          if width > 2 then
            for i in 1 to (width-2) loop
              add_abc(A => a(i), B => b(i), C => c(i), 
                      S => temp_sum(i), COUT => temp_carry(i+1));
            end loop;
          end if;
          add_abc(A => a(width-1), B => b(width-1), C => c(width-1),
                  S => temp_sum(width-1), COUT => temp_cout);
        end if;
        if width = 1 then
          add_abc(A => a(width-1), B => b(width-1), C => ci,
                  S => temp_sum(width-1), COUT => temp_cout);
        end if;          
      end if;   
      sum <= temp_sum;
      carry <= temp_carry;
      co <= temp_cout;
    end process;
-- pragma translate_on
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW01_csa_cfg_sim of DW01_csa is
 for sim
 end for; -- sim
end DW01_csa_cfg_sim;
-- pragma translate_on

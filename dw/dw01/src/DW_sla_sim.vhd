--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2006 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Alex Tenca - March 2006
--
-- VERSION:   VHDL Simulation Model
--
-- DesignWare_version: b25284f2
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------

------------------------------------------------------------------------------
--
-- ABSTRACT: Arithmetic Left Shifter - VHDL style
--           This component performs left and right shifting.
--           When SH_TC = '0', the shift coefficient SH is interpreted as a
--           positive unsigned number and only left shifts are performed.
--           When SH_TC = '1', the shift coefficient SH is a signed two's
--           complement number. A negative coefficient indicates
--           a right shift (division) and a positive coefficient indicates
--           a left shift (multiplication).
--           The input data A is always considered a signed value.
--           The MSB on A is extended when shifted to the right, and the 
--           LSB on A is extended when shifting to the left.
--
-- MODIFIED: 
--
------------------------------------------------------------------------------

library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use DWARE.DW_Foundation_arith.all;

architecture sim of DW_sla is
	
-- pragma translate_off

signal A_signed : signed(A_width-1 downto 0);

-- pragma translate_on  
begin
-- pragma translate_off
  
    
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
    
    if (A_width < 2) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter A_width (lower bound: 2)"
        severity warning;
    end if;
    
    if (SH_width < 1) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter SH_width (lower bound: 1)"
        severity warning;
    end if;     
    
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;  

P: process (A, SH, SH_TC)
   variable SH_integer: integer; 
   variable B_INT : std_logic_vector (A_width-1 downto 0) ;
   begin
    if (Is_x(SH_TC) or Is_x(A) or Is_x(SH)) then
        B_INT := (others => 'X');
    else
      if ((SH_TC = '0') or (SH(SH_width-1) = '0')) then
        SH_integer := conv_integer(unsigned(SH));
        B_INT := A;
        while (SH_integer > 0) loop
          B_INT := B_INT(B_INT'length-2 downto 0) & B_INT(0);
          SH_integer := SH_integer - 1;
        end loop;
      else
        SH_integer := - conv_integer(signed(SH));
        B_INT := A;
        while (SH_integer > 0) loop
          B_INT := B_INT(B_INT'length-1) & B_INT(B_INT'length-1 downto 1);
          SH_integer := SH_integer - 1;        
        end loop;
      end if;
    end if;

    B <= B_INT;

   end process;

-- pragma translate_on  
end sim ;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_sla_cfg_sim of DW_sla is
 for sim
 end for; -- sim
end DW_sla_cfg_sim;
-- pragma translate_on

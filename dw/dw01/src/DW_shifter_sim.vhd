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
-- AUTHOR:    Nitin Mhamunkar  August 1999
--
-- VERSION:   VHDL Simulation Model
--
-- DesignWare_version: 7f1e4c4b
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT : Combo  Shifter
--
-- MODIFIED :	    
--
--  11/04/15  RJK  Change pkg use from individual DW01 pkg to unified DWARE pkg
--
---------------------------------------------------------------------------------

library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use DWARE.DW_Foundation_arith.all;


architecture sim of DW_shifter is
	
  
-- pragma translate_off
 function shift_uns_uns(
   arg         : UNSIGNED;
   shift        : UNSIGNED;
   sh_mode      : std_logic;
   padded_value : std_logic)
   return UNSIGNED is
     
     constant control_msb: INTEGER := shift'length - 1;
     variable control: UNSIGNED (control_msb downto 0);
     constant result_msb: INTEGER := arg'length-1;
     subtype rtype is UNSIGNED (result_msb downto 0);
     variable result, temp: rtype;
   begin
     control := shift;
     if (control(0) = 'X') then
       result := rtype'(others => 'X');
       return result;
     else
       if(sh_mode = '1') then
         result := arg;
         for i in 0 to control_msb loop
           if control(i) = '1' then
             temp := rtype'(others => padded_value);
             if 2**i <= result_msb then
               temp(result_msb downto 2**i) := 
                 result(result_msb - 2**i downto 0);
             end if;
             result := temp;
           end if;
         end loop;
         return result;
       else
         result := DWF_bsh(UNSIGNED(arg), UNSIGNED(shift));
         return result;
       end if;
     end if;
   end;
     

 function shift_tc_uns(
   arg         : UNSIGNED;
   shift        : SIGNED;
   sh_mode      : std_logic;
   padded_value : std_logic)
   return UNSIGNED is
     
     constant control_msb  : INTEGER := shift'length - 1;
     variable control      : SIGNED (control_msb downto 0);
     constant result_msb   : INTEGER := arg'length-1;
     subtype  rtype is UNSIGNED (result_msb downto 0);
     variable result, temp : rtype;
     variable sign_bit: STD_ULOGIC;
   begin
     
     if (control(0) = 'X') then
       result := rtype'(others => 'X');
       return result;
     else
       if(sh_mode = '1') then
         if(shift(control_msb) = '0') then
           result := arg;
           control := shift;
           for i in 0 to control_msb loop
             if control(i) = '1' then
               temp := rtype'(others => padded_value);
               if 2**i <= result_msb then
                 temp(result_msb downto 2**i) := 
                   result(result_msb - 2**i downto 0);
               end if;
               result := temp;
             end if;
           end loop;
         else
           result := arg;
           control := ABS(SIGNED(shift));
           for i in 0 to control_msb loop
             if control(i) = '1' then
               temp := rtype'(others => padded_value);
               if 2**i <= result_msb then
                 temp(result_msb - 2**i downto 0) := 
                   result(result_msb downto 2**i);
               end if;
               result := temp;
             end if;
           end loop;
         end if;
         return result;
       else
         if(shift(control_msb) = '0') then
           result := DWF_bsh(UNSIGNED(arg), UNSIGNED(shift));
         else
           result := arg;
           control := ABS(SIGNED(shift));
           for i in 0 to control_msb loop
             if control(i) = '1' then
               if 2**i <= result_msb+1 then
                 temp(result_msb - 2**i downto 0) := 
                   result(result_msb downto 2**i);
                 temp(result_msb downto result_msb-2**i+1):=
                   result(2**i-1 downto 0);
               end if;
               result := temp;
             end if;
           end loop;
         end if;
         return result;
       end if;
     end if;
   end;

 function shift_uns_tc(
   arg         : SIGNED;
   shift        : UNSIGNED;
   sh_mode      : std_logic;
   padded_value : std_logic)
   return SIGNED is
     
     constant control_msb  : INTEGER := shift'length - 1;
     variable control      : UNSIGNED (control_msb downto 0);
     constant result_msb   : INTEGER := arg'length-1;
     subtype  rtype is SIGNED (result_msb downto 0);
     variable result, temp : rtype;
     variable sign_bit: STD_ULOGIC;
   begin
     control := shift;
     
     if (control(0) = 'X') then
       result := rtype'(others => 'X');
       return result;
     else
       if(sh_mode = '1') then
           result := arg;
           for i in 0 to control_msb loop
             if control(i) = '1' then
               temp := rtype'(others => padded_value);
               if 2**i <= result_msb then
                 temp(result_msb downto 2**i) := 
                   result(result_msb - 2**i downto 0);
               end if;
               result := temp;
             end if;
           end loop;
         return result;
       else
         result := DWF_bsh(SIGNED(arg), UNSIGNED(shift));
         return result;
       end if;
     end if;
   end;

 function shift_tc_tc(
   arg         : SIGNED;
   shift        : SIGNED;
   sh_mode      : std_logic;
   padded_value : std_logic)
   return SIGNED is
     
     constant control_msb  : INTEGER := shift'length - 1;
     variable control      : SIGNED (control_msb downto 0);
     constant result_msb   : INTEGER := arg'length-1;
     subtype  rtype is SIGNED (result_msb downto 0);
     variable result, temp : rtype;
     variable sign_bit: STD_ULOGIC;
   begin
     
     if (control(0) = 'X') then
       result := rtype'(others => 'X');
       return result;
     else
       if(sh_mode = '1') then
         if(shift(control_msb) = '0') then
           result := arg;
           control := shift;
           for i in 0 to control_msb loop
             if control(i) = '1' then
               temp := rtype'(others => padded_value);
               if 2**i <= result_msb then
                 temp(result_msb downto 2**i) := 
                   result(result_msb - 2**i downto 0);
               end if;
               result := temp;
             end if;
           end loop;
         else
           result := arg;
           sign_bit := arg(result_msb);
           control := ABS(SIGNED(shift));
           for i in 0 to control_msb loop
             if control(i) = '1' then
               temp := rtype'(others => sign_bit);
               if 2**i <= result_msb then
                 temp(result_msb - 2**i downto 0) := 
                   result(result_msb downto 2**i);
               end if;
               result := temp;
             end if;
           end loop;
         end if;
         return result;
       else
         if(shift(control_msb) = '0') then
           result := DWF_bsh(SIGNED(arg), UNSIGNED(shift));
         else
           result := arg;
           control := ABS(SIGNED(shift));
           for i in 0 to control_msb loop
             if control(i) = '1' then
               if 2**i <= result_msb+1 then
                 temp(result_msb - 2**i downto 0) := 
                   result(result_msb downto 2**i);
                 temp(result_msb downto result_msb-2**i+1):=
                   result(2**i-1 downto 0);
               end if;
               result := temp;
             end if;
           end loop;
         end if;
         return result;
       end if;
     end if;
   end;
 
 signal sh_int       : std_logic_vector(sh_width-1 downto 0);
 signal sh_tc_int    : std_logic;
 signal data_tc_int  : std_logic;
 signal padded_value : std_logic;
-- pragma translate_on
 
begin
-- pragma translate_off
  
  -----------------------------------------------------------------------------
  -- Parameter legality check
  -----------------------------------------------------------------------------  
  
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
    
    if (data_width < 2) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter data_width (lower bound: 2)"
        severity warning;
    end if;
    
    if ( (sh_width < 1) OR (sh_width > (bit_width(data_width)+1)) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter sh_width (legal range: 1 to (bit_width(data_width)+1))"
        severity warning;
    end if;
    
    if ( (inv_mode < 0) OR (inv_mode > 3) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter inv_mode (legal range: 0 to 3)"
        severity warning;
    end if;   
  
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;

  padded_value <= '0'     when (inv_mode = 0 or inv_mode = 2) else '1';
  data_tc_int  <= data_tc when (inv_mode = 0 or inv_mode = 1) else not data_tc;
  sh_tc_int    <= sh_tc   when (inv_mode = 0 or inv_mode = 1) else not sh_tc;
  sh_int       <= sh      when (inv_mode = 0 or inv_mode = 1) else not sh;
       
  data_out <= (others => 'X') when (Is_X(sh_tc) or (Is_X(data_tc) and Is_X(sh(sh_width-1))) or (Is_X(sh) )) else
              std_logic_vector(shift_uns_uns(UNSIGNED(data_in), UNSIGNED(sh_int), sh_mode, padded_value))
              when ((sh_tc_int ='0') and (data_tc_int ='0') ) else
              std_logic_vector(shift_uns_tc(SIGNED(data_in), UNSIGNED(sh_int), sh_mode, padded_value))
              when ((sh_tc_int ='0') and (data_tc_int ='1') ) else              
              std_logic_vector(shift_tc_uns(UNSIGNED(data_in), SIGNED(sh_int), sh_mode, padded_value))
              when ((sh_tc_int ='1') and (data_tc_int ='0') ) else
              std_logic_vector(shift_tc_tc(SIGNED(data_in), SIGNED(sh_int), sh_mode, padded_value));

  -- pragma translate_on
     
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_shifter_cfg_sim of DW_shifter is
 for sim
 end for; -- sim
end DW_shifter_cfg_sim;
-- pragma translate_on

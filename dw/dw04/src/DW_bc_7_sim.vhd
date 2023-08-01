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
-- AUTHOR:    Bob Tong			March 1, 1998		
--
-- VERSION:   VHDL Simulation Model
--
-- DesignWare_version: 8a0ccdc5
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Boundary Scan Cell Type BC_7
--
--           
--
--              
--  Input Ports:  	Size 	Description
--  ===========     	====   	===========
--  capture_clk    	1 bit  	Clocks data into the capture stage.
--  update_clk      	1 bit  	Clocks data into the update stage. 
--  capture_en      	1 bit  	Enable for data clocked into the capture. 
--  update_en       	1 bit  	Enable for data clocked into the update 
--				stage. 
--  shift_dr        	1 bit  	Enables the boundary scan chain to shift 
--				data one stage toward its serial output 
--				(tdo). 
--  mode1		1 bit  	Determines whether data_out is controlled 
--				by the boundary scan cell or by the 
--				output_data signal.
--  mode2		1 bit  	Determines whether ic_input is controlled 
--				by the boundary scan cell or by the 
--				pin_input signal.
--  si			1 bit  	Serial path from the previous boundary 
--				scan cell.
--  pin_input		1 bit	IC system input pin.
--  control_out		1 bit	Control signal for the output enable.
--  output_data		1 bit 	IC output logic signal.
--
--  Output Ports    	Size   	Description
--  ============    	====   	===========
--  ic_input		1 bit	Ic input logic signal.
--  data_out       	1 bit  	Output data
--  so              	1 bit  	Serial path to the next boundary scan cell.
--              
--
--
-- MODIFIED: 
--
---------------------------------------------------------------------------
library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use DWARE.DWpackages.all;
architecture sim of DW_bc_7 is
	
  signal so_int, data_out_int : std_logic;
  signal update_out : std_logic;
  signal ic_input_int : std_logic;
  signal m1_sel : std_logic;
  signal capture_en_int, shift_dr_int, capture_clk_int : std_logic;
  signal update_en_int, update_clk_int : std_logic;
  signal mode1_int, mode2_int : std_logic;
  signal pin_input_int, control_out_int : std_logic;
  signal output_data_int, si_int: std_logic;
begin
-- pragma translate_off
  capture_en_int <= To_01X(capture_en);
  shift_dr_int <= To_01X(shift_dr);
  capture_clk_int <= To_01X(capture_clk);
  update_en_int <= To_01X(update_en);
  update_clk_int <= To_01X(update_clk);
  mode1_int <= To_01X(mode1);
  mode2_int <= To_01X(mode2);
  pin_input_int <= To_01X(pin_input);
  control_out_int <= To_01X(control_out);
  output_data_int <= To_01X(output_data);
  si_int <= To_01X(si);
  so <= so_int;
  data_out <= data_out_int;
  ic_input <= ic_input_int;
  m1_sel <= ((not mode1_int) and control_out_int);
seq1_proc : process 
begin
    if (capture_clk_int = '1' or (capture_clk_int = 'X'
        and capture_clk_int'last_value = '0') ) then
      if (capture_en_int = '0') then
        if (shift_dr_int = '0') then
          if (m1_sel = '0') then
            if (capture_clk_int'last_value = 'X'
                	or (capture_clk_int = 'X'
                	and capture_clk_int'last_value = '0')) then
              if (ic_input_int /= so_int) then
                so_int <= 'X';
              end if;
            else
              so_int <= ic_input_int;
            end if;
          elsif (m1_sel = '1') then
            if (capture_clk_int'last_value = 'X'
                	or (capture_clk_int = 'X'
                        and capture_clk_int'last_value = '0')) then
              if (data_out_int /= so_int) then
                so_int <= 'X';
              end if;
            else
              so_int <= data_out_int;
            end if;
          elsif (data_out_int /= ic_input_int) then
            so_int <= 'X';
          elsif (capture_clk_int'last_value = 'X'
                	or (capture_clk_int = 'X'
                	and capture_clk_int'last_value = '0')) then
            if (data_out_int /= so_int) then
              so_int <= 'X';
            end if;
          else
            so_int <= data_out_int;
          end if; 
        elsif (shift_dr_int = '1') then
          if (capture_clk_int'last_value = 'X' or (capture_clk_int = 'X'
                and capture_clk_int'last_value = '0')) then
            if (si_int /= so_int) then
              so_int <= 'X';
            end if;
          else
            so_int <= si_int;
          end if;
        elsif (shift_dr_int = 'X') then
          if (m1_sel = '0') then
            if (ic_input_int /= si_int) then
              so_int <= 'X';
            elsif (capture_clk_int'last_value = 'X'
              		or (capture_clk_int = 'X'
                        and capture_clk_int'last_value = '0')) then
              if (ic_input_int /= so_int) then
                so_int <= 'X';
              end if;
            else
              so_int <= ic_input_int;
            end if;
          elsif (m1_sel = '1') then
            if (data_out_int /= si_int) then
              so_int <= 'X';
            elsif (capture_clk_int'last_value = 'X'
                        or (capture_clk_int = 'X'
                        and capture_clk_int'last_value = '0')) then
              if (data_out_int /= so_int) then
                so_int <= 'X';
              end if;
            else
              so_int <= data_out_int;
            end if;
          elsif (data_out_int /= ic_input_int) then
            so_int <= 'X';
          elsif (data_out_int /= si_int) then
            so_int <= 'X';
          elsif (capture_clk_int'last_value = 'X'
			or (capture_clk_int = 'X'
                	and capture_clk_int'last_value = '0')) then
            if (data_out_int /= so_int) then
              so_int <= 'X';
            end if;
          else
            so_int <= data_out_int;
          end if;  
        end if;  
      elsif (capture_en_int = 'X') then
        if (shift_dr_int = '0') then
          if (m1_sel = '0') then
            if (ic_input_int /= so_int) then
              so_int <= 'X';
            end if;
          elsif (m1_sel = '1') then
            if (data_out_int /= so_int) then
              so_int <= 'X';
            end if;
          elsif (ic_input_int /= data_out_int) then
            so_int <= 'X';
          elsif (ic_input_int /= so_int) then
            so_int <= 'X';
          end if;
        elsif (shift_dr_int = '1') then
          if (si_int /= so_int) then
            so_int <= 'X';
          end if;
        elsif (shift_dr_int = 'X') then
          if (m1_sel = '0') then
            if (ic_input_int /= si_int) then
              so_int <= 'X';
            elsif (ic_input_int /= so_int) then
              so_int <= 'X';
            end if;
          elsif (m1_sel = '1') then
            if (data_out_int /= si_int) then
              so_int <= 'X';
            elsif (data_out_int /= so_int) then
              so_int <= 'X'; 
            end if;   
          elsif (ic_input_int /= data_out_int) then
            so_int <= 'X';   
          elsif (ic_input_int /= si_int) then
            so_int <= 'X';   
          elsif (ic_input_int /= so_int) then
            so_int <= 'X';   
          end if; 
        end if;  
      end if;  
    end if;  
    wait until capture_clk_int'EVENT;
end process seq1_proc;
 
seq2_proc : process 
begin
    if (update_clk_int = '1' or (update_clk_int = 'X'
        and update_clk_int'last_value = '0')) then
      if (update_en_int = '1') then
        if (update_clk_int'last_value = 'X' or (update_clk_int = 'X'
            and update_clk_int'last_value = '0')) then
          if (so_int /= update_out) then
            update_out <= 'X';
          end if;
        else
          update_out <= so_int;
        end if;
      elsif (update_en_int = 'X') then
        if (so_int /= update_out) then
          update_out <= 'X';
        end if;
      end if;
    end if;
    wait until update_clk_int'EVENT;
end process seq2_proc;
 
combo1_proc : process 
begin
    if (mode1_int = '0') then
      data_out_int <= output_data_int;
    elsif (mode1_int = '1') then
      data_out_int <= update_out;
    elsif (mode1_int = 'X') then
      if (output_data_int /= update_out) then
        data_out_int <= 'X';
      else
        data_out_int <= output_data_int;
      end if;
    end if;
    wait until (mode1_int'EVENT or output_data_int'EVENT or update_out'EVENT);
end process combo1_proc;
 
combo2_proc : process 
begin
    if (mode2_int = '0') then
      ic_input_int <= pin_input_int;
    elsif (mode2_int = '1') then
      ic_input_int<= update_out;
    elsif (mode2_int = 'X') then
      if (pin_input_int /= update_out) then
        ic_input_int <= 'X';
      else
        ic_input_int <= pin_input_int;
      end if;
    end if;
    wait until (mode2_int'EVENT or pin_input_int'EVENT or update_out'EVENT);
end process combo2_proc;
-- pragma translate_on
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_bc_7_cfg_sim of DW_bc_7 is
 for sim
 end for; -- sim
end DW_bc_7_cfg_sim;
-- pragma translate_on

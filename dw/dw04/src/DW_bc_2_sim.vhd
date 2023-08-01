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
-- DesignWare_version: 0bc1dc30
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Boundary Scan Cell Type BC_2
--
--           
--
--              
--  Input Ports:   	Size    Description
--  =========== 	====    ===========
--  capture_clk     	1 bit   Clocks data into the capture stage
--  update_clk      	1 bit   Clocks data into the update stage 
--  capture_en      	1 bit   Enable for data clocked into the capture 
--  update_en       	1 bit   Enable for data clocked into the update stage 
--  shift_dr           	1 bit   Enables the boundary scan chain to shift data
--			        one stage toward its serial output (tdo) 
--  mode		1 bit  	Determines whether data_out is controlled by the
--				boundary scan cell or by the data_in signal
--  si	 		1 bit  	Serial path from the previous boundary scan cell
--  data_in		1 bit 	Input data
--
--  Output Ports    	Size    Description
--  ============	====    ===========
--  data_out        	1 bit   Output data
--  so              	1 bit   Serial path to the next boundary scan cell
--              
--
--
-- MODIFIED: 
--
---------------------------------------------------------------------------------
library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use DWARE.DWpackages.all;
architecture sim of DW_bc_2 is
	
  signal so_int, data_out_int : std_logic;
  signal update_out : std_logic;
  signal capture_en_int, shift_dr_int, capture_clk_int : std_logic;
  signal update_en_int, update_clk_int, mode_int : std_logic;
  signal data_in_int, si_int: std_logic;
begin
-- pragma translate_off
  capture_en_int <= To_01X(capture_en);
  shift_dr_int <= To_01X(shift_dr);
  capture_clk_int <= To_01X(capture_clk);
  update_en_int <= To_01X(update_en);
  update_clk_int <= To_01X(update_clk);
  mode_int <= To_01X(mode);
  data_in_int <= To_01X(data_in);
  si_int <= To_01X(si);
  so <= so_int;
  data_out <= data_out_int;
seq1_proc : process 
  begin
    if (capture_clk_int = '1' or (capture_clk_int = 'X' 
        and capture_clk_int'last_value = '0') ) then
      if (capture_en_int = '0') then 
        if (shift_dr_int = '0') then
          if (capture_clk_int'last_value = 'X' or (capture_clk_int = 'X' 
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
        elsif (si_int /= data_out_int) then
          so_int <= 'X';
        elsif (capture_clk_int'last_value = 'X' or (capture_clk_int = 'X' 
	       and capture_clk_int'last_value = '0')) then
          if (si_int /= so_int) then
            so_int <= 'X';
          end if;
        else 
          so_int <= si_int;
        end if;
      elsif (capture_en_int = 'X') then
        if (shift_dr_int = '0') then
          if (data_out_int /= so_int) then
            so_int <= 'X';
          end if;
        elsif (shift_dr_int = '1') then
          if (si_int /= so_int) then
            so_int <= 'X';
          end if;
        elsif (si_int = data_out_int) then
          if (si_int /= so_int) then
            so_int <= 'X';
          end if;
        else 
          so_int <= 'X';
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
    if (mode_int = '0') then
      data_out_int <= data_in_int;
    elsif (mode_int = '1') then
      data_out_int <= update_out;
    elsif (mode_int = 'X') then
      if (data_in_int /= update_out) then
      data_out_int <= 'X';
      else 
      data_out_int <= data_in_int;  	
      end if;		            
    end if;  	
    wait until (mode_int'EVENT or data_in_int'EVENT or update_out'EVENT);
end process combo1_proc;
-- pragma translate_on
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_bc_2_cfg_sim of DW_bc_2 is
 for sim
 end for; -- sim
end DW_bc_2_cfg_sim;
-- pragma translate_on

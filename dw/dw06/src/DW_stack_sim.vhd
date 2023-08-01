--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 1997 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    ST                 Oct., 1997
--
-- VERSION:   Entity  
--
-- DesignWare_version: 37c4b0c1
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Stack
--           This LIFO's operation is based on Synchronous single-port ram
--   
--           width : legal range is 1 to 256
--           depth : legal range is 2 to 256
--           err_mode : legal range is 0 to 1
--           rst_mode : legal range is 0 to 3
--   
--           Input data : data_in[width-1:0]
--           Output data: data_out[width-1:0]
--   
--           push request(active low): push_req_n
--           pop request(active low) : pop_req_n
--           reset (active low): rst_n
--           flags (active high) : full,empty,error
--   
--   
-- MODIFIED:
--   
---------------------------------------------------------------------------------
library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_misc.all;
use DWARE.DWpackages.all;
architecture sim of DW_stack is
	
 begin
-- pragma translate_off
  
 SIM_MODEL: process
    subtype mem_row is std_logic_vector(width-1 downto 0);
    type mem_array is array(depth-1 downto 0) of mem_row;
    variable mem : mem_array;
    variable wd_count: integer range -1 to depth;
    variable ctrA : integer;
  begin
      if ( rst_mode = 1 or rst_mode = 3) then
         wait until (clk'event and (clk'last_value = '0') and (clk = '1'));
         if( err_mode = 1) then
             error <= '0';
         end if;
      end if;
      if  (To_01X(rst_n) = '0' ) then
         error <= '0';
         empty <= '1';
         full <= '0';
         wd_count := 0;
         if( rst_mode = 0 or rst_mode = 1) then
            for ctrA in 0 to depth-1 loop
               mem(ctrA) := (others => '0');
            end loop;
         end if;
         data_out <= mem(wd_count);
           while (To_01X(rst_n) = '0') loop
                 wait until ((To_01X(rst_n) /= '0') or (clk'event and (clk'last_value = '0') and (clk = '1')) );
                 if(clk'event and (clk'last_value = '0') and (clk = '1')) then
                    if(push_req_n = '0') then
                     if( rst_mode = 2 or rst_mode = 3) then
                       mem(wd_count) := data_in;
                       data_out <= mem(wd_count);
                     end if;
                    end if;
                 end if;
           end loop;
      elsif  (To_01X(rst_n) = 'X' ) then
         error <= 'X';
         empty <= 'X';
         full <= 'X';
         wd_count := -1;
         if( rst_mode = 0 or rst_mode = 1) then
            for ctrA in 0 to depth-1 loop
               mem(ctrA) := (others => 'X');
            end loop;
         end if;
         data_out <= (others => 'X');
           while (To_01X(rst_n) = 'X') loop
                 wait until ((To_01X(rst_n) /= 'X'));
           end loop;
      else
         if (rst_mode = 0 or rst_mode = 2) then
             wait until ( (clk'event and (clk'last_value = '0') and (clk = '1')) or (To_01X(rst_n) /= '1') );
             if( err_mode = 1) then
                 error <= '0';
             end if;
         end if;
         if (To_01X(rst_n) = '1') then
         if( To_01X(push_req_n) = '0' ) then 
              if(wd_count = depth) then
                  error <= '1';
              else
                  mem(wd_count) := data_in;
                  data_out <= mem(wd_count);
                  wd_count := wd_count + 1;
              end if;
         elsif (( To_01X(push_req_n) = 'X') and (wd_count /= depth)) then
              data_out <= (others => 'X');
         end if;
         if( (To_01X(push_req_n) = '1') and (To_01X(pop_req_n) = '0') ) then
             if(wd_count = 0) then
                 error <= '1';
             else
                 wd_count := wd_count - 1;
                 if( wd_count /= 0 ) then
                   data_out <= mem(wd_count - 1);
                 else
                   data_out <= mem(wd_count);
                 end if;
             end if;
         elsif (( To_01X(pop_req_n) = 'X') and ( To_01X(push_req_n) = '1') and (wd_count /= 0)) then
             data_out <= (others => 'X');
         end if;
      end if;
      if (wd_count = 0) then
          empty <= '1';
      elsif (wd_count = -1) then
          empty <= 'X';
      else
          empty <= '0';
      end if;
      if (wd_count = depth) then
          full <= '1';
      elsif (wd_count = -1) then
          full <= 'X';
      else
          full <= '0';
      end if;
      end if;
 end process;
-- pragma translate_on
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_stack_cfg_sim of DW_stack is
 for sim
 end for; -- sim
end DW_stack_cfg_sim;
-- pragma translate_on

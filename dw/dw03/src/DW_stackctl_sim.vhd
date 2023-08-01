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
-- DesignWare_version: 00f0100e
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Stack Controller
--           This LIFO's operation is based on Synchronous single-port ram
--   
--           depth : legal range is 2 to 256
--           err_mode : legal range is 0 to 2
--           rst_mode : legal range is 0 to 3
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
use DWARE.DWpackages.all;
architecture sim of DW_stackctl is
	
  constant addr_width : INTEGER := bit_width(depth);
  signal full_int: std_logic;
 begin
-- pragma translate_off
   full <= full_int;
   we_n <= push_req_n OR (full_int);
  
 SIM_MODEL: process
    variable wd_count: integer range -1 to depth;
    variable rd_x, wr_x: integer;
  begin
      if ( rst_mode = 1 ) then
         wait until (clk'event and (clk'last_value = '0') and (clk = '1'));
         if( err_mode = 1) then
             error <= '0';
         end if;
      end if;
      if  (To_01X(rst_n) = '0' ) then
         error <= '0';
         empty <= '1';
         full_int <= '0';
         wd_count := 0;
         wr_x := 0;
         rd_x := 0;
         rd_addr <= (others => '0');
         wr_addr <= (others => '0');
         wait until (To_01X(rst_n) /= '0');
      elsif (To_01X(rst_n) = 'X' ) then
         error <= 'X';
         empty <= 'X';
         full_int <= 'X';
         wd_count := -1;
         wr_x := -1;
         rd_x := -1;
         rd_addr <= (others => 'X');
         wr_addr <= (others => 'X');
         if ( rst_mode = 0 ) then
            wait until (To_01X(rst_n) /= 'X');
         end if;
      else
         if (rst_mode = 0) then
             wait until  ( (clk'event and (clk'last_value = '0') and (clk = '1')) or (To_01X(rst_n) /= '1') );
             if( err_mode = 1) then
                 error <= '0';
             end if;
         end if;
         if (To_01X(rst_n) = '1') then
         if ( To_01X(push_req_n) = '0') then
              if (wd_count = depth) then
                  error <= '1';
              else
                  wd_count := wd_count + 1;
              end if;
              wr_x := 0;
         elsif (( To_01X(push_req_n) = 'X') and (wd_count /= depth)) then
              wr_x := 1;
         end if;
         if( ( To_01X(push_req_n) = '1') and ( To_01X(pop_req_n) = '0') ) then
             if(wd_count = 0)then
                 error <= '1';
             else
                 wd_count := wd_count - 1;
             end if;
              rd_x := 0;
         elsif (( To_01X(pop_req_n) = 'X') and ( To_01X(push_req_n) = '1') and (wd_count /= 0)) then
              rd_x := 1;
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
          full_int <= '1';
      elsif (wd_count = -1) then
          full_int <= 'X';
      else
          full_int <= '0';
      end if;
      if(rd_x = 0) then
        rd_addr <= dw_conv_std_logic_vector(maximum((wd_count-1),0), addr_width );
      else
        rd_addr <= (others => 'X');
      end if;
      if(wr_x = 0) then
        wr_addr <= dw_conv_std_logic_vector(minimum(wd_count,(depth-1)), addr_width );
      else
        wr_addr <= (others => 'X');
      end if;
      end if;
 end process;
-- pragma translate_on
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_stackctl_cfg_sim of DW_stackctl is
 for sim
 end for; -- sim
end DW_stackctl_cfg_sim;
-- pragma translate_on

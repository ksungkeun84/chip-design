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
-- AUTHOR:    Sourabh Tandon         Jan.,'98
--
-- VERSION:   Simulation Model
--
-- DesignWare_version: f64d7ed2
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Asymmetric, Synchronous with Dynamic Flags
--           (FIFO) with dynamic programmable almost empty and almost
--           full flags.
--
--           This FIFO controller designed to interface to synchronous
--           true dual port RAMs.
--
--              Parameters:     Valid Values
--              ==========      ============
--              data_in_width   [ 1 to 256]
--              data_out_width  [ 1 to 256]
--                  Note: data_in_width and data_out_width must be
--                        in integer multiple relationship: either
--                              data_in_width = K * data_out_width
--                        or    data_out_width = K * data_in_width
--              depth           [ 2 to 16777216 ]
--              err_mode        [ 0 = dynamic error flag,
--                                1 = sticky error flag ]
--              rst_mode        [ 0 = asynchronous reset,
--                                1 = synchronous reset ]
--              byte_order      [ 0 = the first byte is in MSBs
--                                1 = the first byte is in LSBs ]
--        
--              Input Ports:    Size    Description
--              ===========     ====    ===========
--              clk             1 bit   Input Clock
--              rst_n           1 bit   Active Low Reset
--              push_req_n      1 bit   Active Low Push Request
--              flush_n         1 bit   Flush the partial word into
--                                      the full word memory.  For
--                                      data_in_width<data_out_width
--                                      only
--              pop_req_n       1 bit   Active Low Pop Request
--              diag_n          1 bit   Active Low diagnostic input
--              data_in         L bits  FIFO data to push
--              rd_data         M bits  RAM data input to asymmetric
--                                      FIFO controller
--              ae_level        N bits  Almost Empty level
--              af_thresh       N bits  Almost Full threshold
--
--              Output Ports    Size    Description
--              ============    ====    ===========
--              we_n            1 bit   Active low Write Enable (to RAM)
--              empty           1 bit   Empty Flag
--              almost_empty    1 bit   Almost Empty Flag
--              half_full       1 bit   Half Full Flag
--              almost_full     1 bit   Almost Full Flag
--              full            1 bit   Full Flag
--              ram_full        1 bit   Full Flag for RAM
--              error           1 bit   Error Flag
--              part_wd         1 bit   Partial word read flag.  For
--                                      data_in_width<data_out_width
--                                      only
--              wr_data         M bits  FIFO controller output data
--                                      to RAM
--              wr_addr         N bits  Write Address (to RAM)
--              rd_addr         N bits  Read Address (to RAM)
--              data_out        O bits  FIFO data to pop
--
--                Note: the value of L is parameter data_in_width
--                Note: the value of M is
--                         maximum(data_in_width, data_out_width)
--                Note: the value of N for wr_addr and rd_addr is
--                      determined from the parameter, depth.  The
--                      value of N is equal to:
--                              ceil( log2( depth ) )
--                Note: the value of O is parameter data_out_width
--
--
-- MODIFIED:
--	10/06/98 Jay Zhu: STAR 59594
--------------------------------------------------------------------------------
--
--
library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use DWARE.DWpackages.all;
architecture sim of DW_asymfifoctl_s1_df is
	
constant addr_width : INTEGER := bit_width(depth);
constant max_width : INTEGER := maximum(data_in_width,data_out_width);
signal in_width : INTEGER := data_in_width;
signal out_width : INTEGER := data_out_width;
function in_out_ratio(par1, par2: integer) return INTEGER is
  begin
    if(par1 > par2) then
      return (par1/par2);
    else
      return (par2/par1);
    end if;
  end in_out_ratio;
constant K : INTEGER := in_out_ratio(data_in_width, data_out_width);
function data_output (K, in_width, out_width, rd_addr_buf_new : integer; rd_data : std_logic_vector (max_width-1 downto 0)) return std_logic_vector is
   begin
     if( in_width <= out_width ) then
       return rd_data;
     else
       if(byte_order = 1) then
         return rd_data((((rd_addr_buf_new+1)*out_width)-1) downto rd_addr_buf_new*out_width);
       else
         return rd_data((((K-rd_addr_buf_new)*out_width)-1) downto (K-1-rd_addr_buf_new)*out_width);
       end if;
     end if;
end data_output;
signal part_wd_int : std_logic;
signal we_n_int : std_logic;
signal full_int_new : std_logic := '1';
signal empty_int_new : std_logic := '1';
signal ram_full_int_new : std_logic;
signal rd_addr_buf_last : std_logic := '0';
signal wr_addr_buf_last : std_logic := '1';
signal wr_data_int : std_logic_vector(maximum(data_in_width,data_out_width)-1 downto 0);
signal rd_addr_buf_new : integer := 0;
signal wr_addr_buf_new : integer := 0;
signal rst_n_int : std_logic;
signal push_req_n_int : std_logic;
signal pop_req_n_int : std_logic;
signal flush_n_int : std_logic;
signal diag_n_int : std_logic;
    begin
-- pragma translate_off
    rst_n_int <= To_01X(rst_n);
    push_req_n_int <= To_01X(push_req_n);
    pop_req_n_int <= To_01X(pop_req_n);
    flush_n_int <= To_01X(flush_n);
    diag_n_int <= To_01X(diag_n);
    part_wd <= part_wd_int;
    we_n <= we_n_int;
write_enbl : process (push_req_n_int, wr_addr_buf_last, pop_req_n_int, rd_addr_buf_last, full_int_new, flush_n_int, part_wd_int)
     begin
     if(data_in_width > data_out_width) then
       we_n_int <= (((rd_addr_buf_last or empty_int_new or pop_req_n_int) and full_int_new) or push_req_n_int);
     elsif(data_in_width = data_out_width) then
       we_n_int <= (((empty_int_new or pop_req_n_int) and full_int_new) or push_req_n_int);
     else 
       if(flush_n_int /= '0') then
          we_n_int <= ((push_req_n_int or wr_addr_buf_last) OR ((pop_req_n_int or rd_addr_buf_last) AND full_int_new ));
       else
          if( part_wd_int = '0' ) then
             we_n_int <= ((push_req_n_int or wr_addr_buf_last) OR ((pop_req_n_int or rd_addr_buf_last) AND full_int_new ));
          else
             we_n_int <= ((push_req_n_int or wr_addr_buf_last) OR ((pop_req_n_int or rd_addr_buf_last) AND full_int_new )) and (flush_n_int or (ram_full_int_new and pop_req_n_int));
          end if;
       end if;
     end if;
end process;
    
    data_out <= data_output(K, data_in_width, data_out_width, rd_addr_buf_new, rd_data);
write_data : process (push_req_n_int, wr_data_int, data_in, clk, part_wd_int)
   variable return_int : std_logic_vector(data_out_width - 1 downto 0);
   begin
     if(data_in_width >= data_out_width) then
       wr_data <=  data_in;
     else
       if (flush_n_int = '0' and clk'event and clk = '1') then
          wr_data <=  wr_data_int;
       else
        if(full_int_new = '1' and pop_req_n_int /= '0') then
          wr_data <=  wr_data_int;
        else
          if(wr_addr_buf_new < (K-1)) then
             wr_data <=  wr_data_int;
          else
             if(byte_order = 0) then
                 return_int((data_out_width - 1) downto data_in_width) :=  wr_data_int(data_out_width-1 downto data_in_width);
                 if((((pop_req_n_int and ram_full_int_new) or (not(part_wd_int)) or flush_n_int) and (not(wr_addr_buf_last) and not(push_req_n_int))) = '1') then
                    return_int((data_in_width -1) downto 0) :=  data_in;
                 else
                    return_int((data_in_width - 1) downto 0) :=  (others => '0');
                 end if;
             else
                 return_int((data_out_width- data_in_width - 1) downto 0) :=  wr_data_int((K-1)*data_in_width-1 downto 0);
                 if((((pop_req_n_int and ram_full_int_new) or (not(part_wd_int)) or flush_n_int) and (not(wr_addr_buf_last) and not(push_req_n_int))) = '1') then
                    return_int((data_out_width - 1) downto  (data_out_width- data_in_width )) :=  data_in;
                 else
                    return_int((data_out_width - 1) downto  (data_out_width- data_in_width )) :=  (others => '0');
                 end if;
             end if;
             wr_data <=  return_int;
          end if;
        end if;
       end if;
     end if;
end process;
    sim_mdl : process 
        variable wrd_count, wr_addr_int, rd_addr_int : integer range -1 to depth;
        variable wr_addr_buf, rd_addr_buf : integer range -1 to K := 0;
        variable wrd_count_inc, wrd_count_dec: std_logic;
        variable ram_full_int : std_logic;
        variable error_int : std_logic;
        begin
        if ( err_mode > 1 ) then
            error_int := '0';
        end if;
        if ( rst_mode = 1 ) then
            wait until (clk'event and (clk'last_value = '0') and (clk = '1'));
        end if;
        if  (rst_n_int = '0') then
            wrd_count := 0;
            rd_addr_buf := 0;
            wr_addr_int := 0;
            rd_addr_int := 0;
            error_int := '0';
            error <= '0';
            empty <= '1';
            almost_empty <= '1';
            ram_full <= '0';
            ram_full_int := '0';
            ram_full_int_new <= '0';
            half_full <= '0';
            almost_full <= '0';
            full <= '0';
            full_int_new <= '0';
            part_wd_int <= '0';
            wr_addr <= (others => '0');
            rd_addr <= (others => '0');
            if(data_in_width < data_out_width) then
               wr_data_int <= (others => '0');
               wr_addr_buf := 0;
               wr_addr_buf_last <= '1';
            end if;
            wait until (rst_n_int /= '0');
        elsif  (rst_n_int = 'X') then
            wrd_count := -1;
            rd_addr_buf := -1;
            wr_addr_int := -1;
            rd_addr_int := -1;
            error_int := 'X';
            error <= 'X';
            empty <= 'X';
            almost_empty <= 'X';
            ram_full <= 'X';
            ram_full_int := 'X';
            ram_full_int_new <= 'X';
            half_full <= 'X';
            almost_full <= 'X';
            full <= 'X';
            full_int_new <= 'X';
            part_wd_int <= 'X';
            wr_addr <= (others => 'X');
            rd_addr <= (others => 'X');
            if(data_in_width < data_out_width) then
               wr_data_int <= (others => 'X');
               wr_addr_buf := -1;
               wr_addr_buf_last <= 'X';
            end if;
            wait until (rst_n_int /= 'X');
        else
            if (rst_mode = 0) then
             wait until  ( (clk'event and (clk'last_value = '0') and (clk = '1')) or (rst_n_int /= '1') );
            end if;
          if  (rst_n_int = '1' ) then
            if ( err_mode = 0 ) then
                if ( (wrd_count = 0) or (wrd_count = depth) ) then
                    if ( rd_addr_int /= wr_addr_int ) then
                        error_int := '1';
                    end if;
                  elsif ( rd_addr_int = wr_addr_int ) then
                    error_int := '1';
                end if;
            end if;
-- diagnostic mode
            if ( diag_n_int = '0' and err_mode = 0) then
               rd_addr_int := 0;
            end if;
-- Push and Pop
            if ( pop_req_n_int = '0' and push_req_n_int = '0' ) then
                if (( wrd_count = depth and rd_addr_buf /= (K-1) and data_in_width > data_out_width) or ( wrd_count = 0 and data_in_width < data_out_width)) then 
                    error_int := '1';
                end if;
            end if;
-- Pop
            if ( pop_req_n_int = '0') then
                if ( wrd_count = 0 ) then
                    error_int := '1';
                  else
                    if(flush_n_int = '0' and part_wd_int = '1') then
                       wrd_count_inc := '1';
                       wr_addr_int := (wr_addr_int + 1) mod depth;
                       wr_addr_buf := 0;
                       if( byte_order = 0 ) then
                          wr_data_int((data_out_width-data_in_width-1) downto 0) <= (others => '0');
                       else
                          wr_data_int((data_out_width-1) downto (data_in_width)) <= (others => '0');
                       end if;
                       part_wd_int <= '0';
                    end if;
                    if( data_in_width <= data_out_width ) then
                       wrd_count_dec := '1';
                       rd_addr_int := (rd_addr_int + 1) mod depth;
                    else
                       rd_addr_buf := (rd_addr_buf + 1);
                       if(not( rd_addr_buf < K) ) then
                          wrd_count_dec := '1';
                          rd_addr_int := (rd_addr_int + 1) mod depth;
                          rd_addr_buf := 0;
                       end if;
                    end if;
                end if;
            end if;
-- Flush only
            if ( flush_n_int = '0' and push_req_n_int /= '0' and pop_req_n_int /= '0' and (data_in_width < data_out_width) and part_wd_int /= '0') then
               if ( ram_full_int = '1') then
                 error_int := '1';
               else
                 wrd_count_inc := '1';
                 wr_addr_int := (wr_addr_int + 1) mod depth;
                 wr_addr_buf := 0;
                 if( byte_order = 0 ) then
                                wr_data_int((data_out_width-data_in_width-1) downto 0) <= (others => '0');
                 else
                                wr_data_int((data_out_width-1) downto (data_in_width)) <= (others => '0');
                 end if;
                 part_wd_int <= '0';
               end if;
            end if;
-- Push
            if ( push_req_n_int = '0' ) then
                  if ( wrd_count = depth and not((pop_req_n_int = '0') and (rd_addr_buf = 0)) and not(data_in_width < data_out_width and wr_addr_buf < (K-1))) then
                    error_int := '1';
                  else
                    if( data_in_width >= data_out_width ) then
                       wrd_count_inc := '1';
                       wr_addr_int := (wr_addr_int +1) mod depth;
                    else
                       if( flush_n_int = '0' and ram_full_int = '1' and pop_req_n_int /= '0' and part_wd_int = '1') then
                           error_int := '1';
                       end if;
                       if( flush_n_int = '0' and ram_full_int /= '1' ) then
                           if( part_wd_int = '0') then
                                wr_addr_buf := (wr_addR_buf + 1) mod K; 
                                part_wd_int <= '1';
                             if(byte_order = 0) then
                                wr_data_int((out_width-in_width-1) downto 0) <= (others => '0');
                                wr_data_int((out_width-1) downto (out_width-in_width)) <= data_in;
                             else
                                wr_data_int((out_width-1) downto (in_width)) <= (others => '0');
                                wr_data_int((in_width-1) downto 0) <= data_in;
                             end if;
                           else
                             if(not((pop_req_n_int = '0')and(wrd_count /= 0)and(flush_n_int = '0')and(part_wd_int = '1'))) then
                                wrd_count_inc := '1';
                                wr_addr_int := (wr_addr_int + 1) mod depth;
                             end if;
                                part_wd_int <= '1';
                             if(byte_order = 0) then
                                wr_data_int((out_width-in_width-1) downto 0) <= (others => '0');
                                wr_data_int((out_width-1) downto (out_width-in_width)) <= data_in;
                             else
                                wr_data_int((out_width-1) downto (in_width)) <= (others => '0');
                                wr_data_int((in_width-1) downto 0) <= data_in;
                             end if;
                                wr_addr_buf := 1;
                           end if;
                       else
                          if( wr_addr_buf < (K-1)) then
                             if(byte_order = 0) then
                                wr_data_int((((K-wr_addr_buf)*in_width)-1) downto (K-1-wr_addr_buf)*in_width) <= data_in;
                             else
                                wr_data_int((((wr_addr_buf+1)*in_width)-1) downto (wr_addr_buf*in_width)) <= data_in;
                             end if;
                             wr_addr_buf := (wr_addR_buf + 1) mod K; 
                             part_wd_int <= '1';
                          else
                             if(byte_order = 0) then
                                wr_data_int <= (others => '0');
                             else
                                wr_data_int <= (others => '0');
                             end if;
                                wrd_count_inc := '1';
                             wr_addr_int := (wr_addr_int + 1) mod depth;
                             wr_addr_buf := 0;
                             part_wd_int <= '0';
                          end if;
                       end if;
                          
                    end if;
                end if;
            end if;
if(not(wrd_count_inc = '1' and wrd_count_dec = '1')) then
  if( wrd_count_inc = '1') then
      wrd_count := wrd_count + 1;
      wrd_count_inc := '0';
  end if;
  if( wrd_count_dec = '1') then
      wrd_count := wrd_count - 1;
      wrd_count_dec := '0';
  end if;
else
  wrd_count_dec := '0';
  wrd_count_inc := '0';
end if;
        if ( wrd_count = 0 ) then
            empty <= '1';
            empty_int_new <= '1';
          else
            empty <= '0';
            empty_int_new <= '0';
        end if;
        if ( wrd_count > conv_integer(unsigned(ae_level)) ) then
            almost_empty <= '0';
          else
            almost_empty <= '1';
        end if;
        if ( wrd_count < (depth +1)/2 ) then
            half_full <= '0';
          else
            half_full <= '1';
        end if;
        if ( wrd_count < conv_integer(unsigned(af_thresh)) ) then
            almost_full <= '0';
          else
            almost_full <= '1';
        end if;
        if ( wrd_count = depth ) then
            ram_full_int_new <= '1';
            ram_full_int := '1';
            ram_full <= '1';
          else
            ram_full_int_new <= '0';
            ram_full_int := '0';
            ram_full <= '0';
        end if;
        if( data_in_width >= data_out_width ) then
          if ( wrd_count = depth ) then
              full <= '1';
              full_int_new <= '1';
            else
              full <= '0';
              full_int_new <= '0';
          end if;
        else
          if ( wrd_count = depth and wr_addr_buf = (K-1)) then
              full <= '1';
              full_int_new <= '1';
            else
              full <= '0';
              full_int_new <= '0';
          end if;
        end if;
        if ( (err_mode = 0) and (diag_n_int = '0') ) then
            rd_addr_int := 0;
        end if;
        error <= error_int;
        rd_addr <= dw_conv_std_logic_vector( rd_addr_int, addr_width );
        wr_addr <= dw_conv_std_logic_vector( wr_addr_int, addr_width );
        rd_addr_buf_new <= rd_addr_buf;
        wr_addr_buf_new <= wr_addr_buf;
if(data_in_width > data_out_width) then
   if (rd_addr_buf = (K-1)) then
        rd_addr_buf_last <= '0';
   else
        rd_addr_buf_last <= '1';
   end if;
end if;
if(data_in_width < data_out_width) then
   if(wr_addr_buf = (K-1)) then
       wr_addr_buf_last <= '0';
   else
       wr_addr_buf_last <= '1';
   end if;
end if;
        if ( rst_mode /= 1 ) then
            wait until ( (clk = '0') or (rst_n_int = '0') );
        end if;
          end if;
        end if;
    end process;
-- pragma translate_on
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_asymfifoctl_s1_df_cfg_sim of DW_asymfifoctl_s1_df is
 for sim
 end for; -- sim
end DW_asymfifoctl_s1_df_cfg_sim;
-- pragma translate_on

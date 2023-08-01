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
-- AUTHOR:    SS			Mar. 4, 1997
--
-- VERSION:   simulation architecture
--
-- DesignWare_version: 2659ccca
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Synch Write, Asynch Dual Read RAM (Latch-Based) 
--            (latch based memory array)
--
--              Parameters:     Valid Values
--              ===========     ============
--              data_width      [ 1 to 256 ]
--              depth           [ 2 to 256 ]
--
--              Input Ports:    Description
--              ============    ===========
--              clk             Clock Signal
--              cs_n            Chip Select (active low)
--              wr_n            Write Enable (active low)
--              rd1_addr        Read1 Address Bus [ceil( log2(depth) )]
--              rd2_addr        Read2 Address Bus [ceil( log2(depth) )]
--              wr_addr         Write Address Bus [ceil( log2(depth) )]
--              data_in         Input data [data_width-1:0]
--
--              Output Ports:   Description
--              =============   ===========
--              data_rd1_out    Output data from read1 [data_width-1:0]
--              data_rd2_out    Output data from read2 [data_width-1:0]
--
--      NOTE: This RAM is intended to be used as a scratchpad memory only.
--              For best results keep "depth" and "data_width" less than 65
--              (ie. less than 64 words in RAM) and the overall number of
--              bits less than 256.
--
--
-- MODIFIED:  
--          7/23/97	ss		Added bus_U01X function to data_in. 
--
---------------------------------------------------------------------------------
library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use DWARE.DWpackages.all;
architecture sim of DW_ram_2r_w_s_lat is
	
  -- addr_with to log2(depth)
  constant addr_width : INTEGER := bit_width(depth);
 
begin
-- pragma translate_off
process(clk,cs_n,wr_n,data_in,rd1_addr,rd2_addr,wr_addr)
    subtype mem_row is std_logic_vector(data_width-1 downto 0);
    type mem_array is array(2**addr_width-1 downto 0) of mem_row;
    variable mem : mem_array;
    variable rd1_addr_int, rd2_addr_int, wr_addr_int : integer;
	-- constants used for warning messages
    constant write_enable : string := "WR_N";
    constant chip_select : string := "CS_N";
    constant reset : string := "RST_N";
begin
    rd1_addr_int := conv_integer_x(UNSIGNED(rd1_addr)); 
    rd2_addr_int := conv_integer_x(UNSIGNED(rd2_addr)); 
    wr_addr_int := conv_integer_x(UNSIGNED(wr_addr)); 
      
    if(cs_n='0') then
            
	-- write into RAM
	if (wr_n = '0') then
	    if (clk = '0') then
		if (wr_addr_int >= 0) then
		    mem(wr_addr_int) := bus_U01X(data_in,data_width);
		end if;
	    end if;
              
	elsif (wr_n = '1') then
	    -- do nothing;
              
	else
	    if (clk = '0') then
		if (wr_addr_int >= 0) then
		    mem(wr_addr_int) := (others => 'X');
		end if;
		invalid_input(write_enable);
	    end if;
	end if; 
            
	if (rd1_addr_int < 0) then
	    -- invalid values on address bus
	    data_rd1_out <= (others => 'X');
	elsif (rd1_addr_int >= depth) then
	    data_rd1_out <= (others => '0');
	else
	    data_rd1_out <= mem(rd1_addr_int);
	end if;
            
	if (rd2_addr_int < 0) then
	    -- invalid values on address bus
	    data_rd2_out <= (others => 'X');
	elsif (rd2_addr_int >= depth) then
	    data_rd2_out <= (others => '0');
	else
	    data_rd2_out <= mem(rd2_addr_int);
	end if;
            
    elsif (cs_n = '1') then
	if (rd1_addr_int < 0) then
	    data_rd1_out <= (others => 'X');
	elsif (rd1_addr_int >= depth) then
	    data_rd1_out <= (others => '0');
	else
	    data_rd1_out <= mem(rd1_addr_int); 
	end if;
	if (rd2_addr_int < 0) then
	    data_rd2_out <= (others => 'X');
	elsif (rd2_addr_int >= depth) then
	    data_rd2_out <= (others => '0');
	else
	    data_rd2_out <= mem(rd2_addr_int); 
	end if;
    else
	-- give warning
	invalid_input(chip_select); 
    end if; 
          
end process;        
-- pragma translate_on
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_ram_2r_w_s_lat_cfg_sim of DW_ram_2r_w_s_lat is
 for sim
 end for; -- sim
end DW_ram_2r_w_s_lat_cfg_sim;
-- pragma translate_on

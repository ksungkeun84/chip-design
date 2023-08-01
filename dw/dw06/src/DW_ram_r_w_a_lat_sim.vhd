--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 1996 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    SS			Feb. 25, 1997
--
-- VERSION:   architecture 'sim' of DW_ram_r_w_a_lat
--
-- DesignWare_version: 9220cfee
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Dual-Port RAM (Latch-Based)
--             (latch memory array)
--
--              Parameters:     Valid Values
--              ===========     ============
--              data_width      [ 1 to 256 ]
--              depth           [ 2 to 256 ]
--              rst_mode        [ 0 = asynchronous reset,
--                                1 = no reset ]
--
--              Input Ports:    Description
--              ============    ===========
--              rst_n           Reset (active low)
--              cs_n            Chip Select (active low)
--              wr_n            Write Enable (active low)
--              rd_addr         Read address Bus [ceil( log2(depth) )]
--              wr_addr         Write address Bus [ceil( log2(depth) )]
--              data_in         Input data [data_width-1:0]
--
--              Output Ports:   Description
--              =============   ===========
--              data_out        Output data [data_width-1:0]
--
--      NOTE: This RAM is intended to be used as a scratchpad memory only.
--              For best results keep "depth" and "data_width" less than 65
--              (ie. less than 64 words in RAM) and the overall number of
--              bits less than 256.
--
-- MODIFIED:
--				7/23/97	ss			Added bus_U01X function to data_in.
---------------------------------------------------------------------------------
library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use DWARE.DWpackages.all;
architecture sim of DW_ram_r_w_a_lat is
	
  -- addr_with to log2(depth)
  constant addr_width : INTEGER := bit_width(depth);
begin
-- pragma translate_off
  
    process(rst_n,cs_n,rd_addr,wr_addr,data_in,wr_n)
	type mem_array is array(2**addr_width-1 downto 0) of 
			std_logic_vector(data_width-1 downto 0);
	variable ram_data : mem_array;
	variable rd_addr_int : integer;
	variable wr_addr_int : integer;
	variable i 	  : integer;
	-- constants used for warning messages
    	constant write_enable 	: string := "WR_N";
    	constant chip_select 	: string := "CS_N";
    	constant reset 		: string := "RST_N";
    begin               
	rd_addr_int := conv_integer_x(unsigned(rd_addr));
	wr_addr_int := conv_integer_x(unsigned(wr_addr));
	-- asynchronous reset
	if (rst_mode = 0) then
	    if (rst_n = '0') then
		for i in 0 to 2**addr_width-1 loop
		    ram_data(i) := (others => '0');
		end loop;
		if (rd_addr_int < 0) then
		    -- invalid values on address bus
		    data_out <= (others => 'X');
		elsif (rd_addr_int >= depth) then
		    -- address behond scope of depth
		    data_out <= (others => '0');
		else
		    data_out <= ram_data(rd_addr_int);
		end if;
	    elsif (rst_n = '1') then
	    	if(cs_n='0') then
		    if(wr_n='0') then
			if (wr_addr_int >= 0) then
			    ram_data(wr_addr_int) := bus_U01X(data_in,data_width);
			end if;
		    elsif (wr_n='1') then
			-- do nothing
		    else
			if (wr_addr_int >= 0) then
			    ram_data(wr_addr_int) := (others => 'X');
			end if;
			invalid_input(write_enable);
		    end if;
		    if (rd_addr_int < 0) then
			-- invalid values on address bus
			data_out <= (others => 'X');
		    elsif (rd_addr_int >= depth) then
			data_out <= (others => '0');
		    else
			data_out <= ram_data(rd_addr_int);
		    end if;
		elsif (cs_n = '1') then
		    if (rd_addr_int < 0) then
			-- invalid values on address bus
			data_out <= (others => 'X');
		    elsif (rd_addr_int >= depth) then
			data_out <= (others => '0');
		    else
			data_out <= ram_data(rd_addr_int);
		    end if;
		else
		    -- give warning
		    invalid_input(chip_select);
		end if;
	    else
	    	-- give warning
	    	invalid_input(reset);
	    end if;
	-- no reset
	else -- rst_mode = 1
	    if(cs_n='0') then
	    	if(wr_n='0') then
		    if (wr_addr_int >= 0) then
		    	ram_data(wr_addr_int) := bus_U01X(data_in,data_width);
		    end if;
		elsif (wr_n='1') then
		    -- do nothing
		else
		    if (wr_addr_int >= 0) then
			ram_data(wr_addr_int) := (others => 'X');
		    end if;
		    invalid_input(write_enable);
		end if;
		if (rd_addr_int < 0) then
		    -- invalid values on address bus
		    data_out <= (others => 'X');
		elsif (rd_addr_int >= depth) then
		    data_out <= (others => '0');
		else
		    data_out <= ram_data(rd_addr_int);
		end if;
	    elsif (cs_n = '1') then
		if (rd_addr_int < 0) then
		    -- invalid values on address bus
		    data_out <= (others => 'X');
	    	elsif (rd_addr_int >= depth) then
		    data_out <= (others => '0');
	    	else
		    data_out <= ram_data(rd_addr_int);
	    	end if;
	    else
		-- give warning
		invalid_input(chip_select);
	    end if;
	end if;
    end process;
-- pragma translate_on
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_ram_r_w_a_lat_cfg_sim of DW_ram_r_w_a_lat is
 for sim
 end for; -- sim
end DW_ram_r_w_a_lat_cfg_sim;
-- pragma translate_on

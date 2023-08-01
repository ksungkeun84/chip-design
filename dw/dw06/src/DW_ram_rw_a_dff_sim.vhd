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
-- AUTHOR:    SS			Nov. 13, 1993
--
-- VERSION:   architecture 'sim' of DW_ram_a1_dff
--
-- DesignWare_version: 7f786b0d
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Single-Port RAM (Flip-Flop Based)
--
--            legal range:  depth       [ 2 to 256 ]
--            legal range:  data_width  [ 1 to 256 ]
--            addr_width equal ceiling log2(depth)
--            Input data: data_in[data_width-1:0]
--            Output data: data_out[data_width-1:0]
--            Address: rw_addr[addr_width-1:0]
--            write enable (active low): wr_n
--            chip select (active low): cs_n
--            reset (active low): rst_n
--            Testing signals : test_mode and test_clk
--            NOTE: This RAM is intended to be used as a scratchpad memory only.
--                  For best results keep "depth" and "data_width" less than 64
--                  (ie. less than 64 words in RAM) and the overall number of
--                  bits less than 256.
--
--           
--          
--
-- MODIFIED:
--	     7/23/97	ss		Added bus_U01X function to data_in.
--           04/14/98  RPH  Changed the comments depth and data_width
--                               generic parameter.
--	     10/08/99  tong Re-wrote for STAR 93158 
---------------------------------------------------------------------------------
library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use DWARE.DWpackages.all;
architecture sim of DW_ram_rw_a_dff is
	
	signal wr_n_int : std_logic;
begin
-- pragma translate_off

	wr_n_int <= wr_n OR cs_n;
  
	process(rst_n,cs_n,rw_addr,data_in,wr_n_int,test_mode,test_clk)
	type mem_array is array(depth-1 downto 0) of std_logic_vector(data_width-1 downto 0);
	variable ram_data : mem_array;
	variable addr_int : integer;
	variable i 	  : integer;
	-- constants used for warning messages
    	constant write_enable : string := "WR_N";
    	constant chip_select : string := "CS_N";
    	constant reset : string := "RST_N";
	begin

        addr_int := conv_integer_x(unsigned(rw_addr));

	if (test_mode = '0') then
          if(wr_n_int'event AND wr_n_int = '1' AND 
                 wr_n_int'last_value = '0') then 
            if (addr_int >= 0 AND addr_int <= depth-1) then
              ram_data(addr_int) := bus_U01X(data_in,data_width);
            end if;
          elsif (wr_n_int /= '1' AND wr_n_int /= '0') then
            if (cs_n /= '0' OR cs_n /= '1') then
              invalid_input(chip_select);
	    else
	      invalid_input(write_enable);
	    end if;
	    if (addr_int >= 0 AND addr_int <= depth-1) then 
	      ram_data(addr_int) := (others => 'X');
	    end if;
	  end if;
	end if;

	if (test_mode = '1') then 
	  if(test_clk'event AND test_clk = '1') then 
	    for I in 0 to depth-1 loop
	      ram_data(i) := bus_U01X(data_in,data_width);
	    end loop;
	  elsif (test_clk /= '0' And test_clk /= '1') then
	    for i in 0 to depth-1 loop
	      ram_data(i) := (others => 'X');
	    end loop;
	  end if;
	end if;

	if (rst_mode = 0) then
          if (rst_n = '0') then
	    for i in 0 to depth-1 loop
	      ram_data(i) := (others => '0');
	    end loop;
	  elsif (rst_n /= '1') then
	    for i in 0 to depth-1 loop
	      ram_data(i) := (others => 'X');
	    end loop;
	    invalid_input(reset);
	  end if;
	end if;

	if (addr_int < 0) then
	  data_out <= (others => 'X');
	elsif (addr_int >= depth) then
	  data_out <= (others => '0');
	else
          if (cs_n = '0') then
	    data_out <= ram_data(addr_int);
          else
	    data_out <= (others => '0');
	  end if;
	end if;

	end process;
-- pragma translate_on
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_ram_rw_a_dff_cfg_sim of DW_ram_rw_a_dff is
 for sim
 end for; -- sim
end DW_ram_rw_a_dff_cfg_sim;
-- pragma translate_on

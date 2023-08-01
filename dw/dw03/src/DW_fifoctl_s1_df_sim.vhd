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
-- AUTHOR:    Rick Kelly         1/23/97
--
-- VERSION:   VHDL Simulation Model
--
-- DesignWare_version: 1a682fc5
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Synchronous with Dynamic Flags
--           dynamic programmable almost empty and almost full flags
--
--           This FIFO controller designed to interface to synchronous
--           true dual port RAMs.
--
--              Parameters:     Valid Values
--              ==========      ============
--              depth           [ 2 to 16777216 ]
--              err_mode        [ 0 = sticky error flag w/ ptr check,
--                                1 = sticky error flag (no ptr chk),
--                                2 = dynamic error flag ]
--              rst_mode        [ 0 = asynchronous reset,
--                                1 = synchronous reset ]
--              
--              Input Ports:    Size    Description
--              ===========     ====    ===========
--              clk             1 bit   Input Clock
--              rst_n           1 bit   Active Low Reset
--              push_req_n      1 bit   Active Low Push Request
--              pop_req_n       1 bit   Active Low Pop Request
--              diag_n          1 bit   Active Low diagnostic control
--              ae_level        N bits  Almost Empty level
--              af_thresh       N bits  Almost Full Threshold
--
--              Output Ports    Size    Description
--              ============    ====    ===========
--              we_n            1 bit   Active low Write Enable (to RAM)
--              empty           1 bit   Empty Flag
--              almost_empty    1 bit   Almost Empty Flag
--              half_full       1 bit   Half Full Flag
--              almost_full     1 bit   Almost Full Flag
--              full            1 bit   Full Flag
--              error           1 bit   Error Flag
--              wr_addr         N bits  Write Address (to RAM)
--              rd_addr         N bits  Read Address (to RAM)
--
--                Note: the value of N for ae_level, af_thresh,
--                      wr_addr and rd_addr is determined from the
--                      parameter, depth.  The value of N is equal to:
--                              ceil( log2( depth ) )
--              
--
--
-- MODIFIED: 
--		RJK - 2/2/98
--		Added better processing of 'X' and 'U' inputs
--
---------------------------------------------------------------------------------
--
--
library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use DWARE.DWpackages.all;
architecture sim of DW_fifoctl_s1_df is
	
constant addr_width : INTEGER := bit_width(depth);
signal full_int : std_logic;
signal push_req_n_int : std_logic;
signal pop_req_n_int : std_logic;
signal rst_n_int : std_logic;
signal diag_n_int : std_logic;
signal clk_int : std_logic;
signal ae_level_padded : std_logic_vector(addr_width downto 0 );
signal ae_level_int : INTEGER;
signal af_thresh_padded : std_logic_vector(addr_width downto 0 );
signal af_thresh_int : INTEGER;
    begin
-- pragma translate_off
    rst_n_int <= To_01X( rst_n );
    push_req_n_int <= To_01X( push_req_n );
    pop_req_n_int <= To_01X( pop_req_n );
    diag_n_int <= To_01X( diag_n );
    clk_int <= To_01X( clk );
    ae_level_padded <= '0' & ae_level;
    ae_level_int <= CONV_INTEGER( ae_level_padded );
    af_thresh_padded <= '0' & af_thresh;
    af_thresh_int <= CONV_INTEGER( af_thresh_padded );
    full <= full_int;
    we_n <= push_req_n OR (pop_req_n AND full_int);
    sim_mdl : process 
	variable wrd_count, wr_addr_int, rd_addr_int : integer range -1 to depth;
	variable error_int : std_logic;
	begin
	if ( err_mode > 1 ) then
	    error_int := '0';
	end if;
	if ( rst_mode = 1 ) then
	    wait until (clk_int'event and (clk_int'last_value = '0') and (clk_int = '1'));
	end if;
	if  (rst_n_int = '0') then
	    wrd_count := 0;
	    wr_addr_int := 0;
	    rd_addr_int := 0;
	    error_int := '0';
	    error <= '0';
	    empty <= '1';
	    almost_empty <= '1';
	    half_full <= '0';
	    almost_full <= '0';
	    full_int <= '0';
	    wr_addr <= (others => '0');
	    rd_addr <= (others => '0');
	    wait until (rst_n_int /= '0');
	  elsif ( rst_n_int = 'X' ) then
	    wrd_count := -1;
	    wr_addr_int := -1;
	    rd_addr_int := -1;
	    error_int := 'X';
	    error <= 'X';
	    empty <= 'X';
	    almost_empty <= 'X';
	    half_full <= 'X';
	    almost_full <= 'X';
	    full_int <= 'X';
	    wr_addr <= (others => 'X');
	    rd_addr <= (others => 'X');
	    wait until (rst_n_int /= 'X');
	  else
	    if (rst_mode = 0) then
		wait until (clk_int'event and (clk_int'last_value = '0') and (clk_int = '1')) 
				    or (rst_n_int /= '1');
	    end if;
	    if (rst_n_int = '1') then
		if ( err_mode = 0 ) then
		    if ( (wrd_count = 0) or (wrd_count = depth) ) then
			if ( rd_addr_int /= wr_addr_int ) then
			    error_int := '1';
			end if;
		      elsif ( rd_addr_int = wr_addr_int ) then
			error_int := '1';
		    end if;
		end if;
		if ( pop_req_n_int = '0' ) and ( push_req_n_int = '0' ) then
		    if ( wrd_count < 0 ) then
			rd_addr_int := -1;
			wr_addr_int := -1;
			error_int := 'X';
		    else
			if ( wrd_count = 0 ) then
			    error_int := '1';
			    wrd_count := 1;
			  else
			    rd_addr_int := (rd_addr_int + 1) mod depth;
			end if;
			wr_addr_int := (wr_addr_int + 1) mod depth;
		    end if;
		end if;
		if ( pop_req_n_int = '0' ) and ( push_req_n_int = '1' ) then
		    if ( wrd_count < 0 ) then
			rd_addr_int := -1;
			error_int := 'X';
		     elsif ( wrd_count = 0 ) then
			error_int := '1';
		      else
			wrd_count := wrd_count - 1;
			rd_addr_int := (rd_addr_int + 1) mod depth;
		    end if;
		end if;
		if ( pop_req_n_int = '1' ) and ( push_req_n_int = '0' ) then
		    if ( wrd_count < 0 ) then
			wr_addr_int := -1;
			error_int := 'X';
		     elsif ( wrd_count = depth ) then
			error_int := '1';
		      else
			wrd_count := wrd_count + 1;
			wr_addr_int := (wr_addr_int +1) mod depth;
		    end if;
		end if;
		if ( pop_req_n_int = 'X' ) then
		    if ( wrd_count < 1 ) then
			error_int := 'X';
		    end if;
		    if ( wrd_count /= 0 ) then
			wrd_count := -1;
			rd_addr_int := -1;
		    end if;
		end if;
		if ( push_req_n_int = 'X' ) then
		    if (( wrd_count = depth ) and ( pop_req_n_int /= '0' )) or
						 ( wrd_count < 0 ) then
			error_int := 'X';
		    end if;
		    if ( wrd_count /= depth ) or ( pop_req_n_int /= '1' ) then
			wrd_count := -1;
			wr_addr_int := -1;
		    end if;
		end if;
	    end if;
	end if;
	if ( wrd_count = 0 ) then
	    empty <= '1';
	  elsif ( wrd_count < 0 ) then
	    empty <= 'X';
	  else
	    empty <= '0';
	end if;
	if ( any_unknown( ae_level ) = 1 ) or ( wrd_count < 0 ) then
	    almost_empty <= 'X';
	  else
	    if ( wrd_count > ae_level_int ) then
		almost_empty <= '0';
	      else
		almost_empty <= '1';
	    end if;
	end if;
	if ( wrd_count >= (depth +1)/2 ) then
	    half_full <= '1';
	  elsif ( wrd_count < 0 ) then
	    half_full <= 'X';
	  else
	    half_full <= '0';
	end if;
	if ( any_unknown( af_thresh ) = 1 ) or ( wrd_count < 0 ) then
	    almost_full <= 'X';
	  else
	    if ( wrd_count < af_thresh_int ) then
		almost_full <= '0';
	      else
		almost_full <= '1';
	    end if;
	end if;
	if ( wrd_count = depth ) then
	    full_int <= '1';
	  elsif ( wrd_count < 0 ) then
	    full_int <= 'X';
	  else
	    full_int <= '0';
	end if;
	if ( (err_mode = 0) and (diag_n_int /= '1') ) then
	    if ( diag_n_int = '0') then
		rd_addr_int := 0;
	    
	    else
		rd_addr_int := -1;
	    end if;
	end if;
	error <= error_int;
	if ( rd_addr_int < 0 ) then
	    rd_addr <= (others => 'X');
	else
	    rd_addr <= dw_conv_std_logic_vector( rd_addr_int, addr_width );
	end if;
	if ( wr_addr_int < 0 ) then
	    wr_addr <= (others => 'X');
	else
	    wr_addr <= dw_conv_std_logic_vector( wr_addr_int, addr_width );
	end if;
	if ( rst_mode = 1 ) then
	    wait until (clk_int = '0');
	  elsif ( rst_n_int = '1' ) then
	    wait until ( (clk_int = '0') or (rst_n_int /= '1') );
	end if;
    end process;
-- pragma translate_on
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_fifoctl_s1_df_cfg_sim of DW_fifoctl_s1_df is
 for sim
 end for; -- sim
end DW_fifoctl_s1_df_cfg_sim;
-- pragma translate_on

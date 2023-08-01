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
-- DesignWare_version: 62c44b2e
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Synch Write, Asynch Read RAM (Latch-Based)
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
--              rd_addr         Read Address Bus [ceil( log2(depth) )]
--              wr_addr         Write Address Bus [ceil( log2(depth) )]
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
--
-- MODIFIED:  
--          7/23/97	ss      Added bus_U01X function to data_in
--
--          2/07/07     DLL     Made X processing less pessimistic for data_in
--                              and used IEEE functions for X processing. (STAR#9000163706)
--
--
---------------------------------------------------------------------------------
library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use DWARE.DWpackages.all;
architecture sim of DW_ram_r_w_s_lat is
	
  -- addr_with to log2(depth)
  constant addr_width : INTEGER := bit_width(depth);
  subtype mem_row is std_logic_vector(data_width-1 downto 0);
  type mem_array is array(2**addr_width-1 downto 0) of mem_row;
  signal mem : mem_array;
 
begin
-- pragma translate_off

  
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
  
    if ( (data_width < 1) OR (data_width > 256) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter data_width (legal range: 1 to 256)"
        severity warning;
    end if;
  
    if ( (depth < 2) OR (depth > 256 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter depth (legal range: 2 to 256 )"
        severity warning;
    end if;
  
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;

write_PROC : process(clk,cs_n,wr_n,data_in,wr_addr)
    variable data_in_int : std_logic_vector(data_width-1 downto 0);
    variable wr_addr_int : integer;
	-- constants used for warning messages
    constant write_enable : string := "WR_N";
    constant chip_select : string := "CS_N";
begin
    wr_addr_int := CONV_INTEGER(UNSIGNED(wr_addr)); 
      
    if((cs_n OR wr_n OR clk) /= '1') then
      -- write into RAM
      -- first check to see if wr_addr is not X's and within range
      -- if wr_addr has an 'X', X all data locations
      if (Is_X(wr_addr)) then
        for wrd_idx in 0 to depth-1 loop
          mem(wrd_idx) <= (others => 'X');
        end loop;
      elsif ((wr_addr_int >= 0) AND (wr_addr_int < depth)) then
        if ((cs_n OR wr_n OR clk) = '0') then
          for bit_idx in 0 to data_width-1 loop
            data_in_int(bit_idx) := To_X01(data_in(bit_idx)); -- convert any X's
          end loop;
        else
          data_in_int := (others => 'X');
        end if;
	mem(wr_addr_int) <= data_in_int;
      end if;
    end if; 
          
end process;  -- of write_PROC      

read_PROC : process(mem,rd_addr)
  variable rd_addr_int  : integer;
begin
  rd_addr_int := CONV_INTEGER(UNSIGNED(rd_addr)); 

  if (Is_X(rd_addr)) then
    -- invalid values on address bus
    data_out <= (others => 'X');
  elsif (rd_addr_int >= depth) then
    data_out <= (others => '0');
  else
    data_out <= mem(rd_addr_int);
  end if;
end process; -- of read_PROC
-- pragma translate_on
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_ram_r_w_s_lat_cfg_sim of DW_ram_r_w_s_lat is
 for sim
 end for; -- sim
end DW_ram_r_w_s_lat_cfg_sim;
-- pragma translate_on

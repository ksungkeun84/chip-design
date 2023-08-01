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
-- AUTHOR:    Rick Kelly              June 18, 2001
--
-- VERSION:   simulation architecture
--
-- DesignWare_version: c47ac838
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Dual-Port RAM (Flip-Flop Based)
--            (flip flop memory array)
--            This RAM is operates fully synchronously  to clk.
--
--            legal range:  depth       [ 2 to 2048 ]
--            legal range:  data_width  [ 1 to 1024 ]
--            Input data: data_in[data_width-1:0]
--            Output data: data_out[data_width-1:0]
--            Read Address: rd_addr[addr_width-1:0]
--            Write Address: wr_addr[addr_width-1:0]
--            write enable (active low): wr_n
--            chip select (active low): cs_n
--            reset (active low): rst_n
--            clock : clk
--
-- MODIFIED:
--		7/22/97   ss	 Added U01X function to convert anything other
--				 than a 0, 1, or U on the data_in signal to a X.
--                04/14/98  RPH  Changed the comments depth and data_width
--                               generic parameter.
--              6/18/01   RJK    Rewritten for better X behavior (STAR 119685)
--           
--
---------------------------------------------------------------------------------
library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use DWARE.DWpackages.all;
architecture sim of DW_ram_r_w_s_dff is
	
  -- addr_with to log2(depth)
  constant addr_width : INTEGER := bit_width(depth);
  signal   a_rst_n : std_logic;
  signal   mem      : std_logic_vector(depth*data_width-1 downto 0);
 
begin
-- pragma translate_off

  
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
	    
  
    if ( (data_width < 1) OR (data_width > 2048) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter data_width (legal range: 1 to 2048)"
        severity warning;
    end if;
  
    if ( (depth < 2) OR (depth > 1024 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter depth (legal range: 2 to 1024 )"
        severity warning;
    end if;
  
    if ( (rst_mode < 0) OR (rst_mode > 1 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter rst_mode (legal range: 0 to 1 )"
        severity warning;
    end if;

  
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;

  a_rst_n <= rst_n WHEN (rst_mode = 0) else '1';
  
  data_out <= (others => 'X') WHEN (Is_X(cs_n) OR is_X(rd_addr)) else
		  (others => '0') WHEN (CONV_INTEGER(UNSIGNED(rd_addr)) >= depth) else
		    mem((CONV_INTEGER(UNSIGNED(rd_addr))+1)*data_width-1
				downto
			CONV_INTEGER(UNSIGNED(rd_addr))*data_width);
  
  
  registers_PROC : process( clk, a_rst_n )
    variable next_mem : std_logic_vector(depth*data_width-1 downto 0);
    variable array_indx : INTEGER;
  begin
    
    next_mem := mem;
    
    if ((cs_n OR wr_n) /= '1') then
      if (Is_X(wr_addr)) then
        next_mem := (others => 'X');
    
      else
	
	if (CONV_INTEGER(UNSIGNED(wr_addr)) < depth) then
	
	  for bit_id in 0 to data_width-1 loop
	  
	    array_indx := CONV_INTEGER(UNSIGNED(wr_addr))*data_width + bit_id;
	    
	    if (cs_n OR wr_n) = '0' then
	      next_mem(array_indx) := To_X01(data_in(bit_id));
	    
	    else
	      if (mem(array_indx) /= To_X01(data_in(bit_id))) then
	        next_mem(array_indx) := 'X';
	      end if;
	    end if;
	  
	  end loop;
	end if;
      end if;
    end if;
	 
    
    if (a_rst_n = '0') then
      mem <= (others => '0');
    
    elsif rising_edge(clk) then
    
      if (rst_n = '0') then
        mem <= (others => '0');
      
      else
        mem <= next_mem;
      end if;
    
    end if;
    
  end process registers_PROC;
  
  
  
  clk_monitor_PROC  : process (clk) begin

    assert NOT (Is_X( clk ) AND (now > 0 ns)) 
      report "WARNING: Detected unknown value on the clock input port clk."
      severity warning;

  end process clk_monitor_PROC ;

-- pragma translate_on
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_ram_r_w_s_dff_cfg_sim of DW_ram_r_w_s_dff is
 for sim
 end for; -- sim
end DW_ram_r_w_s_dff_cfg_sim;
-- pragma translate_on

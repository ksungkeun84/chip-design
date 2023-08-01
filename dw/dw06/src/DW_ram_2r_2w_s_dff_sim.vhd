--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2014 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Rick Kelly              July 1, 2014
--
-- VERSION:   simulation architecture
--
-- DesignWare_version: 77407572
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Four port (2 read, 2 write) RAM with synchronous write and
--            asynchronous read constructed of D FFs.
--
--
--	Pameter		value range	description
--	=======		===========	===========
--      width           1 to 8192       Data word width
--      addr_width      1 to 12         Address bus width
--	rst_mode	0 to 1		Reset mode (0 => async reset)
--
--	Port		size 	   dir  description
--      ====            ====            ===========
--      clk              1          I   Clock input (rising edge sensitive)
--      rst_n            1          I   Active low reset input (async)
--
--      en_w1_n          1          I   Active low write port 1 write enable
--      addr_w1       addr_width    I   Write address for write port 1
--      data_w1         width       I   Data to be written via write port 1
--
--      en_w2_n          1          I   Active low write port 2 write enable
--      addr_w2       addr_width    I   Write address for write port 2
--      data_w2         width       I   Data to be written via write port 2
--
--      en_r1_n          1          I   Active low read port 1 read enable
--      addr_r1      addr_width     I   Read address for read port 1
--      data_r1        width        O   Data read from port 1
--
--      en_r2_n          1          I   Active low read port 2 read enable
--      addr_r2      addr_width     I   Read address for read port 2
--      data_r2        width        O   Data read from port 2
-- MODIFIED:
--           
--
---------------------------------------------------------------------------------
library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use DWARE.DWpackages.all;

architecture sim of DW_ram_2r_2w_s_dff is
	

  constant depth    : INTEGER := 2 ** addr_width;

  signal   mem      : std_logic_vector(depth*width-1 downto 0);
  signal   next_mem : std_logic_vector(depth*width-1 downto 0);
 
begin
-- pragma translate_off

  
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
	    
  
    if ( (width < 1) OR (width > 8192) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter width (legal range: 1 to 8192)"
        severity warning;
    end if;
  
    if ( (addr_width < 1) OR (addr_width > 12 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter addr_width (legal range: 1 to 12 )"
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

  
  data_r1 <= (others => '0') WHEN (en_r1_n = '1') else
               (others => 'X') WHEN (Is_X(en_r1_n) OR Is_X(addr_r1)) else
		    mem((CONV_INTEGER(UNSIGNED(addr_r1))+1)*width-1
				downto
			CONV_INTEGER(UNSIGNED(addr_r1))*width);
  
  
  data_r2 <= (others => '0') WHEN (en_r2_n = '1') else
               (others => 'X') WHEN (Is_X(en_r2_n) OR Is_X(addr_r2)) else
		    mem((CONV_INTEGER(UNSIGNED(addr_r2))+1)*width-1
				downto
			CONV_INTEGER(UNSIGNED(addr_r2))*width);
  
  
  next_mem_PROC : process( en_w1_n, addr_w1, data_w1, en_w2_n, addr_w2, data_w2, mem )
    variable array_indx : INTEGER;
  begin
    
    next_mem <= mem;
    
    if (en_w2_n /= '1') then
      if (Is_X(addr_w2)) then
        next_mem <= (others => 'X');
    
      else
	
	for bit_id in 0 to width-1 loop
	
	  array_indx := CONV_INTEGER(UNSIGNED(addr_w2))*width + bit_id;
	  
	  if (en_w2_n) = '0' then
	    next_mem(array_indx) <= To_X01(data_w2(bit_id));
	  
	  else
	    if (mem(array_indx) /= To_X01(data_w2(bit_id))) then
	      next_mem(array_indx) <= 'X';
	    end if;
	  end if;
	
	end loop;
      end if;
    end if;
    
    if (en_w1_n /= '1') then
      if (Is_X(addr_w1)) then
        next_mem <= (others => 'X');
    
      else
	
	for bit_id in 0 to width-1 loop
	
	  array_indx := CONV_INTEGER(UNSIGNED(addr_w1))*width + bit_id;
	  
	  if (en_w1_n) = '0' then
	    next_mem(array_indx) <= To_X01(data_w1(bit_id));
	  
	  else
	    if (mem(array_indx) /= To_X01(data_w1(bit_id))) then
	      next_mem(array_indx) <= 'X';
	    end if;
	  end if;
	
	end loop;
      end if;
    end if;
    
  end process next_mem_PROC;
  
G1 : if (rst_mode = 0) generate
  async_registers_PROC : process( clk, rst_n )
   begin
    
    if (rst_n = '0') then
      mem <= (others => '0');
    
    elsif rising_edge(clk) then
      mem <= next_mem;
    end if;
  end process async_registers_PROC;
end generate G1;
  
G2 : if (rst_mode /= 0) generate
  sync_registers_PROC : process( clk )
   begin
    
    if rising_edge(clk) then
    
      if (rst_n = '0') then
        mem <= (others => '0');
      
      else
        mem <= next_mem;
      end if;
    
    end if;
  end process sync_registers_PROC;
end generate G2;
  
  
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

configuration DW_ram_2r_2w_s_dff_cfg_sim of DW_ram_2r_2w_s_dff is
 for sim
 end for; -- sim
end DW_ram_2r_2w_s_dff_cfg_sim;
-- pragma translate_on

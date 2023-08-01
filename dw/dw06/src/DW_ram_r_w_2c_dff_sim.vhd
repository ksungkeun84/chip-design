--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2006 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Rick Kelly              Nov. 7, 2006
--
-- VERSION:   simulation architecture
--
-- DesignWare_version: 1712cbe3
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  D-type flip-flop based dual port RAM with
--            separate write and read clocks and independently
--            configurable pre and post array retiming registers.
--
--
-- MODIFIED:
--           
--
---------------------------------------------------------------------------------
library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

architecture sim of DW_ram_r_w_2c_dff is
	

  type array_of_words is array (0 to depth-1) of
			  std_logic_vector(width-1 downto 0);

  constant zeroed_word : std_logic_vector(width-1 downto 0) := (others => '0');
  constant exed_word   : std_logic_vector(width-1 downto 0) := (others => 'X');

  signal   mem_array	: array_of_words;

  constant zeroed_array : array_of_words := (others => zeroed_word);
  constant exed_array   : array_of_words := (others => exed_word);

  signal   en_w_q	: std_logic;
  signal   addr_w_q	: std_logic_vector(addr_width-1 downto 0);
  signal   data_w_q	: std_logic_vector(width-1 downto 0);

  signal   en_r_q	: std_logic;
  signal   addr_r_q	: std_logic_vector(addr_width-1 downto 0);

  signal   en_w_mem	: std_logic;
  signal   addr_w_mem	: std_logic_vector(addr_width-1 downto 0);
  signal   data_w_mem	: std_logic_vector(width-1 downto 0);
  signal   en_r_mem	: std_logic;
  signal   addr_r_mem	: std_logic_vector(addr_width-1 downto 0);
  signal   data_r_mem	: std_logic_vector(width-1 downto 0);

  signal   en_r_qq	: std_logic;
  signal   data_r_q	: std_logic_vector(width-1 downto 0);
 
begin
-- pragma translate_off

  
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
  
    if ( (width < 1) OR (width > 1024) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter width (legal range: 1 to 1024)"
        severity warning;
    end if;
  
    if ( (depth < 2) OR (depth > 1024 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter depth (legal range: 2 to 1024 )"
        severity warning;
    end if;
  
    if ( (2**addr_width) < depth ) then
      param_err_flg := 1;
      assert false
        report "ERROR: parameter, addr_width, value too small for depth of memory"
        severity warning;
    end if;
  
    if ( (2**(addr_width-1)) >= depth ) then
      param_err_flg := 1;
      assert false
        report "ERROR: parameter, addr_width, value too large for depth of memory"
        severity warning;
    end if;
  
    if ( (mem_mode < 0) OR (mem_mode > 7 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter mem_mode (legal range: 0 to 7 )"
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

  data_r_mem <= (others => 'X') WHEN (Is_X(en_r_mem) or Is_X(addr_r_mem)) else
		  (others => '0') WHEN (CONV_INTEGER(UNSIGNED(addr_r_mem)) >= depth) else
		    mem_array((CONV_INTEGER(UNSIGNED(addr_r_mem))));
  
  
  mem_write_PROC : process( clk_w, rst_w_n ) begin
    
    if (rst_w_n = '0') AND (rst_mode = 0) then
      mem_array <= zeroed_array;
    elsif (rst_w_n = '1') OR (rst_mode = 1) then
      if rising_edge(clk_w) then
	if (init_w_n = '0') AND (rst_mode = 0) then
	  mem_array <= zeroed_array;
	elsif (init_w_n = '1') OR (rst_mode = 1) then
	  if (en_w_mem = '1') then
	    if Is_X(addr_w_mem) then
	      mem_array <= exed_array;
	    else
	      if (CONV_INTEGER(UNSIGNED(addr_w_mem)) < depth) then
		mem_array( CONV_INTEGER(UNSIGNED(addr_w_mem)) ) <=
			    To_X01( data_w_mem );
	      end if;
	    end if;
	  elsif (en_w_mem /= '0') then
	    if (Is_X(addr_w_mem)) then
	      mem_array <= exed_array;
	    else
	      mem_array( CONV_INTEGER(UNSIGNED(addr_w_mem)) ) <= (others => 'X');
	    end if;
	  end if;
	else
	  mem_array <= exed_array;
	end if;
      end if;
    else
      mem_array <= exed_array;
    end if;

  end process mem_write_PROC;

  G1A : if (mem_mode > 3) generate
    retime_w_inputs_PROC : process (clk_w, rst_w_n) begin
      if (rst_w_n = '0') then
	en_w_q   <= '0';
	addr_w_q <= (others => '0');
        data_w_q <= zeroed_word;
      elsif (rst_w_n = '1') then
        if rising_edge(clk_w) then
	  if (init_w_n = '0') then
	    en_w_q   <= '0';
	    addr_w_q <= (others => '0');
	    data_w_q <= zeroed_word;
	  elsif (init_w_n = '1') then
	    en_w_q <= NOT en_w_n;
	    if (en_w_n = '0') then
	      addr_w_q <= addr_w;
	      data_w_q <= data_w;
	    elsif (en_w_n /= '1') then
	      addr_w_q <= (others => 'X');
	      data_w_q <= exed_word;
	    end if;
	  else
	    en_w_q   <= 'X';
	    addr_w_q <= (others => 'X');
	    data_w_q <= exed_word;
	  end if;
	end if;
      else
	en_w_q   <= 'X';
	addr_w_q <= (others => 'X');
	data_w_q <= exed_word;
      end if;
    end process retime_w_inputs_PROC;

    addr_w_mem <= addr_w_q;
    en_w_mem <= en_w_q;
    data_w_mem <= data_w_q;
  end generate G1A;
  

  G1B : if (mem_mode <= 3) generate
    addr_w_mem <= addr_w;
    en_w_mem <= NOT en_w_n;
    data_w_mem <= data_w;
  end generate G1B;
  
  
  G2A : if ((mem_mode mod 4) > 1) generate
    retime_r_inputs_PROC : process (clk_r, rst_r_n) begin
      if (rst_r_n = '0') then
	en_r_q   <= '0';
	addr_r_q <= (others => '0');
      elsif (rst_r_n = '1') then
        if rising_edge(clk_r) then
	  if (init_r_n = '0') then
	    en_r_q   <= '0';
	    addr_r_q <= (others => '0');
	  elsif (init_r_n = '1') then
	    en_r_q <= NOT en_r_n;
	    if (en_r_n = '0') then
	      addr_r_q <= addr_r;
	    elsif (en_r_n /= '1') then
	      addr_r_q <= (others => 'X');
	    end if;
	  else
	    en_r_q   <= 'X';
	    addr_r_q <= (others => 'X');
	  end if;
	end if;
      else
	en_r_q   <= 'X';
	addr_r_q <= (others => 'X');
      end if;
    end process retime_r_inputs_PROC;

    en_r_mem <= en_r_q;
    addr_r_mem <= addr_r_q;
  end generate G2A;


  G2B : if ((mem_mode mod 4) <= 1) generate
    en_r_mem <= NOT en_r_n;
    addr_r_mem <= addr_r;
  end generate G2B;
  
  
  G3A : if ((mem_mode mod 2) = 1) generate
    retime_r_outputs_PROC : process (clk_r, rst_r_n) begin
      if (rst_r_n = '0') then
	en_r_qq <= '0';
	data_r_q <= (others => '0');
      elsif (rst_r_n = '1') then
        if rising_edge(clk_r) then
	  if (init_r_n = '0') then
	    en_r_qq   <= '0';
	    data_r_q <= (others => '0');
	  elsif (init_r_n = '1') then
	    en_r_qq <= en_r_mem;
	    if (en_r_mem = '1') then
	      data_r_q <= data_r_mem;
	    elsif (en_r_mem /= '0') then
	      data_r_q <= (others => 'X');
	    end if;
	  else
	    en_r_qq  <= 'X';
	    data_r_q <= (others => 'X');
	  end if;
	end if;
      else
	en_r_qq  <= 'X';
	data_r_q <= (others => 'X');
      end if;
    end process retime_r_outputs_PROC;

    data_r <= data_r_q;
    data_r_a <= en_r_qq;
  end generate G3A;



  G3B : if ((mem_mode mod 2) = 0) generate
    data_r <= data_r_mem;
    data_r_a <= en_r_mem;
  end generate G3B;
  
  
  
  clk_monitor_PROC  : process (clk_w) begin

    assert NOT (Is_X( clk_w ) AND (now > 0 ns)) 
      report "WARNING: Detected unknown value on the clock input port clk_w."
      severity warning;

  end process clk_monitor_PROC ;

-- pragma translate_on
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_ram_r_w_2c_dff_cfg_sim of DW_ram_r_w_2c_dff is
 for sim
 end for; -- sim
end DW_ram_r_w_2c_dff_cfg_sim;
-- pragma translate_on

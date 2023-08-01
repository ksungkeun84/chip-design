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
-- AUTHOR:    Bob Tong				Aug. 98
--
-- VERSION:   VHDL Simulation Model
--
-- DesignWare_version: 7c85dcc9
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Asymmetric Synchronous, dual clcok with Static Flags
--           (FIFO) with static programmable almost empty and almost
--           full flags.
--
--           This FIFO controller designed to interface to synchronous
--           true dual port RAMs.
--
--              Parameters:     Valid Values
--              ==========      ============
--              data_in_width   [1 to 4096]
--              data_out_width  [1 to 4096]
--                  Note: data_in_width and data_out_width must be
--                        in integer multiple relationship: either
--                              data_in_width = K * data_out_width
--                        or    data_out_width = K * data_in_width
--              depth           [ 8 to 16777216 ]
--              push_ae_lvl     [ 1 to (depth/2)-1 ]
--              push_af_lvl     [ 1 to (depth/2)-1 ]
--              pop_ae_lvl      [ 1 to (depth/2)-1 ]
--              pop_af_lvl      [ 1 to (depth/2)-1 ]
--              err_mode        [ 0 = sticky error flag,
--                                1 = dynamic error flag ]
--              push_sync       [ 1 = single synchronized,
--                                2 = double synchronized ]
--              pop_sync        [ 1 = single synchronized,
--                                2 = double synchronized ]
--              rst_mode        [ 0 = asynchronous reset,
--                                1 = synchronous reset ]
--              byte_order      [ 0 = the first byte is in MSBs
--                                1 = the first byte is in LSBs ]
--              
--              Input Ports:    Size    Description
--              ===========     ====    ===========
--              clk_push        1 bit   Push I/F Input Clock
--              clk_pop         1 bit   Pop I/F Input Clock
--              rst_n           1 bit   Active Low Reset
--              push_req_n      1 bit   Active Low Push Request
--              flush_n         1 bit   Flush the partial word into
--                                      the full word memory.  For
--                                      data_in_width<data_out_width
--                                      only
--              pop_req_n       1 bit   Active Low Pop Request
--              data_in         L bits  FIFO data to push
--              rd_data         M bits  RAM data input to asymmetric
--                                      FIFO controller
--
--              Output Ports    Size    Description
--              ============    ====    ===========
--              we_n            1 bit   Active low Write Enable (to RAM)
--              push_empty      1 bit   Push I/F Empty Flag
--              push_ae         1 bit   Push I/F Almost Empty Flag
--              push_hf         1 bit   Push I/F Half Full Flag
--              push_af         1 bit   Push I/F Almost Full Flag
--              push_full       1 bit   Push I/F Full Flag
--              ram_full        1 bit   Push I/F ram Full Flag
--              part_wd         1 bit   Partial word read flag.  For
--                                      data_in_width<data_out_width
--                                      only
--              push_error      1 bit   Push I/F Error Flag
--              pop_empty       1 bit   Pop I/F Empty Flag
--              pop_ae          1 bit   Pop I/F Almost Empty Flag
--              pop_hf          1 bit   Pop I/F Half Full Flag
--              pop_af          1 bit   Pop I/F Almost Full Flag
--              pop_full        1 bit   Pop I/F Full Flag
--              pop_error       1 bit   Pop I/F Error Flag
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
--
-- MODIFIED:
--
--  11/04/15  RJK  Change pkg use from individual DW03 pkg to unified DWARE pkg
--
------------------------------------------------------------------------
library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use DWARE.DW_Foundation_arith.all; 
use DWARE.DW_Foundation_comp_arith.all;

architecture sim of DW_asymfifoctl_s2_sf is
	
  function in_out_ratio(par1, par2: integer) return INTEGER is
    begin
      if(par1 > par2) then
        return (par1/par2);
      else
        return (par2/par1);
      end if;
    end in_out_ratio;
  constant K : INTEGER := in_out_ratio(data_in_width, data_out_width);
  constant LBOUND : INTEGER := minimum(data_in_width, data_out_width);
  constant UBOUND : INTEGER := maximum(data_in_width, data_out_width);
  type reg_array is array (0 to K-1) of 
       std_logic_vector(data_in_width-1 downto 0);
  signal data_in_reg    : reg_array;
  signal rst_n_int      : std_logic;
  signal push_req_n_int : std_logic;
  signal ram_push_n     : std_logic;
  signal pop_req_n_int  : std_logic;
  signal ram_pop_n	: std_logic;
  signal ram_pop_n_int	: std_logic;
  signal push_full_int  : std_logic;
  signal ram_pop_full   : std_logic;
  signal flush_n_int    : std_logic;
  signal part_wd_int    : std_logic; 
  signal ram_push_full  : std_logic;
  signal wr_to_ram_n      : std_logic;
  signal wr_data_int    : std_logic_vector(maximum
         (data_in_width,data_out_width)-1 downto 0);
  signal buff_addr : integer range -1 to K-1;
  signal ram_push_error : std_logic;
  signal push_error_int : std_logic;
  signal ram_pop_error  : std_logic;
  signal pop_empty_int  : std_logic;
  signal pop_error_int  : std_logic;
  signal data_out_int   : std_logic_vector(data_out_width-1 downto 0);
  signal low : std_logic;

begin
-- pragma translate_off
 low <= '0';
  rst_n_int      <= To_01X(rst_n);
  push_req_n_int <= To_01X(push_req_n);
  pop_req_n_int  <= To_01X(pop_req_n);
  pop_empty <= pop_empty_int;
  flush_n_int <= To_01X(flush_n) when
                 (data_in_width < data_out_width) else
                 '1';
  ram_pop_n <= pop_req_n_int when 
               (data_in_width <= data_out_width) else
               ram_pop_n_int;
  data_out <= rd_data when
              (data_in_width <= data_out_width) else
              data_out_int;
  pop_error <= ram_pop_error when
               (data_in_width <= data_out_width) else
               pop_error_int;
  ram_push_n <= push_req_n when
                (data_in_width >= data_out_width) else
                (wr_to_ram_n );
  wr_data <= data_in when
             (data_in_width >= data_out_width) else
             wr_data_int;
  part_wd <= '0' when
             (data_in_width >= data_out_width) else
              part_wd_int;
  push_full <= ram_push_full when
               (data_in_width >= data_out_width) else
               push_full_int;
  push_error <= ram_push_error when 
                (data_in_width >= data_out_width) else
                push_error_int;
  pop_full <= ram_pop_full;
  ram_full <= ram_push_full; 
------------------------------------------------------------------------
write_to_ram_proc : process (push_req_n_int, buff_addr, ram_push_full,
			flush_n_int )
begin  -- process write_to_ram_proc
  if (data_in_width < data_out_width) then
    if ( buff_addr = -1 ) then
	    wr_to_ram_n <= 'X';
    elsif (( buff_addr = K-1 AND ram_push_full = '0'
	     AND push_req_n_int = '0') or
	   (buff_addr > 0 AND flush_n_int = '0'
	    AND push_req_n_int = '1' and ram_push_full = '0') or
	   (buff_addr > 0 AND push_req_n_int = '0'
	    AND flush_n_int ='0' and ram_push_full = '0')) then
	wr_to_ram_n <= '0';
    else
	wr_to_ram_n <= '1';
    end if;
  end if;
end process write_to_ram_proc;
------------------------------------------------------------------------
write_data_proc : process(data_in_reg, push_req_n_int,ram_push_full,
			  data_in, flush_n_int, buff_addr)
    
variable data_temp : std_logic_vector(LBOUND-1 downto 0);
begin  -- process write_data_proc
  if (data_in_width < data_out_width) then
    if (buff_addr = K-1 and ram_push_full = '0' and
	   push_req_n_int = '0' and flush_n_int = '1' ) then
	data_temp( LBOUND-1 downto 0 )
	    := data_in;
    else
	data_temp( LBOUND-1 downto 0 )
	    := (others => '0');
    end if;
    if (byte_order = 0) then
	for i in 0 to (K-2) loop
	    wr_data_int( (UBOUND - (LBOUND*i) - 1) downto
			 (UBOUND-(LBOUND * (i+1))) )
		<= data_in_reg(i);
	end loop;
	wr_data_int( LBOUND-1 downto 0 ) <= data_temp;
    else
	for i in 0 to (K-2) loop
	    wr_data_int( (LBOUND * (i+1) - 1) downto
			 LBOUND * (i) )
		<= data_in_reg(i);
	end loop;
	wr_data_int( UBOUND-1 downto UBOUND-LBOUND)
	    <= data_temp; 
    end if;
 end if;
end process write_data_proc;
------------------------------------------------------------------------
push_flag_proc : process (ram_push_full,  buff_addr)
begin  -- process push_flag_proc
  if (data_in_width < data_out_width) then    
    if ((buff_addr = -1 ) or (ram_push_full = 'X')) then
	push_full_int <= 'X';
    elsif ( ram_push_full = '1' and buff_addr = K-1) then
	push_full_int <= '1';
    else
	push_full_int <= '0';
    end if;
  end if;
end process push_flag_proc;
------------------------------------------------------------------------
read_from_ram_proc : process (buff_addr, pop_req_n_int,pop_empty_int)
    
begin  -- process read_from_ram_proc
  if (data_in_width > data_out_width) then
    if ( buff_addr = -1 ) then
	    ram_pop_n_int <= 'X';
    elsif ( buff_addr = K-1 and pop_req_n_int = '0'
	    and pop_empty_int = '0') then
	ram_pop_n_int <= '0';
    else
	ram_pop_n_int <= '1';
    end if;
  end if;
end process read_from_ram_proc;
------------------------------------------------------------------------
data_out_proc : process (rd_data, buff_addr)
    
begin 
  if (data_in_width > data_out_width) then  
    if (buff_addr >  -1) then
	if (byte_order = 0) then
	    data_out_int  <= rd_data( (UBOUND -
			   (LBOUND * buff_addr) - 1) downto
			  (UBOUND - (LBOUND * (buff_addr + 1)) ) );
	else
	    data_out_int
		<= rd_data((LBOUND * (buff_addr+1)-1) downto
			   (LBOUND * (buff_addr)));
	end if;
    end if;
  end if;
end process data_out_proc;
------------------------------------------------------------------------
sim_mdl_proc : process 
variable next_buff_addr  : integer range -1 to (K-1);
  begin
      if (data_in_width < data_out_width) then
	if (rst_mode = 1) then  	
	    wait until (clk_push'event and
		      (clk_push'last_value = '0') and
		      (clk_push = '1'));
	end if;
	if (rst_n_int = '0') then
	    next_buff_addr := 0;
	    buff_addr <= 0;
	    push_error_int <= '0';
	    part_wd_int <= '0';
	    for i in 0 to (K-2) loop
		data_in_reg(i) <= (others => '0');
	    end loop;
	    wait until (rst_n_int /= '0');
	elsif (rst_n_int = 'X') then
	    next_buff_addr := -1;
	    buff_addr <= -1;
	    push_error_int <= 'X';
	    part_wd_int <= 'X';
	    for i in 0 to (K-2) loop
		data_in_reg(i) <= (others => 'X');
	    end loop;
	    wait until (rst_n_int /= 'X' );
	else
	    if (rst_mode = 0) then
		wait until ((clk_push'event and
			     clk_push'last_value = '0' and
			     clk_push = '1') or
			    (rst_n_int /= '1'));
	    end if;
          if ( rst_n_int = '1' ) then
	    if (next_buff_addr = -1 ) then
		push_error_int <= 'X';
	    elsif (err_mode = 0) then
		push_error_int <= ((not push_req_n_int  and
				    push_full_int ) or
				   (not flush_n_int and  part_wd_int and
				    ram_push_full) or
				   push_error_int);
	    else
		push_error_int <= ((not push_req_n_int  and
				    push_full_int ) or
				   (not flush_n_int and  part_wd_int and
				    ram_push_full));		
	    end if;
	    if ((push_req_n_int = 'X' and push_full_int = '0' ) or
		    (flush_n_int = 'X'and next_buff_addr > 0 and
		     ram_push_full = '0') ) then
			next_buff_addr := -1;
			part_wd_int <= 'X';
	    elsif (( buff_addr = K-1 AND ram_push_full = '0'
		     AND push_req_n_int = '0') or
		   (part_wd_int = '1' AND flush_n_int = '0'
		    AND push_req_n_int = '1'
		    and ram_push_full = '0') or
		   (part_wd_int = '1' AND push_req_n_int = '0'
		    AND flush_n_int ='0' and
		    ram_push_full = '0')) then
		if (flush_n_int = '0') then
		    if (push_req_n_int = '0') then
			next_buff_addr := 1;
			part_wd_int <= '1';
			data_in_reg(0) <= data_in;
			for i in 1 to (K-2) loop
			    data_in_reg(i) <= (others => '0');
			end loop;
		    else
			next_buff_addr := 0;
			part_wd_int <= '0';
			for i in 1 to (K-2) loop
			    data_in_reg(i) <= (others => '0');
			end loop;			
		    end if;
		 else
		     next_buff_addr := 0;
		     part_wd_int <= '0';
		     for i in 0 to (K-2) loop
			 data_in_reg(i) <= (others => '0');
		     end loop;		     
		end if;
	    else
		if (push_req_n_int = '0' and ram_push_full = '0') OR
		    (push_req_n_int = '0' and ram_push_full = '1'
		    and next_buff_addr < K-1 ) or
		    (flush_n_int = '1' and ram_push_full = '0'
		     AND push_req_n_int = '0')  then
		    data_in_reg(next_buff_addr) <= data_in;
		    next_buff_addr := (next_buff_addr +1) mod (K);
		    part_wd_int <= '1';
		end if;		
		
            end if;
	    
	    buff_addr <= next_buff_addr;
          end if;
	end if;
	    
	    
    elsif (data_in_width > data_out_width) then
	if (rst_mode = 1) then
	    wait until (clk_pop'event and
		      (clk_pop'last_value = '0') and
		      (clk_pop = '1'));
	end if;
	if (rst_n_int = '0') then
	    next_buff_addr := 0;
	    buff_addr <= 0;
	    pop_error_int <= '0';
	    part_wd_int <= '0';
	    wait until (rst_n_int /= '0');
	elsif (rst_n_int = 'X') then
	    next_buff_addr := -1;
	    buff_addr <= -1;
	    pop_error_int <= 'X';
	    part_wd_int <= 'X';
	    wait until (rst_n_int /= 'X');	    
	else
	    if (rst_mode = 0) then
		wait until ((clk_pop'event and
			     clk_pop'last_value = '0' and
			     clk_pop = '1') or
			    (rst_n_int /= '1'));
	    end if;
	    if ( rst_n_int = '1' ) then
		if (err_mode = 0) then
		    pop_error_int <= ((not pop_req_n_int and pop_empty_int) or
				      pop_error_int) ;
		else
		    pop_error_int <= not pop_req_n_int and pop_empty_int;
		end if;
		if (pop_req_n_int = 'X' ) then
		    next_buff_addr := -1;
		elsif (pop_req_n_int = '0' AND pop_empty_int = '0') then
		    if (next_buff_addr < K-1) then
			next_buff_addr := (next_buff_addr +1) mod (K);
		    else
			next_buff_addr := 0;
		    end if;
		end if;
		
		buff_addr <= next_buff_addr;
	    end if;
       end if;
      else
	  wait;
  end if;
  end process sim_mdl_proc;
------------------------------------------------------------------------
DW_fifoctl_s2_sf_sim : DW_fifoctl_s2_sf 
        generic map (
                    depth => depth,
                    push_ae_lvl => push_ae_lvl,
                    push_af_lvl => push_af_lvl,
                    pop_ae_lvl => pop_ae_lvl,
                    pop_af_lvl => pop_af_lvl,
                    err_mode => err_mode,
                    push_sync => push_sync,
                    pop_sync => pop_sync,
                    rst_mode =>rst_mode,
                    tst_mode =>     0
                )
        
        port map    (
                    clk_push => clk_push,
                    clk_pop => clk_pop,
                    rst_n => rst_n,
                    push_req_n => ram_push_n,
                    pop_req_n => ram_pop_n,
                    we_n => we_n,
                    push_empty => push_empty,
                    push_ae => push_ae,
                    push_hf => push_hf,
                    push_af => push_af,
                    push_full => ram_push_full,
                    push_error => ram_push_error,
                    pop_empty => pop_empty_int,
                    pop_ae => pop_ae,
                    pop_hf => pop_hf,
                    pop_af => pop_af,
                    pop_full => ram_pop_full,
                    pop_error => ram_pop_error,
                    wr_addr => wr_addr,
                    rd_addr => rd_addr,
                    test =>         low 
                );

   
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    

   
    if ( (data_in_width < 1) OR (data_in_width > 4096 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter data_in_width (legal range: 1 to 4096 )"
        severity warning;
    end if;
   
    if ( (data_out_width < 1) OR (data_out_width > 4096 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter data_out_width (legal range: 1 to 4096 )"
        severity warning;
    end if;
   
    if ( (depth < 4) OR (depth > 16777216 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter depth (legal range: 4 to 16777216 )"
        severity warning;
    end if;
   
    if ( (push_ae_lvl < 1) OR (push_ae_lvl > depth-1 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter push_ae_lvl (legal range: 1 to depth-1 )"
        severity warning;
    end if;
   
    if ( (push_af_lvl < 1) OR (push_af_lvl > depth-1 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter push_af_lvl (legal range: 1 to depth-1 )"
        severity warning;
    end if;
   
    if ( (pop_ae_lvl < 1) OR (pop_ae_lvl > depth-1 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter pop_ae_lvl (legal range: 1 to depth-1 )"
        severity warning;
    end if;
   
    if ( (pop_af_lvl < 1) OR (pop_af_lvl > depth-1 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter pop_af_lvl (legal range: 1 to depth-1 )"
        severity warning;
    end if;
   
    if ( (push_sync < 1) OR (push_sync > 3 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter push_sync (legal range: 1 to 3 )"
        severity warning;
    end if;
   
    if ( (pop_sync < 1) OR (pop_sync > 3 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter pop_sync (legal range: 1 to 3 )"
        severity warning;
    end if;
   
    if ( (err_mode < 0) OR (err_mode > 1 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter err_mode (legal range: 0 to 1 )"
        severity warning;
    end if;
   
    if ( (rst_mode < 0) OR (rst_mode > 1 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter rst_mode (legal range: 0 to 1 )"
        severity warning;
    end if;
   
    if ( (byte_order < 0) OR (byte_order > 1 ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter byte_order (legal range: 0 to 1 )"
        severity warning;
    end if;

   
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;
-- pragma translate_on
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

library dw03;

configuration DW_asymfifoctl_s2_sf_cfg_sim of DW_asymfifoctl_s2_sf is
 for sim
for DW_fifoctl_s2_sf_sim : DW_fifoctl_s2_sf use configuration dw03.DW_fifoctl_s2_sf_cfg_sim; end for;
 end for; -- sim
end DW_asymfifoctl_s2_sf_cfg_sim;
-- pragma translate_on

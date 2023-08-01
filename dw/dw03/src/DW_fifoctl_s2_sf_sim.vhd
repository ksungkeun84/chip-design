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
-- AUTHOR:    Rajeev Huralikoppi         10/28/97
--
-- VERSION:   VHDL Simulation Model  
--
-- DesignWare_version: 0da486ce
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Synchronous, dual clcok  with Static Flags
--           static programmable almost empty and almost full flags
--
--           This FIFO controller designed to interface to synchronous
--           true dual port RAMs.
--
--    Parameters: Valid Values
--    ==========  ============
--    depth   [ 4 to 16777216 ]
--    push_ae_lvl [ 1 to depth-1 ]
--    push_af_lvl [ 1 to depth-1 ]
--    pop_ae_lvl  [ 1 to depth-1 ]
--    pop_af_lvl  [ 1 to depth-1 ]
--    err_mode  [ 0 = dynamic error flag,
--          1 = sticky error flag ]
--    push_sync [ 1 = single synchronized,
--          2 = double synchronized,
--          3 = triple synchronized ]
--    pop_sync  [ 1 = single synchronized,
--          2 = double synchronized,
--          3 = triple synchronized ]
--    tst_mode  [ 0 = test input not connected
--          1 = lock-up latches inserted for scan test ]
--
--    Input Ports: Size   Description
--    ===========  ====   ===========
--    clk_push    1 bit   Push I/F Input Clock
--    clk_pop     1 bit   Pop I/F Input Clock
--    rst_n       1 bit   Active Low Reset
--    push_req_n  1 bit   Active Low Push Request
--    pop_req_n   1 bit   Active Low Pop Request
--
--    Output Ports      Size   Description
--    ============      ====   ===========
--    we_n             1 bit   Active low Write Enable (to RAM)
--    push_empty       1 bit   Push I/F Empty Flag
--    push_ae          1 bit   Push I/F Almost Empty Flag
--    push_hf          1 bit   Push I/F Half Full Flag
--    push_af          1 bit   Push I/F Almost Full Flag
--    push_full        1 bit   Push I/F Full Flag
--    push_error       1 bit   Push I/F Error Flag
--    pop_empty        1 bit   Pop I/F Empty Flag
--    pop_ae           1 bit   Pop I/F Almost Empty Flag
--    pop_hf           1 bit   Pop I/F Half Full Flag
--    pop_af           1 bit   Pop I/F Almost Full Flag
--    pop_full         1 bit   Pop I/F Full Flag
--    pop_error        1 bit   Pop I/F Error Flag
--    wr_addr          N bits  Write Address (to RAM)
--    rd_addr          N bits  Read Address (to RAM)
--    push_word_count  M bits  Number of words in FIFO as seen by push IF
--    pop_word_count   M bits  Number of words in FIFO as seen by pop IF
--    test             1 bit   Test Input (controls lock-up latches)
--
--      Note: the value of N for wr_addr and rd_addr is
--      determined from the parameter, depth.  The
--      value of N is equal to:
--        ceil( log2( depth ) )
--
--      Note: the value of M for push_word_count and pop_word_count is
--      determined from the parameter, depth.  The
--      value of M is equal to:
--        ceil( log2( depth+1 ) )
--
--
---------------------------------------------------------------------------------
library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use DWARE.DWpackages.all;

architecture sim of DW_fifoctl_s2_sf is
-- pragma translate_off

function calc_modulus( depth, left_over : in INTEGER ) return INTEGER is
begin
 if ( left_over = depth ) then
   return( depth * 2 );
 else
   return( depth + 2 - (depth mod 2) );
 end if;
end calc_modulus;
function calc_width( depth, left_over : in INTEGER ) return INTEGER is
begin
 if ( left_over = depth ) then
   return( bit_width(depth+1)-1);
 else
   return( bit_width(depth+1) );
 end if;
end calc_width;
constant addr_width : INTEGER := bit_width(depth+1);
constant real_left_over : INTEGER := (2**addr_width) - depth;
constant rollover : INTEGER := calc_modulus( depth, real_left_over );
constant out_width : INTEGER := calc_width(depth, real_left_over );

signal push_req_n_int : std_logic;
signal pop_req_n_int  : std_logic;
signal we_n_int       : std_logic;
signal a_rst_n, s_rst_n : std_logic;

signal push_full_int  : std_logic;
signal next_push_error_int, next_pop_error_int : std_logic;
signal push_error_int, pop_error_int           : std_logic;

signal wd_count, next_wd_count       : integer range -1 to rollover;
signal rd_count, next_rd_count       : integer range -1 to rollover;
signal wr_addr_int, next_wr_addr_int : integer range -1 to rollover;
signal rd_addr_int, next_rd_addr_int : integer range -1 to rollover;
signal wr_addr_ltch, rd_addr_ltch    : integer range -1 to rollover;
signal wr_addr_smpl, rd_addr_smpl    : integer range -1 to rollover;
signal wcmp_addr, rcmp_addr          : integer range -1 to rollover;

signal do_push, do_pop   : std_logic;
signal sync_raddr1, sync_raddr2 : integer range -1 to rollover;
signal sync_waddr1, sync_waddr2 : integer range -1 to rollover;
-- pragma translate_on
begin
-- pragma translate_off
   
   
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
   
    if ( (depth < 4) OR (depth > 16777216) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter depth (legal range: 4 to 16777216)"
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
   
    if ( (push_sync < 1) OR (push_sync > 3) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter push_sync (legal range: 1 to 3)"
        severity warning;
    end if;
   
    if ( (pop_sync < 1) OR (pop_sync > 3) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter pop_sync (legal range: 1 to 3)"
        severity warning;
    end if;
   
    if ( (err_mode < 0) OR (err_mode > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter err_mode (legal range: 0 to 1)"
        severity warning;
    end if;
   
    if ( (tst_mode < 0) OR (tst_mode > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter tst_mode (legal range: 0 to 1)"
        severity warning;
    end if;


   
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;


push_req_n_int <= To_X01(push_req_n);
pop_req_n_int  <= To_X01(pop_req_n);
we_n <= push_full_int or push_req_n_int;
a_rst_n <= rst_n when (rst_mode  = 0) else '1';
s_rst_n <= rst_n when (rst_mode /= 0) else '1';

push_full <= push_full_int;
push_error <= push_error_int;
 
pop_error <= pop_error_int;
   
wr_addr <= (others => 'X') when wr_addr_int = -1 else
              std_logic_vector(conv_unsigned(wr_addr_int, out_width));
rd_addr <= (others => 'X') when rd_addr_int = -1 else
              std_logic_vector(conv_unsigned(rd_addr_int, out_width));

mk_next_wr_addr_int : process (push_req_n_int, wd_count, wr_addr_int )
begin
  if (push_req_n_int = '0') then
    if (wd_count = depth) then
      next_wr_addr_int <= wr_addr_int;
    
    elsif (wd_count < 0) then
      next_wr_addr_int <= -1;
    
    else
      next_wr_addr_int <= (wr_addr_int + 1) mod rollover;
    end if;
  else
    if ((push_req_n_int /= '1') AND (wd_count /= depth)) OR (wd_count < 0) then
      next_wr_addr_int <= -1;
    
    else
      next_wr_addr_int <= wr_addr_int;
    end if;
  end if;
end process mk_next_wr_addr_int;

-- 

mk_next_wd_count : process (wcmp_addr, next_wr_addr_int, wd_count)
begin  -- process mk_next_push_st
  if (wd_count < 0) then
    next_wd_count <= wd_count;
  else
    if (next_wr_addr_int < 0 or wcmp_addr < 0) then
      next_wd_count <= -1;
    elsif ((next_wr_addr_int < wcmp_addr) ) then
      next_wd_count <= rollover - (wcmp_addr - next_wr_addr_int);
    else
      next_wd_count <=  (next_wr_addr_int - wcmp_addr);
    end if;      
  end if;
end process mk_next_wd_count;

-- 

mk_push_next_error : process (push_req_n_int, wd_count, wr_addr_int, push_error_int)
begin  -- process mk_push_next_error
  if (err_mode < 1 and push_error_int /= '0') then
    next_push_error_int <= push_error_int;
  else
    if ((push_req_n_int = '0') and (wd_count = depth)) then
      next_push_error_int <= '1';
    else
      if (wd_count >= 0) AND (wr_addr_int >= 0) then
        next_push_error_int <= '0';
      else
        next_push_error_int <= 'X';
      end if;
    end if;
  end if;
end process mk_push_next_error;

clk_push_registers : process (clk_push, a_rst_n)
begin
 
  if (To_X01(a_rst_n) = '0' ) then
      wr_addr_int <= 0;
      wd_count <= 0;
      push_error_int  <= '0' ;
      sync_raddr1 <= 0;
      sync_raddr2 <= 0;
      wcmp_addr <= 0;
      push_error_int  <= '0';
  elsif (To_X01(a_rst_n) = '1') then
    if (rising_edge(clk_push)) then
      if (To_X01(s_rst_n) = '0') then
        wr_addr_int <= 0;
        wd_count <= 0;
        push_error_int  <= '0' ;
        sync_raddr1 <= 0;
        sync_raddr2 <= 0;
        wcmp_addr <= 0;
        push_error_int  <= '0';
      elsif (To_X01(s_rst_n) = '1') then
        wr_addr_int <= next_wr_addr_int;
        wd_count <= next_wd_count;
        push_error_int  <= next_push_error_int ;
        if (push_sync = 1) then
          wcmp_addr <= rd_addr_smpl;
        else
          sync_raddr1 <= rd_addr_smpl;
 
	  if (push_sync = 2) then
            wcmp_addr <= sync_raddr1;
	
	  else
	    sync_raddr2 <= sync_raddr1;
	    wcmp_addr <= sync_raddr2;
	  end if;
	end if;
      else
	push_error_int  <= 'X';
	wr_addr_int <= -1;
	wd_count <= -1;
	push_error_int  <= 'X' ;
	sync_raddr1 <= -1;  
	sync_raddr2 <= -1;  
	wcmp_addr <= -1;
      end if;
    end if;
  else
    push_error_int  <= 'X';
    wr_addr_int <= -1;
    wd_count <= -1;
    push_error_int  <= 'X' ;
    sync_raddr1 <= -1;  
    sync_raddr2 <= -1;  
    wcmp_addr <= -1;
  end if;
end process clk_push_registers;

-- 

mk_push_flags : process (wd_count)
begin  -- process mk_push_flags
  if (wd_count < 0) then
    push_empty <= 'X';
    push_ae <= 'X';
    push_hf <= 'X';
    push_af <= 'X';
    push_full_int <= 'X';
    push_word_count <= (others => 'X');
  else
    if (wd_count = 0)              then push_empty <= '1'; else push_empty <= '0'; end if;
    if (wd_count <= push_ae_lvl)   then push_ae    <= '1'; else push_ae    <= '0'; end if;
    if (wd_count < (depth+1)/2)    then push_hf    <= '0'; else push_hf    <= '1'; end if;
    if (wd_count < depth-push_af_lvl) then push_af <= '0'; else push_af    <= '1'; end if;
    if (wd_count /= depth)     then push_full_int  <= '0'; else push_full_int <= '1'; end if;
    push_word_count <= std_logic_vector(CONV_UNSIGNED(wd_count,addr_width));
  end if;
end process mk_push_flags;

mk_wr_addr_ltch : process (clk_push, wr_addr_int) begin
  if (clk_push = '0') then
    wr_addr_ltch <= wr_addr_int;
  end if;
end process mk_wr_addr_ltch;

mk_wr_addr_smpl : process (test, wr_addr_ltch, wr_addr_int) begin
  if (tst_mode = 0) then
    wr_addr_smpl <= wr_addr_int;
  elsif (To_X01(test) = '0') then
    wr_addr_smpl <= wr_addr_int;
  elsif (To_X01(test) = '1') then
    wr_addr_smpl <= wr_addr_ltch;
  else
    wr_addr_smpl <= -1;
  end if;
end process mk_wr_addr_smpl;


mk_rd_addr_ltch : process (clk_pop, rd_addr_int) begin
  if (clk_pop = '0') then
    rd_addr_ltch <= rd_addr_int;
  end if;
end process mk_rd_addr_ltch;

mk_rd_addr_smpl : process (test, rd_addr_ltch, rd_addr_int) begin
  if (tst_mode = 0) then
    rd_addr_smpl <= rd_addr_int;
  elsif (To_X01(test) = '0') then
    rd_addr_smpl <= rd_addr_int;
  elsif (To_X01(test) = '1') then
    rd_addr_smpl <= rd_addr_ltch;
  else
    rd_addr_smpl <= -1;
  end if;
end process mk_rd_addr_smpl;

mk_next_rd_addr_int : process (pop_req_n_int, rd_count, rd_addr_int )
begin
  if (pop_req_n_int = '0') then
    if (rd_count = 0) then next_rd_addr_int <= rd_addr_int;
    
    elsif (rd_count < 0) then next_rd_addr_int <= -1;
    
    else next_rd_addr_int <= (rd_addr_int + 1) mod rollover;
    end if;
  else
    if ((pop_req_n_int /= '1') AND (rd_count /= 0)) OR (rd_count < 0) then
      next_rd_addr_int <= -1;
    
    else
      next_rd_addr_int <= rd_addr_int;
    end if;
  end if;
end process mk_next_rd_addr_int;

-- 

mk_next_rd_count : process (rd_count, next_rd_addr_int, rcmp_addr)
begin  -- process mk_next_pop_st
  if (rd_count < 0) then
    next_rd_count <= rd_count;
  else
    if (next_rd_addr_int < 0 or rcmp_addr < 0) then
      next_rd_count <= -1;
    elsif (next_rd_addr_int > rcmp_addr) then
      next_rd_count <= rollover - (next_rd_addr_int - rcmp_addr );
    else
      next_rd_count <= (rcmp_addr - next_rd_addr_int);
    end if;      
  end if;

end process mk_next_rd_count;

-- 

mk_pop_next_error : process (pop_req_n_int, rd_count, rd_addr_int, pop_error_int)
begin  -- process mk_pop_next_error
  if (err_mode < 1 and pop_error_int /= '0') then
    next_pop_error_int <= pop_error_int;
  else
    if ((pop_req_n_int = '0') and (rd_count = 0)) then
      next_pop_error_int <= '1';
    else
      if (rd_count >= 0) AND (rd_addr_int >= 0) then
        next_pop_error_int <= '0';
      else
        next_pop_error_int <= 'X';
      end if;
    end if;
  end if;
end process mk_pop_next_error;

clk_pop_registers : process (clk_pop, a_rst_n)
begin  
  if (To_X01(a_rst_n) = '0') then
    rd_addr_int <= 0;
    rd_count <= 0;
    pop_error_int  <= '0' ;
    sync_waddr1 <= 0;
    sync_waddr2 <= 0;
    rcmp_addr <= 0;
    pop_error_int  <= '0';
  elsif (To_X01(a_rst_n) = '1') then
    if (rising_edge(clk_pop)) then
      if (To_X01(s_rst_n) = '0') then
	rd_addr_int <= 0;
	rd_count <= 0;
	pop_error_int  <= '0' ;
	sync_waddr1 <= 0;
	sync_waddr2 <= 0;
	rcmp_addr <= 0;
	pop_error_int  <= '0';
      elsif (To_X01(s_rst_n) = '1') then
        rd_addr_int <= next_rd_addr_int;
        rd_count <= next_rd_count;
        pop_error_int  <= next_pop_error_int ;
        if (pop_sync = 1 ) then
          rcmp_addr <= wr_addr_smpl;
        else
          sync_waddr1 <= wr_addr_smpl;

	  if (pop_sync = 2) then
            rcmp_addr <= sync_waddr1;
	
	  else
	    sync_waddr2 <= sync_waddr1;
	    rcmp_addr <= sync_waddr2;
	  end if;
	end if;
      else
	pop_error_int  <= 'X';
	rd_addr_int <= -1;
	rd_count <= -1;
	pop_error_int  <= 'X' ;
	sync_waddr1 <= -1;  
	sync_waddr2 <= -1;  
	rcmp_addr <= -1;
      end if;
    end if;
  else
    pop_error_int  <= 'X';
    rd_addr_int <= -1;
    rd_count <= -1;
    pop_error_int  <= 'X' ;
    sync_waddr1 <= -1;  
    sync_waddr2 <= -1;  
    rcmp_addr <= -1;
  end if;
end process clk_pop_registers;

-- 

mk_pop_flags : process (rd_count)
begin  -- process mk_pop_flags
  if (rd_count < 0) then
    pop_empty <= 'X';
    pop_ae <= 'X';
    pop_hf <= 'X';
    pop_af <= 'X';
    pop_full <= 'X';
    pop_word_count <= (others => 'X');
  else
    if (rd_count = 0)              then pop_empty <= '1'; else pop_empty <= '0'; end if;
    if (rd_count <= pop_ae_lvl)    then pop_ae    <= '1'; else pop_ae    <= '0'; end if;
    if (rd_count < (depth+1)/2)    then pop_hf    <= '0'; else pop_hf    <= '1'; end if;
    if (rd_count < depth-pop_af_lvl) then pop_af  <= '0'; else pop_af    <= '1'; end if;
    if (rd_count /= depth)         then pop_full  <= '0'; else pop_full  <= '1'; end if;
    pop_word_count <= std_logic_vector(CONV_UNSIGNED(rd_count,addr_width));
  end if;
end process mk_pop_flags;


  clk_push_monitor  : process (clk_push) begin

    assert NOT (Is_X( clk_push ) AND (now > 0 ns)) 
      report "WARNING: Detected unknown value on the clock input port clk_push."
      severity warning;

  end process clk_push_monitor ;

  clk_pop_monitor  : process (clk_pop) begin

    assert NOT (Is_X( clk_pop ) AND (now > 0 ns)) 
      report "WARNING: Detected unknown value on the clock input port clk_pop."
      severity warning;

  end process clk_pop_monitor ;  
  
-- pragma translate_on
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_fifoctl_s2_sf_cfg_sim of DW_fifoctl_s2_sf is
 for sim
 end for; -- sim
end DW_fifoctl_s2_sf_cfg_sim;
-- pragma translate_on

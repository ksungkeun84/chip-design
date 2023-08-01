--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2000 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Reto Zimmermann        Jul 10, 2000 
--
-- VERSION:   VHDL Simulation Architecture
--
-- DesignWare_version: 94beca38
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Arbiter with First-Come-First-Served priority scheme
-- 
-- MODIFIED:
--          01/06/2002      RPH    Fixed the X-processing. STAR 119685
--          10/13/2010      RJK    Corrected "lock while in park state" issue
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;


architecture sim of DW_arb_fcfs is
	

  type priority_type is array (n-1 downto 0) of integer;

  function init_priorities return priority_type is
    variable priority_v : priority_type;
  begin
    if ( 2**(bit_width(n)) = n ) then
      for i in 0 to n-1 loop
        priority_v(i) := 2**bit_width(n)-1;
      end loop;
    else
      for i in 0 to n-1 loop
        priority_v(i) := 2**bit_width(n)-2;
      end loop;      
    end if;

    return priority_v;
  end init_priorities;

  function decode (a : integer) return std_logic_vector is
    variable z : std_logic_vector(n-1 downto 0) := (others => '0');
  begin
    if (a >= 0) and (a < n) then
      z(a) := '1';
    end if;
    return z;
  end decode;

  -- purpose: if 2's power return n-1 else 2**bit_width(n)-2
  function get_max_pri (n : integer) return integer is
    variable maxpri : integer;
  begin  -- get_max_pri
    if ( 2**(bit_width(n)) = n ) then
      maxpri := n-1;
    else
      maxpri := 2**bit_width(n)-2;
    end if;
    return maxpri;
  end get_max_pri;
    
    
  constant max_priority : integer range 0 to 2**bit_width(n)-1 := get_max_pri(n);
  signal priority_int, priority_next : priority_type;
  signal grant_index_int, grant_index_next : integer;
  signal parked_next, granted_int, granted_next, locked_next : std_logic;
  signal parked_int,locked_int : std_logic;

begin

  -- pragma translate_off

  -----------------------------------------------------------------------------
  -- Behavioral model
  -----------------------------------------------------------------------------

  arbitrate: process (grant_index_int, granted_int, lock, mask, priority_int,
                      request)
    variable request_masked_v : std_logic_vector(n-1 downto 0);
    variable grant_index_v : integer;
    variable parked_v, granted_v, locked_v : std_logic;
    variable priority_v : priority_type;
    variable update_priorities_v : boolean;
  begin
      grant_index_v       := -1;
      parked_v            := '0';
      granted_v           := '0';
      locked_v            := '0';
      priority_v          := priority_int;
      update_priorities_v := false;
      request_masked_v    := request and not mask;
      if (grant_index_int < -1 and lock /=  (n-1 downto 0 => '0')) then
        grant_index_v := -2;
        parked_v      := 'X';
        granted_v     := 'X';
        locked_v      := 'X'; 
      elsif grant_index_int >= 0 and (granted_int and lock(grant_index_int)) /= '0' then
        if ((granted_int and lock(grant_index_int)) = '1') then
          grant_index_v := grant_index_int;
          locked_v      := '1';
          granted_v     := '1';
          if granted_int = '0' then
            update_priorities_v := true;
          end if;
        else
          grant_index_v := -2;
          granted_v     := 'X';
          locked_v      := 'X';
          granted_v     := 'X';
          parked_v      := '0';
        end if;
      elsif request_masked_v /= (n-1 downto 0 => '0') then
         if (Is_X(request_masked_v) ) then
           grant_index_v := -2;
           granted_v     := 'X';
           locked_v      := 'X';
           granted_v     := 'X';
         else                                   
           for i in 0 to n-1 loop
             if request_masked_v(i) = '1' then
               if grant_index_v < 0 or priority_int(i) < priority_int(grant_index_v) then
                 grant_index_v := i;
               end if;
             end if;
           end loop;
           granted_v := '1';
           update_priorities_v := true;
         end if;
      elsif park_mode = 1 then
        grant_index_v := park_index;
        parked_v      := '1';
      else
        grant_index_v := -1;
      end if;
      
      for i in 0 to n-1 loop
        if i = grant_index_v then
          priority_v(i) := max_priority;
        elsif request_masked_v(i) = '1' then
          if update_priorities_v then
            priority_v(i) := priority_int(i) - 1;
          end if;
        else
          priority_v(i) := max_priority;
        end if;
      end loop;
      
    grant_index_next <= grant_index_v;
    parked_next      <= parked_v;
    granted_next     <= granted_v;
    locked_next      <= locked_v;
    priority_next    <= priority_v;
  end process arbitrate;

  grant_register: process (clk, rst_n)
  begin
    if rst_n = '0' then
      grant_index_int <= -1;
      parked_int      <= '0';
      granted_int     <= '0';
      locked_int      <= '0';
      priority_int    <= init_priorities;
    elsif rst_n = '1' then
      if init_n = '0' then
        grant_index_int <= -1;
        parked_int      <= '0';
        granted_int     <= '0';
        locked_int      <= '0';
        priority_int    <= init_priorities;
      elsif init_n = '1' then
        if rising_edge(clk) then
          if(enable = '1') then
            grant_index_int <= grant_index_next;
            parked_int      <= parked_next;
            granted_int     <= granted_next;
            locked_int      <= locked_next;
            priority_int    <= priority_next;
          end if;
        end if;
      else
        grant_index_int <= -2;
        parked_int      <= 'X';
        granted_int     <= 'X';
        locked_int      <= 'X';
        priority_int    <= (others => -1);
      end if;
    else
      grant_index_int <= -2;
      parked_int      <= 'X';
      granted_int     <= 'X';
      locked_int      <= 'X';
      priority_int    <= (others => -1);
    end if;
  end process grant_register;

  grant <= (others => 'X') when grant_index_int = -2 else
           decode(-1) when (grant_index_next = -1 and output_mode = 0) else
           decode (grant_index_next) when output_mode = 0 else
           decode (grant_index_int);
  grant_index <= (others => 'X') when grant_index_int = -2 else
                 (others => '1') when (grant_index_int = -1 and output_mode = 1) else
                 (others => '1') when (grant_index_next = -1 and output_mode = 0) else
                 std_logic_vector(conv_signed(grant_index_next, bit_width(n))) when output_mode = 0 else
                 std_logic_vector(conv_signed(grant_index_int, bit_width(n)));
  granted <= granted_next when output_mode = 0 else 
             granted_int;
  parked <= parked_next when output_mode = 0 else
            parked_int;
  locked <= locked_next when output_mode = 0 else
            locked_int;    
  -----------------------------------------------------------------------------
  -- Parameter legality check
  -----------------------------------------------------------------------------
  
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
    
    if ( (n < 2) OR (n > 32) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter n (legal range: 2 to 32)"
        severity warning;
    end if;
    
    if ( (park_mode < 0) OR (park_mode > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter park_mode (legal range: 0 to 1)"
        severity warning;
    end if;
    
    if ( (park_index < 0) OR (park_index > n-1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter park_index (legal range: 0 to n-1)"
        severity warning;
    end if;
    
    if ( (output_mode < 0) OR (output_mode > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter output_mode (legal range: 0 to 1)"
        severity warning;
    end if;
  
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;


  -----------------------------------------------------------------------------
  -- Report unknown clock inputs
  -----------------------------------------------------------------------------
  
  clk_monitor  : process (clk) begin

    assert NOT (Is_X( clk ) AND (now > 0 ns)) 
      report "WARNING: Detected unknown value on the clock input port clk."
      severity warning;

  end process clk_monitor ;

  -- pragma translate_on

end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_arb_fcfs_cfg_sim of DW_arb_fcfs is
 for sim
 end for; -- sim
end DW_arb_fcfs_cfg_sim;
-- pragma translate_on

--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2003 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Zhijun (Jerry) Huang      08/04/2003
--
-- VERSION:   VHDL Simulation Model for DW_fir_seq
--
-- DesignWare_version: 6cf490c8
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT: Sequential Digital FIR Filter Processor 
--
-- MODIFIED: Zhijun (Jerry) Huang      09/11/2003
--           When coef_shift_en = 1, change
--               hold_int <= '1';
--           to
--               hold_ctl := '1';
--               hold_int <= hold_ctl;
--            so that when coef_shift_en changes to 0, 
--            hold stays at 1 until run becomes 1
--
--           Zhijun (Jerry) Huang      09/16/2003
--           reversed the order of coefficient register signals
--           so that coef(0) is loaded first
--           added register with enable "run" for init_acc_val
--
--------------------------------------------------------------------------------
library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use DWARE.DWpackages.all;

architecture sim of DW_fir_seq is
	
-- pragma translate_off

  -- addr_with is log2(order)
  constant addr_width : integer := bit_width(order);
  
  signal sample_data : std_logic_vector(data_in_width-1 downto 0);
  signal coef_data : std_logic_vector(coef_width-1 downto 0);
  signal coef_addr, data_read_addr, data_write_addr : 
                    std_logic_vector(addr_width-1 downto 0);  
  signal start_int, hold_int : std_logic;  

  subtype SAMPLE_WORD is std_logic_vector(data_in_width-1 downto 0);
  type SAMPLE_ARRAY is array (order-1 downto 0) of SAMPLE_WORD;
  signal sample_mem : SAMPLE_ARRAY;
  subtype COEF_WORD is std_logic_vector(coef_width-1 downto 0);
  type COEF_ARRAY is array (order-1 downto 0) of COEF_WORD;
  signal coef_mem : COEF_ARRAY;
  signal init_acc_val_reg : std_logic_vector(data_out_width-1 downto 0);
  signal sum_acc : std_logic_vector(data_out_width-1 downto 0); 
-- pragma translate_on
  
begin
-- pragma translate_off

  
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
    
    if (data_in_width < 1) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter data_in_width (lower bound: 1)"
        severity warning;
    end if;
    
    if (coef_width < 1) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter coef_width (lower bound: 1)"
        severity warning;
    end if;
    
    if (data_out_width < 1) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter data_out_width (lower bound: 1)"
        severity warning;
    end if;
    
    if ( (order < 2) OR (order > 256) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter order (legal range: 2 to 256)"
        severity warning;
    end if;
  
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;

  start <= start_int;
  hold <= hold_int;    

  CTL_PROC : process(rst_n, clk)
    variable cycle_ctr : integer range 0 to order+1;
    variable run_last, start_ctl, hold_ctl : std_logic;
    variable coef_read_ptr, data_read_ptr, data_write_ptr:
                       integer range 0 to order-1;
  begin
    if (To_X01(rst_n) = '0') then
      cycle_ctr := 0;
      coef_read_ptr := 0;
      data_read_ptr := 0;      
      data_write_ptr := 0;            
      start_ctl := '0';
      hold_ctl := '0';
      run_last := '0';

      start_int <= '0';
      hold_int <= '0';
      coef_addr <= (others => '0');
      data_write_addr <= (others => '0');
      data_read_addr <= (others => '0');            
    elsif (To_X01(rst_n) = '1') then  
  
      if rising_edge(clk) then
        if (Is_X(coef_shift_en) or Is_X(run)) then 
          start_int <= 'X';
          hold_int <= 'X';
          coef_addr <= (others => 'X');
          data_write_addr <= (others => 'X');
          data_read_addr <= (others => 'X');
          
        elsif (To_X01(coef_shift_en) = '0') then

          -- detect rising EDGE of run 
          --   reset cycle counter
          --   turn off the accumulator hold
          --   turn on the start control
          if run_last = '0' and run = '1' then  
            cycle_ctr := 0;
            start_ctl := '1';
            hold_ctl := '0';
            data_read_ptr := data_write_ptr; 
            if data_write_ptr = order-1 then
              data_write_ptr := 0;
            else
                data_write_ptr := data_write_ptr+1;
            end if;
            coef_read_ptr := 0;
            run_last := '1';
          end if;

          if run = '0' then
            run_last := '0';
          end if;

          coef_addr <= dw_conv_std_logic_vector(coef_read_ptr, addr_width);
          data_read_addr <= dw_conv_std_logic_vector(data_read_ptr, addr_width);
          data_write_addr <= dw_conv_std_logic_vector(data_write_ptr, addr_width);

          if cycle_ctr > 0 then
            -- turn off start control signal after first 
            -- clk cycle of sample processing cycle
            start_ctl := '0';
          end if;

          if cycle_ctr = order then  
            hold_ctl := '1';
          end if;

          if cycle_ctr < order-1 then 
            if data_read_ptr = 0 then
              data_read_ptr := order-1;  -- wraparound 
            else
              data_read_ptr := data_read_ptr-1;      
            end if;
            coef_read_ptr := coef_read_ptr+1;
          end if;

          if cycle_ctr < order then
            cycle_ctr := cycle_ctr+1;
          end if;

          hold_int <= hold_ctl;
          start_int <= start_ctl;

        else -- (To_X01(coef_shift_en) = '1')
          -- freeze accumulator during coefficient coef_shift_en mode
          hold_ctl := '1';
          hold_int <= hold_ctl;
          data_write_ptr := 0;
          data_write_addr <= dw_conv_std_logic_vector(data_write_ptr, addr_width);        
        end if;  -- To_X01(coef_shift_en)        
      end if;  -- -- rising_edge(clk)
    
    else -- To_X01(rst_n) = 'X'
      start_int <= 'X';
      hold_int <= 'X';
      coef_addr <= (others => 'X');
      data_write_addr <= (others => 'X');
      data_read_addr <= (others => 'X');      
    end if; -- rst
    
  end process CTL_PROC; 
  
    
  sample_mem_PROC : process (clk, rst_n)
   variable addr_int : integer; 
  begin     
    if (To_X01(rst_n) = '0') then
      sample_mem <= (others => (others => '0'));      
    elsif (To_X01(rst_n) = '1') then

      if rising_edge(clk) then
        addr_int := CONV_INTEGER(UNSIGNED(data_write_addr)); 
      
        if (Is_X(run) or Is_X(data_write_addr)) then 
          sample_mem <= (others => (others => 'X'));
        elsif (To_X01(run) = '0') then
          sample_mem(addr_int) <= sample_mem(addr_int); 
        else  -- (To_X01(run) = '1')
          if (Is_X(data_in)) then 
            sample_mem(addr_int) <= (others => 'X'); 
          else 
            sample_mem(addr_int) <= data_in;
          end if; 
        end if;
      end if; -- rising_edge(clk)
      
    else -- To_X01(rst_n) = 'X'
      sample_mem <= (others => (others => 'X'));
    end if;
  end process sample_mem_PROC;  
  
  sample_data <= (others => 'X') when (Is_X(rst_n) or Is_X(data_read_addr)) else
                 sample_mem(CONV_INTEGER(UNSIGNED(data_read_addr)));


  coef_mem_PROC : process (clk, rst_n)
  begin
    if (To_X01(rst_n) = '0') then
      coef_mem <= (others => (others => '0'));
    elsif (To_X01(rst_n) = '1') then

      if rising_edge(clk) then
        if (To_X01(coef_shift_en) = '0') then
          for i in order-1 downto 0 loop
            coef_mem(i) <= coef_mem(i);
          end loop;
        elsif (To_X01(coef_shift_en) = '1') then
          coef_mem(order-1) <= coef_in;
          for i in order-2 downto 0 loop
            coef_mem(i) <= coef_mem(i+1);
          end loop;
        else
          coef_mem <= (others => (others => 'X')); 
        end if;
      end if; -- rising_edge(clk)

    else -- To_X01(rst_n) = 'X'
      coef_mem <= (others => (others => 'X'));
    end if;
  end process coef_mem_PROC; 
    
  coef_data <= (others => 'X') when (Is_X(rst_n) or Is_X(coef_addr)) else
                 coef_mem(CONV_INTEGER(UNSIGNED(coef_addr)));    


  au_PROC : process (clk, rst_n)
    variable sum_in : std_logic_vector(data_out_width-1 downto 0);  
    variable data_tc : signed(data_in_width-1 downto 0);  
    variable data_uns : unsigned(data_in_width-1 downto 0);  
    variable coef_tc : signed(coef_width-1 downto 0);    
    variable coef_uns : unsigned(coef_width-1 downto 0);      
    variable sum_tc : signed(data_out_width-1 downto 0);          
    variable sum_uns : unsigned(data_out_width-1 downto 0);
  begin
    if (To_X01(rst_n) = '0') then
      sum_acc <= (others => '0');
    elsif (To_X01(rst_n) = '1') then
      if rising_edge(clk) then      
      
        -- register for init_acc_val
        if (To_X01(run) = '0') then 
          init_acc_val_reg <= init_acc_val_reg;
        elsif (To_X01(run) = '1') then 
          init_acc_val_reg <= init_acc_val;
        else 
          init_acc_val_reg <= (others => 'X');
        end if;
        
        if (To_X01(hold_int) = '0') then          
          -- choose accumulator's input
          if (To_X01(start_int) = '0') then 
            sum_in := sum_acc;
          elsif (To_X01(start_int) = '1') then
            sum_in := init_acc_val_reg;
          else
            sum_in := (others => 'X');
          end if;
          
          -- multiply-accumulator
          if (Is_X(tc) or Is_X(sum_in) or 
              Is_X(sample_data) or Is_X(coef_data)) then
            sum_acc <= (others => 'X');
          elsif (To_X01(tc) = '0') then           -- unsigned case
            data_uns := UNSIGNED(sample_data); 
            coef_uns := UNSIGNED(coef_data);
            sum_uns := UNSIGNED(sum_in);
            sum_acc <= sum_uns + coef_uns * data_uns;
          else -- (To_X01(tc) = '1')              -- signed case
            data_tc := SIGNED(sample_data); 
            coef_tc := SIGNED(coef_data);
            sum_tc := SIGNED(sum_in);
            sum_acc <= sum_tc + coef_tc * data_tc;
          end if;
          
        elsif (To_X01(hold_int) = '1') then
          sum_acc <= sum_acc;
        else 
          sum_acc <= (others => 'X');
        end if; -- To_X01(hold_int)
      end if; -- rising_edge(clk)
    else
      sum_acc <= (others => 'X');
    end if; -- To_X01(rst_n)
  end process au_PROC;    

  data_out <= sum_acc;


  
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

configuration DW_fir_seq_cfg_sim of DW_fir_seq is
 for sim
 end for; -- sim
end DW_fir_seq_cfg_sim;
-- pragma translate_on

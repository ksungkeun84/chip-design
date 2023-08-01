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
-- AUTHOR:    Bob Tong                   May 1, 1998           
--
-- VERSION:   VHDL Simulation Model
--
-- DesignWare_version: 08854473
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  TAP Controller
--
--
--    Parameters: 	Valid Values
--    ==========  	============
--    width		[ 2 to 256 ]
--    id		[ 0 = not present,
--			  1 = present ]	
--    version		[ 0 to 15 ]
--    part		[ 0 to 65535 ] 
--    man_num		[ 0 to 2047 ] 
--   			( not equal to 127 ) 
--          
--    sync_mode		[ 0 = asynchronous,
--			  1 = synchrounous ] 	
--
--    tst_mode		[ 0 = no test mode,
--			  1 = test mode used ] 	
--
--  Input Ports:    Size    	Description
--  ===========     ====    	===========
--  tck		     1 bit   	Test clock 
--  trst_n	     1 bit   	Test reset, active low 
--  tms		     1 bit   	Test mode select 
--  tdi		     1 bit   	Test data in 
--  so		     1 bit   	Serial data from boundary scan 
--                          	  register and data registers 
--  bypass_sel	     1 bit   	Selects the bypass register 
--                         
--  sentinel_val    width - 1   User-defined status bits	
--
--  test             1 bit      Test input
--                         
--  Output Ports    Size    	Description
--  ============    ====    	===========
--  clock_dr	     1 bit      Controls the boundary scan register	
--  shift_dr	     1 bit      Controls the boundary scan register
--  update_dr	     1 bit	Controls the boundary scan register
--  tdo		     1 bit	Test data out
--  tdo_en	     1 bit 	Enable for tdo output buffer
--  tap_state       16 bit	Current state of the TAP 
--				  finite state machine
--  extest	     1 bit	EXTEST decoded instruction
--  samp_load	     1 bit	SAMPLE/PRELOAD decoded instruction
--  instructions    width	Instruction register output	
--
--
--
-- MODIFIED:
--
--   RJK 01/11/17  Added new tst_mode parameter and used it for disabling
--                 test input, avoiding unused clock selection logic.
--                 (STAR 9001134192)
--
--
-------------------------------------------------------------------------
library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use DWARE.DWpackages.all;

architecture sim of DW_tap is
	
  signal tck_int : std_logic;
  signal trst_n_int : std_logic;
  signal tms_int : std_logic;
  signal tdi_int: std_logic;
  signal so_int : std_logic;
  signal bypass_sel_int : std_logic;
  signal sentinel_int : std_logic_vector(width-2 downto 0);
  signal clock_dr_int : std_logic;
  signal shift_dr_int : std_logic;
  signal update_dr_int : std_logic;
  signal tdo_int : std_logic;
  signal tdo_en_int : std_logic;
  signal state_reg : std_logic_vector(15 downto 0) := (others =>'0');
  signal extest_int : std_logic;
  signal samp_load_int : std_logic;
  signal clock_ir : std_logic;
  signal shift_ir : std_logic;
  signal update_ir : std_logic;
  signal tck_n : std_logic;
  signal instr_rst : std_logic;
  signal fsm_rst : std_logic;
  signal logic_one : std_logic := '1';
  signal logic_zero : std_logic := '0';
  signal capture_clk_dr : std_logic;
  signal capture_dr : std_logic;
  signal capture_en_dr : std_logic;
  signal data_in_int : std_logic;
  signal bypass_so : std_logic;
 
  signal capture_reg_dr_msb : std_logic;
  signal capture_reg_dr : std_logic_vector(32 downto 0);
  signal id_code_vec : std_logic_vector(31 downto 0);
 
  constant version_vec : std_logic_vector(4 downto 0) :=
                         dw_conv_std_logic_vector(version,5);
  constant part_vec : std_logic_vector(16 downto 0) :=
                         dw_conv_std_logic_vector(part,17);
  constant man_num_vec : std_logic_vector(11 downto 0) :=
                         dw_conv_std_logic_vector(man_num,12);
   
  signal capture_clk_ir : std_logic;
  signal update_clk_ir : std_logic;
  signal capture_en_ir : std_logic;
 
  signal capture_reg_ir_msb : std_logic;
  signal capture_reg_ir : std_logic_vector(width downto 0);
  signal update_reg_ir : std_logic_vector(width - 1 downto 0);
  signal instr_so : std_logic;
 
  signal update_reg_ir_temp : std_logic := '1';
  signal update_reg_ir_temp_n : std_logic := '0';
  signal update_reg_ir_temp_by : std_logic := '1';
  signal id_sel : std_logic;
  signal bypass_int : std_logic;
  signal tdo_temp : std_logic;
  signal id_so : std_logic;
  signal sync_capture_ir : std_logic;

begin
-- pragma translate_off
  tck_int <= To_01X(tck);
  tck_n <= To_01X(tck) when ((tst_mode=1) AND (test='1'))
                       else (not tck);
  trst_n_int <= To_01X(trst_n);
  tms_int <= To_01X(tms);
  tdi_int <= To_01X(tdi);
  so_int <= To_01X(so);
  bypass_sel_int <= To_01X(bypass_sel);
  sentinel_int <= sentinel_val;
  G_SM_EQ_0: if (sync_mode = 0) generate
    clock_dr <= clock_dr_int;
    update_dr <= update_dr_int;
  end generate G_SM_EQ_0;
  shift_dr <= shift_dr_int;
  tdo <= tdo_int;
  tdo_en_int <= (shift_dr_int or shift_ir);
  tdo_en <= tdo_en_int;
  tap_state <= state_reg;
  extest <= extest_int;
  samp_load <= samp_load_int;
  sync_capture_en <= (shift_dr_int nor (state_reg(3) or state_reg(4)));
  sync_capture_ir <= (shift_ir nor (state_reg(10) or state_reg(11)));
  sync_update_dr <= (state_reg(8));
  clock_dr_int <= (tck_int or (tck_int nor (state_reg(3) or state_reg(4)))
                   or not (state_reg(3) or state_reg(4)));
  clock_ir <= (tck_int or (tck_int nor (state_reg(10) or state_reg(11)))
               or not (state_reg(10) or state_reg(11)));
  update_dr_int <= (tck_n and state_reg(8));
  update_ir <= (tck_n and state_reg(15));
  instr_rst <= not trst_n when ((tst_mode=1) AND (test = '1'))
                          else (fsm_rst or not(trst_n));
  data_in_int <= (tdi_int and shift_dr_int);
 
  id_code_vec <= version_vec(3 downto 0) &
                 part_vec(15 downto 0) &
                 man_num_vec(10 downto 0) & '1';
  capture_reg_dr_msb <= To_01X(tdi);
  id_so <= capture_reg_dr(0);
 
  capture_reg_ir_msb <= To_01X(tdi);
  instr_so <= capture_reg_ir(0);
  instructions <= update_reg_ir;
  id_sel <= ( (update_reg_ir(0)) and (not update_reg_ir(1))
                    and (not update_reg_ir_temp_n) );
  extest_int <= ( (not update_reg_ir(0)) and (not update_reg_ir(1))
                    and (not update_reg_ir_temp_n) );
  bypass_int <= ( update_reg_ir(0) and update_reg_ir(1)
                    and update_reg_ir_temp_by );
  samp_load_int <= ( (not update_reg_ir(0)) and update_reg_ir(1)
                    and (not update_reg_ir_temp) ) ;
  capture_clk_dr <= clock_dr_int 
    when (sync_mode = 0) else tck_int;
  capture_en_dr <= logic_zero 
    when (sync_mode = 0) else clock_dr_int;
  capture_clk_ir <= clock_ir
    when (sync_mode = 0) else tck_int;
  capture_en_ir <= logic_zero
    when (sync_mode = 0) else sync_capture_ir;
  update_clk_ir <= update_ir
    when (sync_mode = 0) else tck_n;
 
next_state_proc : process
  variable state_var : integer range 0 to 15;
  begin
    for i in 15 downto 0 loop
      if (state_reg(i) = '1') then
        state_var := i;
      end if;
    end loop;
    if (trst_n_int = '0' or trst_n_int = 'X') then
      state_var := 0;
    elsif (tck_int = '1' and tck_int'EVENT) then
      if ( (tms_int = '0') or (tms_int = 'X') ) then
        case (state_var) is
          when 0 =>  
            state_var := 1;
          when 2 =>
            state_var := 3;
          when 3 =>
            state_var := 4;
          when 5 =>
            state_var := 6;
          when 7 =>  
            state_var := 4;
          when 8 =>  
            state_var := 1;
          when 9 =>  
            state_var := 10;
          when 10 =>
            state_var := 11;
          when 12 =>
            state_var := 13;
          when 14 =>  
            state_var := 11;
          when 15 =>
            state_var := 1;
          when others =>
            null;
        end case;
      elsif (tms_int = '1') then
        case (state_var) is
          when 1 =>  
            state_var := 2;
          when 2 =>
            state_var := 9;
          when 3 =>  
            state_var := 5;
          when 4 =>
            state_var := 5;
          when 5 =>  
            state_var := 8;
          when 6 =>  
            state_var := 7;
          when 7 =>  
            state_var := 8;
          when 8 =>  
            state_var := 2;
          when 9 =>
            state_var := 0;
          when 10 =>
            state_var := 12;
          when 11 =>
            state_var := 12;
          when 12 =>  
            state_var := 15;
          when 13 =>  
            state_var := 14;
          when 14 =>  
            state_var := 15;
          when 15 =>  
            state_var := 2;
          when others =>
            null;
        end case; 
      end if;
    end if;
    for i in 15 downto 0 loop
      if (state_var = i ) then
        state_reg(i) <= '1';
      else
        state_reg(i) <= '0';
      end if;
    end loop;
    wait until (tck_int'EVENT or trst_n_int'EVENT); 
end process next_state_proc;

output1_proc : process
  variable shift_dr_var : std_logic := '0';
  variable shift_ir_var : std_logic := '0';
  variable fsm_rst_var : std_logic := '0';
  variable state_var : integer range 0 to 15;
  begin
    if (trst_n_int = '0' or trst_n_int = 'X') then
      fsm_rst <= '1';
      shift_dr_int <= '0';
      shift_ir <= '0';
    else
      for i in 15 downto 0 loop
        if (state_reg(i) = '1') then
          state_var := i;
        end if;
      end loop; 
      case (state_var) is
        when 0 =>
          fsm_rst_var := '1';
          shift_dr_var := '0';
          shift_ir_var := '0';
        when 4 =>
          fsm_rst_var := '0';
          shift_dr_var := '1';
          shift_ir_var := '0';
        when 11 =>
          fsm_rst_var := '0';
          shift_dr_var := '0';
          shift_ir_var := '1';
        when others =>
          fsm_rst_var := '0';
          shift_dr_var := '0';
          shift_ir_var := '0';
      end case;
      if (tck_n = '1' or (tck_n = 'X'
           and tck_n'last_value = '0') ) then
        if (tck_n'last_value = 'X' or (tck_n = 'X'
            and tck_n'last_value = '0')) then
          if (fsm_rst_var /= fsm_rst) then
              fsm_rst <= 'X';
          end if;
          if (shift_dr_var /= shift_dr_int) then
              shift_dr_int <= 'X';
          end if;
          if (shift_ir_var /= shift_ir) then
              shift_ir <= 'X';
          end if;
        else
          fsm_rst <= fsm_rst_var;
          shift_dr_int <= shift_dr_var;
          shift_ir <= shift_ir_var;
        end if;
      end if;
    end if;
    wait until (tck_n'EVENT or trst_n_int'EVENT);
end process output1_proc;

bypass_seq1_proc : process
  begin
    capture_dr <= state_reg(3);
    if (capture_clk_dr = '1' or (capture_clk_dr = 'X'
        and capture_clk_dr'last_value = '0') ) then
      if (capture_dr = '0') then
        if (capture_en_dr = '0') then
          if (capture_clk_dr'last_value = 'X' or (capture_clk_dr = 'X'
              and capture_clk_dr'last_value = '0')) then
            if (data_in_int /= bypass_so) then
              bypass_so <= 'X';
            end if;
          else
            bypass_so <= data_in_int;
          end if;
        elsif (capture_en_dr = 'X') then
          if (data_in_int /= bypass_so ) then
            bypass_so <= 'X';
          end if;
        end if;
      elsif (capture_dr = '1') then
        if (capture_clk_dr'last_value = 'X' or (capture_clk_dr = 'X'
              and capture_clk_dr'last_value = '0')) then
          if (bypass_so /= '0') then
            bypass_so <= 'X';
          end if;
        else
          bypass_so <= '0';
        end if;
      end if;
    end if;
    wait until capture_clk_dr'EVENT;
end process bypass_seq1_proc;
 
idreg_seq1_proc : process
  begin
    capture_reg_dr(32) <= capture_reg_dr_msb;
    if (capture_clk_dr'EVENT) then
      for i in 31 downto 0 loop
        if (capture_clk_dr = '1' or (capture_clk_dr = 'X'
            and capture_clk_dr'last_value = '0') ) then
          if (capture_en_dr = '0') then
            if (shift_dr_int = '0') then
              if (capture_clk_dr'last_value = 'X' or (capture_clk_dr = 'X'
                  and capture_clk_dr'last_value = '0')) then
                if (id_code_vec(i) /= capture_reg_dr(i)) then
                  capture_reg_dr(i) <= 'X';
                end if;
              else
                capture_reg_dr(i) <= id_code_vec(i);
              end if;
            elsif (shift_dr_int = '1') then
              if (capture_clk_dr'last_value = 'X' or (capture_clk_dr = 'X'
                  and capture_clk_dr'last_value = '0')) then
                if (capture_reg_dr(i+1) /= capture_reg_dr(i)) then
                  capture_reg_dr(i) <= 'X';
                end if;
              else
                capture_reg_dr(i) <= capture_reg_dr(i+1);
              end if;
            elsif (capture_reg_dr(i+1) /= id_code_vec(i)) then
              capture_reg_dr(i) <= 'X';
            elsif (capture_clk_dr'last_value = 'X' or (capture_clk_dr = 'X'
                   and capture_clk_dr'last_value = '0')) then
              if (capture_reg_dr(i+1) /= capture_reg_dr(i)) then
                capture_reg_dr(i) <= 'X';
              end if;
            else
              capture_reg_dr(i) <= capture_reg_dr(i+1);
            end if;
          elsif (capture_en_dr = 'X') then
            if (shift_dr_int = '0') then
              if (id_code_vec(i) /= capture_reg_dr(i)) then
                capture_reg_dr(i) <= 'X';
              end if;
            elsif (shift_dr_int = '1') then
              if (capture_reg_dr(i+1) /= capture_reg_dr(i)) then
                capture_reg_dr(i) <= 'X';
              end if;
            elsif (capture_reg_dr(i+1) = id_code_vec(i)) then
              if (capture_reg_dr(i+1) /= capture_reg_dr(i)) then
                capture_reg_dr(i) <= 'X';
              end if;
            else
              capture_reg_dr(i) <= 'X';
            end if;
          end if;
        end if;
      end loop;
    end if;
    wait until (capture_clk_dr'EVENT or capture_reg_dr_msb'EVENT); 
end process idreg_seq1_proc;

instrreg_seq1_proc : process
  variable data_in_ir : std_logic_vector(width-1 downto 0);
  begin
    capture_reg_ir(width) <= capture_reg_ir_msb;
    if (capture_clk_ir'EVENT) then   
      for i in width-1 downto 0 loop
        if ( i > 1 ) then
          data_in_ir(i) := sentinel_int(i-2);
        else
          data_in_ir(1) := '0';
          data_in_ir(0) := '1';
        end if;
        if (capture_clk_ir = '1' or (capture_clk_ir = 'X'
              and capture_clk_ir'last_value = '0') ) then
            if (capture_en_ir = '0') then
              if (shift_ir = '0') then
                if (capture_clk_ir'last_value = 'X' or (capture_clk_ir = 'X'
                    and capture_clk_ir'last_value = '0')) then
                  if (data_in_ir(i) /= capture_reg_ir(i)) then
                    capture_reg_ir(i) <= 'X';
                  end if;
                else
                  capture_reg_ir(i) <= data_in_ir(i);
                end if;
              elsif (shift_ir = '1') then
                if (capture_clk_ir'last_value = 'X' or (capture_clk_ir = 'X'
                    and capture_clk_ir'last_value = '0')) then
                  if (capture_reg_ir(i+1) /= capture_reg_ir(i)) then
                    capture_reg_ir(i) <= 'X';
                  end if;
                else
                  capture_reg_ir(i) <= capture_reg_ir(i+1);
                end if;
              elsif (capture_reg_ir(i+1) /= data_in_ir(i)) then
                capture_reg_ir(i) <= 'X';
              elsif (capture_clk_ir'last_value = 'X' or (capture_clk_ir = 'X'
                     and capture_clk_ir'last_value = '0')) then
                if (capture_reg_ir(i+1) /= capture_reg_ir(i)) then
                  capture_reg_ir(i) <= 'X';
                end if;
              else
                capture_reg_ir(i) <= capture_reg_ir(i+1);
              end if;
            elsif (capture_en_ir = 'X') then
              if (capture_reg_ir(i+1) /= data_in_ir(i)) then
                capture_reg_ir(i) <= 'X';
              elsif (capture_reg_ir(i+1) /= capture_reg_ir(i)) then
                capture_reg_ir(i) <= 'X';
              end if;
            end if;
          end if;
      end loop;
    end if;
    wait until (capture_clk_ir'EVENT or capture_reg_ir_msb'EVENT); 
end process instrreg_seq1_proc;
 
instrreg_seq2_proc : process
  variable update_en_ir : std_logic; 
  begin
    if (sync_mode = 0) then
      update_en_ir := logic_one;
    else
      update_en_ir := (state_reg(15) and (tck_n));
    end if;
    if (instr_rst'EVENT) then 
      if (instr_rst = '1') then
        if (id = 0) then
          update_reg_ir <= (others => '1');
        elsif (id = 1) then
          update_reg_ir(width - 1 downto 1) <= (others => '0');
          update_reg_ir(0) <= '1';
        end if;
      elsif (instr_rst = 'X') then
        if (id = 0) then
          for i in width-1 downto 0 loop
            if (update_reg_ir(i) /= '1') then
              update_reg_ir(i) <= 'X';
            end if;
          end loop;
        elsif (id = 1) then
          for i in width-1 downto 1 loop
            if (update_reg_ir(i) /= '0') then
              update_reg_ir(i) <= 'X';
            end if;
          end loop;
          if (update_reg_ir(0) /= '1') then
            update_reg_ir(0) <= 'X';
          end if;
        end if;
      end if;
    else    
      for i in width-1 downto 0 loop
        if ((update_clk_ir = '1') or (update_clk_ir = 'X' 
		and update_clk_ir'last_value = '0')) then
          if (update_en_ir = '1' and instr_rst = '0') then
            if (update_clk_ir'last_value = 'X' or (update_clk_ir = 'X'
                  and update_clk_ir'last_value = '0')) then
              if (capture_reg_ir(i) /= update_reg_ir(i)) then
                  update_reg_ir(i) <= 'X';
              end if;
            else
              update_reg_ir(i) <= capture_reg_ir(i);
            end if;
          elsif (update_en_ir = 'X') then
            if (capture_reg_ir(i) /= update_reg_ir(i)) then
              update_reg_ir(i) <= 'X';
            end if;
          end if;
        end if;
      end loop;
    end if;
    wait until (update_clk_ir'EVENT or instr_rst'EVENT);
end process instrreg_seq2_proc;

tdo_combo1_proc : process
  begin
    if ((bypass_sel_int = '1') or (bypass_int = '1')) then
      tdo_temp <= bypass_so;
    elsif (id = 1 and id_sel = '1') then
      tdo_temp <= id_so;
    else 
      tdo_temp <= so_int;      
    end if;
    wait until (bypass_sel_int'EVENT or bypass_int'EVENT or id_so'EVENT
                or id_sel'EVENT or so_int'EVENT or bypass_so'EVENT);
end process tdo_combo1_proc;

instr_decode1_proc : process
  variable update_reg_ir_temp_n_var : std_logic;
  variable update_reg_ir_temp_var : std_logic;
  variable update_reg_ir_temp_by_var : std_logic;
  begin
    update_reg_ir_temp_n_var := update_reg_ir(width-1);
    update_reg_ir_temp_var := update_reg_ir(width-1);
    update_reg_ir_temp_by_var := update_reg_ir(width-1);
    if (width > 2) then 
      for i in width-1 downto 2 loop
        update_reg_ir_temp_var := (update_reg_ir_temp_var or update_reg_ir(i));
        update_reg_ir_temp_n_var := (update_reg_ir_temp_n_var or update_reg_ir(i));
        update_reg_ir_temp_by_var := (update_reg_ir_temp_by_var and update_reg_ir(i));
      end loop;
    else
      update_reg_ir_temp_var := (not update_reg_ir(1));
    end if;
    update_reg_ir_temp_n <= update_reg_ir_temp_n_var;
    update_reg_ir_temp <= update_reg_ir_temp_var;
    update_reg_ir_temp_by <= update_reg_ir_temp_by_var;
    wait until update_reg_ir'EVENT;
end process instr_decode1_proc;

select_seq1_proc : process
 
  begin
    if (tck_n = '1' or (tck_n = 'X'
        and tck_n'last_value = '0') ) then
      if (state_reg(11) = '0') then
        if (tck_n'last_value = 'X' or (tck_n = 'X'
            and tck_n'last_value = '0')) then
          if (tdo_temp /= tdo_int) then
            tdo_int <= 'X';
          end if;
        else
          tdo_int <= tdo_temp;
        end if;
      elsif (state_reg(11) = '1') then
        if (tck_n'last_value = 'X' or (tck_n = 'X'
            and tck_n'last_value = '0')) then
          if (instr_so /= tdo_int) then
            tdo_int <= 'X';
          end if;
        else
          tdo_int <= instr_so;
        end if;
      end if;
    end if;
    wait until tck_n'EVENT;
end process select_seq1_proc;
 
-- pragma translate_on
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_tap_cfg_sim of DW_tap is
 for sim
 end for; -- sim
end DW_tap_cfg_sim;
-- pragma translate_on

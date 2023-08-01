--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 1992 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    GN                 Jan. 24, 1994
--
-- VERSION:   simulation architecture 'sim'
--
-- DesignWare_version: f114eb10
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  LFSR Counter with Dynamic Count-to Flag
--           Programmable wordlength (width in integer range 1 to 50)
--           positive edge-triggering clock: clk  
--           asynchronous reset(active low): reset
--           updn = '1' count up, updn = '0' count down
--           count state : count
--           when reset = '0' , count <= "000...000"
--           counter state 0 to 2**width-2, "111...111" illegal state
--
-- MODIFIED:
--------------------------------------------------------------------------------
architecture sim of DW03_lfsr_dcnto is
	
  signal right_xor, shift_right, tc, ground : std_logic;
  signal q, de, d, cnto : std_logic_vector(width-1 downto 0);
      function equal (A,B : std_logic_vector) return BOOLEAN is
        begin
-- pragma translate_off
            for i in A'range loop
               if A(i) /= B(i) then
                   return FALSE;
               end if;
            end loop;
            return TRUE;
-- pragma translate_on
       end;
      
 begin
 
      count <= q;
   proc_shr: process(right_xor,q)
    begin
     case(width) is
       when 1 => right_xor <= not q(0);
       when 2|3|4|6|7|15|22 => right_xor <= q(0) xor q(1);
       when 5|11|21|29|35 => right_xor <= q(0) xor q(2);
       when 10|17|20|25|28|31|41 => right_xor <= q(0) xor q(3);
       when 9|39 => right_xor <= q(0) xor q(4);
       when 23|47 => right_xor <= q(0) xor q(5);
       when 18 => right_xor <= q(0) xor q(7);
       when 49 => right_xor <= q(0) xor q(9);
       when 36 => right_xor <= q(0) xor q(11);
       when 33 => right_xor <= q(0) xor q(13);
       when 8|38|43 => right_xor <= q(0) xor q(6) xor q(5) xor q(1);
       when 12 => right_xor <= q(0) xor q(7) xor q(4) xor q(3);
       when 13|45 => right_xor <= q(0) xor q(4) xor q(3) xor q(1);
       when 14 => right_xor <= q(0) xor q(12) xor q(11) xor q(1);
       when 16 => right_xor <= q(0) xor q(5) xor q(3) xor q(2);
       when 19 => right_xor <= q(0) xor q(6) xor q(5) xor q(1);
       when 24 => right_xor <= q(0) xor q(4) xor q(3) xor q(1);
       when 26|27 => right_xor <= q(0) xor q(8) xor q(7) xor q(1);
       when 30 => right_xor <= q(0) xor q(16) xor q(15) xor q(1);
       when 32|48 => right_xor <= q(0) xor q(28) xor q(27) xor q(1);
       when 34 => right_xor <= q(0) xor q(15) xor q(14) xor q(1);
       when 37 => right_xor <= q(0) xor q(12) xor q(10) xor q(2);
       when 40 => right_xor <= q(0) xor q(21) xor q(19) xor q(2);
       when 42 => right_xor <= q(0) xor q(23) xor q(22) xor q(1);
       when 44|50 => right_xor <= q(0) xor q(27) xor q(26) xor q(1);
       when 46 => right_xor <= q(0) xor q(21) xor q(20) xor q(1);
       when others => right_xor <= 'U';
   end case;
 end process;
---------------------------------------------------------------------------------------
-- shift register is controlled by updn signal 
-- when power up , reset = '0' the LFSR is "0000....000"
-- for updn counter "111...111" is illegal state
--------------------------------------------------------------------------------------- 
         shift_right <= not right_xor;
	 G3: for i in width-1 downto 0 generate
	   G4: if i = width-1 generate
             de(i) <= (data(i) and not load) or (shift_right and load); 
             d(i) <= (q(i) and not cen) or (de(i) and cen);
             process (d(i), clk, reset, q(i))
               begin
                  if (reset = '0') then
                      q(i) <= '0';
                  elsif (clk'event and clk = '1') then
                      q(i) <= d(i);
                  end if;
             end process;
           end generate G4;
           G5: if i < width-1 generate
               de(i) <= (data(i) and not load) or (q(i+1) and load);
               d(i) <= (q(i) and not cen) or (de(i) and cen);
             process (d(i), clk, reset, q(i))
               begin
                  if (reset = '0') then
                      q(i) <= '0';
                  elsif (clk'event and clk = '1') then
                      q(i) <= d(i);
                  end if;
             end process;
           end generate G5;
        end generate G3;
  
 
      compare_proc: process(count_to,q,tc)
       begin
        if equal(count_to,q) then
           tc <= '1';
        else 
           tc <= '0';
        end if;  
      end process;
      tercnt <= tc;
  
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW03_lfsr_dcnto_cfg_sim of DW03_lfsr_dcnto is
 for sim
 end for; -- sim
end DW03_lfsr_dcnto_cfg_sim;
-- pragma translate_on

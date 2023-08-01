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
-- AUTHOR:    GN                 April. 05, 1993
--
-- VERSION:   simulation architecture 'sim'
--
-- DesignWare_version: d5c1406e
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  LFSR Up/Down Counter
--           Programmable wordwidth (width in integer range 1 to 50)
--           positive edge-triggering clock: clk  
--           asynchronous reset(active low): reset
--           updn = '1' count up, updn = '0' count down
--           count state : count
--           when reset = '0' , count <= "000...000"
--           counter state 0 to 2**width-2, "111...111" illegal state
--
-- MODIFIED: 
--	Jay Zhu	09/11/98	Parameter legality check.
--------------------------------------------------------------------------------
architecture sim of DW03_lfsr_updn is
	
  signal shift_right, shift_left, right_xor, left_xor,tcup,tcup1,tcdn1,tcdn : std_logic;
  signal q,acck, d, de : std_logic_vector(width-1 downto 0);
      
 begin
-- pragma translate_off
 
      count <= q;
   proc_shr: process(right_xor,q)
    begin
     case(width) is
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
   proc_shl: process(left_xor,q)
    begin
     case(width) is
       when 2|3|4|6|7|15|22 => left_xor <= q(width-1) xor q(0);
       when 5|11|21|29|35 => left_xor <= q(width-1) xor q(1);
       when 10|17|20|25|28|31|41 => left_xor <= q(width-1) xor q(2);
       when 9|39 => left_xor <= q(width-1) xor q(3);
       when 23|47 => left_xor <= q(width-1) xor q(4);
       when 18 => left_xor <= q(width-1) xor q(6);
       when 49 => left_xor <= q(width-1) xor q(8);
       when 36 => left_xor <= q(width-1) xor q(10);
       when 33 => left_xor <= q(width-1) xor q(12);
       when 8|38|43 => left_xor <= q(width-1) xor q(5) xor q(4) xor q(0);
       when 12 => left_xor <= q(width-1) xor q(6) xor q(3) xor q(2);
       when 13|45 => left_xor <= q(width-1) xor q(3) xor q(2) xor q(0);
       when 14 => left_xor <= q(width-1) xor q(11) xor q(10) xor q(0);
       when 16 => left_xor <= q(width-1) xor q(4) xor q(2) xor q(1);
       when 19 => left_xor <= q(width-1) xor q(5) xor q(4) xor q(0);
       when 24 => left_xor <= q(width-1) xor q(3) xor q(2) xor q(0);
       when 26|27 => left_xor <= q(width-1) xor q(7) xor q(6) xor q(0);
       when 30 => left_xor <= q(width-1) xor q(15) xor q(14) xor q(0);
       when 32|48 => left_xor <= q(width-1) xor q(27) xor q(26) xor q(0);
       when 34 => left_xor <= q(width-1) xor q(14) xor q(13) xor q(0);
       when 37 => left_xor <= q(width-1) xor q(11) xor q(9) xor q(1);
       when 40 => left_xor <= q(width-1) xor q(20) xor q(18) xor q(1);
       when 42 => left_xor <= q(width-1) xor q(22) xor q(21) xor q(0);
       when 44|50 => left_xor <= q(width-1) xor q(26) xor q(25) xor q(0);
       when 46 => left_xor <= q(width-1) xor q(20) xor q(19) xor q(0);
       when others => left_xor <= 'U';
     end case;
   end process;
---------------------------------------------------------------------------------------
-- shift register is controlled by updn signal 
-- when updn = '1', shift right register
-- when updn = '0', shift left register
-- when power up , reset = '0' the LFSR is "0000....000"
-- for updn counter "111...111" is illegal state
--------------------------------------------------------------------------------------- 
         shift_right <= not right_xor;
         shift_left <= not left_xor;
         G3: for i in width-1 downto 0 generate
           G4: if i = width-1 generate
              de(i) <= (q(i-1) and not updn) or (shift_right and updn); 
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
           G5: if i < width-1 and i > 0 generate
             de(i) <= (q(i-1) and not updn) or (q(i+1) and updn); 
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
           G6: if i = 0 generate
            de(i) <= (shift_left and not updn) or (q(i+1) and updn); 
            d(i) <= (q(i) and not cen) or (de(i) and cen);
            process (d(i), clk, reset, q(i))
                begin
                     if (reset = '0') then
                       q(i) <= '0';
                     elsif (clk'event and clk = '1') then
                       q(i) <= d(i);
                    end if;
               end process;
           end generate G6;
        end generate G3;
------------------------------------------------------------------------
-- generate the terminal counter
-- when updn = '1', count up ,the terminal count at "00..0001"
-- when updn = '0', count down, the terminal count at "000..000"
-----------------------------------------------------------------------
        C0: for k in 1 to width-1 generate
          C1: if k = 2 generate
                acck(k) <= q(1) or q(2);
          end generate C1;
          C3: if k > 2 generate
                acck(k) <= q(k) or acck(k-1); 
         end generate C3;
        end generate C0;
 
           tcup1 <= q(0) and (not acck(width-1));
           tcup <= tcup1 and updn;
           tcdn1 <= not (updn or q(0) or acck(width-2));
           tcdn <= tcdn1 and q(width-1);
           tercnt <= tcup or tcdn;
-- pragma translate_on
  end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW03_lfsr_updn_cfg_sim of DW03_lfsr_updn is
 for sim
 end for; -- sim
end DW03_lfsr_updn_cfg_sim;
-- pragma translate_on

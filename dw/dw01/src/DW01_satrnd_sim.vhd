--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 1994 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Paul Scheidt		Aug. 8, 1994
--
-- VERSION:   Entity
--
-- DesignWare_version: ccfc112d
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Arithmetic Saturation and Rounding Logic
--
--           eg. width=9, msb_out=5, lsb_out=2
--
--           input:    8 7 6 5 4 3 2 1 0
--           extract         5 4 3 2
--           output          3 2 1 0
--
--
-- MODIFIED:
--	Jay Zhu	Jan 29, 1999
--	    Add X behavior.
--	Scott MacKay Jan 11, 1995
--	    Added checking to assert ov when a round up causes overflow.
--
--
------------------------------------------------------------------------
library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use DWARE.DW_Foundation_arith.all;

architecture sim of DW01_satrnd is
	
begin
-- pragma translate_off
  process(din,tc,sat,rnd)
    subtype dout_type is std_logic_vector(msb_out-lsb_out downto 0);
    subtype dout_type_SIGNED is SIGNED(msb_out-lsb_out downto 0);
    variable dout_ov, dout_rnd: dout_type;
    variable max_signed, min_signed, max_unsigned: dout_type;
    variable dout_rnd_signed, add_lsb, din_trunc: dout_type_SIGNED;
    variable din_in : std_logic_vector(width-1 downto 0);
    variable tc_in : std_logic;
    variable sat_in : std_logic;
    variable rnd_in : std_logic;
    variable out_of_range : std_logic;
  begin
    max_signed := (others => '1');
    max_signed(msb_out-lsb_out) := '0';
    min_signed := (others => '0');
    min_signed(msb_out-lsb_out) := '1';
    max_unsigned := (others => '1'); 
    add_lsb := (others => '0'); 
    add_lsb(0) := '1';
    din_in := To_X01(din);
    tc_in := To_X01(tc);
    sat_in := To_X01(sat);
    rnd_in := To_X01(rnd);
    -- check for saturation and compute saturation value
    out_of_range := '0';
    dout_ov := din_in(msb_out downto lsb_out);        
    if msb_out < width-1 then  -- overflow or underflow is possible
      if tc_in = '1' then         -- signed
	if din_in(msb_out) = 'X' then
	  out_of_range := 'X';
	else
	  ovs: for i in width-1 downto msb_out+1 loop
	    if din_in(i) = 'X' then
	      out_of_range := 'X';
	      exit ovs;
	    elsif din_in(i) /= din_in(msb_out) then
	      out_of_range := '1';
	    end if;
	  end loop ovs;
	end if;
        if din_in(width-1) = '0' then
	  dout_ov := max_signed;
	elsif din_in(width-1) = '1' then
	  dout_ov := min_signed;
	else
	  dout_ov := (others => 'X');
        end if;
      elsif tc_in = 'X' and din_in(msb_out) /= '0' then   -- don't know
	  dout_ov := (others => 'X');
	  out_of_range := 'X';
      else                     -- unsigned
        dout_ov := max_unsigned;
	ovu: for i in width-1 downto msb_out+1 loop
	  if din_in(i) = 'X' then
	    out_of_range := 'X';
	    exit ovu;
	  elsif din_in(i) = '1' then
	    out_of_range := '1';
	  end if;
	end loop ovu;
-- check for round up causing an overflow.  Scott M. 1-11-95
      end if;
    end if;
    -- check for lsb truncation and compute rounded output
    if rnd_in = 'X' then
      dout_rnd := (others => 'X');
    elsif lsb_out > 0 AND rnd_in = '1' then
-- check for round up causing an overflow.  Scott M. 1-11-95
      if (tc_in='X') then
	out_of_range := 'X';
      else
    	if(Is_x(din_in(msb_out downto lsb_out))) then
	  out_of_range := 'X';
    	elsif(((tc_in = '1' AND
		din_in(msb_out downto lsb_out) = max_signed) OR
    	       (tc_in = '0' AND
		din_in(msb_out downto lsb_out) = max_unsigned)) AND
	      (lsb_out > 0 AND din_in(lsb_out-1) = '1'))
	then
	  out_of_range := rnd_in OR out_of_range;
	end if;
      end if;
      if (din_in(lsb_out-1) = '1') then
        din_trunc := SIGNED(din_in(msb_out downto lsb_out));
        dout_rnd_signed := din_trunc + add_lsb;
        dout_rnd := std_logic_vector(dout_rnd_signed);
      elsif (din_in(lsb_out-1) = '0') then
        dout_rnd := din_in(msb_out downto lsb_out);
      else
	dout_rnd := (others => 'X');
      end if;
    else -- lsb_out = 0
      dout_rnd := din_in(msb_out downto lsb_out);
    end if;
    if sat_in = '0' then
      dout <= dout_rnd;
    elsif sat_in = '1' then -- sat = '1'
      if out_of_range = '1' then
        dout <= dout_ov;
      elsif out_of_range = '0' then
	dout <= dout_rnd;
      else 
	dout <= (others => 'X');
      end if;
    else -- sat_in = 'X'
      dout <= (others => 'X');
    end if;
    ov <= out_of_range;
  end process;

-- pragma translate_on
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW01_satrnd_cfg_sim of DW01_satrnd is
 for sim
 end for; -- sim
end DW01_satrnd_cfg_sim;
-- pragma translate_on

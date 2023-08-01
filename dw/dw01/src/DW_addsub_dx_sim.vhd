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
-- AUTHOR:    Jay Zhu		July 5, 1998
--
-- VERSION:   VHDL Simulation Model
--
-- DesignWare_version: c20878cd
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Duplex Adder-Subtractor
--
-- MODIFIED:
--
----------------------------------------------------------------------
library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
architecture sim of DW_addsub_dx is
	
function add(
		tc : std_logic;
		ci : std_logic;
		a  :  std_logic_vector;
		b  :  std_logic_vector
		)
return std_logic_vector is
      constant	a_width : NATURAL := a'length;
      variable	a_in	: std_logic_vector(a_width downto 0);
      variable	b_in	: std_logic_vector(a_width downto 0);
      variable	carry 	: std_logic;
      variable	co	: std_logic;
      variable  sum	: std_logic_vector(a_width+1 downto 0);
begin
	a_in(a_width-1 downto 0) := a;
	a_in(a_width) := a_in(a_width-1) and tc;
	b_in(a_width-1 downto 0) := b;
	b_in(a_width) := b_in(a_width-1) and tc;
	carry := ci;
	for i in 0 to a_width-1 loop
	    sum(i) := a_in(i) xor b_in(i) xor carry;
	    carry := (a_in(i) and b_in(i)) or
		    (a_in(i) and carry) or
		    (carry and b_in(i));
	end loop;
	
	sum(a_width) := a_in(a_width) xor b_in(a_width) xor carry;
        sum(a_width+1) := carry;
	return sum;
end add;
function sub(
		tc : std_logic;
		ci : std_logic;
		a  :  std_logic_vector;
		b  :  std_logic_vector
		)
return std_logic_vector is
      constant	a_width : NATURAL := a'length;
      variable	a_in	: std_logic_vector(a_width downto 0);
      variable	b_in	: std_logic_vector(a_width downto 0);
      variable  bv 	: std_logic_vector(a_width downto 0);
      variable	carry 	: std_logic;
      variable	co 	: std_logic;
      variable  sum 	: std_logic_vector(a_width+1 downto 0);
begin
	a_in(a_width-1 downto 0) := a;
	a_in(a_width) := a_in(a_width-1) and tc;
	b_in(a_width-1 downto 0) := b;
	b_in(a_width) := b_in(a_width-1) and tc;
	bv := not b_in;
	carry := not ci;
	for i in 0 to a_width-1 loop
	    sum(i) := a_in(i) xor bv(i) xor carry;
	    carry := (a_in(i) and bv(i)) or
		    (a_in(i) and carry) or
		    (carry and bv(i));
	end loop;
	
	sum(a_width) := a_in(a_width) xor bv(a_width) xor carry;
        sum(a_width+1) := not carry;
	return sum;
end sub;
function addsub_func(
		add_sub_ctl : std_logic;
		tc : std_logic;
		ci : std_logic;
		a :  std_logic_vector;
		b :  std_logic_vector
		)
return std_logic_vector is
      constant	a_width : NATURAL := a'length;
      variable  add_sub_ctl_int : std_logic;
      variable  sum : std_logic_vector (a_width+1 downto 0);
begin
        if (add_sub_ctl = '0') then
	  sum := add(tc, ci, a, b);
        elsif (add_sub_ctl = '1') then
	  sum := sub(tc, ci, a, b);
        else
	  sum := (others => 'X');
        end if;
	return sum;
end addsub_func;
function saturation(sat, avg, addsub, tc , ci: std_logic;
			a_in, b_in : std_logic_vector )
return std_logic_vector is
      constant a_width : NATURAL := a_in'length;
      variable a : std_logic_vector(a_width-1 downto 0);
      variable b : std_logic_vector(a_width-1 downto 0);
      variable sat_int : std_logic;
      variable avg_int : std_logic;
      variable addsub_int : std_logic;
      variable tc_int : std_logic;
      variable sum : std_logic_vector(a_width+1 downto 0);
      variable carry : std_logic;
      variable sum_sign : std_logic;
      variable sum_ext_sign : std_logic;
      variable avg_out : std_logic_vector(a_width-1 downto 0);
      variable sat_out : std_logic_vector(a_width-1 downto 0);
      variable final_out : std_logic_vector(a_width downto 0);
      variable overflow_type : std_logic_vector(1 downto 0);
begin
	a := a_in;
	b := b_in;
	sat_int := To_01X(sat);
	avg_int := To_01X(avg);
	addsub_int := To_01X(addsub);
	tc_int := To_01X(tc);
	sum := addsub_func(addsub_int, tc, ci, a, b);
	sum_sign := sum(a_width-1);
	sum_ext_sign := sum(a_width);
	carry := sum_ext_sign;
	sat_out := sum(a_width-1 downto 0);
	if (sat_int = '1') then
	  if (tc_int = '0') then
	    carry := '0';
	    if (sum_ext_sign = '1') then
	      sat_out := (others => not addsub_int);
	    elsif (sum_ext_sign = '0') then
	      sat_out := sum(a_width-1 downto 0);
	    else
	      sat_out := (others => 'X');
	    end if;
	  elsif (tc_int = '1') then
	    overflow_type := sum_ext_sign & sum_sign;
	    case overflow_type is
		when "00" |	
		     "11" =>
			null;
		when "01" =>
			sat_out(a_width-2 downto 0) := (others => '1');
			sat_out(a_width-1) := '0';
		when "10" =>
			sat_out(a_width-2 downto 0) := (others => '0');
			sat_out(a_width-1) := '1';
		when others =>
			sat_out := (others => 'X');
	    end case;
	  else
	    sat_out := (others => 'X');
	  end if;
	elsif(sat_int = 'X') then
	  if (tc_int = '0') then
	    if (sum_ext_sign /= sum_sign) then
	      sat_out := (others => 'X');
	      carry := 'X';
	    end if;
	  elsif (tc_int = '1') then
	    overflow_type := sum_ext_sign & sum_sign;
	    case overflow_type is
	      when "00" |	
		   "11" =>
		null;
	      when "01" |
		   "10" =>
		sat_out := (others => 'X');
	      	carry := 'X';
	      when others =>
		sat_out := (others => 'X');
	      	carry := 'X';
	    end case;
	  else 			

	    sat_out := (others => 'X');
	    carry := 'X';
	  end if;
	end if;
	if (avg_int = '0') then		
	  avg_out := sat_out;
	elsif (avg_int = '1') then		
	  if (tc_int = '0') then
	    carry := '0';
	  elsif (tc_int = 'X') then
	    if (carry /= '0') then
	      carry := 'X';
	    end if;
	  end if;
	  if (sat = '0') then
	    avg_out(a_width-1 downto 0) := sum(a_width downto 1);
	  elsif (sat = '1') then
	    avg_out(a_width-2 downto 0) := sat_out(a_width-1 downto 1);
	    avg_out(a_width-1) := sat_out(a_width-1) and tc_int;
	  else
	    avg_out := (others => 'X');
	  end if;
	else
	  avg_out := (others => 'X');
	  carry := 'X';
	end if; 
	final_out(a_width-1 downto 0) := avg_out;
	final_out(a_width) := carry;
	return final_out;
end saturation;
function  addsub_dx(
		a :		std_logic_vector;
		b :		std_logic_vector;
		ci1 :		std_logic;
		ci2 :		std_logic;
		addsub :	std_logic;
		tc :		std_logic;
		sat :		std_logic;
		avg :		std_logic;
		dplx :		std_logic
		) return std_logic_vector is
	
variable dplx_int :	std_logic;
variable co1 :		std_logic;
variable co2 :		std_logic;
variable sum_int :	std_logic_vector( width downto 0 );
variable sum :		std_logic_vector( width-1 downto 0 );
begin
	dplx_int := To_01X(dplx);
	if (dplx_int = '0') then
	  sum_int := saturation(sat, avg, addsub, tc, ci1, a, b);
	  sum := sum_int(width-1 downto 0);
	  co1 := '0';
	  co2 := sum_int(width);
	elsif (dplx_int = '1') then
	  sum_int(p1_width downto 0) := saturation(sat, avg,
	  	addsub, tc, ci1,
	  	a(p1_width-1 downto 0), b(p1_width-1 downto 0));
	  sum(p1_width-1 downto 0) := sum_int(p1_width-1 downto 0);
	  co1 := sum_int(p1_width);
	  sum_int(width-p1_width downto 0) := saturation(sat, avg,
	  	addsub, tc, ci2,
	  	a(width-1 downto p1_width), b(width-1 downto p1_width));
	  sum(width-1 downto p1_width) :=
		sum_int(width-p1_width-1 downto 0);
	  co2 := sum_int(width-p1_width);
	else
	  sum := (others => 'X');
	  co1 := 'X';
	  co2 := 'X';
	end if;
	return co1 & co2 & sum;
end addsub_dx;
signal	sum_int :	std_logic_vector(width+1 downto 0);
begin
-- pragma translate_off
	sum_int <= addsub_dx(
			a,
			b,
			ci1,
			ci2,
			addsub,
			tc,
			sat,
			avg,
			dplx
			);
	
	sum <= sum_int(width-1 downto 0);
	co1 <= sum_int(width+1);
	co2 <= sum_int(width);
	
-- pragma translate_on
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_addsub_dx_cfg_sim of DW_addsub_dx is
 for sim
 end for; -- sim
end DW_addsub_dx_cfg_sim;
-- pragma translate_on

--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 1999 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Rick Kelly       	4/19/99
--
-- VERSION:   VHDL Simulation Model
--
-- DesignWare_version: f08df4fa
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT: Integer Square with two partial product outputs
--
--		NOTE:	This model is architecturally different
--			from the 'wall' implementation of DW_squarep
--			but will generate exactly the same result
--			once the two partial product outputs are
--			added together
--
-- MODIFIED:
--
--------------------------------------------------------------------------------
--
library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use DWARE.DWpackages.all;


architecture sim of DW_squarep is
	

  CONSTANT zeros : std_logic_vector(width-1 downto 0) := (others => '0');
  SIGNAL   abs_a : std_logic_vector(width-1 downto 0);

begin
-- pragma translate_off
    
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
    
    if (width < 1) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter width (lower bound: 1)"
        severity warning;
    end if;
    
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;

    -- get absolute value of input, "a"
    ABSVAL_a : process ( a, tc )
	VARIABLE indx : INTEGER;
	VARIABLE a_temp : std_logic_vector(width downto 0);
    begin
	-- for cases when:  tc   sign
	--                  ==   ====
	--                   0     0
	--                   0     1
	--                   1     0
	--                   0     X
	--                   X     0
	-- abs val of a = a
	if ( (tc AND a(width-1)) = '0' ) then
	    abs_a <= a OR zeros;

	else
	    -- if tc = 1 and sign = 1 then two's comp is needed
	    if ((tc = '1') AND (a(width-1) = '1')) then
		a_temp := '0' & (NOT a);

		indx := 0;
		while ((a_temp(indx) = '1') AND (indx < width)) loop
		    a_temp(indx) := '0';
		    indx := indx + 1;
		end loop;

		if (indx < width) then
		    a_temp(indx) := NOT a_temp(indx);
		end if;

		abs_a <= a_temp(width-1 downto 0);

	    else
		-- other cases   tc   sign
		--               ==   ====
		--                1     X
		--                X     1
		--                X     X
		-- value is unknown
		abs_a <= (others => 'X');
	    end if;
	end if;
    end process ABSVAL_a;


    mk_pp_array : process( abs_a )
	SUBTYPE  pp_type is std_logic_vector(2*width-1 downto 0);
	TYPE     pp_array_type is array (0 to width-1) of pp_type;

	variable pp_array : pp_array_type;
	variable tmp_pp_sum, tmp_pp_carry : std_logic_vector(2*width-1 downto 0);
	variable pp_count : INTEGER;
    begin

	-- if there are any unknown values, then all bets are off
	if (Is_X(abs_a)) then
	    out0 <= (others => 'X');
	    out1 <= (others => 'X');

	else
	    if ( width > 1 ) then
		for pp_indx in 1 to width-1 loop
		    if (abs_a(pp_indx) = '1') then
			pp_array(pp_indx) := zeros(width-1 downto pp_indx) &
					 abs_a &
					 zeros(pp_indx-1 downto 0);
		    else
			pp_array(pp_indx) := zeros & zeros;
		    end if;
		end loop;
	    end if;

	    if (abs_a(0) = '1') then
		pp_array(0) := zeros & abs_a;
	    else
		pp_array(0) := zeros & zeros;
	    end if;

	    pp_count := width;

	    while (pp_count > 2) loop
		for i in 0 to (pp_count/3)-1 loop
		    tmp_pp_sum := pp_array(i*3) XOR
				    pp_array(i*3+1) XOR
				    pp_array(i*3+2);

		    tmp_pp_carry := (pp_array(i*3) AND pp_array(i*3+1)) OR
				    (pp_array(i*3+1) AND pp_array(i*3+2)) OR
				    (pp_array(i*3) AND pp_array(i*3+2));

		    pp_array(i*2) := tmp_pp_sum;
		    pp_array(i*2+1) := tmp_pp_carry(2*width-2 downto 0) & '0';
		end loop;

		if (pp_count mod 3) > 0 then
		    for i in 0 to (pp_count mod 3)-1 loop
			pp_array(2 * (pp_count/3) + i) :=
					pp_array(3 * (pp_count/3) + i);
		    end loop;
		end if;

		pp_count := pp_count - (pp_count/3);
	    end loop;

	    out0 <= pp_array(0);

	    if (pp_count = 1) then
		out1 <= zeros & zeros;
	    else
		out1 <= pp_array(1);
	    end if;
	end if;

    end process mk_pp_array;
        
-- pragma translate_on
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_squarep_cfg_sim of DW_squarep is
 for sim
 end for; -- sim
end DW_squarep_cfg_sim;
-- pragma translate_on

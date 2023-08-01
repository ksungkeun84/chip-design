--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2005 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Alexandre F. Tenca
--
-- VERSION:   VHDL Simulation Model
--
-- DesignWare_version: 63e99aaf
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--
-- ABSTRACT: Inverse square-root B=(A)^{-1/2}
--           Computes the reciprocal of the square-root of A using a
--           digit recurrence algorithm. 
--           Input A must be in the range 1/4 < A < 1
--           Output B is in the range 1 < B < 2
--                  t is the sticky bit (1 when the residual is not zero).
--           The prec_control parameter defines the number of bits that must
--           be discarded from the extra_bits used internally
--
-- MODIFIED:
--           1/30/2007: Modified upper bound of prec_control.
--
---------------------------------------------------------------------------------

library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_misc.all;
use DWARE.DW_Foundation_arith.all;

architecture sim of DW_inv_sqrt is
	
-- pragma translate_off

-- Identify special cases that require even more extra internal precision
  function extra_prec(prec : INTEGER; prec_control : INTEGER) return INTEGER is
  variable prec_adj : INTEGER;
  begin
    if (prec_control < 0) then
        prec_adj := -prec_control;
    else
        prec_adj := 0;
    end if;
    if (prec = 7 ) then
        return (1+prec_adj);
    end if;
    if (prec > 21 and prec < 36) then
        return (3+prec_adj);
    end if;
    if (prec >= 36) then
        return (prec/4+prec_adj);
    end if;
    return (prec_adj);
  end extra_prec;

-- number of extra bits used for internal precision
constant extra_bits: integer := a_width/2 + extra_prec(a_width,prec_control);
-- two more bits are added in the MSB positions and extra_bits are
-- added to the LSB positions
signal w0 : std_logic_vector(a_width+1+extra_bits downto 0);
signal p0 : std_logic_vector(a_width+1+extra_bits downto 0);
signal x0 : std_logic_vector(a_width+1+extra_bits downto 0);
signal zero_vector : std_logic_vector(a_width-1+extra_bits downto 0); 
signal zero_extra_vector : std_logic_vector(extra_bits-1 downto 0);

-- pragma translate_on
begin
-- pragma translate_off
  
    
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
    
    if (a_width < 2) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter a_width (lower bound: 2)"
        severity warning;
    end if;
    
    if ( (prec_control > (a_width-2)/2) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter prec_control (upper bound: (a_width-2)/2)"
        severity warning;
    end if;
    
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;  

-- initialization values
 zero_vector <= (others => '0');
 zero_extra_vector <= (others => '0');

-- values for the first iteration
 w0 <= (others => 'X') when (Is_x(a)) else 
       (unsigned("01" & zero_vector ) - unsigned("00" & a & zero_extra_vector));
 p0 <= (others => 'X') when (Is_x(a)) else ("00" & a & zero_extra_vector);
 x0 <= (others => 'X') when (Is_x(a)) else ("00" & a & zero_extra_vector);
  
INVSQRT: process (a, w0, p0, x0) 
type data_array is array (0 to a_width) of std_logic_vector(a_width+1+extra_bits downto 0);
variable w_array_var : data_array;
variable p_array_var : data_array;
variable p_array_var1 : data_array;
variable p_array_var2 : data_array;
variable x_array_var : data_array;
variable vector : std_logic_vector(a_width+1+extra_bits downto 0);
variable wtemp : std_logic_vector(a_width+2+extra_bits downto 0);
variable b_var : std_logic_vector(a_width-1 downto 0);
variable index : integer;
variable i : integer;
begin
 index := 0;
 w_array_var(0) := w0;
 p_array_var(0) := p0;
 x_array_var(0) := x0;
 b_var(a_width-1) := '1';

-- create a loop of operations that generate the combinational behavior of this operation
while (index < a_width-1) loop
  vector := x_array_var(index);

  -- shift right by 1 bit position to obtain Xshft
  x_array_var(index+1) :=  '0' & vector(vector'length-1 downto 1); 

  -- destroy the LS bits defined in prec_control parameter
  i := 0;
  while (i < prec_control) loop
    x_array_var(index+1)(i) := '0';
    i := i + 1;    
  end loop;
  
  vector := p_array_var(index);
  -- 2P + Xshft
  p_array_var1(index) := unsigned(vector(vector'length-2 downto 0) & '0') 
			 + unsigned(x_array_var(index+1));

  -- destroy the LS bits defined in prec_control parameter
  i := 0;
  while (i < prec_control) loop
    p_array_var1(index)(i) := '0';
    i := i + 1;    
  end loop;  -- i
  
  -- P + Xshft
  p_array_var2(index) := unsigned(p_array_var(index)) + unsigned(x_array_var(index+1));

  -- destroy the LS bits defined in prec_control parameter
  i := 0;
  while (i < prec_control) loop
    p_array_var2(index)(i) := '0';
    i := i + 1;    
  end loop;  -- i
  
  -- 2W - (2P+xshft)
  vector := w_array_var(index);
  wtemp := signed(vector & '0') - signed('0' & p_array_var1(index));
  
  -- select the output bit based on the result of the subtraction
  b_var(a_width-index-2) := not wtemp(wtemp'length-1);
  
  -- if the output bit was 1, update the next residual value with wtemp
  if (wtemp(wtemp'length-1) = '0') then 
      w_array_var(index+1) := wtemp(wtemp'length-2 downto 0);
      p_array_var(index+1) := p_array_var2(index);
  else
      w_array_var(index+1) := vector(vector'length-2 downto 0) & '0';
      p_array_var(index+1) := p_array_var(index);
  end if;

  -- increment the loop variable
  index := index + 1;
  
end loop;

-- assign value to outputs 
 if (Is_x(a)) then
   b <= (others => 'X');
   t <= 'X';
 else
   b <= b_var;
   t <= or_reduce(w_array_var(a_width-1));
 end if;

end process INVSQRT;

-- pragma translate_on  

end sim ;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_inv_sqrt_cfg_sim of DW_inv_sqrt is
 for sim
 end for; -- sim
end DW_inv_sqrt_cfg_sim;
-- pragma translate_on

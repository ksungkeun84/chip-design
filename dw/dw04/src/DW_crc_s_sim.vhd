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
-- AUTHOR:    Nitin Mhamunkar  SEPT 1999
--
-- VERSION:   VHDL Simulation Model
--
-- DesignWare_version: c89dde30
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT : Generic CRC Generator/Checker 
--
-- MODIFIED :
--
--		RJK  9/3/2002  Fixed crc_ok behavior at reset and initialization
--				and state behavior after CRC insertion when a new
--				drain request is seen with no intervening initial-
--				ization
--
---------------------------------------------------------------------------------

library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use DWARE.DWpackages.all;

architecture sim of DW_crc_s is
	

-- pragma translate_off

 constant msb_of_crc_poly : integer range 0 to poly_size := poly_size - 1;
 constant msb_l1_of_crc_poly : integer range 0 to poly_size := msb_of_crc_poly - 1;
 constant msb_of_data_width : integer range 0 to data_width := data_width - 1;
 constant no_of_data_segments : integer range 0 to 64 := poly_size/data_width;
 
 signal	next_crc	: std_logic_vector(msb_of_crc_poly downto 0);
 signal	crc_storage	: std_logic_vector(msb_of_crc_poly downto 0);
 
 signal crc_result : std_logic_vector(msb_of_crc_poly downto 0);
 signal start_draining  : std_logic;
 signal accumulating_status : std_logic;
 signal init_crc_reg	: std_logic_vector(msb_of_crc_poly downto 0);
 signal reset_crc_reg	: std_logic_vector(msb_of_crc_poly downto 0);
 signal crc_polynomial  : std_logic_vector(msb_of_crc_poly downto 0);
 signal crc_out_reg     : std_logic_vector(msb_of_crc_poly downto 0);
 signal crc_ok_reg      : std_logic_vector(msb_of_crc_poly downto 0);
 signal insert_crc_bits : std_logic_vector(msb_of_crc_poly downto 0);
 signal swap_bits_of_byte : std_logic_vector(7 downto 0);
 signal crc_xor_constant  : std_logic_vector(msb_of_crc_poly downto 0);
 signal swap_bits_of_word : std_logic_vector(15 downto 0);

 signal crc_ok_info : std_logic_vector(msb_of_crc_poly downto 0); 
 

 signal rst_n_int     : std_logic;
 signal init_n_int    : std_logic;
 signal enable_int    : std_logic;
 signal drain_int     : std_logic;
 signal ld_crc_n_int : std_logic;
 signal data_in_int   : std_logic_vector(data_width-1 downto 0);
 signal crc_in_int    : std_logic_vector(poly_size-1 downto 0);


-------------------------------------------------------------------------------
-- depending on bit order mode the bits and bytes swapping is done 
 
 function fswap_bytes_bits(swap_bytes_of_word:std_logic_vector; bit_order:integer)
                   return std_logic_vector is
                   
 variable input_data_size : integer range 0 to 64 := swap_bytes_of_word'length-1;
 variable input_length : integer range 0 to 64 := swap_bytes_of_word'length;
 variable swaped_word : std_logic_vector(input_data_size downto 0);
 variable no_of_bytes : integer range 0 to 8 := swap_bytes_of_word'length / 8;
 variable byte_boundry1 : integer range 0 to swap_bytes_of_word'length;
 variable byte_boundry2 : integer range 0 to swap_bytes_of_word'length;
 
 begin
 
  if( bit_order = 0 ) then  
   swaped_word := swap_bytes_of_word;  
  elsif( bit_order = 1 ) then
   for i in 0 to input_data_size loop
    swaped_word(input_data_size - i) := swap_bytes_of_word(i); -- input_data_size
   end loop;
  elsif( bit_order = 3 ) then
   for i in 1 to no_of_bytes loop
    byte_boundry1 := (i * 8) - 1;
    byte_boundry2 := ( i - 1) * 8;
    for j in 0 to 7 loop
     swaped_word(byte_boundry2 + j) := swap_bytes_of_word( byte_boundry1 - j );
    end loop;
   end loop; 
  else
   for i in 1 to no_of_bytes loop
    byte_boundry1 := input_length - (i * 8);
    byte_boundry2 := (i - 1) * 8;
    for j in 0 to 7 loop
     swaped_word(byte_boundry2 + j) := swap_bytes_of_word( byte_boundry1 + j );
    end loop;
   end loop;  
  end if;   
     
   
  return swaped_word;
 
 end fswap_bytes_bits;


-------------------------------------------------------------------------------
-- if poly size is greater than data width then poly is divided in segments of 
--   data size and then on each segment swapping is done as per bit order mode.
    
 function fswap_crc(swap_crc_data:std_logic_vector)
                                                    return std_logic_vector is
                   
 variable input_data_size : integer range 0 to 64 := swap_crc_data'length-1;
 variable input_length : integer range 0 to 64 := swap_crc_data'length;
 variable swap_data : std_logic_vector(msb_of_data_width downto 0);
 variable swaped_data : std_logic_vector(msb_of_data_width downto 0);
 variable swaped_crc : std_logic_vector(input_data_size downto 0);
 variable no_of_words : integer range 0 to 64 := swap_crc_data'length / data_width;
 variable data_boundry1 : integer range 0 to (swap_crc_data'length+data_width);
 variable data_boundry2 : integer range 0 to swap_crc_data'length;
 
 begin
   data_boundry1 := msb_of_crc_poly + data_width;
   while(no_of_words > 0) loop
    data_boundry1 := data_boundry1 - data_width;
    data_boundry2 := data_boundry1 - msb_of_data_width;
    swap_data := swap_crc_data(data_boundry1 downto data_boundry2);
    swaped_data :=  fswap_bytes_bits(swap_data, bit_order); 
    swaped_crc(data_boundry1 downto data_boundry2) := swaped_data;
   
    no_of_words := no_of_words - 1;
   end loop;   

  return swaped_crc;
 
 end fswap_crc;



-------------------------------------------------------------------------------
--  function to decide the opeartion to be done on crc data before insertion
-------------------------------------------------------------------------------
-- depending on the configuration the constant to be used to XOR the crc value
--   is calculted.

 function fcal_crc_xor_constant(crc_cfg:integer) 
                      return std_logic_vector is
                      
  variable x : std_logic_vector(msb_of_crc_poly downto 0);
  begin
    if( (crc_cfg = 0) or (crc_cfg = 1) ) then
      x := (others => '0');
    elsif( (crc_cfg = 6) or (crc_cfg = 7) ) then
      x := (others => '1');  
    else
     if( (crc_cfg = 2) or (crc_cfg = 3) ) then
      x(0) := '1';
     else
      x(0) := '0';
     end if;
       
     for i in 1 to msb_of_crc_poly loop
      x(i) := NOT x(i-1);
     end loop;  
    end if;  
  return x;
 end  fcal_crc_xor_constant;                   


-------------------------------------------------------------------------------
--  function to calculate  correct value of crc register, left after performing 
--  crc on incoming data which depends upon the configuration register , which
--  decides the attached crc polynomial is inverted or not which interms 
--  decides whether value left after calculation is magic number or simply 
--  zeros's.
-------------------------------------------------------------------------------
  function fcalc_crc_ok_poly(crc_polynomial:std_logic_vector;
                              crc_cfg_value:integer) return std_logic_vector is
   variable int_ok_calc : std_logic_vector(msb_of_crc_poly  downto 0);
   variable crc_ok_value : std_logic_vector(msb_of_crc_poly  downto 0); 
   variable x : integer range 0 to (msb_of_crc_poly - 1) := msb_of_crc_poly - 1;
   variable xor_or_not_ok : std_logic;
 
   begin
    int_ok_calc := fcal_crc_xor_constant(crc_cfg);
   for z in 0 to msb_of_crc_poly loop
     xor_or_not_ok := int_ok_calc(msb_of_crc_poly);
     int_ok_calc :=  int_ok_calc(x downto 0) & '0';
     if( xor_or_not_ok = '1' ) then
      int_ok_calc := int_ok_calc XOR crc_polynomial;
     end if;
   end loop;
   
   crc_ok_value := int_ok_calc;
    
   return crc_ok_value;
     
  end fcalc_crc_ok_poly; 
  

-------------------------------------------------------------------------------
  function fcalc_crc( data_in_int:std_logic_vector;
                      crc_temp_data:std_logic_vector;
                      crc_polynomial:std_logic_vector;
                      bit_order:integer
                     ) return std_logic_vector is
   variable swaped_data_in : std_logic_vector(msb_of_data_width downto 0);
   variable crc_data  : std_logic_vector(msb_of_crc_poly downto 0);
   variable xor_or_not : std_logic;                     
   variable i : integer;
   begin
  
    swaped_data_in := fswap_bytes_bits(data_in_int, bit_order);
    crc_data := crc_temp_data;
     
    i := 0;    
    while( i < data_width) loop
     xor_or_not := swaped_data_in(msb_of_data_width-i) XOR
                                        crc_data(msb_of_crc_poly);
     crc_data := crc_data(msb_l1_of_crc_poly downto 0) & '0';
          
     if(xor_or_not = '1') then
      crc_data := crc_data XOR crc_polynomial;
     elsif(xor_or_not /= '0') then 
      crc_data := (others => xor_or_not);
     end if;
     i := i + 1;
     
    end loop;
   
    return crc_data;
     
  end fcalc_crc;
 
 
------------------------------------------------------------------------------- 
function check_crc( crc_out_int:std_logic_vector;
                    crc_ok_info:std_logic_vector
                  ) return std_logic is
                    
   variable i : integer;
   variable crc_ok_int : std_logic;
   variable data1 : std_logic_vector(msb_of_crc_poly downto 0);
   variable data2 : std_logic_vector(msb_of_crc_poly downto 0);
   
   begin
    data1 := crc_out_int;
    data2 :=  crc_ok_info;
  
    i := 0;    
    while(i < poly_size) loop
     if(data1(i) = '0' or data1(i) = '1') then
      if(data1(i) = data2(i)) then
       crc_ok_int := '1';
      else 
       crc_ok_int := '0';
      exit;
      end if;
     else
      crc_ok_int := data1(i);
      exit;
     end if;  
     i := i + 1;
    end loop;
   
    return crc_ok_int;
     
  end check_crc;
-- pragma translate_on
  
  
   
begin
   
-- pragma translate_off
   
  rst_n_int     <=  TO_UX01(rst_n);
  init_n_int    <= TO_UX01(init_n);
  enable_int    <= TO_UX01(enable);
  drain_int     <= TO_UX01(drain);
  ld_crc_n_int <= TO_UX01(ld_crc_n);
  data_in_int   <= TO_UX01(data_in);
  crc_in_int    <= TO_UX01(crc_in);
 
---------------------------------------------------------------------------

 process(rst_n_int,init_n_int,clk,drain_int)
   
   variable draining_status   : std_logic;
   variable draining_complete : std_logic; 
   
   variable drain_pointer : integer range 0 to 64; 
   variable data_pointer : integer range 0 to 64; 
 
   variable out_pointer1  : integer range 0 to 64;
   variable out_pointer2  : integer range 0 to 64;
   variable data_out_temp : std_logic_vector(msb_of_data_width downto 0);
   variable data_out_int  : std_logic_vector(msb_of_data_width downto 0);
   variable crc_out_int   : std_logic_vector(msb_of_crc_poly downto 0);
   variable crc_temp_data  : std_logic_vector(msb_of_crc_poly downto 0); 
   variable insert_crc_info : std_logic_vector(msb_of_crc_poly downto 0);
   variable crc_swaped_info : std_logic_vector(msb_of_crc_poly downto 0); 
   variable drain_zeros : std_logic_vector(msb_of_data_width downto 0)
                                  := (others => '0');
  begin
  
  if(rst_n_int = '1') then
   
   if(rising_edge(clk)) then
    if(init_n_int = '1') then
     if(enable_int = '1') then     
  
      if(draining_status = '0') then
       if(drain_int = '1') then
        draining_status := '1';          -- only when not already in drainig stage
       elsif((drain_int /= '0') and (drain_int /= '1')) then
        draining_status := drain_int;  
       end if;
      end if;
     
      if(ld_crc_n_int = '0') then
       crc_out_int := crc_in_int;
       crc_temp_data := crc_in_int;
      elsif(ld_crc_n_int /= '1') then 
       crc_out_int := (others => ld_crc_n_int);
       crc_temp_data := (others => ld_crc_n_int);
      end if;
       
      if(draining_status = '0') then    -- + 
        draining <= '0';
        drain_pointer := 0;
        data_pointer := no_of_data_segments;
        data_out_int := data_in_int;
        
        if( ld_crc_n_int = '1' ) then  
         crc_temp_data := fcalc_crc( data_in_int,crc_temp_data,
                                   crc_polynomial,bit_order);
         insert_crc_info := crc_temp_data XOR crc_xor_constant;
         crc_swaped_info := fswap_crc(insert_crc_info);
         crc_out_int := crc_temp_data; 
         insert_crc_bits <= crc_swaped_info;
        
        end if;
          
      elsif(draining_status = '1') then  -- +
       if (draining_complete = '1') then
        data_out_int := data_in_int;
        crc_temp_data := fcalc_crc( data_in_int,crc_temp_data,
                                   crc_polynomial,bit_order);
        crc_out_int := crc_temp_data;                           
       else
       draining <= '1';
           
       if(data_pointer = 0) then -- check for complete crc attachment
        draining_status := '0';
        drain_done <= '1';
	draining_complete := '1';
        draining <= '0';
        data_out_int := data_in_int;
        crc_temp_data := fcalc_crc( data_in_int,crc_temp_data,
                                   crc_polynomial,bit_order);
        crc_out_int := crc_temp_data;                           
       else     -- attach remaining crc data only 
        
        out_pointer1 := (data_pointer * data_width);
        out_pointer2 := 0;
        while (out_pointer2 < data_width) loop
         out_pointer1 := out_pointer1 - 1;
         data_out_temp(msb_of_data_width-out_pointer2) := insert_crc_bits(out_pointer1);
         out_pointer2 := out_pointer2 + 1;
        end loop;
        
        drain_pointer := drain_pointer + 1;
        data_pointer := data_pointer - 1;
        crc_temp_data := crc_temp_data(msb_of_crc_poly-data_width downto 0) & 
                                               drain_zeros;
        crc_out_int := crc_temp_data;
        data_out_int := data_out_temp;
       end if;
       end if;
      else     
       data_out_int := (others => draining_status); 
       draining <= draining_status;                           -- +
       drain_done <= draining_status;
       crc_ok <= draining_status; 
      end if;   -- draining_status
      
      data_out <= data_out_int;
      crc_out <= crc_out_int; 
      crc_ok <= check_crc(crc_out_int,crc_ok_info);
     elsif(enable_int = '0') then 
      NULL;
     else
      data_out <= (others => enable_int); 
      draining <= enable_int;                           
      drain_done <= enable_int;
      crc_ok <= enable_int; 
      crc_out <= (others => enable_int);
      draining_complete := enable_int;
     end if;
     
    elsif(init_n_int = '0') then
     data_out <= (others => '0') ;
     draining <= '0'; 
     drain_done <= '0';
     crc_temp_data :=  reset_crc_reg;  
     crc_out <= reset_crc_reg;
     crc_out_int :=  reset_crc_reg;   
     crc_ok <= '0';
     draining_status := '0';
     draining_complete := '0';
    else
     data_out <= (others => init_n_int);
     draining <= init_n_int; 
     drain_done <= init_n_int;
     crc_out <= (others => init_n_int);
     crc_ok <= init_n_int;
    end if;  -- if(init_n_int = U/X)
   end if; -- clk 
     
  elsif(rst_n_int = '0') then
   data_out <= (others => '0') ;
   draining <= '0'; 
   drain_done <= '0';
   
   crc_temp_data :=  reset_crc_reg;  
   crc_out <= reset_crc_reg;
   crc_out_int :=  reset_crc_reg;   
   crc_ok <= '0';
   draining_status := '0';
   draining_complete := '0';
    
  else   -- else rst_n_int = X | U
   data_out <= (others => rst_n_int); 
   draining <= rst_n_int;                           
   drain_done <= rst_n_int;
   crc_ok <= rst_n_int; 
   crc_out <= (others => rst_n_int);
  end if;     -- reset
   
   
  end process; -- set_draining_status


---------------------------------------------------------------------------------
-- parameter validation process
---------------------------------------------------------------------------------
    
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
	
    if ( (data_width < 1) OR (data_width > poly_size ) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter data_width (legal range: 1 to poly_size )"
        severity warning;
    end if;
	
    if ( (poly_coef0 mod 2)=0 ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid parameter (poly_coef0 value MUST be an odd number)"
        severity warning;
    end if;
	
    if ( (bit_order>1) AND (data_width mod 8 > 0) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid parameter combination (crc_cfg > 1 only allowed when data_width is multiple of 8)"
        severity warning;
    end if;
	
    if ( (poly_size mod data_width) > 0 ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid parameter combination (poly_size MUST be a multiple of data_width)"
        severity warning;
    end if;

    
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;



    initialize: process
	 variable con_poly_coeff : std_logic_vector(63 downto 0);
	 variable v_poly_coef0 : std_logic_vector(15 downto 0);
	 variable v_poly_coef1 : std_logic_vector(15 downto 0);
	 variable v_poly_coef2 : std_logic_vector(15 downto 0);
	 variable v_poly_coef3 : std_logic_vector(15 downto 0);
 
    begin

	v_poly_coef0 := dw_conv_std_logic_vector(poly_coef0,16);
	v_poly_coef1 := dw_conv_std_logic_vector(poly_coef1,16);
	v_poly_coef2 := dw_conv_std_logic_vector(poly_coef2,16);
	v_poly_coef3 := dw_conv_std_logic_vector(poly_coef3,16);
	con_poly_coeff := v_poly_coef3 & v_poly_coef2 & v_poly_coef1 & v_poly_coef0; 
	crc_polynomial <= con_poly_coeff(msb_of_crc_poly downto 0);

	if( (crc_cfg = 0) OR (crc_cfg = 2) OR (crc_cfg = 4) OR (crc_cfg = 6) ) then
	reset_crc_reg <= (others => '0');
	else
	reset_crc_reg <= (others => '1'); 
	end if;

	crc_xor_constant <= fcal_crc_xor_constant(crc_cfg);
	crc_ok_info <= fcalc_crc_ok_poly(con_poly_coeff(msb_of_crc_poly downto 0),crc_cfg);

	wait;
    end process initialize;

-- pragma translate_on 
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_crc_s_cfg_sim of DW_crc_s is
 for sim
 end for; -- sim
end DW_crc_s_cfg_sim;
-- pragma translate_on

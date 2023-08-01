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
-- AUTHOR:    Derived From Entity Files
--
-- VERSION:   Components package file for DW03_components
--
-- DesignWare_version: 223f679b
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_misc.all;
use IEEE.std_logic_arith.all;

library DWARE;
use DWARE.DWpackages.all;

package DW03_components is


  -- Content from file, DW03_bictr_decode.vhdpp

  component DW03_bictr_decode
  generic(width: POSITIVE);
  port(data: in std_logic_vector(width-1 downto 0);
       up_dn, load, cen, clk, reset : in std_logic;
       count_dec: out std_logic_vector(2**width-1 downto 0);
       tercnt: out std_logic); 
  end component;


  -- Content from file, DW03_bictr_scnto.vhdpp

  component DW03_bictr_scnto
  generic(width: POSITIVE;
          count_to : POSITIVE);
  port(data: in std_logic_vector(width-1 downto 0);
       up_dn, load, cen, clk, reset : in std_logic;
       count: out std_logic_vector(width-1 downto 0);
       tercnt: out std_logic); 
  end component;


  -- Content from file, DW03_bictr_dcnto.vhdpp

  component DW03_bictr_dcnto
  generic(width: POSITIVE);
  port(data,count_to: in std_logic_vector(width-1 downto 0);
       up_dn, load, cen, clk, reset : in std_logic;
       count: out std_logic_vector(width-1 downto 0);
       tercnt: out std_logic); 
  end component;


  -- Content from file, DW_fifoctl_s1_df.vhdpp

  component DW_fifoctl_s1_df
	
	generic (
		    depth : INTEGER range 2 to 16777216;
		    err_mode : INTEGER range 0 to 2 := 0;
		    rst_mode : INTEGER range 0 to 1 := 0
		);
	
	port    (
		    clk : in std_logic;
		    rst_n : in std_logic;
		    push_req_n : in std_logic;
		    pop_req_n : in std_logic;
		    diag_n : in std_logic;
		    ae_level : in std_logic_vector( bit_width(depth)-1 downto 0 );
		    af_thresh : in std_logic_vector( bit_width(depth)-1 downto 0 );
		    we_n : out std_logic;
		    empty : out std_logic;
		    almost_empty : out std_logic;
		    half_full : out std_logic;
		    almost_full : out std_logic;
		    full : out std_logic;
		    error : out std_logic;
		    wr_addr : out std_logic_vector( bit_width(depth)-1 downto 0 );
		    rd_addr : out std_logic_vector( bit_width(depth)-1 downto 0 )
		);
  end component;


  -- Content from file, DW03_lfsr_updn.vhdpp

  component DW03_lfsr_updn
  generic(width : integer range 2 to 50);
  port (updn, cen, clk, reset : in std_logic;
        count   : out std_logic_vector(width-1 downto 0);
        tercnt : out std_logic);
  end component;


  -- Content from file, DW03_lfsr_load.vhdpp

  component DW03_lfsr_load
  generic(width : integer range 1 to 50);
  port (data : in std_logic_vector(width-1 downto 0);
        load, cen, clk, reset : in std_logic;
        count   : out std_logic_vector(width-1 downto 0));
  end component;


  -- Content from file, DW03_lfsr_scnto.vhdpp

  component DW03_lfsr_scnto
  generic(width : POSITIVE range 2 to 50;
          count_to : POSITIVE);
  port (data : in std_logic_vector(width-1 downto 0);
        load, cen, clk, reset : in std_logic;
        count   : out std_logic_vector(width-1 downto 0);
        tercnt : out std_logic);
  end component;


  -- Content from file, DW03_lfsr_dcnto.vhdpp

  component DW03_lfsr_dcnto
  generic(width : integer range 1 to 50);
  port (data : in std_logic_vector(width-1 downto 0);
        count_to : in std_logic_vector(width-1 downto 0);
        load, cen, clk, reset : in std_logic;
        count   : out std_logic_vector(width-1 downto 0);
        tercnt : out std_logic);
  end component;


  -- Content from file, DW03_pipe_reg.vhdpp

  component DW03_pipe_reg
   generic (depth : INTEGER;  
            width : INTEGER); 
   port(A : in std_logic_vector (width-1 downto 0);
        clk : in std_logic;
        B : out std_logic_vector(width-1 downto 0));
  end component;


  -- Content from file, DW03_reg_s_pl.vhdpp

  component DW03_reg_s_pl
	generic(width: POSITIVE := 8;
		reset_value: INTEGER := 0);
	port (	d	: in	std_logic_vector(width-1 downto 0);
		clk	: in	std_logic;
		reset_N	: in	std_logic;
		enable	: in	std_logic;
		q	: out	std_logic_vector(width-1 downto 0) );
  end component;


  -- Content from file, DW03_shftreg.vhdpp

  component DW03_shftreg
	generic	(length :	positive ) ;
	port
	(	clk:		in std_logic;
		s_in:		in std_logic;
		p_in:		in std_logic_vector (length-1 downto 0) ;
		shift_n:	in std_logic;
		load_n:		in std_logic;
		p_out:		out	std_logic_vector (length-1 downto 0) );
  end component;


  -- Content from file, DW_dpll_sd.vhdpp

  component DW_dpll_sd
	
	generic (
	            width : INTEGER range 1 to 16 := 1;
		    divisor : INTEGER range 4 to 256 := 4;
		    gain : INTEGER range 1 to 2 := 1;
		    filter : INTEGER range 0 to 8 := 2;
		    windows : INTEGER range 1 to 128 := 1
		);
	
	port    (
		    clk : in std_logic;
		    rst_n : in std_logic;
		    stall : in std_logic;
		    squelch : in std_logic;
                    window : in std_logic_vector(bit_width(windows)-1 downto 0);
		    data_in : in std_logic_vector(width-1 downto 0);

		    clk_out : out std_logic;
		    bit_ready : out std_logic;
		    data_out : out std_logic_vector(width-1 downto 0)
		);
  end component;


  -- Content from file, DW_stackctl.vhdpp

  component DW_stackctl
	
	generic (
		    depth : INTEGER range 2 to 16777216 ;
		    err_mode : INTEGER range 0 to 1 := 0;
		    rst_mode : INTEGER range 0 to 1 := 0
		);
	
	port    (
		    clk : in std_logic;
		    rst_n : in std_logic;
		    push_req_n : in std_logic;
		    pop_req_n : in std_logic;
		    we_n : out std_logic;
		    empty : out std_logic;
		    full : out std_logic;
		    error : out std_logic;
		    wr_addr : out std_logic_vector( bit_width(depth)-1 downto 0 );
		    rd_addr : out std_logic_vector( bit_width(depth)-1 downto 0 )
		);
  end component;


  -- Content from file, DW03_updn_ctr.vhdpp

  component DW03_updn_ctr
  generic(width : POSITIVE);
  port(data     : in std_logic_vector(width-1 downto 0);
       up_dn, load, cen, clk, reset : in std_logic;
       count    : out std_logic_vector(width-1 downto 0);
       tercnt   : out std_logic); 
  end component;


  -- Content from file, DW_asymfifoctl_s1_sf.vhdpp

  component DW_asymfifoctl_s1_sf
	
	generic (
		    data_in_width  : INTEGER range 1 to 256 ;
		    data_out_width : INTEGER range 1 to 256 ;
		    depth      : INTEGER range 2 to 16777216 ;
		    ae_level   : INTEGER range 1 to 16777215 ;
		    af_level   : INTEGER range 1 to 16777215 ;
		    err_mode   : INTEGER range 0 to 2 := 1;
		    rst_mode   : INTEGER range 0 to 1 := 1;
		    byte_order : INTEGER range 0 to 1 := 0
		);
	
	port    (
		    clk : in std_logic;
		    rst_n : in std_logic;
		    push_req_n : in std_logic;
		    flush_n : in std_logic;
		    pop_req_n : in std_logic;
		    diag_n : in std_logic;
		    data_in : in std_logic_vector(data_in_width-1 downto 0);
		    rd_data : in std_logic_vector(maximum(data_in_width,
		    			data_out_width)-1 downto 0);
		    we_n : out std_logic;
		    empty : out std_logic;
		    almost_empty : out std_logic;
		    half_full : out std_logic;
		    almost_full : out std_logic;
		    full : out std_logic;
		    ram_full : out std_logic;
		    error : out std_logic;
		    part_wd : out std_logic;
		    wr_data : out std_logic_vector(maximum(data_in_width,
		    			data_out_width)-1 downto 0);
		    wr_addr : out std_logic_vector( bit_width(depth)-1 downto 0 );
		    rd_addr : out std_logic_vector( bit_width(depth)-1 downto 0 );
		    data_out : out std_logic_vector(data_out_width-1
		    			downto 0)
		);
  end component;


  -- Content from file, DW_asymfifoctl_s1_df.vhdpp

  component DW_asymfifoctl_s1_df
	
	generic (
		    data_in_width  : INTEGER range 1 to 256 ;
		    data_out_width : INTEGER range 1 to 256 ;
		    depth      : INTEGER range 2 to 16777216 ;
		    err_mode   : INTEGER range 0 to 2 := 1;
		    rst_mode   : INTEGER range 0 to 1 := 1;
		    byte_order : INTEGER range 0 to 1 := 0
		);
	
	port    (
		    clk : in std_logic;
		    rst_n : in std_logic;
		    push_req_n : in std_logic;
		    flush_n : in std_logic;
		    pop_req_n : in std_logic;
		    diag_n : in std_logic;
		    data_in : in std_logic_vector(data_in_width-1 downto 0);
		    rd_data : in std_logic_vector(maximum(data_in_width,
		    			data_out_width)-1 downto 0);
		    ae_level : in std_logic_vector( bit_width(depth)-1 downto 0 );
		    af_thresh : in std_logic_vector( bit_width(depth)-1 downto 0 );
		    we_n : out std_logic;
		    empty : out std_logic;
		    almost_empty : out std_logic;
		    half_full : out std_logic;
		    almost_full : out std_logic;
		    full : out std_logic;
		    ram_full : out std_logic;
		    error : out std_logic;
		    part_wd : out std_logic;
		    wr_data : out std_logic_vector(maximum(data_in_width,
		    			data_out_width)-1 downto 0);
		    wr_addr : out std_logic_vector( bit_width(depth)-1 downto 0 );
		    rd_addr : out std_logic_vector( bit_width(depth)-1 downto 0 );
		    data_out : out std_logic_vector(data_out_width-1
		    			downto 0)
		);
  end component;


  -- Content from file, DW_fifoctl_s2dr_sf.vhdpp

  component DW_fifoctl_s2dr_sf
	
	generic (
		    depth : INTEGER range 4 to 16777216 := 8;
		    push_ae_lvl : INTEGER range 1 to 16777215 := 2;
		    push_af_lvl : INTEGER range 1 to 16777215 := 2;
		    pop_ae_lvl : INTEGER range 1 to 16777215 := 2;
		    pop_af_lvl : INTEGER range 1 to 16777215 := 2;
		    err_mode : INTEGER range 0 to 1 := 0;
		    push_sync : INTEGER range 1 to 3 := 2;
		    pop_sync : INTEGER range 1 to 3 := 2;
		    tst_mode : INTEGER range 0 to 1 := 0
		);
	
	port    (
		    clk_push : in std_logic;
		    clk_pop : in std_logic;
		    rst_push_n : in std_logic;
		    rst_pop_n : in std_logic;
		    init_push_n : in std_logic;
		    init_pop_n : in std_logic;
		    push_req_n : in std_logic;
		    pop_req_n : in std_logic;
		    we_n : out std_logic;
		    push_empty : out std_logic;
		    push_ae : out std_logic;
		    push_hf : out std_logic;
		    push_af : out std_logic;
		    push_full : out std_logic;
		    push_error : out std_logic;
		    pop_empty : out std_logic;
		    pop_ae : out std_logic;
		    pop_hf : out std_logic;
		    pop_af : out std_logic;
		    pop_full : out std_logic;
		    pop_error : out std_logic;
		    wr_addr : out std_logic_vector( bit_width(depth)-1 downto 0 );
		    rd_addr : out std_logic_vector( bit_width(depth)-1 downto 0 );
		    push_word_count : out std_logic_vector( bit_width(depth+1)-1 downto 0 );
		    pop_word_count : out std_logic_vector( bit_width(depth+1)-1 downto 0 );
		    test : in std_logic
		);
  end component;


  -- Content from file, DW_fifoctl_s2_sf.vhdpp

  component DW_fifoctl_s2_sf
	
	generic (
		    depth : INTEGER range 4 to 16777216 := 8;
		    push_ae_lvl : INTEGER range 1 to 16777215 := 2;
		    push_af_lvl : INTEGER range 1 to 16777215 := 2;
		    pop_ae_lvl : INTEGER range 1 to 16777215 := 2;
		    pop_af_lvl : INTEGER range 1 to 16777215 := 2;
		    err_mode : INTEGER range 0 to 1 := 0;
		    push_sync : INTEGER range 1 to 3 := 2;
		    pop_sync : INTEGER range 1 to 3 := 2;
		    rst_mode : INTEGER range 0 to 1 := 0;
		    tst_mode : INTEGER range 0 to 1 := 0
		);
	
	port    (
		    clk_push : in std_logic;
		    clk_pop : in std_logic;
		    rst_n : in std_logic;
		    push_req_n : in std_logic;
		    pop_req_n : in std_logic;
		    we_n : out std_logic;
		    push_empty : out std_logic;
		    push_ae : out std_logic;
		    push_hf : out std_logic;
		    push_af : out std_logic;
		    push_full : out std_logic;
		    push_error : out std_logic;
		    pop_empty : out std_logic;
		    pop_ae : out std_logic;
		    pop_hf : out std_logic;
		    pop_af : out std_logic;
		    pop_full : out std_logic;
		    pop_error : out std_logic;
		    wr_addr : out std_logic_vector( bit_width(depth)-1 downto 0 );
		    rd_addr : out std_logic_vector( bit_width(depth)-1 downto 0 );
		    push_word_count : out std_logic_vector( bit_width(depth+1)-1 downto 0 );
		    pop_word_count : out std_logic_vector( bit_width(depth+1)-1 downto 0 );
		    test : in std_logic
		);
  end component;


  -- Content from file, DW_asymfifoctl_s2_sf.vhdpp

  component DW_asymfifoctl_s2_sf
	
	generic (
		    data_in_width  : INTEGER range 1 to 4096 ;
		    data_out_width : INTEGER range 1 to 4096 ;
		    depth : INTEGER range 4 to 16777216 := 8;
		    push_ae_lvl : INTEGER range 1 to 16777215 := 2;
		    push_af_lvl : INTEGER range 1 to 16777215 := 2;
		    pop_ae_lvl : INTEGER range 1 to 16777215 := 2;
		    pop_af_lvl : INTEGER range 1 to 16777215 := 2;
		    err_mode : INTEGER range 0 to 1 := 0;
		    push_sync : INTEGER range 1 to 3 := 2;
		    pop_sync : INTEGER range 1 to 3 := 2;
		    rst_mode : INTEGER range 0 to 1 := 1;
		    byte_order : INTEGER range 0 to 1 := 0
		);
	
	port    (
		    clk_push : in std_logic;
		    clk_pop : in std_logic;
		    rst_n : in std_logic;
		    push_req_n : in std_logic;
		    flush_n : in std_logic;
		    pop_req_n : in std_logic;
		    data_in : in std_logic_vector(data_in_width-1 downto 0);
		    rd_data : in std_logic_vector(maximum(data_in_width,
		    			data_out_width)-1 downto 0);
		    we_n : out std_logic;
		    push_empty : out std_logic;
		    push_ae : out std_logic;
		    push_hf : out std_logic;
		    push_af : out std_logic;
		    push_full : out std_logic;
		    ram_full : out std_logic;
		    part_wd : out std_logic;
		    push_error : out std_logic;
		    pop_empty : out std_logic;
		    pop_ae : out std_logic;
		    pop_hf : out std_logic;
		    pop_af : out std_logic;
		    pop_full : out std_logic;
		    pop_error : out std_logic;
		    wr_data : out std_logic_vector(maximum(data_in_width,
		    			data_out_width)-1 downto 0);
		    wr_addr : out std_logic_vector( bit_width(depth)-1 downto 0 );
		    rd_addr : out std_logic_vector( bit_width(depth)-1 downto 0 );
		    data_out : out std_logic_vector(data_out_width-1
		    			downto 0)
		);
  end component;


  -- Content from file, DW_cntr_gray.vhdpp

  component DW_cntr_gray

  generic (
    width : positive);                  -- word width

  port (
    clk    : in  std_logic;           -- clock
    rst_n  : in  std_logic;           -- asynchronous reset, active low
    init_n : in  std_logic;           -- synchronous reset, active low
    load_n : in  std_logic;           -- load enable, active low
    data   : in  std_logic_vector(width-1 downto 0);   -- load data input
    cen    : in  std_logic;           -- count enable
    count  : out std_logic_vector(width-1 downto 0));  -- counter output

  end component;


  -- Content from file, DW_mult_seq.vhdpp

  component DW_mult_seq
 
  generic (
    a_width    : positive;                    -- multiplier word width
    b_width    : positive;                    -- multiplicand word width
    tc_mode    : integer range 0 to 1 := 0;   -- '0' : unsigned, '1' : 2's compl.
    num_cyc    : integer := 3;                -- number of cycles to perform multiplication 
    rst_mode   : integer range 0 to 1 := 0;   -- '0' : async, '1' : sync
    input_mode : integer range 0 to 1 := 1;   -- Registered inputs 0=no 1=yes
    output_mode: integer range 0 to 1 := 1;   -- Registered outputs 0=no 1=yes
    early_start: integer range 0 to 1 := 0);   -- Computation start


 
  port (
    clk     : in  std_logic;                -- register clock
    rst_n   : in  std_logic;                -- register reset
    hold    : in  std_logic;                -- hold multiplication '1' 
    start   : in  std_logic;                -- start multiplication '1' 
    a       : in  std_logic_vector(a_width-1 downto 0);  -- multiplier
    b       : in  std_logic_vector(b_width-1 downto 0);  -- multiplicand
    complete: out std_logic;               -- multiplication finished '1'  
    product : out std_logic_vector(a_width+b_width-1 downto 0)); -- product 
 
  end component;


  -- Content from file, DW_div_seq.vhdpp

  component DW_div_seq
 
  generic (
    a_width    : positive;                    -- dividend word width
    b_width    : positive;                    -- divisor word width
    tc_mode    : integer range 0 to 1 := 0;   -- '0' : unsigned, '1' : 2's compl.
    num_cyc    : integer := 3;                -- number of cycles to perform dividcation 
    rst_mode   : integer range 0 to 1 := 0;   -- '0' : async, '1' : sync
    input_mode : integer range 0 to 1 := 1;   -- Registered inputs 0=no 1=yes
    output_mode: integer range 0 to 1 := 1;   -- Registered outputs 0=no 1=yes
    early_start: integer range 0 to 1 := 0);   -- Computation start


 
  port (
    clk     : in  std_logic;                -- register clock
    rst_n   : in  std_logic;                -- register reset
    hold    : in  std_logic;                -- hold dividcation '1' 
    start   : in  std_logic;                -- start dividcation '1' 
    a       : in  std_logic_vector(a_width-1 downto 0);  -- divider
    b       : in  std_logic_vector(b_width-1 downto 0);  -- dividcand
    complete: out std_logic;               -- dividcation finished '1'  
    divide_by_0 : out std_logic;          -- divide-by-0 flag
    quotient    : out std_logic_vector(a_width-1 downto 0);  -- quotient
    remainder   : out std_logic_vector(b_width-1 downto 0)); -- remainder
 
  end component;


  -- Content from file, DW_sqrt_seq.vhdpp

  component DW_sqrt_seq
 
  generic (
    width       : positive;                   -- radicand word width
    tc_mode    : integer range 0 to 1 := 0;   -- '0' : unsigned, '1' : 2's compl.
    num_cyc    : integer := 3;                -- number of cycles to perform sqrt 
    rst_mode   : integer range 0 to 1 := 0;   -- '0' : async, '1' : sync
    input_mode : integer range 0 to 1 := 1;   -- Registered inputs 0=no 1=yes
    output_mode: integer range 0 to 1 := 1;   -- Registered outputs 0=no 1=yes
    early_start: integer range 0 to 1 := 0);  -- Computation start


 
  port (
    clk     : in  std_logic;                -- register clock
    rst_n   : in  std_logic;                -- register reset
    hold    : in  std_logic;                -- hold sqrt'1' 
    start   : in  std_logic;                -- start sqrt'1' 
    a           : in  std_logic_vector(width-1 downto 0);  -- radicand
    complete    : out std_logic;          -- square root finished '1');
    root        : out std_logic_vector((width+1)/2-1 downto 0));  -- root
 
  end component;


  -- Content from file, DW_fir.vhdpp

  component DW_fir
    generic(data_in_width : POSITIVE := 8;
            coef_width : POSITIVE := 8;  
            data_out_width : POSITIVE := 18; 
            order : POSITIVE range 2 to 256 := 6); 
    port(clk : std_logic;
         rst_n : std_logic;
         coef_shift_en : std_logic;
         tc : std_logic;
         data_in : std_logic_vector(data_in_width-1 downto 0);
         coef_in : std_logic_vector(coef_width-1 downto 0);  
         init_acc_val : std_logic_vector(data_out_width-1 downto 0);
         data_out : out std_logic_vector(data_out_width-1 downto 0); 
         coef_out : out std_logic_vector(coef_width-1 downto 0));           
  end component;


  -- Content from file, DW_fir_seq.vhdpp

  component DW_fir_seq
  generic(data_in_width : POSITIVE := 8;
          coef_width : POSITIVE := 8;
          data_out_width : POSITIVE := 18;
          order : POSITIVE range 2 to 256 := 6);
  port(clk : std_logic;
       rst_n : std_logic;
       coef_shift_en : std_logic;
       tc : std_logic;
       run : std_logic;
       data_in : std_logic_vector(data_in_width-1 downto 0);
       coef_in : std_logic_vector(coef_width-1 downto 0);  
       init_acc_val : std_logic_vector(data_out_width-1 downto 0);         
       start : out std_logic;
       hold : out std_logic;
       data_out : out std_logic_vector(data_out_width-1 downto 0));
  end component;


  -- Content from file, DW_iir_dc.vhdpp

  component DW_iir_dc
	generic(data_in_width	: POSITIVE := 8;
		data_out_width	: POSITIVE := 16;
		frac_data_out_width	: NATURAL := 4;
		feedback_width	: POSITIVE := 12;
		max_coef_width	: POSITIVE := 8;
		frac_coef_width	: NATURAL := 4;
		saturation_mode	: NATURAL range 0 to 1 := 0;
                out_reg		: NATURAL range 0 to 1 := 1);
	port(	clk		: in  std_logic;
		rst_n		: in  std_logic;
                init_n		: in  std_logic;
		enable		: in  std_logic;
		A1_coef		: in  std_logic_vector(max_coef_width-1 downto 0);
		A2_coef		: in  std_logic_vector(max_coef_width-1 downto 0);
		B0_coef		: in  std_logic_vector(max_coef_width-1 downto 0);
		B1_coef		: in  std_logic_vector(max_coef_width-1 downto 0);
		B2_coef		: in  std_logic_vector(max_coef_width-1 downto 0);
		data_in		: in  std_logic_vector(data_in_width-1 downto 0);
		data_out	: out std_logic_vector(data_out_width-1 downto 0);
		saturation	: out std_logic);
  end component;


  -- Content from file, DW_iir_sc.vhdpp

  component DW_iir_sc
	generic(data_in_width	: POSITIVE := 4;
		data_out_width	: POSITIVE := 6;
		frac_data_out_width	: NATURAL := 0;
		feedback_width	: POSITIVE := 8;
		max_coef_width	: POSITIVE range 2 to 31 := 4;
		frac_coef_width	: NATURAL range 0 to 30 := 0;
		saturation_mode	: NATURAL range 0 to 1 := 1;
                out_reg		: NATURAL range 0 to 1 := 1;
		A1_coef		: INTEGER := -2;
		A2_coef		: INTEGER :=  3;
		B0_coef		: INTEGER :=  5;
		B1_coef		: INTEGER := -6;
		B2_coef		: INTEGER := -2);
	port(	clk		: in  std_logic;
        	rst_n		: in  std_logic;
		init_n		: in  std_logic;
		enable		: in  std_logic;
		data_in		: in  std_logic_vector(data_in_width-1 downto 0);
		data_out	: out std_logic_vector(data_out_width-1 downto 0);
		saturation	: out std_logic);
  end component;


  -- Content from file, DW_sync.vhdpp

  component DW_sync
   generic (
     width       : POSITIVE range 1 to 1024 := 8;  -- input width
     f_sync_type : NATURAL := 2;
     tst_mode    : NATURAL  range 0 to 2 := 0;
     verif_en    : NATURAL  range 0 to 4 := 1   -- selection of the number of missampling stages
   );

   port (
     clk_d     : in std_logic;
     rst_d_n   : in std_logic;
     init_d_n  : in std_logic;
     data_s    : in std_logic_vector(width-1 downto 0);
     test      : in std_logic;
     data_d    : out std_logic_vector(width-1 downto 0)
   );
  end component;


  -- Content from file, DW_data_sync_1c.vhdpp

  component DW_data_sync_1c
   generic (
     width       : POSITIVE range 1 to 1024 := 8;  -- input width
     f_sync_type : NATURAL := 2;
     filt_size   : POSITIVE range 1 to 8 := 1;
     tst_mode    : NATURAL range 0 to 1 := 0;
     verif_en    : NATURAL range 0 to 4 := 2   -- selection of the number of missampling stages
   );

   port (
     clk_d     : in std_logic;
     rst_d_n   : in std_logic;
     init_d_n  : in std_logic;
     data_s    : in std_logic_vector(width-1 downto 0);
     filt_d    : in std_logic_vector(filt_size-1 downto 0);
     test      : in std_logic;
     data_avail_d  : out std_logic;
     data_d    : out std_logic_vector(width-1 downto 0);
     max_skew_d    : out std_logic_vector(filt_size downto 0)
   );
  end component;


  -- Content from file, DW_pulse_sync.vhdpp

  component DW_pulse_sync
  generic (
    reg_event   :     natural RANGE 0 to 1 := 1;
    f_sync_type :     natural              := 2; 
    tst_mode    :     natural RANGE 0 to 2 := 0; 
    verif_en    :     natural RANGE 0 to 4 := 1; 
    pulse_mode  :     natural RANGE 0 to 3 := 0 
    ); 
  port (

    clk_s    : in std_logic;  -- clock  for source domain
    rst_s_n  : in std_logic;  -- active low async. reset in clk_s domain
    init_s_n : in std_logic;  -- active low sync. reset in clk_s domain
    event_s  : in std_logic;  -- event pulse  (active high event)

    clk_d    : in  std_logic;  -- clock  for destination domain
    rst_d_n  : in  std_logic;  -- active low async. reset in clk_d domain
    init_d_n : in  std_logic;  -- active low sync. reset in clk_d domain
    event_d  : out std_logic;  -- event pulse output (active high event)

    test     : in  std_logic   -- test mode

    );
  end component;


  -- Content from file, DW_pulseack_sync.vhdpp

  component DW_pulseack_sync
  generic (
    reg_event   :     NATURAL range 0 to 1 := 1;
    reg_ack     :     NATURAL range 0 to 1 := 1;
    ack_delay   :     NATURAL range 0 to 1 := 1;
    f_sync_type :     NATURAL              := 2; 
    r_sync_type :     NATURAL              := 2; 
    tst_mode    :     NATURAL range 0 to 1 := 0; 
    verif_en    :     NATURAL range 0 to 4 := 1;
    pulse_mode  :     NATURAL range 0 to 3 := 0 
    ); 
  port (

    clk_s    : in std_logic;  -- clock  for source domain
    rst_s_n  : in std_logic;  -- active low async. reset in clk_s domain
    init_s_n : in std_logic;  -- active low sync. reset in clk_s domain
    event_s  : in std_logic;  -- event pulseack  (active high event)
    ack_s    : out std_logic;   -- source domain event acknowledge output
    busy_s   : out std_logic;   -- source domain busy status output

    clk_d    : in  std_logic;  -- clock  for destination domain
    rst_d_n  : in  std_logic;  -- active low async. reset in clk_d domain
    init_d_n : in  std_logic;  -- active low sync. reset in clk_d domain
    event_d  : out std_logic;  -- event pulseack output (active high event)

    test     : in  std_logic  -- test mode
   );
  end component;


  -- Content from file, DW_data_sync.vhdpp

  component DW_data_sync

 generic (
           width       :     natural := 8; -- default is byte
           pend_mode   :     natural RANGE 0 to 1:= 1; -- use pending data buffer
           ack_delay   :     natural RANGE 0 to 1:= 1; -- ack data transfer when captured
           f_sync_type :     natural             := 2; -- 2 pos syncs src -> dest (request)
           r_sync_type :     natural             := 2; -- 2 pos syncs dest -> src (ack)
           tst_mode    :     natural RANGE 0 to 1:= 0; 
           verif_en    :     natural RANGE 0 to 4:= 1; 
           send_mode   :     natural RANGE 0 to 3:= 0  -- pulse mode type for pas
         ); 
 
port (
      clk_s           : in std_logic;
      rst_s_n         : in std_logic;
      init_s_n        : in std_logic;
      send_s          : in std_logic;
      data_s          : in std_logic_vector (width-1 downto 0);
      empty_s         : out std_logic;
      full_s          : out std_logic;
      done_s          : out std_logic;

      clk_d           : in std_logic;
      rst_d_n         : in std_logic;
      init_d_n        : in std_logic;
      data_avail_d    : out std_logic;
      data_d          : out std_logic_vector (width-1 downto 0);
      
      test            : in std_logic
      );

  end component;


  -- Content from file, DW_data_sync_na.vhdpp

  component DW_data_sync_na
   generic (
     width       : POSITIVE range 1 to 1024 := 8;
     f_sync_type : NATURAL  := 2;
     tst_mode    : NATURAL  range 0 to 1 := 0;
     verif_en    : NATURAL  range 0 to 4 := 1;
     send_mode   : NATURAL  range 0 to 3 := 0
   );

   port (
     clk_s     : in std_logic;
     rst_s_n   : in std_logic;
     init_s_n  : in std_logic;
     send_s    : in std_logic;
     data_s    : in std_logic_vector(width-1 downto 0);
     clk_d     : in std_logic;
     rst_d_n   : in std_logic;
     init_d_n  : in std_logic;
     test      : in std_logic;
     data_avail_d  : out std_logic;
     data_d    : out std_logic_vector(width-1 downto 0)
   );
  end component;


  -- Content from file, DW_gray_sync.vhdpp

  component DW_gray_sync
   generic (
     width              : POSITIVE range 1 to 1024 := 8;   -- input width
     offset             : NATURAL  range 0 to 1073741824 := 0;  -- offset for non-integer powers of 2
     reg_count_d        : NATURAL  range 0 to 1 := 1;      -- register count_d output
     f_sync_type        : NATURAL := 2;
     tst_mode           : NATURAL  range 0 to 2 := 0;
     verif_en           : NATURAL  range 0 to 4 := 1;      -- selection of the number of missampling stages
     pipe_delay         : NATURAL  range 0 to 2 := 0;
     reg_count_s        : NATURAL  range 0 to 1 := 1;      -- register count_s output
     reg_offset_count_s : NATURAL  range 0 to 1 := 1       -- register offset_count_s output
   );

   port (
     clk_s           : in std_logic;
     rst_s_n         : in std_logic;
     init_s_n        : in std_logic;
     en_s            : in std_logic;
     count_s         : out std_logic_vector(width-1 downto 0);
     offset_count_s  : out std_logic_vector(width-1 downto 0);

     clk_d           : in std_logic;
     rst_d_n         : in std_logic;
     init_d_n        : in std_logic;
     count_d         : out std_logic_vector(width-1 downto 0);

     test            : in std_logic
   );
  end component;


  -- Content from file, DW_reset_sync.vhdpp

  component DW_reset_sync
   generic (
     f_sync_type : NATURAL := 2;
     r_sync_type : NATURAL := 2;
     clk_d_faster: NATURAL range 0 to 15 := 1;
     reg_in_prog : NATURAL range 0 to 1  := 1;
     tst_mode    : NATURAL range 0 to 1  := 0;
     verif_en    : NATURAL range 0 to 4  := 1
   );

   port (
     clk_s         : in std_logic;
     rst_s_n       : in std_logic;
     init_s_n      : in std_logic;
     clr_s         : in std_logic;
     clr_sync_s    : out std_logic;
     clr_in_prog_s : out std_logic;
     clr_cmplt_s   : out std_logic;

     clk_d         : in std_logic;
     rst_d_n       : in std_logic;
     init_d_n      : in std_logic;
     clr_d         : in std_logic;
     clr_in_prog_d : out std_logic;
     clr_sync_d    : out std_logic;
     clr_cmplt_d   : out std_logic;

     test          : in std_logic
   );
  end component;


  -- Content from file, DW_stream_sync.vhdpp

  component DW_stream_sync
   generic (
     width        : POSITIVE range 1 to 1024 := 8;
     depth        : POSITIVE range 2 to 256  := 4;
     prefill_lvl  : NATURAL  range 0 to 255  := 0;
     f_sync_type  : NATURAL  := 2;
     reg_stat     : NATURAL  range 0 to 1    := 1;
     tst_mode     : NATURAL  range 0 to 2    := 0;
     verif_en     : NATURAL  range 0 to 4    := 1;
     r_sync_type  : NATURAL  := 2;
     clk_d_faster : NATURAL  range 0 to 15   := 1;
     reg_in_prog  : NATURAL  range 0 to 1    := 1
   );

   port (
     clk_s         : in std_logic;
     rst_s_n       : in std_logic;
     init_s_n      : in std_logic;
     clr_s         : in std_logic;
     send_s        : in std_logic;
     data_s        : in std_logic_vector(width-1 downto 0);
     clr_sync_s    : out std_logic;
     clr_in_prog_s : out std_logic; 
     clr_cmplt_s   : out std_logic; 

     clk_d         : in std_logic;
     rst_d_n       : in std_logic;
     init_d_n      : in std_logic;
     clr_d         : in std_logic;
     prefill_d     : in std_logic;
     clr_in_prog_d : out std_logic; 
     clr_sync_d    : out std_logic;
     clr_cmplt_d   : out std_logic; 
     data_avail_d  : out std_logic;
     data_d        : out std_logic_vector(width-1 downto 0);
     prefilling_d  : out std_logic;

     test          : in std_logic
   );
  end component;


  -- Content from file, DW_piped_mac.vhdpp

  component DW_piped_mac
   generic (
     a_width     : POSITIVE := 8;  -- input 'a' width, at least 1
     b_width     : POSITIVE := 8;  -- input 'b' width, at least 1
     acc_width   : POSITIVE range 2 to 32768 := 16; -- output 'acc' width, at least 2 to something large
     tc          : NATURAL  range 0 to 1    := 0;  -- twos complement
     pipe_reg    : NATURAL  range 0 to 7    := 0;  -- pipeline register insertion
     id_width    : POSITIVE range 1 to 1024 := 1;
     no_pm       : NATURAL  range 0 to 1    := 0;  -- no DW_pipe_mgr configuration
     op_iso_mode : NATURAL  range 0 to 4    := 0   -- operand isolation selection
   );

   port (
     clk         : in std_logic;
     rst_n       : in std_logic;
     init_n      : in std_logic;
     clr_acc_n   : in std_logic;
     a           : in std_logic_vector(a_width-1 downto 0);
     b           : in std_logic_vector(b_width-1 downto 0);
     acc         : out std_logic_vector(acc_width-1 downto 0);
     launch      : in std_logic;
     launch_id   : in std_logic_vector(id_width-1 downto 0);
     pipe_full   : out std_logic;
     pipe_ovf    : out std_logic;
     accept_n    : in std_logic;
     arrive      : out std_logic;
     arrive_id   : out std_logic_vector(id_width-1 downto 0);
     push_out_n  : out std_logic;
     pipe_census : out std_logic_vector(2 downto 0)
   );
  end component;


  -- Content from file, DW_asymdata_inbuf.vhdpp

  component DW_asymdata_inbuf
	
	generic (
		    in_width    : INTEGER range 1 to 256 := 8;
		    out_width   : INTEGER range 1 to 256 := 16;
		    err_mode    : INTEGER range 0 to 1 := 0;
		    byte_order  : INTEGER range 0 to 1 := 0;
		    flush_value : INTEGER range 0 to 1 := 0
		);
	
	port    (
		    clk_push     : in std_logic;
		    rst_push_n   : in std_logic;
		    init_push_n  : in std_logic;
		    push_req_n   : in std_logic;
		    data_in      : in std_logic_vector(in_width-1 downto 0);
		    flush_n      : in std_logic;
		    fifo_full    : in std_logic;

		    push_wd_n    : out std_logic;
		    data_out     : out std_logic_vector(out_width-1 downto 0);
		    inbuf_full   : out std_logic;
		    part_wd      : out std_logic;
		    push_error   : out std_logic
		);
  end component;


  -- Content from file, DW_asymdata_outbuf.vhdpp

  component DW_asymdata_outbuf
	
	generic (
		    in_width    : INTEGER range 1 to 256 := 16;
		    out_width   : INTEGER range 1 to 256 := 8;
		    err_mode    : INTEGER range 0 to 1 := 0;
		    byte_order  : INTEGER range 0 to 1 := 0
		);
	
	port    (
		    clk_pop      : in std_logic;
		    rst_pop_n    : in std_logic;
		    init_pop_n   : in std_logic;
		    pop_req_n    : in std_logic;
		    data_in      : in std_logic_vector(in_width-1 downto 0);
		    fifo_empty   : in std_logic;

		    pop_wd_n     : out std_logic;
		    data_out     : out std_logic_vector(out_width-1 downto 0);
		    part_wd      : out std_logic;
		    pop_error    : out std_logic
		);
  end component;


  -- Content from file, DW_fifoctl_2c_df.vhdpp

  component DW_fifoctl_2c_df
	
	generic (
		    width            : POSITIVE range 1 to 1024 := 8;
		    ram_depth        : POSITIVE range 4 to 16777216 := 8;
                    mem_mode         : NATURAL  range 0 to 7  := 3;
                    f_sync_type      : NATURAL  := 2;
                    r_sync_type      : NATURAL  := 2;
                    clk_ratio        : INTEGER  := 1; --  range -7 to 7 := 1;
                    ram_re_ext       : NATURAL  range 0 to 1  := 0;
                    err_mode         : NATURAL  range 0 to 1  := 0;
                    tst_mode         : NATURAL  range 0 to 2  := 0;
                    verif_en         : NATURAL  range 0 to 4  := 1;
		    clr_dual_domain  : NATURAL  range 0 to 1  := 1;
                    arch_type        : NATURAL  range 0 to 1  := 0
		);
	
	port    (
                    clk_s           : in std_logic;
                    rst_s_n         : in std_logic;
                    init_s_n        : in std_logic;
                    clr_s           : in std_logic;
                    ae_level_s      : in std_logic_vector( bit_width(ram_depth+1)-1 downto 0);
                    af_level_s      : in std_logic_vector( bit_width(ram_depth+1)-1 downto 0);
                    push_s_n        : in std_logic;
                    clr_sync_s      : out std_logic;
                    clr_in_prog_s   : out std_logic;
                    clr_cmplt_s     : out std_logic;
                    wr_en_s_n       : out std_logic;
                    wr_addr_s       : out std_logic_vector(bit_width(ram_depth)-1 downto 0);
                    fifo_word_cnt_s : out std_logic_vector(bit_width((ram_depth+1+(mem_mode mod 2)+((mem_mode/2) mod 2))+1)-1 downto 0);
                    word_cnt_s      : out std_logic_vector(bit_width(ram_depth+1)-1 downto 0);
                    fifo_empty_s    : out std_logic;
                    empty_s         : out std_logic;
                    almost_empty_s  : out std_logic;
                    half_full_s     : out std_logic;
                    almost_full_s   : out std_logic;
                    full_s          : out std_logic;
                    error_s         : out std_logic;

                    clk_d           : in std_logic;
                    rst_d_n         : in std_logic;
                    init_d_n        : in std_logic;
                    clr_d           : in std_logic;
                    ae_level_d      : in std_logic_vector(bit_width((ram_depth+1+(mem_mode mod 2)+((mem_mode/2) mod 2))+1)-1 downto 0);
                    af_level_d      : in std_logic_vector(bit_width((ram_depth+1+(mem_mode mod 2)+((mem_mode/2) mod 2))+1)-1 downto 0);
                    pop_d_n         : in std_logic;
		    rd_data_d       : in std_logic_vector(width-1 downto 0);
                    clr_sync_d      : out std_logic;
                    clr_in_prog_d   : out std_logic;
                    clr_cmplt_d     : out std_logic;
                    ram_re_d_n      : out std_logic;
                    rd_addr_d       : out std_logic_vector(bit_width(ram_depth)-1 downto 0);
		    data_d          : out std_logic_vector(width-1 downto 0);
                    word_cnt_d      : out std_logic_vector(bit_width((ram_depth+1+(mem_mode mod 2)+((mem_mode/2) mod 2))+1)-1 downto 0);
                    ram_word_cnt_d  : out std_logic_vector(bit_width(ram_depth+1)-1 downto 0);
                    empty_d         : out std_logic;
                    almost_empty_d  : out std_logic;
                    half_full_d     : out std_logic;
                    almost_full_d   : out std_logic;
                    full_d          : out std_logic;
                    error_d         : out std_logic;

		    test : in std_logic
		);
  end component;


  -- Content from file, DW_asymfifoctl_2c_df.vhdpp

  component DW_asymfifoctl_2c_df
	
	generic (
		    data_s_width     : POSITIVE range 1 to 1024 := 16;
		    data_d_width     : POSITIVE range 1 to 1024 := 8;
		    ram_depth        : POSITIVE range 4 to 1024 := 8;
                    mem_mode         : NATURAL  range 0 to 7  := 5;
                    arch_type        : NATURAL  range 0 to 1  := 0;
                    f_sync_type      : NATURAL  := 2;
                    r_sync_type      : NATURAL  := 2;
                    byte_order       : NATURAL  range 0 to 1  := 0;
                    flush_value      : NATURAL  range 0 to 1  := 0;
                    clk_ratio        : INTEGER  := 1; --  range -7 to 7 := 1;  -- NOTE: '0' is illegal
                    ram_re_ext       : NATURAL  range 0 to 1  := 1;
                    err_mode         : NATURAL  range 0 to 1  := 0;
                    tst_mode         : NATURAL  range 0 to 1  := 0;
                    verif_en         : NATURAL  := 1  -- only values legal are 0, 1, 4
		);
	
	port    (
                    clk_s             : in std_logic;
                    rst_s_n           : in std_logic;
                    init_s_n          : in std_logic;
                    clr_s             : in std_logic;
                    ae_level_s        : in std_logic_vector(bit_width(ram_depth+1)-1 downto 0);
                    af_level_s        : in std_logic_vector(bit_width(ram_depth+1)-1 downto 0);
                    push_s_n          : in std_logic;
                    flush_s_n         : in std_logic;
                    data_s            : in std_logic_vector(data_s_width-1 downto 0);
                    clr_sync_s        : out std_logic;
                    clr_in_prog_s     : out std_logic;
                    clr_cmplt_s       : out std_logic;
                    wr_en_s_n         : out std_logic;
                    wr_addr_s         : out std_logic_vector(bit_width(ram_depth)-1 downto 0);
                    wr_data_s         : out std_logic_vector(maximum(data_s_width, data_d_width)-1 downto 0);
                    inbuf_part_wd_s   : out std_logic;
                    inbuf_full_s      : out std_logic;
                    fifo_word_cnt_s   : out std_logic_vector(bit_width((ram_depth+1+(mem_mode mod 2)+((mem_mode/2) mod 2))+1)-1 downto 0);
                    word_cnt_s        : out std_logic_vector(bit_width(ram_depth+1)-1 downto 0);
                    fifo_empty_s      : out std_logic;
                    empty_s           : out std_logic;
                    almost_empty_s    : out std_logic;
                    half_full_s       : out std_logic;
                    almost_full_s     : out std_logic;
                    ram_full_s        : out std_logic;
                    push_error_s      : out std_logic;

                    clk_d             : in std_logic;
                    rst_d_n           : in std_logic;
                    init_d_n          : in std_logic;
                    clr_d             : in std_logic;
                    ae_level_d        : in std_logic_vector(bit_width((ram_depth+1+(mem_mode mod 2)+((mem_mode/2) mod 2))+1)-1 downto 0);
                    af_level_d        : in std_logic_vector(bit_width((ram_depth+1+(mem_mode mod 2)+((mem_mode/2) mod 2))+1)-1 downto 0);
                    pop_d_n           : in std_logic;
		    rd_data_d         : in std_logic_vector(maximum(data_s_width, data_d_width)-1 downto 0);
                    clr_sync_d        : out std_logic;
                    clr_in_prog_d     : out std_logic;
                    clr_cmplt_d       : out std_logic;
                    ram_re_d_n        : out std_logic;
                    rd_addr_d         : out std_logic_vector(bit_width(ram_depth)-1 downto 0);
		    data_d            : out std_logic_vector(data_d_width-1 downto 0);
                    outbuf_part_wd_d  : out std_logic;
                    word_cnt_d        : out std_logic_vector(bit_width((ram_depth+1+(mem_mode mod 2)+((mem_mode/2) mod 2))+1)-1 downto 0);
                    ram_word_cnt_d    : out std_logic_vector(bit_width(ram_depth+1)-1 downto 0);
                    empty_d           : out std_logic;
                    almost_empty_d    : out std_logic;
                    half_full_d       : out std_logic;
                    almost_full_d     : out std_logic;
                    full_d            : out std_logic;
                    pop_error_d       : out std_logic;

		    test : in std_logic
		);
  end component;


  -- Content from file, DW_lp_fifoctl_1c_df.vhdpp

  component DW_lp_fifoctl_1c_df
	generic (
                    width        : POSITIVE range 1 to 4096 := 8;
                    depth        : POSITIVE range 4 to 268435456 := 8;
                    mem_mode     : NATURAL  range 0 to 7  := 3;
                    arch_type    : NATURAL  range 0 to 4  := 1;
                    af_from_top  : NATURAL  range 0 to 1  := 1;
                    ram_re_ext   : NATURAL  range 0 to 1  := 0;
                    err_mode     : NATURAL  range 0 to 1  := 0
		);
	
	port    (
                    clk          : in std_logic;
                    rst_n        : in std_logic;
                    init_n       : in std_logic;
                    ae_level     : in std_logic_vector(bit_width(depth+1)-1 downto 0);
                    af_level     : in std_logic_vector(bit_width(depth+1)-1 downto 0);
                    level_change : in std_logic;
                    push_n       : in std_logic;
                    data_in      : in std_logic_vector(width-1 downto 0);
                    pop_n        : in std_logic;
                    rd_data      : in std_logic_vector(width-1 downto 0);

                    ram_we_n     : out std_logic;
                    wr_addr      : out std_logic_vector(bit_width(depth-minimum(arch_type*3, (2+(mem_mode mod 2)+(mem_mode/2)-(mem_mode/4)-(mem_mode/6)-(arch_type mod 2))))-1 downto 0);
                    wr_data      : out std_logic_vector(width-1 downto 0);
                    ram_re_n     : out std_logic;
                    rd_addr      : out std_logic_vector(bit_width(depth-minimum(arch_type*3, (2+(mem_mode mod 2)+(mem_mode/2)-(mem_mode/4)-(mem_mode/6)-(arch_type mod 2))))-1 downto 0);
                    data_out     : out std_logic_vector(width-1 downto 0);
                    word_cnt     : out std_logic_vector(bit_width(depth+1)-1 downto 0);
                    empty        : out std_logic;
                    almost_empty : out std_logic;
                    half_full    : out std_logic;
                    almost_full  : out std_logic;
                    full         : out std_logic;
                    error        : out std_logic
		);
  end component;


  -- Content from file, DW_lp_pipe_mgr.vhdpp

  component DW_lp_pipe_mgr
   generic (
     stages      : POSITIVE range 1 to 1023 := 2;  -- number of pipeline stages
     id_width    : POSITIVE range 1 to 1024 := 2   -- input launch_id width
   );


   port (
     clk         : in std_logic;
     rst_n       : in std_logic;
     init_n      : in std_logic;
     launch      : in std_logic;
     launch_id   : in std_logic_vector(id_width-1 downto 0);
     pipe_full   : out std_logic;
     pipe_ovf    : out std_logic;
     pipe_en_bus : out std_logic_vector(stages-1 downto 0);
     accept_n    : in std_logic;
     arrive      : out std_logic;
     arrive_id   : out std_logic_vector(id_width-1 downto 0);
     push_out_n  : out std_logic;
     pipe_census : out std_logic_vector(bit_width(stages+1)-1 downto 0)
   );
  end component;


  -- Content from file, DW_lp_piped_mult.vhdpp

  component DW_lp_piped_mult
   generic (
     a_width     : POSITIVE  := 8;
     b_width     : POSITIVE  := 8;
     id_width    : POSITIVE range 1 to 1024 := 8;
     in_reg      : NATURAL  range 0 to 1    := 0;
     stages      : POSITIVE range 1 to 1022 := 4;
     out_reg     : NATURAL  range 0 to 1    := 0;
     tc_mode     : NATURAL  range 0 to 1    := 0;
     rst_mode    : NATURAL  range 0 to 1    := 0;
     op_iso_mode : NATURAL  range 0 to 4    := 0
   );

   port (
     clk         : in std_logic;
     rst_n       : in std_logic;
     a           : in std_logic_vector(a_width-1 downto 0);
     b           : in std_logic_vector(b_width-1 downto 0);
     product     : out std_logic_vector(a_width+b_width-1 downto 0);
     launch      : in std_logic;
     launch_id   : in std_logic_vector(id_width-1 downto 0);
     pipe_full   : out std_logic;
     pipe_ovf    : out std_logic;
     accept_n    : in std_logic;
     arrive      : out std_logic;
     arrive_id   : out std_logic_vector(id_width-1 downto 0);
     push_out_n  : out std_logic;
     pipe_census : out std_logic_vector(bit_width(maximum(1,in_reg+(stages-1)+out_reg)+1)-1 downto 0)
   );
  end component;


  -- Content from file, DW_lp_piped_prod_sum.vhdpp

  component DW_lp_piped_prod_sum
   generic (
     a_width     : POSITIVE  := 8;
     b_width     : POSITIVE  := 8;
     num_inputs  : POSITIVE  := 2;
     sum_width   : POSITIVE  := 17;
     id_width    : POSITIVE range 1 to 1024 := 8;
     in_reg      : NATURAL  range 0 to 1    := 0;
     stages      : POSITIVE range 1 to 1022 := 4;
     out_reg     : NATURAL  range 0 to 1    := 0;
     tc_mode     : NATURAL  range 0 to 1    := 0;
     rst_mode    : NATURAL  range 0 to 1    := 0;
     op_iso_mode : NATURAL  range 0 to 4    := 0
   );

   port (
     clk         : in std_logic;
     rst_n       : in std_logic;
     a           : in std_logic_vector((a_width*num_inputs)-1 downto 0);
     b           : in std_logic_vector((b_width*num_inputs)-1 downto 0);
     sum         : out std_logic_vector(sum_width-1 downto 0);
     launch      : in std_logic;
     launch_id   : in std_logic_vector(id_width-1 downto 0);
     pipe_full   : out std_logic;
     pipe_ovf    : out std_logic;
     accept_n    : in std_logic;
     arrive      : out std_logic;
     arrive_id   : out std_logic_vector(id_width-1 downto 0);
     push_out_n  : out std_logic;
     pipe_census : out std_logic_vector(bit_width(maximum(1,in_reg+(stages-1)+out_reg)+1)-1 downto 0)
   );
  end component;


  -- Content from file, DW_fifoctl_s1_sf.vhdpp

  component DW_fifoctl_s1_sf
	
	generic (
		    depth : INTEGER range 2 to 16777216 := 4;
		    ae_level : INTEGER range 1 to 16777215 := 1;
		    af_level : INTEGER range 1 to 16777215 := 1;
		    err_mode : INTEGER range 0 to 2 := 0;
		    rst_mode : INTEGER range 0 to 1 := 0
		);
	
	port    (
		    clk : in std_logic;
		    rst_n : in std_logic;
		    push_req_n : in std_logic;
		    pop_req_n : in std_logic;
		    diag_n : in std_logic;
		    we_n : out std_logic;
		    empty : out std_logic;
		    almost_empty : out std_logic;
		    half_full : out std_logic;
		    almost_full : out std_logic;
		    full : out std_logic;
		    error : out std_logic;
		    wr_addr : out std_logic_vector( bit_width(depth)-1 downto 0 );
		    rd_addr : out std_logic_vector( bit_width(depth)-1 downto 0 )
		);
  end component;


  -- Content from file, DW_data_qsync_lh.vhdpp

  component DW_data_qsync_lh
  generic (
           width       :     natural := 8; -- default is byte
           clk_ratio   :     natural := 2; -- 
           reg_data_s  :     natural := 1; -- 
           reg_data_d  :     natural := 1; 
           tst_mode    :     natural := 0 
);
  port (
        clk_s           : in std_logic;
        rst_s_n         : in std_logic;
        init_s_n        : in std_logic;
        send_s          : in std_logic;
        data_s          : in std_logic_vector (width-1 downto 0);

        clk_d           : in std_logic;
        rst_d_n         : in std_logic;
        init_d_n        : in std_logic;
        data_avail_d    : out std_logic;
        data_d          : out std_logic_vector (width-1 downto 0);
      
        test            : in std_logic
      );
  end component;


  -- Content from file, DW_data_qsync_hl.vhdpp

  component DW_data_qsync_hl
  generic (
           width       :     natural := 8; -- default is byte
           clk_ratio   :     natural := 2; -- 
           tst_mode    :     natural := 0 
);
  port (
        clk_s           : in std_logic;
        rst_s_n         : in std_logic;
        init_s_n        : in std_logic;
        send_s          : in std_logic;
        data_s          : in std_logic_vector (width-1 downto 0);

        clk_d           : in std_logic;
        rst_d_n         : in std_logic;
        init_d_n        : in std_logic;
        data_avail_d    : out std_logic;
        data_d          : out std_logic_vector (width-1 downto 0);
      
        test            : in std_logic
      );
  end component;


  -- Content from file, DW_dct_2d.vhdpp

  component DW_dct_2d
  generic (  
              bpp : natural := 8;
              n   : natural := 8;
              reg_out : natural := 0;
	      tc_mode : natural := 0; --type of input data:1 = two's
	      rt_mode : natural := 1; -- round/truncate
              idct_mode : natural := 0; -- 0 = fdct, 1 = idct
              co_a : natural := 23170;
              co_b : natural := 32138;
              co_c : natural := 30274;
              co_d : natural := 27245;
              co_e : natural := 18205;
              co_f : natural := 12541;
              co_g : natural := 6393;
              co_h : natural := 35355;
              co_i : natural := 49039;
              co_j : natural := 46194;
              co_k : natural := 41573;
              co_l : natural := 27779;
              co_m : natural := 19134;
              co_n : natural := 9755;
              co_o : natural := 35355;
              co_p : natural := 49039
);
  port (  
      clk      : in  std_logic;
      rst_n    : in  std_logic;
      init_n   : in  std_logic;
      enable   : in  std_logic;
      start    : in  std_logic;
      dct_rd_data    : in  std_logic_vector(bpp+(n/2 * idct_mode)-1 downto 0);
      tp_rd_data : in  std_logic_vector(bpp/2+bpp+3 + ((1-tc_mode)*(1-idct_mode)) downto 0);
      done     : out std_logic;
      ready    : out std_logic;
      dct_rd_add     : out std_logic_vector(bit_width(n*n)-1 downto 0);

      tp_rd_add  : out std_logic_vector(bit_width(n*n)-1 downto 0);
      tp_wr_add  : out std_logic_vector(bit_width(n*n)-1 downto 0);
      tp_wr_n    : out std_logic;
      tp_wr_data : out std_logic_vector(bpp/2+bpp+3 + ((1-tc_mode)*(1-idct_mode)) downto 0);
      dct_wr_add     : out std_logic_vector(bit_width(n*n)-1 downto 0);
      dct_wr_n     : out std_logic;
      dct_wr_data     : out std_logic_vector(bpp-1+(n/2 * (1-idct_mode)) downto 0)
);
  end component;


  -- Content from file, DW_lp_piped_div.vhdpp

  component DW_lp_piped_div
   generic (
     a_width     : POSITIVE  := 8;
     b_width     : POSITIVE  := 8;
     id_width    : POSITIVE range 1 to 1024 := 8;
     in_reg      : NATURAL  range 0 to 1    := 0;
     stages      : POSITIVE range 1 to 1022 := 4;
     out_reg     : NATURAL  range 0 to 1    := 0;
     tc_mode     : NATURAL  range 0 to 1    := 0;
     rst_mode    : NATURAL  range 0 to 1    := 0;
     rem_mode    : NATURAL  range 0 to 1    := 1;
     op_iso_mode : NATURAL  range 0 to 4    := 0
   );

   port (
     clk         : in std_logic;
     rst_n       : in std_logic;
     a           : in std_logic_vector(a_width-1 downto 0);
     b           : in std_logic_vector(b_width-1 downto 0);
     quotient    : out std_logic_vector(a_width-1 downto 0);
     remainder   : out std_logic_vector(b_width-1 downto 0);  -- remainder
     div_by_0    : out std_logic;                            -- divide by 0
     launch      : in std_logic;
     launch_id   : in std_logic_vector(id_width-1 downto 0);
     pipe_full   : out std_logic;
     pipe_ovf    : out std_logic;
     accept_n    : in std_logic;
     arrive      : out std_logic;
     arrive_id   : out std_logic_vector(id_width-1 downto 0);
     push_out_n  : out std_logic;
     pipe_census : out std_logic_vector(bit_width(maximum(1,in_reg+(stages-1)+out_reg)+1)-1 downto 0)
   );
  end component;


  -- Content from file, DW_lp_piped_sqrt.vhdpp

  component DW_lp_piped_sqrt
   generic (
     width     : POSITIVE  := 8;
     id_width    : POSITIVE range 1 to 1024 := 8;
     in_reg      : NATURAL  range 0 to 1    := 0;
     stages      : POSITIVE range 1 to 1022 := 4;
     out_reg     : NATURAL  range 0 to 1    := 0;
     tc_mode     : NATURAL  range 0 to 1    := 0;
     rst_mode    : NATURAL  range 0 to 1    := 0;
     op_iso_mode : NATURAL  range 0 to 4    := 0
   );

   port (
     clk         : in std_logic;
     rst_n       : in std_logic;
     a           : in std_logic_vector(width-1 downto 0);
     root        : out std_logic_vector(((width+1)/2)-1 downto 0);
     launch      : in std_logic;
     launch_id   : in std_logic_vector(id_width-1 downto 0);
     pipe_full   : out std_logic;
     pipe_ovf    : out std_logic;
     accept_n    : in std_logic;
     arrive      : out std_logic;
     arrive_id   : out std_logic_vector(id_width-1 downto 0);
     push_out_n  : out std_logic;
     pipe_census : out std_logic_vector(bit_width(maximum(1,in_reg+(stages-1)+out_reg)+1)-1 downto 0)
   );
  end component;


  -- Content from file, DW_lp_piped_fp_add.vhdpp

  component DW_lp_piped_fp_add
  generic (
    sig_width      : POSITIVE range 2 to 253  := 23;
    exp_width      : POSITIVE range 3 to 31   := 8;
    ieee_compliance: INTEGER  range 0 to 1    := 0;
    op_iso_mode    : NATURAL  range 0 to 4    := 0;
    id_width	   : POSITIVE range 1 to 1024 := 8;
    in_reg	   : NATURAL  range 0 to 1    := 0;
    stages	   : POSITIVE range 1 to 1022 := 4;
    out_reg	   : NATURAL  range 0 to 1    := 0;
    no_pm          : NATURAL  range 0 to 1    := 1;
    rst_mode	   : NATURAL  range 0 to 1    := 0
   );
  port (
    clk         : in std_logic;
    rst_n       : in std_logic;
    a           : in std_logic_vector(sig_width + exp_width downto 0);
    b           : in std_logic_vector(sig_width + exp_width downto 0);
    rnd         : in std_logic_vector(2 downto 0);
    z           : out std_logic_vector(sig_width + exp_width downto 0);
    status      : out std_logic_vector(7 downto 0);
    launch	: in std_logic;
    launch_id	: in std_logic_vector(id_width-1 downto 0);
    pipe_full	: out std_logic;
    pipe_ovf	: out std_logic;
    accept_n	: in std_logic;
    arrive	: out std_logic;
    arrive_id	: out std_logic_vector(id_width-1 downto 0);
    push_out_n  : out std_logic;
    pipe_census : out std_logic_vector(bit_width(maximum(1,in_reg+(stages-1)+out_reg)+1)-1 downto 0)
  );
  end component;


  -- Content from file, DW_lp_piped_fp_sum3.vhdpp

  component DW_lp_piped_fp_sum3
  generic (
    sig_width      : POSITIVE range 2 to 253  := 23;
    exp_width      : POSITIVE range 3 to 31   := 8;
    ieee_compliance: INTEGER  range 0 to 1    := 0;
    arch_type      : INTEGER  range 0 to 1    := 0;
    op_iso_mode    : NATURAL  range 0 to 4    := 0;
    id_width	   : POSITIVE range 1 to 1024 := 8;
    in_reg	   : NATURAL  range 0 to 1    := 0;
    stages	   : POSITIVE range 1 to 1022 := 4;
    out_reg	   : NATURAL  range 0 to 1    := 0;
    no_pm          : NATURAL  range 0 to 1    := 1;
    rst_mode	   : NATURAL  range 0 to 1    := 0
   );
  port (
    clk         : in std_logic;
    rst_n       : in std_logic;
    a           : in std_logic_vector(sig_width + exp_width downto 0);
    b           : in std_logic_vector(sig_width + exp_width downto 0);
    c           : in std_logic_vector(sig_width + exp_width downto 0);
    rnd         : in std_logic_vector(2 downto 0);
    z           : out std_logic_vector(sig_width + exp_width downto 0);
    status      : out std_logic_vector(7 downto 0);
    launch	: in std_logic;
    launch_id	: in std_logic_vector(id_width-1 downto 0);
    pipe_full	: out std_logic;
    pipe_ovf	: out std_logic;
    accept_n	: in std_logic;
    arrive	: out std_logic;
    arrive_id	: out std_logic_vector(id_width-1 downto 0);
    push_out_n  : out std_logic;
    pipe_census : out std_logic_vector(bit_width(maximum(1,in_reg+(stages-1)+out_reg)+1)-1 downto 0)
  );
  end component;


  -- Content from file, DW_lp_piped_fp_div.vhdpp

  component DW_lp_piped_fp_div
  generic (
    sig_width      : POSITIVE range 2 to 253  := 23;
    exp_width      : POSITIVE range 3 to 31   := 8;
    ieee_compliance: INTEGER  range 0 to 1    := 0;
    faithful_round : INTEGER  range 0 to 1    := 0;
    op_iso_mode    : NATURAL  range 0 to 4    := 0;
    id_width	   : POSITIVE range 1 to 1024 := 8;
    in_reg	   : NATURAL  range 0 to 1    := 0;
    stages	   : POSITIVE range 1 to 1022 := 4;
    out_reg	   : NATURAL  range 0 to 1    := 0;
    no_pm          : NATURAL  range 0 to 1    := 1;
    rst_mode	   : NATURAL  range 0 to 1    := 0
   );
  port (
    clk         : in std_logic;
    rst_n       : in std_logic;
    a           : in std_logic_vector(sig_width + exp_width downto 0);
    b           : in std_logic_vector(sig_width + exp_width downto 0);
    rnd         : in std_logic_vector(2 downto 0);
    z           : out std_logic_vector(sig_width + exp_width downto 0);
    status      : out std_logic_vector(7 downto 0);
    launch	: in std_logic;
    launch_id	: in std_logic_vector(id_width-1 downto 0);
    pipe_full	: out std_logic;
    pipe_ovf	: out std_logic;
    accept_n	: in std_logic;
    arrive	: out std_logic;
    arrive_id	: out std_logic_vector(id_width-1 downto 0);
    push_out_n  : out std_logic;
    pipe_census : out std_logic_vector(bit_width(maximum(1,in_reg+(stages-1)+out_reg)+1)-1 downto 0)
  );
  end component;


  -- Content from file, DW_lp_piped_fp_mult.vhdpp

  component DW_lp_piped_fp_mult
  generic (
    sig_width      : POSITIVE range 2 to 253  := 23;
    exp_width      : POSITIVE range 3 to 31   := 8;
    ieee_compliance: INTEGER  range 0 to 1    := 0;
    op_iso_mode    : NATURAL  range 0 to 4    := 0;
    id_width	   : POSITIVE range 1 to 1024 := 8;
    in_reg	   : NATURAL  range 0 to 1    := 0;
    stages	   : POSITIVE range 1 to 1022 := 4;
    out_reg	   : NATURAL  range 0 to 1    := 0;
    no_pm          : NATURAL  range 0 to 1    := 1;
    rst_mode	   : NATURAL  range 0 to 1    := 0
   );
  port (
    clk         : in std_logic;
    rst_n       : in std_logic;
    a           : in std_logic_vector(sig_width + exp_width downto 0);
    b           : in std_logic_vector(sig_width + exp_width downto 0);
    rnd         : in std_logic_vector(2 downto 0);
    z           : out std_logic_vector(sig_width + exp_width downto 0);
    status      : out std_logic_vector(7 downto 0);
    launch	: in std_logic;
    launch_id	: in std_logic_vector(id_width-1 downto 0);
    pipe_full	: out std_logic;
    pipe_ovf	: out std_logic;
    accept_n	: in std_logic;
    arrive	: out std_logic;
    arrive_id	: out std_logic_vector(id_width-1 downto 0);
    push_out_n  : out std_logic;
    pipe_census : out std_logic_vector(bit_width(maximum(1,in_reg+(stages-1)+out_reg)+1)-1 downto 0)
  );
  end component;


  -- Content from file, DW_lp_piped_fp_recip.vhdpp

  component DW_lp_piped_fp_recip
  generic (
    sig_width      : POSITIVE range 2 to 253  := 23;
    exp_width      : POSITIVE range 3 to 31   := 8;
    ieee_compliance: INTEGER  range 0 to 1    := 0;
    faithful_round : INTEGER  range 0 to 1    := 0;
    op_iso_mode    : NATURAL  range 0 to 4    := 0;
    id_width	   : POSITIVE range 1 to 1024 := 8;
    in_reg	   : NATURAL  range 0 to 1    := 0;
    stages	   : POSITIVE range 1 to 1022 := 4;
    out_reg	   : NATURAL  range 0 to 1    := 0;
    no_pm          : NATURAL  range 0 to 1    := 1;
    rst_mode	   : NATURAL  range 0 to 1    := 0
   );
  port (
    clk         : in std_logic;
    rst_n       : in std_logic;
    a           : in std_logic_vector(sig_width + exp_width downto 0);
    rnd         : in std_logic_vector(2 downto 0);
    z           : out std_logic_vector(sig_width + exp_width downto 0);
    status      : out std_logic_vector(7 downto 0);
    launch	: in std_logic;
    launch_id	: in std_logic_vector(id_width-1 downto 0);
    pipe_full	: out std_logic;
    pipe_ovf	: out std_logic;
    accept_n	: in std_logic;
    arrive	: out std_logic;
    arrive_id	: out std_logic_vector(id_width-1 downto 0);
    push_out_n  : out std_logic;
    pipe_census : out std_logic_vector(bit_width(maximum(1,in_reg+(stages-1)+out_reg)+1)-1 downto 0)
  );
  end component;


  -- Content from file, DW_pl_reg.vhdpp

  component DW_pl_reg
	generic (
		width : NATURAL := 8;
		in_reg : INTEGER range 0 to 1 := 0;
		stages : INTEGER range 1 to 1024 := 4;
		out_reg : INTEGER range 0 to 1 := 0;
		rst_mode : INTEGER range 0 to 1 := 0
		);
	port (
		clk : in std_logic;
		rst_n : in std_logic;
		enable : in std_logic_vector(maximum(0, in_reg+stages+out_reg-2) downto 0);
		data_in : in std_logic_vector(width-1 downto 0);

		data_out : out std_logic_vector(width-1 downto 0)
	     );
  end component;


  -- Content from file, DW_lp_cntr_updn_df.vhdpp

  component DW_lp_cntr_updn_df
	
	generic (
		    width          : POSITIVE range 1 to 1024 := 8;
		    rst_mode       : NATURAL range 0 to 1 := 0;
		    reg_trmcnt     : NATURAL range 0 to 1 := 0
		);
	
	port    (
                    clk             : in std_logic;
                    rst_n           : in std_logic;
                    enable          : in std_logic;
                    up_dn           : in std_logic;
                    ld_n            : in std_logic;
                    ld_count        : in std_logic_vector(width-1 downto 0);
                    term_val        : in std_logic_vector(width-1 downto 0);
                    count           : out std_logic_vector(width-1 downto 0);
                    term_count_n    : out std_logic
		);
  end component;


  -- Content from file, DW_lp_cntr_up_df.vhdpp

  component DW_lp_cntr_up_df
	
	generic (
		    width          : POSITIVE range 1 to 1024 := 8;
		    rst_mode       : NATURAL range 0 to 1 := 0;
		    reg_trmcnt     : NATURAL range 0 to 1 := 0
		);
	
	port    (
                    clk             : in std_logic;
                    rst_n           : in std_logic;
                    enable          : in std_logic;
                    ld_n            : in std_logic;
                    ld_count        : in std_logic_vector(width-1 downto 0);
                    term_val        : in std_logic_vector(width-1 downto 0);
                    count           : out std_logic_vector(width-1 downto 0);
                    term_count_n    : out std_logic
		);
  end component;


  -- Content from file, DW_fifoctl_s1r.vhdpp

  component DW_fifoctl_s1r

  generic(width : INTEGER RANGE 1 to 1024     := 8;
  	  depth : INTEGER RANGE 4 to 16777216 := 16;
  	  mem_mode : INTEGER RANGE 0 to 1     := 1);

  port(
	clk : in std_logic;
	rst_n : in std_logic;
	init_n : in std_logic;

	push_req_n : in std_logic;
	data_in : in std_logic_vector(width-1 downto 0);
	we_n : out std_logic;
	wr_addr : out std_logic_vector(bit_width(depth-2)-1 downto 0);

	pop_req_n : in std_logic;
	ram_rd_data : in std_logic_vector(width-1 downto 0);
	re_n : out std_logic;
	rd_addr : out std_logic_vector(bit_width(depth-2)-1 downto 0);
	data_out : out std_logic_vector(width-1 downto 0);

	empty : out std_logic;
	full  : out std_logic;
	error : out std_logic;

	wrd_count : out std_logic_vector(bit_width(depth)-1 downto 0);

	next_data_out : out std_logic_vector(width-1 downto 0);
	next_empty : out std_logic;
	next_full  : out std_logic;
	next_error : out std_logic;
	next_wrd_count : out std_logic_vector(bit_width(depth)-1 downto 0));

  end component;


  -- Content from file, DW_pipe_reg.vhdpp

  component DW_pipe_reg
   generic (depth    : NATURAL := 0;
            width    : POSITIVE := 1;
            rst_mode : INTEGER range 0 to 1 := 0 );
   port(data_in  : in std_logic_vector (width-1 downto 0);
        enable   : in std_logic;
        rst_n    : in std_logic;
        ld_0_n   : in std_logic;
        clk      : in std_logic;
        data_out : out std_logic_vector(width-1 downto 0));
  end component;


  -- Content from file, DW_cntr_dcnto.vhdpp

  component DW_cntr_dcnto
	
    generic( width : INTEGER range 1 to 256;
	     rst_mode : INTEGER range 0 to 1 := 0 );
    port(   clk : in std_logic;
	    rst_n : in std_logic;
	    enable : in std_logic;
	    load_n : in std_logic;
	    count_to : in std_logic_vector( width-1 downto 0 );
	    ld_data : in std_logic_vector( width-1 downto 0 );
	    tercnt_n : out std_logic;
	    count : out std_logic_vector ( width-1 downto 0 ) );

  end component;


  -- Content from file, DW_cntr_scnto.vhdpp

  component DW_cntr_scnto
	
    generic( width : INTEGER range 1 to 30;
	     count_to : POSITIVE;
	     rst_mode : INTEGER range 0 to 1 := 0;
	     dcod_mode : INTEGER range 0 to 1 := 0 );
    port(   clk : in std_logic;
	    rst_n : in std_logic;
	    enable : in std_logic;
	    load_n : in std_logic;
	    ld_data : in std_logic_vector( width-1 downto 0 );
	    tercnt_n : out std_logic;
	    count : out std_logic_vector ( width-1 downto 0 ) );

  end component;


  -- Content from file, DW_cntr_smod.vhdpp

  component DW_cntr_smod
	
    generic( width : INTEGER range 1 to 30;
	     modulus : POSITIVE;
	     rst_mode : INTEGER range 0 to 1 := 0 );
    port(   clk : in std_logic;
	    rst_n : in std_logic;
	    enable : in std_logic;
	    load_n : in std_logic;
	    ld_data : in std_logic_vector( width-1 downto 0 );
	    tercnt : out std_logic;
	    count : out std_logic_vector ( width-1 downto 0 ) );

  end component;


  -- Content from file, DW_ASYMFIFOCTL_IN_WRAPPER.vhdpp

  component DW_ASYMFIFOCTL_IN_WRAPPER
	 generic (
		data_in_width : INTEGER;
		data_out_width : INTEGER;
		err_mode : INTEGER range 0 to 2 := 1;
		rst_mode : INTEGER range 0 to 1 := 1;
		push_pop_full : INTEGER range 0 to 1 := 1;
		byte_order : INTEGER range 0 to 1 := 0
		);
 	port (
    		clk : in std_logic;
	    	rst_n : in std_logic;
	    	push_req_n : in std_logic;
		flush_n : in std_logic;
	    	pop_req_n : in std_logic;
		nxt_ram_error : in std_logic;
		ram_full : in std_logic;
		nxt_ram_full : in std_logic;
		byte_ctl_addr : in std_logic_vector(
			data_out_width/data_in_width-1 downto 0);
		data_in : in std_logic_vector(data_in_width-1
						downto 0);
	    	ram_push_n : out std_logic;
		flush_act_n : out std_logic;
		inc_byte_cntr : out std_logic;
		full : out std_logic;
		error : out std_logic;
		part_wd : out std_logic;
		wr_data : out std_logic_vector(data_out_width-1
					downto 0);
		cntr_ld_data : out std_logic_vector(bit_width(
			data_out_width/data_in_width)-1 downto 0)
		);
  end component;


  -- Content from file, DW_ASYMFIFOCTL_OUT_WRAPPER.vhdpp

  component DW_ASYMFIFOCTL_OUT_WRAPPER
	 generic (
		data_in_width : INTEGER;
		data_out_width : INTEGER;
		err_mode : INTEGER range 0 to 2 := 1;
		rst_mode : INTEGER range 0 to 1 := 1;
		byte_order : INTEGER range 0 to 1 := 0
		);
 	port (
    		clk : in std_logic;
	    	rst_n : in std_logic;
	    	pop_req_n : in std_logic;
		nxt_ram_error : in std_logic;
		buf_empty : in std_logic;
		ram_empty : in std_logic;
		mux_ctl_addr : in std_logic_vector(bit_width(
			data_in_width/data_out_width)-1 downto 0);
	    	rd_data : in std_logic_vector(maximum(data_in_width,
	    			data_out_width)-1 downto 0);
		inc_byte_cntr : out std_logic;
	    	ram_pop_n : out std_logic;
		error : out std_logic;
		data_out : out std_logic_vector(data_out_width-1
						downto 0)
		);
  end component;


  -- Content from file, DW_FIFOCTL_IF.vhdpp

  component DW_FIFOCTL_IF
	
	generic (
		    depth : INTEGER range 4 to 16777216 := 8;
		    ae_level : INTEGER range 1 to 16777215 := 2;
		    af_level : INTEGER range 1 to 16777215 := 2;
		    err_mode : INTEGER range 0 to 1 := 0;
		    sync_mode : INTEGER range 1 to 3 := 2;
		    io_mode : INTEGER range 0 to 1 := 0;
		    tst_mode : INTEGER range 0 to 1 := 0
		);
	
	port    (
		    clk : in std_logic;
		    rst_n : in std_logic;
		    init_n : in std_logic;
		    inc_req_n : in std_logic;
		    other_addr_g : in std_logic_vector( bit_width(depth+1)-1 downto 0 );
		    word_count : out std_logic_vector( bit_width(depth+1)-1 downto 0 );
		    empty : out std_logic;
		    almost_empty : out std_logic;
		    half_full : out std_logic;
		    almost_full : out std_logic;
		    full : out std_logic;
		    error : out std_logic;
		    this_addr : out std_logic_vector( bit_width(depth)-1 downto 0 );
		    this_addr_g : out std_logic_vector( bit_width(depth+1)-1 downto 0 );
		    next_word_count : out std_logic_vector( bit_width(depth+1)-1 downto 0 );
		    next_empty_n, next_full, next_error : out std_logic;
		    test : in std_logic
		);

  end component;


  -- Content from file, DW_ASYMFIFOCTL_S2SF_INWRP.vhdpp

  component DW_ASYMFIFOCTL_S2SF_INWRP
	
	generic (
		    data_in_width  : INTEGER range 1 to 4096 ;
		    data_out_width : INTEGER range 1 to 4096 ;
		    depth : INTEGER range 4 to 16777216 := 8;
		    push_ae_lvl : INTEGER range 1 to 16777215 := 2;
		    push_af_lvl : INTEGER range 1 to 16777215 := 2;
		    err_mode : INTEGER range 0 to 1 := 0;
		    push_sync : INTEGER range 1 to 3 := 2;
		    rst_mode : INTEGER range 0 to 1 := 1;
		    byte_order : INTEGER range 0 to 1 := 0
		);
	
	port    (
		    clk_push : in std_logic;
		    rst_n : in std_logic;
		    push_req_n : in std_logic;
		    flush_n : in std_logic;
		    data_in : in std_logic_vector(data_in_width-1 downto 0);
		    rd_addr_g : in std_logic_vector(bit_width(depth+1)-1 downto 0);
		    ram_push_n : out std_logic;
		    push_empty : out std_logic;
		    push_ae : out std_logic;
		    push_hf : out std_logic;
		    push_af : out std_logic;
		    push_full : out std_logic;
		    ram_full : out std_logic;
		    part_wd : out std_logic;
		    push_error : out std_logic;
		    wr_data : out std_logic_vector(maximum(data_in_width,
		    			data_out_width)-1 downto 0);
		    wr_addr : out std_logic_vector(bit_width(depth)-1 downto 0);
		    wr_addr_g : out std_logic_vector(bit_width(depth+1)-1 downto 0)
		);

  end component;


  -- Content from file, DW_ASYMFIFOCTL_S2SF_OUTWRP.vhdpp

  component DW_ASYMFIFOCTL_S2SF_OUTWRP
	
	generic (
		    data_in_width  : INTEGER range 1 to 4096 ;
		    data_out_width : INTEGER range 1 to 4096 ;
		    depth : INTEGER range 4 to 16777216 := 8;
		    pop_ae_lvl : INTEGER range 1 to 16777215 := 2;
		    pop_af_lvl : INTEGER range 1 to 16777215 := 2;
		    err_mode : INTEGER range 0 to 1 := 0;
		    pop_sync : INTEGER range 1 to 3 := 2;
		    rst_mode : INTEGER range 0 to 1 := 1;
		    byte_order : INTEGER range 0 to 1 := 0
		);
	
	port    (
		    clk_pop : in std_logic;
		    rst_n : in std_logic;
		    pop_req_n : in std_logic;
		    rd_data : in std_logic_vector(maximum(data_in_width,
		    			data_out_width)-1 downto 0);
		    wr_addr_g : in std_logic_vector( bit_width(depth+1)-1 downto 0 );
		    pop_empty : out std_logic;
		    pop_ae : out std_logic;
		    pop_hf : out std_logic;
		    pop_af : out std_logic;
		    pop_full : out std_logic;
		    pop_error : out std_logic;
		    rd_addr : out std_logic_vector( bit_width(depth)-1 downto 0 );
		    rd_addr_g : out std_logic_vector( bit_width(depth+1)-1 downto 0 );
		    data_out : out std_logic_vector(data_out_width-1
		    			downto 0)
		);

  end component;


  -- Content from file, DW_FIR_SEQ_AU.vhdpp

  component DW_FIR_SEQ_AU
  generic(D_width, C_width, Y_width: POSITIVE);
  port(D : in std_logic_vector(D_width-1 downto 0); 
       C : in std_logic_vector(C_width-1 downto 0);     
       S : in std_logic_vector(Y_width-1 downto 0);            
       clk, rst_n, run, start, hold : in std_logic;                     
       TC: in std_logic;
       Y : out std_logic_vector(Y_width-1 downto 0));
  end component;


  -- Content from file, DW_FIR_SEQ_CSR.vhdpp

  component DW_FIR_SEQ_CSR
  generic(C_width, length, addr_width: POSITIVE);
  port(CIN : in std_logic_vector(C_width-1 downto 0); 
       raddr : in std_logic_vector(addr_width-1 downto 0);   
       clk, rst_n, coef_shift_en: in std_logic;                     
       COUT : out std_logic_vector(C_width-1 downto 0));
  end component;


  -- Content from file, DW_FIR_SEQ_CTL.vhdpp

  component DW_FIR_SEQ_CTL
  generic(length: POSITIVE;
          addr_width: POSITIVE);    
  port(clk, rst_n, run, coef_shift_en : in std_logic;                     
       dw_addr, dr_addr, c_addr : out std_logic_vector(addr_width-1 downto 0);
       start, hold: out std_logic);
  end component;


  -- Content from file, DW_FIR_SEQ_DSR.vhdpp

  component DW_FIR_SEQ_DSR
  generic(D_width, length, addr_width: POSITIVE);
  port(DIN : in std_logic_vector(D_width-1 downto 0); 
       raddr, waddr: in std_logic_vector(addr_width-1 downto 0);   
       clk, rst_n, wen: in std_logic;                     
       DOUT : out std_logic_vector(D_width-1 downto 0));
  end component;


  -- Content from file, DW_FIR_SEQ_AU.vhdpp

  -- Datapath


  -- Content from file, DW_FIR_SEQ_CSR.vhdpp

  -- coefficient shift register


  -- Content from file, DW_FIR_SEQ_CTL.vhdpp

  -- controller FSM for DW_fir_seq


  -- Content from file, DW_FIR_SEQ_DSR.vhdpp

  -- Sample Data shift register


end DW03_components;

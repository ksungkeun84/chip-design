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
-- VERSION:   Components package file for DW06_components
--
-- DesignWare_version: 0a1acf9a
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_misc.all;
use IEEE.std_logic_arith.all;

library DWARE;
use DWARE.DWpackages.all;

package DW06_components is


  -- Content from file, DW_ram_rw_s_dff.vhdpp

  component DW_ram_rw_s_dff
  generic(data_width : INTEGER range 1 to 2048;
          depth      : INTEGER range 2 to 1024; 
          rst_mode : INTEGER range 0 to 1 := 1); 
  port(clk	: in std_logic;
       rst_n    : in std_logic;
       cs_n     : in std_logic;
       wr_n     : in std_logic;
       rw_addr  : in std_logic_vector(bit_width(depth)-1 downto 0);
       data_in  : in std_logic_vector(data_width-1 downto 0);
       data_out : out std_logic_vector(data_width-1 downto 0));
  end component;


  -- Content from file, DW_ram_rw_s_lat.vhdpp

  component DW_ram_rw_s_lat
  generic(data_width : INTEGER range 1 to 256;
          depth      : INTEGER range 2 to 256); 
  port(clk	: in std_logic;
       cs_n     : in std_logic;
       wr_n     : in std_logic;
       rw_addr  : in std_logic_vector(bit_width(depth)-1 downto 0);
       data_in  : in std_logic_vector(data_width-1 downto 0);
       data_out : out std_logic_vector(data_width-1 downto 0));
  end component;


  -- Content from file, DW_ram_rw_a_dff.vhdpp

  component DW_ram_rw_a_dff
  generic(data_width : INTEGER range 1 to 256;
          depth      : INTEGER range 2 to 256;
          rst_mode : INTEGER range 0 to 1 := 1);
  port(rst_n	: in std_logic;
       cs_n	: in std_logic;
       wr_n     : in std_logic;
       test_mode : in std_logic;
       test_clk  : in std_logic;
       rw_addr	: in std_logic_vector(bit_width(depth)-1 downto 0);
       data_in	: in std_logic_vector(data_width-1 downto 0);
       data_out	: out std_logic_vector(data_width-1 downto 0));
  end component;


  -- Content from file, DW_ram_rw_a_lat.vhdpp

  component DW_ram_rw_a_lat
  generic(data_width : INTEGER range 1 to 256;
          depth      : INTEGER range 2 to 256;
	  rst_mode   : INTEGER range 0 to 1 := 1);
  port(rst_n	: in std_logic;
       cs_n     : in std_logic;
       wr_n     : in std_logic;
       rw_addr	: in std_logic_vector(bit_width(depth)-1 downto 0);
       data_in	: in std_logic_vector(data_width-1 downto 0);
       data_out	: out std_logic_vector(data_width-1 downto 0));
  end component;


  -- Content from file, DW_ram_r_w_s_dff.vhdpp

  component DW_ram_r_w_s_dff
  generic(data_width : INTEGER range 1 to 2048;
          depth      : INTEGER range 2 to 1024; 
          rst_mode : INTEGER range 0 to 1 := 1); 
  port(clk	: in std_logic;
       rst_n    : in std_logic;
       cs_n     : in std_logic;
       wr_n     : in std_logic;
       rd_addr  : in std_logic_vector(bit_width(depth)-1 downto 0);
       wr_addr  : in std_logic_vector(bit_width(depth)-1 downto 0);
       data_in  : in std_logic_vector(data_width-1 downto 0);
       data_out : out std_logic_vector(data_width-1 downto 0));
  end component;


  -- Content from file, DW_ram_r_w_s_lat.vhdpp

  component DW_ram_r_w_s_lat
  generic(data_width : INTEGER range 1 to 256;
          depth      : INTEGER range 2 to 256); 
  port(clk	: in std_logic;
       cs_n     : in std_logic;
       wr_n     : in std_logic;
       rd_addr  : in std_logic_vector(bit_width(depth)-1 downto 0);
       wr_addr  : in std_logic_vector(bit_width(depth)-1 downto 0);
       data_in  : in std_logic_vector(data_width-1 downto 0);
       data_out : out std_logic_vector(data_width-1 downto 0));
  end component;


  -- Content from file, DW_ram_r_w_a_dff.vhdpp

  component DW_ram_r_w_a_dff
  generic(data_width : INTEGER range 1 to 256;
          depth      : INTEGER range 2 to 256;
          rst_mode : INTEGER range 0 to 1 := 1);
  port(rst_n	: in std_logic;
       cs_n	: in std_logic;
       wr_n     : in std_logic;
       test_mode : in std_logic;
       test_clk  : in std_logic;
       rd_addr	: in std_logic_vector(bit_width(depth)-1 downto 0);
       wr_addr	: in std_logic_vector(bit_width(depth)-1 downto 0);
       data_in	: in std_logic_vector(data_width-1 downto 0);
       data_out	: out std_logic_vector(data_width-1 downto 0));
  end component;


  -- Content from file, DW_ram_r_w_a_lat.vhdpp

  component DW_ram_r_w_a_lat
  generic(data_width : INTEGER range 1 to 256;
          depth      : INTEGER range 2 to 256;
	  rst_mode   : INTEGER range 0 to 1 := 1);
  port(rst_n	: in std_logic;
       cs_n     : in std_logic;
       wr_n     : in std_logic;
       rd_addr	: in std_logic_vector(bit_width(depth)-1 downto 0);
       wr_addr	: in std_logic_vector(bit_width(depth)-1 downto 0);
       data_in	: in std_logic_vector(data_width-1 downto 0);
       data_out	: out std_logic_vector(data_width-1 downto 0));
  end component;


  -- Content from file, DW_ram_2r_w_s_dff.vhdpp

  component DW_ram_2r_w_s_dff
  generic(data_width : INTEGER range 1 to 2048;
          depth      : INTEGER range 2 to 1024; 
          rst_mode : INTEGER range 0 to 1 := 1); 
  port(clk	: in std_logic;
       rst_n    : in std_logic;
       cs_n     : in std_logic;
       wr_n     : in std_logic;
       rd1_addr  : in std_logic_vector(bit_width(depth)-1 downto 0);
       rd2_addr  : in std_logic_vector(bit_width(depth)-1 downto 0);
       wr_addr  : in std_logic_vector(bit_width(depth)-1 downto 0);
       data_in  : in std_logic_vector(data_width-1 downto 0);
       data_rd1_out : out std_logic_vector(data_width-1 downto 0);
       data_rd2_out : out std_logic_vector(data_width-1 downto 0));
  end component;


  -- Content from file, DW_ram_2r_w_s_lat.vhdpp

  component DW_ram_2r_w_s_lat
  generic(data_width : INTEGER range 1 to 256;
          depth      : INTEGER range 2 to 256); 
  port(clk	: in std_logic;
       cs_n     : in std_logic;
       wr_n     : in std_logic;
       rd1_addr : in std_logic_vector(bit_width(depth)-1 downto 0);
       rd2_addr : in std_logic_vector(bit_width(depth)-1 downto 0);
       wr_addr  : in std_logic_vector(bit_width(depth)-1 downto 0);
       data_in  : in std_logic_vector(data_width-1 downto 0);
       data_rd1_out : out std_logic_vector(data_width-1 downto 0);
       data_rd2_out : out std_logic_vector(data_width-1 downto 0));
  end component;


  -- Content from file, DW_ram_2r_w_a_dff.vhdpp

  component DW_ram_2r_w_a_dff
  generic(data_width : INTEGER range 1 to 256;
          depth      : INTEGER range 2 to 256;
          rst_mode : INTEGER range 0 to 1 := 1);
  port(rst_n	    : in std_logic;
       cs_n	    : in std_logic;
       wr_n         : in std_logic;
       test_mode    : in std_logic;
       test_clk     : in std_logic;
       rd1_addr	    : in std_logic_vector(bit_width(depth)-1 downto 0);
       rd2_addr	    : in std_logic_vector(bit_width(depth)-1 downto 0);
       wr_addr	    : in std_logic_vector(bit_width(depth)-1 downto 0);
       data_in	    : in std_logic_vector(data_width-1 downto 0);
       data_rd1_out : out std_logic_vector(data_width-1 downto 0);
       data_rd2_out : out std_logic_vector(data_width-1 downto 0));
  end component;


  -- Content from file, DW_ram_2r_w_a_lat.vhdpp

  component DW_ram_2r_w_a_lat
  generic(data_width : INTEGER range 1 to 256;
          depth      : INTEGER range 2 to 256;
	  rst_mode   : INTEGER range 0 to 1 := 1);
  port(rst_n	: in std_logic;
       cs_n     : in std_logic;
       wr_n     : in std_logic;
       rd1_addr	: in std_logic_vector(bit_width(depth)-1 downto 0);
       rd2_addr	: in std_logic_vector(bit_width(depth)-1 downto 0);
       wr_addr	: in std_logic_vector(bit_width(depth)-1 downto 0);
       data_in	: in std_logic_vector(data_width-1 downto 0);
       data_rd1_out : out std_logic_vector(data_width-1 downto 0);
       data_rd2_out : out std_logic_vector(data_width-1 downto 0));
  end component;


  -- Content from file, DW_fifo_s1_df.vhdpp

  component DW_fifo_s1_df
	
	generic (
		    width : INTEGER range 1 to 2048 := 8;
		    depth : INTEGER range 2 to 1024 := 4;
		    err_mode : INTEGER range 0 to 2 := 0;
		    rst_mode : INTEGER range 0 to 3 := 0
		);
	
	port    (
		    clk : in std_logic;
		    rst_n : in std_logic;
		    push_req_n : in std_logic;
		    pop_req_n : in std_logic;
		    diag_n : in std_logic;
		    ae_level : in std_logic_vector( bit_width(depth)-1 downto 0 );
		    af_thresh : in std_logic_vector( bit_width(depth)-1 downto 0 );
		    data_in : in std_logic_vector( width-1 downto 0 );
		    empty : out std_logic;
		    almost_empty : out std_logic;
		    half_full : out std_logic;
		    almost_full : out std_logic;
		    full : out std_logic;
		    error : out std_logic;
		    data_out : out std_logic_vector( width-1 downto 0 )
		);
  end component;


  -- Content from file, DW_fifo_s1_sf.vhdpp

  component DW_fifo_s1_sf
	
	generic (
		    width : INTEGER range 1 to 2048 := 8;
		    depth : INTEGER range 2 to 1024 := 4;
		    ae_level : INTEGER range 1 to 255 := 1;
		    af_level : INTEGER range 1 to 255 := 1;
		    err_mode : INTEGER range 0 to 2 := 0;
		    rst_mode : INTEGER range 0 to 3 := 0
		);
	
	port    (
		    clk : in std_logic;
		    rst_n : in std_logic;
		    push_req_n : in std_logic;
		    pop_req_n : in std_logic;
		    diag_n : in std_logic;
		    data_in : in std_logic_vector( width-1 downto 0 );
		    empty : out std_logic;
		    almost_empty : out std_logic;
		    half_full : out std_logic;
		    almost_full : out std_logic;
		    full : out std_logic;
		    error : out std_logic;
		    data_out : out std_logic_vector( width-1 downto 0 )
		);
  end component;


  -- Content from file, DW_fifo_s2_sf.vhdpp

  component DW_fifo_s2_sf
	
	generic (
		    width : INTEGER range 1 to 256 := 8;
		    depth : INTEGER range 4 to 256 := 8;
		    push_ae_lvl : INTEGER range 1 to 16777215 := 2;
		    push_af_lvl : INTEGER range 1 to 16777215 := 2;
		    pop_ae_lvl : INTEGER range 1 to 16777215 := 2;
		    pop_af_lvl : INTEGER range 1 to 16777215 := 2;
		    err_mode : INTEGER range 0 to 1 := 0;
		    push_sync : INTEGER range 1 to 3 := 2;
		    pop_sync : INTEGER range 1 to 3 := 2;
		    rst_mode : INTEGER range 0 to 3 := 0
		);
	
	port    (
		    clk_push : in std_logic;
		    clk_pop : in std_logic;
		    rst_n : in std_logic;
		    push_req_n : in std_logic;
		    pop_req_n : in std_logic;
		    data_in : in std_logic_vector(width-1 downto 0);
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
		    data_out : out std_logic_vector( width-1 downto 0 )
		);
  end component;


  -- Content from file, DW_asymfifo_s1_sf.vhdpp

  component DW_asymfifo_s1_sf
	
	generic (
		    data_in_width  : INTEGER range 1 to 256 ;
		    data_out_width : INTEGER range 1 to 256 ;
		    depth      : INTEGER range 2 to 256 ;
		    ae_level   : INTEGER range 1 to 255 ;
		    af_level   : INTEGER range 1 to 255 ;
		    err_mode   : INTEGER range 0 to 2 := 1;
		    rst_mode   : INTEGER range 0 to 3 := 1;
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
		    empty : out std_logic;
		    almost_empty : out std_logic;
		    half_full : out std_logic;
		    almost_full : out std_logic;
		    full : out std_logic;
		    ram_full : out std_logic;
		    error : out std_logic;
		    part_wd : out std_logic;
		    data_out : out std_logic_vector(data_out_width-1
		    			downto 0)
		);
  end component;


  -- Content from file, DW_asymfifo_s1_df.vhdpp

  component DW_asymfifo_s1_df
	
	generic (
		    data_in_width  : INTEGER range 1 to 256 ;
		    data_out_width : INTEGER range 1 to 256 ;
		    depth      : INTEGER range 2 to 256 ;
		    err_mode   : INTEGER range 0 to 2 := 1;
		    rst_mode   : INTEGER range 0 to 3 := 1;
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
		    ae_level : in std_logic_vector( bit_width(depth)-1 downto 0 );
		    af_thresh : in std_logic_vector( bit_width(depth)-1 downto 0 );
		    empty : out std_logic;
		    almost_empty : out std_logic;
		    half_full : out std_logic;
		    almost_full : out std_logic;
		    full : out std_logic;
		    ram_full : out std_logic;
		    error : out std_logic;
		    part_wd : out std_logic;
		    data_out : out std_logic_vector(data_out_width-1
		    			downto 0)
		);
  end component;


  -- Content from file, DW_asymfifo_s2_sf.vhdpp

  component DW_asymfifo_s2_sf
	
	generic (
		    data_in_width  : INTEGER range 1 to 256 ;
		    data_out_width : INTEGER range 1 to 256 ;
		    depth : INTEGER range 4 to 256 := 8;
		    push_ae_lvl : INTEGER range 1 to 16777215 := 2;
		    push_af_lvl : INTEGER range 1 to 16777215 := 2;
		    pop_ae_lvl : INTEGER range 1 to 16777215 := 2;
		    pop_af_lvl : INTEGER range 1 to 16777215 := 2;
		    err_mode : INTEGER range 0 to 1 := 0;
		    push_sync : INTEGER range 1 to 3 := 2;
		    pop_sync : INTEGER range 1 to 3 := 2;
		    rst_mode : INTEGER range 0 to 3 := 1;
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
		    data_out : out std_logic_vector(data_out_width-1 downto 0 )
		);
  end component;


  -- Content from file, DW_stack.vhdpp

  component DW_stack
	
	generic (
		    width : INTEGER range 1 to 256 ;
		    depth : INTEGER range 2 to 256 ;
		    err_mode : INTEGER range 0 to 1 := 0;
		    rst_mode : INTEGER range 0 to 3 := 0
		);
	
	port    (
		    clk : in std_logic;
		    rst_n : in std_logic;
		    push_req_n : in std_logic;
		    pop_req_n : in std_logic;
		    data_in : in std_logic_vector( width-1 downto 0 );
		    empty : out std_logic;
		    full : out std_logic;
		    error : out std_logic;
		    data_out : out std_logic_vector( width-1 downto 0 )
		);
  end component;


  -- Content from file, DW_ram_r_w_2c_dff.vhdpp

  component DW_ram_r_w_2c_dff
	
	generic (
		    width        : POSITIVE range 1 to 1024 := 8;
		    depth        : POSITIVE range 2 to 16777216 := 8;
                    addr_width   : NATURAL  range 1 to 10 := 3;
                    mem_mode     : NATURAL  range 0 to 7  := 5;
		    rst_mode     : NATURAL  range 0 to 1  := 1
		);
	
	port    (
                    clk_w           : in std_logic;
                    rst_w_n         : in std_logic;
                    init_w_n        : in std_logic;
                    en_w_n          : in std_logic;
                    addr_w          : in std_logic_vector( bit_width(depth)-1 downto 0);
                    data_w          : in std_logic_vector(width-1 downto 0);

                    clk_r           : in std_logic;
                    rst_r_n         : in std_logic;
                    init_r_n        : in std_logic;
                    en_r_n          : in std_logic;
                    addr_r          : in std_logic_vector( bit_width(depth)-1 downto 0);
                    data_r_a        : out std_logic;
		    data_r          : out std_logic_vector(width-1 downto 0)
		);
  end component;


  -- Content from file, DW_fifo_2c_df.vhdpp

  component DW_fifo_2c_df
	
	generic (
		    width            : POSITIVE range 1 to 1024 := 8;
		    ram_depth        : POSITIVE range 4 to 16777216 := 8;
                    mem_mode         : NATURAL  range 0 to 7  := 3;
                    f_sync_type      : NATURAL  range 1 to 4  := 2;
                    r_sync_type      : NATURAL  range 1 to 4  := 2;
                    clk_ratio        : INTEGER; --  range -7 to 7 := 1;  -- NOTE: '0' is illegal
                    rst_mode         : NATURAL  range 0 to 1  := 0;
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
		    data_s          : in std_logic_vector(width-1 downto 0);
                    clr_sync_s      : out std_logic;
                    clr_in_prog_s   : out std_logic;
                    clr_cmplt_s     : out std_logic;
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
                    clr_sync_d      : out std_logic;
                    clr_in_prog_d   : out std_logic;
                    clr_cmplt_d     : out std_logic;
		    data_d          : out std_logic_vector(width-1 downto 0);
                    word_cnt_d      : out std_logic_vector(bit_width((ram_depth+1+(mem_mode mod 2)+((mem_mode/2) mod 2))+1)-1 downto 0);
                    empty_d         : out std_logic;
                    almost_empty_d  : out std_logic;
                    half_full_d     : out std_logic;
                    almost_full_d   : out std_logic;
                    full_d          : out std_logic;
                    error_d         : out std_logic;

		    test : in std_logic
		);
  end component;


  -- Content from file, DW_lp_fifo_1c_df.vhdpp

  component DW_lp_fifo_1c_df
	generic (
                    width        : POSITIVE range 1 to 1024 := 8;
                    depth        : POSITIVE range 4 to 1024 := 8;
                    mem_mode     : NATURAL  range 0 to 7  := 3;
                    arch_type    : NATURAL  range 0 to 4  := 1;
                    af_from_top  : NATURAL  range 0 to 1  := 1;
                    ram_re_ext   : NATURAL  range 0 to 1  := 0;
                    err_mode     : NATURAL  range 0 to 1  := 0;
                    rst_mode     : NATURAL  range 0 to 3  := 0
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


  -- Content from file, DW_ram_2r_2w_s_dff.vhdpp

  component DW_ram_2r_2w_s_dff
  generic(width : INTEGER range 1 to 8192;
          addr_width : INTEGER range 1 to 12; 
          rst_mode : INTEGER range 0 to 1 := 0); 
  port(clk	: in std_logic;
       rst_n    : in std_logic;

       en_w1_n  : in std_logic;
       addr_w1  : in std_logic_vector(addr_width-1 downto 0);
       data_w1  : in std_logic_vector(width-1 downto 0);

       en_w2_n  : in std_logic;
       addr_w2  : in std_logic_vector(addr_width-1 downto 0);
       data_w2  : in std_logic_vector(width-1 downto 0);

       en_r1_n  : in std_logic;
       addr_r1  : in std_logic_vector(addr_width-1 downto 0);
       data_r1  : out std_logic_vector(width-1 downto 0);

       en_r2_n  : in std_logic;
       addr_r2  : in std_logic_vector(addr_width-1 downto 0);
       data_r2  : out std_logic_vector(width-1 downto 0));
  end component;


  -- Content from file, DW_MEM_RW_A_LAT.vhdpp

  component DW_MEM_RW_A_LAT
  generic(data_width : INTEGER range 1 to 256;
          depth      : INTEGER range 2 to 256;
	  rst_mode   : INTEGER range 0 to 1 := 1);
  port(rst_n	: in std_logic;
       wr_n     : in std_logic;
       rw_addr	: in std_logic_vector(depth-1 downto 0);
       data_in	: in std_logic_vector(data_width-1 downto 0);
       data_out	: out std_logic_vector(data_width-1 downto 0));
  end component;


  -- Content from file, DW_MEM_RW_S_LAT.vhdpp

  component DW_MEM_RW_S_LAT
  generic(data_width : INTEGER range 1 to 256;
          depth      : INTEGER range 2 to 256); 
  port(clk	: in std_logic;
       wr_n     : in std_logic;
       rw_addr  : in std_logic_vector(depth-1 downto 0);
       data_in  : in std_logic_vector(data_width-1 downto 0);
       data_out : out std_logic_vector(data_width-1 downto 0));

  end component;


  -- Content from file, DW_MEM_2R_W_A_LAT.vhdpp

  component DW_MEM_2R_W_A_LAT
  generic(data_width : INTEGER range 1 to 256;
          depth      : INTEGER range 2 to 256;
	  rst_mode   : INTEGER range 0 to 1 := 1);
  port(rst_n	: in std_logic;
       wr_n     : in std_logic;
       rd1_addr	: in std_logic_vector(bit_width(depth)-1 downto 0);
       rd2_addr	: in std_logic_vector(bit_width(depth)-1 downto 0);
       wr_addr	: in std_logic_vector((depth-1) downto 0);
       data_in	: in std_logic_vector(data_width-1 downto 0);
       data_rd1_out : out std_logic_vector(data_width-1 downto 0);
       data_rd2_out : out std_logic_vector(data_width-1 downto 0));
  end component;


  -- Content from file, DW_MEM_2R_W_S_LAT.vhdpp

  component DW_MEM_2R_W_S_LAT
  generic(data_width : INTEGER range 1 to 256;
          depth      : INTEGER range 2 to 256); 
  port(clk	: in std_logic;
       wr_n     : in std_logic;
       rd1_addr : in std_logic_vector(bit_width(depth)-1 downto 0);
       rd2_addr : in std_logic_vector(bit_width(depth)-1 downto 0);
       wr_addr  : in std_logic_vector(depth-1 downto 0);
       data_in  : in std_logic_vector(data_width-1 downto 0);
       data_rd1_out : out std_logic_vector(data_width-1 downto 0);
       data_rd2_out : out std_logic_vector(data_width-1 downto 0));

  end component;


  -- Content from file, DW_MEM_R_W_A_LAT.vhdpp

  component DW_MEM_R_W_A_LAT
  generic(data_width : INTEGER range 1 to 256;
          depth      : INTEGER range 2 to 256;
	  rst_mode   : INTEGER range 0 to 1 := 1);
  port(rst_n	: in std_logic;
       wr_n     : in std_logic;
       rd_addr	: in std_logic_vector(bit_width(depth)-1 downto 0);
       wr_addr	: in std_logic_vector(depth-1 downto 0);
       data_in	: in std_logic_vector(data_width-1 downto 0);
       data_out	: out std_logic_vector(data_width-1 downto 0));
  end component;


  -- Content from file, DW_MEM_R_W_S_LAT.vhdpp

  component DW_MEM_R_W_S_LAT
  generic(data_width : INTEGER range 1 to 256;
          depth      : INTEGER range 2 to 256); 
  port(clk	: in std_logic;
       wr_n     : in std_logic;
       rd_addr  : in std_logic_vector(bit_width(depth)-1 downto 0);
       wr_addr  : in std_logic_vector(depth-1 downto 0);
       data_in  : in std_logic_vector(data_width-1 downto 0);
       data_out : out std_logic_vector(data_width-1 downto 0));

  end component;


end DW06_components;

----------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2007 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Bruce Dean May 22 2007
--
-- VERSION:   Entity
--
-- DesignWare_version: cfa1d05a
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
--
--  ABSTRACT:  
--    This block performs a 2d discrete cosine transform using Chen's
--    factorization. The block performs 2 1d transforms, and writes to
--    an intermediate ram. Please see data sheet for more i/o detail.
--
--
--      Parameters:	Valid Values
--      =====		======
--      bpp		4 - 24   
--      n		4-16 even numbers
--      reg_out 	0/1 register outputs
--      tc_mode 	0/1 input data type-0 is binary, 1 = two's complement
--      rt_mode 	0-1 round/truncate:0= round 1=truncate
--      idct		0/1 forward or inverse dct applied to input data
--      co_a - co_p	coeficient input
--
--      Input Ports:	Size	       Description
--      ============	======         =======================
--        clk		1	       clock input
--        rst_n 	1	       asynchronous reset
--        init_n	1	       synchronous reset
--        enable	1	       enable: 0 stall processing
--        start 	1	       1 clock cycle high starts processing
--        dct_rd_data 	bpp/bpt 	read data input, pels or transform data
--        tp_rd_data	n+bpp	       transform intermediate data
--
--      Output Ports	Size	Description
--      ============	====== =======================
--        done  	1	       first data block read
--        ready 	1	       first transform available
--        dct_rd_add  	bit width(n)   fetch data address out
--        tp_rd_add	bit width(n)   fetch transpose data address out
--        tp_wr_add	bit width(n)   write transpose data address out
--        tp_wr_n 	1	       transpose data write(not) signal
--        tp_wr_data	n+bpp	       transpose intermediate data out
--        dct_wr_add  	bit width(n)   write data out
--        dct_wr_n  	1	       final data write(not) signal
--        dct_wr_data  	n/2+bpp        final transformed data out(dct or pels)
--
--
--
--
--  MODIFIED:
--           jbd original simulation model 0707
--
-------------------------------------------------------------------------------
--
library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
--
entity DW_dct_2d is
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
end DW_dct_2d ;

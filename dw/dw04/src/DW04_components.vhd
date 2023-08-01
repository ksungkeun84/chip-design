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
-- VERSION:   Components package file for DW04_components
--
-- DesignWare_version: 173a1150
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_misc.all;
use IEEE.std_logic_arith.all;

library DWARE;
use DWARE.DWpackages.all;

package DW04_components is


  -- Content from file, DW_bc_1.vhdpp

  component DW_bc_1
    port ( capture_clk : in std_logic; -- =tck for sync, =clock_dr for async
	   update_clk  : in std_logic; -- =tck for sync, =update_dr for async
	   capture_en  : in std_logic; -- =clock_dr for sync, =0 for async
	   update_en   : in std_logic; -- =update_dr for sync, =1 for async
	   shift_dr    : in std_logic; -- =shift_dr from TAP
	   mode        : in std_logic; 
	   si          : in std_logic; -- serial data path input
	   data_in     : in std_logic; 
	   data_out    : out std_logic;  
	   so          : out std_logic); -- serial data path output
  end component;


  -- Content from file, DW_bc_2.vhdpp

  component DW_bc_2
    port ( capture_clk : in std_logic; -- =tck for sync, =clock_dr for async
	   update_clk  : in std_logic; -- =tck for sync, =update_dr for async
	   capture_en  : in std_logic; -- =clock_dr for sync, =0 for async
	   update_en   : in std_logic; -- =update_dr for sync, =1 for async
	   shift_dr    : in std_logic; -- =shift_dr from TAP
	   mode        : in std_logic; 
	   si          : in std_logic; -- serial data path input
	   data_in     : in std_logic; 
	   data_out    : out std_logic;  
	   so          : out std_logic); -- serial data path output
  end component;


  -- Content from file, DW_bc_3.vhdpp

  component DW_bc_3
    port ( capture_clk : in std_logic; -- =tck for sync, =clock_dr for async
	   capture_en  : in std_logic; -- =clock_dr for sync, =0 for async
	   shift_dr    : in std_logic; -- =shift_dr from TAP
	   mode        : in std_logic; 
	   si          : in std_logic; -- serial data path input
	   data_in     : in std_logic; 
	   data_out    : out std_logic;  
	   so          : out std_logic); -- serial data path output
  end component;


  -- Content from file, DW_bc_4.vhdpp

  component DW_bc_4
    port ( capture_clk : in std_logic; -- =tck for sync, =clock_dr for async
	   capture_en  : in std_logic; -- =clock_dr for sync, =0 for async
	   shift_dr    : in std_logic; -- =shift_dr from TAP
	   si          : in std_logic; -- serial data path input
	   data_in     : in std_logic; 
	   so          : out std_logic; -- serial data path output
           data_out    : out std_logic); 
  end component;


  -- Content from file, DW_bc_5.vhdpp

  component DW_bc_5
    port ( capture_clk : in std_logic; -- =tck for sync, =clock_dr for async
	   update_clk  : in std_logic; -- =tck for sync, =update_dr for async
	   capture_en  : in std_logic; -- =clock_dr for sync, =0 for async
	   update_en   : in std_logic; -- =update_dr for sync, =1 for async
	   shift_dr    : in std_logic; -- =shift_dr from TAP
	   mode        : in std_logic; 
	   intest      : in std_logic; -- intest instruction signal 
	   si          : in std_logic; -- serial data path input
	   data_in     : in std_logic; 
	   data_out    : out std_logic;  
	   so          : out std_logic); -- serial data path output
  end component;


  -- Content from file, DW_bc_7.vhdpp

  component DW_bc_7
    port ( capture_clk : in std_logic; -- =tck for sync, =clock_dr for async
	   update_clk  : in std_logic; -- =tck for sync, =update_dr for async
	   capture_en  : in std_logic; -- =clock_dr for sync, =0 for async
	   update_en   : in std_logic; -- =update_dr for sync, =1 for async
	   shift_dr    : in std_logic; -- =shift_dr from TAP
	   mode1       : in std_logic; 
	   mode2       : in std_logic; 
	   si          : in std_logic; -- serial data path input
	   pin_input   : in std_logic; -- connected to IC input pin 
	   control_out : in std_logic; -- =output signal from the control BSC 
	   output_data : in std_logic; -- connected to IC data output logic 
	   ic_input    : out std_logic; -- connected to IC input logic 
	   data_out    : out std_logic;  
	   so          : out std_logic); -- serial data path output
  end component;


  -- Content from file, DW_bc_8.vhdpp

  component DW_bc_8
  port (
    capture_clk : in  std_logic;      -- =tck for sync, =clock_dr for async
    update_clk  : in  std_logic;      -- =tck for sync, =update_dr for async
    
    capture_en  : in  std_logic;      -- =clock_dr for sync, =0 for async
    update_en   : in  std_logic;      -- =update_dr for sync, =1 for async
    shift_dr    : in  std_logic;      -- =shift_dr from TAP
    mode        : in  std_logic;
    si          : in  std_logic;      -- serial data path input
    pin_input   : in  std_logic;      -- connected to IC input pin
    output_data : in  std_logic;      -- connected to IC data output logic

    ic_input    : out std_logic;      -- connected to IC input logic 
    data_out    : out std_logic;
    so          : out std_logic);     -- serial data path output
  end component;


  -- Content from file, DW_bc_9.vhdpp

  component DW_bc_9
    port ( capture_clk : in std_logic; -- =tck for sync, =clock_dr for async
	   update_clk  : in std_logic; -- =tck for sync, =update_dr for async
           
	   capture_en  : in std_logic; -- =clock_dr for sync, =0 for async
	   update_en   : in std_logic; -- =update_dr for sync, =1 for async
	   shift_dr    : in std_logic; -- =shift_dr from TAP
	   mode1       : in std_logic; 
	   mode2       : in std_logic;

	   si          : in std_logic; -- serial data path input
	   pin_input   : in std_logic; -- connected to IC input pin
	   output_data : in std_logic; -- connected to IC data output logic

	   data_out    : out std_logic;  
	   so          : out std_logic); -- serial data path output
  end component;


  -- Content from file, DW_bc_10.vhdpp

  component DW_bc_10
  port (
    capture_clk : in  std_logic;      -- =tck for sync, =clock_dr for async
    update_clk  : in  std_logic;      -- =tck for sync, =update_dr for async
    
    capture_en  : in  std_logic;      -- =clock_dr for sync, =0 for async
    update_en   : in  std_logic;      -- =update_dr for sync, =1 for async
    shift_dr    : in  std_logic;      -- =shift_dr from TAP
    mode        : in  std_logic;
    
    si          : in  std_logic;      -- serial data path input
    pin_input   : in  std_logic;      -- connected to IC output pin
    output_data : in  std_logic;      -- connected to IC data output logic

    data_out    : out std_logic;
    so          : out std_logic);     -- serial data path output
  end component;


  -- Content from file, DW_wc_d1_s.vhdpp

  component DW_wc_d1_s
  generic (
    rst_mode : natural := 0);           -- reset mode 0, 1,2 or 3
  port (
    shift_clk    : in  std_logic;     -- shift clock
    
    rst_n        : in  std_logic;     -- active low reset 
    set_n        : in  std_logic;     -- active low set
    
    shift_en     : in  std_logic;     -- shift enable
    capture_en   : in  std_logic;     -- Capture enable; active low
    safe_control : in  std_logic;     -- Capture enable
    safe_value   : in  std_logic;     -- Safe_value input    
    cfi          : in  std_logic;     -- serial data path input
    cti          : in  std_logic;     -- serial data path input
    
    cfo          : out std_logic;
    cto          : out std_logic;     -- serial data path output

    toggle_state : in  std_logic);
  end component;


  -- Content from file, DW_wc_s1_s.vhdpp

  component DW_wc_s1_s
  generic (
    rst_mode : natural := 0);           -- reset mode 0, 1 or 2
  port (
    shift_clk    : in  std_logic;     -- shift clock
    
    rst_n        : in  std_logic;     -- active low reset 
    set_n        : in  std_logic;     -- active low set
    
    shift_en     : in  std_logic;     -- shift enable
    capture_en    : in  std_logic;     -- Capture enable
    safe_control : in  std_logic;     -- Capture enable
    
    safe_value   : in  std_logic;     -- serial data path input    
    cfi          : in  std_logic;     -- serial data path input
    cti          : in  std_logic;     -- serial data path input
    
    cfo          : out std_logic;
    cfo_n        : out std_logic;
    cto          : out std_logic;     -- serial data path output
    
    toggle_state : in  std_logic);
  end component;


  -- Content from file, DW_crc_s.vhdpp

  component DW_crc_s

    generic (
	    data_width : NATURAL range 1 to 64 := 16;
	    poly_size  : NATURAL range 2 to 64 := 16;
	    crc_cfg    : NATURAL range 0 to 7  := 7;
	    bit_order  : NATURAL range 0 to 3  := 3;
	    poly_coef0 : NATURAL range 1 to 65535 := 4129;
	    poly_coef1 : NATURAL range 0 to 65535 := 0;
	    poly_coef2 : NATURAL range 0 to 65535 := 0;
	    poly_coef3 : NATURAL range 0 to 65535 := 0
	    );

    port    (
	    clk : in std_logic;
	    rst_n : in std_logic;
	    init_n : in std_logic;
	    enable : in std_logic;
	    drain : in std_logic;
	    ld_crc_n : in std_logic;
	    data_in : in std_logic_vector(data_width-1 downto 0);
	    crc_in : in std_logic_vector(poly_size-1 downto 0);

	    draining : out std_logic;
	    drain_done : out std_logic;
	    crc_ok : out std_logic;
	    data_out : out std_logic_vector(data_width-1 downto 0);
	    crc_out : out std_logic_vector(poly_size-1 downto 0)
	    );

  end component;


  -- Content from file, DW_crc_p.vhdpp

  component DW_crc_p

    generic (
	    data_width : NATURAL range 1 to 512 := 16;
	    poly_size  : NATURAL range 2 to 64 := 16;
	    crc_cfg    : NATURAL range 0 to 7  := 7;
	    bit_order  : NATURAL range 0 to 3  := 3;
	    poly_coef0 : NATURAL range 1 to 65535 := 4129;
	    poly_coef1 : NATURAL range 0 to 65535 := 0;
	    poly_coef2 : NATURAL range 0 to 65535 := 0;
	    poly_coef3 : NATURAL range 0 to 65535 := 0
	    );

    port    (
	    data_in : in std_logic_vector(data_width-1 downto 0);
	    crc_in : in std_logic_vector(poly_size-1 downto 0);

	    crc_ok : out std_logic;
	    crc_out : out std_logic_vector(poly_size-1 downto 0)
	    );

  end component;


  -- Content from file, DW_ecc.vhdpp

  component DW_ecc
  generic(width: INTEGER range 4 to 8178;
          chkbits : INTEGER range 5 to 14;
	  synd_sel : INTEGER range 0 to 1 );
  port(gen: in std_logic;
       correct_n: in std_logic;
       datain: in std_logic_vector(width-1 downto 0);
       chkin: in std_logic_vector(chkbits-1 downto 0);
       err_detect: out std_logic;
       err_multpl: out std_logic;
       dataout: out std_logic_vector(width-1 downto 0);
       chkout: out std_logic_vector(chkbits-1 downto 0));
  end component;


  -- Content from file, DW04_par_gen.vhdpp

  component DW04_par_gen
  generic(width: POSITIVE;
          par_type : INTEGER range 0 to 1);
  port(datain: in std_logic_vector(width-1 downto 0);
       parity: out std_logic);
  end component;


  -- Content from file, DW04_shad_reg.vhdpp

  component DW04_shad_reg
  generic(width: POSITIVE range 1 to 512;
  	bld_shad_reg: NATURAL range 0 to 1);
  port(datain: in std_logic_vector(width-1 downto 0);
       sys_clk, shad_clk, reset : in std_logic;
       SI, SE   : in std_logic;
       sys_out  : out std_logic_vector(width-1 downto 0);
       shad_out : out std_logic_vector(width-1 downto 0);
       SO       : out std_logic);
  end component;


  -- Content from file, DW_tap.vhdpp

  component DW_tap
    generic(width : INTEGER range 2 to 256;
        id        : INTEGER range 0 to 1 := 0;
	version   : INTEGER range 0 to 15 := 0;
	part      : INTEGER range 0 to 65535 := 0;
	man_num   : INTEGER range 0 to 2047 := 0;
        sync_mode : INTEGER range 0 to 1 := 0;
        tst_mode  : INTEGER range 0 to 1 := 1);
    port ( tck       : in std_logic;
           trst_n    : in std_logic;
           tms       : in std_logic;
           tdi       : in std_logic;
           so        : in std_logic;
           bypass_sel: in std_logic;
           sentinel_val : in std_logic_vector(width-2 downto 0);
           clock_dr  : out std_logic;
           shift_dr  : out std_logic;
           update_dr : out std_logic;
           tdo       : out std_logic;
	   tdo_en    : out std_logic;
           tap_state    : out std_logic_vector(15 downto 0);
           extest    : out std_logic;
           samp_load : out std_logic;
           instructions : out std_logic_vector(width-1 downto 0);
           sync_capture_en : out std_logic;
           sync_update_dr : out std_logic;
	   test : in std_logic);
  end component;


  -- Content from file, DW_tap_uc.vhdpp

  component DW_tap_uc
  generic(
    width         : INTEGER range 2 to 256;
    id            : INTEGER range 0 to 1          := 0;
    idcode_opcode : INTEGER  := 1;
    version       : INTEGER range 0 to 15         := 0;
    part          : INTEGER range 0 to 65535      := 0;
    man_num       : INTEGER range 0 to 2047       := 0;
    sync_mode     : INTEGER range 0 to 1          := 0;
    tst_mode      : INTEGER range 0 to 1          := 1);

  port (
    tck             : in  std_logic;
    trst_n          : in  std_logic;
    tms             : in  std_logic;
    tdi             : in  std_logic;
    so              : in  std_logic;
    bypass_sel      : in  std_logic;
    sentinel_val    : in  std_logic_vector(width-2 downto 0);
    
    device_id_sel   : in  std_logic;
    user_code_sel   : in  std_logic;
    user_code_val   : in  std_logic_vector(31 downto 0);
    
    ver             : in  std_logic_vector(3 downto 0);
    ver_sel         : in  std_logic;
    part_num        : in  std_logic_vector(15 downto 0);
    part_num_sel    : in  std_logic;
    mnfr_id         : in  std_logic_vector(10 downto 0);
    mnfr_id_sel     : in  std_logic;
    
    clock_dr        : out std_logic;
    shift_dr        : out std_logic;
    update_dr       : out std_logic;
    tdo             : out std_logic;
    tdo_en          : out std_logic;
    tap_state       : out std_logic_vector(15 downto 0);
    instructions    : out std_logic_vector(width-1 downto 0);
    sync_capture_en : out std_logic;
    sync_update_dr  : out std_logic;
    test            : in  std_logic);
  end component;


  -- Content from file, DW_control_force.vhdpp

  component DW_control_force
    port (DIN   : in std_logic;
          TD    : in std_logic;
          TM    : in std_logic;
          TPE   : in std_logic;
          DOUT  : out std_logic);
  end component;


  -- Content from file, DW_Z_control_force.vhdpp

  component DW_Z_control_force
    port (TD    : in std_logic;
          TM    : in std_logic;
          TPE   : in std_logic; 
          DRVR  : out std_logic);
  end component;


  -- Content from file, DW_observ_dgen.vhdpp

  component DW_observ_dgen
    port (OBIN  : in std_logic;
          CLK   : in std_logic;
          TDGO  : out std_logic);
  end component;


  -- Content from file, DW_8b10b_dec.vhdpp

  component DW_8b10b_dec
	generic(
		bytes :		integer range 1 to 16 := 2;
		k28_5_only :	integer range 0 to 1  := 0;
		en_mode :	integer range 0 to 1  := 0;
		init_mode :	integer range 0 to 1  := 0;
		rst_mode :	integer range 0 to 1  := 0;
                op_iso_mode :   integer range 0 to 4  := 0
		);
	port(
		clk : 		in std_logic;
		rst_n : 	in std_logic;
		init_rd_n :	in std_logic;
		init_rd_val :	in std_logic;
		data_in :	in std_logic_vector(bytes*10-1 downto 0);
		error :		out std_logic;
		rd :		out std_logic;
		k_char :	out std_logic_vector(bytes-1 downto 0);
		data_out :	out std_logic_vector(bytes*8-1 downto 0);
		rd_err :	out std_logic;
		code_err :	out std_logic;
		enable :	in std_logic;
		rd_err_bus :	out std_logic_vector(bytes-1 downto 0);
		code_err_bus :	out std_logic_vector(bytes-1 downto 0)
		);
  end component;


  -- Content from file, DW_8b10b_enc.vhdpp

  component DW_8b10b_enc
	generic(
		bytes :		integer range 1 to 16 := 2;
		k28_5_only :	integer range 0 to 1  := 0;
		en_mode :	integer range 0 to 1  := 0;
		init_mode :	integer range 0 to 1  := 0;
		rst_mode :	integer range 0 to 1  := 0;
		op_iso_mode :	integer range 0 to 4  := 0
		);
	port(
		clk : 		in std_logic;
		rst_n : 	in std_logic;
		init_rd_n :	in std_logic;
		init_rd_val :	in std_logic;
		k_char :	in std_logic_vector(bytes-1 downto 0);
		data_in :	in std_logic_vector(bytes*8-1 downto 0);
		rd :		out std_logic;
		data_out :	out std_logic_vector(bytes*10-1 downto 0);
		enable :	in std_logic
		);
  end component;


  -- Content from file, DW_8b10b_unbal.vhdpp

  component DW_8b10b_unbal
    
    generic(
	    k28_5_only : INTEGER range 0 to 1 := 0
	   );
    port(
	    k_char : in std_logic;			-- Special Character control input
	    data_in : in std_logic_vector(7 downto 0);	-- Input data bus (eight bits)
	    unbal   : out std_logic			-- Predicted unbalance status output
	 );
  end component;


  -- Content from file, DW_lp_piped_ecc.vhdpp

  component DW_lp_piped_ecc
   generic (
     data_width  : POSITIVE range 8 to 8178 := 8;
     chk_width   : POSITIVE range 5 to 14   := 5;
     rw_mode     : NATURAL  range 0 to 1    := 1;
     op_iso_mode : NATURAL  range 0 to 4    := 0;
     id_width    : POSITIVE range 1 to 1024 := 1;
     in_reg      : NATURAL  range 0 to 1    := 0;
     stages      : POSITIVE range 1 to 1022 := 4;
     out_reg     : NATURAL  range 0 to 1    := 0;
     no_pm       : NATURAL  range 0 to 1    := 1;
     rst_mode    : NATURAL  range 0 to 1    := 0
   );

   port (
     clk          : in std_logic;
     rst_n        : in std_logic;
     datain       : in std_logic_vector(data_width-1 downto 0);
     chkin        : in std_logic_vector(chk_width-1 downto 0);
     err_detect   : out std_logic;
     err_multiple : out std_logic;
     dataout      : out std_logic_vector(data_width-1 downto 0);
     chkout       : out std_logic_vector(chk_width-1 downto 0);
     syndout      : out std_logic_vector(chk_width-1 downto 0);
     launch       : in std_logic;
     launch_id    : in std_logic_vector(id_width-1 downto 0);
     pipe_full    : out std_logic;
     pipe_ovf     : out std_logic;
     accept_n     : in std_logic;
     arrive       : out std_logic;
     arrive_id    : out std_logic_vector(id_width-1 downto 0);
     push_out_n   : out std_logic;
     pipe_census  : out std_logic_vector(bit_width(maximum(1,in_reg+(stages-1)+out_reg)+1)-1 downto 0)
   );
  end component;


  -- Content from file, DW_BYPASS.vhdpp

  component DW_BYPASS
    port ( capture_clk : in std_logic; -- =tck for sync, =clock_dr for async
	   capture_en  : in std_logic; -- =clock_dr for sync, =1 for async
	   shift_dr    : in std_logic; -- =shift_dr from TAP
	   capture_dr  : in std_logic; -- =capture_dr from TAP
	   tdi         : in std_logic; -- serial data path input
	   so          : out std_logic); -- serial data path output
  end component;


  -- Content from file, DW_CAPTURE.vhdpp

  component DW_CAPTURE
    port ( capture_clk : in std_logic; -- =tck for sync, =clock_dr for async
	   capture_en  : in std_logic; -- =clock_dr for sync, =1 for async
	   shift_dr    : in std_logic; -- =shift_dr from TAP
	   si          : in std_logic; -- serial data path input
	   data_in     : in std_logic; 
	   so          : out std_logic); -- serial data path output
  end component;


  -- Content from file, DW_CAPUP.vhdpp

  component DW_CAPUP
    port ( capture_clk : in std_logic; -- =tck for sync, =clock_dr for async
	   update_clk  : in std_logic; -- =tck for sync, =update_dr for async
	   capture_en  : in std_logic; -- =clock_dr for sync, =1 for async
	   update_en   : in std_logic; -- =update_dr for sync, =1 for async
	   shift_dr    : in std_logic; -- =shift_dr from TAP
	   si          : in std_logic; -- serial data path input
	   data_in     : in std_logic; 
	   data_out    : out std_logic;  
	   so          : out std_logic); -- serial data path output
  end component;


  -- Content from file, DW_IDREG.vhdpp

  component DW_IDREG
    generic (version : integer range 0 to 15 := 0;
	     part    : integer range 0 to 65535 := 0;
	     man_num : integer range 0 to 2047 := 0);
    port ( capture_clk : in std_logic; -- =tck for sync, =clock_ir for async
	   capture_en  : in std_logic; -- =clock_ir for sync, =0 for async
	   shift_dr    : in std_logic; -- =shift_dr from TAP
	   si          : in std_logic; -- serial data path input
	   so          : out std_logic); -- serial data path output
  end component;


  -- Content from file, DW_IDREGUC.vhdpp

  component DW_IDREGUC
  generic (
    version : integer range 0 to 15    := 0;
    part    : integer range 0 to 65535 := 0;
    man_num : integer range 0 to 2047  := 0);
  port (
    capture_clk  : in  std_logic;     -- =tck for sync, =clock_ir for async
    capture_en   : in  std_logic;     -- =clock_ir for sync, =0 for async
    shift_dr     : in  std_logic;     -- =shift_dr from TAP
    si           : in  std_logic;     -- serial data path input
    
    user_code_sel   : in  std_logic;
    user_code_val   : in  std_logic_vector(31 downto 0);
    
    ver          : in  std_logic_vector(3 downto 0);
    ver_sel      : in  std_logic;
    part_num     : in  std_logic_vector(15 downto 0);
    part_num_sel : in  std_logic;
    mnfr_id      : in  std_logic_vector(10 downto 0);
    mnfr_id_sel  : in  std_logic;
    
    so           : out std_logic);    -- serial data path output
  end component;


  -- Content from file, DW_INSTRREG.vhdpp

  component DW_INSTRREG
    generic (width : INTEGER range 1 to 256 );
    port ( capture_clk : in std_logic; -- =tck for sync, =clock_ir for async
	   update_clk  : in std_logic; -- =tck for sync, =update_ir for async
	   test_logic_rst 	: in std_logic; -- test_logic_reset state
	   capture_en  : in std_logic; -- =clock_ir for sync, =0 for async
	   update_en   : in std_logic; -- =update_ir for sync, =1 for async
	   shift_ir    : in std_logic; -- =shift_dr from TAP
	   si          : in std_logic; -- serial data path input
	   init_instr_value : in std_logic_vector(width-1 downto 0);
	   sentinel_val: in std_logic_vector(width-1 downto 0); 
	   instruction_out	: out std_logic_vector(width-1 downto 0);  
	   so          : out std_logic; -- serial data path output
	   instruction_shift	: out std_logic_vector(width-1 downto 0));
  end component;


  -- Content from file, DW_INSTRREGID.vhdpp

  component DW_INSTRREGID
  generic
    (width         : INTEGER range 2 to 32;
     id            : INTEGER range 0 to 1;
     idcode_opcode : integer );
  port
    ( capture_clk     : in  std_logic;  -- =tck for sync, clock_ir for async
      update_clk      : in  std_logic;  -- =tck for sync, update_ir for async
      
      test_logic_rst  : in  std_logic;  -- test_logic_reset state
      capture_en      : in  std_logic;  -- =clock_ir for sync, =0 for async
      update_en       : in  std_logic;  -- =update_ir for sync, =1 for async
      shift_ir        : in  std_logic;  -- =shift_dr from TAP
      si              : in  std_logic;  -- serial data path input
      sentinel_val    : in  std_logic_vector(width-2 downto 0);
      
      instruction_out : out std_logic_vector(width-1 downto 0);
      so              : out std_logic);  -- serial data path output
  end component;


  -- Content from file, DW_TAPFSM.vhdpp

  component DW_TAPFSM
  
  generic(
    sync_mode : INTEGER range 0 to 1 := 0);  
  port (
    tck       : in  std_logic;
    tck_n     : in  std_logic;
    trst_n    : in  std_logic;
    tms       : in  std_logic;
    clock_dr  : out std_logic;
    dr_sel    : out std_logic;
    clock_ir  : out std_logic;
    shift_dr  : out std_logic;
    shift_ir  : out std_logic;
    update_dr : out std_logic;
    update_ir : out std_logic;
    instr_rst : out std_logic;
    state     : out std_logic_vector(15 downto 0)
    );
  end component;


  -- Content from file, DW_tap_uc2.vhdpp

  component DW_tap_uc2
  generic(
    width         : INTEGER range 2 to 256;
    id            : INTEGER range 0 to 1          := 0;
    idcode_opcode : INTEGER  := 1;
    version       : INTEGER range 0 to 15         := 0;
    part          : INTEGER range 0 to 65535      := 0;
    man_num       : INTEGER range 0 to 2047       := 0;
    sync_mode     : INTEGER range 0 to 1          := 0;
    tst_mode      : INTEGER range 0 to 1          := 1);

  port (
    tck             : in  std_logic;
    trst_n          : in  std_logic;
    tms             : in  std_logic;
    tdi             : in  std_logic;
    so              : in  std_logic;
    bypass_sel      : in  std_logic;
    sentinel_val    : in  std_logic_vector(width-2 downto 0);
    
    device_id_sel   : in  std_logic;
    user_code_sel   : in  std_logic;
    user_code_val   : in  std_logic_vector(31 downto 0);
    
    ver             : in  std_logic_vector(3 downto 0);
    ver_sel         : in  std_logic;
    part_num        : in  std_logic_vector(15 downto 0);
    part_num_sel    : in  std_logic;
    mnfr_id         : in  std_logic_vector(10 downto 0);
    mnfr_id_sel     : in  std_logic;
    
    clock_dr        : out std_logic;
    shift_dr        : out std_logic;
    update_dr       : out std_logic;
    tdo             : out std_logic;
    tdo_en          : out std_logic;
    tap_state       : out std_logic_vector(15 downto 0);
    instructions    : out std_logic_vector(width-1 downto 0);
    sync_capture_en : out std_logic;
    sync_update_dr  : out std_logic;
    test            : in  std_logic;
    instructions_shift : out std_logic_vector(width-1 downto 0)
    );
  end component;


  -- Content from file, DW_crc_spm.vhdpp

  component DW_crc_spm

    generic (
	    data_width : POSITIVE := 16;
	    poly_size  : NATURAL range 2 to 64 := 16;
	    poly_coef0 : NATURAL range 1 to 65535 := 4129;
	    poly_coef1 : NATURAL range 0 to 65535 := 0;
	    poly_coef2 : NATURAL range 0 to 65535 := 0;
	    poly_coef3 : NATURAL range 0 to 65535 := 0
	    );

    port    (
	    drain_n : in std_logic;
	    data_in : in std_logic_vector(data_width-1 downto 0);
	    current_crc : in std_logic_vector(poly_size-1 downto 0);

	    next_crc : out std_logic_vector(poly_size-1 downto 0)
	    );

  end component;


  -- Content from file, DW_mbist_apg.vhdpp

  component DW_mbist_apg

  generic (
          addr_width : integer range 3 to 24 := 7;
          data_width : integer range 3 to 256 := 16;
          sep_addr_ports : integer range 0 to 1 := 0;
          num_ports : integer range 1 to 4 := 1;
          memory_full : integer range 0 to 1 := 1;
          registered_io : integer range 0 to 3 := 2;
          in_sys_depth : integer range 0 to 2 := 0;
          out_sys_depth : integer range 0 to 2 := 0;
          mem_start_addr : integer range 0 to 16777215 := 0;
          mem_end_addr : integer range 7 to 16777215 := 32768;
          shadow_disable : integer range 0 to 1 := 1;
          custom_pattern_en : integer range 0 to 1 := 0;
          remove_debug_out_port : integer range 0 to 1 := 1;
          disable_pause_on_error : integer range 0 to 1 := 0;
          mem_we_width_0 : integer range 1 to 256 := 1;
          mem_we_width_1 : integer range 1 to 256 := 1;
          mem_we_width_2 : integer range 1 to 256 := 1;
          mem_we_width_3 : integer range 1 to 256 := 1;
          mem_csoe_en_0 : integer range 0 to 3 := 3;
          mem_csoe_en_1 : integer range 0 to 3 := 3;
          mem_csoe_en_2 : integer range 0 to 3 := 3;
          mem_csoe_en_3 : integer range 0 to 3 := 3;
          mem_csoe_pol_0 : integer range 0 to 3 := 3;
          mem_csoe_pol_1 : integer range 0 to 3 := 3;
          mem_csoe_pol_2 : integer range 0 to 3 := 3;
          mem_csoe_pol_3 : integer range 0 to 3 := 3;
          mem_cs_width_0 : integer range 0 to 256 := 1;
          mem_cs_width_1 : integer range 0 to 256 := 1;
          mem_cs_width_2 : integer range 0 to 256 := 1;
          mem_cs_width_3 : integer range 0 to 256 := 1;
          mem_oe_width_0 : integer range 0 to 256 := 1;
          mem_oe_width_1 : integer range 0 to 256 := 1;
          mem_oe_width_2 : integer range 0 to 256 := 1;
          mem_oe_width_3 : integer range 0 to 256 := 1
          );
  port (
         bist_clk : in std_logic;
         bist_clk_t : in std_logic;
         rst_n_a : in std_logic;
         rst_t_n_a : in std_logic;
         simulation_mode : in std_logic;
         bist_mode : in std_logic;
         dbist_mode : in std_logic;
         port_no : in std_logic_vector(3 downto 0);
         atpg_1 : in std_logic;
         load_parallel_pattern : in std_logic;
         load_serial_pattern : in std_logic;
         serial_pattern_out : in std_logic;
         segment_descr : in std_logic_vector(4 downto 0);
         segment_en : in std_logic;
         continue_test : in std_logic;
         cont_pause_on_error : in std_logic;
         debug_en : in std_logic;
         debug_si : in std_logic;
         custom_pattern : in std_logic_vector(data_width - 1 downto 0);
         cap_mem_addr_0 : in std_logic_vector(addr_width - 1 downto 0);
         cap_mem_addr_1 : in std_logic_vector(addr_width - 1 downto 0);
         cap_mem_addr_2 : in std_logic_vector(addr_width - 1 downto 0);
         cap_mem_addr_3 : in std_logic_vector(addr_width - 1 downto 0);
         cap_mem_wr_addr_0 : in std_logic_vector(addr_width - 1 downto 0);
         cap_mem_wr_addr_1 : in std_logic_vector(addr_width - 1 downto 0);
         cap_mem_wr_addr_2 : in std_logic_vector(addr_width - 1 downto 0);
         cap_mem_wr_addr_3 : in std_logic_vector(addr_width - 1 downto 0);
         cap_mem_rd_addr_0 : in std_logic_vector(addr_width - 1 downto 0);
         cap_mem_rd_addr_1 : in std_logic_vector(addr_width - 1 downto 0);
         cap_mem_rd_addr_2 : in std_logic_vector(addr_width - 1 downto 0);
         cap_mem_rd_addr_3 : in std_logic_vector(addr_width - 1 downto 0);
         cap_mem_wr_data_0 : in std_logic_vector(data_width - 1 downto 0);
         cap_mem_wr_data_1 : in std_logic_vector(data_width - 1 downto 0);
         cap_mem_wr_data_2 : in std_logic_vector(data_width - 1 downto 0);
         cap_mem_wr_data_3 : in std_logic_vector(data_width - 1 downto 0);

         cap_mem_cs_0 : in std_logic_vector(mem_cs_width_0 - 1 downto 0);
         cap_mem_cs_1 : in std_logic_vector(mem_cs_width_1 - 1 downto 0);
         cap_mem_cs_2 : in std_logic_vector(mem_cs_width_2 - 1 downto 0);
         cap_mem_cs_3 : in std_logic_vector(mem_cs_width_3 - 1 downto 0);
         cap_mem_we_0 : in std_logic_vector(mem_we_width_0 - 1 downto 0);
         cap_mem_we_1 : in std_logic_vector(mem_we_width_1 - 1 downto 0);
         cap_mem_we_2 : in std_logic_vector(mem_we_width_2 - 1 downto 0);
         cap_mem_we_3 : in std_logic_vector(mem_we_width_3 - 1 downto 0);
         cap_mem_oe_0 : in std_logic_vector(mem_oe_width_0 - 1 downto 0);
         cap_mem_oe_1 : in std_logic_vector(mem_oe_width_1 - 1 downto 0);
         cap_mem_oe_2 : in std_logic_vector(mem_oe_width_2 - 1 downto 0);
         cap_mem_oe_3 : in std_logic_vector(mem_oe_width_3 - 1 downto 0);
         bist_rd_data_0 : in std_logic_vector(data_width - 1 downto 0);
         bist_rd_data_1 : in std_logic_vector(data_width - 1 downto 0);
         bist_rd_data_2 : in std_logic_vector(data_width - 1 downto 0);
         bist_rd_data_3 : in std_logic_vector(data_width - 1 downto 0);
         segment_active : out std_logic;
         mem_fail_n : out std_logic;
         bist_cs_n_0 : out std_logic;
         bist_cs_n_1 : out std_logic;
         bist_cs_n_2 : out std_logic;
         bist_cs_n_3 : out std_logic;
         bist_oe_n_0 : out std_logic;
         bist_oe_n_1 : out std_logic;
         bist_oe_n_2 : out std_logic;
         bist_oe_n_3 : out std_logic;
         bist_we_n_0 : out std_logic;
         bist_we_n_1 : out std_logic;
         bist_we_n_2 : out std_logic;
         bist_we_n_3 : out std_logic;
         bist_addr_0 : out std_logic_vector(addr_width - 1 downto 0);
         bist_addr_1 : out std_logic_vector(addr_width - 1 downto 0);
         bist_addr_2 : out std_logic_vector(addr_width - 1 downto 0);
         bist_addr_3 : out std_logic_vector(addr_width - 1 downto 0);
         bist_wr_data_0 : out std_logic_vector(data_width - 1 downto 0);
         bist_wr_data_1 : out std_logic_vector(data_width - 1 downto 0);
         bist_wr_data_2 : out std_logic_vector(data_width - 1 downto 0);
         bist_wr_data_3 : out std_logic_vector(data_width - 1 downto 0);
         cap_mem_cs_0_nc : out std_logic_vector(mem_cs_width_0 - 1 downto 0);
         cap_mem_cs_1_nc : out std_logic_vector(mem_cs_width_1 - 1 downto 0);
         cap_mem_cs_2_nc : out std_logic_vector(mem_cs_width_2 - 1 downto 0);
         cap_mem_cs_3_nc : out std_logic_vector(mem_cs_width_3 - 1 downto 0);
         cap_mem_we_0_nc : out std_logic_vector(mem_we_width_0 - 1 downto 0);
         cap_mem_we_1_nc : out std_logic_vector(mem_we_width_1 - 1 downto 0);
         cap_mem_we_2_nc : out std_logic_vector(mem_we_width_2 - 1 downto 0);
         cap_mem_we_3_nc : out std_logic_vector(mem_we_width_3 - 1 downto 0);
         cap_mem_oe_0_nc : out std_logic_vector(mem_oe_width_0 - 1 downto 0);
         cap_mem_oe_1_nc : out std_logic_vector(mem_oe_width_1 - 1 downto 0);
         cap_mem_oe_2_nc : out std_logic_vector(mem_oe_width_2 - 1 downto 0);
         cap_mem_oe_3_nc : out std_logic_vector(mem_oe_width_3 - 1 downto 0);
         debug_out : out std_logic_vector(data_width - 1 downto 0);
         debug_so : out std_logic
       );
  end component;


  -- Content from file, DW_mbist_ctrl.vhdpp

  component DW_mbist_ctrl

  generic (
          num_mem : integer range 1 to 64 := 4;
          a_5 : integer range 0 to 1 := 1;
          zero_one : integer range 0 to 1 := 1;
          pair_sep : integer range 0 to 1 := 0;
          custom_pattern_en : integer range 0 to 1 := 0;
          disable_pause_on_error : integer range 0 to 1 := 0;
          disable_parallel_load : integer range 0 to 1 := 1;

          num_ports_0 : integer range 1 to 4 := 1;
          data_width_0 : integer range 3 to 256 := 16; 
          registered_io_0 : integer range 0 to 3 := 2;
          in_sys_depth_0 : integer range 0 to 2 := 0;
          out_sys_depth_0 : integer range 0 to 2 := 0;

          num_ports_1 : integer range 1 to 4 := 1;
          data_width_1 : integer range 3 to 256 := 16; 
          registered_io_1 : integer range 0 to 3 := 2;
          in_sys_depth_1 : integer range 0 to 2 := 0;
          out_sys_depth_1 : integer range 0 to 2 := 0;

          num_ports_2 : integer range 1 to 4 := 1;
          data_width_2 : integer range 3 to 256 := 16; 
          registered_io_2 : integer range 0 to 3 := 2;
          in_sys_depth_2 : integer range 0 to 2 := 0;
          out_sys_depth_2 : integer range 0 to 2 := 0;

          num_ports_3 : integer range 1 to 4 := 1;
          data_width_3 : integer range 3 to 256 := 16; 
          registered_io_3 : integer range 0 to 3 := 2;
          in_sys_depth_3 : integer range 0 to 2 := 0;
          out_sys_depth_3 : integer range 0 to 2 := 0;

          num_ports_4 : integer range 1 to 4 := 1;
          data_width_4 : integer range 3 to 256 := 16; 
          registered_io_4 : integer range 0 to 3 := 2;
          in_sys_depth_4 : integer range 0 to 2 := 0;
          out_sys_depth_4 : integer range 0 to 2 := 0;

          num_ports_5 : integer range 1 to 4 := 1;
          data_width_5 : integer range 3 to 256 := 16; 
          registered_io_5 : integer range 0 to 3 := 2;
          in_sys_depth_5 : integer range 0 to 2 := 0;
          out_sys_depth_5 : integer range 0 to 2 := 0;

          num_ports_6 : integer range 1 to 4 := 1;
          data_width_6 : integer range 3 to 256 := 16; 
          registered_io_6 : integer range 0 to 3 := 2;
          in_sys_depth_6 : integer range 0 to 2 := 0;
          out_sys_depth_6 : integer range 0 to 2 := 0;

          num_ports_7 : integer range 1 to 4 := 1;
          data_width_7 : integer range 3 to 256 := 16; 
          registered_io_7 : integer range 0 to 3 := 2;
          in_sys_depth_7 : integer range 0 to 2 := 0;
          out_sys_depth_7 : integer range 0 to 2 := 0;

          num_ports_8 : integer range 1 to 4 := 1;
          data_width_8 : integer range 3 to 256 := 16; 
          registered_io_8 : integer range 0 to 3 := 2;
          in_sys_depth_8 : integer range 0 to 2 := 0;
          out_sys_depth_8 : integer range 0 to 2 := 0;

          num_ports_9 : integer range 1 to 4 := 1;
          data_width_9 : integer range 3 to 256 := 16; 
          registered_io_9 : integer range 0 to 3 := 2;
          in_sys_depth_9 : integer range 0 to 2 := 0;
          out_sys_depth_9 : integer range 0 to 2 := 0;

          num_ports_10 : integer range 1 to 4 := 1;
          data_width_10 : integer range 3 to 256 := 16; 
          registered_io_10 : integer range 0 to 3 := 2;
          in_sys_depth_10 : integer range 0 to 2 := 0;
          out_sys_depth_10 : integer range 0 to 2 := 0;

          num_ports_11 : integer range 1 to 4 := 1;
          data_width_11 : integer range 3 to 256 := 16; 
          registered_io_11 : integer range 0 to 3 := 2;
          in_sys_depth_11 : integer range 0 to 2 := 0;
          out_sys_depth_11 : integer range 0 to 2 := 0;

          num_ports_12 : integer range 1 to 4 := 1;
          data_width_12 : integer range 3 to 256 := 16; 
          registered_io_12 : integer range 0 to 3 := 2;
          in_sys_depth_12 : integer range 0 to 2 := 0;
          out_sys_depth_12 : integer range 0 to 2 := 0;

          num_ports_13 : integer range 1 to 4 := 1;
          data_width_13 : integer range 3 to 256 := 16; 
          registered_io_13 : integer range 0 to 3 := 2;
          in_sys_depth_13 : integer range 0 to 2 := 0;
          out_sys_depth_13 : integer range 0 to 2 := 0;

          num_ports_14 : integer range 1 to 4 := 1;
          data_width_14 : integer range 3 to 256 := 16; 
          registered_io_14 : integer range 0 to 3 := 2;
          in_sys_depth_14 : integer range 0 to 2 := 0;
          out_sys_depth_14 : integer range 0 to 2 := 0;

          num_ports_15 : integer range 1 to 4 := 1;
          data_width_15 : integer range 3 to 256 := 16; 
          registered_io_15 : integer range 0 to 3 := 2;
          in_sys_depth_15 : integer range 0 to 2 := 0;
          out_sys_depth_15 : integer range 0 to 2 := 0;

          num_ports_16 : integer range 1 to 4 := 1;
          data_width_16 : integer range 3 to 256 := 16; 
          registered_io_16 : integer range 0 to 3 := 2;
          in_sys_depth_16 : integer range 0 to 2 := 0;
          out_sys_depth_16 : integer range 0 to 2 := 0;

          num_ports_17 : integer range 1 to 4 := 1;
          data_width_17 : integer range 3 to 256 := 16; 
          registered_io_17 : integer range 0 to 3 := 2;
          in_sys_depth_17 : integer range 0 to 2 := 0;
          out_sys_depth_17 : integer range 0 to 2 := 0;

          num_ports_18 : integer range 1 to 4 := 1;
          data_width_18 : integer range 3 to 256 := 16; 
          registered_io_18 : integer range 0 to 3 := 2;
          in_sys_depth_18 : integer range 0 to 2 := 0;
          out_sys_depth_18 : integer range 0 to 2 := 0;

          num_ports_19 : integer range 1 to 4 := 1;
          data_width_19 : integer range 3 to 256 := 16; 
          registered_io_19 : integer range 0 to 3 := 2;
          in_sys_depth_19 : integer range 0 to 2 := 0;
          out_sys_depth_19 : integer range 0 to 2 := 0;

          num_ports_20 : integer range 1 to 4 := 1;
          data_width_20 : integer range 3 to 256 := 16; 
          registered_io_20 : integer range 0 to 3 := 2;
          in_sys_depth_20 : integer range 0 to 2 := 0;
          out_sys_depth_20 : integer range 0 to 2 := 0;

          num_ports_21 : integer range 1 to 4 := 1;
          data_width_21 : integer range 3 to 256 := 16; 
          registered_io_21 : integer range 0 to 3 := 2;
          in_sys_depth_21 : integer range 0 to 2 := 0;
          out_sys_depth_21 : integer range 0 to 2 := 0;

          num_ports_22 : integer range 1 to 4 := 1;
          data_width_22 : integer range 3 to 256 := 16; 
          registered_io_22 : integer range 0 to 3 := 2;
          in_sys_depth_22 : integer range 0 to 2 := 0;
          out_sys_depth_22 : integer range 0 to 2 := 0;

          num_ports_23 : integer range 1 to 4 := 1;
          data_width_23 : integer range 3 to 256 := 16; 
          registered_io_23 : integer range 0 to 3 := 2;
          in_sys_depth_23 : integer range 0 to 2 := 0;
          out_sys_depth_23 : integer range 0 to 2 := 0;

          num_ports_24 : integer range 1 to 4 := 1;
          data_width_24 : integer range 3 to 256 := 16; 
          registered_io_24 : integer range 0 to 3 := 2;
          in_sys_depth_24 : integer range 0 to 2 := 0;
          out_sys_depth_24 : integer range 0 to 2 := 0;

          num_ports_25 : integer range 1 to 4 := 1;
          data_width_25 : integer range 3 to 256 := 16; 
          registered_io_25 : integer range 0 to 3 := 2;
          in_sys_depth_25 : integer range 0 to 2 := 0;
          out_sys_depth_25 : integer range 0 to 2 := 0;

          num_ports_26 : integer range 1 to 4 := 1;
          data_width_26 : integer range 3 to 256 := 16; 
          registered_io_26 : integer range 0 to 3 := 2;
          in_sys_depth_26 : integer range 0 to 2 := 0;
          out_sys_depth_26 : integer range 0 to 2 := 0;

          num_ports_27 : integer range 1 to 4 := 1;
          data_width_27 : integer range 3 to 256 := 16; 
          registered_io_27 : integer range 0 to 3 := 2;
          in_sys_depth_27 : integer range 0 to 2 := 0;
          out_sys_depth_27 : integer range 0 to 2 := 0;

          num_ports_28 : integer range 1 to 4 := 1;
          data_width_28 : integer range 3 to 256 := 16; 
          registered_io_28 : integer range 0 to 3 := 2;
          in_sys_depth_28 : integer range 0 to 2 := 0;
          out_sys_depth_28 : integer range 0 to 2 := 0;

          num_ports_29 : integer range 1 to 4 := 1;
          data_width_29 : integer range 3 to 256 := 16; 
          registered_io_29 : integer range 0 to 3 := 2;
          in_sys_depth_29 : integer range 0 to 2 := 0;
          out_sys_depth_29 : integer range 0 to 2 := 0;

          num_ports_30 : integer range 1 to 4 := 1;
          data_width_30 : integer range 3 to 256 := 16; 
          registered_io_30 : integer range 0 to 3 := 2;
          in_sys_depth_30 : integer range 0 to 2 := 0;
          out_sys_depth_30 : integer range 0 to 2 := 0;

          num_ports_31 : integer range 1 to 4 := 1;
          data_width_31 : integer range 3 to 256 := 16; 
          registered_io_31 : integer range 0 to 3 := 2;
          in_sys_depth_31 : integer range 0 to 2 := 0;
          out_sys_depth_31 : integer range 0 to 2 := 0;

          num_ports_32 : integer range 1 to 4 := 1;
          data_width_32 : integer range 3 to 256 := 16; 
          registered_io_32 : integer range 0 to 3 := 2;
          in_sys_depth_32 : integer range 0 to 2 := 0;
          out_sys_depth_32 : integer range 0 to 2 := 0;

          num_ports_33 : integer range 1 to 4 := 1;
          data_width_33 : integer range 3 to 256 := 16; 
          registered_io_33 : integer range 0 to 3 := 2;
          in_sys_depth_33 : integer range 0 to 2 := 0;
          out_sys_depth_33 : integer range 0 to 2 := 0;

          num_ports_34 : integer range 1 to 4 := 1;
          data_width_34 : integer range 3 to 256 := 16; 
          registered_io_34 : integer range 0 to 3 := 2;
          in_sys_depth_34 : integer range 0 to 2 := 0;
          out_sys_depth_34 : integer range 0 to 2 := 0;

          num_ports_35 : integer range 1 to 4 := 1;
          data_width_35 : integer range 3 to 256 := 16; 
          registered_io_35 : integer range 0 to 3 := 2;
          in_sys_depth_35 : integer range 0 to 2 := 0;
          out_sys_depth_35 : integer range 0 to 2 := 0;

          num_ports_36 : integer range 1 to 4 := 1;
          data_width_36 : integer range 3 to 256 := 16; 
          registered_io_36 : integer range 0 to 3 := 2;
          in_sys_depth_36 : integer range 0 to 2 := 0;
          out_sys_depth_36 : integer range 0 to 2 := 0;

          num_ports_37 : integer range 1 to 4 := 1;
          data_width_37 : integer range 3 to 256 := 16; 
          registered_io_37 : integer range 0 to 3 := 2;
          in_sys_depth_37 : integer range 0 to 2 := 0;
          out_sys_depth_37 : integer range 0 to 2 := 0;

          num_ports_38 : integer range 1 to 4 := 1;
          data_width_38 : integer range 3 to 256 := 16; 
          registered_io_38 : integer range 0 to 3 := 2;
          in_sys_depth_38 : integer range 0 to 2 := 0;
          out_sys_depth_38 : integer range 0 to 2 := 0;

          num_ports_39 : integer range 1 to 4 := 1;
          data_width_39 : integer range 3 to 256 := 16; 
          registered_io_39 : integer range 0 to 3 := 2;
          in_sys_depth_39 : integer range 0 to 2 := 0;
          out_sys_depth_39 : integer range 0 to 2 := 0;

          num_ports_40 : integer range 1 to 4 := 1;
          data_width_40 : integer range 3 to 256 := 16; 
          registered_io_40 : integer range 0 to 3 := 2;
          in_sys_depth_40 : integer range 0 to 2 := 0;
          out_sys_depth_40 : integer range 0 to 2 := 0;

          num_ports_41 : integer range 1 to 4 := 1;
          data_width_41 : integer range 3 to 256 := 16; 
          registered_io_41 : integer range 0 to 3 := 2;
          in_sys_depth_41 : integer range 0 to 2 := 0;
          out_sys_depth_41 : integer range 0 to 2 := 0;

          num_ports_42 : integer range 1 to 4 := 1;
          data_width_42 : integer range 3 to 256 := 16; 
          registered_io_42 : integer range 0 to 3 := 2;
          in_sys_depth_42 : integer range 0 to 2 := 0;
          out_sys_depth_42 : integer range 0 to 2 := 0;

          num_ports_43 : integer range 1 to 4 := 1;
          data_width_43 : integer range 3 to 256 := 16; 
          registered_io_43 : integer range 0 to 3 := 2;
          in_sys_depth_43 : integer range 0 to 2 := 0;
          out_sys_depth_43 : integer range 0 to 2 := 0;

          num_ports_44 : integer range 1 to 4 := 1;
          data_width_44 : integer range 3 to 256 := 16; 
          registered_io_44 : integer range 0 to 3 := 2;
          in_sys_depth_44 : integer range 0 to 2 := 0;
          out_sys_depth_44 : integer range 0 to 2 := 0;

          num_ports_45 : integer range 1 to 4 := 1;
          data_width_45 : integer range 3 to 256 := 16; 
          registered_io_45 : integer range 0 to 3 := 2;
          in_sys_depth_45 : integer range 0 to 2 := 0;
          out_sys_depth_45 : integer range 0 to 2 := 0;

          num_ports_46 : integer range 1 to 4 := 1;
          data_width_46 : integer range 3 to 256 := 16; 
          registered_io_46 : integer range 0 to 3 := 2;
          in_sys_depth_46 : integer range 0 to 2 := 0;
          out_sys_depth_46 : integer range 0 to 2 := 0;

          num_ports_47 : integer range 1 to 4 := 1;
          data_width_47 : integer range 3 to 256 := 16; 
          registered_io_47 : integer range 0 to 3 := 2;
          in_sys_depth_47 : integer range 0 to 2 := 0;
          out_sys_depth_47 : integer range 0 to 2 := 0;

          num_ports_48 : integer range 1 to 4 := 1;
          data_width_48 : integer range 3 to 256 := 16; 
          registered_io_48 : integer range 0 to 3 := 2;
          in_sys_depth_48 : integer range 0 to 2 := 0;
          out_sys_depth_48 : integer range 0 to 2 := 0;

          num_ports_49 : integer range 1 to 4 := 1;
          data_width_49 : integer range 3 to 256 := 16; 
          registered_io_49 : integer range 0 to 3 := 2;
          in_sys_depth_49 : integer range 0 to 2 := 0;
          out_sys_depth_49 : integer range 0 to 2 := 0;

          num_ports_50 : integer range 1 to 4 := 1;
          data_width_50 : integer range 3 to 256 := 16; 
          registered_io_50 : integer range 0 to 3 := 2;
          in_sys_depth_50 : integer range 0 to 2 := 0;
          out_sys_depth_50 : integer range 0 to 2 := 0;

          num_ports_51 : integer range 1 to 4 := 1;
          data_width_51 : integer range 3 to 256 := 16; 
          registered_io_51 : integer range 0 to 3 := 2;
          in_sys_depth_51 : integer range 0 to 2 := 0;
          out_sys_depth_51 : integer range 0 to 2 := 0;

          num_ports_52 : integer range 1 to 4 := 1;
          data_width_52 : integer range 3 to 256 := 16; 
          registered_io_52 : integer range 0 to 3 := 2;
          in_sys_depth_52 : integer range 0 to 2 := 0;
          out_sys_depth_52 : integer range 0 to 2 := 0;

          num_ports_53 : integer range 1 to 4 := 1;
          data_width_53 : integer range 3 to 256 := 16; 
          registered_io_53 : integer range 0 to 3 := 2;
          in_sys_depth_53 : integer range 0 to 2 := 0;
          out_sys_depth_53 : integer range 0 to 2 := 0;

          num_ports_54 : integer range 1 to 4 := 1;
          data_width_54 : integer range 3 to 256 := 16; 
          registered_io_54 : integer range 0 to 3 := 2;
          in_sys_depth_54 : integer range 0 to 2 := 0;
          out_sys_depth_54 : integer range 0 to 2 := 0;

          num_ports_55 : integer range 1 to 4 := 1;
          data_width_55 : integer range 3 to 256 := 16; 
          registered_io_55 : integer range 0 to 3 := 2;
          in_sys_depth_55 : integer range 0 to 2 := 0;
          out_sys_depth_55 : integer range 0 to 2 := 0;

          num_ports_56 : integer range 1 to 4 := 1;
          data_width_56 : integer range 3 to 256 := 16; 
          registered_io_56 : integer range 0 to 3 := 2;
          in_sys_depth_56 : integer range 0 to 2 := 0;
          out_sys_depth_56 : integer range 0 to 2 := 0;

          num_ports_57 : integer range 1 to 4 := 1;
          data_width_57 : integer range 3 to 256 := 16; 
          registered_io_57 : integer range 0 to 3 := 2;
          in_sys_depth_57 : integer range 0 to 2 := 0;
          out_sys_depth_57 : integer range 0 to 2 := 0;

          num_ports_58 : integer range 1 to 4 := 1;
          data_width_58 : integer range 3 to 256 := 16; 
          registered_io_58 : integer range 0 to 3 := 2;
          in_sys_depth_58 : integer range 0 to 2 := 0;
          out_sys_depth_58 : integer range 0 to 2 := 0;

          num_ports_59 : integer range 1 to 4 := 1;
          data_width_59 : integer range 3 to 256 := 16; 
          registered_io_59 : integer range 0 to 3 := 2;
          in_sys_depth_59 : integer range 0 to 2 := 0;
          out_sys_depth_59 : integer range 0 to 2 := 0;

          num_ports_60 : integer range 1 to 4 := 1;
          data_width_60 : integer range 3 to 256 := 16; 
          registered_io_60 : integer range 0 to 3 := 2;
          in_sys_depth_60 : integer range 0 to 2 := 0;
          out_sys_depth_60 : integer range 0 to 2 := 0;

          num_ports_61 : integer range 1 to 4 := 1;
          data_width_61 : integer range 3 to 256 := 16; 
          registered_io_61 : integer range 0 to 3 := 2;
          in_sys_depth_61 : integer range 0 to 2 := 0;
          out_sys_depth_61 : integer range 0 to 2 := 0;

          num_ports_62 : integer range 1 to 4 := 1;
          data_width_62 : integer range 3 to 256 := 16; 
          registered_io_62 : integer range 0 to 3 := 2;
          in_sys_depth_62 : integer range 0 to 2 := 0;
          out_sys_depth_62 : integer range 0 to 2 := 0;

          num_ports_63 : integer range 1 to 4 := 1;
          data_width_63 : integer range 3 to 256 := 16; 
          registered_io_63 : integer range 0 to 3 := 2;
          in_sys_depth_63 : integer range 0 to 2 := 0;
          out_sys_depth_63 : integer range 0 to 2 := 0;
	  SNPS_IP_SCAN : integer range 0 to 20 := 1

          );

  port (
          bist_clk : in std_logic;
          bist_clk_t : in std_logic;
          rst_n_a : in std_logic;
          rst_t_n_a : in std_logic;
          mbrun : in std_logic;
          mode_reg_in : in std_logic_vector (num_mem+14 downto 0);
          mode_reg_si : in std_logic;
          shift_dr : in std_logic;
          parallel_dr : in std_logic;
          segment_active : in std_logic_vector (num_mem-1 downto 0);
          mem_fail_n : in std_logic_vector (num_mem-1 downto 0);
          mr_ctrl_sel_rst : in std_logic;
          mr_marchlr_rst : in std_logic;
          mr_marchc_rst : in std_logic;
          mr_mats_rst : in std_logic;
          mr_retn_rst : in std_logic;
          mr_debug_mode_rst : in std_logic;
          mr_mem_sel_stat_rst : in std_logic_vector (num_mem-1 downto 0);
          mode_reg_so : out std_logic;
          mode_reg_out : out std_logic_vector (num_mem+14 downto 0);
          atpg_1 : out std_logic;
          bist_mode : out std_logic;
          segment_descr : out std_logic_vector (4 downto 0);
          segment_en : out std_logic_vector (num_mem-1 downto 0);
          port_no : out std_logic_vector (3 downto 0);
          continue_test : out std_logic;
          cont_pause_on_error : out std_logic;
          load_parallel_pattern : out std_logic;
          load_serial_pattern : out std_logic;
          serial_pattern_out : out std_logic
          );

  end component;


  -- Content from file, DW_mbist_memory.vhdpp

  component DW_mbist_memory

  generic (
           addr_width : integer range 3 to 24 := 7;
           data_width : integer range 3 to 256 := 16;
           mem_cs_width_0 : integer range 1 to 256 := 1;
           mem_cs_width_1 : integer range 1 to 256 := 1;
           mem_cs_width_2 : integer range 1 to 256 := 1;
           mem_cs_width_3 : integer range 1 to 256 := 1;
           mem_we_width_0 : integer range 1 to 256 := 1;
           mem_we_width_1 : integer range 1 to 256 := 1;
           mem_we_width_2 : integer range 1 to 256 := 1;
           mem_we_width_3 : integer range 1 to 256 := 1;
           mem_oe_width_0 : integer range 1 to 256 := 1;
           mem_oe_width_1 : integer range 1 to 256 := 1;
           mem_oe_width_2 : integer range 1 to 256 := 1;
           mem_oe_width_3 : integer range 1 to 256 := 1);
  port (
         bist_clk : in std_logic;
         mem_addr_0 : in std_logic_vector(addr_width - 1 downto 0);
         mem_addr_1 : in std_logic_vector(addr_width - 1 downto 0);
         mem_addr_2 : in std_logic_vector(addr_width - 1 downto 0);
         mem_addr_3 : in std_logic_vector(addr_width - 1 downto 0);
         mem_wr_addr_0 : in std_logic_vector(addr_width - 1 downto 0);
         mem_wr_addr_1 : in std_logic_vector(addr_width - 1 downto 0);
         mem_wr_addr_2 : in std_logic_vector(addr_width - 1 downto 0);
         mem_wr_addr_3 : in std_logic_vector(addr_width - 1 downto 0);
         mem_rd_addr_0 : in std_logic_vector(addr_width - 1 downto 0);
         mem_rd_addr_1 : in std_logic_vector(addr_width - 1 downto 0);
         mem_rd_addr_2 : in std_logic_vector(addr_width - 1 downto 0);
         mem_rd_addr_3 : in std_logic_vector(addr_width - 1 downto 0);
         mem_wr_data_0 : in std_logic_vector(data_width - 1 downto 0);
         mem_wr_data_1 : in std_logic_vector(data_width - 1 downto 0);
         mem_wr_data_2 : in std_logic_vector(data_width - 1 downto 0);
         mem_wr_data_3 : in std_logic_vector(data_width - 1 downto 0);
         mem_cs_0 : in std_logic_vector(mem_cs_width_0 - 1 downto 0);
         mem_cs_1 : in std_logic_vector(mem_cs_width_1 - 1 downto 0);
         mem_cs_2 : in std_logic_vector(mem_cs_width_2 - 1 downto 0);
         mem_cs_3 : in std_logic_vector(mem_cs_width_3 - 1 downto 0);
         mem_cs_n_0 : in std_logic_vector(mem_cs_width_0 - 1 downto 0);
         mem_cs_n_1 : in std_logic_vector(mem_cs_width_1 - 1 downto 0);
         mem_cs_n_2 : in std_logic_vector(mem_cs_width_2 - 1 downto 0);
         mem_cs_n_3 : in std_logic_vector(mem_cs_width_3 - 1 downto 0);
         mem_we_0 : in std_logic_vector(mem_we_width_0 - 1 downto 0);
         mem_we_1 : in std_logic_vector(mem_we_width_1 - 1 downto 0);
         mem_we_2 : in std_logic_vector(mem_we_width_2 - 1 downto 0);
         mem_we_3 : in std_logic_vector(mem_we_width_3 - 1 downto 0);
         mem_we_n_0 : in std_logic_vector(mem_we_width_0 - 1 downto 0);
         mem_we_n_1 : in std_logic_vector(mem_we_width_1 - 1 downto 0);
         mem_we_n_2 : in std_logic_vector(mem_we_width_2 - 1 downto 0);
         mem_we_n_3 : in std_logic_vector(mem_we_width_3 - 1 downto 0);
         mem_oe_0 : in std_logic_vector(mem_oe_width_0 - 1 downto 0);
         mem_oe_1 : in std_logic_vector(mem_oe_width_1 - 1 downto 0);
         mem_oe_2 : in std_logic_vector(mem_oe_width_2 - 1 downto 0);
         mem_oe_3 : in std_logic_vector(mem_oe_width_3 - 1 downto 0);
         mem_oe_n_0 : in std_logic_vector(mem_oe_width_0 - 1 downto 0);
         mem_oe_n_1 : in std_logic_vector(mem_oe_width_1 - 1 downto 0);
         mem_oe_n_2 : in std_logic_vector(mem_oe_width_2 - 1 downto 0);
         mem_oe_n_3 : in std_logic_vector(mem_oe_width_3 - 1 downto 0);
         mem_rd_data_0 : out std_logic_vector(data_width - 1 downto 0);
         mem_rd_data_1 : out std_logic_vector(data_width - 1 downto 0);
         mem_rd_data_2 : out std_logic_vector(data_width - 1 downto 0);
         mem_rd_data_3 : out std_logic_vector(data_width - 1 downto 0)
       );

  end component;


  -- Content from file, DW_mbist_mux.vhdpp

  component DW_mbist_mux

  generic (
          addr_width : integer range 3 to 24 := 7;
          data_width : integer range 3 to 256 := 16;
          sep_addr_ports : integer range 0 to 1 := 0;
          num_ports : integer range 1 to 4 := 1;
          shadow_disable : integer range 0 to 1 := 0;
          mem_we_pol_0 : integer range 0 to 1 := 1;
          mem_we_pol_1 : integer range 0 to 1 := 1;
          mem_we_pol_2 : integer range 0 to 1 := 1;
          mem_we_pol_3 : integer range 0 to 1 := 1;
          mem_we_width_0 : integer range 1 to 256 := 1;
          mem_we_width_1 : integer range 1 to 256 := 1;
          mem_we_width_2 : integer range 1 to 256 := 1;
          mem_we_width_3 : integer range 1 to 256 := 1;
          mem_csoe_en_0 : integer range 0 to 3 := 3;
          mem_csoe_en_1 : integer range 0 to 3 := 3;
          mem_csoe_en_2 : integer range 0 to 3 := 3;
          mem_csoe_en_3 : integer range 0 to 3 := 3;
          mem_csoe_pol_0 : integer range 0 to 3 := 3;
          mem_csoe_pol_1 : integer range 0 to 3 := 3;
          mem_csoe_pol_2 : integer range 0 to 3 := 3;
          mem_csoe_pol_3 : integer range 0 to 3 := 3;
          mem_cs_width_0 : integer range 0 to 256 := 1;
          mem_cs_width_1 : integer range 0 to 256 := 1;
          mem_cs_width_2 : integer range 0 to 256 := 1;
          mem_cs_width_3 : integer range 0 to 256 := 1;
          mem_oe_width_0 : integer range 0 to 256 := 1;
          mem_oe_width_1 : integer range 0 to 256 := 1;
          mem_oe_width_2 : integer range 0 to 256 := 1;
          mem_oe_width_3 : integer range 0 to 256 := 1
          );
  port (
         bist_mode : in std_logic;
         dbist_mode : in std_logic;
         bist_in_sel : in std_logic;
         bist_cs_n_0 : in std_logic;
         bist_cs_n_1 : in std_logic;
         bist_cs_n_2 : in std_logic;
         bist_cs_n_3 : in std_logic;
         bist_oe_n_0 : in std_logic;
         bist_oe_n_1 : in std_logic;
         bist_oe_n_2 : in std_logic;
         bist_oe_n_3 : in std_logic;
         bist_we_n_0 : in std_logic;
         bist_we_n_1 : in std_logic;
         bist_we_n_2 : in std_logic;
         bist_we_n_3 : in std_logic;
         bist_addr_0 : in std_logic_vector(addr_width - 1 downto 0);
         bist_addr_1 : in std_logic_vector(addr_width - 1 downto 0);
         bist_addr_2 : in std_logic_vector(addr_width - 1 downto 0);
         bist_addr_3 : in std_logic_vector(addr_width - 1 downto 0);
         bist_wr_data_0 : in std_logic_vector(data_width - 1 downto 0);
         bist_wr_data_1 : in std_logic_vector(data_width - 1 downto 0);
         bist_wr_data_2 : in std_logic_vector(data_width - 1 downto 0);
         bist_wr_data_3 : in std_logic_vector(data_width - 1 downto 0);
         sys_rd_wr_addr_0 : in std_logic_vector(addr_width - 1 downto 0); 
         sys_rd_wr_addr_1 : in std_logic_vector(addr_width - 1 downto 0); 
         sys_rd_wr_addr_2 : in std_logic_vector(addr_width - 1 downto 0); 
         sys_rd_wr_addr_3 : in std_logic_vector(addr_width - 1 downto 0); 
         sys_wr_addr_0 : in std_logic_vector(addr_width - 1 downto 0); 
         sys_wr_addr_1 : in std_logic_vector(addr_width - 1 downto 0); 
         sys_wr_addr_2 : in std_logic_vector(addr_width - 1 downto 0); 
         sys_wr_addr_3 : in std_logic_vector(addr_width - 1 downto 0); 
         sys_rd_addr_0 : in std_logic_vector(addr_width - 1 downto 0); 
         sys_rd_addr_1 : in std_logic_vector(addr_width - 1 downto 0); 
         sys_rd_addr_2 : in std_logic_vector(addr_width - 1 downto 0); 
         sys_rd_addr_3 : in std_logic_vector(addr_width - 1 downto 0); 
         sys_wr_data_0 : in std_logic_vector(data_width - 1 downto 0);
         sys_wr_data_1 : in std_logic_vector(data_width - 1 downto 0);
         sys_wr_data_2 : in std_logic_vector(data_width - 1 downto 0);
         sys_wr_data_3 : in std_logic_vector(data_width - 1 downto 0);
         sys_cs_0 : in std_logic_vector(mem_cs_width_0 - 1 downto 0);
         sys_cs_1 : in std_logic_vector(mem_cs_width_1 - 1 downto 0);
         sys_cs_2 : in std_logic_vector(mem_cs_width_2 - 1 downto 0);
         sys_cs_3 : in std_logic_vector(mem_cs_width_3 - 1 downto 0);
         sys_cs_n_0 : in std_logic_vector(mem_cs_width_0 - 1 downto 0);
         sys_cs_n_1 : in std_logic_vector(mem_cs_width_1 - 1 downto 0);
         sys_cs_n_2 : in std_logic_vector(mem_cs_width_2 - 1 downto 0);
         sys_cs_n_3 : in std_logic_vector(mem_cs_width_3 - 1 downto 0);
         sys_we_0 : in std_logic_vector(mem_we_width_0 - 1 downto 0);
         sys_we_1 : in std_logic_vector(mem_we_width_1 - 1 downto 0);
         sys_we_2 : in std_logic_vector(mem_we_width_2 - 1 downto 0);
         sys_we_3 : in std_logic_vector(mem_we_width_3 - 1 downto 0);
         sys_we_n_0 : in std_logic_vector(mem_we_width_0 - 1 downto 0);
         sys_we_n_1 : in std_logic_vector(mem_we_width_1 - 1 downto 0);
         sys_we_n_2 : in std_logic_vector(mem_we_width_2 - 1 downto 0);
         sys_we_n_3 : in std_logic_vector(mem_we_width_3 - 1 downto 0);
         sys_oe_0 : in std_logic_vector(mem_oe_width_0 - 1 downto 0);
         sys_oe_1 : in std_logic_vector(mem_oe_width_1 - 1 downto 0);
         sys_oe_2 : in std_logic_vector(mem_oe_width_2 - 1 downto 0);
         sys_oe_3 : in std_logic_vector(mem_oe_width_3 - 1 downto 0);
         sys_oe_n_0 : in std_logic_vector(mem_oe_width_0 - 1 downto 0);
         sys_oe_n_1 : in std_logic_vector(mem_oe_width_1 - 1 downto 0);
         sys_oe_n_2 : in std_logic_vector(mem_oe_width_2 - 1 downto 0);
         sys_oe_n_3 : in std_logic_vector(mem_oe_width_3 - 1 downto 0);
         mem_rd_data_0 : in std_logic_vector(data_width - 1 downto 0);
         mem_rd_data_1 : in std_logic_vector(data_width - 1 downto 0);
         mem_rd_data_2 : in std_logic_vector(data_width - 1 downto 0);
         mem_rd_data_3 : in std_logic_vector(data_width - 1 downto 0);
         sys_rd_data_0 : out std_logic_vector(data_width - 1 downto 0);
         sys_rd_data_1 : out std_logic_vector(data_width - 1 downto 0);
         sys_rd_data_2 : out std_logic_vector(data_width - 1 downto 0);
         sys_rd_data_3 : out std_logic_vector(data_width - 1 downto 0);
         bist_rd_data_0 : out std_logic_vector(data_width - 1 downto 0);
         bist_rd_data_1 : out std_logic_vector(data_width - 1 downto 0);
         bist_rd_data_2 : out std_logic_vector(data_width - 1 downto 0);
         bist_rd_data_3 : out std_logic_vector(data_width - 1 downto 0);
         mem_cs_n_0     : out std_logic_vector(mem_cs_width_0 - 1 downto 0);
         mem_cs_n_1     : out std_logic_vector(mem_cs_width_1 - 1 downto 0);
         mem_cs_n_2     : out std_logic_vector(mem_cs_width_2 - 1 downto 0);
         mem_cs_n_3     : out std_logic_vector(mem_cs_width_3 - 1 downto 0);
         mem_oe_n_0     : out std_logic_vector(mem_oe_width_0 - 1 downto 0);
         mem_oe_n_1     : out std_logic_vector(mem_oe_width_1 - 1 downto 0);
         mem_oe_n_2     : out std_logic_vector(mem_oe_width_2 - 1 downto 0);
         mem_oe_n_3     : out std_logic_vector(mem_oe_width_3 - 1 downto 0);
         mem_we_n_0     : out std_logic_vector(mem_we_width_0 - 1 downto 0);
         mem_we_n_1     : out std_logic_vector(mem_we_width_1 - 1 downto 0);
         mem_we_n_2     : out std_logic_vector(mem_we_width_2 - 1 downto 0);
         mem_we_n_3     : out std_logic_vector(mem_we_width_3 - 1 downto 0);
         mem_cs_0     : out std_logic_vector(mem_cs_width_0 - 1 downto 0);
         mem_cs_1     : out std_logic_vector(mem_cs_width_1 - 1 downto 0);
         mem_cs_2     : out std_logic_vector(mem_cs_width_2 - 1 downto 0);
         mem_cs_3     : out std_logic_vector(mem_cs_width_3 - 1 downto 0);
         mem_oe_0     : out std_logic_vector(mem_oe_width_0 - 1 downto 0);
         mem_oe_1     : out std_logic_vector(mem_oe_width_1 - 1 downto 0);
         mem_oe_2     : out std_logic_vector(mem_oe_width_2 - 1 downto 0);
         mem_oe_3     : out std_logic_vector(mem_oe_width_3 - 1 downto 0);
         mem_we_0     : out std_logic_vector(mem_we_width_0 - 1 downto 0);
         mem_we_1     : out std_logic_vector(mem_we_width_1 - 1 downto 0);
         mem_we_2     : out std_logic_vector(mem_we_width_2 - 1 downto 0);
         mem_we_3     : out std_logic_vector(mem_we_width_3 - 1 downto 0);
         mem_wr_addr_0 : out std_logic_vector(addr_width - 1 downto 0);
         mem_wr_addr_1 : out std_logic_vector(addr_width - 1 downto 0);
         mem_wr_addr_2 : out std_logic_vector(addr_width - 1 downto 0);
         mem_wr_addr_3 : out std_logic_vector(addr_width - 1 downto 0);
         mem_rd_addr_0 : out std_logic_vector(addr_width - 1 downto 0);
         mem_rd_addr_1 : out std_logic_vector(addr_width - 1 downto 0);
         mem_rd_addr_2 : out std_logic_vector(addr_width - 1 downto 0);
         mem_rd_addr_3 : out std_logic_vector(addr_width - 1 downto 0);
         mem_addr_0 : out std_logic_vector(addr_width - 1 downto 0);
         mem_addr_1 : out std_logic_vector(addr_width - 1 downto 0);
         mem_addr_2 : out std_logic_vector(addr_width - 1 downto 0);
         mem_addr_3 : out std_logic_vector(addr_width - 1 downto 0);
         mem_wr_data_0 : out std_logic_vector(data_width - 1 downto 0);
         mem_wr_data_1 : out std_logic_vector(data_width - 1 downto 0);
         mem_wr_data_2 : out std_logic_vector(data_width - 1 downto 0);
         mem_wr_data_3 : out std_logic_vector(data_width - 1 downto 0);

         cap_mem_addr_0 : out std_logic_vector(addr_width - 1 downto 0);
         cap_mem_addr_1 : out std_logic_vector(addr_width - 1 downto 0);
         cap_mem_addr_2 : out std_logic_vector(addr_width - 1 downto 0);
         cap_mem_addr_3 : out std_logic_vector(addr_width - 1 downto 0);
         cap_mem_wr_addr_0 : out std_logic_vector(addr_width - 1 downto 0);
         cap_mem_wr_addr_1 : out std_logic_vector(addr_width - 1 downto 0);
         cap_mem_wr_addr_2 : out std_logic_vector(addr_width - 1 downto 0);
         cap_mem_wr_addr_3 : out std_logic_vector(addr_width - 1 downto 0);
         cap_mem_rd_addr_0 : out std_logic_vector(addr_width - 1 downto 0);
         cap_mem_rd_addr_1 : out std_logic_vector(addr_width - 1 downto 0);
         cap_mem_rd_addr_2 : out std_logic_vector(addr_width - 1 downto 0);
         cap_mem_rd_addr_3 : out std_logic_vector(addr_width - 1 downto 0);
         cap_mem_wr_data_0 : out std_logic_vector(data_width - 1 downto 0);
         cap_mem_wr_data_1 : out std_logic_vector(data_width - 1 downto 0);
         cap_mem_wr_data_2 : out std_logic_vector(data_width - 1 downto 0);
         cap_mem_wr_data_3 : out std_logic_vector(data_width - 1 downto 0);
         cap_mem_cs_0 : out std_logic_vector(mem_cs_width_0 - 1 downto 0);
         cap_mem_cs_1 : out std_logic_vector(mem_cs_width_1 - 1 downto 0);
         cap_mem_cs_2 : out std_logic_vector(mem_cs_width_2 - 1 downto 0);
         cap_mem_cs_3 : out std_logic_vector(mem_cs_width_3 - 1 downto 0);
         cap_mem_we_0 : out std_logic_vector(mem_we_width_0 - 1 downto 0);
         cap_mem_we_1 : out std_logic_vector(mem_we_width_1 - 1 downto 0);
         cap_mem_we_2 : out std_logic_vector(mem_we_width_2 - 1 downto 0);
         cap_mem_we_3 : out std_logic_vector(mem_we_width_3 - 1 downto 0);
         cap_mem_oe_0 : out std_logic_vector(mem_oe_width_0 - 1 downto 0);
         cap_mem_oe_1 : out std_logic_vector(mem_oe_width_1 - 1 downto 0);
         cap_mem_oe_2 : out std_logic_vector(mem_oe_width_2 - 1 downto 0);
         cap_mem_oe_3 : out std_logic_vector(mem_oe_width_3 - 1 downto 0)
       );
  end component;


  -- Content from file, DW_mbist_wrapper.vhdpp

  component DW_mbist_wrapper

  generic (
          addr_width : integer range 3 to 24 := 7;
          data_width : integer range 3 to 256 := 16;
          sep_addr_ports : integer range 0 to 1 := 0;
          num_ports : integer range 1 to 4 := 1;
          memory_full : integer range 0 to 1 := 1;
          registered_io : integer range 0 to 3 := 2;
          in_sys_depth : integer range 0 to 2 := 0;
          out_sys_depth : integer range 0 to 2 := 0;
          mem_start_addr : integer range 0 to 16777215 := 0;
          mem_end_addr : integer range 7 to 16777215 := 32768;
          shadow_disable : integer range 0 to 1 := 1;
          custom_pattern_en : integer range 0 to 1 := 0;
          remove_debug_out_port : integer range 0 to 1 := 1;
          disable_pause_on_error : integer range 0 to 1 := 0;
          mem_we_pol_0 : integer range 0 to 1 := 1;
          mem_we_pol_1 : integer range 0 to 1 := 1;
          mem_we_pol_2 : integer range 0 to 1 := 1;
          mem_we_pol_3 : integer range 0 to 1 := 1;
          mem_we_width_0 : integer range 1 to 256 := 1;
          mem_we_width_1 : integer range 1 to 256 := 1;
          mem_we_width_2 : integer range 1 to 256 := 1;
          mem_we_width_3 : integer range 1 to 256 := 1;
          mem_csoe_en_0 : integer range 0 to 3 := 3;
          mem_csoe_en_1 : integer range 0 to 3 := 3;
          mem_csoe_en_2 : integer range 0 to 3 := 3;
          mem_csoe_en_3 : integer range 0 to 3 := 3;
          mem_csoe_pol_0 : integer range 0 to 3 := 3;
          mem_csoe_pol_1 : integer range 0 to 3 := 3;
          mem_csoe_pol_2 : integer range 0 to 3 := 3;
          mem_csoe_pol_3 : integer range 0 to 3 := 3;
          mem_cs_width_0 : integer range 0 to 256 := 1;
          mem_cs_width_1 : integer range 0 to 256 := 1;
          mem_cs_width_2 : integer range 0 to 256 := 1;
          mem_cs_width_3 : integer range 0 to 256 := 1;
          mem_oe_width_0 : integer range 0 to 256 := 1;
          mem_oe_width_1 : integer range 0 to 256 := 1;
          mem_oe_width_2 : integer range 0 to 256 := 1;
          mem_oe_width_3 : integer range 0 to 256 := 1;
	  SNPS_IP_SCAN : integer range 0 to 20 := 1
          );
  port (
         bist_clk : in std_logic;
         bist_clk_t : in std_logic;
         rst_n_a : in std_logic;
         rst_t_n_a : in std_logic;
         simulation_mode : in std_logic;
         bist_mode : in std_logic;
         dbist_mode : in std_logic;
         port_no : in std_logic_vector(3 downto 0);
         atpg_1 : in std_logic;
         load_parallel_pattern : in std_logic;
         load_serial_pattern : in std_logic;
         serial_pattern_out : in std_logic;
         segment_descr : in std_logic_vector(4 downto 0);
         segment_en : in std_logic;
         continue_test : in std_logic;
         cont_pause_on_error : in std_logic;
         debug_en : in std_logic;
         debug_si : in std_logic;
         sys_rd_wr_addr_0 : in std_logic_vector(addr_width - 1 downto 0); 
         sys_rd_wr_addr_1 : in std_logic_vector(addr_width - 1 downto 0); 
         sys_rd_wr_addr_2 : in std_logic_vector(addr_width - 1 downto 0); 
         sys_rd_wr_addr_3 : in std_logic_vector(addr_width - 1 downto 0); 
         sys_wr_addr_0 : in std_logic_vector(addr_width - 1 downto 0); 
         sys_wr_addr_1 : in std_logic_vector(addr_width - 1 downto 0); 
         sys_wr_addr_2 : in std_logic_vector(addr_width - 1 downto 0); 
         sys_wr_addr_3 : in std_logic_vector(addr_width - 1 downto 0); 
         sys_rd_addr_0 : in std_logic_vector(addr_width - 1 downto 0); 
         sys_rd_addr_1 : in std_logic_vector(addr_width - 1 downto 0); 
         sys_rd_addr_2 : in std_logic_vector(addr_width - 1 downto 0); 
         sys_rd_addr_3 : in std_logic_vector(addr_width - 1 downto 0); 
         sys_wr_data_0 : in std_logic_vector(data_width - 1 downto 0);
         sys_wr_data_1 : in std_logic_vector(data_width - 1 downto 0);
         sys_wr_data_2 : in std_logic_vector(data_width - 1 downto 0);
         sys_wr_data_3 : in std_logic_vector(data_width - 1 downto 0);
         sys_cs_0 : in std_logic_vector(mem_cs_width_0 - 1 downto 0);
         sys_cs_1 : in std_logic_vector(mem_cs_width_1 - 1 downto 0);
         sys_cs_2 : in std_logic_vector(mem_cs_width_2 - 1 downto 0);
         sys_cs_3 : in std_logic_vector(mem_cs_width_3 - 1 downto 0);
         sys_cs_n_0 : in std_logic_vector(mem_cs_width_0 - 1 downto 0);
         sys_cs_n_1 : in std_logic_vector(mem_cs_width_1 - 1 downto 0);
         sys_cs_n_2 : in std_logic_vector(mem_cs_width_2 - 1 downto 0);
         sys_cs_n_3 : in std_logic_vector(mem_cs_width_3 - 1 downto 0);
         sys_we_0 : in std_logic_vector(mem_we_width_0 - 1 downto 0);
         sys_we_1 : in std_logic_vector(mem_we_width_1 - 1 downto 0);
         sys_we_2 : in std_logic_vector(mem_we_width_2 - 1 downto 0);
         sys_we_3 : in std_logic_vector(mem_we_width_3 - 1 downto 0);
         sys_we_n_0 : in std_logic_vector(mem_we_width_0 - 1 downto 0);
         sys_we_n_1 : in std_logic_vector(mem_we_width_1 - 1 downto 0);
         sys_we_n_2 : in std_logic_vector(mem_we_width_2 - 1 downto 0);
         sys_we_n_3 : in std_logic_vector(mem_we_width_3 - 1 downto 0);
         sys_oe_0 : in std_logic_vector(mem_oe_width_0 - 1 downto 0);
         sys_oe_1 : in std_logic_vector(mem_oe_width_1 - 1 downto 0);
         sys_oe_2 : in std_logic_vector(mem_oe_width_2 - 1 downto 0);
         sys_oe_3 : in std_logic_vector(mem_oe_width_3 - 1 downto 0);
         sys_oe_n_0 : in std_logic_vector(mem_oe_width_0 - 1 downto 0);
         sys_oe_n_1 : in std_logic_vector(mem_oe_width_1 - 1 downto 0);
         sys_oe_n_2 : in std_logic_vector(mem_oe_width_2 - 1 downto 0);
         sys_oe_n_3 : in std_logic_vector(mem_oe_width_3 - 1 downto 0);
         custom_pattern : in std_logic_vector(data_width - 1 downto 0);
         sys_rd_data_0 : out std_logic_vector(data_width - 1 downto 0);
         sys_rd_data_1 : out std_logic_vector(data_width - 1 downto 0);
         sys_rd_data_2 : out std_logic_vector(data_width - 1 downto 0);
         sys_rd_data_3 : out std_logic_vector(data_width - 1 downto 0);
         mem_fail_n : out std_logic;
         debug_out : out std_logic_vector(data_width - 1 downto 0);
         debug_so : out std_logic;
         segment_active : out std_logic;
         cap_mem_cs_0_nc : out std_logic_vector(mem_cs_width_0 - 1 downto 0);
         cap_mem_cs_1_nc : out std_logic_vector(mem_cs_width_1 - 1 downto 0);
         cap_mem_cs_2_nc : out std_logic_vector(mem_cs_width_2 - 1 downto 0);
         cap_mem_cs_3_nc : out std_logic_vector(mem_cs_width_3 - 1 downto 0);
         cap_mem_oe_0_nc : out std_logic_vector(mem_oe_width_0 - 1 downto 0);
         cap_mem_oe_1_nc : out std_logic_vector(mem_oe_width_1 - 1 downto 0);
         cap_mem_oe_2_nc : out std_logic_vector(mem_oe_width_2 - 1 downto 0);
         cap_mem_oe_3_nc : out std_logic_vector(mem_oe_width_3 - 1 downto 0);
         cap_mem_we_0_nc : out std_logic_vector(mem_we_width_0 - 1 downto 0);
         cap_mem_we_1_nc : out std_logic_vector(mem_we_width_1 - 1 downto 0);
         cap_mem_we_2_nc : out std_logic_vector(mem_we_width_2 - 1 downto 0);
         cap_mem_we_3_nc : out std_logic_vector(mem_we_width_3 - 1 downto 0)
       );
  end component;


  -- Content from file, DFT_bistc.vhdpp

  component DFT_bistc

  generic (
          autodbist : INTEGER := 0;
          reseed : INTEGER := 0;
          diag_output : INTEGER := 1;
          pipeline_se : INTEGER := 0;
          invert_prpg_clk : INTEGER := 0;
          clock_misr_during_capture : INTEGER := 1;
          pattern_ctr_width : INTEGER := 1;
          cycle_ctr_width : INTEGER := 1;
          loadable_shift_ctr : INTEGER := 0;
          sh_width   : INTEGER := 5;
          sh_count_to : INTEGER := 22;
	  width      : INTEGER := 11;
	  count_to   : INTEGER := 2047
	  );

  port (
	  bist_clk, bist_reset, bist_mode, auto_mode : in std_logic;
          bist_run : in std_logic;
          bist_diag : in std_logic;
          fast_clock_enable : out std_logic;
          diag_data_valid : out std_logic;
	  lfsr_se : in std_logic;
	  reuse_seed : in std_logic;
	  top_se : in std_logic;
	  core_se, core_se_i : out std_logic;
	  bist_bypass : in std_logic;
          bist_se : in std_logic;
	  bist_si : in std_logic;
          pattern_ctr_data : in std_logic_vector(pattern_ctr_width-1 downto 0);
          cycle_ctr_data : in std_logic_vector(cycle_ctr_width-1 downto 0);
          bist_done : out std_logic;
	  bist_so : out std_logic;
          reuse_seed_gated : out std_logic;
          prpg_clk : out std_logic;
          misr_clk : out std_logic;
          misr_scb : out std_logic_vector (3 downto 0)
	);
  end component;


  -- Content from file, DFT_codec.vhdpp

  component DFT_codec

  generic (
          autodbist : INTEGER := 0;
          codec_count: INTEGER := 1;
          prpg_length: INTEGER := 479;
          chain_count: INTEGER := 512;
          negedge_chains : INTEGER := 0;
          lockup_latch : INTEGER := 11;
          compact_type : INTEGER := 1;
          diag_output : INTEGER := 1;
          x_out_count : INTEGER := 16;
          shadow_width : INTEGER := 12;
          xshadow_width : INTEGER := 4;
          xshadow_int : INTEGER := 1;
          tri_state_mux : INTEGER := 1;
          gen_bist_fail : INTEGER := 0
	  );

  port (
	  bist_reset, bist_mode, auto_mode, bist_diag : in std_logic;

          fast_clock_enable : out std_logic;
          diag_data_valid : out std_logic;
	  lfsr_se : in std_logic;
          lfsr_si : in std_logic_vector(codec_count-1 downto 0);
	  lfsr_so : out std_logic_vector((codec_count * diag_output)-1 downto 0);
	  shadow_si : in std_logic_vector((codec_count * shadow_width)-1 downto 0);
	  shadow_so : out std_logic_vector(codec_count-1 downto 0);
	  core_si : out std_logic_vector((codec_count * chain_count)-1 downto 0);
	  core_so : in std_logic_vector((codec_count * chain_count)-1 downto 0);
	  bist_bypass : in std_logic;
          reuse_seed_gated : in std_logic;
          prpg_clk : in std_logic;
          misr_clk : in std_logic;
          misr_scb : in std_logic_vector (3 downto 0);
          bist_fail: out std_logic
	);
  end component;


  -- Content from file, DFT_shadow.vhdpp

  component DFT_shadow
  generic (prpg_length: INTEGER := 479;
           shadow_width: INTEGER := 12);
        
  port (bist_ck, bist_mode : in std_logic;
        shadow_si : in std_logic_vector((shadow_width-1) downto 0);
        lfsrin : out std_logic_vector((prpg_length-1) downto 0);
        shadow_chain_so : out std_logic;
        ctrl_shadow_se : in std_logic;
        ctrl_shadow_in : in std_logic
);
  end component;


  -- Content from file, DFT_sign.vhdpp

  component DFT_sign
  generic ( chain_count : INTEGER := 512;
            compact_type : INTEGER := 1;
            gen_bist_fail : INTEGER := 0);
  port (
       misr_reset, bist_ck, bist_mode, bist_bypass,
       diag_mode, misr_si, misr_scan : in std_logic;
       misr_scb : in std_logic_vector(3 downto 0);
       misr_in : in std_logic_vector((chain_count-1) downto 0);
       diag_si : in std_logic_vector(15 downto 0);
       bist_fail : out std_logic;
       misr_so : out std_logic_vector(15 downto 0)
  );
  end component;


  -- Content from file, DFT_xbistc.vhdpp

  component DFT_xbistc

  generic (
          autodbist : INTEGER := 0;
          reseed  : INTEGER := 0;
          diag_output : INTEGER := 1;
          pipeline_se : INTEGER := 0;
          invert_prpg_clk : INTEGER := 0;
          clock_misr_during_capture : INTEGER := 1;
          loadable_shift_ctr : INTEGER := 0;
          sh_width   : INTEGER := 5;
          sh_count_to : INTEGER := 22;
	  width      : INTEGER := 11;
	  count_to   : INTEGER := 2047
	  );

  port (
	  bist_clk, bist_reset, bist_mode : in std_logic;
          fast_clock_enable : out std_logic;
          lfsr_se : in std_logic;
          reuse_seed : in std_logic;
	  top_se : in std_logic;
	  core_se, core_se_i : out std_logic;
	  bist_bypass : in std_logic;
          bist_se : in std_logic;
	  bist_si : in std_logic;
	  bist_so : out std_logic;
          reuse_seed_gated : out std_logic
	);
  end component;


  -- Content from file, DFT_xcodec.vhdpp

  component DFT_xcodec

  generic (
          autodbist : INTEGER := 0;
          codec_count: INTEGER := 1;
          prpg_length: INTEGER := 479;
          chain_count: INTEGER := 512;
          negedge_chains : INTEGER := 0;
          lockup_latch : INTEGER := 11;
          compact_type : INTEGER := 1;
          diag_output : INTEGER := 1;
          x_out_count : INTEGER := 16;
          shadow_width: INTEGER := 12;
          xshadow_width: INTEGER := 4;
          xshadow_int : INTEGER := 1;
          tri_state_mux : INTEGER := 1;
          sel_loop  : INTEGER := 1;
          sel_count : INTEGER := 16;
          sel_mask1 : INTEGER := 0;
          sel_mask2 : INTEGER := 0;
          sel_mask3 : INTEGER := 0;
          sel_mask4 : INTEGER := 0
	  );

  port (
	  bist_clk, bist_mode : in std_logic;
          fast_clock_enable : out std_logic;
	  lfsr_se : in std_logic;
          lfsr_si : in std_logic_vector(codec_count-1 downto 0);
	  lfsr_so : out std_logic_vector(codec_count-1 downto 0);
	  shadow_si : in std_logic_vector((codec_count * shadow_width)-1 downto 0);
	  shadow_so : out std_logic_vector(codec_count-1 downto 0);
	  x_shadow_si : in std_logic_vector((codec_count * xshadow_width)-1 downto 0);
	  x_shadow_so : out std_logic_vector(codec_count-1 downto 0);
          x_so : out std_logic_vector((codec_count * x_out_count)-1 downto 0);
	  core_si : out std_logic_vector((codec_count * chain_count)-1 downto 0);
	  core_so : in std_logic_vector((codec_count * chain_count)-1 downto 0);
	  bist_bypass : in std_logic;
          reuse_seed_gated : in std_logic
	);
  end component;


  -- Content from file, DFT_tap.vhdpp

  component DFT_tap
  generic(
    width         : INTEGER range 2 to 256;
    id            : INTEGER range 0 to 1          := 0;
    idcode_opcode : INTEGER  := 1;
    version       : INTEGER range 0 to 15         := 0;
    part          : INTEGER range 0 to 65535      := 0;
    man_num       : INTEGER range 0 to 2047       := 0;
    sync_mode     : INTEGER range 0 to 1          := 0;
    fsm_width     : INTEGER range 4 to 16         := 16);

  port (
    tck             : in  std_logic;
    trst_n          : in  std_logic;
    tms             : in  std_logic;
    tdi             : in  std_logic;
    so              : in  std_logic;
    bypass_sel      : in  std_logic;
    sentinel_val    : in  std_logic_vector(width-2 downto 0);
    
    device_id_sel   : in  std_logic;
    user_code_sel   : in  std_logic;
    user_code_val   : in  std_logic_vector(31 downto 0);
  
    ver             : in  std_logic_vector(3 downto 0);
    ver_sel         : in  std_logic;
    part_num        : in  std_logic_vector(15 downto 0);
    part_num_sel    : in  std_logic;
    mnfr_id         : in  std_logic_vector(10 downto 0);
    mnfr_id_sel     : in  std_logic;
      
    clock_dr        : out std_logic;
    shift_dr        : out std_logic;
    update_dr       : out std_logic;
    tdo             : out std_logic;
    tdo_en          : out std_logic;
    tap_state       : out std_logic_vector(15 downto 0);
    instructions    : out std_logic_vector(width-1 downto 0);
    sync_capture_en : out std_logic;
    sync_update_dr  : out std_logic;
    reset_out       : out std_logic);
    
  end component;


  -- Content from file, DFT_BYPASS.vhdpp

  component DFT_BYPASS

  port (capture_clk : in  std_logic;    -- =tck for sync, =clock_dr for async
         capture_en : in  std_logic;    -- =clock_dr for sync, =1 for async
         shift_dr   : in  std_logic;    -- =shift_dr from TAP
         capture_dr : in  std_logic;    -- =capture_dr from TAP
         tdi        : in  std_logic;    -- serial data path input
         so         : out std_logic);   -- serial data path output
  end component;


  -- Content from file, DFT_IDREG.vhdpp

  component DFT_IDREG

  generic (version : integer range 0 to 15    := 0;
           part    : integer range 0 to 65535 := 0;
           man_num : integer range 0 to 2047  := 0);
  port (capture_clk : in  std_logic;    -- =tck for sync, =clock_ir for async
         capture_en : in  std_logic;    -- =clock_ir for sync, =0 for async
         shift_dr   : in  std_logic;    -- =shift_dr from TAP
         si         : in  std_logic;    -- serial data path input
         so         : out std_logic);   -- serial data path output
  end component;


  -- Content from file, DFT_IDREGUC.vhdpp

  component DFT_IDREGUC
  generic (
    version : integer range 0 to 15    := 0;
    part    : integer range 0 to 65535 := 0;
    man_num : integer range 0 to 2047  := 0);
  port (
    capture_clk : in std_logic;         -- =tck for sync, =clock_ir for async
    capture_en  : in std_logic;         -- =clock_ir for sync, =0 for async
    shift_dr    : in std_logic;         -- =shift_dr from TAP
    si          : in std_logic;         -- serial data path input
    user_code_sel   : in  std_logic;
    user_code_val   : in  std_logic_vector(31 downto 0);
    
    ver          : in std_logic_vector(3 downto 0);
    ver_sel      : in std_logic;
    part_num     : in std_logic_vector(15 downto 0);
    part_num_sel : in std_logic;
    mnfr_id      : in std_logic_vector(10 downto 0);
    mnfr_id_sel  : in std_logic;
    so : out std_logic);                -- serial data path output
  end component;


  -- Content from file, DFT_INSTRREG.vhdpp

  component DFT_INSTRREG

  generic (width : integer range 1 to 256 := 4);
  port (capture_clk       : in  std_logic;  -- =tck for sync, =clock_ir for async
         update_clk       : in  std_logic;  -- =tck for sync, =update_ir for async
         test_logic_rst   : in  std_logic;  -- test_logic_reset state
         capture_en       : in  std_logic;  -- =clock_ir for sync, =0 for async
         update_en        : in  std_logic;  -- =update_ir for sync, =1 for async
         shift_ir         : in  std_logic;  -- =shift_dr from TAP
         si               : in  std_logic;  -- serial data path input
         init_instr_value : in  std_logic_vector(width-1 downto 0);
         sentinel_val     : in  std_logic_vector(width-1 downto 0);
         instruction_out  : out std_logic_vector(width-1 downto 0);
         so               : out std_logic);  -- serial data path output
  end component;


  -- Content from file, DFT_INSTRREGID.vhdpp

  component DFT_INSTRREGID

  generic
    (width         : integer range 2 to 32 := 4;
     id            : integer range 0 to 1  := 1;
     idcode_opcode : integer               := 1);
  port
    ( capture_clk     : in  std_logic;  -- =tck for sync, clock_ir for async
      update_clk      : in  std_logic;  -- =tck for sync, update_ir for async
      
      test_logic_rst  : in  std_logic;  -- test_logic_reset state
      capture_en      : in  std_logic;  -- =clock_ir for sync, =0 for async
      update_en       : in  std_logic;  -- =update_ir for sync, =1 for async
      shift_ir        : in  std_logic;  -- =shift_dr from TAP
      si              : in  std_logic;  -- serial data path input
      sentinel_val    : in  std_logic_vector(width-2 downto 0);
      
      instruction_out : out std_logic_vector(width-1 downto 0);
      so              : out std_logic);  -- serial data path output
  end component;


  -- Content from file, DFT_TAPFSM.vhdpp

  component DFT_TAPFSM

  
  generic(
    sync_mode : integer range 0 to 1  := 0;
    fsm_width : integer range 4 to 16 := 16);  
  port (
    tck       : in  std_logic;
    trst_n    : in  std_logic;
    tms       : in  std_logic;
    clock_dr  : out std_logic;
    dr_sel    : out std_logic;
    clock_ir  : out std_logic;
    shift_dr  : out std_logic;
    shift_ir  : out std_logic;
    update_dr : out std_logic;
    update_ir : out std_logic;
    instr_rst : out std_logic;
    state     : out std_logic_vector(15 downto 0));
  end component;


  -- Content from file, DFT_ac_1.vhdpp

  component DFT_ac_1
    port ( capture_clk : in std_logic; -- =tck for sync, =clock_dr for async
	   update_clk  : in std_logic; -- =tck for sync, =update_dr for async
	   capture_en  : in std_logic; -- =clock_dr for sync, =0 for async
	   update_en   : in std_logic; -- =update_dr for sync, =1 for async
	   shift_dr    : in std_logic; -- =shift_dr from TAP
	   mode        : in std_logic; 
	   si          : in std_logic; -- serial data path input
	   ac_mode     : in std_logic; -- hysteric mem set
	   ac_test     : in std_logic; -- hysteric mem reset
	   data_in     : in std_logic; 
	   data_out    : out std_logic;  
	   so          : out std_logic); -- serial data path output
  end component;


  -- Content from file, DFT_ac_10.vhdpp

  component DFT_ac_10
  port (
    capture_clk : in  std_logic;      -- =tck for sync, =clock_dr for async
    update_clk  : in  std_logic;      -- =tck for sync, =update_dr for async
    
    capture_en  : in  std_logic;      -- =clock_dr for sync, =0 for async
    update_en   : in  std_logic;      -- =update_dr for sync, =1 for async
    shift_dr    : in  std_logic;      -- =shift_dr from TAP
    mode        : in  std_logic;
    
    si          : in  std_logic;      -- serial data path input
    pin_input   : in  std_logic;      -- connected to IC output pin
    output_data : in  std_logic;      -- connected to IC data output logic
    ac_mode     : in  std_logic; 
    ac_test     : in  std_logic;      -- hysteric mem reset

    data_out    : out std_logic;
    so          : out std_logic);     -- serial data path output
  end component;


  -- Content from file, DFT_ac_2.vhdpp

  component DFT_ac_2
    port ( capture_clk : in std_logic; -- =tck for sync, =clock_dr for async
	   update_clk  : in std_logic; -- =tck for sync, =update_dr for async
	   capture_en  : in std_logic; -- =clock_dr for sync, =0 for async
	   update_en   : in std_logic; -- =update_dr for sync, =1 for async
	   shift_dr    : in std_logic; -- =shift_dr from TAP
	   mode        : in std_logic; 
	   si          : in std_logic; -- serial data path input
	   ac_mode     : in std_logic; -- hysteric mem set
	   ac_test     : in std_logic; -- hysteric mem reset
	   data_in     : in std_logic; 
	   data_out    : out std_logic;  
	   so          : out std_logic); -- serial data path output
  end component;


  -- Content from file, DFT_ac_7.vhdpp

  component DFT_ac_7
    port ( capture_clk : in std_logic; -- =tck for sync, =clock_dr for async
	   update_clk  : in std_logic; -- =tck for sync, =update_dr for async
	   capture_en  : in std_logic; -- =clock_dr for sync, =0 for async
	   update_en   : in std_logic; -- =update_dr for sync, =1 for async
	   shift_dr    : in std_logic; -- =shift_dr from TAP
	   mode1       : in std_logic; 
	   mode2       : in std_logic; 
	   ac_mode     : in std_logic; 
           ac_test     : in std_logic; -- hysteric mem reset
	   si          : in std_logic; -- serial data path input
	   pin_input   : in std_logic; -- connected to IC input pin 
	   control_out : in std_logic; -- =output signal from the control BSC 
	   output_data : in std_logic; -- connected to IC data output logic 
	   ic_input    : out std_logic; -- connected to IC input logic 
	   data_out    : out std_logic;  
	   so          : out std_logic); -- serial data path output
  end component;


  -- Content from file, DFT_ac_8.vhdpp

  component DFT_ac_8
  port (
    capture_clk : in  std_logic;      -- =tck for sync, =clock_dr for async
    update_clk  : in  std_logic;      -- =tck for sync, =update_dr for async
    
    capture_en  : in  std_logic;      -- =clock_dr for sync, =0 for async
    update_en   : in  std_logic;      -- =update_dr for sync, =1 for async
    shift_dr    : in  std_logic;      -- =shift_dr from TAP
    mode        : in  std_logic;
    si          : in  std_logic;      -- serial data path input
    pin_input   : in  std_logic;      -- connected to IC input pin
    output_data : in  std_logic;      -- connected to IC data output logic
    ac_mode     : in  std_logic; 
    ac_test     : in  std_logic;      -- hysteric mem reset

    ic_input    : out std_logic;      -- connected to IC input logic 
    data_out    : out std_logic;
    so          : out std_logic);     -- serial data path output
  end component;


  -- Content from file, DFT_ac_9.vhdpp

  component DFT_ac_9
    port ( capture_clk : in std_logic; -- =tck for sync, =clock_dr for async
	   update_clk  : in std_logic; -- =tck for sync, =update_dr for async
           
	   capture_en  : in std_logic; -- =clock_dr for sync, =0 for async
	   update_en   : in std_logic; -- =update_dr for sync, =1 for async
	   shift_dr    : in std_logic; -- =shift_dr from TAP
	   mode1       : in std_logic; 
	   mode2       : in std_logic;

	   si          : in std_logic; -- serial data path input
	   pin_input   : in std_logic; -- connected to IC input pin
	   output_data : in std_logic; -- connected to IC data output logic
           ac_mode     : in std_logic; 
           ac_test     : in std_logic;      -- hysteric mem reset

	   data_out    : out std_logic;  
	   so          : out std_logic); -- serial data path output
  end component;


  -- Content from file, DFT_ac_selu.vhdpp

  component DFT_ac_selu
    port ( capture_clk   : in std_logic; -- =clock_dr for sync, =0 for async
	   update_clk  : in std_logic; -- =tck for sync, =update_dr for async
	   capture_en  : in std_logic; -- =clock_dr for sync, =0 for async
	   update_en   : in std_logic; -- =update_dr for sync, =1 for async
           shift_dr    : in std_logic; -- =shift_dr from TAP
	   si          : in std_logic; -- serial data path input
	   acdc_sel    : out std_logic;  
	   so          : out std_logic); -- serial data path output
  end component;


  -- Content from file, DFT_ac_selx.vhdpp

  component DFT_ac_selx
    port ( capture_clk   : in std_logic; -- =clock_dr for sync, =0 for async
	   update_clk  : in std_logic; -- =tck for sync, =update_dr for async
	   capture_en  : in std_logic; -- =clock_dr for sync, =0 for async
	   update_en   : in std_logic; -- =update_dr for sync, =1 for async
	   si          : in std_logic; -- serial data path input
	   acdc_sel    : out std_logic;  
	   so          : out std_logic); -- serial data path output
  end component;


  -- Content from file, DFT_bc_1.vhdpp

  component DFT_bc_1
    port ( capture_clk : in std_logic; -- =tck for sync, =clock_dr for async
	   update_clk  : in std_logic; -- =tck for sync, =update_dr for async
	   capture_en  : in std_logic; -- =clock_dr for sync, =0 for async
	   update_en   : in std_logic; -- =update_dr for sync, =1 for async
	   shift_dr    : in std_logic; -- =shift_dr from TAP
	   mode        : in std_logic; 
	   si          : in std_logic; -- serial data path input
	   data_in     : in std_logic; 
	   data_out    : out std_logic;  
	   so          : out std_logic); -- serial data path output
  end component;


  -- Content from file, DFT_bc_10.vhdpp

  component DFT_bc_10
  port (
    capture_clk : in  std_logic;      -- =tck for sync, =clock_dr for async
    update_clk  : in  std_logic;      -- =tck for sync, =update_dr for async
    
    capture_en  : in  std_logic;      -- =clock_dr for sync, =0 for async
    update_en   : in  std_logic;      -- =update_dr for sync, =1 for async
    shift_dr    : in  std_logic;      -- =shift_dr from TAP
    mode        : in  std_logic;
    
    si          : in  std_logic;      -- serial data path input
    pin_input   : in  std_logic;      -- connected to IC output pin
    output_data : in  std_logic;      -- connected to IC data output logic

    data_out    : out std_logic;
    so          : out std_logic);     -- serial data path output
  end component;


  -- Content from file, DFT_bc_2.vhdpp

  component DFT_bc_2
    port ( capture_clk : in std_logic; -- =tck for sync, =clock_dr for async
	   update_clk  : in std_logic; -- =tck for sync, =update_dr for async
	   capture_en  : in std_logic; -- =clock_dr for sync, =0 for async
	   update_en   : in std_logic; -- =update_dr for sync, =1 for async
	   shift_dr    : in std_logic; -- =shift_dr from TAP
	   mode        : in std_logic; 
	   si          : in std_logic; -- serial data path input
	   data_in     : in std_logic; 
	   data_out    : out std_logic;  
	   so          : out std_logic); -- serial data path output
  end component;


  -- Content from file, DFT_bc_3.vhdpp

  component DFT_bc_3
    port ( capture_clk : in std_logic; -- =tck for sync, =clock_dr for async
	   capture_en  : in std_logic; -- =clock_dr for sync, =0 for async
	   shift_dr    : in std_logic; -- =shift_dr from TAP
	   mode        : in std_logic; 
	   si          : in std_logic; -- serial data path input
	   data_in     : in std_logic; 
	   data_out    : out std_logic;  
	   so          : out std_logic); -- serial data path output
  end component;


  -- Content from file, DFT_bc_4.vhdpp

  component DFT_bc_4
    port ( capture_clk : in std_logic; -- =tck for sync, =clock_dr for async
	   capture_en  : in std_logic; -- =clock_dr for sync, =0 for async
	   shift_dr    : in std_logic; -- =shift_dr from TAP
	   si          : in std_logic; -- serial data path input
	   data_in     : in std_logic; 
	   so          : out std_logic; -- serial data path output
           data_out    : out std_logic); 
  end component;


  -- Content from file, DFT_bc_5.vhdpp

  component DFT_bc_5
    port ( capture_clk : in std_logic; -- =tck for sync, =clock_dr for async
	   update_clk  : in std_logic; -- =tck for sync, =update_dr for async
	   capture_en  : in std_logic; -- =clock_dr for sync, =0 for async
	   update_en   : in std_logic; -- =update_dr for sync, =1 for async
	   shift_dr    : in std_logic; -- =shift_dr from TAP
	   mode        : in std_logic; 
	   intest      : in std_logic; -- intest instruction signal 
	   si          : in std_logic; -- serial data path input
	   data_in     : in std_logic; 
	   data_out    : out std_logic;  
	   so          : out std_logic); -- serial data path output
  end component;


  -- Content from file, DFT_bc_7.vhdpp

  component DFT_bc_7
    port ( capture_clk : in std_logic; -- =tck for sync, =clock_dr for async
	   update_clk  : in std_logic; -- =tck for sync, =update_dr for async
	   capture_en  : in std_logic; -- =clock_dr for sync, =0 for async
	   update_en   : in std_logic; -- =update_dr for sync, =1 for async
	   shift_dr    : in std_logic; -- =shift_dr from TAP
	   mode1       : in std_logic; 
	   mode2       : in std_logic; 
	   si          : in std_logic; -- serial data path input
	   pin_input   : in std_logic; -- connected to IC input pin 
	   control_out : in std_logic; -- =output signal from the control BSC 
	   output_data : in std_logic; -- connected to IC data output logic 
	   ic_input    : out std_logic; -- connected to IC input logic 
	   data_out    : out std_logic;  
	   so          : out std_logic); -- serial data path output
  end component;


  -- Content from file, DFT_bc_8.vhdpp

  component DFT_bc_8
  port (
    capture_clk : in  std_logic;      -- =tck for sync, =clock_dr for async
    update_clk  : in  std_logic;      -- =tck for sync, =update_dr for async
    
    capture_en  : in  std_logic;      -- =clock_dr for sync, =0 for async
    update_en   : in  std_logic;      -- =update_dr for sync, =1 for async
    shift_dr    : in  std_logic;      -- =shift_dr from TAP
    mode        : in  std_logic;
    si          : in  std_logic;      -- serial data path input
    pin_input   : in  std_logic;      -- connected to IC input pin
    output_data : in  std_logic;      -- connected to IC data output logic

    ic_input    : out std_logic;      -- connected to IC input logic 
    data_out    : out std_logic;
    so          : out std_logic);     -- serial data path output
  end component;


  -- Content from file, DFT_bc_9.vhdpp

  component DFT_bc_9
    port ( capture_clk : in std_logic; -- =tck for sync, =clock_dr for async
	   update_clk  : in std_logic; -- =tck for sync, =update_dr for async
           
	   capture_en  : in std_logic; -- =clock_dr for sync, =0 for async
	   update_en   : in std_logic; -- =update_dr for sync, =1 for async
	   shift_dr    : in std_logic; -- =shift_dr from TAP
	   mode1       : in std_logic; 
	   mode2       : in std_logic;

	   si          : in std_logic; -- serial data path input
	   pin_input   : in std_logic; -- connected to IC input pin
	   output_data : in std_logic; -- connected to IC data output logic

	   data_out    : out std_logic;  
	   so          : out std_logic); -- serial data path output
  end component;


  -- Content from file, DW04_par_gen.vhdpp

  constant evenC            : integer := 0;          -- Denotes even parity
  constant oddC             : integer := 1;          -- Denotes odd parity

  function DWF_parity_gen (par_type: INTEGER range 0 to 1;
                       datain: std_logic_vector) return std_logic;

  function parity_odd (datain: std_logic_vector) return std_logic;
  function parity_gen (par_type: INTEGER range 0 to 1;
                       datain: std_logic_vector) return std_logic;


  -- Content from file, DW_BYPASS.vhdpp

  -- This component is a sub-component of DesignWare JTAG components


  -- Content from file, DW_CAPTURE.vhdpp

  -- This component is a sub-component of DesignWare JTAG components


  -- Content from file, DW_CAPUP.vhdpp

  -- This component is a sub-component of DesignWare JTAG components


  -- Content from file, DW_IDREG.vhdpp

  -- This component is a sub-component of DesignWare JTAG components


  -- Content from file, DW_IDREGUC.vhdpp

  -- This component is a sub-component of DesignWare JTAG components


  -- Content from file, DW_INSTRREG.vhdpp

  -- This component is a sub-component of DesignWare JTAG components


  -- Content from file, DW_INSTRREGID.vhdpp

  -- This component is a sub-component of DesignWare JTAG components


  -- Content from file, DW_TAPFSM.vhdpp

  -- This component is a sub-component of DesignWare JTAG components


  -- Content from file, DFT_BYPASS.vhdpp

  -- This component is a sub-component of DesignWare JTAG components


  -- Content from file, DFT_IDREG.vhdpp

  -- This component is a sub-component of DesignWare JTAG components


  -- Content from file, DFT_IDREGUC.vhdpp

  -- This component is a sub-component of DesignWare JTAG components


  -- Content from file, DFT_INSTRREG.vhdpp

  -- This component is a sub-component of DesignWare JTAG components


  -- Content from file, DFT_INSTRREGID.vhdpp

  -- This component is a sub-component of DesignWare JTAG components


  -- Content from file, DFT_TAPFSM.vhdpp

  -- This component is a sub-component of DesignWare JTAG components


end DW04_components;


package body DW04_components is


  -- Content from file, DW04_par_gen.vhdpp


  function DWF_parity_gen (par_type: INTEGER range 0 to 1;
                       datain: std_logic_vector) return std_logic is
  -- This function generates a parity bit given the state of the
  -- par_type supplied it.  Thus, it generates odd or even parity.
  variable parity_in : std_logic_vector(2 downto 0);
  variable parity_out : std_logic;
  variable tmp_datain : std_logic_vector(datain'length downto 0);
  variable new_datain : std_logic_vector((datain'length)-par_type downto 0);
  begin
     tmp_datain := '1' & datain;
     new_datain := tmp_datain((datain'length)-par_type downto 0);
     parity_out := parity_odd(new_datain);
     return(parity_out);
  end;  -- function DWF_parity_gen


  function parity_odd (datain: std_logic_vector) return std_logic is
  -- This function generates an odd parity.
  -- The pragma statements permit this function to map to DW04_par_gen for
  -- implementation.
  constant widthM1    : integer := datain'high;
  variable ones_count : integer;
  variable parity     : std_logic;
  -- pragma map_to_operator PAR_ODD_OP
  -- pragma return_port_name parity
  begin
     if ( any_unknown( datain ) = 1 ) then
        return('X');
     else
     ones_count := evenC;
     for index in 0 to widthM1 loop
        if (datain(index) = '1') then
           if (ones_count = evenC) then
              -- Toggle the count based on current state
              ones_count := oddC;
           else
              ones_count := evenC;
           end if;
        elsif ((datain(index) = 'U') or (datain(index) = 'X')) then
           return('X');
        end if; -- if datain
     end loop;
     if (ones_count = evenC) then
         return('0');
     else
         return('1');
     end if;
     end if;
  end;  -- function parity_odd

  function parity_gen (par_type: INTEGER range 0 to 1;
                       datain: std_logic_vector) return std_logic is
  begin
     return(DWF_parity_gen(par_type,datain));
  end;  -- function parity_gen

end DW04_components;

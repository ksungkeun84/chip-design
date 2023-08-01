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
-- VERSION:   Components package file for DW01_components
--
-- DesignWare_version: 52f5f45f
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_misc.all;
use IEEE.std_logic_arith.all;

library DWARE;
use DWARE.DWpackages.all;

package DW01_components is


  -- Content from file, DW_decode_en.vhdpp

  component DW_decode_en
  generic(width : NATURAL);
  port(en : in std_logic;
       a: in std_logic_vector(width-1 downto 0);
       b: out std_logic_vector(2**width-1 downto 0));
  end component;


  -- Content from file, DW01_csa.vhdpp

  component DW01_csa
  generic (
    width : INTEGER
  );
  port (
    a     : in std_logic_vector(width-1 downto 0);
    b     : in std_logic_vector(width-1 downto 0);
    c     : in std_logic_vector(width-1 downto 0);
    ci    : in std_logic;
    carry : out std_logic_vector(width-1 downto 0);
    sum   : out std_logic_vector(width-1 downto 0);
    co    : out std_logic
  );
  end component;


  -- Content from file, DW01_decode.vhdpp

  component DW01_decode
  generic(width : NATURAL);
  port(A: in std_logic_vector(width-1 downto 0);
       B: out std_logic_vector(2**width-1 downto 0));
  end component;


  -- Content from file, DW01_dec.vhdpp

  component DW01_dec
   generic(width: NATURAL);
   port(A : in std_logic_vector(width-1 downto 0);
        SUM : out std_logic_vector(width-1 downto 0));
  end component;


  -- Content from file, DW01_inc.vhdpp

  component DW01_inc
   generic(width: NATURAL); 
   port(A : in std_logic_vector(width-1 downto 0);
        SUM : out std_logic_vector(width-1 downto 0));
  end component;


  -- Content from file, DW01_incdec.vhdpp

  component DW01_incdec
   generic(width: NATURAL); 
   port(A : in std_logic_vector(width-1 downto 0);
        INC_DEC: std_logic;
        SUM : out std_logic_vector(width-1 downto 0));
  end component;


  -- Content from file, DW01_cmp2.vhdpp

  component DW01_cmp2
   generic (width : NATURAL);
   port(A,B : in std_logic_vector(width-1 downto 0) ;
        LEQ : in std_logic ; -- 1 => LEQ/GT 0=> LT/GEQ
	TC : in std_logic;  -- 1 => 2's complement numbers
        LT_LE : out std_logic ;
        GE_GT : out std_logic) ;
  end component;


  -- Content from file, DW01_cmp6.vhdpp

  component DW01_cmp6
   generic (width : NATURAL);
   port(A,B: in std_logic_vector(width-1 downto 0) ;
        TC : in std_logic ;
        LT : out std_logic ;
        GT : out std_logic ;
        EQ : out std_logic ;
        LE : out std_logic ;
        GE : out std_logic ;
        NE : out std_logic) ;
 
  end component;


  -- Content from file, DW01_add.vhdpp

  component DW01_add
  generic(width : NATURAL);
  port(A,B : in std_logic_vector(width-1 downto 0);
       CI : in std_logic;
       SUM : out std_logic_vector(width-1 downto 0);
       CO : out std_logic);
  end component;


  -- Content from file, DW01_addsub.vhdpp

  component DW01_addsub
   generic(width: NATURAL);
   port(A,B : in std_logic_vector(width-1 downto 0);
        CI : in std_logic;
        ADD_SUB : std_logic;
        SUM : out std_logic_vector(width-1 downto 0);
        CO : out std_logic);
  end component;


  -- Content from file, DW01_sub.vhdpp

  component DW01_sub
   generic(width: NATURAL);      -- wordlength
   port(A,B : in std_logic_vector(width-1 downto 0);
        CI : in std_logic;
        DIFF : out std_logic_vector(width-1 downto 0);
        CO : out std_logic);
  end component;


  -- Content from file, DW01_satrnd.vhdpp

  component DW01_satrnd
  generic(width : POSITIVE := 16;
          msb_out: NATURAL := 15;
	  lsb_out: NATURAL := 0);
  port(din : std_logic_vector(width-1 downto 0);
       tc : std_logic;
       sat : std_logic;              
       rnd : std_logic;
       ov : out std_logic;                     
       dout : out std_logic_vector(msb_out-lsb_out downto 0));
  end component;


  -- Content from file, DW01_absval.vhdpp

  component DW01_absval
  generic(width : NATURAL);
  port(A : std_logic_vector(width-1 downto 0);
       ABSVAL : out std_logic_vector(width-1 downto 0));
  end component;


  -- Content from file, DW01_ash.vhdpp

  component DW01_ash
   generic(A_width, SH_width : POSITIVE);
   port(A : in std_logic_vector(A_width-1 downto 0);	-- input data
        DATA_TC : in std_logic;				-- 2's compl/unsigned data control
        SH : in std_logic_vector(SH_width-1 downto 0);	-- shift coefficient
        SH_TC : in std_logic;				-- 2's compl/unsigned shift coef. control
        B : out std_logic_vector(A_width-1 downto 0));	-- shifted data
  end component;


  -- Content from file, DW01_binenc.vhdpp

  component DW01_binenc
   generic (A_width, ADDR_width: POSITIVE);
 
   port    ( A    : in std_logic_vector(A_width-1 downto 0);
             ADDR : out std_logic_vector(ADDR_width-1 downto 0));
  end component;


  -- Content from file, DW01_prienc.vhdpp

  component DW01_prienc
   generic (A_width, INDEX_width: POSITIVE);
 
   port    ( A     : in std_logic_vector(A_width-1 downto 0);
             INDEX : out std_logic_vector(INDEX_width-1 downto 0));
  end component;


  -- Content from file, DW01_bsh.vhdpp

  component DW01_bsh
   generic(A_width,SH_width : POSITIVE);
   port(A : in std_logic_vector(A_width-1 downto 0);
        SH : in std_logic_vector(SH_width-1 downto 0);
        B : out std_logic_vector(A_width-1 downto 0));
  end component;


  -- Content from file, DW01_mux_any.vhdpp

  component DW01_mux_any
   generic( A_width, SEL_width, MUX_width : POSITIVE;  -- input & output wordlengths
	    bal_str : INTEGER RANGE 0 to 1 := 0);
   port(A : in std_logic_vector(A_width-1 downto 0);  
        SEL : in std_logic_vector(SEL_width-1 downto 0);  
        MUX : out std_logic_vector(MUX_width-1 downto 0));
  end component;


  -- Content from file, DW_cmp_dx.vhdpp

  component DW_cmp_dx
	generic(
		width :		NATURAL;
		p1_width :	NATURAL
		);
	port(
		a : 		in std_logic_vector(width-1 downto 0);
		b : 		in std_logic_vector(width-1 downto 0);
        	tc :		in std_logic;
        	dplx :		in std_logic;
        	lt1 :		out std_logic;
        	eq1 :		out std_logic;
        	gt1 :		out std_logic;
        	lt2 :		out std_logic;
        	eq2 :		out std_logic;
        	gt2 :		out std_logic
		);
  end component;


  -- Content from file, DW_addsub_dx.vhdpp

  component DW_addsub_dx
	generic(
		width :		NATURAL;
		p1_width :	NATURAL
		);
	port(
		a : 		in std_logic_vector(width-1 downto 0);
		b : 		in std_logic_vector(width-1 downto 0);
        	ci1 :		in std_logic;
        	ci2 :		in std_logic;
        	addsub :	in std_logic;
        	tc :		in std_logic;
        	sat :		in std_logic;
        	avg :		in std_logic;
        	dplx :		in std_logic;
        	sum :		out std_logic_vector(width-1 downto 0);
        	co1 :		out std_logic;
        	co2 :		out std_logic
		);
  end component;


  -- Content from file, DW_shifter.vhdpp

  component DW_shifter

   generic(

            data_width : POSITIVE := 8;
            sh_width   : POSITIVE := 3; 
            inv_mode   : INTEGER range 0 to 3 := 0

          );

   port(

        data_in : in std_logic_vector(data_width-1 downto 0);

        data_tc : in std_logic;

        sh : in std_logic_vector(sh_width-1 downto 0);

        sh_tc : in std_logic;

        sh_mode : in std_logic;

        data_out : out std_logic_vector(data_width-1 downto 0)

        ); 

  end component;


  -- Content from file, DW_minmax.vhdpp

  component DW_minmax

  generic (
    width      : natural;               -- word width of inputs and output
    num_inputs : natural := 2);         -- number of inputs

  port (
    a       : in  std_logic_vector(num_inputs*width-1 downto 0);  -- operands
    tc      : in  std_logic;          -- '0' : unsigned, '1' : signed
    min_max : in  std_logic;          -- '0' : minimum, '1' : maximum
    value   : out std_logic_vector(width-1 downto 0);  -- output value
    index   : out std_logic_vector(bit_width(num_inputs)-1 downto 0));

  end component;


  -- Content from file, DW_bin2gray.vhdpp

  component DW_bin2gray

  generic (
    width : natural);                   -- word width

  port (
    b : in  std_logic_vector(width-1 downto 0);   -- binary input
    g : out std_logic_vector(width-1 downto 0));  -- Gray output

  end component;


  -- Content from file, DW_gray2bin.vhdpp

  component DW_gray2bin

  generic (
    width : natural);                   -- word width

  port (
    g : in  std_logic_vector(width-1 downto 0);   -- Gray input
    b : out std_logic_vector(width-1 downto 0));  -- Binary output

  end component;


  -- Content from file, DW_inc_gray.vhdpp

  component DW_inc_gray

  generic (
    width : natural);                   -- word width

  port (
    a  : in  std_logic_vector(width-1 downto 0);   -- Gray input
    ci : in  std_logic;                            -- carry input
    z  : out std_logic_vector(width-1 downto 0));  -- Gray output

  end component;


  -- Content from file, DW_norm.vhdpp

  component DW_norm
   generic(a_width : POSITIVE := 8; 
           srch_wind: POSITIVE := 8; 
           exp_width : POSITIVE := 4;
           exp_ctr : INTEGER range 0 to 1 := 0);
   port(a : in std_logic_vector(a_width-1 downto 0);	-- input data
        exp_offset : in std_logic_vector(exp_width-1 downto 0);
        no_detect : out std_logic;  	        -- all zeros case
        ovfl : out std_logic;  	        -- overflow on Exp_adjustment calculation
        b : out std_logic_vector(a_width-1 downto 0); -- shifted data
        exp_adj : out std_logic_vector(exp_width-1 downto 0));
  end component;


  -- Content from file, DW_norm_rnd.vhdpp

  component DW_norm_rnd
   generic(a_width : POSITIVE := 16;
           srch_wind : POSITIVE := 4;
           exp_width : POSITIVE := 4;
           b_width : POSITIVE := 10;
           exp_ctr : INTEGER range 0 to 1 := 0);
   port(a_mag : in std_logic_vector(a_width-1 downto 0);	-- input data
        pos_offset: in std_logic_vector(exp_width-1 downto 0);
	sticky_bit: in std_logic;
	a_sign: in std_logic;
        rnd_mode: in std_logic_vector (2 downto 0);
        pos_err : out std_logic;  	                -- wrong exponent value
	no_detect : out std_logic;
        b : out std_logic_vector(b_width-1 downto 0); -- shifted data
        pos: out std_logic_vector(exp_width-1 downto 0));
  end component;


  -- Content from file, DW_lod.vhdpp

  component DW_lod
   generic (
     a_width  : POSITIVE := 8);   -- input width

   port (
     a   : in  std_logic_vector(a_width-1 downto 0);           -- input
     enc : out std_logic_vector(bit_width(a_width) downto 0);  -- encoded output
     dec : out std_logic_vector(a_width-1 downto 0)            -- decoded output
        );
  end component;


  -- Content from file, DW_lzd.vhdpp

  component DW_lzd
   generic (
     a_width  : POSITIVE := 8);   -- input width

   port (
     a   : in  std_logic_vector(a_width-1 downto 0);           -- input
     enc : out std_logic_vector(bit_width(a_width) downto 0);  -- encoded output
     dec : out std_logic_vector(a_width-1 downto 0)            -- decoded output
        );
  end component;


  -- Content from file, DW_rash.vhdpp

  component DW_rash
   generic(A_width : POSITIVE := 8;
           SH_width : POSITIVE := 3);
   port(A : in std_logic_vector(A_width-1 downto 0);		-- input data
        DATA_TC : in std_logic;				-- arithmetic shift control
        SH : in std_logic_vector(SH_width-1 downto 0);	-- shifting distance
        SH_TC : in std_logic;				        -- 2's compl/unsigned shifting distance
        B : out std_logic_vector(A_width-1 downto 0));	-- shifted data
  end component;


  -- Content from file, DW_rbsh.vhdpp

  component DW_rbsh
   generic(A_width,SH_width : POSITIVE);
   port(A : in std_logic_vector(A_width-1 downto 0);          -- main input data
        SH : in std_logic_vector(SH_width-1 downto 0);        -- rotation distance
        SH_TC : in std_logic;				        -- 2's compl/unsigned shifting distance
        B : out std_logic_vector(A_width-1 downto 0));
  end component;


  -- Content from file, DW_lbsh.vhdpp

  component DW_lbsh
   generic(A_width,SH_width : POSITIVE);
   port(A : in std_logic_vector(A_width-1 downto 0);          -- main input data
        SH : in std_logic_vector(SH_width-1 downto 0);        -- rotation distance
        SH_TC : in std_logic;				        -- 2's compl/unsigned shifting distance
        B : out std_logic_vector(A_width-1 downto 0));
  end component;


  -- Content from file, DW_sla.vhdpp

  component DW_sla
   generic(A_width : POSITIVE := 8;
           SH_width : POSITIVE := 3);
   port(A : in std_logic_vector(A_width-1 downto 0);	-- input data
        SH : in std_logic_vector(SH_width-1 downto 0);-- shift coefficient
        SH_TC : in std_logic;				-- 2's compl/unsigned shift coef. control
        B : out std_logic_vector(A_width-1 downto 0));-- shifted data
  end component;


  -- Content from file, DW_sra.vhdpp

  component DW_sra
   generic(A_width : POSITIVE := 8;
           SH_width : POSITIVE := 3);
   port(A : in std_logic_vector(A_width-1 downto 0);	-- input data
        SH : in std_logic_vector(SH_width-1 downto 0);-- shift coefficient
        SH_TC : in std_logic;				-- 2's compl/unsigned shift coef. control
        B : out std_logic_vector(A_width-1 downto 0));-- shifted data
  end component;


  -- Content from file, DW_lsd.vhdpp

  component DW_lsd

  generic (
     a_width  : POSITIVE := 8);   -- input width

   port (
     a   : in  std_logic_vector(a_width-1 downto 0);             -- input
     enc : out std_logic_vector(bit_width(a_width)-1 downto 0);  -- encoded output
     dec : out std_logic_vector(a_width-1 downto 0));            -- decoded output

  end component;


  -- Content from file, DW_thermdec.vhdpp

  component DW_thermdec
   generic(width : NATURAL := 3);
   port(en : in std_logic;
        a  : in std_logic_vector(width-1 downto 0);  
        b  : out std_logic_vector(2**width-1 downto 0));
  end component;


  -- Content from file, DW_pricod.vhdpp

  component DW_pricod
  
   generic (
     a_width  : POSITIVE := 8);   -- input width

   port (
     a    : in  std_logic_vector(a_width-1 downto 0);  -- input
     cod  : out std_logic_vector(a_width-1 downto 0);    -- coded output
     zero : out std_logic);                            -- all-zero flag

  end component;


  -- Content from file, DW_lza.vhdpp

  component DW_lza
  generic (width : natural := 7);
  port ( 
        a     : in  std_logic_vector(width-1 downto 0); -- input
        b     : in  std_logic_vector(width-1 downto 0); -- input
        count : out std_logic_vector(bit_width(width)-1 downto 0));-- decoded output
  end component;


  -- Content from file, DW01_ADD_AB.vhdpp

  component DW01_ADD_AB
    port (A,B: in std_logic; S,COUT: out std_logic);
  end component;


  -- Content from file, DW01_ADD_AB1.vhdpp

  component DW01_ADD_AB1
    port (A,B: in std_logic; S,COUT: out std_logic);
  end component;


  -- Content from file, DW01_ADD_ABC.vhdpp

  component DW01_ADD_ABC
    port (A,B,C: in std_logic; S,COUT: out std_logic);
  end component;


  -- Content from file, DW01_AND2.vhdpp

  component DW01_AND2
    port (A,B: in std_logic; Z: out std_logic);
  end component;


  -- Content from file, DW01_AND_NOT.vhdpp

  component DW01_AND_NOT
    port (A,B: in std_logic; Z: out std_logic);
  end component;


  -- Content from file, DW01_AO21.vhdpp

  component DW01_AO21
    port (A,B,C: in std_logic; Z: out std_logic);
  end component;


  -- Content from file, DW01_CL_DEC.vhdpp

  component DW01_CL_DEC
    port (A, C : in std_logic;
	  Z, P : out std_logic);
  end component;


  -- Content from file, DW01_GP_DEC.vhdpp

  component DW01_GP_DEC
    port (CD, P1, P2: in std_logic;
	  PU, C1, C2: out std_logic);
  end component;


  -- Content from file, DW01_GP_SUM.vhdpp

  component DW01_GP_SUM
    port (G,P,C: in std_logic; Z: out std_logic);
  end component;


  -- Content from file, DW01_MUX.vhdpp

  component DW01_MUX
    port (A,B,S: in std_logic; Z: out std_logic);
  end component;


  -- Content from file, DW01_MMUX.vhdpp

  component DW01_mmux
    generic(width : POSITIVE := 1);
    port (A,B: in std_logic_vector(width-1 downto 0);
	  S: in std_logic;
	  Z: out std_logic_vector(width-1 downto 0));


  end component;


  -- Content from file, DW01_NAND2.vhdpp

  component DW01_NAND2
    port (A,B: in std_logic; Z: out std_logic);
  end component;


  -- Content from file, DW01_NOT.vhdpp

  component DW01_NOT
    port (A: in std_logic; Z: out std_logic);
  end component;


  -- Content from file, DW01_OR2.vhdpp

  component DW01_OR2
    port (A,B: in std_logic; Z: out std_logic);
  end component;


  -- Content from file, DW01_OR_NOT.vhdpp

  component DW01_OR_NOT
    port (A,B: in std_logic; Z: out std_logic);
  end component;


  -- Content from file, DW01_SUB_ABC.vhdpp

  component DW01_SUB_ABC
    port (A,B,C: in std_logic; S,COUT: out std_logic);
  end component;


  -- Content from file, DW01_XOR2.vhdpp

  component DW01_XOR2
    port (A,B: in std_logic; Z: out std_logic);
  end component;


  -- Content from file, DW01_LE_REG.vhdpp

  component DW01_le_reg
   generic( data_width: POSITIVE);  

   port(datain  : in std_logic_vector(data_width-1 downto 0);  
        le      : in std_logic;		   -- load enable -> '1', disabled -> '0'
        clk     : in std_logic;            -- clock 
        dataout : out std_logic_vector(data_width-1 downto 0) );


  end component;


  -- Content from file, DW01_GP_NODE.vhdpp

  component DW01_GP_NODE
    port (G,P,G1,P1: in std_logic; G2,P2: out std_logic);
  end component;


  -- Content from file, DW01_decode_DG.vhdpp

  component DW01_decode_DG
  generic(width : NATURAL);
  port(A: in std_logic_vector(width-1 downto 0);
       B: out std_logic_vector(2**width-1 downto 0);
       DG_ctrl: in std_logic);
  end component;


  -- Content from file, DW_PREFIX_XOR.vhdpp

  component DW_PREFIX_XOR

  generic (
    width : natural);                   -- word width

  port (
    pi : in  std_logic_vector(width-1 downto 0);   -- propagate in
    po : out std_logic_vector(width-1 downto 0));  -- propagate out

  end component;


  -- Content from file, DW_PREFIX_OR.vhdpp

  component DW_PREFIX_OR
  
  generic (
    width : natural);                   -- word width

  port (
    pi : in  std_logic_vector(width-1 downto 0);   -- propagate in
    po : out std_logic_vector(width-1 downto 0));  -- propagate out

  end component;


  -- Content from file, DW_PREFIX_ANDOR.vhdpp

  component DW_PREFIX_ANDOR
  
  generic (
    width : natural);                   -- word width

  port (
    gi : in  std_logic_vector(width-1 downto 0);   -- generate in
    pi : in  std_logic_vector(width-1 downto 0);   -- propagate in
    go : out std_logic_vector(width-1 downto 0);   -- generate out
    po : out std_logic_vector(width-1 downto 0));  -- propagate out

  end component;


  -- Content from file, DW_PREFIX_AND.vhdpp

  component DW_PREFIX_AND
  
  generic (
    width : natural);                   -- word width

  port (
    pi : in  std_logic_vector(width-1 downto 0);   -- propagate in
    po : out std_logic_vector(width-1 downto 0));  -- propagate out

  end component;


  -- Content from file, DW_PRIORITY_CODER.vhdpp

  component DW_PRIORITY_CODER
  
  generic (
    A_width     : positive;                    -- input width
    A_detect_1  : integer range 0 to 1 := 1;   -- phase to detect: 1 = detect '1'
    DEC_lsb2msb : integer range 0 to 1 := 1;   -- decoding direction: 1 = from LSB to MSB
    ENC_lsb2msb : integer range 0 to 1 := 1);  -- encoding direction: 1 = from LSB to MSB

  port (
    A   : in  std_logic_vector(A_width-1 downto 0);  -- input
    DEC : out std_logic_vector(A_width-1 downto 0);  -- decoded output
    ENC : out std_logic_vector(bit_width(A_width+1)-1 downto 0));  -- encoded output

  end component;


  -- Content from file, DW_or_tree.vhdpp

  component DW_or_tree
	
    generic( width : INTEGER range 1 to 1024 );
    port( a : in std_logic_vector( width-1 downto 0 );
	  b : out std_logic );
  end component;


  -- Content from file, DW_and_tree.vhdpp

  component DW_and_tree
	
    generic( width : INTEGER range 1 to 1024 );
    port( a : in std_logic_vector( width-1 downto 0 );
	  b : out std_logic );
  end component;


  -- Content from file, DW_inc.vhdpp

  component DW_inc
   generic(width: NATURAL); 
   port(carry_in : in std_logic;
	a : in std_logic_vector(width-1 downto 0);
	carry_out : out std_logic;
	sum : out std_logic_vector(width-1 downto 0));
  end component;


  -- Content from file, DW_incdec.vhdpp

  component DW_incdec
   generic(width: NATURAL); 
   port(inc_dec, c_b_in : std_logic;
        a : in std_logic_vector(width-1 downto 0);
	c_b_out : out std_logic;
        sum : out std_logic_vector(width-1 downto 0));
  end component;


  -- Content from file, DW_dec.vhdpp

  component DW_dec
   generic(width: NATURAL);
   port(borrow_in : in std_logic;
	a : in std_logic_vector(width-1 downto 0);
	borrow_out : out std_logic;
        sum : out std_logic_vector(width-1 downto 0));
  end component;


  -- Content from file, DW_ne.vhdpp

  component DW_ne
	
    generic( width : INTEGER range 1 to 1024 );
    port( a, b : in std_logic_vector( width-1 downto 0 );
	  ne : out std_logic );
  end component;


  -- Content from file, DW_eq.vhdpp

  component DW_eq
	
    generic( width : INTEGER range 1 to 1024 );
    port( a, b : in std_logic_vector( width-1 downto 0 );
	  eq : out std_logic );
  end component;


  -- Content from file, DW_bit_order.vhdpp

  component DW_bit_order

    generic (
	    width : POSITIVE := 16;
	    bit_order  : INTEGER range 0 to 3  := 0
	    );

    port    (
	    data_in : in std_logic_vector(width-1 downto 0);

	    data_out : out std_logic_vector(width-1 downto 0)
	    );

  end component;


  -- Content from file, DW_minmax4.vhdpp

  component DW_minmax4

  generic (
    width : natural);                   -- word width

  port (
    a0, a1, a2, a3 : in  std_logic_vector(width-1 downto 0);  -- inputs
    tc             : in  std_logic;   -- '0' : unsigned, '1' : signed
    min_max        : in  std_logic;   -- '0' : minimum, '1' : maximum
    value          : out std_logic_vector(width-1 downto 0);  -- output value
    index          : out std_logic_vector(2 downto 0));  -- index of input

  end component;


  -- Content from file, DW_minmax2.vhdpp

  component DW_minmax2

  generic (
    width : natural);                   -- word width

  port (
    a, b    : in  std_logic_vector(width-1 downto 0);  -- input operands
    tc      : in  std_logic;          -- '0' : unsigned, '1' : signed
    min_max : in  std_logic;          -- '0' : minimum, '1' : maximum
    value   : out std_logic_vector(width-1 downto 0);  -- output value
    index   : out std_logic);         -- '0' : a, '1' : b

  end component;


  -- Content from file, DW_lzod.vhdpp

  component DW_lzod

  generic (
    a_width  : POSITIVE;                    -- input width
    detect_1 : INTEGER range 0 to 1 := 0);  -- detect zero (= 0), one (= 1)

  port (
    a   : in  std_logic_vector(a_width-1 downto 0);           -- input
    enc : out std_logic_vector(bit_width(a_width) downto 0);  -- encoded output
    dec : out std_logic_vector(a_width-1 downto 0));          -- decoded output

  end component;


  -- Content from file, DWsc_opiso_ve.vhdpp

  component DWsc_opiso_ve
   generic (
     width       : POSITIVE  := 8
   );

   port (
     enable      : in std_logic;
     data_in     : in std_logic_vector(width-1 downto 0);
     data_out    : out std_logic_vector(width-1 downto 0)
   );
  end component;


  -- Content from file, DWsc_opiso_vh.vhdpp

  component DWsc_opiso_vh
   generic (
     width       : POSITIVE  := 8
   );

   port (
     enable      : in std_logic;
     data_in     : in std_logic_vector(width-1 downto 0);
     data_out    : out std_logic_vector(width-1 downto 0)
   );
  end component;


  -- Content from file, DW01_components.commonpp

    function DW_max(L, R: INTEGER) return INTEGER;
    function DW_max(L, R: SIGNED) return SIGNED;
    function DW_max(L, R: UNSIGNED) return UNSIGNED;

    function DW_min(L, R: INTEGER) return INTEGER;
    function DW_min(L, R: SIGNED) return SIGNED;
    function DW_min(L, R: UNSIGNED) return UNSIGNED;

    function DW_maxmin(L, R: INTEGER; max_min: std_logic) return INTEGER;
    function DW_maxmin(L, R: SIGNED; max_min: std_logic) return SIGNED;
    function DW_maxmin(L, R: UNSIGNED; max_min: std_logic) return UNSIGNED;
	function compute_levelsM1 (width, blk : INTEGER) return INTEGER;


  -- Content from file, DW01_decode.vhdpp

    function DWF_decode(A: SIGNED) return SIGNED;
    
    function DWF_decode(A: UNSIGNED) return UNSIGNED;

    function DWF_decode(A: std_logic_vector) return std_logic_vector;
    function DW_decode(A: SIGNED) return SIGNED;

    function DW_decode(A: UNSIGNED) return UNSIGNED;

    function DW_decode(A: std_logic_vector) return std_logic_vector;


  -- Content from file, DW01_absval.vhdpp

    function DWF_absval(A: SIGNED) return SIGNED;
    function DW_absval(A: SIGNED) return SIGNED;


  -- Content from file, DW01_ash.vhdpp

    function DWF_ash(A: UNSIGNED; SH: UNSIGNED) return UNSIGNED;

    function DWF_ash(A: SIGNED; SH: UNSIGNED) return SIGNED;

    function DWF_ash(A: UNSIGNED; SH: SIGNED) return UNSIGNED;

    function DWF_ash(A: SIGNED; SH: SIGNED) return SIGNED;
    function DW_ash(A: UNSIGNED; SH: UNSIGNED) return UNSIGNED;

    function DW_ash(A: SIGNED; SH: UNSIGNED) return SIGNED;

    function DW_ash(A: UNSIGNED; SH: SIGNED) return UNSIGNED;

    function DW_ash(A: SIGNED; SH: SIGNED) return SIGNED;


  -- Content from file, DW01_binenc.vhdpp

    function DWF_binenc(A: SIGNED; ADDR_width: NATURAL) return SIGNED;
    
    function DWF_binenc(A: UNSIGNED; ADDR_width: NATURAL) 
        return UNSIGNED;

    function DWF_binenc(A: std_logic_vector; ADDR_width: NATURAL) 
        return std_logic_vector;

    function DW_binenc(A: SIGNED; ADDR_width: NATURAL) return SIGNED;

    function DW_binenc(A: UNSIGNED; ADDR_width: NATURAL)
        return UNSIGNED;

    function DW_binenc(A: std_logic_vector; ADDR_width: NATURAL)
        return std_logic_vector;


  -- Content from file, DW01_prienc.vhdpp

    function DWF_prienc(A: SIGNED; INDEX_width: NATURAL) return SIGNED;
    
    function DWF_prienc(A: UNSIGNED; INDEX_width: NATURAL) 
        return UNSIGNED;

    function DWF_prienc(A: std_logic_vector; INDEX_width: NATURAL) 
        return std_logic_vector;

    function DW_prienc(A: SIGNED; INDEX_width: NATURAL) return SIGNED;

    function DW_prienc(A: UNSIGNED; INDEX_width: NATURAL)
        return UNSIGNED;

    function DW_prienc(A: std_logic_vector; INDEX_width: NATURAL)
        return std_logic_vector;


  -- Content from file, DW01_bsh.vhdpp

    function DWF_bsh(A: SIGNED; SH: UNSIGNED) return SIGNED;
    
    function DWF_bsh(A: UNSIGNED; SH: UNSIGNED) return UNSIGNED;
    
    function DWF_bsh(A: std_logic_vector; SH: std_logic_vector)
			return std_logic_vector;
    function DW_bsh(A: SIGNED; SH: UNSIGNED) return SIGNED;

    function DW_bsh(A: UNSIGNED; SH: UNSIGNED) return UNSIGNED;

    function DW_bsh(A: std_logic_vector; SH: std_logic_vector)
                   return std_logic_vector;


  -- Content from file, DW_shifter.vhdpp

    function DWF_shifter(data_in: UNSIGNED; sh: UNSIGNED; sh_mode: std_logic) return UNSIGNED;

    function DWF_shifter(data_in: SIGNED; sh: UNSIGNED; sh_mode: std_logic) return SIGNED;

    function DWF_shifter(data_in: UNSIGNED; SH: SIGNED; sh_mode: std_logic) return UNSIGNED;

    function DWF_shifter(data_in: SIGNED; SH: SIGNED; sh_mode: std_logic) return SIGNED;


  -- Content from file, DW_minmax.vhdpp

  function DWF_min (a : unsigned; num_inputs : natural) return unsigned;
  function DWF_min (a : signed; num_inputs : natural) return signed;
  function DWF_max (a : unsigned; num_inputs : natural) return unsigned;
  function DWF_max (a : signed; num_inputs : natural) return signed;
  -- Internal procedures (not synthesizable)
  procedure MIN_UNSIGNED (a : in unsigned;
                          value : out unsigned;
                          index : out std_logic_vector);
  procedure MIN_SIGNED (a : in signed;
                        value : out signed;
                        index : out std_logic_vector);
  procedure MAX_UNSIGNED (a : in unsigned;
                          value : out unsigned;
                          index : out std_logic_vector);
  procedure MAX_SIGNED (a : in signed;
                        value : out signed;
                        index : out std_logic_vector);


  -- Content from file, DW_bin2gray.vhdpp

   function DWF_bin2gray (B : std_logic_vector)
            return std_logic_vector;


  -- Content from file, DW_gray2bin.vhdpp

   function DWF_gray2bin (G : std_logic_vector) 
            return std_logic_vector;


  -- Content from file, DW_inc_gray.vhdpp

   function DWF_inc_gray (A  : std_logic_vector;
                          CI : std_logic)
            return std_logic_vector;


  -- Content from file, DW_lod.vhdpp

    function DWF_lod_enc(A: SIGNED) return SIGNED;
    
    function DWF_lod_enc(A: UNSIGNED) return UNSIGNED;

    function DWF_lod_enc(A: std_logic_vector) return std_logic_vector;
    function DWF_lod(A: SIGNED) return SIGNED;
    
    function DWF_lod(A: UNSIGNED) return UNSIGNED;

    function DWF_lod(A: std_logic_vector) return std_logic_vector;


  -- Content from file, DW_lzd.vhdpp

    function DWF_lzd_enc(A: SIGNED) return SIGNED;
    
    function DWF_lzd_enc(A: UNSIGNED) return UNSIGNED;

    function DWF_lzd_enc(A: std_logic_vector) return std_logic_vector;
    function DWF_lzd(A: SIGNED) return SIGNED;
    
    function DWF_lzd(A: UNSIGNED) return UNSIGNED;

    function DWF_lzd(A: std_logic_vector) return std_logic_vector;


  -- Content from file, DW_rash.vhdpp

    function DWF_rash(A: UNSIGNED; SH: UNSIGNED) return UNSIGNED;

    function DWF_rash(A: SIGNED; SH: UNSIGNED) return SIGNED;

    function DWF_rash(A: UNSIGNED; SH: SIGNED) return UNSIGNED;

    function DWF_rash(A: SIGNED; SH: SIGNED) return SIGNED;


  -- Content from file, DW_rbsh.vhdpp

    function DWF_rbsh(A: UNSIGNED; SH: UNSIGNED) return UNSIGNED;

    function DWF_rbsh(A: SIGNED; SH: UNSIGNED) return SIGNED;

    function DWF_rbsh(A: UNSIGNED; SH: SIGNED) return UNSIGNED;

    function DWF_rbsh(A: SIGNED; SH: SIGNED) return SIGNED;


  -- Content from file, DW_lbsh.vhdpp

    function DWF_lbsh(A: UNSIGNED; SH: UNSIGNED) return UNSIGNED;

    function DWF_lbsh(A: SIGNED; SH: UNSIGNED) return SIGNED;

    function DWF_lbsh(A: UNSIGNED; SH: SIGNED) return UNSIGNED;

    function DWF_lbsh(A: SIGNED; SH: SIGNED) return SIGNED;


  -- Content from file, DW_lsd.vhdpp

    function DWF_lsd_enc (A: SIGNED) return SIGNED;
    
    function DWF_lsd_enc (A: UNSIGNED) return UNSIGNED;

    function DWF_lsd_enc (A: std_logic_vector) return std_logic_vector;

    function DWF_lsd (A: SIGNED) return SIGNED;
    
    function DWF_lsd (A: UNSIGNED) return UNSIGNED;

    function DWF_lsd (A: std_logic_vector) return std_logic_vector;


  -- Content from file, DW_pricod.vhdpp

    function DWF_pricod (A : SIGNED) return SIGNED;
    
    function DWF_pricod (A : UNSIGNED) return UNSIGNED;

    function DWF_pricod (A : std_logic_vector) return std_logic_vector;


  -- Content from file, DW_lza.vhdpp


  function DWF_lza(A,B: std_logic_vector) return std_logic_vector;


end DW01_components;


package body DW01_components is


  -- Content from file, DW01_components.commonpp

    function DW_max(L, R: INTEGER) return INTEGER is
    begin
	if L > R then
	    return L;
	else
	    return R;
	end if;
    end;

    function DW_max(L, R: SIGNED) return SIGNED is
    begin
	if L > R then
	    return L;
	else
	    return R;
	end if;
    end;

    function DW_max(L, R: UNSIGNED) return UNSIGNED is
    begin
	if L > R then
	    return L;
	else
	    return R;
	end if;
    end;

    function DW_min(L, R: INTEGER) return INTEGER is
    begin
	if L < R then
	    return L;
	else
	    return R;
	end if;
    end;

    function DW_min(L, R: SIGNED) return SIGNED is
    begin
	if L < R then
	    return L;
	else
	    return R;
	end if;
    end;

    function DW_min(L, R: UNSIGNED) return UNSIGNED is
    begin
	if L < R then
	    return L;
	else
	    return R;
	end if;
    end;

    function DW_maxmin(L, R: INTEGER; max_min: std_logic) return INTEGER is
    begin
      if (max_min = '0' or max_min = 'L') then   
        return DW_max(L,R);      
      -- synopsys synthesis_off		
      elsif (max_min = 'U' or 
             max_min = 'X' or
             max_min = 'Z' or	     
             max_min = 'W')  then
        return 0;
      -- synopsys synthesis_on	     
      else
        return DW_min(L,R);
      end if;
    end;

    function DW_maxmin(L, R: SIGNED; max_min: std_logic) return SIGNED is
      subtype return_type is SIGNED(L'range);        
    begin
      if (max_min = '0' or max_min = 'L') then   
        return DW_max(L,R);      
      -- synopsys synthesis_off		
      elsif (max_min = 'U' or 
             max_min = 'X' or
             max_min = 'Z' or	     
             max_min = 'W')  then
        return return_type'(others => 'X');
      -- synopsys synthesis_on	     
      else
        return DW_min(L,R);
      end if;
    end;

    function DW_maxmin(L, R: UNSIGNED; max_min: std_logic) return UNSIGNED is
      subtype return_type is UNSIGNED(L'range);            
    begin
      if (max_min = '0' or max_min = 'L') then   
        return DW_max(L,R);      
      -- synopsys synthesis_off		
      elsif (max_min = 'U' or 
             max_min = 'X' or
             max_min = 'Z' or	     
             max_min = 'W')  then
        return return_type'(others => 'X');
      -- synopsys synthesis_on	     
      else
        return DW_min(L,R);
      end if;
    end;

	function compute_levelsM1 (width, blk : INTEGER) return INTEGER is
	    variable current_n : integer;
	begin
	    current_n := blk;
	    if(width <= current_n) then
		return(0);
	    end if;
	    current_n := current_n * blk;
	    if(width <= current_n) then
		return(1);
       end if;	
	    current_n := current_n * blk;
	    if(width <= current_n) then
		return(2);
       end if;	
	    -- use loop for rest (this should rarely get invoked)
	    for i in 3 to 20 loop
		current_n := current_n * blk;
		if(width <= current_n) then
		    return(i);
		end if;
 	    end loop;
	    return(-2);  -- Should never reach here...
	end;


  -- Content from file, DW01_decode.vhdpp

    function BINDEC_TC_ARG(A: SIGNED) return SIGNED is
      variable Z: SIGNED((2**A'length-1) downto 0);
      -- pragma return_port_name Z
    begin
      return(Z);
    end;

    function BINDEC_UNS_ARG(A: UNSIGNED) return UNSIGNED is
      variable Z: UNSIGNED((2**A'length-1) downto 0);
      -- pragma return_port_name Z
    begin
      return(Z);
    end;

    function BINDEC_STD_LOGIC_ARG(A: std_logic_vector) 
             return  std_logic_vector is
      variable Z: std_logic_vector((2**A'length-1) downto 0);
      -- pragma return_port_name Z
    begin
      return(Z);
    end;

    procedure bin_decode(A: in std_logic_vector; B: out std_logic_vector) is
      constant A_msb : NATURAL := A'length-1;
      variable A_norm : std_logic_vector(A_msb downto 0) := A;
      constant B_msb: NATURAL := 2**(A'length)-1;
      variable and_acc: std_logic;
      variable and_out: std_logic_vector(B_msb downto 0);
      type and_array is array(B_msb downto 0) of 
                        std_logic_vector(A_msb downto 0);
      variable and_in : and_array;
    begin
      for j in 0 to A_msb loop
	for k in 0 to B_msb loop
	  if (k mod 2**(j+1)) < 2**(j) then
	    and_in(k)(j) := not A_norm(j);
	  else
	    and_in(k)(j) := A_norm(j);
	  end if;
	end loop;
      end loop;
      for i in 0 to B_msb loop
	and_acc := '1';
	for j in 0 to A_msb loop
	  and_acc := and_acc and and_in(i)(j);
	end loop;
	and_out(i) := and_acc;
      end loop;
      for i in 0 to B_msb loop
	B(i) := and_out(i);
      end loop;
    end bin_decode;    

    function DWF_decode(A: SIGNED) return SIGNED is
      -- pragma map_to_operator BINDEC_TC_OP
      -- pragma type_function BINDEC_TC_ARG
      -- pragma return_port_name Z
      constant arg_width: NATURAL := A'length;
      constant output_width: NATURAL := 2**A'length;
      variable A1: std_logic_vector(arg_width-1 downto 0);
      variable B: std_logic_vector(output_width-1 downto 0);      
      variable Z: SIGNED(output_width-1 downto 0);
    begin
      A1 := std_logic_vector(A);
      bin_decode(A1,B);
      return(SIGNED(B));
    end;    
    
    function DWF_decode(A: UNSIGNED) return UNSIGNED is
      -- pragma map_to_operator BINDEC_UNS_OP
      -- pragma type_function BINDEC_UNS_ARG
      -- pragma return_port_name Z
      constant arg_width: NATURAL := A'length;
      constant output_width: NATURAL := 2**A'length;
      variable A1: std_logic_vector(arg_width-1 downto 0);      
      variable B: std_logic_vector(output_width-1 downto 0);      
      variable Z: UNSIGNED(output_width-1 downto 0);      
    begin
      A1 := std_logic_vector(A);
      bin_decode(A1,B);
      return(UNSIGNED(B));
    end;    

    function DWF_decode(A: std_logic_vector) return std_logic_vector is
      -- pragma map_to_operator BINDEC_STD_LOGIC_OP
      -- pragma type_function BINDEC_STD_LOGIC_ARG
      -- pragma return_port_name Z
      constant output_width: NATURAL := 2**A'length;
      variable B: std_logic_vector(output_width-1 downto 0);      
    begin
      bin_decode(A,B);  
      return(B);
    end;

    function DW_decode(A: SIGNED) return SIGNED is
      -- pragma map_to_operator BINDEC_TC_OP
      -- pragma type_function BINDEC_TC_ARG
      -- pragma return_port_name Z
    begin
      return(DWF_decode(A));
    end;

    function DW_decode(A: UNSIGNED) return UNSIGNED is
      -- pragma map_to_operator BINDEC_UNS_OP
      -- pragma type_function BINDEC_UNS_ARG
      -- pragma return_port_name Z
    begin
      return(DWF_decode(A));
    end;

    function DW_decode(A: std_logic_vector) return std_logic_vector is
      -- pragma map_to_operator BINDEC_STD_LOGIC_OP
      -- pragma type_function BINDEC_STD_LOGIC_ARG
      -- pragma return_port_name Z
    begin
      return(DWF_decode(A));
    end;


  -- Content from file, DW01_absval.vhdpp

    function SIGNED_ARG(A: SIGNED) return SIGNED is
      variable Z: SIGNED (A'length-1 downto 0);
      -- pragma return_port_name Z
    begin
      return(Z);
    end;

    function DWF_absval(A: SIGNED) return SIGNED is
      -- pragma map_to_operator ABS_OP
      -- pragma type_function SIGNED_ARG
      -- pragma return_port_name Z
    begin
        return(ABS(A));
    end;

    function DW_absval(A: SIGNED) return SIGNED is
      -- pragma map_to_operator ABS_OP
      -- pragma type_function SIGNED_ARG
      -- pragma return_port_name Z
      begin
        return DWF_absval(A);  
      end;


  -- Content from file, DW01_ash.vhdpp

    function SH_TC_TC_ARG(A,SH: SIGNED) return SIGNED is
      variable Z: SIGNED (A'length-1 downto 0);
      -- pragma return_port_name Z
    begin
      return(Z);
    end;

    function SH_TC_UNS_ARG(A: SIGNED; SH: UNSIGNED) return SIGNED is
      variable Z: SIGNED (A'length-1 downto 0);
      -- pragma return_port_name Z
    begin
      return(Z);
    end;
	
    function SH_UNS_UNS_ARG(A,SH: UNSIGNED) return UNSIGNED is
      variable Z: UNSIGNED (A'length-1 downto 0);
      -- pragma return_port_name Z
    begin
      return(Z);
    end;

    function SH_UNS_TC_ARG(A,SH: UNSIGNED) return UNSIGNED is
      variable Z: UNSIGNED (A'length-1 downto 0);
      -- pragma return_port_name Z
    begin
      return(Z);
    end;

    function DWF_ash(A: UNSIGNED; SH: UNSIGNED) return UNSIGNED is
      -- pragma map_to_operator ASH_UNS_UNS_OP
      -- pragma type_function SH_UNS_UNS_ARG
      -- pragma return_port_name Z
    begin
      return(SHL(A,SH));
    end;

    function DWF_ash(A: SIGNED; SH: UNSIGNED) return SIGNED is
      -- pragma map_to_operator ASH_TC_UNS_OP
      -- pragma type_function SH_TC_UNS_ARG
      -- pragma return_port_name Z
    begin
      return(SHL(A,SH));
    end;

    function DWF_ash(A: UNSIGNED; SH: SIGNED) return UNSIGNED is
      -- pragma map_to_operator ASH_UNS_TC_OP
      -- pragma type_function SH_UNS_TC_ARG
      -- pragma return_port_name Z
      constant n: NATURAL := A'length;
      constant m: NATURAL := SH'length;
      variable SHMAG: SIGNED(m-1 downto 0);
    begin
      -- signed shift coefficient - perform left and right shifts on A
      SHMAG := ABS(SIGNED(SH));  -- absolute value of shift coefficient
      if SH(m-1) = '0' then  -- left shift
	     return(SHL(A,UNSIGNED(SHMAG)));
      else                   -- right shift
        return(SHR(A,UNSIGNED(SHMAG)));
      end if;
    end;

    function DWF_ash(A: SIGNED; SH: SIGNED) return SIGNED is
      -- pragma map_to_operator ASH_TC_TC_OP
      -- pragma type_function SH_TC_TC_ARG
      -- pragma return_port_name Z
      constant n: NATURAL := A'length;
      constant m: NATURAL := SH'length;
      variable SHMAG: SIGNED(m-1 downto 0);
    begin
      -- signed shift coefficient - perform left and right shifts on A
      SHMAG := ABS(SH);  -- absolute value of shift coefficient
      if SH(m-1) = '0' then  -- left shift
	     return(SHL(A,UNSIGNED(SHMAG)));
      else                   -- right shift
	     return(SHR(A,UNSIGNED(SHMAG)));  
      end if;
    end;

    function DW_ash(A: UNSIGNED; SH: UNSIGNED) return UNSIGNED is
      -- pragma map_to_operator ASH_UNS_UNS_OP
      -- pragma type_function SH_UNS_UNS_ARG
      -- pragma return_port_name Z
    begin
      return DWF_ash(A,SH);
    end;

    function DW_ash(A: SIGNED; SH: UNSIGNED) return SIGNED is
      -- pragma map_to_operator ASH_TC_UNS_OP
      -- pragma type_function SH_TC_UNS_ARG
      -- pragma return_port_name Z
    begin
      return DWF_ash(A,SH);
    end;

    function DW_ash(A: UNSIGNED; SH: SIGNED) return UNSIGNED is
      -- pragma map_to_operator ASH_UNS_TC_OP
      -- pragma type_function SH_UNS_TC_ARG
      -- pragma return_port_name Z
    begin
      return DWF_ash(A,SH);
    end;

    function DW_ash(A: SIGNED; SH: SIGNED) return SIGNED is
      -- pragma map_to_operator ASH_TC_TC_OP
      -- pragma type_function SH_TC_TC_ARG
      -- pragma return_port_name Z
    begin
      return DWF_ash(A,SH);
    end;


  -- Content from file, DW01_binenc.vhdpp

    function BINENC_TC_ARG(A: SIGNED) return SIGNED is
      variable Z: SIGNED(bit_width(A'length) downto 0);
      -- pragma return_port_name Z
    begin
      return(Z);
    end;

    function BINENC_UNS_ARG(A: UNSIGNED) 
        return UNSIGNED is
      variable Z: UNSIGNED(bit_width(A'length) downto 0);
      -- pragma return_port_name Z
    begin
      return(Z);
    end;

    function BINENC_STD_LOGIC_ARG(A: std_logic_vector)
             return  std_logic_vector is
      variable Z: std_logic_vector(bit_width(A'length) downto 0);
      -- pragma return_port_name Z
    begin
      return(Z);
    end;

    function binenc (A: std_logic_vector) return INTEGER is
      constant A_msb: integer := A'length-1;
      variable A_norm: std_logic_vector(A_msb downto 0) := A;
      variable INDEX: integer;
    begin
      for i in 0 to A_msb loop
  	if (To_X01(A_norm(i)) = '1' ) then
      return(i);
	elsif (To_X01(A_norm(i)) /= '0') then
	  return(-2);
	end if;
      end loop;
      return(-1);  -- illegal input - need at least a single '1' bit
    end binenc;

    function binenc_s(A: SIGNED) return SIGNED is
      -- pragma map_to_operator BINENC_TC_OP
      -- pragma type_function BINENC_TC_ARG
      -- pragma return_port_name Z
      constant A_width: NATURAL := A'length;
      constant Z_width: NATURAL := bit_width(A'length)+1;
      variable AV: std_logic_vector(A_width-1 downto 0);
      variable Z: SIGNED(Z_width-1 downto 0);
      variable Y: SIGNED (Z_width-1 downto 0):= (others => 'X');  
      variable addr_int: integer;  
    begin
      -- pragma translate_off
      AV := std_logic_vector(A);
      addr_int := binenc(AV);
      if (addr_int < -1) then
        Z := Y;
      else
        Z := CONV_SIGNED(addr_int, Z_width);
      end if;  
      -- pragma translate_on
      return(Z);
    end;    

    function binenc_u(A: UNSIGNED) return UNSIGNED is
      -- pragma map_to_operator BINENC_UNS_OP
      -- pragma type_function BINENC_UNS_ARG
      -- pragma return_port_name Z
      constant A_width: NATURAL := A'length;
      constant Z_width: NATURAL := bit_width(A'length)+1;
      variable AV: std_logic_vector(A_width-1 downto 0);
      variable Z: UNSIGNED(Z_width-1 downto 0);
      variable Y: UNSIGNED (Z_width-1 downto 0):= (others => 'X');  
      variable addr_int: integer;  
    begin
      -- pragma translate_off
      AV := std_logic_vector(A);
      addr_int := binenc(AV);
      if (addr_int < -1) then
        Z := Y;
      else
        Z := UNSIGNED(CONV_SIGNED(addr_int, Z_width));
      end if;  
      -- pragma translate_on
      return(Z);
    end;    

    function binenc_v(A: std_logic_vector) return std_logic_vector is
      -- pragma map_to_operator BINENC_STD_LOGIC_OP
      -- pragma type_function BINENC_STD_LOGIC_ARG
      -- pragma return_port_name Z
      constant Z_width: NATURAL := bit_width(A'length)+1;
      variable Z: std_logic_vector(Z_width-1 downto 0);
      variable Y: std_logic_vector (Z_width-1 downto 0):= (others => 'X');  
      variable addr_int: integer;  
    begin
      -- pragma translate_off
      addr_int := binenc(A);
      if (addr_int < -1) then
        Z := Y;
      else
        Z := std_logic_vector(CONV_SIGNED(addr_int, Z_width));
      end if;  
      -- pragma translate_on
      return(Z);
    end;    

    function DWF_binenc(A: SIGNED; ADDR_width: NATURAL) return SIGNED is
      constant Z_prime_width : NATURAL := bit_width(A'length)+1;
      variable Z: SIGNED(ADDR_width-1 downto 0);
      variable Z_prime: SIGNED(Z_prime_width-1 downto 0);
    begin
      Z_prime := binenc_s(A);
      if (ADDR_width > Z_prime_width ) then
        Z(Z_prime_width-1 downto 0) := Z_prime;
        Z(ADDR_width-1 downto Z_prime_width) := (others => Z_prime(Z_prime_width-1));
      else
        Z := Z_prime(ADDR_width-1 downto 0);
      end if;
      return(Z);
    end;
    
    
    function DWF_binenc(A: UNSIGNED; ADDR_width: NATURAL) 
        return UNSIGNED is
      constant Z_prime_width : NATURAL := bit_width(A'length)+1;
      variable Z: UNSIGNED(ADDR_width-1 downto 0);
      variable Z_prime: UNSIGNED(Z_prime_width-1 downto 0);
    begin
      Z_prime := binenc_u(A);
      if (ADDR_width > Z_prime_width ) then
        Z(Z_prime_width-1 downto 0) := Z_prime;
        Z(ADDR_width-1 downto Z_prime_width) := (others => Z_prime(Z_prime_width-1));
      else
        Z := Z_prime(ADDR_width-1 downto 0);
      end if;
      return(Z);
    end;
    

    function DWF_binenc(A: std_logic_vector; ADDR_width: NATURAL) 
        return std_logic_vector is
      constant Z_prime_width : NATURAL := bit_width(A'length)+1;
      variable Z: std_logic_vector(ADDR_width-1 downto 0);
      variable Z_prime: std_logic_vector(Z_prime_width-1 downto 0);
    begin
      Z_prime := binenc_v(A);
      if (ADDR_width > Z_prime_width ) then
        Z(Z_prime_width-1 downto 0) := Z_prime;
        Z(ADDR_width-1 downto Z_prime_width) := (others => Z_prime(Z_prime_width-1));
      else
        Z := Z_prime(ADDR_width-1 downto 0);
      end if;
      return(Z);
    end;
    

    function DW_binenc(A: SIGNED; ADDR_width: NATURAL) return SIGNED is
      variable Z: SIGNED(ADDR_width-1 downto 0);
    begin
      Z := DWF_binenc(A, ADDR_width);
      return(Z);
    end;

    function DW_binenc(A: UNSIGNED; ADDR_width: NATURAL)
        return UNSIGNED is
      variable Z: UNSIGNED(ADDR_width-1 downto 0);
    begin
      Z := DWF_binenc(A, ADDR_width);
      return(Z);
    end;

    function DW_binenc(A: std_logic_vector; ADDR_width: NATURAL)
        return std_logic_vector is
      variable Z: std_logic_vector(ADDR_width-1 downto 0);
    begin
      Z := DWF_binenc(A, ADDR_width);
      return(Z);
    end;


  -- Content from file, DW01_prienc.vhdpp

    function PRIENC_TC_ARG(A: SIGNED) 
             return SIGNED is
      variable Z: SIGNED(bit_width(A'length+1)-1 downto 0);
      -- pragma return_port_name Z
    begin
      return(Z);
    end;

    function PRIENC_UNS_ARG(A: UNSIGNED) 
        return UNSIGNED is
      variable Z: UNSIGNED(bit_width(A'length+1)-1 downto 0);
      -- pragma return_port_name Z
    begin
      return(Z);
    end;

    function PRIENC_STD_LOGIC_ARG(A: std_logic_vector)
             return  std_logic_vector is
      variable Z: std_logic_vector(bit_width(A'length+1)-1 downto 0);
      -- pragma return_port_name Z
    begin
      return(Z);
    end;

    function prienc (A: std_logic_vector) return INTEGER is
      constant A_msb: integer := A'length-1;
      variable A_norm: std_logic_vector(A_msb downto 0) := A;
      variable INDEX: integer;
    begin
      for i in A_msb downto 0 loop
   if (A_norm(i) = '1' ) then
	   return(i+1);
	elsif (A_norm(i) /= '0') then
      return(-(i+1));
	end if;
      end loop;
      return(0);  
    end prienc;

    function prienc_s(A: SIGNED) return SIGNED is
      -- pragma map_to_operator PRIENC_TC_OP
      -- pragma type_function PRIENC_TC_ARG
      -- pragma return_port_name Z
      constant A_width: NATURAL := A'length;
      constant Z_width: NATURAL := bit_width(A'length+1);
      variable AV: std_logic_vector(A_width-1 downto 0);
      variable Z: SIGNED(Z_width-1 downto 0);
      variable Y: SIGNED (Z_width-1 downto 0):= (others => 'X');  
      variable addr_int: integer;  
    begin
      -- pragma translate_off
      AV := std_logic_vector(A);
      addr_int := prienc(AV);
      if (addr_int < -1) then
        Z := Y;
      else
        Z := CONV_SIGNED(addr_int, Z_width);
      end if;  
      -- pragma translate_on
      return(Z);
    end;    

    function prienc_u(A: UNSIGNED) return UNSIGNED is
      -- pragma map_to_operator PRIENC_UNS_OP
      -- pragma type_function PRIENC_UNS_ARG
      -- pragma return_port_name Z
      constant A_width: NATURAL := A'length;
      constant Z_width: NATURAL := bit_width(A'length+1);
      variable AV: std_logic_vector(A_width-1 downto 0);
      variable Z: UNSIGNED(Z_width-1 downto 0);
      variable Y: UNSIGNED (Z_width-1 downto 0):= (others => 'X');  
      variable addr_int: integer;  
    begin
      -- pragma translate_off
      AV := std_logic_vector(A);
      addr_int := prienc(AV);
      if (addr_int < -1) then
        Z := Y;
      else
        Z := UNSIGNED(CONV_SIGNED(addr_int, Z_width));
      end if;  
      -- pragma translate_on
      return(Z);
    end;    

    function prienc_v(A: std_logic_vector) return std_logic_vector is
      -- pragma map_to_operator PRIENC_STD_LOGIC_OP
      -- pragma type_function PRIENC_STD_LOGIC_ARG
      -- pragma return_port_name Z
      constant Z_width: NATURAL := bit_width(A'length+1);
      variable Z: std_logic_vector(Z_width-1 downto 0);
      variable Y: std_logic_vector (Z_width-1 downto 0):= (others => 'X');  
      variable addr_int: integer;  
    begin
      -- pragma translate_off
      addr_int := prienc(A);
      if (addr_int < -1) then
        Z := Y;
      else
        Z := std_logic_vector(CONV_SIGNED(addr_int, Z_width));
      end if;  
      -- pragma translate_on
      return(Z);
    end;    

    function DWF_prienc(A: SIGNED; INDEX_width: NATURAL) return SIGNED is
      constant Z_prime_width : NATURAL := bit_width(A'length+1);
      variable Z: SIGNED(INDEX_width-1 downto 0);
      variable Z_prime: SIGNED(Z_prime_width-1 downto 0);
    begin
      Z_prime := prienc_s(A);
      if (INDEX_width > Z_prime_width ) then
        Z(Z_prime_width-1 downto 0) := Z_prime;
        Z(INDEX_width-1 downto Z_prime_width) := (others => '0');
      else
        Z := Z_prime(INDEX_width-1 downto 0);
      end if;
      return(Z);
    end;
    
    
    function DWF_prienc(A: UNSIGNED; INDEX_width: NATURAL) 
        return UNSIGNED is
      constant Z_prime_width : NATURAL := bit_width(A'length+1);
      variable Z: UNSIGNED(INDEX_width-1 downto 0);
      variable Z_prime: UNSIGNED(Z_prime_width-1 downto 0);
    begin
      Z_prime := prienc_u(A);
      if (INDEX_width > Z_prime_width ) then
        Z(Z_prime_width-1 downto 0) := Z_prime;
        Z(INDEX_width-1 downto Z_prime_width) := (others => '0');
      else
        Z := Z_prime(INDEX_width-1 downto 0);
      end if;
      return(Z);
    end;
    

    function DWF_prienc(A: std_logic_vector; INDEX_width: NATURAL) 
        return std_logic_vector is
      constant Z_prime_width : NATURAL := bit_width(A'length+1);
      variable Z: std_logic_vector(INDEX_width-1 downto 0);
      variable Z_prime: std_logic_vector(Z_prime_width-1 downto 0);
    begin
      Z_prime := prienc_v(A);
      if (INDEX_width > Z_prime_width ) then
        Z(Z_prime_width-1 downto 0) := Z_prime;
        Z(INDEX_width-1 downto Z_prime_width) := (others => '0');
      else
        Z := Z_prime(INDEX_width-1 downto 0);
      end if;
      return(Z);
    end;
    

    function DW_prienc(A: SIGNED; INDEX_width: NATURAL) return SIGNED is
      variable Z: SIGNED(INDEX_width-1 downto 0);
    begin
      Z := DWF_prienc(A, INDEX_width);
      return(Z);
    end;

    function DW_prienc(A: UNSIGNED; INDEX_width: NATURAL)
        return UNSIGNED is
      variable Z: UNSIGNED(INDEX_width-1 downto 0);
    begin
      Z := DWF_prienc(A, INDEX_width);
      return(Z);
    end;

    function DW_prienc(A: std_logic_vector; INDEX_width: NATURAL)
        return std_logic_vector is
      variable Z: std_logic_vector(INDEX_width-1 downto 0);
    begin
      Z := DWF_prienc(A, INDEX_width);
      return(Z);
    end;


  -- Content from file, DW01_bsh.vhdpp

    function SH_STD_STD_ARG(A: std_logic_vector; SH: std_logic_vector)
			return std_logic_vector is
      variable Z : std_logic_vector(A'length-1 downto 0);
      -- pragma return_port_name Z
    begin
      return( Z );
    end;

    function DW_bsh_STD(ARG: std_logic_vector; COUNT: std_logic_vector) 
                  return std_logic_vector is
      constant COUNT_msb: NATURAL := COUNT'length - 1;
      variable COUNT_norm: std_logic_vector(COUNT_msb downto 0) := COUNT;
      constant ARG_msb: NATURAL := ARG'length-1;
      variable ARG_norm: std_logic_vector(ARG_msb downto 0) := ARG;
      subtype rtype is std_logic_vector(ARG_msb downto 0);
      variable result, temp: rtype;
    begin
      if (COUNT(COUNT'left) = 'X') then
         result := (others => 'X');
         return (result);
      end if;
      result := ARG_norm;
      for i in 0 to COUNT_msb loop
	  if COUNT_norm(i) = '1' then
	    if 2**i <= ARG_msb then
	      temp(ARG_msb downto 2**i) := 
	          result((ARG_msb-2**i) downto 0);
	      temp(2**i-1 downto 0) := 
	          result(ARG_msb downto (ARG_msb-2**i)+1);
	      result := temp;
	    end if;
	  end if;
      end loop;
      return result;
    end;

    function DWF_bsh(A: SIGNED; SH: UNSIGNED) return SIGNED is
      -- pragma map_to_operator BSH_TC_OP
      -- pragma type_function SH_TC_UNS_ARG
      -- pragma return_port_name Z
      constant A_width: NATURAL := A'length;
      constant SH_width: NATURAL := SH'length;      
      variable Z: SIGNED(A_width-1 downto 0);
    begin
      return(SIGNED(DW_bsh_STD(std_logic_vector(A), 
                                 std_logic_vector(SH))));
    end;
    
    function DWF_bsh(A: UNSIGNED; SH: UNSIGNED) return UNSIGNED is
      -- pragma map_to_operator BSH_UNS_OP
      -- pragma type_function SH_UNS_UNS_ARG
      -- pragma return_port_name Z
      constant A_width: NATURAL := A'length;      
      constant SH_width: NATURAL := SH'length;            
    begin
      return(UNSIGNED(DW_bsh_STD(std_logic_vector(A), 
                               std_logic_vector(SH))));
		
    end;
    
    function DWF_bsh(A: std_logic_vector; SH: std_logic_vector)
			return std_logic_vector is
      -- pragma map_to_operator BSH_UNS_OP
      -- pragma type_function SH_STD_STD_ARG
      -- pragma return_port_name Z
      constant A_width: NATURAL := A'length;      
      constant SH_width: NATURAL := SH'length;            
    begin
      return(DW_bsh_STD(A, SH));
		
    end;

    function DW_bsh(A: SIGNED; SH: UNSIGNED) return SIGNED is
      -- pragma map_to_operator BSH_TC_OP
      -- pragma type_function SH_TC_UNS_ARG
      -- pragma return_port_name Z
    begin
      return(DWF_bsh(A,SH));
    end;

    function DW_bsh(A: UNSIGNED; SH: UNSIGNED) return UNSIGNED is
      -- pragma map_to_operator BSH_UNS_OP
      -- pragma type_function SH_UNS_UNS_ARG
      -- pragma return_port_name Z
    begin
      return(DWF_bsh(A,SH));
    end;

    function DW_bsh(A: std_logic_vector; SH: std_logic_vector)
                   return std_logic_vector is
      -- pragma map_to_operator BSH_UNS_OP
      -- pragma type_function SH_STD_STD_ARG
      -- pragma return_port_name Z
    begin
      return(DWF_bsh(A, SH));
    end;


  -- Content from file, DW_shifter.vhdpp

    function SHIFTER_TC_TC_ARG(data_in,sh: SIGNED; sh_mode: std_logic) return SIGNED is
      variable Z: SIGNED (data_in'length-1 downto 0);
      -- pragma return_port_name Z
    begin
      return(Z);
    end;

    function SHIFTER_TC_UNS_ARG(data_in: SIGNED; sh: UNSIGNED; sh_mode: std_logic) return SIGNED is
      variable Z: SIGNED (data_in'length-1 downto 0);
      -- pragma return_port_name Z
    begin
      return(Z);
    end;
 
    function SHIFTER_UNS_UNS_ARG(data_in,sh: UNSIGNED; sh_mode: std_logic) return UNSIGNED is
      variable Z: UNSIGNED (data_in'length-1 downto 0);
      -- pragma return_port_name Z
    begin
      return(Z);
    end;

    function SHIFTER_UNS_TC_ARG(data_in: UNSIGNED;sh: SIGNED; sh_mode: std_logic) return UNSIGNED is
      variable Z: UNSIGNED (data_in'length-1 downto 0);
      -- pragma return_port_name Z
    begin
      return(Z);
    end;

   function BSHL(ARG: std_logic_vector; COUNT: UNSIGNED) return std_logic_vector is
      constant COUNT_msb: NATURAL := COUNT'length - 1;
      variable COUNT_norm: UNSIGNED(COUNT_msb downto 0) := COUNT;
      constant ARG_msb: NATURAL := ARG'length-1;
      variable ARG_norm: std_logic_vector(ARG_msb downto 0) := ARG;
      subtype rtype is std_logic_vector(ARG_msb downto 0);
      variable result, temp: rtype;
    begin
      result := ARG_norm;
      for i in 0 to COUNT_msb loop
     if COUNT(i) = '1' then
         temp(ARG_msb downto ((2**i) mod ARG'length)) := 
             result((ARG_msb-((2**i) mod ARG'length)) downto 0);
         temp(((2**i) mod ARG'length)-1 downto 0) := 
             result(ARG_msb downto (ARG_msb-((2**i) mod ARG'length))+1);
         result := temp;
     end if;
      end loop;
      return result;
    end;

   function BSHR(ARG: std_logic_vector; COUNT: UNSIGNED) return std_logic_vector is
      constant COUNT_msb: NATURAL := COUNT'length - 1;
      variable COUNT_norm: UNSIGNED(COUNT_msb downto 0) := COUNT;
      constant ARG_msb: NATURAL := ARG'length-1;
      variable ARG_norm: std_logic_vector(ARG_msb downto 0) := ARG;
      subtype rtype is std_logic_vector(ARG_msb downto 0);
      variable result, temp: rtype;
    begin
      result := ARG_norm;
      for i in 0 to COUNT_msb loop
     if COUNT_norm(i) = '1' then
         temp((ARG_msb-((2**i) mod ARG'length)) downto 0):=
             result(ARG_msb downto ((2**i) mod ARG'length));
         temp(ARG_msb downto (ARG_msb-((2**i) mod ARG'length))+1):=
             result(((2**i) mod ARG'length)-1 downto 0);
         result := temp;
     end if;
      end loop;
           result := temp;
      return result;
    end;

    function DWF_shifter(data_in: UNSIGNED; sh: UNSIGNED; sh_mode: std_logic) return UNSIGNED is
      -- pragma map_to_operator SHIFTER_UNS_UNS_OP
      -- pragma type_function SHIFTER_UNS_UNS_ARG
      -- pragma return_port_name Z
      constant data_in_msb: NATURAL := data_in'length-1;
      variable data_in_norm: UNSIGNED(data_in_msb downto 0) := data_in;
      constant sh_msb: NATURAL := sh'length-1;
      variable sh_norm: UNSIGNED(sh_msb downto 0) := sh;
    begin
      if sh_mode = '1' then -- arithmatic shift
          return(SHL(data_in_norm,sh_norm));
      else                  -- barrel shift
          return(UNSIGNED(BSHL(std_logic_vector(data_in_norm),sh_norm)));
      end if;
    end;

    function DWF_shifter(data_in: SIGNED; sh: UNSIGNED; sh_mode: std_logic) return SIGNED is
      -- pragma map_to_operator SHIFTER_TC_UNS_OP
      -- pragma type_function SHIFTER_TC_UNS_ARG
      -- pragma return_port_name Z
      constant data_in_msb: NATURAL := data_in'length-1;
      variable data_in_norm: SIGNED(data_in_msb downto 0) := data_in;
      constant sh_msb: NATURAL := sh'length-1;
      variable sh_norm: UNSIGNED(sh_msb downto 0) := sh;
    begin
      if sh_mode = '1' then -- arithmatic shift
          return(SHL(data_in_norm,sh_norm));
      else                  -- barrel shift
          return(SIGNED(BSHL(std_logic_vector(data_in_norm),sh_norm)));
      end if;
    end;

    function DWF_shifter(data_in: UNSIGNED; SH: SIGNED; sh_mode: std_logic) return UNSIGNED is
      -- pragma map_to_operator SHIFTER_UNS_TC_OP
      -- pragma type_function SHIFTER_UNS_TC_ARG
      -- pragma return_port_name Z
      constant data_in_msb: NATURAL := data_in'length-1;
      variable data_in_norm: UNSIGNED(data_in_msb downto 0) := data_in;
      constant sh_msb: NATURAL := sh'length-1;
      variable sh_norm: SIGNED(sh_msb downto 0) := sh;
      variable SHMAG: SIGNED(sh_msb downto 0);
    begin
      -- signed shift coefficient - perform left and right shifts on A
      SHMAG := ABS(SIGNED(sh_norm));  -- absolute value of shift coefficient
      if sh_mode = '1' then -- arithmatic shift
          if sh(sh_msb) = '0' then  -- left shift
            return(SHL(data_in_norm,UNSIGNED(SHMAG)));
          else                   -- right shift
            return(SHR(data_in_norm,UNSIGNED(SHMAG)));
          end if;
      else                  -- barrel shift
          if sh(sh_msb) = '0' then  -- left shift
            return(UNSIGNED(BSHL(std_logic_vector(data_in_norm),UNSIGNED(SHMAG))));
          else                   -- right shift
            return(UNSIGNED(BSHR(std_logic_vector(data_in_norm),UNSIGNED(SHMAG))));
          end if;
      end if;
    end;

    function DWF_shifter(data_in: SIGNED; SH: SIGNED; sh_mode: std_logic) return SIGNED is
      -- pragma map_to_operator SHIFTER_TC_TC_OP
      -- pragma type_function SHIFTER_TC_TC_ARG
      -- pragma return_port_name Z
      constant data_in_msb: NATURAL := data_in'length-1;
      variable data_in_norm: SIGNED(data_in_msb downto 0) := data_in;
      constant sh_msb: NATURAL := sh'length-1;
      variable sh_norm: SIGNED(sh_msb downto 0) := sh;
      variable SHMAG: SIGNED(sh_msb downto 0);
    begin
      -- signed shift coefficient - perform left and right shifts on A
      SHMAG := ABS(sh_norm);  -- absolute value of shift coefficient
      if sh_mode = '1' then -- arithmatic shift
          if sh(sh_msb) = '0' then  -- left shift
            return(SHL(data_in_norm,UNSIGNED(SHMAG)));
          else                   -- right shift
            return(SHR(data_in_norm,UNSIGNED(SHMAG)));
          end if;
      else                  -- barrel shift
          if sh(sh_msb) = '0' then  -- left shift
            return(SIGNED(BSHL(std_logic_vector(data_in_norm),UNSIGNED(SHMAG))));
          else                   -- right shift
            return(SIGNED(BSHR(std_logic_vector(data_in_norm),UNSIGNED(SHMAG))));
          end if;
      end if;
    end;
 function shift_uns_uns(
   arg         : UNSIGNED;
   shift        : UNSIGNED;
   sh_mode      : std_logic;
   padded_value : std_logic)
   return UNSIGNED is
     
     constant control_msb: INTEGER := shift'length - 1;
     variable control: UNSIGNED (control_msb downto 0);
     constant result_msb: INTEGER := arg'length-1;
     subtype rtype is UNSIGNED (result_msb downto 0);
     variable result, temp: rtype;
   begin
     control := shift;
     if (control(0) = 'X') then
       result := rtype'(others => 'X');
       return result;
     else
       if(sh_mode = '1') then
         result := arg;
         for i in 0 to control_msb loop
           if control(i) = '1' then
             temp := rtype'(others => padded_value);
             if 2**i <= result_msb then
               temp(result_msb downto 2**i) := 
                 result(result_msb - 2**i downto 0);
             end if;
             result := temp;
           end if;
         end loop;
         return result;
       else
         result := DWF_bsh(UNSIGNED(arg), UNSIGNED(shift));
         return result;
       end if;
     end if;
   end;


 function shift_tc_uns(
   arg         : UNSIGNED;
   shift        : SIGNED;
   sh_mode      : std_logic;
   padded_value : std_logic)
   return UNSIGNED is

     constant control_msb  : INTEGER := shift'length - 1;
     variable control      : SIGNED (control_msb downto 0);
     constant result_msb   : INTEGER := arg'length-1;
     subtype  rtype is UNSIGNED (result_msb downto 0);
     variable result, temp : rtype;
     variable sign_bit: STD_ULOGIC;
   begin

     if (control(0) = 'X') then
       result := rtype'(others => 'X');
       return result;
     else
       if(sh_mode = '1') then
         if(shift(control_msb) = '0') then
           result := arg;
           control := shift;
           for i in 0 to control_msb loop
             if control(i) = '1' then
               temp := rtype'(others => padded_value);
               if 2**i <= result_msb then
                 temp(result_msb downto 2**i) := 
                   result(result_msb - 2**i downto 0);
               end if;
               result := temp;
             end if;
           end loop;
         else
           result := arg;
           control := ABS(SIGNED(shift));
           for i in 0 to control_msb loop
             if control(i) = '1' then
               temp := rtype'(others => padded_value);
               if 2**i <= result_msb then
                 temp(result_msb - 2**i downto 0) := 
                   result(result_msb downto 2**i);
               end if;
               result := temp;
             end if;
           end loop;
         end if;
         return result;
       else
         result := DWF_bsh(UNSIGNED(arg), UNSIGNED(shift));
         return result;
       end if;
     end if;
   end;

 function shift_uns_tc(
   arg         : SIGNED;
   shift        : UNSIGNED;
   sh_mode      : std_logic;
   padded_value : std_logic)
   return SIGNED is

     constant control_msb  : INTEGER := shift'length - 1;
     variable control      : UNSIGNED (control_msb downto 0);
     constant result_msb   : INTEGER := arg'length-1;
     subtype  rtype is SIGNED (result_msb downto 0);
     variable result, temp : rtype;
     variable sign_bit: STD_ULOGIC;
   begin
     control := shift;

     if (control(0) = 'X') then
       result := rtype'(others => 'X');
       return result;
     else
       if(sh_mode = '1') then
           result := arg;
           for i in 0 to control_msb loop
             if control(i) = '1' then
               temp := rtype'(others => padded_value);
               if 2**i <= result_msb then
                 temp(result_msb downto 2**i) := 
                   result(result_msb - 2**i downto 0);
               end if;
               result := temp;
             end if;
           end loop;
         return result;
       else
         result := DWF_bsh(SIGNED(arg), UNSIGNED(shift));
         return result;
       end if;
     end if;
   end;


  -- Content from file, DW_minmax.vhdpp

  --  Type propagation functions used internally for component inferencing

  function MIN_UNSIGNED_ARG (a : unsigned; num_inputs : integer)
    return unsigned is
    constant output_width : integer := a'length/num_inputs;
    variable value : unsigned(output_width-1 downto 0);
    -- pragma return_port_name value
  begin
    return value;
  end MIN_UNSIGNED_ARG;

  function MIN_SIGNED_ARG (a : signed; num_inputs : integer)
    return signed is
    constant output_width : integer := a'length/num_inputs;
    variable value : signed(output_width-1 downto 0);
    -- pragma return_port_name value
  begin
    return value;
  end MIN_SIGNED_ARG;

  function MAX_UNSIGNED_ARG (a : unsigned; num_inputs : integer)
    return unsigned is
    constant output_width : integer := a'length/num_inputs;
    variable value : unsigned(output_width-1 downto 0);
    -- pragma return_port_name value
  begin
    return value;
  end MAX_UNSIGNED_ARG;

  function MAX_SIGNED_ARG (a : signed; num_inputs : integer)
    return signed is
    constant output_width : integer := a'length/num_inputs;
    variable value : signed(output_width-1 downto 0);
    -- pragma return_port_name value
  begin
    return value;
  end MAX_SIGNED_ARG;

  -- Function definitions

  function DWF_min (a : unsigned; num_inputs : natural) return unsigned is
    -- pragma map_to_operator MIN_UNS_OP
    -- pragma type_function MIN_UNSIGNED_ARG
    -- pragma return_port_name value
    constant width : natural := A'length/num_inputs;
    constant ind_width : natural := bit_width(num_inputs);
    variable value : unsigned(width-1 downto 0);
    variable index : std_logic_vector(ind_width-1 downto 0);
  begin
    MIN_UNSIGNED (a, value, index);
    return value;
  end DWF_min;

  function DWF_min (a : signed; num_inputs : natural) return signed is
    -- pragma map_to_operator MIN_TC_OP
    -- pragma type_function MIN_SIGNED_ARG
    -- pragma return_port_name value
    constant width : natural := A'length/num_inputs;
    constant ind_width : natural := bit_width(num_inputs);
    variable value : signed(width-1 downto 0);
    variable index : std_logic_vector(ind_width-1 downto 0);
  begin
    MIN_SIGNED (a, value, index);
    return value;
  end DWF_min;

  function DWF_max (a : unsigned; num_inputs : natural) return unsigned is
    -- pragma map_to_operator MAX_UNS_OP
    -- pragma type_function MAX_UNSIGNED_ARG
    -- pragma return_port_name value
    constant width : natural := A'length/num_inputs;
    constant ind_width : natural := bit_width(num_inputs);
    variable value : unsigned(width-1 downto 0);
    variable index : std_logic_vector(ind_width-1 downto 0);
  begin
    MAX_UNSIGNED (a, value, index);
    return value;
  end DWF_max;

  function DWF_max (a : signed; num_inputs : natural) return signed is
    -- pragma map_to_operator MAX_TC_OP
    -- pragma type_function MAX_SIGNED_ARG
    -- pragma return_port_name value
    constant width : natural := A'length/num_inputs;
    constant ind_width : natural := bit_width(num_inputs);
    variable value : signed(width-1 downto 0);
    variable index : std_logic_vector(ind_width-1 downto 0);
  begin
    MAX_SIGNED (a, value, index);
    return value;
  end DWF_max;

  -- Internal procedures (not synthesizable)
  procedure MIN_UNSIGNED (a : in unsigned;
                          value : out unsigned;
                          index : out std_logic_vector) is
    constant a_msb : natural := a'length-1;
    variable a_norm : unsigned(a_msb downto 0) := a;
    constant width : natural := value'length;
    constant ind_width : natural := index'length;
    constant num_inputs : natural := a'length/width;
    type input_vector is array (num_inputs-1 downto 0)
      of unsigned(width-1 downto 0);
    variable a_v : input_vector;
    variable value_v : unsigned(width-1 downto 0);
    variable index_v : std_logic_vector(ind_width-1 downto 0);
  begin
    -- pragma translate_off
    if Is_X(std_logic_vector(a)) then
      value_v := (others => 'X');
      index_v := (others => 'X');
    else
      for k in 0 to num_inputs-1 loop
        a_v(k) := a_norm((k+1)*width-1 downto k*width);
      end loop;
      value_v := (others => '1');
      index_v := (others => '0');
      for k in 0 to num_inputs-1 loop
        if a_v(k) < value_v then
          value_v := a_v(k);
          index_v := dw_conv_std_logic_vector(k, ind_width);
        end if;
      end loop;
    end if;
    value := value_v;
    index := index_v;
    -- pragma translate_on
  end MIN_UNSIGNED;

  procedure MIN_SIGNED (a : in signed;
                        value : out signed;
                        index : out std_logic_vector) is
    constant a_msb : natural := a'length-1;
    variable a_norm : signed(a_msb downto 0) := a;
    constant width : natural := value'length;
    constant ind_width : natural := index'length;
    constant num_inputs : natural := a'length/width;
    type input_vector is array (num_inputs-1 downto 0)
      of signed(width-1 downto 0);
    variable a_v : input_vector;
    variable value_v : signed(width-1 downto 0);
    variable index_v : std_logic_vector(ind_width-1 downto 0);
  begin
    -- pragma translate_off
    if Is_X(std_logic_vector(a)) then
      value_v := (others => 'X');
      index_v := (others => 'X');
    else
      for k in 0 to num_inputs-1 loop
        a_v(k) := a_norm((k+1)*width-1 downto k*width);
      end loop;
      value_v := '0' & (width-2 downto 0 => '1');
      index_v := (others => '0');
      for k in 0 to num_inputs-1 loop
        if a_v(k) < value_v then
          value_v := a_v(k);
          index_v := dw_conv_std_logic_vector(k, ind_width);
        end if;
      end loop;
    end if;
    value := value_v;
    index := index_v;
    -- pragma translate_on
  end MIN_SIGNED;

  procedure MAX_UNSIGNED (a : in unsigned;
                          value : out unsigned;
                          index : out std_logic_vector) is
    constant a_msb : natural := a'length-1;
    variable a_norm : unsigned(a_msb downto 0) := a;
    constant width : natural := value'length;
    constant ind_width : natural := index'length;
    constant num_inputs : natural := a'length/width;
    type input_vector is array (num_inputs-1 downto 0)
      of unsigned(width-1 downto 0);
    variable a_v : input_vector;
    variable value_v : unsigned(width-1 downto 0);
    variable index_v : std_logic_vector(ind_width-1 downto 0);
  begin
    -- pragma translate_off
    if Is_X(std_logic_vector(a)) then
      value_v := (others => 'X');
      index_v := (others => 'X');
    else
      for k in 0 to num_inputs-1 loop
        a_v(k) := a_norm((k+1)*width-1 downto k*width);
      end loop;
      value_v := (others => '0');
      index_v := (others => '0');
      for k in 0 to num_inputs-1 loop
        if a_v(k) >= value_v then
          value_v := a_v(k);
          index_v := dw_conv_std_logic_vector(k, ind_width);
        end if;
      end loop;
    end if;
    value := value_v;
    index := index_v;
    -- pragma translate_on
  end MAX_UNSIGNED;

  procedure MAX_SIGNED (a : in signed;
                        value : out signed;
                        index : out std_logic_vector) is
    constant a_msb : natural := a'length-1;
    variable a_norm : signed(a_msb downto 0) := a;
    constant width : natural := value'length;
    constant ind_width : natural := index'length;
    constant num_inputs : natural := a'length/width;
    type input_vector is array (num_inputs-1 downto 0)
      of signed(width-1 downto 0);
    variable a_v : input_vector;
    variable value_v : signed(width-1 downto 0);
    variable index_v : std_logic_vector(ind_width-1 downto 0);
  begin
    -- pragma translate_off
    if Is_X(std_logic_vector(a)) then
      value_v := (others => 'X');
      index_v := (others => 'X');
    else
      for k in 0 to num_inputs-1 loop
        a_v(k) := a_norm((k+1)*width-1 downto k*width);
      end loop;
      value_v := '1' & (width-2 downto 0 => '0');
      index_v := (others => '0');
      for k in 0 to num_inputs-1 loop
        if a_v(k) >= value_v then
          value_v := a_v(k);
          index_v := dw_conv_std_logic_vector(k, ind_width);
        end if;
      end loop;
    end if;
    value := value_v;
    index := index_v;
    -- pragma translate_on
  end MAX_SIGNED;


  -- Content from file, DW_bin2gray.vhdpp

   function BIN2GRAY_STD_LOGIC_ARG (B : std_logic_vector)
            return std_logic_vector is
     variable G : std_logic_vector(B'length-1 downto 0);
     -- pragma return_port_name G
   begin
     return G;
   end BIN2GRAY_STD_LOGIC_ARG;

   function DWF_bin2gray (B : std_logic_vector)
            return std_logic_vector is
     -- pragma map_to_operator BIN2GRAY_STD_LOGIC_OP
     -- pragma type_function BIN2GRAY_STD_LOGIC_ARG
     -- pragma return_port_name G
     variable b_v : std_logic_vector(B'length downto 0);
     variable g_v : std_logic_vector(B'length-1 downto 0);
   begin
     -- pragma translate_off
     b_v := '0' & B;
     g_v := B xor b_v(B'length downto 1);
     return g_v;
     -- pragma translate_on
   end DWF_bin2gray;


  -- Content from file, DW_gray2bin.vhdpp

   function GRAY2BIN_STD_LOGIC_ARG (G : std_logic_vector) 
            return std_logic_vector is
     variable B : std_logic_vector(G'length-1 downto 0);
     -- pragma return_port_name B
   begin
     return B;
   end GRAY2BIN_STD_LOGIC_ARG;

   function DWF_gray2bin (G : std_logic_vector) 
            return std_logic_vector is
     -- pragma map_to_operator GRAY2BIN_STD_LOGIC_OP
     -- pragma type_function GRAY2BIN_STD_LOGIC_ARG
     -- pragma return_port_name B
     variable g_v : std_logic_vector(G'length-1 downto 0);
     variable b_v : std_logic_vector(G'length downto 0);
   begin
     -- pragma translate_off
     g_v := G;
     b_v(G'length) := '0';
     for i in G'length-1 downto 0 loop
       b_v(i) := g_v(i) xor b_v(i+1);
     end loop;
     return b_v(G'length-1 downto 0);
     -- pragma translate_on
   end DWF_gray2bin;


  -- Content from file, DW_inc_gray.vhdpp

   function INC_GRAY_STD_LOGIC_ARG (A  : std_logic_vector;
                                    CI : std_logic)
            return std_logic_vector is
     variable Z : std_logic_vector(A'length-1 downto 0);
     -- pragma return_port_name Z
   begin
       return Z;
   end INC_GRAY_STD_LOGIC_ARG;

   function DWF_inc_gray (A  : std_logic_vector;
                          CI : std_logic)
            return std_logic_vector is
     -- pragma map_to_operator INC_GRAY_STD_LOGIC_OP
     -- pragma type_function INC_GRAY_STD_LOGIC_ARG
     -- pragma return_port_name Z
     variable a_v  : std_logic_vector(A'length-1 downto 0);
     variable ab_v : std_logic_vector(A'length downto 0);
     variable ci_v : std_logic_vector(A'length-1 downto 0);
     variable zu_v : unsigned(A'length-1 downto 0);
     variable zb_v : std_logic_vector(A'length downto 0);
     variable z_v  : std_logic_vector(A'length-1 downto 0);
   begin
     -- pragma translate_off
     a_v := A;
     ci_v := (others => '0');
     ci_v(0) := CI;
     ab_v(A'length) := '0';
     for i in A'length-1 downto 0 loop
       ab_v(i) := a_v(i) xor ab_v(i+1);
     end loop;
     zu_v := unsigned(ab_v(A'length-1 downto 0)) + unsigned(ci_v);
     zb_v := '0' & std_logic_vector(zu_v);
     z_v := zb_v(A'length-1 downto 0) xor zb_v(A'length downto 1);
     return z_v;
     -- pragma translate_on
   end DWF_inc_gray;


  -- Content from file, DW_lod.vhdpp

    function LOD_ENC_TC_ARG(A: SIGNED) return SIGNED is
      variable Z: SIGNED(bit_width(A'length) downto 0);
      -- pragma return_port_name Z
    begin
      return(Z);
    end;

    function LOD_DEC_TC_ARG(A: SIGNED) return SIGNED is
      variable Z: SIGNED(A'length-1 downto 0);
      -- pragma return_port_name Z
    begin
      return(Z);
    end;

    function LOD_ENC_UNS_ARG(A: UNSIGNED) return UNSIGNED is
      variable Z: UNSIGNED(bit_width(A'length) downto 0);
      -- pragma return_port_name Z
    begin
      return(Z);
    end;

    function LOD_DEC_UNS_ARG(A: UNSIGNED) return UNSIGNED is
      variable Z: UNSIGNED(A'length-1 downto 0);
      -- pragma return_port_name Z
    begin
      return(Z);
    end;

    function LOD_ENC_STD_LOGIC_ARG(A: std_logic_vector) return  std_logic_vector is
      variable Z: std_logic_vector(bit_width(A'length) downto 0);
      -- pragma return_port_name Z
    begin
      return(Z);
    end;

    function LOD_DEC_STD_LOGIC_ARG(A: std_logic_vector) return  std_logic_vector is
      variable Z: std_logic_vector(A'length-1 downto 0);
      -- pragma return_port_name Z
    begin
      return(Z);
    end;

    -- leading zeroes/ones detector, encoded output
    -- Note: -1 means no bidder, -2 means X encountered first
    function lzod_enc (detect_1 : integer; a : std_logic_vector) return integer is
      variable enc : integer;
      constant neg2 :  integer := -2;
    begin
      enc := -1; -- by default, set to nothing found
      for i in a'length-1 downto 0 loop
        if (((detect_1 = 0) and (a(i) = '1')) or
            ((detect_1 = 1) and (a(i) = '0'))) then
          enc := a'length - i - 1;
          return ( enc );  -- return when first desired bit value found
        elsif (((detect_1 = 0) and (a(i) = 'X')) or
            ((detect_1 = 1) and (a(i) = 'X'))) then
          return ( neg2 );  -- when found an "X" first return a negative number
        end if;
      end loop;
      return enc;
    end lzod_enc;


    -- leading zeroes/ones detector, decoded output
    -- Note: -1 means no bidder, -2 means X encountered first
    function lzod (detect_1 : integer; a: std_logic_vector) return std_logic_vector is
      variable enc_int : integer;
      variable dec_v   : std_logic_vector(a'length-1 downto 0);
      variable Y:  std_logic_vector(a'length-1 downto 0):= (others => 'X');
    begin
      dec_v   := (others => '0');  -- default, no bidders get decode of all 0's
      enc_int := lzod_enc(detect_1, a);

      if (enc_int >= 0) then
        dec_v(a'length - enc_int - 1) := '1';
      elsif (enc_int = -2) then
        return ( Y );  -- return if "X" resulted from lzod (encoder)
      end if;
      return(dec_v);
    end lzod;

    function DWF_lod_enc(A: SIGNED) return SIGNED is
      -- pragma map_to_operator LOD_ENC_TC_OP
      -- pragma type_function LOD_ENC_TC_ARG
      -- pragma return_port_name Z
      constant A_width: NATURAL := A'length;
      constant ENC_width: NATURAL := bit_width(A'length);
      variable AV: std_logic_vector(A_width-1 downto 0);
      variable Z: SIGNED(ENC_width downto 0) ;
      variable Y: SIGNED (ENC_width downto 0):= (others => 'X');
      variable enc_int: integer;  
    begin
      AV := TO_UX01(std_logic_vector(A));
      enc_int := lzod_enc(1, AV);
      if (enc_int = -2) then
        return(Y);
      else
        return(CONV_SIGNED(enc_int, ENC_width+1));
      end if;
    end;    
    
    function DWF_lod_enc(A: UNSIGNED) return UNSIGNED is
      -- pragma map_to_operator LOD_ENC_UNS_OP
      -- pragma type_function LOD_ENC_UNS_ARG
      -- pragma return_port_name Z
      constant A_width: NATURAL := A'length;
      constant ENC_width: NATURAL := bit_width(A'length);
      variable AV: std_logic_vector(A_width-1 downto 0);
      variable Z: UNSIGNED(ENC_width downto 0);
      variable Y: UNSIGNED (ENC_width downto 0):= (others => 'X');
      variable enc_int: integer;  
    begin
      AV := TO_UX01(std_logic_vector(A));
      enc_int := lzod_enc(1, AV);
      if (ENC_int = -2) then
        return(Y);
      else
        return(CONV_UNSIGNED(enc_int, ENC_width+1));
      end if;
    end;    

    function DWF_lod_enc(A: std_logic_vector) return std_logic_vector is
      -- pragma map_to_operator LOD_ENC_STD_LOGIC_OP
      -- pragma type_function LOD_ENC_STD_LOGIC_ARG
      -- pragma return_port_name Z
      constant A_width: NATURAL := A'length;
      constant ENC_width: NATURAL := bit_width(A'length);
      variable AV: std_logic_vector(A_width-1 downto 0);
      variable Z: std_logic_vector(ENC_width downto 0);
      variable Y:  std_logic_vector(ENC_width downto 0):= (others => 'X');
      variable enc_int: integer;  
    begin
      AV := TO_UX01(std_logic_vector(A));
      enc_int := lzod_enc(1, AV);
      if (enc_int = -2) then
        return(Y);
      else
        return(std_logic_vector(CONV_UNSIGNED(enc_int, ENC_width+1)));
      end if;
    end;  

    function DWF_lod(A: SIGNED) return SIGNED is
      -- pragma map_to_operator LOD_DEC_TC_OP
      -- pragma type_function LOD_DEC_TC_ARG
      -- pragma return_port_name Z
      constant A_width: NATURAL := A'length;
      variable AV: std_logic_vector(A_width-1 downto 0);
      variable Z: SIGNED(A_width-1 downto 0) ;
      variable Y: SIGNED(A_width-1 downto 0):= (others => 'X');
      variable dec_v: std_logic_vector(A_width-1 downto 0);  
    begin
      AV := TO_UX01(std_logic_vector(A));
      dec_v := lzod(1, AV);
      if (dec_v(0) = 'X') then
        return(Y);
      else
        return(CONV_SIGNED(signed(dec_v),A_width));
      end if;
    end;    
    
    function DWF_lod(A: UNSIGNED) return UNSIGNED is
      -- pragma map_to_operator LOD_DEC_UNS_OP
      -- pragma type_function LOD_DEC_UNS_ARG
      -- pragma return_port_name Z
      constant A_width: NATURAL := A'length;
      variable AV: std_logic_vector(A_width-1 downto 0);
      variable Z: UNSIGNED(A_width-1 downto 0);
      variable Y: UNSIGNED (A_width-1 downto 0):= (others => 'X');
      variable dec_v: std_logic_vector(A_width-1 downto 0);  
    begin
      AV := TO_UX01(std_logic_vector(A));
      dec_v := lzod(1, AV);
      if (dec_v(0) = 'X') then
        return(Y);
      else
        return(CONV_UNSIGNED(UNSIGNED(dec_v),A_width));
      end if;
    end;    

    function DWF_lod(A: std_logic_vector) return std_logic_vector is
      -- pragma map_to_operator LOD_DEC_STD_LOGIC_OP
      -- pragma type_function LOD_DEC_STD_LOGIC_ARG
      -- pragma return_port_name Z
      constant A_width: NATURAL := A'length;
      variable AV: std_logic_vector(A_width-1 downto 0);
      variable Z: std_logic_vector(A_width-1 downto 0);
      variable Y: std_logic_vector(A_width-1 downto 0):= (others => 'X');
      variable dec_v: std_logic_vector(A_width-1 downto 0);  
    begin
      AV := TO_UX01(std_logic_vector(A));
      dec_v := lzod(1, AV);
      if (dec_v(0) = 'X') then
        return(Y);
      else
        return(dec_v);
      end if;
    end;  


  -- Content from file, DW_lzd.vhdpp

    function LZD_ENC_TC_ARG(A: SIGNED) return SIGNED is
      variable Z: SIGNED(bit_width(A'length) downto 0);
      -- pragma return_port_name Z
    begin
      return(Z);
    end;

    function LZD_DEC_TC_ARG(A: SIGNED) return SIGNED is
      variable Z: SIGNED(A'length-1 downto 0);
      -- pragma return_port_name Z
    begin
      return(Z);
    end;

    function LZD_ENC_UNS_ARG(A: UNSIGNED) return UNSIGNED is
      variable Z: UNSIGNED(bit_width(A'length) downto 0);
      -- pragma return_port_name Z
    begin
      return(Z);
    end;

    function LZD_DEC_UNS_ARG(A: UNSIGNED) return UNSIGNED is
      variable Z: UNSIGNED(A'length-1 downto 0);
      -- pragma return_port_name Z
    begin
      return(Z);
    end;

    function LZD_ENC_STD_LOGIC_ARG(A: std_logic_vector) return  std_logic_vector is
      variable Z: std_logic_vector(bit_width(A'length) downto 0);
      -- pragma return_port_name Z
    begin
      return(Z);
    end;

    function LZD_DEC_STD_LOGIC_ARG(A: std_logic_vector) return  std_logic_vector is
      variable Z: std_logic_vector(A'length-1 downto 0);
      -- pragma return_port_name Z
    begin
      return(Z);
    end;


    function DWF_lzd_enc(A: SIGNED) return SIGNED is
      -- pragma map_to_operator LZD_ENC_TC_OP
      -- pragma type_function LZD_ENC_TC_ARG
      -- pragma return_port_name Z
      constant A_width: NATURAL := A'length;
      constant ENC_width: NATURAL := bit_width(A'length);
      variable AV: std_logic_vector(A_width-1 downto 0);
      variable Z: SIGNED(ENC_width downto 0) ;
      variable Y: SIGNED (ENC_width downto 0):= (others => 'X');
      variable enc_int: integer;  
    begin
      AV := TO_UX01(std_logic_vector(A));
      enc_int := lzod_enc(0, AV);
      if (enc_int = -2) then
        return(Y);
      else
        return(CONV_SIGNED(enc_int, ENC_width+1));
      end if;
    end;    
    
    function DWF_lzd_enc(A: UNSIGNED) return UNSIGNED is
      -- pragma map_to_operator LZD_ENC_UNS_OP
      -- pragma type_function LZD_ENC_UNS_ARG
      -- pragma return_port_name Z
      constant A_width: NATURAL := A'length;
      constant ENC_width: NATURAL := bit_width(A'length);
      variable AV: std_logic_vector(A_width-1 downto 0);
      variable Z: UNSIGNED(ENC_width downto 0);
      variable Y: UNSIGNED (ENC_width downto 0):= (others => 'X');
      variable enc_int: integer;  
    begin
      AV := TO_UX01(std_logic_vector(A));
      enc_int := lzod_enc(0, AV);
      if (ENC_int = -2) then
        return(Y);
      else
        return(CONV_UNSIGNED(enc_int, ENC_width+1));
      end if;
    end;    

    function DWF_lzd_enc(A: std_logic_vector) return std_logic_vector is
      -- pragma map_to_operator LZD_ENC_STD_LOGIC_OP
      -- pragma type_function LZD_ENC_STD_LOGIC_ARG
      -- pragma return_port_name Z
      constant A_width: NATURAL := A'length;
      constant ENC_width: NATURAL := bit_width(A'length);
      variable AV: std_logic_vector(A_width-1 downto 0);
      variable Z: std_logic_vector(ENC_width downto 0);
      variable Y:  std_logic_vector(ENC_width downto 0):= (others => 'X');
      variable enc_int: integer;  
    begin
      AV := TO_UX01(std_logic_vector(A));
      enc_int := lzod_enc(0, AV);
      if (enc_int = -2) then
        return(Y);
      else
        return(std_logic_vector(CONV_UNSIGNED(enc_int, ENC_width+1)));
      end if;
    end;  

    function DWF_lzd(A: SIGNED) return SIGNED is
      -- pragma map_to_operator LZD_DEC_TC_OP
      -- pragma type_function LZD_DEC_TC_ARG
      -- pragma return_port_name Z
      constant A_width: NATURAL := A'length;
      variable AV: std_logic_vector(A_width-1 downto 0);
      variable Z: SIGNED(A_width-1 downto 0) ;
      variable Y: SIGNED(A_width-1 downto 0):= (others => 'X');
      variable dec_v: std_logic_vector(A_width-1 downto 0);
    begin
      AV := TO_UX01(std_logic_vector(A));
      dec_v := lzod(0, AV);
      if (dec_v(0) = 'X') then
        return(Y);
      else
        return(CONV_SIGNED(signed(dec_v),A_width));
      end if;
    end;    
    
    function DWF_lzd(A: UNSIGNED) return UNSIGNED is
      -- pragma map_to_operator LZD_DEC_UNS_OP
      -- pragma type_function LZD_DEC_UNS_ARG
      -- pragma return_port_name Z
      constant A_width: NATURAL := A'length;
      variable AV: std_logic_vector(A_width-1 downto 0);
      variable Z: UNSIGNED(A_width-1 downto 0);
      variable Y: UNSIGNED (A_width-1 downto 0):= (others => 'X');
      variable dec_v: std_logic_vector(A_width-1 downto 0);
    begin
      AV := TO_UX01(std_logic_vector(A));
      dec_v := lzod(0, AV);
      if (dec_v(0) = 'X') then
        return(Y);
      else
        return(CONV_UNSIGNED(UNSIGNED(dec_v),A_width));
      end if;
    end;    

    function DWF_lzd(A: std_logic_vector) return std_logic_vector is
      -- pragma map_to_operator LZD_DEC_STD_LOGIC_OP
      -- pragma type_function LZD_DEC_STD_LOGIC_ARG
      -- pragma return_port_name Z
      constant A_width: NATURAL := A'length;
      variable AV: std_logic_vector(A_width-1 downto 0);
      variable Z: std_logic_vector(A_width-1 downto 0);
      variable Y: std_logic_vector(A_width-1 downto 0):= (others => 'X');
      variable dec_v: std_logic_vector(A_width-1 downto 0);
    begin
      AV := TO_UX01(std_logic_vector(A));
      dec_v := lzod(0, AV);
      if (dec_v(0) = 'X') then
        return(Y);
      else
        return(dec_v);
      end if;
    end;  


  -- Content from file, DW_rash.vhdpp

    function DWF_rash(A: UNSIGNED; SH: UNSIGNED) return UNSIGNED is
      -- pragma map_to_operator ASHR_UNS_UNS_OP
      -- pragma type_function SH_UNS_UNS_ARG
      -- pragma return_port_name Z
    begin
      return(SHR(A,SH));
    end;

    function DWF_rash(A: SIGNED; SH: UNSIGNED) return SIGNED is
      -- pragma map_to_operator ASHR_TC_UNS_OP
      -- pragma type_function SH_TC_UNS_ARG
      -- pragma return_port_name Z
    begin
      return(SHR(A,SH));
    end;

    function DWF_rash(A: UNSIGNED; SH: SIGNED) return UNSIGNED is
      -- pragma map_to_operator ASHR_UNS_TC_OP
      -- pragma type_function SH_UNS_TC_ARG
      -- pragma return_port_name Z
      constant n: NATURAL := A'length;
      constant m: NATURAL := SH'length;
      variable SHMAG: SIGNED(m-1 downto 0);
    begin
      -- signed shift coefficient - perform left and right shifts on A
      SHMAG := ABS(SIGNED(SH));  -- absolute value of shift coefficient
      if (SH(m-1) = '0') then  -- right shift
	     return(SHR(A,UNSIGNED(SHMAG)));
      else                              -- left shift
        return(SHL(A,UNSIGNED(SHMAG)));
      end if;
    end;

    function DWF_rash(A: SIGNED; SH: SIGNED) return SIGNED is
      -- pragma map_to_operator ASHR_TC_TC_OP
      -- pragma type_function SH_TC_TC_ARG
      -- pragma return_port_name Z
      constant n: NATURAL := A'length;
      constant m: NATURAL := SH'length;
      variable SHMAG: SIGNED(m-1 downto 0);
    begin
      -- signed shift coefficient - perform left and right shifts on A
      SHMAG := ABS(SH);  -- absolute value of shift coefficient
      if (SH(m-1) = '0') then  -- right shift
	     return(SHR(A,UNSIGNED(SHMAG)));
      else                   -- left shift
	     return(SHL(A,UNSIGNED(SHMAG)));  
      end if;
    end;


  -- Content from file, DW_rbsh.vhdpp

    function DWF_rbsh(A: UNSIGNED; SH: UNSIGNED) return UNSIGNED is
      -- pragma map_to_operator BSHR_UNS_OP
      -- pragma type_function SH_UNS_UNS_ARG
      -- pragma return_port_name Z
      constant n: NATURAL := A'length;
      constant m: NATURAL := SH'length;
      -- given the limitation of the IEEE std_logic_arith package, the 
      -- shifting distance is limited to 31 bits.
      variable SHMIN: SIGNED(30 downto 0);
      variable SHCOMPL: SIGNED(30 downto 0);
      variable LEFTPART: UNSIGNED(n-1 downto 0);
      variable RIGHTPART: UNSIGNED(n-1 downto 0);
      variable result: UNSIGNED(n-1 downto 0);
    begin
      assert SH'length <= 31
            report "SH length exceeds 31 bits in DWF_rbsh. It was capped to 31 bits"
            severity FAILURE;
      SHMIN := CONV_SIGNED(SH,31);
      while (SHMIN > n) loop     --  the rotation distance is larger than input size
          SHMIN := SHMIN - n;
      end loop;
      SHCOMPL := n - SHMIN;
      LEFTPART := SHR(A,UNSIGNED(SHMIN));
      RIGHTPART := SHL(A,UNSIGNED(SHCOMPL));
      result := LEFTPART + RIGHTPART;
      if SH = 0 then 
         return(A);
      else
         return(result);
      end if;
    end;

    function DWF_rbsh(A: SIGNED; SH: UNSIGNED) return SIGNED is
      -- pragma map_to_operator BSHR_UNS_OP
      -- pragma type_function SH_TC_UNS_ARG
      -- pragma return_port_name Z
    begin
      if (SH = 0) then 
        return(A);
      else
        return (SIGNED(DWF_rbsh(UNSIGNED(A), SH)));
      end if;
    end;

    function DWF_rbsh(A: UNSIGNED; SH: SIGNED) return UNSIGNED is
      -- pragma map_to_operator BSHR_TC_OP
      -- pragma type_function SH_UNS_TC_ARG
      -- pragma return_port_name Z
      constant n: NATURAL := A'length;
      constant m: NATURAL := SH'length;
      variable SHMAG: SIGNED(m downto 0);
      -- given the limitation of the IEEE std_logic_arith package, the 
      -- shifting distance is limited to 31 bits.
      variable SHMIN: SIGNED(30 downto 0);
      variable SHCOMPL: SIGNED(30 downto 0);
    begin
      if (SH = 0) then 
         return(A); 
      end if;
      -- signed shift coefficient - perform left or right rotation on A
      SHMAG := ABS(SH(m-1)&SH);  -- absolute value of shift coefficient
      assert SH'length <= 31
            report "SH length exceeds 31 bits in DWF_rbsh. It was capped to 31 bits"
            severity FAILURE;
      SHMIN := CONV_SIGNED(SHMAG,31);
      while (SHMIN > n) loop    --  the rotation distance is larger than input size
        SHMIN := SHMIN - n;
      end loop;
      SHCOMPL := n-SHMIN;
      if (SH = 0) then 
         return(A); 
      end if;
      if SH(m-1) = '0' then  -- left rotate
        return(SHR(A,UNSIGNED(SHMIN)) + SHL(A,UNSIGNED(SHCOMPL)));
      else                   -- right rotate
        return(SHL(A,UNSIGNED(SHMIN)) + SHR(A,UNSIGNED(SHCOMPL)));
      end if;
    end;

    function DWF_rbsh(A: SIGNED; SH: SIGNED) return SIGNED is
      -- pragma map_to_operator BSHR_TC_OP
      -- pragma type_function SH_TC_TC_ARG
      -- pragma return_port_name Z
    begin
      if (SH = 0) then 
         return(A);
      end if;
      return (SIGNED(DWF_rbsh(UNSIGNED(A), SH)));
    end;


  -- Content from file, DW_lbsh.vhdpp

    function DWF_lbsh(A: UNSIGNED; SH: UNSIGNED) return UNSIGNED is
      -- pragma map_to_operator BSH_UNS_OP
      -- pragma type_function SH_UNS_UNS_ARG
      -- pragma return_port_name Z
      constant n: NATURAL := A'length;
      -- given the limitation of the IEEE std_logic_arith package, the 
      -- shifting distance is limited to 31 bits.
      variable SHMIN: SIGNED(30 downto 0);
      variable SHCOMPL: SIGNED(30 downto 0);
      variable LEFTPART: UNSIGNED(n-1 downto 0);
      variable RIGHTPART: UNSIGNED(n-1 downto 0);
      variable result: UNSIGNED(n-1 downto 0);
    begin
      assert SH'length <= 31
            report "SH length exceeds 31 bits in DWF_lbsh. It was capped to 31 bits"
            severity FAILURE;
      SHMIN := CONV_SIGNED(SH,31);
      while (SHMIN > n) loop     --  the rotation distance is larger than input size
          SHMIN := SHMIN - n;
      end loop;
      SHCOMPL := n - SHMIN;
      LEFTPART := SHL(A,UNSIGNED(SHMIN));
      RIGHTPART := SHR(A,UNSIGNED(SHCOMPL));
      result := LEFTPART + RIGHTPART;
      if SH = 0 then 
         return(A);
      else
         return(result);
      end if;
    end;

    function DWF_lbsh(A: SIGNED; SH: UNSIGNED) return SIGNED is
      -- pragma map_to_operator BSH_TC_OP
      -- pragma type_function SH_TC_UNS_ARG
      -- pragma return_port_name Z
    begin
      if (SH = 0) then 
         return(A);
      end if;
      return (SIGNED(DWF_lbsh(UNSIGNED(A), SH)));
    end;

    function DWF_lbsh(A: UNSIGNED; SH: SIGNED) return UNSIGNED is
      -- pragma map_to_operator BSHL_TC_OP
      -- pragma type_function SH_UNS_TC_ARG
      -- pragma return_port_name Z
      constant n: NATURAL := A'length;
      constant m: NATURAL := SH'length;
      variable SHMAG: SIGNED(m downto 0);
      -- given the limitation of the IEEE std_logic_arith package, the 
      -- shifting distance is limited to 31 bits.
      variable SHMIN: SIGNED(30 downto 0);
      variable SHCOMPL: SIGNED(30 downto 0);
    begin
      if (SH = 0) then 
         return(A); 
      end if;
      -- signed shift coefficient - perform left or right rotation on A
      SHMAG := ABS(SH(m-1)&SH);  -- absolute value of shift coefficient
      assert SH'length <= 31
            report "SH length exceeds 31 bits in DWF_lbsh. It was capped to 31 bits"
            severity FAILURE;
      SHMIN := CONV_SIGNED(SHMAG,31);
      while (SHMIN > n) loop    --  the rotation distance is larger than input size
        SHMIN := SHMIN - n;
      end loop;
      SHCOMPL := n - SHMIN;
      if SH(m-1) = '0' then  -- left rotate
        return(SHL(A,UNSIGNED(SHMIN)) + SHR(A,UNSIGNED(SHCOMPL)));
      else                   -- right rotate
        return(SHR(A,UNSIGNED(SHMIN)) + SHL(A,UNSIGNED(SHCOMPL)));
      end if;
    end;

    function DWF_lbsh(A: SIGNED; SH: SIGNED) return SIGNED is
      -- pragma map_to_operator BSHL_TC_OP
      -- pragma type_function SH_TC_TC_ARG
      -- pragma return_port_name Z
    begin
      if (SH = 0) then 
         return(A);
      end if;
      return (SIGNED(DWF_lbsh(UNSIGNED(A), SH)));
    end;


  -- Content from file, DW_lsd.vhdpp

    function LSD_ENC_TC_ARG (A: SIGNED) return SIGNED is
      variable Z: SIGNED(bit_width(A'length)-1 downto 0);
      -- pragma return_port_name Z
    begin
      return(Z);
    end;

    function LSD_DEC_TC_ARG (A: SIGNED) return SIGNED is
      variable Z: SIGNED(A'length-1 downto 0);
      -- pragma return_port_name Z
    begin
      return(Z);
    end;

    function LSD_ENC_UNS_ARG (A: UNSIGNED) return UNSIGNED is
      variable Z: UNSIGNED(bit_width(A'length)-1 downto 0);
      -- pragma return_port_name Z
    begin
      return(Z);
    end;

    function LSD_DEC_UNS_ARG (A: UNSIGNED) return UNSIGNED is
      variable Z: UNSIGNED(A'length-1 downto 0);
      -- pragma return_port_name Z
    begin
      return(Z);
    end;

    function LSD_ENC_STD_LOGIC_ARG (A: std_logic_vector) return std_logic_vector is
      variable Z: std_logic_vector(bit_width(A'length)-1 downto 0);
      -- pragma return_port_name Z
    begin
      return(Z);
    end;

    function LSD_DEC_STD_LOGIC_ARG (A: std_logic_vector) return std_logic_vector is
      variable Z: std_logic_vector(A'length-1 downto 0);
      -- pragma return_port_name Z
    begin
      return(Z);
    end;

    -- leading signs detector, encoded output
    -- Note: -2 means X encountered first
    function lsd_enc (a : std_logic_vector) return integer is
      variable enc  : integer;
      constant neg2 : integer := -2;
    begin
      enc := a'length-1; -- default
      for i in a'length-2 downto 0 loop
        if ((a(i+1) = 'X') or (a(i) = 'X')) then
          return neg2;  -- return -2 if 'X' found first
        elsif (a(i+1) /= a(i)) then
          enc := a'length - i - 2;
          return enc;  -- return first non-sign position
        end if;
      end loop;
      return enc;
    end lsd_enc;


    -- leading signs detector, decoded output
    -- Note: -2 means X encountered first
    function lsd (a: std_logic_vector) return std_logic_vector is
      variable enc_int : integer;
      variable dec_v   : std_logic_vector(a'length-1 downto 0);
      variable Y: std_logic_vector(a'length-1 downto 0):= (others => 'X');
    begin
      enc_int := lsd_enc (a);

      dec_v := (others => '0');
      if (enc_int >= 0) then
        dec_v(a'length - enc_int - 1) := '1';
      else
        return Y;  -- return if "X" resulted from lsd (encoder)
      end if;
      return dec_v;
    end lsd;

    function DWF_lsd_enc (A: SIGNED) return SIGNED is
      -- pragma map_to_operator LSD_ENC_TC_OP
      -- pragma type_function LSD_ENC_TC_ARG
      -- pragma return_port_name Z
      constant A_width: NATURAL := A'length;
      constant ENC_width: NATURAL := bit_width(A'length);
      variable AV: std_logic_vector(A_width-1 downto 0);
      variable Z: SIGNED(ENC_width-1 downto 0);
      variable Y: SIGNED(ENC_width-1 downto 0) := (others => 'X');
      variable enc_int: integer;  
    begin
      AV := TO_UX01 (std_logic_vector(A));
      enc_int := lsd_enc (AV);
      if (enc_int = -2) then
        return Y;
      else
        return CONV_SIGNED (enc_int, ENC_width);
      end if;
    end;    
    
    function DWF_lsd_enc (A: UNSIGNED) return UNSIGNED is
      -- pragma map_to_operator LSD_ENC_UNS_OP
      -- pragma type_function LSD_ENC_UNS_ARG
      -- pragma return_port_name Z
      constant A_width: NATURAL := A'length;
      constant ENC_width: NATURAL := bit_width(A'length);
      variable AV: std_logic_vector(A_width-1 downto 0);
      variable Z: UNSIGNED(ENC_width-1 downto 0);
      variable Y: UNSIGNED(ENC_width-1 downto 0) := (others => 'X');
      variable enc_int: integer;  
    begin
      AV := TO_UX01 (std_logic_vector(A));
      enc_int := lsd_enc (AV);
      if (ENC_int = -2) then
        return Y;
      else
        return CONV_UNSIGNED (enc_int, ENC_width);
      end if;
    end;    

    function DWF_lsd_enc (A: std_logic_vector) return std_logic_vector is
      -- pragma map_to_operator LSD_ENC_STD_LOGIC_OP
      -- pragma type_function LSD_ENC_STD_LOGIC_ARG
      -- pragma return_port_name Z
      constant A_width: NATURAL := A'length;
      constant ENC_width: NATURAL := bit_width(A'length);
      variable AV: std_logic_vector(A_width-1 downto 0);
      variable Z: std_logic_vector(ENC_width-1 downto 0);
      variable Y: std_logic_vector(ENC_width-1 downto 0) := (others => 'X');
      variable enc_int: integer;  
    begin
      AV := TO_UX01 (std_logic_vector(A));
      enc_int := lsd_enc (AV);
      if (enc_int = -2) then
        return Y;
      else
        return std_logic_vector(CONV_UNSIGNED (enc_int, ENC_width));
      end if;
    end;  

    function DWF_lsd (A: SIGNED) return SIGNED is
      -- pragma map_to_operator LSD_DEC_TC_OP
      -- pragma type_function LSD_DEC_TC_ARG
      -- pragma return_port_name Z
      constant A_width: NATURAL := A'length;
      variable AV: std_logic_vector(A_width-1 downto 0);
      variable Z: SIGNED(A_width-1 downto 0) ;
      variable Y: SIGNED(A_width-1 downto 0) := (others => 'X');
      variable dec_v: std_logic_vector(A_width-1 downto 0);
    begin
      AV := TO_UX01 (std_logic_vector(A));
      dec_v := lsd (AV);
      if (dec_v(0) = 'X') then
        return Y;
      else
        return SIGNED(dec_v);
      end if;
    end;    
    
    function DWF_lsd (A: UNSIGNED) return UNSIGNED is
      -- pragma map_to_operator LSD_DEC_UNS_OP
      -- pragma type_function LSD_DEC_UNS_ARG
      -- pragma return_port_name Z
      constant A_width: NATURAL := A'length;
      variable AV: std_logic_vector(A_width-1 downto 0);
      variable Z: UNSIGNED(A_width-1 downto 0);
      variable Y: UNSIGNED(A_width-1 downto 0) := (others => 'X');
      variable dec_v: std_logic_vector(A_width-1 downto 0);
    begin
      AV := TO_UX01 (std_logic_vector(A));
      dec_v := lsd (AV);
      if (dec_v(0) = 'X') then
        return Y;
      else
        return UNSIGNED(dec_v);
      end if;
    end;    

    function DWF_lsd (A: std_logic_vector) return std_logic_vector is
      -- pragma map_to_operator LSD_DEC_STD_LOGIC_OP
      -- pragma type_function LSD_DEC_STD_LOGIC_ARG
      -- pragma return_port_name Z
      constant A_width: NATURAL := A'length;
      variable AV: std_logic_vector(A_width-1 downto 0);
      variable Z: std_logic_vector(A_width-1 downto 0);
      variable Y: std_logic_vector(A_width-1 downto 0) := (others => 'X');
      variable dec_v: std_logic_vector(A_width-1 downto 0);
    begin
      AV := TO_UX01 (std_logic_vector(A));
      dec_v := lsd (AV);
      if (dec_v(0) = 'X') then
        return Y;
      else
        return dec_v;
      end if;
    end;  


  -- Content from file, DW_pricod.vhdpp

    function PRICOD_TC_ARG(A: SIGNED) return SIGNED is
      variable COD: SIGNED(A'length-1 downto 0);
      -- pragma return_port_name COD
    begin
      return COD;
    end;

    function PRICOD_UNS_ARG(A: UNSIGNED) return UNSIGNED is
      variable COD: UNSIGNED(A'length-1 downto 0);
      -- pragma return_port_name COD
    begin
      return COD;
    end;

    function PRICOD_STD_LOGIC_ARG(A: std_logic_vector) return std_logic_vector is
      variable COD: std_logic_vector(A'length-1 downto 0);
      -- pragma return_port_name COD
    begin
      return COD;
    end;

    -- priority coder
    function pricod (a : std_logic_vector) return std_logic_vector is
      variable cod : std_logic_vector(a'length-1 downto 0);
    begin
      cod := (others => '0');  -- initialize to "000..."
      for i in a'length-1 downto 0 loop
        -- find first '1'
        if (a(i) = '1') then
          cod(i) := '1';
          return cod;
        -- otherwise find first '1'
        elsif (a(i) = 'X') then
          cod := (others => 'X');
          return cod;
        end if;
      end loop;
      return cod;
    end pricod;

    function DWF_pricod (A : SIGNED) return SIGNED is
      -- pragma map_to_operator PRICOD_TC_OP
      -- pragma type_function PRICOD_TC_ARG
      -- pragma return_port_name COD
      constant A_width : NATURAL := A'length;
      variable AV : std_logic_vector(A_width-1 downto 0);
      variable COD : SIGNED(A_width-1 downto 0);
      variable cod_v : std_logic_vector(A_width-1 downto 0);
    begin
      -- pragma translate_off
      AV := TO_UX01 (std_logic_vector(A));
      cod_v := pricod (AV);
      -- pragma translate_on
      return SIGNED(cod_v);
    end;    
    
    function DWF_pricod (A : UNSIGNED) return UNSIGNED is
      -- pragma map_to_operator PRICOD_UNS_OP
      -- pragma type_function PRICOD_UNS_ARG
      -- pragma return_port_name COD
      constant A_width : NATURAL := A'length;
      variable AV : std_logic_vector(A_width-1 downto 0);
      variable COD : UNSIGNED(A_width-1 downto 0);
      variable cod_v : std_logic_vector(A_width-1 downto 0);
    begin
      AV := TO_UX01 (std_logic_vector(A));
      -- pragma translate_off
      cod_v := pricod (AV);
      -- pragma translate_on
      return UNSIGNED(cod_v);
    end;    

    function DWF_pricod (A : std_logic_vector) return std_logic_vector is
      -- pragma map_to_operator PRICOD_STD_LOGIC_OP
      -- pragma type_function PRICOD_STD_LOGIC_ARG
      -- pragma return_port_name COD
      constant A_width : NATURAL := A'length;
      variable AV : std_logic_vector(A_width-1 downto 0);
      variable COD : std_logic_vector(A_width-1 downto 0);
      variable cod_v: std_logic_vector(A_width-1 downto 0);
    begin
      -- pragma translate_off
      AV := TO_UX01 (std_logic_vector(A));
      cod_v := pricod (AV);
      -- pragma translate_on
      return cod_v;
    end;  


  -- Content from file, DW_lza.vhdpp


    function LZA_CNT_STD_LOGIC_ARG(A,B: std_logic_vector) return  std_logic_vector is
      variable Z: std_logic_vector(bit_width(A'length)-1 downto 0);
      -- pragma return_port_name Z
    begin
      return(Z);
    end;


  function DWF_lza(A,B: std_logic_vector) return std_logic_vector is
  -- pragma map_to_operator LZA_CNT_STD_LOGIC_OP
  -- pragma type_function LZA_CNT_STD_LOGIC_ARG
  -- pragma return_port_name Z
  constant width: NATURAL := A'length;
  constant log2width: NATURAL := bit_width(A'length);
  variable DONE : integer := 0;
  variable I   : integer := 0;
  variable LZA : std_logic;
  variable AV  : std_logic_vector(width-1 downto 0);
  variable BV  : std_logic_vector(width-1 downto 0);
  variable Z   : std_logic_vector(width-1 downto 0);
  variable Y   : std_logic_vector(log2width-1 downto 0):= (others => 'X');
  variable POS : std_logic_vector(log2width-1 downto 0);
  begin
    AV := TO_UX01(std_logic_vector(A));
    BV := TO_UX01(std_logic_vector(B));
    if(AV = BV) then
      POS := (others => '1');
    else
      DONE := 0;
      for cnt in 0 to width-1 loop 
        I := width-cnt-1;
        if(I = 0) then
          LZA :=  (AV(I) and not BV(I)) or ((not AV(I)) and BV(I));
        else
          LZA := ((AV(I) and  not BV(I)) 
               and  not ( (not AV(I-1)) and BV(I-1))) 
  	     or (( (not AV(I)) and BV(I)) 
  	     and  not ( (not AV(I-1)) and BV(I-1)));
        end if;
        if(LZA = '1' and DONE = 0) then
          POS :=  std_logic_vector(conv_unsigned(width-i-1,log2width));
          DONE := 1;
        elsif (DONE = 0) then
          POS := (others => '1');
        end if;
      end loop;
    end if;
    if (POS(0) = 'X' or AV(0) = 'X' or BV(0) = 'X') then
      return(Y);
    else
      return(POS);
    end if;
  end;

end DW01_components;

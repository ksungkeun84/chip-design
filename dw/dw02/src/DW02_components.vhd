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
-- VERSION:   Components package file for DW02_components
--
-- DesignWare_version: a796063a
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_misc.all;
use IEEE.std_logic_arith.all;

library DWARE;
use DWARE.DWpackages.all;

package DW02_components is


  -- Content from file, DW02_tree.vhdpp

  component DW02_tree
  generic(num_inputs : POSITIVE;      -- number of inputs
          input_width : POSITIVE;     -- wordlength of inputs
 	  verif_en : INTEGER := 1);   -- control of random CS output
  port(INPUT : in std_logic_vector(num_inputs*input_width-1 downto 0);  
       OUT0, OUT1: out std_logic_vector(input_width-1 downto 0));
  end component;


  -- Content from file, DW02_multp.vhdpp

  component DW02_multp
   generic( a_width: NATURAL;           -- multiplier word size
            b_width: NATURAL;           -- multiplicand word size
	    out_width: NATURAL;         -- partial prod word size
            verif_en: INTEGER := 2);    -- random CS representation control
   port(a : in std_logic_vector(a_width-1 downto 0);  
        b : in std_logic_vector(b_width-1 downto 0);
        tc : in std_logic;              -- signed -> '1', unsigned -> '0'
        out0 : out std_logic_vector(out_width-1 downto 0);
        out1 : out std_logic_vector(out_width-1 downto 0));
  end component;


  -- Content from file, DW02_sum.vhdpp

  component DW02_sum
  generic(num_inputs : NATURAL;      -- number of inputs
          input_width : NATURAL);     -- wordlength of inputs
  port(INPUT : in std_logic_vector(num_inputs*input_width-1 downto 0);  
       SUM : out std_logic_vector(input_width-1 downto 0));
  end component;


  -- Content from file, DW02_mult.vhdpp

  component DW02_mult
   generic( A_width: NATURAL;		-- multiplier wordlength
            B_width: NATURAL);		-- multiplicand wordlength
   port(A : in std_logic_vector(A_width-1 downto 0);  
        B : in std_logic_vector(B_width-1 downto 0);
        TC : in std_logic;		-- signed -> '1', unsigned -> '0'
        PRODUCT : out std_logic_vector(A_width+B_width-1 downto 0));
  end component;


  -- Content from file, DW02_mac.vhdpp

  component DW02_mac
   generic( A_width: NATURAL ;                  -- multiplier wordlength
            B_width: NATURAL);                  -- multiplicand wordlength
   port(A : in std_logic_vector(A_width-1 downto 0);  
        B : in std_logic_vector(B_width-1 downto 0);
        C : in std_logic_vector(A_width+B_width-1 downto 0);
        TC : in std_logic;          
        MAC : out std_logic_vector(A_width+B_width-1 downto 0));
  end component;


  -- Content from file, DW02_mult_2_stage.vhdpp

  component DW02_mult_2_stage
   generic( A_width: POSITIVE;		-- multiplier wordlength
            B_width: POSITIVE);		-- multiplicand wordlength
   port(A : in std_logic_vector(A_width-1 downto 0);  
        B : in std_logic_vector(B_width-1 downto 0);
        TC : in std_logic;		-- signed -> '1', unsigned -> '0'
        CLK : in std_logic;           -- clock for the stage registers.
        PRODUCT : out std_logic_vector(A_width+B_width-1 downto 0));
  end component;


  -- Content from file, DW02_mult_3_stage.vhdpp

  component DW02_mult_3_stage
   generic( A_width: POSITIVE;		-- multiplier wordlength
            B_width: POSITIVE);		-- multiplicand wordlength
   port(A : in std_logic_vector(A_width-1 downto 0);  
        B : in std_logic_vector(B_width-1 downto 0);
        TC : in std_logic;		-- signed -> '1', unsigned -> '0'
        CLK : in std_logic;           -- clock for the stage registers.
        PRODUCT : out std_logic_vector(A_width+B_width-1 downto 0));
  end component;


  -- Content from file, DW02_mult_4_stage.vhdpp

  component DW02_mult_4_stage
   generic( A_width: POSITIVE;		-- multiplier wordlength
            B_width: POSITIVE);		-- multiplicand wordlength
   port(A : in std_logic_vector(A_width-1 downto 0);  
        B : in std_logic_vector(B_width-1 downto 0);
        TC : in std_logic;		-- signed -> '1', unsigned -> '0'
        CLK : in std_logic;           -- clock for the stage registers.
        PRODUCT : out std_logic_vector(A_width+B_width-1 downto 0));
  end component;


  -- Content from file, DW02_mult_5_stage.vhdpp

  component DW02_mult_5_stage
   generic( A_width: POSITIVE;		-- multiplier wordlength
            B_width: POSITIVE);		-- multiplicand wordlength
   port(A : in std_logic_vector(A_width-1 downto 0);  
        B : in std_logic_vector(B_width-1 downto 0);
        TC : in std_logic;		-- signed -> '1', unsigned -> '0'
        CLK : in std_logic;           -- clock for the stage registers.
        PRODUCT : out std_logic_vector(A_width+B_width-1 downto 0));
  end component;


  -- Content from file, DW02_mult_6_stage.vhdpp

  component DW02_mult_6_stage
   generic( A_width: POSITIVE;		-- multiplier wordlength
            B_width: POSITIVE);		-- multiplicand wordlength
   port(A : in std_logic_vector(A_width-1 downto 0);  
        B : in std_logic_vector(B_width-1 downto 0);
        TC : in std_logic;		-- signed -> '1', unsigned -> '0'
        CLK : in std_logic;           -- clock for the stage registers.
        PRODUCT : out std_logic_vector(A_width+B_width-1 downto 0));
  end component;


  -- Content from file, DW02_prod_sum.vhdpp

  component DW02_prod_sum
   generic( A_width: NATURAL;             -- multiplier wordlength
            B_width: NATURAL;             -- multiplicand wordlength
	    num_inputs: POSITIVE;          
            SUM_width: NATURAL);          -- multiplicand wordlength 
   port(A : in std_logic_vector(num_inputs*A_width-1 downto 0);  
        B : in std_logic_vector(num_inputs*B_width-1 downto 0);
        TC : in std_logic;          
        SUM : out std_logic_vector(SUM_width-1 downto 0));
  end component;


  -- Content from file, DW02_prod_sum1.vhdpp

  component DW02_prod_sum1
   generic( A_width: NATURAL;             -- multiplier wordlength
            B_width: NATURAL;             -- multiplicand wordlength
            SUM_width: NATURAL);          -- multiplicand wordlength  
   port(A : in std_logic_vector(A_width-1 downto 0);  
        B : in std_logic_vector(B_width-1 downto 0);
        C : in std_logic_vector(SUM_width-1 downto 0);
        TC : in std_logic;          
        SUM : out std_logic_vector(SUM_width-1 downto 0));
  end component;


  -- Content from file, DW_squarep.vhdpp

  component DW_squarep
   generic( width: NATURAL;             -- multiplier size
            verif_en: INTEGER := 2);    -- random CS representation control

   port(a : in std_logic_vector(width-1 downto 0);  
        tc : in std_logic;          -- signed -> '1', unsigned -> '0'
        out0 : out std_logic_vector((2*width)-1 downto 0);
        out1 : out std_logic_vector((2*width)-1 downto 0));

  end component;


  -- Content from file, DW_square.vhdpp

  component DW_square
   generic( width: NATURAL);          -- multiplier size
   port(a : in std_logic_vector(width-1 downto 0);  
        tc : in std_logic;          -- signed -> '1', unsigned -> '0'
        square : out std_logic_vector((2*width)-1 downto 0));
  end component;


  -- Content from file, DW_mult_dx.vhdpp

  component DW_mult_dx
	generic(
		width :		NATURAL;
		p1_width :	NATURAL
		);
	port(
		a : 		in std_logic_vector(width-1 downto 0);
		b : 		in std_logic_vector(width-1 downto 0);
        	tc :		in std_logic;
        	dplx :		in std_logic;
        	product :	out std_logic_vector(2*width-1 downto 0)
		);
  end component;


  -- Content from file, DW_div.vhdpp

  component DW_div

  generic (
    a_width  : positive;                    -- word width of dividend, quotient
    b_width  : positive;                    -- word width of divisor, remainder
    tc_mode  : integer range 0 to 1 := 0;   -- '0' : unsigned, '1' : 2's compl.
    rem_mode : integer range 0 to 1 := 1);  -- '0' : modulus, '1' : remainder

  port (
    a           : in  std_logic_vector(a_width-1 downto 0);  -- dividend
    b           : in  std_logic_vector(b_width-1 downto 0);  -- divisor
    quotient    : out std_logic_vector(a_width-1 downto 0);  -- quotient
    remainder   : out std_logic_vector(b_width-1 downto 0);  -- remainder
    divide_by_0 : out std_logic);     -- divide-by-0 flag

  end component;


  -- Content from file, DW_div_sat.vhdpp

  component DW_div_sat

  generic (
    a_width  : positive;                    -- word width of dividend
    b_width  : positive;                    -- word width of divisor
    q_width  : positive;                    -- word width of quotient
    tc_mode  : integer range 0 to 1 := 0);  -- '0' : unsigned, '1' : 2's compl.

  port (
    a           : in  std_logic_vector(a_width-1 downto 0);  -- dividend
    b           : in  std_logic_vector(b_width-1 downto 0);  -- divisor
    quotient    : out std_logic_vector(q_width-1 downto 0);  -- quotient
    divide_by_0 : out std_logic);     -- divide-by-0 flag

  end component;


  -- Content from file, DW_sqrt.vhdpp

  component DW_sqrt

  generic (
    width   : positive;                    -- radicand word width
    tc_mode : integer range 0 to 1 := 0);  -- '0' : unsigned, '1' : 2's compl.

  port (
    a    : in  std_logic_vector(width-1 downto 0);         -- radicand
    root : out std_logic_vector((width+1)/2-1 downto 0));  -- square root

  end component;


  -- Content from file, DW_mult_pipe.vhdpp

  component DW_mult_pipe

  generic (
    a_width       : positive;                      -- multiplier word width
    b_width       : positive;                      -- multiplicand word width
    num_stages    : positive := 2;                 -- number of pipeline stages
    stall_mode    : natural range 0 to 1 := 1;     -- '0': non-stallable; '1': stallable
    rst_mode      : natural range 0 to 2  := 1;    -- '0': none; '1': async; '2': sync
    op_iso_mode   : natural range 0 to 4  := 0);   -- '0': apply Power Compiler user setting; '1': noop; '2': and; '3': or; '4' preferred style...'and'

  port (
    clk     : in  std_logic;          -- register clock
    rst_n   : in  std_logic;          -- register reset
    en      : in  std_logic;          -- register enable
    tc      : in  std_logic;          -- '0' : unsigned, '1' : signed
    a       : in  std_logic_vector(a_width-1 downto 0);  -- multiplier
    b       : in  std_logic_vector(b_width-1 downto 0);  -- multiplicand
    product : out std_logic_vector(a_width+b_width-1 downto 0));  -- product

  end component;


  -- Content from file, DW_div_pipe.vhdpp

  component DW_div_pipe

  generic (
    a_width     : positive;                           -- divisor word width
    b_width     : positive;                           -- dividend word width
    tc_mode     : natural  range 0 to 1 := 0;         -- '0' : unsigned, '1' : 2's compl.
    rem_mode    : natural  range 0 to 1 := 1;         -- '0' : modulus, '1' : remainder
    num_stages  : positive := 2;                      -- number of pipeline stages
    stall_mode  : natural  range 0 to 1 := 1;         -- '0' : non-stallable, '1' : stallable
    rst_mode    : natural range 0 to 2  := 1;         -- '0' : none, '1' : async, '2' : sync
    op_iso_mode : natural range 0 to 4  := 0);        -- operand isolation selection

  port (
    clk         : in  std_logic;                      -- register clock
    rst_n       : in  std_logic;                      -- register reset
    en          : in  std_logic;                      -- register enable
    a           : in  std_logic_vector(a_width-1 downto 0);  -- divisor
    b           : in  std_logic_vector(b_width-1 downto 0);  -- dividend
    quotient    : out std_logic_vector(a_width-1 downto 0);  -- quotient
    remainder   : out std_logic_vector(b_width-1 downto 0);  -- remainder
    divide_by_0 : out std_logic);                            -- divide by
  end component;


  -- Content from file, DW_sqrt_pipe.vhdpp

  component DW_sqrt_pipe

  generic (
    width       : positive := 2;                --  radicand word width
    tc_mode     : natural  := 0;                -- '0' : unsigned, '1' : 2's compl.
    num_stages  : positive := 2;                -- number of pipeline stages
    stall_mode  : natural range 0 to 1 := 1;    -- '0' : non-stallable, '1' : stallable
    rst_mode    : natural range 0 to 2 := 1;    -- '0' : none, '1' : async, '2' : sync
    op_iso_mode : natural range 0 to 4 := 0);   -- operand isolation selection

  port (
    clk   : in  std_logic;            -- register clock
    rst_n : in  std_logic;            -- register reset
    en    : in  std_logic;            -- register enable
    a     : in  std_logic_vector(width-1 downto 0);  -- radicand
    root  : out std_logic_vector((width+1)/2-1 downto 0));  -- square root

  end component;


  -- Content from file, DW_prod_sum_pipe.vhdpp

  component DW_prod_sum_pipe

  generic (
    a_width      : positive := 2;              -- multiplier word width
    b_width      : positive := 2;              -- multiplicand word width
    num_inputs   : positive := 2;              -- number of inputs
    sum_width    : positive := 5;              -- width of sum
    num_stages   : positive := 2;              -- number of pipeline stages
    stall_mode   : natural range 0 to 1 := 1;  -- '0' : non-stallable, '1' : stallable
    rst_mode     : natural range 0 to 2 := 1;  -- '0' : none, '1' : async, '2' : sync
    op_iso_mode  : natural range 0 to 4 := 0); -- '0': apply Power Compiler user setting; '1': noop; '2': and; '3': or; '4' preferred style...'and'

  port (
    clk   : in  std_logic;            -- register clock
    rst_n : in  std_logic;            -- register reset
    en    : in  std_logic;            -- register enable
    tc    : in  std_logic;            -- '0' : unsigned, '1' : signed
    a     : in  std_logic_vector(a_width*num_inputs-1 downto 0);  -- multiplier
    b     : in  std_logic_vector(b_width*num_inputs-1 downto 0);  -- multiplicand
    sum   : out std_logic_vector(sum_width-1 downto 0));  -- product

  end component;


  -- Content from file, DW_inv_sqrt.vhdpp

  component DW_inv_sqrt
   generic(a_width : POSITIVE := 8;        -- size of input and output operand
           prec_control : INTEGER := 0);   -- indicates the number of bits that 
   port(a : in std_logic_vector(a_width-1 downto 0);   -- input data
        b : out std_logic_vector(a_width-1 downto 0); -- output data
        t : out std_logic);
  end component;


  -- Content from file, DW_fp_flt2i.vhdpp

  component DW_fp_flt2i

  generic(sig_width      : POSITIVE range 2 to 253 := 23;
          exp_width      : POSITIVE range 3 to 31  := 8;
          isize          : integer range 3 to 512  := 32;
          ieee_compliance: integer range 0 to 1 := 0
         );

  port(  a        : in std_logic_vector(sig_width + exp_width downto 0);
         rnd      : in std_logic_vector(2 downto 0);
         z        : out std_logic_vector(isize - 1 downto 0);
         status   : out std_logic_vector(7 downto 0)
      );

  end component;


  -- Content from file, DW_fp_i2flt.vhdpp

  component DW_fp_i2flt

  generic(
    sig_width   : POSITIVE range 2 to 253 := 23;
    exp_width   : POSITIVE range 3 to 31  := 8;
    isize       : POSITIVE range 3 to 512  := 32;
    isign       : integer range 0 to 1 := 1
  );

  port(
    a        : in std_logic_vector(isize - 1 downto 0);
    rnd      : in std_logic_vector(2 downto 0);
    z        : out std_logic_vector(sig_width + exp_width downto 0);
    status   : out std_logic_vector(7 downto 0)
  );

  end component;


  -- Content from file, DW_fp_addsub.vhdpp

  component DW_fp_addsub
   generic(sig_width : POSITIVE range 2 to 253 := 23;
	   exp_width : POSITIVE range 3 to 31  := 8;
           ieee_compliance : INTEGER range 0 to 1 := 0);
   port(a : in std_logic_vector(sig_width+exp_width downto 0);   -- 1st FP number
        b : in std_logic_vector(sig_width+exp_width downto 0);   -- 2nd FP number
	rnd : in std_logic_vector(2 downto 0);   -- rounding
        op : in std_logic;       -- add/sub control: 0 for add - 1 for sub
        z : out std_logic_vector(sig_width+exp_width downto 0);  -- FP result
        status : out std_logic_vector(7 downto 0));
  end component;


  -- Content from file, DW_fp_add.vhdpp

  component DW_fp_add
   generic(sig_width : POSITIVE := 23;
	   exp_width : POSITIVE := 8;
           ieee_compliance : INTEGER := 0);
   port(a : in std_logic_vector(sig_width+exp_width downto 0);   -- 1st FP number
        b : in std_logic_vector(sig_width+exp_width downto 0);   -- 2nd FP number
	rnd : in std_logic_vector(2 downto 0);   -- rounding
        z : out std_logic_vector(sig_width+exp_width downto 0);  -- FP result
        status : out std_logic_vector(7 downto 0));
  end component;


  -- Content from file, DW_fp_sub.vhdpp

  component DW_fp_sub
   generic(sig_width : POSITIVE := 23;
	   exp_width : POSITIVE := 8;
	   ieee_compliance : INTEGER := 0);
   port(a : in std_logic_vector(sig_width+exp_width downto 0);   -- 1st FP number
        b : in std_logic_vector(sig_width+exp_width downto 0);   -- 2nd FP number
	rnd : in std_logic_vector(2 downto 0);   -- rounding
        z : out std_logic_vector(sig_width+exp_width downto 0);  -- FP result
        status : out std_logic_vector(7 downto 0));
  end component;


  -- Content from file, DW_fp_mult.vhdpp

  component DW_fp_mult

  generic(
    sig_width   : POSITIVE range 2 to 253 := 23;
    exp_width   : POSITIVE range 3 to 31  := 8;
    ieee_compliance: INTEGER  range 0 to 1   := 0
  );

  port(
    a        : in std_logic_vector(sig_width + exp_width downto 0);
    b        : in std_logic_vector(sig_width + exp_width downto 0);
    rnd      : in std_logic_vector(2 downto 0);
    z        : out std_logic_vector(sig_width + exp_width downto 0);
    status   : out std_logic_vector(7 downto 0)
  );

  end component;


  -- Content from file, DW_fp_div.vhdpp

  component DW_fp_div

  generic(
    sig_width   : POSITIVE range 2 to 253 := 23;
    exp_width   : POSITIVE range 3 to 31  := 8;
    ieee_compliance: INTEGER  range 0 to 1 := 0;
    faithful_round : INTEGER  range 0 to 1 := 0
  );

  port(
    a        : in std_logic_vector(sig_width + exp_width downto 0);
    b        : in std_logic_vector(sig_width + exp_width downto 0);
    rnd      : in std_logic_vector(2 downto 0);
    z        : out std_logic_vector(sig_width + exp_width downto 0);
    status   : out std_logic_vector(7 downto 0)
  );

  end component;


  -- Content from file, DW_fp_cmp.vhdpp

  component DW_fp_cmp
   generic(sig_width : POSITIVE := 23;
	   exp_width : POSITIVE := 8;
           ieee_compliance : INTEGER := 0);
   port(a : in std_logic_vector(sig_width+exp_width downto 0);  -- 1st FP number
        b : in std_logic_vector(sig_width+exp_width downto 0);  -- 2nd FP number
        zctr : in std_logic;                                    -- output control
        aeqb : out std_logic;                                   -- output a=b
        altb : out std_logic;                                   -- output a<b
        agtb : out std_logic;                                   -- output a>b
        unordered : out std_logic;                              -- output when NaN input
        z0 : out std_logic_vector(sig_width+exp_width downto 0);-- FP max/min result
        z1 : out std_logic_vector(sig_width+exp_width downto 0);-- FP max/min result
        status0 : out std_logic_vector(7 downto 0);
        status1 : out std_logic_vector(7 downto 0));
  end component;


  -- Content from file, DW_fp_recip.vhdpp

  component DW_fp_recip

  generic(
    sig_width      : POSITIVE range 2 to 60 := 23;
    exp_width      : POSITIVE range 3 to 31 := 8;
    ieee_compliance: INTEGER  range 0 to 1  := 0;
    faithful_round : INTEGER  range 0 to 1  := 0
  );

  port(
    a        : in std_logic_vector(sig_width + exp_width downto 0);
    rnd      : in std_logic_vector(2 downto 0);
    z        : out std_logic_vector(sig_width + exp_width downto 0);
    status   : out std_logic_vector(7 downto 0)
  );

  end component;


  -- Content from file, DW_fp_ifp_conv.vhdpp

  component DW_fp_ifp_conv
   generic(sig_widthi : POSITIVE range 2 to 253 := 23;
	   exp_widthi : POSITIVE range 3 to 31  := 8;
           sig_widtho : POSITIVE range 2 to 253 := 25;
	   exp_widtho : POSITIVE range 3 to 31  := 8;
           use_denormal : INTEGER range 0 to 1 := 0;
           use_1scmpl : INTEGER range 0 to 1 := 0);
   port(a : in std_logic_vector(sig_widthi+exp_widthi downto 0);   -- FP number
        z : out std_logic_vector(sig_widtho+exp_widtho+7-1 downto 0) -- Internal FP number
        );
  end component;


  -- Content from file, DW_ifp_fp_conv.vhdpp

  component DW_ifp_fp_conv
   generic(sig_widthi : POSITIVE range 2 to 253 := 25;
	   exp_widthi : POSITIVE range 3 to 31  := 8;
           sig_width  : POSITIVE range 2 to 253 := 23;
	   exp_width  : POSITIVE range 3 to 31  := 8;
           use_denormal : INTEGER range 0 to 1 := 0);
   port(a : in std_logic_vector(sig_widthi+exp_widthi+7-1 downto 0); -- IFP number
        rnd : in std_logic_vector(2 downto 0);                     -- rounding mode
        z : out std_logic_vector(sig_width+exp_width downto 0);    -- IEEE FP number
        status : out std_logic_vector(7 downto 0));
  end component;


  -- Content from file, DW_ifp_addsub.vhdpp

  component DW_ifp_addsub
   generic(sig_widthi : POSITIVE range 2 to 253 := 23;
	   exp_widthi : POSITIVE range 3 to 31  := 8;
           sig_widtho : POSITIVE range 2 to 253 := 23;
	   exp_widtho : POSITIVE range 3 to 31  := 8;
           use_denormal : INTEGER range 0 to 1 := 0;
           use_1scmpl : INTEGER range 0 to 1 := 0
           );
   port(a : in std_logic_vector(sig_widthi+exp_widthi+7-1 downto 0);   -- 1st FP number
        b : in std_logic_vector(sig_widthi+exp_widthi+7-1 downto 0);   -- 2nd FP number
        op : in std_logic;       -- add/sub control: 0 for add - 1 for sub
        rnd : in std_logic_vector(2 downto 0);  -- rounding mode
        z : out std_logic_vector(sig_widtho+exp_widtho+7-1 downto 0)   -- FP result
        );
  end component;


  -- Content from file, DW_FP_ALIGN.vhdpp

  component DW_FP_ALIGN
   generic(a_width : POSITIVE := 23;
	   sh_width : POSITIVE := 8);
   port(a  : in std_logic_vector(a_width-1 downto 0);  
        sh : in std_logic_vector(sh_width-1 downto 0); 
        b : out std_logic_vector(a_width-1 downto 0);
        stk : out std_logic);
  end component;


  -- Content from file, DW_ifp_mult.vhdpp

  component DW_ifp_mult

  generic(
    sig_widthi   : POSITIVE range 2 to 253 := 23;
    exp_widthi   : POSITIVE range 3 to 31  := 8;
    sig_widtho   : POSITIVE range 2 to 253 := 23;
    exp_widtho   : POSITIVE range 3 to 31  := 8
  );

  port(
    a        : in std_logic_vector(sig_widthi + exp_widthi + 7 -1 downto 0);
    b        : in std_logic_vector(sig_widthi + exp_widthi + 7 -1 downto 0);
    z        : out std_logic_vector(sig_widtho + exp_widtho + 7 -1 downto 0)
  );

  end component;


  -- Content from file, DW_fp_sum3.vhdpp

  component DW_fp_sum3
   generic(sig_width : POSITIVE range 2 to 253 := 23;
           exp_width : POSITIVE range 3 to 31  := 8;
           ieee_compliance : INTEGER range 0 to 1 := 0;
           arch_type : INTEGER range 0 to 1 := 0);
   port(a : in std_logic_vector(sig_width+exp_width downto 0);   -- 1st FP number
        b : in std_logic_vector(sig_width+exp_width downto 0);   -- 2nd FP number
        c : in std_logic_vector(sig_width+exp_width downto 0);   -- 3rd FP number
        rnd : in std_logic_vector(2 downto 0);                   -- rounding
        z : out std_logic_vector(sig_width+exp_width downto 0);  -- FP result
        status : out std_logic_vector(7 downto 0));
  end component;


  -- Content from file, DW_fp_sum4.vhdpp

  component DW_fp_sum4
   generic(sig_width : POSITIVE range 2 to 253 := 23;
	   exp_width : POSITIVE range 3 to 31 := 8;
           ieee_compliance : INTEGER range 0 to 1 := 0;
           arch_type : INTEGER range 0 to 1 := 0);
   port(a : in std_logic_vector(sig_width+exp_width downto 0);   -- 1st FP number
        b : in std_logic_vector(sig_width+exp_width downto 0);   -- 2nd FP number
        c : in std_logic_vector(sig_width+exp_width downto 0);   -- 3rd FP number
        d : in std_logic_vector(sig_width+exp_width downto 0);   -- 4th FP number
	rnd : in std_logic_vector(2 downto 0);              -- rounding
        z : out std_logic_vector(sig_width+exp_width downto 0);  -- FP result
        status : out std_logic_vector(7 downto 0));
  end component;


  -- Content from file, DW_fp_dp2.vhdpp

  component DW_fp_dp2
   generic(sig_width :       POSITIVE range 2 to 253 := 23;
	   exp_width :       POSITIVE range 3 to 31  := 8;
           ieee_compliance : INTEGER range 0 to 1 := 0;
           arch_type :       INTEGER range 0 to 1 := 0);
   port(a : in std_logic_vector(sig_width+exp_width downto 0); -- 1st FP number
        b : in std_logic_vector(sig_width+exp_width downto 0); -- 2nd FP number
        c : in std_logic_vector(sig_width+exp_width downto 0); -- 3rd FP number
        d : in std_logic_vector(sig_width+exp_width downto 0); -- 4th FP number
	rnd : in std_logic_vector(2 downto 0);   -- rounding
        z : out std_logic_vector(sig_width+exp_width downto 0);  -- FP result
        status : out std_logic_vector(7 downto 0));
  end component;


  -- Content from file, DW_fp_dp3.vhdpp

  component DW_fp_dp3
   generic(sig_width :       POSITIVE := 23;
	   exp_width :       POSITIVE := 8;
           ieee_compliance : INTEGER range 0 to 1 := 0;
           arch_type :       INTEGER range 0 to 1 := 0);
   port(a : in std_logic_vector(sig_width+exp_width downto 0);   -- 1st FP number
        b : in std_logic_vector(sig_width+exp_width downto 0);   -- 2nd FP number
        c : in std_logic_vector(sig_width+exp_width downto 0);   -- 3rd FP number
        d : in std_logic_vector(sig_width+exp_width downto 0);   -- 4th FP number
        e : in std_logic_vector(sig_width+exp_width downto 0);   -- 5th FP number
        f : in std_logic_vector(sig_width+exp_width downto 0);   -- 6th FP number
	rnd : in std_logic_vector(2 downto 0);   -- rounding
        z : out std_logic_vector(sig_width+exp_width downto 0);  -- FP result
        status : out std_logic_vector(7 downto 0));
  end component;


  -- Content from file, DW_fp_dp4.vhdpp

  component DW_fp_dp4
   generic(sig_width :       POSITIVE := 23;
	   exp_width :       POSITIVE := 8;
           ieee_compliance : INTEGER range 0 to 1 := 0;
           arch_type :       INTEGER range 0 to 1 := 0);
   port(a : in std_logic_vector(sig_width+exp_width downto 0);   -- 1st FP number
        b : in std_logic_vector(sig_width+exp_width downto 0);   -- 2nd FP number
        c : in std_logic_vector(sig_width+exp_width downto 0);   -- 3rd FP number
        d : in std_logic_vector(sig_width+exp_width downto 0);   -- 4th FP number
        e : in std_logic_vector(sig_width+exp_width downto 0);   -- 5th FP number
        f : in std_logic_vector(sig_width+exp_width downto 0);   -- 6th FP number
        g : in std_logic_vector(sig_width+exp_width downto 0);   -- 7th FP number
        h : in std_logic_vector(sig_width+exp_width downto 0);   -- 8th FP number
	rnd : in std_logic_vector(2 downto 0);   -- rounding
        z : out std_logic_vector(sig_width+exp_width downto 0);  -- FP result
        status : out std_logic_vector(7 downto 0));
  end component;


  -- Content from file, DW_fp_invsqrt.vhdpp

  component DW_fp_invsqrt

  generic(
    sig_width   : POSITIVE range 2 to 253 := 23;
    exp_width   : POSITIVE range 3 to 31  := 8;
    ieee_compliance: INTEGER  range 0 to 1   := 0
  );

  port(
    a        : in std_logic_vector(sig_width + exp_width downto 0);
    rnd      : in std_logic_vector(2 downto 0);
    z        : out std_logic_vector(sig_width + exp_width downto 0);
    status   : out std_logic_vector(7 downto 0)
  );

  end component;


  -- Content from file, DW_log2.vhdpp

  component DW_log2
   generic(op_width   : INTEGER range 2 to 60 := 8;
           arch       : INTEGER range 0 to 2 := 2;
           err_range  : INTEGER range 1 to 2 := 1);
   port(a : in std_logic_vector(op_width-1 downto 0);   
        z : out std_logic_vector(op_width-1 downto 0));
  end component;


  -- Content from file, DW_fp_log2.vhdpp

  component DW_fp_log2
   generic(sig_width : POSITIVE RANGE 2 to 59 := 10;
	   exp_width : POSITIVE RANGE 3 to 31 := 5;
           ieee_compliance : INTEGER RANGE 0 to 1 := 0;
           extra_prec : INTEGER RANGE 0 to 59 := 0;
           arch : INTEGER  RANGE 0 to 2   := 2);
   port(a : in std_logic_vector(sig_width+exp_width downto 0);  -- FP input number
        z : out std_logic_vector(sig_width+exp_width downto 0); -- FP log2(a)
        status : out std_logic_vector(7 downto 0));
  end component;


  -- Content from file, DW_exp2.vhdpp

  component DW_exp2
   generic(op_width : INTEGER range 2 to 60 := 8;
           arch       : INTEGER range 0 to 2 := 2;
           err_range  : INTEGER range 1 to 2 := 1);
   port(a : in std_logic_vector(op_width-1 downto 0);   
        z : out std_logic_vector(op_width-1 downto 0));
  end component;


  -- Content from file, DW_fp_exp2.vhdpp

  component DW_fp_exp2
   generic(sig_width : POSITIVE RANGE 2 to 58 := 10;
	   exp_width : POSITIVE RANGE 3 to 31 := 5;
           ieee_compliance : INTEGER RANGE 0 to 1 := 0;
           arch : INTEGER  RANGE 0 to 2   := 2);
   port(a : in std_logic_vector(sig_width+exp_width downto 0);  -- FP input number
        z : out std_logic_vector(sig_width+exp_width downto 0); -- FP exp2(a)
        status : out std_logic_vector(7 downto 0));
  end component;


  -- Content from file, DW_fp_exp.vhdpp

  component DW_fp_exp
   generic(sig_width : POSITIVE RANGE 2 to 57 := 10;
	   exp_width : POSITIVE RANGE 3 to 31 := 5;
           ieee_compliance : INTEGER RANGE 0 to 1 := 0;
           arch : INTEGER  RANGE 0 to 2   := 2);
   port(a : in std_logic_vector(sig_width+exp_width downto 0);  -- FP input number
        z : out std_logic_vector(sig_width+exp_width downto 0); -- FP exp(a)
        status : out std_logic_vector(7 downto 0));
  end component;


  -- Content from file, DW_ln.vhdpp

  component DW_ln
   generic(op_width   : INTEGER range 2 to 60 := 8;
           arch       : INTEGER range 0 to 1 := 0;
           err_range  : INTEGER range 1 to 2 := 1);
   port(a : in std_logic_vector(op_width-1 downto 0);   
        z : out std_logic_vector(op_width-1 downto 0));
  end component;


  -- Content from file, DW_fp_ln.vhdpp

  component DW_fp_ln
   generic(sig_width : POSITIVE RANGE 2 to 59 := 10;
	   exp_width : POSITIVE RANGE 3 to 31 := 5;
           ieee_compliance : INTEGER RANGE 0 to 1 := 0;
           extra_prec : INTEGER RANGE 0 to 59 := 0;
           arch : INTEGER  range 0 to 1   := 0);
   port(a : in std_logic_vector(sig_width+exp_width downto 0);  -- FP input number
        z : out std_logic_vector(sig_width+exp_width downto 0); -- FP ln(a)
        status : out std_logic_vector(7 downto 0));
  end component;


  -- Content from file, DW_fp_addsub_DG.vhdpp

  component DW_fp_addsub_DG
   generic(sig_width : POSITIVE range 2 to 253 := 23;
	   exp_width : POSITIVE range 3 to 31  := 8;
           ieee_compliance : INTEGER range 0 to 1 := 0);
   port(a : in std_logic_vector(sig_width+exp_width downto 0);   -- 1st FP number
        b : in std_logic_vector(sig_width+exp_width downto 0);   -- 2nd FP number
	rnd : in std_logic_vector(2 downto 0);   -- rounding
        op : in std_logic;       -- add/sub control: 0 for add - 1 for sub
        DG_ctrl : in std_logic;   -- datapath gating control: 0 = isolate inputs
        z : out std_logic_vector(sig_width+exp_width downto 0);  -- FP result
        status : out std_logic_vector(7 downto 0));
  end component;


  -- Content from file, DW_fp_add_DG.vhdpp

  component DW_fp_add_DG
   generic(sig_width : POSITIVE := 23;
	   exp_width : POSITIVE := 8;
           ieee_compliance : INTEGER := 0);
   port(a : in std_logic_vector(sig_width+exp_width downto 0);   -- 1st FP number
        b : in std_logic_vector(sig_width+exp_width downto 0);   -- 2nd FP number
	rnd : in std_logic_vector(2 downto 0);   -- rounding
        DG_ctrl : in std_logic;                   -- datapath gating control
        z : out std_logic_vector(sig_width+exp_width downto 0);  -- FP result
        status : out std_logic_vector(7 downto 0));
  end component;


  -- Content from file, DW_fp_sub_DG.vhdpp

  component DW_fp_sub_DG
   generic(sig_width : POSITIVE := 23;
	   exp_width : POSITIVE := 8;
           ieee_compliance : INTEGER := 0);
   port(a : in std_logic_vector(sig_width+exp_width downto 0);   -- 1st FP number
        b : in std_logic_vector(sig_width+exp_width downto 0);   -- 2nd FP number
	rnd : in std_logic_vector(2 downto 0);   -- rounding
        DG_ctrl : in std_logic;                   -- datapath gating control
        z : out std_logic_vector(sig_width+exp_width downto 0);  -- FP result
        status : out std_logic_vector(7 downto 0));
  end component;


  -- Content from file, DW_fp_mult_DG.vhdpp

  component DW_fp_mult_DG

  generic(
    sig_width   : POSITIVE range 2 to 253 := 23;
    exp_width   : POSITIVE range 3 to 31  := 8;
    ieee_compliance: INTEGER  range 0 to 1   := 0
  );

  port(
    a        : in std_logic_vector(sig_width + exp_width downto 0);
    b        : in std_logic_vector(sig_width + exp_width downto 0);
    rnd      : in std_logic_vector(2 downto 0);
    DG_ctrl  : in std_logic;
    z        : out std_logic_vector(sig_width + exp_width downto 0);
    status   : out std_logic_vector(7 downto 0)
  );

  end component;


  -- Content from file, DW_fp_mac_DG.vhdpp

  component DW_fp_mac_DG

  generic(
    sig_width   : POSITIVE range 2 to 253 := 23;
    exp_width   : POSITIVE range 3 to 31  := 8;
    ieee_compliance: INTEGER  range 0 to 1   := 0
  );

  port(
    a        : in std_logic_vector(sig_width + exp_width downto 0);
    b        : in std_logic_vector(sig_width + exp_width downto 0);
    c        : in std_logic_vector(sig_width + exp_width downto 0);
    rnd      : in std_logic_vector(2 downto 0);
    DG_ctrl  : in std_logic;
    z        : out std_logic_vector(sig_width + exp_width downto 0);
    status   : out std_logic_vector(7 downto 0)
  );

  end component;


  -- Content from file, DW_fp_cmp_DG.vhdpp

  component DW_fp_cmp_DG
   generic(sig_width : POSITIVE := 23;
	   exp_width : POSITIVE := 8;
           ieee_compliance : INTEGER := 0);
   port(a : in std_logic_vector(sig_width+exp_width downto 0);  -- 1st FP number
        b : in std_logic_vector(sig_width+exp_width downto 0);  -- 2nd FP number
        zctr : in std_logic;                                    -- output control
        DG_ctrl : in std_logic;                                 -- Datapath gating control
        aeqb : out std_logic;                                   -- output a=b
        altb : out std_logic;                                   -- output a<b
        agtb : out std_logic;                                   -- output a>b
        unordered : out std_logic;                              -- output when NaN input
        z0 : out std_logic_vector(sig_width+exp_width downto 0);-- FP max/min result
        z1 : out std_logic_vector(sig_width+exp_width downto 0);-- FP max/min result
        status0 : out std_logic_vector(7 downto 0);
        status1 : out std_logic_vector(7 downto 0));
  end component;


  -- Content from file, DW_fp_sum3_DG.vhdpp

  component DW_fp_sum3_DG
   generic(sig_width : POSITIVE range 2 to 253 := 23;
           exp_width : POSITIVE range 3 to 31  := 8;
           ieee_compliance : INTEGER range 0 to 1 := 0;
           arch_type : INTEGER range 0 to 1 := 0);
   port(a : in std_logic_vector(sig_width+exp_width downto 0);   -- 1st FP number
        b : in std_logic_vector(sig_width+exp_width downto 0);   -- 2nd FP number
        c : in std_logic_vector(sig_width+exp_width downto 0);   -- 3rd FP number
        rnd : in std_logic_vector(2 downto 0);                   -- rounding
        DG_ctrl : in std_logic;                                  -- DG control
        z : out std_logic_vector(sig_width+exp_width downto 0);  -- FP result
        status : out std_logic_vector(7 downto 0));
  end component;


  -- Content from file, DW_fp_div_DG.vhdpp

  component DW_fp_div_DG

  generic(
    sig_width   : POSITIVE range 2 to 253 := 23;
    exp_width   : POSITIVE range 3 to 31  := 8;
    ieee_compliance: INTEGER  range 0 to 1 := 0;
    faithful_round : INTEGER  range 0 to 1 := 0
  );

  port(
    a        : in std_logic_vector(sig_width + exp_width downto 0);
    b        : in std_logic_vector(sig_width + exp_width downto 0);
    rnd      : in std_logic_vector(2 downto 0);
    DG_ctrl  : in std_logic;
    z        : out std_logic_vector(sig_width + exp_width downto 0);
    status   : out std_logic_vector(7 downto 0)
  );

  end component;


  -- Content from file, DW_fp_recip_DG.vhdpp

  component DW_fp_recip_DG

  generic(
    sig_width      : POSITIVE range 2 to 60 := 23;
    exp_width      : POSITIVE range 3 to 31 := 8;
    ieee_compliance: INTEGER  range 0 to 1  := 0;
    faithful_round : INTEGER  range 0 to 1  := 0
  );

  port(
    a        : in std_logic_vector(sig_width + exp_width downto 0);
    rnd      : in std_logic_vector(2 downto 0);
    DG_ctrl  : in std_logic;     -- Datapath gating control pin
    z        : out std_logic_vector(sig_width + exp_width downto 0);
    status   : out std_logic_vector(7 downto 0)
  );

  end component;


  -- Content from file, DW_fp_square.vhdpp

  component DW_fp_square

  generic(
    sig_width   : POSITIVE range 2 to 253 := 23;
    exp_width   : POSITIVE range 3 to 31  := 8;
    ieee_compliance: INTEGER  range 0 to 1   := 0
  );

  port(
    a        : in std_logic_vector(sig_width + exp_width downto 0);
    rnd      : in std_logic_vector(2 downto 0);
    z        : out std_logic_vector(sig_width + exp_width downto 0);
    status   : out std_logic_vector(7 downto 0)
  );

  end component;


  -- Content from file, DW_fp_div_seq.vhdpp

  component DW_fp_div_seq

  generic(
    sig_width   : POSITIVE range 2 to 253 := 23;
    exp_width   : POSITIVE range 3 to 31  := 8;
    ieee_compliance: INTEGER  range 0 to 1   := 0;
    num_cyc     : POSITIVE := 4;
    rst_mode    : INTEGER range 0 to 1 := 0;
    input_mode  : INTEGER range 0 to 1 := 1;
    output_mode : INTEGER range 0 to 1 := 1;
    early_start : INTEGER range 0 to 1 := 0;
    internal_reg: INTEGER range 0 to 1 := 1
  );

  port(
    a        : in std_logic_vector(sig_width + exp_width downto 0);
    b        : in std_logic_vector(sig_width + exp_width downto 0);
    rnd      : in std_logic_vector(2 downto 0);
    clk      : in std_logic;
    rst_n    : in std_logic;
    start    : in std_logic;
    z        : out std_logic_vector(sig_width + exp_width downto 0);
    status   : out std_logic_vector(7 downto 0);
    complete : out std_logic
  );

  end component;


  -- Content from file, DW_sqrt_rem.vhdpp

  component DW_sqrt_rem

  generic (
    width   : positive;                    -- radicand word width
    tc_mode : integer range 0 to 1 := 0);  -- '0' : unsigned, '1' : 2's compl.

  port (
    a        : in  std_logic_vector(width-1 downto 0);         -- radicand
    root     : out std_logic_vector((width+1)/2-1 downto 0);   -- square root
    remainder: out std_logic_vector((width+1)/2 downto 0));   -- square root

  end component;


  -- Content from file, DW_fp_sqrt.vhdpp

  component DW_fp_sqrt

  generic(
    sig_width   : POSITIVE range 2 to 253 := 23;
    exp_width   : POSITIVE range 3 to 31  := 8;
    ieee_compliance: INTEGER  range 0 to 1   := 0
  );

  port(
    a        : in std_logic_vector(sig_width + exp_width downto 0);
    rnd      : in std_logic_vector(2 downto 0);
    z        : out std_logic_vector(sig_width + exp_width downto 0);
    status   : out std_logic_vector(7 downto 0)
  );

  end component;


  -- Content from file, DW_fp_mac.vhdpp

  component DW_fp_mac

  generic(
    sig_width   : POSITIVE range 2 to 253 := 23;
    exp_width   : POSITIVE range 3 to 31  := 8;
    ieee_compliance: INTEGER  range 0 to 1   := 0
  );

  port(
    a        : in std_logic_vector(sig_width + exp_width downto 0);
    b        : in std_logic_vector(sig_width + exp_width downto 0);
    c        : in std_logic_vector(sig_width + exp_width downto 0);
    rnd      : in std_logic_vector(2 downto 0);
    z        : out std_logic_vector(sig_width + exp_width downto 0);
    status   : out std_logic_vector(7 downto 0)
  );

  end component;


  -- Content from file, DW_sincos.vhdpp

  component DW_sincos

  generic( 
    A_width    : INTEGER range 2 to 34 := 24;
    WAVE_width : INTEGER range 2 to 35 := 25;
    arch       : INTEGER range 0 to 1 := 0;
    err_range  : INTEGER range 1 to 2 := 1
  );

  port(
    A       : in std_logic_vector(A_width-1 downto 0);  
    SIN_COS : in std_logic;		-- Sine -> '0', Cosine -> '1'
    WAVE    : out std_logic_vector(WAVE_width-1 downto 0)
  );


  end component;


  -- Content from file, DW_fp_sincos.vhdpp

  component DW_fp_sincos

  generic(
    sig_width      : POSITIVE range 2 to 253 := 23;
    exp_width      : POSITIVE range 3 to 31  := 8;
    ieee_compliance: INTEGER  range 0 to 1   := 0;
    pi_multiple    : INTEGER  range 0 to 1   := 1;
    arch           : INTEGER  range 0 to 1   := 0;
    err_range      : INTEGER  range 1 to 2   := 1;
    
    rcp_margin_bit : INTEGER range 0 to 32   := 5;
    round_nearest_pi : INTEGER range 0 to 1  := 1
  );

  port(
    a        : in std_logic_vector(sig_width + exp_width downto 0);
    sin_cos  : in std_logic;
    z        : out std_logic_vector(sig_width + exp_width downto 0);
    status   : out std_logic_vector(7 downto 0)
  );

  end component;


  -- Content from file, DW_lp_multifunc.vhdpp

  component DW_lp_multifunc

  generic(
    op_width        : POSITIVE range 3 to 24  := 24;
    func_select     : POSITIVE range 1 to 127 := 127
  );

  port(
    a        : in std_logic_vector(op_width downto 0);
    func     : in std_logic_vector(15 downto 0);
    z        : out std_logic_vector(op_width + 1 downto 0);
    status   : out std_logic
  );

  end component;


  -- Content from file, DW_lp_fp_multifunc.vhdpp

  component DW_lp_fp_multifunc

  generic(
    sig_width       : INTEGER range 2 to 23  := 23;
    exp_width       : INTEGER range 3 to 8   := 8;
    ieee_compliance : INTEGER range 0 to 1   := 0;
    func_select     : INTEGER range 1 to 127 := 127;
    faithful_round  : INTEGER range 0 to 1   := 1;
    pi_multiple     : INTEGER range 0 to 1   := 1;

    rcp_margin_bit  : INTEGER range 0 to 32  := 3;
    round_nearest_pi: INTEGER range 0 to 1   := 1
  );

  port(
    a        : in std_logic_vector(sig_width + exp_width downto 0);
    func     : in std_logic_vector(15 downto 0);
    rnd      : in std_logic_vector(2 downto 0);
    z        : out std_logic_vector(sig_width + exp_width downto 0);
    status   : out std_logic_vector(7 downto 0)
  );

  end component;


  -- Content from file, DW_lp_multifunc_DG.vhdpp

  component DW_lp_multifunc_DG

  generic(
    op_width        : POSITIVE range 3 to 24  := 24;
    func_select     : POSITIVE range 1 to 127 := 127
  );

  port(
    a        : in std_logic_vector(op_width downto 0);
    func     : in std_logic_vector(15 downto 0);
    DG_ctrl  : in std_logic;
    z        : out std_logic_vector(op_width + 1 downto 0);
    status   : out std_logic
  );

  end component;


  -- Content from file, DW_lp_fp_multifunc_DG.vhdpp

  component DW_lp_fp_multifunc_DG

  generic(
    sig_width       : INTEGER range 2 to 23  := 23;
    exp_width       : INTEGER range 3 to 8   := 8;
    ieee_compliance : INTEGER range 0 to 1   := 0;
    func_select     : INTEGER range 1 to 127 := 127;
    faithful_round  : INTEGER range 0 to 1   := 1;
    pi_multiple     : INTEGER range 0 to 1   := 1
  );

  port(
    a        : in std_logic_vector(sig_width + exp_width downto 0);
    func     : in std_logic_vector(15 downto 0);
    rnd      : in std_logic_vector(2 downto 0);
    DG_ctrl  : in std_logic;
    z        : out std_logic_vector(sig_width + exp_width downto 0);
    status   : out std_logic_vector(7 downto 0)
  );

  end component;


  -- Content from file, DW02_booth.vhdpp

  component DW02_booth
  generic(n: NATURAL; arch : INTEGER RANGE 0 TO 2 := 0);
  port(A : in std_logic_vector(n-1 downto 0);         -- input coefficient to be encoded
       TC : in std_logic;                             -- two's complement if TC = '1'
       A_coded : out std_logic_vector((n/2+1)*3-1 downto 0)); -- encoded partial product multipliers
  end component;


  -- Content from file, DW_bthenc.vhdpp

  component DW_bthenc

    port (
	    a : in std_logic;
	    b : in std_logic;
	    c : in std_logic;
	    shift0 : out std_logic;
	    shift1 : out std_logic;
	    compliment : out std_logic
	 );

  end component;


  -- Content from file, DW_mtree.vhdpp

  component DW_mtree
  generic(  a_width : INTEGER := 8;	-- width of orig. a operand
	    b_width : INTEGER := 8);	-- width of orig. b operand
  port(pp_array : in std_logic_vector((a_width/2+1)*(b_width+2)-1 downto 0);  
       booth_bits: in std_logic_vector(a_width/2 downto 0);
       out0, out1: out std_logic_vector(a_width+b_width downto 0));
  end component;


  -- Content from file, DW_MULTP_SC.vhdpp

  component DW_MULTP_SC

   generic( a_width: NATURAL;
            b_width: NATURAL;
	    out_width: NATURAL);

   port(a : in std_logic_vector(a_width-1 downto 0);  
        b : in std_logic_vector(b_width-1 downto 0);
        tc : in std_logic;
        out0 : out std_logic_vector(out_width-1 downto 0);
        out1 : out std_logic_vector(out_width-1 downto 0));

  end component;


  -- Content from file, DW02_mult_DG.vhdpp

  component DW02_mult_DG
   generic( A_width: NATURAL;		-- multiplier wordlength
            B_width: NATURAL);		-- multiplicand wordlength
   port(A : in std_logic_vector(A_width-1 downto 0);  
        B : in std_logic_vector(B_width-1 downto 0);
        TC : in std_logic;		-- signed -> '1', unsigned -> '0'
        DG_ctrl : in std_logic;		-- enabled -> '1', gated off -> '0'
        PRODUCT : out std_logic_vector(A_width+B_width-1 downto 0));
  end component;


  -- Content from file, DW_div_uns.vhdpp

  component DW_div_uns

  generic (
    a_width : positive;
    b_width : positive);

  port (
    a           : in  std_logic_vector(a_width-1 downto 0);
    b           : in  std_logic_vector(b_width-1 downto 0);
    quotient    : out std_logic_vector(a_width-1 downto 0);
    remainder   : out std_logic_vector(b_width-1 downto 0);
    divide_by_0 : out std_logic);

  end component;


  -- Content from file, DW_div_tc.vhdpp

  component DW_div_tc

  generic (
    a_width : positive;
    b_width : positive);

  port (
    a           : in  std_logic_vector(a_width-1 downto 0);
    b           : in  std_logic_vector(b_width-1 downto 0);
    quotient    : out std_logic_vector(a_width-1 downto 0);
    remainder   : out std_logic_vector(b_width-1 downto 0);
    divide_by_0 : out std_logic);

  end component;


  -- Content from file, DW_mod_uns.vhdpp

  component DW_mod_uns

  generic (
    a_width : positive;
    b_width : positive);

  port (
    a           : in  std_logic_vector(a_width-1 downto 0);
    b           : in  std_logic_vector(b_width-1 downto 0);
    quotient    : out std_logic_vector(a_width-1 downto 0);
    remainder   : out std_logic_vector(b_width-1 downto 0);
    divide_by_0 : out std_logic);

  end component;


  -- Content from file, DW_mod_tc.vhdpp

  component DW_mod_tc

  generic (
    a_width : positive;
    b_width : positive);

  port (
    a           : in  std_logic_vector(a_width-1 downto 0);
    b           : in  std_logic_vector(b_width-1 downto 0);
    quotient    : out std_logic_vector(a_width-1 downto 0);
    remainder   : out std_logic_vector(b_width-1 downto 0);
    divide_by_0 : out std_logic);

  end component;


  -- Content from file, DW_sqrt_uns.vhdpp

  component DW_sqrt_uns

  generic (
    width : positive);

  port (
    a    : in  std_logic_vector(width-1 downto 0);
    root : out std_logic_vector((width+1)/2-1 downto 0));

  end component;


  -- Content from file, DW_sqrt_tc.vhdpp

  component DW_sqrt_tc

  generic (
    width : positive);

  port (
    a    : in  std_logic_vector(width-1 downto 0);
    root : out std_logic_vector((width+1)/2-1 downto 0));

  end component;


  -- Content from file, DW_div_DG.vhdpp

  component DW_div_DG

  generic (
    a_width  : positive;                    -- word width of dividend, quotient
    b_width  : positive;                    -- word width of divisor, remainder
    tc_mode  : integer range 0 to 1 := 0;   -- '0' : unsigned, '1' : 2's compl.
    rem_mode : integer range 0 to 1 := 1;   -- '0' : modulus, '1' : remainder
    dg_level : natural := 0);               -- position of DG layer

  port (
    a           : in  std_logic_vector(a_width-1 downto 0);  -- dividend
    b           : in  std_logic_vector(b_width-1 downto 0);  -- divisor
    DG_ctrl     : in  std_logic;                             -- datapath gating control
    quotient    : out std_logic_vector(a_width-1 downto 0);  -- quotient
    remainder   : out std_logic_vector(b_width-1 downto 0);  -- remainder
    divide_by_0 : out std_logic);     -- divide-by-0 flag

  end component;


  -- Content from file, DW_div_tc_DG.vhdpp

  component DW_div_tc_DG

  generic (
    a_width : positive;
    b_width : positive);

  port (
    a           : in  std_logic_vector(a_width-1 downto 0);
    b           : in  std_logic_vector(b_width-1 downto 0);
    DG_ctrl     : in  std_logic;
    quotient    : out std_logic_vector(a_width-1 downto 0);
    remainder   : out std_logic_vector(b_width-1 downto 0);
    divide_by_0 : out std_logic);

  end component;


  -- Content from file, DW_div_uns_DG.vhdpp

  component DW_div_uns_DG

  generic (
    a_width : positive;
    b_width : positive);

  port (
    a           : in  std_logic_vector(a_width-1 downto 0);
    b           : in  std_logic_vector(b_width-1 downto 0);
    DG_ctrl     : in  std_logic;
    quotient    : out std_logic_vector(a_width-1 downto 0);
    remainder   : out std_logic_vector(b_width-1 downto 0);
    divide_by_0 : out std_logic);

  end component;


  -- Content from file, DW_mod_tc_DG.vhdpp

  component DW_mod_tc_DG

  generic (
    a_width : positive;
    b_width : positive);

  port (
    a           : in  std_logic_vector(a_width-1 downto 0);
    b           : in  std_logic_vector(b_width-1 downto 0);
    DG_ctrl     : in  std_logic;
    quotient    : out std_logic_vector(a_width-1 downto 0);
    remainder   : out std_logic_vector(b_width-1 downto 0);
    divide_by_0 : out std_logic);

  end component;


  -- Content from file, DW_mod_uns_DG.vhdpp

  component DW_mod_uns_DG

  generic (
    a_width : positive;
    b_width : positive);

  port (
    a           : in  std_logic_vector(a_width-1 downto 0);
    b           : in  std_logic_vector(b_width-1 downto 0);
    DG_ctrl     : in  std_logic;
    quotient    : out std_logic_vector(a_width-1 downto 0);
    remainder   : out std_logic_vector(b_width-1 downto 0);
    divide_by_0 : out std_logic);

  end component;


  -- Content from file, DW02_components.commonpp

  type power is (minus_one, zero, one_half, one, two);

  function "**" (a : unsigned; p : power) return unsigned;
  function "**" (a : signed; p : power) return signed;
  function "**" (a : signed; p : power) return unsigned;
  function "**" (a : unsigned; p : power) return std_logic_vector;
  function "**" (a : signed; p : power) return std_logic_vector;


  -- Content from file, DW02_sum.vhdpp

    function DWF_sum(A: UNSIGNED; NUM_INPUTS: INTEGER) return UNSIGNED;
    function DWF_sum(A: SIGNED; NUM_INPUTS: INTEGER) return SIGNED;
    function DW_sum(A: UNSIGNED; NUM_INPUTS: INTEGER) return UNSIGNED;
    function DW_sum(A: SIGNED; NUM_INPUTS: INTEGER) return SIGNED;


  -- Content from file, DW02_mac.vhdpp

    function DWF_mac(A: SIGNED; B: SIGNED; C: SIGNED) return SIGNED;
    function DWF_mac(A: UNSIGNED; B: UNSIGNED; C: UNSIGNED) return UNSIGNED;
    function DW_mac(A: SIGNED; B: SIGNED; C: SIGNED) return SIGNED;
    function DW_mac(A: UNSIGNED; B: UNSIGNED; C: UNSIGNED) return UNSIGNED;


  -- Content from file, DW02_mult_2_stage.vhdpp



  -- Content from file, DW02_mult_3_stage.vhdpp



  -- Content from file, DW02_mult_4_stage.vhdpp



  -- Content from file, DW02_mult_5_stage.vhdpp



  -- Content from file, DW02_mult_6_stage.vhdpp



  -- Content from file, DW_square.vhdpp


  function DWF_square(A: UNSIGNED) return UNSIGNED;
  function DWF_square(A: SIGNED) return SIGNED;


  -- Content from file, DW_div.vhdpp

  function "/" (A : unsigned; B : unsigned) return unsigned;
  function "/" (A : signed; B : signed) return signed;
  function "/" (A : signed; B : unsigned) return signed;
  function "/" (A : unsigned; B : signed) return signed;
  function "/" (A : unsigned; B : unsigned) return std_logic_vector;
  function "/" (A : signed; B : signed) return std_logic_vector;
  function "/" (A : signed; B : unsigned) return std_logic_vector;
  function "/" (A : unsigned; B : signed) return std_logic_vector;
  function "rem" (A : unsigned; B : unsigned) return unsigned;
  function "rem" (A : signed; B : signed) return signed;
  function "rem" (A : signed; B : unsigned) return signed;
  function "rem" (A : unsigned; B : signed) return signed;
  function "rem" (A : unsigned; B : unsigned) return std_logic_vector;
  function "rem" (A : signed; B : signed) return std_logic_vector;
  function "rem" (A : signed; B : unsigned) return std_logic_vector;
  function "rem" (A : unsigned; B : signed) return std_logic_vector;
  function "mod" (A : unsigned; B : unsigned) return unsigned;
  function "mod" (A : signed; B : signed) return signed;
  function "mod" (A : signed; B : unsigned) return signed;
  function "mod" (A : unsigned; B : signed) return signed;
  function "mod" (A : unsigned; B : unsigned) return std_logic_vector;
  function "mod" (A : signed; B : signed) return std_logic_vector;
  function "mod" (A : signed; B : unsigned) return std_logic_vector;
  function "mod" (A : unsigned; B : signed) return std_logic_vector;
  function DWF_div (A, B : unsigned) return unsigned;
  function DWF_div (A, B : signed) return signed;
  function DWF_rem (A, B : unsigned) return unsigned;
  function DWF_rem (A, B : signed) return signed;
  function DWF_mod (A, B : unsigned) return unsigned;
  function DWF_mod (A, B : signed) return signed;
  function DWF_divide (A, B : unsigned) return unsigned;
  function DWF_divide (A, B : signed) return signed;
  function DW_divide (A, B : unsigned) return unsigned;
  function DW_divide (A, B : signed) return signed;
  function DW_rem (A, B : unsigned) return unsigned;
  function DW_rem (A, B : signed) return signed;
  function DW_mod (A, B : unsigned) return unsigned;
  function DW_mod (A, B : signed) return signed;
  function DWF_vhd_mod (A, B : unsigned) return unsigned;
  function DWF_vhd_mod (A, B : signed) return signed;
  function DW_func_vhd_mod (A, B : unsigned) return unsigned;
  function DW_func_vhd_mod (A, B : signed) return signed;
  function DWF_ver_mod (A, B : unsigned) return unsigned;
  function DWF_ver_mod (A, B : signed) return signed;
  function DW_func_ver_mod (A, B : unsigned) return unsigned;
  function DW_func_ver_mod (A, B : signed) return signed;


  -- Content from file, DW_div_sat.vhdpp

  function DWF_div_sat (A, B : unsigned; q_width : positive) return unsigned;
  function DWF_div_sat (A, B : signed; q_width : positive) return signed;


  -- Content from file, DW_sqrt.vhdpp

  function DWF_sqrt (A : unsigned) return unsigned;
  function DWF_sqrt (A : signed) return unsigned;
  function sqrt (A : unsigned) return unsigned;
  function sqrt (A : signed) return unsigned;


end DW02_components;


package body DW02_components is


  -- Content from file, DW02_components.commonpp

  -- Function operator definitions for "**"-operator inference

  function "**" (a : unsigned; p : power) return unsigned is
    constant all_zero : unsigned(a'length-2 downto 0) := (others => '0');
  begin
    case p is
      when minus_one => return DWF_div ('1' & all_zero, a);
      when zero      => return all_zero & '1';
      when one_half  => return DWF_sqrt (a);
      when one       => return a;
      when two       => return DWF_square (a);
    end case;
  end;

  function "**" (a : signed; p : power) return signed is
    constant all_zero : signed(a'length-3 downto 0) := (others => '0');
  begin
    case p is
      when minus_one => return DWF_div ("01" & all_zero, a);
      when zero      => return '0' & all_zero & '1';
      when one_half  => return signed('0' & DWF_sqrt (a));
      when one       => return a;
      when two       => return DWF_square (a);
    end case;
  end;

  function "**" (a : signed; p : power) return unsigned is
  begin
    -- this combination of types is only defined for square root
    return DWF_sqrt (a);
  end;

  function "**" (a : unsigned; p : power) return std_logic_vector is
    constant all_zero : unsigned(a'length-2 downto 0) := (others => '0');
  begin
    case p is
      when minus_one => return std_logic_vector(DWF_div ('1' & all_zero, a));
      when zero      => return std_logic_vector(all_zero & '1');
      when one_half  => return std_logic_vector(DWF_sqrt (a));
      when one       => return std_logic_vector(a);
      when two       => return std_logic_vector(DWF_square (a));
    end case;
  end;

  function "**" (a : signed; p : power) return std_logic_vector is
    constant all_zero : signed(a'length-3 downto 0) := (others => '0');
  begin
    case p is
      when minus_one => return std_logic_vector(DWF_div ("01" & all_zero, a));
      when zero      => return std_logic_vector('0' & all_zero & '1');
      when one_half  => return std_logic_vector(DWF_sqrt (a));
      when one       => return std_logic_vector(a);
      when two       => return std_logic_vector(DWF_square (a));
    end case;
  end;


  -- Content from file, DW02_sum.vhdpp

-- 	Type propagation functions used internally for component inferencing

    function SUM_UNSIGNED_ARG(A: UNSIGNED; NUM_INPUTS: INTEGER)
             return UNSIGNED is
      constant output_width: INTEGER := A'length/NUM_INPUTS;
      variable Z: UNSIGNED(output_width-1 downto 0);
      -- pragma return_port_name Z
    begin
      return(Z);
    end;

--         Type propagation functions used internally for component inferencing

    function SUM_SIGNED_ARG(A: SIGNED; NUM_INPUTS: INTEGER)
             return SIGNED is
      constant output_width: INTEGER := A'length/NUM_INPUTS;
      variable Z: SIGNED(output_width-1 downto 0);
      -- pragma return_port_name Z
    begin
      -- returning unsigned because bound to unsigned syn operator
      return(Z);
    end;
    
-- 	Function Operator Definitions

-- 	Function Definitions
 
    function DWF_sum(A: UNSIGNED; NUM_INPUTS: INTEGER) return UNSIGNED is
      -- pragma map_to_operator SUM_UNS_OP
      -- pragma type_function SUM_UNSIGNED_ARG
      -- pragma return_port_name Z
      constant output_width: INTEGER := A'length/NUM_INPUTS;
      subtype M_ROW is UNSIGNED(output_width-1 downto 0);
      type ARRAY_N_M is array (NUM_INPUTS-1 downto 0) of M_ROW;
      variable sum_input : ARRAY_N_M;
      variable Z : UNSIGNED(output_width-1 downto 0);
      variable A_tmp : UNSIGNED(A'length-1 downto 0);
    begin
	   A_tmp := A;
      for i in 1 to NUM_INPUTS loop
        sum_input(i-1) := A_tmp(i*output_width-1 downto (i-1)*output_width);
      end loop;
      Z := sum_input(0);
      if NUM_INPUTS > 1 then
        for i in 1 to NUM_INPUTS-1 loop
          Z := Z + sum_input(i);
        end loop;
      end if;
      return(Z);
    end;
    
    function DWF_sum(A: SIGNED; NUM_INPUTS: INTEGER) return SIGNED is
      -- pragma map_to_operator SUM_TC_OP
      -- pragma type_function SUM_SIGNED_ARG
      -- pragma return_port_name Z
      constant output_width: INTEGER := A'length/NUM_INPUTS;
      subtype M_ROW is SIGNED(output_width-1 downto 0);
      type ARRAY_N_M is array (NUM_INPUTS-1 downto 0) of M_ROW;
      variable sum_input : ARRAY_N_M;
      variable Z : SIGNED(output_width-1 downto 0);
      variable A_tmp : SIGNED(A'length-1 downto 0);
    begin
 	   A_tmp := A;
      for i in 1 to NUM_INPUTS loop
        sum_input(i-1) := A_tmp(i*output_width-1 downto (i-1)*output_width);
      end loop;
      Z := sum_input(0);
      if NUM_INPUTS > 1 then
        for i in 1 to NUM_INPUTS-1 loop
          Z := Z + sum_input(i);
        end loop;
      end if;
      return(Z);
    end;

    function DW_sum(A: UNSIGNED; NUM_INPUTS: INTEGER) return UNSIGNED is
    begin
      return(DWF_sum(A,NUM_INPUTS));
    end;

    function DW_sum(A: SIGNED; NUM_INPUTS: INTEGER) return SIGNED is
    begin
      return(DWF_sum(A,NUM_INPUTS));
    end;


  -- Content from file, DW02_mac.vhdpp

    function MAC_SIGNED_ARG(A,B,C: SIGNED) return SIGNED is
      variable Z: SIGNED ((A'length+B'length-1) downto 0);
      -- pragma return_port_name Z
    begin
      return(Z);
    end;
	
    function MAC_UNSIGNED_ARG(A,B,C: UNSIGNED) return UNSIGNED is
      variable Z: UNSIGNED ((A'length+B'length-1) downto 0);
      -- pragma return_port_name Z
    begin
      return(Z);
    end;

    function DWF_mac(A: SIGNED; B: SIGNED; C: SIGNED) return SIGNED is
      -- pragma map_to_operator MAC_TC_OP
      -- pragma type_function MAC_SIGNED_ARG
      -- pragma return_port_name Z
    begin
      return(A*B+C);
    end;    
    
    function DWF_mac(A: UNSIGNED; B: UNSIGNED; C: UNSIGNED) return UNSIGNED is
      -- pragma map_to_operator MAC_UNS_OP
      -- pragma type_function MAC_UNSIGNED_ARG
      -- pragma return_port_name Z
    begin
      return(A*B+C);
    end;    
    

    function DW_mac(A: SIGNED; B: SIGNED; C: SIGNED) return SIGNED is
      -- pragma map_to_operator MAC_TC_OP
      -- pragma type_function MAC_SIGNED_ARG
      -- pragma return_port_name Z
    begin
      return(DWF_mac(A,B,C));
    end;

    function DW_mac(A: UNSIGNED; B: UNSIGNED; C: UNSIGNED) return UNSIGNED is
      -- pragma map_to_operator MAC_UNS_OP
      -- pragma type_function MAC_UNSIGNED_ARG
      -- pragma return_port_name Z
    begin
      return(DWF_mac(A,B,C));
    end;



  -- Content from file, DW02_mult_2_stage.vhdpp



  -- Content from file, DW02_mult_3_stage.vhdpp



  -- Content from file, DW02_mult_4_stage.vhdpp



  -- Content from file, DW02_mult_5_stage.vhdpp



  -- Content from file, DW02_mult_6_stage.vhdpp



  -- Content from file, DW_square.vhdpp

-- 	Type propagation functions used internally for component inferencing

  function SQR_UNSIGNED_ARG(A: UNSIGNED) return UNSIGNED is
      constant SQR_width    : POSITIVE := A'length * 2;
      variable SQUARE          : UNSIGNED(SQR_width-1 downto 0);
      -- pragma return_port_name SQUARE
    begin
      return(SQUARE);
  end;

  function SQR_SIGNED_ARG(A: SIGNED) return SIGNED is
      constant SQR_width    : POSITIVE := A'length * 2;
      variable SQUARE         : SIGNED(SQR_width-1 downto 0);
      -- pragma return_port_name SQUARE
    begin
      return(SQUARE);
  end;


-- 	Function Definitions

  function DWF_square(A: UNSIGNED) return UNSIGNED is
    variable SQR    : UNSIGNED(A'length*2-1 downto 0);
    -- pragma map_to_operator SQR_UNS_OP
    -- pragma type_function SQR_UNSIGNED_ARG
    -- pragma return_port_name SQUARE
  begin
    SQR := A * A;
    return(SQR);
  end;
 
  function DWF_square(A: SIGNED) return SIGNED is
    variable SQR    : SIGNED(A'length*2-1 downto 0);
    -- pragma map_to_operator SQR_TC_OP
    -- pragma type_function SQR_SIGNED_ARG
    -- pragma return_port_name SQUARE
  begin
    SQR := A * A;
    return(SQR);
  end;


  -- Content from file, DW_div.vhdpp

  -- Internal function for behavioral modeling

  procedure DIV_REM (a, b : in unsigned; quotient, remainder : out unsigned) is
    variable a_norm : unsigned(a'length-1 downto 0) := a;
    variable b_norm : unsigned(b'length-1 downto 0) := b;
    variable temp_quot : unsigned(maximum (a'length, b'length)-1 downto 0);
    variable temp_rem : unsigned(a'length downto 0);
    variable top_bit : integer;
  begin
    -- pragma translate_off
    if (Is_X (std_logic_vector(a_norm))) or (Is_X (std_logic_vector(b_norm))) then
      temp_quot := (others => 'X');
      temp_rem := (others => 'X');
    else
      top_bit := -1;
      for i in b_norm'range loop
        if b_norm(i) = '1' then
          top_bit := i;
          exit;
        end if;
      end loop;
      assert top_bit >= 0 report "WARNING: Division by zero" severity warning;
      temp_rem := "0" & a_norm;
      temp_quot := (others => '0');
      for i in a'length-top_bit-1 downto 0 loop
        if temp_rem(top_bit+i+1 downto i) >= "0" & b_norm(top_bit downto 0) then
          temp_rem(top_bit+i+1 downto i) :=
            temp_rem(top_bit+i+1 downto i) - ("0" & b_norm(top_bit downto 0));
          temp_quot(i) := '1';
        end if;
      end loop;
    end if;
    quotient := temp_quot(a'length-1 downto 0);
    remainder := conv_unsigned(temp_rem, b'length);
    -- pragma translate_on
  end DIV_REM;


  --  Internal type propagation functions for component inferencing

  function DIV_UNSIGNED_ARG (A, B : unsigned)
    return unsigned is
    constant QUOTIENT_width : positive := A'length;
    variable QUOTIENT : unsigned(QUOTIENT_width-1 downto 0);
    -- pragma return_port_name QUOTIENT
  begin
    return QUOTIENT;
  end DIV_UNSIGNED_ARG;

  function DIV_SIGNED_ARG (A, B : signed)
    return signed is
    constant QUOTIENT_width : positive := A'length;
    variable QUOTIENT : signed(QUOTIENT_width-1 downto 0);
    -- pragma return_port_name QUOTIENT
  begin
    return QUOTIENT;
  end DIV_SIGNED_ARG;
  
  function REM_UNSIGNED_ARG (A, B : unsigned)
    return unsigned is
    constant REMAINDER_width : positive := B'length;
    variable REMAINDER : unsigned(REMAINDER_width-1 downto 0);
    -- pragma return_port_name REMAINDER
  begin
    return REMAINDER;
  end REM_UNSIGNED_ARG;

  function REM_SIGNED_ARG (A, B : signed)
    return signed is
    constant REMAINDER_width : positive := B'length;
    variable REMAINDER : signed(REMAINDER_width-1 downto 0);
    -- pragma return_port_name REMAINDER
  begin
    return REMAINDER;
  end REM_SIGNED_ARG;
  
  function MOD_UNSIGNED_ARG (A, B : unsigned)
    return unsigned is
    constant REMAINDER_width : positive := B'length;
    variable REMAINDER : unsigned(REMAINDER_width-1 downto 0);
    -- pragma return_port_name REMAINDER
  begin
    return REMAINDER;
  end MOD_UNSIGNED_ARG;

  function MOD_SIGNED_ARG (A, B : signed)
    return signed is
    constant REMAINDER_width : positive := B'length;
    variable REMAINDER : signed(REMAINDER_width-1 downto 0);
    -- pragma return_port_name REMAINDER
  begin
    return REMAINDER;
  end MOD_SIGNED_ARG;


  -- Function operator definitions

  function "/" (A : unsigned; B : unsigned) return unsigned is
  begin
    return DWF_div (A, B);
  end;
  
  function "/" (A : signed; B : signed) return signed is
  begin
    return DWF_div (A, B);
  end;
  
  function "/" (A : signed; B : unsigned) return signed is
  begin
    return DWF_div (A, conv_signed(B, B'length+1));
  end;
  
  function "/" (A : unsigned; B : signed) return signed is
  begin
    return DWF_div (conv_signed(A, A'length+1), B);
  end;
  
  function "/" (A : unsigned; B : unsigned) return std_logic_vector is
  begin
    return std_logic_vector(DWF_div (A, B));
  end;
  
  function "/" (A : signed; B : signed) return std_logic_vector is
  begin
    return std_logic_vector(DWF_div (A, B));
  end;
  
  function "/" (A : signed; B : unsigned) return std_logic_vector is
  begin
    return std_logic_vector(DWF_div (A, conv_signed(B, B'length+1)));
  end;
  
  function "/" (A : unsigned; B : signed) return std_logic_vector is
  begin
    return std_logic_vector(DWF_div (conv_signed(A, A'length+1), B));
  end;

  function "rem" (A : unsigned; B : unsigned) return unsigned is
  begin
    return DWF_rem (A, B);
  end;
  
  function "rem" (A : signed; B : signed) return signed is
  begin
    return DWF_rem (A, B);
  end;
  
  function "rem" (A : signed; B : unsigned) return signed is
  begin
    return DWF_rem (A, conv_signed(B, B'length+1));
  end;
  
  function "rem" (A : unsigned; B : signed) return signed is
  begin
    return DWF_rem (conv_signed(A, A'length+1), B);
  end;
  
  function "rem" (A : unsigned; B : unsigned) return std_logic_vector is
  begin
    return std_logic_vector(DWF_rem (A, B));
  end;
  
  function "rem" (A : signed; B : signed) return std_logic_vector is
  begin
    return std_logic_vector(DWF_rem (A, B));
  end;
  
  function "rem" (A : signed; B : unsigned) return std_logic_vector is
  begin
    return std_logic_vector(DWF_rem (A, conv_signed(B, B'length+1)));
  end;
  
  function "rem" (A : unsigned; B : signed) return std_logic_vector is
  begin
    return std_logic_vector(DWF_rem (conv_signed(A, A'length+1), B));
  end;

  function "mod" (A : unsigned; B : unsigned) return unsigned is
  begin
    return DWF_mod (A, B);
  end;
  
  function "mod" (A : signed; B : signed) return signed is
  begin
    return DWF_mod (A, B);
  end;
  
  function "mod" (A : signed; B : unsigned) return signed is
  begin
    return DWF_mod (A, conv_signed(B, B'length+1));
  end;
  
  function "mod" (A : unsigned; B : signed) return signed is
  begin
    return DWF_mod (conv_signed(A, A'length+1), B);
  end;
  
  function "mod" (A : unsigned; B : unsigned) return std_logic_vector is
  begin
    return std_logic_vector(DWF_mod (A, B));
  end;
  
  function "mod" (A : signed; B : signed) return std_logic_vector is
  begin
    return std_logic_vector(DWF_mod (A, B));
  end;
  
  function "mod" (A : signed; B : unsigned) return std_logic_vector is
  begin
    return std_logic_vector(DWF_mod (A, conv_signed(B, B'length+1)));
  end;
  
  function "mod" (A : unsigned; B : signed) return std_logic_vector is
  begin
    return std_logic_vector(DWF_mod (conv_signed(A, A'length+1), B));
  end;


  -- Function definitions
  
  function DWF_div (A, B : unsigned) return unsigned is
    -- pragma map_to_operator DIV_UNS_OP
    -- pragma type_function DIV_UNSIGNED_ARG
    -- pragma return_port_name QUOTIENT
    constant max_uns : unsigned(A'length-1 downto 0) := (others => '1');
    variable quot_uns : unsigned(A'length-1 downto 0);
    variable rem_uns : unsigned(B'length-1 downto 0);
  begin
    -- pragma translate_off
    if B = 0 then
      quot_uns := max_uns;
      assert false report "WARNING: Division by zero" severity warning;
    else
      DIV_REM (A, B, quot_uns, rem_uns);
    end if;
    return quot_uns;
    -- pragma translate_on
  end DWF_div;

  function DWF_div (A, B : signed) return signed is
    -- pragma map_to_operator DIV_TC_OP
    -- pragma type_function DIV_SIGNED_ARG
    -- pragma return_port_name QUOTIENT
    constant min_sgn : signed(A'length-1 downto 0) :=
      '1' & (A'length-2 downto 0 => '0');
    constant max_sgn : signed(A'length-1 downto 0) :=
      '0' & (A'length-2 downto 0 => '1');
    variable A_uns : unsigned(A'length-1 downto 0);
    variable B_uns : unsigned(B'length-1 downto 0);
    variable quot_uns : unsigned(A'length-1 downto 0);
    variable rem_uns : unsigned(B'length-1 downto 0);
    variable quot_sgn : signed(A'length-1 downto 0);
  begin
    -- pragma translate_off
    if B = 0 then
      if A >= 0 then
        quot_sgn := max_sgn;
      else
        quot_sgn := min_sgn;
      end if;
      assert false report "WARNING: Division by zero" severity warning;
    else
      if A(A'left) = '0' then
        A_uns := unsigned(A);
      else
        A_UNS := unsigned(signed'(-A));
      end if;
      if B(B'left) = '0' then
        B_uns := unsigned(B);
      else
        B_uns := unsigned(signed'(-B));
      end if;
      DIV_REM (A_uns, B_uns, quot_uns, rem_uns);
      if A(A'left) = B(B'left) then
        quot_sgn := signed(quot_uns);
      else
        quot_sgn := -signed(quot_uns);
      end if;
    end if;
    return quot_sgn;
    -- pragma translate_on
  end DWF_div;
  
  function DWF_rem (A, B : unsigned) return unsigned is
    -- pragma map_to_operator REM_UNS_OP
    -- pragma type_function REM_UNSIGNED_ARG
    -- pragma return_port_name REMAINDER
    variable quot_uns : unsigned(A'length-1 downto 0);
    variable rem_uns : unsigned(B'length-1 downto 0);
  begin
    -- pragma translate_off
    if B = 0 then
      rem_uns := conv_unsigned(A, B'length);
      assert false report "WARNING: Division by zero" severity warning;
    else
      DIV_REM (A, B, quot_uns, rem_uns);
    end if;
    return rem_uns;
    -- pragma translate_on
  end DWF_rem;

  function DWF_rem (A, B : signed) return signed is
    -- pragma map_to_operator REM_TC_OP
    -- pragma type_function REM_SIGNED_ARG
    -- pragma return_port_name REMAINDER
    constant minus_one : signed(B'length-1 downto 0) := (others => '1');
    variable A_uns : unsigned(A'length-1 downto 0);
    variable B_uns : unsigned(B'length-1 downto 0);
    variable quot_uns : unsigned(A'length-1 downto 0);
    variable rem_uns : unsigned(B'length-1 downto 0);
    variable rem_sgn : signed(B'length-1 downto 0);
  begin
    -- pragma translate_off
    if B = 0 then
      rem_sgn := conv_signed(A, B'length);
      assert false report "WARNING: Division by zero" severity warning;
    else
      if A(A'left) = '0' then
        A_uns := unsigned(A);
      else
        A_uns := unsigned(signed'(-A));
      end if;
      if B(B'left) = '0' then
        B_uns := unsigned(B);
      else
        B_uns := unsigned(signed'(-B));
      end if;
      DIV_REM (A_uns, B_uns, quot_uns, rem_uns);
      if A(A'left) = '0' then
        rem_sgn := signed(rem_uns);
      else
        rem_sgn := -signed(rem_uns);
      end if;
    end if;
    return rem_sgn;
    -- pragma translate_on
  end DWF_rem;
  
  function DWF_mod (A, B : unsigned) return unsigned is
    -- pragma map_to_operator MOD_UNS_OP
    -- pragma type_function MOD_UNSIGNED_ARG
    -- pragma return_port_name REMAINDER
    variable quot_uns : unsigned(A'length-1 downto 0);
    variable rem_uns : unsigned(B'length-1 downto 0);
    variable mod_uns : unsigned(B'length-1 downto 0);
  begin
    -- pragma translate_off
    if B = 0 then
      mod_uns := conv_unsigned(A, B'length);
      assert false report "WARNING: Division by zero" severity warning;
    else
      DIV_REM (A, B, quot_uns, rem_uns);
      mod_uns := rem_uns;
    end if;
    return mod_uns;
    -- pragma translate_on
  end DWF_mod;

  function DWF_mod (A, B : signed) return signed is
    -- pragma map_to_operator MOD_TC_OP
    -- pragma type_function MOD_SIGNED_ARG
    -- pragma return_port_name REMAINDER
    constant minus_one : signed(B'length-1 downto 0) := (others => '1');
    variable A_uns : unsigned(A'length-1 downto 0);
    variable B_uns : unsigned(B'length-1 downto 0);
    variable quot_uns : unsigned(A'length-1 downto 0);
    variable rem_uns : unsigned(B'length-1 downto 0);
    variable mod_sgn : signed(B'length-1 downto 0);
  begin
    -- pragma translate_off
    if B = 0 then
      mod_sgn := conv_signed(A, B'length);
      assert false report "WARNING: Division by zero" severity warning;
    else
      if A(A'left) = '0' then
        A_uns := unsigned(A);
      else
        A_uns := unsigned(signed'(-A));
      end if;
      if B(B'left) = '0' then
        B_uns := unsigned(B);
      else
        B_uns := unsigned(signed'(-B));
      end if;
      DIV_REM (A_uns, B_uns, quot_uns, rem_uns);
      if rem_uns = 0 then
        mod_sgn := signed(rem_uns);
      else
        if A(A'left) = '0' then
          mod_sgn := signed(rem_uns);
        else
          mod_sgn := - signed(rem_uns);
        end if;
        if A(A'left) /= B(B'left) then
          mod_sgn := B + mod_sgn;
        end if;
      end if;
    end if;
    return mod_sgn;
    -- pragma translate_on
  end DWF_mod;
 

  -- Old function definitions
  
  function DWF_divide (A, B : unsigned) return unsigned is
  begin
    return conv_unsigned(DWF_div (conv_unsigned(A, maximum(A'length, B'length)), B), A'length);
  end DWF_divide;

  function DWF_divide (A, B : signed) return signed is
  begin
    return conv_signed(DWF_div (conv_signed(A, maximum(A'length, B'length)), B), A'length);
  end DWF_divide;
  
  function DW_divide (A, B : unsigned) return unsigned is
  begin
    return conv_unsigned(DWF_div (conv_unsigned(A, maximum(A'length, B'length)), B), A'length);
  end DW_divide;

  function DW_divide (A, B : signed) return signed is
  begin
    return conv_signed(DWF_div (conv_signed(A, maximum(A'length, B'length)), B), A'length);
  end DW_divide;
  
  function DW_rem (A, B : unsigned) return unsigned is
  begin
    return DWF_rem (conv_unsigned(A, maximum(A'length, B'length)), B);
  end DW_rem;

  function DW_rem (A, B : signed) return signed is
  begin
    return DWF_rem (conv_signed(A, maximum(A'length, B'length)), B);
  end DW_rem;
  
  function DW_mod (A, B : unsigned) return unsigned is
  begin
    return DWF_mod (conv_unsigned(A, maximum(A'length, B'length)), B);
  end DW_mod;

  function DW_mod (A, B : signed) return signed is
  begin
    return DWF_mod (conv_signed(A, maximum(A'length, B'length)), B);
  end DW_mod;
  
  function DWF_vhd_mod (A, B : unsigned) return unsigned is
  begin
    return DWF_mod (conv_unsigned(A, maximum(A'length, B'length)), B);
  end DWF_vhd_mod;

  function DWF_vhd_mod (A, B : signed) return signed is
  begin
    return DWF_mod (conv_signed(A, maximum(A'length, B'length)), B);
  end DWF_vhd_mod;
  
  function DW_func_vhd_mod (A, B : unsigned) return unsigned is
  begin
    return DWF_mod (conv_unsigned(A, maximum(A'length, B'length)), B);
  end DW_func_vhd_mod;

  function DW_func_vhd_mod (A, B : signed) return signed is
  begin
    return DWF_mod (conv_signed(A, maximum(A'length, B'length)), B);
  end DW_func_vhd_mod;
  
  function DWF_ver_mod (A, B : unsigned) return unsigned is
  begin
    return DWF_rem (conv_unsigned(A, maximum(A'length, B'length)), B);
  end DWF_ver_mod;

  function DWF_ver_mod (A, B : signed) return signed is
  begin
    return DWF_rem (conv_signed(A, maximum(A'length, B'length)), B);
  end DWF_ver_mod;
  
  function DW_func_ver_mod (A, B : unsigned) return unsigned is
  begin
    return DWF_rem (conv_unsigned(A, maximum(A'length, B'length)), B);
  end DW_func_ver_mod;

  function DW_func_ver_mod (A, B : signed) return signed is
  begin
    return DWF_rem (conv_signed(A, maximum(A'length, B'length)), B);
  end DW_func_ver_mod;


  -- Content from file, DW_div_sat.vhdpp

  function DWF_div_sat (A, B : unsigned; q_width : positive) return unsigned is
    constant max_uns : unsigned(q_width-1 downto 0) := (others => '1');
    variable quot_uns : unsigned(A'length-1 downto 0);
    variable quotient : unsigned(q_width-1 downto 0);
    variable rem_uns : unsigned(B'length-1 downto 0);
  begin
    -- pragma translate_off
    if B = 0 then
      quotient := max_uns;
      assert false report "WARNING: Division by zero" severity warning;
    else
      DIV_REM (A, B, quot_uns, rem_uns);
      if q_width < A'length then
        if or_reduce (std_logic_vector(quot_uns(A'length-1 downto q_width))) = '1' then
          quotient := (q_width-1 downto 0 => '1');
        else
          quotient := quot_uns(q_width-1 downto 0);
        end if;
      else
        quotient := conv_unsigned (quot_uns, q_width);
      end if;
    end if;
    return quotient;
    -- pragma translate_on
  end DWF_div_sat;

  function DWF_div_sat (A, B : signed; q_width : positive) return signed is
    constant min_sgn : signed(q_width-1 downto 0) :=
      '1' & (q_width-2 downto 0 => '0');
    constant max_sgn : signed(q_width-1 downto 0) :=
      '0' & (q_width-2 downto 0 => '1');
    variable A_uns : unsigned(A'length-1 downto 0);
    variable B_uns : unsigned(B'length-1 downto 0);
    variable quot_uns : unsigned(A'length-1 downto 0);
    variable rem_uns : unsigned(B'length-1 downto 0);
    variable quot_sgn : signed(A'length-1 downto 0);
    variable quotient : signed(q_width-1 downto 0);
  begin
    -- pragma translate_off
    if B = 0 then
      if A >= 0 then
        quotient := max_sgn;
      else
        quotient := min_sgn;
      end if;
      assert false report "WARNING: Division by zero" severity warning;
    else
      if A(A'left) = '0' then
        A_uns := unsigned(A);
      else
        A_uns := unsigned(signed'(-A));
      end if;
      if B(B'left) = '0' then
        B_uns := unsigned(B);
      else
        B_uns := unsigned(signed'(-B));
      end if;
      DIV_REM (A_uns, B_uns, quot_uns, rem_uns);
      if A(A'left) = B(B'left) then
        quot_sgn := signed(quot_uns);
      else
        quot_sgn := -signed(quot_uns);
      end if;
      if (a = signed'('1' & (A'length-2 downto 0 => '0'))) and
         (b = signed'(B'length-1 downto 0 => '1')) then
        quotient := ('0' & (q_width-2 downto 0 => '1'));
      elsif q_width < A'length then
        if (quot_sgn(A'length-1) = '0') and
          (or_reduce (std_logic_vector(quot_sgn(A'length-2 downto q_width-1))) = '1') then
          quotient := ('0' & (q_width-2 downto 0 => '1'));
        elsif (quot_sgn(A'length-1) = '1') and
          (and_reduce (std_logic_vector(quot_sgn(A'length-2 downto q_width-1))) = '0') then
          quotient := ('1' & (q_width-2 downto 0 => '0'));
        else
          quotient := quot_sgn(q_width-1 downto 0);
        end if;
      else
        quotient := conv_signed (quot_sgn, q_width);
      end if;
    end if;
    return quotient;
    -- pragma translate_on
  end DWF_div_sat;


  -- Content from file, DW_sqrt.vhdpp

  --  Internal type propagation functions for component inferencing

  function SQRT_UNSIGNED_ARG (A : unsigned) return unsigned is
    constant ROOT_width : positive := (A'length+1)/2;
    variable ROOT : unsigned(ROOT_width-1 downto 0);
    -- pragma return_port_name ROOT
  begin
    return ROOT;
  end SQRT_UNSIGNED_ARG;

  function SQRT_SIGNED_ARG (A : signed) return unsigned is
    constant ROOT_width : positive := (A'length+1)/2;
    variable ROOT : unsigned(ROOT_width-1 downto 0);
    -- pragma return_port_name ROOT
  begin
    return ROOT;
  end SQRT_SIGNED_ARG;


  -- Function definitions
  
  function DWF_sqrt (A : unsigned) return unsigned is
    -- pragma map_to_operator SQRT_UNS_OP
    -- pragma type_function SQRT_UNSIGNED_ARG
    -- pragma return_port_name ROOT
    variable ROOT_v : unsigned((A'length+1)/2-1 downto 0);
  begin
    -- pragma translate_off
    if Is_X (std_logic_vector(A)) then
      ROOT_v := (others => 'X');
    else
      ROOT_v := (others => '0');
      for i in (A'length+1)/2-1 downto 0 loop
        ROOT_v(i) := '1';
        if ROOT_v*ROOT_v > A then
          ROOT_v(i) := '0';
        end if;
      end loop;
    end if;
    return ROOT_v;
    -- pragma translate_on
  end DWF_sqrt;

  function DWF_sqrt (A : signed) return unsigned is
    -- pragma map_to_operator SQRT_TC_OP
    -- pragma type_function SQRT_SIGNED_ARG
    -- pragma return_port_name ROOT
    variable A_abs_v : signed(A'length-1 downto 0);
  begin
    -- pragma translate_off
    A_abs_v := abs (A);
    return DWF_sqrt (unsigned(A_abs_v));
    -- pragma translate_on
  end DWF_sqrt;


  -- Old function definitions
  
  function sqrt (A : unsigned) return unsigned is
  begin
    return DWF_sqrt (A);
  end sqrt;

  function sqrt (A : signed) return unsigned is
  begin
    return DWF_sqrt (A);
  end sqrt;

end DW02_components;

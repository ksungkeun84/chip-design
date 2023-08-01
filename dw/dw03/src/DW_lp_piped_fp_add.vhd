----------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2009 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Doug Lee    Feb 20, 2009
--
-- VERSION:   Entity
--
-- DesignWare_version: 80a09a6e
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
--
-- ABSTRACT: Floating-Point Pipelined Reciprocal
--           - 
--              DW_lp_piped_fp_add calculates the floating-point addrocal
--              with 1 ulp error with configurabel pipelining.
--
--           - 
-- 
-- MODIFIED:
--
--   
--   parameters      valid values (defined in the DW manual)
--   ==========      ============       ==========
--   sig_width       2 to 60 bits       significand size,  
--   exp_width       3 to 31 bits       exponent size,	
--   ieee_compliance                    support the IEEE Compliance 
--      	                0 -     IEEE 754 compatible without denormal support
--      		                (NaN becomes Infinity, Denormal becomes Zero)
--      	                1 -     IEEE 754 compatible with denormal support
--      		                (NaN and denormal numbers are supported)
--
--
--   op_iso_mode      0 to 4        default: 0
--                                  Type of operand isolation
--                                    If 'in_reg' is '1', this parameter is ignored...effectively set to '1'.
--                                    0 => Follow intent defined by Power Compiler user setting
--                                    1 => no operand isolation
--                                    2 => 'and' gate isolaton
--                                    3 => 'or' gate isolation
--                                    4 => preferred isolation style: 'and' gate
--
--   id_width        1 to 1024      default: 1
--                                  Launch identifier width
--
--   in_reg           0 to 1        default: 0
--                                  Input register control
--                                    0 => no input register
--                                    1 => include input register
--
--   stages          1 to 1022      default: 4
--                                  Number of logic stages in the pipeline
--
--   out_reg          0 to 1        default: 0
--                                  Output register control
--                                    0 => no output register
--                                    1 => include output register
--
--   no_pm            0 to 1        default: 1
--                                  Pipeline management usage
--                                    0 => Use pipeline management (#lpwr# implementation selected)
--                                    1 => Do not use pipeline management (#rtl# implementation selected)
--                                          launch input becomes global register enable to block
--
--   rst_mode         0 to 1        default: 0
--                                  Control asynchronous or synchronous reset
--                                  behavior of rst_n
--                                    0 => asynchronous reset
--                                    1 => synchronous reset
--
--   Input ports     Size           Description
--   ===========     ======         ============
--   a  	                    (sig_width + exp_width + 1)-bits
--   		                    Floating-point Number Input Dividend
--   b  	                    (sig_width + exp_width + 1)-bits
--   		                    Floating-point Number Input Divisor
--   rnd	                    3 bits
--   		                    Rounding Mode Input
--
--   Output ports     Size          Description
--   ===========     ======         ========================
--   z  	     (sig_width + exp_width + 1)-bits
--   		                   Floating-point Number Output
--   status	     8 bits
--                              Status Flags Output
--
--
--     Note: M is the value of "data_width" parameter
--     Note: N is the value of "chk_width" parameter
--     Note: Q is the value of "id_width" parameter
--     Note: R is equal to the larger of '1' or ceil(log2(in_reg+stages+out_reg))
--
--
-- Modified:
--
-------------------------------------------------------------------------------
--
library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
--
entity DW_lp_piped_fp_add is
  generic (
    sig_width      : POSITIVE   := 23;
    exp_width      : POSITIVE    := 8;
    ieee_compliance: INTEGER      := 0;
    op_iso_mode    : NATURAL      := 0;
    id_width	   : POSITIVE  := 8;
    in_reg	   : NATURAL      := 0;
    stages	   : POSITIVE  := 4;
    out_reg	   : NATURAL      := 0;
    no_pm          : NATURAL      := 1;
    rst_mode	   : NATURAL      := 0
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
end DW_lp_piped_fp_add ;


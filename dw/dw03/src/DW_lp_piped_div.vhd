--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2008 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Bruce Dean    Sep 17, 2007
--
-- VERSION:   Entity
--
-- DesignWare_version: d2b981d8
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
--
-- ABSTRACT: Low Power Pipelined Divider Entity
--
--           This receives two operands that get diviplied.  Configurable
--           to provide pipeline registers for both static and re-timing placement.
--           Also, contains pipeline management to optimized for low power.
--
--
--  Parameters:     Valid Values    Description
--  ==========      ============    =============
--   a_width           >= 1         default: 8
--                                  Width of 'a' operand
--
--   b_width           >= 1         default: 8
--                                  Width of 'a' operand
--
--   id_width        1 to 1024      default: 8
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
--   tc_mode         0 to 1         default: 0
--                                  Two's complement control
--                                    0 => unsigned
--                                    1 => two's complement
--
--   rst_mode        0 to 1         default: 0
--                                  Control asynchronous or synchronous reset
--                                  behavior of rst_n
--                                    0 => asynchronous reset
--                                    1 -> synchronous reset
--
--   rem_mode        0 or 1         default: 0
--                                  Remainder output control:
--                                    0 : remainder output is VHDL modulus
--                                    1 : remainder output is remainder  
--
--   op_iso_mode      0 to 4        default: 0
--                                  Type of operand isolation
--                                    If 'in_reg' is '1', this parameter is ignored...effectively set to '1'.
--                                    0 => Follow intent defined by Power Compiler user setting
--                                    1 => no operand isolation
--                                    2 => 'and' gate operand isolaton
--                                    3 => 'or' gate operand isolation
--                                    4 => preferred isolation style: 'or'
--     
--
--  Ports       Size          Direction    Description
--  =====       ====          =========    ===========
--  clk         1 bit           Input      Clock Input
--  rst_n       1 bit           Input      Reset Input, Active Low
--
--  a           a_width bits    Input      Divider
--  b           b_width bits    Input	   divipicand
--  quotient    a_width bits    Output     quotient a / b
--  rem         b_width bits    Output     rem a / b
--  div_by_0    1 bit           Output     high when b input is zero
--
--  launch      1 bit           Input      Active High Control input to lauche data into pipe
--  launch_id   id_width bits   Input      ID tag for data being launched (optional)
--  pipe_full   1 bit           Output     Status Flag indicating no slot for new data
--  pipe_ovf    1 bit           Output     Status Flag indicating pipe overflow
--
--  accept_n    1 bit           Input      Flow Control Input, Active Low
--  arrive      1 bit           Output     Data Available output
--  arrive_id   id_width bits   Output     ID tag for data that's arrived (optional)
--  push_out_n  1 bit           Output     Active Low Output used with FIFO (optional)
--  pipe_census R bits          Output     Output bus indicating the number
--                                         of pipe stages currently occupied
--
--     Note: R is equal to the the larger of '1' or ceil(log2(in_reg+stages+out_reg))
--
--
-- Modified:
--
--
---------------------------------------------------------------------------------------------
library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;

entity DW_lp_piped_div is
   generic (
     a_width     : POSITIVE  := 8;
     b_width     : POSITIVE  := 8;
     id_width    : POSITIVE  := 8;
     in_reg      : NATURAL      := 0;
     stages      : POSITIVE  := 4;
     out_reg     : NATURAL      := 0;
     tc_mode     : NATURAL      := 0;
     rst_mode    : NATURAL      := 0;
     rem_mode    : NATURAL      := 1;
     op_iso_mode : NATURAL      := 0
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
end DW_lp_piped_div;

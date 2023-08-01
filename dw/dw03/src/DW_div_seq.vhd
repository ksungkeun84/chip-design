--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2002 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Aamir Farooqui	February 20, 2002
--
-- VERSION:   VHDL Entity file for DW_div_seq
--
-- DesignWare_version: 0ebfa429
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  
--            - DW_div_ser is a serial divider which divides the operand 
--              'a' by 'b' to produce a 'quotient' and 'remainder'.
--            - num_cyc: Division is performed in a user-defined number 
--              of clock cycles using the parameter 'num_cyc'. 
--            - start: Division is started by setting the input 'start' to 1 
--            - complete: Division end is flagged with the output 'complete' being set to 1.
--            - tc_mode: The parameter tc_mode determines whether the data of inputs 
--              and outputs is interpreted as unsigned (tc_mode is 0) or 
--              twos complement (tc_mode is 1) numbers.
--            - reset: The internal registers can either have no reset (rst_mode = 0) 
--              or an asynchronous (rst_mode = 0) or synchronous 
--              reset (rst_mode = 1) that is connected to the reset signal rst_n
--            - input_mode: The parameter input_mode determines whether the inputs 
--              need to be registered (input_mode is 1) or not (input_mode is 0). 
--            - output_mode: Similarly, the parameter output_mode determines 
--              whether the outputs are registered (output_mode is 1) 
--              or not (output_mode is 0). 
--            - early_start: When the parameter early_start is 1, computation 
--              starts immediately after setting the start to 1. This saves one 
--              extra cycle to store the data (early_start=0), but results in a 
--              slighltly longer critical path.
--
-- PARAMETERS:
--   Parameter  Legal Range    Default  Description
--   ---------  -----------    -------  -----------
--   a_width    >= 3           none     word length of a
--   b_width    3 to a_width   none     word length of b
--   tc_mode    0 or 1         0        two's complement control:
--                                        0 : inputs/outputs unsigned
--                                        1 : inputs/outputs two's complement
--   num_cyc    3 to a_width   3        number of cycles to perform division 
--   rst_mode   0, or 1        0        Reset mode:
--                                      '0' : async, '1' : sync
--   input_mode 0 or 1         1	Registered inputs 0=no 1=yes
--   output_mode0 or 1         1	Registered outputs 0=no 1=yes
--   early_start0 or 1         0	Computation start
--                                      0=start computation in the second cycle
--                                      1=start computation in the first cycle
-- INPUTS:
--   Inputs       Size     Description
--   ------       ----     -----------
--   clk          1        register clock
--   rst_n        1        register reset
--   hold         1        hold current operation '1' 
--   start        1        start division '1' for one cycle
--   a            a_width  dividend 
--   b            b_width  divisor 
--
-- OUTPUTS:
--   Outputs      Size
--   -------      ----
--   complete	  1        end of division
--   quotient     a_width  quotient
--   remainder    b_width  remainder
--
-- MODIFIED:
--
-------------------------------------------------------------------------------
 
library IEEE;
use IEEE.std_logic_1164.all;
 
 
entity DW_div_seq is
 
  generic (
    a_width    : positive;                    -- dividend word width
    b_width    : positive;                    -- divisor word width
    tc_mode    : integer  := 0;   -- '0' : unsigned, '1' : 2's compl.
    num_cyc    : integer := 3;                -- number of cycles to perform dividcation 
    rst_mode   : integer  := 0;   -- '0' : async, '1' : sync
    input_mode : integer  := 1;   -- Registered inputs 0=no 1=yes
    output_mode: integer  := 1;   -- Registered outputs 0=no 1=yes
    early_start: integer  := 0);   -- Computation start
                                              -- 0=start computation in the second cycle
                                              -- 1=start computation in the first cycle


 
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
 
end DW_div_seq;


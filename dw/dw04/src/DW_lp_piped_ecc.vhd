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
-- AUTHOR:    Doug Lee    Feb 3, 2009
--
-- VERSION:   Entity
--
-- DesignWare_version: d2417339
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
--
-- ABSTRACT: Low Power Pipelined Modified Hamming Code Error Correction/Detection Entity File
--
--           This receives two set of 'concatenated' operands that result
--           in a summation from a set of products.  Configurable to provide
--           pipeline registers for both static and re-timing placement.
--           Also, contains pipeline management to optimized for low power.
--
--
--  Parameters:     Valid Values    Description
--  ==========      ============    =============
--  data_width       8 to 8178      default: 8
--                                  Width of 'datain' and 'dataout'
--
--  chk_width         5 to 14       default: 5
--                                  Width of 'chkin', 'chkout', and 'syndout'
--
--   rw_mode           0 or 1       default: 1
--                                  Read or write mode
--                                    0 => read mode
--                                    1 => write mode
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
--                                    0 => Use pipeline management ('lpwr' implementation selected)
--                                    1 => Do not use pipeline management ('rtl' implementation selected)
--                                          launch input becomes global register enable to block
--
--   rst_mode         0 to 1        default: 0
--                                  Control asynchronous or synchronous reset
--                                  behavior of rst_n
--                                    0 => asynchronous reset
--                                    1 => synchronous reset
--
--
--  Ports        Size    Direction    Description
--  =====        ====    =========    ===========
--  clk          1 bit     Input      Clock Input
--  rst_n        1 bit     Input      Reset Input, Active Low
--
--  datain       M bits    Input      Input data bus
--  chkin        N bits    Input      Input check bits bus
--
--  err_detect   1 bit     Output     Any error flag (active high)
--  err_multiple 1 bit     Output     Multiple bit error flag (active high)
--  dataout      M bits    Output     Output data bus
--  chkout       N bits    Output     Output check bits bus
--  syndout      N bits    Output     Output error syndrome bus
--
--  launch       1 bit     Input      Active High Control input to launch data into pipe
--  launch_id    Q bits    Input      ID tag for operation being launched
--  pipe_full    1 bit     Output     Status Flag indicating no slot for a new launch
--  pipe_ovf     1 bit     Output     Status Flag indicating pipe overflow
--
--  accept_n     1 bit     Input      Flow Control Input, Active Low
--  arrive       1 bit     Output     Product available output
--  arrive_id    Q bits    Output     ID tag for product that has arrived
--  push_out_n   1 bit     Output     Active Low Output used with FIFO
--  pipe_census  R bits    Output     Output bus indicating the number
--                                   of pipeline register levels currently occupied
--
--     Note: M is the value of "data_width" parameter
--     Note: N is the value of "chk_width" parameter
--     Note: Q is the value of "id_width" parameter
--     Note: R is equal to the larger of '1' or ceil(log2(in_reg+stages+out_reg))
--
--
-- Modified:
--
---------------------------------------------------------------------------------------------
library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;

entity DW_lp_piped_ecc is
   generic (
     data_width  : POSITIVE  := 8;
     chk_width   : POSITIVE    := 5;
     rw_mode     : NATURAL      := 1;
     op_iso_mode : NATURAL      := 0;
     id_width    : POSITIVE  := 1;
     in_reg      : NATURAL      := 0;
     stages      : POSITIVE  := 4;
     out_reg     : NATURAL      := 0;
     no_pm       : NATURAL      := 1;
     rst_mode    : NATURAL      := 0
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
end DW_lp_piped_ecc;

--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 1999 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Sourabh Tandon	      July 19, 1999
--
-- VERSION:   Entity
--
-- DesignWare_version: c01d7f4c
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT: Arithmetic and Barrel combo shifter
--           This component performs arithmatic and circular shifting in
--           both left and right directions.  
--
-- MODIFIED:
--
--  08/28/2002  RPH             Rewrote thhe model according to the new coding
--                              Guidelines  
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity DW_shifter is

   generic(

            data_width : POSITIVE := 8;
            sh_width   : POSITIVE := 3; 
            inv_mode   : INTEGER  := 0

          );

   port(

        -- input data
        data_in : in std_logic_vector(data_width-1 downto 0);

        -- 2's complement / unsigned data control
        data_tc : in std_logic;

        -- shift coefficient
        sh : in std_logic_vector(sh_width-1 downto 0);

        -- 2's complement / unsigned shift coefficient control
        sh_tc : in std_logic;

        -- select mode for arithmatic/barrel shifter
        sh_mode : in std_logic;

        -- shifted data
        data_out : out std_logic_vector(data_width-1 downto 0)

        ); 

end DW_shifter;
 



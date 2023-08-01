----------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2004 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Bruce Dean May 22 2007
--
-- VERSION:   Entity
--
-- DesignWare_version: 625ef34b
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
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
--        dct_rd_data 	bpp/bpt        read data input, pels or transform data
--        tp_rd_data	n+bpp	       transform intermediate data
--
--      Output Ports	Size	Description
--      ============	====== =======================
--        done  	1	       first data block read
--        ready 	1	       first transform available
--        dct_rd_add  	bit width(n)   fetch data address out
--        tp_rd_add	bit width(n)   fetch transpose data address out
--        tp_wr_add	bit width(n)   write transpose data address out
--        tp_dct_wr_n 	1	       transpose data write(not) signal
--        tp_wr_data	n+bpp	       transpose intermediate data out
--        dct_wr_add  	bit width(n)   write data out
--        dct_dct_wr_n  	1	       final data write(not) signal
--        dct_wr_data  	n/2+bpp        final transformed data out(dct or pels)
--
--
--
--
--
--  MODIFIED:
--           RJK 5/27/16  Updated design to properly operate with "enable" used
--                        as a high priority register enable (STAR 9000554173)
--
--           jbd original simulation model 0707
-------------------------------------------------------------------------------
--
library IEEE, DWARE;
use IEEE.std_logic_1164.all;
--use ieee.numeric_std.all;
use IEEE.std_logic_misc.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use DWARE.DWpackages.all;

--
architecture sim of DW_dct_2d is
	
-- pragma translate_off
  -- generic parameter re-definition
  constant sumdiff  : integer := n/2+bpp;
  constant bigadd   : integer := sumdiff + 1;
  constant outbits  : integer := sumdiff + 1;
  constant nwidth   : integer := bit_width(n);
  constant depth    : integer := n*n;
  constant addwidth : integer := bit_width(depth);
  constant ysize    : integer := n/4+bpp;
  constant ninc     : integer := n;
  constant coef_w   : integer := 16*(n+1);
  constant rddatsz  : integer := bpp+(idct_mode*n/2);
  constant wrdatsz  : integer := bpp+((1-idct_mode)*n/2);
  constant intdatsz : integer := bpp/2 + bpp + 4 + ((1-tc_mode)*(1-idct_mode));
  constant frstprod : integer := rddatsz  + 16 + ((1-tc_mode)*(1-idct_mode));
  constant frstsum  : integer := frstprod + bpp/2 -1;
  constant scndprod : integer := intdatsz + 16;
  constant prmrnd   : integer := 1 * 2**(frstsum-intdatsz-1);--(10 + ((1-tc_mode)*(1-idct_mode)));
  constant fnlrnd   : integer := 1 * 2**((scndprod - wrdatsz -1)-((bpp-1)*idct_mode));
  --((bpp/2 * (1-idct_mode)) + 16 - (1-idct_mode));
  --constant fnlrnd   : integer := 1 * 2**(n/2 + 15 - idct_mode);

function get_fcoef(linenum:integer) return unsigned is
variable signbit : unsigned( n-1 downto 0);
variable indx    : integer ;
variable get_params : unsigned( 255 downto 0);
variable tcoef      : unsigned( 15 downto 0);
variable coefsel    : unsigned( n*4-1 downto 0);
variable coef_out   : unsigned( 255 downto 0);
variable fcoef      : unsigned( 255 downto 0);
begin
  case(n) is
    when 4 =>
      case (linenum) is
        when   0 => signbit := "0000";
        when   1 => signbit := "0011";
        when   2 => signbit := "0110";
        when   3 => signbit := "0101";
        when others => signbit := (others => 'X');
        end case;
    when 6 => 
      case (linenum) is 
        when   0 => signbit := "000000";
        when   1 => signbit := "000111";
        when   2 => signbit := "001100";
        when   3 => signbit := "011001";
        when   4 => signbit := "010010";
        when   5 => signbit := "010101";
        when others => signbit := (others => 'X');
        end case;
    when 8 => 
      case (linenum) is 
        when   0 => signbit := "00000000";
        when   1 => signbit := "00001111";
        when   2 => signbit := "00111100";
        when   3 => signbit := "01110001";
        when   4 => signbit := "01100110";
        when   5 => signbit := "01001101";
        when   6 => signbit := "01011010";
        when   7 => signbit := "01010101";
        when others => signbit := (others => 'X');
        end case;
    when 10 => 
      case (linenum) is 
        when   0 => signbit := "0000000000";
        when   1 => signbit := "0000011111";
        when   2 => signbit := "0001111000";
        when   3 => signbit := "0011100011";
        when   4 => signbit := "0111001110";
        when   5 => signbit := "0110011001";
        when   6 => signbit := "0110110010";
        when   7 => signbit := "0100101101";
        when   8 => signbit := "0101001010";
        when   9 => signbit := "0101010101";
        when others => signbit := (others => 'X');
        end case;
    when 12 => 
      case (linenum) is 
        when    0 => signbit := "000000000000";
        when    1 => signbit := "000000111111";
        when    2 => signbit := "000111111000";
        when    3 => signbit := "001111000011";
        when    4 => signbit := "001100001100";
        when    5 => signbit := "011100110001";
        when    6 => signbit := "011001100110";
        when    7 => signbit := "011011001001";
        when    8 => signbit := "010010010010";
        when    9 => signbit := "010110100101";
        when   10 => signbit := "010101101010";
        when   11 => signbit := "010101010101";
        when others => signbit := (others => 'X');
        end case;
    when 14 => 
      case (linenum) is 
        when    0 => signbit := "00000000000000";
        when    1 => signbit := "00000001111111";
        when    2 => signbit := "00001111110000";
        when    3 => signbit := "00111110000011";
        when    4 => signbit := "00111000011100";
        when    5 => signbit := "01110001110001";
        when    6 => signbit := "01100011000110";
        when    7 => signbit := "01100110011001";
        when    8 => signbit := "01101100110110";
        when    9 => signbit := "01001001101101";
        when   10 => signbit := "01001011010010";
        when   11 => signbit := "01010010110101";
        when   12 => signbit := "01010100101010";
        when   13 => signbit := "01010101010101";
        when others => signbit := (others => 'X');
        end case;
    when 16 => 
      case (linenum) is 
        when    0 => signbit := "0000000000000000";
        when    1 => signbit := "0000000011111111";
        when    2 => signbit := "0000111111110000";
        when    3 => signbit := "0001111100000111";
        when    4 => signbit := "0011110000111100";
        when    5 => signbit := "0011100011100011";
        when    6 => signbit := "0111000110001110";
        when    7 => signbit := "0110001100111001";
        when    8 => signbit := "0110011001100110";
        when    9 => signbit := "0110110011001001";
        when   10 => signbit := "0100110110110010";
        when   11 => signbit := "0100100101101101";
        when   12 => signbit := "0101101001011010";
        when   13 => signbit := "0101001010110101";
        when   14 => signbit := "0101010110101010";
        when   15 => signbit := "0101010101010101";
        when others => signbit := (others => 'X');
      end case;
    when others => signbit := (others => 'X');
    end case;
  case (n) is
     when  4 =>
      case (linenum) is 
          when 0 => coefsel := X"0000";
          when 1 => coefsel := X"1331";
          when 2 => coefsel := X"0000";
          when 3 => coefsel := X"3113";
          when others => coefsel := (others => 'X');
        end case;
    when 6 =>
      case (linenum) is 
          when 0 => coefsel := X"000000";
          when 1 => coefsel := X"105501";
          when 2 => coefsel := X"262262";
          when 3 => coefsel := X"333333";
          when 4 => coefsel := X"404404";
          when 5 => coefsel := X"501105";
          when others => coefsel := (others => 'X');
        end case;
    when 8 =>
      case (linenum) is 
          when 0 => coefsel := X"00000000";
          when 1 => coefsel := X"13577531";
          when 2 => coefsel := X"26622662";
          when 3 => coefsel := X"37155173";
          when 4 => coefsel := X"44444444";
          when 5 => coefsel := X"51733715";
          when 6 => coefsel := X"62266226";
          when 7 => coefsel := X"75311357";
          when others => coefsel := (others => 'X');
        end case;
    when 10 =>
      case (linenum) is 
          when 0 => coefsel := X"0000000000";
          when 1 => coefsel := X"1307997031";
          when 2 => coefsel := X"26a6226a62";
          when 3 => coefsel := X"3901771093";
          when 4 => coefsel := X"4808448084";
          when 5 => coefsel := X"5555555555";
          when 6 => coefsel := X"62a2662a26";
          when 7 => coefsel := X"7109339017";
          when 8 => coefsel := X"8404884048";
          when 9 => coefsel := X"9703113079";
          when others => coefsel := (others => 'X');
        end case;
    when 12 =>
      case (linenum) is 
          when  0 => coefsel := X"000000000000";
          when  1 => coefsel := X"13579bb97531";
          when  2 => coefsel := X"20aa0220aa02";
          when  3 => coefsel := X"399339933993";
          when  4 => coefsel := X"4c44c44c44c4";
          when  5 => coefsel := X"591b3773b195";
          when  6 => coefsel := X"666666666666";
          when  7 => coefsel := X"73b195591b37";
          when  8 => coefsel := X"808808808808";
          when  9 => coefsel := X"933993399339";
          when 10 => coefsel := X"a0220aa0220a";
          when 11 => coefsel := X"b9753113579b";
          when others => coefsel := (others => 'X');
        end case;
    when 14 =>
      case (linenum) is 
          when  0 => coefsel := X"00000000000000";
          when  1 => coefsel := X"13509bddb90531";
          when  2 => coefsel := X"26aea6226aea62";
          when  3 => coefsel := X"39d015bb510d93";
          when  4 => coefsel := X"4c808c44c808c4";
          when  5 => coefsel := X"5d30b1991b03d5";
          when  6 => coefsel := X"6a2e2a66a2e2a6";
          when  7 => coefsel := X"77777777777777";
          when  8 => coefsel := X"84c0c4884c0c48";
          when  9 => coefsel := X"91b03d55d30b19";
          when 10 => coefsel := X"a26e62aa26e62a";
          when 11 => coefsel := X"b510d9339d015b";
          when 12 => coefsel := X"c84048cc84048c";
          when 13 => coefsel := X"db9053113509bd";
          when others => coefsel := (others => 'X');
        end case;
    when 16 =>
      case (linenum) is 
          when  0 => coefsel := X"0000000000000000";
          when  1 => coefsel := X"13579bdffdb97531";
          when  2 => coefsel := X"26aeea6226aeea62";
          when  3 => coefsel := X"39fb517dd715bf93";
          when  4 => coefsel := X"4cc44cc44cc44cc4";
          when  5 => coefsel := X"5f73d91bb19d37f5";
          when  6 => coefsel := X"6e2aa2e66e2aa2e6";
          when  7 => coefsel := X"7b3f1d5995d1f3b7";
          when  8 => coefsel := X"8888888888888888";
          when  9 => coefsel := X"95d1f3b77b3f1d59";
          when 10 => coefsel := X"a2e66e2aa2e66e2a";
          when 11 => coefsel := X"b19d37f55f73d91b";
          when 12 => coefsel := X"c44cc44cc44cc44c";
          when 13 => coefsel := X"d715bf9339fb517d";
          when 14 => coefsel := X"ea6226aeea6226ae";
          when 15 => coefsel := X"fdb9753113579bdf";
          when others => coefsel := (others => 'X');
        end case;
      when others => coefsel := (others => 'X');
  end case;

  get_params :=    CONV_UNSIGNED(co_p,16) & CONV_UNSIGNED(co_o,16) 
                 & CONV_UNSIGNED(co_n,16) & CONV_UNSIGNED(co_m,16) 
	         & CONV_UNSIGNED(co_l,16) & CONV_UNSIGNED(co_k,16) 
	         & CONV_UNSIGNED(co_j,16) & CONV_UNSIGNED(co_i,16) 
	         & CONV_UNSIGNED(co_h,16) & CONV_UNSIGNED(co_g,16) 
	         & CONV_UNSIGNED(co_f,16) & CONV_UNSIGNED(co_e,16) 
	         & CONV_UNSIGNED(co_d,16) & CONV_UNSIGNED(co_c,16) 
	         & CONV_UNSIGNED(co_b,16) & CONV_UNSIGNED(co_a,16);  
    for cnt in 0 to n-1 loop
      indx := conv_integer(coefsel(4*cnt + 3 downto 4*cnt));
      tcoef := get_params(indx*16+15 downto indx*16);
      if(signbit(cnt) = '1') then
        tinv: for i in 15 downto 0 loop
        tcoef(i) :=  not tcoef(i);
        end loop tinv;
        tcoef := tcoef +1;
      end if;
      coef_out(cnt*16+15 downto cnt*16) := tcoef;
    end loop;
    return coef_out;

  end get_fcoef;
function get_icoef(linenum:integer) return unsigned is
variable coef_out   : unsigned( 255 downto 0);
variable tcoef      : unsigned( 255 downto 0);
begin
    for i in 0 to n-1 loop
      tcoef := get_fcoef(n-1-i);
      coef_out(16*i + 15 downto 16*i) := tcoef(16*(n-1-linenum) + 15 downto 16*(n-1-linenum));
    end loop;
  
  return coef_out;
end get_icoef;

  signal start_q   : std_logic := '0';
  signal start_int : std_logic := '0';
  signal rst_n_int : std_logic := '0';
  signal init_n_int : std_logic := '0';
  signal enable_int : std_logic := '0';
  signal done_int : std_logic:= '0';
  signal done_nxt : std_logic:= '0';
  signal ready_int : std_logic:= '0';
  signal ready_nxt : std_logic:= '0';
  
  signal rd_add_out   : std_logic_vector(bit_width(n*n)-1 downto 0) :=(others => '0');
  signal wr_add_out   : std_logic_vector(bit_width(n*n)-1 downto 0) :=(others => '0');
  signal tp_wr_add_int  : std_logic_vector(bit_width(n*n)-1 downto 0) :=(others => '0');
  --signal tp_rd_add_int  : std_logic_vector(bit_width(n*n)-1 downto 0) :=(others => '0');
  --signal tp_wr_data_int : std_logic_vector(intdatsz-1 downto 0) :=(others => '0');
  --signal tp_rd_data_int : std_logic_vector(intdatsz-1 downto 0) :=(others => '0');

  signal rx0          : std_logic_vector(n*rddatsz-1 downto 0) :=(others => '0');
  signal rx1          : std_logic_vector(n*rddatsz-1 downto 0) :=(others => '0');
  signal rx0_nxt      : std_logic_vector(n*rddatsz-1 downto 0) :=(others => '0');
  signal rx1_nxt      : std_logic_vector(n*rddatsz-1 downto 0) :=(others => '0');

  signal ry0          : std_logic_vector(n*intdatsz-1 downto 0) :=(others => '0');
  signal ry1          : std_logic_vector(n*intdatsz-1 downto 0) :=(others => '0');
  signal ry0_nxt      : std_logic_vector(n*intdatsz-1 downto 0) :=(others => '0');
  signal ry1_nxt      : std_logic_vector(n*intdatsz-1 downto 0) :=(others => '0');

  signal idat_sum     : std_logic_vector(frstsum-1 downto 0)  :=(others => '0');
  signal fdat_sum     : std_logic_vector(scndprod-1 downto 0) :=(others => '0');
  signal idat_sum_int : std_logic_vector(frstsum-1 downto 0)  :=(others => '0');
  signal fdat_sum_int : std_logic_vector(scndprod-1 downto 0) :=(others => '0');

  signal rd_rst : std_logic := '0';
  signal rd_mode     : std_logic := '0';
  signal rd_mode_nxt : std_logic := '0';
  signal rd_run : std_logic := '0';
  signal int_rst : std_logic := '0';

  signal rd_add_rc_tc : std_logic := '0';
  signal rd_add_rc_rst : std_logic := '0';
  signal rd_add_ca_tc : std_logic := '0';
  signal rd_add_rc_en : std_logic := '0';
  signal rd_add_clcnt_tc : std_logic := '0';
  signal rd_add_0 : std_logic := '0';
  signal rd_add_tc     : std_logic := '0';
  
  signal rd_add_colcnt     : integer range -1 to depth := 0;
  signal rd_add_colcnt_int : integer range -1 to depth := 0;
  signal rd_add_rwcnt      : integer range -1 to n := 0;
  signal rd_add_rwcnt_int  : integer range -1 to n := 0;

  signal rd_add_int : integer range -1 to depth := 0;
  signal rd_add_nxt : integer range -1 to depth := 0;
  signal rd_add_col : integer range -1 to depth := 0;
  signal rd_add_col_int : integer range -1 to depth := 0;

  signal n_one : integer  := 1;--range nwidth-1 to 0;
  signal n_zero : integer := 0;--range nwidth-1 to 0;

  signal prc_start : std_logic := '0';
  signal prc_rst : std_logic := '0';
  signal prc_mode     : std_logic := '0';
  signal prc_mode_nxt : std_logic := '0';
  signal prc_run : std_logic := '0';
  signal prc_add_0 : std_logic := '0';

  signal prc_add_tc : std_logic := '0';
  signal prc_add_int : integer range 0 to depth := 0;
  signal prc_add_nxt : integer range 0 to depth := 0;

  signal tp_wr_start          : std_logic := '0';
  signal tp_wr_rst            : std_logic := '0';
  signal tp_wr_mode           : std_logic := '0';
  signal tp_wr_mode_nxt       : std_logic := '0';
  signal tp_wr_run            : std_logic := '0';

  signal twr_add_rc_tc      : std_logic := '0';
  signal twr_add_rc_rst     : std_logic := '0';
  signal twr_add_ca_tc      : std_logic := '0';
  signal twr_add_rc_en      : std_logic := '0';
  signal twr_add_clcnt_tc   : std_logic := '0';
  signal twr_add_0          : std_logic := '0';

  signal twr_add_tc         : std_logic := '0';
  signal twr_add_colcnt     : integer range -1 to depth := 0;
  signal twr_add_colcnt_int : integer range -1 to depth := 0;
  signal twr_add_rwcnt_nxt      : integer range -1 to n := 0;
  signal twr_add_rwcnt_int  : integer range -1 to n := 0;

  signal twr_add_int        : integer range -1 to depth := 0;
  signal twr_add_nxt        : integer range -1 to depth := 0;
  signal twr_add_out        : integer range -1 to depth := 0;

  signal tp_rd_start    : std_logic := '0';
  signal tp_rd_rst      : std_logic := '0';
  signal tp_rd_mode     : std_logic := '0';
  signal tp_rd_mode_nxt : std_logic := '0';
  signal tp_rd_run      : std_logic := '0';

  signal trd_add_0  : std_logic := '0';
  signal trd_add_tc : std_logic := '0';

  signal trd_add_int : integer range -1 to depth := 0;
  signal trd_add_nxt : integer range -1 to depth := 0;

  signal scc_start    : std_logic := '0';
  signal scc_rst      : std_logic := '0';
  signal scc_mode     : std_logic := '0';
  signal scc_mode_nxt : std_logic := '0';
  signal scc_run      : std_logic := '0';
  signal scc_add_0    : std_logic := '0';

  signal scc_add_tc   : std_logic := '0';
  signal scc_add_int  : integer range -1 to depth := 0;
  signal scc_add_nxt  : integer range -1 to depth := 0;

  signal wr_start          : std_logic := '0';
  signal wr_rst            : std_logic := '0';
  signal wr_mode           : std_logic := '0';
  signal wr_mode_nxt       : std_logic := '0';
  signal wr_run            : std_logic := '0';
  signal wr_run_int        : std_logic := '0';
  signal dct_wr_n_sig          : std_logic := '0';

  signal wr_add_rc_tc      : std_logic := '0';
  signal wr_add_rc_rst     : std_logic := '0';
  signal wr_add_ca_tc      : std_logic := '0';
  signal wr_add_rc_en      : std_logic := '0';
  signal wr_add_clcnt_tc   : std_logic := '0';
  signal wr_add_0          : std_logic := '0';

  signal wr_add_tc         : std_logic := '0';
  signal wr_add_colcnt     : integer range -1 to depth := 0;
  signal wr_add_colcnt_int : integer range -1 to depth := 0;
  signal wr_add_rwcnt      : integer range -1 to n := 0;
  signal wr_add_rwcnt_int  : integer range -1 to n := 0;

  signal wr_add_int        : integer range -1 to depth := 0;
  signal wr_add_nxt        : integer range -1 to depth := 0;
  signal wr_add_out_nxt        : integer range -1 to depth := 0;
  signal wr_add_out_int        : integer range -1 to depth := 0;

  signal temp_icoef : unsigned (255 downto 0);
  signal temp_fcoef : unsigned (255 downto 0);
  signal indx    : integer := prmrnd ;

-- pragma translate_on
   begin
-- pragma translate_off
 
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
      
    if (n < 4) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter n (lower bound: 4)"
        severity warning;
    end if;
      
    if (bpp < 8) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter bpp (lower bound: 8)"
        severity warning;
    end if;
      
    if ( (reg_out < 0) OR (reg_out > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter reg_out (legal range: 0 to 1)"
        severity warning;
    end if;
      
    if ( (tc_mode < 0) OR (tc_mode > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter tc_mode (legal range: 0 to 1)"
        severity warning;
    end if;
      
    if ( (rt_mode < 0) OR (rt_mode > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter rt_mode (legal range: 0 to 1)"
        severity warning;
    end if;
      
    if ( (idct_mode < 0) OR (idct_mode > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter idct_mode (legal range: 0 to 1)"
        severity warning;
    end if;
      
    if ( (co_a < 0) OR (co_a > 65535) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter co_a (legal range: 0 to 65535)"
        severity warning;
    end if;
      
    if ( (co_b < 0) OR (co_b > 65535) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter co_b (legal range: 0 to 65535)"
        severity warning;
    end if;
      
    if ( (co_c < 0) OR (co_c > 65535) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter co_c (legal range: 0 to 65535)"
        severity warning;
    end if;
      
    if ( (co_d < 0) OR (co_d > 65535) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter co_d (legal range: 0 to 65535)"
        severity warning;
    end if;
      
    if ( (co_e < 0) OR (co_e > 65535) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter co_e (legal range: 0 to 65535)"
        severity warning;
    end if;
      
    if ( (co_f < 0) OR (co_f > 65535) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter co_f (legal range: 0 to 65535)"
        severity warning;
    end if;
      
    if ( (co_g < 0) OR (co_g > 65535) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter co_g (legal range: 0 to 65535)"
        severity warning;
    end if;
      
    if ( (co_h < 0) OR (co_h > 65535) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter co_h (legal range: 0 to 65535)"
        severity warning;
    end if;
      
    if ( (co_i < 0) OR (co_i > 65535) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter co_i (legal range: 0 to 65535)"
        severity warning;
    end if;
      
    if ( (co_j < 0) OR (co_j > 65535) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter co_j (legal range: 0 to 65535)"
        severity warning;
    end if;
      
    if ( (co_k < 0) OR (co_k > 65535) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter co_k (legal range: 0 to 65535)"
        severity warning;
    end if;
      
    if ( (co_l < 0) OR (co_l > 65535) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter co_l (legal range: 0 to 65535)"
        severity warning;
    end if;
      
    if ( (co_m < 0) OR (co_m > 65535) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter co_m (legal range: 0 to 65535)"
        severity warning;
    end if;
      
    if ( (co_n < 0) OR (co_n > 65535) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter co_n (legal range: 0 to 65535)"
        severity warning;
    end if;
      
    if ( (co_o < 0) OR (co_o > 65535) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter co_o (legal range: 0 to 65535)"
        severity warning;
    end if;
      
    if ( (co_p < 0) OR (co_p > 65535) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter co_p (legal range: 0 to 65535)"
        severity warning;
    end if;

    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;
  rst_n_int <= To_01X( rst_n );
  init_n_int <= To_01X( init_n );
  start_int <= start AND NOT start_q;
  enable_int <= To_01X( enable );

  temp_icoef <= get_icoef(prc_add_int);
  temp_fcoef <= get_fcoef(prc_add_int);

  done_nxt   <= rd_add_tc;
  rd_mode_nxt <=  '1' when start_int = '1' else '0' when rd_add_tc = '1' else rd_mode;

  rd_add_nxt  <= 0 when rd_add_tc = '1' else (rd_add_int + 1) mod depth 
                   when rd_run = '1' or start_int = '1' else rd_add_int mod depth;

  rd_add_tc <= '1' when rd_add_int = n*n-1 else '0';
  rd_run     <= rd_mode;
  
  rd_rst     <= '1' when start_int = '1' and rd_add_tc = '1' else '0'; 
  int_rst    <= '1' when rd_add_0 = '0' and start_int = '1' else '0';
  rd_add_0   <= '1' when rd_add_int = 0 else '0';
   
  rd_add_rwcnt  <=  0 when start_int = '1' or rd_add_rc_rst =  '1' 
                  else rd_add_rwcnt_int+1 when rd_add_rc_en = '1' else  rd_add_rwcnt_int;
  rd_add_rc_tc  <= '1' when rd_add_rwcnt_int = n-1 else '0'; 
  rd_add_ca_tc  <= '1' when rd_add_colcnt_int = n-1 else '0';
  rd_add_rc_rst <= rd_add_rc_tc and rd_add_ca_tc;
  rd_add_rc_en  <=  rd_mode and rd_add_clcnt_tc;
  rd_add_col    <= (rd_add_colcnt * n + rd_add_rwcnt) mod depth;
  rd_add_colcnt   <= rd_add_nxt mod n;
  rd_add_clcnt_tc <= '1' when rd_add_colcnt_int = n-1 else '0'; 
  
  
  prc_start    <=  '1' when rd_add_int = n else '0';
  prc_mode_nxt <=  '1' when prc_start = '1' 
                         else '0' when prc_add_tc = '1' or int_rst = '1' 
			   else prc_mode;
  prc_add_nxt  <= twr_add_nxt mod n;
  --0 when prc_add_tc = '1' else prc_add_int mod depth when prc_run = '0' and start = '0'
  --                      else (prc_add_int + 1) mod depth;
  prc_add_tc <= '1' when prc_add_int = n*n-1  else '0';

  prc_run     <= prc_mode;
  prc_rst     <= '1' when prc_start = '1' and prc_add_tc = '1' else '0'; 
  prc_add_0   <= '1' when prc_add_int = 0 else '0';
  
  tp_wr_start    <=  '1' when rd_add_int = n else '0';
  tp_wr_mode_nxt <=  '1' when tp_wr_start = '1' 
                          else '0' when twr_add_tc = '1' or int_rst = '1'  
			    else tp_wr_mode;
  twr_add_nxt  <= 0 when twr_add_tc = '1' or tp_wr_mode = '0'
                       else twr_add_int mod depth 
                         when tp_wr_run = '0' 
                           else ( twr_add_int + 1) mod depth;
  twr_add_tc   <= '1' when twr_add_int = n*n-1 else '0';
  tp_wr_run      <= tp_wr_mode;
  tp_wr_rst      <= '1' when start_int = '1' or twr_add_tc = '1' or int_rst = '1' else '0'; 
  twr_add_0    <= '1' when twr_add_int = 0 else '0';

  twr_add_rwcnt_nxt  <=  0 when tp_wr_start = '1' or twr_add_rc_rst =  '1' 
                           else (twr_add_rwcnt_int + 1) mod n 
			     when twr_add_rc_en = '1' 
			       else  twr_add_rwcnt_int;
  twr_add_rc_tc  <= '1' when twr_add_rwcnt_int = n-1 and twr_add_colcnt = n-1 else '0'; 
  twr_add_ca_tc  <= '1' when twr_add_colcnt_int = n-1 else '0';
  twr_add_rc_rst <= twr_add_rc_tc and twr_add_ca_tc;
  twr_add_rc_en  <=  tp_wr_mode and twr_add_clcnt_tc;
  twr_add_out    <= ( ((twr_add_int mod n) * n )+ twr_add_rwcnt_int) mod depth;

  twr_add_colcnt   <= twr_add_nxt mod n;
  twr_add_clcnt_tc <= '1' when twr_add_colcnt_int = n-1 else '0'; 
  
  tp_rd_start    <=  '1' when twr_add_out = 2*n+n-2 else '0';
  tp_rd_mode_nxt <=  '1' when tp_rd_start = '1' else '0' when trd_add_tc = '1' else tp_rd_mode;

  trd_add_nxt  <= 0 when trd_add_tc = '1' or int_rst = '1' else trd_add_int mod depth 
                    when tp_rd_run = '0' else (trd_add_int + 1) mod depth;
  trd_add_tc  <= '1' when trd_add_int = n*n-1 else '0';
  tp_rd_run     <= tp_rd_mode;
  tp_rd_rst     <= '1' when tp_rd_start = '1' and trd_add_tc = '1' else '0'; 
  trd_add_0   <= '1' when trd_add_int = 0 else '0';
  
  scc_start    <= '1' when trd_add_int = n else '0';
  scc_mode_nxt <=  '1' when scc_start = '1' else '0' when scc_add_tc = '1' else scc_mode;
  scc_add_nxt  <= 0 when scc_add_tc = '1' or int_rst = '1'
                      else scc_add_int mod depth when scc_run = '0' 
                        else ( scc_add_int + 1) mod depth;
  scc_add_tc   <= '1' when scc_add_int = n*n-1 else '0';

  scc_run      <= scc_mode;
  scc_rst      <= '1' when scc_start = '1' and scc_add_tc = '1' else '0'; 
  scc_add_0    <= '1' when scc_add_int = 0 else '0';
  

  wr_start    <= '1' when trd_add_nxt = n+1 else '0';
  wr_mode_nxt <= '1' when wr_start = '1' else '0' when wr_add_tc = '1' or int_rst = '1'
                     else wr_mode;

  wr_add_nxt  <= 0 when wr_add_tc = '1' or int_rst = '1' or wr_run = '0'
                     else ( wr_add_int + 1) mod depth when wr_run = '1' 
                        else wr_add_int mod depth;

  wr_add_out_nxt  <= ( wr_add_colcnt_int * n + wr_add_rwcnt_int) mod depth when idct_mode = 0
                   else wr_add_int mod depth;

  wr_add_tc   <= '1' when wr_add_int = n*n-1 else '0';
  wr_run      <= wr_mode;
  wr_rst      <= '1' when int_rst = '1' or wr_add_tc = '1' else '0'; 
  wr_add_0    <= '1' when wr_add_int = 0 else '0';

  wr_add_rwcnt  <=  0 when wr_start = '1' or wr_add_rc_rst =  '1' 
                  else wr_add_rwcnt_int+1 when wr_add_rc_en = '1' else  wr_add_rwcnt_int;
  wr_add_rc_tc  <= '1' when wr_add_rwcnt_int = n-1 else '0'; 
  wr_add_ca_tc  <= '1' when wr_add_colcnt_int = n-1 else '0';
  wr_add_rc_rst <= wr_add_rc_tc and wr_add_ca_tc;
  wr_add_rc_en  <= wr_mode and wr_add_clcnt_tc;

  wr_add_colcnt   <= wr_add_nxt mod n;
  wr_add_clcnt_tc <= '1' when wr_add_colcnt_int = n-1 else '0'; 
  
  ready_nxt  <= '1' when wr_add_nxt = 1 else '0';
  --dct_wr_n_sig = '0' and wr_add_int = 1 else '0';
    
  rx0_nxt <= rx0((n-1)*rddatsz-1 downto 0) & dct_rd_data when rd_mode = '1' or start = '1' else rx0;
  ry0_nxt <= ry0((n-1)*intdatsz-1 downto 0) & tp_rd_data when tp_rd_mode = '1' or tp_rd_start = '1' else ry0;

  rx1_nxt <= rx0 when rd_add_int mod n = 0 else rx1; 

  ry1_nxt <= ry0 when wr_add_colcnt = 0 and scc_mode_nxt = '1' else ry1;

  dct_wr_n_sig <=  not wr_run when reg_out = 0 else not wr_run_int;
  
  MAIN_SEQ_PROC : process (clk, rst_n_int)
  begin
  
  if(rst_n_int = '0' ) then
    start_q  <= '0';
    rd_mode  <= '0';
    rd_add_int <= 0;
    rd_add_rwcnt_int <= 0;
    rd_add_colcnt_int <= 0;
    rd_add_col_int <= 0;
    rx0 <= (others => '0');
    rx1 <= (others => '0');
    done_int <= '0';
    ready_int <= '0';
    prc_mode <= '0';
    prc_add_int <= 0;
    tp_wr_mode <= '0';
    twr_add_int <= 0;
    twr_add_rwcnt_int <= 0;
    twr_add_colcnt_int <= 0;
    tp_rd_mode <= '0';
    trd_add_int <= 0;
    scc_mode <= '0';
    scc_add_int <= 0;
    wr_mode <= '0';
    wr_run_int <= '0';
    wr_add_int <= 0;
    wr_add_out_int <= 0;
    wr_add_colcnt_int <= 0;
    wr_add_rwcnt_int  <= 0;
    ry0 <= (others => '0');
    ry1 <= (others => '0');
    idat_sum_int  <= (others => '0');
    fdat_sum_int  <= (others => '0');
  elsif(rst_n_int = '1') then
    if(clk = '1' and clk'event) then
      if (enable_int = '1') then
	if (init_n_int = '0') then
	  start_q  <= '0';
	  rd_mode  <= '0';
	  rd_add_int <= 0;
	  rd_add_rwcnt_int <= 0;
	  rd_add_colcnt_int <= 0;
	  rd_add_col_int <= 0;
	  rx0 <= (others => '0');
	  rx1 <= (others => '0');
	  done_int <= '0';
	  ready_int <= '0';
	  prc_mode <= '0';
	  prc_add_int <= 0;
	  tp_wr_mode <= '0';
	  twr_add_int <= 0;
	  twr_add_rwcnt_int <= 0;
	  twr_add_colcnt_int <= 0;
	  tp_rd_mode <= '0';
	  trd_add_int <= 0;
	  scc_mode <= '0';
	  scc_add_int <= 0;
	  wr_mode <= '0';
	  wr_run_int <= '0';
	  wr_add_int <= 0;
	  wr_add_out_int <= 0;
	  wr_add_colcnt_int <= 0;
	  wr_add_rwcnt_int  <= 0;
	  ry0 <= (others => '0');
	  ry1 <= (others => '0');
	  idat_sum_int  <= (others => '0');
	  fdat_sum_int  <= (others => '0');
	else
	  start_q  <= start;
	  rd_mode  <= rd_mode_nxt;
	  rd_add_int <= rd_add_nxt;
	  rd_add_col_int <= rd_add_col;
	  rd_add_rwcnt_int <= rd_add_rwcnt;
	  rd_add_colcnt_int <= rd_add_colcnt;
	  rx0 <= rx0_nxt;
	  rx1 <= rx1_nxt;
	  done_int  <= done_nxt;
	  ready_int <= ready_nxt;
	  prc_mode <= prc_mode_nxt;
	  prc_add_int <= prc_add_nxt;
	  tp_wr_mode <= tp_wr_mode_nxt;
	  twr_add_int <= twr_add_nxt;
	  twr_add_rwcnt_int <= twr_add_rwcnt_nxt;
	  twr_add_colcnt_int <= twr_add_colcnt;
	  tp_rd_mode <= tp_rd_mode_nxt;
	  trd_add_int <= trd_add_nxt;
	  scc_mode <= scc_mode_nxt;
	  scc_add_int <= scc_add_nxt;
	  wr_mode <= wr_mode_nxt;
	  wr_run_int <= wr_run;
	  wr_add_int <= wr_add_nxt;
	  wr_add_out_int <= wr_add_out_nxt;
	  wr_add_colcnt_int <= wr_add_colcnt;
	  wr_add_rwcnt_int  <= wr_add_rwcnt;
	  ry0 <= ry0_nxt;
	  ry1 <= ry1_nxt;
	  idat_sum_int <= idat_sum;
	  fdat_sum_int <= fdat_sum;
	end if;
      end if;
    end if;
  else 
    start_q  <= 'X';
    rd_mode  <= 'X';
    rd_add_int <= -1;
    rd_add_col_int <= -1;
    rd_add_rwcnt_int <= -1;
    rd_add_colcnt_int <= -1;
    rx0 <= (others => 'X');
    rx1 <= (others => 'X');
    done_int <= 'X';
    ready_int <= 'X';
    prc_mode <= 'X';
    --prc_add_int <= -1;
    tp_wr_mode <= 'X';
    twr_add_int <= -1;
    twr_add_rwcnt_int <= -1;
    twr_add_colcnt_int <= -1;
    tp_rd_mode <= 'X';
    trd_add_int <= -1;
    scc_mode <= 'X';
    scc_add_int <= -1;
    wr_mode <= 'X';
    wr_run_int <= 'X';
    wr_add_int <= -1;
    wr_add_out_int <= -1;
    wr_add_colcnt_int <= -1;
    wr_add_rwcnt_int  <= -1;
    ry0 <= (others => 'X');
    ry1 <= (others => 'X');
    idat_sum_int  <= (others => 'X');
    fdat_sum_int  <= (others => 'X');
  end if;-- reset ain't 1 or 0  
  end process;


  FRST_DCT : process (rx1, prc_add_int, rd_mode, tp_wr_mode)
    variable temp_prod: signed(frstprod -1 downto 0); 
    variable temp_data: signed(rddatsz +((1-tc_mode)*(1-idct_mode)) -1 downto 0);   
    variable temp_ppy, Xtemp_prod: signed(frstsum-1 downto 0);
    variable coef : unsigned(255 downto 0);
  begin
    --for i in 0 to n-1 loop
    if(idct_mode = 1) then
      coef := get_icoef(prc_add_int);
    else
      coef := get_fcoef(prc_add_int);
    end if;
    if(rd_mode  = '1' or tp_wr_mode = '1') then
      temp_ppy := (others => '0');
      for i in 0 to n-1 loop
      if(idct_mode = 0) then
        if(tc_mode = 0) then
	  temp_data := '0' &  SIGNED(rx1((i+1)*rddatsz-1 downto i*rddatsz));
	else
	  temp_data := SIGNED(rx1((i+1)*rddatsz-1 downto i*rddatsz));
	end if;
      else
        temp_data := SIGNED(rx1((i+1)*rddatsz-1 downto i*rddatsz));
      end if;
        temp_prod := temp_data *
                     SIGNED(coef((i+1)*16-1 downto i*16)); 
	temp_ppy := temp_ppy + temp_prod(frstprod-1 downto 0);
      end loop;
      
      if(temp_ppy(frstsum-1) = '0')then
        temp_ppy := temp_ppy + prmrnd;
      else
        temp_ppy := temp_ppy - prmrnd;
      end if;
      
        idat_sum <= std_logic_vector(temp_ppy);
      else
        idat_sum <= (others => '0');
      end if;
    --end loop;
  end process;
  
  SCND_DCT : process (ry1, scc_add_int, tp_rd_mode, wr_mode)
    variable temp_prod: signed(scndprod-1 downto 0);    
    variable temp_ppy, Xtemp_prod: signed(scndprod-1 downto 0);
    variable coef : unsigned(255 downto 0);
  begin
    --for i in 0 to n-1 loop
    if(idct_mode = 1) then
      coef := get_icoef(scc_add_int mod n);
    else
      coef := get_fcoef(scc_add_int mod n);
    end if;
    if(wr_mode = '1' or tp_rd_mode = '1') then
      temp_ppy := (others => '0');
      for i in 0 to n-1 loop
        temp_prod := SIGNED(ry1((i+1)*intdatsz-1 downto i*intdatsz)) *
                     SIGNED(coef((i+1)*16-1 downto i*16)); 
	temp_ppy := temp_ppy + temp_prod(scndprod-1 downto 0);
      end loop;
      
      if(rt_mode = 0) then
        if(temp_ppy(scndprod-1) = '0')then
          temp_ppy := temp_ppy + fnlrnd;
        else
          temp_ppy := temp_ppy - fnlrnd;
        end if;
      end if;
        fdat_sum <= std_logic_vector(temp_ppy);
      else
        fdat_sum <= (others => '0');
      end if;
    --end loop;
  end process;

  process (  rd_add_nxt,rd_add_int,rd_add_col,rd_add_col_int)
  begin
    if(idct_mode = 0) then
      if(reg_out = 0) then
        if(rd_add_int >= 0) then
          rd_add_out <= dw_conv_std_logic_vector(rd_add_int,addwidth);
	else
	  rd_add_out <= (others => 'X') ;
	end if;
      else 
        if(rd_add_int >= 0) then
          rd_add_out <= dw_conv_std_logic_vector(rd_add_nxt,addwidth);
	else
	  rd_add_out <= (others => 'X') ;
	end if;
      end if;
    else
      if(reg_out = 0) then
        if(rd_add_int >= 0) then
          rd_add_out <= dw_conv_std_logic_vector(rd_add_col_int,addwidth);
	else
	  rd_add_out <= (others => 'X') ;
	end if;
      else 
        if(rd_add_int >= 0) then
          rd_add_out <= dw_conv_std_logic_vector(rd_add_col,addwidth);
	else
	  rd_add_out <= (others => 'X') ;
	end if;
      end if;
    end if;

  end process;
process (wr_add_out_nxt, wr_add_out_int)
begin
  if(reg_out = 0) then
    if(wr_add_out_nxt >= 0) then
      wr_add_out <= dw_conv_std_logic_vector(wr_add_out_nxt,addwidth);
    else
      wr_add_out <= (others => 'X');
    end if;
  else
    if(wr_add_out_int >= 0) then
      wr_add_out <= dw_conv_std_logic_vector(wr_add_out_int,addwidth);
    else
      wr_add_out <= (others => 'X');
    end if;
  end if;  
end process;

-- port assigns  
  dct_rd_add     <= rd_add_out;
  tp_wr_add  <= dw_conv_std_logic_vector(twr_add_out,addwidth) when twr_add_out >=0 else (others => 'X');
  tp_rd_add  <= dw_conv_std_logic_vector(trd_add_int,addwidth) when trd_add_int >=0 else (others => 'X');
  tp_wr_n <= not tp_wr_run;
  tp_wr_data <= idat_sum(frstsum-1 downto frstsum -intdatsz) when (tp_wr_run = '1') 
                       else (others => '0');
  dct_wr_add  <= wr_add_out;
  dct_wr_n <=  not wr_run when reg_out = 0 else not wr_run_int;
  done  <= done_int when reg_out = 1 else done_nxt;
  ready <= ready_int when reg_out = 1 else ready_nxt;
  dct_wr_data <= (others => '0') when ((wr_run='0') and (reg_out = 0)) or ((wr_run_int='0') and (reg_out /= 0)) else
          fdat_sum(scndprod-1 downto scndprod-wrdatsz) when idct_mode = 0 else
          fdat_sum(wrdatsz+16 downto 17);

-- pragma translate_on
  end sim ;
  
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_dct_2d_cfg_sim of DW_dct_2d is
 for sim
 end for; -- sim
end DW_dct_2d_cfg_sim;
-- pragma translate_on

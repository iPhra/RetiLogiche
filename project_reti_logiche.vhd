library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity header is
    port(
        forced_reset : in std_logic;
        header_start : in std_logic;
        i_data : in std_logic_vector(7 downto 0);
        i_rst : in std_logic;
        i_clk : in std_logic;
        rows : out std_logic_vector(7 downto 0);
        cols : out std_logic_vector(7 downto 0);
        threshold : out std_logic_vector(7 downto 0);
        address : out std_logic_vector (15 downto 0);
        header_done : out std_logic
    );
end header;

architecture Behavioral of header is

type state_type is (S0, S1, S2, S3, S4, S5);
signal state : state_type;
constant TWO : std_logic_vector(15 downto 0) := "0000000000000010";
constant THREE : std_logic_vector(15 downto 0) := "0000000000000011";
constant FOUR : std_logic_vector(15 downto 0) := "0000000000000100";
constant FIVE : std_logic_vector(15 downto 0) := "0000000000000101";

begin

    HEAD : process(i_rst, i_clk, header_start, forced_reset)
    begin
        if i_rst = '1' or forced_reset = '1' then
            rows <= (others => '0');
            cols <= (others => '0');
            threshold <= (others => '0');
            state <= S0;
        elsif rising_edge(i_clk) then
            if header_start = '1' then
                if state = S0 then
                    address <= TWO;
                    state <= S1;
                elsif state = S1 then
                    address <= THREE;
                    state <= S2;
                elsif state = S2 then
                    address <= FOUR;
                    state <= S3;
                    cols <= i_data;
                elsif state = S3 then
                    address <= FIVE;
                    state <= S4;
                    rows <= i_data;
                elsif state = S4 then
                    threshold <= i_data;
                    state <= S5;
                end if;
            end if;
        end if;
    end process;

    with state select
        header_done <= '1' when S5,
                       '0' when others;
                       
                        
end Behavioral;



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity input is
    port(
      forced_reset : in std_logic;
      input_start : in std_logic;
      i_rst : in std_logic;
      i_clk : in std_logic;  
      i_data : in std_logic_vector(7 downto 0);
      threshold : in std_logic_vector(7 downto 0);
      rows : in std_logic_vector(7 downto 0);
      cols : in std_logic_vector(7 downto 0);
      top_row: out std_logic_vector(7 downto 0);
      bottom_row: out std_logic_vector(7 downto 0);
      left_col: out std_logic_vector(7 downto 0);
      right_col: out std_logic_vector(7 downto 0);
      address : out std_logic_vector(15 downto 0);
      input_done : out std_logic
    );
end input;

architecture Behavioral of input is

type state_type is (S0, S1, S2, S3);
signal state : state_type;
signal tmp_address : std_logic_vector(15 downto 0);
signal tmp_top_row : std_logic_vector(7 downto 0);
signal tmp_left_col : std_logic_vector(7 downto 0);
signal tmp_right_col : std_logic_vector(7 downto 0);
signal prev_col : std_logic_vector(7 downto 0);
signal prev_row : std_logic_vector(7 downto 0);

begin

    READ: process(i_clk, i_rst, forced_reset, input_start)

    begin
        if i_rst = '1' or forced_reset = '1' then
            state <= S0;
        elsif rising_edge(i_clk) then
            if input_start = '1' then
                if state = S0 then
                    top_row <= rows;
                    tmp_top_row <= rows;
                    bottom_row <= "00000000";
                    left_col <= cols;
                    tmp_left_col <= cols;
                    right_col <= "00000000";
                    tmp_right_col <= "00000000";
                    prev_col <= "00000001";
                    prev_row <= "00000001";
                    tmp_address <= (2 => '1', 0 => '1', others => '0');
                    address <= (2 => '1', 0 => '1', others => '0');
                    if rows = "00000000" or cols = "00000000" then
                        state <= S3;
                    else
                        state <= S1;
                    end if; 
                end if;
                if state = S1 then
                    prev_col <= "00000001";
                    prev_row <= "00000001";
                    tmp_address <= std_logic_vector(unsigned(tmp_address) +1);
                    address <= std_logic_vector(unsigned(tmp_address) +1);
                    if threshold <= i_data then
                       bottom_row <= prev_row;
                       if prev_row <= tmp_top_row then
                           tmp_top_row <= prev_row;
                           top_row <= prev_row;
                       end if;
                       if tmp_right_col <= prev_col then
                           right_col <= prev_col;
                           tmp_right_col <= prev_col;
                       end if;
                       if prev_col <= tmp_left_col then
                           left_col <= prev_col;
                           tmp_left_col <= prev_col;
                       end if;
                    end if;
                    state <= S2;
                elsif state = S2 then
                    tmp_address <= std_logic_vector(unsigned(tmp_address) +1);
                    address <= std_logic_vector(unsigned(tmp_address) +1);
                    if threshold <= i_data then
                       bottom_row <= prev_row;
                       if prev_row <= tmp_top_row then
                           tmp_top_row <= prev_row;
                           top_row <= prev_row;
                       end if;
                       if tmp_right_col <= prev_col then
                           right_col <= prev_col;
                           tmp_right_col <= prev_col;
                       end if;
                       if prev_col <= tmp_left_col then
                           left_col <= prev_col;
                           tmp_left_col <= prev_col;
                       end if;
                    end if;
                    if prev_col < cols then
                       prev_col <= std_logic_vector(unsigned(prev_col)+1); 
                    elsif prev_col = cols and prev_row < rows then
                       prev_col <= "00000001";
                       prev_row <= std_logic_vector(unsigned(prev_row)+1);
                    elsif prev_col = cols and prev_row = rows then
                       state <= S3;
                    end if;
                end if;
            end if;
        end if;
    end process;
    
    with state select
        input_done <= '1' when S3,
                      '0' when others;
    
        
end Behavioral;
       
             
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity compute_result is
    port(
        forced_reset : in std_logic;
        i_rst : in std_logic;
        i_clk : in std_logic;
        top_row : in std_logic_vector(7 downto 0);
        bottom_row : in std_logic_vector(7 downto 0);
        left_col : in std_logic_vector(7 downto 0); 
        right_col : in std_logic_vector(7 downto 0);
        result : out std_logic_vector(15 downto 0);
        compute_result_start : in std_logic;
        compute_result_done : out std_logic
    );
end compute_result;


architecture Behavioral of compute_result is

type state_type is (S0, S1, S2, S3);
signal state : state_type;    
signal width : std_logic_vector(7 downto 0);
signal height : std_logic_vector(7 downto 0);
signal mult_end : std_logic;
signal tmp_result : std_logic_vector(15 downto 0);
constant ZERO: std_logic_vector(15 downto 0) := "0000000000000000";
constant ZERO8 : std_logic_vector(7 downto 0) := "00000000";

begin


RES: process(i_clk,compute_result_start, i_rst, forced_reset)
    
    begin
        if i_rst = '1' or forced_reset = '1' then
            compute_result_done <= '0';
            state <= S0;
        elsif rising_edge(i_clk) then
            if compute_result_start='1' then
                if state = S0 then
                    if left_col = ZERO8 or bottom_row = ZERO8 then
                        result <= ZERO;
                        compute_result_done <= '1';
                        state <= S3;
                    else
                        state <= S1;
                    end if;
                elsif state = S1 then
                    width <= std_logic_vector(unsigned(right_col)-unsigned(left_col)+1);
                    height <= std_logic_vector(unsigned(bottom_row)-unsigned(top_row)+1);
                    state <= S2;
                elsif state = S2 and mult_end = '1'then
                    result <= tmp_result;
                    compute_result_done <= '1';
                    state <= S3;
                end if;
            end if;
        end if;
    end process;
    
DESYNC: process(i_rst, state, forced_reset)
    begin
        if i_rst = '1' or forced_reset = '1' then
           mult_end <= '0';
        elsif state=S2 then
           tmp_result <= std_logic_vector(unsigned(width)*unsigned(height));
           mult_end <= '1';
        end if;
    end process;
             
 
end Behavioral;  
    
             
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity output is
    port(
        forced_reset : in std_logic;
        output_start : in std_logic;
        i_rst : in std_logic;
        i_clk : in std_logic;
        result : in std_logic_vector(15 downto 0);
        o_we : out std_logic;
        o_data : out std_logic_vector (7 downto 0);
        address : out std_logic_vector (15 downto 0);
        output_done : out std_logic
    );
end output;

architecture Behavioral of output is

type state_type is (S0, S1, S2, S3);
signal state : state_type;
constant ZERO: std_logic_vector(15 downto 0) := "0000000000000000";
constant ONE : std_logic_vector(15 downto 0) := "0000000000000001";
constant TWO : std_logic_vector(15 downto 0) := "0000000000000010";


begin

    WRITE: process(i_rst, i_clk, output_start, forced_reset)
    begin
        if i_rst = '1' or forced_reset = '1' then
            state <= S0;
        elsif rising_edge(i_clk) then
            if output_start = '1' then
                if state = S0 then
                    address <= ZERO;
                    o_data <= result(7 downto 0);
                    state <= S1;
                elsif state = S1 then
                    address <= ONE;
                    o_data <= result(15 downto 8);
                    state <= S2;
                elsif state = S2 then
                    state <= S3;
                end if;
            end if;
        end if;
    end process;
                      
    with state select
        output_done <= '1' when S2,
                       '0' when others;
   
    with state select
        o_we <= '1' when S1,
                '1' when S2,
                '0' when others;
    
end Behavioral;

             
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity project_reti_logiche is 
    port (
            i_clk : in  std_logic;
            i_start : in std_logic;
            i_rst : in  std_logic;
            i_data : in  std_logic_vector(7 downto 0); --1 byte
            o_address : out std_logic_vector(15 downto 0); --16 bit addr: max size is 255*255 + 3 more for max x and y and thresh.
            o_done : out std_logic;
            o_en : out std_logic;
            o_we : out std_logic;
            o_data : out std_logic_vector (7 downto 0)
      );
end project_reti_logiche;


architecture Behavioral of project_reti_logiche is 

type state_type is (S0, S1, S2, S3, S4);
signal state : state_type;
signal header_start : std_logic;
signal input_start : std_logic;
signal output_start : std_logic;
signal compute_result_start : std_logic;
signal header_done : std_logic;
signal input_done : std_logic;
signal output_done : std_logic;
signal compute_result_done : std_logic;
signal forced_reset : std_logic;
signal header_address : std_logic_vector(15 downto 0);
signal input_address : std_logic_vector(15 downto 0);
signal output_address : std_logic_vector(15 downto 0);
signal rows : std_logic_vector(7 downto 0);
signal cols : std_logic_vector(7 downto 0);
signal threshold : std_logic_vector(7 downto 0);
signal top_row : std_logic_vector(7 downto 0);
signal bottom_row : std_logic_vector(7 downto 0);
signal left_col : std_logic_vector(7 downto 0);
signal right_col : std_logic_vector(7 downto 0);
signal result : std_logic_vector (15 downto 0);

component header is
    port(
        forced_reset : in std_logic;
        header_start : in std_logic;
        i_data : in std_logic_vector(7 downto 0);
        i_rst : in std_logic;
        i_clk : in std_logic;
        rows : out std_logic_vector(7 downto 0);
        cols : out std_logic_vector(7 downto 0);
        threshold : out std_logic_vector(7 downto 0);
        address : out std_logic_vector (15 downto 0);
        header_done : out std_logic
    );
end component;

component input is
    port(
      forced_reset : in std_logic;
      input_start : in std_logic;
      i_rst : in std_logic;
      i_clk : in std_logic;  
      i_data : in std_logic_vector(7 downto 0);
      threshold : in std_logic_vector(7 downto 0);
      rows : in std_logic_vector(7 downto 0);
      cols : in std_logic_vector(7 downto 0);
      top_row: out std_logic_vector(7 downto 0);
      bottom_row: out std_logic_vector(7 downto 0);
      left_col: out std_logic_vector(7 downto 0);
      right_col: out std_logic_vector(7 downto 0);
      address : out std_logic_vector(15 downto 0);
      input_done : out std_logic
    );
end component;

component compute_result is
    port(
        forced_reset : in std_logic;
        i_rst : in std_logic;
        i_clk : in std_logic;
        top_row : in std_logic_vector(7 downto 0);
        bottom_row : in std_logic_vector(7 downto 0);
        left_col : in std_logic_vector(7 downto 0); 
        right_col : in std_logic_vector(7 downto 0);
        result : out std_logic_vector(15 downto 0);
        compute_result_start : in std_logic;
        compute_result_done : out std_logic
    );
end component;

component output is
    port(
        forced_reset : in std_logic;
        output_start : in std_logic;
        i_rst : in std_logic;
        i_clk : in std_logic;
        result : in std_logic_vector(15 downto 0);
        o_we : out std_logic;
        o_data : out std_logic_vector (7 downto 0);
        address : out std_logic_vector (15 downto 0);
        output_done : out std_logic
    );
end component;

begin

    HEA: header
    port map(forced_reset, header_start, i_data, i_rst, i_clk, rows, cols, threshold, header_address, header_done);
    
    INP: input
    port map(forced_reset, input_start, i_rst, i_clk, i_data, threshold, rows, cols, top_row, bottom_row, left_col, right_col, input_address, input_done);
    
    RES: compute_result
    port map(forced_reset, i_rst, i_clk, top_row, bottom_row, left_col, right_col, result, compute_result_start, compute_result_done);
    
    OUTP: output
    port map(forced_reset, output_start, i_rst, i_clk, result, o_we, o_data, output_address, output_done);
     
        
    CONTROLLER: process(i_rst, i_clk)
    begin
        o_done <= '0';
        forced_reset <= '0';
        if i_rst='1' then
            header_start <= '0';
            input_start <= '0';
            output_start <= '0';
            compute_result_start <= '0';
            state <= S0;
        elsif rising_edge(i_clk) then
            if state = S0 and i_start = '1' then  
                header_start <= '1';
                state <= S1;
            elsif state = S1 and header_done = '1' then
                input_start <= '1';
                state <= S2;
            elsif state = S2 and input_done = '1' then
                compute_result_start <= '1';
                state <= S3;
            elsif state = S3 and compute_result_done = '1' then
                output_start <= '1';
                state <= S4;
            elsif state = S4 and output_done = '1' then
                header_start <= '0';
                input_start <= '0';
                output_start <= '0';
                compute_result_start <= '0';
                state <= S0;
                o_done <= '1';
                forced_reset <= '1';
            end if;
        end if;
    end process;
    
    with state select 
        o_address <= header_address when S1,
                     input_address when S2,
                     output_address when S4,
                     "0000000000000000" when others;
    
    o_en <= '0' when state = S0 and i_start = '0' else
            '1';
                          
end Behavioral;







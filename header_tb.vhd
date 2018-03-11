library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


entity header_tb is
end header_tb;

architecture Behavioral of header_tb is

constant c_CLOCK_PERIOD		: time := 15 ns;
signal   header_done		: std_logic := '0';
signal   mem_address		: std_logic_vector (15 downto 0) := (others => '0');
signal   tb_rst		    : std_logic := '0';
signal   header_start		: std_logic := '0';
signal   tb_clk		    : std_logic := '0';
signal   mem_o_data		: std_logic_vector (7 downto 0);
signal   enable_wire  		: std_logic := '1';
signal   rows : std_logic_vector(7 downto 0);
signal   cols : std_logic_vector(7 downto 0);
signal   forced_reset : std_logic := '0';
signal   threshold : std_logic_vector(7 downto 0);

type ram_type is array (65535 downto 0) of std_logic_vector(7 downto 0);
--signal RAM: ram_type := (0 => "00011000", 1 =>"00000111",2 => "00000010", 29 => "00000011", 30 => "00000011", 31 => "00000011", 32 => "00000011", 35 => "00000111", 36 => "00000111", 37 => "00000111", 38 => "00000111", 41 => "00001011", 42 => "00001011", 43 => "00001011", 44 => "00001011", 47 => "00001111", 53 => "00000011", 59 => "00000111", 65 => "00011111", 71 => "00011001", 77 => "00000011", 78 => "00000011", 79 => "00000011", 83 => "00000111", 84 => "00000111", 85 => "00000111", 89 => "00011111", 90 => "00011111", 91 => "00011111", 95 => "00011001", 101 => "00000011", 107 => "00000111", 113 => "00011111", 119 => "00011001", 125 => "00000011", 131 => "00000111", 132 => "00000111", 133 => "00000111", 134 => "00000111", 137 => "00001011", 138 => "00001011", 139 => "00001011", 140 => "00001011", 143 => "00001111", 144 => "00001111", 145 => "00001111", 146 => "00001111", others => (others =>'0'));
signal RAM: ram_type := (2 => "00011000", 3 =>"00000111",4 => "00000010", 30 => "00000011", 31 => "00000011", 32 => "00000011", 33 => "00000011", 36 => "00000111", 37 => "00000111", 38 => "00000111", 39 => "00000111", 42 => "00001011", 43 => "00001011", 44 => "00001011", 45 => "00001011", 48 => "00001111", 54 => "00000011", 60 => "00000111", 66 => "00011111", 72 => "00011001", 78 => "00000011", 79 => "00000011", 80 => "00000011", 84 => "00000111", 85 => "00000111", 86 => "00000111", 90 => "00011111", 91 => "00011111", 92 => "00011111", 96 => "00011001", 102 => "00000011", 108 => "00000111", 114 => "00011111", 120 => "00011001", 126 => "00000011", 132 => "00000111", 133 => "00000111", 134 => "00000111", 135 => "00000111", 138 => "00001011", 139 => "00001011", 140 => "00001011", 141 => "00001011", 144 => "00001111", 145 => "00001111", 146 => "00001111", 147 => "00001111", others => (others =>'0'));

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
end component header;

begin
    HEAD: header
    port map(forced_reset, header_start, mem_o_data, tb_rst, tb_clk, rows, cols, threshold, mem_address, header_done);
    
    p_CLK_GEN : process is
      begin
        wait for c_CLOCK_PERIOD/2;
        tb_clk <= not tb_clk;
      end process p_CLK_GEN; 
      
      
    MEM : process(tb_clk)
       begin
        if tb_clk'event and tb_clk = '1' then
         if enable_wire = '1' then
            mem_o_data <= RAM(conv_integer(mem_address)) after 1ns;
          end if;
         end if;
       end process;
       
    test : process is
       begin 
       wait for 100 ns;
       wait for c_CLOCK_PERIOD;
       tb_rst <= '1';
       wait for c_CLOCK_PERIOD;
       tb_rst <= '0';
       wait for c_CLOCK_PERIOD;
       header_start <= '1';
       wait until header_done = '1';
       wait until rising_edge(tb_clk); 
       
       assert rows = "00000111"  report "FAIL rows" severity failure;
       assert cols = "00011000" report "FAIL cols" severity failure;
       assert threshold = "00000010" report "FAIL threshold" severity failure;
       
       
       assert false report "Simulation Ended!, test passed" severity failure;
       end process test;
       
end Behavioral; 


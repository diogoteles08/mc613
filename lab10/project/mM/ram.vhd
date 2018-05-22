library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram is
    generic(
		depth : natural := 12;
		width: natural := 32;
		init_file : string := ""
	);
    port(
		clk : in std_logic;
        memwrite:  in std_logic;
        ra, wa : in std_logic_vector(depth-1 downto 0);
        writedata : in std_logic_vector(width-1 downto 0);
        memdata : out std_logic_vector(width-1 downto 0)
	);
end ram;

architecture a_ram of ram is
	type mem_type is array (0 to 2**depth-1) of std_logic_vector(width-1 downto 0);
	attribute ram_init_file : string;
	
	signal data : mem_type;
	signal read_a : std_logic_vector(depth-1 downto 0);
	attribute ram_init_file of data : signal is init_file;	
begin
	
	process(clk)
		begin
			if clk'event and clk = '1' then
				if memwrite = '1' then
					data(to_integer(unsigned(wa))) <= writedata;
				end if;
				read_a <= ra;
			end if;
		end process;
	memdata <= data(to_integer(unsigned(read_a)));
	
end a_ram;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom is
	generic (
		depth : natural := 12;
		width : natural := 32; 
		init_file : string := ""
	);
	port(
      clk : in std_logic;
      adr: in std_logic_vector(depth-1 downto 0);
      memdata: out std_logic_vector(width-1 downto 0)
      );
end rom;

architecture a_rom of rom is
	type mem_type is array (0 to 2**depth-1) of std_logic_vector(width-1 downto 0);
	attribute ram_init_file : string;
	
	signal data : mem_type;
	attribute ram_init_file of data : signal is init_file;	
	signal read_a : std_logic_vector(depth-1 downto 0);
begin
	
	process(clk)
	begin
      if clk'event and clk = '1' then
		read_a <= adr;
      end if;
	end process;
	memdata <= data(to_integer(unsigned(read_a)));

end a_rom;
 -- Quartus Prime VHDL Template
 -- Single port RAM with single read/write address 

 library ieee;
 use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

 entity ram_block is

			generic 
			(
				 DATA_WIDTH : natural := 8;
				 ADDR_WIDTH : natural := 7 
			);

			port 
			(
				 Clock		: in std_logic;
				 Address : in std_logic_vector(ADDR_WIDTH -1 downto 0);
				 Data	: in std_logic_vector((DATA_WIDTH-1) downto 0);
				 WrEn		: in std_logic := '0';
				 Q		: out std_logic_vector((DATA_WIDTH -1) downto 0)
			);

 end entity;

 architecture rtl of ram_block is

			-- Build a 2-D array type for the RAM
			subtype word_t is std_logic_vector((DATA_WIDTH-1) downto 0);
			type memory_t is array(2**ADDR_WIDTH-1 downto 0) of word_t;

			-- Declare the RAM signal.	
			signal ram : memory_t;

			-- Register to hold the address 
			signal addr_reg : natural range 0 to 2**ADDR_WIDTH-1;
	
 begin

			process(Clock)
				variable numero: natural range 0 to 2**ADDR_WIDTH - 1;
			begin
			if(Clock'EVENT and Clock = '1') then
				 numero := to_integer(unsigned(Address));
				 if(WrEn = '1') then
							ram(numero) <= Data;
				 end if;
				 addr_reg <= numero;
			end if;
			end process;

			-- leitura sincrona, pois addr_reg so muda com o Clock
			Q <= ram(addr_reg);

end rtl;

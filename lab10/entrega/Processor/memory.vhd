library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

 entity memory is

        generic 
        (
                WORDSIZE        : natural := 8;
                BITS_OF_ADDR    : natural := 16;
                MIF_FILE        : string := ""
        );

        port 
        (
                 clock		: in std_logic;
                 we             : in std_logic;
                 address        : in std_logic_vector(BITS_OF_ADDR -1 downto 0);
                 datain	        : in std_logic_vector((WORDSIZE-1) downto 0);
                 dataout	: out std_logic_vector((WORDSIZE -1) downto 0)
        );

 end entity;

 architecture rtl of memory is

    type memoria is array (0 to 2**BITS_OF_ADDR -1) of std_logic_vector(WORDSIZE -1  downto 0);

	 signal ram : memoria;
	 attribute ram_init_file : string;
	 attribute ram_init_file of ram: signal is MIF_FILE;
	 signal addr_reg : natural range 0 to 2**BITS_OF_ADDR-1;

 begin

    process(clock)
    begin
        if(clock'EVENT and clock = '1') then
             if(we = '1') then
                ram(to_integer(unsigned(address))) <= datain;
             end if;
				 addr_reg <= to_integer(unsigned(address));

        end if;
    end process;

	 dataout <= ram(addr_reg);

end rtl;


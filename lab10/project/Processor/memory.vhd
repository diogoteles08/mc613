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

-- todo: modifique-o para que ele siga as especificações da Memória de Instrução (IM) e da
-- Memória de Dados (DM) do processador m1ps
 architecture rtl of memory is

---- Build a 2-D array type for the RAM
--subtype word_t is std_logic_vector((WORDSIZE-1) downto 0);
--type memory_t is array(2**BITS_OF_ADDR-1 downto 0) of word_t;
--
---- Declare the RAM signal.	
--signal ram : memory_t;
--
---- Register to hold the address 
--signal addr_reg : natural range 0 to 2**BITS_OF_ADDR-1;
    type memoria is array (0 to 2**BITS_OF_ADDR -1) of std_logic_vector(WORDSIZE -1  downto 0);
    signal ram : memoria;
	 attribute ram_init_file : string;
	 attribute ram_init_file of ram signal is MIF_FILE;
	 
    signal endereco : integer := 0;
 begin

    endereco <= to_integer(unsigned(address));

    process(clock)
    begin
        if(clock'EVENT and clock = '1') then
             if(we = '1') then
                ram(endereco) <= datain;
             end if;
        end if;
    end process;

    -- leitura assincrona
    dataout <= ram(endereco);

end rtl;

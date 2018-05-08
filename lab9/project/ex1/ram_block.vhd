library ieee;
use ieee.std_logic_1164.all;

entity ram_block is
  port (
    Clock : in std_logic;
    Address : in std_logic_vector(6 downto 0);
    Data : in std_logic_vector(7 downto 0);
    Q : out std_logic_vector(7 downto 0);
    WrEn : in std_logic
  );
end ram_block;

architecture direct of ram_block is
	signal memoria : std_logic_vector(511 downto 0);
begin
	-- todo: Clock eh o nosso Clock?
	process (Clock)
	begin
		if Clock'EVENT and Clock = '1' then
		-- escritura sincrona com o clock
			if WrEn = '1' then
				-- verificando se escrita esta enabled
				-- todo: arrumar (Address) eh assim que escreve em enderecos de vetor?
				memoria(Address) <= Data;
			end if;
		end if;
	end process;
  
    
	-- leitura assincrona
	-- todo: sempre fica lendo assim mesmo?
	-- todo: arrumar (Address) eh assim que escreve em enderecos de vetor?
	Q <= memoria(Address);
end direct;

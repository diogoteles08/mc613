library ieee;
use ieee.std_logic_1164.all;

entity ram is
  port (
    Clock : in std_logic;
    Address : in std_logic_vector(9 downto 0);
    DataIn : in std_logic_vector(31 downto 0);
    DataOut : out std_logic_vector(31 downto 0);
    WrEn : in std_logic
  );
end ram;

architecture rtl of ram is

component ram_block is

-- todo: duvida desse generic
generic (
		 DATA_WIDTH : natural := 8;
		 ADDR_WIDTH : natural := 7 
);

port (
		 Clock		: in std_logic;
		 Address : in std_logic_vector(ADDR_WIDTH -1 downto 0);
		 Data	: in std_logic_vector((DATA_WIDTH-1) downto 0);
		 WrEn		: in std_logic := '1';
		 Q		: out std_logic_vector((DATA_WIDTH -1) downto 0)
);

end component;

	signal WrEn_V : std_logic_vector(1 downto 0) := "11";
	signal Data_0 : std_logic_vector(31 downto 0);
	signal Data_1 : std_logic_vector(31 downto 0);
	
begin
  ram_b11: ram_block port map (Clock => Clock,
										  Address => Address(6 downto 0), 
										  Data => DataIn(31 downto 24), 
										  Q => Data_0(31 downto 24), 
										  WrEn => WrEn_V(0)
  );
  ram_b12: ram_block port map (Clock => Clock, Address => Address(6 downto 0), Data => DataIn(23 downto 16), Q => Data_0(23 downto 16), WrEn => WrEn_V(0) );
  ram_b13: ram_block port map (Clock => Clock, Address => Address(6 downto 0), Data => DataIn(15 downto 8), Q => Data_0(15 downto 8), WrEn => WrEn_V(0) );
  ram_b14: ram_block port map (Clock => Clock, Address => Address(6 downto 0), Data => DataIn(7 downto 0), Q => Data_0(7 downto 0), WrEn => WrEn_V(0) );
  ram_b21: ram_block port map (Clock => Clock, Address => Address(6 downto 0), Data => DataIn(31 downto 24), Q => Data_1(31 downto 24), WrEn => WrEn_V(1) );
  ram_b22: ram_block port map (Clock => Clock, Address => Address(6 downto 0), Data => DataIn(23 downto 16), Q => Data_1(23 downto 16), WrEn => WrEn_V(1) );
  ram_b23: ram_block port map (Clock => Clock, Address => Address(6 downto 0), Data => DataIn(15 downto 8), Q => Data_1(15 downto 8), WrEn => WrEn_V(1) );
  ram_b24: ram_block port map (Clock => Clock, Address => Address(6 downto 0), Data => DataIn(7 downto 0), Q => Data_1(7 downto 0), WrEn => WrEn_V(1) );
  
  process (Clock)
  begin 
		if(rising_edge(Clock)) then
			if WrEn = '1' then
				if Address(9) = '1' or Address(8) = '1' then
					-- endereco invalido
					-- todo: assim ? alta impedancia em DataOut
					WrEn_v(1 downto 0) <= "00";
					-- todo: isso aqui acho que vai dar problema
					DataOut <= (others => 'Z');
				elsif Address(7) = '1' then
					-- endereco valido de 128 a 255
					WrEn_v(1 downto 0) <= "10";
					DataOut <= Data_1;
				else
					-- endereco valido de 0 a 127
					WrEn_v(1 downto 0) <= "01";
					DataOut <= Data_0;
				end if;
			end if;
		end if;
  end process;
end rtl;

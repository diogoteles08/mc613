library ieee;
use ieee.std_logic_1164.all;

entity ram is
  port (
    Clock : in std_logic;
    Address : in std_logic_vector(9 downto 0);
    DataIn : in std_logic_vector(31 downto 0);
    DataOut : out std_logic_vector(31 downto 0);
	 Data0_aux : out std_logic_vector(31 downto 0);
    Data1_aux : out std_logic_vector(31 downto 0);
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

	signal WrEn_0 : std_logic := '0';
	signal WrEn_1 : std_logic := '0';
	signal Data_0 : std_logic_vector(31 downto 0);
	signal Data_1 : std_logic_vector(31 downto 0);
	signal endereco : std_logic_vector(9 downto 0) := "0000000000";

	
begin
  ram_b11: ram_block port map (Clock => Clock, Address => endereco(6 downto 0), Data => DataIn(31 downto 24), Q => Data_1(31 downto 24), WrEn => WrEn_1 );
  ram_b12: ram_block port map (Clock => Clock, Address => endereco(6 downto 0), Data => DataIn(23 downto 16), Q => Data_1(23 downto 16), WrEn => WrEn_1 );
  ram_b13: ram_block port map (Clock => Clock, Address => endereco(6 downto 0), Data => DataIn(15 downto 8), Q => Data_1(15 downto 8), WrEn => WrEn_1 );
  ram_b14: ram_block port map (Clock => Clock, Address => endereco(6 downto 0), Data => DataIn(7 downto 0), Q => Data_1(7 downto 0), WrEn => WrEn_1 );
  ram_b21: ram_block port map (Clock => Clock, Address => endereco(6 downto 0), Data => DataIn(31 downto 24), Q => Data_0(31 downto 24), WrEn => WrEn_0 );
  ram_b22: ram_block port map (Clock => Clock, Address => endereco(6 downto 0), Data => DataIn(23 downto 16), Q => Data_0(23 downto 16), WrEn => WrEn_0 );
  ram_b23: ram_block port map (Clock => Clock, Address => endereco(6 downto 0), Data => DataIn(15 downto 8), Q => Data_0(15 downto 8), WrEn => WrEn_0 );
  ram_b24: ram_block port map (Clock => Clock, Address => endereco(6 downto 0), Data => DataIn(7 downto 0), Q => Data_0(7 downto 0), WrEn => WrEn_0 );
  

   WrEn_0 <= '1' when endereco(9 downto 8) = "00" and WrEn = '1' and endereco(7) = '0' else '0';
   WrEn_1 <= '1' when endereco(9 downto 8) = "00" and WrEn = '1' and endereco(7) = '1' else '0';
  
   DataOut <= (others => 'Z') when endereco(9 downto 8) /= "00" else
				 Data_1 when endereco(7) = '1' else
				 Data_0 when endereco(7) = '0';
				 
	process(Clock)
	begin
		if (rising_edge(Clock)) then
			endereco <= Address;
		end if;
	end process;
--	
--    process(Clock)
--	 begin 
--    if (Address(9 downto 8) = "00") then
--		case Address(7) is
--		  when '1' => DataOut <= Data_1;
--		  when '0' => DataOut <= Data_0;
--		end case;
--	 else
--		DataOut <= (others => 'Z');
--	 end if;	 
--	end process;		      
end rtl;

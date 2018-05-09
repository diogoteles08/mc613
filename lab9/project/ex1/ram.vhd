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
		 Address	: in natural range 0 to 2**ADDR_WIDTH - 1;
		 Data	: in std_logic_vector((DATA_WIDTH-1) downto 0);
		 WrEn		: in std_logic := '1';
		 Q		: out std_logic_vector((DATA_WIDTH -1) downto 0)
);

	signal WrEn_V : std_logic_vector(7 downto 0) := "1111111";
end component;

begin
  ram_b1: ram_block port map (Clock <= Clock; Address <= ; Data <= DataIn; Q <= DataOut; WrEn <= WrEn_V(0); );
  ram_b2: ram_block port map (Clock <= Clock; Address <= ; Data <= DataIn; Q <= DataOut; WrEn <= WrEn_V(1); );
  ram_b3: ram_block port map (Clock <= Clock; Address <= ; Data <= DataIn; Q <= DataOut; WrEn <= WrEn_V(2); );
  ram_b4: ram_block port map (Clock <= Clock; Address <= ; Data <= DataIn; Q <= DataOut; WrEn <= WrEn_V(3); );
  ram_b5: ram_block port map (Clock <= Clock; Address <= ; Data <= DataIn; Q <= DataOut; WrEn <= WrEn_V(4); );
  ram_b6: ram_block port map (Clock <= Clock; Address <= ; Data <= DataIn; Q <= DataOut; WrEn <= WrEn_V(5); );
  ram_b7: ram_block port map (Clock <= Clock; Address <= ; Data <= DataIn; Q <= DataOut; WrEn <= WrEn_V(6); );
  ram_b8: ram_block port map (Clock <= Clock; Address <= ; Data <= DataIn; Q <= DataOut; WrEn <= WrEn_V(7); );
  
  process (Clock)
  begin 
		if(rising_edge(Clock)) then
			if WrEn = '1' then
			
			end if;
		end if;
  end process;
end rtl;

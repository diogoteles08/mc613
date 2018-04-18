library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity clk_div is
  port (
    clk : in std_logic;
    clk_hz : out std_logic
  );
end clk_div;

architecture behavioral of clk_div is
	signal estado : std_logic;
	signal change_clk : std_logic := '0';
	signal counter : std_logic_Vector (27 downto 0) := "0000000000000000000000000000";
begin

	clk_hz <= change_clk;
	process (clk)
	begin
			if rising_edge(clk) then
				counter <= counter + "0000000000000000000000000001";
				if counter = x"17d7840" then
					change_clk <= not(change_clk);
					counter <= "0000000000000000000000000000";
				end if;
			end if;
	end process;
end behavioral;

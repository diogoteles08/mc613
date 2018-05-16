library ieee;
use ieee.std_logic_1164.all;

entity flopar is
    generic(
		width: natural := 32
	);
    port(
		clk, reset: in std_logic;
        d: in  std_logic_vector(width-1 downto 0);
        q: out std_logic_vector(width-1 downto 0));
end flopar;

architecture a_flopar of flopar is
begin
    process(clk, reset) begin
		if reset = '1' then
			q <= (others => '0');
        elsif clk'event and clk = '1' then
            q <= d;
        end if;
    end process;
end a_flopar;

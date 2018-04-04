library ieee;
use ieee.std_logic_1164.all;

entity latch_sr_nand is

port (
	 S_n : in std_Logic;
	 R_n : in std_Logic;
    Qa : out std_logic;
    Qb :  out std_logic;
);

end latch_sr_nand;

architecture behavorial of latch_sr_nand is
	signal sr_n : std_logic_vector(1 downto 0);
begin

	process ( S, R )
		variable temp_a : std_logic;
		variable temp_b : std_logic;
	begin
		sr_n <= S_n & R_n;
		if sr_n = "00" then
			temp_a <= '1';
			temp_b <= '1';
		elsif sr_n = "10" then
			temp_a <= '0';
			temp_b <= '1';
		elsif sr_n = "01" then
			temp_a <= '1';
			temp_b <= '0';
		else
			temp_a <= temp_a;
			temp_b <= temp_b;
		end if;
		Qa <= temp_a;
		Qb <= temp_b;
	end process;
end behavorial;
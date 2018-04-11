library ieee;
use ieee.std_logic_1164.all;

entity ff_jk is

port (
	 J : in std_Logic;
    K : in std_Logic;
	 Clk : in std_logic;  
    Q : out std_logic;
    Q_n :  out std_logic;
    Preset : in std_logic;
    Clear : in std_logic
);

end ff_jk;

architecture behavorial of ff_jk is
	signal jk : std_logic_vector(1 downto 0);
begin

	process ( J, K, Clk )
		variable temp : std_logic;
	begin
		jk <= J & K;
		if Clk'EVENT AND Clk = '1' then
			if Clear = '1' then
				temp := '0';
			elsif Preset = '1' then
				temp := '1';
			elsif jk = "00" then
				temp := temp;
			elsif jk = "01" then
				temp := '0';
			elsif jk = "10" then
				temp := '1';
			else
				temp := not(temp);
			end if;
		end if;
		Q <= temp;
		Q_n <= not(temp);
	end process;
end behavorial;
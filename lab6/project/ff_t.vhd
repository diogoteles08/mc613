library ieee;
use ieee.std_logic_1164.all;

entity ff_t is

port (
	 T : in std_Logic;
    Clk : in std_logic;  
    Q : out std_logic;
    Q_n :  out std_logic;
    Preset : in std_logic;
    Clear : in std_logic
);

end ff_t;

architecture behavorial of ff_t is
begin

	process ( T, Clk )
		VARIABLE temp: std_logic;
	begin
		if Clk'EVENT AND Clk = '1' then		
			if Clear = '1' then
				temp <= '0';
			elsif Preset = '1' then
				temp <= '1';
			elsif T = '1' then
				temp <= not(temp);
			end if;		
		end if;
		Q <= temp;
		Q_n <= not(temp);
	end process;
end behavorial;
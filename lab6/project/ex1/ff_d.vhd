library ieee;
use ieee.std_logic_1164.all;

entity ff_d is 
	port (
		D, Clk, Preset, Clear: in std_logic;
		Q, Q_n: out std_logic
	);
end ff_d;

architecture structure of ff_d is 
begin 
	process(Clk)
	begin
		IF Clk'EVENT AND Clk = '1' THEN
			IF Clear = '1' then
				Q <= '0';
				Q_n <= '1';
			ELSIF Preset = '1' then
				Q <= '1';
				Q_n <= '0';			
			ELSE 
				Q <= D;
				Q_n <= not D;
			END IF;
		END IF;
	end process;
end structure;
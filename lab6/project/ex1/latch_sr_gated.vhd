library ieee;
use ieee.std_logic_1164.all;

entity latch_sr_gated is 
	port (
		S, R, Clk: in std_logic;
		Q, Q_n: out std_logic
	);
end latch_sr_gated;

architecture structure of latch_sr_gated is 
begin
	process(S, R, Clk)
	begin
		if Clk = '1' then
			if S = '1' and R = '0' then
				Q <= '1';
				Q_n <= '0';
			elsif S = '0' and R = '1' then
				Q <= '0';
				Q_n <= '1';
			end if;
		end if;
	end process;
end structure;
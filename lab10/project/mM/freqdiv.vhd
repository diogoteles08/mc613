library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity freqdiv is
	generic (DIV : natural := 2);
	port (
		clk : in std_logic;
		reset : in std_logic;
		clk_out : out std_logic
	);
end freqdiv;

architecture behavior of freqdiv is
	signal count : natural range 0 to DIV-1;
	signal tmpclk : std_logic;
	
begin
	process(reset, clk)
	begin
		if reset = '1' then
			count <= 0;
			tmpclk <= '0';
		elsif clk'event and clk = '0' then
			count <= count + 1;
			if count = DIV-1 then
				count <= 0;
				tmpclk <= not tmpclk; 
			end if;
		end if;
	end process;
	
	clk_out <= tmpclk;
end behavior;
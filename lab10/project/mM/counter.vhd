library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity counter is
	generic (
		nmax : natural := 128
	);
	port(	
		clk : in std_logic;
		reset : in std_logic;
		recount : in std_logic;
		encount : in std_logic;
		n : out natural range 0 to nmax;
		onmax : out std_logic
    );
end counter;

architecture a_counter of counter is
	signal nn : natural range 0 to nmax;
begin

	process (clk, reset)		
	begin
		if reset = '1' then
			nn <= 0;
		elsif clk'event and clk = '1' then
			if recount = '1' then
				nn <= 0;
			elsif encount = '1' then
				nn <= nn + 1;
			end if;
		end if;
	end process;
	
	onmax <= '1' when nn = nmax else '0';
	n <= nn;

end a_counter;
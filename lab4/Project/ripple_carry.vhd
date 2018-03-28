library ieee;
use ieee.std_logic_1164.all;

entity ripple_carry is
  generic (
    N : integer := 4
  );
  port (
    x,y : in std_logic_vector(N-1 downto 0);
    r : out std_logic_vector(N-1 downto 0);
    cin : in std_logic;
    cout : out std_logic;
    overflow : out std_logic
  );
end ripple_carry;

architecture rtl of ripple_carry is
	component full_adder port (
		x, y : in std_logic;
		r : out std_logic;
		cin : in std_logic;
		cout : out std_logic
	);
	end component;
	signal c: std_logic_vector(N downto 0);
begin
	c(0) <= cin;

	G1: for i in 0 to N-1 generate
		adder: full_adder port map (
			x(i), y(i), r(i), c(i), c(i+1)
		);
	end generate;
		
	cout <= c(N);
	overflow <= c(N) xor c(N-1);						
end rtl;

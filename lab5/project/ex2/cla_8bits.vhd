-- brief : lab05 - question 2

library ieee;
use ieee.std_logic_1164.all;

entity cla_8bits is
  port(
    x    : in  std_logic_vector(7 downto 0);
    y    : in  std_logic_vector(7 downto 0);
    cin  : in  std_logic;
    sum  : out std_logic_vector(7 downto 0);
    cout : out std_logic
  );
end cla_8bits;

architecture rtl of cla_8bits is
	component adder 
	port (
		x, y : in std_logic;
		r : out std_logic;
		cin : in std_logic
	);
	end component;
	
	signal c: std_logic_vector(8 downto 0);
	signal g: std_logic_vector(7 downto 0);
	signal p: std_logic_vector(7 downto 0);
begin
  
  inicializePG: for i in 0 to 7 generate		
		g(i) <= x(i) and y(i);
		p(i) <= x(i) or y(i);
	end generate inicializePG;
  
   c(0) <= cin; 
	
	calcCi: for i in 0 to 7 generate
		c(i+1) <= g(i) or (c(i) and p(i));
	end generate calcCi;
	
	add: for i in 0 to 7 generate
		adde: adder port map (
			x => x(i),
			y => y(i),
			r => sum(i),
			cin => c(i)			
		);
	end generate;

	cout <= c(8);  
end rtl;


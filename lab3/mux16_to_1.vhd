library ieee;
use ieee.std_logic_1164.all;

entity mux16_to_1 is
  port(data : in std_logic_vector(15 downto 0);
       sel : in std_logic_vector(3 downto 0);
       output : out std_logic);
end mux16_to_1;

architecture rtl of mux16_to_1 is
	component mux4_to_1 
		port(d3, d2, d1, d0 : in std_logic;
       sel : in std_logic_vector(1 downto 0);
       output : out std_logic);
	end component;
	
	signal aux: std_logic_vector(3 downto 0);
	signal sel1_0: std_logic_vector(1 downto 0);
	signal sel3_2: std_logic_vector(1 downto 0);
	
begin
	sel1_0 <= sel(1) & sel(0);
	sel3_2 <= sel(3) & sel(2);
  
	mux0: mux4_to_1 port map (data(3), data(2), data(1), data(0), sel1_0, aux(0));
	mux1: mux4_to_1 port map (data(7), data(6), data(5), data(4), sel1_0, aux(1));
	mux2: mux4_to_1 port map (data(11), data(10), data(9), data(8), sel1_0, aux(2));
	mux3: mux4_to_1 port map (data(15), data(14), data(13), data(12), sel1_0, aux(3));
    
	final_mux: mux4_to_1 port map (aux(3), aux(2), aux(1), aux(0), sel3_2, output);
end rtl;


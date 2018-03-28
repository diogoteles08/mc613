library ieee;
use ieee.std_logic_1164.all;

entity ripple_carry_board is
  port (
    SW : in std_logic_vector(7 downto 0);
    HEX4 : out std_logic_vector(6 downto 0);
    HEX2 : out std_logic_vector(6 downto 0);
    HEX0 : out std_logic_vector(6 downto 0);
    LEDR : out std_logic_vector(0 downto 0)
    );
end ripple_carry_board;

architecture rtl of ripple_carry_board is
	component ripple_carry
		generic (
			N: integer := 4
		);
		port (
			x,y: in std_logic_vector(N-1 downto 0);
			r: out std_logic_vector(N-1 downto 0);
			cin: in std_logic;
			cout: out std_logic;
			overflow: out std_logic
		);
	end component;
	
	component bin2hex 
		port (
			SW: in std_logic_vector(3 downto 0);
			HEX0: out std_logic_vector(6 downto 0)
		);
	end component;
	
	signal aux_x, aux_y, aux_r: std_logic_vector(3 downto 0);
begin
	aux_x <= SW(7)&SW(6)&SW(5)&SW(4);
	aux_y <= SW(3)&SW(2)&SW(1)&SW(0);	
	
	ripple: ripple_carry port map (
		aux_x, aux_y, aux_r, '0', open, LEDR(0)
	);
	
	conversor1: bin2hex port map (aux_x, HEX4);
	conversor2: bin2hex port map (aux_y, HEX2);
	conversor3: bin2hex port map (aux_r, HEX0);
	
end rtl;

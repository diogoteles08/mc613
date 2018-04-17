library ieee;
use ieee.std_logic_1164.all;

entity shift_register_board_fullsw is
	port (
		LEDR : out std_logic_vector(5 downto 0);
		SW : in std_logic_vector (9 downto 0)
	);
end shift_register_board_fullsw;

architecture structural of shift_register_board_fullsw is
	component shift_register
		generic (N : integer := 6);
			port(
				clk     : in  std_logic;
				mode    : in  std_logic_vector(1 downto 0);
				ser_in  : in  std_logic;
				par_in  : in  std_logic_vector((N - 1) downto 0);
				par_out : out std_logic_vector((N - 1) downto 0)
			);
	end component;
begin

	bla: shift_register port map (
		clk  => SW(9),
		mode => SW(8 downto 7),
		ser_in => SW(6),
		par_in => SW(5 downto 0),
		par_out => LEDR	
	);
end structural;
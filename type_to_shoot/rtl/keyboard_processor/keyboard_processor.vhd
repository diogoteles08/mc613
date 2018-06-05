library ieee;
library work;
use ieee.std_logic_1164.all;
use work.main_pack.all;

entity keyboard_processor is
  port (
		ps2_data	: inout std_logic;
		ps2_clk		:	inout	std_logic;
    clock 		: in std_logic;
		key_on		: out std_logic;
		asc_code	: out char
  );
end keyboard_processor;

architecture rtl of keyboard_processor is

	function to_std_logic(bool: boolean) return std_logic is
	begin
		if bool then
			return ('1');
		else
			return ('0');
		end if;
	end function to_std_logic;

	-- Valor pego do Lab 6
	constant clockfreq: integer := 50000;

	component kbdex_ctrl 
		generic(
			clkfreq : integer
		);
		port (
			ps2_data	:	inout	std_logic;
			ps2_clk		:	inout	std_logic;
			clk				:	in 	std_logic;
			en				:	in 	std_logic;
			resetn		:	in 	std_logic;		
			lights		: in	std_logic_vector(2 downto 0); -- lights(Caps, Nun, Scroll)
			key_on		:	out	std_logic_vector(2 downto 0);
			key_code	:	out	std_logic_vector(47 downto 0)
		);
	end component;
	
	signal key_code: std_logic_vector(47 downto 0);
	signal key_on_aux: std_logic_vector(2 downto 0);
	signal asc_code_aux: char;
begin
	controller: kbdex_ctrl
		generic map (
			clkfreq => clockfreq
		)
		port map (
			ps2_data => ps2_data,
			ps2_clk => ps2_clk,
			clk => clock,
			en => '1',
			resetn => '1',
			lights => "000",
			key_on => key_on_aux,
			key_code => key_code
		);
	
		-- key_on eh ativado quando alguma tecla eh pressionada e
		-- quando essa tecla e uma letra		
		key_on <= key_on_aux(0) and to_std_logic(asc_code_aux /= no_char);
		
		-- Converte o codigo do kbdex_ctrl para asc
		with key_code(7 downto 0) select asc_code_aux <=
			x"41" when x"1C", -- A
			x"42" when x"32", -- B
			x"43" when x"21", -- C
			x"44" when x"23", -- D
			x"45" when x"24", -- E
			x"46" when x"2B", -- F
			x"47" when x"34", -- G
			x"48" when x"33", -- H
			x"49" when x"43", -- I
			x"4A" when x"3B", -- J
			x"4B" when x"42", -- K
			x"4C" when x"4B", -- L
			x"4D" when x"3A", -- M
			x"4E" when x"31", -- N
			x"4F" when x"44", -- O
			x"50" when x"4D", -- P
			x"51" when x"15", -- Q
			x"52" when x"2D", -- R
			x"53" when x"1B", -- S
			x"54" when x"2C", -- T
			x"55" when x"3C", -- U
			x"56" when x"2A", -- V
			x"57" when x"1D", -- W
			x"58" when x"22", -- X
			x"59" when x"35", -- Y
			x"5A" when x"1A", -- Z
			no_char when others;
			
		asc_code <= asc_code_aux;
end rtl;

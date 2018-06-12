library ieee;
library work;
use ieee.std_logic_1164.all;
use work.main_pack.all;

entity keyboard_processor is
  port (
		ps2_dat		: inout std_logic;
		ps2_clk		: inout std_logic;
		clock		: in std_logic;
		has_pressed	: out std_logic;		
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
			ps2_data:	inout	std_logic;
			ps2_clk	:	inout	std_logic;
			clk		:	in 	std_logic;
			en		:	in 	std_logic;
			resetn	:	in 	std_logic;		
			lights	:	in	std_logic_vector(2 downto 0); -- lights(Caps, Nun, Scroll)
			key_on	:	out	std_logic_vector(2 downto 0);
			key_code:	out	std_logic_vector(47 downto 0)
		);
	end component;

	constant not_used_key: std_logic_vector(7 downto 0) := (others => '0');
	
	signal kbdex_key_codes	: std_logic_vector(47 downto 0);
	signal kbdex_key_on		: std_logic_vector(2 downto 0);
	signal key_code				: std_logic_vector(7 downto 0);
	signal key_on					: std_logic;
	signal key_on_aux			: std_logic;
	
	signal asc_code_aux		: char;
	signal n_pressed_keys	: integer := 0;
begin
	controller: kbdex_ctrl
		generic map (
			clkfreq => clockfreq
		)
		port map (
			ps2_data => ps2_dat,
			ps2_clk => ps2_clk,
			clk => clock,
			en => '1',
			resetn => '1',
			lights => "000",
			key_on => kbdex_key_on,
			key_code => kbdex_key_codes
		);		

		process (clock)
		begin
			if clock'event and clock = '1' then
				n_pressed_keys <= 0;
				key_on_aux <= '0';

				-- Decodificador de prioridade para capturar a ultima tecla pressionada
				for i in 0 to 2 loop
					if kbdex_key_on(i) = '1' then
						n_pressed_keys <= i+1;
						key_code <= kbdex_key_codes(16*i+7 downto 16*i);
						if n_pressed_keys < i+1 then
							key_on_aux <= '1';
						end if;
					end if;
				end loop;
			end if;
		end process;
	
		-- key_on eh ativado quando alguma tecla eh pressionada e
		-- quando essa tecla e uma letra
		has_pressed <= key_on_aux and to_std_logic(asc_code_aux /= not_used_key);
		
		-- Converte o codigo do kbdex_ctrl para asc
		with key_code select asc_code_aux <=
			asc_A			when x"1C", -- A
			asc_B			when x"32", -- B
			asc_C			when x"21", -- C
			asc_D			when x"23", -- D
			asc_E			when x"24", -- E
			asc_F			when x"2B", -- F
			asc_G			when x"34", -- G
			asc_H			when x"33", -- H
			asc_I			when x"43", -- I
			asc_J			when x"3B", -- J
			asc_K			when x"42", -- K
			asc_L			when x"4B", -- L
			asc_M			when x"3A", -- M
			asc_N			when x"31", -- N
			asc_O			when x"44", -- O
			asc_P			when x"4D", -- P
			asc_Q			when x"15", -- Q
			asc_R			when x"2D", -- R
			asc_S			when x"1B", -- S
			asc_T			when x"2C", -- T
			asc_U			when x"3C", -- U
			asc_V			when x"2A", -- V
			asc_W			when x"1D", -- W
			asc_X			when x"22", -- X
			asc_Y			when x"35", -- Y
			asc_Z			when x"1A", -- Z
			asc_enter		when x"5A",
			asc_escape		when x"76",
			asc_space		when x"29",
			not_used_key	when others;
			
		asc_code <= asc_code_aux;
end rtl;

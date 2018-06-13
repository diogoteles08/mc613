library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.main_pack.all;

entity type_proc is
  port (
    CLOCK_50 : in std_logic;
    KEY		 : in std_logic_vector(2 downto 0);
    PS2_DAT : inout STD_LOGIC;
    PS2_CLK : inout STD_LOGIC;
		VGA_R, VGA_G, VGA_B       : out std_logic_vector(7 downto 0);
    VGA_HS, VGA_VS            : out std_logic;
    VGA_BLANK_N, VGA_SYNC_N   : out std_logic;
    VGA_CLK                   : out std_logic;
		LEDR											: out std_logic_vector(9 downto 0);
		HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 : out std_logic_vector(6 downto 0)	
  );
end type_proc;

architecture rtl of type_proc is
	
	component bin2dec is
		port (
			SW: in std_logic_vector(3 downto 0);
			HEX0: out std_logic_vector(6 downto 0)
		);
	end component;

	component word_bank		
		port (
			reset							: in std_logic;
			game_over					: in std_logic;
			clock							: in std_logic;
			kill_word 				: in std_logic;
			word_to_kill_index: in integer;
			insert_new_word		: in std_logic;
			new_word					: in word;
			words							: out word_table;
			num_words					: out integer
		);
	end component;

	component word_gen
		port (
			reset				: in std_logic; -- Active low
			get_word		: in std_logic;
			new_word		: out word;
			new_word_size	: out integer
		);
	end component;

	component screen_proc
		port (
			CLOCK_50                : in  std_logic;
			RESET                   : in  std_logic; -- Active low
			START_GAME							: in std_logic;			
			PLAY_AGAIN							: in std_logic;
			INSERT_WORD							: in std_logic;
			NEW_WORD								: in word;
			NEW_WORD_SIZE						: in integer;
			LOCKED_WORD							: in word;
			LOCKED_EVENT						: in std_logic;
			LETTER_HITS							: in integer;
			WORD_DESTROYED					: in std_logic;			
			VGA_R, VGA_G, VGA_B     : out std_logic_vector(7 downto 0);
			VGA_HS, VGA_VS          : out std_logic;
			VGA_BLANK_N, VGA_SYNC_N	: out std_logic;
			VGA_CLK                 : out std_logic;
			VELOCIDADE								: out integer;
			TIMER_P									: out std_logic;
			GAME_OVER								: out std_logic;
			LEDR										: out std_logic_vector(9 downto 0)
		);
	end component;

	component keyboard_processor
		port (
			ps2_dat	: inout std_logic;
			ps2_clk		:	inout	std_logic;
			clock 		: in std_logic;			
			new_key_pressed		: out std_logic;
			asc_code	: out char			
		);
	end component;	

	signal locked_word_index: integer;
	signal locked_word: word;
	signal locked_event: std_logic;
	
	signal current_letter_index_sig: integer;

	signal get_new_word: std_logic;
	signal new_word: word;
	signal new_word_size: integer;

	signal active_words: word_table;
	signal num_active_words: integer;	

	signal letter_miss: std_logic; -- Internal signal
	signal letter_hit: std_logic; -- Internal signal	
	
	signal digit0: std_logic_vector(3 downto 0);
	signal digit1: std_logic_vector(3 downto 0);
	signal digit2: std_logic_vector(3 downto 0);
	signal digit3: std_logic_vector(3 downto 0);
	signal digit4: std_logic_vector(3 downto 0);
	
	signal score : integer := 0;
	signal kill_word: std_logic;

	signal new_key_pressed: std_logic;
	signal char_pressed: char;
	signal digit5 : std_logic_vector(3 downto 0); 

	signal current_stage: integer;
	signal start_game: std_logic;	
	signal game_over: std_logic;
	signal play_again: std_logic;
	
	signal velocidade : integer;
	signal reset: std_logic;
	
	-- Sinais para um contador utilizado para atrasar a atualização da
  -- posição da bola, a fim de evitar que a animação fique excessivamente
  -- veloz. Aqui utilizamos um contador de 0 a 1250000, de modo que quando
  -- alimentado com um clock de 50MHz, ele demore 25ms (40fps) para contar até o final.
	signal timer : std_logic;        -- vale '1' quando o contador chegar ao fim
	
	-- State machine signals
	type state_t is (
		BEGIN_GAME,
		LOCKED,
		FREE,
		GAME_LOST
	);
	signal state: state_t := BEGIN_GAME;

	signal r_begin : std_logic := '0';
	signal r_locked : std_logic := '0';
	signal r_free : std_logic := '0';
	signal r_hit : std_logic := '0';
	signal r_miss : std_logic := '0';
	signal r_lost : std_logic := '0';
begin
	
	-- Leds for testing
	LEDR(0) <= new_key_pressed;
	LEDR(1) <= letter_hit;
	LEDR(2) <= letter_miss;
	LEDR(3) <= kill_word;
	LEDR(4) <= game_over;
	LEDR(5) <= get_new_word;
	LEDR(6) <= '1' when num_active_words = max_words else '0';
	
	with state select LEDR(9 downto 7) <= 
		"111" when BEGIN_GAME,
		"001" when LOCKED,
		"010" when FREE,
		"000" when GAME_LOST;

	reset <= KEY(0); -- Active low	

	velocidade_hex : bin2dec
		port map (
			SW 				=> digit5,
			HEX0				=> HEX5
		);
		
	un_hex : bin2dec
		port map (
			SW 				=> digit4,
			HEX0				=> HEX0
		);
	dez_hex : bin2dec
		port map (
			SW 				=> digit3,
			HEX0				=> HEX1
		);
	cen_hex : bin2dec
		port map (
			SW 				=> digit2,
			HEX0				=> HEX2
		);
	mil_hex : bin2dec
		port map (
			SW 				=> digit1,
			HEX0				=> HEX3
		);
	dezmil_hex : bin2dec
		port map (
			SW 				=> digit0,
			HEX0				=> HEX4
		);
		
	bank: word_bank
		port map (
			reset								=> reset,
			game_over					  => game_over,
			clock								=> CLOCK_50,
			kill_word 					=> kill_word,
			word_to_kill_index 	=> locked_word_index,
			insert_new_word			=> get_new_word,
			new_word						=> new_word,
			words 							=> active_words,
			num_words 					=> num_active_words
		);

	generator: word_gen
		port map (
			reset					=> reset, -- Active low
			get_word			=> get_new_word,
			new_word			=> new_word,
			new_word_size	=> new_word_size
		);

	keyboard: keyboard_processor
		port map (
			ps2_dat 	=> PS2_DAT,
			ps2_clk 	=> PS2_CLk,
			clock		=> CLOCK_50,			
			new_key_pressed	=> new_key_pressed,			
			asc_code	=> char_pressed
		);

	screen_processor: screen_proc
		port map (
			CLOCK_50				=> CLOCK_50,
			RESET					=> reset, -- Active low
			START_GAME			=> start_game,			
			PLAY_AGAIN			=> play_again,
			INSERT_WORD			=> get_new_word,
			NEW_WORD				=> new_word,
			NEW_WORD_SIZE		=> new_word_size,
			LOCKED_WORD 		=> locked_word,
			LOCKED_EVENT		=> locked_event,
			LETTER_HITS  		=> current_letter_index_sig,
			WORD_DESTROYED	=> kill_word,			
			VGA_R						=> VGA_R,
			VGA_G						=> VGA_G,
			VGA_B						=> VGA_B,
			VGA_HS					=> VGA_HS,
			VGA_VS					=> VGA_VS,
			VGA_BLANK_N			=> VGA_BLANK_N,
			VGA_SYNC_N			=> VGA_SYNC_N,
			VGA_CLK					=> VGA_CLK,
			TIMER_P					=> timer,
			VELOCIDADE				=> velocidade,
			GAME_OVER				=> game_over,
			LEDR						=> open
		);
			

		process (CLOCK_50)
		begin
		
			if CLOCK_50'event and CLOCK_50 = '1' then
				if letter_hit = '1' then
					-- Conta acerto
					score <= score + 1;
				elsif letter_miss = '1' then
					-- Conta erro
					if score > 0  then
						score <= score - 1;
					end if;
				elsif reset = '0' or game_over = '1' then
						score <= 0;
				end if;
			end if;
		end process;	
		
		digit0 <= std_logic_vector(to_unsigned(score / 10000, digit0'length));
		digit1 <= std_logic_vector(to_unsigned((score / 1000) mod 10, digit1'length));
		digit2 <= std_logic_vector(to_unsigned((score / 100) mod 10, digit2'length));
		digit3 <= std_logic_vector(to_unsigned((score / 10) mod 10, digit3'length));
		digit4 <= std_logic_vector(to_unsigned(score mod 10, digit4'length));
		digit5 <= std_logic_vector(to_unsigned(velocidade, digit5'length));				
		
		process (CLOCK_50)
			variable counter: integer := 0;
		begin
			if CLOCK_50'event and CLOCK_50 = '1' then
			
				-- Verifica se nao estamos num estado estatico
				if state /= BEGIN_GAME AND state /= GAME_LOST then
					get_new_word <= '0';
					if timer = '1' then
						-- TODO: Administrate generation of new words
						-- Just need to deal with get_new_word
						if counter /= 20 then
							counter := counter + 1;
						else
							counter := 0;
							if num_active_words /= max_words then
								get_new_word <= '1';
							end if;
						end if;
					end if;
				end if;										
				
			end if;			
		end process;

		-- MAQUINA DE ESTADOS
		process (CLOCK_50)
			variable current_letter_index: integer;
			variable found_word: std_logic;
		begin		
			if CLOCK_50'event and CLOCK_50 = '1' then								
				if reset = '0' then
					-- Reset game
					state <= BEGIN_GAME;					
					start_game <= '0';
					play_again <= '0';
					letter_miss <= '0';
					letter_hit <= '0';
					kill_word <= '0';					
					current_letter_index := 0;

				elsif game_over = '1' and state /= GAME_LOST then
					-- It can get here from any state
					state <= GAME_LOST;					
					start_game <= '0';
					play_again <= '0';
					letter_miss <= '0';
					letter_hit <= '0';
					kill_word <= '0';					
					current_letter_index := 0;
				else										
					-- Zera os sinais
					letter_hit <= '0';
					letter_miss <= '0';
					kill_word <= '0';
					start_game <= '0';
					play_again <= '0';														
					locked_event <= '0';

					case state is
						when BEGIN_GAME =>														
							if new_key_pressed = '1' and char_pressed = asc_enter then
								-- User pressed enter and game will begin
								state <= FREE;
								start_game <= '1';
							end if;
							
						when FREE =>							
							if new_key_pressed = '1' then
								state <= FREE;
								
								-- Procura pela palavra comecando com a letra digitada
								-- Similar a um decodificador de prioridade, os indices menores
								-- tem maior prioridades
								found_word := '0';
								for i in max_words-1 downto 0 loop
									if i < num_active_words then
										if active_words(i)(7 downto 0) = char_pressed then											
											state <= LOCKED;
											found_word := '1';
											letter_hit <= '1';
											locked_word_index <= i;
											locked_event <= '1';
											locked_word <= active_words(i);
											current_letter_index := 1;
											
											-- Verifica se chegamos no tamanho maximo da palavra
											if max_word_length = 1 then
												kill_word <= '1';
												current_letter_index := 0;
												state <= FREE;																								
											
											-- Verifica se chegamos no fim da palavra
											elsif active_words(i)(15 downto 8) = no_char then											
												kill_word <= '1';
												current_letter_index := 0;
												state <= FREE;												
											end if;
										end if;
									end if;
								end loop;
								
								if found_word = '0' then
									state <= FREE;									
									letter_miss <= '1';
								end if;
							end if;														
							
						when LOCKED =>
							if new_key_pressed = '1' then
								state <= LOCKED;
							
								-- Verifica se o usuario digitou a letra esperada
								if active_words(locked_word_index)((current_letter_index+1)*8 - 1 downto current_letter_index*8) = char_pressed then
									state <= LOCKED;
									letter_hit <= '1';
									current_letter_index := current_letter_index + 1;

									-- Verifica se chegamos no tamanho maximo da palavra
									if current_letter_index = max_word_length then
										kill_word <= '1';
										current_letter_index := 0;
										state <= FREE;										
									
									-- Verifica se chegamos no fim da palavra
									elsif active_words(locked_word_index)((current_letter_index+1)*8 - 1 downto current_letter_index*8) = no_char then
										kill_word <= '1';
										current_letter_index := 0;
										state <= FREE;
									end if;

								else
									state <= LOCKED;									
									letter_miss <= '1';
								end if;
							end if;
							
						when GAME_LOST =>
							if new_key_pressed = '1' and char_pressed = asc_enter then
								-- Player wants to play again
								state <= BEGIN_GAME;
								play_again <= '1';
							end if;
							
					end case;								
				end if;				
			end if;
			
			current_letter_index_sig <= current_letter_index;
		end process;
end rtl;

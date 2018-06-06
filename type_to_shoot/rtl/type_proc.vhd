library ieee;
library work;
use ieee.std_logic_1164.all;
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
		LEDR											: out std_logic_vector(9 downto 0)
  );
end type_proc;

architecture rtl of type_proc is

	component word_bank		
		port (
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
			get_word		: in std_logic;
			new_word		: out word;
			new_word_size	: out integer
		);
	end component;

	component vga_ball
		port (
			CLOCK_50                : in  std_logic;
			KEY                     : in  std_logic_vector(2 downto 0);
			START_GAME							: in std_logic;
			STAGE_END								: in std_logic;
			PLAY_AGAIN							: in std_logic;
			INSERT_WORD							: in std_logic;
			NEW_WORD								: in word;
			NEW_WORD_SIZE						: in integer;
			LOCKED_WORD							: in word;
			LOCKED_EVENT						: in std_logic;
			LETTER_HITS							: in integer;
			WORD_DESTROYED					: in std_logic;
			NUM_HITS								: in integer;
			NUM_MISSES							: in integer;
			VGA_R, VGA_G, VGA_B     : out std_logic_vector(7 downto 0);
			VGA_HS, VGA_VS          : out std_logic;
			VGA_BLANK_N, VGA_SYNC_N	: out std_logic;
			VGA_CLK                 : out std_logic;
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
			key_on		: out std_logic;
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

	-- Sinal dizendo se na fase atual nao surgirao novas palavras mais
	signal no_more_words: std_logic; -- Internal signal

	signal letter_miss: std_logic; -- Internal signal
	signal letter_hit: std_logic; -- Internal signal
	
	signal num_hits		: integer;
	signal num_misses	: integer;

	signal kill_word: std_logic;

	signal key_on: std_logic;
	signal char_pressed: char;

	signal current_stage: integer;
	signal start_game: std_logic;
	signal stage_end: std_logic;
	signal game_over: std_logic;
	signal play_again: std_logic;
	
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
		WAIT_RELEASE,		
		GAME_LOST
	);
	signal state: state_t := BEGIN_GAME;
	signal next_state: state_t := BEGIN_GAME;

	signal r_begin : std_logic := '0';
	signal r_locked : std_logic := '0';
	signal r_free : std_logic := '0';
	signal r_hit : std_logic := '0';
	signal r_miss : std_logic := '0';
	signal r_lost : std_logic := '0';
begin
	
--	-- Leds for testing
--	LEDR(0) <= key_on;
--	LEDR(1) <= letter_hit;
--	LEDR(2) <= letter_miss;
--	LEDR(3) <= kill_word;
--	LEDR(4) <= game_over;
--	LEDR(5) <= get_new_word;
--	LEDR(6) <= '1' when num_active_words = max_words else '0';
--	
--	with state select LEDR(9 downto 7) <= 
--		"111" when BEGIN_GAME,
--		"001" when LOCKED,
--		"010" when FREE,
--		"011" when WAIT_RELEASE,		
--		"000" when GAME_LOST;

	bank: word_bank
		port map (
			clock							=> CLOCK_50,
			kill_word 					=> kill_word,
			word_to_kill_index 		=> locked_word_index,
			insert_new_word			=> get_new_word,
			new_word						=> new_word,
			words 						=> active_words,
			num_words 					=> num_active_words
		);

	generator: word_gen
		port map (
			get_word			=> get_new_word,
			new_word			=> new_word,
			new_word_size	=> new_word_size
		);

	keyboard: keyboard_processor
		port map (
			ps2_dat 	=> PS2_DAT,
			ps2_clk 	=> PS2_CLk,
			clock			=> CLOCK_50,
			key_on		=> key_on,
			asc_code	=> char_pressed
		);

	screen_processor: vga_ball
		port map (
			CLOCK_50				=> CLOCK_50,
			KEY							=> KEY,
			START_GAME			=> start_game,
			STAGE_END				=> stage_end,
			PLAY_AGAIN			=> play_again,
			INSERT_WORD			=> get_new_word,
			NEW_WORD				=> new_word,
			NEW_WORD_SIZE		=> new_word_size,
			LOCKED_WORD 		=> locked_word,
			LOCKED_EVENT		=> locked_event,
			LETTER_HITS  		=> current_letter_index,
			WORD_DESTROYED	=> kill_word,
			NUM_HITS				=> num_hits,
			NUM_MISSES			=> num_misses,
			VGA_R						=> VGA_R,
			VGA_G						=> VGA_G,
			VGA_B						=> VGA_B,
			VGA_HS					=> VGA_HS,
			VGA_VS					=> VGA_VS,
			VGA_BLANK_N			=> VGA_BLANK_N,
			VGA_SYNC_N			=> VGA_SYNC_N,
			VGA_CLK					=> VGA_CLK,
			TIMER_P					=> timer,
			GAME_OVER				=> game_over,
			LEDR						=> open
		);
		
		process (letter_hit)
		begin
			if letter_hit = '1' then
				num_hits <= num_hits + 1;
				-- TODO: Update ponctuation					
			end if;
		end process;

		process (letter_miss)
		begin
			if letter_miss = '1' then
				num_misses <= num_misses + 1;
				-- TODO: Update ponctuation
			end if;
		end process;
		
		process (current_stage)
		begin
			-- TODO: Update stage data		
		end process;
		
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
				
				if start_game = '1' then
					current_stage <= 0;
					-- On the new stage we start generating new words
					no_more_words <= '0';
				end if;
			
				if stage_end = '1' then
					current_stage <= current_stage + 1;
					-- On the new stage we start generating new words
					no_more_words <= '0';
				end if;				
			end if;			
		end process;

		-- MAQUINA DE ESTADOS UOU
		process (CLOCK_50)
			variable next_state: state_t;
			variable current_letter_index: integer;
			variable found_word: std_logic;
		begin
			if CLOCK_50'event and CLOCK_50 = '1' then
				if KEY(0) = '0' then
					-- Reset game
					state <= BEGIN_GAME;
					start_game <= '0';
					play_again <= '0';
					letter_miss <= '0';
					letter_hit <= '0';
					kill_word <= '0';
					stage_end <= '0';				

				elsif game_over = '1' and state /= GAME_LOST then
					-- It can get here from any state
					state <= GAME_LOST;
					start_game <= '0';
					play_again <= '0';
					letter_miss <= '0';
					letter_hit <= '0';
					kill_word <= '0';
					stage_end <= '0';

				else										
					case state is

						when WAIT_RELEASE =>
							letter_hit <= '0';
							letter_miss <= '0';
							kill_word <= '0';
							start_game <= '0';
							play_again <= '0';							
							stage_end <= '0';
							locked_event <= '0';
							if key_on = '0' then
								state <= next_state;
							end if;

						when BEGIN_GAME =>														
							if key_on = '1' then
								-- User pressed any key and game will begin
								state <= WAIT_RELEASE;
								next_state := FREE;
								start_game <= '1';								
							end if;						
							
						when FREE =>							
							if key_on = '1' then
								state <= WAIT_RELEASE;
								
								-- Procura pela palavra comecando com a letra digitada
								-- Similar a um decodificador de prioridade, os indices menores
								-- tem maior prioridades
								found_word := '0';
								for i in max_words-1 downto 0 loop
									if i < num_active_words then
										if active_words(i)(7 downto 0) = char_pressed then											
											next_state := LOCKED;
											found_word := '1';
											letter_hit <= '1';
											locked_word_index <= i;
											locked_event <= '1';
											locked_word <= active_words(i);
											current_letter_index := 1;
											
											-- Verifica se chegamos no tamanho maximo da palavra
											if max_word_length = 1 then
												kill_word <= '1';
												next_state := FREE;

												-- Verifica se acabaram as palavras da fase
												if num_active_words = 1 and no_more_words = '1' then
													stage_end <= '1';
												end if;
											
											-- Verifica se chegamos no fim da palavra
											elsif active_words(i)(15 downto 8) = no_char then											
												kill_word <= '1';
												next_state := FREE;

												-- Verifica se acabaram as palavras da fase
												if num_active_words = 1 and no_more_words = '1' then
													stage_end <= '1';
												end if;
											end if;
										end if;
									end if;
								end loop;
								
								if found_word = '0' then
									next_state := FREE;									
									letter_miss <= '1';
								end if;
							end if;														
							
						when LOCKED =>
							if key_on = '1' then
								state <= WAIT_RELEASE;
							
								-- Verifica se o usuario digitou a letra esperada
								if active_words(locked_word_index)((current_letter_index+1)*8 - 1 downto current_letter_index*8) = char_pressed then
									next_state := LOCKED;
									letter_hit <= '1';
									current_letter_index := current_letter_index + 1;

									-- Verifica se chegamos no tamanho maximo da palavra
									if current_letter_index = max_word_length then
										kill_word <= '1';
										next_state := FREE;

										-- Verifica se acabaram as palavras da fase
										if num_active_words = 1 and no_more_words = '1' then
											stage_end <= '1';
										end if;
									
									-- Verifica se chegamos no fim da palavra
									elsif active_words(locked_word_index)((current_letter_index+1)*8 - 1 downto current_letter_index*8) = no_char then
										kill_word <= '1';
										next_state := FREE;

										-- Verifica se acabaram as palavras da fase
										if num_active_words = 1 and no_more_words = '1' then
											stage_end <= '1';
										end if;
									end if;

								else
									next_state := LOCKED;									
									letter_miss <= '1';
								end if;
							end if;
							
						when GAME_LOST =>
							if key_on = '1' then
								state <= WAIT_RELEASE;
								-- Player wants to play again
								play_again <= '1';
								next_state := BEGIN_GAME;
							end if;
							
					end case;								
				end if;				
			end if;
			
			current_letter_index_sig <= current_letter_index;
		end process;

  -- purpose: Avança a FSM para o próximo state
  -- type   : sequential
  -- inputs : CLOCK_50, rstn, next_state
  -- outputs: state
  -- seq_fsm: process (CLOCK_50, rstn)
--  seq_fsm: process (CLOCK_50)
--  begin  -- process seq_fsm    
--    if CLOCK_50'event and CLOCK_50 = '1' then  -- rising clock edge			
--			if key_on <= '0' then
--				state <= next_state;
--			end if;
--    end if;
--  end process seq_fsm;

end rtl;

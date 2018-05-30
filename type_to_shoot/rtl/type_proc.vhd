library ieee;
library work;
use ieee.std_logic_1164.all;
use work.main_pack.all;

entity type_proc is
  port (
    CLOCK_50 : in std_logic;
    PS2_DATA : inout STD_LOGIC;
    PS2_CLK : inout STD_LOGIC;
		VGA_R, VGA_G, VGA_B       : out std_logic_vector(7 downto 0);
    VGA_HS, VGA_VS            : out std_logic;
    VGA_BLANK_N, VGA_SYNC_N   : out std_logic;
    VGA_CLK                   : out std_logic
  );
end type_proc;

architecture rtl of type_proc is

	component word_bank
		port (
			kill_word 		: in std_logic;
			word_to_kill	: in integer;
			new_word			: in word;
			words					: out word_table;
			num_words			: out integer
		);
	end component;

	component vga_ball
		port (
			CLOCK_50                : in  std_logic;
			TIMER										: in std_logic;
			KEY                     : in  std_logic;
			START_GAME							: in std_logic;
			STAGE_END								: in std_logic;
			PLAY_AGAIN							: in std_logic;
			NEW_WORD								: in word;
			LOCKED_WORD							: in word;
			LETTER_HIT							: in std_logic;
			WORD_DESTROYED					: in std_logic;
			VGA_R, VGA_G, VGA_B     : out std_logic_vector(7 downto 0);
			VGA_HS, VGA_VS          : out std_logic;
			VGA_BLANK_N, VGA_SYNC_N	: out std_logic;
			VGA_CLK                 : out std_logic;
			GAME_OVER								: out std_logic
		);
	end component;

	component keyboard_processor
		port (
			ps2_data	: inout std_logic;
			ps2_clk		:	inout	std_logic;
			clock 		: in std_logic;
			key_on		: out std_logic;
			asc_code	: out integer
		);
	end component;	

	signal locked_word_id: integer;
	signal locked_word: word;
	signal word_processed: word;
	signal new_word: word;

	signal active_words: word_table;
	signal num_active_words: integer;

	signal letter_hit: std_logic;
	signal kill_word: std_logic;

	signal key_on: std_logic;
	signal char_pressed: integer;

	signal start_game: std_logic;
	signal stage: integer;
	signal stage_end: std_logic;
	signal game_over: std_logic;
	signal play_again: std_logic;
	
	-- Sinais para um contador utilizado para atrasar a atualização da
  -- posição da bola, a fim de evitar que a animação fique excessivamente
  -- veloz. Aqui utilizamos um contador de 0 a 1250000, de modo que quando
  -- alimentado com um clock de 50MHz, ele demore 25ms (40fps) para contar até o final.
	signal contador : integer range 0 to 1250000 - 1;  -- contador
  signal timer : std_logic;        -- vale '1' quando o contador chegar ao fim
	
	-- State machine signals
	signal state: state_t;
	signal next_state: state_t;
	type state_t is (
		BEGIN_GAME,
		HIT,
		MISS,
		LOCKED,
		FREE
	);

begin
	bank: word_bank
		port map (
			kill_word 		=> kill_word,
			word_to_kill 	=> locked_word_id,
			new_word			=> new_word,
			words 				=> active_words,
			num_words 		=> num_active_words
		);

	keyboard: keyboard_processor
		port map (
			ps2_data 	=> PS2_DATA,
			ps2_clk 	=> PS2_CLk,
			clock			=> CLOCK_50,
			key_on		=> key_on,
			asc_code	=> char_pressed
		);

	screen_processor: vga_ball
		port map (
			CLOCK_50				=> CLOCK_50,
			TIMER						=> timer,
			KEY							=> '1',
			START_GAME			=> start_game,
			STAGE_END				=> stage_end,
			PLAY_AGAIN			=> play_again,
			NEW_WORD				=> new_word,
			LOCKED_WORD 		=> locked_word,
			LETTER_HIT  		=> letter_hit,
			WORD_DESTROYED	=> kill_word,
			VGA_R						=> VGA_R,
			VGA_G						=> VGA_G,
			VGA_B						=> VGA_B,
			VGA_HS					=> VGA_HS,
			VGA_VS					=> VGA_VS,
			VGA_BLANK_N			=> VGA_BLANK_N,
			VGA_SYNC_N			=> VGA_SYNC_N,
			VGA_CLK					=> VGA_CLK,
			GAME_OVER				=> game_over
		);
		
		process (key_on)
		begin
			case state is
				when BEGIN_GAME =>
					if key_on = '1' then
						next_state <= FREE;
					else
						next_state <= BEGIN_GAME;
					end if;
					start_game <= '1';					
				when FREE =>
					for i in 0 to num_active_words-1 loop
						if active_words(i)(0) = asc_code then
						
					end loop;
					start_game <= '0';
				when LOCKED =>
					letter_hit <= '0';
					kill_word <= '0';
					stage_end <= '0';
					game_over <= '0';
					play_again <= '0';
				
				when HIT =>
					
				when MISS =>						
			end case;
		end process;

--	state_machine: process (state, timer, key_on)
--	begin
--		case state is
--			when BEGIN_GAME =>
--				if key_on = '1' then
--					next_state <= FREE;
--				else
--					next_state <= BEGIN_GAME;
--				end if;
--				start_game <= '1';
--				letter_hit <= '0';
--				kill_word <= '0';
--				stage_end <= '0';
--				game_over <= '0';
--				play_again <= '0';
--			when FREE =>
--				start_game <= '0';
--			when LOCKED =>
--				letter_hit <= '0';
--				kill_word <= '0';
--				stage_end <= '0';
--				game_over <= '0';
--				play_again <= '0';
--			
--			when HIT =>
--				
--			when MISS =>						
--		end case;
--	end process state_machine;
--
--	-- purpose: Avança a FSM para o próximo estado
--  -- type   : sequential
--  -- inputs : CLOCK_50, rstn, proximo_estado
--  -- outputs: estado
----  seq_fsm: process (CLOCK_50, rstn)
--	seq_fsm: process (CLOCK_50)
--  begin  -- process seq_fsm
----    if rstn = '0' then                  -- asynchronous reset (active low)
----      estado <= inicio;
--    if CLOCK_50'event and CLOCK_50 = '1' then  -- rising clock edge
--      state <= next_state;
--    end if;
--  end process seq_fsm;

	-----------------------------------------------------------------------------
  -- Processos do contador utilizado para atrasar a animação (evitar
  -- que a atualização de quadros fique excessivamente veloz).
  -----------------------------------------------------------------------------
  -- purpose: Incrementa o contador a cada ciclo de clock
  -- type   : sequential
  -- inputs : CLOCK_50, timer_rstn
  -- outputs: contador, timer
--  p_contador: process (CLOCK_50, timer_rstn)
	p_contador: process (CLOCK_50)
  begin  -- process p_contador
--    if timer_rstn = '0' then            -- asynchronous reset (active low)
--      contador <= 0;
    if CLOCK_50'event and CLOCK_50 = '1' then  -- rising clock edge
--      if timer_enable = '1' then       
        if contador = 1250000 - 1 then
          contador <= 0;
        else
          contador <=  contador + 1;        
        end if;
--      end if;
    end if;
  end process p_contador;

  -- purpose: Calcula o sinal "timer" que indica quando o contador chegou ao tempo
  --          final
  -- type   : combinational
  -- inputs : contador
  -- outputs: timer
  p_timer: process (contador)
  begin  -- process p_timer
    if contador = 1250000 - 1 then
      timer <= '1';
    else
      timer <= '0';
    end if;
  end process p_timer;
		
end rtl;
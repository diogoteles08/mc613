-------------------------------------------------------------------------------
-- Title      : exemplo
-- Project    : 
-------------------------------------------------------------------------------
-- File       : exemplo.vhd
-- Author     : Rafael Auler
-- Company    : 
-- Created    : 2010-03-26
-- Last update: 2018-04-05
-- Platform   : 
-- Standard   : VHDL'2008
-------------------------------------------------------------------------------
-- Description: Fornece um exemplo de uso do módulo VGACON para a disciplina
--              MC613.
--              Este módulo possui uma máquina de estados simples que se ocupa
--              de escrever na memória de vídeo (atualizar o quadro atual) e,
--              em seguida, de atualizar a posição de uma "bola" que percorre
--              toda a tela, quicando pelos cantos.
-------------------------------------------------------------------------------
-- Copyright (c) 2010 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2010-03-26  1.0      Rafael Auler    Created
-- 2018-04-05  1.1      IBFelzmann      Adapted for DE1-SoC
-------------------------------------------------------------------------------

library ieee;
library work;
use work.main_pack.all;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE ieee.numeric_std.ALL;


entity vga_ball is
	generic (
		NUM_LINE : integer := 480;
		NUM_COL : integer := 640;
		WORD_LINE : integer := 16;
		WORD_COL : integer := 8
	);
  port (    
    CLOCK_50                	: in  std_logic;
    RESET                     	: in  std_logic;
    START_GAME		        : in  std_logic;
    STAGE_END		        : in  std_logic;
    PLAY_AGAIN		        : in  std_logic;
		INSERT_WORD							: in std_logic;
    NEW_WORD		        : in  word;
    NEW_WORD_SIZE		: in  integer;
    LOCKED_WORD		        : in  word;
		LOCKED_EVENT					: in std_logic;
    LETTER_HITS		        : in  integer;
    WORD_DESTROYED		: in  std_logic;
		NUM_HITS								: in integer;
		NUM_MISSES							: in integer;
    VGA_R, VGA_G, VGA_B     	: out std_logic_vector(7 downto 0);
    VGA_HS, VGA_VS          	: out std_logic;
    VGA_BLANK_N, VGA_SYNC_N	: out std_logic;
    VGA_CLK                 	: out std_logic;
	 LEDR								: out std_logic_vector(9 downto 0);
	 VELOCIDADE						: out integer;
    TIMER_P			: out std_logic;
    GAME_OVER		        : out std_logic
    );
end vga_ball;

architecture comportamento of vga_ball is
  
   type splash is array (0 to NUM_LINE * NUM_COL - 1) of std_logic_vector(2 downto 0);
	signal tela_inicial: splash;
	attribute ram_init_file : string;
	attribute ram_init_file of tela_inicial : signal is "start_1.mif";
	signal tela_over : splash;
	attribute ram_init_file of tela_over : signal is "over.mif";
	
  signal rstn : std_logic;              -- reset active low para nossos
                                        -- circuitos sequenciais.
  -- Interface com a memória de vídeo do controlador

  signal we : std_logic;                        -- write enable ('1' p/ escrita)
  signal addr : integer range 0 to NUM_LINE * NUM_COL - 1;       -- endereco mem. vga
  signal pixel : std_logic_vector(2 downto 0);  -- valor de cor do pixel

  -- Sinais dos contadores de linhas e colunas utilizados para percorrer
  -- as posições da memória de vídeo (pixels) no momento de construir um quadro.
  
  signal line : integer range 0 to NUM_LINE-1;  -- linha atual
  signal col : integer range 0 to NUM_COL-1;  -- coluna atual

  signal col_rstn : std_logic;          -- reset do contador de colunas
  signal col_enable : std_logic;        -- enable do contador de colunas
  signal line_rstn : std_logic;          -- reset do contador de linhas
  signal line_enable : std_logic;        -- enable do contador de linhas
  signal fim_escrita : std_logic;       -- '1' quando um quadro terminou de ser
                                        -- escrito na memória de vídeo
  signal atualiza_pos_y : std_logic;    -- se '1' = as palavras mudam sua pos. no eixo y

  -- Especificação dos tipos e sinais da máquina de estados de controle
  type estado_t is (show_inicio, inicio, constroi_quadro, desce_palavras, show_over, wait_action);
  signal estado: estado_t := inicio;

  -- Sinais para um contador utilizado para atrasar a atualização da
  -- posição da bola, a fim de evitar que a animação fique excessivamente
  -- veloz. Aqui utilizamos um contador de 0 a 1250000, de modo que quando
  -- alimentado com um clock de 50MHz, ele demore 25ms (40fps) para contar até o final.
  
  signal contador : integer range 0 to 2500000 - 1;  -- contador
  signal timer : std_logic;        -- vale '1' quando o contador chegar ao fim
  signal timer_rstn, timer_enable : std_logic;
  
  signal sync, blank: std_logic;

  signal cor_atual : std_logic_vector(2 downto 0) := "001";
  signal inic_screen : std_logic := '0';
  signal over_screen : std_logic := '0';
  signal local_game_over : std_logic := '0';
  
  signal my_play : std_logic := '0';
  signal my_start : std_logic := '0';
  constant col_0 : integer := 5;
  constant col_1 : integer := 110;
  constant col_2 : integer := 215;
  constant col_3 : integer := 320;
  constant col_4 : integer := 425;
  constant col_5 : integer := 530;

  constant stage_0 : integer := 1;
  constant stage_1 : integer := 1;
  constant stage_2 : integer := 2;
  constant stage_3 : integer := 3;
  constant stage_4 : integer := 5;
  constant stage_5 : integer := 8;
  constant stage_6 : integer := 13;
  constant stage_7 : integer := 21;
  constant stage_8 : integer := 34;
  constant stage_9 : integer := 55;
  
  type stage_integer is array (0 to 9) of integer;
  signal words_in_stage : stage_integer := (stage_0, stage_1, stage_2, stage_3, stage_4, stage_5, stage_6, stage_7, stage_8, stage_9);
  signal contador_in_stage : stage_integer := (2500000 - 1, 2000000 - 1, 1500000 - 1, 1250000 - 1, 1000000 - 1, 900000 - 1, 800000 - 1, 750000 - 1, 700000 - 1, 650000 - 1);
  signal stage_atual : integer := 0;
  signal words_destroyed : integer := 0;
  
  signal line_bases : array5 := (10, 10, 10, 10, 10);
  signal col_bases : array5 := (col_0, col_1, col_2, col_3, col_4);
  
  signal empty_positions :  array5 := (1, 1, 1, 1, 1);
  signal empty_position :  integer range 0 to max_words;

  signal print_enable : std_logic := '0';
  
  -- comeca alocado em uma coluna que nao existe
  signal indice_locked : integer range 0 to max_words := max_words;
  
  
  type letra_t is array (0 to WORD_COL * WORD_LINE -1) of std_logic;

  type matriz_palavras is array (0 to max_words-1) of word;
  
  signal palavras_size: array5 := (0, 0, 0, 0, 0);
  
  signal palavras : matriz_palavras := (
		no_word,
		no_word,
		no_word,
		no_word,
		no_word);

  type letras_atuais_t is array (0 to max_words-1, 0 to max_word_length-1) of letra_t;

  signal letras_atuais : letras_atuais_t;

  type alfabeto_t is array (0 to 26) of letra_t;
  signal alfa: alfabeto_t := 
  ("00000000000000000001000000111000011011001100011011000110111111101100011011000110110001101100011000000000000000000000000000000000", --'A'
	"00000000000000001111110001100110011001100110011001111100011001100110011001100110011001101111110000000000000000000000000000000000", --'B'
	"00000000000000000011110001100110110000101100000011000000110000001100000011000010011001100011110000000000000000000000000000000000", --'C'
	"00000000000000001111100001101100011001100110011001100110011001100110011001100110011011001111100000000000000000000000000000000000", --'D'
	"00000000000000001111111001100110011000100110100001111000011010000110000001100010011001101111111000000000000000000000000000000000", --'E'
	"00000000000000001111111001100110011000100110100001111000011010000110000001100000011000001111000000000000000000000000000000000000", --'F'
	"00000000000000000011110001100110110000101100000011000000110111101100011011000110011001100011101000000000000000000000000000000000", --'G'
	"00000000000000001100011011000110110001101100011011111110110001101100011011000110110001101100011000000000000000000000000000000000", --'H'
	"00000000000000000011110000011000000110000001100000011000000110000001100000011000000110000011110000000000000000000000000000000000", --'I'
	"00000000000000000001111000001100000011000000110000001100000011001100110011001100110011000111100000000000000000000000000000000000", --'J'
	"00000000000000001110011001100110011001100110110001111000011110000110110001100110011001101110011000000000000000000000000000000000", --'K'
	"00000000000000001111000001100000011000000110000001100000011000000110000001100010011001101111111000000000000000000000000000000000", --'L'
	"00000000000000001100001111100111111111111111111111011011110000111100001111000011110000111100001100000000000000000000000000000000", --'M'
	"00000000000000001100011011100110111101101111111011011110110011101100011011000110110001101100011000000000000000000000000000000000", --'N'
	"00000000000000000111110011000110110001101100011011000110110001101100011011000110110001100111110000000000000000000000000000000000", --'O'
	"00000000000000001111110001100110011001100110011001111100011000000110000001100000011000001111000000000000000000000000000000000000", --'P'
	"00000000000000000111110011000110110001101100011011000110110001101100011011010110110111100111110000001100000011100000000000000000", --'Q'
	"00000000000000001111110001100110011001100110011001111100011011000110011001100110011001101110011000000000000000000000000000000000", --'R'
	"00000000000000000111110011000110110001100110000000111000000011000000011011000110110001100111110000000000000000000000000000000000", --'S'
	"00000000000000001111111111011011100110010001100000011000000110000001100000011000000110000011110000000000000000000000000000000000", --'T'
	"00000000000000001100011011000110110001101100011011000110110001101100011011000110110001100111110000000000000000000000000000000000", --'U'
	"00000000000000001100001111000011110000111100001111000011110000111100001101100110001111000001100000000000000000000000000000000000", --'V'
	"00000000000000001100001111000011110000111100001111000011110110111101101111111111011001100110011000000000000000000000000000000000", --'W'
	"00000000000000001100001111000011011001100011110000011000000110000011110001100110110000111100001100000000000000000000000000000000", --'X'
	"00000000000000001100001111000011110000110110011000111100000110000001100000011000000110000011110000000000000000000000000000000000", --'Y'
	"00000000000000001111111111000011100001100000110000011000001100000110000011000001110000111111111100000000000000000000000000000000", -- 'Z'
	"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"); --' '
	
--  signal letra_A : std_logic_vector(0 to WORD_COL * WORD_LINE - 1 ) := (
--   "00000000000000000001000000111000011011001100011011000110111111101100011011000110110001101100011000000000000000000000000000000000");
--  signal letra_B : std_logic_vector(0 to WORD_COL * WORD_LINE - 1 ) := (  
--   "00000000000000001111110001100110011001100110011001111100011001100110011001100110011001101111110000000000000000000000000000000000");
--  signal letra_C : std_logic_vector(0 to WORD_COL * WORD_LINE - 1 ) := (  
--   "00000000000000000011110001100110110000101100000011000000110000001100000011000010011001100011110000000000000000000000000000000000");
--  signal letra_D : std_logic_vector(0 to WORD_COL * WORD_LINE - 1 ) := (
--   "00000000000000001111100001101100011001100110011001100110011001100110011001100110011011001111100000000000000000000000000000000000");
--  signal letra_E : std_logic_vector(0 to WORD_COL * WORD_LINE - 1 ) := (
--   "00000000000000001111111001100110011000100110100001111000011010000110000001100010011001101111111000000000000000000000000000000000");
--  signal letra_F : std_logic_vector(0 to WORD_COL * WORD_LINE - 1 ) := (
--   "00000000000000001111111001100110011000100110100001111000011010000110000001100000011000001111000000000000000000000000000000000000");
--  signal letra_G : std_logic_vector(0 to WORD_COL * WORD_LINE - 1 ) := (
--   "00000000000000000011110001100110110000101100000011000000110111101100011011000110011001100011101000000000000000000000000000000000");
--  signal letra_H : std_logic_vector(0 to WORD_COL * WORD_LINE - 1 ) := (
--   "00000000000000001100011011000110110001101100011011111110110001101100011011000110110001101100011000000000000000000000000000000000");
--  signal letra_I : std_logic_vector(0 to WORD_COL * WORD_LINE - 1 ) := ( 
--   "00000000000000000011110000011000000110000001100000011000000110000001100000011000000110000011110000000000000000000000000000000000");
--  signal letra_J : std_logic_vector(0 to WORD_COL * WORD_LINE - 1 ) := (
--   "00000000000000000001111000001100000011000000110000001100000011001100110011001100110011000111100000000000000000000000000000000000");
--  signal letra_K : std_logic_vector(0 to WORD_COL * WORD_LINE - 1 ) := ( 
--   "00000000000000001110011001100110011001100110110001111000011110000110110001100110011001101110011000000000000000000000000000000000");
--  signal letra_L : std_logic_vector(0 to WORD_COL * WORD_LINE - 1 ) := (
--   "00000000000000001111000001100000011000000110000001100000011000000110000001100010011001101111111000000000000000000000000000000000");
--  signal letra_M : std_logic_vector(0 to WORD_COL * WORD_LINE - 1 ) := (
--   "00000000000000001100001111100111111111111111111111011011110000111100001111000011110000111100001100000000000000000000000000000000");
--  signal letra_N : std_logic_vector(0 to WORD_COL * WORD_LINE - 1 ) := (
--   "00000000000000001100011011100110111101101111111011011110110011101100011011000110110001101100011000000000000000000000000000000000");
--  signal letra_O : std_logic_vector(0 to WORD_COL * WORD_LINE - 1 ) := ( 
--   "00000000000000000111110011000110110001101100011011000110110001101100011011000110110001100111110000000000000000000000000000000000");
--  signal letra_P : std_logic_vector(0 to WORD_COL * WORD_LINE - 1 ) := (
--   "00000000000000001111110001100110011001100110011001111100011000000110000001100000011000001111000000000000000000000000000000000000");
--  signal letra_Q : std_logic_vector(0 to WORD_COL * WORD_LINE - 1 ) := ( 
--   "00000000000000000111110011000110110001101100011011000110110001101100011011010110110111100111110000001100000011100000000000000000");
--  signal letra_R : std_logic_vector(0 to WORD_COL * WORD_LINE - 1 ) := ( 
--   "00000000000000001111110001100110011001100110011001111100011011000110011001100110011001101110011000000000000000000000000000000000");
--  signal letra_S : std_logic_vector(0 to WORD_COL * WORD_LINE - 1 ) := (  
--   "00000000000000000111110011000110110001100110000000111000000011000000011011000110110001100111110000000000000000000000000000000000");
--  signal letra_T : std_logic_vector(0 to WORD_COL * WORD_LINE - 1 ) := ( 
--   "00000000000000001111111111011011100110010001100000011000000110000001100000011000000110000011110000000000000000000000000000000000");
--  signal letra_U : std_logic_vector(0 to WORD_COL * WORD_LINE - 1 ) := ( 
--   "00000000000000001100011011000110110001101100011011000110110001101100011011000110110001100111110000000000000000000000000000000000");
--  signal letra_V : std_logic_vector(0 to WORD_COL * WORD_LINE - 1 ) := ( 
--   "00000000000000001100001111000011110000111100001111000011110000111100001101100110001111000001100000000000000000000000000000000000");
--  signal letra_W : std_logic_vector(0 to WORD_COL * WORD_LINE - 1 ) := (
--   "00000000000000001100001111000011110000111100001111000011110110111101101111111111011001100110011000000000000000000000000000000000");
--  signal letra_X : std_logic_vector(0 to WORD_COL * WORD_LINE - 1 ) := (
--   "00000000000000001100001111000011011001100011110000011000000110000011110001100110110000111100001100000000000000000000000000000000");
--  signal letra_Y : std_logic_vector(0 to WORD_COL * WORD_LINE - 1 ) := ( 
--   "00000000000000001100001111000011110000110110011000111100000110000001100000011000000110000011110000000000000000000000000000000000");
--  signal letra_Z : std_logic_vector(0 to WORD_COL * WORD_LINE - 1 ) := (
--   "00000000000000001111111111000011100001100000110000011000001100000110000011000001110000111111111100000000000000000000000000000000");
	
--  signal letra_atual : std_logic_vector(0 to WORD_COL * WORD_LINE - 1 ) := (
--	"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000");
begin  -- comportamento


  -- Aqui instanciamos o controlador de vídeo, NUM_COL colunas por NUM_LINE linhas
  -- (aspect ratio 4:3). Os sinais que iremos utilizar para comunicar
  -- com a memória de vídeo (para alterar o brilho dos pixels) são
  -- write_clk (nosso clock), write_enable ('1' quando queremos escrever
  -- o valor de um pixel), write_addr (endereço do pixel a escrever)
  -- e data_in (valor do brilho do pixel RGB, 1 bit pra cada componente de cor)
  vga_controller: entity work.vgacon 
	 generic map (
		NUM_HORZ_PIXELS => NUM_COL,
		NUM_VERT_PIXELS => NUM_LINE
	 )
	 port map (
    clk50M       => CLOCK_50,
    rstn         => '1',
    red          => VGA_R,
    green        => VGA_G,
    blue         => VGA_B,
    hsync        => VGA_HS,
    vsync        => VGA_VS,
    write_clk    => CLOCK_50,
    write_enable => we,
    write_addr   => addr,
    data_in      => pixel,
    vga_clk      => VGA_CLK,
    sync         => sync,
    blank        => blank);
	 
    VGA_SYNC_N <= NOT sync;
    VGA_BLANK_N <= NOT blank;

 -- PROCESS PARA BUSCAR UMA POSICAO LIVRE PALAVRA NA MATRIZ DE PALAVRAS
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   -- purpose: 
   -- type   : 
   -- inputs :
   -- outputs: 
procura_indice: process (CLOCK_50)
	variable words_aux : integer;
  begin
		if CLOCK_50'event and CLOCK_50 = '1' then
			if local_game_over = '1' or reset = '0' or estado = inicio then
				stage_atual <= 0;
				words_destroyed <= 0;
				for i in 0 to max_words-1 loop
					palavras(i) <= no_word;
					palavras_size(i) <= 0;
					empty_positions(i) <= 1;
				end loop;
			elsif INSERT_WORD = '1' then
				palavras(empty_position) <= NEW_WORD;
				palavras_size(empty_position) <= NEW_WORD_SIZE;
				empty_positions(empty_position) <= 0;
			elsif WORD_DESTROYED = '1' then
				words_aux := words_destroyed + 1;
					
				if words_aux = words_in_stage(stage_atual) then
				if stage_atual < 9 then
						stage_atual <= stage_atual + 1;
				end if;
					words_destroyed <= 0;
				else
					words_destroyed <= words_destroyed + 1;
				end if;
				
				empty_positions(indice_locked) <= 1;
				palavras(indice_locked) <= no_word;
				palavras_size(indice_locked) <= 0;
			end if;
		end if;
end process procura_indice;

 -- PROCESS PARA BUSCAR UMA POSICAO LIVRE PALAVRA NA MATRIZ DE PALAVRAS
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   -- purpose: 
   -- type   : 
   -- inputs :
   -- outputs: 
procura_empty_position: process (CLOCK_50)
	variable found_position : std_logic;
	variable aux_position : integer;
  begin
		if CLOCK_50'event and CLOCK_50 = '1' then
			found_position := '0';
			for i in 0 to max_words-1 loop
				if empty_positions(i) = 1 then
					found_position := '1';
					aux_position := i;
				end if;
			end loop;
			
			if found_position = '1' then
				empty_position <= aux_position;
			end if;
		end if;
end process procura_empty_position;
 
 
 -- ISSO DAQUI NAO VAI FUNCIONAR PARA PALAVRAS IGUAIS NA TELA
 -- ELE VAI SEMPRE LOCKAR NA PALAVRA MAIS A DIREITA NA TELA
 -- PROCESS PARA VERIFICAR SE ALGUMA PALAVRA FOI DESTRUIDA E QUAL FOI
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
 
 
   -- purpose: 
   -- type   : 
   -- inputs :
   -- outputs: 
procura_indice_locked: process (CLOCK_50)
	variable word_index : integer := max_words;
	variable found_word : std_logic; 
  begin
		if CLOCK_50'event and CLOCK_50 = '1' then
			if LOCKED_EVENT = '1' then
				found_word := '0';
				for i in 0 to max_words-1 loop
					if palavras(i) = LOCKED_WORD then
						word_index := i;
						found_word := '1';
					end if;
				end loop;
				
				if found_word = '1' then
					indice_locked <= word_index;
				end if;
			elsif WORD_DESTROYED = '1' then
				indice_locked <= max_words;
			elsif local_game_over = '1' or reset = '0' then
				indice_locked <= max_words;
			end if;
		end if;
end process procura_indice_locked;

TIMER_P <= timer;
GAME_OVER <= local_game_over;
VELOCIDADE <= stage_atual;
  -----------------------------------------------------------------------------
  -- PROCESS PARA VERIFICAR ONDE ESTAMOS E IMPRIMIR NA TELA
  -----------------------------------------------------------------------------

  -- purpose: 
  -- type   : sequential
  -- inputs :
  -- outputs: 
  pega_linha: process (CLOCK_50)
  begin  -- process conta_coluna
    if CLOCK_50'event and CLOCK_50 = '1' then  -- rising clock edge
		if col_enable = '1' and line_enable = '1' then
			if line >= line_bases(0) and line < line_bases(0) + WORD_LINE and col >= col_bases(0) and col < col_bases(0) + WORD_COL * palavras_size(0) then
				if (col < col_bases(0) + WORD_COL) and palavras_size(0) >= 1 then
													if indice_locked = 0 and LETTER_HITS >= 1 then
															print_enable <= '0';
													else
															print_enable <= letras_atuais(0, 0)((line-line_bases(0)) * WORD_COL + ((col+2) mod WORD_COL));
													end if;
				elsif (col < col_bases(0) + 2*WORD_COL) and palavras_size(0) >= 2 then
                                        if indice_locked = 0 and LETTER_HITS >= 2 then
                                                print_enable <= '0';
                                        else
                                            print_enable <= letras_atuais(0, 1)((line-line_bases(0)) * WORD_COL + ((col+2) mod WORD_COL));
                                         end if;
				elsif (col < col_bases(0) + 3*WORD_COL) and palavras_size(0) >= 3 then
                                        if indice_locked = 0 and LETTER_HITS >= 3 then
                                                print_enable <= '0';
                                        else
                                            print_enable <= letras_atuais(0, 2)((line-line_bases(0)) * WORD_COL + ((col+2) mod WORD_COL));
                                         end if;
				elsif (col < col_bases(0) + 4*WORD_COL) and palavras_size(0) >= 4 then
                                        if indice_locked = 0 and LETTER_HITS >= 4 then
                                                print_enable <= '0';
                                        else
                                            print_enable <= letras_atuais(0, 3)((line-line_bases(0)) * WORD_COL + ((col+2) mod WORD_COL));
													 end if;
				elsif (col < col_bases(0) + 5*WORD_COL) and palavras_size(0) >= 5 then
                                        if indice_locked = 0 and LETTER_HITS >= 5 then
                                                print_enable <= '0';
                                        else
                                            print_enable <= letras_atuais(0, 4)((line-line_bases(0)) * WORD_COL + ((col+2) mod WORD_COL));
                                         end if;
				elsif (col < col_bases(0) + 6*WORD_COL) and palavras_size(0) >= 6 then
                                        if indice_locked = 0 and LETTER_HITS >= 6 then
                                                print_enable <= '0';
                                        else
                                            print_enable <= letras_atuais(0, 5)((line-line_bases(0)) * WORD_COL + ((col+2) mod WORD_COL));
                                         end if;
				elsif (col < col_bases(0) + 7*WORD_COL) and palavras_size(0) >= 7 then
                                        if indice_locked = 0 and LETTER_HITS >= 7 then
                                                print_enable <= '0';
                                        else
                                            print_enable <= letras_atuais(0, 6)((line-line_bases(0)) * WORD_COL + ((col+2) mod WORD_COL));
                                         end if;
				elsif (col < col_bases(0) + 8*WORD_COL) and palavras_size(0) >= 8 then
                                        if indice_locked = 0 and LETTER_HITS >= 8 then
                                                print_enable <= '0';
                                        else
                                            print_enable <= letras_atuais(0, 7)((line-line_bases(0)) * WORD_COL + ((col+2) mod WORD_COL));
                                         end if;
				elsif (col < col_bases(0) + 9*WORD_COL) and palavras_size(0) >= 9 then
                                        if indice_locked = 0 and LETTER_HITS >= 9 then
                                                print_enable <= '0';
                                        else
                                            print_enable <= letras_atuais(0, 8)((line-line_bases(0)) * WORD_COL + ((col+2) mod WORD_COL));
                                         end if;
				elsif (col < col_bases(0) + 10*WORD_COL) and palavras_size(0) >= 10 then
                                        if indice_locked = 0 and LETTER_HITS >= 10 then
                                                print_enable <= '0';
                                        else
                                            print_enable <= letras_atuais(0, 9)((line-line_bases(0)) * WORD_COL + ((col+2) mod WORD_COL));
                                         end if;
				else
					print_enable <= '0';
				end if;
		  
				--print_enable <= alfa( ( palavras(0, (col - col_bases(0)) / WORD_COL) ) - 65);
		  elsif line >= line_bases(1) and line < line_bases(1) + WORD_LINE and col >= col_bases(1) and col < col_bases(1) + WORD_COL * palavras_size(1) then
				if (col < col_bases(1) + WORD_COL) and palavras_size(1) >= 1 then
                                        if indice_locked = 1 and LETTER_HITS >= 1 then
                                                print_enable <= '0';
                                        else
                                            print_enable <= letras_atuais(1, 0)((line-line_bases(1)) * WORD_COL + ((col+1) mod WORD_COL));
                                         end if;
				elsif (col < col_bases(1) + 2*WORD_COL) and palavras_size(1) >= 2 then
                                        if indice_locked = 1 and LETTER_HITS >= 2 then
                                                print_enable <= '0';
                                        else
                                            print_enable <= letras_atuais(1, 1)((line-line_bases(1)) * WORD_COL + ((col+1) mod WORD_COL));
                                         end if;
				elsif (col < col_bases(1) + 3*WORD_COL) and palavras_size(1) >= 3 then
                                        if indice_locked = 1 and LETTER_HITS >= 3 then
                                                print_enable <= '0';
                                        else
                                            print_enable <= letras_atuais(1, 2)((line-line_bases(1)) * WORD_COL + ((col+1) mod WORD_COL));
                                         end if;
				elsif (col < col_bases(1) + 4*WORD_COL) and palavras_size(1) >= 4 then
                                        if indice_locked = 1 and LETTER_HITS >= 4 then
                                                print_enable <= '0';
                                        else
                                            print_enable <= letras_atuais(1, 3)((line-line_bases(1)) * WORD_COL + ((col+1) mod WORD_COL));
                                         end if;
				elsif (col < col_bases(1) + 5*WORD_COL) and palavras_size(1) >= 5 then
                                        if indice_locked = 1 and LETTER_HITS >= 5 then
                                                print_enable <= '0';
                                        else
                                            print_enable <= letras_atuais(1, 4)((line-line_bases(1)) * WORD_COL + ((col+1) mod WORD_COL));
                                         end if;
				elsif (col < col_bases(1) + 6*WORD_COL) and palavras_size(1) >= 6 then
                                        if indice_locked = 1 and LETTER_HITS >= 6 then
                                                print_enable <= '0';
                                        else
                                            print_enable <= letras_atuais(1, 5)((line-line_bases(1)) * WORD_COL + ((col+1) mod WORD_COL));
                                         end if;
				elsif (col < col_bases(1) + 7*WORD_COL) and palavras_size(1) >= 7 then
                                        if indice_locked = 1 and LETTER_HITS >= 7 then
                                                print_enable <= '0';
                                        else
                                            print_enable <= letras_atuais(1, 6)((line-line_bases(1)) * WORD_COL + ((col+1) mod WORD_COL));
                                         end if;
				elsif (col < col_bases(1) + 8*WORD_COL) and palavras_size(1) >= 8 then
                                        if indice_locked = 1 and LETTER_HITS >= 8 then
                                                print_enable <= '0';
                                        else
                                            print_enable <= letras_atuais(1, 7)((line-line_bases(1)) * WORD_COL + ((col+1) mod WORD_COL));
                                         end if;
				elsif (col < col_bases(1) + 9*WORD_COL) and palavras_size(1) >= 9 then
                                        if indice_locked = 1 and LETTER_HITS >= 9 then
                                                print_enable <= '0';
                                        else
                                            print_enable <= letras_atuais(1, 8)((line-line_bases(1)) * WORD_COL + ((col+1) mod WORD_COL));
                                         end if;
				elsif (col < col_bases(1) + 10*WORD_COL) and palavras_size(1) >= 10 then
                                        if indice_locked = 1 and LETTER_HITS >= 10 then
                                                print_enable <= '0';
                                        else
                                            print_enable <= letras_atuais(1, 9)((line-line_bases(1)) * WORD_COL + ((col+1) mod WORD_COL));
                                         end if;
				else
					print_enable<= '0';
				end if;
		  elsif line >= line_bases(2) and line < line_bases(2) + WORD_LINE and col >= col_bases(2) and col < col_bases(2) + WORD_COL * palavras_size(2) then
				if (col < col_bases(2) + WORD_COL) and palavras_size(2) >= 1 then
                                        if indice_locked = 2 and LETTER_HITS >= 1 then
                                                print_enable <= '0';
                                        else
                                            print_enable <= letras_atuais(2, 0)((line-line_bases(2)) * WORD_COL + (col mod WORD_COL));
                                         end if;
				elsif (col < col_bases(2) + 2*WORD_COL) and palavras_size(2) >= 2 then
                                        if indice_locked = 2 and LETTER_HITS >= 2 then
                                                print_enable <= '0';
                                        else
                                            print_enable <= letras_atuais(2, 1)((line-line_bases(2)) * WORD_COL + (col mod WORD_COL));
                                         end if;
				elsif (col < col_bases(2) + 3*WORD_COL) and palavras_size(2) >= 3 then
                                        if indice_locked = 2 and LETTER_HITS >= 3 then
                                                print_enable <= '0';
                                        else
                                            print_enable <= letras_atuais(2, 2)((line-line_bases(2)) * WORD_COL + (col mod WORD_COL));
                                         end if;
				elsif (col < col_bases(2) + 4*WORD_COL) and palavras_size(2) >= 4 then
                                        if indice_locked = 2 and LETTER_HITS >= 4 then
                                                print_enable <= '0';
                                        else
                                            print_enable <= letras_atuais(2, 3)((line-line_bases(2)) * WORD_COL + (col mod WORD_COL));
                                         end if;
				elsif (col < col_bases(2) + 5*WORD_COL) and palavras_size(2) >= 5 then
                                        if indice_locked = 2 and LETTER_HITS >= 5 then
                                                print_enable <= '0';
                                        else
                                            print_enable <= letras_atuais(2, 4)((line-line_bases(2)) * WORD_COL + (col mod WORD_COL));
                                         end if;
				elsif (col < col_bases(2) + 6*WORD_COL) and palavras_size(2) >= 6 then
                                        if indice_locked = 2 and LETTER_HITS >= 6 then
                                                print_enable <= '0';
                                        else
                                            print_enable <= letras_atuais(2, 5)((line-line_bases(2)) * WORD_COL + (col mod WORD_COL));
                                         end if;
				elsif (col < col_bases(2) + 7*WORD_COL) and palavras_size(2) >= 7 then
                                        if indice_locked = 2 and LETTER_HITS >= 7 then
                                                print_enable <= '0';
                                        else
                                            print_enable <= letras_atuais(2, 6)((line-line_bases(2)) * WORD_COL + (col mod WORD_COL));
                                         end if;
				elsif (col < col_bases(2) + 8*WORD_COL) and palavras_size(2) >= 8 then
                                        if indice_locked = 2 and LETTER_HITS >= 8 then
                                                print_enable <= '0';
                                        else
                                            print_enable <= letras_atuais(2, 7)((line-line_bases(2)) * WORD_COL + (col mod WORD_COL));
                                         end if;
				elsif (col < col_bases(2) + 9*WORD_COL) and palavras_size(2) >= 9 then
                                        if indice_locked = 2 and LETTER_HITS >= 9 then
                                                print_enable <= '0';
                                        else
                                            print_enable <= letras_atuais(2, 8)((line-line_bases(2)) * WORD_COL + (col mod WORD_COL));
                                         end if;
				elsif (col < col_bases(2) + 10*WORD_COL) and palavras_size(2) >= 10 then
                                        if indice_locked = 2 and LETTER_HITS >= 10 then
                                                print_enable <= '0';
                                        else
                                            print_enable <= letras_atuais(2, 9)((line-line_bases(2)) * WORD_COL + (col mod WORD_COL));
                                         end if;
				else
					print_enable <= '0';
				end if;
		  elsif line >= line_bases(3) and line < line_bases(3) + WORD_LINE and col >= col_bases(3) and col < col_bases(3) + WORD_COL * palavras_size(3) then
				if (col < col_bases(3) + WORD_COL) and palavras_size(3) >= 1 then
                                        if indice_locked = 3 and LETTER_HITS >= 1 then
                                                print_enable <= '0';
                                        else
                                            print_enable <= letras_atuais(3, 0)((line-line_bases(3)) * WORD_COL + (col mod WORD_COL));
                                         end if;
				elsif (col < col_bases(3) + 2*WORD_COL) and palavras_size(3) >= 2 then
                                        if indice_locked = 3 and LETTER_HITS >= 2 then
                                                print_enable <= '0';
                                        else
                                            print_enable <= letras_atuais(3, 1)((line-line_bases(3)) * WORD_COL + (col mod WORD_COL));
                                         end if;
				elsif (col < col_bases(3) + 3*WORD_COL) and palavras_size(3) >= 3 then
                                        if indice_locked = 3 and LETTER_HITS >= 3 then
                                                print_enable <= '0';
                                        else
                                            print_enable <= letras_atuais(3, 2)((line-line_bases(3)) * WORD_COL + (col mod WORD_COL));
                                         end if;
				elsif (col < col_bases(3) + 4*WORD_COL) and palavras_size(3) >= 4 then
                                        if indice_locked = 3 and LETTER_HITS >= 4 then
                                                print_enable <= '0';
                                        else
                                            print_enable <= letras_atuais(3, 3)((line-line_bases(3)) * WORD_COL + (col mod WORD_COL));
                                         end if;
				elsif (col < col_bases(3) + 5*WORD_COL) and palavras_size(3) >= 5 then
                                        if indice_locked = 3 and LETTER_HITS >= 5 then
                                                print_enable <= '0';
                                        else
                                            print_enable <= letras_atuais(3, 4)((line-line_bases(3)) * WORD_COL + (col mod WORD_COL));
                                         end if;
				elsif (col < col_bases(3) + 6*WORD_COL) and palavras_size(3) >= 6 then
                                        if indice_locked = 3 and LETTER_HITS >= 6 then
                                                print_enable <= '0';
                                        else
                                            print_enable <= letras_atuais(3, 5)((line-line_bases(3)) * WORD_COL + (col mod WORD_COL));
                                         end if;
				elsif (col < col_bases(3) + 7*WORD_COL) and palavras_size(3) >= 7 then
                                        if indice_locked = 3 and LETTER_HITS >= 7 then
                                                print_enable <= '0';
                                        else
                                            print_enable <= letras_atuais(3, 6)((line-line_bases(3)) * WORD_COL + (col mod WORD_COL));
                                         end if;
				elsif (col < col_bases(3) + 8*WORD_COL) and palavras_size(3) >= 8 then
                                        if indice_locked = 3 and LETTER_HITS >= 8 then
                                                print_enable <= '0';
                                        else
                                            print_enable <= letras_atuais(3, 7)((line-line_bases(3)) * WORD_COL + (col mod WORD_COL));
                                         end if;
				elsif (col < col_bases(3) + 9*WORD_COL) and palavras_size(3) >= 9 then
                                        if indice_locked = 3 and LETTER_HITS >= 9 then
                                                print_enable <= '0';
                                        else
                                            print_enable <= letras_atuais(3, 8)((line-line_bases(3)) * WORD_COL + (col mod WORD_COL));
                                         end if;
				elsif (col < col_bases(3) + 10*WORD_COL) and palavras_size(3) >= 10 then
                                        if indice_locked = 3 and LETTER_HITS >= 10 then
                                                print_enable <= '0';
                                        else
                                            print_enable <= letras_atuais(3, 9)((line-line_bases(3)) * WORD_COL + (col mod WORD_COL));
                                         end if;
				else
					print_enable <= '0';
				end if;
		  elsif line >= line_bases(4) and line < line_bases(4) + WORD_LINE and col >= col_bases(4) and col < col_bases(4) + WORD_COL * palavras_size(4) then
				if (col < col_bases(4) + WORD_COL) and palavras_size(4) >= 1 then
                                        if indice_locked = 4 and LETTER_HITS >= 1 then
                                                print_enable <= '0';
                                        else
                                            print_enable <= letras_atuais(4, 0)((line-line_bases(4)) * WORD_COL + ((col-1) mod WORD_COL));	
                                         end if;
				elsif (col < col_bases(4) + 2*WORD_COL) and palavras_size(4) >= 2 then
                                        if indice_locked = 4 and LETTER_HITS >= 2 then
                                                print_enable <= '0';
                                        else
                                            print_enable <= letras_atuais(4, 1)((line-line_bases(4)) * WORD_COL + ((col-1) mod WORD_COL));
                                         end if;
				elsif (col < col_bases(4) + 3*WORD_COL) and palavras_size(4) >= 3 then
                                        if indice_locked = 4 and LETTER_HITS >= 3 then
                                                print_enable <= '0';
                                        else
                                            print_enable <= letras_atuais(4, 2)((line-line_bases(4)) * WORD_COL + ((col-1) mod WORD_COL));
                                         end if;
				elsif (col < col_bases(4) + 4*WORD_COL) and palavras_size(4) >= 4 then
                                        if indice_locked = 4 and LETTER_HITS >= 4 then
                                                print_enable <= '0';
                                        else
                                            print_enable <= letras_atuais(4, 3)((line-line_bases(4)) * WORD_COL + ((col-1) mod WORD_COL));
                                         end if;
				elsif (col < col_bases(4) + 5*WORD_COL) and palavras_size(4) >= 5 then
                                        if indice_locked = 4 and LETTER_HITS >= 5 then
                                                print_enable <= '0';
                                        else
                                            print_enable <= letras_atuais(4, 4)((line-line_bases(4)) * WORD_COL + ((col-1) mod WORD_COL));
                                         end if;
				elsif (col < col_bases(4) + 6*WORD_COL) and palavras_size(4) >= 6 then
                                        if indice_locked = 4 and LETTER_HITS >= 6 then
                                                print_enable <= '0';
                                        else
                                            print_enable <= letras_atuais(4, 5)((line-line_bases(4)) * WORD_COL + ((col-1) mod WORD_COL));
                                         end if;
				elsif (col < col_bases(4) + 7*WORD_COL) and palavras_size(4) >= 7 then
                                        if indice_locked = 4 and LETTER_HITS >= 7 then
                                                print_enable <= '0';
                                        else
                                            print_enable <= letras_atuais(4, 6)((line-line_bases(4)) * WORD_COL + ((col-1) mod WORD_COL));
                                         end if;
				elsif (col < col_bases(4) + 8*WORD_COL) and palavras_size(4) >= 8 then
                                        if indice_locked = 4 and LETTER_HITS >= 8 then
                                                print_enable <= '0';
                                        else
                                            print_enable <= letras_atuais(4, 7)((line-line_bases(4)) * WORD_COL + ((col-1) mod WORD_COL));
                                         end if;
				elsif (col < col_bases(4) + 9*WORD_COL) and palavras_size(4) >= 9 then
                                        if indice_locked = 4 and LETTER_HITS >= 9 then
                                                print_enable <= '0';
                                        else
                                            print_enable <= letras_atuais(4, 8)((line-line_bases(4)) * WORD_COL + ((col-1) mod WORD_COL));
                                         end if;
				elsif (col < col_bases(4) + 10*WORD_COL) and palavras_size(4) >= 10 then
                                        if indice_locked = 4 and LETTER_HITS >= 10 then
                                                print_enable <= '0';
                                        else
                                            print_enable <= letras_atuais(4, 9)((line-line_bases(4)) * WORD_COL + ((col-1) mod WORD_COL));
                                         end if;
				else
					print_enable <= '0';
				end if;
		   else
				print_enable <= '0';
			end if;
		end if;
    end if;
  end process pega_linha;
  
    -----------------------------------------------------------------------------
  -- PROCESS PARA DESCER A LETRA
  -----------------------------------------------------------------------------

  -- purpose: 
  -- type   : sequential
  -- inputs :
  -- outputs: 
  desce_linha: process (CLOCK_50)
  begin  -- process conta_coluna
    if CLOCK_50'event and CLOCK_50 = '1' then  -- rising clock edge
		local_game_over <= '0';
		if WORD_DESTROYED = '1' then
			line_bases(indice_locked) <= 10;
		elsif reset = '0' or estado = inicio then
			for i in 0 to max_words-1 loop
				line_bases(i) <= 10;
			end loop;
			
		elsif atualiza_pos_y = '1' then
			if line_bases(0) >= 467 or line_bases(1) >= 467 or line_bases(2) >= 467 or line_bases(3) >= 467 or line_bases (4) >= 467 then
            local_game_over <= '1';
				for i in 0 to max_words-1 loop
					line_bases(i) <= 10;
				end loop;
			else
            local_game_over <= '0';
				for i in 0 to max_words-1 loop
					if empty_positions(i) = 0 then
						line_bases(i) <= line_bases(i) + 1;
					end if;
				end loop;
			end if;
		end if;
	 end if;
  end process desce_linha;
  
   -----------------------------------------------------------------------------
  -- PROCESS RESPONSAVEL POR ALTERAR A LETRA ATUAL DEPENDENDO DE QUAL POSICAO ESTAMOS
  -----------------------------------------------------------------------------

  -- purpose: Este processo altera a letra atual dependendo de qual coluna estamos agora
  -- type   : 
  -- inputs : CLOCK_50,
  -- outputs: col
  troca_letra_atual: process (CLOCK_50)
  begin  -- process conta_coluna
    --letra_atual <= alfa( ( palavras(0)((col - col_bases(0)) / WORD_COL) ) - 65);
    if CLOCK_50'event and CLOCK_50 = '1' then  -- rising clock edge
		  if print_enable = '1' and inic_screen = '0' and over_screen = '0' then
				if col >= col_bases(0) and col < col_bases(0) + palavras_size(0) * WORD_COL and indice_locked = 0 then
					pixel <= "101";
				elsif col >= col_bases(1) and col < col_bases(1) + palavras_size(1) * WORD_COL and indice_locked = 1 then
					pixel <= "101";
				elsif col >= col_bases(2) and col < col_bases(2) + palavras_size(2) * WORD_COL and indice_locked = 2 then
					pixel <= "101";
				elsif col >= col_bases(3) and col < col_bases(3) + palavras_size(3) * WORD_COL and indice_locked = 3 then
					pixel <= "101";
				elsif col >= col_bases(4) and col < col_bases(4) + palavras_size(4) * WORD_COL and indice_locked = 4 then
					pixel <= "101";
				else
					pixel <= "111";
				end if;
			elsif inic_screen = '1' and over_screen = '0' then
				pixel <= tela_inicial( line + col*NUM_LINE);
			elsif inic_screen = '0' and over_screen = '1' then
			   pixel <= tela_over( line + col*NUM_LINE);
			elsif print_enable = '0' then
				pixel <= "000";
			end if;
		  -- O endereço de memória pode ser construído com essa fórmula simples,
		  -- a partir da linha e coluna atual
		  addr  <= col + (NUM_COL * line);   
    end if;
  end process troca_letra_atual;

  letras_atuais(0, 0) <= alfa (to_integer(unsigned(palavras(0)(7 downto 0))) - 65);
	letras_atuais(0, 1) <= alfa (to_integer(unsigned(palavras(0)(15 downto 8))) - 65);
	letras_atuais(0, 2) <= alfa (to_integer(unsigned(palavras(0)(23 downto 16))) - 65);
	letras_atuais(0, 3) <= alfa (to_integer(unsigned(palavras(0)(31 downto 24))) - 65);
	letras_atuais(0, 4) <= alfa (to_integer(unsigned(palavras(0)(39 downto 32))) - 65);
	letras_atuais(0, 5) <= alfa (to_integer(unsigned(palavras(0)(47 downto 40))) - 65);
	letras_atuais(0, 6) <= alfa (to_integer(unsigned(palavras(0)(55 downto 48))) - 65);
	letras_atuais(0, 7) <= alfa (to_integer(unsigned(palavras(0)(63 downto 56))) - 65);
	letras_atuais(0, 8) <= alfa (to_integer(unsigned(palavras(0)(71 downto 64))) - 65);
	letras_atuais(0, 9) <= alfa (to_integer(unsigned(palavras(0)(79 downto 72))) - 65);
	letras_atuais(1, 0) <= alfa (to_integer(unsigned(palavras(1)(7 downto 0))) - 65);
	letras_atuais(1, 1) <= alfa (to_integer(unsigned(palavras(1)(15 downto 8))) - 65);
	letras_atuais(1, 2) <= alfa (to_integer(unsigned(palavras(1)(23 downto 16))) - 65);
	letras_atuais(1, 3) <= alfa (to_integer(unsigned(palavras(1)(31 downto 24))) - 65);
	letras_atuais(1, 4) <= alfa (to_integer(unsigned(palavras(1)(39 downto 32))) - 65);
	letras_atuais(1, 5) <= alfa (to_integer(unsigned(palavras(1)(47 downto 40))) - 65);
	letras_atuais(1, 6) <= alfa (to_integer(unsigned(palavras(1)(55 downto 48))) - 65);
	letras_atuais(1, 7) <= alfa (to_integer(unsigned(palavras(1)(63 downto 56))) - 65);
	letras_atuais(1, 8) <= alfa (to_integer(unsigned(palavras(1)(71 downto 64))) - 65);
	letras_atuais(1, 9) <= alfa (to_integer(unsigned(palavras(1)(79 downto 72))) - 65);
	letras_atuais(2, 0) <= alfa (to_integer(unsigned(palavras(2)(7 downto 0))) - 65);
	letras_atuais(2, 1) <= alfa (to_integer(unsigned(palavras(2)(15 downto 8))) - 65);
	letras_atuais(2, 2) <= alfa (to_integer(unsigned(palavras(2)(23 downto 16))) - 65);
	letras_atuais(2, 3) <= alfa (to_integer(unsigned(palavras(2)(31 downto 24))) - 65);
	letras_atuais(2, 4) <= alfa (to_integer(unsigned(palavras(2)(39 downto 32))) - 65);
	letras_atuais(2, 5) <= alfa (to_integer(unsigned(palavras(2)(47 downto 40))) - 65);
	letras_atuais(2, 6) <= alfa (to_integer(unsigned(palavras(2)(55 downto 48))) - 65);
	letras_atuais(2, 7) <= alfa (to_integer(unsigned(palavras(2)(63 downto 56))) - 65);
	letras_atuais(2, 8) <= alfa (to_integer(unsigned(palavras(2)(71 downto 64))) - 65);
	letras_atuais(2, 9) <= alfa (to_integer(unsigned(palavras(2)(79 downto 72))) - 65);
	letras_atuais(3, 0) <= alfa (to_integer(unsigned(palavras(3)(7 downto 0))) - 65);
	letras_atuais(3, 1) <= alfa (to_integer(unsigned(palavras(3)(15 downto 8))) - 65);
	letras_atuais(3, 2) <= alfa (to_integer(unsigned(palavras(3)(23 downto 16))) - 65);
	letras_atuais(3, 3) <= alfa (to_integer(unsigned(palavras(3)(31 downto 24))) - 65);
	letras_atuais(3, 4) <= alfa (to_integer(unsigned(palavras(3)(39 downto 32))) - 65);
	letras_atuais(3, 5) <= alfa (to_integer(unsigned(palavras(3)(47 downto 40))) - 65);
	letras_atuais(3, 6) <= alfa (to_integer(unsigned(palavras(3)(55 downto 48))) - 65);
	letras_atuais(3, 7) <= alfa (to_integer(unsigned(palavras(3)(63 downto 56))) - 65);
	letras_atuais(3, 8) <= alfa (to_integer(unsigned(palavras(3)(71 downto 64))) - 65);
	letras_atuais(3, 9) <= alfa (to_integer(unsigned(palavras(3)(79 downto 72))) - 65);
	letras_atuais(4, 0) <= alfa (to_integer(unsigned(palavras(4)(7 downto 0))) - 65);
	letras_atuais(4, 1) <= alfa (to_integer(unsigned(palavras(4)(15 downto 8))) - 65);
	letras_atuais(4, 2) <= alfa (to_integer(unsigned(palavras(4)(23 downto 16))) - 65);
	letras_atuais(4, 3) <= alfa (to_integer(unsigned(palavras(4)(31 downto 24))) - 65);
	letras_atuais(4, 4) <= alfa (to_integer(unsigned(palavras(4)(39 downto 32))) - 65);
	letras_atuais(4, 5) <= alfa (to_integer(unsigned(palavras(4)(47 downto 40))) - 65);
	letras_atuais(4, 6) <= alfa (to_integer(unsigned(palavras(4)(55 downto 48))) - 65);
	letras_atuais(4, 7) <= alfa (to_integer(unsigned(palavras(4)(63 downto 56))) - 65);
	letras_atuais(4, 8) <= alfa (to_integer(unsigned(palavras(4)(71 downto 64))) - 65);
	letras_atuais(4, 9) <= alfa (to_integer(unsigned(palavras(4)(79 downto 72))) - 65);
  -----------------------------------------------------------------------------
  -- Processos que controlam contadores de linhas e coluna para varrer
  -- todos os endereços da memória de vídeo, no momento de construir um quadro.
  -----------------------------------------------------------------------------

  -- purpose: Este processo conta o número da coluna atual, quando habilitado
  --          pelo sinal "col_enable".
  -- type   : sequential
  -- inputs : CLOCK_50, col_rstn
  -- outputs: col
  conta_coluna: process (CLOCK_50, col_rstn)
  begin  -- process conta_coluna
    if col_rstn = '0' then                  -- asynchronous reset (active low)
      col <= 0;
    elsif CLOCK_50'event and CLOCK_50 = '1' then  -- rising clock edge
      if col_enable = '1' then
        if col = NUM_COL-1 then               -- conta de 0 a NUM_COL-1 (NUM_COL colunas)
          col <= 0;
        else
          col <= col + 1;
        end if;
      end if;
    end if;
  end process conta_coluna;
    
  -- purpose: Este processo conta o número da linha atual, quando habilitado
  --          pelo sinal "line_enable".
  -- type   : sequential
  -- inputs : CLOCK_50, line_rstn
  -- outputs: line
  conta_linha: process (CLOCK_50, line_rstn)
  begin  -- process conta_linha
    if line_rstn = '0' then                  -- asynchronous reset (active low)
      line <= 0;
    elsif CLOCK_50'event and CLOCK_50 = '1' then  -- rising clock edge
      -- o contador de linha só incrementa quando o contador de colunas
      -- chegou ao fim (valor NUM_COL-1)
      if line_enable = '1' and col = NUM_COL-1 then
        if line = NUM_LINE-1 then               -- conta de 0 a NUM_LINE-1 (NUM_LINE linhas)
          line <= 0;
        else
          line <= line + 1;  
        end if;
      end if;
    end if;
  end process conta_linha;

  -- Este sinal é útil para informar nossa lógica de controle quando
  -- o quadro terminou de ser escrito na memória de vídeo, para que
  -- possamos avançar para o próximo estado.
  fim_escrita <= '1' when (line = NUM_LINE-1) and (col = NUM_COL-1) else '0'; 
  
  -----------------------------------------   -- asynchronous reset (active lo------------------------------------
  -- Processos que definem a FSM (finite state machine), nossa máquina
  -- de estados de controle.
  -----------------------------------------------------------------------------

  -- purpose: 
  -- type   : 
  -- inputs : 
  -- outputs: atualiza_pos_y, line_rstn,
  --          line_enable, col_rstn, col_enable, we, timer_enable, timer_rstn
  logica_mealy: process (CLOCK_50, reset)
  begin  -- process logica_mealy
	 -- Reset assincrono
	 if reset = '0' then
		estado <= inicio;
	 elsif CLOCK_50'event and CLOCK_50 = '1' then
		if local_game_over = '1' then
			estado <= show_over;
		else
				case estado is
				when inicio         => estado <= show_inicio;
											  atualiza_pos_y <= '0';
											  line_rstn      <= '0';  -- reset é active low!
											  line_enable    <= '0';
											  col_rstn       <= '0';  -- reset é active low!
											  col_enable     <= '0';
											  we             <= '0';
											  timer_rstn     <= '1';  -- reset é active low!
											  timer_enable   <= '1';
											  inic_screen    <= '0';
											  over_screen 	  <= '0';

											  LEDR(9 downto 5) <= "10000";

				when constroi_quadro => if fim_escrita = '1' then
												 estado <= desce_palavras;
											  else
												estado <= constroi_quadro;
											  end if;
											  atualiza_pos_y <= '0';
											  line_rstn      <= '1';
											  line_enable    <= '1';
											  col_rstn       <= '1';
											  col_enable     <= '1';
											  we             <= '1';
											  timer_rstn     <= '0'; 
											  timer_enable   <= '0';
											  inic_screen    <= '0';
											  over_screen 	  <= '0';
											  LEDR(9 downto 5) <= "01000";

				when desce_palavras => if timer = '1' then
												   estado <= constroi_quadro;
													atualiza_pos_y <= '1';
											  else
													estado <= desce_palavras;
													atualiza_pos_y <= '0';
											  end if;
											  line_rstn      <= '0';
											  line_enable    <= '0';
											  col_rstn       <= '0';
											  col_enable     <= '0';
											  we             <= '0';
											  timer_rstn     <= '1'; 
											  timer_enable   <= '1';
											  inic_screen     <= '0';
											  over_screen 	  <= '0';
											  LEDR(9 downto 5) <= "00100";

				when show_inicio    => --if START_GAME = '1' then
												--	estado <= constroi_quadro;
											  if fim_escrita = '1' then
													estado <= wait_action;
											  else
													estado <= show_inicio;
											  end if;
											  atualiza_pos_y <= '0';
											  line_rstn      <= '1';
											  line_enable    <= '1';
											  col_rstn       <= '1';
											  col_enable     <= '1';
											  we             <= '1';
											  timer_rstn     <= '0'; 
											  timer_enable   <= '1';
											  inic_screen    <= '1';
											  over_screen 	  <= '0';

											  LEDR(9 downto 5) <= "00010";
											  
				  when show_over 	 =>  --if PLAY_AGAIN = '1' then
												--	estado <= inicio;
											  if fim_escrita = '1' then
													estado <= wait_action;
											  else
													estado <= show_over;
											  end if;
											  atualiza_pos_y <= '0';
											  line_rstn      <= '1';
											  line_enable    <= '1';
											  col_rstn       <= '1';
											  col_enable     <= '1';
											  we             <= '1';
											  timer_rstn     <= '0'; 
											  timer_enable   <= '0';
											  inic_screen    <= '0';
											  over_screen 	  <= '1';
											  LEDR(9 downto 5) <= "00001";
											  
					when OTHERS		 =>  if PLAY_AGAIN = '1' then		-- wait_action
													estado <= inicio;
											  elsif START_GAME = '1' then
													estado <= constroi_quadro;
											  else
													estado <= wait_action;
											  end if;
											  atualiza_pos_y <= '0';
											  line_rstn      <= '0';  -- reset é active low!
											  line_enable    <= '0';
											  col_rstn       <= '0';  -- reset é active low!
											  col_enable     <= '0';
											  we             <= '0';
											  timer_rstn     <= '1';  -- reset é active low!
											  timer_enable   <= '1';
											  inic_screen    <= '0';
											  over_screen 	  <= '0';
											  
											  LEDR(9 downto 5) <= "10001";

			 end case;
		end if;
	 end if;
	 
  end process logica_mealy;
  
  -----------------------------------------------------------------------------
  -- Processos do contador utilizado para atrasar a animação (evitar
  -- que a atualização de quadros fique excessivamente veloz).
  -----------------------------------------------------------------------------
  -- purpose: Incrementa o contador a cada ciclo de clock
  -- type   : sequential
  -- inputs : CLOCK_50, timer_rstn
  -- outputs: contador, timer
  p_contador: process (CLOCK_50, timer_rstn)
  begin  -- process p_contador
    if timer_rstn = '0' then            -- asynchronous reset (active low)
      contador <= 0;
    elsif CLOCK_50'event and CLOCK_50 = '1' then  -- rising clock edge
      if timer_enable = '1' then       
        if contador = contador_in_stage(stage_atual) then
          contador <= 0;
        else
          contador <=  contador + 1;        
        end if;
      end if;
    end if;
  end process p_contador;
  
  -- purpose: Calcula o sinal "timer" que indica quando o contador chegou aotemp := KEY(0);
  --          final
  -- type   : combinational
  -- inputs : contador
  -- outputs: timer
  p_timer: process (contador)
  begin  -- process p_timer
    if contador = contador_in_stage(stage_atual) then
	   timer <= '1';
	 else
      timer <= '0';
    end if;
  end process p_timer;

  -----------------------------------------------------------------------------
  -- Processos que sincronizam sinais assíncronos, de preferência com mais
  -- de 1 flipflop, para evitar metaestabilidade.
  -----------------------------------------------------------------------------
  
  -- purpose: Aqui sincronizamos nosso sinal de reset vindo do botão da DE1
  -- type   : sequential
  -- inputs : CLOCK_50
  -- outputs: rstn
  build_rstn: process (CLOCK_50)
    variable temp : std_logic := '1';          -- flipflop intermediario
  begin  -- process build_rstn
    if CLOCK_50'event and CLOCK_50 = '1' then  -- rising clock edge
      rstn <= temp;
		temp := reset;
    end if;
  end process build_rstn;
	
end comportamento;


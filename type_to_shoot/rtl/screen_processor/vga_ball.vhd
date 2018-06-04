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

entity vga_ball is
	generic (
		NUM_LINE : integer := 480;
		NUM_COL : integer := 640;
		WORD_LINE : integer := 16;
		WORD_COL : integer := 8
	);
  port (    
    CLOCK_50                	: in  std_logic;
    KEY                     	: in  std_logic_vector(1 downto 0);
    START_GAME		        : in  std_logic;
    STAGE_END		        : in  std_logic;
    PLAY_AGAIN		        : in  std_logic;
    NEW_WORD		        : in  word;
    NEW_WORD_SIZE		: in  integer;
    LOCKED_WORD		        : in  word;
    LETTER_HIT		        : in  std_logic;
    WORD_DESTROYED		: in  std_logic;
    VGA_R, VGA_G, VGA_B     	: out std_logic_vector(7 downto 0);
    VGA_HS, VGA_VS          	: out std_logic;
    VGA_BLANK_N, VGA_SYNC_N	: out std_logic;
    VGA_CLK                 	: out std_logic;
	 LEDR								: out std_logic_vector(4 downto 0);
    TIMER_P			: out std_logic;
    GAME_OVER		        : out std_logic
    );
end vga_ball;

architecture comportamento of vga_ball is
  
   type splash is array (0 to NUM_LINE * NUM_COL - 1) of std_logic_vector(2 downto 0);
	signal tela_inicial: splash;
	attribute ram_init_file : string;
	attribute ram_init_file of tela_inicial : signal is "start_1.mif";
   signal tela_troca_estagio : splash;
	attribute ram_init_file of tela_troca_estagio : signal is "troca_1.mif";
	
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
  signal col_splash : std_logic;
  signal line_rstn : std_logic;          -- reset do contador de linhas
  signal line_enable : std_logic;        -- enable do contador de linhas
  signal line_splash : std_logic;
  signal fim_escrita : std_logic;       -- '1' quando um quadro terminou de ser
                                        -- escrito na memória de vídeo
  signal atualiza_pos_y : std_logic;    -- se '1' = as palavras mudam sua pos. no eixo y

  -- Especificação dos tipos e sinais da máquina de estados de controle
  type estado_t is (show_splash, inicio, constroi_quadro, desce_palavras, limpa_tela);
  signal estado: estado_t := inicio;
  signal proximo_estado: estado_t := inicio;

  -- Sinais para um contador utilizado para atrasar a atualização da
  -- posição da bola, a fim de evitar que a animação fique excessivamente
  -- veloz. Aqui utilizamos um contador de 0 a 1250000, de modo que quando
  -- alimentado com um clock de 50MHz, ele demore 25ms (40fps) para contar até o final.
  
  signal contador : integer range 0 to 1250000 - 1;  -- contador
  signal timer : std_logic;        -- vale '1' quando o contador chegar ao fim
  signal timer_rstn, timer_enable : std_logic;
  
  signal sync, blank: std_logic;

  signal cor_atual : std_logic_vector(2 downto 0) := "001";
  signal inic_splash : std_logic := '0';
  signal inic_limpa : std_logic := '0';
  signal locked_hits : integer range 0 to 10 := 0;
  signal my_play : std_logic := '0';
  
  constant col_0 : integer := 5;
  constant col_1 : integer := 110;
  constant col_2 : integer := 215;
  constant col_3 : integer := 320;
  constant col_4 : integer := 425;
  constant col_5 : integer := 530;

  signal line_bases : array5 := (10, 10, 10, 10, 10);
  signal col_bases : array5 := (col_0, col_1, col_2, col_3, col_4);

  signal print_enable : std_logic := '0';
  signal ja_limpei : std_logic := '0';
  signal indice : integer range 0 to 6 := 5;
  type letra_t is array (0 to WORD_COL * WORD_LINE -1) of std_logic;

  type matriz_palavras is array (0 to 4) of word;
  signal letter_col : array5 := (10, 10, 10, 10, 10);
  signal palavras : matriz_palavras := (
  (76, 79, 71, 73, 67, 79, 83, 84, 85, 68),
  (69, 72, 91, 91, 70, 71, 72, 73, 74, 75),
  (65, 77, 79, 82, 75, 76, 76, 76, 76, 76),
  (71, 72, 73, 74, 75, 76, 77, 78, 79, 80),
  (76, 79, 71, 73, 67, 79, 83, 67, 89, 90));

  type letras_atuais_t is array (0 to 4, 0 to 9) of letra_t;

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
	 
	 
 -- PROCESS PARA VERIFICAR SE ALGUMA PALAVRA FOI DESTRUIDA E QUAL
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
 
 
   -- purpose: 
   -- type   : 
   -- inputs :
   -- outputs: 
procura_indice: process (LETTER_HIT)
  begin
		for i in 0 to 4 loop
			if palavras(i)(0) = LOCKED_WORD(0) and palavras(i)(1) = LOCKED_WORD(1) and palavras(i)(2) = LOCKED_WORD(2)  and palavras(i)(3) = LOCKED_WORD(3)   and palavras(i)(4) = LOCKED_WORD(4)   and palavras(i)(5) = LOCKED_WORD(5)   and palavras(i)(6) = LOCKED_WORD(6)   and palavras(i)(7) = LOCKED_WORD(7)  and palavras(i)(8) = LOCKED_WORD(8)  and palavras(i)(9) = LOCKED_WORD(9) then
					indice <= i;
			end if;
		end loop;
		locked_hits <= locked_hits + 1;
end process procura_indice;

TIMER_P <= timer;
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
			if line >= line_bases(0) and line < line_bases(0) + WORD_LINE and col >= col_bases(0) and col < col_bases(0) + WORD_COL * letter_col(0) then
				if (col < col_bases(0) + WORD_COL) and letter_col(0) >= 1 then
					print_enable <= letras_atuais(0, 0)((line-line_bases(0)) * WORD_COL + ((col+2) mod WORD_COL));
				elsif (col < col_bases(0) + 2*WORD_COL) and letter_col(0) >= 2 then
					print_enable <= letras_atuais(0, 1)((line-line_bases(0)) * WORD_COL + ((col+2) mod WORD_COL));
				elsif (col < col_bases(0) + 3*WORD_COL) and letter_col(0) >= 3 then
					print_enable <= letras_atuais(0, 2)((line-line_bases(0)) * WORD_COL + ((col+2) mod WORD_COL));
				elsif (col < col_bases(0) + 4*WORD_COL) and letter_col(0) >= 4 then
					print_enable <= letras_atuais(0, 3)((line-line_bases(0)) * WORD_COL + ((col+2) mod WORD_COL));
				elsif (col < col_bases(0) + 5*WORD_COL) and letter_col(0) >= 5 then
					print_enable <= letras_atuais(0, 4)((line-line_bases(0)) * WORD_COL + ((col+2) mod WORD_COL));
				elsif (col < col_bases(0) + 6*WORD_COL) and letter_col(0) >= 6 then
					print_enable <= letras_atuais(0, 5)((line-line_bases(0)) * WORD_COL + ((col+2) mod WORD_COL));
				elsif (col < col_bases(0) + 7*WORD_COL) and letter_col(0) >= 7 then
					print_enable <= letras_atuais(0, 6)((line-line_bases(0)) * WORD_COL + ((col+2) mod WORD_COL));
				elsif (col < col_bases(0) + 8*WORD_COL) and letter_col(0) >= 8 then
					print_enable <= letras_atuais(0, 7)((line-line_bases(0)) * WORD_COL + ((col+2) mod WORD_COL));
				elsif (col < col_bases(0) + 9*WORD_COL) and letter_col(0) >= 9 then
					print_enable <= letras_atuais(0, 8)((line-line_bases(0)) * WORD_COL + ((col+2) mod WORD_COL));
				elsif (col < col_bases(0) + 10*WORD_COL) and letter_col(0) >= 10 then
					print_enable <= letras_atuais(0, 9)((line-line_bases(0)) * WORD_COL + ((col+2) mod WORD_COL));
				else
					print_enable <= '0';
				end if;
		  
				--print_enable <= alfa( ( palavras(0, (col - col_bases(0)) / WORD_COL) ) - 65);
		  elsif line >= line_bases(1) and line < line_bases(1) + WORD_LINE and col >= col_bases(1) and col < col_bases(1) + WORD_COL * letter_col(1) then
				if (col < col_bases(1) + WORD_COL) and letter_col(1) >= 1 then
					print_enable <= letras_atuais(1, 0)((line-line_bases(1)) * WORD_COL + ((col+1) mod WORD_COL));
				elsif (col < col_bases(1) + 2*WORD_COL) and letter_col(1) >= 2 then
					print_enable <= letras_atuais(1, 1)((line-line_bases(1)) * WORD_COL + ((col+1) mod WORD_COL));
				elsif (col < col_bases(1) + 3*WORD_COL) and letter_col(1) >= 3 then
					print_enable <= letras_atuais(1, 2)((line-line_bases(1)) * WORD_COL + ((col+1) mod WORD_COL));
				elsif (col < col_bases(1) + 4*WORD_COL) and letter_col(1) >= 4 then
					print_enable <= letras_atuais(1, 3)((line-line_bases(1)) * WORD_COL + ((col+1) mod WORD_COL));
				elsif (col < col_bases(1) + 5*WORD_COL) and letter_col(1) >= 5 then
					print_enable <= letras_atuais(1, 4)((line-line_bases(1)) * WORD_COL + ((col+1) mod WORD_COL));
				elsif (col < col_bases(1) + 6*WORD_COL) and letter_col(1) >= 6 then
					print_enable <= letras_atuais(1, 5)((line-line_bases(1)) * WORD_COL + ((col+1) mod WORD_COL));
				elsif (col < col_bases(1) + 7*WORD_COL) and letter_col(1) >= 7 then
					print_enable <= letras_atuais(1, 6)((line-line_bases(1)) * WORD_COL + ((col+1) mod WORD_COL));
				elsif (col < col_bases(1) + 8*WORD_COL) and letter_col(1) >= 8 then
					print_enable <= letras_atuais(1, 7)((line-line_bases(1)) * WORD_COL + ((col+1) mod WORD_COL));
				elsif (col < col_bases(1) + 9*WORD_COL) and letter_col(1) >= 9 then
					print_enable <= letras_atuais(1, 8)((line-line_bases(1)) * WORD_COL + ((col+1) mod WORD_COL));
				elsif (col < col_bases(1) + 10*WORD_COL) and letter_col(1) >= 10 then
					print_enable <= letras_atuais(1, 9)((line-line_bases(1)) * WORD_COL + ((col+1) mod WORD_COL));
				else
					print_enable<= '0';
				end if;
		  elsif line >= line_bases(2) and line < line_bases(2) + WORD_LINE and col >= col_bases(2) and col < col_bases(2) + WORD_COL * letter_col(2) then
				if (col < col_bases(2) + WORD_COL) and letter_col(2) >= 1 then
					print_enable <= letras_atuais(2, 0)((line-line_bases(2)) * WORD_COL + (col mod WORD_COL));
				elsif (col < col_bases(2) + 2*WORD_COL) and letter_col(2) >= 2 then
					print_enable <= letras_atuais(2, 1)((line-line_bases(2)) * WORD_COL + (col mod WORD_COL));
				elsif (col < col_bases(2) + 3*WORD_COL) and letter_col(2) >= 3 then
					print_enable <= letras_atuais(2, 2)((line-line_bases(2)) * WORD_COL + (col mod WORD_COL));
				elsif (col < col_bases(2) + 4*WORD_COL) and letter_col(2) >= 4 then
					print_enable <= letras_atuais(2, 3)((line-line_bases(2)) * WORD_COL + (col mod WORD_COL));
				elsif (col < col_bases(2) + 5*WORD_COL) and letter_col(2) >= 5 then
					print_enable <= letras_atuais(2, 4)((line-line_bases(2)) * WORD_COL + (col mod WORD_COL));
				elsif (col < col_bases(2) + 6*WORD_COL) and letter_col(2) >= 6 then
					print_enable <= letras_atuais(2, 5)((line-line_bases(2)) * WORD_COL + (col mod WORD_COL));
				elsif (col < col_bases(2) + 7*WORD_COL) and letter_col(2) >= 7 then
					print_enable <= letras_atuais(2, 6)((line-line_bases(2)) * WORD_COL + (col mod WORD_COL));
				elsif (col < col_bases(2) + 8*WORD_COL) and letter_col(2) >= 8 then
					print_enable <= letras_atuais(2, 7)((line-line_bases(2)) * WORD_COL + (col mod WORD_COL));
				elsif (col < col_bases(2) + 9*WORD_COL) and letter_col(2) >= 9 then
					print_enable <= letras_atuais(2, 8)((line-line_bases(2)) * WORD_COL + (col mod WORD_COL));
				elsif (col < col_bases(2) + 10*WORD_COL) and letter_col(2) >= 10 then
					print_enable <= letras_atuais(2, 9)((line-line_bases(2)) * WORD_COL + (col mod WORD_COL));
				else
					print_enable <= '0';
				end if;
		  elsif line >= line_bases(3) and line < line_bases(3) + WORD_LINE and col >= col_bases(3) and col < col_bases(3) + WORD_COL * letter_col(3) then
				if (col < col_bases(3) + WORD_COL) and letter_col(3) >= 1 then
					print_enable <= letras_atuais(3, 0)((line-line_bases(3)) * WORD_COL + (col mod WORD_COL));
				elsif (col < col_bases(3) + 2*WORD_COL) and letter_col(3) >= 2 then
					print_enable <= letras_atuais(3, 1)((line-line_bases(3)) * WORD_COL + (col mod WORD_COL));
				elsif (col < col_bases(3) + 3*WORD_COL) and letter_col(3) >= 3 then
					print_enable <= letras_atuais(3, 2)((line-line_bases(3)) * WORD_COL + (col mod WORD_COL));
				elsif (col < col_bases(3) + 4*WORD_COL) and letter_col(3) >= 4 then
					print_enable <= letras_atuais(3, 3)((line-line_bases(3)) * WORD_COL + (col mod WORD_COL));
				elsif (col < col_bases(3) + 5*WORD_COL) and letter_col(3) >= 5 then
					print_enable <= letras_atuais(3, 4)((line-line_bases(3)) * WORD_COL + (col mod WORD_COL));
				elsif (col < col_bases(3) + 6*WORD_COL) and letter_col(3) >= 6 then
					print_enable <= letras_atuais(3, 5)((line-line_bases(3)) * WORD_COL + (col mod WORD_COL));
				elsif (col < col_bases(3) + 7*WORD_COL) and letter_col(3) >= 7 then
					print_enable <= letras_atuais(3, 6)((line-line_bases(3)) * WORD_COL + (col mod WORD_COL));
				elsif (col < col_bases(3) + 8*WORD_COL) and letter_col(3) >= 8 then
					print_enable <= letras_atuais(3, 7)((line-line_bases(3)) * WORD_COL + (col mod WORD_COL));
				elsif (col < col_bases(3) + 9*WORD_COL) and letter_col(3) >= 9 then
					print_enable <= letras_atuais(3, 8)((line-line_bases(3)) * WORD_COL + (col mod WORD_COL));
				elsif (col < col_bases(3) + 10*WORD_COL) and letter_col(3) >= 10 then
					print_enable <= letras_atuais(3, 9)((line-line_bases(3)) * WORD_COL + (col mod WORD_COL));
				else
					print_enable <= '0';
				end if;
		  elsif line >= line_bases(4) and line < line_bases(4) + WORD_LINE and col >= col_bases(4) and col < col_bases(4) + WORD_COL * letter_col(4) then
				if (col < col_bases(4) + WORD_COL) and letter_col(4) >= 1 then
					print_enable <= letras_atuais(4, 0)((line-line_bases(4)) * WORD_COL + ((col-1) mod WORD_COL));	
				elsif (col < col_bases(4) + 2*WORD_COL) and letter_col(4) >= 2 then
					print_enable <= letras_atuais(4, 1)((line-line_bases(4)) * WORD_COL + ((col-1) mod WORD_COL));
				elsif (col < col_bases(4) + 3*WORD_COL) and letter_col(4) >= 3 then
					print_enable <= letras_atuais(4, 2)((line-line_bases(4)) * WORD_COL + ((col-1) mod WORD_COL));
				elsif (col < col_bases(4) + 4*WORD_COL) and letter_col(4) >= 4 then
					print_enable <= letras_atuais(4, 3)((line-line_bases(4)) * WORD_COL + ((col-1) mod WORD_COL));
				elsif (col < col_bases(4) + 5*WORD_COL) and letter_col(4) >= 5 then
					print_enable <= letras_atuais(4, 4)((line-line_bases(4)) * WORD_COL + ((col-1) mod WORD_COL));
				elsif (col < col_bases(4) + 6*WORD_COL) and letter_col(4) >= 6 then
					print_enable <= letras_atuais(4, 5)((line-line_bases(4)) * WORD_COL + ((col-1) mod WORD_COL));
				elsif (col < col_bases(4) + 7*WORD_COL) and letter_col(4) >= 7 then
					print_enable <= letras_atuais(4, 6)((line-line_bases(4)) * WORD_COL + ((col-1) mod WORD_COL));
				elsif (col < col_bases(4) + 8*WORD_COL) and letter_col(4) >= 8 then
					print_enable <= letras_atuais(4, 7)((line-line_bases(4)) * WORD_COL + ((col-1) mod WORD_COL));
				elsif (col < col_bases(4) + 9*WORD_COL) and letter_col(4) >= 9 then
					print_enable <= letras_atuais(4, 8)((line-line_bases(4)) * WORD_COL + ((col-1) mod WORD_COL));
				elsif (col < col_bases(4) + 10*WORD_COL) and letter_col(4) >= 10 then
					print_enable <= letras_atuais(4, 9)((line-line_bases(4)) * WORD_COL + ((col-1) mod WORD_COL));
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
		if atualiza_pos_y = '1' then
			if line_bases(0) >= 467 or line_bases(1) >= 467 or line_bases(2) >= 467 or line_bases(3) >= 467 or line_bases (4) >= 467 then
            --GAME_OVER <= '1';
				line_bases(0) <= 10;
				line_bases(1) <= 10;
				line_bases(2) <= 10; 
				line_bases(3) <= 10;
				line_bases(4) <= 10; 
			else
            --GAME_OVER <= '0';
				line_bases(0) <= line_bases(0) + 1;
				line_bases(1) <= line_bases(1) + 1;
				line_bases(2) <= line_bases(2) + 1;
				line_bases(3) <= line_bases(3) + 1;
				line_bases(4) <= line_bases(4) + 1;
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
		  if inic_limpa = '1' then
				pixel <= "000";
        elsif print_enable = '1' and inic_splash = '0' then
				if col >= col_bases(0) and col < col_bases(0) + letter_col(0) * WORD_COL and indice = 0 then
					pixel <= "101";
				elsif col >= col_bases(1) and col < col_bases(1) + letter_col(1) * WORD_COL and indice = 1 then
					pixel <= "101";
				elsif col >= col_bases(2) and col < col_bases(2) + letter_col(2) * WORD_COL and indice = 2 then
					pixel <= "101";
				elsif col >= col_bases(3) and col < col_bases(3) + letter_col(3) * WORD_COL and indice = 3 then
					pixel <= "101";
				elsif col >= col_bases(4) and col < col_bases(4) + letter_col(4) * WORD_COL and indice = 4 then
					pixel <= "101";
				else
					pixel <= "111";
				end if;
			elsif inic_splash = '1' then
				pixel <= tela_inicial( line + col*NUM_LINE);
			elsif print_enable = '0' then
				pixel <= "000";
			end if;
		  -- O endereço de memória pode ser construído com essa fórmula simples,
		  -- a partir da linha e coluna atual
		  addr  <= col + (NUM_COL * line);   
    end if;
  end process troca_letra_atual;

	letras_atuais(0, 0) <= alfa ( (palavras(0)(0) - 65) );
	letras_atuais(0, 1) <= alfa ( (palavras(0)(1) - 65) );
	letras_atuais(0, 2) <= alfa ( (palavras(0)(2) - 65) );
	letras_atuais(0, 3) <= alfa ( (palavras(0)(3) - 65) );
	letras_atuais(0, 4) <= alfa ( (palavras(0)(4) - 65) );
	letras_atuais(0, 5) <= alfa ( (palavras(0)(5) - 65) );
	letras_atuais(0, 6) <= alfa ( (palavras(0)(6) - 65) );
	letras_atuais(0, 7) <= alfa ( (palavras(0)(7) - 65) );
	letras_atuais(0, 8) <= alfa ( (palavras(0)(8) - 65) );
	letras_atuais(0, 9) <= alfa ( (palavras(0)(9) - 65) );
	letras_atuais(1, 0) <= alfa ( (palavras(1)(0) - 65) );
	letras_atuais(1, 1) <= alfa ( (palavras(1)(1) - 65) );
	letras_atuais(1, 2) <= alfa ( (palavras(1)(2) - 65) );
	letras_atuais(1, 3) <= alfa ( (palavras(1)(3) - 65) );
	letras_atuais(1, 4) <= alfa ( (palavras(1)(4) - 65) );
	letras_atuais(1, 5) <= alfa ( (palavras(1)(5) - 65) );
	letras_atuais(1, 6) <= alfa ( (palavras(1)(6) - 65) );
	letras_atuais(1, 7) <= alfa ( (palavras(1)(7) - 65) );
	letras_atuais(1, 8) <= alfa ( (palavras(1)(8) - 65) );
	letras_atuais(1, 9) <= alfa ( (palavras(1)(9) - 65) );
	letras_atuais(2, 0) <= alfa ( (palavras(2)(0) - 65) );
	letras_atuais(2, 1) <= alfa ( (palavras(2)(1) - 65) );
	letras_atuais(2, 2) <= alfa ( (palavras(2)(2) - 65) );
	letras_atuais(2, 3) <= alfa ( (palavras(2)(3) - 65) );
	letras_atuais(2, 4) <= alfa ( (palavras(2)(4) - 65) );
	letras_atuais(2, 5) <= alfa ( (palavras(2)(5) - 65) );
	letras_atuais(2, 6) <= alfa ( (palavras(2)(6) - 65) );
	letras_atuais(2, 7) <= alfa ( (palavras(2)(7) - 65) );
	letras_atuais(2, 8) <= alfa ( (palavras(2)(8) - 65) );
	letras_atuais(2, 9) <= alfa ( (palavras(2)(9) - 65) );
	letras_atuais(3, 0) <= alfa ( (palavras(3)(0) - 65) );
	letras_atuais(3, 1) <= alfa ( (palavras(3)(1) - 65) );
	letras_atuais(3, 2) <= alfa ( (palavras(3)(2) - 65) );
	letras_atuais(3, 3) <= alfa ( (palavras(3)(3) - 65) );
	letras_atuais(3, 4) <= alfa ( (palavras(3)(4) - 65) );
	letras_atuais(3, 5) <= alfa ( (palavras(3)(5) - 65) );
	letras_atuais(3, 6) <= alfa ( (palavras(3)(6) - 65) );
	letras_atuais(3, 7) <= alfa ( (palavras(3)(7) - 65) );
	letras_atuais(3, 8) <= alfa ( (palavras(3)(8) - 65) );
	letras_atuais(3, 9) <= alfa ( (palavras(3)(9) - 65) );
	letras_atuais(4, 0) <= alfa ( (palavras(4)(0) - 65) );
	letras_atuais(4, 1) <= alfa ( (palavras(4)(1) - 65) );
	letras_atuais(4, 2) <= alfa ( (palavras(4)(2) - 65) );
	letras_atuais(4, 3) <= alfa ( (palavras(4)(3) - 65) );
	letras_atuais(4, 4) <= alfa ( (palavras(4)(4) - 65) );
	letras_atuais(4, 5) <= alfa ( (palavras(4)(5) - 65) );
	letras_atuais(4, 6) <= alfa ( (palavras(4)(6) - 65) );
	letras_atuais(4, 7) <= alfa ( (palavras(4)(7) - 65) );
	letras_atuais(4, 8) <= alfa ( (palavras(4)(8) - 65) );
	letras_atuais(4, 9) <= alfa ( (palavras(4)(9) - 65) );
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
      if col_enable = '1' or col_splash = '1' then
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
      if (line_enable = '1' or line_splash = '1' ) and col = NUM_COL-1 then
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

  -- purpose: Esta é a lógica combinacional que calcula sinais de saída a partir
  --          do estado atual e alguns sinais de entrada (Máquina de Mealy).
  -- type   : combinational
  -- inputs : estado, fim_escrita, timer
  -- outputs: proximo_estado, atualiza_pos_y, line_rstn,
  --          line_enable, col_rstn, col_enable, we, timer_enable, timer_rstn
  logica_mealy: process (estado, fim_escrita, timer, my_play, ja_limpei)
  begin  -- process logica_mealy
	 inic_limpa 	  <= '0';
    case estado is
      when inicio         => if timer = '1' and my_play = '1' and ja_limpei = '0' then              
                               proximo_estado <= limpa_tela;
										 ja_limpei <= '1';
									  elsif timer = '1' and my_play = '1' then
									    proximo_estado <= constroi_quadro;
									  elsif timer ='1' and my_play = '0' then
										 proximo_estado <= show_splash;
                             else
                               proximo_estado <= inicio;
                             end if;
                             atualiza_pos_y <= '0';
                             line_rstn      <= '0';  -- reset é active low!
                             line_enable    <= '0';
                             col_rstn       <= '0';  -- reset é active low!
                             col_enable     <= '0';
									  line_splash    <= '0';
									  col_splash     <= '0';
                             we             <= '0';
                             timer_rstn     <= '1';  -- reset é active low!
                             timer_enable   <= '1';
									  inic_splash    <= '0';
									  inic_limpa 	  <= '0';

									  LEDR <= "00001";

      when constroi_quadro=> if fim_escrita = '1' then
                               proximo_estado <= desce_palavras;
                             else
                               proximo_estado <= constroi_quadro;
                             end if;
                             atualiza_pos_y <= '0';
                             line_rstn      <= '1';
                             line_enable    <= '1';
                             col_rstn       <= '1';
                             col_enable     <= '1';
									  line_splash    <= '0';
									  col_splash     <= '0';
                             we             <= '1';
                             timer_rstn     <= '0'; 
                             timer_enable   <= '0';
									  inic_splash    <= '0';
									  inic_limpa 	  <= '0';
									  inic_limpa 	  <= '0';
									  LEDR <= "00010";


      when desce_palavras => proximo_estado <= inicio;
                             atualiza_pos_y <= '1';
                             line_rstn      <= '1';
                             line_enable    <= '0';
                             col_rstn       <= '1';
                             col_enable     <= '0';
                             line_splash    <= '0';
									  col_splash     <= '0';
									  we             <= '0';
                             timer_rstn     <= '0'; 
                             timer_enable   <= '0';
									  inic_splash     <= '0';
									  inic_limpa 	  <= '0';
									  inic_limpa 	  <= '0';
									  LEDR <= "00100";


      when show_splash    => if fim_escrita = '1' then
											proximo_estado <= inicio;
									  else
											proximo_estado <= show_splash;
									  end if;
                             atualiza_pos_y <= '0';
                             line_rstn      <= '1';
                             line_enable    <= '0';
                             col_rstn       <= '1';
                             col_enable     <= '0';
									  line_splash    <= '1';
									  col_splash     <= '1';
                             we             <= '1';
                             timer_rstn     <= '0'; 
                             timer_enable   <= '0';
									  inic_splash    <= '1';
									  inic_limpa 	  <= '0';

									  LEDR <= "01000";
									  
		 when OTHERS        => if fim_escrita = '1' then
											proximo_estado <= inicio;
											ja_limpei <= '1';
									  else
											proximo_estado <= limpa_tela;
									  end if;
									  ja_limpei <= '1';
                             atualiza_pos_y <= '0';
                             line_rstn      <= '1';
                             line_enable    <= '1';
                             col_rstn       <= '1';
                             col_enable     <= '1';
									  line_splash    <= '0';
									  col_splash     <= '0';
                             we             <= '1';
                             timer_rstn     <= '0'; 
                             timer_enable   <= '0';
									  inic_splash    <= '0';
									  inic_limpa 	  <= '1';
									  LEDR <= "10000";
		

    end case;
  end process logica_mealy;
  
  -- purpose: Avança a FSM para o próximo estado
  -- type   : sequential
  -- inputs : CLOCK_50, rstn, proximo_estado
  -- outputs: estado
  seq_fsm: process (CLOCK_50, rstn)
  begin  -- process seq_fsm
    if rstn = '0' then                  -- asynchronous reset (active low)
      estado <= inicio;
    elsif CLOCK_50'event and CLOCK_50 = '1' then  -- rising clock edge
      estado <= proximo_estado;
    end if;
  end process seq_fsm;

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
        if contador = 1250000 - 1 then
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
    if contador = 1250000 - 1 then
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
		temp := KEY(0);
    end if;
  end process build_rstn;
  
  start_button : process (CLOCK_50)
  begin
		if CLOCK_50'event and CLOCK_50 = '1' then
			my_play <= my_play or not(KEY(1));
		end if;
	end process start_button;
end comportamento;


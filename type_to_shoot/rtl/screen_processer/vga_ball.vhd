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
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.main_pack.all;

entity vga_ball is
	generic (
		NUM_LINE : integer := 480;
		NUM_COL : integer := 640;
		WORD_LINE : integer := 16;
		WORD_COL : integer := 8
	);
  port (    
    CLOCK_50                : in std_logic;
    KEY                     : in std_logic;
		START_GAME							: in std_logic;
		STAGE_END								: in std_logic;
		PLAY_AGAIN							: in std_logic;
		NEW_WORD								: in word;
		NEW_WORD_SIZE						: in integer;
		LOCKED_WORD							: in word;
		LETTER_HIT							: in std_logic;
		WORD_DESTROYED					: in std_logic;
    VGA_R, VGA_G, VGA_B     : out std_logic_vector(7 downto 0);
    VGA_HS, VGA_VS          : out std_logic;
    VGA_BLANK_N, VGA_SYNC_N	: out std_logic;
    VGA_CLK                 : out std_logic;
		TIMER										: out std_logic;
		GAME_OVER								: out std_logic
    );
end vga_ball;

architecture comportamento of vga_ball is
  
  signal rstn : std_logic;              -- reset active low para nossos
                                        -- circuitos sequenciais.
  constant col_0 : integer := 5;
  constant col_1 : integer := 110;
  constant col_2 : integer := 215;
  constant col_3 : integer := 320;
  constant col_4 : integer := 425;
  constant col_5 : integer := 530;
  
  -- Interface com a memória de vídeo do controlador

  signal we : std_logic;                        -- write enable ('1' p/ escrita)
  signal addr : integer range 0 to NUM_LINE * NUM_COL - 1;       -- endereco mem. vga
  signal pixel : std_logic_vector(2 downto 0);  -- valor de cor do pixel
  signal pixel_bit : std_logic;                 -- um bit do vetor acima

  -- Sinais dos contadores de linhas e colunas utilizados para percorrer
  -- as posições da memória de vídeo (pixels) no momento de construir um quadro.
  
  signal line : integer range 0 to NUM_LINE-1;  -- linha atual
  signal col : integer range 0 to NUM_COL-1;  -- coluna atual
  signal col_d : integer range 0 to NUM_COL-1;  -- coluna atual

  signal col_rstn : std_logic;          -- reset do contador de colunas
  signal col_enable : std_logic;        -- enable do contador de colunas

  signal line_rstn : std_logic;          -- reset do contador de linhas
  signal line_enable : std_logic;        -- enable do contador de linhas

  signal fim_escrita : std_logic;       -- '1' quando um quadro terminou de ser
                                        -- escrito na memória de vídeo

  -- Sinais que armazem a posição de uma bola, que deverá ser desenhada
  -- na tela de acordo com sua posição.

  signal pos_x : integer range 0 to NUM_COL-1;  -- coluna atual da bola
  signal pos_y : integer range 0 to NUM_LINE-1;   -- linha atual da bola

  signal atualiza_pos_x : std_logic;    -- se '1' = bola muda sua pos. no eixo x
  signal atualiza_pos_y : std_logic;    -- se '1' = bola muda sua pos. no eixo y

  -- Especificação dos tipos e sinais da máquina de estados de controle
  type estado_t is (show_splash, inicio, constroi_quadro, move_bola);
  signal estado: estado_t := show_splash;
  signal proximo_estado: estado_t := show_splash;

  -- Sinais para um contador utilizado para atrasar a atualização da
  -- posição da bola, a fim de evitar que a animação fique excessivamente
  -- veloz. Aqui utilizamos um contador de 0 a 1250000, de modo que quando
  -- alimentado com um clock de 50MHz, ele demore 25ms (40fps) para contar até o final.
  
  signal contador : integer range 0 to 1250000 - 1;  -- contador
  signal timer_aux : std_logic;        -- vale '1' quando o contador chegar ao fim
  signal timer_rstn, timer_enable : std_logic;
  
  signal sync, blank: std_logic;

  signal cor_atual : std_logic_vector(2 downto 0) := "001";
  signal limpa : std_logic := '0';
  signal inic : std_logic := '0';
	
  signal font_word: std_logic_vector(7 downto 0);
  signal rom_addr: std_logic_vector(10 downto 0);
  
  type size_5_array is array (0 to 5) of integer;
  
  signal line_bases : size_5_array := (20, 20, 20, 20, 20, 20);
  signal col_bases : size_5_array := (5, 110, 215, 320, 425, 530);

  signal letter_col : size_5_array := (1, 2, 3, 4, 5, 10);
  signal print_enable : std_logic := '0';
  
  signal att_col : std_logic := '0';
  
  signal letra_A : std_logic_vector(0 to WORD_COL * WORD_LINE - 1 ) := (
   "00000000000000000001000000111000011011001100011011000110111111101100011011000110110001101100011000000000000000000000000000000000");
  signal letra_B : std_logic_vector(0 to WORD_COL * WORD_LINE - 1 ) := (  
   "00000000000000001111110001100110011001100110011001111100011001100110011001100110011001101111110000000000000000000000000000000000");
  signal letra_C : std_logic_vector(0 to WORD_COL * WORD_LINE - 1 ) := (  
   "00000000000000000011110001100110110000101100000011000000110000001100000011000010011001100011110000000000000000000000000000000000");
  signal letra_D : std_logic_vector(0 to WORD_COL * WORD_LINE - 1 ) := (
   "00000000000000001111100001101100011001100110011001100110011001100110011001100110011011001111100000000000000000000000000000000000");
  signal letra_E : std_logic_vector(0 to WORD_COL * WORD_LINE - 1 ) := (
   "00000000000000001111111001100110011000100110100001111000011010000110000001100010011001101111111000000000000000000000000000000000");
  signal letra_F : std_logic_vector(0 to WORD_COL * WORD_LINE - 1 ) := (
   "00000000000000001111111001100110011000100110100001111000011010000110000001100000011000001111000000000000000000000000000000000000");
  signal letra_G : std_logic_vector(0 to WORD_COL * WORD_LINE - 1 ) := (
   "00000000000000000011110001100110110000101100000011000000110111101100011011000110011001100011101000000000000000000000000000000000");
  signal letra_H : std_logic_vector(0 to WORD_COL * WORD_LINE - 1 ) := (
   "00000000000000001100011011000110110001101100011011111110110001101100011011000110110001101100011000000000000000000000000000000000");
  signal letra_I : std_logic_vector(0 to WORD_COL * WORD_LINE - 1 ) := ( 
   "00000000000000000011110000011000000110000001100000011000000110000001100000011000000110000011110000000000000000000000000000000000");
  signal letra_J : std_logic_vector(0 to WORD_COL * WORD_LINE - 1 ) := (
   "00000000000000000001111000001100000011000000110000001100000011001100110011001100110011000111100000000000000000000000000000000000");
  signal letra_K : std_logic_vector(0 to WORD_COL * WORD_LINE - 1 ) := ( 
   "00000000000000001110011001100110011001100110110001111000011110000110110001100110011001101110011000000000000000000000000000000000");
  signal letra_L : std_logic_vector(0 to WORD_COL * WORD_LINE - 1 ) := (
   "00000000000000001111000001100000011000000110000001100000011000000110000001100010011001101111111000000000000000000000000000000000");
  signal letra_M : std_logic_vector(0 to WORD_COL * WORD_LINE - 1 ) := (
   "00000000000000001100001111100111111111111111111111011011110000111100001111000011110000111100001100000000000000000000000000000000");
  signal letra_N : std_logic_vector(0 to WORD_COL * WORD_LINE - 1 ) := (
   "00000000000000001100011011100110111101101111111011011110110011101100011011000110110001101100011000000000000000000000000000000000");
  signal letra_O : std_logic_vector(0 to WORD_COL * WORD_LINE - 1 ) := ( 
   "00000000000000000111110011000110110001101100011011000110110001101100011011000110110001100111110000000000000000000000000000000000");
  signal letra_P : std_logic_vector(0 to WORD_COL * WORD_LINE - 1 ) := (
   "00000000000000001111110001100110011001100110011001111100011000000110000001100000011000001111000000000000000000000000000000000000");
  signal letra_Q : std_logic_vector(0 to WORD_COL * WORD_LINE - 1 ) := ( 
   "00000000000000000111110011000110110001101100011011000110110001101100011011010110110111100111110000001100000011100000000000000000");
  signal letra_R : std_logic_vector(0 to WORD_COL * WORD_LINE - 1 ) := ( 
   "00000000000000001111110001100110011001100110011001111100011011000110011001100110011001101110011000000000000000000000000000000000");
  signal letra_S : std_logic_vector(0 to WORD_COL * WORD_LINE - 1 ) := (  
   "00000000000000000111110011000110110001100110000000111000000011000000011011000110110001100111110000000000000000000000000000000000");
  signal letra_T : std_logic_vector(0 to WORD_COL * WORD_LINE - 1 ) := ( 
   "00000000000000001111111111011011100110010001100000011000000110000001100000011000000110000011110000000000000000000000000000000000");
  signal letra_U : std_logic_vector(0 to WORD_COL * WORD_LINE - 1 ) := ( 
   "00000000000000001100011011000110110001101100011011000110110001101100011011000110110001100111110000000000000000000000000000000000");
  signal letra_V : std_logic_vector(0 to WORD_COL * WORD_LINE - 1 ) := ( 
   "00000000000000001100001111000011110000111100001111000011110000111100001101100110001111000001100000000000000000000000000000000000");
  signal letra_W : std_logic_vector(0 to WORD_COL * WORD_LINE - 1 ) := (
   "00000000000000001100001111000011110000111100001111000011110110111101101111111111011001100110011000000000000000000000000000000000");
  signal letra_X : std_logic_vector(0 to WORD_COL * WORD_LINE - 1 ) := (
   "00000000000000001100001111000011011001100011110000011000000110000011110001100110110000111100001100000000000000000000000000000000");
  signal letra_Y : std_logic_vector(0 to WORD_COL * WORD_LINE - 1 ) := ( 
   "00000000000000001100001111000011110000110110011000111100000110000001100000011000000110000011110000000000000000000000000000000000");
  signal letra_Z : std_logic_vector(0 to WORD_COL * WORD_LINE - 1 ) := (
   "00000000000000001111111111000011100001100000110000011000001100000110000011000001110000111111111100000000000000000000000000000000");
	
  signal letra_atual : std_logic_vector(0 to WORD_COL * WORD_LINE - 1 ) := (
	"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000");

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
	 
	-- instantiate font ROM
   font_unit: entity work.font_rom  port map(
				 clk	=>		CLOCK_50,
				 addr	=>		rom_addr, 
				 data	=>		font_word);  
	
  -----------------------------------------------------------------------------
  -- PROCESS PARA PEDIR INFORMACOES DE FONT_ROM E IMPRIMIR NA TELA
  -----------------------------------------------------------------------------

  -- purpose: 
  -- type   : sequential
  -- inputs :
  -- outputs: 
  pega_linha: process (att_col)
  begin  -- process conta_coluna
    if att_col'event and att_col = '1' then  -- rising clock edge
		if line >= line_bases(0) and line <= line_bases(0) + WORD_LINE - 1 and (col + 1) >= col_bases(0) and (col + 1) <= col_bases(0) + WORD_COL* letter_col(0) -1 then
			print_enable <= letra_atual( (line-line_bases(0)) * WORD_COL + ((col + 1) mod WORD_COL) );
		elsif line >= line_bases(1) and line <= line_bases(1) + WORD_LINE - 1 and col >= col_bases(1) and col <= col_bases(1) + WORD_COL* letter_col(1) -1 then
			print_enable <= letra_atual( (line-line_bases(1)) * WORD_COL + (col mod WORD_COL) );
		elsif line >= line_bases(2) and line <= line_bases(2) + WORD_LINE - 1 and col >= col_bases(2) and col <= col_bases(2) + WORD_COL* letter_col(2) -1 then
			print_enable <= letra_atual( (line-line_bases(2)) * WORD_COL + (col mod WORD_COL) );
		elsif line >= line_bases(3) and line <= line_bases(3) + WORD_LINE - 1 and col >= col_bases(3) and col <= col_bases(3) + WORD_COL* letter_col(3) -1 then
			print_enable <= letra_atual( (line-line_bases(3)) * WORD_COL + (col mod WORD_COL) );
		elsif line >= line_bases(4) and line <= line_bases(4) + WORD_LINE - 1 and col >= col_bases(4) and col <= col_bases(4) + WORD_COL* letter_col(4) -1 then
			print_enable <= letra_atual( (line-line_bases(4)) * WORD_COL + (col mod WORD_COL) );
		elsif line >= line_bases(5) and line <= line_bases(5) + WORD_LINE - 1 and col >= col_bases(5) and col <= col_bases(5) + WORD_COL* letter_col(5) -1 then
			print_enable <= letra_atual( (line-line_bases(5)) * WORD_COL + (col mod WORD_COL) );	
		else
			print_enable <= '0';
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
		if atualiza_pos_x = '1' and atualiza_pos_y = '1' then
			if line_bases(0) = 470 then
				line_bases(0) <= 0;
				line_bases(1) <= 0;
				line_bases(2) <= 0;
				line_bases(3) <= 0;
				line_bases(4) <= 0;
				line_bases(5) <= 0;
			else
				line_bases(0) <= line_bases(0) + 1;
				line_bases(1) <= line_bases(1) + 1;
				line_bases(2) <= line_bases(2) + 1;
				line_bases(3) <= line_bases(3) + 1;
				line_bases(4) <= line_bases(4) + 1;
				line_bases(5) <= line_bases(5) + 1;
			end if;
			
		end if;
    end if;
  end process desce_linha;
  
   -----------------------------------------------------------------------------
  -- PROCESS RESPONSAVEL POR ALTERAR A LETRA ATUAL DEPENDENDO DE QUAL POSICAO ESTAMOS
  -----------------------------------------------------------------------------

  -- purpose: Este processo altera a letra atual dependendo de qual coluna estamos agora
  -- type   : 
  -- inputs : CLOCK_50, col_rstn
  -- outputs: col
  troca_letra_atual: process (CLOCK_50, col_rstn)
  begin  -- process conta_coluna
    if CLOCK_50'event and CLOCK_50 = '1' then  -- rising clock edge
      if col_enable = '1' then
        if col >= col_0 and col <= col_0 + WORD_COL * letter_col(0) then
				letra_atual <= letra_A;
		  elsif col >= col_1 and col <= col_1 + WORD_COL * letter_col(1) then
				letra_atual <= letra_B;
		  elsif col >= col_2 and col <= col_2 + WORD_COL * letter_col(2) then
				letra_atual <= letra_C;
		  elsif col >= col_3 and col <= col_3 + WORD_COL * letter_col(3) then
				letra_atual <= letra_D;
		  elsif col >= col_4 and col <= col_4 + WORD_COL * letter_col(4) then
				letra_atual <= letra_E;
		  elsif col >= col_5 and col <= col_5 + WORD_COL * letter_col(5) then
				letra_atual <= letra_F;
		  else
				letra_atual <= "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
		  end if;
      end if;
    end if;
  end process troca_letra_atual;
		  
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
		  att_col <= '1';
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
  fim_escrita <= '1' when (line = NUM_LINE-1) and (col = NUM_COL-1)
                 else '0'; 

  -----------------------------------------------------------------------------
  -- Abaixo estão processos relacionados com a atualização da posição da
  -- bola. Todos são controlados por sinais de enable de modo que a posição
  -- só é de fato atualizada quando o controle (uma máquina de estados)
  -- solicitar.
  -----------------------------------------------------------------------------

  -- purpose: Este processo irá atualizar a coluna atual da bola,
  --          alterando sua posição no próximo quadro a ser desenhado.
  -- type   : sequential
  -- inputs : CLOCK_50, rstn
  -- outputs: pos_x
--  p_atualiza_pos_x: process (CLOCK_50, rstn)
--    type direcao_t is (direita, esquerda);
--    variable direcao : direcao_t := direita;
--  begin  -- process p_atualiza_pos_x
--    if rstn = '0' then                  -- asynchronous reset (active low)
--      pos_x <= 0;
--    elsif CLOCK_50'event and CLOCK_50 = '1' then  -- rising clock edge
--      if atualiza_pos_x = '1' then
--        if direcao = direita then         
--          if pos_x = NUM_COL-1 then
--            direcao := esquerda;  
--          else
--            pos_x <= pos_x + 1;
--          end if;        
--        else  -- se a direcao é esquerda
--          if pos_x = 0 then
--            direcao := direita;
--          else
--            pos_x <= pos_x - 1;
--          end if;
--        end if;
--      end if;
--    end if;
--  end process p_atualiza_pos_x;

  -- purpose: Este processo irá atualizar a linha atual da bola,
  --          alterando sua posição no próximo quadro a ser desenhado.
  -- type   : sequential
  -- inputs : CLOCK_50, rstn
  -- outputs: pos_y
--  p_atualiza_pos_y: process (CLOCK_50, rstn)
--    type direcao_t is (desce, sobe);
--    variable direcao : direcao_t := desce;
--  begin  -- process p_atualiza_pos_x
--    if rstn = '0' then                  -- asynchronous reset (active low)
--      pos_y <= 0;
--    elsif CLOCK_50'event and CLOCK_50 = '1' then  -- rising clock edge
--      if atualiza_pos_y = '1' then
--        if direcao = desce then         
--          if pos_y = NUM_LINE-1 then
--            direcao := sobe;  
--          else
--            pos_y <= pos_y + 1;
--          end if;        
--        else  -- se a direcao é para subir
--          if pos_y = 0 then
--            direcao := desce;
--          else
--            pos_y <= pos_y - 1;
--          end if;
--        end if;
--      end if;
--    end if;
--  end process p_atualiza_pos_y;

  -----------------------------------------------------------------------------
  -- Brilho do pixel
  -----------------------------------------------------------------------------
  -- O brilho do pixel é branco quando os contadores deatualiza_pos_y linha e coluna, que
  -- indicam o endereço do pixel sendo escrito para o quadro atual, casam com a
  -- posição da bola (sinais pos_x e pos_y). Caso contrário,
  -- o pixel é preto.
--  
--  process(CLOCK_50)
--		variable na_quina : std_logic := '0';
--  begin
--		if CLOCK_50'event and CLOCK_50 = '1' then
--			if line = pos_y and col = pos_x then	
--				if inic = '1' then
--					cor_atual <= "001";			
--				elsif (line = NUM_LINE-1 or line = 0) and (col = NUM_COL-1 or col = 0) then
--					if na_quina = '0' then
--						na_quina := '1';
--						if cor_atual = "111" then 
--							cor_atual <= "010";	
--						elsif cor_atual = "110" then
--							cor_atual <= "001";
--						else
--							cor_atual <= cor_atual + "010";
--						end if;			
--					end if;
--				elsif (line = NUM_LINE-1 or line = 0 or col = NUM_COL-1 or col = 0) then
--					if na_quina = '0' then
--						na_quina := '1';
--						if cor_atual = "111" then 
--							cor_atual <= "001";				
--						else
--							cor_atual <= cor_atual + "001";
--						end if;			
--					end if;										
--				else
--					na_quina := '0';					
--				end if;
--			end if;
--		end if;
--  end process;
  
  process (CLOCK_50, rstn)
		variable temp: std_logic := '0';
  begin
    if rstn = '0' then  -- rising clock edge
		temp := '1';
		inic <= '1';
	 elsif CLOCK_50'event and CLOCK_50 = '1' then
		inic <= '0';
		 if fim_escrita = '1' then
			temp := '0';
		 end if;
	 end if;
	 limpa <= temp;
  end process;

--  pixel <= cor_atual when line = pos_y and col = pos_x and limpa = '0' else "000";
  pixel <= "111" when print_enable = '1' else "000";
  
  -- O endereço de memória pode ser construído com essa fórmula simples,
  -- a partir da linha e coluna atual
  addr  <= col + (NUM_COL * line);

  -----------------------------------------------------------------------------
  -- Processos que definem a FSM (finite state machine), nossa máquina
  -- de estados de controle.
  -----------------------------------------------------------------------------

  -- purpose: Esta é a lógica combinacional que calcula sinais de saída a partir
  --          do estado atual e alguns sinais de entrada (Máquina de Mealy).
  -- type   : combinational
  -- inputs : estado, fim_escrita, timer
  -- outputs: proximo_estado, atualiza_pos_x, atualiza_pos_y, line_rstn,
  --          line_enable, col_rstn, col_enable, we, timer_enable, timer_rstn
  logica_mealy: process (estado, fim_escrita, timer_aux)
  begin  -- process logica_mealy
    case estado is
      when inicio         => if timer_aux = '1' then
                               proximo_estado <= constroi_quadro;
                             else
                               proximo_estado <= inicio;
                             end if;
                             atualiza_pos_x <= '0';
                             atualiza_pos_y <= '0';
                             line_rstn      <= '0';  -- reset é active low!
                             line_enable    <= '0';
                             col_rstn       <= '0';  -- reset é active low!
                             col_enable     <= '0';
                             we             <= '0';
                             timer_rstn     <= '1';  -- reset é active low!
                             timer_enable   <= '1';

      when constroi_quadro=> if fim_escrita = '1' then
                               proximo_estado <= move_bola;
                             else
                               proximo_estado <= constroi_quadro;
                             end if;
                             atualiza_pos_x <= '0';
                             atualiza_pos_y <= '0';
                             line_rstn      <= '1';
                             line_enable    <= '1';
                             col_rstn       <= '1';
                             col_enable     <= '1';
                             we             <= '1';
                             timer_rstn     <= '0'; 
                             timer_enable   <= '0';

      when move_bola      => proximo_estado <= inicio;
                             atualiza_pos_x <= '1';
                             atualiza_pos_y <= '1';
                             line_rstn      <= '1';
                             line_enable    <= '0';
                             col_rstn       <= '1';
                             col_enable     <= '0';
                             we             <= '0';
                             timer_rstn     <= '0'; 
                             timer_enable   <= '0';

      when others         => proximo_estado <= inicio;
                             atualiza_pos_x <= '0';
                             atualiza_pos_y <= '0';
                             line_rstn      <= '1';
                             line_enable    <= '0';
                             col_rstn       <= '1';
                             col_enable     <= '0';
                             we             <= '0';
                             timer_rstn     <= '1'; 
                             timer_enable   <= '0';
      
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

  -- purpose: Calcula o sinal "timer" que indica quando o contador chegou ao tempo
  --          final
  -- type   : combinational
  -- inputs : contador
  -- outputs: timer
  p_timer: process (contador)
  begin  -- process p_timer
    if contador = 1250000 - 1 then
      timer_aux <= '1';
    else
      timer_aux <= '0';
    end if;
  end process p_timer;

	timer <= timer_aux;

  -----------------------------------------------------------------------------
  -- Processos que sincronizam sinais assíncronos, de preferência com mais
  -- de 1 flipflop, para evitar metaestabilidade.
  -----------------------------------------------------------------------------
  
  -- purpose: Aqui sincronizamos nosso sinal de reset vindo do botão da DE1
  -- type   : sequential
  -- inputs : CLOCK_50
  -- outputs: rstn
  build_rstn: process (CLOCK_50)
    variable temp : std_logic;          -- flipflop intermediario
  begin  -- process build_rstn
    if CLOCK_50'event and CLOCK_50 = '1' then  -- rising clock edge
      rstn <= temp;      
      temp := KEY;
    end if;
  end process build_rstn;

  
end comportamento;

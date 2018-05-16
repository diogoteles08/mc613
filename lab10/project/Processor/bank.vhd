library ieee;
use ieee.std_logic_1164.all;

entity bank is
  generic ( WORDSIZE: natural := 32 );
  port (
    WR_EN, RD_EN : in std_logic;
    clear : in std_logic;
    clock : in std_logic;
    WR_ADDR : in std_logic_vector(4 downto 0);
    RG_ADDR1 : in std_logic_vector(4 downto 0);
    RG_ADDR2 : in std_logic_vector(4 downto 0);
    DATA_IN : in std_logic_vector(WORDSIZE-1 downto 0);
    DATA_OUT1 : out std_logic_vector(WORDSIZE-1 downto 0);
    DATA_OUT2 : out std_logic_vector(WORDSIZE-1 downto 0)
-- todo: implementar DATA_OUT2
-- todo: implementar RG_ADDR2
-- todo: RD_EN nao ta implementado ainda
  );
end bank;

architecture structural of bank is
	component reg 
		generic (N : INTEGER := 4);
		port (
			clock : in std_logic;
			DATA_IN : in std_logic_vector(N-1 downto 0);
			DATA_OUT1 : out std_logic_vector(N-1 downto 0);
			load : in std_logic; --write enable
			clear : in std_logic
                    );
	end component;

-- todo: pou preciso da sua ajuda, esses generics tem que ir pra 5? e arrumar o
-- resto do codigo que muda junto com isso
	component zbuffer 
		generic (N : INTEGER := 4);
		port (
			enable: in std_logic;
			Xin: in std_logic_vector(N-1 downto 0);
			Xout: out std_logic_vector(N-1 downto 0)
		);
	end component;

	component dec3_to_8
		port (
			en: in std_logic;
			Xin: in std_logic_vector(2 downto 0);
			Xout: out std_logic_vector(7 downto 0)
		);
	end component;
	
	signal D2R: std_logic_vector(7 downto 0);
	signal R2D: std_logic_vector(7 downto 0);
	signal output_vector: std_logic_vector (8*4 downto 0);
begin
	
        inputSelection: dec3_to_8 port map (
		en => '1',
		Xin => WR_ADDR,
		Xout => D2R
	);	
	outputSelection: dec3_to_8 port map (
		en => '1',
		Xin => RG_ADDR1,
		Xout => R2D
	);
	
	create_regs: for i in 0 to 7 generate
		regis: reg port map (
			clock => clock,
			DATA_IN => DATA_IN,
			DATA_OUT1 => output_vector(i*4+3 downto i*4),
			load => WR_EN and D2R(i),
			clear => clear
		);
	end generate;
	
	filter_output: for i in 0 to 7 generate
		buffer_t_state: zbuffer port map (
			enable => R2D(i),
			Xin => output_vector(i*4+3 downto i*4),
			Xout => DATA_OUT1
		);
	end generate;
end structural;

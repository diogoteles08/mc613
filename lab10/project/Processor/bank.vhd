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
  );
end bank;

architecture structural of bank is
	component reg 
		generic (N : INTEGER := WORDSIZE);
		port (
			clock : in std_logic;
			DATA_IN : in std_logic_vector(N-1 downto 0);
			DATA_OUT : out std_logic_vector(N-1 downto 0);
			load : in std_logic; --write enable
			readEn : in std_logic;
			clear : in std_logic
      );
	end component;

	component zbuffer 
		generic (N : INTEGER := WORDSIZE);
		port (
			enable: in std_logic;
			Xin: in std_logic_vector(N-1 downto 0);
			Xout: out std_logic_vector(N-1 downto 0)
		);
	end component;

	component dec5_to_32
		port (
			en: in std_logic;
			Xin: in std_logic_vector(4 downto 0);
			Xout: out std_logic_vector(31 downto 0)
		);
	end component;
	
	signal writeAddressDecoded: std_logic_vector(31 downto 0);
	signal readAddress1Decoded: std_logic_vector(31 downto 0);
	signal readAddress2Decoded: std_logic_vector(31 downto 0);
	signal output_vector1: std_logic_vector (WORDSIZE*32 downto 0);
	signal output_vector2: std_logic_vector (WORDSIZE*32 downto 0);
begin
	
   inputSelection: dec5_to_32 port map (
		en => '1',
		Xin => WR_ADDR,
		Xout => writeAddressDecoded
	);	
	
	outputSelection1: dec5_to_32 port map (
		en => '1',
		Xin => RG_ADDR1,
		Xout => readAddress1Decoded
	);
	
	outputSelection2: dec5_to_32 port map (
		en => '1',
		Xin => RG_ADDR2,
		Xout => readAddress2Decoded
	);
	
	
	

	create_regs: for i in 1 to 31 generate
		regis: reg port map (
			clock => clock,
			DATA_IN => DATA_IN,
			DATA_OUT => output_vector1(i*4+31 downto i*4),
			load => WR_EN and writeAddressDecoded(i),
			readEn => RD_EN and readAddress1Decoded(i),
			clear => clear
		);
	end generate;
	
	create_regs: for i in 1 to 31 generate
		regis: reg port map (
			clock => clock,
			DATA_IN => open,
			DATA_OUT => output_vector2(i*4+31 downto i*4),
			load => '0',
			readEn => RD_EN and readAddress2Decoded(i),
			clear => clear
		);
	end generate;
	
	filter_output: for i in 0 to 7 generate
		buffer_t_state: zbuffer port map (
			enable => readAddress1Decoded(i),
			Xin => output_vector1(i*4+3 downto i*4),
			Xout => DATA_OUT1
		);
	end generate;
	
	filter_output: for i in 0 to 7 generate
		buffer_t_state: zbuffer port map (
			enable => readAddress2Decoded(i),
			Xin => output_vector2(i*4+3 downto i*4),
			Xout => DATA_OUT2
		);
	end generate;
end structural;

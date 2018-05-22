library ieee;
use ieee.std_logic_1164.all;

entity bank is
  generic ( WORDSIZE: natural := 32 );
  port (
    WR_EN, RD_EN : in std_logic;
    clear : in std_logic;
    clock : in std_logic;
    WR_ADDR : in std_logic_vector(4 downto 0);
    RD_ADDR1 : in std_logic_vector(4 downto 0);
    RD_ADDR2 : in std_logic_vector(4 downto 0);
    DATA_IN : in std_logic_vector(WORDSIZE-1 downto 0);
    DATA_OUT1 : out std_logic_vector(WORDSIZE-1 downto 0);
    DATA_OUT2 : out std_logic_vector(WORDSIZE-1 downto 0)
  );
end bank;

architecture structural of bank is
	component reg 
		generic (WORDSIZE : INTEGER := WORDSIZE);
		port (
			clock : in std_logic;
			datain : in std_logic_vector(WORDSIZE-1 downto 0);
			dataout : out std_logic_vector(WORDSIZE-1 downto 0);
			load : in std_logic; --write enable
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
	signal out_aux1: std_logic_vector(WORDSIZE-1 downto 0);
	signal out_aux2: std_logic_vector(WORDSIZE-1 downto 0);
	signal reg_values_vector: std_logic_vector (WORDSIZE*32 downto 0);
begin
	
   inputSelection: dec5_to_32 port map (
		en => '1',
		Xin => WR_ADDR,
		Xout => writeAddressDecoded
	);	
	
	outputSelection1: dec5_to_32 port map (
		en => '1',
		Xin => RD_ADDR1,
		Xout => readAddress1Decoded
	);
	
	outputSelection2: dec5_to_32 port map (
		en => '1',
		Xin => RD_ADDR2,
		Xout => readAddress2Decoded
	);		

	create_regs1: for i in 0 to 31 generate
		creating_registers: reg 
                        port map (
			clock => clock,
			datain => DATA_IN,
			dataout => reg_values_vector(i*WORDSIZE+31 downto i*WORDSIZE),
			load => WR_EN and writeAddressDecoded(i),			
			clear => clear
		);
	end generate;	
	
	filter_output1: for i in 1 to 31 generate
		buffer_t_state1: zbuffer port map (
			enable => RD_EN and readAddress1Decoded(i),
			Xin => reg_values_vector(i*WORDSIZE+31 downto i*WORDSIZE),
			Xout => DATA_OUT1
		);
	end generate;
	
	filter_output2: for i in 1 to 31 generate
		buffer_t_state2: zbuffer port map (
			enable => RD_EN and readAddress2Decoded(i),
			Xin => reg_values_vector(i*WORDSIZE+31 downto i*WORDSIZE),
			Xout => DATA_OUT2
		);
	end generate;
	
	buffer_t_state_r0_1: zbuffer port map (
		enable => RD_EN and readAddress1Decoded(0),
		Xin => (others => '0'),
		Xout => DATA_OUT1
	);
	
	buffer_t_state_r0_2: zbuffer port map (
		enable => RD_EN and readAddress2Decoded(0),
		Xin => (others => '0'),
		Xout => DATA_OUT2
	);
	
end structural;

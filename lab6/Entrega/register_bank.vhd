library ieee;
use ieee.std_logic_1164.all;

entity register_bank is
  port (
    clk : in std_logic;
    data_in : in std_logic_vector(3 downto 0);
    data_out : out std_logic_vector(3 downto 0);
    reg_rd : in std_logic_vector(2 downto 0);
    reg_wr : in std_logic_vector(2 downto 0);
    we : in std_logic;
    clear : in std_logic
  );
end register_bank;

architecture structural of register_bank is
	component reg 
		generic (N : INTEGER := 4);
		port (
			clk : in std_logic;
			data_in : in std_logic_vector(N-1 downto 0);
			data_out : out std_logic_vector(N-1 downto 0);
			load : in std_logic; --write enable
			clear : in std_logic
		);
	end component;

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
		Xin => reg_wr,
		Xout => D2R
	);	
	outputSelection: dec3_to_8 port map (
		en => '1',
		Xin => reg_rd,
		Xout => R2D
	);
	
	create_regs: for i in 0 to 7 generate
		regis: reg port map (
			clk => clk,
			data_in => data_in,
			data_out => output_vector(i*4+3 downto i*4),
			load => we and D2R(i),
			clear => clear
		);
	end generate;
	
	filter_output: for i in 0 to 7 generate
		buffer_t_state: zbuffer port map (
			enable => R2D(i),
			Xin => output_vector(i*4+3 downto i*4),
			Xout => data_out
		);
	end generate;
end structural;

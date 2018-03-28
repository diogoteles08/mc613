library ieee;
use ieee.std_logic_1164.all;

entity alu_board is
  port (
    SW : in std_logic_vector(9 downto 0);
    HEX5, HEX4, HEX3, HEX2, HEX1, HEX0 : out std_logic_vector(6 downto 0);
    LEDR : out std_logic_vector(3 downto 0)
  );
end alu_board;

architecture behavioral of alu_board is

	signal a_aux : std_logic_vector(3 downto 0);
	signal b_aux : std_logic_vector(3 downto 0);
	signal f_aux : std_logic_vector(3 downto 0);
	signal a_aux1 : std_logic_vector(3 downto 0);
	signal b_aux2 : std_logic_vector(3 downto 0);
	signal f_aux1 : std_Logic_vector(3 downto 0);
	signal neg_aux: std_logic_vector(2 downto 0);
	signal HEX4_aux : std_logic_vector(6 downto 0);
	signal HEX2_aux : std_logic_vector(6 downto 0);
	signal HEX0_aux : std_logic_vector(6 downto 0);
	signal HEX4_aux1 : std_logic_vector(6 downto 0);
	signal HEX2_aux1 : std_logic_vector(6 downto 0);
	signal HEX0_aux1 : std_logic_vector(6 downto 0);
	signal oper : std_logic_vector(1 downto 0);
	signal is_neg: std_logic_vector(6 downto 0);
	signal not_neg: std_logic_vector(6 downto 0);
	signal true_neg : std_logic_vector(6 downto 0);
	component alu
	
	port (
    a, b : in std_logic_vector(3 downto 0);
    F : out std_logic_vector(3 downto 0);
    s0, s1 : in std_logic;
    Z, C, V, N : out std_logic
  );
  
  end component;

  component two_comp_to_7seg
  
  port (
    bin : in std_logic_vector(3 downto 0);
    segs : out std_logic_vector(6 downto 0);
    neg : out std_logic
  );
  
  end component;
  
  component bin2hex
  port (
	SW: in std_logic_vector(3 downto 0);
	HEX0: out std_logic_vector(6 downto 0)
  );
  
  end component;
begin

	oper <= SW(9) & SW(8);
					
  a_aux <= SW(7)&SW(6)&SW(5)&SW(4);
  b_aux <= SW(3)&SW(2)&SW(1)&SW(0);
  
  my_alu: alu port map (
		s0 => SW(9),
		s1 => SW(8), 
		a(3) => SW(7), 
		a(2) => SW(6),
		a(1) => SW(5),
		a(0) => SW(4),
		b(3) => SW(3),
		b(2) => SW(2),
		b(1) => SW(1),
		b(0) => SW(0),
		Z => LEDR(3),
		C => LEDR(2),
		V => LEDR(1),
		N => LEDR(0),
		F => f_aux
  );
  
  my_first: two_comp_to_7seg port map (
		bin => a_aux,
		segs => HEX4_aux,
		neg => neg_aux(2)
  );
  my_second: two_comp_to_7seg port map (
		bin => b_aux,
		segs => HEX2_aux,
		neg => neg_aux(1)
  );
  my_third: two_comp_to_7seg port map ( 
		bin => f_aux,
		segs => HEX0_aux,
		neg => neg_aux(0)
  );
  
  my_hex_1 : bin2hex port map (
		SW => a_aux,
		HEX0 => HEX4_aux1
  );
  
  my_hex_2 : bin2hex port map (
		SW => b_aux,
		HEX0 => HEX2_aux1
  );
  
  my_hex_3 : bin2hex port map (
		SW => f_aux,
		HEX0 => HEX0_aux1
  );
  
  with oper(0) select
		HEX4 <= HEX4_aux when '0',
				  HEX4_aux1 when OTHERS;
  
  with oper(0) select
		HEX2 <= HEX2_aux when '0',
				  HEX2_aux1 when OTHERS;
  
  with oper(0) select
		HEX0 <= HEX0_aux when '0',
				  HEX0_aux1 when OTHERS;
				  
  is_neg <=  "0111111";
  not_neg <= "1111111";
  
  with oper(0) select
		true_neg <= is_neg when '0',
						not_neg when OTHERS;
  
  with neg_aux(2) select
		HEX5 <= not_neg WHEN '0',
				  true_neg WHEN OTHERS;
  
  with neg_aux(1) select
		HEX3 <= not_neg WHEN '0',
				  true_neg WHEN OTHERS;
				  
	with neg_aux(0) select
		HEX1 <= not_neg WHEN '0',
				  true_neg WHEN OTHERS;
  
end behavioral;

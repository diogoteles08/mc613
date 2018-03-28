library ieee;
use ieee.std_logic_1164.all;

entity alu is
  port (
    a, b : in std_logic_vector(3 downto 0);
    F : out std_logic_vector(3 downto 0);
    s0, s1 : in std_logic;
    Z, C, V, N : out std_logic
  );
end alu;

architecture behavioral of alu is
	signal op : std_logic_vector(1 downto 0);
	signal b_tmp : std_logic_vector(3 downto 0);
	signal R: std_logic_vector(3 downto 0);
	signal C_aux: std_logic;
	signal V_aux: std_logic;
	signal N_aux: std_logic;
	signal F_aux: std_logic_vector(3 downto 0);
	signal T_aux: std_logic_vector(2 downto 0);
	signal Help_me: std_logic_vector(2 downto 0);
	signal aux : std_logic;
	component ripple_carry
	generic (
    N : integer := 4
  );
  port (
    x,y : in std_logic_vector(N-1 downto 0);
    r : out std_logic_vector(N-1 downto 0);
    cin : in std_logic;
    cout : out std_logic;
    overflow : out std_logic
  );
	end component;
begin
	op <= s0 & s1 ;
	
	-- problemas de sintaxe
	b_tmp <= not(b) when op(1) = '1' else b;
	doing: ripple_carry port map(
		x => a,
		y => b_tmp, 
		r => R, 
		cin => op(1), 
		cout => aux, 
		overflow => V_aux
	);
	
	with op select
		F_aux <= a and b when "01",
			  a or b when "11",
			  R when OTHERS;
  
	Z <= '1' when F_aux = "0000" else '0';
	
	F <= F_aux;
	Help_me <= "000";
	
	C_aux <= '0' when op(1) = '1' else aux;
	
	T_aux <= C_aux & V_aux & N_aux;
	with op(0) select
		(C, V, N) <= T_aux when '0',
						 Help_me when OTHERS;
		
	N_aux <= '1' when F_aux(3) = '1' else '0';
	
end behavioral;

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity fsm_table is
  port (
    clk, reset, w : in std_logic;
    z : out std_logic
  );
end fsm_table;

architecture rtl of fsm_table is
	TYPE State_type IS (A, B, C, D);
	SIGNAL state: State_type;
begin
  process (clk, reset)
  begin
		if reset = '1' then 
			state <= A;
			z <= '0';
		elsif clk'EVENT and clk= '1' then
			CASE state IS
				WHEN A =>
					if w = '0' then
						state <= C;
						z <= '1';
					else
						state <= B;
						z <= '1';
					end if;
				WHEN B =>
					if w = '0' then
						state <= D;
						z <= '1';
					else 
						state <= C;
						z <= '0';
					end if;
				WHEN C =>
					if w = '0' then
						state <= B;
						z <= '0';
					else 
						state <= C;
						z <= '0';
					end if;
				WHEN D =>
					if w = '0' then
						state <= A;
						z <= '0';
					else 
						state <= C;
						z <= '1';
					end if;
			END CASE;
		end if;
  end process;
end rtl;

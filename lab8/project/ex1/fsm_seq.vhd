library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity fsm_seg is
  port (
    clk, reset, w : in std_logic;
    z : in std_logic;
  );
end fsm_seg;

architecture rtl of fsm_seg is
	TYPE State_type IS (A, B, C, D);
	SIGNAL state: State_type;
begin
  process (clk, reset)
  begin
		if reset = '1' then 
			state <= A;
		if clk'EVENT and clk= '1' then
			z <= '0';
			CASE state IS
				WHEN A =>
					if w = '0' 
						state <= B;
					else 
						state <= A;
					end if;
				WHEN B =>
					if w = '0' 
						state <= A;
					else 
						state <= C;
					end if;
				WHEN C =>
					if w = '0'
						state <= D;
					else 
						state <= A;
					end if;
				WHEN D =>
					if w = '0'
						state <= A;
					else 
						state <= C;
						z <= '1';
					end if;
			END CASE;
		end if;
  end process;
end rtl;

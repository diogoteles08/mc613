library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity fsm_diag is
  port (
    clk, reset, w : in std_logic;
    z : out std_logic
  );
end fsm_diag;

architecture rtl of fsm_diag is
	TYPE State_type IS (A, B, C, D);
	SIGNAL state: State_type;
begin
  process (clk, reset)
  begin
		if reset = '1' then 
			state <= A;
		elsif clk'EVENT and clk= '1' then
			CASE state IS
				WHEN A =>
					if w = '0' then
						state <= A;
					else 
						state <= B;
					end if;
				WHEN B =>
					if w = '0' then
						state <= C;
					else 
						state <= B;
					end if;
				WHEN C =>
					if w = '0' then
						state <= C;
					else 
						state <= D;
					end if;
				WHEN D =>
					if w = '0' then
						state <= A;
					else 
						state <= D;
					end if;
			END CASE;
		end if;
  end process;
  z <= '1' when state = B else '0';
end rtl;

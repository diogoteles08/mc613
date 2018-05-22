LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY reg IS
	GENERIC (
		WORDSIZE	: NATURAL := 32
	);
	PORT (
		clock,
		load,
		clear	: IN	STD_LOGIC;
		datain	: IN	STD_LOGIC_VECTOR(WORDSIZE-1 DOWNTO 0);
		dataout : OUT	STD_LOGIC_VECTOR(WORDSIZE-1 DOWNTO 0)
	);
END ENTITY;

ARCHITECTURE Behavior OF reg IS
BEGIN
	PROCESS (clock, load, clear, datain)
	BEGIN
		IF clear = '1' THEN
			dataout <= (OTHERS => '0');
		ELSIF (clock'event AND clock = '1') THEN
			IF (load = '1') THEN
				dataout <= datain;
			END IF;
		END IF;
	END PROCESS;
END ARCHITECTURE;
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;

ENTITY PC IS
	GENERIC (
		increment	: NATURAL := 4;
		WORDSIZE	: NATURAL := 32
	);
	PORT (
		clock,
		clear,
		PC_Ld,
		PC_Inc		: IN		STD_LOGIC;
		DATA_IN		: IN		STD_LOGIC_VECTOR (WORDSIZE-1 DOWNTO 0);
		DATA_OUT	: BUFFER	STD_LOGIC_VECTOR (WORDSIZE-1 DOWNTO 0)
	);
END ENTITY;

ARCHITECTURE Behavior OF PC IS
BEGIN
	Counter:
	PROCESS (clock, clear, PC_Ld, PC_Inc, DATA_IN)
	BEGIN
		IF (clear = '1') THEN
			DATA_OUT <= (OTHERS => '0');
		ELSIF (FALLING_EDGE(clock)) THEN
			IF (PC_Ld = '1') THEN
				DATA_OUT <= DATA_IN;
			ELSIF (PC_Inc = '1') THEN
				DATA_OUT <= DATA_OUT + STD_LOGIC_VECTOR(TO_UNSIGNED(increment, WORDSIZE));
			END IF;	
		END IF;	
	END PROCESS;
END ARCHITECTURE;
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY ALU IS
	GENERIC (
		WORDSIZE	: NATURAL := 4
	);
	PORT (
		A, B		: IN		STD_LOGIC_VECTOR (WORDSIZE-1 DOWNTO 0);
		Op			: IN		STD_LOGIC_VECTOR (1 DOWNTO 0);
		F			: BUFFER	STD_LOGIC_VECTOR (WORDSIZE-1 DOWNTO 0);
		Z, C, V, N	: OUT		STD_LOGIC
	);
END ENTITY;

ARCHITECTURE Behavior OF ALU IS
BEGIN
	Operation:
	PROCESS (A, B, Op, F)
		VARIABLE R : STD_LOGIC_VECTOR (WORDSIZE DOWNTO 0);
		VARIABLE W : STD_LOGIC_VECTOR (WORDSIZE-1 DOWNTO 0);
	BEGIN
		IF Op = "01" THEN
			W := (NOT B) + 1;
		ELSE
			W := B;
		END IF;
	
		CASE Op IS
		WHEN "00" =>
			R := ('0' & A) + ('0' & W);
		WHEN "01" =>
			R := ('0' & A) + ('0' & W);
		WHEN "10" =>
			R := '0' & (A AND W);
		WHEN OTHERS =>
			R := '0' & (A OR W);
		END CASE;
		
		V <= (A(WORDSIZE-1) AND W(WORDSIZE-1) AND (NOT F(WORDSIZE-1))) OR ( (NOT A(WORDSIZE-1)) AND (NOT W(WORDSIZE-1)) AND F(WORDSIZE-1));
		
		IF (F = 0) THEN
			Z <= '1';
		ELSE
			Z <= '0';
		END IF;
		
		N <= R (WORDSIZE-1);
		C <= R (WORDSIZE);
		F <= R (WORDSIZE-1 DOWNTO 0);
		
	END PROCESS;
END ARCHITECTURE;
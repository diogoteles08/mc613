LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

PACKAGE Processor_pack IS
	TYPE states_UC IS (FETCH, DECODE, EX);

	COMPONENT memory IS
		GENERIC (
			WORDSIZE		: NATURAL	:= 8;
			BITS_OF_ADDR	: NATURAL	:= 16;
			MIF_FILE		: STRING	:= ""
		);
		PORT (
			clock   : IN	STD_LOGIC;
			we      : IN	STD_LOGIC;
			address : IN	STD_LOGIC_VECTOR(BITS_OF_ADDR-1 DOWNTO 0);
			datain  : IN	STD_LOGIC_VECTOR(WORDSIZE-1 DOWNTO 0);
			dataout : OUT	STD_LOGIC_VECTOR(WORDSIZE-1 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT reg IS
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
	END COMPONENT;

	COMPONENT bank IS
		GENERIC (
			WORDSIZE : NATURAL := 32
		);
		PORT (
			WR_EN, RD_EN,
			clear,
			clock		: IN 	STD_LOGIC;
			WR_ADDR,
			RD_ADDR1,
			RD_ADDR2	: IN	STD_LOGIC_VECTOR (4 DOWNTO 0);
			DATA_IN		: IN	STD_LOGIC_VECTOR (WORDSIZE-1 DOWNTO 0);
			DATA_OUT1,
			DATA_OUT2	: OUT	STD_LOGIC_VECTOR (WORDSIZE-1 DOWNTO 0)
		);
	END COMPONENT;
	
	COMPONENT ALU IS
		GENERIC (
			WORDSIZE	: NATURAL := 4
		);
		PORT (
			A, B		: IN		STD_LOGIC_VECTOR (WORDSIZE-1 DOWNTO 0);
			Op			: IN		STD_LOGIC_VECTOR (1 DOWNTO 0);
			F			: BUFFER	STD_LOGIC_VECTOR (WORDSIZE-1 DOWNTO 0);
			Z, C, V, N	: OUT		STD_LOGIC
		);
	END COMPONENT;

	COMPONENT PC IS
		GENERIC (
			increment	: NATURAL := 4;
			WORDSIZE	: NATURAL := 32
		);
		PORT (
			clock,
			load,
			enable		: IN		STD_LOGIC;
			DATA_IN		: IN		STD_LOGIC_VECTOR (WORDSIZE-1 DOWNTO 0);
			DATA_OUT	: BUFFER	STD_LOGIC_VECTOR (WORDSIZE-1 DOWNTO 0)
		);
	END COMPONENT;
	
	COMPONENT UC IS
		PORT (
			clear,
			clock			: IN	STD_LOGIC;
			instruction		: IN	STD_LOGIC_VECTOR (2 DOWNTO 0);
			IR_Ld, PC_Inc, ALU_2_DBus, DM_Rd, DM_Wr, PC_Ld_En, Reg_2_IO, IO_2_Reg, Reg_Wr, Stat_Wr,
			DM_2_DBus		: OUT	STD_LOGIC
		);
	END COMPONENT;
	
	COMPONENT CPU
		PORT (
			clock				:	 IN STD_LOGIC;
			reset				:	 IN STD_LOGIC;
			IO_IN				:	 IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			DBus				:	 OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			RSource1			:	 OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			RSource2			:	 OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			IO_OUT				:	 OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			IM_address			:	 OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			IM_instruction_out	:	 OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			instruction			:	 OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			stat_CVNZ			:	 OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			Pc_Ld				:	 OUT STD_LOGIC;
			IR_Ld				:	 OUT STD_LOGIC;
			Pc_Inc				:	 OUT STD_LOGIC;
			ALU_2_DBus			:	 OUT STD_LOGIC;
			DM_Rd				:	 OUT STD_LOGIC;
			DM_Wr				:	 OUT STD_LOGIC;
			PC_Ld_En			:	 OUT STD_LOGIC;
			Reg_2_IO			:	 OUT STD_LOGIC;
			IO_2_Reg			:	 OUT STD_LOGIC;
			Reg_Wr				:	 OUT STD_LOGIC;
			Stat_Wr				:	 OUT STD_LOGIC;
			DM_2_DBus			:	 OUT STD_LOGIC
		);
	END COMPONENT;

END PACKAGE;

library ieee;
use ieee.std_logic_1164.all;

PACKAGE latches_ffs_pack IS 
	COMPONENT latch_sr_nand
		port (
			S_n, R_n: in std_logic;
			Qa, Qb: out std_logic
		);
	END COMPONENT;
	
	COMPONENT latch_sr_gated
		port (
			S, R, Clk: in std_logic;
			Q, Q_n: out std_logic
		);
	END COMPONENT;
	
	COMPONENT latch_d_gated
		port (
			D, Clk: in std_logic;
			Q, Q_n: out std_logic
		);
	END COMPONENT;
	
	COMPONENT ff_d
		port (
			D, Clk, Preset, Clear: in std_logic;
			Q, Q_n: out std_logic
		);
	END COMPONENT;
	
	COMPONENT ff_jk
		port (
			J, K, Clk, Preset, Clear: in std_logic;
			Q, Q_n: out std_logic
		);
	END COMPONENT;
	
	COMPONENT ff_t
		port (
			T, Clk, Preset, Clear: in std_logic;
			Q, Q_n: out std_logic
		);
	END COMPONENT;
END latches_ffs_pack;
	
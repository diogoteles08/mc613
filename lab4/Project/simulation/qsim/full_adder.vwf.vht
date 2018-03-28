-- Copyright (C) 2017  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel FPGA IP License Agreement, or other applicable license
-- agreement, including, without limitation, that your use is for
-- the sole purpose of programming logic devices manufactured by
-- Intel and sold by Intel or its authorized distributors.  Please
-- refer to the applicable agreement for further details.

-- *****************************************************************************
-- This file contains a Vhdl test bench with test vectors .The test vectors     
-- are exported from a vector file in the Quartus Waveform Editor and apply to  
-- the top level entity of the current Quartus project .The user can use this   
-- testbench to simulate his design using a third-party simulation tool .       
-- *****************************************************************************
-- Generated on "03/21/2018 16:04:15"
                                                             
-- Vhdl Test Bench(with test vectors) for design  :          full_adder
-- 
-- Simulation tool : 3rd Party
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

ENTITY full_adder_vhd_vec_tst IS
END full_adder_vhd_vec_tst;
ARCHITECTURE full_adder_arch OF full_adder_vhd_vec_tst IS
-- constants                                                 
-- signals                                                   
SIGNAL cin : STD_LOGIC;
SIGNAL cout : STD_LOGIC;
SIGNAL r : STD_LOGIC;
SIGNAL x : STD_LOGIC;
SIGNAL y : STD_LOGIC;
COMPONENT full_adder
	PORT (
	cin : IN STD_LOGIC;
	cout : OUT STD_LOGIC;
	r : OUT STD_LOGIC;
	x : IN STD_LOGIC;
	y : IN STD_LOGIC
	);
END COMPONENT;
BEGIN
	i1 : full_adder
	PORT MAP (
-- list connections between master ports and signals
	cin => cin,
	cout => cout,
	r => r,
	x => x,
	y => y
	);

-- cin
t_prcs_cin: PROCESS
BEGIN
	cin <= '1';
	WAIT FOR 100000 ps;
	cin <= '0';
WAIT;
END PROCESS t_prcs_cin;

-- x
t_prcs_x: PROCESS
BEGIN
	x <= '1';
	WAIT FOR 50000 ps;
	x <= '0';
	WAIT FOR 50000 ps;
	x <= '1';
	WAIT FOR 50000 ps;
	x <= '0';
WAIT;
END PROCESS t_prcs_x;

-- y
t_prcs_y: PROCESS
BEGIN
	y <= '1';
	WAIT FOR 30000 ps;
	y <= '0';
	WAIT FOR 20000 ps;
	y <= '1';
	WAIT FOR 20000 ps;
	y <= '0';
	WAIT FOR 30000 ps;
	y <= '1';
	WAIT FOR 20000 ps;
	y <= '0';
	WAIT FOR 30000 ps;
	y <= '1';
	WAIT FOR 30000 ps;
	y <= '0';
WAIT;
END PROCESS t_prcs_y;
END full_adder_arch;

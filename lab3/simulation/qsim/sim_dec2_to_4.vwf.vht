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
-- Generated on "03/20/2018 22:02:30"
                                                             
-- Vhdl Test Bench(with test vectors) for design  :          dec2_to_4
-- 
-- Simulation tool : 3rd Party
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

ENTITY dec2_to_4_vhd_vec_tst IS
END dec2_to_4_vhd_vec_tst;
ARCHITECTURE dec2_to_4_arch OF dec2_to_4_vhd_vec_tst IS
-- constants                                                 
-- signals                                                   
SIGNAL en : STD_LOGIC;
SIGNAL w0 : STD_LOGIC;
SIGNAL w1 : STD_LOGIC;
SIGNAL y0 : STD_LOGIC;
SIGNAL y1 : STD_LOGIC;
SIGNAL y2 : STD_LOGIC;
SIGNAL y3 : STD_LOGIC;
COMPONENT dec2_to_4
	PORT (
	en : IN STD_LOGIC;
	w0 : IN STD_LOGIC;
	w1 : IN STD_LOGIC;
	y0 : OUT STD_LOGIC;
	y1 : OUT STD_LOGIC;
	y2 : OUT STD_LOGIC;
	y3 : OUT STD_LOGIC
	);
END COMPONENT;
BEGIN
	i1 : dec2_to_4
	PORT MAP (
-- list connections between master ports and signals
	en => en,
	w0 => w0,
	w1 => w1,
	y0 => y0,
	y1 => y1,
	y2 => y2,
	y3 => y3
	);

-- en
t_prcs_en: PROCESS
BEGIN
	en <= '0';
	WAIT FOR 118 ps;
	en <= '1';
	WAIT FOR 99882 ps;
	en <= '0';
WAIT;
END PROCESS t_prcs_en;

-- w0
t_prcs_w0: PROCESS
BEGIN
	w0 <= '1';
	WAIT FOR 50000 ps;
	w0 <= '0';
	WAIT FOR 50000 ps;
	w0 <= '1';
	WAIT FOR 50000 ps;
	w0 <= '0';
WAIT;
END PROCESS t_prcs_w0;

-- w1
t_prcs_w1: PROCESS
BEGIN
	w1 <= '1';
	WAIT FOR 20000 ps;
	w1 <= '0';
	WAIT FOR 30000 ps;
	w1 <= '1';
	WAIT FOR 30000 ps;
	w1 <= '0';
	WAIT FOR 20000 ps;
	w1 <= '1';
	WAIT FOR 20000 ps;
	w1 <= '0';
	WAIT FOR 30000 ps;
	w1 <= '1';
	WAIT FOR 30000 ps;
	w1 <= '0';
WAIT;
END PROCESS t_prcs_w1;
END dec2_to_4_arch;

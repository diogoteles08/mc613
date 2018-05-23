-- Copyright (C) 2017  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel MegaCore Function License Agreement, or other 
-- applicable license agreement, including, without limitation, 
-- that your use is for the sole purpose of programming logic 
-- devices manufactured by Intel and sold by Intel or its 
-- authorized distributors.  Please refer to the applicable 
-- agreement for further details.

-- PROGRAM		"Quartus Prime"
-- VERSION		"Version 17.0.0 Build 595 04/25/2017 SJ Lite Edition"
-- CREATED		"Thu May 17 20:31:26 2018"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY altera;
USE altera.maxplus2.all; 

LIBRARY work;

ENTITY mux_0 IS 
PORT 
( 
	data	:	IN	 STD_LOGIC_VECTOR(3 DOWNTO 0);
	sel	:	IN	 STD_LOGIC_VECTOR(1 DOWNTO 0);
	result	:	OUT	 STD_LOGIC
); 
END mux_0;

ARCHITECTURE bdf_type OF mux_0 IS 
BEGIN 

-- instantiate macrofunction 

b2v_mux4to1 : mux
GENERIC MAP(WIDTH => 4,
			WIDTHS => 2)
PORT MAP(data => data,
		 sel => sel,
		 result => result);

END bdf_type; 
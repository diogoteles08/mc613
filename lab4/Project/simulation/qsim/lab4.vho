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

-- VENDOR "Altera"
-- PROGRAM "Quartus Prime"
-- VERSION "Version 17.1.0 Build 590 10/25/2017 SJ Lite Edition"

-- DATE "03/26/2018 20:25:41"

-- 
-- Device: Altera 5CSEMA5F31C6 Package FBGA896
-- 

-- 
-- This VHDL file should be used for ModelSim-Altera (VHDL) only
-- 

LIBRARY ALTERA_LNSIM;
LIBRARY CYCLONEV;
LIBRARY IEEE;
USE ALTERA_LNSIM.ALTERA_LNSIM_COMPONENTS.ALL;
USE CYCLONEV.CYCLONEV_COMPONENTS.ALL;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY 	ripple_carry IS
    PORT (
	x : IN std_logic_vector(3 DOWNTO 0);
	y : IN std_logic_vector(3 DOWNTO 0);
	r : OUT std_logic_vector(3 DOWNTO 0);
	cin : IN std_logic;
	cout : OUT std_logic;
	overflow : OUT std_logic
	);
END ripple_carry;

-- Design Ports Information
-- r[0]	=>  Location: PIN_Y27,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- r[1]	=>  Location: PIN_V25,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- r[2]	=>  Location: PIN_AE29,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- r[3]	=>  Location: PIN_AC30,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- cout	=>  Location: PIN_AD29,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- overflow	=>  Location: PIN_Y26,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- x[0]	=>  Location: PIN_AB30,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- y[0]	=>  Location: PIN_AB28,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- cin	=>  Location: PIN_AC28,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- x[1]	=>  Location: PIN_AA26,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- y[1]	=>  Location: PIN_AB27,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- x[2]	=>  Location: PIN_AA28,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- y[2]	=>  Location: PIN_AA30,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- x[3]	=>  Location: PIN_AC29,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- y[3]	=>  Location: PIN_W25,	 I/O Standard: 2.5 V,	 Current Strength: Default


ARCHITECTURE structure OF ripple_carry IS
SIGNAL gnd : std_logic := '0';
SIGNAL vcc : std_logic := '1';
SIGNAL unknown : std_logic := 'X';
SIGNAL devoe : std_logic := '1';
SIGNAL devclrn : std_logic := '1';
SIGNAL devpor : std_logic := '1';
SIGNAL ww_devoe : std_logic;
SIGNAL ww_devclrn : std_logic;
SIGNAL ww_devpor : std_logic;
SIGNAL ww_x : std_logic_vector(3 DOWNTO 0);
SIGNAL ww_y : std_logic_vector(3 DOWNTO 0);
SIGNAL ww_r : std_logic_vector(3 DOWNTO 0);
SIGNAL ww_cin : std_logic;
SIGNAL ww_cout : std_logic;
SIGNAL ww_overflow : std_logic;
SIGNAL \~QUARTUS_CREATED_GND~I_combout\ : std_logic;
SIGNAL \cin~input_o\ : std_logic;
SIGNAL \x[0]~input_o\ : std_logic;
SIGNAL \y[0]~input_o\ : std_logic;
SIGNAL \G1:0:adder|r~combout\ : std_logic;
SIGNAL \x[1]~input_o\ : std_logic;
SIGNAL \y[1]~input_o\ : std_logic;
SIGNAL \G1:1:adder|r~combout\ : std_logic;
SIGNAL \x[2]~input_o\ : std_logic;
SIGNAL \G1:1:adder|cout~0_combout\ : std_logic;
SIGNAL \y[2]~input_o\ : std_logic;
SIGNAL \G1:2:adder|r~combout\ : std_logic;
SIGNAL \y[3]~input_o\ : std_logic;
SIGNAL \x[3]~input_o\ : std_logic;
SIGNAL \G1:3:adder|r~combout\ : std_logic;
SIGNAL \G1:3:adder|cout~0_combout\ : std_logic;
SIGNAL \overflow~0_combout\ : std_logic;
SIGNAL \ALT_INV_y[3]~input_o\ : std_logic;
SIGNAL \ALT_INV_x[3]~input_o\ : std_logic;
SIGNAL \ALT_INV_y[2]~input_o\ : std_logic;
SIGNAL \ALT_INV_x[2]~input_o\ : std_logic;
SIGNAL \ALT_INV_y[1]~input_o\ : std_logic;
SIGNAL \ALT_INV_x[1]~input_o\ : std_logic;
SIGNAL \ALT_INV_cin~input_o\ : std_logic;
SIGNAL \ALT_INV_y[0]~input_o\ : std_logic;
SIGNAL \ALT_INV_x[0]~input_o\ : std_logic;
SIGNAL \G1:1:adder|ALT_INV_cout~0_combout\ : std_logic;

BEGIN

ww_x <= x;
ww_y <= y;
r <= ww_r;
ww_cin <= cin;
cout <= ww_cout;
overflow <= ww_overflow;
ww_devoe <= devoe;
ww_devclrn <= devclrn;
ww_devpor <= devpor;
\ALT_INV_y[3]~input_o\ <= NOT \y[3]~input_o\;
\ALT_INV_x[3]~input_o\ <= NOT \x[3]~input_o\;
\ALT_INV_y[2]~input_o\ <= NOT \y[2]~input_o\;
\ALT_INV_x[2]~input_o\ <= NOT \x[2]~input_o\;
\ALT_INV_y[1]~input_o\ <= NOT \y[1]~input_o\;
\ALT_INV_x[1]~input_o\ <= NOT \x[1]~input_o\;
\ALT_INV_cin~input_o\ <= NOT \cin~input_o\;
\ALT_INV_y[0]~input_o\ <= NOT \y[0]~input_o\;
\ALT_INV_x[0]~input_o\ <= NOT \x[0]~input_o\;
\G1:1:adder|ALT_INV_cout~0_combout\ <= NOT \G1:1:adder|cout~0_combout\;

-- Location: IOOBUF_X89_Y25_N22
\r[0]~output\ : cyclonev_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	shift_series_termination_control => "false")
-- pragma translate_on
PORT MAP (
	i => \G1:0:adder|r~combout\,
	devoe => ww_devoe,
	o => ww_r(0));

-- Location: IOOBUF_X89_Y20_N62
\r[1]~output\ : cyclonev_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	shift_series_termination_control => "false")
-- pragma translate_on
PORT MAP (
	i => \G1:1:adder|r~combout\,
	devoe => ww_devoe,
	o => ww_r(1));

-- Location: IOOBUF_X89_Y23_N39
\r[2]~output\ : cyclonev_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	shift_series_termination_control => "false")
-- pragma translate_on
PORT MAP (
	i => \G1:2:adder|r~combout\,
	devoe => ww_devoe,
	o => ww_r(2));

-- Location: IOOBUF_X89_Y25_N56
\r[3]~output\ : cyclonev_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	shift_series_termination_control => "false")
-- pragma translate_on
PORT MAP (
	i => \G1:3:adder|r~combout\,
	devoe => ww_devoe,
	o => ww_r(3));

-- Location: IOOBUF_X89_Y23_N56
\cout~output\ : cyclonev_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	shift_series_termination_control => "false")
-- pragma translate_on
PORT MAP (
	i => \G1:3:adder|cout~0_combout\,
	devoe => ww_devoe,
	o => ww_cout);

-- Location: IOOBUF_X89_Y25_N5
\overflow~output\ : cyclonev_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	shift_series_termination_control => "false")
-- pragma translate_on
PORT MAP (
	i => \overflow~0_combout\,
	devoe => ww_devoe,
	o => ww_overflow);

-- Location: IOIBUF_X89_Y20_N78
\cin~input\ : cyclonev_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_cin,
	o => \cin~input_o\);

-- Location: IOIBUF_X89_Y21_N4
\x[0]~input\ : cyclonev_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_x(0),
	o => \x[0]~input_o\);

-- Location: IOIBUF_X89_Y21_N38
\y[0]~input\ : cyclonev_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_y(0),
	o => \y[0]~input_o\);

-- Location: LABCELL_X88_Y21_N30
\G1:0:adder|r\ : cyclonev_lcell_comb
-- Equation(s):
-- \G1:0:adder|r~combout\ = ( \y[0]~input_o\ & ( !\cin~input_o\ $ (\x[0]~input_o\) ) ) # ( !\y[0]~input_o\ & ( !\cin~input_o\ $ (!\x[0]~input_o\) ) )

-- pragma translate_off
GENERIC MAP (
	extended_lut => "off",
	lut_mask => "0011110000111100110000111100001100111100001111001100001111000011",
	shared_arith => "off")
-- pragma translate_on
PORT MAP (
	datab => \ALT_INV_cin~input_o\,
	datac => \ALT_INV_x[0]~input_o\,
	datae => \ALT_INV_y[0]~input_o\,
	combout => \G1:0:adder|r~combout\);

-- Location: IOIBUF_X89_Y23_N4
\x[1]~input\ : cyclonev_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_x(1),
	o => \x[1]~input_o\);

-- Location: IOIBUF_X89_Y23_N21
\y[1]~input\ : cyclonev_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_y(1),
	o => \y[1]~input_o\);

-- Location: LABCELL_X88_Y21_N9
\G1:1:adder|r\ : cyclonev_lcell_comb
-- Equation(s):
-- \G1:1:adder|r~combout\ = ( \y[0]~input_o\ & ( \y[1]~input_o\ & ( !\x[1]~input_o\ $ (((\cin~input_o\) # (\x[0]~input_o\))) ) ) ) # ( !\y[0]~input_o\ & ( \y[1]~input_o\ & ( !\x[1]~input_o\ $ (((\x[0]~input_o\ & \cin~input_o\))) ) ) ) # ( \y[0]~input_o\ & ( 
-- !\y[1]~input_o\ & ( !\x[1]~input_o\ $ (((!\x[0]~input_o\ & !\cin~input_o\))) ) ) ) # ( !\y[0]~input_o\ & ( !\y[1]~input_o\ & ( !\x[1]~input_o\ $ (((!\x[0]~input_o\) # (!\cin~input_o\))) ) ) )

-- pragma translate_off
GENERIC MAP (
	extended_lut => "off",
	lut_mask => "0000010111111010010111111010000011111010000001011010000001011111",
	shared_arith => "off")
-- pragma translate_on
PORT MAP (
	dataa => \ALT_INV_x[0]~input_o\,
	datac => \ALT_INV_cin~input_o\,
	datad => \ALT_INV_x[1]~input_o\,
	datae => \ALT_INV_y[0]~input_o\,
	dataf => \ALT_INV_y[1]~input_o\,
	combout => \G1:1:adder|r~combout\);

-- Location: IOIBUF_X89_Y21_N55
\x[2]~input\ : cyclonev_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_x(2),
	o => \x[2]~input_o\);

-- Location: LABCELL_X88_Y21_N42
\G1:1:adder|cout~0\ : cyclonev_lcell_comb
-- Equation(s):
-- \G1:1:adder|cout~0_combout\ = ( \y[0]~input_o\ & ( \y[1]~input_o\ & ( ((\x[0]~input_o\) # (\cin~input_o\)) # (\x[1]~input_o\) ) ) ) # ( !\y[0]~input_o\ & ( \y[1]~input_o\ & ( ((\cin~input_o\ & \x[0]~input_o\)) # (\x[1]~input_o\) ) ) ) # ( \y[0]~input_o\ & 
-- ( !\y[1]~input_o\ & ( (\x[1]~input_o\ & ((\x[0]~input_o\) # (\cin~input_o\))) ) ) ) # ( !\y[0]~input_o\ & ( !\y[1]~input_o\ & ( (\x[1]~input_o\ & (\cin~input_o\ & \x[0]~input_o\)) ) ) )

-- pragma translate_off
GENERIC MAP (
	extended_lut => "off",
	lut_mask => "0000000100000001000101010001010101010111010101110111111101111111",
	shared_arith => "off")
-- pragma translate_on
PORT MAP (
	dataa => \ALT_INV_x[1]~input_o\,
	datab => \ALT_INV_cin~input_o\,
	datac => \ALT_INV_x[0]~input_o\,
	datae => \ALT_INV_y[0]~input_o\,
	dataf => \ALT_INV_y[1]~input_o\,
	combout => \G1:1:adder|cout~0_combout\);

-- Location: IOIBUF_X89_Y21_N21
\y[2]~input\ : cyclonev_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_y(2),
	o => \y[2]~input_o\);

-- Location: LABCELL_X88_Y21_N51
\G1:2:adder|r\ : cyclonev_lcell_comb
-- Equation(s):
-- \G1:2:adder|r~combout\ = ( \y[2]~input_o\ & ( !\x[2]~input_o\ $ (\G1:1:adder|cout~0_combout\) ) ) # ( !\y[2]~input_o\ & ( !\x[2]~input_o\ $ (!\G1:1:adder|cout~0_combout\) ) )

-- pragma translate_off
GENERIC MAP (
	extended_lut => "off",
	lut_mask => "0101101001011010101001011010010101011010010110101010010110100101",
	shared_arith => "off")
-- pragma translate_on
PORT MAP (
	dataa => \ALT_INV_x[2]~input_o\,
	datac => \G1:1:adder|ALT_INV_cout~0_combout\,
	datae => \ALT_INV_y[2]~input_o\,
	combout => \G1:2:adder|r~combout\);

-- Location: IOIBUF_X89_Y20_N44
\y[3]~input\ : cyclonev_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_y(3),
	o => \y[3]~input_o\);

-- Location: IOIBUF_X89_Y20_N95
\x[3]~input\ : cyclonev_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_x(3),
	o => \x[3]~input_o\);

-- Location: LABCELL_X88_Y21_N54
\G1:3:adder|r\ : cyclonev_lcell_comb
-- Equation(s):
-- \G1:3:adder|r~combout\ = ( \x[3]~input_o\ & ( !\y[3]~input_o\ $ (((!\x[2]~input_o\ & (\G1:1:adder|cout~0_combout\ & \y[2]~input_o\)) # (\x[2]~input_o\ & ((\y[2]~input_o\) # (\G1:1:adder|cout~0_combout\))))) ) ) # ( !\x[3]~input_o\ & ( !\y[3]~input_o\ $ 
-- (((!\x[2]~input_o\ & ((!\G1:1:adder|cout~0_combout\) # (!\y[2]~input_o\))) # (\x[2]~input_o\ & (!\G1:1:adder|cout~0_combout\ & !\y[2]~input_o\)))) ) )

-- pragma translate_off
GENERIC MAP (
	extended_lut => "off",
	lut_mask => "0001111001111000111000011000011100011110011110001110000110000111",
	shared_arith => "off")
-- pragma translate_on
PORT MAP (
	dataa => \ALT_INV_x[2]~input_o\,
	datab => \G1:1:adder|ALT_INV_cout~0_combout\,
	datac => \ALT_INV_y[3]~input_o\,
	datad => \ALT_INV_y[2]~input_o\,
	datae => \ALT_INV_x[3]~input_o\,
	combout => \G1:3:adder|r~combout\);

-- Location: LABCELL_X88_Y21_N3
\G1:3:adder|cout~0\ : cyclonev_lcell_comb
-- Equation(s):
-- \G1:3:adder|cout~0_combout\ = ( \x[3]~input_o\ & ( ((!\y[2]~input_o\ & (\G1:1:adder|cout~0_combout\ & \x[2]~input_o\)) # (\y[2]~input_o\ & ((\x[2]~input_o\) # (\G1:1:adder|cout~0_combout\)))) # (\y[3]~input_o\) ) ) # ( !\x[3]~input_o\ & ( (\y[3]~input_o\ 
-- & ((!\y[2]~input_o\ & (\G1:1:adder|cout~0_combout\ & \x[2]~input_o\)) # (\y[2]~input_o\ & ((\x[2]~input_o\) # (\G1:1:adder|cout~0_combout\))))) ) )

-- pragma translate_off
GENERIC MAP (
	extended_lut => "off",
	lut_mask => "0000000100010101010101110111111100000001000101010101011101111111",
	shared_arith => "off")
-- pragma translate_on
PORT MAP (
	dataa => \ALT_INV_y[3]~input_o\,
	datab => \ALT_INV_y[2]~input_o\,
	datac => \G1:1:adder|ALT_INV_cout~0_combout\,
	datad => \ALT_INV_x[2]~input_o\,
	datae => \ALT_INV_x[3]~input_o\,
	combout => \G1:3:adder|cout~0_combout\);

-- Location: LABCELL_X88_Y21_N36
\overflow~0\ : cyclonev_lcell_comb
-- Equation(s):
-- \overflow~0_combout\ = ( \x[3]~input_o\ & ( (\y[3]~input_o\ & ((!\x[2]~input_o\ & ((!\G1:1:adder|cout~0_combout\) # (!\y[2]~input_o\))) # (\x[2]~input_o\ & (!\G1:1:adder|cout~0_combout\ & !\y[2]~input_o\)))) ) ) # ( !\x[3]~input_o\ & ( (!\y[3]~input_o\ & 
-- ((!\x[2]~input_o\ & (\G1:1:adder|cout~0_combout\ & \y[2]~input_o\)) # (\x[2]~input_o\ & ((\y[2]~input_o\) # (\G1:1:adder|cout~0_combout\))))) ) )

-- pragma translate_off
GENERIC MAP (
	extended_lut => "off",
	lut_mask => "0001000001110000000011100000100000010000011100000000111000001000",
	shared_arith => "off")
-- pragma translate_on
PORT MAP (
	dataa => \ALT_INV_x[2]~input_o\,
	datab => \G1:1:adder|ALT_INV_cout~0_combout\,
	datac => \ALT_INV_y[3]~input_o\,
	datad => \ALT_INV_y[2]~input_o\,
	datae => \ALT_INV_x[3]~input_o\,
	combout => \overflow~0_combout\);

-- Location: MLABCELL_X15_Y64_N3
\~QUARTUS_CREATED_GND~I\ : cyclonev_lcell_comb
-- Equation(s):

-- pragma translate_off
GENERIC MAP (
	extended_lut => "off",
	lut_mask => "0000000000000000000000000000000000000000000000000000000000000000",
	shared_arith => "off")
-- pragma translate_on
;
END structure;



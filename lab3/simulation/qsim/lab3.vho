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

-- DATE "03/20/2018 23:19:28"

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

ENTITY 	mux16_to_1 IS
    PORT (
	data : IN std_logic_vector(15 DOWNTO 0);
	sel : IN std_logic_vector(3 DOWNTO 0);
	output : OUT std_logic
	);
END mux16_to_1;

-- Design Ports Information
-- output	=>  Location: PIN_AC27,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- data[0]	=>  Location: PIN_AD26,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- data[2]	=>  Location: PIN_Y26,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- data[1]	=>  Location: PIN_W25,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- data[3]	=>  Location: PIN_Y27,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- sel[1]	=>  Location: PIN_AC29,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- sel[0]	=>  Location: PIN_AA28,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- data[8]	=>  Location: PIN_AB30,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- data[10]	=>  Location: PIN_AB27,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- data[9]	=>  Location: PIN_V25,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- data[11]	=>  Location: PIN_AB28,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- data[4]	=>  Location: PIN_AH30,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- data[6]	=>  Location: PIN_AC30,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- data[5]	=>  Location: PIN_AF29,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- data[7]	=>  Location: PIN_AA26,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- data[12]	=>  Location: PIN_AA30,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- data[14]	=>  Location: PIN_AG30,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- data[13]	=>  Location: PIN_AC28,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- data[15]	=>  Location: PIN_AD29,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- sel[3]	=>  Location: PIN_AE29,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- sel[2]	=>  Location: PIN_AD30,	 I/O Standard: 2.5 V,	 Current Strength: Default


ARCHITECTURE structure OF mux16_to_1 IS
SIGNAL gnd : std_logic := '0';
SIGNAL vcc : std_logic := '1';
SIGNAL unknown : std_logic := 'X';
SIGNAL devoe : std_logic := '1';
SIGNAL devclrn : std_logic := '1';
SIGNAL devpor : std_logic := '1';
SIGNAL ww_devoe : std_logic;
SIGNAL ww_devclrn : std_logic;
SIGNAL ww_devpor : std_logic;
SIGNAL ww_data : std_logic_vector(15 DOWNTO 0);
SIGNAL ww_sel : std_logic_vector(3 DOWNTO 0);
SIGNAL ww_output : std_logic;
SIGNAL \~QUARTUS_CREATED_GND~I_combout\ : std_logic;
SIGNAL \sel[2]~input_o\ : std_logic;
SIGNAL \sel[0]~input_o\ : std_logic;
SIGNAL \data[1]~input_o\ : std_logic;
SIGNAL \sel[1]~input_o\ : std_logic;
SIGNAL \data[2]~input_o\ : std_logic;
SIGNAL \data[0]~input_o\ : std_logic;
SIGNAL \data[3]~input_o\ : std_logic;
SIGNAL \final_mux|extra|f~0_combout\ : std_logic;
SIGNAL \data[12]~input_o\ : std_logic;
SIGNAL \data[14]~input_o\ : std_logic;
SIGNAL \data[13]~input_o\ : std_logic;
SIGNAL \data[15]~input_o\ : std_logic;
SIGNAL \final_mux|extra|f~3_combout\ : std_logic;
SIGNAL \data[4]~input_o\ : std_logic;
SIGNAL \data[7]~input_o\ : std_logic;
SIGNAL \data[6]~input_o\ : std_logic;
SIGNAL \data[5]~input_o\ : std_logic;
SIGNAL \final_mux|extra|f~2_combout\ : std_logic;
SIGNAL \sel[3]~input_o\ : std_logic;
SIGNAL \data[8]~input_o\ : std_logic;
SIGNAL \data[11]~input_o\ : std_logic;
SIGNAL \data[9]~input_o\ : std_logic;
SIGNAL \data[10]~input_o\ : std_logic;
SIGNAL \final_mux|extra|f~1_combout\ : std_logic;
SIGNAL \final_mux|extra|f~4_combout\ : std_logic;
SIGNAL \ALT_INV_sel[2]~input_o\ : std_logic;
SIGNAL \ALT_INV_sel[3]~input_o\ : std_logic;
SIGNAL \ALT_INV_data[15]~input_o\ : std_logic;
SIGNAL \ALT_INV_data[13]~input_o\ : std_logic;
SIGNAL \ALT_INV_data[14]~input_o\ : std_logic;
SIGNAL \ALT_INV_data[12]~input_o\ : std_logic;
SIGNAL \ALT_INV_data[7]~input_o\ : std_logic;
SIGNAL \ALT_INV_data[5]~input_o\ : std_logic;
SIGNAL \ALT_INV_data[6]~input_o\ : std_logic;
SIGNAL \ALT_INV_data[4]~input_o\ : std_logic;
SIGNAL \ALT_INV_data[11]~input_o\ : std_logic;
SIGNAL \ALT_INV_data[9]~input_o\ : std_logic;
SIGNAL \ALT_INV_data[10]~input_o\ : std_logic;
SIGNAL \ALT_INV_data[8]~input_o\ : std_logic;
SIGNAL \ALT_INV_sel[0]~input_o\ : std_logic;
SIGNAL \ALT_INV_sel[1]~input_o\ : std_logic;
SIGNAL \ALT_INV_data[3]~input_o\ : std_logic;
SIGNAL \ALT_INV_data[1]~input_o\ : std_logic;
SIGNAL \ALT_INV_data[2]~input_o\ : std_logic;
SIGNAL \ALT_INV_data[0]~input_o\ : std_logic;
SIGNAL \final_mux|extra|ALT_INV_f~3_combout\ : std_logic;
SIGNAL \final_mux|extra|ALT_INV_f~2_combout\ : std_logic;
SIGNAL \final_mux|extra|ALT_INV_f~1_combout\ : std_logic;
SIGNAL \final_mux|extra|ALT_INV_f~0_combout\ : std_logic;

BEGIN

ww_data <= data;
ww_sel <= sel;
output <= ww_output;
ww_devoe <= devoe;
ww_devclrn <= devclrn;
ww_devpor <= devpor;
\ALT_INV_sel[2]~input_o\ <= NOT \sel[2]~input_o\;
\ALT_INV_sel[3]~input_o\ <= NOT \sel[3]~input_o\;
\ALT_INV_data[15]~input_o\ <= NOT \data[15]~input_o\;
\ALT_INV_data[13]~input_o\ <= NOT \data[13]~input_o\;
\ALT_INV_data[14]~input_o\ <= NOT \data[14]~input_o\;
\ALT_INV_data[12]~input_o\ <= NOT \data[12]~input_o\;
\ALT_INV_data[7]~input_o\ <= NOT \data[7]~input_o\;
\ALT_INV_data[5]~input_o\ <= NOT \data[5]~input_o\;
\ALT_INV_data[6]~input_o\ <= NOT \data[6]~input_o\;
\ALT_INV_data[4]~input_o\ <= NOT \data[4]~input_o\;
\ALT_INV_data[11]~input_o\ <= NOT \data[11]~input_o\;
\ALT_INV_data[9]~input_o\ <= NOT \data[9]~input_o\;
\ALT_INV_data[10]~input_o\ <= NOT \data[10]~input_o\;
\ALT_INV_data[8]~input_o\ <= NOT \data[8]~input_o\;
\ALT_INV_sel[0]~input_o\ <= NOT \sel[0]~input_o\;
\ALT_INV_sel[1]~input_o\ <= NOT \sel[1]~input_o\;
\ALT_INV_data[3]~input_o\ <= NOT \data[3]~input_o\;
\ALT_INV_data[1]~input_o\ <= NOT \data[1]~input_o\;
\ALT_INV_data[2]~input_o\ <= NOT \data[2]~input_o\;
\ALT_INV_data[0]~input_o\ <= NOT \data[0]~input_o\;
\final_mux|extra|ALT_INV_f~3_combout\ <= NOT \final_mux|extra|f~3_combout\;
\final_mux|extra|ALT_INV_f~2_combout\ <= NOT \final_mux|extra|f~2_combout\;
\final_mux|extra|ALT_INV_f~1_combout\ <= NOT \final_mux|extra|f~1_combout\;
\final_mux|extra|ALT_INV_f~0_combout\ <= NOT \final_mux|extra|f~0_combout\;

-- Location: IOOBUF_X89_Y16_N22
\output~output\ : cyclonev_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	shift_series_termination_control => "false")
-- pragma translate_on
PORT MAP (
	i => \final_mux|extra|f~4_combout\,
	devoe => ww_devoe,
	o => ww_output);

-- Location: IOIBUF_X89_Y25_N38
\sel[2]~input\ : cyclonev_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_sel(2),
	o => \sel[2]~input_o\);

-- Location: IOIBUF_X89_Y21_N55
\sel[0]~input\ : cyclonev_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_sel(0),
	o => \sel[0]~input_o\);

-- Location: IOIBUF_X89_Y20_N44
\data[1]~input\ : cyclonev_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_data(1),
	o => \data[1]~input_o\);

-- Location: IOIBUF_X89_Y20_N95
\sel[1]~input\ : cyclonev_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_sel(1),
	o => \sel[1]~input_o\);

-- Location: IOIBUF_X89_Y25_N4
\data[2]~input\ : cyclonev_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_data(2),
	o => \data[2]~input_o\);

-- Location: IOIBUF_X89_Y16_N4
\data[0]~input\ : cyclonev_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_data(0),
	o => \data[0]~input_o\);

-- Location: IOIBUF_X89_Y25_N21
\data[3]~input\ : cyclonev_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_data(3),
	o => \data[3]~input_o\);

-- Location: LABCELL_X88_Y21_N30
\final_mux|extra|f~0\ : cyclonev_lcell_comb
-- Equation(s):
-- \final_mux|extra|f~0_combout\ = ( \data[0]~input_o\ & ( \data[3]~input_o\ & ( (!\sel[0]~input_o\ & (((!\sel[1]~input_o\) # (\data[2]~input_o\)))) # (\sel[0]~input_o\ & (((\sel[1]~input_o\)) # (\data[1]~input_o\))) ) ) ) # ( !\data[0]~input_o\ & ( 
-- \data[3]~input_o\ & ( (!\sel[0]~input_o\ & (((\sel[1]~input_o\ & \data[2]~input_o\)))) # (\sel[0]~input_o\ & (((\sel[1]~input_o\)) # (\data[1]~input_o\))) ) ) ) # ( \data[0]~input_o\ & ( !\data[3]~input_o\ & ( (!\sel[0]~input_o\ & (((!\sel[1]~input_o\) # 
-- (\data[2]~input_o\)))) # (\sel[0]~input_o\ & (\data[1]~input_o\ & (!\sel[1]~input_o\))) ) ) ) # ( !\data[0]~input_o\ & ( !\data[3]~input_o\ & ( (!\sel[0]~input_o\ & (((\sel[1]~input_o\ & \data[2]~input_o\)))) # (\sel[0]~input_o\ & (\data[1]~input_o\ & 
-- (!\sel[1]~input_o\))) ) ) )

-- pragma translate_off
GENERIC MAP (
	extended_lut => "off",
	lut_mask => "0001000000011010101100001011101000010101000111111011010110111111",
	shared_arith => "off")
-- pragma translate_on
PORT MAP (
	dataa => \ALT_INV_sel[0]~input_o\,
	datab => \ALT_INV_data[1]~input_o\,
	datac => \ALT_INV_sel[1]~input_o\,
	datad => \ALT_INV_data[2]~input_o\,
	datae => \ALT_INV_data[0]~input_o\,
	dataf => \ALT_INV_data[3]~input_o\,
	combout => \final_mux|extra|f~0_combout\);

-- Location: IOIBUF_X89_Y21_N21
\data[12]~input\ : cyclonev_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_data(12),
	o => \data[12]~input_o\);

-- Location: IOIBUF_X89_Y16_N55
\data[14]~input\ : cyclonev_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_data(14),
	o => \data[14]~input_o\);

-- Location: IOIBUF_X89_Y20_N78
\data[13]~input\ : cyclonev_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_data(13),
	o => \data[13]~input_o\);

-- Location: IOIBUF_X89_Y23_N55
\data[15]~input\ : cyclonev_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_data(15),
	o => \data[15]~input_o\);

-- Location: LABCELL_X88_Y21_N18
\final_mux|extra|f~3\ : cyclonev_lcell_comb
-- Equation(s):
-- \final_mux|extra|f~3_combout\ = ( \sel[0]~input_o\ & ( \data[15]~input_o\ & ( (\data[13]~input_o\) # (\sel[1]~input_o\) ) ) ) # ( !\sel[0]~input_o\ & ( \data[15]~input_o\ & ( (!\sel[1]~input_o\ & (\data[12]~input_o\)) # (\sel[1]~input_o\ & 
-- ((\data[14]~input_o\))) ) ) ) # ( \sel[0]~input_o\ & ( !\data[15]~input_o\ & ( (!\sel[1]~input_o\ & \data[13]~input_o\) ) ) ) # ( !\sel[0]~input_o\ & ( !\data[15]~input_o\ & ( (!\sel[1]~input_o\ & (\data[12]~input_o\)) # (\sel[1]~input_o\ & 
-- ((\data[14]~input_o\))) ) ) )

-- pragma translate_off
GENERIC MAP (
	extended_lut => "off",
	lut_mask => "0101001101010011000000001111000001010011010100110000111111111111",
	shared_arith => "off")
-- pragma translate_on
PORT MAP (
	dataa => \ALT_INV_data[12]~input_o\,
	datab => \ALT_INV_data[14]~input_o\,
	datac => \ALT_INV_sel[1]~input_o\,
	datad => \ALT_INV_data[13]~input_o\,
	datae => \ALT_INV_sel[0]~input_o\,
	dataf => \ALT_INV_data[15]~input_o\,
	combout => \final_mux|extra|f~3_combout\);

-- Location: IOIBUF_X89_Y16_N38
\data[4]~input\ : cyclonev_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_data(4),
	o => \data[4]~input_o\);

-- Location: IOIBUF_X89_Y23_N4
\data[7]~input\ : cyclonev_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_data(7),
	o => \data[7]~input_o\);

-- Location: IOIBUF_X89_Y25_N55
\data[6]~input\ : cyclonev_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_data(6),
	o => \data[6]~input_o\);

-- Location: IOIBUF_X89_Y15_N38
\data[5]~input\ : cyclonev_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_data(5),
	o => \data[5]~input_o\);

-- Location: LABCELL_X88_Y21_N42
\final_mux|extra|f~2\ : cyclonev_lcell_comb
-- Equation(s):
-- \final_mux|extra|f~2_combout\ = ( \sel[0]~input_o\ & ( \sel[1]~input_o\ & ( \data[7]~input_o\ ) ) ) # ( !\sel[0]~input_o\ & ( \sel[1]~input_o\ & ( \data[6]~input_o\ ) ) ) # ( \sel[0]~input_o\ & ( !\sel[1]~input_o\ & ( \data[5]~input_o\ ) ) ) # ( 
-- !\sel[0]~input_o\ & ( !\sel[1]~input_o\ & ( \data[4]~input_o\ ) ) )

-- pragma translate_off
GENERIC MAP (
	extended_lut => "off",
	lut_mask => "0101010101010101000000001111111100001111000011110011001100110011",
	shared_arith => "off")
-- pragma translate_on
PORT MAP (
	dataa => \ALT_INV_data[4]~input_o\,
	datab => \ALT_INV_data[7]~input_o\,
	datac => \ALT_INV_data[6]~input_o\,
	datad => \ALT_INV_data[5]~input_o\,
	datae => \ALT_INV_sel[0]~input_o\,
	dataf => \ALT_INV_sel[1]~input_o\,
	combout => \final_mux|extra|f~2_combout\);

-- Location: IOIBUF_X89_Y23_N38
\sel[3]~input\ : cyclonev_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_sel(3),
	o => \sel[3]~input_o\);

-- Location: IOIBUF_X89_Y21_N4
\data[8]~input\ : cyclonev_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_data(8),
	o => \data[8]~input_o\);

-- Location: IOIBUF_X89_Y21_N38
\data[11]~input\ : cyclonev_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_data(11),
	o => \data[11]~input_o\);

-- Location: IOIBUF_X89_Y20_N61
\data[9]~input\ : cyclonev_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_data(9),
	o => \data[9]~input_o\);

-- Location: IOIBUF_X89_Y23_N21
\data[10]~input\ : cyclonev_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_data(10),
	o => \data[10]~input_o\);

-- Location: LABCELL_X88_Y21_N6
\final_mux|extra|f~1\ : cyclonev_lcell_comb
-- Equation(s):
-- \final_mux|extra|f~1_combout\ = ( \sel[0]~input_o\ & ( \data[10]~input_o\ & ( (!\sel[1]~input_o\ & ((\data[9]~input_o\))) # (\sel[1]~input_o\ & (\data[11]~input_o\)) ) ) ) # ( !\sel[0]~input_o\ & ( \data[10]~input_o\ & ( (\sel[1]~input_o\) # 
-- (\data[8]~input_o\) ) ) ) # ( \sel[0]~input_o\ & ( !\data[10]~input_o\ & ( (!\sel[1]~input_o\ & ((\data[9]~input_o\))) # (\sel[1]~input_o\ & (\data[11]~input_o\)) ) ) ) # ( !\sel[0]~input_o\ & ( !\data[10]~input_o\ & ( (\data[8]~input_o\ & 
-- !\sel[1]~input_o\) ) ) )

-- pragma translate_off
GENERIC MAP (
	extended_lut => "off",
	lut_mask => "0101010100000000000011110011001101010101111111110000111100110011",
	shared_arith => "off")
-- pragma translate_on
PORT MAP (
	dataa => \ALT_INV_data[8]~input_o\,
	datab => \ALT_INV_data[11]~input_o\,
	datac => \ALT_INV_data[9]~input_o\,
	datad => \ALT_INV_sel[1]~input_o\,
	datae => \ALT_INV_sel[0]~input_o\,
	dataf => \ALT_INV_data[10]~input_o\,
	combout => \final_mux|extra|f~1_combout\);

-- Location: LABCELL_X88_Y21_N24
\final_mux|extra|f~4\ : cyclonev_lcell_comb
-- Equation(s):
-- \final_mux|extra|f~4_combout\ = ( \sel[3]~input_o\ & ( \final_mux|extra|f~1_combout\ & ( (!\sel[2]~input_o\) # (\final_mux|extra|f~3_combout\) ) ) ) # ( !\sel[3]~input_o\ & ( \final_mux|extra|f~1_combout\ & ( (!\sel[2]~input_o\ & 
-- (\final_mux|extra|f~0_combout\)) # (\sel[2]~input_o\ & ((\final_mux|extra|f~2_combout\))) ) ) ) # ( \sel[3]~input_o\ & ( !\final_mux|extra|f~1_combout\ & ( (\sel[2]~input_o\ & \final_mux|extra|f~3_combout\) ) ) ) # ( !\sel[3]~input_o\ & ( 
-- !\final_mux|extra|f~1_combout\ & ( (!\sel[2]~input_o\ & (\final_mux|extra|f~0_combout\)) # (\sel[2]~input_o\ & ((\final_mux|extra|f~2_combout\))) ) ) )

-- pragma translate_off
GENERIC MAP (
	extended_lut => "off",
	lut_mask => "0010001001110111000001010000010100100010011101111010111110101111",
	shared_arith => "off")
-- pragma translate_on
PORT MAP (
	dataa => \ALT_INV_sel[2]~input_o\,
	datab => \final_mux|extra|ALT_INV_f~0_combout\,
	datac => \final_mux|extra|ALT_INV_f~3_combout\,
	datad => \final_mux|extra|ALT_INV_f~2_combout\,
	datae => \ALT_INV_sel[3]~input_o\,
	dataf => \final_mux|extra|ALT_INV_f~1_combout\,
	combout => \final_mux|extra|f~4_combout\);

-- Location: MLABCELL_X8_Y14_N0
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



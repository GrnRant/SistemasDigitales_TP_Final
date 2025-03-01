---------------------------------------------------------
--
-- Controlador de VGA
-- Version actualizada a 07/06/2016
--
-- Modulos:
--    vga_sync
--    gen_pixels
--
---------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_ctrl is
	generic(
		N_ADDRESS: natural := 11; --Memoria de 16x1200bits -> address máximo es 32000
		N_DATA: natural := 16 --Memoria de 16x1200bits -> "words" son de 1bit
	);
	port(
		clk: in std_logic;
		rst: in std_logic;
		rd_data: in unsigned(N_DATA - 1 downto 0);
		addr: out unsigned(N_ADDRESS - 1 downto 0);
		hsync: out std_logic;
		vsync: out std_logic;
		rgb: out std_logic_vector(2 downto 0)
	);
	
	-- attribute LOC: string;
	-- attribute LOC of clk: signal is "C9";
	-- attribute LOC of rst: signal is "D18";
	-- attribute LOC of sw: signal is "H18 L14 L13";
	-- attribute LOC of hsync: signal is "F15";
	-- attribute LOC of vsync: signal is "F14";
	-- attribute LOC of rgb: signal is "H14 H15 G15";

end vga_ctrl;

architecture vga_ctrl_arch of vga_ctrl is

	signal rgb_reg: std_logic_vector(2 downto 0);
	signal pixel_x, pixel_y: std_logic_vector(9 downto 0);
	signal video_on: std_logic;

begin

	-- instanciacion del controlador VGA
	vga_sync_unit: entity work.vga_sync
		port map(
			clk 	=> clk,
			rst 	=> rst,
			hsync 	=> hsync,
			vsync 	=> vsync,
			vidon	=> video_on,
			p_tick 	=> open,
			pixel_x => pixel_x,
			pixel_y => pixel_y
		);

	pixeles: entity work.gen_pixels
		generic map(
			N_ADDRESS => N_ADDRESS,
			N_DATA => N_DATA,
			TILES_SCALE => 4
		)
		port map(
			clk		=> clk,
			reset	=> rst,
			addr	=> addr,
			rd_data	=> rd_data,
			pixel_x	=> pixel_x,
			pixel_y	=> pixel_y,
			ena		=> video_on,
			rgb		=> rgb
		);

end vga_ctrl_arch;
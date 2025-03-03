---------------------------------------------------------
--
-- Generador de pixeles para la VGA
-- Version actualizada a 07/06/2016
--
-- Modulos:
-- 
--
---------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gen_pixels is
	generic(
		N_ADDRESS: natural := 11; --Memoria de 16x1200bits -> address máximo es 2047
		N_DATA: natural := 16; --Memoria de 16x1200bits -> "words" son de 1bit
		TILES_SCALE: natural := 4
	);
	port(
		clk: in std_logic;
		rst: in std_logic;
		pixel_x: in std_logic_vector (9 downto 0);
		pixel_y: in std_logic_vector (9 downto 0);
		ena: in std_logic;
		rd_data: in unsigned(N_DATA - 1 downto 0);
		addr: out unsigned(N_ADDRESS - 1 downto 0);
		rgb : out std_logic_vector(2 downto 0)
	);
	
end gen_pixels;

architecture gen_pixels_arch of gen_pixels is

	signal rgb_reg: std_logic_vector(2 downto 0);
	signal tile_x: integer := 0;
	signal tile_y: integer := 0;
	signal tile_index: integer;
	signal tile_bit: std_logic;
	constant H: natural := 480;
	constant W: natural := 640;

begin
	process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				tile_x <= 0;
				tile_y <= 0;
			else
				-- Coordenas de los tiles
				tile_x <= to_integer(unsigned(pixel_x)) / TILES_SCALE;
				tile_y <= to_integer(unsigned(pixel_y)) / TILES_SCALE;
			end if;
			-- Address en RAM del tile
			addr <= to_unsigned((tile_y * W/TILES_SCALE + tile_x) / 16, N_ADDRESS);
			tile_index <= (tile_y * W/TILES_SCALE + tile_x) mod 16;

			-- Leer valor del tile
			tile_bit <= rd_data(tile_index);

			-- Asignar 
			if tile_bit = '1' then
				rgb_reg <= "000"; -- Negro
			else
				rgb_reg <= "111"; -- Blanco
			end if;
		end if;
	end process;

	rgb <= rgb_reg when ena = '1' else "000";

end gen_pixels_arch;
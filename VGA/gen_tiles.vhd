library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gen_tiles is
    generic(
            N_CORDIC : natural := 16;
            N_ADDRESS : natural := 16;
            N_DATA : natural := 16;
            MAX_VAL : natural := 50 --Se calculó en base a BRAM y resolución de 480x640
    );
    port(
        x_in : in signed(N_CORDIC-1 downto 0);
        y_in : in signed(N_C-1 downto 0);
        z_in : in signed(N_C-1 downto 0);
        cordic_busy : in std_logic;
        address : out unsigned(N_ADDRESS-1 downto 0);
        wr_data : out unsigned(N_DATA-1 downto 0)
    );
end gen_tiles

architecture gen_tiles_arch of gen_tiles is
    
begin
    
    
    
end architecture gen_tiles_arch;
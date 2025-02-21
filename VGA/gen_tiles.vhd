library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gen_tiles is
    generic(
            N_CORDIC: natural := 16;
            N_ADDRESS: natural := 15; --Memoria de 32kx1bit -> address máximo es 32000
            N_DATA: natural := 16; --Memoria de 32kx1bit -> "words" son de 1bit
            MAX_VAL : natural := 50 --Se calculó en base a BRAM y resolución de 480x640
    );
    port(
        rst : in std_logic;
        clk : in std_logic;
        x_in : in signed(N_CORDIC-1 downto 0);
        y_in : in signed(N_CORDIC-1 downto 0);
        cordic_busy : in std_logic;
        wr : out std_logic;
        addr : out unsigned(N_ADDRESS-1 downto 0);
        wr_data : out unsigned(N_DATA-1 downto 0)
    );
end gen_tiles;

architecture gen_tiles_arch of gen_tiles is
    constant cordic_scale: integer := 2**(N_CORDIC-1)/MAX_VAL;
    signal x_coord: integer := 0;
    signal y_coord: integer := 0;
    signal bit_index: integer := 0;
    signal busy_pre_state: std_logic := '0';
begin
    P_GEN_TILES_MAIN: process(clk)
    begin
        if rising_edge(clk) then
            --Reset
            if rst = '1' then
                wr <= '0';
                addr <= (others => '0');
                wr_data <= (others => '0');
            end if;
            --Si se detectó que bajó la línea de busy, habilitar escritura
            if (busy_pre_state = '1' and cordic_busy = '0') then
                wr <= '1';
            else
                wr <= '0';
            end if;
            busy_pre_state <= cordic_busy;
        end if;
    end process;

    --Esto solo escribe un punto, necesito que haga dibujo entero
    x_coord <= to_integer(x_in)/cordic_scale;
    y_coord <= to_integer(y_in)/cordic_scale;
    bit_index <= x_coord - 160*y_coord + 9680;
    addr <= to_unsigned(bit_index/N_DATA, N_DATA);
    wr_data <= to_unsigned(bit_index mod N_DATA, N_DATA);

end architecture gen_tiles_arch;
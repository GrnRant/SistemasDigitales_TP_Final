library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gen_tiles is
    generic(
            N_CORDIC: natural := 16;
            N_ADDRESS: natural := 15; --Memoria de 32kx16bit -> address máximo es 32000
            N_DATA: natural := 16; --Memoria de 32kx16bit -> "words" son de 1bit
            MAX_CORDIC_COMP_VALUE: natural := 8192; --Valor máximo con el que puede venir una componente del cordic
            MAX_TILE_VAL: natural := 50; --Se calculó en base a BRAM y resolución de 480x640
            L_T: natural := 120;
            P_T: natural := 160
    );
    port(
        rst : in std_logic;
        clk : in std_logic;
        x_in : in signed(N_CORDIC - 1 downto 0);
        y_in : in signed(N_CORDIC - 1 downto 0);
        cordic_busy : in std_logic;
        wr : out std_logic;
        addr : out unsigned(N_ADDRESS - 1 downto 0);
        wr_data : out unsigned(N_DATA - 1 downto 0)
    );
end gen_tiles;

architecture gen_tiles_arch of gen_tiles is
    constant CORDIC_SCALE: integer := MAX_CORDIC_COMP_VALUE/MAX_TILE_VAL;
    signal x_comp: integer := 0;
    signal y_comp: integer := 0;
    signal x_pos: integer := 0;
    signal y_pos: integer := 0;
    signal p_tile: integer := 0; --Píxel actual
    signal l_tile: integer := 0; --Línea actual
    signal bit_index: integer := 0; --Número de píxel, ubicado en (p_tile, l_tile)
    signal bit_value: std_logic := '0'; --Valor de píxel actual
    signal busy_pre_state: std_logic := '0';
    signal wr_aux: std_logic := '0';
begin
    P_GEN_TILES_MAIN: process(clk)
    variable n: natural := 1;

    begin
        if rising_edge(clk) then
            --Reset
            if rst = '1' then
                p_tile <= 0;
                l_tile <= 0;
                bit_value <= '0';
                wr_aux <= '0';
                addr <= (others => '0');
                wr_data <= (others => '0');
            end if;

            --Si se detectó que bajó la línea de busy hay datos nuevos (habilitar escritura y resetar posiciones)
            if (busy_pre_state = '1' and cordic_busy = '0') then
                p_tile <= 0;
                l_tile <= 0;
                bit_value <= '0';
                wr_aux <= '1';
            end if;

            --Si está habilitada la escritura, setear siguiente tile
            if wr_aux = '1' then
                --Ejes
                if p_tile = P_T/2 or l_tile = L_T/2 then
                    bit_value <= '1';
                --Vector
                elsif p_tile = ((P_T/2 + x_comp)/n) and l_tile = ((L_T/2 - y_comp)/n) then
                    bit_value <= '1';
                    n := n + 1;
                --Cualquier otro tile
                else
                    bit_value <= '0';
                end if;

                --Número de tile a pintar
                bit_index <= p_tile + P_T*l_tile;
                --Address de word que contiene el tile
                addr <= to_unsigned(bit_index/N_DATA, N_ADDRESS);
                --Bit del word que representa al tile
                wr_data(bit_index mod N_DATA) <= bit_value;

                --Actualizar valores de p_tile y l_tile
                if p_tile < (P_T - 1) then
                    p_tile <= p_tile + 1;
                --Si se llegó a final de línea saltar a la siguiente
                elsif l_tile < (L_T - 1) then
                    p_tile <= 0;
                    l_tile <= l_tile + 1;
                --Si se llega a final deshabilitar escritura
                else
                    wr_aux <= '0';
                end if;

            end if;

            --Para detección de flanco descendente de busy
            busy_pre_state <= cordic_busy;
        end if;
    end process;

    wr <= wr_aux;
    --Valores de las componentes (se escalan al tile)
    x_comp <= to_integer(x_in)/CORDIC_SCALE;
    y_comp <= to_integer(y_in)/CORDIC_SCALE;

end architecture gen_tiles_arch;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.textio.all;

entity cordic_tb is 
end entity cordic_tb;

architecture cordic_tb_arq of cordic_tb is

    constant N : natural := 16;
    constant FILE_PATH  : string := "Datos.txt";
    
    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal req : std_logic := '0';
    signal rot0_vec1 : std_logic := '0';
    signal x_in,y_in,z_in : signed(N-1 downto 0);
    signal x_out,y_out,z_out : signed(N-1 downto 0);

    signal count : integer := 0;

    file datos: text open read_mode is FILE_PATH;


begin

    clk <= not clk after 10 us;

    Test_Sequence: process
    
        variable l   : line;
        variable ch  : character := ' ';
        variable aux : integer;
        variable z_file: integer;
        variable ANG_RAD: real;
        variable ANG_Z : integer;
        
    begin
    
        while not(endfile(datos)) loop
            wait until rising_edge(clk);
            -- Se lee una linea del archivo de valores de prueba
            readline(datos, l);
            -- Se extrae un entero de la linea
            read(l, aux);
            -- Se carga el valor de la coordenada X (en fondo de escala)
            x_in <= to_signed(aux, N);
            -- Se lee un caracter (el espacio)
            read(l, ch);
            -- Se lee otro entero de la linea
            read(l, aux);
            -- Se carga el valor de la coordenada Y (en fondo de escala)
            y_in <= to_signed(aux, N);
            -- Se lee otro caracter (el espacio)
            read(l, ch);
            -- Se lee otro entero
            read(l, aux);
            -- Se carga el valor del angulo a rotar (en grados)
            z_file := aux;
            
            -- Opero con el angulo a rotar.
            ANG_Z := integer( round( (real(z_file)*(2.0**(N-1)-1.0) / 180.0) ) ); -- Lo escalo 
            
            -- Se carga el valor correspondiente del angulo a rotar
            z_in <= to_signed(ANG_Z, N);
            
            rst <= '1';
            wait until rising_edge(clk);
            rst <= '0';
            wait until count = N;
            wait until rising_edge(clk);
        end loop;
    
        file_close(datos); -- Se cierra el archivo

        -- Se aborta la simulacion (fin del archivo)
        assert false report
            "Fin de la simulacion" severity failure;

    end process Test_Sequence;

    P_STAGES_COUNT: process(clk)
    begin
        if rising_edge(clk) then
            if count >= N then
                count <= 0;
            else
                count <= count + 1;
            end if;
        end if;
    end process;

    --Cambiar arquitectura en función de la que se quiera probar
    DUT_CORDIC: entity work.cordic(cordic_rolled_arch)
    generic map(
        N => N
    )
    port map(
        clk => clk,
        start => rst,
        mode => rot0_vec1,
        x0 => x_in,
        y0 => y_in,
        z0 => z_in,
        xr => x_out,
        yr => y_out,
        zr => z_out
        
    );

end architecture cordic_tb_arq;
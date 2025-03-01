-- En este archivo se encuentran el CORDIC con sus dos respectivas arquitecturas,
-- la enrollada ("cordic_rolled") y la desenrollada con pipeling ("cordic_unrolled").
-- Además cada arquitectura tiene su precordic, falta postcordic, que es la división por la ganancia
-- de cordic del resultado, por ejemplo con 15 iteraciones se debe dividir todo por 1.64 aproximadamente.
-- Para el cordic_rolled el 'start' se debe poner en '1' y luego en '0', y ahí inicia.
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.utils.all;

entity cordic is
    --N cantidad de bits para cuentas, ITERATIONS cantidad de iteraciones, N_CONT bits del contador elegido 
    --en función de la cantidad de ITERATIONS (no debe superares) y FRAC cantidad de decimales en cuentas
    --(es decir cantidad de bits de la parte fraccionaria de los números en binario)  
    generic(N: natural := 16; N_CONT : natural := 4; ITERATIONS: natural := 15; GAIN_DECIMALS: natural := 3);
    port(x0 : in signed(N-1 downto 0);  --Valor de entrada al cordic
        y0 : in signed(N-1 downto 0);   --Valor de entrada al cordic
        z0 : in signed(N-1 downto 0);   --Valor de entrada al cordic
        xr : out signed(N-1 downto 0);  --Valor de salida del cordic
        yr : out signed(N-1 downto 0);  --Valor de salida del cordic
        zr : out signed(N-1 downto 0);  --Valor de salida del cordic
        busy : out std_logic;           --Igual a '1' mientras el cordic esté trabajando
        start : in std_logic;           --Indica el inicio para el cordic rolled y reset para el unrolled 
        clk : in std_logic;             --Clock del cordic
        rst : in std_logic;             --Reset del cordic
        mode : in std_logic             --Modo de operacion (rotación => '1', vector => '0')
    );
end cordic;

architecture cordic_rolled_arch of cordic is
    signal i : natural;
    signal x_pre : signed(N-1 downto 0);  --Salida del precordic
    signal y_pre : signed(N-1 downto 0);  --Salida del precordic
    signal z_pre : signed(N-1 downto 0);  --Salida del precordic
    signal x_in : signed(N-1 downto 0);   --Entrada a etapa cordic
    signal y_in : signed(N-1 downto 0);   --Entrada a etapa cordic
    signal z_in : signed(N-1 downto 0);   --Entrada a etapa cordic
    signal x_act : signed(N-1 downto 0);  --Salida del registro de salida
    signal y_act : signed(N-1 downto 0);  --Salida del registro de salida
    signal z_act : signed(N-1 downto 0);  --Salida del registro de salida
    signal x_next : signed(N-1 downto 0); --Salida del cordic
    signal y_next : signed(N-1 downto 0); --Salida del cordic
    signal z_next : signed(N-1 downto 0); --Salida del cordic
    constant betas: int_array(ITERATIONS-1 downto 0) := gen_atan_table(N, ITERATIONS); --LUT con betas por iteración
    signal beta : signed(N-1 downto 0); --Variable auxiliar
    signal count_en : std_logic; --Variable auxiliar para habilitación del contador
    constant gain_scaled : integer := integer(cordic_gain(ITERATIONS)*10.0**GAIN_DECIMALS); --Ganancia de CORDIC
    
begin
    --PRECORDIC
    PRECORDIC: entity work.precordic
    generic map(NP => N)
    port map(x_in => x0,
         y_in => y0,
         z_in => z0,
         x_out => x_pre,
         y_out => y_pre,
         z_out => z_pre,
         mode => mode
    );

     --CONTADOR
     COUNTER: entity work.counter
     generic map(MAX => (ITERATIONS-1))
     port map(
         clk => clk,
         ena => count_en,
         rst => start,
         count => i
     );
     --ETAPA CORDIC
     CORDIC_STAGE: entity work.cordic_stage
     generic map(NC => N)
    port map(x_in => x_in,
             y_in => y_in,
             z_in => z_in,
             x_out => x_next,
             y_out => y_next,
             z_out => z_next,
             beta => beta,
             shift => i,
             mode => mode
    );
    --REGISTROS A LA SALIDA
    REG_X: entity work.ffd
    generic map(NR => N)
    port map(rst => start,
             clk => clk,
             di => x_next,
             qo => x_act,
             ena => count_en
    );
    REG_Y: entity work.ffd
    generic map(NR => N)
    port map(rst => start,
             clk => clk,
             di => y_next,
             qo => y_act,
             ena => count_en
    );
    REG_Z: entity work.ffd
    generic map(NR => N)
    port map(rst => start,
             clk => clk,
             di => z_next,
             qo => z_act,
             ena => count_en
    );

--Asignación de valor de beta
beta <= to_signed(betas(i), N) when count_en = '1' else (others => '0');

--PROCESO PRINCIPAL DE INICIO Y TERMINADO
P_MAIN: process(clk)
variable pre_start: std_logic := '1';
begin
    if rising_edge(clk) then
        --Es como una especie de Reset
        if rst = '1' then
            count_en <= '0';
            xr <= (others => '0');
            yr <= (others => '0');
            zr <= (others => '0');
        --Detección de inicio
        elsif pre_start = '1' and start = '0' then
            count_en <= '1';
            xr <= (others => '0');
            yr <= (others => '0');
            zr <= (others => '0');
        end if;
        if i = ITERATIONS-1 then --Si final de las iteraciones
            count_en <= '0';
            xr <= to_signed(to_integer(x_act)*10**GAIN_DECIMALS/gain_scaled, N);
            yr <= to_signed(to_integer(y_act)*10**GAIN_DECIMALS/gain_scaled, N);
            zr <= z_act;
        end if;
        pre_start := start;
    end if;
end process;

x_in <= x_pre when i = 0 else x_act;
y_in <= y_pre when i = 0 else y_act;
z_in <= z_pre when i = 0 else z_act;

busy <= count_en;

end cordic_rolled_arch;
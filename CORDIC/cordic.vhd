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
    generic(N: natural := 16; N_CONT : natural := 4; ITERATIONS: natural := 15);
    port(x0 : in signed(N-1 downto 0);  --Valor de entrada al cordic
        y0 : in signed(N-1 downto 0);   --Valor de entrada al cordic
        z0 : in signed(N-1 downto 0);   --Valor de entrada al cordic
        xr : out signed(N-1 downto 0);  --Valor de salida del cordic
        yr : out signed(N-1 downto 0);  --Valor de salida del cordic
        zr : out signed(N-1 downto 0);  --Valor de salida del cordic
        start : in std_logic;           --Indica el inicio para el cordic rolled y reset para el unrolled 
        clk : in std_logic;             --Clock del cordic
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
    signal gain : integer; --Ganancia de CORDIC
    
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
             qo => x_act
    );
    REG_Y: entity work.ffd
    generic map(NR => N)
    port map(rst => start,
             clk => clk,
             di => y_next,
             qo => y_act
    );
    REG_Z: entity work.ffd
    generic map(NR => N)
    port map(rst => start,
             clk => clk,
             di => z_next,
             qo => z_act
    );

--Asignación de valor de beta
beta <= to_signed(betas(i), N) when count_en = '1' else (others => '0');

--PROCESO PRINCIPAL DE INICIO Y TERMINADO
P_MAIN: process(clk, i)
variable pre_start: std_logic := '1';
begin
    if rising_edge(clk) then
        --Detección de inicio
        if pre_start = '1' and start = '0' then
            count_en <= '1';
        end if;
        pre_start := start;
    end if;
    if i = 0 then
        x_in <= x_pre;
        y_in <= y_pre;
        z_in <= z_pre;
    else
        x_in <= x_act;
        y_in <= y_act;
        z_in <= z_act;
    end if;
    if i = ITERATIONS-1 then
        count_en <= '0';
    end if;
end process;

--Valores finales
xr <= x_act;
yr <= y_act;
zr <= z_act;

end cordic_rolled_arch;

architecture cordic_unrolled_arch of cordic is
    type array_of_signed is array(natural range <>) of signed(N-1 downto 0);

    signal x_pre : signed(N-1 downto 0);                --Salida del precordic
    signal y_pre : signed(N-1 downto 0);                --Salida del precordic
    signal z_pre : signed(N-1 downto 0);                --Salida del precordic
    signal x_i: array_of_signed(ITERATIONS downto 0);   --Entradas de etapas cordic
    signal y_i: array_of_signed(ITERATIONS downto 0);   --Entradas de etapas cordic
    signal z_i: array_of_signed(ITERATIONS downto 0);   --Entradas de etapas cordic
    signal x_o: array_of_signed(ITERATIONS downto 0);   --Salidas de etapas cordic
    signal y_o: array_of_signed(ITERATIONS downto 0);   --Salidas de etapas cordic
    signal z_o: array_of_signed(ITERATIONS downto 0);   --Salidas de etapas cordic

    constant betas: int_array(ITERATIONS-1 downto 0) := gen_atan_table(N, ITERATIONS); --LUT con betas por iteración

    signal mode_vec : std_logic_vector(ITERATIONS downto 0); --Usado para el pasaje del modo por las distintas etapas

    --COMPONENTES
    --Etapa cordic
    component cordic_stage
        generic(NC : natural);
        port(x_in : in signed(NC-1 downto 0);
            y_in : in signed(NC-1 downto 0);
            z_in : in signed(NC-1 downto 0);
            x_out : out signed(NC-1 downto 0);
            y_out : out signed(NC-1 downto 0);
            z_out : out signed(NC-1 downto 0);
            beta : in signed(NC-1 downto 0);
            shift : in integer;
            mode : in std_logic --Modo de operacion (rotación => '1', vector => '0')
        );
    end component;
    --Registros
    component ffd
    generic(NR: natural);
    port(
        di : in signed(NR-1 downto 0);
        qo : out signed(NR-1 downto 0);
        clk : in std_logic;
        rst : in std_logic
    );
    end component;

begin
    --Asignaciones
    --Señales de entrada
    x_i(0) <= x_pre;
    y_i(0) <= y_pre;
    z_i(0) <= z_pre;
    --Señales de salida
    xr <= x_i(ITERATIONS);
    yr <= y_i(ITERATIONS);
    zr <= z_i(ITERATIONS);
    --Modo de primera etapa
    mode_vec(0) <= mode;

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

    COMPONENTS: for i in 0 to ITERATIONS-1 generate
        CORDIC_STAGE_INST: cordic_stage
        generic map(NC => N)
        port map(x_in => x_i(i),
                 y_in => y_i(i),
                 z_in => z_i(i),
                 x_out => x_o(i),
                 y_out => y_o(i),
                 z_out => z_o(i),
                 beta => to_signed(betas(i), N),
                 shift => i,
                 mode => mode_vec(i)
        );

        REG_X_INST: ffd
        generic map(NR => N)
        port map(rst => start,
                 clk => clk,
                 di => x_o(i),
                 qo => x_i(i+1)
        );

        REG_Y_INST: ffd
        generic map(NR => N)
        port map(rst => start,
                 clk => clk,
                 di => y_o(i),
                 qo => y_i(i+1)
        );

        REG_Z_INST: ffd
        generic map(NR => N)
        port map(rst => start,
                 clk => clk,
                 di => z_o(i),
                 qo => z_i(i+1)
        );

    end generate;

    --Proceso que va despalazando el modo a través de las estapas
    --(serían los registros de desplazamiento del pin del modo)
    P_MODE_REG: process(clk)
        begin
        if rising_edge(clk) then
            if start = '1' then
                mode_vec(ITERATIONS downto 1) <= (others => '0');
            else
                mode_vec(ITERATIONS downto 1) <= mode_vec(ITERATIONS-1 downto 0);
            end if;
        end if;
    end process;
    
end cordic_unrolled_arch;
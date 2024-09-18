library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity cordic_stage is
    generic(NC : natural := 16);
    port(x_in : in signed(NC-1 downto 0);   --Entrada de etapa cordic
        y_in : in signed(NC-1 downto 0);    --Entrada de etapa cordic
        z_in : in signed(NC-1 downto 0);    --Entrada de etapa cordic
        x_out : out signed(NC-1 downto 0);  --Salida de etapa cordic
        y_out : out signed(NC-1 downto 0);  --Salida de etapa cordic
        z_out : out signed(NC-1 downto 0);  --Salida de etapa cordic
        beta : in signed(NC-1 downto 0);    --Beta de la etapa (depende del número de etapa o iteración)
        shift : in integer;                 --Cantidad de desplazamientos de la etapa (depende del número de etapa o iteración)
        mode : in std_logic                 --Modo de operacion (rotación => '1', vector => '0')
    );
end cordic_stage;

architecture cordic_stage_arch of cordic_stage is
    signal di : std_logic; --Seleccion suma o resta en las ALUs

begin
    --Valor de di (depende de si se eligió modo rotación o vector)
    di <= z_in(NC-1) when mode = '0' else not y_in(NC-1);

    --Componente x
    x_out <= x_in - (shift_right(y_in, shift)) when  di = '0' else x_in + (shift_right(y_in, shift));

    --Componente y
    y_out <= y_in + (shift_right(x_in, shift)) when  di = '0' else y_in - (shift_right(x_in, shift));

    --Componente z
    z_out <= z_in - beta when di = '0' else z_in + beta;

end cordic_stage_arch;
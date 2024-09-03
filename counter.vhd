library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity counter is
    generic (MAX : integer := 15);
    port (
        clk : in std_logic; --Clock del contador
        ena : in std_logic; --Habilitador
        rst : in std_logic; --Reset
        count : out natural --Salida del contador
    );
end counter;

architecture counter_arch of counter is
    signal aux : natural;
begin
    P_COUNTER : process (clk, rst)
    begin
        --En cada flanco ascendente
        if rising_edge(clk) then
            --Reset
            if rst = '1' then
                aux <= 0;
            else
                --Si contador está habilitado
                if ena = '1' then
                    --Si se llegó al máximo
                    if aux < MAX then
                        aux <= aux + 1;
                    else
                        aux <= 0;
                    end if;
                end if;
            end if;
        end if;
    end process;
    --Salida
    count <= 0 when rst = '1' else
        aux;
end counter_arch;
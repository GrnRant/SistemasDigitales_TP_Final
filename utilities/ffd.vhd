library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ffd is
    generic (NR : natural := 32);
    port (
        di : in signed(NR - 1 downto 0); --Entrada del flip-flop D
        qo : out signed(NR - 1 downto 0); --Salida
        clk : in std_logic; --Clock
        rst : in std_logic; --Reset
        ena : in std_logic --Enable
    );
end ffd;

architecture ffd_arch of ffd is
begin
    P_FFD : process (clk)
    begin
        --Salida igual a entrada en flanco ascendente
        if rising_edge(clk) then
            --Reset
            if rst = '1' then
                qo <= (others => '0');
            elsif ena = '1' then
                qo <= di;
            end if;
        end if;
    end process;
end ffd_arch;
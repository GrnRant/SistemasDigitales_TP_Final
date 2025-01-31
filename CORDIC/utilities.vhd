--Funciones y variables usadas en los distintos archivos
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.math_real.all;

package utils is
    type int_array is array (natural range <>) of integer;
    --Genera la tabla con los betas para cada iteración (sería la LUT)
    function gen_atan_table(size : natural; iterations : natural) return int_array;
    --Devuelve la ganacia cordic según la cantidad de iteraciones
    function cordic_gain(iterations : positive) return real;
    --Hace cierta cantidad de desplazamientos aritméticos (agrega unos) a derecha
    function shift_right(reg : signed; shift : natural) return signed;

end utils;

package body utils is
    ---------------------------------------------------------------------------------
    function gen_atan_table(size : natural; iterations : natural) return int_array is
        variable table : int_array(iterations-1 downto 0);
      begin
        for i in table'range loop
          --Escalado: (2.0**(size-1)-1.0)/180.0 ; arctan devuelve en radianes entonces se cancle 180°
          table(i) := integer((arctan(2.0 ** (-i)) / MATH_PI) * (2.0**(size-1)-1.0));
        end loop;
        return table;
    end function;
    ----------------------------------------------------------------------------------
    function cordic_gain(iterations : positive) return real is
        variable g : real := 1.0;
      begin
        for i in 0 to iterations-1 loop
          g := g * sqrt(1.0 + 2.0**(-2*i));
        end loop;
        return g;
      end function;
    ----------------------------------------------------------------------------------
    function shift_right(reg : signed; shift : natural) return signed is
        variable aux : signed(reg'range) := (others => '0');
    begin
        for i in (reg'length - 1) downto shift loop
            aux(i) := '0'; 
        end loop;
        for i in (shift - 1) downto 0 loop
            aux(i) := reg(i+shift); 
        end loop;
        return aux;
    end function;
    -----------------------------------------------------------------------------------
end utils;
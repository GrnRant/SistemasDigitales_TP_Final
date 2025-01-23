--Funciones y variables usadas en los distintos archivos
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.math_real.all;

package utils is
    type cordic_ctl_states is (S0, S_R, S_O, S_T, S_SPC, S_A, S_SPC_A, S_NUM1, S_NUM2, S_NUM3, S_C, S_SPC_C, S_C_H, S_C_A);

    constant R_CHAR: std_logic_vector(7 downto 0) := x"52";
    constant O_CHAR: std_logic_vector(7 downto 0) := x"4F";
    constant T_CHAR: std_logic_vector(7 downto 0) := x"54";
    constant SPC_CHAR: std_logic_vector(7 downto 0) := x"20";
    constant C_CHAR: std_logic_vector(7 downto 0) := x"43";
    constant A_CHAR: std_logic_vector(7 downto 0) := x"41";
    constant H_CHAR: std_logic_vector(7 downto 0) := x"48";
    constant NEW_LINE_CHAR: std_logic_vector(7 downto 0) := x"09";

    type cordic_ctl_cmds is (CMD_NONE, CMD_C_H, CMD_C_A, CMD_A);

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
          table(i) := integer(arctan(2.0**(-i)) * 2.0**size / MATH_2_PI);
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
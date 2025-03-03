--Funciones y variables usadas en los distintos archivos
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.math_real.all;

package utils is
    subtype cmd_ctl_states is std_logic_vector(3 downto 0);
    constant S0: cmd_ctl_states := "0000";
    constant S_R: cmd_ctl_states := "0001"; 
    constant S_O: cmd_ctl_states := "0010";
    constant S_T: cmd_ctl_states := "0011";
    constant S_SPC: cmd_ctl_states := "0100";
    constant S_A: cmd_ctl_states := "0101";
    constant S_SPC_A: cmd_ctl_states := "0110";
    constant S_NUM1: cmd_ctl_states := "0111";
    constant S_NUM2: cmd_ctl_states := "1000";
    constant S_NUM3: cmd_ctl_states := "1001";
    constant S_C: cmd_ctl_states := "1010";
    constant S_SPC_C: cmd_ctl_states := "1011";
    constant S_C_H: cmd_ctl_states := "1100";
    constant S_C_A: cmd_ctl_states := "1101";

    constant R_CHAR: std_logic_vector(7 downto 0) := x"52";
    constant O_CHAR: std_logic_vector(7 downto 0) := x"4F";
    constant T_CHAR: std_logic_vector(7 downto 0) := x"54";
    constant SPC_CHAR: std_logic_vector(7 downto 0) := x"20";
    constant C_CHAR: std_logic_vector(7 downto 0) := x"43";
    constant A_CHAR: std_logic_vector(7 downto 0) := x"41";
    constant H_CHAR: std_logic_vector(7 downto 0) := x"48";
    constant NEW_LINE_CHAR: std_logic_vector(7 downto 0) := x"0A";

    subtype cordic_ctl_cmds is std_logic_vector(1 downto 0);
    constant CMD_NONE: cordic_ctl_cmds := "00";
    constant CMD_C_H: cordic_ctl_cmds := "01";
    constant CMD_C_A: cordic_ctl_cmds := "10";
    constant CMD_A: cordic_ctl_cmds := "11";

    type int_array is array (natural range <>) of integer;
    --Genera la tabla con los betas para cada iteración (sería la LUT)
    function gen_atan_table(size : natural; iterations : natural) return int_array;
    --Devuelve la ganacia cordic según la cantidad de iteraciones
    function cordic_gain(iterations : positive) return real;

end utils;

package body utils is
    ---------------------------------------------------------------------------------
    function gen_atan_table(size : natural; iterations : natural) return int_array is
        variable table : int_array(iterations-1 downto 0);
      begin
        for i in table'range loop
          --Escalado: (2.0**(size-1)-1.0)/180.0 ; arctan devuelve en radianes entonces se cancela 180°
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
end utils;
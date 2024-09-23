library IEEE;
use IEEE.std_logic_1164.all;

package cordic_ctl_utils_package is

    type cordic_ctl_states is (S0, S_R, S_O, S_T, S_SPC, S_A, S_SPC_A, S_NUM1, S_NUM2, S_NUM3, S_C, S_SPC_C, S_C_H, S_C_A);

    type cordic_ctl_cmds is (CMD_NONE, CMD_C_H, CMD_C_A, CMD_A);

    constant R_CHAR: std_logic_vector(7 downto 0) := x"52";
    constant O_CHAR: std_logic_vector(7 downto 0) := x"4F";
    constant T_CHAR: std_logic_vector(7 downto 0) := x"54";
    constant SPC_CHAR: std_logic_vector(7 downto 0) := x"20";
    constant C_CHAR: std_logic_vector(7 downto 0) := x"43";
    constant A_CHAR: std_logic_vector(7 downto 0) := x"41";
    constant H_CHAR: std_logic_vector(7 downto 0) := x"48";
    constant NEW_LINE_CHAR: std_logic_vector(7 downto 0) := x"09";

end package cordic_ctl_utils_package;

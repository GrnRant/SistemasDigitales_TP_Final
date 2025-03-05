library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.utils.all;

entity cmd_ctl is
	generic (
		BAUD_RATE : integer := 115200;
		CLOCK_RATE : integer := 50E6;
		N : natural := 16
	);
	port (
		clk_pin : in std_logic; 
		rst_pin : in std_logic; 
		--Inputs de la UART
		rx_data : in std_logic_vector(7 downto 0); -- Data output de uart_rx
		rx_data_rdy : in std_logic; -- Data ready output de uart_rx
		--Outputs de cmd_ctl
		cmd_out : out cordic_ctl_cmds;
		ang_out : out signed(N - 1 downto 0);
		ang_chg : out std_logic
	);
end;

architecture cmd_ctl_arq of cmd_ctl is
	--Señales relacionadas a comandos y estados
    signal current_state : cmd_ctl_states := S0;
	signal rx_data_rdy_prev: std_logic := '0';
	signal ang: integer := 0;
	constant ANG_CHG_PIN_CYCLES: natural := 2; --Cantidad de ciclos en los que se mantiene la señal de ang_chg

begin
	--FSM de cordic_ctl
	CORDIC_CTL_FSM: process(clk_pin)
		variable ang_chg_cycle_count: natural := ANG_CHG_PIN_CYCLES - 1;
		begin
		if rising_edge(clk_pin) then
			--Reset
			if rst_pin = '1' then
				cmd_out <= CMD_NONE;
				ang <= 0; 
				ang_chg <= '0';
			end if;
			--Reseteado de pin de ang_chg
			if ang_chg_cycle_count >= (ANG_CHG_PIN_CYCLES - 1) then
				ang_chg <= '0';
			else
				ang_chg_cycle_count := ang_chg_cycle_count + 1;
			end if;
			--FSM de UART
			if (rx_data_rdy = '1' and rx_data_rdy_prev = '0') then
				C_CORDIC_CTL_STATES : case current_state is
					when S0 =>
						ang <= 0;
						if rx_data = R_CHAR then
							current_state <= S_R;
						end if;
					when S_R =>
						if rx_data = O_CHAR then
							current_state <= S_O;
						else
							current_state <= S0;
						end if;
					when S_O =>
						if rx_data = T_CHAR then
							current_state <= S_T;
						else
							current_state <= S0;
						end if;
					when S_T =>
						if rx_data = SPC_CHAR then
							current_state <= S_SPC;
						else
							current_state <= S0;
						end if;
					when S_SPC =>
						if rx_data = C_CHAR then
							current_state <= S_C;
						elsif rx_data = A_CHAR then
							current_state <= S_A;
						else
							current_state <= S0;
						end if;
					when S_C =>
						if rx_data = SPC_CHAR then
							current_state <= S_SPC_C;
						else
							current_state <= S0;
						end if;
					when S_A =>
						if rx_data = SPC_CHAR then
							current_state <= S_SPC_A;
						else
							current_state <= S0;
						end if;
					when S_SPC_C =>
						if rx_data = H_CHAR then
							current_state <= S_C_H;
						elsif rx_data = A_CHAR then
							current_state <= S_C_A;
						else
							current_state <= S0;
						end if;
					when S_SPC_A =>
						if (unsigned(rx_data) >= to_unsigned(48, 8)) and (unsigned(rx_data) <= to_unsigned(57, 8)) then
							current_state <= S_NUM1;
							ang <= to_integer(unsigned(rx_data) - to_unsigned(48, 8));
						else
							current_state <= S0;
						end if;
					when S_C_H =>
						if rx_data = NEW_LINE_CHAR then
							cmd_out <= CMD_C_H;
						end if;
						current_state <= S0;
					when S_C_A =>
						if rx_data = NEW_LINE_CHAR then
							cmd_out <= CMD_C_A;
						end if;
						current_state <= S0;
					when S_NUM1 =>
						if (unsigned(rx_data) >= to_unsigned(48, 8)) and (unsigned(rx_data) <= to_unsigned(57, 8)) then
							current_state <= S_NUM2;
							ang <= ang*10 + to_integer(unsigned(rx_data) - to_unsigned(48, 8));
						elsif rx_data = NEW_LINE_CHAR then
							current_state <= S0;
							cmd_out <= CMD_A;
							ang_chg <= '1';
							ang_chg_cycle_count := 0; --Para comenzar conteo de ciclos de pin ang_chg en alto
						else
							current_state <= S0;
						end if;
					when S_NUM2 =>
						if (unsigned(rx_data) >= to_unsigned(48, 8)) and (unsigned(rx_data) <= to_unsigned(57, 8)) then
							current_state <= S_NUM3;
							ang <= ang*10 + to_integer(unsigned(rx_data) - to_unsigned(48, 8));
						elsif rx_data = NEW_LINE_CHAR then
							current_state <= S0;
							cmd_out <= CMD_A;
							ang_chg <= '1';
							ang_chg_cycle_count := 0; --Para comenzar conteo de ciclos de pin ang_chg en alto
						else
							current_state <= S0;
						end if;
					when S_NUM3 =>
						if rx_data = NEW_LINE_CHAR then
							cmd_out <= CMD_A;
							ang_chg <= '1';
							ang_chg_cycle_count := 0; --Para comenzar conteo de ciclos de pin ang_chg en alto
						end if;
						current_state <= S0;
					when others =>
							
				end case;
			end if;
			rx_data_rdy_prev <= rx_data_rdy;
			ang_out <= to_signed(ang, N);
		end if;
	end process;
end;
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
		-- Entradas
		clk_pin : in std_logic; -- Clock input (from pin)
		rst_pin : in std_logic; -- Active HIGH reset (from pin)
		rxd_pin : in std_logic; -- RS232 RXD pin - directly from pin
		-- Salidas
		cmd_out : out cordic_ctl_cmds;
		ang_out : out signed(N + 1 downto 0)
	);
end;

architecture cmd_ctl_arq of cmd_ctl is
	signal rst_clk_rx : std_logic;

	-- Entre uart y cordic_ctl
	signal rx_data : std_logic_vector(7 downto 0); -- Data output of uart_rx
	signal rx_data_rdy : std_logic; -- Data ready output of uart_rx

	--Señales relacionadas a comandos y estados
    signal current_state : cordic_ctl_states := S0;

begin
	-- Metastability harden the rst - this is an asynchronous input to the
	-- system (from a pushbutton), and is used in synchronous logic. Therefore
	-- it must first be synchronized to the clock domain (clk_pin in this case)
	-- prior to being used. A simple metastability hardener is appropriate here.
	META_HARDEN_RST: entity work.meta_harden
	port map(
		clk_dst => clk_pin,
		rst_dst => '0', -- No reset on the hardener for reset!
		signal_src => rst_pin,
		signal_dst => rst_clk_rx
	);

	UART_RX_INSTANCE : entity work.uart_rx
	generic map(
		CLOCK_RATE => CLOCK_RATE,
		BAUD_RATE => BAUD_RATE
	)
	port map(
		clk_rx => clk_pin,
		rst_clk_rx => rst_clk_rx,

		rxd_i => rxd_pin,
		rxd_clk_rx => open,

		rx_data_rdy => rx_data_rdy,
		rx_data => rx_data,
		frm_err => open
	);
	--FSM de cordic_ctl
	CORDIC_CTL_FSM: process(clk_pin)
		variable ang_num1 : integer :=0;
		variable ang_num2 : integer :=0;
		variable ang_num3 : integer :=0;
		begin
		if rising_edge(clk_pin) then
			if rst_pin = '1' then
				cmd_out <= CMD_NONE;
				ang_out <= (others => '0');
			elsif rx_data_rdy = '1' then
				C_CORDIC_CTL_STATES : case current_state is
					when S0 =>
						ang_num1 := 0;
						ang_num2 := 0;
						ang_num3 := 0;
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
							current_state <= S_C;
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
						if (unsigned(rx_data) >= to_unsigned(48, 8)) and (unsigned(rx_data) <= to_unsigned(48, 8)) then
							current_state <= S_NUM1;
							ang_num1 := to_integer(unsigned(rx_data));
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
						if (unsigned(rx_data) >= to_unsigned(48, 8)) and (unsigned(rx_data) <= to_unsigned(48, 8)) then
							current_state <= S_NUM2;
							ang_num2 := to_integer(unsigned(rx_data));
						elsif rx_data = NEW_LINE_CHAR then
							current_state <= S0;
							cmd_out <= CMD_A;
						else
							current_state <= S0;
						end if;
					when S_NUM2 =>
						if (unsigned(rx_data) >= to_unsigned(48, 8)) and (unsigned(rx_data) <= to_unsigned(48, 8)) then
							current_state <= S_NUM3;
							ang_num3 := to_integer(unsigned(rx_data));
						elsif rx_data = NEW_LINE_CHAR then
							current_state <= S0;
							cmd_out <= CMD_A;
						else
							current_state <= S0;
						end if;
					when S_NUM3 =>
						if rx_data = NEW_LINE_CHAR then
							cmd_out <= CMD_A;
						end if;
						current_state <= S0;
				end case;
			end if;
			ang_out <= to_signed(100*ang_num3 + 10*ang_num2 + ang_num1, N + 2);
		end if;
	end process;
end;
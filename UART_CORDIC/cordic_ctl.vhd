-------------------------------------------------------------------------------
--  
--  Copyright (c) 2009 Xilinx Inc.
--
--  Project  : Programmable Wave Generator
--  Module   : cordic_ctl.vhd
--  Parent   : None
--  Children : uart_rx.vhd led_ctl.vhd 
--
--  Description: 
--     Ties the UART receiver to the LED controller
--
--  Parameters:
--     None
--
--  Local Parameters:
--
--  Notes       : 
--
--  Multicycle and False Paths
--    None
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.cordic_ctl_utils_package.all;

entity cordic_ctl is
	generic (
		BAUD_RATE : integer := 115200;
		CLOCK_RATE : integer := 50E6;
		N : natural := 16
	);
	port (
		-- Write side inputs
		clk_pin : in std_logic; -- Clock input (from pin)
		rst_pin : in std_logic; -- Active HIGH reset (from pin)
		rxd_pin : in std_logic; -- RS232 RXD pin - directly from pin
		--Inputs al cordic      					
		x_cordic_in : out signed(N + 1 downto 0); --Valor de entrada al cordic
		y_cordic_in : out signed(N + 1 downto 0); --Valor de entrada al cordic
		z_cordic_in : out signed(N + 1 downto 0)  --Valor de entrada al cordic
	);
end;

architecture cordic_ctl_arq of cordic_ctl is

	component meta_harden is
		port (
			clk_dst : in std_logic; -- Destination clock
			rst_dst : in std_logic; -- Reset - synchronous to destination clock
			signal_src : in std_logic; -- Asynchronous signal to be synchronized
			signal_dst : out std_logic -- Synchronized signal
		);
	end component;

	component uart_rx is
		generic (
			BAUD_RATE : integer := 115200; -- Baud rate
			CLOCK_RATE : integer := 50E6
		);

		port (
			-- Write side inputs
			clk_rx : in std_logic; -- Clock input
			rst_clk_rx : in std_logic; -- Active HIGH reset - synchronous to clk_rx

			rxd_i : in std_logic; -- RS232 RXD pin - Directly from pad
			rxd_clk_rx : out std_logic; -- RXD pin after synchronization to clk_rx

			rx_data : out std_logic_vector(7 downto 0); -- 8 bit data output
			--  - valid when rx_data_rdy is asserted
			rx_data_rdy : out std_logic; -- Ready signal for rx_data
			frm_err : out std_logic -- The STOP bit was not detected	
		);
	end component;

	signal rst_clk_rx : std_logic;

	-- Between uart_rx and led_ctl
	signal rx_data : std_logic_vector(7 downto 0); -- Data output of uart_rx
	signal rx_data_rdy : std_logic; -- Data ready output of uart_rx

    signal current_state : cordic_ctl_states := S0;
	signal cmd : cordic_ctl_cmds := CMD_NONE; 

begin
	-- Metastability harden the rst - this is an asynchronous input to the
	-- system (from a pushbutton), and is used in synchronous logic. Therefore
	-- it must first be synchronized to the clock domain (clk_pin in this case)
	-- prior to being used. A simple metastability hardener is appropriate here.
	META_HARDEN_RST: meta_harden
	port map(
		clk_dst => clk_pin,
		rst_dst => '0', -- No reset on the hardener for reset!
		signal_src => rst_pin,
		signal_dst => rst_clk_rx
	);

	UART_RX_INSTANCE : uart_rx
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

	CORDIC_CTL_PROCESS: process(rx_data_rdy)
	begin
	if(rising_edge(rx_data_rdy)) and cmd = CMD_NONE then
		C_SEMF : case current_state is
			when S0 =>
				if rx_data = R_CHAR then
					current_state <= S_R;
				end if;
				cmd <= CMD_NONE;
			when S_R =>
				if rx_data = O_CHAR then
					current_state <= S_O;
				else
					current_state <= S0;
				end if;
				cmd <= CMD_NONE;
			when S_O =>
				if rx_data = T_CHAR then
					current_state <= S_T;
				else
					current_state <= S0;
				end if;
				cmd <= CMD_NONE;
			when S_T =>
				if rx_data = SPC_CHAR then
					current_state <= S_SPC;
				else
					current_state <= S0;
				end if;
				cmd <= CMD_NONE;
			when S_SPC =>
				if rx_data = C_CHAR then
					current_state <= S_C;
				elsif rx_data = A_CHAR then
					current_state <= S_C;
				else
					current_state <= S0;
				end if;
				cmd <= CMD_NONE;
			when S_C =>
				if rx_data = SPC_CHAR then
					current_state <= S_SPC_C;
				else
					current_state <= S0;
				end if;
				cmd <= CMD_NONE;
			when S_A =>
				if rx_data = SPC_CHAR then
					current_state <= S_SPC_A;
				else
					current_state <= S0;
				end if;
				cmd <= CMD_NONE;
			when S_SPC_C =>
				if rx_data = H_CHAR then
					current_state <= S_C_H;
				elsif rx_data = A_CHAR then
					current_state <= S_C_A;
				else
					current_state <= S0;
				end if;
				cmd <= CMD_NONE;
			when S_SPC_A =>
				if (unsigned(rx_data) >= to_unsigned(48, 7)) and (unsigned(rx_data) <= to_unsigned(48, 7)) then
					current_state <= S_NUM1;
				else
					current_state <= S0;	
				end if;
				cmd <= CMD_NONE;
			when S_C_H =>
				if rx_data = NEW_LINE_CHAR then
					cmd <= CMD_C_H;
				else
					cmd <= CMD_NONE;	
				end if;
				current_state <= S0;
			when S_C_A =>
				if rx_data = NEW_LINE_CHAR then
					cmd <= CMD_C_A;
				else
					cmd <= CMD_NONE;	
				end if;
				current_state <= S0;
			when S_NUM1 =>
				if (unsigned(rx_data) >= to_unsigned(48, 7)) and (unsigned(rx_data) <= to_unsigned(48, 7)) then
					current_state <= S_NUM2;
					cmd <= CMD_NONE;
				elsif rx_data = NEW_LINE_CHAR then
					current_state <= S0;
					cmd <= CMD_A;
				else
					current_state <= S0;
					cmd <= CMD_NONE;
				end if;
			when S_NUM2 =>
			if (unsigned(rx_data) >= to_unsigned(48, 7)) and (unsigned(rx_data) <= to_unsigned(48, 7)) then
				current_state <= S_NUM3;
				cmd <= CMD_NONE;
			elsif rx_data = NEW_LINE_CHAR then
				current_state <= S0;
				cmd <= CMD_A;
			else
				current_state <= S0;
				cmd <= CMD_NONE;
			end if;
			when S_NUM3 =>
				if rx_data = NEW_LINE_CHAR then
					cmd <= CMD_A;
				else
					cmd <= CMD_NONE;
				end if;
				current_state <= S0;
		end case;

	end if;
	end process;
	
end;
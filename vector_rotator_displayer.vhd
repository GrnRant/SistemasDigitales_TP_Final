library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.utils.all;

entity vector_rotator_displayer is
	generic(
		N_CORDIC: natural := 16;
		N_ADDRESS: natural := 11;
		N_DATA: natural := 16;
		BAUD_RATE: integer := 115200;
		CLOCK_RATE: integer := 125E6;
		CORDIC_ITERATIONS: natural := 16;  --
		CORDIC_CTL_CYCLES: natural := 125E6/50-16 --Cantidad de ciclos que espera el cordic_ctl para próxima rotación
	);
	port(
		--Write side inputs
		clk_pin: in std_logic;		-- Clock input (from pin)
		--rst_pin: in std_logic;		-- Active HIGH reset (from pin)
		rxd_pin: in std_logic; 		-- Uart input
		hsync: out std_logic;
		vsync: out std_logic;
		rgb: out std_logic_vector(2 downto 0)
	);
end;
	

architecture vector_rotator_displayer_arq of vector_rotator_displayer is
	signal rst_pin: std_logic := '0';		
	signal rst_vio: std_logic_vector(0 downto 0);
	--UART/CMD_CTL
	signal rx_data_rdy: std_logic;
	signal rx_data: std_logic_vector(7 downto 0);
	--CMDS_CTL/CORDIC/TILES_GEN
	signal cmd: cordic_ctl_cmds;
	signal ang_chg: std_logic;
	signal ang_a: signed(N_CORDIC - 1 downto 0);
	signal x_i: signed(N_CORDIC - 1 downto 0);
	signal y_i: signed(N_CORDIC - 1 downto 0);
	signal z_i: signed(N_CORDIC - 1 downto 0);
	signal x_o: signed(N_CORDIC - 1 downto 0);
	signal y_o: signed(N_CORDIC - 1 downto 0);
	signal x_i_aux: std_logic_vector(N_CORDIC - 1 downto 0);
	signal y_i_aux: std_logic_vector(N_CORDIC - 1 downto 0);
	signal z_i_aux: std_logic_vector(N_CORDIC - 1 downto 0);
	signal y_o_aux: std_logic_vector(N_CORDIC - 1 downto 0);
	signal x_o_aux: std_logic_vector(N_CORDIC - 1 downto 0);
	signal z_o: signed(N_CORDIC - 1 downto 0);
	signal cordic_start: std_logic;
	signal busy: std_logic;
	--TILES_GEN/BRAM
	signal wr_a: std_logic;
    signal wr_a_aux: std_logic_vector(0 downto 0);
	signal addr_a: unsigned(N_ADDRESS - 1 downto 0);
	signal wr_data_a: unsigned(N_DATA - 1 downto 0);
    --BRAM/VGA_CTL
	signal addr_b: unsigned(N_ADDRESS - 1 downto 0);
	signal rd_data_b: unsigned(N_DATA - 1 downto 0);
    signal rd_data_b_aux: std_logic_vector(N_DATA - 1 downto 0);
    --VGA_CTL
    signal clk_vga: std_logic;
	--signal clk_vga_aux: std_logic;
	--signal clk_vga_locked: std_logic;
	-- signal vsync_ila: std_logic_vector(0 downto 0);
	-- signal rgb_ila: std_logic_vector(2 downto 0);

    component vram is
    port (
      clka : in std_logic;
      wea : in std_logic_vector(0 downto 0);
      addra : in std_logic_vector(10 downto 0);
      dina : in std_logic_vector(15 downto 0);
      clkb : in std_logic;
      addrb : in std_logic_vector(10 downto 0);
      doutb : out std_logic_vector(15 downto 0)
    );
    end component;

	component clk_wiz_vga
	port
	(-- Clock in ports
	-- Clock out ports
	clk_50mhz          : out    std_logic;
	-- Status and control signals
	reset             : in     std_logic;
	locked            : out    std_logic;
	clk_in           : in     std_logic
	);
	end component;

	--Componentes para mediciones (VIO e ILA)
	--VIO
	component vio_0
	port (
		clk : in std_logic;
		probe_in0 : in std_logic_vector(15 downto 0);
		probe_in1 : in std_logic_vector(15 downto 0);
		probe_out0 : out std_logic_vector(0 downto 0) 
	);
	end component;

begin
    wr_a_aux(0) <= wr_a;
    rd_data_b <= unsigned(rd_data_b_aux);
	--clk_vga <= clk_vga_aux when (clk_vga_locked = '0') else '0';
	rst_pin <= rst_vio(0);
	x_o_aux <= std_logic_vector(x_o);
	y_o_aux <= std_logic_vector(y_o);
	-- rgb <= rgb_ila;
	-- vsync <= vsync_ila(0);

	UART : entity work.uart_top
	generic map(
		CLOCK_RATE => CLOCK_RATE,
		BAUD_RATE => BAUD_RATE
	)
	port map(
		clk_pin => clk_pin,
		rst_pin => rst_pin, 
		rxd_pin => rxd_pin,
		rx_data => rx_data,
		rx_data_rdy => rx_data_rdy
	);
	CMD_CTL: entity work.cmd_ctl
		generic map(
			BAUD_RATE => BAUD_RATE,
			CLOCK_RATE => CLOCK_RATE,
			N => N_CORDIC
		)
		port map(
			clk_pin => clk_pin,
			rst_pin => rst_pin, 
			rx_data => rx_data, 
			rx_data_rdy => rx_data_rdy,
			cmd_out => cmd,
			ang_out => ang_a,
			ang_chg => ang_chg
		);
	CORDIC_CTL: entity work.cordic_ctl
		generic map (
			CLOCK_RATE  => CLOCK_RATE,
			N => N_CORDIC,
			CORDIC_CYCLES => CORDIC_CTL_CYCLES,
			MAX_CORDIC_COMP_VALUE => 2**(N_CORDIC-3)
		)
		port map(
			clk => clk_pin,
			rst => rst_pin, 
			cmd_in => cmd, 
			ang_in => ang_a, 
			ang_chg => ang_chg,
			x_cordic_out => x_o, 
			y_cordic_out => y_o,
			cordic_busy => busy, 			
			x_cordic_in => x_i,
			y_cordic_in => y_i, 
			z_cordic_in => z_i,
			cordic_start => cordic_start
		);
	CORDIC: entity work.cordic
		generic map(
			N => N_CORDIC, 
			ITERATIONS => CORDIC_ITERATIONS,
			GAIN_DECIMALS => 10
			)
		port map(
			x0 => x_i,
			y0 => y_i,
			z0 => z_i,
			xr => x_o,
			yr => y_o,
			zr => z_o,
			start => cordic_start, 
			clk => clk_pin,
			rst => rst_pin,
			mode => '0',
			busy => busy
		);
	TILE_GEN: entity work.gen_tiles
	generic map(
		N_CORDIC => N_CORDIC,
		N_ADDRESS => N_ADDRESS,
		N_DATA => N_DATA,
		MAX_CORDIC_COMP_VALUE => 2**(N_CORDIC-3)
	)
	port map(
		rst => rst_pin,
		clk => clk_pin,
		x_in => x_o,
		y_in => y_o,
		cordic_busy => busy,
		wr => wr_a,
		addr => addr_a,
		wr_data => wr_data_a
	);
    VIDEO_MEMORY: vram
    port map(
        clka => clk_pin,
        wea => wr_a_aux,
        addra => std_logic_vector(addr_a),
        dina => std_logic_vector(wr_data_a),
        clkb => clk_pin,
        addrb => std_logic_vector(addr_b),
        doutb => rd_data_b_aux
    );

    VGA_CONTROLLER: entity work.vga_ctrl
    generic map(
		N_ADDRESS => N_ADDRESS,
		N_DATA => N_DATA
	)
	port map(
		clk => clk_vga,
		rst => rst_pin,
		rd_data => rd_data_b,
		addr => addr_b,
		hsync => hsync,
		vsync => vsync, --vsync_ila(0),
		rgb => rgb --rgb_ila
	);
	VGA_CLK_GEN: clk_wiz_vga
	port map
	(-- Clock in ports
	-- Clock out ports
	clk_50mhz => clk_vga, --clk_vga_aux,
	-- Status and control signals
	reset => rst_pin,
	locked => open,
	clk_in => clk_pin
	);

	--Para mediciones (VIO e ILA)
	VIO_RESET_CORDIC: vio_0
	port map(
		clk => clk_pin,
		probe_in0 => x_o_aux,
		probe_in1 => y_o_aux,
		probe_out0 => rst_vio
	);
	-- ILA_VGA_RGB: ila_0
	-- port map(
	-- 	clk => clk_pin,
	-- 	probe0 => rgb_ila,
	-- 	probe1 => vsync_ila
	-- );
	
end;
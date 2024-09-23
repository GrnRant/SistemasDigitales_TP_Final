@echo off

if exist build\ (
    rmdir /s /q build
) 
mkdir build

@REM UART_CORDIC
ghdl -a --workdir=build UART_CORDIC/meta_harden.vhd
ghdl -a --workdir=build UART_CORDIC/uart_baud_gen.vhd
ghdl -a --workdir=build UART_CORDIC/uart_rx_ctl.vhd
ghdl -a --workdir=build UART_CORDIC/uart_rx.vhd
ghdl -a --workdir=build UART_CORDIC/cordic_ctl_utils.vhd
ghdl -a --workdir=build UART_CORDIC/cordic_ctl.vhd

@REM GENERAL
ghdl -a --workdir=build uart_cordic.vhd

@REM Run
ghdl -r --workdir=build uart_cordic --vcd=build/uart_cordic.vcd
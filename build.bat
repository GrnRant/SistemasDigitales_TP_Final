@echo off

if exist build\ (
    rmdir /s /q build
) 
mkdir build

@REM utilities
ghdl -a --workdir=build utilities/utilities.vhd
ghdl -a --workdir=build utilities/ffd.vhd
ghdl -a --workdir=build utilities/counter.vhd

@REM uart_cmd
ghdl -a --workdir=build uart_cmd/meta_harden.vhd
ghdl -a --workdir=build uart_cmd/uart_baud_gen.vhd
ghdl -a --workdir=build uart_cmd/uart_rx_ctl.vhd
ghdl -a --workdir=build uart_cmd/uart_rx.vhd
ghdl -a --workdir=build uart_cmd/uart_top.vhd
ghdl -a --workdir=build uart_cmd/cmd_ctl.vhd

@REM cordic
ghdl -a --workdir=build cordic/cordic_ctl.vhd
ghdl -a --workdir=build cordic/cordic_stage.vhd
ghdl -a --workdir=build cordic/precordic.vhd
ghdl -a --workdir=build cordic/cordic.vhd

@REM vga
ghdl -a --workdir=build vga/gen_tiles.vhd

@REM GENERAL
ghdl -a --workdir=build vector_rotator.vhd

@REM test bench para simulación
ghdl -a --workdir=build vector_rotator_tb.vhd

@REM Run
ghdl -r --workdir=build vector_rotator_tb --vcd=build/vector_rotator_tb.vcd

@REM Abrir simulación
cd build
gtkwave vector_rotator_tb.vcd
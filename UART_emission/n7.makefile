
SRC = ../clkUnit/clkUnit.vhd             \
      ../TxUnit/TxUnit.vhd               \
      ctrlUnit.vhd \
      UART.vhd \
      diviseurClk.vhd \
      RxUnit.vhd \
      echoUnit.vhd \
      UART_FPGA_N4.vhd \
      testRxUnit.vhd

# for simulation: 
TEST = testRxUnit
# duration (to adjust if necessary)
TIME = 10000ns
PLOT = output

# for synthesis:
UNIT = UART_FPGA_N4
ARCH = synthesis
UCF  = UART_FPGA_N4_DDR.ucf

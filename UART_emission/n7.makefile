
SRC = ../clkUnit/clkUnit.vhd             \
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

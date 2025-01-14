
SRC = ../clkUnit/clkUnit.vhd             \
      ../TxUnit/TxUnit.vhd               \
      ctrlUnit.vhd \
      UART.vhd \
      diviseurClk.vhd \
      RxUnit.vhd \
      echoUnit.vhd \
      UART_FPGA_N4.vhd \
      testRxUnit4.vhd \
#      testRxUnit3.vhd \
#      testRxUnit2.vhd \
#      testRxUnit.vhd

# for simulation: 
# TEST = testRxUnit
# TEST = testRxUnit2
# TEST = testRxUnit3
TEST = testRxUnit4
# duration (to adjust if necessary)
TIME = 6000ns
PLOT = output

# for synthesis:
UNIT = UART_FPGA_N4
ARCH = synthesis
UCF  = UART_FPGA_N4_DDR.ucf

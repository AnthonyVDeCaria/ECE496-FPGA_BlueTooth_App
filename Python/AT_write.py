'''
	Anthony De Caria - January 5, 2017

	This is a collection of Python functions 
	needed to send AT commands to the BTM.

	Note: BTM = Bluetooth Module
'''

import ok
import constants as con

'''
	Puts a byte of data to the UART_tx
	Assumes byte is proper.
'''
def load_AT_byte(fpga, byte):
	fpga.SetWireInValue(con.AT_DATA_WIRE, byte, 0xffff)
	fpga.UpdateWireIns()
	fpga.SetWireInValue(con.SIGNAL_WIRE, 0x000C, 0xffff)
	fpga.UpdateWireIns()

'''
	Alerts the FPGA we have more bytes to send 
'''
def alert_FPGA_more_to_send(fpga):
	fpga.SetWireInValue(con.SIGNAL_WIRE, 0x0014, 0xffff)
	fpga.UpdateWireIns()

'''
	Alerts the FPGA we are finished loading the AT command
'''
def alert_FPGA_done_AT_command(fpga):
	fpga.SetWireInValue(con.SIGNAL_WIRE, 0x0034, 0xffff)
	fpga.UpdateWireIns()



'''
	Anthony De Caria - January 5, 2017

	This is a collection of Python functions 
	needed to send AT commands to the BTM.

	Note: BTM = Bluetooth Module
'''

import ok
import constants as con
import library as lib


def load_AT_byte(fpga, byte):
	'''
		Puts a byte of data to the UART_tx
		Assumes byte is proper.
	'''
	lib.write_wire(fpga, con.Wire.AT_DATA_WIRE, byte)
	lib.write_wire(fpga, con.Wire.SIGNAL_WIRE, 0x000C)


def alert_FPGA_more_to_send(fpga):
	'''
		Alerts the FPGA we have more bytes to send 
	'''
	lib.write_wire(fpga, con.Wire.SIGNAL_WIRE, 0x0014)

def alert_FPGA_done_AT_command(fpga):
	'''
		Alerts the FPGA we are finished loading the AT command
	'''
	lib.write_wire(fpga, con.Wire.SIGNAL_WIRE, 0x0034)
	
def send_AT_command(fpga, data):
	'''
		Sends a full AT command to the FPGA
		Assumes the data is properly formatted
	'''
	end_i = len(data) - 1
	for byte in data:
		print('Loading: %04x' % byte)
		load_AT_byte(fpga, byte)
		
		if (byte == data[end_i]):
			alert_FPGA_done_AT_command
		else:
			alert_FPGA_more_to_send
	
def send_AT_command_to_BTM(fpga, data, btm):
	'''
		Sends a full AT command to the FPGA
		AFTER appending \r\n if needed
		Assumes that the rest of the data is properly formatted
	'''
	if(btm == con.Bluetooth.NEEDS_RN):
		data = data + [0x0d0a]
	elif(btm == con.Bluetooth.NEEDS_R):
		data = data + [0x0d00]
	elif(btm == con.Bluetooth.NEEDS_N):
		data = data + [0x0a00]
	
	send_AT_command(fpga, data)


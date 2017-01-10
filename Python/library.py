'''
	Anthony De Caria - January 5, 2017

	This is a collection of Python functions needed to access the FPGA.
	Note: BTM = Bluetooth Module
'''

#import ok
import constants as con

def convert(char):
	'''
		convert a char to ascii int
	'''
	return (hex(ord(char)))
	
def write_wire(fpga, wire, word):
	'''
		Write data to a wire
	'''
	fpga.SetWireInValue(wire, word, 0xffff)
	fpga.UpdateWireIns()

def clear_wire_ins(fpga):
	'''
		Resets the WireIns
	'''
	[write_wire(fpga, wire, 0x0000) for wire in con.Wire.WIRE_IN_CON]
	
def reset(fpga):
	'''
		Resets the FPGA
	'''
	write_wire(fpga, con.Wire.SIGNAL_WIRE, 0x0001)

def datastream_toggle(fpga, want_datastream = False):
	'''
		Toggles the datastream
		When want_datastream = true -> data flows
		Otherwise its 0.
	'''
	if(want_datastream):
		write_wire(fpga, con.Wire.SIGNAL_WIRE, 0x0002)
	else:
		write_wire(fpga, con.Wire.SIGNAL_WIRE, 0x0000)
		
def turn_on_datastream(fpga):
	'''
		Turns on the Datastream
	'''
	write_wire(fpga, con.Wire.SIGNAL_WIRE, 0x0002)
		
def read_wire(fpga, wire):
	'''
		Read data from a wire
	'''
	fpga.UpdateWireOuts()
	return fpga.GetWireOutValue(wire)

def read_state(fpga):
	'''
		Reads the State wire
	'''
	return read_wire(fpga, con.Wire.STATE)

def read_all_Wire_Outs(fpga):
	'''
		Reads all the WireOuts
	'''
	wire_data = []
	for wire in con.Wire.CURR_WIRE_OUTS:
		wire_data = wire_data + [read_wire(fpga, wire)]
	return wire_data
	
def display_state(fpga):
	'''
		Displays the contents of the state wire
	'''
	state = read_state(fpga)
	print('The current state is: %04x' % state)

def display_all_Wire_Outs(fpga):
	'''
		Display all the WireOuts
	'''
	wire_data = read_all_Wire_Outs(fpga)
	for i, wire in enumerate(wire_data):
		print(i, '%04x' % wire)

if __name__ == "__main__":
	char = raw_input('Enter character: ')
	print(convert(char))

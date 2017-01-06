'''
	Anthony De Caria - January 5, 2017

	This is a collection of Python functions needed to access the FPGA.
	Note: BTM = Bluetooth Module
'''

import ok
import constants as con

'''
	convert char to ascii int
'''
def convert(text):
    return (hex(ord(char)))

'''
	Resets the FPGA
'''
def reset(fpga):
	fpga.SetWireInValue(con.SIGNAL_WIRE, 0x0001, 0xffff)
	fpga.UpdateWireIns()

'''
	Toggles the datastream
	When want_datastream = true -> data flows
	Otehrwise its 0.
'''
def datastream_toggle(fpga, want_datastream = False):
	if(want_datastream):
		fpga.SetWireInValue(con.SIGNAL_WIRE, 0x0002, 0xffff)
		fpga.UpdateWireIns()
	else:
		fpga.SetWireInValue(con.SIGNAL_WIRE, 0x0000, 0xffff)
		fpga.UpdateWireIns()

'''
	Reads the State wire
'''
def read_state(fpga):
	fpga.UpdateWireOuts()
	return fpga.GetWireOutValue(con.STATE)

'''
	Displays the contents of the state wire
'''
def display_state(fpga):
	state = read_state(fpga)
	print('The current state is: %04x' % state)

'''
	Reads all the WireOuts

def check_all_Wire_Outs(fpga)
	fpga.UpdateWireOuts()
	a.Array(I)

	return a
'''


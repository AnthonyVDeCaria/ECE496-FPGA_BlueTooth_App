'''
	Anthony De Caria - January 5, 2017

	This is a collection of Python functions 
	needed to read AT responses from the BTM.

	Note: BTM = Bluetooth Module
'''

import ok
import constants as con
import library as lib

'''
	Access the first word of data in the RFIFO.
'''
def pop_RFIFO(fpga):
	fpga.SetWireInValue(con.SIGNAL_WIRE, 0x0044, 0xffff)
	fpga.UpdateWireIns()

	fpga.UpdateWireOuts()
	return fpga.GetWireOutValue(con.RFIFO_OUT_WIRE)

'''
	Lets the FPGA know that we have the RFIFO word
	but we want more data
'''
def alert_FPGA_receieved_word_want_more(fpga):
	fpga.SetWireInValue(con.SIGNAL_WIRE, 0x0084, 0xffff)
	fpga.UpdateWireIns()

'''
	Lets the FPGA know that we have the RFIFO word
	and we're finished
'''
def alert_FPGA_receieved_word_done(fpga):
	fpga.SetWireInValue(con.SIGNAL_WIRE, 0x0184, 0xffff)
	fpga.UpdateWireIns()

'''
	Reads the amount of times RFIFO has been writen
'''
def read_RFIFO_wr_count_wire(fpga):
	fpga.UpdateWireOuts()
	return fpga.GetWireOutValue(con.RFIFO_WR_COUNT_WIRE)

'''
	Reads the amount of times RFIFO can been read
'''
def read_RFIFO_rd_count_wire(fpga):
	fpga.UpdateWireOuts()
	return fpga.GetWireOutValue(con.RFIFO_RD_COUNT_WIRE)

'''
	Takes the AT Response from the BTM.
	Assumes the FPGA is in the proper state.
'''
def read_and_display_AT_response(fpga):
	out = 0
	state = lib.read_state(fpga)
	times_RFIFO_written = read_RFIFO_wr_count_wire(fpga)
	times_to_read_RFIFO = read_RFIFO_rd_count_wire(fpga)

	print('We are in state %04x.' % state)	
	print('The RFIFO was written %04x times.' % times_RFIFO_written)
	print('We should read %04x pieces of data.' % times_to_read_RFIFO)

	while (times_to_read_RFIFO > 0):
		out = pop_RFIFO(fpga)
		print('Read: %04x' % out)

		times_to_read_RFIFO = read_RFIFO_rd_count_wire(fpga)
		
		if (times_to_read_RFIFO == 0): #finished with RFIFO
			alert_FPGA_receieved_word_done(fpga)
			print('I love poop')
		else:
			alert_FPGA_receieved_word_want_more(fpga)

	alert_FPGA_receieved_word_done(fpga)
	lib.display_state(fpga)
	print('I dont like poop')


'''
	Anthony De Caria - January 5, 2017

	This is a collection of Python functions 
	needed to read AT responses from the BTM.

	Note: BTM = Bluetooth Module
'''

import ok
import constants as con
import library as lib

def pop_RFIFO(fpga):
	'''
		Access the first word of data in the RFIFO.
	'''
	lib.write_wire(fpga, con.Wire.SIGNAL_WIRE, 0x0044)

	return lib.read_wire(fpga, con.Wire.RFIFO_OUT_WIRE)

def alert_FPGA_receieved_word_want_more(fpga):
	'''
		Lets the FPGA know that we have the RFIFO word
		but we want more data
	'''
	lib.write_wire(fpga, con.Wire.SIGNAL_WIRE, 0x0084)

def alert_FPGA_receieved_word_done(fpga):
	'''
		Lets the FPGA know that we have the RFIFO word
		and we're finished
	'''
	lib.write_wire(fpga, con.Wire.SIGNAL_WIRE, 0x0184)

def read_RFIFO_wr_count_wire(fpga):
	'''
		Reads the amount of times RFIFO has been writen
	'''
	return lib.read_wire(fpga, con.Wire.RFIFO_WR_COUNT_WIRE)

def read_RFIFO_rd_count_wire(fpga):
	'''
		Reads the amount of times RFIFO can been read
	'''
	return lib.read_wire(fpga, con.Wire.RFIFO_RD_COUNT_WIRE)

def read_and_display_AT_response(fpga):
	'''
		Takes the AT Response from the BTM.
		Assumes the FPGA is in the proper state.
	'''
	out = 0
	state = lib.read_state(fpga)
	times_RFIFO_written = read_RFIFO_wr_count_wire(fpga)
	times_to_read_RFIFO = read_RFIFO_rd_count_wire(fpga)

	print('The RFIFO was written %04x times.' % times_RFIFO_written)
	print('We should read %04x pieces of data.' % times_to_read_RFIFO)

	while (times_to_read_RFIFO > 0):
		out = pop_RFIFO(fpga)
		print('Read: %04x' % out)

		times_to_read_RFIFO = read_RFIFO_rd_count_wire(fpga)
		
		if (times_to_read_RFIFO == 0): #finished with RFIFO
			alert_FPGA_receieved_word_done(fpga)
		else:
			alert_FPGA_receieved_word_want_more(fpga)


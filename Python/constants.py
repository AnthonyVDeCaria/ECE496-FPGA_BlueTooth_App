'''
	Anthony De Caria - January 5, 2017

	This is a collection of constants
'''
class Wire:
	AT_DATA_WIRE = 0x01
	SIGNAL_WIRE = 0x02

	RFIFO_OUT_WIRE = 0x20
	RFIFO_WR_COUNT_WIRE = 0x21
	RFIFO_RD_COUNT_WIRE = 0x22
	AT_DATA_WIRE_CHECK = 0x23
	SIGNAL_WIRE_CHECK = 0x24
	STATE = 0x25

	#These will come and go out of the aether
	DS_CHECK = 0x26
	RC_CHECK = 0x27
	DATA_STREAM = 0x28

	WIRE_IN_CON = [AT_DATA_WIRE, SIGNAL_WIRE]

	STAND_WIRE_OUTS = [RFIFO_OUT_WIRE, RFIFO_WR_COUNT_WIRE, RFIFO_RD_COUNT_WIRE, AT_DATA_WIRE_CHECK, SIGNAL_WIRE_CHECK, STATE]

	CURR_WIRE_OUTS = STAND_WIRE_OUTS + [DS_CHECK, RC_CHECK, DATA_STREAM]

class States:
	Idle = 0b0000
	Load_AT_FIFO = 0b0010
	Rest_AT_FIFO = 0b0011
	Release_from_FIFO = 0b0100
	Load_Transmission = 0b0101
	Begin_Transmission = 0b0110
	Rest_Transmission = 0b0111
	Receive_AT_Response = 0b1000
	Wait_for_RFIFO_Request = 0b1101
	Read_RFIFO = 0b1110
	Rest_RFIFO = 0b1111
	
class Bluetooth:
	NEEDS_RN = 3
	NEEDS_R = 2
	NEEDS_N = 1
	NO_NEED = 0
	
	HC_05 = NEEDS_RN
	HM_10 = NO_NEED
	

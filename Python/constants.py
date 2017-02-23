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
	MS_CHECK = 0x28
	EMPTY_FLAGS = 0x29
	DATA_STREAM = 0x30

	WIRE_IN_CON = [AT_DATA_WIRE, SIGNAL_WIRE]

	STAND_WIRE_OUTS = [RFIFO_OUT_WIRE, RFIFO_WR_COUNT_WIRE, RFIFO_RD_COUNT_WIRE, AT_DATA_WIRE_CHECK, SIGNAL_WIRE_CHECK, STATE]

	CURR_WIRE_OUTS = STAND_WIRE_OUTS + [DS_CHECK, RC_CHECK, MS_CHECK, EMPTY_FLAGS, DATA_STREAM]

class States:
	Idle = 0b0000
	Load_AT_FIFO = 0b0001
	Rest_AT_FIFO = 0b0010
	Wait_for_Clearance = 0b0011
	Release_from_FIFO = 0b0100
	Load_Buffer = 0b0101
	Rest_byte_i = 0b0110
	Send_Byte = 0b1000
	Rest_Transmission = 0b1001
	Receive_AT_Response = 0b1100
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
	

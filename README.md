# ECE496-FPGA_BlueTooth_App

ep02wireIn[0] = reset; 
ep02wireIn[1] = access_datastreams;
ep02wireIn[2] = want_at;

ep02wireIn[3] = user_data_loaded;  
ep02wireIn[4] = user_knows_stored;  
ep02wireIn[5] = user_data_done;

ep02wireIn[6] = access_RFIFO;  
ep02wireIn[7] = user_received_data;  
ep02wireIn[8] = finished_with_RFIFO;

To access constant datastream: 000 000 010 -> 002 -> 0 0000 0010 -> 002

AT  
To begin AT Mode: 000 000 100 -> 004 -> 0 0000 0100 -> 004

To load a byte of your AT command: 000 001 100 -> 014 -> 0 0000 1100 -> 00C
To signal you have more to your AT command: 000 010 100 -> 024 -> 0 0001 0100 -> 014
To signal you finished AT command: 000 110 100 -> 064 -> 0 0011 0100 -> 034

To access RFIFO: 001 000 100 -> 104 -> 0 0100 0100 -> 044  
To say you've received data: 010 000 100 -> 204 -> 0 1000 0100 -> 084  
To stop receiving data: 110 000 100 -> 604 -> 1 1000 0100 -> 184

CPD
Because of the quirks of the clock and registers,  
you cannot just use the clock speed divided by the baud rate to get a proper period.  
You have to use other values - ones that we determined experimentally.  
Assuming a 1MHZ:  
38400 => 26 microseconds => 11
19200 => 52 microseconds => 24
9600 => 104 microseconds => 50

Pause Length (Assuming a 1MHZ):  
38400 => 800 microseconds => 385
19200 => 572 microseconds => 255
9600 => 140 microseconds => 12

#Custom Protocol between FPGA and App
Control Command Type (1 byte)  
Start		-0  
Cancel		-1  
Are active	-2   
Acknowledge	-3

Operands (1 byte)  
Which channels App will listen to	-8 bits (1 bit representing one channel)

Note:  
Start will incorporate operands, which channels App will listen to.  
Control commands having no operands will be transmitted as command type packet only.

Phases  
1. Establish Bluetooth Channel  
2. Notify which channels are active from FPGA to the App (Are active is used)  
3. Interact with the user (Start, Cancel, Acknowledge are used)

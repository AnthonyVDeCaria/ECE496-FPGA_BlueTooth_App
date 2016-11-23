# ECE496-FPGA_BlueTooth_App

ep02wireIn[0] = reset;
ep02wireIn[1] = want_at;
ep02wireIn[2] = begin_connection;

ep02wireIn[3] = user_data_loaded;
ep02wireIn[4] = user_knows_stored;
ep02wireIn[5] = user_data_done;

ep02wireIn[6] = access_RFIFO;
ep02wireIn[7] = user_received_data;
ep02wireIn[8] = finished_with_RFIFO;

To access constant datastream: 000 000 100 -> 004 -> 0 0000 0100 -> 004

AT
To access AT datastream: 000 000 110 -> 006 -> 0 0000 0110 -> 006
To load a piece of data: 000 001 110 -> 016 -> 0 0000 1110 -> 00E
To add a new piece of data: 000 010 110 -> 026 -> 0 0001 0110 -> 016
To move on when you finished sending your AT commands: 000 110 110 -> 066 -> 0 0011 0110 -> 036

To accees RFIFO: 001 000 110 -> 106 -> 0 0100 0110 -> 046
To say you've received data: 010 000 110 -> 206 -> 0 1000 0110 -> 086
To stop receiving data: 110 000 110 -> 606 -> 1 1000 0110 -> 186

CPD
Because of the quirks of the clock and registers, 
you cannot just use the clock speed divided by the baud rate to get a proper period.
You have to use other values - ones that we determined experimentally.
Assuming a 1MHZ:
38400 => 26 microseconds => 11
9600 => 100 microseconds => TK(To Be Determined)

Pause Length (Assuming a 1MHZ):
HC-05 => 800 microseconds => 385

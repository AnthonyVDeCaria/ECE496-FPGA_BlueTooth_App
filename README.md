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

ep21wireOut[0] = curr[0];
ep21wireOut[1] = curr[1];
ep21wireOut[2] = curr[2];
ep21wireOut[3] = curr[3];
ep21wireOut[4] = next[0];
ep21wireOut[5] = next[1];
ep21wireOut[6] = next[2];
ep21wireOut[7] = next[3];
ep21wireOut[8] = data_stored_for_user;
ep21wireOut[9] = data_ready_for_user;
ep21wireOut[10] = data_ready;
ep21wireOut[11] = data_complete;
ep21wireOut[12] = TFIFO_full;
ep21wireOut[13] = TFIFO_empty;
ep21wireOut[14] = TFIFO_wr_en;
ep21wireOut[15] = TFIFO_rd_en;

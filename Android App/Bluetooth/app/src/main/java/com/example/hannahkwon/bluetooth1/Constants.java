package com.example.hannahkwon.bluetooth1;

/**
 * Created by HannahKwon on 2016-09-23.
 */
public class Constants {
    static final int REQUEST_ENABLE_BT = 1000;
    static final int REQUEST_CONNECT_DEVICE = 1001;

    // Message types sent from the BluetoothService Handler
    public static final int MESSAGE_BLUETOOTH_ON = 0;
    public static final int MESSAGE_STATE_CHANGE = 1;
    public static final int MESSAGE_READ = 2;
    //    public static final int MESSAGE_WRITE = 3;
    public static final int MESSAGE_DEVICE_NAME = 4;
    public static final int MESSAGE_TOAST = 5;
    public static final int MESSAGE_CLEAR_INPUT = 6;

    // Key names received from the BluetoothService Handler
    public static final String DEVICE_NAME = "device_name";
    public static final String TOAST = "toast";

    // Permission Request Code
    public static final int PERMISSION_ACCESS_COARSE_LOCATION = 2000;
    public static final int PERMISSION_READ_EXTERNAL_STORAGE = 2001;
    public static final int PERMISSION_WRITE_EXTERNAL_STORAGE = 2002;   // dividing external storage permission in case they are not in the same group

    // Commands used between FPGA and App
    public static final String COMMAND_HEADER = "11";
    // Command types
    public static final String ON_DS = "00";
    public static final String OFF_DS = "01";
    public static final String WAIT = "02";
    public static final String READY = "03";
    public static final String SELECT_DS = "04";
    public static final String ACK = "05";
    public static final String SELECT_PRE_FILTER = "06";
    // Sensors (Used in command operand)
    public static final String DS_1 = "01";
    public static final String DS_2 = "02";
    public static final String DS_3 = "03";
    public static final String DS_4 = "04";
    public static final String DS_5 = "05";
    public static final String DS_6 = "06";
    public static final String DS_7 = "07";
    public static final String DS_8 = "08";
}

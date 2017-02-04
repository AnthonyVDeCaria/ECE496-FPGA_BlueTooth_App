package com.example.hannahkwon.bluetooth1;

/**
 * Created by HannahKwon on 2016-09-23.
 */
public class Constants {
    static final int REQUEST_ENABLE_BT = 1000;
    static final int REQUEST_CONNECT_DEVICE = 1001;

    // Gatt operation for BLE
    static final int GATT_READ = 0;
    static final int GATT_WRITE = 1;

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

    // Control Commands used between FPGA and App
    // Control Command types
    public static final int START = 0x00; // 0
    public static final int CANCEL = 0x01;    // 1

    //    public static final String WAIT = "2";
//    public static final String READY = "3";
    public static final int ARE_ACTIVE = 0x02;    // 2
    public static final int ACK = 0x03;   // 3
    // Control Command Operands
    public static final int DS1 = 0b00000001;
    public static final int DS2 = 0b00000010;
    public static final int DS3 = 0b00000100;
    public static final int DS4 = 0b00001000;
    public static final int DS5 = 0b00010000;
    public static final int DS6 = 0b00100000;
    public static final int DS7 = 0b01000000;
    public static final int DS8 = 0b10000000;

    public static final int TEMP_THRESHOLD = 35;
}

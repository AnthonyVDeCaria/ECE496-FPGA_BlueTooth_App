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
    public static final int MESSAGE_DEVICE_NAME = 3;
    public static final int MESSAGE_TOAST = 4;

    // Key names received from the BluetoothService Handler
    public static final String DEVICE_NAME = "device_name";
    public static final String TOAST = "toast";
}

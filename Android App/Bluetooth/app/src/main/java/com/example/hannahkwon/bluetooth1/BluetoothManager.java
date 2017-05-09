package com.example.hannahkwon.bluetooth1;

import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.content.Intent;
import android.os.Handler;
import android.os.Message;
import android.util.Log;

/**
 * Created by HannahKwon on 2016-09-15.
 * As the App acts as client initiating connection to the Bluetooth Module
 */
public class BluetoothManager {
    private static final String TAG = "BluetoothManager";

    private BluetoothAdapter btAdapter;

    private Activity mActivity;
    private Handler mHandler;

    public BluetoothManager(Activity ac, Handler h){
        mActivity= ac;
        mHandler = h;

        btAdapter = BluetoothAdapter.getDefaultAdapter();
    }

    /* Checks if the device supports Bluetooth */
    public boolean getDeviceState() {
        Log.d(TAG, "Checking the Bluetooth support");

        if (btAdapter == null) { // this device does not support Bluetooth
            Log.d(TAG, "Bluetooth is not available");

            return false;
        } else {
            Log.d(TAG, "Bluetooth is available");

            return true;
        }
    }

    public void enableBluetooth() {
        Log.i(TAG,"Checking enabled Bluetooth");

        if (btAdapter.isEnabled() && btAdapter != null) { // Bluetooth is on
            Log.d(TAG,"Bluetooth is already enabled");

            // Send the name of the connected device back to the UI Activity
            Message msg = mHandler.obtainMessage(Constants.MESSAGE_BLUETOOTH_ON);
            mHandler.sendMessage(msg);

            scanDevice();
        }
        else { //Bluetooth is off
            Log.d(TAG,"Bluetooth Enables Request");

            Intent i = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
            mActivity.startActivityForResult(i, Constants.REQUEST_ENABLE_BT);
        }
    }

    /*
     * Uses DeviceListActivity to scan Bluetooth devices
     * If device is selected it will return the result back to MainActivity
     */
    public void scanDevice(){
        Log.d(TAG,"Scan device");

        Intent serverIntent = new Intent(mActivity, DeviceListActivity.class);
        mActivity.startActivityForResult(serverIntent, Constants.REQUEST_CONNECT_DEVICE);

    }
}


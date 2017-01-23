package com.example.hannahkwon.bluetooth1;

import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothSocket;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.widget.Toast;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Arrays;
import java.util.UUID;

/**
 * Created by HannahKwon on 2016-09-15.
 * As the App acts as client initiating connection to the Bluetooth Module
 */
public class BluetoothService {
    private static final String TAG = "BluetoothService";

    private BluetoothAdapter btAdapter;

    private Activity mActivity;
    private Handler mHandler;

    // RFCOMM Protocol
    // MY_UUID is the Bluetooth Module's UUID string
    private static final UUID MY_UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB");

    private ConnectThread mConnectThread;
    private ConnectedThread mConnectedThread;

    private int mState;

    // Constants that indicate the current connection state
    public static final int STATE_NONE = 0;        // we're doing nothing
    public static final int STATE_CONNECTING = 2;  // now initiating an outgoing connection
    public static final int STATE_CONNECTED = 3;   // now connected to a remote device

    public BluetoothService(Activity ac, Handler h){
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

    public void getDeviceInfo(Intent data) {
        // Get the device MAC address
        String address = data.getExtras().getString(DeviceListActivity.EXTRA_DEVICE_ADDRESS);

        // A BluetoothDevice will always be returned for a valid hardware address,
        // even if this adapter has never seen that device.
        BluetoothDevice device = btAdapter.getRemoteDevice(address);

        Log.d(TAG, "Get Device Info \n" + "address : " + address);

        connect(device);
    }

    /**
     * Sends a message.
     *
     * @param message A string of text to send.
     */
    public void sendMessage(byte[] message) {
        // Check that we're actually connected before trying anything
        if (mState != STATE_CONNECTED) {
            Toast.makeText(mActivity.getApplicationContext(), R.string.not_connected, Toast.LENGTH_SHORT).show();
            return;
        }

        // Check that there's actually something to send
        if (message.length > 0) {
            // Get the message bytes and tell the BluetoothChatService to write
//            byte[] send = message.getBytes();
//            Log.d(TAG, "Sending " + Arrays.toString(send));
//            write(send);
            write(message);
        }
    }

    /**
     * Set the current state of the displaying service
     *
     * @param state An integer defining the current connection state
     */
    private synchronized  void setState(int state) {
        Log.d(TAG, "setState()" + mState + " -> " + state);
        mState = state;

        // Give the new state to the Handler so the UI Activity can update
        mHandler.obtainMessage(Constants.MESSAGE_STATE_CHANGE, state, -1).sendToTarget();
    }

    /**
     * Start the ConnectThread to initiate a connection to a remote device.
     *
     * @param device The BluetoothDevice to connect
     */
    public synchronized  void connect(BluetoothDevice device) {
        Log.d(TAG, "connect to: " + device);

        // Cancel any thread attempting to make a connection
        if (mState == STATE_CONNECTING) {
            if (mConnectThread != null) {
                mConnectThread.cancel();
                mConnectThread = null;
            }
        }

        // Cancel any thread currently running a connection
        if (mConnectedThread != null) {
            mConnectedThread.cancel();
            mConnectedThread = null;
        }

        // Start the thread to connect with the given device
        mConnectThread = new ConnectThread(device);

        mConnectThread.start();
        setState(STATE_CONNECTING);
    }

    /*
     * Initializes ConnectedThread
     */
    public synchronized void connected(BluetoothSocket socket, BluetoothDevice device) {
        Log.d(TAG, "Connected");

        // Cancel the thread that completed the connection
        if (mConnectThread != null) {
            mConnectThread.cancel();
            mConnectThread = null;
        }

        // Cancel any thread currently runnning a connection
        if (mConnectedThread != null) {
            mConnectedThread.cancel();
            mConnectedThread = null;
        }

        // Start the thread to manage the connection and perform transmission
        mConnectedThread = new ConnectedThread(device, socket);
        mConnectedThread.start();

        // Send the name of the connected device back to the UI Activity
        Message msg = mHandler.obtainMessage(Constants.MESSAGE_DEVICE_NAME);
        Bundle bundle = new Bundle();
        bundle.putString(Constants.DEVICE_NAME, device.getName());
        msg.setData(bundle);
        mHandler.sendMessage(msg);

        setState(STATE_CONNECTED);
    }

    /*
     * Stops every threads
     */
    public synchronized void stop() {
        Log.d(TAG, "Stop");

        if (mConnectThread != null) {
            mConnectThread.cancel();
            mConnectThread = null;
        }
        if (mConnectedThread != null) {
            mConnectedThread.cancel();
            mConnectedThread = null;
        }

        setState(STATE_NONE);
    }


    public void write(byte[] out) {
        // Create temporary object
        ConnectedThread r;
        // Synchronize a copy of the ConnectedThread
        synchronized (this) {
            if (mState != STATE_CONNECTED)
                return;
            r = mConnectedThread;
        }
        // Perform the write unsynchronized
        Log.d(TAG, "Sending " + Arrays.toString(out));
        r.write(out);
    }

    /**
     * Indicate that the connection attempt failed and notify the UI Activity.
     */
    private void connectionFailed() {
        // Send a connection failure message back to the Activity
        Message msg = mHandler.obtainMessage(Constants.MESSAGE_TOAST);
        Bundle bundle = new Bundle();
        bundle.putString(Constants.TOAST, "Unable to connect device");
        msg.setData(bundle);
        mHandler.sendMessage(msg);

        setState(STATE_NONE);
    }


    private void connectionLost() {
        // Send a failure message back to the Activity
        Message msg = mHandler.obtainMessage(Constants.MESSAGE_TOAST);
        Bundle bundle = new Bundle();
        bundle.putString(Constants.TOAST, "Device connection was lost");
        msg.setData(bundle);
        mHandler.sendMessage(msg);

        setState(STATE_NONE);
    }

    private class ConnectThread extends Thread {
        private final BluetoothSocket mmSocket;
        private final BluetoothDevice mmDevice;

        public ConnectThread(BluetoothDevice device) {
            mmDevice = device;
            // Use a temporary object that is later assigned to mmSocket
            // because mmSocket is final
            BluetoothSocket tmp = null;

            // Initializes a BluetoothSocket to connect with the given BluetoothDevice
            try {
                tmp = device.createRfcommSocketToServiceRecord(MY_UUID);
                Log.d(TAG, "Created RFCOMM socket");
            } catch (IOException e) {
                Log.e(TAG, "Creating RFCOMM socket failed");
            }
            if (tmp == null)
                Log.d(TAG, "RFCOMM socket is null");
            // Successfully created RFCOMM socket
            mmSocket = tmp;
        }


        public void run() {
            Log.i(TAG, "Beginning mConnectThread");
            setName("ConnectThread");

            // Makes sure discovery process is off because it will slow down the connection
            btAdapter.cancelDiscovery();

            try {
                // Connect the device through the socket. This will block
                // until it succeed or throws an exception
                Log.d(TAG, "Before connection");
                mmSocket.connect();
                Log.d(TAG, "Connection success");
            } catch (IOException connectException) {
                connectionFailed();
                Log.d(TAG, "Connect Fail");
                // Unable to connect; close the socket and get out
                try {
                    mmSocket.close();
                    Log.d(TAG, "Connection failed");
                } catch (IOException closeExcpetion) {
                    Log.e(TAG, "close() of connect socket failed", closeExcpetion);
                }
                // Connection failed. Re-establish the connection
                BluetoothService.this.connect(mmDevice);
                return;
            }
            // resets ConnectThread class using mutual exclusion
            synchronized (BluetoothService.this) {
                mConnectThread = null;
            }
            // Successfully connected, Start ConnectedThread
            connected(mmSocket, mmDevice);
        }

        /* Will cancel an in-progress connection, and close the socket */
        public void cancel() {
            try {
                mmSocket.close();
            } catch (IOException e) {
                Log.e(TAG, "close() of connect socket failed", e);
            }
        }
    }

    /*
     *This is the thread where you can start sharing data between the devices
     * It has to be in thread as read() & write() block
     */
    private class ConnectedThread extends Thread {
        private final BluetoothDevice mmDevice; // Used to make connection again
        private final BluetoothSocket mmSocket;
        private final InputStream mmInstream;
        private final OutputStream mmOutStream;

        public ConnectedThread(BluetoothDevice device, BluetoothSocket socket) {
            Log.d(TAG, "Creating ConnectedThread");
            mmDevice = device;
            mmSocket = socket;
            InputStream tmpIn = null;
            OutputStream tmpOut = null;

            // Gets InputStream and OutputStream from the BluetoothSocket
            try {
                // Using temp objects because member streams are final
                tmpIn = socket.getInputStream();
                tmpOut = socket.getOutputStream();
            } catch (IOException e) {
                Log.e(TAG, "temp input & output streams not created", e);
            }
            if (tmpIn == null)
                Log.d(TAG, "input stream is null");
            mmInstream = tmpIn;
            mmOutStream = tmpOut;
        }

        public void run() {
            Log.i(TAG, "Beginning mConnectedThread");
            byte[] buffer = new byte[1024]; // buffer store for the stream
            int bytes; // bytes returned from read
            int available = 0;
            // Keep listening to the InputStream while connected
//            while (mState == STATE_CONNECTED) {
//                try {
//                    bytes = mmInstream.read(buffer);
//
//                    Log.d(TAG, "Received: " + bytes);
//                    // Send the obtained bytes to the UI activity
//                    mHandler.obtainMessage(Constants.MESSAGE_READ, bytes, -1, buffer)
//                            .sendToTarget();
//                } catch (IOException e) {
//                    Log.e(TAG, "InputStream disconnected");
//                    connectionLost();
//                    connect(mmDevice);
//                    break;
//                }
//            }
            while (true) {
                try {
                    available = mmInstream.available();
                } catch (IOException e) {
                    Log.e(TAG, "Inputstream is not available", e);
                }
                if (available > 0) {
                    try {
                        bytes = mmInstream.read(buffer);

                        Log.d(TAG, "Received: " + bytes);
                        // Send the obtained bytes to the UI activity
                        mHandler.obtainMessage(Constants.MESSAGE_READ, bytes, -1, buffer)
                                .sendToTarget();
                    } catch (IOException e) {
                        Log.e(TAG, "InputStream disconnected");
                        connectionLost();
                        connect(mmDevice);
                        break;
                    }
                }
            }
        }

        /*
         * Write to the connected OutStream
         * Call this from the main activity to send data to the remote device (but not used now)
         * @param buffer The bytes to write
         */
        public void write(byte[] buffer) {
            try {
                mmOutStream.write(buffer);
                Log.d(TAG, "Succeed sending");
            } catch (IOException e) {
                Log.e(TAG, "Exception during write", e);
            }
        }

        /* Call this from the main activity to shutdown the connection */
        public void cancel() {
            try {
                mmSocket.close();
            } catch (IOException e) {
                Log.e(TAG, "close() of connect socket failed", e);
            }
        }
    }
}


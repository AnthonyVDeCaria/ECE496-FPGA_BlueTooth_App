package com.example.hannahkwon.bluetooth1;

/**
 * Created by HannahKwon on 2017-01-10.
 */

import android.app.Service;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothGatt;
import android.bluetooth.BluetoothGattCallback;
import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattDescriptor;
import android.bluetooth.BluetoothGattService;
import android.bluetooth.BluetoothManager;
import android.bluetooth.BluetoothProfile;
import android.content.Context;
import android.content.Intent;
import android.os.Binder;
import android.os.IBinder;
import android.util.Log;

import java.util.Arrays;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.locks.ReentrantLock;

/**
 * Service for managing connection and data communication with a GATT server hosted on a
 * given Bluetooth LE device.
 */
public class BluetoothLeService extends Service {
    private final static String TAG = BluetoothLeService.class.getSimpleName();

    private BluetoothManager mBluetoothManager;
    private BluetoothAdapter mBluetoothAdapter;
    private String mBluetoothDeviceAddress;
    private BluetoothGatt mBluetoothGatt;
    private int mConnectionState = STATE_DISCONNECTED;
    private static final int STATE_DISCONNECTED = 0;
    private static final int STATE_CONNECTING = 1;
    private static final int STATE_CONNECTED = 2;

    public final static String ACTION_GATT_CONNECTED =
            "com.example.bluetooth.le.ACTION_GATT_CONNECTED";
    public final static String ACTION_GATT_DISCONNECTED =
            "com.example.bluetooth.le.ACTION_GATT_DISCONNECTED";
    public final static String ACTION_GATT_SERVICES_DISCOVERED =
            "com.example.bluetooth.le.ACTION_GATT_SERVICES_DISCOVERED";
    public final static String ACTION_DATA_AVAILABLE =
            "com.example.bluetooth.le.ACTION_DATA_AVAILABLE";
    public final static String EXTRA_DATA =
            "com.example.bluetooth.le.EXTRA_DATA";
    public final static UUID UUID_HM_RX_TX =
            UUID.fromString(SampleGattAttributes.HM_RX_TX);

    //TODO delete this
    public final static UUID BATTERY_LEVEL =
            UUID.fromString(SampleGattAttributes.BATTERY_LEVEL);

    private ConnectedThread mConnectedThread;
    private BluetoothGattCharacteristic mcharacteristicTX = null;
    private BluetoothGattCharacteristic mcharacteristicRX = null;
    public static ReentrantLock GattLock = null;
    public static boolean NoGattOperation = true;

    // Implements callback methods for GATT events that the app cares about.  For example,
    // connection change and services discovered.
    private final BluetoothGattCallback mGattCallback = new BluetoothGattCallback() {
        @Override
        public void onConnectionStateChange(BluetoothGatt gatt, int status, int newState) {
            String intentAction;
            if (newState == BluetoothProfile.STATE_CONNECTED) {
                intentAction = ACTION_GATT_CONNECTED;
                mConnectionState = STATE_CONNECTED;
                broadcastUpdate(intentAction);
                Log.i(TAG, "Connected to GATT server.");
                // Attempts to discover services after successful connection.
                Log.i(TAG, "Attempting to start service discovery:" +
                        mBluetoothGatt.discoverServices());

            } else if (newState == BluetoothProfile.STATE_DISCONNECTED) {
                intentAction = ACTION_GATT_DISCONNECTED;
                mConnectionState = STATE_DISCONNECTED;
                Log.i(TAG, "Disconnected from GATT server.");
                broadcastUpdate(intentAction);
            }
        }

        @Override
        public void onServicesDiscovered(BluetoothGatt gatt, int status) {
            if (status == BluetoothGatt.GATT_SUCCESS) {
                broadcastUpdate(ACTION_GATT_SERVICES_DISCOVERED);
            } else {
                Log.w(TAG, "onServicesDiscovered received: " + status);
            }
        }

        @Override
        public void onCharacteristicRead(BluetoothGatt gatt,
                                         BluetoothGattCharacteristic characteristic,
                                         int status) {
            if (status == BluetoothGatt.GATT_SUCCESS) {
                Log.d(TAG, "Characteristic read was successful");
                broadcastUpdate(ACTION_DATA_AVAILABLE, characteristic);
            }
            else if (status == BluetoothGatt.GATT_INSUFFICIENT_AUTHENTICATION ||
                    status == BluetoothGatt.GATT_INSUFFICIENT_ENCRYPTION)
                Log.d(TAG, "Failed to complete operation. Bonding should start shortly");
            else {
                Log.e(TAG, "Characteristic read failed some other reason");
            }
            GattLock.lock();
            try {
                NoGattOperation = true;
            } finally {
                GattLock.unlock();
            }
        }

        @Override
        public void onCharacteristicWrite (BluetoothGatt gatt,
                                           BluetoothGattCharacteristic characteristic,
                                           int status) {
            Log.d(TAG, "Write result is as following");
            if (status == BluetoothGatt.GATT_SUCCESS) {
                Log.d(TAG, "Characteristic write was successful");
                //TODO Move this to the appropriate place. Pair with updateConnectionState(getResources().getString(R.string.connected_to_device, mDeviceName));
//                connected();
            }
            else if (status == BluetoothGatt.GATT_INSUFFICIENT_AUTHENTICATION ||
                    status == BluetoothGatt.GATT_INSUFFICIENT_ENCRYPTION) {
                Log.d(TAG, "Failed to complete operation. Bonding should start shortly");
            }
            else {
                Log.e(TAG, "Characteristic write failed some other reason" + status);
            }
            GattLock.lock();
            try {
                NoGattOperation = true;
            } finally {
                GattLock.unlock();
            }
        }

        @Override
        public void onCharacteristicChanged(BluetoothGatt gatt,
                                            BluetoothGattCharacteristic characteristic) {
            Log.d(TAG, "Received characteristic notification");
            broadcastUpdate(ACTION_DATA_AVAILABLE, characteristic);
        }
    };

    private void broadcastUpdate(final String action) {
        final Intent intent = new Intent(action);
        sendBroadcast(intent);
    }

    private void broadcastUpdate(final String action,final BluetoothGattCharacteristic characteristic) {
        final Intent intent = new Intent(action);

        // For all other profiles, writes the data formatted in HEX.
        final byte[] data = characteristic.getValue();
        Log.i(TAG, "data " + characteristic.getValue());

//        if (data != null && data.length > 0) {
//            final StringBuilder stringBuilder = new StringBuilder(data.length);
//            for(byte byteChar : data)
//                stringBuilder.append(String.format("%02X ", byteChar));
//            Log.d(TAG, String.format("%s", new String(data)));
            // getting cut off when longer, need to push on new line, 0A
//            intent.putExtra(EXTRA_DATA,String.format("%s", new String(data)));
//        }
        Log.d(TAG, String.format("%s", new String(data)));
        intent.putExtra(EXTRA_DATA,String.format("%s", new String(data)));
        sendBroadcast(intent);
    }

    public class LocalBinder extends Binder {
        BluetoothLeService getService() {
            return BluetoothLeService.this;
        }
    }

    @Override
    public IBinder onBind(Intent intent) {
        return mBinder;
    }

    @Override
    public boolean onUnbind(Intent intent) {
        // After using a given device, you should make sure that BluetoothGatt.close() is called
        // such that resources are cleaned up properly.  In this particular example, close() is
        // invoked when the UI is disconnected from the Service.
        close();
        return super.onUnbind(intent);
    }

    private final IBinder mBinder = new LocalBinder();

    /**
     * Initializes a reference to the local Bluetooth adapter.
     *
     * @return Return true if the initialization is successful.
     */
    public boolean initialize() {
        // For API level 18 and above, get a reference to BluetoothAdapter through
        // BluetoothManager.
        if (mBluetoothManager == null) {
            mBluetoothManager = (BluetoothManager) getSystemService(Context.BLUETOOTH_SERVICE);
            if (mBluetoothManager == null) {
                Log.e(TAG, "Unable to initialize BluetoothManager.");
                return false;
            }
        }

        mBluetoothAdapter = mBluetoothManager.getAdapter();
        if (mBluetoothAdapter == null) {
            Log.e(TAG, "Unable to obtain a BluetoothAdapter.");
            return false;
        }

        GattLock = new ReentrantLock();

        return true;
    }

    /**
     * Connects to the GATT server hosted on the Bluetooth LE device.
     *
     * @param address The device address of the destination device.
     *
     * @return Return true if the connection is initiated successfully. The connection result
     *         is reported asynchronously through the
     *         {@code BluetoothGattCallback#onConnectionStateChange(android.bluetooth.BluetoothGatt, int, int)}
     *         callback.
     */
    public boolean connect(final String address) {
        if (mBluetoothAdapter == null || address == null) {
            Log.w(TAG, "BluetoothAdapter not initialized or unspecified address.");
            return false;
        }

        // Previously connected device.  Try to reconnect.
        if (mBluetoothDeviceAddress != null && address.equals(mBluetoothDeviceAddress)
                && mBluetoothGatt != null) {
            Log.d(TAG, "Trying to use an existing mBluetoothGatt for connection.");
            if (mBluetoothGatt.connect()) {
                mConnectionState = STATE_CONNECTING;
                return true;
            } else {
                final BluetoothDevice device = mBluetoothAdapter.getRemoteDevice(address);
                mBluetoothGatt = device.connectGatt(this, false, mGattCallback);
                mBluetoothDeviceAddress = address;
                return false;
            }
        }

        final BluetoothDevice device = mBluetoothAdapter.getRemoteDevice(address);
        if (device == null) {
            Log.w(TAG, "Device not found.  Unable to connect.");
            return false;
        }
        // We want to directly connect to the device, so we are setting the autoConnect
        // parameter to false.
        mBluetoothGatt = device.connectGatt(this, false, mGattCallback);
        Log.d(TAG, "Trying to create a new connection.");
        mBluetoothDeviceAddress = address;
        mConnectionState = STATE_CONNECTING;
        return true;
    }

    /**
     * Disconnects an existing connection or cancel a pending connection. The disconnection result
     * is reported asynchronously through the
     * {@code BluetoothGattCallback#onConnectionStateChange(android.bluetooth.BluetoothGatt, int, int)}
     * callback.
     */
    public void disconnect() {
        if (mBluetoothAdapter == null || mBluetoothGatt == null) {
            Log.w(TAG, "BluetoothAdapter not initialized");
            return;
        }
        mBluetoothGatt.disconnect();
    }

    /**
     * After using a given BLE device, the app must call this method to ensure resources are
     * released properly.
     */
    public void close() {
        if (mBluetoothGatt == null) {
            return;
        }
        mBluetoothGatt.close();
        mBluetoothGatt = null;
    }

    // Demonstrates how to iterate through the supported GATT Services/Characteristics.
    // In this sample, we populate the data structure that is bound to the ExpandableListView
    // on the UI.
    public void displayGattServices(List<BluetoothGattService> gattServices) {
        if (gattServices == null) return;
        String uuid = null;
        String unknownServiceString = "Unknown service";
        boolean serviceFound = false;

        BluetoothGattCharacteristic characteristicTX = null;
        BluetoothGattCharacteristic characteristicRX = null;

        // Loops through available GATT Services.
        for (BluetoothGattService gattService : gattServices) {
            uuid = gattService.getUuid().toString();
            Log.d(TAG, "Discovered service: " + uuid);

//            if (SampleGattAttributes.lookup(uuid, unknownServiceString) == "BATTERY") {
//                Log.d(TAG, "Found Battery Service");
//                // get characteristic when UUID matches RX/TX UUID
//                characteristicTX = gattService.getCharacteristic(BluetoothLeService.BATTERY_LEVEL);
//                characteristicRX = gattService.getCharacteristic(BluetoothLeService.BATTERY_LEVEL);
//                if (characteristicRX == null)
//                    Log.e(TAG, "No characteristics for transfer");
//                mBluetoothLeService.readCharacteristic(characteristicRX);
//            }
            // Found HM-10 connectivity service
            if (SampleGattAttributes.lookup(uuid, unknownServiceString) == "HM 10 Serial") {
                Log.d(TAG, "Found HM 10 Connectivity service");
                serviceFound = true;

                // Extract characteristics
                List<BluetoothGattCharacteristic> gattCharacteristics = gattService.getCharacteristics();
                for (BluetoothGattCharacteristic gattCharacteristic : gattCharacteristics) {
                    Log.d(TAG, "Discovered GATT Characteristic: "+ gattCharacteristic.toString());

                    boolean isWritable = isWritableCharacteristic(gattCharacteristic);
                    if(isWritable) {
                        characteristicTX = gattCharacteristic;
                    }

                    boolean isReadable = isReadableCharacteristic(gattCharacteristic);
                    if(isReadable) {
                        characteristicRX = gattCharacteristic;
                    }

                    if(isNotificationCharacteristic(gattCharacteristic)) {
                        setCharacteristicNotification(gattCharacteristic, true);
                    }
//                    // get characteristic when UUID matches RX/TX UUID
//                    characteristicTX = gattService.getCharacteristic(BluetoothLeService.UUID_HM_RX_TX);
//                    characteristicRX = gattService.getCharacteristic(BluetoothLeService.UUID_HM_RX_TX);
                    if (characteristicRX == null || characteristicTX == null)
                        Log.e(TAG, "No characteristics for transfer");
                    // For bonding
                    //                mBluetoothLeService.readCharacteristic(characteristicRX);
                    // starting thread for reading characteristics
                    setCharacteristic(characteristicTX, characteristicRX);
                    connected();
                    // Only now show it is connected
                    //                updateConnectionState(getResources().getString(R.string.connected_to_device, mDeviceName));
                }
            }
        }
        if(!serviceFound)
            Log.e(TAG, "No HM 10 Connectivity service");
    }

    private boolean isWritableCharacteristic(BluetoothGattCharacteristic chr) {
        if(chr == null) return false;

        final int charaProp = chr.getProperties();
        if (((charaProp & BluetoothGattCharacteristic.PROPERTY_WRITE) |
                (charaProp & BluetoothGattCharacteristic.PROPERTY_WRITE_NO_RESPONSE)) > 0) {
            Log.d(TAG, "Found writable characteristic");
            return true;
        } else {
            Log.d(TAG, "Not writable characteristic");
            return false;
        }
    }

    private boolean isReadableCharacteristic(BluetoothGattCharacteristic chr) {
        if(chr == null) return false;

        final int charaProp = chr.getProperties();
        if((charaProp & BluetoothGattCharacteristic.PROPERTY_READ) > 0) {
            Log.d(TAG, "Found readable characteristic");
            return true;
        } else {
            Log.d(TAG, "Not readable characteristic");
            return false;
        }
    }

    private boolean isNotificationCharacteristic(BluetoothGattCharacteristic chr) {
        if (chr == null) return false;

        final int charaProp = chr.getProperties();
        if ((charaProp & BluetoothGattCharacteristic.PROPERTY_NOTIFY) > 0) {
            Log.d(TAG, "Found notification characteristic");
            return true;
        } else {
            Log.d(TAG, "Not notification characteristic");
            return false;
        }
    }

    /**
     * Request a read on a given {@code BluetoothGattCharacteristic}. The read result is reported
     * asynchronously through the {@code BluetoothGattCallback#onCharacteristicRead(android.bluetooth.BluetoothGatt, android.bluetooth.BluetoothGattCharacteristic, int)}
     * callback.
     */
    public void readCharacteristic() {
        if (mBluetoothAdapter == null || mBluetoothGatt == null) {
            Log.w(TAG, "BluetoothAdapter not initialized");
            return;
        }
        if (mcharacteristicRX == null)
            Log.e(TAG, "Characteristic is null");

        Log.d(TAG, "Execute readCharacteristic()");
        mBluetoothGatt.readCharacteristic(mcharacteristicRX);
    }

    /**
     * Write to a given char
     */
    public void writeCharacteristic(byte[] out) {
        if (mBluetoothAdapter == null || mBluetoothGatt == null) {
            Log.w(TAG, "BluetoothAdapter not initialized");
            return;
        }
        if (mcharacteristicTX == null)
            Log.e(TAG, "Characteristic is null");

        if(out.length > 20) {
            Log.e(TAG, "Cannot write longer than 20 bytes");
            return;
        }

        mcharacteristicTX.setValue(out);
        // For now, expecting no response from BLE module
        mcharacteristicTX.setWriteType(BluetoothGattCharacteristic.WRITE_TYPE_NO_RESPONSE);
        Log.d(TAG, "Sending " + Arrays.toString(mcharacteristicTX.getValue()));
        Log.d(TAG, "Execute writeCharacteristic()");
        mBluetoothGatt.writeCharacteristic(mcharacteristicTX);
    }

    /**
     * Enables or disables notification on a give characteristic.
     *
     * @param characteristic Characteristic to act on.
     * @param enabled If true, enable notification.  False otherwise.
     */
    public void setCharacteristicNotification(BluetoothGattCharacteristic characteristic,
                                              boolean enabled) {
        if (mBluetoothAdapter == null || mBluetoothGatt == null) {
            Log.w(TAG, "BluetoothAdapter not initialized");
            return;
        }
        if(characteristic != null) {
            mBluetoothGatt.setCharacteristicNotification(characteristic, enabled); // Enabled locally

            BluetoothGattDescriptor descriptor = characteristic.getDescriptor(
                        UUID.fromString(SampleGattAttributes.CLIENT_CHARACTERISTIC_CONFIG));

            if(enabled)
                descriptor.setValue(BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE);
            else
                descriptor.setValue(BluetoothGattDescriptor.DISABLE_NOTIFICATION_VALUE);

            mBluetoothGatt.writeDescriptor(descriptor); // Enabled remotely
        }
        else
            Log.e(TAG, "Failed to set notification as the characteristic is null!");
    }

    /**
     * Retrieves a list of supported GATT services on the connected device. This should be
     * invoked only after {@code BluetoothGatt#discoverServices()} completes successfully.
     *
     * @return A {@code List} of supported services.
     */
    public List<BluetoothGattService> getSupportedGattServices() {
        if (mBluetoothGatt == null) return null;

        return mBluetoothGatt.getServices();
    }

    /**
     * Sets characteristics discovered
     * @param characteristicTX The characteristic to write to
     * @param characteristicRX The characteristic to read from
     */
    public void setCharacteristic(BluetoothGattCharacteristic characteristicTX, BluetoothGattCharacteristic characteristicRX) {
        mcharacteristicTX = characteristicTX;
        mcharacteristicRX = characteristicRX;
    }

    /**
     * Resets characteristics to null
     */
    public void resetCharacteristic() {
        mcharacteristicTX = null;
        mcharacteristicRX = null;
    }

    /**
     * Checks if characteristics are set. (Checks if it is ready for data transfer)
     * @return true if characteristics are set
     * @return false if one of the characteristic is null
     */
    public boolean checkCharacteristic() {
        if (mcharacteristicRX == null || mcharacteristicTX ==null)
            return false;
        else
            return true;
    }

    public synchronized void connected () {
        Log.d(TAG, "Connected");

        // Start the thread to manage the connection and perform transmission
        mConnectedThread = new ConnectedThread();
        mConnectedThread.start();
    }

//    public synchronized  void sleep() {
//        Log.d(TAG, "Turn ConnnectedThread into sleep");
//        if (mConnectedThread != null)
//            mConnectedThread.sleep();
//    }

    /*
    * This is the thread where you can start sharing data between the devices
    * It has to be in thread as read() & write() block
    */
    private class ConnectedThread extends Thread {

        public ConnectedThread() {
            Log.d(TAG, "Creating ConnectedThread");
        }

        public void run() {
            Log.i(TAG, "Beginning mConnectedThread");
            while (true) {
                if(GattLock == null)
                    Log.e(TAG, "Lock for Gatt operation is not initialized!");
                GattLock.lock();
                try {
                    if(NoGattOperation) { // No Gatt operation is being processed at the moment
                        NoGattOperation = false;
                        readCharacteristic();
                    }
                } finally {
                    GattLock.unlock();
                }
            }
        }

        /*
         * Write to the connected OutStream
         * Call this from the main activity to send data to the remote device (but not used now)
         * @param buffer The bytes to write
         */
//        public void write(byte[] buffer) {
//            try {
//                mmOutStream.write(buffer);
//                Log.d(TAG, "Succeed sending");
//            } catch (IOException e) {
//                Log.e(TAG, "Exception during write", e);
//            }
//        }
    }
}

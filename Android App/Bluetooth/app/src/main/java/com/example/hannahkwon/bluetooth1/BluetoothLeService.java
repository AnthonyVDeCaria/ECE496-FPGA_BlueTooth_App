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
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Binder;
import android.os.IBinder;
import android.support.v4.content.LocalBroadcastManager;
import android.util.Log;

import java.util.Arrays;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.locks.ReentrantLock;

import static com.example.hannahkwon.bluetooth1.Constants.ACK;

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

    private BluetoothGattCharacteristic mcharacteristicTX = null;
    private BluetoothGattCharacteristic mcharacteristicRX = null;
    public static ReentrantLock GattLock = null;
    public static boolean NoGattOperation = true;

    LocalBroadcastManager manager;
    private PackagingThread mPackagingThread;

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
//            broadcastUpdate(ACTION_DATA_AVAILABLE, characteristic);

            mPackagingThread.add(characteristic.getValue());
        }
    };

    private void broadcastUpdate(final String action) {
        final Intent intent = new Intent(action);
        manager.sendBroadcast(intent);
    }

    private void broadcastUpdate(final String action, final BluetoothGattCharacteristic characteristic) {
        final Intent intent = new Intent(action);

        // For all other profiles, writes the data formatted in HEX.
        final byte[] data = characteristic.getValue();
        Log.i(TAG, "data " + characteristic.getValue());

//        if (data != null && data.length > 0) {
//            final StringBuilder stringBuilder = new StringBuilder(data.length);
//            for(byte byteChar : data)
//                stringBuilder.append(String.format("%02X ", byteChar));
//            intent.putExtra(EXTRA_DATA, stringBuilder.toString());
//        }
        Log.d(TAG, String.format("%s", new String(data)));
//        intent.putExtra(EXTRA_DATA,String.format("%s", new String(data)));
        intent.putExtra(EXTRA_DATA, data);
        manager.sendBroadcast(intent);
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

    private final BroadcastReceiver mPairReceiver = new BroadcastReceiver() {
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();

            if (BluetoothDevice.ACTION_BOND_STATE_CHANGED.equals(action)) {
                int state        = intent.getIntExtra(BluetoothDevice.EXTRA_BOND_STATE, BluetoothDevice.ERROR);
                int prevState    = intent.getIntExtra(BluetoothDevice.EXTRA_PREVIOUS_BOND_STATE, BluetoothDevice.ERROR);

                if (state == BluetoothDevice.BOND_BONDED && prevState == BluetoothDevice.BOND_BONDING) {
                    Log.d(TAG, "Bonded with the device");
                    connect(mBluetoothDeviceAddress);
                }
                else if (state == BluetoothDevice.BOND_NONE && prevState == BluetoothDevice.BOND_BONDED){
                    Log.d(TAG, "Unpaired with the device");
                }
            }
        }
    };

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
        manager = LocalBroadcastManager.getInstance(this);

        startPackaging();

        // for bonding
        IntentFilter intent = new IntentFilter(BluetoothDevice.ACTION_BOND_STATE_CHANGED);
        registerReceiver(mPairReceiver, intent);

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
        // check if the device is bonded
        int bondState = device.getBondState();
        if(bondState == BluetoothDevice.BOND_NONE) { // Not bonded
            Log.i(TAG, "Device is not bonded. Trying to bond");
            mBluetoothDeviceAddress = address;
            device.createBond();
            return true;
        }
        else if (bondState == BluetoothDevice.BOND_BONDED) {
            // We want to directly connect to the device, so we are setting the autoConnect
            // parameter to false
            mBluetoothGatt = device.connectGatt(this, false, mGattCallback);
            Log.d(TAG, "Trying to create a new connection.");
            mBluetoothDeviceAddress = address;
            mConnectionState = STATE_CONNECTING;
            return true;
        }
        else {
            return true;
        }
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

            // Found HM-10 connectivity service
            if (SampleGattAttributes.lookup(uuid, unknownServiceString) == "HM 10 Serial") {
                Log.d(TAG, "Found HM 10 Connectivity service");
                serviceFound = true;

                // Extract characteristics
                List<BluetoothGattCharacteristic> gattCharacteristics = gattService.getCharacteristics();
                for (BluetoothGattCharacteristic gattCharacteristic : gattCharacteristics) {
                    Log.d(TAG, "Discovered GATT Characteristic: "+ gattCharacteristic.getUuid().toString());

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
                    if (characteristicRX == null || characteristicTX == null)
                        Log.e(TAG, "No characteristics for transfer");
                    setCharacteristic(characteristicTX, characteristicRX);
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

    public void write(byte[] out) {
        if(GattLock == null)
            Log.e(TAG, "Lock for Gatt operation is not initialized!");
        boolean writeDone = false;
        while(true) {
            GattLock.lock();
            try {
                if(NoGattOperation) { // No Gatt operation is being processed at the moment
                    NoGattOperation = false;
                    writeCharacteristic(out);
                    writeDone = true;
                }
            } finally {
                GattLock.unlock();
                if(writeDone)
                    return;
            }
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
            Log.d(TAG, "Setting characteristic notification");
            mBluetoothGatt.setCharacteristicNotification(characteristic, enabled); // Enabled locally

            BluetoothGattDescriptor descriptor = characteristic.getDescriptor(
                    UUID.fromString(SampleGattAttributes.CLIENT_CHARACTERISTIC_CONFIG));

            if(enabled) {
                Log.d(TAG, "Enabled notification remotely");
                descriptor.setValue(BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE);
            }
            else {
                Log.d(TAG, "Disabled notification remotely");
                descriptor.setValue(BluetoothGattDescriptor.DISABLE_NOTIFICATION_VALUE);
            }
            mBluetoothGatt.writeDescriptor(descriptor); // Configured remote device
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

    public synchronized void startPackaging () {
        Log.d(TAG, "Start Packaging");

        // Start the thread to manage the connection and perform transmission
        mPackagingThread = new PackagingThread();
        mPackagingThread.start();
    }

    /*
    * This is the thread where it collects bytes received from FPGA
    * to form the entire packet
    * Once the packet is formed, it is transferred to the MainActivity
    */
    private class PackagingThread extends Thread {
        LinkedBlockingQueue<byte []> mmFIFOQueue = new LinkedBlockingQueue<byte []>();
        private byte [] mmPackagedData = new byte[16];
        private byte [] mmDataAvailable = null;
        private byte[] commandPacket = null;
        private int offset = 0; // starting point of read left
        private int length_left = 0; // length_left to be read in a single packet
        private int read_left = 16; // more to be read to fill full packet
        private int length_used = 0;
        private boolean more_to_read = false;

        private int position = 0;  // to keep track of starting point of saving

        public PackagingThread() {
            Log.d(TAG, "Creating PackagingThread");
            commandPacket = new byte[1];
            commandPacket[0] = ACK;
        }

        public void run(){
            Log.i(TAG, "Beginning mPackagingThread");
            while (true) {
                // getting arbitrary length_left of bytes
                mmDataAvailable = mmFIFOQueue.peek();
                if (mmDataAvailable != null) {
                    if (length_left == 0)
                        length_used = mmDataAvailable.length;
                    else
                        length_used = length_left;
    //                    Log.d(TAG, "Length used is " + length_used);
                    if(position == 0) {    // at the very first packaging
                        if (length_left == 0) {
                            if (mmDataAvailable.length > 16) {
                                System.arraycopy(mmDataAvailable, offset, mmPackagedData, position, 16);
                            }
                            else {
                                System.arraycopy(mmDataAvailable, offset, mmPackagedData, position, mmDataAvailable.length);
                            }
                        }
                        else {
                            System.arraycopy(mmDataAvailable, offset, mmPackagedData, position, length_left);
                        }
                        position += offset;

    //                        Log.d(TAG, "At the very first packaging");
                        if (length_used > 16) {   // the packet received was more than full packet
    //                            Log.d(TAG, "There are more bytes than full packet");
                            offset = offset + 16;
                            length_left = length_used - 16;
                            read_left = 0;
                            more_to_read = false;

    //                            Log.d(TAG, "Next packet offset: " + offset + ", length_left: " + length_left + ", read_left: " + read_left);
                        }
                        else if (length_used < 16){  // the packet received was partial packet
    //                            Log.d(TAG, "There are bytes missing");
                            offset = 0;
                            length_left = 0;
                            read_left = 16 - length_used;
                            more_to_read = true;
    //                            Log.d(TAG, "Next packet offset: " + offset + ", length_left: " + length_left + ", read_left: " + read_left);

                            mmFIFOQueue.remove();
                        }
                        else {  // the packet received was full packet
                            mmFIFOQueue.remove();

                            offset = 0;
                            length_left = 0;
                            read_left = 0;
                            more_to_read = false;

    //                            Log.d(TAG, "Next packet offset: " + offset + ", length_left: " + length_left + ", read_left: " + read_left);
                        }
                    }
                    else {
                        if(more_to_read) {   // at the next packaging
                            if (length_left == 0) {
                                if (mmDataAvailable.length > read_left) {
                                    System.arraycopy(mmDataAvailable, offset, mmPackagedData, position, read_left);
                                }
                                else {
                                    System.arraycopy(mmDataAvailable, offset, mmPackagedData, position, mmDataAvailable.length);
                                }
                            }
                            else {
                                System.arraycopy(mmDataAvailable, offset, mmPackagedData, position, length_left);
                            }
                            position += offset;

    //                            Log.d(TAG, "At the next packaging");
                            if (length_used > read_left) {
    //                                Log.d(TAG, "There are more bytes than full packet");
                                offset = offset + read_left;
                                length_left = length_used - read_left;
                                read_left = 0;
                                more_to_read = false;

    //                                Log.d(TAG, "Next packet offset: " + offset + ", length_left: " + length_left + ", read_left: " + read_left);
                            }
                            else if (length_used < read_left){  // the packet received was partial packet
    //                                Log.d(TAG, "There are bytes missing");
                                offset = 0;
                                length_left = 0;
                                read_left = read_left - length_used;
                                more_to_read = true;

    //                                Log.d(TAG, "Next packet offset: " + offset + ", length_left: " + length_left + ", read_left: " + read_left);

                                mmFIFOQueue.remove();
                            }
                            else {  // the packet received was full packet
                                mmFIFOQueue.remove();

                                offset = 0;
                                length_left = 0;
                                read_left = 0;
                                more_to_read = false;

    //                                Log.d(TAG, "Next packet offset: " + offset + ", length_left: " + length_left + ", read_left: " + read_left);
                            }

                        }
                    }

                    if(!more_to_read) {   // received full packet (128 bits)
    //                        Log.d(TAG, "Got the full packet");
    //                        if (mmPackagedData != null && mmPackagedData.length > 0) {
    //                            final StringBuilder stringBuilder = new StringBuilder(mmPackagedData.length);
    //                            for(byte byteChar : mmPackagedData)
    //                                stringBuilder.append(String.format("%02X ", byteChar));
    //                            Log.d(TAG, "Full packet data is " + stringBuilder.toString());
    //                        }
                        Intent intent = new Intent(ACTION_DATA_AVAILABLE);
                        intent.putExtra(EXTRA_DATA, mmPackagedData);
                        manager.sendBroadcast(intent);

                        // resetting
                        mmPackagedData = new byte[16];
                    }
                }
            }
        }

        public synchronized void add (byte[] data) {
//            Log.i(TAG, "Adding into FIFO queue " + data);
//            if (data != null && data.length > 0) {
//                final StringBuilder stringBuilder = new StringBuilder(data.length);
//                for(byte byteChar : data)
//                    stringBuilder.append(String.format("%02X ", byteChar));
//                Log.d(TAG, "Adding into FIFO queue "  + stringBuilder.toString() + "(" + mmPacketCount + ")");
//            }
//            mmPacketCount++;
            try {
                mmFIFOQueue.put(data);
            } catch (Exception e) {
                Log.e(TAG, "Failed adding into Packaging FIFO queue", e);
            }
        }
    }
}

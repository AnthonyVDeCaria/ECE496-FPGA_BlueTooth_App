package com.example.hannahkwon.bluetooth1;

import android.Manifest;
import android.app.Activity;
import android.app.Dialog;
import android.bluetooth.BluetoothDevice;
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.ServiceConnection;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.IBinder;
import android.os.Message;
import android.support.v4.app.ActivityCompat;
import android.support.v4.app.DialogFragment;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.Menu;
import android.view.View;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.GridLayout;
import android.widget.TextView;
import android.widget.Toast;

import static com.example.hannahkwon.bluetooth1.BluetoothLeService.GattLock;
import static com.example.hannahkwon.bluetooth1.BluetoothLeService.NoGattOperation;
import static com.example.hannahkwon.bluetooth1.DeviceListActivity.EXTRA_DEVICE_ADDRESS;
import static com.example.hannahkwon.bluetooth1.DeviceListActivity.EXTRA_DEVICE_NAME;

public class MainActivity extends AppCompatActivity
        implements RepromptBtDialogFragment.RepromptBtDialogListener, NotSupportBtDialogFragment.NotSupportBtDialogListener, GetFileNameDialogFragment.GetFileNameDialogListener{

    private static final String TAG = "MainActivity";

    private android.support.v7.widget.Toolbar toolbar;

    // Bluetooth related
    private TextView txt_BtStatus;
    private TextView txt_DataReceived;

    private Button bt_Save;

    private GridLayout gridLayout_Channels;
    private CheckBox checkBox_DS1;
    private CheckBox checkBox_DS2;
    private CheckBox checkBox_DS3;
    private CheckBox checkBox_DS4;
    private CheckBox checkBox_DS5;
    private CheckBox checkBox_DS6;
    private CheckBox checkBox_DS7;
    private CheckBox checkBox_DS8;

    private Button bt_Start;
    private Button bt_Cancel;

    private int btType = -1;
    private BluetoothService btService = null;

    private BluetoothLeService mBluetoothLeService;
    private boolean mBound = false;
    private String mDeviceAddress;
    private String mDeviceName;

    private FileManager fileManager = null;

    private final Handler mHandler = new Handler(){
        @Override
        public void handleMessage(Message msg){
            super.handleMessage(msg);

            switch (msg.what) {
                case Constants.MESSAGE_BLUETOOTH_ON:
                    txt_BtStatus.setText(R.string.bluetooth_on);
                    break;
                // Shows the state of connection
                case Constants.MESSAGE_STATE_CHANGE:
                    switch (msg.arg1) {
                        case BluetoothService.STATE_NONE:
                            txt_BtStatus.setText(R.string.not_connected);
                            break;
                        case BluetoothService.STATE_CONNECTING:
                            txt_BtStatus.setText(R.string.connecting);
                            break;
                    }
                    break;
                // Add data received to textview
                case Constants.MESSAGE_READ:
                    byte[] readBuf = (byte[]) msg.obj;
                    String writeMessage = new String(readBuf, 0, msg.arg1);
//                    Log.d(TAG, "Data recevied " + writeMessage);
                    txt_DataReceived.append(writeMessage);
                    break;
                // Device connected. Now sharing data is possible.
                case Constants.MESSAGE_DEVICE_NAME:
                    String deviceName = msg.getData().getString(Constants.DEVICE_NAME);
                    txt_BtStatus.setText(getString(R.string.connected_to_device, deviceName));
                    break;
                // For informing any connection failure
                case Constants.MESSAGE_TOAST:
                    Toast.makeText(MainActivity.this, msg.getData().getString(Constants.TOAST),
                            Toast.LENGTH_SHORT).show();
                    break;
            }
        }
    };

    // to listen to any changes to Bluetooth Adapter
//    private final BroadcastReceiver mReceiver = new BroadcastReceiver() {
//        @Override
//        public void onReceive(Context context, Intent intent) {
//            final String action = intent.getAction();
//
//            if (action.equals(BluetoothAdapter.ACTION_STATE_CHANGED)) {
//               final int state = intent.getIntExtra(BluetoothAdapter.EXTRA_STATE,BluetoothAdapter.ERROR);
//
//                switch (state){
//                    case BluetoothAdapter.STATE_OFF:
//
//                        break;
//                    case BluetoothAdapter.STATE_TURNING_OFF:
//                        break;
//                    case BluetoothAdapter.STATE_DISCONNECTED:
//                        //TODO show the sensor is disconnected
//                        break;
//                    case BluetoothAdapter.STATE_DISCONNECTING:
//                        break;
//                }
//            }
//        }
//    };

    private static IntentFilter makeGattUpdateIntentFilter() {
        final IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction(BluetoothLeService.ACTION_GATT_CONNECTED);
        intentFilter.addAction(BluetoothLeService.ACTION_GATT_DISCONNECTED);
        intentFilter.addAction(BluetoothLeService.ACTION_GATT_SERVICES_DISCOVERED);
        intentFilter.addAction(BluetoothLeService.ACTION_DATA_AVAILABLE);
        return intentFilter;
    }

    private void updateConnectionState(final String data) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Log.d(TAG, "Changing Bluetooth Status to " + data);
                txt_BtStatus.setText(data);
            }
        });
    }

    private void displayData(final String data) {

        if (data != null) {
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    Log.d(TAG, "Displaying data :" + data);
                    txt_DataReceived.append(data);
                }
            });
        }
        else {
            Log.e(TAG, "Failed displaying data");
        }
    }



    // Handles various events fired by the Service.
    // ACTION_GATT_CONNECTED: connected to a GATT server.
    // ACTION_GATT_DISCONNECTED: disconnected from a GATT server.
    // ACTION_GATT_SERVICES_DISCOVERED: discovered GATT services.
    // ACTION_DATA_AVAILABLE: received data from the device.  This can be a result of read
    //                        or notification operations.
    private final BroadcastReceiver mGattUpdateReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            final String action = intent.getAction();
            if (BluetoothLeService.ACTION_GATT_CONNECTED.equals(action)) {
                Log.d(TAG, "Connected to a GATT server");
                updateConnectionState(getResources().getString(R.string.connected_to_device, mDeviceName));
            } else if (BluetoothLeService.ACTION_GATT_DISCONNECTED.equals(action)) {
                Log.d(TAG, "Disconnected from a GATT server");
                // reset characteristic
                mBluetoothLeService.resetCharacteristic();
                updateConnectionState(getResources().getString(R.string.disoconnted));
            } else if (BluetoothLeService.ACTION_GATT_SERVICES_DISCOVERED.equals(action)) {
                //Show all the supported services and characteristics on the user interface.
                Log.d(TAG, "Discovered GATT services");
                mBluetoothLeService.displayGattServices(mBluetoothLeService.getSupportedGattServices());
            }
            if (BluetoothLeService.ACTION_DATA_AVAILABLE.equals(action)) {
                Log.d(TAG, "Received data");
                displayData(intent.getStringExtra(BluetoothLeService.EXTRA_DATA));
            }
        }
    };

    // Code to manage Service lifecycle.
    private final ServiceConnection mServiceConnection = new ServiceConnection() {

        // Called when the connection with the service is established
        @Override
        public void onServiceConnected(ComponentName componentName, IBinder service) {
            mBluetoothLeService = ((BluetoothLeService.LocalBinder) service).getService();
            mBound = true;
            if (!mBluetoothLeService.initialize()) {
                Log.e(TAG, "Unable to initialize Bluetooth");
                finish();
            }
            // Automatically connects to the device upon successful start-up initialization.
            Log.d(TAG, "Connecting to the device");
            if(!mBluetoothLeService.connect(mDeviceAddress))
                Log.e(TAG, "Connection initiation failed");
        }

        // Called when the connection with the service disconnects unexpectedly
        @Override
        public void onServiceDisconnected(ComponentName componentName) {
            Log.e(TAG, "onServiceDisconnected");
            mBluetoothLeService = null;
            mBound = false;
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        Log.d(TAG, "MainActivity is getting created");

        setContentView(R.layout.activity_main);

        toolbar = (Toolbar) findViewById(R.id.toolBar);
        setSupportActionBar(toolbar);

        txt_BtStatus = (TextView) findViewById(R.id.txt_BtStatus);
        txt_DataReceived = (TextView) findViewById(R.id.txt_DataReceived);

        bt_Save = (Button) findViewById(R.id.btn_Save);

        gridLayout_Channels = (GridLayout) findViewById(R.id.gridLayout_Channels);
        checkBox_DS1 = (CheckBox) findViewById(R.id.checkBox_DS1);
        checkBox_DS2 = (CheckBox) findViewById(R.id.checkBox_DS2);
        checkBox_DS3 = (CheckBox) findViewById(R.id.checkBox_DS3);
        checkBox_DS4 = (CheckBox) findViewById(R.id.checkBox_DS4);
        checkBox_DS5 = (CheckBox) findViewById(R.id.checkBox_DS5);
        checkBox_DS6 = (CheckBox) findViewById(R.id.checkBox_DS6);
        checkBox_DS7 = (CheckBox) findViewById(R.id.checkBox_DS7);
        checkBox_DS8 = (CheckBox) findViewById(R.id.checkBox_DS8);
        bt_Start = (Button) findViewById(R.id.btn_Start);
        bt_Cancel = (Button) findViewById(R.id.btn_Cancel);

        // TODO scale the gridlayout

        if(btService == null){
            btService = new BluetoothService(this, mHandler);
        }
        if(btService.getDeviceState()){
            // the device supports Bluetooth
            btService.enableBluetooth();

//            IntentFilter filter = new IntentFilter(BluetoothAdapter.ACTION_STATE_CHANGED);
//            registerReceiver(mReceiver,filter);
        }
        else{
            // sets up a dialogue saying the device does not support Bluetooth and kill the app
            showNotSupportBtDialog();
        }

        if(fileManager == null){
            fileManager = new FileManager(this);
        }

        bt_Save.setOnClickListener(new View.OnClickListener(){
            public void onClick(View v){
                if(fileManager.isExternalStorageAvailable()) { // External storage is available
                    verifyWriteStoragePermission(MainActivity.this);
                }
                else { // External storage is not available
                    showStorageNotWorkingDialog();
                }
            }
        });

        bt_Start.setOnClickListener(new View.OnClickListener(){
            public void onClick(View v){
                // TODO Compare with the Are_Active channels wit the user's selected channels and notify

                // Sends Start command using the user's selection upon the channels
//                String commandArg;
//                commandArg = new String(setCommandArg());
                // encoding command arg into UTF-8
//                commandArg = new String(setCommandArg(), 0, 1);
//                Log.d(TAG, "Command arg is encoded into " + commandArg);
                Log.d(TAG, "Pressed Start");
                commandPacketCreator((byte) Constants.START, setCommandArg());
            }
        });
        bt_Cancel.setOnClickListener(new View.OnClickListener(){
            public void onClick(View v){
                // TODO wipe out the screen

                Log.d(TAG, "Pressed Cancel");
                commandPacketCreator((byte) Constants.CANCEL);
            }
        });
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        //TODO start from here
        getMenuInflater().inflate(R.menu.menu_main, menu);
        return true;
    }

    @Override
    protected void onStart(){
        super.onStart();

        Log.d(TAG, "MainActivity is getting started");
    }

    @Override
    protected void onResume() {
        super.onResume();
        registerReceiver(mGattUpdateReceiver, makeGattUpdateIntentFilter());
        if (mBluetoothLeService != null) {
            final boolean result = mBluetoothLeService.connect(mDeviceAddress);
            Log.d(TAG, "Connect request result=" + result);
        }
    }

    @Override
    protected void onPause() {
        super.onPause();
        unregisterReceiver(mGattUpdateReceiver);
    }

    @Override
    protected void onStop(){
        super.onStop();

        Log.d(TAG, "MainActivity is getting stopped");
        // unregister broadcast receiver
//        unregisterReceiver(mReceiver);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();

        Log.d(TAG, "MainActivity is getting destroyed");

        if (btService != null) {
            // Stops ConnectThread and ConnectedThread
            btService.stop();
        }
        if(mBound) {
            unbindService(mServiceConnection);
            mBluetoothLeService = null;
            mBound = false;
        }
    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
        //No call for super(). Bug on API Level > 11.
    }

    /* Gets result from the previous activity */
    public void onActivityResult(int requestCode, int resultCode, Intent data){
        switch (requestCode){
            //when the request to enable Bluetooth returns
            case Constants.REQUEST_ENABLE_BT:
                if (resultCode == Activity.RESULT_OK){ // BlueTooth enabled
                    Log.d(TAG,"Bluetooth is enabled");
                    txt_BtStatus.setText(R.string.bluetooth_on);

                    // Scan for devices
                    btService.scanDevice();
                }
                else{ // user pressed "No"
                    Log.d(TAG,"Bluetooth is not enabled");

                    // has to re-prompt user for the bluetooth (creates a dialogue)
                    showRepromptBtDialog();
                }
                break;
            // When Device ListActivity returns with a device to connect
            case Constants.REQUEST_CONNECT_DEVICE:
                if (resultCode == Activity.RESULT_OK) {
                    btType = data.getExtras().getInt(DeviceListActivity.EXTRA_DEVICE_TYPE);

                    // Device supports only BLE
                    if (btType == BluetoothDevice.DEVICE_TYPE_LE) {
                        Log.d(TAG, "Device selected supports BLE only");
                        mDeviceName = data.getStringExtra(EXTRA_DEVICE_NAME);
                        mDeviceAddress = data.getStringExtra(EXTRA_DEVICE_ADDRESS);
                        Intent gattServiceIntent = new Intent(this, BluetoothLeService.class);
                        try {
                            if(!bindService(gattServiceIntent, mServiceConnection, BIND_AUTO_CREATE))
                                Log.e(TAG, "Failed binding to BluetoothLeService");
                        } catch (Exception e){
                            Log.e(TAG, "Failed binding to BluetoothLeService", e);
                        }
                    }
                    else {
                        btService.getDeviceInfo(data);
                    }
                }
                break;
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode,
                                           String permissions[], int[] grantResults) {
        switch (requestCode) {
            case Constants.PERMISSION_WRITE_EXTERNAL_STORAGE: {
                // If request is cancelled, the result arrays are empty.
                if (grantResults.length > 0
                        && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    // permission granted
                    Log.d(TAG, "User granted the permission");
                    if(!fileManager.createStorageDir()) {   // failed creating parent directory
                        Toast.makeText(this, R.string.failed_creating_parent_directory,
                                Toast.LENGTH_SHORT).show();
                    }
                    else {
                        // Get file name and save
                        showGetFileNameDialog();
                    }
                }
                else {
                    Log.d(TAG, "Permission is denied");
                    DialogFragment dialog = RationalDialogFragment.newInstance(getString(R.string.permission_write_storage),
                            getString(R.string.permission_write_storage_rationale));
                    dialog.show(this.getSupportFragmentManager(), "RationalDialogFragment");
                }
                return;
            }
            case Constants.PERMISSION_READ_EXTERNAL_STORAGE: {
                // If request is cancelled, the result arrays are empty.
                if (grantResults.length > 0
                        && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    // permission granted
                    Log.d(TAG, "User granted the permission");

                }
                else { // for now it shouldn't fall here
                    Log.d(TAG, "Permission is denied");
                    DialogFragment dialog = RationalDialogFragment.newInstance(getString(R.string.permission_read_storage),
                            getString(R.string.permission_read_storage_rationale));
                    dialog.show(this.getSupportFragmentManager(), "RationalDialogFragment");
                }
                return;
            }
            // other 'case' lines to check for other
            // permissions this app might request
        }
    }

    /**
     * Creates command argument byte using bitwise OR
     */
    private byte setCommandArg(){
        int commandArg = 0b000000000;
        byte ret;
//        byte temp;
//        String ret;
        if(checkBox_DS1.isChecked()) {
            Log.d(TAG, "Check Box Channel 1 is checked");
            commandArg = commandArg | Constants.DS1;
        }
        if(checkBox_DS2.isChecked()) {
            Log.d(TAG, "Check Box Channel 2 is checked");
            commandArg = commandArg | Constants.DS2;
        }
        if(checkBox_DS3.isChecked()) {
            Log.d(TAG, "Check Box Channel 3 is checked");
            commandArg = commandArg | Constants.DS3;
        }
        if(checkBox_DS4.isChecked()) {
            Log.d(TAG, "Check Box Channel 4 is checked");
            commandArg = commandArg | Constants.DS4;
        }
        if(checkBox_DS5.isChecked()) {
            Log.d(TAG, "Check Box Channel 5 is checked");
            commandArg = commandArg | Constants.DS5;
        }
        if(checkBox_DS6.isChecked()) {
            Log.d(TAG, "Check Box Channel 6 is checked");
            commandArg = commandArg | Constants.DS6;
        }
        if(checkBox_DS7.isChecked()) {
            Log.d(TAG, "Check Box Channel 7 is checked");
            commandArg = commandArg | Constants.DS7;
        }
        if(checkBox_DS8.isChecked()) {
            Log.d(TAG, "Check Box Channel 8 is checked");
            commandArg = commandArg | Constants.DS8;
        }
        ret = (byte) commandArg;
        Log.d(TAG, "Command Arg is " + Integer.toBinaryString(ret));
        return ret;
    }

    /**
     * Creates command packet using the fields given and sends it to FPGA
     */
    private void commandPacketCreator(byte ... fields) {
        byte[] commandPacket;
        if(fields.length == 1){ // No operands
            commandPacket = new byte[1];
            commandPacket[0] = fields[0];
        }
        else {// With operands
            commandPacket = new byte[2];
            commandPacket[0] = fields[0];
            commandPacket[1] = fields[1];
        }
//        for (String field : fields){
//            commandPacket = commandPacket + field;
//        }

        // sending the created command packet to FPGA
        Log.d(TAG, "Command packet created is " + commandPacket);
        if(mBound) { // When BLE
            if(mBluetoothLeService.checkCharacteristic()) {
                if(GattLock == null)
                    Log.e(TAG, "Lock for Gatt operation is not initialized!");
                boolean writeDone = false;
                while(true) {
                    GattLock.lock();
                    try {
                        if(NoGattOperation) { // No Gatt operation is being processed at the moment
                            NoGattOperation = false;
                            mBluetoothLeService.writeCharacteristic(commandPacket);
                            writeDone = true;
                        }
                    } finally {
                        GattLock.unlock();
                        if(writeDone)
                            return;
                    }
                }
            }
            else{
                Log.d(TAG, "Characteristics are not set yet");
                Toast.makeText(this, R.string.failed_saving_data,
                        Toast.LENGTH_SHORT).show();
            }
        }
        else {  // When Classic Bluetooth
            btService.sendMessage(commandPacket);
        }
    }

    /**
     * Checks if the app has permission to write to device storage
     *
     * If the app does not has permission then the user will be prompted to grant permissions
     */
//    @TargetApi(23)
    public void verifyWriteStoragePermission(Activity activity) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Log.d(TAG, "Verifying Storage Permission");
            // Check if there is write permission
            int permission = ContextCompat.checkSelfPermission(activity, Manifest.permission.WRITE_EXTERNAL_STORAGE);

            if (permission != PackageManager.PERMISSION_GRANTED) {
                Log.d(TAG, "Permission not granted");
                //            setState(STATE_FORBIDDEN);
                // there is no permission so prompt the user
                ActivityCompat.requestPermissions(
                        activity,
                        new String[]{Manifest.permission.WRITE_EXTERNAL_STORAGE},
                        Constants.PERMISSION_WRITE_EXTERNAL_STORAGE
                );
            }
            else {
                Log.d(TAG, "Permission already granted");
                fileManager.createStorageDir();
                // Get file name and save
                showGetFileNameDialog();
            }
        }
        else {
            Log.d(TAG, "Android version is under 6.0 (No need for Runtime Permission");
            fileManager.createStorageDir();
            // Get file name and save
            showGetFileNameDialog();
        }
    }

    public static void verifyReadStoragePermission(Activity activity) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Log.d(TAG, "Verifying Storage Permission");
            // Check if there is write permission
            int permission = ContextCompat.checkSelfPermission(activity, Manifest.permission.READ_EXTERNAL_STORAGE);

            if (permission != PackageManager.PERMISSION_GRANTED) { // for now it shouldn't fall at here
                Log.d(TAG, "Permission not granted");
                //            setState(STATE_FORBIDDEN);
                // there is no permission so prompt the user
                ActivityCompat.requestPermissions(
                        activity,
                        new String[]{Manifest.permission.READ_EXTERNAL_STORAGE},
                        Constants.PERMISSION_READ_EXTERNAL_STORAGE
                );
            }
            Log.d(TAG, "Permission already granted");
        }
        else
            Log.d(TAG, "Android version is under 6.0 (No need for Runtime Permission");
    }

    /* For the case where no Bluetooth support */
    public void showNotSupportBtDialog() {
        // Create an instance of the dialog fragment and show it
        DialogFragment dialog = new NotSupportBtDialogFragment();
        dialog.show(getSupportFragmentManager(), "NotSupportBtDialogFragment" );
    }

    @Override
    public void onDialogOkClick (DialogFragment dialog){
        // User touched OK button -> terminate the app
        this.finishAffinity();
    }

    /* For the case where user refused to enable Bluetooth */
    public void showRepromptBtDialog() {
        DialogFragment dialog = new RepromptBtDialogFragment();
        dialog.show(getSupportFragmentManager(), "RepromptBtDialogFragment");
    }

    @Override
    public void onDialogConnectClick(DialogFragment dialog) {
        dialog.dismiss();
        btService.enableBluetooth();
    }

    @Override
    public void onDialogExitClick(DialogFragment dialog) {
        dialog.dismiss();
        this.finishAffinity();
    }

    /* For the case where the external storage is not available */
    public void showStorageNotWorkingDialog() {
        DialogFragment dialog = new StorageNotWorkingDialogFragment();
        dialog.show(getSupportFragmentManager(), "StorageNotWorkingDialogFragment");
    }

    /* For the case where user wants to save data */
    public void showGetFileNameDialog() {
        Log.d(TAG, "Getting file name");
        DialogFragment dialog = new GetFileNameDialogFragment();
        dialog.show(getSupportFragmentManager(), "GetFileNameDialogFragment");
    }

    @Override
    public void onDialogSaveClick(DialogFragment dialog) {
        // Getting file name user inserted
        Dialog dialogView = dialog.getDialog();
        EditText edittxt_FileName = (EditText) dialogView.findViewById(R.id.edittxt_FileName);
        String fileName = edittxt_FileName.getText().toString();

        // Checks if given file name already exists
        if(fileManager.checkFileExists(fileName)) {
            // flushes edit text where user enters file name
            edittxt_FileName.setText("");

            // warns user the file name is already being used
            TextView txt_WarnDuplicate = (TextView) dialogView.findViewById(R.id.txt_WarnDuplicate);

            txt_WarnDuplicate.setText(getString(R.string.txt_Warn_Duplicate, fileName));
            txt_WarnDuplicate.setVisibility(View.VISIBLE);
        }
        else { // file name is unique
            dialog.dismiss();

            if(!fileManager.saveFile(fileName, txt_DataReceived.getText().toString())) { // failed saving data
                Toast.makeText(this, R.string.failed_saving_data,
                        Toast.LENGTH_SHORT).show();
            }
            else {
                Log.d(TAG, "Successfully saved data");
            }
        }
    }
}




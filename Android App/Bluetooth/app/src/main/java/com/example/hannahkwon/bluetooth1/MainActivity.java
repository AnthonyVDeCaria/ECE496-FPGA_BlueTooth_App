package com.example.hannahkwon.bluetooth1;

import android.Manifest;
import android.app.Activity;
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
import android.os.CountDownTimer;
import android.os.Handler;
import android.os.IBinder;
import android.os.Message;
import android.support.v4.app.ActivityCompat;
import android.support.v4.app.DialogFragment;
import android.support.v4.content.ContextCompat;
import android.support.v4.content.LocalBroadcastManager;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.GridLayout;
import android.widget.TextView;
import android.widget.Toast;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.locks.ReentrantLock;

import static android.util.Log.d;
import static com.example.hannahkwon.bluetooth1.BluetoothLeService.ACTION_DATA_AVAILABLE;
import static com.example.hannahkwon.bluetooth1.BluetoothLeService.EXTRA_DATA;
import static com.example.hannahkwon.bluetooth1.DeviceListActivity.EXTRA_DEVICE_ADDRESS;
import static com.example.hannahkwon.bluetooth1.DeviceListActivity.EXTRA_DEVICE_NAME;

public class MainActivity extends AppCompatActivity
        implements RepromptBtDialogFragment.RepromptBtDialogListener, NotSupportBtDialogFragment.NotSupportBtDialogListener {

    private static final String TAG = "MainActivity";

    private android.support.v7.widget.Toolbar toolbar;

    // Bluetooth related
    private TextView txt_BtStatus;
    private TextView txt_DataReceived;

    private GridLayout gridLayout_Channels;
    private CheckBox checkBox_DS1;
    private CheckBox checkBox_DS2;
    private CheckBox checkBox_DS3;
    private CheckBox checkBox_DS4;
    private CheckBox checkBox_DS5;
    private CheckBox checkBox_DS6;
    private CheckBox checkBox_DS7;
    private CheckBox checkBox_DS8;

    private Runtimer runtimer;
    private boolean moreSecondInput = false;
    private EditText editTxt_Minute;
    private EditText editTxt_Second;

    private Button bt_Start;
    private Button bt_Cancel;

    private BluetoothService mBtService = null;

    private BluetoothLeService mBluetoothLeService;
    private boolean mBound = false;
    private String mDeviceAddress;
    private String mDeviceName;

    LocalBroadcastManager manager;

    public static FileManager mFileManager = null;

    private ProcessingThread mProcessingThread;
    private FileManager.LoggingThread mLoggingThread;

    //used for synchronizing view update at UI thread
    public static ReentrantLock ViewUpdateLock = null;
    public static ReentrantLock RuntimerWaiting;
    public static boolean runtimerWaiting = false;

//    private GraphFragment mGraph_1;
    private static GraphFragment_MPAndroidChart mGraph_1;
//    private GraphFragment_aChartEngine mGraph_1;

    private static GraphFragment_MPAndroidChart mGraph_2;
    private static GraphFragment_MPAndroidChart mGraph_3;
    private static GraphFragment_MPAndroidChart mGraph_4;
    private static GraphFragment_MPAndroidChart mGraph_5;
    private static GraphFragment_MPAndroidChart mGraph_6;
    private static GraphFragment_MPAndroidChart mGraph_7;
    private static GraphFragment_MPAndroidChart mGraph_8;

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
//                    String writeMessage = new String(readBuf, 0, msg.arg1);
//                    Log.d(TAG, "Data recevied " + writeMessage);
//                    txt_DataReceived.append(writeMessage);

                    mProcessingThread.add(true, readBuf);
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

    private static IntentFilter makeGattUpdateIntentFilter() {
        final IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction(BluetoothLeService.ACTION_GATT_CONNECTED);
        intentFilter.addAction(BluetoothLeService.ACTION_GATT_DISCONNECTED);
        intentFilter.addAction(BluetoothLeService.ACTION_GATT_SERVICES_DISCOVERED);
        intentFilter.addAction(ACTION_DATA_AVAILABLE);
        return intentFilter;
    }

    private void updateConnectionState(final String data) {
        Log.d(TAG, "Changing Bluetooth Status to " + data);
        txt_BtStatus.setText(data);
    }

    private void displayData(final String data) {

        if (data != null) {
            d(TAG, "Displaying data :" + data);
            txt_DataReceived.append(data);
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
                d(TAG, "Connected to a GATT server");
                updateConnectionState(getResources().getString(R.string.connected_to_device, mDeviceName));
            } else if (BluetoothLeService.ACTION_GATT_DISCONNECTED.equals(action)) {
                d(TAG, "Disconnected from a GATT server");
                // reset characteristic
                mBluetoothLeService.resetCharacteristic();
                updateConnectionState(getResources().getString(R.string.disoconnted));
            } else if (BluetoothLeService.ACTION_GATT_SERVICES_DISCOVERED.equals(action)) {
                //Show all the supported services and characteristics on the user interface.
                d(TAG, "Discovered GATT services");
                mBluetoothLeService.displayGattServices(mBluetoothLeService.getSupportedGattServices());
            }
            if (ACTION_DATA_AVAILABLE.equals(action)) {
                d(TAG, "Received data");
                byte [] data = intent.getByteArrayExtra(EXTRA_DATA);
                if (data != null && data.length > 0) {
//                    final StringBuilder stringBuilder = new StringBuilder(data.length);
//                    for(byte byteChar : data)
//                        stringBuilder.append(String.format("%02X ", byteChar));
//                    displayData(stringBuilder.toString());
                    mProcessingThread.add(false, data);
                }
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
            d(TAG, "Connecting to the device");
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

        d(TAG, "MainActivity is getting created");

        setContentView(R.layout.activity_main);

        toolbar = (Toolbar) findViewById(R.id.toolBar);
        setSupportActionBar(toolbar);

        txt_BtStatus = (TextView) findViewById(R.id.txt_BtStatus);
//        txt_DataReceived = (TextView) findViewById(R.id.txt_DataReceived);

        gridLayout_Channels = (GridLayout) findViewById(R.id.gridLayout_Channels);
        checkBox_DS1 = (CheckBox) findViewById(R.id.checkBox_DS1);
        checkBox_DS2 = (CheckBox) findViewById(R.id.checkBox_DS2);
        checkBox_DS3 = (CheckBox) findViewById(R.id.checkBox_DS3);
        checkBox_DS4 = (CheckBox) findViewById(R.id.checkBox_DS4);
        checkBox_DS5 = (CheckBox) findViewById(R.id.checkBox_DS5);
        checkBox_DS6 = (CheckBox) findViewById(R.id.checkBox_DS6);
        checkBox_DS7 = (CheckBox) findViewById(R.id.checkBox_DS7);
        checkBox_DS8 = (CheckBox) findViewById(R.id.checkBox_DS8);

        editTxt_Minute = (EditText) findViewById(R.id.editTxt_Minute);
        editTxt_Second = (EditText) findViewById(R.id.editTxt_Second);
        bt_Start = (Button) findViewById(R.id.btn_Start);
        bt_Cancel = (Button) findViewById(R.id.btn_Cancel);

        ViewUpdateLock = new ReentrantLock();
        RuntimerWaiting = new ReentrantLock();

        mGraph_1 = (GraphFragment_MPAndroidChart) getSupportFragmentManager().findFragmentById(R.id.graph_1);
//        mGraph_1 = (GraphFragment_aChartEngine) getSupportFragmentManager().findFragmentById(R.id.graph_1);

        mGraph_2 = (GraphFragment_MPAndroidChart) getSupportFragmentManager().findFragmentById(R.id.graph_2);
        mGraph_3 = (GraphFragment_MPAndroidChart) getSupportFragmentManager().findFragmentById(R.id.graph_3);
        mGraph_4 = (GraphFragment_MPAndroidChart) getSupportFragmentManager().findFragmentById(R.id.graph_4);
        mGraph_5 = (GraphFragment_MPAndroidChart) getSupportFragmentManager().findFragmentById(R.id.graph_5);
        mGraph_6 = (GraphFragment_MPAndroidChart) getSupportFragmentManager().findFragmentById(R.id.graph_6);
        mGraph_7 = (GraphFragment_MPAndroidChart) getSupportFragmentManager().findFragmentById(R.id.graph_7);
        mGraph_8 = (GraphFragment_MPAndroidChart) getSupportFragmentManager().findFragmentById(R.id.graph_8);

        // TODO scale the gridlayout

        if (mBtService == null) {
            mBtService = new BluetoothService(this, mHandler);
        }

        if (mBtService.getDeviceState()) {
            // the device supports Bluetooth
            mBtService.enableBluetooth();
        }
        else {
            // sets up a dialogue saying the device does not support Bluetooth and kill the app
            showNotSupportBtDialog();
        }

        if (mFileManager == null) {
            mFileManager = new FileManager(this);
        }

        // to enable better runtimer input interaction
        RuntimerSelector();

        bt_Start.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                // Sends Start command using the user's selection upon the channels
//                String commandArg;
//                commandArg = new String(setCommandArg());
                // encoding command arg into UTF-8
//                commandArg = new String(setCommandArg(), 0, 1);
//                Log.d(TAG, "Command arg is encoded into " + commandArg);
                d(TAG, "Pressed Start");

                int minute = Integer.parseInt(editTxt_Minute.getText().toString());
                int second = Integer.parseInt(editTxt_Second.getText().toString());
                long milliseconds = (minute* 60 + second) * 1000;
                d(TAG, "User set the timer with " + milliseconds + " ms");
                if (milliseconds <= 0) {
                    editTxt_Second.setError("0 seconds is not permitted!");
                }

                verifyWriteStoragePermission(MainActivity.this);

                d(TAG, "Setting up timer with " + milliseconds + " ms");
                runtimer = new Runtimer(milliseconds);

                int minCapacity = (minute * 60 + second) * 8;

                mGraph_1.start(minCapacity);
                mGraph_2.start(minCapacity);
                mGraph_3.start(minCapacity);
                mGraph_4.start(minCapacity);
                mGraph_5.start(minCapacity);
                mGraph_6.start(minCapacity);
                mGraph_7.start(minCapacity);
                mGraph_8.start(minCapacity);

                runtimer.start();
//                while(true) {
//                    if (mGraph_1.start_done & mGraph_2.start_done & mGraph_3.start_done & mGraph_4.start_done
//                            & mGraph_5.start_done & mGraph_6.start_done & mGraph_7.start_done & mGraph_8.start_done) {
//                        runtimer.start();
//                        break;
//                    }
//                }
            }
        });
        // Also used for clearing up the screen after opening a file
        bt_Cancel.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                d(TAG, "Pressed Cancel");
                // Wiping out log file
                if(mLoggingThread != null)    // in case user opened file
                    mLoggingThread.finishLog();

                commandPacketCreator((byte) Constants.CANCEL, (byte) Constants.CANCEL);

                // Wipes out the graphs
                mGraph_1.clear();
                mGraph_2.clear();
                mGraph_3.clear();
                mGraph_4.clear();
                mGraph_5.clear();
                mGraph_6.clear();
                mGraph_7.clear();
                mGraph_8.clear();

                if(runtimer != null)    // in case user opened file
                    runtimer.cancel();
                runtimerWaiting = false;
            }
        });

        manager = LocalBroadcastManager.getInstance(this);

        // Used to capture App abruptly terminating
        final Thread.UncaughtExceptionHandler oldHandler =
                Thread.getDefaultUncaughtExceptionHandler();

        Thread.setDefaultUncaughtExceptionHandler(
                new Thread.UncaughtExceptionHandler() {
                    @Override
                    public void uncaughtException(
                            Thread paramThread,
                            Throwable paramThrowable
                    ) {
                        //Do your own error handling here
                        Log.e(TAG, "Something went wrong!\nThe App is going to crash!");
                        if(mLoggingThread != null)
                            mLoggingThread.finishLog();

                        if (oldHandler != null)
                            oldHandler.uncaughtException(
                                    paramThread,
                                    paramThrowable
                            ); //Delegates to Android's error handling
                        else
                            System.exit(1); //Prevents the service/app from freezing
                    }
                });
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case R.id.action_bluetooth_connect:
                mBtService.enableBluetooth();
                return true;
            //TODO start from here
            case R.id.action_open_file:
                verifyReadStoragePermission(this);
                return true;
            default:
                // If we got here, the user's action was not recognized.
                // Invoke the superclass to handle it.
                return super.onOptionsItemSelected(item);
        }
    }

    @Override
    protected void onStart(){
        super.onStart();

        d(TAG, "MainActivity is getting started");
    }

    @Override
    protected void onResume() {
        super.onResume();
        manager.registerReceiver(mGattUpdateReceiver, makeGattUpdateIntentFilter());
        if (mBluetoothLeService != null) {
            final boolean result = mBluetoothLeService.connect(mDeviceAddress);
            d(TAG, "Connect request result=" + result);
        }
    }

    @Override
    protected void onPause() {
        super.onPause();
        manager.unregisterReceiver(mGattUpdateReceiver);
    }

    @Override
    protected void onStop(){
        super.onStop();

        d(TAG, "MainActivity is getting stopped");
        // unregister broadcast receiver
//        unregisterReceiver(mReceiver);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        d(TAG, "MainActivity is getting destroyed");

        if (mBtService != null) {
            // Stops ConnectThread and ConnectedThread
            mBtService.stop();
        }
        if(mBound) {
            unbindService(mServiceConnection);
            mBluetoothLeService = null;
            mBound = false;
        }
        if(mLoggingThread != null)
            mLoggingThread.finishLog();
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
                    d(TAG,"Bluetooth is enabled");
                    txt_BtStatus.setText(R.string.bluetooth_on);

                    // Scan for devices
                    mBtService.scanDevice();
                }
                else{ // user pressed "No"
                    d(TAG,"Bluetooth is not enabled");

                    // has to re-prompt user for the bluetooth (creates a dialogue)
                    showRepromptBtDialog();
                }
                break;
            // When Device ListActivity returns with a device to connect
            case Constants.REQUEST_CONNECT_DEVICE:
                if (resultCode == Activity.RESULT_OK) {
                    int btType = -1;
                    btType = data.getExtras().getInt(DeviceListActivity.EXTRA_DEVICE_TYPE);

                    // Device supports only BLE
                    if (btType == BluetoothDevice.DEVICE_TYPE_LE) {
                        d(TAG, "Device selected supports BLE only");
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
                        mBtService.getDeviceInfo(data);
                    }
                    startProcessingAndLogging();
                }
                break;
            case Constants.REQUEST_OPEN_FILE:
                if (resultCode == Activity.RESULT_OK){
                    //TODO start reading file from here
                    Log.d(TAG, "User selected a file to open");
                    String fileName = data.getStringExtra(OpenFileActivity.EXTRA_FILE_NAME);
                    mFileManager.readFile(fileName);
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
                    d(TAG, "User granted the permission");
                    if(!mFileManager.createStorageDir()) {   // failed creating parent directory
                        Toast.makeText(this, R.string.failed_creating_parent_directory,
                                Toast.LENGTH_SHORT).show();
                    }
                    else {
                        commandPacketCreator((byte) Constants.START, setCommandArg());
                    }
                }
                else {
                    d(TAG, "Permission is denied");
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
                    d(TAG, "User granted the permission");
                    Intent intent = new Intent(this, OpenFileActivity.class);
                    this.startActivityForResult(intent, Constants.REQUEST_OPEN_FILE);
                }
                else { // for now it shouldn't fall here
                    d(TAG, "Permission is denied");
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
            d(TAG, "Check Box Channel 1 is checked");
            commandArg = commandArg | Constants.DS1;
        }
        if(checkBox_DS2.isChecked()) {
            d(TAG, "Check Box Channel 2 is checked");
            commandArg = commandArg | Constants.DS2;
        }
        if(checkBox_DS3.isChecked()) {
            d(TAG, "Check Box Channel 3 is checked");
            commandArg = commandArg | Constants.DS3;
        }
        if(checkBox_DS4.isChecked()) {
            d(TAG, "Check Box Channel 4 is checked");
            commandArg = commandArg | Constants.DS4;
        }
        if(checkBox_DS5.isChecked()) {
            d(TAG, "Check Box Channel 5 is checked");
            commandArg = commandArg | Constants.DS5;
        }
        if(checkBox_DS6.isChecked()) {
            d(TAG, "Check Box Channel 6 is checked");
            commandArg = commandArg | Constants.DS6;
        }
        if(checkBox_DS7.isChecked()) {
            d(TAG, "Check Box Channel 7 is checked");
            commandArg = commandArg | Constants.DS7;
        }
        if(checkBox_DS8.isChecked()) {
            d(TAG, "Check Box Channel 8 is checked");
            commandArg = commandArg | Constants.DS8;
        }
        ret = (byte) commandArg;
        d(TAG, "Command Arg is " + Integer.toBinaryString(ret));
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
        d(TAG, "Command packet created is " + commandPacket);
        if(mBound) { // When BLE
            if(mBluetoothLeService.checkCharacteristic()) {
                mBluetoothLeService.write(commandPacket);
            }
            else{
                d(TAG, "Characteristics are not set yet");
                Toast.makeText(this, "Not connected yet",
                        Toast.LENGTH_SHORT).show();
            }
        }
        else {  // When Classic Bluetooth
            mBtService.sendMessage(commandPacket);
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
            d(TAG, "Verifying Write Storage Permission");
            // Check if there is write permission
            int permission = ContextCompat.checkSelfPermission(activity, Manifest.permission.WRITE_EXTERNAL_STORAGE);

            if (permission != PackageManager.PERMISSION_GRANTED) {
                d(TAG, "Write storage permission not granted");
                //            setState(STATE_FORBIDDEN);
                // there is no permission so prompt the user
                ActivityCompat.requestPermissions(
                        activity,
                        new String[]{Manifest.permission.WRITE_EXTERNAL_STORAGE},
                        Constants.PERMISSION_WRITE_EXTERNAL_STORAGE
                );
            }
            else {
                d(TAG, "Write storage permission already granted");
                mFileManager.createStorageDir();

                // starting to log data
                mLoggingThread.startLog();

                commandPacketCreator((byte) Constants.START, setCommandArg());
            }
        }
        else {
            d(TAG, "Android version is under 6.0 (No need for Runtime Permission");
            mFileManager.createStorageDir();

            // starting to log data
            mLoggingThread.startLog();

            commandPacketCreator((byte) Constants.START, setCommandArg());
        }
    }

    public static void verifyReadStoragePermission(Activity activity) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            d(TAG, "Verifying Read Storage Permission");
            // Check if there is write permission
            int permission = ContextCompat.checkSelfPermission(activity, Manifest.permission.READ_EXTERNAL_STORAGE);

            if (permission != PackageManager.PERMISSION_GRANTED) {
                d(TAG, "Read storage permission not granted");
                //            setState(STATE_FORBIDDEN);
                // there is no permission so prompt the user
                ActivityCompat.requestPermissions(
                        activity,
                        new String[]{Manifest.permission.READ_EXTERNAL_STORAGE},
                        Constants.PERMISSION_READ_EXTERNAL_STORAGE
                );
            }
            else {
                d(TAG, "Read storage permission already granted");

                Intent intent = new Intent(activity, OpenFileActivity.class);
                activity.startActivityForResult(intent, Constants.REQUEST_OPEN_FILE);
            }
        }
        else {
            d(TAG, "Android version is under 6.0 (No need for Runtime Permission");

            Intent intent = new Intent(activity, OpenFileActivity.class);
            activity.startActivityForResult(intent, Constants.REQUEST_OPEN_FILE);
        }
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
        d(TAG, "Showing Bluetooth Reprompt Dialog");
        DialogFragment dialog = new RepromptBtDialogFragment();
        dialog.show(getSupportFragmentManager(), "RepromptBtDialogFragment");
    }

    @Override
    public void onDialogConnectClick(DialogFragment dialog) {
        dialog.dismiss();
        mBtService.enableBluetooth();
    }

    @Override
    public void onDialogIllDoItLaterClick(DialogFragment dialog) {
        dialog.dismiss();
    }

    /* For the case where the external storage is not available */
    public void showStorageNotWorkingDialog() {
        DialogFragment dialog = new StorageNotWorkingDialogFragment();
        dialog.show(getSupportFragmentManager(), "StorageNotWorkingDialogFragment");
    }

    private void RuntimerSelector() {
        // to get the runtime
        editTxt_Minute.addTextChangedListener(new TextWatcher() {
            boolean pushed = false;
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }
            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
            }
            @Override
            public void afterTextChanged(Editable s) {  // also get called when numbers are deleted
//                Log.d(TAG, "After text changed");
                String value = s.toString();
                int length = value.length();
                if (length > 0) {
                    if(!pushed) {
//                        Log.d(TAG, "May need to push");
                        if(length > 2) {
                            if(Integer.parseInt(value.substring(0, 1 + 1)) == 59) {
//                                Log.d(TAG, "Was already at 59 previously");
                                editTxt_Minute.setText("0" + value.charAt(2));
                                editTxt_Minute.setSelection(2);
                                return;
                            }
//                            Log.d(TAG, "Pushing in " + value + " to the left");
                            String current = value.substring(1, 2 + 1);
//                            Log.d(TAG, "Pushed value should be " + current);
                            pushed = true;
                            editTxt_Minute.setText(current);
                            editTxt_Minute.setSelection(2);
                            return;
                        }
                    }
                    int second = Integer.parseInt(value);
                    if (second > 59) {
//                        Log.d(TAG, "User entered invalid second! " + second);
                        editTxt_Minute.setText("59");
                    }
                    pushed = false;
//                    Log.d(TAG, "pushed is changed back to false");
                }
            }
        });
        editTxt_Second.addTextChangedListener(new TextWatcher() {
            boolean pushed = false;
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }
            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
            }
            @Override
            public void afterTextChanged(Editable s) {  // also get called when numbers are deleted
//                Log.d(TAG, "After text changed");
                String value = s.toString();
                int length = value.length();
                if (length > 0) {
                    if(!pushed) {
//                        Log.d(TAG, "May need to push");
                        if(length > 2) {
                            if(Integer.parseInt(value.substring(0, 1 + 1)) == 59) {
//                                Log.d(TAG, "Was already at 59 previously");
                                editTxt_Second.setText("0" + value.charAt(2));
                                editTxt_Second.setSelection(2);
                                return;
                            }
//                            Log.d(TAG, "Pushing in " + value + " to the left");
                            String current = value.substring(1, 2 + 1);
//                            Log.d(TAG, "Pushed value should be " + current);
                            pushed = true;
                            editTxt_Second.setText(current);
                            editTxt_Second.setSelection(2);
                            return;
                        }
                    }
                    int second = Integer.parseInt(value);
                    if (second > 59) {
//                        Log.d(TAG, "User entered invalid second! " + second);
                        editTxt_Second.setText("59");
                    }
                    pushed = false;
//                    Log.d(TAG, "pushed is changed back to false");
                }
            }
        });
    }

    private class Runtimer extends CountDownTimer {
        int timeLeft;
        int timeToDisplay;
        private Runtimer(long millisInFuture) {
            super(millisInFuture, 100);    // Using smaller than 1 second to get frequent updates
            timeLeft = (int) millisInFuture / 1000;
            d(TAG, "runtimer start with " + timeLeft + " s");
        }

        @Override
        public void onTick(long millisUntilFinished) {
            RuntimerWaiting.lock();
            try {
                runtimerWaiting = true;
            } finally {
                RuntimerWaiting.unlock();
            }
            ViewUpdateLock.lock();
            RuntimerWaiting.lock();
            try {
                int timeToDisplay = Math.round((float) millisUntilFinished / 1000.0f);
                if (timeToDisplay != timeLeft) {
                    timeLeft = timeToDisplay;
                    String minute = String.format("%02d", TimeUnit.MILLISECONDS.toMinutes(millisUntilFinished));
                    String second = String.format("%02d", TimeUnit.MILLISECONDS.toSeconds(millisUntilFinished) - TimeUnit.MINUTES.toSeconds(TimeUnit.MILLISECONDS.toMinutes(millisUntilFinished)));
                    editTxt_Minute.setText(minute);
                    editTxt_Second.setText(second);
                    d(TAG, "Changed Minute to " + minute + " and Second to " + second);

                    runtimerWaiting = false;
                }
            }  finally {
                RuntimerWaiting.unlock();
                ViewUpdateLock.unlock();
            }
        }

        @Override
        public void onFinish() {
            RuntimerWaiting.lock();
            try {
                runtimerWaiting = true;
            } finally {
                RuntimerWaiting.unlock();
            }
            ViewUpdateLock.lock();
            RuntimerWaiting.lock();
            try {
                editTxt_Minute.setText("00");
                editTxt_Second.setText("00");

                d(TAG, "Finished timer");
                runtimerWaiting = false;
            } finally {
                ViewUpdateLock.unlock();
                RuntimerWaiting.unlock();
            }

            // notify FPGA to stop sending data
            commandPacketCreator((byte) Constants.CANCEL, (byte) Constants.CANCEL);

            // saving data into file
            Calendar c = Calendar.getInstance();
            SimpleDateFormat dateformat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            String datetime = dateformat.format(c.getTime());
            d(TAG, "Using following date time for file name " + datetime);

            mGraph_1.saveAllData(datetime);
            mGraph_2.saveAllData(datetime);
            mGraph_3.saveAllData(datetime);
            mGraph_4.saveAllData(datetime);
            mGraph_5.saveAllData(datetime);
            mGraph_6.saveAllData(datetime);
            mGraph_7.saveAllData(datetime);
            mGraph_8.saveAllData(datetime);
        }
    }

    public synchronized void startProcessingAndLogging() {
        d(TAG, "Start Processing");

        // Start the thread to process packets received
        mProcessingThread = new ProcessingThread();
        mProcessingThread.start();

        d(TAG, "Start Logging");

        // Start the thread to log processed data
        mLoggingThread = mFileManager.new LoggingThread();
        mLoggingThread.start();
    }

    public static void clearGraphs(int datastream) {
        switch (datastream) {
            case 1:
                mGraph_1.clear();
                break;
            case 2:
                mGraph_2.clear();
                break;
            case 3:
                mGraph_3.clear();
                break;
            case 4:
                mGraph_4.clear();
                break;
            case 5:
                mGraph_5.clear();
                break;
            case 6:
                mGraph_6.clear();
                break;
            case 7:
                mGraph_7.clear();
                break;
            case 8:
                mGraph_8.clear();
                break;
        }
    }

    public static void addFromFile(int datastream, float[] data) {
        switch (datastream) {
            case 1:
                mGraph_1.addDataFromFile(data);
                break;
            case 2:
                mGraph_2.addDataFromFile(data);
                break;
            case 3:
                mGraph_3.addDataFromFile(data);
                break;
            case 4:
                mGraph_4.addDataFromFile(data);
                break;
            case 5:
                mGraph_5.addDataFromFile(data);
                break;
            case 6:
                mGraph_6.addDataFromFile(data);
                break;
            case 7:
                mGraph_7.addDataFromFile(data);
                break;
            case 8:
                mGraph_8.addDataFromFile(data);
                break;
        }
    }

    public static void doneAddingFromFile(int datastream) {
        switch (datastream) {
            case 1:
                mGraph_1.doneAddingFromFile();
                break;
            case 2:
                mGraph_2.doneAddingFromFile();
                break;
            case 3:
                mGraph_3.doneAddingFromFile();
                break;
            case 4:
                mGraph_4.doneAddingFromFile();
                break;
            case 5:
                mGraph_5.doneAddingFromFile();
                break;
            case 6:
                mGraph_6.doneAddingFromFile();
                break;
            case 7:
                mGraph_7.doneAddingFromFile();
                break;
            case 8:
                mGraph_8.doneAddingFromFile();
                break;
        }
    }

    /*
    * This is the thread where it sends off the packets to the correct Fragments for graph display
    * It also do auto logging when 5th data is received.
    */
    private class ProcessingThread extends Thread {
        LinkedBlockingQueue<byte []> mmFIFOQueue = new LinkedBlockingQueue<byte []>();
        private float [] mmRetrievedData = null;
        private byte [] mmTempData = null;
        private int datastream = -1;
        private boolean mmTestPurpose = false; // for testing graph (remove it later)

        private int count = 0;  // used to count number of packets for logging
        private byte[] mmDataToLog = new byte[201];

        public ProcessingThread() {
            d(TAG, "Creating ProcessingThread");
        }

        public void run() {
            Log.i(TAG, "Beginning mProcessingThread");
            while (true) {
                try {
                    mmTempData = mmFIFOQueue.take();
                } catch (Exception e) {
                    Log.e(TAG, "Failed taking out element from the FIFO queue", e);
                }
//                    Log.d(TAG, "Processing data: " + mmTempData);

//                    Log.d(TAG, "Retrieving data from packaged data");
                if(!mmTestPurpose) {
//                        mmRetrievedData = retrieveData(mmTempData);
                    mmRetrievedData = new float[3];
                    mmRetrievedData[2] = mmTempData[11] & 0xff;
                    mmRetrievedData[1] = mmTempData[12] & 0xff;
                    mmRetrievedData[0] = mmTempData[13] & 0xff;
                }
                else {
                    mmRetrievedData = new float[3];
                    mmRetrievedData[0] = mmTempData[1];
                    mmRetrievedData[1] = mmTempData[2];
                    mmRetrievedData[2] = mmTempData[3];
                }

                for(int i = 0; i < 4; i++) {
                    if(i == 0)
                        mmDataToLog[count * 4 + i] = (byte) mmTempData[0];
                    else
                        mmDataToLog[count * 4 + i] = (byte) mmRetrievedData[i - 1];
                }

                count++;
                if(count == 50) {
                    mmDataToLog[200] = (byte) 27;
                    mLoggingThread.log(mmDataToLog);
                    mmDataToLog = new byte[201];
                    count = 0;
                }

                //TODO enable this
                datastream = mmTempData[0] & 0b00000111;
                //TODO uncomment below
//                if(datastream == 0){    // display only DS1
//                    Log.d(TAG, "Packaged data corresponds to datastream 1");
//                    // for graph
//                    mGraph_1.addData(mmRetrievedData);
//                }
                //TODO delete below
                if(mmTempData[0] == 49){    // display only DS1
                    d(TAG, "Packaged data corresponds to datastream 1");
                    // for graph
                    mGraph_1.addData(mmRetrievedData);
                }
//                else if(datastream == 1) {
////                        Log.d(TAG, "Packaged data corresponds to datastream 2");
//                    // for graph
//                    mGraph_2.addData(mmRetrievedData);
//                }
//                else if(datastream == 2) {
////                        Log.d(TAG, "Packaged data corresponds to datastream 3");
//                    // for graph
//                    mGraph_3.addData(mmRetrievedData);
//                }
//                else if(datastream == 3) {
////                        Log.d(TAG, "Packaged data corresponds to datastream 4");
//                    // for graph
//                    mGraph_4.addData(mmRetrievedData);
//                }
//                else if(datastream == 4) {
////                        Log.d(TAG, "Packaged data corresponds to datastream 5");
//                    // for graph
//                    mGraph_5.addData(mmRetrievedData);
//                }
//                else if(datastream == 5) {
////                        Log.d(TAG, "Packaged data corresponds to datastream 6");
//                    // for graph
//                    mGraph_6.addData(mmRetrievedData);
//                }
//                else if(datastream == 6) {
////                        Log.d(TAG, "Packaged data corresponds to datastream 7");
//                    // for graph
//                    mGraph_7.addData(mmRetrievedData);
//                }
//                else if(datastream == 7) {
////                        Log.d(TAG, "Packaged data corresponds to datastream 8");
//                    // for graph
//                    mGraph_8.addData(mmRetrievedData);
//                }
                else {
                    Log.e(TAG, "Received data not corresponding to any datastreams");
                }
            }
        }

        public synchronized void add (boolean testPurpose, byte[] data) {
            mmTestPurpose = testPurpose;
            Log.i(TAG, "Adding into Processing FIFO queue " + data);
            try {
                mmFIFOQueue.put(data);
            } catch (Exception e) {
                Log.e(TAG, "Failed adding into Processing FIFO queue", e);
            }
        }
    }
}




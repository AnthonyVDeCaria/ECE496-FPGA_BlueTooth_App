package com.example.hannahkwon.bluetooth1;

import android.Manifest;
import android.app.Activity;
import android.app.Dialog;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.support.v4.app.ActivityCompat;
import android.support.v4.app.DialogFragment;
import android.support.v4.app.FragmentActivity;
import android.support.v4.content.ContextCompat;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.Switch;
import android.widget.TextView;
import android.widget.Toast;

public class MainActivity extends FragmentActivity
        implements RepromptBtDialogFragment.RepromptBtDialogListener, NotSupportBtDialogFragment.NotSupportBtDialogListener, GetFileNameDialogFragment.GetFileNameDialogListener{

    private static final String TAG = "MainActivity";

    // Bluetooth related
    private TextView txt_BtStatus;
    private TextView txt_DataReceived;

    private Button bt_Save;

    private Switch switch_DS1Ctrl;
    private Switch switch_DS2Ctrl;
    private Switch switch_DS3Ctrl;
    private Switch switch_DS4Ctrl;
    private Switch switch_DS5Ctrl;
    private Switch switch_DS6Ctrl;
    private Switch switch_DS7Ctrl;
    private Switch switch_DS8Ctrl;;

    private BluetoothService btService = null;
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

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        Log.d(TAG, "MainActivity is getting created");

        setContentView(R.layout.activity_main);

        txt_BtStatus = (TextView) findViewById(R.id.txt_BtStatus);
        txt_DataReceived = (TextView) findViewById(R.id.txt_DataReceived);

        switch_DS1Ctrl = (Switch) findViewById(R.id.switch_DS1Ctrl);
        switch_DS2Ctrl = (Switch) findViewById(R.id.switch_DS2Ctrl);
        switch_DS3Ctrl = (Switch) findViewById(R.id.switch_DS3Ctrl);
        switch_DS4Ctrl = (Switch) findViewById(R.id.switch_DS4Ctrl);
        switch_DS5Ctrl = (Switch) findViewById(R.id.switch_DS5Ctrl);
        switch_DS6Ctrl = (Switch) findViewById(R.id.switch_DS6Ctrl);
        switch_DS7Ctrl = (Switch) findViewById(R.id.switch_DS7Ctrl);
        switch_DS8Ctrl = (Switch) findViewById(R.id.switch_DS8Ctrl);
        bt_Save = (Button) findViewById(R.id.btn_Save);

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

        // Sets
        setSwitchesListener(switch_DS1Ctrl, switch_DS2Ctrl, switch_DS3Ctrl, switch_DS4Ctrl, switch_DS5Ctrl,
                switch_DS6Ctrl, switch_DS7Ctrl, switch_DS8Ctrl);

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
    }

    @Override
    protected void onStart(){
        super.onStart();

        Log.d(TAG, "MainActivity is getting started");
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
                    btService.getDeviceInfo(data);
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

    private void setSwitchesListener(Switch sw1, Switch sw2, Switch sw3, Switch sw4, Switch sw5, Switch sw6, Switch sw7, Switch sw8) {
        sw1.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (isChecked) {
                    // Turned on Datastream1
                    Log.d(TAG, "Datastream1 is turned on");
                    commandPacketCreator(Constants.ON_DS, Constants.DS_1);
                } else {
                    // Turned off Datastream1
                    Log.d(TAG, "Datastream1 is turned off");
                    commandPacketCreator(Constants.OFF_DS, Constants.DS_1);
                }
            }
        });
        sw2.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (isChecked) {
                    // Turned on Datastream2
                    Log.d(TAG, "Datastream2 is turned on");
                    commandPacketCreator(Constants.ON_DS, Constants.DS_2);
                } else {
                    // Turned off Datastream2
                    Log.d(TAG, "Datastream2 is turned off");
                    commandPacketCreator(Constants.OFF_DS, Constants.DS_2);
                }
            }
        });
        sw3.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (isChecked) {
                    // Turned on Datastream3
                    Log.d(TAG, "Datastream3 is turned on");
                    commandPacketCreator(Constants.ON_DS, Constants.DS_3);
                } else {
                    // Turned off Datastream3
                    Log.d(TAG, "Datastream3 is turned off");
                    commandPacketCreator(Constants.OFF_DS, Constants.DS_3);
                }
            }
        });
        sw4.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (isChecked) {
                    // Turned on Datastream4
                    Log.d(TAG, "Datastream4 is turned on");
                    commandPacketCreator(Constants.ON_DS, Constants.DS_4);
                } else {
                    // Turned off Datastream4
                    Log.d(TAG, "Datastream4 is turned off");
                    commandPacketCreator(Constants.OFF_DS, Constants.DS_4);
                }
            }
        });
        sw5.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (isChecked) {
                    // Turned on Datastream5
                    Log.d(TAG, "Datastream5 is turned on");
                    commandPacketCreator(Constants.ON_DS, Constants.DS_5);
                } else {
                    // Turned off Datastream5
                    Log.d(TAG, "Datastream5 is turned off");
                    commandPacketCreator(Constants.OFF_DS, Constants.DS_5);
                }
            }
        });
        sw6.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (isChecked) {
                    // Turned on Datastream6
                    Log.d(TAG, "Datastream6 is turned on");
                    commandPacketCreator(Constants.ON_DS, Constants.DS_6);
                } else {
                    // Turned off Datastream6
                    Log.d(TAG, "Datastream6 is turned off");
                    commandPacketCreator(Constants.OFF_DS, Constants.DS_6);
                }
            }
        });
        sw7.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (isChecked) {
                    // Turned on Datastream7
                    Log.d(TAG, "Datastream7 is turned on");
                    commandPacketCreator(Constants.ON_DS, Constants.DS_7);
                } else {
                    // Turned off Datastream7
                    Log.d(TAG, "Datastream7 is turned off");
                    commandPacketCreator(Constants.OFF_DS, Constants.DS_7);
                }
            }
        });
        sw8.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (isChecked) {
                    // Turned on Datastream8
                    Log.d(TAG, "Datastream8 is turned on");
                    commandPacketCreator(Constants.ON_DS, Constants.DS_8);
                } else {
                    // Turned off Datastream8
                    Log.d(TAG, "Datastream8 is turned off");
                    commandPacketCreator(Constants.OFF_DS, Constants.DS_8);
                }
            }
        });
    }

    /**
     * Creates command packet using the fields given and sends it to FPGA
     */
    private void commandPacketCreator(String ... fields) {
        String commandPacket = Constants.COMMAND_HEADER;
//         commandHeader = String.valueOf(Constants.COMMAND_HEADER);
//        if(fields.length == 1){ // No operands
//            commandPacket = new byte[2];
//            commandPacket[0] = commandHeader;
//            commandPacket[1] = (new Integer(fields[0])).byteValue();
//        }
//        else {// With opreands
//            commandPacket = new byte[3];
//            commandPacket[0] = commandHeader;
//            commandPacket[1] = (new Integer(fields[0])).byteValue();
//            commandPacket[2] = (new Integer(fields[1])).byteValue();
//        }
        for (String field : fields){
            commandPacket = commandPacket + field;
        }

        // sending the created command packet to FPGA
        Log.d(TAG, "Command packet created is " + commandPacket);
        btService.sendMessage(commandPacket);
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




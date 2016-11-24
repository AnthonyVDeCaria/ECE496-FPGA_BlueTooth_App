package com.example.hannahkwon.bluetooth1;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.support.v4.app.DialogFragment;
import android.support.v4.app.FragmentActivity;
import android.util.Log;
import android.widget.TextView;
import android.widget.Toast;

public class MainActivity extends FragmentActivity
        implements RepromptBtDialogFragment.RepromptBtDialogListener, NotSupportBtDialogFragment.NotSupportBtDialogListener{

    private static final String TAG = "MainActivity";

    private TextView txt_BtStatus;
    private TextView txt_DataReceived;
    private BluetoothService btService = null;

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
        setContentView(R.layout.activity_main);

        txt_BtStatus = (TextView) findViewById(R.id.txt_BtStatus);
        txt_DataReceived = (TextView) findViewById(R.id.txt_DataReceived);

        if(btService == null){
            btService = new BluetoothService(this, mHandler);
        }
    }

    @Override
    protected void onStart(){
        super.onStart();

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
    }

    @Override
    protected void onStop(){
        super.onStop();

        // unregister broadcast receiver
//        unregisterReceiver(mReceiver);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();

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
                    //TODO
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
}




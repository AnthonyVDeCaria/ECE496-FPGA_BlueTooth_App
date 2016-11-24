package com.example.hannahkwon.bluetooth1;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.os.Bundle;
import android.support.v4.app.DialogFragment;
import android.util.Log;

/**
 * Created by HannahKwon on 2016-09-22.
 */
public class RepromptBtDialogFragment extends DialogFragment {

    private static final String TAG = "RepromptBtDialog";

    public interface RepromptBtDialogListener {
        void onDialogConnectClick(DialogFragment dialog);
        void onDialogExitClick(DialogFragment dialog);
    }

    // Use this instance of the interface to deliver action events to host activity
    RepromptBtDialogListener mListener;

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
        // Verify that the host activity(MainActivity) implements callback
        if (context instanceof RepromptBtDialogListener) {
            Log.d(TAG,"MainActivity implemented RepromptBtDialogListener");
            mListener = (RepromptBtDialogListener) context;
        }
        else{
            throw new RuntimeException(context.toString()
                    + "must implement RepromptBtDialogListener");
        }
    }

    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
        builder.setMessage(R.string.dialog_need_bluetooth)
                .setPositiveButton(R.string.btn_Connect, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        // Send the positive button event back to the host activity
                        Log.d(TAG,"Send the Connect button event back to the host activity");
                        mListener.onDialogConnectClick(RepromptBtDialogFragment.this);
                    }
                })
                .setNegativeButton(R.string.btn_Exit, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        Log.d(TAG,"Send the Exit button event back to the host activity");
                        mListener.onDialogExitClick(RepromptBtDialogFragment.this);
                    }
                });
        return builder.create();
    }
}
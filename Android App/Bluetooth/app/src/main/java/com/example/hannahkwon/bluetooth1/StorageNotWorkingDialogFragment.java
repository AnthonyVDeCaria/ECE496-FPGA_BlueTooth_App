package com.example.hannahkwon.bluetooth1;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.DialogInterface;
import android.os.Bundle;
import android.support.v4.app.DialogFragment;
import android.util.Log;

/**
 * Created by HannahKwon on 2016-11-25.
 */

public class StorageNotWorkingDialogFragment extends DialogFragment {
    private static final String TAG = "StorageNotWorkingDialog";

    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
        builder.setMessage(R.string.dialog_unavailable_external_storage)
                .setPositiveButton(R.string.btn_Connect, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        // Nothing to be done, Just inhibits user trying to save file when the external storage is inaccessible
                        Log.d(TAG,"User acknowledged the external storage is not accessible");
                    }
                });
        return builder.create();
    }
}

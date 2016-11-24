package com.example.hannahkwon.bluetooth1;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.os.Bundle;
import android.support.v4.app.DialogFragment;
import android.util.Log;

/**
 * Created by HannahKwon on 2016-09-21.
 */
public class NotSupportBtDialogFragment extends DialogFragment {

    private static final String TAG = "NotSupportBtDialog";

    public interface NotSupportBtDialogListener {
        void onDialogOkClick(DialogFragment dialog);
    }

    NotSupportBtDialogListener mListener;

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
        // Verify that the host activity(MainActivity) implements callback
        if (context instanceof NotSupportBtDialogListener) {
            Log.d(TAG,"MainAcitivity implemented NotSupportBtDialogListener");
            mListener = (NotSupportBtDialogListener) context;
        }
        else{
            throw new RuntimeException(context.toString()
            + "must implement NotSupportBtDialogListener");
        }
    }

    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
        builder.setMessage(R.string.dialog_not_support_bluetooth)
                .setPositiveButton(R.string.btn_OK, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        // Send the positive button event back to the host activity
                        mListener.onDialogOkClick(NotSupportBtDialogFragment.this);
                    }
                });
        return builder.create();
    }
}

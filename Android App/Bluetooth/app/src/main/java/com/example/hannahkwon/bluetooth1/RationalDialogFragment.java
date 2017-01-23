package com.example.hannahkwon.bluetooth1;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.ActivityNotFoundException;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.provider.Settings;
import android.support.v4.app.DialogFragment;
import android.util.Log;

/**
 * Created by HannahKwon on 2016-11-12.
 */
public class RationalDialogFragment extends DialogFragment {
    private static final String TAG = "RationalDialogFragment";

    private String mTitle = null;
    private String mMessage = null;
    private Context mContext;

    static RationalDialogFragment newInstance(String title, String message){
        RationalDialogFragment rationalDialog = new RationalDialogFragment();

        Bundle args = new Bundle();
        args.putString("title", title);
        args.putString("message", message);
        rationalDialog.setArguments(args);

        return rationalDialog;
    }

    @Override
    public void onCreate(Bundle savedInstanceState){
        super.onCreate(savedInstanceState);

        mTitle = getArguments().getString("title");
        mMessage = getArguments().getString("message");
    }

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
        mContext = getActivity();
    }

    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        Log.d(TAG, "Showing Permission Rationale Dialog");
        AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
        builder.setTitle(mTitle);
        builder.setMessage(mMessage)
                .setPositiveButton(R.string.btn_OK, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        Log.d(TAG, "User pressed OK");
                        try {
                            // Going to the Application's setting
                            Log.d(TAG, "Going to Application's setting");
                            Intent intent = new Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
                                    .setData(Uri.parse("package:" + mContext.getPackageName()));
                            mContext.startActivity(intent);
                        } catch (ActivityNotFoundException e) {
                            e.printStackTrace();

                            Intent intent = new Intent(Settings.ACTION_MANAGE_APPLICATIONS_SETTINGS);
                            mContext.startActivity(intent);
                        }
                    }
                })
                .setNegativeButton(R.string.btn_No_Thanks, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        // User cancelled the dialog
                        // Dialog dismissed automatically
                        Log.d(TAG, "User pressed NO THANKS");
                        dialog.cancel();
                    }
                });
        return builder.create();
    }
}


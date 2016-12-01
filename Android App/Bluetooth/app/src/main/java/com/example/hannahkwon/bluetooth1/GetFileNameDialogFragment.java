package com.example.hannahkwon.bluetooth1;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.DialogFragment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;

/**
 * Created by HannahKwon on 2016-10-13.
 */
public class GetFileNameDialogFragment extends DialogFragment {
    private static final String TAG = "GetFileNameDialog";

    private View mContainer;
    private Button bt_InsertFileName;
    private EditText edittxt_FileName;

//    private String fileName = null;

    public interface GetFileNameDialogListener {
        void onDialogSaveClick(DialogFragment dialog);
    }

    // Use this instance of the interface to deliver action events to host activity
    GetFileNameDialogListener mListener;


    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
        // Verify that the host activity(MainActivity) implements callback
        if (context instanceof GetFileNameDialogListener) {
            Log.d(TAG, "MainActivity implemented GetFileNameDialogListener");
            mListener = (GetFileNameDialogListener) context;
        } else {
            throw new RuntimeException(context.toString()
                    + "must implement GetFileNameDialogListener");
        }
    }

    public Dialog onCreateDialog(Bundle savedInstanceState) {
        AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());

        // Get the layout inflater
        LayoutInflater inflater = getActivity().getLayoutInflater();

        // Inflate and set the custom layout for the dialog
        // Pass null as the parent view because it's going in the dialog layout
        mContainer = inflater.inflate(R.layout.dialog_file_name, null);
        builder.setView(mContainer);

        bt_InsertFileName = (Button) mContainer.findViewById(R.id.bt_InsertFileName);
        edittxt_FileName = (EditText) mContainer.findViewById(R.id.edittxt_FileName);

        bt_InsertFileName.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                mListener.onDialogSaveClick(GetFileNameDialogFragment.this);
            }
        });

        return builder.create();
    }
}
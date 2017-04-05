package com.example.hannahkwon.bluetooth1;

import android.os.Bundle;
import android.support.v4.app.ListFragment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ListView;

import java.io.File;

import static android.content.ContentValues.TAG;
import static com.example.hannahkwon.bluetooth1.MainActivity.mFileManager;

/**
 * Created by HannahKwon on 2017-04-04.
 */

public class ArrayListFragment extends ListFragment {
    int mNum;
    private ArrayAdapter<String> TxTFilesArrayAdapter;
    /**
     * Create a new instance of CountingFragment, providing "num"
     * as an argument.
     */
    static ArrayListFragment newInstance(int num) {
        ArrayListFragment f = new ArrayListFragment();

        // Supply num input as an argument.
        Bundle args = new Bundle();
        args.putInt("num", num);
        f.setArguments(args);

        return f;
    }

    public interface onFileSelectedListener {
        public void onFileSelected(String fileName);
    }

    /**
     * When creating, retrieve this instance's number from its arguments.
     */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mNum = getArguments() != null ? getArguments().getInt("num") : 1;
        Log.d(TAG, TAG + " is getting created");
    }

    /**
     * The Fragment's UI is just a simple text view showing its
     * instance number.
     */
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View v = inflater.inflate(R.layout.fragment_file_list, container, false);
        return v;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);

        TxTFilesArrayAdapter =
                new ArrayAdapter<String>(getActivity(),
                        android.R.layout.simple_list_item_1);
        setListAdapter(TxTFilesArrayAdapter);

        if(mNum == 0) {
            Log.d(TAG, "Displaying local storage files");
            if(mFileManager.createStorageDir()) {   // for cases where the user never started the app
                    File[] txtFiles = mFileManager.getTxTFiles();
                for (File file : txtFiles) {
                    TxTFilesArrayAdapter.add(file.getName());
                }
            }
        }
        else {
            //TODO start from here
            Log.d(TAG, "Displaying cloud storage files");
        }
    }

    @Override
    public void onListItemClick(ListView l, View v, int position, long id) {
        Log.i("FragmentList", "Item clicked: " + id);
        String fileName = TxTFilesArrayAdapter.getItem(position);
        try{
            ((onFileSelectedListener) getActivity()).onFileSelected(fileName);
        }catch (Exception e){
            Log.e(TAG, "Error occurred when passing selected file to activity");
        }
    }
}


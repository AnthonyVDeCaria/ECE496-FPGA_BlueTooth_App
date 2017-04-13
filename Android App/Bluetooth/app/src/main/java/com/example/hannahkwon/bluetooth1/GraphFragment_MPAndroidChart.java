package com.example.hannahkwon.bluetooth1;

import android.app.Activity;
import android.graphics.Color;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.github.mikephil.charting.charts.LineChart;
import com.github.mikephil.charting.components.Description;
import com.github.mikephil.charting.components.XAxis;
import com.github.mikephil.charting.components.YAxis;
import com.github.mikephil.charting.data.Entry;
import com.github.mikephil.charting.data.LineData;
import com.github.mikephil.charting.data.LineDataSet;
import com.github.mikephil.charting.interfaces.datasets.ILineDataSet;

import java.util.ArrayList;
import java.util.concurrent.locks.ReentrantLock;

import static android.util.Log.d;
import static com.example.hannahkwon.bluetooth1.MainActivity.mFileManager;

/**
 * Created by HannahKwon on 2017-03-18.
 */

public class GraphFragment_MPAndroidChart extends Fragment {

    private String TAG = null;

    private Activity activity;

    private long start_time;
    private long plotting_time;

//    private GraphingThread graphingThread;

    private LineChart chart;
    private LineData lineData;  // holds ISE1_dataset & ISE2_dataset
    private LineDataSet ISE1_dataset;
    private LineDataSet ISE2_dataset;
    private ArrayList<Entry> ISE1_entries;
    private ArrayList<Entry> ISE2_entries;

    private boolean over_threshold = false;  // used to change background color
    private float final_temp = 0; // used for saving

    private String description_txt;

    private static ReentrantLock SavingLock = new ReentrantLock();

    //TODO remove this
    private float index = 0;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        activity = getActivity();
        if(activity == null)
            Log.e(TAG, "Getting reference to activity failed!");

        ISE1_entries = new ArrayList<Entry>();
        ISE2_entries = new ArrayList<Entry>();

        ISE1_dataset = new LineDataSet(ISE1_entries, "ISE1");
        ISE1_dataset.setColor(Color.RED);
        ISE1_dataset.setValueTextColor(Color.RED);
        ISE1_dataset.setCircleRadius(2f);
        ISE1_dataset.setCircleColor(Color.RED);
        ISE1_dataset.setDrawCircleHole(false);  // circle will be filled up
        ISE1_dataset.setDrawValues(false);

        ISE2_dataset = new LineDataSet(ISE2_entries, "ISE2");
        ISE2_dataset.setColor(Color.BLUE);
        ISE2_dataset.setValueTextColor(Color.BLUE);
        ISE2_dataset.setCircleRadius(2f);
        ISE2_dataset.setCircleColor(Color.BLUE);
        ISE2_dataset.setDrawCircleHole(false);  // circle will be filled up
        ISE2_dataset.setDrawValues(false);

        lineData = new LineData();

        TAG = getTag();
        d(TAG, "TAG is " + TAG);
        description_txt = "Channel " + TAG.charAt(8);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        d(TAG, "Creating views for " + TAG);

        View view = inflater.inflate(R.layout.graph_fragment_mpandroidchart, container, false);
        chart = (LineChart) view.findViewById(R.id.chart);
        chart.setData(lineData);
        chart.setAutoScaleMinMaxEnabled(true);  // auto scales Y-axis
        chart.setTouchEnabled(true);

        XAxis xAxis = chart.getXAxis();
        xAxis.setPosition(XAxis.XAxisPosition.BOTTOM);
        xAxis.setLabelRotationAngle(45);

        //disabling right Y-axis
        YAxis rightYAxis = chart.getAxisRight();
        rightYAxis.setEnabled(false);

        Description description = chart.getDescription();
        description.setText(description_txt);

        chart.invalidate();

        return view;
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
    }

    public synchronized void addData(float ISE1, float ISE2, float Temp) {
        ISE1_dataset.addEntry(new Entry(index, ISE1));
        ISE2_dataset.addEntry(new Entry(index, ISE2));

        // used for saving
        final_temp = Temp;

        lineData.notifyDataChanged();
        chart.notifyDataSetChanged();

        if (Temp >= Constants.TEMP_THRESHOLD) {
//            Log.d(TAG, "Temp is above threshold");
            if(!over_threshold) {
                chart.setBackgroundColor(Color.GREEN);
                over_threshold = true;
//                Log.d(TAG, "Succeed changing graph background color");
            }

        }
        else {
//            Log.d(TAG, "Temp is below threshold");
            if(over_threshold) {
                chart.setBackgroundColor(Color.WHITE);
                over_threshold = false;
//                Log.d(TAG, "Succeed changing graph background color");
            }
        }
        chart.invalidate();

        index++;
    }

    public void addDataFromFile(float[] data) {
        // 0 - ISE1, 1 - ISE2, 2 - finalTemp, 3 - index
        Log.i(TAG, "Adding into entries from file " + data[0] + ", "
                + data[1] + ", " + data[2]);
        ISE1_dataset.addEntry(new Entry(data[3], data[0]));
        ISE2_dataset.addEntry(new Entry(data[3], data[1]));
        if(data[2] > Constants.TEMP_THRESHOLD) {
            if (!over_threshold) {
                chart.setBackgroundColor(Color.GREEN);
                over_threshold = true;
            }
        }
    }

    public void doneAddingFromFile(){
        lineData.addDataSet(ISE1_dataset);
        lineData.addDataSet(ISE2_dataset);
        lineData.notifyDataChanged();
        chart.notifyDataSetChanged();
        chart.invalidate();
        Log.d(TAG, "Successfully updated the UI");
    }

    public void clear() {
        MainActivity.ViewUpdateLock.lock();
        try {
            // Removes all DataSets (and thereby Entries) from the chart.
//        lineData.clearValues();

            //TODO remove this
            index = 0;

            chart.clearValues();
            ISE1_entries.clear();
            ISE2_entries.clear();

            lineData.notifyDataChanged();
            chart.notifyDataSetChanged();

            d(TAG, "Before clear");

//            d(TAG, "Acquired lock");
            if(over_threshold) {
                chart.setBackgroundColor(Color.WHITE);
                over_threshold = false;
            }
            chart.invalidate();
            d(TAG, "Successfully cleared values");
        } finally {
            MainActivity.ViewUpdateLock.unlock();
        }
    }

    private void ensureCapacity(int num) {
        d(TAG, "Increasing the capacity of the entries");
        ISE1_entries.ensureCapacity(num);
        ISE2_entries.ensureCapacity(num);
    }

    public void start(int num) {
        ensureCapacity(num);

        LineData data = chart.getData();
        if(data != null) {   // cleared entries
            ILineDataSet set = data.getDataSetByIndex(0);

            if (set == null) {
                d(TAG, "Adding datasets");
                lineData.addDataSet(ISE1_dataset);
                lineData.addDataSet(ISE2_dataset);
            }
        }
        start_time = System.currentTimeMillis();

        return;
    }

    // NOTE temperature values are not stored
    public void saveAllData(String fileName) {
        String datatoSave = null;
        String temp = TAG + "\n" + "ISE1\n";
        for (Entry e : ISE1_entries) {
            Log.d(TAG, "Adding following data to saving " + e.getX() + ", " + e.getY());
            datatoSave = temp.concat(e.getX() + "," + e.getY() + "\t");
            temp = datatoSave;
        }
        datatoSave = temp.concat("\nISE2\n");
        temp = datatoSave;
        for (Entry e : ISE2_entries) {
            Log.d(TAG, "Adding following data to saving " + e.getX() + ", " + e.getY());
            datatoSave = temp.concat(e.getX() + "," + e.getY() + "\t");
            temp = datatoSave;
        }
        datatoSave = temp.concat("\nFinalTemp\n");
        temp = datatoSave;
        datatoSave = temp.concat(String.valueOf(final_temp));

        temp = datatoSave;
        datatoSave = temp.concat("\n");

        // to synchronize saving
        SavingLock.lock();
        try {
            mFileManager.saveFile(fileName, datatoSave);
            Log.d(TAG, "Successfully saved all data!");
        } finally {
            SavingLock.unlock();
        }
    }
}

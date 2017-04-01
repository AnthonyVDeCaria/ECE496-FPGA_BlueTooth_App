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
import com.github.mikephil.charting.data.Entry;
import com.github.mikephil.charting.data.LineData;
import com.github.mikephil.charting.data.LineDataSet;
import com.github.mikephil.charting.interfaces.datasets.ILineDataSet;

import java.util.ArrayList;

/**
 * Created by HannahKwon on 2017-03-18.
 */

public class GraphFragment_MPAndroidChart extends Fragment {

    private static String TAG = null;

    private Activity activity;

    private long start_time;
    private long plotting_time;

    private LineChart chart;
    private LineData lineData;  // holds ISE1_dataset & ISE2_dataset
    private LineDataSet ISE1_dataset;
    private LineDataSet ISE2_dataset;
    private ArrayList<Entry> ISE1_entries;
    private ArrayList<Entry> ISE2_entries;

    private boolean over_threshold = false;  // used to change background color

    private long counter = 0;

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
        Log.d(TAG, "TAG is " + TAG);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        Log.d(TAG, "Creating views for " + TAG);

        View view = inflater.inflate(R.layout.graph_fragment_mpandroidchart, container, false);
        chart = (LineChart) view.findViewById(R.id.chart);
        chart.setData(lineData);
        chart.setAutoScaleMinMaxEnabled(true);  // auto scales Y-axis
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

    public synchronized void addData(int ISE1_val, int ISE2_val, int Temp_val) {
//        plotting_time = (System.currentTimeMillis() - start_time) / 1000; // to seconds
//        Log.d(TAG, "Adding following data into corresponding series: " + ISE1_val + ", "
//                + ISE2_val);
        // adding data into corresponding series

//                    Log.d(TAG, "Current ISE1: " + ISE1_Series.getyVals().toString());
//                    Log.d(TAG, "Current ISE2: " + ISE2_Series.getyVals().toString());
//        ISE1_dataset.addEntry(new Entry(plotting_time, ISE1_val));
//        ISE2_dataset.addEntry(new Entry(plotting_time, ISE2_val));
        ISE1_dataset.addEntry(new Entry(counter, ISE1_val));
        ISE2_dataset.addEntry(new Entry(counter, ISE2_val));
        counter++;

        lineData.notifyDataChanged();
        chart.notifyDataSetChanged();


//                Log.d(TAG, "Updated ISE1: " + ISE1_Series.getyVals().toString());
//                    Log.d(TAG, "Updated ISE2: " + ISE2_Series.getyVals().toString());
        MainActivity.RuntimerWaiting.lock();
        MainActivity.ViewUpdateLock.lock();
        try {
            if (!MainActivity.runtimerWaiting) {
                if (Temp_val >= Constants.TEMP_THRESHOLD) {
                    //             Log.d(TAG, "Temp is above threshold");
                    if (!over_threshold) {
                        activity.runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                chart.setBackgroundColor(Color.GREEN);
                            }
                        });
                        over_threshold = true;
                        //                Log.d(TAG, "Succeed changing graph background color");
                    }
                } else {
                    //            Log.d(TAG, "Temp is below threshold");
                    if (over_threshold) {
                        activity.runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                chart.setBackgroundColor(Color.WHITE);
                            }
                        });
                        over_threshold = false;
                        //                Log.d(TAG, "Succeed changing graph background color");
                    }
                }
                activity.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        chart.invalidate();
                    }
                });
                Log.d(TAG, "Succeed updating graph");
            }
        } finally   {
            MainActivity.ViewUpdateLock.unlock();
            MainActivity.RuntimerWaiting.unlock();
        }
        return;
    }

    public void clear() {
        ISE1_entries.clear();
        ISE2_entries.clear();
        // Removes all DataSets (and thereby Entries) from the chart.
//        lineData.clearValues();

        counter = 0;

        chart.clearValues();
        lineData.notifyDataChanged();
        chart.notifyDataSetChanged();

        Log.d(TAG, "Before clear");
        MainActivity.ViewUpdateLock.lock();
        try {
            Log.d(TAG, "Acquired lock");
            if(over_threshold) {
                chart.setBackgroundColor(Color.WHITE);
                over_threshold = false;
            }
            chart.invalidate();
            Log.d(TAG, "Successfully cleared values");
        } finally {
            MainActivity.ViewUpdateLock.unlock();
        }
    }

    private void ensureCapacity(int num) {
        Log.d(TAG, "Increasing the capacity of the entries");
        ISE1_entries.ensureCapacity(num);
        ISE2_entries.ensureCapacity(num);
    }

    public void start(int num) {
        ensureCapacity(num);

        LineData data = chart.getData();
        if(data != null) {   // cleared entries
            ILineDataSet set = data.getDataSetByIndex(0);

            if (set == null) {
                Log.d(TAG, "Adding datasets");
                lineData.addDataSet(ISE1_dataset);
                lineData.addDataSet(ISE2_dataset);
            }
        }
        start_time = System.currentTimeMillis();
//        lineData.addDataSet(ISE1_dataset);
//        lineData.addDataSet(ISE2_dataset);
    }

    public void save() {

    }
}

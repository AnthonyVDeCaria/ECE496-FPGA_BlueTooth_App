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
import java.util.concurrent.LinkedBlockingQueue;

import static android.util.Log.d;

/**
 * Created by HannahKwon on 2017-03-18.
 */

public class GraphFragment_MPAndroidChart extends Fragment {

    private String TAG = null;

    private Activity activity;

    private long start_time;
    private long plotting_time;

    private GraphingThread graphingThread;

    private LineChart chart;
    private LineData lineData;  // holds ISE1_dataset & ISE2_dataset
    private LineDataSet ISE1_dataset;
    private LineDataSet ISE2_dataset;
    private ArrayList<Entry> ISE1_entries;
    private ArrayList<Entry> ISE2_entries;

    private boolean over_threshold = false;  // used to change background color

    private String description_txt;

    private LinkedBlockingQueue<int []> mmFIFOQueue = new LinkedBlockingQueue<int []>();

    //TODO remove this
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
        d(TAG, "TAG is " + TAG);
        description_txt = "Channel " + TAG.charAt(8);

        graphingThread = new GraphingThread();
        graphingThread.start();
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

    public void addData(int[] data) {
        int [] necessary_data = new int[3];
        necessary_data[0] = data[1];
        necessary_data[1] = data[2];
        necessary_data[2] = data[3];
        Log.i(TAG, "Adding into GraphingThread FIFO queue " + data);
        try {
            mmFIFOQueue.put(necessary_data);
        } catch (Exception e) {
            Log.e(TAG, "Failed adding into GraphingThread FIFO queue", e);
        }
    }

    private class GraphingThread extends Thread {
        private int[] mmTempData = null;

        public GraphingThread() {
            d(TAG, "Creating GraphingThread");
        }

        public void run() {
            while (true) {
                mmTempData = mmFIFOQueue.peek();
                if (mmTempData != null) {
                    MainActivity.RuntimerWaiting.lock();
                    MainActivity.ViewUpdateLock.lock();
                    try {
//            lineData.notifyDataChanged();
//            chart.notifyDataSetChanged();

                        if (!MainActivity.runtimerWaiting) {

                            int ISE1_val = mmTempData[0];
                            int ISE2_val = mmTempData[1];
                            int Temp_val = mmTempData[2];
                            d(TAG, "Adding following data into corresponding series: " + ISE1_val + ", "
                                    + ISE2_val);
                            ISE1_dataset.addEntry(new Entry(counter, ISE1_val));
                            ISE2_dataset.addEntry(new Entry(counter, ISE2_val));
                            counter++;

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
                                    lineData.notifyDataChanged();
                                    chart.notifyDataSetChanged();
                                    chart.invalidate();
                                }
                            });
                            d(TAG, "Succeed updating graph");
                        }
                    } finally {
                        MainActivity.ViewUpdateLock.unlock();
                        MainActivity.RuntimerWaiting.unlock();
                        mmFIFOQueue.remove();
                        Log.d(TAG, "Unlocked locks");
                    }
                }
            }
        }
    }


//        private synchronized void add (int[] data) {
//            Log.i(TAG, "Adding into GraphingThread FIFO queue " + data);
//            try {
//                mmFIFOQueue.put(data);
//            } catch (Exception e) {
//                Log.e(TAG, "Failed adding into GraphingThread FIFO queue", e);
//            }
//        }

//    }
//    public synchronized void addData(int ISE1_val, int ISE2_val, int Temp_val) {
////        plotting_time = (System.currentTimeMillis() - start_time) / 1000; // to seconds
//        d(TAG, "Received following data: " + ISE1_val + ", "
//                + ISE2_val);
//
//        MainActivity.RuntimerWaiting.lock();
//        MainActivity.ViewUpdateLock.lock();
//        try {
//
////            lineData.notifyDataChanged();
////            chart.notifyDataSetChanged();
//
//            if (!MainActivity.runtimerWaiting) {
//                d(TAG, "Adding following data into corresponding series: " + ISE1_val + ", "
//                        + ISE2_val);
//                final int ISE1 = ISE1_val;
//                final int ISE2 = ISE2_val;
//                counter++;
//
//                if (Temp_val >= Constants.TEMP_THRESHOLD) {
//                    //             Log.d(TAG, "Temp is above threshold");
//                    if (!over_threshold) {
//                        activity.runOnUiThread(new Runnable() {
//                            @Override
//                            public void run() {
//                                chart.setBackgroundColor(Color.GREEN);
//                            }
//                        });
//                        over_threshold = true;
//                        //                Log.d(TAG, "Succeed changing graph background color");
//                    }
//                } else {
//                    //            Log.d(TAG, "Temp is below threshold");
//                    if (over_threshold) {
//                        activity.runOnUiThread(new Runnable() {
//                            @Override
//                            public void run() {
//                                chart.setBackgroundColor(Color.WHITE);
//                            }
//                        });
//                        over_threshold = false;
//                        //                Log.d(TAG, "Succeed changing graph background color");
//                    }
//                }
//                activity.runOnUiThread(new Runnable() {
//                    @Override
//                    public void run() {
//                        ISE1_dataset.addEntry(new Entry(counter, ISE1));
//                        ISE2_dataset.addEntry(new Entry(counter, ISE2));
//                        lineData.notifyDataChanged();
//                        chart.notifyDataSetChanged();
//                        chart.invalidate();
//                    }
//                });
//                d(TAG, "Succeed updating graph");
//            }
//        } finally   {
//            MainActivity.ViewUpdateLock.unlock();
//            MainActivity.RuntimerWaiting.unlock();
//            return;
//        }
//    }

    public void clear() {
        ISE1_entries.clear();
        ISE2_entries.clear();
        // Removes all DataSets (and thereby Entries) from the chart.
//        lineData.clearValues();

        counter = 0;

        chart.clearValues();
        MainActivity.ViewUpdateLock.lock();
        try {
            lineData.notifyDataChanged();
            chart.notifyDataSetChanged();

            d(TAG, "Before clear");

            d(TAG, "Acquired lock");
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

    public void save() {

    }
}

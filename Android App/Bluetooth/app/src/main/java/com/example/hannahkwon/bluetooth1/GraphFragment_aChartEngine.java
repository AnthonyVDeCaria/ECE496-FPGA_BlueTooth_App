package com.example.hannahkwon.bluetooth1;

import android.app.Activity;
import android.graphics.Color;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;

import org.achartengine.ChartFactory;
import org.achartengine.GraphicalView;
import org.achartengine.chart.PointStyle;
import org.achartengine.model.XYMultipleSeriesDataset;
import org.achartengine.model.XYSeries;
import org.achartengine.renderer.XYMultipleSeriesRenderer;
import org.achartengine.renderer.XYSeriesRenderer;

/**
 * Created by HannahKwon on 2017-03-18.
 */

public class GraphFragment_aChartEngine extends Fragment {

    private static String TAG = null;

    private Activity activity;

    private long start_time;
    private long plotting_time;

    private XYSeries ISE1_Series;
    private XYSeries ISE2_Series;
    private XYMultipleSeriesDataset multiple_series;
    private XYSeriesRenderer ISE1_render;
    private XYSeriesRenderer ISE2_render;
    private XYMultipleSeriesRenderer multiRenderer;
    private GraphicalView chartView;

    private boolean over_threshold = false;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        activity = getActivity();
        if(activity == null)
            Log.e(TAG, "Getting reference to activity failed!");

        ISE1_Series = new XYSeries("ISE1");
        ISE2_Series = new XYSeries("ISE2");

        multiple_series = new XYMultipleSeriesDataset();
        multiple_series.addSeries(ISE1_Series);
        multiple_series.addSeries(ISE2_Series);

        ISE1_render = new XYSeriesRenderer();
        ISE1_render.setColor(Color.RED);
        ISE1_render.setPointStyle(PointStyle.CIRCLE);
        ISE1_render.setFillPoints(true);
        ISE2_render = new XYSeriesRenderer();
        ISE2_render.setColor(Color.BLUE);
        ISE2_render.setPointStyle(PointStyle.CIRCLE);
        ISE2_render.setFillPoints(true);

        multiRenderer = new XYMultipleSeriesRenderer();
        multiRenderer.addSeriesRenderer(ISE1_render);
        multiRenderer.addSeriesRenderer(ISE2_render);
        multiRenderer.setShowGrid(true);

        chartView = ChartFactory.getLineChartView(getContext(), multiple_series, multiRenderer);

        TAG = getTag();
        Log.d(TAG, "TAG is " + TAG);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        Log.d(TAG, "Creating views for " + TAG);

        View view = inflater.inflate(R.layout.graph_fragment_achartengine, container, false);
        LinearLayout chartLayout = (LinearLayout) view.findViewById(R.id.chart_container);
        chartLayout.addView(chartView, 0);

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
        plotting_time = System.currentTimeMillis() - start_time;
//        Log.d(TAG, "Adding following data into corresponding series: " + ISE1_val + ", "
//                + ISE2_val);
                // adding data into corresponding series

//                    Log.d(TAG, "Current ISE1: " + ISE1_Series.getyVals().toString());
//                    Log.d(TAG, "Current ISE2: " + ISE2_Series.getyVals().toString());
        ISE1_Series.add((double) plotting_time, ISE1_val);
        ISE2_Series.add((double) plotting_time, ISE2_val);

//                Log.d(TAG, "Updated ISE1: " + ISE1_Series.getyVals().toString());
//                    Log.d(TAG, "Updated ISE2: " + ISE2_Series.getyVals().toString());

        if (Temp_val >= Constants.TEMP_THRESHOLD) {
//                        Log.d(TAG, "Temp is above threshold");
            if(!over_threshold) {
                activity.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        chartView.setBackgroundColor(Color.GREEN);
                    }
                });
                over_threshold = true;
//                Log.d(TAG, "Succeed changing graph background color");
            }
        } else {
//                        Log.d(TAG, "Temp is below threshold");
            if(over_threshold) {
                activity.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        chartView.setBackgroundColor(Color.WHITE);
                    }
                });
                over_threshold = true;
//                Log.d(TAG, "Succeed changing graph background color");
            }
        }
        activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                chartView.repaint();
            }
        });
//        Log.d(TAG, "Succeed updating graph");

        return;
    }

    public void clear() {
        chartView.setBackgroundColor(Color.WHITE);
        over_threshold = false;

        // Removes all the XY series from the list
        ISE1_Series.clear();
        ISE2_Series.clear();
        chartView.repaint();
    }

    public void start() {
        start_time = System.currentTimeMillis();
    }
}
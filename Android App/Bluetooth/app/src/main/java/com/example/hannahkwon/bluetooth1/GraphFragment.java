package com.example.hannahkwon.bluetooth1;

import android.graphics.Canvas;
import android.graphics.Color;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.androidplot.Plot;
import com.androidplot.PlotListener;
import com.androidplot.xy.LineAndPointFormatter;
import com.androidplot.xy.PanZoom;
import com.androidplot.xy.SimpleXYSeries;
import com.androidplot.xy.XYPlot;

import java.util.concurrent.locks.ReentrantLock;

/**
 * Created by HannahKwon on 2017-01-18.
 */

public class GraphFragment extends Fragment {
    private static String TAG = null;

    private XYPlot plot;

    private SimpleXYSeries ISE1_Series = null;
    private SimpleXYSeries ISE2_Series = null;
    private SimpleXYSeries Temp_Series = null;

    public static ReentrantLock DataLock = null;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        ISE1_Series = new SimpleXYSeries(SimpleXYSeries.ArrayFormat.Y_VALS_ONLY, "ISE1_Series");
        ISE2_Series = new SimpleXYSeries(SimpleXYSeries.ArrayFormat.Y_VALS_ONLY, "ISE2_Series");
        Temp_Series = new SimpleXYSeries(SimpleXYSeries.ArrayFormat.Y_VALS_ONLY, "Temp_Series");

        DataLock = new ReentrantLock();

        TAG = getTag();
        Log.d(TAG, "TAG is " + TAG);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        Log.d(TAG, "Creating views for " + TAG);
        View view = inflater.inflate(R.layout.graph_fragment, container, false);

        plot = (XYPlot) view.findViewById(R.id.plot);
        if(plot == null)
            Log.d(TAG, "plot is null!");
        LineAndPointFormatter ISE1_format = new LineAndPointFormatter(Color.BLUE, Color.BLUE, null, null);
        LineAndPointFormatter ISE2_format = new LineAndPointFormatter(Color.GREEN, Color.GREEN, null, null);
        LineAndPointFormatter Temp_format = new LineAndPointFormatter(Color.RED, Color.RED, null,null);
        // disabling legends
        ISE1_format.setLegendIconEnabled(false);
        ISE2_format.setLegendIconEnabled(false);
        Temp_format.setLegendIconEnabled(false);

        plot.addSeries(ISE1_Series, ISE1_format);
        plot.addSeries(ISE2_Series, ISE2_format);
        plot.addSeries(Temp_Series, Temp_format);

        PanZoom.attach(plot);   // enable zooming

        plot.addListener(new PlotListener() { // to synchronize data with rendering loop
            @Override
            public void onBeforeDraw(Plot source, Canvas canvas) {
                // write-lock each active series for writes
                Log.d(TAG, "Before redraw");
                DataLock.lock();
            }

            @Override
            public void onAfterDraw(Plot source, Canvas canvas) {
                // unlock any locked series
                Log.d(TAG, "Done redraw");
                DataLock.unlock();
            }
        });

        return view;
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
    }

    public void addData(int ISE1_val, int ISE2_val, int Temp_val) {
        if(DataLock == null)
            Log.e(TAG, "Lock for Data add is not initialized!");
        boolean addDone = false;
        Log.d(TAG, "Adding following data into corresponding series: " + ISE1_val + ", "
                + ISE2_val + ", " + Temp_val);
        while(true) {
            DataLock.lock();
            try {
                    // adding data into corresponding series

                    Log.d(TAG, "Current ISE1: " + ISE1_Series.getyVals().toString());
                    Log.d(TAG, "Current ISE2: " + ISE2_Series.getyVals().toString());
                    Log.d(TAG, "Current Temp: " + Temp_Series.getyVals().toString());
                    ISE1_Series.addLast(null, ISE1_val);
                    ISE2_Series.addLast(null, ISE2_val);
                    Temp_Series.addLast(null, Temp_val);
                    addDone = true;
                    Log.d(TAG, "Updated ISE1: " + ISE1_Series.getyVals().toString());
                    Log.d(TAG, "Updated ISE2: " + ISE2_Series.getyVals().toString());
                    Log.d(TAG, "Updated Temp: " + Temp_Series.getyVals().toString());
            } finally {
                DataLock.unlock();
                if(addDone) {
                    Log.d(TAG, "Redraw plot");
                    plot.redraw();
                    return;
                }
            }
        }
    }

}

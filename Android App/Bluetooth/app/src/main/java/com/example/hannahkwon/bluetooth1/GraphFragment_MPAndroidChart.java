package com.example.hannahkwon.bluetooth1;

import android.app.Activity;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.github.mikephil.charting.charts.LineChart;
import com.github.mikephil.charting.components.Description;
import com.github.mikephil.charting.components.MarkerView;
import com.github.mikephil.charting.components.XAxis;
import com.github.mikephil.charting.components.YAxis;
import com.github.mikephil.charting.data.Entry;
import com.github.mikephil.charting.data.LineData;
import com.github.mikephil.charting.data.LineDataSet;
import com.github.mikephil.charting.highlight.Highlight;
import com.github.mikephil.charting.interfaces.datasets.ILineDataSet;
import com.github.mikephil.charting.utils.MPPointF;

import java.util.ArrayList;
import java.util.concurrent.locks.ReentrantLock;

import static android.util.Log.d;
import static com.example.hannahkwon.bluetooth1.MainActivity.mFileManager;
import static com.example.hannahkwon.bluetooth1.MainActivity.temp_threshold;

/**
 * Created by HannahKwon on 2017-03-18.
 */

public class GraphFragment_MPAndroidChart extends Fragment {

    private String TAG = null;

    private Activity activity;

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

    //TODO remove this
    private static ReentrantLock SavingLock = new ReentrantLock();

    private boolean marked = false;

    private boolean zoomed = false;

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

        ISE1_dataset.setHighlightEnabled(true);
        ISE1_dataset.setDrawVerticalHighlightIndicator(false);
        ISE1_dataset.setHighLightColor(Color.MAGENTA);
        ISE1_dataset.setHighlightLineWidth(2f);

        ISE2_dataset = new LineDataSet(ISE2_entries, "ISE2");
        ISE2_dataset.setColor(Color.BLUE);
        ISE2_dataset.setValueTextColor(Color.BLUE);
        ISE2_dataset.setCircleRadius(2f);
        ISE2_dataset.setCircleColor(Color.BLUE);
        ISE2_dataset.setDrawCircleHole(false);  // circle will be filled up
        ISE2_dataset.setDrawValues(false);

        ISE2_dataset.setHighlightEnabled(true);
        ISE2_dataset.setDrawVerticalHighlightIndicator(false);
        ISE2_dataset.setHighLightColor(Color.CYAN);
        ISE2_dataset.setHighlightLineWidth(2f);

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

        // disables highlighting at touch event
        chart.setHighlightPerDragEnabled(false);
        chart.setHighlightPerTapEnabled(false);

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

    public synchronized void addData(float index, float ISE1, float ISE2, float Temp) {
        ISE1_dataset.addEntry(new Entry(index, ISE1));
        ISE2_dataset.addEntry(new Entry(index, ISE2));

        // used for saving
        final_temp = Temp;

        lineData.notifyDataChanged();
        chart.notifyDataSetChanged();

        if (Temp >= temp_threshold) {
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
    }

    public void addDataFromFile(float[] data) {
        // 0 - ISE1, 1 - ISE2, 2 - finalTemp, 3 - index
        Log.i(TAG, "Adding into entries from file " + data[0] + ", "
                + data[1] + ", " + data[2]);
        ISE1_dataset.addEntry(new Entry(data[3], data[0]));
        ISE2_dataset.addEntry(new Entry(data[3], data[1]));
        if (data[2] > temp_threshold) {
            if(!over_threshold) {
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

        chart.fitScreen();

        Log.d(TAG, "Successfully updated the UI");
    }

    public synchronized void clear() {
        if(marked) {    // to clear highlights and markers
            Log.d(TAG, "Removing markers for previous graphs");
            chart.setDrawMarkers(false);
            marked = false;
        }

        if(over_threshold) {
            Log.d(TAG, "Changing back the background color to white");
            chart.setBackgroundColor(Color.WHITE);
            over_threshold = false;
        }

        chart.clearValues();
        ISE1_entries.clear();
        ISE2_entries.clear();

        lineData.notifyDataChanged();
        chart.notifyDataSetChanged();

        d(TAG, "Before clear");
        chart.invalidate();

        d(TAG, "Successfully cleared values");
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
        return;
    }

    // NOTE temperature values are not stored
    public synchronized void saveAllData(String fileName) {
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

        mFileManager.saveFile(fileName, datatoSave);
        Log.d(TAG, "Successfully saved all data!");
    }

    /*
     * Data analysis - supporting only min/max and slope for now
     */
    public synchronized void dataAnalysis(int option) {
        if (option == Constants.OPT_MIN_AND_MAX) {
            minMaxAnalysis();
        }
        else if (option == Constants.OPT_SLOPE) {
            Log.d(TAG, "Performing Slope data analysis");
            SlopeAnalysis();
        }
        else {
            Log.e(TAG, "Wrong data analysis option");
        }
    }

    private void minMaxAnalysis() {
        if(ISE1_entries.size() != 0 && ISE2_entries.size() != 0) {
            Log.d(TAG, "Performing Min/Max data analysis");
            if(marked) {    // to clear previous highlights and markers
                Log.d(TAG, "Removing markers for previous graphs");
                chart.setDrawMarkers(false);
            }
            marked = true;

            boolean ISE1_min_found = false;
            boolean ISE1_max_found = false;
            boolean ISE2_min_found = false;
            boolean ISE2_max_found = false;
            int k = 0;
            // 0 & 1 - min/max for ISE1, 2 & 3  - min/max for ISE2
            Highlight[] highlights = new Highlight[4];
            for (int i = 0; i < 2; i++) {
                int xMin = (int) lineData.getDataSetByIndex(i).getXMin();
                int xMax = (int) lineData.getDataSetByIndex(i).getXMax();
                float yMin = lineData.getDataSetByIndex(i).getYMin();
                float yMax = lineData.getDataSetByIndex(i).getYMax();
                for (int j = xMin; j < xMax + 1; j++) {
                    float y = lineData.getDataSetByIndex(i).getEntryForXValue(j, Float.NaN).getY();
                    if (y == yMin) {
                        if (i == 0 && !ISE1_min_found) {
                            Log.d(TAG, "Set ISE1 min with index " + k);
                            highlights[k] = new Highlight(j, y, i);
                            ISE1_min_found = true;
                            k++;
                        }
                        else if (i == 1 && !ISE2_min_found) {
                            Log.d(TAG, "Set ISE2 min with index " + k);
                            highlights[k] = new Highlight(j, y, i);
                            ISE2_min_found = true;
                            k++;
                        }
                    }
                    if (y == yMax) {
                        if (i == 0 && !ISE1_max_found) {
                            Log.d(TAG, "Set ISE1 max with index " + k);
                            highlights[k] = new Highlight(j, y, i);
                            ISE1_max_found = true;
                            k++;
                        }
                        else if (i == 1 && !ISE2_max_found) {
                            Log.d(TAG, "Set ISE2 max with index " + k);
                            highlights[k] = new Highlight(j, y, i);
                            ISE2_max_found = true;
                            k++;
                        }
                    }
                    if(ISE1_min_found && ISE1_max_found && ISE2_min_found && ISE2_max_found) {
                        Log.d(TAG, "Found all min and max for ISE1 & ISE2");
                        break;
                    }
                }
            }
            MinMaxMarkerView minMaxMarker = new MinMaxMarkerView(activity, R.layout.min_max_marker_layout);
            minMaxMarker.setChartView(chart);   // for bounds control
            chart.setDrawMarkers(true);
            chart.setMarker(minMaxMarker);
            chart.highlightValues(highlights);
        }
    }

    public class MinMaxMarkerView extends MarkerView {
        private RelativeLayout layout;
        private TextView tvContent;

        public MinMaxMarkerView(Context context, int layoutResource) {
            super(context, layoutResource);

            // find your layout components
            layout = (RelativeLayout) findViewById(R.id.relativeLayout);
            tvContent = (TextView) findViewById(R.id.textView);
        }

        // callbacks everytime the MarkerView is redrawn, can be used to update the
        // content (user-interface)
        @Override
        public void refreshContent(Entry e, Highlight highlight) {
            int dataSet = highlight.getDataSetIndex();
            float yVal;
            if(dataSet == 0) {  // ISE1
                yVal = highlight.getY();
                if(yVal == ISE1_dataset.getYMin())
                    tvContent.setText("Min: " + e.getY());
                else
                    tvContent.setText("Max: " + e.getY());
                // changing the color of background drawable to magenta
                layout.setBackgroundColor(0xFFFF0000);
            }
            else if(dataSet == 1) {
                yVal = highlight.getY();
                if(yVal == ISE2_dataset.getYMin())
                    tvContent.setText("Min: " + e.getY());
                else
                    tvContent.setText("Max: " + e.getY());
                // changing the color of background drawable to cyan
                layout.setBackgroundColor(0xFF0000FF);
            }

            // this will perform necessary layouting
            super.refreshContent(e, highlight);
        }

        private MPPointF mOffset;
        @Override
        public MPPointF getOffset() {
            if(mOffset == null) {
                // center the marker horizontally and vertically
                mOffset = new MPPointF(-(getWidth() / 2), -getHeight());
            }
            return mOffset;
        }

        @Override
        public void draw(Canvas canvas, float posX, float posY) {
            super.draw(canvas, posX, posY);
            getOffsetForDrawingAtPoint(posX, posY);
        }
    }

    private void SlopeAnalysis() {
        if(ISE1_entries.size() != 0 && ISE2_entries.size() != 0) {
            Log.d(TAG, "Performing Slope data analysis");
            if(marked) {    // to clear previous highlights and markers
                chart.setDrawMarkers(false);
            }

            //TODO start from here
        }
    }
}

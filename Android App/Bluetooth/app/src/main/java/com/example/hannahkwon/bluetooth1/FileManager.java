package com.example.hannahkwon.bluetooth1;

import android.os.Environment;
import android.support.v4.app.FragmentActivity;
import android.util.Log;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.FilenameFilter;

/**
 * Created by HannahKwon on 2016-10-13.
 */
public class FileManager {
    private static final String TAG = "FileManager";

    private FragmentActivity mActivity;
//    private Handler mHandler;

    private static String PARENT_DIR;
    private static String path = null;

    private static String logFilePath;

    public FileManager(FragmentActivity ac){
        Log.d(TAG, "FileManager is instantiated");
        mActivity= ac;

        PARENT_DIR = mActivity.getString(R.string.app_name);

        path = Environment.getExternalStorageDirectory().getAbsolutePath() + File.separator + PARENT_DIR;
        logFilePath = path + File.separator + Constants.LOG_FILE;
    }

    /*
    * Checks if external storage is available for read and write
    */
    public static boolean isExternalStorageAvailable() {
        String state = Environment.getExternalStorageState();
        if (Environment.MEDIA_MOUNTED.equals(state)) {
            return true;
        }
        return false;
    }

    /*
    * Creates parent directory for storage if it is not there
    * Returns true if the parent storage is created or already exists
    */
    public static boolean createStorageDir() {

        File file = new File(path);
        if(!file.exists()) {
            try {
                if(file.mkdir()) {
                    Log.d(TAG, "Parent directory is created");
                    return true;
                }
                else {    // failed creating parent directory
                    Log.d(TAG, "Failed creating parent directory for storage");
                    return false;
                }
            } catch (Exception e) {
                Log.e(TAG,"Failed creating parent directory for storage", e);
            }
        }
        Log.d(TAG, "File already exists");
        return true;
    }


    /*
    * Check if the given file name already exists
    */
    public static boolean checkFileExists(String fileName) {
        File file = new File(path + File.separator + fileName + ".txt");
        if (file.exists())
            return true;
        return false;
    }

    /*
    * Saves the received data into file with the given file name
    */
    public static boolean saveFile(String fileName, String data) {
        File file = new File(path + File.separator + fileName + ".txt");

        byte[] dataToSave = data.getBytes();

        try{
            // appends to whatever is already there
            FileOutputStream fos = new FileOutputStream(file, true);
            fos.write(dataToSave);
            fos.flush();
            fos.close();
        } catch (Exception e) {
            Log.e(TAG,"Failed saving data", e);
            return false;
        }
        return true;
    }

    public static File [] getTxTFiles() {
        File dir = new File(path);
        return dir.listFiles(new FilenameFilter() {
            public boolean accept(File dir, String filename)
            { return filename.endsWith(".txt"); }
        } );
    }

    public void readFile(String fileName) {
        File file = new File(path + File.separator + fileName);
        int datastream = -1;
        // 0 - index, 1 - ISE1, 2 - ISE2, 3 - FinalTemp
        // 0 - ISE1, 1 - ISE2, 2 - finalTemp, 3 - index
        float [] toAdd = new float[4];

        CharSequence fragment = "Fragment";
        CharSequence ISE1 = "ISE1";
        CharSequence ISE2 = "ISE2";
        CharSequence Temp = "FinalTemp";

        String ISE1_data = null;
        String ISE2_data = null;
        // string composed of x and y
        String[] ISE1_data_point;
        String[] ISE2_data_point;
        // string composed of pair of x and y
        String[] ISE1_data_pair;
        String[] ISE2_data_pair;
        int i = 0;
        try {
            BufferedReader br = new BufferedReader(new FileReader(file));
            String line = null;

            while (true) {
                // A line is considered to be terminated by any one of a line feed ('\n'), a carriage return ('\r')
                line = br.readLine();
                if(line != null) {
                    if(line.contains(fragment)) {
                        datastream = Character.getNumericValue(line.charAt(8));
                        Log.d(TAG, "Now reading data for fragment " + datastream);
                    }
                    if(line.contains(ISE1)) {
                        ISE1_data = br.readLine();
                        Log.d(TAG, "For fragment " + datastream + " ISE1 data is " + ISE1_data);
                    }
                    if(line.contains(ISE2)) {
                        ISE2_data = br.readLine();
                        Log.d(TAG, "For fragment " + datastream + " ISE2 data is " + ISE2_data);
                    }
                    if(line.contains(Temp)) {
                        toAdd[3] = (byte) Float.parseFloat(br.readLine());
                        Log.d(TAG, "For fragment " + datastream + " Temp data is " + toAdd[2]);

                        // Need to clear graphs in case there were data on the screen
                        MainActivity.clearGraphs(datastream);
                        // now starting adding data to graphs
                        if(!ISE1_data.isEmpty() & !ISE2_data.isEmpty()) {
                            ISE1_data_point = ISE1_data.split("\t");
                            ISE2_data_point = ISE2_data.split("\t");
                            for (i = 0; i < ISE1_data_point.length; i++) {
                                ISE1_data_pair = ISE1_data_point[i].split(",");
                                ISE2_data_pair = ISE2_data_point[i].split(",");
                                toAdd[1] = Float.parseFloat(ISE1_data_pair[1]);
                                toAdd[2] = Float.parseFloat(ISE2_data_pair[1]);
                                toAdd[0] = Float.parseFloat(ISE1_data_pair[0]);
                                Log.d(TAG, "Adding the following to the graph " + datastream + " " + toAdd[0] + ", "
                                        + toAdd[1] + ", " + toAdd[2] + ", " + toAdd[3]);
                                MainActivity.addFromFile(datastream, toAdd);
                            }
                            MainActivity.doneAddingFromFile(datastream);
                        }
                    }
                }
                else
                    break;
            }
            br.close();
        } catch (Exception e) {
            Log.e(TAG, "Error occurred when reading file", e);
        }
    }

    /*
    * This is the thread where logs data
    * For now, it's logging every 10 data
    */
    public class LoggingThread extends Thread {
        private FileOutputStream logfos = null;
        public LoggingThread() {
            Log.d(TAG, "Creating LoggingThread");
        }

        public void run() {
            Log.i(TAG, "Beginning mLoggingThread");
            while (true) {
            }
        }

        // To be called when user pressed Start
        public void startLog() {
            Log.d(TAG, "Starting log");
            try {
                clearLogFile();
                File logFile = new File(logFilePath);
                logfos = new FileOutputStream(logFile, true);
            } catch (Exception e) {
                Log.e(TAG, "Failed starting log", e);
            }
        }

        // To be called when user pressed Cancel or after data saving or at Activity destroy
        public void finishLog() {
            Log.d(TAG, "Canceling log");
            try {
                if(logfos != null) {
                    logfos.flush();
                    logfos.close();
                    logfos = null;
                    Log.d(TAG, "Log file saved correctly");
                }
            } catch (Exception e) {
                Log.e(TAG, "Failed canceling log", e);
            }
        }

        public synchronized void log (byte[] data) {
            Log.d(TAG, "Logging");
            try {
//                logfos = new FileOutputStream(logFilePath, true);
                logfos.write(data);
//                logfos.close();
            } catch (Exception e) {
                Log.e(TAG, "Failed logging", e);
            }
        }

        private void clearLogFile() {
            Log.d(TAG, "Clearing log file");
            File logFile = new File(logFilePath);
           try {
               Log.d(TAG, "Log file path is " + logFilePath);
               FileOutputStream fos = new FileOutputStream(logFile);
               fos.close();
           } catch (Exception e) {
               Log.e(TAG, "Failed clearing log file", e);
           }
        }
    }

    public void readLogFile() {
        Log.d(TAG, "Restoring data from Log file");

        File logFile = new File(logFilePath);
        if(logFile.exists()) {
            int datastream = -1;
            // 0 - index, 1 - ISE1, 2 - ISE2, 3 - FinalTemp
            float[] toAdd = new float[4];

            int i, j, k;
            try {
                FileInputStream logfis = new FileInputStream(logFile);
                byte[] dataRead = new byte[250];
                int numBytesRead = 0;

                while (true) {
                    numBytesRead = logfis.read(dataRead, 0, 250);
                    if (numBytesRead != -1) {    // end of dataRead
                        logfis.read();  // to read new dataRead
                        Log.d(TAG, "Char length read is " + numBytesRead);
                        // dataRead read does not include any dataRead-termination characters
                        k = 0;
                        for (j = 0; j < 50; j++) {
                            for (i = 0; i < 5; i++) {
                                if (i == 0) {
                                    datastream = (int) dataRead[k + i] & 0b00000111;
                                    datastream++;
                                }
                                else
                                    toAdd[i - 1] = dataRead[k + i] & 0xff;
                            }
                            Log.d(TAG, "Adding the following to the graph " + datastream + " " + toAdd[0] + ", "
                                    + toAdd[1] + ", " + toAdd[2] + ", " + toAdd[3]);
                            MainActivity.addFromFile(datastream, toAdd);
                            k += 5;
                        }
                    } else { // done reading
                        for(int stream = 1; stream < 9; stream++)   // to finish adding data for all graphs
                            MainActivity.doneAddingFromFile(stream);
                        break;
                    }
                }
                logfis.close();
            } catch (Exception e) {
                Log.e(TAG, "Error occurred when reading file", e);
            }
        }
    }
}

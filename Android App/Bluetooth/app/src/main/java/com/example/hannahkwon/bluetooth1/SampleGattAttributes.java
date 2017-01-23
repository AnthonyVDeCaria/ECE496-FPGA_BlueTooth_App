package com.example.hannahkwon.bluetooth1;

import java.util.HashMap;

/**
 * Created by HannahKwon on 2017-01-10.
 */

public class SampleGattAttributes {
    private static HashMap<String, String> attributes = new HashMap();
    public static String CLIENT_CHARACTERISTIC_CONFIG = "00002902-0000-1000-8000-00805f9b34fb";
    public static String HM_10_CONF = "0000ffe0-0000-1000-8000-00805f9b34fb";
    public static String HM_RX_TX = "0000ffe1-0000-1000-8000-00805f9b34fb";

    //TODO delete them after BLE successful pairing
    public static String BATTERY_LEVEL = "00002a19-0000-1000-8000-00805f9b34fb";
    public static String BATTERY = "0000180f-0000-1000-8000-00805f9b34fb";

    static {
        // Sample Services.
        attributes.put(HM_10_CONF, "HM 10 Serial");
        attributes.put("00001800-0000-1000-8000-00805f9b34fb", "Device Information Service");

        //TODO delete this
        attributes.put(BATTERY, "BATTERY");
        // Sample Characteristics.
        attributes.put(HM_RX_TX, "RX/TX data");
        attributes.put("00002a29-0000-1000-8000-00805f9b34fb", "Manufacturer Name String");
    }

    public static String lookup(String uuid, String defaultName) {
        String name = attributes.get(uuid);
        return name == null ? defaultName : name;
    }
}


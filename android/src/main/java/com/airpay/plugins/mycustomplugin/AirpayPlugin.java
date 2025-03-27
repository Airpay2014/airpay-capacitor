package com.airpay.plugins.mycustomplugin;


import android.content.Intent;

import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

@CapacitorPlugin(name = "MyCustomPlugin")
public class AirpayPlugin extends Plugin {
    public static String LOCAL_AIRPAY_BORADCAST_EVENT = "LOCAL_AIRPAY_BORADCAST_EVENT";
    // Static holder to persist the PluginCall across activity destruction
    private static class CallHolder {
        static PluginCall pluginCall;
    }

    @PluginMethod
    public void echo(PluginCall call) {
        String value = call.getString("value");

        JSObject ret = new JSObject();
        ret.put("value", "result");
        call.resolve(ret);
    }

    @PluginMethod()
    public void open(PluginCall call) {
        if (getActivity() == null) {
            call.reject("Activity is not available");
            return;
        }

        CallHolder.pluginCall = call;
        CallHolder.pluginCall.setKeepAlive(true);
        Intent intent = new Intent(LOCAL_AIRPAY_BORADCAST_EVENT);
        intent.putExtra("request_data",CallHolder.pluginCall.getData().toString());
        LocalBroadcastManager.getInstance(getContext()).sendBroadcast(intent);
    }

    // Static method to resolve the call after payment
    public static void resolvePaymentResult(String result) {
        if (CallHolder.pluginCall != null) {
            JSObject ret = new JSObject();
            ret.put("value", result);
            CallHolder.pluginCall.resolve(ret);
            CallHolder.pluginCall = null; // Clean up
        }
    }

    // Static method to reject the call if payment fails
    public static void rejectPayment(String error) {
        if (CallHolder.pluginCall != null) {
            CallHolder.pluginCall.reject(error);
            CallHolder.pluginCall = null; // Clean up
        }
    }


}

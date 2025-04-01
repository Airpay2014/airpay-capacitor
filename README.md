# Airpay Ionic Capacitor Plugin

This is the official Ionic Capacitor plugin for integrating the Airpay payment gateway into Ionic applications.

## Supported Platforms

* **Android** (version compatibility details below)  
  - Up to Gradle version 8.7

## Requirements

* **Node.js Version:** 22.11.0
* **Ionic Version:** 8.5.0
* **Ionic CLI:** 7.2.0
* **Capacitor CLI:** 7.1.0
* **@capacitor/android:** 7.1.0
* **@capacitor/core:** 7.1.0
* **npm:** 8.19.4

## Installation

> **Note:** For Windows users, please run the following commands in Git Bash instead of Command Prompt. You can download Git for Windows [here](https://git-scm.com/downloads).

### Install Ionic CLI and Capacitor CLI

```sh
npm install -g @ionic/cli
npm install -g @capacitor/cli
```

### Create a New Ionic Project

```sh
ionic start ionic_sample_app blank --type=angular
cd ionic_sample_app/
```

### Enable Capacitor and Add Android Platform

```sh
ionic integrations enable capacitor
npm install @capacitor/android
npx cap add android
npx cap sync android
```

### Install the Airpay Plugin

```sh
npm install https://github.com/Airpay2014/airpay-capacitor.git
ionic build
ionic cap sync android
```

## Android Integration

The following Android files are crucial for integrating Airpay with Capacitor:

### AndroidManifest.xml

Add the following inside the `<application>` tag:

```xml
<uses-library
    android:name="org.apache.http.legacy"
    android:required="false" />
```

Ensure internet permission is granted:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

### MainActivity.java

Modify `MainActivity.java` to include Airpay imports:

```java
package io.ionic.starter;

import com.airpay.airpaysdk_simplifiedotp.AirpayConfig;
import com.airpay.airpaysdk_simplifiedotp.constants.ConfigConstants;
import com.airpay.airpaysdk_simplifiedotp.utils.Transaction;
import com.airpay.airpaysdk_simplifiedotp.utils.Utils;
import com.airpay.airpaysdk_simplifiedotp.view.ActionResultListener;
import com.airpay.plugins.mycustomplugin.AirpayPlugin;
import com.getcapacitor.BridgeActivity;
import com.getcapacitor.JSObject;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.widget.Toast;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.appcompat.app.AppCompatDelegate;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import org.json.JSONObject;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.zip.CRC32;

public class MainActivity extends BridgeActivity implements ActionResultListener {
  public ActivityResultLauncher<Intent> airpayLauncher;


  private BroadcastReceiver receiver = new BroadcastReceiver() {
    @Override
    public void onReceive(Context context, Intent intent) {
      if (AirpayPlugin.LOCAL_AIRPAY_BORADCAST_EVENT.equals(intent.getAction())) {
        if (intent != null ) {
        //  if (intent.getStringExtra("flag").equalsIgnoreCase("y")) {

        String requestData = intent.getStringExtra("request_data");
        Log.d("requestData", requestData);
        try {
          // Convert jsonString to JSONObject
          JSONObject outerJson = new JSONObject(requestData);
          // Get the "value" field which contains the actual JSON string
          String innerJsonString = outerJson.getString("value");
          // Replace escaped quotes \" with actual quotes "
          innerJsonString = innerJsonString.replace("\\\"", "\"");
          // Convert to JSONObject
          JSONObject innerJson = new JSONObject(innerJsonString);

          // Extract values
          String firstName = innerJson.getString("firstName");
          String lastName = innerJson.getString("lastName");
          String email = innerJson.isNull("email") ? "" : innerJson.getString("email");
          String address = innerJson.isNull("address") ? "" : innerJson.getString("address");
          String city = innerJson.isNull("city") ? "" : innerJson.getString("city");
          String state = innerJson.isNull("state") ? "" : innerJson.getString("state");
          String phone = innerJson.isNull("phone") ? "" : innerJson.getString("phone");
          String country = innerJson.isNull("country") ? "" : innerJson.getString("country");
          String pincode = innerJson.isNull("pincode") ? "" : innerJson.getString("pincode");
          String orderId = innerJson.getString("orderId");
          String amount = innerJson.getString("amount");


          DateFormat df1 = new SimpleDateFormat("yyyy-MM-dd");
          String sCurDate1 = df1.format(new Date());

          String sAllData1 = email + firstName
            + lastName + address
            + city + state
            + country + amount
            + orderId + sCurDate1;


          // Merchant Configuration details
          String sMid = "";      //Please enter merchantid
          String sSecret = "";   //Please enter secret key
          String sUserName = ""; //Please enter username
          String sPassword = ""; //Please enter password
          // private key
          String sTemp = sSecret + "@" + sUserName + ":|:" + sPassword;
          String sPrivateKey = Utils.sha256(sTemp);

          // key for checksum
          String sTemp3 = sUserName + "~:~" + sPassword;
          String sKey1 = Utils.sha256(sTemp3);

          // checksum
          sAllData1 = sKey1 + "@" + sAllData1;
          String sChecksum1 = Utils.sha256(sAllData1);

          new AirpayConfig.Builder(MainActivity.this, airpayLauncher)
            .setEnvironment(ConfigConstants.PRODUCTION)
            .setType(102)
            .setPrivateKey(sPrivateKey)
            .setMerchantId(sMid)
            .setOrderId(orderId)
            .setCurrency("356")
            .setIsoCurrency("INR")
            .setEmailId(email)
            .setMobileNo(phone)
            .setBuyerFirstName(firstName)
            .setBuyerLastName(lastName)
            .setBuyerAddress(address)
            .setBuyerCity(city)
            .setBuyerState(state)
            .setBuyerCountry(country)
            .setBuyerPinCode(pincode)
            .setAmount(amount)
            .setWallet("0")
            .setCustomVar("")
            .setTxnSubType("")
            .setChmod("")
            .setChecksum(sChecksum1)
            .setSuccessUrl("") //Please enter success url
            .setFailedUrl("")  //Please enter success url
            .setLanguage("EN")
            .build()
            .initiatePayment();
        

        } catch (Exception e) {
          e.printStackTrace();
        }
    //  }
    }

      }
    }
  };

  @Override
  public void onCreate(Bundle savedInstanceState) {

    registerPlugin(AirpayPlugin.class);

    super.onCreate(savedInstanceState);
    // pluginCall = new AirpayPlugin();
    AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_NO);

    airpayLauncher = registerForActivityResult(
      new ActivityResultContracts.StartActivityForResult(),
      result -> {
        if (result.getResultCode() == RESULT_OK) {
          Intent data = result.getData();
          if (data != null) {
            Transaction transaction = (Transaction) data.getSerializableExtra("response");
            if (transaction != null) {
              Log.d("MyCustomPlugin", "Transaction status: " + transaction.getSTATUS());
              Toast.makeText(this, "Transaction Status: " + transaction.getSTATUS(), Toast.LENGTH_SHORT).show();

              JSObject response = new JSObject();
              response.put("STATUS", transaction.getSTATUS());
              response.put("STATUSMSG", transaction.getSTATUSMSG());
              response.put("TXN_MODE", transaction.getTXN_MODE());
              response.put("TRANSACTIONID", transaction.getTRANSACTIONID());
              response.put("TRANSACTIONAMT", transaction.getTRANSACTIONAMT());
              response.put("TRANSACTIONSTATUS", transaction.getTRANSACTIONSTATUS());
              response.put("MERCHANTTRANSACTIONID", transaction.getMERCHANTTRANSACTIONID());
              response.put("MERCHANTPOSTTYPE", transaction.getMERCHANTPOSTTYPE());
              response.put("MERCHANTKEY", transaction.getMERCHANTKEY());
              response.put("SECUREHASH", transaction.getSECUREHASH());
              response.put("CUSTOMVAR", transaction.getCUSTOMVAR());
              response.put("TXN_DATE_TIME", transaction.getTXN_DATE_TIME());
              response.put("TXN_CURRENCY_CODE", transaction.getTXN_CURRENCY_CODE());
              response.put("TRANSACTIONVARIANT", transaction.getTRANSACTIONVARIANT());
              response.put("CHMOD", transaction.getCHMOD());
              response.put("BANKNAME", transaction.getBANKNAME());
              response.put("CARDISSUER", transaction.getCARDISSUER());
              response.put("FULLNAME", transaction.getFULLNAME());
              response.put("EMAIL", transaction.getEMAIL());
              response.put("CONTACTNO", transaction.getCONTACTNO());
              response.put("ISRISK", transaction.getISRISK());
              response.put("MERCHANT_NAME", transaction.getMERCHANT_NAME());
              response.put("SETTLEMENT_DATE", transaction.getSETTLEMENT_DATE());
              response.put("SURCHARGE", transaction.getSURCHARGE());
              response.put("BILLEDAMOUNT", transaction.getBILLEDAMOUNT());
              response.put("CUSTOMERVPA", transaction.getCUSTOMERVPA());


              AirpayPlugin.resolvePaymentResult(response.toString());

            } else {
              Log.e("MyCustomPlugin", "Transaction object is null");
              AirpayPlugin.rejectPayment("Transaction object is null");
            }
          } else {
            Log.e("MyCustomPlugin", "Intent data is null");
            AirpayPlugin.rejectPayment("Payment failed: No data received");
          }
        } else {
          Log.e("MyCustomPlugin", "Payment failed, Result Code: " + result.getResultCode());
          AirpayPlugin.rejectPayment("Payment failed, Result Code: " + result.getResultCode());
        }
      }
    );


  }

  @Override
  public void onResume() {
    super.onResume();
    LocalBroadcastManager.getInstance(this)
      .registerReceiver(receiver, new IntentFilter(AirpayPlugin.LOCAL_AIRPAY_BORADCAST_EVENT));
  }

  @Override
  public void onPause() {
    super.onPause();
    LocalBroadcastManager.getInstance(this).unregisterReceiver(receiver);
  }

  @Override
  public void onResult(Object o) {
    if (o instanceof Transaction) {
      Transaction transaction = (Transaction) o;

      Toast.makeText(MainActivity.this, transaction.getTRANSACTIONSTATUS() + "\n" + transaction.getSTATUSMSG(), Toast.LENGTH_LONG).show();
      if (transaction.getSTATUS() != null) {
        Log.e("STATUS -> ", "=" + transaction.getSTATUS());
      }
      if (transaction.getMERCHANTKEY() != null) {
        Log.e("MERCHANT KEY -> ", "=" + transaction.getMERCHANTKEY());
      }
      if (transaction.getMERCHANTPOSTTYPE() != null) {
        Log.e("MERCHANT POST TYPE ", "=" +
          transaction.getMERCHANTPOSTTYPE());
      }
      if (transaction.getSTATUSMSG() != null) {
        Log.e("STATUS MSG -> ", "=" + transaction.getSTATUSMSG()); // success or fail
      }
      if (transaction.getTRANSACTIONAMT() != null) {
        Log.e("TRANSACTION AMT -> ", "=" + transaction.getTRANSACTIONAMT());
      }
      if (transaction.getTXN_MODE() != null) {
        Log.e("TXN MODE -> ", "=" + transaction.getTXN_MODE());
      }
      if (transaction.getMERCHANTTRANSACTIONID() != null) {
        Log.e("MERCHANT_TXN_ID -> ", "=" + transaction.getMERCHANTTRANSACTIONID()); // order id
      }
      if (transaction.getSECUREHASH() != null) {
        Log.e("SECURE HASH -> ", "=" + transaction.getSECUREHASH());
      }
      if (transaction.getCUSTOMVAR() != null) {
        Log.e("CUSTOMVAR -> ", "=" + transaction.getCUSTOMVAR());
      }
      if (transaction.getTRANSACTIONID() != null) {
        Log.e("TXN ID -> ", "=" + transaction.getTRANSACTIONID());
      }
      if (transaction.getTRANSACTIONSTATUS() != null) {
        Log.e("TXN STATUS -> ", "=" + transaction.getTRANSACTIONSTATUS());
      }
      if (transaction.getTXN_DATE_TIME() != null) {
        Log.e("TXN_DATETIME -> ", "=" + transaction.getTXN_DATE_TIME());
      }
      if (transaction.getTXN_CURRENCY_CODE() != null) {
        Log.e("TXN_CURRENCY_CODE -> ", "=" + transaction.getTXN_CURRENCY_CODE());
      }
      if (transaction.getTRANSACTIONVARIANT() != null) {
        Log.e("TRANSACTIONVARIANT -> ", "=" + transaction.getTRANSACTIONVARIANT());
      }
      if (transaction.getCHMOD() != null) {
        Log.e("CHMOD -> ", "=" + transaction.getCHMOD());
      }
      if (transaction.getBANKNAME() != null) {
        Log.e("BANKNAME -> ", "=" + transaction.getBANKNAME());
      }
      if (transaction.getCARDISSUER() != null) {
        Log.e("CARDISSUER -> ", "=" + transaction.getCARDISSUER());
      }
      if (transaction.getFULLNAME() != null) {
        Log.e("FULLNAME -> ", "=" + transaction.getFULLNAME());
      }
      if (transaction.getEMAIL() != null) {
        Log.e("EMAIL -> ", "=" + transaction.getEMAIL());
      }
      if (transaction.getCONTACTNO() != null) {
        Log.e("CONTACTNO -> ", "=" + transaction.getCONTACTNO());
      }
      if (transaction.getMERCHANT_NAME() != null) {
        Log.e("MERCHANT_NAME -> ", "=" + transaction.getMERCHANT_NAME());
      }
      if (transaction.getSETTLEMENT_DATE() != null) {
        Log.e("SETTLEMENT_DATE -> ", "=" + transaction.getSETTLEMENT_DATE());
      }
      if (transaction.getSURCHARGE() != null) {
        Log.e("SURCHARGE -> ", "=" + transaction.getSURCHARGE());
      }
      if (transaction.getBILLEDAMOUNT() != null) {
        Log.e("BILLEDAMOUNT -> ", "=" + transaction.getBILLEDAMOUNT());
      }
      if (transaction.getISRISK() != null) {
        Log.e("ISRISK -> ", "=" + transaction.getISRISK());
      }
      String transid = transaction.getMERCHANTTRANSACTIONID();
      String apTransactionID = transaction.getTRANSACTIONID();
      String amount = transaction.getTRANSACTIONAMT();
      String transtatus = transaction.getTRANSACTIONSTATUS();
      String message = transaction.getSTATUSMSG();

      String customer_vpa = "";
      if (!TextUtils.isEmpty(transaction.getCHMOD()) && transaction.getCHMOD().equalsIgnoreCase("upi")) {
        customer_vpa = ":" + transaction.getCUSTOMERVPA();
        Log.e("Verified Hash ==", "INSIDE CHMODE UPI CONSIDTION");
      }

      String merchantid = ""; //Please enter Merchant Id
      String username = "";   //Please enter Username
      String sParam = transid + ":" + apTransactionID + ":" + amount + ":" + transtatus + ":" + message + ":" + merchantid + ":" + username + customer_vpa;
      CRC32 crc = new CRC32();
      crc.update(sParam.getBytes());
      String sCRC = "" + crc.getValue();
      Log.e("Verified Hash ==", "sParam= " + sParam);
      Log.e("Verified Hash ==", "Calculate Hash= " + sCRC);
      Log.e("Verified Hash ==", "RESP Secure Hash= " + transaction.getSECUREHASH());

      if (sCRC.equalsIgnoreCase(transaction.getSECUREHASH())) {
        Log.e("Verified Hash ==", "SECURE HASH MATCHED");
      } else {
        Log.e("Verified Hash ==", "SECURE HASH MIS-MATCHED");
      }
    }


  }

}

```

### build.gradle (app-level)

Add the following dependencies:

```gradle
implementation("com.airpay:Airpay-India-Kit:1.0.1") {
    exclude group: 'androidx.core', module: 'core'
    // or
    exclude group: 'androidx.legacy', module: 'legacy-support-v4'
}
implementation 'androidx.localbroadcastmanager:localbroadcastmanager:1.0.0'
```

### build.gradle (project-level)

Add the following repository configurations:

```gradle
maven { url 'https://maven.google.com' }
maven {
    url 'https://gitlab.com/api/v4/projects/60989340/packages/maven'
    name "GitLab"
    credentials {
        username "" // Enter Username
        password "" // Enter Access Token
    }
}
```

### gradle.properties

Add the following properties:

```properties
android.enableJetifier=true
org.gradle.java.home=C:\\Program Files\\Java\\jdk-21
```

### AirpayPlugin.java

Update the following fields with your merchant configuration details:

```java
// Merchant details
String sMid = ""; // Enter Merchant ID
String sSecret = ""; // Enter Secret Key
String sUserName = ""; // Enter Username
String sPassword = ""; // Enter Password

.setSuccessUrl("") // Enter Success URL
.setFailedUrl("") // Enter Failed URL
```

### Angular Code - home.page.ts

Example of calling the `.open` function on button click:

```typescript
await MyCustomPlugin.open({ value: jsonData })
    .then((result) => {
        alert("Return value is " + result.value);
    })
    .catch((error) => {
        alert("Error is " + error);
    });
```

> **Note:** For merchant configuration details, please contact the Airpay Support Team.

## Help

For troubleshooting, use:

```sh
npx cap doctor
```

## Support

For assistance, please contact:

* **Technical/Integration Support Team**
* **Customer Support Team**

## Version History

* **1.0** - Initial Release

## License

This project is licensed under the [Airpay Payment Service] License.


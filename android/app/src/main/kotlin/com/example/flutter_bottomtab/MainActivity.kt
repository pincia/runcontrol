package com.example.RunControl

import android.util.Log
import androidx.annotation.NonNull;
import com.facebook.FacebookSdk
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        Log.d("RunControl", "key:" + FacebookSdk.getApplicationSignature(this)+"=");
    }
}

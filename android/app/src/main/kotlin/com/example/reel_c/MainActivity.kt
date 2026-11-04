package com.example.reel_c


import android.os.Build

import android.util.Log
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.PickVisualMediaRequest
import androidx.activity.result.contract.ActivityResultContracts
import androidx.annotation.RequiresApi

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity(){

    private val videoPickerChannel = "VIDCHAN"
    private lateinit var pickMedia : ActivityResultLauncher<PickVisualMediaRequest>

    private var pendingResult : MethodChannel.Result? = null


    @RequiresApi(Build.VERSION_CODES.TIRAMISU)
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        pickMedia = registerForActivityResult(ActivityResultContracts.PickVisualMedia()){ uri ->
            if(uri != null){
                Log.d("Uri", "here is uri $uri")
                try{
                contentResolver.openInputStream(uri)?.use { inputStream ->
                    val res = inputStream.readAllBytes()
                    pendingResult?.success(res)
                }}catch (e : Exception){
                    pendingResult?.error(e.toString(), null, null)
                }
            }else{
                Log.d("Uri", "No data selected")
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, videoPickerChannel).setMethodCallHandler { call, result ->
             when(call.method){
                 "selectVideo" -> pickVideo(result)
             }
        }
    }


    @RequiresApi(Build.VERSION_CODES.TIRAMISU)
    private fun pickVideo(result : MethodChannel.Result){
        pendingResult = result
        pickMedia.launch(PickVisualMediaRequest(ActivityResultContracts.PickVisualMedia.VideoOnly))
    }

}

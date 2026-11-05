package com.example.reel_c


import android.os.Build

import android.util.Log
import android.webkit.MimeTypeMap
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.PickVisualMediaRequest
import androidx.activity.result.contract.ActivityResultContracts
import androidx.annotation.RequiresApi

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.nio.file.Files
import java.util.UUID
import kotlin.io.path.writeBytes
import kotlin.uuid.ExperimentalUuidApi
import kotlin.uuid.Uuid

class MainActivity : FlutterFragmentActivity(){

    private val videoPickerChannel = "VIDCHAN"
    private lateinit var pickMedia : ActivityResultLauncher<PickVisualMediaRequest>

    private var pendingResult : MethodChannel.Result? = null


    @OptIn(ExperimentalUuidApi::class)
    @RequiresApi(Build.VERSION_CODES.TIRAMISU)
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        pickMedia = registerForActivityResult(ActivityResultContracts.PickVisualMedia()){ uri ->
            if(uri != null){
                Log.d("Uri", "here is uri $uri")
                try{
                    val mimeType = contentResolver.getType( uri)
                    val extension = MimeTypeMap.getSingleton().getExtensionFromMimeType(mimeType)

                contentResolver.openInputStream(uri)?.use { inputStream ->
                    val vidUuid =  Uuid.generateV7().toString()
                    val tempVidFile =  Files.createTempFile(vidUuid, ".$extension")

                    tempVidFile.writeBytes(inputStream.readAllBytes())
                    pendingResult?.success(tempVidFile.toAbsolutePath().toString())
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

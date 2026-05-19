package io.github.caturl.caturl

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.provider.OpenableColumns
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "io.github.caturl.caturl/intent"
    private val FILE_PICK_REQUEST = 1001
    private var sharedFilePath: String? = null
    private var pendingPickerResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getSharedFilePath" -> {
                        result.success(sharedFilePath)
                        sharedFilePath = null
                    }
                    "openFilePicker" -> {
                        pendingPickerResult = result
                        val intent = Intent(Intent.ACTION_GET_CONTENT).apply {
                            type = "*/*"
                            addCategory(Intent.CATEGORY_OPENABLE)
                        }
                        startActivityForResult(
                            Intent.createChooser(intent, "Open .url file"),
                            FILE_PICK_REQUEST
                        )
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == FILE_PICK_REQUEST) {
            if (resultCode == Activity.RESULT_OK && data?.data != null) {
                val path = resolveUri(data.data!!)
                pendingPickerResult?.success(path)
            } else {
                pendingPickerResult?.success(null)
            }
            pendingPickerResult = null
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
        flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
            MethodChannel(messenger, CHANNEL)
                .invokeMethod("onNewFile", sharedFilePath)
        }
    }

    private fun handleIntent(intent: Intent?) {
        intent ?: return

        val action = intent.action
        val data = intent.data

        when {
            action == Intent.ACTION_VIEW && data != null -> {
                sharedFilePath = resolveUri(data)
            }
            action == Intent.ACTION_SEND -> {
                val uri = intent.getParcelableExtra<Uri>(Intent.EXTRA_STREAM)
                if (uri != null) {
                    sharedFilePath = resolveUri(uri)
                }
            }
        }
    }

    private fun resolveUri(uri: Uri): String? {
        return when (uri.scheme) {
            "file" -> uri.path
            "content" -> {
                try {
                    var fileName = "shortcut.url"
                    contentResolver.query(uri, null, null, null, null)?.use { cursor ->
                        val nameIndex = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                        if (cursor.moveToFirst() && nameIndex >= 0) {
                            fileName = cursor.getString(nameIndex)
                        }
                    }
                    val cacheFile = File(cacheDir, fileName)
                    contentResolver.openInputStream(uri)?.use { input ->
                        FileOutputStream(cacheFile).use { output ->
                            input.copyTo(output)
                        }
                    }
                    cacheFile.absolutePath
                } catch (e: Exception) {
                    null
                }
            }
            else -> null
        }
    }
}

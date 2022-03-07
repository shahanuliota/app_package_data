package com.example.app_package_data

import android.content.Context
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import org.json.JSONObject
import java.security.MessageDigest
import java.security.NoSuchAlgorithmException

/** AppPackageDataPlugin */
class AppPackageDataPlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private var applicationContext: Context? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "app_package_data")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = null
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {

        try {

            if (call.method == "getAll") {
                val packageManager = applicationContext!!.packageManager
                val info = packageManager.getPackageInfo(applicationContext!!.packageName, 0)
                val buildSignature = getBuildSignature(packageManager)
                val infoMap = HashMap<String, Any>()
                infoMap.apply {
                    put("appName", info.applicationInfo.loadLabel(packageManager).toString())
                    put("packageName", applicationContext!!.packageName)
                    put("version", info.versionName)
                    put("buildNumber", getLongVersionCode(info).toString())
                    if (buildSignature != null)
                        put(
                            "buildSignature",
                            buildSignature
                            //JSONObject(buildSignature).toString()
                        )
                }.also { resultingMap ->
                    result.success(JSONObject(resultingMap.toMap()).toString())
                }
            } else if (call.method == "getPlatformVersion") {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            } else {
                result.notImplemented()
            }
        } catch (ex: PackageManager.NameNotFoundException) {
            result.error("Name not found", ex.message, null)
        }


    }


    @Suppress("deprecation")
    private fun getLongVersionCode(info: PackageInfo): Long {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            info.longVersionCode
        } else {
            info.versionCode.toLong()
        }
    }

    @Suppress("deprecation", "PackageManagerGetSignatures")
    private fun getBuildSignature(pm: PackageManager): Map<String, String?>? {
        return try {
            val signatureTypes = listOf("SHA1", "MD5", "SHA256")
            val map = HashMap<String, String?>()
            signatureTypes.forEach {
                val signature = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    val packageInfo = pm.getPackageInfo(
                        applicationContext!!.packageName,
                        PackageManager.GET_SIGNING_CERTIFICATES
                    )
                    val signingInfo = packageInfo.signingInfo ?: return null

                    if (signingInfo.hasMultipleSigners()) {
                        signatureToSha1(
                            signingInfo.apkContentsSigners.first().toByteArray(),
//                            "SHA1"
                            it
                        )
                    } else {
                        signatureToSha1(
                            signingInfo.signingCertificateHistory.first().toByteArray(),
                            //  "SHA1"
                            it
                        )
                    }
                } else {
                    val packageInfo = pm.getPackageInfo(
                        applicationContext!!.packageName,
                        PackageManager.GET_SIGNATURES
                    )
                    val signatures = packageInfo.signatures

                    if (signatures.isNullOrEmpty() || packageInfo.signatures.first() == null) {
                        null
                    } else {
                        signatureToSha1(signatures.first().toByteArray(), it)
                    }
                }
                map[it] = signature
            }
            map
        } catch (e: PackageManager.NameNotFoundException) {
            null
        } catch (e: NoSuchAlgorithmException) {
            null
        }
    }

    // Credits https://gist.github.com/scottyab/b849701972d57cf9562e
    @Throws(NoSuchAlgorithmException::class)
    private fun signatureToSha1(sig: ByteArray, key: String): String {
        val digest = MessageDigest.getInstance(key)
        digest.update(sig)
        val hashText = digest.digest()
        return bytesToHex(hashText)
    }

    // Credits https://gist.github.com/scottyab/b849701972d57cf9562e
    private fun bytesToHex(bytes: ByteArray): String {
        val hexArray = charArrayOf(
            '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'
        )
        val hexChars = CharArray(bytes.size * 2)
        var v: Int
        for (j in bytes.indices) {
            v = bytes[j].toInt() and 0xFF
            hexChars[j * 2] = hexArray[v ushr 4]
            hexChars[j * 2 + 1] = hexArray[v and 0x0F]
        }
        return String(hexChars)
    }


}

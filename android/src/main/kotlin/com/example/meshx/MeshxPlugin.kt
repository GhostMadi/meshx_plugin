
package com.example.meshx

import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.UUID
import org.json.JSONObject

/** MeshxPlugin
 *  ВНИМАНИЕ: это заглушка. Реальная BLE-логика не реализована.
 */
class MeshxPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, EventChannel.StreamHandler {
  private lateinit var methodChannel : MethodChannel
  private lateinit var eventChannel : EventChannel
  private var eventsSink: EventChannel.EventSink? = null
  private val mainHandler = Handler(Looper.getMainLooper())

  private var initialized = false
  private var started = false

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    methodChannel = MethodChannel(binding.binaryMessenger, "meshx/methods")
    methodChannel.setMethodCallHandler(this)
    eventChannel = EventChannel(binding.binaryMessenger, "meshx/events")
    eventChannel.setStreamHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "initialize" -> {
        initialized = true
        result.success(null)
      }
      "start" -> {
        if (!initialized) { result.error("notInitialized", "Call initialize() first", null); return }
        started = true
        result.success(null)
        // emit a fake peer discovered after short delay
        mainHandler.postDelayed({
          eventsSink?.success(mapOf(
            "type" to "peerDiscovered",
            "data" to mapOf("id" to "peer-android-demo", "rssi" to -55, "lastSeen" to System.currentTimeMillis(), "connected" to true)
          ))
        }, 500)
      }
      "stop" -> {
        started = false
        result.success(null)
      }
      "sendBytes" -> {
        val id = UUID.randomUUID().toString()
        // echo success
        eventsSink?.success(mapOf(
          "type" to "messageSent",
          "data" to mapOf("id" to id, "toPeerId" to (call.argument<String>("toPeerId")), "mode" to (call.argument<Int>("mode") ?: 1), "qos" to (call.argument<Int>("qos") ?: 1), "retries" to 0)
        ))
        result.success(id)
        // simulate receive (loopback)
        mainHandler.postDelayed({
          eventsSink?.success(mapOf(
            "type" to "messageReceived",
            "data" to mapOf(
              "id" to id,
              "fromPeerId" to "peer-android-demo",
              "mode" to (call.argument<Int>("mode") ?: 1),
              "hopCount" to 0,
              "ttl" to (call.argument<Int>("ttl") ?: 4),
              "payload" to mapOf("type" to "bytes", "data" to (call.argument<ByteArray>("data")?.toList() ?: emptyList<Int>())),
              "receivedAt" to System.currentTimeMillis(),
              "meta" to mapOf<String, Any>()
            )
          ))
        }, 400)
      }
      "sendJson" -> {
        val id = UUID.randomUUID().toString()
        eventsSink?.success(mapOf(
          "type" to "messageSent",
          "data" to mapOf("id" to id, "toPeerId" to (call.argument<String>("toPeerId")), "mode" to (call.argument<Int>("mode") ?: 1), "qos" to (call.argument<Int>("qos") ?: 1), "retries" to 0)
        ))
        result.success(id)
        mainHandler.postDelayed({
          @Suppress("UNCHECKED_CAST")
          val json = call.argument<Map<String, Any?>>("json") ?: emptyMap()
          eventsSink?.success(mapOf(
            "type" to "messageReceived",
            "data" to mapOf(
              "id" to id,
              "fromPeerId" to "peer-android-demo",
              "mode" to (call.argument<Int>("mode") ?: 1),
              "hopCount" to 0,
              "ttl" to (call.argument<Int>("ttl") ?: 4),
              "payload" to mapOf("type" to "json", "data" to json),
              "receivedAt" to System.currentTimeMillis(),
              "meta" to mapOf<String, Any>()
            )
          ))
        }, 400)
      }
      "sendFile" -> {
        val id = UUID.randomUUID().toString()
        result.success(id)
      }
      "getConnectedPeers" -> {
        result.success(listOf(mapOf("id" to "peer-android-demo", "rssi" to -55, "lastSeen" to System.currentTimeMillis(), "connected" to true)))
      }
      "getStats" -> {
        result.success(mapOf("sent" to 1, "delivered" to 1, "relayed" to 0, "failed" to 0, "avgHop" to 0.0))
      }
      "updateLicenseKey" -> {
        result.success(null)
      }
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    methodChannel.setMethodCallHandler(null)
    eventChannel.setStreamHandler(null)
  }

  override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
    eventsSink = events
  }

  override fun onCancel(arguments: Any?) {
    eventsSink = null
  }
}

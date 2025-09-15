
import Flutter
import UIKit

public class MeshxPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?
  private var initialized: Bool = false
  private var started: Bool = false

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "meshx/methods", binaryMessenger: registrar.messenger())
    let instance = MeshxPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)

    let eventChannel = FlutterEventChannel(name: "meshx/events", binaryMessenger: registrar.messenger())
    eventChannel.setStreamHandler(instance)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
      case "initialize":
        initialized = true
        result(nil)
      case "start":
        guard initialized else { result(FlutterError(code: "notInitialized", message: "Call initialize() first", details: nil)); return }
        started = true
        result(nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          self.eventSink?([
            "type": "peerDiscovered",
            "data": ["id": "peer-ios-demo", "rssi": -60, "lastSeen": Int(Date().timeIntervalSince1970 * 1000), "connected": true]
          ])
        }
      case "stop":
        started = false
        result(nil)
      case "sendBytes":
        let id = UUID().uuidString
        self.eventSink?([
          "type": "messageSent",
          "data": ["id": id, "toPeerId": (call.arguments as? [String: Any])?["toPeerId"] as? String ?? NSNull(), "mode": (call.arguments as? [String: Any])?["mode"] as? Int ?? 1, "qos": (call.arguments as? [String: Any])?["qos"] as? Int ?? 1, "retries": 0]
        ])
        result(id)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
          let args = call.arguments as? [String: Any]
          let data = args?["data"] as? FlutterStandardTypedData
          self.eventSink?([
            "type": "messageReceived",
            "data": [
              "id": id,
              "fromPeerId": "peer-ios-demo",
              "mode": args?["mode"] as? Int ?? 1,
              "hopCount": 0,
              "ttl": args?["ttl"] as? Int ?? 4,
              "payload": ["type": "bytes", "data": data?.data.map { Int($0) } ?? []],
              "receivedAt": Int(Date().timeIntervalSince1970 * 1000),
              "meta": [:]
            ]
          ])
        }
      case "sendJson":
        let id = UUID().uuidString
        self.eventSink?([
          "type": "messageSent",
          "data": ["id": id, "toPeerId": (call.arguments as? [String: Any])?["toPeerId"] as? String ?? NSNull(), "mode": (call.arguments as? [String: Any])?["mode"] as? Int ?? 1, "qos": (call.arguments as? [String: Any])?["qos"] as? Int ?? 1, "retries": 0]
        ])
        result(id)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
          let args = call.arguments as? [String: Any]
          let json = args?["json"] as? [String: Any] ?? [:]
          self.eventSink?([
            "type": "messageReceived",
            "data": [
              "id": id,
              "fromPeerId": "peer-ios-demo",
              "mode": args?["mode"] as? Int ?? 1,
              "hopCount": 0,
              "ttl": args?["ttl"] as? Int ?? 4,
              "payload": ["type": "json", "data": json],
              "receivedAt": Int(Date().timeIntervalSince1970 * 1000),
              "meta": [:]
            ]
          ])
        }
      case "sendFile":
        let id = UUID().uuidString
        result(id)
      case "getConnectedPeers":
        result([["id": "peer-ios-demo", "rssi": -60, "lastSeen": Int(Date().timeIntervalSince1970 * 1000), "connected": true]])
      case "getStats":
        result(["sent": 1, "delivered": 1, "relayed": 0, "failed": 0, "avgHop": 0.0])
      case "updateLicenseKey":
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
    }
  }

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.eventSink = events
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    self.eventSink = nil
    return nil
  }
}

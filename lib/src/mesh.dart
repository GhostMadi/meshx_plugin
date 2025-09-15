
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'config.dart';
import 'errors.dart';
import 'models.dart';
import 'payload.dart';
import 'stats.dart';

/// Главный входной класс API.
class Mesh {
  Mesh._();
  static final Mesh instance = Mesh._();

  static const MethodChannel _m = MethodChannel('meshx/methods');
  static const EventChannel _e = EventChannel('meshx/events');

  final _onMessageReceived = StreamController<IncomingMessage>.broadcast();
  final _onMessageSent = StreamController<MessageReport>.broadcast();
  final _onMessageFailed = StreamController<MessageReport>.broadcast();

  final _onPeerDiscovered = StreamController<Peer>.broadcast();
  final _onPeerLost = StreamController<Peer>.broadcast();
  final _onPeerConnected = StreamController<Peer>.broadcast();
  final _onPeerDisconnected = StreamController<Peer>.broadcast();

  final _onInitializationComplete = StreamController<void>.broadcast();
  final _onError = StreamController<MeshError>.broadcast();

  StreamSubscription? _eventsSub;

  bool _initialized = false;
 bool _started = false;

  String? _userId;
  PropagationProfile _profile = PropagationProfile.standard;
  MeshConfig _config = const MeshConfig();

  bool get isInitialized => _initialized;
  bool get isStarted => _started;

  String get currentUserId => _userId ?? 'unknown';

  // Streams
  Stream<IncomingMessage> get onMessageReceived => _onMessageReceived.stream;
  Stream<MessageReport> get onMessageSent => _onMessageSent.stream;
  Stream<MessageReport> get onMessageFailed => _onMessageFailed.stream;

  Stream<Peer> get onPeerDiscovered => _onPeerDiscovered.stream;
  Stream<Peer> get onPeerLost => _onPeerLost.stream;
  Stream<Peer> get onPeerConnected => _onPeerConnected.stream;
  Stream<Peer> get onPeerDisconnected => _onPeerDisconnected.stream;

  Stream<void> get onInitializationComplete => _onInitializationComplete.stream;
  Stream<MeshError> get onError => _onError.stream;

  Future<void> initialize({required String userId, PropagationProfile profile = PropagationProfile.standard, MeshConfig config = const MeshConfig()}) async {
    if (_initialized) {
      throw MeshError(MeshErrorCode.alreadyInitialized, 'Already initialized');
    }
    _userId = userId;
    _profile = profile;
    _config = config;

    _eventsSub = _e.receiveBroadcastStream().listen(_handleEvent, onError: (e) {
      _onError.add(MeshError(MeshErrorCode.internal, 'Event channel error', e));
    });

    await _m.invokeMethod('initialize', {
      'userId': userId,
      'profile': profile.index,
      'config': {
        'scanIntervalMs': config.scanInterval.inMilliseconds,
        'advertiseIntervalMs': config.advertiseInterval.inMilliseconds,
        'ttl': config.maxHopCount,
        'maxRetries': config.maxRetries,
        'ackTimeoutMs': config.ackTimeout.inMilliseconds,
        'defaultQoS': config.defaultQoS.index,
        'maxInflight': config.maxInflightMessages,
        'maxFragmentSize': config.maxFragmentSize,
        'enableEncryption': config.enableEncryption,
        'allowBackground': config.allowBackground,
      }
    });

    _initialized = true;
    _onInitializationComplete.add(null);
  }

  Future<void> start() async {
    _ensureInitialized();
    await _m.invokeMethod('start');
    _started = false;
  }

  Future<void> stop() async {
    if (!_initialized) return;
    await _m.invokeMethod('stop');
    _started = false;
  }

  Future<MessageId> sendBytes(Uint8List data, {DeliveryMode mode = DeliveryMode.mesh, String? toPeerId, QoS? qos, int? ttl}) async {
    _ensureStarted();
    final id = await _m.invokeMethod<String>('sendBytes', {
      'data': data,
      'mode': mode.index,
      'toPeerId': toPeerId,
      'qos': (qos ?? _config.defaultQoS).index,
      'ttl': ttl ?? _config.maxHopCount,
    });
    return MessageId(id ?? _genId());
  }

  Future<MessageId> sendJson(Map<String, Object?> json, {DeliveryMode mode = DeliveryMode.mesh, String? toPeerId, QoS? qos, int? ttl}) async {
    _ensureStarted();
    final id = await _m.invokeMethod<String>('sendJson', {
      'json': json,
      'mode': mode.index,
      'toPeerId': toPeerId,
      'qos': (qos ?? _config.defaultQoS).index,
      'ttl': ttl ?? _config.maxHopCount,
    });
    return MessageId(id ?? _genId());
  }

  Future<MessageId> sendFile(String path, {required String name, required int size, DeliveryMode mode = DeliveryMode.mesh, String? toPeerId, QoS? qos, int? ttl}) async {
    _ensureStarted();
    final id = await _m.invokeMethod<String>('sendFile', {
      'name': name,
      'size': size,
      'path': path,
      'mode': mode.index,
      'toPeerId': toPeerId,
      'qos': (qos ?? _config.defaultQoS).index,
      'ttl': ttl ?? _config.maxHopCount,
    });
    return MessageId(id ?? _genId());
  }

  Future<List<Peer>> getConnectedPeers() async {
    _ensureInitialized();
    final list = await _m.invokeMethod<List>('getConnectedPeers');
    return (list ?? const []).cast<Map>().map((e) => Peer.fromMap(e)).toList();
  }

  Future<MeshStats> getStats() async {
    _ensureInitialized();
    final map = await _m.invokeMethod<Map>('getStats');
    return MeshStats.fromMap((map ?? const {}));
  }

  Future<void> updateLicenseKey(String newKey) async {
    _ensureInitialized();
    await _m.invokeMethod('updateLicenseKey', {'key': newKey});
  }

  void dispose() {
    _eventsSub?.cancel();
    _onMessageReceived.close();
    _onMessageSent.close();
    _onMessageFailed.close();
    _onPeerDiscovered.close();
    _onPeerLost.close();
    _onPeerConnected.close();
    _onPeerDisconnected.close();
    _onInitializationComplete.close();
    _onError.close();
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw MeshError(MeshErrorCode.notInitialized, 'Mesh is not initialized');
    }
  }

  void _ensureStarted() {
    _ensureInitialized();
    if (!_started) {
      throw MeshError(MeshErrorCode.notStarted, 'Mesh is not started');
    }
  }

  void _handleEvent(dynamic event) {
    if (event is Map) {
      final type = event['type'] as String? ?? '';
      switch (type) {
        case 'messageReceived':
          _onMessageReceived.add(IncomingMessage.fromMap(event['data'] as Map));
          break;
        case 'messageSent':
          _onMessageSent.add(MessageReport.fromMap(event['data'] as Map));
          break;
        case 'messageFailed':
          _onMessageFailed.add(MessageReport.fromMap(event['data'] as Map));
          break;
        case 'peerDiscovered':
          _onPeerDiscovered.add(Peer.fromMap(event['data'] as Map));
          break;
        case 'peerLost':
          _onPeerLost.add(Peer.fromMap(event['data'] as Map));
          break;
        case 'peerConnected':
          _onPeerConnected.add(Peer.fromMap(event['data'] as Map));
          break;
        case 'peerDisconnected':
          _onPeerDisconnected.add(Peer.fromMap(event['data'] as Map));
          break;
        case 'error':
          _onError.add(MeshError(MeshErrorCode.internal, (event['message'] as String?) ?? 'Unknown error'));
          break;
      }
    }
  }

  String _genId() {
    const chars = 'abcdef0123456789';
    final r = Random();
    String part(int n) => String.fromCharCodes(Iterable.generate(n, (_) => chars.codeUnitAt(r.nextInt(chars.length))));
    return '${part(8)}-${part(4)}-${part(4)}-${part(4)}-${part(12)}';
  }
}

/// Небольшой трюк, чтобы иметь изменяемое bool внутренняя реализация.
class FalseBool {
  bool value;
  FalseBool._(this.value);
  static final falseValue = FalseBool._(false);
  static final trueValue = FalseBool._(true);
}


import 'dart:typed_data';
import 'package:meta/meta.dart';
import 'config.dart';
import 'payload.dart';

@immutable
class Peer {
  final String id;
  final int? rssi;
  final DateTime lastSeen;
  final bool connected;

  const Peer({required this.id, this.rssi, required this.lastSeen, required this.connected});

  factory Peer.fromMap(Map data) => Peer(
        id: data['id'] as String,
        rssi: data['rssi'] as int?,
        lastSeen: DateTime.fromMillisecondsSinceEpoch((data['lastSeen'] ?? DateTime.now().millisecondsSinceEpoch) as int),
        connected: (data['connected'] ?? false) as bool,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'rssi': rssi,
        'lastSeen': lastSeen.millisecondsSinceEpoch,
        'connected': connected,
      };
}

@immutable
class MessageId {
  final String value;
  const MessageId(this.value);
}

@immutable
class MessageReport {
  final MessageId id;
  final String? toPeerId;
  final DeliveryMode mode;
  final QoS qos;
  final int? retries;

  const MessageReport({required this.id, this.toPeerId, required this.mode, required this.qos, this.retries});

  factory MessageReport.fromMap(Map m) => MessageReport(
        id: MessageId(m['id'] as String),
        toPeerId: m['toPeerId'] as String?,
        mode: DeliveryMode.values[m['mode'] as int],
        qos: QoS.values[m['qos'] as int],
        retries: m['retries'] as int?,
      );
}

@immutable
class IncomingMessage {
  final MessageId id;
  final String fromPeerId;
  final DeliveryMode mode;
  final int hopCount;
  final int ttl;
  final Payload payload;
  final DateTime receivedAt;
  final Map<String, Object?>? meta;

  const IncomingMessage({
    required this.id,
    required this.fromPeerId,
    required this.mode,
    required this.hopCount,
    required this.ttl,
    required this.payload,
    required this.receivedAt,
    this.meta,
  });

  factory IncomingMessage.fromMap(Map m) => IncomingMessage(
        id: MessageId(m['id'] as String),
        fromPeerId: m['fromPeerId'] as String,
        mode: DeliveryMode.values[m['mode'] as int],
        hopCount: (m['hopCount'] ?? 0) as int,
        ttl: (m['ttl'] ?? 0) as int,
        payload: Payload.fromMap(m['payload'] as Map),
        receivedAt: DateTime.fromMillisecondsSinceEpoch((m['receivedAt'] ?? DateTime.now().millisecondsSinceEpoch) as int),
        meta: (m['meta'] as Map?)?.cast<String, Object?>(),
      );
}


import 'package:meta/meta.dart';

/// Уровень гарантии доставки.
enum QoS { atMostOnce, atLeastOnce, exactlyOnce }

/// Режим доставки сообщения.
enum DeliveryMode { p2p, mesh, broadcast }

/// Профили распространения (влияют на интервалы, мощность и политики ретрансляций).
enum PropagationProfile { standard, highDensityNetwork, sparseNetwork, longReach, shortReach }

@immutable
class MeshConfig {
  final Duration scanInterval;
  final Duration advertiseInterval;
  final int maxHopCount; // TTL
  final int maxRetries;
  final Duration ackTimeout;
  final QoS defaultQoS;
  final int maxInflightMessages;
  final int maxFragmentSize;
  final bool enableEncryption;
  final bool allowBackground;

  const MeshConfig({
    this.scanInterval = const Duration(milliseconds: 600),
    this.advertiseInterval = const Duration(milliseconds: 600),
    this.maxHopCount = 4,
    this.maxRetries = 3,
    this.ackTimeout = const Duration(seconds: 3),
    this.defaultQoS = QoS.atLeastOnce,
    this.maxInflightMessages = 16,
    this.maxFragmentSize = 180,
    this.enableEncryption = true,
    this.allowBackground = true,
  });

  MeshConfig copyWith({
    Duration? scanInterval,
    Duration? advertiseInterval,
    int? maxHopCount,
    int? maxRetries,
    Duration? ackTimeout,
    QoS? defaultQoS,
    int? maxInflightMessages,
    int? maxFragmentSize,
    bool? enableEncryption,
    bool? allowBackground,
  }) {
    return MeshConfig(
      scanInterval: scanInterval ?? this.scanInterval,
      advertiseInterval: advertiseInterval ?? this.advertiseInterval,
      maxHopCount: maxHopCount ?? this.maxHopCount,
      maxRetries: maxRetries ?? this.maxRetries,
      ackTimeout: ackTimeout ?? this.ackTimeout,
      defaultQoS: defaultQoS ?? this.defaultQoS,
      maxInflightMessages: maxInflightMessages ?? this.maxInflightMessages,
      maxFragmentSize: maxFragmentSize ?? this.maxFragmentSize,
      enableEncryption: enableEncryption ?? this.enableEncryption,
      allowBackground: allowBackground ?? this.allowBackground,
    );
  }
}

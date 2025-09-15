
class MeshStats {
  final int sent;
  final int delivered;
  final int relayed;
  final int failed;
  final double avgHop;

  const MeshStats({this.sent = 0, this.delivered = 0, this.relayed = 0, this.failed = 0, this.avgHop = 0});

  factory MeshStats.fromMap(Map m) => MeshStats(
        sent: (m['sent'] ?? 0) as int,
        delivered: (m['delivered'] ?? 0) as int,
        relayed: (m['relayed'] ?? 0) as int,
        failed: (m['failed'] ?? 0) as int,
        avgHop: ((m['avgHop'] ?? 0.0) as num).toDouble(),
      );

  Map<String, Object?> toMap() => {
        'sent': sent,
        'delivered': delivered,
        'relayed': relayed,
        'failed': failed,
        'avgHop': avgHop,
      };
}

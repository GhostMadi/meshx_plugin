
class MeshError implements Exception {
  final MeshErrorCode code;
  final String message;
  final Object? cause;
  MeshError(this.code, this.message, [this.cause]);
  @override
  String toString() => 'MeshError($code): $message';
}

enum MeshErrorCode {
  notInitialized,
  alreadyInitialized,
  notStarted,
  permissionDenied,
  bluetoothOff,
  incompatibleDevice,
  payloadTooLarge,
  timeout,
  noRoute,
  queueOverflow,
  licenseInvalid,
  internal,
}


import 'dart:convert';
import 'dart:typed_data';

sealed class Payload {
  const Payload();
  Map<String, Object?> toMap();
  static Payload fromMap(Map m) {
    final type = m['type'] as String;
    switch (type) {
      case 'bytes':
        return BytesPayload(Uint8List.fromList(List<int>.from(m['data'] as List)));
      case 'json':
        return JsonPayload(Map<String, Object?>.from(m['data'] as Map));
      case 'file':
        return FilePayload(name: m['name'] as String, size: m['size'] as int, path: m['path'] as String);
      default:
        throw ArgumentError('Unknown payload type: $type');
    }
  }
}

class BytesPayload extends Payload {
  final Uint8List data;
  const BytesPayload(this.data);
  @override
  Map<String, Object?> toMap() => {'type': 'bytes', 'data': data};
  @override
  String toString() => 'BytesPayload(${data.length} bytes)';
}

class JsonPayload extends Payload {
  final Map<String, Object?> json;
  const JsonPayload(this.json);
  @override
  Map<String, Object?> toMap() => {'type': 'json', 'data': json};
  @override
  String toString() => 'JsonPayload(${jsonEncode(json)})';
}

class FilePayload extends Payload {
  final String name;
  final int size;
  final String path; // простая модель — путь к локальному файлу
  const FilePayload({required this.name, required this.size, required this.path});
  @override
  Map<String, Object?> toMap() => {'type': 'file', 'name': name, 'size': size, 'path': path};
  @override
  String toString() => 'FilePayload($name, $size bytes)';
}

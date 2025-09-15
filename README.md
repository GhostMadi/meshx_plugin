
# meshx (prototype)

**meshx** — прототип Flutter-плагина для офлайн-связи в стиле Bridgefy. 
Этот пакет предоставляет удобный Dart-API (Streams/Callbacks, QoS, режимы доставки), 
а также заготовки (stubs) для нативных слоёв Android/iOS. Реальная BLE-меш 
реализация помечена TODO и должна быть доработана.

> ⚠️ **Важно:** текущая версия *не* содержит полноценной реализации BLE mesh. 
> Это каркас с корректным API, событиями, платформенными каналами и примером. 
> Используйте как стартовую точку под ТЗ.

## Быстрый старт

```dart
final mesh = Mesh.instance;
await mesh.initialize(userId: 'user-123', profile: PropagationProfile.standard);
await mesh.start();

final sub = mesh.onMessageReceived.listen((msg) {
  print('from: ${msg.fromPeerId}, payload: ${msg.payload}');
});

final id = await mesh.sendJson({'type': 'ping'}, mode: DeliveryMode.broadcast);
print('sent id: ${id.value}');
```

## Статус
- ✅ Dart-API (инициализация, start/stop, sendBytes/Json/File, события, модели)
- ✅ Профили распространения (интерфейс)
- ✅ QoS интерфейсы, TTL, статистика
- ✅ Android/iOS плагины — заглушки с платформенными каналами
- ✅ Пример-приложение
- ⏳ Реальная BLE логика (CoreBluetooth/Android BLE) — TODO

## Лицензия
MIT

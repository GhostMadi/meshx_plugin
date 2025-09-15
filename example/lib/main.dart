
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:meshx/meshx.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final mesh = Mesh.instance;
  final messages = <String>[];
  StreamSubscription? sub;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await mesh.initialize(userId: 'user-demo', profile: PropagationProfile.standard);
    await mesh.start();
    sub = mesh.onMessageReceived.listen((m) {
      setState(() {
        messages.add('from ${m.fromPeerId}: ${m.payload}');
      });
    });
  }

  @override
  void dispose() {
    sub?.cancel();
    mesh.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('meshx demo')),
        body: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                final id = await mesh.sendJson({'type': 'ping', 'ts': DateTime.now().toIso8601String()}, mode: DeliveryMode.broadcast);
                setState(() => messages.add('sent id: ${id.value}'));
              },
              child: const Text('Broadcast ping'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (_, i) => ListTile(title: Text(messages[i])),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

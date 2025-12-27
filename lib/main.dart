import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stream Counter GitHub',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const StreamCounterPage(),
    );
  }
}

class StreamCounterPage extends StatefulWidget {
  const StreamCounterPage({super.key});

  @override
  State<StreamCounterPage> createState() => _StreamCounterPageState();
}

class _StreamCounterPageState extends State<StreamCounterPage> {
  // 1. تعريف الـ StreamController لإدارة العداد
  late StreamController<int> _counterController;

  // تعريف المؤقت (Timer) والعداد
  Timer? _timer;
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    // تهيئة الـ Controller
    _counterController = StreamController<int>();
  }

  // دالة لبدء العداد
  void _startCounter() {
    // التأكد من عدم وجود تايمر يعمل حالياً
    if (_timer != null && _timer!.isActive) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _counter++;
      // إرسال الرقم الجديد داخل الـ Stream
      _counterController.sink.add(_counter);
    });
  }

  // دالة لإيقاف العداد
  void _stopCounter() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    // إغلاق الـ Stream والتايمر عند مسح الصفحة من الذاكرة (مهم جداً)
    _timer?.cancel();
    _counterController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stream Counter App'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('العد الحالي:', style: TextStyle(fontSize: 20)),
            // 2. استخدام StreamBuilder للاستماع للبيانات وتحديث الواجهة تلقائياً
            StreamBuilder<int>(
              stream: _counterController.stream,
              initialData: 0,
              builder: (context, snapshot) {
                return Text(
                  '${snapshot.data}',
                  style: const TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _startCounter,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: _stopCounter,
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

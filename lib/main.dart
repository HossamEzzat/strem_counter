import 'dart:async';

import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: StreamChallengePage()));

class StreamChallengePage extends StatefulWidget {
  const StreamChallengePage({super.key});

  @override
  State<StreamChallengePage> createState() => _StreamChallengePageState();
}

class _StreamChallengePageState extends State<StreamChallengePage> {
  // تعريف الـ Controller والعداد
  StreamController<int> _controller = StreamController<int>();
  bool _isRunning = false;

  void startChallenge() async {
    if (_isRunning) return; // منع البدء إذا كان يعمل بالفعل

    setState(() {
      _isRunning = true;
      // إعادة إنشاء Controller جديد إذا كان القديم أُغلق
      if (_controller.isClosed) {
        _controller = StreamController<int>();
      }
    });

    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(seconds: 1));

      if (_controller.isClosed) break;

      // التحدي 1: الخطأ عند رقم 7
      if (i == 7) {
        _controller.sink.addError("أوبس! خطأ عند رقم 7 ⚠️");
      } else {
        _controller.sink.add(i);
      }

      // التحدي 2: الإغلاق التلقائي عند رقم 10
      if (i == 10) {
        await _controller.close();
        setState(() => _isRunning = false);
      }
    }
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Stream Challenge")),
      body: Center(
        child: StreamBuilder<int>(
          stream: _controller.stream,
          builder: (context, snapshot) {
            // ترتيب الحالات مهم جداً:

            // 1. حالة الخطأ
            if (snapshot.hasError) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${snapshot.error}",
                    style: const TextStyle(color: Colors.red, fontSize: 22),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text("إعادة"),
                  ),
                ],
              );
            }

            // 2. حالة الانتهاء
            if (snapshot.connectionState == ConnectionState.done) {
              return const Text(
                "تم العد لـ 10 واغلقنا الـ Stream ✅",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.green, fontSize: 24),
              );
            }

            // 3. حالة استقبال البيانات
            if (snapshot.hasData) {
              return Text(
                "${snapshot.data}",
                style: const TextStyle(fontSize: 90),
              );
            }

            // 4. الحالة الابتدائية
            return const Text("اضغط Start للبدء بالعد");
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isRunning ? null : startChallenge,
        backgroundColor: _isRunning ? Colors.grey : Colors.blue,
        child: const Icon(Icons.play_arrow),
      ),
    );
  }
}

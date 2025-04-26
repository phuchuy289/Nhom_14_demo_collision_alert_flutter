import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(home: CollisionWarningApp()));
}

class CollisionWarningApp extends StatefulWidget {
  const CollisionWarningApp({super.key});

  @override
  State<CollisionWarningApp> createState() => _CollisionWarningAppState();
}

class _CollisionWarningAppState extends State<CollisionWarningApp> {
  double x1 = 50;
  double y1 = 50;
  double x2 = 250;
  double y2 = 250;
  double dx1 = 0, dy1 = 0;
  double dx2 = 0, dy2 = 0;

  bool isRed = false;
  bool isWarning = false;
  bool isMoving = false;

  Timer? _moveTimer;
  Timer? _directionTimer;
  Timer? _blinkTimer;

  final double carSize = 20; // kích thước xe
  final double warningDistance = 50; // khoảng cách cảnh báo
  final double screenLimit = 300; // giới hạn màn hình

  @override
  void dispose() {
    _moveTimer?.cancel();
    _directionTimer?.cancel();
    _blinkTimer?.cancel();
    super.dispose();
  }

  void startMovingBothCars() {
    if (isMoving) return;
    isMoving = true;

    // Đổi hướng mỗi 3 giây
    _directionTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      setState(() {
        dx1 = Random().nextInt(11) - 5; // -3..3
        dy1 = Random().nextInt(11) - 5;
        dx2 = Random().nextInt(11) - 5;
        dy2 = Random().nextInt(11) - 5;
      });
    });

    // Di chuyển mỗi 50ms
    _moveTimer = Timer.periodic(const Duration(milliseconds: 35), (_) {
      setState(() {
        double speedMultiplier = 1.0;
        if (isWarning) {
          speedMultiplier = 0.3; // Khi cảnh báo thì xe 1 đi chậm lại
        }

        x1 += dx1 * speedMultiplier;
        y1 += dy1 * speedMultiplier;
        x2 += dx2;
        y2 += dy2;

        // Kiểm tra chạm tường và đổi hướng cho xe 1
        if (x1 <= 0 || x1 >= screenLimit) dx1 = -dx1;
        if (y1 <= 0 || y1 >= screenLimit) dy1 = -dy1;

        // Kiểm tra chạm tường và đổi hướng cho xe 2
        if (x2 <= 0 || x2 >= screenLimit) dx2 = -dx2;
        if (y2 <= 0 || y2 >= screenLimit) dy2 = -dy2;

        x1 = x1.clamp(0, screenLimit);
        y1 = y1.clamp(0, screenLimit);
        x2 = x2.clamp(0, screenLimit);
        y2 = y2.clamp(0, screenLimit);

        checkWarning();
      });
    });
  }

  void checkWarning() {
    double distance = sqrt(pow(x1 - x2, 2) + pow(y1 - y2, 2));

    if (distance <= warningDistance && !isWarning) {
      startBlinking();
      isWarning = true;
    } else if (distance > warningDistance && isWarning) {
      stopBlinking();
      isWarning = false;
    }
  }

  void startBlinking() {
    _blinkTimer?.cancel();
    _blinkTimer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      setState(() {
        isRed = !isRed;
      });
    });
  }

  void stopBlinking() {
    _blinkTimer?.cancel();
    setState(() {
      isRed = false;
    });
  }

  void resetGame() {
    _moveTimer?.cancel();
    _directionTimer?.cancel();
    _blinkTimer?.cancel();
    isMoving = false;

    setState(() {
      x1 = 50;
      y1 = 50;
      x2 = 250;
      y2 = 250;
      dx1 = 0;
      dy1 = 0;
      dx2 = 0;
      dy2 = 0;
      isRed = false;
      isWarning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Collision Warning App')),
      body: Center(
        child: SizedBox(
          width: screenLimit + carSize,
          height: screenLimit + carSize,
          child: Stack(
            children: [
              Positioned(
                left: x1,
                top: y1,
                child: Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: isRed ? Colors.red : Colors.blue,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Positioned(
                left: x2,
                top: y2,
                child: Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: startMovingBothCars,
              child: const Text('Bắt đầu'),
            ),
            ElevatedButton(onPressed: resetGame, child: const Text('Reset')),
          ],
        ),
      ),
    );
  }
}

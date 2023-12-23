import 'dart:async';
import 'dart:ui';

import 'package:tarea_flutter/SettingsScreen.dart';

class Time {
  
  static Future<void> waitForSeconds(int seconds) async {
    await Future.delayed(Duration(seconds: seconds));
  }

  Timer? timer;

  int seconds = 0;
  int minutes = 0;
  int timeLimit = 0;
  double progress = 0;
  VoidCallback? onUpdate;

  void startTimer(VoidCallback updateCallback) {
    onUpdate = updateCallback;
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => timeStepUpdate());
  }

  void timeStepUpdate() {
    seconds++;
    if (seconds == 60) {
      minutes++;
      seconds = 0;
    }
    progress = updateProgress();
    onUpdate?.call(); 
  }

  void startIntervalTimer(int timeInterval, VoidCallback function) {
    timer = Timer.periodic(Duration(seconds: timeInterval), (Timer t) => function());
  }

  void stopTimer() {
    timer?.cancel();
  }

  String getParsedCurrentTime() {
    return seconds > 9 ? "0$minutes:$seconds" : "0$minutes:0$seconds";
  }

  double updateProgress() {
    timeLimit = currentSettings?.timeLimit ?? 60;
    if (timeLimit == 0) return 0.0;
    progress = seconds / timeLimit;
    if (progress == 1) return -1.0;
    
    return progress;
  }
}
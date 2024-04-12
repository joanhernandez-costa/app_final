import 'dart:async';
import 'dart:ui';

class TimeService {
  
  static Future<void> waitForSeconds(int seconds) async {
    await Future.delayed(Duration(seconds: seconds));
  }

  Timer? timer;
  bool isPaused = false;

  int seconds = 0;
  int minutes = 0;
  
  VoidCallback? onUpdate;
  VoidCallback? onTimeChange;

  void startTimer(VoidCallback? updateCallback) {
    onUpdate = updateCallback;
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => timeStepUpdate());
  }

  void timeStepUpdate() {
    seconds++;
    if (seconds == 60) {
      minutes++;
      seconds = 0;
    }

    if (onUpdate != null) onUpdate!.call();
    if (onTimeChange != null) onTimeChange!.call();
  }

  void startIntervalTimer(int timeInterval, VoidCallback function) {
    timer = Timer.periodic(Duration(seconds: timeInterval), (Timer t) => function());
  }

  void stopTimer() {
    seconds = 0;
    minutes = 0;
    timer?.cancel();
  }

  String getParsedCurrentTime() {
    return seconds > 9 ? "0$minutes:$seconds" : "0$minutes:0$seconds";
  }

  void pauseTimer() {
    if (timer != null && timer!.isActive) {
      timer!.cancel();
      isPaused = true;
    }
  }

  void resumeTimer() {
    if (isPaused) {
      startTimer(onUpdate!);
      isPaused = false;
    }
  }

}
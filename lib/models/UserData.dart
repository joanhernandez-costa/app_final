
import 'package:app_final/services/ApiService.dart';

class UserData {
  String user_data_id;
  String user_id;
  Duration averageDailyUsage;
  DateTime lastLogin;
  int numberOfSessions;
  DateTime createdAt; 
  Duration averageSessionDuration;
  AppSession? currentSession;
  
  UserData({
    required this.user_data_id,
    required this.user_id,
    required this.averageDailyUsage,
    required this.lastLogin,
    required this.numberOfSessions,
    required this.createdAt,
    required this.averageSessionDuration,
  });

  static Map<String, dynamic> toJson(UserData userData) {
    return {
      'user_data_id': userData.user_data_id,
      'user_id': userData.user_id,
      'average_daily_usage': userData.averageDailyUsage.toString(),
      'last_login': userData.lastLogin.toIso8601String(),
      'number_of_sessions': userData.numberOfSessions,
      'created_at': userData.createdAt.toIso8601String(),
      'average_session_duration': userData.averageSessionDuration.toString()
    };
  }

  static UserData fromJson(Map<String, dynamic> json) {
    return UserData(
      user_data_id: json['user_data_id'],
      user_id: json['user_id'],
      averageDailyUsage: Duration(minutes: int.parse(json['average_daily_usage'])), 
      lastLogin: DateTime.parse(json['last_login']), 
      numberOfSessions: json['number_of_sessions'], 
      createdAt: DateTime.parse(json['created_at']),
      averageSessionDuration: Duration(minutes: int.parse(json['average_session_duration'])),
    );
  }

  void startSession() {
    currentSession = AppSession(loginTime: DateTime.now());
    numberOfSessions++;
  }

  void endSession() {
    if (currentSession != null) {
      currentSession!.logoutTime = DateTime.now();
      print('Hora de login: ${currentSession!.loginTime!}');
      print('Hora de logout: ${currentSession!.logoutTime!}');
      updateSessionInfo();
    }
  }
  
  void updateSessionInfo() {
    if (currentSession?.loginTime != null && currentSession?.logoutTime != null) {
      DateTime now = DateTime.now();

      Duration currentSessionDuration = currentSession!.logoutTime!.difference(currentSession!.loginTime!);

      // Actualizar la duración media de las sesiones
      int totalSessions = numberOfSessions - 1;
      totalSessions = totalSessions == 0 ? 1 : totalSessions;
      averageSessionDuration = ((averageSessionDuration * totalSessions) + currentSessionDuration) ~/ numberOfSessions;

      // Calcular tiempo medio de uso diario
      int totalDays = now.difference(createdAt).inDays + 1;
      Duration totalUsage = averageSessionDuration * numberOfSessions;
      averageDailyUsage = Duration(minutes: totalUsage.inMinutes ~/ totalDays);

      // Guardar los cambios en la base de datos
      update();
    }
  }

  Future<void> update() async {
    await ApiService.updateItem(this, user_data_id);
  }
}

class AppSession {
  DateTime? loginTime;
  DateTime? logoutTime;

  AppSession({this.loginTime, this.logoutTime});
}
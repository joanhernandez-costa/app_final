import 'package:app_final/ApiCalls.dart';
import 'package:app_final/SaveLoad.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum UserState { loggedIn, loggedOut }

class AppUser {
  String userName;
  String mail;
  String password;
  String id;
  String? profileImageUrl;

  AppUser({
    required this.userName,
    required this.mail,
    required this.password,
    required this.id,
    required this.profileImageUrl,
  });
  
  UserState? userState;

  static List<AppUser> registeredUsers = [];
  static ValueNotifier<AppUser?> currentUser = ValueNotifier<AppUser?>(null);

  static Future<void> initSupabaseListeners() async {
    final supabaseClient = Supabase.instance.client;

    supabaseClient.auth.onAuthStateChange.listen((data) async {
      switch (data.event) {
        case AuthChangeEvent.signedIn:
          await handleSignIn(data.session);
          break;
        case AuthChangeEvent.signedOut:
          await handleSignOut();
          break;
        case AuthChangeEvent.initialSession:
          await handleInitialSession(data.session);
          break;
        case AuthChangeEvent.userDeleted:
          await handleDeletedUser(data.session);
          break;
        case AuthChangeEvent.userUpdated:
          // Esperar a que el usuario verifique su dirección de correo electrónico, después, mostrar HomeScreen()
        default:
          break;
      }
    });
  }

  static Future<void> handleSignIn(Session? session) async {
    if (session != null) {
      ApiCalls.userToken = session.accessToken;
      currentUser.value = await ApiCalls.getItem<AppUser>(session.user.id, fromJson);
    }
  }

  static Future<void> handleInitialSession(Session? session) async {
    if (session != null) {
      ApiCalls.userToken = session.accessToken;
      //currentUser.value = await ApiCalls.getItem<AppUser>(session.user.id, fromJson);
    }
  }

  static Future<void> handleSignOut() async {
    if (currentUser.value != null) {
      await SaveLoad.saveGeneric('lastUser', currentUser.value!, toJson);
      currentUser.value = null;
      ApiCalls.userToken = null;
    }
  }

  static Future<void> handleDeletedUser(Session? session) async {
    if (session != null) {
      await ApiCalls.deleteItem(session.user.id);
    }
  }

  static void updateCurrentUser(AppUser updatedUser, String updatedUserId) async {
    await ApiCalls.updateElement<AppUser>(updatedUser, updatedUserId);
    currentUser.value = updatedUser;
  }

  static Map<String, dynamic> toJson(AppUser user) {
    return {
      'userName': user.userName,
      'mail': user.mail,
      'password': user.password,
      'user_id': user.id,
      'profileImageUrl': user.profileImageUrl,
    };
  }
  
  static AppUser fromJson(Map<String, dynamic> json) {
    return AppUser(
      userName: json['userName'] as String,
      mail: json['mail'] as String,
      password: json['password'] as String,
      id: json['user_id'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
    );
  }
}

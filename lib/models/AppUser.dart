import 'package:app_final/services/ApiService.dart';
import 'package:app_final/services/StorageService.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
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
      if (data.session != null) {
        AppUser? userAfterEvent = registeredUsers.firstWhereOrNull(
          (user) => user.id == data.session!.user.id);        

        switch (data.event) {
          case AuthChangeEvent.signedIn:
            currentUser.value = userAfterEvent;
            print(toJson(userAfterEvent!));
            break;
          case AuthChangeEvent.initialSession:
            currentUser.value = userAfterEvent;
            print(toJson(userAfterEvent!));
            break;
          case AuthChangeEvent.userDeleted:
            await ApiService.deleteItem(userAfterEvent!.id);
            break;
          case AuthChangeEvent.signedOut:
            await handleSignOut();
            break;
          case AuthChangeEvent.userUpdated:
            await updateCurrentUser(userAfterEvent!);
            break;
          default:
            break;
        }
      }
    }); 
  }

  static Future<void> handleSignOut() async {
    await StorageService.saveGeneric('lastUser', currentUser.value!, toJson);
    currentUser.value = null;
    ApiService.userToken = null;
  }

  static Future<void> updateCurrentUser(AppUser updatedUser) async {
    await ApiService.updateElement<AppUser>(updatedUser, updatedUser.id);
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

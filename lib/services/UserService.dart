import 'package:app_final/models/AppUser.dart';
import 'package:app_final/models/UserData.dart';
import 'package:app_final/screens/HomeScreen.dart';
import 'package:app_final/screens/SignInScreen.dart';
import 'package:app_final/services/NavigationService.dart';
import 'package:collection/collection.dart';
import 'package:app_final/services/ApiService.dart';
import 'package:app_final/services/StorageService.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  static List<AppUser> registeredUsers = [];
  static ValueNotifier<AppUser?> currentUser = ValueNotifier<AppUser?>(null);

  static Future<void> initSupabaseListeners() async {
    final supabaseClient = Supabase.instance.client;

    supabaseClient.auth.onAuthStateChange.listen((data) async {
      if (data.session != null) {
        AppUser? userAfterEvent = registeredUsers.firstWhereOrNull(
          (user) => user.id == data.session!.user.id);
        if (!isAppUser(userAfterEvent)) return;

        UserData? userData = await ApiService.fromAppUser(userAfterEvent!.id!);
        userAfterEvent.userData = userData;
        if (userAfterEvent.userData == null) return;

        if (data.event == AuthChangeEvent.initialSession) {
          handleInitialSession(userAfterEvent, data.session!.accessToken);
        } else if (data.event == AuthChangeEvent.signedIn) {
          handleSignIn(userAfterEvent, data.session!.accessToken);
        } else if (data.event == AuthChangeEvent.userDeleted) {
          await ApiService.deleteItem(userAfterEvent.id!);
        } else if (data.event == AuthChangeEvent.signedOut) {
          await handleSignOut();
        } else if (data.event == AuthChangeEvent.userUpdated) {
          updateCurrentUser(userAfterEvent);
        } else if (data.event == AuthChangeEvent.tokenRefreshed) {
          ApiService.userToken = data.session!.accessToken;
        } else {
          print('AuthChangeEvent no reconocido.');
          return;
        }
      }
    }); 
  }

  static void handleInitialSession(AppUser initialUser, String userToken) {
    print('Iniciando sesión existente...');
    currentUser.value = initialUser;
    currentUser.value!.userData!.startSession();
    ApiService.userToken = userToken;

    NavigationService.replaceScreen(const HomeScreen());
  }

  static void handleSignIn(AppUser userSignedIn, String userToken) {
    print('Iniciando sesión...');
    currentUser.value = userSignedIn;
    currentUser.value!.userData!.startSession();
    ApiService.userToken = userToken;
    
    NavigationService.replaceScreen(const HomeScreen());
  }

  static Future<void> handleSignOut() async {
    print('Cerrando sesión...');
    currentUser.value!.userData!.endSession();
    await StorageService.saveGeneric('lastUser', currentUser.value!, AppUser.toJson);
    currentUser.value = null;
    ApiService.userToken = null;

    NavigationService.replaceScreen(const SignInScreen());
  }

  static Future<void> updateCurrentUser(AppUser updatedUser) async {
    await ApiService.updateItem<AppUser>(updatedUser, updatedUser.id!);
    currentUser.value = updatedUser;
  }

  static bool isAppUser(AppUser? user) {
    if (user == null) return false;
    return user.mail != null;
  }
}
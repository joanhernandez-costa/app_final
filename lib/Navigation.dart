import 'package:flutter/material.dart';

class Navigation {
  static void replaceScreen(BuildContext context, Widget newScreen) {
    removeScreen(context);
    showScreen(context, newScreen);
  }

  static void removeScreen(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  static void showScreen(BuildContext context, Widget newScreen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => newScreen),
    );
  }

  static void navigateTo(String routeName, BuildContext context, {Object? arguments}) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  static void replaceWithNamed(String routeName, BuildContext context, {Object? arguments}) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }

  static void popWithResult(BuildContext context, [Object? result]) {
    Navigator.pop(context, result);
  }

  static void clearStackAndShowScreen(BuildContext context, Widget newScreen) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => newScreen),
      (Route<dynamic> route) => false,
    );
  }

  static void showAnimatedScreen(BuildContext context, Widget newScreen, RouteTransitionsBuilder transitionBuilder) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => newScreen,
        transitionsBuilder: transitionBuilder,
      ),
    );
  }

  static Future<bool> confirmExit(BuildContext context, String message) async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sí'),
          ),
        ],
      ),
    )) ?? false;
  }
}
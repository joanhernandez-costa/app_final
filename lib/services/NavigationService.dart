import 'package:flutter/material.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // Quita la pantalla actual del árbol de Widgets y la sustituye por newScreen.
  static void replaceScreen(Widget newScreen) {
    navigatorKey.currentState
        ?.pushReplacement(MaterialPageRoute(builder: (context) => newScreen));
  }

  // Añade newScreen al árbol de Widgets, sin quitar el anterior.
  static void showScreen(Widget newScreen) {
    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (context) => newScreen),
    );
  }

  // Quita la pantalla actual e inicia la navegación a una nueva pantalla según su ruta
  static void replaceWithNamed(String routeName, {Object? arguments}) {
    navigatorKey.currentState
        ?.pushReplacementNamed(routeName, arguments: arguments);
  }

  // Restablece el árbol de widgets y muestra newScreen.
  static void clearStackAndShowScreen(String routeName, {Object? arguments}) {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(routeName, (_) => false,
        arguments: arguments);
  }

  // Abre una alerta y pide confirmación para salir.
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
        )) ??
        false;
  }
}

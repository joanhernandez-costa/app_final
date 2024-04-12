import 'package:app_final/services/ColorService.dart';
import 'package:flutter/material.dart';


abstract class ButtonFactory {
  Widget createButton(Widget child, VoidCallback onPressed);
}

ButtonStyle customButtonStyle(Color backgroundColor, Color foregroundColor) {
  return ButtonStyle(
    backgroundColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
      if (states.contains(MaterialState.hovered)) {
        return ColorService.changeLightness(backgroundColor, 0.85); // Más oscuro en hover
      } else if (states.contains(MaterialState.pressed)) {
        return ColorService.changeLightness(backgroundColor, 0.7); // Aún más oscuro cuando está presionado
      } else if (states.contains(MaterialState.error)) {
        return ColorService.error;
      }
      return backgroundColor; // Color normal
    }),
    foregroundColor: MaterialStateProperty.all<Color?>(foregroundColor),
  );
}

// Botón primario
class PrimaryButton extends ButtonFactory {
  @override
  Widget createButton(Widget child, VoidCallback onPressed) {
    return ElevatedButton(
      style: customButtonStyle(ColorService.primary, ColorService.textOnPrimary),
      onPressed: onPressed,
      child: Center(child: child),
    );
  }
}

// Botón secundario
class SecondaryButton extends ButtonFactory {
  @override
  Widget createButton(Widget child, VoidCallback onPressed) {
    return ElevatedButton(
      style: customButtonStyle(ColorService.textOnPrimary, ColorService.primary),
      onPressed: onPressed,
      child: Center(child: child),
    );
  }
}

// Botón de error
class ErrorButton extends ButtonFactory {
  @override
  Widget createButton(Widget child, VoidCallback onPressed) {
    return ElevatedButton(
      style: customButtonStyle(ColorService.error, ColorService.textOnError),
      onPressed: onPressed,
      child: Center(child: child),
    );
  }
}

// Botón de iconos
class IconButtonFactory extends ButtonFactory {
  @override
  Widget createButton(Widget child, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: customButtonStyle(ColorService.secondary, ColorService.textOnSecondary),
      child: Center(child: child), // Centrar el icono
    );
  }
}

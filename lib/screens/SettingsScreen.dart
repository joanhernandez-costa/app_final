import 'package:app_final/services/ThemeService.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_final/services/NavigationService.dart';

class SettingsScreen extends StatelessWidget {
  bool notificationEnabled = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: const Text('Paleta de Colores'),
            trailing: const Icon(Icons.palette),
            onTap: () => showColorThemeDialog(context),
          ),
          ListTile(
            title: const Text('Permisos de ubicación'),
            trailing: const Icon(Icons.location_on),
            onTap: () => showLocationPermissionDialog(context),
          ),
          ListTile(
            title: const Text('Precisión del sombreado'),
            trailing: const Icon(Icons.timeline),
            onTap: () => showShadowPrecisionDialog(context),
          ),
          ListTile(
            title: const Text('Ajustes de accesibilidad'),
            trailing: const Icon(Icons.accessibility_new),
            onTap: () => showAccessibilitySettingsDialog(context),
          ),
          ListTile(
            title: const Text('Activar notifiaciones'),
            trailing: Switch(
              value: notificationEnabled,
              onChanged: (value) => notificationEnabled = !value,
            ),
          )
        ],
      ),
    );
  }

  // Función para mostrar un diálogo de selección de tema
  void showColorThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Seleccionar tema"),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: ThemeService.availableThemes.keys.length,
              itemBuilder: (BuildContext context, int index) {
                String themeKey =
                    ThemeService.availableThemes.keys.elementAt(index);
                return RadioListTile<String>(
                  title: Text(themeKey),
                  value: themeKey,
                  groupValue: ThemeService.currentThemeKey,
                  onChanged: (String? value) {
                    if (value != null) {
                      ThemeService.switchTheme(value);
                      Navigator.of(context).pop();
                    }
                  },
                );
              },
            ),
          ),
          actions: <Widget>[
            FloatingActionButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  // Función para mostrar un diálogo de permisos de ubicación
  void showLocationPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Permisos de ubicación"),
          content: const Text(
              "Conceder o denegar permisos de ubicación a la aplicación."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Denegar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Conceder'),
            ),
          ],
        );
      },
    );
  }

  // Función para mostrar un diálogo de precisión del sombreado
  void showShadowPrecisionDialog(BuildContext context) {
    int selectedPrecision = 5; // Valor inicial de precisión
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Precisión del sombreado"),
          content: Container(
            width: double.maxFinite,
            child: Slider(
              value: selectedPrecision.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: selectedPrecision.toString(),
              onChanged: (double value) {
                selectedPrecision = value.toInt();
              },
            ),
          ),
          actions: <Widget>[
            FloatingActionButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  // Función para mostrar un diálogo de ajustes de accesibilidad
  void showAccessibilitySettingsDialog(BuildContext context) {
    double selectedFontSize = ThemeService.currentFontSize;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Ajustes de accesibilidad"),
          content: Container(
            width: double.maxFinite,
            child: Slider(
              value: selectedFontSize,
              min: 0.5,
              max: 2.0,
              divisions: 15,
              label: '${(selectedFontSize * 100).toInt().toString()}%',
              onChanged: (double value) {
                selectedFontSize = value;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                ThemeService.setFontSize(selectedFontSize);
                Navigator.of(context).pop();
              },
              child: const Text('Guardar'),
            ),
            FloatingActionButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    bool confirm = await NavigationService.confirmExit(
        context, '¿Estás seguro de que quieres cerrar sesión?');
    if (confirm) {
      await Supabase.instance.client.auth.signOut();
    }
  }
}

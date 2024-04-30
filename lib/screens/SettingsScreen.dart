import 'package:app_final/services/ThemeService.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_final/services/NavigationService.dart';

class SettingsScreen extends StatelessWidget {
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
          // Futuras configuraciones se pueden agregar aquí
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

  Future<void> _confirmSignOut(BuildContext context) async {
    bool confirm = await NavigationService.confirmExit(
        context, '¿Estás seguro de que quieres cerrar sesión?');
    if (confirm) {
      await Supabase.instance.client.auth.signOut();
    }
  }
}

import 'package:app_final/widgets/SettingsDialogs.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_final/services/NavigationService.dart';
import 'package:app_final/services/ThemeService.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationEnabled = true;
  int shadowPrecision = 5;
  double accessibilityFontSize = 100;
  bool locationPermissionGranted = true;

  List<Color> primaryColors = [
    ThemeService.currentTheme.primary,
    ThemeService.currentTheme.secondary,
    ThemeService.currentTheme.background,
    ThemeService.currentTheme.surface,
  ];

  void updatePrimaryColors() {
    setState(() {});
  }

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
            trailing: Row(
              children: primaryColors.map((color) {
                return Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(right: 8),
                  color: color,
                );
              }).toList(),
            ),
            onTap: () => showColorThemeDialog(context),
          ),
          ListTile(
            title: const Text('Permisos de ubicación'),
            trailing: Icon(
              locationPermissionGranted
                  ? Icons.location_on
                  : Icons.location_off,
              color: locationPermissionGranted
                  ? ThemeService.currentTheme.primary
                  : ThemeService.currentTheme.secondary,
            ),
            onTap: () => showLocationPermissionDialog(context),
          ),
          ListTile(
            title: const Text('Precisión del sombreado'),
            subtitle: Text(shadowPrecision.toString()),
            onTap: () => showShadowPrecisionDialog(context),
          ),
          ListTile(
            title: const Text('Ajustes de accesibilidad'),
            subtitle: Text('${accessibilityFontSize}%'),
            onTap: () => showAccessibilitySettingsDialog(context),
          ),
          SwitchListTile(
            title: const Text('Activar notificaciones'),
            value: notificationEnabled,
            onChanged: (value) {
              setState(() {
                notificationEnabled = value;
              });
            },
          ),
        ],
      ),
    );
  }

  void showColorThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ColorThemeDialog(
          onThemeSelected: () {
            setState(() {});
          },
        );
      },
    );
  }

  void showLocationPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return LocationPermissionDialog(
          onPermissionChanged: (bool granted) {
            setState(() {
              locationPermissionGranted = granted;
            });
          },
        );
      },
    );
  }

  void showShadowPrecisionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ShadowPrecisionDialog(
          initialPrecision: shadowPrecision,
          onPrecisionChanged: (int precision) {
            setState(() {
              shadowPrecision = precision;
            });
          },
        );
      },
    );
  }

  void showAccessibilitySettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AccessibilitySettingsDialog(
          initialFontSize: accessibilityFontSize,
          onFontSizeChanged: (double fontSize) {
            setState(() {
              accessibilityFontSize = (fontSize * 100).toDouble();
            });
          },
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

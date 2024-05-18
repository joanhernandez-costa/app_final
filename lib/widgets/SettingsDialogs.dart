import 'package:app_final/services/LocationService.dart';
import 'package:app_final/services/ThemeService.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class SettingsListItem extends StatelessWidget {
  final String title;
  final Widget? subtitle;
  final IconData icon;
  final VoidCallback onTap;

  SettingsListItem({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: subtitle,
      trailing: Icon(icon),
      onTap: onTap,
    );
  }
}

class ColorThemeDialog extends StatelessWidget {
  final VoidCallback onThemeSelected;

  ColorThemeDialog({required this.onThemeSelected});

  @override
  Widget build(BuildContext context) {
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
                  onThemeSelected();
                  Navigator.of(context).pop();
                }
              },
            );
          },
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}

class LocationPermissionDialog extends StatefulWidget {
  final ValueChanged<bool> onPermissionChanged;

  LocationPermissionDialog({required this.onPermissionChanged});

  @override
  _LocationPermissionDialogState createState() =>
      _LocationPermissionDialogState();
}

class _LocationPermissionDialogState extends State<LocationPermissionDialog> {
  late bool locationServiceEnabled;
  late LocationPermission permissionStatus;

  @override
  void initState() {
    super.initState();
    _checkLocationStatus();
  }

  Future<void> _checkLocationStatus() async {
    locationServiceEnabled = await LocationService.isLocationServiceEnabled();
    permissionStatus = await LocationService.checkPermission();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Permisos de ubicación"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          locationServiceEnabled
              ? Icon(Icons.location_on, color: Theme.of(context).primaryColor)
              : Icon(Icons.location_off, color: Theme.of(context).errorColor),
          SizedBox(height: 16),
          Text(
            locationServiceEnabled
                ? "Los servicios de ubicación están habilitados."
                : "Los servicios de ubicación están deshabilitados.",
          ),
          SizedBox(height: 16),
          Text("Permiso de ubicación actual: ${permissionStatus.toString()}"),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            permissionStatus = await LocationService.requestPermission();
            widget.onPermissionChanged(
                permissionStatus != LocationPermission.denied &&
                    permissionStatus != LocationPermission.deniedForever);
            setState(() {});
          },
          child: const Text('Solicitar Permiso'),
        ),
        TextButton(
          onPressed: () async {
            await LocationService.openLocationSettings();
          },
          child: const Text('Abrir Configuración de Ubicación'),
        ),
        TextButton(
          onPressed: () async {
            await LocationService.openAppSettings();
          },
          child: const Text('Abrir Configuración de la App'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}

class ShadowPrecisionDialog extends StatefulWidget {
  final int initialPrecision;
  final ValueChanged<int> onPrecisionChanged;

  ShadowPrecisionDialog(
      {required this.initialPrecision, required this.onPrecisionChanged});

  @override
  _ShadowPrecisionDialogState createState() => _ShadowPrecisionDialogState();
}

class _ShadowPrecisionDialogState extends State<ShadowPrecisionDialog> {
  late int selectedPrecision;

  @override
  void initState() {
    super.initState();
    selectedPrecision = widget.initialPrecision;
  }

  @override
  Widget build(BuildContext context) {
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
            setState(() {
              selectedPrecision = value.toInt();
            });
          },
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            widget.onPrecisionChanged(selectedPrecision);
            Navigator.of(context).pop();
          },
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}

class AccessibilitySettingsDialog extends StatefulWidget {
  final double initialFontSize;
  final ValueChanged<double> onFontSizeChanged;

  AccessibilitySettingsDialog(
      {required this.initialFontSize, required this.onFontSizeChanged});

  @override
  _AccessibilitySettingsDialogState createState() =>
      _AccessibilitySettingsDialogState();
}

class _AccessibilitySettingsDialogState
    extends State<AccessibilitySettingsDialog> {
  late double selectedFontSize;

  @override
  void initState() {
    super.initState();
    selectedFontSize = widget.initialFontSize;
  }

  @override
  Widget build(BuildContext context) {
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
            setState(() {
              selectedFontSize = value;
            });
          },
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            widget.onFontSizeChanged(selectedFontSize);
            Navigator.of(context).pop();
          },
          child: const Text('Guardar'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}

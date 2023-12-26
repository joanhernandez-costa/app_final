import 'package:app_final/ApiCalls.dart';
import 'package:app_final/AppUser.dart';
import 'package:app_final/MediaService.dart';
import 'package:app_final/Navigation.dart';
import 'package:app_final/SettingsScreen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  final AppUser currentUser;
  // Agregar otras propiedades

  const ProfileScreen({
    Key? key,
    required this.currentUser,
  }) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {
                  Navigation.replaceScreen(context, SettingsScreen());
                },
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: widget.currentUser.profileImage != null && widget.currentUser.profileImage!.isNotEmpty
                              ? NetworkImage(widget.currentUser.profileImage!)
                              : null, // Usa null aquí para el caso por defecto
                          child: widget.currentUser.profileImage == null || widget.currentUser.profileImage!.isEmpty
                              ? const Icon(Icons.person, size: 60) // Icono por defecto
                              : null,
                        ),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            MediaService.pickImage((url) => onImageSelected(url));
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Expanded(
                      child: Container(
                        color: Colors.white,
                        child: ListView.builder(
                          itemCount: 20,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: Icon(Icons.settings),
                              title: Text('Opción ${index + 1}'),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onImageSelected(String? url) {
    if (url != null) {
      // Actualiza el objeto currentUser con la nueva imagen
      setState(() {
        widget.currentUser.profileImage = url;
      });

      // Actualiza el registro en Supabase
      ApiCalls.updateProfile(widget.currentUser);
    }
  }
}

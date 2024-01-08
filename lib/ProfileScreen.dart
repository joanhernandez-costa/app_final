
import 'package:app_final/AppUser.dart';
import 'package:app_final/MediaService.dart';
import 'package:app_final/Navigation.dart';
import 'package:app_final/SettingsScreen.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

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
                        ValueListenableBuilder<AppUser?>(
                          valueListenable: AppUser.currentUser,
                          builder: (context, currentUser, child) {
                            return CircleAvatar(
                              radius: 60,
                              backgroundImage: NetworkImage(AppUser.currentUser.value!.profileImageUrl!),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: pickAndUploadImage,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
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

  void pickAndUploadImage() async {
    await MediaService.pickImage((url) async {
      if (url != null) {
        setState(() {
          AppUser.currentUser.value?.profileImageUrl = url;
        });

        // Actualizar el registro en Supabase
        AppUser.updateCurrentUser(AppUser.currentUser.value!, AppUser.currentUser.value!.id);
      }
    });
  }
}

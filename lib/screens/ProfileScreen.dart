
import 'package:flutter/material.dart';
import 'package:app_final/models/AppUser.dart';
import 'package:app_final/services/MediaService.dart';
import 'package:app_final/services/NavigationService.dart';
import 'package:app_final/screens/SettingsScreen.dart';
import 'package:app_final/services/ValidationService.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _mailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _userNameController.text = AppUser.currentUser.value?.userName ?? '';
    _mailController.text = AppUser.currentUser.value?.mail ?? '';    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          children: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                NavigationService.replaceScreen(context, SettingsScreen());
              },
              alignment: Alignment.topLeft,
            ),
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(AppUser.currentUser.value!.profileImageUrl ?? 'https://nkmqlnfejowcintlfspl.supabase.co/storage/v1/object/public/app_final_bucket/logo_app.png'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 150),
              child: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: pickAndUploadImage,
              ),
            ),
            _buildEditableField('Nombre de Usuario', _userNameController),
            _buildEditableField('Correo Electrónico', _mailController),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100),
              child: ElevatedButton(
                onPressed: _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.black,
                ),
                child: const Text('Actualizar'),
              ),
            ),
            const SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Table(
                border: TableBorder.all(),
                children: List<TableRow>.generate(
                  5,
                  (index) => TableRow(
                    children: [
                      Center(child: Text('Celda $index')),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        //onEditingComplete: ,
      ),
    );
  }

  void pickAndUploadImage() async {
    var url = await MediaService.pickImage();
    setState(() {
      AppUser.currentUser.value!.profileImageUrl = url;
    });
  }

  void _updateProfile() {
    String? userNameError = ValidationService.validateUserName(_userNameController.text);
    String? mailError = ValidationService.validateMailForSignUp(_mailController.text);

    if (userNameError != null || mailError != null) {      
      print('Error: $userNameError, $mailError');
      return;
    }

    AppUser updatedUser = AppUser(
      userName: _userNameController.text,
      mail: _mailController.text,
      password: AppUser.currentUser.value!.password,
      id: AppUser.currentUser.value!.id, 
      profileImageUrl: AppUser.currentUser.value!.profileImageUrl
    );

    AppUser.updateCurrentUser(updatedUser);
  }
}

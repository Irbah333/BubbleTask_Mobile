// screens/tabs/profile_tab.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../helpers/database_helper.dart';
import '../../models/user.dart';
import '../auth/login_screen.dart';

class ProfileTab extends StatefulWidget {
  final int userId;

  ProfileTab({required this.userId});

  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  User? _currentUser;
  bool _isLoading = true;
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await DatabaseHelper.instance.getUserById(widget.userId);
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });

      // Update user profile image in database
      if (_currentUser != null) {
        final updatedUser = User(
          id: _currentUser!.id,
          username: _currentUser!.username,
          password: _currentUser!.password,
          profileImage: image.path,
        );

        await DatabaseHelper.instance.updateUser(updatedUser);
        _loadUserData();
      }
    }
  }

  Future<void> _showEditDialog(String field) async {
    final TextEditingController controller = TextEditingController();
    String title = '';
    bool isPassword = false;

    switch (field) {
      case 'name':
        title = 'Change Account Name';
        controller.text = _currentUser?.username ?? '';
        break;
      case 'password':
        title = 'Change Account Password';
        isPassword = true;
        break;
    }

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            obscureText: isPassword,
            decoration: InputDecoration(
              hintText: isPassword ? 'Enter new password' : 'Enter new name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.trim().isNotEmpty && _currentUser != null) {
                  User updatedUser;
                  if (field == 'name') {
                    updatedUser = User(
                      id: _currentUser!.id,
                      username: controller.text.trim(),
                      password: _currentUser!.password,
                      profileImage: _currentUser!.profileImage,
                    );
                  } else {
                    updatedUser = User(
                      id: _currentUser!.id,
                      username: _currentUser!.username,
                      password: controller.text.trim(),
                      profileImage: _currentUser!.profileImage,
                    );
                  }

                  await DatabaseHelper.instance.updateUser(updatedUser);
                  _loadUserData();
                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$field updated successfully')),
                  );
                }
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE3F2FD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Profile',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Section
            Container(
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : _currentUser?.profileImage != null
                          ? FileImage(File(_currentUser!.profileImage!))
                          : null,
                      child: (_profileImage == null && _currentUser?.profileImage == null)
                          ? Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.grey[600],
                      )
                          : null,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    _currentUser?.username ?? 'User',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5C6BC0),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            // Account Section
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildMenuItem(
                    icon: Icons.person_outline,
                    title: 'Change account name',
                    onTap: () => _showEditDialog('name'),
                  ),
                  _buildMenuItem(
                    icon: Icons.lock_outline,
                    title: 'Change account password',
                    onTap: () => _showEditDialog('password'),
                  ),
                  _buildMenuItem(
                    icon: Icons.image_outlined,
                    title: 'Change account image',
                    onTap: _pickImage,
                  ),
                  SizedBox(height: 20),
                  _buildMenuItem(
                    icon: Icons.logout,
                    title: 'Log out',
                    onTap: _logout,
                    isLogout: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15),
        child: Row(
          children: [
            Icon(
              icon,
              color: isLogout ? Colors.red : Color(0xFF5C6BC0),
              size: 24,
            ),
            SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: isLogout ? Colors.red : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
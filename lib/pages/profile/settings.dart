// ignore: prefer_const_constructors (can be added later for performance)
// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors, prefer_const_constructors

import 'package:fitnesstrackingapp/pages/profile/updateprofile.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLightTheme = true; // Track current theme state

  void _toggleTheme() {
    setState(() {
      _isLightTheme = !_isLightTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text('Settings'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Colors.black, 
            onPressed: () => Navigator.pop(context),
          ),
          
        ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ListTile( // Update Profile option
                title: Text('Update Profile'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UpdateProfileScreen()),
                ),
              ),
              
              Divider(thickness: 1.0),
              ListTile(
                title: Text('Change Theme'),
                trailing: Switch(
                  value: _isLightTheme,
                  onChanged: (value) => _toggleTheme(),
                ),
              ),            
              Divider(thickness: 1.0),
            ],
          ),
        ),
      ),
    );
  }
}

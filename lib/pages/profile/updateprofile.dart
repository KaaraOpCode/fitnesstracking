// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, use_key_in_widget_constructors

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UpdateProfileScreen extends StatefulWidget {
  @override
  _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
   final imagePicker = ImagePicker(); 
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  File? _profileImage; // Variable to store the selected image file

  Future<void> _pickImage() async {
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Profile'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile image section
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50.0,
                  backgroundImage: AssetImage('assets/images/profile_picture.jpg'),

                ),
              ),
              SizedBox(height: 16.0),

              // Name and email form fields (unchanged)
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
                onSaved: (newValue) => _name = newValue ?? '',
              ),
              SizedBox(height: 16.0),
              TextFormField(
                initialValue: _email,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  } else if (!RegExp(r"\S+@\S+\.\S+").hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
                onSaved: (newValue) => _email = newValue ?? '',
              ),
              SizedBox(height: 24.0),

              // Update button (unchanged)
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Handle profile update logic (including image upload if applicable)
                    print('Name: $_name, Email: $_email, Image: $_profileImage'); // Simulate update
                    // Show success message or navigate back to Settings screen
                  }
                },
                child: Text('Update Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

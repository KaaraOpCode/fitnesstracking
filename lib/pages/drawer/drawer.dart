// ignore_for_file: avoid_print, library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnesstrackingapp/pages/drawer/goals.dart';
import 'package:fitnesstrackingapp/pages/profile/profile.dart';
import 'package:fitnesstrackingapp/pages/profile/settings.dart';
import 'package:flutter/material.dart';

class DrawerScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String userId;

  const DrawerScreen({super.key, required this.scaffoldKey, required this.userId});

  @override
  _DrawerScreenState createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  String? username;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsername();
  }

  Future<void> fetchUsername() async {
    try {
      print('Fetching username for userId: ${widget.userId}');  // Logging userId
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();
      
      print('User document data: ${userDoc.data()}');  // Logging Firestore response
      
      if (userDoc.exists) {
        setState(() {
          username = userDoc['username'];
          isLoading = false;
        });
      } else {
        print('User document does not exist');
        setState(() {
          username = 'User not found';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching username: $e');
      setState(() {
        username = 'Error fetching user';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundImage: AssetImage('assets/images/profile_picture.jpg'), // Replace with your asset path
                ),
                const SizedBox(width: 16.0),
                isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(
                      username ?? 'Unknown User',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                      ),
                    ),
              ],
            ),
          ),
          ListTile(
            title: const Text('Profile'),
            leading: const Icon(Icons.account_circle),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
              widget.scaffoldKey.currentState?.closeDrawer();
            },
          ),
          ListTile(
            title: const Text('Goals'),
            leading: const Icon(Icons.notifications),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FitnessGoalsScreen(),
                ),
              );
              widget.scaffoldKey.currentState?.closeDrawer();
            },
          ),
          ListTile(
            title: const Text('Settings'),
            leading: const Icon(Icons.settings),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(),
                ),
              );
              widget.scaffoldKey.currentState?.closeDrawer();
            },
          ),
          Spacer(),  // Takes up all remaining space to push the close button to the bottom
          ListTile(
            title: const Text('Close'), // New option for closing
            leading: const Icon(Icons.close),
            onTap: () {
              widget.scaffoldKey.currentState?.closeDrawer();
            },
          ),
        ],
      ),
    );
  }
}

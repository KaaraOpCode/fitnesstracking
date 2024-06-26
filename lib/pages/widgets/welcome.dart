// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors, unnecessary_import

import 'package:fitnesstrackingapp/pages/auth/signup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Welcome extends StatefulWidget {
  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Image.asset(
            'assets/images/welcome_undraw.jpg', // Replace with your image path
            // Ensure the image fills the entire available space
            width: 500,
            height: 900,
            fit: BoxFit.cover,
          ),
        ),
      ),
      // Position other content below the image
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 110.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 30.0 ),
              child: const Text(
                'WELCOME!',
                style: TextStyle(fontSize: 24.0),
              ),
            ),
            const Text(
              'FITNESS TRACKER',
              style: TextStyle(fontSize: 24.0),
            ),
            const SizedBox(height: 20.0),
            // Buttons
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, 
                  MaterialPageRoute(builder: 
                    // ignore: prefer_const_constructors
                    (context) => SignUp()
                  )
                );
              },
              child: const Text('Get Started'),
            ),
            
          ],
        ),
      ),
    );
  }
}

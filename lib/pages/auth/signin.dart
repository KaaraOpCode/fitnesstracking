// ignore_for_file: avoid_print, unused_field, prefer_const_constructors, unused_local_variable, use_build_context_synchronously, prefer_typing_uninitialized_variables, unused_import

import 'package:fitnesstrackingapp/pages/activities/activity_widgets/activities.dart';
import 'package:fitnesstrackingapp/pages/widgets/home.dart';
import 'package:fitnesstrackingapp/pages/auth/signup.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  String? username;
  String? age;
  String? gender;
  String? height;
  String? weight;
  String? userId;

  // Initialize Google Sign-In
  final GoogleSignIn googleSignIn = GoogleSignIn();

  @override
  void initState() {
    super.initState();
    // Set Firebase locale
    FirebaseAuth.instance.setLanguageCode('en'); // Change 'en' to the appropriate locale code
  }

  Future<void> _signInWithEmailAndPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        // Fetch the user document from Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(credential.user!.uid)
            .get();

        // Assign the fields or provide default values if fields are missing
        username = userDoc['username'] ?? 'Unknown';
        age = userDoc['age'] ?? 'Unknown';
        gender = userDoc['gender'] ?? 'Unknown';
        height = userDoc['height'] ?? 'Unknown';
        weight = userDoc['weight'] ?? 'Unknown';
        userId = userDoc['userId'] ?? 'Unknown';

        // Only navigate if the widget is still in the tree
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Home(
              userId: userId!,
              username: username!,
              age: age!,
              gender: gender!,
              height: height!,
              weight: weight!,
            )),
          );
        }
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sign in: $e')),
        );
      } finally {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
    print(userId);
    print('Sign In Button Pressed');
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Sign in with Google
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with Google credentials
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      // Check if user is new or existing
      final User? firebaseUser = userCredential.user;

      // If user is new, create a Firestore document with user data
      if (firebaseUser != null) {
        final DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).get();
        
        // Handle userDoc data retrieval as per your application's requirements
        username = userDoc['username'] ?? firebaseUser.displayName ?? 'Unknown';
        age = userDoc['age'] ?? 'Unknown';
        gender = userDoc['gender'] ?? 'Unknown';
        height = userDoc['height'] ?? 'Unknown';
        weight = userDoc['weight'] ?? 'Unknown';
        userId = userDoc['userId'] ?? firebaseUser.uid;

        // Navigate to home screen or perform other actions
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Home(
              userId: userId!,
              username: username!,
              age: age!,
              gender: gender!,
              height: height!,
              weight: weight!,
            )),
          );
        }
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign in with Google: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.asset(
                      'assets/images/signin_undraw.png',
                      width: 300.0,
                      height: 200.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 20.0),

                  // Email Text Field
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter email';
                      }
                      return null;
                    },
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),

                  // Password Text Field
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter password';
                      }
                      return null;
                    },
                    controller: passwordController,
                    obscureText: true, // Hide password input
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),

                  // Sign In Button
                  ElevatedButton(
                    onPressed: _signInWithEmailAndPassword,
                    child: isLoading ? CircularProgressIndicator() : const Text('Sign In'),
                  ),
                  const SizedBox(height: 20.0),

                  // Google Sign-In Button
                  OutlinedButton(
                    onPressed: _signInWithGoogle,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const <Widget>[
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Image(image: AssetImage("assets/images/google_logo.png"), height: 35.0),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 10.0),
                          child: Text(
                            'Sign in with Google',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.black54,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20.0),

                  // Don't have an account? Sign Up
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SignUp()),
                          );
                          print('Sign Up Button Pressed');
                        },
                        child: const Text('Sign Up'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, no_leading_underscores_for_local_identifiers, unused_element

import 'package:carousel_slider/carousel_slider.dart';
import 'package:fitnesstrackingapp/pages/activities/activity_widgets/activities.dart';
import 'package:fitnesstrackingapp/pages/auth/signin.dart';
import 'package:fitnesstrackingapp/pages/drawer/drawer.dart';
import 'package:fitnesstrackingapp/pages/activities/journal.dart';
import 'package:fitnesstrackingapp/pages/tutorials/tutorials.dart';
import 'package:fitnesstrackingapp/pages/widgets/notifications.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  final String username;
  final String age;
  final String gender;
  final String height;
  final String weight;
  final String userId;

  const Home({
    super.key,
    required this.username,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.userId,
  });

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _drawerKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    Widget _buildBody() {
      switch (_selectedIndex) {
        case 1:
          return Activities(userId: widget.userId, activityName: '',);
        case 2:
          return Journal(userId: widget.userId,);
        case 3:
          return Tutorials(userId: widget.userId,);
        case 4:
          return NotificationScreen(userId: widget.userId,);
        case 0:
        default:
          return Column(
            children: [
              _buildUserInfoCard(context, screenWidth),
              SizedBox(height: 20),
              buildCarousel(context), // Display Carousel here
            ],
          );
      }
    }

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        // Show exit confirmation dialog
        return await _showExitConfirmationDialog(context);
      },
      child: Scaffold(
        key: _drawerKey,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.logout_outlined),
            color: Colors.black,
            onPressed: () {
              _showSignOutDialog(context);
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.menu),
              color: Colors.black,
              onPressed: () {
                if (_drawerKey.currentState != null) {
                  _drawerKey.currentState!.openDrawer();
                }
              },
            ),
          ],
        ),
        body: SafeArea(child: _buildBody()),
        drawer: DrawerScreen(scaffoldKey: _drawerKey, userId: widget.userId,),
        bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
              backgroundColor: Theme.of(context).primaryColor,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.volunteer_activism_outlined),
              label: 'Activities',
              backgroundColor: Theme.of(context).primaryColor,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_edu_outlined),
              label: 'Journal',
              backgroundColor: Theme.of(context).primaryColor,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.play_circle_outline_rounded),
              label: 'Tutorials',
              backgroundColor: Theme.of(context).primaryColor,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notification_add),
              label: 'Alerts',
              backgroundColor: Theme.of(context).primaryColor,
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.white,
          selectedFontSize: 24, // Adjust the font size as needed
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold), // Adjust the style as needed
          onTap: _onItemTapped,
        ),
      ),
    );
  }


  Widget _buildUserInfoCard(BuildContext context, double screenWidth) {
    return Container(
      height: 155.0,
      width: screenWidth * 0.9,
      margin: const EdgeInsets.all(10.0),
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        children: [
          Text(
            'Welcome, ${widget.username}!',
            style: TextStyle(color: Colors.white, fontSize: 20.0),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildInfoContainer('Age', widget.age),
              _buildInfoContainer('Gender', widget.gender),
              _buildInfoContainer('Height', widget.height),
              _buildInfoContainer('Weight', widget.weight),
            ],
          ),

        ],
      ),
    );
  }


  Widget buildCarousel(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 450.0,
        enlargeCenterPage: true,
        autoPlay: true,
        aspectRatio: 16 / 9,
        autoPlayCurve: Curves.fastOutSlowIn,
        enableInfiniteScroll: true,
        autoPlayAnimationDuration: Duration(milliseconds: 800),
        viewportFraction: 0.8,
      ),
      items: [
        Container(
          margin: EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Center(
            child: Text(
              'Container 1',
              style: TextStyle(fontSize: 20.0),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Center(
            child: Text(
              'Container 2',
              style: TextStyle(fontSize: 20.0),
            ),
          ),
        ),
        // Add more containers as needed
      ],
    );
  }


  Widget _buildInfoContainer(String label, String value) {
    return Column(
      children: [
        _buildInfoTile(value),
        SizedBox(height: 10),
        _buildInfoTile(label),
      ],
    );
  }

  Widget _buildInfoTile(String text) {
    return Container(
      height: 30,
      width: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Center(child: Text(text)),
    );
  }

  Widget _buildButton(String label, IconData iconData, Function() onPressed) {
    return Container(
      height: 45.0,
      width: 370.0,
      margin: const EdgeInsets.all(10.0),
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        children: [
          Icon(iconData, color: Colors.black),
          SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(color: Colors.white, fontSize: 20.0),
          ),
          Spacer(),
          IconButton(
            color: Colors.white,
            onPressed: onPressed,
            icon: Icon(Icons.arrow_forward_ios),
          ),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
  
  void _showSignOutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Confirm Sign Out"),
        content: Text("Are you sure you want to sign out?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              // Perform sign-out action here
              // For now, just pop the dialog and navigate to SignIn screen
              Navigator.of(context).pop(); // Close the dialog
              Navigator.pushReplacement( // Use pushReplacement to clear the stack
                context,
                MaterialPageRoute(builder: (context) => SignIn()), // Navigate to SignIn screen
              );
            },
            child: Text("Sign Out"),
          ),
        ],
      );
    },
  );
}
}


Future<bool> _showExitConfirmationDialog(BuildContext context) async {
  return await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Confirm Exit"),
        content: Text("Are you sure you want to exit?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Close the dialog and return false
            },
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Close the dialog and return true
            },
            child: Text("Exit"),
          ),
        ],
      );
    },
  ) ?? false; // Return false if the dialog was dismissed
}

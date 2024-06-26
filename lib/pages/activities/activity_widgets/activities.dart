import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'actvititytracking.dart'; // Import your Tracker widget

class Activities extends StatefulWidget {
  final String userId;

  const Activities({super.key, required this.userId, required String activityName});

  @override
  State<Activities> createState() => _ActivitiesState();
}

class _ActivitiesState extends State<Activities> {
  // ignore: unused_field
  final _drawerKey = GlobalKey<ScaffoldState>();

  Widget _buildActivityCard({
    required BuildContext context,
    required String activityName,
    required String imagePath,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 130.0,
      width: 460.0,
      margin: const EdgeInsets.all(10.0),
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        children: [
          SizedBox(height: 20),
          Row(
            children: [
              Column(
                children: [
                  Container(
                    height: 30,
                    width: 69,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Center(
                      child: Text(activityName),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 35,
                    width: 35,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: IconButton(
                      iconSize: 20,
                      color: Colors.black,
                      onPressed: onPressed,
                      icon: Icon(Icons.play_circle_filled_rounded),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 140),
              Container(
                height: 77,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  image: DecorationImage(
                    image: AssetImage(imagePath),
                    //fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 50,
              width: 300,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(10.0), // Adding border radius
              ),
              child: const Center(
                child: Text(
                  'Select An Activity!',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 10), // Add some spacing between the title and the list
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('activities')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  if (!snapshot.hasData || snapshot.data == null) {
                    return Text('No data available');
                  }

                  final activities = snapshot.data!.docs;
                  //print(activities.first.id);
                  print('User ID: ${widget.userId}');
                  return SingleChildScrollView(
                    child: Column(
                      children: activities.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final activityName =
                            data['activityName'] ?? 'Unknown';
                        final imagePath =
                            data['imageUrl'] ?? 'assets/images/default.png';
                        print(activityName);
                        return _buildActivityCard(
                          context: context,
                          activityName: activityName,
                          imagePath: imagePath,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Tracker(
                                  activityName: activityName, // Pass the selected activity name
                                  userId: widget.userId,
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

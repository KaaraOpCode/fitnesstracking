// ignore_for_file: avoid_print, unnecessary_to_list_in_spreads, use_key_in_widget_constructors, library_private_types_in_public_api, unused_element, unused_field
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Journal extends StatefulWidget {
  final String userId;

  const Journal({super.key, required this.userId});
  @override
  _JournalState createState() => _JournalState();
}

class _JournalState extends State<Journal> {
  late Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _activityData;

  final int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _activityData = _fetchActivityData();
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _fetchActivityData() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('activityData')
        .where('userId', isEqualTo: widget.userId) // Filter documents by userId
        .get();

    return querySnapshot.docs;
  }

  Widget buildActivityCard(BuildContext context, Map<String, dynamic> activity) {
    // Extracting year, month, and day from the activity timestamp
    if (activity['time'] == null) {
      return SizedBox(); // Return an empty SizedBox if 'time' is null
    }
    final DateTime activityDate = activity['time'].toDate();
    // ignore: unused_local_variable
    final String formattedDate = '${activityDate.year}-${activityDate.month}-${activityDate.day}';

    return Container(
      height: 123.0,
      width: double.infinity,
      margin: const EdgeInsets.all(10.0),
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                activity['time'].toDate().toString().split(' ')[0], // Example: 'Wed 20'
                style: const TextStyle(color: Colors.white, fontSize: 10.0),
              ),
              Text(
                '  ${activity['time'].toDate().toString().split(' ')[1]}', // Example: 'March'
                style: const TextStyle(color: Colors.white, fontSize: 10.0),
              ),
              const SizedBox(width: 5),
              const Icon(
                Icons.directions_walk_rounded,
                color: Colors.black,
                size: 13,
              ),
              const SizedBox(width: 5),
              Text(
                '${activity['steps']} steps',
                style: const TextStyle(color: Colors.white, fontSize: 10.0),
              ),
              const SizedBox(width: 5),
              const Icon(
                Icons.energy_savings_leaf_rounded,
                color: Colors.black,
                size: 13,
              ),
              const SizedBox(width: 5),
              Text(
                '${activity['cal']} pts',
                style: const TextStyle(color: Colors.white, fontSize: 10.0),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.directions_walk_rounded,
                color: Colors.black,
                size: 13,
              ),
              const SizedBox(width: 5),
              Text(
                '${activity['time'].toDate().hour.toString().padLeft(2, '0')}:${activity['time'].toDate().minute.toString().padLeft(2, '0')}',
                style: const TextStyle(color: Colors.white, fontSize: 10.0),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${activity['activityType']}',
                style: TextStyle(color: Colors.white, fontSize: 15.0, fontWeight: FontWeight.bold),
              ),
              Icon(
                Icons.directions_walk_rounded,
                color: Colors.black,
                size: 33,
              ),
            ],
          ),
          Row(
            children: [
              Text(
                '${activity['distance']} km',
                style: const TextStyle(color: Colors.white, fontSize: 10.0),
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
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: const Center(
                child: Text(
                  'Look At Your Activity Records! ',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
                future: _activityData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final data = snapshot.data ?? [];
                  return ListView(
                    children: data.map((activity) => buildActivityCard(context, activity.data())).toList(),
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

String _formatTime(int seconds) {
  int hours = seconds ~/ 3600;
  int minutes = (seconds ~/ 60) % 60;
  int remainingSeconds = seconds % 60;

  String hoursStr = hours.toString().padLeft(2, '0');
  String minutesStr = minutes.toString().padLeft(2, '0');
  String secondsStr = remainingSeconds.toString().padLeft(2, '0');

  return '$hoursStr:$minutesStr:$secondsStr';
}

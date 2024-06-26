// ignore_for_file: avoid_print, use_key_in_widget_constructors, library_private_types_in_public_api, use_build_context_synchronously, unnecessary_string_interpolations, use_super_parameters

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnesstrackingapp/pages/activities/activity_widgets/activityhistory.dart';
import 'package:fitnesstrackingapp/pages/activities/activity_widgets/count_down_modal.dart';
import 'package:fitnesstrackingapp/pages/activities/health_connect.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class Tracker extends StatefulWidget {
  final String activityName;
  final String userId;

  const Tracker({Key? key, required this.activityName, required this.userId}) : super(key: key);

  @override
  _TrackerState createState() => _TrackerState();
}

class _TrackerState extends State<Tracker> {
  late Timer _timer;
  int _seconds = 0;

  Map<String, dynamic> _activityMetrics = {
    'time': '-',
    'distance': '-',
    'heartRate': '-',
    'steps': '-',
    'cal': '-',
  };

  @override
  void initState() {
    super.initState();
    _fetchActivityData(); // Fetch data when the widget is initialized
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _fetchActivityData() async {
    print('Fetching activity data for: ${widget.activityName}');

    final querySnapshot = await FirebaseFirestore.instance
        .collection('activityData')
        .where('activityType', isEqualTo: widget.activityName)
        .orderBy('time', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final activityData = querySnapshot.docs.first.data();
      //print('Fetched data: $activityData'); // Print fetched data for debugging

      setState(() {
        _activityMetrics = activityData;
      });
    } else {
      print('No data found for activity: ${widget.activityName}'); // Print message if no data is found
      setState(() {
        _activityMetrics = {
          'time': '-',
          'distance': '-',
          'heartRate': '-',
          'steps': '-',
          'cal': '-',
        };
      });
    }
  }

  Future<void> _insertDummyData() async {
    await FirebaseFirestore.instance.collection('activityData').add({
      'activityType': widget.activityName,
      'time': Timestamp.now(),
      'distance': 15.5,
      'heartRate': 75,
      'steps': 3000,
      'cal': 200,
      'userId': widget.userId
    });
    await _fetchActivityData(); // Refresh data after inserting dummy data
  }

  Future<void> _showCountdownModal() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Prevents closing the dialog by tapping outside
      builder: (BuildContext context) {
        return CountdownModal();
      },
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  void _stopTimer() {
    _timer.cancel();
  }

  void _resetTimer() {
    setState(() {
      _seconds = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            
            Text(
              widget.activityName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: screenWidth * 0.7,
                    height: screenWidth * 0.7,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Positioned(
                    top: screenWidth * 0.05,
                    child: Column(
                      children: [
                        Text(
                          _formatTime(_seconds), // Display the active time from the timer
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                        const Text(
                          'Active Time',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                    top: screenWidth * 0.29,
                    left: screenWidth * 0.05,
                    child: Column(
                      children: [
                        Text(
                          _activityMetrics['distance'].toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                        const Text(
                          'km',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: screenWidth * 0.29,
                    left: screenWidth * 0.32,
                    child: Column(
                      children: const [
                        Text(
                          '-:-',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: screenWidth * 0.29,
                    right: screenWidth * 0.04,
                    child: Column(
                      children: [
                        Text(
                          _activityMetrics['heartRate'].toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                        const Text(
                          'Heart Rate',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: screenWidth * 0.1,
                    left: screenWidth * 0.2,
                    child: Column(
                      children: [
                        Text(
                          _activityMetrics['steps'].toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                        const Text(
                          'Steps',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: screenWidth * 0.1,
                    right: screenWidth * 0.2,
                    child: Column(
                      children: [
                        Text(
                          _activityMetrics['cal'].toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                        const Text(
                          'Cal',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () async {
                    _stopTimer(); // Stop the timer when the stop icon is pressed
                    await _fetchActivityData(); // Fetch the latest data
                    final updatedTimeStamp = _activityMetrics['time'] as Timestamp?;
                    final updatedDateString = updatedTimeStamp != null
                        ? '${updatedTimeStamp.toDate().year}-${updatedTimeStamp.toDate().month.toString().padLeft(2, '0')}-${updatedTimeStamp.toDate().day.toString().padLeft(2, '0')}'
                        : '-';

                    print(_activityMetrics);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ActivityHistory(
                          date: updatedTimeStamp?.toDate().toString() ?? '-',
                          time: updatedDateString,
                          activeTime: _formatTime(_seconds), // Display the active time from the timer
                          energyExpended: _activityMetrics['cal'].toString(),
                          distance: _activityMetrics['distance'].toString(),
                          heartRate: _activityMetrics['heartRate'].toString(),
                          steps: _activityMetrics['steps'].toString(), 
                          activityType: _activityMetrics['activityType']?.toString() ?? '-', // Ensure this is not null
                        ),
                      ),
                    );
                    print('ActivityHistory Button Pressed');
                  },
                  icon: const Icon(Icons.stop_circle_outlined),
                  iconSize: 50,
                ),
                IconButton(
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HealthApp()),
                    );
                  },
                  icon: const Icon(Icons.access_alarm),
                  iconSize: 50,
                ),
                IconButton(
                  onPressed: () async {
                    await _showCountdownModal();
                    _resetTimer();
                    _startTimer();
                    await _insertDummyData();

                  },
                  icon: const Icon(Icons.play_circle_fill_outlined),
                  iconSize: 50,
                ),
              ],
            ),
            const SizedBox(height: 40),
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
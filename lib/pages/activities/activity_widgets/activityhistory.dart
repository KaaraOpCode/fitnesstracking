// ActivityHistory.dart
// ignore_for_file: avoid_print, library_private_types_in_public_api, use_super_parameters

import 'package:fitnesstrackingapp/pages/activities/chart.dart';
import 'package:flutter/material.dart';

class ActivityHistory extends StatefulWidget {
  final String date;
  final String time;
  final String activeTime;
  final String energyExpended;
  final String distance;
  final String heartRate;
  final String steps;
  final String activityType;

  const ActivityHistory({
    Key? key,
    required this.date,
    required this.time,
    required this.activeTime,
    required this.energyExpended,
    required this.distance,
    required this.heartRate,
    required this.steps, 
    required this.activityType,
  }) : super(key: key);

  @override
  _ActivityHistoryState createState() => _ActivityHistoryState();
}

class _ActivityHistoryState extends State<ActivityHistory> {
  final _drawerKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _drawerKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Builder(
            builder: (context) => Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  color: Colors.black,
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => buildPopupMenu(context),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.share_rounded),
                  color: Colors.black,
                  onPressed: () {
                    // Add share functionality here
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(
            height: 50,
            width: 300,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Center(
              child: Text(
                '${widget.activityType} Metrics',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          SizedBox(height: 10),
                ActivityDetailRow(
                  icon: Icons.directions_walk_rounded,
                  label1: 'Date',
                  label2: widget.date,
                ),
                const SizedBox(height: 20),
                ActivityDetailRow(
                  icon: Icons.punch_clock,
                  label1: 'Active Time',
                  label2: widget.activeTime,
                ),
                const SizedBox(height: 20),
                ActivityDetailRow(
                  icon: Icons.energy_savings_leaf_rounded,
                  label1: 'Energy Expended',
                  label2: widget.energyExpended,
                ),
                const SizedBox(height: 20),
                ActivityDetailRow(
                  icon: Icons.social_distance_rounded,
                  label1: 'Distance',
                  label2: widget.distance,
                ),
                const SizedBox(height: 20),
                ActivityDetailRow(
                  icon: Icons.favorite_rounded,
                  label1: 'Heart Rate',
                  label2: widget.heartRate,
                ),
                const SizedBox(height: 20),
                ActivityDetailRow(
                  icon: Icons.directions_walk_rounded,
                  label1: 'Steps',
                  label2: widget.steps,
                ),
                const SizedBox(height: 20),
                LineChartSample7(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPopupMenu(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Delete'),
            onTap: () {
              Navigator.pop(context);
              print('Option 1 selected');
            },
          ),
          ListTile(
            title: const Text('Help & Feedback'),
            onTap: () {
              Navigator.pop(context);
              print('Option 2 selected');
            },
          ),
        ],
      ),
    );
  }
}

class ActivityDetailRow extends StatelessWidget {
  final IconData icon;
  final String label1;
  final String label2;

  const ActivityDetailRow({
    Key? key,
    required this.icon,
    required this.label1,
    required this.label2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45.0,
      width: 350.0,
      margin: const EdgeInsets.all(10.0),
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label1,
              style: const TextStyle(color: Colors.white, fontSize: 13.0),
            ),
          ),
          Text(
            label2,
            style: const TextStyle(color: Colors.white, fontSize: 13.0),
          ),
        ],
      ),
    );
  }
}
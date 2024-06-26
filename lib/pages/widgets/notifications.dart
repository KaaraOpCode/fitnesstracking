import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationScreen extends StatefulWidget {
  final String userId;
  const NotificationScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class Notification {
  final String title;
  final String body;
  final DateTime timestamp;

  Notification({
    required this.title,
    required this.body,
    required this.timestamp,
  });
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Notification> notifications = [];

  @override
  void initState() {
    super.initState();
    _subscribeToActivityDataChanges();
  }

  void _subscribeToActivityDataChanges() {
    FirebaseFirestore.instance
        .collection('activityData')
        .where('userId', isEqualTo: widget.userId)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          _createAlertFromActivity(change.doc);
        }
      }
    });
  }
void _createAlertFromActivity(DocumentSnapshot activityDoc) {
  // Extract activity data
  final activityData = activityDoc.data() as Map<String, dynamic>;
  final String activityType = activityData['activityType'] ?? '';
  final dynamic timeData = activityData['time'];
  
  // Check if 'time' field is null or not present
  if (timeData != null) {
    final DateTime timestamp = timeData.toDate();

    // Create alert
    final alert = Notification(
      title: 'New Activity Added',
      body: 'New $activityType activity added',
      timestamp: timestamp,
    );

    // Add alert to list
    setState(() {
      notifications.add(alert);
    });

    // Add alert to 'alerts' collection
    FirebaseFirestore.instance.collection('alerts').add({
      'userId': widget.userId,
      'title': alert.title,
      'body': alert.body,
      'timestamp': alert.timestamp,
    });
  } else {
    print('Error: Time data is null or not present in activity document');
  }
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
              width: 280,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: const Center(
                child: Text(
                  'Notifications',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                itemCount: notifications.length,
                separatorBuilder: (context, index) => Divider(
                  color: Colors.grey[300],
                  thickness: 1.0,
                ),
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return _buildNotificationTile(notification);
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTile(Notification notification) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (notification.body.isNotEmpty)
                    Text(
                      notification.body,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Text(
              _formatTimestamp(notification.timestamp),
              style: TextStyle(color: Colors.grey[600], fontSize: 12.0),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

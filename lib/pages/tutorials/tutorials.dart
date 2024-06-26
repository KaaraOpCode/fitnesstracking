// ignore_for_file: use_super_parameters, library_private_types_in_public_api, avoid_print, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class Tutorials extends StatefulWidget {
  const Tutorials({super.key, required this.userId});
  final String userId;

  @override
  State<Tutorials> createState() => _TutorialsState();
}

class _TutorialsState extends State<Tutorials> {
  final List<String> _allTutorials = [
    "Ab Workout",
    "Aerobics Workout",
    "Squats Workout",
    "Meditation Workout",
    "Yoga Workout",
    "Physique Workout"
  ];

  final Map<String, String> tutorialImageMapping = {
    "Ab Workout": 'assets/images/ab.png',
    "Aerobics Workout": 'assets/images/aerobics.png',
    "Squats Workout": 'assets/images/training.png',
    "Meditation Workout": 'assets/images/meditation.png',
    "Yoga Workout": 'assets/images/pilates_yoga.png',
    "Physique Workout": 'assets/images/physique.png',
  };

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
              child: Center(
                child: Text(
                  'Watch an exercise video!!',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                children: _allTutorials
                    .map((tutorialTitle) => _buildGridTile(context, tutorialTitle))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridTile(BuildContext context, String tutorialTitle) {
    String imagePath = tutorialImageMapping[tutorialTitle] ?? 'assets/images/default.png';
    
    // Determine if the background image is light or dark
    bool isBackgroundLight = _isImageLight(imagePath);

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10.0),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            tutorialTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              backgroundColor: const Color.fromARGB(137, 0, 0, 0),
            ),
          ),
          IconButton(
            iconSize: 48,
            color: isBackgroundLight ? Theme.of(context).primaryColor : Colors.white,
            onPressed: () {
              _showVideoModal(context, tutorialTitle);
            },
            icon: Icon(Icons.play_circle_filled_rounded),
          ),
        ],
      ),
    );
  }

  bool _isImageLight(String imagePath) {
    // In a real application, you might analyze the image to determine its brightness.
    // For simplicity, we'll assume certain images are light.
    // This can be customized based on your actual image set.
    const lightImages = [
      'assets/images/training.png',
      'assets/images/aerobics.png',
      'assets/images/pilates_yoga.png',
      'assets/images/physique.png',
      
    ];

    return lightImages.contains(imagePath);
  }

  void _showVideoModal(BuildContext context, String tutorialTitle) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return VideoModal(tutorialTitle: tutorialTitle);
      },
    );
  }
}

class VideoModal extends StatefulWidget {
  final String tutorialTitle;

  const VideoModal({Key? key, required this.tutorialTitle}) : super(key: key);

  @override
  _VideoModalState createState() => _VideoModalState();
}

class _VideoModalState extends State<VideoModal> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  final Map<String, String> tutorialVideoMapping = {
    "Ab Workout": "ab_workout.mp4",
    "Aerobics Workout": "aerobics_workout.mp4",
    "Squats Workout": "butt_thigh_workout.mp4",
    "Meditation Workout": "meditation_workout.mp4",
    "Yoga Workout": "yoga_workout.mp4",
    "Physique Workout": "physique_workout.mp4"
  };

  @override
  void initState() {
    super.initState();
    String videoFileName = tutorialVideoMapping[widget.tutorialTitle] ?? 'default_video.mp4';
    _controller = VideoPlayerController.asset('assets/videos/$videoFileName');
    _initializeVideoPlayerFuture = _controller.initialize().catchError((error) {
      print("Error initializing video player: $error");
    });
    _controller.setLooping(true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () {}, // Prevents closing when tapping inside the modal
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.width * 0.45,
                  child: FutureBuilder(
                    future: _initializeVideoPlayerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        );
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error loading video'));
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.replay_10),
                      onPressed: () {
                        setState(() {
                          _controller.seekTo(
                            _controller.value.position - Duration(seconds: 10),
                          );
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
                      onPressed: () {
                        setState(() {
                          if (_controller.value.isPlaying) {
                            _controller.pause();
                          } else {
                            _controller.play();
                          }
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.stop),
                      onPressed: () {
                        setState(() {
                          _controller.seekTo(Duration.zero);
                          _controller.pause();
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.forward_10),
                      onPressed: () {
                        setState(() {
                          _controller.seekTo(
                            _controller.value.position + Duration(seconds: 10),
                          );
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

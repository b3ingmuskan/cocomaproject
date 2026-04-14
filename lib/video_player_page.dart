import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerPage extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerPage({super.key, required this.videoUrl});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {

  late VideoPlayerController controller;

  @override
  void initState() {
    super.initState();

    controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
        controller.play();
      });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,

      body: controller.value.isInitialized
          ? Stack(
        children: [

          Center(
            child: AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: VideoPlayer(controller),
            ),
          ),

          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.close,
                  color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          Center(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  controller.value.isPlaying
                      ? controller.pause()
                      : controller.play();
                });
              },
              child: Icon(
                controller.value.isPlaying
                    ? Icons.pause_circle
                    : Icons.play_circle,
                size: 70,
                color: Colors.white70,
              ),
            ),
          ),

          Positioned(
            bottom: 20,
            left: 10,
            right: 10,
            child: VideoProgressIndicator(
              controller,
              allowScrubbing: true,
            ),
          ),
        ],
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
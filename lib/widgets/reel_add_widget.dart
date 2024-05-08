import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mytube/utils/firebase_methods.dart';
import 'package:mytube/utils/image_picker.dart';
import 'package:video_player/video_player.dart';

class ReelAddWidget extends StatefulWidget {
  const ReelAddWidget({super.key, required this.userUid});
  final String userUid;
  @override
  State<ReelAddWidget> createState() {
    return _ReelAddWidgetState();
  }
}

class _ReelAddWidgetState extends State<ReelAddWidget> {
  TextEditingController titleController = TextEditingController();
  late VideoPlayerController videoPlayerController;
  File? thumbnail;
  File? video;
  bool isUploading = false;

  /// Fetches a video using the ImageVideoPicker and initializes the video player.
  ///
  /// This method asynchronously picks a video file, initializes the video player controller
  /// with the selected video, and updates the UI state to reflect the changes. It sets the
  /// video player to loop the video and automatically starts playback.
  ///
  /// The method uses the [BuildContext] to interact with the ImageVideoPicker and to manage
  /// the state of the widget.
  ///
  /// [context] The BuildContext used for picking the video and managing state.
  ///
  /// Note: This method assumes that `ImageVideoPicker.getVideo` and `VideoPlayerController`
  /// are available and correctly configured in your project.
  void getVideo(BuildContext context) async {
    final pickedVideo = await ImageVideoPicker.getVideo(true, context);
    setState(() {
      video = pickedVideo;
      videoPlayerController = VideoPlayerController.file(video!)
        ..initialize().then((value) => setState(() {}));
      videoPlayerController.setLooping(true);
      videoPlayerController.setVolume(1.0);
      videoPlayerController.play();
    });
  }

  /// Initiates the upload process for a video reel.
  ///
  /// This method checks if the title, thumbnail, and video are not empty or null,
  /// and then proceeds to upload the video using `FirebaseMethods.uplaodVideo`.
  /// Upon successful upload, it displays a snackbar with a success message,
  /// clears the title, and resets the video and thumbnail to null.
  /// If any of the required fields are missing, it displays a snackbar
  /// indicating that all fields are required for upload.
  void reelUpload() async {
    setState(() {
      isUploading = true;
    });
    if (titleController.text.isNotEmpty && thumbnail != null && video != null) {
      final uploaded = await FirebaseMethods.uplaodVideo(
          widget.userUid, titleController.text, thumbnail!, video!, context);
      if (uploaded == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.pink,
            content: Text("uploaded 🤝🤝"),
          ),
        );
        setState(() {
          isUploading = false;
          titleController.clear();
          video = null;
          thumbnail = null;
          videoPlayerController.dispose();
        });
      }
    } else {
      isUploading = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.pink,
          content: Text("Everything is reQuired for video uplaod"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Uplaod Video",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Center(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            InkWell(
              /// Handles the tap event to pick an image.
              ///
              /// This function is triggered when the user taps on the designated area for image picking.
              /// It asynchronously opens the image picker, allowing the user to select an image. Once an image
              /// is picked, it updates the state to display the selected image as a thumbnail.
              onTap: () async {
                // Calls the getImage function with true to allow image picking and passes the current context.
                final pickedImage =
                    await ImageVideoPicker.getImage(true, context);
                // Updates the state with the picked image to refresh the UI and show the thumbnail.
                setState(() {
                  thumbnail = pickedImage;
                });
              },
              child: Container(
                height: 200,
                width: 200,
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.red)),
                child: thumbnail == null
                    ? const Icon(Icons.image)
                    : Image.file(
                        thumbnail!,
                        fit: BoxFit.fill,
                      ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(15),
              decoration: const BoxDecoration(color: Colors.white),
              padding: const EdgeInsets.only(left: 10),
              child: TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Enter video title",
                ),
              ),
            ),
            InkWell(
              onTap: () {
                getVideo(context);
              },
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                ),
                child: video == null
                    ? const Icon(Icons.video_camera_back)
                    : VideoPlayer(videoPlayerController),
              ),
            ),
            ElevatedButton.icon(
              onPressed: reelUpload,
              icon: const Icon(Icons.upload),
              label: isUploading == false
                  ? const Text("upload")
                  : const SizedBox(
                      height: 15,
                      width: 15,
                      child: CircularProgressIndicator(
                        color: Colors.blue,
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }
}

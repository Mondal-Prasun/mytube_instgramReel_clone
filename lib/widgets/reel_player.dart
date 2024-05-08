import 'package:flutter/material.dart';

import 'package:mytube/utils/firebase_methods.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:video_player/video_player.dart';

class Reelplayer extends StatefulWidget {
  const Reelplayer({
    super.key,
    required this.videoUrl,
    required this.userUid,
    required this.videoTitle,
  });
  final String videoUrl;
  final String userUid;
  final String videoTitle;
  @override
  State<Reelplayer> createState() {
    return _ReelplayerState();
  }
}

class _ReelplayerState extends State<Reelplayer> {
  late VideoPlayerController videoPlayerController;
  bool isLoading = true;
  bool isPlaying = true;
  Map<String, dynamic>? userDetails;

  @override

  /// Initializes the state of the widget.
  ///
  /// This method is called when the stateful widget is inserted into the tree
  /// for the first time. It overrides the [initState] method from the
  /// [State] class.
  ///
  /// Within this method, the [super.initState] method is called to ensure that
  /// the parent class's [initState] method is also executed.
  ///
  /// The method initializes the [videoPlayerController] by creating a new
  /// instance of [VideoPlayerController] with the network URL obtained from
  /// the [widget.videoUrl]. The [videoPlayerController] is then initialized
  /// asynchronously using the [initialize] method, and the state is updated
  /// using [setState] once the initialization is complete.
  ///
  /// The [setLooping] method is called on the [videoPlayerController] to enable
  /// looping of the video, and the [play] method is called to start playing
  /// the video.
  void initState() {
    super.initState();
    videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    videoPlayerController.initialize().then((value) => setState(() {
          isLoading = false;
        }));
    // videoPlayerController.addListener(() {
    //   setState(() {});
    // });

    videoPlayerController.setLooping(true);
    videoPlayerController.setVolume(1.0);
    videoPlayerController.play();

    // videoPlayerController.addListener(() {
    //   for (final item in videoPlayerController.value.buffered) {
    //     print(item);
    //   }
    // });
    loadViedoAndDetails();
  }

  void loadViedoAndDetails() async {
    setState(() {
      isLoading = true;
    });
    userDetails = await FirebaseMethods.getUserDetails(widget.userUid, context);
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InkWell(
        onTap: () {
          if (isPlaying == true) {
            videoPlayerController.pause();
            videoPlayerController.setVolume(0);
            setState(() {
              isPlaying = !isPlaying;
            });
          } else {
            videoPlayerController.play();
            videoPlayerController.setVolume(1.0);
            setState(() {
              isPlaying = !isPlaying;
            });
          }
        },
        child: Skeletonizer.zone(
          enabled: isLoading,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const ColoredBox(
                color: Colors.grey,
                child: SizedBox.expand(),
              ),
              Container(
                child: AspectRatio(
                  aspectRatio: videoPlayerController.value.aspectRatio,
                  child: VideoPlayer(videoPlayerController),
                ),
              ),
              Visibility(
                visible: !isPlaying,
                child: const Icon(
                  Icons.pause,
                  color: Colors.white,
                  size: 80,
                ),
              ),
              Positioned(
                left: 10,
                bottom: 15,
                child: Skeletonizer(
                  enabled: isLoading,
                  child: Row(
                    children: [
                      Container(
                        color: Colors.white,
                        height: 50,
                        width: 50,
                        child: userDetails == null
                            ? null
                            : Image.network(userDetails!["userImage"]),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Column(
                          children: [
                            Text(
                              userDetails == null
                                  ? "userName"
                                  : userDetails!["userName"],
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text("Title:${widget.videoTitle}")
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

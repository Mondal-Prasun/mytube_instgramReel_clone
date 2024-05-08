import 'package:flutter/material.dart';
import 'package:mytube/widgets/reel_player.dart';

class VideoPreviewCard extends StatelessWidget {
  const VideoPreviewCard(
      {super.key,
      required this.ctx,
      required this.videoThumbnail,
      required this.videoUrl,
      required this.userUid,
      required this.videoTitle});
  final BuildContext ctx;
  final String videoThumbnail;
  final String videoUrl;
  final String userUid;
  final String videoTitle;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(ctx).size;

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Reelplayer(
              videoUrl: videoUrl,
              userUid: userUid,
              videoTitle: videoTitle,
            ),
          ),
        );
      },
      child: Card(
        child: Container(
          padding: const EdgeInsets.all(5),
          height: 200,
          width: size.width / 3,
          child: Image.network(
            videoThumbnail,
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mytube/utils/firebase_methods.dart';
import 'package:mytube/widgets/reel_player.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ReelWidget extends StatefulWidget {
  const ReelWidget({super.key});
  @override
  State<ReelWidget> createState() {
    return _ReelWidgetState();
  }
}

class _ReelWidgetState extends State<ReelWidget> {
  PageController pageController = PageController(
    initialPage: 0,
    keepPage: false,
  );
  QuerySnapshot? reelQuerySnapshot;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadReelVideos();
  }

  void loadReelVideos() async {
    reelQuerySnapshot = await FirebaseMethods.getAllVideos(context);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: reelQuerySnapshot != null
          ? PageView.builder(
              scrollDirection: Axis.vertical,
              controller: pageController,
              itemCount: reelQuerySnapshot!.docs.length,
              itemBuilder: (context, index) => Reelplayer(
                videoUrl:
                    (reelQuerySnapshot!.docs[index].data() as Map)["videoUrls"],
                userUid:
                    (reelQuerySnapshot!.docs[index].data() as Map)["userUid"],
                videoTitle: (reelQuerySnapshot!.docs[index].data()
                    as Map)["videoTitle"],
              ),
            )
          : const SizedBox.expand(
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.pink,
                ),
              ),
            ),
    );
  }
}

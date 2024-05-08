import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import 'package:mytube/utils/firebase_methods.dart';
import 'package:mytube/widgets/user_video_preview.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key, required this.userUid});
  final String userUid;
  @override
  State<ProfileWidget> createState() {
    return _ProfileWidgetState();
  }
}

class _ProfileWidgetState extends State<ProfileWidget> {
  Map<String, dynamic>? userDetails;
  QuerySnapshot? userVideoQuery;
  bool isLodaing = false;

  @override
  void initState() {
    super.initState();

    getUserDetailsFromFireBase();
  }

  /// Fetches user details from Firebase.
  ///
  /// This method asynchronously retrieves the user details based on the provided user UID.
  /// Once the details are fetched, it triggers a UI update by calling `setState`.
  void getUserDetailsFromFireBase() async {
    setState(() {
      isLodaing = true;
    });
    userDetails = await FirebaseMethods.getUserDetails(widget.userUid, context);
    userVideoQuery =
        await FirebaseMethods.getUserVideos(widget.userUid, context);
    setState(() {
      isLodaing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(65, 255, 144, 181),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: Card(
                child: SizedBox.expand(
                  child: Skeletonizer(
                    enabled: isLodaing,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          height: 100,
                          width: 100,
                          child: userDetails != null
                              ? Image.network(
                                  userDetails!["userImage"],
                                  fit: BoxFit.fill,
                                )
                              : const Center(
                                  child: Text("userImage"),
                                ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                userDetails != null
                                    ? userDetails!["userName"]
                                    : "username",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                            ),
                            Visibility(
                              visible: FirebaseAuth.instance.currentUser!.uid ==
                                      widget.userUid
                                  ? false
                                  : true,
                              child: OutlinedButton(
                                onPressed: () {},
                                child: Text("Follow"),
                                style: OutlinedButton.styleFrom(),
                              ),
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              userDetails != null
                                  ? userDetails!["email"]
                                  : "userEmail",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                "|",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              height: 30,
                              padding: const EdgeInsets.all(5),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                              ),
                              child: Text("Followers: 0"),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: userVideoQuery == null || userVideoQuery!.docs.isEmpty
                  ? const Card(
                      child: SizedBox.expand(
                        child: Center(
                          child: Text("No videos uploaded"),
                        ),
                      ),
                    )
                  : GridView.builder(
                      itemCount: userVideoQuery!.docs.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3),

                      /// Builds an item for the list view.
                      ///
                      /// This function is used as a builder for list items, specifically for displaying video preview cards.
                      /// Each card is constructed with context and video information extracted from a query result.
                      ///
                      /// Parameters:
                      /// - `ctx`: The build context for the widget.
                      /// - `index`: The current index of the item being built, used to access the appropriate data from the query.
                      ///
                      /// Returns:
                      /// A `VideoPreviewCard` widget configured with the video thumbnail and URL from the query data.
                      itemBuilder: (ctx, index) => VideoPreviewCard(
                        userUid: widget.userUid,
                        ctx: context,
                        videoThumbnail: (userVideoQuery!.docs[index].data()
                            as Map)["videoThumbnail"],
                        videoUrl: (userVideoQuery!.docs[index].data()
                            as Map)["videoUrl"],
                        videoTitle: (userVideoQuery!.docs[index].data()
                            as Map)["videoTitle"],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

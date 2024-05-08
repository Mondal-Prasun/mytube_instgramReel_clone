import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class FirebaseMethods {
  /// Retrieves the download URL of a video from Firebase Storage.
  ///
  /// Returns a [Future] that completes with a [String] representing the download URL.
  /// The download URL can be used to access the video file.
  static Future<String> getVideos() async {
    final storageIns = FirebaseStorage.instance.ref("tesing");
    final videoUrl =
        await storageIns.child("testFolder/test.mp4").getDownloadURL();

    return videoUrl;
  }

  /// Signs up a user with the provided information.
  ///
  /// This method creates a new user account using the provided [email] and [password].
  /// It also uploads the [image] file as the user's profile image to Firebase Storage.
  /// The [userName] is used as the user's display name.
  /// The [context] is used to show a SnackBar in case of an error.
  ///
  /// Returns a [UserCredential] object if the sign-up is successful, otherwise returns null.
  static Future<UserCredential?> signUpUser(File image, String userName,
      String email, String password, BuildContext context) async {
    try {
      final user = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await FirebaseStorage.instance
          .ref("user_content/${user.user!.uid}/userProfileImage")
          .child("${user.user!.uid}_profileImage")
          .putFile(image);
      final userImage = await FirebaseStorage.instance
          .ref("user_content/${user.user!.uid}/userProfileImage")
          .child("${user.user!.uid}_profileImage")
          .getDownloadURL();

      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.user!.uid)
          .set({
        "userName": userName,
        "email": email,
        "userImage": userImage,
        "followers": 0,
      });

      return user;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.pink,
          content: Text(e.toString()),
        ),
      );
    }
  }

  // This method logs in a user using their email and password
  static Future<UserCredential?> logInUser(
      String email, String password, BuildContext context) async {
    try {
      final user = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      return user;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.pink,
          content: Text(e.toString()),
        ),
      );
    }
  }

  /// Fetches the details of a user from Firestore based on the user's UID.
  ///
  /// This method queries the "users" collection in Firestore using the provided [userUid]
  /// to retrieve the user's details. If the operation is successful, it returns a [Map<String, dynamic>]
  /// containing the user's details. If an error occurs, it displays a [SnackBar] with the error message.
  ///
  /// [userUid] is the unique identifier for the user whose details are to be fetched.
  /// [context] is the BuildContext from which this method is called, used for displaying the [SnackBar].
  ///
  /// Returns a [Future<Map<String, dynamic>?>] containing the user's details or null if an error occurs.
  static Future<Map<String, dynamic>?> getUserDetails(
      String userUid, BuildContext context) async {
    try {
      final userSnapShot = await FirebaseFirestore.instance
          .collection("users")
          .doc(userUid)
          .get();
      final user = userSnapShot.data() as Map<String, dynamic>;

      return user;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.pink,
          content: Text(e.toString()),
        ),
      );
    }
  }

  /// Uploads a video and its thumbnail to Firebase Storage and Firestore.
  ///
  /// This method uploads a video file along with its thumbnail to Firebase Storage
  /// and then stores the URLs to these files in Firebase Firestore under the user's
  /// document. It also adds the video URL to a collection of all reels.
  ///
  /// [userUid] The unique identifier for the user.
  /// [title] The title of the video, used as part of the file name.
  /// [thumbnail] The File object for the thumbnail image.
  /// [reelVideo] The File object for the video.
  /// [context] The BuildContext for showing SnackBars in case of errors.
  ///
  /// Returns a Future<bool?> which completes with true if the upload was successful,
  /// or completes with null if an exception occurred.
  static Future<bool?> uplaodVideo(String userUid, String title, File thumbnail,
      File reelVideo, BuildContext context) async {
    try {
      final storageIns = FirebaseStorage.instance;

      /// Upload thumbnail to Firebase Storage.
      await storageIns
          .ref("user_content/$userUid/videoThumbnails")
          .child("${title}_${userUid}_thumnail")
          .putFile(thumbnail);

      final thubmNailUrl = await storageIns
          .ref("user_content/$userUid/videoThumbnails")
          .child("${title}_${userUid}_thumnail")
          .getDownloadURL();

      /// Upload video to Firebase Storage.
      await storageIns
          .ref("user_content/$userUid/videos")
          .child("${title}_video")
          .putFile(reelVideo);

      final reelVideoUrl = await storageIns
          .ref("user_content/$userUid/videos")
          .child("${title}_video")
          .getDownloadURL();

      /// Upload video details to Firebase Firestore under the user's document.
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userUid)
          .collection("videos")
          .doc("${userUid}_${title}_details")
          .set({
        "videoThumbnail": thubmNailUrl,
        "videoUrl": reelVideoUrl,
        "videoTitle": title,
      });

      /// Add video URL to a collection of all reels.
      await FirebaseFirestore.instance.collection("allreels").add({
        "videoUrls": reelVideoUrl,
        "videoTitle": title,
        "userUid": userUid,
      });

      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.pink,
          content: Text(e.toString()),
        ),
      );
    }
  }

  // Fetches a user's videos from Firestore based on their UID
  static Future<QuerySnapshot?> getUserVideos(
      String userUid, BuildContext context) async {
    try {
      // Attempt to get the user's videos from Firestore
      final quarySnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(userUid)
          .collection("videos")
          .get();

      return quarySnapshot;
    } catch (e) {
      // Show an error message if the operation fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.pink,
          content: Text(e.toString()),
        ),
      );
    }
  }

  static Future<QuerySnapshot?> getAllVideos(BuildContext context) async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection("allreels").get();
      return querySnapshot;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.pink,
          content: Text(e.toString()),
        ),
      );
    }
  }
}

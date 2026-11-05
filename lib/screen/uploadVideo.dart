import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reel_c/provider/methodChannel.dart';

import 'package:reel_c/provider/server.dart';
import 'package:reel_c/widget/customTextField.dart';
import 'package:video_player/video_player.dart';

class UploadVideoScreen extends StatefulWidget {
  const UploadVideoScreen({super.key});

  @override
  State<UploadVideoScreen> createState() => _UploadVideoScreenState();
}

class _UploadVideoScreenState extends State<UploadVideoScreen> {
  late VideoPlayerController _videoPlayerController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocBuilder<UserApiCubit, UserApiState?>(
        builder: (BuildContext ctx, UserApiState? state) {
          if (state == null) {
            return Text("State is null");
          }
          return Form(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  spacing: 10,
                  mainAxisAlignment: .center,
                  children: [
                    CustomTextFromField(
                      hintText: "Video Name",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Video name cannot be empty";
                        }
                        return null;
                      },
                      onSave: (value) {},
                    ),

                    CustomTextFromField(
                      hintText: "Video Description",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Video description cannot be empty";
                        }
                        return null;
                      },
                      onSave: (value) {},
                    ),
                    BlocBuilder<VideoMethodCubit, String>(
                      builder: (BuildContext ctx, String vidTempPath) {
                        debugPrint("Flutter ui uri: $vidTempPath");
                        if (vidTempPath.isEmpty) {
                          return Container(
                            height: 50,
                            width: 200,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: InkWell(
                              onTap: () async {
                                await context
                                    .read<VideoMethodCubit>()
                                    .getVideoPath();
                              },
                              child: Row(
                                crossAxisAlignment: .center,
                                spacing: 10,
                                children: [Icon(Icons.add), Text("add video")],
                              ),
                            ),
                          );
                        } else {
                          debugPrint(vidTempPath);
                          _videoPlayerController =
                              VideoPlayerController.contentUri(
                                  Uri.parse(vidTempPath),
                                )
                                ..initialize().then((value) {
                                  _videoPlayerController.play();
                                });

                          return Container(
                            height: 300,
                            width: 300,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: AspectRatio(
                                aspectRatio:
                                    _videoPlayerController.value.aspectRatio,
                                child: VideoPlayer(_videoPlayerController),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

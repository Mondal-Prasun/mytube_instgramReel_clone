import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reel_c/provider/methodChannel.dart';
import 'package:reel_c/provider/server.dart';

class UploadVideoScreen extends StatefulWidget {
  const UploadVideoScreen({super.key});

  @override
  State<UploadVideoScreen> createState() => _UploadVideoScreenState();
}

class _UploadVideoScreenState extends State<UploadVideoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.read<VideoMethodCubit>().getVideoBytes();
        },
        child: Icon(Icons.add),
      ),
      body: BlocBuilder<UserApiCubit, UserApiState?>(
        builder: (BuildContext ctx, UserApiState? state) {
          if (state == null) {
            return Text("State is null");
          }
          return BlocBuilder<VideoMethodCubit, Uint8List>(
            builder: (ctx, bytes) {
              return Text("byteLenth: ${bytes.length}");
            },
          );
        },
      ),
    );
  }
}

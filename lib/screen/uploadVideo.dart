import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      body: BlocBuilder<UserApiCubit, UserApiState?>(
        bloc: UserApiCubit(),
        builder: (BuildContext ctx, UserApiState? state) {
          return Text(state!.serverToken!);
        },
      ),
    );
  }
}

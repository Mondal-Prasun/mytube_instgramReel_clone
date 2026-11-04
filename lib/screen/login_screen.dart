import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reel_c/provider/methodChannel.dart';
import 'package:reel_c/provider/server.dart';
import 'package:reel_c/screen/uploadVideo.dart';
import 'package:reel_c/widget/customTextField.dart';

class LoginClass extends StatefulWidget {
  const LoginClass({super.key});

  @override
  State<LoginClass> createState() => _LoginClassState();
}

class _LoginClassState extends State<LoginClass> {
  User user = User();
  final GlobalKey<FormState> _fromKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocBuilder<ApiCubit, ServerState>(
        builder: (BuildContext ctx, ServerState state) {
          if (state == ServerState.none) {
            () async {
              await context.read<ApiCubit>().checkHeath();
            }();
          }

          return switch (state) {
            ServerState.done => Center(
              child: Form(
                key: _fromKey,
                child: Column(
                  spacing: 10,
                  mainAxisAlignment: .center,
                  children: [
                    CustomTextFromField(
                      hintText: "UserName",
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          return null;
                        }
                        return "Cannot be empty";
                      },
                      onSave: (value) {
                        user.userName = value!;
                      },
                    ),

                    CustomTextFromField(
                      hintText: "UserEmail",
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          return null;
                        }
                        return "Cannot be empty";
                      },
                      onSave: (value) {
                        user.userEmail = value!;
                      },
                    ),

                    CustomTextFromField(
                      hintText: "Password",
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          return null;
                        }
                        return "Cannot be empty";
                      },
                      onSave: (value) {
                        user.passWord = value!;
                      },
                    ),

                    ElevatedButton(
                      onPressed: () async {
                        if (_fromKey.currentState!.validate()) {
                          _fromKey.currentState!.save();

                          await context.read<UserApiCubit>().signUp(user);

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BlocProvider(
                                create: (_) => VideoMethodCubit(),
                                child: UploadVideoScreen(),
                              ),
                            ),
                          );
                        }
                      },
                      child: Text("Save"),
                    ),
                  ],
                ),
              ),
            ),
            ServerState.loading => Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            ServerState.error => Center(child: Text("Cannot get Server")),
            ServerState.none => Center(child: Text("Fetching Server")),
          };
        },
      ),
    );
  }
}

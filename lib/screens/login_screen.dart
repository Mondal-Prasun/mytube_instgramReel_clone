import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mytube/screens/feed_screen.dart';
import 'package:mytube/utils/firebase_methods.dart';

import 'package:mytube/utils/image_picker.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState extends State<LoginScreen> {
  File? image;
  final fromkey = GlobalKey<FormState>();
  String? userName;
  String? email;
  String? password;
  bool isUser = false;
  bool isChecking = false;

  /// Displays an AlertDialog to allow the user to choose an image from the gallery or camera.
  ///
  /// This method shows an AlertDialog with two options: "Gallery" and "Camera". When the user selects
  /// "Gallery", it calls the [ImageVideoPicker.getImage] method with the `isGallery` parameter set to true,
  /// and assigns the returned image to the `image` variable. It then calls [setState] to update the UI and
  /// closes the dialog by calling [Navigator.of(context).pop()].
  ///
  /// When the user selects "Camera", it calls the [ImageVideoPicker.getImage] method with the `isGallery`
  /// parameter set to false, and performs the same operations as when selecting "Gallery".
  ///
  /// This method should be called within a StatefulWidget's build method, as it relies on the `context` and
  /// `setState` methods being available.
  void pickedImage() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Choose from gallery or camera"),
        actions: [
          ElevatedButton.icon(
            onPressed: () async {
              image = await ImageVideoPicker.getImage(true, context);
              setState(() {});
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.image),
            label: const Text("Gallery"),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              image = await ImageVideoPicker.getImage(false, context);
              setState(() {});
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.image),
            label: const Text("Camera"),
          ),
        ],
      ),
    );
  }

  /// Handles the form submission.
  ///
  /// This method is called when the user submits the form. It performs the necessary validation
  /// and saves the form data. If the user is logging in, it calls the [logInUser] method from
  /// the [FirebaseMethods] class. If the user is signing up, it calls the [signUpUser] method
  /// from the [FirebaseMethods] class. After successful login or signup, it navigates to the
  /// [FeedScreen] page. If there is an error during the login or signup process, it displays
  /// an error message using a [SnackBar].
  void onSubmit() async {
    setState(() {
      isChecking = true;
    });

    if (fromkey.currentState!.validate()) {
      fromkey.currentState!.save();

      if (isUser == true) {
        FirebaseMethods.logInUser(email!, password!, context).then(
          (user) {
            if (user != null) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => FeedScreen(
                    user: user.user!,
                  ),
                ),
              );
            }
          },
        ).onError((error, stackTrace) {
          setState(() {
            isChecking = false;
          });
        });
      }

      if (isUser == false) {
        if (image != null) {
          FirebaseMethods.signUpUser(
            image!,
            userName!,
            email!,
            password!,
            context,
          ).then((user) {
            if (user != null) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => FeedScreen(
                    user: user.user!,
                  ),
                ),
              );
            }
            setState(() {
              isChecking = false;
            });
          }).onError((error, stackTrace) {
            setState(() {
              isChecking = false;
            });
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.pink,
              content: Text("Image is needed"),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Card(
              child: SizedBox(
                height: isUser ? 200 : 400,
                width: 300,
                child: Column(
                  children: [
                    Visibility(
                      visible: isUser ? false : true,
                      child: InkWell(
                        onTap: pickedImage,
                        child: Container(
                          margin: const EdgeInsets.only(top: 15),
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color:
                                    Theme.of(context).colorScheme.onSecondary),
                          ),
                          child: image == null
                              ? const Icon(
                                  Icons.image,
                                  color: Colors.amber,
                                )
                              : Image.file(
                                  image!,
                                  fit: BoxFit.fill,
                                ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: fromkey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          children: [
                            Visibility(
                              visible: isUser ? false : true,
                              child: TextFormField(
                                maxLength: 40,
                                decoration: const InputDecoration(
                                  helperText: "Enter Username",
                                  hintText: "Username",
                                  hintStyle: TextStyle(
                                    color: Color.fromARGB(84, 0, 0, 0),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please Enter username";
                                  }
                                  return null;
                                },
                                onSaved: (newValue) => userName = newValue!,
                              ),
                            ),
                            TextFormField(
                              maxLength: 40,
                              decoration: const InputDecoration(
                                helperText: "Enter email",
                                hintText: "email",
                                hintStyle: TextStyle(
                                  color: Color.fromARGB(84, 0, 0, 0),
                                ),
                              ),
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    !value.contains("@gmail.com")) {
                                  return "Please Enter valid email";
                                }
                                return null;
                              },
                              onSaved: (newValue) => email = newValue!,
                            ),
                            TextFormField(
                              maxLength: 40,
                              decoration: const InputDecoration(
                                helperText: "Enter password",
                                hintText: "password",
                                hintStyle: TextStyle(
                                  color: Color.fromARGB(84, 0, 0, 0),
                                ),
                              ),
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.length <= 5) {
                                  return "Please Enter valid password 5 charecter long";
                                }
                                return null;
                              },
                              onSaved: (newValue) => password = newValue!,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: isChecking == false
                ? onSubmit
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.pink,
                        content: Text("Wait bro..."),
                      ),
                    );
                  },
            child: isChecking == false
                ? Text(isUser ? "log In" : "Sign up")
                : const SizedBox(
                    height: 15,
                    width: 15,
                    child: CircularProgressIndicator(
                      color: Colors.pink,
                    ),
                  ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                isUser = !isUser;
              });
            },
            child: Text(
                isUser ? "Create a account" : "Login an Excisting account"),
          ),
        ],
      ),
    );
  }
}

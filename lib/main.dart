import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reel_c/provider/server.dart';
import 'package:reel_c/screen/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ApiCubit>(create: (_) => ApiCubit()),
        BlocProvider<UserApiCubit>(create: (_) => UserApiCubit()),
      ],
      child: MaterialApp(
        title: 'Reel_c',
        theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
        home: LoginClass(),
      ),
    );
  }
}

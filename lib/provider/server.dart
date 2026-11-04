import "dart:convert";

import "package:flutter/foundation.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:http/http.dart" as http;

enum ServerState { done, loading, error, none }

class User {
  String userName = "";
  String userEmail = "";
  String passWord = "";
}

class UserApiState {
  UserApiState();

  User? user;
  String? serverToken;
  ServerState state = ServerState.none;
}

class VideoApiState {
  VideoApiState();

  String videoName = "";
  String videoDes = "";
  String videoFilePath = "";
}

final String _localHost = "http://192.168.0.104:8080";

class ApiCubit extends Cubit<ServerState> {
  ApiCubit() : super(ServerState.none);

  Future<void> checkHeath() async {
    try {
      emit(ServerState.loading);

      final res = await http.get(Uri.parse("$_localHost/checkHealth"));

      debugPrint(res.body);

      emit(ServerState.done);
    } catch (e) {
      emit(ServerState.error);
      debugPrint("cannot get health ${e.toString()}");
    }
  }
}

class UserApiCubit extends Cubit<UserApiState?> {
  UserApiCubit() : super(UserApiState());

  Future<void> signUp(User user) async {
    try {
      UserApiState userState = UserApiState();

      userState.state = ServerState.loading;

      emit(userState);

      final body = json.encode({
        "Username": user.userName,
        "UserEmail": user.userEmail,
        "UserPassword": user.passWord,
      });

      final res = await http.post(Uri.parse("$_localHost/signUp"), body: body);

      final parsedRes = json.decode(res.body) as Map<String, dynamic>;

      userState.user = user;
      userState.serverToken = parsedRes["Token"];
      userState.state = ServerState.done;

      emit(userState);

      debugPrint(userState.serverToken);
    } catch (e) {
      emit(UserApiState()..state = ServerState.error);
      debugPrint("cannot signup ${e.toString()}");
    }
  }
}

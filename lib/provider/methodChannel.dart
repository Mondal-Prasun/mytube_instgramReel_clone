import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// class VideoMethodCubit extends Cubit<String> {
//   VideoMethodCubit() : super("");

//   static const _channel = MethodChannel("VIDCHAN");

//   Future<void> getVideoPath() async {
//     try {
//       final res = await _channel.invokeMethod("selectVideo") as String;

//       debugPrint("Flutter side uri: $res");

//       emit(res);
//     } catch (e) {
//       debugPrint("Cannot get video form memory");
//       emit("");
//     }
//   }
// }

class VideoMethodCubit extends Cubit<String> {
  VideoMethodCubit() : super("");

  static const _channel = MethodChannel("VIDCHAN");

  Future<void> getVideoPath() async {
    try {
      final dynamic res = await _channel.invokeMethod("selectVideo");

      debugPrint("Flutter side uri received: $res");

      if (res != null && res is String && res.trim().isNotEmpty) {
        emit(res);
      } else {
        debugPrint("Native side returned null, empty string, or invalid type.");
      }
    } catch (e) {
      debugPrint("Exception during method channel call: $e");
    }
  }
}

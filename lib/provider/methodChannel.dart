import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VideoMethodCubit extends Cubit<Uint8List> {
  VideoMethodCubit() : super(Uint8List.fromList([]));

  static const _channel = MethodChannel("VIDCHAN");

  Future<void> getVideoBytes() async {
    try {
      final res = await _channel.invokeMethod("selectVideo");

      if (res == null) {
        emit(Uint8List.fromList([]));
        return;
      }

      Future.microtask(() {
        emit(Uint8List.fromList(res as List<int>));
      });
    } catch (e) {
      debugPrint("Cannot get video form memory");
      emit(Uint8List.fromList([]));
    }
  }
}

import 'package:Youtility/global.dart' as global;
import 'package:Youtility/utils/logMessage.dart';

Future<void> stopMobileFFmpeg() async {
  try {
    await global.mobileFFmpeg.cancel();
  } catch (e) {
    updateLogMessage("Fained to stop ffmpeg: $e");
  }
}

Future<bool> initMobileFFmpeg() async {
  return await global.mobileFFmpeg.execute("--help") == 0 ? true : false;
}

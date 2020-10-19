import 'package:Youtility/global.dart' as global;
import 'package:Youtility/utils/logMessage.dart';

Future<void> stopMobileFFmpeg(int executionId) async {
  try {
    await global.mobileFFmpeg.cancelExecution(executionId);
  } catch (e) {
    updateLogMessage("Fained to stop ffmpeg: $e");
  }
}

Future<bool> initMobileFFmpeg() async {
  return await global.mobileFFmpeg.execute("--help") == 0 ? true : false;
}

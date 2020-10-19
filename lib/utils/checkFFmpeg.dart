import 'dart:io';

import 'package:Youtility/utils/mobileFFmpegManager.dart';
import 'package:process_run/process_run.dart';

import 'logMessage.dart';

Future<bool> checkFFmpeg() async {
  bool isFFmpegAvailable;
  updateLogMessage("Checking FFmpeg...");
  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    try {
      var output = await run("ffmpeg", ["--help"], verbose: false);
      if (output.exitCode == 1) {
        isFFmpegAvailable = false;
      } else {
        isFFmpegAvailable = true;
      }
    } catch (e) {
      isFFmpegAvailable = false;
    }
  } else if (Platform.isAndroid || Platform.isIOS) {
    print(await initMobileFFmpeg());
    await initMobileFFmpeg()
        ? isFFmpegAvailable = true
        : isFFmpegAvailable = false;
  }
  isFFmpegAvailable
      ? updateLogMessage("FFmpeg detected.")
      : updateLogMessage("FFmpeg not detected.");
  return isFFmpegAvailable;
}

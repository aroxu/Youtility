import 'dart:io';

import 'package:process_run/process_run.dart';

Future<void> killFFmpeg() async {
  try {
    if (Platform.isWindows) {
      await run("taskkill", ["-f", "-im", "ffmpeg.exe"], verbose: false);
    } else if (Platform.isMacOS || Platform.isLinux) {
      await run("killall", ["ffmpeg"], verbose: false);
    }
  } catch (e) {}
}

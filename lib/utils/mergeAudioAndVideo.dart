import 'dart:io';

import 'package:Youtility/utils/logMessage.dart';
import 'package:process_run/process_run.dart';

Future<List<dynamic>> mergeAudioAndVideo(
    String audioPath, String videoPath, String outputPath) async {
  bool success = false;
  Error e;
  try {
    await run(
            "ffmpeg",
            [
              "-i",
              "$audioPath",
              "-i",
              "$videoPath",
              "-c",
              "copy",
              "$outputPath"
            ],
            verbose: true)
        .then(
      (log) => updateLogMessage("Merged Audio and Video using FFmpeg."),
    );
    File(audioPath).deleteSync();
    File(videoPath).deleteSync();
    success = true;
    e = Error();
  } catch (err) {
    e = err;
    updateLogMessage("Error while merging Audio and Video: $e");
    success = false;
  }
  return [success, e];
}

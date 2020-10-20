import 'dart:io';

import 'package:Youtility/utils/logMessage.dart';
import 'package:process_run/process_run.dart';

Future<List<dynamic>> encodeWithAudioAndVideo(
    String audioPath, String videoPath, String outputPath) async {
  bool success = false;
  Error e;
  try {
    var result = await run(
        "ffmpeg",
        [
          "-i",
          "$audioPath",
          "-i",
          "$videoPath",
          "-c:v",
          "copy", // Reason of copy: Default downloaded video codec is VP9.
          "-c:a",
          "aac",
          "$outputPath"
        ],
        verbose: true);
    updateLogMessage("Merged Audio and Video using FFmpeg.");
    File(audioPath).deleteSync();
    File(videoPath).deleteSync();
    result.exitCode == 0 ? success = true : success = false;
    e = Error();
  } catch (err) {
    e = err;
    updateLogMessage("Error while merge and encode Audio and Video: $e");
    success = false;
  }
  return [success, e];
}

Future<List<dynamic>> encodeWithAudioOnly(
    String audioPath, String outputPath) async {
  bool success = false;
  Error e;
  try {
    var result = await run(
        "ffmpeg", ["-i", "$audioPath", "-c:a", "aac", "$outputPath"],
        verbose: true);
    updateLogMessage("Merged Audio and Video using FFmpeg.");
    File(audioPath).deleteSync();
    result.exitCode == 0 ? success = true : success = false;
    e = Error();
  } catch (err) {
    e = err;
    updateLogMessage("Error while encoding Audio: $e");
    success = false;
  }
  return [success, e];
}

Future<List<dynamic>> encodeWithVideoOnly(
    String videoPath, String outputPath) async {
  bool success = false;
  Error e;
  try {
    var result = await run(
        "ffmpeg", ["-i", "$videoPath", "-c:v", "copy", "$outputPath"],
        verbose: true);
    updateLogMessage("Merged Audio and Video using FFmpeg.");
    File(videoPath).deleteSync();
    result.exitCode == 0 ? success = true : success = false;
    e = Error();
  } catch (err) {
    e = err;
    updateLogMessage("Error while encoding Video: $e");
    success = false;
  }
  return [success, e];
}

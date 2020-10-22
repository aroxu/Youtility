import 'dart:io';

import 'package:Youtility/utils/logMessage.dart';
import 'package:process_run/process_run.dart';
import 'package:Youtility/global.dart' as global;

Future<List<dynamic>> encodeWithAudioAndVideo(
    String audioPath, String videoPath, String outputPath) async {
  bool success = false;
  Error e;
  var result;

  try {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      if (global.useCustomFFmpegArgument) {
        List<String> customArgs;
        var _replaceAudio =
            global.customFFmpegArgument.split(" ").indexOf("~[audioFile]");
        var _replaceVideo =
            global.customFFmpegArgument.split(" ").indexOf("~[videoFile]");
        var _replaceOutput =
            global.customFFmpegArgument.split(" ").indexOf("~[outputFile]");
        customArgs = global.customFFmpegArgument.split(" ");
        customArgs[_replaceAudio] = audioPath;
        customArgs[_replaceVideo] = videoPath;
        customArgs[_replaceOutput] = outputPath;
        result = await run("ffmpeg", customArgs, verbose: true);
      } else {
        List<String> fileArgs;

        var _replaceAudio = global.dekstopDefaultAudioAndVideoFFmpegArgument
            .split(" ")
            .indexOf("~[audioFile]");
        var _replaceVideo = global.dekstopDefaultAudioAndVideoFFmpegArgument
            .split(" ")
            .indexOf("~[videoFile]");
        var _replaceOutput = global.dekstopDefaultAudioAndVideoFFmpegArgument
            .split(" ")
            .indexOf("~[outputFile]");
        fileArgs = global.dekstopDefaultAudioAndVideoFFmpegArgument.split(" ");
        fileArgs[_replaceAudio] = audioPath;
        fileArgs[_replaceVideo] = videoPath;
        fileArgs[_replaceOutput] = outputPath;

        List<String> inputFiles = [
          fileArgs[0],
          fileArgs[1],
          fileArgs[2],
          fileArgs[3]
        ];
        List<String> outputFile = [fileArgs[4]];

        if (global.currentAudioEncodeOption == global.AudioEncodeOption.AAC) {
          if (global.currentVideoEncodeOption ==
              global.VideoEncodeOption.H264) {
            result = await run(
                "ffmpeg",
                inputFiles +
                    global.aacAudioCodec +
                    global.h264VideoCodec +
                    outputFile,
                verbose: true);
          }
          if (global.currentVideoEncodeOption ==
              global.VideoEncodeOption.HEVC) {
            result = await run(
                "ffmpeg",
                inputFiles +
                    global.aacAudioCodec +
                    global.hevcVideoCodec +
                    outputFile,
                verbose: true);
          }
          if (global.currentVideoEncodeOption == global.VideoEncodeOption.VP9) {
            result = await run(
                "ffmpeg",
                inputFiles +
                    global.aacAudioCodec +
                    global.vp9VideoCodec +
                    outputFile,
                verbose: true);
          }
        }
        if (global.currentAudioEncodeOption == global.AudioEncodeOption.ALAC) {
          if (global.currentVideoEncodeOption ==
              global.VideoEncodeOption.H264) {
            result = await run(
                "ffmpeg",
                inputFiles +
                    global.alacAudioCodec +
                    global.h264VideoCodec +
                    outputFile,
                verbose: true);
          }
          if (global.currentVideoEncodeOption ==
              global.VideoEncodeOption.HEVC) {
            result = await run(
                "ffmpeg",
                inputFiles +
                    global.alacAudioCodec +
                    global.hevcVideoCodec +
                    outputFile,
                verbose: true);
          }
          if (global.currentVideoEncodeOption == global.VideoEncodeOption.VP9) {
            result = await run(
                "ffmpeg",
                inputFiles +
                    global.alacAudioCodec +
                    global.vp9VideoCodec +
                    outputFile,
                verbose: true);
          }
        }
      }

      updateLogMessage("Merged Audio and Video using FFmpeg.");
      File(audioPath).deleteSync();
      File(videoPath).deleteSync();
      result.exitCode == 0 ? success = true : success = false;
      e = Error();
    }
    if (Platform.isIOS) {
      if (global.useCustomFFmpegArgument) {
        List<String> customArgs;

        var _replaceAudio =
            global.customFFmpegArgument.split(" ").indexOf("~[audioFile]");
        var _replaceVideo =
            global.customFFmpegArgument.split(" ").indexOf("~[videoFile]");
        var _replaceOutput =
            global.customFFmpegArgument.split(" ").indexOf("~[outputFile]");
        customArgs = global.customFFmpegArgument.split(" ");
        customArgs[_replaceAudio] = audioPath;
        customArgs[_replaceVideo] = videoPath;
        customArgs[_replaceOutput] = outputPath;
        await global.mobileFFmpeg.executeWithArguments(customArgs);
      } else {
        List<String> fileArgs;

        var _replaceAudio = global.iOSDefaultAudioAndVideoFFmpegArgument
            .split(" ")
            .indexOf("~[audioFile]");
        var _replaceVideo = global.iOSDefaultAudioAndVideoFFmpegArgument
            .split(" ")
            .indexOf("~[videoFile]");
        var _replaceOutput = global.iOSDefaultAudioAndVideoFFmpegArgument
            .split(" ")
            .indexOf("~[outputFile]");
        fileArgs = global.iOSDefaultAudioAndVideoFFmpegArgument.split(" ");
        fileArgs[_replaceAudio] = audioPath;
        fileArgs[_replaceVideo] = videoPath;
        fileArgs[_replaceOutput] = outputPath;

        List<String> inputFiles = [
          fileArgs[2],
          fileArgs[3],
          fileArgs[4],
          fileArgs[5]
        ];
        List<String> outputFile = [fileArgs[6]];

        updateLogMessage("\n\n${inputFiles.toString()}\n\n");
        updateLogMessage("\n\n${outputFile.toString()}\n\n");

        if (global.currentAudioEncodeOption == global.AudioEncodeOption.AAC) {
          if (global.currentVideoEncodeOption ==
              global.VideoEncodeOption.H264) {
            await global.mobileFFmpeg.executeWithArguments(inputFiles +
                global.aacAudioCodec +
                global.h264VideoCodec +
                outputFile);
          }
          if (global.currentVideoEncodeOption ==
              global.VideoEncodeOption.HEVC) {
            await global.mobileFFmpeg.executeWithArguments(inputFiles +
                global.aacAudioCodec +
                global.hevcVideoCodec +
                outputFile);
          }
          if (global.currentVideoEncodeOption == global.VideoEncodeOption.VP9) {
            await global.mobileFFmpeg.executeWithArguments(inputFiles +
                global.aacAudioCodec +
                global.vp9VideoCodec +
                outputFile);
          }
        }
        if (global.currentAudioEncodeOption == global.AudioEncodeOption.ALAC) {
          if (global.currentVideoEncodeOption ==
              global.VideoEncodeOption.H264) {
            await global.mobileFFmpeg.executeWithArguments(inputFiles +
                global.alacAudioCodec +
                global.h264VideoCodec +
                outputFile);
          }
          if (global.currentVideoEncodeOption ==
              global.VideoEncodeOption.HEVC) {
            await global.mobileFFmpeg.executeWithArguments(inputFiles +
                global.alacAudioCodec +
                global.hevcVideoCodec +
                outputFile);
          }
          if (global.currentVideoEncodeOption == global.VideoEncodeOption.VP9) {
            await global.mobileFFmpeg.executeWithArguments(inputFiles +
                global.alacAudioCodec +
                global.vp9VideoCodec +
                outputFile);
          }
        }
      }

      File(audioPath).deleteSync();
      File(videoPath).deleteSync();
      success = true;
      e = Error();
    }
    if (Platform.isAndroid) {
      if (global.useCustomFFmpegArgument) {
        List<String> customArgs;

        var _replaceAudio =
            global.customFFmpegArgument.split(" ").indexOf("~[audioFile]");
        var _replaceVideo =
            global.customFFmpegArgument.split(" ").indexOf("~[videoFile]");
        var _replaceOutput =
            global.customFFmpegArgument.split(" ").indexOf("~[outputFile]");
        customArgs = global.customFFmpegArgument.split(" ");
        customArgs[_replaceAudio] = audioPath;
        customArgs[_replaceVideo] = videoPath;
        customArgs[_replaceOutput] = outputPath;
        await global.mobileFFmpeg.executeWithArguments(customArgs);
      } else {
        List<String> fileArgs;

        var _replaceAudio = global.androidDefaultAudioAndVideoFFmpegArgument
            .split(" ")
            .indexOf("~[audioFile]");
        var _replaceVideo = global.androidDefaultAudioAndVideoFFmpegArgument
            .split(" ")
            .indexOf("~[videoFile]");
        var _replaceOutput = global.androidDefaultAudioAndVideoFFmpegArgument
            .split(" ")
            .indexOf("~[outputFile]");
        fileArgs = global.androidDefaultAudioAndVideoFFmpegArgument.split(" ");
        fileArgs[_replaceAudio] = audioPath;
        fileArgs[_replaceVideo] = videoPath;
        fileArgs[_replaceOutput] = outputPath;

        List<String> inputFiles = [
          fileArgs[2],
          fileArgs[3],
          fileArgs[4],
          fileArgs[5]
        ];
        List<String> outputFile = [fileArgs[6]];

        if (global.currentAudioEncodeOption == global.AudioEncodeOption.AAC) {
          if (global.currentVideoEncodeOption ==
              global.VideoEncodeOption.H264) {
            await global.mobileFFmpeg.executeWithArguments(inputFiles +
                global.aacAudioCodec +
                global.h264VideoCodec +
                outputFile);
          }
          if (global.currentVideoEncodeOption ==
              global.VideoEncodeOption.HEVC) {
            await global.mobileFFmpeg.executeWithArguments(inputFiles +
                global.aacAudioCodec +
                global.hevcVideoCodec +
                outputFile);
          }
          if (global.currentVideoEncodeOption == global.VideoEncodeOption.VP9) {
            await global.mobileFFmpeg.executeWithArguments(inputFiles +
                global.aacAudioCodec +
                global.vp9VideoCodec +
                outputFile);
          }
        }
        if (global.currentAudioEncodeOption == global.AudioEncodeOption.ALAC) {
          if (global.currentVideoEncodeOption ==
              global.VideoEncodeOption.H264) {
            await global.mobileFFmpeg.executeWithArguments(inputFiles +
                global.alacAudioCodec +
                global.h264VideoCodec +
                outputFile);
          }
          if (global.currentVideoEncodeOption ==
              global.VideoEncodeOption.HEVC) {
            await global.mobileFFmpeg.executeWithArguments(inputFiles +
                global.alacAudioCodec +
                global.hevcVideoCodec +
                outputFile);
          }
          if (global.currentVideoEncodeOption == global.VideoEncodeOption.VP9) {
            await global.mobileFFmpeg.executeWithArguments(inputFiles +
                global.alacAudioCodec +
                global.vp9VideoCodec +
                outputFile);
          }
        }
      }

      File(audioPath).deleteSync();
      File(videoPath).deleteSync();
      success = true;
      e = Error();
    }
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
  var result;

  try {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      if (global.useCustomFFmpegArgument) {
        List<String> customArgs;
        var _replaceAudio =
            global.customFFmpegArgument.split(" ").indexOf("~[audioFile]");
        var _replaceOutput =
            global.customFFmpegArgument.split(" ").indexOf("~[outputFile]");
        customArgs = global.customFFmpegArgument.split(" ");
        customArgs[_replaceAudio] = audioPath;
        customArgs[_replaceOutput] = outputPath;
        result = await run("ffmpeg", customArgs, verbose: true);
      } else {
        List<String> fileArgs;

        var _replaceAudio = global.dekstopDefaultAudioOnlyFFmpegArgument
            .split(" ")
            .indexOf("~[audioFile]");
        var _replaceOutput = global.dekstopDefaultAudioOnlyFFmpegArgument
            .split(" ")
            .indexOf("~[outputFile]");
        fileArgs = global.dekstopDefaultAudioOnlyFFmpegArgument.split(" ");
        fileArgs[_replaceAudio] = audioPath;
        fileArgs[_replaceOutput] = outputPath;

        List<String> inputFiles = [fileArgs[0], fileArgs[1]];
        List<String> outputFile = [fileArgs[2]];

        print(fileArgs);
        print(inputFiles);
        print(outputFile);

        if (global.currentAudioEncodeOption == global.AudioEncodeOption.AAC) {
          if (global.currentAudioFileExtension ==
              global.AudioFileExtension.M4A) {
            result = await run(
                "ffmpeg", inputFiles + global.aacAudioCodec + outputFile,
                verbose: true);
          }
          if (global.currentAudioFileExtension ==
              global.AudioFileExtension.MP3) {
            result = await run(
                "ffmpeg", inputFiles + global.aacAudioCodecMP3 + outputFile,
                verbose: true);
          }
        }
        if (global.currentAudioEncodeOption == global.AudioEncodeOption.ALAC) {
          result = await run(
              "ffmpeg", inputFiles + global.alacAudioCodec + outputFile,
              verbose: true);
        }
      }

      updateLogMessage("Encoded Audio using FFmpeg.");
      File(audioPath).deleteSync();
      result.exitCode == 0 ? success = true : success = false;
      e = Error();
    }
    if (Platform.isIOS) {
      if (global.useCustomFFmpegArgument) {
        List<String> customArgs;

        var _replaceAudio =
            global.customFFmpegArgument.split(" ").indexOf("~[audioFile]");
        var _replaceOutput =
            global.customFFmpegArgument.split(" ").indexOf("~[outputFile]");
        customArgs = global.customFFmpegArgument.split(" ");
        customArgs[_replaceAudio] = audioPath;
        customArgs[_replaceOutput] = outputPath;
        await global.mobileFFmpeg.executeWithArguments(customArgs);
      } else {
        List<String> fileArgs;

        var _replaceAudio = global.iOSDefaultAudioOnlyFFmpegArgument
            .split(" ")
            .indexOf("~[audioFile]");
        var _replaceOutput = global.iOSDefaultAudioOnlyFFmpegArgument
            .split(" ")
            .indexOf("~[outputFile]");
        fileArgs = global.iOSDefaultAudioOnlyFFmpegArgument.split(" ");
        fileArgs[_replaceAudio] = audioPath;
        fileArgs[_replaceOutput] = outputPath;

        List<String> inputFiles = [fileArgs[2], fileArgs[3]];
        List<String> outputFile = [fileArgs[4]];

        if (global.currentAudioEncodeOption == global.AudioEncodeOption.AAC) {
          if (global.currentAudioFileExtension ==
              global.AudioFileExtension.M4A) {
            await global.mobileFFmpeg.executeWithArguments(
                inputFiles + global.aacAudioCodec + outputFile);
          }
          if (global.currentAudioFileExtension ==
              global.AudioFileExtension.MP3) {
            await global.mobileFFmpeg.executeWithArguments(
                inputFiles + global.aacAudioCodecMP3 + outputFile);
          }
        }
        if (global.currentAudioEncodeOption == global.AudioEncodeOption.ALAC) {
          await global.mobileFFmpeg.executeWithArguments(
              inputFiles + global.alacAudioCodec + outputFile);
        }
      }

      File(audioPath).deleteSync();
      success = true;
      e = Error();
    }
    if (Platform.isAndroid) {
      if (global.useCustomFFmpegArgument) {
        List<String> customArgs;

        var _replaceAudio =
            global.customFFmpegArgument.split(" ").indexOf("~[audioFile]");
        var _replaceOutput =
            global.customFFmpegArgument.split(" ").indexOf("~[outputFile]");
        customArgs = global.customFFmpegArgument.split(" ");
        customArgs[_replaceAudio] = audioPath;
        customArgs[_replaceOutput] = outputPath;
        await global.mobileFFmpeg.executeWithArguments(customArgs);
      } else {
        List<String> fileArgs;

        var _replaceAudio = global.androidDefaultAudioOnlyFFmpegArgument
            .split(" ")
            .indexOf("~[audioFile]");
        var _replaceOutput = global.androidDefaultAudioOnlyFFmpegArgument
            .split(" ")
            .indexOf("~[outputFile]");
        fileArgs = global.androidDefaultAudioOnlyFFmpegArgument.split(" ");
        fileArgs[_replaceAudio] = audioPath;
        fileArgs[_replaceOutput] = outputPath;

        List<String> inputFiles = [fileArgs[2], fileArgs[3]];
        List<String> outputFile = [fileArgs[4]];

        if (global.currentAudioEncodeOption == global.AudioEncodeOption.AAC) {
          if (global.currentAudioFileExtension ==
              global.AudioFileExtension.M4A) {
            await global.mobileFFmpeg.executeWithArguments(
                inputFiles + global.aacAudioCodec + outputFile);
          }
          if (global.currentAudioFileExtension ==
              global.AudioFileExtension.MP3) {
            await global.mobileFFmpeg.executeWithArguments(
                inputFiles + global.aacAudioCodecMP3 + outputFile);
          }
        }
        if (global.currentAudioEncodeOption == global.AudioEncodeOption.ALAC) {
          await global.mobileFFmpeg.executeWithArguments(
              inputFiles + global.alacAudioCodec + outputFile);
        }
      }

      File(audioPath).deleteSync();
      success = true;
      e = Error();
    }
  } catch (err) {
    e = err;
    updateLogMessage("Error while merge and encode Audio and Video: $e");
    success = false;
  }
  return [success, e];
}

Future<List<dynamic>> encodeWithVideoOnly(
    String videoPath, String outputPath) async {
  bool success = false;
  Error e;
  var result;

  try {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      if (global.useCustomFFmpegArgument) {
        List<String> customArgs;
        var _replaceVideo =
            global.customFFmpegArgument.split(" ").indexOf("~[videoFile]");
        var _replaceOutput =
            global.customFFmpegArgument.split(" ").indexOf("~[outputFile]");
        customArgs = global.customFFmpegArgument.split(" ");
        customArgs[_replaceVideo] = videoPath;
        customArgs[_replaceOutput] = outputPath;
        result = await run("ffmpeg", customArgs, verbose: true);
      } else {
        List<String> fileArgs;

        var _replaceAudio = global.dekstopDefaultVideoOnlyFFmpegArgument
            .split(" ")
            .indexOf("~[videoFile]");
        var _replaceOutput = global.dekstopDefaultVideoOnlyFFmpegArgument
            .split(" ")
            .indexOf("~[outputFile]");
        fileArgs = global.dekstopDefaultVideoOnlyFFmpegArgument.split(" ");
        fileArgs[_replaceAudio] = videoPath;
        fileArgs[_replaceOutput] = outputPath;

        List<String> inputFiles = [fileArgs[0], fileArgs[1]];
        List<String> outputFile = [fileArgs[2]];

        if (global.currentVideoEncodeOption == global.VideoEncodeOption.H264) {
          result = await run(
              "ffmpeg", inputFiles + global.h264VideoCodec + outputFile,
              verbose: true);
        }
        if (global.currentVideoEncodeOption == global.VideoEncodeOption.HEVC) {
          result = await run(
              "ffmpeg", inputFiles + global.hevcVideoCodec + outputFile,
              verbose: true);
        }
        if (global.currentVideoEncodeOption == global.VideoEncodeOption.VP9) {
          result = await run(
              "ffmpeg", inputFiles + global.vp9VideoCodec + outputFile,
              verbose: true);
        }
      }

      updateLogMessage("Encoded Video using FFmpeg.");
      File(videoPath).deleteSync();
      result.exitCode == 0 ? success = true : success = false;
      e = Error();
    }
    if (Platform.isIOS) {
      if (global.useCustomFFmpegArgument) {
        List<String> customArgs;

        var _replaceVideo =
            global.customFFmpegArgument.split(" ").indexOf("~[videoFile]");
        var _replaceOutput =
            global.customFFmpegArgument.split(" ").indexOf("~[outputFile]");
        customArgs = global.customFFmpegArgument.split(" ");
        customArgs[_replaceVideo] = videoPath;
        customArgs[_replaceOutput] = outputPath;
        await global.mobileFFmpeg.executeWithArguments(customArgs);
      } else {
        List<String> fileArgs;

        var _replaceVideo = global.iOSDefaultVideoOnlyFFmpegArgument
            .split(" ")
            .indexOf("~[videoFile]");
        var _replaceOutput = global.iOSDefaultVideoOnlyFFmpegArgument
            .split(" ")
            .indexOf("~[outputFile]");
        fileArgs = global.iOSDefaultVideoOnlyFFmpegArgument.split(" ");
        fileArgs[_replaceVideo] = videoPath;
        fileArgs[_replaceOutput] = outputPath;

        List<String> inputFiles = [fileArgs[2], fileArgs[3]];
        List<String> outputFile = [fileArgs[4]];

        if (global.currentVideoEncodeOption == global.VideoEncodeOption.H264) {
          await global.mobileFFmpeg.executeWithArguments(
              inputFiles + global.h264VideoCodec + outputFile);
        }
        if (global.currentVideoEncodeOption == global.VideoEncodeOption.HEVC) {
          await global.mobileFFmpeg.executeWithArguments(
              inputFiles + global.hevcVideoCodec + outputFile);
        }
        if (global.currentVideoEncodeOption == global.VideoEncodeOption.VP9) {
          await global.mobileFFmpeg.executeWithArguments(
              inputFiles + global.vp9VideoCodec + outputFile);
        }
      }

      File(videoPath).deleteSync();
      success = true;
      e = Error();
    }
    if (Platform.isAndroid) {
      if (global.useCustomFFmpegArgument) {
        List<String> customArgs;

        var _replaceVideo =
            global.customFFmpegArgument.split(" ").indexOf("~[videoFile]");
        var _replaceOutput =
            global.customFFmpegArgument.split(" ").indexOf("~[outputFile]");
        customArgs = global.customFFmpegArgument.split(" ");
        customArgs[_replaceVideo] = videoPath;
        customArgs[_replaceOutput] = outputPath;
        await global.mobileFFmpeg.executeWithArguments(customArgs);
      } else {
        List<String> fileArgs;

        var _replaceVideo = global.androidDefaultVideoOnlyFFmpegArgument
            .split(" ")
            .indexOf("~[videoFile]");
        var _replaceOutput = global.androidDefaultVideoOnlyFFmpegArgument
            .split(" ")
            .indexOf("~[outputFile]");
        fileArgs = global.androidDefaultVideoOnlyFFmpegArgument.split(" ");
        fileArgs[_replaceVideo] = videoPath;
        fileArgs[_replaceOutput] = outputPath;

        List<String> inputFiles = [fileArgs[2], fileArgs[3]];
        List<String> outputFile = [fileArgs[4]];

        if (global.currentVideoEncodeOption == global.VideoEncodeOption.H264) {
          await global.mobileFFmpeg.executeWithArguments(
              inputFiles + global.h264VideoCodec + outputFile);
        }
        if (global.currentVideoEncodeOption == global.VideoEncodeOption.HEVC) {
          await global.mobileFFmpeg.executeWithArguments(
              inputFiles + global.hevcVideoCodec + outputFile);
        }
        if (global.currentVideoEncodeOption == global.VideoEncodeOption.VP9) {
          await global.mobileFFmpeg.executeWithArguments(
              inputFiles + global.vp9VideoCodec + outputFile);
        }
      }

      File(videoPath).deleteSync();
      success = true;
      e = Error();
    }
  } catch (err) {
    e = err;
    updateLogMessage("Error while merge and encode Audio and Video: $e");
    success = false;
  }
  return [success, e];
}

library youtility.globals;

import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';

var logMessage = "";
bool isJobDone = true;

var audioProgress = -1.00;
var videoProgress = -1.00;
var encodeProgress = -1.00;

int ffmpegExecutionId;

final FlutterFFmpeg mobileFFmpeg = new FlutterFFmpeg();
final FlutterFFmpegConfig mobileFFmpegConfig = new FlutterFFmpegConfig();

enum DownloadOption { VideoOnly, AudioOnly, Both }
DownloadOption currentDownloadOption = DownloadOption.Both;

bool autoMergeEnabled = true;

enum AudioEncodeOption { AAC, OPUS }
AudioEncodeOption currentAudioEncodeOption = AudioEncodeOption.AAC;

enum VideoEncodeOption { VP9, H264, MPEG4 }
VideoEncodeOption currentVideoEncodeOption = VideoEncodeOption.VP9;

bool useCustomFFmpegArgument = false;
String customFFmpegArgument = "-i ~[audioFile] -i ~[videoFile] ~[outputFile]";
final String customFFmpegArgumentExample =
    "-i ~[audioFile] -i ~[videoFile] ~[outputFile]";

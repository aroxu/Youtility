library youtility.globals;

import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';

var logMessage = "";
bool isJobDone = true;

var audioProgress = -1.00;
var videoProgress = -1.00;

int ffmpegExecutionId;

final FlutterFFmpeg mobileFFmpeg = new FlutterFFmpeg();
final FlutterFFmpegConfig mobileFFmpegConfig = new FlutterFFmpegConfig();

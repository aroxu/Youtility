library youtility.globals;

import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';

var logMessage = "";
bool isJobDone = true;

var audioProgress = -1.00;
var videoProgress = -1.00;
bool isEncoding = false;

final List<String> encodeingTexts = [
  "Apple은 VP9 비디오 코덱을 자체적으로 지원하지 않습니다.\n서드파티 프로그램을 사용하거나 비디오 인코딩을 H264로 바꿔보세요.",
  "VP9 비디오 코덱 이외의 비디오 코덱은 인코딩 하는데 오래걸립니다.\n왜냐하면 YouTube에서 VP9 코덱의 파일을 받아오거든요!",
  "Youtility는 오픈소스 프로그램 입니다.",
  "이 텍스트는 5초마다 랜덤으로 바뀝니다.",
  "HEVC 비디오 코덱은 압축률이 높은 대신, 인코딩 시간이 다른 비디오 코덱보다 오래 걸립니다.",
  "기다리는동안 잠시 쉬세요. YouTube를 보는것도 나쁘지 않겠네요.",
  ""
];

final FlutterFFmpeg mobileFFmpeg = new FlutterFFmpeg();
final FlutterFFmpegConfig mobileFFmpegConfig = new FlutterFFmpegConfig();

enum DownloadOption { VideoOnly, AudioOnly, Both }
DownloadOption currentDownloadOption = DownloadOption.Both;

enum AudioEncodeOption { AAC, ALAC }
AudioEncodeOption currentAudioEncodeOption = AudioEncodeOption.AAC;

enum AudioFileExtension { MP3, M4A }
AudioFileExtension currentAudioFileExtension = AudioFileExtension.MP3;

enum VideoEncodeOption { VP9, H264, HEVC }
VideoEncodeOption currentVideoEncodeOption = VideoEncodeOption.VP9;

enum VideoFileExtension { MP4, MOV }
VideoFileExtension currentVideoFileExtension = VideoFileExtension.MP4;

final List<String> vp9VideoCodec = [
  "-c:v",
  "copy"
]; //because YouTube video default video codec = VP9
final List<String> h264VideoCodec = ["-c:v", "libx264"];
final List<String> hevcVideoCodec = ["-c:v", "libx265", "-tag:v", "hvc1"];

final List<String> aacAudioCodecMP3 = ["-c:a", "libmp3lame"];
final List<String> aacAudioCodec = ["-c:a", "aac"];
final List<String> alacAudioCodec = ["-c:a", "alac"];

bool useCustomFFmpegArgument = false;
String customFFmpegArgument = "-i ~[audioFile] -i ~[videoFile] ~[outputFile]";
final String customFFmpegArgumentExample =
    "-i ~[audioFile] -i ~[videoFile] ~[outputFile]";

final String dekstopDefaultAudioAndVideoFFmpegArgument =
    "-i ~[audioFile] -i ~[videoFile] ~[outputFile]";
final String dekstopDefaultAudioOnlyFFmpegArgument =
    "-i ~[audioFile] ~[outputFile]";
final String dekstopDefaultVideoOnlyFFmpegArgument =
    "-i ~[videoFile] ~[outputFile]";

final String iOSDefaultAudioAndVideoFFmpegArgument =
    "-hwaccel videotoolbox -i ~[audioFile] -i ~[videoFile] ~[outputFile]";
final String iOSDefaultAudioOnlyFFmpegArgument =
    "-hwaccel videotoolbox -i ~[audioFile] ~[outputFile]";
final String iOSDefaultVideoOnlyFFmpegArgument =
    "-hwaccel videotoolbox -i ~[videoFile] ~[outputFile]";

final String androidDefaultAudioAndVideoFFmpegArgument =
    "-hwaccel mediacodec -i ~[audioFile] -i ~[videoFile] ~[outputFile]";
final String androidDefaultAudioOnlyFFmpegArgument =
    "-hwaccel mediacodec -i ~[audioFile] ~[outputFile]";
final String androidDefaultVideoOnlyFFmpegArgument =
    "-hwaccel mediacodec -i ~[videoFile] ~[outputFile]";

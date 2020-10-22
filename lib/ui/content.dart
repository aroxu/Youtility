import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:Youtility/ui/animatedBackground.dart';
import 'package:Youtility/ui/animatedWave.dart';
import 'package:Youtility/ui/downloadOption.dart';
import 'package:Youtility/utils/checkFFmpeg.dart';
import 'package:Youtility/utils/fileChooser.dart';
import 'package:Youtility/utils/logMessage.dart';
import 'package:Youtility/utils/encoder.dart';
import 'package:Youtility/utils/mobileFFmpegManager.dart';
import 'package:flutter/material.dart';
import 'package:Youtility/global.dart' as global;
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:package_info/package_info.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:process_run/process_run.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class Content extends StatefulWidget {
  @override
  _ContentState createState() => _ContentState();
}

Widget onBottom(Widget child) => Positioned.fill(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: child,
      ),
    );

class _ContentState extends State<Content> {
  final youtubeURL = TextEditingController();

  String _encodeTexts = global.currentDownloadOption ==
          global.DownloadOption.AudioOnly
      ? "오디오 인코딩중...\n팁: ${global.encodeingTexts[new Random().nextInt(global.encodeingTexts.length - 1)]}"
      : "비디오 인코딩중...\n팁: ${global.encodeingTexts[new Random().nextInt(global.encodeingTexts.length - 1)]}";

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
      return true;
    } else {
      updateLogMessage("Failed to launch URL: $url");
      Widget okButton = FlatButton(
        child: Text("확인"),
        onPressed: () {
          Navigator.pop(context);
        },
      );

      AlertDialog alert = AlertDialog(
        title: Row(children: [
          Icon(Icons.error),
          Padding(
            padding: EdgeInsets.only(right: 4),
          ),
          Text("오류"),
        ]),
        // ignore: unnecessary_brace_in_string_interps
        content: Text("URL을 열 수 없습니다. 브라우저에서 ${url}을 열어주세요."),
        actions: [
          okButton,
        ],
      );

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return alert;
        },
      );
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    const oneSecond = const Duration(seconds: 5);
    new Timer.periodic(
        oneSecond,
        (Timer t) => {
              if (global.isEncoding)
                {
                  setState(() {
                    _encodeTexts = global.currentDownloadOption ==
                            global.DownloadOption.AudioOnly
                        ? "오디오 인코딩중...\n팁: ${global.encodeingTexts[new Random().nextInt(global.encodeingTexts.length - 1)]}"
                        : "비디오 인코딩중...\n팁: ${global.encodeingTexts[new Random().nextInt(global.encodeingTexts.length - 1)]}";
                  })
                }
            });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: AnimatedBackground()),
          onBottom(
            AnimatedWave(
              height: 180,
              speed: 1.0,
            ),
          ),
          onBottom(
            AnimatedWave(
              height: 120,
              speed: 0.9,
              offset: pi,
            ),
          ),
          onBottom(
            AnimatedWave(
              height: 220,
              speed: 1.2,
              offset: pi / 2,
            ),
          ),
          Positioned.fill(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.download_outlined,
                    size: 64,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    padding: EdgeInsets.only(bottom: 12),
                    width: MediaQuery.of(context).size.width * 0.65,
                    child: TextField(
                      controller: youtubeURL,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "YouTube URL을 입력해주세요.",
                        labelText: 'URL',
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(bottom: 12),
                    child: global.audioProgress > -1
                        ? Column(
                            children: [
                              Text(
                                "Audio Downloading: ${global.audioProgress}%",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 24),
                              ),
                              Container(
                                padding: EdgeInsets.only(top: 12),
                                width: MediaQuery.of(context).size.width * 0.65,
                                child: LinearProgressIndicator(
                                  value: global.audioProgress / 100,
                                ),
                              ),
                            ],
                          )
                        : global.videoProgress > -1
                            ? Column(
                                children: [
                                  Text(
                                    "Video Downloading: ${global.videoProgress}%",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 24),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(top: 12),
                                    width: MediaQuery.of(context).size.width *
                                        0.65,
                                    child: LinearProgressIndicator(
                                      value: global.videoProgress / 100,
                                    ),
                                  ),
                                ],
                              )
                            : global.isEncoding
                                ? Text(
                                    _encodeTexts,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 18),
                                  )
                                : Text(
                                    "다운로드 준비됨",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 24),
                                  ),
                  ),
                  RaisedButton.icon(
                    icon: Icon(Icons.settings),
                    label: Text("다운로드 옵션"),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    textColor: Colors.white,
                    color: Colors.black,
                    onPressed: () {
                      Widget okButton = FlatButton(
                        child: Text("확인"),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      );

                      AlertDialog alert = AlertDialog(
                        title: Row(children: [
                          Icon(Icons.settings),
                          Padding(
                            padding: EdgeInsets.only(right: 4),
                          ),
                          Text("다운로드 옵션"),
                        ]),
                        content: DownloadOption(),
                        actions: [
                          okButton,
                        ],
                      );
                      return showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return alert;
                        },
                      );
                    },
                  )
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: new Builder(
        builder: (BuildContext context) {
          return Stack(
            children: [
              Container(
                padding: EdgeInsets.only(right: 16),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: FloatingActionButton(
                    onPressed: () async {
                      bool ffmpegChecked = false;
                      void _showSnackBar(Widget element, Duration duration) {
                        try {
                          Scaffold.of(context).hideCurrentSnackBar();
                        } catch (e) {}
                        Scaffold.of(context).showSnackBar(
                          SnackBar(
                            duration: duration,
                            content: Container(
                              child: element,
                            ),
                          ),
                        );
                      }

                      if (youtubeURL.text.trim() == "" ||
                          !youtubeURL.text.startsWith("http")) {
                        Widget okButton = FlatButton(
                          child: Text("확인"),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        );

                        AlertDialog alert = AlertDialog(
                          title: Row(children: [
                            Icon(Icons.warning),
                            Padding(
                              padding: EdgeInsets.only(right: 4),
                            ),
                            Text("경고"),
                          ]),
                          content: Text("YouTube URL을 입력해주세요."),
                          actions: [
                            okButton,
                          ],
                        );

                        return showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return alert;
                          },
                        );
                      }

                      if (!global.isJobDone) {
                        Widget okButton = FlatButton(
                          child: Text("확인"),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        );

                        AlertDialog alert = AlertDialog(
                          title: Row(children: [
                            Icon(Icons.warning),
                            Padding(
                              padding: EdgeInsets.only(right: 4),
                            ),
                            Text("경고"),
                          ]),
                          content: Text("작업이 진행중입니다. 작업이 완료된 후 다시 시도해주세요."),
                          actions: [
                            okButton,
                          ],
                        );

                        return showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return alert;
                          },
                        );
                      }

                      if (!await checkFFmpeg()) {
                        Widget stopButton = FlatButton(
                          child: Text("중단"),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        );
                        Widget forceButton = FlatButton(
                          child: Text("무시하고 진행하기"),
                          onPressed: () {
                            ffmpegChecked = true;
                            Navigator.pop(context);
                          },
                        );
                        Widget downloadButton = FlatButton(
                          child: Text("FFmpeg 다운로드"),
                          onPressed: () {
                            _launchURL("https://ffmpeg.org/download.html");
                            Navigator.pop(context);
                          },
                        );

                        AlertDialog alert = AlertDialog(
                          title: Row(children: [
                            Icon(Icons.warning),
                            Padding(
                              padding: EdgeInsets.only(right: 4),
                            ),
                            Text("경고"),
                          ]),
                          content: Text(
                              "FFmpeg가 발견되지 않아, 영상을 다운로드 하고 변환할 수 없습니다. 계속 하시겠습니까?"),
                          actions: [
                            downloadButton,
                            forceButton,
                            stopButton,
                          ],
                        );

                        await showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return alert;
                          },
                        );
                      } else {
                        ffmpegChecked = true;
                      }
                      if (!ffmpegChecked) return;

                      global.isJobDone = false;

                      try {
                        _showSnackBar(
                          Row(
                            children: [
                              Icon(Icons.search),
                              Flexible(
                                child: Text("YouTube에서 영상 찾는중..."),
                              ),
                            ],
                          ),
                          Duration(milliseconds: 2500),
                        );
                        var yt = YoutubeExplode();
                        var id = VideoId(youtubeURL.text.trim());
                        var target = await yt.videos.get(id);
                        var audioFile;
                        var videoFile;
                        var audioOutput;
                        var videoOutput;
                        updateLogMessage(
                            "Tried to search ${youtubeURL.text.trim()}");
                        _showSnackBar(
                          Row(
                            children: [
                              Icon(Icons.cloud_download),
                              SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                    '영상 이름: ${target.title}, 재생 시간: ${target.duration.toString().split(".")[0]}'),
                              ),
                            ],
                          ),
                          Duration(milliseconds: 2500),
                        );
                        updateLogMessage(
                            "Found Video ${target.title}, Duration: ${target.duration.toString().split(".")[0]}");
                        var manifest =
                            await yt.videos.streamsClient.getManifest(id);
                        for (var target in manifest.audioOnly.sortByBitrate()) {
                          updateLogMessage("Found Audio: $target");
                        }
                        var audio = manifest.audioOnly.withHighestBitrate();
                        updateLogMessage("Audio Target: $audio");
                        var audioStream = yt.videos.streamsClient.get(audio);

                        String audioDownloadFileExtention = "";
                        String videoDownloadFileExtention = "";
                        if (global.currentAudioFileExtension ==
                            global.AudioFileExtension.MP3)
                          audioDownloadFileExtention = "mp3";
                        if (global.currentAudioFileExtension ==
                            global.AudioFileExtension.M4A)
                          audioDownloadFileExtention = "m4a";
                        if (global.currentVideoFileExtension ==
                            global.VideoFileExtension.MOV)
                          videoDownloadFileExtention = "mov";
                        if (global.currentVideoFileExtension ==
                            global.VideoFileExtension.MP4)
                          videoDownloadFileExtention = "mp4";

                        if (Platform.isMacOS ||
                            Platform.isWindows ||
                            Platform.isLinux) {
                          final destination = await chooseFileDesktop(
                              '${target.title}.${global.currentDownloadOption == global.DownloadOption.AudioOnly ? audioDownloadFileExtention : videoDownloadFileExtention}',
                              '${global.currentDownloadOption == global.DownloadOption.AudioOnly ? "오디오" : "비디오"} 파일',
                              [
                                '${global.currentDownloadOption == global.DownloadOption.AudioOnly ? audioDownloadFileExtention : videoDownloadFileExtention}'
                              ]);
                          if (!destination.canceled) {
                            if (global.currentDownloadOption ==
                                global.DownloadOption.Both) {
                              audioFile =
                                  File("${destination.paths[0]}_audio.webm");
                              if (audioFile.existsSync()) {
                                audioFile.deleteSync();
                              }
                              audioOutput = audioFile.openWrite(
                                  mode: FileMode.writeOnlyAppend);
                              var audioLen = audio.size.totalBytes;
                              var audioCount = -1;
                              updateLogMessage("Started Download.");
                              _showSnackBar(
                                Row(
                                  children: [
                                    Icon(Icons.cloud_download),
                                    SizedBox(width: 4),
                                    Flexible(
                                      child: Text('오디오 다운로드중...'),
                                    ),
                                  ],
                                ),
                                Duration(days: 365),
                              );
                              await for (var data in audioStream) {
                                audioCount += data.length;
                                setState(() {
                                  global.audioProgress = double.parse(
                                      ((audioCount / audioLen) * 100)
                                          .toStringAsFixed(3));
                                });
                                audioOutput.add(data);
                              }
                              await audioOutput.flush();
                              setState(() {
                                global.audioProgress = -1;
                              });

                              updateLogMessage("Audio Download Done.");
                              for (var target
                                  in manifest.videoOnly.sortByVideoQuality()) {
                                updateLogMessage("Found Video: $target");
                              }

                              var _video = manifest.videoOnly
                                  .sortByVideoQuality()
                                  .indexWhere((element) => element
                                      .toString()
                                      .contains("HDR | webm"));
                              if (_video == -1) {
                                _video = manifest.videoOnly
                                    .sortByVideoQuality()
                                    .indexWhere((element) =>
                                        element.toString().contains("webm"));
                              }
                              var video = manifest.videoOnly
                                  .sortByVideoQuality()[_video];
                              updateLogMessage("Video Target: $video");

                              var videoStream =
                                  yt.videos.streamsClient.get(video);
                              videoFile =
                                  File("${destination.paths[0]}_video.webm");
                              if (videoFile.existsSync()) {
                                videoFile.deleteSync();
                              }
                              videoOutput = videoFile.openWrite(
                                  mode: FileMode.writeOnlyAppend);
                              var videoLen = video.size.totalBytes;
                              var videoCount = 0;
                              _showSnackBar(
                                Row(
                                  children: [
                                    Icon(Icons.cloud_download),
                                    SizedBox(width: 4),
                                    Flexible(
                                      child: Text('비디오 다운로드중...'),
                                    ),
                                  ],
                                ),
                                Duration(days: 365),
                              );
                              updateLogMessage("Started Download.");
                              await for (var data in videoStream) {
                                videoCount += data.length;
                                setState(() {
                                  global.videoProgress = double.parse(
                                      ((videoCount / videoLen) * 100)
                                          .toStringAsFixed(3));
                                });
                                videoOutput.add(data);
                              }
                              await videoOutput.flush();
                              setState(() {
                                global.videoProgress = -1.0;
                              });
                              updateLogMessage("Video Download Done.");
                              _showSnackBar(
                                Row(
                                  children: [
                                    Icon(Icons.merge_type),
                                    SizedBox(width: 4),
                                    Flexible(
                                      child: Text('인코딩중...'),
                                    ),
                                  ],
                                ),
                                Duration(days: 365),
                              );
                              updateLogMessage(
                                  "Requesting directory permission...");
                              var mergeFile = File(destination.paths[0]);
                              if (mergeFile.existsSync()) {
                                mergeFile.deleteSync();
                              }
                              await audioOutput.close();
                              await videoOutput.close();
                              setState(() {
                                global.isEncoding = true;
                              });
                              //throw ("STOP!!!");
                              var mergerResult = await encodeWithAudioAndVideo(
                                  audioFile.path,
                                  videoFile.path,
                                  mergeFile.path);
                              setState(() {
                                global.isEncoding = false;
                              });
                              if (!mergerResult[0]) {
                                updateLogMessage(
                                    "Failed to merge audio and video: ${mergerResult[1]}");
                                throw ("Error: invalid FFmpeg argument.");
                              }
                              global.isJobDone = true;
                              Widget okButton = FlatButton(
                                child: Text("확인"),
                                onPressed: () {
                                  try {
                                    Scaffold.of(context).hideCurrentSnackBar();
                                  } catch (e) {}
                                  Navigator.pop(context);
                                },
                              );

                              AlertDialog alert = AlertDialog(
                                title: Row(children: [
                                  Icon(Icons.file_download_done),
                                  Padding(
                                    padding: EdgeInsets.only(right: 4),
                                  ),
                                  Text("완료"),
                                ]),
                                content: Text(
                                    "비디오가 ${destination.paths[0]}에 저장되었습니다."),
                                actions: [
                                  okButton,
                                ],
                              );

                              return showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return alert;
                                },
                              );
                            }
                            if (global.currentDownloadOption ==
                                global.DownloadOption.AudioOnly) {
                              audioFile =
                                  File("${destination.paths[0]}_audio.webm");
                              if (audioFile.existsSync()) {
                                audioFile.deleteSync();
                              }
                              audioOutput = audioFile.openWrite(
                                  mode: FileMode.writeOnlyAppend);
                              var audioLen = audio.size.totalBytes;
                              var audioCount = -1;
                              updateLogMessage("Started Download.");
                              _showSnackBar(
                                Row(
                                  children: [
                                    Icon(Icons.cloud_download),
                                    SizedBox(width: 4),
                                    Flexible(
                                      child: Text('오디오 다운로드중...'),
                                    ),
                                  ],
                                ),
                                Duration(days: 365),
                              );
                              await for (var data in audioStream) {
                                audioCount += data.length;
                                setState(() {
                                  global.audioProgress = double.parse(
                                      ((audioCount / audioLen) * 100)
                                          .toStringAsFixed(3));
                                });
                                audioOutput.add(data);
                              }
                              await audioOutput.flush();
                              setState(() {
                                global.audioProgress = -1;
                              });

                              updateLogMessage("Audio Download Done.");

                              _showSnackBar(
                                Row(
                                  children: [
                                    Icon(Icons.merge_type),
                                    SizedBox(width: 4),
                                    Flexible(
                                      child: Text('인코딩중...'),
                                    ),
                                  ],
                                ),
                                Duration(days: 365),
                              );
                              updateLogMessage(
                                  "Requesting directory permission...");
                              var mergeFile = File(destination.paths[0]);
                              if (mergeFile.existsSync()) {
                                mergeFile.deleteSync();
                              }
                              await audioOutput.close();
                              setState(() {
                                global.isEncoding = true;
                              });
                              var audioEncodeResult = await encodeWithAudioOnly(
                                  audioFile.path, mergeFile.path);
                              setState(() {
                                global.isEncoding = false;
                              });
                              if (!audioEncodeResult[0]) {
                                updateLogMessage(
                                    "Failed to encode audio: ${audioEncodeResult[1]}");
                                throw ("Error: invalid FFmpeg argument.");
                              }
                              global.isJobDone = true;
                              Widget okButton = FlatButton(
                                child: Text("확인"),
                                onPressed: () {
                                  try {
                                    Scaffold.of(context).hideCurrentSnackBar();
                                  } catch (e) {}
                                  Navigator.pop(context);
                                },
                              );

                              AlertDialog alert = AlertDialog(
                                title: Row(children: [
                                  Icon(Icons.file_download_done),
                                  Padding(
                                    padding: EdgeInsets.only(right: 4),
                                  ),
                                  Text("완료"),
                                ]),
                                content: Text(
                                    "오디오가 ${destination.paths[0]}에 저장되었습니다."),
                                actions: [
                                  okButton,
                                ],
                              );

                              return showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return alert;
                                },
                              );
                            }
                            if (global.currentDownloadOption ==
                                global.DownloadOption.VideoOnly) {
                              for (var target
                                  in manifest.videoOnly.sortByVideoQuality()) {
                                updateLogMessage("Found Video: $target");
                              }

                              var _video = manifest.videoOnly
                                  .sortByVideoQuality()
                                  .indexWhere((element) => element
                                      .toString()
                                      .contains("HDR | webm"));
                              if (_video == -1) {
                                _video = manifest.videoOnly
                                    .sortByVideoQuality()
                                    .indexWhere((element) =>
                                        element.toString().contains("webm"));
                              }
                              var video = manifest.videoOnly
                                  .sortByVideoQuality()[_video];
                              updateLogMessage("Video Target: $video");

                              var videoStream =
                                  yt.videos.streamsClient.get(video);
                              videoFile =
                                  File("${destination.paths[0]}_video.webm");
                              if (videoFile.existsSync()) {
                                videoFile.deleteSync();
                              }
                              videoOutput = videoFile.openWrite(
                                  mode: FileMode.writeOnlyAppend);
                              var videoLen = video.size.totalBytes;
                              var videoCount = 0;
                              _showSnackBar(
                                Row(
                                  children: [
                                    Icon(Icons.cloud_download),
                                    SizedBox(width: 4),
                                    Flexible(
                                      child: Text('비디오 다운로드중...'),
                                    ),
                                  ],
                                ),
                                Duration(days: 365),
                              );
                              updateLogMessage("Started Download.");
                              await for (var data in videoStream) {
                                videoCount += data.length;
                                setState(() {
                                  global.videoProgress = double.parse(
                                      ((videoCount / videoLen) * 100)
                                          .toStringAsFixed(3));
                                });
                                videoOutput.add(data);
                              }
                              await videoOutput.flush();
                              setState(() {
                                global.videoProgress = -1.0;
                              });
                              updateLogMessage("Video Download Done.");
                              _showSnackBar(
                                Row(
                                  children: [
                                    Icon(Icons.merge_type),
                                    SizedBox(width: 4),
                                    Flexible(
                                      child: Text('인코딩중...'),
                                    ),
                                  ],
                                ),
                                Duration(days: 365),
                              );
                              updateLogMessage(
                                  "Requesting directory permission...");
                              var mergeFile = File(destination.paths[0]);
                              if (mergeFile.existsSync()) {
                                mergeFile.deleteSync();
                              }
                              await videoOutput.close();
                              setState(() {
                                global.isEncoding = true;
                              });
                              var videoEncodeResult = await encodeWithVideoOnly(
                                  videoFile.path, mergeFile.path);
                              setState(() {
                                global.isEncoding = false;
                              });
                              if (!videoEncodeResult[0]) {
                                updateLogMessage(
                                    "Failed to encode video: ${videoEncodeResult[1]}");
                                throw ("Error: invalid FFmpeg argument.");
                              }
                              global.isJobDone = true;
                              Widget okButton = FlatButton(
                                child: Text("확인"),
                                onPressed: () {
                                  try {
                                    Scaffold.of(context).hideCurrentSnackBar();
                                  } catch (e) {}
                                  Navigator.pop(context);
                                },
                              );

                              AlertDialog alert = AlertDialog(
                                title: Row(children: [
                                  Icon(Icons.file_download_done),
                                  Padding(
                                    padding: EdgeInsets.only(right: 4),
                                  ),
                                  Text("완료"),
                                ]),
                                content: Text(
                                    "비디오가 ${destination.paths[0]}에 저장되었습니다."),
                                actions: [
                                  okButton,
                                ],
                              );

                              return showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return alert;
                                },
                              );
                            }
                          } else {
                            global.isJobDone = true;
                            return _showSnackBar(
                              Row(
                                children: [
                                  Icon(Icons.cancel),
                                  SizedBox(width: 4),
                                  Flexible(
                                    child: Text('다운로드가 취소되었습니다.'),
                                  )
                                ],
                              ),
                              Duration(milliseconds: 2500),
                            );
                          }
                        }
                        if (Platform.isAndroid || Platform.isIOS) {
                          var fileName = target.title
                              .replaceAll(r'\', '')
                              .replaceAll('/', '')
                              .replaceAll('*', '')
                              .replaceAll('?', '')
                              .replaceAll('"', '')
                              .replaceAll('<', '')
                              .replaceAll('>', '')
                              .replaceAll('|', '');
                          var mobileSaveRequest = await getMobileLocalFolder();
                          if (mobileSaveRequest[0]) {
                            var destinationDirectory =
                                mobileSaveRequest[1].path;
                            if (global.currentDownloadOption ==
                                global.DownloadOption.Both) {
                              audioFile = File(
                                  "$destinationDirectory/${fileName}_audio.webm");
                              if (audioFile.existsSync()) {
                                audioFile.deleteSync();
                              }
                              audioOutput = audioFile.openWrite(
                                  mode: FileMode.writeOnlyAppend);
                              var audioLen = audio.size.totalBytes;
                              var audioCount = -1;
                              updateLogMessage("Started Download.");
                              _showSnackBar(
                                Row(
                                  children: [
                                    Icon(Icons.cloud_download),
                                    SizedBox(width: 4),
                                    Flexible(
                                      child: Text('오디오 다운로드중...'),
                                    ),
                                  ],
                                ),
                                Duration(days: 365),
                              );
                              await for (var data in audioStream) {
                                audioCount += data.length;
                                setState(() {
                                  global.audioProgress = double.parse(
                                      ((audioCount / audioLen) * 100)
                                          .toStringAsFixed(3));
                                });
                                audioOutput.add(data);
                              }
                              await audioOutput.flush();
                              setState(() {
                                global.audioProgress = -1;
                              });

                              updateLogMessage("Audio Download Done.");
                              for (var target
                                  in manifest.videoOnly.sortByVideoQuality()) {
                                updateLogMessage("Found Video: $target");
                              }

                              var _video = manifest.videoOnly
                                  .sortByVideoQuality()
                                  .indexWhere((element) => element
                                      .toString()
                                      .contains("HDR | webm"));
                              if (_video == -1) {
                                _video = manifest.videoOnly
                                    .sortByVideoQuality()
                                    .indexWhere((element) =>
                                        element.toString().contains("webm"));
                              }
                              var video = manifest.videoOnly
                                  .sortByVideoQuality()[_video];
                              updateLogMessage("Video Target: $video");

                              var videoStream =
                                  yt.videos.streamsClient.get(video);
                              videoFile = File(
                                  "$destinationDirectory/${fileName}_video.webm");
                              if (videoFile.existsSync()) {
                                videoFile.deleteSync();
                              }
                              videoOutput = videoFile.openWrite(
                                  mode: FileMode.writeOnlyAppend);
                              var videoLen = video.size.totalBytes;
                              var videoCount = 0;
                              _showSnackBar(
                                Row(
                                  children: [
                                    Icon(Icons.cloud_download),
                                    SizedBox(width: 4),
                                    Flexible(
                                      child: Text('비디오 다운로드중...'),
                                    ),
                                  ],
                                ),
                                Duration(days: 365),
                              );
                              updateLogMessage("Started Download.");
                              await for (var data in videoStream) {
                                videoCount += data.length;
                                setState(() {
                                  global.videoProgress = double.parse(
                                      ((videoCount / videoLen) * 100)
                                          .toStringAsFixed(3));
                                });
                                videoOutput.add(data);
                              }
                              await videoOutput.flush();

                              setState(() {
                                global.videoProgress = -1.0;
                              });
                              updateLogMessage("Video Download Done.");
                              _showSnackBar(
                                Row(
                                  children: [
                                    Icon(Icons.merge_type),
                                    SizedBox(width: 4),
                                    Flexible(
                                      child: Text('인코딩중...'),
                                    ),
                                  ],
                                ),
                                Duration(days: 365),
                              );
                              updateLogMessage(
                                  "Requesting directory permission...");
                              var mergeFile = File(
                                  "$destinationDirectory/$fileName.${global.currentDownloadOption == global.DownloadOption.AudioOnly ? audioDownloadFileExtention : videoDownloadFileExtention}");
                              if (mergeFile.existsSync()) {
                                mergeFile.deleteSync();
                              }
                              await audioOutput.close();
                              await videoOutput.close();
                              setState(() {
                                global.isEncoding = true;
                              });
                              var mergerResult = await encodeWithAudioAndVideo(
                                  audioFile.path,
                                  videoFile.path,
                                  mergeFile.path);
                              setState(() {
                                global.isEncoding = false;
                              });
                              if (!mergerResult[0]) {
                                updateLogMessage(
                                    "Failed to merge audio and video: ${mergerResult[1]}");
                              }
                              global.isJobDone = true;
                              Widget okButton = FlatButton(
                                child: Text("확인"),
                                onPressed: () {
                                  try {
                                    Scaffold.of(context).hideCurrentSnackBar();
                                  } catch (e) {}
                                  Navigator.pop(context);
                                },
                              );
                              AlertDialog alert = AlertDialog(
                                title: Row(children: [
                                  Icon(Icons.file_download_done),
                                  Padding(
                                    padding: EdgeInsets.only(right: 4),
                                  ),
                                  Text("완료"),
                                ]),
                                content: Text(
                                    "영상이 ${Platform.isAndroid ? "다운로드" : "파일 > Youtility"} > $fileName.${global.currentDownloadOption == global.DownloadOption.AudioOnly ? audioDownloadFileExtention : videoDownloadFileExtention}에 저장되었습니다."),
                                actions: [
                                  okButton,
                                ],
                              );

                              return showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return alert;
                                },
                              );
                            }
                            if (global.currentDownloadOption ==
                                global.DownloadOption.AudioOnly) {
                              audioFile = File(
                                  "$destinationDirectory/${fileName}_audio.webm");
                              if (audioFile.existsSync()) {
                                audioFile.deleteSync();
                              }
                              audioOutput = audioFile.openWrite(
                                  mode: FileMode.writeOnlyAppend);
                              var audioLen = audio.size.totalBytes;
                              var audioCount = -1;
                              updateLogMessage("Started Download.");
                              _showSnackBar(
                                Row(
                                  children: [
                                    Icon(Icons.cloud_download),
                                    SizedBox(width: 4),
                                    Flexible(
                                      child: Text('오디오 다운로드중...'),
                                    ),
                                  ],
                                ),
                                Duration(days: 365),
                              );
                              await for (var data in audioStream) {
                                audioCount += data.length;
                                setState(() {
                                  global.audioProgress = double.parse(
                                      ((audioCount / audioLen) * 100)
                                          .toStringAsFixed(3));
                                });
                                audioOutput.add(data);
                              }
                              await audioOutput.flush();
                              setState(() {
                                global.audioProgress = -1;
                              });

                              updateLogMessage("Audio Download Done.");
                              _showSnackBar(
                                Row(
                                  children: [
                                    Icon(Icons.merge_type),
                                    SizedBox(width: 4),
                                    Flexible(
                                      child: Text('인코딩중...'),
                                    ),
                                  ],
                                ),
                                Duration(days: 365),
                              );
                              updateLogMessage(
                                  "Requesting directory permission...");
                              var mergeFile = File(
                                  "$destinationDirectory/$fileName.${global.currentDownloadOption == global.DownloadOption.AudioOnly ? audioDownloadFileExtention : videoDownloadFileExtention}");
                              if (mergeFile.existsSync()) {
                                mergeFile.deleteSync();
                              }
                              await audioOutput.close();
                              setState(() {
                                global.isEncoding = true;
                              });
                              var mergerResult = await encodeWithAudioOnly(
                                  audioFile.path, mergeFile.path);
                              setState(() {
                                global.isEncoding = false;
                              });
                              if (!mergerResult[0]) {
                                updateLogMessage(
                                    "Failed to encode audio: ${mergerResult[1]}");
                              }
                              global.isJobDone = true;
                              Widget okButton = FlatButton(
                                child: Text("확인"),
                                onPressed: () {
                                  try {
                                    Scaffold.of(context).hideCurrentSnackBar();
                                  } catch (e) {}
                                  Navigator.pop(context);
                                },
                              );
                              AlertDialog alert = AlertDialog(
                                title: Row(children: [
                                  Icon(Icons.file_download_done),
                                  Padding(
                                    padding: EdgeInsets.only(right: 4),
                                  ),
                                  Text("완료"),
                                ]),
                                content: Text(
                                    "오디오가 ${Platform.isAndroid ? "다운로드" : "파일 > Youtility"} > $fileName.${global.currentDownloadOption == global.DownloadOption.AudioOnly ? audioDownloadFileExtention : videoDownloadFileExtention}에 저장되었습니다."),
                                actions: [
                                  okButton,
                                ],
                              );

                              return showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return alert;
                                },
                              );
                            }
                            if (global.currentDownloadOption ==
                                global.DownloadOption.VideoOnly) {
                              for (var target
                                  in manifest.videoOnly.sortByVideoQuality()) {
                                updateLogMessage("Found Video: $target");
                              }

                              var _video = manifest.videoOnly
                                  .sortByVideoQuality()
                                  .indexWhere((element) => element
                                      .toString()
                                      .contains("HDR | webm"));
                              if (_video == -1) {
                                _video = manifest.videoOnly
                                    .sortByVideoQuality()
                                    .indexWhere((element) =>
                                        element.toString().contains("webm"));
                              }
                              var video = manifest.videoOnly
                                  .sortByVideoQuality()[_video];
                              updateLogMessage("Video Target: $video");

                              var videoStream =
                                  yt.videos.streamsClient.get(video);
                              videoFile = File(
                                  "$destinationDirectory/${fileName}_video.webm");
                              if (videoFile.existsSync()) {
                                videoFile.deleteSync();
                              }
                              videoOutput = videoFile.openWrite(
                                  mode: FileMode.writeOnlyAppend);
                              var videoLen = video.size.totalBytes;
                              var videoCount = 0;
                              _showSnackBar(
                                Row(
                                  children: [
                                    Icon(Icons.cloud_download),
                                    SizedBox(width: 4),
                                    Flexible(
                                      child: Text('비디오 다운로드중...'),
                                    ),
                                  ],
                                ),
                                Duration(days: 365),
                              );
                              updateLogMessage("Started Download.");
                              await for (var data in videoStream) {
                                videoCount += data.length;
                                setState(() {
                                  global.videoProgress = double.parse(
                                      ((videoCount / videoLen) * 100)
                                          .toStringAsFixed(3));
                                });
                                videoOutput.add(data);
                              }
                              await videoOutput.flush();
                              setState(() {
                                global.videoProgress = -1.0;
                              });
                              updateLogMessage("Video Download Done.");
                              _showSnackBar(
                                Row(
                                  children: [
                                    Icon(Icons.merge_type),
                                    SizedBox(width: 4),
                                    Flexible(
                                      child: Text('인코딩중...'),
                                    ),
                                  ],
                                ),
                                Duration(days: 365),
                              );
                              updateLogMessage(
                                  "Requesting directory permission...");
                              var mergeFile = File(
                                  "$destinationDirectory/$fileName.${global.currentDownloadOption == global.DownloadOption.AudioOnly ? audioDownloadFileExtention : videoDownloadFileExtention}");
                              if (mergeFile.existsSync()) {
                                mergeFile.deleteSync();
                              }
                              await videoOutput.close();
                              setState(() {
                                global.isEncoding = true;
                              });
                              var mergerResult = await encodeWithVideoOnly(
                                  videoFile.path, mergeFile.path);
                              setState(() {
                                global.isEncoding = false;
                              });
                              if (!mergerResult[0]) {
                                updateLogMessage(
                                    "Failed to encode video: ${mergerResult[1]}");
                              }
                              global.isJobDone = true;
                              Widget okButton = FlatButton(
                                child: Text("확인"),
                                onPressed: () {
                                  try {
                                    Scaffold.of(context).hideCurrentSnackBar();
                                  } catch (e) {}
                                  Navigator.pop(context);
                                },
                              );
                              AlertDialog alert = AlertDialog(
                                title: Row(children: [
                                  Icon(Icons.file_download_done),
                                  Padding(
                                    padding: EdgeInsets.only(right: 4),
                                  ),
                                  Text("완료"),
                                ]),
                                content: Text(
                                    "비디오가 ${Platform.isAndroid ? "다운로드" : "파일 > Youtility"} > $fileName.${global.currentDownloadOption == global.DownloadOption.AudioOnly ? audioDownloadFileExtention : videoDownloadFileExtention}에 저장되었습니다."),
                                actions: [
                                  okButton,
                                ],
                              );

                              return showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return alert;
                                },
                              );
                            }
                            //jiji
                          } else {
                            setState(() {
                              global.audioProgress = -1;
                              global.videoProgress = -1;
                              global.isJobDone = true;
                            });
                            Widget okButton = FlatButton(
                              child: Text("확인"),
                              onPressed: () {
                                try {
                                  Scaffold.of(context).hideCurrentSnackBar();
                                } catch (e) {}
                                Navigator.pop(context);
                              },
                            );
                            Widget goSettingsButton = FlatButton(
                              child: Text("설정 열기"),
                              onPressed: () {
                                try {
                                  Scaffold.of(context).hideCurrentSnackBar();
                                } catch (e) {}
                                openAppSettings();
                                Navigator.pop(context);
                              },
                            );
                            AlertDialog alert = AlertDialog(
                              title: Row(children: [
                                Icon(Icons.error),
                                Padding(
                                  padding: EdgeInsets.only(right: 4),
                                ),
                                Text("오류"),
                              ]),
                              content: Text(
                                  "권한이 부족하여 진행할 수 없습니다.\n설정 앱에서 수동으로 권한을 부여한 후, 재시도 해주세요."),
                              actions: [
                                goSettingsButton,
                                okButton,
                              ],
                            );

                            return showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return alert;
                              },
                            );
                          }
                        }
                      } catch (e) {
                        updateLogMessage("Error Occured: $e");
                        Widget okButton = FlatButton(
                          child: Text("확인"),
                          onPressed: () {
                            try {
                              Scaffold.of(context).hideCurrentSnackBar();
                            } catch (e) {}
                            Navigator.pop(context);
                          },
                        );
                        AlertDialog alert;
                        if (e
                                .toString()
                                .contains('Invalid YouTube video ID or URL') ==
                            true) {
                          alert = AlertDialog(
                            title: Row(children: [
                              Icon(Icons.error),
                              Padding(
                                padding: EdgeInsets.only(right: 4),
                              ),
                              Text("오류"),
                            ]),
                            content: Text("올바른 YouTube URL을 입력해주세요."),
                            actions: [
                              okButton,
                            ],
                          );
                        } else {
                          // set up the AlertDialog
                          alert = AlertDialog(
                            title: Row(children: [
                              Icon(Icons.error),
                              Padding(
                                padding: EdgeInsets.only(right: 4),
                              ),
                              Text("오류"),
                            ]),
                            content: Text(
                                "다운로드를 시도하는중 오류가 발생했습니다. 다시 시도해주세요.\n오류 내용: $e"),
                            actions: [
                              okButton,
                            ],
                          );
                        }

                        // show the dialog
                        setState(() {
                          global.isEncoding = false;
                          global.isJobDone = true;
                          global.audioProgress = -1;
                          global.videoProgress = -1;
                        });
                        return showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return alert;
                          },
                        );
                      }
                    },
                    tooltip: '검색',
                    child: Icon(Icons.search),
                  ),
                ),
              ),
              Container(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: FloatingActionButton(
                      backgroundColor: Colors.red,
                      onPressed: () {
                        Widget okButton = FlatButton(
                          child: Text("확인"),
                          onPressed: () async {
                            try {
                              if (Platform.isWindows) {
                                await run(
                                    "taskkill", ["-f", "-im", "ffmpeg.exe"],
                                    verbose: false);
                              } else if (Platform.isMacOS || Platform.isLinux) {
                                await run("killall", ["ffmpeg"],
                                    verbose: false);
                              }
                            } catch (e) {}
                            Navigator.pop(context);
                            setState(() {
                              global.audioProgress = -1;
                              global.videoProgress = -1;
                              global.isJobDone = true;
                              global.isEncoding = false;
                            });
                            Phoenix.rebirth(context);
                            if (Platform.isAndroid || Platform.isIOS) {
                              await stopMobileFFmpeg();
                            }
                          },
                        );
                        Widget cancelButton = FlatButton(
                          child: Text("취소"),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        );

                        AlertDialog alert = AlertDialog(
                          title: Row(children: [
                            Icon(Icons.priority_high),
                            Padding(
                              padding: EdgeInsets.only(right: 4),
                            ),
                            Text("확인"),
                          ]),
                          content: Text("진행중인 작업을 중단하고 초기화 할까요?"),
                          actions: [
                            cancelButton,
                            okButton,
                          ],
                        );

                        return showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return alert;
                          },
                        );
                      },
                      tooltip: '초기화',
                      child: Icon(Icons.delete_forever)),
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 16),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: FloatingActionButton(
                      onPressed: () async {
                        var packageInfo = await PackageInfo.fromPlatform();
                        Widget okButton = FlatButton(
                          child: Text("확인"),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        );
                        Widget clearLogButton = FlatButton(
                          child: Text("로그 초기화"),
                          onPressed: () => {clearLogMessage()},
                        );

                        AlertDialog alert = AlertDialog(
                          title: Row(children: [
                            Icon(Icons.info),
                            Padding(
                              padding: EdgeInsets.only(right: 4),
                            ),
                            Text("정보"),
                          ]),
                          content: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("버전 : ${packageInfo.version}"),
                                Text("제작자 : aroxu"),
                                Container(
                                  child: Text(
                                    '⚠️ 본인의 영상이 아니거나 사용 권한이 없다면, 비상업적 용도로만 사용해주세요.\nYoutility를 이용하여 추출한 음성 / 영상을 사용하여 발생하는 모든 책임은 사용자 본인에게 있습니다.',
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                ExpansionTile(
                                  title: Text(
                                    "로그",
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  children: <Widget>[
                                    ListTile(
                                      title: Text(
                                        global.logMessage,
                                        textAlign: TextAlign.left,
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            clearLogButton,
                            okButton,
                          ],
                        );
                        return showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return alert;
                          },
                        );
                      },
                      tooltip: '정보',
                      child: Icon(Icons.info_outlined)),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

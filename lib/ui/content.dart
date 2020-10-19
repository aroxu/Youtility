import 'dart:io';
import 'dart:math';

import 'package:Youtility/ui/animatedBackground.dart';
import 'package:Youtility/ui/animatedWave.dart';
import 'package:Youtility/utils/checkFFmpeg.dart';
import 'package:Youtility/utils/fileChooser.dart';
import 'package:Youtility/utils/logMessage.dart';
import 'package:Youtility/utils/mergeAudioAndVideo.dart';
import 'package:Youtility/utils/mobileFFmpegManager.dart';
import 'package:flutter/material.dart';
import 'package:Youtility/global.dart' as global;
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:package_info/package_info.dart';
import 'package:process_run/process_run.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:clippy/server.dart' as clippy;

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
        title: Text("오류"),
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
                            : Text(
                                "다운로드 준비됨",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 24),
                              ),
                  ),
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
                          title: Text("경고"),
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
                          title: Text("경고"),
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

                      if (!global.isJobDone) {
                        Widget okButton = FlatButton(
                          child: Text("확인"),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        );

                        AlertDialog alert = AlertDialog(
                          title: Text("경고"),
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
                          Duration(milliseconds: 5000),
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
                          Duration(milliseconds: 5000),
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
                        updateLogMessage("Requesting directory permission...");
                        final audioResult = await chooseFile(
                            '${target.title}_audio.webm', '오디오 파일', ['webm']);
                        if (!audioResult.canceled) {
                          updateLogMessage(
                              "File Destination: ${audioResult.paths[0]}");
                          audioFile = File(audioResult.paths[0]);
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
                                Icon(Icons.file_download_done),
                                SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                      '${audioResult.paths[0]} 위치에 다운로드가 완료되었습니다.'),
                                )
                              ],
                            ),
                            Duration(milliseconds: 5000),
                          );
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
                            Duration(milliseconds: 5000),
                          );
                        }
                        for (var target
                            in manifest.videoOnly.sortByVideoQuality()) {
                          updateLogMessage("Found Video: $target");
                        }

                        var _video = manifest.videoOnly
                            .sortByVideoQuality()
                            .indexWhere((element) =>
                                element.toString().contains("HDR | webm"));
                        if (_video == -1) {
                          _video = manifest.videoOnly
                              .sortByVideoQuality()
                              .indexWhere((element) =>
                                  element.toString().contains("webm"));
                        }

                        var video =
                            manifest.videoOnly.sortByVideoQuality()[_video];
                        updateLogMessage("Video Target: $video");

                        var videoStream = yt.videos.streamsClient.get(video);
                        var videoFileName = '${target.title}'
                            .replaceAll(r'\', '')
                            .replaceAll('/', '')
                            .replaceAll('*', '')
                            .replaceAll('?', '')
                            .replaceAll('"', '')
                            .replaceAll('<', '')
                            .replaceAll('>', '')
                            .replaceAll('|', '');
                        updateLogMessage("Requesting directory permission...");
                        final videoResult = await chooseFile(
                            '${videoFileName}_video.webm', '비디오 파일', ['webm']);
                        if (!videoResult.canceled) {
                          updateLogMessage(
                              "File Destination: ${videoResult.paths[0]}");
                          videoFile = File(videoResult.paths[0]);
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
                                Icon(Icons.file_download_done),
                                SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                      '${videoResult.paths[0]} 위치에 다운로드가 완료되었습니다.'),
                                ),
                              ],
                            ),
                            Duration(milliseconds: 5000),
                          );
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
                            Duration(milliseconds: 5000),
                          );
                        }
                        final mergeResult = await chooseFile(
                            '${target.title}.mp4', '비디오 파일', ['mp4']);
                        if (!mergeResult.canceled) {
                          _showSnackBar(
                            Row(
                              children: [
                                Icon(Icons.merge_type),
                                SizedBox(width: 4),
                                Flexible(
                                  child: Text('오디오와 비디오를 합치는중...'),
                                ),
                              ],
                            ),
                            Duration(days: 365),
                          );
                          updateLogMessage(
                              "Requesting directory permission...");
                          var mergeFile = File(mergeResult.paths[0]);
                          if (mergeFile.existsSync()) {
                            mergeFile.deleteSync();
                          }
                          await audioOutput.close();
                          await videoOutput.close();
                          var mergerResult = await mergeAudioAndVideo(
                              audioFile.path, videoFile.path, mergeFile.path);
                          if (!mergerResult[0]) {
                            updateLogMessage(
                                "Failed to merge audio and video: ${mergerResult[1]}");
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
                            Duration(milliseconds: 5000),
                          );
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
                          title: Text("완료"),
                          content:
                              Text("영상이 ${mergeResult.paths[0]}에 저장되었습니다."),
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
                            title: Text("오류"),
                            content: Text("올바른 YouTube URL을 입력해주세요."),
                            actions: [
                              okButton,
                            ],
                          );
                        } else {
                          // set up the AlertDialog
                          alert = AlertDialog(
                            title: Text("오류"),
                            content: Text("다운로드를 시도하는중 오류가 발생했습니다.\n$e"),
                            actions: [
                              okButton,
                            ],
                          );
                        }

                        // show the dialog
                        global.isJobDone = true;
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
                              } else if (Platform.isAndroid || Platform.isIOS) {
                                if (global.ffmpegExecutionId == null) {
                                } else {
                                  await stopMobileFFmpeg(
                                      global.ffmpegExecutionId);
                                }
                              }
                            } catch (e) {}
                            Navigator.pop(context);
                            global.audioProgress = -1;
                            global.videoProgress = -1;
                            Phoenix.rebirth(context);
                          },
                        );
                        Widget cancelButton = FlatButton(
                          child: Text("취소"),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        );

                        AlertDialog alert = AlertDialog(
                          title: Text("확인"),
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
                        Widget copyLogButton = FlatButton(
                          child: Text("클립보드로 로그 복사하기"),
                          onPressed: () async =>
                              {await clippy.write(global.logMessage)},
                        );
                        Widget clearLogButton = FlatButton(
                          child: Text("로그 초기화"),
                          onPressed: () => {clearLogMessage()},
                        );

                        AlertDialog alert = AlertDialog(
                          title: Text("정보"),
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
                            copyLogButton,
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

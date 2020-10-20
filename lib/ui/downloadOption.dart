import 'package:flutter/material.dart';

import 'package:Youtility/global.dart' as global;

class DownloadOption extends StatefulWidget {
  @override
  _DownloadOptionState createState() => _DownloadOptionState();
}

class _DownloadOptionState extends State<DownloadOption> {
  TextEditingController ffmpegArgs = TextEditingController();

  @override
  Widget build(BuildContext context) {
    setState(() {
      ffmpegArgs.text = global.customFFmpegArgument;
    });

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExpansionTile(
            initiallyExpanded: true,
            title: Text(
              "저장방식 옵션",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            children: <Widget>[
              RadioListTile(
                title: Text('오디오만'),
                value: global.DownloadOption.AudioOnly,
                groupValue: global.currentDownloadOption,
                onChanged: (value) {
                  setState(() {
                    global.currentDownloadOption = value;
                  });
                },
              ),
              RadioListTile(
                title: Text('오디오와 비디오'),
                value: global.DownloadOption.Both,
                groupValue: global.currentDownloadOption,
                onChanged: (value) {
                  setState(() {
                    global.currentDownloadOption = value;
                  });
                },
              ),
              RadioListTile(
                title: Text('비디오만'),
                value: global.DownloadOption.VideoOnly,
                groupValue: global.currentDownloadOption,
                onChanged: (value) {
                  setState(() {
                    global.currentDownloadOption = value;
                  });
                },
              ),
              CheckboxListTile(
                title: Text(
                    "오디오와 비디오를 단일파일로 저장\n(저장방식 옵션이 '오디오와 비디오' 일때만 변경 가능합니다.)"),
                onChanged:
                    global.currentDownloadOption == global.DownloadOption.Both
                        ? (bool value) {
                            setState(() {
                              global.autoMergeEnabled = value;
                            });
                          }
                        : null,
                value: global.autoMergeEnabled,
              ),
            ],
          ),
          ExpansionTile(
            title: Text(
              "오디오 인코딩 옵션",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            children: <Widget>[
              RadioListTile(
                title: Text('aac'),
                value: global.AudioEncodeOption.AAC,
                groupValue: global.currentAudioEncodeOption,
                onChanged: (value) {
                  setState(() {
                    global.currentDownloadOption = value;
                  });
                },
              ),
              RadioListTile(
                title: Text('opus(일부 프로그램에서 정상적으로 인식 못할 수 있음)'),
                value: global.AudioEncodeOption.OPUS,
                groupValue: global.currentAudioEncodeOption,
                onChanged: (value) {
                  setState(() {
                    global.currentDownloadOption = value;
                  });
                },
              ),
            ],
          ),
          ExpansionTile(
            title: Text(
              "비디오 인코딩 옵션",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            children: <Widget>[
              RadioListTile(
                title: Text('vp9'),
                value: global.VideoEncodeOption.VP9,
                groupValue: global.currentVideoEncodeOption,
                onChanged: (value) {
                  setState(() {
                    global.currentDownloadOption = value;
                  });
                },
              ),
              RadioListTile(
                title: Text('h264'),
                value: global.VideoEncodeOption.H264,
                groupValue: global.currentVideoEncodeOption,
                onChanged: (value) {
                  setState(() {
                    global.currentDownloadOption = value;
                  });
                },
              ),
              RadioListTile(
                title: Text('mpeg4'),
                value: global.VideoEncodeOption.MPEG4,
                groupValue: global.currentVideoEncodeOption,
                onChanged: (value) {
                  setState(() {
                    global.currentDownloadOption = value;
                  });
                },
              ),
            ],
          ),
          ExpansionTile(
            title: Text(
              "FFmpeg",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            children: <Widget>[
              CheckboxListTile(
                title: Text("사용자 지정 FFmpeg 인자"),
                onChanged: (bool value) {
                  setState(() {
                    global.useCustomFFmpegArgument = value;
                  });
                },
                value: global.useCustomFFmpegArgument,
              ),
              Text(
                "반드시 적용 버튼을 눌러야 인자가 적용됩니다.\n잘못된 인자 사용시 인코딩이 제대로 되지 않을 수 있습니다.\n\n다음 항목은 실제 값으로 변경됩니다:\n~[audioFile]: 오디오 파일의 위치\n~[videoFile]: 비디오 파일의 위치\n~[outputFile]: 내보내질 파일의 위치",
                textAlign: TextAlign.start,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: EdgeInsets.only(top: 12, bottom: 12),
                child: TextField(
                  enabled: global.useCustomFFmpegArgument,
                  controller: ffmpegArgs,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "ex) ${global.customFFmpegArgumentExample}",
                    labelText: 'FFmpeg 인자',
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    padding: EdgeInsets.only(bottom: 12),
                    child: RaisedButton.icon(
                      elevation: 0,
                      disabledElevation: 0,
                      highlightElevation: 0,
                      color: Colors.transparent,
                      icon: Icon(Icons.delete_forever),
                      label: Text("초기화"),
                      onPressed: global.useCustomFFmpegArgument
                          ? () {
                              Widget okButton = FlatButton(
                                child: Text("확인"),
                                onPressed: () {
                                  setState(() {
                                    global.customFFmpegArgument =
                                        global.customFFmpegArgumentExample;
                                  });
                                  Navigator.pop(context);
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
                                content: Text("FFmpeg 인자를 초기화 할까요?"),
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
                            }
                          : null,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(bottom: 12),
                    child: RaisedButton.icon(
                      elevation: 0,
                      disabledElevation: 0,
                      highlightElevation: 0,
                      color: Colors.transparent,
                      icon: Icon(Icons.check),
                      label: Text("적용"),
                      onPressed: global.useCustomFFmpegArgument
                          ? () {
                              setState(() {
                                global.customFFmpegArgument = ffmpegArgs.text;
                              });
                            }
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

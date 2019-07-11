import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';

class CommentItem extends StatefulWidget {
    String username = "";
    String audioUrl = "";


    CommentItem(String username, String audioUrl) {
        this.username = username;
        this.audioUrl = audioUrl;
    }

    @override
    _CommentItemState createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
    Widget playIcon = Icon(Icons.play_arrow, size: 30.0);
    bool _isPlaying = false;
    bool _isPaused = false;
    var _playerSubscription;

    FlutterSound flutterSound = new FlutterSound();

    startPlayer() async {
        String path = await flutterSound.startPlayer(widget.audioUrl);
        print('startPlayer: $path');
        _playerSubscription = flutterSound.onPlayerStateChanged.listen((e) {
            debugPrint(e.toString());
            if (e != null) {
                this.setState(() {
                    this._isPlaying = true;
                    this.playIcon = Icon(Icons.pause, size: 30.0);
                });
            }
            else {
                this.setState(() {
                    this._isPlaying = false;
                    this.playIcon = Icon(Icons.play_arrow, size: 30.0);
                });
            }
        });
    }

    pausePlayer() async {
        String result = await flutterSound.pausePlayer();
    }

    resumePlayer() async {
        String result = await flutterSound.resumePlayer();
    }

    handlePress() {
        if(_isPlaying == false) {
            startPlayer();
            debugPrint("START");
        }
        else if(_isPlaying == true && _isPaused == false) {
            _playerSubscription.pause();
            this.setState(() {
                this._isPaused = true;
                this.playIcon = Icon(Icons.play_arrow, size: 30.0);
            });
            pausePlayer();
            debugPrint("PAUSE");
        }
        else if(_isPlaying == true && _isPaused == true) {
            _playerSubscription.resume();
            this.setState(() {
                this._isPaused = false;
                this.playIcon = Icon(Icons.pause, size: 30.0);
            });
            resumePlayer();
            debugPrint("RESUME");
        }
    }

    @override
    Widget build(BuildContext context) {

        return Container(
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: Colors.black12,
                    )
                ),
            ),
//            color: Colors.white,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                    Padding (
                        padding: EdgeInsets.only(left: 16.0, top: 8.0, bottom: 0.0),
                        child: Text(widget.username),
                    ),
                    Row(
                        children: <Widget>[
                            SizedBox(width: 8.0),
                            GestureDetector(
                                onTap: handlePress,
                                child: this.playIcon,
                            ),

                            SizedBox(width: 8.0),
                            Expanded(
                                child: Container()
                            ),

                            SizedBox(width: 8.0),
                        ],
                    ),
                ],
            )
        );
    }
}

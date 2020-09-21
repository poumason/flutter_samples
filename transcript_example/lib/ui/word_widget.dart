import 'dart:async';

import 'package:flutter/material.dart';
import 'package:transcript_example/model/stt.dart';
import 'package:transcript_example/player/player_bloc.dart';

class WordWidget extends StatefulWidget {
  final PlayerBloc _playerBloc;
  final WordData _data;

  WordWidget(this._playerBloc, this._data, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => WordWidgetState();
}

class WordWidgetState extends State<WordWidget> {
  StreamSubscription<Duration> _positionChangedSubscription;
  Duration _position;

  @override
  void initState() {
    super.initState();
    _position = Duration.zero;
    _positionChangedSubscription = widget
        ._playerBloc.player.onAudioPositionChanged
        .listen(onPositionChanaged);
  }

  @override
  void dispose() {
    _positionChangedSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(widget._data.word,
        softWrap: true, style: _isPlayed(widget._data.offsetInSeconds));
  }

  TextStyle _isPlayed(double offsetInSeconds) {
    if (_position.inMicroseconds >= (widget._data.offset * 100 / 1000)) {
      print(
          '${widget._data.word}: c:$_position, ${_position.inMicroseconds}, off: ${(widget._data.offset / 1000)}');
      return TextStyle(fontSize: 25, color: Colors.black);
    } else {
      return TextStyle(
          fontSize: 25, color: Color.fromARGB(0xFF, 0x88, 0x88, 0x88));
    }
  }

  void onPositionChanaged(Duration position) {
    setState(() {
      _position = position;
    });
  }
}

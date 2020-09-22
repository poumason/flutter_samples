import 'dart:async';

import 'package:flutter/material.dart';
import '../model/stt.dart';
import '../player/player_bloc.dart';

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
    return Text(widget._data.word, softWrap: true, style: _isPlayed());
  }

  TextStyle _isPlayed() {
    // Offset	The time (in 100-nanosecond units) at which the recognized speech begins in the audio stream.
    if (_position.inMicroseconds >= (widget._data.offset * 100 / 1000)) {
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

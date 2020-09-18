import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:transcript_example/player/player_bloc.dart';
import 'package:transcript_example/stt.dart';

class TranscriptContainerWidget extends StatefulWidget {
  final PlayerBloc playerBloc;
  final List<WordData> words;

  TranscriptContainerWidget(this.playerBloc, this.words);

  @override
  State<StatefulWidget> createState() => TranscriptContainerWidgetState();
}

class TranscriptContainerWidgetState extends State<TranscriptContainerWidget> {
  List<WordDataWrapper> _wordDataKey;
  StreamSubscription<Duration> _positionChangedSubscription;
  Duration _position;

  @override
  void initState() {
    super.initState();
    _position = Duration.zero;
    _wordDataKey =
        widget.words.map((e) => WordDataWrapper(GlobalKey(), e)).toList();
    _positionChangedSubscription = widget
        .playerBloc.player.onAudioPositionChanged
        .listen(onPositionChanaged);
  }

  @override
  void dispose() {
    _positionChangedSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(Object context) {
    return SingleChildScrollView(
      child: Text.rich(
        TextSpan(
          style: TextStyle(
              fontSize: 25, color: Color.fromARGB(0xFF, 0x88, 0x88, 0x88)),
          children:
              Iterable.generate(_wordDataKey.length, (i) => i).expand((i) {
            print(_wordDataKey[i].data.word);
            return [
              WidgetSpan(
                child: SizedBox.fromSize(
                  size: Size.zero,
                  key: _wordDataKey[i].key,
                ),
              ),
              TextSpan(
                text: _wordDataKey[i].data.word,
                style: _isPlayed(_wordDataKey[i].data.offsetInSeconds),
              ),
            ];
          }).toList(),
        ),
      ),
    );
  }

  TextStyle _isPlayed(double offsetInSeconds) {
    if (_position.inSeconds > offsetInSeconds) {
      return TextStyle(fontSize: 25, color: Colors.black);
    } else {
      return TextStyle(
          fontSize: 25, color: Color.fromARGB(0xFF, 0x88, 0x88, 0x88));
    }
  }

  int _findPlayingWord() {
    return _wordDataKey.indexWhere((element) {
      var startTime = element.data.offsetInSeconds;
      var endTime =
          element.data.offsetInSeconds + element.data.durationInSeconds;

      if (_position.inSeconds >= startTime && _position.inSeconds < endTime) {
        return true;
      } else {
        return false;
      }
    });
  }

  void onPositionChanaged(Duration position) {
    setState(() {
      _position = position;
    });

    var index = _findPlayingWord();

    Scrollable.ensureVisible(
      _wordDataKey[index].key.currentContext,
      alignment: 0.2,
      duration: Duration(milliseconds: 500),
    );
  }
}

class WordDataWrapper {
  final GlobalKey key;
  final WordData data;

  WordDataWrapper(this.key, this.data);
}

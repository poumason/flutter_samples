import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:transcript_example/ui/word_widget.dart';
import '../model/word_data_wrapper.dart';
import '../model/stt.dart';
import '../player/player_bloc.dart';

class SegmentWords extends StatefulWidget {
  final PlayerBloc playerBloc;
  final List<WordData> words;

  SegmentWords(this.playerBloc, this.words);

  @override
  State<StatefulWidget> createState() => SegmentWordsState();
}

class SegmentWordsState extends State<SegmentWords> {
  List<WordDataWrapper> _wordDataKey;
  StreamSubscription<Duration> _positionChangedSubscription;
  Duration _position;
  ScrollController _scrollController;
  int _focusWordIndex;

  @override
  void initState() {
    super.initState();
    _position = Duration.zero;
    _focusWordIndex = -1;
    _wordDataKey =
        widget.words.map((e) => WordDataWrapper(GlobalKey(), e)).toList();
    _positionChangedSubscription = widget
        .playerBloc.player.onAudioPositionChanged
        .listen(onPositionChanaged);
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _positionChangedSubscription.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(Object context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: BouncingScrollPhysics(),
        child: Text.rich(
          TextSpan(
            style: TextStyle(
                fontSize: 25, color: Color.fromARGB(0xFF, 0x88, 0x88, 0x88)),
            children: Iterable.generate(_wordDataKey.length, (i) => i)
                .expand((i) => [
                      WidgetSpan(
                          child: WordWidget(
                        widget.playerBloc,
                        _wordDataKey[i].data,
                        key: _wordDataKey[i].key,
                      ))
                    ])
                .toList(),
          ),
        ),
      ),
    );
  }

  void onPositionChanaged(Duration position) {
    _position = position;
    var index = _findPlayingWord();

    if (index >= 0 && index < _wordDataKey.length && index != _focusWordIndex) {
      _scrollController.position.ensureVisible(
        _wordDataKey[index].key.currentContext.findRenderObject(),
        // How far into view the item should be scrolled (between 0 and 1).
        alignment: 0.5,
        duration: const Duration(seconds: 1),
      );

      _focusWordIndex = index;
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
}

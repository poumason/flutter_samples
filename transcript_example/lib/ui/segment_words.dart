import 'dart:async';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
// import './custom_text_selection_controls.dart';
import '../ui/word_widget.dart';
import '../model/word_data_wrapper.dart';
import '../model/stt.dart';
import '../player/player_bloc.dart';
import '../extension_methods/duration_extensions.dart';

class SegmentWords extends StatefulWidget {
  final PlayerBloc _playerBloc;
  final Duration _startDuration;
  final String _displayText;
  final List<WordData> words;
  final bool enableTranscript;

  SegmentWords(
      this._playerBloc, this._startDuration, this._displayText, this.words,
      {this.enableTranscript = false});

  @override
  State<StatefulWidget> createState() => SegmentWordsState();
}

class SegmentWordsState extends State<SegmentWords> {
  List<WordDataWrapper> _wordDataKey;
  StreamSubscription<Duration> _positionChangedSubscription;
  Duration _position;
  ScrollController _scrollController;
  int _focusWordIndex;
  // CustomTextSelectionControls _customTextSelectionControls;

  @override
  void initState() {
    super.initState();
    _position = Duration.zero;
    _focusWordIndex = -1;
    _wordDataKey =
        widget.words.map((e) => WordDataWrapper(GlobalKey(), e)).toList();
    _positionChangedSubscription = widget
        ._playerBloc.player.onAudioPositionChanged
        .listen(onPositionChanaged);
    _scrollController = ScrollController();
    // _customTextSelectionControls = CustomTextSelectionControls();
  }

  @override
  void dispose() {
    _positionChangedSubscription.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(Object context) {
    return SingleChildScrollView(
      controller: _scrollController,
      physics: BouncingScrollPhysics(),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RaisedButton.icon(
                onPressed: () {
                  widget._playerBloc
                      .add(PlayerBlocSeekEvent(widget._startDuration));
                },
                icon: Icon(Icons.music_note),
                label: Text(
                    '從 ${widget._startDuration.getFormattedMinuteSecondPosition()} 開始')),
            widget.enableTranscript == false
                ? ExtendedText(
                    '${widget._displayText}\n',
                    style: TextStyle(fontSize: 25, color: Colors.black),
                    softWrap: true,
                    selectionEnabled: true,
                    // selectionControls: _customTextSelectionControls,
                  )
                : ExtendedText.rich(
                    TextSpan(
                      style: TextStyle(
                          fontSize: 25,
                          color: Color.fromARGB(0xFF, 0x88, 0x88, 0x88)),
                      children: Iterable.generate(_wordDataKey.length, (i) => i)
                          .expand((i) => [
                                WidgetSpan(
                                    child: WordWidget(
                                  widget._playerBloc,
                                  _wordDataKey[i].data,
                                  key: _wordDataKey[i].key,
                                ))
                              ])
                          .toList(),
                    ),
                    style: TextStyle(fontSize: 25, color: Colors.black),
                    softWrap: true,
                    selectionEnabled: true,
                    // selectionControls: _customTextSelectionControls,
                  )
          ]),
    );
  }

  void onPositionChanaged(Duration position) {
    _position = position;
    if (_position.inMicroseconds >=
        _wordDataKey.last.data.offset * 100 / 1000) {
      return;
    }
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

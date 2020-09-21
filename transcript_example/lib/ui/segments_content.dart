import 'dart:async';

import 'package:flutter/material.dart';
import '../ui/segment_words.dart';
import '../model/stt.dart';
import '../player/player_bloc.dart';

class SegmentsContent extends StatefulWidget {
  final PlayerBloc _playerBloc;
  final List<SegmentResult> _segments;
  final bool enableTranscript;

  SegmentsContent(this._playerBloc, this._segments,
      {this.enableTranscript = false});

  @override
  State<StatefulWidget> createState() => SegmentContentState();
}

class SegmentContentState extends State<SegmentsContent> {
  final PageController controller = PageController();
  StreamSubscription<Duration> _positionChangedSubscription;
  Duration _position;

  @override
  void initState() {
    super.initState();
    _positionChangedSubscription = widget
        ._playerBloc.player.onAudioPositionChanged
        .listen(onPositionChanged);
  }

  @override
  void dispose() {
    _positionChangedSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: controller,
      scrollDirection: Axis.vertical,
      children: _buildSegmentPages(),
    );
  }

  List<Widget> _buildSegmentPages() {
    return widget._segments.map((e) {
      var nBest = e.nBest.first;
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: SegmentWords(
          widget._playerBloc,
          Duration(seconds: e.offsetInSeconds.toInt()),
          nBest.display,
          nBest.words,
          enableTranscript: widget.enableTranscript,
        ),
      );
    }).toList();
  }

  void onPositionChanged(Duration position) {
    _position = position;

    var pageIndex = _findSegmentPage();
    if (pageIndex >= 0 && pageIndex != controller.page) {
      controller.jumpToPage(pageIndex);
    }
  }

  int _findSegmentPage() {
    return widget._segments.indexWhere((element) {
      var startTime = element.offsetInSeconds;
      var endTime = element.offsetInSeconds + element.durationInSeconds;

      if (_position.inSeconds >= startTime && _position.inSeconds < endTime) {
        return true;
      } else {
        return false;
      }
    });
  }
}

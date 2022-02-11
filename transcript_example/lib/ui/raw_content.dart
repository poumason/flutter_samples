import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import '../model/stt.dart';
import '../player/player_bloc.dart';
import '../extension_methods/duration_extensions.dart';
// import 'custom_text_selection_controls.dart';

class RawContent extends StatelessWidget {
  final PlayerBloc _playerBloc;
  final List<SegmentResult> _segments;

  RawContent(this._playerBloc, this._segments);
  // final _customTextSelectionControls = CustomTextSelectionControls();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Column(
            children: _buildSegments(),
          )),
    );
  }

  List<Widget> _buildSegments() {
    return _segments.map((e) {
      return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RaisedButton.icon(
                onPressed: () {
                  _playerBloc.add(PlayerBlocSeekEvent(
                      Duration(seconds: e.offsetInSeconds.toInt())));
                },
                icon: Icon(Icons.music_note),
                label:
                    Text('從 ${_convertStartPosition(e.offsetInSeconds)} 開始')),
            ExtendedText(
              '${e.nBest.first.display}\n',
              style: TextStyle(fontSize: 25, color: Colors.black),
              softWrap: true,
              selectionEnabled: true,
              // selectionControls: _customTextSelectionControls,
            )
          ]);
    }).toList();
  }

  String _convertStartPosition(double seconds) {
    var duration = Duration(seconds: seconds.toInt());
    return duration.getFormattedMinuteSecondPosition();
  }
}

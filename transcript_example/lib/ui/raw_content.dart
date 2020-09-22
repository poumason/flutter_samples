import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../model/stt.dart';
import '../player/player_bloc.dart';
import '../extension_methods/duration_extensions.dart';

class RawContent extends StatelessWidget {
  final PlayerBloc _playerBloc;
  final List<SegmentResult> _segments;

  RawContent(this._playerBloc, this._segments);

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
            SelectableText(
              '${e.nBest.first.display}\n',
              style: TextStyle(fontSize: 25, color: Colors.black),
              showCursor: true,
              toolbarOptions: ToolbarOptions(copy: true, selectAll: true),
            )
          ]);
    }).toList();
  }

  String _convertStartPosition(double seconds) {
    var duration = Duration(seconds: seconds.toInt());
    return duration.getFormattedMinuteSecondPosition();
  }

  SelectableText _buildSelectableText() {
    return SelectableText.rich(
      TextSpan(
        style: TextStyle(fontSize: 25, color: Colors.black),
        children: Iterable.generate(_segments.length, (i) => i)
            .expand((i) => [
                  TextSpan(
                    text: '${_segments[i].nBest.first.display}\n\n',
                  )
                ])
            .toList(),
      ),
      showCursor: true,
      toolbarOptions: ToolbarOptions(copy: true, selectAll: true),
    );
  }

  LongPressGestureRecognizer _buildLongPres(BuildContext context) {
    return LongPressGestureRecognizer()
      ..onLongPress = () {
        showMenu(
          context: context,
          position: RelativeRect.fromLTRB(0.0, 300.0, 300.0, 0.0),
          items: [
            PopupMenuItem(
              child: RaisedButton(
                child: Text('Share'),
                onPressed: () => {},
              ),
            ),
          ],
        );
      };
  }
}

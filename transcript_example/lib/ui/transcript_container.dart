import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../player/player_bloc.dart';
import '../ui/segments_content.dart';
import '../display_content_bloc.dart';
import '../model/stt.dart';
import '../ui/raw_content.dart';

class TranscriptContainer extends StatelessWidget {
  final PlayerBloc _playerBloc;
  final STT _data;

  TranscriptContainer(this._playerBloc, this._data);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
        bloc: BlocProvider.of<DisplayContentBloc>(context),
        builder: (BuildContext context, DisplayContentState state) {
          Widget result;

          switch (state.type) {
            case DisplayContentType.segements:
              result = SegmentsContent(_playerBloc, _data.segmentResults);
              break;
            case DisplayContentType.words:
              result = SegmentsContent(_playerBloc, _data.segmentResults,
                  enableTranscript: true);
              break;
            default:
              result = RawContent(_playerBloc, _data.segmentResults);
              break;
          }

          return ExtendedTextSelectionPointerHandler(
            builder: (List<ExtendedTextSelectionState> states) {
              return Listener(
                child: result,
                behavior: HitTestBehavior.translucent,
                onPointerDown: (PointerDownEvent value) {
                  for (final state in states) {
                    if (!state.containsPosition(value.position)) {
                      //clear other selection
                      state.clearSelection();
                    }
                  }
                },
                onPointerMove: (PointerMoveEvent value) {
                  //clear other selection
                  for (final state in states) {
                    state.clearSelection();
                  }
                },
              );
            },
          );
        });
  }
}

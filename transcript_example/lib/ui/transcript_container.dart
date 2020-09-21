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
        cubit: BlocProvider.of<DisplayContentBloc>(context),
        builder: (BuildContext context, DisplayContentState state) {
          switch (state.type) {
            case DisplayContentType.segements:
              return SegmentsContent(_playerBloc, _data.segmentResults);
            case DisplayContentType.words:
              return SegmentsContent(_playerBloc, _data.segmentResults,
                  enableTranscript: true);
            default:
              return RawContent(_playerBloc, _data.segmentResults);
          }
        });
  }
}

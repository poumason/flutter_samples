import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

enum DisplayContentType { raw, segements, words }

class DisplayContentBloc extends Bloc<DisplayEvent, DisplayContentState> {
  DisplayContentBloc()
      : super(DisplayContentState(type: DisplayContentType.raw)) {
    on((event, emit) => {emit(DisplayContentState(type: event.type))});
    add(DisplayEvent(type: DisplayContentType.raw));
  }

  // @override
  // Stream<DisplayContentState> mapEventToState(DisplayEvent event) async* {
  //   yield DisplayContentState(type: event.type);
  // }
}

class DisplayEvent {
  final DisplayContentType type;
  DisplayEvent({@required this.type});
}

class DisplayContentState {
  final DisplayContentType type;
  DisplayContentState({@required this.type});
}

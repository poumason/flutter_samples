import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class PlayerBloc extends Bloc<PlayerBlocEvent, PlayerBlocState> {
  final AudioPlayer player = AudioPlayer();

  StreamSubscription<PlayerState> onPlayerStateChangedSubscription;
  StreamSubscription<Duration> onDurationChangedSubscription;
  StreamSubscription<Duration> onPositionChangedSubscription;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  PlayerBloc() : super(PlayerBlocStoppedState()) {
    onPlayerStateChangedSubscription =
        player.onPlayerStateChanged.listen(onPlayerStateChanged);
    onDurationChangedSubscription =
        player.onDurationChanged.listen(onDurationChanged);
    player.onAudioPositionChanged.listen(onPositionChanged);

    on<PlayerBlocEvent>((event, emit) async {
      if (event is PlayerBlocPlayEvent) {
        emit(PlayerBlocLoadingState());
        var file = await _getAudioFilePath();
        var result = await player.play(file, isLocal: true);
        emit(result == 1 ? PlayerBlocPlayingState() : PlayerBlocStoppedState());
      }

      if (event is PlayerBlocStopEvent) {
        await player.stop();
        emit(PlayerBlocStoppedState());
      }

      if (event is PlayerBlocStoppedEvent) {
        emit(PlayerBlocStoppedState());
      }

      if (event is PlayerBlocPauseEvent) {
        var state = this.state;
        if (state is PlayerBlocPlayingState) {
          await player.pause();
          emit(PlayerBlocPausedState());
        }
      }

      if (event is PlayerBlocResumeEvent) {
        var state = this.state;
        if (state is PlayerBlocPausedState) {
          await player.resume();
          emit(PlayerBlocPlayingState());
        } else {
          add(PlayerBlocPlayEvent());
        }
      }

      if (event is PlayerBlocSeekEvent) {
        if (!isIdle) {
          await player.seek(event.position);
        }
      }

      if (event is PlayerBlocGoBackwardEvent) {
        await _calcuateNewPosition(true);
      }

      if (event is PlayerBlocGoForwardEvent) {
        await _calcuateNewPosition(false);
      }

      if (event is PlayerBlocEnableSkipAdvEvent) {
        emit(PlayerBlocSkipAdvState());
      }
    });
  }

  void onPlayerStateChanged(PlayerState state) {}

  Duration get position {
    if (!isIdle) {
      return _position;
    } else {
      return Duration.zero;
    }
  }

  void onPositionChanged(Duration position) {
    _position = position;
    print('${_position.inMilliseconds}/${_position.inMicroseconds}');
  }

  void onDurationChanged(Duration duration) {
    _duration = duration;
  }

  Duration get duration {
    if (!isIdle) {
      return _duration;
    } else {
      return Duration.zero;
    }
  }

  bool get isIdle {
    return player.state == null ||
        player.state == PlayerState.COMPLETED ||
        player.state == PlayerState.STOPPED;
  }

  @override
  Stream<PlayerBlocState> mapEventToState(
    PlayerBlocEvent event,
  ) async* {
    if (event is PlayerBlocPlayEvent) {
      yield PlayerBlocLoadingState();
      var file = await _getAudioFilePath();
      var result = await player.play(file, isLocal: true);
      yield result == 1 ? PlayerBlocPlayingState() : PlayerBlocStoppedState();
    }

    if (event is PlayerBlocStopEvent) {
      await player.stop();
      yield PlayerBlocStoppedState();
    }

    if (event is PlayerBlocStoppedEvent) {
      yield PlayerBlocStoppedState();
    }

    if (event is PlayerBlocPauseEvent) {
      var state = this.state;
      if (state is PlayerBlocPlayingState) {
        await player.pause();
        yield PlayerBlocPausedState();
      }
    }

    if (event is PlayerBlocResumeEvent) {
      var state = this.state;
      if (state is PlayerBlocPausedState) {
        await player.resume();
        yield PlayerBlocPlayingState();
      } else {
        add(PlayerBlocPlayEvent());
      }
    }

    if (event is PlayerBlocSeekEvent) {
      if (!isIdle) {
        await player.seek(event.position);
      }
    }

    if (event is PlayerBlocGoBackwardEvent) {
      await _calcuateNewPosition(true);
    }

    if (event is PlayerBlocGoForwardEvent) {
      await _calcuateNewPosition(false);
    }

    if (event is PlayerBlocEnableSkipAdvEvent) {
      yield PlayerBlocSkipAdvState();
    }
  }

  Future _calcuateNewPosition(bool goBackward) async {
    const offsetSeconds = 30;
    var newSeconds = 0;

    if (goBackward) {
      newSeconds = position.inSeconds.toInt() - offsetSeconds;
    } else {
      newSeconds = position.inSeconds.toInt() + offsetSeconds;
    }

    if (!isIdle) {
      await player.seek(Duration(seconds: newSeconds));
    }
  }

  Future<String> _getAudioFilePath() async {
    const fileName = 'audio.mp3';
    var source = await rootBundle.load('assets/$fileName');
    var file = File('${(await getTemporaryDirectory()).path}/$fileName');
    await file.create(recursive: true);
    await file.writeAsBytes(source.buffer.asUint8List());
    return file.path;
  }

  @override
  Future<void> close() {
    onPlayerStateChangedSubscription.cancel();
    onDurationChangedSubscription.cancel();
    onPositionChangedSubscription.cancel();
    player.dispose();
    return super.close();
  }
}

class PlayerBlocState {}

class PlayerBlocWorkingState extends PlayerBlocState {
  PlayerBlocWorkingState();
}

class PlayerBlocStoppedState extends PlayerBlocState {}

class PlayerBlocLoadingState extends PlayerBlocWorkingState {
  PlayerBlocLoadingState() : super();
}

class PlayerBlocPlayingState extends PlayerBlocWorkingState {
  PlayerBlocPlayingState() : super();
}

class PlayerBlocPausedState extends PlayerBlocWorkingState {
  PlayerBlocPausedState() : super();
}

class PlayerBlocSkipAdvState extends PlayerBlocWorkingState {
  PlayerBlocSkipAdvState() : super();
}

class PlayerBlocEvent {}

class PlayerBlocPlayEvent extends PlayerBlocEvent {}

class PlayerBlocPauseEvent extends PlayerBlocEvent {}

class PlayerBlocResumeEvent extends PlayerBlocEvent {}

class PlayerBlocPreviousEvent extends PlayerBlocEvent {}

class PlayerBlocNextEvent extends PlayerBlocEvent {}

class PlayerBlocStopEvent extends PlayerBlocEvent {}

class PlayerBlocStoppedEvent extends PlayerBlocEvent {}

class PlayerBlocSeekEvent extends PlayerBlocEvent {
  final Duration position;

  PlayerBlocSeekEvent(this.position);
}

class PlayerBlocGoForwardEvent extends PlayerBlocEvent {}

class PlayerBlocGoBackwardEvent extends PlayerBlocEvent {}

class PlayerBlocEnableSkipAdvEvent extends PlayerBlocEvent {}

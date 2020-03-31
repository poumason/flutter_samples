import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioPlayerTask extends BackgroundAudioTask {
  AudioPlayer _audioPlayer = AudioPlayer();
  Completer _completer = Completer();
  bool _playing;

  final MediaControl playControl;
  final MediaControl pauseControl;
  final MediaControl stopControl;

  AudioPlayerTask(this.playControl, this.pauseControl, this.stopControl);

  @override
  Future<void> onStart() async {
    var playerStateSubscription =
        _audioPlayer.onPlayerStateChanged.listen((event) async {
      var state = _stateToBasicState(event);

      if (state != BasicPlaybackState.stopped) {
        await _setState(
          state: state,
          //position: event.position.inMilliseconds,
        );
      }
    });

    // await _playWithStarting();

    await _completer.future;

    playerStateSubscription.cancel();
  }

  @override
  void onStop() {
    _audioPlayer.stop();
    _setState(state: BasicPlaybackState.stopped);
    _completer.complete();
  }

  @override
  void onPlay() {
    _playing = true;
    _audioPlayer.resume();
  }

  @override
  void onPause() {
    _playing = false;
    _audioPlayer.pause();
  }

  @override
  void onClick(MediaButton button) {
    if (_playing) {
      onPause();
    } else {
      onPlay();
    }
  }

  BasicPlaybackState _stateToBasicState(AudioPlayerState state) {
    switch (state) {
      case AudioPlayerState.STOPPED:
        return BasicPlaybackState.stopped;
      case AudioPlayerState.PAUSED:
        return BasicPlaybackState.paused;
      case AudioPlayerState.PLAYING:
        return BasicPlaybackState.playing;
      case AudioPlayerState.COMPLETED:
        return BasicPlaybackState.stopped;
      default:
        throw Exception("Illegal state");
    }
  }

  Future<void> _setState(
      {@required BasicPlaybackState state, int position}) async {
    if (position == null) {
      try {
        position = await _audioPlayer.getCurrentPosition();
      } on Exception catch (e) {
        print(e);
        position = 0;
      }
    }
    AudioServiceBackground.setState(
      controls: getControls(state),
      systemActions: [MediaAction.seekTo],
      basicState: state,
      position: position,
    );
  }

  List<MediaControl> getControls(BasicPlaybackState state) {
    if (_playing) {
      return [
        pauseControl,
        stopControl,
      ];
    } else {
      return [
        playControl,
        stopControl,
      ];
    }
  }

  void onCustomAction(String name, dynamic arguments) async {
    print(name);
    print(arguments);
    if (name == "playChannel") {
      var mediaItem = MediaItem(
          title: arguments["title"],
          id: arguments["url"],
          album: arguments["album"],
          artist: "Science Friday and WNYC Studios",
          duration: 5739820,
          artUri:
              "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg");

      await AudioServiceBackground.setMediaItem(mediaItem);
      await _audioPlayer.stop();
      await _audioPlayer.play(mediaItem.id);
      onPlay();
    }
  }

  Future<void> _playWithStarting() async {
    final _queue = <MediaItem>[
      MediaItem(
          id:
              'https://radio-hichannel.cdn.hinet.net/live/pool/hich-ra000001/ra-hls/index.m3u8?token1=toCGFiD4TksJklIdxfNSfw&token2=mU7O_Y5Rr3kOvmQvBcAu5g&expire1=1585636377389&expire2=1585636406189',
          album: "Science Friday",
          title: "A Salute To Head-Scratching Science",
          artist: "Science Friday and WNYC Studios",
          duration: 5739820,
          artUri:
              "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
    ];

    AudioServiceBackground.setQueue(_queue);

    var mediaItem = _queue[0];

    AudioServiceBackground.setMediaItem(mediaItem);

    await _audioPlayer.stop();
    // await _audioPlayer.setUrl(mediaItem.id);
    await _audioPlayer.play(mediaItem.id);
    onPlay();
  }
}

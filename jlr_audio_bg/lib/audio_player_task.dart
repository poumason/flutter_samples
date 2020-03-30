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
    final _queue = <MediaItem>[
      MediaItem(
        //id: "https://radio-hichannel.cdn.hinet.net/live/pool/hich-ra000002/ra-hls/index.m3u8?token1=sRaiVoSov64EOkU2lBpfhw&token2=8-pC413TdMkPImaOLFhTEw&expire1=1585542655515&expire2=1585542684315",
        id: " https://radio-hichannel.cdn.hinet.net/live/pool/hich-ra000040/ra-hls/index.m3u8?token1=fVHDrArUhsmCJNEvl-8BAQ&token2=nbX8j4JFYdoVG5HM_gZD1A&expire1=1585554251140&expire2=1585554279940",
        album: "Science Friday",
        title: "A Salute To Head-Scratching Science",
        artist: "Science Friday and WNYC Studios",
        duration: 5739820,
        artUri:
            "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg",
      ),
    ];

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

    AudioServiceBackground.setQueue(_queue);

    var mediaItem = _queue[0];

    AudioServiceBackground.setMediaItem(mediaItem);

    await _audioPlayer.stop();
    // await _audioPlayer.setUrl(mediaItem.id);
    await _audioPlayer.play(mediaItem.id);
    onPlay();

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
}

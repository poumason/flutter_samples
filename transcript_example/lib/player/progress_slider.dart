import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'player_bloc.dart';
import '../extension_methods/duration_extensions.dart';

class ProgressSlider extends StatefulWidget {
  final PlayerBloc playerBloc;
  final bool enableDrag;
  final bool showText;

  ProgressSlider(this.playerBloc,
      {Key key, this.enableDrag = true, this.showText = false})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => ProgressSliderState();
}

class ProgressSliderState extends State<ProgressSlider> {
  Timer timer;
  bool isSeeking = false;
  double seekValue = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(milliseconds: 100), (t) {
      if (isSeeking) {
        return;
      }
      setState(() {});
    });
  }

  void stopTimer() {
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    var position = widget.playerBloc.position;
    var duration = widget.playerBloc.duration;

    return BlocListener(
        bloc: widget.playerBloc,
        listener: (context, state) {
          if (state is PlayerBlocPlayingState) {
            startTimer();
          } else {
            stopTimer();
          }
        },
        child: Offstage(
          offstage: duration <= Duration.zero && position < duration,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              widget.showText
                  ? Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2),
                      child: Text(position.getFormattedMinuteSecondPosition()),
                    )
                  : Container(),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: widget.enableDrag
                      ? _buildDragProgressBar(
                          position.inMilliseconds.toDouble(),
                          duration.inMilliseconds.toDouble())
                      : _buildNotDragProgressBar(
                          position.inMilliseconds.toDouble(),
                          duration.inMilliseconds.toDouble()),
                ),
              ),
              widget.showText
                  ? Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2),
                      child: Text(duration.getFormattedMinuteSecondPosition()),
                    )
                  : Container(),
            ],
          ),
        ));
  }

  Widget _buildDragProgressBar(double position, double duration) {
    return SliderTheme(
      data: SliderThemeData(
        trackShape: CustomTrackShape(),
      ),
      child: Slider(
        value: isSeeking ? seekValue : position,
        min: 0,
        max: duration,
        onChanged: (value) {
          seekValue = value;
          setState(() {});
        },
        onChangeStart: (value) {
          isSeeking = true;
        },
        onChangeEnd: (value) {
          isSeeking = false;
          widget.playerBloc
              .add(PlayerBlocSeekEvent(Duration(milliseconds: value.floor())));
        },
        activeColor: Theme.of(context).accentColor,
        inactiveColor: Theme.of(context).disabledColor,
      ),
    );
  }

  Widget _buildNotDragProgressBar(double position, double duration) {
    if (position == 0 && duration == 0) {
      return Container();
    }
    return LinearProgressIndicator(
      value: position / duration,
      valueColor: AlwaysStoppedAnimation(Theme.of(context).accentColor),
      backgroundColor: Theme.of(context).disabledColor,
    );
  }
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    @required RenderBox parentBox,
    Offset offset = Offset.zero,
    @required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    var trackHeight = sliderTheme.trackHeight;
    var trackLeft = offset.dx;
    var trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    var trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

import 'audio_player_task.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    connect();
  }

  @override
  void dispose() {
    disconnect();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        connect();
        break;
      case AppLifecycleState.paused:
        disconnect();
        break;
      default:
        break;
    }
  }

  void connect() async {
    await AudioService.connect();
  }

  void disconnect() {
    AudioService.disconnect();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
            StreamBuilder(
              stream: AudioService.playbackStateStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container();
                }

                var state = snapshot.data as PlaybackState;

                return IconButton(
                  icon: Icon(state.basicState == BasicPlaybackState.playing
                      ? Icons.pause
                      : Icons.play_arrow),
                  iconSize: 20,
                  onPressed: state.basicState == BasicPlaybackState.playing
                      ? AudioService.pause
                      : AudioService.play,
                );
              },
            ),
            RaisedButton(
              child: Text("AudioPlayer"),
              onPressed: () async {
                await AudioService.start(
                  backgroundTaskEntrypoint: _audioPlayerTaskEntrypoint,
                  androidNotificationChannelName: 'Audio Service Demo',
                  notificationColor: 0xFF2196f3,
                  androidNotificationIcon: 'mipmap/ic_launcher',
                  //enableQueue: true,
                );

                await AudioService.customAction("playChannel", {
                  "title": "Ancient Capital 古都電台",
                  "url":
                      "https://radio-hichannel.cdn.hinet.net/live/pool/hich-ra000001/ra-hls/index.m3u8?token1=toCGFiD4TksJklIdxfNSfw&token2=mU7O_Y5Rr3kOvmQvBcAu5g&expire1=1585636377389&expire2=1585636406189",
                  "album": "精品音樂"
                });
              },
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}

void _audioPlayerTaskEntrypoint() async {
  AudioServiceBackground.run(
      () => AudioPlayerTask(playControl, pauseControl, stopControl));
}

MediaControl playControl = MediaControl(
  androidIcon: 'drawable/ic_action_play_arrow',
  label: 'Play',
  action: MediaAction.play,
);
MediaControl pauseControl = MediaControl(
  androidIcon: 'drawable/ic_action_pause',
  label: 'Pause',
  action: MediaAction.pause,
);
MediaControl skipToNextControl = MediaControl(
  androidIcon: 'drawable/ic_action_skip_next',
  label: 'Next',
  action: MediaAction.skipToNext,
);
MediaControl skipToPreviousControl = MediaControl(
  androidIcon: 'drawable/ic_action_skip_previous',
  label: 'Previous',
  action: MediaAction.skipToPrevious,
);
MediaControl stopControl = MediaControl(
  androidIcon: 'drawable/ic_action_stop',
  label: 'Stop',
  action: MediaAction.stop,
);

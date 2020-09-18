import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import './display_content_bloc.dart';
import './ui/transcript_container.dart';

import 'model/stt.dart';
import 'player/player_bloc.dart';
import 'player/progress_slider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Transcript Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Transcript Demo Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;
  final PlayerBloc playerBloc = PlayerBloc();

  MyHomePage({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Column(
          children: [
            Expanded(
                child: FutureBuilder(
              future: _loadFromAsset(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container();
                } else {
                  return BlocProvider<DisplayContentBloc>(
                    create: (BuildContext context) => DisplayContentBloc(),
                    child: TranscriptContainer(playerBloc, snapshot.data),
                  );
                }
              },
            )),
            _buildPlayerBar()
          ],
        ));
  }

  Future<STT> _loadFromAsset() async {
    var raw = await rootBundle.loadString("assets/transcript.json");
    var json = jsonDecode(raw);
    var sttObject = STT.fromJson(json);
    return sttObject;
  }

  Widget _buildPlayerBar() {
    return Container(
        margin: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 10),
        child: Column(
          children: [
            ProgressSlider(
              playerBloc,
              showText: true,
              enableDrag: true,
            ),
            BlocBuilder(
              cubit: playerBloc,
              builder: (context, state) {
                var isPlaying = playerBloc.state is PlayerBlocPlayingState;
                return IconButton(
                    icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                    onPressed: () {
                      if (isPlaying) {
                        playerBloc.add(PlayerBlocPauseEvent());
                      } else {
                        playerBloc.add(PlayerBlocResumeEvent());
                      }
                    });
              },
            ),
          ],
        ));
  }
}

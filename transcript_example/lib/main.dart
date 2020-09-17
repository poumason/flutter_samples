import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transcript_example/player/player_bloc.dart';
import 'package:transcript_example/player/progress_slider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Transcript Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
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

class _MyHomePageState extends State<MyHomePage> {
  PlayerBloc playerBloc;

  @override
  void initState() {
    super.initState();
    playerBloc = PlayerBloc();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Column(
          children: [
            Expanded(
              child: Container(),
            ),
            _buildPlayerBar()
          ],
        ));
  }

  Widget _buildPlayerBar() {
    return Container(
        margin: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 10),
        child: Column(
          children: [
            ProgressSlider(playerBloc, showText: true, enableDrag: true,),
            BlocBuilder(
              cubit: playerBloc,
              builder: (context, state) {
                print(playerBloc.state);
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

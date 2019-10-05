import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter PageView Sample'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  PageController _controller;
  var pageOffset = 0.0;
  var screenWidth = 0.0;

  var images = [
    'http://0rz.tw/y2yyL',
    'http://0rz.tw/RTyOI',
    'http://0rz.tw/GZfs8',
    'http://0rz.tw/myTYd',
    'http://0rz.tw/HuKP2'
  ];

  void _offsetChanged() {
    // 每次的移動都重新計算對應的偏移值與特效
    setState(() {
      pageOffset = _controller.offset / screenWidth;
    });

    print(
        "offset: from ${_controller.initialScrollOffset}, to ${_controller.offset}");
  }

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: 0);
	  // 監聽 PageController 的 Scroller 變化
    _controller.addListener(_offsetChanged);
  }

  @override
  Widget build(BuildContext context) {
    // 預設使用螢幕的寬度
    print("page width: ${MediaQuery.of(context).size.width}");
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: PageView.builder(
          controller: _controller,
          itemCount: images.length,
          itemBuilder: (context, index) {
            // 計算每次異動時左邊的 Page 是哪個 index
            var currentLeftPageIndex = pageOffset.floor();
            // 計算現在畫面 Offset 佔的比例
            var currentPageOffsetPercent = pageOffset - currentLeftPageIndex;
            // 加入移動的特效
            return Transform.translate(
              // 因爲是水平滑動，所以設定 offset 的 X 值，因爲 Page 固定不動，所以要先用 pageOffset 減去 index 得到 負數
			        // 如果是垂直滑動，請設定 offset 的 Y 值
              offset: Offset((pageOffset - index) * screenWidth, 0),
              child: Opacity(
                // 如果現在左邊的 index 等於正要建立的 index，則讓它透明度變淡，因爲它要退出畫面了
				        // 相反地是要顯示，則使用原本的 currentPageOffsetPercent
                opacity: currentLeftPageIndex == index
                    ? 1 - currentPageOffsetPercent
                    : currentPageOffsetPercent,
                child: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(images[index]),
                            fit: BoxFit.cover))),
              ),
            );
            //return Image.network(images[index]);
          },
        ));
  }
}

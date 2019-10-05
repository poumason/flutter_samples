import 'package:flutter/material.dart';
import 'package:pageviewer_sample/indicator.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter PageView Sample'),
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
  final PageController _controller = PageController();
  final ScrollController _scrollController = ScrollController();
  var pageOffset = 0.0;
  var screenWidth = 0.0;

  var images = [
    'http://0rz.tw/y2yyL',
    'http://0rz.tw/RTyOI',
    'http://0rz.tw/GZfs8',
    'http://0rz.tw/myTYd',
    'http://0rz.tw/HuKP2'
  ];

  var texts = ['GOW 1', 'GOW 2', 'GOW 3', 'GEARS OF WAR JUDGMENT', 'GEARS OF WAR:ULTIMATE EDITION'];

  void _offsetChanged() {
    // 每次的移動都重新計算對應的偏移值與特效
    setState(() {
      pageOffset = _controller.offset / screenWidth;
      // 利用 PageController.offset 來移動
      _scrollController.jumpTo(_controller.offset);
    });

    print(
        "offset: from ${_controller.initialScrollOffset}, to ${_controller.offset}");
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // 監聽 PageController 的 Scroller 變化
    _controller.addListener(_offsetChanged);
    super.initState();
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
        body: Stack(
          alignment: AlignmentDirectional.bottomStart,
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: images.length,
              itemBuilder: (context, index) {
                // 計算每次異動時左邊的 Page 是哪個 index
                var currentLeftPageIndex = pageOffset.floor();
                // 計算現在畫面 Offset 佔的比例
                var currentPageOffsetPercent =
                    pageOffset - currentLeftPageIndex;
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
              },
            ),
            Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: DotsIndicator(
                  color: Colors.white,
                  itemCount: images.length,
                  controller: _controller,
                )),
            // 利用 IgnorePointer 忽略 ListView 的滑動
            IgnorePointer(
                child: ListView.builder(
              // 改利用 ScrollController 來操作 ListView
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: texts.length,
              itemBuilder: (context, index) {
                return Container(
                    alignment: Alignment.bottomLeft,
                    // 設定 width 與 Page 一致
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.only(left: 10, bottom: 50),
                    child: Text(
                      texts[index],
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ));
              },
            ))
          ],
        ));
  }
}

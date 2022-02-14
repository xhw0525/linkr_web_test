import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  WebViewController? _controller;
  File? htmlfile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: WebView(
          initialUrl: 'about:blank',
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            _controller = webViewController;
            _loadHtmlFromAssets();
          },
          javascriptChannels: <JavascriptChannel>{
            JavascriptChannel(
              name: 'show_flutter_toast',
              onMessageReceived: (JavascriptMessage message) {
                try {
                  debugPrint(
                      "${message.toString()},  ${message.hashCode}, message: ${message.message}");
                } catch (e) {
                  debugPrint('error>>>>${e.toString()}');
                }
              },
            )
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          copyDemoToSandBox();
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  // 拷贝demo到沙盒
  Future<void> copyDemoToSandBox() async {
    // 获取cache目录，
    Directory documents = await getApplicationDocumentsDirectory();
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    /// 这里自己过滤需要复制的文件夹
    manifestMap.keys
        .where((key) =>
            key.endsWith(".js") ||
            key.endsWith(".html") ||
            key.endsWith(".css"))
        .forEach((element) async {
      // 读取数据
      ByteData data = await rootBundle.load("assets/${element}");
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      String dataPath = "${documents.path}/${element}";
      File file = File(dataPath);
      await file.create(recursive: true);
      await File(dataPath).writeAsBytes(bytes);
      print("复制成功");
    });
  }

  Future<String> get _localPath async {
    // final _path = await getTemporaryDirectory();
    final _path = await getApplicationDocumentsDirectory();
    return _path.path;
  }

  Future<File> get _htmlFile async {
    final path = await _localPath;
    return File('$path/index.html');
  }

  Future<File> get _cssFile async {
    final path = await _localPath;
    return File('$path/mystyle.css');
  }

  Future<File> get _jsFile async {
    final path = await _localPath;
    return File('$path/index1.js');
  }

  void _loadHtmlFromAssets() async {
    File file = await _htmlFile;

    // _controller?.loadUrl(Uri.file(file.path).toString());
    _controller?.loadFile(file.path);
  }
}

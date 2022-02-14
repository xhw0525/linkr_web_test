import 'dart:io';

import 'package:flutter/material.dart';
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
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    _htmlFile.then((value) {
      value.writeAsString("""<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>菜鸟教程(runoob.com)</title>
    <link rel="stylesheet" type="text/css" href="mystyle.css">
    <script type="text/javascript" src="index1.js"></script>

</head>

<body>
<h1>这是一个标题</h1>
<p id="p1">这是一个段落。111</p>
<h1 id="id01">旧标题</h1>
<button onclick = "hello()">点击我弹出hello</button>
</body>

</html>""");
    });
    _cssFile.then((value) {
      value.writeAsString("""h1 {color:red;}
p {color:blue;}""");
    });
    _jsFile.then((value) {
      value.writeAsString("""function hello(){
    var element = document.getElementById("id01");
    element.innerHTML = "新标题";

    show_flutter_toast.postMessage("message from JS...");
}""");
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

    _controller?.loadUrl(Uri.file(file.path).toString());
    // _controller?.loadFile(file.path);
  }
}

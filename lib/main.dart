import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:jaguar/jaguar.dart';

import 'myroute.dart';

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

  @override
  void initState() {
    super.initState();
    _initaa();
  }

  _initaa() async {
    print("aaaaa");

    // await _serverBind();
    final server = Jaguar(address: "127.0.0.1", port: 8000);
    server.addRoute(serveFlutterAssets1());
    await server.serve(logRequests: true);
  }

  // Future<void> _serverBind() async {
  //   HttpServer.bind(InternetAddress.anyIPv4, 8000).then((server) {
  //     print("00000");
  //     server.listen((HttpRequest httpRequest) async {
  //       // print("11111111");
  //       // request.response.write('Hello, world! 23456');
  //       // request.response.close();
  //     });
  //   });
  // }

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
          // copyDemoToSandBox();
          _controller?.loadUrl("http://127.0.0.1:8000/index.html");
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  // ??????demo?????????
  Future<void> copyDemoToSandBox() async {
    // ??????cache?????????
    Directory documents = await getApplicationDocumentsDirectory();
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    /// ??????????????????????????????????????????
    manifestMap.keys
        .where((key) =>
            key.endsWith(".js") ||
            key.endsWith(".html") ||
            key.endsWith(".css"))
        .forEach((element) async {
      // ????????????
      ByteData data = await rootBundle.load("assets/$element");
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      String dataPath = "${documents.path}/$element";
      File file = File(dataPath);
      await file.create(recursive: true);
      await File(dataPath).writeAsBytes(bytes);
      debugPrint("????????????");
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

  void _loadHtmlFromAssets() async {
    File file = await _htmlFile;

    // _controller?.loadUrl(Uri.file(file.path).toString());
    // _controller?.loadFile(file.path);
  }
}

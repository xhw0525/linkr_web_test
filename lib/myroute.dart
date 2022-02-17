import 'dart:io';

import 'package:jaguar/jaguar.dart';
import 'package:path_provider/path_provider.dart';

/// Serves static files from Flutter assets.
///
/// Example:
///
///       final server = Jaguar();
///       server.addRoute(serveFlutterAssets());
///       await server.serve();
Route serveFlutterAssets1(
    {String path: '*',
      bool stripPrefix: true,
      String prefix: '',
      Map<String, String>? pathRegEx,
      ResponseProcessor? responseProcessor}) {
  Route route;
  int skipCount = -1;
  route = Route.get(path, (ctx) async {
    Iterable<String> segs = ctx.pathSegments;
    if (skipCount > 0) segs = segs.skip(skipCount);

    String lookupPath =
        segs.join('/') + (ctx.path.endsWith('/') ? 'index.html' : '');
    final localPath = await _localPath;
    File file = File('$localPath/$prefix$lookupPath');

    final body = await file.readAsBytes();

    String? mimeType;
    if (!ctx.path.endsWith('/')) {
      if (ctx.pathSegments.isNotEmpty) {
        final String last = ctx.pathSegments.last;
        if (last.contains('.')) {
          mimeType = MimeTypes.fromFileExtension[last.split('.').last];
        }
      }
    } else {
      mimeType = 'text/html';
    }

    ctx.response = ByteResponse(body: body, mimeType: mimeType);
  }, pathRegEx: pathRegEx, responseProcessor: responseProcessor);

  if (stripPrefix) skipCount = route.pathSegments.length - 1;

  return route;
}
Future<String> get _localPath async {
  // final _path = await getTemporaryDirectory();
  final _path = await getApplicationDocumentsDirectory();
  return _path.path;
}

import 'package:unittest/unittest.dart';
import 'package:roundtrip/roundtrip.dart';
import 'dart:io';

class FakeHeaders implements HttpHeaders {

}

class FakeHttpRequest implements HttpRequest {
  int contentLength = 1;
  bool persistentConnection = true;
  String method = 'GET';
  Map<String, String> queryParameters = <String>{};
  String queryString = '';
  String uri = 'http://google.com/';
  String path = '/';
  String protocolVersion = '1,1';
  HttpHeaders headers = null;
  HttpConnectionInfo connectionInfo = null;
  List<Cookie> cookies = <Cookie>[];
  InputStream inputStream = null;
  HttpSession session([init(HttpSession session)]) => null;
}

main() {
  group('Request.', () {
    test('Exists', () {
      var req = new FakeHttpRequest();
      var r = new RoundTrip(req, null);
      expect(r.request.contentLength, equals(1));
    });
  });
}


import 'dart:io';
import 'package:unittest/unittest.dart';
import 'package:httpstub/httpstub.dart';
import 'package:roundtrip/roundtrip.dart';
import 'package:logging/logging.dart';


initLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.on.record.add((rec) => print('${rec.time}:${rec.message}'));
}


main() {
  initLogging();
  group('Roundtrip.', () {

    HttpRequest req;
    HttpResponse res;
    RoundTrip r;

    setUp(() {
      req = new FakeHttpRequest();
      res = new FakeHttpResponse();
      r = new RoundTrip(req, res);
    });

    test('Exists', () {
      expect(r.request.contentLength, equals(0));
    });

    test('Request args', () {
      req.queryParameters['a'] = 'b';
      expect(r.args['a'], equals('b'));
    });

    test('Response status', () {
      r.statusCode = 404;
      expect(r.statusCode, equals(404));
      expect(r.response.statusCode, equals(404));
    });

    test('Response phrase', () {
      r.reasonPhrase = 'Not Found';
      expect(r.reasonPhrase, equals('Not Found'));
      expect(r.response.reasonPhrase, equals('Not Found'));
    });

    test('Respond empty body', () {
      r.respond();
      ListOutputStream s = res.outputStream;
      expect(s.read(), equals(null));
    });

    test('Response body', () {
      r.respond(body: 'I am a banana');
      ListOutputStream s = res.outputStream;
      expect(s.read(), equals('I am a banana'.charCodes));
    });

    test('Respond status', () {
      r.respond(status: 403);
      expect(r.statusCode, equals(403));
    });

    test('Respond no status', () {
      r.respond();
      expect(r.statusCode, equals(200));
    });

  });
}


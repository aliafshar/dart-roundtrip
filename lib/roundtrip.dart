library roundtrip;

import 'dart:io';
import 'dart:json' as json;
import 'package:logging/logging.dart';
import 'package:principal/principal.dart';

logRoundtrip(RoundTrip r) {
  Logger.root.fine('${r.request.path} ${r.response.statusCode}');
}


/*
 * The HTTP context of the request and response.
 *
 * These objects contain the complete context of an HTTP round trip, including
 * the request, the respone, and the routing match with arguments. There are
 * helpers to facilitate the common funcitonality that a view performs.
 *
 * Additional funcitonality can be performed by accessing the underlying
 * components.
 */
abstract class RoundTrip {

  // The HTTP request.
  final HttpRequest request;

  final Map<String, String> args;

  // The HTTP response.
  final HttpResponse response;

  // The response body.
  String body;

  // The response status code.
  int statusCode;

  // The response status message.
  String reasonPhrase;

  // Additional arguments to this roundtrip.
  Map matchArgs;

  // Identity of the request. Must be set manually.
  Identity identity;

  respond({String body, int status : HttpStatus.OK, InputStream stream});

  /**
   * Reads the request body as a string, with optional encoding.
   */
  String read([Encoding encoding]);

  dynamic readJson();

  /**
   * Writes a string, with optional encoding, to the response.
   */
  String write(String body, [Encoding encoding]);

  /**
   * Completes the response by closing the output stream.
   */
  finish();

  /**
   * Responds with an HTTP error.
   *
   * When the reason is not provided, the default for the status code is used.
   */
  respondError(int statusCode, [String reasonPhrase]);

  /**
   * Responds with a 404, Not Found HTTP error.
   */
  respond404();

  /**
   * Creates an instance of the default implementation of [RoundTrip].
   */
  factory RoundTrip(HttpRequest rq, HttpResponse rs) {
    return new _RoundTripImpl(rq, rs);
  }
}

class _RoundTripImpl implements RoundTrip {

  final HttpRequest request;
  final HttpResponse response;

  final Map matchArgs = new Map();

  Identity identity;

  Map get args => request.queryParameters;

  String _body;
  dynamic _jsonBody;

  _RoundTripImpl(this.request, this.response);

  String get body {
    if (_body == null) {
      _body = read();
    }
    return _body;
  }

  dynamic get json {
    if (_jsonBody == null) {
      _jsonBody = json.parse(body);
    }
    return _jsonBody;
  }

  int get statusCode => response.statusCode;
      set statusCode(int value) => response.statusCode = value;

  String get reasonPhrase => response.reasonPhrase;
         set reasonPhrase(String value) => response.reasonPhrase = value;

  String read([Encoding encoding]) {
    var stream = new StringInputStream(request.inputStream, encoding);
    return stream.read();
  }

  dynamic readJson() {
    return json.parse(read());
  }

  write(String body, [Encoding encoding = Encoding.UTF_8]) {
    response.outputStream.writeString(body, encoding);
  }

  respond({String body : '', int status : HttpStatus.OK, InputStream stream}) {
    statusCode = status;
    write(body);
    finish();
  }

  finish() {
    logRoundtrip(this);
    response.outputStream.close();
  }

  respondError(int statusCode, [String reasonPhrase]) {
    response.statusCode = statusCode;
    if (?reasonPhrase) {
      response.reasonPhrase = reasonPhrase;
    }
    write(response.reasonPhrase);
    finish();
  }

  respond404() {
    respondError(404);
  }

}

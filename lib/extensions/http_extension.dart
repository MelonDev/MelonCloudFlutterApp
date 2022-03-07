import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

Map<String, String> _header() {
  return {'Content-Type': 'application/json;charset=UTF-8', 'Charset': 'utf-8'};
}

class HttpResponse {
  int statusCode;
  dynamic data;

  HttpResponse(this.statusCode, this.data);
}

Future<HttpResponse> http_get(Uri uri, {Map<String, String>? headers}) async {
  var responses = await http.get(uri, headers: headers ?? _header());
  dynamic data;
  if (responses.statusCode != 200) {
    data = utf8.decode(responses.bodyBytes);
  } else {
    dynamic raw = utf8.decode(responses.bodyBytes);
    data = json.decode(raw);
  }
  return HttpResponse(responses.statusCode, data);
}

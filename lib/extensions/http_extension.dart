import 'dart:convert';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../environment/app_environment.dart';

Map<String, String> _header() {
  return {'Content-Type': 'application/json;charset=UTF-8', 'Charset': 'utf-8'};
}

Map<String, String> _postHeader() {
  return {
    'Content-Type': 'application/json;charset=UTF-8',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Access-Control-Allow-Origin, Accept',
    'Charset': 'utf-8'
  };
}

Map<String, String> _formHeader() {
  return {
    'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
    'Charset': 'utf-8'
  };
}

class HttpResponse {
  int statusCode;
  dynamic data;

  HttpResponse(this.statusCode, this.data);
}

class MelonCloudAuthorization {
  String password;
  Uri uri;
  Map<String, String>? body;
  String secureKey;

  MelonCloudAuthorization(
      {required this.uri,
      required this.password,
      required this.secureKey,
      this.body});
}

Future<HttpResponse> http_get(Uri uri,
    {Map<String, String>? headers,
    MelonCloudAuthorization? authorization}) async {
  var responses = await http.get(uri, headers: headers ?? _header());
  dynamic data;
  if (responses.statusCode == 401) {
    /*
    if (authorization != null) {
      String? access_token = await http_authorization(authorization);
      if(access_token != null) {
        Map<String, String> header = _header();
        header['cookie'] = 'access_token_cookie=$access_token';
        print(header);
        responses = await http.get(uri, headers: header);
        print(responses.statusCode);
        if (responses.statusCode != 200) {
          data = utf8.decode(responses.bodyBytes);
        } else {
          dynamic raw = utf8.decode(responses.bodyBytes);
          data = json.decode(raw);
        }
        return HttpResponse(responses.statusCode, data);
      }

    }
    
     */
  } else if (responses.statusCode != 200) {
    data = utf8.decode(responses.bodyBytes);
  } else {
    dynamic raw = utf8.decode(responses.bodyBytes);
    data = json.decode(raw);
  }
  return HttpResponse(responses.statusCode, data);
}

Future<HttpResponse> http_post(Uri uri,
    {Map<String, String>? headers,
    Map<String, String>? body,
    MelonCloudAuthorization? authorization}) async {
  print("POST");
  print(uri);
  var responses = await http.post(
    uri,
    headers: _postHeader(),
    encoding: Encoding.getByName('utf-8'),
    body: jsonEncode(body ?? {}),
  );
  print("POSTED");

  print(responses.statusCode);
  dynamic data;
  if (responses.statusCode != 200) {
    data = utf8.decode(responses.bodyBytes);
  } else if (responses.statusCode == 401) {
    if (authorization != null) {
      await http_authorization(authorization);
    }
  } else {
    dynamic raw = utf8.decode(responses.bodyBytes);
    data = json.decode(raw);
  }
  return HttpResponse(responses.statusCode, data);
}

Future<String?> http_authorization(
    MelonCloudAuthorization authorization) async {
  final login_response = await http.post(
    authorization.uri,
    headers: _formHeader(),
    encoding: Encoding.getByName('utf-8'),
    body: authorization.body ?? {"password": authorization.password},
  );
  dynamic data;
  if (login_response.statusCode == 200) {
    dynamic raw = utf8.decode(login_response.bodyBytes);
    data = json.decode(raw);
    String access_token = data['data']['access_token'];
    FlutterSecureStorage storage = const FlutterSecureStorage();
    //await storage.write(key: authorization.secureKey, value: access_token);
    return access_token;
  } else {
    return null;
  }
}

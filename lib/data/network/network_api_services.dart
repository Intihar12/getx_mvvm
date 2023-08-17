import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:getx_mvvm/data/network/base_api_services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../app_exceptions.dart';

class NetworkApiServices extends BaseApiServices {
  @override
  Future<dynamic> getApi(String url) async {
    if (kDebugMode) {
      print(url);
    }

    dynamic responseJson;
    try {
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      responseJson = returnResponse(response);
    } on SocketException {
      throw InternetException('');
    } on RequestTimeOut {
      throw RequestTimeOut('');
    }
    print(responseJson);
    return responseJson;
  }

  @override
  Future<dynamic> postApi(
    var data,
    String url, {
    String? contentType,
  }) async {
    if (kDebugMode) {
      print(url);
      print(data);
    }

    dynamic responseJson;
    var headers = await _getHeaders(contentType: contentType);
    try {
      final response =
          await http.post(Uri.parse(url), body: data, headers: headers).timeout(const Duration(seconds: 10));
      responseJson = returnResponse(response);
    } on SocketException {
      throw InternetException('');
    } on RequestTimeOut {
      throw RequestTimeOut('');
    }
    if (kDebugMode) {
      print(responseJson);
    }
    return responseJson;
  }

  dynamic returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        dynamic responseJson = jsonDecode(response.body);
        return responseJson;
      case 400:
        dynamic responseJson = jsonDecode(response.body);
        return responseJson;

      default:
        throw FetchDataException('Error accoured while communicating with server ' + response.statusCode.toString());
    }
  }

  final _apiKey = "8610ed17b516d04629f55a715dca9c64104d00d8";
  Future<Map<String, String>> _getHeaders({String? contentType}) async {
    var accessToken = await getToken();

    Map<String, String> headers = {
      'x-api-key': _apiKey,
      'Content-Type': contentType ?? 'text/plain',
    };
    if (accessToken != null) {
      headers.addAll({HttpHeaders.authorizationHeader: "Bearer $accessToken"});
    }
    return headers;
  }

  String? accessToken;
  Future<String?> getToken() async {
    //getIpInfo();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var accessToken = prefs.getString('accessToken');
    debugPrint("AccessTokenFromGet: $accessToken");
    this.accessToken = accessToken;
    //notifyListeners();
    return accessToken;
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:getx_mvvm/data/network/base_api_services.dart';
import 'package:getx_mvvm/res/app_url/app_url.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../view_models/controller/user_preference/user_prefrence_view_model.dart';
import '../app_exceptions.dart';

class NetworkApiServices extends BaseApiServices {
  UserPreference userPreference = UserPreference();
  @override
  Future<dynamic> getApi(String url,{String? contentType}) async {
    if (kDebugMode) {
      print(url);
    }

    dynamic responseJson;
    var headers = await _getHeaders(contentType: contentType);
    try {
      final response = await http.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 10));
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


  Future<Map<String, String>> _getHeaders({String? contentType}) async {
    var accessToken = await userPreference.getUserToken();

    Map<String, String> headers = {
      'x-api-key': AppUrl.apiKey,
      'Content-Type': contentType ?? 'text/plain',
    };
    if (accessToken != null) {
      headers.addAll({HttpHeaders.authorizationHeader: "Bearer $accessToken"});
    }
    return headers;
  }

}

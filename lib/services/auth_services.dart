import 'dart:convert';
import 'dart:io';

import 'package:flutter_webapi_first_course/services/webcliente.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthServices {

  String url = WebClient.url;
  http.Client client = WebClient().client;

  Future<bool> login({required String email, required String password}) async {
    http.Response response = await client.post(
      Uri.parse('${url}login'),
      body: {'email': email, 'password': password},
    );

    if (response.statusCode != 200) {
      String content = json.decode(response.body).toString();
      switch (content) {
        case "Cannot find user":
          throw UserNotFoundException();
      }

      throw HttpException(response.body);
    }

    saveUserInfos(response.body);
    return true;
  }

  Future<bool> register(
      {required String email, required String password}) async {
    http.Response response = await client.post(
      Uri.parse('${url}register'),
      body: {'email': email, 'password': password},
    );

    if (response.statusCode != 201) {
      throw HttpException(response.body.toString());
    }

    saveUserInfos(response.body);
    return true;
  }

  saveUserInfos(String body) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    Map<String, dynamic> map = json.decode(body);

    sharedPreferences.setString("accessToken", map["accessToken"]);
    sharedPreferences.setString("id", map["user"]["id"].toString());
    sharedPreferences.setString("email", map["user"]["email"]);

    return map["accessToken"];
  }
}

class UserNotFoundException implements Exception {}

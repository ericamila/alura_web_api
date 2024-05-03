import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_webapi_first_course/services/http_interceptors.dart';
import 'package:http/http.dart' as http;
import 'package:http_interceptor/http/http.dart';
import 'package:http_interceptor/http_interceptor.dart';
import '../models/journal.dart';

class JournalService {
  static const String url = "http://192.168.150.131:3000/";
  static const String resource = "journals/";

  http.Client client = InterceptedClient.build(
    interceptors: [LoggingInterceptor()],
  );

  String getURL() {
    return "$url$resource";
  }

  //TODO: Substituir getURL por getURI
  Future<bool> register(Journal journal) async {
    String journalJSON = json.encode(journal.toMap());

    http.Response response = await client.post(
      Uri.parse(getURL()),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: journalJSON,
    );

    if (response.statusCode == 201) {
      return true;
    }

    return false;
  }

  Future<bool> edit(String id, Journal journal) async {
    String journalJSON = json.encode(journal.toMap());

    http.Response response = await client.put(
      Uri.parse("${Uri.parse(getURL())}$id"),
      headers: {'Content-type': 'application/json'},
      body: journalJSON,
    );

    if (response.statusCode == 200) {
      return true;
    }

    return false;
  }

  Future<List<Journal>> getAll() async {
    http.Response response = await client.get(Uri.parse(getURL()),
        headers: {'Content-Type': 'application/json; charset=UTF-8'});

    if (response.statusCode != 200) {
      //TODO: Criar uma exceção personalizada
      throw Exception();
    }

    List<Journal> result = [];

    List<dynamic> jsonList = json.decode(response.body);
    for (var jsonMap in jsonList) {
      result.add(Journal.fromMap(jsonMap));
    }

    return result;
  }

  Future<bool> delete(String id) async {
    http.Response response = await http.delete(Uri.parse("${getURL()}$id"));

    if (response.statusCode == 200) {
      return true;
    }

    return false;
  }
}

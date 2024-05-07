import 'dart:convert';
import 'dart:io';
import 'package:flutter_webapi_first_course/services/webcliente.dart';
import 'package:http/http.dart' as http;
import '../models/journal.dart';

class JournalService {
  http.Client client = WebClient().client;
  static const String resource = "journals/";

  String getURL() {
    return "${WebClient.url}$resource";
  }

  Uri getUri() {
    return Uri.parse(getURL());
  }

  Future<bool> register(Journal journal, String token) async {
    String journalJSON = json.encode(journal.toMap());

    http.Response response = await client.post(
      getUri(),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: journalJSON,
    );

    if (response.statusCode != 201) {
      if (json.decode(response.body) == 'jwt expired') {
        throw TokenNotValidException();
      }
      throw HttpException(response.body);
    }

    return true;
  }

  Future<bool> edit(String id, Journal journal, String token) async {
    journal.updatedAt = DateTime.now();
    String journalJSON = json.encode(journal.toMap());

    http.Response response = await client.put(
      Uri.parse("${getURL()}$id"),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: journalJSON,
    );

    if (response.statusCode != 200) {
      if (json.decode(response.body) == 'jwt expired') {
        throw TokenNotValidException();
      }
      throw HttpException(response.body);
    }
    return true;
  }

  Future<List<Journal>> getAll(
      {required String id, required String token}) async {
    http.Response response = await client.get(
      Uri.parse("${WebClient.url}users/$id/$resource"),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
    );

    List<Journal> result = [];

    if (response.statusCode != 200) {
      if (json.decode(response.body) == 'jwt expired') {
        throw TokenNotValidException();
      }
      throw HttpException(response.body);
    }

    List<dynamic> jsonList = json.decode(response.body);
    for (var jsonMap in jsonList) {
      result.add(Journal.fromMap(jsonMap));
    }

    return result;
  }

  Future<bool> delete(String id, String token) async {
    http.Response response = await http.delete(Uri.parse("${getURL()}$id"),
        headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode != 200) {
      if (json.decode(response.body) == 'jwt expired') {
        throw TokenNotValidException();
      }
      throw HttpException(response.body);
    }

    return true;
  }
}

class TokenNotValidException implements Exception {}

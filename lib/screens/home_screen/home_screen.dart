import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_webapi_first_course/screens/commom/exception_dialog.dart';
import 'package:flutter_webapi_first_course/screens/home_screen/widgets/home_screen_list.dart';
import 'package:flutter_webapi_first_course/services/journal_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/logout.dart';
import '../../models/journal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // O último dia apresentado na lista
  DateTime currentDay = DateTime.now();

  // Tamanho da lista
  int windowPage = 10;

  // A base de dados mostrada na lista
  Map<String, Journal> database = {};

  final ScrollController _listScrollController = ScrollController();

  JournalService service = JournalService();

  String? userId;
  String? token;

  @override
  void initState() {
    refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // Título basado no dia atual
          title: Text(
            "${currentDay.day}  |  ${currentDay.month}  |  ${currentDay.year}",
          ),
          actions: [
            IconButton(
                onPressed: () {
                  refresh();
                },
                icon: const Icon(Icons.refresh))
          ],
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              ListTile(
                onTap: () => logout(context),
                title: const Text("Sair"),
                leading: const Icon(Icons.login_outlined),
              )
            ],
          ),
        ),
        body: (userId != null && token != null)
            ? ListView(
                controller: _listScrollController,
                children: generateListJournalCards(
                  windowPage: windowPage,
                  currentDay: currentDay,
                  database: database,
                  refreshFunction: refresh,
                  userId: userId!,
                  token: token!,
                ),
              )
            : const Center(
                child: CircularProgressIndicator(),
              ));
  }

  void refresh() async {
    SharedPreferences.getInstance().then(
      (preferences) {
        String? token = preferences.getString("accessToken");
        String? email = preferences.getString("email");
        String? id = preferences.getString("id");

        if (token != null && email != null && id != null) {
          setState(() {
            userId = id;
            this.token = token;
          });
          service
              .getAll(id: id.toString(), token: token)
              .then((List<Journal> listJournal) {
            setState(() {
              database = {};
              for (Journal journal in listJournal) {
                database[journal.id] = journal;
              }
            });
          });
        } else {
          Navigator.pushReplacementNamed(context, "login");
        }
      },
    ).catchError(
      (error) {
        logout(context);
      },
      test: (error) => error is TokenNotValidException,
    ).catchError(
      (error) {
        var innerError = error as HttpException;
        showExceptionDialog(context, content: innerError.message);
      },
      test: (error) => error is HttpException,
    );
  }
}

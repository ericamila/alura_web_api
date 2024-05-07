import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_webapi_first_course/helpers/weekday.dart';
import 'package:flutter_webapi_first_course/models/journal.dart';
import 'package:flutter_webapi_first_course/services/journal_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/logout.dart';
import '../commom/exception_dialog.dart';

class AddJournalScreen extends StatefulWidget {
  final Journal journal;
  final bool isEditing;

  const AddJournalScreen(
      {super.key, required this.journal, required this.isEditing});

  @override
  State<AddJournalScreen> createState() => _AddJournalScreenState();
}

class _AddJournalScreenState extends State<AddJournalScreen> {
  final TextEditingController _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _contentController.text = widget.journal.content;
    return Scaffold(
      appBar: AppBar(
        title: Text(WeekDay(widget.journal.createdAt).toString()),
        actions: [
          IconButton(
            onPressed: () {
              registerJournal(context);
            },
            icon: const Icon(Icons.check),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: TextField(
          controller: _contentController,
          keyboardType: TextInputType.multiline,
          style: const TextStyle(fontSize: 24),
          expands: true,
          maxLines: null,
          minLines: null,
        ),
      ),
    );
  }

  registerJournal(BuildContext context) async {
    SharedPreferences.getInstance().then((preferences) {
      String? token = preferences.getString("accessToken");
      if (token != null) {
        JournalService journalService = JournalService();
        widget.journal.content = _contentController.text;

        if (widget.isEditing) {
          journalService.register(widget.journal, token).then((value) {
            Navigator.pop(
                context, (value) ? DisposeStatus.success : DisposeStatus.error);
          }).catchError(
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
        } else {
          journalService
              .edit(widget.journal.id, widget.journal, token)
              .then((value) {
            Navigator.pop(
                context, (value) ? DisposeStatus.success : DisposeStatus.error);
          }).catchError(
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
    });
  }
}

enum DisposeStatus { exit, error, success }

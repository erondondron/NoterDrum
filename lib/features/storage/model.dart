import 'package:drums/features/sheet_music/model.dart';
import 'package:drums/features/storage/explorer/model.dart';
import 'package:flutter/material.dart';

class Storage extends ChangeNotifier {
  Storage() {
    explorer.addListener(notifyListeners);
  }

  StorageExplorer explorer = StorageExplorer();
  SheetMusic selectedGroove = SheetMusic.generate();

  String? newFolder;

  @override
  void dispose() {
    explorer.removeListener(notifyListeners);
    super.dispose();
  }

  bool get setupIsActive => newFolder != null;

  void createFolder() {
    closeSetup();
    newFolder = "NewFolder";
    notifyListeners();
  }

  void open() {
    explorer.openFolder();
  }

  void closeSetup() {
    newFolder = null;
    notifyListeners();
  }

  void close() {
    closeSetup();
    explorer.close();
  }
}

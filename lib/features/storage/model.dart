import 'package:drums/features/sheet_music/model.dart';
import 'package:drums/features/storage/explorer/model.dart';
import 'package:drums/features/storage/setup/models.dart';
import 'package:flutter/material.dart';

class Storage extends ChangeNotifier {
  Storage() {
    explorer.addListener(notifyListeners);
  }

  StorageExplorer explorer = StorageExplorer();
  SheetMusic selectedGroove = SheetMusic.generate();

  StorageSetupEntity? setupEntity;

  @override
  void dispose() {
    explorer.removeListener(notifyListeners);
    super.dispose();
  }

  bool get setupIsActive => setupEntity != null;

  void createFolder() {
    closeSetup();
    setupEntity = StorageNewFolder();
    notifyListeners();
  }

  void open() {
    explorer.openFolder();
  }

  void closeSetup() {
    setupEntity = null;
    notifyListeners();
  }

  void close() {
    closeSetup();
    explorer.close();
  }
}

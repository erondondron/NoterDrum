import 'package:drums/features/sheet_music/model.dart';
import 'package:flutter/material.dart';

class StorageFolder {
  String? currentPath;

  List<String> folders = [];
  List<String> grooves = [];
}

class Storage extends ChangeNotifier {
  bool saveMode = false;
  bool viewMode = false;

  SheetMusic selectedGroove = SheetMusic.generate();
  String? selectedGroovePath;

  StorageFolder? selectedFolder;

  bool get disabled => !saveMode && !viewMode;
}

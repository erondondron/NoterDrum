import 'dart:io';

import 'package:drums/features/sheet_music/model.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class StorageFolder {
  StorageFolder({
    required this.rootPath,
    required this.relativePath,
    required this.folders,
    required this.grooves,
  });

  String rootPath;
  String relativePath;

  List<FileSystemEntity> folders;
  List<FileSystemEntity> grooves;
}

class Storage extends ChangeNotifier {
  bool newGrooveMode = false;
  bool newFolderMode = false;

  SheetMusic selectedGroove = SheetMusic.generate();
  String? selectedGroovePath;

  StorageFolder? selectedFolder;

  bool get viewMode => selectedFolder != null;

  void toggleNewFolderMode() {
    newFolderMode = !newFolderMode;
    notifyListeners();
  }

  void openFolder({String folderPath = "NoterDrum"}) async {
    var root = await getApplicationDocumentsDirectory();
    var folder = Directory(path.join(root.path, folderPath));
    if (!folder.existsSync()) folder.createSync();
    var content = folder.listSync();
    selectedFolder = StorageFolder(
      rootPath: root.path,
      relativePath: folderPath,
      folders: content.whereType<Directory>().toList(),
      grooves: content.whereType<File>().toList(),
    );
    notifyListeners();
  }

  void close() {
    selectedFolder = null;
    newFolderMode = false;
    newGrooveMode = false;
    notifyListeners();
  }
}

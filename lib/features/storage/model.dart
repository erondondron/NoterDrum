import 'dart:io';

import 'package:drums/features/sheet_music/model.dart';
import 'package:drums/features/storage/setup/models.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class Storage extends ChangeNotifier {
  static const String baseFolder = "NoterDrum";

  String relativePath = "";

  List<String> folders = [];
  List<String> grooves = [];

  SheetMusic selectedGroove = SheetMusic.generate();
  StorageSetupEntity? setupEntity;

  bool get isActive => relativePath.isNotEmpty;

  bool get setupIsActive => setupEntity != null;

  String get displayedPath {
    var result = path.basename(relativePath);
    if (result == relativePath) return result;

    var parent = path.basename(path.dirname(relativePath));
    result = path.join(parent, result);
    if (result != relativePath) result = "... $result";

    return result.replaceAll("/", " / ");
  }

  Future<void> sync() async {
    var root = await getApplicationDocumentsDirectory();
    var folder = Directory(path.join(root.path, relativePath));
    if (!folder.existsSync()) folder.createSync();
    var content = folder.listSync();
    folders = content
        .whereType<Directory>()
        .map((entity) => path.basename(entity.path))
        .toList();
    grooves = content
        .whereType<File>()
        .map((entity) => path.basename(entity.path))
        .toList();
    notifyListeners();
  }

  Future<void> openFolder({String? name}) async {
    relativePath = path.join(relativePath, name ?? baseFolder);
    return sync();
  }

  Future<void> returnBack() async {
    if (path.basename(relativePath) == relativePath) return close();
    relativePath = path.dirname(relativePath);
    return sync();
  }

  Future<void> createFolder({required String name}) async {
    var root = await getApplicationDocumentsDirectory();
    var folder = Directory(path.join(root.path, relativePath, name));
    if (!folder.existsSync()) {
      folder.createSync();
      return sync();
    }
  }

  Future<void> removeFolder({required String name}) async {
    var root = await getApplicationDocumentsDirectory();
    var folder = Directory(path.join(root.path, relativePath, name));
    if (folder.existsSync()) {
      folder.deleteSync(recursive: true);
      return sync();
    }
  }

  void close() {
    relativePath = "";
    folders = [];
    grooves = [];
    closeSetup();
  }

  void setup({required StorageSetupEntity entity}) {
    setupEntity = entity;
    notifyListeners();
  }

  void closeSetup() {
    setupEntity = null;
    notifyListeners();
  }
}

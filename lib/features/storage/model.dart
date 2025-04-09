import 'dart:io';
import 'dart:math';

import 'package:drums/features/sheet_music/model.dart';
import 'package:drums/features/storage/setup/models.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class StorageEntityAlreadyExistsError implements Exception {
  const StorageEntityAlreadyExistsError(this.entityPath);

  final String entityPath;

  @override
  String toString() => 'File system entity $entityPath already exists';
}

class Storage extends ChangeNotifier {
  static const String baseFolder = "NoterDrum";

  String relativePath = "";

  List<String> folders = [];
  List<String> grooves = [];

  SheetMusic selectedGroove = SheetMusic.generate();
  StorageNewGroove? newGroove;
  StorageSetupEntity? setupEntity;

  bool get isActive => relativePath.isNotEmpty;

  String get displayedTitle {
    var title = isActive
        ? relativePath
        : selectedGroove.relativePath;
    if (path.extension(title) == ".pbnd"){
      title = title.substring(0, title.length - ".pbnd".length);
    }
    return title.replaceAll("/", " / ");
  }

  FileSystemEntity _getFileSystemEntity(String entityPath) {
    return path.extension(entityPath) == ".pbnd"
        ? File(entityPath)
        : Directory(entityPath);
  }

  Future<void> _sync() async {
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

  Future<void> removeFileSystemEntity({required String name}) async {
    var root = await getApplicationDocumentsDirectory();
    var entityPath = path.join(root.path, relativePath, name);
    var entity = _getFileSystemEntity(entityPath);
    if (entity.existsSync()) {
      entity.deleteSync(recursive: true);
      return _sync();
    }
  }

  Future<void> openFolder({String? name}) async {
    relativePath = path.join(relativePath, name ?? baseFolder);
    return _sync();
  }

  Future<void> returnBack() async {
    if (path.basename(relativePath) == relativePath) return close();
    relativePath = path.dirname(relativePath);
    return _sync();
  }

  void setup({required StorageSetupEntity entity}) {
    entity is StorageNewGroove ? newGroove = entity : setupEntity = entity;
    notifyListeners();
  }

  Future<void> createFolder({required String name}) async {
    var root = await getApplicationDocumentsDirectory();
    var folder = Directory(path.join(root.path, relativePath, name));
    if (!folder.existsSync()) {
      folder.createSync();
      return _sync();
    }
  }

  Future<void> openGroove({required String name}) async {
    var groovePath = path.join(relativePath, name);
    var groove = await SheetMusic.parseFile(groovePath);
    if (groove == null) return;
    selectedGroove = groove;
    return close();
  }

  Future<void> setupNewGroove() async {
    await openFolder(name: path.dirname(selectedGroove.relativePath));
    newGroove = StorageNewGroove(name: getNewGrooveName());
    notifyListeners();
  }

  String getNewGrooveName() {
    var grooveNumber = 0;
    var groovePattern = RegExp(r"^Groove (\d+).pbnd$");
    for (var groove in grooves) {
      var match = groovePattern.firstMatch(groove);
      if (match == null) continue;
      var existingGrooveNumber = int.parse(match.group(1)!);
      grooveNumber = max(grooveNumber, existingGrooveNumber);
    }
    return 'Groove ${grooveNumber + 1}';
  }

  Future<void> saveNewGroove({bool force = false}) async {
    if (newGroove == null) return;
    var root = await getApplicationDocumentsDirectory();
    var name = "${newGroove!.name}.pbnd";
    var groovePath = path.join(relativePath, name);
    var file = File(path.join(root.path, groovePath));
    if (file.existsSync() && !force) {
      throw StorageEntityAlreadyExistsError(groovePath);
    }
    await selectedGroove.dumpFile(groovePath);
    return close();
  }

  void closeSetup() {
    setupEntity = null;
    notifyListeners();
  }

  void close() {
    newGroove = null;
    relativePath = "";
    folders = [];
    grooves = [];
    closeSetup();
  }
}

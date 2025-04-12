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
    var entityPath = isActive ? relativePath : selectedGroove.relativePath;
    var entityName = path.basenameWithoutExtension(entityPath);
    var parentPath = path.dirname(entityPath);
    if (parentPath == ".") return entityName;

    var parentName = path.basename(parentPath);
    var result = path.join(parentName, entityName);
    if (isActive && parentName != parentPath) result = "... $result";
    return result.replaceAll("/", " / ");
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

  void setupNewFolder() {
    setupEntity = StorageNewFolder(name: getNewFolderName());
    notifyListeners();
  }

  String getNewFolderName() {
    var folderNumber = 0;
    var folderPattern = RegExp(r"^Folder (\d+)$");
    for (var folder in folders) {
      var match = folderPattern.firstMatch(folder);
      if (match == null) continue;
      var existingFolderNumber = int.parse(match.group(1)!);
      folderNumber = max(folderNumber, existingFolderNumber);
    }
    return 'Folder ${folderNumber + 1}';
  }

  Future<void> saveNewFolder() async {
    if (setupEntity is! StorageNewFolder) return;
    var newFolder = setupEntity as StorageNewFolder;
    var root = await getApplicationDocumentsDirectory();
    var folderPath = path.join(relativePath, newFolder.name);
    var folder = Directory(path.join(root.path, folderPath));
    if (!folder.existsSync()) {
      folder.createSync();
      await _sync();
    }
    return closeSetup();
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

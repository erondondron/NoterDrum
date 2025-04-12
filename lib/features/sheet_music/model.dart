import 'dart:convert';
import 'dart:io';

import 'package:drums/features/sheet_music/drum_set/model.dart';
import 'package:drums/features/sheet_music/measure/model.dart';
import 'package:drums/features/sheet_music/time_signature/model.dart';
import 'package:drums/features/storage/model.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class SheetMusic extends ChangeNotifier {
  static const int version = 1;

  SheetMusic({
    required this.relativePath,
    required this.drumSet,
    required this.measures,
  }) {
    drumSet.addListener(_updateMeasureDrumLines);
  }

  factory SheetMusic.generate({String name = "NewGroove"}) {
    var relativePath = path.join(
      Storage.baseFolder,
      name + Storage.grooveExtension,
    );
    var drumSet = DrumSet();
    var measure = SheetMusicMeasure.generate(
      timeSignature: sixteenSixteenths,
      drums: drumSet.selected,
    );
    return SheetMusic(
      relativePath: relativePath,
      drumSet: drumSet,
      measures: [measure],
    );
  }

  @override
  void dispose() {
    drumSet.removeListener(_updateMeasureDrumLines);
    super.dispose();
  }

  String relativePath;

  final DrumSet drumSet;
  final List<SheetMusicMeasure> measures;

  void addNewMeasure() {
    measures.add(
      SheetMusicMeasure.generate(
        timeSignature: measures.last.timeSignature,
        drums: drumSet.selected,
      ),
    );
    notifyListeners();
  }

  void removeMeasure(SheetMusicMeasure measure) {
    if (measures.length == 1) {
      final newMeasure = SheetMusicMeasure.generate(
        timeSignature: measures.last.timeSignature,
        drums: drumSet.selected,
      );
      measures.insert(0, newMeasure);
    }
    measures.remove(measure);
    notifyListeners();
  }

  void _updateMeasureDrumLines() {
    for (SheetMusicMeasure measure in measures) {
      measure.updateDrumLines(drumSet.selected);
    }
  }

  static Future<SheetMusic?> parseFile(String relativePath) async {
    var root = await getApplicationDocumentsDirectory();
    var file = File(path.join(root.path, relativePath));
    if (!file.existsSync()) return null;
    var jsonString = await file.readAsString();
    var content = jsonDecode(jsonString) as Map<String, dynamic>;
    return SheetMusic(
      relativePath: relativePath,
      drumSet: DrumSet.fromJson(
        content["drum_set"] as Map<String, dynamic>,
      ),
      measures: (content["measures"] as List<dynamic>)
          .map((measure) => SheetMusicMeasure.fromJson(
                measure as Map<String, dynamic>,
              ))
          .toList(),
    );
  }

  Future<void> dumpFile(String relativePath) async {
    var content = {
      "drum_set": drumSet.toJson(),
      "measures": measures.map((measure) => measure.toJson()).toList(),
    };
    var jsonString = json.encode(content);
    var root = await getApplicationDocumentsDirectory();
    var file = File(path.join(root.path, relativePath));
    await file.writeAsString(jsonString);
  }
}

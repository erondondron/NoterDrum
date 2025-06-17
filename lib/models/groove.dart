import 'dart:convert';
import 'dart:io';

import 'package:drums/models/drum_set.dart';
import 'package:drums/models/measure.dart';
import 'package:drums/models/time_signature.dart';
import 'package:drums/storage/model.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class Groove extends ChangeNotifier {
  static const int version = 1;

  final DrumSet drumSet;
  final List<GrooveMeasure> measures;

  String relativePath;
  bool saved;

  Groove({
    required this.relativePath,
    required this.drumSet,
    required this.measures,
    required this.saved,
  }) {
    drumSet.newDrumCallback = addNewMeasuresLine;
    drumSet.removedDrumCallback = removeMeasuresLine;
  }

  factory Groove.generate({String name = "NewGroove"}) {
    var relativePath = path.join(
      Storage.baseFolder,
      name + Storage.grooveExtension,
    );
    var drumSet = DrumSet();
    var measure = GrooveMeasure.generate(
      timeSignature: sixteenSixteenths,
      drumSet: drumSet,
    );
    return Groove(
      relativePath: relativePath,
      drumSet: drumSet,
      measures: [measure],
      saved: false,
    );
  }

  @override
  void dispose() {
    drumSet.newDrumCallback = null;
    drumSet.removedDrumCallback = null;
    super.dispose();
  }

  void addNewMeasure() {
    measures.add(
      GrooveMeasure.generate(
        timeSignature: measures.last.timeSignature,
        drumSet: drumSet,
      ),
    );
    notifyListeners();
  }

  void removeMeasure(GrooveMeasure measure) {
    if (measures.length == 1) {
      final newMeasure = GrooveMeasure.generate(
        timeSignature: measures.last.timeSignature,
        drumSet: drumSet,
      );
      measures.insert(0, newMeasure);
    }
    measures.remove(measure);
    notifyListeners();
  }

  void addNewMeasuresLine(int idx) {
    for (var measure in measures) {
      measure.addNewBeatsLine(idx);
    }
  }

  void removeMeasuresLine(int idx) {
    for (var measure in measures) {
      measure.removeBeatsLine(idx);
    }
  }

  static Future<Groove?> parseFile(String relativePath) async {
    var root = await getApplicationDocumentsDirectory();
    var file = File(path.join(root.path, relativePath));
    if (!file.existsSync()) return null;
    var jsonString = await file.readAsString();
    var content = jsonDecode(jsonString) as Map<String, dynamic>;
    var drumSet = DrumSet.fromJson(
      content["drum_set"] as Map<String, dynamic>,
    );
    return Groove(
      relativePath: relativePath,
      drumSet: drumSet,
      measures: (content["measures"] as List<dynamic>)
          .map((measure) => GrooveMeasure.fromJson(
                drumSet,
                measure as Map<String, dynamic>,
              ))
          .toList(),
      saved: true,
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

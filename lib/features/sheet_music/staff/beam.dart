import 'package:drums/features/sheet_music/beat/models.dart';
import 'package:drums/features/sheet_music/note/models.dart';
import 'package:drums/features/sheet_music/staff/lines.dart';
import 'package:drums/features/sheet_music/staff/note.dart';
import 'package:flutter/material.dart';

class NotesBeamPainter {
  static const double linesWidth = StaffPainter.lineWidth * 3;
  static const double linesGap = StaffPainter.linesGap;

  static const double stemOffset = NotePainter.stemOffset;
  static const double singleBeamLength = linesGap;
  static const double beamWidth = 0.4 * linesGap;
  static const double beamIncline = 0.176;

  final Color color;
  final Canvas canvas;

  const NotesBeamPainter({
    required this.canvas,
    required this.color,
  });

  Paint get paint => Paint()
    ..color = color
    ..strokeWidth = linesWidth
    ..style = PaintingStyle.fill;

  List<List<BeatDivision>> getBeamGroups(
    Iterable<BeatDivision> divisions,
    NoteValue noteValue,
  ) {
    var rawBeamGroups = <List<BeatDivision>>[];
    var beamGroup = <BeatDivision>[];
    for (var division in divisions) {
      if (division.noteValue.part >= noteValue.part) {
        beamGroup.add(division);
        continue;
      }
      if (beamGroup.isEmpty) continue;
      rawBeamGroups.add(beamGroup);
      beamGroup = [];
    }
    if (beamGroup.isNotEmpty) {
      rawBeamGroups.add(beamGroup);
    }

    var beamGroups = <List<BeatDivision>>[];
    for (var rawGroup in rawBeamGroups) {
      int startIdx = rawGroup.indexWhere((div) => div.notes.isNotEmpty);
      if (startIdx == -1) continue;

      int endIdx = rawGroup.lastIndexWhere((div) => div.notes.isNotEmpty);
      var group = rawGroup.sublist(startIdx, endIdx + 1);
      beamGroups.add(group);
    }
    return beamGroups;
  }

  void drawBeamGroup(List<BeatDivision> beamGroup, NoteValue noteValue) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = beamWidth
      ..style = PaintingStyle.fill;

    var startX = beamGroup.first.position + stemOffset;
    var endX = beamGroup.last.position + stemOffset;
    var width = endX - startX;

    if (noteValue == NoteValue.eighth) {
      // Рисуем stems
    }

    var relative = noteValue.part.bitLength - NoteValue.eighth.part.bitLength;
    var position = relative * linesGap;
    var startOffset = stemOffset - linesWidth / 2;
    var endOffset = stemOffset + linesWidth / 2;
    var beamStart = Offset(beamGroup.first.position + startOffset, position);
    var beamEnd = Offset(beamGroup.last.position + endOffset, position);
    // canvas.drawLine(beamStart, beamEnd, paint);
    // FIXME

    if (noteValue == NoteValue.values.last) return;
    drawNextValueBeamGroups(beamGroup, noteValue);
  }

  void drawNextValueBeamGroups(
    List<BeatDivision> beamGroup,
    NoteValue noteValue,
  ) {
    var nextValue = NoteValue.values.firstWhere(
      (note) => note.part == noteValue.part * 2,
    );
    var nextGroups = <BeatDivision, List<BeatDivision>>{
      for (var group in getBeamGroups(beamGroup, nextValue)) group.first: group
    };
    var forwardDir = true;
    var divIdx = 0;
    while (divIdx < beamGroup.length) {
      var division = beamGroup[divIdx++];
      var group = nextGroups[division];
      if (group == null) {
        if (division.noteValue == nextValue) {
          forwardDir = !forwardDir;
        }
        continue;
      }
      if (group.length > 1) {
        drawBeamGroup(group, nextValue);
        divIdx += group.length - 1;
        continue;
      }
      if (divIdx == beamGroup.length) {
        forwardDir = false;
      }
      // drawSingleNoteBeam(division.position, nextValue, forwardDir);
      // FIXME
    }
  }

  void drawSingleNoteBeam(
    double position,
    NoteValue noteValue,
    bool forwardDirection,
  ) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = beamWidth
      ..style = PaintingStyle.fill;

    var yRelative = noteValue.part.bitLength - NoteValue.eighth.part.bitLength;
    var yAbsolute = yRelative * linesGap;
    var xDirection = forwardDirection ? 1 : -1;
    var xStart = position + stemOffset - linesWidth / 2;
    var xEnd = xStart + singleBeamLength * xDirection;
    var beamStart = Offset(xStart, yAbsolute);
    var beamEnd = Offset(xEnd, yAbsolute);
    canvas.drawLine(beamStart, beamEnd, paint);
  }
}

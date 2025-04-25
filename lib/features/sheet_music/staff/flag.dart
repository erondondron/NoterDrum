import 'package:drums/features/sheet_music/beat/models.dart';
import 'package:drums/features/sheet_music/note/models.dart';
import 'package:drums/features/sheet_music/staff/lines.dart';
import 'package:drums/features/sheet_music/staff/note.dart';
import 'package:flutter/material.dart';

class NoteFlagPainter {
  static const double linesWidth = StaffPainter.lineWidth * 3;
  static const double stemOffset = NotePainter.headRadius - linesWidth / 2;
  static const double singleBeamLength = StaffPainter.linesGap;
  static const double flagWidth = StaffPainter.linesGap;
  static const double beamWidth = 4;

  final Color color;
  final Canvas canvas;

  const NoteFlagPainter(
    this.canvas,
    this.color,
  );

  Paint get paint => Paint()
    ..color = color
    ..strokeWidth = linesWidth
    ..style = PaintingStyle.fill;

  void drawNoteValues(Map<BeatDivision, Map<SingleNote, Offset>> divisions) {
    for (var entry in divisions.entries) {
      if (entry.value.isEmpty) continue;
      var stemX = entry.key.position + stemOffset;
      var lowerNote = entry.value.values.reduce((a, b) => a.dy > b.dy ? a : b);
      canvas.drawLine(Offset(stemX, 0), Offset(stemX, lowerNote.dy), paint);
    }

    for (var eighthGroup in getBeamGroups(divisions.keys, NoteValue.eighth)) {
      eighthGroup.length > 1
          ? drawBeamGroup(eighthGroup, NoteValue.eighth)
          : drawSingleNoteFlags(eighthGroup.first);
    }
  }

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

    var relative = noteValue.part.bitLength - NoteValue.eighth.part.bitLength;
    var position = relative * StaffPainter.linesGap;
    var startOffset = stemOffset - linesWidth / 2;
    var endOffset = stemOffset + linesWidth / 2;
    var beamStart = Offset(beamGroup.first.position + startOffset, position);
    var beamEnd = Offset(beamGroup.last.position + endOffset, position);
    canvas.drawLine(beamStart, beamEnd, paint);

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
      drawSingleNoteBeam(division.position, nextValue, forwardDir);
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
    var yAbsolute = yRelative * StaffPainter.linesGap;
    var xDirection = forwardDirection ? 1 : -1;
    var xStart = position + stemOffset - linesWidth / 2;
    var xEnd = xStart + singleBeamLength * xDirection;
    var beamStart = Offset(xStart, yAbsolute);
    var beamEnd = Offset(xEnd, yAbsolute);
    canvas.drawLine(beamStart, beamEnd, paint);
  }

  void drawSingleNoteFlags(BeatDivision division) {
    var flagsCount = 0;
    var flagValuePart = NoteValue.eighth.part;
    while (division.noteValue.part >= flagValuePart) {
      var position = Offset(
        division.position + stemOffset,
        flagWidth * flagsCount++,
      );
      drawSingleNoteFlag(stemTop: position);
      flagValuePart *= 2;
    }
  }

  void drawSingleNoteFlag({required Offset stemTop, double size = flagWidth}) {
    var path = Path()
      ..moveTo(stemTop.dx, stemTop.dy)
      ..cubicTo(
        stemTop.dx,
        stemTop.dy + size,
        stemTop.dx + size * 1.5,
        stemTop.dy + size * 1.25,
        stemTop.dx + size * 0.5,
        stemTop.dy + size * 2.6,
      )
      ..cubicTo(
        stemTop.dx + size,
        stemTop.dy + size * 1.5,
        stemTop.dx + size * 0.4,
        stemTop.dy + size,
        stemTop.dx,
        stemTop.dy + size,
      );
    canvas.drawPath(path, paint);
  }
}

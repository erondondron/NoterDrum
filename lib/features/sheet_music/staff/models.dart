import 'dart:math';

import 'package:drums/features/sheet_music/beat/models.dart';
import 'package:drums/features/sheet_music/drum_set/model.dart';
import 'package:drums/features/sheet_music/note/models.dart';
import 'package:drums/features/sheet_music/staff/configuration.dart';
import 'package:flutter/material.dart';

class StaffPoint {
  double x;
  double y;

  StaffPoint({
    this.x = 0,
    this.y = 0,
  });

  Offset toOffset() => Offset(x, y);
}

class StaffNote {
  final Drum drum;
  final StrokeType stroke;

  StaffPoint position;

  StaffNote({
    required this.drum,
    required this.stroke,
    StaffPoint? position,
  }) : position = position ?? StaffPoint();
}

class StaffDivision {
  List<StaffNote> notes;
  NoteValue noteValue;

  double position;
  StaffPoint? stemStart;
  StaffPoint? stemEnd;
  bool rightFlag = true;

  StaffDivision({
    required this.noteValue,
    List<StaffNote>? notes,
    this.position = 0,
    this.stemStart,
    this.stemEnd,
  }) : notes = notes ?? [];
}

class StaffBeat {
  List<StaffDivision> divisions;
  List<StaffDivision> singleNotes;
  List<StaffBeat> beamGroups;
  NoteValue noteValue;
  double beamInclineDx = NotesSettings.beamInclineDx;

  StaffBeat({
    required this.noteValue,
    List<StaffDivision>? divisions,
    List<StaffDivision>? singleNotes,
    List<StaffBeat>? beamGroups,
  })  : divisions = divisions ?? [],
        singleNotes = singleNotes ?? [],
        beamGroups = beamGroups ?? [];
}

class StaffConverter {
  static StaffBeat convert(Beat beat) {
    var staff = StaffBeat(noteValue: NoteValue.quarter);
    if (beat.notesGrid.isEmpty) return staff;

    var smallestNote = NoteValue.values.last.part;
    var beatDuration = smallestNote * beat.length ~/ beat.noteValue.part;
    var shortestNoteUnit = beat.notesGrid
        .expand((line) => line.notes)
        .reduce((a, b) => a.value.unit.part > b.value.unit.part ? a : b);
    var divValue = shortestNoteUnit.value.unit;
    var divCount = beatDuration * divValue.part ~/ smallestNote;
    var divWidth = beat.viewSize / divCount;

    staff.divisions = List.generate(
      divCount,
      (int idx) => StaffDivision(
        position: (idx + 1 / 2) * divWidth,
        noteValue: divValue,
      ),
    );

    _putNotesToDivisions(staff, beat, divValue);
    _setupNoteFlagsParameters(staff);
    return staff;
  }

  static _putNotesToDivisions(StaffBeat staff, Beat beat, NoteValue divValue) {
    for (var gridLine in beat.notesGrid) {
      var divIdx = 0;
      for (var note in gridLine.notes) {
        if (note is SingleNote && note.stroke != StrokeType.off) {
          var division = staff.divisions[divIdx];
          var staffNote = StaffNote(
            drum: gridLine.drum,
            stroke: note.stroke,
            position: _getNotePosition(
              division.position,
              gridLine.drum,
              note.stroke,
            ),
          );
          division.notes.add(staffNote);
        }
        divIdx += divValue.part ~/ note.value.unit.part;
      }
    }
    _optimizeDivisions(staff);
    _tuneNotePositions(staff);
  }

  static StaffPoint _getNotePosition(double x, Drum drum, StrokeType stroke) {
    var y = switch (drum) {
      Drum.kick => 1.5,
      Drum.snare => -0.5,
      Drum.hiHat => stroke == StrokeType.foot ? 2.5 : -2.5,
      Drum.crash => -3,
      Drum.ride => -2,
      Drum.tom1 => -1.5,
      Drum.tom2 => -1,
      Drum.tom3 => 0.5,
    };
    return StaffPoint(x: x, y: y * FiveLinesSettings.gap);
  }

  static void _optimizeDivisions(StaffBeat beat) {
    var idx = 1;
    while (idx != beat.divisions.length) {
      var division = beat.divisions[idx];
      var previous = beat.divisions[idx - 1];

      if (division.notes.isNotEmpty ||
          previous.noteValue != division.noteValue ||
          previous.noteValue == NoteValue.quarter) {
        idx++;
        continue;
      }

      beat.divisions.removeAt(idx);
      previous.noteValue = NoteValue.values.firstWhere(
        (note) => note.part == previous.noteValue.part ~/ 2,
      );
      idx = max(idx - 1, 1);
    }
  }

  static void _tuneNotePositions(StaffBeat beat) {
    for (var division in beat.divisions) {
      var offset = false;
      var previous = -double.infinity;
      division.notes.sort((a, b) => a.position.y.compareTo(b.position.y));
      for (var note in division.notes) {
        note.position.x -= note.position.y * NotesSettings.stemInclineDx;
        var isNear = note.position.y - previous <= FiveLinesSettings.gap + 1e-5;
        previous = note.position.y;
        offset = isNear ? !offset : false;
        if (offset) note.position.x += 2 * NotesSettings.stemOffset;
      }
    }
  }

  static void _setupNoteFlagsParameters(StaffBeat beat) {
    _divideIntoBeams(beat);
    _setupBeamStems(beat);
    _setupSingleNoteStems(beat);
    _setupSingleNoteFlagDirections(beat);
  }

  static void _divideIntoBeams(StaffBeat beat) {
    if (beat.noteValue == NoteValue.values.last) return;
    var nextValue = NoteValue.values.firstWhere(
      (note) => note.part == beat.noteValue.part * 2,
    );

    var nextValueGroups = <StaffBeat>[];
    var nextValueGroup = StaffBeat(noteValue: nextValue);
    for (var division in beat.divisions) {
      if (division.noteValue.part >= nextValue.part) {
        nextValueGroup.divisions.add(division);
        continue;
      }
      if (nextValueGroup.divisions.isEmpty) {
        if (beat.noteValue == NoteValue.quarter && division.notes.isNotEmpty) {
          beat.singleNotes.add(division);
        }
        continue;
      }
      nextValueGroups.add(nextValueGroup);
      nextValueGroup = StaffBeat(noteValue: nextValue);
    }
    if (nextValueGroup.divisions.isNotEmpty) {
      nextValueGroups.add(nextValueGroup);
    }

    for (var group in nextValueGroups) {
      int start = group.divisions.indexWhere((div) => div.notes.isNotEmpty);
      if (start == -1) continue;

      int end = group.divisions.lastIndexWhere((div) => div.notes.isNotEmpty);
      group.divisions = group.divisions.sublist(start, end + 1);
      if (group.divisions.length == 1) {
        beat.singleNotes.add(group.divisions.first);
        continue;
      }

      _divideIntoBeams(group);
      beat.beamGroups.add(group);
    }
  }

  static void _setupBeamStems(StaffBeat beat) {
    for (var group in beat.beamGroups) {
      var startDiv = group.divisions.first;
      var endY = startDiv.notes.first.position.y - NotesSettings.stemLength;

      var previousDivPosition = startDiv.position;
      for (var division in group.divisions) {
        if (division.notes.isEmpty) continue;
        var divY = division.notes.first.position.y - NotesSettings.stemLength;
        var dx = division.position - previousDivPosition;
        endY = min(endY - NotesSettings.beamInclineDx * dx, divY);
        previousDivPosition = division.position;
      }

      var endDiv = group.divisions.last;
      var length = endDiv.position - startDiv.position;
      var startY = endY + length * NotesSettings.beamInclineDx;
      if (endY < -FiveLinesSettings.center) {
        group.beamInclineDx = (FiveLinesSettings.center + startY) / length;
      }

      for (var division in group.divisions) {
        if (division.notes.isEmpty) continue;
        var lowerNote = division.notes.last;
        division.stemStart = StaffPoint(
          x: lowerNote.position.x + NotesSettings.stemOffset,
          y: lowerNote.position.y,
        );

        var divDx = division.position - startDiv.position;
        var stemEndY = startY - group.beamInclineDx * divDx;
        var stemLength = lowerNote.position.y - stemEndY;
        var stemIncline = NotesSettings.stemInclineDx * stemLength;
        var stemOffset = NotesSettings.stemOffset + stemIncline;
        var stemEndX = lowerNote.position.x + stemOffset;
        division.stemEnd = StaffPoint(x: stemEndX, y: stemEndY);
      }
    }
  }

  static void _setupSingleNoteStems(StaffBeat beat) {
    var stemEndOffset = NotesSettings.stemInclineDx * NotesSettings.stemLength;
    for (var division in beat.singleNotes) {
      var lowerNote = division.notes.last;
      division.stemStart = StaffPoint(
        x: lowerNote.position.x + NotesSettings.stemOffset,
        y: lowerNote.position.y,
      );

      var upperNote = division.notes.first;
      division.stemEnd = StaffPoint(
        x: upperNote.position.x + NotesSettings.stemOffset + stemEndOffset,
        y: upperNote.position.y - NotesSettings.stemLength,
      );
    }
  }

  static void _setupSingleNoteFlagDirections(StaffBeat beat) {
    if (beat.noteValue == NoteValue.values.last) return;
    var nextValue = NoteValue.values.firstWhere(
      (note) => note.part == beat.noteValue.part * 2,
    );
    var nextValueGroups = <StaffDivision, StaffBeat>{
      for (var group in beat.beamGroups) group.divisions.first: group
    };
    var rightFlag = true;
    var divIdx = 0;
    while (divIdx < beat.divisions.length) {
      var division = beat.divisions[divIdx++];
      var nextValueGroup = nextValueGroups[division];
      if (nextValueGroup != null) {
        _setupSingleNoteFlagDirections(nextValueGroup);
        divIdx += nextValueGroup.divisions.length - 1;
        continue;
      }

      if (division.notes.isEmpty) {
        if (division.noteValue == nextValue) {
          rightFlag = !rightFlag;
        }
        continue;
      }

      if (divIdx == beat.divisions.length) {
        rightFlag = false;
      }

      division.rightFlag = rightFlag;
    }
  }
}

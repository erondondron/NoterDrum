import 'dart:math';

import 'package:drums/features/edit_grid/configuration.dart';
import 'package:drums/features/models/beat.dart';
import 'package:drums/features/models/drum_set.dart';
import 'package:drums/features/models/note.dart';
import 'package:drums/features/models/note_value.dart';
import 'package:drums/features/staff/configuration.dart';
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

class StaffLine {
  Point start;
  Point end;

  StaffLine({
    required this.start,
    required this.end,
  });
}

class StaffNote {
  final NoteDuration start;
  final StrokeType stroke;
  final Drum drum;

  late StaffPoint position;

  StaffNote({
    required this.start,
    required this.stroke,
    required this.drum,
  });
}

class StaffTriplet {
  final NoteValue noteValue;
  final List<StaffNote> notes;

  StaffTriplet({
    required this.noteValue,
    required this.notes,
  });
}

class StaffNoteStack {
  NoteDuration start;
  NoteValue noteValue;
  List<StaffNote> notes = [];

  late double x;
  late double width;
  StaffPoint? stemStart;
  StaffPoint? stemEnd;

  bool rightFlag = true;

  NoteDuration get end => start + noteValue.duration;

  StaffNoteStack({
    required this.start,
    this.noteValue = NoteValue.thirtySecond,
  });
}

class StaffNoteGroup {
  List<StaffNoteStack> stacks;
  Map<NoteDuration, StaffNoteGroup> subgroups = {};
  List<StaffNoteStack> singleNotes = [];

  NoteValue noteValue = NoteValue.quarter;
  double beamInclineDx = NotesSettings.beamInclineDx;

  double get width => stacks.isNotEmpty ? stacks.last.x - stacks.first.x : 0;

  NoteDuration get duration =>
      stacks.isNotEmpty ? stacks.last.end - stacks.first.start : NoteDuration();

  StaffNoteGroup({
    this.noteValue = NoteValue.quarter,
    List<StaffNoteStack>? stacks,
  }) : stacks = stacks ?? [];
}

class StaffConverter {
  static StaffNoteGroup convert(Beat grooveBeat) {
    var beat = StaffNoteGroup();
    var beatDuration = _getBeatDuration(grooveBeat);

    var triplets = _convertTriplets(grooveBeat);
    beat.subgroups = _mergeTriplets(triplets);
    _fillRestStacks(beat, beatDuration);

    var notes = _convertNotes(grooveBeat);
    _fitNotesToBeat(beat, notes);
    _optimizeNoteValues(beat);

    _divideBeatIntoBeams(beat);
    _unpackSubgroups(beat);

    _calculateNotePositions(beat, grooveBeat.viewSize);
    _setupSingleNoteFlagDirections(beat);
    _setupSingleNoteStems(beat);
    _setupBeamStems(beat);
    return beat;
  }

  static NoteDuration _getBeatDuration(Beat grooveBeat) {
    return NoteDuration.fromNoteValue(
      noteValue: grooveBeat.noteValue,
      count: grooveBeat.length,
    );
  }

  static List<StaffTriplet> _convertTriplets(Beat grooveBeat) {
    var triplets = <StaffTriplet>[];
    for (var gridLine in grooveBeat.notesGrid) {
      var lineDuration = NoteDuration();
      for (var triplet in gridLine.notes) {
        var noteStart = lineDuration;
        lineDuration += triplet.value.unit.duration;

        if (triplet is! Triplet ||
            triplet.second.stroke == StrokeType.off &&
                triplet.third.stroke == StrokeType.off) {
          continue;
        }

        var staffNotes = <StaffNote>[];
        for (var (idx, tripletNote) in triplet.notes.indexed) {
          var staffNote = StaffNote(
            start: noteStart + triplet.value.duration * idx,
            drum: gridLine.drum,
            stroke: tripletNote.stroke,
          );
          staffNotes.add(staffNote);
        }

        var staffTriplet = StaffTriplet(
          noteValue: triplet.value,
          notes: staffNotes,
        );
        triplets.add(staffTriplet);
      }
    }
    return triplets;
  }

  static Map<NoteDuration, StaffNoteGroup> _mergeTriplets(
    List<StaffTriplet> triplets,
  ) {
    var groups = <NoteDuration, StaffNoteGroup>{};
    for (var noteValue in NoteValue.values.where((v) => v.length == 3)) {
      var groupsToMerge = <NoteDuration, StaffNoteGroup>{};

      for (var triplet in triplets.where((t) => t.noteValue == noteValue)) {
        var group = groupsToMerge[triplet.notes.first.start];
        group ??= StaffNoteGroup(
          noteValue: noteValue,
          stacks: triplet.notes
              .map((note) => StaffNoteStack(
                    start: note.start,
                    noteValue: noteValue,
                  ))
              .toList(),
        );
        for (var i = 0; i < noteValue.length; i++) {
          var note = triplet.notes[i];
          if (note.stroke == StrokeType.off) continue;
          group.stacks[i].notes.add(note);
        }
        groupsToMerge[triplet.notes.first.start] = group;
      }

      for (var triplet in groupsToMerge.entries) {
        var group = groups[triplet.key];
        if (group == null) {
          groups[triplet.key] = triplet.value;
          continue;
        }
        for (var stack in triplet.value.stacks) {
          _mergeTripletWithStack(group, stack);
        }
      }
    }
    return groups;
    // TODO добавить обработку случаев, когда триоли пересекаются не полностью
  }

  static bool _mergeTripletWithStack(
    StaffNoteGroup? triplet,
    StaffNoteStack stack,
  ) {
    if (triplet == null ||
        stack.notes.isEmpty ||
        stack.start < triplet.stacks.first.start ||
        stack.start >= triplet.stacks.last.end) {
      return false;
    }

    var tripletStacks = {for (var stack in triplet.stacks) stack.start: stack};
    var tripletStack = tripletStacks[stack.start];
    if (tripletStack != null) {
      tripletStack.notes.addAll(stack.notes);
      return true;
    }

    StaffNoteGroup? subTriplet;
    var tripletStart = triplet.stacks.first.start;
    var tripletDuration = triplet.noteValue.unit.duration;
    var tripletHalf = tripletStart + tripletDuration ~/ 2;

    var subTripletStart = tripletStart;
    if (stack.start < tripletHalf) subTripletStart = tripletHalf;
    subTriplet = triplet.subgroups[subTripletStart];
    subTriplet ??= _createSubTriplet(
      subTripletStart,
      triplet.noteValue,
      tripletStacks,
    );

    var success = _mergeTripletWithStack(subTriplet, stack);
    if (!success) return false;

    triplet.subgroups[subTripletStart] = subTriplet!;
    _collectStacksFromSubgroups(triplet);
    return true;
  }

  static StaffNoteGroup? _createSubTriplet(
    NoteDuration start,
    NoteValue noteValue,
    Map<NoteDuration, StaffNoteStack> stacks,
  ) {
    var newNoteValue = noteValue.smaller;
    if (newNoteValue == null) return null;
    var stackDuration = newNoteValue.duration;
    var tripletStacks = <StaffNoteStack>[];
    for (var i = 0; i < newNoteValue.length; i++) {
      var stackStart = start + stackDuration * i;
      var stack = stacks[stackStart] ??
          StaffNoteStack(
            start: stackStart,
            noteValue: newNoteValue,
          );
      stack.noteValue = newNoteValue;
      tripletStacks.add(stack);
    }
    return StaffNoteGroup(
      noteValue: newNoteValue,
      stacks: tripletStacks,
    );
  }

  static void _collectStacksFromSubgroups(
    StaffNoteGroup group,
  ) {
    if (group.subgroups.isEmpty) return;
    var stacks = group.stacks.toSet();
    for (var subgroup in group.subgroups.values) {
      _collectStacksFromSubgroups(subgroup);
      stacks.addAll(subgroup.stacks);
    }
    group.stacks = stacks.toList();
    group.stacks.sort((a, b) => a.start.value.compareTo(b.start.value));
  }

  static void _fillRestStacks(StaffNoteGroup beat, NoteDuration beatDuration) {
    var subgroups = beat.subgroups.entries.toList()
      ..sort((a, b) => a.key.value.compareTo(b.key.value))
      ..reversed;
    var step = NoteDuration();
    while (step < beatDuration) {
      var stepEnd = beatDuration;
      var nextStep = stepEnd;
      if (subgroups.isNotEmpty) {
        var subgroup = subgroups.removeLast();
        nextStep = subgroup.value.stacks.last.end;
        stepEnd = subgroup.key;
      }
      var restDuration = stepEnd - step;
      if (restDuration.value == 0) {
        step = nextStep;
        continue;
      }

      stackGenerator(int idx) {
        var offset = NoteDuration.fromNoteValue(
          noteValue: NoteValue.thirtySecond,
          count: idx,
        );
        return StaffNoteStack(start: step + offset);
      }

      var subgroup = StaffNoteGroup(
        stacks: List.generate(
          restDuration.value ~/ NoteValue.thirtySecond.duration.value,
          stackGenerator,
        ),
      );

      beat.subgroups[step] = subgroup;
      step = nextStep;
    }
  }

  static List<StaffNoteStack> _convertNotes(Beat grooveBeat) {
    var stacks = <NoteDuration, StaffNoteStack>{};
    for (var gridLine in grooveBeat.notesGrid) {
      var lineDuration = NoteDuration();
      for (var note in gridLine.notes) {
        var noteStart = lineDuration;
        lineDuration += note.value.unit.duration;

        SingleNote? singleNote;
        if (note is SingleNote) {
          if (note.stroke == StrokeType.off) continue;
          singleNote = note;
        } else if (note is Triplet) {
          if (note.first.stroke == StrokeType.off ||
              note.second.stroke != StrokeType.off ||
              note.third.stroke != StrokeType.off) {
            continue;
          }
          singleNote = note.first;
        }

        var staffNote = StaffNote(
          start: noteStart,
          drum: gridLine.drum,
          stroke: singleNote!.stroke,
        );
        var stack = stacks.putIfAbsent(
          noteStart,
          () => StaffNoteStack(start: noteStart),
        );
        stack.notes.add(staffNote);
      }
    }
    return stacks.values.toList();
  }

  static void _fitNotesToBeat(
    StaffNoteGroup beat,
    List<StaffNoteStack> stacks,
  ) {
    var stackDuration = NoteValue.thirtySecond.duration.value;
    for (var subgroup in beat.subgroups.values) {
      var start = subgroup.stacks.first.start;
      var end = subgroup.stacks.last.end;
      var groupStacks = stacks.where((s) => s.start >= start && s.start < end);

      if (subgroup.noteValue.length == 3) {
        for (var stack in groupStacks) {
          _mergeTripletWithStack(subgroup, stack);
        }
        continue;
      }

      for (var stack in groupStacks) {
        var idx = (stack.start - start) ~/ stackDuration;
        var groupStack = subgroup.stacks[idx.value];
        groupStack.notes.addAll(stack.notes);
      }
    }
  }

  static void _optimizeNoteValues(StaffNoteGroup beat) {
    for (var subgroup in beat.subgroups.values) {
      if (subgroup.noteValue.length == 3) continue;
      var idx = 1;
      while (idx != subgroup.stacks.length) {
        var stack = subgroup.stacks[idx];
        var previous = subgroup.stacks[idx - 1];

        if (stack.notes.isNotEmpty ||
            previous.noteValue != stack.noteValue ||
            previous.noteValue == NoteValue.quarter) {
          idx++;
          continue;
        }

        subgroup.stacks.removeAt(idx);
        previous.noteValue = NoteValue.values.firstWhere(
          (note) => note.part == previous.noteValue.part ~/ 2,
        );
        idx = max(idx - 1, 1);
      }
    }
  }

  static void _divideBeatIntoBeams(StaffNoteGroup beat) {
    for (var subgroup in beat.subgroups.values) {
      if (subgroup.noteValue.length == 3) continue;
      _divideGroupIntoBeams(subgroup);
    }
  }

  static void _divideGroupIntoBeams(StaffNoteGroup group) {
    if (group.noteValue == NoteValue.sixtyFourth) return;
    var nextValue = group.noteValue.smaller!;

    var nextValueGroups = <StaffNoteGroup>[];
    var nextValueGroup = StaffNoteGroup(noteValue: nextValue);
    for (var stack in group.stacks) {
      if (stack.noteValue.part >= nextValue.part) {
        nextValueGroup.stacks.add(stack);
        continue;
      }
      if (nextValueGroup.stacks.isEmpty) {
        if (group.noteValue == NoteValue.quarter && stack.notes.isNotEmpty) {
          group.singleNotes.add(stack);
        }
        continue;
      }
      nextValueGroups.add(nextValueGroup);
      nextValueGroup = StaffNoteGroup(noteValue: nextValue);
    }
    if (nextValueGroup.stacks.isNotEmpty) {
      nextValueGroups.add(nextValueGroup);
    }

    for (var subgroup in nextValueGroups) {
      int start = subgroup.stacks.indexWhere((s) => s.notes.isNotEmpty);
      if (start == -1) continue;

      int end = subgroup.stacks.lastIndexWhere((s) => s.notes.isNotEmpty);
      subgroup.stacks = subgroup.stacks.sublist(start, end + 1);
      if (subgroup.stacks.length == 1) {
        group.singleNotes.add(subgroup.stacks.first);
        continue;
      }

      _divideGroupIntoBeams(subgroup);
      group.subgroups[subgroup.stacks.first.start] = subgroup;
    }
  }

  static void _unpackSubgroups(StaffNoteGroup beat) {
    _collectStacksFromSubgroups(beat);
    var subgroups = beat.subgroups.entries.toList();
    for (var group in subgroups) {
      if (group.value.noteValue.length == 3) continue;
      beat.subgroups.remove(group.key);
      beat.singleNotes.addAll(group.value.singleNotes);
      for (var subgroup in group.value.subgroups.entries) {
        beat.subgroups[subgroup.key] = subgroup.value;
      }
    }
  }

  static void _calculateNotePositions(StaffNoteGroup beat, double width) {
    var beatDuration = beat.duration;
    var unitWidth = width / beatDuration.value;
    var noteCenter = 0.5 * EditGridConfiguration.noteWidth;

    for (var stack in beat.stacks) {
      stack.width = stack.noteValue.duration.value * unitWidth;
      stack.x = noteCenter + stack.start.value * unitWidth;
      for (var note in stack.notes) {
        note.position = StaffPoint(
          x: stack.x,
          y: _getNoteLinePosition(note.drum, note.stroke),
        );
      }
      stack.notes.sort((a, b) => a.position.y.compareTo(b.position.y));
      _tuneStackNotePositions(stack);
    }
  }

  static double _getNoteLinePosition(Drum drum, StrokeType stroke) {
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
    return y * FiveLinesSettings.gap;
  }

  static void _tuneStackNotePositions(StaffNoteStack stack) {
    var offset = false;
    var previous = -double.infinity;
    for (var note in stack.notes) {
      note.position.x -= note.position.y * NotesSettings.stemInclineDx;
      var isNear = note.position.y - previous <= FiveLinesSettings.gap + 1e-5;
      previous = note.position.y;
      offset = isNear ? !offset : false;
      if (offset) note.position.x += 2 * NotesSettings.stemOffset;
    }
  }

  static void _setupSingleNoteFlagDirections(StaffNoteGroup beat) {
    if (beat.noteValue == NoteValue.sixtyFourth) return;
    var nextValue = beat.noteValue.smaller;
    var nextValueGroups = <StaffNoteStack, StaffNoteGroup>{
      for (var group in beat.subgroups.values) group.stacks.first: group
    };
    var rightFlag = true;
    var stackIdx = 0;
    while (stackIdx < beat.stacks.length) {
      var stack = beat.stacks[stackIdx++];
      var nextValueGroup = nextValueGroups[stack];
      if (nextValueGroup != null) {
        _setupSingleNoteFlagDirections(nextValueGroup);
        stackIdx += nextValueGroup.stacks.length - 1;
        continue;
      }

      if (stack.notes.isEmpty) {
        if (stack.noteValue == nextValue) {
          rightFlag = !rightFlag;
        }
        continue;
      }

      if (stackIdx == beat.stacks.length) {
        rightFlag = false;
      }

      stack.rightFlag = rightFlag;
    }
  }

  static void _setupSingleNoteStems(StaffNoteGroup beat) {
    var stemEndOffset = NotesSettings.stemInclineDx * NotesSettings.stemLength;
    for (var stack in beat.singleNotes) {
      var lowerNote = stack.notes.last;
      stack.stemStart = StaffPoint(
        x: lowerNote.position.x + NotesSettings.stemOffset,
        y: lowerNote.position.y,
      );

      var upperNote = stack.notes.first;
      stack.stemEnd = StaffPoint(
        x: upperNote.position.x + NotesSettings.stemOffset + stemEndOffset,
        y: upperNote.position.y - NotesSettings.stemLength,
      );
    }
  }

  static void _setupBeamStems(StaffNoteGroup beat) {
    for (var group in beat.subgroups.values) {
      _setupBeamGroupStems(group);
    }
  }

  static void _setupBeamGroupStems(StaffNoteGroup group) {
    var startStack = group.stacks.first;
    var endY = startStack.notes.isNotEmpty
        ? startStack.notes.first.position.y - NotesSettings.stemLength
        : double.infinity;

    var previousStackPosition = startStack.x;
    for (var division in group.stacks) {
      var dx = division.x - previousStackPosition;
      endY -= NotesSettings.beamInclineDx * dx;
      previousStackPosition = division.x;
      if (division.notes.isEmpty) continue;
      var upperNoteY = division.notes.first.position.y;
      var noteStemEnd = upperNoteY - NotesSettings.stemLength;
      if (noteStemEnd < endY) endY = noteStemEnd;
    }

    var endStack = group.stacks.last;
    var length = endStack.x - startStack.x;
    var startY = endY + length * NotesSettings.beamInclineDx;
    if (endY < -FiveLinesSettings.center) {
      group.beamInclineDx = (FiveLinesSettings.center + startY) / length;
    }

    for (var stack in group.stacks) {
      var stackDx = stack.x - startStack.x;
      var stemEndY = startY - group.beamInclineDx * stackDx;

      if (stack.notes.isNotEmpty) {
        var lowerNote = stack.notes.last.position;
        var stemStartX = lowerNote.x + NotesSettings.stemOffset;
        var stemLength = lowerNote.y - stemEndY;
        var stemIncline = NotesSettings.stemInclineDx * stemLength;
        var stemEndX = lowerNote.x + NotesSettings.stemOffset + stemIncline;
        stack.stemStart = StaffPoint(x: stemStartX, y: lowerNote.y);
        stack.stemEnd = StaffPoint(x: stemEndX, y: stemEndY);
        continue;
      }

      if (group.noteValue.length != 3) continue;

      var stemEndIncline = NotesSettings.stemInclineDx * -stemEndY;
      var stemEndOffset = NotesSettings.stemOffset + stemEndIncline;
      var stemEndX = stack.x + stemEndOffset;
      stack.stemEnd = StaffPoint(x: stemEndX, y: stemEndY);

      var stemLength = NotesSettings.flagWidth;
      var stemStartIncline = NotesSettings.stemInclineDx * stemLength;
      var stemStartX = stemEndX - stemStartIncline;
      var stemStartY = stemEndY + stemLength;
      stack.stemStart = StaffPoint(x: stemStartX, y: stemStartY);
    }
  }
}

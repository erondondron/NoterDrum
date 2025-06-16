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
  List<StaffNote> notes;

  late double x;
  late double width;
  StaffPoint? stemStart;
  StaffPoint? stemEnd;

  bool rightFlag = true;

  NoteDuration get end => start + noteValue.duration;

  StaffNoteStack({
    required this.start,
    this.noteValue = NoteValue.thirtySecond,
    List<StaffNote>? notes,
  }) : notes = notes ?? [];
}

class StaffNoteGroup {
  List<StaffNoteStack> stacks;
  Map<NoteDuration, StaffNoteGroup> subgroups;
  List<StaffNoteStack> singleNotes;

  NoteValue noteValue = NoteValue.quarter;
  double _beamInclineDx = NotesSettings.beamInclineDx;

  double get width => stacks.isNotEmpty ? stacks.last.x - stacks.first.x : 0;

  NoteDuration get duration =>
      stacks.isNotEmpty ? stacks.last.end - stacks.first.start : NoteDuration();

  double get beamInclineDx => _beamInclineDx;

  set beamInclineDx(double value) {
    _beamInclineDx = value;
    for (var subgroup in subgroups.values) {
      subgroup.beamInclineDx = value;
    }
  }

  StaffNoteGroup({
    this.noteValue = NoteValue.quarter,
    List<StaffNoteStack>? stacks,
    Map<NoteDuration, StaffNoteGroup>? subgroups,
    List<StaffNoteStack>? singleNotes,
  })  : stacks = stacks ?? [],
        subgroups = subgroups ?? {},
        singleNotes = singleNotes ?? [];
}

class StaffConverter {
  static StaffNoteGroup convertBeat(Beat grooveBeat) {
    var beat = StaffNoteGroup();
    var beatDuration = getBeatDuration(grooveBeat);

    var triplets = convertTriplets(grooveBeat);
    beat.subgroups = mergeTriplets(triplets);
    fillRestStacks(beat, beatDuration);

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

  @visibleForTesting
  static NoteDuration getBeatDuration(Beat grooveBeat) {
    return NoteDuration.fromNoteValue(
      noteValue: grooveBeat.noteValue,
      count: grooveBeat.length,
    );
  }

  @visibleForTesting
  static List<StaffTriplet> convertTriplets(Beat grooveBeat) {
    var triplets = <StaffTriplet>[];
    for (var gridLine in grooveBeat.notesGrid) {
      var lineDuration = NoteDuration();
      for (var triplet in gridLine.notes) {
        var noteStart = lineDuration;
        lineDuration += triplet.value.unit.duration;

        if (triplet is! Triplet ||
            triplet.second.stroke == StrokeType.rest &&
                triplet.third.stroke == StrokeType.rest) {
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

  @visibleForTesting
  static Map<NoteDuration, StaffNoteGroup> mergeTriplets(
    List<StaffTriplet> triplets,
  ) {
    var groups = <NoteDuration, StaffNoteGroup>{};
    for (var noteValue in NoteValue.values.where((v) => v.length == 3)) {
      for (var triplet in triplets.where((t) => t.noteValue == noteValue)) {
        var tripletStart = triplet.notes.first.start;
        if (!groups.containsKey(tripletStart)) {
          groups[tripletStart] = createNoteGroup(
            tripletStart,
            noteValue,
            withParents: true,
          );
        }
        var group = groups[tripletStart]!;
        for (var note in triplet.notes) {
          if (note.stroke == StrokeType.rest) continue;
          var stack = StaffNoteStack(
            start: note.start,
            noteValue: noteValue,
            notes: [note],
          );
          mergeTripletWithStack(group, stack);
        }
      }
    }

    var step = NoteDuration();
    var toProcess = groups.entries.toList();
    toProcess.sort((a, b) => a.key.value.compareTo(b.key.value));
    while (toProcess.length > 1) {
      var triplet = toProcess.first;
      step = triplet.value.stacks.last.end;

      var toMerge = toProcess.where((t) => t.key < step).toList();
      var residue = <StaffNoteStack>[];
      toProcess = toProcess.sublist(toMerge.length);

      for (var subTriplet in toMerge.sublist(1)) {
        groups.remove(subTriplet.key);
        for (var stack in subTriplet.value.stacks) {
          var success = mergeTripletWithStack(triplet.value, stack);
          if (!success) residue.add(stack);
        }
      }

      if (residue.isNotEmpty) {
        var last = residue.map((s) => s.start).reduce((a, b) => a > b ? a : b);
        var noteValue = NoteValue.sixtyFourthTriplet;
        while (noteValue != NoteValue.eighthTriplet) {
          var noteValueEnd = step + noteValue.unit.duration;
          if (noteValueEnd < last) {
            noteValue = noteValue.larger!;
            continue;
          }
          if (toProcess.isNotEmpty) {
            last = toProcess
                .where((t) => t.key < noteValueEnd)
                .map((t) => t.value.stacks.last.start)
                .reduce((a, b) => a > b ? a : b);
          }
          if (noteValueEnd >= last) break;
        }

        var newTriplet = createNoteGroup(step, noteValue, withParents: true);
        for (var stack in residue) {
          mergeTripletWithStack(newTriplet, stack);
        }
        if (toProcess.isNotEmpty && toProcess.first.key == step) {
          var nextTriplet = toProcess.removeAt(0);
          for (var stack in nextTriplet.value.stacks) {
            mergeTripletWithStack(newTriplet, stack);
          }
        }
        groups[step] = newTriplet;
        toProcess.insert(0, MapEntry(step, newTriplet));
      }
    }
    return groups;
  }

  @visibleForTesting
  static bool mergeTripletWithStack(
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
    if (stack.start >= tripletHalf) subTripletStart = tripletHalf;
    subTriplet = triplet.subgroups[subTripletStart];
    if (subTriplet == null) {
      var subTripletValue = triplet.noteValue.smaller;
      if (subTripletValue == null) return false;
      subTriplet = createNoteGroup(
        subTripletStart,
        subTripletValue,
        stacks: tripletStacks,
      );
    }

    var success = mergeTripletWithStack(subTriplet, stack);
    if (!success) return false;

    triplet.subgroups[subTripletStart] = subTriplet;
    collectStacksFromSubgroups(triplet);
    return true;
  }

  @visibleForTesting
  static StaffNoteGroup createNoteGroup(
    NoteDuration start,
    NoteValue noteValue, {
    bool withParents = false,
    Map<NoteDuration, StaffNoteStack>? stacks,
  }) {
    var stackDuration = noteValue.duration;
    var groupStacks = <StaffNoteStack>[];
    for (var i = 0; i < noteValue.length; i++) {
      var stackStart = start + stackDuration * i;
      var stack = stacks?[stackStart] ??
          StaffNoteStack(
            start: stackStart,
            noteValue: noteValue,
          );
      stack.noteValue = noteValue;
      groupStacks.add(stack);
    }
    var group = StaffNoteGroup(
      noteValue: noteValue,
      stacks: groupStacks,
    );
    if (withParents) {
      var nestedValue = noteValue.larger;
      while (nestedValue != null) {
        group = StaffNoteGroup(
          noteValue: nestedValue,
          stacks: groupStacks,
          subgroups: {start: group},
        );
        nestedValue = nestedValue.larger;
      }
    }
    return group;
  }

  @visibleForTesting
  static void collectStacksFromSubgroups(StaffNoteGroup group) {
    if (group.subgroups.isEmpty) {
      group.stacks.sort((a, b) => a.start.value.compareTo(b.start.value));
      return;
    }
    var stacks = group.stacks.toSet();
    for (var subgroup in group.subgroups.values) {
      collectStacksFromSubgroups(subgroup);
      stacks.addAll(subgroup.stacks);
    }
    group.stacks = stacks.toList();
    group.stacks.sort((a, b) => a.start.value.compareTo(b.start.value));
  }

  @visibleForTesting
  static void fillRestStacks(StaffNoteGroup beat, NoteDuration beatDuration) {
    var subgroups = beat.subgroups.entries.toList()
      ..sort((a, b) => b.key.value.compareTo(a.key.value));
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
          if (note.stroke == StrokeType.rest) continue;
          singleNote = note;
        } else if (note is Triplet) {
          if (note.first.stroke == StrokeType.rest ||
              note.second.stroke != StrokeType.rest ||
              note.third.stroke != StrokeType.rest) {
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
          mergeTripletWithStack(subgroup, stack);
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
      if (group.noteValue == NoteValue.quarter) {
        int start = subgroup.stacks.indexWhere((s) => s.notes.isNotEmpty);
        if (start == -1) continue;

        int end = subgroup.stacks.lastIndexWhere((s) => s.notes.isNotEmpty);
        subgroup.stacks = subgroup.stacks.sublist(start, end + 1);
      }

      if (subgroup.stacks.length == 1) {
        group.singleNotes.add(subgroup.stacks.first);
        continue;
      }

      _divideGroupIntoBeams(subgroup);
      group.subgroups[subgroup.stacks.first.start] = subgroup;
    }
  }

  static void _unpackSubgroups(StaffNoteGroup beat) {
    collectStacksFromSubgroups(beat);
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
    for (var stack in beat.singleNotes) {
      var lowerNote = stack.notes.last;
      stack.stemStart = StaffPoint(
        x: lowerNote.position.x + NotesSettings.stemOffset,
        y: lowerNote.position.y,
      );

      var upperNote = stack.notes.first;
      var stemFlagLength = _getStemFlagLength(stack.noteValue);
      var stemLength = NotesSettings.stemLength + stemFlagLength / 2;
      var stemEndOffset = NotesSettings.stemInclineDx * stemLength;
      stack.stemEnd = StaffPoint(
        x: upperNote.position.x + NotesSettings.stemOffset + stemEndOffset,
        y: upperNote.position.y - stemLength,
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
    for (var stack in group.stacks) {
      var dx = stack.x - previousStackPosition;
      endY -= NotesSettings.beamInclineDx * dx;
      previousStackPosition = stack.x;

      double stemEnd;
      var stemFlagWidth = _getStemFlagLength(stack.noteValue);
      if (stack.notes.isNotEmpty) {
        var upperNoteY = stack.notes.first.position.y;
        var stemLength = NotesSettings.stemLength + stemFlagWidth / 2;
        stemEnd = upperNoteY - stemLength;
      } else {
        var upperLineY = -2 * FiveLinesSettings.gap;
        stemEnd = upperLineY - stemFlagWidth;
      }
      if (stemEnd < endY) endY = stemEnd;
    }

    var endStack = group.stacks.last;
    var length = endStack.x - startStack.x;
    var startY = endY + length * NotesSettings.beamInclineDx;
    if (endY < -FiveLinesSettings.top) {
      group.beamInclineDx = (FiveLinesSettings.top + startY) / length;
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

      var stemEndIncline = NotesSettings.stemInclineDx * -stemEndY;
      var stemEndOffset = NotesSettings.stemOffset + stemEndIncline;
      var stemEndX = stack.x + stemEndOffset;
      stack.stemEnd = StaffPoint(x: stemEndX, y: stemEndY);

      var stemLength = _getStemFlagLength(stack.noteValue);
      var stemStartIncline = NotesSettings.stemInclineDx * stemLength;
      var stemStartX = stemEndX - stemStartIncline;
      var stemStartY = stemEndY + stemLength;
      stack.stemStart = StaffPoint(x: stemStartX, y: stemStartY);
    }
  }

  static double _getStemFlagLength(NoteValue noteValue) {
    if (noteValue.length == 3) noteValue = noteValue.unit.smaller!;
    var relative = noteValue.part.bitLength - NoteValue.quarter.part.bitLength;
    return relative * NotesSettings.flagWidth;
  }
}

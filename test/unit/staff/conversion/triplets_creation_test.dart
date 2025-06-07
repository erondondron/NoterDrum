import 'package:drums/features/models/drum_set.dart';
import 'package:drums/features/models/note.dart';
import 'package:drums/features/models/note_value.dart';
import 'package:drums/features/staff/models.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

void createEmptyTriplet() {
  var actual = StaffConverter.createNoteGroup(
    NoteDuration(value: 100),
    NoteValue.sixtyFourthTriplet,
  );

  var expected = StaffNoteGroup(
    noteValue: NoteValue.sixtyFourthTriplet,
    stacks: [
      StaffNoteStack(
        start: NoteDuration(value: 100),
        noteValue: NoteValue.sixtyFourthTriplet,
      ),
      StaffNoteStack(
        start: NoteDuration(value: 102),
        noteValue: NoteValue.sixtyFourthTriplet,
      ),
      StaffNoteStack(
        start: NoteDuration(value: 104),
        noteValue: NoteValue.sixtyFourthTriplet,
      ),
    ],
  );

  compareNoteGroups(actual, expected);
}

void createTripletWithParents() {
  var actual = StaffConverter.createNoteGroup(
    NoteDuration(value: 100),
    NoteValue.sixtyFourthTriplet,
    withParents: true,
  );

  var expected = StaffNoteGroup(
    noteValue: NoteValue.sixtyFourthTriplet,
    stacks: [
      StaffNoteStack(
        start: NoteDuration(value: 100),
        noteValue: NoteValue.sixtyFourthTriplet,
      ),
      StaffNoteStack(
        start: NoteDuration(value: 102),
        noteValue: NoteValue.sixtyFourthTriplet,
      ),
      StaffNoteStack(
        start: NoteDuration(value: 104),
        noteValue: NoteValue.sixtyFourthTriplet,
      ),
    ],
  );
  expected = StaffNoteGroup(
    noteValue: NoteValue.thirtySecondTriplet,
    stacks: expected.stacks,
    subgroups: {NoteDuration(value: 100): expected},
  );
  expected = StaffNoteGroup(
    noteValue: NoteValue.sixteenthTriplet,
    stacks: expected.stacks,
    subgroups: {NoteDuration(value: 100): expected},
  );
  expected = StaffNoteGroup(
    noteValue: NoteValue.eighthTriplet,
    stacks: expected.stacks,
    subgroups: {NoteDuration(value: 100): expected},
  );

  compareNoteGroups(actual, expected);
}

void createFullTriplet() {
  var stacks = <NoteDuration, StaffNoteStack>{
    NoteDuration(): StaffNoteStack(
      start: NoteDuration(),
      noteValue: NoteValue.eighth,
    ),
    NoteDuration(value: 24): StaffNoteStack(
      start: NoteDuration(value: 24),
      noteValue: NoteValue.eighth,
    ),
    NoteDuration(value: 48): StaffNoteStack(
      start: NoteDuration(value: 48),
      noteValue: NoteValue.quarter,
      notes: [
        StaffNote(
          start: NoteDuration(value: 48),
          stroke: StrokeType.rimShot,
          drum: Drum.snare,
        ),
        StaffNote(
          start: NoteDuration(value: 48),
          stroke: StrokeType.opened,
          drum: Drum.hiHat,
        ),
      ],
    ),
    NoteDuration(value: 56): StaffNoteStack(
      start: NoteDuration(value: 56),
      noteValue: NoteValue.quarter,
      notes: [
        StaffNote(
          start: NoteDuration(value: 56),
          stroke: StrokeType.plain,
          drum: Drum.kick,
        ),
      ],
    ),
  };

  var actual = StaffConverter.createNoteGroup(
    NoteDuration(value: 48),
    NoteValue.thirtySecondTriplet,
    stacks: stacks,
  );

  var expected = StaffNoteGroup(
    noteValue: NoteValue.thirtySecondTriplet,
    stacks: [
      StaffNoteStack(
        start: NoteDuration(value: 48),
        noteValue: NoteValue.thirtySecondTriplet,
        notes: [
          StaffNote(
            start: NoteDuration(value: 48),
            stroke: StrokeType.rimShot,
            drum: Drum.snare,
          ),
          StaffNote(
            start: NoteDuration(value: 48),
            stroke: StrokeType.opened,
            drum: Drum.hiHat,
          ),
        ],
      ),
      StaffNoteStack(
        start: NoteDuration(value: 52),
        noteValue: NoteValue.thirtySecondTriplet,
      ),
      StaffNoteStack(
        start: NoteDuration(value: 56),
        noteValue: NoteValue.thirtySecondTriplet,
        notes: [
          StaffNote(
            start: NoteDuration(value: 56),
            stroke: StrokeType.plain,
            drum: Drum.kick,
          ),
        ],
      ),
    ],
  );

  compareNoteGroups(actual, expected);
}

void main() {
  test("should create triplet with empty stacks", createEmptyTriplet);
  test("should create triplet with parents", createTripletWithParents);
  test("should create triplet with reused note stacks", createFullTriplet);
}

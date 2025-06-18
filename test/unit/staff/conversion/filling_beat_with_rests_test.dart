import 'package:drums/models/note_value.dart';
import 'package:drums/staff/models.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

void notFillingFullBeat() {
  var actual = StaffNoteGroup(subgroups: {
    NoteDuration(): StaffConverter.createNoteGroup(
      NoteDuration(),
      NoteValue.sixteenthTriplet,
      withParents: true,
    ),
    NoteDuration(value: 24): StaffConverter.createNoteGroup(
      NoteDuration(value: 24),
      NoteValue.sixteenthTriplet,
      withParents: true,
    ),
  });

  var expected = StaffNoteGroup(subgroups: {
    NoteDuration(): StaffConverter.createNoteGroup(
      NoteDuration(),
      NoteValue.sixteenthTriplet,
      withParents: true,
    ),
    NoteDuration(value: 24): StaffConverter.createNoteGroup(
      NoteDuration(value: 24),
      NoteValue.sixteenthTriplet,
      withParents: true,
    ),
  });

  var beatDuration = NoteDuration.fromNoteValue(noteValue: NoteValue.quarter);
  StaffConverter.fillRestStacks(actual, beatDuration);
  compareNoteGroups(actual, expected);
}

void fullFillingEmptyBeat() {
  var actual = StaffNoteGroup();

  restGenerator(int idx) => StaffNoteStack(start: NoteDuration(value: idx * 6));
  var expectedRest = StaffNoteGroup(stacks: List.generate(8, restGenerator));
  var expected = StaffNoteGroup(subgroups: {NoteDuration(): expectedRest});

  var beatDuration = NoteDuration.fromNoteValue(noteValue: NoteValue.quarter);
  StaffConverter.fillRestStacks(actual, beatDuration);
  compareNoteGroups(actual, expected);
}

void partialFillingBeat() {
  var actual = StaffNoteGroup(subgroups: {
    NoteDuration(value: 12): StaffConverter.createNoteGroup(
      NoteDuration(value: 12),
      NoteValue.sixteenthTriplet,
      withParents: true,
    ),
    NoteDuration(value: 60): StaffConverter.createNoteGroup(
      NoteDuration(value: 60),
      NoteValue.sixteenthTriplet,
      withParents: true,
    ),
  });

  var expected = StaffNoteGroup(subgroups: {
    NoteDuration(value: 0): StaffNoteGroup(stacks: [
      StaffNoteStack(start: NoteDuration(value: 0)),
      StaffNoteStack(start: NoteDuration(value: 6)),
    ]),
    NoteDuration(value: 12): StaffConverter.createNoteGroup(
      NoteDuration(value: 12),
      NoteValue.sixteenthTriplet,
      withParents: true,
    ),
    NoteDuration(value: 36): StaffNoteGroup(stacks: [
      StaffNoteStack(start: NoteDuration(value: 36)),
      StaffNoteStack(start: NoteDuration(value: 42)),
      StaffNoteStack(start: NoteDuration(value: 48)),
      StaffNoteStack(start: NoteDuration(value: 54)),
    ]),
    NoteDuration(value: 60): StaffConverter.createNoteGroup(
      NoteDuration(value: 60),
      NoteValue.sixteenthTriplet,
      withParents: true,
    ),
    NoteDuration(value: 84): StaffNoteGroup(stacks: [
      StaffNoteStack(start: NoteDuration(value: 84)),
      StaffNoteStack(start: NoteDuration(value: 90)),
    ]),
  });

  var beatDuration = NoteDuration.fromNoteValue(
    noteValue: NoteValue.quarter,
    count: 2,
  );
  StaffConverter.fillRestStacks(actual, beatDuration);
  compareNoteGroups(actual, expected);
}

void main() {
  test("should not filling beat with the rests", notFillingFullBeat);
  test("should fill whole beat with the rests", fullFillingEmptyBeat);
  test("should fill rests in the correct places", partialFillingBeat);
}

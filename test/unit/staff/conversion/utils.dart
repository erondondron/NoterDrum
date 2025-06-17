import 'package:drums/models/note_value.dart';
import 'package:drums/staff/models.dart';
import 'package:flutter_test/flutter_test.dart';

void comparePoints(StaffPoint actual, StaffPoint expected) {
  expect(actual.x, expected.x);
  expect(actual.y, expected.y);
}

void compareNotes(
  StaffNote actual,
  StaffNote expected, {
  bool withPosition = false,
}) {
  expect(actual.start, expected.start);
  expect(actual.stroke, expected.stroke);
  expect(actual.drum, expected.drum);
  if (withPosition) {
    comparePoints(
      actual.position,
      expected.position,
    );
  }
}

void compareTriplets(
  StaffTriplet actual,
  StaffTriplet expected, {
  bool withPositions = false,
}) {
  expect(actual.noteValue, expected.noteValue);
  expect(actual.notes.length, expected.notes.length);
  for (var (noteIdx, expectedNote) in expected.notes.indexed) {
    var actualNote = actual.notes[noteIdx];
    compareNotes(actualNote, expectedNote, withPosition: withPositions);
  }
}

void compareNoteStacks(
  StaffNoteStack actual,
  StaffNoteStack expected, {
  bool withPositions = false,
}) {
  expect(actual.start, expected.start);
  expect(actual.noteValue, expected.noteValue);
  expect(actual.rightFlag, expected.rightFlag);

  if (withPositions) {
    expect(actual.x, expected.x);
    expect(actual.width, expected.width);
  }

  expect(actual.notes.length, expected.notes.length);
  for (var (noteIdx, expectedNote) in expected.notes.indexed) {
    var actualNote = actual.notes[noteIdx];
    compareNotes(actualNote, expectedNote, withPosition: withPositions);
  }

  if (expected.stemStart != null) {
    comparePoints(
      actual.stemStart!,
      expected.stemStart!,
    );
  }
  if (expected.stemStart != null) {
    comparePoints(
      actual.stemStart!,
      expected.stemStart!,
    );
  }
}

void compareNoteStackLists(
  List<StaffNoteStack> actual,
  List<StaffNoteStack> expected, {
  bool withPositions = false,
}) {
  expect(actual.length, expected.length);
  for (var (stackIdx, expectedStack) in expected.indexed) {
    var actualStack = actual[stackIdx];
    compareNoteStacks(actualStack, expectedStack, withPositions: withPositions);
  }
}

void compareNoteGroups(
  StaffNoteGroup actual,
  StaffNoteGroup expected, {
  bool withPositions = false,
}) {
  expect(actual.noteValue, expected.noteValue);
  expect(actual.beamInclineDx, expected.beamInclineDx);

  compareNoteStackLists(actual.stacks, expected.stacks);
  compareNoteGroupMaps(actual.subgroups, expected.subgroups);
  compareNoteStackLists(actual.singleNotes, expected.singleNotes);
}

void compareNoteGroupMaps(
  Map<NoteDuration, StaffNoteGroup> actual,
  Map<NoteDuration, StaffNoteGroup> expected, {
  bool withPositions = false,
}) {
  expect(actual.length, expected.length);
  for (var expectedSubgroupStart in expected.keys) {
    var expectedSubgroup = expected[expectedSubgroupStart];
    var actualSubgroup = actual[expectedSubgroupStart];
    assert(actualSubgroup != null);
    compareNoteGroups(
      actualSubgroup!,
      expectedSubgroup!,
      withPositions: withPositions,
    );
  }
}

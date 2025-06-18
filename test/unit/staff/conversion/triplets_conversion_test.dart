import 'package:drums/models/beat.dart';
import 'package:drums/models/drum_set.dart';
import 'package:drums/models/note.dart';
import 'package:drums/models/note_value.dart';
import 'package:drums/staff/models.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

void compareTripletLists(
    List<StaffTriplet> actual, List<StaffTriplet> expected) {
  expect(actual.length, expected.length);
  for (var (tripletIdx, expectedTriplet) in expected.indexed) {
    var actualTriplet = actual[tripletIdx];
    compareTriplets(actualTriplet, expectedTriplet);
  }
}

void convertTriplets() {
  var notes = [
    Triplet(
      value: NoteValue.sixteenthTriplet,
      first: TripletNote(
        value: NoteValue.sixteenthTriplet,
        stroke: StrokeType.plain,
      ),
      second: TripletNote(
        value: NoteValue.sixteenthTriplet,
        stroke: StrokeType.ghost,
      ),
      third: TripletNote(
        value: NoteValue.sixteenthTriplet,
        stroke: StrokeType.plain,
      ),
    ),
    Triplet(
      value: NoteValue.sixteenthTriplet,
      first: TripletNote(
        value: NoteValue.sixteenthTriplet,
        stroke: StrokeType.ghost,
      ),
      second: TripletNote(
        value: NoteValue.sixteenthTriplet,
        stroke: StrokeType.plain,
      ),
      third: TripletNote(
        value: NoteValue.sixteenthTriplet,
        stroke: StrokeType.ghost,
      ),
    ),
  ];
  var beat = Beat(
    notesGrid: [BeatLine(notes: notes, drum: Drum.snare)],
    noteValue: NoteValue.quarter,
    length: 1,
  );

  var expected = [
    StaffTriplet(noteValue: NoteValue.sixteenthTriplet, notes: [
      StaffNote(
        start: NoteDuration(value: 0),
        stroke: StrokeType.plain,
        drum: Drum.snare,
      ),
      StaffNote(
        start: NoteDuration(value: 8),
        stroke: StrokeType.ghost,
        drum: Drum.snare,
      ),
      StaffNote(
        start: NoteDuration(value: 16),
        stroke: StrokeType.plain,
        drum: Drum.snare,
      ),
    ]),
    StaffTriplet(noteValue: NoteValue.sixteenthTriplet, notes: [
      StaffNote(
        start: NoteDuration(value: 24),
        stroke: StrokeType.ghost,
        drum: Drum.snare,
      ),
      StaffNote(
        start: NoteDuration(value: 32),
        stroke: StrokeType.plain,
        drum: Drum.snare,
      ),
      StaffNote(
        start: NoteDuration(value: 40),
        stroke: StrokeType.ghost,
        drum: Drum.snare,
      ),
    ]),
  ];

  var actual = StaffConverter.convertTriplets(beat);
  compareTripletLists(actual, expected);
}

void convertSingleNotes() {
  var notes = [
    SingleNote(
      value: NoteValue.sixteenthTriplet,
      stroke: StrokeType.plain,
    ),
    SingleNote(
      value: NoteValue.sixteenthTriplet,
      stroke: StrokeType.plain,
    ),
    SingleNote(
      value: NoteValue.sixteenthTriplet,
      stroke: StrokeType.plain,
    ),
    SingleNote(
      value: NoteValue.sixteenthTriplet,
      stroke: StrokeType.plain,
    ),
  ];
  var beat = Beat(
    notesGrid: [BeatLine(notes: notes, drum: Drum.snare)],
    noteValue: NoteValue.quarter,
    length: 1,
  );

  var expected = <StaffTriplet>[];
  var actual = StaffConverter.convertTriplets(beat);
  compareTripletLists(actual, expected);
}

void convertMixedNotes() {
  var notes = [
    SingleNote(
      value: NoteValue.thirtySecond,
      stroke: StrokeType.plain,
    ),
    SingleNote(
      value: NoteValue.thirtySecond,
      stroke: StrokeType.ghost,
    ),
    Triplet(
      value: NoteValue.thirtySecondTriplet,
      first: TripletNote(
        value: NoteValue.thirtySecondTriplet,
        stroke: StrokeType.plain,
      ),
      second: TripletNote(
        value: NoteValue.thirtySecondTriplet,
        stroke: StrokeType.ghost,
      ),
      third: TripletNote(
        value: NoteValue.thirtySecondTriplet,
        stroke: StrokeType.plain,
      ),
    ),
    Triplet(
      value: NoteValue.thirtySecondTriplet,
      first: TripletNote(
        value: NoteValue.thirtySecondTriplet,
        stroke: StrokeType.plain,
      ),
      second: TripletNote(
        value: NoteValue.thirtySecondTriplet,
        stroke: StrokeType.rest,
      ),
      third: TripletNote(
        value: NoteValue.thirtySecondTriplet,
        stroke: StrokeType.rest,
      ),
    ),
    Triplet(
      value: NoteValue.thirtySecondTriplet,
      first: TripletNote(
        value: NoteValue.thirtySecondTriplet,
        stroke: StrokeType.ghost,
      ),
      second: TripletNote(
        value: NoteValue.thirtySecondTriplet,
        stroke: StrokeType.plain,
      ),
      third: TripletNote(
        value: NoteValue.thirtySecondTriplet,
        stroke: StrokeType.ghost,
      ),
    ),
  ];
  var beat = Beat(
    notesGrid: [BeatLine(notes: notes, drum: Drum.snare)],
    noteValue: NoteValue.quarter,
    length: 1,
  );

  var expected = [
    StaffTriplet(noteValue: NoteValue.thirtySecondTriplet, notes: [
      StaffNote(
        start: NoteDuration(value: 12),
        stroke: StrokeType.plain,
        drum: Drum.snare,
      ),
      StaffNote(
        start: NoteDuration(value: 16),
        stroke: StrokeType.ghost,
        drum: Drum.snare,
      ),
      StaffNote(
        start: NoteDuration(value: 20),
        stroke: StrokeType.plain,
        drum: Drum.snare,
      ),
    ]),
    StaffTriplet(noteValue: NoteValue.thirtySecondTriplet, notes: [
      StaffNote(
        start: NoteDuration(value: 36),
        stroke: StrokeType.ghost,
        drum: Drum.snare,
      ),
      StaffNote(
        start: NoteDuration(value: 40),
        stroke: StrokeType.plain,
        drum: Drum.snare,
      ),
      StaffNote(
        start: NoteDuration(value: 44),
        stroke: StrokeType.ghost,
        drum: Drum.snare,
      ),
    ]),
  ];

  var actual = StaffConverter.convertTriplets(beat);
  compareTripletLists(actual, expected);
}

void main() {
  test("should convert triplets correctly", convertTriplets);
  test("should not convert single notes", convertSingleNotes);
  test(
    "should convert only triplets containing "
    "notes in second and third stacks",
    convertMixedNotes,
  );
}

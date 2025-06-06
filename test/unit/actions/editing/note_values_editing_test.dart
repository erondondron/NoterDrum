import 'package:drums/features/actions/editing/model.dart';
import 'package:drums/features/models/beat.dart';
import 'package:drums/features/models/drum_set.dart';
import 'package:drums/features/models/note.dart';
import 'package:drums/features/models/note_value.dart';
import 'package:test/test.dart';

void compareSingleNotes(SingleNote actual, SingleNote expected) {
  expect(actual.value, expected.value);
  expect(actual.stroke, expected.stroke);
  expect(actual.isSelected, expected.isSelected);
  expect(actual.isValid, expected.isValid);
}

void compareTriplets(Triplet actual, Triplet expected) {
  expect(actual.value, expected.value);
  compareSingleNotes(actual.first, expected.first);
  compareSingleNotes(actual.second, expected.second);
  compareSingleNotes(actual.third, expected.third);
}

void compareGridLines(BeatLine actual, BeatLine expected) {
  expect(actual.notes.length, expected.notes.length);
  for (var (idx, expectedNote) in expected.notes.indexed) {
    var actualNote = actual.notes[idx];
    if (expectedNote is SingleNote) {
      assert(actualNote is SingleNote);
      compareSingleNotes(actualNote as SingleNote, expectedNote);
    }
    if (expectedNote is Triplet) {
      assert(actualNote is Triplet);
      compareTriplets(actualNote as Triplet, expectedNote);
    }
  }
}

void changeNoteValues(
  BeatLine input,
  Set<SingleNote> selected,
  NoteValue newValue,
) {
  for (var note in selected) {
    note.isSelected = true;
  }
  var controller = NotesEditingController(drumSet: DrumSet());
  controller.changeLineNotesValues(input, selected, newValue);
}

Triplet generateTestTriplet({
  required NoteValue noteValue,
  bool isSelected = false,
}) {
  return Triplet(
    value: noteValue,
    first: TripletNote(value: noteValue)..isSelected = isSelected,
    second: TripletNote(value: noteValue)..isSelected = isSelected,
    third: TripletNote(value: noteValue)..isSelected = isSelected,
  );
}

void quarterNoteValueEditing() {
  test("Quarter to the same value", () {
    var selectedNotes = <SingleNote>[SingleNote(value: NoteValue.quarter)];
    var actualNotes = <Note>[
      SingleNote(value: NoteValue.quarter),
      ...selectedNotes,
      SingleNote(value: NoteValue.quarter),
    ];
    var inputLine = BeatLine(notes: actualNotes, drum: Drum.snare);
    changeNoteValues(inputLine, selectedNotes.toSet(), NoteValue.quarter);

    var expectedNotes = [
      SingleNote(value: NoteValue.quarter),
      SingleNote(value: NoteValue.quarter)..isSelected = true,
      SingleNote(value: NoteValue.quarter),
    ];
    var expectedLine = BeatLine(notes: expectedNotes, drum: Drum.snare);
    compareGridLines(inputLine, expectedLine);
  });

  test("Quarter in the start of line to eight", () {
    var selectedNotes = <SingleNote>[SingleNote(value: NoteValue.quarter)];
    var actualNotes = <Note>[
      ...selectedNotes,
      SingleNote(value: NoteValue.eighth),
      SingleNote(value: NoteValue.eighth),
    ];
    var inputLine = BeatLine(notes: actualNotes, drum: Drum.snare);
    changeNoteValues(inputLine, selectedNotes.toSet(), NoteValue.eighth);

    var expectedNotes = [
      SingleNote(value: NoteValue.eighth)..isSelected = true,
      SingleNote(value: NoteValue.eighth)..isSelected = true,
      SingleNote(value: NoteValue.eighth),
      SingleNote(value: NoteValue.eighth),
    ];
    var expectedLine = BeatLine(notes: expectedNotes, drum: Drum.snare);
    compareGridLines(inputLine, expectedLine);
  });

  test("Quarter in the middle of line to eight", () {
    var selectedNotes = <SingleNote>[SingleNote(value: NoteValue.quarter)];
    var actualNotes = <Note>[
      SingleNote(value: NoteValue.eighth),
      ...selectedNotes,
      SingleNote(value: NoteValue.eighth),
    ];
    var inputLine = BeatLine(notes: actualNotes, drum: Drum.snare);
    changeNoteValues(inputLine, selectedNotes.toSet(), NoteValue.eighth);

    var expectedNotes = [
      SingleNote(value: NoteValue.eighth),
      SingleNote(value: NoteValue.eighth)..isSelected = true,
      SingleNote(value: NoteValue.eighth)..isSelected = true,
      SingleNote(value: NoteValue.eighth),
    ];
    var expectedLine = BeatLine(notes: expectedNotes, drum: Drum.snare);
    compareGridLines(inputLine, expectedLine);
  });

  test("Quarter in the end of line to eight", () {
    var selectedNotes = <SingleNote>[SingleNote(value: NoteValue.quarter)];
    var actualNotes = <Note>[
      SingleNote(value: NoteValue.eighth),
      SingleNote(value: NoteValue.eighth),
      ...selectedNotes,
    ];
    var inputLine = BeatLine(notes: actualNotes, drum: Drum.snare);
    changeNoteValues(inputLine, selectedNotes.toSet(), NoteValue.eighth);

    var expectedNotes = [
      SingleNote(value: NoteValue.eighth),
      SingleNote(value: NoteValue.eighth),
      SingleNote(value: NoteValue.eighth)..isSelected = true,
      SingleNote(value: NoteValue.eighth)..isSelected = true,
    ];
    var expectedLine = BeatLine(notes: expectedNotes, drum: Drum.snare);
    compareGridLines(inputLine, expectedLine);
  });

  test("Quarter to sixteenth triplet", () {
    var selectedNotes = <SingleNote>[SingleNote(value: NoteValue.quarter)];
    var actualNotes = <Note>[
      generateTestTriplet(noteValue: NoteValue.sixteenthTriplet),
      ...selectedNotes,
      generateTestTriplet(noteValue: NoteValue.sixteenthTriplet),
    ];
    var inputLine = BeatLine(notes: actualNotes, drum: Drum.snare);
    changeNoteValues(
      inputLine,
      selectedNotes.toSet(),
      NoteValue.sixteenthTriplet,
    );

    var expectedNotes = [
      generateTestTriplet(noteValue: NoteValue.sixteenthTriplet),
      generateTestTriplet(
        noteValue: NoteValue.sixteenthTriplet,
        isSelected: true,
      ),
      generateTestTriplet(
        noteValue: NoteValue.sixteenthTriplet,
        isSelected: true,
      ),
      generateTestTriplet(noteValue: NoteValue.sixteenthTriplet),
    ];
    var expectedLine = BeatLine(notes: expectedNotes, drum: Drum.snare);
    compareGridLines(inputLine, expectedLine);
  });

  test("Quarter to thirty second", () {
    var selectedNotes = <SingleNote>[SingleNote(value: NoteValue.quarter)];
    var actualNotes = <Note>[
      SingleNote(value: NoteValue.thirtySecond),
      ...selectedNotes,
      SingleNote(value: NoteValue.thirtySecond),
    ];
    var inputLine = BeatLine(notes: actualNotes, drum: Drum.snare);
    changeNoteValues(inputLine, selectedNotes.toSet(), NoteValue.thirtySecond);

    var expectedNotes = [
      SingleNote(value: NoteValue.thirtySecond),
      SingleNote(value: NoteValue.thirtySecond)..isSelected = true,
      SingleNote(value: NoteValue.thirtySecond)..isSelected = true,
      SingleNote(value: NoteValue.thirtySecond)..isSelected = true,
      SingleNote(value: NoteValue.thirtySecond)..isSelected = true,
      SingleNote(value: NoteValue.thirtySecond)..isSelected = true,
      SingleNote(value: NoteValue.thirtySecond)..isSelected = true,
      SingleNote(value: NoteValue.thirtySecond)..isSelected = true,
      SingleNote(value: NoteValue.thirtySecond)..isSelected = true,
      SingleNote(value: NoteValue.thirtySecond),
    ];
    var expectedLine = BeatLine(notes: expectedNotes, drum: Drum.snare);
    compareGridLines(inputLine, expectedLine);
  });
}

void sixteenthTripletNoteValueEditing() {
  test("Sixteenth triplet to the same value", () {
    var selectedTriplet = generateTestTriplet(
      noteValue: NoteValue.sixteenthTriplet,
    );
    var actualNotes = <Note>[
      generateTestTriplet(noteValue: NoteValue.sixteenthTriplet),
      selectedTriplet,
      generateTestTriplet(noteValue: NoteValue.sixteenthTriplet),
    ];
    var inputLine = BeatLine(notes: actualNotes, drum: Drum.snare);
    changeNoteValues(
      inputLine,
      selectedTriplet.notes.toSet(),
      NoteValue.sixteenthTriplet,
    );

    var expectedNotes = [
      generateTestTriplet(noteValue: NoteValue.sixteenthTriplet),
      generateTestTriplet(
        noteValue: NoteValue.sixteenthTriplet,
        isSelected: true,
      ),
      generateTestTriplet(noteValue: NoteValue.sixteenthTriplet),
    ];
    var expectedLine = BeatLine(notes: expectedNotes, drum: Drum.snare);
    compareGridLines(inputLine, expectedLine);
  });

  test("Sixteenth triplet in the start of line to eight", () {
    var selectedTriplet = generateTestTriplet(
      noteValue: NoteValue.sixteenthTriplet,
    );
    var actualNotes = <Note>[
      selectedTriplet,
      generateTestTriplet(noteValue: NoteValue.sixteenthTriplet),
      generateTestTriplet(noteValue: NoteValue.sixteenthTriplet),
    ];
    var inputLine = BeatLine(notes: actualNotes, drum: Drum.snare);
    changeNoteValues(
      inputLine,
      selectedTriplet.notes.toSet(),
      NoteValue.eighth,
    );

    var expectedNotes = [
      SingleNote(value: NoteValue.eighth)..isSelected = true,
      generateTestTriplet(noteValue: NoteValue.sixteenthTriplet),
      generateTestTriplet(noteValue: NoteValue.sixteenthTriplet),
    ];
    var expectedLine = BeatLine(notes: expectedNotes, drum: Drum.snare);
    compareGridLines(inputLine, expectedLine);
  });

  test("Sixteenth triplet in the middle of line to eight", () {
    var selectedTriplet = generateTestTriplet(
      noteValue: NoteValue.sixteenthTriplet,
    );
    var actualNotes = <Note>[
      generateTestTriplet(noteValue: NoteValue.sixteenthTriplet),
      selectedTriplet,
      generateTestTriplet(noteValue: NoteValue.sixteenthTriplet),
    ];
    var inputLine = BeatLine(notes: actualNotes, drum: Drum.snare);
    changeNoteValues(
      inputLine,
      selectedTriplet.notes.toSet(),
      NoteValue.eighth,
    );

    var expectedNotes = [
      generateTestTriplet(noteValue: NoteValue.sixteenthTriplet),
      SingleNote(value: NoteValue.eighth)..isSelected = true,
      generateTestTriplet(noteValue: NoteValue.sixteenthTriplet),
    ];
    var expectedLine = BeatLine(notes: expectedNotes, drum: Drum.snare);
    compareGridLines(inputLine, expectedLine);
  });

  test("Sixteenth triplet in the end of line to eight", () {
    var selectedTriplet = generateTestTriplet(
      noteValue: NoteValue.sixteenthTriplet,
    );
    var actualNotes = <Note>[
      generateTestTriplet(noteValue: NoteValue.sixteenthTriplet),
      generateTestTriplet(noteValue: NoteValue.sixteenthTriplet),
      selectedTriplet,
    ];
    var inputLine = BeatLine(notes: actualNotes, drum: Drum.snare);
    changeNoteValues(
      inputLine,
      selectedTriplet.notes.toSet(),
      NoteValue.eighth,
    );

    var expectedNotes = [
      generateTestTriplet(noteValue: NoteValue.sixteenthTriplet),
      generateTestTriplet(noteValue: NoteValue.sixteenthTriplet),
      SingleNote(value: NoteValue.eighth)..isSelected = true,
    ];
    var expectedLine = BeatLine(notes: expectedNotes, drum: Drum.snare);
    compareGridLines(inputLine, expectedLine);
  });

  test("Sixteenth triplet to thirty second", () {
    var selectedTriplet = generateTestTriplet(
      noteValue: NoteValue.sixteenthTriplet,
    );
    var actualNotes = <Note>[
      generateTestTriplet(noteValue: NoteValue.sixteenthTriplet),
      selectedTriplet,
      generateTestTriplet(noteValue: NoteValue.sixteenthTriplet),
    ];
    var inputLine = BeatLine(notes: actualNotes, drum: Drum.snare);
    changeNoteValues(
      inputLine,
      selectedTriplet.notes.toSet(),
      NoteValue.thirtySecond,
    );

    var expectedNotes = [
      generateTestTriplet(noteValue: NoteValue.sixteenthTriplet),
      SingleNote(value: NoteValue.thirtySecond)..isSelected = true,
      SingleNote(value: NoteValue.thirtySecond)..isSelected = true,
      SingleNote(value: NoteValue.thirtySecond)..isSelected = true,
      SingleNote(value: NoteValue.thirtySecond)..isSelected = true,
      generateTestTriplet(noteValue: NoteValue.sixteenthTriplet),
    ];
    var expectedLine = BeatLine(notes: expectedNotes, drum: Drum.snare);
    compareGridLines(inputLine, expectedLine);
  });

  test("Sixteenth triplet to too large note value", () {
    var selectedTriplet = generateTestTriplet(
      noteValue: NoteValue.sixteenthTriplet,
    );
    var actualNotes = <Note>[
      generateTestTriplet(noteValue: NoteValue.sixteenthTriplet),
      selectedTriplet,
      generateTestTriplet(noteValue: NoteValue.sixteenthTriplet),
    ];
    var inputLine = BeatLine(notes: actualNotes, drum: Drum.snare);
    changeNoteValues(
      inputLine,
      selectedTriplet.notes.toSet(),
      NoteValue.quarter,
    );

    var expectedNotes = [
      generateTestTriplet(noteValue: NoteValue.sixteenthTriplet),
      SingleNote(value: NoteValue.eighth)
        ..isSelected = true
        ..isValid = false,
      generateTestTriplet(noteValue: NoteValue.sixteenthTriplet),
    ];
    var expectedLine = BeatLine(notes: expectedNotes, drum: Drum.snare);
    compareGridLines(inputLine, expectedLine);
  });

  test("Part of sixteenth triplet to eight", () {
    var selectedTriplet = generateTestTriplet(
      noteValue: NoteValue.sixteenthTriplet,
    );
    var actualNotes = <Note>[
      generateTestTriplet(noteValue: NoteValue.sixteenthTriplet),
      selectedTriplet,
      generateTestTriplet(noteValue: NoteValue.sixteenthTriplet),
    ];
    var inputLine = BeatLine(notes: actualNotes, drum: Drum.snare);
    changeNoteValues(
      inputLine,
      {selectedTriplet.first, selectedTriplet.second},
      NoteValue.eighth,
    );

    var highlightedTriplet = generateTestTriplet(
      noteValue: NoteValue.sixteenthTriplet,
    );
    highlightedTriplet.first
      ..isValid = false
      ..isSelected = true;
    highlightedTriplet.second
      ..isValid = false
      ..isSelected = true;
    var expectedNotes = [
      generateTestTriplet(noteValue: NoteValue.sixteenthTriplet),
      highlightedTriplet,
      generateTestTriplet(noteValue: NoteValue.sixteenthTriplet),
    ];
    var expectedLine = BeatLine(notes: expectedNotes, drum: Drum.snare);
    compareGridLines(inputLine, expectedLine);
  });
}

void main() {
  group("Note values editing", () {
    group("Quarter note value editing", quarterNoteValueEditing);
    group("Sixteenth triplet value editing", sixteenthTripletNoteValueEditing);
  });
}

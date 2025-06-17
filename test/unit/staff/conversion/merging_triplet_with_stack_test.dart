import 'package:drums/models/drum_set.dart';
import 'package:drums/models/note.dart';
import 'package:drums/models/note_value.dart';
import 'package:drums/staff/models.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

void mergeTriplet() {
  var actualSubTriplet = StaffNoteGroup(
    noteValue: NoteValue.sixteenthTriplet,
    stacks: [
      StaffNoteStack(
        start: NoteDuration(value: 24),
        noteValue: NoteValue.sixteenthTriplet,
      ),
      StaffNoteStack(
        start: NoteDuration(value: 32),
        noteValue: NoteValue.sixteenthTriplet,
      ),
      StaffNoteStack(
        start: NoteDuration(value: 40),
        noteValue: NoteValue.sixteenthTriplet,
      ),
    ],
  );

  var actual = StaffNoteGroup(
    noteValue: NoteValue.eighthTriplet,
    stacks: [
      StaffNoteStack(
        start: NoteDuration(value: 0),
        noteValue: NoteValue.eighthTriplet,
      ),
      StaffNoteStack(
        start: NoteDuration(value: 16),
        noteValue: NoteValue.eighthTriplet,
      ),
      ...actualSubTriplet.stacks,
    ],
    subgroups: {NoteDuration(value: 24): actualSubTriplet},
  );

  var stacks = [
    StaffNoteStack(
      noteValue: NoteValue.quarter,
      start: NoteDuration(value: 0),
      notes: [
        StaffNote(
          start: NoteDuration(value: 0),
          stroke: StrokeType.rimShot,
          drum: Drum.snare,
        ),
        StaffNote(
          start: NoteDuration(value: 0),
          stroke: StrokeType.opened,
          drum: Drum.hiHat,
        ),
      ],
    ),
    StaffNoteStack(
      noteValue: NoteValue.thirtySecond,
      start: NoteDuration(value: 24),
      notes: [
        StaffNote(
          start: NoteDuration(value: 24),
          stroke: StrokeType.plain,
          drum: Drum.kick,
        ),
      ],
    ),
  ];

  var expectedSubTriplet = StaffNoteGroup(
    noteValue: NoteValue.sixteenthTriplet,
    stacks: [
      StaffNoteStack(
        start: NoteDuration(value: 24),
        noteValue: NoteValue.sixteenthTriplet,
        notes: [
          StaffNote(
            start: NoteDuration(value: 24),
            stroke: StrokeType.plain,
            drum: Drum.kick,
          ),
        ],
      ),
      StaffNoteStack(
        start: NoteDuration(value: 32),
        noteValue: NoteValue.sixteenthTriplet,
      ),
      StaffNoteStack(
        start: NoteDuration(value: 40),
        noteValue: NoteValue.sixteenthTriplet,
      ),
    ],
  );

  var expected = StaffNoteGroup(
    noteValue: NoteValue.eighthTriplet,
    stacks: [
      StaffNoteStack(
        start: NoteDuration(value: 0),
        noteValue: NoteValue.eighthTriplet,
        notes: [
          StaffNote(
            start: NoteDuration(value: 0),
            stroke: StrokeType.rimShot,
            drum: Drum.snare,
          ),
          StaffNote(
            start: NoteDuration(value: 0),
            stroke: StrokeType.opened,
            drum: Drum.hiHat,
          ),
        ],
      ),
      StaffNoteStack(
        start: NoteDuration(value: 16),
        noteValue: NoteValue.eighthTriplet,
      ),
      ...expectedSubTriplet.stacks,
    ],
    subgroups: {NoteDuration(value: 24): expectedSubTriplet},
  );

  for (var stack in stacks) {
    StaffConverter.mergeTripletWithStack(actual, stack);
  }
  compareNoteGroups(actual, expected);
}

void mergeTripletWithGrinding() {
  var actual = StaffNoteGroup(
    noteValue: NoteValue.eighthTriplet,
    stacks: [
      StaffNoteStack(
        start: NoteDuration(value: 0),
        noteValue: NoteValue.eighthTriplet,
        notes: [
          StaffNote(
            start: NoteDuration(value: 0),
            stroke: StrokeType.plain,
            drum: Drum.kick,
          ),
        ],
      ),
      StaffNoteStack(
        start: NoteDuration(value: 16),
        noteValue: NoteValue.eighthTriplet,
        notes: [
          StaffNote(
            start: NoteDuration(value: 16),
            stroke: StrokeType.plain,
            drum: Drum.kick,
          ),
        ],
      ),
      StaffNoteStack(
        start: NoteDuration(value: 32),
        noteValue: NoteValue.eighthTriplet,
        notes: [
          StaffNote(
            start: NoteDuration(value: 32),
            stroke: StrokeType.plain,
            drum: Drum.kick,
          ),
        ],
      ),
    ],
  );

  var stacks = [
    StaffNoteStack(
      noteValue: NoteValue.sixteenth,
      start: NoteDuration(value: 0),
      notes: [
        StaffNote(
          start: NoteDuration(value: 0),
          stroke: StrokeType.accent,
          drum: Drum.snare,
        ),
      ],
    ),
    StaffNoteStack(
      noteValue: NoteValue.sixteenth,
      start: NoteDuration(value: 12),
      notes: [
        StaffNote(
          start: NoteDuration(value: 12),
          stroke: StrokeType.plain,
          drum: Drum.snare,
        ),
      ],
    ),
    StaffNoteStack(
      noteValue: NoteValue.sixteenth,
      start: NoteDuration(value: 24),
      notes: [
        StaffNote(
          start: NoteDuration(value: 24),
          stroke: StrokeType.ghost,
          drum: Drum.snare,
        ),
      ],
    ),
    StaffNoteStack(
      noteValue: NoteValue.sixteenth,
      start: NoteDuration(value: 36),
      notes: [
        StaffNote(
          start: NoteDuration(value: 36),
          stroke: StrokeType.rimClick,
          drum: Drum.snare,
        ),
      ],
    ),
  ];

  var firstNestedSubTriplet = StaffNoteGroup(
    noteValue: NoteValue.thirtySecondTriplet,
    stacks: [
      StaffNoteStack(
        start: NoteDuration(value: 12),
        noteValue: NoteValue.thirtySecondTriplet,
        notes: [
          StaffNote(
            start: NoteDuration(value: 12),
            stroke: StrokeType.plain,
            drum: Drum.snare,
          ),
        ],
      ),
      StaffNoteStack(
        start: NoteDuration(value: 16),
        noteValue: NoteValue.thirtySecondTriplet,
        notes: [
          StaffNote(
            start: NoteDuration(value: 16),
            stroke: StrokeType.plain,
            drum: Drum.kick,
          ),
        ],
      ),
      StaffNoteStack(
        start: NoteDuration(value: 20),
        noteValue: NoteValue.thirtySecondTriplet,
      ),
    ],
  );

  var firstSubTriplet = StaffNoteGroup(
    noteValue: NoteValue.sixteenthTriplet,
    stacks: [
      StaffNoteStack(
        start: NoteDuration(value: 0),
        noteValue: NoteValue.sixteenthTriplet,
        notes: [
          StaffNote(
            start: NoteDuration(value: 0),
            stroke: StrokeType.plain,
            drum: Drum.kick,
          ),
          StaffNote(
            start: NoteDuration(value: 0),
            stroke: StrokeType.accent,
            drum: Drum.snare,
          ),
        ],
      ),
      StaffNoteStack(
        start: NoteDuration(value: 8),
        noteValue: NoteValue.sixteenthTriplet,
      ),
      ...firstNestedSubTriplet.stacks,
    ],
    subgroups: {NoteDuration(value: 12): firstNestedSubTriplet},
  );

  var secondNestedSubTriplet = StaffNoteGroup(
    noteValue: NoteValue.thirtySecondTriplet,
    stacks: [
      StaffNoteStack(
        start: NoteDuration(value: 36),
        noteValue: NoteValue.thirtySecondTriplet,
        notes: [
          StaffNote(
            start: NoteDuration(value: 36),
            stroke: StrokeType.rimClick,
            drum: Drum.snare,
          ),
        ],
      ),
      StaffNoteStack(
        start: NoteDuration(value: 40),
        noteValue: NoteValue.thirtySecondTriplet,
      ),
      StaffNoteStack(
        start: NoteDuration(value: 44),
        noteValue: NoteValue.thirtySecondTriplet,
      ),
    ],
  );

  var secondSubTriplet = StaffNoteGroup(
    noteValue: NoteValue.sixteenthTriplet,
    stacks: [
      StaffNoteStack(
        start: NoteDuration(value: 24),
        noteValue: NoteValue.sixteenthTriplet,
        notes: [
          StaffNote(
            start: NoteDuration(value: 24),
            stroke: StrokeType.ghost,
            drum: Drum.snare,
          ),
        ],
      ),
      StaffNoteStack(
        start: NoteDuration(value: 32),
        noteValue: NoteValue.sixteenthTriplet,
        notes: [
          StaffNote(
            start: NoteDuration(value: 32),
            stroke: StrokeType.plain,
            drum: Drum.kick,
          ),
        ],
      ),
      ...secondNestedSubTriplet.stacks,
    ],
    subgroups: {NoteDuration(value: 36): secondNestedSubTriplet},
  );

  var expected = StaffNoteGroup(
    noteValue: NoteValue.eighthTriplet,
    stacks: [
      ...firstSubTriplet.stacks,
      ...secondSubTriplet.stacks,
    ],
    subgroups: {
      NoteDuration(value: 0): firstSubTriplet,
      NoteDuration(value: 24): secondSubTriplet,
    },
  );

  for (var stack in stacks) {
    StaffConverter.mergeTripletWithStack(actual, stack);
  }
  compareNoteGroups(actual, expected);
}

void main() {
  test("should put notes to existing stack in triplet", mergeTriplet);
  test(
    "should put notes to new stacks with creation new smaller triplets",
    mergeTripletWithGrinding,
  );
}

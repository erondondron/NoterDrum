import 'package:drums/features/models/drum_set.dart';
import 'package:drums/features/models/note.dart';
import 'package:drums/features/models/note_value.dart';
import 'package:drums/features/staff/models.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

void mergeWithSameValues() {
  var triplets = <StaffTriplet>[
    StaffTriplet(
      noteValue: NoteValue.eighthTriplet,
      notes: [
        StaffNote(
          start: NoteDuration(value: 0),
          stroke: StrokeType.plain,
          drum: Drum.tom3,
        ),
        StaffNote(
          start: NoteDuration(value: 16),
          stroke: StrokeType.off,
          drum: Drum.tom3,
        ),
        StaffNote(
          start: NoteDuration(value: 32),
          stroke: StrokeType.plain,
          drum: Drum.tom3,
        ),
      ],
    ),
    StaffTriplet(
      noteValue: NoteValue.eighthTriplet,
      notes: [
        StaffNote(
          start: NoteDuration(value: 0),
          stroke: StrokeType.off,
          drum: Drum.snare,
        ),
        StaffNote(
          start: NoteDuration(value: 16),
          stroke: StrokeType.plain,
          drum: Drum.snare,
        ),
        StaffNote(
          start: NoteDuration(value: 32),
          stroke: StrokeType.off,
          drum: Drum.snare,
        ),
      ],
    ),
    StaffTriplet(
      noteValue: NoteValue.sixteenthTriplet,
      notes: [
        StaffNote(
          start: NoteDuration(value: 48),
          stroke: StrokeType.off,
          drum: Drum.tom3,
        ),
        StaffNote(
          start: NoteDuration(value: 56),
          stroke: StrokeType.plain,
          drum: Drum.tom3,
        ),
        StaffNote(
          start: NoteDuration(value: 64),
          stroke: StrokeType.off,
          drum: Drum.tom3,
        ),
      ],
    ),
    StaffTriplet(
      noteValue: NoteValue.sixteenthTriplet,
      notes: [
        StaffNote(
          start: NoteDuration(value: 48),
          stroke: StrokeType.plain,
          drum: Drum.snare,
        ),
        StaffNote(
          start: NoteDuration(value: 56),
          stroke: StrokeType.off,
          drum: Drum.snare,
        ),
        StaffNote(
          start: NoteDuration(value: 64),
          stroke: StrokeType.plain,
          drum: Drum.snare,
        ),
      ],
    ),
  ];

  var firstEightTriplet = StaffNoteGroup(
    noteValue: NoteValue.eighthTriplet,
    stacks: [
      StaffNoteStack(
        start: NoteDuration(value: 0),
        noteValue: NoteValue.eighthTriplet,
        notes: [
          StaffNote(
            start: NoteDuration(value: 0),
            stroke: StrokeType.plain,
            drum: Drum.tom3,
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
            drum: Drum.snare,
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
            drum: Drum.tom3,
          ),
        ],
      ),
    ],
  );

  var sixteenthTriplet = StaffNoteGroup(
    noteValue: NoteValue.sixteenthTriplet,
    stacks: [
      StaffNoteStack(
        start: NoteDuration(value: 48),
        noteValue: NoteValue.sixteenthTriplet,
        notes: [
          StaffNote(
            start: NoteDuration(value: 48),
            stroke: StrokeType.plain,
            drum: Drum.snare,
          ),
        ],
      ),
      StaffNoteStack(
        start: NoteDuration(value: 56),
        noteValue: NoteValue.sixteenthTriplet,
        notes: [
          StaffNote(
            start: NoteDuration(value: 56),
            stroke: StrokeType.plain,
            drum: Drum.tom3,
          ),
        ],
      ),
      StaffNoteStack(
        start: NoteDuration(value: 64),
        noteValue: NoteValue.sixteenthTriplet,
        notes: [
          StaffNote(
            start: NoteDuration(value: 64),
            stroke: StrokeType.plain,
            drum: Drum.snare,
          ),
        ],
      ),
    ],
  );

  var secondEightTriplet = StaffNoteGroup(
    noteValue: NoteValue.eighthTriplet,
    stacks: sixteenthTriplet.stacks,
    subgroups: {NoteDuration(value: 48): sixteenthTriplet},
  );

  var expected = {
    NoteDuration(value: 0): firstEightTriplet,
    NoteDuration(value: 48): secondEightTriplet,
  };

  var actual = StaffConverter.mergeTriplets(triplets);
  compareNoteGroupMaps(actual, expected);
}

void mergeWithDifferentValues() {
  var triplets = <StaffTriplet>[
    StaffTriplet(
      noteValue: NoteValue.eighthTriplet,
      notes: [
        StaffNote(
          start: NoteDuration(value: 0),
          stroke: StrokeType.plain,
          drum: Drum.kick,
        ),
        StaffNote(
          start: NoteDuration(value: 16),
          stroke: StrokeType.plain,
          drum: Drum.kick,
        ),
        StaffNote(
          start: NoteDuration(value: 32),
          stroke: StrokeType.plain,
          drum: Drum.kick,
        ),
      ],
    ),
    StaffTriplet(
      noteValue: NoteValue.eighthTriplet,
      notes: [
        StaffNote(
          start: NoteDuration(value: 48),
          stroke: StrokeType.plain,
          drum: Drum.kick,
        ),
        StaffNote(
          start: NoteDuration(value: 64),
          stroke: StrokeType.plain,
          drum: Drum.kick,
        ),
        StaffNote(
          start: NoteDuration(value: 80),
          stroke: StrokeType.plain,
          drum: Drum.kick,
        ),
      ],
    ),
    StaffTriplet(
      noteValue: NoteValue.sixteenthTriplet,
      notes: [
        StaffNote(
          start: NoteDuration(value: 24),
          stroke: StrokeType.plain,
          drum: Drum.snare,
        ),
        StaffNote(
          start: NoteDuration(value: 32),
          stroke: StrokeType.plain,
          drum: Drum.snare,
        ),
        StaffNote(
          start: NoteDuration(value: 40),
          stroke: StrokeType.plain,
          drum: Drum.snare,
        ),
      ],
    ),
    StaffTriplet(
      noteValue: NoteValue.sixteenthTriplet,
      notes: [
        StaffNote(
          start: NoteDuration(value: 48),
          stroke: StrokeType.plain,
          drum: Drum.snare,
        ),
        StaffNote(
          start: NoteDuration(value: 56),
          stroke: StrokeType.plain,
          drum: Drum.snare,
        ),
        StaffNote(
          start: NoteDuration(value: 64),
          stroke: StrokeType.plain,
          drum: Drum.snare,
        ),
      ],
    ),
  ];

  var firstSubTriplet = StaffNoteGroup(
    noteValue: NoteValue.sixteenthTriplet,
    stacks: [
      StaffNoteStack(
        start: NoteDuration(value: 24),
        noteValue: NoteValue.sixteenthTriplet,
        notes: [
          StaffNote(
            start: NoteDuration(value: 24),
            stroke: StrokeType.plain,
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
          StaffNote(
            start: NoteDuration(value: 32),
            stroke: StrokeType.plain,
            drum: Drum.snare,
          ),
        ],
      ),
      StaffNoteStack(
        start: NoteDuration(value: 40),
        noteValue: NoteValue.sixteenthTriplet,
        notes: [
          StaffNote(
            start: NoteDuration(value: 40),
            stroke: StrokeType.plain,
            drum: Drum.snare,
          ),
        ],
      ),
    ],
  );

  var firstTriplet = StaffNoteGroup(
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
      ...firstSubTriplet.stacks,
    ],
    subgroups: {NoteDuration(value: 24): firstSubTriplet},
  );

  var secondSubTriplet = StaffNoteGroup(
    noteValue: NoteValue.sixteenthTriplet,
    stacks: [
      StaffNoteStack(
        start: NoteDuration(value: 48),
        noteValue: NoteValue.sixteenthTriplet,
        notes: [
          StaffNote(
            start: NoteDuration(value: 48),
            stroke: StrokeType.plain,
            drum: Drum.kick,
          ),
          StaffNote(
            start: NoteDuration(value: 48),
            stroke: StrokeType.plain,
            drum: Drum.snare,
          ),
        ],
      ),
      StaffNoteStack(
        start: NoteDuration(value: 56),
        noteValue: NoteValue.sixteenthTriplet,
        notes: [
          StaffNote(
            start: NoteDuration(value: 56),
            stroke: StrokeType.plain,
            drum: Drum.snare,
          ),
        ],
      ),
      StaffNoteStack(
        start: NoteDuration(value: 64),
        noteValue: NoteValue.sixteenthTriplet,
        notes: [
          StaffNote(
            start: NoteDuration(value: 64),
            stroke: StrokeType.plain,
            drum: Drum.kick,
          ),
          StaffNote(
            start: NoteDuration(value: 64),
            stroke: StrokeType.plain,
            drum: Drum.snare,
          ),
        ],
      ),
    ],
  );

  var secondTriplet = StaffNoteGroup(
    noteValue: NoteValue.eighthTriplet,
    stacks: [
      ...secondSubTriplet.stacks,
      StaffNoteStack(
        start: NoteDuration(value: 80),
        noteValue: NoteValue.eighthTriplet,
        notes: [
          StaffNote(
            start: NoteDuration(value: 80),
            stroke: StrokeType.plain,
            drum: Drum.kick,
          ),
        ],
      ),
    ],
    subgroups: {NoteDuration(value: 48): secondSubTriplet},
  );

  var expected = {
    NoteDuration(value: 0): firstTriplet,
    NoteDuration(value: 48): secondTriplet,
  };

  var actual = StaffConverter.mergeTriplets(triplets);
  compareNoteGroupMaps(actual, expected);
}

void main() {
  test("should merge triplets with same note values", mergeWithSameValues);
  test(
    "should merge triplets with different note values",
    mergeWithDifferentValues,
  );
}

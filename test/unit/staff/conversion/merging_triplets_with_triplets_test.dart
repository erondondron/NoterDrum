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

void mergeOverlappingTriplets() {
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
          start: NoteDuration(value: 24),
          stroke: StrokeType.plain,
          drum: Drum.snare,
        ),
        StaffNote(
          start: NoteDuration(value: 40),
          stroke: StrokeType.plain,
          drum: Drum.snare,
        ),
        StaffNote(
          start: NoteDuration(value: 56),
          stroke: StrokeType.plain,
          drum: Drum.snare,
        ),
      ],
    ),
  ];

  var sixteenthNestedTriplet = StaffNoteGroup(
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

  var eighthTriplet = StaffNoteGroup(
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
      ...sixteenthNestedTriplet.stacks,
    ],
    subgroups: {NoteDuration(value: 24): sixteenthNestedTriplet},
  );

  var sixteenthTriplet = StaffNoteGroup(
    noteValue: NoteValue.sixteenthTriplet,
    stacks: [
      StaffNoteStack(
        start: NoteDuration(value: 48),
        noteValue: NoteValue.sixteenthTriplet,
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
      ),
    ],
  );

  sixteenthTriplet = StaffNoteGroup(
    noteValue: NoteValue.eighthTriplet,
    stacks: sixteenthTriplet.stacks.toList(),
    subgroups: {NoteDuration(value: 48): sixteenthTriplet},
  );

  var expected = {
    NoteDuration(value: 0): eighthTriplet,
    NoteDuration(value: 48): sixteenthTriplet,
  };

  var actual = StaffConverter.mergeTriplets(triplets);
  compareNoteGroupMaps(actual, expected);
}

void mergeDoubleOverlappingTriplets() {
  var triplets = <StaffTriplet>[
    StaffTriplet(
      noteValue: NoteValue.sixteenthTriplet,
      notes: [
        StaffNote(
          start: NoteDuration(value: 0),
          stroke: StrokeType.plain,
          drum: Drum.kick,
        ),
        StaffNote(
          start: NoteDuration(value: 8),
          stroke: StrokeType.plain,
          drum: Drum.kick,
        ),
        StaffNote(
          start: NoteDuration(value: 16),
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
          drum: Drum.kick,
        ),
        StaffNote(
          start: NoteDuration(value: 32),
          stroke: StrokeType.plain,
          drum: Drum.kick,
        ),
        StaffNote(
          start: NoteDuration(value: 40),
          stroke: StrokeType.plain,
          drum: Drum.kick,
        ),
      ],
    ),
    StaffTriplet(
      noteValue: NoteValue.sixteenthTriplet,
      notes: [
        StaffNote(
          start: NoteDuration(value: 12),
          stroke: StrokeType.plain,
          drum: Drum.snare,
        ),
        StaffNote(
          start: NoteDuration(value: 20),
          stroke: StrokeType.plain,
          drum: Drum.snare,
        ),
        StaffNote(
          start: NoteDuration(value: 28),
          stroke: StrokeType.plain,
          drum: Drum.snare,
        ),
      ],
    ),
  ];

  var firstThirtySecondTriplet = StaffNoteGroup(
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
        notes: [
          StaffNote(
            start: NoteDuration(value: 20),
            stroke: StrokeType.plain,
            drum: Drum.snare,
          ),
        ],
      ),
    ],
  );

  var firstSixteenthTriplet = StaffNoteGroup(
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
        ],
      ),
      StaffNoteStack(
        start: NoteDuration(value: 8),
        noteValue: NoteValue.sixteenthTriplet,
        notes: [
          StaffNote(
            start: NoteDuration(value: 8),
            stroke: StrokeType.plain,
            drum: Drum.kick,
          ),
        ],
      ),
      ...firstThirtySecondTriplet.stacks,
    ],
    subgroups: {NoteDuration(value: 12): firstThirtySecondTriplet},
  );

  firstSixteenthTriplet = StaffNoteGroup(
    noteValue: NoteValue.eighthTriplet,
    stacks: firstSixteenthTriplet.stacks.toList(),
    subgroups: {NoteDuration(value: 0): firstSixteenthTriplet},
  );

  var secondThirtySecondTriplet = StaffNoteGroup(
    noteValue: NoteValue.thirtySecondTriplet,
    stacks: [
      StaffNoteStack(
        start: NoteDuration(value: 24),
        noteValue: NoteValue.thirtySecondTriplet,
        notes: [
          StaffNote(
            start: NoteDuration(value: 24),
            stroke: StrokeType.plain,
            drum: Drum.kick,
          ),
        ],
      ),
      StaffNoteStack(
        start: NoteDuration(value: 28),
        noteValue: NoteValue.thirtySecondTriplet,
        notes: [
          StaffNote(
            start: NoteDuration(value: 28),
            stroke: StrokeType.plain,
            drum: Drum.snare,
          ),
        ],
      ),
      StaffNoteStack(
        start: NoteDuration(value: 32),
        noteValue: NoteValue.thirtySecondTriplet,
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

  var secondSixteenthTriplet = StaffNoteGroup(
    noteValue: NoteValue.sixteenthTriplet,
    stacks: [
      ...secondThirtySecondTriplet.stacks,
      StaffNoteStack(
        start: NoteDuration(value: 40),
        noteValue: NoteValue.sixteenthTriplet,
        notes: [
          StaffNote(
            start: NoteDuration(value: 40),
            stroke: StrokeType.plain,
            drum: Drum.kick,
          ),
        ],
      ),
    ],
    subgroups: {NoteDuration(value: 24): secondThirtySecondTriplet},
  );

  secondSixteenthTriplet = StaffNoteGroup(
    noteValue: NoteValue.eighthTriplet,
    stacks: secondSixteenthTriplet.stacks.toList(),
    subgroups: {NoteDuration(value: 24): secondSixteenthTriplet},
  );

  var expected = {
    NoteDuration(value: 0): firstSixteenthTriplet,
    NoteDuration(value: 24): secondSixteenthTriplet,
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
  test("should merge overlapping triplets", mergeOverlappingTriplets);
  test(
    "should merge double overlapping triplets",
    mergeDoubleOverlappingTriplets,
  );
}

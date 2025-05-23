enum NoteValue {
  quarter(part: 4),
  eighth(part: 8),
  eighthTriplet(part: 12, length: 3),
  sixteenth(part: 16),
  sixteenthTriplet(part: 24, length: 3),
  thirtySecond(part: 32),
  thirtySecondTriplet(part: 48, length: 3),
  sixtyFourth(part: 64),
  sixtyFourthTriplet(part: 96, length: 3);

  final int part;
  final int length;

  const NoteValue({
    required this.part,
    this.length = 1,
  });

  NoteValue get unit {
    return switch (this) {
      NoteValue.eighthTriplet => NoteValue.quarter,
      NoteValue.sixteenthTriplet => NoteValue.eighth,
      NoteValue.thirtySecondTriplet => NoteValue.sixteenth,
      NoteValue.sixtyFourthTriplet => NoteValue.thirtySecond,
      _ => this,
    };
  }

  NoteValue? get larger =>
      NoteValue.values.where((note) => note.part == part ~/ 2).firstOrNull;

  NoteValue? get smaller =>
      NoteValue.values.where((note) => note.part == part * 2).firstOrNull;

  NoteDuration get duration => NoteDuration.fromNoteValue(noteValue: this);

  bool operator >(NoteValue other) => part < other.part;

  bool operator >=(NoteValue other) => part <= other.part;

  bool operator <(NoteValue other) => part > other.part;

  bool operator <=(NoteValue other) => part >= other.part;
}

class NoteDuration {
  static const int _baseNotePart = 192;

  final int value;

  const NoteDuration({this.value = 0});

  NoteDuration.fromNoteValue({
    required NoteValue noteValue,
    int count = 1,
  }) : value = count * _baseNotePart ~/ noteValue.part;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NoteDuration && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  NoteDuration operator +(NoteDuration other) =>
      NoteDuration(value: value + other.value);

  NoteDuration operator -(NoteDuration other) =>
      NoteDuration(value: value - other.value);

  NoteDuration operator *(int scalar) => NoteDuration(value: value * scalar);

  NoteDuration operator ~/(int scalar) => NoteDuration(value: value ~/ scalar);

  bool operator >(NoteDuration other) => value > other.value;

  bool operator >=(NoteDuration other) => value >= other.value;

  bool operator <(NoteDuration other) => value < other.value;

  bool operator <=(NoteDuration other) => value <= other.value;
}

enum NoteValues {
  quarter(value: 4),
  eight(value: 8),
  sixteenth(value: 16),
  thirtySecond(value: 32);

  const NoteValues({required this.value});

  final int value;
}

enum StrokeTypes {
  plain(name: "Plain"),
  off(name: "Off");

  const StrokeTypes({required this.name});

  final String name;
}

class NoteModel {
  const NoteModel({
    this.value = NoteValues.sixteenth,
    this.type = StrokeTypes.off,
  });

  final NoteValues value;
  final StrokeTypes type;
}

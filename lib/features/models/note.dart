import 'package:drums/features/models/beat.dart';
import 'package:drums/features/models/drum_set.dart';
import 'package:flutter/material.dart';

const Set<Drum> cymbals = {Drum.crash, Drum.ride};
const Set<Drum> snareAndToms = {Drum.snare, Drum.tom1, Drum.tom2, Drum.tom3};

enum StrokeType {
  opened(name: "Opened", drums: {Drum.hiHat}),
  bell(name: "Bell", drums: cymbals),
  choke(name: "Choke", drums: cymbals),
  accent(name: "Accent"),
  plain(name: "Plain"),
  ghost(name: "Ghost"),
  rimClick(name: "Rim click", drums: snareAndToms),
  rimShot(name: "Rim shot", drums: snareAndToms),
  flam(name: "Flam"),
  foot(name: "Foot", drums: {Drum.hiHat}),
  off(name: "Off");

  final String name;
  final Set<Drum>? drums;

  Set<Drum> get filter => drums ?? Drum.values.toSet();

  const StrokeType({
    required this.name,
    this.drums,
  });
}

enum NoteValue {
  quarter(part: 4),
  eighth(part: 8),
  eighthTriplet(part: 12, length: 3),
  sixteenth(part: 16),
  sixteenthTriplet(part: 24, length: 3),
  thirtySecond(part: 32);

  final int part;
  final int length;

  NoteValue get unit {
    return switch (this) {
      NoteValue.eighthTriplet => NoteValue.quarter,
      NoteValue.sixteenthTriplet => NoteValue.eighth,
      _ => this,
    };
  }

  const NoteValue({
    required this.part,
    this.length = 1,
  });
}

abstract class Note {
  static const double minViewSize = 35;

  final NoteValue value;

  double viewSize = minViewSize;
  late BeatLine beatLine;

  Note({required this.value});

  factory Note.generate({required NoteValue value}) {
    if (value.length == 1) return SingleNote(value: value);
    return Triplet(
      value: value,
      first: TripletNote(value: value),
      second: TripletNote(value: value),
      third: TripletNote(value: value),
    );
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    var value = NoteValue.values.firstWhere(
      (value) => value.part == json["value"] as int,
    );
    if (value.length == 1) return SingleNote.fromJson(json);
    return Triplet.fromJson(json);
  }
}

class SingleNote extends Note {
  StrokeType stroke;

  final GlobalKey key = GlobalKey();
  bool isSelected = false;
  bool isValid = true;

  SingleNote({
    required super.value,
    this.stroke = StrokeType.off,
  });

  SingleNote.fromJson(Map<String, dynamic> json)
      : stroke = StrokeType.values.firstWhere(
          (type) => type.name == json["stroke"] as String,
        ),
        super(
          value: NoteValue.values.firstWhere(
            (value) => value.part == json["value"] as int,
          ),
        );

  Map<String, dynamic> toJson() => {
        "value": value.part,
        "stroke": stroke.name,
      };
}

class TripletNote extends SingleNote {
  late Triplet triplet;

  TripletNote({
    required super.value,
    super.stroke,
  });

  TripletNote.fromJson(Map<String, dynamic> json)
      : super(
          stroke: StrokeType.values.firstWhere(
            (type) => type.name == json["stroke"] as String,
          ),
          value: NoteValue.values.firstWhere(
            (value) => value.part == json["value"] as int,
          ),
        );
}

class Triplet extends Note {
  final TripletNote first;
  final TripletNote second;
  final TripletNote third;

  List<TripletNote> get notes => [first, second, third];

  @override
  set beatLine(BeatLine beatLine) {
    for (var note in notes){
      note.beatLine = beatLine;
    }
  }

  Triplet({
    required super.value,
    required this.first,
    required this.second,
    required this.third,
  }) {
    first.triplet = this;
    second.triplet = this;
    third.triplet = this;
  }

  Triplet.fromJson(Map<String, dynamic> json)
      : first = TripletNote.fromJson(json["first"] as Map<String, dynamic>),
        second = TripletNote.fromJson(json["second"] as Map<String, dynamic>),
        third = TripletNote.fromJson(json["third"] as Map<String, dynamic>),
        super(
          value: NoteValue.values.firstWhere(
            (value) => value.part == json["value"] as int,
          ),
        );

  Map<String, dynamic> toJson() => {
        "value": value.part,
        "first": first.toJson(),
        "second": second.toJson(),
        "third": third.toJson(),
      };
}

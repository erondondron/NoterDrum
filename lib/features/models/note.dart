import 'package:drums/features/models/beat.dart';
import 'package:drums/features/models/drum_set.dart';
import 'package:drums/features/models/note_value.dart';
import 'package:flutter/material.dart';

const Set<Drum> cymbals = {Drum.crash, Drum.ride};
const Set<Drum> snareAndToms = {Drum.snare, Drum.tom1, Drum.tom2, Drum.tom3};

enum StrokeType {
  opened(name: "Opened", icon: "opened.svg", drums: {Drum.hiHat}),
  bell(name: "Bell", icon: "bell.svg", drums: cymbals),
  choke(name: "Choke", icon: "choke.svg", drums: cymbals),
  accent(name: "Accent", icon: "accent.svg"),
  plain(name: "Plain", icon: "plain.svg"),
  ghost(name: "Ghost", icon: "ghost.svg"),
  rimClick(name: "Rim click", icon: "rim_click.svg", drums: snareAndToms),
  rimShot(name: "Rim shot", icon: "rim_shot.svg", drums: snareAndToms),
  flam(name: "Flam", icon: "flam.svg"),
  foot(name: "Foot", icon: "foot.svg", drums: {Drum.hiHat}),
  rest(name: "Rest", icon: "rest.svg");

  final String name;
  final Set<Drum>? drums;
  final String icon;

  Set<Drum> get filter => drums ?? Drum.values.toSet();

  const StrokeType({
    required this.name,
    this.drums,
    required String icon,
  }) : icon = "assets/icons/strokes/$icon";
}

abstract class Note {
  final NoteValue value;

  late BeatLine beatLine;
  late double viewSize;

  Note({required this.value});

  factory Note.generate({required NoteValue value}) {
    return value.length == 1
        ? SingleNote(value: value)
        : Triplet(
            value: value,
            first: TripletNote(value: value),
            second: TripletNote(value: value),
            third: TripletNote(value: value),
          );
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    var value = NoteValue.values.firstWhere(
      (value) => value.part == json["duration"] as int,
    );
    return value.length == 1
        ? Triplet.fromJson(json)
        : SingleNote.fromJson(json);
  }
}

class SingleNote extends Note {
  StrokeType stroke;

  final GlobalKey key = GlobalKey();
  bool isSelected = false;
  bool isValid = true;

  SingleNote({
    required super.value,
    this.stroke = StrokeType.rest,
  });

  SingleNote.fromJson(Map<String, dynamic> json)
      : stroke = StrokeType.values.firstWhere(
          (type) => type.name == json["stroke"] as String,
        ),
        super(
          value: NoteValue.values.firstWhere(
            (value) => value.part == json["duration"] as int,
          ),
        );

  Map<String, dynamic> toJson() => {
        "duration": value.part,
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
            (value) => value.part == json["duration"] as int,
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
    for (var note in notes) {
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
            (value) => value.part == json["duration"] as int,
          ),
        );

  Map<String, dynamic> toJson() => {
        "duration": value.part,
        "first": first.toJson(),
        "second": second.toJson(),
        "third": third.toJson(),
      };
}

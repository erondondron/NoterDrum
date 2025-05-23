import 'package:drums/features/models/note.dart';
import 'package:drums/features/models/time_signature.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TimeSignatureCustomizeWindow extends StatelessWidget {
  const TimeSignatureCustomizeWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TimeSignature>(
      builder: (BuildContext context, TimeSignature timeSignature, _) {
        return AlertDialog(
          title: Text("Custom time signature ${timeSignature.label}"),
          content: Center(child: _EditorWidget(timeSignature: timeSignature)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Accept'),
            ),
          ],
        );
      },
    );
  }
}

class _EditorWidget extends StatelessWidget {
  const _EditorWidget({required this.timeSignature});

  final TimeSignature timeSignature;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...timeSignature.measures.asMap().keys.map(
                (int index) => _BeatsLengthEditor(
                  timeSignature: timeSignature,
                  beatIndex: index,
                ),
              ),
          IconButton(
            icon: Icon(Icons.add_outlined),
            onPressed: timeSignature.addBeat,
          ),
          Padding(
            padding: EdgeInsets.only(left: 10, right: 20),
            child: Text(
              "/",
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ),
          _BeatsNoteValueEditor(timeSignature: timeSignature),
        ],
      ),
    );
  }
}

class _BeatsLengthEditor extends StatelessWidget {
  const _BeatsLengthEditor({
    required this.timeSignature,
    required this.beatIndex,
  });

  final TimeSignature timeSignature;
  final int beatIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.add_outlined),
          onPressed: () => timeSignature.changeBeatLength(
              beatIndex, timeSignature.noteValue.length),
        ),
        // TODO(erondondron): Add note symbols
        Text(
          timeSignature.measures[beatIndex].toString(),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        IconButton(
          icon: Icon(Icons.remove_outlined),
          onPressed: () => timeSignature.changeBeatLength(
              beatIndex, -timeSignature.noteValue.length),
        ),
      ],
    );
  }
}

class _BeatsNoteValueEditor extends StatelessWidget {
  const _BeatsNoteValueEditor({required this.timeSignature});

  final TimeSignature timeSignature;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.add_outlined),
          onPressed: timeSignature.noteValue != NoteValue.values.last
              ? timeSignature.increaseNoteValue
              : null,
        ),
        Text(
          timeSignature.noteValue.part.toString(),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        IconButton(
          icon: Icon(Icons.remove_outlined),
          onPressed: timeSignature.noteValue != NoteValue.values.first
              ? timeSignature.decreaseNoteValue
              : null,
        ),
      ],
    );
  }
}

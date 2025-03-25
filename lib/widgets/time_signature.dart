import 'package:drums/features/sheet_music/bar/models.dart';
import 'package:drums/models/note.dart';
import 'package:drums/models/time_signature.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TimeSignatureWidget extends StatelessWidget {
  const TimeSignatureWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SheetMusicBarModel>(
      builder: (BuildContext context, SheetMusicBarModel bar, _) {
        return PopupMenuButton<TimeSignature>(
          child: Text(bar.timeSignature.label),
          itemBuilder: (BuildContext context) {
            return [
              ...[sixEights, eightEights, sixteenSixteenths].map(
                (TimeSignature timeSignature) => PopupMenuItem(
                  value: timeSignature,
                  child: Text(timeSignature.label),
                  onTap: () => bar.updateTimeSignature(timeSignature),
                ),
              ),
              PopupMenuItem(
                value: bar.timeSignature,
                child: Text("Custom"),
                onTap: () async {
                  final timeSignature = await showDialog<TimeSignature?>(
                    context: context,
                    builder: (_) => _CustomizeWindow(
                      initial: bar.timeSignature,
                    ),
                  );
                  if (timeSignature != null) {
                    bar.updateTimeSignature(timeSignature);
                  }
                },
              ),
            ];
          },
        );
      },
    );
  }
}

class _CustomizeWindow extends StatefulWidget {
  const _CustomizeWindow({required this.initial});

  final TimeSignature initial;

  @override
  State<_CustomizeWindow> createState() => _CustomizeWindowState();
}

class _CustomizeWindowState extends State<_CustomizeWindow> {
  late TimeSignature _timeSignature;

  @override
  void initState() {
    _timeSignature = TimeSignature(
      noteValue: widget.initial.noteValue,
      measures: widget.initial.measures.toList(),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Custom time signature ${_timeSignature.label}"),
      content: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ..._timeSignature.measures.asMap().keys.map(
                    (int index) => measureEditor(index),
                  ),
              IconButton(
                icon: Icon(Icons.add_outlined),
                onPressed: () => setState(() => _timeSignature.measures.add(1)),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10, right: 20),
                child: Text(
                  "/",
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
              noteValues(),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _timeSignature),
          child: const Text('Accept'),
        ),
      ],
    );
  }

  Widget measureEditor(int index) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.add_outlined),
          onPressed: () => setState(() => _timeSignature.measures[index]++),
        ),
        Text(
          _timeSignature.measures[index].toString(),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        IconButton(
          icon: Icon(Icons.remove_outlined),
          onPressed: () => setState(() => _timeSignature.measures[index] > 1
              ? _timeSignature.measures[index]--
              : _timeSignature.measures.removeAt(index)),
        ),
      ],
    );
  }

  Widget noteValues() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.add_outlined),
          onPressed: _timeSignature.noteValue != NoteValues.thirtySecond
              ? () {
                  final nextValue = _timeSignature.noteValue.value * 2;
                  final nextNote = NoteValues.values.firstWhere(
                    (NoteValues note) => note.value == nextValue,
                  );
                  setState(() => _timeSignature.noteValue = nextNote);
                }
              : null,
        ),
        Text(
          _timeSignature.noteValue.value.toString(),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        IconButton(
          icon: Icon(Icons.remove_outlined),
          onPressed: _timeSignature.noteValue != NoteValues.quarter
              ? () {
                  final nextValue = _timeSignature.noteValue.value ~/ 2;
                  final nextNote = NoteValues.values.firstWhere(
                    (NoteValues note) => note.value == nextValue,
                  );
                  setState(() => _timeSignature.noteValue = nextNote);
                }
              : null,
        ),
      ],
    );
  }
}

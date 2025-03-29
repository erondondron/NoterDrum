import 'dart:math';

import 'package:drums/features/actions/editing/model.dart';
import 'package:drums/features/sheet_music/measure/model.dart';
import 'package:drums/features/sheet_music/measure_unit_line/model.dart';
import 'package:drums/features/sheet_music/note/model.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class NotesSelector extends StatefulWidget {
  const NotesSelector({super.key, required this.child});

  final Widget child;

  @override
  State<NotesSelector> createState() => _NotesSelectorState();
}

class _NotesSelectorState extends State<NotesSelector> {
  late NotesEditingController _controller;
  late SheetMusicMeasure _measure;

  Offset? _dragSelectionStart;

  @override
  Widget build(BuildContext context) {
    return Consumer2<NotesEditingController, SheetMusicMeasure>(
      builder: (BuildContext context, NotesEditingController controller,
          SheetMusicMeasure measure, _) {
        if (!controller.isActive) {
          controller.updateSelectedNoteGroups();
          return widget.child;
        }
        _controller = controller;
        _measure = measure;
        return GestureDetector(
          onLongPressStart: _onLongPressStart,
          onLongPressMoveUpdate: _onLongPressMoveUpdate,
          onLongPressEnd: _onLongPressEnd,
          child: widget.child,
        );
      },
    );
  }

  void _onLongPressStart(LongPressStartDetails details) {
    _controller.updateSelectedNoteGroups();
    _dragSelectionStart = details.globalPosition;
  }

  void _onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    if (_dragSelectionStart == null) return;
    var x = [_dragSelectionStart!.dx, details.globalPosition.dx];
    var y = [_dragSelectionStart!.dy, details.globalPosition.dy];

    var newSelection = _getSelectedNotes(
      Offset(x.reduce(min), y.reduce(min)),
      Offset(x.reduce(max), y.reduce(max)),
    );
    _controller.updateSelectedNoteGroups(groups: newSelection);
  }

  void _onLongPressEnd(LongPressEndDetails details) =>
      _dragSelectionStart = null;

  Map<MeasureUnitDrumLine, Set<Note>> _getSelectedNotes(
      Offset topLeft, Offset bottomRight) {
    var notes = <MeasureUnitDrumLine, Set<Note>>{};
    for (var unit in _measure.units.where(
      (unit) => _isSelected(unit.key, topLeft, bottomRight),
    )) {
      for (var line in unit.drumLines.where(
        (line) => _isSelected(line.key, topLeft, bottomRight),
      )) {
        var lineNotes = line.notes
            .where((note) => _isSelected(note.key, topLeft, bottomRight))
            .toSet();
        notes[line] = (lineNotes);
      }
    }
    return notes;
  }

  bool _isSelected(GlobalKey item, Offset topLeft, Offset bottomRight) {
    var renderBox = item.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return false;

    var itemPosition = renderBox.localToGlobal(Offset.zero);

    return topLeft.dx < itemPosition.dx + renderBox.size.width &&
        topLeft.dy < itemPosition.dy + renderBox.size.height &&
        bottomRight.dx > itemPosition.dx &&
        bottomRight.dy > itemPosition.dy;
  }
}

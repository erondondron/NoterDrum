import 'dart:math';

import 'package:drums/features/sheet_music/actions/editing/model.dart';
import 'package:drums/features/sheet_music/beat/models.dart';
import 'package:drums/features/sheet_music/measure/model.dart';
import 'package:drums/features/sheet_music/note/models.dart';
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
  late GrooveMeasure _measure;

  Offset? _dragSelectionStart;

  @override
  Widget build(BuildContext context) {
    return Consumer2<NotesEditingController, GrooveMeasure>(
      builder: (BuildContext context, NotesEditingController controller,
          GrooveMeasure measure, _) {
        if (!controller.isActive) {
          controller.unselect();
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
    _controller.unselect();
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
    _controller.updateSelectedNoteGroups(newSelection);
  }

  void _onLongPressEnd(LongPressEndDetails details) =>
      _dragSelectionStart = null;

  Map<Beat, Set<SingleNote>> _getSelectedNotes(
      Offset topLeft, Offset bottomRight) {
    var newSelection = <Beat, Set<SingleNote>>{};
    for (var beat in _measure.beats.where(
      (beat) => _isSelected(beat.key, topLeft, bottomRight),
    )) {
      var beatSelection = <SingleNote>{};
      for (var beatLine in beat.notesGrid.where(
        (beatLine) => _isSelected(beatLine.key, topLeft, bottomRight),
      )) {
        var lineNotes = beatLine.singleNotes
            .where((note) => _isSelected(note.key, topLeft, bottomRight))
            .toSet();
        beatSelection.addAll(lineNotes);
      }
      newSelection[beat] = beatSelection;
    }
    return newSelection;
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

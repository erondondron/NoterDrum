import 'dart:math';

import 'package:drums/features/actions/editing/model.dart';
import 'package:drums/features/sheet_music/bar/models.dart';
import 'package:drums/features/sheet_music/note/model.dart';
import 'package:drums/features/sheet_music/note/widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class NotesSelector extends StatefulWidget {
  const NotesSelector({super.key, required this.child});

  final Widget child;

  @override
  State<NotesSelector> createState() => _NotesSelectorState();
}

class _NotesSelectorState extends State<NotesSelector> {
  late SheetMusicBarModel _sheetMusicBar;
  late NotesEditingModel _controller;

  Offset? _dragSelectionStart;

  @override
  Widget build(BuildContext context) {
    return Consumer2<NotesEditingModel, SheetMusicBarModel>(
      builder: (BuildContext context, NotesEditingModel controller,
          SheetMusicBarModel bar, _) {
        if (!controller.isActive) {
          controller.updateSelectedNotes();
          return widget.child;
        }
        _sheetMusicBar = bar;
        _controller = controller;
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
    _controller.updateSelectedNotes();
    _dragSelectionStart = details.globalPosition;
  }

  void _onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    if (_dragSelectionStart == null) return;
    var x = [_dragSelectionStart!.dx, details.globalPosition.dx];
    var y = [_dragSelectionStart!.dy, details.globalPosition.dy];

    var selection = _getSelectedNotes(
      startPosition: Offset(x.reduce(min), y.reduce(min)),
      endPosition: Offset(x.reduce(max), y.reduce(max)),
    );
    _controller.updateSelectedNotes(newSelection: selection);
  }

  void _onLongPressEnd(LongPressEndDetails details) =>
      _dragSelectionStart = null;

  List<BarModel> _getSelectedBars({
    required Offset startPosition,
    Offset? endPosition,
  }) {
    var bars = <BarModel>[];
    for (var bar in _sheetMusicBar.drumBars) {
      if (bars.isEmpty) {
        var bellowOrAbove = _getYRelation(startPosition, bar.key);
        if (bellowOrAbove.first || bellowOrAbove.last) continue;
        if (endPosition == null) return [bar];
      }

      bars.add(bar);
      var bellowOrAbove = _getYRelation(endPosition!, bar.key);
      if (!bellowOrAbove.first) return bars;
    }
    return bars;
  }

  Set<NoteModel> _getSelectedNotes({
    required Offset startPosition,
    Offset? endPosition,
  }) {
    var notes = <NoteModel>{};
    for (var drumBar in _getSelectedBars(
      startPosition: startPosition,
      endPosition: endPosition,
    )) {
      var barNotes = <NoteModel>{};
      for (var note in drumBar.beats.expand((beat) => beat.notes)) {
        if (barNotes.isEmpty) {
          var beforeOrAfter = _getXRelation(startPosition, note.key);
          if (beforeOrAfter.first || beforeOrAfter.last) continue;
          barNotes.add(note);
          if (endPosition == null) break;
        }

        barNotes.add(note);
        var beforeOrAfter = _getXRelation(endPosition!, note.key);
        if (!beforeOrAfter.last) break;
      }
      notes.addAll(barNotes);
    }
    return notes;
  }

  List<bool> _getXRelation(Offset position, GlobalKey item) {
    var renderBox = item.currentContext?.findRenderObject();
    if (renderBox == null) return [true, true];

    var itemPosition = (renderBox as RenderBox).localToGlobal(Offset.zero);
    var before = position.dx < itemPosition.dx;
    var after = position.dx >= itemPosition.dx + NoteBox.outerWidth;
    return [before, after];
  }

  List<bool> _getYRelation(Offset position, GlobalKey item) {
    var renderBox = item.currentContext?.findRenderObject();
    if (renderBox == null) return [true, true];

    var itemPosition = (renderBox as RenderBox).localToGlobal(Offset.zero);
    var isAbove = position.dy < itemPosition.dy;
    var isBelow = position.dy >= itemPosition.dy + NoteBox.outerHeight;
    return [isBelow, isAbove];
  }
}

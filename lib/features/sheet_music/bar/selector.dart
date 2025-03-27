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
  SheetMusicBarModel? _sheetMusicBar;

  Offset? _tapSelectionStart;

  Set<NoteModel> _selected = {};

  @override
  Widget build(BuildContext context) {
    return Consumer2<NotesEditingModel, SheetMusicBarModel>(
      builder: (BuildContext context, NotesEditingModel controller,
          SheetMusicBarModel bar, _) {
        if (!controller.isActive) {
          _updateSelected();
          return widget.child;
        }
        _sheetMusicBar = bar;
        return GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          // onLongPressStart: _onLongPressStart,
          child: widget.child,
        );
      },
    );
  }

  void _onTapDown(TapDownDetails details) {
    _tapSelectionStart = details.globalPosition;
  }

  void _onTapUp(TapUpDetails details) {
    if (_tapSelectionStart == null) return;
    var startSelection = _getSelectedNotes(startPosition: _tapSelectionStart!);
    var endSelection = _getSelectedNotes(startPosition: details.globalPosition);
    var newSelection = startSelection.intersection(endSelection);
    _updateSelected(newSelection: newSelection.difference(_selected));
    _tapSelectionStart = null;
  }

  void _updateSelected({Set<NoteModel> newSelection = const {}}) {
    var intersection = _selected.intersection(newSelection);
    var union = _selected.union(newSelection);
    for (var note in union.difference(intersection)) {
      note.select();
    }
    _selected = newSelection;
  }

  List<BarModel> _getSelectedBars({
    required Offset startPosition,
    Offset? endPosition,
  }) {
    var bars = <BarModel>[];
    for (var bar in _sheetMusicBar!.drumBars) {
      if (bars.isEmpty) {
        var bellowOrAbove = _getYRelation(startPosition, bar.key);
        if (bellowOrAbove.first || bellowOrAbove.last) continue;
        if (endPosition == null) return [bar];
        bars.add(bar);
        continue;
      }

      var bellowOrAbove = _getYRelation(startPosition, bar.key);
      if (bellowOrAbove.first) {
        bars.add(bar);
        continue;
      }

      if (bellowOrAbove.last) return bars;
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
      for (var beat in drumBar.beats) {
        var beatNotes = <NoteModel>{};
        for (var note in beat.notes) {
          if (beatNotes.isEmpty) {
            var beforeOrAfter = _getXRelation(startPosition, note.key);
            if (beforeOrAfter.first || beforeOrAfter.last) continue;
            beatNotes.add(note);
            if (endPosition == null) break;
            continue;
          }

          var beforeOrAfter = _getXRelation(startPosition, note.key);
          if (beforeOrAfter.first) {
            beatNotes.add(note);
            continue;
          }

          if (beforeOrAfter.last) break;
        }
        notes.addAll(beatNotes);
      }
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

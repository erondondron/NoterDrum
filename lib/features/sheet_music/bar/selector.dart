import 'package:drums/features/actions/editing/model.dart';
import 'package:drums/features/sheet_music/bar/models.dart';
import 'package:drums/features/sheet_music/note/widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class NotesSelector extends StatelessWidget {
  const NotesSelector({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Consumer2<NotesEditingModel, SheetMusicBarModel>(
      builder: (BuildContext context, NotesEditingModel controller,
          SheetMusicBarModel bar, _) {
        return Listener(
          onPointerDown: controller.isActive
              ? (PointerEvent event) => _onPointerDown(bar, event)
              : null,
          onPointerUp: controller.isActive ? _onPointerUp : null,
          child: child,
        );
      },
    );
  }

  void _onPointerDown(SheetMusicBarModel bar, PointerEvent event) {
    for (var drumBar in bar.drumBars) {
      var renderBox = drumBar.key.currentContext?.findRenderObject();
      if (renderBox == null) return;

      var barPosition = (renderBox as RenderBox).localToGlobal(Offset.zero);
      var isBelow = event.position.dy < barPosition.dy ;
      var isAbove = event.position.dy >= barPosition.dy + NoteBox.outerHeight;
      if (isBelow || isAbove) continue;

      for (var beat in drumBar.beats) {
        for (var note in beat.notes) {
          var renderBox = note.key.currentContext?.findRenderObject();
          if (renderBox == null) continue;

          var position = (renderBox as RenderBox).localToGlobal(Offset.zero);
          var before = event.position.dx < position.dx ;
          var after = event.position.dx >= position.dx + NoteBox.outerWidth;
          if (!before && !after){
            note.select();
            return;
          }
        }
      }
    }
  }

  void _onPointerUp(PointerEvent event) {}
}

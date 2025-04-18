import 'package:drums/features/sheet_music/actions/editing/selector.dart';
import 'package:drums/features/sheet_music/beat/widget.dart';
import 'package:drums/features/sheet_music/measure/model.dart';
import 'package:drums/features/sheet_music/note/widget.dart';
import 'package:drums/features/sheet_music/model.dart';
import 'package:drums/shared/widgets/fix_height_row.dart';
import 'package:drums/features/sheet_music/time_signature/widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GrooveMeasureWidget extends StatelessWidget {
  const GrooveMeasureWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GrooveMeasure>(
      builder: (BuildContext context, GrooveMeasure measure, _) {
        return IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ControlPanel(measure: measure),
              _BeatsPanel(measure: measure),
            ],
          ),
        );
      },
    );
  }
}

class _BeatsPanel extends StatelessWidget {
  const _BeatsPanel({required this.measure});

  final GrooveMeasure measure;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: NotesSelector(
        child: Row(
          children: measure.beats
              .map(
                (beat) => ChangeNotifierProvider.value(
                  value: beat,
                  child: BeatWidget(),
                ),
              )
              .expand((widget) => [widget, VerticalDivider(width: 0)])
              .toList()
            ..removeLast(),
        ),
      ),
    );
  }
}

class _ControlPanel extends StatelessWidget {
  const _ControlPanel({required this.measure});

  final GrooveMeasure measure;

  @override
  Widget build(BuildContext context) {
    final groove = Provider.of<Groove>(context, listen: false);
    return FixHeightRow(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: TimeSignatureWidget(),
        ),
        GestureDetector(
          onTap: () => groove.removeMeasure(measure),
          behavior: HitTestBehavior.translucent,
          child: SizedBox(
            height: NoteView.height,
            width: NoteView.height,
            child: Icon(Icons.close_outlined, size: 20),
          ),
        ),
      ],
    );
  }
}

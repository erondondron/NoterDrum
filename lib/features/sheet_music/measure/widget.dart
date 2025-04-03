import 'package:drums/features/sheet_music/measure/model.dart';
import 'package:drums/features/sheet_music/actions/editing/selector.dart';
import 'package:drums/features/sheet_music/measure_unit/widget.dart';
import 'package:drums/features/sheet_music/model.dart';
import 'package:drums/features/sheet_music/note/widget.dart';
import 'package:drums/shared/widgets/fix_height_row.dart';
import 'package:drums/features/sheet_music/time_signature/widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SheetMusicMeasureWidget extends StatelessWidget {
  const SheetMusicMeasureWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SheetMusicMeasure>(
      builder: (BuildContext context, SheetMusicMeasure measure, _) {
        return IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ControlPanel(measure: measure),
              _UnitsPanel(measure: measure),
            ],
          ),
        );
      },
    );
  }
}

class _UnitsPanel extends StatelessWidget {
  const _UnitsPanel({required this.measure});

  final SheetMusicMeasure measure;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: NotesSelector(
        child: Row(
          children: measure.units
              .map(
                (unit) => ChangeNotifierProvider.value(
                  value: unit,
                  child: MeasureUnitWidget(),
                ),
              )
              .expand((widget) => [widget, VerticalDivider()])
              .toList()
            ..removeLast(),
        ),
      ),
    );
  }
}

class _ControlPanel extends StatelessWidget {
  const _ControlPanel({required this.measure});

  final SheetMusicMeasure measure;

  @override
  Widget build(BuildContext context) {
    final sheetMusic = Provider.of<SheetMusic>(context, listen: false);
    return FixHeightRow(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: TimeSignatureWidget(),
        ),
        GestureDetector(
          onTap: () => sheetMusic.removeMeasure(measure),
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

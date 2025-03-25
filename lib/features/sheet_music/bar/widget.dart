import 'package:drums/features/sheet_music/bar/models.dart';
import 'package:drums/features/sheet_music/bar/selector.dart';
import 'package:drums/features/sheet_music/beat/model.dart';
import 'package:drums/features/sheet_music/model.dart';
import 'package:drums/shared/fix_height_row.dart';
import 'package:drums/features/sheet_music/beat/widget.dart';
import 'package:drums/features/sheet_music/time_signature/widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BarWidget extends StatelessWidget {
  const BarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SheetMusicBarModel>(
      builder: (BuildContext context, SheetMusicBarModel bar, _) {
        return IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FixHeightRow(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: TimeSignatureWidget(),
                  ),
                  _RemoveBarButton(bar: bar),
                ],
              ),
              NotesSelector(
                child: Column(
                  children: bar.drumBars
                      .map((BarModel bar) => _BeatsRow(bar: bar))
                      .toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BeatsRow extends StatelessWidget {
  const _BeatsRow({required this.bar});

  final BarModel bar;

  @override
  Widget build(BuildContext context) {
    return FixHeightRow(
      children: bar.beats
          .map(
            (BeatModel beat) => ChangeNotifierProvider.value(
              value: beat,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: BeatWidget.padding),
                child: BeatWidget(),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _RemoveBarButton extends StatelessWidget {
  const _RemoveBarButton({required this.bar});

  final SheetMusicBarModel bar;

  @override
  Widget build(BuildContext context) {
    final sheetMusic = Provider.of<SheetMusicModel>(context, listen: false);
    return GestureDetector(
      onTap: () => sheetMusic.removeBar(bar),
      behavior: HitTestBehavior.translucent,
      child: SizedBox(
        height: FixHeightRow.height,
        width: FixHeightRow.height,
        child: Icon(Icons.close_outlined, size: 20),
      ),
    );
  }
}

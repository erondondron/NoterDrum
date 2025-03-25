import 'package:drums/models/bar.dart';
import 'package:drums/models/beat.dart';
import 'package:drums/models/sheet_music.dart';
import 'package:drums/models/sheet_music_bar.dart';
import 'package:drums/shared/fix_height_row.dart';
import 'package:drums/widgets/beat.dart';
import 'package:drums/widgets/time_signature.dart';
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
                  TimeSignatureWidget(),
                  _RemoveBarButton(bar: bar),
                ],
              ),
              Column(
                children: bar.drumBars
                    .map((BarModel bar) => _BeatsRow(bar: bar))
                    .toList(),
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
                padding: EdgeInsets.symmetric(horizontal: 5),
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

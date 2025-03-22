import 'package:drums/models/bar.dart';
import 'package:drums/models/drum_set.dart';
import 'package:drums/models/sheet_music.dart';
import 'package:drums/shared/fix_height_row.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BarWidget extends StatelessWidget {
  const BarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BarModel>(
      builder: (BuildContext context, BarModel bar, _) {
        return IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FixHeightRow(
                children: [
                  Text("Bar:"),
                  _RemoveBarButton(bar: bar),
                ],
              ),
              ...bar.selectedDrums.map(
                (Drums drum) => FixHeightRow(
                  children: [Text("${drum.name} beats")],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RemoveBarButton extends StatelessWidget {
  const _RemoveBarButton({required this.bar});

  final BarModel bar;

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

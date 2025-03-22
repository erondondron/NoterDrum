import 'package:drums/drum_set.dart';
import 'package:drums/models.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SheetMusicWidget extends StatelessWidget {
  const SheetMusicWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DrumSetModel>(
      builder: (BuildContext context, DrumSetModel sheetMusic, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [DrumSetWidget()],
        );
      },
    );
  }
}

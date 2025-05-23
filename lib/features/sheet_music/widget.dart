import 'dart:math';

import 'package:drums/features/app_bar.dart';
import 'package:drums/features/sheet_music/actions/widget.dart';
import 'package:drums/features/sheet_music/measure/model.dart';
import 'package:drums/features/sheet_music/measure/widget.dart';
import 'package:drums/features/sheet_music/model.dart';
import 'package:drums/features/sheet_music/drum_set/widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SheetMusicWindow extends StatelessWidget {
  static const double bodyPadding = 25;

  const SheetMusicWindow({super.key});

  @override
  Widget build(BuildContext context) {
    var notchSize = MediaQuery.of(context).padding.left;
    var leftPadding = max(notchSize, NoterDrumAppBar.leftPadding);
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        InteractiveViewer(
          clipBehavior: Clip.antiAlias,
          constrained: false,
          panAxis: PanAxis.aligned,
          child: Padding(
            padding: EdgeInsets.only(
              left: leftPadding,
              top: bodyPadding,
              right: bodyPadding * 2 + ActionsPanel.size,
              bottom: bodyPadding * 2 + ActionsPanel.size,
            ),
            child: Container(
              constraints: BoxConstraints(
                minHeight: height - NoterDrumAppBar.height - bodyPadding * 2,
                minWidth: width - leftPadding - bodyPadding,
              ),
              child: _SheetMusicMeasuresWidget(),
            ),
          ),
        ),
        Positioned(
          right: bodyPadding,
          bottom: bodyPadding,
          child: ActionsPanel(),
        ),
      ],
    );
  }
}

class _SheetMusicMeasuresWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SheetMusic>(
      builder: (BuildContext context, SheetMusic sheetMusic, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: sheetMusic.measures.map((SheetMusicMeasure measure) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: <Widget>[
                  ChangeNotifierProvider.value(
                    value: sheetMusic.drumSet,
                    child: const DrumSetWidget(),
                  ),
                  ChangeNotifierProvider.value(
                    value: measure,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: SheetMusicMeasureWidget(),
                    ),
                  ),
                  if (measure == sheetMusic.measures.last)
                    IconButton(
                      icon: const Icon(Icons.add_outlined),
                      onPressed: sheetMusic.addNewMeasure,
                    ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

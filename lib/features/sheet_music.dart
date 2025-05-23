import 'dart:math';

import 'package:drums/features/actions/widget.dart';
import 'package:drums/features/app_bar.dart';
import 'package:drums/features/edit_grid/drum_set.dart';
import 'package:drums/features/edit_grid/measure.dart';
import 'package:drums/features/edit_grid/note.dart';
import 'package:drums/features/models/measure.dart';
import 'package:drums/features/models/groove.dart';
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
    var actionPanelSize = bodyPadding * 2 + ActionsPanel.size;

    return Stack(
      children: [
        InteractiveViewer(
          clipBehavior: Clip.antiAlias,
          constrained: false,
          panAxis: PanAxis.aligned,
          child: Padding(
            padding: EdgeInsets.only(
              left: leftPadding,
              right: actionPanelSize,
              bottom: actionPanelSize,
            ),
            child: Container(
              constraints: BoxConstraints(
                minHeight: height - NoterDrumAppBar.height - actionPanelSize,
                minWidth: width - leftPadding - actionPanelSize,
              ),
              child: _GrooveMeasuresWidget(),
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

class _GrooveMeasuresWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<Groove>(
      builder: (BuildContext context, Groove groove, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: groove.measures.map((GrooveMeasure measure) {
            return Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  ChangeNotifierProvider.value(
                    value: groove.drumSet,
                    child: const DrumSetWidget(),
                  ),
                  ChangeNotifierProvider.value(
                    value: measure,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: GrooveMeasureWidget(),
                    ),
                  ),
                  if (measure == groove.measures.last)
                    SizedBox(
                      height: (groove.drumSet.selected.length + 1) *
                          NoteView.height,
                      child: IconButton(
                        icon: const Icon(Icons.add_outlined),
                        onPressed: groove.addNewMeasure,
                      ),
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

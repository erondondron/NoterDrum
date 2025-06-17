import 'package:drums/edit_grid/configuration.dart';
import 'package:drums/models/drum_set.dart';
import 'package:drums/shared/svg_icon.dart';
import 'package:drums/shared/fix_height_row.dart';
import 'package:drums/shared/text_with_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DrumSetWidget extends StatelessWidget {
  const DrumSetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<DrumSet, DrumSetPanelController>(
      builder: (BuildContext context, DrumSet drumSet,
          DrumSetPanelController controller, _) {
        return IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ControlPanel(drumSet: drumSet, controller: controller),
              ...drumSet.selected.map(
                (Drum drum) => _SelectedDrumRow(
                  drumSet: drumSet,
                  drum: drum,
                  isHidden: controller.isHidden,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ControlPanel extends StatelessWidget {
  const _ControlPanel({
    required this.drumSet,
    required this.controller,
  });

  final DrumSet drumSet;
  final DrumSetPanelController controller;

  @override
  Widget build(BuildContext context) {
    final toggle = _HidingToggle(controller: controller);
    if (controller.isHidden) return toggle;

    final moreButton = _SelectNewDrumButton(drumSet: drumSet);
    return FixHeightRow(children: [moreButton, toggle]);
  }
}

class _SelectNewDrumButton extends StatelessWidget {
  const _SelectNewDrumButton({required this.drumSet});

  final DrumSet drumSet;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Drum>(
      child: TextWithIcon(
        icon: SizedBox(
          height: EditGridConfiguration.noteHeight,
          width: EditGridConfiguration.noteHeight,
          child: Icon(Icons.add_outlined),
        ),
        text: Text("More"),
      ),
      onSelected: (Drum drum) => drumSet.add(drum),
      itemBuilder: (BuildContext context) {
        return drumSet.unselected
            .map(
              (drum) => PopupMenuItem(
                value: drum,
                child: TextWithIcon(
                  icon: SvgIcon(asset: drum.icon),
                  text: Text(drum.name),
                ),
              ),
            )
            .toList();
      },
    );
  }
}

class _HidingToggle extends StatelessWidget {
  const _HidingToggle({required this.controller});

  final DrumSetPanelController controller;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: controller.toggleHiding,
      behavior: HitTestBehavior.translucent,
      child: SizedBox(
        height: EditGridConfiguration.noteHeight,
        width: EditGridConfiguration.noteHeight,
        child: controller.isHidden
            ? Icon(Icons.keyboard_double_arrow_right_outlined, size: 24)
            : Icon(Icons.keyboard_double_arrow_left_outlined, size: 18),
      ),
    );
  }
}

class _SelectedDrumRow extends StatelessWidget {
  const _SelectedDrumRow({
    required this.drumSet,
    required this.drum,
    required this.isHidden,
  });

  final DrumSet drumSet;
  final Drum drum;
  final bool isHidden;

  @override
  Widget build(BuildContext context) {
    final icon = SvgIcon(asset: drum.icon);
    if (isHidden) return icon;

    return FixHeightRow(
      children: [
        TextWithIcon(icon: icon, text: Text(drum.name)),
        _RemoveDrumButton(drumSet: drumSet, drum: drum)
      ],
    );
  }
}

class _RemoveDrumButton extends StatelessWidget {
  const _RemoveDrumButton({required this.drumSet, required this.drum});

  final DrumSet drumSet;
  final Drum drum;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => drumSet.remove(drum),
      behavior: HitTestBehavior.translucent,
      child: SizedBox(
        height: EditGridConfiguration.noteHeight,
        width: EditGridConfiguration.noteHeight,
        child: Icon(Icons.close_outlined, size: 15),
      ),
    );
  }
}
